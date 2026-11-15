; engine/random.asm -- Random number generator
; Bank $00, $00:816C-$00:819A. Included by main.asm in segment BANK00.
;
; next_random: 32-bit shift-register generator in rng_lo/rng_hi, seeded from
; frame_counter while 0. Called once per frame by the NMI frame handlers.
; Returns the new rng_lo in A (16-bit); uses zp_E6.

next_random:
	rep	#$30
	ldx	#$0000
	phx
	pld
	lda	rng_lo
	bne	@seeded
	lda	frame_counter
	sta	rng_lo
@seeded:
	eor	#$FFFF
	sta	zp_E6
	lda	rng_hi
	eor	zp_E6
	asl	rng_lo
	rol	rng_hi
	asl	zp_E6
	bcc	@done
	lda	rng_lo
	eor	#$2125
	sta	rng_lo
	lda	rng_hi
	eor	#$1010
	sta	rng_hi
@done:
	rtl
