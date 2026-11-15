; objects/object_handlers_00b.asm -- Object handlers (bank $00, part 2)
; Bank $00, $00:DDC8-$00:E1B7. Included by main.asm in segment BANK00.
;
; Handlers of the player shots (tbl_shot_types, see
; objects/secondary_objects.asm) and helpers: find_free_shot_slot_up_to and
; find_free_homing_shot_slot find a free shot slot, get_bg_tile_at_object reads the BG map
; under an object.
;
; Shot types by weapon (spawners in objects/player_shots.asm; SHOT_DAMAGE
; in brackets): $01 default gun (2), $02 spread (2; becomes $01 after its
; first frame), $03 crush missile (4) whose blast is made of $0D shots (4),
; $04 homing missile (2), $05 / $06 flame (the first slot $05, the others
; $06), $0B / $0C laser segments (the second slot $0C, damage 3 once their
; delay ran out). $15: a shot that hit something without destroying it,
; bouncing back (damage 0). The other types are not identified.

; Shot type $02: spread gun bullet, first frame (then type $01).
update_spread_shot:
	lda	$04,x
	bmi	loc_00DDEB
	bne	loc_00DDE9
	lda	#$3E1C
	sta	$02,x
	lda	#$0001
	sta	$10,x
	lda	#$0008
	sta	$04,x
	bra	loc_00DDEB

; Shot type $01: bullet of the default gun (also the spread shots after their
; first frame); on a hit it bounces back as type $15.
update_default_shot:
	lda	$04,x
	bmi	loc_00DDEB
	bne	loc_00DDE9
	lda	$14,x
	sta	$02,x
loc_00DDE9:
	dec	$04,x
loc_00DDEB:
	lda	$16,x
	beq	loc_00DE17
loc_00DDEF:
	lda	$18,x
	eor	#$FFFF
	sta	$18,x
	lda	$1A,x
	eor	#$FFFF
	sta	$1A,x
	lda	$1C,x
	eor	#$FFFF
	sta	$1C,x
	lda	$1E,x
	eor	#$FFFF
	sta	$1E,x
	stz	$06,x
	lda	#$0015
	sta	$10,x
	lda	#$0007
	sta	$04,x
loc_00DE17:
	rtl
loc_00DE18:
	lda	$16,x
	bne	loc_00DE20
	dec	$04,x
	bne	loc_00DE2C
loc_00DE20:
	stz	$04,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$06,x
loc_00DE2C:
	rtl

; Shot type $03: crush missile; once its field $04 is 0 it explodes into type
; $0D blast shots around it, one per frame for field $14 frames.
update_crush_shot:
	lda	$04,x
	bne	loc_00DE18
	dec	$14,x
	bne	loc_00DE3D
	stz	$06,x
	lda	#$8000
	sta	$0A,x
	rtl
loc_00DE3D:
	lda	$14,x
	and	#$000E
	tay
	lda	a:data_05A08E,y
	sta	$02,x
	txa
	clc
	adc	#$0020
	tay
	adc	#$0040
	sta	zp_00
@loop:
	lda	a:$0010,y
	beq	loc_00DE63
	tya
	clc
	adc	#$0020
	tay
	cmp	zp_00
	bcc	@loop
	rtl
loc_00DE63:
	lda	rng_lo
	and	#$001F
	sec
	adc	$0A,x
	sbc	#$000F
	sta	a:$000A,y
	lda	rng_hi
	and	#$001F
	sec
	adc	$0E,x
	sbc	#$000F
	sta	a:$000E,y
	lda	#$000A
	sta	a:$0004,y
	lda	#$000D
	sta	a:$0010,y
	lda	#$0004
	sta	a:$0006,y
	lda	frame_counter
	adc	rng_lo
	sta	rng_lo
	adc	rng_hi
	sta	rng_hi
	rtl

; Shot type $04: homing missile: steers towards the next OBJF_TARGET object
; (round robin from wram_1646) by 6 units of direction per frame.
update_homing_shot:
	lda	$16,x
	beq	loc_00DEA3
	brl	loc_00DDEF
loc_00DEA3:
	lda	stage_frame_odd
	bne	loc_00DEAE
	txa
	bit	#$0020
	beq	loc_00DEB5
	; (not executed in the CDL traces)
	rtl
loc_00DEAE:
	txa
	bit	#$0020
	bne	loc_00DEB5
	rtl
loc_00DEB5:
	ldy	a:wram_1646
	lda	#$0021
	sta	zp_00
loc_00DEBD:
	lda	a:$0016,y
	bit	#$0010
	beq	loc_00DECA
	lda	a:$0006,y
	bpl	loc_00DEE3
loc_00DECA:
	tya
	clc
	adc	#$0040
	cmp	#$0AC0
	bcc	loc_00DED7
	lda	#$0280
loc_00DED7:
	tay
	dec	zp_00
	bpl	loc_00DEBD
	sty	a:wram_1646
	lda	$04,x
	bra	loc_00DF38
loc_00DEE3:
	tya
	clc
	adc	#$0040
	cmp	#$0AC0
	bcc	loc_00DEF0
	lda	#$0280
loc_00DEF0:
	sta	a:wram_1646
	lda	a:$0028,y
	lsr	a
	adc	a:$000A,y
	sbc	$0A,x
	sta	zp_08
	lda	a:$002A,y
	sec
	ror	a
	adc	a:$000E,y
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	lsr	a
	and	#$00FE
	sta	zp_0A
	sec
	lda	$04,x
	sbc	zp_0A
	bpl	loc_00DF28
	cmp	#$FFC0
	bcc	loc_00DF2D
loc_00DF20:
	clc
	lda	$04,x
	adc	#$0006
	bra	loc_00DF33
loc_00DF28:
	cmp	#$0040
	bcs	loc_00DF20
loc_00DF2D:
	sec
	lda	$04,x
	sbc	#$0006
loc_00DF33:
	and	#$007E
	sta	$04,x
loc_00DF38:
	tay
	lda	a:vel8_x_sub,y
	sta	$18,x
	lda	a:vel8_x,y
	sta	$1A,x
	lda	a:vel8_y_sub,y
	sta	$1C,x
	lda	a:vel8_y,y
	sta	$1E,x
	tya
	clc
	adc	#$0008
	and	#$007E
	lsr	a
	lsr	a
	lsr	a
	and	#$00FE
	tay
	lda	a:data_05A074,y
	sta	$02,x
	rtl

update_shot_type_05:
	dec	$00,x
	bpl	@return
	lda	#$8000
	sta	$0A,x
	lda	#$3F62
	sta	$02,x
	stz	$12,x
@return:
	rtl

update_shot_type_06:
	dec	$00,x
	bpl	loc_00DF89
	stz	$06,x
	lda	#$0007
	sta	$04,x
	lda	#$0015
	sta	$10,x
	lda	#$FFFC
	sta	$1E,x
	rtl
loc_00DF89:
	lda	stage_frame_bit1
	bne	loc_00DF92
	lda	$04,x
	sta	$02,x
	rtl
loc_00DF92:
	lda	$04,x
	ora	#$4000
	sta	$02,x
	rtl
loc_00DF9A:
	; (not executed in the CDL traces)
	dec	$14,x
	bpl	loc_00DFA9
	lda	#$3E00
	sta	$02,x
	lda	#$8000
	sta	$0A,x
	rtl
loc_00DFA9:
	stz	$18,x
	stz	$1A,x
	stz	$02,x
	txa
	clc
	adc	#$0020
	tay
	adc	#$0100
	sta	zp_00
@loop:
	lda	a:$0010,y
	beq	loc_00DFCA
	tya
	clc
	adc	#$0020
	tay
	cmp	zp_00
	bcc	@loop
	rtl
loc_00DFCA:
	lda	rng_lo
	and	#$001F
	sec
	adc	$0A,x
	sbc	#$000F
	sta	a:$000A,y
	lda	rng_hi
	and	#$001F
	sec
	adc	$0E,x
	sbc	#$000F
	sta	a:$000E,y
	lda	#$000C
	sta	a:$0004,y
	lda	#$000D
	sta	a:$0010,y
	lda	#$0008
	sta	a:$0006,y
	rtl

update_shot_type_07:
	lda	$16,x
	bpl	loc_00DF9A
	clc
	lda	$18,x
	adc	#$2000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	lda	stage_frame_odd
	beq	loc_00E049
	txy
	phx
	txa
	clc
	adc	#$0140
	sta	zp_00
@loop:
	lda	$30,x
	beq	loc_00E029
	txa
	clc
	adc	#$0020
	tax
	cmp	zp_00
	bcc	@loop
	plx
	rtl
loc_00E029:
	lda	#$0012
	sta	$30,x
	lda	a:$000E,y
	sta	$2E,x
	lda	a:$000A,y
	sta	$2A,x
	stz	$38,x
	lda	#$0005
	sta	$3A,x
	stz	$3C,x
	stz	$3E,x
	lda	#$0010
	sta	$24,x
	plx
loc_00E049:
	rtl

update_shot_type_08:
	dec	$04,x
	bne	loc_00E054
	lda	#$8000
	sta	$0A,x
	rtl
loc_00E054:
	; (not executed in the CDL traces)
	lda	$04,x
	and	#$0006
	tay
	lda	a:data_05A084,y
	sta	$02,x
	rtl

; Shot types $0A and $0B: laser segment, inactive (damage 0) until its delay
; (field $04) runs out, then damage 3.
update_laser_shot:
	lda	$04,x
	beq	update_shot_type_09
	dec	$04,x
	bne	@return
	lda	#$0003
	sta	$06,x
	lda	$14,x
	sta	$02,x
@return:
	rtl

update_shot_type_09:
	lda	$16,x
	bmi	loc_00E08B
	lda	#$0008
	sta	$10,x
	stz	$06,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#$0001
	sta	$04,x
	rtl
loc_00E08B:
	lda	stage_frame_bit1
	beq	loc_00E097
	lda	$02,x
	and	#$F1FF
	sta	$02,x
	rtl
loc_00E097:
	lda	$02,x
	ora	#$0200
	sta	$02,x
	rtl

update_shot_type_0C:
	dec	$04,x
	beq	loc_00E0AF
	lda	stage_frame_mod8
	and	#$0006
	tay
	lda	a:data_05A086,y
	sta	$02,x
	rtl
loc_00E0AF:
	lda	#$8000
	sta	$0A,x
	rtl

; Shot type $0D: one blast of the crush missile (damage 4, or 8 from type
; $07), frees itself when field $04 runs out.
update_crush_blast:
	lda	$16,x
	beq	loc_00E0BB
	stz	$06,x
loc_00E0BB:
	dec	$04,x
	bpl	loc_00E0C7
	stz	$06,x
	lda	#$8000
	sta	$0A,x
	rtl
loc_00E0C7:
	lda	$04,x
	and	#$FFFE
	tay
	lda	a:data_05A08E,y
	sta	$02,x
	rtl

update_shot_type_0E:
	; (not executed in the CDL traces)
	dec	$04,x
	bne	@return
	lda	#$8000
	sta	$0A,x
@return:
	rtl

update_shot_type_10:
	clc
	lda	$18,x
	adc	#$1000
	sta	$18,x
	lda	$1A,x
	adc	#$FFFF
	sta	$1A,x
	dec	$04,x
	beq	loc_00E0FC
	lda	$04,x
	and	#$FFFE
	tay
	lda	a:data_05A09E,y
	sta	$02,x
	rtl
loc_00E0FC:
	lda	#$8000
	sta	$0A,x
	rtl

update_shot_type_13:
	; (not executed in the CDL traces)
	dec	$04,x
	bne	@return
	lda	#$8000
	sta	$0A,x
@return:
	rtl

; Shot type $15: a shot that hit without destroying its target, flying back
; with damage 0 until field $04 runs out.
update_spent_shot:
	dec	$04,x
	bne	loc_00E116
	lda	#$8000
	sta	$0A,x
	rtl
loc_00E116:
	lda	$04,x
	and	#$0006
	tay
	lda	a:data_05A0AE,y
	sta	$02,x
	rtl

; Returns in X the first free shot slot from X up to zp_06, carry clear;
; carry set when there is none.
find_free_shot_slot_up_to:
	lda	$10,x
	beq	loc_00E132
	txa
	clc
	adc	#$0020
	tax
	cmp	zp_06
	bne	find_free_shot_slot_up_to
	sec
	rtl
loc_00E132:
	clc
	rtl

find_free_homing_shot_slot:
	txa
	clc
	adc	#$0080
	tax
	lda	$10,x
	beq	loc_00E168
	txa
	sec
	sbc	#$0040
	tax
	lda	$10,x
	beq	loc_00E168
	txa
	clc
	adc	#$0080
	tax
	lda	$10,x
	beq	loc_00E168
	txa
	sec
	sbc	#$00C0
	tax
	lda	$10,x
	beq	loc_00E168
	txa
	clc
	adc	#$0100
	tax
	lda	$10,x
	beq	loc_00E168
	sec
	rtl
loc_00E168:
	clc
	rtl
loc_00E16A:
	lda	#$0000
	rtl

; Returns in A the BG map entry ($7E:4000) under the object at X plus the
; offset (zp_00, zp_02); 0 when below the screen (y >= $E0). Used for floor
; and wall collision.
get_bg_tile_at_object:
	clc
	lda	$0E,x
	adc	zp_02
	cmp	#$00E0
	bcs	loc_00E16A
	clc
	adc	a:bg1_y
	and	#$00FF
	sta	zp_0A
	lda	a:bg1_x
	clc
	adc	$0A,x
	clc
	adc	zp_00
	and	#$01FF
	sta	zp_08
	and	#$0100
	asl	a
	asl	a
	sta	zp_0C
	lda	zp_08
	lsr	a
	lsr	a
	lsr	a
	and	#$001F
	ora	zp_0C
	sta	zp_0C
	lda	zp_0A
	asl	a
	asl	a
	and	#$03E0
	ora	zp_0C
	phx
	asl	a
	tax
	lda	f:$7E4000,x
	sta	zp_08
	plx
	lda	zp_08
	rtl
