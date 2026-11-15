; objects/secondary_objects.asm -- Secondary object list
; Bank $00, $00:E1B8-$00:E368. Included by main.asm in segment BANK00.
;
; sub_00E1B8 (once per frame from the stage loop) runs 40 slots of $20 bytes
; at $0AC0-$0FBF: the handler of each slot's type (+$10) is called through
; tbl_05A0B4 (sub_00E355), then velocity (+$18/+$1C) is added to position
; (+$08/+$0C).

sub_00E1B8:
	ldx	#$0AC0
loc_00E1BB:
	lda	$10,x
	bne	loc_00E1CB
loc_00E1BF:
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcc	loc_00E1BB
	rtl
loc_00E1CB:
	jsl	f:sub_00E355
	lda	a:title_menu_cursor
	beq	loc_00E1E4
	lda	zp_BC
	beq	loc_00E1DF
	cpx	#$0D40
	bcc	loc_00E1E4
	bcs	loc_00E1ED
loc_00E1DF:
	cpx	#$0D40
	bcc	loc_00E1ED
loc_00E1E4:
	lda	$02,x
	beq	loc_00E1ED
	ldy	zp_AC
	jsr	a:sub_00E2D7
loc_00E1ED:
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	ldy	$02,x
	beq	loc_00E1BF
	cmp	#$00F8
	bcs	loc_00E21C
	lda	$0E,x
	cmp	#$FFC0
	bcs	loc_00E22A
	cmp	#$00F0
	bcc	loc_00E22A
loc_00E21C:
	phx
	stz	$00,x
	txy
	iny
	lda	#$001E
	mvn	#$05, #$05
	plx
	bra	loc_00E1BF
loc_00E22A:
	lda	$06,x
	beq	loc_00E1BF
	lda	zp_BC
	bne	loc_00E239
	cpx	#$0D40
	bcs	loc_00E23E
	bcc	loc_00E1BF
loc_00E239:
	cpx	#$0D40
	bcs	loc_00E1BF
loc_00E23E:
	lda	$0A,x
	adc	#$000A
	sta	zp_00
	lda	$0E,x
	adc	#$000A
	sta	zp_02
	txy
	ldx	#$159E
	phx
loc_00E251:
	plx
	inx
	inx
	lda	$00,x
	beq	loc_00E2C7
	phx
	tax
	lda	$06,x
	bmi	loc_00E251
	lda	zp_00
	cmp	$0A,x
	bmi	loc_00E251
	lda	a:$000E,y
	cmp	$0E,x
	bpl	loc_00E251
	lda	zp_02
	cmp	$2E,x
	bmi	loc_00E251
	lda	a:$000A,y
	cmp	$2C,x
	bpl	loc_00E251
	pla
	lda	a:$0010,y
	sta	$14,x
	lda	$16,x
	bit	#$0010
	beq	loc_00E2B3
	bit	#$0020
	bne	loc_00E2B3
	sec
	lda	$06,x
	sbc	a:$0006,y
	sta	$06,x
	bpl	loc_00E2B3
	sta	a:$0016,y
	phy
	lda	$10,x
	asl	a
	tay
	lda	a:data_05A66D,y
	ply
	phx
	ldx	#$0200
	cpy	#$0D40
	bcc	loc_00E2AC
	ldx	#$0240
loc_00E2AC:
	jsl	f:sub_00B829
	plx
	bra	loc_00E2C7
loc_00E2B3:
	lda	$16,x
	bit	#$4000
	beq	loc_00E2C1
	lda	#$0010
	jsl	f:sub_00868F
loc_00E2C1:
	lda	#$0001
	sta	a:$0016,y
loc_00E2C7:
	tyx
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcs	loc_00E2D6
	brl	loc_00E1BB
loc_00E2D6:
	rtl

sub_00E2D7:
	bit	#$0100
	beq	loc_00E320
	lda	$0A,x
	cmp	#$00FE
	bcs	loc_00E31F
	and	#$00FF
	sta	zp_08
	lda	$0E,x
	cmp	#$00F0
	bcs	loc_00E31F
	and	#$00FF
	xba
	ora	zp_08
	sta	a:$0000,y
	lda	$02,x
	and	#$FEFF
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	clc
	ror	zp_9C
	sec
	ror	zp_9C
	bcc	loc_00E31D
loc_00E30C:
	phx
	ldx	zp_AE
	lda	zp_9C
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_9C
	stx	zp_AE
	plx
loc_00E31D:
	sty	zp_AC
loc_00E31F:
	rts
loc_00E320:
	lda	$0A,x
	adc	#$0004
	cmp	#$00FE
	bcs	loc_00E31F
	and	#$00FF
	sta	zp_08
	lda	$0E,x
	adc	#$0004
	cmp	#$00F4
	bcs	loc_00E31F
	and	#$00FF
	xba
	ora	zp_08
	sta	a:$0000,y
	lda	$02,x
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	clc
	ror	zp_9C
	clc
	ror	zp_9C
	bcc	loc_00E31D
	bcs	loc_00E30C

sub_00E355:
	sta	zp_00
	asl	a
	clc
	adc	zp_00
	tay
	lda	a:tbl_05A0B4,y
	sta	zp_00
	lda	a:tbl_05A0B4+2,y
	sta	zp_02
	jml	[zp_00]
