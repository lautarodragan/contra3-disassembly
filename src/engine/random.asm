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
	lda	$E8
	bne	loc_00817B
	lda	$3A
	sta	$E8
loc_00817B:
	eor	#$FFFF
	sta	$E6
	lda	$EA
	eor	$E6
	asl	$E8
	rol	$EA
	asl	$E6
	bcc	loc_00819A
	lda	$E8
	eor	#$2125
	sta	$E8
	lda	$EA
	eor	#$1010
	sta	$EA
loc_00819A:
	rtl
