; game/stage.asm -- Side-view stage state machine
; Bank $00, $00:BD40-$00:C282. Included by main.asm in segment BANK00.
;
; sub_00BD40 dispatches the stage sub-mode through tbl_00BD57: stage start
; effects (sub_00BD61), stage setup (sub_00BE64: video mode, graphics, BG),
; and the per-frame stage loop (sub_00BF69: players sub_01A624, object lists
; sub_00E1B8/sub_00E989, HUD...).

sub_00BD40:
	rep	#$30
	lda	#$0002
	sta	$64
	lda	a:$1600
	phx
	asl	a
	tax
	lda	f:tbl_00BD57,x
	plx
	sta	$00
	jmp	($0000)
tbl_00BD57:
	.addr	sub_00BD61
	.addr	sub_00BE64
	.addr	sub_00BF69
	.addr	sub_00BF4A
	.addr	sub_00C16F

sub_00BD61:
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	inc	a:$1600
	lda	#$0080
	sta	a:$1E80
	jsl	f:sub_00865C
	ldx	$86
	lda	a:data_0589CC,x
	and	#$00FF
	sta	a:$1670
	sta	a:$1698
	ldy	a:$1E40
	beq	loc_00BD90
	clc
	adc	#$000A
	sta	a:$1670
loc_00BD90:
	ldy	#$8AC7
	jsl	f:sub_009982
	ldy	a:$1670
	lda	a:data_0589D3,y
	sta	a:$13BC
	lda	a:data_0589E7,y
	sta	a:$13FC
	ldy	a:$1698
	ldx	a:data_058A03,y
	jsl	f:sub_00C132
	lda	a:data_0589FB,y
	sta	a:$1672
	stz	$A0
	stz	$A2
	stz	a:$1660
	stz	a:$1662
	stz	$78
	lda	#$000E
	sta	a:$0212
	sta	a:$0252
	stz	a:$1688
	stz	a:$16B4
	stz	a:$16B6
	stz	a:$16BE
	stz	a:$16C0
	stz	a:$1E5E
	ldy	a:$1698
	lda	a:data_058A21,y
	tay
	ldx	#$1210
	jsl	f:sub_009985
	lda	$88
	ora	$8E
	sta	a:$1628
	lda	#$005F
	sta	a:$16AA
	lda	#$0020
	sta	a:$16AC
	lda	#$0001
	sta	f:$7E3C1E
	sta	f:$7E3E1E
	lda	#$0020
	sta	a:CGWSEL
	sta	a:$1E94
	lda	#$003F
	sta	a:CGADSUB
	sta	a:$1E96
	lda	#$0022
	sta	a:W12SEL
	sta	a:$1EAC
	lda	#$0203
	sta	a:TMW
	sta	a:$1EBA
	lda	#$00E0
	sta	a:COLDATA
	stz	a:$1E98
	lda	#$00FF
	sta	a:$1EB0
	stz	a:$1EB2
	lda	#$0030
	sta	a:$1EAE
	stz	a:$1510
	stz	a:$1550
	lda	#$0280
	sta	a:$1646
	stz	a:$16B2
	stz	a:$1676
	stz	a:$167A
	stz	a:$167C
	stz	a:$167E
	stz	a:$1678
	rtl

sub_00BE64:
	lda	$86
	bne	loc_00BE6E
	inc	a:$1600
	inc	a:$1600
loc_00BE6E:
	inc	a:$1600
	lda	#$0041
	sta	a:$1E8C
	sta	a:BG1SC
	lda	#$0049
	sta	a:$1E8E
	sta	a:BG2SC
	lda	#$005C
	sta	a:$1E90
	sta	a:BG3SC
	lda	#$0000
	sta	a:BG12NBA
	lda	#$0005
	sta	a:BG34NBA
	lda	#$0003
	sta	a:$1E86
	lda	#$0009
	sta	a:$1E84
	sta	a:BGMODE
	lda	#$0017
	sta	a:$1E9A
	lda	#$0002
	sta	a:$1E9C
	ldx	#.loword(data_058ADD)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058AD4)
	jsl	f:sub_0090A8
	ldy	a:$1670
	ldx	a:data_058A0D,y
	jsl	f:sub_0090A8
	ldx	#$1380
	ldy	#$4000
	jsl	f:sub_00C612
	ldx	#$13C0
	ldy	#$A000
	jsl	f:sub_00C612
	lda	$86
	cmp	#$0004
	bne	loc_00BEEA
	jsl	f:sub_00C575
loc_00BEEA:
	jsl	f:sub_00E369
	jsl	f:sub_00C041
	stz	a:$168A
	jsl	f:sub_00CE0A
	stz	a:$1E80
	stz	a:$1686
	stz	a:$16BC

sub_00BF02:
	stz	$B0
	stz	$B6
	stz	a:$1800
	stz	a:$1808
	stz	a:$1810
	stz	a:$1818
	stz	a:$1820
	stz	a:$1828
	stz	a:$1830
	stz	a:$1838
	lda	#$0008
	sta	$E2
	stz	$9A
	stz	$98
	rtl

sub_00BF28:
	inc	$78
	lda	$78
	and	#$0007
	sta	$C0
	and	#$0003
	sta	$BE
	and	#$0001
	sta	$BC
	lda	$78
	and	#$0002
	sta	$E4
	lda	$78
	and	#$0004
	sta	$E6
	rts

sub_00BF4A:
	lda	$78
	bit	#$0007
	bne	loc_00BF89
	dec	a:$1E80
	bne	loc_00BF89
	stz	a:$1E5E
	stz	a:$1E80
	stz	$46
	stz	a:$1600
	stz	$42
	lda	#$0001
	sta	$36
	rtl

sub_00BF69:
	lda	a:$1686
	beq	loc_00BF72
	inc	a:$1600
	rtl
loc_00BF72:
	lda	a:$16BC
	bne	loc_00BF79
	stz	$64
loc_00BF79:
	lda	a:$1E80
	cmp	#$000F
	bcs	loc_00BF89
	inc	a:$1E80
	lda	#$0002
	sta	$64
loc_00BF89:
	lda	a:$1F8A
	bne	loc_00BF99
	lda	a:$1FCA
	bne	loc_00BF99
	lda	#$0003
	sta	a:$1600
loc_00BF99:
	lda	a:$1688
	beq	loc_00BFA1
	dec	a:$1688
loc_00BFA1:
	lda	#$0FC0
	sta	$AC
	lda	#$11C0
	sta	$AE
	lda	#$8000
	sta	$9C
	jsl	f:sub_00BF02
	jsr	a:sub_00BF28
	jsl	f:sub_01A624
	jsl	f:sub_00E1B8
	stz	a:$023C
	stz	a:$027C
	stz	a:$1504
	stz	a:$1544
	lda	a:$16B6
	bne	loc_00BFD4
	jsl	f:sub_00CE3A
loc_00BFD4:
	lda	$BC
	bne	loc_00BFE2
	jsl	f:sub_00E960
	jsl	f:sub_00E989
	bra	loc_00BFEA
loc_00BFE2:
	jsl	f:sub_00E989
	jsl	f:sub_00E960
loc_00BFEA:
	jsl	f:sub_00E97E
	ldy	$AE
	cpy	#$11E0
	bcs	loc_00C034
	ldx	$AC
loc_00BFF7:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	$9C
	lsr	$9C
	bcc	loc_00BFF7
	lda	$9C
	sta	a:$0000,y
loc_00C00C:
	cpx	#$11C0
	bcs	loc_00C034
	iny
	iny
	lda	#$0080
	sta	$00,x
	sta	$04,x
	sta	$08,x
	sta	$0C,x
	sta	$10,x
	sta	$14,x
	sta	$18,x
	sta	$1C,x
	lda	#$5555
	sta	a:$0000,y
	txa
	clc
	adc	#$0020
	tax
	bra	loc_00C00C
loc_00C034:
	jsl	f:sub_00FF01
	jsl	f:sub_00FDB4
	jsl	f:sub_01F6B7
	rtl

sub_00C041:
	lda	a:$1670
	lsr	a
	phx
	asl	a
	tax
	lda	f:tbl_00C052,x
	plx
	sta	$00
	jmp	($0000)
tbl_00C052:
	.addr	sub_00C06E
	.addr	sub_00C098
	.addr	sub_00C0CA
	.addr	sub_00C115
	.addr	sub_00EBC4
	.addr	sub_00C066
	.addr	sub_00C08D
	.addr	sub_00C0B0
	.addr	sub_00C115
	.addr	sub_00EBC4

sub_00C066:
	lda	#$0000
	sta	a:$13FA
	bra	loc_00C07D

sub_00C06E:
	jsl	f:sub_01B918
	lda	#$0003
	sta	$46
	lda	#$0004
	sta	a:$13FA
loc_00C07D:
	lda	#$00C1
	sta	a:$1EAA
	stz	a:$1666
	lda	#$0064
	jml	f:sub_00868F

sub_00C08D:
	; (not executed in the CDL traces)
	stz	a:$13FA
	stz	a:$13C0
	stz	a:$13D8
	bra	loc_00C0A3

sub_00C098:
	lda	#$0007
	sta	$46
	lda	#$003C
	sta	a:$08D0
loc_00C0A3:
	lda	#$004A
	sta	a:$1E8E
	lda	#$0062
	jml	f:sub_00868F

sub_00C0B0:
	; (not executed in the CDL traces)
	lda	#$0063
	jsl	f:sub_00868F
	lda	#$000D
	sta	a:$0952
	lda	#$000A
	sta	$46
	lda	#$0030
	sta	a:$0978
	bra	loc_00C0DE

sub_00C0CA:
	lda	#$0084
	jsl	f:sub_00868F
	lda	#$004F
	jsl	f:sub_00868F
	lda	#$0040
	sta	a:$1E8C
loc_00C0DE:
	lda	#$0002
	sta	a:$16B6
	lda	#$0064
	sta	a:$0950
	lda	#$00A0
	sta	a:$0964
	lda	#$006D
	sta	a:$0290
	sta	a:$02D0
	stz	a:$02B0
	lda	#$0002
	sta	a:$02F0
	lda	#$004A
	sta	a:$1E8E
	lda	#$0004
	sta	a:$13BA
	lda	#$000A
	sta	a:$13FA
	rtl

sub_00C115:
	lda	#$0006
	sta	a:$16BE
	jsl	f:sub_01F6AF
	lda	#$0055
	sta	a:$08D0
	lda	#$004A
	sta	a:$1E8E
	lda	#$0062
	jml	f:sub_00868F

sub_00C132:
	lda	a:$0000,x
	sta	$C8
	lda	a:$0002,x
	sta	$CA
	lda	a:$0004,x
	sta	$CC
	lda	a:$0006,x
	sta	$CE
	lda	a:$0008,x
	sta	$D0
	lda	a:$000A,x
	sta	$D2
	lda	a:$000C,x
	sta	$D4
	lda	a:$000E,x
	sta	$D6
	lda	a:$0010,x
	sta	$D8
	lda	a:$0012,x
	sta	$DA
	lda	a:$0014,x
	sta	$DC
	lda	a:$0016,x
	sta	$DE
	rtl

sub_00C16F:
	lda	a:$1E80
	cmp	#$000F
	bcs	loc_00C17A
	inc	a:$1E80
loc_00C17A:
	lda	#$0FC0
	sta	$AC
	lda	#$11C0
	sta	$AE
	lda	#$8000
	sta	$9C
	jsl	f:sub_00BF02
	jsr	a:sub_00BF28
	jsl	f:sub_00C67D
	jsl	f:sub_00C917
	jsl	f:sub_00EBD7
	jsl	f:sub_00E989
	jsl	f:sub_00E97E
	ldy	$AE
	cpy	#$11E0
	bcs	loc_00C1EA
	ldx	$AC
loc_00C1AD:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	$9C
	lsr	$9C
	bcc	loc_00C1AD
	lda	$9C
	sta	a:$0000,y
loc_00C1C2:
	cpx	#$11C0
	bcs	loc_00C1EA
	iny
	iny
	lda	#$0080
	sta	$00,x
	sta	$04,x
	sta	$08,x
	sta	$0C,x
	sta	$10,x
	sta	$14,x
	sta	$18,x
	sta	$1C,x
	lda	#$5555
	sta	a:$0000,y
	txa
	clc
	adc	#$0020
	tax
	bra	loc_00C1C2
loc_00C1EA:
	jsl	f:sub_00FF01
	jsl	f:sub_00FDB4
	rtl
loc_00C1F3:
	rtl

sub_00C1F4:
	lda	a:$16B4
	beq	loc_00C1F3
	ldy	#$0000
	cpx	#$0200
	beq	loc_00C204
	; (not executed in the CDL traces)
	ldy	#$0002
loc_00C204:
	stz	$2C,x
	stz	$22,x
	phx
	asl	a
	tax
	lda	f:tbl_00C215,x
	plx
	sta	$00
	jmp	($0000)
tbl_00C215:
	.addr	$0000
	.addr	sub_00C21E
	.addr	sub_00C270
	.addr	sub_00C21D

sub_00C21D:
	rtl

sub_00C21E:
	lda	$12,x
	bne	loc_00C242
	lda	#$0100
	ldy	$0A,x
	cpy	#$007A
	bcc	loc_00C22F
	lda	#$0200
loc_00C22F:
	sta	$22,x
	lda	$0A,x
	cmp	#$0030
	bcc	loc_00C241
	cmp	#$00D0
	bcs	loc_00C241
	lda	$8A
	sta	$2C,x
loc_00C241:
	rtl
loc_00C242:
	cmp	#$0001
	beq	loc_00C248
	rtl
loc_00C248:
	sec
	lda	$0A,x
	sbc	a:data_058CDE,y
	bpl	loc_00C265
	beq	loc_00C257
	cmp	#$FFFE
	bcc	loc_00C25F
loc_00C257:
	stz	$04,x
	lda	#$0000
	sta	$22,x
	rtl
loc_00C25F:
	lda	#$0100
	sta	$22,x
	rtl
loc_00C265:
	cmp	#$0002
	bcc	loc_00C257
	lda	#$0200
	sta	$22,x
	rtl

sub_00C270:
	lda	$12,x
	cmp	#$0001
	bne	loc_00C280
	lda	#$0400
	sta	$22,x
	lda	$8A
	sta	$2C,x
loc_00C280:
	sty	$04,x
	rtl
