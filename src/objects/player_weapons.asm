; objects/player_weapons.asm -- Player weapons
; Bank $01, $01:8000-$01:9E43. Included by main.asm in segment BANK01.
;
; Code reached from the player update (sub_01A624) and from object types of
; tbl_05A48A: weapon firing (the routines that call the shot spawners in
; objects/player_shots.asm, e.g. sub_0183DA, sub_018930..sub_018E4B) and the
; players' shot objects.

sub_018000:
	.a16
	.i16
	stz	a:$1D8E,x
	lda	$12,x
	cmp	#$000C
	beq	loc_018017
	lda	$22,x
	and	#$0030
	beq	loc_018016
	cmp	#$0030
	beq	loc_018017
loc_018016:
	rtl
loc_018017:
	inc	a:$1D8E,x
	rtl

sub_01801B:
	lda	$2C,x
	bit	zp_8C
	beq	loc_01804D
	lda	a:$1310,x
	bne	loc_01804D
	lda	a:$1D8C,x
	beq	loc_01804D
	inc	a:$1310,x
	dec	a:$1D8C,x
	stz	a:$1318,x
	lda	#$0001
	sta	a:$131A,x
	lda	a:$1312,x
	sta	a:$131C,x
	lda	a:$1314,x
	sta	a:$131E,x
	lda	#$005A
	jsl	f:queue_sound
loc_01804D:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01804E:
	; (not executed in the CDL traces)
	lda	$22,x
	bit	#$4000
	beq	loc_018062
	ldy	#$0012
	lda	zp_BC
	beq	loc_01805F
	ldy	#$0000
loc_01805F:
	sty	a:mosaic_shadow
loc_018062:
	rtl

sub_018063:
	lda	$20,x
	clc
	adc	a:$1300,x
	clc
	adc	$38,x
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	lda	a:data_05B29E,y
	sta	a:wram_1780
	clc
	adc	#$0200
	sta	a:wram_178C
	lda	a:data_05B2A0,y
	sta	a:wram_1782
	clc
	adc	#$0200
	sta	a:wram_178E
	lda	a:data_05B2A2,y
	sta	a:wram_1784
	clc
	adc	#$0200
	sta	a:wram_1790
	lda	a:data_05B2A4,y
	sta	a:wram_1786
	clc
	adc	#$0200
	sta	a:wram_1792
	lda	a:data_05B2A6,y
	sta	a:wram_1788
	clc
	adc	#$0200
	sta	a:wram_1794
	lda	a:data_05B2A8,y
	sta	a:wram_178A
	clc
	adc	#$0200
	sta	a:wram_1796
	stz	$38,x
	lda	$04,x
	bne	loc_0180CB
	lda	a:data_05B2AA,y
	sta	$00,x
	rtl
loc_0180CB:
	lda	a:data_05B2AC,y
	sta	$00,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_0180D1:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:cgwsel_shadow
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_0180D8:
	; (not executed in the CDL traces)
	lda	hdma_preset
	cmp	#$0004
	beq	sub_0180D1
	lda	#$0000
	sta	a:cgwsel_shadow
	ldy	#$0052
	lda	joy2_held
	bit	#$2000
	beq	loc_0180F6
	lda	joy2_held
	bit	#$0040
	bne	loc_0180F9
loc_0180F6:
	ldy	#$0000
loc_0180F9:
	sty	a:cgadsub_shadow
	bit	#$4000
	beq	loc_01810A
	lda	a:cgadsub_shadow
	and	#$0012
	sta	a:cgadsub_shadow
loc_01810A:
	lda	a:wram_1612
	sta	a:coldata_shadow
	lda	joy2_pressed
	bit	#$0080
	beq	loc_01811B
	inc	a:wram_1612
	rtl
loc_01811B:
	bit	#$8000
	beq	loc_018123
	dec	a:wram_1612
loc_018123:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_018124:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#$2000
	beq	loc_018134
	lda	a:wram_162C
	eor	#$0001
	sta	a:wram_162C
loc_018134:
	lda	a:wram_162C
	bne	loc_01813C
	brl	loc_0181E1
loc_01813C:
	lda	joy1_pressed
	bit	#$8000
	beq	loc_018156
	lda	a:tmw_shadow
	pha
	inc	a
	and	#$001F
	sta	zp_00
	pla
	and	#$FF00
	ora	zp_00
	sta	a:tmw_shadow
loc_018156:
	lda	joy1_pressed
	bit	#$4000
	beq	loc_018174
	lda	a:tmw_shadow
	pha
	and	#$00FF
	sta	a:tmw_shadow
	pla
	xba
	inc	a
	and	#$001F
	xba
	ora	a:tmw_shadow
	sta	a:tmw_shadow
loc_018174:
	lda	joy1_pressed
	bit	#$0020
	beq	loc_018194
	lda	a:w12sel_shadow
	pha
	inc	a
	and	#$0003
	sta	a:w12sel_shadow
	pla
	clc
	adc	#$0010
	and	#$0030
	ora	a:w12sel_shadow
	sta	a:w12sel_shadow
loc_018194:
	lda	joy1_pressed
	bit	#$0010
	beq	loc_0181A8
	lda	a:wobjsel_shadow
	clc
	adc	#$0010
	and	#$0030
	sta	a:wobjsel_shadow
loc_0181A8:
	lda	#$00FF
	sta	f:wram_7EF800
	lda	#$F807
	sta	f:wram_7EF801
	lda	#$00FF
	sta	f:wram_7EF803
	lda	#$F887
	sta	f:wram_7EF804
	lda	#$00FF
	sta	f:wram_7EFA00
	lda	#$FA07
	sta	f:wram_7EFA01
	lda	#$00FF
	sta	f:wram_7EFA03
	lda	#$FA87
	sta	f:wram_7EFA04
	rtl
loc_0181E1:
	stz	a:tmw_shadow
	stz	a:wram_1EBC
	rtl

sub_0181E8:
	phx
	ldx	#$0200
loc_0181EC:
	clc
	lda	zp_BE
	adc	#$FFFC
	sta	$24,x
	lda	$16,x
	ora	#$0002
	sta	$16,x
	cpx	#$0240
	beq	loc_018205
	ldx	#$0240
	bra	loc_0181EC
loc_018205:
	plx
	rtl

sub_018207:
	ldy	$30,x
	lda	a:data_05AB6C,y
	tay
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_01821B
	lda	#$8000
	sta	$16,x
	rtl
loc_01821B:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01822A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01822A:
	.addr	sub_018230
	.addr	sub_018243
	.addr	sub_018273

sub_018230:
	ldy	$30,x
	stz	$16,x
	stz	$24,x
	lda	#$00B4
	sta	$0E,x
	lda	a:data_05AB70,y
	sta	$02,x
	inc	$12,x
	rtl

sub_018243:
	lda	$24,x
	bmi	loc_01824B
	dec	$24,x
	bra	loc_01824D
loc_01824B:
	stz	$00,x
loc_01824D:
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$000E,y
	sta	$0E,x
	lda	a:$0012,y
	cmp	#$0011
	beq	loc_018272
	cmp	#$0012
	beq	loc_018272
	lda	a:$0016,y
	beq	loc_018272
	bmi	loc_018272
	inc	$12,x
	lda	#$CB8B
	sta	$00,x
loc_018272:
	rtl

sub_018273:
	lda	$0E,x
	cmp	#$00B1
	bcc	loc_01827C
	dec	$0E,x
loc_01827C:
	lda	a:$0016,y
	beq	loc_0182B2
	bmi	loc_0182B2
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$0032,y
	bne	loc_0182B4
	lda	a:$000E,y
	cmp	#$00A4
	bcc	loc_0182B4
	lda	#$0002
	sta	$24,x
	lda	#$0011
	sta	a:$0012,y
	lda	#$00B4
	sta	a:$000E,y
	lda	#$7400
	sta	a:$001C,y
	lda	#$0000
	sta	a:$001E,y
loc_0182B2:
	dec	$12,x
loc_0182B4:
	rtl
loc_0182B5:
	dec	$0A,x
	lda	#$0000
	bra	loc_0182D0

sub_0182BC:
	inc	$0A,x
	lda	#$0000
	bra	loc_0182D0

sub_0182C3:
	lda	#$040A
	bra	loc_0182D0
loc_0182C8:
	lda	#$020A
	bra	loc_0182D0
loc_0182CD:
	lda	#$010A
loc_0182D0:
	sta	$32,x
	stz	$1C,x
	stz	$1E,x
	lda	#$0004
	sta	$12,x
	lda	#$00D3
	sta	$20,x
	stz	$38,x
	bra	sub_018317
loc_0182E4:
	lda	#$DFFF
	sta	$1C,x
	lda	#$FFFB
	sta	$1E,x
	lda	#$0003
	sta	$12,x
	stz	$32,x
	bra	sub_018354
loc_0182F7:
	dec	$0A,x
	bra	loc_0182FD
loc_0182FB:
	inc	$0A,x
loc_0182FD:
	lda	#$0068
	sta	$20,x
	stz	$38,x
	stz	$1C,x
	lda	#$FFFA
	sta	$1E,x
	lda	#$0003
	sta	$12,x
	lda	#$070A
	sta	$32,x
	bra	sub_018354

sub_018317:
	lda	$3C,x
	bit	#$0004
	beq	loc_018322
	jml	f:loc_019A76
loc_018322:
	jsr	a:sub_018F6C
	jsl	f:sub_01801B
	stz	zp_C4
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_01833A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01833A:
	.addr	sub_018395
	.addr	sub_018399
	.addr	sub_01844D
	.addr	sub_01847F
	.addr	sub_0183AF
	.addr	sub_018395
	.addr	sub_0184A8
	.addr	sub_018395
	.addr	sub_0184D1
	.addr	sub_018503
	.addr	sub_018395
	.addr	sub_018395
	.addr	sub_01852C

sub_018354:
	lda	$3C,x
	bit	#$0004
	beq	loc_01835F
	jml	f:loc_019A76
loc_01835F:
	jsr	a:sub_018839
	jsl	f:sub_01801B
	stz	zp_C4
	jsl	f:sub_018555
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_01837B,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01837B:
	.addr	sub_0183C5
	.addr	sub_0183C9
	.addr	sub_01846D
	.addr	sub_018496
	.addr	sub_0183DA
	.addr	sub_0183C5
	.addr	sub_0184BF
	.addr	sub_0183C5
	.addr	sub_0184F1
	.addr	sub_01851A
	.addr	sub_0183C5
	.addr	sub_0183C5
	.addr	sub_018543

sub_018395:
	lda	$04,x
	bne	sub_0183AF

sub_018399:
	lda	#$0020
	sta	zp_12
	lda	#$0010
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	lda	#$00D3
	sta	$20,x
	bra	loc_0183E9

sub_0183AF:
	lda	#$0060
	sta	zp_12
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	lda	#$00D3
	sta	$20,x
	bra	loc_0183E9

sub_0183C5:
	lda	$04,x
	bne	sub_0183DA

sub_0183C9:
	lda	#$0020
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
	bra	loc_0183E9

sub_0183DA:
	lda	#$0060
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
loc_0183E9:
	lda	$12,x
	cmp	#$000C
	bne	loc_01841E
	lda	#$FFF2
	ldy	$04,x
	bne	loc_0183FA
	lda	#$FFF6
loc_0183FA:
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
	jsl	f:sub_00D692
	stz	$38,x
	lda	#$0002
	ldy	$04,x
	bne	loc_018411
	lda	#$0006
loc_018411:
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
	jsl	f:sub_00D656
	bra	loc_018429
loc_01841E:
	jsl	f:sub_00D6DC
	lda	$12,x
	cmp	#$0003
	bne	loc_01842B
loc_018429:
	stz	$38,x
loc_01842B:
	lda	$1E,x
	bmi	loc_018434
	cmp	#$0006
	bcs	loc_018443
loc_018434:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_018443:
	lda	$1E,x
	bmi	loc_01844A
	brl	loc_01871A
loc_01844A:
	brl	loc_018682

sub_01844D:
	lda	#$00D7
	sta	$20,x
	lda	#$0000
	sta	zp_12
	lda	$04,x
	bne	loc_018460
	lda	#$FFFE
	bra	loc_018463
loc_018460:
	lda	#$FFF9
loc_018463:
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	brl	loc_0183E9

sub_01846D:
	lda	#$0000
	sta	zp_12
	lda	#$FFFC
	sta	zp_14
	lda	#$FFD0
	sta	zp_16
	brl	loc_0183E9

sub_01847F:
	lda	#$00D5
	sta	$20,x
	lda	#$0010
	sta	zp_12
	lda	#$000C
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	brl	loc_0183E9

sub_018496:
	lda	#$0010
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFD4
	sta	zp_16
	brl	loc_0183E9

sub_0184A8:
	lda	#$00D5
	sta	$20,x
	lda	#$0070
	sta	zp_12
	lda	#$FFE8
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	brl	loc_0183E9

sub_0184BF:
	lda	#$0070
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFD0
	sta	zp_16
	brl	loc_0183E9

sub_0184D1:
	lda	#$00DB
	sta	$20,x
	lda	#$0040
	sta	zp_12
	lda	$04,x
	bne	loc_0184E4
	lda	#$FFF9
	bra	loc_0184E4
loc_0184E4:
	lda	#$FFFD
	sta	zp_14
	lda	#$FFFC
	sta	zp_16
	brl	loc_0183E9

sub_0184F1:
	lda	#$0040
	sta	zp_12
	lda	#$FFF9
	sta	zp_14
	lda	#$FFE0
	sta	zp_16
	brl	loc_0183E9

sub_018503:
	lda	#$00D9
	sta	$20,x
	lda	#$0030
	sta	zp_12
	lda	#$000A
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	brl	loc_0183E9

sub_01851A:
	lda	#$0030
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFE0
	sta	zp_16
	brl	loc_0183E9

sub_01852C:
	lda	#$00D9
	sta	$20,x
	lda	#$0050
	sta	zp_12
	lda	#$FFEC
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	brl	loc_0183E9

sub_018543:
	; (not executed in the CDL traces)
	lda	#$0050
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFE0
	sta	zp_16
	brl	loc_0183E9

sub_018555:
	lda	$20,x
	cmp	#$003A
	bcs	loc_018562
loc_01855C:
	lda	#$003A
	sta	$20,x
	rtl
loc_018562:
	lda	$1E,x
	bpl	loc_01856C
	lda	zp_BC
	bne	loc_018579
	beq	loc_018570
loc_01856C:
	lda	zp_BE
	bne	loc_018579
loc_018570:
	inc	$20,x
	lda	$20,x
	cmp	#$003E
	bcs	loc_01855C
loc_018579:
	rtl

sub_01857A:
	lda	zp_06
	bit	#$807E
	beq	loc_01859F
	bit	#$0078
	beq	loc_0185D0
	bit	#$0001
	bne	loc_018592
	bit	#$0050
	beq	loc_0185F5
	bne	loc_018608
loc_018592:
	bit	#$0050
	bne	loc_01859A
	brl	loc_01861B
loc_01859A:
	beq	loc_01859F
	brl	loc_01862E
loc_01859F:
	lda	zp_04
	bit	#$807E
	bne	loc_0185A9
	brl	loc_01865F
loc_0185A9:
	bit	#$0078
	bne	loc_0185B1
	brl	loc_018649
loc_0185B1:
	bit	#$0001
	beq	loc_0185C3
	bit	#$0050
	bne	loc_0185BE
	brl	loc_01864F
loc_0185BE:
	; (not executed in the CDL traces)
	beq	loc_0185C3
	brl	loc_018672
loc_0185C3:
	bit	#$0050
	bne	loc_0185CB
	brl	loc_018662
loc_0185CB:
	beq	loc_0185D0
	brl	loc_01866A
loc_0185D0:
	lda	zp_04
	bit	#$807E
	bne	loc_0185DA
	brl	loc_018649
loc_0185DA:
	bit	#$0078
	bne	loc_0185E2
	brl	loc_018641
loc_0185E2:
	bit	#$0001
	beq	loc_0185EE
	bit	#$0050
	beq	loc_018649
	bne	loc_018649
loc_0185EE:
	bit	#$0050
	beq	loc_018649
	bne	loc_01866A
loc_0185F5:
	lda	zp_04
	bit	#$807E
	beq	loc_018657
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018662
	; (not executed in the CDL traces)
	bne	loc_01866A
loc_018608:
	lda	zp_04
	bit	#$807E
	beq	loc_018662
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018662
	bne	loc_01866A
loc_01861B:
	lda	zp_04
	bit	#$807E
	beq	loc_018672
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018672
	bne	loc_018672
loc_01862E:
	lda	zp_04
	bit	#$807E
	beq	loc_01867A
	bit	#$0078
	beq	loc_01867A
	; (not executed in the CDL traces)
	bit	#$0050
	beq	loc_01867A
	bne	loc_01867A
loc_018641:
	lda	#$0002
	sta	zp_C4
	brl	sub_0193DB
loc_018649:
	lda	#$8002
	sta	zp_C4
	rtl
loc_01864F:
	lda	#$0010
	sta	zp_C4
	brl	loc_01961D
loc_018657:
	lda	#$0008
	sta	zp_C4
	brl	loc_019502
loc_01865F:
	stz	zp_C4
	rtl
loc_018662:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_01866A:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_018672:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565
loc_01867A:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_018682:
	jsl	f:sub_01AF6F
	lda	#$0006
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0186AC
	bmi	loc_0186F5
	lda	#$0002
	sta	$12,x
	jsl	f:sub_019414
	lda	zp_C4
	bpl	loc_0186AB
	brl	sub_0193F4
loc_0186AB:
	rtl
loc_0186AC:
	stz	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0186C9
	; (not executed in the CDL traces)
	bmi	loc_0186D7
	lda	#$0005
	sta	$12,x
	jsl	f:sub_019433
	lda	zp_C4
	bpl	loc_0186AB
	brl	sub_0193F4
loc_0186C9:
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0186E7
loc_0186D7:
	; (not executed in the CDL traces)
	jsl	f:sub_01942F
	lda	zp_C4
	beq	loc_0186E6
	bmi	loc_0186E6
	lda	#$000D
	sta	$12,x
loc_0186E6:
	rtl
loc_0186E7:
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_018705
loc_0186F5:
	jsl	f:sub_019410
	lda	zp_C4
	beq	loc_018704
	; (not executed in the CDL traces)
	bmi	loc_018704
	lda	#$000D
	sta	$12,x
loc_018704:
	rtl
loc_018705:
	lda	zp_C4
	beq	loc_018715
	lda	#$000D
	sta	$12,x
	lda	zp_C4
	bpl	loc_018715
	brl	sub_0193F4
loc_018715:
	rtl
loc_018716:
	; (not executed in the CDL traces)
	jml	f:loc_019A76
loc_01871A:
	lda	$3C,x
	bit	#$0004
	bne	loc_018716
	bit	#$0080
	beq	loc_018731
	lda	#$0000
	sta	$12,x
	lda	#$0014
	sta	$20,x
	rtl
loc_018731:
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	bit	#$2000
	bne	loc_018749
	lda	$32,x
	bit	#$0100
	beq	loc_018749
	stz	zp_04
loc_018749:
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	bit	#$2000
	bne	loc_018762
	lda	$32,x
	bit	#$0100
	beq	loc_018762
	stz	zp_06
loc_018762:
	jsl	f:sub_01857A
	lda	#$0006
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_01878C
	bmi	loc_0187D6
	lda	#$0002
	sta	$12,x
	jsl	f:sub_019414
	lda	zp_C4
	bpl	loc_01878B
	brl	sub_0193DB
loc_01878B:
	rtl
loc_01878C:
	stz	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0187AA
	bmi	loc_0187B8
	lda	#$0005
	sta	$12,x
	jsl	f:sub_019433
	lda	zp_C4
	bpl	loc_0187A9
	brl	sub_0193DB
loc_0187A9:
	rtl
loc_0187AA:
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0187C8
loc_0187B8:
	jsl	f:sub_01942F
	lda	zp_C4
	beq	loc_0187F7
	bmi	loc_0187F7
	; (not executed in the CDL traces)
	lda	#$0000
	sta	$12,x
	rtl
loc_0187C8:
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_0187E6
loc_0187D6:
	jsl	f:sub_019410
	lda	zp_C4
	beq	loc_0187F7
	bmi	loc_0187F7
	lda	#$0000
	sta	$12,x
	rtl
loc_0187E6:
	lda	zp_C4
	beq	loc_0187F7
	lda	#$0000
	sta	$12,x
	lda	zp_C4
	bpl	loc_0187F6
	brl	sub_0193DB
loc_0187F6:
	rtl
loc_0187F7:
	stz	zp_00
	lda	#$FFD0
	sta	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	bit	#$0E00
	beq	loc_018812
	lda	$32,x
	bit	#$0200
	beq	loc_018812
	stz	zp_04
loc_018812:
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	bit	#$0E00
	beq	loc_01882B
	lda	$32,x
	bit	#$0200
	beq	loc_01882B
	stz	zp_06
loc_01882B:
	jsl	f:sub_01902B
	lda	zp_C4
	beq	loc_018838
	lda	#$0001
	sta	$12,x
loc_018838:
	rtl

sub_018839:
	ldy	$04,x
	lda	$0A,x
	sta	$06,x
	adc	#$0006
	sta	$28,x
	adc	a:data_05AB74,y
	sta	a:$1312,x
	lda	$0E,x
	adc	#$FFF2
	sta	$10,x
	adc	#$FFE4
	sta	$2A,x
	adc	#$0006
	sta	a:$1314,x
	rts
loc_01885D:
	rtl

sub_01885E:
	jsl	f:sub_01801B
	jsr	a:sub_018F6C
	lda	$3C,x
	bit	#$0004
	beq	loc_018870
	jml	f:loc_019A76
loc_018870:
	ldy	a:$1304,x
	beq	loc_0188A4
	bit	#$0080
	beq	loc_0188A4
	clc
	lda	$08,x
	adc	a:$0018,y
	sta	$08,x
	lda	$0A,x
	adc	a:$001A,y
	sta	$0A,x
	clc
	lda	$0C,x
	adc	a:$001C,y
	sta	$0C,x
	lda	$0E,x
	adc	a:$001E,y
	sta	$0E,x
	lda	#$8002
	sta	zp_C4
	lda	#$2000
	sta	zp_12
	bra	loc_0188C2
loc_0188A4:
	jsl	f:sub_018EF5
	lda	$12,x
	bne	loc_01885D
	lda	zp_C4
	bne	loc_0188B3
	brl	loc_0182CD
loc_0188B3:
	bit	#$0078
	beq	loc_0188C2
	clc
	lda	a:$1314,x
	adc	#$FFFC
	sta	a:$1314,x
loc_0188C2:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0188F3
	lda	$26,x
	cmp	#$0008
	beq	loc_0188D2
	brl	loc_0182FD
loc_0188D2:
	lda	zp_12
	bit	#$2000
	beq	loc_0188DC
	brl	loc_0182FD
loc_0188DC:
	lda	stage_number
	cmp	#$0006
	beq	loc_0188E6
	brl	loc_0182CD
loc_0188E6:
	lda	$0E,x
	cmp	#$0074
	bcc	loc_0188F0
	brl	loc_0182FD
loc_0188F0:
	brl	loc_0182CD
loc_0188F3:
	lda	a:$1D8E,x
	beq	loc_0188FB
	brl	loc_01AC62
loc_0188FB:
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_01890A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01890A:
	.addr	sub_018924
	.addr	sub_018930
	.addr	sub_0189D9
	.addr	sub_018A63
	.addr	sub_018B0D
	.addr	sub_018924
	.addr	sub_018BB7
	.addr	sub_018924
	.addr	sub_018C61
	.addr	sub_018DA1
	.addr	sub_018924
	.addr	sub_018924
	.addr	sub_018E4B

sub_018924:
	lda	#$0001
	sta	$2E,x
	lda	$04,x
	beq	sub_018930
	brl	sub_018B0D

sub_018930:
	lda	#$0020
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018971
	lda	$2E,x
	beq	loc_018959
	stz	$20,x
	lda	zp_C4
	bpl	loc_01894B
loc_018946:
	lda	#$0014
	sta	$20,x
loc_01894B:
	lda	#$0010
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:sub_00D6DC
loc_018959:
	lda	#$0002
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$0010
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:loc_00D6CE
loc_018971:
	ldy	$2E,x
	beq	loc_0189A4
	lda	zp_C4
	bmi	loc_018946
	bit	#$0028
	bne	loc_018991
	lda	#$00BA
	sta	$20,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC
loc_018991:
	lda	#$00B0
	sta	$20,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC
loc_0189A4:
	bit	#$0028
	bne	loc_0189C1
	lda	#$0074
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$0010
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:sub_00D6DC
loc_0189C1:
	lda	#$0068
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$0010
	sta	zp_14
	lda	#$FFDB
	sta	zp_16
	jml	f:sub_00D6DC

sub_0189D9:
	lda	#$0000
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018A06
	ldy	#$001A
	lda	zp_C4
	bpl	loc_0189EF
loc_0189EC:
	ldy	#$00DD
loc_0189EF:
	sty	$20,x
	ldy	#$FFF9
	lda	$04,x
	bne	loc_0189FB
	ldy	#$FFFE
loc_0189FB:
	sty	zp_14
	lda	#$FFC0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018A06:
	lda	zp_C4
	bmi	loc_0189EC
	bit	#$0028
	bne	loc_018A39
	lda	$04,x
	bne	loc_018A26
	lda	#$FFFF
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	lda	#$00BC
	sta	$20,x
	jml	f:sub_00D6DC
loc_018A26:
	lda	#$FFF8
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	lda	#$00B2
	sta	$20,x
	jml	f:sub_00D6DC
loc_018A39:
	lda	$04,x
	bne	loc_018A50
	lda	#$FFFF
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	lda	#$00B2
	sta	$20,x
	jml	f:sub_00D6DC
loc_018A50:
	lda	#$FFF8
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	lda	#$00BC
	sta	$20,x
	jml	f:sub_00D6DC

sub_018A63:
	lda	#$0010
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018AA5
	lda	$2E,x
	beq	loc_018A8D
	ldy	#$001C
	lda	zp_C4
	bpl	loc_018A7D
loc_018A7A:
	ldy	#$0024
loc_018A7D:
	sty	$20,x
	lda	#$000C
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	jml	f:sub_00D6DC
loc_018A8D:
	lda	#$001E
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$000C
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	jml	f:sub_00D6DC
loc_018AA5:
	ldy	$2E,x
	beq	loc_018AD8
	lda	zp_C4
	bmi	loc_018A7A
	bit	#$0028
	bne	loc_018AC5
	lda	#$00BE
	sta	$20,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7
	sta	zp_16
	jml	f:sub_00D6DC
loc_018AC5:
	lda	#$00B4
	sta	$20,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7
	sta	zp_16
	jml	f:sub_00D6DC
loc_018AD8:
	bit	#$0028
	bne	loc_018AF5
	lda	#$008C
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$0011
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	jml	f:sub_00D6DC
loc_018AF5:
	lda	#$0080
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$000C
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	jml	f:sub_00D6DC

sub_018B0D:
	lda	#$0060
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018B4F
	lda	$2E,x
	beq	loc_018B37
	ldy	#$0000
	lda	zp_C4
	bpl	loc_018B27
loc_018B24:
	ldy	#$0014
loc_018B27:
	sty	$20,x
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:sub_00D6DC
loc_018B37:
	lda	#$0002
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:loc_00D6CE
loc_018B4F:
	ldy	$2E,x
	beq	loc_018B82
	lda	zp_C4
	bmi	loc_018B24
	bit	#$0050
	bne	loc_018B6F
	lda	#$00BA
	sta	$20,x
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC
loc_018B6F:
	lda	#$00B0
	sta	$20,x
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:sub_00D6DC
loc_018B82:
	bit	#$0050
	bne	loc_018B9F
	lda	#$0074
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDD
	sta	zp_16
	jml	f:sub_00D6DC
loc_018B9F:
	lda	#$0068
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE6
	sta	zp_14
	lda	#$FFDB
	sta	zp_16
	jml	f:sub_00D6DC

sub_018BB7:
	lda	#$0070
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018BF9
	lda	$2E,x
	beq	loc_018BE1
	; (not executed in the CDL traces)
	ldy	#$001C
	lda	zp_C4
	bpl	loc_018BD1
loc_018BCE:
	ldy	#$0024
loc_018BD1:
	sty	$20,x
	lda	#$FFE8
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC
loc_018BE1:
	lda	#$001E
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE8
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC
loc_018BF9:
	ldy	$2E,x
	beq	loc_018C2C
	; (not executed in the CDL traces)
	lda	zp_C4
	bmi	loc_018BCE
	bit	#$0050
	bne	loc_018C19
	lda	#$00BE
	sta	$20,x
	lda	#$FFEC
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC
loc_018C19:
	lda	#$00B4
	sta	$20,x
	lda	#$FFEC
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC
loc_018C2C:
	bit	#$0050
	bne	loc_018C49
	lda	#$008C
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE5
	sta	zp_14
	lda	#$FFC9
	sta	zp_16
	jml	f:sub_00D6DC
loc_018C49:
	lda	#$0080
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE8
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC

sub_018C61:
	lda	$2E,x
	beq	loc_018C68
	; (not executed in the CDL traces)
	brl	loc_018D19
loc_018C68:
	lda	zp_C4
	bit	#$0002
	beq	loc_018CA2
	lda	$0E,x
	sta	$10,x
	adc	#$FFF2
	sta	$2A,x
	adc	#$0006
	sta	a:$1314,x
	lda	$04,x
	bne	loc_018C8A
	lda	#$0020
	ldy	#$0018
	bra	loc_018C90
loc_018C8A:
	lda	#$0060
	ldy	#$FFDE
loc_018C90:
	sta	zp_12
	sty	zp_14
	lda	#$FFF2
	sta	zp_16
	lda	#$002A
	sta	$20,x
	jml	f:sub_00D6DC
loc_018CA2:
	lda	$0E,x
	sta	$10,x
	adc	#$FFE4
	sta	$2A,x
	adc	#$000A
	sta	a:$1314,x
	lda	zp_C4
	ldy	$04,x
	bne	loc_018CE9
	ldy	#$0020
	sty	zp_12
	lda	zp_C4
	bit	#$0028
	bne	loc_018CD6
	lda	#$0012
	sta	zp_14
	lda	#$FFE5
	sta	zp_16
	lda	#$00C0
	sta	$20,x
	jml	f:sub_00D6DC
loc_018CD6:
	lda	#$0010
	sta	zp_14
	lda	#$FFE5
	sta	zp_16
	lda	#$00B6
	sta	$20,x
	jml	f:sub_00D6DC
loc_018CE9:
	ldy	#$0060
	sty	zp_12
	bit	#$0028
	bne	loc_018D06
	lda	#$FFE4
	sta	zp_14
	lda	#$FFE5
	sta	zp_16
	lda	#$00B6
	sta	$20,x
	jml	f:sub_00D6DC
loc_018D06:
	lda	#$FFE6
	sta	zp_14
	lda	#$FFE5
	sta	zp_16
	lda	#$00C0
	sta	$20,x
	jml	f:sub_00D6DC
loc_018D19:
	; (not executed in the CDL traces)
	lda	#$0040
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018D46
	bpl	loc_018D2C
loc_018D27:
	lda	#$00E1
	bra	loc_018D2F
loc_018D2C:
	lda	#$00DF
loc_018D2F:
	sta	$20,x
	ldy	#$FFFD
	lda	$04,x
	bne	loc_018D3B
	ldy	#$FFF9
loc_018D3B:
	sty	zp_14
	lda	#$FFFC
	sta	zp_16
	jml	f:sub_00D6DC
loc_018D46:
	bmi	loc_018D27
	bit	#$0028
	bne	loc_018D77
	lda	$04,x
	bne	loc_018D64
	lda	#$FFFA
	sta	zp_14
	lda	#$FFF6
	sta	zp_16
	lda	#$00E5
	sta	$20,x
	jml	f:sub_00D6DC
loc_018D64:
	lda	#$FFFA
	sta	zp_14
	lda	#$FFF6
	sta	zp_16
	lda	#$00E3
	sta	$20,x
	jml	f:sub_00D6DC
loc_018D77:
	lda	$04,x
	bne	loc_018D8E
	lda	#$FFFA
	sta	zp_14
	lda	#$FFF4
	sta	zp_16
	lda	#$00E3
	sta	$20,x
	jml	f:sub_00D6DC
loc_018D8E:
	lda	#$FFFC
	sta	zp_14
	lda	#$FFF4
	sta	zp_16
	lda	#$00E5
	sta	$20,x
	jml	f:sub_00D6DC

sub_018DA1:
	lda	#$0030
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018DE3
	lda	$2E,x
	beq	loc_018DCB
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	loc_018DBB
loc_018DB8:
	ldy	#$0034
loc_018DBB:
	sty	$20,x
	lda	#$000A
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018DCB:
	lda	#$002E
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$000A
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018DE3:
	; (not executed in the CDL traces)
	ldy	$2E,x
	beq	loc_018E16
	lda	zp_C4
	bmi	loc_018DB8
	bit	#$0028
	bne	loc_018E03
	lda	#$00C2
	sta	$20,x
	lda	#$000A
	sta	zp_14
	lda	#$FFEC
	sta	zp_16
	jml	f:sub_00D6DC
loc_018E03:
	lda	#$00B8
	sta	$20,x
	lda	#$000B
	sta	zp_14
	lda	#$FFEC
	sta	zp_16
	jml	f:sub_00D6DC
loc_018E16:
	bit	#$0028
	bne	loc_018E33
	lda	#$00A4
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$0014
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018E33:
	lda	#$0098
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$000D
	sta	zp_14
	lda	#$FFEC
	sta	zp_16
	jml	f:sub_00D6DC

sub_018E4B:
	lda	#$0050
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018E8D
	lda	$2E,x
	beq	loc_018E75
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	loc_018E65
loc_018E62:
	ldy	#$0034
loc_018E65:
	sty	$20,x
	lda	#$FFEC
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018E75:
	lda	#$002E
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFEC
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018E8D:
	; (not executed in the CDL traces)
	ldy	$2E,x
	beq	loc_018EC0
	lda	zp_C4
	bmi	loc_018E62
	bit	#$0050
	bne	loc_018EAD
	lda	#$00C2
	sta	$20,x
	lda	#$FFEC
	sta	zp_14
	lda	#$FFEC
	sta	zp_16
	jml	f:sub_00D6DC
loc_018EAD:
	lda	#$00B8
	sta	$20,x
	lda	#$FFEA
	sta	zp_14
	lda	#$FFEE
	sta	zp_16
	jml	f:sub_00D6DC
loc_018EC0:
	bit	#$0050
	bne	loc_018EDD
	lda	#$00A4
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE4
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC
loc_018EDD:
	lda	#$0098
	sta	a:$1300,x
	jsl	f:sub_018F5A
	lda	#$FFE8
	sta	zp_14
	lda	#$FFEE
	sta	zp_16
	jml	f:sub_00D6DC

sub_018EF5:
	stz	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8000
	beq	loc_018F0B
	; (not executed in the CDL traces)
	jsl	f:sub_019433
	bra	loc_018F3E
loc_018F0B:
	bit	#$0002
	beq	loc_018F18
	lda	#$0005
	sta	$12,x
	brl	sub_019433
loc_018F18:
	lda	#$0006
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8000
	beq	loc_018F31
	jsl	f:sub_019414
	bra	loc_018F3E
loc_018F31:
	bit	#$0002
	beq	loc_018F3E
	lda	#$0002
	sta	$12,x
	brl	sub_019414
loc_018F3E:
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	ora	zp_04
	sta	zp_12
	brl	loc_019699

sub_018F5A:
	lda	zp_C0
	bne	loc_018F62
	inc	$20,x
	inc	$20,x
loc_018F62:
	lda	$20,x
	cmp	#$000C
	bcc	loc_018F6B
	stz	$20,x
loc_018F6B:
	rtl

sub_018F6C:
	lda	$0A,x
	sta	$06,x
	adc	#$0006
	sta	$28,x
	adc	#$FFFC
	sta	a:$1312,x
	lda	$0E,x
	sta	$10,x
	adc	#$FFDC
	sta	$2A,x
	adc	#$000E
	sta	a:$1314,x
	rts

sub_018F8B:
	lda	$3C,x
	bit	#$0004
	beq	loc_018F96
	jml	f:loc_019A76
loc_018F96:
	jsr	a:sub_01B0C0
	jsl	f:sub_01801B
	ldy	a:$1304,x
	beq	loc_018FC9
	lda	$3C,x
	bit	#$2000
	beq	loc_018FC9
	clc
	lda	$08,x
	adc	a:$0018,y
	sta	$08,x
	lda	$0A,x
	adc	a:$001A,y
	sta	$0A,x
	clc
	lda	$0C,x
	adc	a:$001C,y
	sta	$0C,x
	lda	$0E,x
	adc	a:$001E,y
	sta	$0E,x
	bra	loc_018FD5
loc_018FC9:
	jsl	f:sub_019013
	lda	a:zp_C4
	bne	loc_018FD5
	brl	loc_0182C8
loc_018FD5:
	lda	$2C,x
	bit	zp_8A
	beq	loc_018FE8
	lda	$26,x
	bit	#$0008
	beq	loc_018FE5
	brl	loc_0182C8
loc_018FE5:
	brl	loc_0182FD
loc_018FE8:
	stz	zp_14
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_018FF9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_018FF9:
	.addr	sub_01ADE2
	.addr	sub_01ADEE
	.addr	sub_01AE10
	.addr	sub_01AE2F
	.addr	sub_01AE51
	.addr	sub_01ADE2
	.addr	sub_01AE73
	.addr	sub_01ADE2
	.addr	sub_01AE95
	.addr	sub_01AEB4
	.addr	sub_01ADE2
	.addr	sub_01ADE2
	.addr	sub_01AED6

sub_019013:
	stz	zp_00
	lda	#$FFD0
	sta	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06

sub_01902B:
	lda	zp_06
	bit	#$0E00
	beq	loc_019050
	bit	#$0C00
	beq	loc_019081
	bit	#$0001
	bne	loc_019043
	bit	#$0800
	beq	loc_0190A6
	bne	loc_0190B9
loc_019043:
	bit	#$0800
	bne	loc_01904B
	brl	loc_0190CC
loc_01904B:
	beq	loc_019050
	brl	loc_0190DF
loc_019050:
	lda	zp_04
	bit	#$0E00
	bne	loc_01905A
	brl	loc_019102
loc_01905A:
	bit	#$0C00
	bne	loc_019062
	brl	loc_0190F2
loc_019062:
	bit	#$0001
	beq	loc_019074
	bit	#$0800
	bne	loc_01906F
	brl	loc_019102
loc_01906F:
	; (not executed in the CDL traces)
	beq	loc_019074
	brl	loc_019102
loc_019074:
	bit	#$0800
	bne	loc_01907C
	; (not executed in the CDL traces)
	brl	loc_019105
loc_01907C:
	beq	loc_019081
	brl	loc_01910D
loc_019081:
	lda	zp_04
	bit	#$0E00
	bne	loc_01908B
	brl	loc_0190F2
loc_01908B:
	bit	#$0C00
	bne	loc_019093
	brl	loc_0190FA
loc_019093:
	bit	#$0001
	beq	loc_01909F
	bit	#$0800
	beq	loc_0190FA
	bne	loc_0190FA
loc_01909F:
	bit	#$0800
	beq	loc_019105
	; (not executed in the CDL traces)
	bne	loc_01910D
loc_0190A6:
	lda	zp_04
	bit	#$0E00
	beq	loc_019102
	bit	#$0C00
	beq	loc_0190FA
	bit	#$0800
	beq	loc_019105
	; (not executed in the CDL traces)
	bne	loc_01910D
loc_0190B9:
	lda	zp_04
	bit	#$0E00
	beq	loc_019102
	bit	#$0C00
	beq	loc_0190FA
	bit	#$0800
	beq	loc_019105
	bne	loc_01910D
loc_0190CC:
	lda	zp_04
	bit	#$0E00
	beq	loc_019115
	bit	#$0C00
	beq	loc_019115
	bit	#$0800
	beq	loc_019115
	bne	loc_019115
loc_0190DF:
	lda	zp_04
	bit	#$0E00
	beq	loc_01911D
	bit	#$0C00
	beq	loc_01911D
	bit	#$0800
	beq	loc_01911D
	bne	loc_01911D
loc_0190F2:
	lda	#$8000
	sta	zp_C4
	brl	sub_0193F4
loc_0190FA:
	lda	#$0002
	sta	zp_C4
	brl	sub_0193F4
loc_019102:
	stz	zp_C4
	rtl
loc_019105:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_01910D:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_019115:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_01911D:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

sub_019125:
	lda	$3C,x
	bit	#$0004
	beq	loc_019130
	jml	f:loc_019A76
loc_019130:
	jsr	a:sub_01B0C0
	jsl	f:sub_01801B
	lda	$2C,x
	bit	zp_8A
	beq	loc_01914C
	stz	$3E,x
	lda	$22,x
	bit	#$0400
	beq	loc_019149
	brl	sub_0182C3
loc_019149:
	brl	loc_0182FD
loc_01914C:
	brl	loc_018FE8

sub_01914F:
	lda	$3C,x
	bit	#$0004
	beq	loc_01915A
	jml	f:loc_019A76
loc_01915A:
	lda	$0A,x
	adc	#$FFF6
	sta	$06,x
	adc	#$0006
	sta	$28,x
	adc	#$FFFE
	sta	a:$1312,x
	lda	$0E,x
	adc	#$FFF8
	sta	$10,x
	adc	#$FFE0
	sta	$2A,x
	adc	#$000C
	sta	a:$1314,x
	jsl	f:sub_01801B
	lda	#$0006
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	bne	loc_0191A9
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	bne	loc_0191A6
	; (not executed in the CDL traces)
	brl	loc_0182CD
loc_0191A6:
	brl	loc_0182E4
loc_0191A9:
	stz	$04,x
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_0191BA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_0191BA:
	.addr	sub_0191D4
	.addr	sub_0191E0
	.addr	sub_0191F8
	.addr	sub_01922D
	.addr	sub_019259
	.addr	sub_0191D4
	.addr	sub_01929D
	.addr	sub_0191D4
	.addr	sub_0192EB
	.addr	sub_019320
	.addr	sub_0191D4
	.addr	sub_0191D4
	.addr	sub_019349

sub_0191D4:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0191DD
	brl	loc_0182B5
loc_0191DD:
	brl	loc_019285

sub_0191E0:
	lda	#$0058
	sta	$20,x
	lda	#$0020
	sta	zp_12
	lda	#$0006
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC

sub_0191F8:
	lda	$2E,x
	beq	loc_019203
	lda	#$0066
	sta	$20,x
	bra	loc_019211
loc_019203:
	jsl	f:sub_019397
	beq	loc_01920D
	; (not executed in the CDL traces)
	stz	$1E,x
	stz	$1C,x
loc_01920D:
	jsl	f:sub_0193BE
loc_019211:
	lda	$2C,x
	bit	zp_8A
	beq	loc_01921A
	brl	loc_0182F7
loc_01921A:
	lda	#$0000
	sta	zp_12
	lda	#$FFF3
	sta	zp_14
	lda	#$FFBC
	sta	zp_16
	jml	f:sub_00D6DC

sub_01922D:
	lda	$2E,x
	beq	loc_019238
	lda	#$005A
	sta	$20,x
	bra	loc_019246
loc_019238:
	jsl	f:sub_019397
	beq	loc_019242
	stz	$1E,x
	stz	$1C,x
loc_019242:
	jsl	f:sub_0193BE
loc_019246:
	lda	#$0010
	sta	zp_12
	lda	#$0002
	sta	zp_14
	lda	#$FFC8
	sta	zp_16
	jml	f:sub_00D6DC

sub_019259:
	jsl	f:sub_019397
	bne	loc_019265
	jsl	f:sub_0193AC
	beq	loc_019272
loc_019265:
	ldy	$0A,x
	cpy	#$000B
	bcc	loc_019272
	dec	a
	sta	$12,x
	dec	$0A,x
	rtl
loc_019272:
	lda	$2C,x
	bit	zp_8A
	beq	loc_019285
	lda	#$97FF
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	brl	loc_0182B5
loc_019285:
	lda	#$005E
	sta	$20,x
	lda	#$0060
	sta	zp_12
	lda	#$FFCC
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC

sub_01929D:
	jsl	f:sub_019397
	bne	loc_0192A9
	jsl	f:sub_0193AC
	beq	loc_0192B6
loc_0192A9:
	ldy	$0A,x
	cpy	#$000B
	bcc	loc_0192B6
	dec	a
	sta	$12,x
	dec	$0A,x
	rtl
loc_0192B6:
	lda	$2E,x
	beq	loc_0192C1
	lda	#$0060
	sta	$20,x
	bra	loc_0192C5
loc_0192C1:
	; (not executed in the CDL traces)
	jsl	f:sub_0193BE
loc_0192C5:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0192D8
	; (not executed in the CDL traces)
	lda	#$97FF
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	brl	loc_0182F7
loc_0192D8:
	lda	#$0070
	sta	zp_12
	lda	#$FFD5
	sta	zp_14
	lda	#$FFCA
	sta	zp_16
	jml	f:sub_00D6DC

sub_0192EB:
	lda	$2E,x
	beq	loc_0192F6
	lda	#$0064
	sta	$20,x
	bra	loc_019304
loc_0192F6:
	jsl	f:sub_0193AC
	beq	loc_019300
	stz	$1E,x
	stz	$1C,x
loc_019300:
	jsl	f:sub_0193BE
loc_019304:
	lda	$2C,x
	bit	zp_8A
	beq	loc_01930D
	brl	loc_0182B5
loc_01930D:
	lda	#$0040
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFF8
	sta	zp_16
	jml	f:sub_00D6DC

sub_019320:
	; (not executed in the CDL traces)
	lda	$2E,x
	beq	loc_01932B
	lda	#$005C
	sta	$20,x
	bra	loc_019339
loc_01932B:
	jsl	f:sub_0193AC
	beq	loc_019335
	stz	$1E,x
	stz	$1C,x
loc_019335:
	jsl	f:sub_0193BE
loc_019339:
	lda	#$0030
	sta	zp_12
	stz	zp_14
	lda	#$FFEE
	sta	zp_16
	jml	f:sub_00D6DC

sub_019349:
	; (not executed in the CDL traces)
	jsl	f:sub_019397
	bne	loc_019355
	jsl	f:sub_0193AC
	beq	loc_019362
loc_019355:
	ldy	$0A,x
	cpy	#$000B
	bcc	loc_019362
	dec	a
	sta	$12,x
	dec	$0A,x
	rtl
loc_019362:
	lda	$2E,x
	beq	loc_01936D
	lda	#$0062
	sta	$20,x
	bra	loc_019371
loc_01936D:
	jsl	f:sub_0193BE
loc_019371:
	lda	$2C,x
	bit	zp_8A
	beq	loc_019384
	lda	#$97FF
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	brl	loc_0182B5
loc_019384:
	lda	#$0050
	sta	zp_12
	lda	#$FFD2
	sta	zp_14
	lda	#$FFEE
	sta	zp_16
	jml	f:sub_00D6DC

sub_019397:
	stz	zp_00
	lda	#$FFD0
	sta	zp_02
	jsl	f:sub_00E16E
	beq	loc_0193AB
	jsl	f:sub_0193F4
	lda	#$000E
loc_0193AB:
	rtl

sub_0193AC:
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	beq	loc_0193BD
	jsl	f:sub_0193DB
	lda	#$0001
loc_0193BD:
	rtl

sub_0193BE:
	lda	zp_C0
	bne	loc_0193C4
	inc	$20,x
loc_0193C4:
	lda	$20,x
	cmp	#$0054
	bcc	loc_0193D1
	cmp	#$0058
	bcs	loc_0193D1
	rtl
loc_0193D1:
	lda	#$0054
	sta	$20,x
	rtl
loc_0193D7:
	stz	$18,x
	stz	$1A,x

sub_0193DB:
	clc
	lda	a:wram_1398
	adc	$0E,x
	and	#$0007
	sta	zp_0E
	sec
	lda	$0E,x
	sbc	zp_0E
	sta	$0E,x
	stz	$1E,x
	stz	$1C,x
	stz	$0C,x
	rtl

sub_0193F4:
	stz	$1E,x
	stz	$1C,x
	stz	$0C,x
	clc
	lda	a:wram_1398
	adc	$0E,x
	eor	#$FFFF
	and	#$0007
	sta	zp_0E
	clc
	lda	$0E,x
	adc	zp_0E
	sta	$0E,x
	rtl

sub_019410:
	lda	$1A,x
	bmi	loc_01942E

sub_019414:
	clc
	lda	$0A,x
	adc	zp_00
	adc	a:wram_1380
	and	#$0007
	sta	zp_0E
	sec
	lda	$0A,x
	sbc	zp_0E
	sta	$0A,x
	stz	$1A,x
	stz	$18,x
	stz	$08,x
loc_01942E:
	rtl

sub_01942F:
	lda	$1A,x
	bpl	loc_01944F

sub_019433:
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$0007
	sta	zp_0E
	sec
	lda	$0A,x
	sbc	zp_0E
	clc
	adc	#$0007
	sta	$0A,x
	stz	$1A,x
	stz	$18,x
	stz	$08,x
loc_01944F:
	rtl
loc_019450:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	eor	#$FFFF
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_019480:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	eor	#$FFFF
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	sta	$0E,x
	rtl
loc_0194AB:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	clc
	adc	zp_10
	sta	zp_0E
	sec
	lda	#$000E
	sbc	zp_0E
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_0194DD:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	clc
	adc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	sec
	sbc	zp_0E
	sta	$0E,x
	rtl
loc_019502:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	eor	#$FFFF
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_019536:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	a:wram_1380
	and	#$000F
	eor	#$FFFF
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	sta	$0E,x
	rtl
loc_019565:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_019592:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	sta	$0E,x
	rtl
loc_0195BA:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	eor	#$FFFF
	lsr	a
	and	#$0007
	clc
	adc	zp_10
	sta	zp_0E
	sec
	lda	#$000E
	sbc	zp_0E
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_0195F2:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	eor	#$FFFF
	lsr	a
	and	#$0007
	clc
	adc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	and	#$FFF8
	sec
	sbc	zp_0E
	sta	$0E,x
	rtl
loc_01961D:
	stz	$1E,x
	stz	$1C,x
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	$0E,x
	rtl
loc_019651:
	lda	a:wram_1398
	and	#$0007
	sta	zp_10
	lda	$0A,x
	clc
	adc	zp_00
	clc
	adc	a:wram_1380
	and	#$000F
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	$0E,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	sta	$0E,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_019680:
	; (not executed in the CDL traces)
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	ora	zp_04
	sta	zp_12
loc_019699:
	lda	zp_06
	bit	#$807E
	bne	loc_0196A3
	brl	loc_0196CA
loc_0196A3:
	bit	#$0078
	bne	loc_0196AB
	brl	loc_0196FB
loc_0196AB:
	bit	#$0001
	bne	loc_0196BD
	bit	#$0050
	bne	loc_0196B8
	brl	loc_01972C
loc_0196B8:
	beq	loc_0196BD
	brl	loc_01974B
loc_0196BD:
	bit	#$0050
	bne	loc_0196C5
	brl	loc_01976A
loc_0196C5:
	beq	loc_0196CA
	brl	loc_019789
loc_0196CA:
	lda	zp_04
	bit	#$807E
	bne	loc_0196D4
	brl	loc_0197A8
loc_0196D4:
	bit	#$0078
	bne	loc_0196DC
	brl	loc_0197C3
loc_0196DC:
	bit	#$0001
	beq	loc_0196EE
	bit	#$0050
	bne	loc_0196E9
	brl	loc_0197AB
loc_0196E9:
	; (not executed in the CDL traces)
	beq	loc_0196EE
	brl	loc_0197B3
loc_0196EE:
	bit	#$0050
	bne	loc_0196F6
	brl	loc_0197CB
loc_0196F6:
	beq	loc_0196FB
	brl	loc_0197D3
loc_0196FB:
	lda	zp_04
	bit	#$807E
	bne	loc_019705
	brl	loc_0197C3
loc_019705:
	bit	#$0078
	bne	loc_01970D
	brl	loc_0197BB
loc_01970D:
	bit	#$0001
	beq	loc_01971F
	bit	#$0050
	bne	loc_01971A
	; (not executed in the CDL traces)
	brl	loc_0197C3
loc_01971A:
	beq	loc_01971F
	brl	loc_0197C3
loc_01971F:
	bit	#$0050
	bne	loc_019727
	brl	loc_0197CB
loc_019727:
	; (not executed in the CDL traces)
	beq	loc_01972C
	brl	loc_0197D3
loc_01972C:
	lda	zp_04
	bit	#$807E
	bne	loc_019736
	brl	loc_0197DB
loc_019736:
	bit	#$0078
	bne	loc_01973E
	; (not executed in the CDL traces)
	brl	loc_0197C3
loc_01973E:
	bit	#$0050
	bne	loc_019746
	brl	loc_0197E3
loc_019746:
	; (not executed in the CDL traces)
	beq	loc_01974B
	brl	loc_0197EB
loc_01974B:
	lda	zp_04
	bit	#$807E
	bne	loc_019755
	brl	loc_0197CB
loc_019755:
	bit	#$0078
	bne	loc_01975D
	brl	loc_0197C3
loc_01975D:
	bit	#$0050
	bne	loc_019765
	brl	loc_0197E3
loc_019765:
	beq	loc_01976A
	brl	loc_0197EB
loc_01976A:
	lda	zp_04
	bit	#$807E
	bne	loc_019774
	brl	loc_0197F3
loc_019774:
	bit	#$0078
	bne	loc_01977C
	brl	loc_0197F3
loc_01977C:
	bit	#$0050
	bne	loc_019784
	brl	loc_0197FB
loc_019784:
	beq	loc_019789
	brl	loc_0197FB
loc_019789:
	lda	zp_04
	bit	#$807E
	bne	loc_019793
	; (not executed in the CDL traces)
	brl	loc_019803
loc_019793:
	bit	#$0078
	bne	loc_01979B
	; (not executed in the CDL traces)
	brl	loc_019803
loc_01979B:
	bit	#$0050
	bne	loc_0197A3
	; (not executed in the CDL traces)
	brl	loc_01980B
loc_0197A3:
	beq	loc_0197A8
	brl	loc_01980B
loc_0197A8:
	stz	zp_C4
	rtl
loc_0197AB:
	lda	#$8011
	sta	zp_C4
	brl	loc_019651
loc_0197B3:
	; (not executed in the CDL traces)
	lda	#$8011
	sta	zp_C4
	brl	loc_019592
loc_0197BB:
	lda	#$0002
	sta	zp_C4
	brl	sub_0193DB
loc_0197C3:
	lda	#$8002
	sta	zp_C4
	brl	sub_0193DB
loc_0197CB:
	lda	#$8008
	sta	zp_C4
	brl	loc_019480
loc_0197D3:
	lda	#$8008
	sta	zp_C4
	brl	loc_0194DD
loc_0197DB:
	lda	#$8008
	sta	zp_C4
	brl	loc_019536
loc_0197E3:
	lda	#$0008
	sta	zp_C4
	brl	loc_019480
loc_0197EB:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194DD
loc_0197F3:
	lda	#$8010
	sta	zp_C4
	brl	loc_019592
loc_0197FB:
	lda	#$0010
	sta	zp_C4
	brl	loc_019592
loc_019803:
	; (not executed in the CDL traces)
	lda	#$8010
	sta	zp_C4
	brl	loc_0195F2
loc_01980B:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195F2

sub_019813:
	lda	$3C,x
	bit	#$0004
	beq	loc_01981E
	jml	f:loc_019A76
loc_01981E:
	lda	$0A,x
	adc	#$0008
	sta	$06,x
	adc	#$0006
	sta	$28,x
	adc	#$FFFC
	sta	a:$1312,x
	lda	$0E,x
	adc	#$FFF8
	sta	$10,x
	adc	#$FFE0
	sta	$2A,x
	adc	#$0006
	sta	a:$1314,x
	jsl	f:sub_01801B
	stz	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	bne	loc_01986A
	; (not executed in the CDL traces)
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	bne	loc_019867
	brl	loc_0182CD
loc_019867:
	brl	loc_0182E4
loc_01986A:
	lda	#$0002
	sta	$04,x
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_01987E,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01987E:
	.addr	sub_019898
	.addr	sub_0198A3
	.addr	sub_0198E0
	.addr	sub_019915
	.addr	sub_01995C
	.addr	sub_019898
	.addr	sub_019974
	.addr	sub_019898
	.addr	sub_0199A0
	.addr	sub_0199D6
	.addr	sub_019898
	.addr	sub_019898
	.addr	sub_019A1D

sub_019898:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0198A1
	brl	sub_0182BC
loc_0198A1:
	bra	loc_0198C8

sub_0198A3:
	jsl	f:sub_019A49
	bne	loc_0198AF
	jsl	f:sub_019A61
	beq	loc_0198B5
loc_0198AF:
	dec	a
	sta	$12,x
	inc	$0A,x
	rtl
loc_0198B5:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0198C8
	lda	#$6800
	sta	$18,x
	lda	#$0001
	sta	$1A,x
	brl	sub_0182BC
loc_0198C8:
	lda	#$005E
	sta	$20,x
	lda	#$0020
	sta	zp_12
	lda	#$002A
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC

sub_0198E0:
	lda	$2E,x
	beq	loc_0198EB
	lda	#$0066
	sta	$20,x
	bra	loc_0198F9
loc_0198EB:
	; (not executed in the CDL traces)
	jsl	f:sub_019A49
	beq	loc_0198F5
	stz	$1C,x
	stz	$1E,x
loc_0198F5:
	jsl	f:sub_0193BE
loc_0198F9:
	lda	$2C,x
	bit	zp_8A
	beq	loc_019902
	brl	loc_0182FB
loc_019902:
	lda	#$0000
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFBE
	sta	zp_16
	jml	f:sub_00D6DC

sub_019915:
	jsl	f:sub_019A49
	bne	loc_019921
	jsl	f:sub_019A61
	beq	loc_019927
loc_019921:
	; (not executed in the CDL traces)
	dec	a
	sta	$12,x
	inc	$0A,x
	rtl
loc_019927:
	lda	$2E,x
	beq	loc_019932
	lda	#$0060
	sta	$20,x
	bra	loc_019936
loc_019932:
	jsl	f:sub_0193BE
loc_019936:
	lda	$2C,x
	bit	zp_8A
	beq	loc_019949
	lda	#$6800
	sta	$18,x
	lda	#$0001
	sta	$1A,x
	brl	loc_0182FB
loc_019949:
	lda	#$0010
	sta	zp_12
	lda	#$0020
	sta	zp_14
	lda	#$FFCC
	sta	zp_16
	jml	f:sub_00D6DC

sub_01995C:
	lda	#$0058
	sta	$20,x
	lda	#$0060
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFDA
	sta	zp_16
	jml	f:sub_00D6DC

sub_019974:
	lda	$2E,x
	beq	loc_01997F
	lda	#$005A
	sta	$20,x
	bra	loc_01998D
loc_01997F:
	; (not executed in the CDL traces)
	jsl	f:sub_019A49
	beq	loc_019989
	stz	$1E,x
	stz	$1C,x
loc_019989:
	jsl	f:sub_0193BE
loc_01998D:
	lda	#$0070
	sta	zp_12
	lda	#$FFF4
	sta	zp_14
	lda	#$FFC6
	sta	zp_16
	jml	f:sub_00D6DC

sub_0199A0:
	lda	$2E,x
	beq	loc_0199AB
	lda	#$0064
	sta	$20,x
	bra	loc_0199B9
loc_0199AB:
	jsl	f:sub_019A61
	beq	loc_0199B5
	; (not executed in the CDL traces)
	stz	$1C,x
	stz	$1E,x
loc_0199B5:
	jsl	f:sub_0193BE
loc_0199B9:
	lda	$2C,x
	bit	zp_8A
	beq	loc_0199C3
	; (not executed in the CDL traces)
	jsl	f:sub_0182BC
loc_0199C3:
	lda	#$0040
	sta	zp_12
	lda	#$0006
	sta	zp_14
	lda	#$FFF8
	sta	zp_16
	jml	f:sub_00D6DC

sub_0199D6:
	; (not executed in the CDL traces)
	jsl	f:sub_019A49
	bne	loc_0199E2
	jsl	f:sub_019A61
	beq	loc_0199E8
loc_0199E2:
	dec	a
	sta	$12,x
	inc	$0A,x
	rtl
loc_0199E8:
	lda	$2E,x
	beq	loc_0199F3
	lda	#$0062
	sta	$20,x
	bra	loc_0199F7
loc_0199F3:
	jsl	f:sub_0193BE
loc_0199F7:
	lda	$2C,x
	bit	zp_8A
	beq	loc_019A0A
	lda	#$6800
	sta	$18,x
	lda	#$0001
	sta	$1A,x
	brl	sub_0182BC
loc_019A0A:
	lda	#$0030
	sta	zp_12
	lda	#$0024
	sta	zp_14
	lda	#$FFF0
	sta	zp_16
	jml	f:sub_00D6DC

sub_019A1D:
	; (not executed in the CDL traces)
	lda	$2E,x
	beq	loc_019A28
	lda	#$005C
	sta	$20,x
	bra	loc_019A36
loc_019A28:
	jsl	f:sub_019A61
	beq	loc_019A32
	stz	$1E,x
	stz	$1C,x
loc_019A32:
	jsl	f:sub_0193BE
loc_019A36:
	lda	#$0050
	sta	zp_12
	lda	#$FFF6
	sta	zp_14
	lda	#$FFED
	sta	zp_16
	jml	f:sub_00D6DC

sub_019A49:
	lda	#$0006
	sta	zp_00
	lda	#$FFD0
	sta	zp_02
	jsl	f:sub_00E16E
	beq	loc_019A60
	; (not executed in the CDL traces)
	jsl	f:sub_0193F4
	lda	#$000E
loc_019A60:
	rtl

sub_019A61:
	lda	#$0006
	sta	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	beq	loc_019A75
	jsl	f:sub_0193DB
	lda	#$0001
loc_019A75:
	rtl
loc_019A76:
	lda	#$003F
	ldy	$0E,x
	cpy	#$00F8
	bcc	loc_019A85
	bmi	loc_019A85
	lda	#$0043
loc_019A85:
	jsl	f:queue_sound
	stz	$30,x
	stz	$34,x
	stz	$36,x
	stz	$3E,x
	lda	$04,x
	beq	loc_019AA1
	lda	#$0001
	sta	$1A,x
	lda	#$6800
	sta	$18,x
	bra	loc_019AAB
loc_019AA1:
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
loc_019AAB:
	lda	#$DFFF
	sta	$1C,x
	lda	#$FFFB
	sta	$1E,x
	lda	a:$1D80,x
	bne	loc_019ABF
	stz	a:$1D86,x
	bra	loc_019ACA
loc_019ABF:
	lda	a:$1D82,x
	beq	loc_019AC7
	stz	a:$1D86,x
loc_019AC7:
	stz	a:$1D84,x
loc_019ACA:
	lda	#$0007
	sta	$12,x
	lda	#$00E8
	sta	$20,x
	stz	a:$1300,x
	stz	$32,x
	lda	#$0028
	sta	$30,x
	stz	$24,x
	stz	$38,x
	lda	#$8000
	sta	$16,x
	stz	a:$1D88,x
	rtl

sub_019AEB:
	lda	$0A,x
	sta	$06,x
	adc	#$0006
	sta	$28,x
	lda	$0E,x
	adc	#$FFF2
	sta	$10,x
	adc	#$FFE4
	sta	$2A,x
	lda	$0E,x
	bmi	loc_019B09
	cmp	#$0120
	bcs	loc_019B52
loc_019B09:
	dec	$30,x
	lda	$30,x
	beq	loc_019B22
	bit	#$0007
	bne	loc_019B22
	inc	$20,x
	lda	#$00ED
	cmp	$20,x
	bne	loc_019B22
	lda	#$00E9
	sta	$20,x
loc_019B22:
	lda	$1E,x
	bmi	loc_019B2B
	cmp	#$0006
	bcs	loc_019B3A
loc_019B2B:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_019B3A:
	stz	zp_C4
	lda	$1E,x
	bpl	loc_019B4A
	jsl	f:sub_019D76
loc_019B44:
	lda	#$0007
	sta	$12,x
	rtl
loc_019B4A:
	jsl	f:sub_019DAB
	lda	$12,x
	bne	loc_019B44
loc_019B52:
	lda	#$0008
	sta	$12,x
	lda	#$0020
	sta	$30,x
	stz	$1A,x
	stz	$18,x
	lda	#$00ED
	sta	$20,x
	rtl

sub_019B66:
	lda	$0A,x
	sta	$06,x
	adc	#$0006
	sta	$28,x
	lda	$0E,x
	sta	$10,x
	adc	#$FFF0
	sta	$2A,x
	dec	$30,x
	bpl	loc_019B9C
	stz	$0A,x
	stz	$0E,x
	stz	$00,x
	stz	$20,x
	stz	a:$1300,x
	stz	$16,x
	lda	#$000E
	sta	$12,x
	lda	#$0000
	dec	a:$1D8A,x
	beq	loc_019B99
	lda	#$0001
loc_019B99:
	sta	a:$1D8C,x
loc_019B9C:
	rtl

sub_019B9D:
	lda	a:$1D8A,x
	beq	loc_019BC7
	stz	$0A,x
	stz	$0E,x
	stz	$00,x
	stz	$20,x
	stz	a:$1300,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	$32,x
	stz	$24,x
	stz	$38,x
	stz	$16,x
	stz	$3C,x
	lda	#$000F
	sta	$12,x
	stz	a:$1D88,x
loc_019BC7:
	rtl

sub_019BC8:
	lda	a:wram_1672
	phx
	asl	a
	tax
	lda	f:tbl_019BD8,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_019BD8:
	.addr	sub_019C7D
	.addr	sub_019C73
	.addr	sub_019D4C
	.addr	sub_019D61
	.addr	sub_019C69
	.addr	sub_019C55
	.addr	sub_019C18
	.addr	sub_019BFF
	.addr	sub_019BEA

sub_019BEA:
	lda	#$0020
	cpx	#$0200
	beq	loc_019BF5
	lda	#$0040
loc_019BF5:
	sta	$0A,x
	lda	#$005A
	sta	$0E,x
	brl	sub_019E14

sub_019BFF:
	sec
	lda	a:wram_028E
	sbc	#$0018
	sta	$0E,x
	lda	#$0058
	cpx	#$0200
	beq	loc_019C13
	; (not executed in the CDL traces)
	lda	#$0098
loc_019C13:
	sta	$0A,x
	brl	sub_019E14

sub_019C18:
	ldy	#$07C0
loc_019C1B:
	lda	a:$0010,y
	cmp	#$0065
	bne	loc_019C49
	lda	a:$000A,y
	bmi	loc_019C49
	cmp	#$0044
	bcs	loc_019C49
	txa
	sec
	sbc	#$0200
	lsr	a
	clc
	adc	#$0020
	adc	a:$000A,y
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	#$0024
	sta	$0E,x
	jml	f:sub_019E14
loc_019C49:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0880
	bcc	loc_019C1B
	rtl

sub_019C55:
	lda	#$00B4
	sta	$0E,x
	lda	#$000A
	sta	$0A,x
	jsl	f:sub_019E14
	lda	#$0008
	sta	$1A,x
	rtl

sub_019C69:
	lda	#$0040
	sta	zp_0E
	lda	#$000E
	bra	loc_019C85

sub_019C73:
	lda	#$0020
	sta	zp_0E
	lda	#$0012
	bra	loc_019C85

sub_019C7D:
	lda	#$0030
	sta	zp_0E
	lda	#$0014
loc_019C85:
	sta	zp_08
	sta	zp_02
	lda	#$0020
	sta	zp_06
	lda	#$0038
	cpx	#$0200
	beq	loc_019C99
	lda	#$0020
loc_019C99:
	stx	zp_FC
	stz	zp_04
	clc
	adc	a:wram_1380
	bit	#$0100
	beq	loc_019CAB
	ldy	#$0800
	sty	zp_04
loc_019CAB:
	lsr	a
	lsr	a
	and	#$003E
	sta	zp_00
	lda	a:wram_1398
	clc
	adc	zp_0E
	asl	a
	asl	a
	asl	a
	and	#$07C0
	sta	zp_12
loc_019CC0:
	sta	zp_0A
	ora	zp_00
	ora	zp_04
loc_019CC6:
	tax
	lda	f:$7E4000,x
	beq	loc_019D03
	txa
	and	#$003E
	asl	a
	asl	a
	sta	zp_00
	txa
	and	#$07C0
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	a:wram_1398
	and	#$00FF
	ldx	zp_FC
	sec
	sbc	#$0038
	bmi	loc_019CF0
	cmp	#$0020
	bcs	loc_019CF3
loc_019CF0:
	lda	#$0020
loc_019CF3:
	sta	$0E,x
	sec
	lda	zp_00
	sbc	a:wram_1380
	and	#$00FF
	sta	$0A,x
	brl	sub_019E14
loc_019D03:
	clc
	lda	zp_0A
	adc	#$0040
	and	#$07C0
	dec	zp_02
	bne	loc_019CC0
	lda	zp_08
	sta	zp_02
	lda	zp_12
	sta	zp_0A
	dec	zp_06
	bne	loc_019D21
	; (not executed in the CDL traces)
	ldx	zp_FC
	brl	loc_019D42
loc_019D21:
	clc
	lda	zp_00
	adc	#$0002
	cmp	#$0040
	bcc	loc_019D39
	lda	zp_04
	adc	#$0800
	and	#$0800
	sta	zp_04
	lda	#$0000
loc_019D39:
	sta	zp_00
	ora	zp_04
	ora	zp_12
	brl	loc_019CC6
loc_019D42:
	; (not executed in the CDL traces)
	lda	#$0080
	sta	$0A,x
	sta	$0E,x
	brl	sub_019E14

sub_019D4C:
	lda	#$0070
	cpx	#$0200
	beq	loc_019D57
	lda	#$0088
loc_019D57:
	sta	$0E,x
	lda	#$00D2
	sta	$0A,x
	brl	sub_019E14

sub_019D61:
	lda	#$0078
	cpx	#$0200
	beq	loc_019D6C
	; (not executed in the CDL traces)
	lda	#$0058
loc_019D6C:
	sta	$0A,x
	lda	#$00BC
	sta	$0E,x
	brl	sub_019E14

sub_019D76:
	lda	#$FFF8
	jsl	f:sub_01AF72
	lda	#$0006
	sta	zp_00
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_019D93
	brl	sub_019414
loc_019D93:
	stz	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_019DA1
	brl	sub_019433
loc_019DA1:
	lda	zp_C4
	beq	loc_019DAA
	bpl	loc_019DAA
	; (not executed in the CDL traces)
	brl	sub_0193F4
loc_019DAA:
	rtl

sub_019DAB:
	lda	$3C,x
	bit	#$0080
	beq	loc_019DB5
	; (not executed in the CDL traces)
	stz	$12,x
	rtl
loc_019DB5:
	stz	zp_00
	stz	zp_02
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	jsl	f:sub_01857A
	lda	#$0006
	sta	zp_00
	lda	#$FFF8
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_019DEE
	jsl	f:sub_019414
	lda	zp_C4
	beq	loc_019DED
	bmi	loc_019DED
	stz	$12,x
loc_019DED:
	rtl
loc_019DEE:
	stz	zp_00
	jsl	f:sub_00E16E
	bit	#$8002
	beq	loc_019E06
	jsl	f:sub_019433
	lda	zp_C4
	beq	loc_019E05
	bmi	loc_019E05
	stz	$12,x
loc_019E05:
	rtl
loc_019E06:
	lda	zp_C4
	beq	loc_019E13
	stz	$12,x
	lda	zp_C4
	bpl	loc_019E13
	brl	sub_0193DB
loc_019E13:
	rtl

sub_019E14:
	ldy	a:wram_1672
	lda	a:data_05AB78,y
	and	#$00FF
	sta	$12,x
	tya
	asl	a
	tay
	lda	a:data_05AB93,y
	sta	$1E,x
	lda	a:data_05AB81,y
	sta	$20,x
	stz	$04,x
	stz	$32,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	a:$1300,x
	lda	#$0060
	sta	$24,x
	lda	#$0003
	sta	$16,x
	rtl
