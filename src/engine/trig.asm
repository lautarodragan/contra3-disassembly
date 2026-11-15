; engine/trig.asm -- Angle and trigonometry helpers
; Bank $1D, $1D:ABA0-$1D:AF26. Included by main.asm in segment BANK1D.
;
; sub_1DABA0: angle (0-255) of a vector; sub_1DACA4, sub_1DAD8A...: multiply
; by sine/cosine (tables data_05F794/data_05F814) with the hardware
; multiplier.

sub_1DABA0:
	.a16
	.i16
	phx
	phy
	jsr	a:sub_1DABAD
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	and	#$00FF
	ply
	plx
	rtl

sub_1DABAD:
	sep	#$30
	.a8
	.i8
	lda	zp_08
	bne	loc_1DABBB
	ldy	zp_0B
	bpl	loc_1DABB8
	rts
loc_1DABB8:
	lda	#$80
	rts
loc_1DABBB:
	lda	zp_0A
	bne	loc_1DABC9
	lda	zp_09
	bmi	loc_1DABC6
	lda	#$40
	rts
loc_1DABC6:
	lda	#$C0
	rts
loc_1DABC9:
	lda	zp_09
	bmi	loc_1DAC44
	lda	zp_0B
	bpl	loc_1DABFD
	lda	zp_0A
	eor	#$FF
	inc	a
	sta	zp_0A
	cmp	zp_08
	bne	loc_1DABDF
	lda	#$20
	rts
loc_1DABDF:
	bcc	loc_1DABEF
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	stz	zp_0C
	lda	zp_0A
	bra	loc_1DAC33
loc_1DABEF:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$40
	sta	zp_0C
	lda	zp_08
	bra	loc_1DAC16
loc_1DABFD:
	lda	zp_0A
	cmp	zp_08
	bne	loc_1DAC06
	lda	#$60
	rts
loc_1DAC06:
	bcc	loc_1DAC27
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$80
	sta	zp_0C
	lda	zp_0A
loc_1DAC16:
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	sec
	lda	zp_0C
	ldy	a:RDDIVL
	sbc	a:data_05F694,y
	rts
loc_1DAC27:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$40
	sta	zp_0C
	lda	zp_08
loc_1DAC33:
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	clc
	lda	zp_0C
	ldy	a:RDDIVL
	adc	a:data_05F694,y
	rts
loc_1DAC44:
	lda	zp_08
	eor	#$FF
	inc	a
	sta	zp_08
	lda	zp_0B
	bmi	loc_1DAC78
	lda	zp_0A
	cmp	zp_08
	bne	loc_1DAC58
	lda	#$A0
	rts
loc_1DAC58:
	bcc	loc_1DAC6A
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$80
	sta	zp_0C
	lda	zp_0A
	bra	loc_1DAC33
loc_1DAC6A:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$C0
	sta	zp_0C
	lda	zp_08
	bra	loc_1DAC16
loc_1DAC78:
	lda	zp_0A
	eor	#$FF
	inc	a
	sta	zp_0A
	cmp	zp_08
	bne	loc_1DAC86
	lda	#$E0
	rts
loc_1DAC86:
	bcc	loc_1DAC96
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	stz	zp_0C
	lda	zp_0A
	bra	loc_1DAC16
loc_1DAC96:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$C0
	sta	zp_0C
	lda	zp_08
	bra	loc_1DAC33

sub_1DACA4:
	.a16
	.i16
	sty	a:WRMPYA
	bit	#$0080
	bne	loc_1DACC9
	bit	#$0040
	bne	loc_1DACBD
	jsr	a:sub_1DACEF
	lda	#$0000
	sec
	sbc	zp_0A
	sta	zp_0A
	rtl
loc_1DACBD:
	jsr	a:sub_1DACEF
	lda	zp_08
	ldy	zp_0A
	sty	zp_08
	sta	zp_0A
	rtl
loc_1DACC9:
	bit	#$0040
	bne	loc_1DACDA
	jsr	a:sub_1DACEF
	lda	#$0000
	sec
	sbc	zp_08
	sta	zp_08
	rtl
loc_1DACDA:
	jsr	a:sub_1DACEF
	lda	#$0000
	sec
	sbc	zp_08
	tay
	lda	#$0000
	sec
	sbc	zp_0A
	sta	zp_08
	sty	zp_0A
	rtl

sub_1DACEF:
	and	#$003F
	tay
	sep	#$20
	.a8
	lda	a:data_05F794,y
	sta	a:WRMPYB
	nop
	stz	zp_09
	lda	a:RDMPYH
	sta	zp_08
	lda	a:data_05F814,y
	sta	a:WRMPYB
	rep	#$20
	.a16
	clc
	lda	zp_08
	adc	a:RDMPYL
	xba
	and	#$00FF
	sta	zp_08
	sep	#$20
	.a8
	lda	a:data_05F7D4,y
	sta	a:WRMPYB
	nop
	stz	zp_0B
	lda	a:RDMPYH
	sta	zp_0A
	lda	a:data_05F854,y
	sta	a:WRMPYB
	rep	#$20
	.a16
	clc
	lda	zp_0A
	adc	a:RDMPYL
	xba
	and	#$00FF
	sta	zp_0A
	rts

sub_1DAD3C:
	phy
	lda	zp_08
	bpl	loc_1DAD45
	eor	#$FFFF
	inc	a
loc_1DAD45:
	cmp	#$0100
	bcs	loc_1DAD7B
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	lda	zp_0A
	bpl	loc_1DAD5C
	eor	#$FFFF
	inc	a
loc_1DAD5C:
	cmp	#$0100
	bcs	loc_1DAD7B
	ldy	a:RDMPYL
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	tya
	lsr	a
	sta	zp_FA
	lda	a:RDMPYL
	lsr	a
	clc
	adc	zp_FA
	ply
	rtl
loc_1DAD7B:
	lda	#$FFFE
	ply
	rtl

sub_1DAD80:
	phx
	phy
	tyx
	jsl	f:sub_1DAD8A
	ply
	plx
	rtl

sub_1DAD8A:
	sep	#$20
	.a8
	sta	a:WRMPYA
	lda	$04,x
	bit	#$80
	beq	loc_1DAD98
	brl	loc_1DAE2A
loc_1DAD98:
	bit	#$40
	bne	loc_1DADE8
	and	#$3F
	tay
	lda	a:data_05F814,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	$1A,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$18,x
	sep	#$20
	.a8
	lda	a:data_05F854,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	$1E,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	$1C,x
	bne	loc_1DADE7
	; (not executed in the CDL traces)
	inc	$1E,x
loc_1DADE7:
	rtl
loc_1DADE8:
	.a8
	and	#$3F
	tay
	lda	a:data_05F854,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	$1A,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$18,x
	sep	#$20
	.a8
	lda	a:data_05F814,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	$1E,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$1C,x
	rtl
loc_1DAE2A:
	.a8
	bit	#$40
	bne	loc_1DAE7A
	and	#$3F
	tay
	lda	a:data_05F814,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	$1A,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	$18,x
	bne	loc_1DAE59
	; (not executed in the CDL traces)
	inc	$1A,x
loc_1DAE59:
	sep	#$20
	.a8
	lda	a:data_05F854,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	$1E,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$1C,x
	rtl
loc_1DAE7A:
	.a8
	and	#$3F
	tay
	lda	a:data_05F854,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	$1A,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	$18,x
	bne	loc_1DAEA5
	; (not executed in the CDL traces)
	inc	$1A,x
loc_1DAEA5:
	sep	#$20
	.a8
	lda	a:data_05F814,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	$1E,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	$1C,x
	bne	loc_1DAECF
	; (not executed in the CDL traces)
	inc	$1E,x
loc_1DAECF:
	rtl

sub_1DAED0:
	phy
	lda	zp_08
	bpl	loc_1DAED9
	eor	#$FFFF
	inc	a
loc_1DAED9:
	cmp	#$0100
	bcs	loc_1DAF10
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	lda	zp_0A
	bpl	loc_1DAEF0
	eor	#$FFFF
	inc	a
loc_1DAEF0:
	cmp	#$0100
	bcs	loc_1DAF10
	ldy	a:RDMPYL
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	tya
	sta	zp_FA
	lda	a:RDMPYL
	clc
	adc	zp_FA
	bcs	loc_1DAF10
	ply
	bra	loc_1DAF15
loc_1DAF10:
	; (not executed in the CDL traces)
	lda	#$00FF
	ply
	rtl
loc_1DAF15:
	phy
	ldy	#$FFFF
loc_1DAF19:
	iny
	iny
	sty	zp_FA
	sec
	sbc	zp_FA
	bcs	loc_1DAF19
	lda	zp_FA
	lsr	a
	ply
	rtl
