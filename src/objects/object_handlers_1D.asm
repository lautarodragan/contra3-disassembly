; objects/object_handlers_1D.asm -- Object handlers (bank $1D)
; Bank $1D, $1D:AF27-$1D:CCDF. Included by main.asm in segment BANK1D.
;
; Handlers of object types dispatched through tbl_05A48A and their helpers.

sub_1DAF27:
	lda	$12,x
	cmp	#$0009
	bcs	loc_1DAF38
	lda	#$918A
	sta	$9A
	lda	#$0030
	sta	$98
loc_1DAF38:
	lda	$26,x
	beq	loc_1DAF46
	lda	#$912A
	sta	$9A
	lda	#$B030
	sta	$98
loc_1DAF46:
	lda	$06,x
	bpl	loc_1DAF72
	stz	$06,x
	lda	#$0001
	sta	$16,x
	lda	#$0002
	sta	a:$1688
	stz	$1C,x
	stz	$1E,x
	lda	#$000F
	sta	$12,x
	lda	#$8000
	sta	a:$0956
	lda	#$076F
	sta	f:$7EE800
	lda	#$0200
	sta	$24,x
loc_1DAF72:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_1DAF81,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DAF81:
	.addr	sub_1DAFD7
	.addr	sub_1DAFFE
	.addr	sub_1DB06B
	.addr	sub_1DB087
	.addr	sub_1DB0AC
	.addr	sub_1DB0C2
	.addr	sub_1DB0DD
	.addr	sub_1DB0E9
	.addr	sub_1DB113
	.addr	sub_1DB175
	.addr	sub_1DB19D
	.addr	sub_1DB1C1
	.addr	sub_1DB205
	.addr	sub_1DB220
	.addr	sub_1DB24A
	.addr	sub_1DBCE3
	.addr	sub_1DB2C5
	.addr	sub_1DBD1C
	.addr	sub_1DBD32
	.addr	sub_1DBD32
	.addr	sub_1DB269
	.addr	sub_1DB306
	.addr	sub_1DBA8C
	.addr	sub_1DBAEA
	.addr	sub_1DBB2E
	.addr	sub_1DBB6B
	.addr	sub_1DBB84
	.addr	sub_1DBB90
	.addr	sub_1DBBDA
	.addr	sub_1DBB84
	.addr	sub_1DBC16
	.addr	sub_1DBC2A
	.addr	sub_1DB338
	.addr	sub_1DB377
	.addr	sub_1DB3CB
	.addr	sub_1DB3FD
	.addr	sub_1DB409
	.addr	sub_1DBC59
	.addr	sub_1DBC97
	.addr	sub_1DBCBF
	.addr	sub_1DBCCD
	.addr	sub_1DBDFB
	.addr	sub_1DBE2C

sub_1DAFD7:
	inc	$12,x
	lda	#$0002
	sta	a:$16B6
	lda	#$8000
	sta	a:$08D6
	lda	#$0002
	sta	a:$13FA
	lda	#$0480
	sta	a:$13FC
	stz	a:$13FE
	lda	#$01F8
	sta	a:$13C2
	stz	a:$13F2
	rtl

sub_1DAFFE:
	lda	a:$13FE
	beq	loc_1DB06A
	inc	$12,x
	stz	a:$13FA
	lda	#$0065
	sta	a:$0290
	lda	#$0001
	sta	a:$0296
	lda	#$0078
	sta	a:$02A8
	lda	#$FFF8
	sta	a:$02AA
	lda	#$0001
	sta	a:$0292
	lda	#$FFF0
	sta	a:$028E
	lda	#$0042
	sta	a:$028A
	lda	#$8000
	sta	a:$029C
	lda	#$076F
	sta	f:$7EE800
	lda	#$7FE8
	sta	f:$7EE802
	lda	#$E809
	sta	f:$7EE804
	lda	#$7F00
	sta	f:$7EE806
	sta	f:$7EE808
	lda	#$0000
	sta	f:$7EE80A
	lda	#$0011
	sta	$46
	lda	#$0007
	sta	a:$1672
loc_1DB06A:
	rtl

sub_1DB06B:
	jsr	a:sub_1DB41F
	lda	a:$028E
	bmi	loc_1DB086
	cmp	#$006C
	bcc	loc_1DB086
	inc	$12,x
	stz	a:$029C
	lda	#$0001
	sta	a:$16B4
	stz	a:$1666
loc_1DB086:
	rtl

sub_1DB087:
	jsr	a:sub_1DB41F
	lda	a:$1F8A
	beq	loc_1DB097
	lda	a:$0212
	cmp	#$0001
	bne	loc_1DB0AB
loc_1DB097:
	lda	a:$1FCA
	beq	loc_1DB0A4
	; (not executed in the CDL traces)
	lda	a:$0252
	cmp	#$0001
	bne	loc_1DB0AB
loc_1DB0A4:
	inc	$12,x
	lda	#$0040
	sta	$24,x
loc_1DB0AB:
	rtl

sub_1DB0AC:
	jsr	a:sub_1DB41F
	dec	$24,x
	bpl	loc_1DB0C1
	lda	#$FFFF
	sta	a:$029E
	lda	#$8000
	sta	a:$029C
	inc	$12,x
loc_1DB0C1:
	rtl

sub_1DB0C2:
	jsr	a:sub_1DB41F
	lda	a:$028E
	bpl	loc_1DB0DC
	cmp	#$FFDD
	bcs	loc_1DB0DC
	stz	a:$029C
	stz	a:$029E
	lda	#$0080
	sta	$24,x
	inc	$12,x
loc_1DB0DC:
	rtl

sub_1DB0DD:
	dec	$24,x
	bpl	loc_1DB0E8
	lda	#$0080
	sta	$24,x
	inc	$12,x
loc_1DB0E8:
	rtl

sub_1DB0E9:
	dec	$24,x
	bpl	loc_1DB102
	lda	$84
	cmp	#$0004
	beq	loc_1DB0FF
	lda	#$0100
	sta	$24,x
	lda	#$0025
	sta	$12,x
	rtl
loc_1DB0FF:
	inc	$12,x
	rtl
loc_1DB102:
	ldy	#$FF59
	lda	$24,x
	bit	#$0008
	bne	loc_1DB10F
	ldy	#$FF5D
loc_1DB10F:
	jsr	a:sub_1DCC1C
	rtl

sub_1DB113:
	lda	#$004A
	jsl	f:sub_00868F
	stz	a:$1636
	lda	#$0010
	sta	a:$1638
	inc	$12,x
	jsr	a:sub_1DB81A
	stz	$30,x
	lda	#$401D
	sta	$16,x
	lda	#$002C
	sta	$28,x
	lda	#$FFB0
	sta	$2A,x
	lda	#$006A
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	lda	#$0180
	sta	$06,x
	stz	$34,x
	stz	$36,x
	lda	#$0001
	sta	$3A,x
	phx
	ldx	#$0940
	lda	#$0053
	sta	$10,x
	lda	#$003C
	sta	$16,x
	lda	#$007C
	sta	$28,x
	lda	#$FFD8
	sta	$2A,x
	lda	#$0042
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	plx
	rtl

sub_1DB175:
	stz	$00
	lda	#$00FF
	sta	$04
	jsr	a:sub_1DBA68
	jsr	a:sub_1DB472
	lda	a:$1636
	cmp	#$0012
	bcc	loc_1DB19C
	lda	#$0049
	jsl	f:sub_00868F
	inc	$12,x
	jsr	a:sub_1DB642
	lda	#$0002
	sta	a:$16B6
loc_1DB19C:
	rtl

sub_1DB19D:
	lda	a:$1398
	bit	#$00FF
	beq	loc_1DB1D0
	bit	#$0080
	bne	loc_1DB1D0
	inc	$12,x
	stz	a:$029C
	stz	a:$029E
	stz	$1C,x
	stz	$1E,x
	lda	#$0004
	sta	a:$13BA
	lda	#$0100
	sta	$24,x

sub_1DB1C1:
	jsr	a:sub_1DB685
	dec	$24,x
	bpl	loc_1DB1D0
	inc	$12,x
	lda	#$8000
	sta	a:$029C
loc_1DB1D0:
	lda	$BC
	bne	loc_1DB1F2
	lda	a:$16A2
	cmp	#$000A
	bcs	loc_1DB1E3
	inc	a
	sta	a:$16A2
	sta	a:$16A4
loc_1DB1E3:
	lda	a:$16A6
	cmp	#$000C
	bcs	loc_1DB1F2
	inc	a
	sta	a:$16A6
	sta	a:$16A8
loc_1DB1F2:
	lda	#$0004
	sta	a:$1662
	jsr	a:sub_1DB44A
	jsr	a:sub_1DB4E2
	jsr	a:sub_1DB4F5
	jsr	a:sub_1DB5ED
	rtl

sub_1DB205:
	lda	a:$028E
	bmi	loc_1DB237
	cmp	#$0040
	bcc	loc_1DB237
	stz	a:$16B4
	ldy	#$0200
	jsr	a:sub_1DB741
	ldy	#$0240
	jsr	a:sub_1DB741
	inc	$12,x

sub_1DB220:
	lda	$78
	bit	#$01FF
	bne	loc_1DB22E
	inc	$12,x
	lda	#$0400
	sta	$36,x
loc_1DB22E:
	jsr	a:sub_1DB5A2
	jsr	a:sub_1DB758
	jsr	a:sub_1DB70F
loc_1DB237:
	jsr	a:sub_1DB685
	jsr	a:sub_1DB44A
	jsr	a:sub_1DB4E2
	jsr	a:sub_1DB4F5
	jsr	a:sub_1DB5ED
	jsr	a:sub_1DB41F
	rtl

sub_1DB24A:
	jsr	a:sub_1DB758
	jsr	a:sub_1DB70F
	jsr	a:sub_1DB685
	jsr	a:sub_1DB44A
	jsr	a:sub_1DB4E2
	jsr	a:sub_1DB509
	jsr	a:sub_1DB5ED
	jsr	a:sub_1DB41F
	dec	$36,x
	bpl	loc_1DB268
	dec	$12,x
loc_1DB268:
	rtl

sub_1DB269:
	lda	a:$1398
	and	#$01FF
	cmp	#$0004
	bcs	loc_1DB2BB
	clc
	adc	#$0200
	sta	a:$1398
	clc
	adc	#$0100
	and	#$FF00
	sta	a:$13B0
	inc	$12,x
	lda	#$0006
	sta	a:$13BA
	lda	#$0012
	sta	$46
	lda	#$0004
	sta	a:$1E9C
	lda	#$0001
	sta	a:$16B4
	lda	#$0001
	sta	a:$1E5E
	lda	#$6000
	sta	a:$1636
	lda	#$FFFF
	sta	a:$1638
	jsl	f:sub_1DB306
	lda	a:$13D8
	sta	a:$13E2
	rtl
loc_1DB2BB:
	jsr	a:sub_1DB685
	jsr	a:sub_1DB758
	jsr	a:sub_1DB41F
	rtl

sub_1DB2C5:
	jsr	a:sub_1DB44A
	dec	$24,x
	bpl	loc_1DB2F1
	inc	$12,x
	phx
	ldx	#.loword(data_05F8C3)
	jsl	f:sub_0090A8
	ldy	#$F8DA
	jsl	f:sub_009982
	plx
	stz	$0A,x
	lda	#$0180
	sta	$0E,x
	lda	#$0200
	sta	$24,x
	lda	#$0100
	sta	f:$7EE809
loc_1DB2F1:
	jsr	a:sub_1DB685
	jsr	a:sub_1DB758
	jsr	a:sub_1DB41F
	lda	a:$1636
	cmp	#$0014
	bcs	loc_1DB305
	jsr	a:sub_1DB472
loc_1DB305:
	rtl

sub_1DB306:
	jsr	a:sub_1DB7DE
	jsr	a:sub_1DB6B6
	lda	#$0064
	sta	$00
	lda	#$0080
	sta	$02
	jsr	a:sub_1DB762
	jsr	a:sub_1DB43F
	lda	a:$1398
	bpl	loc_1DB337
	stz	a:$1398
	lda	#$0004
	sta	a:$13BA
	lda	#$00C0
	sta	$24,x
	inc	$12,x
	stz	a:$163A
	stz	a:$163C
loc_1DB337:
	rtl

sub_1DB338:
	jsr	a:sub_1DB6F1
	lda	a:$163E
	bmi	loc_1DB360
	cmp	#$0046
	bcc	loc_1DB360
	stz	a:$163A
	stz	a:$163C
	inc	$12,x
	lda	#$0006
	sta	a:$13BA
	lda	#$0900
	sta	a:$13BC
	sta	a:$13B0
	jsl	f:sub_04E21B
loc_1DB360:
	jsr	a:sub_1DB7DE
	jsr	a:sub_1DB98D
	lda	#$0074
	sta	$00
	lda	#$0080
	sta	$02
	jsr	a:sub_1DB762
	jsr	a:sub_1DB43F
	rtl

sub_1DB377:
	jsr	a:sub_1DB6D3
	jsr	a:sub_1DB668
	jsr	a:sub_1DB98D
	lda	#$0088
	sta	$00
	lda	#$0090
	sta	$02
	jsr	a:sub_1DB762
	jsr	a:sub_1DB43F
	jsr	a:sub_1DB7DE
	lda	#$0100
	cmp	a:$1398
	bcs	loc_1DB3CA
	sta	a:$1398
	inc	$12,x
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	asl	a
	clc
	adc	#$4640
	tay
	lda	#$2002
	sta	$02
	lda	#$0002
	sta	$04
	lda	#$0020
	jsl	f:sub_00CFAF
	lda	#$0060
	sta	$24,x
	lda	#$0002
	sta	a:$16B4
loc_1DB3CA:
	rtl

sub_1DB3CB:
	dec	$24,x
	bpl	sub_1DB409
	inc	$12,x
	lda	a:$1F8A
	beq	loc_1DB3E2
	lda	#$0013
	sta	a:$0212
	lda	#$0040
	sta	a:$0234
loc_1DB3E2:
	lda	a:$1FCA
	beq	loc_1DB3F3
	; (not executed in the CDL traces)
	lda	#$0013
	sta	a:$0252
	lda	#$0040
	sta	a:$0274
loc_1DB3F3:
	stz	a:$16B4
	lda	#$01F0
	sta	$24,x
	bra	sub_1DB409

sub_1DB3FD:
	dec	$24,x
	bpl	sub_1DB409
	lda	#$0100
	sta	a:$1686
	inc	$12,x

sub_1DB409:
	lda	a:$028E
	bpl	loc_1DB412
	jsl	f:sub_02FCCB
loc_1DB412:
	jsr	a:sub_1DB6D3
	jsr	a:sub_1DB7B9
	jsr	a:sub_1DB43F
	jsr	a:sub_1DB7DE
	rtl

sub_1DB41F:
	sec
	lda	#$0077
	sbc	a:$028E
	sta	f:$7EE807
	lda	a:$028E
	bmi	loc_1DB434
	cmp	#$0008
	bcs	loc_1DB437
loc_1DB434:
	lda	#$0008
loc_1DB437:
	ora	#$0700
	sta	f:$7EE800
loc_1DB43E:
	rts

sub_1DB43F:
	sec
	lda	#$0078
	sbc	a:$028E
	sta	a:$13D8
	rts

sub_1DB44A:
	sec
	lda	#$0141
	sbc	$0E,x
	sta	f:$7EE809
	clc
	lda	$0E,x
	adc	#$FFF0
	sta	a:$094E
	clc
	adc	#$0010
	sta	a:$169E
	sta	a:$16A0
	clc
	adc	#$FFE0
	sta	a:$169A
	sta	a:$169C
	rts

sub_1DB472:
	ldy	a:$1636
	bmi	loc_1DB43E
	cpy	#$0014
	bcs	loc_1DB43E
	dec	a:$1638
	bpl	loc_1DB43E
	lda	$BC
	beq	loc_1DB43E
	phx
	lda	#$0001
	sta	$02
	lda	#$0018
	sta	$08
	clc
	lda	a:data_05F8EC,y
	and	#$000F
	adc	#$4B80
	sta	$FC
	eor	#$001C
	sta	$FA
	clc
	lda	a:data_05F900,y
	and	#$00FF
	adc	#$F914
	tay
	clc
	adc	#$0006
	sta	$FE
	lda	$FC
	jsl	f:sub_00FEA3
	lda	#$0001
	sta	$02
	lda	#$0030
	sta	$08
	ldy	$FE
	lda	$FA
	ldx	#$0018
	jsl	f:sub_00FEAA
	plx
	ldy	a:$1636
	lda	a:data_05F8EC,y
	and	#$00FF
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	a:$1638
	inc	a:$1636
	rts

sub_1DB4E2:
	jsr	a:sub_1DB5B6
	clc
	lda	$32,x
	sta	a:$1644
	adc	#$0064
	and	#$00FF
	sta	a:$1642
	rts

sub_1DB4F5:
	eor	#$007F
	and	#$00FF
	sta	a:$163E
	sec
	sbc	#$0094
	and	#$00FF
	sta	a:$1640
	rts

sub_1DB509:
	phx
	ldx	#$0300
	ldy	#$0000
	jsr	a:sub_1DB51E
	ldx	#$0440
	ldy	#$0002
	jsr	a:sub_1DB51E
	plx
	rts

sub_1DB51E:
	lda	a:$0936
	cmp	#$03C0
	bcs	loc_1DB55B
	cmp	#$0040
	bcc	loc_1DB55B
	and	#$0040
	eor	a:data_05F894,y
	beq	loc_1DB55B
	lda	a:$0936
	and	#$003F
	cmp	#$003F
	bne	loc_1DB556
	phy
	lda	#$0020
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	ply
	sta	a:$0938
	lda	#$005C
	jsl	f:sub_00868F
	rts
loc_1DB556:
	cmp	#$0020
	bcs	loc_1DB575
loc_1DB55B:
	lda	a:$16A2,y
	cmp	#$0001
	bcc	loc_1DB574
	dec	a
	sta	a:$16A2,y
	clc
	lda	a:$163E,y
	adc	a:data_05F898,y
	and	#$00FF
	sta	a:$163E,y
loc_1DB574:
	rts
loc_1DB575:
	sec
	lda	a:$0938
	sbc	a:$163E,y
	bpl	loc_1DB582
	eor	#$FFFF
	inc	a
loc_1DB582:
	cmp	#$0004
	bcc	loc_1DB594
	clc
	lda	a:$163E,y
	adc	a:data_05F89C,y
	and	#$00FF
	sta	a:$163E,y
loc_1DB594:
	lda	a:$16A2,y
	cmp	#$0020
	bcs	loc_1DB5A1
	inc	a
	inc	a
	sta	a:$16A2,y
loc_1DB5A1:
	rts

sub_1DB5A2:
	lda	$BC
	bne	loc_1DB5B5
	lda	a:$16A2
	cmp	#$000A
	bcs	loc_1DB5B5
	inc	a
	sta	a:$16A2
	sta	a:$16A4
loc_1DB5B5:
	rts

sub_1DB5B6:
	lda	$32,x
	ldy	$30,x
	bne	loc_1DB5CD
	ldy	$34,x
	sec
	sbc	a:data_05F8BB,y
	and	#$00FF
	sta	$32,x
	cmp	#$0018
	bcc	loc_1DB5DE
	rts
loc_1DB5CD:
	ldy	$34,x
	clc
	adc	a:data_05F8BB,y
	and	#$00FF
	sta	$32,x
	cmp	#$007C
	bcs	loc_1DB5E5
	rts
loc_1DB5DE:
	lda	#$005E
	jsl	f:sub_00868F
loc_1DB5E5:
	lda	$30,x
	eor	#$0002
	sta	$30,x
	rts

sub_1DB5ED:
	phx
	ldx	#$0300
	ldy	#$0000
	jsr	a:sub_1DB614
	ldx	#$0440
	ldy	#$0002
	jsr	a:sub_1DB614
	ldx	#$0580
	ldy	#$0004
	jsr	a:sub_1DB614
	ldx	#$0640
	ldy	#$0006
	jsr	a:sub_1DB614
	plx
	rts

sub_1DB614:
	lda	a:$16A2,y
	sta	$30,x
	clc
	lda	$32,x
	adc	#$0004
	cmp	#$0010
	bcc	loc_1DB628
	sec
	sbc	#$0010
loc_1DB628:
	clc
	adc	$34,x
	tax
	lda	a:data_05F8B3,y
	sta	f:$7EE000,x
	lda	a:$169A,y
	sta	f:$7EE100,x
	lda	a:$163E,y
	sta	f:$7EE200,x
	rts

sub_1DB642:
	lda	#$0002
	sta	a:$13BA
	sta	a:$13B4
	lda	#$0004
	sta	a:$13B6
	lda	#$2000
	sta	a:$029C
	sta	a:$163A
	sta	$1C,x
	lda	#$FFFF
	sta	a:$029E
	sta	a:$163C
	sta	$1E,x
	rts

sub_1DB668:
	lda	a:$163C
	cmp	#$0003
	bcs	loc_1DB6A2
	clc
	lda	a:$163A
	adc	#$1800
	sta	a:$163A
	lda	a:$163C
	adc	#$0000
	sta	a:$163C
	bra	loc_1DB6A2

sub_1DB685:
	lda	a:$163C
	bpl	loc_1DB68F
	cmp	#$FFFA
	bcc	loc_1DB6A2
loc_1DB68F:
	sec
	lda	a:$163A
	sbc	#$1000
	sta	a:$163A
	lda	a:$163C
	sbc	#$0000
	sta	a:$163C
loc_1DB6A2:
	clc
	lda	a:$139C
	adc	a:$163A
	sta	a:$139C
	lda	a:$1398
	adc	a:$163C
	sta	a:$1398
	rts

sub_1DB6B6:
	lda	a:$163C
	cmp	#$FFFF
	bcs	loc_1DB6A2
	clc
	lda	a:$163A
	adc	#$1000
	sta	a:$163A
	lda	a:$163C
	adc	#$0000
	sta	a:$163C
	bra	loc_1DB6A2

sub_1DB6D3:
	lda	a:$1638
	bpl	loc_1DB6DD
	cmp	#$FFFF
	bcc	loc_1DB70E
loc_1DB6DD:
	sec
	lda	a:$1636
	sbc	#$C800
	sta	a:$1636
	lda	a:$1638
	sbc	#$0000
	sta	a:$1638
	rts

sub_1DB6F1:
	lda	a:$1638
	cmp	#$0006
	bmi	loc_1DB6FB
	bcs	loc_1DB70E
loc_1DB6FB:
	clc
	lda	a:$1636
	adc	#$1000
	sta	a:$1636
	lda	a:$1638
	adc	#$0000
	sta	a:$1638
loc_1DB70E:
	rts

sub_1DB70F:
	lda	$34,x
	beq	loc_1DB722
	stz	$1C,x
	lda	#$FFFE
	sta	$1E,x
	lda	$0E,x
	cmp	#$00C4
	bcc	loc_1DB739
loc_1DB721:
	rts
loc_1DB722:
	lda	#$C000
	sta	$1C,x
	stz	$1E,x
	lda	$0E,x
	cmp	#$0100
	bcc	loc_1DB721
	lda	#$005D
	jsl	f:sub_00868F
	bra	loc_1DB739
loc_1DB739:
	lda	$34,x
	eor	#$0002
	sta	$34,x
	rts

sub_1DB741:
	lda	a:$1D8A,y
	beq	loc_1DB757
	lda	a:$0016,y
	bmi	loc_1DB757
	lda	#$0060
	sta	a:$0024,y
	lda	#$0003
	sta	a:$0016,y
loc_1DB757:
	rts

sub_1DB758:
	lda	#$0040
	sta	$00
	lda	#$0060
	sta	$02

sub_1DB762:
	ldy	$3A,x
	bne	loc_1DB790
	lda	a:$028E
	bmi	loc_1DB790
	cmp	$00
	bcs	loc_1DB771
	inc	$3A,x
loc_1DB771:
	lda	a:$029D
	bpl	loc_1DB77B
	cmp	#$FF80
	bcc	loc_1DB7B8
loc_1DB77B:
	sec
	lda	a:$029C
	sbc	#$0400
	sta	a:$029C
	lda	a:$029E
	sbc	#$0000
	sta	a:$029E
	bra	loc_1DB7B8
loc_1DB790:
	lda	a:$028E
	bmi	loc_1DB79B
	cmp	$02
	bcc	loc_1DB79B
	stz	$3A,x
loc_1DB79B:
	lda	a:$029D
	bmi	loc_1DB7A5
	cmp	#$0080
	bcs	loc_1DB7B8
loc_1DB7A5:
	clc
	lda	a:$029C
	adc	#$0400
	sta	a:$029C
	lda	a:$029E
	adc	#$0000
	sta	a:$029E
loc_1DB7B8:
	rts

sub_1DB7B9:
	lda	a:$028E
	bpl	loc_1DB7CA
	cmp	#$FFF0
	bcs	loc_1DB7CA
	stz	a:$029C
	stz	a:$029E
	rts
loc_1DB7CA:
	sec
	lda	a:$029C
	sbc	#$0400
	sta	a:$029C
	lda	a:$029E
	sbc	#$0000
	sta	a:$029E
	rts

sub_1DB7DE:
	lda	#$0003
	sta	a:$1676
	lda	a:$1398
	sta	a:$1674
	phx
	ldx	#$0006
	lda	a:$1636
	sta	$00
	lda	a:$1638
	sta	$02
loc_1DB7F8:
	clc
	lda	$00
	adc	f:$7EE402,x
	sta	f:$7EE402,x
	lda	$02
	adc	f:$7EE002,x
	sta	f:$7EE002,x
	lda	$02
	asl	a
	ror	$02
	ror	$00
	dex
	dex
	bne	loc_1DB7F8
	plx
	rts

sub_1DB81A:
	phx
	ldy	#$000C
	lda	#$0000
	sta	$08
	lda	#$0004
	sta	$0A
	lda	#$0004
	ldx	#$0300
	jsr	a:sub_1DB85C
	lda	#$0004
	ldy	#$000C
	ldx	#$0440
	jsr	a:sub_1DB85C
	lda	#$000E
	sta	$0A
	lda	#$0002
	ldy	#$0000
	ldx	#$0580
	jsr	a:sub_1DB85C
	lda	#$0002
	ldy	#$0000
	ldx	#$0640
	jsr	a:sub_1DB85C
	plx
	rts

sub_1DB85C:
	sta	$02
	sty	$04
	ldy	#$0000
loc_1DB863:
	lda	#$0096
	sta	$10,x
	lda	$04
	sta	$16,x
	lda	#$C503
	sta	$00,x
	lda	#$0600
	sta	$02,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	phx
	phy
	lda	#$0180
	sta	$0A,x
	ldx	$08
	ldy	#$0008
loc_1DB88C:
	sta	f:$7EE000,x
	inx
	inx
	dey
	bpl	loc_1DB88C
	ply
	plx
	lda	$08
	sta	$34,x
	lda	$0A
	sta	$38,x
	stz	$30,x
	stz	$32,x
	clc
	txa
	adc	#$0040
	sta	$36,x
	tax
	clc
	lda	$08
	adc	#$0010
	sta	$08
	dec	$02
	bpl	loc_1DB863
	sec
	txa
	sbc	#$0040
	tax
	stz	$36,x
	rts

sub_1DB8C0:
	lda	a:$1688
	beq	loc_1DB8CB
	lda	#$8000
	sta	$16,x
	rtl
loc_1DB8CB:
	clc
	lda	$32,x
	adc	$34,x
	phx
	tax
	lda	f:$7EE000,x
	sta	$FC
	lda	f:$7EE100,x
	sta	$FE
	lda	f:$7EE200,x
	sta	$FA
	plx
	ldy	$30,x
	jsl	f:sub_1DACA4
	clc
	lda	$FC
	adc	$08
	sta	$0A,x
	sta	$FC
	clc
	lda	$FE
	adc	$0A
	sta	$0E,x
	sta	$FE
	ldy	$36,x
	beq	loc_1DB940
	lda	$30,x
	sta	a:$0030,y
	clc
	lda	$32,x
	adc	$38,x
	cmp	#$0010
	bcc	loc_1DB914
	sec
	sbc	#$0010
loc_1DB914:
	clc
	adc	$34,x
	clc
	adc	#$0010
	phx
	tax
	lda	$FC
	sta	f:$7EE000,x
	lda	$FE
	sta	f:$7EE100,x
	lda	$FA
	sta	f:$7EE200,x
	plx
loc_1DB930:
	lda	$32,x
	inc	a
	inc	a
	cmp	#$0010
	bcc	loc_1DB93D
	sec
	sbc	#$0010
loc_1DB93D:
	sta	$32,x
	rtl
loc_1DB940:
	lda	$FA
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_05F8AB,y
	sta	$00,x
	bra	loc_1DB930

sub_1DB952:
	stz	a:$1644
	lda	#$FFFF
	sta	a:$163E
	stz	a:$1642
	lda	#$0010
	sta	a:$1640
	jsl	f:sub_00FF30
	lda	#$0002
	sta	a:$1E94
	lda	#$0013
	sta	a:$1E96
	lda	#$0001
	sta	a:$1E84
	phx
	ldy	#$F8E3
	jsl	f:sub_009982
	plx
	phx
	ldx	#.loword(data_05F8D1)
	jsl	f:sub_0090A8
	plx
loc_1DB98C:
	rts

sub_1DB98D:
	ldy	a:$169A
	lda	a:$1640
	bne	loc_1DB99F
	lda	a:$1644
	bit	#$0010
	bne	loc_1DBA0F
	beq	loc_1DB9F4
loc_1DB99F:
	dec	a:$1640
	bne	loc_1DB98C
	ldy	a:$163E
	iny
	sty	a:$163E
	lda	a:data_05F9D0,y
	and	#$00FF
	cmp	#$00FE
	bcc	loc_1DB9C5
	ldy	#$0040
	cmp	#$00FE
	beq	loc_1DB9C1
	ldy	#$0160
loc_1DB9C1:
	sty	a:$1640
	rts
loc_1DB9C5:
	ldy	#$0020
	sta	a:$1644
	and	#$000F
	sta	a:$169C
	phx
	lda	a:$1644
	bit	#$0010
	bne	loc_1DB9EF
	tax
	ldy	a:$1642
	lda	a:data_05FA1A,y
	sta	f:$7EE900,x
	lda	a:data_05FA52,y
	sta	f:$7EE910,x
	ldy	#$0000
loc_1DB9EF:
	sty	a:$169A
	plx
	rts
loc_1DB9F4:
	iny
	cpy	#$0020
	bcc	loc_1DBA36
	ldy	#$0060
	lda	a:$169C
	beq	loc_1DBA05
	ldy	#$0020
loc_1DBA05:
	sty	a:$1640
	inc	a:$1642
	inc	a:$1642
	rts
loc_1DBA0F:
	dey
	bne	loc_1DBA36
	ldy	#$0020
	lda	a:$169C
	beq	loc_1DBA1D
	ldy	#$0001
loc_1DBA1D:
	sty	a:$1640
	inc	a
	inc	a
	xba
	lsr	a
	lsr	a
	clc
	adc	#$5C20
	sta	$B0
	lda	#$A000
	sta	$B4
	lda	#$00C0
	sta	$B2
	rts
loc_1DBA36:
	sty	a:$169A
	phx
	tya
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_05F9C8,y
	pha
	sec
	sbc	#$0400
	sta	$FC
	ldx	a:$169C
	lda	f:$7EE900,x
	tax
	pla
	jsl	f:sub_009015
	ldx	a:$169C
	lda	f:$7EE910,x
	tax
	lda	$FC
	jsl	f:sub_009015
	plx
	rts

sub_1DBA68:
	lda	#$0004
	sta	a:$1662
	lda	$BC
	beq	loc_1DBA8B
	stz	$06
	lda	#$00C0
	sta	$02
	ldy	#$0700
	lda	#$C69C
	jsl	f:sub_01CF3C
	bcs	loc_1DBA8B
	lda	#$FFFC
	sta	a:$001E,y
loc_1DBA8B:
	rts

sub_1DBA8C:
	jsr	a:sub_1DB6F1
	jsr	a:sub_1DB7DE
	lda	#$0030
	sta	$00
	lda	#$0040
	sta	$02
	jsr	a:sub_1DB762
	jsr	a:sub_1DB43F
	lda	$24,x
	bmi	loc_1DBAAA
	dec	$24,x
	bpl	loc_1DBAE9
loc_1DBAAA:
	dec	a:$1E80
	dec	a:$1E80
	beq	loc_1DBAB4
	bpl	loc_1DBAE9
loc_1DBAB4:
	stz	a:$029C
	stz	a:$029E
	stz	a:$1E9A
	stz	$46
	inc	$12,x
	lda	#$00F0
	sta	a:$13D8
	lda	#$0024
	sta	$24,x
	phx
	ldy	#$FECD
	jsl	f:sub_009982
	ldx	#$1210
	ldy	#$FED9
	jsl	f:sub_009985
	plx
	stz	a:$163E
	lda	#$0081
	jsl	f:sub_00868F
loc_1DBAE9:
	rtl

sub_1DBAEA:
	dec	$24,x
	bpl	loc_1DBB2D
	lda	#$0080
	sta	$24,x
	phx
	ldy	$84
	ldx	a:data_05FD9B,y
	jsl	f:sub_0090A8
	ldy	#$FEE8
	jsl	f:sub_009982
	plx
	inc	$12,x
	lda	#$0081
	jsl	f:sub_00868F
	stz	a:$029C
	stz	a:$029E
	stz	a:$02BA
	lda	#$FFDD
	sta	a:$028E
	ldy	a:$1F8A
	beq	loc_1DBB25
	sta	a:$020E
loc_1DBB25:
	ldy	a:$1FCA
	beq	loc_1DBB2D
	; (not executed in the CDL traces)
	sta	a:$024E
loc_1DBB2D:
	rtl

sub_1DBB2E:
	dec	$24,x
	bpl	loc_1DBB6A
	lda	#$0040
	sta	$24,x
	lda	$84
	cmp	#$0004
	beq	loc_1DBB45
	lda	#$0029
	sta	$12,x
	bra	loc_1DBB47
loc_1DBB45:
	inc	$12,x
loc_1DBB47:
	phx
	ldx	#$F4C3
	jsl	f:sub_0098D4
	lda	#$0071
	jsl	f:sub_00868F
	ldy	#$FEC7
	jsl	f:sub_009982
	ldx	#.loword(data_05FEDF)
	jsl	f:sub_0090A8
	plx
	lda	#$0013
	sta	$46
loc_1DBB6A:
	rtl

sub_1DBB6B:
	dec	$24,x
	bpl	loc_1DBB83
	inc	$12,x
	lda	#$0080
	sta	$24,x
	phx
	ldy	a:$163E
	lda	a:ptrs_05FDBC,y
	tax
	jsl	f:sub_0090A8
	plx
loc_1DBB83:
	rtl

sub_1DBB84:
	dec	$24,x
	bpl	loc_1DBB8F
	lda	#$0004
	sta	$24,x
	inc	$12,x
loc_1DBB8F:
	rtl

sub_1DBB90:
	dec	$24,x
	bpl	loc_1DBBA8
	lda	#$00E0
	sta	$24,x
	inc	$12,x
	phx
	ldx	#$1210
	ldy	#$FED3
	jsl	f:sub_009985
	plx
	rtl
loc_1DBBA8:
	lda	$84
	cmp	#$0004
	bne	loc_1DBBD9
	lda	$BC
	beq	loc_1DBBD9
	lda	$24,x
	and	#$0002
	tay
	lda	a:data_05FDF7,y
	pha
	lda	a:data_05FDF3,y
	ldy	a:$163E
	clc
	adc	a:data_05FDFB,y
	tay
	lda	#$0004
	sta	$02
	lda	#$0040
	sta	$08
	pla
	phx
	jsl	f:sub_00FEA3
	plx
loc_1DBBD9:
	rtl

sub_1DBBDA:
	dec	$24,x
	bpl	loc_1DBC15
	lda	#$0014
	sta	$24,x
	lda	#$0019
	sta	$12,x
	phx
	ldx	#$1210
	ldy	#$FED9
	jsl	f:sub_009985
	plx
	inc	a:$163E
	inc	a:$163E
	lda	a:$163E
	cmp	#$000A
	bcc	loc_1DBC15
	lda	#$0054
	sta	$24,x
	lda	#$001D
	sta	$12,x
	phx
	ldy	#$FECD
	jsl	f:sub_009982
	plx
loc_1DBC15:
	rtl

sub_1DBC16:
	dec	$24,x
	bmi	loc_1DBC1D
	brl	loc_1DBBA8
loc_1DBC1D:
	lda	#$0380
	sta	$24,x
	inc	$12,x
	stz	$46
	jsr	a:sub_1DB952
	rtl

sub_1DBC2A:
	lda	$BC
	beq	loc_1DBC58
	sec
	lda	$24,x
	sbc	#$0080
	sta	$24,x
	bne	loc_1DBC49
	inc	$12,x
	lda	#$0012
	sta	$46
	lda	#$001F
	sta	a:$1E9A
	stz	a:$1E80
	rtl
loc_1DBC49:
	adc	#$5C00
	sta	$B0
	lda	#$A000
	sta	$B4
	lda	#$00FE
	sta	$B2
loc_1DBC58:
	rtl

sub_1DBC59:
	dec	$24,x
	bpl	loc_1DBC89
	lda	$BC
	beq	loc_1DBC89
	lda	#$0002
	sta	$02
	lda	#$0020
	sta	$08
	ldy	#$946A
	lda	#$4C0C
	phx
	jsl	f:sub_00FEA3
	plx
	inc	$12,x
	jsr	a:sub_1DB642
	lda	#$0012
	sta	a:$1636
	lda	#$0059
	jsl	f:sub_00868F
loc_1DBC89:
	lda	#$0058
	sta	$00
	lda	#$003F
	sta	$04
	jsr	a:sub_1DBA68
	rtl

sub_1DBC97:
	lda	a:$1398
	bit	#$00FF
	beq	loc_1DBCBB
	bit	#$0080
	bne	loc_1DBCBB
	inc	$12,x
	stz	a:$029C
	stz	a:$029E
	stz	$1C,x
	stz	$1E,x
	lda	#$0004
	sta	a:$13BA
	lda	#$0100
	sta	$24,x
loc_1DBCBB:
	jsr	a:sub_1DB685
	rtl

sub_1DBCBF:
	dec	$24,x
	bpl	loc_1DBCBB
	inc	$12,x
	lda	#$8000
	sta	a:$029C
	bra	loc_1DBCBB

sub_1DBCCD:
	lda	a:$028E
	bmi	loc_1DBCBB
	cmp	#$0010
	bcc	loc_1DBCBB
	lda	#$0010
	sta	$24,x
	lda	#$0010
	sta	$12,x
	bra	loc_1DBCBB

sub_1DBCE3:
	lda	$0E,x
	cmp	#$0108
	bcc	loc_1DBCF5
	stz	$1C,x
	stz	$1E,x
	inc	$12,x
	lda	#$0010
	sta	$24,x
loc_1DBCF5:
	lda	$24,x
	bmi	loc_1DBCFD
	dec	$24,x
	bra	loc_1DBD02
loc_1DBCFD:
	lda	#$8000
	sta	$1C,x
loc_1DBD02:
	jsr	a:sub_1DB758
	jsr	a:sub_1DB685
	jsr	a:sub_1DB44A
	jsr	a:sub_1DB41F
	jsr	a:sub_1DBD6A
	lda	#$003F
	sta	$04
	sta	$06
	jsr	a:sub_1DBDA0
	rtl

sub_1DBD1C:
	jsr	a:sub_1DB758
	jsr	a:sub_1DB685
	jsr	a:sub_1DB41F
	jsr	a:sub_1DBD89
	jsr	a:sub_1DBD6A
	dec	$24,x
	bpl	loc_1DBD31
	inc	$12,x
loc_1DBD31:
	rtl

sub_1DBD32:
	jsr	a:sub_1DB758
	jsr	a:sub_1DB685
	jsr	a:sub_1DB41F
	jsr	a:sub_1DBD89
	jsr	a:sub_1DBD6A
	inc	$12,x
	lda	#$0002
	sta	a:$16BC
	rtl

sub_1DBD4A:
	ldy	$20,x
	bne	loc_1DBD54
	lda	#$8000
	sta	$16,x
	rtl
loc_1DBD54:
	lda	a:$0004,y
	sta	$02,x
	clc
	lda	$1C,x
	adc	#$8000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_1DBD69:
	; (not executed in the CDL traces)
	rtl

sub_1DBD6A:
	lda	#$0002
	sta	a:$1662
	lda	$78
	bit	#$0001
	bne	loc_1DBD88
	lda	$E8
	and	#$0003
	bne	loc_1DBD88
	lda	#$912A
	sta	$9A
	lda	#$3040
	sta	$98
loc_1DBD88:
	rts

sub_1DBD89:
	lda	$0E,x
	cmp	#$00E0
	bcc	loc_1DBD96
	lda	$BE
	bne	loc_1DBD96
	dec	$0E,x
loc_1DBD96:
	lda	#$00FF
	sta	$04
	lda	#$007F
	sta	$06

sub_1DBDA0:
	lda	$0A,x
	adc	#$FFF0
	sta	$00
	lda	$0E,x
	sta	$02
	ldy	#$02C0
	lda	#$0001
	sta	$FC
loc_1DBDB3:
	lda	$E8
	adc	$EA
	adc	$C0
	sta	$E8
	tya
	adc	$3A
	adc	$EA
	sta	$EA
	lda	#$C558
	jsl	f:sub_01CF3C
	bcs	loc_1DBDF6
	lda	#$0098
	sta	a:$0010,y
	lda	#$FFFE
	sta	a:$001E,y
	phx
	ldx	#$0000
	lda	a:$000A,y
	cmp	#$0080
	bcc	loc_1DBDE5
	inx
	inx
loc_1DBDE5:
	lda	a:data_05FEF1,x
	sta	a:$0018,y
	lda	a:data_05FEF5,x
	sta	a:$001A,y
	plx
	dec	$FC
	bpl	loc_1DBDB3
loc_1DBDF6:
	jsl	f:sub_00FD8D
	rts

sub_1DBDFB:
	lda	$24,x
	bmi	loc_1DBE03
	dec	$24,x
	bpl	sub_1DBE2C
loc_1DBE03:
	lda	$28
	ora	$2A
	bit	#$1000
	bne	loc_1DBE11
	jsr	a:sub_1DBE61
	bra	sub_1DBE2C
loc_1DBE11:
	; (not executed in the CDL traces)
	phx
	ldx	#$FF0A
	lda	#$0400
	jsl	f:sub_009015
	plx
	lda	#$0100
	sta	a:$1686
	lda	#$0084
	jsl	f:sub_00868F
	inc	$12,x

sub_1DBE2C:
	jsr	a:sub_1DBE30
	rtl

sub_1DBE30:
	lda	$84
	beq	loc_1DBE60
	lda	#$00FF
	sta	$06
	sta	$04
	sta	$02
	lda	#$0010
	sta	$00
	lda	#$C6EA
	ldy	$BC
	bne	loc_1DBE4C
	lda	#$C702
loc_1DBE4C:
	ldy	#$0300
	jsl	f:sub_01CF3C
	bcs	loc_1DBE60
	lda	$E8
	and	#$0007
	adc	#$FFFA
	sta	a:$001A,y
loc_1DBE60:
	rts

sub_1DBE61:
	phx
	ldx	#$FEF9
	lda	$78
	bit	#$0010
	bne	loc_1DBE6F
	ldx	#$FF0A
loc_1DBE6F:
	lda	#$0400
	jsl	f:sub_009015
	plx
	rts

sub_1DBE78:
	lda	a:$1644
	bmi	loc_1DBE80
	dec	a:$1644
loc_1DBE80:
	lda	$26,x
	beq	loc_1DBEA5
	lda	#$912A
	sta	$9A
	lda	#$0030
	sta	$98
	lda	a:$16BA
	bmi	loc_1DBE98
	dec	a:$16BA
	bra	loc_1DBEA5
loc_1DBE98:
	lda	#$003C
	jsl	f:sub_00868F
	lda	#$0004
	sta	a:$16BA
loc_1DBEA5:
	lda	$06,x
	bpl	loc_1DBED8
	lda	#$0002
	sta	a:$1688
	lda	#$0002
	sta	a:$1638
	lda	#$0008
	sta	$12,x
	lda	#$0030
	sta	$16,x
	lda	#$0100
	sta	$24,x
	stz	$06,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	stz	$1E,x
	stz	$1A,x
	stz	$1C,x
	stz	$18,x
loc_1DBED8:
	lda	$12,x
	beq	loc_1DBEEE
	sec
	lda	#$0160
	sbc	$0A,x
	sta	a:$13C0
	sec
	lda	#$0140
	sbc	$0E,x
	sta	a:$13D8
loc_1DBEEE:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_1DBEFD,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DBEFD:
	.addr	sub_1DBF13
	.addr	sub_1DBF5D
	.addr	sub_1DBF76
	.addr	sub_1DBF89
	.addr	sub_1DBFA3
	.addr	sub_1DC03B
	.addr	sub_1DC05B
	.addr	sub_1DC089
	.addr	sub_1DC125
	.addr	sub_1DC145
	.addr	sub_1DC14C

sub_1DBF13:
	inc	$12,x
	ldy	$84
	lda	#$0031
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	a:data_05FF9B,y
	sta	$06,x
	lda	#$0038
	sta	$28,x
	lda	#$FFD0
	sta	$2A,x
	lda	#$014B
	sta	$36,x
	stz	$38,x
	stz	$34,x
	sec
	lda	#$0140
	sbc	a:$13D8
	sta	$0E,x
	lda	#$0060
	sta	$0A,x
	stz	a:$1638
	phx
	ldx	#.loword(data_05FF27)
	jsl	f:sub_0090A8
	plx
	stz	a:$1642
	stz	a:$16BA
	jml	f:loc_00E733

sub_1DBF5D:
	dec	$24,x
	bpl	loc_1DBF72
	lda	#$8000
	sta	$1C,x
	inc	$12,x
	lda	#$0040
	sta	$24,x
	lda	#$0010
	sta	$46
loc_1DBF72:
	jml	f:loc_00E733

sub_1DBF76:
	jsr	a:sub_1DCB48
	lda	$0E,x
	bmi	loc_1DBF88
	cmp	#$0070
	bcc	loc_1DBF88
	stz	$1C,x
	inc	$12,x
	stz	$46
loc_1DBF88:
	rtl

sub_1DBF89:
	jsr	a:sub_1DCC58
	jsr	a:sub_1DCCC0
	lda	$E8
	and	#$00FF
	sta	a:$163A
	lda	#$0001
	sta	a:$163C
	stz	a:$163E
	inc	$12,x
	rtl

sub_1DBFA3:
	lda	a:$163E
	cmp	#$0001
	bcs	loc_1DBFD4
	lda	$78
	bit	#$003F
	bne	loc_1DBFB5
	jsr	a:sub_1DCCC0
loc_1DBFB5:
	lda	#$0001
	sta	a:$1660
	lda	a:$163C
	cmp	#$0030
	bcs	loc_1DBFCA
	lda	$BC
	bne	loc_1DBFCA
	inc	a:$163C
loc_1DBFCA:
	clc
	lda	a:$163A
	adc	$3E,x
	sta	a:$163A
	rtl
loc_1DBFD4:
	cmp	#$0002
	beq	loc_1DC005
	lda	#$0060
	sta	$24,x
	ldy	#$0300
loc_1DBFE1:
	lda	a:$0006,y
	bne	loc_1DBFEE
	tya
	clc
	adc	#$0040
	tay
	bra	loc_1DBFE1
loc_1DBFEE:
	lda	#$0030
	sta	a:$0016,y
	lda	a:$0024,y
	lsr	a
	sta	a:$1636
	inc	a:$163E
	ldy	#$FF5D
	jsr	a:sub_1DCC1C
loc_1DC004:
	rtl
loc_1DC005:
	dec	$24,x
	bpl	loc_1DC004
	lda	#$0011
	sta	$16,x
	lda	$EA
	and	#$003F
	adc	#$0200
	sta	a:$1644
	inc	$12,x
	lda	a:$1636
	phx
	asl	a
	tax
	lda	f:tbl_1DC02B,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DC02B:
	.addr	sub_1DC559
	.addr	sub_1DC5B7
	.addr	sub_1DC586
	.addr	sub_1DC580
	.addr	sub_1DC5C9
	.addr	sub_1DC57A
	.addr	sub_1DC5A7
	.addr	sub_1DC5FF

sub_1DC03B:
	lda	a:$1636
	phx
	asl	a
	tax
	lda	f:tbl_1DC04B,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DC04B:
	.addr	sub_1DC1B8
	.addr	sub_1DC372
	.addr	sub_1DC31B
	.addr	sub_1DC2AB
	.addr	sub_1DC3FC
	.addr	sub_1DC23D
	.addr	sub_1DC35A
	.addr	sub_1DC51B

sub_1DC05B:
	lda	$06,x
	cmp	#$0100
	bcc	loc_1DC065
	lsr	a
	sta	$06,x
loc_1DC065:
	inc	$12,x
	stz	$3A,x
	lda	#$0010
	sta	$46
	lda	#$014B
	sta	$36,x
	lda	#$0031
	sta	$16,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$3E,x
	jsr	a:sub_1DCB48
	stz	a:$1642
	rtl

sub_1DC089:
	lda	$36,x
	ldy	$3A,x
	bne	loc_1DC0E1
	cmp	#$0111
	bcs	loc_1DC0DB
	inc	$3A,x
	lda	#$0004
	sta	$FC
loc_1DC09B:
	jsl	f:sub_019EAB
	bcs	loc_1DC0C6
	lda	#$C6DE
	jsl	f:sub_01CF66
	lda	$0E,x
	adc	#$FFE4
	sta	a:$000E,y
	lda	$0A,x
	adc	#$001C
	sta	a:$000A,y
	lda	$FC
	sta	a:$001A,y
	dec	$FC
	lda	$FC
	cmp	#$FFFB
	bne	loc_1DC09B
loc_1DC0C6:
	lda	#$0180
	sta	$0E,x
	lda	#$0105
	sta	$36,x
	lda	#$0020
	sta	$24,x
	lda	#$0003
	sta	a:$1662
loc_1DC0DB:
	dec	$36,x
	jsr	a:sub_1DCB66
	rtl
loc_1DC0E1:
	cpy	#$0002
	beq	loc_1DC10A
	dec	$24,x
	bpl	loc_1DC106
	inc	$3A,x
	lda	#$0060
	sta	$0A,x
	ldy	a:$1638
	lda	a:data_05FF1B,y
	sta	$0E,x
	ldy	#$FF59
	jsr	a:sub_1DCC1C
	lda	#$0059
	jsl	f:sub_00868F
loc_1DC106:
	jsr	a:sub_1DCB66
	rtl
loc_1DC10A:
	cmp	#$014B
	bcc	loc_1DC119
	ldy	a:$1638
	lda	a:data_05FF1F,y
	sta	$12,x
	stz	$46
loc_1DC119:
	inc	$36,x
	jsr	a:sub_1DCB66
	lda	#$0001
	sta	a:$1660
	rtl

sub_1DC125:
	lda	#$0004
	sta	a:$1662
	dec	$24,x
	bpl	loc_1DC13D
	lda	#$0006
	sta	$12,x
	phx
	ldx	#.loword(data_05FF30)
	jsl	f:sub_0090A8
	plx
loc_1DC13D:
	jsl	f:sub_00FD92
	jml	f:loc_01D83E

sub_1DC145:
	lda	#$0200
	sta	$24,x
	inc	$12,x

sub_1DC14C:
	lda	#$918A
	sta	$9A
	lda	#$0030
	sta	$98
	dec	$24,x
	bpl	loc_1DC175
	lda	#$0095
	sta	$10,x
	stz	$12,x
	clc
	lda	a:$1380
	and	#$0100
	eor	#$0000
	xba
	asl	a
	asl	a
	clc
	adc	#$0040
	sta	a:$1E8C
loc_1DC175:
	lda	$24,x
	cmp	#$0180
	bne	loc_1DC182
	inc	a:$1642
	inc	a:$1642
loc_1DC182:
	lda	$24,x
	cmp	#$0180
	bcs	loc_1DC18D
	jsl	f:sub_00FD8D
loc_1DC18D:
	lda	#$0004
	sta	a:$1662
	lda	#$00FF
	sta	$02
	stz	$00
	sta	$04
	sta	$06
	ldy	a:$1642
	lda	a:data_05FFA1,y
	sta	$FC
	lda	a:data_05FFA5,y
	ldy	#$02C0
	jsl	f:sub_01CF3C
	bcs	loc_1DC1B7
	lda	$FC
	sta	a:$001E,y
loc_1DC1B7:
	rtl

sub_1DC1B8:
	jsr	a:sub_1DCB7A
	lda	#$0070
	sta	$00
	lda	#$00A0
	sta	$02
	jsr	a:sub_1DCBD1
	lda	a:$1644
	bpl	loc_1DC1D0
	inc	$12,x
	rtl
loc_1DC1D0:
	lda	$78
	bit	#$001F
	bne	loc_1DC1E5
	lda	$E8
	bit	#$0001
	bne	loc_1DC1E5
	lda	$36,x
	eor	#$0002
	sta	$36,x
loc_1DC1E5:
	lda	#$0001
	sta	$00
	lda	#$FFFF
	sta	$02
	jsr	a:sub_1DCB04
	lda	$78
	bit	#$003F
	bne	loc_1DC208
	lda	$EA
	bit	#$0001
	bne	loc_1DC208
	lda	$38,x
	eor	#$FFFF
	inc	a
	sta	$38,x
loc_1DC208:
	lda	a:$163C
	cmp	#$0024
	bcc	loc_1DC217
	lda	#$FFFF
	sta	$38,x
	bra	loc_1DC221
loc_1DC217:
	cmp	#$0014
	bcs	loc_1DC221
	lda	#$0002
	sta	$38,x
loc_1DC221:
	clc
	lda	a:$163C
	adc	$38,x
	sta	a:$163C
	lda	a:$163E
	cmp	#$FFE8
	bcc	loc_1DC23C
	sec
	lda	a:$163E
	sbc	#$0004
	sta	a:$163E
loc_1DC23C:
	rtl

sub_1DC23D:
	lda	a:$1642
	phx
	asl	a
	tax
	lda	f:tbl_1DC24D,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DC24D:
	.addr	sub_1DC259
	.addr	sub_1DC282
	.addr	sub_1DC29D
	.addr	sub_1DC28F
	.addr	sub_1DC259
	.addr	sub_1DC2AA

sub_1DC259:
	lda	$0E,x
	cmp	#$00BC
	bcc	loc_1DC281
	stz	$1E,x
	lda	#$0003
	sta	a:$1662
	inc	a:$1642
	lda	a:$1642
	cmp	#$0005
	beq	loc_1DC281
	lda	#$0050
	sta	$24,x
	lda	#$008C
	ldy	#$0340
	jsr	a:sub_1DCA52
loc_1DC281:
	rtl

sub_1DC282:
	dec	$24,x
	bpl	loc_1DC28E
	lda	#$FFFE
	sta	$1E,x
	inc	a:$1642
loc_1DC28E:
	rtl

sub_1DC28F:
	lda	a:$1644
	bpl	loc_1DC29C
	lda	#$0001
	sta	$1E,x
	inc	a:$1642
loc_1DC29C:
	rtl

sub_1DC29D:
	lda	$0E,x
	cmp	#$0070
	bcs	loc_1DC2A9
	stz	$1E,x
	inc	a:$1642
loc_1DC2A9:
	rtl

sub_1DC2AA:
	rtl

sub_1DC2AB:
	lda	a:$1642
	bne	loc_1DC2C0
	ldy	a:$0084
	lda	a:data_05FF61,y
	cmp	$0E,x
	bcc	loc_1DC2BF
	inc	a:$1642
	stz	$1E,x
loc_1DC2BF:
	rtl
loc_1DC2C0:
	lda	#$0001
	sta	a:$1660
	jsr	a:sub_1DCB7A
	lda	a:$1644
	bpl	loc_1DC2D1
	inc	$12,x
	rtl
loc_1DC2D1:
	lda	$C0
	bne	loc_1DC31A
	lda	$E8
	and	#$0001
	bne	loc_1DC2F0
	lda	#$008E
	phx
	jsr	a:sub_1DCA73
	bcs	loc_1DC31A
	lda	#$3400
	sta	$02,x
	txy
	jsr	a:sub_1DCC30
	plx
	rtl
loc_1DC2F0:
	ldy	#$0800
	jsl	f:sub_019EC1
	bcc	loc_1DC31A
	lda	#$000F
	sta	a:$0010,y
	lda	#$0001
	sta	a:$003E,y
	jsr	a:sub_1DCC30
	lda	$EA
	xba
	and	#$0007
	inc	a
	cmp	#$0006
	bcc	loc_1DC317
	lda	#$0007
loc_1DC317:
	sta	a:$003A,y
loc_1DC31A:
	rtl

sub_1DC31B:
	jsr	a:sub_1DCB7A
	lda	#$0038
	sta	$00
	lda	#$0040
	sta	$02
	jsr	a:sub_1DCBD1
	lda	a:$163C
	cmp	#$00F0
	bcs	loc_1DC34E
	lda	$78
	bit	#$007F
	bne	loc_1DC341
	lda	$36,x
	eor	#$0002
	sta	$36,x
loc_1DC341:
	lda	#$0004
	sta	$00
	lda	#$FFFC
	sta	$02
	jsr	a:sub_1DCB04
loc_1DC34E:
	lda	$BC
	bne	loc_1DC359
	dec	a:$163C
	bpl	loc_1DC359
	inc	$12,x
loc_1DC359:
	rtl

sub_1DC35A:
	jsr	a:sub_1DCB7A
	lda	#$0078
	sta	$00
	lda	#$0080
	sta	$02
	jsr	a:sub_1DCBD1
	lda	a:$1644
	bpl	loc_1DC371
	inc	$12,x
loc_1DC371:
	rtl

sub_1DC372:
	lda	a:$1642
	bne	loc_1DC39D
	clc
	lda	$1C,x
	adc	#$1480
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	$0E,x
	cmp	#$00C0
	bcc	loc_1DC39C
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#$0004
	sta	a:$1662
	inc	a:$1642
loc_1DC39C:
	rtl
loc_1DC39D:
	lda	#$0001
	sta	a:$1660
	lda	$78
	bit	#$007F
	bne	loc_1DC3F4
	lda	#$0091
	phx
	jsr	a:sub_1DCA73
	bcs	loc_1DC3F3
	lda	#$0001
	sta	$3A,x
	lda	#$0040
	sta	$38,x
	lda	#$0004
	sta	$24,x
	lda	#$00B0
	sta	$0E,x
	stx	$FC
	stz	$FE
	lda	$84
	lsr	a
	lsr	a
	sta	$FA
loc_1DC3D1:
	lda	#$0091
	jsr	a:sub_1DCA73
	bcs	loc_1DC3ED
	clc
	lda	$FE
	adc	#$001C
	sta	$FE
	lda	$FC
	sta	$38,x
	lda	$FE
	sta	$36,x
	dec	$FA
	bpl	loc_1DC3D1
loc_1DC3ED:
	ldx	$FC
	lda	$FE
	sta	$36,x
loc_1DC3F3:
	plx
loc_1DC3F4:
	lda	a:$1644
	bpl	loc_1DC3FB
	inc	$12,x
loc_1DC3FB:
	rtl

sub_1DC3FC:
	lda	a:$1644
	bpl	loc_1DC404
	inc	$12,x
	rtl
loc_1DC404:
	ldy	$38,x
	lda	#$0001
	sta	a:$1660
	lda	a:$1642
	phx
	asl	a
	tax
	lda	f:tbl_1DC41C,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DC41C:
	.addr	sub_1DC42E
	.addr	sub_1DC44C
	.addr	sub_1DC498
	.addr	sub_1DC492
	.addr	sub_1DC4F9
	.addr	sub_1DC487
	.addr	sub_1DC481
	.addr	sub_1DC4F9
	.addr	sub_1DC44C

sub_1DC42E:
	lda	$0E,x
	cmp	#$007C
	bcs	loc_1DC437
	inc	$0E,x
loc_1DC437:
	inc	a:$163C
	lda	a:$163C
	cmp	#$0014
	bcc	loc_1DC44B
	inc	a:$1642
	lda	#$0004
	sta	a:$1662
loc_1DC44B:
	rtl

sub_1DC44C:
	lda	$0A,x
	cmp	#$0040
	bcs	loc_1DC458
	lda	#$0000
	bra	loc_1DC467
loc_1DC458:
	cmp	#$0090
	bcc	loc_1DC462
	lda	#$0002
	bra	loc_1DC467
loc_1DC462:
	lda	$E8
	and	#$0002
loc_1DC467:
	sta	$38,x
	tay
	lda	a:data_05FF87,y
	tay
	lda	a:$000A,y
	sta	a:$0036,y
	lda	a:$000E,y
	sta	a:$0038,y
	lda	#$0002
	sta	a:$1642
	rtl

sub_1DC481:
	tya
	clc
	adc	#$0004
	tay

sub_1DC487:
	lda	$3E,x
	cmp	#$00D0
	bcs	loc_1DC490
	inc	$3E,x
loc_1DC490:
	bra	loc_1DC4A1

sub_1DC492:
	tya
	clc
	adc	#$0004
	tay

sub_1DC498:
	lda	$3E,x
	cmp	#$00C0
	bcc	loc_1DC4A1
	dec	$3E,x
loc_1DC4A1:
	clc
	lda	a:$163E
	adc	a:data_05FF93,y
	sta	a:$163E
	sta	a:$163A
	cmp	a:data_05FF8B,y
	bne	loc_1DC4DA
	inc	a:$1642
	lda	a:$1642
	cmp	#$0004
	beq	loc_1DC4C3
	cmp	#$0007
	bne	loc_1DC4DA
loc_1DC4C3:
	lda	$E8
	and	#$000F
	adc	#$0004
	sta	$24,x
	lda	#$0004
	sta	a:$1662
	lda	#$0039
	jsl	f:sub_00868F
loc_1DC4DA:
	ldy	$38,x
	lda	a:data_05FF87,y
	tay
	sec
	lda	a:$0036,y
	sbc	a:$000A,y
	clc
	adc	$0A,x
	sta	$0A,x
	sec
	lda	a:$0038,y
	sbc	a:$000E,y
	clc
	adc	$0E,x
	sta	$0E,x
	rtl

sub_1DC4F9:
	dec	$24,x
	lda	$24,x
	bpl	loc_1DC51A
	lda	$38,x
	eor	#$0002
	sta	$38,x
	tay
	lda	a:data_05FF87,y
	tay
	lda	a:$000A,y
	sta	a:$0036,y
	lda	#$00B0
	sta	a:$0038,y
	inc	a:$1642
loc_1DC51A:
	rtl

sub_1DC51B:
	lda	$78
	bit	#$003F
	bne	loc_1DC544
	lda	#$0093
	phx
	jsr	a:sub_1DCA73
	bcs	loc_1DC544
	lda	#$0003
	ldy	$E8
	bpl	loc_1DC535
	lda	#$FFFD
loc_1DC535:
	sta	$1E,x
	lda	#$0001
	ldy	$EA
	bpl	loc_1DC541
	lda	#$FFFF
loc_1DC541:
	sta	$1A,x
	plx
loc_1DC544:
	lda	#$0060
	sta	$00
	lda	#$0080
	sta	$02
	jsr	a:sub_1DCBD1
	lda	a:$1644
	bpl	loc_1DC558
	inc	$12,x
loc_1DC558:
	rtl

sub_1DC559:
	lda	#$008B
	ldy	#$0700
	jsr	a:sub_1DCA52
	lda	#$0001
	sta	$38,x
	stz	$36,x
	stz	$32,x
	stz	$34,x
	lda	#$0001
	sta	a:$163C
	lda	#$FFFC
	sta	a:$163E
	rtl

sub_1DC57A:
	lda	#$0001
	sta	$1E,x
	rtl

sub_1DC580:
	lda	#$FFFF
	sta	$1E,x
	rtl

sub_1DC586:
	lda	#$0002
	jsl	f:sub_01A15D
	sty	a:$163E
	lda	#$008F
	ldy	#$0500
	jsr	a:sub_1DCA52
	lda	#$0001
	sta	$38,x
	stz	$36,x
	lda	#$0120
	sta	a:$163C
	rtl

sub_1DC5A7:
	lda	#$0090
	phx
	jsr	a:sub_1DCA73
	lda	#$3400
	sta	$02,x
	stz	$16,x
	plx
	rtl

sub_1DC5B7:
	stz	$24,x
	clc
	lda	a:$1644
	adc	#$0100
	sta	a:$1644
	lda	#$0002
	sta	$1A,x
	rtl

sub_1DC5C9:
	lda	#$0092
	ldy	#$0580
	jsr	a:sub_1DCA52
	lda	#$8000
	sta	a:$033A
	sta	a:$047A
	lda	#$0001
	sta	a:$043A
	sta	a:$057A
	lda	#$0080
	sta	a:$163A
	sta	a:$163E
	lda	#$00D0
	sta	$3E,x
	stz	a:$163C
	lda	a:$1644
	adc	#$0060
	sta	a:$1644
	rtl

sub_1DC5FF:
	lda	$84
	cmp	#$0004
	bne	loc_1DC60C
	lda	#$0300
	sta	a:$1644
loc_1DC60C:
	rtl

sub_1DC60D:
	lda	a:$163E
	cmp	#$0002
	beq	loc_1DC62E
	lda	a:$163C
	cmp	#$0030
	bcc	loc_1DC62C
	lda	$14,x
	beq	loc_1DC629
	lda	#$0001
	sta	a:$163E
	sta	$06,x
loc_1DC629:
	lda	a:$163C
loc_1DC62C:
	bra	loc_1DC687
loc_1DC62E:
	lda	$16,x
	cmp	#$0030
	bne	loc_1DC65C
	dec	$30,x
	bpl	loc_1DC63F
	lda	#$8000
	sta	$16,x
	rtl
loc_1DC63F:
	lda	$78
	bit	#$0004
	bne	loc_1DC64B
	lda	$3A,x
	sta	$00,x
	rtl
loc_1DC64B:
	stz	$00,x
	rtl

sub_1DC64E:
	lda	a:$1688
	bne	loc_1DC65C
	lda	a:$1644
	bmi	loc_1DC65C
	lda	$06,x
	bpl	loc_1DC674
loc_1DC65C:
	lda	#$0004
	sta	a:$1662
	jsr	a:sub_1DCAC9
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$C4CE
	txy
	jml	f:sub_01CF66
loc_1DC674:
	lda	a:$163C
	cpx	#$0500
	bcc	loc_1DC687
	clc
	adc	a:$163E
	eor	#$FFFF
	clc
	adc	#$0020
loc_1DC687:
	pha
	jsr	a:sub_1DCAE9
	ply
	jsl	f:sub_1DACA4
	clc
	lda	a:$090A
	adc	#$001C
	adc	$08
	sta	$0A,x
	clc
	lda	a:$090E
	adc	#$FFE4
	adc	$0A
	sta	$0E,x
	rtl

sub_1DC6A7:
	lda	a:$1688
	beq	loc_1DC6AF
	brl	loc_1DC7C9
loc_1DC6AF:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_1DC6BE,x
	plx
	sta	$00
	jmp	($0000)
tbl_1DC6BE:
	.addr	sub_1DC6C6
	.addr	sub_1DC73F
	.addr	sub_1DC703
	.addr	sub_1DC7C2

sub_1DC6C6:
	inc	$12,x
	lda	#$0090
	sta	$0E,x
	lda	#$003E
	sta	$32,x
	lda	#$0000
	sta	$34,x
	stz	$36,x
	lda	#$C569
	sta	$08
	lda	#$3E00
	sta	$0A
	lda	#$0008
	sta	$0C
	lda	#$FFF8
	sta	$0E
	lda	#$403C
	sta	$10
	stz	$00
	lda	#$000A
	sta	$04
	lda	#$000C
	ldy	#$0340
	jml	f:loc_01A41C

sub_1DC703:
	clc
	lda	a:$090A
	adc	#$001C
	sec
	sbc	$0A,x
	bpl	loc_1DC712
	eor	#$FFFF
loc_1DC712:
	cmp	#$0004
	bcs	loc_1DC749
	stz	$18,x
	stz	$1A,x
	clc
	lda	a:$090E
	adc	#$FFE4
	sec
	sbc	$0E,x
	bpl	loc_1DC72A
	eor	#$FFFF
loc_1DC72A:
	cmp	#$0004
	bcs	loc_1DC749
	inc	$12,x
	lda	#$0070
	sta	$24,x
	lda	#$0180
	sta	$0A,x
	jml	f:sub_01A513

sub_1DC73F:
	lda	a:$1642
	cmp	#$0005
	bne	loc_1DC749
	inc	$12,x
loc_1DC749:
	lda	#$0001
	sta	a:$1660
	lda	$0A,x
	bmi	loc_1DC761
	cmp	#$0020
	bcc	loc_1DC761
	cmp	#$00E0
	bcc	loc_1DC765
	stz	$36,x
	bra	loc_1DC765
loc_1DC761:
	inc	$36,x
	inc	$36,x
loc_1DC765:
	lda	$36,x
	bne	loc_1DC783
	lda	$1A,x
	bpl	loc_1DC772
	cmp	#$FFFC
	bcc	loc_1DC79B
loc_1DC772:
	sec
	lda	$18,x
	sbc	#$3000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	loc_1DC79B
loc_1DC783:
	lda	$1A,x
	bmi	loc_1DC78C
	cmp	#$0004
	bcs	loc_1DC79B
loc_1DC78C:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
loc_1DC79B:
	lda	$34,x
	inc	a
	inc	a
	and	#$003E
	sta	$34,x
	tay
	lda	a:data_05941A,y
	asl	a
	sta	$00
	lda	a:data_0593CA,y
	rol	a
	sta	$02
	clc
	lda	$0C,x
	adc	$00
	sta	$0C,x
	lda	$0E,x
	adc	$02
	sta	$0E,x
	jml	f:sub_01A513

sub_1DC7C2:
	dec	$24,x
	bpl	loc_1DC7D2
	inc	a:$0912
loc_1DC7C9:
	lda	#$8000
	sta	$16,x
	jml	f:sub_01A52C
loc_1DC7D2:
	jml	f:sub_01A513

sub_1DC7D6:
	lda	$0E,x
	cmp	#$00B4
	bcc	loc_1DC7F1
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$FFFC
	sta	$1E,x
	txy
	lda	#$C516
	jml	f:sub_01CF66
loc_1DC7F1:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_1DC801:
	lda	a:$1688
	bne	loc_1DC835
	lda	a:$163C
	cmp	#$00F0
	bcc	loc_1DC822
	bne	loc_1DC817
	lda	#$001C
	sta	$16,x
	bra	loc_1DC81B
loc_1DC817:
	lda	$BC
	beq	loc_1DC81E
loc_1DC81B:
	lda	#$C536
loc_1DC81E:
	sta	$00,x
	bra	loc_1DC847
loc_1DC822:
	cmp	#$0002
	bcc	loc_1DC835
	ldy	a:$163E
	lda	a:$0016,y
	beq	loc_1DC835
	bmi	loc_1DC835
	lda	$06,x
	bpl	loc_1DC847
loc_1DC835:
	jsr	a:sub_1DCAC9
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$C4CE
	txy
	jml	f:sub_01CF66
loc_1DC847:
	jsr	a:sub_1DCAE9
	ldy	a:$163C
	cpy	#$0040
	bcc	loc_1DC855
	ldy	#$0040
loc_1DC855:
	jsl	f:sub_1DACA4
	ldy	a:$163E
	clc
	lda	a:$1312,y
	adc	$08
	sta	$0A,x
	clc
	lda	a:$1314,y
	adc	$0A
	sta	$0E,x
	rtl

sub_1DC86D:
	lda	$06,x
	bmi	loc_1DC87B
	lda	a:$1688
	bne	loc_1DC87B
	lda	a:$1644
	bpl	loc_1DC88A
loc_1DC87B:
	lda	#$0030
	jsl	f:sub_00868F
	txy
	lda	#$C516
	jml	f:sub_01CF66
loc_1DC88A:
	lda	$12,x
	bne	loc_1DC8DE
	clc
	lda	a:$090A
	adc	#$001C
	sta	$0A,x
	sta	$FC
	clc
	lda	a:$090E
	adc	#$FFE0
	sta	$0E,x
	sta	$FE
	phx
	lda	$78
	bit	#$001F
	bne	loc_1DC8DC
	lda	#$0090
	jsr	a:sub_1DCA73
	bcs	loc_1DC8DC
	inc	$12,x
	lda	$FC
	sta	$0A,x
	lda	$FE
	sta	$0E,x
	stz	$30,x
	lda	$84
	lsr	a
	sta	$06,x
	clc
	lda	$E8
	and	#$0001
	adc	#$0001
	bit	#$0001
	bne	loc_1DC8D7
	eor	#$FFFF
	inc	a
loc_1DC8D7:
	sta	$1A,x
	jsr	a:sub_1DCCD4
loc_1DC8DC:
	plx
	rtl
loc_1DC8DE:
	lda	$1E,x
	bmi	loc_1DC902
	lda	$0E,x
	bmi	loc_1DC902
	cmp	#$00B0
	bcc	loc_1DC902
	jsr	a:sub_1DCCD4
	lda	$30,x
	bne	loc_1DC902
	lda	$1A,x
	eor	#$FFFF
	inc	a
	sta	$1A,x
	inc	$30,x
	lda	#$0002
	sta	a:$1662
loc_1DC902:
	clc
	lda	$1C,x
	adc	#$3C00
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_1DC912:
	lda	a:$1688
	bne	loc_1DC91C
	lda	a:$1644
	bpl	loc_1DC924
loc_1DC91C:
	txy
	lda	#$C672
	jml	f:sub_01CF66
loc_1DC924:
	lda	$3A,x
	beq	loc_1DC960
	lda	$0A,x
	bpl	loc_1DC931
	cmp	#$FF80
	bcc	loc_1DC91C
loc_1DC931:
	lda	$38,x
	cmp	#$FFC0
	bne	loc_1DC957
	dec	$24,x
	bpl	loc_1DC956
	lda	#$0040
	sta	$38,x
	sec
	lda	$0A,x
	sbc	$36,x
	inc	a
	sta	$0A,x
	lda	a:$0084
	lsr	a
	and	#$0002
	tay
	lda	a:data_05FF23,y
	sta	$24,x
loc_1DC956:
	rtl
loc_1DC957:
	sec
	lda	$38,x
	sbc	#$0004
	sta	$38,x
	rtl
loc_1DC960:
	ldy	$38,x
	lda	a:$0016,y
	beq	loc_1DC91C
	lda	a:$0038,y
	ldy	$36,x
	jsl	f:sub_1DACA4
	ldy	$38,x
	clc
	lda	a:$000A,y
	adc	$08
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	$0A
	sta	$0E,x
	rtl

sub_1DC983:
	lda	a:$1688
	bne	loc_1DC98D
	lda	a:$1644
	bpl	loc_1DC995
loc_1DC98D:
	txy
	lda	#$C4CE
	jml	f:sub_01CF66
loc_1DC995:
	lda	a:$163A
	ldy	$3A,x
	bmi	loc_1DC9CA
	cpx	#$0440
	bcs	loc_1DC9A5
	clc
	adc	#$FFE0
loc_1DC9A5:
	clc
	adc	#$0010
	sta	a:$163A
	ldy	a:$163C
	jsl	f:sub_1DACA4
	txa
	clc
	adc	#$FFC0
	tay
	clc
	lda	a:$000A,y
	adc	$08
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	$0A
	sta	$0E,x
	rtl
loc_1DC9CA:
	lda	a:$163E
	cpx	#$0440
	bcc	loc_1DC9D8
	clc
	adc	a:$093E
	bra	loc_1DC9DC
loc_1DC9D8:
	sec
	sbc	a:$093E
loc_1DC9DC:
	and	#$00FF
	sta	a:$163A
	ldy	#$0014
	jsl	f:sub_1DACA4
	clc
	lda	a:$090A
	adc	#$001C
	adc	$08
	sta	$0A,x
	clc
	lda	a:$090E
	adc	#$FFE8
	adc	$0A
	sta	$0E,x
	rtl

sub_1DCA00:
	lda	a:$1644
	bmi	loc_1DCA0A
	lda	a:$1688
	beq	loc_1DCA19
loc_1DCA0A:
	lda	#$0030
	jsl	f:sub_00868F
	txy
	lda	#$C4CE
	jml	f:sub_01CF66
loc_1DCA19:
	lda	$0E,x
	ldy	$1E,x
	bmi	loc_1DCA26
	cmp	#$00B8
	bcc	loc_1DCA38
	bra	loc_1DCA2B
loc_1DCA26:
	cmp	#$0020
	bcs	loc_1DCA38
loc_1DCA2B:
	tya
	eor	#$FFFF
	inc	a
	sta	$1E,x
	lda	#$0002
	sta	a:$1662
loc_1DCA38:
	lda	$0A,x
	ldy	$1A,x
	bmi	loc_1DCA45
	cmp	#$00F0
	bcc	loc_1DCA51
	bra	loc_1DCA4A
loc_1DCA45:
	cmp	#$0008
	bcs	loc_1DCA51
loc_1DCA4A:
	tya
	eor	#$FFFF
	inc	a
	sta	$1A,x
loc_1DCA51:
	rtl

sub_1DCA52:
	sta	$02
	sty	$04
	phx
	stz	$00
	ldx	#$0300
loc_1DCA5C:
	jsr	a:sub_1DCA7D
	lda	$00
	sta	$24,x
	inc	$00
	inc	$00
	clc
	txa
	adc	#$0040
	tax
	cmp	$04
	bcc	loc_1DCA5C
	plx
	rts

sub_1DCA73:
	pha
	jsl	f:sub_019E83
	pla
	bcs	loc_1DCAC8
	bra	loc_1DCA7F

sub_1DCA7D:
	lda	$02
loc_1DCA7F:
	sta	$10,x
	stz	$12,x
	stz	$20,x
	stz	$22,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	clc
	lda	$84
	adc	#$000A
	sta	$06,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	clc
	lda	a:$090A
	adc	#$001C
	sta	$0A,x
	clc
	lda	a:$090E
	adc	#$FFE4
	sta	$0E,x
	lda	a:$1636
	asl	a
	tay
	lda	a:data_05FF3E,y
	sta	$16,x
	lda	a:data_05FF67,y
	sta	$00,x
	lda	a:data_05FF77,y
	sta	$02,x
	clc
loc_1DCAC8:
	rts

sub_1DCAC9:
	jsr	a:sub_1DCAE9
	jsr	a:sub_1DCAE9
	lsr	a
	and	#$007E
	tay
	lda	a:data_058D5A,y
	sta	$1E,x
	lda	a:data_058D7A,y
	sta	$1A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058E1A,y
	sta	$18,x
	rts

sub_1DCAE9:
	lda	$24,x
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$0020
	clc
	adc	a:$163A
	cpx	#$0500
	bcc	loc_1DCB00
	clc
	adc	#$0010
loc_1DCB00:
	and	#$00FF
	rts

sub_1DCB04:
	lda	$36,x
	bne	loc_1DCB21
	lda	$34,x
	bmi	loc_1DCB10
	cmp	$00
	bcs	loc_1DCB38
loc_1DCB10:
	clc
	lda	$32,x
	adc	#$1000
	sta	$32,x
	lda	$34,x
	adc	#$0000
	sta	$34,x
	bra	loc_1DCB38
loc_1DCB21:
	lda	$34,x
	bpl	loc_1DCB29
	cmp	$02
	bcc	loc_1DCB38
loc_1DCB29:
	sec
	lda	$32,x
	sbc	#$1000
	sta	$32,x
	lda	$34,x
	sbc	#$0000
	sta	$34,x
loc_1DCB38:
	clc
	lda	$32,x
	adc	$30,x
	sta	$30,x
	lda	$34,x
	adc	a:$163A
	sta	a:$163A
	rts

sub_1DCB48:
	lda	$36,x
	ldy	$34,x
	beq	loc_1DCB56
	inc	a
	cmp	#$014B
	bcc	loc_1DCB64
	bra	loc_1DCB5C
loc_1DCB56:
	dec	a
	cmp	#$0120
	bcs	loc_1DCB64
loc_1DCB5C:
	pha
	tya
	eor	#$0001
	sta	$34,x
	pla
loc_1DCB64:
	sta	$36,x

sub_1DCB66:
	sec
	lda	a:$13D8
	sta	$00
	and	#$01FE
	sbc	#$00A0
	tay
	lda	$36,x
	jsl	f:sub_00E76C
	rts

sub_1DCB7A:
	lda	$0A,x
	bmi	loc_1DCB8C
	cmp	#$0040
	bcc	loc_1DCB8C
	cmp	#$0088
	bcc	loc_1DCB91
	stz	$38,x
	bra	loc_1DCB91
loc_1DCB8C:
	lda	#$0001
	sta	$38,x
loc_1DCB91:
	lda	$38,x
	bne	loc_1DCBAE
	lda	$1A,x
	bpl	loc_1DCB9E
	cmp	#$FFFF
	bcc	loc_1DCBC6
loc_1DCB9E:
	sec
	lda	$18,x
	sbc	#$1000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rts
loc_1DCBAE:
	lda	$1A,x
	bmi	loc_1DCBB7
	cmp	#$0001
	bcs	loc_1DCBC6
loc_1DCBB7:
	clc
	lda	$18,x
	adc	#$1000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
loc_1DCBC6:
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_1DCBC7:
	; (not executed in the CDL traces)
	lda	#$0040
	sta	$00
	lda	#$0080
	sta	$02

sub_1DCBD1:
	lda	$0E,x
	bmi	loc_1DCBE1
	cmp	$00
	bcc	loc_1DCBE1
	cmp	$02
	bcc	loc_1DCBE6
	stz	$3E,x
	bra	loc_1DCBE6
loc_1DCBE1:
	lda	#$0001
	sta	$3E,x
loc_1DCBE6:
	lda	$3E,x
	bne	loc_1DCC03
	lda	$1E,x
	bpl	loc_1DCBF3
	cmp	#$FFFF
	bcc	loc_1DCC1B
loc_1DCBF3:
	sec
	lda	$1C,x
	sbc	#$1800
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rts
loc_1DCC03:
	lda	$1E,x
	bmi	loc_1DCC0C
	cmp	#$0001
	bcs	loc_1DCC1B
loc_1DCC0C:
	clc
	lda	$1C,x
	adc	#$1800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_1DCC1B:
	rts

sub_1DCC1C:
	lda	#$0002
	sta	$02
	lda	#$0010
	sta	$08
	lda	#$4C0C
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_1DCC30:
	clc
	lda	a:$090A
	adc	#$001C
	sta	a:$000A,y
	lda	a:$090E
	sta	a:$000E,y
	lda	$E8
	and	#$0003
	clc
	adc	#$FFFE
	sta	a:$001A,y
	lda	$EA
	sta	a:$0018,y
	lda	#$FFFE
	sta	a:$001E,y
	rts

sub_1DCC58:
	phx
	lda	$84
	bne	loc_1DCC65
	; (not executed in the CDL traces)
	ldx	#$0400
	lda	#$0000
	bra	loc_1DCC6D
loc_1DCC65:
	ldx	#$0300
	lda	$E8
	and	#$000E
loc_1DCC6D:
	sta	$00
loc_1DCC6F:
	lda	#$0094
	sta	$10,x
	lda	#$4031
	sta	$16,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$0058
	sta	$30,x
	stz	$06,x
	lda	$00
	and	#$000E
	tay
	lda	a:data_05FF67,y
	sta	$00,x
	sta	$3A,x
	lda	a:data_05FF77,y
	sta	$02,x
	sty	$24,x
	inc	$00
	inc	$00
	lda	$84
	bne	loc_1DCCAA
	; (not executed in the CDL traces)
	inc	$00
	inc	$00
loc_1DCCAA:
	lda	$00
	cmp	#$0010
	bcc	loc_1DCCB3
	stz	$00
loc_1DCCB3:
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0500
	bcc	loc_1DCC6F
	plx
	rts

sub_1DCCC0:
	lda	$E8
	and	#$0003
	clc
	adc	#$0005
	bit	#$0004
	bne	loc_1DCCD1
	eor	#$FFFF
loc_1DCCD1:
	sta	$3E,x
	rts

sub_1DCCD4:
	clc
	lda	$EA
	and	#$0001
	adc	#$FFF9
	sta	$1E,x
	rts
