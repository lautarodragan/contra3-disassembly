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
	ldy	a:wram_16B0
	bpl	loc_00FDB0
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:wram_16B0
	pla
	jsl	f:queue_sound
loc_00FDB0:
	dec	a:wram_16B0
	rtl

sub_00FDB4:
	lda	a:wram_1678
	bne	loc_00FDBE
	ldy	a:wram_1680
	beq	loc_00FDD1
loc_00FDBE:
	asl	a
	tax
	lda	f:tbl_00FDC9,x
	sta	zp_00
	jmp	(zp_00)
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
	sta	a:wram_1680
	inc	a:wram_1678
	lda	#$0081
	jml	f:queue_sound

sub_00FDE7:
	dec	a:wram_1680
	bpl	loc_00FDD1
loc_00FDEC:
	lda	#$0002
	sta	a:wram_1678
	stz	a:wram_1680
	lda	#$0084
	jml	f:queue_sound

sub_00FDFC:
	ldx	a:wram_1682
	inc	a:wram_1678
	stz	a:wram_1682
	lda	#$0040
	sta	a:wram_167A
	jml	f:sub_00994F

sub_00FE0F:
	lda	a:wram_167A
	bmi	loc_00FE19
	dec	a:wram_167A
	bpl	loc_00FE23
loc_00FE19:
	lda	apu_pending_cmd
	cmp	#$00FF
	beq	loc_00FE23
	stz	a:wram_1678
loc_00FE23:
	rtl

; Never executed in the CDL traces (found by the unreferenced-routine heuristic).
; DB is assumed to be $05, the game's usual data bank (hint).
; (no caller found; decoded because it follows the end of a routine)
sub_00FE24:
	; (not executed in the CDL traces)
	sta	zp_00
	phx
	ldx	zp_04
	lda	zp_08
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	sta	zp_08
	lda	a:data_05AB64,x
	tay
	lda	a:$0000,y
	lsr	a
	lsr	a
	lsr	a
	and	#$003C
	clc
	adc	zp_08
	pha
	and	#$0020
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_06
	pla
	and	#$001C
	clc
	adc	zp_06
	clc
	adc	a:data_05AB68,x
	sta	zp_08
	lda	zp_02
	asl	a
	asl	a
	and	#$0380
	sta	zp_02
	lda	a:$0018,y
	asl	a
	asl	a
	and	#$0380
	clc
	adc	zp_02
	and	#$0380
	clc
	adc	zp_08
	plx

sub_00FE76:
	ldy	zp_B6
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
	lda	zp_00
	sta	a:$1840,y
	clc
	lda	zp_B6
	adc	#$0008
	sta	zp_B6
loc_00FEA2:
	rtl

sub_00FEA3:
	ldx	zp_B6
	cpx	#$0040
	bcs	loc_00FEA2

sub_00FEAA:
	sta	zp_00
	lda	zp_02
	sta	zp_04
	lda	zp_00
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
	dec	zp_02
	bne	loc_00FEE2
	lda	zp_04
	sta	zp_02
	clc
	lda	zp_00
	adc	#$0080
	sta	zp_00
	bra	loc_00FEE9
loc_00FEE2:
	clc
	lda	a:$1800,x
	adc	#$0004
loc_00FEE9:
	sta	zp_06
	iny
	iny
	txa
	clc
	adc	#$0008
	tax
	stx	zp_B6
	lda	zp_06
	cpx	#$0040
	bcs	loc_00FF00
	cpx	zp_08
	bcc	loc_00FEB2
loc_00FF00:
	rtl

sub_00FF01:
	lda	zp_E4
	bne	loc_00FF28
	lda	a:wram_1662
	beq	loc_00FF1D
	lda	zp_78
	and	#$000F
	bne	loc_00FF14
	dec	a:wram_1662
loc_00FF14:
	lda	a:wram_1662
	sta	zp_A0
	lsr	a
	sta	zp_A2
	rtl
loc_00FF1D:
	lda	a:wram_1660
	beq	loc_00FF2B
	lda	#$0001
	sta	zp_A0
	rtl
loc_00FF28:
	stz	a:wram_1660
loc_00FF2B:
	stz	zp_A0
	stz	zp_A2
	rtl

sub_00FF30:
	lda	#$0000
	sta	f:wram_7EA000
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
	lda	zp_08
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	sta	zp_0C
	sep	#$20
	.a8
	lda	zp_0A
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	clc
	adc	zp_0C
	sta	zp_10
	stz	zp_12
	lda	#$4000
	sta	zp_14
	stz	zp_16
	ldy	#$0008
loc_00FF7F:
	lda	zp_12
	cmp	zp_16
	beq	loc_00FF89
	bcc	loc_00FF8F
	bra	loc_00FF94
loc_00FF89:
	lda	zp_10
	cmp	zp_14
	bcs	loc_00FF94
loc_00FF8F:
	clc
	rol	zp_16
	bra	loc_00FFA4
loc_00FF94:
	sec
	lda	zp_10
	sbc	zp_14
	sta	zp_10
	lda	zp_12
	sbc	zp_16
	sta	zp_12
	sec
	rol	zp_16
loc_00FFA4:
	asl	zp_10
	rol	zp_12
	asl	zp_10
	rol	zp_12
	dey
	bne	loc_00FF7F
	lda	zp_16
	rtl
	; CDL: not accessed
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
