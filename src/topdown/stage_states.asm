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
	beq	loc_028025
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
loc_028025:
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
	beq	loc_028064
	; (not executed in the CDL traces)
	ldy	#$0004
loc_028064:
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
	bcc	loc_028096
	jsl	f:init_topdown_views
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_state
loc_028096:
	rtl

; State 3: play. Map view (Select), players, objects, views; when every
; target is destroyed, fades out to the boss (check_targets_destroyed).
stage2_state_play:
	jsr	a:update_map_view
	bcc	loc_02809D
	; (not executed in the CDL traces)
	rtl
loc_02809D:
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
	bcs	loc_0280D8
	jsr	a:check_targets_destroyed
loc_0280D8:
	rtl

; Carry set when neither player has lives left: fades out and
; leaves the stage (topdown_state = 0, nmi_mode = 0, next game sub-mode).
check_topdown_game_over:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_028103
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	beq	loc_0280F7
	cmp	#$000F
	bne	loc_028101
	stz	a:fade_target_brightness
	lda	#$0081
	jsl	f:queue_sound
	bra	loc_028101
loc_0280F7:
	stz	a:topdown_state
	stz	a:topdown_boss_end_step
	inc	mode_result
	stz	nmi_mode
loc_028101:
	sec
	rts
loc_028103:
	clc
	rts

; Once targets_left_flag is negative: waits $80 frames (sound $81
; at the start), fades out, then moves to the next state (boss setup).
check_targets_destroyed:
	lda	a:targets_left_flag
	bpl	loc_02813C
	lda	a:topdown_timer
	cmp	#$0080
	bne	loc_028119
	lda	#$0081
	jsl	f:queue_sound
loc_028119:
	dec	a:topdown_timer
	bpl	loc_02813C
	lda	a:inidisp_shadow
	beq	loc_028134
	cmp	#$000F
	bne	loc_02813C
	stz	a:fade_target_brightness
	lda	#$0081
	jsl	f:queue_sound
	bra	loc_02813C
loc_028134:
	lda	#$0001
	sta	pause_disabled
	inc	a:topdown_state
loc_02813C:
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
	bcs	loc_028199
	jsl	f:update_topdown_players
	jsl	f:td_update_bombs
	jsl	f:update_map_objects
	jsl	f:update_td_items
	jsl	f:update_topdown_shots
	jsl	f:update_screen_shake
	jsl	f:animate_topdown_palettes
	jsl	f:update_topdown_views
	jsl	f:td_run_collisions
loc_028199:
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	loc_0281A4
	jsr	a:update_stage2_boss_end
loc_0281A4:
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
	bne	loc_0281E8
	lda	#$0081
	jsl	f:queue_sound
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_boss_end_step
	rts

; Counts topdown_timer down, then resets the sound queue and fades out.
stage2_boss_defeat_delay:
	dec	a:topdown_timer
	bpl	loc_0281E8
	jsl	f:reset_sound_queue
	lda	#$0001
	sta	pause_disabled
	stz	a:fade_target_brightness
	inc	a:topdown_boss_end_step
loc_0281E8:
	rts

; When the screen is black, leaves the stage (next game sub-mode, NMI mode 0).
stage2_boss_exit:
	jsr	a:update_topdown_fade
	lda	a:inidisp_shadow
	bne	loc_0281E8
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
	bcc	loc_02822E
	jsl	f:init_topdown_views
	lda	#$0080
	sta	a:topdown_timer
	inc	a:topdown_state
loc_02822E:
	rtl

; State 3 of stage 5 (see stage2_state_play).
stage5_state_play:
	jsr	a:update_map_view
	bcc	loc_028235
	; (not executed in the CDL traces)
	rtl
loc_028235:
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
	bcs	loc_028270
	jsr	a:check_targets_destroyed
loc_028270:
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
	bcs	loc_0282D1
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
loc_0282D1:
	jsr	a:update_topdown_fade
	jsr	a:check_topdown_game_over
	bcs	loc_0282DC
	jsr	a:update_stage5_boss_end
loc_0282DC:
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
	bne	loc_028320
	lda	#$0081
	jsl	f:queue_sound
	lda	#$0040
	sta	a:topdown_timer
	inc	a:topdown_boss_end_step
	rts

; Counts topdown_timer down, then resets the sound queue and fades out.
stage5_boss_defeat_delay:
	dec	a:topdown_timer
	bpl	loc_028320
	jsl	f:reset_sound_queue
	lda	#$0001
	sta	pause_disabled
	stz	a:fade_target_brightness
	inc	a:topdown_boss_end_step
loc_028320:
	rts

; When the screen is black, leaves the stage.
stage5_boss_exit:
	jsr	a:update_topdown_fade
	lda	a:inidisp_shadow
	bne	loc_028320
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
	bne	loc_02838D
	lda	#$0000
	ldy	a:p1_lives
	beq	loc_028362
	ora	joy1_pressed
loc_028362:
	ldy	a:p2_lives
	beq	loc_028369
	ora	joy2_pressed
loc_028369:
	bit	#$2000
	beq	loc_02838D
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	sta	a:wram_15D2
	lda	a:p1_view_brightness
	sta	a:wram_15D4
	lda	a:p2_view_brightness
	sta	a:wram_15D6
	lda	#$0001
	sta	pause_disabled
	lda	#$0001
	sta	a:map_view_step
	sec
	rts
loc_02838D:
	clc
	rts

; Step 1: fades every view to black.
map_view_fade_out:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	ora	a:p1_view_brightness
	ora	a:p2_view_brightness
	beq	loc_0283B4
	dec	a:inidisp_shadow
	bpl	loc_0283A2
	stz	a:inidisp_shadow
loc_0283A2:
	dec	a:p1_view_brightness
	bpl	loc_0283AA
	stz	a:p1_view_brightness
loc_0283AA:
	dec	a:p2_view_brightness
	bpl	loc_0283B2
	stz	a:p2_view_brightness
loc_0283B2:
	sec
	rts
loc_0283B4:
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
	lda	#$FFE6
	sta	a:p1_m7_hofs
	lda	#$0000
	sta	a:p1_m7_center_y
	lda	#$FFF6
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
	bcs	loc_02843A
	inc	a:inidisp_shadow
	inc	a:p1_view_brightness
	inc	a:p2_view_brightness
	sec
	rts
loc_02843A:
	inc	a:map_view_step
	sec
	rts

; Step 4: waits for Select.
map_view_wait_select:
	; (not executed in the CDL traces)
	lda	#$0000
	ldy	a:p1_lives
	beq	loc_028449
	ora	joy1_pressed
loc_028449:
	ldy	a:p2_lives
	beq	loc_028450
	ora	joy2_pressed
loc_028450:
	bit	#$2000
	beq	loc_028458
	inc	a:map_view_step
loc_028458:
	sec
	rts

; Step 5: fades out, then forced blank.
map_view_fade_out_2:
	; (not executed in the CDL traces)
	lda	a:inidisp_shadow
	beq	loc_02846A
	dec	a:inidisp_shadow
	dec	a:p1_view_brightness
	dec	a:p2_view_brightness
	sec
	rts
loc_02846A:
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
	sta	f:wram_0FC0
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
	cmp	a:wram_15D2
	bcs	loc_0284E7
	inc	a:inidisp_shadow
	lda	a:p1_view_brightness
	cmp	a:wram_15D4
	bcs	loc_0284DA
	inc	a:p1_view_brightness
loc_0284DA:
	lda	a:p2_view_brightness
	cmp	a:wram_15D6
	bcs	loc_0284E5
	inc	a:p2_view_brightness
loc_0284E5:
	sec
	rts
loc_0284E7:
	lda	a:wram_15D2
	sta	a:inidisp_shadow
	lda	a:wram_15D4
	sta	a:p1_view_brightness
	lda	a:wram_15D6
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
	ldy	#$CD59
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
	bcs	loc_0285AC
	inc	a:inidisp_shadow
	inc	a:p1_view_brightness
	inc	a:p2_view_brightness
	clc
	rts
loc_0285AC:
	inc	a:intro_step
	clc
	rts

; Step 2: moves the cursors until every player has chosen a start point.
intro_choose_start:
	jsr	a:init_intro_views
	jsr	a:move_start_cursors
	jsr	a:check_start_points_chosen
	bcc	loc_0285C7
	lda	#$0040
	sta	a:topdown_timer
	stz	pause_disabled
	inc	a:intro_step
loc_0285C7:
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
	bmi	loc_0285E8
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
loc_0285E8:
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
	beq	loc_02861B
	dec	a
	bne	loc_02861B
	lda	#$0002
	sta	m7_split_screen
loc_02861B:
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
	bpl	loc_028646
	lda	a:topdown_map
	lsr	a
	and	#$0002
	tay
	lda	a:topdown_stage_songs,y
	jsl	f:queue_sound
	inc	a:intro_step
loc_028646:
	clc
	rts

; Step 5: zooms in and spins the views until the scale is back to $0100.
intro_zoom_in:
	jsr	a:zoom_in_views
	jsr	a:set_intro_scroll
	lda	a:p1_m7_scale_x
	cmp	#M7_SCALE_1X
	bne	loc_028659
	inc	a:intro_step
loc_028659:
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
	beq	loc_028698
	dec	a
	beq	loc_028688
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
loc_028688:
	lda	rng_hi
	and	#$0003
	sta	a:p2_start_x
	lda	zp_EB
	and	#$0003
	sta	a:p2_start_y
loc_028698:
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
	bne	loc_0286B1
	brl	loc_028742
loc_0286B1:
	dec	a
	bne	loc_0286B7
	brl	loc_02873F
loc_0286B7:
	; (not executed in the CDL traces)
	lda	a:p1_start_chosen
	and	a:p2_start_chosen
	bne	loc_0286CD
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$5000
	bne	loc_0286E8
	bit	#$0F00
	bne	loc_0286CE
loc_0286CD:
	rts
loc_0286CE:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_0286F9
	bit	#$0400
	bne	loc_028709
	bit	#$0100
	bne	loc_02872C
	bra	loc_02871C
loc_0286E8:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p1_start_chosen
	sta	a:p2_start_chosen
	rts
loc_0286F9:
	lda	a:p1_start_y
	dec	a
	bpl	loc_028702
	lda	#$0003
loc_028702:
	sta	a:p1_start_y
	sta	a:p2_start_y
	rts
loc_028709:
	lda	a:p1_start_y
	inc	a
	cmp	#$0004
	bcc	loc_028715
	lda	#$0000
loc_028715:
	sta	a:p1_start_y
	sta	a:p2_start_y
	rts
loc_02871C:
	lda	a:p1_start_x
	dec	a
	bpl	loc_028725
	lda	#$0003
loc_028725:
	sta	a:p1_start_x
	sta	a:p2_start_x
	rts
loc_02872C:
	lda	a:p1_start_x
	inc	a
	cmp	#$0004
	bcc	loc_028738
	lda	#$0000
loc_028738:
	sta	a:p1_start_x
	sta	a:p2_start_x
	rts
loc_02873F:
	jsr	a:move_p2_start_cursor
loc_028742:
	lda	a:p1_lives
	beq	loc_028758
	lda	a:p1_start_chosen
	bne	loc_028758
	lda	joy1_pressed
	bit	#$5000
	bne	loc_028773
	bit	#$0F00
	bne	loc_028759
loc_028758:
	rts
loc_028759:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_02878C
	bit	#$0400
	bne	loc_028799
	bit	#$0100
	bne	loc_0287B6
	bra	loc_0287A9
loc_028773:
	lda	a:p2_lives
	bne	loc_02877E
	lda	#$0002
	sta	a:p2_start_chosen
loc_02877E:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p1_start_chosen
	rts
loc_02878C:
	lda	a:p1_start_y
	dec	a
	bpl	loc_028795
	lda	#$0003
loc_028795:
	sta	a:p1_start_y
	rts
loc_028799:
	lda	a:p1_start_y
	inc	a
	cmp	#$0004
	bcc	loc_0287A5
	; (not executed in the CDL traces)
	lda	#$0000
loc_0287A5:
	sta	a:p1_start_y
	rts
loc_0287A9:
	lda	a:p1_start_x
	dec	a
	bpl	loc_0287B2
	; (not executed in the CDL traces)
	lda	#$0003
loc_0287B2:
	sta	a:p1_start_x
	rts
loc_0287B6:
	lda	a:p1_start_x
	inc	a
	cmp	#$0004
	bcc	loc_0287C2
	lda	#$0000
loc_0287C2:
	sta	a:p1_start_x
	rts

; Joypad 2 moves player 2's start cursor.
move_p2_start_cursor:
	lda	a:p2_lives
	beq	loc_0287DC
	lda	a:p2_start_chosen
	bne	loc_0287DC
	lda	joy2_pressed
	bit	#$5000
	bne	loc_0287F7
	bit	#$0F00
	bne	loc_0287DD
loc_0287DC:
	rts
loc_0287DD:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_028810
	; (not executed in the CDL traces)
	bit	#$0400
	bne	loc_02881D
	bit	#$0100
	bne	loc_02883A
	bra	loc_02882D
loc_0287F7:
	lda	a:p1_lives
	bne	loc_028802
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:p1_start_chosen
loc_028802:
	lda	#$0002
	jsl	f:queue_sound
	lda	#$0002
	sta	a:p2_start_chosen
	rts
loc_028810:
	lda	a:p2_start_y
	dec	a
	bpl	loc_028819
	; (not executed in the CDL traces)
	lda	#$0003
loc_028819:
	sta	a:p2_start_y
	rts
loc_02881D:
	; (not executed in the CDL traces)
	lda	a:p2_start_y
	inc	a
	cmp	#$0004
	bcc	loc_028829
	lda	#$0000
loc_028829:
	sta	a:p2_start_y
	rts
loc_02882D:
	lda	a:p2_start_x
	dec	a
	bpl	loc_028836
	lda	#$0003
loc_028836:
	sta	a:p2_start_x
	rts
loc_02883A:
	lda	a:p2_start_x
	inc	a
	cmp	#$0004
	bcc	loc_028846
	lda	#$0000
loc_028846:
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
	beq	loc_0288CD
	dec	a
	beq	loc_0288FF
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
loc_0288CD:
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
loc_0288FF:
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
	beq	loc_028973
	clc
	adc	#$0010
loc_028973:
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
	beq	loc_02898A
	clc
	adc	#$0010
loc_02898A:
	asl	a
	tay
	rts

; Scale -4 per frame (and angle +2 until 1:1), centres towards the start points.
zoom_in_views:
	lda	a:title_menu_cursor
	beq	loc_0289BA
	dec	a
	bne	loc_0289BA
	lda	a:p2_m7_scale_x
	sec
	sbc	#$0004
	sta	a:p2_m7_scale_x
	lda	a:p2_m7_scale_y
	sec
	sbc	#$0004
	sta	a:p2_m7_scale_y
	cmp	#M7_SCALE_1X
	bcc	loc_0289B4
	dec	a:p2_m7_angle
	dec	a:p2_m7_angle
loc_0289B4:
	jsr	a:approach_p2_start_x
	jsr	a:approach_p2_start_y
loc_0289BA:
	lda	a:p1_m7_scale_x
	sec
	sbc	#$0004
	sta	a:p1_m7_scale_x
	lda	a:p1_m7_scale_y
	sec
	sbc	#$0004
	sta	a:p1_m7_scale_y
	cmp	#M7_SCALE_1X
	bcc	loc_0289D9
	inc	a:p1_m7_angle
	inc	a:p1_m7_angle
loc_0289D9:
	jsr	a:approach_p1_start_x
	jsr	a:approach_p1_start_y
	rts

; Moves p1_m7_center_x 2 pixels towards p1_start_x.
approach_p1_start_x:
	lda	a:p1_m7_center_x
	cmp	a:p1_start_x
	beq	loc_0289F9
	bpl	loc_0289F2
	clc
	adc	#$0002
	sta	a:p1_m7_center_x
	rts
loc_0289F2:
	sec
	sbc	#$0002
	sta	a:p1_m7_center_x
loc_0289F9:
	rts

; Moves p1_m7_center_y 2 pixels towards p1_start_y.
approach_p1_start_y:
	lda	a:p1_m7_center_y
	cmp	a:p1_start_y
	beq	loc_028A13
	bpl	loc_028A0C
	clc
	adc	#$0002
	sta	a:p1_m7_center_y
	rts
loc_028A0C:
	sec
	sbc	#$0002
	sta	a:p1_m7_center_y
loc_028A13:
	rts

; Moves p2_m7_center_x 2 pixels towards p2_start_x.
approach_p2_start_x:
	lda	a:p2_m7_center_x
	cmp	a:p2_start_x
	beq	loc_028A2D
	bpl	loc_028A26
	; (not executed in the CDL traces)
	clc
	adc	#$0002
	sta	a:p2_m7_center_x
	rts
loc_028A26:
	sec
	sbc	#$0002
	sta	a:p2_m7_center_x
loc_028A2D:
	rts

; Moves p2_m7_center_y 2 pixels towards p2_start_y.
approach_p2_start_y:
	lda	a:p2_m7_center_y
	cmp	a:p2_start_y
	beq	loc_028A47
	bpl	loc_028A40
	clc
	adc	#$0002
	sta	a:p2_m7_center_y
	rts
loc_028A40:
	sec
	sbc	#$0002
	sta	a:p2_m7_center_y
loc_028A47:
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

; Runs the loader lists data_05CF33 and data_05CF41.
load_topdown_common_assets:
	ldx	#.loword(data_05CF33)
	jsl	f:load_data_list
	jsl	f:init_hud
	ldx	#.loword(data_05CF41)
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
	beq	loc_028AD2
	dec	a
	eor	#$0001
	asl	a
loc_028AD2:
	tay
	sep	#$20
	.a8
	stz	a:BG3HOFS
	stz	a:BG3HOFS
	lda	a:data_05CD6E,y
	sta	a:BG3VOFS
	lda	a:data_05CD6F,y
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
	sta	f:wram_1500
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
	sta	a:wram_1808
	sta	a:wram_180A
	sta	a:wram_180C
	sta	a:wram_180E
	sta	a:wram_1810
	sta	a:wram_1812
	sta	a:wram_1814
	sta	a:wram_1816
	sta	a:wram_1818
	sta	a:wram_181A
	sta	a:wram_181C
	sta	a:wram_181E
	sta	a:wram_1820
	sta	a:wram_1822
	sta	a:wram_1824
	sta	a:wram_1826
	rts

; Loads stage 2's graphics (loader list data_05CF2A) and palettes.
load_stage2_assets:
	ldx	#.loword(data_05CF2A)
	jsl	f:load_data_list
	ldy	#.loword(palette_05CFB2)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads stage 5's graphics and palettes.
load_stage5_assets:
	ldx	#.loword(data_05D01F)
	jsl	f:load_data_list
	ldy	#.loword(palette_05D056)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads the stage 2 boss graphics and palettes.
load_stage2_boss_assets:
	ldx	#.loword(song_set_05F46B)
	jsl	f:load_song_set
	ldx	#.loword(data_05CFCF)
	jsl	f:load_data_list
	ldx	#.loword(data_05CFD8)
	jsl	f:load_data_list
	ldy	#.loword(palette_05D006)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; Loads the stage 5 boss graphics and palettes.
load_stage5_boss_assets:
	ldx	#.loword(song_set_05F46B)
	jsl	f:load_song_set
	ldx	#.loword(data_05D073)
	jsl	f:load_data_list
	ldx	#.loword(data_05D07C)
	jsl	f:load_data_list
	ldy	#.loword(palette_05D0AA)
	jsl	f:start_palette_task
	jsl	f:build_m7_tilemap
	rts

; topdown_map = stage 2, clears the objects ($0200-$11DF), full brightness target.
init_stage2_vars:
	stz	a:topdown_map
	stz	a:boss_centered_view
	lda	#$0004
	sta	a:targets_left_flag
loc_028BF3:
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
	lda	#$8000
	sta	a:td_push_speed_frac
	stz	a:td_push_speed
	lda	#$0002
	sta	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	bra	loc_028BF3

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
	sta	f:wram_1500
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1780
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#TD_MAP_STAGE2_BOSS
	sta	a:topdown_map
	sta	a:boss_centered_view
loc_028C8D:
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
	sta	f:wram_1500
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1780
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#TD_MAP_STAGE5_BOSS
	sta	a:topdown_map
	stz	a:boss_centered_view
	brl	loc_028C8D

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
	beq	loc_028D77
	bcs	loc_028D5D
	lda	stage_frame_counter
	bit	#$0001
	bne	loc_028D77
	inc	a:inidisp_shadow
	lda	a:p1_view_brightness
	cmp	#$000F
	bcs	loc_028D51
	inc	a:p1_view_brightness
loc_028D51:
	lda	a:p2_view_brightness
	cmp	#$000F
	bcs	loc_028D5C
	inc	a:p2_view_brightness
loc_028D5C:
	rts
loc_028D5D:
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_028D77
	dec	a:inidisp_shadow
	lda	a:p1_view_brightness
	beq	loc_028D6F
	dec	a:p1_view_brightness
loc_028D6F:
	lda	a:p2_view_brightness
	beq	loc_028D77
	dec	a:p2_view_brightness
loc_028D77:
	rts

; Spawns stage 2's five targets in the slots from $0AC0 (types chosen by difficulty and random).
spawn_stage2_targets:
	lda	difficulty
	beq	loc_028D85
	tay
	lda	rng_lo
	and	#$0030
	ora	a:data_05CD72,y
loc_028D85:
	clc
	adc	#$CD78
	sta	zp_FA
	ldy	#$0000
	ldx	#$0AC0
loc_028D91:
	lda	(zp_FA),y
	sta	$10,x
	stz	$12,x
	lda	a:data_05CE08,y
	sta	$0A,x
	lda	a:data_05CE12,y
	sta	$0E,x
	lda	a:data_05CE1C,y
	sta	$26,x
	lda	a:data_05CE26,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	loc_028D91
	rtl

; Spawns the stage 2 boss objects (10 slots from $0AC0).
spawn_stage2_boss:
	ldy	#$0000
	ldx	#$0AC0
loc_028DBF:
	stz	$12,x
	lda	a:data_05CE30,y
	sta	$10,x
	lda	a:data_05CE44,y
	sta	$14,x
	lda	a:data_05CE58,y
	sta	$26,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$0014
	bcc	loc_028DBF
	rtl

; Spawns stage 5's five targets.
spawn_stage5_targets:
	lda	difficulty
	beq	loc_028DE7
	lda	rng_lo
	and	#$0070
loc_028DE7:
	clc
	adc	#$CE7C
	sta	zp_FA
	ldy	#$0000
	ldx	#$0AC0
loc_028DF3:
	lda	(zp_FA),y
	sta	$10,x
	stz	$12,x
	lda	a:data_05CF06,y
	sta	$0A,x
	lda	a:data_05CF10,y
	sta	$0E,x
	lda	a:data_05CF1A,y
	sta	$26,x
	lda	a:data_05CEFC,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	loc_028DF3
	rtl

; Spawns the stage 5 boss object.
spawn_stage5_boss:
	ldy	#$0000
	ldx	#$0AC0
	stz	$12,x
	lda	a:data_05CF24,y
	sta	$10,x
	lda	a:data_05CF26,y
	sta	$14,x
	lda	a:data_05CF28,y
	sta	$26,x
	rtl
