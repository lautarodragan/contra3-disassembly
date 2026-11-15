; game/sound_check.asm -- Sound check mode (game mode 5)
; Bank $04, $04:D878-$04:D9F0. Included by main.asm in segment BANK04.
;
; run_sound_check: "SOUND CHECK MODE", the handler of GAME_MODE_SOUND_CHECK
; (game_mode_sound_check), steps in mode_step. Nothing enters this mode;
; never run in the CDL traces (checked in the emulator by poking game_mode).

; SOUND CHECK MODE (game mode 5, never run): d-pad picks sound_check_id
; ($00-$6A, auto-repeat), Y plays it (data_1DCCE0; ids $60-$73 load a song
; set first), B sends $84 (stop), Start leaves.
run_sound_check:
	; (not executed in the CDL traces)
	lda	a:mode_step
	phx
	asl	a
	tax
	lda	f:tbl_sound_check_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_sound_check_steps:
	.addr	sound_check_init
	.addr	sound_check_fade_in
	.addr	sound_check_input
	.addr	sound_check_fade_out

sound_check_init:
	; (not executed in the CDL traces)
	ldx	#.loword(data_05CF41)
	jsl	f:load_data_list
	ldy	#$8412
	jsl	f:start_palette_task
	inc	a:mode_step

sound_check_fade_in:
	; (not executed in the CDL traces)
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

sound_check_input:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	@start_pressed
	bit	#JOY_B
	bne	@b_pressed
	ldx	#$F347
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$F35A
	jsl	f:draw_text
	jsr	a:sound_check_change_id
	jsr	a:sound_check_play
	jsr	a:sound_check_draw_id
	rtl
@b_pressed:
	lda	#$0084
	jsl	f:queue_sound
	rtl
@start_pressed:
	inc	a:mode_step

sound_check_fade_out:
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

sound_check_change_id:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_DPAD
	beq	@check_held
	stz	a:sound_check_repeat_delay
	bra	@move
@check_held:
	lda	joy1_held
	ora	joy2_held
	bit	#JOY_DPAD
	beq	@return
	inc	a:sound_check_repeat_delay
	bne	@check_delay
	lda	#$0020
	sta	a:sound_check_repeat_delay
@check_delay:
	lda	a:sound_check_repeat_delay
	cmp	#$0020
	bcc	@return
	bit	#$0003
	bne	@return
	lda	joy1_held
	ora	joy2_held
@move:
	bit	#JOY_DOWN|JOY_RIGHT
	bne	@next_id
	lda	a:sound_check_id
	dec	a
	bpl	@store
	lda	#$006A
@store:
	sta	a:sound_check_id
	rts
@next_id:
	lda	a:sound_check_id
	inc	a
	cmp	#$006B
	bcc	@store_next
	lda	#$0000
@store_next:
	sta	a:sound_check_id
@return:
	rts

sound_check_play:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_Y
	beq	@return
	ldx	a:sound_check_id
	lda	f:data_1DCCE0,x
	and	#$00FF
	cmp	#$0060
	bcc	@play_sound
	cmp	#$0074
	bcc	@play_song_set
@play_sound:
	jsl	f:queue_sound
@return:
	rts
@play_song_set:
	sec
	sbc	#$0060
	asl	a
	tay
	lda	a:song_lists,y
	tax
	phy
	jsl	f:load_song_set
	ply
	lda	a:song_start_commands,y
	jsl	f:send_sound_command_now
	ldx	a:sound_check_id
	lda	f:data_1DCCE0,x
	and	#$00FF
	jsl	f:send_sound_command_now
	rts

sound_check_draw_id:
	; (not executed in the CDL traces)
	ldy	#$5A52
	lda	a:sound_check_id
	sta	zp_FA
	jsl	f:begin_vram_transfer
	lda	zp_FA
	and	#$00F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	jsr	a:hex_digit_to_tile
	ora	#$2000
	jsl	f:push_vram_word
	lda	zp_FA
	and	#$000F
	jsr	a:hex_digit_to_tile
	ora	#$2000
	jsl	f:push_vram_word
	jsl	f:end_vram_transfer
	rts

; A = 0-15 -> tile number (digits 1-10, letters from $3C).
hex_digit_to_tile:
	; (not executed in the CDL traces)
	cmp	#$000A
	bcs	@letter
	inc	a
	rts
@letter:
	sbc	#$000A
	clc
	adc	#$003C
	rts
