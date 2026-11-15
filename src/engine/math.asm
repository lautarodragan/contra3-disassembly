; engine/math.asm -- Arithmetic helpers
; Bank $00, $00:8986-$00:8B18. Included by main.asm in segment BANK00.
;
; Helpers the CDL traces never ran: a Mode 7 matrix calculation
; (unused_calc_mode7_matrix), sub_0089E4 (about A * X / $8000, done with two
; hardware divisions), sub_008A58, clear_object_slot and multiply_16x16.

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) Mode 7 matrix shadows m7a-m7d from the angle at $1F98 (sine
; table data_058010) and the scales at $1F94/$1F96, and M7X/M7Y from
; $1F90/$1F92.
unused_calc_mode7_matrix:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	ldy	#$0003
@loop:
	phy
	tya
	asl	a
	tax
	lsr	a
	and	#$0002
	tay
	lda	a:p1_m7_angle
	clc
	adc	f:data_058000,x
	and	#$01FF
	pha
	lda	a:p1_m7_angle
	and	#$00FF
	asl	a
	clc
	adc	f:data_058008,x
	and	#$01FF
	tax
	lda	f:data_058010,x
	ldx	a:$1F94,y
	jsl	f:sub_0089E4
	pla
	cmp	#$0100
	bcc	@positive
	lda	#$0000
	sec
	sbc	zp_00
	sta	zp_00
@positive:
	ply
	tya
	asl	a
	tax
	lda	zp_00
	sta	a:$1E9E,x
	dey
	bpl	@loop
	lda	a:p1_m7_center_x
	sta	a:m7x_shadow
	lda	a:p1_m7_center_y
	sta	a:m7y_shadow
	rtl

; (Not run in the traces.) A, X 16-bit: computes about A * X / $8000 in zp_00
; as (A / 2) / ($8000 / X), with the hardware 16/8 divider, scaling the
; divisors down to 8 bits. Uses zp_00-zp_04.
sub_0089E4:
	; (not executed in the CDL traces)
	rep	#$30
	sta	zp_00
	stx	zp_02
	lda	#$8000
	sta	zp_04
	ldy	#$0008
	lda	zp_02
loc_0089F4:
	asl	a
	bcs	loc_0089FC
	dey
	bne	loc_0089F4
	beq	loc_008A03
loc_0089FC:
	lsr	zp_04
	lsr	zp_02
	dey
	bne	loc_0089FC
loc_008A03:
	lda	zp_04
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	zp_02
	sta	a:WRDIVB
	lda	#$04
loc_008A11:
	dec	a
	bne	loc_008A11
	rep	#$20
	.a16
	ldx	a:RDDIVL
	stx	zp_02
	lda	zp_00
	cmp	#$FFFF
	clc
	bne	loc_008A27
	lda	#$0000
	sec
loc_008A27:
	ror	a
	sta	zp_00
	ldy	#$0008
	lda	zp_02
loc_008A2F:
	asl	a
	bcs	loc_008A37
	dey
	bne	loc_008A2F
	beq	loc_008A3E
loc_008A37:
	lsr	zp_00
	lsr	zp_02
	dey
	bne	loc_008A37
loc_008A3E:
	lda	zp_00
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	zp_02
	sta	a:WRDIVB
	lda	#$04
loc_008A4C:
	dec	a
	bne	loc_008A4C
	rep	#$20
	.a16
	lda	a:RDDIVL
	asl	a
	sta	zp_00
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) zp_08:zp_0A = (zp_00 - zp_02) shifted left by Y (right if Y
; is negative); zp_00:zp_02 = zp_04:zp_06 - zp_08:zp_0A.
sub_008A58:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10
	lda	zp_00
	sec
	sbc	zp_02
	sta	zp_08
	lda	#$0000
	sbc	#$0000
	sta	zp_0A
	sta	zp_0C
	tya
	beq	@done
	bmi	@shift_right
@shift_left:
	asl	zp_08
	rol	zp_0A
	dey
	bne	@shift_left
	beq	@done
@shift_right:
	lsr	zp_0C
	ror	zp_0A
	ror	zp_08
	iny
	bne	@shift_right
@done:
	lda	zp_04
	sec
	sbc	zp_08
	sta	zp_00
	lda	zp_06
	sbc	zp_0A
	sta	zp_02
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) Same with the slot in Y.
clear_object_slot_y:
	; (not executed in the CDL traces)
	phx
	tyx
	jsl	f:clear_object_slot
	plx
	rtl

; (Not run in the traces.) Clears the $40 bytes at X (an object slot).
clear_object_slot:
	; (not executed in the CDL traces)
	stz	$04,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	stz	$00,x
	stz	$02,x
	stz	$14,x
	stz	$06,x
	stz	$10,x
	stz	$12,x
	stz	$16,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$20,x
	stz	$22,x
	stz	$24,x
	stz	$26,x
	stz	$28,x
	stz	$2A,x
	stz	$2C,x
	stz	$2E,x
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	stz	$38,x
	stz	$3A,x
	stz	$3C,x
	stz	$3E,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) zp_04-zp_07 = zp_00 * zp_02 (unsigned 16 x 16 -> 32 bits).
multiply_16x16:
	; (not executed in the CDL traces)
	sep	#$10
	.i8
	ldx	zp_00
	ldy	zp_02
	sty	a:WRMPYA
	stx	a:WRMPYB
	stz	zp_06
	ldx	zp_01
	lda	a:RDMPYL
	stx	a:WRMPYB
	sta	zp_04
	ldx	zp_00
	lda	a:RDMPYL
	ldy	zp_03
	sty	a:WRMPYA
	stx	a:WRMPYB
	clc
	adc	zp_05
	clc
	adc	a:RDMPYL
	ldx	zp_01
	stx	a:WRMPYB
	sta	zp_05
	lda	zp_06
	clc
	adc	a:RDMPYL
	sta	zp_06
	rep	#$10
	.i16
	rtl
