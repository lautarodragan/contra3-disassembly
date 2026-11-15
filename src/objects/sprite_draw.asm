; objects/sprite_draw.asm -- Metasprite drawing
; Bank $00, $00:EB1A-$00:EBC3. Included by main.asm in segment BANK00.
;
; sub_00EB1A draws an object's metasprite (data in bank $06, read with DB=$06)
; into the OAM buffer.

sub_00EB1A:
	sep	#$20
	.a8
	lda	#$06
	pha
	plb
	rep	#$20
	.a16
	clc
	lda	$0E,x
	adc	$A0
	sta	$0A
	lda	a:$0000,y
	and	#$00FF
	sta	$16
	iny
loc_00EB32:
	lda	a:$0000,y
	and	#$FF00
	bpl	loc_00EB3D
	ora	#$00FF
loc_00EB3D:
	xba
	clc
	adc	$0A
	cmp	#$00E8
	bcc	loc_00EB4B
	cmp	#$FFF0
	bcc	loc_00EBA9
loc_00EB4B:
	xba
	and	#$FF00
	sta	$04
	dey
	lda	a:$0000,y
	and	#$FF00
	bpl	loc_00EB5D
	ora	#$00FF
loc_00EB5D:
	xba
	clc
	adc	$0A,x
	xba
	lsr	a
	ror	$9C
	asl	a
	xba
	and	#$00FF
	ora	$04
	sta	$08
	iny
	lda	a:$0002,y
	sec
	bit	#$2000
	bne	loc_00EB79
	clc
loc_00EB79:
	ora	$02,x
	sta	$02
	ror	$9C
	bcc	loc_00EB97
	phx
	ldx	$AE
	lda	$9C
	sta	$00,x
	inx
	inx
	stx	$AE
	cpx	#$11E0
	bcs	loc_00EBBA
	lda	#$8000
	sta	$9C
	plx
loc_00EB97:
	phx
	ldx	$AC
	lda	$08
	sta	$00,x
	lda	$02
	sta	$02,x
	inx
	inx
	inx
	inx
	stx	$AC
	plx
loc_00EBA9:
	iny
	iny
	iny
	iny
	dec	$16
	bne	loc_00EB32
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts
loc_00EBBA:
	; (not executed in the CDL traces)
	plx
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts
