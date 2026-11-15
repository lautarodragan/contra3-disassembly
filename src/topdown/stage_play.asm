; topdown/stage_play.asm -- Top-down stages: gameplay (part 1)
; Bank $02, $02:8E33-$02:DDC5. Included by main.asm in segment BANK02.
;
; Players, objects and map handling of the top-down stages, reached from the
; state handlers in topdown/stage_states.asm.

sub_028E33:
	lda	joy1_held
	sta	a:wram_152C
	lda	joy1_pressed
	sta	a:wram_152E
	ldx	#$0EC0
	jsl	f:sub_028E51
	lda	joy2_held
	sta	a:wram_156C
	lda	joy2_pressed
	sta	a:wram_156E
	ldx	#$0F00

sub_028E51:
	lda	$12,x
	bne	loc_028E58
	brl	sub_028EF2
loc_028E58:
	lda	a:$0648,x
	beq	loc_028E70
	dec	a:$0648,x
	bne	loc_028E6A
	lda	#$8000
	sta	$16,x
	lda	#$0002
loc_028E6A:
	and	#$0002
	lsr	a
	sta	$00,x
loc_028E70:
	lda	$2C,x
	beq	loc_028E77
	brl	sub_029449
loc_028E77:
	lda	$06,x
	bpl	loc_028E7E
	brl	sub_029393
loc_028E7E:
	jsr	a:sub_0290A5
	jsr	a:sub_0290F3
	jsr	a:sub_029113
	jsr	a:sub_0291A5
	lda	a:$0640,x
	beq	loc_028E92
	brl	loc_028EC0
loc_028E92:
	jsr	a:sub_029102
	bcc	loc_028E9A
	brl	sub_02929D
loc_028E9A:
	stz	a:$10CE,x
	lda	a:$066C,x
	bit	zp_92
	beq	loc_028EA7
	brl	sub_0291CB
loc_028EA7:
	bit	#$0F00
	beq	loc_028EAF
	brl	sub_029355
loc_028EAF:
	bit	zp_96
	beq	loc_028EB6
	brl	sub_029355
loc_028EB6:
	bit	zp_94
	beq	loc_028EBD
	brl	sub_029355
loc_028EBD:
	brl	sub_029233
loc_028EC0:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_028ECF,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_028ECF:
	.addr	sub_028EF2
	.addr	sub_029233
	.addr	sub_029265
	.addr	sub_029355
	.addr	sub_029376
	.addr	sub_0291CB
	.addr	sub_02929D
	.addr	sub_0292F2
	.addr	sub_029393
	.addr	sub_029449
loc_028EE3:
	stz	$00,x
	stz	$06,x
	stz	a:$0648,x
	stz	$16,x
	lda	#$0001
	sta	a:$10CC,x

sub_028EF2:
	lda	a:$10CA,x
	bne	loc_028F4B
	stz	a:$10CC,x
	stz	$12,x
	lda	a:title_menu_cursor
	beq	loc_028F0C
	; (not executed in the CDL traces)
	dec	a
	bne	loc_028F0D
	lda	a:$10F4,x
	beq	loc_028F0D
	dec	a:$10F4,x
loc_028F0C:
	rtl
loc_028F0D:
	; (not executed in the CDL traces)
	jsr	a:sub_028FBB
	lda	a:$002C,y
	sta	$2C,x
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$000E,y
	sta	$0E,x
	lda	a:$0004,y
	eor	#$0080
	sta	$04,x
	stz	$08,x
	stz	$0C,x
	lda	a:$0002,y
	and	#$3000
	bne	loc_028F36
	lda	#$2000
loc_028F36:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	loc_028F43
	lda	#$0A00
loc_028F43:
	and	#$CFFF
	ora	zp_FA
	sta	$02,x
	rtl
loc_028F4B:
	lda	#$0002
	sta	a:$0644,x
	lda	#$00C0
	sta	a:$0648,x
	lda	#$0001
	sta	$00,x
	lda	#$0003
	sta	$20,x
	lda	#$0004
	sta	$06,x
	lda	$02,x
	beq	loc_028F6E
	lda	$2C,x
	beq	loc_028F7B
loc_028F6E:
	lda	#$2800
	cpx	#$0EC0
	beq	loc_028F79
	lda	#$2A00
loc_028F79:
	sta	$02,x
loc_028F7B:
	stz	$2E,x
	stz	$16,x
	lda	a:wram_1E80
	sta	a:$10F4,x
	lda	a:$0654,x
	clc
	adc	a:$0658,x
	and	#$00FF
	sta	$04,x
	stz	a:$064A,x
	jsr	a:sub_028FC8
	lda	a:wram_15A8
	bne	loc_028FA5
	lda	#$0100
	sta	a:$10D4,x
	sta	a:$10D6,x
loc_028FA5:
	stz	$2C,x
	stz	a:$10CE,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	a:$0640,x
	lda	#$0001
	sta	$12,x
	rtl

sub_028FBB:
	; (not executed in the CDL traces)
	cpx	#$0EC0
	bne	loc_028FC4
	ldy	#$0F00
	rts
loc_028FC4:
	ldy	#$0EC0
	rts

sub_028FC8:
	lda	a:title_menu_cursor
	dec	a
	beq	loc_028FEE
	bpl	loc_028FF3
loc_028FD0:
	lda	$2C,x
	beq	sub_028FED
	lda	a:wram_1594
	lsr	a
	phx
	asl	a
	tax
	lda	f:tbl_028FE5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_028FE5:
	.addr	sub_029037
	.addr	sub_028FED
	.addr	sub_029080
	.addr	sub_028FED

sub_028FED:
	rts
loc_028FEE:
	lda	$2C,x
	bne	loc_028FD0
	rts
loc_028FF3:
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_029036
	jsr	a:sub_028FBB
	lda	a:$10CA,y
	beq	loc_028FD0
	lda	a:$002C,y
	bne	loc_028FD0
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$000E,y
	sta	$0E,x
	lda	a:$0004,y
	eor	#$0080
	sta	$04,x
	stz	$08,x
	stz	$0C,x
	lda	a:$0002,y
	and	#$3000
	bne	loc_029025
	lda	#$2000
loc_029025:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	loc_029032
	lda	#$0A00
loc_029032:
	ora	zp_FA
	sta	$02,x
loc_029036:
	rts

sub_029037:
	jsr	a:sub_02905C
	xba
	and	#$0003
	asl	a
	asl	a
	sta	zp_FA
	jsr	a:sub_02906E
	xba
	and	#$0003
	ora	zp_FA
	asl	a
	tay
	lda	a:data_05D0DE,y
	sta	$0A,x
	lda	a:data_05D11E,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

sub_02905C:
	lda	$0E,x
	bmi	loc_029066
	cmp	#$0400
	bpl	loc_02906A
	rts
loc_029066:
	lda	#$0000
	rts
loc_02906A:
	lda	#$03FF
	rts

sub_02906E:
	lda	$0A,x
	bmi	loc_029078
	cmp	#$0400
	bpl	loc_02907C
	rts
loc_029078:
	; (not executed in the CDL traces)
	lda	#$0000
	rts
loc_02907C:
	lda	#$03FF
	rts

sub_029080:
	jsr	a:sub_02905C
	xba
	and	#$0003
	asl	a
	asl	a
	sta	zp_FA
	jsr	a:sub_02906E
	xba
	and	#$0003
	ora	zp_FA
	asl	a
	tay
	lda	a:data_05D0FE,y
	sta	$0A,x
	lda	a:data_05D13E,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

sub_0290A5:
	lda	a:$066C,x
	and	#$0030
	beq	loc_0290E1
	lda	a:$0642,x
	bit	#$00FF
	beq	loc_0290D2
	xba
	and	#$0030
	bit	a:$066E,x
	bne	loc_0290C4
	bit	a:$066C,x
	beq	loc_0290D2
	rts
loc_0290C4:
	xba
	ora	#$0008
	sta	a:$0642,x
	lda	#$0004
	sta	a:$0644,x
	rts
loc_0290D2:
	lda	a:$066E,x
	and	#$0030
	beq	loc_0290E7
	xba
	ora	#$0008
	sta	a:$0642,x
loc_0290E1:
	lda	#$0002
	sta	a:$0644,x
loc_0290E7:
	lda	a:$0642,x
	and	#$00FF
	beq	loc_0290F2
	dec	a:$0642,x
loc_0290F2:
	rts

sub_0290F3:
	lda	a:$066E,x
	bit	zp_88
	beq	loc_0290FE
	stz	a:$0646,x
	rts
loc_0290FE:
	inc	a:$0646,x
	rts

sub_029102:
	lda	zp_94
	ora	zp_96
	sta	zp_FA
	and	a:$066C,x
	cmp	zp_FA
	beq	loc_029111
	clc
	rts
loc_029111:
	sec
	rts

sub_029113:
	lda	#$0007
	cmp	$12,x
	beq	loc_02912F
	lda	a:$066E,x
	bit	zp_96
	bne	loc_02912C
	bit	zp_94
	beq	loc_02912F
	lda	#$0002
	sta	a:$0656,x
	rts
loc_02912C:
	stz	a:$0656,x
loc_02912F:
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_029130:
	; (not executed in the CDL traces)
	lda	a:$066C,x
	bit	#$0040
	beq	loc_0291A4
	lda	a:$066E,x
	bit	#$0020
	beq	loc_02914E
	inc	a:$10C4,x
	lda	a:$10C4,x
	cmp	#$0006
	bcc	loc_02914E
	stz	a:$10C4,x
loc_02914E:
	lda	a:$066E,x
	bit	#$0010
	beq	loc_029164
	inc	a:$10C6,x
	lda	a:$10C6,x
	cmp	#$0006
	bcc	loc_029164
	stz	a:$10C6,x
loc_029164:
	lda	a:$066E,x
	bit	#$0080
	beq	loc_02917D
	inc	a:$10CC,x
	lda	a:$10CC,x
	cmp	#$0009
	bcc	loc_02917D
	lda	#$0009
	sta	a:$10CC,x
loc_02917D:
	lda	a:$066E,x
	bit	#$4000
	beq	loc_02918B
	lda	#$FFFF
	sta	a:$10C8,x
loc_02918B:
	lda	a:$066E,x
	bit	#$8000
	beq	loc_0291A4
	inc	a:$10CA,x
	lda	a:$10CA,x
	cmp	#$0063
	bcc	loc_0291A4
	lda	#$0063
	sta	a:$10CA,x
loc_0291A4:
	rts

sub_0291A5:
	lda	a:$066E,x
	bit	zp_8C
	beq	loc_0291CA
	lda	a:$10CC,x
	beq	loc_0291CA
	lda	a:$0090,x
	dec	a
	beq	loc_0291CA
	lda	#$005A
	jsl	f:sub_00868F
	dec	a:$10CC,x
	lda	#$0001
	sta	a:$0090,x
	stz	a:$0092,x
loc_0291CA:
	rts

sub_0291CB:
	lda	#$0005
	cmp	$12,x
	beq	loc_0291DA
	sta	$12,x
	lda	#$0008
	sta	a:$0640,x
loc_0291DA:
	lda	a:$0640,x
	cmp	#$0004
	bne	loc_0291F5
	lda	a:$066C,x
	bit	#$8000
	beq	loc_0291F5
	bit	#$4000
	beq	loc_029202
	jsl	f:sub_0296D8
	bra	loc_029202
loc_0291F5:
	dec	a:$0640,x
	bpl	loc_029202
	stz	a:$0640,x
	lda	#$0003
	sta	$12,x
loc_029202:
	jsl	f:sub_02920E
	jsl	f:sub_02C334
	jsr	a:sub_0295CD
	rtl

sub_02920E:
	lda	$22,x
	bne	loc_029215
	inc	$22,x
	rtl
loc_029215:
	lda	#$0000
	ldy	a:$0640,x
	cpy	#$0004
	bne	loc_029223
	lda	#$0004
loc_029223:
	ora	a:$10DE,x
	tay
	lda	a:data_05D15E,y
	cmp	$20,x
	beq	loc_029232
	sta	$20,x
	stz	$22,x
loc_029232:
	rtl

sub_029233:
	lda	a:$066C,x
	bit	zp_88
	bne	sub_029265
	lda	#$0001
	cmp	$12,x
	beq	loc_029243
	sta	$12,x
loc_029243:
	jsl	f:sub_02924F
	jsl	f:sub_02C334
	jsr	a:sub_0295CD
	rtl

sub_02924F:
	lda	$22,x
	bne	loc_029256
	inc	$22,x
	rtl
loc_029256:
	ldy	a:$10DE,x
	lda	a:data_05D166,y
	cmp	$20,x
	beq	loc_029264
	sta	$20,x
	stz	$22,x
loc_029264:
	rtl

sub_029265:
	lda	#$0002
	cmp	$12,x
	beq	loc_029270
	sta	$12,x
	stz	$24,x
loc_029270:
	jsl	f:sub_02927F
	jsl	f:sub_02C334
	jsr	a:sub_0295CD
	jml	f:loc_0296E9

sub_02927F:
	inc	$24,x
	lda	$22,x
	bne	loc_029288
	inc	$22,x
	rtl
loc_029288:
	lda	$24,x
	and	#$0004
	ora	a:$10DE,x
	tay
	lda	a:data_05D16A,y
	cmp	$20,x
	beq	loc_02929C
	sta	$20,x
	stz	$22,x
loc_02929C:
	rtl

sub_02929D:
	lda	#$0006
	cmp	$12,x
	beq	loc_0292BA
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0004
	sta	$24,x
	lda	#$0001
	sta	a:$0640,x
	stz	a:$064A,x
loc_0292BA:
	lda	$24,x
	beq	loc_0292C2
	dec	$24,x
	bra	loc_0292D3
loc_0292C2:
	stz	a:$0640,x
	jsr	a:sub_029102
	bcs	loc_0292CC
	bra	loc_0292D3
loc_0292CC:
	lda	a:$066C,x
	bit	zp_88
	bne	sub_0292F2
loc_0292D3:
	jsl	f:sub_0292DF
	jsl	f:sub_02C334
	jsr	a:sub_0295CD
	rtl

sub_0292DF:
	lda	$22,x
	bne	loc_0292E6
	inc	$22,x
	rtl
loc_0292E6:
	lda	#$0005
	cmp	$20,x
	beq	loc_0292F1
	sta	$20,x
	stz	$22,x
loc_0292F1:
	rtl

sub_0292F2:
	lda	#$0007
	cmp	$12,x
	beq	loc_02930D
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0001
	sta	a:$0640,x
	sta	a:$064A,x
	sta	a:$065A,x
loc_02930D:
	jsr	a:sub_029102
	bcc	loc_029319
	lda	a:$066C,x
	bit	zp_88
	bne	loc_02931C
loc_029319:
	stz	a:$065A,x
loc_02931C:
	lda	a:$065A,x
	bne	loc_029332
	lda	a:$0654,x
	clc
	adc	a:$0658,x
	and	#$00FF
	cmp	$04,x
	bne	loc_029332
	brl	sub_02929D
loc_029332:
	jsr	a:sub_029342
	jsl	f:sub_02C334
	jsr	a:sub_0295CD
	jsr	a:sub_02966C
	jmp	a:loc_0296B1

sub_029342:
	lda	$22,x
	bne	loc_029349
	inc	$22,x
	rts
loc_029349:
	lda	#$0006
	cmp	$20,x
	beq	loc_029354
	sta	$20,x
	stz	$22,x
loc_029354:
	rts

sub_029355:
	lda	a:$066C,x
	bit	zp_88
	bne	sub_029376
	lda	#$0003
	cmp	$12,x
	beq	loc_029365
	sta	$12,x
loc_029365:
	jsr	a:sub_029648
	jsl	f:sub_02C334
	jsr	a:sub_029504
	jsr	a:sub_0295CD
	jsr	a:sub_029629
	rtl

sub_029376:
	lda	#$0004
	cmp	$12,x
	beq	loc_02937F
	sta	$12,x
loc_02937F:
	jsr	a:sub_029648
	jsl	f:sub_02C334
	jsr	a:sub_029504
	jsr	a:sub_0295CD
	jsr	a:sub_029629
	jml	f:loc_0296E9

sub_029393:
	lda	#$0008
	cmp	$12,x
	beq	loc_0293B9
	pha
	jsr	a:sub_029689
	pla
	sta	$12,x
	lda	#$003F
	jsl	f:sub_00868F
	lda	#$0020
	jsl	f:sub_1DAD8A
	stz	$24,x
	lda	#$0001
	sta	a:$064A,x
	stz	$16,x
loc_0293B9:
	lda	$24,x
	cmp	#$0010
	bcc	loc_0293D0
	cmp	#$0080
	bcc	loc_0293C8
	brl	loc_028EE3
loc_0293C8:
	jsl	f:sub_029419
	jsl	f:sub_029431
loc_0293D0:
	inc	$24,x
	jsl	f:sub_029405
	jsl	f:sub_02C334
	jsl	f:sub_029C83
	jsr	a:sub_0295CD
	lda	$22,x
	bne	loc_0293E8
	inc	$22,x
	rtl
loc_0293E8:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	loc_0293F5
	lda	#$0004
loc_0293F5:
	ora	a:$10DE,x
	tay
	lda	a:data_05D172,y
	cmp	$20,x
	beq	loc_029404
	sta	$20,x
	stz	$22,x
loc_029404:
	rtl

sub_029405:
	lda	$24,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	tay
	lda	$04,x
	clc
	adc	a:data_05D17A,y
	and	#$00FF
	sta	$04,x
	rtl

sub_029419:
	lda	$1A,x
	cmp	$18,x
	bne	loc_029429
	cmp	#$FFFF
	bne	loc_029429
	stz	$1A,x
	stz	$18,x
	rtl
loc_029429:
	lda	$1A,x
	asl	a
	ror	$1A,x
	ror	$18,x
	rtl

sub_029431:
	lda	$1E,x
	cmp	$1C,x
	bne	loc_029441
	cmp	#$FFFF
	bne	loc_029441
	stz	$1E,x
	stz	$1C,x
	rtl
loc_029441:
	lda	$1E,x
	asl	a
	ror	$1E,x
	ror	$1C,x
	rtl

sub_029449:
	lda	#$0009
	cmp	$12,x
	beq	loc_029477
	pha
	jsr	a:sub_029689
	pla
	sta	$12,x
	lda	#$0043
	jsl	f:sub_00868F
	stz	$24,x
	stz	a:$064A,x
	stz	$16,x
	lda	$02,x
	and	#$CFFF
	ora	#$1000
	sta	$02,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
loc_029477:
	lda	$24,x
	cmp	#$0010
	bcc	loc_029486
	cmp	#$0080
	bcc	loc_029486
	brl	loc_028EE3
loc_029486:
	inc	$24,x
	jsr	a:sub_0294DB
	jsl	f:sub_02C334
	jsl	f:sub_029C83
	jsr	a:sub_0295CD
	jsr	a:sub_0294E7
	jsr	a:sub_0294B7
	lda	a:title_menu_cursor
	beq	loc_0294A4
	dec	a
	bne	loc_0294B6
loc_0294A4:
	lda	$24,x
	cmp	#$0020
	bcc	loc_0294B6
	lsr	a
	bcs	loc_0294B6
	lda	a:$10F4,x
	beq	loc_0294B6
	dec	a:$10F4,x
loc_0294B6:
	rtl

sub_0294B7:
	lda	$22,x
	bne	loc_0294BE
	inc	$22,x
	rts
loc_0294BE:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	loc_0294CB
	lda	#$0004
loc_0294CB:
	ora	a:$10DE,x
	tay
	lda	a:data_05D18C,y
	cmp	$20,x
	beq	loc_0294DA
	sta	$20,x
	stz	$22,x
loc_0294DA:
	rts

sub_0294DB:
	lda	$04,x
	clc
	adc	#$0002
	and	#$00FF
	sta	$04,x
	rts

sub_0294E7:
	lda	a:title_menu_cursor
	beq	loc_0294EF
	dec	a
	bne	loc_029503
loc_0294EF:
	lda	a:$10D4,x
	sec
	sbc	#$0004
	sta	a:$10D4,x
	lda	a:$10D6,x
	sec
	sbc	#$0004
	sta	a:$10D6,x
loc_029503:
	rts

sub_029504:
	ldy	a:$10CE,x
	bne	loc_029532
	jsr	a:sub_029533
	lda	a:$066C,x
	bit	#$0800
	beq	loc_029519
	jsr	a:sub_02955D
	bra	loc_029521
loc_029519:
	bit	#$0400
	beq	loc_029521
	jsr	a:sub_029572
loc_029521:
	lda	a:$066C,x
	bit	#$0100
	beq	loc_02952B
	bra	loc_029595
loc_02952B:
	bit	#$0200
	beq	loc_029532
	bra	loc_0295B1
loc_029532:
	rts

sub_029533:
	lda	a:$0654,x
	asl	a
	tay
	sep	#$20
	.a8
	lda	#$07
	pha
	plb
	rep	#$20
	.a16
	lda	a:data_079198,y
	sta	zp_1A
	lda	a:data_079418,y
	sta	zp_18
	lda	a:data_079118,y
	sta	zp_1E
	lda	a:data_079398,y
	sta	zp_1C
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts

sub_02955D:
	lda	zp_18
	sta	$18,x
	lda	zp_1A
	sta	$1A,x
	lda	zp_1C
	sta	$1C,x
	lda	zp_1E
	sta	$1E,x
	jsl	f:sub_029C83
	rts

sub_029572:
	sec
	lda	#$0000
	sbc	zp_18
	sta	$18,x
	lda	#$0000
	sbc	zp_1A
	sta	$1A,x
	sec
	lda	#$0000
	sbc	zp_1C
	sta	$1C,x
	lda	#$0000
	sbc	zp_1E
	sta	$1E,x
	jsl	f:sub_029C83
	rts
loc_029595:
	sec
	lda	#$0000
	sbc	zp_1C
	sta	$18,x
	lda	#$0000
	sbc	zp_1E
	sta	$1A,x
	lda	zp_18
	sta	$1C,x
	lda	zp_1A
	sta	$1E,x
	jsl	f:sub_029C83
	rts
loc_0295B1:
	lda	zp_1C
	sta	$18,x
	lda	zp_1E
	sta	$1A,x
	sec
	lda	#$0000
	sbc	zp_18
	sta	$1C,x
	lda	#$0000
	sbc	zp_1A
	sta	$1E,x
	jsl	f:sub_029C83
	rts

sub_0295CD:
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	loc_0295E2
	; (not executed in the CDL traces)
	jsr	a:sub_028FBB
	lda	a:$0012,y
	beq	loc_0295E2
	jsr	a:sub_0295E3
	jsr	a:sub_029606
loc_0295E2:
	rts

sub_0295E3:
	; (not executed in the CDL traces)
	lda	a:$000A,y
	sec
	sbc	#$0090
	cmp	$0A,x
	bpl	loc_0295FF
	clc
	adc	#$0120
	cmp	$0A,x
	bmi	loc_0295F8
	bne	loc_0295FE
loc_0295F8:
	dec	a
	sta	$0A,x
	stz	a:$0672,x
loc_0295FE:
	rts
loc_0295FF:
	inc	a
	sta	$0A,x
	stz	a:$0672,x
	rts

sub_029606:
	; (not executed in the CDL traces)
	lda	a:$000E,y
	sec
	sbc	#$0058
	cmp	$0E,x
	bpl	loc_029622
	clc
	adc	#$00B0
	cmp	$0E,x
	bmi	loc_02961B
	bne	loc_029621
loc_02961B:
	dec	a
	sta	$0E,x
	stz	a:$0672,x
loc_029621:
	rts
loc_029622:
	inc	a
	sta	$0E,x
	stz	a:$0672,x
	rts

sub_029629:
	inc	$24,x
	lda	$22,x
	bne	loc_029632
	inc	$22,x
	rts
loc_029632:
	lda	$24,x
	lsr	a
	and	#$000C
	ora	a:$10DE,x
	tay
	lda	a:data_05D194,y
	cmp	$20,x
	beq	loc_029647
	sta	$20,x
	stz	$22,x
loc_029647:
	rts

sub_029648:
	lda	a:$066C,x
	bit	zp_96
	bne	loc_029654
	bit	zp_94
	bne	loc_029660
	rts
loc_029654:
	lda	$04,x
	clc
	adc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts
loc_029660:
	lda	$04,x
	sec
	sbc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts

sub_02966C:
	lda	a:$0656,x
	bne	loc_02967D
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rts
loc_02967D:
	; (not executed in the CDL traces)
	lda	$04,x
	sec
	sbc	#$0008
	and	#$00FF
	sta	$04,x
	rts

sub_029689:
	lda	$12,x
	cmp	#$0008
	beq	loc_0296B0
	cmp	#$0009
	beq	loc_0296B0
	dec	a:$10CA,x
	bpl	loc_02969D
	; (not executed in the CDL traces)
	stz	a:$10CA,x
loc_02969D:
	lda	a:$10C2,x
	beq	loc_0296A5
	stz	a:$10C6,x
loc_0296A5:
	lda	a:$10C0,x
	beq	loc_0296AD
	stz	a:$10C4,x
loc_0296AD:
	stz	a:$10C8,x
loc_0296B0:
	rts
loc_0296B1:
	stz	zp_14
	lda	#$0040
	sta	zp_12
	lda	#$003C
	sta	zp_10
	ldy	#$001E
	jsl	f:sub_0296F8
	lda	#$0002
	sta	zp_14
	lda	#$00C0
	sta	zp_12
	lda	#$00C4
	sta	zp_10
	ldy	#$001E
	bra	sub_0296F8

sub_0296D8:
	stz	zp_12
	ldy	a:$10DE,x
	sty	zp_14
	lda	a:data_05D1A8,y
	sta	zp_10
	ldy	#$0020
	bra	sub_0296F8
loc_0296E9:
	stz	zp_12
	ldy	a:$10DE,x
	sty	zp_14
	lda	a:data_05D1A4,y
	sta	zp_10
	ldy	#$0018

sub_0296F8:
	jsr	a:sub_02971E
	lda	a:$10C4,x
	ldy	zp_14
	beq	loc_029705
	lda	a:$10C6,x
loc_029705:
	phx
	asl	a
	tax
	lda	f:tbl_029712,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_029712:
	.addr	sub_029744
	.addr	sub_02977C
	.addr	sub_02987B
	.addr	sub_0297D8
	.addr	sub_02983C
	.addr	sub_02980A

sub_02971E:
	lda	$04,x
	clc
	adc	zp_12
	and	#$00FF
	sta	zp_1A
	lda	$04,x
	clc
	adc	zp_10
	jsl	f:sub_1DACA4
	lda	zp_08
	sta	zp_0C
	clc
	adc	$0A,x
	sta	zp_1C
	lda	zp_0A
	sta	zp_0E
	clc
	adc	$0E,x
	sta	zp_1E
	rts

sub_029744:
	lda	a:$0646,x
	lsr	a
	bcs	loc_029750
	jsl	f:sub_0298CC
	bcc	loc_029751
loc_029750:
	rtl
loc_029751:
	lda	a:$0646,x
	and	#$0003
	bne	loc_029760
	lda	#$0004
	jsl	f:sub_00868F
loc_029760:
	lda	#$0000
	sta	a:$0012,y
	lda	#$0002
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	rtl

sub_02977C:
	lda	a:$0646,x
	and	#$0003
	beq	loc_029785
loc_029784:
	rtl
loc_029785:
	jsl	f:sub_0298CC
	bcs	loc_029784
	lda	a:$0646,x
	and	#$0007
	bne	loc_02979A
	lda	#$0009
	jsl	f:sub_00868F
loc_02979A:
	lda	#$0005
	sta	zp_18
loc_02979F:
	lda	#$0000
	sta	a:$0012,y
	lda	#$0003
	sta	a:$0010,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	lda	rng_lo
	and	#$0008
	clc
	adc	zp_18
	asl	a
	phy
	tay
	lda	a:data_05D1AA,y
	ply
	clc
	adc	zp_1A
	and	#$00FF
	sta	a:$0004,y
	dec	zp_18
	beq	loc_0297D7
	jsl	f:sub_0298CC
	bcc	loc_02979F
loc_0297D7:
	rtl

sub_0297D8:
	lda	a:$0646,x
	and	#$0003
	bne	loc_0297E6
	jsl	f:sub_0298CC
	bcc	loc_0297E7
loc_0297E6:
	rtl
loc_0297E7:
	lda	#$0008
	jsl	f:sub_00868F
	lda	#$0000
	sta	a:$0012,y
	lda	#$0005
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	rtl

sub_02980A:
	jsl	f:sub_0298CC
	bcc	loc_029811
	rtl
loc_029811:
	lda	a:$0646,x
	and	#$000F
	bne	loc_029820
	lda	#$0005
	jsl	f:sub_00868F
loc_029820:
	lda	#$0000
	sta	a:$0012,y
	lda	#$0006
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_10
	sta	a:$001A,y
	lda	zp_12
	sta	a:$000C,y
	rtl

sub_02983C:
	jsl	f:sub_02990A
	bcc	loc_029858
	jsl	f:sub_0298CC
	bcc	loc_029849
	; (not executed in the CDL traces)
	rtl
loc_029849:
	jsr	a:sub_02986B
	lda	#$0000
	sta	a:$0012,y
	lda	#$0007
	sta	a:$0010,y
loc_029858:
	jsr	a:sub_02986B
	lda	zp_1A
	sta	a:$0014,y
	lda	zp_1C
	sta	a:$0008,y
	lda	zp_1E
	sta	a:$000C,y
	rtl

sub_02986B:
	lda	a:$0646,x
	and	#$000F
	bne	loc_02987A
	lda	#$000A
	jsl	f:sub_00868F
loc_02987A:
	rts

sub_02987B:
	lda	a:$0646,x
	and	#$0001
	bne	loc_029889
	jsl	f:sub_029953
	bcc	loc_02988A
loc_029889:
	rtl
loc_02988A:
	lda	#$0007
	jsl	f:sub_00868F
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0000,y
	lda	#$0008
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	lda	zp_02
	sta	a:$001A,y
	phy
	tay
	lda	#$FFFF
	sta	a:$0010,y
	ply
	lda	zp_04
	sta	a:$001E,y
	phy
	tay
	lda	#$FFFF
	sta	a:$0010,y
	ply
	rtl

sub_0298CC:
	lda	zp_14
	bne	loc_0298E5
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_0298E1
	ldy	#$0700
	lda	#$0840
loc_0298E1:
	sta	zp_FA
	bra	loc_0298F8
loc_0298E5:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_0298F6
	ldy	#$0840
	lda	#$0980
loc_0298F6:
	sta	zp_FA
loc_0298F8:
	lda	a:$0010,y
	bne	loc_0298FF
	clc
	rtl
loc_0298FF:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	loc_0298F8
	rtl

sub_02990A:
	lda	zp_14
	bne	loc_029923
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_02991F
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
loc_02991F:
	sta	zp_FA
	bra	loc_029936
loc_029923:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_029934
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
loc_029934:
	sta	zp_FA
loc_029936:
	lda	a:$0010,y
	cmp	#$0007
	bne	loc_029948
	lda	a:$0012,y
	cmp	#$000E
	bne	loc_029948
	clc
	rtl
loc_029948:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	loc_029936
	rtl

sub_029953:
	lda	zp_14
	bne	loc_02996C
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_029968
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
loc_029968:
	sta	zp_FA
	bra	loc_02997F
loc_02996C:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_02997D
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
loc_02997D:
	sta	zp_FA
loc_02997F:
	phx
	ldx	#$0006
loc_029983:
	lda	a:$0010,y
	bne	loc_029991
	dex
	dex
	sty	$00,x
	bne	loc_029991
	clc
	plx
	rtl
loc_029991:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	loc_029983
	plx
	rtl

sub_02999D:
	lda	zp_78
	bit	#$0200
	beq	loc_0299AB
	jsl	f:sub_029BA9
	bcc	loc_0299CE
	rtl
loc_0299AB:
	jsl	f:sub_029B94
	bcc	loc_0299B2
loc_0299B1:
	rtl
loc_0299B2:
	jsr	a:sub_029A23
	bcs	loc_0299B1
	ldy	difficulty
	lda	rng_lo
	and	a:data_05D1CC,y
	beq	loc_0299C3
	lda	#$0002
loc_0299C3:
	tay
	lda	a:data_05D1D2,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
loc_0299CE:
	ldx	#$0DC0
	jsr	a:sub_029A23
	bcs	loc_0299DF
	lda	#$000F
	sta	$10,x
	stz	$00,x
	stz	$2E,x
loc_0299DF:
	rtl

sub_0299E0:
	lda	zp_78
	bit	#$0200
	beq	loc_0299EE
	jsl	f:sub_029BA9
	bcc	loc_029A11
	rtl
loc_0299EE:
	jsl	f:sub_029B94
	bcc	loc_0299F5
loc_0299F4:
	rtl
loc_0299F5:
	jsr	a:sub_029A23
	bcs	loc_0299F4
	ldy	difficulty
	lda	rng_lo
	and	a:data_05D1CC,y
	beq	loc_029A06
	lda	#$0002
loc_029A06:
	tay
	lda	a:data_05D1D6,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
loc_029A11:
	ldx	#$0DC0
	jsr	a:sub_029A23
	bcs	loc_029A22
	lda	#$000C
	sta	$10,x
	stz	$00,x
	stz	$2E,x
loc_029A22:
	rtl

sub_029A23:
	jsr	a:sub_029A49
	bcs	loc_029A48
	lda	rng_lo
	and	#$00FF
	asl	a
	tay
	lda	a:data_05D25A,y
	clc
	adc	zp_FC
	sta	$0A,x
	lda	a:data_05D1DA,y
	clc
	adc	zp_FE
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	jsl	f:sub_02C086
loc_029A48:
	rts

sub_029A49:
	lda	a:title_menu_cursor
	bne	loc_029A61
	lda	a:p1_lives
	bne	loc_029A55
	; (not executed in the CDL traces)
	sec
	rts
loc_029A55:
	lda	a:wram_0ECA
	sta	zp_FC
	lda	a:wram_0ECE
	sta	zp_FE
	clc
	rts
loc_029A61:
	lda	zp_E9
	lsr	a
	bcs	loc_029A7E
loc_029A66:
	lda	a:p1_lives
	bne	loc_029A72
	; (not executed in the CDL traces)
	lda	a:p2_lives
	bne	loc_029A7E
	sec
	rts
loc_029A72:
	lda	a:wram_0ECA
	sta	zp_FC
	lda	a:wram_0ECE
	sta	zp_FE
	clc
	rts
loc_029A7E:
	lda	a:p2_lives
	bne	loc_029A8A
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	loc_029A66
	sec
	rts
loc_029A8A:
	lda	a:wram_0F0A
	sta	zp_FC
	lda	a:wram_0F0E
	sta	zp_FE
	clc
	rts

sub_029A96:
	lda	a:title_menu_cursor
	bne	loc_029AA2
	lda	a:p1_lives
	bne	loc_029AE0
	; (not executed in the CDL traces)
	sec
	rtl
loc_029AA2:
	lda	a:p1_lives
	beq	loc_029AFF
	lda	a:p2_lives
	beq	loc_029AF8
	lda	a:wram_0ECA
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:wram_0ECE
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DAD3C
	sta	zp_18
	lda	a:wram_0F0A
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:wram_0F0E
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DAD3C
	cmp	zp_18
	bne	loc_029ADE
	lda	zp_78
	xba
	lsr	a
loc_029ADE:
	bcc	loc_029AEC
loc_029AE0:
	lda	a:wram_0ECA
	sta	zp_18
	lda	a:wram_0ECE
	sta	zp_1A
	clc
	rtl
loc_029AEC:
	lda	a:wram_0F0A
	sta	zp_18
	lda	a:wram_0F0E
	sta	zp_1A
	clc
	rtl
loc_029AF8:
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	loc_029AE0
	sec
	rtl
loc_029AFF:
	lda	a:p2_lives
	bne	loc_029AEC
	sec
	rtl

sub_029B06:
	jsl	f:sub_029A96
	bcc	loc_029B0D
	; (not executed in the CDL traces)
	rtl
loc_029B0D:
	lda	zp_18
	sec
	sbc	$0A,x
	sta	zp_08
	lda	zp_1A
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	clc
	rtl

sub_029B21:
	phx
	phy
	phb
	lda	#$0000
	sta	f:$000000,x
	txy
	iny
	lda	#$003E
	mvn	#$00, #$00
	plb
	ply
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_029B37:
	; (not executed in the CDL traces)
	phx
	phy
	phb
	tyx
	lda	#$0000
	sta	f:$000000,x
	iny
	lda	#$003E
	mvn	#$00, #$00
	plb
	ply
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_029B4D:
	; (not executed in the CDL traces)
	phx
	phb
	ldx	#$1900
	sta	f:$7E0000,x
	txy
	iny
	iny
	lda	#$01FD
	mvn	#$7E, #$7E
	plb
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_029B62:
	; (not executed in the CDL traces)
	ldx	#$0D40
loc_029B65:
	lda	$10,x
	bne	loc_029B6B
	clc
	rtl
loc_029B6B:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_029B65
	rtl

sub_029B77:
	lda	$2E,x
	bit	#$0010
	bne	loc_029B88
	bit	#$0020
	beq	loc_029B92
	ldy	#$0D80
	bra	loc_029B8B
loc_029B88:
	ldy	#$0D40
loc_029B8B:
	lda	a:$0010,y
	bne	loc_029B92
	clc
	rtl
loc_029B92:
	sec
	rtl

sub_029B94:
	ldx	#$0DC0
loc_029B97:
	lda	$10,x
	bne	loc_029B9D
	clc
	rtl
loc_029B9D:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_029B97
	rtl

sub_029BA9:
	phx
	ldx	#$0DC0
loc_029BAD:
	lda	$10,x
	beq	loc_029BB4
	plx
	sec
	rtl
loc_029BB4:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_029BAD
	plx
	clc
	rtl

sub_029BC2:
	ldy	#$0300
loc_029BC5:
	lda	a:$0010,y
	bne	loc_029BCC
	clc
	rtl
loc_029BCC:
	tya
	clc
	adc	#$0020
	tay
	cpy	#$0480
	bcc	loc_029BC5
	rtl

sub_029BD8:
	ldy	#$0980
loc_029BDB:
	lda	a:$0010,y
	bne	loc_029BE2
	clc
	rtl
loc_029BE2:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0AC0
	bcc	loc_029BDB
	rtl

sub_029BEE:
	lda	$2A,x
	beq	loc_029C04
	cmp	#$0004
	bne	loc_029BFA
	jsr	a:sub_029C3C
loc_029BFA:
	dec	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_029C03:
	rtl
loc_029C04:
	lda	$2E,x
	bit	#$0040
	beq	loc_029C03
	and	#$FFBF
	sta	$2E,x
	lda	#$0004
	sta	$2A,x
	lda	#$0010
	jsl	f:sub_00868F
	phx
	phb
	ldx	zp_02
	lda	#$7FFF
	sta	f:$7E0000,x
	txy
	iny
	iny
	lda	zp_04
	dec	a
	dec	a
	dec	a
	mvn	#$7E, #$7E
	plb
	plx
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	rtl

sub_029C3C:
	phx
	phb
	ldx	zp_00
	ldy	zp_02
	lda	zp_04
	mvn	#$08, #$7E
	plb
	plx
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	rts

sub_029C51:
	pha
	jsl	f:sub_029B06
	ply
	sty	zp_FA
	bcs	loc_029C7E
	sec
	sbc	$04,x
	beq	loc_029C7D
	bit	#$0080
	bne	loc_029C71
	lda	$04,x
	clc
	adc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
loc_029C71:
	lda	$04,x
	sec
	sbc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
loc_029C7D:
	sec
loc_029C7E:
	rtl

sub_029C7F:
	jsl	f:sub_1DAD8A

sub_029C83:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rtl

sub_029C9E:
	ldx	#$0B40
	bra	loc_029CA6

sub_029CA3:
	ldx	#$0D40
loc_029CA6:
	lda	$10,x
	beq	loc_029CB6
	jsl	f:sub_029CC2
	jsl	f:sub_029D44
	jsl	f:sub_029D88
loc_029CB6:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_029CA6

sub_029CC1:
	rtl

sub_029CC2:
	lda	$10,x
	phx
	asl	a
	tax
	lda	f:tbl_029CD1,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_029CD1:
	.addr	sub_029CC1
	.addr	sub_029F48
	.addr	sub_029EA4
	.addr	sub_02A27E
	.addr	sub_02A3B6
	.addr	sub_02A876
	.addr	sub_02A7A5
	.addr	sub_029CC1
	.addr	sub_029CF9
	.addr	sub_02A0E5
	.addr	sub_02F4B8
	.addr	sub_02F67C
	.addr	sub_02A44C
	.addr	sub_02A55B
	.addr	sub_02A5AF
	.addr	sub_02A682
	.addr	sub_02A01C
	.addr	sub_02A167
	.addr	sub_02A8E5
	.addr	sub_02F5D8

sub_029CF9:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_029D08,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_029D08:
	.addr	sub_029D0C
	.addr	sub_029D31

sub_029D0C:
	lda	#$0008
	sta	$10,x
	lda	#$0009
	sta	$00,x
	lda	#$D45A
	sta	$28,x
	stz	$22,x
	stz	$16,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0001
	sta	$12,x
	rtl

sub_029D31:
	lda	$2E,x
	bit	#$000C
	bne	loc_029D3B
	brl	sub_029B21
loc_029D3B:
	lda	$28,x
	bne	loc_029D43
	jml	f:sub_029B21
loc_029D43:
	rtl

sub_029D44:
	ldy	$28,x
	beq	loc_029D6E
	dec	$22,x
	bmi	loc_029D6F
	bne	loc_029D6E
	tya
	clc
	adc	#$0006
loc_029D53:
	tay
	lda	a:$0000,y
	bmi	loc_029D53
	beq	loc_029D74
	sty	$28,x
loc_029D5D:
	sta	$22,x
	lda	a:$0002,y
	sta	$20,x
	lda	$02,x
	and	#$3000
	ora	a:$0004,y
	sta	$02,x
loc_029D6E:
	rtl
loc_029D6F:
	lda	a:$0000,y
	bne	loc_029D5D
loc_029D74:
	sta	$22,x
	sta	$28,x
	lda	a:$0002,y
	sta	$20,x
	lda	$02,x
	and	#$3000
	ora	a:$0004,y
	sta	$02,x
	rtl

sub_029D88:
	lda	zp_78
	bit	#$0001
	bne	loc_029DAB
	lda	$2A,x
	bne	loc_029DAC
	lda	$2E,x
	bit	#$0040
	beq	loc_029DAB
	and	#$FFBF
	sta	$2E,x
	lda	$02,x
	sta	$2A,x
	and	#$3000
	ora	#$0600
	sta	$02,x
loc_029DAB:
	rtl
loc_029DAC:
	lda	$2A,x
	sta	$02,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rtl

sub_029DBA:
	lda	$2A,x
	bne	loc_029DCC
	lda	$2E,x
	bit	#$0040
	beq	loc_029DCC
	lda	#$0010
	jsl	f:sub_00868F
loc_029DCC:
	rtl

sub_029DCD:
	jsr	a:sub_029DD9
	bcs	loc_029DD5
	jsr	a:sub_029DF6
loc_029DD5:
	jsr	a:sub_029E1F
	rtl

sub_029DD9:
	jsl	f:sub_029A96
	bcc	loc_029DE0
	; (not executed in the CDL traces)
	rts
loc_029DE0:
	lda	zp_18
	sec
	sbc	$0A,x
	sta	zp_08
	lda	zp_1A
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sta	zp_10
	clc
	rts

sub_029DF6:
	lda	zp_10
	sec
	sbc	$04,x
	xba
	and	#$FF00
	beq	loc_029E15
	bpl	loc_029E0D
	cmp	#$8000
	bne	loc_029E16
	lda	rng_lo
	lsr	a
	bcs	loc_029E16
loc_029E0D:
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
loc_029E15:
	rts
loc_029E16:
	lda	$04,x
	dec	a
	and	#$00FF
	sta	$04,x
	rts

sub_029E1F:
	lda	#$000C
	jsl	f:sub_1DAD8A
	jsl	f:sub_029C83
	jsl	f:sub_02C086
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_029E2F:
	; (not executed in the CDL traces)
	lda	$3C,x
	bne	loc_029E3C
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
	rts
loc_029E3C:
	lda	$04,x
	dec	a
	and	#$00FF
	sta	$04,x
	rts

sub_029E45:
	lda	$2E,x
	bit	#$0003
	beq	loc_029EA3
	phy
	jsl	f:sub_029BC2
	pla
	bcs	loc_029EA3
	pha
	lda	#$0004
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	pla
	phy
	tay
	lda	$04,x
	jsl	f:sub_1DACA4
	ply
	lda	$0A,x
	clc
	adc	zp_08
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_0A
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	lda	$04,x
	sta	a:$0004,y
	phx
	phy
	tyx
	lda	#$0020
	jsl	f:sub_1DAD8A
	ply
	plx
	lda	#$FFFF
	sta	a:$0004,y
loc_029EA3:
	rtl

sub_029EA4:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_029EB3,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_029EB3:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_029EEB
	.addr	sub_029F24
	.addr	sub_029F45

sub_029EBD:
	lda	$2E,x
	bit	#$0003
	beq	loc_029EC7
	brl	sub_029B21
loc_029EC7:
	stz	$3E,x
	stz	$3C,x
	stz	$00,x
	stz	$20,x
	stz	$28,x
	stz	$02,x
	stz	$2A,x
	stz	$16,x
	stz	$08,x
	stz	$0C,x
	inc	$12,x
	rtl

sub_029EDE:
	lda	$2E,x
	bit	#$0003
	beq	loc_029EE8
	brl	sub_029B21
loc_029EE8:
	inc	$12,x
	rtl

sub_029EEB:
	lda	$00,x
	bne	loc_029F0A
	ldy	difficulty
	lda	a:data_05D4A2,y
	sta	$06,x
	lda	#$0006
	sta	$00,x
	lda	#$D4A8
	sta	$28,x
	lda	#$2000
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_029F0A:
	dec	$24,x
	bpl	loc_029F11
	brl	sub_029B21
loc_029F11:
	lda	$2E,x
	bit	#$0003
	bne	loc_029F1D
	jsl	f:sub_029DCD
	rtl
loc_029F1D:
	lda	#$A000
	sta	$16,x
	inc	$12,x

sub_029F24:
	lda	$06,x
	bmi	loc_029F37
	lda	$2E,x
	bit	#$000C
	bne	loc_029F32
	brl	sub_029B21
loc_029F32:
	jsl	f:sub_029DCD
	rtl
loc_029F37:
	stz	$06,x
	lda	#$000B
	jsl	f:sub_00868F
	lda	#$0004
	sta	$12,x

sub_029F45:
	brl	sub_029D0C

sub_029F48:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_029F57,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_029F57:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_029F61
	.addr	sub_029FA7
	.addr	sub_029FD8

sub_029F61:
	lda	$00,x
	bne	loc_029F80
	ldy	difficulty
	lda	a:data_05D4C2,y
	sta	$06,x
	lda	#$0006
	sta	$00,x
	lda	#$D4E0
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_029F80:
	dec	$24,x
	bpl	loc_029F87
	brl	sub_029B21
loc_029F87:
	lda	$2E,x
	bit	#$0003
	bne	loc_029F93
	jsl	f:sub_029DCD
	rtl
loc_029F93:
	lda	#$A000
	sta	$16,x
	lda	#$D4E0
	sta	$28,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_029FA7:
	lda	$2E,x
	bit	#$000C
	bne	loc_029FB1
	brl	sub_029B21
loc_029FB1:
	lda	$06,x
	bmi	loc_02A012
	dec	$24,x
	bpl	loc_029FC3
	inc	$24,x
	jsl	f:sub_029B06
	cmp	$04,x
	beq	loc_029FC8
loc_029FC3:
	jsl	f:sub_029DCD
	rtl
loc_029FC8:
	lda	#$0001
	sta	$20,x
	stz	$28,x
	ldy	difficulty
	lda	a:data_05D4C8,y
	sta	$24,x
	inc	$12,x

sub_029FD8:
	lda	$2E,x
	bit	#$000C
	bne	loc_029FE2
	brl	sub_029B21
loc_029FE2:
	lda	$06,x
	bmi	loc_02A012
	dec	$24,x
	bpl	loc_029FFB
	inc	$24,x
	jsl	f:sub_029B06
	cmp	$04,x
	bne	loc_029F93
	ldy	difficulty
	lda	a:data_05D4C8,y
	sta	$24,x
loc_029FFB:
	ldy	difficulty
	lda	a:data_05D4C8,y
	lsr	a
	cmp	$24,x
	bne	loc_02A011
	jsl	f:sub_02A21A
	lda	#$D4CE
	sta	$28,x
	stz	$22,x
	rtl
loc_02A011:
	rtl
loc_02A012:
	lda	#$000B
	jsl	f:sub_00868F
	jmp	a:sub_029D0C

sub_02A01C:
	lda	$06,x
	bpl	loc_02A023
	brl	loc_02A0D4
loc_02A023:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A030
	brl	sub_029B21
loc_02A030:
	cmp	#$0003
	bne	loc_02A038
	brl	loc_02A077
loc_02A038:
	cmp	#$0004
	bne	loc_02A040
	brl	loc_02A0C3
loc_02A040:
	cmp	#$0005
	bne	loc_02A048
	brl	loc_02A0D4
loc_02A048:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A057,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A057:
	.addr	sub_02A061
	.addr	sub_02A076
	.addr	sub_02A099
	.addr	sub_02A0D3
	.addr	sub_02A0E2

sub_02A061:
	stz	$06,x
	stz	$16,x
	lda	#$0006
	sta	$00,x
	stz	$20,x
	stz	$28,x
	lda	#$1200
	sta	$02,x
	inc	$12,x
	rtl

sub_02A076:
	rtl
loc_02A077:
	lda	$12,x
	cmp	#$0002
	beq	sub_02A099
	ldy	difficulty
	lda	a:data_05D4DA,y
	sta	$06,x
	lda	#$A000
	sta	$16,x
	lda	#$D4E0
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

sub_02A099:
	jsl	f:sub_029B06
	ldy	difficulty
	clc
	adc	a:data_05D500,y
	sec
	sbc	$04,x
	cmp	a:data_05D4FA,y
	bcc	loc_02A0B5
	ldy	difficulty
	lda	a:data_05D4FA,y
	jsl	f:sub_029C51
	rtl
loc_02A0B5:
	ldy	difficulty
	lda	zp_78
	and	a:data_05D506,y
	bne	loc_02A0C2
	jsl	f:sub_02A21A
loc_02A0C2:
	rtl
loc_02A0C3:
	lda	#$1000
	sta	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	lda	#$0003
	sta	$12,x

sub_02A0D3:
	rtl
loc_02A0D4:
	stz	$06,x
	lda	#$000B
	jsl	f:sub_00868F
	lda	#$0004
	sta	$12,x

sub_02A0E2:
	brl	sub_029D0C

sub_02A0E5:
	lda	$06,x
	bpl	loc_02A0EC
	brl	loc_02A0D4
loc_02A0EC:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A0F9
	brl	sub_029B21
loc_02A0F9:
	cmp	#$0003
	bne	loc_02A101
	brl	loc_02A12A
loc_02A101:
	cmp	#$0004
	bne	loc_02A109
	brl	loc_02A0C3
loc_02A109:
	cmp	#$0005
	bne	loc_02A111
	; (not executed in the CDL traces)
	brl	loc_02A0D4
loc_02A111:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A120,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A120:
	.addr	sub_02A061
	.addr	sub_02A076
	.addr	sub_02A14C
	.addr	sub_02A0D3
	.addr	sub_02A0E2
loc_02A12A:
	lda	$12,x
	cmp	#$0002
	beq	sub_02A14C
	ldy	difficulty
	lda	a:data_05D4DA,y
	sta	$06,x
	lda	#$A000
	sta	$16,x
	lda	#$D4E0
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

sub_02A14C:
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05D50C,y
	and	#$00FF
	sta	$04,x
	ldy	difficulty
	lda	zp_78
	and	a:data_05D512,y
	bne	loc_02A166
	jsl	f:sub_02A21A
loc_02A166:
	rtl

sub_02A167:
	lda	$06,x
	bpl	loc_02A16E
	brl	loc_02A0D4
loc_02A16E:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A17B
	brl	sub_029B21
loc_02A17B:
	cmp	#$0003
	bne	loc_02A183
	brl	loc_02A1AC
loc_02A183:
	cmp	#$0004
	bne	loc_02A18B
	brl	loc_02A0C3
loc_02A18B:
	cmp	#$0005
	bne	loc_02A193
	brl	loc_02A0D4
loc_02A193:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A1A2,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A1A2:
	.addr	sub_02A061
	.addr	sub_02A076
	.addr	sub_02A1D0
	.addr	sub_02A0D3
	.addr	sub_02A0E2
loc_02A1AC:
	lda	$12,x
	cmp	#$0002
	beq	sub_02A1D0
	ldy	difficulty
	lda	a:data_05D4DA,y
	sta	$06,x
	lda	#$A000
	sta	$16,x
	lda	#$D4E0
	sta	$28,x
	stz	$24,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

sub_02A1D0:
	ldy	difficulty
	lda	$24,x
	clc
	adc	a:data_05D518,y
	and	#$00FF
	sta	$24,x
	ldy	difficulty
	lda	zp_78
	and	a:data_05D524,y
	bne	loc_02A1EA
	jsl	f:sub_02A21A
loc_02A1EA:
	jsr	a:sub_02A1EE
	rtl

sub_02A1EE:
	ldy	difficulty
	lda	$24,x
	clc
	adc	#$0040
	sec
	sbc	a:data_05D518,y
	and	#$00FF
	bit	#$0080
	bne	loc_02A20E
	lda	$04,x
	clc
	adc	a:data_05D51E,y
	and	#$00FF
	sta	$04,x
	rts
loc_02A20E:
	lda	$04,x
	sec
	sbc	a:data_05D51E,y
	and	#$00FF
	sta	$04,x
	rts

sub_02A21A:
	lda	$2E,x
	bit	#$0003
	beq	loc_02A27D
	jsl	f:sub_029BC2
	bcs	loc_02A27D
	lda	#$0004
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	phy
	ldy	#$0012
	lda	$04,x
	clc
	adc	#$FFEC
	jsl	f:sub_1DACA4
	lda	zp_08
	sta	zp_FC
	lda	zp_0A
	sta	zp_FE
	ply
	lda	$0A,x
	clc
	adc	zp_FC
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_FE
	sta	a:$000E,y
	lda	$04,x
	sta	a:$0004,y
	lda	#$0020
	jsl	f:sub_1DAD80
	lda	#$FFFF
	sta	a:$0004,y
loc_02A27D:
	rtl

sub_02A27E:
	; (not executed in the CDL traces)
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A28D,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A28D:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_02A297
	.addr	sub_02A2FA
	.addr	sub_02A31E

sub_02A297:
	; (not executed in the CDL traces)
	lda	$00,x
	bne	loc_02A2BB
	ldy	difficulty
	lda	a:data_05D52A,y
	sta	$06,x
	lda	#$0004
	sta	a:wram_0E10
	sta	a:wram_0E50
	sta	a:wram_0E90
	lda	#$2400
	sta	$02,x
	lda	#$D530
	sta	$28,x
	jsr	a:sub_02A2D1
loc_02A2BB:
	dec	$24,x
	bpl	loc_02A2C2
	brl	loc_02A39A
loc_02A2C2:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A2F3
	jsl	f:sub_029DCD
	jsr	a:sub_02A339
	rtl

sub_02A2D1:
	; (not executed in the CDL traces)
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$1870
	sta	a:wram_0E2C
	lda	#$17E0
	sta	a:wram_0E6C
	lda	#$1750
	sta	a:wram_0EAC
	lda	#$0040
	sta	$24,x
	rts
loc_02A2F3:
	lda	#$A000
	sta	$16,x
	inc	$12,x

sub_02A2FA:
	; (not executed in the CDL traces)
	jsr	a:sub_02A377
	bcc	loc_02A302
	brl	loc_02A39A
loc_02A302:
	jsr	a:sub_02A35F
	bcc	loc_02A30A
	brl	loc_02A312
loc_02A30A:
	jsl	f:sub_029DCD
	jsr	a:sub_02A339
	rtl
loc_02A312:
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$0004
	sta	$12,x

sub_02A31E:
	phx
	ldx	#$0E00
	jsl	f:sub_029D0C
	ldx	#$0E40
	jsl	f:sub_029D0C
	ldx	#$0E80
	jsl	f:sub_029D0C
	plx
	jml	f:sub_029D0C

sub_02A339:
	ldy	$2C,x
	lda	$04,x
	jsr	a:sub_02A34D
	lda	$0A,x
	jsr	a:sub_02A34D
	lda	$0E,x
	jsr	a:sub_02A34D
	sty	$2C,x
	rts

sub_02A34D:
	phx
	tyx
	sta	f:$7E0000,x
	iny
	iny
	cpy	#$1B00
	bcc	loc_02A35D
	ldy	#$1900
loc_02A35D:
	plx
	rts

sub_02A35F:
	jsl	f:sub_029DBA
	lda	$06,x
	clc
	adc	a:wram_0E06
	clc
	adc	a:wram_0E46
	clc
	adc	a:wram_0E86
	bpl	loc_02A375
	sec
	rts
loc_02A375:
	clc
	rts

sub_02A377:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A398
	lda	a:wram_0E2E
	bit	#$000C
	bne	loc_02A398
	lda	a:wram_0E6E
	bit	#$000C
	bne	loc_02A398
	lda	a:wram_0EAE
	bit	#$000C
	bne	loc_02A398
	sec
	rts
loc_02A398:
	clc
	rts
loc_02A39A:
	phx
	ldx	#$0E80
	jsl	f:sub_029B21
	ldx	#$0E40
	jsl	f:sub_029B21
	ldx	#$0E00
	jsl	f:sub_029B21
	plx
	jsl	f:sub_029B21
	rtl

sub_02A3B6:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A3C5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A3C5:
	.addr	sub_02A3C9
	.addr	sub_02A3FB

sub_02A3C9:
	lda	#$0007
	sta	$00,x
	lda	#$2400
	sta	$02,x
	lda	#$D530
	sta	$28,x
	lda	a:wram_0DC4
	sta	$04,x
	lda	a:wram_0DCA
	sta	$0A,x
	lda	a:wram_0DCE
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	stz	$2E,x
	stz	$16,x
	stz	$06,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

sub_02A3FB:
	jsl	f:sub_029DBA
	jsr	a:sub_02A40A
	jsr	a:sub_02A41A
	jsl	f:sub_02C086
	rtl

sub_02A40A:
	lda	$2E,x
	bit	#$0003
	beq	loc_02A417
	lda	#$A000
	sta	$16,x
	rts
loc_02A417:
	stz	$16,x
	rts

sub_02A41A:
	ldy	$2C,x
	cpy	#$1900
	bcs	loc_02A428
	tya
	adc	#$0006
	sta	$2C,x
	rts
loc_02A428:
	jsr	a:sub_02A43A
	sta	$04,x
	jsr	a:sub_02A43A
	sta	$0A,x
	jsr	a:sub_02A43A
	sta	$0E,x
	sty	$2C,x
	rts

sub_02A43A:
	phx
	tyx
	lda	f:$7E0000,x
	iny
	iny
	cpy	#$1B00
	bcc	loc_02A44A
	ldy	#$1900
loc_02A44A:
	plx
	rts

sub_02A44C:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A45B,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A45B:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_02A463
	.addr	sub_02A4D0

sub_02A463:
	lda	$00,x
	bne	loc_02A4AB
	ldy	difficulty
	lda	a:data_05D53E,y
	sta	$06,x
	lda	#$000D
	sta	a:wram_0E10
	sta	a:wram_0E50
	sta	a:wram_0E90
	jsl	f:sub_029B06
	sta	$04,x
	lda	#$2E00
	sta	$02,x
	lda	#$D544
	sta	$28,x
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$18AC
	sta	a:wram_0E2C
	lda	#$1858
	sta	a:wram_0E6C
	lda	#$1804
	sta	a:wram_0EAC
	lda	#$0040
	sta	$24,x
loc_02A4AB:
	dec	$24,x
	bpl	loc_02A4B2
	brl	loc_02A39A
loc_02A4B2:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A4C1
	jsl	f:sub_029DCD
	jsr	a:sub_02A339
	rtl
loc_02A4C1:
	lda	#$A000
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02A4D0:
	jsr	a:sub_02A377
	bcc	loc_02A4D8
	brl	loc_02A39A
loc_02A4D8:
	jsr	a:sub_02A35F
	bcc	loc_02A4E0
	brl	loc_02A505
loc_02A4E0:
	lda	a:wram_0E8A
	cmp	$0A,x
	bne	loc_02A4EE
	lda	a:wram_0E8E
	cmp	$0E,x
	beq	loc_02A505
loc_02A4EE:
	dec	$24,x
	bpl	loc_02A4F7
	lda	#$0080
	sta	$24,x
loc_02A4F7:
	lda	#$0002
	jsl	f:sub_029C51
	jsr	a:sub_02A78E
	jsr	a:sub_02A339
	rtl
loc_02A505:
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$000E
	sta	a:wram_0DD0
	sta	a:wram_0E10
	sta	a:wram_0E50
	sta	a:wram_0E90
	stz	a:wram_0DD2
	stz	a:wram_0E12
	stz	a:wram_0E52
	stz	a:wram_0E92
	stz	a:wram_0DC6
	stz	a:wram_0E06
	stz	a:wram_0E46
	stz	a:wram_0E86
	lda	rng_lo
	ldy	#$0DC0
	jsr	a:sub_02A554
	lda	zp_E9
	ldy	#$0E00
	jsr	a:sub_02A554
	lda	rng_hi
	ldy	#$0E40
	jsr	a:sub_02A554
	lda	zp_EB
	ldy	#$0E80
	jsr	a:sub_02A554
	rtl

sub_02A554:
	and	#$00FF
	sta	a:$0038,y
	rts

sub_02A55B:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A56A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A56A:
	.addr	sub_02A56E
	.addr	sub_02A5A0

sub_02A56E:
	lda	#$0007
	sta	$00,x
	lda	#$2E00
	sta	$02,x
	lda	#$D544
	sta	$28,x
	lda	a:wram_0DC4
	sta	$04,x
	lda	a:wram_0DCA
	sta	$0A,x
	lda	a:wram_0DCE
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	stz	$2E,x
	stz	$16,x
	stz	$06,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

sub_02A5A0:
	jsl	f:sub_029DBA
	jsr	a:sub_02A40A
	jsr	a:sub_02A41A
	jsl	f:sub_02C086
	rtl

sub_02A5AF:
	lda	$06,x
	bpl	loc_02A5B6
	brl	loc_02A678
loc_02A5B6:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A5C5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A5C5:
	.addr	sub_02A5CD
	.addr	sub_02A5FB
	.addr	sub_02A625
	.addr	sub_02A665

sub_02A5CD:
	ldy	difficulty
	lda	a:data_05D552,y
	sta	$06,x
	stz	$3E,x
	stz	$3C,x
	stz	$20,x
	stz	$2A,x
	lda	#$A000
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	lda	#$0007
	sta	$00,x
	lda	#$D544
	sta	$28,x
	lda	#$2E00
	sta	$02,x
	lda	#$0020
	sta	$24,x
	inc	$12,x

sub_02A5FB:
	dec	$24,x
	bmi	loc_02A61B
	lda	$04,x
	pha
	lda	$38,x
	sta	$04,x
	lda	$24,x
	jsl	f:sub_1DAD8A
	jsl	f:sub_029C83
	pla
	clc
	adc	#$0010
	and	#$00FF
	sta	$04,x
	rtl
loc_02A61B:
	lda	#$0020
	sta	$24,x
	lda	#$0002
	sta	$12,x

sub_02A625:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A62F
	brl	sub_029B21
loc_02A62F:
	lda	$06,x
	bmi	loc_02A678
	dec	$24,x
	bmi	loc_02A64C
	lda	$24,x
	cmp	#$0010
	bne	loc_02A642
	jsl	f:sub_02A9A6
loc_02A642:
	lda	#$0002
	sta	$22,x
	jsl	f:sub_02C086
	rtl
loc_02A64C:
	lda	#$A000
	sta	$16,x
	txa
	lsr	a
	lsr	a
	lsr	a
	and	#$0018
	clc
	ldy	difficulty
	adc	a:data_05D558,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02A665:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A66F
	brl	sub_029B21
loc_02A66F:
	dec	$24,x
	bmi	loc_02A61B
	jsl	f:sub_029DCD
	rtl
loc_02A678:
	lda	#$0030
	jsl	f:sub_00868F
	jmp	a:sub_029D0C

sub_02A682:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A691,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A691:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_02A69D
	.addr	sub_02A70A
	.addr	sub_02A72C
	.addr	sub_02A773

sub_02A69D:
	lda	$00,x
	bne	loc_02A6E5
	ldy	difficulty
	lda	a:data_05D55E,y
	sta	$06,x
	lda	#$0004
	sta	a:wram_0E10
	sta	a:wram_0E50
	sta	a:wram_0E90
	jsl	f:sub_029B06
	sta	$04,x
	lda	#$2400
	sta	$02,x
	lda	#$D530
	sta	$28,x
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$18AC
	sta	a:wram_0E2C
	lda	#$1858
	sta	a:wram_0E6C
	lda	#$1804
	sta	a:wram_0EAC
	lda	#$0040
	sta	$24,x
loc_02A6E5:
	dec	$24,x
	bpl	loc_02A6EC
	brl	loc_02A39A
loc_02A6EC:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A6FB
	jsl	f:sub_029DCD
	jsr	a:sub_02A339
	rtl
loc_02A6FB:
	lda	#$A000
	sta	$16,x
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02A70A:
	jsr	a:sub_02A377
	bcc	loc_02A712
	brl	loc_02A39A
loc_02A712:
	jsr	a:sub_02A35F
	bcc	loc_02A71A
	brl	loc_02A312
loc_02A71A:
	dec	$24,x
	bmi	loc_02A725
	jsr	a:sub_02A78E
	jsr	a:sub_02A339
	rtl
loc_02A725:
	lda	#$A000
	sta	$16,x
	inc	$12,x

sub_02A72C:
	jsr	a:sub_02A377
	bcc	loc_02A734
	brl	loc_02A39A
loc_02A734:
	jsr	a:sub_02A35F
	bcc	loc_02A73C
	brl	loc_02A312
loc_02A73C:
	lda	#$0004
	jsl	f:sub_029C51
	jsl	f:sub_029B06
	clc
	adc	#$0002
	sec
	sbc	$04,x
	cmp	#$0004
	bcc	loc_02A6FB
	ldy	difficulty
	lda	zp_78
	and	a:data_05D564,y
	bne	loc_02A763
	ldy	#$0010
	jsl	f:sub_029E45
loc_02A763:
	jsr	a:sub_02A339
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_02A767:
	; (not executed in the CDL traces)
	lda	#$0030
	jsl	f:sub_00868F
	lda	#$0005
	sta	$12,x

sub_02A773:
	; (not executed in the CDL traces)
	phx
	ldx	#$0E00
	jsl	f:sub_029D0C
	ldx	#$0E40
	jsl	f:sub_029D0C
	ldx	#$0E80
	jsl	f:sub_029D0C
	plx
	jml	f:sub_029D0C

sub_02A78E:
	lda	$24,x
	and	#$007F
	cmp	#$0040
	bcc	loc_02A79B
	eor	#$007F
loc_02A79B:
	lsr	a
	jsl	f:sub_029C7F
	jsl	f:sub_02C086
	rts

sub_02A7A5:
	lda	$06,x
	bpl	loc_02A7AC
	brl	loc_02A86C
loc_02A7AC:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0005
	bne	loc_02A7B9
	brl	loc_02A86C
loc_02A7B9:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A7C8,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A7C8:
	.addr	sub_02A7D2
	.addr	sub_02A7F8
	.addr	sub_02A813
	.addr	sub_02A82F
	.addr	sub_02A849

sub_02A7D2:
	ldy	difficulty
	lda	a:data_05D56A,y
	sta	$06,x
	stz	$3C,x
	stz	$08,x
	stz	$0C,x
	lda	#$0005
	sta	$00,x
	lda	#$D570
	sta	$28,x
	lda	#$0000
	sta	$02,x
	lda	#$A000
	sta	$16,x
	lda	#$0001
	sta	$12,x

sub_02A7F8:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0003
	beq	loc_02A809
	jsl	f:sub_029B06
	sta	$04,x
	rtl
loc_02A809:
	lda	#$0002
	sta	$24,x
	lda	#$0002
	sta	$12,x

sub_02A813:
	dec	$24,x
	bmi	loc_02A81E
	jsl	f:sub_029B06
	sta	$04,x
	rtl
loc_02A81E:
	lda	#$2000
	sta	$02,x
	ldy	difficulty
	lda	a:data_05D58A,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02A82F:
	dec	$24,x
	bmi	loc_02A842
	lda	$2E,x
	bit	#$000C
	bne	loc_02A83D
	brl	sub_029B21
loc_02A83D:
	jsl	f:sub_029DCD
	rtl
loc_02A842:
	lda	#$0040
	sta	$24,x
	inc	$12,x

sub_02A849:
	dec	$24,x
	bmi	loc_02A81E
	lda	$2E,x
	bit	#$000C
	bne	loc_02A857
	brl	sub_029B21
loc_02A857:
	lda	$24,x
	cmp	#$0020
	bne	loc_02A862
	jsl	f:sub_02A9A6
loc_02A862:
	lda	#$0002
	sta	$22,x
	jsl	f:sub_02C086
	rtl
loc_02A86C:
	lda	#$000B
	jsl	f:sub_00868F
	jmp	a:sub_029D0C

sub_02A876:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A885,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A885:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_02A88D
	.addr	sub_02A8C6

sub_02A88D:
	lda	$00,x
	bne	loc_02A8AC
	ldy	difficulty
	lda	a:data_05D590,y
	sta	$06,x
	lda	#$0005
	sta	$00,x
	lda	#$D596
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_02A8AC:
	dec	$24,x
	bpl	loc_02A8B3
	brl	sub_029B21
loc_02A8B3:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A8BF
	jsl	f:sub_029DCD
	rtl
loc_02A8BF:
	lda	#$A000
	sta	$16,x
	inc	$12,x

sub_02A8C6:
	lda	$06,x
	bmi	loc_02A8D9
	lda	$2E,x
	bit	#$000C
	bne	loc_02A8D4
	brl	sub_029B21
loc_02A8D4:
	jsl	f:sub_029DCD
	rtl
loc_02A8D9:
	stz	$06,x
	lda	#$000B
	jsl	f:sub_00868F
	jmp	a:sub_029D0C

sub_02A8E5:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02A8F4,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02A8F4:
	.addr	sub_029EBD
	.addr	sub_029EDE
	.addr	sub_02A8FE
	.addr	sub_02A93F
	.addr	sub_02A96C

sub_02A8FE:
	lda	$00,x
	bne	loc_02A91D
	ldy	difficulty
	lda	a:data_05D5B0,y
	sta	$06,x
	lda	#$0005
	sta	$00,x
	lda	#$D570
	sta	$28,x
	lda	#$2000
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_02A91D:
	dec	$24,x
	bpl	loc_02A924
	brl	sub_029B21
loc_02A924:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A930
	jsl	f:sub_029DCD
	rtl
loc_02A930:
	lda	#$A000
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02A93F:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A949
	brl	sub_029B21
loc_02A949:
	lda	$06,x
	bpl	loc_02A950
	brl	loc_02A8D9
loc_02A950:
	dec	$24,x
	bpl	loc_02A95E
	inc	$24,x
	jsl	f:sub_029B06
	cmp	$04,x
	beq	loc_02A963
loc_02A95E:
	jsl	f:sub_029DCD
	rtl
loc_02A963:
	ldy	difficulty
	lda	a:data_05D5B6,y
	sta	$24,x
	inc	$12,x

sub_02A96C:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A976
	brl	sub_029B21
loc_02A976:
	lda	$06,x
	bpl	loc_02A97D
	brl	loc_02A8D9
loc_02A97D:
	dec	$24,x
	bpl	loc_02A992
	inc	$24,x
	jsl	f:sub_029B06
	cmp	$04,x
	bne	loc_02A930
	ldy	difficulty
	lda	a:data_05D5B6,y
	sta	$24,x
loc_02A992:
	ldy	difficulty
	lda	a:data_05D5B6,y
	lsr	a
	cmp	$24,x
	bne	loc_02A9A5
	jsl	f:sub_02A9A6
	lda	#$0002
	sta	$22,x
loc_02A9A5:
	rtl

sub_02A9A6:
	lda	$2E,x
	bit	#$0003
	beq	loc_02A9F7
	jsl	f:sub_029BC2
	bcs	loc_02A9F7
	lda	#$000D
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	lda	$04,x
	sta	a:$0004,y
	phy
	ldy	#$000C
	jsl	f:sub_1DACA4
	ply
	lda	$0A,x
	clc
	adc	zp_08
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_0A
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	lda	a:$0004,y
	ora	#$FF00
	sta	a:$0004,y
loc_02A9F7:
	rtl

sub_02A9F8:
	ldx	#$0980
loc_02A9FB:
	lda	$10,x
	beq	loc_02AA07
	jsl	f:sub_02AA13
	jsl	f:sub_02ABCF
loc_02AA07:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02A9FB
	rtl

sub_02AA13:
	phx
	asl	a
	tax
	lda	f:tbl_02AA20,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AA20:
	.addr	sub_02AA72
	.addr	sub_02AA34
	.addr	sub_02AA73
	.addr	sub_02AABA
	.addr	sub_02AAFD
	.addr	sub_02AB20
	.addr	sub_02AB43
	.addr	sub_02AB66
	.addr	sub_02AB89
	.addr	sub_02ABAC

sub_02AA34:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AA43,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AA43:
	.addr	sub_02AA47
	.addr	sub_02AA6B

sub_02AA47:
	lda	#$D5BC
	sta	$20,x
	stz	$22,x
	lda	#$8000
	sta	$16,x
	lda	#$0010
	sta	$06,x
	stz	$04,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0001
	sta	$12,x

sub_02AA6B:
	lda	$20,x
	bne	sub_02AA72
	brl	sub_029B21

sub_02AA72:
	rtl

sub_02AA73:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AA82,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AA82:
	.addr	sub_02AA86
	.addr	sub_02AAB2

sub_02AA86:
	lda	#$D610
	sta	$20,x
	stz	$22,x
	stz	$16,x
	stz	$04,x
	lda	rng_lo
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$0A,x
	sta	$0A,x
	lda	rng_hi
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$0E,x
	sta	$0E,x
	lda	#$0001
	sta	$12,x

sub_02AAB2:
	lda	$20,x
	bne	loc_02AAB9
	brl	sub_029B21
loc_02AAB9:
	rtl

sub_02AABA:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AAC9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AAC9:
	.addr	sub_02AACD
	.addr	sub_02AAF5

sub_02AACD:
	ldy	a:wram_15A8
	lda	a:data_05D664,y
	sta	$20,x
	lda	#$0001
	sta	$14,x
loc_02AADA:
	lda	#$4000
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0140
	sta	$24,x
	lda	#$0001
	sta	$12,x

sub_02AAF5:
	dec	$24,x
	bpl	loc_02AAFC
	brl	sub_029B21
loc_02AAFC:
	rtl

sub_02AAFD:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AB0C,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AB0C:
	.addr	sub_02AB10
	.addr	sub_02AAF5

sub_02AB10:
	ldy	a:wram_15A8
	lda	a:data_05D668,y
	sta	$20,x
	lda	#$0002
	sta	$14,x
	jmp	a:loc_02AADA

sub_02AB20:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AB2F,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AB2F:
	.addr	sub_02AB33
	.addr	sub_02AAF5

sub_02AB33:
	ldy	a:wram_15A8
	lda	a:data_05D66C,y
	sta	$20,x
	lda	#$0003
	sta	$14,x
	jmp	a:loc_02AADA

sub_02AB43:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AB52,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AB52:
	.addr	sub_02AB56
	.addr	sub_02AAF5

sub_02AB56:
	ldy	a:wram_15A8
	lda	a:data_05D670,y
	sta	$20,x
	lda	#$0004
	sta	$14,x
	jmp	a:loc_02AADA

sub_02AB66:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AB75,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AB75:
	.addr	sub_02AB79
	.addr	sub_02AAF5

sub_02AB79:
	ldy	a:wram_15A8
	lda	a:data_05D674,y
	sta	$20,x
	lda	#$0005
	sta	$14,x
	jmp	a:loc_02AADA

sub_02AB89:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AB98,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AB98:
	.addr	sub_02AB9C
	.addr	sub_02AAF5

sub_02AB9C:
	ldy	a:wram_15A8
	lda	a:data_05D678,y
	sta	$20,x
	lda	#$0006
	sta	$14,x
	jmp	a:loc_02AADA

sub_02ABAC:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02ABBB,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02ABBB:
	.addr	sub_02ABBF
	.addr	sub_02AAF5

sub_02ABBF:
	ldy	a:wram_15A8
	lda	a:data_05D67C,y
	sta	$20,x
	lda	#$0007
	sta	$14,x
	jmp	a:loc_02AADA

sub_02ABCF:
	ldy	$20,x
	beq	loc_02ABF4
	dec	$22,x
	bmi	loc_02ABF5
	bne	loc_02ABF4
	tya
	clc
	adc	#$0006
loc_02ABDE:
	tay
	lda	a:$0000,y
	bmi	loc_02ABDE
	beq	loc_02ABFA
	sty	$20,x
loc_02ABE8:
	sta	$22,x
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
loc_02ABF4:
	rtl
loc_02ABF5:
	lda	a:$0000,y
	bne	loc_02ABE8
loc_02ABFA:
	sta	$22,x
	sta	$20,x
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	rtl

sub_02AC09:
	ldx	#$0AC0
loc_02AC0C:
	lda	$10,x
	beq	loc_02AC17
	jsl	f:sub_02AC3D
	jsr	a:sub_02ACCC
loc_02AC17:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	loc_02AC0C
	rtl

sub_02AC23:
	ldx	#$0AC0
loc_02AC26:
	lda	$10,x
	beq	loc_02AC31
	jsl	f:sub_02AC3D
	jsr	a:sub_02ACCC
loc_02AC31:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02AC26

sub_02AC3C:
	rtl

sub_02AC3D:
	phx
	asl	a
	tax
	lda	f:tbl_02AC4A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AC4A:
	.addr	sub_02AC3C
	.addr	sub_02F9F6
	.addr	sub_02F8D4
	.addr	sub_02ACE2
	.addr	sub_02B35B
	.addr	sub_02B5B2
	.addr	sub_02B416
	.addr	sub_02FADD
	.addr	sub_02EF8D
	.addr	sub_02AC3C
	.addr	sub_02AC3C
	.addr	sub_02AC3C
	.addr	sub_02FB33
	.addr	sub_02FB80
	.addr	sub_02FBF4
	.addr	sub_02AC3C
	.addr	sub_02AC3C
	.addr	sub_02AC3C
	.addr	sub_02AC3C
	.addr	sub_02AC3C

sub_02AC72:
	jsl	f:sub_029BD8
	bcs	loc_02AC8E
	lda	#$0002
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_02AC8E:
	rtl

sub_02AC8F:
	jsl	f:sub_029BD8
	bcs	loc_02ACCB
	lda	$14,x
	asl	a
	sta	zp_FA
	lda	rng_lo
	and	#$0003
	ora	zp_FA
	asl	a
	phy
	tay
	lda	a:data_05D78C,y
	ply
	sta	a:$0014,y
	cmp	#$0000
	beq	loc_02ACCA
	asl	a
	phy
	tay
	lda	a:data_05D7A2,y
	ply
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_02ACCA:
	clc
loc_02ACCB:
	rtl

sub_02ACCC:
	lda	$20,x
	cmp	$28,x
	beq	loc_02ACE1
	sta	$28,x
	tay
	lda	$26,x
	phx
	jsl	f:sub_04DCD2
	plx
	bcc	loc_02ACE1
	stz	$28,x
loc_02ACE1:
	rts

sub_02ACE2:
	lda	$12,x
	cmp	#$0011
	beq	loc_02ACEC
	jsr	a:sub_02B18C
loc_02ACEC:
	jsr	a:sub_02B1A7
	jsl	f:sub_02AD04
	jsl	f:sub_02B77D
	lda	$04,x
	clc
	adc	#$0002
	lsr	a
	and	#$007E
	sta	$3E,x
	rtl

sub_02AD04:
	lda	a:wram_0B46
	bpl	loc_02AD0C
	brl	loc_02B04C
loc_02AD0C:
	lda	$12,x
	cmp	#$0004
	bcc	loc_02AD2B
	cmp	#$0007
	bcs	loc_02AD2B
	lda	a:wram_0B90
	bne	loc_02AD20
	; (not executed in the CDL traces)
	brl	loc_02AE9A
loc_02AD20:
	lda	a:wram_0B92
	cmp	#$0004
	bne	loc_02AD2B
	brl	loc_02AE9A
loc_02AD2B:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02AD3A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02AD3A:
	.addr	sub_02AD60
	.addr	sub_02AD86
	.addr	sub_02ADBC
	.addr	sub_02AE0A
	.addr	sub_02AE1C
	.addr	sub_02AE30
	.addr	sub_02AE7C
	.addr	sub_02AE9F
	.addr	sub_02AEC4
	.addr	sub_02AEE2
	.addr	sub_02AF27
	.addr	sub_02AF5E
	.addr	sub_02AFCA
	.addr	sub_02AFE1
	.addr	sub_02B005
	.addr	sub_02B01B
	.addr	sub_02B041
	.addr	sub_02B063
	.addr	sub_02B0B2

sub_02AD60:
	lda	#$8000
	sta	a:wram_0ACA
	sta	a:wram_0ACE
	lda	#$00F0
	sta	a:wram_1F90
	sta	a:wram_1FD0
	lda	#$0110
	sta	a:wram_1F92
	sta	a:wram_1FD2
	stz	$2E,x
	stz	$16,x
	lda	#$0040
	sta	$24,x
	inc	$12,x

sub_02AD86:
	dec	$24,x
	bmi	loc_02AD8B
	rtl
loc_02AD8B:
	lda	#$002F
	jsl	f:sub_00868F
	stz	$20,x
	stz	$28,x
	lda	a:wram_1510
	sta	a:wram_0ACA
	lda	a:wram_1512
	sta	a:wram_0ACE
	lda	#$0000
	sta	a:wram_1F94
	sta	a:wram_1FD4
	sta	a:wram_1F96
	sta	a:wram_1FD6
	lda	#$0080
	sta	a:wram_0AC4
	jsr	a:sub_02B169
	inc	$12,x

sub_02ADBC:
	lda	a:wram_0AC4
	inc	a
	inc	a
	and	#$00FF
	sta	a:wram_0AC4
	inc	a:wram_1F94
	inc	a:wram_1FD4
	inc	a:wram_1F96
	inc	a:wram_1FD6
	inc	a:wram_1F94
	inc	a:wram_1FD4
	inc	a:wram_1F96
	inc	a:wram_1FD6
	lda	a:wram_1FD6
	cmp	#$0100
	beq	loc_02ADE8
	rtl
loc_02ADE8:
	lda	#$0056
	jsl	f:sub_00868F
	jsr	a:sub_02B146
	lda	#$A000
	sta	$16,x
	lda	#$0010
	sta	a:wram_15A4
	lda	#$0004
	sta	a:wram_15A2
	lda	#$0020
	sta	$24,x
	inc	$12,x

sub_02AE0A:
	dec	$24,x
	bmi	loc_02AE0F
	rtl
loc_02AE0F:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0004
	sta	$12,x

sub_02AE1C:
	jsr	a:sub_02B210
	bcs	loc_02AE22
	rtl
loc_02AE22:
	lda	#$0018
	jsl	f:sub_1DAD8A
	lda	#$0060
	sta	$24,x
	inc	$12,x

sub_02AE30:
	dec	$24,x
	bmi	loc_02AE3B
	jsr	a:sub_02B24B
	jsr	a:sub_02B293
	rtl
loc_02AE3B:
	lda	a:wram_15A0
	cmp	#$3C80
	bcc	loc_02AE46
	; (not executed in the CDL traces)
	brl	loc_02AE0F
loc_02AE46:
	lda	$04,x
	sta	$24,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	$04,x
	bit	#$0080
	bne	loc_02AE77
	stz	$26,x
	bra	sub_02AE7C
loc_02AE77:
	lda	#$0002
	sta	$26,x

sub_02AE7C:
	lda	#$0002
	jsr	a:sub_02B79B
	ldy	$26,x
	lda	$04,x
	clc
	adc	a:data_05D7B2,y
	and	#$00FF
	sta	$04,x
	cmp	$24,x
	bne	loc_02AE96
	brl	loc_02AE0F
loc_02AE96:
	jsr	a:sub_02B129
	rtl
loc_02AE9A:
	lda	#$0007
	sta	$12,x

sub_02AE9F:
	ldy	difficulty
	lda	a:data_05D7CE,y
	lsr	a
	cmp	a:wram_0B46
	bcs	loc_02AEB5
	lda	a:wram_15A0
	cmp	#$7F00
	bcs	loc_02AEB5
	brl	loc_02AFD2
loc_02AEB5:
	lda	#$0020
	sta	$24,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

sub_02AEC4:
	dec	$24,x
	bmi	loc_02AED4
	lda	a:wram_0AC4
	inc	a
	inc	a
	and	#$00FF
	sta	a:wram_0AC4
	rtl
loc_02AED4:
	lda	#$002E
	jsl	f:sub_00868F
	stz	$16,x
	jsr	a:sub_02B169
	inc	$12,x

sub_02AEE2:
	lda	a:wram_0AC4
	inc	a
	inc	a
	and	#$00FF
	sta	a:wram_0AC4
	dec	a:wram_1F94
	dec	a:wram_1FD4
	dec	a:wram_1F96
	dec	a:wram_1FD6
	dec	a:wram_1F94
	dec	a:wram_1FD4
	dec	a:wram_1F96
	dec	a:wram_1FD6
	beq	loc_02AF08
	rtl
loc_02AF08:
	lda	#$0100
	sta	a:wram_1F94
	sta	a:wram_1FD4
	sta	a:wram_1F96
	sta	a:wram_1FD6
	lda	#$8000
	sta	a:wram_0ACA
	sta	a:wram_0ACE
	lda	#$0020
	sta	$24,x
	inc	$12,x

sub_02AF27:
	dec	$24,x
	bmi	loc_02AF2C
	rtl
loc_02AF2C:
	lda	#$002F
	jsl	f:sub_00868F
	stz	a:wram_1F94
	stz	a:wram_1FD4
	stz	a:wram_1F96
	stz	a:wram_1FD6
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sta	a:wram_0ACA
	lda	a:$0ECE,y
	sta	a:wram_0ACE
	ldy	difficulty
	lda	a:data_05D7B6,y
	sta	a:wram_0AFC
	lda	a:data_05D7BC,y
	sta	a:wram_0AFA
	inc	$12,x

sub_02AF5E:
	lda	a:wram_0AC4
	clc
	adc	a:wram_0AFC
	and	#$00FF
	sta	a:wram_0AC4
	lda	a:wram_1F94
	clc
	adc	a:wram_0AFA
	sta	a:wram_1F94
	lda	a:wram_1FD4
	clc
	adc	a:wram_0AFA
	sta	a:wram_1FD4
	lda	a:wram_1F96
	clc
	adc	a:wram_0AFA
	sta	a:wram_1F96
	lda	a:wram_1FD6
	clc
	adc	a:wram_0AFA
	sta	a:wram_1FD6
	cmp	#$0100
	bcs	loc_02AF99
	rtl
loc_02AF99:
	lda	#$0056
	jsl	f:sub_00868F
	lda	#$0100
	sta	a:wram_1F94
	sta	a:wram_1FD4
	sta	a:wram_1F96
	sta	a:wram_1FD6
	jsr	a:sub_02B146
	lda	#$A000
	sta	$16,x
	lda	#$0010
	sta	a:wram_15A4
	lda	#$0004
	sta	a:wram_15A2
	lda	#$0020
	sta	$24,x
	inc	$12,x

sub_02AFCA:
	dec	$24,x
	bpl	loc_02AFD1
	brl	loc_02B02D
loc_02AFD1:
	rtl
loc_02AFD2:
	lda	#$0080
	sta	$24,x
	stz	$26,x
	jsr	a:sub_02B26A
	lda	#$000D
	sta	$12,x

sub_02AFE1:
	dec	$24,x
	bmi	loc_02AFFE
	lda	$2C,x
	clc
	adc	#$0010
	sta	$2C,x

sub_02AFED:
	lda	$2C,x
	xba
	and	#$00FF
	pha
	jsr	a:sub_02B79B
	pla
	clc
	adc	$04,x
	sta	$04,x
	rtl
loc_02AFFE:
	lda	#$0040
	sta	$24,x
	inc	$12,x

sub_02B005:
	dec	$24,x
	bmi	loc_02B011
	jsr	a:sub_02B293
	jsl	f:sub_02AFED
	rtl
loc_02B011:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

sub_02B01B:
	lda	$2C,x
	sec
	sbc	#$0010
	bpl	loc_02B026
	; (not executed in the CDL traces)
	lda	#$0000
loc_02B026:
	sta	$2C,x
	beq	loc_02B02D
	jmp	a:sub_02AFED
loc_02B02D:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	ldy	difficulty
	lda	a:data_05D7C2,y
	sta	$24,x
	lda	#$0010
	sta	$12,x

sub_02B041:
	dec	$24,x
	bpl	loc_02B048
	brl	loc_02AE9A
loc_02B048:
	jsr	a:sub_02B129
	rtl
loc_02B04C:
	stz	$06,x
	stz	$16,x
	lda	#$0200
	sta	$24,x
	sta	a:wram_15A4
	lda	#$0001
	sta	a:wram_15A2
	lda	#$0011
	sta	$12,x

sub_02B063:
	jsl	f:sub_02B7C9
	jsr	a:sub_02B0B3
	jsr	a:sub_02B293
	jsl	f:sub_02AFED
	lda	$24,x
	beq	loc_02B0A9
	cmp	#$000C
	bcc	loc_02B0A6
	and	#$0003
	bne	loc_02B0A6
	lda	rng_hi
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0A,x
	sta	a:wram_0B0A
	lda	rng_lo
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0E,x
	sta	a:wram_0B0E
	phx
	ldx	#$0B00
	jsl	f:sub_02AC72
	plx
loc_02B0A6:
	dec	$24,x
	rtl
loc_02B0A9:
	lda	#$8000
	sta	$0A,x
	sta	$0E,x
	inc	$12,x

sub_02B0B2:
	rtl

sub_02B0B3:
	lda	$2C,x
	beq	loc_02B0C2
	; (not executed in the CDL traces)
	sec
	sbc	#$0020
	bcs	loc_02B0C0
	lda	#$0000
loc_02B0C0:
	sta	$2C,x
loc_02B0C2:
	jsr	a:sub_02B0F7
	lda	$1A,x
	ora	$18,x
	beq	loc_02B0F6
	; (not executed in the CDL traces)
	lda	$1A,x
	bmi	loc_02B0E5
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bcs	loc_02B0F6
loc_02B0E0:
	stz	$1A,x
	stz	$18,x
	rts
loc_02B0E5:
	clc
	lda	$18,x
	adc	#$4000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	bcs	loc_02B0E0
loc_02B0F6:
	rts

sub_02B0F7:
	lda	$1E,x
	ora	$1C,x
	beq	loc_02B128
	; (not executed in the CDL traces)
	lda	$1E,x
	bmi	loc_02B117
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bcs	loc_02B128
loc_02B112:
	stz	$1E,x
	stz	$1C,x
	rts
loc_02B117:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bcs	loc_02B112
loc_02B128:
	rts

sub_02B129:
	ldy	#$0BC0
loc_02B12C:
	lda	a:$0012,y
	cmp	#$0002
	bne	loc_02B13A
	lda	#$0003
	sta	a:$0012,y
loc_02B13A:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	loc_02B12C
	rts

sub_02B146:
	lda	a:p1_lives
	beq	loc_02B157
	lda	a:wram_0EC2
	and	#$CFFF
	ora	#$2000
	sta	a:wram_0EC2
loc_02B157:
	lda	a:p2_lives
	beq	loc_02B168
	; (not executed in the CDL traces)
	lda	a:wram_0F02
	and	#$CFFF
	ora	#$2000
	sta	a:wram_0F02
loc_02B168:
	rts

sub_02B169:
	lda	a:p1_lives
	beq	loc_02B17A
	lda	a:wram_0EC2
	and	#$CFFF
	ora	#$1000
	sta	a:wram_0EC2
loc_02B17A:
	lda	a:p2_lives
	beq	loc_02B18B
	; (not executed in the CDL traces)
	lda	a:wram_0F02
	and	#$CFFF
	ora	#$1000
	sta	a:wram_0F02
loc_02B18B:
	rts

sub_02B18C:
	lda	zp_78
	and	#$0003
	bne	loc_02B1A2
	lda	a:wram_1592
	inc	a
	cmp	#$0003
	bcc	loc_02B19F
	lda	#$0000
loc_02B19F:
	sta	a:wram_1592
loc_02B1A2:
	rts

sub_02B1A3:
	jsr	a:sub_02B1A7
	rtl

sub_02B1A7:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_02B1B0
	; (not executed in the CDL traces)
	rts
loc_02B1B0:
	lda	#$FFFF
	sta	zp_0C
	sta	zp_0E
	lda	a:p1_lives
	beq	loc_02B1D2
	lda	a:wram_0ECA
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:wram_0ECE
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DAD3C
	sta	zp_0C
loc_02B1D2:
	lda	a:p2_lives
	beq	loc_02B1ED
	; (not executed in the CDL traces)
	lda	a:wram_0F0A
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:wram_0F0E
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DAD3C
	sta	zp_0E
loc_02B1ED:
	lda	zp_0C
	cmp	zp_0E
	beq	loc_02B1FE
	bcs	loc_02B204
loc_02B1F5:
	stz	a:wram_159E
	lda	zp_0C
	sta	a:wram_15A0
	rts
loc_02B1FE:
	; (not executed in the CDL traces)
	lda	zp_78
	xba
	lsr	a
	bcc	loc_02B1F5
loc_02B204:
	lda	#$0040
	sta	a:wram_159E
	lda	zp_0E
	sta	a:wram_15A0
	rts

sub_02B210:
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	$04,x
	and	#$00FF
	beq	loc_02B249
	bit	#$0080
	bne	loc_02B239
	lda	$04,x
	inc	a
	bra	loc_02B23C
loc_02B239:
	lda	$04,x
	dec	a
loc_02B23C:
	and	#$00FF
	sta	$04,x
	lda	#$0001
	jsr	a:sub_02B79B
	clc
	rts
loc_02B249:
	sec
	rts

sub_02B24B:
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	cmp	$04,x
	bne	loc_02B268
	clc
	rts
loc_02B268:
	sec
	rts

sub_02B26A:
	lda	$04,x
	pha
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sta	$04,x
	ldy	difficulty
	lda	a:data_05D7C8,y
	jsl	f:sub_1DAD8A
	pla
	sta	$04,x
	rts

sub_02B293:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rts

sub_02B2AE:
	lda	a:wram_0ACE
	sec
	sbc	zp_1A
	sta	zp_D6
	bpl	loc_02B2BC
	eor	#$FFFF
	inc	a
loc_02B2BC:
	inc	a
	cmp	#$0100
	bcc	loc_02B2C3
loc_02B2C2:
	rtl
loc_02B2C3:
	sta	zp_DE
	lda	a:wram_0ACA
	sec
	sbc	zp_18
	sta	zp_D4
	bpl	loc_02B2D3
	eor	#$FFFF
	inc	a
loc_02B2D3:
	inc	a
	cmp	#$0100
	bcs	loc_02B2C2
	sta	a:WRMPYA
	ldy	zp_16
	tya
	sta	zp_D8
	asl	a
	eor	zp_16
	sta	zp_DA
	sep	#$10
	.i8
	ldx	a:data_05D868,y
	stx	a:WRMPYB
	stx	zp_E2
	lda	zp_D4
	eor	zp_D9
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B301
	eor	#$FFFF
	inc	a
loc_02B301:
	sta	zp_00
	ldx	a:data_05D828,y
	stx	a:WRMPYB
	lda	zp_D4
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B31A
	eor	#$FFFF
	inc	a
loc_02B31A:
	sta	zp_02
	ldy	zp_DE
	sty	a:WRMPYA
	stx	a:WRMPYB
	lda	zp_D6
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B334
	eor	#$FFFF
loc_02B334:
	adc	zp_00
	clc
	adc	zp_1C
	sta	zp_00
	ldx	zp_E2
	stx	a:WRMPYB
	lda	zp_D6
	eor	zp_D9
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B350
	eor	#$FFFF
loc_02B350:
	adc	zp_1E
	sec
	sbc	zp_02
	sta	zp_02
	rep	#$10
	.i16
	clc
	rtl

sub_02B35B:
	jsr	a:sub_02B3F8
	lda	#$8C60
	sta	zp_00
	lda	#$2260
	sta	zp_02
	lda	#$0070
	sta	zp_04
	jsl	f:sub_029BEE
	lda	$06,x
	bmi	loc_02B3C6
	lda	a:wram_0AD2
	cmp	#$0003
	beq	loc_02B3B6
	cmp	#$0009
	beq	loc_02B3AD
	cmp	#$000C
	beq	loc_02B3B6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02B396,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02B396:
	.addr	sub_02B3A0
	.addr	sub_02B3B2
	.addr	sub_02B3BB
	.addr	sub_02B3C5
	.addr	sub_02B3DB

sub_02B3A0:
	ldy	difficulty
	lda	a:data_05D7CE,y
	sta	$06,x
	stz	$20,x
	stz	$28,x
	stz	$2E,x
loc_02B3AD:
	lda	#$0001
	sta	$12,x

sub_02B3B2:
	stz	$16,x
	bra	loc_02B3C0
loc_02B3B6:
	lda	#$0002
	sta	$12,x

sub_02B3BB:
	lda	#$A000
	sta	$16,x
loc_02B3C0:
	lda	#$0003
	sta	$12,x

sub_02B3C5:
	rtl
loc_02B3C6:
	stz	$06,x
	stz	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0041
	jsl	f:sub_00868F
	lda	#$0004
	sta	$12,x

sub_02B3DB:
	dec	$24,x
	bmi	loc_02B3EB
	lda	$24,x
	bit	#$0003
	bne	loc_02B3EA
	jsl	f:sub_02AC72
loc_02B3EA:
	rtl
loc_02B3EB:
	lda	#$0013
	sta	$20,x
	cmp	$28,x
	bne	loc_02B3F7
	brl	sub_029B21
loc_02B3F7:
	rtl

sub_02B3F8:
	lda	a:wram_0AFE
	clc
	adc	#$0040
	and	#$007E
	tay
	lda	a:data_05DA64,y
	clc
	adc	a:wram_0ACA
	sta	$0A,x
	lda	a:data_05DA44,y
	clc
	adc	a:wram_0ACE
	sta	$0E,x
	rts

sub_02B416:
	jsr	a:sub_02B584
	jsl	f:sub_02B44E
	lda	$2A,x
	bne	loc_02B442
	lda	$2E,x
	bit	#$0040
	beq	loc_02B44D
	lda	$20,x
	sta	$2A,x
	ldy	$14,x
	lda	a:data_05D98C,y
	sta	$20,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	lda	#$0010
	jsl	f:sub_00868F
	rtl
loc_02B442:
	sta	$20,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_02B44D:
	rtl

sub_02B44E:
	lda	$06,x
	bpl	loc_02B455
	brl	loc_02B502
loc_02B455:
	lda	a:wram_0AD2
	cmp	#$0011
	bcc	loc_02B460
	; (not executed in the CDL traces)
	brl	loc_02B502
loc_02B460:
	cmp	#$0003
	beq	loc_02B4A6
	cmp	#$0009
	beq	loc_02B49E
	cmp	#$000C
	beq	loc_02B4A6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02B47E,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02B47E:
	.addr	sub_02B48E
	.addr	sub_02B4A3
	.addr	sub_02B4AB
	.addr	sub_02B4B8
	.addr	sub_02B4CE
	.addr	sub_02B4E0
	.addr	sub_02B4FD
	.addr	sub_02B519

sub_02B48E:
	ldy	difficulty
	lda	a:data_05D7D4,y
	sta	$06,x
	lda	#$2000
	sta	$02,x
	stz	$2A,x
	stz	$2E,x
loc_02B49E:
	lda	#$0001
	sta	$12,x

sub_02B4A3:
	stz	$16,x
	rtl
loc_02B4A6:
	lda	#$0002
	sta	$12,x

sub_02B4AB:
	ldy	$14,x
	lda	a:data_05D968,y
	sta	$20,x
	lda	#$B000
	sta	$16,x
	rtl

sub_02B4B8:
	ldy	$14,x
	lda	a:data_05D974,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	lda	#$B000
	sta	$16,x
	lda	#$0004
	sta	$12,x

sub_02B4CE:
	dec	$24,x
	bne	loc_02B501
	ldy	$14,x
	lda	a:data_05D980,y
	sta	$20,x
	lda	#$0020
	sta	$24,x
	inc	$12,x

sub_02B4E0:
	dec	$24,x
	bmi	loc_02B4EF
	lda	$24,x
	and	#$000F
	bne	loc_02B4EE
	jsr	a:sub_02B5A4
loc_02B4EE:
	rtl
loc_02B4EF:
	ldy	$14,x
	lda	a:data_05D974,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02B4FD:
	dec	$24,x
	beq	loc_02B4A6
loc_02B501:
	rtl
loc_02B502:
	lda	#$0007
	cmp	$12,x
	beq	sub_02B519
	sta	$12,x
	stz	$16,x
	lda	#$0041
	jsl	f:sub_00868F
	lda	#$0040
	sta	$24,x

sub_02B519:
	dec	$24,x
	bmi	loc_02B529
	lda	$24,x
	bit	#$0003
	bne	loc_02B528
	jsl	f:sub_02AC72
loc_02B528:
	rtl
loc_02B529:
	ldy	$14,x
	lda	a:data_05D998,y
	sta	$20,x
	cmp	$28,x
	bne	loc_02B528
	lda	a:wram_0AD2
	cmp	#$0011
	beq	loc_02B528
	jsr	a:sub_02B545
	bcs	loc_02B544
	brl	sub_029B21
loc_02B544:
	rtl

sub_02B545:
	jsl	f:sub_029BD8
	bcs	loc_02B583
	lda	rng_hi
	and	#$0004
	sta	zp_FA
	lda	rng_lo
	and	#$0003
	ora	zp_FA
	asl	a
	phy
	tay
	lda	a:data_05D7DA,y
	ply
	sta	a:$0014,y
	cmp	#$0000
	beq	loc_02B582
	asl	a
	phy
	tay
	lda	a:data_05D808,y
	ply
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_02B582:
	clc
loc_02B583:
	rts

sub_02B584:
	ldy	$14,x
	lda	a:wram_0AFE
	clc
	adc	a:data_05DC04,y
	and	#$007E
	tay
	lda	a:data_05DB04,y
	clc
	adc	a:wram_0ACA
	sta	$0A,x
	lda	a:data_05DAE4,y
	clc
	adc	a:wram_0ACE
	sta	$0E,x
	rts

sub_02B5A4:
	jsl	f:sub_029B06
	sta	$04,x
	ldy	#$0000
	jsl	f:sub_029E45
	rts

sub_02B5B2:
	jsl	f:sub_02B5BA
	jml	f:sub_029D88

sub_02B5BA:
	jsl	f:sub_029DBA
	jsr	a:sub_02B6E5
	lda	$06,x
	bpl	loc_02B5C8
	brl	loc_02B66E
loc_02B5C8:
	lda	a:wram_0AD2
	cmp	#$0011
	bcc	loc_02B5D3
	; (not executed in the CDL traces)
	brl	loc_02B66E
loc_02B5D3:
	cmp	#$0002
	beq	loc_02B636
	cmp	#$0003
	beq	loc_02B61B
	cmp	#$0004
	beq	loc_02B61B
	cmp	#$0006
	beq	loc_02B648
	cmp	#$0009
	beq	loc_02B636
	cmp	#$000C
	beq	loc_02B61B
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02B600,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02B600:
	.addr	sub_02B60A
	.addr	sub_02B62C
	.addr	sub_02B642
	.addr	sub_02B659
	.addr	sub_02B68A

sub_02B60A:
	ldy	difficulty
	lda	a:data_05D818,y
	sta	$06,x
	jsr	a:sub_02B6C3
	stz	$2E,x
	lda	a:wram_0AC4
	sta	$04,x
loc_02B61B:
	lda	#$0001
	cmp	$12,x
	beq	sub_02B62C
	sta	$12,x
	jsr	a:sub_02B6D2
	lda	#$A000
	sta	$16,x

sub_02B62C:
	lda	a:wram_0AC4
	jsr	a:sub_02B700
	jsr	a:sub_02B6AE
	rtl
loc_02B636:
	lda	#$0002
	cmp	$12,x
	beq	sub_02B642
	sta	$12,x
	jsr	a:sub_02B6C3

sub_02B642:
	lda	a:wram_0AC4
	sta	$04,x
	rtl
loc_02B648:
	lda	#$0003
	cmp	$12,x
	beq	sub_02B659
	sta	$12,x
	jsr	a:sub_02B6D2
	lda	#$A000
	sta	$16,x

sub_02B659:
	jsr	a:sub_02B6AE
	ldy	a:wram_0AE6
	lda	$04,x
	clc
	adc	a:data_05D81E,y
	and	#$00FF
	sta	$04,x
	jsr	a:sub_02B71E
	rtl
loc_02B66E:
	lda	#$0004
	cmp	$12,x
	beq	sub_02B68A
	sta	$12,x
	stz	$16,x
	lda	#$0041
	jsl	f:sub_00868F
	lda	#$0040
	sta	$24,x
	lda	#$0004
	sta	$12,x

sub_02B68A:
	dec	$24,x
	bmi	loc_02B69A
	lda	$24,x
	bit	#$0003
	bne	loc_02B699
	jsl	f:sub_02AC72
loc_02B699:
	rtl
loc_02B69A:
	lda	#$141C
	sta	$26,x
	stz	$00,x
	lda	#$0012
	sta	$20,x
	cmp	$28,x
	bne	loc_02B6AD
	brl	sub_029B21
loc_02B6AD:
	rtl

sub_02B6AE:
	lda	$28,x
	cmp	$20,x
	bne	loc_02B6C2
	lda	#$0002
	sta	$00,x
	lda	#$2000
	sta	$02,x
	stz	$28,x
	stz	$20,x
loc_02B6C2:
	rts

sub_02B6C3:
	lda	#$0036
	sta	$20,x
	lda	#$149C
	sta	$26,x
	stz	$00,x
	stz	$02,x
	rts

sub_02B6D2:
	lda	$00,x
	bne	loc_02B6E4
	lda	#$0037
	sta	$20,x
	lda	#$149C
	sta	$26,x
	stz	$00,x
	stz	$02,x
loc_02B6E4:
	rts

sub_02B6E5:
	lda	a:wram_0AC4
	ldy	#$003A
	jsl	f:sub_1DACA4
	lda	zp_08
	clc
	adc	a:wram_0ACA
	sta	$0A,x
	lda	zp_0A
	clc
	adc	a:wram_0ACE
	sta	$0E,x
	rts

sub_02B700:
	sec
	sbc	$04,x
	and	#$00FF
	beq	loc_02B71C
	bit	#$0080
	bne	loc_02B712
	lda	$04,x
	inc	a
	bra	loc_02B715
loc_02B712:
	lda	$04,x
	dec	a
loc_02B715:
	and	#$00FF
	sta	$04,x
	clc
	rts
loc_02B71C:
	sec
	rts

sub_02B71E:
	ldy	difficulty
	cpy	#$0004
	bcs	loc_02B734
	lda	zp_78
	and	a:data_05D822,y
	bne	loc_02B733
	ldy	#$001C
	jsl	f:sub_029E45
loc_02B733:
	rts
loc_02B734:
	; (not executed in the CDL traces)
	jsl	f:sub_029BC2
	bcs	loc_02B77C
	lda	zp_78
	and	#$000F
	bne	loc_02B748
	lda	#$0014
	jsl	f:sub_00868F
loc_02B748:
	lda	#$000C
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$04,x
	sta	a:$0004,y
	clc
	adc	#$0002
	lsr	a
	lsr	a
	asl	a
	and	#$007E
	phx
	tax
	lda	a:data_05D9A4,x
	sta	zp_08
	lda	a:data_05D9C4,x
	plx
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	zp_08
	clc
	adc	$0E,x
	sta	a:$000E,y
loc_02B77C:
	rts

sub_02B77D:
	lda	#$0040
	sta	a:wram_15AA
	lda	#$007E
	sta	a:wram_15AC
	lda	#$0600
	sta	a:wram_15AE
	lda	a:wram_1592
	asl	a
	tay
	lda	a:data_05DC30,y
	sta	a:wram_158C
	rtl

sub_02B79B:
	cmp	#$0000
	beq	loc_02B7C8
	bpl	loc_02B7A6
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
loc_02B7A6:
	pha
	cmp	#$0008
	bcc	loc_02B7AF
	lda	#$0008
loc_02B7AF:
	asl	a
	tay
	pla
	clc
	adc	a:wram_15CE
	sta	a:wram_15CE
	cmp	a:data_05DC34,y
	bcc	loc_02B7C8
	stz	a:wram_15CE
	lda	a:data_05DC44,y
	jsl	f:sub_00868F
loc_02B7C8:
	rts

sub_02B7C9:
	lda	#$006E
	ldy	a:wram_15D0
	bpl	loc_02B7E2
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:wram_15D0
	pla
	jsl	f:sub_00868F
loc_02B7E2:
	dec	a:wram_15D0
	rtl

sub_02B7E6:
	ldy	#$0EC0
	sty	zp_18
	lda	a:$0002,y
	and	#$3000
	sta	zp_1A
	ldx	#$0480
loc_02B7F6:
	lda	$10,x
	beq	loc_02B7FE
	jsl	f:sub_02B845
loc_02B7FE:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcc	loc_02B7F6
	lda	a:title_menu_cursor
	beq	loc_02B82E
	ldy	#$0F00
	sty	zp_18
	lda	a:$0002,y
	and	#$3000
	sta	zp_1A
loc_02B81B:
	lda	$10,x
	beq	loc_02B823
	jsl	f:sub_02B845
loc_02B823:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcc	loc_02B81B
loc_02B82E:
	ldx	#$0300
loc_02B831:
	lda	$10,x
	beq	loc_02B839
	jsl	f:sub_02B845
loc_02B839:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	loc_02B831
	rtl

sub_02B845:
	clc
	adc	#$0008
	phx
	asl	a
	tax
	lda	f:tbl_02B856,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02B856:
	.addr	sub_02B914
	.addr	sub_02B914
	.addr	sub_02B914
	.addr	sub_02B914
	.addr	sub_02B914
	.addr	sub_02B914
	.addr	sub_02B8C9
	.addr	sub_02B914
	.addr	sub_02B8D1
	.addr	sub_02B91C
	.addr	sub_02B91C
	.addr	sub_02B977
	.addr	sub_02B884
	.addr	sub_02B9C9
	.addr	sub_02BAEC
	.addr	sub_02BB99
	.addr	sub_02BC42
	.addr	sub_02BC93
	.addr	sub_02BD21
	.addr	sub_02BDFD
	.addr	sub_02BD9B
	.addr	sub_02BE6F
	.addr	sub_02BEBA

sub_02B884:
	lda	$12,x
	bne	loc_02B8AA
	lda	#$0040
	sta	$12,x
	lda	#$0003
	sta	$06,x
	lda	#$FFFF
	sta	$04,x
	lda	#$01F4
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	$02,x
	and	#$3000
	sta	$02,x
	bra	loc_02B8B8
loc_02B8AA:
	dec	$12,x
	beq	sub_02B8D2
	jsl	f:sub_02C02E
	bcs	sub_02B8D2
	jsl	f:sub_02B95C
loc_02B8B8:
	lda	$12,x
	and	#$0006
	tay
	lda	$02,x
	and	#$3000
	ora	a:data_05DC56,y
	sta	$02,x
	rtl

sub_02B8C9:
	dec	$12,x
	bne	sub_02B8D1
loc_02B8CD:
	stz	$10,x
	stz	$00,x

sub_02B8D1:
	rtl

sub_02B8D2:
	lda	$10,x
	cmp	#$0007
	beq	loc_02B913
	cmp	#$0008
	bne	loc_02B8E1
	brl	loc_02BC8B
loc_02B8E1:
	cmp	#$0009
	beq	loc_02B913
	cmp	#$000A
	beq	loc_02B913
	cmp	#$000B
	beq	loc_02B913
	lda	#$FFFE
	sta	$10,x
	lda	#$FFFF
	sta	$04,x
	lda	#$0101
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0004
	sta	$16,x
	lda	#$0002
	sta	$12,x
loc_02B913:
	rtl

sub_02B914:
	stz	$00,x
	lda	#$FFFF
	sta	$04,x
	rtl

sub_02B91C:
	lda	$12,x
	bne	loc_02B94C
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0080
	jsl	f:sub_1DAD8A
	stz	$08,x
	stz	$0C,x
	lda	#$FFFF
	sta	$04,x
	lda	#$0100
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	rtl
loc_02B94C:
	dec	$12,x
	bne	loc_02B953
	brl	sub_02B8D2
loc_02B953:
	jsl	f:sub_02BF89
	bcc	sub_02B95C
	brl	sub_02B8D2

sub_02B95C:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rtl

sub_02B977:
	lda	$12,x
	bne	loc_02B9A7
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0080
	jsl	f:sub_1DAD8A
	stz	$08,x
	stz	$0C,x
	lda	#$FFFF
	sta	$04,x
	lda	#$0110
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	rtl
loc_02B9A7:
	cmp	#$0008
	bne	loc_02B9B6
	lda	#$0102
	sta	$00,x
	lda	#$0008
	sta	$16,x
loc_02B9B6:
	dec	$12,x
	bne	loc_02B9BD
	brl	sub_02B8D2
loc_02B9BD:
	jsl	f:sub_02BF89
	bcc	loc_02B9C6
	brl	sub_02B8D2
loc_02B9C6:
	jmp	a:sub_02B95C

sub_02B9C9:
	lda	$12,x
	beq	loc_02B9D0
	brl	loc_02BA83
loc_02B9D0:
	lda	#$0040
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0000
	sta	$00,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	lda	#$0080
	jsl	f:sub_1DAD8A
	lda	a:wram_15A8
	bne	loc_02BA3F
	ldy	a:wram_1596
	bne	loc_02BA06
	ldy	#$0AC0
	sty	a:wram_1596
loc_02BA06:
	lda	a:$0016,y
	bit	#$2000
	beq	loc_02BA29
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02BA29
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA25
	lda	#$0AC0
loc_02BA25:
	sta	a:wram_1596
	rtl
loc_02BA29:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA36
	lda	#$0AC0
loc_02BA36:
	tay
	cpy	a:wram_1596
	bne	loc_02BA06
	stz	$14,x
	rtl
loc_02BA3F:
	; (not executed in the CDL traces)
	ldy	a:wram_1596
	bne	loc_02BA4A
	ldy	#$0AC0
	sty	a:wram_1596
loc_02BA4A:
	lda	a:$0016,y
	bit	#$2000
	beq	loc_02BA6D
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02BA6D
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA69
	lda	#$0AC0
loc_02BA69:
	sta	a:wram_1596
	rtl
loc_02BA6D:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA7A
	lda	#$0AC0
loc_02BA7A:
	tay
	cpy	a:wram_1596
	bne	loc_02BA4A
	stz	$14,x
	rtl
loc_02BA83:
	dec	$12,x
	bne	loc_02BA8A
	brl	sub_02B8D2
loc_02BA8A:
	jsl	f:sub_02BF89
	bcc	loc_02BA93
	brl	sub_02B8D2
loc_02BA93:
	lda	$12,x
	cmp	#$000A
	bcc	loc_02BAA2
	jsl	f:sub_02BAA5
	jsl	f:sub_02BAE4
loc_02BAA2:
	jmp	a:sub_02B95C

sub_02BAA5:
	ldy	$14,x
	beq	loc_02BAE3
	lda	a:$0010,y
	beq	loc_02BAE3
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	$04,x
	beq	loc_02BAE3
	bit	#$0080
	bne	loc_02BAD8
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rtl
loc_02BAD8:
	lda	$04,x
	sec
	sbc	#$0008
	and	#$00FF
	sta	$04,x
loc_02BAE3:
	rtl

sub_02BAE4:
	lda	#$0080
	jsl	f:sub_1DAD8A
	rtl

sub_02BAEC:
	lda	$12,x
	bne	loc_02BB08
	lda	#$0007
	sta	$12,x
	lda	#$0004
	sta	$06,x
	lda	#$0100
	sta	$00,x
	lda	#$0008
	sta	$16,x
	lda	zp_1A
	sta	$02,x
loc_02BB08:
	ldy	zp_18
	lda	a:$0004,y
	clc
	adc	$1A,x
	pha
	jsr	a:sub_02BB80
	pla
	jsl	f:sub_1DACA4
	lda	zp_08
	sta	zp_FC
	lda	zp_0A
	sta	zp_FE
	ldy	zp_18
	lda	a:$0004,y
	clc
	adc	$0C,x
	and	#$00FF
	sta	$04,x
	lda	#$0007
	sec
	sbc	$12,x
	asl	a
	tay
	lda	a:data_05DC62,y
	tay
	lda	$04,x
	jsl	f:sub_1DACA4
	ldy	zp_18
	lda	a:$000A,y
	clc
	adc	zp_08
	clc
	adc	zp_FC
	sta	$0A,x
	lda	a:$000E,y
	clc
	adc	zp_0A
	clc
	adc	zp_FE
	sta	$0E,x
	dec	$12,x
	bne	loc_02BB5F
	brl	sub_02B8D2
loc_02BB5F:
	jsl	f:sub_02BF89
	bcc	sub_02BB68
	brl	sub_02B8D2

sub_02BB68:
	ldy	#$0000
	lda	zp_78
	bit	#$0002
	bne	loc_02BB75
	ldy	#$0002
loc_02BB75:
	lda	$02,x
	and	#$3000
	ora	a:data_05DC7A,y
	sta	$02,x
	rtl

sub_02BB80:
	ldy	zp_18
	lda	a:$0012,y
	ldy	#$0022
	cmp	#$0005
	beq	loc_02BB98
	ldy	#$001E
	cmp	#$0007
	beq	loc_02BB98
	ldy	#$0017
loc_02BB98:
	rts

sub_02BB99:
	lda	$12,x
	bne	loc_02BBCC
	lda	#$000E
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF
	sta	$04,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:sub_02BC1B
	lda	$14,x
	sta	$18,x
	lda	$08,x
	sta	$0A,x
	sta	$1A,x
	lda	$0C,x
	sta	$0E,x
	sta	$1E,x
	rtl
loc_02BBCC:
	dec	$12,x
	bne	loc_02BBD3
	brl	loc_02B8CD
loc_02BBD3:
	jsl	f:sub_02BF89
	jsr	a:sub_02BC1B
	lda	$18,x
	sta	zp_10
	lda	$1A,x
	sta	zp_12
	lda	$1E,x
	sta	zp_14
	lda	#$000E
	sec
	sbc	$12,x
	and	#$000E
	tay
	lda	a:data_05DCFC,y
	tay
	lda	$14,x
	sta	$18,x
	jsl	f:sub_1DACA4
	lda	$08,x
	sta	$1A,x
	clc
	adc	zp_08
	sta	$0A,x
	lda	$0C,x
	sta	$1E,x
	clc
	adc	zp_0A
	sta	$0E,x
	lda	zp_10
	sta	$14,x
	lda	zp_12
	sta	$08,x
	lda	zp_14
	sta	$0C,x
	rtl

sub_02BC1B:
	lda	$12,x
	ldy	#$0000
	cmp	#$000A
	bcs	loc_02BC30
	ldy	#$0010
	cmp	#$0006
	bcs	loc_02BC30
	ldy	#$0020
loc_02BC30:
	lda	zp_78
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:data_05DC86,y
	sta	$00,x
	rts

sub_02BC42:
	lda	$12,x
	bne	loc_02BC66
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0200
	sta	$00,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	rtl
loc_02BC66:
	dec	$12,x
	bne	loc_02BC6D
	brl	loc_02BCDE
loc_02BC6D:
	jsl	f:sub_02BF89
	bcs	loc_02BC8B
	lda	$1A,x
	pha
	lda	$1E,x
	pha
	lda	#$0080
	jsl	f:sub_1DAD8A
	jsl	f:sub_02B95C
	pla
	sta	$1E,x
	pla
	sta	$1A,x
	rtl
loc_02BC8B:
	stz	$12,x
	lda	#$0009
	sta	$10,x
	rtl

sub_02BC93:
	lda	$12,x
	bne	loc_02BCDA
	lda	#$0040
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF
	sta	$04,x
	jsl	f:sub_02BD7B
	lda	$0A,x
	sta	$18,x
	lda	$0E,x
	sta	$1C,x
loc_02BCB2:
	lda	rng_lo
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_00
	lda	rng_hi
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_02
	lda	$18,x
	clc
	adc	zp_00
	sta	$0A,x
	lda	$1C,x
	clc
	adc	zp_02
	sta	$0E,x
	jml	f:sub_02BF89
loc_02BCDA:
	dec	$12,x
	bne	loc_02BCF4
loc_02BCDE:
	lda	#$0000
	ldy	$1A,x
	sta	a:$0010,y
	sta	a:$0012,y
	ldy	$1E,x
	sta	a:$0010,y
	sta	a:$0012,y
	jmp	a:loc_02B8CD
loc_02BCF4:
	jsl	f:sub_02BF89
	jsl	f:sub_02BD7B
	lda	$12,x
	and	#$0007
	beq	loc_02BCB2
	ldy	$1A,x
	cmp	#$0002
	beq	loc_02BD12
	ldy	$1E,x
	cmp	#$0005
	beq	loc_02BD12
	rtl
loc_02BD12:
	lda	#$0000
	sta	a:$0012,y
	lda	#$000A
	sta	a:$0010,y
	stx	$1A,y
	rtl

sub_02BD21:
	lda	$12,x
	bne	loc_02BD6D
	lda	#$0008
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF
	sta	$04,x
	ldy	a:$001A,x
	lda	a:$0002,y
	sta	$02,x
	jsl	f:sub_02BD7B
	lda	rng_lo
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_00
	lda	rng_hi
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_02
	ldy	a:$001A,x
	lda	a:$0018,y
	clc
	adc	zp_00
	sta	$0A,x
	lda	a:$001C,y
	clc
	adc	zp_02
	sta	$0E,x
	jml	f:sub_02BF89
loc_02BD6D:
	dec	$12,x
	bne	loc_02BD77
	; (not executed in the CDL traces)
	lda	#$FFFF
	sta	$10,x
	rtl
loc_02BD77:
	jsl	f:sub_02BF89

sub_02BD7B:
	lda	#$0008
	sec
	sbc	$12,x
	asl	a
	and	#$000E
	tay
	lda	a:data_05DCC6,y
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	a:data_05DCD6,y
	sta	$02,x
	lda	a:data_05DCE6,y
	sta	$16,x
	rtl

sub_02BD9B:
	; (not executed in the CDL traces)
	lda	$12,x
	bne	loc_02BDC1
	lda	#$0007
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$0100
	sta	$00,x
	lda	#$0008
	sta	$16,x
	lda	#$2C00
	sta	$02,x
	jsl	f:sub_02C02E
	jsl	f:sub_02BB68
	rtl
loc_02BDC1:
	lda	#$0007
	sec
	sbc	$12,x
	asl	a
	tay
	lda	a:data_05DC62,y
	clc
	adc	#$0020
	tay
	lda	a:wram_0B84
	sta	$04,x
	jsl	f:sub_1DACA4
	lda	a:wram_0B8A
	clc
	adc	zp_08
	sta	$0A,x
	lda	a:wram_0B8E
	clc
	adc	zp_0A
	sta	$0E,x
	dec	$12,x
	bne	loc_02BDF1
	brl	sub_02B8D2
loc_02BDF1:
	jsl	f:sub_02BF89
	bcc	loc_02BDFA
	brl	sub_02B8D2
loc_02BDFA:
	jmp	a:sub_02BB68

sub_02BDFD:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02BE0C,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02BE0C:
	.addr	sub_02BE14
	.addr	sub_02BE2F
	.addr	sub_02BE3B
	.addr	sub_02BE56

sub_02BE14:
	lda	#$0001
	sta	$06,x
	lda	#$FFFF
	sta	$04,x
	lda	#$0008
	sta	$16,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	inc	$12,x

sub_02BE2F:
	jsr	a:sub_02BE62
	lda	$14,x
	beq	loc_02BE3A
	jsl	f:sub_02B95C
loc_02BE3A:
	rtl

sub_02BE3B:
	lda	#$0004
	sta	$14,x
	lda	#$018E
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	stz	$06,x
	lda	#$0003
	sta	$12,x

sub_02BE56:
	dec	$14,x
	bpl	loc_02BE5D
	brl	loc_02B8CD
loc_02BE5D:
	jsl	f:sub_02B95C
	rtl

sub_02BE62:
	lda	zp_78
	asl	a
	and	#$000E
	tay
	lda	a:data_05DCA6,y
	sta	$00,x
	rts

sub_02BE6F:
	lda	$12,x
	bne	loc_02BE8F
	lda	#$0040
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:sub_02BF3B
loc_02BE8F:
	dec	$12,x
	bne	loc_02BE96
	brl	loc_02B8CD
loc_02BE96:
	jsr	a:sub_02BF3B
	lda	$04,x
	and	#$00FF
	sta	$04,x
	lda	$04,x
	and	#$00FF
	sta	$04,x
	lda	#$0020
	jsl	f:sub_1DAD8A
	lda	$04,x
	ora	#$FF00
	sta	$04,x
	jsl	f:sub_02B95C
	rtl

sub_02BEBA:
	lda	$12,x
	bne	loc_02BEDA
	lda	#$0080
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:sub_02BF5A
loc_02BEDA:
	dec	$12,x
	bne	loc_02BEE1
	brl	loc_02B8CD
loc_02BEE1:
	jsr	a:sub_02BF5A
	lda	$04,x
	and	#$00FF
	sta	$04,x
	jsr	a:sub_02BF01
	lda	#$0020
	jsl	f:sub_1DAD8A
	lda	$04,x
	ora	#$FF00
	sta	$04,x
	jsl	f:sub_02B95C
	rtl

sub_02BF01:
	ldy	$14,x
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	$04,x
	bit	#$0080
	bne	loc_02BF2D
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DCF6,y
	and	#$00FF
	sta	$04,x
	rts
loc_02BF2D:
	ldy	difficulty
	lda	$04,x
	sec
	sbc	a:data_05DCF6,y
	and	#$00FF
	sta	$04,x
	rts

sub_02BF3B:
	lda	$12,x
	ldy	#$0000
	cmp	#$0038
	bcs	loc_02BF58
	ldy	#$0010
	cmp	#$0030
	bcs	loc_02BF58
	ldy	#$0020
	cmp	#$0008
	bcs	loc_02BF58
	ldy	#$0030
loc_02BF58:
	bra	loc_02BF77

sub_02BF5A:
	lda	$12,x
	ldy	#$0000
	cmp	#$0078
	bcs	loc_02BF77
	ldy	#$0010
	cmp	#$0070
	bcs	loc_02BF77
	ldy	#$0020
	cmp	#$0008
	bcs	loc_02BF58
	ldy	#$0030
loc_02BF77:
	lda	zp_78
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:data_05DC86,y
	sta	$00,x
	rts

sub_02BF89:
	lda	a:wram_1594
	cmp	#$0002
	bne	loc_02BF93
	clc
	rtl
loc_02BF93:
	jsr	a:sub_02BF9A
	jsr	a:sub_02C9E3
	rtl

sub_02BF9A:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	beq	loc_02BFE1
	bit	#$0080
	bne	loc_02BFE4
	plx
	bit	#$0010
	beq	loc_02BFDA
	ldy	#$0002
	bit	#$0008
	beq	loc_02BFCE
	ldy	#$0000
loc_02BFCE:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
	pla
loc_02BFDA:
	and	#$0007
	beq	loc_02BFE2
loc_02BFDF:
	sec
	rts
loc_02BFE1:
	plx
loc_02BFE2:
	clc
	rts
loc_02BFE4:
	plx
	cmp	#$00FC
	bne	loc_02BFE2
	lda	a:wram_1594
	cmp	#$0006
	bne	loc_02C007
	ldy	#$0EC0
	cpx	#$0700
	bcc	loc_02BFFD
	; (not executed in the CDL traces)
	ldy	#$0F00
loc_02BFFD:
	lda	a:$0012,y
	cmp	#$0005
	beq	loc_02BFDF
	bra	loc_02BFE2
loc_02C007:
	jsr	a:sub_02CB59
	lda	a:$0016,y
	bpl	loc_02C02C
	bit	#$1000
	beq	loc_02C02C
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02C02C
	jsl	f:sub_02EB75
loc_02C02C:
	sec
	rts

sub_02C02E:
	lda	a:wram_15A8
	beq	loc_02C035
	clc
	rtl
loc_02C035:
	jsr	a:sub_02C03C
	jsr	a:sub_02C9E3
	rtl

sub_02C03C:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	beq	loc_02C05F
	bit	#$0080
	beq	loc_02C062
loc_02C05F:
	plx
loc_02C060:
	clc
	rts
loc_02C062:
	plx
	bit	#$0010
	beq	loc_02C07F
	ldy	#$0000
	bit	#$0008
	beq	loc_02C073
	ldy	#$0002
loc_02C073:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
	pla
loc_02C07F:
	and	#$0007
	beq	loc_02C060
	sec
	rts

sub_02C086:
	lda	a:wram_15A8
	beq	loc_02C08D
	; (not executed in the CDL traces)
	clc
	rtl
loc_02C08D:
	jsr	a:sub_02C123
	jsr	a:sub_02C71F
	jsr	a:sub_02C097
	rtl

sub_02C097:
	lda	$0E,x
	bpl	loc_02C09D
loc_02C09B:
	sec
	rts
loc_02C09D:
	lda	$0A,x
	bmi	loc_02C09B
	lda	zp_04
	beq	sub_02C121
	bit	#$0080
	beq	loc_02C105
	eor	#$00FF
	phx
	asl	a
	tax
	lda	f:tbl_02C0BA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02C0BA:
	.addr	sub_02C0E0
	.addr	sub_02C121
	.addr	sub_02C121
	.addr	sub_02C121
	.addr	sub_02C121
	.addr	sub_02C0E7
	.addr	sub_02C121
	.addr	sub_02C4B1
	.addr	sub_02C4C2
	.addr	sub_02C4A0
	.addr	sub_02C48F
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0
	.addr	sub_02C0E0

sub_02C0E0:
	lda	#$FFFF
	sta	$06,x
	sec
	rts

sub_02C0E7:
	jsr	a:sub_02CB85
	bcc	loc_02C104
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	tya
	bne	loc_02C103
	lda	zp_78
	bit	#$0007
	bne	loc_02C103
	dec	$06,x
loc_02C103:
	clc
loc_02C104:
	rts
loc_02C105:
	bit	#$0010
	beq	loc_02C11F
	ldy	#$0002
	bit	#$0008
	beq	loc_02C115
	ldy	#$0000
loc_02C115:
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
loc_02C11F:
	sec
	rts

sub_02C121:
	clc
	rts

sub_02C123:
	lda	$02,x
	bit	#$2000
	bne	loc_02C12D
	brl	loc_02C2DF
loc_02C12D:
	lda	$0E,x
	bit	#$0004
	bne	loc_02C14C
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	loc_02C147
	brl	loc_02C26A
loc_02C147:
	beq	loc_02C14C
	brl	loc_02C210
loc_02C14C:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	loc_02C1B6
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C2C4
	sta	zp_08
	beq	loc_02C17B
	lda	#$0001
	tsb	zp_06
loc_02C17B:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0A
	beq	loc_02C18E
	lda	#$0002
	tsb	zp_06
loc_02C18E:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0C
	beq	loc_02C1A1
	lda	#$0004
	tsb	zp_06
loc_02C1A1:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0E
	beq	loc_02C1B4
	lda	#$0008
	tsb	zp_06
loc_02C1B4:
	plx
	rts
loc_02C1B6:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C2C4
	sta	zp_0A
	beq	loc_02C1D5
	lda	#$0002
	tsb	zp_06
loc_02C1D5:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_08
	beq	loc_02C1E8
	lda	#$0001
	tsb	zp_06
loc_02C1E8:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0C
	beq	loc_02C1FB
	lda	#$0004
	tsb	zp_06
loc_02C1FB:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0E
	beq	loc_02C20E
	lda	#$0008
	tsb	zp_06
loc_02C20E:
	plx
	rts
loc_02C210:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C2C4
	sta	zp_0C
	beq	loc_02C22F
	lda	#$0004
	tsb	zp_06
loc_02C22F:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_08
	beq	loc_02C242
	lda	#$0001
	tsb	zp_06
loc_02C242:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0A
	beq	loc_02C255
	lda	#$0002
	tsb	zp_06
loc_02C255:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0E
	beq	loc_02C268
	lda	#$0008
	tsb	zp_06
loc_02C268:
	plx
	rts
loc_02C26A:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C2C4
	sta	zp_0E
	beq	loc_02C289
	lda	#$0008
	tsb	zp_06
loc_02C289:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_08
	beq	loc_02C29C
	lda	#$0001
	tsb	zp_06
loc_02C29C:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0A
	beq	loc_02C2AF
	lda	#$0002
	tsb	zp_06
loc_02C2AF:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:sub_02C2C4
	sta	zp_0C
	beq	loc_02C2C2
	lda	#$0004
	tsb	zp_06
loc_02C2C2:
	plx
	rts

sub_02C2C4:
	bit	#$0080
	bne	loc_02C2CD
	and	#$0007
	rts
loc_02C2CD:
	cmp	#$00FF
	beq	loc_02C2DB
	cmp	#$00F5
	bcc	loc_02C2DB
	lda	#$0000
	rts
loc_02C2DB:
	lda	#$0001
	rts
loc_02C2DF:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	plx
	sta	zp_04
	lda	a:wram_1594
	bne	loc_02C325
	lda	$0E,x
	cmp	#$0100
	bcc	loc_02C325
	cmp	#$0200
	bcs	loc_02C325
	lda	$0A,x
	cmp	#$0100
	bcc	loc_02C325
	cmp	#$0200
	bcs	loc_02C325
	cmp	#$0154
	bcc	loc_02C328
	cmp	#$01AC
	bcs	loc_02C32E
loc_02C325:
	stz	zp_06
	rts
loc_02C328:
	lda	#$0005
	sta	zp_06
	rts
loc_02C32E:
	lda	#$000A
	sta	zp_06
	rts

sub_02C334:
	lda	a:wram_15A8
	beq	loc_02C33B
	clc
	rtl
loc_02C33B:
	jsr	a:sub_02C571
	jsr	a:sub_02C71F
	jsr	a:sub_02C345
	rtl

sub_02C345:
	lda	zp_04
	beq	loc_02C372
	cmp	#$00F9
	beq	loc_02C351
	stz	a:$0672,x
loc_02C351:
	bit	#$0080
	bne	loc_02C377
	bit	#$0010
	beq	loc_02C370
	ldy	#$0002
	bit	#$0008
	beq	loc_02C366
	ldy	#$0000
loc_02C366:
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
loc_02C370:
	clc
	rts
loc_02C372:
	stz	a:$0672,x
	clc
	rts
loc_02C377:
	eor	#$00FF
	phx
	asl	a
	tax
	lda	f:tbl_02C387,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02C387:
	.addr	sub_02C56A
	.addr	sub_02C3AD
	.addr	sub_02C3B2
	.addr	sub_02C3B7
	.addr	sub_02C3DF
	.addr	sub_02C3E4
	.addr	sub_02C42D
	.addr	sub_02C4B1
	.addr	sub_02C4C2
	.addr	sub_02C4A0
	.addr	sub_02C48F
	.addr	sub_02C4D3
	.addr	sub_02C4E4
	.addr	sub_02C4F4
	.addr	sub_02C504
	.addr	sub_02C514
	.addr	sub_02C52A
	.addr	sub_02C540
	.addr	sub_02C556

sub_02C3AD:
	jsr	a:sub_02CA1D
	clc
	rts

sub_02C3B2:
	jsr	a:sub_02C9F8
	clc
	rts

sub_02C3B7:
	lda	$16,x
	bpl	loc_02C3DD
	lda	a:$0090,x
	cmp	#$0002
	bne	loc_02C3D0
	; (not executed in the CDL traces)
	lda	a:wram_1594
	cmp	#$0006
	beq	loc_02C3DD
	jsr	a:sub_02CB27
	clc
	rts
loc_02C3D0:
	jsr	a:sub_02CB59
	lda	a:$0016,y
	bpl	loc_02C3DD
	lda	#$FFFF
	sta	$06,x
loc_02C3DD:
	clc
	rts

sub_02C3DF:
	jsr	a:sub_02CA49
	clc
	rts

sub_02C3E4:
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	loc_02C40C
	; (not executed in the CDL traces)
	jsr	a:sub_02CB85
	bcc	loc_02C40B
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	a:$0658,x
	clc
loc_02C40B:
	rts
loc_02C40C:
	jsr	a:sub_02CB85
	bcc	loc_02C42C
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	a:$0654,x
	clc
loc_02C42C:
	rts

sub_02C42D:
	lda	a:wram_0AD2
	cmp	#$0008
	bcs	loc_02C440
	ldy	difficulty
	lda	a:data_05E670,y
	lsr	a
	cmp	a:wram_0AC6
	bcs	loc_02C445
loc_02C440:
	stz	a:$0672,x
loc_02C443:
	clc
	rts
loc_02C445:
	lda	a:wram_15BE
	bne	loc_02C443
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	loc_02C470
	; (not executed in the CDL traces)
	jsr	a:sub_02CC00
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	a:$0658,x
	clc
	rts
loc_02C470:
	jsr	a:sub_02CC00
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	a:$0654,x
	clc
	rts

sub_02C48F:
	clc
	lda	$08,x
	adc	a:wram_15B2
	sta	$08,x
	lda	$0A,x
	adc	a:wram_15B4
	sta	$0A,x
	clc
	rts

sub_02C4A0:
	sec
	lda	$08,x
	sbc	a:wram_15B2
	sta	$08,x
	lda	$0A,x
	sbc	a:wram_15B4
	sta	$0A,x
	clc
	rts

sub_02C4B1:
	clc
	lda	$0C,x
	adc	a:wram_15B2
	sta	$0C,x
	lda	$0E,x
	adc	a:wram_15B4
	sta	$0E,x
	clc
	rts

sub_02C4C2:
	sec
	lda	$0C,x
	sbc	a:wram_15B2
	sta	$0C,x
	lda	$0E,x
	sbc	a:wram_15B4
	sta	$0E,x
	clc
	rts

sub_02C4D3:
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	stz	$1C,x
	stz	$1E,x
	brl	sub_02C56A

sub_02C4E4:
	lda	#$8000
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	stz	$1C,x
	stz	$1E,x
	bra	sub_02C56A

sub_02C4F4:
	stz	$18,x
	stz	$1A,x
	lda	#$8000
	sta	$1C,x
	lda	#$0000
	sta	$1E,x
	bra	sub_02C56A

sub_02C504:
	stz	$18,x
	stz	$1A,x
	lda	#$8000
	sta	$1C,x
	lda	#$FFFF
	sta	$1E,x
	bra	sub_02C56A

sub_02C514:
	lda	#$A57E
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$A57E
	sta	$1C,x
	lda	#$FFFF
	sta	$1E,x
	bra	sub_02C56A

sub_02C52A:
	lda	#$5A82
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	lda	#$A57E
	sta	$1C,x
	lda	#$FFFF
	sta	$1E,x
	bra	sub_02C56A

sub_02C540:
	lda	#$A57E
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$5A82
	sta	$1C,x
	lda	#$0000
	sta	$1E,x
	bra	sub_02C56A

sub_02C556:
	lda	#$5A82
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	lda	#$5A82
	sta	$1C,x
	lda	#$0000
	sta	$1E,x

sub_02C56A:
	lda	#$0002
	sta	$2C,x
	clc
	rts

sub_02C571:
	lda	$02,x
	bit	#$2000
	bne	loc_02C57B
	brl	loc_02C2DF
loc_02C57B:
	lda	$0E,x
	bit	#$0004
	bne	loc_02C59A
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	loc_02C595
	brl	loc_02C6B8
loc_02C595:
	beq	loc_02C59A
	brl	loc_02C65E
loc_02C59A:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	loc_02C604
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C712
	sta	zp_08
	beq	loc_02C5C9
	lda	#$0001
	tsb	zp_06
loc_02C5C9:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0A
	beq	loc_02C5DC
	lda	#$0002
	tsb	zp_06
loc_02C5DC:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0C
	beq	loc_02C5EF
	lda	#$0004
	tsb	zp_06
loc_02C5EF:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0E
	beq	loc_02C602
	lda	#$0008
	tsb	zp_06
loc_02C602:
	plx
	rts
loc_02C604:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C712
	sta	zp_0A
	beq	loc_02C623
	lda	#$0002
	tsb	zp_06
loc_02C623:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_08
	beq	loc_02C636
	lda	#$0001
	tsb	zp_06
loc_02C636:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0C
	beq	loc_02C649
	lda	#$0004
	tsb	zp_06
loc_02C649:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0E
	beq	loc_02C65C
	lda	#$0008
	tsb	zp_06
loc_02C65C:
	plx
	rts
loc_02C65E:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C712
	sta	zp_0C
	beq	loc_02C67D
	lda	#$0004
	tsb	zp_06
loc_02C67D:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_08
	beq	loc_02C690
	lda	#$0001
	tsb	zp_06
loc_02C690:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0A
	beq	loc_02C6A3
	lda	#$0002
	tsb	zp_06
loc_02C6A3:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0E
	beq	loc_02C6B6
	lda	#$0008
	tsb	zp_06
loc_02C6B6:
	plx
	rts
loc_02C6B8:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:sub_02C712
	sta	zp_0E
	beq	loc_02C6D7
	lda	#$0008
	tsb	zp_06
loc_02C6D7:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_08
	beq	loc_02C6EA
	lda	#$0001
	tsb	zp_06
loc_02C6EA:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0A
	beq	loc_02C6FD
	lda	#$0002
	tsb	zp_06
loc_02C6FD:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:sub_02C712
	sta	zp_0C
	beq	loc_02C710
	lda	#$0004
	tsb	zp_06
loc_02C710:
	plx
	rts

sub_02C712:
	bit	#$0080
	bne	loc_02C71B
	and	#$0007
	rts
loc_02C71B:
	lda	#$0000
	rts

sub_02C71F:
	lda	zp_06
	asl	a
	phx
	tax
	jmp	(.loword(tbl_02C727),x)
tbl_02C727:
	.addr	sub_02C747
	.addr	sub_02C896
	.addr	sub_02C7F1
	.addr	sub_02C7A0
	.addr	sub_02C85D
	.addr	sub_02C781
	.addr	sub_02C747
	.addr	sub_02C7E1
	.addr	sub_02C82A
	.addr	sub_02C747
	.addr	sub_02C773
	.addr	sub_02C7B1
	.addr	sub_02C792
	.addr	sub_02C7D1
	.addr	sub_02C7C1
	.addr	sub_02C749

sub_02C747:
	plx
	rts

sub_02C749:
	plx
	lda	zp_0C
	cmp	#$0005
	bcc	loc_02C754
	brl	loc_02C8D2
loc_02C754:
	lda	zp_08
	cmp	#$0005
	bcc	loc_02C75E
	brl	loc_02C917
loc_02C75E:
	lda	zp_0A
	cmp	#$0005
	bcc	loc_02C768
	brl	loc_02C950
loc_02C768:
	lda	zp_0E
	cmp	#$0005
	bcc	loc_02C772
	brl	loc_02C995
loc_02C772:
	rts

sub_02C773:
	plx

sub_02C774:
	lda	$0A,x
	and	#$FFF8
	ora	#$0003
	sta	$0A,x
	stz	$08,x
	rts

sub_02C781:
	plx

sub_02C782:
	lda	$0A,x
	and	#$FFF8
	ora	#$0004
	sta	$0A,x
	lda	#$FFFF
	sta	$08,x
	rts

sub_02C792:
	plx
loc_02C793:
	lda	$0E,x
	and	#$FFF8
	ora	#$0003
	sta	$0E,x
	stz	$0C,x
	rts

sub_02C7A0:
	plx
loc_02C7A1:
	lda	$0E,x
	and	#$FFF8
	ora	#$0004
	sta	$0E,x
	lda	#$FFFF
	sta	$0C,x
	rts

sub_02C7B1:
	plx
	lda	zp_0A
	cmp	#$0004
	bcc	loc_02C7BC
	brl	loc_02C8D2
loc_02C7BC:
	jsr	a:sub_02C774
	bra	loc_02C7A1

sub_02C7C1:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	loc_02C7CC
	brl	loc_02C917
loc_02C7CC:
	jsr	a:sub_02C774
	bra	loc_02C793

sub_02C7D1:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	loc_02C7DC
	brl	loc_02C950
loc_02C7DC:
	jsr	a:sub_02C782
	bra	loc_02C793

sub_02C7E1:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	loc_02C7EC
	brl	loc_02C995
loc_02C7EC:
	jsr	a:sub_02C782
	bra	loc_02C7A1

sub_02C7F1:
	plx
	lda	zp_0A
	cmp	#$0004
	bcc	loc_02C7FC
	brl	loc_02C8E9
loc_02C7FC:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DDAA,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF
	sta	$0C,x
	rts

sub_02C82A:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	loc_02C835
	brl	loc_02C928
loc_02C835:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DDAA,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

sub_02C85D:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	loc_02C868
	brl	loc_02C967
loc_02C868:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DDAA,y
	sta	$0E,x
	lda	#$FFFF
	sta	$08,x
	stz	$0C,x
	rts

sub_02C896:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	loc_02C8A1
	brl	loc_02C9B2
loc_02C8A1:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DDAA,y
	sta	$0E,x
	lda	#$FFFF
	sta	$08,x
	sta	$0C,x
	rts
loc_02C8D2:
	lda	$0E,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	bra	loc_02C8FB
loc_02C8E9:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
loc_02C8FB:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DE2A,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF
	sta	$0C,x
	rts
loc_02C917:
	lda	$0E,x
	and	#$0003
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	bra	loc_02C937
loc_02C928:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
loc_02C937:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts
loc_02C950:
	lda	$0E,x
	and	#$0003
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	bra	loc_02C979
loc_02C967:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
loc_02C979:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0E,x
	lda	#$FFFF
	sta	$08,x
	stz	$0C,x
	rts
loc_02C995:
	lda	$0E,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	bra	loc_02C9C7
loc_02C9B2:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
loc_02C9C7:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DE2A,y
	sta	$0E,x
	lda	#$FFFF
	sta	$08,x
	sta	$0C,x
	rts

sub_02C9E3:
	lda	$02,x
	bit	#$2000
	beq	loc_02C9EB
	rts
loc_02C9EB:
	ldy	$0A,x
	cpy	#$0150
	bcc	loc_02C9F6
	cpy	#$01B0
	rts
loc_02C9F6:
	sec
	rts

sub_02C9F8:
	lda	$0A,x
	and	#$FFE0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	tay
	lda	a:data_05DEAA,y
	beq	loc_02CA1C
	tay
	lda	a:$187E,y
	bne	loc_02CA1C
	lda	#$0050
	sta	a:$187E,y
	phx
	lda	#$0500
	jsl	f:sub_00B833
	plx
loc_02CA1C:
	rts

sub_02CA1D:
	ldy	#$0000
	lda	$0A,x
	cmp	#$0200
	bcc	loc_02CA2A
	ldy	#$0002
loc_02CA2A:
	lda	a:$18AC,y
	bne	loc_02CA48
	lda	#$0020
	sta	a:$18AC,y
	lda	#$0001
	sta	a:wram_15A2
	lda	#$0030
	sta	a:wram_15A4
	lda	#$0011
	jsl	f:sub_00868F
loc_02CA48:
	rts

sub_02CA49:
	lda	a:$066C,x
	bit	#$4080
	bne	loc_02CA52
	rts
loc_02CA52:
	lda	$0E,x
	cmp	#$0100
	bcs	loc_02CA5C
	brl	loc_02CAE6
loc_02CA5C:
	cmp	#$0300
	bcs	loc_02CA64
	brl	loc_02CAA5
loc_02CA64:
	lda	a:wram_18CC
	beq	loc_02CA6A
	rts
loc_02CA6A:
	lda	#$0001
	sta	a:wram_15A2
	sta	a:wram_15A4
	lda	#$0001
	sta	a:wram_18CC
	lda	#$0008
	sta	a:wram_18CE
	stz	a:wram_18D0
	ldy	#$0000
	lda	$0A,x
	cmp	#$0220
	bcc	loc_02CA8F
	ldy	#$0002
loc_02CA8F:
	sty	a:wram_18D2
	lda	a:data_05DEEA,y
	sta	a:wram_18D8
	lda	a:data_05DEEE,y
	sta	a:wram_18D4
	lda	#$0390
	sta	a:wram_18D6
	rts
loc_02CAA5:
	lda	a:wram_18BE
	beq	loc_02CAAB
	rts
loc_02CAAB:
	lda	#$0001
	sta	a:wram_15A2
	sta	a:wram_15A4
	lda	#$0001
	sta	a:wram_18BE
	lda	#$0008
	sta	a:wram_18C0
	stz	a:wram_18C2
	ldy	#$0000
	lda	$0A,x
	cmp	#$0140
	bcc	loc_02CAD0
	ldy	#$0002
loc_02CAD0:
	sty	a:wram_18C4
	lda	a:data_05DEF2,y
	sta	a:wram_18CA
	lda	a:data_05DEF6,y
	sta	a:wram_18C6
	lda	#$0230
	sta	a:wram_18C8
	rts
loc_02CAE6:
	lda	a:wram_18B0
	beq	loc_02CAEC
	rts
loc_02CAEC:
	lda	#$0001
	sta	a:wram_15A2
	sta	a:wram_15A4
	lda	#$0001
	sta	a:wram_18B0
	lda	#$0008
	sta	a:wram_18B2
	stz	a:wram_18B4
	ldy	#$0000
	lda	$0A,x
	cmp	#$0300
	bcc	loc_02CB11
	ldy	#$0002
loc_02CB11:
	sty	a:wram_18B6
	lda	a:data_05DEFA,y
	sta	a:wram_18BC
	lda	a:data_05DEFE,y
	sta	a:wram_18B8
	lda	#$0050
	sta	a:wram_18BA
	rts

sub_02CB27:
	; (not executed in the CDL traces)
	jsr	a:sub_02CB59
	lda	a:$0016,y
	bpl	loc_02CB57
	bit	#$1000
	beq	loc_02CB57
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02CB57
	phx
	phy
	txa
	tyx
	clc
	adc	#$10C0
	tay
	jsl	f:sub_02EBBF
	ply
	plx
loc_02CB57:
	sec
	rts

sub_02CB59:
	lda	$0A,x
	xba
	and	#$0003
	sta	zp_FA
	lda	$0E,x
	asl	a
	asl	a
	xba
	and	#$000C
	ora	zp_FA
	asl	a
	tay
	lda	a:wram_1594
	beq	loc_02CB7B
	cmp	#$0004
	beq	loc_02CB80
	ldy	#$0AC0
	rts
loc_02CB7B:
	lda	a:data_05DF02,y
	tay
	rts
loc_02CB80:
	lda	a:data_05DF22,y
	tay
	rts

sub_02CB85:
	lda	$0A,x
	and	#$001F
	bne	loc_02CB91
loc_02CB8C:
	ldy	#$0010
	clc
	rts
loc_02CB91:
	sec
	sbc	#$0010
	sta	zp_08
	sta	zp_FC
	lda	$0E,x
	and	#$001F
	beq	loc_02CB8C
	sec
	sbc	#$0010
	sta	zp_0A
	sta	zp_FE
	jsl	f:sub_1DABA0
	pha
	lda	zp_FE
	bpl	loc_02CBB5
	eor	#$FFFF
	inc	a
loc_02CBB5:
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	zp_FC
	bpl	loc_02CBC3
	eor	#$FFFF
	inc	a
loc_02CBC3:
	ora	zp_FA
	tay
	lda	a:data_05DF46,y
	and	#$00FF
	tay
	beq	loc_02CBD7
	lda	zp_78
	bit	#$0007
	bne	loc_02CBD7
	dey
loc_02CBD7:
	pla
	phy
	inc	a
	and	#$00FF
	jsl	f:sub_1DACA4
	lda	$0A,x
	and	#$FFE0
	clc
	adc	#$0010
	clc
	adc	zp_08
	sta	$0A,x
	lda	$0E,x
	and	#$FFE0
	clc
	adc	#$0010
	clc
	adc	zp_0A
	sta	$0E,x
	ply
	sec
	rts

sub_02CC00:
	lda	$0A,x
	sec
	sbc	#$0200
	sta	zp_08
	sta	zp_FC
	lda	$0E,x
	sec
	sbc	#$0200
	sta	zp_0A
	sta	zp_FE
	lda	a:$0672,x
	beq	loc_02CC1F
	lda	a:$0670,x
	pha
	bra	loc_02CC32
loc_02CC1F:
	lda	#$0001
	sta	a:$0672,x
	jsl	f:sub_1DABA0
	pha
	lda	zp_FC
	sta	zp_08
	lda	zp_FE
	sta	zp_0A
loc_02CC32:
	jsl	f:sub_1DAED0
	tay
	iny
	pla
	phy
	inc	a
	and	#$00FF
	sta	a:$0670,x
	jsl	f:sub_1DACA4
	lda	#$0200
	clc
	adc	zp_08
	sta	$0A,x
	lda	#$0200
	clc
	adc	zp_0A
	sta	$0E,x
	ply
	rts
loc_02CC57:
	rep	#$30
	lda	a:wram_1594
	cmp	#$0002
	beq	loc_02CC79
	cmp	#$0006
	beq	loc_02CC89
	jsr	a:sub_02D18D
	jsr	a:sub_02CC99
	jsr	a:sub_02CD67
	lda	a:wram_0F50
	dec	a
	bne	loc_02CC78
	jsr	a:sub_02D106
loc_02CC78:
	rtl
loc_02CC79:
	jsr	a:sub_02D2AA
	jsr	a:sub_02CEB4
	lda	a:wram_0F50
	dec	a
	bne	loc_02CC88
	jsr	a:sub_02D0FF
loc_02CC88:
	rtl
loc_02CC89:
	jsr	a:sub_02D1A7
	jsr	a:sub_02D2E5
	lda	a:wram_0F50
	dec	a
	bne	loc_02CC98
	jsr	a:sub_02D106
loc_02CC98:
	rtl

sub_02CC99:
	ldy	#$0D40
loc_02CC9C:
	lda	a:$0016,y
	bmi	loc_02CCA4
	brl	loc_02CD58
loc_02CCA4:
	lda	a:$002E,y
	bit	#$0003
	bne	loc_02CCAF
	brl	loc_02CD58
loc_02CCAF:
	lda	#$0008
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$0008
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0480
loc_02CCC4:
	lda	$10,x
	dec	a
	bmi	loc_02CD03
	lda	a:$0002,y
	eor	$02,x
	bit	#$3000
	bne	loc_02CD03
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	loc_02CD03
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	loc_02CD03
	jsl	f:sub_02B8D2
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02CD03
	jsl	f:sub_02EB75
loc_02CD03:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcc	loc_02CCC4
	lda	#$000C
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$000C
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0980
loc_02CD23:
	lda	$16,x
	bpl	loc_02CD4D
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02CD4D
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02CD4D
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
loc_02CD4D:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02CD23
loc_02CD58:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	loc_02CD66
	brl	loc_02CC9C
loc_02CD66:
	rts

sub_02CD67:
	jsr	a:sub_02CE2C
	lda	a:wram_0ED6
	bmi	loc_02CD70
	rts
loc_02CD70:
	lda	#$000C
	clc
	adc	a:wram_0ECA
	sta	zp_18
	lda	#$000C
	clc
	adc	a:wram_0ECE
	sta	zp_1A
	ldx	#$0D40
loc_02CD85:
	lda	$16,x
	bpl	loc_02CDC6
	lda	$02,x
	eor	a:wram_0EC2
	bit	#$3000
	bne	loc_02CDC6
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02CDC6
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02CDC6
	lda	a:p1_barrier_timer
	beq	loc_02CDC0
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02CDC6
	ldy	#$1F80
	jsl	f:sub_02EBBF
	bra	loc_02CDC6
loc_02CDC0:
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02CDC6:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02CD85
loc_02CDD1:
	lda	a:wram_0ED2
	cmp	#$0005
	beq	loc_02CE2B
	lda	#$0008
	clc
	adc	a:wram_0ECA
	sta	zp_18
	lda	#$0008
	clc
	adc	a:wram_0ECE
	sta	zp_1A
	ldx	#$0300
loc_02CDEE:
	lda	$10,x
	dec	a
	bmi	loc_02CE20
	lda	$02,x
	eor	a:wram_0EC2
	bit	#$3000
	bne	loc_02CE20
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	loc_02CE20
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	loc_02CE20
	jsl	f:sub_02B8D2
	lda	a:p1_barrier_timer
	bne	loc_02CE20
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02CE20:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	loc_02CDEE
loc_02CE2B:
	rts

sub_02CE2C:
	lda	#$000C
	clc
	adc	a:wram_0ECA
	sta	zp_18
	lda	#$000C
	clc
	adc	a:wram_0ECE
	sta	zp_1A
	ldx	#$0980
loc_02CE41:
	lda	$16,x
	bit	#$4000
	bne	loc_02CE52
	bit	#$8000
	beq	loc_02CEA8
	lda	a:wram_0ED6
	bpl	loc_02CEA8
loc_02CE52:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02CEA8
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02CEA8
	lda	$16,x
	bpl	loc_02CE77
	lda	a:p1_barrier_timer
	bne	loc_02CE75
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02CE75:
	bra	loc_02CEA8
loc_02CE77:
	lda	#$0012
	jsl	f:sub_00868F
	lda	$14,x
	cmp	#$0006
	bcs	loc_02CE8D
	ldy	a:wram_1F9E
	sta	a:$1F84,y
	bra	loc_02CEA6
loc_02CE8D:
	beq	loc_02CEA0
	lda	a:p1_bombs
	inc	a
	cmp	#$000A
	bcc	loc_02CE9B
	; (not executed in the CDL traces)
	lda	#$0009
loc_02CE9B:
	sta	a:p1_bombs
	bra	loc_02CEA6
loc_02CEA0:
	; (not executed in the CDL traces)
	lda	#$0200
	sta	a:p1_barrier_timer
loc_02CEA6:
	stz	$24,x
loc_02CEA8:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02CE41
	rts

sub_02CEB4:
	ldx	#$0480
loc_02CEB7:
	lda	$10,x
	dec	a
	bpl	loc_02CEBF
	brl	loc_02CFD5
loc_02CEBF:
	lda	a:wram_0B56
	bpl	loc_02CF2B
	lda	a:wram_0B6E
	bit	#$0003
	beq	loc_02CF09
	lda	a:wram_0B4A
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02CF09
	lda	a:wram_0B4E
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02CF09
	jsl	f:sub_02B8D2
	lda	a:wram_0B6E
	ora	#$0040
	sta	a:wram_0B6E
	lda	a:wram_0B46
	sec
	sbc	$06,x
	sta	a:wram_0B46
	bpl	loc_02CF09
	; (not executed in the CDL traces)
	ldy	#$0B40
	jsl	f:sub_02EB75
loc_02CF09:
	lda	a:wram_0ACA
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	loc_02CF2B
	lda	a:wram_0ACE
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	loc_02CF2B
	jsl	f:sub_02B8D2
loc_02CF2B:
	lda	a:wram_0B96
	bpl	loc_02CF78
	lda	a:wram_0BAE
	bit	#$0003
	bne	loc_02CF3B
	brl	loc_02CF78
loc_02CF3B:
	lda	a:wram_0B8A
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	loc_02CF78
	lda	a:wram_0B8E
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	loc_02CF78
	jsl	f:sub_02B8D2
	lda	a:wram_0BAE
	ora	#$0040
	sta	a:wram_0BAE
	lda	a:wram_0B86
	sec
	sbc	$06,x
	sta	a:wram_0B86
	bpl	loc_02CF78
	; (not executed in the CDL traces)
	ldy	#$0B80
	jsl	f:sub_02EB75
loc_02CF78:
	ldy	#$0BC0
loc_02CF7B:
	lda	a:$0016,y
	bpl	loc_02CFCA
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02CFCA
	lda	a:$000A,y
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02CFCA
	lda	a:$000E,y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02CFCA
	jsl	f:sub_02B8D2
	lda	a:$0016,y
	bit	#$1000
	beq	loc_02CFCA
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02CFCA
	; (not executed in the CDL traces)
	jsl	f:sub_02EB75
loc_02CFCA:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	loc_02CF7B
loc_02CFD5:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	loc_02CFE3
	brl	loc_02CEB7
loc_02CFE3:
	jsr	a:sub_02CE2C
	lda	a:wram_0ED6
	bmi	loc_02CFEC
	rts
loc_02CFEC:
	lda	a:wram_0B96
	bpl	loc_02D036
	lda	a:wram_0B8A
	clc
	adc	#$000E
	sec
	sbc	a:wram_0ECA
	cmp	#$001C
	bcs	loc_02D036
	lda	a:wram_0B8E
	clc
	adc	#$000E
	sec
	sbc	a:wram_0ECE
	cmp	#$001C
	bcs	loc_02D036
	lda	a:p1_barrier_timer
	beq	loc_02D030
	; (not executed in the CDL traces)
	lda	a:wram_0BAE
	ora	#$0040
	sta	a:wram_0BAE
	dec	a:wram_0B86
	bpl	loc_02D036
	ldx	#$0B80
	ldy	#$1F80
	jsl	f:sub_02EBBF
	bra	loc_02D036
loc_02D030:
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02D036:
	ldx	#$0BC0
loc_02D039:
	lda	$16,x
	bpl	loc_02D07A
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECA
	cmp	#$0024
	bcs	loc_02D07A
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECE
	cmp	#$0024
	bcs	loc_02D07A
	; (not executed in the CDL traces)
	lda	a:p1_barrier_timer
	beq	loc_02D074
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D07A
	ldy	#$1F80
	jsl	f:sub_02EBBF
	bra	loc_02D07A
loc_02D074:
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02D07A:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D039
	lda	a:p1_barrier_timer
	beq	loc_02D0CC
	; (not executed in the CDL traces)
	lda	a:wram_0B56
	bpl	loc_02D0CC
	lda	a:wram_0B4A
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECA
	cmp	#$0024
	bcs	loc_02D0CC
	lda	a:wram_0B4E
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECE
	cmp	#$0024
	bcs	loc_02D0CC
	lda	a:wram_0B6E
	bit	#$0040
	bne	loc_02D0BD
	ora	#$0040
	sta	a:wram_0B6E
loc_02D0BD:
	dec	a:wram_0B46
	bpl	loc_02D0CC
	ldx	#$0B40
	ldy	#$1F80
	jsl	f:sub_02EBBF
loc_02D0CC:
	lda	a:wram_0AD6
	bpl	loc_02D0FC
	lda	a:wram_0ACA
	clc
	adc	#$001A
	sec
	sbc	a:wram_0ECA
	cmp	#$0034
	bcs	loc_02D0FC
	lda	a:wram_0ACE
	clc
	adc	#$001A
	sec
	sbc	a:wram_0ECE
	cmp	#$0034
	bcs	loc_02D0FC
	lda	a:p1_barrier_timer
	bne	loc_02D0FC
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02D0FC:
	jmp	a:loc_02CDD1

sub_02D0FF:
	lda	#$0DC0
	sta	zp_1E
	bra	loc_02D10B

sub_02D106:
	lda	#$0EC0
	sta	zp_1E
loc_02D10B:
	lda	a:wram_0F54
	asl	a
	sta	zp_1C
	lsr	a
	clc
	adc	a:wram_0F4A
	sta	zp_18
	lda	a:wram_0F4E
	clc
	adc	a:wram_0F54
	sta	zp_1A
	ldx	#$0AC0
loc_02D124:
	lda	$16,x
	bpl	loc_02D159
	lda	$2E,x
	bit	#$0003
	beq	loc_02D159
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	loc_02D159
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	loc_02D159
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	lda	$06,x
	sec
	sbc	a:wram_0F46
	sta	$06,x
	bpl	loc_02D159
	ldy	#$1F80
	jsl	f:sub_02EBBF
loc_02D159:
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_1E
	bcc	loc_02D124
	ldx	#$0300
loc_02D166:
	lda	$10,x
	dec	a
	bmi	loc_02D181
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	loc_02D181
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	loc_02D181
	jsl	f:sub_02B8D2
loc_02D181:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	loc_02D166
	rts

sub_02D18D:
	lda	#$FFFF
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
loc_02D197:
	jsr	a:sub_02D1DD
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D197
	bra	loc_02D1BD

sub_02D1A7:
	lda	#$FFFF
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:sub_02D1DD
	ldx	zp_1A
	bne	loc_02D1BB
	; (not executed in the CDL traces)
	brl	loc_02D2C8
loc_02D1BB:
	bra	loc_02D1C4
loc_02D1BD:
	ldx	zp_1A
	bne	loc_02D1C4
	brl	loc_02D29A
loc_02D1C4:
	lda	zp_18
	cmp	#$2000
	bcc	loc_02D1D4
	lda	$2E,x
	and	#$FFEF
	sta	$2E,x
	bra	loc_02D206
loc_02D1D4:
	lda	$2E,x
	ora	#$0010
	sta	$2E,x
	bra	loc_02D206

sub_02D1DD:
	lda	$10,x
	beq	loc_02D205
	lda	$0A,x
	sec
	sbc	a:wram_1510
	sta	zp_08
	lda	$0E,x
	sec
	sbc	a:wram_1512
	sta	zp_0A
	jsl	f:sub_1DAD3C
	cmp	zp_18
	bcs	loc_02D205
	sta	zp_18
	stx	zp_1A
	lda	zp_08
	sta	zp_1C
	lda	zp_0A
	sta	zp_1E
loc_02D205:
	rts
loc_02D206:
	lda	zp_1C
	sta	zp_08
	lda	zp_1E
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	a:wram_1514
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
loc_02D222:
	lda	a:title_menu_cursor
	beq	loc_02D22A
	dec	a
	beq	loc_02D262
loc_02D22A:
	lda	a:data_05E046,y
	beq	loc_02D240
	sta	a:player1_obj
	lda	a:data_05E066,y
	sta	a:wram_020A
	lda	#$0070
	sta	a:wram_020E
	bra	loc_02D246
loc_02D240:
	lda	#$00F0
	sta	a:wram_020E
loc_02D246:
	lda	a:data_05E056,y
	beq	loc_02D25B
	sta	a:player2_obj
	lda	#$0078
	sta	a:wram_024A
	lda	a:data_05E076,y
	sta	a:wram_024E
	rts
loc_02D25B:
	lda	#$00F0
	sta	a:wram_024E
	rts
loc_02D262:
	lda	a:data_05E046,y
	beq	loc_02D278
	sta	a:player1_obj
	lda	a:data_05E066,y
	sta	a:wram_020A
	lda	#$0030
	sta	a:wram_020E
	bra	loc_02D27E
loc_02D278:
	lda	#$00F0
	sta	a:wram_020E
loc_02D27E:
	lda	a:data_05E056,y
	beq	loc_02D293
	sta	a:player2_obj
	lda	#$0078
	sta	a:wram_024A
	lda	a:data_05E086,y
	sta	a:wram_024E
	rts
loc_02D293:
	lda	#$00F0
	sta	a:wram_024E
	rts
loc_02D29A:
	lda	#$FFFF
	sta	a:wram_159A
	lda	zp_78
	asl	a
	and	#$000E
	tay
	jmp	a:loc_02D222

sub_02D2AA:
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	loc_02D29A
	cmp	#$0009
	beq	loc_02D29A
	cmp	#$000A
	beq	loc_02D29A
	cmp	#$000B
	beq	loc_02D29A
	cmp	#$0011
	bcc	loc_02D2D2
loc_02D2C8:
	lda	#$00F0
	sta	a:wram_020E
	sta	a:wram_024E
	rts
loc_02D2D2:
	lda	$0A,x
	sec
	sbc	a:wram_1510
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:wram_1512
	sta	zp_1E
	jmp	a:loc_02D206

sub_02D2E5:
	jsr	a:sub_02D2EE
	jsr	a:sub_02CE2C
	jmp	a:loc_02D3AF

sub_02D2EE:
	ldx	#$0480
loc_02D2F1:
	lda	$10,x
	dec	a
	bpl	loc_02D2F9
	brl	loc_02D3A0
loc_02D2F9:
	lda	a:wram_0AD6
	bpl	loc_02D343
	lda	a:wram_0AEE
	bit	#$0003
	beq	loc_02D343
	lda	a:wram_0ACA
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02D343
	lda	a:wram_0ACE
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02D343
	jsl	f:sub_02B8D2
	lda	a:wram_0AEE
	ora	#$0040
	sta	a:wram_0AEE
	lda	a:wram_0AC6
	sec
	sbc	$06,x
	sta	a:wram_0AC6
	bpl	loc_02D343
	; (not executed in the CDL traces)
	ldy	#$0AC0
	jsl	f:sub_02EB75
loc_02D343:
	ldy	#$0B40
loc_02D346:
	lda	a:$0016,y
	bpl	loc_02D395
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02D395
	lda	a:$000A,y
	clc
	adc	#$0006
	sec
	sbc	$0A,x
	cmp	#$000C
	bcs	loc_02D395
	lda	a:$000E,y
	clc
	adc	#$0006
	sec
	sbc	$0E,x
	cmp	#$000C
	bcs	loc_02D395
	jsl	f:sub_02B8D2
	lda	a:$0016,y
	bit	#$1000
	beq	loc_02D395
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02D395
	jsl	f:sub_02EB9A
loc_02D395:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcc	loc_02D346
loc_02D3A0:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	loc_02D3AE
	brl	loc_02D2F1
loc_02D3AE:
	rts
loc_02D3AF:
	lda	a:wram_0ED6
	bmi	loc_02D3B5
	rts
loc_02D3B5:
	lda	a:wram_0AD6
	bpl	loc_02D3F7
	lda	a:wram_0ACA
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECA
	cmp	#$0024
	bcs	loc_02D3F7
	lda	a:wram_0ACE
	clc
	adc	#$0012
	sec
	sbc	a:wram_0ECE
	cmp	#$0024
	bcs	loc_02D3F7
	; (not executed in the CDL traces)
	lda	a:wram_0AEE
	bit	#$0040
	bne	loc_02D3E8
	ora	#$0040
	sta	a:wram_0AEE
loc_02D3E8:
	dec	a:wram_0AC6
	bpl	loc_02D3F7
	ldx	#$0AC0
	ldy	#$1F80
	jsl	f:sub_02EBBF
loc_02D3F7:
	ldx	#$0B40
loc_02D3FA:
	lda	$16,x
	bpl	loc_02D43B
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:wram_0ECA
	cmp	#$0014
	bcs	loc_02D43B
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:wram_0ECE
	cmp	#$0014
	bcs	loc_02D43B
	lda	a:p1_barrier_timer
	beq	loc_02D435
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D43B
	ldy	#$1F80
	jsl	f:sub_02EBCE
	bra	loc_02D43B
loc_02D435:
	lda	#$FFFF
	sta	a:wram_0EC6
loc_02D43B:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02D3FA
	jmp	a:loc_02CDD1
loc_02D449:
	rep	#$30
	lda	a:wram_1594
	cmp	#$0002
	beq	loc_02D46B
	cmp	#$0006
	beq	loc_02D47B
	jsr	a:sub_02D97F
	jsr	a:sub_02D48B
	jsr	a:sub_02D559
	lda	a:wram_0F90
	dec	a
	bne	loc_02D46A
	jsr	a:sub_02D8F8
loc_02D46A:
	rtl
loc_02D46B:
	; (not executed in the CDL traces)
	jsr	a:sub_02DA9C
	jsr	a:sub_02D6A6
	lda	a:wram_0F90
	dec	a
	bne	loc_02D47A
	jsr	a:sub_02D8F1
loc_02D47A:
	rtl
loc_02D47B:
	jsr	a:sub_02D999
	jsr	a:sub_02DAD7
	lda	a:wram_0F90
	dec	a
	bne	loc_02D48A
	jsr	a:sub_02D8F8
loc_02D48A:
	rtl

sub_02D48B:
	ldy	#$0D40
loc_02D48E:
	lda	a:$0016,y
	bmi	loc_02D496
	brl	loc_02D54A
loc_02D496:
	lda	a:$002E,y
	bit	#$0003
	bne	loc_02D4A1
	brl	loc_02D54A
loc_02D4A1:
	lda	#$0008
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$0008
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0700
loc_02D4B6:
	lda	$10,x
	dec	a
	bmi	loc_02D4F5
	lda	a:$0002,y
	eor	$02,x
	bit	#$3000
	bne	loc_02D4F5
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	loc_02D4F5
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	loc_02D4F5
	jsl	f:sub_02B8D2
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02D4F5
	jsl	f:sub_02EB75
loc_02D4F5:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcc	loc_02D4B6
	lda	#$000C
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$000C
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0980
loc_02D515:
	lda	$16,x
	bpl	loc_02D53F
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02D53F
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02D53F
	; (not executed in the CDL traces)
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
loc_02D53F:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02D515
loc_02D54A:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	loc_02D558
	brl	loc_02D48E
loc_02D558:
	rts

sub_02D559:
	jsr	a:sub_02D61E
	lda	a:wram_0F16
	bmi	loc_02D562
	rts
loc_02D562:
	lda	#$000C
	clc
	adc	a:wram_0F0A
	sta	zp_18
	lda	#$000C
	clc
	adc	a:wram_0F0E
	sta	zp_1A
	ldx	#$0D40
loc_02D577:
	lda	$16,x
	bpl	loc_02D5B8
	lda	$02,x
	eor	a:wram_0F02
	bit	#$3000
	bne	loc_02D5B8
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02D5B8
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02D5B8
	lda	a:p2_barrier_timer
	beq	loc_02D5B2
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D5B8
	ldy	#$1FC0
	jsl	f:sub_02EBBF
	bra	loc_02D5B8
loc_02D5B2:
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D5B8:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02D577
loc_02D5C3:
	lda	a:wram_0F12
	cmp	#$0005
	beq	loc_02D61D
	lda	#$0008
	clc
	adc	a:wram_0F0A
	sta	zp_18
	lda	#$0008
	clc
	adc	a:wram_0F0E
	sta	zp_1A
	ldx	#$0300
loc_02D5E0:
	lda	$10,x
	dec	a
	bmi	loc_02D612
	lda	$02,x
	eor	a:wram_0F02
	bit	#$3000
	bne	loc_02D612
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	loc_02D612
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	loc_02D612
	jsl	f:sub_02B8D2
	lda	a:p2_barrier_timer
	bne	loc_02D612
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D612:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	loc_02D5E0
loc_02D61D:
	rts

sub_02D61E:
	lda	#$000C
	clc
	adc	a:wram_0F0A
	sta	zp_18
	lda	#$000C
	clc
	adc	a:wram_0F0E
	sta	zp_1A
	ldx	#$0980
loc_02D633:
	lda	$16,x
	bit	#$4000
	bne	loc_02D644
	bit	#$8000
	beq	loc_02D69A
	lda	a:wram_0F16
	bpl	loc_02D69A
loc_02D644:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02D69A
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02D69A
	lda	$16,x
	bpl	loc_02D669
	lda	a:p2_barrier_timer
	bne	loc_02D667
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D667:
	bra	loc_02D69A
loc_02D669:
	lda	#$0012
	jsl	f:sub_00868F
	lda	$14,x
	cmp	#$0006
	bcs	loc_02D67F
	ldy	a:wram_1FDE
	sta	a:$1FC4,y
	bra	loc_02D698
loc_02D67F:
	; (not executed in the CDL traces)
	beq	loc_02D692
	lda	a:p2_bombs
	inc	a
	cmp	#$000A
	bcc	loc_02D68D
	lda	#$0009
loc_02D68D:
	sta	a:p2_bombs
	bra	loc_02D698
loc_02D692:
	lda	#$0200
	sta	a:p2_barrier_timer
loc_02D698:
	stz	$24,x
loc_02D69A:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02D633
	rts

sub_02D6A6:
	; (not executed in the CDL traces)
	ldx	#$0700
loc_02D6A9:
	lda	$10,x
	dec	a
	bpl	loc_02D6B1
	brl	loc_02D7C7
loc_02D6B1:
	lda	a:wram_0B56
	bpl	loc_02D71D
	lda	a:wram_0B6E
	bit	#$0003
	beq	loc_02D6FB
	lda	a:wram_0B4A
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02D6FB
	lda	a:wram_0B4E
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02D6FB
	jsl	f:sub_02B8D2
	lda	a:wram_0B6E
	ora	#$0040
	sta	a:wram_0B6E
	lda	a:wram_0B46
	sec
	sbc	$06,x
	sta	a:wram_0B46
	bpl	loc_02D6FB
	ldy	#$0B40
	jsl	f:sub_02EB75
loc_02D6FB:
	lda	a:wram_0ACA
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	loc_02D71D
	lda	a:wram_0ACE
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	loc_02D71D
	jsl	f:sub_02B8D2
loc_02D71D:
	lda	a:wram_0B96
	bpl	loc_02D76A
	lda	a:wram_0BAE
	bit	#$0003
	bne	loc_02D72D
	brl	loc_02D76A
loc_02D72D:
	lda	a:wram_0B8A
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	loc_02D76A
	lda	a:wram_0B8E
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	loc_02D76A
	jsl	f:sub_02B8D2
	lda	a:wram_0BAE
	ora	#$0040
	sta	a:wram_0BAE
	lda	a:wram_0B86
	sec
	sbc	$06,x
	sta	a:wram_0B86
	bpl	loc_02D76A
	ldy	#$0B80
	jsl	f:sub_02EB75
loc_02D76A:
	ldy	#$0BC0
loc_02D76D:
	lda	a:$0016,y
	bpl	loc_02D7BC
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02D7BC
	lda	a:$000A,y
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02D7BC
	lda	a:$000E,y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02D7BC
	jsl	f:sub_02B8D2
	lda	a:$0016,y
	bit	#$1000
	beq	loc_02D7BC
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02D7BC
	jsl	f:sub_02EB75
loc_02D7BC:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	loc_02D76D
loc_02D7C7:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	loc_02D7D5
	brl	loc_02D6A9
loc_02D7D5:
	jsr	a:sub_02D61E
	lda	a:wram_0F16
	bmi	loc_02D7DE
	rts
loc_02D7DE:
	lda	a:wram_0B96
	bpl	loc_02D828
	lda	a:wram_0B8A
	clc
	adc	#$000E
	sec
	sbc	a:wram_0F0A
	cmp	#$001C
	bcs	loc_02D828
	lda	a:wram_0B8E
	clc
	adc	#$000E
	sec
	sbc	a:wram_0F0E
	cmp	#$001C
	bcs	loc_02D828
	lda	a:p2_barrier_timer
	beq	loc_02D822
	lda	a:wram_0BAE
	ora	#$0040
	sta	a:wram_0BAE
	dec	a:wram_0B86
	bpl	loc_02D828
	ldx	#$0B80
	ldy	#$1FC0
	jsl	f:sub_02EBBF
	bra	loc_02D828
loc_02D822:
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D828:
	ldx	#$0BC0
loc_02D82B:
	lda	$16,x
	bpl	loc_02D86C
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0A
	cmp	#$0024
	bcs	loc_02D86C
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0E
	cmp	#$0024
	bcs	loc_02D86C
	lda	a:p2_barrier_timer
	beq	loc_02D866
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D86C
	ldy	#$1FC0
	jsl	f:sub_02EBBF
	bra	loc_02D86C
loc_02D866:
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D86C:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D82B
	lda	a:p2_barrier_timer
	beq	loc_02D8BE
	lda	a:wram_0B56
	bpl	loc_02D8BE
	lda	a:wram_0B4A
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0A
	cmp	#$0024
	bcs	loc_02D8BE
	lda	a:wram_0B4E
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0E
	cmp	#$0024
	bcs	loc_02D8BE
	lda	a:wram_0B6E
	bit	#$0040
	bne	loc_02D8AF
	ora	#$0040
	sta	a:wram_0B6E
loc_02D8AF:
	dec	a:wram_0B46
	bpl	loc_02D8BE
	ldx	#$0B40
	ldy	#$1FC0
	jsl	f:sub_02EBBF
loc_02D8BE:
	lda	a:wram_0AD6
	bpl	loc_02D8EE
	lda	a:wram_0ACA
	clc
	adc	#$001A
	sec
	sbc	a:wram_0F0A
	cmp	#$0034
	bcs	loc_02D8EE
	lda	a:wram_0ACE
	clc
	adc	#$001A
	sec
	sbc	a:wram_0F0E
	cmp	#$0034
	bcs	loc_02D8EE
	lda	a:p2_barrier_timer
	bne	loc_02D8EE
	lda	#$FFFF
	sta	a:wram_0F06
loc_02D8EE:
	jmp	a:loc_02D5C3

sub_02D8F1:
	; (not executed in the CDL traces)
	lda	#$0DC0
	sta	zp_1E
	bra	loc_02D8FD

sub_02D8F8:
	lda	#$0EC0
	sta	zp_1E
loc_02D8FD:
	lda	a:wram_0F94
	asl	a
	sta	zp_1C
	lsr	a
	clc
	adc	a:wram_0F8A
	sta	zp_18
	lda	a:wram_0F8E
	clc
	adc	a:wram_0F94
	sta	zp_1A
	ldx	#$0AC0
loc_02D916:
	lda	$16,x
	bpl	loc_02D94B
	lda	$2E,x
	bit	#$0003
	beq	loc_02D94B
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	loc_02D94B
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	loc_02D94B
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	lda	$06,x
	sec
	sbc	a:wram_0F86
	sta	$06,x
	bpl	loc_02D94B
	ldy	#$1FC0
	jsl	f:sub_02EBBF
loc_02D94B:
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_1E
	bcc	loc_02D916
	ldx	#$0300
loc_02D958:
	lda	$10,x
	dec	a
	bmi	loc_02D973
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	loc_02D973
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	loc_02D973
	jsl	f:sub_02B8D2
loc_02D973:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	loc_02D958
	rts

sub_02D97F:
	lda	#$FFFF
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
loc_02D989:
	jsr	a:sub_02D9CF
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D989
	bra	loc_02D9AF

sub_02D999:
	; (not executed in the CDL traces)
	lda	#$FFFF
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:sub_02D9CF
	ldx	zp_1A
	bne	loc_02D9AD
	brl	loc_02DABA
loc_02D9AD:
	bra	loc_02D9B6
loc_02D9AF:
	ldx	zp_1A
	bne	loc_02D9B6
	; (not executed in the CDL traces)
	brl	loc_02DA8C
loc_02D9B6:
	lda	zp_18
	cmp	#$2000
	bcc	loc_02D9C6
	lda	$2E,x
	and	#$FFDF
	sta	$2E,x
	bra	loc_02D9F8
loc_02D9C6:
	lda	$2E,x
	ora	#$0020
	sta	$2E,x
	bra	loc_02D9F8

sub_02D9CF:
	lda	$10,x
	beq	loc_02D9F7
	lda	$0A,x
	sec
	sbc	a:wram_1550
	sta	zp_08
	lda	$0E,x
	sec
	sbc	a:wram_1552
	sta	zp_0A
	jsl	f:sub_1DAD3C
	cmp	zp_18
	bcs	loc_02D9F7
	sta	zp_18
	stx	zp_1A
	lda	zp_08
	sta	zp_1C
	lda	zp_0A
	sta	zp_1E
loc_02D9F7:
	rts
loc_02D9F8:
	lda	zp_1C
	sta	zp_08
	lda	zp_1E
	sta	zp_0A
	jsl	f:sub_1DABA0
	sec
	sbc	a:wram_1554
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
loc_02DA14:
	lda	a:title_menu_cursor
	beq	loc_02DA1C
	dec	a
	beq	loc_02DA54
loc_02DA1C:
	; (not executed in the CDL traces)
	lda	a:data_05E096,y
	beq	loc_02DA32
	sta	a:player1_obj
	lda	a:data_05E0B6,y
	sta	a:wram_020A
	lda	#$0070
	sta	a:wram_020E
	bra	loc_02DA38
loc_02DA32:
	lda	#$00F0
	sta	a:wram_020E
loc_02DA38:
	lda	a:data_05E0A6,y
	beq	loc_02DA4D
	sta	a:player2_obj
	lda	#$0078
	sta	a:wram_024A
	lda	a:data_05E0C6,y
	sta	a:wram_024E
	rts
loc_02DA4D:
	lda	#$00F0
	sta	a:wram_024E
	rts
loc_02DA54:
	lda	a:data_05E096,y
	beq	loc_02DA6A
	sta	a:wram_0280
	lda	a:data_05E0B6,y
	sta	a:wram_028A
	lda	#$00A8
	sta	a:wram_028E
	bra	loc_02DA70
loc_02DA6A:
	lda	#$00F0
	sta	a:wram_028E
loc_02DA70:
	lda	a:data_05E0A6,y
	beq	loc_02DA85
	sta	a:wram_02C0
	lda	#$0078
	sta	a:wram_02CA
	lda	a:data_05E0D6,y
	sta	a:wram_02CE
	rts
loc_02DA85:
	lda	#$00F0
	sta	a:wram_02CE
	rts
loc_02DA8C:
	; (not executed in the CDL traces)
	lda	#$FFFF
	sta	a:wram_159A
	lda	zp_78
	asl	a
	and	#$000E
	tay
	jmp	a:loc_02DA14

sub_02DA9C:
	; (not executed in the CDL traces)
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	loc_02DA8C
	cmp	#$0009
	beq	loc_02DA8C
	cmp	#$000A
	beq	loc_02DA8C
	cmp	#$000B
	beq	loc_02DA8C
	cmp	#$0011
	bcc	loc_02DAC4
loc_02DABA:
	lda	#$00F0
	sta	a:wram_028E
	sta	a:wram_02CE
	rts
loc_02DAC4:
	lda	$0A,x
	sec
	sbc	a:wram_1550
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:wram_1552
	sta	zp_1E
	jmp	a:loc_02D9F8

sub_02DAD7:
	; (not executed in the CDL traces)
	jsr	a:sub_02DAE0
	jsr	a:sub_02D61E
	jmp	a:loc_02DBA1

sub_02DAE0:
	; (not executed in the CDL traces)
	ldx	#$0700
loc_02DAE3:
	lda	$10,x
	dec	a
	bpl	loc_02DAEB
	brl	loc_02DB92
loc_02DAEB:
	lda	a:wram_0AD6
	bpl	loc_02DB35
	lda	a:wram_0AEE
	bit	#$0003
	beq	loc_02DB35
	lda	a:wram_0ACA
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02DB35
	lda	a:wram_0ACE
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02DB35
	jsl	f:sub_02B8D2
	lda	a:wram_0AEE
	ora	#$0040
	sta	a:wram_0AEE
	lda	a:wram_0AC6
	sec
	sbc	$06,x
	sta	a:wram_0AC6
	bpl	loc_02DB35
	ldy	#$0AC0
	jsl	f:sub_02EB75
loc_02DB35:
	ldy	#$0B40
loc_02DB38:
	lda	a:$0016,y
	bpl	loc_02DB87
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02DB87
	lda	a:$000A,y
	clc
	adc	#$0006
	sec
	sbc	$0A,x
	cmp	#$000C
	bcs	loc_02DB87
	lda	a:$000E,y
	clc
	adc	#$0006
	sec
	sbc	$0E,x
	cmp	#$000C
	bcs	loc_02DB87
	jsl	f:sub_02B8D2
	lda	a:$0016,y
	bit	#$1000
	beq	loc_02DB87
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc	$06,x
	sta	a:$0006,y
	bpl	loc_02DB87
	jsl	f:sub_02EB9A
loc_02DB87:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcc	loc_02DB38
loc_02DB92:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	loc_02DBA0
	brl	loc_02DAE3
loc_02DBA0:
	rts
loc_02DBA1:
	lda	a:wram_0F16
	bmi	loc_02DBA7
	rts
loc_02DBA7:
	lda	a:wram_0AD6
	bpl	loc_02DBE9
	lda	a:wram_0ACA
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0A
	cmp	#$0024
	bcs	loc_02DBE9
	lda	a:wram_0ACE
	clc
	adc	#$0012
	sec
	sbc	a:wram_0F0E
	cmp	#$0024
	bcs	loc_02DBE9
	lda	a:wram_0AEE
	bit	#$0040
	bne	loc_02DBDA
	ora	#$0040
	sta	a:wram_0AEE
loc_02DBDA:
	dec	a:wram_0AC6
	bpl	loc_02DBE9
	ldx	#$0AC0
	ldy	#$1FC0
	jsl	f:sub_02EBBF
loc_02DBE9:
	ldx	#$0B40
loc_02DBEC:
	lda	$16,x
	bpl	loc_02DC2D
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:wram_0F0A
	cmp	#$0014
	bcs	loc_02DC2D
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:wram_0F0E
	cmp	#$0014
	bcs	loc_02DC2D
	lda	a:p2_barrier_timer
	beq	loc_02DC27
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02DC2D
	ldy	#$1FC0
	jsl	f:sub_02EBCE
	bra	loc_02DC2D
loc_02DC27:
	lda	#$FFFF
	sta	a:wram_0F06
loc_02DC2D:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02DBEC
	jmp	a:loc_02D5C3

sub_02DC3B:
	lda	a:wram_1800
	ora	a:wram_1802
	ora	a:wram_1804
	ora	a:wram_1806
	beq	loc_02DC4C
	brl	loc_02DCC8
loc_02DC4C:
	lda	a:wram_18AC
	beq	loc_02DC8A
	dec	a:wram_18AC
	asl	a
	tay
	lda	a:data_05E13C,y
	beq	loc_02DC8A
	tax
	ldy	a:data_05E17C,x
	lda	a:data_05E1BC,x
	phx
	jsl	f:sub_04DCF1
	plx
	ldy	a:data_05E18C,x
	lda	a:data_05E1CC,x
	phx
	jsl	f:sub_04E047
	plx
	ldy	a:data_05E19C,x
	lda	a:data_05E1DC,x
	phx
	jsl	f:sub_04E0E3
	plx
	ldy	a:data_05E1AC,x
	lda	a:data_05E1EC,x
	jml	f:loc_04E17F
loc_02DC8A:
	lda	a:wram_18AE
	beq	loc_02DCC8
	dec	a:wram_18AE
	asl	a
	tay
	lda	a:data_05E13C,y
	beq	loc_02DCC8
	tax
	ldy	a:data_05E17C,x
	lda	a:data_05E1FC,x
	phx
	jsl	f:sub_04DCF1
	plx
	ldy	a:data_05E18C,x
	lda	a:data_05E20C,x
	phx
	jsl	f:sub_04E047
	plx
	ldy	a:data_05E19C,x
	lda	a:data_05E21C,x
	phx
	jsl	f:sub_04E0E3
	plx
	ldy	a:data_05E1AC,x
	lda	a:data_05E22C,x
	jml	f:loc_04E17F
loc_02DCC8:
	ldx	#$002C
loc_02DCCB:
	lda	a:$187E,x
	beq	loc_02DD14
	dec	a:$187E,x
	beq	loc_02DD03
	cmp	#$0020
	bne	loc_02DD14
	pha
	lda	#$0030
	jsl	f:sub_00868F
	pla
	jsl	f:sub_029BD8
	bcs	loc_02DD01
	lda	#$0001
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	a:data_05E0E4,x
	sta	a:$000A,y
	lda	a:data_05E110,x
	sta	a:$000E,y
loc_02DD01:
	bra	loc_02DD14
loc_02DD03:
	phx
	ldy	#$0057
	lda	a:data_05E23C,x
	jsl	f:sub_04DCD2
	plx
	bcc	loc_02DD14
	; (not executed in the CDL traces)
	inc	a:$187E,x
loc_02DD14:
	dex
	dex
	bne	loc_02DCCB
	rtl

sub_02DD19:
	ldx	#$18B0
loc_02DD1C:
	lda	$00,x
	beq	loc_02DD23
	jsr	a:sub_02DD2F
loc_02DD23:
	txa
	clc
	adc	#$000E
	tax
	cpx	#$18DA
	bcc	loc_02DD1C
	rtl

sub_02DD2F:
	lda	#$0001
	sta	a:wram_15A4
	jsr	a:sub_02DD8E
	lda	$04,x
	inc	$04,x
	ldy	difficulty
	cmp	a:data_05E26A,y
	bcs	loc_02DD44
	rts
loc_02DD44:
	jsr	a:sub_02DD78
	bcs	loc_02DD68
	lda	#$0030
	jsl	f:sub_00868F
	dec	$02,x
	beq	loc_02DD69
	stz	$04,x
	ldy	$06,x
	lda	$08,x
	clc
	adc	a:data_05E270,y
	sta	$08,x
	lda	$0C,x
	clc
	adc	a:data_05E274,y
	sta	$0C,x
loc_02DD68:
	rts
loc_02DD69:
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	rts

sub_02DD78:
	lda	$06,x
	asl	a
	asl	a
	clc
	adc	$02,x
	asl	a
	tay
	lda	a:data_05E276,y
	tay
	lda	$0C,x
	phx
	jsl	f:sub_04DCD2
	plx
	rts

sub_02DD8E:
	lda	$04,x
	bit	#$0007
	bne	loc_02DDC5
	jsl	f:sub_029BD8
	bcs	loc_02DDC5
	lda	#$0002
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	rng_lo
	and	#$0007
	sec
	sbc	#$0004
	clc
	adc	$08,x
	sta	a:$000A,y
	lda	rng_hi
	and	#$0007
	sec
	sbc	#$0004
	clc
	adc	$0A,x
	sta	a:$000E,y
loc_02DDC5:
	rts
