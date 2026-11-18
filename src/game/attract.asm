; game/attract.asm -- Attract mode: demo, title, Konami logo
; Bank $00, $00:AD7C-$00:B678. Included by main.asm in segment BANK00.
;
; The attract demo (run_demo: recorded pad input played back through
; run_stage, demo_index chooses one of three stages), the title screen
; (load_title_screen, run_title_menu, the sprite words of the logo) and the
; Konami logo (run_konami_logo). Also three button codes that nothing
; calls (30 lives, stage select).

; Attract demo, steps in mode_step: demo_init, demo_play, demo_end.
run_demo:
	lda	a:mode_step
	asl	a
	tax
	jmp	(.loword(tbl_demo_steps),x)
tbl_demo_steps:
	.addr	demo_init
	.addr	demo_play
	.addr	demo_end

; Sets up the demo stage (demo_stages[demo_index], checkpoint from
; demo_stage_checkpoints), the players, the recorded input and the RNG
; (seeded with 0 so the recording replays exactly); demo_timer = $800.
demo_init:
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
	lda	a:demo_index
	asl	a
	tay
	lda	a:demo_stages,y
	sta	stage_number
	jsr	a:demo_init_players
	jsl	f:load_stage_music
	lda	stage_number
	dec	a
	sta	stage_index
	jsr	a:demo_init_input
	stz	rng_temp
	stz	rng_lo
	stz	rng_hi
	stz	frame_counter
	stz	stage_frame_counter
	lda	#$0002
	sta	demo_mode
	lda	#$0800
	sta	demo_timer
	inc	a:mode_step
	rtl

; Plays a frame: replaces the pads with the recording (demo_update_input)
; and runs run_stage. Ends on timeout, at the end of the stage or on Start
; (demo_result 1 / 2).
demo_play:
	dec	demo_timer
	beq	@timed_out
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	@start_pressed
	jsr	a:demo_update_input
	jsl	f:run_stage
	lda	a:demo_record_mode
	beq	@check_result
	; (not executed in the CDL traces)
	lda	a:demo_p1_ptr
	cmp	#$0400
	bcs	@timed_out
	lda	a:demo_p2_ptr
	cmp	#$0800
	bcs	@timed_out
@check_result:
	lda	mode_result
	bne	@timed_out
	rtl
@timed_out:
	stz	mode_result
	lda	#$0001
	sta	a:demo_result
	inc	a:mode_step
	rtl
@start_pressed:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:demo_result
	inc	a:mode_step
	rtl

; Fades out, advances demo_index (0-2), mode_result = demo_result.
demo_end:
	jsl	f:fade_out_step
	bcs	@return
	lda	a:demo_index
	inc	a
	cmp	#$0003
	bcc	@store_index
	lda	#$0000
@store_index:
	sta	a:demo_index
	stz	hdma_preset
	stz	nmi_mode
	lda	#$0002
	sta	force_blank_frames
	lda	a:demo_result
	sta	mode_result
@return:
	rtl

; demo_record_mode: record the pads to SRAM; otherwise replace joy1/joy2
; held/pressed with the recorded events (buttons, duration).
demo_update_input:
	lda	a:demo_record_mode
	beq	demo_playback_input
	; (not executed in the CDL traces)
	jsr	a:demo_record_p1
	jmp	a:demo_record_p2

demo_record_p1:
	; (not executed in the CDL traces)
	inc	a:demo_p1_timer
	lda	joy1_held
	cmp	a:demo_p1_input
	bne	@input_changed
	rts
@input_changed:
	ldy	#$0000
	lda	a:demo_p1_ptr
	sta	zp_00
	lda	a:demo_p1_ptr+1
	sta	zp_01
	lda	a:demo_p1_input
	sta	[zp_00],y
	iny
	iny
	lda	a:demo_p1_timer
	sta	[zp_00],y
	lda	joy1_held
	sta	a:demo_p1_input
	stz	a:demo_p1_timer
	lda	a:demo_p1_ptr
	clc
	adc	#$0004
	sta	a:demo_p1_ptr
	rts
demo_record_p2:
	inc	a:demo_p2_timer
	lda	joy2_held
	cmp	a:demo_p2_input
	bne	@input_changed
	rts
@input_changed:
	ldy	#$0000
	lda	a:demo_p2_ptr
	sta	zp_00
	lda	a:demo_p2_ptr+1
	sta	zp_01
	lda	a:demo_p2_input
	sta	[zp_00],y
	iny
	iny
	lda	a:demo_p2_timer
	sta	[zp_00],y
	lda	joy2_held
	sta	a:demo_p2_input
	stz	a:demo_p2_timer
	lda	a:demo_p2_ptr
	clc
	adc	#$0004
	sta	a:demo_p2_ptr
	rts
demo_playback_input:
	jsr	a:demo_playback_p1
	jmp	a:demo_playback_p2

demo_playback_p1:
	lda	a:demo_p1_timer
	bne	@count_down
	jsr	a:demo_read_p1_event
@count_down:
	dec	a:demo_p1_timer
	beq	demo_read_p1_event
	lda	a:demo_p1_input
	sta	joy1_held
	stz	joy1_pressed
	rts

demo_read_p1_event:
	ldy	#$0000
	lda	a:demo_p1_ptr
	sta	zp_00
	lda	a:demo_p1_ptr+1
	sta	zp_01
	lda	[zp_00],y
	sta	joy1_held
	eor	a:demo_p1_input
	and	[zp_00],y
	sta	joy1_pressed
	lda	[zp_00],y
	sta	a:demo_p1_input
	iny
	iny
	lda	[zp_00],y
	sta	a:demo_p1_timer
	lda	a:demo_p1_ptr
	clc
	adc	#$0004
	sta	a:demo_p1_ptr
	rts
demo_playback_p2:
	lda	a:demo_p2_timer
	bne	@count_down
	jsr	a:demo_read_p2_event
@count_down:
	dec	a:demo_p2_timer
	beq	demo_read_p2_event
	lda	a:demo_p2_input
	sta	joy2_held
	stz	joy2_pressed
	rts

demo_read_p2_event:
	ldy	#$0000
	lda	a:demo_p2_ptr
	sta	zp_00
	lda	a:demo_p2_ptr+1
	sta	zp_01
	lda	[zp_00],y
	sta	joy2_held
	eor	a:demo_p2_input
	and	[zp_00],y
	sta	joy2_pressed
	lda	[zp_00],y
	sta	a:demo_p2_input
	iny
	iny
	lda	[zp_00],y
	sta	a:demo_p2_timer
	lda	a:demo_p2_ptr
	clc
	adc	#$0004
	sta	a:demo_p2_ptr
	rts

demo_init_players:
	lda	stage_number
	asl	a
	tay
	lda	a:demo_stage_checkpoints,y
	sta	a:stage_checkpoint
	stz	a:p1_score
	stz	a:p1_score_hi
	stz	a:p2_score
	stz	a:p2_score_hi
	lda	#$0000
	sta	a:p1_next_extend
	sta	a:p2_next_extend
	lda	#$0002
	sta	a:p1_next_extend_hi
	sta	a:p2_next_extend_hi
	lda	#$0003
	sta	a:p1_lives
	lda	#$0001
	sta	a:p1_bombs
	stz	a:p2_bombs
	stz	a:p2_lives
	lda	a:title_menu_cursor
	beq	@one_player
	lda	#$0003
	sta	a:p2_lives
	lda	#$0001
	sta	a:p2_bombs
@one_player:
	lda	#$0002
	sta	difficulty
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:p1_weapon_slot_other
	stz	a:p2_weapon_slot_other
	stz	a:p1_weapon_1
	stz	a:p2_weapon_1
	stz	a:p1_weapon_2
	stz	a:p2_weapon_2
	stz	a:p1_weapon_select
	stz	a:p2_weapon_select
	stz	a:p1_barrier_timer
	stz	a:p2_barrier_timer
	stz	a:p1_spin
	stz	a:p2_spin
	stz	a:stage_state
	stz	a:topdown_state
	lda	#$0020
	sta	zp_94
	lda	#$0010
	sta	zp_96
	lda	#$4000
	sta	button_fire
	lda	#$8000	; [num]
	sta	button_jump
	lda	#$8000	; [num]
	sta	zp_92
	lda	#$0080
	sta	button_bomb
	lda	#$0010
	sta	button_stand_still
	rts

; Event pointers for demo_index (demo_p1_input_ptrs / demo_p2_input_ptrs, 3-byte
; pointers) or, when recording, $70:0000 / $70:0400.
demo_init_input:
	stz	a:demo_p1_timer
	stz	a:demo_p2_timer
	stz	a:demo_p1_input
	stz	a:demo_p2_input
	lda	a:demo_record_mode
	beq	@playback
	; (not executed in the CDL traces)
	lda	#$0000
	sta	a:demo_p1_ptr
	lda	#$0400
	sta	a:demo_p2_ptr
	sep	#$20
	.a8
	lda	#$70
	sta	a:demo_p1_ptr+2
	sta	a:demo_p2_ptr+2
	rep	#$20
	.a16
	bra	@return
@playback:
	lda	a:demo_index
	asl	a
	clc
	adc	a:demo_index
	tay
	lda	a:demo_p1_input_ptrs,y
	sta	a:demo_p1_ptr
	lda	a:demo_p1_input_ptrs+1,y
	sta	a:demo_p1_ptr+1
	lda	a:demo_p2_input_ptrs,y
	sta	a:demo_p2_ptr
	lda	a:demo_p2_input_ptrs+1,y
	sta	a:demo_p2_ptr+1
@return:
	rts

; One step of a fade out (also of the top-down views on stages 2 and 5).
; Carry set while fading; clear when done (display blanked).
fade_out_step:
	lda	stage_number
	cmp	#STAGE_2
	beq	@top_down
	cmp	#STAGE_5
	beq	@top_down
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	sec
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	clc
	rtl
@top_down:
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out2
	dec	a:inidisp_shadow
	lda	a:p1_view_brightness
	and	#$000F
	dec	a
	bpl	@store_p1
	; (not executed in the CDL traces)
	lda	#$0080
@store_p1:
	sta	a:p1_view_brightness
	lda	a:p2_view_brightness
	and	#$000F
	dec	a
	bpl	@store_p2
	; (not executed in the CDL traces)
	lda	#$0080
@store_p2:
	sta	a:p2_view_brightness
	sec
	rtl
@faded_out2:
	lda	#$0080
	sta	a:inidisp_shadow
	sta	a:p1_view_brightness
	sta	a:p2_view_brightness
	clc
	rtl

; Loads the title for the opening: Mode 7 logo scaled to 0.
opening_load_title_screen:
	jsl	f:reset_video_state
	jsr	a:load_title_graphics
	jsr	a:init_title_logo_zoomed_out
	jsr	a:draw_title_texts
	lda	#$000F
	sta	a:mode_work+$04
	lda	#$000F
	sta	a:inidisp_shadow
	rtl

init_title_logo_zoomed_out:
	lda	#$000F
	sta	a:bgmode_shadow
	lda	#$0000
	sta	a:m7a_shadow
	stz	a:m7b_shadow
	stz	a:m7c_shadow
	sta	a:m7d_shadow
	lda	#$0080
	sta	a:m7x_shadow
	lda	#$0040
	sta	a:m7y_shadow
	lda	#$0000
	sta	a:bg1_x
	lda	#$0000
	sta	a:bg1_y
	stz	a:m7sel_shadow
	rts

; Loads the title with the logo at full size (from the demo or the menu).
load_title_screen:
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsr	a:load_title_graphics
	jsr	a:init_title_logo
	jsr	a:draw_title_texts
	lda	#$000F
	sta	a:mode_work+$04
	stz	a:inidisp_shadow
	rtl

load_title_graphics:
	ldy	#.loword(palette_task_058558)
	ldx	#$1210
	jsl	f:start_palette_task_at
	ldy	#.loword(palette_task_05854B)
	jsl	f:start_palette_task
	ldx	#.loword(load_list_058527)
	jsl	f:load_data_list
	ldx	#.loword(load_list_058530)
	jsl	f:load_data_list
	ldx	#.loword(load_list_058539)
	jsl	f:load_data_list
	ldx	#.loword(load_list_058542)
	jsl	f:load_data_list
	rts

init_title_logo:
	lda	#$000F
	sta	a:bgmode_shadow
	lda	#$0100
	sta	a:m7a_shadow
	stz	a:m7b_shadow
	stz	a:m7c_shadow
	sta	a:m7d_shadow
	lda	#$0080
	sta	a:m7x_shadow
	sta	a:m7y_shadow
	lda	#$0000
	sta	a:bg1_x
	lda	#$0000
	sta	a:bg1_y
	stz	a:m7sel_shadow
	rts

draw_title_texts:
	ldx	#.loword(text_tm_and_1992_konami_co_ltd)
	jsl	f:draw_text
	ldx	#.loword(text_1_player)
	jsl	f:draw_text
	ldx	#.loword(text_2_players_a)
	jsl	f:draw_text
	ldx	#.loword(text_2_players_b)
	jsl	f:draw_text
	ldx	#.loword(text_option)
	jsl	f:draw_text
	jsl	f:draw_title_menu_cursor
	rts

; (no caller found; decoded because it follows the end of a routine)
; Never called: setup_hdma_from_list with the list at $05:84FE.
setup_hdma_list_unused:
	; (not executed in the CDL traces)
	ldy	#.loword(hdma_list_0584FE)
	jsl	f:setup_hdma_from_list
	rts

; Y = list of (register address, 4 bytes) entries ended by $FFFF and the
; HDMAEN value; writes them to the DMA registers.
setup_hdma_from_list:
	ldx	a:$0000,y
	cpx	#$FFFF	; [num]
	bcs	@end_of_list
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	tya
	clc
	adc	#$0007
	tay
	bra	setup_hdma_from_list
@end_of_list:
	sep	#$20
	.a8
	lda	a:$0002,y
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl

; Title menu, steps in mode_step: init, fade in, input, fade out (unused).
run_title_menu:
	rep	#$20
	rep	#$10
	lda	a:mode_step
	phx
	asl	a
	tax
	lda	f:tbl_title_menu_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_title_menu_steps:
	.addr	title_menu_init
	.addr	title_menu_fade_in
	.addr	title_menu_input
	.addr	title_menu_fade_out

title_menu_init:
	lda	#$0300
	sta	a:title_menu_timeout
	stz	a:code1_progress
	stz	a:code1_timer
	stz	a:code2_progress
	stz	a:code2_timer
	stz	a:code3_progress
	stz	a:code3_timer
	stz	a:stage_select_enabled
	inc	a:mode_step
	rtl

title_menu_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:inidisp_shadow
@check_level:
	cmp	#$000F
	bcs	@faded_in
	inc	a:inidisp_shadow
	plp
	rtl
@faded_in:
	plp
	jsr	a:load_demo_stage_graphics
	inc	a:mode_step
	rtl

; mode_result = 1 when title_menu_timeout runs out (demo), 2 on Start.
title_menu_input:
.if CHEAT_SOUND_CHECK
	jsr	a:check_button_code_unused	; Right, Down, Down+Right, X: carry set
	bcs	title_menu_unused_sound_check	; fade out, mode_result 3: the sound check
.endif
.if CHEAT_BUTTON_CODES
	jsr	a:check_30_lives_code
	jsr	a:check_stage_select_code
.endif
	jsl	f:title_menu_update_cursor
	bcs	@start_pressed
	dec	a:title_menu_timeout
	bne	@return
	lda	#$0001
	sta	mode_result
	rtl
@start_pressed:
	lda	#$0002
	sta	mode_result
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; Fades the title out with mode_result 3, which game_mode_title turns into
; GAME_MODE_SOUND_CHECK. Probably the target of check_button_code_unused's
; carry (the sound_check cheat branches here from title_menu_input).
title_menu_unused_sound_check:
	; (not executed in the CDL traces)
	lda	#$0003
	sta	a:mode_step

title_menu_fade_out:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0003
	sta	mode_result
	rtl

; Up/Down/Select move title_menu_cursor (0-3, TITLE_*) and redraw it;
; carry set (and sound) on Start.
title_menu_update_cursor:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	title_menu_start_pressed
	bit	#JOY_SELECT|JOY_UP|JOY_DOWN
	beq	draw_title_menu_cursor
	lda	#$0300
	sta	a:title_menu_timeout
	lda	#SOUND_CURSOR
	jsl	f:queue_sound
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_SELECT|JOY_DOWN
	bne	@move_down
	dec	a:title_menu_cursor
	bpl	draw_title_menu_cursor
	lda	#TITLE_OPTION
	sta	a:title_menu_cursor
	bra	draw_title_menu_cursor
@move_down:
	inc	a:title_menu_cursor
	lda	a:title_menu_cursor
	cmp	#TITLE_OPTION+1
	bcc	draw_title_menu_cursor
	stz	a:title_menu_cursor

draw_title_menu_cursor:
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:title_menu_attrs_1p,y
	ldx	#.loword(text_1_player)
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:title_menu_attrs_2p_a,y
	ldx	#.loword(text_2_players_a)
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:title_menu_attrs_2p_b,y
	ldx	#.loword(text_2_players_b)
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:title_menu_attrs_option,y
	ldx	#.loword(text_option)
	jsl	f:draw_text_attr
	clc
	rtl
title_menu_start_pressed:
	lda	a:title_menu_cursor
	cmp	#TITLE_OPTION
	beq	@option_chosen
	lda	#$006D
	jsl	f:queue_sound
	sec
	rtl
@option_chosen:
	lda	#SOUND_SELECT
	jsl	f:queue_sound
	sec
	rtl

; Loads the graphics of the next demo's stage (ptrs_0585CB[demo_index])
; while the title is shown.
load_demo_stage_graphics:
	jsl	f:clear_bg_scroll_state
	jsl	f:clear_wram_7e4000_7effff
	lda	a:demo_index
	asl	a
	tay
	lda	a:ptrs_0585CB,y
	tax
	jsl	f:load_data_list
	rts

; check_button_code_unused, check_30_lives_code, check_stage_select_code: never executed in the CDL traces (found
; by the unreferenced-routine heuristic).  Each compares the d-pad bits of the
; joypads ($20/$22 & $0F00) with a 3-entry sequence and then checks a button:
; probably button-code checks.  DB is assumed to be $05, the game's usual data
; bank (hint): the sequences are then d-pad masks at $05:86D3/86D9/86DF.
; (no caller found; decoded because it follows the end of a routine)
; Button codes on the title: never called. Each compares the d-pad with a
; 3-entry sequence (data_0586D3/D9/DF) within a time limit, then a button.
; This one only plays a sound.
check_button_code_unused:
	; (not executed in the CDL traces)
	lda	a:code1_timer
	bne	@in_progress
	ldy	#$0000
	sty	a:code1_progress
	bra	@check_dpad
@in_progress:
	dec	a:code1_timer
	ldy	a:code1_progress
	cpy	#$0006
	bcs	@check_button
@check_dpad:
	lda	joy1_held
	ora	joy2_held
	and	#JOY_DPAD
	cmp	a:code_unused_dpad_sequence,y
	bne	@not_entered
	cpy	#$0000
	bne	@next_entry
	lda	#$0010
	sta	a:code1_timer
@next_entry:
	iny
	iny
	sty	a:code1_progress
	cpy	#$0006
	bcc	@not_entered
	lda	#$000C
	sta	a:code1_timer
@check_button:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_X
	bne	@entered
@not_entered:
	clc
	rts
@entered:
	lda	#SOUND_EXTRA_LIFE
	jsl	f:queue_sound
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
; Sets option_lives to 30 (never called).
check_30_lives_code:
	; (not executed in the CDL traces)
	lda	a:code2_timer
	bne	@in_progress
	ldy	#$0000
	sty	a:code2_progress
	bra	@check_dpad
@in_progress:
	dec	a:code2_timer
	ldy	a:code2_progress
	cpy	#$0006
	bcs	@check_button
@check_dpad:
	lda	joy1_held
	ora	joy2_held
	and	#JOY_DPAD
	cmp	a:code_30_lives_dpad_sequence,y
	bne	@not_entered
	cpy	#$0000
	bne	@next_entry
	lda	#$0010
	sta	a:code2_timer
@next_entry:
	iny
	iny
	sty	a:code2_progress
	cpy	#$0006
	bcc	@not_entered
	lda	#$000C
	sta	a:code2_timer
@check_button:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	@entered
@not_entered:
	clc
	rts
@entered:
	lda	#SOUND_PLAYER_FALL
	jsl	f:queue_sound
	lda	#$001E
	sta	a:option_lives
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
; Sets stage_select_enabled (never called).
check_stage_select_code:
	; (not executed in the CDL traces)
	lda	a:code3_timer
	bne	@in_progress
	ldy	#$0000
	sty	a:code3_progress
	bra	@check_dpad
@in_progress:
	dec	a:code3_timer
	ldy	a:code3_progress
	cpy	#$0006
	bcs	@check_button
@check_dpad:
	lda	joy1_held
	ora	joy2_held
	and	#JOY_DPAD
	cmp	a:code_stage_select_dpad_sequence,y
	bne	@not_entered
	cpy	#$0000
	bne	@next_entry
	lda	#$0010
	sta	a:code3_timer
@next_entry:
	iny
	iny
	sty	a:code3_progress
	cpy	#$0006
	bcc	@not_entered
	lda	#$000C
	sta	a:code3_timer
@check_button:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	@entered
@not_entered:
	clc
	rts
@entered:
	lda	a:title_menu_cursor
	cmp	#TITLE_OPTION
	beq	@not_entered
	lda	#$0059
	jsl	f:queue_sound
	lda	#$0001
	sta	a:stage_select_enabled
	sec
	rts

; Builds the OAM entries of the words THE, ALIEN, WARS and the TM mark
; at their X positions (title_*_x), Y offset by the title shake.
draw_title_word_sprites:
	ldx	#$0FC0
	lda	#$11C0
	sta	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	lda	a:title_the_x
	sta	zp_FC
	lda	#$0044
	sta	zp_FE
	lda	#.loword(title_sprites_058705)
	sta	zp_18
	lda	#.loword(title_sprites_0586E5)
	sta	zp_1A
	lda	#.loword(title_sprites_0586F5)
	sta	zp_1C
	ldy	#$000E
	jsr	a:draw_title_sprite_group
	lda	a:title_alien_x
	sta	zp_FC
	lda	#$004C
	sta	zp_FE
	lda	#.loword(title_sprites_058745)
	sta	zp_18
	lda	#.loword(title_sprites_058715)
	sta	zp_1A
	lda	#.loword(title_sprites_05872D)
	sta	zp_1C
	ldy	#$0016
	jsr	a:draw_title_sprite_group
	lda	a:title_wars_x
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#.loword(title_sprites_05877D)
	sta	zp_18
	lda	#.loword(title_sprites_05875D)
	sta	zp_1A
	lda	#.loword(title_sprites_05876D)
	sta	zp_1C
	ldy	#$000E
	jsr	a:draw_title_sprite_group
	lda	a:title_tm_x
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#.loword(title_sprites_058791)
	sta	zp_18
	lda	#.loword(title_sprites_05878D)
	sta	zp_1A
	lda	#.loword(title_sprites_05878F)
	sta	zp_1C
	ldy	#$0000
	jsr	a:draw_title_sprite_group
@loop:
	sec
	ror	zp_14
	sec
	ror	zp_14
	bcc	@loop
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	rtl

draw_title_sprite_group:
	lda	zp_FE
	sec
	sbc	a:bg1_y
	clc
	adc	(zp_1C),y
	sta	a:$0001,x
	lda	zp_FC
	clc
	adc	(zp_1A),y
	pha
	cmp	#$0100
	ror	zp_14
	sec
	ror	zp_14
	bcc	@no_flush
	phy
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	sty	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	ply
@no_flush:
	pla
	sep	#$20
	.a8
	sta	a:$0000,x
	rep	#$20
	.a16
	lda	(zp_18),y
	sta	a:$0002,x
	inx
	inx
	inx
	inx
	dey
	dey
	bpl	draw_title_sprite_group
	rts

; Konami logo, steps in konami_logo_step (tbl_konami_logo_steps): a line
; sweeps in, the logo scrolls in, shines (palette rows rotated), turns
; white and fades out; then konami_logo_done = 1.
run_konami_logo:
	rep	#$20
	rep	#$10
	lda	a:konami_logo_step
	phx
	asl	a
	tax
	lda	f:tbl_konami_logo_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_konami_logo_steps:
	.addr	konami_logo_init
	.addr	konami_logo_sweep
	.addr	konami_logo_cycle_line
	.addr	konami_logo_scroll_in
	.addr	konami_logo_wait
	.addr	konami_logo_start_shine
	.addr	konami_logo_shine
	.addr	konami_logo_wait
	.addr	konami_logo_whiten
	.addr	konami_logo_wait
	.addr	konami_logo_fade_out

konami_logo_init:
	jsl	f:wait_nmi_and_disable_display
	jsl	f:disable_display_and_nmi
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_mode_work
	lda	#$0009
	sta	a:bgmode_shadow
	lda	#$0001
	ldx	#.loword(load_list_0587AB)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_0587C3)
	jsl	f:start_palette_task
	lda	#$0400
	sta	a:bg1_y
	lda	#$0100
	sta	a:bg1_x
	sta	a:bg2_x
	lda	#$0019
	sta	a:bgmode_shadow
	lda	#$0003
	sta	a:konami_logo_count2
	inc	a:konami_logo_step
	rtl

konami_logo_sweep:
	lda	frame_counter
	and	#$0001
	bne	@scroll
	lda	a:konami_logo_count1
	asl	a
	tay
	ldx	a:ptrs_konami_logo_sweep_texts,y
	lda	#$2C00
	jsl	f:draw_text_attr
	inc	a:konami_logo_count1
	lda	a:konami_logo_count1
	and	#$0003
	sta	a:konami_logo_count1
@scroll:
	lda	a:bg1_x
	sec
	sbc	#$0008
	sta	a:bg1_x
	bne	@return
	stz	a:bg2_x
	inc	a:konami_logo_step
@return:
	rtl

konami_logo_cycle_line:
	lda	frame_counter
	and	#$0003
	bne	@return
	ldx	#$2264
	jsr	a:rotate_palette_row
	dec	a:konami_logo_count2
	bne	@return
	inc	a:konami_logo_step
@return:
	rtl

konami_logo_scroll_in:
	lda	a:bg1_y
	sec
	sbc	#$0002
	sta	a:bg1_y
	and	#$0100
	bne	konami_logo_step_return
konami_logo_next_step:
	lda	#$0001
	sta	a:konami_logo_timer
	inc	a:konami_logo_step
	rtl

konami_logo_start_shine:
	lda	#$000A
	sta	a:konami_logo_count1
	sta	a:konami_logo_count2
	sta	a:konami_logo_count3
	ldy	#.loword(palette_task_0587E1)
	jsl	f:start_palette_task
	lda	#SOUND_SONG_KONAMI_LOGO
	jsl	f:queue_sound
	inc	a:konami_logo_step
konami_logo_step_return:
	rtl

konami_logo_shine:
	lda	a:konami_logo_count1
	beq	@check_count2
	cmp	#$000A
	bne	@rotate_row1
	ldy	#.loword(palette_task_0587EA)
	jsl	f:start_palette_task
@rotate_row1:
	dec	a:konami_logo_count1
	ldx	#$222C
	jsr	a:rotate_palette_row
@check_count2:
	lda	a:konami_logo_count2
	bmi	@check_timer
	ldx	#$224C
	jsr	a:rotate_palette_row
	dec	a:konami_logo_count2
	lda	#$0003
	sta	a:konami_logo_timer
	rtl
@check_timer:
	lda	a:konami_logo_timer
	beq	@check_count3
	dec	a:konami_logo_timer
	bne	@return
	ldy	#.loword(palette_task_0587D8)
	jmp	a:start_palette_task
@check_count3:
	lda	a:konami_logo_count3
	bmi	konami_logo_next_step
	lda	frame_counter
	and	#$0001
	bne	@return
	dec	a:konami_logo_count3
	ldx	#$220A
	jsr	a:rotate_palette_row
@return:
	rtl

konami_logo_whiten:
	ldx	#$2200
	lda	f:$7E0000,x
	clc
	adc	#$0421
	sta	f:$7E0000,x
	sta	f:$7E0002,x
	cmp	#$7FFF
	bne	@return
	lda	#$0100
	sta	a:konami_logo_timer
	inc	a:konami_logo_step
@return:
	rtl

konami_logo_wait:
	dec	a:konami_logo_timer
	bne	@return
	inc	a:konami_logo_step
@return:
	rtl

konami_logo_fade_out:
	dec	a:inidisp_shadow
	bne	@return
	inc	a:konami_logo_done
@return:
	rtl

; Rotates the 16 colours at $7E:0000+X (the CGRAM buffer) by one entry.
rotate_palette_row:
	lda	f:$7E0000,x
	pha
	inx
	inx
@loop:
	lda	f:$7E0000,x
	sta	f:$7DFFFE,x
	inx
	inx
	txa
	and	#$001F
	bne	@loop
	pla
	sta	f:$7DFFFE,x
	rts
