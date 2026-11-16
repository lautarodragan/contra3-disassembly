; objects/object_handlers_02.asm -- Object handlers (bank $02)
; Bank $02, $02:FCCB-$02:FFFF. Included by main.asm in segment BANK02.
;
; The ending fireworks. They run in the player-shot list (free during the
; ending) as shot types $16-$1A of tbl_shot_types: spawn_ending_firework
; (called by ending_sequence in bank $1D), their handlers and
; find_free_shot_slot.

spawn_ending_firework:
	lda	stage_frame_counter
	and	#$007F
	bne	@return
	jsr	a:find_free_shot_slot
	bcs	@return
	lda	stage_frame_counter
	and	#$0180
	asl	a
	xba
	and	#$0003
	sta	a:$0014,y
	lda	#SHOTT_ENDING_FIREWORK
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	zp_E9
	and	#$007F
	clc
	adc	#$0040
	sta	a:$000A,y
	lda	frame_counter
	adc	rng_lo
	and	#$001F
	adc	#$0020
	sta	a:$000E,y
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
find_free_shot_slot_long:
	; (not executed in the CDL traces)
	jsr	a:find_free_shot_slot
	rtl

find_free_shot_slot:
	phx
	ldx	#$0000
@loop:
	txa
	asl	a
	tay
	lda	a:shot_slot_addresses,y
	tay
	lda	a:$0010,y
	beq	@found
	inx
	cpx	#$0028
	bcc	@loop
	; (not executed in the CDL traces)
	sec
	plx
	rts
@found:
	clc
	plx
	rts

; Shot type $16 (tbl_shot_types). Ending: a firework rocket; after 15 frames
; it bursts into 16 sparks of type $17-$1A (chosen by +$14) and clears itself.
; Spawned by spawn_ending_firework once the helicopter has left the screen
; (seen at the end of stage 6).
update_ending_firework:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_ending_firework_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_ending_firework_states:
	.addr	ending_firework_state_00
	.addr	ending_firework_state_01

ending_firework_state_00:
	lda	#$3E4F
	sta	$02,x
	stz	$16,x
	stz	$06,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	stz	$1A,x
	stz	$1C,x
	stz	$18,x
	stz	$00,x
	inc	$12,x
	rtl

ending_firework_state_01:
	inc	$00,x
	lda	$00,x
	cmp	#$000F
	bcc	@return
	jsr	a:spawn_firework_sparks
	stx	zp_00
	lda	#$0000
	ldy	#$0000
@clear_loop:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	@clear_loop
@return:
	rtl

spawn_firework_sparks:
	stz	zp_00
@loop:
	jsr	a:find_free_shot_slot
	bcs	@next
	sty	zp_02
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:firework_spark_types,y
	ldy	zp_02
	sta	a:$0010,y
	lda	zp_00
	sta	a:$0004,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$18,x
	sta	a:$0018,y
	lda	$1A,x
	sta	a:$001A,y
	lda	$1C,x
	sta	a:$001C,y
	lda	$1E,x
	sta	a:$001E,y
@next:
	inc	zp_00
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:firework_spark_counts,y
	cmp	zp_00
	bcs	@loop
	rts

apply_spark_gravity:
	lda	$1C,x
	clc
	adc	#$0400
	sta	$1C,x
	bcc	@return
	inc	$1E,x
@return:
	rts

; Shot type $17, $1A (tbl_shot_types). Ending firework spark with a random
; velocity (random_spark_velocity), falling under gravity, blinking out after
; 60 frames.
update_spark_random:
	jsr	a:apply_spark_gravity
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_spark_random_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spark_random_states:
	.addr	spark_random_state_00
	.addr	spark_random_state_01
	.addr	spark_random_state_02

spark_random_state_00:
	lda	#$3E4F
	sta	$02,x
	jsr	a:random_spark_velocity
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

spark_random_state_01:
	inc	$00,x
	lda	$00,x
	cmp	#$001E
	bcc	@return
	stz	$00,x
	inc	$12,x
@return:
	rtl

spark_random_state_02:
	lda	$00,x
	bit	#$0002
	bne	@alt_palette
	lda	#$3E5E
	bra	@set_palette
@alt_palette:
	lda	#$3E4F
@set_palette:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$003C
	bcc	@return
	stx	zp_00
	lda	#$0000
	ldy	#$0000
@clear_loop:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	@clear_loop
@return:
	rtl

; Shot type $18 (tbl_shot_types). Ending firework spark thrown in one of 16
; directions (+$04, radial_spark_velocity), falling under gravity; cleared
; after 70 frames.
update_spark_radial:
	jsr	a:apply_spark_gravity
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_spark_radial_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spark_radial_states:
	.addr	spark_radial_state_00
	.addr	spark_radial_state_01
	.addr	spark_radial_state_02

spark_radial_state_00:
	lda	#$3E4F
	sta	$02,x
	jsr	a:radial_spark_velocity
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

spark_radial_state_01:
	inc	$00,x
	lda	$00,x
	cmp	#$0032
	bcc	@return
	stz	$00,x
	inc	$12,x
@return:
	rtl

spark_radial_state_02:
	lda	$00,x
	bit	#$0002
	bne	@alt_palette
	lda	#$3C4F
	bra	@set_palette
@alt_palette:
	lda	#$3E4F
@set_palette:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	spark_radial_return
clear_spark_slot:
	stx	zp_00
	lda	#$0000
	ldy	#$0000
@loop:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	@loop
spark_radial_return:
	rtl

; Shot type $19 (tbl_shot_types). As spark_radial at twice the speed, other
; palette.
update_spark_radial_fast:
	jsr	a:apply_spark_gravity
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_spark_radial_fast_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spark_radial_fast_states:
	.addr	spark_radial_fast_state_00
	.addr	spark_radial_fast_state_01
	.addr	spark_radial_fast_state_02

spark_radial_fast_state_00:
	lda	#$3E4F
	sta	$02,x
	jsr	a:radial_spark_velocity
	asl	zp_08
	rol	zp_00
	asl	zp_0A
	rol	zp_02
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

spark_radial_fast_state_01:
	jmp	a:spark_radial_state_01

spark_radial_fast_state_02:
	lda	$00,x
	bit	#$0002
	bne	@alt_palette
	lda	#$324F
	bra	@set_palette
@alt_palette:
	lda	#$384F
@set_palette:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	spark_radial_return
	jmp	a:clear_spark_slot

random_spark_velocity:
	lda	rng_lo
	sta	zp_08
	eor	#$EA9E
	ror	a
	sta	zp_0A
	adc	zp_E9
	sta	rng_lo
	bra	scale_spark_velocity

radial_spark_velocity:
	lda	$04,x
	lsr	a
	lsr	a
	lsr	a
	asl	a
	tay
	lda	a:radial_spark_speeds,y
	and	#$00FF
	sta	zp_00
	tay
	lda	$04,x
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$0010
	and	#$00FF
	sta	zp_00
	jsl	f:polar_to_xy
scale_spark_velocity:
	lda	zp_08
	bmi	@x_negative
	lda	#$0000
	bra	@store_x_sign
@x_negative:
	lda	#$FFFF	; [num]
@store_x_sign:
	sta	zp_00
	lda	zp_08
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_08
	lda	zp_0A
	bmi	@y_negative
	lda	#$0000
	bra	@store_y_sign
@y_negative:
	lda	#$FFFF	; [num]
@store_y_sign:
	sta	zp_02
	lda	zp_0A
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_0A
	rts
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
