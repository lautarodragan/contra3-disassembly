; game/screens.asm -- Stage clear, OPTION and FINAL SCORE screens; scores
; Bank $00, $00:B679-$00:BD3F. Included by main.asm in segment BANK00.
;
; run_stage_clear (GAME_MODE_STAGE_CLEAR), run_options (GAME_MODE_OPTIONS),
; run_final_score (GAME_MODE_FINAL_SCORE); the score board and number
; drawing helpers; add_score (BCD scores and extra lives) used by the
; players and the top-down stages; load_stage_graphics.

; GAME_MODE_STAGE_CLEAR screen: loads the stage clear picture
; (data_0587F1[stage_number]), loads the next stage's graphics, counts the
; 10000-point stage_bonus into the scores (transfer_stage_bonus), waits a
; button or $100 frames; stage_number + 1, stage_checkpoint = 0.
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
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	a:tm_shadow
	ldx	#.loword(song_set_05F4EF)
	jsl	f:load_song_set
	lda	stage_number
	asl	a
	tay
	lda	a:data_0587F1,y
	tax
	jsl	f:load_data_list
	ldy	#.loword(palette_task_058880)
	jsl	f:start_palette_task
	inc	a:mode_step
	rtl

stage_clear_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
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
	lda	#$006A
	jsl	f:queue_sound
	inc	a:mode_step
	rtl

stage_clear_load_next_stage:
	lda	stage_number
	inc	a
	cmp	#$0007
	bcc	@load_next
	; (not executed in the CDL traces)
	lda	#$0001
@load_next:
	jsl	f:load_stage_graphics
	lda	#$0001
	sta	mode_timer
	inc	a:mode_step
	rtl

stage_clear_show_scores:
	dec	mode_timer
	bpl	@return
	jsl	f:draw_score_board
	lda	#$0001
	sta	a:stage_bonus_hi
	lda	#$0000
	sta	a:stage_bonus
	jsr	a:draw_stage_bonus
	ldy	#.loword(palette_task_058889)
	jsl	f:start_palette_task
	lda	#$0040
	sta	mode_timer
	lda	#$0005
	sta	a:tm_shadow
	inc	a:mode_step
@return:
	rtl

stage_clear_wait:
	dec	mode_timer
	bpl	@return
	inc	a:mode_step
@return:
	rtl

stage_clear_count_bonus:
	jsr	a:transfer_stage_bonus
	jsl	f:draw_score_board
	jsr	a:draw_stage_bonus
	lda	a:stage_bonus
	bit	#$0100
	bne	@check_end
	lda	#$0003
	jsl	f:queue_sound
@check_end:
	lda	a:stage_bonus
	ora	a:stage_bonus_hi
	beq	@bonus_done
	rtl
@bonus_done:
	lda	#$0100
	sta	mode_timer
	inc	a:mode_step
	rtl

stage_clear_wait_button:
	dec	mode_timer
	bpl	@check_button
	; (not executed in the CDL traces)
	brl	@next
@check_button:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_B|JOY_Y|JOY_START|JOY_A|JOY_X
	bne	@next
	rtl
@next:
	inc	a:mode_step
	rtl

stage_clear_fade_out:
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
	stz	a:stage_checkpoint
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	@to_stage_card
	; (not executed in the CDL traces)
	lda	#$0001
	sta	stage_number
@to_stage_card:
	lda	#$0001
	sta	mode_result
	rtl

; Draws HI SCORE, 1P/2P SCORE and REST (update_high_score first).
draw_score_board:
	jsr	a:update_high_score
	ldx	#.loword(text_hi_score)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_1p_score)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_rest_03)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_2p_score)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_rest_03_2)
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

; add_score with X = player object ($0200/$0240): stat block = X + $1D80.
add_score_for_player_obj:
	pha
	txa
	clc
	adc	#$1D80
	tax
	pla
	bra	add_score

; add_score with X = top-down player ($0EC0/$0F00): stat block = X + $10C0.
add_score_for_topdown_player:
	pha
	txa
	clc
	adc	#$10C0
	tax
	pla

; Adds A (BCD) to the score of the player whose stat block ($1F80 / $1FC0)
; is in X (field +$20, capped at 9999999). Counts down the next-extend
; counter (+$36): at 0 an extra life (+$0A, max 30, sound $3E) and 60000
; more points to the next one.
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
	bmi	@extra_life
	lda	$36,x
	ora	$38,x
	bne	@add_points
@extra_life:
	lda	#$003E
	jsl	f:queue_sound
	lda	$0A,x
	inc	a
	cmp	#$001E
	bcc	@store_lives
	; (not executed in the CDL traces)
	lda	#$001E
@store_lives:
	sta	$0A,x
	clc
	lda	$36,x
	adc	#$0000
	sta	$36,x
	lda	$38,x
	adc	#$0006
	sta	$38,x
@add_points:
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
	bcc	@done
	; (not executed in the CDL traces)
	lda	#$9999
	sta	$20,x
	lda	#$0999
	sta	$22,x
@done:
	cld
	rtl

; Draws the 7-digit BCD number at X (4 bytes) at VRAM word address Y,
; tile attributes in A.
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
	ldx	#.loword(text_stage_clear_bonus)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$1C02
	ldy	#$5AAD
	lda	#$2000
	jsl	f:draw_bcd_number
	rts

; Draws the word at X (0-99) as two decimal digits at VRAM word address Y.
draw_two_digit_number:
	sta	zp_FA
	phx
	jsl	f:begin_vram_transfer
	plx
	lda	$00,x
	bpl	@divide
	; (not executed in the CDL traces)
	lda	#$0000
@divide:
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

; Writes digit A & $F (tile = digit + 1 | attributes zp_FA) to the VRAM
; write started by the caller.
draw_digit:
	and	#$000F
	inc	a
	ora	zp_FA
	phx
	jsl	f:push_vram_word
	plx
	rtl

; Moves 100 points of stage_bonus to each living player per frame.
transfer_stage_bonus:
	lda	a:p1_lives
	beq	@check_p2
	lda	#$0100
	ldx	#$1F80
	jsl	f:add_score
@check_p2:
	lda	a:p2_lives
	beq	@decrease_bonus
	; (not executed in the CDL traces)
	lda	#$0100
	ldx	#$1FC0
	jsl	f:add_score
@decrease_bonus:
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

; high_score = max(high_score, p1_score, p2_score).
update_high_score:
	sec
	lda	a:high_score
	sbc	a:p1_score
	lda	a:high_score_hi
	sbc	a:p1_score_hi
	bcs	@check_p2
	lda	a:p1_score
	sta	a:high_score
	lda	a:p1_score_hi
	sta	a:high_score_hi
@check_p2:
	sec
	lda	a:high_score
	sbc	a:p2_score
	lda	a:high_score_hi
	sbc	a:p2_score_hi
	bcs	@return
	; (not executed in the CDL traces)
	lda	a:p2_score
	sta	a:high_score
	lda	a:p2_score_hi
	sta	a:high_score_hi
@return:
	rts

; A = stage number: loads its graphics sets (ptrs_0588E1 / ptrs_0588ED).
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

; OPTION MODE: PLAYER (option_lives 3/5/7), LEVEL (option_level),
; SOUND (option_sound, STEREO / MONO), EXIT. Up/Down move options_cursor,
; Left/Right change the entry; EXIT + a button or Start leaves.
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
	ldx	#.loword(load_list_05CF41)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_058412)
	jsl	f:start_palette_task
	jsr	a:options_get_lives_index
	ldx	#.loword(text_option_mode)
	lda	#$2400
	jsl	f:draw_text_attr
	inc	a:mode_step
	rtl

options_input:
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
	; (not executed in the CDL traces)
	inc	a:inidisp_shadow
	plp
	rtl
@faded_in:
	plp
	jsr	a:options_move_cursor
	jsr	a:options_update_player_item
	jsr	a:options_update_level_item
	jsr	a:options_update_sound_item
	jsr	a:options_update_exit_item
	bcs	@exit
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	@exit
	rtl
@exit:
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
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
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
	beq	@return
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_UP
	bne	@move_up
	lda	a:options_cursor
	inc	a
	cmp	#$0004
	bcc	@store
	; (not executed in the CDL traces)
	lda	#$0000
@store:
	sta	a:options_cursor
	rts
@move_up:
	lda	a:options_cursor
	dec	a
	bpl	@store2
	lda	#$0003
@store2:
	sta	a:options_cursor
@return:
	rts

options_update_player_item:
	lda	a:options_cursor
	cmp	#$0000
	beq	@selected
	ldx	#.loword(text_player)
	jsl	f:draw_text
	jmp	a:options_draw_lives
@selected:
	ldx	#.loword(text_player)
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_lives
	jsr	a:options_store_lives
	jmp	a:options_draw_lives

options_update_level_item:
	lda	a:options_cursor
	cmp	#$0001
	beq	@selected
	ldx	#.loword(text_level)
	jsl	f:draw_text
	jmp	a:options_draw_level
@selected:
	ldx	#.loword(text_level)
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_level
	jmp	a:options_draw_level

options_update_sound_item:
	lda	a:options_cursor
	cmp	#$0002
	beq	@selected
	ldx	#.loword(text_sound)
	jsl	f:draw_text
	jmp	a:options_draw_sound
@selected:
	ldx	#.loword(text_sound)
	lda	#$2400
	jsl	f:draw_text_attr
	jsr	a:options_change_sound
	jmp	a:options_draw_sound

options_update_exit_item:
	lda	a:options_cursor
	cmp	#$0003
	beq	@selected
	ldx	#.loword(text_exit)
	jsl	f:draw_text
@loop:
	clc
	rts
@selected:
	ldx	#.loword(text_exit)
	lda	#$2400
	jsl	f:draw_text_attr
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_B|JOY_Y|JOY_A|JOY_X
	beq	@loop
	sec
	rts

options_change_lives:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_LEFT|JOY_RIGHT
	beq	@return
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	@next_option
	lda	a:options_lives_index
	dec	a
	bpl	@store
	lda	#OPTION_LIVES_LAST	; 2; 3 with CHEAT_OPTION_30_LIVES
@store:
	sta	a:options_lives_index
	rts
@next_option:
	lda	a:options_lives_index
	inc	a
	cmp	#OPTION_LIVES_LAST+1
	bcc	@store2
	lda	#$0000
@store2:
	sta	a:options_lives_index
@return:
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
	beq	@store
	; (not executed in the CDL traces)
	iny
	cmp	#$0005
	beq	@store
	iny
	cmp	#$0007
	beq	@store
	iny
@store:
	sty	a:options_lives_index
	rts
options_draw_lives:
	ldy	#$5992
	lda	a:option_lives
	cmp	#$0063
	bcc	@divide
	; (not executed in the CDL traces)
	lda	#$0063
@divide:
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
	beq	@return
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	@next_option
	; (not executed in the CDL traces)
	lda	a:option_level
	dec	a
	dec	a
	bpl	@store
	lda	#$0004
@store:
	sta	a:option_level
	rts
@next_option:
	lda	a:option_level
	inc	a
	inc	a
	cmp	#$0006
	bcc	@store2
	lda	#$0000
@store2:
	sta	a:option_level
@return:
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
	beq	@return
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_RIGHT
	bne	@next_option
	lda	a:option_sound
	dec	a
	dec	a
	bpl	@store_previous
	lda	#$0002
@store_previous:
	sta	a:option_sound
	jsr	a:options_apply_sound_mode
@return:
	rts
@next_option:
	; (not executed in the CDL traces)
	lda	a:option_sound
	inc	a
	inc	a
	cmp	#$0004
	bcc	@store
	lda	#$0000
@store:
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

; FINAL SCORE screen: fade in, draw the scores, wait for Start, fade out.
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
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0005
	sta	a:tm_shadow
	ldx	#.loword(load_list_058976)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05898E)
	jsl	f:start_palette_task
	jsl	f:draw_final_scores
	inc	a:mode_step
	rtl

final_score_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
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
	inc	a:mode_step
	rtl

final_score_wait_start:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	@return
	; (not executed in the CDL traces)
	inc	a:mode_step
@return:
	rtl

final_score_fade_out:
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
	lda	#$0001
	sta	mode_result
	rtl

draw_final_scores:
	jsr	a:update_high_score
	ldx	#.loword(text_hi_score_2)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_1p_score_2)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_rest_03_3)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_2p_score_2)
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#.loword(text_rest_03_4)
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
