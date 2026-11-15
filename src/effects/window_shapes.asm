; effects/window_shapes.asm -- Window shapes
; Bank $02, $02:DDC6-$02:E65E. Included by main.asm in segment BANK02.
;
; Routines called from the NMI frame handlers and from
; engine/window_effect.asm that compute window/HDMA shapes (sub_02DDEE,
; sub_02DE4A, sub_02DF49...).

sub_02DDC6:
	lda	$3A
	lsr	a
	bcs	loc_02DDCE
	brl	loc_02DDD5
loc_02DDCE:
	lda	#$3C00
	sta	a:A1T2L
	rtl
loc_02DDD5:
	lda	#$3E00
	sta	a:A1T2L
loc_02DDDB:
	rtl

sub_02DDDC:
	lda	a:$1586
	beq	loc_02DDDB
	lda	$3A
	lsr	a
	bcc	loc_02DDEA
	jml	f:loc_02E0FD
loc_02DDEA:
	jml	f:loc_02E3AE

sub_02DDEE:
	lda	$10
	asl	a
	sta	$06
	lda	$14
	clc
	adc	$10
	bmi	loc_02DE04
	beq	loc_02DE04
	sec
	sbc	$06
	cmp	#$0100
	bmi	loc_02DE06
loc_02DE04:
	sec
	rtl
loc_02DE06:
	lda	$16
	sec
	sbc	$10
	cmp	$18
	bmi	loc_02DE15
	sta	$08
	stz	$0C
	bra	loc_02DE2D
loc_02DE15:
	tay
	clc
	adc	$06
	cmp	$18
	bmi	loc_02DE04
	beq	loc_02DE04
	lda	$18
	sta	$08
	tya
	sec
	sbc	$18
	eor	#$FFFF
	inc	a
	sta	$0C
loc_02DE2D:
	lda	$16
	clc
	adc	$10
	cmp	$1A
	bmi	loc_02DE3F
	sec
	sbc	$06
	cmp	$1A
	bpl	loc_02DE04
	lda	$1A
loc_02DE3F:
	sta	$0A
	lda	$0A
	sec
	sbc	$08
	sta	$0E
	clc
	rtl

sub_02DE4A:
	sep	#$20
	.a8
	lda	$10
	sta	a:WRMPYA
	rep	#$20
	.a16
	lda	$08
	asl	a
	clc
	adc	$1C
	tax
	lda	$0E
	sta	$02
	lda	$0C
	sta	$00
	cmp	$10
	bcc	loc_02DE69
	brl	loc_02DED5
loc_02DE69:
	sep	#$20
loc_02DE6B:
	.a8
	lda	$00
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	$10
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy	a:RDDIVL
	lda	a:data_05E336,y
	sta	a:WRMPYB
	nop
	nop
	nop
	nop
	lda	a:RDMPYH
	rep	#$20
	.a16
	and	#$00FF
	tay
	eor	#$FFFF
	sec
	adc	$14
	bpl	loc_02DEA1
	lda	#$0000
loc_02DEA1:
	cmp	#$0100
	bcc	loc_02DEAB
loc_02DEA6:
	lda	#$0001
	bra	loc_02DEC1
loc_02DEAB:
	sta	$04
	tya
	clc
	adc	$14
	bmi	loc_02DEA6
	cmp	#$0100
	bmi	loc_02DEBB
	lda	#$00FF
loc_02DEBB:
	and	#$00FF
	xba
	ora	$04
loc_02DEC1:
	sta	f:$7E0000,x
	sep	#$20
	.a8
	inc	$00
	inx
	inx
	dec	$02
	beq	loc_02DF44
	lda	$00
	cmp	$10
	bcc	loc_02DE6B
loc_02DED5:
	.a16
	rep	#$20
	lda	$06
	sec
	sbc	$00
	sta	$00
	sep	#$20
loc_02DEE0:
	.a8
	lda	$00
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	$10
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy	a:RDDIVL
	lda	a:data_05E336,y
	sta	a:WRMPYB
	nop
	nop
	nop
	nop
	lda	a:RDMPYH
	rep	#$20
	.a16
	and	#$00FF
	tay
	eor	#$FFFF
	sec
	adc	$14
	bpl	loc_02DF16
	lda	#$0000
loc_02DF16:
	cmp	#$0100
	bcc	loc_02DF20
loc_02DF1B:
	lda	#$0001
	bra	loc_02DF36
loc_02DF20:
	sta	$04
	tya
	clc
	adc	$14
	bmi	loc_02DF1B
	cmp	#$0100
	bmi	loc_02DF30
	lda	#$00FF
loc_02DF30:
	and	#$00FF
	xba
	ora	$04
loc_02DF36:
	sta	f:$7E0000,x
	sep	#$20
	.a8
	dec	$00
	inx
	inx
	dec	$02
	bne	loc_02DEE0
loc_02DF44:
	stx	$1C
	rep	#$30
	.a16
	rtl

sub_02DF49:
	lda	$08
	asl	a
	clc
	adc	$1C
	sta	$00
	ldx	$1E
	lda	$08
	sec
	sbc	$18
	beq	loc_02DF8B
	cmp	#$0080
	bcc	loc_02DF79
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$7F
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	pla
loc_02DF79:
	sep	#$20
	.a8
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
loc_02DF8B:
	lda	$0E
	beq	loc_02DFC6
	cmp	#$0080
	bcc	loc_02DFB3
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$FF
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	$00
	sta	f:$7E0000,x
	clc
	adc	#$00FE
	sta	$00
	inx
	inx
	pla
loc_02DFB3:
	sep	#$20
	.a8
	ora	#$80
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	$00
	sta	f:$7E0000,x
	inx
	inx
loc_02DFC6:
	lda	$1A
	sec
	sbc	$0A
	beq	loc_02DFFE
	cmp	#$0080
	bcc	loc_02DFEC
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$7F
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	pla
loc_02DFEC:
	sep	#$20
	.a8
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
loc_02DFFE:
	stx	$1E
	rep	#$30
	rtl

sub_02E003:
	ldx	$1E
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0001,x
	sep	#$20
	.a8
	lda	#$00
	sta	f:$7E0003,x
	rep	#$30
	.a16
	rtl

sub_02E021:
	ldx	$1E
	sep	#$20
	.a8
	lda	#$10
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	$1E
	rtl

sub_02E03A:
	ldx	$1E
	sep	#$20
	.a8
	lda	#$18
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	$1E
	rtl

sub_02E053:
	ldx	$1E
	sep	#$20
	.a8
	lda	$1A
	sec
	sbc	$18
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	$1E
	rtl

sub_02E06F:
	; (not executed in the CDL traces)
	ldx	$1E
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	sep	#$20
	.a8
	lda	$1A
	clc
	sbc	$18
	dec	a
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	$1E
	rtl

sub_02E0B4:
	lda	$0E
	sta	$02
	lda	$0C
	asl	a
	tay
	lda	$08
	asl	a
	clc
	adc	$1C
	tax
loc_02E0C3:
	lda	$14
	sec
	sbc	($12),y
	bpl	loc_02E0CD
	lda	#$0000
loc_02E0CD:
	cmp	#$0100
	bcc	loc_02E0D7
loc_02E0D2:
	; (not executed in the CDL traces)
	lda	#$0001
	bra	loc_02E0EE
loc_02E0D7:
	sta	$04
	lda	$14
	clc
	adc	($12),y
	bmi	loc_02E0D2
	cmp	#$0100
	bmi	loc_02E0E8
	; (not executed in the CDL traces)
	lda	#$00FF
loc_02E0E8:
	and	#$00FF
	xba
	ora	$04
loc_02E0EE:
	sta	f:$7E0000,x
	iny
	iny
	inx
	inx
	dec	$02
	bne	loc_02E0C3
	stx	$1C
	rtl
loc_02E0FD:
	rep	#$30
	lda	a:$0F50
	dec	a
	bne	loc_02E108
	brl	loc_02E291
loc_02E108:
	bpl	loc_02E133
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E3C00
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E3C01
	sep	#$20
	.a8
	lda	#$00
	sta	f:$7E3C03
	sep	#$20
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	rtl
loc_02E133:
	; (not executed in the CDL traces)
	ldy	#$0000
	lda	a:$0EC2
	bit	#$2000
	bne	loc_02E141
	ldy	#$0002
loc_02E141:
	sep	#$20
	.a8
	lda	a:data_05E43E,y
	sta	a:CGADSUB
	sta	f:$7E3863
	sta	f:$7E3867
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:$0F46
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	cmp	#$0020
	bcc	loc_02E173
	lda	#$0020
loc_02E173:
	tay
	lda	a:ptrs_05E298,y
	sta	$04
	lda	$78
	lsr	a
	and	#$000F
	tay
	sep	#$20
	.a8
	lda	($04),y
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3C00
	sta	$1E
	lda	#$0010
	sta	$10
	lda	#$E2F6
	sta	$12
	lda	a:$1E02
	beq	loc_02E1D8
	dec	a
	bne	loc_02E1A3
	brl	loc_02E208
loc_02E1A3:
	lda	#$3C20
	sta	$1C
	lda	a:$0F70
	sta	$14
	lda	a:$0F74
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E1D3
	lda	a:$0EEC
	bne	loc_02E1D3
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E1D3:
	jsl	f:sub_02E003
	rtl
loc_02E1D8:
	lda	#$3C20
	sta	$1C
	lda	a:$0F70
	sta	$14
	lda	a:$0F74
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E203
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E203:
	jsl	f:sub_02E003
	rtl
loc_02E208:
	lda	#$3C20
	sta	$1C
	lda	a:$0F70
	sta	$14
	lda	a:$0F74
	sta	$16
	lda	#$0000
	sta	$18
	lda	#$0068
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E22D
loc_02E227:
	jsl	f:sub_02E06F
	bra	loc_02E24E
loc_02E22D:
	lda	#$0000
	beq	loc_02E23A
	lda	a:$0EEC
	ora	a:$0F2C
	bne	loc_02E227
loc_02E23A:
	lda	$08
	bne	loc_02E246
	inc	$08
	inc	$0C
	dec	$0E
	beq	loc_02E227
loc_02E246:
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E24E:
	jsl	f:sub_02E021
	lda	#$3C20
	sta	$1C
	lda	a:$0F72
	sta	$14
	lda	a:$0F76
	sta	$16
	lda	#$0078
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E277
loc_02E271:
	jsl	f:sub_02E053
	bra	loc_02E28C
loc_02E277:
	lda	#$0000
	bne	loc_02E284
	lda	a:$0EEC
	ora	a:$0F2C
	bne	loc_02E271
loc_02E284:
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E28C:
	jsl	f:sub_02E003
	rtl
loc_02E291:
	sep	#$20
	.a8
	lda	#$13
	sta	a:CGADSUB
	sta	f:$7E3863
	sta	f:$7E3867
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$3F
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:$0F64
	lsr	a
	lsr	a
	and	#$001F
	ora	#$00C0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3C00
	sta	$1E
	lda	a:$0F64
	asl	a
	and	#$00FF
	sta	$10
	lda	a:$1E02
	beq	loc_02E30C
	dec	a
	bne	loc_02E2DC
	brl	loc_02E341
loc_02E2DC:
	; (not executed in the CDL traces)
	lda	#$3C20
	sta	$1C
	lda	a:$0F78
	sta	$14
	lda	a:$0F7C
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E307
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E307:
	jsl	f:sub_02E003
	rtl
loc_02E30C:
	lda	#$3C20
	sta	$1C
	lda	a:$0F78
	sta	$14
	lda	a:$0F7C
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E33C
	lda	a:$0EEC
	bne	loc_02E33C
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E33C:
	jsl	f:sub_02E003
	rtl
loc_02E341:
	lda	#$3C20
	sta	$1C
	lda	a:$0F78
	sta	$14
	lda	a:$0F7C
	sta	$16
	lda	#$0000
	sta	$18
	lda	#$0068
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E366
loc_02E360:
	jsl	f:sub_02E053
	bra	loc_02E373
loc_02E366:
	lda	a:$0EEC
	bne	loc_02E360
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E373:
	jsl	f:sub_02E021
	lda	#$3C20
	sta	$1C
	lda	a:$0F7A
	sta	$14
	lda	a:$0F7E
	sta	$16
	lda	#$0078
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E39C
loc_02E396:
	jsl	f:sub_02E053
	bra	loc_02E3A9
loc_02E39C:
	lda	a:$0F2C
	bne	loc_02E396
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E3A9:
	jsl	f:sub_02E003
	rtl
loc_02E3AE:
	rep	#$30
	lda	a:$0F90
	dec	a
	bne	loc_02E3B9
	brl	loc_02E542
loc_02E3B9:
	bpl	loc_02E3E4
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E3E00
	rep	#$20
	.a16
	lda	#$3E1E
	sta	f:$7E3E01
	sep	#$20
	.a8
	lda	#$00
	sta	f:$7E3E03
	sep	#$20
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	rtl
loc_02E3E4:
	; (not executed in the CDL traces)
	ldy	#$0000
	lda	a:$0F02
	bit	#$2000
	bne	loc_02E3F2
	ldy	#$0002
loc_02E3F2:
	sep	#$20
	.a8
	lda	a:data_05E442,y
	sta	a:CGADSUB
	sta	f:$7E3863
	sta	f:$7E3867
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:$0F86
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	cmp	#$0020
	bcc	loc_02E424
	lda	#$0020
loc_02E424:
	tay
	lda	a:ptrs_05E298,y
	sta	$04
	lda	$78
	lsr	a
	and	#$000F
	tay
	sep	#$20
	.a8
	lda	($04),y
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3E00
	sta	$1E
	lda	#$0010
	sta	$10
	lda	#$E2F6
	sta	$12
	lda	a:$1E02
	beq	loc_02E489
	dec	a
	bne	loc_02E454
	brl	loc_02E4B9
loc_02E454:
	lda	#$3E20
	sta	$1C
	lda	a:$0FB0
	sta	$14
	lda	a:$0FB4
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E484
	lda	a:$0F2C
	bne	loc_02E484
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E484:
	jsl	f:sub_02E003
	rtl
loc_02E489:
	lda	#$3E20
	sta	$1C
	lda	a:$0FB0
	sta	$14
	lda	a:$0FB4
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E4B4
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E4B4:
	jsl	f:sub_02E003
	rtl
loc_02E4B9:
	lda	#$3E20
	sta	$1C
	lda	a:$0FB0
	sta	$14
	lda	a:$0FB4
	sta	$16
	lda	#$0000
	sta	$18
	lda	#$0068
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E4DE
loc_02E4D8:
	jsl	f:sub_02E06F
	bra	loc_02E4FF
loc_02E4DE:
	lda	#$0002
	beq	loc_02E4EB
	lda	a:$0F2C
	ora	a:$0EEC
	bne	loc_02E4D8
loc_02E4EB:
	lda	$08
	bne	loc_02E4F7
	inc	$08
	inc	$0C
	dec	$0E
	beq	loc_02E4D8
loc_02E4F7:
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E4FF:
	jsl	f:sub_02E021
	lda	#$3E20
	sta	$1C
	lda	a:$0FB2
	sta	$14
	lda	a:$0FB6
	sta	$16
	lda	#$0078
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E528
loc_02E522:
	jsl	f:sub_02E053
	bra	loc_02E53D
loc_02E528:
	lda	#$0002
	bne	loc_02E535
	lda	a:$0F2C
	ora	a:$0EEC
	bne	loc_02E522
loc_02E535:
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
loc_02E53D:
	jsl	f:sub_02E003
	rtl
loc_02E542:
	sep	#$20
	.a8
	lda	#$13
	sta	a:CGADSUB
	sta	f:$7E3863
	sta	f:$7E3867
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$3F
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:$0FA4
	lsr	a
	lsr	a
	and	#$001F
	ora	#$00C0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3E00
	sta	$1E
	lda	a:$0FA4
	asl	a
	and	#$00FF
	sta	$10
	lda	a:$1E02
	beq	loc_02E5BD
	dec	a
	bne	loc_02E58D
	brl	loc_02E5F2
loc_02E58D:
	; (not executed in the CDL traces)
	lda	#$3E20
	sta	$1C
	lda	a:$0FB8
	sta	$14
	lda	a:$0FBC
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E5B8
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E5B8:
	jsl	f:sub_02E003
	rtl
loc_02E5BD:
	lda	#$3E20
	sta	$1C
	lda	a:$0FB8
	sta	$14
	lda	a:$0FBC
	sta	$16
	lda	#$0018
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02E03A
	jsl	f:sub_02DDEE
	bcs	loc_02E5ED
	lda	a:$0F2C
	bne	loc_02E5ED
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E5ED:
	jsl	f:sub_02E003
	rtl
loc_02E5F2:
	lda	#$3E20
	sta	$1C
	lda	a:$0FB8
	sta	$14
	lda	a:$0FBC
	sta	$16
	lda	#$0000
	sta	$18
	lda	#$0068
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E617
loc_02E611:
	jsl	f:sub_02E053
	bra	loc_02E624
loc_02E617:
	lda	a:$0EEC
	bne	loc_02E611
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E624:
	jsl	f:sub_02E021
	lda	#$3E20
	sta	$1C
	lda	a:$0FBA
	sta	$14
	lda	a:$0FBE
	sta	$16
	lda	#$0078
	sta	$18
	lda	#$00E0
	sta	$1A
	jsl	f:sub_02DDEE
	bcc	loc_02E64D
loc_02E647:
	jsl	f:sub_02E053
	bra	loc_02E65A
loc_02E64D:
	lda	a:$0F2C
	bne	loc_02E647
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
loc_02E65A:
	jsl	f:sub_02E003
	rtl
