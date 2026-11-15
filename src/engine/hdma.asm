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
	sta	f:wram_1700
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
	lda	a:title_menu_cursor
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
	lda	a:title_menu_cursor
	beq	sub_00E3DA
	lda	frame_counter
	lsr	a
	bcc	sub_00E3DA
	brl	sub_00E464

sub_00E3DA:
	lda	a:p1_lives
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
	sta	a:wram_1744
	lda	a:RDMPYL
	inc	a
	sta	a:wram_1746
	ldx	a:p1_weapon_slot
	lda	a:data_05A1D1,x
	sta	a:wram_170B
	sta	a:wram_170D
	sta	a:wram_174B
	sta	a:wram_174D
	ldx	a:wram_1F82
	lda	a:data_05A1D1,x
	sta	a:wram_1711
	sta	a:wram_1713
	sta	a:wram_1751
	sta	a:wram_1753
	ldx	a:p1_weapon_1
	lda	a:data_05A1D5,x
	sta	a:wram_170A
	lda	a:data_05A1DB,x
	sta	a:wram_170C
	lda	a:data_05A1E1,x
	sta	a:wram_174A
	lda	a:data_05A1E7,x
	sta	a:wram_174C
	ldx	a:p1_weapon_2
	lda	a:data_05A1D5,x
	sta	a:wram_1710
	lda	a:data_05A1DB,x
	sta	a:wram_1712
	lda	a:data_05A1E1,x
	sta	a:wram_1750
	lda	a:data_05A1E7,x
	sta	a:wram_1752
	lda	a:p1_bombs
	inc	a
	sta	a:wram_175C
	rep	#$20
	.a16
	rtl

sub_00E464:
	lda	a:p2_lives
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
	sta	a:wram_1764
	lda	a:RDMPYL
	inc	a
	sta	a:wram_1766
	ldx	a:p2_weapon_slot
	lda	a:data_05A1D1,x
	sta	a:wram_172B
	sta	a:wram_172D
	sta	a:wram_176B
	sta	a:wram_176D
	ldx	a:wram_1FC2
	lda	a:data_05A1D1,x
	sta	a:wram_1731
	sta	a:wram_1733
	sta	a:wram_1771
	sta	a:wram_1773
	ldx	a:p2_weapon_1
	lda	a:data_05A1D5,x
	sta	a:wram_172A
	lda	a:data_05A1DB,x
	sta	a:wram_172C
	lda	a:data_05A1E1,x
	sta	a:wram_176A
	lda	a:data_05A1E7,x
	sta	a:wram_176C
	ldx	a:p2_weapon_2
	lda	a:data_05A1D5,x
	sta	a:wram_1730
	lda	a:data_05A1DB,x
	sta	a:wram_1732
	lda	a:data_05A1E1,x
	sta	a:wram_1770
	lda	a:data_05A1E7,x
	sta	a:wram_1772
	lda	a:p2_bombs
	inc	a
	sta	a:wram_177C
	rep	#$20
	.a16
	rtl

sub_00E4EE:
	lda	frame_counter
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
	stz	zp_00
	sep	#$20
	.a8
	stz	a:HDMAEN
	rep	#$30
	.a16
	lda	a:wram_1600
	cmp	#$0002
	bcc	loc_00E574
	lda	hdma_preset
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
	sta	zp_00
loc_00E5B6:
	lda	zp_9E
	beq	loc_00E5CA
	sta	a:A1T3L
	lda	#$2641
	sta	a:DMAP3
	lda	#$0008
	ora	zp_00
	sta	zp_00
loc_00E5CA:
	lda	zp_C6
	beq	loc_00E5DE
	sta	a:A1T4L
	lda	#$3242
	sta	a:DMAP4
	lda	#$0010
	ora	zp_00
	sta	zp_00
loc_00E5DE:
	sep	#$20
	.a8
	lda	#$7E
	sta	a:A1B3
	sta	a:DASB3
	sta	a:A1B4
	sta	a:DASB4
	lda	zp_00
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl
loc_00E5F6:
	rtl

sub_00E5F7:
	lda	a:wram_1676
	beq	loc_00E5F6
	dec	a
	asl	a
	tay
	lda	#$D000
	sta	zp_00
	lda	a:data_05A25A,y
	sta	zp_04
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
	sta	zp_02
	sta	zp_FC
	lda	zp_00
	sta	zp_FE
	stz	zp_08
	stz	zp_0C
	lda	a:wram_1674
	and	#$FF00
	xba
	asl	a
	tay
	lda	(zp_04),y
	sta	zp_06
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
	lda	(zp_06),y
	sbc	a:wram_1674
	bmi	loc_00E615
	beq	loc_00E615
	cmp	#$00DF
	bcc	loc_00E653
	inc	zp_0C
	lda	#$00DF
loc_00E653:
	and	#$00FF
	sta	zp_0A
	sec
	sbc	zp_08
	and	#$007F
	pha
	lda	zp_0A
	sta	zp_08
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	(zp_00)
	inc	zp_00
	lda	zp_02
	inc	a
	inc	a
	clc
	adc	#$0400
	sta	(zp_00)
	inc	zp_00
	inc	zp_00
	iny
	iny
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	lda	(zp_06),y
	pha
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	(zp_02)
	inc	zp_02
	inc	zp_02
	inc	zp_02
	inc	zp_02
	iny
	iny
	lda	zp_0C
	bne	loc_00E6A6
	bra	loc_00E637
loc_00E6A6:
	lda	#$0000
	sta	(zp_00)
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts

sub_00E6B4:
	ldx	zp_FE
	lda	f:$7E0000,x
	beq	loc_00E6DA
	ldx	zp_FC
	lda	f:$7E0000,x
	sta	zp_02
	and	#$00FE
	jsr	a:sub_00E6DB
	inc	zp_FE
	inc	zp_FE
	inc	zp_FE
	inc	zp_FC
	inc	zp_FC
	inc	zp_FC
	inc	zp_FC
	bra	sub_00E6B4
loc_00E6DA:
	rts

sub_00E6DB:
	tay
	lda	a:tbl_05A35C,y
	sta	zp_00
	jmp	(zp_00)

sub_00E6E4:
	lda	zp_03
	and	#$00FF
	phx
	tax
	lda	f:$7EE000,x
	plx
	sta	f:$7E0002,x
	rts

sub_00E6F5:
	lda	a:wram_1380
	sta	f:$7E0002,x
	rts

sub_00E6FD:
	lda	a:wram_13C0
	sta	f:$7E0002,x
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00E705:
	; (not executed in the CDL traces)
	lda	#$0007
	sta	hdma_preset
	lda	joy1_held
	bit	#$0800
	beq	loc_00E714
	dec	a:wram_1674
loc_00E714:
	bit	#$0400
	beq	loc_00E71C
	inc	a:wram_1674
loc_00E71C:
	lda	a:wram_1674
	and	#$01FF
	sta	a:wram_1674
	lda	#$D000
	sta	zp_00
	lda	#$A260
	sta	zp_04
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
	sta	f:wram_7EEA01
	clc
	adc	#$00FC
	sta	f:wram_7EEA04
	pla
	phx
	stz	zp_02
	stz	zp_04
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
	sta	zp_03
	asl	zp_03
	asl	zp_03
	asl	zp_03
	stz	zp_08
	stz	zp_0A
	stz	zp_06
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
	lda	zp_00
	adc	zp_08
	sta	a:$E800,x
	clc
	lda	zp_00
	adc	zp_0A
	sta	a:$E900,y
	clc
	lda	zp_06
	adc	zp_02
	sta	zp_06
	lda	zp_08
	adc	zp_04
	sta	zp_08
	eor	#$FFFF
	inc	a
	sta	zp_0A
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
