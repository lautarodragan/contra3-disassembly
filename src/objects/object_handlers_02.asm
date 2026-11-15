; objects/object_handlers_02.asm -- Object handlers (bank $02)
; Bank $02, $02:FCCB-$02:FFFF. Included by main.asm in segment BANK02.
;
; The ending fireworks: handlers of secondary-list types $16-$1A
; (tbl_shot_types), spawn_ending_firework (called by ending_sequence in bank
; $1D) and find_free_secondary_slot.

spawn_ending_firework:
	lda	stage_frame_counter
	and	#$007F
	bne	loc_02FD09
	jsr	a:find_free_secondary_slot
	bcs	loc_02FD09
	lda	stage_frame_counter
	and	#$0180
	asl	a
	xba
	and	#$0003
	sta	a:$0014,y
	lda	#$0016
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
loc_02FD09:
	rtl

; (no caller found; decoded because it follows the end of a routine)
find_free_secondary_slot_long:
	; (not executed in the CDL traces)
	jsr	a:find_free_secondary_slot
	rtl

find_free_secondary_slot:
	phx
	ldx	#$0000
loc_02FD12:
	txa
	asl	a
	tay
	lda	a:data_05E6E4,y
	tay
	lda	a:$0010,y
	beq	loc_02FD27
	inx
	cpx	#$0028
	bcc	loc_02FD12
	; (not executed in the CDL traces)
	sec
	plx
	rts
loc_02FD27:
	clc
	plx
	rts

; Object type $16 (secondary list). Ending: a firework rocket; after 15 frames
; it bursts into 15 sparks of type $17-$1A (chosen by +$14) and clears itself.
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
	lda	#$FFFF
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
	bcc	loc_02FD73
	jsr	a:spawn_firework_sparks
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FD6A:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FD6A
loc_02FD73:
	rtl

spawn_firework_sparks:
	stz	zp_00
loc_02FD76:
	jsr	a:find_free_secondary_slot
	bcs	loc_02FDB5
	sty	zp_02
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:data_05E734,y
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
loc_02FDB5:
	inc	zp_00
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:data_05E73C,y
	cmp	zp_00
	bcs	loc_02FD76
	rts

apply_spark_gravity:
	lda	$1C,x
	clc
	adc	#$0400
	sta	$1C,x
	bcc	loc_02FDD2
	inc	$1E,x
loc_02FDD2:
	rts

; Object type $17, $1A (secondary list). Ending firework spark with a random
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
	bcc	loc_02FE18
	stz	$00,x
	inc	$12,x
loc_02FE18:
	rtl

spark_random_state_02:
	lda	$00,x
	bit	#$0002
	bne	loc_02FE25
	lda	#$3E5E
	bra	loc_02FE28
loc_02FE25:
	lda	#$3E4F
loc_02FE28:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$003C
	bcc	loc_02FE44
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FE3B:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FE3B
loc_02FE44:
	rtl

; Object type $18 (secondary list). Ending firework spark thrown in one of 16
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
	bcc	loc_02FE8A
	stz	$00,x
	inc	$12,x
loc_02FE8A:
	rtl

spark_radial_state_02:
	lda	$00,x
	bit	#$0002
	bne	loc_02FE97
	lda	#$3C4F
	bra	loc_02FE9A
loc_02FE97:
	lda	#$3E4F
loc_02FE9A:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	loc_02FEB6
loc_02FEA5:
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FEAD:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FEAD
loc_02FEB6:
	rtl

; Object type $19 (secondary list). As spark_radial at twice the speed, other
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
	bne	loc_02FF06
	lda	#$324F
	bra	loc_02FF09
loc_02FF06:
	lda	#$384F
loc_02FF09:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	loc_02FEB6
	jmp	a:loc_02FEA5

random_spark_velocity:
	lda	rng_lo
	sta	zp_08
	eor	#$EA9E
	ror	a
	sta	zp_0A
	adc	zp_E9
	sta	rng_lo
	bra	loc_02FF4B

radial_spark_velocity:
	lda	$04,x
	lsr	a
	lsr	a
	lsr	a
	asl	a
	tay
	lda	a:data_05E744,y
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
	jsl	f:sub_1DACA4
loc_02FF4B:
	lda	zp_08
	bmi	loc_02FF54
	lda	#$0000
	bra	loc_02FF57
loc_02FF54:
	lda	#$FFFF
loc_02FF57:
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
	bmi	loc_02FF6D
	lda	#$0000
	bra	loc_02FF70
loc_02FF6D:
	lda	#$FFFF
loc_02FF70:
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
	; CDL: not accessed
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF
