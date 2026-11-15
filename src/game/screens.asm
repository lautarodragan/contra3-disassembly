; game/screens.asm -- Other non-gameplay screens
; Bank $00, $00:B679-$00:BD3F. Included by main.asm in segment BANK00.
;
; Sub-mode tables of game modes 10, 13 and 14 (sub_00B679, sub_00B9BE,
; sub_00BC38) and the tilemap/number drawing helpers they share with other
; modes (sub_00B7B2, sub_00B83B...).

sub_00B679:
	lda	a:wram_1C00
	asl	a
	tax
	jmp	(.loword(tbl_00B681),x)
tbl_00B681:
	.addr	sub_00B691
	.addr	sub_00B6CF
	.addr	sub_00B6F4
	.addr	sub_00B70C
	.addr	sub_00B739
	.addr	sub_00B741
	.addr	sub_00B76C
	.addr	sub_00B781

sub_00B691:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B6A4
	dec	a:inidisp_shadow
	plp
	rtl
loc_00B6A4:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	a:tm_shadow
	ldx	#$F4EF
	jsl	f:sub_0098D4
	lda	stage_number
	asl	a
	tay
	lda	a:data_0587F1,y
	tax
	jsl	f:sub_0090A8
	ldy	#$8880
	jsl	f:sub_009982
	inc	a:wram_1C00
	rtl

sub_00B6CF:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00B6DE
	and	#$000F
	sta	a:inidisp_shadow
loc_00B6DE:
	cmp	#$000F
	bcs	loc_00B6E8
	inc	a:inidisp_shadow
	plp
	rtl
loc_00B6E8:
	plp
	lda	#$006A
	jsl	f:queue_sound
	inc	a:wram_1C00
	rtl

sub_00B6F4:
	lda	stage_number
	inc	a
	cmp	#$0007
	bcc	loc_00B6FF
	; (not executed in the CDL traces)
	lda	#$0001
loc_00B6FF:
	jsl	f:sub_00B99F
	lda	#$0001
	sta	zp_76
	inc	a:wram_1C00
	rtl

sub_00B70C:
	dec	zp_76
	bpl	loc_00B738
	jsl	f:sub_00B7B2
	lda	#$0001
	sta	a:wram_1C04
	lda	#$0000
	sta	a:wram_1C02
	jsr	a:sub_00B8D5
	ldy	#$8889
	jsl	f:sub_009982
	lda	#$0040
	sta	zp_76
	lda	#$0005
	sta	a:tm_shadow
	inc	a:wram_1C00
loc_00B738:
	rtl

sub_00B739:
	dec	zp_76
	bpl	loc_00B740
	inc	a:wram_1C00
loc_00B740:
	rtl

sub_00B741:
	jsr	a:sub_00B934
	jsl	f:sub_00B7B2
	jsr	a:sub_00B8D5
	lda	a:wram_1C02
	bit	#$0100
	bne	loc_00B75A
	lda	#$0003
	jsl	f:queue_sound
loc_00B75A:
	lda	a:wram_1C02
	ora	a:wram_1C04
	beq	loc_00B763
	rtl
loc_00B763:
	lda	#$0100
	sta	zp_76
	inc	a:wram_1C00
	rtl

sub_00B76C:
	dec	zp_76
	bpl	loc_00B773
	; (not executed in the CDL traces)
	brl	loc_00B77D
loc_00B773:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$D0C0
	bne	loc_00B77D
	rtl
loc_00B77D:
	inc	a:wram_1C00
	rtl

sub_00B781:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00B794
	dec	a:inidisp_shadow
	plp
	rtl
loc_00B794:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	a:wram_1E40
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	loc_00B7AC
	; (not executed in the CDL traces)
	lda	#$0001
	sta	stage_number
loc_00B7AC:
	lda	#$0001
	sta	zp_36
	rtl

sub_00B7B2:
	jsr	a:sub_00B968
	ldx	#$8892
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$889D
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$88A8
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$88B2
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$88BD
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$1E44
	ldy	#$58AD
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1FA0
	ldy	#$5924
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1FE0
	ldy	#$5936
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1F8A
	ldy	#$5969
	lda	#$2000
	jsl	f:sub_00B8ED
	ldx	#$1FCA
	ldy	#$597B
	lda	#$2000
	jsl	f:sub_00B8ED
	rtl

sub_00B829:
	pha
	txa
	clc
	adc	#$1D80
	tax
	pla
	bra	sub_00B83B

sub_00B833:
	pha
	txa
	clc
	adc	#$10C0
	tax
	pla

sub_00B83B:
	sed
	sta	zp_FA
	sec
	lda	$36,x
	sbc	zp_FA
	sta	$36,x
	lda	$38,x
	sbc	#$0000
	sta	$38,x
	bmi	loc_00B854
	lda	$36,x
	ora	$38,x
	bne	loc_00B877
loc_00B854:
	lda	#$003E
	jsl	f:queue_sound
	lda	$0A,x
	inc	a
	cmp	#$001E
	bcc	loc_00B866
	; (not executed in the CDL traces)
	lda	#$001E
loc_00B866:
	sta	$0A,x
	clc
	lda	$36,x
	adc	#$0000
	sta	$36,x
	lda	$38,x
	adc	#$0006
	sta	$38,x
loc_00B877:
	lda	zp_FA
	clc
	adc	$20,x
	sta	$20,x
	lda	$22,x
	adc	#$0000
	sta	$22,x
	sec
	lda	$20,x
	sbc	#$9999
	lda	$22,x
	sbc	#$0999
	bcc	loc_00B89C
	; (not executed in the CDL traces)
	lda	#$9999
	sta	$20,x
	lda	#$0999
	sta	$22,x
loc_00B89C:
	cld
	rtl

sub_00B89E:
	sta	zp_FA
	phx
	jsl	f:sub_008D41
	plx
	lda	$03,x
	jsl	f:sub_00B927
	lda	$02,x
	jsl	f:sub_00B923
	lda	$02,x
	jsl	f:sub_00B927
	lda	$01,x
	jsl	f:sub_00B923
	lda	$01,x
	jsl	f:sub_00B927
	lda	$00,x
	jsl	f:sub_00B923
	lda	$00,x
	jsl	f:sub_00B927
	jsl	f:sub_008DB0
	rtl

sub_00B8D5:
	ldx	#$88C7
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$1C02
	ldy	#$5AAD
	lda	#$2000
	jsl	f:sub_00B89E
	rts

sub_00B8ED:
	sta	zp_FA
	phx
	jsl	f:sub_008D41
	plx
	lda	$00,x
	bpl	loc_00B8FC
	; (not executed in the CDL traces)
	lda	#$0000
loc_00B8FC:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rep	#$20
	.a16
	lda	a:RDDIVL
	jsl	f:sub_00B927
	lda	a:RDMPYL
	jsl	f:sub_00B927
	jsl	f:sub_008DB0
	rtl

sub_00B923:
	lsr	a
	lsr	a
	lsr	a
	lsr	a

sub_00B927:
	and	#$000F
	inc	a
	ora	zp_FA
	phx
	jsl	f:sub_008DA5
	plx
	rtl

sub_00B934:
	lda	a:p1_lives
	beq	loc_00B943
	lda	#$0100
	ldx	#$1F80
	jsl	f:sub_00B83B
loc_00B943:
	lda	a:p2_lives
	beq	loc_00B952
	; (not executed in the CDL traces)
	lda	#$0100
	ldx	#$1FC0
	jsl	f:sub_00B83B
loc_00B952:
	sed
	sec
	lda	a:wram_1C02
	sbc	#$0100
	sta	a:wram_1C02
	lda	a:wram_1C04
	sbc	#$0000
	sta	a:wram_1C04
	cld
	rts

sub_00B968:
	sec
	lda	a:wram_1E44
	sbc	a:wram_1FA0
	lda	a:wram_1E46
	sbc	a:wram_1FA2
	bcs	loc_00B983
	lda	a:wram_1FA0
	sta	a:wram_1E44
	lda	a:wram_1FA2
	sta	a:wram_1E46
loc_00B983:
	sec
	lda	a:wram_1E44
	sbc	a:wram_1FE0
	lda	a:wram_1E46
	sbc	a:wram_1FE2
	bcs	loc_00B99E
	; (not executed in the CDL traces)
	lda	a:wram_1FE0
	sta	a:wram_1E44
	lda	a:wram_1FE2
	sta	a:wram_1E46
loc_00B99E:
	rts

sub_00B99F:
	pha
	jsl	f:clear_bg_scroll_state
	jsl	f:clear_wram_7e4000_7effff
	pla
	asl	a
	tay
	lda	a:ptrs_0588E1,y
	tax
	phy
	jsl	f:sub_0090A8
	ply
	lda	a:ptrs_0588ED,y
	tax
	jsl	f:sub_0090A8
	rtl

sub_00B9BE:
	lda	a:wram_1C00
	asl	a
	tax
	jmp	(.loword(tbl_00B9C6),x)
tbl_00B9C6:
	.addr	sub_00B9CC
	.addr	sub_00B9EB
	.addr	sub_00BA2B

sub_00B9CC:
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsr	a:sub_00BB4E
	ldx	#$8948
	lda	#$2400
	jsl	f:sub_009015
	inc	a:wram_1C00
	rtl

sub_00B9EB:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00B9FA
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:inidisp_shadow
loc_00B9FA:
	cmp	#$000F
	bcs	loc_00BA04
	; (not executed in the CDL traces)
	inc	a:inidisp_shadow
	plp
	rtl
loc_00BA04:
	plp
	jsr	a:sub_00BA4B
	jsr	a:sub_00BA7F
	jsr	a:sub_00BAA4
	jsr	a:sub_00BAC6
	jsr	a:sub_00BAE8
	bcs	loc_00BA20
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_00BA20
	rtl
loc_00BA20:
	lda	#$0002
	jsl	f:queue_sound
	inc	a:wram_1C00
	rtl

sub_00BA2B:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BA3E
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BA3E:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	zp_36
	rtl

sub_00BA4B:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0C00
	beq	loc_00BA7E
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_00BA72
	lda	a:wram_1C02
	inc	a
	cmp	#$0004
	bcc	loc_00BA6E
	; (not executed in the CDL traces)
	lda	#$0000
loc_00BA6E:
	sta	a:wram_1C02
	rts
loc_00BA72:
	lda	a:wram_1C02
	dec	a
	bpl	loc_00BA7B
	lda	#$0003
loc_00BA7B:
	sta	a:wram_1C02
loc_00BA7E:
	rts

sub_00BA7F:
	lda	a:wram_1C02
	cmp	#$0000
	beq	loc_00BA91
	ldx	#$8956
	jsl	f:sub_009024
	jmp	a:loc_00BB6A
loc_00BA91:
	ldx	#$8956
	lda	#$2400
	jsl	f:sub_009015
	jsr	a:sub_00BB0E
	jsr	a:sub_00BB42
	jmp	a:loc_00BB6A

sub_00BAA4:
	lda	a:wram_1C02
	cmp	#$0001
	beq	loc_00BAB6
	ldx	#$895F
	jsl	f:sub_009024
	jmp	a:loc_00BBDF
loc_00BAB6:
	ldx	#$895F
	lda	#$2400
	jsl	f:sub_009015
	jsr	a:sub_00BBA9
	jmp	a:loc_00BBDF

sub_00BAC6:
	lda	a:wram_1C02
	cmp	#$0002
	beq	loc_00BAD8
	ldx	#$8967
	jsl	f:sub_009024
	jmp	a:loc_00BC2D
loc_00BAD8:
	ldx	#$8967
	lda	#$2400
	jsl	f:sub_009015
	jsr	a:sub_00BBEA
	jmp	a:loc_00BC2D

sub_00BAE8:
	lda	a:wram_1C02
	cmp	#$0003
	beq	loc_00BAF9
	ldx	#$896F
	jsl	f:sub_009024
loc_00BAF7:
	clc
	rts
loc_00BAF9:
	ldx	#$896F
	lda	#$2400
	jsl	f:sub_009015
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$C0C0
	beq	loc_00BAF7
	sec
	rts

sub_00BB0E:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0300
	beq	loc_00BB41
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0100
	bne	loc_00BB32
	lda	a:wram_1C04
	dec	a
	bpl	loc_00BB2E
	lda	#$0002
loc_00BB2E:
	sta	a:wram_1C04
	rts
loc_00BB32:
	lda	a:wram_1C04
	inc	a
	cmp	#$0003
	bcc	loc_00BB3E
	lda	#$0000
loc_00BB3E:
	sta	a:wram_1C04
loc_00BB41:
	rts

sub_00BB42:
	lda	a:wram_1C04
	asl	a
	tay
	lda	a:data_0588FB,y
	sta	a:wram_1E3C
	rts

sub_00BB4E:
	ldy	#$0000
	lda	a:wram_1E3C
	cmp	#$0003
	beq	loc_00BB66
	; (not executed in the CDL traces)
	iny
	cmp	#$0005
	beq	loc_00BB66
	iny
	cmp	#$0007
	beq	loc_00BB66
	iny
loc_00BB66:
	sty	a:wram_1C04
	rts
loc_00BB6A:
	ldy	#$5992
	lda	a:wram_1E3C
	cmp	#$0063
	bcc	loc_00BB78
	; (not executed in the CDL traces)
	lda	#$0063
loc_00BB78:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	rep	#$20
	.a16
	jsl	f:sub_008D41
	lda	a:RDDIVL
	and	#$00FF
	inc	a
	ora	#$2000
	jsl	f:sub_008DA5
	lda	a:RDMPYL
	and	#$00FF
	inc	a
	ora	#$2000
	jsl	f:sub_008DA5
	jsl	f:sub_008DB0
	rts

sub_00BBA9:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0300
	beq	loc_00BBDE
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0100
	bne	loc_00BBCE
	; (not executed in the CDL traces)
	lda	a:wram_1E3E
	dec	a
	dec	a
	bpl	loc_00BBCA
	lda	#$0004
loc_00BBCA:
	sta	a:wram_1E3E
	rts
loc_00BBCE:
	lda	a:wram_1E3E
	inc	a
	inc	a
	cmp	#$0006
	bcc	loc_00BBDB
	lda	#$0000
loc_00BBDB:
	sta	a:wram_1E3E
loc_00BBDE:
	rts
loc_00BBDF:
	ldy	a:wram_1E3E
	ldx	a:data_058903,y
	jsl	f:sub_009024
	rts

sub_00BBEA:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$0300
	beq	loc_00BC11
	; (not executed in the CDL traces)
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0100
	bne	loc_00BC12
	lda	a:wram_1E54
	dec	a
	dec	a
	bpl	loc_00BC0B
	lda	#$0002
loc_00BC0B:
	sta	a:wram_1E54
	jsr	a:sub_00BC22
loc_00BC11:
	rts
loc_00BC12:
	; (not executed in the CDL traces)
	lda	a:wram_1E54
	inc	a
	inc	a
	cmp	#$0004
	bcc	loc_00BC1F
	lda	#$0000
loc_00BC1F:
	sta	a:wram_1E54

sub_00BC22:
	; (not executed in the CDL traces)
	ldy	a:wram_1E54
	lda	a:data_05892A,y
	jsl	f:queue_sound
	rts
loc_00BC2D:
	ldy	a:wram_1E54
	ldx	a:data_05892E,y
	jsl	f:sub_009024
	rts

sub_00BC38:
	lda	a:wram_1C00
	asl	a
	tax
	jmp	(.loword(tbl_00BC40),x)
tbl_00BC40:
	.addr	sub_00BC48
	.addr	sub_00BC7E
	.addr	sub_00BC9C
	.addr	sub_00BCA9

sub_00BC48:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BC5B
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BC5B:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0005
	sta	a:tm_shadow
	ldx	#.loword(data_058976)
	jsl	f:sub_0090A8
	ldy	#$898E
	jsl	f:sub_009982
	jsl	f:sub_00BCC9
	inc	a:wram_1C00
	rtl

sub_00BC7E:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00BC8D
	and	#$000F
	sta	a:inidisp_shadow
loc_00BC8D:
	cmp	#$000F
	bcs	loc_00BC97
	inc	a:inidisp_shadow
	plp
	rtl
loc_00BC97:
	plp
	inc	a:wram_1C00
	rtl

sub_00BC9C:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00BCA8
	; (not executed in the CDL traces)
	inc	a:wram_1C00
loc_00BCA8:
	rtl

sub_00BCA9:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00BCBC
	dec	a:inidisp_shadow
	plp
	rtl
loc_00BCBC:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	#$0001
	sta	zp_36
	rtl

sub_00BCC9:
	jsr	a:sub_00B968
	ldx	#$8997
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$89A2
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$89AD
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$89B7
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$89C2
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$1E44
	ldy	#$58ED
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1FA0
	ldy	#$58E4
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1FE0
	ldy	#$58F6
	lda	#$2000
	jsl	f:sub_00B89E
	ldx	#$1F8A
	ldy	#$5929
	lda	#$2000
	jsl	f:sub_00B8ED
	ldx	#$1FCA
	ldy	#$593B
	lda	#$2000
	jsl	f:sub_00B8ED
	rtl
