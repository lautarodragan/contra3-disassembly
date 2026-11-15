; engine/window_effect.asm -- Window effect around a player
; Bank $00, $00:E7EF-$00:E95F. Included by main.asm in segment BANK00.
;
; sub_00E7EF (from NMI, side-view stages) builds a window/HDMA effect for a
; player while $1D88,x (that player's barrier timer, $1F88/$1FC8) or $1310,x
; is set, with the shape routines in effects/window_shapes.asm.

sub_00E7EF:
	lda	$BC
	asl	a
	tay
	lda	a:$1FCA
	beq	loc_00E80C
	lda	a:$1F8A
	beq	loc_00E805
	lda	a:data_05A39E,y
	tax
	sta	$FE
	bra	loc_00E811
loc_00E805:
	; (not executed in the CDL traces)
	ldx	#$0240
	stx	$FE
	bra	loc_00E811
loc_00E80C:
	ldx	#$0200
	stx	$FE
loc_00E811:
	lda	a:data_05A3A2,y
	sta	$C6
	lda	a:data_05A3A6,y
	sta	$9E
	sta	$1E
	clc
	adc	#$0020
	sta	$1C
	lda	a:$1310,x
	bne	loc_00E855
	lda	a:$1D88,x
	bne	loc_00E839
loc_00E82D:
	stz	$9E
	stz	$C6
	jsl	f:sub_02E003
	stz	a:$1E98
	rtl
loc_00E839:
	jsr	a:sub_00E86B
	jsl	f:sub_02DDEE
	bcs	loc_00E82D
	jsl	f:sub_02DF49
	jsl	f:sub_02E0B4
	jsr	a:sub_00E8C1
	jsr	a:sub_00E913
	jsl	f:sub_02E003
	rtl
loc_00E855:
	jsr	a:sub_00E896
	jsl	f:sub_02DDEE
	bcs	loc_00E82D
	jsl	f:sub_02DF49
	jsl	f:sub_02DE4A
	jsl	f:sub_02E003
	rtl

sub_00E86B:
	lda	#$0022
	sta	a:$1EAC
	lda	#$0203
	sta	a:$1EBA
	stz	a:$1E98
	lda	#$A42A
	sta	$12
	lda	#$0018
	sta	$10
	lda	a:$1312,x
	sta	$14
	lda	a:$1314,x
	sta	$16
	stz	$18
	lda	#$00E0
	sta	$1A
	rts

sub_00E896:
	sta	$10
	and	a:$16AA
	ora	a:$16AC
	sta	a:$1E98
	lda	#$0023
	sta	a:$1EAC
	lda	#$0200
	sta	a:$1EBA
	lda	a:$131C,x
	sta	$14
	lda	a:$131E,x
	sta	$16
	stz	$18
	lda	#$00E0
	sta	$1A
	stz	$C6
	rts

sub_00E8C1:
	ldx	$9E
	ldy	$C6
	tya
	clc
	adc	#$0010
	sta	$FC
loc_00E8CC:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	a:$0000,x
	sta	a:$0000,y
	inx
	inx
	iny
	iny
	cpy	$FC
	bcc	loc_00E8CC
	ldx	$C6
loc_00E8E4:
	sep	#$20
	.a8
	lda	a:$0001,x
	cmp	#$1E
	bne	loc_00E8FF
	inx
	inx
	inx
	cpx	$FC
	bcc	loc_00E8E4
	; (not executed in the CDL traces)
	sep	#$20
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rep	#$20
	rts
loc_00E8FF:
	.a8
	rep	#$20
	.a16
	clc
	lda	$C6
	adc	#$0020
	sta	a:$0001,x
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts

sub_00E913:
	lda	$06
	sta	$FC
	ldx	$FE
	ldy	#$8F40
	lda	a:$1D88,x
	cmp	#$0060
	bcs	loc_00E927
	ldy	#$0F20
loc_00E927:
	sty	$00
	lda	$78
	asl	a
	asl	a
	eor	#$FFFF
	and	#$007F
	tax
	ldy	$C6
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00E93E:
	.a16
	lda	f:data_05A3AA,x
	and	#$00FF
	ora	$00
	xba
	sta	a:$0020,y
	iny
	iny
	inx
	txa
	and	#$007F
	tax
	dec	$FC
	bne	loc_00E93E
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts
