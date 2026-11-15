; topdown/stage_states.asm -- Top-down stages: state machine and setup
; Bank $02, $02:8000-$02:8E32. Included by main.asm in segment BANK02.
;
; Entered from sub_00AC3F for stages 2 and 5 (top-down, Mode 7): loc_028000
; dispatches $1E42 through tbl_028019 (tbl_028035 for $86 = 5); screen and
; graphics setup.

loc_028000:
	.a16
	.i16
	rep	#$30
	lda	$86
	cmp	#$0005
	beq	loc_028025
	lda	a:$1E42
	phx
	asl	a
	tax
	lda	f:tbl_028019,x
	plx
	sta	$00
	jmp	($0000)
tbl_028019:
	.addr	sub_028041
	.addr	sub_028068
	.addr	sub_028080
	.addr	sub_028097
	.addr	sub_02813D
	.addr	sub_02816D
loc_028025:
	lda	a:$1E42
	phx
	asl	a
	tax
	lda	f:tbl_028035,x
	plx
	sta	$00
	jmp	($0000)
tbl_028035:
	.addr	sub_028041
	.addr	sub_028200
	.addr	sub_028218
	.addr	sub_02822F
	.addr	sub_028271
	.addr	sub_0282A1

sub_028041:
	stz	a:$1EC4
	jsl	f:sub_00865C
	jsr	a:sub_028AEA
	jsr	a:sub_028A71
	jsr	a:sub_028A88
	jsr	a:sub_028AC8
	lda	#$0001
	sta	$64
	ldy	#$0001
	lda	a:$1E40
	beq	loc_028064
	; (not executed in the CDL traces)
	ldy	#$0004
loc_028064:
	sty	a:$1E42
	rtl

sub_028068:
	jsr	a:sub_028BE7
	jsl	f:sub_028D78
	jsr	a:sub_028B4B
	jsr	a:sub_028B7F
	jsr	a:sub_028D19
	jsl	f:sub_02ED3B
	inc	a:$1E42
	rtl

sub_028080:
	jsl	f:sub_04DA07
	jsr	a:sub_028500
	bcc	loc_028096
	jsl	f:sub_02E6C6
	lda	#$0080
	sta	a:$159C
	inc	a:$1E42
loc_028096:
	rtl

sub_028097:
	jsr	a:sub_028338
	bcc	loc_02809D
	; (not executed in the CDL traces)
	rtl
loc_02809D:
	jsl	f:sub_028E33
	jsl	f:sub_02E65F
	jsl	f:sub_02AC23
	jsl	f:sub_029CA3
	jsl	f:sub_02999D
	jsl	f:sub_02A9F8
	jsl	f:sub_02B7E6
	jsl	f:sub_02DC3B
	jsl	f:sub_02EF54
	jsl	f:sub_04DA07
	jsl	f:sub_02E7AF
	jsl	f:sub_02EB56
	jsr	a:sub_028D32
	jsr	a:sub_0280D9
	bcs	loc_0280D8
	jsr	a:sub_028105
loc_0280D8:
	rtl

sub_0280D9:
	lda	a:$1F8A
	ora	a:$1FCA
	bne	loc_028103
	; (not executed in the CDL traces)
	lda	a:$1E80
	beq	loc_0280F7
	cmp	#$000F
	bne	loc_028101
	stz	a:$1588
	lda	#$0081
	jsl	f:sub_00868F
	bra	loc_028101
loc_0280F7:
	stz	a:$1E42
	stz	a:$1580
	inc	$36
	stz	$42
loc_028101:
	sec
	rts
loc_028103:
	clc
	rts

sub_028105:
	lda	a:$159A
	bpl	loc_02813C
	lda	a:$159C
	cmp	#$0080
	bne	loc_028119
	lda	#$0081
	jsl	f:sub_00868F
loc_028119:
	dec	a:$159C
	bpl	loc_02813C
	lda	a:$1E80
	beq	loc_028134
	cmp	#$000F
	bne	loc_02813C
	stz	a:$1588
	lda	#$0081
	jsl	f:sub_00868F
	bra	loc_02813C
loc_028134:
	lda	#$0001
	sta	$64
	inc	a:$1E42
loc_02813C:
	rts

sub_02813D:
	jsr	a:sub_028C42
	jsl	f:sub_02B77D
	jsl	f:sub_02E6C6
	jsl	f:sub_028DB9
	jsr	a:sub_028B4B
	jsr	a:sub_028BA5
	lda	#$0068
	jsl	f:sub_00868F
	jsl	f:sub_02EBF2
	jsl	f:sub_02ED3B
	jsr	a:sub_028D03
	stz	$64
	stz	a:$1580
	inc	a:$1E42
	rtl

sub_02816D:
	lda	a:$1580
	cmp	#$0002
	bcs	loc_028199
	jsl	f:sub_028E33
	jsl	f:sub_02E65F
	jsl	f:sub_02AC23
	jsl	f:sub_02A9F8
	jsl	f:sub_02B7E6
	jsl	f:sub_02EF54
	jsl	f:sub_04DA07
	jsl	f:sub_02E7AF
	jsl	f:sub_02EB56
loc_028199:
	jsr	a:sub_028D32
	jsr	a:sub_0280D9
	bcs	loc_0281A4
	jsr	a:sub_0281A5
loc_0281A4:
	rtl

sub_0281A5:
	lda	a:$1580
	phx
	asl	a
	tax
	lda	f:tbl_0281B5,x
	plx
	sta	$00
	jmp	($0000)
tbl_0281B5:
	.addr	sub_0281BB
	.addr	sub_0281D4
	.addr	sub_0281E9

sub_0281BB:
	lda	a:$0AD2
	cmp	#$0012
	bne	loc_0281E8
	lda	#$0081
	jsl	f:sub_00868F
	lda	#$0080
	sta	a:$159C
	inc	a:$1580
	rts

sub_0281D4:
	dec	a:$159C
	bpl	loc_0281E8
	jsl	f:sub_00865C
	lda	#$0001
	sta	$64
	stz	a:$1588
	inc	a:$1580
loc_0281E8:
	rts

sub_0281E9:
	jsr	a:sub_028D32
	lda	a:$1E80
	bne	loc_0281E8
	jsl	f:sub_00865C
	stz	a:$1E42
	stz	a:$1580
	inc	$36
	stz	$42
	rts

sub_028200:
	jsr	a:sub_028C1F
	jsl	f:sub_028DDE
	jsr	a:sub_028B4B
	jsr	a:sub_028B92
	jsr	a:sub_028D19
	jsl	f:sub_02ED3B
	inc	a:$1E42
	rtl

sub_028218:
	jsl	f:sub_04DA07
	jsr	a:sub_028500
	bcc	loc_02822E
	jsl	f:sub_02E6C6
	lda	#$0080
	sta	a:$159C
	inc	a:$1E42
loc_02822E:
	rtl

sub_02822F:
	jsr	a:sub_028338
	bcc	loc_028235
	; (not executed in the CDL traces)
	rtl
loc_028235:
	jsl	f:sub_028E33
	jsl	f:sub_02E65F
	jsl	f:sub_02AC23
	jsl	f:sub_029CA3
	jsl	f:sub_0299E0
	jsl	f:sub_02A9F8
	jsl	f:sub_02B7E6
	jsl	f:sub_02DD19
	jsl	f:sub_02EF54
	jsl	f:sub_04DA07
	jsl	f:sub_02E7AF
	jsl	f:sub_02EB56
	jsr	a:sub_028D32
	jsr	a:sub_0280D9
	bcs	loc_028270
	jsr	a:sub_028105
loc_028270:
	rtl

sub_028271:
	jsr	a:sub_028CB5
	jsl	f:sub_02F18F
	jsl	f:sub_02E6C6
	jsl	f:sub_028E1B
	jsr	a:sub_028B4B
	jsr	a:sub_028BC6
	lda	#$0068
	jsl	f:sub_00868F
	jsl	f:sub_02EBF2
	jsl	f:sub_02ED3B
	jsr	a:sub_028D03
	stz	$64
	stz	a:$1580
	inc	a:$1E42
	rtl

sub_0282A1:
	lda	a:$1580
	cmp	#$0002
	bcs	loc_0282D1
	jsl	f:sub_028E33
	jsl	f:sub_02E65F
	jsl	f:sub_02AC09
	jsl	f:sub_029C9E
	jsl	f:sub_02A9F8
	jsl	f:sub_02B7E6
	jsl	f:sub_02EF54
	jsl	f:sub_04DA07
	jsl	f:sub_02E7AF
	jsl	f:sub_02EB56
loc_0282D1:
	jsr	a:sub_028D32
	jsr	a:sub_0280D9
	bcs	loc_0282DC
	jsr	a:sub_0282DD
loc_0282DC:
	rtl

sub_0282DD:
	lda	a:$1580
	phx
	asl	a
	tax
	lda	f:tbl_0282ED,x
	plx
	sta	$00
	jmp	($0000)
tbl_0282ED:
	.addr	sub_0282F3
	.addr	sub_02830C
	.addr	sub_028321

sub_0282F3:
	lda	a:$0AD2
	cmp	#$0009
	bne	loc_028320
	lda	#$0081
	jsl	f:sub_00868F
	lda	#$0040
	sta	a:$159C
	inc	a:$1580
	rts

sub_02830C:
	dec	a:$159C
	bpl	loc_028320
	jsl	f:sub_00865C
	lda	#$0001
	sta	$64
	stz	a:$1588
	inc	a:$1580
loc_028320:
	rts

sub_028321:
	jsr	a:sub_028D32
	lda	a:$1E80
	bne	loc_028320
	jsl	f:sub_00865C
	stz	a:$1E42
	stz	a:$1580
	inc	$36
	stz	$42
	rts

sub_028338:
	jsl	f:sub_04DA07
	lda	a:$1582
	asl	a
	tax
	jmp	(.loword(tbl_028344),x)
tbl_028344:
	.addr	sub_028354
	.addr	sub_02838F
	.addr	sub_0283BC
	.addr	sub_028427
	.addr	sub_02843F
	.addr	sub_02845A
	.addr	sub_02847B
	.addr	sub_0284C4

sub_028354:
	lda	$66
	bne	loc_02838D
	lda	#$0000
	ldy	a:$1F8A
	beq	loc_028362
	ora	$28
loc_028362:
	ldy	a:$1FCA
	beq	loc_028369
	ora	$2A
loc_028369:
	bit	#$2000
	beq	loc_02838D
	; (not executed in the CDL traces)
	lda	a:$1E80
	sta	a:$15D2
	lda	a:$1FB4
	sta	a:$15D4
	lda	a:$1FF4
	sta	a:$15D6
	lda	#$0001
	sta	$64
	lda	#$0001
	sta	a:$1582
	sec
	rts
loc_02838D:
	clc
	rts

sub_02838F:
	; (not executed in the CDL traces)
	lda	a:$1E80
	ora	a:$1FB4
	ora	a:$1FF4
	beq	loc_0283B4
	dec	a:$1E80
	bpl	loc_0283A2
	stz	a:$1E80
loc_0283A2:
	dec	a:$1FB4
	bpl	loc_0283AA
	stz	a:$1FB4
loc_0283AA:
	dec	a:$1FF4
	bpl	loc_0283B2
	stz	a:$1FF4
loc_0283B2:
	sec
	rts
loc_0283B4:
	inc	a:$1582
	jsr	a:sub_028D19
	sec
	rts

sub_0283BC:
	; (not executed in the CDL traces)
	stz	a:$1586
	lda	#$0001
	sta	a:$1590
	lda	#$0500
	sta	a:$1F94
	sta	a:$1F96
	lda	#$0000
	sta	a:$1F90
	lda	#$FFE6
	sta	a:$1F9A
	lda	#$0000
	sta	a:$1F92
	lda	#$FFF6
	sta	a:$1F9C
	stz	a:$1F98
	inc	a:$1582
	sep	#$20
	.a8
	lda	#$12
	sta	a:OBSEL
	lda	#$07
	sta	a:BGMODE
	lda	#$80
	sta	a:M7SEL
	lda	#$13
	sta	a:TM
	lda	#$40
	sta	a:SETINI
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	stz	$40
	lda	#$0000
	sta	a:$1EC2
	stz	a:$1E80
	stz	a:$1FB4
	stz	a:$1FF4
	sec
	rts

sub_028427:
	; (not executed in the CDL traces)
	lda	a:$1E80
	cmp	#$000F
	bcs	loc_02843A
	inc	a:$1E80
	inc	a:$1FB4
	inc	a:$1FF4
	sec
	rts
loc_02843A:
	inc	a:$1582
	sec
	rts

sub_02843F:
	; (not executed in the CDL traces)
	lda	#$0000
	ldy	a:$1F8A
	beq	loc_028449
	ora	$28
loc_028449:
	ldy	a:$1FCA
	beq	loc_028450
	ora	$2A
loc_028450:
	bit	#$2000
	beq	loc_028458
	inc	a:$1582
loc_028458:
	sec
	rts

sub_02845A:
	; (not executed in the CDL traces)
	lda	a:$1E80
	beq	loc_02846A
	dec	a:$1E80
	dec	a:$1FB4
	dec	a:$1FF4
	sec
	rts
loc_02846A:
	inc	a:$1582
	lda	#$0080
	sta	a:$1E80
	sta	a:$1FB4
	sta	a:$1FF4
	sec
	rts

sub_02847B:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	a:$1586
	stz	a:$1590
	rep	#$30
	phb
	lda	#$0000
	sta	f:$000FC0
	lda	#$021E
	ldx	#$0FC0
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0100
	sta	a:$1F94
	sta	a:$1F96
	jsl	f:sub_02E7AF
	sep	#$20
	.a8
	lda	#$0A
	sta	a:OBSEL
	lda	#$09
	sta	a:BGMODE
	stz	a:M7SEL
	rep	#$20
	.a16
	jsl	f:sub_02ED3B
	inc	a:$1582
	jsr	a:sub_028D03
	sec
	rts

sub_0284C4:
	; (not executed in the CDL traces)
	lda	a:$1E80
	cmp	a:$15D2
	bcs	loc_0284E7
	inc	a:$1E80
	lda	a:$1FB4
	cmp	a:$15D4
	bcs	loc_0284DA
	inc	a:$1FB4
loc_0284DA:
	lda	a:$1FF4
	cmp	a:$15D6
	bcs	loc_0284E5
	inc	a:$1FF4
loc_0284E5:
	sec
	rts
loc_0284E7:
	lda	a:$15D2
	sta	a:$1E80
	lda	a:$15D4
	sta	a:$1FB4
	lda	a:$15D6
	sta	a:$1FF4
	stz	$64
	stz	a:$1582
	sec
	rts

sub_028500:
	lda	a:$158A
	asl	a
	tax
	jmp	(.loword(tbl_028508),x)
tbl_028508:
	.addr	sub_028516
	.addr	sub_028599
	.addr	sub_0285B1
	.addr	sub_0285D3
	.addr	sub_028626
	.addr	sub_028648
	.addr	sub_02865B

sub_028516:
	lda	#$006F
	jsl	f:sub_00868F
	stz	a:$1586
	lda	#$0001
	sta	a:$158E
	jsr	a:sub_02884A
	jsr	a:sub_028669
	stz	a:$152A
	stz	a:$156A
	sep	#$20
	.a8
	lda	#$12
	sta	a:OBSEL
	lda	#$07
	sta	a:BGMODE
	stz	a:M7SEL
	stz	a:W12SEL
	stz	a:W34SEL
	lda	#$80
	sta	a:WOBJSEL
	stz	a:WH0
	stz	a:WH1
	stz	a:WBGLOG
	stz	a:WOBJLOG
	lda	#$13
	sta	a:TM
	stz	a:TS
	stz	a:TMW
	stz	a:TSW
	lda	#$20
	sta	a:CGWSEL
	lda	#$83
	sta	a:CGADSUB
	lda	#$FF
	sta	a:COLDATA
	lda	#$40
	sta	a:SETINI
	rep	#$20
	.a16
	stz	$40
	ldy	#$CD59
	jsl	f:sub_00B183
	lda	#$0080
	sta	a:$1EC4
	stz	a:$1E80
	stz	a:$1FB4
	stz	a:$1FF4
	inc	a:$158A
	clc
	rts

sub_028599:
	lda	a:$1E80
	cmp	#$000F
	bcs	loc_0285AC
	inc	a:$1E80
	inc	a:$1FB4
	inc	a:$1FF4
	clc
	rts
loc_0285AC:
	inc	a:$158A
	clc
	rts

sub_0285B1:
	jsr	a:sub_02884A
	jsr	a:sub_0286A9
	jsr	a:sub_0285C9
	bcc	loc_0285C7
	lda	#$0040
	sta	a:$159C
	stz	$64
	inc	a:$158A
loc_0285C7:
	clc
	rts

sub_0285C9:
	lda	a:$152A
	and	a:$156A
	cmp	#$0002
	rts

sub_0285D3:
	dec	a:$159C
	bmi	loc_0285E8
	lda	a:$159C
	lsr	a
	ora	#$00E0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	clc
	rts
loc_0285E8:
	lda	#$0002
	sta	a:$158E
	jsr	a:sub_028887
	jsl	f:sub_02EBF2
	sep	#$20
	.a8
	lda	#$FC
	sta	a:$1EC4
	lda	#$80
	sta	a:WOBJSEL
	stz	a:CGWSEL
	stz	a:CGADSUB
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:$1E02
	beq	loc_02861B
	dec	a
	bne	loc_02861B
	lda	#$0002
	sta	$40
loc_02861B:
	lda	#$0040
	sta	a:$159C
	inc	a:$158A
	clc
	rts

sub_028626:
	sep	#$20
	.a8
	lda	#$0A
	sta	a:OBSEL
	rep	#$20
	.a16
	dec	a:$159C
	bpl	loc_028646
	lda	a:$1594
	lsr	a
	and	#$0002
	tay
	lda	a:data_05CD6A,y
	jsl	f:sub_00868F
	inc	a:$158A
loc_028646:
	clc
	rts

sub_028648:
	jsr	a:sub_02898D
	jsr	a:sub_028A48
	lda	a:$1F94
	cmp	#$0100
	bne	loc_028659
	inc	a:$158A
loc_028659:
	clc
	rts

sub_02865B:
	lda	#$0001
	sta	a:$1586
	stz	a:$158E
	stz	a:$158A
	sec
	rts

sub_028669:
	lda	a:$1E02
	beq	loc_028698
	dec	a
	beq	loc_028688
	; (not executed in the CDL traces)
	lda	$E8
	and	#$0003
	sta	a:$1526
	sta	a:$1566
	lda	$E9
	and	#$0003
	sta	a:$1528
	sta	a:$1568
	rts
loc_028688:
	lda	$EA
	and	#$0003
	sta	a:$1566
	lda	$EB
	and	#$0003
	sta	a:$1568
loc_028698:
	lda	$E8
	and	#$0003
	sta	a:$1526
	lda	$E9
	and	#$0003
	sta	a:$1528
	rts

sub_0286A9:
	lda	a:$1E02
	bne	loc_0286B1
	brl	loc_028742
loc_0286B1:
	dec	a
	bne	loc_0286B7
	brl	loc_02873F
loc_0286B7:
	; (not executed in the CDL traces)
	lda	a:$152A
	and	a:$156A
	bne	loc_0286CD
	lda	$28
	ora	$2A
	bit	#$5000
	bne	loc_0286E8
	bit	#$0F00
	bne	loc_0286CE
loc_0286CD:
	rts
loc_0286CE:
	pha
	lda	#$0001
	jsl	f:sub_00868F
	pla
	bit	#$0800
	bne	loc_0286F9
	bit	#$0400
	bne	loc_028709
	bit	#$0100
	bne	loc_02872C
	bra	loc_02871C
loc_0286E8:
	lda	#$0002
	jsl	f:sub_00868F
	lda	#$0002
	sta	a:$152A
	sta	a:$156A
	rts
loc_0286F9:
	lda	a:$1528
	dec	a
	bpl	loc_028702
	lda	#$0003
loc_028702:
	sta	a:$1528
	sta	a:$1568
	rts
loc_028709:
	lda	a:$1528
	inc	a
	cmp	#$0004
	bcc	loc_028715
	lda	#$0000
loc_028715:
	sta	a:$1528
	sta	a:$1568
	rts
loc_02871C:
	lda	a:$1526
	dec	a
	bpl	loc_028725
	lda	#$0003
loc_028725:
	sta	a:$1526
	sta	a:$1566
	rts
loc_02872C:
	lda	a:$1526
	inc	a
	cmp	#$0004
	bcc	loc_028738
	lda	#$0000
loc_028738:
	sta	a:$1526
	sta	a:$1566
	rts
loc_02873F:
	jsr	a:sub_0287C6
loc_028742:
	lda	a:$1F8A
	beq	loc_028758
	lda	a:$152A
	bne	loc_028758
	lda	$28
	bit	#$5000
	bne	loc_028773
	bit	#$0F00
	bne	loc_028759
loc_028758:
	rts
loc_028759:
	pha
	lda	#$0001
	jsl	f:sub_00868F
	pla
	bit	#$0800
	bne	loc_02878C
	bit	#$0400
	bne	loc_028799
	bit	#$0100
	bne	loc_0287B6
	bra	loc_0287A9
loc_028773:
	lda	a:$1FCA
	bne	loc_02877E
	lda	#$0002
	sta	a:$156A
loc_02877E:
	lda	#$0002
	jsl	f:sub_00868F
	lda	#$0002
	sta	a:$152A
	rts
loc_02878C:
	lda	a:$1528
	dec	a
	bpl	loc_028795
	lda	#$0003
loc_028795:
	sta	a:$1528
	rts
loc_028799:
	lda	a:$1528
	inc	a
	cmp	#$0004
	bcc	loc_0287A5
	; (not executed in the CDL traces)
	lda	#$0000
loc_0287A5:
	sta	a:$1528
	rts
loc_0287A9:
	lda	a:$1526
	dec	a
	bpl	loc_0287B2
	; (not executed in the CDL traces)
	lda	#$0003
loc_0287B2:
	sta	a:$1526
	rts
loc_0287B6:
	lda	a:$1526
	inc	a
	cmp	#$0004
	bcc	loc_0287C2
	lda	#$0000
loc_0287C2:
	sta	a:$1526
	rts

sub_0287C6:
	lda	a:$1FCA
	beq	loc_0287DC
	lda	a:$156A
	bne	loc_0287DC
	lda	$2A
	bit	#$5000
	bne	loc_0287F7
	bit	#$0F00
	bne	loc_0287DD
loc_0287DC:
	rts
loc_0287DD:
	pha
	lda	#$0001
	jsl	f:sub_00868F
	pla
	bit	#$0800
	bne	loc_028810
	; (not executed in the CDL traces)
	bit	#$0400
	bne	loc_02881D
	bit	#$0100
	bne	loc_02883A
	bra	loc_02882D
loc_0287F7:
	lda	a:$1F8A
	bne	loc_028802
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:$152A
loc_028802:
	lda	#$0002
	jsl	f:sub_00868F
	lda	#$0002
	sta	a:$156A
	rts
loc_028810:
	lda	a:$1568
	dec	a
	bpl	loc_028819
	; (not executed in the CDL traces)
	lda	#$0003
loc_028819:
	sta	a:$1568
	rts
loc_02881D:
	; (not executed in the CDL traces)
	lda	a:$1568
	inc	a
	cmp	#$0004
	bcc	loc_028829
	lda	#$0000
loc_028829:
	sta	a:$1568
	rts
loc_02882D:
	lda	a:$1566
	dec	a
	bpl	loc_028836
	lda	#$0003
loc_028836:
	sta	a:$1566
	rts
loc_02883A:
	lda	a:$1566
	inc	a
	cmp	#$0004
	bcc	loc_028846
	lda	#$0000
loc_028846:
	sta	a:$1566
	rts

sub_02884A:
	lda	#$0000
	sta	a:$1F98
	sta	a:$1FD8
	lda	#$0500
	sta	a:$1F94
	sta	a:$1F96
	sta	a:$1FD4
	sta	a:$1FD6
	lda	#$0200
	sta	a:$1F90
	sta	a:$1FD0
	lda	#$0200
	sta	a:$1F92
	sta	a:$1FD2
	lda	#$0180
	sta	a:$1F9A
	sta	a:$1FDA
	lda	#$0180
	sta	a:$1F9C
	sta	a:$1FDC
	rts

sub_028887:
	lda	a:$1E02
	beq	loc_0288CD
	dec	a
	beq	loc_0288FF
	; (not executed in the CDL traces)
	lda	#$0080
	sta	a:$150C
	sta	a:$154C
	lda	#$007C
	sta	a:$150E
	sta	a:$154E
	jsr	a:sub_02895F
	lda	a:data_05D0DE,y
	sta	a:$1510
	sta	a:$1550
	clc
	adc	#$0080
	sec
	sbc	a:$150C
	sta	a:$1526
	lda	a:data_05D11E,y
	sta	a:$1512
	sta	a:$1552
	clc
	adc	#$0070
	sec
	sbc	a:$150E
	sta	a:$1528
	rts
loc_0288CD:
	lda	#$0080
	sta	a:$150C
	lda	#$00A0
	sta	a:$150E
	jsr	a:sub_02895F
	lda	a:data_05D0DE,y
	sta	a:$1510
	clc
	adc	#$0080
	sec
	sbc	a:$150C
	sta	a:$1526
	lda	a:data_05D11E,y
	sta	a:$1512
	clc
	adc	#$0070
	sec
	sbc	a:$150E
	sta	a:$1528
	rts
loc_0288FF:
	lda	#$0060
	sta	a:$150C
	sta	a:$154C
	lda	#$0034
	sta	a:$150E
	lda	#$00AC
	sta	a:$154E
	jsr	a:sub_02895F
	lda	a:data_05D0DE,y
	sta	a:$1510
	clc
	adc	#$0080
	sec
	sbc	a:$150C
	sta	a:$1526
	lda	a:data_05D11E,y
	sta	a:$1512
	clc
	adc	#$0070
	sec
	sbc	a:$150E
	sta	a:$1528
	jsr	a:sub_028976
	lda	a:data_05D0DE,y
	sta	a:$1550
	clc
	adc	#$0080
	sec
	sbc	a:$154C
	sta	a:$1566
	lda	a:data_05D11E,y
	sta	a:$1552
	clc
	adc	#$0070
	sec
	sbc	a:$154E
	sta	a:$1568
	rts

sub_02895F:
	lda	a:$1528
	asl	a
	asl	a
	clc
	adc	a:$1526
	ldy	$86
	cpy	#$0002
	beq	loc_028973
	clc
	adc	#$0010
loc_028973:
	asl	a
	tay
	rts

sub_028976:
	lda	a:$1568
	asl	a
	asl	a
	clc
	adc	a:$1566
	ldy	$86
	cpy	#$0002
	beq	loc_02898A
	clc
	adc	#$0010
loc_02898A:
	asl	a
	tay
	rts

sub_02898D:
	lda	a:$1E02
	beq	loc_0289BA
	dec	a
	bne	loc_0289BA
	lda	a:$1FD4
	sec
	sbc	#$0004
	sta	a:$1FD4
	lda	a:$1FD6
	sec
	sbc	#$0004
	sta	a:$1FD6
	cmp	#$0100
	bcc	loc_0289B4
	dec	a:$1FD8
	dec	a:$1FD8
loc_0289B4:
	jsr	a:sub_028A14
	jsr	a:sub_028A2E
loc_0289BA:
	lda	a:$1F94
	sec
	sbc	#$0004
	sta	a:$1F94
	lda	a:$1F96
	sec
	sbc	#$0004
	sta	a:$1F96
	cmp	#$0100
	bcc	loc_0289D9
	inc	a:$1F98
	inc	a:$1F98
loc_0289D9:
	jsr	a:sub_0289E0
	jsr	a:sub_0289FA
	rts

sub_0289E0:
	lda	a:$1F90
	cmp	a:$1526
	beq	loc_0289F9
	bpl	loc_0289F2
	clc
	adc	#$0002
	sta	a:$1F90
	rts
loc_0289F2:
	sec
	sbc	#$0002
	sta	a:$1F90
loc_0289F9:
	rts

sub_0289FA:
	lda	a:$1F92
	cmp	a:$1528
	beq	loc_028A13
	bpl	loc_028A0C
	clc
	adc	#$0002
	sta	a:$1F92
	rts
loc_028A0C:
	sec
	sbc	#$0002
	sta	a:$1F92
loc_028A13:
	rts

sub_028A14:
	lda	a:$1FD0
	cmp	a:$1566
	beq	loc_028A2D
	bpl	loc_028A26
	; (not executed in the CDL traces)
	clc
	adc	#$0002
	sta	a:$1FD0
	rts
loc_028A26:
	sec
	sbc	#$0002
	sta	a:$1FD0
loc_028A2D:
	rts

sub_028A2E:
	lda	a:$1FD2
	cmp	a:$1568
	beq	loc_028A47
	bpl	loc_028A40
	clc
	adc	#$0002
	sta	a:$1FD2
	rts
loc_028A40:
	sec
	sbc	#$0002
	sta	a:$1FD2
loc_028A47:
	rts

sub_028A48:
	lda	a:$1F90
	sec
	sbc	#$0080
	sta	a:$1F9A
	lda	a:$1F92
	sec
	sbc	#$0070
	sta	a:$1F9C
	lda	a:$1FD0
	sec
	sbc	#$0080
	sta	a:$1FDA
	lda	a:$1FD2
	sec
	sbc	#$0070
	sta	a:$1FDC
	rts

sub_028A71:
	ldx	#.loword(data_05CF33)
	jsl	f:sub_0090A8
	jsl	f:sub_00E369
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	jsl	f:sub_008CFF
	rts

sub_028A88:
	sep	#$20
	.a8
	lda	#$5C
	sta	a:BG1SC
	lda	#$5C
	sta	a:BG2SC
	lda	#$5C
	sta	a:BG3SC
	lda	#$55
	sta	a:BG12NBA
	lda	#$05
	sta	a:BG34NBA
	lda	#$0A
	sta	a:OBSEL
	lda	#$09
	sta	a:BGMODE
	stz	a:M7SEL
	stz	a:MOSAIC
	rep	#$20
	.a16
	stz	a:BG1HOFS
	stz	a:BG1HOFS
	stz	a:BG2HOFS
	stz	a:BG2HOFS
	stz	a:TM
	stz	a:CGWSEL
	rts

sub_028AC8:
	lda	a:$1E02
	beq	loc_028AD2
	dec	a
	eor	#$0001
	asl	a
loc_028AD2:
	tay
	sep	#$20
	.a8
	stz	a:BG3HOFS
	stz	a:BG3HOFS
	lda	a:data_05CD6E,y
	sta	a:BG3VOFS
	lda	a:data_05CD6F,y
	sta	a:BG3VOFS
	rep	#$20
	.a16
	rts

sub_028AEA:
	lda	#$0004
	sta	$42
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$7E2000
	lda	#$1FFE
	ldx	#$2000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	stz	a:$1F90
	stz	a:$1F92
	stz	a:$1F94
	stz	a:$1F96
	stz	a:$1F98
	stz	a:$1F80
	stz	a:$1F98
	stz	a:$1FD0
	stz	a:$1FD2
	stz	a:$1FD4
	stz	a:$1FD6
	stz	a:$1FD8
	stz	a:$1FC0
	stz	a:$1FD8
	lda	#$0004
	sta	$42
	rts

sub_028B4B:
	lda	#$6000
	sta	a:$1808
	sta	a:$180A
	sta	a:$180C
	sta	a:$180E
	sta	a:$1810
	sta	a:$1812
	sta	a:$1814
	sta	a:$1816
	sta	a:$1818
	sta	a:$181A
	sta	a:$181C
	sta	a:$181E
	sta	a:$1820
	sta	a:$1822
	sta	a:$1824
	sta	a:$1826
	rts

sub_028B7F:
	ldx	#.loword(data_05CF2A)
	jsl	f:sub_0090A8
	ldy	#$CFB2
	jsl	f:sub_009982
	jsl	f:sub_04DB02
	rts

sub_028B92:
	ldx	#.loword(data_05D01F)
	jsl	f:sub_0090A8
	ldy	#$D056
	jsl	f:sub_009982
	jsl	f:sub_04DB02
	rts

sub_028BA5:
	ldx	#$F46B
	jsl	f:sub_0098D4
	ldx	#.loword(data_05CFCF)
	jsl	f:sub_0090A8
	ldx	#.loword(data_05CFD8)
	jsl	f:sub_0090A8
	ldy	#$D006
	jsl	f:sub_009982
	jsl	f:sub_04DB02
	rts

sub_028BC6:
	ldx	#$F46B
	jsl	f:sub_0098D4
	ldx	#.loword(data_05D073)
	jsl	f:sub_0090A8
	ldx	#.loword(data_05D07C)
	jsl	f:sub_0090A8
	ldy	#$D0AA
	jsl	f:sub_009982
	jsl	f:sub_04DB02
	rts

sub_028BE7:
	stz	a:$1594
	stz	a:$15A8
	lda	#$0004
	sta	a:$159A
loc_028BF3:
	rep	#$30
	phb
	lda	#$0000
	sta	f:$000200
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0001
	sta	a:$1586
	stz	a:$1E40
	stz	a:$1F88
	stz	a:$1FC8
	lda	#$000F
	sta	a:$1588
	rts

sub_028C1F:
	lda	#$0004
	sta	a:$1594
	stz	a:$15A8
	lda	#$0004
	sta	a:$159A
	lda	#$8000
	sta	a:$15B2
	stz	a:$15B4
	lda	#$0002
	sta	a:$15B6
	stz	a:$15B8
	bra	loc_028BF3

sub_028C42:
	rep	#$30
	phb
	lda	#$0000
	sta	f:$000200
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001780
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0002
	sta	a:$1594
	sta	a:$15A8
loc_028C8D:
	stz	a:$159A
	lda	#$0001
	sta	a:$1586
	lda	#$0001
	sta	a:$1E40
	lda	#$000F
	sta	a:$1588
	lda	#$0200
	sta	a:$1510
	sta	a:$1550
	lda	#$0280
	sta	a:$1512
	sta	a:$1552
	rts

sub_028CB5:
	rep	#$30
	phb
	lda	#$0000
	sta	f:$000200
	lda	#$0FDE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$01FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001780
	lda	#$017E
	ldx	#$1780
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0006
	sta	a:$1594
	stz	a:$15A8
	brl	loc_028C8D

sub_028D03:
	sep	#$20
	.a8
	lda	#$FC
	sta	a:$1EC4
	stz	a:INIDISP
	rep	#$20
	.a16
	stz	a:$1FB4
	stz	a:$1FF4
	stz	a:$1E80
	rts

sub_028D19:
	sep	#$20
	.a8
	stz	a:$1EC4
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	lda	#$0080
	sta	a:$1FB4
	sta	a:$1FF4
	sta	a:$1E80
	rts

sub_028D32:
	lda	a:$1E80
	cmp	a:$1588
	beq	loc_028D77
	bcs	loc_028D5D
	lda	$78
	bit	#$0001
	bne	loc_028D77
	inc	a:$1E80
	lda	a:$1FB4
	cmp	#$000F
	bcs	loc_028D51
	inc	a:$1FB4
loc_028D51:
	lda	a:$1FF4
	cmp	#$000F
	bcs	loc_028D5C
	inc	a:$1FF4
loc_028D5C:
	rts
loc_028D5D:
	lda	$78
	bit	#$0003
	bne	loc_028D77
	dec	a:$1E80
	lda	a:$1FB4
	beq	loc_028D6F
	dec	a:$1FB4
loc_028D6F:
	lda	a:$1FF4
	beq	loc_028D77
	dec	a:$1FF4
loc_028D77:
	rts

sub_028D78:
	lda	$84
	beq	loc_028D85
	tay
	lda	$E8
	and	#$0030
	ora	a:data_05CD72,y
loc_028D85:
	clc
	adc	#$CD78
	sta	$FA
	ldy	#$0000
	ldx	#$0AC0
loc_028D91:
	lda	($FA),y
	sta	$10,x
	stz	$12,x
	lda	a:data_05CE08,y
	sta	$0A,x
	lda	a:data_05CE12,y
	sta	$0E,x
	lda	a:data_05CE1C,y
	sta	$26,x
	lda	a:data_05CE26,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	loc_028D91
	rtl

sub_028DB9:
	ldy	#$0000
	ldx	#$0AC0
loc_028DBF:
	stz	$12,x
	lda	a:data_05CE30,y
	sta	$10,x
	lda	a:data_05CE44,y
	sta	$14,x
	lda	a:data_05CE58,y
	sta	$26,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$0014
	bcc	loc_028DBF
	rtl

sub_028DDE:
	lda	$84
	beq	loc_028DE7
	lda	$E8
	and	#$0070
loc_028DE7:
	clc
	adc	#$CE7C
	sta	$FA
	ldy	#$0000
	ldx	#$0AC0
loc_028DF3:
	lda	($FA),y
	sta	$10,x
	stz	$12,x
	lda	a:data_05CF06,y
	sta	$0A,x
	lda	a:data_05CF10,y
	sta	$0E,x
	lda	a:data_05CF1A,y
	sta	$26,x
	lda	a:data_05CEFC,y
	sta	$14,x
	txa
	clc
	adc	#$0040
	tax
	iny
	iny
	cpy	#$000A
	bcc	loc_028DF3
	rtl

sub_028E1B:
	ldy	#$0000
	ldx	#$0AC0
	stz	$12,x
	lda	a:data_05CF24,y
	sta	$10,x
	lda	a:data_05CF26,y
	sta	$14,x
	lda	a:data_05CF28,y
	sta	$26,x
	rtl
