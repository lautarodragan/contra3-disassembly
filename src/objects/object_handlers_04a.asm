; objects/object_handlers_04a.asm -- Object handlers (bank $04, part 1)
; Bank $04, $04:8000-$04:D877. Included by main.asm in segment BANK04.
;
; Handlers of object types dispatched through tbl_05A48A and their helpers.

sub_048000:
	.a16
	.i16
	lda	$12,x
	cmp	#$000D
	bcc	loc_04802A
	lda	#$0001
	sta	a:$1660
	ldy	#$0050
	jsl	f:sub_019E6E
	lda	$78
	and	#$000C
	lsr	a
	lsr	a
	bit	#$0002
	beq	loc_048023
	eor	#$FFFF
loc_048023:
	clc
	adc	#$0100
	sta	a:$13D8
loc_04802A:
	inc	a:$1636
	jsr	a:sub_048605
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04803F,x
	plx
	sta	$00
	jmp	($0000)
tbl_04803F:
	.addr	sub_04809D
	.addr	sub_0480CB
	.addr	sub_0480E2
	.addr	sub_04823D
	.addr	sub_04824E
	.addr	sub_048274
	.addr	sub_0481E9
	.addr	sub_04832A
	.addr	sub_048382
	.addr	sub_04842E
	.addr	sub_04867C
	.addr	sub_04869A
	.addr	sub_0486F1
	.addr	sub_04873D
	.addr	sub_04880B
	.addr	sub_048837
	.addr	sub_04880B
	.addr	sub_04885B
	.addr	sub_048893
	.addr	sub_04880B
	.addr	sub_0488BA
	.addr	sub_048907
	.addr	sub_0487DB
	.addr	sub_048766
	.addr	sub_04877D
	.addr	sub_0487A4
	.addr	sub_0487AE

sub_048075:
	jsr	a:sub_048605
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_048087,x
	plx
	sta	$00
	jmp	($0000)
tbl_048087:
	.addr	sub_04809D
	.addr	sub_0480CB
	.addr	sub_048186
	.addr	sub_04823D
	.addr	sub_04824E
	.addr	sub_048274
	.addr	sub_048224
	.addr	sub_04832A
	.addr	sub_048382
	.addr	sub_04842E
	.addr	sub_04843C

sub_04809D:
	inc	$12,x
	ldy	$3A,x
	lda	a:data_05E819,y
	sta	$02,x
	lda	#$403D
	sta	$16,x
	lda	a:data_05E815,y
	sta	$00,x
	lda	#$001A
	sta	$28,x
	lda	#$FFB8
	sta	$2A,x
	lda	#$0140
	sta	$06,x
	stz	$38,x
	phx
	ldy	#$E7E2
	jsl	f:sub_009982
	plx
	rtl

sub_0480CB:
	lda	a:$13BA
	cmp	#$0004
	bne	loc_0480E1
	inc	$12,x
	stz	$24,x
	lda	#$0002
	sta	$04,x
	lda	#$401D
	sta	$16,x
loc_0480E1:
	rtl

sub_0480E2:
	dec	$24,x
	bpl	loc_0480E1
	ldy	$84
	lda	a:data_05E809,y
	sta	$24,x
	jsr	a:sub_048545
	ldy	$00
	lda	$0E,x
	cmp	#$00CF
	bcs	loc_048120
	lda	$0A,x
	cmp	#$0070
	bcc	loc_04810C
	lda	#$0002
	sta	$04,x
	lda	#$FFFF
	sta	$1A,x
	bra	loc_048113
loc_04810C:
	; (not executed in the CDL traces)
	stz	$04,x
	lda	#$0001
	sta	$1A,x
loc_048113:
	lda	#$0004
	sta	$12,x
	lda	#$E83B
	sta	$20,x
	stz	$22,x
	rtl
loc_048120:
	lda	$06
	cmp	#$0070
	bcc	loc_04814B
	lda	$04
	cmp	#$0030
	bcs	loc_04814B
	lda	$00
	sta	$04,x
	lda	#$0004
	sta	$36,x
	lda	#$FFF8
	sta	$32,x
	stz	$34,x
loc_04813E:
	lda	#$0003
	sta	$12,x
	lda	#$E81D
	sta	$20,x
	stz	$22,x
	rtl
loc_04814B:
	lda	$0A,x
	cmp	#$0031
	bcc	loc_048157
	cmp	#$00AF
	bcc	loc_04816E
loc_048157:
	lda	a:data_05E85D,y
	sta	$04,x
	lda	a:data_05E859,y
	sta	$34,x
	lda	#$0005
	sta	$36,x
	lda	#$FFFB
	sta	$32,x
	brl	loc_04813E
loc_04816E:
	lda	a:data_05E85D,y
	sta	$04,x
	lda	a:data_05E855,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFB
	sta	$32,x
	brl	loc_04813E
loc_048185:
	rtl

sub_048186:
	dec	$24,x
	bpl	loc_048185
	ldy	$84
	lda	a:data_05E80F,y
	sta	$24,x
	jsr	a:sub_048545
	lda	$0E,x
	cmp	#$00CF
	bcs	loc_0481A8
	lda	#$0004
	sta	$12,x
	lda	#$E83B
	sta	$20,x
	stz	$22,x
	rtl
loc_0481A8:
	lda	$04
	cmp	#$0050
	bcs	loc_0481C5
	lda	$00
	sta	$04,x
	lda	#$0006
	sta	$12,x
	lda	#$E847
	sta	$20,x
	stz	$22,x
	lda	#$00C0
	sta	$3E,x
	rtl
loc_0481C5:
	ldy	#$0000
	lda	$0A,x
	cmp	#$0070
	bcc	loc_0481D2
	ldy	#$0002
loc_0481D2:
	lda	a:data_05E85D,y
	sta	$04,x
	lda	a:data_05E855,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFD
	sta	$32,x
	brl	loc_04813E

sub_0481E9:
	lda	$06,x
	bmi	loc_048216
	dec	$3E,x
	bpl	loc_04821C
	ldy	$04,x
	lda	$0A,x
	adc	a:data_05E8B3,y
	sta	$00
	lda	$0E,x
	adc	#$FFBE
	sta	$02
	lda	a:data_05E8A7,y
	jsl	f:sub_01A11C
	lda	a:data_05E8AB,y
	jsl	f:sub_01A11C
	lda	a:data_05E8AF,y
	jsl	f:sub_01A11C
loc_048216:
	lda	#$0002
	sta	$12,x
	rtl
loc_04821C:
	jsr	a:sub_048545
	lda	$00
	sta	$04,x
	rtl

sub_048224:
	lda	$06,x
	bmi	loc_04822C
	dec	$3E,x
	bpl	loc_048239
loc_04822C:
	lda	#$0002
	sta	$12,x
	lda	#$E829
	sta	$20,x
	stz	$22,x
	rtl
loc_048239:
	jsr	a:sub_048589
	rtl

sub_04823D:
	lda	$20,x
	bne	loc_04824D
	lda	$36,x
	sta	$12,x
	lda	$32,x
	sta	$1E,x
	lda	$34,x
	sta	$1A,x
loc_04824D:
	rtl

sub_04824E:
	lda	$0A,x
	cmp	#$0030
	bcc	loc_048265
	cmp	#$00B0
	bcc	loc_048299
	lda	$1A,x
	bmi	loc_048299
	lda	#$00B0
	sta	$0A,x
	bpl	loc_04826E
loc_048265:
	lda	$1A,x
	bpl	loc_048299
	lda	#$0030
	sta	$0A,x
loc_04826E:
	stz	$18,x
	stz	$1A,x
	bra	loc_048299

sub_048274:
	lda	$0A,x
	cmp	#$0010
	bcc	loc_048284
	cmp	#$00D0
	bcc	loc_048299
	stz	$04,x
	bra	loc_048289
loc_048284:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$04,x
loc_048289:
	lda	#$0033
	jsl	f:sub_00868F
	lda	#$E841
	sta	$20,x
	stz	$22,x
	bra	loc_048306
loc_048299:
	lda	$1E,x
	bpl	loc_0482CA
	lda	$0E,x
	cmp	#$0090
	bcs	loc_04831A
	lda	#$0033
	jsl	f:sub_00868F
	lda	#$0090
	sta	$0E,x
	lda	#$E835
	sta	$20,x
	stz	$22,x
	lda	#$0006
	sta	$12,x
	lda	#$0080
	sta	$3E,x
	lda	#$E88B
	sta	$20,x
	stz	$22,x
	bra	loc_04830B
loc_0482CA:
	lda	$0E,x
	cmp	#$00D0
	bcc	loc_04831A
	lda	#$0032
	jsl	f:sub_00868F
	lda	#$00D0
	sta	$0E,x
	lda	#$E829
	sta	$20,x
	stz	$22,x
	sec
	lda	$0A,x
	sbc	#$0030
	cmp	#$0008
	bcs	loc_0482F6
	lda	#$0030
	sta	$0A,x
	bra	loc_048306
loc_0482F6:
	sec
	lda	#$00B0
	sbc	$0A,x
	cmp	#$0008
	bcs	loc_048306
	lda	#$00B0
	sta	$0A,x
loc_048306:
	lda	#$0002
	sta	$12,x
loc_04830B:
	stz	$1C,x
	stz	$1E,x
	stz	$18,x
	stz	$1A,x
	lda	#$0003
	sta	a:$1662
	rtl
loc_04831A:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_04832A:
	dec	$24,x
	bpl	loc_04834A
	inc	$12,x
	lda	#$0C00
	sta	$24,x
	lda	#$E871
	sta	$20,x
	lda	#$001D
	sta	$16,x
	lda	#$FFE2
	sta	$2A,x
	lda	#$FFFD
	sta	$1E,x
	rtl
loc_04834A:
	jsr	a:sub_048669
	jsl	f:sub_00FD97
	lda	$BC
	bne	loc_048381
	lda	$0A,x
	sta	$00
	lda	$0E,x
	adc	#$000C
	sta	$02
	lda	#$000F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0300
	lda	#$C5B8
	jsl	f:sub_01CF3C
	bcs	loc_048381
	lda	$E8
	and	#$0001
	adc	#$FFFE
	sta	a:$001E,y
loc_048381:
	rtl

sub_048382:
	lda	$C0
	bne	loc_048396
	lda	$EA
	adc	$0A,x
	bit	#$0001
	bne	loc_048396
	lda	$04,x
	eor	#$0002
	sta	$04,x
loc_048396:
	lda	$0A,x
	cmp	#$0010
	bcs	loc_0483A6
	stz	$04,x
	lda	#$0003
	sta	$1A,x
	bra	loc_0483B5
loc_0483A6:
	cmp	#$00D8
	bcc	loc_0483B5
	lda	#$0002
	sta	$04,x
	lda	#$FFFD
	sta	$1A,x
loc_0483B5:
	lda	$04,x
	beq	loc_0483D3
	lda	$1A,x
	bpl	loc_0483C2
	cmp	#$FFFD
	bcc	loc_0483EB
loc_0483C2:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	loc_0483EB
loc_0483D3:
	lda	$1A,x
	bmi	loc_0483DC
	cmp	#$0003
	bcs	loc_0483EB
loc_0483DC:
	clc
	lda	$18,x
	adc	#$2000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
loc_0483EB:
	lda	$1E,x
	bmi	loc_0483F7
	jsl	f:sub_01A177
	lda	$FC
	bne	loc_048411
loc_0483F7:
	lda	$1E,x
	bmi	loc_048400
	cmp	#$0005
	bcs	loc_04842D
loc_048400:
	clc
	lda	$1C,x
	adc	#$5000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	loc_04842D
loc_048411:
	lda	$E8
	adc	$0A,x
	and	#$000F
	bne	loc_04842D
	lda	#$E86B
	sta	$20,x
	stz	$22,x
	lda	#$FFF9
	sta	$1E,x
	lda	#$0034
	jsl	f:sub_00868F
loc_04842D:
	rtl

sub_04842E:
	dec	$24,x
	bpl	loc_048439
	inc	$12,x
	lda	#$0080
	sta	$24,x
loc_048439:
	brl	loc_04834A

sub_04843C:
	lda	#$8000
	sta	$16,x
	rtl

sub_048442:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_048451,x
	plx
	sta	$00
	jmp	($0000)
tbl_048451:
	.addr	sub_04845B
	.addr	sub_04846D
	.addr	sub_048482
	.addr	sub_0484E6
	.addr	sub_0484F7

sub_04845B:
	inc	$12,x
	lda	#$0001
	sta	$16,x
	lda	#$3400
	sta	$02,x
	lda	#$BE1D
	sta	$00,x
	rtl

sub_04846D:
	lda	a:$0912
	cmp	#$0003
	bcc	loc_048481
	lda	#$0018
	sta	$24,x
	lda	#$E7C8
	sta	$30,x
	inc	$12,x
loc_048481:
	rtl

sub_048482:
	dec	$24,x
	bpl	loc_0484B8
	lda	#$E7EB
	sta	$20,x
	inc	$12,x
	ldy	#$0200
	jsr	a:sub_04852F
	ldy	#$0240
	jsr	a:sub_04852F
	lda	#$0040
	sta	$04
	lda	#$2002
	sta	$02
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	asl	a
	clc
	adc	#$4402
	tay
	lda	#$000A
	jml	f:sub_00CFAF
loc_0484B8:
	lda	$24,x
	bit	#$0007
	bne	loc_0484E5
	lda	#$0001
	sta	$02
	lda	#$0018
	sta	$08
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4200
	ldy	$30,x
	phx
	jsl	f:sub_00FEA3
	plx
	clc
	lda	$30,x
	adc	#$0006
	sta	$30,x
loc_0484E5:
	rtl

sub_0484E6:
	lda	$00,x
	bne	loc_0484F6
	inc	$12,x
	lda	#$0010
	sta	$24,x
	lda	#$E7DA
	sta	$30,x
loc_0484F6:
	rtl

sub_0484F7:
	dec	$24,x
	bpl	loc_048501
	lda	#$8000
	sta	$16,x
	rtl
loc_048501:
	lda	$24,x
	bit	#$0007
	bne	loc_04852E
	lda	#$0002
	sta	$02
	lda	#$0010
	sta	$08
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4090
	ldy	$30,x
	phx
	jsl	f:sub_00FEA3
	plx
	clc
	lda	$30,x
	adc	#$0004
	sta	$30,x
loc_04852E:
	rtl

sub_04852F:
	lda	a:$0016,y
	beq	loc_048544
	bmi	loc_048544
	lda	a:$000A,y
	cmp	#$000D
	bcs	loc_048544
	lda	#$0004
	sta	a:$003C,y
loc_048544:
	rts

sub_048545:
	lda	#$0400
	jsl	f:sub_01A15D
	lda	a:$1636
	and	#$0300
	beq	loc_048575
	stz	$00
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bpl	loc_048565
	eor	#$FFFF
	inc	$00
	inc	$00
loc_048565:
	sta	$04
	sec
	lda	a:$000E,y
	sbc	$0E,x
	bpl	loc_048572
	eor	#$FFFF
loc_048572:
	sta	$06
	rts
loc_048575:
	lda	$E8
	and	#$00FF
	sta	$06
	lda	$EA
	and	#$00FF
	sta	$04
	and	#$0002
	sta	$00
	rts

sub_048589:
	lda	$BE
	bne	loc_048604
	ldy	#$0800
	jsl	f:sub_019EC1
	bcc	loc_048604
	lda	#$0046
	sta	a:$0010,y
	lda	#$3800
	sta	a:$0002,y
	lda	#$000F
	sta	a:$0016,y
	lda	$0A,x
	sta	$00
	lda	$0E,x
	adc	#$FFE6
	sta	a:$000E,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4
	sta	a:$002A,y
	phx
	tya
	ldy	$04,x
	tax
	lda	a:data_05E861,y
	sta	$00,x
	lda	a:data_05E89D,y
	clc
	adc	$00
	sta	$0A,x
	lda	$78
	bit	#$0010
	beq	loc_0485DC
	eor	#$FFFF
loc_0485DC:
	and	#$000E
	clc
	adc	a:data_05E899,y
	tay
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	lda	a:data_058E1A,y
	sta	$18,x
	lda	a:data_058D7A,y
	sta	$1A,x
	plx
	lda	$C0
	bne	loc_048604
	lda	#$001A
	jsl	f:sub_00868F
loc_048604:
	rts

sub_048605:
	lda	$38,x
	bne	loc_048631
	lda	$06,x
	bpl	loc_048630
	lda	$12,x
	cmp	#$0002
	bne	loc_048630
	lda	#$0007
	sta	$12,x
	lda	#$0030
	sta	$06,x
loc_04861E:
	lda	#$0001
	sta	$16,x
	lda	#$0080
	sta	$24,x
	stz	$20,x
	stz	$30,x
	stz	$04,x
	inc	$38,x
loc_048630:
	rts
loc_048631:
	cmp	#$0002
	bcs	loc_04864D
	lda	$06,x
	bmi	loc_04863C
	bpl	loc_048630
loc_04863C:
	inc	$12,x
	lda	#$0400
	sta	$06,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	bra	loc_04861E
loc_04864D:
	lda	$06,x
	bpl	loc_048630
	lda	#$0016
	sta	$12,x
	lda	#$0004
	sta	$36,x
	stz	$34,x
	lda	#$0001
	sta	$16,x
	stz	$06,x
	jsl	f:sub_0181E8
	rts

sub_048669:
	lda	$30,x
	beq	loc_048675
	lda	$30,x
	sta	$00,x
	stz	$30,x
	bra	loc_04867B
loc_048675:
	lda	$00,x
	sta	$30,x
	stz	$00,x
loc_04867B:
	rts

sub_04867C:
	lda	a:$08D0
	bne	loc_048699
	dec	$24,x
	bne	loc_048699
	lda	#$F48A
	sta	a:$1682
	lda	#$0004
	sta	a:$1680
	lda	#$0004
	sta	a:$1662
	inc	$12,x
loc_048699:
	rtl

sub_04869A:
	lda	a:$1678
	bne	loc_048699
	lda	#$0068
	jsl	f:sub_00868F
	inc	$12,x
	lda	#$0100
	sta	a:$13D8
	stz	a:$163C
	stz	a:$1638
	lda	#$0002
	sta	a:$163A
	lda	#$00A2
	sta	a:$163E
	lda	#$0030
	sta	$30,x
	lda	#$0008
	sta	$32,x
	lda	#$0068
	sta	$0A,x
	lda	#$0080
	sta	$0E,x
	lda	#$0028
	sta	$28,x
	lda	#$FFC8
	sta	$2A,x
	stz	$16,x
	phx
	ldx	#.loword(data_05EB45)
	jsl	f:sub_0090A8
	plx
	lda	#$0004
	jsl	f:sub_01F6A8
	rtl

sub_0486F1:
	dec	$30,x
	bne	loc_04873C
	dec	$32,x
	dec	$32,x
	bpl	loc_048704
	inc	$12,x
	lda	#$004E
	jml	f:sub_00868F
loc_048704:
	lda	#$0002
	sta	$02
	lda	#$0010
	sta	$08
	lda	$32,x
	tay
	asl	a
	clc
	adc	#$EB21
	pha
	lda	a:data_05E8B7,y
	sta	$30,x
	tya
	lsr	a
	and	#$0002
	tay
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	clc
	adc	a:data_05E8BF,y
	ply
	phx
	jsl	f:sub_00FEA3
	plx
	lda	#$004D
	jsl	f:sub_00868F
loc_04873C:
	rtl

sub_04873D:
	jsr	a:sub_04893E
	dec	a:$163E
	bne	loc_048751
	stz	$34,x
	stz	$36,x
	lda	#$4010
	sta	$16,x
	inc	$12,x
	rtl
loc_048751:
	lda	a:$163E
	cmp	#$0040
	bcc	loc_048765
	phx
	ldy	#$CD35
	ldx	#$1210
	jsl	f:sub_009985
	plx
loc_048765:
	rtl

sub_048766:
	lda	#$0070
	sta	$0A,x
	lda	#$0080
	sta	$0E,x
	lda	#$3400
	sta	$02,x
	lda	#$C257
	sta	$00,x
	inc	$12,x
	rtl

sub_04877D:
	stz	a:$163A
	jsr	a:sub_04893E
	lda	a:$1638
	bne	loc_0487A1
	lda	#$0083
	jsl	f:sub_00868F
	inc	$12,x
	lda	#$0100
	sta	a:$1686
	lda	#$001F
	sta	$34,x
	lda	#$001F
	sta	$36,x
loc_0487A1:
	brl	loc_048929

sub_0487A4:
	lda	#$006D
	jsl	f:sub_00868F
	inc	$12,x
	rtl

sub_0487AE:
	stz	a:$163A
	jsr	a:sub_04893E
	lda	$0E,x
	bmi	loc_0487C2
	cmp	#$00D8
	bcc	loc_0487C2
	lda	#$FFFD
	sta	$1E,x
loc_0487C2:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	#$0001
	sta	a:$1660
	jml	f:loc_01D83E

sub_0487DB:
	jsl	f:sub_00FD8D
	lda	#$0003
	sta	a:$1662
	lda	#$00C0
	sta	$02
	lda	#$0038
	sta	$00
	lda	#$007F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	sub_04880B
	lda	#$FFFD
	sta	a:$001E,y

sub_04880B:
	ldy	$36,x
	lda	$34,x
	cmp	a:data_05EB4E,y
	bcs	loc_048819
	lda	a:data_05EB54,y
	bra	loc_048821
loc_048819:
	lda	#$0060
	sta	$3E,x
	inc	$12,x
	rtl
loc_048821:
	clc
	adc	$34,x
	sta	$34,x
	and	#$0020
	bne	loc_048830
	lda	#$000C
	bra	loc_048833
loc_048830:
	lda	#$0000
loc_048833:
	jsr	a:sub_048A5C
	rtl

sub_048837:
	stz	$34,x
	lda	#$0000
	jsr	a:sub_048A5C
	dec	$3E,x
	bne	loc_048847
	inc	$12,x
	stz	$36,x
loc_048847:
	lda	$3E,x
	cmp	#$0040
	bne	loc_04885A
	lda	#$006C
	jsr	a:sub_048BBF
	lda	#$0084
	jsr	a:sub_048BBF
loc_04885A:
	rtl

sub_04885B:
	jsr	a:sub_0489CD
	dec	$3E,x
	bne	loc_04886C
	inc	$12,x
	stz	$30,x
	lda	#$003E
	sta	$32,x
	rtl
loc_04886C:
	lda	#$0084
	sta	$02
	lda	#$0070
	sta	$00
	lda	#$000F
	sta	$04
	lda	#$0000
	sta	$06
	ldy	#$0300
	lda	#$C5B8
	jsl	f:sub_01CF3C
	bcs	loc_048892
	lda	#$0002
	sta	a:$001E,y
loc_048892:
	rtl

sub_048893:
	jsr	a:sub_0489CD
	jsr	a:sub_0489DC
	lda	$78
	and	#$0004
	beq	loc_0488A3
	lda	#$000C
loc_0488A3:
	jsr	a:sub_048A5C
	lda	$32,x
	cmp	#$0144
	bcc	loc_0488B9
	lda	#$0013
	sta	$12,x
	lda	#$0002
	sta	$36,x
	stz	$34,x
loc_0488B9:
	rtl

sub_0488BA:
	stz	$34,x
	lda	$78
	and	#$0004
	beq	loc_0488C6
	lda	#$000C
loc_0488C6:
	jsr	a:sub_048A5C
	dec	$3E,x
	dec	$3E,x
	bne	loc_048906
	inc	$12,x
	lda	#$0080
	sta	$3E,x
	stz	$16,x
	lda	#$0006
	sta	$FE
	lda	#$0800
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	lsr	a
	sec
	sbc	#$0018
	and	#$007E
	sta	$FC
loc_0488F2:
	lda	$FC
	jsr	a:sub_048A80
	clc
	lda	$FC
	adc	#$0008
	and	#$007E
	sta	$FC
	dec	$FE
	bne	loc_0488F2
loc_048906:
	rtl

sub_048907:
	dec	$3E,x
	bne	loc_048923
	lda	#$00A2
	sta	a:$163E
	lda	#$0002
	sta	a:$163A
	lda	#$000D
	sta	$12,x
	lda	#$004E
	jml	f:sub_00868F
loc_048923:
	stz	a:$163A
	jsr	a:sub_04893E
loc_048929:
	lda	a:$1638
	cmp	#$0004
	bne	loc_04893D
	phx
	ldy	#$CD3B
	ldx	#$1210
	jsl	f:sub_009985
	plx
loc_04893D:
	rtl

sub_04893E:
	lda	#$0003
	sta	a:$1662
	phx
	lda	a:$1638
	asl	a
	tay
	lda	a:$163C
	cmp	#$0003
	bcs	loc_0489A1
	cpy	#$000E
	bcc	loc_04895C
	cmp	#$0000
	beq	loc_0489A1
loc_04895C:
	ldx	#$0001
	stx	$02
	ldx	#$0020
	stx	$08
	asl	a
	tax
	tya
	asl	a
	asl	a
	asl	a
	clc
	adc	a:data_05E8EF,x
	tay
	clc
	adc	#$0008
	sta	$FE
	lda	a:$1380
	and	#$0100
	asl	a
	asl	a
	pha
	clc
	adc	a:data_05E8FB,x
	sta	$FC
	pla
	clc
	adc	a:data_05E8F5,x
	jsl	f:sub_00FEA3
	ldx	#$0001
	stx	$02
	ldx	#$0040
	stx	$08
	lda	$FC
	ldy	$FE
	jsl	f:sub_00FEA3
loc_0489A1:
	inc	a:$163C
	ldy	a:$163A
	lda	a:$163C
	cmp	a:data_05E8E7,y
	bcc	loc_0489CB
	stz	a:$163C
	clc
	lda	a:$1638
	adc	a:data_05E8EB,y
	bpl	loc_0489C0
	stz	a:$1638
	bra	loc_0489CB
loc_0489C0:
	cmp	#$0008
	bcc	loc_0489C8
	lda	#$0008
loc_0489C8:
	sta	a:$1638
loc_0489CB:
	plx
	rts

sub_0489CD:
	lda	$78
	bit	#$001F
	bne	loc_0489DB
	lda	#$0035
	jsl	f:sub_00868F
loc_0489DB:
	rts

sub_0489DC:
	ldy	$84
	clc
	lda	$30,x
	adc	a:data_05EB31,y
	sta	$30,x
	lda	$32,x
	adc	#$0000
	sta	$32,x
	lda	$BE
	bne	loc_048A5B
	phx
	lda	$32,x
	and	#$007E
	pha
	clc
	adc	#$0004
	sta	$34,x
	pla
	tax
	ldy	#$08C0
	jsl	f:sub_019EC1
	bcc	loc_048A5A
	lda	#$EB37
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$004B
	sta	a:$0010,y
	lda	#$000F
	sta	a:$0016,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4
	sta	a:$002A,y
	lda	a:data_058D5A,x
	sta	a:$001E,y
	lda	a:data_058D7A,x
	sta	a:$001A,y
	lda	a:data_058DFA,x
	sta	a:$001C,y
	lda	a:data_058E1A,x
	sta	a:$0018,y
	txa
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	tax
	lda	a:data_05EAA1,x
	and	#$00FF
	sta	a:$000A,y
	lda	#$0082
	sta	a:$000E,y
loc_048A5A:
	plx
loc_048A5B:
	rts

sub_048A5C:
	pha
	lda	#$0002
	sta	$02
	lda	#$0030
	sta	$08
	lda	$34,x
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	pla
	clc
	adc	a:data_05EA91,y
	tay
	lda	#$4D0C
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_048A80:
	phx
	tax
	ldy	#$0300
	jsl	f:sub_019EAE
	bcs	loc_048ADB
	lda	a:data_058D5A,x
	sta	a:$001E,y
	lda	a:data_058D7A,x
	sta	a:$001A,y
	lda	a:data_058DFA,x
	sta	a:$001C,y
	lda	a:data_058E1A,x
	sta	a:$0018,y
	txa
	clc
	adc	#$004A
	and	#$0070
	sta	a:$0032,y
	lda	#$0080
	sta	a:$000A,y
	lda	#$0090
	sta	a:$000E,y
	lda	#$C218
	sta	a:$0000,y
	sta	a:$0034,y
	lda	#$3800
	sta	a:$0002,y
	lda	#$004C
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	#$EB5A
	sta	a:$0020,y
loc_048ADB:
	plx
	rts

sub_048ADD:
	lda	$12,x
	bne	loc_048B25
	lda	#$FFE8
	sta	$02
	lda	#$0018
	sta	$00
	jsl	f:sub_00E16E
	bne	loc_048B0C
	stz	$00
	jsl	f:sub_00E16E
	bne	loc_048B0C
	stz	$02
	jsl	f:sub_00E16E
	bne	loc_048B0C
	lda	#$0018
	sta	$00
	jsl	f:sub_00E16E
	beq	loc_048B24
loc_048B0C:
	lda	$0E,x
	and	#$FFF8
	sta	$0E,x
	lda	$0A,x
	and	#$FFF8
	sta	$0A,x
	stz	$1C,x
	stz	$1E,x
	stz	$18,x
	stz	$1A,x
	inc	$12,x
loc_048B24:
	rtl
loc_048B25:
	cmp	#$0002
	beq	loc_048B45
	lda	$00,x
	cmp	$34,x
	beq	loc_048B39
	sta	$34,x
	lda	#$0036
	jsl	f:sub_00868F
loc_048B39:
	lda	$20,x
	bne	loc_048B44
	inc	$12,x
	lda	#$0040
	sta	$24,x
loc_048B44:
	rtl
loc_048B45:
	dec	$24,x
	bne	loc_048B4F
	lda	#$8000
	sta	$16,x
	rtl
loc_048B4F:
	lda	#$0030
	jsl	f:sub_00FD9A
	lda	$BE
	bne	loc_048BBE
	ldy	#$0280
	jsl	f:sub_019E98
	bcs	loc_048BBE
	lda	#$C51C
	sta	a:$0020,y
	lda	#$001D
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
	lda	$E8
	inc	$E8
	and	#$001F
	pha
	adc	$0A,x
	sta	a:$000A,y
	pla
	adc	$0E,x
	sta	a:$000E,y
	phx
	lda	$EA
	dec	$EA
	and	#$001F
	eor	#$FFFF
	adc	$32,x
	and	#$007E
	tax
	lda	a:data_058D5A,x
	sta	a:$001E,y
	lda	a:data_058D7A,x
	sta	a:$001A,y
	lda	a:data_058DFA,x
	sta	a:$001C,y
	lda	a:data_058E1A,x
	sta	a:$0018,y
	plx
loc_048BBE:
	rtl

sub_048BBF:
	sta	$FC
	jsl	f:sub_019EAB
	bcs	loc_048BE9
	lda	#$0087
	sta	a:$0010,y
	lda	$FC
	sta	a:$000A,y
	phx
	tyx
	lda	#$0001
	sta	$00
	lda	#$000A
	sta	$04
	lda	#$0005
	ldy	#$0380
	jsl	f:sub_01A412
	plx
loc_048BE9:
	rts

sub_048BEA:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_048BF9,x
	plx
	sta	$00
	jmp	($0000)
tbl_048BF9:
	.addr	sub_048BFF
	.addr	sub_048C27
	.addr	sub_048C5D

sub_048BFF:
	inc	$12,x
	lda	#$C6BA
	sta	$20,x
	lda	#$000D
	sta	$16,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$3000
	sta	$02,x
	lda	#$0074
	sta	$0E,x
	ldy	$84
	lda	a:data_05EB78,y
	sta	$24,x
	rtl

sub_048C27:
	lda	$20,x
	bne	loc_048C5B
	inc	$12,x
	lda	$E8
	adc	$0A,x
	and	#$000F
	adc	#$0010
	sta	$36,x
	lda	#$0800
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:data_05E8C3,y
	sta	$00,x
	lda	a:data_05E8D7,y
	sta	$1A,x
	lda	a:data_05E8D3,y
	sta	$1E,x
loc_048C5B:
	bra	loc_048C79

sub_048C5D:
	dec	$24,x
	bpl	loc_048C6A
	lda	#$8000
	sta	$16,x
	jml	f:sub_01A52C
loc_048C6A:
	dec	$36,x
	bpl	loc_048C79
	dec	$12,x
	stz	$1A,x
	stz	$1E,x
	lda	#$C636
	sta	$20,x
loc_048C79:
	lda	$E4
	bne	loc_048C84
	lda	$02,x
	eor	#$0E00
	sta	$02,x
loc_048C84:
	jml	f:sub_01A513

sub_048C88:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_048C97,x
	plx
	sta	$00
	jmp	($0000)
tbl_048C97:
	.addr	sub_048CD7
	.addr	sub_048CEC
	.addr	sub_048D33
	.addr	sub_048D2D
	.addr	sub_048D42
	.addr	sub_048D49
	.addr	sub_048D97
	.addr	sub_048DB9
	.addr	sub_048DE4
	.addr	sub_048E01
	.addr	sub_048DF3
	.addr	sub_048E14
	.addr	sub_048E45
	.addr	sub_048EEF
	.addr	sub_048F05
	.addr	sub_048F21
	.addr	sub_048F3C
	.addr	sub_048F72
	.addr	sub_048F95
	.addr	sub_048FCB
	.addr	sub_048FD1
	.addr	sub_049007
	.addr	sub_049018
	.addr	sub_0490B2
	.addr	sub_0490E2
	.addr	sub_0490ED
	.addr	sub_04911F
	.addr	sub_049123
	.addr	sub_04915F
	.addr	sub_0491E3
	.addr	sub_049205
	.addr	sub_049211

sub_048CD7:
	lda	#$0100
	sta	$24,x
	inc	$12,x
	stz	a:$1688
	lda	#$0018
	sta	$34,x
	lda	#$0080
	sta	$38,x
	rtl

sub_048CEC:
	dec	$24,x
	bpl	loc_048CFB
	inc	$12,x
	lda	#$0063
	jsl	f:sub_00868F
	stz	$24,x
loc_048CFB:
	lda	$24,x
	cmp	#$0090
	bne	loc_048D29
	jsr	a:sub_049B36
	lda	#$0060
	sta	a:$000E,y
	lda	#$3600
	sta	a:$0002,y
	lda	#$0074
	sta	a:$0010,y
	lda	#$0005
	sta	a:$0012,y
	lda	#$C6EB
	sta	a:$0000,y
	lda	#$0004
	sta	a:$001A,y
loc_048D29:
	jsr	a:sub_0497E0
	rtl

sub_048D2D:
	jsr	a:sub_049BD5
	jsr	a:sub_049B32

sub_048D33:
	dec	$24,x
	bpl	loc_048D3E
	lda	#$00C0
	sta	$24,x
	inc	$12,x
loc_048D3E:
	jsr	a:sub_0497E0
	rtl

sub_048D42:
	jsr	a:sub_049AF5
	jsr	a:sub_0497E0
	rtl

sub_048D49:
	jsr	a:sub_0497E0
	lda	a:$1380
	and	#$00FF
	cmp	#$0010
	bne	loc_048D96
	stz	a:$1380
	lda	#$0041
	sta	a:$1E8C
	lda	#$000A
	sta	$46
	lda	#$51A0
	sta	$00
	lda	#$4018
	jsl	f:sub_00FE76
	lda	#$0001
	sta	$02
	lda	#$0030
	sta	$08
	lda	#$401C
	ldy	#$ECC6
	phx
	jsl	f:sub_00FEA3
	plx
	inc	$12,x
	lda	#$0010
	sta	a:$1380
	sta	a:$138A
	jml	f:loc_00D5ED
loc_048D96:
	rtl

sub_048D97:
	lda	a:$1380
	clc
	adc	#$0010
	and	#$00FF
	bne	loc_048DB2
	inc	$12,x
	lda	#$4000
	sta	$34,x
	lda	#$0080
	sta	$24,x
	lda	#$0100
loc_048DB2:
	sta	a:$1380
	jml	f:loc_00D5ED

sub_048DB9:
	lda	#$0008
	sta	$02
	lda	#$0040
	sta	$08
	lda	$34,x
	ldy	#$946A
	phx
	jsl	f:sub_00FEA3
	plx
	clc
	lda	$34,x
	adc	#$0080
	sta	$34,x
	cmp	#$4300
	bcc	loc_048DE0
	inc	$12,x
	stz	a:$1380
loc_048DE0:
	jml	f:loc_00D5ED

sub_048DE4:
	dec	$24,x
	bpl	loc_048DEF
	lda	#$0140
	sta	$24,x
	inc	$12,x
loc_048DEF:
	jml	f:loc_00D5ED

sub_048DF3:
	lda	a:$0910
	bne	loc_048E0D
	lda	#$0002
	sta	a:$1688
	inc	$12,x
	rtl

sub_048E01:
	dec	$24,x
	bpl	loc_048E0D
	inc	$12,x
	lda	#$006E
	sta	a:$0910
loc_048E0D:
	jsr	a:sub_049AC1
	jml	f:loc_00D5ED

sub_048E14:
	phx
	ldx	#.loword(data_05ECD9)
	jsl	f:sub_0090A8
	plx
	lda	#$FFFC
	sta	a:$168E
	lda	#$8000
	sta	a:$168C
	lda	#$0005
	sta	a:$13BA
	lda	#$0008
	sta	a:$13B2
	lda	#$0B80
	sta	a:$1380
	stz	$24,x
	stz	$36,x
	inc	$12,x
	jml	f:loc_00D5ED

sub_048E45:
	ldy	$24,x
	lda	a:$1380
	cmp	#$01E0
	bcs	loc_048E56
	lda	#$0040
	sta	$24,x
	inc	$12,x
loc_048E56:
	cmp	a:data_05EB7E,y
	bcs	loc_048E5F
	inc	$24,x
	inc	$24,x
loc_048E5F:
	lda	a:$168D
	cmp	a:data_05EB8C,y
	beq	loc_048E91
	bmi	loc_048E7E
	sec
	lda	a:$168C
	sbc	#$0800
	sta	a:$168C
	lda	a:$168E
	sbc	#$0000
	sta	a:$168E
	bra	loc_048E91
loc_048E7E:
	clc
	lda	a:$168C
	adc	#$0800
	sta	a:$168C
	lda	a:$168E
	adc	#$0000
	sta	a:$168E
loc_048E91:
	ldy	$36,x
	bne	loc_048EBE
	lda	a:$1398
	cmp	#$000C
	bcs	loc_048E9F
	inc	$36,x
loc_048E9F:
	lda	a:$1691
	bpl	loc_048EA9
	cmp	#$FF80
	bcc	loc_048EE7
loc_048EA9:
	sec
	lda	a:$1690
	sbc	#$0400
	sta	a:$1690
	lda	a:$1692
	sbc	#$0000
	sta	a:$1692
	bra	loc_048EE7
loc_048EBE:
	lda	a:$1398
	bmi	loc_048ECA
	cmp	#$0010
	bcc	loc_048ECA
	stz	$36,x
loc_048ECA:
	lda	a:$1691
	bmi	loc_048ED4
	cmp	#$0080
	bcs	loc_048EE7
loc_048ED4:
	clc
	lda	a:$1690
	adc	#$0400
	sta	a:$1690
	lda	a:$1692
	adc	#$0000
	sta	a:$1692
loc_048EE7:
	jsl	f:sub_00CF0C
	jml	f:loc_00D5ED

sub_048EEF:
	dec	$24,x
	bpl	loc_048F01
	lda	#$0079
	sta	a:$0910
	lda	#$0001
	sta	a:$1E40
	inc	$12,x
loc_048F01:
	jml	f:loc_00D5ED

sub_048F05:
	lda	a:$0910
	cmp	#$0079
	beq	loc_048F1D
	inc	$12,x
	lda	#$0100
	sta	$24,x
	phx
	ldx	#.loword(data_05ECD0)
	jsl	f:sub_0090A8
	plx
loc_048F1D:
	jml	f:loc_00D5ED

sub_048F21:
	dec	$24,x
	bpl	loc_048F35
	stz	$24,x
	inc	$12,x
	lda	#$0084
	sta	a:$0910
	lda	#$0004
	sta	a:$13BA
loc_048F35:
	jsr	a:sub_049BD5
	jml	f:loc_00D5ED

sub_048F3C:
	inc	$12,x
	ldy	#$0800
	lda	#$0065
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	#$0002
	sta	a:$0034,y
	lda	#$EBB8
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0001
	sta	a:$001A,y
	lda	#$FF80
	sta	a:$000A,y
	stz	a:$1398
	jml	f:sub_00D610

sub_048F72:
	sec
	lda	#$0140
	sbc	a:$080A
	sta	a:$1380
	lda	a:$080A
	bmi	loc_048F91
	cmp	#$0040
	bcc	loc_048F91
	stz	a:$081A
	inc	$12,x
	lda	#$0006
	sta	a:$1672
loc_048F91:
	jml	f:loc_00D5ED

sub_048F95:
	lda	a:$1F8A
	beq	loc_048FA2
	lda	a:$0212
	cmp	#$0001
	bne	loc_048FC7
loc_048FA2:
	lda	a:$1E02
	beq	loc_048FB4
	lda	a:$1FCA
	beq	loc_048FB4
	lda	a:$0252
	cmp	#$0001
	bne	loc_048FC7
loc_048FB4:
	inc	$12,x
	stz	a:$0820
	stz	a:$0822
	stz	a:$0800
	lda	#$000B
	sta	a:$13FA
	stz	$30,x
loc_048FC7:
	jml	f:sub_00D610

sub_048FCB:
	jsl	f:sub_00D610
	bra	loc_048FE1

sub_048FD1:
	lda	a:$13D8
	cmp	#$FE00
	bne	loc_048FE1
	lda	#$000A
	sta	a:$13FA
	inc	$12,x
loc_048FE1:
	lda	a:$1398
	cmp	#$0010
	beq	loc_049000
	lda	#$C000
	sta	a:$081C
	lda	#$FFFF
	sta	a:$081E
	sec
	lda	#$0078
	sbc	a:$080E
	sta	a:$1398
	rtl
loc_049000:
	stz	a:$081C
	stz	a:$081E
	rtl

sub_049007:
	lda	a:$0910
	cmp	#$0084
	beq	loc_049017
	lda	#$C558
	sta	a:$1636
	inc	$12,x
loc_049017:
	rtl

sub_049018:
	lda	$BC
	beq	loc_049017
	inc	$12,x
	lda	#$4200
	jsr	a:sub_049864
	lda	#$000B
	sta	$46
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0030
	sta	a:$3800
	lda	#$1001
	sta	a:$3802
	lda	#$0100
	sta	a:$3806
	sta	a:$3810
	lda	#$0001
	sta	a:$3816
	lda	#$0010
	sta	a:$3808
	stz	a:$3812
	stz	a:$3818
	lda	#$3000
	sta	a:$380C
	lda	#$1F00
	sta	a:$3804
	sta	a:$380E
	lda	#$001F
	sta	a:$380A
	sta	a:$3814
	sta	a:$3820
	lda	#$7F00
	sta	a:$3822
	stz	a:$3826
	lda	a:$13C0
	sta	a:$3824
	lda	a:$13C4
	sta	a:$13C4
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	lda	#$0180
	sta	a:$13FC
	lda	#$0001
	sta	a:$13FA
	stz	a:$13FE
	lda	#$0015
	sta	a:$1E9A
	lda	#$2000
	sta	a:$140C
	lda	#$0001
	sta	a:$140E
	rtl

sub_0490B2:
	lda	a:$13FE
	beq	loc_0490DE
	inc	$12,x
	stz	a:$13FA
	lda	#$0002
	sta	a:$0812
	lda	#$FFFC
	sta	a:$081A
	lda	#$0001
	sta	a:$081E
	lda	#$0050
	jsl	f:sub_00868F
	phx
	ldx	#.loword(data_05ECD0)
	jsl	f:sub_0090A8
	plx
loc_0490DE:
	jsr	a:sub_049878
	rtl

sub_0490E2:
	lda	$BC
	beq	loc_04911E
	inc	$12,x
	lda	#$0040
	sta	$24,x

sub_0490ED:
	dec	$24,x
	bne	loc_049105
	inc	$12,x
	lda	#$0017
	sta	a:$1E9A
	lda	#$0049
	sta	a:$1E8E
	lda	#$0069
	sta	a:$0910
loc_049105:
	lda	#$0004
	sta	$02
	lda	#$0020
	sta	$08
	ldy	#$EC34
	lda	#$4588
	phx
	jsl	f:sub_00FEA3
	plx
	jsr	a:sub_049878
loc_04911E:
	rtl

sub_04911F:
	jsr	a:sub_049878
	rtl

sub_049123:
	lda	#$0001
	sta	a:$1510
	sta	a:$1550
	stz	a:$1518
	stz	a:$1558
	lda	#$000C
	sta	a:$151A
	sta	a:$155A
	lda	#$00D8
	sta	a:$151C
	sta	a:$155C
	lda	#$0080
	sta	a:$151E
	sta	a:$155E
	lda	#$001F
	sta	a:$16AC
	lda	#$00FF
	sta	a:$16AA
	inc	$12,x
	jsr	a:sub_049878
	rtl

sub_04915F:
	lda	#$00E0
	cmp	a:$1510
	bcs	loc_0491DF
	lda	#$00FE
	sta	a:$1510
	sta	a:$1550
	stz	a:$1518
	stz	a:$1558
	stz	a:$151A
	stz	a:$155A
	lda	#$005B
	jsl	f:sub_00868F
	lda	#$0002
	sta	a:$1E5E
	lda	#$0080
	sta	$24,x
	inc	$12,x
	lda	#$0003
	sta	a:$16B4
	lda	#$FFD8
	sta	a:$1398
	lda	#$4580
	jsr	a:sub_049864
	lda	#$000C
	sta	$46
	lda	#$8000
	sta	a:$0816
	sta	a:$0856
	sta	a:$0896
	sta	a:$0916
	lda	#$0008
	sta	a:$07D2
	stz	a:$07DA
	lda	#$4000
	sta	a:$07D8
	lda	#$00A0
	sta	a:$07CE
	lda	#$0000
	sta	a:$07CA
	phx
	ldx	#$0200
	jsr	a:sub_0497AB
	ldx	#$0240
	jsr	a:sub_0497AB
	plx
loc_0491DF:
	jsr	a:sub_049878
	rtl

sub_0491E3:
	dec	$24,x
	bpl	loc_0491EE
	inc	$12,x
	lda	#$0080
	sta	$24,x
loc_0491EE:
	lda	#$00FE
	sta	a:$1510
	sta	a:$1550
	stz	a:$1518
	stz	a:$1558
	stz	a:$151A
	stz	a:$155A
	bra	loc_049231

sub_049205:
	dec	$24,x
	bpl	sub_049211
	inc	$12,x
	lda	#$0100
	sta	a:$1686

sub_049211:
	sec
	lda	a:$1510
	sbc	#$0004
	bpl	loc_04921D
	lda	#$0000
loc_04921D:
	sta	a:$1510
	sta	a:$1550
	lda	$BC
	bne	loc_049231
	lda	a:$151E
	inc	a
	sta	a:$151E
	sta	a:$155E
loc_049231:
	lda	a:$151C
	dec	a
	sta	a:$151C
	sta	a:$155C
	stz	a:$1518
	stz	a:$1558
	stz	a:$151A
	stz	a:$155A
	rtl

sub_049248:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_049257,x
	plx
	sta	$00
	jmp	($0000)
tbl_049257:
	.addr	sub_049269
	.addr	sub_0492FF
	.addr	sub_0492A7
	.addr	sub_0492D5
	.addr	sub_0492F6
	.addr	sub_0493E1
	.addr	sub_04941B
	.addr	sub_04939B
	.addr	sub_049460

sub_049269:
	lda	#$FF80
	sta	$0A,x
	lda	#$0078
	sta	$0E,x
	inc	$12,x
	bra	loc_049285

sub_049277:
	sty	$34,x
	lda	#$0065
	sta	$10,x
	lda	#$0007
	sta	$12,x
	stz	$1A,x
loc_049285:
	lda	#$0078
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$0001
	sta	$16,x
	stz	$18,x
	stz	$1C,x
	stz	$1E,x
	stz	$3A,x
	stz	$3E,x
	stz	$38,x
	stz	$36,x
	stz	$30,x
	stz	$32,x
	rtl

sub_0492A7:
	sec
	lda	$1C,x
	sbc	#$0800
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bne	loc_0492BE
	lda	$1C,x
	bne	loc_0492BE
	inc	$12,x
loc_0492BE:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	jsr	a:sub_04988E
	jsr	a:sub_04997F
	bra	sub_0492FF

sub_0492D5:
	sec
	lda	$18,x
	sbc	#$0800
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	cmp	#$FFFE
	bne	loc_0492EB
	inc	$12,x
loc_0492EB:
	jsr	a:sub_0499AB
	jsr	a:sub_04988E
	jsr	a:sub_04997F
	bra	sub_0492FF

sub_0492F6:
	jsr	a:sub_0499AB
	jsr	a:sub_04988E
	jsr	a:sub_04997F

sub_0492FF:
	lda	$78
	bit	#$003F
	bne	loc_049329
	lda	#$0031
	ldy	$86
	cpy	#$0004
	beq	loc_049325
	lda	a:$0912
	cmp	#$0017
	bcc	loc_049322
	cmp	#$0025
	bcc	loc_049329
	cmp	#$0029
	bcs	loc_049329
loc_049322:
	lda	#$005F
loc_049325:
	jsl	f:sub_00868F
loc_049329:
	jsr	a:sub_0497EE
	inc	$30,x
	lda	$32,x
	inc	a
	and	#$0007
	cmp	#$0006
	bne	loc_04933C
	lda	#$0000
loc_04933C:
	sta	$32,x
	and	#$0006
	sta	$FC
	lda	$BC
	bne	loc_04939A
	lda	$30,x
	and	#$0006
	tay
	lda	#$0006
	sta	$02
	lda	#$0030
	sta	$08
	phy
	lda	#$4404
	ldy	$86
	cpy	#$0004
	beq	loc_049365
	lda	#$4804
loc_049365:
	ply
	pha
	lda	a:data_05EC3C,y
	tay
	pla
	phx
	jsl	f:sub_00FEA3
	ldy	$FC
	lda	#$0002
	sta	$02
	lda	#$0040
	sta	$08
	phy
	lda	#$4480
	ldy	$86
	cpy	#$0004
	beq	loc_04938B
	lda	#$4880
loc_04938B:
	ply
	pha
	lda	a:data_05EC74,y
	tay
	pla
	ldx	#$0030
	jsl	f:sub_00FEAA
	plx
loc_04939A:
	rtl

sub_04939B:
	lda	$34,x
	lsr	a
	tay
	lda	#$FF80
	sta	$0A,x
	lda	a:data_05EB9A,y
	and	#$00FF
	sta	$00
	lda	$EA
	and	#$0007
	clc
	adc	$00
	sta	$0E,x
	tya
	clc
	adc	$30,x
	and	#$0003
	tay
	lda	a:data_05EB9E,y
	xba
	and	#$FF00
	sta	$00
	ldy	$84
	lda	a:data_05EBA2,y
	clc
	adc	$00
	sta	$18,x
	lda	#$0000
	adc	#$0000
	sta	$1A,x
	lda	#$0005
	sta	$12,x
	inc	$30,x
	rtl

sub_0493E1:
	jsr	a:sub_0497EE
	jsr	a:sub_04988E
	jsr	a:sub_04997F
	lda	a:$0796
	beq	loc_0493FD
	clc
	lda	a:$078A
	adc	#$FF90
	cmp	$0A,x
	bpl	loc_04941A
	inc	$12,x
	rtl
loc_0493FD:
	clc
	lda	a:$090A
	adc	#$FF90
	cmp	$0A,x
	bpl	loc_04941A
	lda	#$0200
	sta	a:$0926
	sec
	lda	a:$0906
	sbc	#$0004
	sta	a:$0906
	inc	$12,x
loc_04941A:
	rtl

sub_04941B:
	lda	$0A,x
	adc	#$0080
	sta	$00
	lda	$0E,x
	adc	#$FFF5
	sta	$02
	phx
	ldx	#$0006
	ldy	#$06C0
loc_049430:
	jsl	f:sub_019EC1
	bcc	loc_049456
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	$00
	sta	a:$000A,y
	sbc	#$0018
	sta	$00
	lda	$02
	sta	a:$000E,y
	lda	a:data_05ECB6,x
	sta	a:$001A,y
	dex
	dex
	bpl	loc_049430
loc_049456:
	plx
	inc	$12,x
	lda	#$0030
	jml	f:sub_00868F

sub_049460:
	lda	$0A,x
	adc	#$FFE8
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$007F
	sta	$06
	lda	#$003F
	sta	$04
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF3C
	lda	#$FFFE
	sta	a:$001A,y
	sec
	lda	#$0140
	sbc	a:$000A,x
	sta	a:$1380
	brl	sub_0492FF

sub_049495:
	lda	$16,x
	bpl	loc_04949D
	stz	a:$13C0
	rtl
loc_04949D:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_0494AC,x
	plx
	sta	$00
	jmp	($0000)
tbl_0494AC:
	.addr	sub_0494B6
	.addr	sub_04950E
	.addr	sub_04951D
	.addr	sub_0495C8
	.addr	sub_0495D1

sub_0494B6:
	lda	#$4001
	sta	$16,x
	lda	#$0180
	sta	$0A,x
	lda	#$0088
	sta	$0E,x
	lda	#$0180
	sta	$06,x
	lda	#$0020
	sta	$28,x
	lda	#$FFD0
	sta	$2A,x
	lda	#$017F
	sta	$32,x
	stz	$30,x
	stz	a:$163A
	inc	$12,x
	phx
	ldx	#$0700
	ldy	#$0000
	stz	$30,x
	jsr	a:sub_049A30
	lda	#$0080
	sta	$06,x
	ldx	#$0740
	sta	$06,x
	lda	#$0002
	sta	$30,x
	sta	$04,x
	jsr	a:sub_049A30
	ldx	#$0780
	ldy	#$0002
	jsr	a:sub_049A30
	plx
	stz	a:$1638
	rtl

sub_04950E:
	lda	$C0
	bne	sub_04951D
	dec	$32,x
	lda	$32,x
	cmp	#$00E1
	bcs	sub_04951D
	inc	$12,x

sub_04951D:
	lda	$26,x
	beq	loc_04952B
	lda	#$912A
	sta	$9A
	lda	#$6050
	sta	$98
loc_04952B:
	lda	$06,x
	bpl	loc_04953B
	lda	#$0001
	sta	$16,x
	inc	$12,x
	lda	#$0080
	sta	$24,x
loc_04953B:
	jsr	a:sub_0498AF
	lda	a:$0796
	beq	loc_0495A1
	inc	a:$1638
	lda	a:$1638
	cmp	#$0070
	bcc	loc_0495A0
	bit	#$0007
	bne	loc_0495A0
	cmp	#$0090
	bcc	loc_049564
	stz	a:$1638
	lda	a:$163A
	eor	#$0002
	sta	a:$163A
loc_049564:
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_0495A0
	lda	#$0082
	sta	a:$0010,y
	lda	$EA
	and	#$0003
	clc
	adc	#$FFFE
	sta	a:$001E,y
	lda	$E8
	and	#$F800
	ora	#$8000
	sta	a:$001C,y
	lda	$E8
	and	#$003F
	eor	#$FFFF
	clc
	adc	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	adc	#$0000
	sta	a:$000A,y
loc_0495A0:
	rtl
loc_0495A1:
	lda	$78
	bit	#$003F
	bne	loc_0495C7
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_0495C7
	lda	#$0083
	sta	a:$0010,y
	lda	$0A,x
	adc	#$0020
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFE0
	sta	a:$000E,y
loc_0495C7:
	rtl

sub_0495C8:
	dec	$24,x
	bne	sub_0495D1
	inc	a:$0952
	inc	$12,x

sub_0495D1:
	jsl	f:sub_00FD8D
	lda	$0A,x
	sta	$00
	lda	#$00FF
	sta	$02
	lda	#$00FF
	sta	$06
	stz	$04
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_0495FC
	lda	$E8
	and	#$0003
	adc	#$FFF5
	sta	a:$001A,y
loc_0495FC:
	jsr	a:sub_0498AF
	rtl

sub_049600:
	lda	$06,x
	bpl	loc_049633
	phx
	lda	$30,x
	tax
	lda	#$0001
	sta	$02
	lda	#$0010
	sta	$08
	ldy	a:data_05EBA8,x
	lda	a:data_05EBB4,x
	jsl	f:sub_00FEA3
	plx
	lda	#$0041
	jsl	f:sub_00868F
	ldy	$30,x
	lda	#$FFFC
	sta	$1A,x
	txy
	lda	#$C516
	jml	f:sub_01CF66
loc_049633:
	lda	a:$163A
	eor	$30,x
	bne	loc_04963D
	jsr	a:sub_049A54
loc_04963D:
	rtl

sub_04963E:
	lda	$3C,x
	bne	loc_049646
	lda	$06,x
	bpl	loc_04965A
loc_049646:
	lda	#$0017
	jsl	f:sub_00868F
	lda	#$FFF8
	sta	$1A,x
	txy
	lda	#$C4CE
	jml	f:sub_01CF66
loc_04965A:
	lda	$12,x
	bne	loc_049690
	inc	$12,x
	lda	#$C83F
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	lda	#$001F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	$E8
	and	#$001F
	adc	#$0090
	sta	$24,x
	lda	$E8
	and	#$7800
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	rtl
loc_049690:
	dec	$24,x
	bmi	loc_049646
	lda	$1C,x
	bne	loc_04969C
	lda	$1E,x
	beq	loc_0496AF
loc_04969C:
	lda	$1E,x
	bpl	loc_0496B0
	clc
	lda	$1C,x
	adc	#$0800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_0496AF:
	rtl
loc_0496B0:
	sec
	lda	$1C,x
	sbc	#$0800
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rtl

sub_0496C0:
	lda	$06,x
	bpl	loc_0496CC
	txy
	lda	#$C516
	jml	f:sub_01CF66
loc_0496CC:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_0496DB,x
	plx
	sta	$00
	jmp	($0000)
tbl_0496DB:
	.addr	sub_0496E1
	.addr	sub_049707
	.addr	sub_04971F

sub_0496E1:
	inc	$12,x
	lda	#$AF8C
	sta	$00,x
	lda	#$3200
	sta	$02,x
	lda	#$0013
	sta	$16,x
	lda	#$000C
	sta	$28,x
	lda	#$FFF4
	sta	$2A,x
	lda	#$0010
	sta	$06,x
	lda	#$0001
	sta	$1A,x
	rtl

sub_049707:
	lda	$E8
	and	#$00C0
	clc
	adc	#$07C0
	tay
	lda	a:$0012,y
	cmp	#$0005
	bne	loc_04973E
	inc	$12,x
	sty	$30,x
	bra	loc_04973E

sub_04971F:
	ldy	$30,x
	lda	a:$0012,y
	cmp	#$0005
	beq	loc_04972D
	dec	$12,x
	bra	loc_04973E
loc_04972D:
	clc
	lda	a:$000E,y
	adc	#$FFF6
	cmp	$0E,x
	bcc	loc_04973C
	inc	$0E,x
	bra	loc_04973E
loc_04973C:
	dec	$0E,x
loc_04973E:
	sec
	lda	$18,x
	sbc	#$1000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	lda	$BE
	bne	loc_04976E
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_04976E
	lda	#$C558
	jsl	f:sub_01CF66
	lda	$0A,x
	adc	#$0004
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_04976E:
	ldy	#$07C0
loc_049771:
	clc
	lda	a:$000A,y
	adc	#$0070
	cmp	$0A,x
	bmi	loc_04979F
	lda	a:$000A,y
	cmp	$0A,x
	bpl	loc_04979F
	sec
	lda	a:$000E,y
	sbc	$0E,x
	bpl	loc_04978E
	eor	#$FFFF
loc_04978E:
	cmp	#$000A
	bcs	loc_04979F
	lda	#$0006
	sta	a:$0012,y
	lda	#$FFFF
	sta	$06,x
	rtl
loc_04979F:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_049771
	rtl

sub_0497AB:
	lda	$16,x
	beq	loc_0497DF
	bmi	loc_0497DF
	lda	$12,x
	cmp	#$0001
	beq	loc_0497C2
	; (not executed in the CDL traces)
	cmp	#$0003
	beq	loc_0497C2
	cmp	#$0004
	beq	loc_0497C2
loc_0497C2:
	lda	$0E,x
	cmp	#$00E0
	bcs	loc_0497DF
	txa
	and	#$0040
	lsr	a
	clc
	adc	#$0010
	sta	$0A,x
	lda	#$00C3
	sta	$0E,x
	stz	$1C,x
	stz	$1E,x
	stz	$04,x
loc_0497DF:
	rts

sub_0497E0:
	clc
	lda	a:$1380
	adc	#$0010
	sta	a:$1380
	sta	a:$13C0
	rts

sub_0497EE:
	ldy	#$0200
	jsr	a:sub_0497FB
	ldy	#$0240
	jsr	a:sub_0497FB
	rts

sub_0497FB:
	lda	a:$0016,y
	beq	loc_049863
	bmi	loc_049863
	lda	a:$0032,y
	bne	loc_049863
	clc
	lda	a:$000A,y
	adc	#$0006
	cmp	$0A,x
	bmi	loc_049863
	clc
	lda	$0A,x
	adc	$28,x
	cmp	a:$000A,y
	bmi	loc_049863
	sec
	lda	a:$000E,y
	sbc	#$0028
	sta	$00
	cmp	$0E,x
	bpl	loc_049863
	sec
	lda	$0E,x
	sbc	#$0009
	cmp	$00
	bpl	loc_049863
	lda	#$2000
	ora	a:$003C,y
	sta	a:$003C,y
	txa
	sta	a:$1304,y
	lda	#$0001
	cmp	a:$0012,y
	beq	loc_049863
	sta	a:$0012,y
	clc
	lda	$0E,x
	adc	#$0023
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$001E,y
loc_049863:
	rts

sub_049864:
	ldy	#$0007
	sty	$02
	ldy	#$0038
	sty	$08
	ldy	#$EC26
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_049878:
	clc
	lda	a:$1404
	adc	a:$140C
	sta	a:$1404
	lda	f:$7E3824
	adc	a:$140E
	sta	f:$7E3824
	rts

sub_04988E:
	phx
	ldy	$34,x
	sec
	lda	#$0098
	sbc	$0E,x
	pha
	sec
	lda	#$0040
	sbc	$0A,x
	pha
	lda	a:data_05EC86,y
	tax
	pla
	sta	f:$7E3800,x
	pla
	sta	f:$7E3802,x
	plx
	rts

sub_0498AF:
	lda	$30,x
	bne	loc_0498D3
	lda	$32,x
	cmp	$0A,x
	bcs	loc_0498F7
	lda	$1A,x
	bpl	loc_0498C2
	cmp	#$FFFE
	bcc	loc_0498FE
loc_0498C2:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	loc_0498FE
loc_0498D3:
	clc
	lda	$32,x
	adc	#$0008
	cmp	$0A,x
	bcc	loc_0498F7
	lda	$1A,x
	bmi	loc_0498E6
	cmp	#$0001
	bcs	loc_0498FE
loc_0498E6:
	clc
	lda	$18,x
	adc	#$1000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	bra	loc_0498FE
loc_0498F7:
	lda	$30,x
	eor	#$0002
	sta	$30,x
loc_0498FE:
	sec
	lda	#$01A0
	sbc	$0A,x
	sta	a:$13C0
	lda	$78
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	bit	#$0008
	beq	loc_049918
	eor	#$FFFF
loc_049918:
	and	#$0007
	sta	$02
	clc
	adc	#$0000
	sta	a:$13D8
	sec
	lda	$0A,x
	sbc	#$0020
	sta	$00
	lda	a:$0796
	beq	loc_049949
	lda	a:$0716
	ora	a:$0756
	bne	loc_04994A
	lda	#$8000
	sta	a:$0796
	lda	#$4011
	sta	$16,x
	lda	#$00C8
	sta	$32,x
loc_049949:
	rts
loc_04994A:
	lda	$00
	sta	a:$078A
	sec
	lda	#$00B0
	sbc	$02
	sta	a:$078E
	lda	a:$0716
	beq	loc_04996B
	lda	$00
	sta	a:$070A
	sec
	lda	#$0030
	sbc	$02
	sta	a:$070E
loc_04996B:
	lda	a:$0756
	beq	loc_049949
	lda	$00
	sta	a:$074A
	sec
	lda	#$00C8
	sbc	$02
	sta	a:$074E
	rts

sub_04997F:
	lda	$BE
	bne	loc_0499AA
	ldy	#$0500
	jsl	f:sub_019EC1
	bcc	loc_0499AA
	lda	a:$1636
	jsl	f:sub_01CF66
	lda	#$FFF8
	sta	a:$001A,y
	lda	$0A,x
	adc	#$FFF8
	sta	a:$000A,y
	clc
	lda	$0E,x
	adc	#$FFF5
	sta	a:$000E,y
loc_0499AA:
	rts

sub_0499AB:
	clc
	lda	$36,x
	adc	#$0500
	sta	$36,x
	lda	$38,x
	adc	#$0000
	sta	$38,x
	clc
	lda	$3A,x
	adc	$36,x
	sta	$3A,x
	lda	f:$7E3801
	adc	$38,x
	sta	f:$7E3801
	sta	f:$7E3806
	cmp	#$0200
	bcc	loc_049A05
	inc	$12,x
	lda	#$4000
	sta	$18,x
	stz	$1A,x
	stz	$30,x
	lda	#$C606
	sta	a:$1636
	phx
	ldy	#$0000
	ldx	#$07C0
	jsl	f:sub_049277
	ldy	#$0004
	ldx	#$0840
	jsl	f:sub_049277
	iny
	iny
	ldx	#$0880
	jsl	f:sub_049277
	plx
	rts
loc_049A05:
	clc
	lda	$3E,x
	adc	#$0C00
	sta	$3E,x
	lda	f:$7E3803
	adc	#$0000
	sta	f:$7E3803
	sta	f:$7E3808
	clc
	lda	a:$140C
	adc	#$2000
	sta	a:$140C
	lda	a:$140E
	adc	#$0000
	sta	a:$140E
	rts

sub_049A30:
	lda	a:data_05EC8E,y
	sta	$10,x
	lda	a:data_05EC92,y
	sta	$16,x
	lda	a:data_05EC96,y
	sta	$20,x
	lda	#$0180
	sta	$0A,x
	lda	a:data_05EC9A,y
	sta	$28,x
	lda	a:data_05EC9E,y
	sta	$2A,x
	lda	#$0E00
	sta	$02,x
	rts

sub_049A54:
	lda	$0A,x
	cmp	#$00E0
	bcs	loc_049AC0
	lda	$84
	beq	loc_049AC0
	lda	a:$1638
	cmp	#$0020
	bcc	loc_049AC0
	cmp	#$0032
	bcs	loc_049AC0
	bit	#$0007
	bne	loc_049AC0
	ldy	#$06C0
	jsl	f:sub_019EC1
	bcc	loc_049AC0
	lda	$30,x
	phx
	tax
	lda	#$001F
	sta	a:$0016,y
	lda	#$006B
	sta	a:$0010,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
	lda	#$FFFD
	sta	a:$001A,y
	lda	a:data_05EBE6,x
	sta	a:$001E,y
	lda	a:data_05EBC6,x
	sta	a:$0020,y
	plx
	lda	$0A,x
	adc	#$0000
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$001A
	jsl	f:sub_00868F
loc_049AC0:
	rts

sub_049AC1:
	dec	$32,x
	bpl	loc_049AF4
	phx
	ldy	#$0000
	ldx	#$07C0
	lda	$10,x
	beq	loc_049AE2
	iny
	iny
	ldx	#$0840
	lda	$10,x
	beq	loc_049AE2
	iny
	iny
	ldx	#$0880
	lda	$10,x
	bne	loc_049AE9
loc_049AE2:
	lda	#$0073
	sta	$10,x
	sty	$30,x
loc_049AE9:
	plx
	lda	$E8
	and	#$003F
	adc	#$0048
	sta	$32,x
loc_049AF4:
	rts

sub_049AF5:
	dec	$32,x
	bpl	loc_049B31
	ldy	#$0400
	jsl	f:sub_019EC1
	bcc	loc_049B31
	lda	#$0074
	sta	a:$0010,y
	lda	$E8
	and	#$003F
	adc	#$0020
	sta	a:$000E,y
	and	#$0002
	sta	a:$0030,y
	lda	#$0100
	sta	a:$000A,y
	ldy	$84
	lda	$EA
	and	#$001F
	lda	a:data_05ECBE,y
	sta	$32,x
	dec	$34,x
	bne	loc_049B31
	inc	$12,x
loc_049B31:
	rts

sub_049B32:
	lda	$C0
	bne	loc_049B73

sub_049B36:
	ldy	#$0400
	jsl	f:sub_019EC1
	bcc	loc_049B31
	lda	#$0053
	sta	a:$0010,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$C6EB
	sta	a:$0000,y
	lda	#$3800
	sta	a:$0002,y
	lda	$E8
	and	#$0003
	adc	#$0007
	sta	a:$001A,y
	lda	$E8
	and	#$003F
	adc	#$0030
	sta	a:$000E,y
	lda	#$FFE8
	sta	a:$000A,y
loc_049B73:
	rts

sub_049B74:
	sec
	lda	$0A,x
	sbc	a:$1694
	sta	$0A,x
	cmp	#$0100
	bcc	loc_049B86
	lda	#$8000
	sta	$16,x
loc_049B86:
	sec
	lda	$0E,x
	sbc	a:$1696
	sta	$0E,x
	rts

sub_049B8F:
	lda	#$0030
	jsl	f:sub_00FD9A
	lda	$BC
	bne	loc_049BD4
	dec	$24,x
	bpl	loc_049BA4
	lda	#$8000
	sta	$16,x
	rtl
loc_049BA4:
	ldy	#$0580
	jsl	f:sub_019EC1
	bcc	loc_049BD4
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	$E8
	and	#$001F
	sta	$00
	lda	$0E,x
	sbc	$00
	sta	a:$000E,y
	lda	$EA
	and	#$0007
	pha
	adc	$0A,x
	sta	a:$000A,y
	pla
	adc	#$FFF8
	sta	a:$001A,y
loc_049BD4:
	rtl

sub_049BD5:
	dec	$38,x
	bpl	loc_049C0B
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_049C0B
	lda	#$000F
	sta	a:$0010,y
	lda	$EA
	and	#$001F
	adc	#$0040
	sta	a:$000E,y
	and	#$0001
	inc	a
	sta	a:$003A,y
	lda	$E8
	and	#$0001
	clc
	adc	#$FFFF
	sta	a:$000A,y
	lda	#$0100
	sta	$38,x
loc_049C0B:
	rts

sub_049C0C:
	ldy	$26,x
	beq	loc_049C1A
	lda	#$0030
	sta	$98
	lda	#$912A
	sta	$9A
loc_049C1A:
	lda	$06,x
	bpl	loc_049C2A
	lda	#$0006
	sta	$12,x
	lda	#$0001
	sta	$16,x
	stz	$06,x
loc_049C2A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_049C39,x
	plx
	sta	$00
	jmp	($0000)
tbl_049C39:
	.addr	sub_049C49
	.addr	sub_049C58
	.addr	sub_049C76
	.addr	sub_049CCA
	.addr	sub_049D7A
	.addr	sub_049DFC
	.addr	sub_049FEE
	.addr	sub_04A03E

sub_049C49:
	lda	#$004A
	sta	a:$1E8E
	stz	a:$13C0
	stz	a:$13D8
	inc	$12,x
	rtl

sub_049C58:
	lda	a:$13BA
	cmp	#$0004
	beq	loc_049C61
	rtl
loc_049C61:
	ldy	$84
	lda	a:data_05ECE2,y
	sta	$06,x
	jsr	a:sub_04A0A7
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	inc	$12,x
	rtl

sub_049C76:
	lda	#$0080
	sta	$0A,x
	lda	$0E,x
	bmi	loc_049C84
	cmp	#$0070
	bcs	loc_049C95
loc_049C84:
	lda	$1C,x
	clc
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	loc_049CAF
loc_049C95:
	lda	$78
	bit	#$0007
	bne	loc_049CA7
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
	sta	$30,x
	jsr	a:sub_04A298
loc_049CA7:
	lsr	$1E,x
	ror	$1C,x
	lda	$1C,x
	beq	loc_049CB9
loc_049CAF:
	inc	a:$07B8
	inc	a:$07B8
	jsr	a:sub_04A16E
	rtl
loc_049CB9:
	inc	$12,x
	lda	#$401D
	sta	$16,x
	inc	a:$07B8
	inc	a:$07B8
	jsr	a:sub_04A16E
	rtl

sub_049CCA:
	lda	$06,x
	ldy	$84
	cmp	a:data_05ECE8,y
	bcs	loc_049CDA
	lda	#$0004
	sta	$12,x
	stz	$3A,x
loc_049CDA:
	lda	$0A,x
	bmi	loc_049D26
	cmp	#$00D0
	bcc	loc_049D26
	lda	#$0055
	jsl	f:sub_00868F
	lda	a:$0216
	ora	a:$0256
	and	#$0001
	bne	loc_049CFC
	lda	#$0078
	sta	$00
	bra	loc_049D05
loc_049CFC:
	jsl	f:sub_01E860
	lda	a:$000E,y
	sta	$00
loc_049D05:
	lda	$0E,x
	bmi	loc_049D12
	cmp	$00
	bcc	loc_049D12
	ldy	#$0002
	bra	loc_049D15
loc_049D12:
	ldy	#$0000
loc_049D15:
	lda	a:data_05ECEE,y
	sta	$1C,x
	lda	a:data_05ECF2,y
	sta	$1E,x
	lda	#$FFFA
	sta	$1A,x
	stz	$18,x
loc_049D26:
	lda	$18,x
	clc
	adc	#$2000
	sta	$18,x
	lda	$1A,x
	sta	$00
	adc	#$0000
	sta	$1A,x
	eor	#$FFFF
	and	$00
	bit	#$8000
	beq	loc_049D4C
	lda	$E8
	and	#$0001
	bne	loc_049D4C
	stz	$1E,x
	stz	$1C,x
loc_049D4C:
	lda	$1A,x
	bmi	loc_049D5E
	lda	$78
	bit	#$0003
	bne	loc_049D70
	and	#$0004
	lsr	a
	lsr	a
	bra	loc_049D6B
loc_049D5E:
	lda	$78
	bit	#$0007
	bne	loc_049D70
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
loc_049D6B:
	sta	$30,x
	jsr	a:sub_04A298
loc_049D70:
	inc	a:$07B8
	inc	a:$07B8
	jsr	a:sub_04A16E
	rtl

sub_049D7A:
	lda	$3A,x
	phx
	asl	a
	tax
	lda	f:tbl_049D89,x
	plx
	sta	$00
	jmp	($0000)
tbl_049D89:
	.addr	sub_049D8D
	.addr	sub_049DC4

sub_049D8D:
	stz	$1E,x
	stz	$1C,x
	lda	#$FFFA
	sta	$1A,x
	stz	$18,x
	lda	$0A,x
	adc	#$FFE0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$003F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_049DC2
	lda	#$FFFD
	sta	a:$001E,y
loc_049DC2:
	inc	$3A,x

sub_049DC4:
	lda	$0A,x
	bmi	loc_049DDE
	cmp	#$0048
	bcc	loc_049DDE
	lda	$18,x
	clc
	adc	#$8000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	bmi	loc_049DF8
loc_049DDE:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$00D0
	sta	a:$07B6
	lda	#$01F2
	sta	a:$07B8
	inc	$12,x
	stz	$3A,x
	stz	$24,x
loc_049DF8:
	jsr	a:sub_04A16E
	rtl

sub_049DFC:
	jsr	a:sub_049E03
	jsr	a:sub_04A16E
	rtl

sub_049E03:
	lda	$3A,x
	phx
	asl	a
	tax
	lda	f:tbl_049E12,x
	plx
	sta	$00
	jmp	($0000)
tbl_049E12:
	.addr	sub_049E7A
	.addr	sub_049E8F
	.addr	sub_049ED6
	.addr	sub_049F01
	.addr	sub_049F1C
	.addr	sub_049F21
	.addr	sub_049F2F
	.addr	sub_049F7B
	.addr	sub_049F96
	.addr	sub_049FC6

sub_049E26:
	ldy	#$0000
	lda	a:$07B6
	cmp	#$00D0
	bne	loc_049E34
	iny
	bra	loc_049E4D
loc_049E34:
	clc
	adc	#$0004
	sta	a:$07B6
	and	#$01FF
	clc
	sbc	#$00D0
	cmp	#$0008
	bcs	loc_049E4D
	; (not executed in the CDL traces)
	lda	#$00D0
	sta	a:$07B6
loc_049E4D:
	lda	a:$07B8
	cmp	#$01F2
	bne	loc_049E58
	iny
	bra	loc_049E71
loc_049E58:
	sec
	sbc	#$0001
	sta	a:$07B8
	and	#$01FF
	clc
	sbc	#$01F2
	cmp	#$0002
	bcs	loc_049E71
	lda	#$01F2
	sta	a:$07B8
loc_049E71:
	cpy	#$0002
	beq	loc_049E78
	clc
	rts
loc_049E78:
	sec
	rts

sub_049E7A:
	jsr	a:sub_049E26
	bcc	loc_049E8B
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	$24,x
	inc	$3A,x
loc_049E8B:
	jsr	a:sub_04A2B2
	rts

sub_049E8F:
	lda	$0A,x
	bmi	loc_049EC9
	cmp	#$0048
	bcc	loc_049EC9
	lda	$18,x
	sec
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	lda	$0E,x
	bmi	loc_049EC5
	cmp	#$0010
	bcc	loc_049EC1
	lda	$1C,x
	sec
	sbc	#$2000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bra	loc_049EC5
loc_049EC1:
	stz	$1C,x
	stz	$1E,x
loc_049EC5:
	jsr	a:sub_04A2C5
	rts
loc_049EC9:
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$24,x
	inc	$3A,x
	rts

sub_049ED6:
	lda	#$0000
	sta	f:$7EE823
	lda	#$0074
	sta	f:$7EE827
	lda	$0E,x
	sta	f:$7EE825
	lda	#$000D
	sta	$16,x
	lda	#$003D
	jsl	f:sub_00868F
	stz	$24,x
	inc	$3A,x
	lda	#$0001
	jsr	a:sub_04A298
	rts

sub_049F01:
	jsr	a:sub_04A2D2
	lda	f:$7EE823
	cmp	#$0002
	bcc	loc_049F1B
	lda	#$0180
	sta	$0E,x
	lda	#$0078
	sta	$0A,x
	inc	$3A,x
	stz	$24,x
loc_049F1B:
	rts

sub_049F1C:
	stz	$46
	inc	$3A,x
	rts

sub_049F21:
	inc	$24,x
	lda	$24,x
	cmp	#$0030
	bcc	loc_049F2E
	inc	$3A,x
	stz	$24,x
loc_049F2E:
	rts

sub_049F2F:
	lda	a:$0216
	ora	a:$0256
	and	#$0001
	bne	loc_049F41
	lda	#$0078
	sta	$00
	bra	loc_049F4A
loc_049F41:
	jsl	f:sub_01E860
	lda	a:$000E,y
	sta	$00
loc_049F4A:
	lda	$E8
	and	#$000F
	sta	$02
	lda	$00
	sbc	$02
	sbc	#$0032
	sta	$0E,x
	lda	#$0090
	sta	$0A,x
	lda	#$0080
	sta	a:$07B6
	lda	#$0040
	sta	a:$07B8
	inc	$3A,x
	lda	#$0000
	sta	f:$7EE823
	lda	$0E,x
	sta	f:$7EE825
	rts

sub_049F7B:
	jsr	a:sub_04A2E9
	lda	f:$7EE823
	cmp	#$0002
	bcc	loc_049F95
	lda	#$401D
	sta	$16,x
	stz	$46
	stz	$24,x
	inc	$3A,x
	jsr	a:sub_04A2B2
loc_049F95:
	rts

sub_049F96:
	inc	$24,x
	lda	$24,x
	cmp	#$0008
	bcc	loc_049FC2
	jsl	f:sub_01E860
	lda	$0E,x
	clc
	adc	#$0032
	cmp	a:$000E,y
	bcs	loc_049FB4
	lda	#$0090
	sta	a:$07B6
loc_049FB4:
	stz	a:$07B8
	lda	#$FFFA
	sta	$1A,x
	stz	$18,x
	stz	$24,x
	inc	$3A,x
loc_049FC2:
	jsr	a:sub_04A2C5
	rts

sub_049FC6:
	lda	$0A,x
	bmi	loc_049FE2
	cmp	#$0040
	bcs	loc_049FE2
	; (not executed in the CDL traces)
	lda	$18,x
	clc
	adc	#$1F40
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	jsr	a:sub_04A2C5
	rts
loc_049FE2:
	stz	$18,x
	stz	$1A,x
	stz	$24,x
	stz	$3A,x
	jsr	a:sub_04A2B2
	rts

sub_049FEE:
	stz	$46
	lda	#$8000
	sta	a:$0356
	sta	a:$0316
	phx
	stz	$00
loc_049FFC:
	lda	$00
	asl	a
	tay
	lda	a:data_05ECFC,y
	tax
	lda	#$0001
	sta	$12,x
	sta	$16,x
	inc	$00
	lda	$00
	cmp	#$0010
	bcc	loc_049FFC
	plx
	lda	#$0025
	sta	a:$0790
	lda	#$0001
	sta	a:$0792
	lda	#$0001
	sta	a:$0796
	lda	#$0002
	jsr	a:sub_04A298
	lda	#$FFFF
	sta	$1E,x
	stz	$1A,x
	stz	$18,x
	stz	$18,x
	inc	$12,x
	jsr	a:sub_04A1B9
	rtl

sub_04A03E:
	lda	$0E,x
	bmi	loc_04A047
	cmp	#$0140
	bcs	loc_04A088
loc_04A047:
	lda	$1C,x
	clc
	adc	#$1000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	jsl	f:sub_00FD92
	lda	$0A,x
	adc	#$FFE0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$003F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04A084
	lda	#$FFFD
	sta	a:$001E,y
loc_04A084:
	jsr	a:sub_04A1B9
	rtl
loc_04A088:
	lda	#$0002
	sta	a:$13BA
	lda	#$0049
	sta	a:$1E8E
	stz	a:$13C0
	stz	a:$13D8
	lda	#$0082
	jsl	f:sub_00868F
	lda	#$8000
	sta	$16,x
	rtl

sub_04A0A7:
	lda	#$000D
	sta	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$FFC0
	sta	$0E,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	stz	$30,x
	lda	#$0053
	sta	a:$0350
	lda	#$003D
	sta	a:$0356
	lda	#$0012
	sta	a:$0368
	lda	#$FFC0
	sta	a:$036A
	lda	#$0053
	sta	a:$0310
	lda	#$003D
	sta	a:$0316
	lda	#$0053
	sta	a:$0790
	lda	#$003D
	sta	a:$0796
	lda	#$C46D
	sta	a:$0780
	lda	#$3600
	sta	a:$0782
	lda	#$0008
	sta	a:$07A8
	lda	#$FFF8
	sta	a:$07AA
	lda	#$0080
	sta	a:$07B6
	lda	#$0010
	sta	a:$07B8
	phx
	lda	#$0780
	sta	$00
	ldy	#$0000
loc_04A11F:
	lda	a:data_05ECFC,y
	tax
	lda	#$0025
	sta	$10,x
	lda	#$003C
	sta	$16,x
	stz	$12,x
	cpy	#$0010
	bcs	loc_04A139
	lda	#$C46D
	bra	loc_04A13C
loc_04A139:
	lda	#$C472
loc_04A13C:
	sta	$00,x
	lda	#$3600
	sta	$02,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	$00
	sta	$30,x
	stz	$32,x
	lda	#$0080
	sta	$36,x
	lda	#$0010
	sta	$38,x
	stx	$00
	iny
	iny
	cpy	#$0020
	bcc	loc_04A11F
	plx
	lda	#$008D
	sta	a:$0390
	rts

sub_04A16E:
	lda	$0A,x
	sec
	sbc	#$0028
	sta	a:$034A
	lda	$0E,x
	clc
	adc	#$0030
	sta	a:$034E
	lda	$0A,x
	sec
	sbc	#$0050
	sta	a:$030A
	lda	$0E,x
	clc
	adc	#$0010
	sta	a:$030E
	phy
	lda	$30,x
	and	#$0001
	asl	a
	tay
	lda	a:data_05ED20,y
	ply
	sta	a:$032A
	lda	#$0040
	sta	a:$0328
	lda	$0A,x
	clc
	adc	#$FFC8
	sta	a:$078A
	lda	$0E,x
	clc
	adc	#$0014
	sta	a:$078E

sub_04A1B9:
	lda	#$00B8
	sec
	sbc	$0A,x
	and	#$00FF
	sta	a:$13C0
	lda	#$0175
	sec
	sbc	$0E,x
	and	#$01FF
	sta	a:$13D8
	rts

sub_04A1D2:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04A1E1,x
	plx
	sta	$00
	jmp	($0000)
tbl_04A1E1:
	.addr	sub_04A1FC
	.addr	sub_04A250
	.addr	sub_04A27A

sub_04A1E7:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04A1F6,x
	plx
	sta	$00
	jmp	($0000)
tbl_04A1F6:
	.addr	sub_04A211
	.addr	sub_04A250
	.addr	sub_04A27A

sub_04A1FC:
	lda	a:$0036,x
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:data_05ED24,y
	sta	$00,x

sub_04A211:
	stx	$00
	lda	$30,x
	tay
	lda	a:$0038,y
	sta	$38,x
	lda	a:$0036,y
	clc
	adc	$38,x
	sta	$36,x
	and	#$01FE
	tax
	lda	f:data_058E9A,x
	bmi	loc_04A230
	lsr	a
	bra	loc_04A232
loc_04A230:
	sec
	ror	a
loc_04A232:
	pha
	lda	f:data_058F1A,x
	bmi	loc_04A23C
	lsr	a
	bra	loc_04A23E
loc_04A23C:
	sec
	ror	a
loc_04A23E:
	clc
	adc	a:$000A,y
	ldx	$00
	sta	$0A,x
	pla
	clc
	adc	a:$000E,y
	ldx	$00
	sta	$0E,x
	rtl

sub_04A250:
	lda	#$FFFE
	sta	$1E,x
	lda	$E8
	sta	$1C,x
	asl	a
	sta	$18,x
	lda	$E8
	and	#$0001
	sec
	sbc	#$0001
	sta	$1A,x
	lda	$E8
	eor	#$CA63
	adc	$3A
	sta	$E8
	stz	$24,x
	lda	#$0001
	sta	$16,x
	inc	$12,x
	rtl

sub_04A27A:
	lda	$1C,x
	clc
	adc	#$1000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcc	loc_04A297
	lda	#$8000
	sta	$16,x
loc_04A297:
	rtl

sub_04A298:
	asl	a
	tay
	lda	a:data_05ED34,y
	tay
	lda	#$0003
	sta	$02
	lda	#$0030
	sta	$08
	lda	#$4D0C
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04A2B2:
	lda	$78
	bit	#$0007
	bne	loc_04A2C4
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
loc_04A2BF:
	sta	$30,x
	jsr	a:sub_04A298
loc_04A2C4:
	rts

sub_04A2C5:
	lda	$78
	bit	#$0001
	bne	loc_04A2C4
	and	#$0002
	lsr	a
	bra	loc_04A2BF

sub_04A2D2:
	lda	f:$7EE823
	phx
	asl	a
	tax
	lda	f:tbl_04A2E3,x
	plx
	sta	$00
	jmp	($0000)
tbl_04A2E3:
	.addr	sub_04A300
	.addr	sub_04A32A
	.addr	sub_04A349

sub_04A2E9:
	lda	f:$7EE823
	phx
	asl	a
	tax
	lda	f:tbl_04A2FA,x
	plx
	sta	$00
	jmp	($0000)
tbl_04A2FA:
	.addr	sub_04A300
	.addr	sub_04A313
	.addr	sub_04A349

sub_04A300:
	jsr	a:sub_04A34A
	jsr	a:sub_04A374
	lda	#$0001
	sta	f:$7EE823
	lda	#$000F
	sta	$46
	rts

sub_04A313:
	jsr	a:sub_04A374
	lda	f:$7EE827
	clc
	adc	#$0004
	sta	f:$7EE827
	bmi	loc_04A341
	cmp	#$0075
	bcs	loc_04A341
	rts

sub_04A32A:
	jsr	a:sub_04A374
	lda	f:$7EE827
	sec
	sbc	#$0004
	sta	f:$7EE827
	bmi	loc_04A341
	cmp	#$0001
	bcc	loc_04A341
	rts
loc_04A341:
	lda	#$0002
	sta	f:$7EE823
	rts

sub_04A349:
	; (not executed in the CDL traces)
	rts

sub_04A34A:
	phx
	ldx	#$0000
	lda	#$00F0
	clc
	adc	a:$13D8
	and	#$01FF
loc_04A358:
	sta	f:$7EE880,x
	dec	a
	and	#$01FF
	inx
	inx
	cpx	#$03C0
	bcc	loc_04A358
	lda	#$01E0
	clc
	adc	#$E880
	sta	f:$7EE829
	plx
	rts

sub_04A374:
	jsr	a:sub_04A37A
	jmp	a:loc_04A40A

sub_04A37A:
	lda	f:$7EE827
	lsr	a
	sta	$00
	lda	f:$7EE825
	sec
	sbc	$00
	cmp	#$0002
	bmi	loc_04A399
	bcc	loc_04A399
	cmp	#$00F0
	bcc	loc_04A39C
	; (not executed in the CDL traces)
	lda	#$00F0
	bra	loc_04A39C
loc_04A399:
	lda	#$0002
loc_04A39C:
	sta	$02
	lsr	a
	pha
	adc	#$0000
	sta	f:$7EE82B
	pla
	sta	f:$7EE82D
	lda	f:$7EE827
	clc
	adc	$02
	sta	$04
	cmp	#$00F0
	bcc	loc_04A3C4
	lda	#$00F0
	sta	$04
	sec
	sbc	$02
	bra	loc_04A3D0
loc_04A3C4:
	lda	f:$7EE827
	cmp	#$0002
	bcs	loc_04A3D0
	lda	#$0002
loc_04A3D0:
	lsr	a
	pha
	adc	#$0000
	sta	f:$7EE82F
	pla
	sta	f:$7EE831
	lda	#$00F0
	sec
	sbc	$04
	bpl	loc_04A3E9
	; (not executed in the CDL traces)
	lda	#$0000
loc_04A3E9:
	cmp	#$0080
	bcc	loc_04A3FE
	sec
	sbc	#$007F
	sta	f:$7EE835
	lda	#$007F
	sta	f:$7EE833
	rts
loc_04A3FE:
	sta	f:$7EE833
	lda	#$0000
	sta	f:$7EE835
	rts
loc_04A40A:
	lda	f:$7EE82B
	ora	#$0080
	sta	f:$7EE800
	lda	f:$7EE82B
	clc
	adc	f:$7EE82D
	asl	a
	sta	$00
	lda	f:$7EE829
	sec
	sbc	$00
	sta	f:$7EE801
	lda	f:$7EE82D
	ora	#$0080
	sta	f:$7EE803
	lda	f:$7EE82D
	asl	a
	sta	$00
	lda	f:$7EE829
	sec
	sbc	$00
	sta	f:$7EE804
	lda	f:$7EE82F
	sta	f:$7EE806
	lda	f:$7EE829
	sta	f:$7EE807
	lda	f:$7EE831
	sta	f:$7EE809
	lda	f:$7EE829
	sta	f:$7EE80A
	lda	f:$7EE833
	ora	#$0080
	sta	f:$7EE80C
	lda	f:$7EE829
	sta	f:$7EE80D
	lda	f:$7EE835
	ora	#$0080
	sta	f:$7EE80F
	lda	f:$7EE833
	asl	a
	clc
	adc	f:$7EE829
	sta	f:$7EE810
	lda	#$0000
	sta	f:$000012
	rts

sub_04A49D:
	lda	#$0030
	jsl	f:sub_04AA0D
	lda	$06,x
	bpl	loc_04A4AB
	brl	loc_04A626
loc_04A4AB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04A4BA,x
	plx
	sta	$00
	jmp	($0000)
tbl_04A4BA:
	.addr	sub_04A4CE
	.addr	sub_04A4EC
	.addr	sub_04A50D
	.addr	sub_04A54E
	.addr	sub_04A5D2
	.addr	sub_04A606
	.addr	sub_04A58B
	.addr	sub_04A64C
	.addr	sub_04A694
	.addr	sub_04A6A9

sub_04A4CE:
	ldy	$84
	lda	a:data_05ED5E,y
	sta	$06,x
	lda	#$004A
	sta	a:$1E8E
	stz	$30,x
	stz	$32,x
	stz	$34,x
	jsr	a:sub_04A810
	jsr	a:sub_04A8AF
	lda	#$0001
	sta	$12,x

sub_04A4EC:
	lda	a:$13BA
	cmp	#$0004
	beq	loc_04A4F5
	rtl
loc_04A4F5:
	lda	#$0006
	jsl	f:sub_01F6AF
loc_04A4FC:
	lda	#$0044
	jsl	f:sub_00868F
	lda	#$0040
	sta	$24,x
	lda	#$0002
	sta	$12,x

sub_04A50D:
	dec	$24,x
	bne	loc_04A518
	lda	#$0044
	jsl	f:sub_00868F
loc_04A518:
	lda	$78
	lsr	a
	bcs	loc_04A52A
	lda	$0E,x
	inc	a
	sta	$0E,x
	cmp	#$0020
	bpl	loc_04A537
	jsr	a:sub_04A8AF
loc_04A52A:
	lda	#$0004
	sta	a:$1662
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	rtl
loc_04A537:
	lda	#$401D
	sta	$16,x
	lda	#$0024
	sta	$0E,x
	jsr	a:sub_04A8AF
	lda	#$0200
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_04A54E:
	lda	a:$0410
	cmp	#$0075
	beq	loc_04A55E
	lda	a:$0450
	cmp	#$0075
	bne	loc_04A586
loc_04A55E:
	dec	$24,x
	bpl	loc_04A573
	lda	a:$0430
	ora	a:$0470
	bne	loc_04A56D
	brl	loc_04A5CD
loc_04A56D:
	stz	$24,x
	stz	$38,x
	bra	loc_04A576
loc_04A573:
	jsr	a:sub_04A6B8
loc_04A576:
	jsr	a:sub_04A6CA
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	lda	#$0002
	sta	a:$1662
	rtl
loc_04A586:
	lda	#$0006
	sta	$12,x

sub_04A58B:
	jsr	a:sub_04A74A
	ldy	$84
	lda	$78
	and	a:data_05ED64,y
	bne	loc_04A5AC
	lda	$E8
	bit	#$0001
	bne	loc_04A5A6
	ldy	#$0300
	jsr	a:sub_04A9BD
	bra	loc_04A5AC
loc_04A5A6:
	ldy	#$0300
	jsr	a:sub_04A9E5
loc_04A5AC:
	ldy	$84
	lda	$78
	and	a:data_05ED6A,y
	bne	loc_04A5BA
	lda	#$0030
	sta	$36,x
loc_04A5BA:
	ldy	#$0300
	jsr	a:sub_04A7D1
	jsr	a:sub_04A93B
	jsr	a:sub_04A907
	lda	#$0002
	sta	a:$1662
	rtl
loc_04A5CD:
	lda	#$0004
	sta	$12,x

sub_04A5D2:
	lda	$78
	lsr	a
	bcs	loc_04A5E4
	lda	$0E,x
	dec	a
	sta	$0E,x
	cmp	#$FFF0
	bmi	loc_04A5F4
	jsr	a:sub_04A8AF
loc_04A5E4:
	lda	#$0004
	sta	a:$1662
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	jsr	a:sub_04A997
	rtl
loc_04A5F4:
	ldy	#$0700
	jsr	a:sub_04A9A8
	lda	#$0030
	sta	$36,x
	sta	$24,x
	lda	#$0005
	sta	$12,x

sub_04A606:
	dec	$24,x
	bpl	loc_04A60D
	brl	loc_04A4FC
loc_04A60D:
	lda	#$0004
	sta	a:$1662
	jsr	a:sub_04A74A
	ldy	#$0700
	jsr	a:sub_04A7D1
	jsr	a:sub_04A93B
	jsr	a:sub_04A907
	jsr	a:sub_04A997
	rtl
loc_04A626:
	stz	$06,x
	stz	$16,x
	lda	#$8000
	sta	a:$0316
	sta	a:$0356
	lda	#$FFFF
	sta	a:$0386
	sta	a:$03C6
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	lda	#$0300
	sta	$24,x
	lda	#$0007
	sta	$12,x

sub_04A64C:
	dec	$24,x
	bmi	loc_04A681
	jsl	f:sub_00FD92
	lda	#$0004
	sta	a:$1662
	lda	#$0040
	sta	$00
	lda	#$0040
	sta	$02
	lda	#$007F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04A680
	lda	#$FFFC
	sta	a:$001E,y
loc_04A680:
	rtl
loc_04A681:
	lda	#$0059
	jsl	f:sub_00868F
	lda	#$0080
	sta	$24,x
	lda	#$0004
	sta	$22,x
	inc	$12,x

sub_04A694:
	lda	$22,x
	beq	loc_04A69D
	jsr	a:sub_04A95D
	dec	$22,x
loc_04A69D:
	dec	$24,x
	bmi	loc_04A6A2
	rtl
loc_04A6A2:
	lda	#$0003
	sta	$22,x
	inc	$12,x

sub_04A6A9:
	jsr	a:sub_04A97A
	dec	$22,x
	bne	loc_04A6B7
	lda	#$008A
	sta	$10,x
	stz	$12,x
loc_04A6B7:
	rtl

sub_04A6B8:
	ldy	$84
	lda	$E8
	and	a:data_05ED70,y
	cmp	#$0008
	bcc	loc_04A6C7
	lda	#$0000
loc_04A6C7:
	sta	$38,x
	rts

sub_04A6CA:
	jsr	a:sub_04A6D0
	jmp	a:loc_04A70D

sub_04A6D0:
	lda	a:$0410
	cmp	#$0075
	bne	loc_04A70C
	lda	a:$0430
	bne	loc_04A70C
	lda	a:$0474
	bne	loc_04A70C
	lda	$38,x
	bit	#$0001
	beq	loc_04A70C
	bit	#$0004
	beq	loc_04A700
	lda	a:$0470
	bne	loc_04A70C
	lda	#$0002
	sta	a:$0430
	stz	a:$0432
	sta	a:$0434
	rts
loc_04A700:
	lda	#$0002
	sta	a:$0430
	stz	a:$0432
	stz	a:$0434
loc_04A70C:
	rts
loc_04A70D:
	lda	a:$0450
	cmp	#$0075
	bne	loc_04A749
	lda	a:$0470
	bne	loc_04A749
	lda	a:$0434
	bne	loc_04A749
	lda	$38,x
	bit	#$0002
	beq	loc_04A749
	bit	#$0004
	beq	loc_04A73D
	lda	a:$0430
	bne	loc_04A749
	lda	#$0002
	sta	a:$0470
	sta	a:$0472
	sta	a:$0474
	rts
loc_04A73D:
	lda	#$0002
	sta	a:$0470
	sta	a:$0472
	stz	a:$0474
loc_04A749:
	rts

sub_04A74A:
	jsr	a:sub_04A751
	jsr	a:sub_04A77A
	rts

sub_04A751:
	lda	a:$0390
	cmp	#$0053
	bne	loc_04A779
	lda	a:$0386
	bpl	loc_04A769
	lda	#$8006
	sta	$30,x
	ldy	#$0380
	jmp	a:loc_04A7B3
loc_04A769:
	ldy	#$0200
	lda	a:$1F8A
	bne	loc_04A774
	; (not executed in the CDL traces)
	ldy	#$0240
loc_04A774:
	jsr	a:sub_04A7A3
	sta	$30,x
loc_04A779:
	rts

sub_04A77A:
	lda	a:$03D0
	cmp	#$0053
	bne	loc_04A7A2
	lda	a:$03C6
	bpl	loc_04A792
	lda	#$8006
	sta	$32,x
	ldy	#$03C0
	jmp	a:loc_04A7B3
loc_04A792:
	ldy	#$0240
	lda	a:$1FCA
	bne	loc_04A79D
	ldy	#$0200
loc_04A79D:
	jsr	a:sub_04A7A3
	sta	$32,x
loc_04A7A2:
	rts

sub_04A7A3:
	lda	a:$1312,y
	asl	a
	asl	a
	asl	a
	asl	a
	xba
	and	#$000E
	tay
	lda	a:data_05ED76,y
	rts
loc_04A7B3:
	lda	#$0041
	jsl	f:sub_00868F
	lda	#$FFFF
	sta	a:$001E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001A,y
	lda	#$C4CE
	jsl	f:sub_01CF66
	rts

sub_04A7D1:
	lda	$36,x
	beq	loc_04A7E9
	cmp	#$0020
	bne	loc_04A7DD
	jsr	a:sub_04A7EA
loc_04A7DD:
	ldy	#$8000
	dec	$36,x
	beq	loc_04A7E7
	ldy	#$8002
loc_04A7E7:
	sty	$34,x
loc_04A7E9:
	rts

sub_04A7EA:
	jsl	f:sub_019EAE
	bcs	loc_04A80F
	lda	#$0021
	sta	a:$0010,y
	lda	$E8
	and	#$0080
	ora	#$0040
	sta	a:$0004,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	#$0048
	sta	a:$000E,y
loc_04A80F:
	rts

sub_04A810:
	lda	#$0001
	sta	$16,x
	lda	#$00FA
	sta	$0A,x
	lda	#$FFA0
	sta	$0E,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$0053
	sta	a:$0310
	lda	#$003D
	sta	a:$0316
	lda	#$0030
	sta	a:$0328
	lda	#$FFC0
	sta	a:$032A
	lda	#$0053
	sta	a:$0350
	lda	#$003D
	sta	a:$0356
	lda	#$0030
	sta	a:$0368
	lda	#$FFC0
	sta	a:$036A
	lda	#$0053
	sta	a:$0390
	ldy	$84
	lda	a:data_05ED86,y
	sta	a:$0386
	lda	#$4011
	sta	a:$0396
	lda	#$000C
	sta	a:$03A8
	lda	#$FFF4
	sta	a:$03AA
	lda	#$0053
	sta	a:$03D0
	ldy	$84
	lda	a:data_05ED86,y
	sta	a:$03C6
	lda	#$4011
	sta	a:$03D6
	lda	#$000C
	sta	a:$03E8
	lda	#$FFF4
	sta	a:$03EA
	lda	#$0075
	sta	a:$0410
	stz	a:$0432
	lda	#$0075
	sta	a:$0450
	lda	#$0002
	sta	a:$0472
	rts

sub_04A8AF:
	stz	a:$13C0
	lda	#$0124
	sec
	sbc	$0E,x
	and	#$01FF
	sta	a:$13D8
	lda	$0A,x
	sec
	sbc	#$0074
	sta	a:$030A
	lda	$0E,x
	clc
	adc	#$0018
	sta	a:$030E
	lda	$0A,x
	clc
	adc	#$0048
	sta	a:$034A
	lda	$0E,x
	clc
	adc	#$0018
	sta	a:$034E
	lda	$0A,x
	sec
	sbc	#$0006
	sta	a:$038A
	lda	$0E,x
	clc
	adc	#$0020
	sta	a:$038E
	lda	$0A,x
	clc
	adc	#$0006
	sta	a:$03CA
	lda	$0E,x
	clc
	adc	#$0020
	sta	a:$03CE
	rts

sub_04A907:
	jsr	a:sub_04A90D
	jmp	a:loc_04A924

sub_04A90D:
	lda	$30,x
	bpl	loc_04A923
	and	#$0006
	sta	$30,x
	tay
	lda	a:data_05ED8C,y
	sta	$00
	lda	#$4C8C
	jsl	f:sub_00FE76
loc_04A923:
	rts
loc_04A924:
	lda	$32,x
	bpl	loc_04A93A
	and	#$0006
	sta	$32,x
	tay
	lda	a:data_05ED94,y
	sta	$00
	lda	#$4C90
	jsl	f:sub_00FE76
loc_04A93A:
	rts

sub_04A93B:
	lda	$34,x
	bpl	loc_04A95C
	and	#$0002
	sta	$34,x
	tay
	lda	a:data_05ED9C,y
	tay
	lda	#$0002
	sta	$02
	lda	#$0020
	sta	$08
	lda	#$4D0C
	phx
	jsl	f:sub_00FEA3
	plx
loc_04A95C:
	rts

sub_04A95D:
	lda	$22,x
	asl	a
	tay
	lda	a:data_05EDB6,y
	pha
	lda	#$0004
	sta	$02
	lda	#$0020
	sta	$08
	lda	a:data_05EDAE,y
	ply
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04A97A:
	lda	$22,x
	asl	a
	tay
	lda	a:data_05EDDC,y
	pha
	lda	#$0008
	sta	$02
	lda	#$0040
	sta	$08
	lda	a:data_05EDD6,y
	ply
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04A997:
	lda	$78
	bit	#$001F
	bne	loc_04A9A7
	lda	#$0010
	sta	a:$043A
	sta	a:$047A
loc_04A9A7:
	rts

sub_04A9A8:
	lda	a:$0410
	cmp	#$0075
	beq	loc_04A9B2
	bra	sub_04A9BD
loc_04A9B2:
	lda	a:$0450
	cmp	#$0075
	beq	loc_04A9BC
	; (not executed in the CDL traces)
	bra	sub_04A9E5
loc_04A9BC:
	rts

sub_04A9BD:
	jsl	f:sub_019EAE
	bcs	loc_04A9E4
	lda	#$0024
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	$0A,x
	clc
	adc	#$FF97
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	#$0034
	sta	a:$000E,y
loc_04A9E4:
	rts

sub_04A9E5:
	jsl	f:sub_019EAE
	bcs	loc_04AA0C
	lda	#$0024
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	$0A,x
	clc
	adc	#$005E
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	#$0034
	sta	a:$000E,y
loc_04AA0C:
	rts

sub_04AA0D:
	ldy	$26,x
	beq	loc_04AA18
	sta	$98
	lda	#$912A
	sta	$9A
loc_04AA18:
	rtl

sub_04AA19:
	lda	$06,x
	bpl	loc_04AA24
	stz	$06,x
	lda	#$0008
	sta	$12,x
loc_04AA24:
	lda	$26,x
	beq	loc_04AA32
	lda	#$912A
	sta	$9A
	lda	#$0050
	sta	$98
loc_04AA32:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04AA41,x
	plx
	sta	$00
	jmp	($0000)
tbl_04AA41:
	.addr	sub_04AA55
	.addr	sub_04AA80
	.addr	sub_04AA99
	.addr	sub_04AA90
	.addr	sub_04AAC0
	.addr	sub_04AB0C
	.addr	sub_04AB1A
	.addr	sub_04AB23
	.addr	sub_04AB29
	.addr	sub_04AB5C

sub_04AA55:
	lda	#$001F
	sta	$16,x
	ldy	$84
	lda	a:data_05EE14,y
	sta	$06,x
	lda	#$0020
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	inc	$12,x
	rtl

sub_04AA80:
	inc	$24,x
	lda	$24,x
	ldy	$84
	cmp	a:data_05EE28,y
	bcc	loc_04AA8F
	stz	$24,x
	inc	$12,x
loc_04AA8F:
	rtl

sub_04AA90:
	lda	#$0000
	jsr	a:sub_04ABA3
	inc	$12,x
	rtl

sub_04AA99:
	lda	$24,x
	and	#$0007
	bne	loc_04AAB2
	lda	$24,x
	and	#$0008
	bne	loc_04AAAC
	lda	#$0000
	bra	loc_04AAAF
loc_04AAAC:
	lda	#$0001
loc_04AAAF:
	jsr	a:sub_04ABA3
loc_04AAB2:
	inc	$24,x
	lda	$24,x
	cmp	#$001E
	bcc	loc_04AABF
	stz	$24,x
	inc	$12,x
loc_04AABF:
	rtl

sub_04AAC0:
	stz	$30,x
loc_04AAC2:
	jsl	f:sub_019EAB
	bcs	loc_04AB0B
	lda	#$0062
	sta	a:$0010,y
	lda	$0A,x
	clc
	adc	#$0008
	sta	a:$000A,y
	lda	$0E,x
	sec
	sbc	#$0008
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0008,y
	sta	a:$000C,y
	lda	$30,x
	sta	a:$0030,y
	inc	$30,x
	lda	$30,x
	cmp	#$0003
	bcc	loc_04AAC2
	inc	$12,x
loc_04AB0B:
	rtl

sub_04AB0C:
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcc	loc_04AB19
	stz	$24,x
	inc	$12,x
loc_04AB19:
	rtl

sub_04AB1A:
	lda	#$0001
	jsr	a:sub_04ABA3
	inc	$12,x
	rtl

sub_04AB23:
	lda	#$0001
	sta	$12,x
	rtl

sub_04AB29:
	lda	#$0002
	jsr	a:sub_04ABA3
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$0003
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	lda	#$C558
	sta	$20,x
	stz	$04,x
	stz	$22,x
	lda	$0A,x
	clc
	adc	#$0008
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	#$0008
	sta	$0E,x
	inc	$12,x
	rtl

sub_04AB5C:
	lda	$20,x
	bne	loc_04AB69
	lda	#$8000
	sta	$16,x
	stz	$00,x
	stz	$10,x
loc_04AB69:
	rtl

sub_04AB6A:
	lda	$0A,x
	clc
	adc	#$0010
	clc
	adc	a:$1380
	sta	$02
	and	#$00E0
	lsr	a
	lsr	a
	lsr	a
	sta	$00
	lda	$0E,x
	sec
	sbc	#$0010
	clc
	adc	a:$1398
	and	#$00E0
	asl	a
	asl	a
	clc
	adc	$00
	sta	$00
	lda	$02
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4000
	clc
	adc	$00
	sta	$00
	rts

sub_04ABA3:
	asl	a
	tay
	lda	#$0001
	sta	$02
	lda	#$0008
	sta	$08
	lda	a:data_05EE1C,y
	tay
	jsr	a:sub_04AB6A
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04ABBD:
	lda	$06,x
	bpl	loc_04ABC6
	lda	#$0007
	sta	$12,x
loc_04ABC6:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04ABD5,x
	plx
	sta	$00
	jmp	($0000)
tbl_04ABD5:
	.addr	sub_04ABE7
	.addr	sub_04AC30
	.addr	sub_04AC3E
	.addr	sub_04AC30
	.addr	sub_04AC4F
	.addr	sub_04AC92
	.addr	sub_04ACAC
	.addr	sub_04ACC0
	.addr	sub_04ACDF

sub_04ABE7:
	lda	#$001F
	sta	$16,x
	lda	#$3600
	sta	$02,x
	ldy	$84
	lda	a:data_05EE30,y
	sta	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	$30,x
	asl	a
	tay
	lda	a:data_05EE38,y
	sta	$18,x
	lda	a:data_05EE3E,y
	sta	$1A,x
	lda	a:data_05EE44,y
	sta	$1C,x
	lda	a:data_05EE4A,y
	sta	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	lda	#$EE50
	sta	$20,x
	stz	$04,x
	stz	$22,x
	inc	$12,x
	rtl

sub_04AC30:
	inc	$24,x
	lda	$24,x
	cmp	#$003C
	bcc	loc_04AC4E
	stz	$24,x
	inc	$12,x
	rtl

sub_04AC3E:
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$24,x
	inc	$12,x
loc_04AC4E:
	rtl

sub_04AC4F:
	lda	$0A,x
	sta	$00
	lda	$0E,x
	sta	$02
	jsl	f:sub_01E860
	sec
	lda	a:$1312,y
	sbc	$00
	sta	$08
	sec
	lda	a:$1314,y
	sbc	$02
	sta	$0A
	jsl	f:sub_1DABA0
	lsr	a
	lsr	a
	and	#$00FE
	ldy	$84
	clc
	adc	a:data_05ABA5,y
	tay
	lda	a:$0000,y
	sta	$1E,x
	lda	a:$0010,y
	sta	$1A,x
	lda	a:$0050,y
	sta	$1C,x
	lda	a:$0060,y
	sta	$18,x
	inc	$12,x
	rtl

sub_04AC92:
	inc	$24,x
	lda	$24,x
	cmp	#$0040
	bcc	loc_04ACAB
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$24,x
	inc	$12,x
loc_04ACAB:
	rtl

sub_04ACAC:
	inc	$30,x
	lda	$30,x
	cmp	#$0004
	bcc	loc_04ACBA
	lda	#$0007
	bra	loc_04ACBD
loc_04ACBA:
	lda	#$0002
loc_04ACBD:
	sta	$12,x
	rtl

sub_04ACC0:
	stz	$06,x
	lda	#$000B
	jsl	f:sub_00868F
	lda	#$0003
	sta	$16,x
	lda	#$3000
	sta	$02,x
	lda	#$C59A
	sta	$20,x
	stz	$04,x
	stz	$22,x
	inc	$12,x
	rtl

sub_04ACDF:
	lda	$20,x
	bne	loc_04ACEC
	lda	#$8000
	sta	$16,x
	stz	$00,x
	stz	$10,x
loc_04ACEC:
	rtl

sub_04ACED:
	lda	a:$0912
	cmp	#$0003
	bcc	loc_04ACF8
	brl	loc_04AD6B
loc_04ACF8:
	lda	$06,x
	bpl	loc_04ACFF
	brl	loc_04AD6B
loc_04ACFF:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04AD0E,x
	plx
	sta	$00
	jmp	($0000)
tbl_04AD0E:
	.addr	sub_04AD16
	.addr	sub_04AD51
	.addr	sub_04AD61
	.addr	sub_04AD83

sub_04AD16:
	lda	#$001F
	sta	$16,x
	lda	#$3400
	sta	$02,x
	ldy	$84
	lda	a:data_05EE5E,y
	sta	$06,x
	lda	#$0014
	sta	$28,x
	lda	#$FFEC
	sta	$2A,x
	lda	$E8
	and	#$0002
	tay
	lda	a:data_05EE64,y
	sta	$04,x
	stz	$08,x
	stz	$0C,x
	lda	#$EE68
	sta	$20,x
	stz	$22,x
	lda	#$0040
	sta	$24,x
	lda	#$0001
	sta	$12,x

sub_04AD51:
	dec	$24,x
	bmi	loc_04AD5C
	lda	#$0010
	jml	f:sub_1DAD8A
loc_04AD5C:
	lda	#$0002
	sta	$12,x

sub_04AD61:
	jsr	a:sub_04AD84
	lda	#$0010
	jml	f:sub_1DAD8A
loc_04AD6B:
	lda	#$000C
	jsl	f:sub_00868F
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	lda	#$C4CE
	txy
	jml	f:sub_01CF66

sub_04AD83:
	; (not executed in the CDL traces)
	rtl

sub_04AD84:
	jsr	a:sub_04ADAC
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	$08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	$0A
	jsl	f:sub_1DABA0
	sep	#$20
	.a8
	sec
	sbc	$04,x
	bmi	loc_04ADA7
	inc	$04,x
	rep	#$20
	.a16
	rts
loc_04ADA7:
	.a8
	dec	$04,x
	rep	#$20
	.a16
	rts

sub_04ADAC:
	lda	a:$1FCA
	bne	loc_04ADB5
loc_04ADB1:
	ldy	#$0200
	rts
loc_04ADB5:
	lda	a:$1F8A
	bne	loc_04ADBE
loc_04ADBA:
	ldy	#$0240
	rts
loc_04ADBE:
	txa
	bit	#$0040
	beq	loc_04ADB1
	bra	loc_04ADBA

sub_04ADC6:
	lda	a:$0906
	bpl	loc_04ADCE
	brl	loc_04AD6B
loc_04ADCE:
	lda	$06,x
	bpl	loc_04ADD5
	brl	loc_04AD6B
loc_04ADD5:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04ADE4,x
	plx
	sta	$00
	jmp	($0000)
tbl_04ADE4:
	.addr	sub_04ADEC
	.addr	sub_04AE1C
	.addr	sub_04AE3E
	.addr	sub_04AD83

sub_04ADEC:
	lda	#$001F
	sta	$16,x
	lda	#$3400
	sta	$02,x
	ldy	$84
	lda	a:data_05EE9A,y
	sta	$06,x
	lda	#$0014
	sta	$28,x
	lda	#$FFEC
	sta	$2A,x
	stz	$08,x
	stz	$0C,x
loc_04AE0B:
	lda	#$EE68
	sta	$20,x
	stz	$22,x
	lda	#$0100
	sta	$24,x
	lda	#$0001
	sta	$12,x

sub_04AE1C:
	dec	$24,x
	bmi	loc_04AE2A
	jsr	a:sub_04AD84
	lda	#$0010
	jml	f:sub_1DAD8A
loc_04AE2A:
	lda	#$0001
	sta	$30,x
	lda	#$0010
	sta	$32,x
	lda	#$0200
	sta	$24,x
	lda	#$0002
	sta	$12,x

sub_04AE3E:
	dec	$24,x
	bmi	loc_04AE0B
	lda	#$0010
	jsr	a:sub_04AE4F
	lda	#$0010
	jml	f:sub_1DAD8A

sub_04AE4F:
	sta	$00
	lda	a:$090A
	sec
	sbc	#$0008
	sec
	sbc	$0A,x
	sta	$08
	lda	a:$090E
	clc
	adc	#$0004
	sec
	sbc	$0E,x
	sta	$0A
	jsl	f:sub_1DABA0
	sep	#$20
	.a8
	sec
	sbc	$04,x
	bmi	loc_04AE7E
	lda	$04,x
	clc
	adc	$00
	sta	$04,x
	rep	#$20
	.a16
	rts
loc_04AE7E:
	.a8
	lda	$04,x
	sec
	sbc	$00
	sta	$04,x
	rep	#$20
	.a16
	rts

sub_04AE88:
	lda	a:$0912
	cmp	#$0003
	bcc	loc_04AE93
	brl	loc_04AFE7
loc_04AE93:
	lda	$06,x
	bpl	loc_04AE9A
	brl	loc_04AFE7
loc_04AE9A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04AEA9,x
	plx
	sta	$00
	jmp	($0000)
tbl_04AEA9:
	.addr	sub_04AEB5
	.addr	sub_04AF05
	.addr	sub_04AF4D
	.addr	sub_04AFB1
	.addr	sub_04AFDC
	.addr	sub_04B004

sub_04AEB5:
	lda	#$001F
	sta	$16,x
	lda	#$3400
	sta	$02,x
	ldy	$84
	lda	a:data_05EEA0,y
	sta	$06,x
	lda	#$0014
	sta	$28,x
	lda	#$FFEC
	sta	$2A,x
	lda	#$0070
	cmp	$0E,x
	lda	#$0000
	rol	a
	asl	a
	sta	$30,x
	tay
	lda	a:data_05EEA6,y
	sta	$1E,x
	lda	a:data_05EEAA,y
	sta	$1C,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$0000
	sta	$18,x
	stz	$04,x
	stz	$08,x
	stz	$0C,x
	ldy	$30,x
	lda	a:data_05EEAE,y
	sta	$00,x
	stz	$20,x
	lda	#$0001
	sta	$12,x

sub_04AF05:
	ldy	$30,x
	jsr	a:sub_04AF1C
	bcs	loc_04AF2A
	clc
	lda	$1C,x
	adc	a:data_05EEB6,y
	sta	$1C,x
	lda	$1E,x
	adc	a:data_05EEB2,y
	sta	$1E,x
	rtl

sub_04AF1C:
	bne	loc_04AF24
	lda	$0E,x
	cmp	#$00B8
	rts
loc_04AF24:
	lda	#$0048
	cmp	$0E,x
	rts
loc_04AF2A:
	ldy	$30,x
	lda	a:data_05EEBA,y
	sta	$0E,x
	stz	$0C,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	a:data_05EEBE,y
	sta	$20,x
	stz	$22,x
	lda	#$0002
	sta	$12,x

sub_04AF4D:
	jsr	a:sub_04AF5C
	bcc	loc_04AF5B
	lda	$30,x
	bne	loc_04AF59
	brl	loc_04AFBC
loc_04AF59:
	bra	loc_04AF8F
loc_04AF5B:
	rtl

sub_04AF5C:
	lda	a:$1F8A
	beq	loc_04AF70
	lda	a:$1512
	clc
	adc	#$0020
	sec
	sbc	$0A,x
	cmp	#$0002
	bcc	loc_04AF86
loc_04AF70:
	lda	a:$1FCA
	beq	loc_04AF84
	lda	a:$1552
	clc
	adc	#$0020
	sec
	sbc	$0A,x
	cmp	#$0002
	bcc	loc_04AF86
loc_04AF84:
	clc
	rts
loc_04AF86:
	lda	$E8
	bit	#$0001
	bne	loc_04AF84
	sec
	rts
loc_04AF8F:
	stz	$30,x
	lda	#$C307
	sta	$00,x
	stz	$20,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$0000
	sta	$18,x
	lda	#$0003
	sta	$1E,x
	lda	#$0000
	sta	$1C,x
	lda	#$0003
	sta	$12,x

sub_04AFB1:
	lda	$0E,x
	cmp	#$00B8
	bcc	loc_04AFBB
	brl	loc_04AF2A
loc_04AFBB:
	rtl
loc_04AFBC:
	lda	#$0002
	sta	$30,x
	stz	$20,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1E,x
	lda	#$0000
	sta	$1C,x
	lda	#$0004
	sta	$12,x

sub_04AFDC:
	lda	#$0048
	cmp	$0E,x
	bcc	loc_04AFE6
	brl	loc_04AF2A
loc_04AFE6:
	rtl
loc_04AFE7:
	lda	#$000E
	jsl	f:sub_00868F
	lda	#$001D
	sta	$10,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	lda	#$C4CE
	txy
	jml	f:sub_01CF66

sub_04B004:
	; (not executed in the CDL traces)
	rtl

sub_04B005:
	lda	#$0060
	jsl	f:sub_04AA0D
	lda	a:$16BA
	beq	loc_04B014
	dec	a:$16BA
loc_04B014:
	lda	$26,x
	beq	loc_04B02A
	lda	a:$16BA
	bne	loc_04B02A
	lda	#$003C
	jsl	f:sub_00868F
	lda	#$0004
	sta	a:$16BA
loc_04B02A:
	lda	$06,x
	bpl	loc_04B031
	brl	loc_04B08A
loc_04B031:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04B040,x
	plx
	sta	$00
	jmp	($0000)
tbl_04B040:
	.addr	sub_04B04E
	.addr	sub_04B078
	.addr	sub_04B086
	.addr	sub_04B0A7
	.addr	sub_04B0DF
	.addr	sub_04B0FE
	.addr	sub_04B117

sub_04B04E:
	ldy	$84
	lda	a:data_05EEFA,y
	sta	$06,x
	lda	#$0049
	sta	a:$1E8E
	lda	#$0080
	sta	a:$13C0
	stz	a:$13D8
	jsr	a:sub_04B17C
	lda	#$0001
	sta	a:$1E40
	jsr	a:sub_04B1C3
	lda	#$0009
	sta	a:$13FA
	inc	$12,x

sub_04B078:
	lda	a:$13BA
	cmp	#$0004
	beq	loc_04B084
	jsr	a:sub_04B14B
	rtl
loc_04B084:
	inc	$12,x

sub_04B086:
	jsr	a:sub_04B14B
	rtl
loc_04B08A:
	lda	#$0052
	jsl	f:sub_00868F
	stz	$06,x
	stz	$16,x
	lda	#$8000
	ldy	$30,x
	sta	a:$0016,y
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_04B0A7:
	dec	$24,x
	bmi	loc_04B0D8
	lda	#$0004
	sta	a:$1662
	lda	#$0080
	sta	$00
	lda	#$00A0
	sta	$02
	lda	#$007F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04B0D7
	lda	#$FFFC
	sta	a:$001E,y
loc_04B0D7:
	rtl
loc_04B0D8:
	lda	#$0003
	sta	$24,x
	inc	$12,x

sub_04B0DF:
	jsr	a:sub_04B12E
	dec	$24,x
	beq	loc_04B0E7
	rtl
loc_04B0E7:
	lda	#$0081
	jsl	f:sub_00868F
	phx
	ldx	#.loword(data_059EC9)
	jsl	f:sub_0090A8
	plx
	lda	#$0080
	sta	$24,x
	inc	$12,x

sub_04B0FE:
	dec	$24,x
	bmi	loc_04B10C
	bne	loc_04B10B
	lda	#$0083
	jsl	f:sub_00868F
loc_04B10B:
	rtl
loc_04B10C:
	phx
	ldx	#$F497
	jsl	f:sub_00994F
	plx
	inc	$12,x

sub_04B117:
	lda	$52
	cmp	#$00FF
	beq	loc_04B12D
	lda	#$0069
	jsl	f:sub_00868F
	stz	a:$13BA
	lda	#$8000
	sta	$16,x
loc_04B12D:
	rtl

sub_04B12E:
	lda	#$0004
	sta	$02
	lda	#$0040
	sta	$08
	lda	$24,x
	asl	a
	tay
	lda	a:data_05EF04,y
	pha
	lda	a:data_05EEFE,y
	ply
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04B14B:
	lda	$22,x
	inc	$22,x
	bit	#$0007
	bne	loc_04B17B
	ldy	$B6
	cpy	#$0010
	bcc	loc_04B15E
	; (not executed in the CDL traces)
	dec	$22,x
	rts
loc_04B15E:
	lsr	a
	lsr	a
	and	#$0002
	tay
	lda	a:data_05EF3C,y
	tay
	lda	#$0003
	sta	$02
	lda	#$0030
	sta	$08
	lda	#$4D90
	phx
	jsl	f:sub_00FEA3
	plx
loc_04B17B:
	rts

sub_04B17C:
	lda	#$001D
	sta	$16,x
	lda	#$0110
	sta	$0A,x
	lda	#$0090
	sta	$0E,x
	lda	#$0040
	sta	$28,x
	lda	#$FFD0
	sta	$2A,x
	jsl	f:sub_019EAB
	bcs	loc_04B1C2
	sty	$30,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$0120
	sta	a:$000A,y
	lda	#$00C0
	sta	a:$000E,y
	lda	#$0050
	sta	a:$0028,y
	lda	#$FF60
	sta	a:$002A,y
	clc
loc_04B1C2:
	rts

sub_04B1C3:
	phx
	ldx	#$0008
loc_04B1C7:
	ldy	#$03C0
	jsl	f:sub_019EAE
	bcs	loc_04B1EE
	lda	#$0067
	sta	a:$0010,y
	lda	a:data_05EF56,x
	sta	a:$000A,y
	lda	a:data_05EF5E,x
	sta	a:$000E,y
	lda	a:data_05EF66,x
	sta	a:$0030,y
	lda	a:data_05EF6E,x
	sta	a:$0032,y
loc_04B1EE:
	dex
	dex
	bne	loc_04B1C7
	plx
	rts

sub_04B1F4:
	lda	a:$0912
	cmp	#$0003
	bcc	loc_04B1FF
	brl	loc_04B283
loc_04B1FF:
	lda	$06,x
	bpl	loc_04B206
	brl	loc_04B283
loc_04B206:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04B215,x
	plx
	sta	$00
	jmp	($0000)
tbl_04B215:
	.addr	sub_04B21D
	.addr	sub_04B25B
	.addr	sub_04B270
	.addr	sub_04B28F

sub_04B21D:
	ldy	$84
	lda	a:data_05EF78,y
	sta	$06,x
	stz	$08,x
	stz	$0C,x
	stz	$04,x
	lda	#$001D
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	stz	$34,x
	stz	$36,x
loc_04B23D:
	phx
	jsl	f:sub_00816C
	plx
	lda	$E8
	and	#$0003
	sta	$FA
	lda	$84
	asl	a
	ora	$FA
	asl	a
	tay
	lda	a:data_05EF7E,y
	sta	$24,x
	lda	#$0001
	sta	$12,x

sub_04B25B:
	dec	$24,x
	bmi	loc_04B260
	rtl
loc_04B260:
	ldy	$30,x
	lda	a:data_05EF96,y
	sta	$34,x
	stz	$36,x
	lda	#$0030
	sta	$24,x
	inc	$12,x

sub_04B270:
	jsl	f:sub_04B2E7
	dec	$24,x
	bmi	loc_04B23D
	lda	$24,x
	cmp	#$0020
	bne	loc_04B282
	jsr	a:sub_04B2C1
loc_04B282:
	rtl
loc_04B283:
	lda	#$003B
	jsl	f:sub_00868F
	lda	#$0003
	sta	$12,x

sub_04B28F:
	stz	$06,x
	lda	#$0003
	sta	$16,x
	ldy	$30,x
	lda	a:data_05EFC6,y
	jsl	f:sub_04B32B
	lda	$0A,x
	clc
	adc	#$000A
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	#$0008
	sta	$0E,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#$C4CE
	jsl	f:sub_01CF66
	rtl

sub_04B2C1:
	ldy	#$03C0
	jsl	f:sub_019EAE
	bcs	loc_04B2E6
	lda	#$0068
	sta	a:$0010,y
	lda	$0A,x
	clc
	adc	#$0008
	sta	a:$000A,y
	phy
	ldy	$30,x
	lda	$0E,x
	clc
	adc	a:data_05EFCA,y
	ply
	sta	a:$000E,y
loc_04B2E6:
	rts

sub_04B2E7:
	ldy	$34,x
	beq	loc_04B32A
	lda	$36,x
	bne	loc_04B300
	lda	$B6
	cmp	#$0040
	bcs	loc_04B32A
	lda	a:$0000,y
	sta	$36,x
	lda	a:$0002,y
	bra	sub_04B32B
loc_04B300:
	dec	$36,x
	bne	loc_04B32A
	lda	$B6
	cmp	#$0040
	bcc	loc_04B30E
	; (not executed in the CDL traces)
	inc	$36,x
	rtl
loc_04B30E:
	iny
	iny
	iny
	iny
	lda	a:$0000,y
	beq	loc_04B326
	bpl	loc_04B31D
	; (not executed in the CDL traces)
	tay
	lda	a:$0000,y
loc_04B31D:
	sty	$34,x
	sta	$36,x
	lda	a:$0002,y
	bra	sub_04B32B
loc_04B326:
	sta	$34,x
	sta	$36,x
loc_04B32A:
	rtl

sub_04B32B:
	sta	$00
	lda	$32,x
	jml	f:sub_00FE76

sub_04B333:
	lda	$06,x
	bpl	loc_04B33A
	brl	loc_04B383
loc_04B33A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04B349,x
	plx
	sta	$00
	jmp	($0000)
tbl_04B349:
	.addr	sub_04B353
	.addr	sub_04B360
	.addr	sub_04B370
	.addr	sub_04B3A5
	.addr	sub_04B3DF

sub_04B353:
	ldy	$84
	lda	a:data_05EFCE,y
	sta	$06,x
	stz	$34,x
	stz	$36,x
	inc	$12,x

sub_04B360:
	lda	a:$13BA
	cmp	#$0004
	beq	loc_04B369
loc_04B368:
	rtl
loc_04B369:
	jsr	a:sub_04B486
	bcs	loc_04B368
	inc	$12,x

sub_04B370:
	jsr	a:sub_04B4F3
	jsr	a:sub_04B3EF
	jsr	a:sub_04B434
	jsr	a:sub_04B502
	jsr	a:sub_04B403
	jsr	a:sub_04B447
	rtl
loc_04B383:
	lda	#$0051
	jsl	f:sub_00868F
	stz	$06,x
	stz	$16,x
	lda	#$8000
	ldy	$30,x
	sta	a:$0016,y
	ldy	$32,x
	sta	a:$0016,y
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_04B3A5:
	dec	$24,x
	bmi	loc_04B3D5
	lda	#$0004
	sta	a:$1662
	lda	$0A,x
	sta	$00
	lda	#$0080
	sta	$02
	lda	#$003F
	sta	$04
	lda	#$007F
	sta	$06
	ldy	#$0300
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04B3D4
	lda	#$FFFC
	sta	a:$001E,y
loc_04B3D4:
	rtl
loc_04B3D5:
	lda	#$0004
	sta	$24,x
	lda	#$0004
	sta	$12,x

sub_04B3DF:
	jsr	a:sub_04B469
	dec	$24,x
	bne	loc_04B368
	stz	a:$13BA
	lda	#$8000
	sta	$16,x
	rtl

sub_04B3EF:
	lda	$78
	bit	#$003F
	bne	loc_04B402
	and	#$0040
	asl	a
	asl	a
	xba
	asl	a
	ora	#$8000
	sta	$34,x
loc_04B402:
	rts

sub_04B403:
	lda	$34,x
	bpl	loc_04B433
	and	#$0002
	sta	$34,x
	tay
	lda	a:data_05EFE8,y
	sta	$16,x
	lda	a:data_05EFEC,y
	sta	$2A,x
	lda	a:data_05EFF0,y
	sta	$0E,x
	lda	a:data_05EFD4,y
	tay
	lda	#$0002
	sta	$02
	lda	#$0020
	sta	$08
	lda	#$4590
	phx
	jsl	f:sub_00FEA3
	plx
loc_04B433:
	rts

sub_04B434:
	lda	$78
	dec	a
	bit	#$0007
	bne	loc_04B446
	lsr	a
	lsr	a
	and	#$0002
	ora	#$8000
	sta	$36,x
loc_04B446:
	rts

sub_04B447:
	lda	$36,x
	bpl	loc_04B468
	and	#$0002
	sta	$36,x
	tay
	lda	a:data_05EFF4,y
	tay
	lda	#$0001
	sta	$02
	lda	#$0008
	sta	$08
	lda	#$4598
	phx
	jsl	f:sub_00FEA3
	plx
loc_04B468:
	rts

sub_04B469:
	lda	#$0003
	sta	$02
	lda	#$0018
	sta	$08
	lda	$24,x
	asl	a
	tay
	lda	a:data_05F002,y
	pha
	lda	a:data_05EFFA,y
	ply
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_04B486:
	lda	#$003F
	sta	$16,x
	lda	#$0090
	sta	$0A,x
	lda	#$0080
	sta	$0E,x
	lda	#$0040
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	ldy	#$03C0
	sty	$30,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$003F
	sta	a:$0016,y
	lda	#$0088
	sta	a:$000A,y
	lda	#$0060
	sta	a:$000E,y
	lda	#$0050
	sta	a:$0028,y
	lda	#$FFD8
	sta	a:$002A,y
	ldy	#$0400
	sty	$32,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$003F
	sta	a:$0016,y
	lda	#$00A0
	sta	a:$000A,y
	lda	#$0038
	sta	a:$000E,y
	lda	#$0048
	sta	a:$0028,y
	lda	#$FFC8
	sta	a:$002A,y
	clc
	rts

sub_04B4F3:
	lda	$26,x
	beq	loc_04B501
	lda	#$912A
	sta	$9A
	lda	#$0020
	sta	$98
loc_04B501:
	rts

sub_04B502:
	lda	$34,x
	beq	loc_04B528
	lda	$78
	bit	#$001F
	bne	loc_04B528
	ldy	#$03C0
	jsl	f:sub_019EAE
	bcs	loc_04B528
	lda	#$0063
	sta	a:$0010,y
	lda	#$0090
	sta	a:$000A,y
	lda	#$0080
	sta	a:$000E,y
loc_04B528:
	rts

sub_04B529:
	jsr	a:sub_04BDC6
	ldy	#$0840
	lda	a:$0006,y
	bpl	loc_04B539
	lda	#$0026
	sta	$12,x
loc_04B539:
	ldy	#$0840
	lda	a:$0026,y
	beq	loc_04B552
	lda	#$912A
	sta	$9A
	lda	#$0020
	sta	$98
	lda	#$000F
	jsl	f:sub_00868F
loc_04B552:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04B561,x
	plx
	sta	$00
	jmp	($0000)
tbl_04B561:
	.addr	sub_04B5B2
	.addr	sub_04B5CE
	.addr	sub_04B5D9
	.addr	sub_04B69E
	.addr	sub_04BB9D
	.addr	sub_04BABC
	.addr	sub_04B714
	.addr	sub_04B7EF
	.addr	sub_04B80B
	.addr	sub_04B819
	.addr	sub_04B843
	.addr	sub_04B7EF
	.addr	sub_04B80B
	.addr	sub_04B824
	.addr	sub_04B843
	.addr	sub_04B7EF
	.addr	sub_04B80B
	.addr	sub_04B8F6
	.addr	sub_04B8FD
	.addr	sub_04B906
	.addr	sub_04B937
	.addr	sub_04B976
	.addr	sub_04BB9D
	.addr	sub_04B97F
	.addr	sub_04B9AB
	.addr	sub_04BA15
	.addr	sub_04BB9D
	.addr	sub_04BA46
	.addr	sub_04BA61
	.addr	sub_04BA75
	.addr	sub_04BA98
	.addr	sub_04B69E
	.addr	sub_04BAD9
	.addr	sub_04B714
	.addr	sub_04B7EF
	.addr	sub_04B80B
	.addr	sub_04BAE6
	.addr	sub_04B5B1
	.addr	sub_04BAF2
	.addr	sub_04BB2B

sub_04B5B1:
	rtl

sub_04B5B2:
	lda	#$0006
	jsl	f:sub_01F6A8
	lda	#$0008
	sta	a:$1672
	lda	#$004A
	sta	a:$1E8E
	stz	a:$13C0
	stz	a:$13D8
	inc	$12,x
	rtl

sub_04B5CE:
	lda	a:$13BA
	cmp	#$0004
	bne	loc_04B5D8
	inc	$12,x
loc_04B5D8:
	rtl

sub_04B5D9:
	lda	#$0079
	sta	$16,x
	lda	#$0FFF
	sta	$06,x
	lda	#$0034
	sta	$28,x
	lda	#$FFA8
	sta	$2A,x
	ldy	#$0800
	lda	#$0053
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	#$0FFF
	sta	a:$0006,y
	lda	#$0030
	sta	a:$0028,y
	lda	#$FFE8
	sta	a:$002A,y
	ldy	$84
	lda	a:data_05F024,y
	sta	$00
	ldy	#$0840
	lda	#$00A0
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	$00
	sta	a:$0006,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFE0
	sta	a:$002A,y
	ldy	#$0880
	lda	#$0053
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	#$0FFF
	sta	a:$0006,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFC0
	sta	a:$002A,y
	lda	#$00AD
	sta	$0A,x
	lda	#$01E0
	sta	$0E,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	inc	$12,x
loc_04B674:
	jsr	a:sub_04BBBD
	stz	$0C
	jsl	f:sub_04BE03
	phx
	ldx	#$0840
	stz	$0C
	jsl	f:sub_04BE03
	ldx	#$0800
	stz	$0C
	jsl	f:sub_04BE03
	ldx	#$0880
	stz	$0C
	jsl	f:sub_04BE03
	plx
	jsr	a:sub_04BBF5
	rtl

sub_04B69E:
	lda	$24,x
	bit	#$003F
	bne	loc_04B6AC
	lda	#$0053
	jsl	f:sub_00868F
loc_04B6AC:
	dec	$0E,x
	lda	$0E,x
	cmp	#$00B9
	bcs	loc_04B6BC
	stz	$24,x
	inc	$12,x
	jmp	a:loc_04B674
loc_04B6BC:
	lda	#$0003
	sta	a:$1662
	jsl	f:sub_019EAB
	bcs	loc_04B6F1
	lda	#$0066
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	phy
	ldy	#$0800
	lda	a:$000A,y
	sta	$00
	ply
	lda	$E8
	and	#$003F
	adc	$00
	sta	a:$000A,y
	lda	#$00B8
	sta	a:$000E,y
loc_04B6F1:
	inc	$24,x
	jmp	a:loc_04B674
loc_04B6F6:
	lda	#$FFFF
	sta	$1A,x
loc_04B6FB:
	lda	#$8000
	sta	$18,x
	stz	$1C,x
	lda	#$FFFC
	sta	$1E,x
	lda	#$000A
	jsr	a:sub_04BC10
	inc	$12,x
	rtl
loc_04B710:
	stz	$1A,x
	bra	loc_04B6FB

sub_04B714:
	lda	$1E,x
	bmi	loc_04B72F
	lda	$78
	bit	#$0003
	bne	loc_04B72F
	bit	#$0004
	beq	loc_04B729
	lda	#$0009
	bra	loc_04B72C
loc_04B729:
	lda	#$000A
loc_04B72C:
	jsr	a:sub_04BC10
loc_04B72F:
	lda	$0A,x
	cmp	#$002D
	bmi	loc_04B740
	cmp	#$00AD
	bcc	loc_04B749
	; (not executed in the CDL traces)
	lda	#$00AD
	bra	loc_04B743
loc_04B740:
	lda	#$002D
loc_04B743:
	sta	$0A,x
	stz	$18,x
	stz	$1A,x
loc_04B749:
	stz	$00
loc_04B74B:
	lda	$00
	asl	a
	tay
	lda	a:data_05F02C,y
	sta	$02
	lda	$1E,x
	bmi	loc_04B7B2
	ldy	$02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	loc_04B77A
	ldy	$02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0010
	bcc	loc_04B7A7
loc_04B77A:
	ldy	#$0800
	lda	a:$000E,y
	cmp	#$0098
	bcc	loc_04B7B2
	ldy	$02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0020
	bcs	loc_04B7B2
	ldy	$02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	loc_04B7B2
loc_04B7A7:
	ldy	$02
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
loc_04B7B2:
	inc	$00
	lda	$00
	cmp	#$0002
	bcc	loc_04B74B
	lda	$0E,x
	cmp	#$00B8
	bcc	loc_04B7DD
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#$00B8
	sta	$0E,x
	sta	$32,x
	lda	a:$1398
	sta	$30,x
	stz	$24,x
	inc	$12,x
	jmp	a:loc_04B7EC
loc_04B7DD:
	lda	$1C,x
	clc
	adc	#$1400
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_04B7EC:
	jmp	a:loc_04B674

sub_04B7EF:
	lda	#$0009
	jsr	a:sub_04BC10
	lda	#$0003
	sta	a:$1662
	stz	$30,x
	stz	$24,x
	lda	#$0056
	jsl	f:sub_00868F
	inc	$12,x
	jmp	a:loc_04B7EC

sub_04B80B:
	lda	a:$1662
	bne	loc_04B816
	stz	$30,x
	stz	$24,x
	inc	$12,x
loc_04B816:
	jmp	a:loc_04B7EC

sub_04B819:
	jsl	f:sub_01E860
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_04B839

sub_04B824:
	stz	$3A,x
	lda	#$4000
loc_04B829:
	sta	$38,x
	stz	$1A,x
	stz	$18,x
	inc	$12,x
	lda	#$0054
	jsl	f:sub_00868F
	rtl
loc_04B839:
	lda	#$FFFF
	sta	$3A,x
	lda	#$C000
	bra	loc_04B829

sub_04B843:
	lda	$3A,x
	bmi	loc_04B855
	lda	$0A,x
	cmp	#$00AD
	bcc	loc_04B87F
	lda	#$00AD
	sta	$0A,x
	bra	loc_04B861
loc_04B855:
	lda	$0A,x
	cmp	#$002D
	bpl	loc_04B87F
	lda	#$002D
	sta	$0A,x
loc_04B861:
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#$00B8
	sta	$0E,x
	lda	#$0000
	sta	a:$1660
	lda	#$0007
	jsr	a:sub_04BC10
	inc	$12,x
	jmp	a:loc_04B674
loc_04B87F:
	lda	$18,x
	sta	$00
	lda	$1A,x
	sta	$02
	lda	$00
	clc
	adc	$38,x
	sta	$00
	lda	$02
	adc	$3A,x
	sta	$02
	bpl	loc_04B89A
	eor	#$FFFF
	inc	a
loc_04B89A:
	cmp	#$0004
	bcs	loc_04B8A7
	lda	$00
	sta	$18,x
	lda	$02
	sta	$1A,x
loc_04B8A7:
	jsl	f:sub_019EAB
	bcs	loc_04B8D6
	lda	#$0066
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	phy
	ldy	#$0800
	lda	a:$000A,y
	sta	$00
	ply
	lda	$E8
	and	#$003F
	adc	$00
	sta	a:$000A,y
	lda	#$00B8
	sta	a:$000E,y
loc_04B8D6:
	lda	$78
	bit	#$0003
	bne	loc_04B8ED
	bit	#$0004
	beq	loc_04B8E7
	lda	#$0007
	bra	loc_04B8EA
loc_04B8E7:
	lda	#$0008
loc_04B8EA:
	jsr	a:sub_04BC10
loc_04B8ED:
	lda	#$0001
	sta	a:$1660
	jmp	a:loc_04B674

sub_04B8F6:
	stz	$24,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04B8FD:
	stz	$24,x
	stz	$30,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04B906:
	inc	$24,x
	lda	$24,x
	and	#$0007
	bne	loc_04B934
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F030,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	loc_04B934
	ldy	#$0840
	lda	a:$0016,y
	and	#$FFDF
	sta	a:$0016,y
	stz	$24,x
	stz	$30,x
	inc	$12,x
loc_04B934:
	jmp	a:loc_04B674

sub_04B937:
	inc	$24,x
	lda	$24,x
	and	#$0007
	bne	loc_04B934
	jsl	f:sub_019EAB
	bcs	loc_04B962
	lda	#$0070
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	$0A,x
	adc	#$0014
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_04B962:
	inc	$30,x
	ldy	$84
	lda	a:data_05F034,y
	cmp	$30,x
	bcs	loc_04B973
	stz	$24,x
	stz	$30,x
	inc	$12,x
loc_04B973:
	jmp	a:loc_04B674

sub_04B976:
	stz	$24,x
	stz	$30,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04B97F:
	inc	$24,x
	lda	$24,x
	and	#$0007
	bne	loc_04B9A8
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F03C,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	loc_04B934
	lda	#$0014
	jsl	f:sub_00868F
	stz	$24,x
	stz	$30,x
	inc	$12,x
loc_04B9A8:
	jmp	a:loc_04B674

sub_04B9AB:
	inc	$24,x
	lda	$24,x
	and	#$0001
	bne	loc_04B9E4
	lda	$30,x
	bne	loc_04B9E7
	jsl	f:sub_019EAB
	bcs	loc_04BA0A
	lda	#$0071
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	$0A,x
	clc
	adc	#$0004
	sta	a:$000A,y
	lda	$0E,x
	sec
	sbc	#$0040
	sta	a:$000E,y
	tya
	sta	$32,x
	inc	$30,x
loc_04B9E4:
	jmp	a:loc_04B674
loc_04B9E7:
	jsl	f:sub_019EAB
	bcs	loc_04BA0A
	lda	$32,x
	sta	a:$0030,y
	lda	#$0072
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	inc	$30,x
	lda	$30,x
	cmp	#$000A
	bcc	loc_04B9E4
loc_04BA0A:
	stz	$24,x
	stz	$30,x
	stz	$32,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04BA15:
	inc	$24,x
	lda	$24,x
	and	#$0007
	bne	loc_04BA43
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F040,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0004
	bcc	loc_04BA43
	ldy	#$0840
	lda	a:$0016,y
	ora	#$0020
	sta	a:$0016,y
	stz	$24,x
	stz	$30,x
	inc	$12,x
loc_04BA43:
	jmp	a:loc_04B674

sub_04BA46:
	ldy	#$0840
	lda	a:$0006,y
	cmp	#$0080
	bcs	loc_04BA55
	inc	$12,x
	bra	loc_04BA5A
loc_04BA55:
	lda	#$0005
	sta	$12,x
loc_04BA5A:
	stz	$24,x
	stz	$30,x
	jmp	a:loc_04B674

sub_04BA61:
	stz	$1A,x
	stz	$18,x
	stz	$1C,x
	lda	#$0001
	sta	$1E,x
	stz	$24,x
	stz	$30,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04BA75:
	lda	$24,x
	bit	#$003F
	bne	loc_04BA83
	lda	#$0053
	jsl	f:sub_00868F
loc_04BA83:
	lda	$0E,x
	cmp	#$0140
	bcc	loc_04BA95
	stz	$1E,x
	stz	$24,x
	stz	$30,x
	inc	$12,x
	jmp	a:loc_04B674
loc_04BA95:
	jmp	a:loc_04B6BC

sub_04BA98:
	jsl	f:sub_01E860
	lda	a:$000A,y
	cmp	#$0040
	bcc	loc_04BAAB
	cmp	#$00A0
	bcs	loc_04BAB0
	bcc	loc_04BAB5
loc_04BAAB:
	lda	#$0040
	bra	loc_04BAB5
loc_04BAB0:
	lda	#$00A0
	bra	loc_04BAB5
loc_04BAB5:
	sta	$0A,x
	inc	$12,x
	jmp	a:loc_04B674

sub_04BABC:
	jsl	f:sub_01E860
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcc	sub_04BAD9
	stz	$24,x
	lda	#$0009
	sta	$12,x
	jmp	a:loc_04B674

sub_04BAD9:
	lda	$0A,x
	cmp	#$0080
	bcc	loc_04BAE3
	jmp	a:loc_04B6F6
loc_04BAE3:
	jmp	a:loc_04B710

sub_04BAE6:
	lda	#$0005
	sta	$12,x
	stz	$24,x
	stz	$30,x
	jmp	a:loc_04B674

sub_04BAF2:
	lda	#$0001
	sta	$16,x
	lda	#$0000
	ldy	#$0800
	sta	a:$0016,y
	ldy	#$0840
	sta	a:$0016,y
	sta	a:$0006,y
	stz	$06,x
	stz	$24,x
	stz	$30,x
	stz	$32,x
	stz	$0C,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1C,x
	lda	#$FFFE
	sta	$1E,x
	lda	#$0006
	jsr	a:sub_04BC10
	inc	$12,x
	jmp	a:loc_04B674

sub_04BB2B:
	jsl	f:sub_00FD92
	lda	$0A,x
	adc	#$FFE0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$003F
	sta	$04
	lda	#$003F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04BB59
	lda	#$FFFD
	sta	a:$001E,y
loc_04BB59:
	lda	$1E,x
	bmi	loc_04BB62
	cmp	#$0001
	bcs	loc_04BB6E
loc_04BB62:
	lda	$1C,x
	clc
	adc	#$2000
	sta	$1C,x
	bcc	loc_04BB6E
	inc	$1E,x
loc_04BB6E:
	lda	$0E,x
	cmp	#$0140
	bcs	loc_04BB78
	jmp	a:loc_04B6BC
loc_04BB78:
	stz	a:$13BA
	lda	#$8000
	sta	$16,x
	ldy	#$0840
	sta	a:$0016,y
	ldy	#$0800
	sta	a:$0016,y
	ldy	#$0880
	sta	a:$0016,y
	stz	a:$1672
	lda	#$0082
	jsl	f:sub_00868F
	rtl

sub_04BB9D:
	inc	$24,x
	lda	$24,x
	cmp	#$003C
	bcc	loc_04BBAA
	stz	$24,x
	inc	$12,x
loc_04BBAA:
	jmp	a:loc_04B674

; (no caller found; decoded because it follows the end of a routine)
sub_04BBAD:
	; (not executed in the CDL traces)
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcc	loc_04BBBA
	stz	$24,x
	inc	$12,x
loc_04BBBA:
	jmp	a:loc_04B674

sub_04BBBD:
	ldy	#$0800
	lda	$0A,x
	sec
	sbc	#$0028
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	ldy	#$0840
	lda	$0A,x
	sec
	sbc	#$000A
	sta	a:$000A,y
	lda	$0E,x
	sec
	sbc	#$0020
	sta	a:$000E,y
	ldy	#$0880
	lda	$0A,x
	clc
	adc	#$0030
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	rts

sub_04BBF5:
	lda	$0A,x
	sec
	sbc	#$00AD
	eor	#$FFFF
	inc	a
	sta	a:$13C0
	lda	$0E,x
	sec
	sbc	#$01C0
	eor	#$FFFF
	inc	a
	sta	a:$13D8
	rts

sub_04BC10:
	asl	a
	tay
	lda	a:data_05F048,y
	sta	$02
	lda	a:data_05F05E,y
	sta	$08
	lda	a:data_05F074,y
	pha
	lda	a:data_05F08A,y
	tay
	pla
	phx
	jsl	f:sub_00FEA3
	plx
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_04BC2C:
	; (not executed in the CDL traces)
	clc
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_04BC2E:
	; (not executed in the CDL traces)
	sec
	rts

sub_04BC30:
	lda	$12,x
	bne	loc_04BC6F
	lda	#$0003
	sta	$16,x
	lda	#$3400
	sta	$02,x
	stz	$06,x
	lda	$E8
	sta	$18,x
	lda	$E8
	and	#$0007
	sbc	#$0004
	sta	$1A,x
	lda	$EA
	sta	$1C,x
	lda	#$FFFC
	sta	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	lda	#$AEB6
	sta	$00,x
	stz	$20,x
	stz	$04,x
	stz	$22,x
	inc	$12,x
	rtl
loc_04BC6F:
	inc	$24,x
	lda	$24,x
	cmp	#$00F0
	bcc	loc_04BC7E
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	rtl
loc_04BC7E:
	lda	$1C,x
	clc
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_04BC8E:
	lda	$12,x
	bne	loc_04BCD7
	lda	#$000F
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	stz	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	$E8
	sta	$18,x
	lda	$E8
	and	#$0003
	sbc	#$0003
	sta	$1A,x
	lda	$EA
	sta	$1C,x
	lda	#$FFF9
	sta	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	lda	#$C376
	sta	$00,x
	stz	$20,x
	stz	$04,x
	stz	$22,x
	inc	$12,x
	rtl
loc_04BCD7:
	inc	$24,x
	lda	$24,x
	cmp	#$012C
	bcc	loc_04BCE6
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	rtl
loc_04BCE6:
	lda	$78
	and	#$0007
	xba
	asl	a
	asl	a
	asl	a
	asl	a
	ora	#$3000
	sta	$02,x
	lda	$1E,x
	bmi	loc_04BCFE
	cmp	#$0006
	bcs	loc_04BD0D
loc_04BCFE:
	lda	$1C,x
	clc
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_04BD0D:
	lda	$1E,x
	bmi	loc_04BD16
	sec
	ror	$1A,x
	ror	$18,x
loc_04BD16:
	rtl

sub_04BD17:
	lda	$12,x
	bne	loc_04BD59
	lda	#$000F
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	stz	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	stz	$08,x
	stz	$0C,x
	stz	$36,x
	stz	$24,x
	lda	#$AF82
	sta	$00,x
	stz	$20,x
	stz	$04,x
	stz	$22,x
	lda	$0A,x
	sta	$32,x
	lda	$0E,x
	sta	$34,x
	jsl	f:sub_04AC4F
	asl	$18,x
	rol	$1A,x
	asl	$1C,x
	rol	$1E,x
	rtl
loc_04BD59:
	inc	$24,x
	lda	$24,x
	cmp	#$012C
	bcc	loc_04BD68
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	rtl
loc_04BD68:
	lda	$78
	and	#$0003
	asl	a
	tay
	lda	a:data_05F0C6,y
	sta	$00,x
	rtl

sub_04BD75:
	lda	$12,x
	bne	loc_04BD59
	lda	#$000F
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	stz	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	stz	$36,x
	stz	$24,x
	lda	#$AF82
	sta	$00,x
	stz	$20,x
	stz	$04,x
	stz	$22,x
	stz	$08,x
	stz	$0C,x
	lda	$30,x
	tay
	lda	a:$0032,y
	sta	$0A,x
	lda	a:$0034,y
	sta	$0E,x
	lda	a:$0018,y
	sta	$18,x
	lda	a:$001A,y
	sta	$1A,x
	lda	a:$001C,y
	sta	$1C,x
	lda	a:$001E,y
	sta	$1E,x
	inc	$12,x
	rtl

sub_04BDC6:
	stz	$00
loc_04BDC8:
	lda	$00
	asl	a
	tay
	lda	a:data_05F02C,y
	tay
	lda	a:$0016,y
	beq	loc_04BDF9
	lda	a:$000E,y
	cmp	#$0056
	bcc	loc_04BDEA
	cmp	#$00B9
	bcc	loc_04BDF9
	; (not executed in the CDL traces)
	lda	#$00B8
	sta	a:$000E,y
	bra	loc_04BDF9
loc_04BDEA:
	lda	#$0057
	sta	a:$000E,y
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
loc_04BDF9:
	inc	$00
	lda	$00
	cmp	#$0002
	bcc	loc_04BDC8
	rts

sub_04BE03:
	ldy	#$0200
	lda	a:$0016,y
	beq	loc_04BE13
	bmi	loc_04BE13
	stz	$0C
	jsl	f:sub_019F37
loc_04BE13:
	ldy	#$0240
	lda	a:$0016,y
	beq	loc_04BE23
	bmi	loc_04BE23
	stz	$0C
	jsl	f:sub_019F37
loc_04BE23:
	rtl

sub_04BE24:
	lda	$06,x
	bpl	loc_04BE2B
	brl	loc_04BFA2
loc_04BE2B:
	lda	a:$0906
	bpl	loc_04BE33
	; (not executed in the CDL traces)
	brl	loc_04BFA2
loc_04BE33:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04BE42,x
	plx
	sta	$00
	jmp	($0000)
tbl_04BE42:
	.addr	sub_04BE4E
	.addr	sub_04BE77
	.addr	sub_04BE98
	.addr	sub_04BF07
	.addr	sub_04BF88
	.addr	sub_04BFC0

sub_04BE4E:
	ldy	$84
	lda	a:data_05F0CE,y
	sta	$06,x
	stz	$16,x
	lda	#$C49F
	sta	$00,x
	lda	#$2600
	sta	$02,x
	stz	$26,x
	lda	#$0020
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	lda	#$0001
	sta	$16,x
	lda	#$0001
	sta	$12,x

sub_04BE77:
	lda	a:$0912
	cmp	#$0002
	bcs	loc_04BE80
	rtl
loc_04BE80:
	lda	#$4019
	sta	$16,x
	stz	$30,x
	lda	#$C49F
	sta	$00,x
	lda	#$2600
	sta	$02,x
	stz	$26,x
	lda	#$0002
	sta	$12,x

sub_04BE98:
	ldy	$32,x
	lda	a:$090A
	clc
	adc	a:data_05F0E8,y
	sta	$0A,x
	lda	a:$090E
	clc
	adc	#$0034
	sta	$0E,x
	lda	$30,x
	beq	loc_04BEB5
	jsr	a:sub_04C137
	bcc	loc_04BED0
loc_04BEB5:
	ldy	#$C4BC
	lda	$3A,x
	dec	a
	bpl	loc_04BEC3
	lda	#$0000
	ldy	#$C49F
loc_04BEC3:
	sty	$00,x
	sta	$3A,x
	cmp	#$0008
	bne	loc_04BECF
	jsr	a:sub_04C1DA
loc_04BECF:
	rtl
loc_04BED0:
	lda	#$401D
	sta	$16,x
	lda	#$C4BC
	sta	$00,x
	lda	#$3600
	sta	$02,x
	stz	$26,x
	jsr	a:sub_04BF56
	bcs	loc_04BE80
	sty	$38,x
	lda	#$0080
	sta	$04,x
	lda	$34,x
	asl	a
	ora	$32,x
	tay
	lda	a:data_05F0D4,y
	sta	$36,x
	ldy	$34,x
	lda	a:data_05F0DC,y
	sta	$24,x
	jsr	a:sub_04BFC1
	lda	#$0003
	sta	$12,x

sub_04BF07:
	dec	$24,x
	bmi	loc_04BF79
	ldy	$36,x
	lda	$0A,x
	sta	a:$0000,y
	iny
	iny
	lda	$0E,x
	sta	a:$0000,y
	iny
	iny
	sty	$36,x
	ldy	$38,x
	lda	a:$1312,y
	sec
	sbc	$0A,x
	sta	$08
	lda	a:$1314,y
	sec
	sbc	$0E,x
	sta	$0A
	jsl	f:sub_1DABA0
	rep	#$20
	sec
	sbc	$04,x
	beq	loc_04BF4E
	bit	#$0080
	beq	loc_04BF45
	lda	$04,x
	dec	a
	dec	a
	bra	loc_04BF49
loc_04BF45:
	lda	$04,x
	inc	a
	inc	a
loc_04BF49:
	and	#$00FF
	sta	$04,x
loc_04BF4E:
	lda	#$0020
	jsl	f:sub_1DAD8A
	rtl

sub_04BF56:
	lda	a:$1F8A
	ora	a:$1FCA
	bne	loc_04BF60
	; (not executed in the CDL traces)
	sec
	rts
loc_04BF60:
	lda	$E8
	lsr	a
	bcc	loc_04BF6F
loc_04BF65:
	lda	a:$1F8A
	beq	loc_04BF6F
	ldy	#$0200
	clc
	rts
loc_04BF6F:
	lda	a:$1FCA
	beq	loc_04BF65
	; (not executed in the CDL traces)
	ldy	#$0240
	clc
	rts
loc_04BF79:
	ldy	$34,x
	lda	a:data_05F0DC,y
	sta	$24,x
	jsr	a:sub_04C18A
	lda	#$0004
	sta	$12,x

sub_04BF88:
	dec	$24,x
	bpl	loc_04BF8F
	brl	loc_04BE80
loc_04BF8F:
	ldy	$36,x
	dey
	dey
	lda	a:$0000,y
	sta	$0E,x
	dey
	dey
	lda	a:$0000,y
	sta	$0A,x
	sty	$36,x
	rtl
loc_04BFA2:
	lda	$0A,x
	clc
	adc	#$0010
	sta	$0A,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	#$0005
	sta	$12,x

sub_04BFC0:
	rtl

sub_04BFC1:
	lda	$34,x
	beq	loc_04BFC8
	brl	loc_04C073
loc_04BFC8:
	lda	$32,x
	bne	loc_04C01E
	lda	#$0077
	sta	a:$0490
	sta	a:$04D0
	sta	a:$0510
	sta	a:$0550
	sta	a:$0590
	stz	a:$04B0
	stz	a:$04F0
	stz	a:$0530
	stz	a:$0570
	stz	a:$05B0
	lda	#$1900
	sta	a:$04B2
	sta	a:$04F2
	sta	a:$0532
	sta	a:$0572
	sta	a:$05B2
	lda	#$0000
	sta	a:$04B4
	lda	#$000C
	sta	a:$04F4
	lda	#$0018
	sta	a:$0534
	lda	#$0024
	sta	a:$0574
	lda	#$0030
	sta	a:$05B4
	rts
loc_04C01E:
	lda	#$0077
	sta	a:$05D0
	sta	a:$0610
	sta	a:$0650
	sta	a:$0690
	sta	a:$06D0
	lda	#$0002
	sta	a:$05F0
	sta	a:$0630
	sta	a:$0670
	sta	a:$06B0
	sta	a:$06F0
	lda	#$1A00
	sta	a:$05F2
	sta	a:$0632
	sta	a:$0672
	sta	a:$06B2
	sta	a:$06F2
	lda	#$0000
	sta	a:$05F4
	lda	#$000C
	sta	a:$0634
	lda	#$0018
	sta	a:$0674
	lda	#$0024
	sta	a:$06B4
	lda	#$0030
	sta	a:$06F4
	rts
loc_04C073:
	lda	$32,x
	bne	loc_04C097
	stz	a:$04B0
	stz	a:$04F0
	stz	a:$0530
	stz	a:$0570
	stz	a:$05B0
	stz	a:$05F0
	stz	a:$0630
	stz	a:$0670
	stz	a:$06B0
	stz	a:$06F0
	bra	loc_04C0B8
loc_04C097:
	lda	#$0002
	sta	a:$04B0
	sta	a:$04F0
	sta	a:$0530
	sta	a:$0570
	sta	a:$05B0
	sta	a:$05F0
	sta	a:$0630
	sta	a:$0670
	sta	a:$06B0
	sta	a:$06F0
loc_04C0B8:
	lda	#$0077
	sta	a:$0490
	sta	a:$04D0
	sta	a:$0510
	sta	a:$0550
	sta	a:$0590
	sta	a:$05D0
	sta	a:$0610
	sta	a:$0650
	sta	a:$0690
	sta	a:$06D0
	lda	#$1900
	sta	a:$04B2
	sta	a:$04F2
	sta	a:$0532
	sta	a:$0572
	sta	a:$05B2
	sta	a:$05F2
	sta	a:$0632
	sta	a:$0672
	sta	a:$06B2
	sta	a:$06F2
	lda	#$0000
	sta	a:$04B4
	lda	#$000C
	sta	a:$04F4
	lda	#$0018
	sta	a:$0534
	lda	#$0024
	sta	a:$0574
	lda	#$0030
	sta	a:$05B4
	lda	#$003C
	sta	a:$05F4
	lda	#$0048
	sta	a:$0634
	lda	#$0054
	sta	a:$0674
	lda	#$0060
	sta	a:$06B4
	lda	#$006C
	sta	a:$06F4
	rts

sub_04C137:
	lda	$34,x
	bne	loc_04C167
	lda	$32,x
	bne	loc_04C153
	lda	a:$0490
	ora	a:$04D0
	ora	a:$0510
	ora	a:$0550
	ora	a:$0590
	clc
	beq	loc_04C166
	sec
	rts
loc_04C153:
	lda	a:$05D0
	ora	a:$0610
	ora	a:$0650
	ora	a:$0690
	ora	a:$06D0
	clc
	beq	loc_04C166
	sec
loc_04C166:
	rts
loc_04C167:
	lda	a:$0490
	ora	a:$04D0
	ora	a:$0510
	ora	a:$0550
	ora	a:$0590
	ora	a:$05D0
	ora	a:$0610
	ora	a:$0650
	ora	a:$0690
	ora	a:$06D0
	clc
	beq	loc_04C166
	sec
	rts

sub_04C18A:
	lda	$34,x
	bne	loc_04C1B8
	lda	$32,x
	bne	loc_04C1A5
	lda	#$0002
	sta	a:$04B6
	sta	a:$04F6
	sta	a:$0536
	sta	a:$0576
	sta	a:$05B6
	rts
loc_04C1A5:
	lda	#$0002
	sta	a:$05F6
	sta	a:$0636
	sta	a:$0676
	sta	a:$06B6
	sta	a:$06F6
	rts
loc_04C1B8:
	lda	#$0002
	sta	a:$04B6
	sta	a:$04F6
	sta	a:$0536
	sta	a:$0576
	sta	a:$05B6
	sta	a:$05F6
	sta	a:$0636
	sta	a:$0676
	sta	a:$06B6
	sta	a:$06F6
	rts

sub_04C1DA:
	ldy	#$0400
	jsl	f:sub_019EAE
	bcc	loc_04C1E6
	brl	loc_04C26D
loc_04C1E6:
	lda	#$0018
	sta	a:$0010,y
	lda	$0A,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001C,y
	lda	#$0002
	sta	a:$001E,y
	ldy	#$0400
	jsl	f:sub_019EAE
	bcs	loc_04C26D
	lda	#$0018
	sta	a:$0010,y
	lda	$0A,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0002
	sta	a:$001A,y
	sta	a:$001E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	ldy	#$0400
	jsl	f:sub_019EAE
	bcs	loc_04C26D
	lda	#$0018
	sta	a:$0010,y
	lda	$0A,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	lda	#$FFFE
	sta	a:$001A,y
	lda	#$0002
	sta	a:$001E,y
loc_04C26D:
	rts

sub_04C26E:
	lda	a:$0906
	bpl	loc_04C276
	; (not executed in the CDL traces)
	brl	loc_04C383
loc_04C276:
	ldy	$30,x
	lda	a:data_05F0E4,y
	tay
	lda	a:$0006,y
	bpl	loc_04C284
	brl	loc_04C383
loc_04C284:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04C293,x
	plx
	sta	$00
	jmp	($0000)
tbl_04C293:
	.addr	sub_04C2A3
	.addr	sub_04C2AA
	.addr	sub_04C2EC
	.addr	sub_04C31A
	.addr	sub_04C33F
	.addr	sub_04C363
	.addr	sub_04C3A1
	.addr	sub_04C382

sub_04C2A3:
	stz	$06,x
	lda	#$0001
	sta	$12,x

sub_04C2AA:
	lda	$36,x
	beq	loc_04C2B5
	; (not executed in the CDL traces)
	dec	a
	beq	loc_04C2B4
	brl	loc_04C378
loc_04C2B4:
	rtl
loc_04C2B5:
	dec	$34,x
	bmi	loc_04C2BA
	rtl
loc_04C2BA:
	lda	#$003D
	sta	$16,x
	lda	#$C4D9
	sta	$00,x
	lda	#$2600
	sta	$02,x
	ldy	$30,x
	lda	a:$090A
	clc
	adc	a:data_05F0E8,y
	sta	$0A,x
	lda	a:$090E
	clc
	adc	#$001C
	sta	$0E,x
	lda	#$0020
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	lda	#$0002
	sta	$12,x

sub_04C2EC:
	lda	$36,x
	beq	loc_04C2F7
	dec	a
	beq	loc_04C2F6
	brl	loc_04C359
loc_04C2F6:
	; (not executed in the CDL traces)
	rtl
loc_04C2F7:
	lda	$0E,x
	inc	a
	inc	a
	sta	$0E,x
	lda	a:$090E
	clc
	adc	#$0034
	cmp	$0E,x
	bcc	loc_04C309
	rtl
loc_04C309:
	lda	#$0034
	sta	$0E,x
	lda	#$3600
	sta	$02,x
	stz	$24,x
	lda	#$0003
	sta	$12,x

sub_04C31A:
	lda	$36,x
	beq	loc_04C325
	dec	a
	beq	loc_04C324
	brl	loc_04C33A
loc_04C324:
	; (not executed in the CDL traces)
	rtl
loc_04C325:
	inc	$24,x
	ldy	$32,x
	lda	a:$0000,y
	sta	$0A,x
	iny
	iny
	lda	a:$0000,y
	sta	$0E,x
	iny
	iny
	sty	$32,x
	rtl
loc_04C33A:
	lda	#$0004
	sta	$12,x

sub_04C33F:
	dec	$24,x
	bpl	loc_04C346
	brl	loc_04C359
loc_04C346:
	ldy	$32,x
	dey
	dey
	lda	a:$0000,y
	sta	$0E,x
	dey
	dey
	lda	a:$0000,y
	sta	$0A,x
	sty	$32,x
	rtl
loc_04C359:
	lda	#$2600
	sta	$02,x
	lda	#$0005
	sta	$12,x

sub_04C363:
	lda	$0E,x
	dec	a
	dec	a
	sta	$0E,x
	lda	a:$090E
	clc
	adc	#$001C
	cmp	$0E,x
	bcc	loc_04C377
	brl	loc_04C378
loc_04C377:
	rtl
loc_04C378:
	lda	#$8000
	sta	$16,x
	lda	#$0007
	sta	$12,x

sub_04C382:
	rtl
loc_04C383:
	lda	$0A,x
	clc
	adc	#$0010
	sta	$0A,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	#$0006
	sta	$12,x

sub_04C3A1:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_04C3A2:
	; (not executed in the CDL traces)
	ldy	#$0500
	lda	#$0000
	sta	a:$0006,y
	rtl

sub_04C3AC:
	ldy	#$0500
	lda	a:$0006,y
	bpl	loc_04C3C2
	lda	#$0010
	sta	$12,x
	lda	#$0000
	sta	a:$0006,y
	sta	a:$0016,y
loc_04C3C2:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04C3D1,x
	plx
	sta	$00
	jmp	($0000)
tbl_04C3D1:
	.addr	sub_04C3F6
	.addr	sub_04C4D9
	.addr	sub_04C504
	.addr	sub_04C55F
	.addr	sub_04C5AE
	.addr	sub_04C620
	.addr	sub_04C6B3
	.addr	sub_04C889
	.addr	sub_04C905
	.addr	sub_04C9F5
	.addr	sub_04C3F5
	.addr	sub_04C3F5
	.addr	sub_04C3F5
	.addr	sub_04C3F5
	.addr	sub_04C3F5
	.addr	sub_04C3F5
	.addr	sub_04CA59
	.addr	sub_04CAC3

sub_04C3F5:
	; (not executed in the CDL traces)
	rtl

sub_04C3F6:
	lda	#$0080
	sta	$0A,x
	lda	#$0010
	sta	$0E,x
	lda	#$0001
	sta	$16,x
	lda	#$0FFF
	sta	$06,x
	lda	#$0001
	sta	$28,x
	lda	#$FFFF
	sta	$2A,x
	ldy	#$0500
	lda	#$0081
	sta	a:$0010,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$C65B
	sta	a:$0000,y
	lda	#$401C
	sta	a:$0016,y
	phy
	ldy	$84
	lda	a:data_05F0EC,y
	ply
	sta	a:$0006,y
	sta	a:$003A,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFE0
	sta	a:$002A,y
	stz	$00
loc_04C44A:
	lda	$00
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	#$0053
	sta	a:$0010,y
	lda	#$C670
	sta	a:$0000,y
	lda	#$3E00
	sta	a:$0002,y
	inc	$00
	lda	$00
	cmp	#$0010
	bcc	loc_04C44A
	stz	$00
loc_04C46F:
	lda	$00
	asl	a
	tay
	lda	a:data_05F186,y
	tay
	lda	#$0053
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0100
	sta	a:$0006,y
	lda	#$0010
	sta	a:$0028,y
	lda	#$FFF0
	sta	a:$002A,y
	lda	#$C7E5
	sta	a:$0000,y
	lda	#$0080
	sta	a:$000A,y
	lda	#$0010
	sta	a:$000E,y
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001E,y
	sta	a:$001C,y
	inc	$00
	lda	$00
	cmp	#$0002
	bcc	loc_04C46F
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$3E,x
	lda	#$00C0
	sta	$36,x
	stz	$24,x
	inc	$12,x
	jmp	a:loc_04CD2B

sub_04C4D9:
	stz	$00
loc_04C4DB:
	lda	$00
	asl	a
	tay
	lda	a:data_05F114,y
	pha
	lda	a:data_05F156,y
	tay
	pla
	sta	a:$0036,y
	inc	$00
	lda	$00
	cmp	#$0010
	bcc	loc_04C4DB
	stz	$1C,x
	stz	$1E,x
	stz	$30,x
	stz	$24,x
	inc	$12,x
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

sub_04C504:
	ldy	#$0300
	lda	a:$000E,y
	bmi	loc_04C51D
	cmp	#$00B0
	bcc	loc_04C51D
	stz	$30,x
	stz	$24,x
	inc	$12,x
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B
loc_04C51D:
	stz	$02
loc_04C51F:
	lda	$02
	asl	a
	tay
	lda	a:ptrs_05F17E,y
	sta	$04
	stz	$00
loc_04C52A:
	lda	$00
	asl	a
	tay
	lda	($04),y
	tay
	lda	a:$0036,y
	dec	a
	dec	a
	bmi	loc_04C53B
	sta	a:$0036,y
loc_04C53B:
	inc	$00
	lda	$00
	cmp	#$0007
	bcc	loc_04C52A
	inc	$02
	lda	$02
	cmp	#$0002
	bcc	loc_04C51F
	lda	$1C,x
	clc
	adc	#$1000
	sta	$1C,x
	bcc	loc_04C559
	inc	$1E,x
loc_04C559:
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

sub_04C55F:
	ldy	#$0700
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF
	sta	a:$001A,y
	ldy	#$0300
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF
	sta	a:$001A,y
	sta	$1A,x
	stz	$18,x
	lda	$1E,x
	cmp	#$0002
	bcc	loc_04C599
	lda	#$0038
	bra	loc_04C59C
loc_04C599:
	lda	#$0039
loc_04C59C:
	jsl	f:sub_00868F
	stz	$30,x
	stz	$38,x
	stz	$24,x
	inc	$12,x
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

sub_04C5AE:
	lda	$30,x
	bne	loc_04C5D7
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	$0E,x
	cmp	#$0060
	bcc	loc_04C5C5
	inc	$30,x
	jmp	a:loc_04CD2B
loc_04C5C5:
	lda	$1C,x
	sec
	sbc	#$2000
	sta	$1C,x
	bcs	loc_04C5D1
	dec	$1E,x
loc_04C5D1:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C5D7:
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	$0E,x
	cmp	#$0060
	bcs	loc_04C60E
	stz	$1C,x
	stz	$1E,x
	stz	$30,x
	stz	$24,x
	ldy	#$0700
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	sta	a:$001A,y
	sta	a:$0018,y
	stz	$1A,x
	stz	$18,x
	inc	$12,x
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C60E:
	lda	$1C,x
	clc
	adc	#$8000
	sta	$1C,x
	bcc	loc_04C61A
	inc	$1E,x
loc_04C61A:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

sub_04C620:
	ldy	#$0300
	lda	a:$000E,y
	sta	$34,x
	stz	$00
loc_04C62A:
	lda	$00
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	$0A,x
	sta	a:$0032,y
	lda	$0E,x
	sta	a:$0034,y
	inc	$00
	lda	$00
	cmp	#$0008
	bcc	loc_04C62A
	stz	$30,x
	stz	$36,x
	stz	$38,x
	stz	$24,x
	lda	$0A,x
	bmi	loc_04C658
	cmp	#$0080
	bcc	loc_04C658
	inc	$38,x
loc_04C658:
	lda	$38,x
	asl	a
	tay
	lda	a:data_05F0F4,y
	sta	$00
	lda	a:data_05F0F8,y
	sta	$02
	lda	a:data_05F0FC,y
	sta	$04
	lda	a:data_05F100,y
	sta	$06
	ldy	#$0300
	lda	#$0001
	sta	a:$0030,y
	lda	#$0000
	sta	a:$001C,y
	sta	a:$001E,y
	lda	$00
	sta	a:$0018,y
	lda	$02
	sta	a:$001A,y
	ldy	#$0700
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001C,y
	lda	#$FFFE
	sta	a:$001E,y
	lda	$04
	sta	a:$0018,y
	lda	$06
	sta	a:$001A,y
	inc	$12,x
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

sub_04C6B3:
	ldy	#$0500
	lda	a:$003A,y
	sec
	sbc	a:$0006,y
	cmp	#$0020
	bcs	loc_04C6D5
	lda	$0A,x
	bmi	loc_04C6D2
	cmp	#$0028
	bcc	loc_04C6D2
	cmp	#$00B0
	bcs	loc_04C6D2
	bra	loc_04C6E1
loc_04C6D2:
	jmp	a:loc_04C83E
loc_04C6D5:
	ldy	#$0500
	lda	a:$0006,y
	sta	a:$003A,y
	jmp	a:loc_04C80E
loc_04C6E1:
	stz	$00
loc_04C6E3:
	lda	$00
	asl	a
	tay
	lda	a:data_05F17A,y
	sta	$02
	lda	a:data_05F186,y
	tay
	lda	a:$0030,y
	beq	loc_04C6F8
	jmp	a:loc_04C78F
loc_04C6F8:
	lda	a:$001E,y
	bpl	loc_04C700
	jmp	a:loc_04C77A
loc_04C700:
	lda	a:$000E,y
	cmp	#$00B0
	bcc	loc_04C77A
	lda	#$00B0
	sta	a:$000E,y
	lda	$32,x
	clc
	adc	#$0020
	clc
	adc	$02
	sta	a:$000A,y
	phy
	lda	$38,x
	asl	a
	tay
	lda	a:data_05F0F4,y
	sta	$04
	lda	a:data_05F0F8,y
	sta	$06
	lda	a:data_05F0FC,y
	sta	$08
	lda	a:data_05F100,y
	sta	$0A
	ply
	lda	#$0001
	sta	a:$0030,y
	lda	#$0000
	sta	a:$000C,y
	sta	a:$001C,y
	sta	a:$001E,y
	lda	$04
	sta	a:$0018,y
	lda	$06
	sta	a:$001A,y
	lda	$00
	asl	a
	tay
	lda	a:data_05F188,y
	tay
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001C,y
	lda	#$FFFC
	sta	a:$001E,y
	lda	$08
	sta	a:$0018,y
	lda	$0A
	sta	a:$001A,y
	lda	#$0037
	jsl	f:sub_00868F
	bra	loc_04C78F
loc_04C77A:
	lda	a:$001C,y
	clc
	adc	#$8000
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	bra	loc_04C78F
loc_04C78F:
	inc	$00
	lda	$00
	cmp	#$0002
	bcs	loc_04C79B
	jmp	a:loc_04C6E3
loc_04C79B:
	jsl	f:sub_01E860
	lda	a:$000A,y
	cmp	$0A,x
	bmi	loc_04C7C9
	lda	a:$000E,y
	sbc	#$0018
	cmp	$0E,x
	bpl	loc_04C805
	lda	$0A,x
	sta	$00
	clc
	adc	#$0010
	lda	$0E,x
	sec
	sbc	#$0008
	sta	$02
	lda	#$0010
	jsl	f:sub_01A11C
	bra	loc_04C805
loc_04C7C9:
	lda	#$0000
	jsl	f:sub_01A2F0
	bcc	loc_04C805
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,x
	lda	#$FFFF
	sta	a:$001A,x
	phy
	lda	$78
	and	#$0001
	asl	a
	tay
	lda	a:data_05F104,y
	sta	$00
	lda	a:data_05F108,y
	sta	$02
	ply
	lda	$00
	sta	a:$001C,y
	lda	$02
	sta	a:$001E,y
loc_04C805:
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C80E:
	lda	$0A,x
	adc	#$FFF0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$001F
	sta	$04
	lda	#$001F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04C83E
	lda	#$FFFD
	sta	a:$001E,y
	lda	#$FFFA
	sta	a:$001A,y
loc_04C83E:
	ldy	#$0700
	lda	#$00B0
	sta	a:$000E,y
	ldy	#$0300
	lda	#$00B0
	sta	a:$000E,y
	ldy	#$0700
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	stz	$30,x
	stz	$24,x
	inc	$12,x
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

sub_04C889:
	stz	$38,x
	lda	$0A,x
	bmi	loc_04C894
	cmp	#$0080
	bcs	loc_04C896
loc_04C894:
	inc	$38,x
loc_04C896:
	lda	$38,x
	asl	a
	tay
	lda	a:data_05F10C,y
	sta	$00
	lda	a:data_05F110,y
	sta	$02
	ldy	#$0700
	lda	#$FFFF
	sta	a:$001E,y
	lda	#$8000
	sta	a:$001C,y
	lda	$02
	sta	a:$001A,y
	lda	$00
	sta	a:$0018,y
	ldy	#$0300
	lda	#$FFFF
	sta	a:$001E,y
	lda	#$8000
	sta	a:$001C,y
	lda	$02
	sta	a:$001A,y
	lda	$00
	sta	a:$0018,y
	lda	#$FFFE
	sta	$1E,x
	lda	#$8000
	sta	$1C,x
	lda	$02
	sta	$1A,x
	lda	$00
	sta	$18,x
	stz	$30,x
	stz	$38,x
	stz	$24,x
	inc	$12,x
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	lda	$0A,x
	sta	$00
	lda	$0E,x
	sta	$02
	jsl	f:sub_01A0E9
	jmp	a:loc_04CD2B

sub_04C905:
	lda	$1C,x
	clc
	adc	#$0400
	sta	$1C,x
	bcc	loc_04C911
	inc	$1E,x
loc_04C911:
	ldy	#$0300
	lda	a:$001C,y
	clc
	adc	#$0400
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	ldy	#$0700
	lda	a:$001C,y
	clc
	adc	#$0400
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	lda	$30,x
	bne	loc_04C9AB
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	$0E,x
	cmp	#$0060
	bcc	loc_04C951
	inc	$30,x
loc_04C951:
	lda	$0A,x
	clc
	adc	a:data_05F17A
	sta	$00
	ldy	#$0300
	lda	a:$000A,y
	cmp	$00
	bpl	loc_04C970
	lda	a:$000A,y
	inc	a
	cmp	$00
	bpl	loc_04C97B
	sta	a:$000A,y
	bra	loc_04C97B
loc_04C970:
	lda	a:$000A,y
	dec	a
	cmp	$00
	bmi	loc_04C97B
	sta	a:$000A,y
loc_04C97B:
	lda	$0A,x
	clc
	adc	a:data_05F17C
	sta	$00
	ldy	#$0700
	lda	a:$000A,y
	cmp	$00
	bpl	loc_04C99A
	lda	a:$000A,y
	inc	a
	cmp	$00
	bpl	loc_04C9A5
	sta	a:$000A,y
	bra	loc_04C9A5
loc_04C99A:
	lda	a:$000A,y
	dec	a
	cmp	$00
	bmi	loc_04C9A5
	sta	a:$000A,y
loc_04C9A5:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C9AB:
	stz	$00
loc_04C9AD:
	lda	$00
	asl	a
	tay
	lda	a:data_05F134,y
	pha
	lda	a:data_05F156,y
	tay
	pla
	sta	a:$0036,y
	inc	$00
	lda	$00
	cmp	#$0010
	bcc	loc_04C9AD
	ldy	#$0700
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	inc	$12,x
	stz	$30,x
	stz	$38,x
	stz	$24,x
	jmp	a:loc_04CD2B

sub_04C9F5:
	lda	$1E,x
	bmi	loc_04CA15
	ldy	#$0300
	lda	a:$000E,y
	bmi	loc_04CA15
	cmp	#$00B0
	bcc	loc_04CA15
	stz	$30,x
	stz	$24,x
	lda	#$0003
	sta	$12,x
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B
loc_04CA15:
	stz	$02
loc_04CA17:
	lda	$02
	asl	a
	tay
	lda	a:ptrs_05F17E,y
	sta	$04
	stz	$00
loc_04CA22:
	lda	$00
	asl	a
	tay
	lda	($04),y
	tay
	lda	a:$0036,y
	sec
	sbc	#$0004
	bmi	loc_04CA35
	sta	a:$0036,y
loc_04CA35:
	inc	$00
	lda	$00
	cmp	#$0007
	bcc	loc_04CA22
	inc	$02
	lda	$02
	cmp	#$0002
	bcc	loc_04CA17
	lda	$1C,x
	clc
	adc	#$0400
	sta	$1C,x
	bcc	loc_04CA53
	inc	$1E,x
loc_04CA53:
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

sub_04CA59:
	lda	#$0001
	sta	$16,x
	stz	$06,x
	lda	#$0005
	sta	$1A,x
	lda	#$FFFD
	sta	$1E,x
	stz	$24,x
	stz	$00
loc_04CA6E:
	lda	$00
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	#$0088
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	$E8
	adc	$78
	sta	$E8
	and	#$0003
	sta	a:$001A,y
	lda	#$8000
	sta	a:$0018,y
	lda	$E9
	adc	$78
	sta	$E9
	ora	#$FFF8
	sta	a:$001E,y
	lda	#$8000
	sta	a:$001C,y
	lda	#$0000
	sta	a:$0024,y
	inc	$00
	lda	$00
	cmp	#$0010
	bcc	loc_04CA6E
	lda	#$0041
	jsl	f:sub_00868F
	stz	$30,x
	inc	$12,x
	jmp	a:loc_04CD2B

sub_04CAC3:
	lda	$0A,x
	adc	#$FFE0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$001F
	sta	$04
	lda	#$001F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_04CAF3
	lda	#$FFFD
	sta	a:$001E,y
	lda	#$FFFA
	sta	a:$001A,y
loc_04CAF3:
	jsl	f:sub_04CAFA
	jmp	a:loc_04CD2B

sub_04CAFA:
	lda	a:$0024,x
	inc	a
	sta	a:$0024,x
	cmp	#$0168
	bcs	loc_04CB1A
	lda	a:$000A,x
	bit	#$FE00
	bne	loc_04CB1A
	lda	a:$000E,x
	clc
	adc	#$0100
	bit	#$FE00
	beq	loc_04CB22
loc_04CB1A:
	lda	#$8000
	sta	a:$0016,x
	bra	loc_04CB61
loc_04CB22:
	lda	a:$001E,x
	bmi	loc_04CB3B
	lda	a:$000E,x
	bmi	loc_04CB3B
	cmp	#$00B8
	bcc	loc_04CB3B
	lda	a:$001E,x
	eor	#$FFFF
	inc	a
	sta	a:$001E,x
loc_04CB3B:
	lda	a:$001C,x
	clc
	adc	#$4000
	sta	a:$001C,x
	lda	a:$001E,x
	adc	#$0000
	sta	a:$001E,x
	lda	a:$0018,x
	sec
	sbc	#$2000
	sta	a:$0018,x
	lda	a:$001A,x
	sbc	#$0000
	sta	a:$001A,x
loc_04CB61:
	rtl
	; CDL: not accessed
	.byte	$6B

sub_04CB63:
	phx
	stx	$10
	stz	$0A
loc_04CB68:
	lda	$0A
	asl	a
	tay
	lda	a:data_05F17A,y
	pha
	lda	a:data_05F176,y
	tay
	pla
	ldx	$10
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	a:$0036,y
	sta	$08
	lda	$0A
	asl	a
	tay
	lda	a:ptrs_05F17E,y
	sta	$0C
	lda	a:ptrs_05F182,y
	sta	$0E
	stz	$00
loc_04CB97:
	lda	$00
	asl	a
	tay
	lda	($0C),y
	tax
	lda	($0E),y
	sta	$02
	lda	$08
	clc
	adc	$36,x
	sta	$08
	and	#$00FF
	asl	a
	phx
	tax
	lda	f:data_058E9A,x
	sta	$04
	lda	f:data_058F1A,x
	sta	$06
	plx
	ldy	$02
	lda	a:$000A,y
	clc
	adc	$04
	sta	$0A,x
	lda	a:$000E,y
	clc
	adc	$06
	sta	$0E,x
	inc	$00
	lda	$00
	cmp	#$0007
	bcc	loc_04CB97
	inc	$0A
	lda	$0A
	cmp	#$0002
	bcc	loc_04CB68
	plx
	rts

sub_04CBE2:
	stz	$00
loc_04CBE4:
	lda	$00
	asl	a
	tay
	lda	a:data_05F17A,y
	pha
	lda	a:data_05F176,y
	tay
	pla
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	inc	$00
	lda	$00
	cmp	#$0002
	bcc	loc_04CBE4
	phx
	stx	$06
	stz	$00
loc_04CC0A:
	lda	$00
	asl	a
	tay
	lda	a:data_05F190,y
	tax
	lda	$0E,x
	pha
	lda	a:data_05F1B4,y
	tax
	pla
	clc
	adc	$0E,x
	lsr	a
	pha
	lda	a:data_05F1D8,y
	tax
	pla
	sta	$0E,x
	sta	$08
	lda	a:data_05F190,y
	tax
	lda	$0A,x
	pha
	lda	a:data_05F1B4,y
	tax
	pla
	clc
	adc	$0A,x
	lsr	a
	cpy	#$0000
	beq	loc_04CC42
	cpy	#$0012
	bne	loc_04CC66
loc_04CC42:
	pha
	lda	$08
	ldx	$06
	sec
	sbc	$0E,x
	bpl	loc_04CC50
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
loc_04CC50:
	cmp	#$0030
	bcc	loc_04CC58
	lda	#$0030
loc_04CC58:
	sta	$0A
	lda	#$0030
	sec
	sbc	$0A
	sta	$04
	pla
	sec
	sbc	$04
loc_04CC66:
	pha
	lda	a:data_05F1D8,y
	tax
	pla
	sta	$0A,x
	inc	$00
	lda	$00
	cmp	#$0012
	bcc	loc_04CC0A
	stz	$00
loc_04CC79:
	lda	$00
	asl	a
	tay
	lda	a:data_05F186,y
	tay
	lda	a:$000A,y
	clc
	adc	#$0008
	pha
	lda	a:$000E,y
	clc
	adc	#$0008
	pha
	lda	$00
	asl	a
	tay
	lda	a:data_05F18C,y
	tay
	pla
	sta	a:$000E,y
	pla
	sta	a:$000A,y
	inc	$00
	lda	$00
	cmp	#$0002
	bcc	loc_04CC79
	plx
	rts

sub_04CCAC:
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:data_05F17A
	ldy	#$0700
	adc	a:$000A,y
	sec
	sbc	a:data_05F17C
	clc
	lsr	a
	sta	$02
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:data_05F17A
	ldy	#$0700
	clc
	adc	a:data_05F17C
	sec
	sbc	a:$000A,y
	bpl	loc_04CCDF
	eor	#$FFFF
	inc	a
loc_04CCDF:
	cmp	#$0060
	bcc	loc_04CCE7
	; (not executed in the CDL traces)
	lda	#$0060
loc_04CCE7:
	lsr	a
	sta	$00
	lda	#$0060
	sec
	sbc	$00
	sta	$04
	lda	$34,x
	sec
	sbc	$04
	sta	$04
	lda	$36,x
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	$02
	sta	a:$0032,y
	sta	$32,x
	lda	$04
	sta	a:$0034,y
	lda	$36,x
	inc	a
	cmp	#$0008
	bcc	loc_04CD18
	lda	#$0000
loc_04CD18:
	sta	$36,x
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	a:$0032,y
	sta	$0A,x
	lda	a:$0034,y
	sta	$0E,x
	rts
loc_04CD2B:
	ldy	#$0500
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	rtl

sub_04CD39:
	lda	a:data_05F154
	tay
	lda	a:$0010,y
	bne	loc_04CD47
	lda	#$8000
	sta	$16,x
loc_04CD47:
	rtl

sub_04CD48:
	jsr	a:sub_049B74
	lda	$06,x
	bpl	loc_04CD65
	lda	#$001C
	sta	$30,x
	jsr	a:sub_04CE28
	lda	#$0010
	sta	$24,x
	stz	$16,x
	stz	$06,x
	lda	#$0004
	sta	$12,x
loc_04CD65:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04CD74,x
	plx
	sta	$00
	jmp	($0000)
tbl_04CD74:
	.addr	sub_04CD7E
	.addr	sub_04CD9D
	.addr	sub_04CDAB
	.addr	sub_04CDCC
	.addr	sub_049B8F

sub_04CD7E:
	inc	$12,x
	stz	$16,x
	lda	#$0020
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	ldy	$3A,x
	lda	a:data_05F1FC,y
	sta	$24,x
	lda	$84
	asl	a
	clc
	adc	#$0010
	sta	$06,x
	rtl

sub_04CD9D:
	cmp	#$0002
	beq	sub_04CDCC
	dec	$24,x
	bne	loc_04CDAA
	inc	$12,x
	stz	$30,x
loc_04CDAA:
	rtl

sub_04CDAB:
	inc	$24,x
	lda	$24,x
	bit	#$0007
	bne	loc_04CDCB
	jsr	a:sub_04CE28
	clc
	lda	$30,x
	adc	#$0004
	sta	$30,x
	cmp	#$0010
	bne	loc_04CDCB
	inc	$12,x
	lda	#$4010
	sta	$16,x
loc_04CDCB:
	rtl

sub_04CDCC:
	lda	#$0400
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	lsr	a
	lsr	a
	and	#$003E
	cmp	#$0018
	bcs	loc_04CDE6
	lda	#$0018
	bra	loc_04CDEE
loc_04CDE6:
	cmp	#$0028
	bcc	loc_04CDEE
	lda	#$0028
loc_04CDEE:
	pha
	sec
	sbc	#$0018
	ldy	#$FFFE
loc_04CDF6:
	iny
	iny
	sec
	sbc	#$0006
	bpl	loc_04CDF6
	lda	a:data_05F222,y
	sta	$30,x
	phy
	jsr	a:sub_04CE28
	ply
	clc
	lda	a:data_05F228,y
	adc	$0E,x
	sta	$02
	clc
	lda	a:data_05F22E,y
	adc	$0A,x
	sta	$00
	dec	$24,x
	bpl	loc_04CE26
	lda	#$0100
	sta	$24,x
	pla
	jml	f:sub_01A11C
loc_04CE26:
	pla
	rtl

sub_04CE28:
	ldy	$30,x
	lda	a:data_05F202,y
	sta	$00
	lda	a:data_05F204,y
	pha
	ldy	$3A,x
	lda	a:data_05F234,y
	sta	$FC
	jsl	f:sub_00FE76
	pla
	sta	$00
	clc
	lda	$FC
	adc	#$0080
	jsl	f:sub_00FE76
	rts

sub_04CE4C:
	jsr	a:sub_049B74
	lda	$06,x
	bpl	loc_04CE80
	; (not executed in the CDL traces)
	lda	#$0002
	sta	$12,x
	stz	$06,x
	stz	$16,x
	ldy	$3A,x
	lda	#$0010
	sta	$24,x
	lda	#$59C0
	sta	$00
	lda	a:data_05F23A,y
	sta	$FC
	jsl	f:sub_00FE76
	lda	#$5000
	sta	$00
	clc
	lda	$FC
	adc	#$0080
	jml	f:sub_00FE76
loc_04CE80:
	lda	$12,x
	bne	loc_04CE9F
	inc	$12,x
	lda	#$4010
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFC0
	sta	$2A,x
	stz	$24,x
	ldy	$84
	lda	a:data_05F26C,y
	sta	$06,x
	rtl
loc_04CE9F:
	cmp	#$0002
	bne	loc_04CEA7
	; (not executed in the CDL traces)
	brl	sub_049B8F
loc_04CEA7:
	dec	$24,x
	bpl	loc_04CED7
	ldy	$3A,x
	lda	a:data_05F260,y
	sta	$24,x
	ldy	#$0580
	jsl	f:sub_019EC1
	bcc	loc_04CED7
	lda	#$007B
	sta	a:$0010,y
	clc
	lda	$0A,x
	adc	#$0001
	sta	a:$000A,y
	clc
	lda	$0E,x
	adc	#$0008
	sta	a:$000E,y
	txa
	sta	a:$0032,y
loc_04CED7:
	rtl

sub_04CED8:
	ldy	$32,x
	lda	a:$0010,y
	cmp	#$007A
	bne	loc_04CEE7
	lda	a:$0016,y
	bne	loc_04CEED
loc_04CEE7:
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	rtl
loc_04CEED:
	jsr	a:sub_049B74
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04CEFF,x
	plx
	sta	$00
	jmp	($0000)
tbl_04CEFF:
	.addr	sub_04CF07
	.addr	sub_04CF28
	.addr	sub_04CF3B
	.addr	sub_04CF51

sub_04CF07:
	inc	$12,x
	lda	#$0018
	sta	$24,x
	lda	#$000C
	sta	$16,x
	lda	#$F246
	sta	$20,x
	lda	#$0008
	sta	$28,x
	lda	#$FFC0
	sta	$2A,x
	lda	#$3000
	sta	$02,x
	rtl

sub_04CF28:
	dec	$24,x
	bpl	loc_04CF3A
	inc	$12,x
	lda	#$0008
	sta	$24,x
	lda	#$0014
	jml	f:sub_00868F
loc_04CF3A:
	rtl

sub_04CF3B:
	dec	$24,x
	bpl	loc_04CF48
	inc	$12,x
	lda	#$0020
	sta	$24,x
	inc	$04,x
loc_04CF48:
	clc
	lda	$0E,x
	adc	#$0008
	sta	$0E,x
	rtl

sub_04CF51:
	dec	$24,x
	bpl	loc_04CF5B
	lda	#$8000
	sta	$16,x
	rtl
loc_04CF5B:
	lda	$BC
	bne	loc_04CF90
	ldy	#$0580
	jsl	f:sub_019EC1
	bcc	loc_04CF90
	lda	#$C672
	jsl	f:sub_01CF66
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$E8
	and	#$0007
	pha
	clc
	adc	#$FFFC
	sta	a:$001E,y
	pla
	clc
	adc	#$FFF7
	sta	a:$001A,y
	inc	$E8
loc_04CF90:
	rtl

sub_04CF91:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04CFA0,x
	plx
	sta	$00
	jmp	($0000)
tbl_04CFA0:
	.addr	sub_04CFAA
	.addr	sub_04D029
	.addr	sub_04D0B1
	.addr	sub_04D0DC
	.addr	sub_04D0E3

sub_04CFAA:
	inc	$12,x
	lda	#$C81D
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	lda	#$001E
	sta	$28,x
	lda	#$FFE2
	sta	$2A,x
	stz	$30,x
	stz	$32,x
	stz	$FC
	stx	$02
	phx
	ldx	#$0A80
loc_04CFCC:
	cpx	#$07C0
	bcc	loc_04D020
	jsl	f:sub_019ED4
	bcc	loc_04CFCC
	lda	#$007D
	sta	$10,x
	lda	#$0002
	sta	$12,x
	lda	$FC
	sta	$30,x
	phx
	tax
	lda	#$F000
	sta	f:$7EA070,x
	sta	f:$7EA072,x
	sta	f:$7EA074,x
	sta	f:$7EA076,x
	sta	f:$7EA078,x
	sta	f:$7EA07A,x
	sta	f:$7EA07C,x
	sta	f:$7EA07E,x
	plx
	lda	$02
	sta	$3E,x
	stz	$34,x
	clc
	lda	$FC
	adc	#$0010
	sta	$FC
	cmp	#$0070
	bcc	loc_04CFCC
	inc	$34,x
loc_04D020:
	plx
	stz	$3A,x
	lda	#$0100
	sta	$36,x
	rtl

sub_04D029:
	jsr	a:sub_049B74
	lda	$3A,x
	bne	loc_04D044
	clc
	lda	$38,x
	adc	#$0002
	bmi	loc_04D053
	cmp	#$0010
	bcc	loc_04D053
	ldy	#$0002
	sty	$3A,x
	bra	loc_04D053
loc_04D044:
	sec
	lda	$38,x
	sbc	#$0002
	bpl	loc_04D053
	cmp	#$FFB0
	bcs	loc_04D053
	stz	$3A,x
loc_04D053:
	sta	$38,x
	sta	f:$7EA0E2
	lda	#$0200
	jsl	f:sub_01A15D
	jsl	f:sub_01A0C8
	asl	a
	cmp	$36,x
	bcc	loc_04D079
	clc
	lda	$36,x
	adc	#$0002
	cmp	#$0160
	bcc	loc_04D087
	lda	#$0160
	bra	loc_04D087
loc_04D079:
	sec
	lda	$36,x
	sbc	#$0002
	cmp	#$00A0
	bcs	loc_04D087
	lda	#$00A0
loc_04D087:
	and	#$01FE
	sta	$36,x
	sta	f:$7EA0E0
	txy
	clc
	lda	$30,x
	adc	$32,x
	tax
	lda	a:$000E,y
	sta	f:$7EA000,x
	lda	a:$000A,y
	sta	f:$7EA070,x
	tyx
	lda	$32,x
	adc	#$0002
	and	#$000E
	sta	$32,x
	rtl

sub_04D0B1:
	lda	#$C81D
	ldy	$34,x
	beq	loc_04D0BB
	lda	#$C82E
loc_04D0BB:
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	lda	#$403C
	sta	$16,x
	lda	#$001E
	sta	$28,x
	lda	#$FFE2
	sta	$2A,x
	stz	$32,x
	inc	$12,x
	lda	$34,x
	beq	loc_04D0DB
	inc	$12,x
loc_04D0DB:
	rtl

sub_04D0DC:
	jsr	a:sub_04D0EA
	jsr	a:sub_04D142
	rtl

sub_04D0E3:
	jsr	a:sub_04D0EA
	jsr	a:sub_04D158
	rtl

sub_04D0EA:
	ldy	$3E,x
	lda	a:$0010,y
	cmp	#$007D
	beq	loc_04D106
	lda	#$FFFB
	sta	$1A,x
	lda	#$0001
	sta	$16,x
	txy
	lda	#$C516
	jsl	f:sub_01CF66
loc_04D106:
	phx
	lda	f:$7EA0E0
	and	#$01FE
	tay
	clc
	adc	f:$7EA0E2
	sta	f:$7EA0E0
	clc
	lda	$32,x
	adc	#$0004
	and	#$000E
	clc
	adc	$30,x
	tax
	lda	a:data_058F1A,y
	adc	f:$7EA070,x
	sta	$00
	lda	a:data_058E9A,y
	adc	f:$7EA000,x
	sta	$02
	plx
	lda	$32,x
	inc	a
	inc	a
	and	#$000E
	sta	$32,x
	rts

sub_04D142:
	clc
	adc	#$0010
	clc
	adc	$30,x
	phx
	tax
	lda	$00
	sta	f:$7EA070,x
	lda	$02
	sta	f:$7EA000,x
	plx

sub_04D158:
	lda	$02
	sta	$0E,x
	lda	$00
	sta	$0A,x
	rts

sub_04D161:
	jsr	a:sub_049B74
	lda	$06,x
	bpl	loc_04D1A6
	; (not executed in the CDL traces)
	stz	$06,x
	stz	$16,x
	lda	#$0002
	sta	$12,x
	lda	#$0020
	sta	$24,x
	lda	#$0001
	sta	$02
	lda	#$0018
	sta	$08
	ldy	#$F272
	lda	#$4100
	phx
	ldx	#$0000
	jsl	f:sub_00FEAA
	lda	#$0001
	sta	$02
	lda	#$0030
	sta	$08
	ldy	#$F272
	lda	#$451C
	ldx	#$0018
	jsl	f:sub_00FEAA
	plx
loc_04D1A6:
	lda	$12,x
	bne	loc_04D1C6
	inc	$12,x
	lda	#$4010
	sta	$16,x
	lda	#$0080
	sta	$06,x
	lda	#$003C
	sta	$28,x
	lda	#$FFE2
	sta	$2A,x
	lda	#$0001
	sta	$24,x
	rtl
loc_04D1C6:
	cmp	#$0002
	bne	loc_04D1CE
	; (not executed in the CDL traces)
	brl	sub_049B8F
loc_04D1CE:
	lda	$24,x
	beq	loc_04D207
	lda	#$0800
	jsl	f:sub_01A15D
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bmi	loc_04D1E6
	cmp	#$0060
	bcs	loc_04D207
loc_04D1E6:
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_04D207
	lda	#$0080
	sta	a:$0010,y
	lda	$0A,x
	adc	#$000C
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	stz	$24,x
loc_04D207:
	rtl

sub_04D208:
	lda	$12,x
	bne	loc_04D230
	inc	$12,x
	lda	#$000F
	sta	$16,x
	lda	#$0003
	sta	$1A,x
	sta	$1E,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$F278
	sta	$20,x
	lda	#$0015
	jml	f:sub_00868F
loc_04D230:
	cmp	#$0002
	beq	loc_04D26C
	lda	$0E,x
	cmp	#$00B0
	bcc	loc_04D247
	stz	$1C,x
	stz	$1E,x
	lda	#$FFF8
	sta	$1A,x
	inc	$12,x
loc_04D247:
	ldy	#$05C0
	jsl	f:sub_019EC1
	bcc	loc_04D2AC
	lda	#$C672
	jsl	f:sub_01CF66
	lda	#$FFFA
	sta	a:$001A,y
	sta	a:$001E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	bra	loc_04D2AC
loc_04D26C:
	jsl	f:sub_00FD92
	lda	#$001F
	sta	$04
	lda	#$0007
	sta	$06
	lda	$0A,x
	sta	$00
	lda	#$00B0
	sta	$02
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF3C
	bcs	loc_04D2AC
	lda	$EA
	and	#$0003
	adc	#$FFF8
	sta	a:$001E,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
	lda	#$000F
	sta	a:$0016,y
loc_04D2AC:
	ldy	$20,x
	lda	a:$0004,y
	sta	$02,x
	rtl

sub_04D2B4:
	cpx	#$0900
	bne	loc_04D2ED
	lda	$06,x
	bmi	loc_04D2C6
	lda	$0E,x
	cmp	#$0180
	bmi	loc_04D2ED
	; (not executed in the CDL traces)
	bcc	loc_04D2ED
loc_04D2C6:
	jsl	f:sub_01A52C
	stz	$20,x
	stz	$22,x
	lda	#$CB30
	sta	$00,x
	lda	#$0002
	sta	$1A,x
	stz	$1E,x
	lda	#$000C
	sta	$12,x
	lda	#$0001
	sta	$16,x
	stz	$06,x
	lda	#$0015
	jsl	f:sub_00868F
loc_04D2ED:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_04D2FC,x
	plx
	sta	$00
	jmp	($0000)
tbl_04D2FC:
	.addr	sub_04D316
	.addr	sub_04D32F
	.addr	sub_04D373
	.addr	sub_04D451
	.addr	sub_04D461
	.addr	sub_04D42C
	.addr	sub_04D500
	.addr	sub_04D532
	.addr	sub_04D56D
	.addr	sub_04D57C
	.addr	sub_04D5C3
	.addr	sub_04D608
	.addr	sub_04D622

sub_04D316:
	lda	a:$13FA
	cmp	#$000B
	bne	loc_04D32E
	inc	$12,x
	lda	#$01C0
	sta	$24,x
	phx
	ldx	#.loword(data_05F286)
	jsl	f:sub_0090A8
	plx
loc_04D32E:
	rtl

sub_04D32F:
	dec	$24,x
	bpl	loc_04D372
	lda	#$0015
	jsl	f:sub_00868F
	lda	#$C859
	sta	$00,x
	lda	#$3400
	sta	$02,x
	lda	#$401D
	sta	$16,x
	lda	#$00F0
	sta	$0E,x
	stz	$0A,x
	lda	#$0010
	sta	$28,x
	lda	#$FFEE
	sta	$2A,x
	lda	#$0080
	sta	$06,x
	lda	#$FFFE
	sta	$1E,x
	lda	#$8000
	sta	$1C,x
	sta	$18,x
	lda	#$0001
	sta	$1A,x
	inc	$12,x
loc_04D372:
	rtl

sub_04D373:
	lda	$0E,x
	cmp	#$0060
	bcs	loc_04D389
	cmp	#$0078
	bcs	loc_04D3B3
	jsl	f:sub_04D3B4
	lda	#$0006
	sta	$12,x
	rtl
loc_04D389:
	lda	#$000F
	sta	$06
	sta	$04
	lda	$0A,x
	adc	#$FFF0
	sta	$00
	lda	$0E,x
	sta	$02
	ldy	#$0700
	lda	#$C4CE
	jsl	f:sub_01CF3C
	bcs	loc_04D3B3
	lda	#$FFFC
	sta	a:$001A,y
	lda	#$0004
	sta	a:$001E,y
loc_04D3B3:
	rtl

sub_04D3B4:
	lda	#$0001
	sta	$00
	lda	#$0006
	sta	$04
	lda	#$0003
	ldy	#$0940
	jsl	f:sub_01A412
	stz	$34,x
	lda	#$0002
	sta	$32,x
	lda	#$0008
	sta	$FC
	phx
	ldx	#$08C0
loc_04D3D8:
	jsl	f:sub_019ED4
	bcc	loc_04D421
	lda	#$0084
	sta	$10,x
	lda	#$0005
	sta	$12,x
	lda	$FC
	sta	$34,x
	lda	#$3400
	sta	$02,x
	phx
	ldx	$FC
	lda	#$8000
	sta	f:$7EA070,x
	sta	f:$7EA072,x
	sta	f:$7EA074,x
	sta	f:$7EA076,x
	plx
	clc
	lda	$FC
	adc	#$0008
	sta	$FC
	cmp	#$0070
	bcc	loc_04D3D8
	lda	#$0004
	sta	$12,x
	lda	#$3400
	sta	$02,x
	stz	$16,x
loc_04D421:
	plx
	stz	a:$1638
	lda	#$0004
	sta	a:$1640
	rtl

sub_04D42C:
	lda	a:$0916
	cmp	#$0001
	bne	loc_04D43A
	lda	#$8000
	sta	$16,x
	rtl
loc_04D43A:
	lda	#$0000
	ldy	a:$163E
	bne	loc_04D445
	lda	#$CB86
loc_04D445:
	sta	$00,x
	jsr	a:sub_04D686
	jsr	a:sub_04D6E7
	jsr	a:sub_04D701
	rtl

sub_04D451:
	jsr	a:sub_04D70A
	jsr	a:sub_04D7C7

sub_04D457:
	jsr	a:sub_04D686
	jsr	a:sub_04D724
	jml	f:sub_01A513

sub_04D461:
	lda	a:$0916
	cmp	#$0001
	bne	loc_04D46F
	lda	#$8000
	sta	$16,x
	rtl
loc_04D46F:
	stz	$16,x
	lda	#$0000
	ldy	a:$163E
	bne	loc_04D488
	lda	#$CB77
	ldy	$E4
	bne	loc_04D483
	lda	#$CB72
loc_04D483:
	ldy	#$0000
	sty	$16,x
loc_04D488:
	sta	$00,x
	lda	a:$1638
	beq	loc_04D4F6
	lda	#$CB72
	sta	$00,x
	lda	$0A,x
	sta	$00
	lda	$0E,x
	sta	$02
	jsr	a:sub_04D6DD
	jsr	a:sub_04D6E7
	jsr	a:sub_04D701
	lda	a:$163A
	bne	loc_04D4F5
	ldy	a:$163C
	lda	$0A,x
	cmp	#$0084
	bcc	loc_04D4C8
	cpy	#$0140
	bcc	loc_04D4F5
	cpy	#$0144
	bcs	loc_04D4F5
	lda	a:$1644
	bmi	loc_04D4F5
	lda	#$FFFF
	bra	loc_04D4DA
loc_04D4C8:
	cpy	#$00C0
	bcs	loc_04D4F5
	cpy	#$00BC
	bcc	loc_04D4F5
	lda	a:$1644
	bpl	loc_04D4F5
	lda	#$0001
loc_04D4DA:
	sta	a:$091A
	stz	a:$1638
	lda	#$0004
	sta	a:$1640
	lda	#$0006
	sta	a:$0912
	lda	#$FFFC
	sta	a:$091E
	stz	a:$091C
loc_04D4F5:
	rtl
loc_04D4F6:
	jsr	a:sub_04D686
	jsr	a:sub_04D701
	jsr	a:sub_04D737
	rtl

sub_04D500:
	lda	#$0007
	sta	$12,x
	lda	$1A,x
	bpl	loc_04D513
	stz	a:$1636
	stz	$04,x
	lda	#$0240
	bra	loc_04D51E
loc_04D513:
	lda	#$0002
	sta	a:$1636
	sta	$04,x
	lda	#$01C2
loc_04D51E:
	sta	a:$163C
	stz	a:$1642
	stz	a:$1644
	lda	#$F2F3
	sta	$20,x
	lda	#$0016
	sta	a:$163E

sub_04D532:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	ldy	$04,x
	clc
	lda	$0A,x
	adc	a:data_05F329,y
	sta	$00
	clc
	lda	$0E,x
	adc	#$FFEE
	sta	$02
	jsr	a:sub_04D6DD
	jsr	a:sub_04D6E7
	lda	a:$163E
	bne	loc_04D563
	stz	a:$1640
	bra	loc_04D566
loc_04D563:
	dec	a:$163E
loc_04D566:
	jml	f:sub_01A513
loc_04D56A:
	brl	sub_04D451

sub_04D56D:
	lda	a:$163C
	cmp	#$00FD
	bcc	loc_04D56A
	cmp	#$0103
	bcs	loc_04D56A
	inc	$12,x

sub_04D57C:
	lda	$BE
	bne	loc_04D5C0
	inc	a:$1640
	lda	a:$1640
	cmp	#$0004
	bcc	loc_04D5C0
	lda	#$0100
	sta	a:$163C
	lda	#$7FFF
	sta	a:$163E
	stz	a:$1642
	stz	a:$1644
	inc	$12,x
	lda	#$F30B
	sta	$20,x
	lda	#$0040
	sta	$24,x
	lda	#$0400
	jsl	f:sub_01A15D
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_04D5BB
	stz	$04,x
	bra	loc_04D5C0
loc_04D5BB:
	lda	#$0002
	sta	$04,x
loc_04D5C0:
	brl	sub_04D457

sub_04D5C3:
	dec	$24,x
	bne	loc_04D5D0
	inc	$12,x
	stz	a:$163E
	stz	$20,x
	stz	$22,x
loc_04D5D0:
	lda	$24,x
	cmp	#$0014
	bne	loc_04D5FB
	ldy	#$04C0
	jsl	f:sub_019EC1
	bcc	loc_04D5FB
	lda	#$0085
	sta	a:$0010,y
	lda	$04,x
	sta	a:$0004,y
	lda	$0A,x
	adc	#$0008
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
loc_04D5FB:
	jsl	f:sub_04D457
	lda	#$007C
	sta	$0E,x
	jml	f:sub_01A513

sub_04D608:
	lda	$BE
	bne	loc_04D61C
	dec	a:$1640
	bne	loc_04D61C
	lda	#$0003
	sta	$12,x
	lda	#$0002
	sta	a:$163A
loc_04D61C:
	jsr	a:sub_04D70A
	brl	sub_04D457

sub_04D622:
	lda	$0E,x
	cmp	#$0180
	bcs	loc_04D632
	lda	$0A,x
	bpl	loc_04D638
	cmp	#$FFC8
	bcs	loc_04D638
loc_04D632:
	lda	#$8000
	sta	$16,x
	rtl
loc_04D638:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	clc
	lda	$1C,x
	adc	#$0800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	$BC
	bne	loc_04D685
	ldy	#$0700
	jsl	f:sub_019EC1
	bcc	loc_04D685
	lda	#$C4CE
	jsl	f:sub_01CF66
	lda	$0A,x
	adc	#$0000
	sta	a:$000A,y
	lda	$E8
	and	#$000F
	adc	$0E,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$FFF8
	sta	a:$001A,y
loc_04D685:
	rtl

sub_04D686:
	phx
	lda	a:$163C
	and	#$01FE
	tay
	clc
	lda	a:data_058F1A,y
	bpl	loc_04D695
	sec
loc_04D695:
	ror	a
	sta	$00
	clc
	lda	a:data_058E9A,y
	bpl	loc_04D69F
	sec
loc_04D69F:
	ror	a
	sta	$02
	ldy	a:$1640
loc_04D6A5:
	cpy	#$0000
	beq	loc_04D6BF
	clc
	lda	$00
	bpl	loc_04D6B0
	sec
loc_04D6B0:
	ror	a
	sta	$00
	clc
	lda	$02
	bpl	loc_04D6B9
	sec
loc_04D6B9:
	ror	a
	sta	$02
	dey
	bra	loc_04D6A5
loc_04D6BF:
	clc
	lda	$32,x
	adc	#$0000
	and	#$0006
	clc
	adc	$34,x
	tax
	lda	$00
	adc	f:$7EA070,x
	sta	$00
	lda	$02
	adc	f:$7EA000,x
	sta	$02
	plx

sub_04D6DD:
	lda	$32,x
	inc	a
	inc	a
	and	#$0006
	sta	$32,x
	rts

sub_04D6E7:
	ldy	a:$1638
	clc
	adc	a:data_05F28F,y
	clc
	adc	$34,x
	phx
	tax
	lda	$00
	sta	f:$7EA070,x
	lda	$02
	sta	f:$7EA000,x
	plx
	rts

sub_04D701:
	lda	$02
	sta	$0E,x
	lda	$00
	sta	$0A,x
	rts

sub_04D70A:
	clc
	lda	a:$163C
	adc	#$0020
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	clc
	adc	$04,x
	tay
	sty	$3A,x
	lda	a:data_05F293,y
	sta	$00,x
	rts

sub_04D724:
	ldy	$3A,x
	clc
	lda	a:data_05F2B3,y
	adc	$00
	sta	$0A,x
	clc
	lda	a:data_05F2D3,y
	adc	$02
	sta	$0E,x
	rts

sub_04D737:
	lda	a:$091E
	bpl	loc_04D73D
	rts
loc_04D73D:
	ldy	#$0800
	lda	a:$000E,y
	cmp	$0E,x
	bcc	loc_04D7C6
	clc
	adc	#$FFF0
	cmp	$0E,x
	bcs	loc_04D7C6
	lda	a:$000A,y
	cmp	$0A,x
	bcs	loc_04D7C6
	clc
	adc	a:$0028,y
	cmp	$0A,x
	bcc	loc_04D7C6
	ldy	#$04C0
	jsl	f:sub_019EC1
	bcc	loc_04D78B
	lda	#$0033
	jsl	f:sub_00868F
	lda	#$C6BA
	jsl	f:sub_01CF66
	lda	#$FFFC
	sta	a:$001A,y
	lda	#$FFFE
	sta	a:$001E,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
loc_04D78B:
	ldy	#$0003
	lda	$E8
	and	#$0001
	bne	loc_04D79B
	lda	#$0080
	ldy	#$0008
loc_04D79B:
	sty	a:$0912
	sta	a:$163A
	stz	a:$0918
	stz	a:$091A
	stz	a:$091C
	stz	a:$091E
	stz	a:$0920
	stz	a:$0922
	lda	#$0002
	sta	a:$1638
	clc
	lda	a:$163C
	adc	#$00FE
	and	#$01FE
	sta	a:$163C
loc_04D7C6:
	rts

sub_04D7C7:
	lda	a:$163C
	ldy	a:$1636
	beq	loc_04D7F3
	cmp	#$0160
	bcs	loc_04D817
	lda	a:$1644
	bmi	loc_04D7DE
	cmp	#$0004
	bcs	loc_04D82A
loc_04D7DE:
	clc
	lda	a:$1642
	adc	#$8000
	sta	a:$1642
	lda	a:$1644
	adc	#$0000
	sta	a:$1644
	bra	loc_04D82A
loc_04D7F3:
	cmp	#$00A4
	bcc	loc_04D817
	lda	a:$1644
	bpl	loc_04D802
	cmp	#$FFFD
	bcc	loc_04D82A
loc_04D802:
	sec
	lda	a:$1642
	sbc	#$8000
	sta	a:$1642
	lda	a:$1644
	sbc	#$0000
	sta	a:$1644
	bra	loc_04D82A
loc_04D817:
	lda	a:$1636
	eor	#$0002
	sta	a:$1636
	sta	$04,x
	lda	a:$163A
	beq	loc_04D82A
	dec	a:$163A
loc_04D82A:
	clc
	lda	a:$1644
	adc	a:$163C
	sta	a:$163C
	rts

sub_04D835:
	lda	$12,x
	bne	loc_04D866
	inc	$12,x
	lda	#$F32D
	sta	$20,x
	lda	#$000F
	sta	$16,x
	lda	#$3400
	sta	$02,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	ldy	$04,x
	lda	a:data_05F33B,y
	sta	$1A,x
	lda	#$FFFF
	sta	$1E,x
	lda	#$2000
	sta	$1C,x
	rtl
loc_04D866:
	ldy	$04,x
	clc
	lda	$18,x
	adc	a:data_05F33F,y
	sta	$18,x
	lda	$1A,x
	adc	a:data_05F343,y
	sta	$1A,x
	rtl
