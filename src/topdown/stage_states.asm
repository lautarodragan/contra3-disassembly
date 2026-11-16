; topdown/stage_states.asm -- Top-down stages: state machine and setup
; Bank $02, $02:8000-$02:8E32. Included by main.asm in segment BANK02.
;
; Entered from tbl_stage_runners for stages 2 and 5 (top-down, Mode 7): run_topdown_stage
; dispatches topdown_state through tbl_stage2_states (tbl_stage5_states in stage 5):
; setup, the start-point intro, the Select map view, play, boss and stage end.

; Top-down stage frame (stages 2 and 5), reached from tbl_stage_runners: runs
; state topdown_state of tbl_stage2_states, or tbl_stage5_states when
; stage_number is 5.
run_topdown_stage:
	.a16
	.i16
	rep	#$30
	lda	stage_number
	cmp	#$0005
	beq	run_stage5_state
	lda	a:topdown_state
	phx
	asl	a
	tax
	lda	f:tbl_stage2_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_states:
	.addr	topdown_state_init
	.addr	stage2_state_setup
	.addr	stage2_state_intro
	.addr	stage2_state_play
	.addr	stage2_state_boss_setup
	.addr	stage2_state_boss
; Stage 5: the same through tbl_stage5_states.
run_stage5_state:
	lda	a:topdown_state
	phx
	asl	a
	tax
	lda	f:tbl_stage5_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_states:
	.addr	topdown_state_init
	.addr	stage5_state_setup
	.addr	stage5_state_intro
	.addr	stage5_state_play
	.addr	stage5_state_boss_setup
	.addr	stage5_state_boss

; State 0: resets the sound queue, clears the top-down RAM, sets NMI mode 4,
; loads the common graphics and sets up the PPU; next state 1 (or 4,
; straight to the boss, when stage_checkpoint is set).
topdown_state_init:
	stz	a:hdmaen_shadow
	jsl	f:reset_sound_queue
	jsr	a:clear_topdown_ram
	jsr	a:load_topdown_common_assets
	jsr	a:init_topdown_ppu
	jsr	a:set_status_bar_scroll
	lda	#$0001
	sta	pause_disabled
	ldy	#$0001
	lda	a:stage_checkpoint
	beq	@set_state
	; (not executed in the CDL traces)
	ldy	#$0004
@set_state:
	sty	a:topdown_state
	rtl

; State 1 of stage 2: resets the objects and the stage variables,
; spawns the targets, loads the stage graphics, screen in forced blank.
stage2_state_setup:
	jsr	a:init_stage2_vars
	jsl	f:spawn_stage2_targets
	jsr	a:reset_m7_block_patches
	jsr	a:load_stage2_assets
	jsr	a:blank_topdown_display
	jsl	f:init_topdown_irq
	inc	a:topdown_state
	rtl

; State 2: the start-point intro (update_topdown_intro); when it ends,
; puts the players at their start points.
stage2_state_intro:
	jsl	f:animate_topdown_palettes
	jsr	a:update_topdown_intro
	bcc	@return
	jsl	f:init_topdown_views
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_state
@return:
	rtl

; State 3: play. Map view (Select), players, objects, views; when every
; target is destroyed, fades out to the boss (check_targets_destroyed).
stage2_state_play:
	jsr	a:update_map_view
	bcc	@play
	; (not executed in the CDL traces)
	rtl
@play:
	jsl	f:update_topdown_players
	jsl	f:td_update_bombs
	jsl	f:update_map_objects
	jsl	f:td_update_enemies
	jsl	f:spawn_stage2_enemies
	jsl	f:update_td_items
	jsl	f:update_topdown_shots
	jsl	f:td_update_stage2_map_events
	jsl	f:update_screen_shake
	jsl	f:animate_topdown_palettes
	jsl	f:update_topdown_views
	jsl	f:td_run_collisions
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	@return
	jsr	a:check_targets_destroyed
@return:
	rtl

; Carry set when neither player has lives left: fades out and
; leaves the stage (topdown_state = 0, nmi_mode = 0, next game sub-mode).
check_topdown_game_over:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	@return_clc
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	beq	@leave_stage
	cmp	#$000F
	bne	@return_sec
	stz	a:fade_target_brightness
	lda	#$0081
	jsl	f:queue_sound
	bra	@return_sec
@leave_stage:
	stz	a:topdown_state
	stz	a:topdown_boss_end_step
	inc	mode_result
	stz	nmi_mode
@return_sec:
	sec
	rts
@return_clc:
	clc
	rts

; Once targets_left_flag is negative: waits $80 frames (sound $81
; at the start), fades out, then moves to the next state (boss setup).
check_targets_destroyed:
	lda	a:targets_left_flag
	bpl	@return
	lda	a:topdown_timer
	cmp	#$0080
	bne	@count_down
	lda	#$0081
	jsl	f:queue_sound
@count_down:
	dec	a:topdown_timer
	bpl	@return
	lda	a:inidisp_shadow
	beq	@next_state
	cmp	#$000F
	bne	@return
	stz	a:fade_target_brightness
	lda	#$0081
	jsl	f:queue_sound
	bra	@return
@next_state:
	lda	#$0001
	sta	pause_disabled
	inc	a:topdown_state
@return:
	rts

; State 4 of stage 2: clears objects and the top-down blocks, loads
; the boss map graphics, spawns the boss, starts the boss music ($68).
stage2_state_boss_setup:
	jsr	a:init_stage2_boss_vars
	jsl	f:stage2_boss_stream_chr
	jsl	f:init_topdown_views
	jsl	f:spawn_stage2_boss
	jsr	a:reset_m7_block_patches
	jsr	a:load_stage2_boss_assets
	lda	#$0068
	jsl	f:queue_sound
	jsl	f:init_topdown_hdma
	jsl	f:init_topdown_irq
	jsr	a:enable_topdown_display
	stz	pause_disabled
	stz	a:topdown_boss_end_step
	inc	a:topdown_state
	rtl

; State 5 of stage 2: the boss fight; update_stage2_boss_end ends the stage.
stage2_state_boss:
	lda	a:topdown_boss_end_step
	cmp	#$0002
	bcs	@after_updates
	jsl	f:update_topdown_players
	jsl	f:td_update_bombs
	jsl	f:update_map_objects
	jsl	f:update_td_items
	jsl	f:update_topdown_shots
	jsl	f:update_screen_shake
	jsl	f:animate_topdown_palettes
	jsl	f:update_topdown_views
	jsl	f:td_run_collisions
@after_updates:
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	@return
	jsr	a:update_stage2_boss_end
@return:
	rtl

; Steps after the stage 2 boss: wait for its defeat, delay, fade, exit.
update_stage2_boss_end:
	lda	a:topdown_boss_end_step
	phx
	asl	a
	tax
	lda	f:tbl_stage2_boss_end_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_boss_end_steps:
	.addr	stage2_boss_wait_defeat
	.addr	stage2_boss_defeat_delay
	.addr	stage2_boss_exit

; Waits for the boss object ($0AC0) to reach state $12 (defeated).
stage2_boss_wait_defeat:
	lda	a:td_boss_state
	cmp	#$0012
	bne	stage2_boss_end_return
	lda	#$0081
	jsl	f:queue_sound
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_boss_end_step
	rts

; Counts topdown_timer down, then resets the sound queue and fades out.
stage2_boss_defeat_delay:
	dec	a:topdown_timer
	bpl	stage2_boss_end_return
	jsl	f:reset_sound_queue
	lda	#$0001
	sta	pause_disabled
	stz	a:fade_target_brightness
	inc	a:topdown_boss_end_step
stage2_boss_end_return:
	rts

; When the screen is black, leaves the stage (next game sub-mode, NMI mode 0).
stage2_boss_exit:
	jsr	a:update_topdown_fade
	lda	a:inidisp_shadow
	bne	stage2_boss_end_return
	jsl	f:reset_sound_queue
	stz	a:topdown_state
	stz	a:topdown_boss_end_step
	inc	mode_result
	stz	nmi_mode
	rts

; State 1 of stage 5 (see stage2_state_setup).
stage5_state_setup:
	jsr	a:init_stage5_vars
	jsl	f:spawn_stage5_targets
	jsr	a:reset_m7_block_patches
	jsr	a:load_stage5_assets
	jsr	a:blank_topdown_display
	jsl	f:init_topdown_irq
	inc	a:topdown_state
	rtl

; State 2 of stage 5 (see stage2_state_intro).
stage5_state_intro:
	jsl	f:animate_topdown_palettes
	jsr	a:update_topdown_intro
	bcc	@return
	jsl	f:init_topdown_views
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_state
@return:
	rtl

; State 3 of stage 5 (see stage2_state_play).
stage5_state_play:
	jsr	a:update_map_view
	bcc	@play
	; (not executed in the CDL traces)
	rtl
@play:
	jsl	f:update_topdown_players
	jsl	f:td_update_bombs
	jsl	f:update_map_objects
	jsl	f:td_update_enemies
	jsl	f:spawn_stage5_enemies
	jsl	f:update_td_items
	jsl	f:update_topdown_shots
	jsl	f:td_update_switch_events
	jsl	f:update_screen_shake
	jsl	f:animate_topdown_palettes
	jsl	f:update_topdown_views
	jsl	f:td_run_collisions
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	@return
	jsr	a:check_targets_destroyed
@return:
	rtl

; State 4 of stage 5 (see stage2_state_boss_setup).
stage5_state_boss_setup:
	jsr	a:init_stage5_boss_vars
	jsl	f:stage5_boss_stream_chr
	jsl	f:init_topdown_views
	jsl	f:spawn_stage5_boss
	jsr	a:reset_m7_block_patches
	jsr	a:load_stage5_boss_assets
	lda	#$0068
	jsl	f:queue_sound
	jsl	f:init_topdown_hdma
	jsl	f:init_topdown_irq
	jsr	a:enable_topdown_display
	stz	pause_disabled
	stz	a:topdown_boss_end_step
	inc	a:topdown_state
	rtl

; State 5 of stage 5: the boss fight; update_stage5_boss_end ends the stage.
stage5_state_boss:
	lda	a:topdown_boss_end_step
	cmp	#$0002
	bcs	@after_updates
	jsl	f:update_topdown_players
	jsl	f:td_update_bombs
	jsl	f:update_stage5_boss_objects
	jsl	f:update_stage5_boss_arm
	jsl	f:update_td_items
	jsl	f:update_topdown_shots
	jsl	f:update_screen_shake
	jsl	f:animate_topdown_palettes
	jsl	f:update_topdown_views
	jsl	f:td_run_collisions
@after_updates:
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	@return
	jsr	a:update_stage5_boss_end
@return:
	rtl

; Steps after the stage 5 boss (see update_stage2_boss_end).
update_stage5_boss_end:
	lda	a:topdown_boss_end_step
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_end_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_end_steps:
	.addr	stage5_boss_wait_defeat
	.addr	stage5_boss_defeat_delay
	.addr	stage5_boss_exit

; Waits for the boss object ($0AC0) to reach state $09 (defeated).
stage5_boss_wait_defeat:
	lda	a:td_boss_state
	cmp	#$0009
	bne	stage5_boss_end_return
	lda	#$0081
	jsl	f:queue_sound
	lda	#$0040
	sta	a:topdown_timer
	inc	a:topdown_boss_end_step
	rts

; Counts topdown_timer down, then resets the sound queue and fades out.
stage5_boss_defeat_delay:
	dec	a:topdown_timer
	bpl	stage5_boss_end_return
	jsl	f:reset_sound_queue
	lda	#$0001
	sta	pause_disabled
	stz	a:fade_target_brightness
	inc	a:topdown_boss_end_step
stage5_boss_end_return:
	rts

; When the screen is black, leaves the stage.
stage5_boss_exit:
	jsr	a:update_topdown_fade
	lda	a:inidisp_shadow
	bne	stage5_boss_end_return
	jsl	f:reset_sound_queue
	stz	a:topdown_state
	stz	a:topdown_boss_end_step
	inc	mode_result
	stz	nmi_mode
	rts

; The Select map view: the whole map zoomed out (scale $0500).
; Returns carry set while the map view is open (play is suspended).
update_map_view:
	jsl	f:animate_topdown_palettes
	lda	a:map_view_step
	asl	a
	tax
	jmp	(.loword(tbl_map_view_steps),x)
tbl_map_view_steps:
	.addr	map_view_check_select
	.addr	map_view_fade_out
	.addr	map_view_open
	.addr	map_view_fade_in
	.addr	map_view_wait_select
	.addr	map_view_fade_out_2
	.addr	map_view_close
	.addr	map_view_restore_brightness

; Step 0: Select (by a player with lives) saves the brightness and opens the map.
map_view_check_select:
	lda	paused
	bne	@return_clc
	lda	#$0000
	ldy	a:p1_lives
	beq	@p2_input
	ora	joy1_pressed
@p2_input:
	ldy	a:p2_lives
	beq	@test_select
	ora	joy2_pressed
@test_select:
	bit	#$2000
	beq	@return_clc
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	sta	a:map_view_saved_inidisp
	lda	a:p1_view_brightness
	sta	a:map_view_saved_p1_brightness
	lda	a:p2_view_brightness
	sta	a:map_view_saved_p2_brightness
	lda	#$0001
	sta	pause_disabled
	lda	#$0001
	sta	a:map_view_step
	sec
	rts
@return_clc:
	clc
	rts

; Step 1: fades every view to black.
map_view_fade_out:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	ora	a:p1_view_brightness
	ora	a:p2_view_brightness
	beq	@black
	dec	a:inidisp_shadow
	bpl	@fade_p1
	stz	a:inidisp_shadow
@fade_p1:
	dec	a:p1_view_brightness
	bpl	@fade_p2
	stz	a:p1_view_brightness
@fade_p2:
	dec	a:p2_view_brightness
	bpl	@return_sec
	stz	a:p2_view_brightness
@return_sec:
	sec
	rts
@black:
	inc	a:map_view_step
	jsr	a:blank_topdown_display
	sec
	rts

; Step 2: Mode 7, scale $0500, centre $0000, scroll -$1A/-$0A: the whole map.
map_view_open:
	; (not executed in the CDL traces)
	stz	a:topdown_window_update_on
	lda	#$0001
	sta	a:map_view_active
	lda	#M7_SCALE_MAP
	sta	a:p1_m7_scale_x
	sta	a:p1_m7_scale_y
	lda	#$0000
	sta	a:p1_m7_center_x
	lda	#$FFE6	; [num]
	sta	a:p1_m7_hofs
	lda	#$0000
	sta	a:p1_m7_center_y
	lda	#$FFF6	; [num]
	sta	a:p1_m7_vofs
	stz	a:p1_m7_angle
	inc	a:map_view_step
	sep	#$20
	.a8
	lda	#$12
	sta	a:OBSEL
	lda	#$07
	sta	a:BGMODE
	lda	#$80
	sta	a:M7SEL
	lda	#$13
	sta	a:TM
	lda	#$40
	sta	a:SETINI
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	stz	m7_split_screen
	lda	#$0000
	sta	a:vtime_shadow
	stz	a:inidisp_shadow
	stz	a:p1_view_brightness
	stz	a:p2_view_brightness
	sec
	rts

; Step 3: fades in.
map_view_fade_in:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	@next_step
	inc	a:inidisp_shadow
	inc	a:p1_view_brightness
	inc	a:p2_view_brightness
	sec
	rts
@next_step:
	inc	a:map_view_step
	sec
	rts

; Step 4: waits for Select.
map_view_wait_select:
	; (not executed in the CDL traces)
	lda	#$0000
	ldy	a:p1_lives
	beq	@p2_input
	ora	joy1_pressed
@p2_input:
	ldy	a:p2_lives
	beq	@test_select
	ora	joy2_pressed
@test_select:
	bit	#$2000
	beq	@return_sec
	inc	a:map_view_step
@return_sec:
	sec
	rts

; Step 5: fades out, then forced blank.
map_view_fade_out_2:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	beq	@black
	dec	a:inidisp_shadow
	dec	a:p1_view_brightness
	dec	a:p2_view_brightness
	sec
	rts
@black:
	inc	a:map_view_step
	lda	#$0080
	sta	a:inidisp_shadow
	sta	a:p1_view_brightness
	sta	a:p2_view_brightness
	sec
	rts

; Step 6: hides the sprites, scale back to $0100, recomputes the views.
map_view_close:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	a:topdown_window_update_on
	stz	a:map_view_active
	rep	#$30
	phb
	lda	#$0000
	sta	f:oam_buffer
	lda	#$021E
	ldx	#$0FC0
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#M7_SCALE_1X
	sta	a:p1_m7_scale_x
	sta	a:p1_m7_scale_y
	jsl	f:update_topdown_views
	sep	#$20
	.a8
	lda	#$0A
	sta	a:OBSEL
	lda	#$09
	sta	a:BGMODE
	stz	a:M7SEL
	rep	#$20
	.a16
	jsl	f:init_topdown_irq
	inc	a:map_view_step
	jsr	a:enable_topdown_display
	sec
	rts

; Step 7: fades back to the saved brightness; closes the map view.
map_view_restore_brightness:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	cmp	a:map_view_saved_inidisp
	bcs	@restore_saved
	inc	a:inidisp_shadow
	lda	a:p1_view_brightness
	cmp	a:map_view_saved_p1_brightness
	bcs	@p2_brightness
	inc	a:p1_view_brightness
@p2_brightness:
	lda	a:p2_view_brightness
	cmp	a:map_view_saved_p2_brightness
	bcs	@return_sec
	inc	a:p2_view_brightness
@return_sec:
	sec
	rts
@restore_saved:
	lda	a:map_view_saved_inidisp
	sta	a:inidisp_shadow
	lda	a:map_view_saved_p1_brightness
	sta	a:p1_view_brightness
	lda	a:map_view_saved_p2_brightness
	sta	a:p2_view_brightness
	stz	pause_disabled
	stz	a:map_view_step
	sec
	rts

; The start-point intro ("CHOOSE YOUR STARTING POINT"): runs a step of
; tbl_intro_steps; returns carry set when the intro is over.
update_topdown_intro:
	lda	a:intro_step
	asl	a
	tax
	jmp	(.loword(tbl_intro_steps),x)
tbl_intro_steps:
	.addr	intro_init
	.addr	intro_fade_in
	.addr	intro_choose_start
	.addr	intro_start_chosen
	.addr	intro_play_music
	.addr	intro_zoom_in
	.addr	intro_done

; Step 0: map zoomed out, random cursors, PPU and colour math setup, sound $6F.
intro_init:
	lda	#$006F
	jsl	f:queue_sound
	stz	a:topdown_window_update_on
	lda	#$0001
	sta	a:intro_phase
	jsr	a:init_intro_views
	jsr	a:randomize_start_cursors
	stz	a:p1_start_chosen
	stz	a:p2_start_chosen
	sep	#$20
	.a8
	lda	#$12
	sta	a:OBSEL
	lda	#$07
	sta	a:BGMODE
	stz	a:M7SEL
	stz	a:W12SEL
	stz	a:W34SEL
	lda	#$80
	sta	a:WOBJSEL
	stz	a:WH0
	stz	a:WH1
	stz	a:WBGLOG
	stz	a:WOBJLOG
	lda	#$13
	sta	a:TM
	stz	a:TS
	stz	a:TMW
	stz	a:TSW
	lda	#$20
	sta	a:CGWSEL
	lda	#$83
	sta	a:CGADSUB
	lda	#$FF
	sta	a:COLDATA
	lda	#$40
	sta	a:SETINI
	rep	#$20
	.a16
	stz	m7_split_screen
	ldy	#.loword(hdma_list_05CD59)
	jsl	f:setup_hdma_from_list
	lda	#$0080
	sta	a:hdmaen_shadow
	stz	a:inidisp_shadow
	stz	a:p1_view_brightness
	stz	a:p2_view_brightness
	inc	a:intro_step
	clc
	rts

; Step 1: fades in.
intro_fade_in:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	@next_step
	inc	a:inidisp_shadow
	inc	a:p1_view_brightness
	inc	a:p2_view_brightness
	clc
	rts
@next_step:
	inc	a:intro_step
	clc
	rts

; Step 2: moves the cursors until every player has chosen a start point.
intro_choose_start:
	jsr	a:init_intro_views
	jsr	a:move_start_cursors
	jsr	a:check_start_points_chosen
	bcc	@return_clc
	lda	#$0040
	sta	a:topdown_timer
	stz	pause_disabled
	inc	a:intro_step
@return_clc:
	clc
	rts

; Carry set when both p1_start_chosen and p2_start_chosen are 2.
check_start_points_chosen:
	lda	a:p1_start_chosen
	and	a:p2_start_chosen
	cmp	#$0002
	rts

; Step 3: colour fade, then the players' positions from the chosen start points.
intro_start_chosen:
	dec	a:topdown_timer
	bmi	@set_positions
	lda	a:topdown_timer
	lsr	a
	ora	#$00E0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	clc
	rts
@set_positions:
	lda	#$0002
	sta	a:intro_phase
	jsr	a:set_start_points
	jsl	f:init_topdown_hdma
	sep	#$20
	.a8
	lda	#$FC
	sta	a:hdmaen_shadow
	lda	#$80
	sta	a:WOBJSEL
	stz	a:CGWSEL
	stz	a:CGADSUB
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:title_menu_cursor
	beq	@set_timer
	dec	a
	bne	@set_timer
	lda	#$0002
	sta	m7_split_screen
@set_timer:
	lda	#$0040
	sta	a:topdown_timer
	inc	a:intro_step
	clc
	rts

; Step 4: after a delay, starts the stage music (topdown_stage_songs).
intro_play_music:
	sep	#$20
	.a8
	lda	#$0A
	sta	a:OBSEL
	rep	#$20
	.a16
	dec	a:topdown_timer
	bpl	@return_clc
	lda	a:topdown_map
	lsr	a
	and	#$0002
	tay
	lda	a:topdown_stage_songs,y
	jsl	f:queue_sound
	inc	a:intro_step
@return_clc:
	clc
	rts

; Step 5: zooms in and spins the views until the scale is back to $0100.
intro_zoom_in:
	jsr	a:zoom_in_views
	jsr	a:set_intro_scroll
	lda	a:p1_m7_scale_x
	cmp	#M7_SCALE_1X
	bne	@return_clc
	inc	a:intro_step
@return_clc:
	clc
	rts

; Step 6: intro over (carry set).
intro_done:
	lda	#$0001
	sta	a:topdown_window_update_on
	stz	a:intro_phase
	stz	a:intro_step
	sec
	rts

; Puts the start cursors at a random column and row (0-3).
randomize_start_cursors:
	lda	a:title_menu_cursor
	beq	@p1_cursor
	dec	a
	beq	@two_players_a
	; (not executed in the CDL traces)
	lda	rng_lo
	and	#$0003
	sta	a:p1_start_x
	sta	a:p2_start_x
	lda	zp_E9
	and	#$0003
	sta	a:p1_start_y
	sta	a:p2_start_y
	rts
@two_players_a:
	lda	rng_hi
	and	#$0003
	sta	a:p2_start_x
	lda	zp_EB
	and	#$0003
	sta	a:p2_start_y
@p1_cursor:
	lda	rng_lo
	and	#$0003
	sta	a:p1_start_x
	lda	zp_E9
	and	#$0003
	sta	a:p1_start_y
	rts

; Joypad 1 moves player 1's start cursor (up/down: row, left/right:
; column, wrapping); Y or Start chooses. Player 2 too in 2P-A.
move_start_cursors:
	lda	a:title_menu_cursor
	bne	@two_players
	brl	@p1_cursor
@two_players:
	dec	a
	bne	@mode_b
	brl	@two_players_a
@mode_b:
	; (not executed in the CDL traces)
	lda	a:p1_start_chosen
	and	a:p2_start_chosen
	bne	@return
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$5000
	bne	@b_chosen
	bit	#$0F00
	bne	@b_move
@return:
	rts
@b_move:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	@b_up
	bit	#$0400
	bne	@b_down
	bit	#$0100
	bne	@b_right
	bra	@b_left
@b_chosen:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p1_start_chosen
	sta	a:p2_start_chosen
	rts
@b_up:
	lda	a:p1_start_y
	dec	a
	bpl	@b_up_store
	lda	#$0003
@b_up_store:
	sta	a:p1_start_y
	sta	a:p2_start_y
	rts
@b_down:
	lda	a:p1_start_y
	inc	a
	cmp	#$0004
	bcc	@b_down_store
	lda	#$0000
@b_down_store:
	sta	a:p1_start_y
	sta	a:p2_start_y
	rts
@b_left:
	lda	a:p1_start_x
	dec	a
	bpl	@b_left_store
	lda	#$0003
@b_left_store:
	sta	a:p1_start_x
	sta	a:p2_start_x
	rts
@b_right:
	lda	a:p1_start_x
	inc	a
	cmp	#$0004
	bcc	@b_right_store
	lda	#$0000
@b_right_store:
	sta	a:p1_start_x
	sta	a:p2_start_x
	rts
@two_players_a:
	jsr	a:move_p2_start_cursor
@p1_cursor:
	lda	a:p1_lives
	beq	@return2
	lda	a:p1_start_chosen
	bne	@return2
	lda	joy1_pressed
	bit	#$5000
	bne	@chosen
	bit	#$0F00
	bne	@move
@return2:
	rts
@move:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	@up
	bit	#$0400
	bne	@down
	bit	#$0100
	bne	@right
	bra	@left
@chosen:
	lda	a:p2_lives
	bne	@confirm
	lda	#$0002
	sta	a:p2_start_chosen
@confirm:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p1_start_chosen
	rts
@up:
	lda	a:p1_start_y
	dec	a
	bpl	@up_store
	lda	#$0003
@up_store:
	sta	a:p1_start_y
	rts
@down:
	lda	a:p1_start_y
	inc	a
	cmp	#$0004
	bcc	@down_store
	; (not executed in the CDL traces)
	lda	#$0000
@down_store:
	sta	a:p1_start_y
	rts
@left:
	lda	a:p1_start_x
	dec	a
	bpl	@left_store
	; (not executed in the CDL traces)
	lda	#$0003
@left_store:
	sta	a:p1_start_x
	rts
@right:
	lda	a:p1_start_x
	inc	a
	cmp	#$0004
	bcc	@right_store
	lda	#$0000
@right_store:
	sta	a:p1_start_x
	rts

; Joypad 2 moves player 2's start cursor.
move_p2_start_cursor:
	lda	a:p2_lives
	beq	@return
	lda	a:p2_start_chosen
	bne	@return
	lda	joy2_pressed
	bit	#$5000
	bne	@chosen
	bit	#$0F00
	bne	@move
@return:
	rts
@move:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	@up
	; (not executed in the CDL traces)
	bit	#$0400
	bne	@down
	bit	#$0100
	bne	@right
	bra	@left
@chosen:
	lda	a:p1_lives
	bne	@confirm
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:p1_start_chosen
@confirm:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p2_start_chosen
	rts
@up:
	lda	a:p2_start_y
	dec	a
	bpl	@up_store
	; (not executed in the CDL traces)
	lda	#$0003
@up_store:
	sta	a:p2_start_y
	rts
@down:
	; (not executed in the CDL traces)
	lda	a:p2_start_y
	inc	a
	cmp	#$0004
	bcc	@down_store
	lda	#$0000
@down_store:
	sta	a:p2_start_y
	rts
@left:
	lda	a:p2_start_x
	dec	a
	bpl	@left_store
	lda	#$0003
@left_store:
	sta	a:p2_start_x
	rts
@right:
	lda	a:p2_start_x
	inc	a
	cmp	#$0004
	bcc	@right_store
	lda	#$0000
@right_store:
	sta	a:p2_start_x
	rts

; Both views: angle 0, scale $0500, centre ($200, $200), scroll ($180, $180).
init_intro_views:
	lda	#$0000
	sta	a:p1_m7_angle
	sta	a:p2_m7_angle
	lda	#M7_SCALE_MAP
	sta	a:p1_m7_scale_x
	sta	a:p1_m7_scale_y
	sta	a:p2_m7_scale_x
	sta	a:p2_m7_scale_y
	lda	#$0200
	sta	a:p1_m7_center_x
	sta	a:p2_m7_center_x
	lda	#$0200
	sta	a:p1_m7_center_y
	sta	a:p2_m7_center_y
	lda	#$0180
	sta	a:p1_m7_hofs
	sta	a:p2_m7_hofs
	lda	#$0180
	sta	a:p1_m7_vofs
	sta	a:p2_m7_vofs
	rts

; Sets each player's view position (p1_view_x/y) from the chosen start
; point (start_points_x/y), and p1_start_x/y to the zoom-in target.
set_start_points:
	lda	a:title_menu_cursor
	beq	@one_player
	dec	a
	beq	@two_players_a
	; (not executed in the CDL traces)
	lda	#$0080
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	lda	#$007C
	sta	a:p1_view_anchor_y
	sta	a:p2_view_anchor_y
	jsr	a:get_p1_start_point_index
	lda	a:start_points_x,y
	sta	a:p1_view_x
	sta	a:p2_view_x
	clc
	adc	#$0080
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_start_x
	lda	a:start_points_y,y
	sta	a:p1_view_y
	sta	a:p2_view_y
	clc
	adc	#$0070
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_start_y
	rts
@one_player:
	lda	#$0080
	sta	a:p1_view_anchor_x
	lda	#$00A0
	sta	a:p1_view_anchor_y
	jsr	a:get_p1_start_point_index
	lda	a:start_points_x,y
	sta	a:p1_view_x
	clc
	adc	#$0080
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_start_x
	lda	a:start_points_y,y
	sta	a:p1_view_y
	clc
	adc	#$0070
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_start_y
	rts
@two_players_a:
	lda	#$0060
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	lda	#$0034
	sta	a:p1_view_anchor_y
	lda	#$00AC
	sta	a:p2_view_anchor_y
	jsr	a:get_p1_start_point_index
	lda	a:start_points_x,y
	sta	a:p1_view_x
	clc
	adc	#$0080
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_start_x
	lda	a:start_points_y,y
	sta	a:p1_view_y
	clc
	adc	#$0070
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_start_y
	jsr	a:get_p2_start_point_index
	lda	a:start_points_x,y
	sta	a:p2_view_x
	clc
	adc	#$0080
	sec
	sbc	a:p2_view_anchor_x
	sta	a:p2_start_x
	lda	a:start_points_y,y
	sta	a:p2_view_y
	clc
	adc	#$0070
	sec
	sbc	a:p2_view_anchor_y
	sta	a:p2_start_y
	rts

; Y = index of player 1's start point (row * 4 + column, +16 for stage 5) x2.
get_p1_start_point_index:
	lda	a:p1_start_y
	asl	a
	asl	a
	clc
	adc	a:p1_start_x
	ldy	stage_number
	cpy	#$0002
	beq	@to_offset
	clc
	adc	#$0010
@to_offset:
	asl	a
	tay
	rts

; Y = index of player 2's start point.
get_p2_start_point_index:
	lda	a:p2_start_y
	asl	a
	asl	a
	clc
	adc	a:p2_start_x
	ldy	stage_number
	cpy	#$0002
	beq	@to_offset
	clc
	adc	#$0010
@to_offset:
	asl	a
	tay
	rts

; Scale -4 per frame (and angle +2 until 1:1), centres towards the start points.
zoom_in_views:
	lda	a:title_menu_cursor
	beq	@p1_view
	dec	a
	bne	@p1_view
	lda	a:p2_m7_scale_x
	sec
	sbc	#$0004
	sta	a:p2_m7_scale_x
	lda	a:p2_m7_scale_y
	sec
	sbc	#$0004
	sta	a:p2_m7_scale_y
	cmp	#M7_SCALE_1X
	bcc	@p2_center
	dec	a:p2_m7_angle
	dec	a:p2_m7_angle
@p2_center:
	jsr	a:approach_p2_start_x
	jsr	a:approach_p2_start_y
@p1_view:
	lda	a:p1_m7_scale_x
	sec
	sbc	#$0004
	sta	a:p1_m7_scale_x
	lda	a:p1_m7_scale_y
	sec
	sbc	#$0004
	sta	a:p1_m7_scale_y
	cmp	#M7_SCALE_1X
	bcc	@p1_center
	inc	a:p1_m7_angle
	inc	a:p1_m7_angle
@p1_center:
	jsr	a:approach_p1_start_x
	jsr	a:approach_p1_start_y
	rts

; Moves p1_m7_center_x 2 pixels towards p1_start_x.
approach_p1_start_x:
	lda	a:p1_m7_center_x
	cmp	a:p1_start_x
	beq	@return
	bpl	@decrease
	clc
	adc	#$0002
	sta	a:p1_m7_center_x
	rts
@decrease:
	sec
	sbc	#$0002
	sta	a:p1_m7_center_x
@return:
	rts

; Moves p1_m7_center_y 2 pixels towards p1_start_y.
approach_p1_start_y:
	lda	a:p1_m7_center_y
	cmp	a:p1_start_y
	beq	@return
	bpl	@decrease
	clc
	adc	#$0002
	sta	a:p1_m7_center_y
	rts
@decrease:
	sec
	sbc	#$0002
	sta	a:p1_m7_center_y
@return:
	rts

; Moves p2_m7_center_x 2 pixels towards p2_start_x.
approach_p2_start_x:
	lda	a:p2_m7_center_x
	cmp	a:p2_start_x
	beq	@return
	bpl	@decrease
	; (not executed in the CDL traces)
	clc
	adc	#$0002
	sta	a:p2_m7_center_x
	rts
@decrease:
	sec
	sbc	#$0002
	sta	a:p2_m7_center_x
@return:
	rts

; Moves p2_m7_center_y 2 pixels towards p2_start_y.
approach_p2_start_y:
	lda	a:p2_m7_center_y
	cmp	a:p2_start_y
	beq	@return
	bpl	@decrease
	clc
	adc	#$0002
	sta	a:p2_m7_center_y
	rts
@decrease:
	sec
	sbc	#$0002
	sta	a:p2_m7_center_y
@return:
	rts

; Scroll = centre - ($80, $70) for both views.
set_intro_scroll:
	lda	a:p1_m7_center_x
	sec
	sbc	#$0080
	sta	a:p1_m7_hofs
	lda	a:p1_m7_center_y
	sec
	sbc	#$0070
	sta	a:p1_m7_vofs
	lda	a:p2_m7_center_x
	sec
	sbc	#$0080
	sta	a:p2_m7_hofs
	lda	a:p2_m7_center_y
	sec
	sbc	#$0070
	sta	a:p2_m7_vofs
	rts

; Runs the loader lists load_list_05CF33 and load_list_05CF41.
load_topdown_common_assets:
	ldx	#.loword(load_list_05CF33)
	jsl	f:load_data_list
	jsl	f:init_hud
	ldx	#.loword(load_list_05CF41)
	jsl	f:load_data_list
	jsl	f:run_vram_queue
	rts

; BG maps/character bases, BG mode 1 + BG3 priority, sprites; display off.
init_topdown_ppu:
	sep	#$20
	.a8
	lda	#$5C
	sta	a:BG1SC
	lda	#$5C
	sta	a:BG2SC
	lda	#$5C
	sta	a:BG3SC
	lda	#$55
	sta	a:BG12NBA
	lda	#$05
	sta	a:BG34NBA
	lda	#$0A
	sta	a:OBSEL
	lda	#$09
	sta	a:BGMODE
	stz	a:M7SEL
	stz	a:MOSAIC
	rep	#$20
	.a16
	stz	a:BG1HOFS
	stz	a:BG1HOFS
	stz	a:BG2HOFS
	stz	a:BG2HOFS
	stz	a:TM
	stz	a:CGWSEL
	rts

; BG3 vertical scroll for the status bar, by 1P / 2P mode.
set_status_bar_scroll:
	lda	a:title_menu_cursor
	beq	@read_table
	dec	a
	eor	#$0001
	asl	a
@read_table:
	tay
	sep	#$20
	.a8
	stz	a:BG3HOFS
	stz	a:BG3HOFS
	lda	a:status_bar_vofs_lo,y
	sta	a:BG3VOFS
	lda	a:status_bar_vofs_hi,y
	sta	a:BG3VOFS
	rep	#$20
	.a16
	rts

; Clears $1500-$18FF and $7E:2000-$7E:3FFF and the Mode 7 variables; NMI mode 4.
clear_topdown_ram:
	lda	#$0004
	sta	nmi_mode
	rep	#$30
	phb
	lda	#$0000
	sta	f:stage_ram
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E2000
	lda	#$1FFE
	ldx	#$2000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	stz	a:p1_m7_center_x
	stz	a:p1_m7_center_y
	stz	a:p1_m7_scale_x
	stz	a:p1_m7_scale_y
	stz	a:p1_m7_angle
	stz	a:p1_weapon_slot
	stz	a:p1_m7_angle
	stz	a:p2_m7_center_x
	stz	a:p2_m7_center_y
	stz	a:p2_m7_scale_x
	stz	a:p2_m7_scale_y
	stz	a:p2_m7_angle
	stz	a:p2_weapon_slot
	stz	a:p2_m7_angle
	lda	#$0004
	sta	nmi_mode
	rts

; Points the four block patch slots at VRAM $6000, outside the Mode 7 data.
reset_m7_block_patches:
	lda	#$6000
	sta	a:m7_patch_vram
	sta	a:m7_patch_vram+2
	sta	a:m7_patch_vram+4
	sta	a:m7_patch_vram+6
	sta	a:m7_patch_vram+8
	sta	a:m7_patch_vram+10
	sta	a:m7_patch_vram+12
	sta	a:m7_patch_vram+14
	sta	a:m7_patch_vram+16
	sta	a:m7_patch_vram+18
	sta	a:m7_patch_vram+20
	sta	a:m7_patch_vram+22
	sta	a:m7_patch_vram+24
	sta	a:m7_patch_vram+26
	sta	a:m7_patch_vram+28
	sta	a:m7_patch_vram+30
	rts

; Loads stage 2's graphics (loader list load_list_05CF2A) and palettes.
load_stage2_assets:
	ldx	#.loword(load_list_05CF2A)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05CFB2)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads stage 5's graphics and palettes.
load_stage5_assets:
	ldx	#.loword(load_list_05D01F)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05D056)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads the stage 2 boss graphics and palettes.
load_stage2_boss_assets:
	ldx	#.loword(song_set_boss_full)
	jsl	f:load_song_set
	ldx	#.loword(load_list_05CFCF)
	jsl	f:load_data_list
	ldx	#.loword(load_list_05CFD8)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05D006)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads the stage 5 boss graphics and palettes.
load_stage5_boss_assets:
	ldx	#.loword(song_set_boss_full)
	jsl	f:load_song_set
	ldx	#.loword(load_list_05D073)
	jsl	f:load_data_list
	ldx	#.loword(load_list_05D07C)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05D0AA)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; topdown_map = stage 2, clears the objects ($0200-$11DF), full brightness target.
init_stage2_vars:
	stz	a:topdown_map
	stz	a:boss_centered_view
	lda	#$0004
	sta	a:targets_left_flag
; Shared tail of init_stage2_vars / init_stage5_vars: clears the objects
; ($0200-$11DF), window effect on, checkpoint 0, no barrier, fade to full
; brightness.
init_td_stage_common_vars:
	rep	#$30
	phb
	lda	#$0000
	sta	f:player1_obj
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0001
	sta	a:topdown_window_update_on
	stz	a:stage_checkpoint
	stz	a:p1_barrier_timer
	stz	a:p2_barrier_timer
	lda	#$000F
	sta	a:fade_target_brightness
	rts

; topdown_map = stage 5 and its own variables, then as init_stage2_vars.
init_stage5_vars:
	lda	#TD_MAP_STAGE5
	sta	a:topdown_map
	stz	a:boss_centered_view
	lda	#$0004
	sta	a:targets_left_flag
	lda	#$8000	; [num]
	sta	a:td_push_speed_frac
	stz	a:td_push_speed
	lda	#$0002
	sta	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	bra	init_td_stage_common_vars

; Boss of stage 2: clears objects and blocks, topdown_map = 2,
; boss_centered_view = 2 (view follows the boss), players at ($200, $280).
init_stage2_boss_vars:
	rep	#$30
	phb
	lda	#$0000
	sta	f:player1_obj
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:stage_ram
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:td_gfx_stream+GFXS_SRC
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#TD_MAP_STAGE2_BOSS
	sta	a:topdown_map
	sta	a:boss_centered_view
; Shared tail of init_stage2_boss_vars / init_stage5_boss_vars (after
; topdown_map and boss_centered_view): no targets, window effect on, checkpoint 1, fade to full
; brightness, both views at ($200, $280).
init_td_boss_common_vars:
	stz	a:targets_left_flag
	lda	#$0001
	sta	a:topdown_window_update_on
	lda	#$0001
	sta	a:stage_checkpoint
	lda	#$000F
	sta	a:fade_target_brightness
	lda	#$0200
	sta	a:p1_view_x
	sta	a:p2_view_x
	lda	#$0280
	sta	a:p1_view_y
	sta	a:p2_view_y
	rts

; Boss of stage 5: as init_stage2_boss_vars, topdown_map = 6.
init_stage5_boss_vars:
	rep	#$30
	phb
	lda	#$0000
	sta	f:player1_obj
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:stage_ram
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:td_gfx_stream+GFXS_SRC
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#TD_MAP_STAGE5_BOSS
	sta	a:topdown_map
	stz	a:boss_centered_view
	brl	init_td_boss_common_vars

; HDMA channels 2-7 on, display on at brightness 0.
enable_topdown_display:
	sep	#$20
	.a8
	lda	#$FC
	sta	a:hdmaen_shadow
	stz	a:INIDISP
	rep	#$20
	.a16
	stz	a:p1_view_brightness
	stz	a:p2_view_brightness
	stz	a:inidisp_shadow
	rts

; HDMA off, forced blank.
blank_topdown_display:
	sep	#$20
	.a8
	stz	a:hdmaen_shadow
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	lda	#$0080
	sta	a:p1_view_brightness
	sta	a:p2_view_brightness
	sta	a:inidisp_shadow
	rts

; Steps the brightness (inidisp_shadow and both views) towards fade_target_brightness.
update_topdown_fade:
	lda	a:inidisp_shadow
	cmp	a:fade_target_brightness
	beq	@return2
	bcs	@darker
	lda	stage_frame_counter
	bit	#$0001
	bne	@return2
	inc	a:inidisp_shadow
	lda	a:p1_view_brightness
	cmp	#$000F
	bcs	@p2_brighter
	inc	a:p1_view_brightness
@p2_brighter:
	lda	a:p2_view_brightness
	cmp	#$000F
	bcs	@return
	inc	a:p2_view_brightness
@return:
	rts
@darker:
	lda	stage_frame_counter
	bit	#$0003
	bne	@return2
	dec	a:inidisp_shadow
	lda	a:p1_view_brightness
	beq	@p2_darker
	dec	a:p1_view_brightness
@p2_darker:
	lda	a:p2_view_brightness
	beq	@return2
	dec	a:p2_view_brightness
@return2:
	rts

; Spawns stage 2's five targets in the slots from $0AC0 (types chosen by difficulty and random).
spawn_stage2_targets:
	lda	difficulty
	beq	@add_base
	tay
	lda	rng_lo
	and	#$0030
	ora	a:stage2_target_set_bases,y
@add_base:
	clc
	adc	#.loword(stage2_target_type_sets)
	sta	zp_FA
	ldy	#$0000
	ldx	#$0AC0
@loop:
	lda	(zp_FA),y
	sta	$10,x
	stz	$12,x
	lda	a:stage2_target_x,y
	sta	$0A,x
	lda	a:stage2_target_y,y
	sta	$0E,x
	lda	a:stage2_target_vram_addrs,y
	sta	$26,x
	lda	a:stage2_target_params,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	@loop
	rtl

; Spawns the stage 2 boss objects (10 slots from $0AC0).
spawn_stage2_boss:
	ldy	#$0000
	ldx	#$0AC0
@loop:
	stz	$12,x
	lda	a:stage2_boss_part_types,y
	sta	$10,x
	lda	a:stage2_boss_part_params,y
	sta	$14,x
	lda	a:stage2_boss_part_vram_addrs,y
	sta	$26,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$0014
	bcc	@loop
	rtl

; Spawns stage 5's five targets.
spawn_stage5_targets:
	lda	difficulty
	beq	@add_base
	lda	rng_lo
	and	#$0070
@add_base:
	clc
	adc	#.loword(stage5_target_type_sets)
	sta	zp_FA
	ldy	#$0000
	ldx	#$0AC0
@loop:
	lda	(zp_FA),y
	sta	$10,x
	stz	$12,x
	lda	a:stage5_target_x,y
	sta	$0A,x
	lda	a:stage5_target_y,y
	sta	$0E,x
	lda	a:stage5_target_vram_addrs,y
	sta	$26,x
	lda	a:stage5_target_params,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	@loop
	rtl

; Spawns the stage 5 boss object.
spawn_stage5_boss:
	ldy	#$0000
	ldx	#$0AC0
	stz	$12,x
	lda	a:stage5_boss_spawn_type,y
	sta	$10,x
	lda	a:stage5_boss_spawn_param,y
	sta	$14,x
	lda	a:stage5_boss_spawn_vram_addr,y
	sta	$26,x
	rtl
