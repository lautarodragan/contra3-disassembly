; engine/random.asm -- Random number generator
; Bank $00, $00:816C-$00:819A. Included by main.asm in segment BANK00.
;
; sub_00816C: 32-bit shift-register generator at $E8/$EA, seeded from the
; frame counter when 0. Called once per frame by the NMI frame handlers.

sub_00816C:
	rep	#$30
	ldx	#$0000
	phx
	pld
	lda	rng_lo
	bne	loc_00817B
	lda	frame_counter
	sta	rng_lo
loc_00817B:
	eor	#$FFFF
	sta	zp_E6
	lda	rng_hi
	eor	zp_E6
	asl	rng_lo
	rol	rng_hi
	asl	zp_E6
	bcc	loc_00819A
	lda	rng_lo
	eor	#$2125
	sta	rng_lo
	lda	rng_hi
	eor	#$1010
	sta	rng_hi
loc_00819A:
	rtl
