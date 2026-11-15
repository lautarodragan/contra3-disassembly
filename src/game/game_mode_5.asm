; game/game_mode_5.asm -- Game mode 5
; Bank $04, $04:D878-$04:D9F0. Included by main.asm in segment BANK04.
;
; sub_04D878: the handler of game mode 5 (via sub_00A625), with sub-modes
; tbl_04D888. Never run in the CDL traces.

sub_04D878:
	; (not executed in the CDL traces)
	lda	a:wram_1C00
	phx
	asl	a
	tax
	lda	f:tbl_04D888,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_04D888:
	.addr	sub_04D890
	.addr	sub_04D8A1
	.addr	sub_04D8BE
	.addr	sub_04D8F2

sub_04D890:
	; (not executed in the CDL traces)
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	inc	a:wram_1C00

sub_04D8A1:
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
	inc	a:wram_1C00

sub_04D8BE:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_04D8EF
	bit	#$8000
	bne	loc_04D8E7
	ldx	#$F347
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$F35A
	jsl	f:sub_009024
	jsr	a:sub_04D912
	jsr	a:sub_04D967
	jsr	a:sub_04D9AF
	rtl
loc_04D8E7:
	lda	#$0084
	jsl	f:queue_sound
	rtl
loc_04D8EF:
	inc	a:wram_1C00

sub_04D8F2:
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
	sta	zp_36
	rtl

sub_04D912:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0F00
	beq	loc_04D920
	stz	a:wram_1C04
	bra	loc_04D945
loc_04D920:
	lda	joy1_held
	ora	joy2_held
	bit	#$0F00
	beq	loc_04D966
	inc	a:wram_1C04
	bne	loc_04D934
	lda	#$0020
	sta	a:wram_1C04
loc_04D934:
	lda	a:wram_1C04
	cmp	#$0020
	bcc	loc_04D966
	bit	#$0003
	bne	loc_04D966
	lda	joy1_held
	ora	joy2_held
loc_04D945:
	bit	#$0500
	bne	loc_04D957
	lda	a:wram_1C02
	dec	a
	bpl	loc_04D953
	lda	#$006A
loc_04D953:
	sta	a:wram_1C02
	rts
loc_04D957:
	lda	a:wram_1C02
	inc	a
	cmp	#$006B
	bcc	loc_04D963
	lda	#$0000
loc_04D963:
	sta	a:wram_1C02
loc_04D966:
	rts

sub_04D967:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$4000
	beq	loc_04D988
	ldx	a:wram_1C02
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
	ldx	a:wram_1C02
	lda	f:data_1DCCE0,x
	and	#$00FF
	jsl	f:send_sound_command_now
	rts

sub_04D9AF:
	; (not executed in the CDL traces)
	ldy	#$5A52
	lda	a:wram_1C02
	sta	zp_FA
	jsl	f:sub_008D41
	lda	zp_FA
	and	#$00F0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	jsr	a:sub_04D9E2
	ora	#$2000
	jsl	f:sub_008DA5
	lda	zp_FA
	and	#$000F
	jsr	a:sub_04D9E2
	ora	#$2000
	jsl	f:sub_008DA5
	jsl	f:sub_008DB0
	rts

sub_04D9E2:
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
