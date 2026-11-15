; engine/nmi.asm -- NMI handler and per-frame drivers
; Bank $00, $00:819B-$00:85F2. Included by main.asm in segment BANK00.
;
; nmi saves the registers and calls one of three frame handlers through
; tbl_0081E0, indexed by $42: sub_0081E6, sub_00823C (side-view stages) and
; sub_0083A3 (top-down Mode 7 stages, see game/game_modes.asm sub_00AC3F).
; They upload PPU state (scroll, BG/colour-math registers, OAM, CGRAM) and
; then run the game logic for the frame (joypads, game mode state machine
; sub_00A377, palette tasks, loaders, sound queue).

nmi:
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	pha
	phx
	phy
	phd
	phb
	sep	#$20
	.a8
	ldx	#$0000
	phx
	pld
	lda	#$05
	pha
	plb
	lda	a:RDNMI
	sei
	lda	a:$1E82
	sta	a:NMITIMEN
	rep	#$20
	.a16
	lda	a:$1EC0
	sta	a:HTIMEL
	lda	a:$1EC2
	sta	a:VTIMEL
	cli
	lda	$3C
	beq	loc_0081D1
	lda	#$0001
	sta	$3C
	bra	loc_0081DA
loc_0081D1:
	inc	$3C
	ldx	$42
	jsr	(.loword(tbl_0081E0),x)
	stz	$3C
loc_0081DA:
	plb
	pld
	ply
	plx
	pla
	rti
tbl_0081E0:
	.addr	sub_0081E6
	.addr	sub_00823C
	.addr	sub_0083A3

sub_0081E6:
	sep	#$20
	.a8
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	jsr	a:sub_008549
	jsr	a:sub_0084AE
	jsl	f:sub_00913D
	jsl	f:sub_008BA7
	jsr	a:sub_008452
	jsl	f:sub_008CFF
	sep	#$20
	.a8
	lda	$3E
	beq	loc_008215
	dec	$3E
	beq	loc_008215
	lda	a:$1E80
	ora	#$80
	bra	loc_008218
loc_008215:
	lda	a:$1E80
loc_008218:
	sta	a:INIDISP
	rep	#$20
	.a16
	jsl	f:sub_008B19
	stz	$5C
	jsl	f:sub_00A377
	jsl	f:sub_00816C
	jsl	f:sub_009995
	jsl	f:sub_0090C7
	jsl	f:sub_009B76
	jsl	f:sub_0085F3
	rts

sub_00823C:
	sep	#$20
	.a8
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	rep	#$30
	ldx	#$1380
	lda	$0A,x
	sep	#$20
	.a8
	sta	a:BG1HOFS
	xba
	sta	a:BG1HOFS
	rep	#$20
	.a16
	lda	$00,x
	sta	$0A,x
	lda	$22,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG1VOFS
	xba
	sta	a:BG1VOFS
	rep	#$20
	.a16
	lda	$18,x
	sec
	sbc	$A0
	sta	$22,x
	ldx	#$13C0
	lda	$0A,x
	sep	#$20
	.a8
	sta	a:BG2HOFS
	xba
	sta	a:BG2HOFS
	rep	#$20
	.a16
	lda	$00,x
	sta	$0A,x
	lda	$22,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG2VOFS
	xba
	sta	a:BG2VOFS
	rep	#$20
	.a16
	lda	$18,x
	sec
	sbc	$A2
	sta	$22,x
	ldx	#$1400
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG3HOFS
	lda	$01,x
	sta	a:BG3HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG3VOFS
	xba
	sta	a:BG3VOFS
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	jsr	a:sub_0084AE
	jsl	f:sub_00913D
	jsr	a:sub_008452
	sep	#$20
	.a8
	lda	$98
	beq	loc_008301
	sta	a:CGADD
	ldx	$9A
	stx	a:A1T1L
	lda	#$05
	sta	a:A1B1
	ldx	#$0020
	stx	a:DAS1L
	lda	#$02
	sta	a:MDMAEN
	lda	$99
	beq	loc_008301
	sta	a:CGADD
	ldx	$9A
	stx	a:A1T1L
	lda	#$05
	sta	a:A1B1
	ldx	#$0020
	stx	a:DAS1L
	lda	#$02
	sta	a:MDMAEN
loc_008301:
	rep	#$20
	.a16
	jsl	f:sub_008CFF
	jsl	f:sub_00E4F6
	lda	a:$1E02
	beq	loc_008314
	jsl	f:sub_00E535
loc_008314:
	jsl	f:sub_00E575
	jsl	f:sub_00C283
	lda	a:$1EAC
	sta	a:W12SEL
	lda	a:$1EAE
	sta	a:WOBJSEL
	lda	a:$1EBA
	sta	a:TMW
	sep	#$20
	.a8
	lda	a:$1EB8
	sta	a:WBGLOG
	lda	$3E
	beq	loc_008345
	dec	$3E
	beq	loc_008345
	lda	a:$1E80
	ora	#$80
	bra	loc_008348
loc_008345:
	lda	a:$1E80
loc_008348:
	sta	a:INIDISP
	rep	#$20
	.a16
	phb
	lda	#$0063
	ldx	#$D000
	ldy	#$D200
	mvn	#$7E, #$7E
	lda	#$0084
	ldx	#$D400
	ldy	#$D800
	mvn	#$7E, #$7E
	plb
	jsl	f:sub_008B19
	jsl	f:sub_00E7EF
	jsl	f:sub_00E5F7
	stz	$5C
	jsl	f:sub_00A377
	jsl	f:sub_00816C
	jsl	f:sub_009995
	jsl	f:sub_0090C7
	jsl	f:sub_009B76
	jsl	f:sub_0085F3
	lda	$3A
	bit	#$0001
	bne	loc_008399
	jsl	f:sub_00E3DA
loc_008398:
	rts
loc_008399:
	lda	a:$1E02
	beq	loc_008398
	jsl	f:sub_00E464
	rts

sub_0083A3:
	sep	#$20
	.a8
	lda	#$80
	sta	f:$7E38A3
	sta	f:$7E38A7
	sta	f:$7E38A1
	sta	f:$7E38A5
	sta	a:INIDISP
	lda	a:$1EC4
	sta	a:HDMAEN
	rep	#$20
	.a16
	jsl	f:sub_02DDC6
	jsl	f:sub_00A257
	jsl	f:sub_00E4EE
	jsl	f:sub_009C18
	jsr	a:sub_008452
	lda	$3E
	beq	loc_0083DD
	dec	$3E
	bne	loc_008427
loc_0083DD:
	lda	a:$1E02
	beq	loc_0083E5
	dec	a
	beq	loc_008407
loc_0083E5:
	sep	#$20
	.a8
	lda	a:$1FB4
	sta	f:$7E38A3
	lda	a:$1FF4
	sta	f:$7E38A7
	lda	a:$1E80
	sta	f:$7E38A1
	sta	f:$7E38A5
	sta	a:INIDISP
	rep	#$20
	.a16
	bra	loc_008427
loc_008407:
	sep	#$20
	.a8
	lda	a:$1FF4
	sta	f:$7E38A7
	lda	a:$1E80
	sta	f:$7E38A1
	sta	f:$7E38A5
	lda	a:$1FB4
	sta	f:$7E38A3
	sta	a:INIDISP
	rep	#$20
loc_008427:
	.a16
	jsl	f:sub_02DDDC
	jsl	f:sub_008B19
	stz	$5C
	jsl	f:sub_00A377
	jsl	f:sub_00816C
	jsl	f:sub_00E3CD
	jsl	f:sub_02ED77
	jsl	f:sub_03E180
	jsl	f:sub_009995
	jsl	f:sub_0090C7
	jsl	f:sub_0085F3
	rts

sub_008452:
	sep	#$20
	.a8
	stz	a:OAMADDL
	ldx	#$0400
	stx	a:DMAP0
	ldx	#$0FC0
	stx	a:A1T0L
	lda	#$7E
	sta	a:A1B0
	ldx	#$0220
	stx	a:DAS0L
	stz	a:CGADD
	ldx	#$2200
	stx	a:DMAP1
	ldx	$48
	stx	a:A1T1L
	lda	#$7E
	sta	a:A1B1
	ldx	#$0200
	stx	a:DAS1L
	lda	#$03
	sta	a:MDMAEN
	rep	#$20
	.a16
	rts

sub_00848F:
	php
	sep	#$30
	.a8
	.i8
	lda	a:RDNMI
	lda	#$0F
	sta	a:$1E80
	lda	#$81
	sta	a:$1E82
	sta	a:NMITIMEN
	jsl	f:sub_0088A3
	.a16
	.i16
	sep	#$30
	.a8
	.i8
	lda	#$04
	sta	$3E
	plp
	.a16
	.i16
	rtl

sub_0084AE:
	sep	#$20
	.a8
	lda	a:$1E9A
	sta	a:TM
	lda	a:$1E9C
	sta	a:TS
	lda	a:$1E94
	sta	a:CGWSEL
	lda	a:$1E96
	sta	a:CGADSUB
	lda	a:$1E98
	sta	a:COLDATA
	lda	a:$1E86
	sta	a:OBSEL
	lda	a:$1E84
	sta	a:BGMODE
	lda	a:$1E8A
	sta	a:MOSAIC
	lda	a:$1E8C
	sta	a:BG1SC
	lda	a:$1E8E
	sta	a:BG2SC
	lda	a:$1E92
	sta	a:BG4SC
	lda	a:$1E90
	sta	a:BG3SC
	lda	a:$1E9E
	sta	a:M7A
	lda	a:$1E9F
	sta	a:M7A
	lda	a:$1EA0
	sta	a:M7B
	lda	a:$1EA1
	sta	a:M7B
	lda	a:$1EA2
	sta	a:M7C
	lda	a:$1EA3
	sta	a:M7C
	lda	a:$1EA4
	sta	a:M7D
	lda	a:$1EA5
	sta	a:M7D
	lda	a:$1EA6
	sta	a:M7X
	lda	a:$1EA7
	sta	a:M7X
	lda	a:$1EA8
	sta	a:M7Y
	lda	a:$1EA9
	sta	a:M7Y
	lda	a:$1EAA
	sta	a:M7SEL
	rep	#$20
	.a16
	rts

sub_008549:
	rep	#$30
	ldx	#$1380
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG1HOFS
	lda	$01,x
	sta	a:BG1HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG1VOFS
	xba
	sta	a:BG1VOFS
	rep	#$20
	.a16
	ldx	#$13C0
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG2HOFS
	lda	$01,x
	sta	a:BG2HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG2VOFS
	xba
	sta	a:BG2VOFS
	rep	#$20
	.a16
	ldx	#$1400
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG3HOFS
	lda	$01,x
	sta	a:BG3HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG3VOFS
	xba
	sta	a:BG3VOFS
	rep	#$20
	.a16
	rts

sub_0085A9:
	php
	sep	#$20
	.a8
	lda	a:RDNMI
	lda	#$00
	sta	a:HDMAEN
	sta	a:MDMAEN
	sta	a:NMITIMEN
loc_0085BA:
	lda	#$8F
	sta	a:INIDISP
	bra	loc_0085D0

sub_0085C1:
	.a16
	php
	sep	#$20
	.a8
	lda	a:RDNMI
	lda	a:$1E82
	sta	a:NMITIMEN
	lda	a:$1E80
loc_0085D0:
	lda	#$04
	sta	a:$003E
	lda	#$00
	sta	a:HDMAEN
	sta	a:MDMAEN
	plp
	.a16
	rtl

sub_0085DF:
	php
	sep	#$20
	.a8
	lda	a:$1E82
	bpl	loc_0085D0
	lda	#$80
	sta	a:$003C
loc_0085EC:
	lda	a:$003C
	bmi	loc_0085EC
	bra	loc_0085BA
