; engine/trig.asm -- Angle and trigonometry helpers
; Bank $1D, $1D:ABA0-$1D:AF26. Included by main.asm in segment BANK1D.
;
; Angles are bytes: 0 up, $40 right, $80 down, $C0 left (clockwise). The
; sine tables are a quarter wave of 64 entries, value x 256 (quarter_sine,
; quarter_cosine = sin/cos x 256, with quarter_sine_lo / quarter_cosine_lo
; the next 8 fraction bits); atan_table gives the angle of a ratio.
;
; calc_angle: zp_08 = dx, zp_0A = dy (magnitudes below 256, sign in the high
; byte) -> A = angle. polar_to_xy: A = angle, Y = radius -> zp_08 = x,
; zp_0A = y. set_velocity_from_angle: X = object, A = speed (1/16 pixel per
; frame), angle in the object's byte +$04 -> OBJ_X_VEL / OBJ_Y_VEL (and
; their fractions). calc_distance: sqrt(dx^2 + dy^2) of zp_08/zp_0A ($FF if
; too far); half_distance_squared: (dx^2 + dy^2) / 2 ($FFFE if too far).

; zp_08 = dx, zp_0A = dy (16-bit; only magnitudes below 256 are handled).
; Returns the angle in A (16-bit, 0-255); keeps X and Y.
calc_angle:
	.a16
	.i16
	phx
	phy
	jsr	a:calc_angle_8
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	and	#$00FF
	ply
	plx
	rtl

calc_angle_8:
	sep	#$30
	.a8
	.i8
	lda	zp_08
	bne	@dx_nonzero
	ldy	zp_0B
	bpl	@down
	rts
@down:
	lda	#$80
	rts
@dx_nonzero:
	lda	zp_0A
	bne	@general
	lda	zp_09
	bmi	@left
	lda	#$40
	rts
@left:
	lda	#$C0
	rts
@general:
	lda	zp_09
	bmi	@dx_negative
	lda	zp_0B
	bpl	@dy_positive_right
	lda	zp_0A
	eor	#$FF
	inc	a
	sta	zp_0A
	cmp	zp_08
	bne	@not_diagonal_ne
	lda	#$20
	rts
@not_diagonal_ne:
	bcc	@ne_steep
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	stz	zp_0C
	lda	zp_0A
	bra	@divide_add
@ne_steep:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$40
	sta	zp_0C
	lda	zp_08
	bra	@divide_subtract
@dy_positive_right:
	lda	zp_0A
	cmp	zp_08
	bne	@not_diagonal_se
	lda	#$60
	rts
@not_diagonal_se:
	bcc	@se_steep
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$80
	sta	zp_0C
	lda	zp_0A
@divide_subtract:
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	sec
	lda	zp_0C
	ldy	a:RDDIVL
	sbc	a:atan_table,y
	rts
@se_steep:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$40
	sta	zp_0C
	lda	zp_08
@divide_add:
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	clc
	lda	zp_0C
	ldy	a:RDDIVL
	adc	a:atan_table,y
	rts
@dx_negative:
	lda	zp_08
	eor	#$FF
	inc	a
	sta	zp_08
	lda	zp_0B
	bmi	@dy_negative_left
	lda	zp_0A
	cmp	zp_08
	bne	@not_diagonal_sw
	lda	#$A0
	rts
@not_diagonal_sw:
	bcc	@sw_steep
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$80
	sta	zp_0C
	lda	zp_0A
	bra	@divide_add
@sw_steep:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$C0
	sta	zp_0C
	lda	zp_08
	bra	@divide_subtract
@dy_negative_left:
	lda	zp_0A
	eor	#$FF
	inc	a
	sta	zp_0A
	cmp	zp_08
	bne	@not_diagonal_nw
	lda	#$E0
	rts
@not_diagonal_nw:
	bcc	@nw_steep
	lda	zp_08
	sta	a:WRDIVH
	stz	a:WRDIVL
	stz	zp_0C
	lda	zp_0A
	bra	@divide_subtract
@nw_steep:
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	#$C0
	sta	zp_0C
	lda	zp_08
	bra	@divide_add

; A = angle, Y = radius (8-bit): zp_08 = radius * sin, zp_0A = -radius * cos.
polar_to_xy:
	.a16
	.i16
	sty	a:WRMPYA
	bit	#$0080
	bne	@quadrant23
	bit	#$0040
	bne	@quadrant1
	jsr	a:scale_sine_cosine
	lda	#$0000
	sec
	sbc	zp_0A
	sta	zp_0A
	rtl
@quadrant1:
	jsr	a:scale_sine_cosine
	lda	zp_08
	ldy	zp_0A
	sty	zp_08
	sta	zp_0A
	rtl
@quadrant23:
	bit	#$0040
	bne	@quadrant3
	jsr	a:scale_sine_cosine
	lda	#$0000
	sec
	sbc	zp_08
	sta	zp_08
	rtl
@quadrant3:
	jsr	a:scale_sine_cosine
	lda	#$0000
	sec
	sbc	zp_08
	tay
	lda	#$0000
	sec
	sbc	zp_0A
	sta	zp_08
	sty	zp_0A
	rtl

scale_sine_cosine:
	and	#$003F
	tay
	sep	#$20
	.a8
	lda	a:quarter_sine_lo,y
	sta	a:WRMPYB
	nop
	stz	zp_09
	lda	a:RDMPYH
	sta	zp_08
	lda	a:quarter_sine,y
	sta	a:WRMPYB
	rep	#$20
	.a16
	clc
	lda	zp_08
	adc	a:RDMPYL
	xba
	and	#$00FF
	sta	zp_08
	sep	#$20
	.a8
	lda	a:quarter_cosine_lo,y
	sta	a:WRMPYB
	nop
	stz	zp_0B
	lda	a:RDMPYH
	sta	zp_0A
	lda	a:quarter_cosine,y
	sta	a:WRMPYB
	rep	#$20
	.a16
	clc
	lda	zp_0A
	adc	a:RDMPYL
	xba
	and	#$00FF
	sta	zp_0A
	rts

half_distance_squared:
	phy
	lda	zp_08
	bpl	@dx_abs
	eor	#$FFFF
	inc	a
@dx_abs:
	cmp	#$0100
	bcs	@too_far
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	lda	zp_0A
	bpl	@dy_abs
	eor	#$FFFF
	inc	a
@dy_abs:
	cmp	#$0100
	bcs	@too_far
	ldy	a:RDMPYL
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	tya
	lsr	a
	sta	zp_FA
	lda	a:RDMPYL
	lsr	a
	clc
	adc	zp_FA
	ply
	rtl
@too_far:
	lda	#$FFFE
	ply
	rtl

set_velocity_from_angle_y:
	phx
	phy
	tyx
	jsl	f:set_velocity_from_angle
	ply
	plx
	rtl

; X = object, A = speed; angle in byte +$04 of the object (also used as
; OBJ_FACING by other objects). Velocity = speed * sin / 16 (x) and
; -speed * cos / 16 (y), in 12.4 fixed point split into the OBJ velocity
; words.
set_velocity_from_angle:
	sep	#$20
	.a8
	sta	a:WRMPYA
	lda	$04,x
	bit	#$80
	beq	@quadrant01
	brl	@quadrant23
@quadrant01:
	bit	#$40
	bne	@quadrant1
	and	#$3F
	tay
	lda	a:quarter_sine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	OBJ_X_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	OBJ_X_VEL_SUB,x
	sep	#$20
	.a8
	lda	a:quarter_cosine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	OBJ_Y_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	OBJ_Y_VEL_SUB,x
	bne	@done
	; (not executed in the CDL traces)
	inc	OBJ_Y_VEL,x
@done:
	rtl
@quadrant1:
	.a8
	and	#$3F
	tay
	lda	a:quarter_cosine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	OBJ_X_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	OBJ_X_VEL_SUB,x
	sep	#$20
	.a8
	lda	a:quarter_sine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	OBJ_Y_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	OBJ_Y_VEL_SUB,x
	rtl
@quadrant23:
	.a8
	bit	#$40
	bne	@quadrant3
	and	#$3F
	tay
	lda	a:quarter_sine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	OBJ_X_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	OBJ_X_VEL_SUB,x
	bne	@q2_y
	; (not executed in the CDL traces)
	inc	OBJ_X_VEL,x
@q2_y:
	sep	#$20
	.a8
	lda	a:quarter_cosine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	sta	OBJ_Y_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	sta	OBJ_Y_VEL_SUB,x
	rtl
@quadrant3:
	.a8
	and	#$3F
	tay
	lda	a:quarter_cosine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	OBJ_X_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	OBJ_X_VEL_SUB,x
	bne	@q3_y
	; (not executed in the CDL traces)
	inc	OBJ_X_VEL,x
@q3_y:
	sep	#$20
	.a8
	lda	a:quarter_sine,y
	sta	a:WRMPYB
	nop
	rep	#$20
	.a16
	lda	a:RDMPYH
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	eor	#$FFFF
	sta	OBJ_Y_VEL,x
	lda	a:RDMPYL
	asl	a
	asl	a
	asl	a
	asl	a
	eor	#$FFFF
	sta	OBJ_Y_VEL_SUB,x
	bne	@q3_done
	; (not executed in the CDL traces)
	inc	OBJ_Y_VEL,x
@q3_done:
	rtl

; zp_08 = dx, zp_0A = dy: A = integer square root of dx^2 + dy^2.
calc_distance:
	phy
	lda	zp_08
	bpl	@dx_abs
	eor	#$FFFF
	inc	a
@dx_abs:
	cmp	#$0100
	bcs	@too_far
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	lda	zp_0A
	bpl	@dy_abs
	eor	#$FFFF
	inc	a
@dy_abs:
	cmp	#$0100
	bcs	@too_far
	ldy	a:RDMPYL
	sep	#$20
	.a8
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	tya
	sta	zp_FA
	lda	a:RDMPYL
	clc
	adc	zp_FA
	bcs	@too_far
	ply
	bra	@sqrt
@too_far:
	; (not executed in the CDL traces)
	lda	#$00FF
	ply
	rtl
@sqrt:
	phy
	ldy	#$FFFF
@sqrt_loop:
	iny
	iny
	sty	zp_FA
	sec
	sbc	zp_FA
	bcs	@sqrt_loop
	lda	zp_FA
	lsr	a
	ply
	rtl
