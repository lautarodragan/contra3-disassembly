; objects/object_helpers_00.asm -- Object helpers (bank $00)
; Bank $00, $00:FD8D-$00:FFBF. Included by main.asm in segment BANK00.
;
; Small routines shared by object handlers in all banks (sub_00FD8D,
; sub_00FE76, sub_00FEA3, sub_00FEAA...), and sub_00FF48 (multiplication, ends
; at $00:FFB1 inside the unused extended-header area), followed by $FF padding
; up to the header.

sub_00FD8D:
	lda	#$006E
	bra	sub_00FD9A

sub_00FD92:
	lda	#$0041
	bra	sub_00FD9A

sub_00FD97:
	lda	#$0030

sub_00FD9A:
	ldy	a:$16B0
	bpl	loc_00FDB0
	pha
	lda	$E8
	and	#$0007
	adc	#$000C
	sta	a:$16B0
	pla
	jsl	f:sub_00868F
loc_00FDB0:
	dec	a:$16B0
	rtl

sub_00FDB4:
	lda	a:$1678
	bne	loc_00FDBE
	ldy	a:$1680
	beq	loc_00FDD1
loc_00FDBE:
	asl	a
	tax
	lda	f:tbl_00FDC9,x
	sta	$00
	jmp	($0000)
tbl_00FDC9:
	.addr	sub_00FDD2
	.addr	sub_00FDE7
	.addr	sub_00FDFC
	.addr	sub_00FE0F
loc_00FDD1:
	rtl

sub_00FDD2:
	cpy	#$0002
	beq	loc_00FDEC
	lda	a:data_05AB58,y
	sta	a:$1680
	inc	a:$1678
	lda	#$0081
	jml	f:sub_00868F

sub_00FDE7:
	dec	a:$1680
	bpl	loc_00FDD1
loc_00FDEC:
	lda	#$0002
	sta	a:$1678
	stz	a:$1680
	lda	#$0084
	jml	f:sub_00868F

sub_00FDFC:
	ldx	a:$1682
	inc	a:$1678
	stz	a:$1682
	lda	#$0040
	sta	a:$167A
	jml	f:sub_00994F

sub_00FE0F:
	lda	a:$167A
	bmi	loc_00FE19
	dec	a:$167A
	bpl	loc_00FE23
loc_00FE19:
	lda	$52
	cmp	#$00FF
	beq	loc_00FE23
	stz	a:$1678
loc_00FE23:
	rtl

; Never executed in the CDL traces (found by the unreferenced-routine heuristic).
; DB is assumed to be $05, the game's usual data bank (hint).
; (no caller found; decoded because it follows the end of a routine)
sub_00FE24:
	; (not executed in the CDL traces)
	sta	$00
	phx
	ldx	$04
	lda	$08
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	sta	$08
	lda	a:data_05AB64,x
	tay
	lda	a:$0000,y
	lsr	a
	lsr	a
	lsr	a
	and	#$003C
	clc
	adc	$08
	pha
	and	#$0020
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$06
	pla
	and	#$001C
	clc
	adc	$06
	clc
	adc	a:data_05AB68,x
	sta	$08
	lda	$02
	asl	a
	asl	a
	and	#$0380
	sta	$02
	lda	a:$0018,y
	asl	a
	asl	a
	and	#$0380
	clc
	adc	$02
	and	#$0380
	clc
	adc	$08
	plx

sub_00FE76:
	ldy	$B6
	cpy	#$0040
	bcs	loc_00FEA2
loc_00FE7D:
	sta	a:$1800,y
	clc
	adc	#$0020
	sta	a:$1802,y
	clc
	adc	#$0020
	sta	a:$1804,y
	clc
	adc	#$0020
	sta	a:$1806,y
	lda	$00
	sta	a:$1840,y
	clc
	lda	$B6
	adc	#$0008
	sta	$B6
loc_00FEA2:
	rtl

sub_00FEA3:
	ldx	$B6
	cpx	#$0040
	bcs	loc_00FEA2

sub_00FEAA:
	sta	$00
	lda	$02
	sta	$04
	lda	$00
loc_00FEB2:
	sta	a:$1800,x
	clc
	adc	#$0020
	sta	a:$1802,x
	clc
	adc	#$0020
	sta	a:$1804,x
	clc
	adc	#$0020
	sta	a:$1806,x
	lda	a:$0000,y
	sta	a:$1840,x
	dec	$02
	bne	loc_00FEE2
	lda	$04
	sta	$02
	clc
	lda	$00
	adc	#$0080
	sta	$00
	bra	loc_00FEE9
loc_00FEE2:
	clc
	lda	a:$1800,x
	adc	#$0004
loc_00FEE9:
	sta	$06
	iny
	iny
	txa
	clc
	adc	#$0008
	tax
	stx	$B6
	lda	$06
	cpx	#$0040
	bcs	loc_00FF00
	cpx	$08
	bcc	loc_00FEB2
loc_00FF00:
	rtl

sub_00FF01:
	lda	$E4
	bne	loc_00FF28
	lda	a:$1662
	beq	loc_00FF1D
	lda	$78
	and	#$000F
	bne	loc_00FF14
	dec	a:$1662
loc_00FF14:
	lda	a:$1662
	sta	$A0
	lsr	a
	sta	$A2
	rtl
loc_00FF1D:
	lda	a:$1660
	beq	loc_00FF2B
	lda	#$0001
	sta	$A0
	rtl
loc_00FF28:
	stz	a:$1660
loc_00FF2B:
	stz	$A0
	stz	$A2
	rtl

sub_00FF30:
	lda	#$0000
	sta	f:$7EA000
	phx
	phb
	lda	#$01FF
	ldx	#$A000
	ldy	#$A001
	mvn	#$7E, #$7E
	plb
	plx
	rtl

sub_00FF48:
	sep	#$20
	.a8
	lda	$08
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	sta	$0C
	sep	#$20
	.a8
	lda	$0A
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	clc
	adc	$0C
	sta	$10
	stz	$12
	lda	#$4000
	sta	$14
	stz	$16
	ldy	#$0008
loc_00FF7F:
	lda	$12
	cmp	$16
	beq	loc_00FF89
	bcc	loc_00FF8F
	bra	loc_00FF94
loc_00FF89:
	lda	$10
	cmp	$14
	bcs	loc_00FF94
loc_00FF8F:
	clc
	rol	$16
	bra	loc_00FFA4
loc_00FF94:
	sec
	lda	$10
	sbc	$14
	sta	$10
	lda	$12
	sbc	$16
	sta	$12
	sec
	rol	$16
loc_00FFA4:
	asl	$10
	rol	$12
	asl	$10
	rol	$12
	dey
	bne	loc_00FF7F
	lda	$16
	rtl
	; CDL: not accessed
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
