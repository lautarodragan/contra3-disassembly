; game/screens.asm -- Other non-gameplay screens
; Bank $00, $00:B679-$00:BD3F. Included by main.asm in segment BANK00.
;
; Sub-mode tables of game modes 10, 13 and 14 (run_stage_clear, run_options,
; run_final_score) and the tilemap/number drawing helpers they share with other
; modes (draw_score_board, add_score...).

run_stage_clear:
	lda	a:mode_step
	asl	a
	tax
	jmp	(.loword(tbl_stage_clear_steps),x)
tbl_stage_clear_steps:
	.addr	stage_clear_init
	.addr	stage_clear_fade_in
	.addr	stage_clear_load_next_stage
	.addr	stage_clear_show_scores
	.addr	stage_clear_wait
	.addr	stage_clear_count_bonus
	.addr	stage_clear_wait_button
	.addr	stage_clear_fade_out

stage_clear_init:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B6A4
	dec	a:inidisp_shadow
	plp
	rtl
loc_00B6A4:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	a:tm_shadow
	ldx	#$F4EF
	jsl	f:load_song_set
	lda	stage_number
	asl	a
	tay
	lda	a:data_0587F1,y
	tax
	jsl	f:load_data_list
	ldy	#$8880
	jsl	f:sub_009982
	inc	a:mode_step
	rtl

stage_clear_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00B6DE
	and	#$000F
	sta	a:inidisp_shadow
loc_00B6DE:
	cmp	#$000F
	bcs	loc_00B6E8
	inc	a:inidisp_shadow
	plp
	rtl
loc_00B6E8:
	plp
	lda	#$006A
	jsl	f:queue_sound
	inc	a:mode_step
	rtl

stage_clear_load_next_stage:
	lda	stage_number
	inc	a
	cmp	#$0007
	bcc	loc_00B6FF
	; (not executed in the CDL traces)
	lda	#$0001
loc_00B6FF:
	jsl	f:load_stage_graphics
	lda	#$0001
	sta	mode_timer
	inc	a:mode_step
	rtl

stage_clear_show_scores:
	dec	mode_timer
	bpl	loc_00B738
	jsl	f:draw_score_board
	lda	#$0001
	sta	a:stage_bonus_hi
	lda	#$0000
	sta	a:stage_bonus
	jsr	a:draw_stage_bonus
	ldy	#$8889
	jsl	f:sub_009982
	lda	#$0040
	sta	mode_timer
	lda	#$0005
	sta	a:tm_shadow
	inc	a:mode_step
loc_00B738:
	rtl

stage_clear_wait:
	dec	mode_timer
	bpl	loc_00B740
	inc	a:mode_step
loc_00B740:
	rtl

stage_clear_count_bonus:
	jsr	a:transfer_stage_bonus
	jsl	f:draw_score_board
	jsr	a:draw_stage_bonus
	lda	a:stage_bonus
	bit	#$0100
	bne	loc_00B75A
	lda	#$0003
	jsl	f:queue_sound
loc_00B75A:
	lda	a:stage_bonus
	ora	a:stage_bonus_hi
	beq	loc_00B763
	rtl
loc_00B763:
	lda	#$0100
	sta	mode_timer
	inc	a:mode_step
	rtl

stage_clear_wait_button:
	dec	mode_timer
	bpl	loc_00B773
	; (not executed in the CDL traces)
	brl	loc_00B77D
loc_00B773:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_B|JOY_Y|JOY_START|JOY_A|JOY_X
	bne	loc_00B77D
	rtl
loc_00B77D:
	inc	a:mode_step
	rtl

stage_clear_fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B794
	dec	a:inidisp_shadow
	plp
	rtl
loc_00B794:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	a:stage_checkpoint
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	loc_00B7AC
	; (not executed in the CDL traces)
	lda	#$0001
	sta	stage_number
loc_00B7AC:
	lda	#$0001
	sta	mode_result
	rtl

draw_score_board:
	jsr	a:update_high_score
	ldx	#$8892
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$889D
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$88A8
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$88B2
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$88BD
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$1E44
	ldy	#$58AD
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1FA0
	ldy	#$5924
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1FE0
	ldy	#$5936
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1F8A
	ldy	#$5969
	lda	#$2000
	jsl	f:draw_two_digit_number
	ldx	#$1FCA
	ldy	#$597B
	lda	#$2000
	jsl	f:draw_two_digit_number
	rtl

add_score_for_player_obj:
	pha
	txa
	clc
	adc	#$1D80
	tax
	pla
	bra	add_score

add_score_for_topdown_player:
	pha
	txa
	clc
	adc	#$10C0
	tax
	pla

add_score:
	sed
	sta	zp_FA
	sec
	lda	$36,x
	sbc	zp_FA
	sta	$36,x
	lda	$38,x
	sbc	#$0000
	sta	$38,x
	bmi	loc_00B854
	lda	$36,x
	ora	$38,x
	bne	loc_00B877
loc_00B854:
	lda	#$003E
	jsl	f:queue_sound
	lda	$0A,x
	inc	a
	cmp	#$001E
	bcc	loc_00B866
	; (not executed in the CDL traces)
	lda	#$001E
loc_00B866:
	sta	$0A,x
	clc
	lda	$36,x
	adc	#$0000
	sta	$36,x
	lda	$38,x
	adc	#$0006
	sta	$38,x
loc_00B877:
	lda	zp_FA
	clc
	adc	$20,x
	sta	$20,x
	lda	$22,x
	adc	#$0000
	sta	$22,x
	sec
	lda	$20,x
	sbc	#$9999
	lda	$22,x
	sbc	#$0999
	bcc	loc_00B89C
	; (not executed in the CDL traces)
	lda	#$9999
	sta	$20,x
	lda	#$0999
	sta	$22,x
loc_00B89C:
	cld
	rtl

draw_bcd_number:
	sta	zp_FA
	phx
	jsl	f:begin_vram_transfer
	plx
	lda	$03,x
	jsl	f:draw_digit
	lda	$02,x
	jsl	f:draw_digit_high_nibble
	lda	$02,x
	jsl	f:draw_digit
	lda	$01,x
	jsl	f:draw_digit_high_nibble
	lda	$01,x
	jsl	f:draw_digit
	lda	$00,x
	jsl	f:draw_digit_high_nibble
	lda	$00,x
	jsl	f:draw_digit
	jsl	f:end_vram_transfer
	rtl

draw_stage_bonus:
	ldx	#$88C7
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$1C02
	ldy	#$5AAD
	lda	#$2000
	jsl	f:draw_bcd_number
	rts

draw_two_digit_number:
	sta	zp_FA
	phx
	jsl	f:begin_vram_transfer
	plx
	lda	$00,x
	bpl	loc_00B8FC
	; (not executed in the CDL traces)
	lda	#$0000
loc_00B8FC:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rep	#$20
	.a16
	lda	a:RDDIVL
	jsl	f:draw_digit
	lda	a:RDMPYL
	jsl	f:draw_digit
	jsl	f:end_vram_transfer
	rtl

draw_digit_high_nibble:
	lsr	a
	lsr	a
	lsr	a
	lsr	a

draw_digit:
	and	#$000F
	inc	a
	ora	zp_FA
	phx
	jsl	f:push_vram_word
	plx
	rtl

transfer_stage_bonus:
	lda	a:p1_lives
	beq	loc_00B943
	lda	#$0100
	ldx	#$1F80
	jsl	f:add_score
loc_00B943:
	lda	a:p2_lives
	beq	loc_00B952
	; (not executed in the CDL traces)
	lda	#$0100
	ldx	#$1FC0
	jsl	f:add_score
loc_00B952:
	sed
	sec
	lda	a:stage_bonus
	sbc	#$0100
	sta	a:stage_bonus
	lda	a:stage_bonus_hi
	sbc	#$0000
	sta	a:stage_bonus_hi
	cld
	rts

update_high_score:
	sec
	lda	a:high_score
	sbc	a:p1_score
	lda	a:high_score_hi
	sbc	a:p1_score_hi
	bcs	loc_00B983
	lda	a:p1_score
	sta	a:high_score
	lda	a:p1_score_hi
	sta	a:high_score_hi
loc_00B983:
	sec
	lda	a:high_score
	sbc	a:p2_score
	lda	a:high_score_hi
	sbc	a:p2_score_hi
	bcs	loc_00B99E
	; (not executed in the CDL traces)
	lda	a:p2_score
	sta	a:high_score
	lda	a:p2_score_hi
	sta	a:high_score_hi
loc_00B99E:
	rts

load_stage_graphics:
	pha
	jsl	f:clear_bg_scroll_state
	jsl	f:clear_wram_7e4000_7effff
	pla
	asl	a
	tay
	lda	a:ptrs_0588E1,y
	tax
	phy
	jsl	f:load_data_list
	ply
	lda	a:ptrs_0588ED,y
	tax
	jsl	f:load_data_list
	rtl

run_options:
	lda	a:mode_step
	asl	a
	tax
	jmp	(.loword(tbl_options_steps),x)
tbl_options_steps:
	.addr	options_init
	.addr	options_input
	.addr	options_fade_out

options_init:
	ldx	#.loword(data_05CF41)
	jsl	f:load_data_list
	ldy	#$8412
	jsl	f:sub_009982
	jsr	a:options_get_lives_index
	ldx	#$8948
	lda	#$2400
	jsl	f:draw_text_attr
	inc	a:mode_step
	rtl

options_input:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00B9FA
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:inidisp_shadow
loc_00B9FA:
	cmp	#$000F
	bcs	loc_00BA04
	; (not executed in the CDL traces)
	inc	a:inidisp_shadow
	plp
	rtl
loc_00BA04:
	plp
	jsr	a:options_move_cursor
	jsr	a:options_update_player_item
	jsr	a:options_update_level_item
	jsr	a:options_update_sound_item
	jsr	a:options_update_exit_item
	bcs	loc_00BA20
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	loc_00BA20
	rtl
loc_00BA20:
	lda	#$0002
	jsl	f:queue_sound
	inc	a:mode_step
	rtl

options_fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BA3E
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BA3E:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	mode_result
	rtl

options_move_cursor:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_UP|JOY_DOWN
	beq	loc_00BA7E
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_UP
	bne	loc_00BA72
	lda	a:options_cursor
	inc	a
	cmp	#$0004
	bcc	loc_00BA6E
	; (not executed in the CDL traces)
	lda	#$0000
loc_00BA6E:
	sta	a:options_cursor
	rts
loc_00BA72:
	lda	a:options_cursor
	dec	a
	bpl	loc_00BA7B
	lda	#$0003
loc_00BA7B:
	sta	a:options_cursor
loc_00BA7E:
	rts

options_update_player_item:
	lda	a:options_cursor
	cmp	#$0000
	beq	loc_00BA91
	ldx	#$8956
	jsl	f:draw_text
	jmp	a:options_draw_lives
loc_00BA91:
	ldx	#$8956
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_lives
	jsr	a:options_store_lives
	jmp	a:options_draw_lives

options_update_level_item:
	lda	a:options_cursor
	cmp	#$0001
	beq	loc_00BAB6
	ldx	#$895F
	jsl	f:draw_text
	jmp	a:options_draw_level
loc_00BAB6:
	ldx	#$895F
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_level
	jmp	a:options_draw_level

options_update_sound_item:
	lda	a:options_cursor
	cmp	#$0002
	beq	loc_00BAD8
	ldx	#$8967
	jsl	f:draw_text
	jmp	a:options_draw_sound
loc_00BAD8:
	ldx	#$8967
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_sound
	jmp	a:options_draw_sound

options_update_exit_item:
	lda	a:options_cursor
	cmp	#$0003
	beq	loc_00BAF9
	ldx	#$896F
	jsl	f:draw_text
loc_00BAF7:
	clc
	rts
loc_00BAF9:
	ldx	#$896F
	lda	#$2400
	jsl	f:draw_text_attr
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_B|JOY_Y|JOY_A|JOY_X
	beq	loc_00BAF7
	sec
	rts

options_change_lives:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_LEFT|JOY_RIGHT
	beq	loc_00BB41
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	loc_00BB32
	lda	a:options_lives_index
	dec	a
	bpl	loc_00BB2E
	lda	#$0002
loc_00BB2E:
	sta	a:options_lives_index
	rts
loc_00BB32:
	lda	a:options_lives_index
	inc	a
	cmp	#$0003
	bcc	loc_00BB3E
	lda	#$0000
loc_00BB3E:
	sta	a:options_lives_index
loc_00BB41:
	rts

options_store_lives:
	lda	a:options_lives_index
	asl	a
	tay
	lda	a:lives_options,y
	sta	a:option_lives
	rts

options_get_lives_index:
	ldy	#$0000
	lda	a:option_lives
	cmp	#$0003
	beq	loc_00BB66
	; (not executed in the CDL traces)
	iny
	cmp	#$0005
	beq	loc_00BB66
	iny
	cmp	#$0007
	beq	loc_00BB66
	iny
loc_00BB66:
	sty	a:options_lives_index
	rts
options_draw_lives:
	ldy	#$5992
	lda	a:option_lives
	cmp	#$0063
	bcc	loc_00BB78
	; (not executed in the CDL traces)
	lda	#$0063
loc_00BB78:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	rep	#$20
	.a16
	jsl	f:begin_vram_transfer
	lda	a:RDDIVL
	and	#$00FF
	inc	a
	ora	#$2000
	jsl	f:push_vram_word
	lda	a:RDMPYL
	and	#$00FF
	inc	a
	ora	#$2000
	jsl	f:push_vram_word
	jsl	f:end_vram_transfer
	rts

options_change_level:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_LEFT|JOY_RIGHT
	beq	loc_00BBDE
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	loc_00BBCE
	; (not executed in the CDL traces)
	lda	a:option_level
	dec	a
	dec	a
	bpl	loc_00BBCA
	lda	#$0004
loc_00BBCA:
	sta	a:option_level
	rts
loc_00BBCE:
	lda	a:option_level
	inc	a
	inc	a
	cmp	#$0006
	bcc	loc_00BBDB
	lda	#$0000
loc_00BBDB:
	sta	a:option_level
loc_00BBDE:
	rts
options_draw_level:
	ldy	a:option_level
	ldx	a:data_058903,y
	jsl	f:draw_text
	rts

options_change_sound:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_LEFT|JOY_RIGHT
	beq	loc_00BC11
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	loc_00BC12
	lda	a:option_sound
	dec	a
	dec	a
	bpl	loc_00BC0B
	lda	#$0002
loc_00BC0B:
	sta	a:option_sound
	jsr	a:options_apply_sound_mode
loc_00BC11:
	rts
loc_00BC12:
	; (not executed in the CDL traces)
	lda	a:option_sound
	inc	a
	inc	a
	cmp	#$0004
	bcc	loc_00BC1F
	lda	#$0000
loc_00BC1F:
	sta	a:option_sound

options_apply_sound_mode:
	; (not executed in the CDL traces)
	ldy	a:option_sound
	lda	a:sound_mode_commands,y
	jsl	f:queue_sound
	rts
options_draw_sound:
	ldy	a:option_sound
	ldx	a:data_05892E,y
	jsl	f:draw_text
	rts

run_final_score:
	lda	a:mode_step
	asl	a
	tax
	jmp	(.loword(tbl_final_score_steps),x)
tbl_final_score_steps:
	.addr	final_score_init
	.addr	final_score_fade_in
	.addr	final_score_wait_start
	.addr	final_score_fade_out

final_score_init:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BC5B
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BC5B:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0005
	sta	a:tm_shadow
	ldx	#.loword(data_058976)
	jsl	f:load_data_list
	ldy	#$898E
	jsl	f:sub_009982
	jsl	f:draw_final_scores
	inc	a:mode_step
	rtl

final_score_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00BC8D
	and	#$000F
	sta	a:inidisp_shadow
loc_00BC8D:
	cmp	#$000F
	bcs	loc_00BC97
	inc	a:inidisp_shadow
	plp
	rtl
loc_00BC97:
	plp
	inc	a:mode_step
	rtl

final_score_wait_start:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	loc_00BCA8
	; (not executed in the CDL traces)
	inc	a:mode_step
loc_00BCA8:
	rtl

final_score_fade_out:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BCBC
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BCBC:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	mode_result
	rtl

draw_final_scores:
	jsr	a:update_high_score
	ldx	#$8997
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$89A2
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$89AD
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$89B7
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$89C2
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$1E44
	ldy	#$58ED
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1FA0
	ldy	#$58E4
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1FE0
	ldy	#$58F6
	lda	#$2000
	jsl	f:draw_bcd_number
	ldx	#$1F8A
	ldy	#$5929
	lda	#$2000
	jsl	f:draw_two_digit_number
	ldx	#$1FCA
	ldy	#$593B
	lda	#$2000
	jsl	f:draw_two_digit_number
	rtl
