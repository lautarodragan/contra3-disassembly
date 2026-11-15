; game/attract.asm -- Attract mode: intro, title, demo
; Bank $00, $00:AD7C-$00:B678. Included by main.asm in segment BANK00.
;
; Game modes 0, 3 and 4 and their helpers: the intro (sub_00B4DD, sub-modes
; tbl_00B4F1), the title screen helpers, and the attract demo (sub_00AD7C;
; demo index $1E48; sub_00AECD/sub_00AF11 read data from banks $15/$16,
; probably the recorded inputs). sub_00B2F3..sub_00B39F (never run in the
; traces) look like button-code checks.

sub_00AD7C:
	lda	a:wram_1C00
	asl	a
	tax
	jmp	(.loword(tbl_00AD84),x)
tbl_00AD84:
	.addr	sub_00AD8A
	.addr	sub_00ADD1
	.addr	sub_00AE15

sub_00AD8A:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	a:demo_index
	asl	a
	tay
	lda	a:data_0584DA,y
	sta	stage_number
	jsr	a:sub_00AF40
	jsl	f:sub_04D9F1
	lda	stage_number
	dec	a
	sta	stage_index
	jsr	a:sub_00AFE4
	stz	zp_E6
	stz	rng_lo
	stz	rng_hi
	stz	frame_counter
	stz	zp_78
	lda	#$0002
	sta	zp_4A
	lda	#$0800
	sta	zp_4C
	inc	a:wram_1C00
	rtl

sub_00ADD1:
	dec	zp_4C
	beq	loc_00ADFF
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00AE0B
	jsr	a:sub_00AE39
	jsl	f:sub_00ABE0
	lda	a:wram_1E4A
	beq	loc_00ADFA
	; (not executed in the CDL traces)
	lda	a:wram_1C08
	cmp	#$0400
	bcs	loc_00ADFF
	lda	a:wram_1C0B
	cmp	#$0800
	bcs	loc_00ADFF
loc_00ADFA:
	lda	zp_36
	bne	loc_00ADFF
	rtl
loc_00ADFF:
	stz	zp_36
	lda	#$0001
	sta	a:wram_1C02
	inc	a:wram_1C00
	rtl
loc_00AE0B:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:wram_1C02
	inc	a:wram_1C00
	rtl

sub_00AE15:
	jsl	f:sub_00B031
	bcs	loc_00AE38
	lda	a:demo_index
	inc	a
	cmp	#$0003
	bcc	loc_00AE27
	lda	#$0000
loc_00AE27:
	sta	a:demo_index
	stz	zp_46
	stz	nmi_mode
	lda	#$0002
	sta	zp_3E
	lda	a:wram_1C02
	sta	zp_36
loc_00AE38:
	rtl

sub_00AE39:
	lda	a:wram_1E4A
	beq	loc_00AEB2
	; (not executed in the CDL traces)
	jsr	a:sub_00AE44
	jmp	a:loc_00AE7B

sub_00AE44:
	; (not executed in the CDL traces)
	inc	a:wram_1C04
	lda	joy1_held
	cmp	a:wram_1C0E
	bne	loc_00AE4F
	rts
loc_00AE4F:
	ldy	#$0000
	lda	a:wram_1C08
	sta	zp_00
	lda	a:wram_1C09
	sta	zp_01
	lda	a:wram_1C0E
	sta	[zp_00],y
	iny
	iny
	lda	a:wram_1C04
	sta	[zp_00],y
	lda	joy1_held
	sta	a:wram_1C0E
	stz	a:wram_1C04
	lda	a:wram_1C08
	clc
	adc	#$0004
	sta	a:wram_1C08
	rts
loc_00AE7B:
	inc	a:wram_1C06
	lda	joy2_held
	cmp	a:wram_1C10
	bne	loc_00AE86
	rts
loc_00AE86:
	ldy	#$0000
	lda	a:wram_1C0B
	sta	zp_00
	lda	a:wram_1C0C
	sta	zp_01
	lda	a:wram_1C10
	sta	[zp_00],y
	iny
	iny
	lda	a:wram_1C06
	sta	[zp_00],y
	lda	joy2_held
	sta	a:wram_1C10
	stz	a:wram_1C06
	lda	a:wram_1C0B
	clc
	adc	#$0004
	sta	a:wram_1C0B
	rts
loc_00AEB2:
	jsr	a:sub_00AEB8
	jmp	a:loc_00AEFC

sub_00AEB8:
	lda	a:wram_1C04
	bne	loc_00AEC0
	jsr	a:sub_00AECD
loc_00AEC0:
	dec	a:wram_1C04
	beq	sub_00AECD
	lda	a:wram_1C0E
	sta	joy1_held
	stz	joy1_pressed
	rts

sub_00AECD:
	ldy	#$0000
	lda	a:wram_1C08
	sta	zp_00
	lda	a:wram_1C09
	sta	zp_01
	lda	[zp_00],y
	sta	joy1_held
	eor	a:wram_1C0E
	and	[zp_00],y
	sta	joy1_pressed
	lda	[zp_00],y
	sta	a:wram_1C0E
	iny
	iny
	lda	[zp_00],y
	sta	a:wram_1C04
	lda	a:wram_1C08
	clc
	adc	#$0004
	sta	a:wram_1C08
	rts
loc_00AEFC:
	lda	a:wram_1C06
	bne	loc_00AF04
	jsr	a:sub_00AF11
loc_00AF04:
	dec	a:wram_1C06
	beq	sub_00AF11
	lda	a:wram_1C10
	sta	joy2_held
	stz	joy2_pressed
	rts

sub_00AF11:
	ldy	#$0000
	lda	a:wram_1C0B
	sta	zp_00
	lda	a:wram_1C0C
	sta	zp_01
	lda	[zp_00],y
	sta	joy2_held
	eor	a:wram_1C10
	and	[zp_00],y
	sta	joy2_pressed
	lda	[zp_00],y
	sta	a:wram_1C10
	iny
	iny
	lda	[zp_00],y
	sta	a:wram_1C06
	lda	a:wram_1C0B
	clc
	adc	#$0004
	sta	a:wram_1C0B
	rts

sub_00AF40:
	lda	stage_number
	asl	a
	tay
	lda	a:data_0584DE,y
	sta	a:wram_1E40
	stz	a:wram_1FA0
	stz	a:wram_1FA2
	stz	a:wram_1FE0
	stz	a:wram_1FE2
	lda	#$0000
	sta	a:wram_1FB6
	sta	a:wram_1FF6
	lda	#$0002
	sta	a:wram_1FB8
	sta	a:wram_1FF8
	lda	#$0003
	sta	a:p1_lives
	lda	#$0001
	sta	a:p1_bombs
	stz	a:p2_bombs
	stz	a:p2_lives
	lda	a:title_menu_cursor
	beq	loc_00AF8B
	lda	#$0003
	sta	a:p2_lives
	lda	#$0001
	sta	a:p2_bombs
loc_00AF8B:
	lda	#$0002
	sta	difficulty
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:wram_1F82
	stz	a:wram_1FC2
	stz	a:wram_1F84
	stz	a:wram_1FC4
	stz	a:wram_1F86
	stz	a:wram_1FC6
	stz	a:wram_1F9E
	stz	a:wram_1FDE
	stz	a:p1_barrier_timer
	stz	a:p2_barrier_timer
	stz	a:wram_1F8E
	stz	a:wram_1FCE
	stz	a:wram_1600
	stz	a:wram_1E42
	lda	#$0020
	sta	zp_94
	lda	#$0010
	sta	zp_96
	lda	#$4000
	sta	zp_88
	lda	#$8000
	sta	zp_8A
	lda	#$8000
	sta	zp_92
	lda	#$0080
	sta	zp_8C
	lda	#$0010
	sta	zp_8E
	rts

sub_00AFE4:
	stz	a:wram_1C04
	stz	a:wram_1C06
	stz	a:wram_1C0E
	stz	a:wram_1C10
	lda	a:wram_1E4A
	beq	loc_00B00F
	; (not executed in the CDL traces)
	lda	#$0000
	sta	a:wram_1C08
	lda	#$0400
	sta	a:wram_1C0B
	sep	#$20
	.a8
	lda	#$70
	sta	a:wram_1C0A
	sta	a:wram_1C0D
	rep	#$20
	.a16
	bra	loc_00B030
loc_00B00F:
	lda	a:demo_index
	asl	a
	clc
	adc	a:demo_index
	tay
	lda	a:data_0584EC,y
	sta	a:wram_1C08
	lda	a:data_0584ED,y
	sta	a:wram_1C09
	lda	a:data_0584F5,y
	sta	a:wram_1C0B
	lda	a:data_0584F6,y
	sta	a:wram_1C0C
loc_00B030:
	rts

sub_00B031:
	lda	stage_number
	cmp	#$0002
	beq	loc_00B055
	cmp	#$0005
	beq	loc_00B055
	lda	a:wram_1E80
	and	#$000F
	sta	a:wram_1E80
	beq	loc_00B04D
	dec	a:wram_1E80
	sec
	rtl
loc_00B04D:
	lda	#$0080
	sta	a:wram_1E80
	clc
	rtl
loc_00B055:
	lda	a:wram_1E80
	and	#$000F
	sta	a:wram_1E80
	beq	loc_00B083
	dec	a:wram_1E80
	lda	a:wram_1FB4
	and	#$000F
	dec	a
	bpl	loc_00B06F
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B06F:
	sta	a:wram_1FB4
	lda	a:wram_1FF4
	and	#$000F
	dec	a
	bpl	loc_00B07E
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B07E:
	sta	a:wram_1FF4
	sec
	rtl
loc_00B083:
	lda	#$0080
	sta	a:wram_1E80
	sta	a:wram_1FB4
	sta	a:wram_1FF4
	clc
	rtl

sub_00B091:
	jsl	f:sub_008DBE
	jsr	a:sub_00B0F7
	jsr	a:sub_00B0AB
	jsr	a:sub_00B153
	lda	#$000F
	sta	a:wram_1C04
	lda	#$000F
	sta	a:wram_1E80
	rtl

sub_00B0AB:
	lda	#$000F
	sta	a:wram_1E84
	lda	#$0000
	sta	a:wram_1E9E
	stz	a:wram_1EA0
	stz	a:wram_1EA2
	sta	a:wram_1EA4
	lda	#$0080
	sta	a:wram_1EA6
	lda	#$0040
	sta	a:wram_1EA8
	lda	#$0000
	sta	a:wram_1380
	lda	#$0000
	sta	a:wram_1398
	stz	a:wram_1EAA
	rts

sub_00B0DC:
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsr	a:sub_00B0F7
	jsr	a:sub_00B125
	jsr	a:sub_00B153
	lda	#$000F
	sta	a:wram_1C04
	stz	a:wram_1E80
	rtl

sub_00B0F7:
	ldy	#$8558
	ldx	#$1210
	jsl	f:sub_009985
	ldy	#$854B
	jsl	f:sub_009982
	ldx	#.loword(data_058527)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058530)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058539)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058542)
	jsl	f:sub_0090A8
	rts

sub_00B125:
	lda	#$000F
	sta	a:wram_1E84
	lda	#$0100
	sta	a:wram_1E9E
	stz	a:wram_1EA0
	stz	a:wram_1EA2
	sta	a:wram_1EA4
	lda	#$0080
	sta	a:wram_1EA6
	sta	a:wram_1EA8
	lda	#$0000
	sta	a:wram_1380
	lda	#$0000
	sta	a:wram_1398
	stz	a:wram_1EAA
	rts

sub_00B153:
	ldx	#$8561
	jsl	f:sub_009024
	ldx	#$8599
	jsl	f:sub_009024
	ldx	#$85A6
	jsl	f:sub_009024
	ldx	#$85B4
	jsl	f:sub_009024
	ldx	#$85C2
	jsl	f:sub_009024
	jsl	f:sub_00B285
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B17B:
	; (not executed in the CDL traces)
	ldy	#$84FE
	jsl	f:sub_00B183
	rts

sub_00B183:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	loc_00B1A2
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	tya
	clc
	adc	#$0007
	tay
	bra	sub_00B183
loc_00B1A2:
	sep	#$20
	.a8
	lda	a:$0002,y
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl

sub_00B1AD:
	rep	#$20
	rep	#$10
	lda	a:wram_1C00
	phx
	asl	a
	tax
	lda	f:tbl_00B1C1,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00B1C1:
	.addr	sub_00B1C9
	.addr	sub_00B1E8
	.addr	sub_00B209
	.addr	sub_00B226

sub_00B1C9:
	lda	#$0300
	sta	a:wram_1C02
	stz	a:wram_1C08
	stz	a:wram_1C0A
	stz	a:wram_1C0C
	stz	a:wram_1C0E
	stz	a:wram_1C10
	stz	a:wram_1C12
	stz	a:wram_1E60
	inc	a:wram_1C00
	rtl

sub_00B1E8:
	php
	lda	a:wram_1E80
	bit	#$0080
	beq	loc_00B1F7
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:wram_1E80
loc_00B1F7:
	cmp	#$000F
	bcs	loc_00B201
	inc	a:wram_1E80
	plp
	rtl
loc_00B201:
	plp
	jsr	a:sub_00B2DD
	inc	a:wram_1C00
	rtl

sub_00B209:
	jsl	f:sub_00B246
	bcs	loc_00B21A
	dec	a:wram_1C02
	bne	loc_00B21F
	lda	#$0001
	sta	zp_36
	rtl
loc_00B21A:
	lda	#$0002
	sta	zp_36
loc_00B21F:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00B220:
	; (not executed in the CDL traces)
	lda	#$0003
	sta	a:wram_1C00

sub_00B226:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:wram_1E80
	and	#$000F
	sta	a:wram_1E80
	beq	loc_00B239
	dec	a:wram_1E80
	plp
	rtl
loc_00B239:
	lda	#$0080
	sta	a:wram_1E80
	plp
	lda	#$0003
	sta	zp_36
	rtl

sub_00B246:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B2C3
	bit	#$2C00
	beq	sub_00B285
	lda	#$0300
	sta	a:wram_1C02
	lda	#$0001
	jsl	f:sub_00868F
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$2400
	bne	loc_00B277
	dec	a:title_menu_cursor
	bpl	sub_00B285
	lda	#$0003
	sta	a:title_menu_cursor
	bra	sub_00B285
loc_00B277:
	inc	a:title_menu_cursor
	lda	a:title_menu_cursor
	cmp	#$0004
	bcc	sub_00B285
	stz	a:title_menu_cursor

sub_00B285:
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851F,y
	ldx	#$8599
	jsl	f:sub_009015
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851D,y
	ldx	#$85A6
	jsl	f:sub_009015
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_05851B,y
	ldx	#$85B4
	jsl	f:sub_009015
	lda	a:title_menu_cursor
	asl	a
	tay
	lda	a:data_058519,y
	ldx	#$85C2
	jsl	f:sub_009015
	clc
	rtl
loc_00B2C3:
	lda	a:title_menu_cursor
	cmp	#$0003
	beq	loc_00B2D4
	lda	#$006D
	jsl	f:sub_00868F
	sec
	rtl
loc_00B2D4:
	lda	#$0002
	jsl	f:sub_00868F
	sec
	rtl

sub_00B2DD:
	jsl	f:sub_0088A3
	jsl	f:sub_008942
	lda	a:demo_index
	asl	a
	tay
	lda	a:ptrs_0585CB,y
	tax
	jsl	f:sub_0090A8
	rts

; sub_00B2F3, sub_00B346, sub_00B39F: never executed in the CDL traces (found
; by the unreferenced-routine heuristic).  Each compares the d-pad bits of the
; joypads ($20/$22 & $0F00) with a 3-entry sequence and then checks a button:
; probably button-code checks.  DB is assumed to be $05, the game's usual data
; bank (hint): the sequences are then d-pad masks at $05:86D3/86D9/86DF.
; (no caller found; decoded because it follows the end of a routine)
sub_00B2F3:
	; (not executed in the CDL traces)
	lda	a:wram_1C0A
	bne	loc_00B300
	ldy	#$0000
	sty	a:wram_1C08
	bra	loc_00B30B
loc_00B300:
	dec	a:wram_1C0A
	ldy	a:wram_1C08
	cpy	#$0006
	bcs	loc_00B332
loc_00B30B:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586D3,y
	bne	loc_00B33B
	cpy	#$0000
	bne	loc_00B322
	lda	#$0010
	sta	a:wram_1C0A
loc_00B322:
	iny
	iny
	sty	a:wram_1C08
	cpy	#$0006
	bcc	loc_00B33B
	lda	#$000C
	sta	a:wram_1C0A
loc_00B332:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0040
	bne	loc_00B33D
loc_00B33B:
	clc
	rts
loc_00B33D:
	lda	#$003E
	jsl	f:sub_00868F
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B346:
	; (not executed in the CDL traces)
	lda	a:wram_1C0E
	bne	loc_00B353
	ldy	#$0000
	sty	a:wram_1C0C
	bra	loc_00B35E
loc_00B353:
	dec	a:wram_1C0E
	ldy	a:wram_1C0C
	cpy	#$0006
	bcs	loc_00B385
loc_00B35E:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586D9,y
	bne	loc_00B38E
	cpy	#$0000
	bne	loc_00B375
	lda	#$0010
	sta	a:wram_1C0E
loc_00B375:
	iny
	iny
	sty	a:wram_1C0C
	cpy	#$0006
	bcc	loc_00B38E
	lda	#$000C
	sta	a:wram_1C0E
loc_00B385:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B390
loc_00B38E:
	clc
	rts
loc_00B390:
	lda	#$0043
	jsl	f:sub_00868F
	lda	#$001E
	sta	a:wram_1E3C
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B39F:
	; (not executed in the CDL traces)
	lda	a:wram_1C12
	bne	loc_00B3AC
	ldy	#$0000
	sty	a:wram_1C10
	bra	loc_00B3B7
loc_00B3AC:
	dec	a:wram_1C12
	ldy	a:wram_1C10
	cpy	#$0006
	bcs	loc_00B3DE
loc_00B3B7:
	lda	joy1_held
	ora	joy2_held
	and	#$0F00
	cmp	a:data_0586DF,y
	bne	loc_00B3E7
	cpy	#$0000
	bne	loc_00B3CE
	lda	#$0010
	sta	a:wram_1C12
loc_00B3CE:
	iny
	iny
	sty	a:wram_1C10
	cpy	#$0006
	bcc	loc_00B3E7
	lda	#$000C
	sta	a:wram_1C12
loc_00B3DE:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00B3E9
loc_00B3E7:
	clc
	rts
loc_00B3E9:
	lda	a:title_menu_cursor
	cmp	#$0003
	beq	loc_00B3E7
	lda	#$0059
	jsl	f:sub_00868F
	lda	#$0001
	sta	a:wram_1E60
	sec
	rts

sub_00B400:
	ldx	#$0FC0
	lda	#$11C0
	sta	zp_12
	lda	#$8000
	sta	zp_14
	lda	a:wram_1E56
	sta	zp_FC
	lda	#$0044
	sta	zp_FE
	lda	#$8705
	sta	zp_18
	lda	#$86E5
	sta	zp_1A
	lda	#$86F5
	sta	zp_1C
	ldy	#$000E
	jsr	a:sub_00B499
	lda	a:wram_1E58
	sta	zp_FC
	lda	#$004C
	sta	zp_FE
	lda	#$8745
	sta	zp_18
	lda	#$8715
	sta	zp_1A
	lda	#$872D
	sta	zp_1C
	ldy	#$0016
	jsr	a:sub_00B499
	lda	a:wram_1E5A
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#$877D
	sta	zp_18
	lda	#$875D
	sta	zp_1A
	lda	#$876D
	sta	zp_1C
	ldy	#$000E
	jsr	a:sub_00B499
	lda	a:wram_1E5C
	sta	zp_FC
	lda	#$006C
	sta	zp_FE
	lda	#$8791
	sta	zp_18
	lda	#$878D
	sta	zp_1A
	lda	#$878F
	sta	zp_1C
	ldy	#$0000
	jsr	a:sub_00B499
loc_00B489:
	sec
	ror	zp_14
	sec
	ror	zp_14
	bcc	loc_00B489
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	rtl

sub_00B499:
	lda	zp_FE
	sec
	sbc	a:wram_1398
	clc
	adc	(zp_1C),y
	sta	a:$0001,x
	lda	zp_FC
	clc
	adc	(zp_1A),y
	pha
	cmp	#$0100
	ror	zp_14
	sec
	ror	zp_14
	bcc	loc_00B4C7
	phy
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	sty	zp_12
	lda	#$8000
	sta	zp_14
	ply
loc_00B4C7:
	pla
	sep	#$20
	.a8
	sta	a:$0000,x
	rep	#$20
	.a16
	lda	(zp_18),y
	sta	a:$0002,x
	inx
	inx
	inx
	inx
	dey
	dey
	bpl	sub_00B499
	rts

sub_00B4DD:
	rep	#$20
	rep	#$10
	lda	a:wram_1C60
	phx
	asl	a
	tax
	lda	f:tbl_00B4F1,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00B4F1:
	.addr	sub_00B507
	.addr	sub_00B551
	.addr	sub_00B586
	.addr	sub_00B59C
	.addr	sub_00B64A
	.addr	sub_00B5B5
	.addr	sub_00B5D3
	.addr	sub_00B64A
	.addr	sub_00B628
	.addr	sub_00B64A
	.addr	sub_00B653

sub_00B507:
	jsl	f:sub_0085DF
	jsl	f:sub_0085A9
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	lda	#$0009
	sta	a:wram_1E84
	lda	#$0001
	ldx	#.loword(data_0587AB)
	jsl	f:sub_0090A8
	ldy	#$87C3
	jsl	f:sub_009982
	lda	#$0400
	sta	a:wram_1398
	lda	#$0100
	sta	a:wram_1380
	sta	a:wram_13C0
	lda	#$0019
	sta	a:wram_1E84
	lda	#$0003
	sta	a:wram_1C66
	inc	a:wram_1C60
	rtl

sub_00B551:
	lda	frame_counter
	and	#$0001
	bne	loc_00B573
	lda	a:wram_1C64
	asl	a
	tay
	ldx	a:data_058793,y
	lda	#$2C00
	jsl	f:sub_009015
	inc	a:wram_1C64
	lda	a:wram_1C64
	and	#$0003
	sta	a:wram_1C64
loc_00B573:
	lda	a:wram_1380
	sec
	sbc	#$0008
	sta	a:wram_1380
	bne	loc_00B585
	stz	a:wram_13C0
	inc	a:wram_1C60
loc_00B585:
	rtl

sub_00B586:
	lda	frame_counter
	and	#$0003
	bne	loc_00B59B
	ldx	#$2264
	jsr	a:sub_00B65C
	dec	a:wram_1C66
	bne	loc_00B59B
	inc	a:wram_1C60
loc_00B59B:
	rtl

sub_00B59C:
	lda	a:wram_1398
	sec
	sbc	#$0002
	sta	a:wram_1398
	and	#$0100
	bne	loc_00B5D2
loc_00B5AB:
	lda	#$0001
	sta	a:wram_1C6A
	inc	a:wram_1C60
	rtl

sub_00B5B5:
	lda	#$000A
	sta	a:wram_1C64
	sta	a:wram_1C66
	sta	a:wram_1C68
	ldy	#$87E1
	jsl	f:sub_009982
	lda	#$0072
	jsl	f:sub_00868F
	inc	a:wram_1C60
loc_00B5D2:
	rtl

sub_00B5D3:
	lda	a:wram_1C64
	beq	loc_00B5ED
	cmp	#$000A
	bne	loc_00B5E4
	ldy	#$87EA
	jsl	f:sub_009982
loc_00B5E4:
	dec	a:wram_1C64
	ldx	#$222C
	jsr	a:sub_00B65C
loc_00B5ED:
	lda	a:wram_1C66
	bmi	loc_00B602
	ldx	#$224C
	jsr	a:sub_00B65C
	dec	a:wram_1C66
	lda	#$0003
	sta	a:wram_1C6A
	rtl
loc_00B602:
	lda	a:wram_1C6A
	beq	loc_00B612
	dec	a:wram_1C6A
	bne	loc_00B627
	ldy	#$87D8
	jmp	a:sub_009982
loc_00B612:
	lda	a:wram_1C68
	bmi	loc_00B5AB
	lda	frame_counter
	and	#$0001
	bne	loc_00B627
	dec	a:wram_1C68
	ldx	#$220A
	jsr	a:sub_00B65C
loc_00B627:
	rtl

sub_00B628:
	ldx	#$2200
	lda	f:$7E0000,x
	clc
	adc	#$0421
	sta	f:$7E0000,x
	sta	f:$7E0002,x
	cmp	#$7FFF
	bne	loc_00B649
	lda	#$0100
	sta	a:wram_1C6A
	inc	a:wram_1C60
loc_00B649:
	rtl

sub_00B64A:
	dec	a:wram_1C6A
	bne	loc_00B652
	inc	a:wram_1C60
loc_00B652:
	rtl

sub_00B653:
	dec	a:wram_1E80
	bne	loc_00B65B
	inc	a:wram_1C62
loc_00B65B:
	rtl

sub_00B65C:
	lda	f:$7E0000,x
	pha
	inx
	inx
loc_00B663:
	lda	f:$7E0000,x
	sta	f:$7DFFFE,x
	inx
	inx
	txa
	and	#$001F
	bne	loc_00B663
	pla
	sta	f:$7DFFFE,x
	rts
