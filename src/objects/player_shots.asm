; objects/player_shots.asm -- Player shots
; Bank $00, $00:D656-$00:DDC7. Included by main.asm in segment BANK00.
;
; Spawning of the players' shots: sub_00D656, sub_00D692, sub_00D6DC (called
; from the player weapon code in bank $01) dispatch per weapon through
; tbl_00D686, tbl_00D6C2, tbl_00D717 to routines that allocate object slots
; (sub_00E122) and set position and velocity from aim-direction tables in bank
; $05.

sub_00D656:
	lda	$3A,x
	bne	loc_00D655
	lda	a:$1D84,x
	pha
	asl	a
	tay
	lda	a:data_05A008,y
	sta	$3A,x
	txy
	lda	#$0AC0
	cpy	#$0200
	beq	loc_00D671
	lda	#$0D40
loc_00D671:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_00D686,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00D686:
	.addr	sub_00D758
	.addr	sub_00D7E3
	.addr	sub_00D8B2
	.addr	sub_00D961
	.addr	sub_00D9F5
	.addr	sub_00DC5A

sub_00D692:
	lda	$14,x
	bne	loc_00D655
	lda	a:$1D86,x
	pha
	asl	a
	tay
	lda	a:data_05A008,y
	sta	$14,x
	txy
	lda	#$0C00
	cpy	#$0200
	beq	loc_00D6AD
	lda	#$0E80
loc_00D6AD:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_00D6C2,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00D6C2:
	.addr	sub_00D741
	.addr	sub_00D7C6
	.addr	sub_00D895
	.addr	sub_00D942
	.addr	sub_00D9DE
	.addr	sub_00DC3D
loc_00D6CE:
	lda	$22,x
	bit	zp_88
	beq	loc_00D740
	lda	#$000E
	sta	a:$1300,x
	bra	loc_00D6E2

sub_00D6DC:
	lda	$22,x
	bit	zp_88
	beq	loc_00D740
loc_00D6E2:
	lda	a:$1D80,x
	beq	loc_00D723
	lda	$3A,x
	bne	loc_00D740
	lda	a:$1D84,x
	pha
	asl	a
	tay
	lda	a:data_05A008,y
	sta	$3A,x
	txy
	lda	#$0AC0
	cpy	#$0200
	beq	loc_00D702
	lda	#$0D40
loc_00D702:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_00D717,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00D717:
	.addr	sub_00D76B
	.addr	sub_00D81A
	.addr	sub_00D8E3
	.addr	sub_00D97A
	.addr	sub_00DA08
	.addr	sub_00DC88
loc_00D723:
	lda	$14,x
	bne	loc_00D740
	lda	a:$1D86,x
	pha
	asl	a
	tay
	lda	a:data_05A008,y
	sta	$14,x
	txy
	lda	#$0C00
	cpy	#$0200
	beq	loc_00D702
	lda	#$0E80
	bra	loc_00D702
loc_00D740:
	rtl

sub_00D741:
	clc
	lda	a:$0034,y
	adc	#$0008
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	sub_00D76B

sub_00D758:
	clc
	lda	a:$0036,y
	adc	#$0008
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	sub_00D76B
loc_00D769:
	tyx
	rtl

sub_00D76B:
	jsl	f:sub_00E122
	bcs	loc_00D769
	lda	#$0001
	sta	$10,x
	sta	$04,x
	lda	#$0002
	sta	$06,x
	lda	#$3E0C
	sta	$14,x
	stz	$16,x
	phy
	ldy	#$3F82
	lda	zp_BC
	bne	loc_00D78F
	ldy	#$3FEC
loc_00D78F:
	sty	$02,x
	ldy	zp_12
	lda	a:data_058E1A,y
	sta	$18,x
	lda	a:data_058D7A,y
	sta	$1A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	ply
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	$0E,x
	tyx
	lda	#$0001
	sta	$38,x
	lda	#$0004
	jsl	f:queue_sound
	rtl

sub_00D7C6:
	jsr	a:sub_00D7FA
	beq	loc_00D7CC
	rtl
loc_00D7CC:
	clc
	lda	a:$0034,y
	adc	#$0020
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D820

sub_00D7E3:
	; (not executed in the CDL traces)
	jsr	a:sub_00D7FA
	beq	loc_00D7E9
	rtl
loc_00D7E9:
	clc
	lda	a:$0036,y
	adc	#$0020
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	loc_00D820

sub_00D7FA:
	lda	$10,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	beq	loc_00D819
	txa
	clc
	adc	#$00A0
	tax
	lda	$10,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	beq	loc_00D819
	tyx
loc_00D819:
	rts

sub_00D81A:
	jsr	a:sub_00D7FA
	beq	loc_00D820
	rtl
loc_00D820:
	lda	#$0005
	sta	zp_10
	sec
	lda	zp_12
	sbc	#$000C
	and	#$007E
	sta	zp_12
loc_00D830:
	lda	#$0002
	sta	$10,x
	lda	#$3F84
	sta	$02,x
	lda	#$0001
	sta	$04,x
	lda	#$3F0E
	sta	$14,x
	lda	#$0002
	sta	$06,x
	sty	zp_FE
	clc
	lda	zp_12
	adc	#$0004
	and	#$007E
	sta	zp_12
	tay
	lda	a:data_058E1A,y
	sta	$18,x
	lda	a:data_058D7A,y
	sta	$1A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	ldy	zp_FE
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	$0E,x
	txa
	clc
	adc	#$0020
	tax
	dec	zp_10
	bne	loc_00D830
	tyx
	lda	#$0001
	sta	$38,x
	lda	#$0009
	jsl	f:queue_sound
	rtl

sub_00D895:
	jsr	a:sub_00D8C9
	beq	loc_00D89B
	rtl
loc_00D89B:
	clc
	lda	a:$0034,y
	adc	#$0010
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D8E9

sub_00D8B2:
	jsr	a:sub_00D8C9
	beq	loc_00D8B8
	rtl
loc_00D8B8:
	clc
	lda	a:$0036,y
	adc	#$0010
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	loc_00D8E9

sub_00D8C9:
	lda	$10,x
	beq	loc_00D8E2
	txa
	clc
	adc	#$0060
	tax
	lda	$10,x
	beq	loc_00D8E2
	txa
	clc
	adc	#$0060
	tax
	lda	$10,x
	beq	loc_00D8E2
	tyx
loc_00D8E2:
	rts

sub_00D8E3:
	jsr	a:sub_00D8C9
	beq	loc_00D8E9
	rtl
loc_00D8E9:
	lda	#$0003
	sta	$10,x
	lda	#$0004
	sta	$06,x
	sty	zp_FE
	lda	zp_12
	tay
	lsr	a
	lsr	a
	lsr	a
	pha
	sta	$00,x
	lda	a:data_058E1A,y
	sta	$18,x
	lda	a:data_058D7A,y
	sta	$1A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	ply
	lda	a:data_05A014,y
	sta	$02,x
	ldy	zp_FE
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	$0E,x
	lda	#$0010
	sta	$04,x
	lda	#$0020
	sta	$14,x
	tyx
	lda	#$0001
	sta	$38,x
	lda	#$0007
	jsl	f:queue_sound
	rtl

sub_00D942:
	jsl	f:sub_00E134
	bcc	loc_00D94A
	tyx
	rtl
loc_00D94A:
	clc
	lda	a:$0034,y
	adc	#$0010
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D982

sub_00D961:
	; (not executed in the CDL traces)
	jsl	f:sub_00E134
	bcc	loc_00D969
	tyx
	rtl
loc_00D969:
	clc
	lda	a:$0036,y
	adc	#$0010
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	loc_00D982

sub_00D97A:
	jsl	f:sub_00E134
	bcc	loc_00D982
	tyx
	rtl
loc_00D982:
	lda	#$0004
	sta	$10,x
	lda	#$0002
	sta	$06,x
	phy
	stx	zp_04
	sec
	lda	zp_06
	sbc	zp_04
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	#$0006
	clc
	adc	zp_12
	and	#$007E
	tay
	sta	$04,x
	lda	a:data_058E1A,y
	sta	$18,x
	lda	a:data_058D7A,y
	sta	$1A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	ply
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	$0E,x
	lda	#$305E
	sta	$02,x
	tyx
	lda	#$0001
	sta	$38,x
	lda	#$0008
	jsl	f:queue_sound
	rtl

sub_00D9DE:
	clc
	lda	a:$0034,y
	adc	#$0004
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	sub_00DA08

sub_00D9F5:
	; (not executed in the CDL traces)
	clc
	lda	a:$0036,y
	adc	#$0004
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	sub_00DA08
loc_00DA06:
	tyx
	rtl

sub_00DA08:
	lda	$12,x
	beq	loc_00DA0F
	brl	loc_00DA80
loc_00DA0F:
	lda	$10,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	ora	$B0,x
	ora	$D0,x
	ora	$F0,x
	ora	a:$0110,x
	ora	a:$0130,x
	bne	loc_00DA06
	inc	$12,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	zp_12
	asl	a
	asl	a
	sta	$14,x
	sta	$34,x
	sta	$54,x
	sta	$74,x
	sta	$94,x
	sta	$B4,x
	sta	$D4,x
	sta	$F4,x
	lda	#$8000
	sta	$2A,x
	sta	$4A,x
	sta	$6A,x
	sta	$8A,x
	sta	$AA,x
	sta	$CA,x
	sta	$EA,x
	sta	a:$010A,x
	sta	a:$012A,x
	phx
	tyx
	lda	zp_12
	lsr	a
	lsr	a
	lsr	a
	tay
	clc
	lda	$0A,x
	adc	zp_14
	adc	a:data_05A024,y
	sta	zp_00
	clc
	lda	$0E,x
	adc	zp_16
	adc	a:data_05A034,y
	ply
	sta	a:$000E,y
	lda	zp_00
	sta	a:$000A,y
	rtl
loc_00DA80:
	lda	zp_78
	bit	#$000F
	bne	loc_00DA8E
	lda	#$000A
	jsl	f:queue_sound
loc_00DA8E:
	lda	$D4,x
	sta	$F4,x
	lda	$B4,x
	sta	$D4,x
	lda	$94,x
	sta	$B4,x
	lda	$74,x
	sta	$94,x
	lda	$54,x
	sta	$74,x
	lda	$34,x
	sta	$54,x
	lda	$14,x
	sta	$34,x
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	zp_00
	sec
	lda	$0A,x
	sbc	zp_00
	cmp	#$0005
	bcc	loc_00DAD3
	cmp	#$FFFB
	bcs	loc_00DAD3
	bmi	loc_00DACB
	sec
	lda	$0A,x
	sbc	#$0005
	bra	loc_00DAD5
loc_00DACB:
	clc
	lda	$0A,x
	adc	#$0005
	bra	loc_00DAD5
loc_00DAD3:
	lda	zp_00
loc_00DAD5:
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	zp_00
	sec
	lda	$0E,x
	sbc	zp_00
	cmp	#$0005
	bcc	loc_00DB00
	cmp	#$FFFB
	bcs	loc_00DB00
	bmi	loc_00DAF8
	sec
	lda	$0E,x
	sbc	#$0005
	bra	loc_00DB02
loc_00DAF8:
	clc
	lda	$0E,x
	adc	#$0005
	bra	loc_00DB02
loc_00DB00:
	lda	zp_00
loc_00DB02:
	sta	$0E,x
	phy
	lda	zp_12
	asl	a
	asl	a
	sta	zp_06
	tay
	sec
	lda	zp_06
	sbc	$14,x
	beq	loc_00DB17
	bmi	loc_00DB1B
	bpl	loc_00DB2D
loc_00DB17:
	lda	zp_06
	bra	loc_00DB40
loc_00DB1B:
	cmp	#$FF00
	bcc	loc_00DB37
	cmp	#$FFF0
	bcs	loc_00DB17
loc_00DB25:
	sec
	lda	$14,x
	sbc	#$0010
	bra	loc_00DB3D
loc_00DB2D:
	cmp	#$0100
	bcs	loc_00DB25
	cmp	#$0010
	bcc	loc_00DB17
loc_00DB37:
	clc
	lda	$14,x
	adc	#$0010
loc_00DB3D:
	and	#$01FF
loc_00DB40:
	sta	$14,x
	lda	$F4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$CE,x
	sta	$EE,x
	clc
	adc	#$FFF0
	sta	a:$012E,x
	clc
	lda	a:data_058F1A,y
	adc	$CA,x
	sta	$EA,x
	sta	a:$012A,x
	lda	$D4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$AE,x
	sta	$CE,x
	clc
	adc	#$FFF4
	sta	a:$010E,x
	clc
	lda	a:data_058F1A,y
	adc	$AA,x
	sta	$CA,x
	sta	a:$010A,x
	lda	$B4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$8E,x
	sta	$AE,x
	clc
	lda	a:data_058F1A,y
	adc	$8A,x
	sta	$AA,x
	lda	$94,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$6E,x
	sta	$8E,x
	clc
	lda	a:data_058F1A,y
	adc	$6A,x
	sta	$8A,x
	lda	$74,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$4E,x
	sta	$6E,x
	clc
	lda	a:data_058F1A,y
	adc	$4A,x
	sta	$6A,x
	lda	$54,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$2E,x
	sta	$4E,x
	clc
	lda	a:data_058F1A,y
	adc	$2A,x
	sta	$4A,x
	lda	$14,x
	sta	$34,x
	lda	$0E,x
	sta	$2E,x
	lda	$0A,x
	sta	$2A,x
	lda	#$0005
	sta	$10,x
	lda	#$0006
	sta	$30,x
	sta	$50,x
	sta	$70,x
	sta	$90,x
	sta	$B0,x
	sta	$D0,x
	sta	$F0,x
	sta	a:$0110,x
	sta	a:$0130,x
	stz	$04,x
	lda	#$3F62
	sta	$24,x
	inc	a
	inc	a
	sta	$44,x
	sta	$64,x
	inc	a
	inc	a
	sta	$84,x
	sta	$A4,x
	inc	a
	inc	a
	sta	$C4,x
	sta	$E4,x
	inc	a
	inc	a
	sta	a:$0104,x
	sta	a:$0124,x
	lda	#$0001
	sta	$26,x
	sta	$46,x
	sta	$66,x
	sta	$86,x
	sta	$A6,x
	sta	$C6,x
	sta	$E6,x
	lda	#$0001
	sta	$00,x
	sta	$20,x
	sta	$40,x
	sta	$60,x
	sta	$80,x
	sta	$A0,x
	sta	$C0,x
	sta	a:$0100,x
	sta	$E0,x
	sta	a:$0120,x
	plx
	rtl

sub_00DC3D:
	jsr	a:sub_00DC71
	beq	loc_00DC43
	rtl
loc_00DC43:
	clc
	lda	a:$0034,y
	adc	#$0010
	and	#$007E
	sta	a:$0034,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00DC8E

sub_00DC5A:
	jsr	a:sub_00DC71
	beq	loc_00DC60
	rtl
loc_00DC60:
	clc
	lda	a:$0036,y
	adc	#$0010
	and	#$007E
	sta	a:$0036,y
	sta	zp_12
	bra	loc_00DC8E

sub_00DC71:
	lda	$10,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	ora	$B0,x
	ora	$D0,x
	ora	$F0,x
	ora	a:$0110,x
	beq	loc_00DC87
	tyx
loc_00DC87:
	rts

sub_00DC88:
	jsr	a:sub_00DC71
	beq	loc_00DC8E
	rtl
loc_00DC8E:
	lda	#$000C
	sta	$30,x
	lda	#$000B
	sta	$10,x
	sta	$50,x
	sta	$70,x
	sta	$90,x
	sta	$B0,x
	sta	$D0,x
	sta	$F0,x
	sta	a:$0110,x
	sty	zp_FE
	ldy	zp_12
	lda	a:data_058E1A,y
	sta	$18,x
	sta	$58,x
	sta	$78,x
	sta	$98,x
	sta	$B8,x
	sta	$D8,x
	sta	$F8,x
	sta	a:$0118,x
	lda	a:data_058D7A,y
	sta	$1A,x
	sta	$5A,x
	sta	$7A,x
	sta	$9A,x
	sta	$BA,x
	sta	$DA,x
	sta	$FA,x
	sta	a:$011A,x
	lda	a:data_058DFA,y
	sta	$1C,x
	sta	$5C,x
	sta	$7C,x
	sta	$9C,x
	sta	$BC,x
	sta	$DC,x
	sta	$FC,x
	sta	a:$011C,x
	lda	a:data_058D5A,y
	sta	$1E,x
	sta	$5E,x
	sta	$7E,x
	sta	$9E,x
	sta	$BE,x
	sta	$DE,x
	sta	$FE,x
	sta	a:$011E,x
	lda	zp_12
	lsr	a
	lsr	a
	lsr	a
	tay
	lda	a:data_05A064,y
	sta	$02,x
	lda	a:data_05A044,y
	sta	zp_00
	lda	a:data_05A054,y
	sta	zp_02
	lda	#$0004
	sta	$44,x
	inc	a
	inc	a
	sta	$64,x
	inc	a
	inc	a
	sta	$84,x
	inc	a
	inc	a
	inc	a
	sta	$A4,x
	inc	a
	inc	a
	sta	$C4,x
	inc	a
	inc	a
	sta	$E4,x
	inc	a
	inc	a
	inc	a
	sta	a:$0104,x
	sta	$24,x
	lda	a:data_05A064,y
	sta	$54,x
	sta	$74,x
	sta	$94,x
	sta	$B4,x
	sta	$D4,x
	sta	$F4,x
	sta	a:$0114,x
	ldy	zp_FE
	clc
	lda	a:$000A,y
	adc	zp_14
	sta	$0A,x
	sta	$2A,x
	clc
	adc	zp_00
	sta	$4A,x
	clc
	adc	zp_00
	sta	$6A,x
	clc
	adc	zp_00
	sta	$8A,x
	clc
	adc	zp_00
	sta	$AA,x
	clc
	adc	zp_00
	sta	$CA,x
	clc
	adc	zp_00
	sta	$EA,x
	clc
	adc	zp_00
	sta	a:$010A,x
	clc
	lda	a:$000E,y
	adc	zp_16
	sta	$0E,x
	sta	$2E,x
	clc
	adc	zp_02
	sta	$4E,x
	clc
	adc	zp_02
	sta	$6E,x
	clc
	adc	zp_02
	sta	$8E,x
	clc
	adc	zp_02
	sta	$AE,x
	clc
	adc	zp_02
	sta	$CE,x
	clc
	adc	zp_02
	sta	$EE,x
	clc
	adc	zp_02
	sta	a:$010E,x
	lda	#$0004
	sta	$06,x
	dec	$16,x
	dec	$36,x
	dec	$56,x
	dec	$76,x
	dec	$96,x
	dec	$B6,x
	dec	$D6,x
	dec	$F6,x
	dec	a:$0116,x
	tyx
	lda	#$0001
	sta	$38,x
	lda	#$0005
	jsl	f:queue_sound
	rtl
