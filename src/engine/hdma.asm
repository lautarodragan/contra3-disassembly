; engine/hdma.asm -- HDMA tables and their NMI-time transfers
; Bank $00, $00:E369-$00:E7EE. Included by main.asm in segment BANK00.
;
; sub_00E369 clears and sets up the HDMA table buffer at $1700;
; sub_00E3DA/sub_00E464 (from NMI) compute table entries with the hardware
; divider; sub_00E4F6/sub_00E535 DMA to VRAM and sub_00E575 programs HDMA
; channels 3 and 4.

sub_00E369:
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001700
	lda	#$007E
	ldx	#$1700
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$2000
	ldx	#$A105
	jsl	f:sub_009015
	ldx	#$0020
loc_00E38C:
	lda	a:data_05A14F,x
	sta	a:$16FE,x
	dex
	dex
	bne	loc_00E38C
	ldx	#$0020
loc_00E399:
	lda	a:data_05A18F,x
	sta	a:$173E,x
	dex
	dex
	bne	loc_00E399
	lda	a:$1E02
	beq	loc_00E3CC
	lda	#$2400
	ldx	#$A12B
	jsl	f:sub_009015
	ldx	#$0020
loc_00E3B5:
	lda	a:data_05A16F,x
	sta	a:$171E,x
	dex
	dex
	bne	loc_00E3B5
	ldx	#$0020
loc_00E3C2:
	lda	a:data_05A1AF,x
	sta	a:$175E,x
	dex
	dex
	bne	loc_00E3C2
loc_00E3CC:
	rtl

sub_00E3CD:
	lda	a:$1E02
	beq	sub_00E3DA
	lda	$3A
	lsr	a
	bcc	sub_00E3DA
	brl	sub_00E464

sub_00E3DA:
	lda	a:$1F8A
	beq	loc_00E3E0
	dec	a
loc_00E3E0:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	inc	a
	sta	a:$1744
	lda	a:RDMPYL
	inc	a
	sta	a:$1746
	ldx	a:$1F80
	lda	a:data_05A1D1,x
	sta	a:$170B
	sta	a:$170D
	sta	a:$174B
	sta	a:$174D
	ldx	a:$1F82
	lda	a:data_05A1D1,x
	sta	a:$1711
	sta	a:$1713
	sta	a:$1751
	sta	a:$1753
	ldx	a:$1F84
	lda	a:data_05A1D5,x
	sta	a:$170A
	lda	a:data_05A1DB,x
	sta	a:$170C
	lda	a:data_05A1E1,x
	sta	a:$174A
	lda	a:data_05A1E7,x
	sta	a:$174C
	ldx	a:$1F86
	lda	a:data_05A1D5,x
	sta	a:$1710
	lda	a:data_05A1DB,x
	sta	a:$1712
	lda	a:data_05A1E1,x
	sta	a:$1750
	lda	a:data_05A1E7,x
	sta	a:$1752
	lda	a:$1F8C
	inc	a
	sta	a:$175C
	rep	#$20
	.a16
	rtl

sub_00E464:
	lda	a:$1FCA
	beq	loc_00E46A
	dec	a
loc_00E46A:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	inc	a
	sta	a:$1764
	lda	a:RDMPYL
	inc	a
	sta	a:$1766
	ldx	a:$1FC0
	lda	a:data_05A1D1,x
	sta	a:$172B
	sta	a:$172D
	sta	a:$176B
	sta	a:$176D
	ldx	a:$1FC2
	lda	a:data_05A1D1,x
	sta	a:$1731
	sta	a:$1733
	sta	a:$1771
	sta	a:$1773
	ldx	a:$1FC4
	lda	a:data_05A1D5,x
	sta	a:$172A
	lda	a:data_05A1DB,x
	sta	a:$172C
	lda	a:data_05A1E1,x
	sta	a:$176A
	lda	a:data_05A1E7,x
	sta	a:$176C
	ldx	a:$1FC6
	lda	a:data_05A1D5,x
	sta	a:$1730
	lda	a:data_05A1DB,x
	sta	a:$1732
	lda	a:data_05A1E1,x
	sta	a:$1770
	lda	a:data_05A1E7,x
	sta	a:$1772
	lda	a:$1FCC
	inc	a
	sta	a:$177C
	rep	#$20
	.a16
	rtl

sub_00E4EE:
	lda	$3A
	lsr	a
	bcs	sub_00E4F6
	brl	sub_00E535

sub_00E4F6:
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	ldx	#$5C25
	stx	a:VMADDL
	ldx	#$1801
	stx	a:DMAP0
	stz	a:A1B0
	ldx	#$170A
	stx	a:A1T0L
	ldx	#$0010
	stx	a:DAS0L
	lda	#$01
	sta	a:MDMAEN
	ldx	#$5C42
	stx	a:VMADDL
	ldx	#$1744
	stx	a:A1T0L
	ldx	#$001A
	stx	a:DAS0L
	sta	a:MDMAEN
	rep	#$20
	.a16
	rtl

sub_00E535:
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	ldx	#$5C35
	stx	a:VMADDL
	ldx	#$1801
	stx	a:DMAP0
	stz	a:A1B0
	ldx	#$172A
	stx	a:A1T0L
	ldx	#$0010
	stx	a:DAS0L
	lda	#$01
	sta	a:MDMAEN
	ldx	#$5C52
	stx	a:VMADDL
	ldx	#$1764
	stx	a:A1T0L
	ldx	#$001A
	stx	a:DAS0L
	sta	a:MDMAEN
	rep	#$20
	.a16
	rtl
loc_00E574:
	rtl

sub_00E575:
	stz	$00
	sep	#$20
	.a8
	stz	a:HDMAEN
	rep	#$30
	.a16
	lda	a:$1600
	cmp	#$0002
	bcc	loc_00E574
	lda	$46
	beq	loc_00E5B6
	dec	a
	asl	a
	tax
	ldy	a:data_05A1ED,x
loc_00E590:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	loc_00E5B1
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	sta	$06,x
	tya
	clc
	adc	#$0008
	tay
	bra	loc_00E590
loc_00E5B1:
	lda	a:$0002,y
	sta	$00
loc_00E5B6:
	lda	$9E
	beq	loc_00E5CA
	sta	a:A1T3L
	lda	#$2641
	sta	a:DMAP3
	lda	#$0008
	ora	$00
	sta	$00
loc_00E5CA:
	lda	$C6
	beq	loc_00E5DE
	sta	a:A1T4L
	lda	#$3242
	sta	a:DMAP4
	lda	#$0010
	ora	$00
	sta	$00
loc_00E5DE:
	sep	#$20
	.a8
	lda	#$7E
	sta	a:A1B3
	sta	a:DASB3
	sta	a:A1B4
	sta	a:DASB4
	lda	$00
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl
loc_00E5F6:
	rtl

sub_00E5F7:
	lda	a:$1676
	beq	loc_00E5F6
	dec	a
	asl	a
	tay
	lda	#$D000
	sta	$00
	lda	a:data_05A25A,y
	sta	$04
	lda	#$D400
	phx
	jsr	a:sub_00E61B
	jsr	a:sub_00E6B4
	plx
	rtl
loc_00E615:
	iny
	iny
	iny
	iny
	bra	loc_00E637

sub_00E61B:
	sta	$02
	sta	$FC
	lda	$00
	sta	$FE
	stz	$08
	stz	$0C
	lda	a:$1674
	and	#$FF00
	xba
	asl	a
	tay
	lda	($04),y
	sta	$06
	ldy	#$0000
loc_00E637:
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	sec
	lda	($06),y
	sbc	a:$1674
	bmi	loc_00E615
	beq	loc_00E615
	cmp	#$00DF
	bcc	loc_00E653
	inc	$0C
	lda	#$00DF
loc_00E653:
	and	#$00FF
	sta	$0A
	sec
	sbc	$08
	and	#$007F
	pha
	lda	$0A
	sta	$08
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	($00)
	inc	$00
	lda	$02
	inc	a
	inc	a
	clc
	adc	#$0400
	sta	($00)
	inc	$00
	inc	$00
	iny
	iny
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	lda	($06),y
	pha
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	($02)
	inc	$02
	inc	$02
	inc	$02
	inc	$02
	iny
	iny
	lda	$0C
	bne	loc_00E6A6
	bra	loc_00E637
loc_00E6A6:
	lda	#$0000
	sta	($00)
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts

sub_00E6B4:
	ldx	$FE
	lda	f:$7E0000,x
	beq	loc_00E6DA
	ldx	$FC
	lda	f:$7E0000,x
	sta	$02
	and	#$00FE
	jsr	a:sub_00E6DB
	inc	$FE
	inc	$FE
	inc	$FE
	inc	$FC
	inc	$FC
	inc	$FC
	inc	$FC
	bra	sub_00E6B4
loc_00E6DA:
	rts

sub_00E6DB:
	tay
	lda	a:tbl_05A35C,y
	sta	$00
	jmp	($0000)

sub_00E6E4:
	lda	$03
	and	#$00FF
	phx
	tax
	lda	f:$7EE000,x
	plx
	sta	f:$7E0002,x
	rts

sub_00E6F5:
	lda	a:$1380
	sta	f:$7E0002,x
	rts

sub_00E6FD:
	lda	a:$13C0
	sta	f:$7E0002,x
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00E705:
	; (not executed in the CDL traces)
	lda	#$0007
	sta	$46
	lda	$20
	bit	#$0800
	beq	loc_00E714
	dec	a:$1674
loc_00E714:
	bit	#$0400
	beq	loc_00E71C
	inc	a:$1674
loc_00E71C:
	lda	a:$1674
	and	#$01FF
	sta	a:$1674
	lda	#$D000
	sta	$00
	lda	#$A260
	sta	$04
	lda	#$D400
	rts
loc_00E733:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	stz	a:$E800
	phx
	phb
	lda	#$03FF
	ldx	#$E800
	ldy	#$E801
	mvn	#$7E, #$7E
	plb
	plx
	lda	#$00FF
	sta	a:$EA00
	stz	a:$EA06
	lda	#$FFE8
	sta	a:$EA02
	lda	#$E900
	sta	a:$EA04
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_00E76C:
	pha
	tya
	asl	a
	clc
	adc	#$E800
	sta	f:$7EEA01
	clc
	adc	#$00FC
	sta	f:$7EEA04
	pla
	phx
	stz	$02
	stz	$04
	pha
	lda	#$00FF
	sta	a:WRDIVL
	pla
	sep	#$20
	.a8
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rep	#$20
	.a16
	lda	a:RDDIVL
	asl	a
	sta	$03
	asl	$03
	asl	$03
	asl	$03
	stz	$08
	stz	$0A
	stz	$06
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldx	#$00FE
	ldy	#$0000
loc_00E7BC:
	clc
	lda	$00
	adc	$08
	sta	a:$E800,x
	clc
	lda	$00
	adc	$0A
	sta	a:$E900,y
	clc
	lda	$06
	adc	$02
	sta	$06
	lda	$08
	adc	$04
	sta	$08
	eor	#$FFFF
	inc	a
	sta	$0A
	iny
	iny
	dex
	dex
	bpl	loc_00E7BC
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	plx
	rtl
