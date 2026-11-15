; objects/player.asm -- Players
; Bank $01, $01:A548-$01:B193. Included by main.asm in segment BANK01.
;
; sub_01A624 (once per frame from the stage loop sub_00BF69) updates both
; players (objects at $0200/$0240): joypad state, barrier blinking, the player
; state machine (sub_01A6CF), collisions; sub_01AA6A, sub_01ABFF, sub_01B0C0.

sub_01A548:
	jsr	a:sub_018839
	lda	$0E,x
	cmp	#$00C8
	bcs	loc_01A564
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	brl	sub_018555
loc_01A564:
	lda	#$00C8
	sta	$0E,x
	stz	$04,x
	stz	$1C,x
	stz	$1E,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	lda	#$00E7
	sta	$20,x
	inc	$12,x
	rtl

sub_01A57D:
	lda	$0E,x
	sta	$10,x
	adc	#$FFDA
	sta	$2A,x
	adc	#$0004
	sta	a:$1314,x
	lda	$0A,x
	sta	$06,x
	adc	#$0028
	sta	$28,x
	adc	#$FFE0
	sta	a:$1312,x
	lda	$2C,x
	bit	zp_88
	beq	loc_01A60B
	txy
	ldx	#$0AC0
	cpy	#$0200
	beq	loc_01A5AD
	ldx	#$0D40
loc_01A5AD:
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
	beq	loc_01A5C8
	; (not executed in the CDL traces)
	tyx
	bra	loc_01A60B
loc_01A5C8:
	lda	#$0007
	sta	$10,x
	lda	#$0010
	sta	$06,x
	lda	#$3348
	sta	$02,x
	lda	#$FFFF
	sta	$16,x
	lda	#$00A0
	sta	$0E,x
	clc
	lda	a:$000A,y
	adc	#$0020
	sta	$0A,x
	lda	#$0040
	sta	$14,x
	stz	$1A,x
	stz	$18,x
	tyx
	lda	#$DFFF
	sta	$34,x
	lda	#$FFF9
	sta	$36,x
	lda	#$0004
	sta	a:shake_timer
	lda	#$0020
	jsl	f:queue_sound
loc_01A60B:
	lda	$36,x
	beq	loc_01A620
	clc
	lda	$34,x
	adc	#$4800
	sta	$34,x
	lda	$36,x
	adc	#$0000
	sta	$36,x
	bra	loc_01A622
loc_01A620:
	stz	$34,x
loc_01A622:
	rtl
	; CDL: not accessed
	.byte	$6B

sub_01A624:
	ldx	#$0200
	lda	a:p1_lives
	beq	loc_01A654
	lda	joy1_held
	sta	$22,x
	lda	joy1_pressed
	sta	$2C,x
	lda	$24,x
	beq	loc_01A64D
	dec	$24,x
	bne	loc_01A643
	lda	$16,x
	and	#$FFFD
	sta	$16,x
loc_01A643:
	bit	#$0003
	bne	loc_01A64D
	lda	#$3200
	bra	loc_01A650
loc_01A64D:
	lda	#$3A00
loc_01A650:
	jsl	f:sub_01A6CF
loc_01A654:
	jsr	a:sub_01AAF4
	ldx	#$0240
	lda	a:p2_lives
	beq	loc_01A687
	lda	joy2_held
	sta	$22,x
	lda	joy2_pressed
	sta	$2C,x
	lda	$24,x
	beq	loc_01A680
	dec	$24,x
	bne	loc_01A676
	lda	$16,x
	and	#$FFFD
	sta	$16,x
loc_01A676:
	bit	#$0003
	bne	loc_01A680
	lda	#$3220
	bra	loc_01A683
loc_01A680:
	lda	#$3C20
loc_01A683:
	jsl	f:sub_01A6CF
loc_01A687:
	jsr	a:sub_01AAF4
	jsl	f:sub_00C67D
	jsl	f:sub_00C917
	lda	a:p1_lives
	beq	loc_01A6B0
	ldx	#$0200
	jsl	f:sub_01AA6A
	lda	zp_BC
	beq	loc_01A6B0
	lda	#$6000
	sta	zp_B8
	lda	#$6100
	sta	zp_BA
	jsl	f:sub_018063
loc_01A6B0:
	lda	a:p2_lives
	beq	loc_01A6CE
	ldx	#$0240
	jsl	f:sub_01AA6A
	lda	zp_BC
	bne	loc_01A6CE
	lda	#$6200
	sta	zp_B8
	lda	#$6300
	sta	zp_BA
	jsl	f:sub_018063
loc_01A6CE:
	rtl

sub_01A6CF:
	sta	$02,x
	jsl	f:sub_00C1F4
	jsl	f:sub_018000
	stz	$2E,x
	stz	$26,x
	stz	a:$1300,x
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01A6EF,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01A6EF:
	.addr	sub_01A93D
	.addr	sub_01A938
	.addr	sub_01A9B9
	.addr	sub_01A956
	.addr	sub_01A956
	.addr	sub_01A9B9
	.addr	sub_01A806
	.addr	sub_01AA20
	.addr	sub_01AA20
	.addr	sub_01AA20
	.addr	sub_01A851
	.addr	sub_01AA18
	.addr	sub_01A956
	.addr	sub_01A938
	.addr	sub_01AA20
	.addr	sub_01AA20
	.addr	sub_01A7B9
	.addr	sub_01A757
	.addr	sub_01A719
	.addr	sub_01AA18
	.addr	sub_01AA18

sub_01A719:
	lda	$24,x
	cmp	#$0001
	bne	loc_01A72A
	lda	#$0040
	sta	$24,x
	lda	#$0011
	sta	$12,x
loc_01A72A:
	stz	$26,x
	cpx	#$0240
	bne	loc_01A739
	cmp	#$0058
	bcc	loc_01A739
	brl	sub_01AA18
loc_01A739:
	lda	$1A,x
	bpl	loc_01A745
	cmp	#$FFFE
	bcs	loc_01A745
	brl	sub_01AA18
loc_01A745:
	sec
	lda	$18,x
	sbc	#$3000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	brl	sub_01AA18

sub_01A757:
	stz	$04,x
	stz	$18,x
	stz	$1A,x
	lda	$22,x
	bit	#$0800
	beq	loc_01A76B
	lda	#$0002
	sta	$26,x
	bra	loc_01A775
loc_01A76B:
	bit	#$0400
	beq	loc_01A775
	lda	#$0008
	sta	$26,x
loc_01A775:
	lda	$22,x
	bit	#$0100
	beq	loc_01A794
	lda	$26,x
	ora	#$0001
	sta	$26,x
	lda	$22,x
	bit	zp_8E
	beq	loc_01A78C
	brl	sub_01AA18
loc_01A78C:
	lda	#$0002
	sta	$1A,x
	brl	sub_01AA18
loc_01A794:
	bit	#$0200
	bne	loc_01A79C
	brl	sub_01AA18
loc_01A79C:
	lda	#$0002
	sta	$04,x
	lda	$26,x
	ora	#$0004
	sta	$26,x
	lda	$22,x
	bit	zp_8E
	beq	loc_01A7B1
	brl	sub_01AA18
loc_01A7B1:
	lda	#$FFFE
	sta	$1A,x
	brl	sub_01AA18

sub_01A7B9:
	stz	$18,x
	stz	$1A,x
	lda	$22,x
	bit	a:wram_1628
	beq	loc_01A7C6
	inc	$2E,x
loc_01A7C6:
	bit	#$0100
	beq	loc_01A7D4
	stz	$04,x
	lda	#$0001
	sta	$26,x
	bra	loc_01A7E3
loc_01A7D4:
	bit	#$0200
	beq	loc_01A7E3
	lda	#$0002
	sta	$04,x
	lda	#$0004
	sta	$26,x
loc_01A7E3:
	lda	$22,x
	bit	#$0400
	beq	loc_01A7F4
	lda	$26,x
	ora	#$0008
	sta	$26,x
	brl	sub_01AA18
loc_01A7F4:
	bit	#$0800
	bne	loc_01A7FC
	brl	sub_01AA18
loc_01A7FC:
	lda	$26,x
	ora	#$0002
	sta	$26,x
	brl	sub_01AA18

sub_01A806:
	; (not executed in the CDL traces)
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	$22,x
	bit	#$0100
	beq	loc_01A81F
	lda	#$6800
	sta	$18,x
	lda	#$0001
	bra	loc_01A82C
loc_01A81F:
	bit	#$0200
	beq	loc_01A82E
	lda	#$97FF
	sta	$18,x
	lda	#$FFFE
loc_01A82C:
	sta	$1A,x
loc_01A82E:
	lda	$22,x
	bit	#$0800
	beq	loc_01A83F
	lda	#$97FF
	sta	$1C,x
	lda	#$FFFE
	bra	loc_01A84C
loc_01A83F:
	bit	#$0400
	beq	loc_01A84E
	lda	#$6800
	sta	$1C,x
	lda	#$0001
loc_01A84C:
	sta	$1E,x
loc_01A84E:
	brl	sub_01AA20

sub_01A851:
	lda	#$0040
	sta	a:wram_09D6
	stz	a:wram_09F4
	stz	a:$1304,x
	stz	$18,x
	stz	$1A,x
	lda	a:wram_09C6
	beq	loc_01A86F
	lda	$2C,x
	bit	zp_8A
	beq	loc_01A8A9
	dec	a:wram_09D2
loc_01A86F:
	stz	a:wram_16AE
	lda	#$001F
	jsl	f:queue_sound
	stz	a:wram_165C
	stz	a:wram_09DA
	stz	a:wram_09D8
	lda	#$0041
	sta	a:wram_09D6
	lda	#$0003
	sta	$12,x
	inc	$0A,x
	dec	$0E,x
	dec	$0E,x
	lda	#$3FFF
	sta	$1C,x
	lda	#$FFFA
	sta	$1E,x
	lda	#$0060
	sta	$24,x
	stz	$32,x
	stz	$34,x
	brl	sub_01AA20
loc_01A8A9:
	lda	$22,x
	bit	#$0100
	beq	loc_01A8C1
	lda	$3C,x
	bit	#$0200
	bne	loc_01A8E1
	lda	#$0001
	sta	$1A,x
	lda	#$6800
	bra	loc_01A8CE
loc_01A8C1:
	bit	#$0200
	beq	loc_01A8E1
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
loc_01A8CE:
	sta	$18,x
	lda	a:wram_16AE
	bne	loc_01A8F0
	inc	a:wram_16AE
	lda	#$001E
	jsl	f:queue_sound
	bra	loc_01A8F0
loc_01A8E1:
	lda	a:wram_16AE
	beq	loc_01A8F0
	stz	a:wram_16AE
	lda	#$001F
	jsl	f:queue_sound
loc_01A8F0:
	clc
	lda	$18,x
	adc	$34,x
	sta	$18,x
	lda	$1A,x
	adc	$36,x
	sta	$1A,x
	clc
	lda	$08,x
	adc	$18,x
	lda	$0A,x
	sta	zp_00
	adc	$1A,x
	cmp	#$000A
	bcs	loc_01A919
	sec
	lda	#$000A
	sbc	zp_00
	sta	a:wram_165C
	brl	sub_01AA20
loc_01A919:
	sec
	sbc	zp_00
	sta	a:wram_165C
	bne	loc_01A924
	brl	sub_01AA20
loc_01A924:
	bpl	loc_01A92F
	lda	#$0001
	sta	a:wram_09F4
	brl	sub_01AA20
loc_01A92F:
	lda	#$0002
	sta	a:wram_09F4
	brl	sub_01AA20

sub_01A938:
	lda	a:wram_1628
	bra	loc_01A93F

sub_01A93D:
	lda	zp_8E
loc_01A93F:
	sta	zp_00
	lda	$22,x
	bit	zp_00
	beq	loc_01A94B
	inc	$2E,x
	bra	loc_01A958
loc_01A94B:
	bit	#$0300
	bne	loc_01A958
	stz	$18,x
	stz	$1A,x
	bra	loc_01A999

sub_01A956:
	lda	$22,x
loc_01A958:
	bit	#$0100
	beq	loc_01A977
	stz	$04,x
	lda	$3C,x
	bit	#$0400
	bne	loc_01A970
	lda	#$0001
	sta	$1A,x
	lda	#$6800
	sta	$18,x
loc_01A970:
	lda	#$0001
	sta	$26,x
	bra	loc_01A999
loc_01A977:
	lda	$22,x
	bit	#$0200
	beq	loc_01A999
	lda	#$0002
	sta	$04,x
	lda	$3C,x
	bit	#$0200
	bne	loc_01A994
	lda	#$FFFE
	sta	$1A,x
	lda	#$97FF
	sta	$18,x
loc_01A994:
	lda	#$0004
	sta	$26,x
loc_01A999:
	lda	$22,x
	bit	#$0400
	beq	loc_01A9A9
	lda	$26,x
	ora	#$0008
	sta	$26,x
	bra	sub_01AA18
loc_01A9A9:
	lda	$22,x
	bit	#$0800
	beq	sub_01AA18
	lda	$26,x
	ora	#$0002
	sta	$26,x
	bra	sub_01AA18

sub_01A9B9:
	stz	$18,x
	stz	$1A,x
	lda	$22,x
	bit	#$0400
	beq	loc_01A9D5
	lda	#$0001
	sta	$1E,x
	lda	#$6800
	sta	$1C,x
	lda	#$0008
	sta	$26,x
	bra	loc_01A9EB
loc_01A9D5:
	lda	$22,x
	bit	#$0800
	beq	loc_01A9F4
	lda	#$FFFE
	sta	$1E,x
	lda	#$97FF
	sta	$1C,x
	lda	#$0002
	sta	$26,x
loc_01A9EB:
	lda	$22,x
	bit	a:wram_1628
	beq	loc_01A9F8
	inc	$2E,x
loc_01A9F4:
	stz	$1C,x
	stz	$1E,x
loc_01A9F8:
	lda	$22,x
	bit	#$0100
	beq	loc_01AA08
	lda	$26,x
	ora	#$0001
	sta	$26,x
	bra	sub_01AA20
loc_01AA08:
	lda	$22,x
	bit	#$0200
	beq	sub_01AA20
	lda	$26,x
	ora	#$0004
	sta	$26,x
	bra	sub_01AA20

sub_01AA18:
	lda	$2E,x
	beq	sub_01AA20
	stz	$18,x
	stz	$1A,x

sub_01AA20:
	clc
	lda	$18,x
	adc	$08,x
	sta	$08,x
	lda	$0A,x
	sta	zp_00
	adc	$1A,x
	cmp	#$000A
	bcc	loc_01AA3C
	cmp	#$00F0
	bcc	loc_01AA3F
	lda	#$00F0
	bra	loc_01AA3F
loc_01AA3C:
	lda	#$000A
loc_01AA3F:
	sta	$0A,x
	sec
	sbc	zp_00
	sta	a:$1306,x
	clc
	lda	$1C,x
	adc	$0C,x
	sta	$0C,x
	lda	$0E,x
	sta	zp_00
	adc	$1E,x
	ldy	a:wram_1666
	beq	loc_01AA61
	cmp	#$0031
	bcs	loc_01AA61
	lda	#$0031
loc_01AA61:
	sta	$0E,x
	sec
	sbc	zp_00
	sta	a:$130C,x
	rtl

sub_01AA6A:
	sec
	lda	a:$000A,x
	sbc	a:wram_138E
	sta	a:$000A,x
	sec
	lda	a:$000E,x
	sbc	a:wram_13A6
	sta	a:$000E,x
	bmi	loc_01AA8A
	cmp	#$00FF
	bcc	loc_01AA8A
	lda	#$0004
	sta	$3C,x
loc_01AA8A:
	lda	$32,x
	beq	loc_01AA99
	and	#$00FF
	bne	loc_01AA97
	stz	$32,x
	bra	loc_01AA99
loc_01AA97:
	dec	$32,x
loc_01AA99:
	lda	$3A,x
	dec	a
	cmp	#$0008
	bcc	loc_01AAA4
	lda	#$0000
loc_01AAA4:
	sta	$3A,x
	lda	$14,x
	dec	a
	cmp	#$0008
	bcc	loc_01AAB1
	lda	#$0000
loc_01AAB1:
	sta	$14,x
	lda	a:$1D88,x
	beq	loc_01AABB
	dec	a:$1D88,x
loc_01AABB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_01AACA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01AACA:
	.addr	sub_01885E
	.addr	sub_018F8B
	.addr	sub_01914F
	.addr	sub_018354
	.addr	sub_018317
	.addr	sub_019813
	.addr	sub_019C18
	.addr	sub_019AEB
	.addr	sub_019B66
	.addr	sub_01A548
	.addr	sub_01A57D
	.addr	sub_01AC71
	.addr	sub_018354
	.addr	sub_01AD83
	.addr	sub_019B9D
	.addr	sub_019BC8
	.addr	sub_019125
	.addr	sub_01B0E7
	.addr	sub_01B104
	.addr	sub_01ABFF
	.addr	sub_01AC28

sub_01AAF4:
	lda	a:$1310,x
	beq	loc_01AB1E
	clc
	adc	a:$131A,x
	cmp	#$00FF
	bcc	loc_01AB05
	lda	#$0000
loc_01AB05:
	sta	a:$1310,x
	clc
	lda	a:$1318,x
	adc	#$0800
	sta	a:$1318,x
	lda	a:$131A,x
	adc	#$0000
	sta	a:$131A,x
	jsr	a:sub_01AB1F
loc_01AB1E:
	rts

sub_01AB1F:
	lda	zp_BC
	bne	loc_01AB2A
	cpx	#$0200
	bne	loc_01ABA7
	beq	loc_01AB2F
loc_01AB2A:
	cpx	#$0240
	bne	loc_01ABA7
loc_01AB2F:
	lda	a:$131C,x
	adc	a:$1310,x
	sta	zp_00
	lda	a:$131C,x
	sbc	a:$1310,x
	sta	zp_02
	lda	a:$131E,x
	adc	a:$1310,x
	sta	zp_04
	lda	a:$131E,x
	sbc	a:$1310,x
	sta	zp_06
	txy
	ldx	#$159E
	phx
loc_01AB54:
	plx
	inx
	inx
	lda	$00,x
	beq	loc_01ABA6
	phx
	tax
	lda	$06,x
	bmi	loc_01AB54
	lda	zp_00
	cmp	$0A,x
	bmi	loc_01AB54
	lda	zp_06
	cmp	$0E,x
	bpl	loc_01AB54
	lda	zp_04
	cmp	$2E,x
	bmi	loc_01AB54
	lda	zp_02
	cmp	$2C,x
	bpl	loc_01AB54
	lda	#$0100
	sta	$14,x
	lda	$16,x
	bit	#$0010
	beq	loc_01AB54
	bit	#$0020
	bne	loc_01AB54
	sec
	lda	$06,x
	sbc	#$0001
	sta	$06,x
	bpl	loc_01AB54
	phy
	lda	$10,x
	asl	a
	tay
	lda	a:type_scores,y
	ply
	phx
	tyx
	jsl	f:sub_00B829
	plx
	bra	loc_01AB54
loc_01ABA6:
	tyx
loc_01ABA7:
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_01ABA8:
	; (not executed in the CDL traces)
	lda	$22,x
	bit	#$2000
	beq	loc_01ABFE
	lda	$2C,x
	bit	#$0800
	beq	loc_01ABCE
	inc	difficulty
	inc	difficulty
	lda	difficulty
	and	#$0006
	cmp	#$0006
	bne	loc_01ABC7
	lda	#$0000
loc_01ABC7:
	sta	difficulty
	sta	a:$1D8C,x
	bra	loc_01ABFE
loc_01ABCE:
	lda	$22,x
	bit	#$0080
	beq	loc_01ABDD
	lda	#$0001
	sta	a:$1D8A,x
	bra	loc_01ABE4
loc_01ABDD:
	lda	$22,x
	bit	#$8000
	beq	loc_01ABEB
loc_01ABE4:
	lda	#$0004
	sta	$3C,x
	bra	loc_01ABFE
loc_01ABEB:
	lda	$22,x
	bit	#$0040
	beq	loc_01ABFE
	lda	#$8000
	sta	a:$1D8A,x
	sta	a:$1D8C,x
	sta	a:$1D88,x
loc_01ABFE:
	rts

sub_01ABFF:
	dec	$34,x
	bpl	loc_01AC1A
	inc	$12,x
	lda	#$0040
	sta	$34,x
	lda	#$0004
	sta	$30,x
	lda	#$0004
	sta	$36,x
	lda	#$0111
	sta	$20,x
	rtl
loc_01AC1A:
	lda	$34,x
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_05ABC1,y
	sta	$20,x
	rtl

sub_01AC28:
	lda	$34,x
	bmi	loc_01AC2F
	dec	$34,x
	rtl
loc_01AC2F:
	lda	$30,x
	cmp	#$000C
	bcs	loc_01AC53
	dec	$36,x
	bpl	loc_01AC52
	ldy	#$0004
	sty	$36,x
	inc	$30,x
	inc	$30,x
	cpx	#$0200
	beq	loc_01AC4C
	; (not executed in the CDL traces)
	clc
	adc	#$000C
loc_01AC4C:
	tay
	lda	a:data_05ABC9,y
	sta	$20,x
loc_01AC52:
	rtl
loc_01AC53:
	lda	$22,x
	bit	#$4000
	beq	loc_01AC52
	stz	$30,x
	lda	#$0010
	sta	$36,x
	rtl
loc_01AC62:
	lda	#$0008
	sta	$30,x
	lda	#$000B
	sta	$12,x
	stz	$18,x
	stz	$1A,x
	rtl

sub_01AC71:
	jsr	a:sub_018F6C
	jsl	f:sub_01801B
	lda	$3C,x
	bit	#$0004
	beq	loc_01AC83
	jml	f:loc_019A76
loc_01AC83:
	ldy	a:$1304,x
	beq	loc_01ACA3
	stz	a:$1304,x
	bit	#$0080
	beq	loc_01ACA3
	clc
	lda	$0A,x
	adc	a:$001A,y
	sta	$0A,x
	clc
	lda	$0E,x
	adc	a:$001E,y
	sta	$0E,x
	bra	loc_01ACC1
loc_01ACA2:
	; (not executed in the CDL traces)
	rtl
loc_01ACA3:
	jsl	f:sub_018EF5
	lda	$12,x
	cmp	#$000B
	bne	loc_01ACA2
	lda	zp_C4
	bne	loc_01ACB5
	brl	loc_0182CD
loc_01ACB5:
	lda	zp_C4
	bit	#$0008
	bne	loc_01ACCF
	bit	#$0010
	bne	loc_01ACC6
loc_01ACC1:
	lda	#$0000
	bra	loc_01ACD6
loc_01ACC6:
	lda	$04,x
	bne	loc_01ACD3
loc_01ACCA:
	lda	#$0010
	bra	loc_01ACD6
loc_01ACCF:
	lda	$04,x
	bne	loc_01ACCA
loc_01ACD3:
	lda	#$0008
loc_01ACD6:
	ldy	$30,x
	beq	loc_01ACDF
	dec	$30,x
	clc
	adc	$30,x
loc_01ACDF:
	lsr	a
	tay
	lda	a:data_05ABE1,y
	and	#$00FF
	sta	$20,x
	lda	$30,x
	bne	loc_01AD08
	lda	a:$1D8E,x
	beq	loc_01AD09
	lda	$22,x
	bit	zp_88
	beq	loc_01AD08
	lda	#$FFFA
	sta	$1E,x
	lda	#$070A
	sta	$32,x
	stz	$34,x
	stz	$36,x
	inc	$12,x
loc_01AD08:
	rtl
loc_01AD09:
	lda	#$0000
	sta	$12,x
	stz	$30,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01AD11:
	; (not executed in the CDL traces)
	jsr	a:sub_018839
	lda	$3C,x
	bit	#$0004
	beq	loc_01AD1F
	jml	f:loc_019A76
loc_01AD1F:
	jsl	f:sub_018555
	jsl	f:sub_01801B
	lda	#$FFF2
	ldy	$04,x
	bne	loc_01AD31
	lda	#$FFF6
loc_01AD31:
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
	jsl	f:sub_00D692
	stz	$38,x
	lda	#$0002
	ldy	$04,x
	bne	loc_01AD48
	lda	#$0006
loc_01AD48:
	sta	zp_14
	lda	#$FFD8
	sta	zp_16
	jsl	f:sub_00D656
	stz	$38,x
	lda	$1E,x
	bmi	loc_01AD5E
	cmp	#$0006
	bcs	loc_01AD6D
loc_01AD5E:
	clc
	lda	$1C,x
	adc	#$0C00
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01AD6D:
	bpl	loc_01AD79
	jsl	f:sub_019D76
loc_01AD73:
	lda	#$000C
	sta	$12,x
	rtl
loc_01AD79:
	jsl	f:sub_019DAB
	lda	$12,x
	bne	loc_01AD73
	rtl
loc_01AD82:
	rtl

sub_01AD83:
	lda	$3C,x
	bit	#$0004
	beq	loc_01AD8E
	jml	f:loc_019A76
loc_01AD8E:
	jsr	a:sub_01B0C0
	jsl	f:sub_01801B
	jsl	f:sub_01AF3C
	lda	$12,x
	cmp	#$000D
	bne	loc_01AD82
	lda	zp_C4
	bne	loc_01ADA7
	brl	loc_0182C8
loc_01ADA7:
	lda	$2C,x
	bit	zp_8A
	beq	loc_01ADB7
	lda	$26,x
	bit	#$0008
	beq	loc_01ADB7
	brl	loc_0182C8
loc_01ADB7:
	stz	zp_14
	lda	$26,x
	phx
	asl	a
	tax
	lda	f:tbl_01ADC8,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_01ADC8:
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

sub_01ADE2:
	lda	#$004A
	sta	$20,x
	lda	$04,x
	beq	loc_01ADFD
	brl	loc_01AE60

sub_01ADEE:
	lda	$2E,x
	beq	loc_01ADF9
	lda	#$004A
	sta	$20,x
	bra	loc_01ADFD
loc_01ADF9:
	jsl	f:sub_01AEF8
loc_01ADFD:
	lda	#$0020
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFDF
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AE10:
	lda	#$0052
	sta	$20,x
	lda	#$0000
	sta	zp_12
	ldy	#$FFFE
	lda	$04,x
	bne	loc_01AE24
	ldy	#$FFF8
loc_01AE24:
	sty	zp_14
	lda	#$FFC0
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AE2F:
	lda	$2E,x
	beq	loc_01AE3A
	lda	#$004C
	sta	$20,x
	bra	loc_01AE3E
loc_01AE3A:
	jsl	f:sub_01AEF8
loc_01AE3E:
	lda	#$0010
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFCB
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AE51:
	lda	$2E,x
	beq	loc_01AE5C
	lda	#$004A
	sta	$20,x
	bra	loc_01AE60
loc_01AE5C:
	jsl	f:sub_01AF0F
loc_01AE60:
	lda	#$0060
	sta	zp_12
	lda	#$FFEC
	sta	zp_14
	lda	#$FFDF
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AE73:
	lda	$2E,x
	beq	loc_01AE7E
	lda	#$004C
	sta	$20,x
	bra	loc_01AE82
loc_01AE7E:
	; (not executed in the CDL traces)
	jsl	f:sub_01AF0F
loc_01AE82:
	lda	#$0070
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFCC
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AE95:
	lda	#$0050
	sta	$20,x
	lda	#$0040
	sta	zp_12
	ldy	#$0000
	lda	$04,x
	bne	loc_01AEA9
	ldy	#$FFF6
loc_01AEA9:
	sty	zp_14
	lda	#$0000
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AEB4:
	lda	$2E,x
	beq	loc_01AEBF
	lda	#$004E
	sta	$20,x
	bra	loc_01AEC3
loc_01AEBF:
	; (not executed in the CDL traces)
	jsl	f:sub_01AEF8
loc_01AEC3:
	lda	#$0030
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFF4
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AED6:
	; (not executed in the CDL traces)
	lda	$2E,x
	beq	loc_01AEE1
	lda	#$004E
	sta	$20,x
	bra	loc_01AEE5
loc_01AEE1:
	jsl	f:sub_01AF0F
loc_01AEE5:
	lda	#$0050
	sta	zp_12
	lda	#$FFF0
	sta	zp_14
	lda	#$FFF2
	sta	zp_16
	jml	f:sub_00D6DC

sub_01AEF8:
	lda	zp_C4
	ldy	#$0000
	bit	#$0018
	beq	loc_01AF24
	ldy	#$0004
	bit	#$0010
	beq	loc_01AF24
	ldy	#$0008
	bra	loc_01AF24

sub_01AF0F:
	lda	zp_C4
	ldy	#$0000
	bit	#$0018
	beq	loc_01AF24
	ldy	#$0004
	bit	#$0008
	beq	loc_01AF24
	ldy	#$0008
loc_01AF24:
	tya
	clc
	adc	#$003E
	sta	a:$1300,x
	lda	zp_C0
	bne	loc_01AF32
	inc	$20,x
loc_01AF32:
	lda	$20,x
	cmp	#$0004
	bcc	loc_01AF3B
	stz	$20,x
loc_01AF3B:
	rtl

sub_01AF3C:
	stz	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	beq	loc_01AF54
	lda	#$0005
	sta	$12,x
	brl	sub_019433
loc_01AF54:
	lda	#$0006
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:sub_00E16E
	bit	#$0002
	beq	sub_01AF6F
	lda	#$0002
	sta	$12,x
	brl	sub_019414

sub_01AF6F:
	lda	#$FFD0

sub_01AF72:
	sta	zp_02
	stz	zp_00
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
	sta	zp_06
	lda	zp_06
	bit	#$0182
	beq	loc_01AFAC
	bit	#$0180
	beq	loc_01AFDD
	bit	#$0001
	bne	loc_01AF9F
	bit	#$0080
	beq	loc_01B002
	bne	loc_01B015
loc_01AF9F:
	bit	#$0080
	bne	loc_01AFA7
	brl	loc_01B028
loc_01AFA7:
	beq	loc_01AFAC
	brl	loc_01B03B
loc_01AFAC:
	lda	zp_04
	bit	#$0182
	bne	loc_01AFB6
	brl	loc_01B05C
loc_01AFB6:
	bit	#$0180
	bne	loc_01AFBE
	brl	loc_01B04E
loc_01AFBE:
	bit	#$0001
	beq	loc_01AFD0
	; (not executed in the CDL traces)
	bit	#$0080
	bne	loc_01AFCB
	brl	loc_01B05C
loc_01AFCB:
	beq	loc_01AFD0
	brl	loc_01B05C
loc_01AFD0:
	bit	#$0080
	bne	loc_01AFD8
	; (not executed in the CDL traces)
	brl	loc_01B05F
loc_01AFD8:
	beq	loc_01AFDD
	brl	loc_01B067
loc_01AFDD:
	lda	zp_04
	bit	#$0182
	bne	loc_01AFE7
	brl	loc_01B04E
loc_01AFE7:
	bit	#$0180
	bne	loc_01AFEF
	brl	loc_01B054
loc_01AFEF:
	; (not executed in the CDL traces)
	bit	#$0001
	beq	loc_01AFFB
	bit	#$0080
	beq	loc_01B054
	bne	loc_01B05C
loc_01AFFB:
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B002:
	lda	zp_04
	bit	#$0182
	beq	loc_01B05C
	bit	#$0180
	beq	loc_01B054
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B015:
	lda	zp_04
	bit	#$0182
	beq	loc_01B05C
	bit	#$0180
	beq	loc_01B05C
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B028:
	lda	zp_04
	bit	#$0182
	beq	loc_01B06F
	bit	#$0180
	beq	loc_01B06F
	bit	#$0080
	beq	loc_01B06F
	bne	loc_01B06F
loc_01B03B:
	lda	zp_04
	bit	#$0182
	beq	loc_01B077
	bit	#$0180
	beq	loc_01B077
	bit	#$0080
	beq	loc_01B077
	bne	loc_01B077
loc_01B04E:
	lda	#$8000
	sta	zp_C4
	rtl
loc_01B054:
	lda	#$0002
	sta	zp_C4
	brl	sub_0193F4
loc_01B05C:
	stz	zp_C4
	rtl
loc_01B05F:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_01B067:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_01B06F:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_01B077:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

; (no caller found; decoded because it follows the end of a routine)
sub_01B07F:
	; (not executed in the CDL traces)
	lda	#$8000
	sta	zp_C4
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01B085:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	zp_C4
	brl	sub_0193F4

; (no caller found; decoded because it follows the end of a routine)
sub_01B08D:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	loc_01961D

; (no caller found; decoded because it follows the end of a routine)
sub_01B095:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	loc_019502

; (no caller found; decoded because it follows the end of a routine)
sub_01B09D:
	; (not executed in the CDL traces)
	stz	zp_C4
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01B0A0:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	loc_019450

; (no caller found; decoded because it follows the end of a routine)
sub_01B0A8:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB

; (no caller found; decoded because it follows the end of a routine)
sub_01B0B0:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

; (no caller found; decoded because it follows the end of a routine)
sub_01B0B8:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA

sub_01B0C0:
	ldy	$04,x
	lda	$0A,x
	adc	a:data_05ABED,y
	sta	$06,x
	adc	a:data_05ABF1,y
	sta	$28,x
	adc	a:data_05ABF5,y
	sta	a:$1312,x
	lda	$0E,x
	adc	#$FFF8
	sta	$10,x
	adc	#$FFE4
	sta	$2A,x
	adc	#$0008
	sta	a:$1314,x
	rts

sub_01B0E7:
	jsl	f:sub_01801B
	lda	$3C,x
	bit	#$0004
	beq	loc_01B0F6
	jml	f:loc_019A76
loc_01B0F6:
	lda	$2C,x
	bit	zp_8A
	beq	sub_01B104
	lda	#$0002
	sta	$34,x
	brl	loc_0182FD

sub_01B104:
	lda	$0A,x
	sta	$06,x
	adc	#$0006
	sta	$28,x
	adc	#$FFFC
	sta	a:$1312,x
	lda	$34,x
	bne	loc_01B13F
	lda	$0E,x
	cmp	#$00B2
	bcs	loc_01B125
	lda	#$0002
	sta	$34,x
	bra	loc_01B153
loc_01B125:
	lda	$1D,x
	bpl	loc_01B12E
	cmp	#$FFC0
	bcc	loc_01B162
loc_01B12E:
	sec
	lda	$1C,x
	sbc	#$0800
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bra	loc_01B162
loc_01B13F:
	lda	$0E,x
	cmp	#$00BA
	bcc	loc_01B14A
	stz	$34,x
	bra	loc_01B12E
loc_01B14A:
	lda	$1D,x
	bmi	loc_01B153
	cmp	#$0040
	bcs	loc_01B162
loc_01B153:
	clc
	lda	$1C,x
	adc	#$0800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01B162:
	clc
	lda	$0E,x
	sta	$10,x
	adc	#$FFDC
	sta	$2A,x
	adc	#$000E
	sta	a:$1314,x
	lda	$26,x
	asl	a
	tay
	lda	a:data_05ABF9,y
	sta	zp_12
	lda	a:data_05AC13,y
	sta	$20,x
	lda	zp_E6
	lsr	a
	sta	a:$1300,x
	lda	a:data_05AC2D,y
	sta	zp_14
	lda	a:data_05AC47,y
	sta	zp_16
	jml	f:sub_00D6DC
