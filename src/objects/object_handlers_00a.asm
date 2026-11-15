; objects/object_handlers_00a.asm -- Object handlers (bank $00, part 1)
; Bank $00, $00:CF0C-$00:D655. Included by main.asm in segment BANK00.
;
; Handlers of object types dispatched through tbl_object_types (see
; objects/object_loop.asm) and helpers they share.

sub_00CF0C:
	clc
	lda	a:wram_168C
	adc	a:wram_1384
	sta	a:wram_1384
	lda	a:wram_1380
	sta	zp_00
	adc	a:wram_168E
	sta	a:wram_1380
	sec
	sbc	zp_00
	sta	a:wram_1694
	clc
	lda	a:wram_1690
	adc	a:wram_139C
	sta	a:wram_139C
	lda	a:wram_1398
	sta	zp_00
	adc	a:wram_1692
	sta	a:wram_1398
	sec
	sbc	zp_00
	sta	a:wram_1696
	ldy	a:wram_168A
	lda	a:data_059BC8,y
	cmp	a:wram_1380
	bcc	loc_00CF7D
	phx
	ldx	#$0600
	jsl	f:sub_019E86
	bcc	loc_00CF59
	; (not executed in the CDL traces)
	plx
	rtl
loc_00CF59:
	lda	a:data_059BCA,y
	pha
	and	#$00FF
	sta	$10,x
	pla
	xba
	and	#$00FF
	sec
	sbc	a:wram_1398
	sta	$0E,x
	lda	a:data_059BCC,y
	sta	$3A,x
	stz	$0A,x
	tya
	clc
	adc	#$0006
	sta	a:wram_168A
	plx
loc_00CF7D:
	rtl

sub_00CF7E:
	lda	zp_78
	and	#$0007
	dec	a
	bne	loc_00CF9D
	lda	zp_78
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_059E42,y
	sta	zp_B4
	lda	#$0400
	sta	zp_B2
	lda	#$3A90
	sta	zp_B0
loc_00CF9D:
	rtl

sub_00CF9E:
	; (not executed in the CDL traces)
	lda	a:bg2sc_shadow
	and	#$FFFC
	ora	$3A,x
	sta	a:bg2sc_shadow
	lda	#$8000
	sta	$16,x
	rtl

sub_00CFAF:
	phx
	tax
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00CFB9:
	.a16
	lda	zp_02
	sta	a:$0000,y
	tya
	clc
	adc	zp_04
	tay
	dex
	bne	loc_00CFB9
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	plx
	rtl

sub_00CFD0:
	lda	#$8000
	sta	$16,x
	stz	a:wram_13B4
	lda	#$0004
	sta	a:wram_13BA
	stz	a:wram_13B6
	lda	a:wram_160A
	sta	zp_02
	lda	(zp_02)
	clc
	adc	#$0080
	and	#$FF00
	sta	a:wram_160C
	sta	(zp_02)
	rtl

sub_00CFF5:
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	a:wram_1E40
	rtl

sub_00D001:
	lda	$12,x
	bne	loc_00D019
	lda	#$0001
	sta	a:wram_13FA
	lda	$3A,x
	and	#$FFF0
	sta	a:wram_13FC
	inc	$12,x
	stz	a:wram_13FE
	rtl
loc_00D019:
	lda	a:wram_13FE
	beq	loc_00D02B
	lda	$3A,x
	and	#$000F
	sta	a:wram_13FA
	lda	#$8000
	sta	$16,x
loc_00D02B:
	rtl

sub_00D02C:
	lda	#$0001
	sta	a:wram_13B4
	lda	#$8000
	sta	$16,x
	rtl

sub_00D038:
	clc
	lda	a:wram_13D8
	adc	#$00FF
	and	#$FF00
	sta	a:wram_13F0
	lda	$3B,x
	and	#$00FF
	sta	a:wram_13FA

sub_00D04D:
	lda	$3A,x
	and	#$00FF
	sta	a:wram_13BA
	stz	a:wram_13B4
	clc
	lda	a:wram_1380
	adc	#$00FF
	and	#$FF00
	sta	a:wram_1380
	clc
	lda	a:wram_1398
	adc	#$00FF
	and	#$FF00
	sta	a:wram_1398
	lda	#$8000
	sta	$16,x
	rtl

sub_00D078:
	lda	#$8000
	sta	$16,x
	lda	$3A,x
	tay
	stx	zp_FA
	ldx	a:data_059E4A,y
	jsl	f:sub_0090A8
	ldx	zp_FA
	rtl

sub_00D08C:
	sep	#$20
	.a8
	stz	a:wram_1673
	lda	$3B,x
	sta	a:wram_1672
	stz	a:wram_1667
	lda	$3A,x
	sta	a:wram_1666
	rep	#$20
	.a16
	lda	#$8000
	sta	$16,x
	rtl

sub_00D0A6:
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	ldy	$3A,x
	lda	a:data_059F06,y
	sta	a:wram_1680
	lda	a:data_059F08,y
	sta	a:wram_1682
	rtl

sub_00D0BA:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_00D0C9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00D0C9:
	.addr	sub_00D0DB
	.addr	sub_00D0E6
	.addr	sub_00D107
	.addr	sub_00D1BD
	.addr	sub_00D290
	.addr	sub_00D2F8
	.addr	sub_00D37E
	.addr	sub_00D480
	.addr	sub_00D3E7

sub_00D0DB:
	lda	a:wram_13BA
	cmp	#$0004
	bne	loc_00D0E5
	inc	$12,x
loc_00D0E5:
	rtl

sub_00D0E6:
	lda	#$003F
	sta	a:wram_166C
	lda	#$A000
	sta	a:wram_161E
	lda	#$F300
	sta	a:wram_161C
	stz	a:wram_1620
	stz	a:wram_1622
	inc	$12,x
	lda	#$0005
	sta	a:wram_13FA
	rtl

sub_00D107:
	lda	#$0008
	sta	zp_08
	stx	zp_FE
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	a:wram_1620
	jsl	f:sub_008D41
loc_00D11D:
	lda	a:wram_161C
	tay
	lda	a:$0000,y
	and	#$3FFF
	clc
	adc	a:wram_1622
	tay
loc_00D12C:
	lda	a:$5000,y
	and	#$00FF
	sta	zp_0A
	ldx	a:wram_161E
	lda	a:$0000,x
	and	#$00FF
	xba
	ora	zp_0A
	ldx	vram_queue_data_ptr
	sta	a:$0000,x
	inc	vram_queue_data_ptr
	inc	vram_queue_data_ptr
	inc	a:wram_161E
	iny
	iny
	tya
	and	#$0007
	bne	loc_00D12C
	inc	a:wram_161C
	inc	a:wram_161C
	lda	a:wram_161C
	and	#$000F
	bne	loc_00D196
	clc
	lda	a:wram_161C
	adc	#$0070
	sta	a:wram_161C
	cmp	#$F500
	bcc	loc_00D196
	sec
	sbc	#$0200
	sta	a:wram_161C
	clc
	lda	a:wram_1622
	adc	#$0008
	cmp	#$0020
	bcc	loc_00D187
	lda	#$0000
loc_00D187:
	sta	a:wram_1622
	bne	loc_00D196
	clc
	lda	a:wram_161C
	adc	#$0010
	sta	a:wram_161C
loc_00D196:
	dec	zp_08
	beq	loc_00D19D
	brl	loc_00D11D
loc_00D19D:
	jsl	f:sub_008DB0
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FE
	clc
	lda	a:wram_1620
	adc	#$0020
	sta	a:wram_1620
	cmp	#$1000
	bcc	loc_00D1BC
	inc	$12,x
loc_00D1BC:
	rtl

sub_00D1BD:
	stx	zp_FC
	lda	#$0005
	sta	hdma_preset
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	#$3800
	lda	#$0018
	sta	a:$0000,y
	lda	a:wram_1380
	sta	a:$0001,y
	lda	#$0048
	sta	a:$0003,y
	lda	#$0101
	sta	a:$0005,y
	lda	a:wram_1380
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3820
	lda	#$0018
	sta	a:$0000,y
	lda	#$0000
	sta	a:$0001,y
	lda	#$0002
	sta	a:$0003,y
	lda	#$0100
	sta	a:$0005,y
	lda	#$FFFF
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3840
	lda	#$0918
	sta	a:$0000,y
	lda	#$0702
	sta	a:$0002,y
	lda	#$0901
	sta	a:$0004,y
	lda	#$0000
	sta	a:$0006,y
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FC
	inc	$12,x
	stz	$24,x
	stz	$38,x
	stz	$30,x
	lda	#$7FFF
	sta	$1C,x
	lda	#$FFFD
	sta	$1E,x
	stz	a:wram_1636
	lda	#$00A0
	sta	f:wram_7E3824
	lda	#$0320
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	stz	a:m7b_shadow
	stz	a:m7c_shadow
	lda	#$0180
	sta	a:m7x_shadow
	lda	#$00A8
	sta	a:m7y_shadow
	lda	#$00C1
	sta	a:m7sel_shadow
	lda	#$0001
	sta	a:wram_1672
	lda	#$0045
	jsl	f:queue_sound
	lda	#$0080
	sta	a:wram_1692
loc_00D28F:
	rtl

sub_00D290:
	lda	a:wram_1692
	bmi	loc_00D29A
	dec	a:wram_1692
	bpl	loc_00D28F
loc_00D29A:
	lda	a:m7d_shadow
	cmp	#$0280
	bcs	sub_00D2F8
	lda	#$0046
	jsl	f:queue_sound
	inc	$12,x
	lda	a:wram_0290
	bne	sub_00D2F8
	phx
	ldy	#$0300
	ldx	#$0004
loc_00D2B7:
	lda	#$000C
	sta	a:$0010,y
	lda	#$9F12
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$4000
	sta	a:$001C,y
	lda	#$0003
	sta	a:$001E,y
	lda	#$0038
	sta	a:$000E,y
	lda	a:data_059F08,x
	sta	a:$000A,y
	lda	a:data_059F0C,x
	sta	a:$0034,y
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bne	loc_00D2B7
	plx

sub_00D2F8:
	sec
	lda	a:m7a_shadow
	sbc	#$0008
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	cmp	#$002A
	bcs	loc_00D323
	lda	#$0047
	jsl	f:queue_sound
	inc	$12,x
	stz	hdma_preset
	stz	$24,x
	stx	zp_FC
	ldx	#.loword(data_059FBA)
	jsl	f:sub_0090A8
	ldx	zp_FC
	rtl
loc_00D323:
	cmp	#$01D0
	bcs	loc_00D332
	lda	zp_BC
	bne	loc_00D332
	dec	a:m7b_shadow
	dec	a:m7c_shadow
loc_00D332:
	clc
	lda	$1C,x
	adc	#$0700
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	clc
	lda	a:wram_1636
	adc	$1C,x
	sta	a:wram_1636
	lda	f:wram_7E3824
	adc	$1E,x
	sta	f:wram_7E3824
	sep	#$20
	.a8
	lda	a:wram_1398
	dec	a
	sta	f:wram_7E3827
	lda	f:wram_7E3842
	cmp	#$47
	bcs	loc_00D37B
	sec
	lda	$38,x
	sbc	$1C,x
	sta	$38,x
	lda	f:wram_7E3842
	sbc	$1E,x
	sta	f:wram_7E3842
	sta	f:wram_7E3823
loc_00D37B:
	rep	#$20
	.a16
	rtl

sub_00D37E:
	lda	#$0003
	sta	a:shake_timer
	inc	$24,x
	lda	$24,x
	cmp	#$0100
	bcs	loc_00D394
	cmp	#$00D8
	bne	loc_00D3C0
	bra	loc_00D3C0
loc_00D394:
	inc	$12,x
	lda	#$0001
	sta	a:wram_13BA
	lda	#$0004
	sta	hdma_preset
	stz	$32,x
	lda	#$007F
	sta	f:wram_7E3820
	lda	#$0020
	sta	f:wram_7E3823
	lda	#$0020
	sta	f:wram_7E3826
	lda	#$0000
	sta	f:wram_7E3829
	rtl
loc_00D3C0:
	lda	#$0008
	sta	zp_00
	lda	#$00D0
	sta	zp_02
	lda	#$00FF
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#$C4CE
	jsl	f:sub_01CF3C
	bcs	loc_00D3E6
	lda	#$FFFC
	sta	a:$001E,y
loc_00D3E6:
	rtl

sub_00D3E7:
	phx
	lda	#$0038
	sta	zp_02
	ldx	a:wram_166C
	lda	a:data_059F6A,x
	and	#$00FF
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
loc_00D401:
	.a8
	lda	a:$A000,y
	ora	f:data_059F2A,x
	sta	a:$A000,y
	lda	a:$A001,y
	ora	f:data_059F2A,x
	sta	a:$A001,y
	lda	a:$A380,y
	ora	f:data_059F2A,x
	sta	a:$A380,y
	lda	a:$A381,y
	ora	f:data_059F2A,x
	sta	a:$A381,y
	lda	a:$A700,y
	ora	f:data_059F2A,x
	sta	a:$A700,y
	lda	a:$A701,y
	ora	f:data_059F2A,x
	sta	a:$A701,y
	lda	a:$AA80,y
	ora	f:data_059F2A,x
	sta	a:$AA80,y
	lda	a:$AA81,y
	ora	f:data_059F2A,x
	sta	a:$AA81,y
	rep	#$20
	.a16
	tya
	clc
	adc	#$0010
	tay
	sep	#$20
	.a8
	dec	zp_02
	bne	loc_00D401
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	plx
	lda	zp_BC
	bne	loc_00D47E
	dec	a:wram_166C
	bne	loc_00D47E
	lda	#$8000
	sta	$16,x
	stz	hdma_preset
	stz	a:wram_1672
	rtl
loc_00D47E:
	bra	loc_00D48E

sub_00D480:
	lda	#$00C0
	sta	zp_00
	stz	zp_02
	lda	#$0000
	jsl	f:sub_01A296
loc_00D48E:
	lda	a:wram_13C0
	sta	f:wram_7E3821
	sta	f:wram_7E3824
	lda	a:wram_1380
	and	#$00FF
	sta	f:wram_7E3827
	inc	$32,x
	lda	$32,x
	asl	a
	and	#$0006
	tay
	lda	a:data_059FAA,y
	sta	zp_B4
	lda	#$0380
	sta	zp_B2
	lda	#$2E40
	sta	zp_B0
	rtl

sub_00D4BC:
	ldy	#$09C0
loc_00D4BF:
	lda	a:$0010,y
	cmp	#$0006
	beq	loc_00D4D2
	; (not executed in the CDL traces)
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0AC0
	bcc	loc_00D4BF
loc_00D4D2:
	lda	a:$0012,y
	inc	a
	sta	a:$0012,y
	lda	#$8000
	sta	$16,x
	ldy	#$0280
loc_00D4E1:
	lda	a:$0010,y
	cmp	#$002F
	beq	loc_00D4EE
	; (not executed in the CDL traces)
	ldy	#$02C0
	bra	loc_00D4E1
loc_00D4EE:
	lda	#$8000
	sta	a:$0016,y
	rtl

sub_00D4F5:
	lda	zp_BC
	bne	loc_00D530
	ldy	$20,x
	lda	a:$0004,y
	sta	zp_00
	ldy	#$0840
	jsl	f:sub_019EC1
	bcc	loc_00D530
	lda	zp_00
	sta	a:$0020,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$E000
	sta	a:$001C,y
	lda	#$FFFD
	sta	a:$001E,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$001D
	sta	a:$0010,y
loc_00D530:
	sec
	lda	$1C,x
	sbc	#$0900
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	lda	$34,x
	bpl	loc_00D553
	sec
	lda	$18,x
	sbc	#$1400
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rtl
loc_00D553:
	clc
	lda	$18,x
	adc	#$1400
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	rtl

sub_00D563:
	lda	zp_78
	bit	#$0007
	bne	loc_00D57F
	and	#$0018
	lsr	a
	lsr	a
	tay
	lda	a:data_059FB2,y
	sta	zp_B4
	lda	#$02E0
	sta	zp_B2
	lda	#$0E80
	sta	zp_B0
loc_00D57F:
	lda	#$0001
	sta	a:wram_1676
	clc
	lda	a:wram_13D8
	adc	#$0200
	sta	a:wram_1674
	cmp	#$0090
	bcs	loc_00D5A2
	lda	#$8000
	sta	$16,x
	stz	a:wram_1676
	stz	a:wram_1674
	stz	hdma_preset
	rtl
loc_00D5A2:
	ldy	#$001E
	lda	#$0800
	sta	zp_08
loc_00D5AA:
	lda	#$0000
	sta	zp_04
	sta	zp_0A
	lda	a:wram_13D2

sub_00D5B4:
	sta	zp_02
	stz	zp_00
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00D5C0:
	.a16
	clc
	lda	a:$E800,y
	adc	zp_00
	sta	a:$E800,y
	lda	a:$E000,y
	adc	zp_02
	sta	a:$E000,y
	clc
	lda	zp_00
	adc	zp_08
	sta	zp_00
	lda	zp_02
	adc	zp_0A
	sta	zp_02
	dey
	dey
	cpy	zp_04
	bne	loc_00D5C0
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_00D5ED:
	lda	zp_78
	lsr	a
	lsr	a
	lsr	a
	and	#$0007
	bit	#$0004
	beq	loc_00D5FD
	eor	#$FFFF
loc_00D5FD:
	and	#$0003
	pha
	clc
	adc	a:wram_1674
	sta	a:wram_1674
	pla
	clc
	adc	#$0000
	sta	a:wram_13D8

sub_00D610:
	lda	#$0002
	sta	a:wram_1676
	clc
	lda	a:wram_13D8
	adc	#$0100
	sta	a:wram_1674
	cmp	#$0002
	bcs	loc_00D630
	inc	$12,x
	stz	a:wram_1676
	stz	a:wram_1674
	stz	hdma_preset
	rtl
loc_00D630:
	ldy	#$001A
	lda	#$0012
	sta	zp_04
	lda	#$0000
	sta	zp_08
	lda	#$0001
	sta	zp_0A
	lda	#$000C
	jsl	f:sub_00D5B4
	ldy	#$0012
	lda	#$6000
	sta	zp_08
	brl	loc_00D5AA
	; CDL: not accessed
	.byte	$6B
loc_00D655:
	rtl
