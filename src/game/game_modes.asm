; game/game_modes.asm -- Game mode state machine
; Bank $00, $00:A377-$00:AD7B. Included by main.asm in segment BANK00.
;
; sub_00A377 increments the frame counter $3A and dispatches the game mode $32
; through tbl_00A38A (15 modes, sub_00A3A8..sub_00AB76); many modes dispatch a
; sub-mode $34 through their own table. Also the end-of-life/continue checks
; (sub_00ABE0) and the per-stage choice between side-view and top-down
; (tbl_00AC2A, indexed by $70).

sub_00A377:
	.a16
	rep	#$30
	inc	$3A
	lda	$32
	phx
	asl	a
	tax
	lda	f:tbl_00A38A,x
	plx
	sta	$00
	jmp	($0000)
tbl_00A38A:
	.addr	sub_00A3A8
	.addr	sub_00A3E4
	.addr	sub_00A3E5
	.addr	sub_00A587
	.addr	sub_00A5E0
	.addr	sub_00A625
	.addr	sub_00A64A
	.addr	sub_00A73D
	.addr	sub_00A7FE
	.addr	sub_00A8E1
	.addr	sub_00A932
	.addr	sub_00A954
	.addr	sub_00AA0A
	.addr	sub_00AB56
	.addr	sub_00AB76

sub_00A3A8:
	lda	$34
	bne	loc_00A3C1
	ldx	#$F537
	jsl	f:sub_0098D4
	stz	a:$1C60
	stz	a:$1C62
	lda	#$0005
	sta	$3E
	inc	$34
loc_00A3C0:
	rtl
loc_00A3C1:
	jsl	f:sub_00B4DD
	lda	$28
	ora	$2A
	bit	#$1000
	beq	loc_00A3D9
	; (not executed in the CDL traces)
	lda	#$0002
	sta	$3E
	lda	#$0003
	brl	sub_00ABA3
loc_00A3D9:
	lda	a:$1C62
	beq	loc_00A3C0
	lda	#$0002
	brl	sub_00ABA3

sub_00A3E4:
	; (not executed in the CDL traces)
	rtl

sub_00A3E5:
	lda	$34
	asl	a
	tax
	jmp	(.loword(tbl_00A3EC),x)
tbl_00A3EC:
	.addr	sub_00A404
	.addr	sub_00A434
	.addr	sub_00A43B
	.addr	sub_00A460
	.addr	sub_00A46E
	.addr	sub_00A46E
	.addr	sub_00A46E
	.addr	sub_00A491
	.addr	sub_00A4DD
	.addr	sub_00A501
	.addr	sub_00A525
	.addr	sub_00A54F

sub_00A404:
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	stz	a:$1600
	stz	a:$1E42
	stz	a:$1E02
	stz	$86
	brl	loc_00AB9B

sub_00A434:
	jsl	f:sub_04D9F1
	brl	loc_00AB9B

sub_00A43B:
	lda	$28
	ora	$2A
	bit	#$1000
	beq	loc_00A44B
	; (not executed in the CDL traces)
	stz	$42
	stz	$46
	brl	loc_00ABA0
loc_00A44B:
	lda	#$0002
	sta	$42
	jsl	f:sub_00BD40
	lda	$36
	beq	loc_00A45F
	stz	$42
	stz	$46
	brl	loc_00AB9B
loc_00A45F:
	rtl

sub_00A460:
	jsl	f:sub_00885E
	stz	a:$1E02
	jsl	f:sub_00B091
	brl	loc_00AB9B

sub_00A46E:
	lda	a:$1E9E
	clc
	adc	#$0020
	sta	a:$1E9E
	lda	a:$1EA4
	clc
	adc	#$0020
	sta	a:$1EA4
	cmp	#$0100
	bcc	loc_00A490
	stz	a:$1E9E
	stz	a:$1EA4
	brl	loc_00AB9B
loc_00A490:
	rtl

sub_00A491:
	lda	a:$1E9E
	clc
	adc	#$0010
	sta	a:$1E9E
	lda	a:$1EA4
	clc
	adc	#$0010
	sta	a:$1EA4
	cmp	#$0100
	bcc	loc_00A490
	lda	#$0100
	sta	a:$1E9E
	sta	a:$1EA4
	lda	#$0100
	sta	a:$1E56
	lda	#$FFA0
	sta	a:$1E58
	lda	#$0100
	sta	a:$1E5A
	lda	#$FF80
	sta	a:$1E5C
	lda	#$0046
	jsl	f:sub_00868F
	stz	a:$1E64
	lda	#$0001
	sta	$46
	brl	loc_00AB9B

sub_00A4DD:
	jsl	f:sub_00B400
	lda	a:$1E56
	sec
	sbc	#$0004
	sta	a:$1E56
	cmp	#$0068
	bmi	loc_00A4F1
	rtl
loc_00A4F1:
	lda	#$0068
	sta	a:$1E56
	lda	#$0046
	jsl	f:sub_00868F
	brl	loc_00AB9B

sub_00A501:
	jsl	f:sub_00B400
	lda	a:$1E58
	clc
	adc	#$0004
	sta	a:$1E58
	cmp	#$0050
	bpl	loc_00A515
	rtl
loc_00A515:
	lda	#$0050
	sta	a:$1E58
	lda	#$0046
	jsl	f:sub_00868F
	brl	loc_00AB9B

sub_00A525:
	jsl	f:sub_00B400
	lda	a:$1E5A
	sec
	sbc	#$0004
	sta	a:$1E5A
	cmp	#$0050
	bmi	loc_00A539
	rtl
loc_00A539:
	lda	#$0050
	sta	a:$1E5A
	lda	#$0047
	jsl	f:sub_00868F
	lda	#$0004
	sta	a:$1E64
	brl	loc_00AB9B

sub_00A54F:
	lda	#$00B0
	sta	a:$1E5C
	jsl	f:sub_00B400
	ldy	a:$1E64
	lda	$3A
	bit	#$0002
	beq	loc_00A569
	tya
	eor	#$FFFF
	inc	a
	tay
loc_00A569:
	sty	a:$1398
	sty	a:$1418
	lda	a:$1E64
	beq	loc_00A57F
	lda	$3A
	bit	#$000F
	bne	loc_00A57E
	dec	a:$1E64
loc_00A57E:
	rtl
loc_00A57F:
	lda	#$0001
	sta	$34
	brl	loc_00ABAF

sub_00A587:
	lda	$34
	bne	loc_00A5B9
	lda	#$0068
	sta	a:$1E56
	lda	#$0050
	sta	a:$1E58
	lda	#$0050
	sta	a:$1E5A
	lda	#$00B0
	sta	a:$1E5C
	stz	a:$1E64
	jsl	f:sub_00885E
	stz	a:$1E02
	jsl	f:sub_00B0DC
	lda	#$0001
	sta	$46
	brl	loc_00AB9B
loc_00A5B9:
	jsl	f:sub_00B1AD
	jsl	f:sub_00B400
	lda	$36
	asl	a
	tax
	jmp	(.loword(tbl_00A5C8),x)
tbl_00A5C8:
	.addr	sub_00A5DF
	.addr	sub_00A5D0
	.addr	sub_00A5D3
	.addr	sub_00A5D9

sub_00A5D0:
	brl	loc_00ABA0

sub_00A5D3:
	lda	#$0006
	brl	sub_00ABA3

sub_00A5D9:
	; (not executed in the CDL traces)
	lda	#$0005
	brl	sub_00ABA3

sub_00A5DF:
	rtl

sub_00A5E0:
	lda	$34
	bne	loc_00A60D
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00A5F7
	dec	a:$1E80
	plp
	rtl
loc_00A5F7:
	lda	#$0080
	sta	a:$1E80
	plp
	stz	$46
	lda	#$0001
	sta	a:$1E02
	jsl	f:sub_00885E
	brl	loc_00AB9B
loc_00A60D:
	jsl	f:sub_00AD7C
	lda	$36
	beq	loc_00A624
	dec	a
	bne	loc_00A61E
	lda	#$0000
	brl	sub_00ABA3
loc_00A61E:
	; (not executed in the CDL traces)
	lda	#$0003
	brl	sub_00ABA3
loc_00A624:
	rtl

sub_00A625:
	; (not executed in the CDL traces)
	lda	$34
	bne	loc_00A63B
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	stz	a:$1E80
	brl	loc_00AB9B
loc_00A63B:
	jsl	f:sub_04D878
	lda	$36
	beq	loc_00A649
	lda	#$0003
	brl	sub_00ABA3
loc_00A649:
	rtl

sub_00A64A:
	lda	$34
	dec	a
	beq	loc_00A65F
	bpl	loc_00A67F
	lda	#$0001
	sta	$86
	stz	a:$1E40
	ldx	#$0050
	brl	loc_00AB99
loc_00A65F:
	lda	$68
	and	#$0004
	sta	$F0
	lda	a:$1E02
	asl	a
	tay
	ldx	a:data_05840A,y
	lda	#$2400
	jsl	f:sub_009015
	jsl	f:sub_00ABB6
	bne	loc_00A67E
	brl	loc_00AB9B
loc_00A67E:
	rtl
loc_00A67F:
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00A692
	dec	a:$1E80
	plp
	rtl
loc_00A692:
	lda	#$0080
	sta	a:$1E80
	plp
	stz	$46
	jsr	a:sub_00A6C0
	jsr	a:sub_00A734
	lda	a:$1E02
	cmp	#$0003
	bcs	loc_00A6BA
	lda	a:$1E60
	beq	loc_00A6B4
	; (not executed in the CDL traces)
	lda	#$0007
	brl	sub_00ABA3
loc_00A6B4:
	lda	#$0008
	brl	sub_00ABA3
loc_00A6BA:
	lda	#$000D
	brl	sub_00ABA3

sub_00A6C0:
	stz	a:$1E4C

sub_00A6C3:
	stz	a:$1600
	stz	a:$1E42
	stz	a:$1E5E
	stz	a:$1F80
	stz	a:$1FC0
	stz	a:$1F82
	stz	a:$1FC2
	stz	a:$1F84
	stz	a:$1FC4
	stz	a:$1F86
	stz	a:$1FC6
	stz	a:$1F9E
	stz	a:$1FDE
	stz	a:$1F88
	stz	a:$1FC8
	lda	#$0001
	sta	a:$1F8C
	sta	a:$1FCC
	stz	a:$1F8E
	stz	a:$1FCE
	stz	a:$1FA0
	stz	a:$1FA2
	stz	a:$1FE0
	stz	a:$1FE2
	lda	#$0000
	sta	a:$1FB6
	sta	a:$1FF6
	lda	#$0002
	sta	a:$1FB8
	sta	a:$1FF8
	lda	a:$1E3C
	sta	a:$1F8A
	lda	a:$1E02
	beq	loc_00A72B
	lda	a:$1E3C
loc_00A72B:
	sta	a:$1FCA
	lda	a:$1E3E
	sta	$84
	rts

sub_00A734:
	ldy	$84
	lda	a:data_0583F6,y
	sta	a:$1E62
	rts

sub_00A73D:
	; (not executed in the CDL traces)
	lda	$34
	dec	a
	beq	loc_00A77C
	bmi	loc_00A747
	brl	loc_00A7E1
loc_00A747:
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:$1E80
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	ldx	#$841B
	lda	#$2400
	jsl	f:sub_009015
	lda	#$0100
	sta	$4C
	brl	loc_00AB9B
loc_00A77C:
	php
	lda	a:$1E80
	bit	#$0080
	beq	loc_00A78B
	and	#$000F
	sta	a:$1E80
loc_00A78B:
	cmp	#$000F
	bcs	loc_00A795
	inc	a:$1E80
	plp
	rtl
loc_00A795:
	plp
	lda	$86
	asl	a
	tay
	ldx	a:data_058428,y
	jsl	f:sub_009024
	lda	$28
	ora	$2A
	bit	#$1000
	beq	loc_00A7B4
	lda	#$0002
	jsl	f:sub_00868F
	brl	loc_00AB9B
loc_00A7B4:
	bit	#$2C00
	bne	loc_00A7BA
	rtl
loc_00A7BA:
	pha
	lda	#$0001
	jsl	f:sub_00868F
	pla
	bit	#$0800
	beq	loc_00A7D2
	dec	$86
	bne	loc_00A7E0
	lda	#$0006
	sta	$86
	rtl
loc_00A7D2:
	inc	$86
	lda	$86
	cmp	#$0007
	bcc	loc_00A7E0
	lda	#$0001
	sta	$86
loc_00A7E0:
	rtl
loc_00A7E1:
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00A7F4
	dec	a:$1E80
	plp
	rtl
loc_00A7F4:
	lda	#$0080
	sta	a:$1E80
	plp
	brl	loc_00ABA0

sub_00A7FE:
	lda	$34
	dec	a
	bne	loc_00A806
	brl	loc_00A870
loc_00A806:
	bmi	loc_00A80B
	brl	loc_00A8B8
loc_00A80B:
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	lda	#$0080
	sta	a:$1E80
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:sub_00B7B2
	lda	$86
	asl	a
	tay
	ldx	a:data_058428,y
	lda	#$2400
	jsl	f:sub_009015
	stz	a:$1600
	stz	a:$1E42
	stz	a:$1E5E
	lda	#$0020
	sta	$94
	lda	#$0010
	sta	$96
	lda	#$4000
	sta	$88
	lda	#$8000
	sta	$8A
	sta	$92
	lda	#$0080
	sta	$8C
	lda	#$0010
	sta	$8E
	brl	loc_00AB9B
loc_00A870:
	php
	lda	a:$1E80
	bit	#$0080
	beq	loc_00A87F
	and	#$000F
	sta	a:$1E80
loc_00A87F:
	cmp	#$000F
	bcs	loc_00A889
	inc	a:$1E80
	plp
	rtl
loc_00A889:
	plp
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	a:$1E4C
	bne	loc_00A8AB
	lda	$86
	jsl	f:sub_00B99F
loc_00A8AB:
	lda	#$0002
	sta	a:$1E4C
	jsl	f:sub_04D9F1
	brl	loc_00AB9B
loc_00A8B8:
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00A8CB
	dec	a:$1E80
	plp
	rtl
loc_00A8CB:
	lda	#$0080
	sta	a:$1E80
	plp
	stz	$4A
	lda	#$0002
	sta	$64
	lda	$86
	dec	a
	sta	$70
	brl	loc_00ABA0

sub_00A8E1:
	jsl	f:sub_00ABDD
	lda	$36
	beq	loc_00A931
	lda	a:$1F8A
	ora	a:$1FCA
	bne	loc_00A8FB
	jsl	f:sub_00865C
	lda	#$000B
	brl	sub_00ABA3
loc_00A8FB:
	lda	$86
	cmp	#$0006
	bcc	loc_00A92B
	lda	#$0001
	sta	$86
	stz	a:$1E40
	lda	a:$1E3E
	inc	a
	inc	a
	cmp	#$0006
	bcc	loc_00A91A
	lda	#$000E
	brl	sub_00ABA3
loc_00A91A:
	; (not executed in the CDL traces)
	sta	a:$1E3E
	sta	$84
	stz	a:$1E4C
	jsr	a:sub_00A734
	lda	#$0008
	brl	sub_00ABA3
loc_00A92B:
	lda	#$000A
	brl	sub_00ABA3
loc_00A931:
	rtl

sub_00A932:
	lda	$34
	bne	loc_00A945
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	brl	loc_00AB9B
loc_00A945:
	jsl	f:sub_00B679
	lda	$36
	beq	loc_00A953
	lda	#$0008
	brl	sub_00ABA3
loc_00A953:
	rtl

sub_00A954:
	lda	$34
	phx
	asl	a
	tax
	lda	f:tbl_00A963,x
	plx
	sta	$00
	jmp	($0000)
tbl_00A963:
	.addr	sub_00A96D
	.addr	sub_00A9A4
	.addr	sub_00A9DD
	.addr	sub_00A9E5
	.addr	sub_00A9ED

sub_00A96D:
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:$1E80
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:sub_00B7B2
	ldx	#$8472
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$F513
	jsl	f:sub_0098D4
	brl	loc_00AB9B

sub_00A9A4:
	php
	lda	a:$1E80
	bit	#$0080
	beq	loc_00A9B3
	and	#$000F
	sta	a:$1E80
loc_00A9B3:
	cmp	#$000F
	bcs	loc_00A9BD
	inc	a:$1E80
	plp
	rtl
loc_00A9BD:
	plp
	lda	#$006B
	jsl	f:sub_00868F
	dec	a:$1E62
	bmi	loc_00A9D2
	lda	#$0080
	sta	$76
	brl	loc_00AB9B
loc_00A9D2:
	; (not executed in the CDL traces)
	lda	#$0180
	sta	$76
	lda	#$0003
	sta	$34
	rtl

sub_00A9DD:
	dec	$76
	bne	loc_00A9E4
	brl	loc_00ABA0
loc_00A9E4:
	rtl

sub_00A9E5:
	; (not executed in the CDL traces)
	dec	$76
	bne	loc_00A9EC
	brl	loc_00AB9B
loc_00A9EC:
	rtl

sub_00A9ED:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00AA00
	dec	a:$1E80
	plp
	rtl
loc_00AA00:
	lda	#$0080
	sta	a:$1E80
	plp
	brl	loc_00AAA8

sub_00AA0A:
	lda	$34
	asl	a
	tax
	jmp	(.loword(tbl_00AA11),x)
tbl_00AA11:
	.addr	sub_00AA19
	.addr	sub_00AA25
	.addr	sub_00AA5D
	.addr	sub_00AA80

sub_00AA19:
	lda	#$0002
	sta	a:$1C02
	stz	a:$1C00
	brl	loc_00AB9B

sub_00AA25:
	jsr	a:sub_00AAB1
	jsr	a:sub_00AAE6
	lda	$28
	ora	$2A
	bit	#$1000
	beq	loc_00AA5C
	lda	#$0002
	jsl	f:sub_00868F
	lda	a:$1C00
	beq	loc_00AA46
	; (not executed in the CDL traces)
	lda	#$0003
	brl	loc_00ABAA
loc_00AA46:
	lda	a:$1E02
	sta	a:$1C00
	lda	#$0003
	sta	a:$1C02
	ldx	#$8490
	jsl	f:sub_009024
	brl	loc_00AB9B
loc_00AA5C:
	rtl

sub_00AA5D:
	jsr	a:sub_00AAB1
	jsr	a:sub_00AB28
	lda	$28
	ora	$2A
	bit	#$1000
	beq	loc_00AA7F
	lda	#$0002
	jsl	f:sub_00868F
	lda	a:$1C00
	sta	a:$1E02
	stz	a:$1C00
	brl	loc_00AB9B
loc_00AA7F:
	rtl

sub_00AA80:
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00AA93
	dec	a:$1E80
	plp
	rtl
loc_00AA93:
	lda	#$0080
	sta	a:$1E80
	plp
	lda	a:$1C00
	bne	loc_00AAA8
	jsr	a:sub_00A6C3
	lda	#$0008
	brl	sub_00ABA3
loc_00AAA8:
	; (not executed in the CDL traces)
	stz	a:$1E40
	lda	#$0003
	brl	sub_00ABA3

sub_00AAB1:
	lda	$28
	ora	$2A
	bit	#$2C00
	beq	loc_00AAE5
	pha
	lda	#$0001
	jsl	f:sub_00868F
	pla
	bit	#$0800
	bne	loc_00AAD8
	lda	a:$1C00
	inc	a
	cmp	a:$1C02
	bcc	loc_00AAD4
	lda	#$0000
loc_00AAD4:
	sta	a:$1C00
	rts
loc_00AAD8:
	lda	a:$1C00
	dec	a
	bpl	loc_00AAE2
	lda	a:$1C02
	dec	a
loc_00AAE2:
	sta	a:$1C00
loc_00AAE5:
	rts

sub_00AAE6:
	lda	a:$1C00
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$847E
	pha
	jsl	f:sub_009015
	pla
	ldx	#$1E62
	ldy	#$5A35
	jsl	f:sub_00AB14
	lda	a:$1C00
	eor	#$0001
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$848A
	jsl	f:sub_009015
	rts

sub_00AB14:
	sta	$FA
	phx
	jsl	f:sub_008D41
	plx
	lda	$00,x
	inc	a
	jsl	f:sub_00B927
	jsl	f:sub_008DB0
	rtl

sub_00AB28:
	lda	a:$1C00
	asl	a
	tay
	lda	a:data_058404,y
	ldx	#$8599
	jsl	f:sub_009015
	lda	a:$1C00
	asl	a
	tay
	lda	a:data_058402,y
	ldx	#$85A6
	jsl	f:sub_009015
	lda	a:$1C00
	asl	a
	tay
	lda	a:data_058400,y
	ldx	#$85B4
	jsl	f:sub_009015
	rts

sub_00AB56:
	lda	$34
	bne	loc_00AB68
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	bra	loc_00AB9B
loc_00AB68:
	jsl	f:sub_00B9BE
	lda	$36
	beq	loc_00AB75
	lda	#$0003
	bra	sub_00ABA3
loc_00AB75:
	rtl

sub_00AB76:
	lda	$34
	bne	loc_00AB88
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	bra	loc_00AB9B
loc_00AB88:
	jsl	f:sub_00BC38
	lda	$36
	beq	loc_00AB95
	; (not executed in the CDL traces)
	lda	#$0002
	bra	sub_00ABA3
loc_00AB95:
	rtl
	; CDL: not accessed
	.byte	$A2, $80, $00
loc_00AB99:
	stx	$68
loc_00AB9B:
	lda	$34
	inc	a
	bra	loc_00ABAA
loc_00ABA0:
	lda	$32
	inc	a

sub_00ABA3:
	sta	$32
	lda	#$0000
	sta	$36
loc_00ABAA:
	sta	$34
	stz	$38
	rtl
loc_00ABAF:
	inc	$32
	stz	$36
	stz	$38
	rtl

sub_00ABB6:
	lda	$68
	beq	loc_00ABBC
	dec	$68
loc_00ABBC:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00ABBD:
	; (not executed in the CDL traces)
	jsl	f:sub_00ABC6
	rep	#$20
	stz	$4A
	rtl

sub_00ABC6:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	stz	$66
	jsl	f:sub_0085A9
	sep	#$20
	.a8
	jsl	f:sub_00885E
	jsl	f:sub_00848F
	rep	#$20
	.a16
	rtl

sub_00ABDD:
	jsr	a:sub_00AD2A

sub_00ABE0:
	rep	#$30
	jsr	a:sub_00AC4A
	lda	$4A
	bne	loc_00AC1B
	lda	$64
	bne	loc_00AC1B
	lda	#$0000
	ldy	a:$1F8A
	beq	loc_00ABF7
	ora	$28
loc_00ABF7:
	ldy	a:$1FCA
	beq	loc_00ABFE
	ora	$2A
loc_00ABFE:
	bit	#$1000
	beq	loc_00AC16
	lda	$66
	eor	#$0001
	sta	$66
	asl	a
	tay
	lda	a:data_0584D6,y
	jsl	f:sub_00868F
	jsr	a:sub_00ACAF
loc_00AC16:
	lda	$66
	beq	loc_00AC1B
	rtl
loc_00AC1B:
	lda	$70
	phx
	asl	a
	tax
	lda	f:tbl_00AC2A,x
	plx
	sta	$00
	jmp	($0000)
tbl_00AC2A:
	.addr	sub_00AC36
	.addr	sub_00AC3F
	.addr	sub_00AC36
	.addr	sub_00AC36
	.addr	sub_00AC3F
	.addr	sub_00AC36

sub_00AC36:
	lda	#$0002
	sta	$42
	jml	f:sub_00BD40

sub_00AC3F:
	lda	#$0004
	sta	$42
	inc	$78
	jml	f:loc_028000

sub_00AC4A:
	jsr	a:sub_00AC7E
	lda	a:$1FCE
	beq	loc_00AC5C
	lda	#$0002
	sta	a:$1FC2
	sta	a:$1FC0
	rts
loc_00AC5C:
	lda	a:$1FCA
	beq	loc_00AC71
	lda	$2A
	bit	#$0040
	beq	loc_00AC71
	lda	a:$1FDE
	eor	#$0002
	sta	a:$1FDE
loc_00AC71:
	lda	a:$1FDE
	sta	a:$1FC2
	eor	#$0002
	sta	a:$1FC0
	rts

sub_00AC7E:
	lda	a:$1F8E
	beq	loc_00AC8D
	lda	#$0002
	sta	a:$1F82
	sta	a:$1F80
	rts
loc_00AC8D:
	lda	a:$1F8A
	beq	loc_00ACA2
	lda	$28
	bit	#$0040
	beq	loc_00ACA2
	lda	a:$1F9E
	eor	#$0002
	sta	a:$1F9E
loc_00ACA2:
	lda	a:$1F9E
	sta	a:$1F82
	eor	#$0002
	sta	a:$1F80
	rts

sub_00ACAF:
	lda	$66
	beq	loc_00ACCF
	lda	a:$1E80
	sta	a:$1E4E
	lda	a:$1FB4
	sta	a:$1E50
	lda	a:$1FF4
	sta	a:$1E52
	jsr	a:sub_00ACE2
	jsr	a:sub_00ACFA
	jsr	a:sub_00AD12
	rts
loc_00ACCF:
	lda	a:$1E4E
	sta	a:$1E80
	lda	a:$1E50
	sta	a:$1FB4
	lda	a:$1E52
	sta	a:$1FF4
	rts

sub_00ACE2:
	lda	a:$1E80
	bit	#$0080
	bne	loc_00ACF9
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00ACF6
	; (not executed in the CDL traces)
	lda	#$0000
loc_00ACF6:
	sta	a:$1E80
loc_00ACF9:
	rts

sub_00ACFA:
	lda	a:$1FB4
	bit	#$0080
	bne	loc_00AD11
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD0E
	lda	#$0000
loc_00AD0E:
	sta	a:$1FB4
loc_00AD11:
	rts

sub_00AD12:
	lda	a:$1FF4
	bit	#$0080
	bne	loc_00AD29
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD26
	lda	#$0000
loc_00AD26:
	sta	a:$1FF4
loc_00AD29:
	rts

sub_00AD2A:
	lda	a:$1E5E
	bne	loc_00AD5A
	lda	a:$1E02
	beq	loc_00AD5A
	jsr	a:sub_00AD3A
	jmp	a:loc_00AD5B

sub_00AD3A:
	lda	a:$1F8A
	bne	loc_00AD5A
	; (not executed in the CDL traces)
	lda	$28
	bit	#$0080
	beq	loc_00AD5A
	lda	a:$1FCA
	cmp	#$0002
	bcc	loc_00AD5A
	inc	a:$1F8A
	dec	a:$1FCA
	lda	#$0001
	sta	a:$1F8C
loc_00AD5A:
	rts
loc_00AD5B:
	lda	a:$1FCA
	bne	loc_00AD7B
	; (not executed in the CDL traces)
	lda	$2A
	bit	#$0080
	beq	loc_00AD7B
	lda	a:$1F8A
	cmp	#$0002
	bcc	loc_00AD7B
	inc	a:$1FCA
	dec	a:$1F8A
	lda	#$0001
	sta	a:$1FCC
loc_00AD7B:
	rts
