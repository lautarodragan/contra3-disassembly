; engine/math.asm -- Arithmetic helpers
; Bank $00, $00:8986-$00:8B18. Included by main.asm in segment BANK00.
;
; Division (sub_0089E4) and multiplication (sub_008ADB) with the hardware
; divider/multiplier, and helpers the CDL traces never ran.

; (no caller found; decoded because it follows the end of a routine)
sub_008986:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	ldy	#$0003
loc_00898D:
	phy
	tya
	asl	a
	tax
	lsr	a
	and	#$0002
	tay
	lda	a:$1F98
	clc
	adc	f:data_058000,x
	and	#$01FF
	pha
	lda	a:$1F98
	and	#$00FF
	asl	a
	clc
	adc	f:data_058008,x
	and	#$01FF
	tax
	lda	f:data_058010,x
	ldx	a:$1F94,y
	jsl	f:sub_0089E4
	pla
	cmp	#$0100
	bcc	loc_0089CB
	lda	#$0000
	sec
	sbc	$00
	sta	$00
loc_0089CB:
	ply
	tya
	asl	a
	tax
	lda	$00
	sta	a:$1E9E,x
	dey
	bpl	loc_00898D
	lda	a:$1F90
	sta	a:$1EA6
	lda	a:$1F92
	sta	a:$1EA8
	rtl

sub_0089E4:
	; (not executed in the CDL traces)
	rep	#$30
	sta	$00
	stx	$02
	lda	#$8000
	sta	$04
	ldy	#$0008
	lda	$02
loc_0089F4:
	asl	a
	bcs	loc_0089FC
	dey
	bne	loc_0089F4
	beq	loc_008A03
loc_0089FC:
	lsr	$04
	lsr	$02
	dey
	bne	loc_0089FC
loc_008A03:
	lda	$04
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	$02
	sta	a:WRDIVB
	lda	#$04
loc_008A11:
	dec	a
	bne	loc_008A11
	rep	#$20
	.a16
	ldx	a:RDDIVL
	stx	$02
	lda	$00
	cmp	#$FFFF
	clc
	bne	loc_008A27
	lda	#$0000
	sec
loc_008A27:
	ror	a
	sta	$00
	ldy	#$0008
	lda	$02
loc_008A2F:
	asl	a
	bcs	loc_008A37
	dey
	bne	loc_008A2F
	beq	loc_008A3E
loc_008A37:
	lsr	$00
	lsr	$02
	dey
	bne	loc_008A37
loc_008A3E:
	lda	$00
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	$02
	sta	a:WRDIVB
	lda	#$04
loc_008A4C:
	dec	a
	bne	loc_008A4C
	rep	#$20
	.a16
	lda	a:RDDIVL
	asl	a
	sta	$00
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008A58:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10
	lda	$00
	sec
	sbc	$02
	sta	$08
	lda	#$0000
	sbc	#$0000
	sta	$0A
	sta	$0C
	tya
	beq	loc_008A84
	bmi	loc_008A7B
loc_008A72:
	asl	$08
	rol	$0A
	dey
	bne	loc_008A72
	beq	loc_008A84
loc_008A7B:
	lsr	$0C
	ror	$0A
	ror	$08
	iny
	bne	loc_008A7B
loc_008A84:
	lda	$04
	sec
	sbc	$08
	sta	$00
	lda	$06
	sbc	$0A
	sta	$02
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008A92:
	; (not executed in the CDL traces)
	phx
	tyx
	jsl	f:sub_008A9A
	plx
	rtl

sub_008A9A:
	; (not executed in the CDL traces)
	stz	$04,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	stz	$00,x
	stz	$02,x
	stz	$14,x
	stz	$06,x
	stz	$10,x
	stz	$12,x
	stz	$16,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$20,x
	stz	$22,x
	stz	$24,x
	stz	$26,x
	stz	$28,x
	stz	$2A,x
	stz	$2C,x
	stz	$2E,x
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	stz	$38,x
	stz	$3A,x
	stz	$3C,x
	stz	$3E,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008ADB:
	; (not executed in the CDL traces)
	sep	#$10
	.i8
	ldx	$00
	ldy	$02
	sty	a:WRMPYA
	stx	a:WRMPYB
	stz	$06
	ldx	$01
	lda	a:RDMPYL
	stx	a:WRMPYB
	sta	$04
	ldx	$00
	lda	a:RDMPYL
	ldy	$03
	sty	a:WRMPYA
	stx	a:WRMPYB
	clc
	adc	$05
	clc
	adc	a:RDMPYL
	ldx	$01
	stx	a:WRMPYB
	sta	$05
	lda	$06
	clc
	adc	a:RDMPYL
	sta	$06
	rep	#$10
	.i16
	rtl
