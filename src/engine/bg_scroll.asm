; engine/bg_scroll.asm -- BG scrolling and tilemap updates
; Bank $00, $00:C283-$00:CF0B. Included by main.asm in segment BANK00.
;
; sub_00C283/sub_00C575 (from NMI) DMA the tilemap rows/columns queued at
; $1780 to VRAM; sub_00C612..sub_00CC37 scroll the BG layers, whose state is
; at $1380 and $13C0 ($40 bytes each). Tables data_00CD0A..data_00CD90.

sub_00C283:
	sep	#$10
	.i8
	lda	zp_B8
	bne	loc_00C28C
	brl	loc_00C33B
loc_00C28C:
	sta	a:VMADDL
	ldx	#$80
	stx	a:VMAIN
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_1780
	sta	a:A1T0L
	lda	#$007F
	sta	a:A1B0
	ldy	#$40
	sty	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_1782
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1784
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1786
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1788
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_178A
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	zp_BA
	sta	a:VMADDL
	lda	a:wram_178C
	sta	a:A1T0L
	sty	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_178E
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1790
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1792
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1794
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1796
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
loc_00C33B:
	ldy	#$01
	ldx	#$7E
	stx	a:A1B0
	lda	zp_B0
	beq	loc_00C356
	sta	a:VMADDL
	lda	zp_B4
	sta	a:A1T0L
	lda	zp_B2
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C356:
	lda	a:wram_1800
	beq	loc_00C396
	sta	a:VMADDL
	lda	a:wram_1840
	sta	a:A1T0L
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1802
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1804
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1806
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C396:
	lda	a:wram_1808
	beq	loc_00C3DA
	sta	a:VMADDL
	lda	a:wram_1848
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_180A
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_180C
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_180E
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C3DA:
	lda	a:wram_1810
	beq	loc_00C41E
	sta	a:VMADDL
	lda	a:wram_1850
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1812
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1814
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1816
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C41E:
	lda	a:wram_1818
	beq	loc_00C462
	sta	a:VMADDL
	lda	a:wram_1858
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_181A
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_181C
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_181E
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C462:
	lda	a:wram_1820
	beq	loc_00C4A6
	sta	a:VMADDL
	lda	a:wram_1860
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1822
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1824
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1826
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C4A6:
	lda	a:wram_1828
	beq	loc_00C4EA
	sta	a:VMADDL
	lda	a:wram_1868
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_182A
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_182C
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_182E
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C4EA:
	lda	a:wram_1830
	beq	loc_00C52E
	sta	a:VMADDL
	lda	a:wram_1870
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1832
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1834
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_1836
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C52E:
	lda	a:wram_1838
	beq	loc_00C572
	sta	a:VMADDL
	lda	a:wram_1878
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_183A
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_183C
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:wram_183E
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
loc_00C572:
	rep	#$10
	.i16
	rtl

sub_00C575:
	ldx	#$0000
	ldy	#$0001
	lda	#$5C00
	sta	zp_0E
	sta	zp_00
	lda	#$0008
	sta	zp_0A
loc_00C587:
	lda	a:data_058CE2,x
	sta	zp_08
	sep	#$10
	.i8
	lda	#$1801
	sta	a:DMAP0
	ldy	#$80
	sty	a:VMAIN
	lda	#$007E
	sta	a:A1B0
	lda	zp_00
	sta	a:VMADDL
	lda	zp_08
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	ldy	#$01
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0020
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0040
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0060
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	rep	#$10
	.i16
	dec	zp_0A
	bne	loc_00C5FF
	lda	#$0008
	sta	zp_0A
	clc
	lda	zp_0E
	adc	#$0080
	sta	zp_0E
	bra	loc_00C605
loc_00C5FF:
	clc
	lda	zp_00
	adc	#$0004
loc_00C605:
	sta	zp_00
	inx
	inx
	cpx	#$0070
	bcs	loc_00C611
	brl	loc_00C587
loc_00C611:
	rtl

sub_00C612:
	stx	zp_FC
	sty	zp_FE
	stz	$32,x
	stz	$18,x
	lda	#$0100
	sta	$00,x
	lda	zp_FC
	cmp	#$1380
	bne	loc_00C632
	lda	stage_number
	cmp	#$0004
	beq	loc_00C632
	lda	#$0020
	bra	loc_00C635
loc_00C632:
	lda	#$003F
loc_00C635:
	sta	zp_18
loc_00C637:
	ldx	zp_FC
	jsl	f:sub_00CB29
	lda	zp_FC
	cmp	#$1380
	bne	loc_00C648
	jsl	f:sub_00CC37
loc_00C648:
	jsl	f:run_vram_queue
	ldx	zp_FC
	clc
	lda	$00,x
	adc	#$0008
	sta	$00,x
	cmp	#$01FF
	bcc	loc_00C665
	stz	$00,x
	clc
	lda	$3C,x
	adc	#$0080
	sta	$3C,x
loc_00C665:
	dec	zp_18
	bpl	loc_00C637
	stz	$00,x
	stz	$02,x
	lda	#$0000
	sta	a:wram_13BA
	lda	#$0005
	sta	a:wram_13FA
	stz	a:wram_13B0
	rtl

sub_00C67D:
	lda	a:wram_13BA
	phx
	asl	a
	tax
	lda	f:tbl_00C68D,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00C68D:
	.addr	sub_00C6A2
	.addr	sub_00C705
	.addr	sub_00C7BF
	.addr	sub_00C82A
	.addr	sub_00C69B
	.addr	sub_00C8F8
	.addr	sub_00C8C8

sub_00C69B:
	stz	a:wram_138E
	stz	a:wram_13A6
	rtl

sub_00C6A2:
	lda	#$0080
	sta	zp_A6
	jsl	f:sub_00CC1D
	stz	a:wram_13B2
	lda	#$0001
	sta	a:wram_13BA
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:sub_00CB29
	jsl	f:sub_00CC37
	clc
	lda	a:wram_1380
	adc	#$0008
	sta	a:wram_1380
	ldx	#$1380
	ldy	#$4000
	jsl	f:sub_00CB29
	jsl	f:sub_00CC37
	lda	#$0002
	sta	a:wram_13B2
	sec
	lda	a:wram_1380
	sbc	#$0008
	sta	a:wram_1380
	sta	a:wram_160C
	clc
	adc	#$0010
	and	#$FF00
	sta	a:wram_13B0
	stz	a:wram_1608
	lda	#$1380
	sta	a:wram_160A
	rtl

sub_00C705:
	lda	a:wram_13B4
	bne	loc_00C77B
	ldx	#$0080
	lda	a:p1_lives
	beq	loc_00C71A
	lda	a:p2_lives
	beq	loc_00C71A
	ldx	#$00A0
loc_00C71A:
	stx	zp_A6
	lda	a:wram_020A
	cmp	zp_A6
	bcc	loc_00C731
	ldx	#$0200
	ldy	#$0240
	lda	$1A,x
	beq	loc_00C76E
	bmi	loc_00C76E
	bra	loc_00C749
loc_00C731:
	lda	a:p2_lives
	beq	loc_00C75E
	lda	a:wram_024A
	cmp	zp_A6
	bcc	loc_00C75E
	ldx	#$0240
	ldy	#$0200
	lda	$1A,x
	beq	loc_00C76E
	bmi	loc_00C76E
loc_00C749:
	lda	a:$1D8A,y
	beq	loc_00C765
	lda	a:$000A,y
	cmp	#$000C
	bcs	loc_00C765
	sec
	lda	$0A,x
	sbc	a:$1306,x
	sta	$0A,x
loc_00C75E:
	stz	a:wram_138E
	stz	a:$1306,x
	rtl
loc_00C765:
	clc
	lda	a:$1306,x
	sta	a:wram_138E
	bra	loc_00C78E
loc_00C76E:
	lda	a:$1D8A,y
	beq	loc_00C77B
	lda	a:$000A,y
	cmp	#$000C
	bcc	loc_00C75E
loc_00C77B:
	clc
	lda	a:wram_1384
	adc	#$6800
	sta	a:wram_1384
	lda	#$0000
	adc	#$0001
	sta	a:wram_138E
loc_00C78E:
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	$00,x
	adc	$0E,x
	sta	$00,x
	clc
	lda	$32,x
	asl	a
	asl	a
	asl	a
	adc	$00,x
	and	#$FF00
	cmp	$30,x
	beq	loc_00C7B8
	sta	$30,x
	clc
	lda	$3C,x
	adc	#$0080
	sta	$3C,x
loc_00C7B8:
	jsl	f:sub_00CB29
	jmp	a:sub_00CC37

sub_00C7BF:
	lda	#$0060
	sta	zp_A6
	jsl	f:sub_00CC1D
	inc	a:wram_13BA
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:sub_00CA52
	jsl	f:sub_00CC37
	clc
	lda	a:wram_1398
	adc	#$0008
	sta	a:wram_1398
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:sub_00CA52
	jsl	f:sub_00CC37
	sec
	lda	a:wram_1398
	sbc	#$0008
	sta	a:wram_1398
	clc
	adc	#$00F0
	and	#$FF00
	sta	a:wram_13B0
	lda	a:wram_1398
	and	#$FF00
	sta	a:wram_160C
	lda	#$FFFF
	sta	a:wram_1608
	lda	#$1398
	sta	a:wram_160A
	rtl
loc_00C823:
	stz	a:wram_13A4
	stz	a:wram_13A6
	rtl

sub_00C82A:
	lda	a:wram_13B4
	bne	loc_00C883
	lda	a:p1_lives
	beq	loc_00C846
	lda	a:wram_020E
	bmi	loc_00C83D
	cmp	zp_A6
	bcs	loc_00C846
loc_00C83D:
	ldx	#$0200
	lda	$1E,x
	bpl	loc_00C883
	bmi	loc_00C85B
loc_00C846:
	lda	a:p2_lives
	beq	loc_00C823
	; (not executed in the CDL traces)
	lda	a:wram_024E
	bmi	loc_00C854
	cmp	zp_A6
	bcs	loc_00C823
loc_00C854:
	ldx	#$0240
	lda	$1E,x
	bpl	loc_00C883
loc_00C85B:
	clc
	lda	$0C,x
	adc	$1C,x
	lda	$0E,x
	sta	zp_00
	adc	$1E,x
	sec
	sbc	zp_00
	sta	a:wram_13A6
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	$18,x
	adc	a:wram_13A6
	sta	$18,x
	stz	a:wram_13A4
	bra	loc_00C8AA
loc_00C883:
	ldy	a:wram_13B6
	clc
	lda	a:data_058D52,y
	adc	a:wram_13A4
	sta	a:wram_13A4
	lda	#$FFFF
	adc	#$0000
	sta	a:wram_13A6
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	$18,x
	adc	$26,x
	sta	$18,x
loc_00C8AA:
	clc
	lda	#$00F0
	adc	$18,x
	and	#$FF00
	cmp	$30,x
	beq	loc_00C8C1
	sta	$30,x
	clc
	lda	$3C,x
	adc	#$0080
	sta	$3C,x
loc_00C8C1:
	jsl	f:sub_00CA52
	jmp	a:sub_00CC37

sub_00C8C8:
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	#$00F0
	adc	$18,x
	and	#$FF00
	cmp	$30,x
	beq	loc_00C8E9
	sta	$30,x
	clc
	lda	$3C,x
	adc	#$0080
	sta	$3C,x
loc_00C8E9:
	jsl	f:sub_00CA52
	jmp	a:sub_00CC37

sub_00C8F0:
	ldx	#$13C0
	ldy	#$A000
	bra	loc_00C8FE

sub_00C8F8:
	ldx	#$1380
	ldy	#$4000
loc_00C8FE:
	stx	zp_FC
	sty	zp_FE
	clc
	lda	#$0008
	sta	$32,x
	asl	a
	asl	a
	asl	a
	adc	$00,x
	and	#$FF00
	lsr	a
	sta	$3C,x
	jml	f:sub_00CB29

sub_00C917:
	lda	a:wram_13FA
	phx
	asl	a
	tax
	lda	f:tbl_00C927,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00C927:
	.addr	sub_00C941
	.addr	sub_00C982
	.addr	sub_00C942
	.addr	sub_00C9AB
	.addr	sub_00C99B
	.addr	sub_00C9AC
	.addr	sub_00C9CC
	.addr	sub_00C9F7
	.addr	sub_00CA3C
	.addr	sub_00CA3D
	.addr	sub_00C9CC
	.addr	sub_00C9E0
	.addr	sub_00C8F0

sub_00C941:
	rtl

sub_00C942:
	lda	a:wram_13FE
	bne	loc_00C97E
	lda	a:wram_13C2
	sta	a:wram_13C0
	ldx	#$13C0
	stx	zp_FC
	ldy	#$A000
	sty	zp_FE
	jsl	f:sub_00CB29
	sec
	lda	a:wram_13C2
	sbc	#$0008
	sta	a:wram_13C2
	cmp	#$00F8
	bne	loc_00C976
	clc
	lda	a:wram_13FC
	adc	#$0080
	sta	a:wram_13FC
	bra	loc_00C97E
loc_00C976:
	cmp	#$FFF8
	bne	loc_00C97E
	inc	a:wram_13FE
loc_00C97E:
	stz	a:wram_13C0
	rtl

sub_00C982:
	stz	a:wram_13F2
	stz	a:wram_13D8
	stz	a:wram_13DC
	stz	a:wram_13C0
	stz	a:wram_13C4
	lda	#$01F8
	sta	a:wram_13C2
	inc	a:wram_13FA
	rtl

sub_00C99B:
	jsl	f:sub_00C9AC
	lda	a:wram_13C0
	sta	f:wram_7E3801
	sta	f:wram_7E3804
	rtl

sub_00C9AB:
	; (not executed in the CDL traces)
	rtl

sub_00C9AC:
	stz	a:wram_13D2
	stz	a:wram_13EA
	clc
	lda	a:wram_138E
	adc	a:wram_13CE
	sta	a:wram_13CE
	sec
	sbc	#$0008
	bmi	loc_00C9CB
	sta	a:wram_13CE
	inc	a:wram_13C0
	inc	a:wram_13D2
loc_00C9CB:
	rtl

sub_00C9CC:
	clc
	lda	a:wram_13C4
	adc	#$2000
	sta	a:wram_13C4
	lda	a:wram_13C0
	adc	#$0001
	sta	a:wram_13C0
	rtl

sub_00C9E0:
	sec
	lda	a:wram_13DC
	sbc	#$A000
	sta	a:wram_13DC
	lda	a:wram_13D8
	sbc	#$0000
	sta	a:wram_13D8
	jsl	f:sub_00C9CC

sub_00C9F7:
	ldx	#$13C0
	stx	zp_FC
	ldy	#$A000
	sty	zp_FE
	lda	$00,x
	and	#$00FF
	sta	$00,x
	stz	$12,x
	stz	$2A,x
	clc
	lda	a:wram_13A6
	adc	$26,x
	sta	$26,x
loc_00CA14:
	clc
	adc	#$0003
	bpl	loc_00CA22
	sta	$26,x
	dec	$18,x
	dec	$2A,x
	bra	loc_00CA14
loc_00CA22:
	clc
	lda	#$00F0
	adc	$18,x
	and	#$FF00
	cmp	$30,x
	beq	loc_00CA39
	sta	$30,x
	clc
	lda	$3C,x
	adc	#$0080
	sta	$3C,x
loc_00CA39:
	brl	sub_00CA52

sub_00CA3C:
	; (not executed in the CDL traces)
	rtl

sub_00CA3D:
	clc
	lda	a:wram_138E
	sta	a:wram_13CE
	sta	a:wram_13D2
	stz	a:wram_13EA
	clc
	adc	a:wram_13C0
	sta	a:wram_13C0
	rtl

sub_00CA52:
	clc
	lda	$18,x
	adc	#$0010
	and	#$0018
	sta	zp_0A
	lda	$18,x
	lsr	a
	sec
	sbc	#$0008
	and	#$0070
	clc
	adc	zp_FE
	adc	$3C,x
	adc	#$5000
	sta	zp_00
	lda	vram_queue_end
	sta	zp_1A
	lda	#$0008
	sta	zp_06
	lda	#$FFFF
	sta	zp_0C
	lda	$00,x
	and	#$0100
	asl	a
	asl	a
	sta	zp_04
	clc
	lda	$18,x
	adc	#$00F0
	and	#$00F8
	asl	a
	asl	a
	ora	zp_04
	sta	zp_04
	ldx	zp_FE
	cpx	#$4000
	bne	loc_00CAA4
	clc
	adc	#$4000
	bra	loc_00CAA8
loc_00CAA4:
	clc
	adc	#$4800
loc_00CAA8:
	sta	zp_04
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0080
	ldy	zp_04
	jsl	f:begin_vram_transfer_vmain
loc_00CABB:
	lda	(zp_00)
	and	#$3FFF
	clc
	adc	#$1000
	adc	zp_FE
	tay
	lda	(zp_00)
	and	#$C000
	cmp	zp_0C
	beq	loc_00CAEF
	sta	zp_0C
	xba
	lsr	a
	ora	zp_0A
	tax
	lda	f:data_00CD8A,x
	sta	zp_10
	lda	f:data_00CD8C,x
	sta	zp_12
	lda	f:data_00CD8E,x
	sta	zp_14
	lda	f:data_00CD90,x
	sta	zp_16
loc_00CAEF:
	ldx	vram_queue_data_ptr
	lda	(zp_10),y
	eor	zp_0C
	sta	a:$0000,x
	lda	(zp_12),y
	eor	zp_0C
	sta	a:$0002,x
	lda	(zp_14),y
	eor	zp_0C
	sta	a:$0004,x
	lda	(zp_16),y
	eor	zp_0C
	sta	a:$0006,x
	txa
	clc
	adc	#$0008
	sta	vram_queue_data_ptr
	inc	zp_00
	inc	zp_00
	dec	zp_06
	bne	loc_00CABB
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_00CB29:
	lda	$32,x
	asl	a
	asl	a
	asl	a
	clc
	adc	$00,x
	and	#$0018
	sta	zp_0A
	lda	$00,x
	and	#$00F8
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	$32,x
	sta	zp_08
	lsr	a
	and	#$000E
	clc
	adc	zp_FE
	adc	$3C,x
	adc	#$5000
	sta	zp_02
	lda	vram_queue_end
	sta	zp_1A
	ldy	#$0008
	cpx	#$1380
	bne	loc_00CB60
	ldy	#$0007
loc_00CB60:
	sty	zp_06
	lda	#$FFFF
	sta	zp_0C
	ldy	#$0000
	clc
	lda	zp_08
	bit	#$FFE0
	bne	loc_00CB75
	ldy	#$0100
loc_00CB75:
	sty	zp_1C
	and	#$001F
	sta	zp_04
	lda	$00,x
	and	#$0100
	eor	zp_1C
	asl	a
	asl	a
	ora	zp_04
	ldx	zp_FE
	cpx	#$4000
	bne	loc_00CB94
	clc
	adc	#$4000
	bra	loc_00CB98
loc_00CB94:
	clc
	adc	#$4800
loc_00CB98:
	sta	zp_04
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0081
	ldy	zp_04
	jsl	f:begin_vram_transfer_vmain
loc_00CBAB:
	lda	(zp_02)
	and	#$3FFF
	clc
	adc	#$1000
	adc	zp_FE
	tay
	lda	(zp_02)
	and	#$C000
	cmp	zp_0C
	beq	loc_00CBDF
	sta	zp_0C
	xba
	lsr	a
	ora	zp_0A
	tax
	lda	f:data_00CD0A,x
	sta	zp_10
	lda	f:data_00CD0C,x
	sta	zp_12
	lda	f:data_00CD0E,x
	sta	zp_14
	lda	f:data_00CD10,x
	sta	zp_16
loc_00CBDF:
	ldx	vram_queue_data_ptr
	lda	(zp_10),y
	eor	zp_0C
	sta	a:$0000,x
	lda	(zp_12),y
	eor	zp_0C
	sta	a:$0002,x
	lda	(zp_14),y
	eor	zp_0C
	sta	a:$0004,x
	lda	(zp_16),y
	eor	zp_0C
	sta	a:$0006,x
	txa
	clc
	adc	#$0008
	sta	vram_queue_data_ptr
	lda	zp_02
	clc
	adc	#$0010
	sta	zp_02
	dec	zp_06
	bne	loc_00CBAB
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_00CC1D:
	stz	a:wram_138C
	stz	a:wram_138E
	stz	a:wram_13A4
	stz	a:wram_13A6
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00CC2A:
	; (not executed in the CDL traces)
	stz	a:wram_13CC
	stz	a:wram_13CE
	stz	a:wram_13E4
	stz	a:wram_13E6
	rtl

sub_00CC37:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_1A
	ldy	#$0002
	lda	a:$0000,x
	cmp	#$0081
	bne	loc_00CC4F
	ldy	#$0040
loc_00CC4F:
	sty	zp_06
	lda	a:$0004,x
	and	#$0FFF
	asl	a
	clc
	adc	#$4000
	sta	zp_00
	lda	a:$0006,x
	sta	zp_0E
	lda	a:$0009,x
	sta	zp_02
	ldy	#$0000
loc_00CC6B:
	lda	(zp_0E),y
	sta	zp_0A
	rol	a
	rol	a
	rol	a
	and	#$0001
	sta	zp_0C
	lda	zp_0A
	and	#$03FF
	cmp	zp_C8
	bcs	loc_00CC85
	lda	#$0000
	bra	loc_00CCEF
loc_00CC85:
	cmp	zp_CA
	bcs	loc_00CC8E
	lda	#$2002
	bra	loc_00CCEF
loc_00CC8E:
	cmp	zp_CC
	bcs	loc_00CC97
	lda	#$0004
	bra	loc_00CCEF
loc_00CC97:
	cmp	zp_CE
	bcs	loc_00CCA0
	lda	#$4008
	bra	loc_00CCED
loc_00CCA0:
	cmp	zp_D0
	bcs	loc_00CCA9
	lda	#$4010
	bra	loc_00CCED
loc_00CCA9:
	cmp	zp_D2
	bcs	loc_00CCB2
	lda	#$6020
	bra	loc_00CCED
loc_00CCB2:
	cmp	zp_D4
	bcs	loc_00CCBB
	lda	#$6040
	bra	loc_00CCED
loc_00CCBB:
	cmp	zp_D6
	bcs	loc_00CCC4
	lda	#$6080
	bra	loc_00CCED
loc_00CCC4:
	cmp	zp_D8
	bcs	loc_00CCCD
	lda	#$6100
	bra	loc_00CCED
loc_00CCCD:
	cmp	zp_DA
	bcs	loc_00CCD6
	lda	#$1200
	bra	loc_00CCEF
loc_00CCD6:
	cmp	zp_DC
	bcs	loc_00CCDF
	lda	#$5400
	bra	loc_00CCED
loc_00CCDF:
	cmp	zp_DE
	bcs	loc_00CCE8
	lda	#$5800
	bra	loc_00CCED
loc_00CCE8:
	lda	#$A000
	bra	loc_00CCEF
loc_00CCED:
	eor	zp_0C
loc_00CCEF:
	sta	(zp_00)
	lda	zp_00
	clc
	adc	zp_06
	sta	zp_00
	iny
	iny
	cpy	zp_02
	bcs	loc_00CD01
	brl	loc_00CC6B
loc_00CD01:
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
data_00CD0A:
	; CDL: read by sub_00CB29
	.byte	$00, $00
data_00CD0C:
	; CDL: read by sub_00CB29
	.byte	$08, $00
data_00CD0E:
	; CDL: read by sub_00CB29
	.byte	$10, $00
data_00CD10:
	; CDL: read by sub_00CB29
	.byte	$18, $00, $02, $00, $0A, $00, $12, $00, $1A, $00, $04, $00, $0C, $00, $14, $00
	.byte	$1C, $00, $06, $00, $0E, $00, $16, $00, $1E, $00, $06, $00, $0E, $00, $16, $00
	.byte	$1E, $00, $04, $00, $0C, $00, $14, $00, $1C, $00, $02, $00, $0A, $00, $12, $00
	.byte	$1A, $00, $00, $00, $08, $00, $10, $00, $18, $00, $18, $00, $10, $00, $08, $00
	.byte	$00, $00, $1A, $00, $12, $00, $0A, $00, $02, $00, $1C, $00, $14, $00, $0C, $00
	.byte	$04, $00, $1E, $00, $16, $00, $0E, $00, $06, $00, $1E, $00, $16, $00, $0E, $00
	.byte	$06, $00, $1C, $00, $14, $00, $0C, $00, $04, $00, $1A, $00, $12, $00, $0A, $00
	.byte	$02, $00, $18, $00, $10, $00, $08, $00, $00, $00
data_00CD8A:
	; CDL: read by sub_00CA52
	.byte	$00, $00
data_00CD8C:
	; CDL: read by sub_00CA52
	.byte	$02, $00
data_00CD8E:
	; CDL: read by sub_00CA52
	.byte	$04, $00
data_00CD90:
	; CDL: read by sub_00CA52
	.byte	$06, $00, $08, $00, $0A, $00, $0C, $00, $0E, $00, $10, $00, $12, $00, $14, $00
	.byte	$16, $00, $18, $00, $1A, $00, $1C, $00, $1E, $00, $06, $00, $04, $00, $02, $00
	.byte	$00, $00, $0E, $00, $0C, $00, $0A, $00, $08, $00, $16, $00, $14, $00, $12, $00
	.byte	$10, $00, $1E, $00, $1C, $00, $1A, $00, $18, $00, $18, $00, $1A, $00, $1C, $00
	.byte	$1E, $00, $10, $00, $12, $00, $14, $00, $16, $00, $08, $00, $0A, $00, $0C, $00
	.byte	$0E, $00, $00, $00, $02, $00, $04, $00, $06, $00
	; CDL: not accessed
	.byte	$1E, $00, $1C, $00, $1A, $00, $18, $00, $16, $00, $14, $00, $12, $00, $10, $00
	.byte	$0E, $00, $0C, $00, $0A, $00, $08, $00, $06, $00, $04, $00, $02, $00, $00, $00

sub_00CE0A:
	lda	a:wram_1380
	and	#$FF00
	sta	a:wram_160C
	lda	a:wram_13BC
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	#$0002
	sta	a:wram_1606
	stz	a:wram_1602
	stz	a:wram_1608
	lda	#$1380
	sta	a:wram_160A
	lda	stage_number
	asl	a
	tay
	lda	a:data_05947A,y
	sta	a:wram_1604
	rtl

sub_00CE3A:
	lda	a:wram_160A
	sta	zp_02
	lda	a:wram_1608
	and	#$0001
	sta	zp_04
	lda	(zp_02)
	and	#$FF00
	cmp	a:wram_160C
	beq	loc_00CE6C
	sta	a:wram_160C
loc_00CE54:
	lda	#$00FF
	jsl	f:sub_00CE6E
	lda	a:$0000,y
	cmp	#$00FF
	bne	loc_00CE54
	inc	a:wram_1606
	inc	a:wram_1606
	stz	a:wram_1602
loc_00CE6C:
	lda	(zp_02)

sub_00CE6E:
	eor	a:wram_1608
	clc
	adc	zp_04
	and	#$00FF
	sta	zp_0C
	lda	a:wram_1606
	sta	zp_00
	ldy	a:wram_1604
	lda	(zp_00),y
	clc
	adc	a:wram_1602
	tay
	lda	a:$0000,y
	and	#$00FF
	cmp	#$00FF
	beq	loc_00CEE4
	cmp	zp_0C
	beq	loc_00CE99
	bcs	loc_00CEE4
loc_00CE99:
	sta	zp_06
	jsr	a:sub_00CEE5
	bcs	loc_00CEE4
	lda	a:wram_1608
	bmi	loc_00CEB0
	sec
	lda	zp_0C
	sbc	zp_06
	stz	zp_0A
	sta	zp_08
	bra	loc_00CEB9
loc_00CEB0:
	sec
	lda	zp_06
	sbc	zp_0C
	stz	zp_08
	sta	zp_0A
loc_00CEB9:
	lda	a:$0001,y
	and	#$00FF
	sta	$10,x
	clc
	lda	a:$0004,y
	adc	zp_08
	sta	$0A,x
	sec
	lda	a:$0006,y
	sbc	zp_0A
	sta	$0E,x
	lda	a:$0008,y
	sta	$3A,x
	stz	$06,x
	stz	$16,x
	clc
	lda	a:wram_1602
	adc	#$000A
	sta	a:wram_1602
loc_00CEE4:
	rtl

sub_00CEE5:
	lda	a:$0003,y
	and	#$00FF
	asl	a
	asl	a
	asl	a
	asl	a
	tax
	lda	a:$0002,y
	and	#$00FF
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_FC
	clc
loc_00CEFD:
	lda	$10,x
	beq	loc_00CF0B
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_FC
	bcc	loc_00CEFD
loc_00CF0B:
	rts
