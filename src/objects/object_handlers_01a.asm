; objects/object_handlers_01a.asm -- Object handlers (bank $01, part 1)
; Bank $01, $01:B194-$01:CF8A. Included by main.asm in segment BANK01.
;
; Handlers of object types dispatched through tbl_05A48A and their helpers;
; sub_01CF25..sub_01CF66 are helpers used by every bank.

sub_01B194:
	lda	$12,x
	pha
	beq	loc_01B200
	cmp	#$0008
	bcs	loc_01B1EE
	lda	$06,x
	bpl	loc_01B1E0
	pla
	lda	#$0042
	jsl	f:sub_00868F
	stz	$18,x
	stz	$1A,x
	stz	$16,x
	stz	$06,x
	lda	#$0080
	sta	$24,x
	lda	#$0008
	sta	$12,x
	lda	#$B540
	sta	zp_00
	lda	#$4D8C
	jsl	f:sub_00FE76
	lda	#$B520
	sta	zp_00
	lda	#$4E0C
	jsl	f:sub_00FE76
	lda	#$B560
	sta	zp_00
	lda	#$4D90
	jml	f:sub_00FE76
loc_01B1E0:
	lda	$26,x
	beq	loc_01B1EE
	lda	#$912A
	sta	zp_9A
	lda	#$0050
	sta	zp_98
loc_01B1EE:
	sec
	lda	#$00A8
	sbc	$0E,x
	sta	a:wram_13D8
	sec
	lda	#$015C
	sbc	$0A,x
	sta	a:wram_13C0
loc_01B200:
	pla
	phx
	asl	a
	tax
	lda	f:tbl_01B20E,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01B20E:
	.addr	sub_01B224
	.addr	sub_01B267
	.addr	sub_01B312
	.addr	sub_01B339
	.addr	sub_01B371
	.addr	sub_01B39E
	.addr	sub_01B3B4
	.addr	sub_01B41F
	.addr	sub_01B4E1
	.addr	sub_01D831
	.addr	sub_01B521

sub_01B224:
	lda	#$8000
	sta	a:wram_09D6
	lda	a:wram_13BA
	cmp	#$0004
	bne	loc_01B266
	lda	a:wram_13FE
	beq	loc_01B266
	lda	#$0050
	sta	$28,x
	lda	#$FFC0
	sta	$2A,x
	lda	#$0100
	sta	$06,x
	lda	#$0080
	sta	a:wram_1636
	lda	#$009C
	sta	$0A,x
	lda	#$00A8
	sta	$0E,x
	lda	#$ACDF
	sta	$30,x
	stz	$24,x
	inc	$12,x
	lda	#$0044
	jsl	f:sub_00868F
loc_01B266:
	rtl

sub_01B267:
	lda	#$0003
	sta	a:wram_1662
	lda	#$0078
	sta	zp_00
	lda	#$00D0
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#$C69C
	jsl	f:sub_01CF3C
	bcs	loc_01B293
	lda	#$FFFC
	sta	a:$001E,y
loc_01B293:
	stx	zp_FA
	stz	zp_00
	stz	zp_0C
	lda	$24,x
	cmp	#$0010
	bcc	loc_01B2A5
	lda	#$0000
	sta	$24,x
loc_01B2A5:
	cmp	#$0003
	bcs	loc_01B30F
	cmp	#$0000
	beq	loc_01B2C8
	ldy	#$0010
	sty	zp_00
	ldy	#$0100
	sty	zp_0C
	cmp	#$0001
	beq	loc_01B2C8
	lda	#$0020
	sta	zp_00
	lda	#$0200
	sta	zp_0C
loc_01B2C8:
	lda	a:wram_1380
	bit	#$0100
	beq	loc_01B2D8
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
loc_01B2D8:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	clc
	lda	$30,x
	adc	zp_00
	tay
	clc
	lda	#$4010
	adc	zp_0C
	jsl	f:sub_00FEA3
	ldx	zp_FA
	lda	$24,x
	cmp	#$0002
	bne	loc_01B30F
	clc
	lda	$30,x
	adc	#$0030
	sta	$30,x
	cmp	#$AF1F
	bcc	loc_01B30F
	inc	$12,x
	lda	#$0060
	sta	$24,x
loc_01B30F:
	inc	$24,x
	rtl

sub_01B312:
	dec	$24,x
	bne	loc_01B338
	inc	$12,x
	lda	#$0001
	sta	$16,x
	lda	#$4000
	sta	$1C,x
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$0001
	sta	$04,x
	lda	#$001E
	jsl	f:sub_00868F
loc_01B338:
	rtl

sub_01B339:
	inc	a:wram_1660
	lda	$0E,x
	cmp	#$00C8
	bcc	loc_01B353
	lda	#$401D
	sta	$16,x
	stz	$1C,x
	stz	$1E,x
	lda	#$0001
	sta	$24,x
	inc	$12,x
loc_01B353:
	ldy	#$AC97
	lda	zp_E4
	bne	loc_01B35D
	ldy	#$ACA7
loc_01B35D:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	#$4E08
	phx
	jsl	f:sub_00FEA3
	plx
	rtl

sub_01B371:
	lda	$24,x
	bne	loc_01B383
	ldy	#$ACB7
	inc	$12,x
	lda	#$4D88
	pha
	lda	#$0040
	bra	loc_01B38F
loc_01B383:
	ldy	#$ACC7
	dec	$24,x
	lda	#$4E88
	pha
	lda	#$0020
loc_01B38F:
	sta	zp_08
	lda	#$0004
	sta	zp_02
	pla
	phx
	jsl	f:sub_00FEA3
	plx
	rtl

sub_01B39E:
	inc	a:wram_1660
	lda	$0A,x
	cmp	#$0028
	bcs	loc_01B3E0
	inc	$12,x
	stz	$1A,x
	stz	$04,x
	lda	#$0001
	sta	$38,x
	rtl

sub_01B3B4:
	inc	a:wram_1660
	lda	$04,x
	beq	loc_01B3C3
	lda	$0A,x
	cmp	$34,x
	bcs	loc_01B3E0
	bcc	loc_01B3CA
loc_01B3C3:
	lda	$0A,x
	cmp	#$0090
	bcc	loc_01B3E0
loc_01B3CA:
	lda	#$0100
	sta	$30,x
	lda	#$001F
	jsl	f:sub_00868F
	stz	$18,x
	stz	$1A,x
	lda	#$0007
	sta	$12,x
	rtl
loc_01B3E0:
	lda	zp_E4
	bne	loc_01B3F2
	lda	#$B600
	sta	zp_FC
	ldy	#$ACCF
	lda	#$4E88
	pha
	bra	loc_01B3FE
loc_01B3F2:
	lda	#$BF40
	sta	zp_FC
	ldy	#$ACD7
	lda	#$4E88
	pha
loc_01B3FE:
	lda	#$0020
	sta	zp_08
	lda	#$0004
	sta	zp_02
	pla
	phx
	jsl	f:sub_00FEA3
	plx
	lda	zp_FC
	sta	zp_00
	lda	#$4E08
	jsl	f:sub_00FE76
	lda	$38,x
	bne	loc_01B459
	rtl

sub_01B41F:
	lda	difficulty
	cmp	#$0004
	bcs	loc_01B428
	stz	$38,x
loc_01B428:
	lda	$30,x
	bne	loc_01B457
	lda	$04,x
	eor	#$0001
	sta	$04,x
	beq	loc_01B43F
	lda	#$0060
	sta	$34,x
	lda	#$FFFF
	bra	loc_01B442
loc_01B43F:
	lda	#$0000
loc_01B442:
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	lda	#$0006
	sta	$12,x
	lda	#$001E
	jsl	f:sub_00868F
	bra	loc_01B4D0
loc_01B457:
	dec	$30,x
loc_01B459:
	ldy	difficulty
	lda	zp_78
	and	a:data_05AC61,y
	bne	loc_01B4CC
	jsl	f:sub_019EAB
	bcs	loc_01B4CC
	lda	$0A,x
	adc	#$0002
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFC0
	sta	a:$000E,y
	lda	#$001C
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$3000
	sta	a:$0002,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
	phx
	lda	rng_lo
	and	#$0007
	asl	a
	sta	zp_00
	tax
	lda	a:data_05AC67,x
	sta	a:$001E,y
	lda	rng_hi
	and	#$0007
	asl	a
	clc
	adc	zp_00
	sta	zp_00
	tax
	lda	a:data_05AC77,x
	sta	a:$0018,y
	lda	zp_00
	and	#$000F
	tax
	lda	a:data_05AC87,x
	sta	a:$001A,y
	plx
	lda	#$001A
	jsl	f:sub_00868F
loc_01B4CC:
	lda	zp_E6
	bne	loc_01B4D5
loc_01B4D0:
	lda	#$B5A0
	bra	loc_01B4D8
loc_01B4D5:
	lda	#$B580
loc_01B4D8:
	sta	zp_00
	lda	#$4D8C
	jml	f:sub_00FE76

sub_01B4E1:
	jsl	f:sub_00FD92
	dec	$24,x
	bne	loc_01B4FB
	inc	$12,x
	lda	#$0030
	sta	$24,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	rtl
loc_01B4FB:
	lda	$0A,x
	sta	zp_00
	lda	#$00B0
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_01B520
	lda	#$FFFC
	sta	a:$001E,y
loc_01B520:
	rtl

sub_01B521:
	lda	#$0000
	sta	a:wram_13C0
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	a:wram_13BA
	lda	#$0001
	sta	a:wram_1E40
	rtl

sub_01B539:
	lda	$0E,x
	cmp	#$00C8
	bcc	loc_01B549
	stz	$1C,x
	lda	#$FFFE
	sta	$1E,x
	bra	loc_01B54D
loc_01B549:
	lda	$14,x
	beq	loc_01B555
loc_01B54D:
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_01B555:
	lda	$1E,x
	bpl	loc_01B568
	cmp	#$FFFE
	bcs	loc_01B563
	lda	#$AF96
	bra	loc_01B57F
loc_01B563:
	lda	#$AFB9
	bra	loc_01B57F
loc_01B568:
	cmp	#$0001
	bcs	loc_01B572
	lda	#$AFB4
	bra	loc_01B57F
loc_01B572:
	cmp	#$0003
	bcs	loc_01B57C
	lda	#$AFAF
	bra	loc_01B57F
loc_01B57C:
	lda	#$AFAA
loc_01B57F:
	sta	$00,x
	lda	$1E,x
	bmi	loc_01B58A
	cmp	#$0003
	bcs	loc_01B599
loc_01B58A:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01B599:
	rtl

sub_01B59A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01B5A9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01B5A9:
	.addr	sub_01B5B1
	.addr	sub_01B5E6
	.addr	sub_01B601
	.addr	sub_01B6AB

sub_01B5B1:
	inc	$12,x
	lda	#$0180
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	lda	#$0060
	sta	$28,x
	lda	#$FFC0
	sta	$2A,x
	stz	$24,x
	lda	#$0003
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#$AF1F
	lda	#$4608
	phx
	jsl	f:sub_00FEA3
	plx
	lda	#$0008
	sta	a:wram_1398
	rtl

sub_01B5E6:
	dec	$24,x
	bpl	loc_01B600
	lda	#$0100
	sta	$0A,x
	lda	#$401D
	sta	$16,x
	lda	#$1000
	sta	$24,x
	lda	#$0140
	sta	$06,x
	inc	$12,x
loc_01B600:
	rtl

sub_01B601:
	lda	$06,x
	bpl	loc_01B60F
	inc	$12,x
	stz	$16,x
	lda	#$0080
	sta	$24,x
	rtl
loc_01B60F:
	lda	$26,x
	beq	loc_01B61D
	lda	#$912A
	sta	zp_9A
	lda	#$6050
	sta	zp_98
loc_01B61D:
	lda	$24,x
	bpl	loc_01B639
	; (not executed in the CDL traces)
	lda	#$F000
	sta	$18,x
	stz	$1A,x
	lda	$0A,x
	cmp	#$0100
	bcc	loc_01B682
	lda	#$0100
	sta	$24,x
	dec	$12,x
	stz	$16,x
	rtl
loc_01B639:
	dec	$24,x
	lda	$0A,x
	cmp	#$0090
	bcs	loc_01B648
	stz	$18,x
	stz	$1A,x
	bra	loc_01B662
loc_01B648:
	lda	$1A,x
	bpl	loc_01B651
	cmp	#$FFFF
	bcc	loc_01B662
loc_01B651:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	loc_01B682
loc_01B662:
	lda	zp_78
	and	#$007F
	bne	loc_01B682
	lda	#$0000
	jsl	f:sub_01A2F0
	bcc	loc_01B682
	lda	#$0002
	sta	$1A,x
	lda	#$00A0
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
loc_01B682:
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:wram_1380
	lda	#$0003
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	zp_E4
	bne	loc_01B69E
	ldy	#$AF25
	bra	loc_01B6A1
loc_01B69E:
	ldy	#$AF2B
loc_01B6A1:
	lda	#$4688
	phx
	jsl	f:sub_00FEA3
	plx
	rtl

sub_01B6AB:
	dec	$24,x
	bpl	loc_01B6D1
	lda	#$0200
	sta	$24,x
	lda	#$8000
	sta	$16,x
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	ldy	#$946A
	lda	#$4608
	phx
	jsl	f:sub_00FEA3
	plx
	bra	loc_01B6E3
loc_01B6D1:
	lda	zp_BC
	bne	loc_01B6E3
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:wram_1380
	lda	#$C5B8
	bra	loc_01B6E9
loc_01B6E3:
	lda	#$C4CE
	stz	a:wram_1380
loc_01B6E9:
	pha
	jsl	f:sub_00FD92
	lda	$0A,x
	sta	zp_00
	lda	#$00B4
	sta	zp_02
	lda	#$001F
	sta	zp_06
	lda	#$003F
	sta	zp_04
	ldy	#$0500
	pla
	jsl	f:sub_01CF3C
	bcs	loc_01B711
	lda	#$FFF8
	sta	a:$001A,y
loc_01B711:
	rtl

sub_01B712:
	lda	$12,x
	cmp	#$0003
	beq	loc_01B723
	lda	a:wram_09C6
	beq	loc_01B74B
	cmp	#$0009
	bcs	loc_01B74B
loc_01B723:
	; (not executed in the CDL traces)
	lda	zp_C0
	bne	loc_01B74B
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_01B74B
	lda	#$FFFE
	sta	a:$001E,y
loc_01B74B:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01B75A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01B75A:
	.addr	sub_01B764
	.addr	sub_01B793
	.addr	sub_01B7B7
	.addr	sub_01B8B6
	.addr	sub_01B89C

sub_01B764:
	stz	a:wram_16AE
	lda	#$0041
	sta	$16,x
	lda	#$FFDA
	sta	$2A,x
	lda	#$0058
	sta	$28,x
	stz	$34,x
	lda	#$AF3D
	sta	$3A,x
	lda	#$0010
	sta	$06,x
	stz	$38,x
	inc	$12,x
	lda	#$0200
	sta	a:wram_1658
	stz	a:wram_165A
	stz	a:wram_165C
	rtl

sub_01B793:
	lda	a:wram_0216
	beq	loc_01B7A8
	bmi	loc_01B7A8
	ldy	#$0200
	jsr	a:sub_01B9DE
	lda	a:player1_state
	cmp	#$0009
	beq	sub_01B7B7
loc_01B7A8:
	lda	a:wram_0256
	beq	loc_01B7DD
	bmi	loc_01B7DD
	ldy	#$0240
	jsr	a:sub_01B9DE
	bra	loc_01B7DD

sub_01B7B7:
	lda	a:wram_1658
	tay
	lda	a:$1306,y
	sta	$1A,x
	clc
	lda	a:$000A,y
	adc	#$FFD8
	sta	$0A,x
	tya
	eor	#$0040
	tay
	lda	a:$0016,y
	beq	loc_01B7DD
	bmi	loc_01B7DD
	lda	$34,x
	sta	zp_0C
	jsl	f:sub_019F37
loc_01B7DD:
	lda	$34,x
	asl	a
	tay
	lda	a:data_05AF31,y
	sta	zp_02
	lda	a:data_05AF37,y
	sta	zp_00
	lda	#$0080
	sta	zp_04
	ldy	#$0280
loc_01B7F3:
	lda	a:$0016,y
	bit	#$0800
	beq	loc_01B83E
	jsr	a:sub_01BA47
	lda	zp_0E
	beq	loc_01B83E
	bit	#$1000
	beq	loc_01B83E
	lda	a:$0010,y
	cmp	#$002D
	beq	loc_01B81A
	lda	#$0200
	sta	a:$003C,y
	dec	a:wram_09C6
	bne	loc_01B829
loc_01B81A:
	; (not executed in the CDL traces)
	stz	a:wram_09C6
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x
	bra	loc_01B831
loc_01B829:
	lda	a:wram_09C6
	cmp	#$0008
	bne	loc_01B83E
loc_01B831:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	a:wram_165A
	lda	#$AF49
	sta	$3A,x
	bra	loc_01B849
loc_01B83E:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B7F3
loc_01B849:
	sec
	lda	#$0168
	sbc	$0A,x
	sta	f:wram_7E3807
	lda	a:wram_165C
	bne	loc_01B85E
	lda	a:wram_165A
	bne	loc_01B861
	rtl
loc_01B85E:
	inc	a:wram_1660
loc_01B861:
	lda	zp_BE
	bne	loc_01B89B
	lda	#$0003
	sta	zp_02
	lda	a:wram_165A
	beq	loc_01B87F
	; (not executed in the CDL traces)
	stz	a:wram_165A
	lda	#$0030
	sta	zp_08
	lda	#$4E8C
	ldy	#$AF55
	bra	loc_01B895
loc_01B87F:
	ldy	$3A,x
	lda	zp_E6
	bne	loc_01B88D
	clc
	lda	a:$003A,x
	adc	#$0006
	tay
loc_01B88D:
	lda	#$0018
	sta	zp_08
	lda	#$4F0C
loc_01B895:
	phx
	jsl	f:sub_00FEA3
	plx
loc_01B89B:
	rtl

sub_01B89C:
	lda	a:wram_13FA
	cmp	#$0002
	bne	loc_01B8B5
	lda	#$0000
	sta	f:wram_7E3807
	stz	a:wram_13C0
	stz	zp_46
	lda	#$8000
	sta	$16,x
loc_01B8B5:
	rtl

sub_01B8B6:
	; (not executed in the CDL traces)
	dec	$24,x
	beq	loc_01B8C6
	lda	$0A,x
	cmp	#$FF80
	bcs	loc_01B8D5
	cmp	#$FF00
	bcc	loc_01B8D5
loc_01B8C6:
	lda	#$0004
	sta	$12,x
	stz	$16,x
	lda	#$0000
	sta	f:wram_7E3807
	rtl
loc_01B8D5:
	lda	a:wram_165A
	bne	loc_01B861
	lda	zp_BC
	bne	loc_01B8FA
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0280
	lda	#$C5DC
	jsl	f:sub_01CF3C
loc_01B8FA:
	jsr	a:sub_01B993
	lda	$24,x
	cmp	#$0060
	bcs	loc_01B90D
	lda	zp_BC
	bne	loc_01B90D
	sta	f:wram_7E3807
	rtl
loc_01B90D:
	sec
	lda	#$0168
	sbc	$0A,x
	sta	f:wram_7E3807
	rtl

sub_01B918:
	lda	#$007F
	sta	f:wram_7E3800
	lda	#$1C00
	sta	f:wram_7E3802
	lda	#$0000
	sta	f:wram_7E3804
	lda	#$007F
	sta	f:wram_7E3806
	lda	#$0000
	sta	f:wram_7E3808
	lda	#$0000
	sta	f:wram_7E380A
	rtl

sub_01B943:
	lda	#$0080
	sta	zp_04
	lda	#$0200
	sta	zp_02
	lda	#$0400
	sta	zp_00
	ldy	#$0280
	rts

sub_01B956:
	lda	a:wram_0216
	beq	loc_01B966
	ldy	#$0200
	stz	zp_0C
	jsl	f:sub_019F37
	beq	loc_01B974
loc_01B966:
	lda	a:wram_0256
	beq	loc_01B974
	ldy	#$0240
	stz	zp_0C
	jsl	f:sub_019F37
loc_01B974:
	jsr	a:sub_01B943
loc_01B977:
	lda	a:$0010,y
	cmp	#$000A
	beq	loc_01B984
	cmp	#$001E
	bne	loc_01B987
loc_01B984:
	jsr	a:sub_01BA47
loc_01B987:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B977
	rtl

sub_01B993:
	; (not executed in the CDL traces)
	lda	a:wram_0216
	beq	loc_01B9A5
	bmi	loc_01B9A5
	ldy	#$0200
	stz	zp_0C
	jsl	f:sub_019F37
	beq	loc_01B9B5
loc_01B9A5:
	lda	a:wram_0256
	beq	loc_01B9B5
	bmi	loc_01B9B5
	ldy	#$0240
	stz	zp_0C
	jsl	f:sub_019F37
loc_01B9B5:
	jsr	a:sub_01B943
loc_01B9B8:
	lda	a:$0016,y
	bit	#$0800
	beq	loc_01B9D2
	jsr	a:sub_01BA47
	lda	zp_0E
	beq	loc_01B9D2
	bit	#$1000
	beq	loc_01B9D2
	lda	#$0200
	sta	a:$003C,y
loc_01B9D2:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B9B8
	rts

sub_01B9DE:
	lda	$34,x
	sta	zp_0C
	jsl	f:sub_019F37
	lda	a:$003C,y
	bit	#$0080
	beq	loc_01BA08
	clc
	lda	$0A,x
	adc	#$0020
	bmi	loc_01BA08
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	loc_01BA08
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	loc_01BA1C
loc_01BA08:
	lda	$0A,x
	cmp	#$FF80
	bcs	loc_01BA1B
	cmp	#$FF00
	bcc	loc_01BA1B
	lda	#$0004
	sta	$12,x
	stz	$16,x
loc_01BA1B:
	rts
loc_01BA1C:
	sty	a:wram_1658
	lda	$0A,x
	clc
	adc	#$0028
	sta	a:$000A,y
	lda	#$0009
	sta	a:$0012,y
	inc	$12,x
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001A,y
	sta	a:$0024,y
	lda	a:$0016,y
	ora	#$0002
	sta	a:$0016,y
	rts
loc_01BA46:
	rts

sub_01BA47:
	stz	zp_0E
	clc
	lda	$0A,x
	adc	$28,x
	sec
	sbc	a:$000A,y
	bmi	loc_01BA46
	sta	zp_10
	clc
	lda	a:$000A,y
	adc	a:$0028,y
	sec
	sbc	$0A,x
	bmi	loc_01BA46
	sta	zp_12
	clc
	lda	$0E,x
	adc	$2A,x
	sec
	sbc	a:$000E,y
	bpl	loc_01BA46
	eor	#$FFFF
	inc	a
	sta	zp_14
	clc
	lda	a:$000E,y
	adc	a:$002A,y
	sec
	sbc	$0E,x
	bpl	loc_01BA46
	eor	#$FFFF
	inc	a
	sta	zp_16
	lda	a:$0016,y
	sta	zp_0E
	lda	zp_10
	cmp	zp_12
	bcc	loc_01BA94
	lda	zp_12
loc_01BA94:
	sta	zp_08
	lda	zp_14
	cmp	zp_16
	bcc	loc_01BA9E
	lda	zp_16
loc_01BA9E:
	sta	zp_0A
	lda	zp_0A
	cmp	zp_08
	bcs	loc_01BAC3
	lda	zp_14
	cmp	zp_16
	bcs	loc_01BAC2
	; (not executed in the CDL traces)
	lda	a:$001E,y
	bmi	loc_01BAC1
	clc
	lda	$0E,x
	adc	$2A,x
	sta	a:$000E,y
	lda	zp_04
	ora	a:$003E,y
	sta	a:$003E,y
loc_01BAC1:
	rts
loc_01BAC2:
	rts
loc_01BAC3:
	lda	zp_10
	cmp	zp_12
	bcs	loc_01BADA
	clc
	lda	$0A,x
	adc	$28,x
	sta	a:$000A,y
	lda	zp_02
	ora	a:$003E,y
	sta	a:$003E,y
	rts
loc_01BADA:
	sec
	lda	$0A,x
	sbc	a:$0028,y
	sta	a:$000A,y
	lda	zp_00
	ora	a:$003E,y
	sta	a:$003E,y
	rts

sub_01BAEC:
	lda	$30,x
	bmi	loc_01BAF4
	lda	$06,x
	bpl	loc_01BAFF
loc_01BAF4:
	stz	$06,x
	lda	#$001B
	sta	$10,x
	jml	f:loc_01D201
loc_01BAFF:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01BB0E,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01BB0E:
	.addr	sub_01BB79
	.addr	sub_01BBCA
	.addr	sub_01BBA6
	.addr	sub_01BC08
	.addr	sub_01BD71
	.addr	sub_01BD8D

sub_01BB1A:
	stz	$1C,x
	stz	$1E,x
	lda	#$0008
	sta	$24,x

sub_01BB23:
	lda	$0A,x
	cmp	#$0080
	bcc	loc_01BB3A
	lda	#$0002
	sta	$04,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
	rts
loc_01BB3A:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$1A,x
	lda	#$A800
	sta	$18,x
	rts
loc_01BB45:
	jsr	a:sub_01BB1A
	bra	loc_01BB68

sub_01BB4A:
	lda	#$000C
	sta	$24,x
	lda	#$0003
	sta	$12,x
	jsr	a:sub_01BB23
	jsl	f:sub_01BB79
	lda	#$0068
	sta	$0E,x
	rtl

sub_01BB61:
	lda	rng_lo
	and	#$003F
	sta	$24,x
loc_01BB68:
	ldy	difficulty
	lda	a:data_05AFE4,y
	sta	$06,x
	lda	#$0001
	sta	$12,x
	lda	#$3600
	bra	loc_01BB7E

sub_01BB79:
	stz	$06,x
	lda	#$3400
loc_01BB7E:
	sta	$02,x
	lda	#$000A
	sta	$10,x
	lda	#$00C8
	sta	$0E,x
	lda	#$081F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	inc	$12,x
	lda	#$AF9C
	sta	$20,x
	lda	#$0003
	sta	$30,x
	rtl

sub_01BBA6:
	lda	$0A,x
	cmp	#$0020
	bcc	sub_01BBCA
	cmp	#$00D0
	bcs	sub_01BBCA
	dec	$24,x
	bpl	sub_01BBCA
	lda	#$0006
	sta	$24,x
	lda	$3E,x
	bne	loc_01BBCE
	lda	#$AFB6
	sta	$20,x
	stz	$18,x
	stz	$1A,x
	inc	$12,x

sub_01BBCA:
	lda	$3E,x
	beq	loc_01BC07
loc_01BBCE:
	bit	#$0004
	beq	loc_01BBD6
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BBD6:
	dec	$30,x
	stz	$3E,x
	stz	$22,x
	bit	#$0200
	beq	loc_01BBF1
	inc	$0A,x
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800
	sta	$18,x
	bra	loc_01BC07
loc_01BBF1:
	bit	#$0400
	beq	loc_01BC07
	dec	$0A,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
	lda	#$0002
	sta	$04,x
loc_01BC07:
	rtl

sub_01BC08:
	lda	$3E,x
	beq	loc_01BC0F
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BC0F:
	lda	$20,x
	bne	loc_01BC46
	lda	#$0001
	sta	$12,x
	lda	#$AF9C
	sta	$20,x
	lda	#$7000
	sta	$24,x
	lda	$0A,x
	cmp	#$0080
	bcs	loc_01BC39
	lda	#$0002
	sta	$04,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
	rtl
loc_01BC39:
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800
	sta	$18,x
	rtl
loc_01BC46:
	dec	$24,x
	bne	loc_01BC6E
	lda	$0E,x
	adc	#$FFEA
	sta	zp_02
	lda	$04,x
	bne	loc_01BC63
	lda	$0A,x
	adc	#$0008
	sta	zp_00
	lda	#$0010
	jml	f:sub_01A11C
loc_01BC63:
	lda	$0A,x
	sta	zp_00
	lda	#$0030
	jml	f:sub_01A11C
loc_01BC6E:
	rtl

sub_01BC6F:
	lda	$06,x
	bpl	loc_01BC76
	brl	loc_01BAF4
loc_01BC76:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01BC85,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01BC85:
	.addr	sub_01BC8F
	.addr	sub_01BCA5
	.addr	sub_01BCAF
	.addr	sub_01BD3C
	.addr	sub_01BD51

sub_01BC8F:
	lda	#$AFCE
	sta	$32,x
	lda	#$0001
	sta	$16,x
	sta	$34,x
	ldy	difficulty
	lda	a:data_05AFE4,y
	sta	$06,x
	inc	$12,x
	rtl

sub_01BCA5:
	lda	$0A,x
	cmp	#$00D0
	bcs	loc_01BCAE
	inc	$12,x
loc_01BCAE:
	rtl

sub_01BCAF:
	lda	$34,x
	bne	loc_01BD30
	lda	#$0003
	sta	$16,x
	lda	#$FFFD
	sta	$1E,x
	lda	#$B1C1
	sta	$00,x
	lda	#$3600
	sta	$02,x
	lda	$0A,x
	sta	zp_10
	phx
	ldx	#$000A
	ldy	#$0300
loc_01BCD2:
	jsl	f:sub_019EAE
	bcc	loc_01BCED
loc_01BCD8:
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bpl	loc_01BCD2
	plx
	lda	#$001B
	jsl	f:sub_00868F
	inc	$12,x
	rtl
loc_01BCED:
	lda	#$0010
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	a:data_05AF6C,x
	adc	zp_10
	sta	a:$000A,y
	lda	a:data_05AF78,x
	sta	a:$000E,y
	lda	a:data_05AF90,x
	sta	a:$001A,y
	lda	a:data_05AF84,x
	sta	a:$0018,y
	lda	#$0020
	sta	a:$0024,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$FFFE
	sta	a:$0030,y
	lda	#$B1EB
	sta	a:$0000,y
	sta	a:$0032,y
	bra	loc_01BCD8
loc_01BD30:
	lda	zp_BE
	cmp	#$0003
	bne	loc_01BD3B
	jsl	f:sub_01C302
loc_01BD3B:
	rtl

sub_01BD3C:
	lda	$1E,x
	bmi	loc_01BD62
	lda	#$081F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	inc	$12,x

sub_01BD51:
	lda	$3E,x
	beq	loc_01BD58
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BD58:
	lda	#$00C8
	cmp	$0E,x
	bcs	loc_01BD62
	brl	loc_01BB45
loc_01BD62:
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_01BD71:
	dec	$24,x
	bpl	loc_01BD8C
	stz	$22,x
	stz	$20,x
	lda	#$FFFE
	sta	$1E,x
	inc	$12,x
	ldy	#$B16D
	lda	$04,x
	beq	loc_01BD8A
	ldy	#$B427
loc_01BD8A:
	sty	$00,x
loc_01BD8C:
	rtl

sub_01BD8D:
	lda	#$00C8
	cmp	$0E,x
	bcs	loc_01BDA5
	sta	$0E,x
	lda	#$0001
	sta	$12,x
	lda	#$AF9C
	sta	$20,x
	stz	$1E,x
	stz	$1C,x
	rtl
loc_01BDA5:
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_01BDB4:
	lda	$12,x
	bne	loc_01BDC4
	lda	#$0040
	sta	$32,x
	lda	#$0080
	sta	$34,x
	inc	$12,x
loc_01BDC4:
	dec	$32,x
	bne	loc_01BE16
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:data_05AFD2,y
	sta	$32,x
	ldy	#$0900
loc_01BDD7:
	lda	a:$0016,y
	bit	#$0040
	beq	loc_01BDEA
	lda	a:$000A,y
	adc	a:$0028,y
	cmp	#$00F8
	bcs	loc_01BE16
loc_01BDEA:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	loc_01BDD7
	ldy	#$0300
	jsl	f:sub_019EAE
	bcs	loc_01BE71
	phx
	tyx
	lda	#$0110
	sta	$0A,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
	lda	#$0002
	sta	$04,x
	bra	loc_01BE60
loc_01BE16:
	dec	$34,x
	bne	loc_01BE71
	ldy	difficulty
	lda	rng_hi
	and	#$00FF
	adc	a:data_05AFD8,y
	sta	$34,x
	ldy	#$0900
loc_01BE29:
	lda	a:$0016,y
	bit	#$0040
	beq	loc_01BE3B
	lda	a:$000A,y
	bmi	loc_01BE71
	cmp	#$0008
	bcc	loc_01BE71
loc_01BE3B:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	loc_01BE29
	ldy	#$0300
	jsl	f:sub_019EAE
	bcs	loc_01BE71
	phx
	tyx
	lda	#$FFF0
	sta	$0A,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800
	sta	$18,x
loc_01BE60:
	ldy	difficulty
	lda	rng_lo
	and	#$000F
	cmp	a:data_05AFDE,y
	bcs	loc_01BE72
	jsl	f:sub_01BB61
	plx
loc_01BE71:
	rtl
loc_01BE72:
	jsl	f:sub_01BB79
	plx
	rtl

sub_01BE78:
	lda	a:wram_1688
	bne	loc_01BE83
	lda	$06,x
	bpl	loc_01BE98
	bmi	loc_01BE8C
loc_01BE83:
	lda	$02,x
	bne	loc_01BE8C
	; (not executed in the CDL traces)
	lda	#$3800
	sta	$02,x
loc_01BE8C:
	lda	#$001B
	sta	$10,x
	lda	#$C7EA
	jml	f:loc_01D1FD
loc_01BE98:
	ldy	$30,x
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01BEA9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01BEA9:
	.addr	sub_01BEB1
	.addr	sub_01BEF5
	.addr	sub_01BF53
	.addr	sub_01BF67

sub_01BEB1:
	inc	$12,x
	lda	#$C5CF
	sta	$00,x
	lda	#$3600
	cpy	difficulty
	beq	loc_01BEC4
	bcc	loc_01BEC4
	lda	#$3800
loc_01BEC4:
	sta	$02,x
	lda	#$0003
	sta	$16,x
	lda	difficulty
	inc	a
	asl	a
	sta	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE1
	sta	$2A,x
	lda	#$00F0
	sta	$0E,x
	stz	$32,x
	stz	$34,x
	lda	a:data_05AFEA,y
	sta	$1E,x
	lda	a:data_05AFF0,y
	sta	$0A,x
	lda	#$0015
	jml	f:sub_00868F

sub_01BEF5:
	clc
	lda	$18,x
	adc	#$2000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	lda	$1E,x
	bmi	loc_01BF16
	inc	$12,x
	lda	#$0013
	sta	$16,x
	lda	#$B002
	sta	$20,x
	stz	$22,x
loc_01BF16:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	zp_BC
	bne	loc_01BF52
	ldy	#$0700
	jsl	f:sub_019EC1
	bcc	loc_01BF52
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	$0E,x
	adc	#$FFEC
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$FFF8
	sta	a:$001A,y
	lda	#$0002
	sta	a:$001E,y
loc_01BF52:
	rtl

sub_01BF53:
	sec
	lda	$18,x
	sbc	#$6000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bpl	loc_01BF66
	inc	$12,x
loc_01BF66:
	rtl

sub_01BF67:
	stz	zp_00
	stz	zp_02
	lda	$1E,x
	bpl	loc_01BF80
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	loc_01BFA6
loc_01BF80:
	lda	#$3000
	sta	$1C,x
	lda	$32,x
	bne	loc_01BFA4
	lda	$0E,x
	cmp	a:data_05AFF6,y
	bcc	loc_01BFA6
	lda	#$FFFD
	sta	$1E,x
	lda	#$0004
	sta	zp_00
	lda	rng_hi
	and	#$003F
	adc	#$0010
	sta	$32,x
loc_01BFA4:
	dec	$32,x
loc_01BFA6:
	sec
	lda	$18,x
	sbc	#$1000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	bpl	loc_01BFCD
	cmp	#$FFFC
	bcs	loc_01BFCD
	lda	#$FFFC
	sta	zp_02
	lda	rng_lo
	sta	$18,x
	lda	#$AFFC
	sta	$20,x
	stz	$22,x
	lda	#$0003
loc_01BFCD:
	sta	$1A,x
	lda	zp_02
	ora	zp_00
	beq	loc_01BFFF
	ldy	#$0500
	jsl	f:sub_019EC1
	bcc	loc_01BFFF
	lda	#$C61E
	jsl	f:sub_01CF66
	lda	zp_02
	sta	a:$001A,y
	lda	zp_00
	sta	a:$001E,y
	lda	$0A,x
	adc	#$FFF8
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFE8
	sta	a:$000E,y
loc_01BFFF:
	lda	difficulty
	cmp	$30,x
	bcc	loc_01C03B
	lda	$34,x
	bpl	loc_01C039
	lda	$0A,x
	cmp	#$0050
	bcc	loc_01C01C
	lda	$00,x
	cmp	#$C80C
	bne	loc_01C03B
	lda	#$0028
	bra	loc_01C026
loc_01C01C:
	lda	$00,x
	cmp	#$C5F1
	bne	loc_01C03B
	lda	#$0020
loc_01C026:
	pha
	lda	#$0040
	sta	$34,x
	lda	$0E,x
	sta	zp_02
	lda	$0A,x
	sta	zp_00
	pla
	jml	f:sub_01A11C
loc_01C039:
	dec	$34,x
loc_01C03B:
	rtl

sub_01C03C:
	lda	a:wram_1688
	bne	loc_01C045
	lda	$06,x
	bpl	loc_01C061
loc_01C045:
	lda	$34,x
	beq	loc_01C055
	lda	#$0004
	sta	a:wram_1688
	inc	a:wram_0964
	inc	a:wram_0964
loc_01C055:
	lda	#$001B
	sta	$10,x
	lda	#$C7EA
	jml	f:loc_01D1F2
loc_01C061:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01C070,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C070:
	.addr	sub_01C080
	.addr	sub_01C0F5
	.addr	sub_01C09F
	.addr	sub_01C164
	.addr	sub_01C184
	.addr	sub_01C1B6
	.addr	sub_01C1EC
	.addr	sub_01C21D

sub_01C080:
	jsl	f:sub_01C164
	lda	#$0600
	sta	$02,x
	lda	#$0080
	sta	$06,x
	lda	#$0018
	sta	$0A,x
	stz	$30,x
	stz	$32,x
	lda	#$0010
	sta	$36,x
	inc	$34,x
	rtl

sub_01C09F:
	sec
	lda	#$0080
	sbc	a:wram_1398
	sta	$0E,x
	lda	rng_hi
	bit	#$0007
	bne	loc_01C0BF
	dec	$12,x
	lda	#$FFFC
	sta	$1E,x
	stz	$20,x
	stz	$22,x
	lda	#$C697
	sta	$00,x
loc_01C0BF:
	lda	$30,x
	bne	loc_01C0DD
	lda	$1A,x
	bpl	loc_01C0CC
	cmp	#$FFFD
	bcc	sub_01C0F5
loc_01C0CC:
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	sub_01C0F5
loc_01C0DD:
	lda	$1A,x
	bmi	loc_01C0E6
	cmp	#$0003
	bcs	sub_01C0F5
loc_01C0E6:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x

sub_01C0F5:
	lda	$0A,x
	cmp	#$00E0
	bcc	loc_01C102
	lda	$1A,x
	bpl	loc_01C111
	bmi	loc_01C10B
loc_01C102:
	cmp	#$0010
	bcs	loc_01C10B
	lda	$1A,x
	bmi	loc_01C111
loc_01C10B:
	dec	$32,x
	bpl	loc_01C12E
	bra	loc_01C11D
loc_01C111:
	eor	#$FFFF
	sta	$1A,x
	lda	$18,x
	eor	#$FFFF
	sta	$18,x
loc_01C11D:
	lda	rng_lo
	and	#$003F
	adc	#$0010
	sta	$32,x
	lda	$30,x
	eor	#$0002
	sta	$30,x
loc_01C12E:
	dec	$36,x
	bpl	loc_01C162
	ldy	difficulty
	lda	rng_lo
	and	#$001F
	adc	a:data_05B028,y
	sta	$36,x
	phx
	ldx	#$06C0
	jsl	f:sub_019ED4
	bcc	loc_01C161
	jsl	f:sub_01C166
	lda	#$007E
	sta	$10,x
	lda	#$0004
	sta	$12,x
	lda	rng_lo
	and	#$0006
	tay
	lda	a:data_05B02E,y
	sta	$0A,x
loc_01C161:
	plx
loc_01C162:
	bra	sub_01C184

sub_01C164:
	inc	$12,x

sub_01C166:
	lda	#$0001
	sta	$16,x
	lda	#$C697
	sta	$00,x
	lda	#$0800
	sta	$02,x
	stz	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFD8
	sta	$2A,x
	stz	$34,x
	rtl

sub_01C184:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	sec
	lda	#$0080
	sbc	a:wram_1398
	cmp	$0E,x
	bcs	loc_01C1B5
	lda	#$401F
	sta	$16,x
	lda	$02,x
	ora	#$3000
	sta	$02,x
	lda	#$B01A
	sta	$20,x
	inc	$12,x
	stz	$1C,x
	stz	$1E,x
loc_01C1B5:
	rtl

sub_01C1B6:
	sec
	lda	#$0080
	sbc	a:wram_1398
	sta	$0E,x
	lda	#$0080
	jsl	f:sub_01A15D
	sec
	lda	$0A,x
	sbc	a:$1312,y
	bpl	loc_01C1D6
	ldy	#$0002
	eor	#$FFFF
	bra	loc_01C1D9
loc_01C1D6:
	ldy	#$FFFE
loc_01C1D9:
	cmp	#$0030
	bcs	loc_01C1E9
	inc	$12,x
	stz	$20,x
	stz	$22,x
	lda	#$C697
	sta	$00,x
loc_01C1E9:
	sty	$1A,x
	rtl

sub_01C1EC:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	$0E,x
	cmp	#$00B0
	bcc	loc_01C21C
	lda	#$0003
	sta	$16,x
	inc	$12,x
	lda	#$B01A
	sta	$20,x
	lda	#$0002
	sta	$04,x
	stz	$1C,x
	stz	$1E,x
	lda	#$FFF8
	sta	$1A,x
loc_01C21C:
	rtl

sub_01C21D:
	rtl

sub_01C21E:
	lda	$3E,x
	bne	loc_01C226
	lda	$06,x
	bpl	loc_01C24A
loc_01C226:
	lda	#$0030
	jsl	f:sub_00868F
	stz	$3E,x
	stz	$06,x
	lda	#$B056
	sta	$32,x
	lda	#$0001
	sta	$34,x
	lda	#$0003
	sta	$16,x
	lda	#$0005
	sta	$12,x
	lda	#$0020
	sta	$24,x
loc_01C24A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01C259,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C259:
	.addr	sub_01C265
	.addr	sub_01C27C
	.addr	sub_01C28B
	.addr	sub_01C2B0
	.addr	sub_01C2BC
	.addr	sub_01C31C

sub_01C265:
	lda	#$0003
	sta	$16,x
	lda	#$0020
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	#$0010
	sta	$06,x
	inc	$12,x
	rtl

sub_01C27C:
	lda	$0A,x
	cmp	#$00E8
	bcs	loc_01C28A
	lda	#$B046
	sta	$32,x
	inc	$12,x
loc_01C28A:
	rtl

sub_01C28B:
	lda	zp_C0
	cmp	#$0001
	bne	loc_01C2AF
	jsl	f:sub_01C302
	lda	$32,x
	clc
	adc	#$0004
	sta	$32,x
	cmp	#$B052
	bcc	loc_01C2AF
	lda	#$481F
	sta	$16,x
	inc	$12,x
	lda	#$0010
	sta	$24,x
loc_01C2AF:
	rtl

sub_01C2B0:
	dec	$24,x
	bne	loc_01C2BB
	lda	#$0021
	sta	$24,x
	inc	$12,x
loc_01C2BB:
	rtl

sub_01C2BC:
	dec	$24,x
	bne	loc_01C2C8
	lda	#$0080
	sta	$24,x
	dec	$12,x
	rtl
loc_01C2C8:
	lda	$24,x
	cmp	#$0020
	beq	loc_01C2E1
	cmp	#$0010
	beq	loc_01C2E1
	lda	$34,x
	bne	sub_01C2FB
	inc	$34,x
	lda	#$B04E
	sta	$32,x
	bra	sub_01C2FB
loc_01C2E1:
	lda	$0A,x
	sta	zp_00
	lda	#$00B8
	sta	zp_02
	lda	#$0030
	jsl	f:sub_01A11C
	lda	#$0001
	sta	$34,x
	lda	#$B052
	sta	$32,x

sub_01C2FB:
	lda	zp_BE
	cmp	#$0001
	bne	loc_01C31B

sub_01C302:
	lda	#$0001
	sta	zp_02
	lda	#$0010
	sta	zp_08
	ldy	$3A,x
	lda	a:data_05B036,y
	ldy	$32,x
	phx
	jsl	f:sub_00FEA3
	plx
	stz	$34,x
loc_01C31B:
	rtl

sub_01C31C:
	lda	$34,x
	beq	loc_01C324
	jsl	f:sub_01C2FB
loc_01C324:
	dec	$24,x
	bne	loc_01C32E
	lda	#$8000
	sta	$16,x
	rtl
loc_01C32E:
	lda	zp_C0
	bne	loc_01C354
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF25
	bcs	loc_01C354
	lda	rng_hi
	and	#$001F
	adc	$0A,x
	sta	a:$000A,y
	lda	#$00C8
	sta	a:$000E,y
	lda	#$FFFF
	sta	a:$001E,y
loc_01C354:
	rtl

sub_01C355:
	inc	$34,x
	lda	$06,x
	bpl	loc_01C385
	lda	#$0030
	jsl	f:sub_00868F
	stz	$04,x
	txy
	lda	#$C516
	jsl	f:sub_01CF66
	lda	$0A,x
	adc	#$0008
	sta	$0A,x
	lda	$0E,x
	adc	#$FFF8
	sta	$0E,x
	lda	#$69C0
	sta	zp_00
	lda	$3A,x
	jml	f:sub_00FE76
loc_01C385:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01C394,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C394:
	.addr	sub_01C3A0
	.addr	sub_01C3D0
	.addr	sub_01C3F1
	.addr	sub_01C424
	.addr	sub_01C3F1
	.addr	sub_01C4C8

sub_01C3A0:
	inc	$12,x
	ldy	difficulty
	lda	a:data_05B05A,y
	sta	$06,x
	lda	#$0003
	sta	$16,x
	lda	#$FFE0
	sta	$2A,x
	lda	#$0020
	sta	$28,x
	lda	#$0015
	sta	$24,x
	lda	a:wram_1380
	and	#$0100
	asl	a
	asl	a
	clc
	adc	$3A,x
	and	#$F7FF
	sta	$3A,x
	stz	$30,x
	rtl

sub_01C3D0:
	lda	a:wram_13BA
	cmp	#$0003
	bne	loc_01C3E2
	lda	$0E,x
	bmi	loc_01C3F0
	cmp	#$0020
	bcs	loc_01C3EE
	rtl
loc_01C3E2:
	cmp	#$0001
	bne	loc_01C3F0
	lda	$0A,x
	cmp	#$00E0
	bcs	loc_01C3F0
loc_01C3EE:
	inc	$12,x
loc_01C3F0:
	rtl

sub_01C3F1:
	dec	$24,x
	lda	$24,x
	bpl	loc_01C404
	inc	$12,x
	lda	#$0030
	sta	$34,x
	lda	#$4013
	sta	$16,x
	rtl
loc_01C404:
	bit	#$0007
	bne	loc_01C423
	lsr	a
	lsr	a
	tay
	lda	$12,x
	cmp	#$0002
	beq	loc_01C418
	lda	a:data_05B060,y
	bra	loc_01C41B
loc_01C418:
	lda	a:data_05B074,y
loc_01C41B:
	sta	zp_00
	lda	$3A,x
	jsl	f:sub_00FE76
loc_01C423:
	rtl

sub_01C424:
	lda	a:wram_13BA
	cmp	#$0003
	bne	loc_01C435
	lda	$0E,x
	cmp	#$00C0
	bcc	loc_01C44E
	bcs	loc_01C441
loc_01C435:
	cmp	#$0001
	bne	loc_01C44E
	lda	$0A,x
	cmp	#$0020
	bcs	loc_01C44E
loc_01C441:
	lda	#$0015
	sta	$24,x
	lda	#$0003
	sta	$16,x
	inc	$12,x
	rtl
loc_01C44E:
	ldy	difficulty
	lda	zp_78
	and	a:data_05B09A,y
	bne	loc_01C48F
	lda	#$0800
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	lsr	a
	lsr	a
	and	#$003E
	sec
	sbc	$30,x
	bmi	loc_01C47C
	cmp	#$001E
	bcs	loc_01C486
	cmp	#$0002
	bcc	loc_01C48F
loc_01C476:
	lda	$30,x
	inc	a
	inc	a
	bra	loc_01C48A
loc_01C47C:
	cmp	#$FFE2
	bcc	loc_01C476
	cmp	#$FFFE
	bcs	loc_01C48F
loc_01C486:
	lda	$30,x
	dec	a
	dec	a
loc_01C48A:
	and	#$003E
	sta	$30,x
loc_01C48F:
	lda	$30,x
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:data_05B064,y
	sta	zp_00
	lda	$3A,x
	sty	zp_FE
	jsl	f:sub_00FE76
	lda	$34,x
	and	#$007F
	bne	loc_01C4C7
	ldy	zp_FE
	clc
	lda	$0A,x
	adc	a:data_05B07A,y
	sta	zp_00
	clc
	lda	$0E,x
	adc	a:data_05B08A,y
	sta	zp_02
	lda	$30,x
	jsl	f:sub_01A11C
loc_01C4C7:
	rtl

sub_01C4C8:
	lda	#$8000
	sta	$16,x
	rtl

sub_01C4CE:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01C4DD,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C4DD:
	.addr	sub_01C4E9
	.addr	sub_01C4FB
	.addr	sub_01C5E1
	.addr	sub_01C5F9
	.addr	sub_01C629
	.addr	sub_01C637

sub_01C4E9:
	lda	#$0041
	sta	$16,x
	lda	#$0060
	sta	$28,x
	lda	#$FF10
	sta	$2A,x
	inc	$12,x
loc_01C4FA:
	rtl

sub_01C4FB:
	jsl	f:sub_01B956
	lda	a:wram_13BA
	cmp	#$0004
	bne	loc_01C4FA
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	#$0000
	lda	#$2002
loc_01C515:
	sta	a:$4670,y
	iny
	iny
	cpy	#$0010
	bcc	loc_01C515
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	inc	$12,x
	lda	#$0014
	sta	a:wram_08D0
	lda	#$4010
	sta	a:wram_08D6
	sta	a:wram_0856
	sta	a:wram_0896
	lda	#$00C0
	sta	a:wram_08CA
	lda	#$00B0
	sta	a:wram_08CE
	lda	#$0010
	sta	a:wram_08E8
	sta	a:wram_0868
	sta	a:wram_08A8
	lda	#$FFF0
	sta	a:wram_08EA
	sta	a:wram_086A
	sta	a:wram_08AA
	lda	#$0040
	sta	a:wram_08C6
	lda	#$0015
	sta	a:wram_0850
	sta	a:wram_0890
	lda	#$00A8
	sta	a:wram_084A
	lda	#$00C8
	sta	a:wram_088A
	lda	#$0080
	sta	a:wram_084E
	sta	a:wram_088E
	lda	#$0028
	sta	a:wram_0846
	sta	a:wram_0886
	lda	#$4194
	sta	a:wram_0870
	lda	#$4198
	sta	a:wram_08B0
	lda	#$7480
	sta	a:wram_0872
	lda	#$7560
	sta	a:wram_0874
	lda	#$7600
	sta	a:wram_0876
	lda	#$74A0
	sta	a:wram_08B2
	lda	#$75E0
	sta	a:wram_08B4
	lda	#$7620
	sta	a:wram_08B6
	lda	#$0000
	sta	a:wram_0864
	lda	#$0018
	sta	a:wram_08A4
	stz	a:wram_08C0
	stz	a:wram_0840
	stz	a:wram_0880
	stz	a:wram_08E0
	stz	a:wram_0860
	stz	a:wram_08A0
	stz	a:wram_0852
	stz	a:wram_0892
	rtl

sub_01C5E1:
	jsl	f:sub_01B956
	lda	a:wram_08C6
	bpl	loc_01C5F8
	lda	#$8000
	sta	a:wram_08D6
	sta	a:wram_0856
	sta	a:wram_0896
	inc	$12,x
loc_01C5F8:
	rtl

sub_01C5F9:
	jsl	f:sub_01B956
	lda	#$B0A0
	sta	$30,x
	lda	#$0044
	jsl	f:sub_00868F
	inc	$12,x
	ldy	#$0300
loc_01C60E:
	lda	a:$0010,y
	cmp	#$0017
	beq	loc_01C622
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0740
	bcc	loc_01C60E
	rtl
loc_01C622:
	; (not executed in the CDL traces)
	lda	#$FFFF
	sta	a:$0006,y
	rtl

sub_01C629:
	jsl	f:sub_01B956
	lda	zp_78
	and	#$000F
	bne	loc_01C636
	inc	$12,x
loc_01C636:
	rtl

sub_01C637:
	lda	#$0004
	sta	a:wram_1662
	jsl	f:sub_01B956
	lda	zp_BC
	bne	loc_01C66B
	lda	#$00A0
	sta	zp_00
	lda	#$00D8
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF3C
	bcs	loc_01C66B
	lda	#$FFFD
	sta	a:$001E,y
loc_01C66B:
	stx	zp_FA
	lda	#$0030
	sta	zp_08
	lda	zp_78
	and	#$000F
	cmp	#$0004
	bcs	sub_01C6EB
	phx
	asl	a
	tax
	lda	f:tbl_01C689,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C689:
	.addr	sub_01C6EB
	.addr	sub_01C691
	.addr	sub_01C697
	.addr	sub_01C6A3

sub_01C691:
	stz	zp_00
	stz	zp_0C
	bra	loc_01C6B2

sub_01C697:
	lda	#$0100
	sta	zp_0C
	lda	#$000C
	sta	zp_00
	bra	loc_01C6B2

sub_01C6A3:
	lda	#$0200
	sta	zp_0C
	lda	#$0018
	sta	zp_00
	lda	#$0018
	sta	zp_08
loc_01C6B2:
	lda	#$0003
	sta	zp_02
	clc
	lda	$30,x
	adc	zp_00
	tay
	clc
	lda	#$4114
	adc	zp_0C
	jsl	f:sub_00FEA3
	ldx	zp_FA
	lda	zp_78
	and	#$000F
	cmp	#$0002
	bne	sub_01C6EB
	clc
	lda	$30,x
	adc	#$001E
	sta	$30,x
	cmp	#$B172
	bcc	sub_01C6EB
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	a:wram_13BA

sub_01C6EB:
	rtl

sub_01C6EC:
	lda	$26,x
	beq	loc_01C6FA
	lda	#$914A
	sta	zp_9A
	lda	#$0050
	sta	zp_98
loc_01C6FA:
	rtl

sub_01C6FB:
	lda	$12,x
	beq	loc_01C731
	lda	zp_BE
	bne	loc_01C730
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$000F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF3C
	bcs	loc_01C730
	lda	#$FFFF
	sta	a:$001E,y
	dec	$24,x
	bne	loc_01C730
	lda	#$8000
	sta	$16,x
loc_01C730:
	rtl
loc_01C731:
	lda	$06,x
	bpl	loc_01C747
	lda	#$0030
	jsl	f:sub_00868F
	inc	$12,x
	lda	#$0008
	sta	$24,x
	lda	$36,x
	bra	loc_01C7AD
loc_01C747:
	inc	$24,x
	lda	$24,x
	cmp	#$0028
	bne	loc_01C756
	stz	$24,x
	lda	$32,x
	bra	loc_01C7AD
loc_01C756:
	cmp	#$0020
	bcc	loc_01C7B5
	bne	loc_01C7B5
	phx
	ldx	#$03C0
	jsl	f:sub_019E86
	ply
	bcs	loc_01C7B5
	lda	#$0016
	sta	$10,x
	lda	#$3E00
	sta	$02,x
	lda	#$B40D
	sta	$00,x
	lda	#$180F
	sta	$16,x
	lda	rng_lo
	and	#$0001
	adc	#$FFFE
	sta	$1A,x
	lda	#$4000
	sta	$18,x
	lda	#$FFFF
	sta	$1E,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	a:$000A,y
	adc	#$FFF8
	sta	$0A,x
	lda	a:$000E,y
	adc	#$FFF8
	sta	$0E,x
	tyx
	lda	$34,x
loc_01C7AD:
	sta	zp_00
	lda	$30,x
	jsl	f:sub_00FE76
loc_01C7B5:
	rtl

sub_01C7B6:
	lda	$3C,x
	bne	loc_01C7CF
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	$0E,x
	cmp	#$00C8
	bcc	loc_01C7E0
loc_01C7CF:
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#$C516
	jml	f:sub_01CF66
loc_01C7E0:
	rtl

sub_01C7E1:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01C7F0,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01C7F0:
	.addr	sub_01C7FA
	.addr	sub_01C840
	.addr	sub_01C87E
	.addr	sub_01C8AE
	.addr	sub_01C8C7

sub_01C7FA:
	lda	#$3E00
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	inc	$12,x
	lda	$3E,x
	beq	loc_01C813
	jsr	a:sub_01C9A5
	rtl
loc_01C813:
	lda	#$0012
	sta	$16,x
	lda	#$B172
	sta	$20,x
	lda	#$FFFE
	sta	$1E,x
	lda	$0E,x
	sta	$34,x
	lda	$0A,x
	bpl	loc_01C835
	lda	#$FFF0
	sta	$0A,x
	lda	#$0002
	sta	$1A,x
	rtl
loc_01C835:
	lda	#$0100
	sta	$0A,x
	lda	#$FFFD
	sta	$1A,x
	rtl

sub_01C840:
	jsr	a:sub_01C99D
	lda	$34,x
	cmp	$0E,x
	bcc	loc_01C85A
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	loc_01C869
loc_01C85A:
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
loc_01C869:
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	clc
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	rtl

sub_01C87E:
	ldy	$3C,x
	beq	loc_01C8AB
	lda	#$0012
	jsl	f:sub_00868F
	lda	#$8000
	sta	$16,x
	lda	a:$1D82,y
	bne	loc_01C89F
	lda	$3A,x
	sta	a:$1D84,y
	lda	#$0000
	sta	a:$0036,y
	rtl
loc_01C89F:
	lda	$3A,x
	sta	a:$1D86,y
	lda	#$0000
	sta	a:$0034,y
	rtl
loc_01C8AB:
	brl	loc_01C8F5

sub_01C8AE:
	ldy	$3C,x
	beq	loc_01C8C4
	lda	#$0012
	jsl	f:sub_00868F
	lda	#$8000
	sta	$16,x
	lda	#$0200
	sta	a:$1D88,y
loc_01C8C4:
	brl	loc_01C8F5

sub_01C8C7:
	ldy	#$3E00
	lda	zp_BC
	bne	loc_01C8D1
	ldy	#$3200
loc_01C8D1:
	sty	$02,x
	ldy	$3C,x
	beq	loc_01C8F2
	lda	#$8000
	sta	$16,x
	lda	#$0012
	jsl	f:sub_00868F
	lda	a:$1D8C,y
	inc	a
	cmp	#$0009
	bcc	loc_01C8EF
	; (not executed in the CDL traces)
	lda	#$0009
loc_01C8EF:
	sta	a:$1D8C,y
loc_01C8F2:
	brl	loc_01C8F5
loc_01C8F5:
	lda	$3E,x
	beq	loc_01C910
	lda	$0E,x
	cmp	#$00C0
	bcs	loc_01C903
	brl	loc_01C98D
loc_01C903:
	lda	#$FFFE
	sta	$1E,x
	txy
	lda	#$C4CE
	jml	f:sub_01CF66
loc_01C910:
	dec	$36,x
	bne	loc_01C91A
	lda	#$8000
	sta	$16,x
	rtl
loc_01C91A:
	lda	$36,x
	cmp	#$0030
	bcs	loc_01C92D
	lda	zp_BC
	beq	loc_01C929
	stz	$00,x
	bra	loc_01C92D
loc_01C929:
	lda	$38,x
	sta	$00,x
loc_01C92D:
	lda	stage_number
	cmp	#$0004
	bne	loc_01C937
	brl	loc_01C9D8
loc_01C937:
	stz	zp_00
	lda	$1E,x
	bmi	loc_01C963
	stz	zp_02
	jsl	f:sub_00E16E
	and	#$807E
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:sub_00E16E
	bit	#$807E
	beq	loc_01C95D
	lda	zp_04
	beq	loc_01C961
	brl	loc_0193D7
loc_01C95D:
	lda	zp_04
	beq	loc_01C961
loc_01C961:
	bra	loc_01C98D
loc_01C963:
	lda	#$FFF0
	sta	zp_02
	jsl	f:sub_00E16E
	and	#$0182
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:sub_00E16E
	bit	#$0182
	beq	loc_01C989
	lda	zp_04
	beq	loc_01C987
	jsl	f:sub_0193F4
loc_01C987:
	bra	loc_01C98D
loc_01C989:
	lda	zp_04
	beq	loc_01C98D
loc_01C98D:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_01C99D:
	lda	$06,x
	bpl	loc_01C9D7
	stz	$18,x
	stz	$1A,x

sub_01C9A5:
	stz	$20,x
	stz	$22,x
	lda	$3A,x
	asl	a
	tay
	lda	a:data_05B17E,y
	sta	$00,x
	sta	$38,x
	clc
	lda	a:data_05B18C,y
	adc	$12,x
	sta	$12,x
	cmp	#$0003
	bne	loc_01C9C6
	lda	#$3000
	sta	$02,x
loc_01C9C6:
	lda	#$0200
	sta	$36,x
	stz	$1C,x
	lda	#$FFFE
	sta	$1E,x
	lda	#$000B
	sta	$16,x
loc_01C9D7:
	rts
loc_01C9D8:
	lda	$0E,x
	cmp	#$00B4
	bcs	loc_01C9E2
	brl	loc_01C98D
loc_01C9E2:
	lda	a:wram_1672
	cmp	#$0005
	bcs	loc_01C9ED
	; (not executed in the CDL traces)
	brl	loc_01C98D
loc_01C9ED:
	stz	$1C,x
	stz	$1E,x
	sec
	lda	$0A,x
	sbc	#$0008
	sta	$0A,x
	rtl

sub_01C9FA:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01CA09,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01CA09:
	.addr	sub_01CA0F
	.addr	sub_01CA43
	.addr	sub_01CAC7

sub_01CA0F:
	lda	#$B374
	sta	$00,x
	lda	#$4013
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	lda	#$0080
	sta	$30,x
	lda	#$0200
	sta	$34,x
	lda	#$0400
	sta	$36,x
	lda	#$0010
	sta	$06,x
	lda	#$FFD8
	sta	$2A,x
	lda	#$0034
	sta	$28,x
	inc	$12,x
	rtl
loc_01CA3F:
	jml	f:sub_01B956

sub_01CA43:
	lda	$06,x
	bpl	loc_01CA3F
	lda	#$0042
	jsl	f:sub_00868F
	inc	$12,x
	lda	#$0003
	sta	$16,x
	lda	#$B3C1
	sta	$00,x
	sta	$32,x
	lda	#$FFFB
	sta	$30,x
	sta	$1E,x
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$0060
	sta	$24,x
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	phx
	ldy	#$000A
	ldx	#$0300
loc_01CA81:
	lda	$10,x
	beq	loc_01CA92
loc_01CA85:
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0780
	bcc	loc_01CA81
	; (not executed in the CDL traces)
	plx
	rtl
loc_01CA92:
	lda	a:data_05B19C,y
	sta	$00,x
	sta	$32,x
	lda	#$0003
	sta	$16,x
	lda	#$0010
	sta	$10,x
	lda	#$3E00
	sta	$02,x
	lda	#$0040
	sta	$24,x
	lda	zp_00
	sta	$0A,x
	lda	zp_02
	sta	$0E,x
	lda	a:data_05B1A8,y
	sta	$1E,x
	sta	$30,x
	lda	a:data_05B1B4,y
	sta	$1A,x
	dey
	dey
	bne	loc_01CA85
	plx
	rtl

sub_01CAC7:
	lda	zp_BC
	bne	loc_01CAF1
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	sub_01CB4A
	lda	#$FFFF
	sta	a:$001E,y
	bra	sub_01CB4A
loc_01CAF1:
	lda	zp_C0
	bne	sub_01CB4A
	; (not executed in the CDL traces)
	ldy	#$0740
	jsl	f:sub_019EC1
	bcc	sub_01CB4A
	lda	#$0010
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	rng_lo
	and	#$003F
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$0018
	sta	a:$0024,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$FFFC
	sta	a:$0030,y
	lda	#$B1EB
	sta	a:$0000,y
	sta	a:$0032,y
	lda	#$8000
	sta	a:$0018,y
	lda	rng_hi
	bmi	loc_01CB43
	bra	sub_01CB4A
loc_01CB43:
	lda	a:$001A,y
	dec	a
	sta	a:$001A,y

sub_01CB4A:
	dec	$24,x
	bne	loc_01CB54
	lda	#$8000
	sta	$16,x
	rtl
loc_01CB54:
	lda	$24,x
	cmp	#$0010
	bcs	loc_01CB67
	lda	zp_BC
	bne	loc_01CB63
	stz	$00,x
	bra	loc_01CB67
loc_01CB63:
	lda	$32,x
	sta	$00,x
loc_01CB67:
	lda	$1E,x
	bmi	loc_01CB82
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	beq	loc_01CB82
	jsl	f:sub_0193DB
	lda	$30,x
	beq	loc_01CB92
	inc	a
	sta	$30,x
	sta	$1E,x
loc_01CB82:
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
loc_01CB92:
	; (not executed in the CDL traces)
	stz	$1C,x
	rtl

sub_01CB95:
	lda	$12,x
	bne	loc_01CBB0
	inc	$12,x
	lda	#$4071
	sta	$16,x
	lda	#$FF00
	sta	$2A,x
	lda	#$0020
	sta	$28,x
	lda	#$0040
	sta	$06,x
	rtl
loc_01CBB0:
	lda	a:wram_13BA
	cmp	#$0004
	bne	loc_01CBBD
	lda	#$4051
	sta	$16,x
loc_01CBBD:
	jsl	f:sub_019F1A
	lda	$06,x
	bpl	loc_01CC13
	lda	#$0041
	jsl	f:sub_00868F
	lda	#$0005
	sta	a:wram_1662
	lda	#$00FF
	sta	zp_FA
	lda	#$0078
	sta	zp_FE
	lda	#$0004
	sta	zp_08
	lda	#$2208
	jsl	f:sub_01D005
	lda	#$0001
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	a:wram_1380
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$411C
	ldy	#$B1C0
	phx
	jsl	f:sub_00FEA3
	plx
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	a:wram_13BA
	rtl
loc_01CC13:
	lda	$26,x
	beq	loc_01CC21
	lda	#$912A
	sta	zp_9A
	lda	#$0030
	sta	zp_98
loc_01CC21:
	rtl

sub_01CC22:
	jsr	a:sub_01CD18
	lda	$06,x
	bpl	loc_01CC34
	stz	$06,x
	lda	#$001B
	sta	$10,x
	jml	f:loc_01D201
loc_01CC34:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01CC43,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01CC43:
	.addr	sub_01CC53
	.addr	sub_01CC7C
	.addr	sub_01CC90
	.addr	sub_01CC97
	.addr	sub_01CC90
	.addr	sub_01CCAF
	.addr	sub_01CC90
	.addr	sub_01CC7C

sub_01CC53:
	lda	#$3400
	sta	$02,x
	stz	$26,x
	stz	$20,x
	lda	#$001F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	ldy	difficulty
	lda	a:data_05B1C8,y
	sta	$06,x
	inc	$12,x

sub_01CC7C:
	ldy	$04,x
	lda	a:data_05B278,y
	sta	$00,x
	ldy	difficulty
	lda	a:data_05B1CE,y
	sta	$24,x
	lda	#$0002
	sta	$12,x
	rtl

sub_01CC90:
	dec	$24,x
	bne	loc_01CC96
	inc	$12,x
loc_01CC96:
	rtl

sub_01CC97:
	ldy	$04,x
	lda	a:data_05B27C,y
	sta	$00,x
	lda	#$000C
	sta	$24,x
	lda	#$0004
	sta	$12,x
	lda	#$0016
	jml	f:sub_00868F

sub_01CCAF:
	jsl	f:sub_019EAB
	bcs	loc_01CD06
	lda	#$0013
	sta	a:$0010,y
	lda	$0A,x
	clc
	phy
	ldy	$04,x
	adc	a:data_05B1D4,y
	ply
	sta	a:$000A,y
	lda	$04,x
	sta	a:$0004,y
	lda	$0E,x
	clc
	adc	#$FFE0
	sta	a:$000E,y
	phx
	tyx
	lda	zp_1E
	lsr	a
	lsr	a
	and	#$003C
	ora	$04,x
	tay
	lda	a:data_05B1D8,y
	sta	$1A,x
	lda	a:data_05B228,y
	sta	$18,x
	lda	#$FFFA
	sta	$1E,x
	stz	$1C,x
	plx
	ldy	$04,x
	lda	a:data_05B280,y
	sta	$00,x
	lda	#$0010
	sta	$24,x
	lda	#$0006
	sta	$12,x
	rtl
loc_01CD06:
	; (not executed in the CDL traces)
	ldy	$04,x
	lda	a:data_05B278,y
	sta	$00,x
	lda	#$000C
	sta	$24,x
	lda	#$0002
	sta	$12,x
	rtl

sub_01CD18:
	lda	a:p1_lives
	ora	a:p2_lives
	beq	loc_01CD76
	lda	a:p1_lives
	beq	loc_01CD38
	ldy	#$0200
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_18
	bpl	loc_01CD36
	eor	#$FFFF
	inc	a
loc_01CD36:
	sta	zp_1C
loc_01CD38:
	lda	a:p2_lives
	beq	loc_01CD57
	ldy	#$0240
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_1A
	bpl	loc_01CD4E
	eor	#$FFFF
	inc	a
loc_01CD4E:
	sta	zp_1E
	ldy	#$0002
	cmp	zp_1C
	bcc	loc_01CD5E
loc_01CD57:
	lda	zp_1C
	sta	zp_1E
	ldy	#$0000
loc_01CD5E:
	lda	$12,x
	cmp	#$0003
	bcc	loc_01CD6A
	cmp	#$0007
	bcc	loc_01CD76
loc_01CD6A:
	stz	$04,x
	lda	a:$0018,y
	bpl	loc_01CD76
	lda	#$0002
	sta	$04,x
loc_01CD76:
	rts

sub_01CD77:
	lda	$12,x
	bne	loc_01CD99
	lda	#$3000
	sta	$02,x
	lda	#$180D
	sta	$16,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$B284
	sta	$20,x
	stz	$22,x
	inc	$12,x
	rtl
loc_01CD99:
	lda	$3C,x
	bne	loc_01CDAA
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	bit	#$2000
	beq	loc_01CDCA
loc_01CDAA:
	lda	#$001A
	sta	$10,x
	lda	$0A,x
	clc
	adc	#$0008
	lda	$0A,x
	lda	$0E,x
	sec
	sbc	#$0010
	lda	$0E,x
	lda	#$0030
	jsl	f:sub_00868F
	jml	f:loc_01D2A1
loc_01CDCA:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	bcc	loc_01CDE4
	inc	$1E,x
	lda	$1E,x
	cmp	#$0006
	bmi	loc_01CDE4
	lda	#$0006
	sta	$1E,x
	stz	$1C,x
loc_01CDE4:
	rtl

sub_01CDE5:
	lda	$12,x
	cmp	#$0003
	bcs	loc_01CDF3
	jsr	a:sub_01CE99
	jsl	f:sub_01CF15
loc_01CDF3:
	lda	$06,x
	bpl	loc_01CE02
	stz	$06,x
	lda	#$001B
	sta	$10,x
	jml	f:loc_01D201
loc_01CE02:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01CE11,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01CE11:
	.addr	sub_01CE1D
	.addr	sub_01CE44
	.addr	sub_01CE51
	.addr	sub_01CE58
	.addr	sub_01CE51
	.addr	sub_01CE44

sub_01CE1D:
	lda	#$2600
	sta	$02,x
	stz	$26,x
	lda	#$001F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	ldy	difficulty
	lda	a:data_05C43E,y
	sta	$06,x
	inc	$12,x

sub_01CE44:
	ldy	difficulty
	lda	a:data_05C444,y
	sta	$24,x
	lda	#$0002
	sta	$12,x
	rtl

sub_01CE51:
	dec	$24,x
	bne	loc_01CE57
	inc	$12,x
loc_01CE57:
	rtl

sub_01CE58:
	lda	$0A,x
	sta	zp_18
	lda	$0E,x
	sta	zp_1A
	lda	$34,x
	sta	zp_1C
	phx
	lda	$32,x
	tax
	lda	zp_18
	clc
	adc	a:data_05C44E,x
	sta	zp_00
	lda	zp_1A
	clc
	adc	a:data_05C46E,x
	sta	zp_02
	lda	zp_1C
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	plx
	jsl	f:sub_01A11C
	bcc	loc_01CE98
	jsl	f:sub_01CF1D
	lda	#$0010
	sta	$24,x
	lda	#$0004
	sta	$12,x
loc_01CE98:
	rtl

sub_01CE99:
	lda	#$FFFF
	sta	zp_1C
	sta	zp_1E
	lda	a:wram_0216
	beq	loc_01CEB5
	sec
	lda	a:wram_020A
	sbc	$0A,x
	sta	zp_18
	bpl	loc_01CEB3
	eor	#$FFFF
	inc	a
loc_01CEB3:
	sta	zp_1C
loc_01CEB5:
	lda	a:wram_0256
	beq	loc_01CECA
	sec
	lda	a:wram_024A
	sbc	$0A,x
	sta	zp_1A
	bpl	loc_01CEC8
	eor	#$FFFF
	inc	a
loc_01CEC8:
	sta	zp_1E
loc_01CECA:
	ldy	#$0000
	lda	zp_1E
	cmp	zp_1C
	bne	loc_01CED8
	cmp	#$FFFF
	beq	loc_01CF14
loc_01CED8:
	bcs	loc_01CEDD
	ldy	#$0002
loc_01CEDD:
	lda	a:data_05C44A,y
	sta	$30,x
	stz	$04,x
	lda	a:$0018,y
	bpl	loc_01CEEE
	lda	#$0002
	sta	$04,x
loc_01CEEE:
	ldy	$30,x
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sta	$34,x
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	ora	$04,x
	sta	$32,x
loc_01CF14:
	rts

sub_01CF15:
	ldy	$32,x
	lda	a:data_05C48E,y
	sta	$00,x
	rtl

sub_01CF1D:
	ldy	$32,x
	lda	a:data_05C4AE,y
	sta	$00,x
	rtl

sub_01CF25:
	pha
loc_01CF26:
	lda	a:$0010,y
	beq	loc_01CF38
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01CF26
	pla
	rtl
loc_01CF38:
	clc
	pla
	bra	sub_01CF66

sub_01CF3C:
	pha
loc_01CF3D:
	lda	a:$0010,y
	beq	loc_01CF4F
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01CF3D
	pla
	rtl
loc_01CF4F:
	lda	rng_lo
	and	zp_04
	adc	zp_00
	sta	a:$000A,y
	lda	rng_hi
	and	zp_06
	eor	#$FFFF
	adc	zp_02
	sta	a:$000E,y
	clc
	pla

sub_01CF66:
	sta	a:$0020,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$001D
	sta	a:$0010,y
	lda	#$AEA0
	sta	a:$0000,y
	lda	#$3200
	sta	a:$0002,y
	lda	#$0000
	sta	a:$0022,y
	sta	a:$0004,y
	rtl
