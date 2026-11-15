; game/game_mode_5.asm -- Game mode 5
; Bank $04, $04:D878-$04:D9F0. Included by main.asm in segment BANK04.
;
; run_sound_check: the handler of game mode 5 (via game_mode_sound_check), with sub-modes
; tbl_sound_check_steps. Never run in the CDL traces.

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
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	inc	a:mode_step

sound_check_fade_in:
	; (not executed in the CDL traces)
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_04D8B0
	and	#$000F
	sta	a:inidisp_shadow
loc_04D8B0:
	cmp	#$000F
	bcs	loc_04D8BA
	inc	a:inidisp_shadow
	plp
	rtl
loc_04D8BA:
	plp
	inc	a:mode_step

sound_check_input:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	bne	loc_04D8EF
	bit	#JOY_B
	bne	loc_04D8E7
	ldx	#$F347
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$F35A
	jsl	f:sub_009024
	jsr	a:sound_check_change_id
	jsr	a:sound_check_play
	jsr	a:sound_check_draw_id
	rtl
loc_04D8E7:
	lda	#$0084
	jsl	f:queue_sound
	rtl
loc_04D8EF:
	inc	a:mode_step

sound_check_fade_out:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_04D905
	dec	a:inidisp_shadow
	plp
	rtl
loc_04D905:
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
	beq	loc_04D920
	stz	a:sound_check_repeat_delay
	bra	loc_04D945
loc_04D920:
	lda	joy1_held
	ora	joy2_held
	bit	#JOY_DPAD
	beq	loc_04D966
	inc	a:sound_check_repeat_delay
	bne	loc_04D934
	lda	#$0020
	sta	a:sound_check_repeat_delay
loc_04D934:
	lda	a:sound_check_repeat_delay
	cmp	#$0020
	bcc	loc_04D966
	bit	#$0003
	bne	loc_04D966
	lda	joy1_held
	ora	joy2_held
loc_04D945:
	bit	#JOY_DOWN|JOY_RIGHT
	bne	loc_04D957
	lda	a:sound_check_id
	dec	a
	bpl	loc_04D953
	lda	#$006A
loc_04D953:
	sta	a:sound_check_id
	rts
loc_04D957:
	lda	a:sound_check_id
	inc	a
	cmp	#$006B
	bcc	loc_04D963
	lda	#$0000
loc_04D963:
	sta	a:sound_check_id
loc_04D966:
	rts

sound_check_play:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_Y
	beq	loc_04D988
	ldx	a:sound_check_id
	lda	f:data_1DCCE0,x
	and	#$00FF
	cmp	#$0060
	bcc	loc_04D984
	cmp	#$0074
	bcc	loc_04D989
loc_04D984:
	jsl	f:queue_sound
loc_04D988:
	rts
loc_04D989:
	sec
	sbc	#$0060
	asl	a
	tay
	lda	a:data_05F362,y
	tax
	phy
	jsl	f:sub_0098D4
	ply
	lda	a:data_05F388,y
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
	jsl	f:sub_008D41
	lda	zp_FA
	and	#$00F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	jsr	a:hex_digit_to_tile
	ora	#$2000
	jsl	f:sub_008DA5
	lda	zp_FA
	and	#$000F
	jsr	a:hex_digit_to_tile
	ora	#$2000
	jsl	f:sub_008DA5
	jsl	f:sub_008DB0
	rts

hex_digit_to_tile:
	; (not executed in the CDL traces)
	cmp	#$000A
	bcs	loc_04D9E9
	inc	a
	rts
loc_04D9E9:
	sbc	#$000A
	clc
	adc	#$003C
	rts
