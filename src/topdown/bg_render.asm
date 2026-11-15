; topdown/bg_render.asm -- Top-down stages: BG rendering
; Bank $03, $03:E180-$03:FFFF. Included by main.asm in segment BANK03.
;
; sub_03E180 (from the top-down NMI frame handler nmi_frame_top_down) builds the
; tilemap updates of the top-down stages into the buffer at $1780 (one half
; per player view in two-player games, on alternate frames).

sub_03E180:
	.a16
	.i16
	rep	#$30
	lda	a:title_menu_cursor
	beq	loc_03E18F
	dec	a
	bne	loc_03E18F
	lda	frame_counter
	lsr	a
	bcs	loc_03E193
loc_03E18F:
	jml	f:loc_03E918
loc_03E193:
	jml	f:loc_03F3B2

sub_03E197:
	phx
	ldx	zp_DA
	jmp	(.loword(tbl_03E19D),x)
tbl_03E19D:
	.addr	sub_03E1A5
	.addr	sub_03E262
	.addr	sub_03E322
	.addr	sub_03E3E5

sub_03E1A5:
	sec
	sbc	zp_1A
	bmi	loc_03E201
	cmp	#$00B8
	bcs	loc_03E1D8
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E1DA
	cmp	#$00B8
	bcs	loc_03E1D8
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	[zp_D7],y
	sec
	sbc	zp_DD
	clc
	adc	zp_1E
	sta	zp_02
	clc
loc_03E1D8:
	plx
	rts
loc_03E1DA:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E1D8
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	[zp_D4],y
	sec
	sbc	zp_E0
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts
loc_03E201:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E236
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E238
	cmp	#$00B8
	bcs	loc_03E236
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	clc
loc_03E236:
	plx
	rts
loc_03E238:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E236
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts

sub_03E262:
	sec
	sbc	zp_1A
	bmi	loc_03E2C1
	cmp	#$00B8
	bcs	loc_03E298
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E29A
	cmp	#$00B8
	bcs	loc_03E298
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	[zp_D7],y
	sec
	sbc	zp_DD
	clc
	adc	zp_1C
	sta	zp_00
	clc
loc_03E298:
	plx
	rts
loc_03E29A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E298
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
loc_03E2C1:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E2F9
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E2FB
	cmp	#$00B8
	bcs	loc_03E2F9
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	clc
loc_03E2F9:
	plx
	rts
loc_03E2FB:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E2F9
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts

sub_03E322:
	sec
	sbc	zp_1A
	bmi	loc_03E384
	cmp	#$00B8
	bcs	loc_03E358
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E35A
	cmp	#$00B8
	bcs	loc_03E358
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
loc_03E358:
	plx
	rts
loc_03E35A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E358
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts
loc_03E384:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E3B9
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E3BB
	cmp	#$00B8
	bcs	loc_03E3B9
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
loc_03E3B9:
	plx
	rts
loc_03E3BB:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E3B9
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts

sub_03E3E5:
	sec
	sbc	zp_1A
	bmi	loc_03E444
	cmp	#$00B8
	bcs	loc_03E418
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E41A
	cmp	#$00B8
	bcs	loc_03E418
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
loc_03E418:
	plx
	rts
loc_03E41A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E418
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	[zp_D4],y
	sec
	sbc	zp_E0
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
loc_03E444:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E476
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E478
	cmp	#$00B8
	bcs	loc_03E476
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
loc_03E476:
	plx
	rts
loc_03E478:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E476
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
loc_03E4A5:
	; (not executed in the CDL traces)
	ldy	#$0FC0
	lda	#$AAAA
	sta	a:wram_11C0
	lda	#$AAAA
	sta	a:wram_11C2
	lda	a:p1_lives
	bne	loc_03E4BC
	brl	loc_03E4C8
loc_03E4BC:
	ldx	#$0EC0
	jsr	a:sub_03E4EF
	jsr	a:sub_03E549
	jsr	a:sub_03E589
loc_03E4C8:
	lda	a:p2_lives
	bne	loc_03E4D0
	brl	loc_03E4D9
loc_03E4D0:
	ldx	#$0F00
	jsr	a:sub_03E4EF
	jsr	a:sub_03E569
loc_03E4D9:
	jsr	a:sub_03E5CB
	jsr	a:sub_03E60D
	lda	#$F000
loc_03E4E2:
	sta	a:$0000,y
	iny
	iny
	iny
	iny
	cpy	#$11C0
	bcc	loc_03E4E2
	rtl

sub_03E4EF:
	; (not executed in the CDL traces)
	phy
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$000A
	clc
	adc	a:RDDIVL
	sta	zp_02
	lda	$04,x
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:data_05E748,y
	sta	zp_04
	lda	$02,x
	and	#$0E00
	ora	#$3100
	sta	zp_06
	ply
	rts

sub_03E549:
	; (not executed in the CDL traces)
	lda	$0E,x
	and	#$03FF
	cmp	#$0200
	bcs	loc_03E55E
	lda	#$002A
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
loc_03E55E:
	lda	#$0000
	sta	zp_08
	lda	#$FFE8
	sta	zp_0A
	rts

sub_03E569:
	; (not executed in the CDL traces)
	lda	$0E,x
	and	#$03FF
	cmp	#$0200
	bcs	loc_03E57E
	lda	#$002C
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
loc_03E57E:
	lda	#$0002
	sta	zp_08
	lda	#$FFE8
	sta	zp_0A
	rts

sub_03E589:
	; (not executed in the CDL traces)
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	zp_0A
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_08
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts

sub_03E5CB:
	; (not executed in the CDL traces)
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	zp_0A
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_08
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts

sub_03E60D:
	; (not executed in the CDL traces)
	jsr	a:sub_03E8F3
	ldx	#$0AC0
loc_03E613:
	lda	$10,x
	beq	loc_03E656
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$000A
	clc
	adc	a:RDDIVL
	sta	zp_02
	jsr	a:sub_03E662
loc_03E656:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_03E613
	rts

sub_03E662:
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts
loc_03E682:
	ldy	#$0FC0
	lda	#$AAAA
	sta	a:wram_11C0
	lda	#$AAAA
	sta	a:wram_11C2
	lda	#$AAAA
	sta	a:wram_11C4
	lda	#$0002
	sta	a:wram_11C6
	lda	a:intro_phase
	dec	a
	beq	loc_03E6A6
	brl	loc_03E6B2
loc_03E6A6:
	jsr	a:sub_03E87C
	jsr	a:sub_03E6C2
	jsr	a:sub_03E79B
	jsr	a:sub_03E89E
loc_03E6B2:
	lda	#$F000
loc_03E6B5:
	sta	a:$0000,y
	iny
	iny
	iny
	iny
	cpy	#$11C0
	bcc	loc_03E6B5
	rtl

sub_03E6C2:
	lda	a:p1_lives
	bne	loc_03E6CA
	; (not executed in the CDL traces)
	brl	loc_03E79A
loc_03E6CA:
	phy
	lda	a:p1_start_x
	asl	a
	tay
	lda	a:data_05E788,y
	sta	zp_00
	lda	a:p1_start_y
	asl	a
	tay
	lda	a:data_05E790,y
	sta	zp_02
	ply
	lda	#$3900
	sta	zp_06
	lda	a:p1_start_chosen
	beq	loc_03E6F4
	lda	zp_78
	bit	#$0004
	beq	loc_03E6F4
	brl	loc_03E79A
loc_03E6F4:
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	sep	#$20
	.a8
	lda	zp_00
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0000
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$4026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$8026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$C026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
loc_03E79A:
	rts

sub_03E79B:
	lda	a:title_menu_cursor
	bne	loc_03E7A3
	brl	loc_03E87B
loc_03E7A3:
	lda	a:p2_lives
	bne	loc_03E7AB
	; (not executed in the CDL traces)
	brl	loc_03E87B
loc_03E7AB:
	phy
	lda	a:p2_start_x
	asl	a
	tay
	lda	a:data_05E788,y
	sta	zp_00
	lda	a:p2_start_y
	asl	a
	tay
	lda	a:data_05E790,y
	sta	zp_02
	ply
	lda	#$3B00
	sta	zp_06
	lda	a:p2_start_chosen
	beq	loc_03E7D5
	lda	zp_78
	bit	#$0004
	bne	loc_03E7D5
	brl	loc_03E87B
loc_03E7D5:
	lda	zp_02
	clc
	adc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$002C
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$4026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$8026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$C026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
loc_03E87B:
	rts

sub_03E87C:
	ldx	#$0014
loc_03E87F:
	lda	#$0008
	sta	a:$0001,y
	lda	a:data_05E796,x
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	a:data_05E7AA,x
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	dex
	dex
	bne	loc_03E87F
	rts

sub_03E89E:
	jsr	a:sub_03E8F3
	ldx	#$0AC0
loc_03E8A4:
	lda	$10,x
	beq	loc_03E8E7
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_02
	jsr	a:sub_03E662
loc_03E8E7:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_03E8A4
	rts

sub_03E8F3:
	ldx	#$0000
	lda	zp_78
	bit	#$0003
	bne	loc_03E900
	ldx	#$0002
loc_03E900:
	stx	zp_FA
	lda	#$0000
	ldx	stage_number
	cpx	#$0002
	beq	loc_03E90F
	lda	#$0004
loc_03E90F:
	ora	zp_FA
	tax
	lda	a:data_05E7C0,x
	sta	zp_06
	rts
loc_03E918:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	loc_03E96E
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_03E92A
	brl	loc_03E9A0
loc_03E92A:
	lda	a:intro_phase
	beq	loc_03E932
	brl	loc_03E682
loc_03E932:
	lda	a:map_view_active
	beq	loc_03E93A
	; (not executed in the CDL traces)
	brl	loc_03E4A5
loc_03E93A:
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03E9E8
	jsr	a:sub_03EA78
	jsr	a:sub_03EAA9
	jsr	a:sub_03E9D7
	bcs	loc_03E956
	jsr	a:sub_03EABF
	jsr	a:sub_03EB48
loc_03E956:
	jsr	a:sub_03EB72
	jsr	a:sub_03EB8F
	jsr	a:sub_03EC63
	jsr	a:sub_03F0F7
	jsr	a:sub_03F161
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_03E96E:
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03E9E8
	jsr	a:sub_03EA78
	jsr	a:sub_03EAA9
	jsr	a:sub_03EABF
	jsr	a:sub_03EB48
	jsr	a:sub_03EB72
	jsr	a:sub_03ED33
	jsr	a:sub_03EDF6
	jsr	a:sub_03EEAA
	jsr	a:sub_03F0F7
	jsr	a:sub_03F161
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_03E9A0:
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03E9E8
	jsr	a:sub_03EA78
	jsr	a:sub_03EAA9
	jsr	a:sub_03E9D7
	bcs	loc_03E9BC
	jsr	a:sub_03EABF
	jsr	a:sub_03EB48
loc_03E9BC:
	jsr	a:sub_03EB72
	jsr	a:sub_03F1B0
	jsr	a:sub_03F202
	jsr	a:sub_03F2E3
	jsr	a:sub_03EC63
	jsr	a:sub_03F161
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_03E9D7:
	lda	a:title_menu_cursor
	beq	loc_03E9DF
	dec	a
	bne	loc_03E9E6
loc_03E9DF:
	lda	a:wram_0EEC
	beq	loc_03E9E6
	sec
	rts
loc_03E9E6:
	clc
	rts

sub_03E9E8:
	lda	a:title_menu_cursor
	beq	loc_03E9F0
	dec	a
	beq	loc_03EA17
loc_03E9F0:
	lda	#$0008
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
	bra	loc_03EA3C
loc_03EA17:
	lda	#$FFF0
	sta	a:zp_0C
	lda	#$0068
	sta	a:zp_0E
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
loc_03EA3C:
	asl	a
	asl	a
	asl	a
	xba
	and	#$0006
	sta	zp_DA
	lda	zp_16
	and	#$003F
	xba
	sta	zp_D4
	lsr	a
	clc
	adc	zp_D4
	clc
	adc	#$8000
	sta	zp_D4
	lda	zp_16
	and	#$003F
	eor	#$003F
	inc	a
	xba
	sta	zp_D7
	lsr	a
	clc
	adc	zp_D7
	clc
	adc	#$8000
	sta	zp_D7
	sep	#$20
	.a8
	lda	#$03
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

sub_03EA78:
	lda	a:wram_020A
	sta	a:wram_0FC0
	lda	a:wram_020E
	sta	a:wram_0FC1
	lda	a:player1_obj
	sta	a:wram_0FC2
	lda	a:wram_024A
	sta	a:wram_0FC4
	lda	a:wram_024E
	sta	a:wram_0FC5
	lda	a:player2_obj
	sta	a:wram_0FC6
	lda	a:wram_11C0
	and	#$FF00
	ora	#$00AA
	sta	a:wram_11C0
	rts

sub_03EAA9:
	ldx	#$0FD0
	stx	zp_10
	ldx	#$11C0
	stx	zp_12
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
	rts

sub_03EABF:
	ldx	#$0300
loc_03EAC2:
	lda	$10,x
	beq	loc_03EB39
	lda	$04,x
	bmi	loc_03EADA
	sec
	sbc	a:p1_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:data_0780C8,y
	bra	loc_03EADE
loc_03EADA:
	lda	$00,x
	beq	loc_03EB39
loc_03EADE:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcs	loc_03EB39
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	loc_03EB39
	cmp	zp_0E
	bpl	loc_03EB39
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	loc_03EB39
	cmp	#$FFF0
	bmi	loc_03EB39
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	lda	$16,x
	cmp	#$0008
	ror	zp_14
	bcc	loc_03EB39
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03EB39:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	loc_03EB47
	brl	loc_03EAC2
loc_03EB47:
	rts

sub_03EB48:
	ldx	#$0980
loc_03EB4B:
	lda	$00,x
	beq	loc_03EB66
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcs	loc_03EB66
	lda	$02,x
	ora	#$0100
	sta	zp_06
	ldy	$00,x
	phx
	jsr	a:sub_03F077
	plx
loc_03EB66:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_03EB4B
	rts

sub_03EB72:
	lda	zp_14
loc_03EB74:
	lsr	a
	bcc	loc_03EB74
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10C0
	bcs	loc_03EB8E
	lda	#$F000
loc_03EB83:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10C0
	bcc	loc_03EB83
loc_03EB8E:
	rts

sub_03EB8F:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$8000
	sta	zp_14
	lda	a:title_menu_cursor
	beq	loc_03EBA6
	dec	a
	bne	loc_03EBAE
loc_03EBA6:
	lda	a:wram_0EEC
	beq	loc_03EBAE
	brl	loc_03EC46
loc_03EBAE:
	stz	zp_08
	ldx	#$0D40
loc_03EBB3:
	lda	$00,x
	beq	loc_03EC34
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03EBD6
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	loc_03EC34
loc_03EBD6:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780AC,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07808C,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03EFF9
	plx
	lda	zp_D0
	bne	loc_03EC2D
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03EC34
loc_03EC2D:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03EC34:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03EC46
	brl	loc_03EBB3
loc_03EC46:
	lda	zp_14
loc_03EC48:
	lsr	a
	bcc	loc_03EC48
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	loc_03EC62
	lda	#$F000
loc_03EC57:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1120
	bcc	loc_03EC57
loc_03EC62:
	rts

sub_03EC63:
	ldx	#$1180
	stx	zp_10
	ldx	#$11DC
	stx	zp_12
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03EC77:
	lda	a:title_menu_cursor
	beq	loc_03EC86
	dec	a
	beq	loc_03EC86
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_03EC93
	brl	loc_03ED04
loc_03EC86:
	cpx	#$0EC0
	beq	loc_03EC93
	lda	a:wram_0EEC
	ora	a:wram_0F2C
	bne	loc_03ED04
loc_03EC93:
	lda	$00,x
	beq	loc_03ED04
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03ECB7
	lda	#$8000
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	loc_03ED04
loc_03ECB7:
	lda	zp_00
	sta	a:$00B0,x
	lda	zp_02
	sta	a:$00B4,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780A8,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_078088,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03EFF9
	plx
loc_03ED04:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03ED16
	brl	loc_03EC77
loc_03ED16:
	lda	zp_14
loc_03ED18:
	lsr	a
	bcc	loc_03ED18
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11A0
	bcs	loc_03ED32
	lda	#$F000
loc_03ED27:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11A0
	bcc	loc_03ED27
loc_03ED32:
	rts

sub_03ED33:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$0000
	bne	loc_03ED49
	lda	#$8000
	sta	zp_14
	bra	loc_03ED54
loc_03ED49:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03ED54:
	ldx	#$0B80
	lda	$00,x
	beq	loc_03EDD6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03ED6D
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03EDD6
loc_03ED6D:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	#$0004
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ora	a:data_0780AC
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07808C
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03EFF9
	plx
	lda	zp_D0
	bne	loc_03EDCF
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03EDD6
loc_03EDCF:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03EDD6:
	lda	zp_14
loc_03EDD8:
	lsr	a
	bcc	loc_03EDD8
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10D0
	bcs	loc_03EDF5
	lda	#$F000
loc_03EDEA:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10D0
	bcc	loc_03EDEA
loc_03EDF5:
	rts

sub_03EDF6:
	ldx	#$10E0
	stx	zp_10
	ldx	#$11D2
	stx	zp_12
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03EE0A:
	lda	$00,x
	beq	loc_03EE7B
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03EE2E
	; (not executed in the CDL traces)
	lda	#$8000
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	loc_03EE7B
loc_03EE2E:
	lda	zp_00
	sta	a:$00B0,x
	lda	zp_02
	sta	a:$00B4,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780A8,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_078088,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03EFF9
	plx
loc_03EE7B:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03EE8D
	brl	loc_03EE0A
loc_03EE8D:
	lda	zp_14
loc_03EE8F:
	lsr	a
	bcc	loc_03EE8F
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	loc_03EEA9
	lda	#$F000
loc_03EE9E:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1100
	bcc	loc_03EE9E
loc_03EEA9:
	rts

sub_03EEAA:
	ldx	#$1120
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$0000
	bne	loc_03EEC0
	lda	#$8000
	sta	zp_14
	bra	loc_03EECB
loc_03EEC0:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03EECB:
	lda	#$1028
	sta	zp_06
	lda	#$0040
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:data_079BCE,y
	sta	zp_CA
	lda	a:data_079C0E,y
	ldy	#$0020
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
loc_03EF11:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:$7FFE,x
	tay
	lda	zp_C6
	clc
	adc	a:data_078010,x
	jsr	a:sub_03E197
	bcs	loc_03EF2A
	ldy	zp_CA
	jsr	a:sub_03EFF9
loc_03EF2A:
	dec	zp_08
	dec	zp_08
	bne	loc_03EF11
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$1024
	bit	#$0020
	beq	loc_03EF46
	ldy	#$D024
loc_03EF46:
	sty	zp_06
	tay
	lda	a:data_079C84,y
	ldy	#$0018
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
loc_03EF73:
	lda	zp_C4
	clc
	adc	a:data_078022,x
	tay
	lda	zp_C6
	clc
	adc	a:data_078054,x
	jsr	a:sub_03E197
	bcs	loc_03EFD5
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03EFD5
	cmp	zp_0E
	bpl	loc_03EFD5
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03EFD5
	cmp	#$FFF0
	bmi	loc_03EFD5
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	loc_03EFD5
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03EFD5:
	dex
	dex
	bne	loc_03EF73
	lda	zp_14
loc_03EFDB:
	lsr	a
	bcc	loc_03EFDB
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1170
	bcs	loc_03EFF8
	lda	#$F000
loc_03EFED:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1170
	bcc	loc_03EFED
loc_03EFF8:
	rts

sub_03EFF9:
	stz	zp_D0
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
loc_03F00D:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03F016
	dec	zp_CD
loc_03F016:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03F06C
	cmp	zp_0E
	bpl	loc_03F06C
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03F030
	dec	zp_CD
loc_03F030:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03F06C
	cmp	#$FFF0
	bmi	loc_03F06C
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	inc	zp_D0
	lda	a:$0003,y
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_14
	bcc	loc_03F06C
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03F06C:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03F00D
	stx	zp_10
	rts

sub_03F077:
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
loc_03F089:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03F092
	dec	zp_CD
loc_03F092:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03F0EC
	cmp	zp_0E
	bpl	loc_03F0EC
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03F0AC
	dec	zp_CD
loc_03F0AC:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03F0EC
	cmp	#$FFF0
	bmi	loc_03F0EC
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	lda	a:$0003,y
	and	#$C0FF
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	lda	a:$0004,y
	lsr	a
	ror	zp_14
	bcc	loc_03F0EC
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03F0EC:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03F089
	stx	zp_10
	rts

sub_03F0F7:
	ldx	#$0AC0
loc_03F0FA:
	lda	$10,x
	beq	loc_03F155
	cpx	#$0D40
	bcs	loc_03F10A
	cmp	#$0003
	beq	loc_03F155
	bra	loc_03F10E
loc_03F10A:
	lda	$00,x
	bne	loc_03F155
loc_03F10E:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F120
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F14E
loc_03F120:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_00
	sta	$18,x
	lda	zp_02
	sta	$1C,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03F14E
	cmp	zp_0E
	bpl	loc_03F14E
	lda	zp_00
	cmp	#$0100
	bpl	loc_03F14E
	cmp	#$FFF0
	bmi	loc_03F14E
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F155
loc_03F14E:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F155:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_03F0FA
	rts

sub_03F161:
	lda	a:wram_0EEC
	bne	loc_03F188
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	loc_03F18D
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F180
	lda	#$8000
	sta	$38,x
	sta	$3C,x
	bra	loc_03F18D
loc_03F180:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
loc_03F188:
	lda	a:wram_0F2C
	bne	loc_03F1AF
loc_03F18D:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	loc_03F1AF
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F1A7
	lda	#$8000
	sta	$38,x
	sta	$3C,x
	bra	loc_03F1AF
loc_03F1A7:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
loc_03F1AF:
	rts

sub_03F1B0:
	ldx	#$0AC0
loc_03F1B3:
	lda	$10,x
	beq	loc_03F1F6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F1C9
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F1EF
loc_03F1C9:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03F1EF
	cmp	zp_0E
	bpl	loc_03F1EF
	lda	zp_00
	cmp	#$0100
	bpl	loc_03F1EF
	cmp	#$FFF0
	bmi	loc_03F1EF
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F1F6
loc_03F1EF:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F1F6:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	loc_03F1B3
	rts

sub_03F202:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$8000
	sta	zp_14
	jsr	a:sub_03F2CF
	bcs	loc_03F219
	jsr	a:sub_03F236
loc_03F219:
	lda	zp_14
loc_03F21B:
	lsr	a
	bcc	loc_03F21B
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	loc_03F235
	lda	#$F000
loc_03F22A:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10E0
	bcc	loc_03F22A
loc_03F235:
	rts

sub_03F236:
	stz	zp_08
	ldx	#$0B40
loc_03F23B:
	lda	$00,x
	beq	loc_03F2BC
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F25E
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	loc_03F2BC
loc_03F25E:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780AC,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07808C,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03EFF9
	plx
	lda	zp_D0
	bne	loc_03F2B5
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03F2BC
loc_03F2B5:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03F2BC:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	loc_03F2CE
	brl	loc_03F23B
loc_03F2CE:
	rts

sub_03F2CF:
	lda	a:title_menu_cursor
	beq	loc_03F2D7
	; (not executed in the CDL traces)
	dec	a
	bne	loc_03F2DF
loc_03F2D7:
	lda	a:wram_0EEC
	beq	loc_03F2DF
	; (not executed in the CDL traces)
	brl	loc_03F2E1
loc_03F2DF:
	clc
	rts
loc_03F2E1:
	; (not executed in the CDL traces)
	sec
	rts

sub_03F2E3:
	ldx	#$1100
	stx	zp_10
	ldx	#$11D4
	stx	zp_12
	lda	#$0000
	bne	loc_03F2F9
	lda	#$8000
	sta	zp_14
	bra	loc_03F304
loc_03F2F9:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F304:
	ldx	#$0BC0
loc_03F307:
	lda	$00,x
	beq	loc_03F384
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F321
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F37D
loc_03F321:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03F37D
	cmp	zp_0E
	bpl	loc_03F37D
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03F37D
	cmp	#$FFF0
	bmi	loc_03F37D
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	loc_03F374
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03F374:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F384
loc_03F37D:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F384:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03F392
	brl	loc_03F307
loc_03F392:
	lda	zp_14
loc_03F394:
	lsr	a
	bcc	loc_03F394
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1130
	bcs	loc_03F3B1
	lda	#$F000
loc_03F3A6:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1130
	bcc	loc_03F3A6
loc_03F3B1:
	rts
loc_03F3B2:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	loc_03F408
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_03F3C4
	; (not executed in the CDL traces)
	brl	loc_03F43A
loc_03F3C4:
	lda	a:intro_phase
	beq	loc_03F3CC
	brl	loc_03E682
loc_03F3CC:
	lda	a:map_view_active
	beq	loc_03F3D4
	; (not executed in the CDL traces)
	brl	loc_03E4A5
loc_03F3D4:
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03F482
	jsr	a:sub_03F512
	jsr	a:sub_03F543
	jsr	a:sub_03F471
	bcs	loc_03F3F0
	jsr	a:sub_03F559
	jsr	a:sub_03F5E2
loc_03F3F0:
	jsr	a:sub_03F60C
	jsr	a:sub_03F629
	jsr	a:sub_03F6FD
	jsr	a:sub_03FB91
	jsr	a:sub_03FBFB
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_03F408:
	; (not executed in the CDL traces)
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03F482
	jsr	a:sub_03F512
	jsr	a:sub_03F543
	jsr	a:sub_03F559
	jsr	a:sub_03F5E2
	jsr	a:sub_03F60C
	jsr	a:sub_03F7CD
	jsr	a:sub_03F890
	jsr	a:sub_03F944
	jsr	a:sub_03FB91
	jsr	a:sub_03FBFB
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_03F43A:
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:sub_03F482
	jsr	a:sub_03F512
	jsr	a:sub_03F543
	jsr	a:sub_03F471
	bcs	loc_03F456
	jsr	a:sub_03F559
	jsr	a:sub_03F5E2
loc_03F456:
	jsr	a:sub_03F60C
	jsr	a:sub_03FC4A
	jsr	a:sub_03FC9C
	jsr	a:sub_03FD7D
	jsr	a:sub_03F6FD
	jsr	a:sub_03FBFB
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_03F471:
	lda	a:title_menu_cursor
	beq	loc_03F479
	dec	a
	bne	loc_03F480
loc_03F479:
	lda	a:wram_0F2C
	beq	loc_03F480
	sec
	rts
loc_03F480:
	clc
	rts

sub_03F482:
	lda	a:title_menu_cursor
	beq	loc_03F48A
	dec	a
	beq	loc_03F4B1
loc_03F48A:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p2_view_anchor_x
	sta	zp_1C
	lda	a:p2_view_anchor_y
	sta	zp_1E
	lda	a:p2_view_x
	sta	zp_18
	lda	a:p2_view_y
	sta	zp_1A
	lda	a:p2_view_angle
	sta	zp_16
	bra	loc_03F4D6
loc_03F4B1:
	lda	#$0068
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p2_view_anchor_x
	sta	zp_1C
	lda	a:p2_view_anchor_y
	sta	zp_1E
	lda	a:p2_view_x
	sta	zp_18
	lda	a:p2_view_y
	sta	zp_1A
	lda	a:p2_view_angle
	sta	zp_16
loc_03F4D6:
	asl	a
	asl	a
	asl	a
	xba
	and	#$0006
	sta	zp_DA
	lda	zp_16
	and	#$003F
	xba
	sta	zp_D4
	lsr	a
	clc
	adc	zp_D4
	clc
	adc	#$8000
	sta	zp_D4
	lda	zp_16
	and	#$003F
	eor	#$003F
	inc	a
	xba
	sta	zp_D7
	lsr	a
	clc
	adc	zp_D7
	clc
	adc	#$8000
	sta	zp_D7
	sep	#$20
	.a8
	lda	#$03
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

sub_03F512:
	lda	a:wram_028A
	sta	a:wram_0FC8
	lda	a:wram_028E
	sta	a:wram_0FC9
	lda	a:wram_0280
	sta	a:wram_0FCA
	lda	a:wram_02CA
	sta	a:wram_0FCC
	lda	a:wram_02CE
	sta	a:wram_0FCD
	lda	a:wram_02C0
	sta	a:wram_0FCE
	lda	a:wram_11C0
	and	#$FF00
	ora	#$00AA
	sta	a:wram_11C0
	rts

sub_03F543:
	ldx	#$0FD0
	stx	zp_10
	ldx	#$11C0
	stx	zp_12
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
	rts

sub_03F559:
	ldx	#$0300
loc_03F55C:
	lda	$10,x
	beq	loc_03F5D3
	lda	$04,x
	bmi	loc_03F574
	sec
	sbc	a:p2_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:data_0780C8,y
	bra	loc_03F578
loc_03F574:
	lda	$00,x
	beq	loc_03F5D3
loc_03F578:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcs	loc_03F5D3
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	loc_03F5D3
	cmp	zp_0E
	bpl	loc_03F5D3
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	loc_03F5D3
	cmp	#$FFF0
	bmi	loc_03F5D3
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	lda	$16,x
	cmp	#$0008
	ror	zp_14
	bcc	loc_03F5D3
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03F5D3:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	loc_03F5E1
	brl	loc_03F55C
loc_03F5E1:
	rts

sub_03F5E2:
	ldx	#$0980
loc_03F5E5:
	lda	$00,x
	beq	loc_03F600
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcs	loc_03F600
	lda	$02,x
	ora	#$0100
	sta	zp_06
	ldy	$00,x
	phx
	jsr	a:sub_03FB11
	plx
loc_03F600:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_03F5E5
	rts

sub_03F60C:
	lda	zp_14
loc_03F60E:
	lsr	a
	bcc	loc_03F60E
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10C0
	bcs	loc_03F628
	lda	#$F000
loc_03F61D:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10C0
	bcc	loc_03F61D
loc_03F628:
	rts

sub_03F629:
	ldx	#$1120
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$8000
	sta	zp_14
	lda	a:title_menu_cursor
	beq	loc_03F640
	dec	a
	bne	loc_03F648
loc_03F640:
	lda	a:wram_0F2C
	beq	loc_03F648
	brl	loc_03F6E0
loc_03F648:
	stz	zp_08
	ldx	#$0D40
loc_03F64D:
	lda	$00,x
	beq	loc_03F6CE
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F670
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	loc_03F6CE
loc_03F670:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780BC,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07809C,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03FA93
	plx
	lda	zp_D0
	bne	loc_03F6C7
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03F6CE
loc_03F6C7:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03F6CE:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03F6E0
	brl	loc_03F64D
loc_03F6E0:
	lda	zp_14
loc_03F6E2:
	lsr	a
	bcc	loc_03F6E2
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1180
	bcs	loc_03F6FC
	lda	#$F000
loc_03F6F1:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1180
	bcc	loc_03F6F1
loc_03F6FC:
	rts

sub_03F6FD:
	ldx	#$11A0
	stx	zp_10
	ldx	#$11DE
	stx	zp_12
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03F711:
	lda	a:title_menu_cursor
	beq	loc_03F720
	dec	a
	beq	loc_03F720
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_03F72D
	brl	loc_03F79E
loc_03F720:
	cpx	#$0F00
	beq	loc_03F72D
	lda	a:wram_0F2C
	ora	a:wram_0EEC
	bne	loc_03F79E
loc_03F72D:
	lda	$00,x
	beq	loc_03F79E
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F751
	lda	#$8000
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	loc_03F79E
loc_03F751:
	lda	zp_00
	sta	a:$00B2,x
	lda	zp_02
	sta	a:$00B6,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780B8,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_078098,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03FA93
	plx
loc_03F79E:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03F7B0
	brl	loc_03F711
loc_03F7B0:
	lda	zp_14
loc_03F7B2:
	lsr	a
	bcc	loc_03F7B2
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	loc_03F7CC
	lda	#$F000
loc_03F7C1:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11C0
	bcc	loc_03F7C1
loc_03F7CC:
	rts

sub_03F7CD:
	; (not executed in the CDL traces)
	ldx	#$10D0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$0002
	bne	loc_03F7E3
	lda	#$8000
	sta	zp_14
	bra	loc_03F7EE
loc_03F7E3:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F7EE:
	ldx	#$0B80
	lda	$00,x
	beq	loc_03F870
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F807
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03F870
loc_03F807:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	#$0004
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ora	a:data_0780BC
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07809C
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03FA93
	plx
	lda	zp_D0
	bne	loc_03F869
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03F870
loc_03F869:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03F870:
	lda	zp_14
loc_03F872:
	lsr	a
	bcc	loc_03F872
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	loc_03F88F
	lda	#$F000
loc_03F884:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10E0
	bcc	loc_03F884
loc_03F88F:
	rts

sub_03F890:
	; (not executed in the CDL traces)
	ldx	#$1100
	stx	zp_10
	ldx	#$11D4
	stx	zp_12
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03F8A4:
	lda	$00,x
	beq	loc_03F915
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03F8C8
	lda	#$8000
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	loc_03F915
loc_03F8C8:
	lda	zp_00
	sta	a:$00B2,x
	lda	zp_02
	sta	a:$00B6,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780B8,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_078098,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03FA93
	plx
loc_03F915:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03F927
	brl	loc_03F8A4
loc_03F927:
	lda	zp_14
loc_03F929:
	lsr	a
	bcc	loc_03F929
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	loc_03F943
	lda	#$F000
loc_03F938:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1120
	bcc	loc_03F938
loc_03F943:
	rts

sub_03F944:
	; (not executed in the CDL traces)
	ldx	#$1170
	stx	zp_10
	ldx	#$11DA
	stx	zp_12
	lda	#$0002
	bne	loc_03F95A
	lda	#$8000
	sta	zp_14
	bra	loc_03F965
loc_03F95A:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F965:
	lda	#$10A8
	sta	zp_06
	lda	#$0040
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:data_079BCE,y
	sta	zp_CA
	lda	a:data_079C0E,y
	ldy	#$0060
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
loc_03F9AB:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:$7FFE,x
	tay
	lda	zp_C6
	clc
	adc	a:data_078010,x
	jsr	a:sub_03E197
	bcs	loc_03F9C4
	ldy	zp_CA
	jsr	a:sub_03FA93
loc_03F9C4:
	dec	zp_08
	dec	zp_08
	bne	loc_03F9AB
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$10A4
	bit	#$0020
	beq	loc_03F9E0
	ldy	#$D0A4
loc_03F9E0:
	sty	zp_06
	tay
	lda	a:data_079C84,y
	ldy	#$0058
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
loc_03FA0D:
	lda	zp_C4
	clc
	adc	a:data_078022,x
	tay
	lda	zp_C6
	clc
	adc	a:data_078054,x
	jsr	a:sub_03E197
	bcs	loc_03FA6F
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03FA6F
	cmp	zp_0E
	bpl	loc_03FA6F
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03FA6F
	cmp	#$FFF0
	bmi	loc_03FA6F
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	loc_03FA6F
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03FA6F:
	dex
	dex
	bne	loc_03FA0D
	lda	zp_14
loc_03FA75:
	lsr	a
	bcc	loc_03FA75
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	loc_03FA92
	lda	#$F000
loc_03FA87:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11C0
	bcc	loc_03FA87
loc_03FA92:
	rts

sub_03FA93:
	stz	zp_D0
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
loc_03FAA7:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03FAB0
	dec	zp_CD
loc_03FAB0:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03FB06
	cmp	zp_0E
	bpl	loc_03FB06
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03FACA
	dec	zp_CD
loc_03FACA:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03FB06
	cmp	#$FFF0
	bmi	loc_03FB06
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	inc	zp_D0
	lda	a:$0003,y
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_14
	bcc	loc_03FB06
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03FB06:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03FAA7
	stx	zp_10
	rts

sub_03FB11:
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
loc_03FB23:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03FB2C
	dec	zp_CD
loc_03FB2C:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03FB86
	cmp	zp_0E
	bpl	loc_03FB86
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03FB46
	dec	zp_CD
loc_03FB46:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03FB86
	cmp	#$FFF0
	bmi	loc_03FB86
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	lda	a:$0003,y
	and	#$C0FF
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	lda	a:$0004,y
	lsr	a
	ror	zp_14
	bcc	loc_03FB86
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03FB86:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03FB23
	stx	zp_10
	rts

sub_03FB91:
	ldx	#$0AC0
loc_03FB94:
	lda	$10,x
	beq	loc_03FBEF
	cpx	#$0D40
	bcs	loc_03FBA4
	cmp	#$0003
	beq	loc_03FBEF
	bra	loc_03FBA8
loc_03FBA4:
	lda	$00,x
	bne	loc_03FBEF
loc_03FBA8:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FBBA
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FBE8
loc_03FBBA:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_00
	sta	$1A,x
	lda	zp_02
	sta	$1E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03FBE8
	cmp	zp_0E
	bpl	loc_03FBE8
	lda	zp_00
	cmp	#$0100
	bpl	loc_03FBE8
	cmp	#$FFF0
	bmi	loc_03FBE8
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FBEF
loc_03FBE8:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FBEF:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_03FB94
	rts

sub_03FBFB:
	lda	a:wram_0F2C
	bne	loc_03FC22
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	loc_03FC27
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FC1A
	lda	#$8000
	sta	$3A,x
	sta	$3E,x
	bra	loc_03FC27
loc_03FC1A:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
loc_03FC22:
	lda	a:wram_0EEC
	bne	loc_03FC49
loc_03FC27:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	loc_03FC49
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FC41
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$3A,x
	sta	$3E,x
	bra	loc_03FC49
loc_03FC41:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
loc_03FC49:
	rts

sub_03FC4A:
	; (not executed in the CDL traces)
	ldx	#$0AC0
loc_03FC4D:
	lda	$10,x
	beq	loc_03FC90
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FC63
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FC89
loc_03FC63:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03FC89
	cmp	zp_0E
	bpl	loc_03FC89
	lda	zp_00
	cmp	#$0100
	bpl	loc_03FC89
	cmp	#$FFF0
	bmi	loc_03FC89
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FC90
loc_03FC89:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FC90:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	loc_03FC4D
	rts

sub_03FC9C:
	; (not executed in the CDL traces)
	ldx	#$10E0
	stx	zp_10
	ldx	#$11D2
	stx	zp_12
	lda	#$8000
	sta	zp_14
	jsr	a:sub_03FD69
	bcs	loc_03FCB3
	jsr	a:sub_03FCD0
loc_03FCB3:
	lda	zp_14
loc_03FCB5:
	lsr	a
	bcc	loc_03FCB5
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	loc_03FCCF
	lda	#$F000
loc_03FCC4:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1100
	bcc	loc_03FCC4
loc_03FCCF:
	rts

sub_03FCD0:
	; (not executed in the CDL traces)
	stz	zp_08
	ldx	#$0B40
loc_03FCD5:
	lda	$00,x
	beq	loc_03FD56
	asl	a
	tay
	lda	a:data_078806,y
	sta	zp_C4
	lda	a:data_078828,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FCF8
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	loc_03FD56
loc_03FCF8:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:data_0780BC,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:data_07809C,x
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:sub_03FA93
	plx
	lda	zp_D0
	bne	loc_03FD4F
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03FD56
loc_03FD4F:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03FD56:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	loc_03FD68
	brl	loc_03FCD5
loc_03FD68:
	rts

sub_03FD69:
	; (not executed in the CDL traces)
	lda	a:title_menu_cursor
	beq	loc_03FD71
	dec	a
	bne	loc_03FD79
loc_03FD71:
	lda	a:wram_0F2C
	beq	loc_03FD79
	brl	loc_03FD7B
loc_03FD79:
	clc
	rts
loc_03FD7B:
	sec
	rts

sub_03FD7D:
	; (not executed in the CDL traces)
	ldx	#$1130
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$0002
	bne	loc_03FD93
	lda	#$8000
	sta	zp_14
	bra	loc_03FD9E
loc_03FD93:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03FD9E:
	ldx	#$0BC0
loc_03FDA1:
	lda	$00,x
	beq	loc_03FE1E
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:sub_03E197
	bcc	loc_03FDBB
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FE17
loc_03FDBB:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03FE17
	cmp	zp_0E
	bpl	loc_03FE17
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03FE17
	cmp	#$FFF0
	bmi	loc_03FE17
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	loc_03FE0E
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03FE0E:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FE1E
loc_03FE17:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FE1E:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03FE2C
	brl	loc_03FDA1
loc_03FE2C:
	lda	zp_14
loc_03FE2E:
	lsr	a
	bcc	loc_03FE2E
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1160
	bcs	loc_03FE4B
	lda	#$F000
loc_03FE40:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1160
	bcc	loc_03FE40
loc_03FE4B:
	rts
	; CDL: not accessed
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF
