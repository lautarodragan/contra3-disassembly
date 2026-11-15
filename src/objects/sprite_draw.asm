; objects/sprite_draw.asm -- Metasprite drawing
; Bank $00, $00:EB1A-$00:EBC3. Included by main.asm in segment BANK00.
;
; draw_metasprite draws an object's metasprite (data in bank $06, read with DB=$06)
; into the OAM buffer.

; Appends the metasprite at Y (bank $06: a count byte, then 4 bytes per
; sprite: dx, dy, tile, attributes) to the OAM buffer at oam_ptr, placed at
; OBJ_X/OBJ_Y of the object at X (+ the screen shake shake_bg1_y), ORing OBJ_ATTR
; into each sprite's attributes; sprites off the screen vertically are
; skipped.  The size and x-high bits go to oam_hi_bits / oam_hi_ptr.
; In: X = slot, Y = metasprite.  Uses zp_02-zp_0A, zp_16.
draw_metasprite:
	sep	#$20
	.a8
	lda	#^sprites_06
	pha
	plb
	rep	#$20
	.a16
	clc
	lda	OBJ_Y,x
	adc	shake_bg1_y
	sta	zp_0A
	lda	a:$0000,y
	and	#$00FF
	sta	zp_16
	iny
loc_00EB32:
	lda	a:$0000,y
	and	#$FF00
	bpl	loc_00EB3D
	ora	#$00FF
loc_00EB3D:
	xba
	clc
	adc	zp_0A
	cmp	#$00E8
	bcc	loc_00EB4B
	cmp	#$FFF0
	bcc	loc_00EBA9
loc_00EB4B:
	xba
	and	#$FF00
	sta	zp_04
	dey
	lda	a:$0000,y
	and	#$FF00
	bpl	loc_00EB5D
	ora	#$00FF
loc_00EB5D:
	xba
	clc
	adc	OBJ_X,x
	xba
	lsr	a
	ror	oam_hi_bits
	asl	a
	xba
	and	#$00FF
	ora	zp_04
	sta	zp_08
	iny
	lda	a:$0002,y
	sec
	bit	#$2000
	bne	loc_00EB79
	clc
loc_00EB79:
	ora	OBJ_ATTR,x
	sta	zp_02
	ror	oam_hi_bits
	bcc	loc_00EB97
	phx
	ldx	oam_hi_ptr
	lda	oam_hi_bits
	sta	$00,x
	inx
	inx
	stx	oam_hi_ptr
	cpx	#$11E0
	bcs	loc_00EBBA
	lda	#$8000
	sta	oam_hi_bits
	plx
loc_00EB97:
	phx
	ldx	oam_ptr
	lda	zp_08
	sta	$00,x
	lda	zp_02
	sta	$02,x
	inx
	inx
	inx
	inx
	stx	oam_ptr
	plx
loc_00EBA9:
	iny
	iny
	iny
	iny
	dec	zp_16
	bne	loc_00EB32
	sep	#$20
	.a8
	lda	#^tables_05
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
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts
