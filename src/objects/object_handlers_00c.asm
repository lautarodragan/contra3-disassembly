; objects/object_handlers_00c.asm -- Object handlers (bank $00, part 3)
; Bank $00, $00:F27C-$00:FD8C. Included by main.asm in segment BANK00.
;
; Object type 1 (sub_00F27C) with its sub-states and helpers, and other
; handlers dispatched through tbl_05A48A.

sub_00F27C:
	lda	$32,x
	beq	loc_00F290
	dec	a
	bne	loc_00F28A
	dec	a
	ldy	#$0100
	sty	a:$1686
loc_00F28A:
	sta	$32,x
	jsl	f:sub_0181E8
loc_00F290:
	inc	a:$1636
	ldy	#$0012
	lda	$C0
	cmp	#$0005
	bcs	loc_00F2A0
	ldy	#$0000
loc_00F2A0:
	sty	a:$1E8A
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_00F2B2,x
	plx
	sta	$00
	jmp	($0000)
tbl_00F2B2:
	.addr	sub_00F2C4
	.addr	sub_00F2EF
	.addr	sub_00F31A
	.addr	sub_00F34C
	.addr	sub_00F3A3
	.addr	sub_00F3B8
	.addr	sub_00F3E9
	.addr	sub_00F415
	.addr	sub_00F43D

sub_00F2C4:
	lda	#$0002
	jsl	f:sub_01F6A8
	lda	#$F48A
	sta	a:$1682
	lda	#$0004
	sta	a:$1680
	stz	$32,x
	inc	$12,x
	lda	#$0040
	sta	$04
	lda	#$A000
	sta	$02
	ldy	#$4830
	lda	#$0018
	jml	f:sub_00CFAF

sub_00F2EF:
	lda	a:$13BA
	cmp	#$0004
	bne	loc_00F319
	stz	$46
	inc	$12,x
	lda	#$0080
	sta	$24,x
	stx	$FC
	ldx	#.loword(data_05AA1F)
	jsl	f:sub_0090A8
	ldy	#$AA28
	jsl	f:sub_009982
	ldx	$FC
	jsl	f:sub_00FF30
	jsr	a:sub_00F65E
loc_00F319:
	rtl

sub_00F31A:
	lda	$24,x
	bmi	loc_00F322
	dec	$24,x
	bpl	loc_00F34B
loc_00F322:
	lda	a:$1678
	bne	loc_00F34B
	lda	#$0068
	jsl	f:sub_00868F
	lda	#$0058
	jsl	f:sub_00868F
	lda	#$0002
	sta	$24,x
	inc	$12,x
	jsr	a:sub_00F514
	stz	a:$163A
	lda	#$0020
	sta	a:$163C
	sta	a:$1640
loc_00F34B:
	rtl

sub_00F34C:
	dec	$24,x
	beq	loc_00F362
	phx
	jsr	a:sub_00F9C5
	plx
	ldy	#$AAB8
	lda	#$4018
	sta	$0C
	lda	#$0040
	bra	loc_00F383
loc_00F362:
	inc	$12,x
	lda	#$003C
	sta	$16,x
	lda	#$0180
	sta	$0A,x
	lda	#$0080
	sta	$28,x
	lda	#$FFA0
	sta	$2A,x
	ldy	#$AAC8
	lda	#$4218
	sta	$0C
	lda	#$0030
loc_00F383:
	sta	$08
	lda	a:$1380
	bit	#$0100
	beq	loc_00F395
	clc
	lda	$0C
	adc	#$0400
	sta	$0C
loc_00F395:
	lda	#$0002
	sta	$02
	phx
	lda	$0C
	jsl	f:sub_00FEA3
	plx
	rtl

sub_00F3A3:
	jsr	a:sub_00F559
	lda	$34,x
	bne	loc_00F3B1
	inc	$12,x
	lda	#$0010
	sta	$24,x
loc_00F3B1:
	jsr	a:sub_00F5D9
	jsr	a:sub_00F8E2
	rtl

sub_00F3B8:
	dec	$24,x
	bne	loc_00F3DF
	lda	#$0006
	sta	$46
	inc	$12,x
	lda	#$0020
	sta	a:$1636
	stz	$36,x
	lda	#$0080
	sta	$38,x
	lda	#$0080
	sta	a:$0474
	lda	#$0100
	sta	a:$1638
	jsr	a:sub_00F907
loc_00F3DF:
	dec	a:$030E
	jsr	a:sub_00F5D9
	jsr	a:sub_00F8E2
	rtl

sub_00F3E9:
	lda	a:$163C
	cmp	#$0020
	bne	loc_00F405
	lda	$32,x
	bne	loc_00F3FC
	lda	$E8
	bit	#$003F
	bne	loc_00F405
loc_00F3FC:
	lda	#$0003
	sta	a:$163E
	inc	$12,x
	rtl
loc_00F405:
	lda	#$2000
	sta	$00
	stz	$02
	jsr	a:sub_00F850
	jsr	a:sub_00F672
	brl	loc_00F46D

sub_00F415:
	lda	a:$163C
	cmp	#$0007
	bcs	loc_00F42D
	lda	#$0056
	jsl	f:sub_00868F
	lda	#$0004
	sta	a:$1662
	inc	$12,x
	rtl
loc_00F42D:
	stz	$00
	lda	#$0002
	sta	$02
	jsr	a:sub_00F85A
	jsr	a:sub_00F672
	brl	loc_00F46D

sub_00F43D:
	lda	a:$163C
	cmp	#$0020
	bcc	loc_00F45D
	dec	a:$163E
	bne	loc_00F45A
	lda	$32,x
	bne	loc_00F45A
	lda	#$0020
	sta	a:$1636
	lda	#$0006
	sta	$12,x
	rtl
loc_00F45A:
	dec	$12,x
	rtl
loc_00F45D:
	stz	$00
	lda	#$0002
	sta	$02
	jsr	a:sub_00F871
	jsr	a:sub_00F672
	brl	loc_00F46D
loc_00F46D:
	jsr	a:sub_00F8D0
	jsl	f:sub_00F4DA
	jsr	a:sub_00F5D9
	jsr	a:sub_00F98E
	jsr	a:sub_00F949
	jsr	a:sub_00F4B7
	jsr	a:sub_00F484
	rtl

sub_00F484:
	lda	$32,x
	beq	loc_00F4B6
	jsl	f:sub_00FD8D
	lda	$0A,x
	adc	#$FFE0
	sta	$00
	lda	$0E,x
	adc	#$0010
	sta	$02
	lda	#$007F
	sta	$04
	lda	#$007F
	sta	$06
	ldy	#$0280
	lda	#$C516
	jsl	f:sub_01CF3C
	bcs	loc_00F4B6
	lda	#$FFFD
	sta	a:$001E,y
loc_00F4B6:
	rts

sub_00F4B7:
	ldy	#$AB28
	lda	$3E,x
	beq	loc_00F4C3
	dec	$3E,x
	ldy	#$AB30
loc_00F4C3:
	lda	#$0002
	sta	$02
	lda	#$0040
	sta	$08
	lda	#$4D8C
	phx
	ldx	#$0020
	jsl	f:sub_00FEAA
	plx
	rts

sub_00F4DA:
	lda	#$A000
	sta	$00
	lda	#$0020
	sta	$E2
	lda	#$5E00
	jml	f:loc_00F4EB
loc_00F4EB:
	ldy	#$0000
	sta	a:$1800,y
	clc
	adc	#$0010
	sta	a:$1802,y
	clc
	adc	#$0010
	sta	a:$1804,y
	clc
	adc	#$0010
	sta	a:$1806,y
	lda	$00
	sta	a:$1840,y
	clc
	lda	$B6
	adc	#$0008
	sta	$B6
	rtl

sub_00F514:
	phx
	ldx	#$0300
	ldy	#$0000
loc_00F51B:
	lda	#$0022
	sta	$10,x
	lda	#$0001
	sta	$16,x
	lda	#$3800
	sta	$02,x
	lda	#$001C
	sta	$28,x
	lda	#$FFE5
	sta	$2A,x
	stz	$30,x
	lda	a:data_05AA50,y
	sta	$0A,x
	lda	a:data_05AA58,y
	sta	$0E,x
	lda	a:data_05AA60,y
	sta	$24,x
	iny
	iny
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0400
	bcc	loc_00F51B
	plx
	lda	#$0008
	sta	$34,x
	rts

sub_00F559:
	lda	$24,x
	beq	loc_00F572
	dec	$24,x
	bne	loc_00F571
	lda	$30,x
	eor	#$0002
	sta	$30,x
	lda	#$0020
	sta	a:$1644
	brl	loc_00F5B1
loc_00F571:
	rts
loc_00F572:
	dec	a:$1644
	bpl	loc_00F5B0
	lda	#$0020
	sta	$24,x
	stz	a:$0318
	stz	a:$031A
	stz	a:$031C
	stz	a:$031E
	stz	a:$0330
	stz	a:$03D8
	stz	a:$03DA
	stz	a:$03DC
	stz	a:$03DE
	stz	a:$03F0
	lda	#$0004
	sta	a:$1662
	lda	#$0056
	jsl	f:sub_00868F
	lda	#$0056
	jsl	f:sub_00868F
	dec	$34,x
loc_00F5B0:
	rts
loc_00F5B1:
	phx
	lda	$30,x
	bne	loc_00F5BB
	ldx	#$0300
	bra	loc_00F5BE
loc_00F5BB:
	ldx	#$03C0
loc_00F5BE:
	lda	#$4000
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$0000
	sta	$1C,x
	lda	#$FFFF
	sta	$1E,x
	lda	#$0001
	sta	$30,x
	plx
	rts

sub_00F5D9:
	stz	$00
	sec
	lda	a:$030A
	sbc	a:$03CA
	bpl	loc_00F5E9
	eor	#$FFFF
	inc	$00
loc_00F5E9:
	and	#$00FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$03
	sta	a:WRDIVB
	rep	#$20
	.a16
	stz	$02
	sec
	lda	a:$030E
	sbc	a:$03CE
	bpl	loc_00F608
	eor	#$FFFF
	inc	$02
loc_00F608:
	and	#$00FF
	pha
	lda	a:RDDIVL
	ldy	$00
	bne	loc_00F616
	eor	#$FFFF
loc_00F616:
	sta	$00
	clc
	lda	a:$030A
	adc	$00
	adc	#$0000
	sta	a:$034A
	clc
	adc	$00
	adc	#$0000
	sta	a:$038A
	pla
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$03
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	ldy	$02
	bne	loc_00F64C
	; (not executed in the CDL traces)
	eor	#$FFFF
loc_00F64C:
	sta	$02
	clc
	lda	a:$030E
	adc	$02
	sta	a:$034E
	clc
	adc	$02
	sta	a:$038E
	rts

sub_00F65E:
	phx
	ldx	#$0000
	lda	#$0008
loc_00F665:
	sta	f:$7EA046,x
	inx
	inx
	cpx	#$003A
	bcc	loc_00F665
	plx
	rts

sub_00F672:
	lda	$36,x
	phx
	asl	a
	tax
	lda	f:tbl_00F681,x
	plx
	sta	$0C
	jmp	($000C)
tbl_00F681:
	.addr	sub_00F7AE
	.addr	sub_00F6E3
	.addr	sub_00F71B
	.addr	sub_00F757
	.addr	sub_00F69D
	.addr	sub_00F6C7
	.addr	sub_00F68F

sub_00F68F:
	ldy	a:$1640
	cpy	#$002C
	bcs	loc_00F69A
	brl	loc_00F882
loc_00F69A:
	brl	loc_00F88A

sub_00F69D:
	lda	#$0002
	sta	$3E,x
	dec	$38,x
	bne	loc_00F6B6
	lda	#$0025
	jsl	f:sub_00868F
	inc	$36,x
	ldy	$84
	lda	a:data_05AB52,y
	sta	$38,x
loc_00F6B6:
	jsr	a:sub_00FB71
	ldy	a:$1640
	cpy	#$001C
	bcs	loc_00F6C4
	brl	loc_00F882
loc_00F6C4:
	brl	loc_00F88A

sub_00F6C7:
	lda	#$0002
	sta	$3E,x
	lda	#$0001
	sta	a:$1660
	dec	$38,x
	bne	loc_00F6DD
	stz	$36,x
	lda	#$0100
	sta	$38,x
loc_00F6DD:
	jsr	a:sub_00FBAB
	brl	loc_00F828

sub_00F6E3:
	lda	$C0
	bne	loc_00F6EC
	lda	#$0004
	sta	$3E,x
loc_00F6EC:
	dec	$38,x
	bne	loc_00F6F7
	stz	$36,x
	lda	#$0080
	sta	$38,x
loc_00F6F7:
	jsr	a:sub_00FA55
	ldy	a:$1640
	lda	a:$1636
	and	#$0010
	bne	loc_00F710
loc_00F705:
	cpy	#$0030
	bcs	loc_00F70D
	brl	loc_00F882
loc_00F70D:
	brl	loc_00F88A
loc_00F710:
	cpy	#$0010
	bcc	loc_00F718
	brl	loc_00F88A
loc_00F718:
	; (not executed in the CDL traces)
	brl	loc_00F882

sub_00F71B:
	lda	a:$1636
	and	#$0040
	beq	loc_00F728
	lda	#$0002
	sta	$3E,x
loc_00F728:
	dec	$38,x
	bne	loc_00F733
	stz	$36,x
	lda	#$0040
	sta	$38,x
loc_00F733:
	jsr	a:sub_00F9FD
	ldy	a:$1640
	lda	a:$1636
	and	#$0020
	bne	loc_00F74C
	cpy	#$0024
	bcs	loc_00F749
	brl	loc_00F882
loc_00F749:
	brl	loc_00F88A
loc_00F74C:
	cpy	#$0010
	bcc	loc_00F754
	brl	loc_00F88A
loc_00F754:
	brl	loc_00F882

sub_00F757:
	lda	$78
	bit	#$001F
	bne	loc_00F763
	lda	#$0004
	sta	$3E,x
loc_00F763:
	dec	$38,x
	bne	loc_00F771
	stz	$36,x
	lda	#$0080
	sta	$38,x
	stz	a:$0464
loc_00F771:
	ldy	a:$1640
	lda	$38,x
	bit	#$0080
	bne	loc_00F78F
	lda	a:$1F8A
	bne	loc_00F783
	; (not executed in the CDL traces)
	brl	loc_00F797
loc_00F783:
	sec
	lda	a:$020E
	sbc	a:$044E
	bcs	loc_00F7A3
	brl	loc_00F705
loc_00F78F:
	lda	a:$1FCA
	bne	loc_00F797
	brl	loc_00F783
loc_00F797:
	; (not executed in the CDL traces)
	sec
	lda	a:$024E
	sbc	a:$044E
	bcs	loc_00F7A3
	brl	loc_00F705
loc_00F7A3:
	cpy	#$0008
	bcc	loc_00F7AB
	brl	loc_00F88A
loc_00F7AB:
	; (not executed in the CDL traces)
	brl	loc_00F882

sub_00F7AE:
	dec	$38,x
	bne	loc_00F80A
	lda	$E8
	bit	#$0003
	beq	loc_00F7DD
	bit	#$0001
	bne	loc_00F7C6
	ldy	#$00C0
	lda	#$0001
	bra	loc_00F806
loc_00F7C6:
	lda	#$0057
	jsl	f:sub_00868F
	lda	a:$0490
	cmp	#$0020
	bne	loc_00F7E2
	ldy	#$0080
	lda	#$0002
	bra	loc_00F806
loc_00F7DD:
	bit	#$0008
	bne	loc_00F7F3
loc_00F7E2:
	lda	#$0057
	jsl	f:sub_00868F
	stz	$3A,x
	ldy	#$0080
	lda	#$0004
	bra	loc_00F806
loc_00F7F3:
	lda	#$0057
	jsl	f:sub_00868F
	lda	#$0001
	sta	a:$0464
	ldy	#$0100
	lda	#$0003
loc_00F806:
	sta	$36,x
	sty	$38,x
loc_00F80A:
	ldy	a:$1640
	lda	a:$1636
	and	#$0010
	bne	loc_00F820
	cpy	#$0024
	bcs	loc_00F81D
	brl	loc_00F882
loc_00F81D:
	brl	loc_00F828
loc_00F820:
	cpy	#$0010
	bcc	loc_00F828
	brl	loc_00F88A
loc_00F828:
	phx
	ldx	#$0000
loc_00F82C:
	clc
	lda	f:$7EA0C6,x
	adc	$00
	sta	f:$7EA0C6,x
	lda	f:$7EA046,x
	adc	$02
	and	#$00FF
	ora	#$4000
	sta	f:$7EA046,x
	inx
	inx
	cpx	#$0020
	bcc	loc_00F82C
	plx
	rts

sub_00F850:
	lda	a:$1636
	and	#$0040
	bne	sub_00F85A
	bra	sub_00F871

sub_00F85A:
	lda	$00
	eor	#$FFFF
	clc
	adc	#$0001
	sta	$00
	lda	$02
	eor	#$FFFF
	adc	#$0000
	sta	$02
	bra	loc_00F876

sub_00F871:
	ldy	#$0020
	bra	loc_00F879
loc_00F876:
	ldy	#$0058
loc_00F879:
	phx
	ldx	#$0020
	lda	#$003A
	bra	loc_00F897
loc_00F882:
	inc	a:$1640
	ldy	#$0000
	bra	loc_00F890
loc_00F88A:
	dec	a:$1640
	ldy	#$0038
loc_00F890:
	phx
	ldx	#$0000
	lda	#$0020
loc_00F897:
	sta	$08
loc_00F899:
	clc
	lda	f:$7EA0C6,x
	adc	a:data_05921A,y
	sta	$04
	lda	f:$7EA046,x
	adc	a:data_0591AA,y
	and	#$00FF
	sta	$06
	clc
	lda	$04
	adc	$00
	sta	f:$7EA0C6,x
	lda	$06
	adc	$02
	and	#$00FF
	ora	#$4000
	sta	f:$7EA046,x
	iny
	iny
	inx
	inx
	cpx	$08
	bcc	loc_00F899
	plx
	rts

sub_00F8D0:
	clc
	lda	a:$163A
	adc	$00
	sta	a:$163A
	lda	a:$163C
	adc	$02
	sta	a:$163C
	rts

sub_00F8E2:
	sec
	lda	#$01C0
	sbc	a:$030A
	sta	a:$13C0
	sec
	lda	#$009C
	sbc	a:$030E
	sta	a:$13D8
loc_00F8F6:
	lda	a:$030A
	adc	#$FFE0
	sta	$0A,x
	lda	a:$030E
	adc	#$001C
	sta	$0E,x
	rts

sub_00F907:
	phx
	ldx	#$0400
	ldy	#$0000
loc_00F90E:
	lda	a:data_05AADA,y
	sta	$10,x
	lda	a:data_05AAD4,y
	sta	$16,x
	lda	a:data_05AAE0,y
	sta	$28,x
	lda	a:data_05AAE6,y
	sta	$2A,x
	lda	a:data_05AAEC,y
	sta	$0A,x
	lda	#$0180
	sta	$0E,x
	iny
	iny
	txa
	clc
	adc	#$0040
	tax
	cpy	#$0006
	bcc	loc_00F90E
	ldy	$84
	lda	#$0160
	sta	a:$0406
	lda	a:data_05AB40,y
	sta	a:$0486
	plx
	rts

sub_00F949:
	lda	a:$1638
	and	#$01F8
	ora	#$4000
	phx
	ldx	#$0000
loc_00F956:
	sta	f:$7EA006,x
	inx
	inx
	cpx	#$0020
	bcc	loc_00F956
	lda	a:$1638
	bit	#$0100
	beq	loc_00F98C
	and	#$00F8
	lsr	a
	lsr	a
	lsr	a
	sta	$00
	lda	#$00F8
	dex
	dex
loc_00F976:
	dec	$00
	bmi	loc_00F98C
	clc
	adc	#$0008
	and	#$01F8
	ora	#$4100
	sta	f:$7EA006,x
	dex
	dex
	bra	loc_00F976
loc_00F98C:
	plx
	rts

sub_00F98E:
	sep	#$20
	.a8
	sec
	lda	#$B8
	sbc	f:$7EA068
	sta	a:$040E
	stz	a:$040F
	sec
	lda	#$90
	sbc	f:$7EA056
	sta	a:$044E
	stz	a:$044F
	sec
	lda	#$60
	sbc	a:$1638
	sta	a:$044A
	stz	a:$044B
	sec
	lda	#$9C
	sbc	f:$7EA070
	sta	a:$030E
	rep	#$20
	.a16
	brl	loc_00F8F6

sub_00F9C5:
	ldy	#$0018
	ldx	#$0600
loc_00F9CB:
	lda	a:data_05AA68,y
	sta	$0E,x
	lda	#$00D0
	sta	$0A,x
	lda	#$0023
	sta	$10,x
	lda	#$0003
	sta	$16,x
	lda	a:data_05AA80,y
	sta	$00,x
	lda	a:data_05AA98,y
	sta	$1A,x
	stz	$1E,x
	lda	#$3800
	sta	$02,x
	dey
	dey
	bne	loc_00F9F5
	rts
loc_00F9F5:
	clc
	txa
	adc	#$0040
	tax
	bra	loc_00F9CB

sub_00F9FD:
	lda	$78
	bit	#$0040
	beq	loc_00FA54
	lda	$C0
	bne	loc_00FA54
	ldy	#$0500
	jsl	f:sub_019EAE
	bcs	loc_00FA54
	phx
	lda	#$0026
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$2800
	sta	a:$0002,y
	lda	#$AB14
	sta	a:$0020,y
	lda	a:$048E
	adc	#$FFE8
	sta	a:$000E,y
	lda	a:$048A
	adc	#$0010
	sta	a:$000A,y
	lda	$E8
	sta	a:$001C,x
	lda	#$FFFF
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2
	sta	a:$002A,y
	plx
loc_00FA54:
	rts

sub_00FA55:
	lda	$78
	bit	#$000F
	bne	loc_00FA54
	ldy	#$0500
	jsl	f:sub_019EAE
	bcs	loc_00FABF
	phx
	lda	#$0027
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$2800
	sta	a:$0002,y
	lda	#$AAFA
	sta	a:$0020,y
	lda	#$0001
	sta	a:$0004,y
	lda	a:$044E
	sta	a:$000E,y
	lda	a:$044A
	adc	#$0008
	sta	a:$000A,y
	lda	#$0001
	sta	a:$0006,y
	lda	$E8
	and	#$0003
	asl	a
	tax
	lda	a:data_05AAF2,x
	sta	a:$0018,y
	lda	#$FFFF
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2
	sta	a:$002A,y
	lda	#$FFFF
	sta	a:$001E,y
	plx
loc_00FABF:
	rts

sub_00FAC0:
	lda	$06,x
	bpl	loc_00FAD3
	lda	#$000C
	jsl	f:sub_00868F
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_00FAD3:
	lda	$E6
	cmp	#$0002
	bcc	loc_00FADE
	inc	$0E,x
	bra	loc_00FAE0
loc_00FADE:
	dec	$0E,x
loc_00FAE0:
	ldy	#$0200
	txa
	and	#$0040
	beq	loc_00FAEC
	ldy	#$0240
loc_00FAEC:
	lda	a:$000E,y
	ldy	$84
	cmp	$0E,x
	bpl	loc_00FB05
	sec
	lda	$1C,x
	sbc	a:data_05AB46,y
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rtl
loc_00FB05:
	clc
	lda	$1C,x
	adc	a:data_05AB46,y
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_00FB15:
	lda	$06,x
	bpl	loc_00FB2A
	lda	#$000C
	jsl	f:sub_00868F
	stz	$04,x
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_00FB2A:
	lda	$12,x
	bne	loc_00FB6B
	stz	$00
	stz	$02
	jsl	f:sub_00E16E
	beq	loc_00FB44
	jsl	f:sub_0193DB
	inc	$12,x
	lda	#$FFFE
	sta	$1E,x
	rtl
loc_00FB44:
	clc
	lda	$1C,x
	adc	#$1800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
loc_00FB54:
	stz	$00
	stz	$02
	jsl	f:sub_00E16E
	beq	loc_00FB44
	jsl	f:sub_0193DB
	inc	$12,x
	stz	$1E,x
	stz	$1C,x
	stz	$04,x
	rtl
loc_00FB6B:
	cmp	#$0001
	beq	loc_00FB54
	rtl

sub_00FB71:
	lda	$3A,x
	bne	loc_00FBAA
	inc	$3A,x
	lda	#$AB14
	ldy	#$0500
	jsl	f:sub_01CF25
	bcs	loc_00FBAA
	lda	#$0038
	sta	a:$0010,y
	lda	#$1200
	sta	a:$0002,y
	lda	a:$044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:$044E
	adc	#$FFFC
	sta	a:$000E,y
	lda	#$0080
	sta	a:$0024,y
	sta	a:$0004,y
loc_00FBAA:
	rts

sub_00FBAB:
	lda	#$AB22
	ldy	#$0500
	jsl	f:sub_01CF25
	bcs	loc_00FBE1
	lda	#$000F
	sta	a:$0016,y
	lda	a:$044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:$044E
	adc	#$FFFC
	sta	a:$000E,y
	lda	#$FFF0
	sta	a:$001A,y
	lda	#$001C
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
loc_00FBE1:
	rts

sub_00FBE2:
	lda	$14,x
	bne	loc_00FC0B
	ldy	#$0130
	lda	$24,x
	bne	loc_00FBF8
	ldy	#$0100
	lda	a:$1638
	cmp	#$0100
	bcs	loc_00FC11
loc_00FBF8:
	sty	$00
	lda	a:$1638
	clc
	adc	#$0004
	cmp	$00
	bcc	loc_00FC07
	lda	$00
loc_00FC07:
	sta	a:$1638
	rtl
loc_00FC0B:
	lda	a:$1638
	ldy	#$00E0
loc_00FC11:
	sty	$00
	sec
	sbc	#$000C
	cmp	$00
	bcs	loc_00FC1D
	lda	$00
loc_00FC1D:
	sta	a:$1638
	rtl

sub_00FC21:
	dec	$34,x
	bpl	loc_00FC43
	ldy	$84
	lda	$E8
	and	#$007F
	adc	a:data_05AB4C,y
	sta	$34,x
	lda	$0E,x
	adc	#$FFF8
	sta	$02
	lda	$0A,x
	adc	#$0010
	sta	$00
	jsl	f:sub_01A0E9
loc_00FC43:
	lda	$26,x
	beq	loc_00FC58
	lda	#$912A
	sta	$9A
	lda	#$0060
	sta	$98
	lda	#$000F
	jsl	f:sub_00868F
loc_00FC58:
	lda	$06,x
	bpl	loc_00FCBD
	lda	#$0100
	sta	a:$0932
	lda	#$0110
	sta	a:$093E
	lda	#$0006
	sta	a:$0936
	stz	a:$0464
	lda	#$8000
	sta	$16,x
	lda	#$C540
	sta	$00
	ldy	#$0010
	lda	#$4E94
	jml	f:loc_00FE7D

sub_00FC85:
	sec
	lda	#$0060
	sbc	f:$7EA068
	and	#$00FF
	sta	a:$000E,x
	lda	$12,x
	bne	loc_00FCC9
	lda	a:$0932
	bne	loc_00FCA0
	lda	$06,x
	bpl	loc_00FCBD
loc_00FCA0:
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$0040
	sta	$24,x
	inc	$12,x
	lda	#$C480
	sta	$00
	ldy	#$0008
	lda	#$4D14
	jml	f:loc_00FE7D
loc_00FCBD:
	lda	$14,x
	beq	loc_00FCC8
	lda	#$000F
	jml	f:sub_00868F
loc_00FCC8:
	rtl
loc_00FCC9:
	dec	$24,x
	bne	loc_00FCD2
	lda	#$8000
	sta	$16,x
loc_00FCD2:
	lda	$C0
	bne	loc_00FCBD
	lda	$0A,x
	sta	$00
	lda	$0E,x
	sta	$02
	lda	#$001F
	sta	$04
	lda	#$0007
	sta	$06
	ldy	#$0500
	jsl	f:sub_01CF3C
	bcs	loc_00FD11
	lda	#$C516
	sta	a:$0020,y
	phx
	lda	$E8
	and	#$000E
	tax
	lda	a:data_05C838,x
	sta	a:$0018,y
	lda	a:data_05C828,x
	sta	a:$001A,y
	plx
	lda	#$FFFE
	sta	a:$001E,y
loc_00FD11:
	rtl

sub_00FD12:
	lda	$30,x
	beq	loc_00FD25
	clc
	lda	$1C,x
	adc	#$1000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_00FD25:
	inc	$24,x
	ldy	#$0000
	lda	$24,x
	and	#$001F
	cmp	#$0006
	bcc	loc_00FD37
	ldy	#$0002
loc_00FD37:
	cpx	#$03C0
	bne	loc_00FD40
	iny
	iny
	iny
	iny
loc_00FD40:
	lda	a:data_05AAB0,y
	sta	$00,x
	rtl

sub_00FD46:
	lda	$0E,x
	cmp	#$00C8
	bcc	loc_00FD5A
	lda	#$FFFC
	sta	$1E,x
	txy
	lda	#$C69C
	jml	f:sub_01CF66
loc_00FD5A:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_00FD6A:
	dec	$24,x
	bne	loc_00FD73
	lda	#$8000
	sta	$16,x
loc_00FD73:
	lda	a:$044A
	sta	$0A,x
	lda	a:$044E
	adc	#$FFFC
	sta	$0E,x
	lda	$78
	and	#$0004
	lsr	a
	xba
	ora	#$3000
	sta	$02,x
	rtl
