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
	sty	a:wram_1686
loc_00F28A:
	sta	$32,x
	jsl	f:sub_0181E8
loc_00F290:
	inc	a:wram_1636
	ldy	#$0012
	lda	zp_C0
	cmp	#$0005
	bcs	loc_00F2A0
	ldy	#$0000
loc_00F2A0:
	sty	a:mosaic_shadow
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_00F2B2,x
	plx
	sta	zp_00
	jmp	(zp_00)
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
	sta	a:wram_1682
	lda	#$0004
	sta	a:wram_1680
	stz	$32,x
	inc	$12,x
	lda	#$0040
	sta	zp_04
	lda	#$A000
	sta	zp_02
	ldy	#$4830
	lda	#$0018
	jml	f:sub_00CFAF

sub_00F2EF:
	lda	a:wram_13BA
	cmp	#$0004
	bne	loc_00F319
	stz	hdma_preset
	inc	$12,x
	lda	#$0080
	sta	$24,x
	stx	zp_FC
	ldx	#.loword(data_05AA1F)
	jsl	f:sub_0090A8
	ldy	#$AA28
	jsl	f:sub_009982
	ldx	zp_FC
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
	lda	a:wram_1678
	bne	loc_00F34B
	lda	#$0068
	jsl	f:queue_sound
	lda	#$0058
	jsl	f:queue_sound
	lda	#$0002
	sta	$24,x
	inc	$12,x
	jsr	a:sub_00F514
	stz	a:wram_163A
	lda	#$0020
	sta	a:wram_163C
	sta	a:wram_1640
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
	sta	zp_0C
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
	sta	zp_0C
	lda	#$0030
loc_00F383:
	sta	zp_08
	lda	a:wram_1380
	bit	#$0100
	beq	loc_00F395
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
loc_00F395:
	lda	#$0002
	sta	zp_02
	phx
	lda	zp_0C
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
	sta	hdma_preset
	inc	$12,x
	lda	#$0020
	sta	a:wram_1636
	stz	$36,x
	lda	#$0080
	sta	$38,x
	lda	#$0080
	sta	a:wram_0474
	lda	#$0100
	sta	a:wram_1638
	jsr	a:sub_00F907
loc_00F3DF:
	dec	a:wram_030E
	jsr	a:sub_00F5D9
	jsr	a:sub_00F8E2
	rtl

sub_00F3E9:
	lda	a:wram_163C
	cmp	#$0020
	bne	loc_00F405
	lda	$32,x
	bne	loc_00F3FC
	lda	rng_lo
	bit	#$003F
	bne	loc_00F405
loc_00F3FC:
	lda	#$0003
	sta	a:wram_163E
	inc	$12,x
	rtl
loc_00F405:
	lda	#$2000
	sta	zp_00
	stz	zp_02
	jsr	a:sub_00F850
	jsr	a:sub_00F672
	brl	loc_00F46D

sub_00F415:
	lda	a:wram_163C
	cmp	#$0007
	bcs	loc_00F42D
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0004
	sta	a:wram_1662
	inc	$12,x
	rtl
loc_00F42D:
	stz	zp_00
	lda	#$0002
	sta	zp_02
	jsr	a:sub_00F85A
	jsr	a:sub_00F672
	brl	loc_00F46D

sub_00F43D:
	lda	a:wram_163C
	cmp	#$0020
	bcc	loc_00F45D
	dec	a:wram_163E
	bne	loc_00F45A
	lda	$32,x
	bne	loc_00F45A
	lda	#$0020
	sta	a:wram_1636
	lda	#$0006
	sta	$12,x
	rtl
loc_00F45A:
	dec	$12,x
	rtl
loc_00F45D:
	stz	zp_00
	lda	#$0002
	sta	zp_02
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
	sta	zp_00
	lda	$0E,x
	adc	#$0010
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$007F
	sta	zp_06
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
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	#$4D8C
	phx
	ldx	#$0020
	jsl	f:sub_00FEAA
	plx
	rts

sub_00F4DA:
	lda	#$A000
	sta	zp_00
	lda	#$0020
	sta	zp_E2
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
	lda	zp_00
	sta	a:$1840,y
	clc
	lda	zp_B6
	adc	#$0008
	sta	zp_B6
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
	sta	a:wram_1644
	brl	loc_00F5B1
loc_00F571:
	rts
loc_00F572:
	dec	a:wram_1644
	bpl	loc_00F5B0
	lda	#$0020
	sta	$24,x
	stz	a:wram_0318
	stz	a:wram_031A
	stz	a:wram_031C
	stz	a:wram_031E
	stz	a:wram_0330
	stz	a:wram_03D8
	stz	a:wram_03DA
	stz	a:wram_03DC
	stz	a:wram_03DE
	stz	a:wram_03F0
	lda	#$0004
	sta	a:wram_1662
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0056
	jsl	f:queue_sound
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
	stz	zp_00
	sec
	lda	a:wram_030A
	sbc	a:wram_03CA
	bpl	loc_00F5E9
	eor	#$FFFF
	inc	zp_00
loc_00F5E9:
	and	#$00FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$03
	sta	a:WRDIVB
	rep	#$20
	.a16
	stz	zp_02
	sec
	lda	a:wram_030E
	sbc	a:wram_03CE
	bpl	loc_00F608
	eor	#$FFFF
	inc	zp_02
loc_00F608:
	and	#$00FF
	pha
	lda	a:RDDIVL
	ldy	zp_00
	bne	loc_00F616
	eor	#$FFFF
loc_00F616:
	sta	zp_00
	clc
	lda	a:wram_030A
	adc	zp_00
	adc	#$0000
	sta	a:wram_034A
	clc
	adc	zp_00
	adc	#$0000
	sta	a:wram_038A
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
	ldy	zp_02
	bne	loc_00F64C
	; (not executed in the CDL traces)
	eor	#$FFFF
loc_00F64C:
	sta	zp_02
	clc
	lda	a:wram_030E
	adc	zp_02
	sta	a:wram_034E
	clc
	adc	zp_02
	sta	a:wram_038E
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
	sta	zp_0C
	jmp	(zp_0C)
tbl_00F681:
	.addr	sub_00F7AE
	.addr	sub_00F6E3
	.addr	sub_00F71B
	.addr	sub_00F757
	.addr	sub_00F69D
	.addr	sub_00F6C7
	.addr	sub_00F68F

sub_00F68F:
	ldy	a:wram_1640
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
	jsl	f:queue_sound
	inc	$36,x
	ldy	difficulty
	lda	a:data_05AB52,y
	sta	$38,x
loc_00F6B6:
	jsr	a:sub_00FB71
	ldy	a:wram_1640
	cpy	#$001C
	bcs	loc_00F6C4
	brl	loc_00F882
loc_00F6C4:
	brl	loc_00F88A

sub_00F6C7:
	lda	#$0002
	sta	$3E,x
	lda	#$0001
	sta	a:wram_1660
	dec	$38,x
	bne	loc_00F6DD
	stz	$36,x
	lda	#$0100
	sta	$38,x
loc_00F6DD:
	jsr	a:sub_00FBAB
	brl	loc_00F828

sub_00F6E3:
	lda	zp_C0
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
	ldy	a:wram_1640
	lda	a:wram_1636
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
	lda	a:wram_1636
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
	ldy	a:wram_1640
	lda	a:wram_1636
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
	lda	zp_78
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
	stz	a:wram_0464
loc_00F771:
	ldy	a:wram_1640
	lda	$38,x
	bit	#$0080
	bne	loc_00F78F
	lda	a:p1_lives
	bne	loc_00F783
	; (not executed in the CDL traces)
	brl	loc_00F797
loc_00F783:
	sec
	lda	a:wram_020E
	sbc	a:wram_044E
	bcs	loc_00F7A3
	brl	loc_00F705
loc_00F78F:
	lda	a:p2_lives
	bne	loc_00F797
	brl	loc_00F783
loc_00F797:
	; (not executed in the CDL traces)
	sec
	lda	a:wram_024E
	sbc	a:wram_044E
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
	lda	rng_lo
	bit	#$0003
	beq	loc_00F7DD
	bit	#$0001
	bne	loc_00F7C6
	ldy	#$00C0
	lda	#$0001
	bra	loc_00F806
loc_00F7C6:
	lda	#$0057
	jsl	f:queue_sound
	lda	a:wram_0490
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
	jsl	f:queue_sound
	stz	$3A,x
	ldy	#$0080
	lda	#$0004
	bra	loc_00F806
loc_00F7F3:
	lda	#$0057
	jsl	f:queue_sound
	lda	#$0001
	sta	a:wram_0464
	ldy	#$0100
	lda	#$0003
loc_00F806:
	sta	$36,x
	sty	$38,x
loc_00F80A:
	ldy	a:wram_1640
	lda	a:wram_1636
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
	adc	zp_00
	sta	f:$7EA0C6,x
	lda	f:$7EA046,x
	adc	zp_02
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
	lda	a:wram_1636
	and	#$0040
	bne	sub_00F85A
	bra	sub_00F871

sub_00F85A:
	lda	zp_00
	eor	#$FFFF
	clc
	adc	#$0001
	sta	zp_00
	lda	zp_02
	eor	#$FFFF
	adc	#$0000
	sta	zp_02
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
	inc	a:wram_1640
	ldy	#$0000
	bra	loc_00F890
loc_00F88A:
	dec	a:wram_1640
	ldy	#$0038
loc_00F890:
	phx
	ldx	#$0000
	lda	#$0020
loc_00F897:
	sta	zp_08
loc_00F899:
	clc
	lda	f:$7EA0C6,x
	adc	a:data_05921A,y
	sta	zp_04
	lda	f:$7EA046,x
	adc	a:data_0591AA,y
	and	#$00FF
	sta	zp_06
	clc
	lda	zp_04
	adc	zp_00
	sta	f:$7EA0C6,x
	lda	zp_06
	adc	zp_02
	and	#$00FF
	ora	#$4000
	sta	f:$7EA046,x
	iny
	iny
	inx
	inx
	cpx	zp_08
	bcc	loc_00F899
	plx
	rts

sub_00F8D0:
	clc
	lda	a:wram_163A
	adc	zp_00
	sta	a:wram_163A
	lda	a:wram_163C
	adc	zp_02
	sta	a:wram_163C
	rts

sub_00F8E2:
	sec
	lda	#$01C0
	sbc	a:wram_030A
	sta	a:wram_13C0
	sec
	lda	#$009C
	sbc	a:wram_030E
	sta	a:wram_13D8
loc_00F8F6:
	lda	a:wram_030A
	adc	#$FFE0
	sta	$0A,x
	lda	a:wram_030E
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
	ldy	difficulty
	lda	#$0160
	sta	a:wram_0406
	lda	a:data_05AB40,y
	sta	a:wram_0486
	plx
	rts

sub_00F949:
	lda	a:wram_1638
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
	lda	a:wram_1638
	bit	#$0100
	beq	loc_00F98C
	and	#$00F8
	lsr	a
	lsr	a
	lsr	a
	sta	zp_00
	lda	#$00F8
	dex
	dex
loc_00F976:
	dec	zp_00
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
	sbc	f:wram_7EA068
	sta	a:wram_040E
	stz	a:wram_040F
	sec
	lda	#$90
	sbc	f:wram_7EA056
	sta	a:wram_044E
	stz	a:wram_044F
	sec
	lda	#$60
	sbc	a:wram_1638
	sta	a:wram_044A
	stz	a:wram_044B
	sec
	lda	#$9C
	sbc	f:wram_7EA070
	sta	a:wram_030E
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
	lda	zp_78
	bit	#$0040
	beq	loc_00FA54
	lda	zp_C0
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
	lda	a:wram_048E
	adc	#$FFE8
	sta	a:$000E,y
	lda	a:wram_048A
	adc	#$0010
	sta	a:$000A,y
	lda	rng_lo
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
	lda	zp_78
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
	lda	a:wram_044E
	sta	a:$000E,y
	lda	a:wram_044A
	adc	#$0008
	sta	a:$000A,y
	lda	#$0001
	sta	a:$0006,y
	lda	rng_lo
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
	jsl	f:queue_sound
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_00FAD3:
	lda	zp_E6
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
	ldy	difficulty
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
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_00FB2A:
	lda	$12,x
	bne	loc_00FB6B
	stz	zp_00
	stz	zp_02
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
	stz	zp_00
	stz	zp_02
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
	lda	a:wram_044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:wram_044E
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
	lda	a:wram_044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:wram_044E
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
	lda	a:wram_1638
	cmp	#$0100
	bcs	loc_00FC11
loc_00FBF8:
	sty	zp_00
	lda	a:wram_1638
	clc
	adc	#$0004
	cmp	zp_00
	bcc	loc_00FC07
	lda	zp_00
loc_00FC07:
	sta	a:wram_1638
	rtl
loc_00FC0B:
	lda	a:wram_1638
	ldy	#$00E0
loc_00FC11:
	sty	zp_00
	sec
	sbc	#$000C
	cmp	zp_00
	bcs	loc_00FC1D
	lda	zp_00
loc_00FC1D:
	sta	a:wram_1638
	rtl

sub_00FC21:
	dec	$34,x
	bpl	loc_00FC43
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:data_05AB4C,y
	sta	$34,x
	lda	$0E,x
	adc	#$FFF8
	sta	zp_02
	lda	$0A,x
	adc	#$0010
	sta	zp_00
	jsl	f:sub_01A0E9
loc_00FC43:
	lda	$26,x
	beq	loc_00FC58
	lda	#$912A
	sta	cgram_upload_src
	lda	#$0060
	sta	cgram_upload_addr
	lda	#$000F
	jsl	f:queue_sound
loc_00FC58:
	lda	$06,x
	bpl	loc_00FCBD
	lda	#$0100
	sta	a:wram_0932
	lda	#$0110
	sta	a:wram_093E
	lda	#$0006
	sta	a:wram_0936
	stz	a:wram_0464
	lda	#$8000
	sta	$16,x
	lda	#$C540
	sta	zp_00
	ldy	#$0010
	lda	#$4E94
	jml	f:loc_00FE7D

sub_00FC85:
	sec
	lda	#$0060
	sbc	f:wram_7EA068
	and	#$00FF
	sta	a:$000E,x
	lda	$12,x
	bne	loc_00FCC9
	lda	a:wram_0932
	bne	loc_00FCA0
	lda	$06,x
	bpl	loc_00FCBD
loc_00FCA0:
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x
	inc	$12,x
	lda	#$C480
	sta	zp_00
	ldy	#$0008
	lda	#$4D14
	jml	f:loc_00FE7D
loc_00FCBD:
	lda	$14,x
	beq	loc_00FCC8
	lda	#$000F
	jml	f:queue_sound
loc_00FCC8:
	rtl
loc_00FCC9:
	dec	$24,x
	bne	loc_00FCD2
	lda	#$8000
	sta	$16,x
loc_00FCD2:
	lda	zp_C0
	bne	loc_00FCBD
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$001F
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0500
	jsl	f:sub_01CF3C
	bcs	loc_00FD11
	lda	#$C516
	sta	a:$0020,y
	phx
	lda	rng_lo
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
	lda	a:wram_044A
	sta	$0A,x
	lda	a:wram_044E
	adc	#$FFFC
	sta	$0E,x
	lda	zp_78
	and	#$0004
	lsr	a
	xba
	ora	#$3000
	sta	$02,x
	rtl
