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
	sta	zp_64
	lda	a:wram_1600
	phx
	asl	a
	tax
	lda	f:tbl_00BD57,x
	plx
	sta	zp_00
	jmp	(zp_00)
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
	inc	a:wram_1600
	lda	#$0080
	sta	a:inidisp_shadow
	jsl	f:reset_sound_queue
	ldx	stage_number
	lda	a:data_0589CC,x
	and	#$00FF
	sta	a:wram_1670
	sta	a:wram_1698
	ldy	a:wram_1E40
	beq	loc_00BD90
	clc
	adc	#$000A
	sta	a:wram_1670
loc_00BD90:
	ldy	#$8AC7
	jsl	f:sub_009982
	ldy	a:wram_1670
	lda	a:data_0589D3,y
	sta	a:wram_13BC
	lda	a:data_0589E7,y
	sta	a:wram_13FC
	ldy	a:wram_1698
	ldx	a:data_058A03,y
	jsl	f:sub_00C132
	lda	a:data_0589FB,y
	sta	a:wram_1672
	stz	zp_A0
	stz	zp_A2
	stz	a:wram_1660
	stz	a:wram_1662
	stz	zp_78
	lda	#$000E
	sta	a:player1_state
	sta	a:player2_state
	stz	a:wram_1688
	stz	a:wram_16B4
	stz	a:wram_16B6
	stz	a:wram_16BE
	stz	a:wram_16C0
	stz	a:wram_1E5E
	ldy	a:wram_1698
	lda	a:data_058A21,y
	tay
	ldx	#$1210
	jsl	f:sub_009985
	lda	zp_88
	ora	zp_8E
	sta	a:wram_1628
	lda	#$005F
	sta	a:wram_16AA
	lda	#$0020
	sta	a:wram_16AC
	lda	#$0001
	sta	f:wram_7E3C1E
	sta	f:wram_7E3E1E
	lda	#$0020
	sta	a:CGWSEL
	sta	a:cgwsel_shadow
	lda	#$003F
	sta	a:CGADSUB
	sta	a:cgadsub_shadow
	lda	#$0022
	sta	a:W12SEL
	sta	a:w12sel_shadow
	lda	#$0203
	sta	a:TMW
	sta	a:tmw_shadow
	lda	#$00E0
	sta	a:COLDATA
	stz	a:coldata_shadow
	lda	#$00FF
	sta	a:wram_1EB0
	stz	a:wram_1EB2
	lda	#$0030
	sta	a:wobjsel_shadow
	stz	a:wram_1510
	stz	a:wram_1550
	lda	#$0280
	sta	a:wram_1646
	stz	a:wram_16B2
	stz	a:wram_1676
	stz	a:wram_167A
	stz	a:wram_167C
	stz	a:wram_167E
	stz	a:wram_1678
	rtl

sub_00BE64:
	lda	stage_number
	bne	loc_00BE6E
	inc	a:wram_1600
	inc	a:wram_1600
loc_00BE6E:
	inc	a:wram_1600
	lda	#$0041
	sta	a:bg1sc_shadow
	sta	a:BG1SC
	lda	#$0049
	sta	a:bg2sc_shadow
	sta	a:BG2SC
	lda	#$005C
	sta	a:bg3sc_shadow
	sta	a:BG3SC
	lda	#$0000
	sta	a:BG12NBA
	lda	#$0005
	sta	a:BG34NBA
	lda	#$0003
	sta	a:obsel_shadow
	lda	#$0009
	sta	a:bgmode_shadow
	sta	a:BGMODE
	lda	#$0017
	sta	a:tm_shadow
	lda	#$0002
	sta	a:ts_shadow
	ldx	#.loword(data_058ADD)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058AD4)
	jsl	f:sub_0090A8
	ldy	a:wram_1670
	ldx	a:data_058A0D,y
	jsl	f:sub_0090A8
	ldx	#$1380
	ldy	#$4000
	jsl	f:sub_00C612
	ldx	#$13C0
	ldy	#$A000
	jsl	f:sub_00C612
	lda	stage_number
	cmp	#$0004
	bne	loc_00BEEA
	jsl	f:sub_00C575
loc_00BEEA:
	jsl	f:sub_00E369
	jsl	f:sub_00C041
	stz	a:wram_168A
	jsl	f:sub_00CE0A
	stz	a:inidisp_shadow
	stz	a:wram_1686
	stz	a:wram_16BC

sub_00BF02:
	stz	zp_B0
	stz	zp_B6
	stz	a:wram_1800
	stz	a:wram_1808
	stz	a:wram_1810
	stz	a:wram_1818
	stz	a:wram_1820
	stz	a:wram_1828
	stz	a:wram_1830
	stz	a:wram_1838
	lda	#$0008
	sta	zp_E2
	stz	cgram_upload_src
	stz	cgram_upload_addr
	rtl

sub_00BF28:
	inc	zp_78
	lda	zp_78
	and	#$0007
	sta	zp_C0
	and	#$0003
	sta	zp_BE
	and	#$0001
	sta	zp_BC
	lda	zp_78
	and	#$0002
	sta	zp_E4
	lda	zp_78
	and	#$0004
	sta	zp_E6
	rts

sub_00BF4A:
	lda	zp_78
	bit	#$0007
	bne	loc_00BF89
	dec	a:inidisp_shadow
	bne	loc_00BF89
	stz	a:wram_1E5E
	stz	a:inidisp_shadow
	stz	hdma_preset
	stz	a:wram_1600
	stz	nmi_mode
	lda	#$0001
	sta	zp_36
	rtl

sub_00BF69:
	lda	a:wram_1686
	beq	loc_00BF72
	inc	a:wram_1600
	rtl
loc_00BF72:
	lda	a:wram_16BC
	bne	loc_00BF79
	stz	zp_64
loc_00BF79:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	loc_00BF89
	inc	a:inidisp_shadow
	lda	#$0002
	sta	zp_64
loc_00BF89:
	lda	a:p1_lives
	bne	loc_00BF99
	lda	a:p2_lives
	bne	loc_00BF99
	lda	#$0003
	sta	a:wram_1600
loc_00BF99:
	lda	a:wram_1688
	beq	loc_00BFA1
	dec	a:wram_1688
loc_00BFA1:
	lda	#$0FC0
	sta	zp_AC
	lda	#$11C0
	sta	zp_AE
	lda	#$8000
	sta	zp_9C
	jsl	f:sub_00BF02
	jsr	a:sub_00BF28
	jsl	f:sub_01A624
	jsl	f:sub_00E1B8
	stz	a:wram_023C
	stz	a:wram_027C
	stz	a:wram_1504
	stz	a:wram_1544
	lda	a:wram_16B6
	bne	loc_00BFD4
	jsl	f:sub_00CE3A
loc_00BFD4:
	lda	zp_BC
	bne	loc_00BFE2
	jsl	f:sub_00E960
	jsl	f:sub_00E989
	bra	loc_00BFEA
loc_00BFE2:
	jsl	f:sub_00E989
	jsl	f:sub_00E960
loc_00BFEA:
	jsl	f:sub_00E97E
	ldy	zp_AE
	cpy	#$11E0
	bcs	loc_00C034
	ldx	zp_AC
loc_00BFF7:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_9C
	lsr	zp_9C
	bcc	loc_00BFF7
	lda	zp_9C
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
	lda	a:wram_1670
	lsr	a
	phx
	asl	a
	tax
	lda	f:tbl_00C052,x
	plx
	sta	zp_00
	jmp	(zp_00)
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
	sta	a:wram_13FA
	bra	loc_00C07D

sub_00C06E:
	jsl	f:sub_01B918
	lda	#$0003
	sta	hdma_preset
	lda	#$0004
	sta	a:wram_13FA
loc_00C07D:
	lda	#$00C1
	sta	a:m7sel_shadow
	stz	a:wram_1666
	lda	#$0064
	jml	f:queue_sound

sub_00C08D:
	; (not executed in the CDL traces)
	stz	a:wram_13FA
	stz	a:wram_13C0
	stz	a:wram_13D8
	bra	loc_00C0A3

sub_00C098:
	lda	#$0007
	sta	hdma_preset
	lda	#$003C
	sta	a:wram_08D0
loc_00C0A3:
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0062
	jml	f:queue_sound

sub_00C0B0:
	; (not executed in the CDL traces)
	lda	#$0063
	jsl	f:queue_sound
	lda	#$000D
	sta	a:wram_0952
	lda	#$000A
	sta	hdma_preset
	lda	#$0030
	sta	a:wram_0978
	bra	loc_00C0DE

sub_00C0CA:
	lda	#$0084
	jsl	f:queue_sound
	lda	#$004F
	jsl	f:queue_sound
	lda	#$0040
	sta	a:bg1sc_shadow
loc_00C0DE:
	lda	#$0002
	sta	a:wram_16B6
	lda	#$0064
	sta	a:wram_0950
	lda	#$00A0
	sta	a:wram_0964
	lda	#$006D
	sta	a:wram_0290
	sta	a:wram_02D0
	stz	a:wram_02B0
	lda	#$0002
	sta	a:wram_02F0
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0004
	sta	a:wram_13BA
	lda	#$000A
	sta	a:wram_13FA
	rtl

sub_00C115:
	lda	#$0006
	sta	a:wram_16BE
	jsl	f:sub_01F6AF
	lda	#$0055
	sta	a:wram_08D0
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0062
	jml	f:queue_sound

sub_00C132:
	lda	a:$0000,x
	sta	zp_C8
	lda	a:$0002,x
	sta	zp_CA
	lda	a:$0004,x
	sta	zp_CC
	lda	a:$0006,x
	sta	zp_CE
	lda	a:$0008,x
	sta	zp_D0
	lda	a:$000A,x
	sta	zp_D2
	lda	a:$000C,x
	sta	zp_D4
	lda	a:$000E,x
	sta	zp_D6
	lda	a:$0010,x
	sta	zp_D8
	lda	a:$0012,x
	sta	zp_DA
	lda	a:$0014,x
	sta	zp_DC
	lda	a:$0016,x
	sta	zp_DE
	rtl

sub_00C16F:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	loc_00C17A
	inc	a:inidisp_shadow
loc_00C17A:
	lda	#$0FC0
	sta	zp_AC
	lda	#$11C0
	sta	zp_AE
	lda	#$8000
	sta	zp_9C
	jsl	f:sub_00BF02
	jsr	a:sub_00BF28
	jsl	f:sub_00C67D
	jsl	f:sub_00C917
	jsl	f:sub_00EBD7
	jsl	f:sub_00E989
	jsl	f:sub_00E97E
	ldy	zp_AE
	cpy	#$11E0
	bcs	loc_00C1EA
	ldx	zp_AC
loc_00C1AD:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_9C
	lsr	zp_9C
	bcc	loc_00C1AD
	lda	zp_9C
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
	lda	a:wram_16B4
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
	sta	zp_00
	jmp	(zp_00)
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
	lda	zp_8A
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
	lda	zp_8A
	sta	$2C,x
loc_00C280:
	sty	$04,x
	rtl
