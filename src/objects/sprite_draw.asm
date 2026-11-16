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
@loop:
	lda	a:$0000,y
	and	#$FF00
	bpl	@have_dy
	ora	#$00FF
@have_dy:
	xba
	clc
	adc	zp_0A
	cmp	#$00E8
	bcc	@on_screen
	cmp	#$FFF0	; [num]
	bcc	@next_sprite
@on_screen:
	xba
	and	#$FF00
	sta	zp_04
	dey
	lda	a:$0000,y
	and	#$FF00
	bpl	@have_dx
	ora	#$00FF
@have_dx:
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
	bne	@have_size_bit
	clc
@have_size_bit:
	ora	OBJ_ATTR,x
	sta	zp_02
	ror	oam_hi_bits
	bcc	@store_sprite
	phx
	ldx	oam_hi_ptr
	lda	oam_hi_bits
	sta	$00,x
	inx
	inx
	stx	oam_hi_ptr
	cpx	#$11E0
	bcs	@oam_hi_full
	lda	#$8000	; [num]
	sta	oam_hi_bits
	plx
@store_sprite:
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
@next_sprite:
	iny
	iny
	iny
	iny
	dec	zp_16
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts
@oam_hi_full:
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
