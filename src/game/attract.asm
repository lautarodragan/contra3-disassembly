; game/attract.asm -- Attract mode: intro, title, demo
; Bank $00, $00:AD7C-$00:B678. Included by main.asm in segment BANK00.
;
; Game modes 0, 3 and 4 and their helpers: the intro (run_konami_logo, sub-modes
; tbl_konami_logo_steps), the title screen helpers, and the attract demo (run_demo;
; demo index $1E48; sub_00AECD/sub_00AF11 read data from banks $15/$16,
; probably the recorded inputs). check_button_code_unused..sub_00B39F (never run in the
; traces) look like button-code checks.

run_demo:
	lda	a:mode_step
	asl	a
	tax
	jmp	(.loword(tbl_demo_steps),x)
tbl_demo_steps:
	.addr	demo_init
	.addr	demo_play
	.addr	demo_end

demo_init:
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
	stz	zp_E6
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

demo_play:
	dec	demo_timer
	beq	loc_00ADFF
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00AE0B
	jsr	a:demo_update_input
	jsl	f:run_stage
	lda	a:demo_record_mode
	beq	loc_00ADFA
	; (not executed in the CDL traces)
	lda	a:demo_p1_ptr
	cmp	#$0400
	bcs	loc_00ADFF
	lda	a:demo_p2_ptr
	cmp	#$0800
	bcs	loc_00ADFF
loc_00ADFA:
	lda	mode_result
	bne	loc_00ADFF
	rtl
loc_00ADFF:
	stz	mode_result
	lda	#$0001
	sta	a:demo_result
	inc	a:mode_step
	rtl
loc_00AE0B:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:demo_result
	inc	a:mode_step
	rtl

demo_end:
	jsl	f:fade_out_step
	bcs	loc_00AE38
	lda	a:demo_index
	inc	a
	cmp	#$0003
	bcc	loc_00AE27
	lda	#$0000
loc_00AE27:
	sta	a:demo_index
	stz	hdma_preset
	stz	nmi_mode
	lda	#$0002
	sta	force_blank_frames
	lda	a:demo_result
	sta	mode_result
loc_00AE38:
	rtl

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
	bne	loc_00AE4F
	rts
loc_00AE4F:
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
	bne	loc_00AE86
	rts
loc_00AE86:
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
	bne	loc_00AEC0
	jsr	a:demo_read_p1_event
loc_00AEC0:
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
	bne	loc_00AF04
	jsr	a:demo_read_p2_event
loc_00AF04:
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
	beq	loc_00AF8B
	lda	#$0003
	sta	a:p2_lives
	lda	#$0001
	sta	a:p2_bombs
loc_00AF8B:
	lda	#$0002
	sta	difficulty
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:wram_1F82
	stz	a:wram_1FC2
	stz	a:p1_weapon_1
	stz	a:p2_weapon_1
	stz	a:p1_weapon_2
	stz	a:p2_weapon_2
	stz	a:wram_1F9E
	stz	a:wram_1FDE
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
	lda	#$8000
	sta	button_jump
	lda	#$8000
	sta	zp_92
	lda	#$0080
	sta	button_bomb
	lda	#$0010
	sta	button_stand_still
	rts

demo_init_input:
	stz	a:demo_p1_timer
	stz	a:demo_p2_timer
	stz	a:demo_p1_input
	stz	a:demo_p2_input
	lda	a:demo_record_mode
	beq	loc_00B00F
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
	bra	loc_00B030
loc_00B00F:
	lda	a:demo_index
	asl	a
	clc
	adc	a:demo_index
	tay
	lda	a:data_0584EC,y
	sta	a:demo_p1_ptr
	lda	a:data_0584ED,y
	sta	a:demo_p1_ptr+1
	lda	a:data_0584F5,y
	sta	a:demo_p2_ptr
	lda	a:data_0584F6,y
	sta	a:demo_p2_ptr+1
loc_00B030:
	rts

fade_out_step:
	lda	stage_number
	cmp	#$0002
	beq	loc_00B055
	cmp	#$0005
	beq	loc_00B055
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B04D
	dec	a:inidisp_shadow
	sec
	rtl
loc_00B04D:
	lda	#$0080
	sta	a:inidisp_shadow
	clc
	rtl
loc_00B055:
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B083
	dec	a:inidisp_shadow
	lda	a:p1_view_brightness
	and	#$000F
	dec	a
	bpl	loc_00B06F
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B06F:
	sta	a:p1_view_brightness
	lda	a:p2_view_brightness
	and	#$000F
	dec	a
	bpl	loc_00B07E
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B07E:
	sta	a:p2_view_brightness
	sec
	rtl
loc_00B083:
	lda	#$0080
	sta	a:inidisp_shadow
	sta	a:p1_view_brightness
	sta	a:p2_view_brightness
	clc
	rtl

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
	sta	a:wram_1380
	lda	#$0000
	sta	a:wram_1398
	stz	a:m7sel_shadow
	rts

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
	ldy	#$8558
	ldx	#$1210
	jsl	f:sub_009985
	ldy	#$854B
	jsl	f:sub_009982
	ldx	#.loword(data_058527)
	jsl	f:load_data_list
	ldx	#.loword(data_058530)
	jsl	f:load_data_list
	ldx	#.loword(data_058539)
	jsl	f:load_data_list
	ldx	#.loword(data_058542)
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
	sta	a:wram_1380
	lda	#$0000
	sta	a:wram_1398
	stz	a:m7sel_shadow
	rts

draw_title_texts:
	ldx	#$8561
	jsl	f:draw_text
	ldx	#$8599
	jsl	f:draw_text
	ldx	#$85A6
	jsl	f:draw_text
	ldx	#$85B4
	jsl	f:draw_text
	ldx	#$85C2
	jsl	f:draw_text
	jsl	f:draw_title_menu_cursor
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B17B:
	; (not executed in the CDL traces)
	ldy	#$84FE
	jsl	f:setup_hdma_from_list
	rts

setup_hdma_from_list:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	loc_00B1A2
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
loc_00B1A2:
	sep	#$20
	.a8
	lda	a:$0002,y
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl

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
	beq	loc_00B1F7
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:inidisp_shadow
loc_00B1F7:
	cmp	#$000F
	bcs	loc_00B201
	inc	a:inidisp_shadow
	plp
	rtl
loc_00B201:
	plp
	jsr	a:load_demo_stage_graphics
	inc	a:mode_step
	rtl

title_menu_input:
	jsl	f:title_menu_update_cursor
	bcs	loc_00B21A
	dec	a:title_menu_timeout
	bne	loc_00B21F
	lda	#$0001
	sta	mode_result
	rtl
loc_00B21A:
	lda	#$0002
	sta	mode_result
loc_00B21F:
	rtl

; (no caller found; decoded because it follows the end of a routine)
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
	beq	loc_00B239
	dec	a:inidisp_shadow
	plp
	rtl
loc_00B239:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0003
	sta	mode_result
	rtl

title_menu_update_cursor:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B2C3
	bit	#$2C00
	beq	draw_title_menu_cursor
	lda	#$0300
	sta	a:title_menu_timeout
	lda	#$0001
	jsl	f:queue_sound
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$2400
	bne	loc_00B277
	dec	a:title_menu_cursor
	bpl	draw_title_menu_cursor
	lda	#$0003
	sta	a:title_menu_cursor
	bra	draw_title_menu_cursor
loc_00B277:
	inc	a:title_menu_cursor
	lda	a:title_menu_cursor
	cmp	#$0004
	bcc	draw_title_menu_cursor
	stz	a:title_menu_cursor

draw_title_menu_cursor:
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851F,y
	ldx	#$8599
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851D,y
	ldx	#$85A6
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851B,y
	ldx	#$85B4
	jsl	f:draw_text_attr
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_058519,y
	ldx	#$85C2
	jsl	f:draw_text_attr
	clc
	rtl
loc_00B2C3:
	lda	a:title_menu_cursor
	cmp	#$0003
	beq	loc_00B2D4
	lda	#$006D
	jsl	f:queue_sound
	sec
	rtl
loc_00B2D4:
	lda	#$0002
	jsl	f:queue_sound
	sec
	rtl

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
check_button_code_unused:
	; (not executed in the CDL traces)
	lda	a:code1_timer
	bne	loc_00B300
	ldy	#$0000
	sty	a:code1_progress
	bra	loc_00B30B
loc_00B300:
	dec	a:code1_timer
	ldy	a:code1_progress
	cpy	#$0006
	bcs	loc_00B332
loc_00B30B:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586D3,y
	bne	loc_00B33B
	cpy	#$0000
	bne	loc_00B322
	lda	#$0010
	sta	a:code1_timer
loc_00B322:
	iny
	iny
	sty	a:code1_progress
	cpy	#$0006
	bcc	loc_00B33B
	lda	#$000C
	sta	a:code1_timer
loc_00B332:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0040
	bne	loc_00B33D
loc_00B33B:
	clc
	rts
loc_00B33D:
	lda	#$003E
	jsl	f:queue_sound
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
check_30_lives_code:
	; (not executed in the CDL traces)
	lda	a:code2_timer
	bne	loc_00B353
	ldy	#$0000
	sty	a:code2_progress
	bra	loc_00B35E
loc_00B353:
	dec	a:code2_timer
	ldy	a:code2_progress
	cpy	#$0006
	bcs	loc_00B385
loc_00B35E:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586D9,y
	bne	loc_00B38E
	cpy	#$0000
	bne	loc_00B375
	lda	#$0010
	sta	a:code2_timer
loc_00B375:
	iny
	iny
	sty	a:code2_progress
	cpy	#$0006
	bcc	loc_00B38E
	lda	#$000C
	sta	a:code2_timer
loc_00B385:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B390
loc_00B38E:
	clc
	rts
loc_00B390:
	lda	#$0043
	jsl	f:queue_sound
	lda	#$001E
	sta	a:option_lives
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
check_stage_select_code:
	; (not executed in the CDL traces)
	lda	a:code3_timer
	bne	loc_00B3AC
	ldy	#$0000
	sty	a:code3_progress
	bra	loc_00B3B7
loc_00B3AC:
	dec	a:code3_timer
	ldy	a:code3_progress
	cpy	#$0006
	bcs	loc_00B3DE
loc_00B3B7:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586DF,y
	bne	loc_00B3E7
	cpy	#$0000
	bne	loc_00B3CE
	lda	#$0010
	sta	a:code3_timer
loc_00B3CE:
	iny
	iny
	sty	a:code3_progress
	cpy	#$0006
	bcc	loc_00B3E7
	lda	#$000C
	sta	a:code3_timer
loc_00B3DE:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B3E9
loc_00B3E7:
	clc
	rts
loc_00B3E9:
	lda	a:title_menu_cursor
	cmp	#$0003
	beq	loc_00B3E7
	lda	#$0059
	jsl	f:queue_sound
	lda	#$0001
	sta	a:stage_select_enabled
	sec
	rts

draw_title_word_sprites:
	ldx	#$0FC0
	lda	#$11C0
	sta	zp_12
	lda	#$8000
	sta	zp_14
	lda	a:title_the_x
	sta	zp_FC
	lda	#$0044
	sta	zp_FE
	lda	#$8705
	sta	zp_18
	lda	#$86E5
	sta	zp_1A
	lda	#$86F5
	sta	zp_1C
	ldy	#$000E
	jsr	a:draw_title_sprite_group
	lda	a:title_alien_x
	sta	zp_FC
	lda	#$004C
	sta	zp_FE
	lda	#$8745
	sta	zp_18
	lda	#$8715
	sta	zp_1A
	lda	#$872D
	sta	zp_1C
	ldy	#$0016
	jsr	a:draw_title_sprite_group
	lda	a:title_wars_x
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#$877D
	sta	zp_18
	lda	#$875D
	sta	zp_1A
	lda	#$876D
	sta	zp_1C
	ldy	#$000E
	jsr	a:draw_title_sprite_group
	lda	a:wram_1E5C
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#$8791
	sta	zp_18
	lda	#$878D
	sta	zp_1A
	lda	#$878F
	sta	zp_1C
	ldy	#$0000
	jsr	a:draw_title_sprite_group
loc_00B489:
	sec
	ror	zp_14
	sec
	ror	zp_14
	bcc	loc_00B489
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	rtl

draw_title_sprite_group:
	lda	zp_FE
	sec
	sbc	a:wram_1398
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
	bcc	loc_00B4C7
	phy
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	sty	zp_12
	lda	#$8000
	sta	zp_14
	ply
loc_00B4C7:
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
	jsl	f:clear_ram_1c00_1cff
	lda	#$0009
	sta	a:bgmode_shadow
	lda	#$0001
	ldx	#.loword(data_0587AB)
	jsl	f:load_data_list
	ldy	#$87C3
	jsl	f:sub_009982
	lda	#$0400
	sta	a:wram_1398
	lda	#$0100
	sta	a:wram_1380
	sta	a:wram_13C0
	lda	#$0019
	sta	a:bgmode_shadow
	lda	#$0003
	sta	a:konami_logo_count2
	inc	a:konami_logo_step
	rtl

konami_logo_sweep:
	lda	frame_counter
	and	#$0001
	bne	loc_00B573
	lda	a:konami_logo_count1
	asl	a
	tay
	ldx	a:data_058793,y
	lda	#$2C00
	jsl	f:draw_text_attr
	inc	a:konami_logo_count1
	lda	a:konami_logo_count1
	and	#$0003
	sta	a:konami_logo_count1
loc_00B573:
	lda	a:wram_1380
	sec
	sbc	#$0008
	sta	a:wram_1380
	bne	loc_00B585
	stz	a:wram_13C0
	inc	a:konami_logo_step
loc_00B585:
	rtl

konami_logo_cycle_line:
	lda	frame_counter
	and	#$0003
	bne	loc_00B59B
	ldx	#$2264
	jsr	a:rotate_palette_row
	dec	a:konami_logo_count2
	bne	loc_00B59B
	inc	a:konami_logo_step
loc_00B59B:
	rtl

konami_logo_scroll_in:
	lda	a:wram_1398
	sec
	sbc	#$0002
	sta	a:wram_1398
	and	#$0100
	bne	loc_00B5D2
loc_00B5AB:
	lda	#$0001
	sta	a:konami_logo_timer
	inc	a:konami_logo_step
	rtl

konami_logo_start_shine:
	lda	#$000A
	sta	a:konami_logo_count1
	sta	a:konami_logo_count2
	sta	a:konami_logo_count3
	ldy	#$87E1
	jsl	f:sub_009982
	lda	#$0072
	jsl	f:queue_sound
	inc	a:konami_logo_step
loc_00B5D2:
	rtl

konami_logo_shine:
	lda	a:konami_logo_count1
	beq	loc_00B5ED
	cmp	#$000A
	bne	loc_00B5E4
	ldy	#$87EA
	jsl	f:sub_009982
loc_00B5E4:
	dec	a:konami_logo_count1
	ldx	#$222C
	jsr	a:rotate_palette_row
loc_00B5ED:
	lda	a:konami_logo_count2
	bmi	loc_00B602
	ldx	#$224C
	jsr	a:rotate_palette_row
	dec	a:konami_logo_count2
	lda	#$0003
	sta	a:konami_logo_timer
	rtl
loc_00B602:
	lda	a:konami_logo_timer
	beq	loc_00B612
	dec	a:konami_logo_timer
	bne	loc_00B627
	ldy	#$87D8
	jmp	a:sub_009982
loc_00B612:
	lda	a:konami_logo_count3
	bmi	loc_00B5AB
	lda	frame_counter
	and	#$0001
	bne	loc_00B627
	dec	a:konami_logo_count3
	ldx	#$220A
	jsr	a:rotate_palette_row
loc_00B627:
	rtl

konami_logo_whiten:
	ldx	#$2200
	lda	f:$7E0000,x
	clc
	adc	#$0421
	sta	f:$7E0000,x
	sta	f:$7E0002,x
	cmp	#$7FFF
	bne	loc_00B649
	lda	#$0100
	sta	a:konami_logo_timer
	inc	a:konami_logo_step
loc_00B649:
	rtl

konami_logo_wait:
	dec	a:konami_logo_timer
	bne	loc_00B652
	inc	a:konami_logo_step
loc_00B652:
	rtl

konami_logo_fade_out:
	dec	a:inidisp_shadow
	bne	loc_00B65B
	inc	a:konami_logo_done
loc_00B65B:
	rtl

rotate_palette_row:
	lda	f:$7E0000,x
	pha
	inx
	inx
loc_00B663:
	lda	f:$7E0000,x
	sta	f:$7DFFFE,x
	inx
	inx
	txa
	and	#$001F
	bne	loc_00B663
	pla
	sta	f:$7DFFFE,x
	rts
