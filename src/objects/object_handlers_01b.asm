; objects/object_handlers_01b.asm -- Object handlers (bank $01, part 2)
; Bank $01, $01:CF8B-$01:F6A7. Included by main.asm in segment BANK01.
;
; Handlers of object types dispatched through tbl_object_types and their helpers.

; (no caller found; decoded because it follows the end of a routine)
sub_01CF8B:
	; (not executed in the CDL traces)
	clc
	lda	$1C,x
	adc	$30,x
	sta	$1C,x
	lda	$1E,x
	adc	$32,x
	sta	$1E,x

; Object type $46: becomes an explosion effect (type $1D) where there is a
; solid BG tile (stage 3 boss).
update_debris_explosion:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	loc_01CFBA
	lda	#.loword(anim_05C59A)
	sta	$20,x
	stz	$22,x
	lda	#OBJT_EFFECT
	sta	$10,x
	lda	#$0003
	sta	$16,x
	stz	$1A,x
	lda	#$FFFE
	sta	$1E,x
loc_01CFBA:
	rtl

; Object type $4B: becomes a type $1D effect flying in a random direction
; (stage 3 boss).
update_debris_spark:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	loc_01CFF4

sub_01CFC5:
	lda	#.loword(anim_05C672)
	sta	$20,x
	stz	$22,x
	lda	#OBJT_EFFECT
	sta	$10,x
	lda	#$0003
	sta	$16,x
	lda	rng_lo
	adc	rng_hi
	sta	rng_lo
	and	#$003E
	tay
	lda	a:data_0593CA,y
	sta	$1E,x
	lda	a:data_0593DA,y
	sta	$1A,x
	lda	a:data_05941A,y
	sta	$1C,x
	lda	a:data_05942A,y
	sta	$18,x
loc_01CFF4:
	rtl

; Object type $1D: effect (explosion, spark, fire): plays OBJ_ANIM and frees
; itself when the script ends (make_effect_object).
update_effect:
	ldy	$20,x
	bne	loc_01CFFF
	lda	#$8000
	sta	$16,x
	rtl
loc_01CFFF:
	lda	a:$0004,y
	sta	$02,x
	rtl

sub_01D005:
	phx
	pha
	xba
	and	#$003E
	tax
	pla
	and	#$00FF
	sta	zp_04
	ldy	#$0700
loc_01D015:
	jsl	f:find_free_slot_y_down
	bcc	loc_01D044
	lda	#.loword(anim_05C558)
	jsl	f:make_effect_object
	lda	a:data_0593CA,x
	sta	a:$001E,y
	lda	a:data_0593DA,x
	sta	a:$001A,y
	lda	a:data_05941A,x
	sta	a:$001C,y
	lda	a:data_05942A,x
	sta	a:$0018,y
	lda	zp_FA
	sta	a:$000A,y
	lda	zp_FE
	sta	a:$000E,y
loc_01D044:
	txa
	clc
	adc	zp_08
	and	#$003E
	tax
	tya
	sec
	sbc	#$0040
	cmp	#$0340
	bcc	loc_01D05B
	tay
	dec	zp_04
	bne	loc_01D015
loc_01D05B:
	plx
	rtl

; Object type $1E: alien dog that jumps out at the player (stage 1 sections
; 2-3; seen in the emulator).
update_alien_dog:
	lda	$06,x
	bpl	loc_01D064
	jmp	a:loc_01D149
loc_01D064:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_alien_dog_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_alien_dog_states:
	.addr	alien_dog_state_00
	.addr	alien_dog_state_01
	.addr	alien_dog_state_02
	.addr	alien_dog_state_03
	.addr	alien_dog_state_04
	.addr	alien_dog_state_05

alien_dog_state_00:
	lda	#$0003
	sta	$16,x
	lda	#$3800
	sta	$02,x
	stz	$26,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	$04,x
	lda	#.loword(anim_05C714)
	sta	$20,x
	stz	$22,x
	inc	$12,x

alien_dog_state_01:
	jsr	a:sub_01D0A4
	bcc	loc_01D0E8
	rtl

sub_01D0A4:
	lda	a:p1_lives
	beq	loc_01D0B4
	lda	$0A,x
	sec
	sbc	#$0020
	cmp	a:wram_020A
	bcs	loc_01D0C5
loc_01D0B4:
	lda	a:p2_lives
	beq	loc_01D0C4
	lda	$0A,x
	sec
	sbc	#$0020
	cmp	a:wram_024A
	bcs	loc_01D0C5
loc_01D0C4:
	clc
loc_01D0C5:
	rts

sub_01D0C6:
	lda	a:p1_lives
	beq	loc_01D0D6
	lda	$0A,x
	clc
	adc	#$0050
	cmp	a:wram_020A
	bcs	loc_01D0E7
loc_01D0D6:
	lda	a:p2_lives
	beq	loc_01D0E6
	lda	$0A,x
	clc
	adc	#$0050
	cmp	a:wram_024A
	bcs	loc_01D0E7
loc_01D0E6:
	clc
loc_01D0E7:
	rts
loc_01D0E8:
	stz	$04,x
	lda	#.loword(anim_05C752)
	sta	$20,x
	stz	$22,x
	inc	$12,x

alien_dog_state_02:
	lda	difficulty
	beq	loc_01D0FC
	jsr	a:sub_01D0C6
	bcc	loc_01D0FD
loc_01D0FC:
	rtl
loc_01D0FD:
	lda	#$081F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	ldy	difficulty
	lda	a:alien_dog_hp,y
	sta	$06,x
	lda	#$0002
	sta	$1A,x
	lda	#$0000
	sta	$18,x
	lda	#$0000
	sta	$1E,x
	lda	#$8000
	sta	$1C,x
	stz	$04,x
	lda	#.loword(anim_05C778)
	sta	$20,x
	stz	$22,x
	inc	$12,x

alien_dog_state_03:
	lda	$0E,x
	cmp	#$00C8
	bcs	loc_01D13A
	rtl
loc_01D13A:
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

alien_dog_state_04:
	lda	$3E,x
	beq	loc_01D148
	; (not executed in the CDL traces)
	stz	$3E,x
	bra	loc_01D149
loc_01D148:
	rtl
loc_01D149:
	lda	#$000B
	jsl	f:queue_sound
	stz	$06,x
	lda	#$0007
	sta	$16,x
	lda	#$FFFF
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	lda	#$FFFC
	sta	$1E,x
	lda	#$0000
	sta	$1C,x
	stz	$04,x
	lda	#.loword(anim_05C78C)
	sta	$20,x
	stz	$22,x
	lda	#$0010
	sta	$24,x
	lda	#$0005
	sta	$12,x
	rtl

alien_dog_state_05:
	dec	$24,x
	bne	loc_01D1A1
	lda	$0A,x
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	#$0010
	sta	$0E,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rtl
loc_01D1A1:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $18: enemy bullet (spawn_enemy_bullet allocates them); deleted when it
; touches a player.
update_enemy_bullet:
	lda	$12,x
	bne	loc_01D1D2
	lda	#$180F
	sta	$16,x
	jsl	f:sub_01D1DB
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	stz	$20,x
	lda	#.loword(metasprite_06AF55)
	sta	$00,x
	inc	$12,x
	rtl
loc_01D1D2:
	lda	$3C,x
	beq	sub_01D1DB
	lda	#$8000
	sta	$16,x

sub_01D1DB:
	lda	stage_frame_counter
	and	#$0006
	tay
	lda	a:data_05C792,y
	sta	$02,x
	rtl

; Object type $1B: killed soldier thrown back (start_dying_soldier*), then
; an explosion effect.
update_dying_soldier:
	lda	$12,x
	bne	loc_01D23C
; Entry points used by soldier handlers when killed: turn the object into
; type $1B (thrown back, then an explosion). With sprite A and sound $0E
; (here), $0D (start_dying_soldier_sound_0D) or $0B
; (start_dying_soldier_sprite); start_dying_soldier takes the sprite from
; data_05C79A by OBJ_FACING.
start_dying_soldier_sound_0E:
	sta	$00,x
	lda	#$000E
	bra	loc_01D1F7
start_dying_soldier_sound_0D:
	sta	$00,x
	lda	#$000D
loc_01D1F7:
	jsl	f:queue_sound
	bra	loc_01D20F
start_dying_soldier_sprite:
	sta	$00,x
	bra	loc_01D208
start_dying_soldier:
	ldy	$04,x
	lda	a:data_05C79A,y
	sta	$00,x
loc_01D208:
	lda	#$000B
	jsl	f:queue_sound
loc_01D20F:
	ldy	$04,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	stz	$20,x
	lda	#$0003
	sta	$16,x
	lda	a:data_05C79E,y
	sta	$1A,x
	lda	a:data_05C7A2,y
	sta	$18,x
	lda	#$FFFC
	sta	$1E,x
	lda	#$0000
	sta	$1C,x
	lda	#$0010
	sta	$24,x
	lda	#$0001
	sta	$12,x
	rtl
loc_01D23C:
	dec	$24,x
	bne	loc_01D25E
	lda	$0A,x
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	#$0010
	sta	$0E,x
	lda	#$FFFF
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rtl
loc_01D25E:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $19: plays an animation and deletes itself; never run in the
; CDL traces.
update_object_type_19:
	; (not executed in the CDL traces)
	lda	$12,x
	bne	loc_01D291
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$3E00
	sta	$02,x
	lda	#$0003
	sta	$16,x
	lda	#$C7A6
	sta	$20,x
	stz	$22,x
	lda	#$0001
	sta	$12,x
	rtl
loc_01D291:
	lda	$20,x
	bne	loc_01D29C
	lda	$16,x
	ora	#$8000
	sta	$16,x
loc_01D29C:
	rtl

; Object type $1A: explosion of a grenade (type $13): harmful for $20
; frames, spawns type $1D sparks.
update_grenade_blast:
	lda	$12,x
	bne	loc_01D2D8
; Turns the object into a grenade blast (type $1A, also entered from
; update_grenade).
start_grenade_blast:
	stz	$1A,x
	stz	$18,x
	lda	#$FFFE
	sta	$1E,x
	stz	$1C,x
	lda	$0E,x
	sta	$30,x
	stz	$04,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	#$3E00
	sta	$02,x
	lda	#$180F
	sta	$16,x
	lda	#.loword(anim_05C516)
	sta	$20,x
	stz	$22,x
	lda	#$0020
	sta	$24,x
	lda	#$0001
	sta	$12,x
	rtl
loc_01D2D8:
	lda	$24,x
	bne	loc_01D2E2
	lda	#$8000
	sta	$16,x
	rtl
loc_01D2E2:
	lda	$3C,x
	beq	loc_01D2ED
	stz	$3C,x
	lda	#$0003
	sta	$16,x
loc_01D2ED:
	lda	$00,x
	bne	loc_01D2FC
	lda	#.loword(anim_05C516)
	sta	$20,x
	stz	$22,x
	lda	$30,x
	sta	$0E,x
loc_01D2FC:
	lda	$20,x
	bne	loc_01D302
	; (not executed in the CDL traces)
	stz	$00,x
loc_01D302:
	dec	$24,x
	lda	$24,x
	bit	#$0007
	bne	loc_01D353
	jsl	f:find_free_slot_y
	bcs	loc_01D353
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0006,y
	lda	#$FFFE
	sta	a:$001E,y
	lda	rng_lo
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	rng_hi
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$30,x
	sta	a:$000E,y
	lda	#$1803
	sta	a:$0016,y
	lda	#.loword(anim_05C516)
	sta	a:$0020,y
	lda	#$0000
	sta	a:$0022,y
loc_01D353:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01D354:
	; (not executed in the CDL traces)
	lda	$26,x
	bne	loc_01D369
	lda	$14,x
	beq	loc_01D368
	lda	$02,x
	sta	$26,x
	and	#$3000
	ora	#$0200
	sta	$02,x
loc_01D368:
	rtl
loc_01D369:
	lda	$26,x
	sta	$02,x
	stz	$26,x
	rtl

; Object type $2F: stage 1 burning section: spawns type $30 (falling fire).
; Not identified exactly.
update_object_type_2F:
	lda	$12,x
	bne	loc_01D383
	lda	#$0004
	sta	$24,x
	lda	#$0001
	sta	$16,x
	inc	$12,x
	stz	$32,x
loc_01D382:
	rtl
loc_01D383:
	lda	$0A,x
	cmp	#$0120
	bcc	loc_01D395
	cmp	#$FF80
	bcs	loc_01D395
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	rtl
loc_01D395:
	lda	$32,x
	bne	loc_01D3B0
	dec	$24,x
	bne	loc_01D382
	ldy	difficulty
	lda	#$0024
	sta	$32,x
	lda	a:data_05C7E2,y
	sta	$24,x
	lda	#$0022
	jsl	f:queue_sound
loc_01D3B0:
	lda	stage_frame_mod4
	bne	loc_01D382
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	loc_01D382
	dec	$32,x
	lda	#$0030
	sta	a:$0010,y
	lda	#$8000
	sta	a:$0018,y
	lda	#$0002
	sta	a:$001A,y
	lda	#$FFF9
	sta	a:$001E,y
	bra	loc_01D446

; Object type $2B: stage 1 burning section. Not identified.
update_object_type_2B:
	lda	$12,x
	bne	loc_01D3FE
	lda	$3A,x
	sta	$24,x
	lda	#$0003
	sta	$16,x
	lda	#$FFFD
	sta	$1E,x
	lda	#.loword(metasprite_06AEA5)
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	inc	$12,x
	rtl
loc_01D3FE:
	clc
	lda	#$1900
	adc	$1C,x
	sta	$1C,x
	lda	#$0000
	adc	$1E,x
	sta	$1E,x
	lda	#$00C0
	cmp	$0E,x
	bcs	loc_01D42D
	sta	$0E,x
	lda	#$FFFD
	dec	$24,x
	bne	loc_01D42B
	lda	$3A,x
	sta	$24,x
	lda	#$0023
	jsl	f:queue_sound
	lda	#$FFFA
loc_01D42B:
	sta	$1E,x
loc_01D42D:
	lda	stage_frame_mod4
	bne	loc_01D46E
	ldy	#$08C0
	jsl	f:find_free_slot_y_down
	bcc	loc_01D46E
	lda	#$002E
	sta	a:$0010,y
	lda	#$0004
	sta	a:$001E,y
loc_01D446:
	lda	#$000D
	sta	a:$0016,y
	lda	#.loword(anim_05C7E8)
	sta	a:$0020,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4
	sta	a:$002A,y
loc_01D46E:
	rtl

; Object type $30: stage 1 burning section: falling fire. Not identified
; exactly.
update_object_type_30:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x

; Object type $2E: stage 1 burning section: fireball. Not identified
; exactly.
update_object_type_2E:
	lda	$0E,x
	cmp	#$00B8
	bcc	loc_01D4BE
	txa
	bit	#$0040
	bne	loc_01D491
	lda	#$8000
	sta	$16,x
	rtl
loc_01D491:
	lda	#$0001
	sta	$16,x
	lda	#.loword(anim_05C4CE)
	sta	$20,x
	lda	#OBJT_EFFECT
	sta	$10,x
	stz	$22,x
	lda	#$FFFE
	sta	$1E,x
	ldy	#$FFFF
	lda	rng_hi
	bpl	loc_01D4B1
	ldy	#$0000
loc_01D4B1:
	sty	zp_00
	lda	rng_lo
	sta	$18,x
	and	#$0001
	eor	zp_00
	sta	$1A,x
loc_01D4BE:
	rtl

; Object type $31: stage 1 burning section: flying fireball enemy, HP 64.
; Not identified exactly.
update_object_type_31:
	lda	$12,x
	bne	loc_01D4EF
	ldy	difficulty
	lda	$3A,x
	and	#$00FF
	sta	$32,x
	lda	$3B,x
	and	#$00FF
	ora	#$FF00
	sta	$34,x
	lda	#$0004
	sta	$24,x
	inc	$12,x
	lda	a:data_05C81C,y
	sta	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	brl	loc_01D591
loc_01D4EF:
	lda	$30,x
	bne	loc_01D52F
	lda	$20,x
	bne	loc_01D508
	stz	$22,x
	lda	#.loword(anim_05C59A)
	sta	$20,x
	lda	#$00B8
	sta	$0E,x
	lda	#$3000
	sta	$02,x
loc_01D508:
	dec	$24,x
	bne	loc_01D52E
	lda	#$001F
	sta	$16,x
	inc	$30,x
	lda	$32,x
	sta	$24,x
	lda	$34,x
	sta	$1E,x
	stz	$1C,x
	lda	#$00C0
	sta	$0E,x
	inc	$04,x
	lda	#.loword(anim_05C7E8)
	sta	$20,x
	lda	#$3E00
	sta	$02,x
loc_01D52E:
	rtl
loc_01D52F:
	lda	$06,x
	bpl	loc_01D53D
	stz	$04,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
loc_01D53D:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	stage_frame_mod4
	bne	loc_01D58A
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	loc_01D58A
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#$0002
	sta	a:$001E,y
	lda	#$0001
	sta	a:$0016,y
	lda	#.loword(anim_05C68A)
	sta	a:$0020,y
	lda	rng_lo
	and	#$000F
	sta	zp_00
	lda	$0A,x
	sbc	#$0005
	adc	zp_00
	sta	a:$000A,y
	lda	$0E,x
	adc	#$000C
	sta	a:$000E,y
loc_01D58A:
	lda	$0E,x
	cmp	#$00C4
	bcc	loc_01D5B0
loc_01D591:
	lda	#$0003
	sta	$16,x
	stz	$22,x
	lda	#.loword(anim_05C4CE)
	sta	$20,x
	stz	$30,x
	lda	#$FFFD
	sta	$1E,x
	lda	#$00C0
	sta	$0E,x
	stz	$04,x
	lda	#$3E00
	sta	$02,x
loc_01D5B0:
	rtl

; Object type $32: stage 1 section 10: fireballs. Not identified exactly.
update_object_type_32:
	lda	$06,x
	bmi	loc_01D5D0
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	$0E,x
	cmp	#$00CC
	bcc	loc_01D5E1
	lda	#$FFFE
	sta	$1E,x
loc_01D5D0:
	lda	#$0001
	sta	$16,x
	lda	#.loword(anim_05C59A)
	sta	$20,x
	lda	#OBJT_EFFECT
	sta	$10,x
	stz	$22,x
loc_01D5E1:
	rtl

; Object type $33: stage 1 section 10. Not identified.
update_object_type_33:
	lda	$16,x
	bne	loc_01D5F1
	lda	#$0003
	sta	$16,x
	lda	#$FFFF
	sta	$24,x
loc_01D5F0:
	rtl
loc_01D5F1:
	inc	$24,x
	lda	$0A,x
	cmp	#$0030
	bcs	loc_01D600
	lda	#$8000
	sta	$16,x
	rtl
loc_01D600:
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$FFFD
	lda	$24,x
	bit	#$0100
	bne	loc_01D625
	bit	#$00FF
	bne	loc_01D61C
	lda	#$0024
	jsl	f:queue_sound
loc_01D61C:
	lda	#$0004
	sta	a:shake_timer
	ldy	#$FFF9
loc_01D625:
	sty	$30,x
	lda	stage_frame_odd
	bne	loc_01D5F0
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	loc_01D5F0
	tya
	bit	#$0040
	beq	loc_01D64E
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	#.loword(anim_05C516)
	sta	a:$0020,y
	bra	loc_01D672
loc_01D64E:
	lda	#$0032
	sta	a:$0010,y
	lda	#.loword(anim_05C802)
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4
	sta	a:$002A,y
loc_01D672:
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	rng_lo
	and	#$0007
	sec
	adc	$30,x
	sta	a:$001E,y
	phx
	tyx
	ldy	#$FFFF
	lda	rng_hi
	bpl	loc_01D693
	ldy	#$0000
loc_01D693:
	sty	zp_00
	lda	rng_lo
	sta	$18,x
	and	#$0001
	eor	zp_00
	sta	$1A,x
	txy
	plx
	rtl

; Object type $2C: stage 1 burning section: fire pillar. Not identified
; exactly.
update_object_type_2C:
	lda	$12,x
	bne	loc_01D6C5
	ldy	difficulty
	sec
	lda	$3A,x
	sbc	a:data_05C822,y
	sta	$30,x
	sta	$24,x
	inc	$12,x
	lda	#$0003
	sta	$16,x
	lda	#$00C8
	sta	$0E,x
	lda	#$FFFD
	sta	$34,x
	rtl
loc_01D6C5:
	lda	$32,x
	beq	loc_01D6FE
	bmi	loc_01D6E6
	sec
	lda	$36,x
	sbc	#$C000
	sta	$36,x
	lda	$34,x
	sbc	#$0000
	sta	$34,x
	cmp	#$FFF0
	bcs	loc_01D712
	lda	#$FFFF
	sta	$32,x
	bra	loc_01D712
loc_01D6E6:
	clc
	lda	$36,x
	adc	#$4000
	sta	$36,x
	lda	$34,x
	adc	#$0000
	sta	$34,x
	cmp	#$FFFB
	bcc	loc_01D712
	stz	$32,x
	bra	loc_01D712
loc_01D6FE:
	dec	$24,x
	bne	loc_01D712
	lda	$30,x
	sta	$24,x
	lda	#$0001
	sta	$32,x
	lda	#$0021
	jsl	f:queue_sound
loc_01D712:
	lda	stage_frame_mod4
	bne	loc_01D752
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcs	loc_01D752
	lda	#$00D0
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$002D
	sta	a:$0010,y
	lda	#$180F
	sta	a:$0016,y
	lda	$34,x
	sta	a:$001E,y
	lda	$36,x
	sta	a:$001C,y
	lda	#.loword(anim_05C5B8)
	sta	a:$0020,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2
	sta	a:$002A,y
loc_01D752:
	rtl

; Object type $2D: stage 1 burning section: fire. Not identified exactly.
update_object_type_2D:
	clc
	lda	$1C,x
	adc	#$C000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	jml	f:update_effect

; Object type $34: stage 1 section 2. Not identified.
update_object_type_34:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_34_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_34_states:
	.addr	object_type_34_state_00
	.addr	object_type_34_state_01
	.addr	sub_01D7E2
	.addr	sub_01D7E2
	.addr	sub_01D831
	.addr	object_type_34_state_05

object_type_34_state_00:
	inc	$12,x
	lda	#$0003
	sta	$16,x
	sta	$38,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	rtl

object_type_34_state_01:
	lda	a:wram_0910
	cmp	#$0017
	bne	loc_01D7BA
	lda	a:wram_0906
	bpl	loc_01D7BB
	lda	#$001D
	jsl	f:queue_sound
	inc	$12,x
	lda	#$C848
	sta	$32,x
	lda	#$4418
	sta	$30,x
	lda	#$0060
	sta	$24,x
loc_01D7BA:
	rtl
loc_01D7BB:
	dec	$38,x
	bne	loc_01D7E1
	lda	zp_EB
	and	#$003F
	adc	#$0020
	sta	$38,x
	ldy	#$0700
	jsl	f:find_free_slot_y_down
	bcc	loc_01D7E1
	lda	$0A,x
	adc	#$0018
	sta	a:$000A,y
	phx
	tyx
	jsl	f:init_foot_soldier_running
	plx
loc_01D7E1:
	rtl

sub_01D7E2:
	lda	stage_frame_mod4
	cmp	#$0002
	bne	loc_01D809
	inc	$12,x
	lda	#$0030
	sta	zp_08
	lda	#$0002
	sta	zp_02
	ldy	$32,x
	lda	$30,x
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#$C854
	sta	$32,x
	lda	#$4000
	sta	$30,x
loc_01D809:
	rtl

object_type_34_state_05:
	lda	stage_frame_mod8
	bne	loc_01D830
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	$34,x
	sta	zp_04
	lda	$36,x
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C59A)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01D830
	lda	#$FFFE
	sta	a:$001E,y
loc_01D830:
	rtl

sub_01D831:
	lda	#$0003
	sta	a:shake_timer
	dec	$24,x
	bne	loc_01D83E
	inc	$12,x
	rtl
loc_01D83E:
	lda	$0A,x
	adc	#$FFF4
	sta	zp_00
	lda	$0E,x
	adc	#$FFF4
	sta	zp_02
	lda	$34,x
	sta	zp_04
	lda	$36,x
	sta	zp_06
	ldy	#$0300
	jsl	f:spawn_effect_random_offset
	bcs	loc_01D867
	lda	stage_frame_odd
	bne	loc_01D868
	lda	#.loword(anim_05C5EE)
	sta	a:$0020,y
loc_01D867:
	rtl
loc_01D868:
	phx
	lda	rng_lo
	and	#$000E
	tax
	lda	a:data_05C838,x
	sta	a:$0018,y
	lda	a:data_05C828,x
	sta	a:$001E,y
	lda	rng_hi
	adc	stage_frame_counter
	and	#$000E
	tax
	lda	a:data_05C838,x
	sta	a:$001C,y
	lda	a:data_05C828,x
	sta	a:$001A,y
	plx
	lda	zp_04
	lsr	a
	adc	$0A,x
	sta	a:$000A,y
	lda	zp_06
	lsr	a
	eor	#$FFFF
	adc	$0E,x
	sta	a:$000E,y
	lda	#.loword(anim_05C516)
	sta	a:$0020,y
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01D8AA:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10

; Object type $39: stage 3. Not identified.
update_object_type_39:
	lda	$12,x
	bne	loc_01D8C0
	inc	$12,x
	lda	#$0001
	sta	$16,x
	txa
	sta	$3E,x
	jsr	a:sub_01D932
	rtl
loc_01D8C0:
	stx	zp_FC
	lda	$0A,x
	cmp	#$0120
	bcc	loc_01D8CE
	cmp	#$FFE0
	bcc	loc_01D8DA
loc_01D8CE:
	lda	$0E,x
	cmp	#$0120
	bcc	loc_01D8DF
	cmp	#$FFE0
	bcs	loc_01D8DF
loc_01D8DA:
	lda	#$8000
	sta	$16,x
loc_01D8DF:
	jsr	a:sub_01D9C7
	ldy	#$0200
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	loc_01D8F4
	jsr	a:sub_01DA12
	jsr	a:sub_01DA72
loc_01D8F4:
	ldy	#$0240
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	loc_01D906
	jsr	a:sub_01DA12
	jsr	a:sub_01DA72
loc_01D906:
	rtl

; Object type $3A: stage 3. Not identified.
update_object_type_3A:
	ldy	$34,x
	lda	a:$0016,y
	bne	loc_01D916
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_01D916:
	jsr	a:sub_01D9D2
	ldy	#$0200
	jsl	f:sub_01DB1A
	bcs	loc_01D925
	jsr	a:sub_01DAC0
loc_01D925:
	ldy	#$0240
	jsl	f:sub_01DB1A
	bcs	loc_01D931
	jsr	a:sub_01DAC0
loc_01D931:
	rtl

sub_01D932:
	ldy	$3A,x
	lda	a:data_05C874,y
	sta	$38,x
	lda	a:data_05C860,y
	sta	zp_00
	sta	zp_02
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_0C
	clc
	adc	#$0008
	sta	$36,x
	lda	a:data_05C86A,y
	sta	$30,x
	sta	zp_04
	clc
	adc	#$0080
	and	#$00FF
	sta	zp_0A
	lda	#$0080
	sta	zp_06
	stx	zp_FC
	phx
loc_01D964:
	lda	#$0010
	sta	zp_08
loc_01D969:
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	loc_01D9C5
	lda	zp_FC
	sta	a:$0034,y
	lda	zp_06
	sta	a:$0038,y
	lda	#$0000
	sta	a:$003A,y
	lda	zp_08
	sta	a:$0032,y
	clc
	adc	#$0010
	and	#$00FF
	sta	zp_08
	lda	zp_0C
	sta	a:$0036,y
	lda	#$3F00
	sta	a:$0002,y
	lda	#$003A
	sta	a:$0010,y
	lda	#$0010
	sta	a:$0028,y
	lda	#$FFF0
	sta	a:$002A,y
	dec	zp_00
	bne	loc_01D969
	sec
	lda	zp_06
	sbc	#$0080
	sta	zp_06
	bmi	loc_01D9C5
	lda	zp_02
	sta	zp_00
	lda	zp_0A
	sta	zp_04
	bra	loc_01D964
loc_01D9C5:
	plx
	rts

sub_01D9C7:
	clc
	lda	$30,x
	adc	$38,x
	and	#$00FF
	sta	$30,x
	rts

sub_01D9D2:
	lda	$32,x
	cmp	$3A,x
	bcc	loc_01D9DA
	inc	$3A,x
loc_01D9DA:
	ldy	$34,x
	clc
	lda	a:$0030,y
	adc	$38,x
	and	#$00FF
	sta	zp_FE
	ldy	$3A,x
	jsl	f:polar_to_xy
	ldy	$34,x
	clc
	lda	a:$000A,y
	adc	zp_08
	sta	$0A,x
	clc
	lda	a:$000E,y
	adc	zp_0A
	sta	$0E,x
	lda	zp_FE
	clc
	adc	#$0008
	and	#$0070
	lsr	a
	lsr	a
	lsr	a
	tay
	lda	a:data_05C87E,y
	sta	$00,x
	rts

sub_01DA12:
	lda	$16,x
	bpl	loc_01DA19
	; (not executed in the CDL traces)
	brl	loc_01DA67
loc_01DA19:
	lda	$30,x
	lsr	a
	lsr	a
	sta	zp_02
	ldx	zp_FE
	lda	$30,x
	lsr	a
	lsr	a
	clc
	adc	zp_02
	sta	zp_02
	ldy	#$0000
	lda	$2E,x
	bne	loc_01DA6F
	lda	$22,x
	bit	#$0300
	beq	loc_01DA6F
	bit	#$0200
	beq	loc_01DA40
	ldy	#$0020
loc_01DA40:
	tya
	clc
	adc	zp_02
	and	#$003E
	tay
	ldx	zp_FE
	clc
	lda	$34,x
	adc	a:data_05C8CE,y
	sta	$34,x
	lda	$36,x
	adc	a:data_05C88E,y
	cmp	#$0008
	bcs	loc_01DA5F
	lda	#$0008
loc_01DA5F:
	sta	$36,x
	ldx	zp_FC
	cmp	$36,x
	bcc	loc_01DA6F
loc_01DA67:
	ldx	zp_FE
	jsl	f:start_player_drop
	stz	$3E,x
loc_01DA6F:
	ldx	zp_FC
	rts

sub_01DA72:
	ldy	zp_FE
	lda	a:$0016,y
	bmi	loc_01DA67
	beq	loc_01DA67
	lda	a:$003E,y
	cmp	$3E,x
	bne	loc_01DABF
	clc
	lda	$30,x
	adc	a:$0030,y
	and	#$00FF
	pha
	lda	a:$0036,y
	tay
	pla
	jsl	f:polar_to_xy
	ldy	zp_FE
	clc
	lda	$0A,x
	adc	zp_08
	clc
	adc	#$0006
	cmp	#$000A
	bcs	loc_01DAA8
	brl	loc_01DA67
loc_01DAA8:
	cmp	#$00F6
	bcc	loc_01DAB0
	; (not executed in the CDL traces)
	brl	loc_01DA67
loc_01DAB0:
	sta	a:$000A,y
	clc
	lda	$0E,x
	adc	zp_0A
	clc
	adc	#$0028
	sta	a:$000E,y
loc_01DABF:
	rts

sub_01DAC0:
	lda	#$0000
	sta	a:$001C,y
	sta	a:$001E,y
	lda	#$0010
	sta	a:$0012,y
	lda	$38,x
	sta	a:$0030,y
	phx
	lda	$34,x
	sta	a:$003E,y
	tax
	sec
	lda	a:$002A,y
	sbc	$0E,x
	bpl	loc_01DAE6
	eor	#$FFFF
loc_01DAE6:
	sta	zp_0A
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bpl	loc_01DAF3
	eor	#$FFFF
loc_01DAF3:
	sta	zp_08
	plx
	phy
	jsl	f:vector_length
	ply
	cmp	#$0008
	bcs	loc_01DB06
	lda	#$0008
	bra	loc_01DB10
loc_01DB06:
	cmp	$36,x
	bcc	loc_01DB10
	sec
	lda	$36,x
	sbc	#$0004
loc_01DB10:
	sta	a:$0036,y
	lda	#$0000
	sta	a:$0034,y
	rts

sub_01DB1A:
	lda	a:$0016,y
	beq	loc_01DB63
	bmi	loc_01DB63
	lda	a:$003E,y
	cmp	$34,x
	beq	loc_01DB63
	lda	a:$0032,y
	bit	#$0400
	bne	loc_01DB63
	lda	a:$0006,y
	sta	zp_00
	lda	a:$0028,y
	sta	zp_02
	lda	a:$002A,y
	sta	zp_04
	clc
	adc	#$FFF0
	sta	zp_06
	lda	zp_02
	cmp	$0A,x
	bmi	loc_01DB63
	lda	zp_06
	cmp	$0E,x
	bpl	loc_01DB63
	lda	$0A,x
	adc	$28,x
	cmp	zp_00
	bmi	loc_01DB63
	lda	$0E,x
	adc	$2A,x
	cmp	zp_04
	bpl	loc_01DB63
	clc
	rtl
loc_01DB63:
	sec
	rtl

; Object types $48 and $51: stage 3 (type $51: the flying machine with a
; searchlight, section 8). Not identified exactly.
update_object_type_48:
	lda	$06,x
	bpl	loc_01DB72
	stz	$06,x
	lda	#$C1CC
	jml	f:start_dying_soldier_sprite
loc_01DB72:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_48_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_48_states:
	.addr	sub_01DB8B
	.addr	object_type_48_state_01
	.addr	sub_01DC66
	.addr	sub_01DB8B
	.addr	sub_01DC66

sub_01DB8B:
	lda	#$001F
	sta	$16,x
	lda	#$3800
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	ldy	difficulty
	lda	a:object_type_48_hp,y
	sta	$06,x
	lda	$10,x
	cmp	#$0051
	bne	loc_01DBB0
	jmp	a:loc_01DC45
loc_01DBB0:
	jsl	f:snap_y_up_to_tile
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	jsr	a:sub_01DCA0
	stz	$1E,x
	stz	$1C,x
	stz	$0C,x
	stz	$08,x
	stz	$24,x
	stz	$04,x
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcs	loc_01DBD9
	lda	#$0002
	sta	$04,x
loc_01DBD9:
	lda	#.loword(anim_05C926)
	sta	$20,x
	stz	$22,x
	inc	$12,x
	rtl

object_type_48_state_01:
	lda	$24,x
	beq	loc_01DC1F
	lda	#$0004
	sta	zp_02
	lda	#$0008
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$0004
	bne	loc_01DBFF
	bit	#$2000
	beq	loc_01DC29
loc_01DBFF:
	ldy	$38,x
	lda	a:$000A,y
	clc
	adc	#$0018
	sec
	sbc	$0A,x
	cmp	#$0030
	bcs	loc_01DC1F
	lda	a:$000E,y
	clc
	adc	#$0008
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	loc_01DC29
loc_01DC1F:
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcs	loc_01DC29
	rtl
loc_01DC29:
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_01DC3B
	lda	#$8000
	sta	$18,x
	stz	$1A,x
	bra	loc_01DC45
loc_01DC3B:
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
loc_01DC45:
	lda	#$FFFC
	sta	$1E,x
	stz	$1C,x
	stz	$24,x
	stz	$0C,x
	stz	$08,x
	stz	$04,x
	lda	#.loword(anim_05C940)
	sta	$20,x
	stz	$22,x
	lda	$0A,x
	sta	$30,x
	lda	$0E,x
	sta	$32,x
	inc	$12,x
	rtl

sub_01DC66:
	lda	$32,x
	clc
	adc	#$0020
	cmp	$0E,x
	bcs	loc_01DC82
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0004
	bne	loc_01DC98
	bit	#$2000
	bne	loc_01DC98
loc_01DC82:
	lda	$1E,x
	bmi	loc_01DC8B
	cmp	#$0004
	bcs	loc_01DC97
loc_01DC8B:
	lda	$1C,x
	clc
	adc	#$4000
	sta	$1C,x
	bcc	loc_01DC97
	inc	$1E,x
loc_01DC97:
	rtl
loc_01DC98:
	lda	#$0000
	sta	$12,x
	jmp	a:loc_01DBB0

sub_01DCA0:
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_01DCBD
	ldy	difficulty
	lda	a:data_05C916,y
	and	#$FF00
	sta	$18,x
	lda	a:data_05C916,y
	and	#$00FF
	sta	$1A,x
	bra	loc_01DCCF
loc_01DCBD:
	ldy	difficulty
	lda	a:data_05C91E,y
	and	#$FF00
	sta	$18,x
	lda	a:data_05C91E,y
	ora	#$FF00
	sta	$1A,x
loc_01DCCF:
	rts

; Object type $49: stage 3 section 10: green shielded soldiers. Not
; identified exactly.
update_object_type_49:
	lda	$0E,x
	cmp	#$00E8
	bcc	loc_01DCDD
	lda	#$8000
	sta	$16,x
	rtl
loc_01DCDD:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_49_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_49_states:
	.addr	object_type_49_state_00
	.addr	object_type_49_state_01
	.addr	object_type_49_state_02

object_type_49_state_00:
	lda	#$0003
	sta	$16,x
	stz	$24,x
	stz	$30,x
	stz	$32,x
	inc	$12,x
	rtl

object_type_49_state_01:
	lda	stage_frame_counter
	and	#$001F
	bne	loc_01DD4F
	jsl	f:find_free_slot_y
	bcs	loc_01DD4F
	lda	#$0048
	sta	a:$0010,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0012,y
	lda	#$0200
	sta	a:$0038,y
	lda	rng_lo
	and	#$0001
	beq	loc_01DD3E
	lda	a:wram_0256
	bit	#$0001
	beq	loc_01DD3E
	; (not executed in the CDL traces)
	lda	#$0240
	sta	a:$0038,y
loc_01DD3E:
	inc	$32,x
	inc	$30,x
	ldy	difficulty
	lda	a:data_05C94E,y
	cmp	$30,x
	bcs	loc_01DD4F
	stz	$24,x
	inc	$12,x
loc_01DD4F:
	rtl

object_type_49_state_02:
	lda	$32,x
	cmp	#$0018
	bcs	loc_01DD68
	inc	$24,x
	ldy	difficulty
	lda	a:data_05C956,y
	cmp	$24,x
	bcs	loc_01DD68
	stz	$30,x
	stz	$24,x
	stz	$12,x
loc_01DD68:
	rtl

; Object type $4A: stage 3: rolling disc (HP 6; seen in the emulator).
update_rolling_mine:
	lda	$06,x
	bpl	loc_01DD81
	lda	#$0030
	jsl	f:queue_sound
	txy
	lda	#$FFFE
	sta	$1E,x
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_01DD81:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_rolling_mine_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_rolling_mine_states:
	.addr	rolling_mine_state_00
	.addr	rolling_mine_state_01
	.addr	rolling_mine_state_02
	.addr	rolling_mine_state_03
	.addr	rolling_mine_state_04
	.addr	rolling_mine_state_05

rolling_mine_state_00:
	ldy	difficulty
	lda	#$003F
	sta	$16,x
	lda	a:rolling_mine_hp,y
	sta	$06,x
	lda	#$3800
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE4
	sta	$2A,x
	ldy	$3A,x
	sty	$04,x
	lda	a:data_05C964,y
	sta	$18,x
	lda	a:data_05C968,y
	sta	$1A,x
	stz	$32,x
	lda	#.loword(anim_05C96C)
	sta	$20,x
	inc	$12,x
	rtl

rolling_mine_state_01:
	lda	$24,x
	bmi	loc_01DDD5
	dec	$24,x
loc_01DDD5:
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	loc_01DDE0
	inc	$12,x
	rtl
loc_01DDE0:
	lda	$24,x
	bpl	loc_01DE0C
	lda	$30,x
	bne	loc_01DDF5
	ldy	#$0200
	jsr	a:sub_01DED0
	ldy	#$0240
	jsr	a:sub_01DED0
	rtl
loc_01DDF5:
	lda	#$0003
	sta	$12,x
	stz	$20,x
	stz	$22,x
	stz	$1A,x
	stz	$18,x
	lda	#.loword(anim_05C986)
	sta	$20,x
	lda	#$401F
	sta	$16,x
loc_01DE0C:
	rtl

rolling_mine_state_02:
	lda	$1E,x
	bmi	loc_01DE16
	cmp	#$0005
	bcs	loc_01DE25
loc_01DE16:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01DE25:
	jsr	a:sub_01DEEF
	lda	$1E,x
	bmi	loc_01DE4E
	jsl	f:object_follow_floor
	lda	zp_FC
	beq	loc_01DE4E
	lda	$32,x
	bne	loc_01DE47
	lda	#$0020
	sta	$24,x
	inc	$32,x
	lda	#$FFFE
	sta	$1E,x
	stz	$1C,x
	rtl
loc_01DE47:
	stz	$32,x
	lda	#$0001
	sta	$12,x
loc_01DE4E:
	rtl

rolling_mine_state_03:
	lda	$20,x
	bne	loc_01DE5C
	lda	#$0040
	sta	$24,x
	stz	$30,x
	inc	$12,x
loc_01DE5C:
	rtl

rolling_mine_state_05:
	lda	$20,x
	bne	loc_01DE81
	lda	#$0080
	sta	$24,x
	ldy	$04,x
	lda	a:data_05C964,y
	sta	$18,x
	lda	a:data_05C968,y
	sta	$1A,x
	lda	#$003F
	sta	$16,x
	lda	#.loword(anim_05C96C)
	sta	$20,x
	lda	#$0001
	sta	$12,x
loc_01DE81:
	rtl

rolling_mine_state_04:
	lda	#$0800
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	and	#$003E
	sta	zp_FE
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:data_05C9C8,y
	sta	$00,x
	dec	$24,x
	lda	$24,x
	bmi	loc_01DEC5
	cmp	#$0010
	bne	loc_01DEC4
	clc
	lda	a:data_05C9D8,y
	adc	$0A,x
	sta	zp_00
	clc
	lda	a:data_05C9E8,y
	adc	$0E,x
	sta	zp_02
	lda	zp_FE
	jsl	f:spawn_enemy_bullet
loc_01DEC4:
	rtl
loc_01DEC5:
	lda	#.loword(anim_05C9B0)
	sta	$20,x
	lda	#$0005
	sta	$12,x
	rtl

sub_01DED0:
	lda	a:$0016,y
	beq	loc_01DEEE
	clc
	lda	$0A,x
	adc	#$0008
	sec
	sbc	a:$1312,y
	bpl	loc_01DEE4
	eor	#$FFFF
loc_01DEE4:
	cmp	#$0050
	bcs	loc_01DEEE
	lda	#$0001
	sta	$30,x
loc_01DEEE:
	rts

sub_01DEEF:
	lda	#$0010
	sta	zp_00
	lda	#$FFF0
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_01DF11
	lda	#$0002
	sta	$04,x
	lda	#$87FF
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
loc_01DF11:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_01DF28
	stz	$04,x
	lda	#$7800
	sta	$18,x
	lda	#$0001
	sta	$1A,x
loc_01DF28:
	rts

; Object type $4E: stage 3 section 7, 27 states (a mid-boss, probably). Not
; identified.
update_object_type_4E:
	lda	$06,x
	bpl	loc_01DF32
	lda	#$0018
	sta	$12,x
loc_01DF32:
	lda	$26,x
	beq	loc_01DF40
	lda	#.loword(palette_05916A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
loc_01DF40:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_4E_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_4E_states:
	.addr	object_type_4E_state_00
	.addr	object_type_4E_state_01
	.addr	object_type_4E_state_02
	.addr	object_type_4E_state_03
	.addr	object_type_4E_state_04
	.addr	object_type_4E_state_05
	.addr	object_type_4E_state_06
	.addr	object_type_4E_state_07
	.addr	object_type_4E_state_08
	.addr	object_type_4E_state_09
	.addr	object_type_4E_state_0A
	.addr	sub_01E0B8
	.addr	object_type_4E_state_0C
	.addr	object_type_4E_state_0D
	.addr	sub_01E0D1
	.addr	sub_01E1CC
	.addr	object_type_4E_state_10
	.addr	sub_01E0B8
	.addr	object_type_4E_state_12
	.addr	object_type_4E_state_13
	.addr	sub_01E0D1
	.addr	object_type_4E_state_15
	.addr	sub_01E1CC
	.addr	object_type_4E_state_17
	.addr	object_type_4E_state_18
	.addr	sub_01E0D1
	.addr	object_type_4E_state_1A
	; CDL: not accessed
	.byte	$6B

object_type_4E_state_00:
	lda	#$0000
	sta	$16,x
	lda	#$0006
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	stz	$38,x
	stz	$20,x
	stz	$00,x
	inc	$12,x
	rtl

object_type_4E_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bcc	loc_01DFBC
	inc	$12,x
loc_01DFBC:
	rtl

object_type_4E_state_04:
	stz	$36,x
	stz	$38,x
	inc	$12,x
	rtl

object_type_4E_state_05:
	lda	#$0008
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	$38,x
	asl	a
	tay
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	a:data_05CA02,y
	pha
	lda	$38,x
	asl	a
	tay
	lda	a:data_05C9F8,y
	tay
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$38,x
	lda	$38,x
	cmp	#$0005
	bcc	loc_01DFF9
	inc	$12,x
loc_01DFF9:
	rtl

object_type_4E_state_02:
	lda	#$0001
	sta	$16,x
	lda	#$FFFF
	sta	$1E,x
	stz	a:bg2_x
	stz	a:bg2_y
	inc	$12,x
	rtl

object_type_4E_state_03:
	jsr	a:sub_01E01E
	lda	$0E,x
	cmp	#$0020
	bcs	loc_01E01D
	stz	$16,x
	stz	$1E,x
	inc	$12,x
loc_01E01D:
	rtl

sub_01E01E:
	lda	$0A,x
	eor	#$FFFF
	inc	a
	clc
	adc	#$0080
	sta	a:bg2_x
	lda	$0E,x
	eor	#$FFFF
	inc	a
	clc
	adc	#$014E
	sta	a:bg2_y
	rts

object_type_4E_state_06:
	lda	#$0001
	sta	$16,x
	lda	#$0001
	sta	$1E,x
	inc	$12,x
	rtl

object_type_4E_state_07:
	jsr	a:sub_01E01E
	lda	$0E,x
	cmp	#$0043
	bcc	loc_01E056
	stz	$16,x
	stz	$1E,x
	inc	$12,x
loc_01E056:
	rtl

object_type_4E_state_08:
	phx
	ldx	#$0000
loc_01E05B:
	lda	a:data_05CA5C,x
	sta	f:$7EA000,x
	inx
	inx
	cpx	#$0008
	bcc	loc_01E05B
	lda	a:bg2_x
	sta	f:wram_7EA008
	ldx	#$0000
loc_01E073:
	sta	f:$7EA100,x
	inx
	inx
	cpx	#$0078
	bcc	loc_01E073
	plx
	inc	$12,x
	rtl

object_type_4E_state_09:
	lda	#$400D
	sta	$16,x
	ldy	difficulty
	lda	a:object_type_4E_hp,y
	sta	$06,x
	inc	$12,x
	stz	$24,x
	stz	$30,x
	stz	$32,x
	lda	#$0008
	sta	hdma_preset
	rtl

object_type_4E_state_0A:
	lda	#$006D
	sta	zp_06
	lda	$0A,x
	sta	zp_04
	lda	#$00B6
	sta	zp_02
	lda	$0A,x
	sta	zp_00
	phx
	jsr	a:sub_01E318
	plx
	stz	$30,x
	inc	$12,x
	rtl

sub_01E0B8:
	lda	#$0002
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#$CA6C
	lda	#$4D8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

sub_01E0D1:
	lda	#$0002
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#$CA78
	lda	#$4D8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

object_type_4E_state_0C:
	jsr	a:sub_01E0F0
	inc	$12,x
	rtl

sub_01E0F0:
	lda	#$0200
	sta	$34,x
	lda	a:wram_0216
	bit	#$0001
	beq	loc_01E104
	lda	rng_lo
	and	#$0001
	beq	loc_01E111
loc_01E104:
	lda	a:wram_0256
	bit	#$0001
	beq	loc_01E111
	; (not executed in the CDL traces)
	lda	#$0240
	sta	$34,x
loc_01E111:
	rts

object_type_4E_state_0D:
	jsr	a:sub_01E01E
	lda	a:bg2_x
	sta	f:wram_7EA008
	lda	stage_frame_counter
	and	#$000F
	bne	loc_01E16F
	jsl	f:find_free_slot_y
	bcs	loc_01E16F
	lda	stage_frame_counter
	and	#$0010
	bne	loc_01E137
	lda	#$0016
	jsl	f:queue_sound
loc_01E137:
	lda	#OBJT_GRENADE
	sta	a:$0010,y
	lda	rng_lo
	and	#$0001
	sta	a:$0004,y
	lda	rng_lo
	and	#$001F
	sbc	#$0013
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	lda	#$FFFD
	sta	a:$001E,y
	lda	#$0000
	sta	a:$001C,y
	sta	a:$0012,y
loc_01E16F:
	lda	$30,x
	inc	a
	and	#$007F
	sta	$30,x
	and	#$003F
	asl	a
	asl	a
	asl	a
	phx
	tax
	lda	f:data_058010,x
	plx
	lsr	a
	lsr	a
	xba
	and	#$003F
	sta	$32,x
	lda	$30,x
	bit	#$0040
	beq	loc_01E19B
	lda	$32,x
	eor	#$FFFF
	inc	a
	sta	$32,x
loc_01E19B:
	lda	#$006D
	sta	zp_06
	lda	$0A,x
	sta	zp_04
	lda	#$00B6
	sta	zp_02
	lda	$0A,x
	clc
	adc	$32,x
	sta	zp_00
	phx
	jsr	a:sub_01E318
	plx
	jsr	a:sub_01E3EA
	inc	$24,x
	lda	$24,x
	cmp	#$00F0
	bcc	loc_01E1CB
	stz	$30,x
	stz	$32,x
	stz	$24,x
	stz	$1A,x
	inc	$12,x
loc_01E1CB:
	rtl

sub_01E1CC:
	jsr	a:sub_01E01E
	lda	a:bg2_x
	sta	f:wram_7EA008
	stz	$1A,x
	stz	$18,x
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcc	loc_01E1E9
	stz	$24,x
	stz	$1A,x
	inc	$12,x
loc_01E1E9:
	rtl

object_type_4E_state_12:
	lda	$16,x
	ora	#$0010
	sta	$16,x
	stz	$08,x
	lda	$0A,x
	cmp	#$0080
	bcs	loc_01E1FF
	lda	#$0000
	bra	loc_01E202
loc_01E1FF:
	lda	#$FFFF
loc_01E202:
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#$CA88
	lda	#$4C8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

object_type_4E_state_13:
	inc	$24,x
	lda	$24,x
	cmp	#$0258
	bcc	loc_01E232
	stz	$24,x
	stz	$1A,x
	inc	$12,x
	rtl
loc_01E232:
	lda	stage_frame_counter
	and	#$001F
	bne	loc_01E29E
	jsl	f:find_free_slot_y
	bcs	loc_01E29E
	lda	#$0051
	sta	a:$0010,y
	lda	stage_frame_counter
	and	#$0020
	beq	loc_01E257
	lda	#$0000
	sta	a:$001A,y
	lda	#$0008
	bra	loc_01E260
loc_01E257:
	lda	#$FFFF
	sta	a:$001A,y
	lda	#$FFE8
loc_01E260:
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	#$8000
	sta	a:$0018,y
	lda	$0E,x
	sec
	sbc	#$0010
	sta	a:$000E,y
	lda	#$0003
	sta	a:$0012,y
	lda	#$0200
	sta	a:$0038,y
	lda	a:wram_0216
	bit	#$0001
	beq	loc_01E290
	lda	rng_lo
	and	#$0001
	beq	loc_01E29E
loc_01E290:
	lda	a:wram_0256
	bit	#$0001
	beq	loc_01E29E
	; (not executed in the CDL traces)
	lda	#$0240
	sta	a:$0038,y
loc_01E29E:
	jsr	a:sub_01E01E
	lda	a:bg2_x
	sta	f:wram_7EA008
	jsr	a:sub_01E3C5

sub_01E2AB:
	lda	#$006D
	sta	zp_06
	lda	$0A,x
	sta	zp_04
	lda	#$00B6
	sta	zp_02
	lda	$34,x
	tay
	lda	a:$0016,y
	bit	#$0001
	bne	loc_01E2D6
	jsr	a:sub_01E0F0
	lda	a:wram_0216
	ora	a:wram_0256
	and	#$0001
	bne	loc_01E2D6
	lda	zp_04
	bra	loc_01E2DC
loc_01E2D6:
	lda	$34,x
	tay
	lda	a:$000A,y
loc_01E2DC:
	sta	zp_00
	phx
	jsr	a:sub_01E318
	plx
	rtl

object_type_4E_state_10:
	jsr	a:sub_01E0F0
	jsl	f:sub_01E2AB
	inc	$12,x
	rtl

object_type_4E_state_15:
	lda	$16,x
	and	#$FFEF
	sta	$16,x
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#$CA95
	lda	#$4C8C
	phx
	jsl	f:queue_vram_blocks
	plx
	stz	$24,x
	stz	$36,x
	inc	$12,x
	rtl

object_type_4E_state_17:
	lda	#$000A
	sta	$12,x
	rtl

sub_01E318:
	lda	zp_02
	sec
	sbc	zp_06
	sta	zp_0A
	bpl	loc_01E324
	; (not executed in the CDL traces)
	jmp	a:loc_01E3AB
loc_01E324:
	lda	zp_00
	sec
	sbc	zp_04
	bcc	loc_01E334
	sta	zp_08
	lda	#$0000
	sta	zp_10
	bra	loc_01E33F
loc_01E334:
	eor	#$FFFF
	inc	a
	sta	zp_08
	lda	#$FFFF
	sta	zp_10
loc_01E33F:
	ldx	#$0000
	lda	zp_08
loc_01E344:
	sec
	sbc	zp_0A
	bcc	loc_01E358
	inx
	cmp	zp_0A
	bcc	loc_01E356
	cpx	#$0003
	bcc	loc_01E344
	; (not executed in the CDL traces)
	lda	#$0000
loc_01E356:
	sta	zp_08
loc_01E358:
	stx	zp_14
	lda	zp_04
	sta	zp_0C
	lda	zp_06
	sta	zp_0E
	stz	zp_12
	ldx	#$0000
loc_01E367:
	lda	zp_10
	bmi	loc_01E36F
	lda	zp_0C
	bra	loc_01E375
loc_01E36F:
	lda	zp_04
	asl	a
	sec
	sbc	zp_0C
loc_01E375:
	eor	#$FFFF
	inc	a
	clc
	adc	#$0080
	sta	f:$7EA100,x
	inx
	inx
	inc	zp_0E
	lda	zp_0E
	cmp	zp_02
	beq	loc_01E3AA
	lda	zp_12
	clc
	adc	zp_08
	sta	zp_12
	lda	zp_0C
	clc
	adc	zp_14
	sta	zp_0C
	lda	zp_12
	cmp	zp_0A
	bmi	loc_01E367
	inc	zp_0C
	lda	zp_12
	sec
	sbc	zp_0A
	sta	zp_12
	bra	loc_01E367
loc_01E3AA:
	clc
loc_01E3AB:
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_01E3AC:
	; (not executed in the CDL traces)
	phx
	eor	#$FFFF
	inc	a
	sta	zp_00
	tya
	sta	zp_04
	lda	#$0100
	sta	zp_02
	lda	#$0000
	sta	zp_06
	jsr	a:sub_01E318
	plx
	rtl

sub_01E3C5:
	lda	$0A,x
	cmp	#$00B0
	bcs	loc_01E427
	cmp	#$0050
	bcs	loc_01E3E7
	lda	#$8000
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	bra	loc_01E3E7

; (no caller found; decoded because it follows the end of a routine)
sub_01E3DD:
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
loc_01E3E7:
	jmp	a:loc_01E43E

sub_01E3EA:
	lda	$34,x
	tay
	lda	a:$0016,y
	bit	#$0001
	bne	loc_01E408
	jsr	a:sub_01E0F0
	lda	a:wram_0216
	ora	a:wram_0256
	and	#$0001
	bne	loc_01E408
	lda	#$0080
	bra	loc_01E40E
loc_01E408:
	lda	$34,x
	tay
	lda	a:$000A,y
loc_01E40E:
	cmp	$0A,x
	beq	loc_01E43A
	bmi	loc_01E427
	lda	$0A,x
	cmp	#$00B0
	bcs	loc_01E43A
	lda	#$8000
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	bra	loc_01E43E
loc_01E427:
	lda	$0A,x
	cmp	#$0050
	bcc	loc_01E43A
	lda	#$8000
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
	bra	loc_01E43E
loc_01E43A:
	stz	$18,x
	stz	$1A,x
loc_01E43E:
	lda	$0E,x
	and	#$FFFE
	sta	zp_00
	lda	stage_frame_counter
	and	#$0004
	lsr	a
	lsr	a
	ora	zp_00
	sta	$0E,x
	rts

object_type_4E_state_18:
	lda	#$0002
	sta	zp_02
	lda	#$0010
	sta	zp_08
	ldy	#$CA9D
	lda	#$4D0C
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#$0001
	sta	$16,x
	stz	hdma_preset
	stz	$06,x
	stz	$24,x
	stz	$30,x
	stz	$32,x
	stz	$0C,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1C,x
	lda	#$FFFE
	sta	$1E,x
	inc	$12,x
	lda	#$0030
	jsl	f:queue_sound
	rtl

object_type_4E_state_1A:
	jsr	a:sub_01E01E
	jsl	f:queue_sound_41_throttled
	lda	$0A,x
	adc	#$FFE0
	sta	zp_00
	lda	$0E,x
	adc	#$0010
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01E4C0
	lda	#$FFFD
	sta	a:$001E,y
loc_01E4C0:
	lda	#$0003
	sta	a:shake_timer
	lda	$1E,x
	bmi	loc_01E4CF
	cmp	#$0001
	bcs	loc_01E4DB
loc_01E4CF:
	lda	$1C,x
	clc
	adc	#$2000
	sta	$1C,x
	bcc	loc_01E4DB
	inc	$1E,x
loc_01E4DB:
	lda	$0E,x
	cmp	#$0140
	bcc	loc_01E4F2
	lda	#$8000
	sta	$16,x
	stz	$10,x
	stz	a:bg1_scroll_mode
	stz	a:bg2_scroll_mode
	stz	a:bg2_x
loc_01E4F2:
	rtl

; Object type $4F: stage 3: winged alien bug (HP 8; seen in the emulator).
update_stage3_winged_bug:
	inc	$32,x
	lda	a:wram_1688
	bne	loc_01E4FE
	lda	$06,x
	bpl	loc_01E52D
loc_01E4FE:
	lda	#$000C
	jsl	f:queue_sound
	ldy	#$0200
	jsr	a:sub_01E6DD
	ldy	#$0240
	jsr	a:sub_01E6DD
	lda	#$0004
	sta	$12,x
	stz	$22,x
	stz	$06,x
	lda	#$0003
	sta	$16,x
	stz	$1E,x
	stz	$1C,x
	lda	#.loword(anim_05CAB7)
	sta	$20,x
	lda	#$3400
	sta	$02,x
loc_01E52D:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage3_winged_bug_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage3_winged_bug_states:
	.addr	stage3_winged_bug_state_00
	.addr	stage3_winged_bug_state_01
	.addr	stage3_winged_bug_state_02
	.addr	stage3_winged_bug_state_03
	.addr	stage3_winged_bug_state_04

stage3_winged_bug_state_01:
	lda	$0E,x
	bmi	loc_01E557
	cmp	$30,x
	bcc	loc_01E557
	inc	$12,x
	lda	#.loword(anim_05CAA1)
	sta	$20,x
	stz	$22,x
loc_01E557:
	lda	$1E,x
	bmi	loc_01E560
	cmp	#$0002
	bcs	loc_01E56F
loc_01E560:
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01E56F:
	jsr	a:sub_01E5AE
	jsr	a:sub_01E63E
	jsr	a:sub_01E763
	rtl

stage3_winged_bug_state_02:
	clc
	lda	$30,x
	adc	#$FFF0
	cmp	$0E,x
	bcc	loc_01E58C
	dec	$12,x
	lda	#.loword(anim_05CAAF)
	sta	$20,x
	stz	$22,x
loc_01E58C:
	lda	$1E,x
	bpl	loc_01E595
	cmp	#$FFFF
	bcc	loc_01E5A4
loc_01E595:
	sec
	lda	$1C,x
	sbc	#$3000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
loc_01E5A4:
	jsr	a:sub_01E5AE
	jsr	a:sub_01E63E
	jsr	a:sub_01E763
	rtl

sub_01E5AE:
	lda	$32,x
	bit	#$001F
	bne	loc_01E5EA
	txa
	and	#$0040
	clc
	adc	#$0200
	tay
	lda	a:$0016,y
	bne	loc_01E5C8
	tya
	eor	#$0040
	tay
loc_01E5C8:
	lda	a:$000A,y
	cmp	$0A,x
	bmi	loc_01E5DA
	stz	$04,x
	lda	rng_hi
	adc	$0E,x
	sta	$18,x
	stz	$1A,x
	rts
loc_01E5DA:
	lda	#$0002
	sta	$04,x
	lda	rng_hi
	adc	$0E,x
	sta	$18,x
	lda	#$FFFF
	sta	$1A,x
loc_01E5EA:
	rts

stage3_winged_bug_state_03:
	jsr	a:sub_01E63E
	sec
	lda	$1C,x
	sbc	#$1000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rtl

stage3_winged_bug_state_04:
	lda	stage_frame_mod8
	bne	loc_01E629
	lda	$0A,x
	adc	#$FFFE
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$0007
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C672)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01E629
	lda	#$FFFC
	sta	a:$001E,y
loc_01E629:
	lda	rng_temp
	lsr	a
	sta	$04,x
	clc
	lda	$1C,x
	adc	#$1800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

sub_01E63E:
	ldy	#$0200
	jsr	a:sub_01E64B
	ldy	#$0240
	jsr	a:sub_01E64B
loc_01E64A:
	rts

sub_01E64B:
	lda	a:$0016,y
	beq	loc_01E64A
	bmi	loc_01E64A
	bit	#$0002
	bne	loc_01E64A
	txa
	cmp	a:$003E,y
	beq	loc_01E6A8
	lda	a:$003E,y
	bne	loc_01E6DC
	lda	$0A,x
	cmp	#$000C
	bcc	loc_01E6DC
	cmp	#$00E0
	bcs	loc_01E6DC
	adc	$28,x
	sta	zp_00
	lda	a:$1312,y
	cmp	$0A,x
	bcc	loc_01E6DC
	cmp	zp_00
	bcs	loc_01E6DC
	lda	$0E,x
	adc	#$FFF0
	sta	zp_00
	lda	a:$000E,y
	adc	#$FFE0
	sta	zp_02
	cmp	zp_00
	bcc	loc_01E6DC
	cmp	$0E,x
	bcs	loc_01E6DC
	stz	$1E,x
	lda	#$F000
	sta	$1C,x
	sta	$18,x
	stz	$1A,x
	lda	#$0003
	sta	$12,x
	txa
	sta	a:$003E,y
loc_01E6A8:
	lda	#$0000
	sta	a:$001A,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF
	sta	a:$001E,y
	lda	$0A,x
	cmp	#$000C
	bcc	loc_01E6E3
	cmp	#$00E0
	bcs	loc_01E6E3
	adc	#$0004
	sta	a:$000A,y
	lda	$0E,x
	bpl	loc_01E6D6
	lda	#$0004
	sta	a:$003C,y
loc_01E6D6:
	adc	#$001C
	sta	a:$000E,y
loc_01E6DC:
	rts

sub_01E6DD:
	txa
	cmp	a:$003E,y
	bne	loc_01E6EF
loc_01E6E3:
	lda	#$0000
	sta	a:$003E,y
	lda	#$FFFC
	sta	a:$001E,y
loc_01E6EF:
	rts

stage3_winged_bug_state_00:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:data_05CABF,y
	bne	loc_01E762
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	loc_01E762
	lda	#OBJT_STAGE3_WINGED_BUG
	sta	a:$0010,y
	lda	#$001B
	sta	a:$0016,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$001C
	sta	a:$0028,y
	lda	#$FFD8
	sta	a:$002A,y
	lda	#.loword(anim_05CAAF)
	sta	a:$0020,y
	lda	#$0000
	sta	a:$000E,y
	lda	rng_lo
	and	#$00FF
	clc
	adc	#$0020
	sta	a:$000A,y
	lda	#$0001
	sta	a:$0012,y
	lda	difficulty
	asl	a
	asl	a
	sta	a:$0006,y
	lda	rng_lo
	and	#$007F
	clc
	adc	#$0038
	sta	a:$0030,y
	lda	rng_lo
	and	#$00FF
	adc	#$0020
	sta	a:$0024,y
	lda	#$0003
	sta	a:$001E,y
loc_01E762:
	rtl

sub_01E763:
	dec	$24,x
	bpl	loc_01E771
	lda	#$0003
	sta	$12,x
	lda	#.loword(anim_05CAA1)
	sta	$20,x
loc_01E771:
	rts

; Object type $56: stage 6. Not identified.
update_object_type_56:
	lda	$06,x
	bpl	loc_01E782
	stz	$06,x
	lda	$04,x
	tay
	lda	a:data_05CB19,y
	jml	f:start_dying_soldier_sound_0E
loc_01E782:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_56_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_56_states:
	.addr	object_type_56_state_00
	.addr	object_type_56_state_01
	.addr	sub_01E822

object_type_56_state_00:
	ldy	difficulty
	lda	#$001F
	sta	$16,x
	lda	a:object_type_56_hp,y
	sta	$06,x
	lda	#$3400
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	jsr	a:sub_01E864
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_01E7C0
	stz	$04,x
	bra	loc_01E7C5
loc_01E7C0:
	lda	#$0002
	sta	$04,x
loc_01E7C5:
	lda	#.loword(anim_05CAF7)
	sta	$20,x
	stz	$22,x
	jsr	a:sub_01E7E0
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	inc	$12,x
	rtl

sub_01E7E0:
	lda	$04,x
	bne	loc_01E7F2
	ldy	difficulty
	lda	a:data_05CAD3
	sta	$18,x
	lda	a:data_05CADB
	sta	$1A,x
	bra	loc_01E7FE
loc_01E7F2:
	ldy	difficulty
	lda	a:data_05CAE3
	sta	$18,x
	lda	a:data_05CAEB
	sta	$1A,x
loc_01E7FE:
	rts

object_type_56_state_01:
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	loc_01E821
	lda	#$FFFD
	sta	$1E,x
	lda	$04,x
	tay
	lda	a:data_05CAF3,y
	sta	$1A,x
	stz	$1C,x
	stz	$18,x
	lda	#.loword(anim_05CB11)
	sta	$20,x
	stz	$22,x
	inc	$12,x
loc_01E821:
	rtl

sub_01E822:
	lda	$1E,x
	bmi	loc_01E82B
	cmp	#$0004
	bcs	loc_01E837
loc_01E82B:
	lda	$1C,x
	clc
	adc	#$4000
	sta	$1C,x
	bcc	loc_01E837
	inc	$1E,x
loc_01E837:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$807E
	beq	loc_01E85F
	jsr	a:sub_01E7E0
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	jsl	f:snap_y_up_to_tile
	lda	#.loword(anim_05CAF7)
	sta	$20,x
	stz	$22,x
	lda	#$0001
	sta	$12,x
loc_01E85F:
	rtl

sub_01E860:
	jsr	a:sub_01E864
	rtl

sub_01E864:
	lda	#$0200
	tay
	lda	a:wram_0216
	bit	#$0001
	beq	loc_01E877
	lda	rng_lo
	and	#$0001
	beq	loc_01E883
loc_01E877:
	lda	a:wram_0256
	bit	#$0001
	beq	loc_01E883
	lda	#$0240
	tay
loc_01E883:
	rts

; Object type $5C: stage 6 (the bone arch). Not identified.
update_object_type_5C:
	lda	$12,x
	bne	loc_01E89A
	lda	#$0003
	sta	$16,x
	lda	#$0010
	sta	$30,x
	lda	#$0078
	sta	$32,x
	inc	$12,x
	rtl
loc_01E89A:
	dec	$30,x
	lda	$30,x
	bne	loc_01E8A3
	jsr	a:sub_01E8AD
loc_01E8A3:
	dec	$32,x
	lda	$32,x
	bne	loc_01E8AC
	jsr	a:sub_01E8F9
loc_01E8AC:
	rtl

sub_01E8AD:
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:data_05CB1D,y
	sta	$30,x
	ldy	#$0900
loc_01E8BC:
	lda	a:$0016,y
	bit	#$0040
	beq	loc_01E8CF
	; (not executed in the CDL traces)
	lda	a:$000A,y
	adc	a:$0028,y
	cmp	#$00F8
	bcs	loc_01E8F8
loc_01E8CF:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	loc_01E8BC
	jsl	f:find_free_slot_y
	bcs	loc_01E8F8
	lda	#$00FF
	sta	a:$000A,y
	jsr	a:sub_01E916
loc_01E8E9:
	lda	#$0056
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
loc_01E8F8:
	rts

sub_01E8F9:
	ldy	difficulty
	lda	rng_lo
	and	#$00FF
	adc	a:data_05CB23,y
	sta	$32,x
	jsl	f:find_free_slot_y
	bcs	loc_01E8F8
	lda	#$0000
	sta	a:$000A,y
	jsr	a:sub_01E916
	bra	loc_01E8E9

sub_01E916:
	lda	#$0078
	sta	zp_05
	phx
	tyx
loc_01E91D:
	lda	zp_05
	sta	$0E,x
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$807E
	bne	loc_01E93D
	lda	zp_05
	clc
	adc	#$0004
	sta	zp_05
	cmp	#$00BC
	bcc	loc_01E91D
	bcs	loc_01E940
loc_01E93D:
	txy
	plx
	rts
loc_01E940:
	txy
	plx
	lda	rng_lo
	and	#$001F
	clc
	adc	#$0050
	sta	a:$000E,y
	rts

; Object type $24: stage 6 alien soldier (seen in the emulator).
update_object_type_24:
	lda	$06,x
	bpl	loc_01E95F
	stz	$06,x
	lda	$04,x
	tay
	lda	a:data_05CB19,y
	jml	f:start_dying_soldier_sound_0E
loc_01E95F:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_24_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_24_states:
	.addr	object_type_24_state_00
	.addr	object_type_24_state_01
	.addr	sub_01E822

object_type_24_state_00:
	ldy	difficulty
	lda	#$001F
	sta	$16,x
	lda	a:object_type_56_hp,y
	sta	$06,x
	lda	#$2400
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	jsr	a:sub_01E864
	lda	a:$000A,y
	cmp	$0A,x
	bcc	loc_01E99D
	stz	$04,x
	bra	loc_01E9A2
loc_01E99D:
	lda	#$0002
	sta	$04,x
loc_01E9A2:
	lda	#.loword(anim_05CAF7)
	sta	$20,x
	stz	$22,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	inc	$12,x
	rtl

object_type_24_state_01:
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	loc_01E9D7
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#.loword(anim_05CB11)
	sta	$20,x
	stz	$22,x
	inc	$12,x
loc_01E9D7:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01E9D8:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10

; Object type $3D: stage 3 mid-boss: the spiked machine climbing the girder
; (HP 160; seen in the emulator).
update_stage3_spiked_climber:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage3_spiked_climber_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage3_spiked_climber_states:
	.addr	stage3_spiked_climber_state_00
	.addr	stage3_spiked_climber_state_01
	.addr	stage3_spiked_climber_state_02
	.addr	stage3_spiked_climber_state_03
	.addr	stage3_spiked_climber_state_04
	.addr	stage3_spiked_climber_state_05
	.addr	stage3_spiked_climber_state_06
	.addr	stage3_spiked_climber_state_07
	.addr	update_object_type_59
	.addr	stage3_spiked_climber_state_09
	.addr	stage3_spiked_climber_state_0A
	.addr	update_object_type_52
	.addr	stage3_spiked_climber_state_0C
	.addr	stage3_spiked_climber_state_0D
	.addr	stage3_spiked_climber_state_0E
	.addr	stage3_spiked_climber_state_0F
	.addr	stage3_spiked_climber_state_10
	.addr	stage3_spiked_climber_state_11
	.addr	stage3_spiked_climber_state_12
	.addr	stage3_spiked_climber_state_13

stage3_spiked_climber_state_01:
	inc	$12,x
	lda	#$0060
	sta	$24,x
	lda	#$0002
	sta	a:wram_1688
	rtl

stage3_spiked_climber_state_02:
	dec	$24,x
	bpl	loc_01EA35
	inc	$12,x
	lda	#$0060
	sta	$24,x
	phx
	ldx	#.loword(data_059E95)
	jsl	f:load_data_list
	plx
loc_01EA35:
	rtl

stage3_spiked_climber_state_00:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	loc_01EA58
	inc	$12,x
	lda	#$FFF8
	sta	a:wram_1636
	lda	#$0200
	sta	a:wram_163A
	stz	a:wram_163E
	stz	a:wram_1640
	stz	a:stage1_boss_head_pos
	stz	a:wram_1642
loc_01EA58:
	rtl

stage3_spiked_climber_state_03:
	dec	$24,x
	bpl	loc_01EA58
	lda	#$0108
	sta	$0E,x
	lda	#$0078
	sta	$0A,x
	lda	#$0001
	sta	$16,x
	inc	$12,x
	lda	#$0008
	sta	$3A,x
	lda	#$FFFE
	sta	$1E,x
	txa
	sta	$3E,x
	phx
	ldx	#$0340
	ldy	#$0000
	jsr	a:sub_01EBCE
	ldx	#$0380
	ldy	#$0002
	lda	#$FFFE
	sta	$24,x
	jsr	a:sub_01EBCE
	ldx	#$0300
	ldy	#$0004
	jsr	a:sub_01EBCE
	lda	#$4010
	sta	$16,x
	ldy	difficulty
	lda	a:stage3_spiked_climber_core_hp,y
	sta	$06,x
	lda	#$FFF8
	sta	$2A,x
	plx
	jsr	a:sub_01D932
	rtl

stage3_spiked_climber_state_04:
	lda	$0E,x
	cmp	#$0080
	bcs	stage3_spiked_climber_state_05
	inc	$12,x
	stz	$1E,x

stage3_spiked_climber_state_05:
	lda	a:wram_1642
	beq	loc_01EAC9
	jsr	a:sub_01ECED
	lda	$16,x
	beq	loc_01EB2E
loc_01EAC9:
	stx	zp_FC
	jsr	a:sub_01ECAA
	jsr	a:sub_01EBF4
	lda	a:wram_1642
	beq	loc_01EADD
	lda	#$0003
	sta	$38,x
	bra	loc_01EB07
loc_01EADD:
	lda	a:stage1_boss_head_pos
	beq	loc_01EAE7
	dec	a:stage1_boss_head_pos
	bra	loc_01EB0A
loc_01EAE7:
	dec	a:wram_163A
	bpl	loc_01EB07
	lda	#$0040
	sta	a:stage1_boss_head_pos
	ldy	difficulty
	lda	rng_lo
	and	#$00FF
	adc	a:data_05CB43,y
	sta	a:wram_163A
	lda	$38,x
	eor	#$FFFF
	inc	a
	sta	$38,x
loc_01EB07:
	jsr	a:sub_01D9C7
loc_01EB0A:
	ldy	#$0200
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	loc_01EB1C
	jsr	a:sub_01DA12
	jsr	a:sub_01DA72
loc_01EB1C:
	ldy	#$0240
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	loc_01EB2E
	jsr	a:sub_01DA12
	jsr	a:sub_01DA72
loc_01EB2E:
	rtl

stage3_spiked_climber_state_06:
	lda	a:bg1_y
	bpl	loc_01EB54
	cmp	#$FF58
	bcs	loc_01EB54
	inc	$12,x
	lda	#$0002
	sta	a:wram_1672
	lda	#$0001
	sta	a:wram_0356
	lda	#$FFFB
	sta	a:wram_035E
	lda	#$0048
	jsl	f:queue_sound
loc_01EB54:
	rtl

stage3_spiked_climber_state_07:
	lda	a:wram_035E
	bne	loc_01EB69
	inc	$12,x
	stz	a:wram_035C
	stz	a:wram_035E
	stz	a:wram_0358
	stz	a:wram_035A
	rtl
loc_01EB69:
	clc
	lda	a:wram_035C
	adc	#$1000
	sta	a:wram_035C
	lda	a:wram_035E
	adc	#$0000
	sta	a:wram_035E
	clc
	lda	a:wram_0358
	adc	#$EC00
	sta	a:wram_0358
	lda	a:wram_035A
	adc	#$FFFF
	sta	a:wram_035A
	rtl

; Object type $3E: does nothing (rtl); stage 3 spiked climber's arm.
update_object_type_3E:
	rtl

; Object type $40: stage 3 spiked climber, its weak point (HP 80).
update_stage3_spiked_climber_core:
	lda	a:wram_1642
	bne	loc_01EBAD
	lda	$06,x
	bpl	loc_01EBAD
	inc	a:wram_1642
	lda	#$0030
	sta	a:wram_0396
	sta	a:wram_0356
	lda	#$0019
	jsl	f:queue_sound
loc_01EBAD:
	ldy	#$3E00
	lda	$26,x
	beq	loc_01EBB7
	ldy	#$3200
loc_01EBB7:
	sty	a:wram_0342
	sty	a:wram_0382
	rtl

; Object type $3F: stage 3 spiked climber, spike arm.
update_object_type_3F:
	ldy	#$B8B6
	lda	stage_frame_bit1
	bne	loc_01EBC8
	ldy	#$B8C3
loc_01EBC8:
	sty	$00,x
	jsr	a:sub_01EC51
	rtl

sub_01EBCE:
	lda	a:data_05CB3D,y
	sta	$00,x
	lda	a:data_05CB31,y
	sta	$10,x
	lda	#$003C
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	lda	a:data_05CB37,y
	sta	$28,x
	lda	#$FFDC
	sta	$2A,x
	lda	#$0180
	sta	$0A,x
	sta	$0E,x
	rts

sub_01EBF4:
	clc
	lda	$0A,x
	adc	#$0004
	sta	a:wram_030A
	clc
	adc	#$FFF4
	sta	a:wram_034A
	clc
	adc	#$000C
	sta	a:wram_038A
	lda	stage_frame_counter
	and	#$001F
	lsr	a
	lsr	a
	sta	zp_00
	lda	stage_frame_counter
	bit	#$0020
	beq	loc_01EC25
	lda	zp_00
	eor	#$FFFF
	and	#$0007
	sta	zp_00
loc_01EC25:
	lda	zp_00
	lsr	a
	eor	#$FFFF
	and	#$0003
	sta	zp_02
	clc
	lda	$0E,x
	adc	zp_02
	lda	$0E,x
	clc
	adc	#$0008
	adc	zp_00
	sta	a:wram_034E
	dec	a
	dec	a
	sta	a:wram_030E
	inc	a
	inc	a
	clc
	adc	zp_02
	adc	a:wram_1636
	sta	a:wram_038E
	rts

sub_01EC51:
	lda	a:wram_1642
	bne	loc_01EC63
	inc	$24,x
	lda	difficulty
	beq	loc_01EC63
	lda	$24,x
	bit	#$0300
	beq	loc_01EC8B
loc_01EC63:
	and	#$03FF
	cmp	#$0100
	bne	loc_01EC72
	lda	#$0019
	jsl	f:queue_sound
loc_01EC72:
	lda	a:wram_1636
	cmp	#$FFF8
	bcs	loc_01ECA9
	clc
	lda	a:wram_1636
	adc	#$0004
	cmp	#$FFF8
	bcc	loc_01ECA6
	lda	#$FFF8
	bra	loc_01ECA6
loc_01EC8B:
	and	#$00FF
	bne	loc_01EC97
	lda	#$0018
	jsl	f:queue_sound
loc_01EC97:
	lda	a:wram_1636
	cmp	#$FFD4
	bcc	loc_01ECA9
	clc
	lda	a:wram_1636
	adc	#$FFFF
loc_01ECA6:
	sta	a:wram_1636
loc_01ECA9:
	rts

sub_01ECAA:
	ldy	a:wram_163E
	bne	loc_01ECC1
	lda	$0A,x
	cmp	#$0088
	bcs	loc_01ECD3
	lda	$1A,x
	bmi	loc_01ECDD
	cmp	#$0001
	bcs	loc_01ECEC
	bcc	loc_01ECDD
loc_01ECC1:
	lda	$0A,x
	cmp	#$0068
	bcc	loc_01ECD3
	lda	$1A,x
	bpl	loc_01ECDD
	cmp	#$FFFF
	bcc	loc_01ECEC
	bcs	loc_01ECDD
loc_01ECD3:
	lda	a:wram_163E
	eor	#$0002
	sta	a:wram_163E
	rts
loc_01ECDD:
	clc
	lda	$18,x
	adc	a:data_05CB29,y
	sta	$18,x
	lda	$1A,x
	adc	a:data_05CB2D,y
	sta	$1A,x
loc_01ECEC:
	rts

sub_01ECED:
	lda	$0E,x
	cmp	#$0100
	bcc	loc_01ED3E
	lda	#$8000
	sta	a:wram_0316
	sta	a:wram_0396
	inc	$12,x
	stz	$16,x
	stz	a:wram_0340
	lda	#$0001
	sta	a:bg1_autoscroll
	sta	a:wram_1666
	lda	#$0002
	sta	a:bg1_scroll_mode
	sta	a:bg1_autoscroll_speed
	lda	#$0007
	sta	a:bg2_scroll_mode
	lda	#$CB49
	sta	a:wram_0360
	stz	a:wram_0356
	lda	#$0080
	sta	a:wram_034A
	lda	#$0130
	sta	a:wram_034E
	stz	a:wram_0358
	stz	a:wram_035A
	stz	a:wram_035C
	stz	a:wram_035E
	rts
loc_01ED3E:
	clc
	lda	$1C,x
	adc	#$0100
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	jsl	f:queue_sound_30_throttled
	lda	$0A,x
	adc	#$FFF0
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$001F
	sta	zp_04
	sta	zp_06
	ldy	#$03C0
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01ED75
	lda	#$FFFA
	sta	a:$001E,y
loc_01ED75:
	rts

; Object type $59: not seen. Not identified.
update_object_type_59:
	lda	#$004E
	sta	$24,x
	inc	$12,x
	stz	zp_04
	stx	zp_FC
	ldx	#$03C0
loc_01ED84:
	lda	#$005A
	sta	$10,x
	lda	#.loword(anim_05CC0B)
	sta	$20,x
	lda	#$3E00
	sta	$02,x
	lda	#$003D
	sta	$16,x
	lda	#$FFF4
	sta	$2A,x
	lda	#$000C
	sta	$28,x
	lda	zp_04
	sta	$38,x
	inc	zp_04
	inc	zp_04
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0640
	bcc	loc_01ED84
	lda	#$B9EA
	sta	a:wram_03C0
	sta	a:wram_0600
	stz	a:wram_03E0
	stz	a:wram_0620
	ldx	#$0340
	lda	zp_04
	sta	$38,x
	lda	#$005A
	sta	$10,x
	lda	#$FF80
	sta	$0A,x
	lda	#$0080
	sta	$0E,x
	lda	#.loword(anim_05CC95)
	sta	$20,x
	lda	#$003D
	sta	$16,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	stz	a:wram_1636
	stz	a:stage1_boss_head_pos
	stz	a:wram_163A
	ldx	zp_FC
	stz	$30,x
	stz	$32,x
	stz	$24,x
	rtl

stage3_spiked_climber_state_09:
	lda	a:wram_034A
	bmi	loc_01EE22
	cmp	#$007C
	bcc	loc_01EE22
	lda	#$0049
	jsl	f:queue_sound
	lda	#$007C
	sta	a:wram_034A
	lda	#$0003
	sta	a:shake_timer
	stz	a:wram_0358
	stz	a:wram_035A
	inc	$12,x
	rtl
loc_01EE22:
	clc
	lda	a:wram_0358
	adc	#$2000
	sta	a:wram_0358
	lda	a:wram_035A
	adc	#$0000
	sta	a:wram_035A
	rtl

stage3_spiked_climber_state_0A:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	loc_01EE44
	inc	$12,x
	inc	a:wram_1636
	rtl
loc_01EE44:
	lda	stage_frame_counter
	bit	#$0002
	beq	loc_01EE50
	lda	#$0001
	bra	loc_01EE53
loc_01EE50:
	lda	#$FFFF
loc_01EE53:
	clc
	adc	a:wram_034A
	sta	a:wram_034A
	lda	$24,x
	beq	loc_01EE7D
	dec	$24,x
	lda	a:stage1_boss_head_pos
	beq	loc_01EE7C
	ldy	$36,x
	lda	a:data_05CB99,y
	tay
	lda	$30,x
	sta	a:$0030,y
	lda	$32,x
	sta	a:$0032,y
	inc	$36,x
	inc	$36,x
	dec	a:stage1_boss_head_pos
loc_01EE7C:
	rtl
loc_01EE7D:
	lda	#$0001
	sta	a:wram_1636
	ldy	a:wram_163A
	lda	a:wram_034E
	bmi	loc_01EE7C
	cmp	a:data_05CB7B,y
	bcc	loc_01EE7C
	phx
	ldx	#$0340
	lda	#$FFFF
	sta	zp_FE
	lda	#$FFFE
	sta	zp_FC
	jsr	a:sub_01F3BD
	lda	#$0001
	sta	zp_FE
	jsr	a:sub_01F3BD
	plx
	phx
	inc	a:wram_163A
	inc	a:wram_163A
	stz	$36,x
	lda	#$000A
	sta	zp_02
	inc	a
	sta	a:stage1_boss_head_pos
	lda	$30,x
	eor	#$0016
	sta	$30,x
	sta	a:wram_03F0
	lda	$32,x
	eor	#$0002
	sta	$32,x
	sta	a:wram_03F2
	bne	loc_01EEDA
	lda	#$0040
	ldx	#$03C0
	bra	loc_01EEE0
loc_01EEDA:
	lda	#$FFC0
	ldx	#$0600
loc_01EEE0:
	sta	zp_00
	ldy	#$0000
loc_01EEE5:
	lda	#$004F
	sta	$24,x
	lda	a:data_05CC41,y
	sta	$18,x
	lda	a:data_05CC55,y
	sta	$1A,x
	lda	a:data_05CC19,y
	sta	$3A,x
	lda	a:data_05CC2D,y
	sta	$3E,x
	txa
	clc
	adc	zp_00
	tax
	iny
	iny
	dec	zp_02
	bne	loc_01EEE5
	ldx	#$0340
	lda	#$004F
	sta	$24,x
	lda	#$C7FF
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$0800
	sta	$3A,x
	lda	#$0000
	sta	$3E,x
	plx
	lda	#$005F
	sta	$24,x
	rtl

; Object type $60: does nothing (rtl); never run in the CDL traces.
update_object_type_60:
	; (not executed in the CDL traces)
	rtl

; Object type $5A: stage 3 spiked climber, spikes. Not identified exactly.
update_object_type_5A:
	lda	a:wram_1636
	phx
	asl	a
	tax
	lda	f:tbl_object_type_5A_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_5A_states:
	.addr	object_type_5A_state_00
	.addr	object_type_5A_state_01
	.addr	object_type_5A_state_02

object_type_5A_state_00:
	ldy	$38,x
	clc
	lda	a:wram_034A
	adc	a:data_05CBAF,y
	sta	$0A,x
	clc
	lda	a:wram_034E
	adc	a:data_05CBC5,y
	sta	$0E,x

object_type_5A_state_01:
	ldy	$32,x
	lda	a:data_05CBDB,y
	sta	zp_00
	clc
	lda	$38,x
	adc	$30,x
	tay
	sec
	lda	(zp_00)
	sbc	$0E,x
	sec
	sbc	a:data_05CBDF,y
	beq	loc_01EF77
	bpl	loc_01EF75
	dec	$0E,x
	bra	loc_01EF77
loc_01EF75:
	inc	$0E,x
loc_01EF77:
	lda	$24,x
	beq	loc_01EF9E
	dec	$24,x
	bne	loc_01EF9E
	cpx	#$03C0
	beq	loc_01EF89
	cpx	#$0600
	bne	loc_01EF96
loc_01EF89:
	lda	#$0002
	sta	a:shake_timer
	lda	#$0049
	jsl	f:queue_sound
loc_01EF96:
	stz	$18,x
	stz	$1A,x
	stz	$3A,x
	stz	$3E,x
loc_01EF9E:
	ldy	$38,x
	clc
	lda	$18,x
	adc	$3A,x
	sta	$18,x
	lda	$1A,x
	adc	$3E,x
	sta	$1A,x
	rtl

object_type_5A_state_02:
	lda	a:wram_060A
	cmp	$0A,x
	bcs	loc_01EFB7
	sta	$0A,x
loc_01EFB7:
	rtl

; Object type $52: not seen. Not identified.
update_object_type_52:
	lda	a:bg1_x
	eor	#$FFFF
	and	#$0100
	asl	a
	asl	a
	sta	$30,x
	clc
	adc	#$4000
	ldy	#$CCA3
	jsr	a:sub_01F2B0
	inc	$12,x
	stz	a:wram_1640
	lda	#$0040
	sta	a:wram_1642
	lda	#$0003
	sta	$32,x
	rtl

stage3_spiked_climber_state_0C:
	inc	$12,x
	clc
	lda	$30,x
	adc	#$4280
	ldy	#$CCBB
	jsr	a:sub_01F2B0
	rtl

stage3_spiked_climber_state_0D:
	lda	#$00F0
	sta	a:wram_03E8
	sta	a:wram_0628
	lda	#$FFE2
	sta	a:wram_03EA
	sta	a:wram_062A
	jsr	a:sub_01F2C3
	inc	$12,x
	clc
	lda	$30,x
	adc	#$4300
	ldy	#$CCAF
	jsr	a:sub_01F2B0
	lda	#$0003
	sta	a:shake_timer
	lda	#$0020
	sta	$24,x
	lda	#$004A
	jsl	f:queue_sound
	rtl

stage3_spiked_climber_state_0E:
	jsr	a:sub_01F3E3
	lda	#$0001
	sta	a:shake_continuous
	lda	f:wram_7E3821
	cmp	#$00A0
	bcc	loc_01F039
	inc	$12,x
loc_01F039:
	inc	a
	inc	a
	sta	f:wram_7E3821
	sta	f:wram_7E382A
	lda	a:wram_03CA
	dec	a
	dec	a
	sta	a:wram_03CA
	sta	a:wram_060A
	rtl

stage3_spiked_climber_state_0F:
	jsr	a:sub_01F3E3
	lda	#$0003
	sta	a:shake_timer
	lda	#$8000
	sta	a:wram_0416
	sta	a:wram_0456
	sta	a:wram_0496
	sta	a:wram_04D6
	sta	a:wram_0516
	sta	a:wram_0556
	sta	a:wram_0596
	sta	a:wram_05D6
	sta	$16,x
	stz	a:wram_03D6
	stz	a:wram_0616
	inc	$12,x
	phx
	lda	$10,x
	sta	a:wram_0350
	lda	$12,x
	sta	a:wram_0352
	ldy	#$0002
	ldx	#$0400
	jsr	a:sub_01F360
	ldx	#$0440
	jsr	a:sub_01F360
	lda	#$006C
	sta	$0E,x
	ldy	#$0004
	ldx	#$0380
	jsr	a:sub_01F360
	lda	#$0002
	sta	$04,x
	ldy	#$0000
	ldx	#$0340
	jsr	a:sub_01F36F
	lda	#.loword(anim_05CCDD)
	sta	$20,x
	lda	#$401D
	sta	$16,x
	ldy	difficulty
	lda	a:stage3_spiked_climber_hp,y
	sta	$06,x
	jsr	a:sub_01F2FF
	plx
	rtl

stage3_spiked_climber_state_10:
	jsr	a:sub_01F3E3
	lda	$06,x
	bpl	loc_01F0F4
	lda	#$0100
	sta	$24,x
	lda	#$8000
	sta	a:wram_03D6
	sta	a:wram_0616
	sta	a:wram_0416
	sta	a:wram_0456
	sta	a:wram_0396
	stz	$1A,x
	stz	$18,x
	stz	$1C,x
	stz	$1E,x
	stz	$16,x
	inc	$12,x
	rtl
loc_01F0F4:
	lda	$20,x
	bne	loc_01F118
	ldy	#$0000
	lda	$0A,x
	cmp	#$0058
	bcc	loc_01F105
	ldy	#$0002
loc_01F105:
	lda	a:data_05CC69,y
	cmp	$04,x
	beq	loc_01F118
	sta	$04,x
	lda	a:data_05CC6D,y
	sta	$16,x
	lda	#.loword(anim_05CCDD)
	sta	$20,x
loc_01F118:
	ldy	difficulty
	lda	$0A,x
	cmp	a:data_05CCD7,y
	bcc	loc_01F127
	stz	$1C,x
	stz	$1E,x
	bra	loc_01F164
loc_01F127:
	jsr	a:sub_01F2A0
	bmi	loc_01F149
	cmp	#$000C
	bcc	loc_01F14E
loc_01F131:
	lda	$0E,x
	cmp	#$0040
	bcs	loc_01F141
	lda	#$0002
	sta	$1E,x
	stz	$1C,x
	bra	loc_01F15E
loc_01F141:
	lda	#$1000
	jsr	a:sub_01F26C
	bra	loc_01F164
loc_01F149:
	cmp	#$FFF4
	bcs	loc_01F131
loc_01F14E:
	lda	$0E,x
	cmp	#$00BC
	bcc	loc_01F15E
	lda	#$FFFE
	sta	$1E,x
	stz	$1C,x
	bra	loc_01F141
loc_01F15E:
	lda	#$1000
	jsr	a:sub_01F286
loc_01F164:
	ldy	a:wram_1640
	bne	loc_01F1A0
	lda	$0A,x
	cmp	a:wram_1642
	bcs	loc_01F1B2
	cmp	#$0098
	bcc	loc_01F195
	lda	#$004B
	jsl	f:queue_sound
	lda	#$0002
	sta	a:shake_timer
	phy
	jsr	a:sub_01F38B
	ply
	lda	#$FFFE
	sta	$1A,x
	lda	#$8000
	sta	$18,x
	dec	$32,x
	bmi	loc_01F1B2
loc_01F195:
	lda	$1A,x
	bmi	loc_01F1CE
	cmp	#$0003
	bcs	loc_01F1DD
	bcc	loc_01F1CE
loc_01F1A0:
	lda	$0A,x
	cmp	#$003C
	bcc	loc_01F1B2
	lda	$1A,x
	bpl	loc_01F1CE
	cmp	#$FFFE
	bcc	loc_01F1DD
	bcs	loc_01F1CE
loc_01F1B2:
	lda	a:wram_1640
	eor	#$0002
	sta	a:wram_1640
	lda	#$0001
	sta	$32,x
	lda	rng_lo
	and	#$0006
	tay
	lda	a:data_05CCCF,y
	sta	a:wram_1642
	bra	loc_01F1DD
loc_01F1CE:
	clc
	lda	$18,x
	adc	a:data_05CCC7,y
	sta	$18,x
	lda	$1A,x
	adc	a:data_05CCCB,y
	sta	$1A,x
loc_01F1DD:
	jsr	a:sub_01F2FF
	rtl

stage3_spiked_climber_state_11:
	jsr	a:sub_01F3E3
	dec	$24,x
	bpl	loc_01F1EF
	inc	$12,x
	stz	$20,x
	stz	$00,x
	rtl
loc_01F1EF:
	jsl	f:queue_sound_41_throttled
	lda	#$0002
	sta	a:shake_timer
	lda	$0A,x
	sta	zp_00
	lda	#$00B8
	sta	zp_02
	lda	#$001F
	sta	zp_04
	lda	#$007F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01F21E
	lda	#$FFFC
	sta	a:$001A,y
loc_01F21E:
	rtl

stage3_spiked_climber_state_12:
	jsr	a:sub_01F3E3
	lda	#$0001
	sta	a:shake_continuous
	lda	f:wram_7E3821
	bpl	loc_01F24A
	lda	#$0000
	sta	f:wram_7E3821
	sta	f:wram_7E382A
	phx
	ldx	#.loword(data_059EB1)
	jsl	f:load_data_list
	plx
	inc	$12,x
	lda	#$0020
	sta	$24,x
	rtl
loc_01F24A:
	sec
	sbc	#$0004
	sta	f:wram_7E3821
	sta	f:wram_7E382A
	rtl

stage3_spiked_climber_state_13:
	dec	$24,x
	bpl	loc_01F26B
	lda	#$8000
	sta	$16,x
	lda	#$0002
	sta	a:bg1_scroll_mode
	lda	#$0007
	sta	hdma_preset
loc_01F26B:
	rtl

sub_01F26C:
	sta	zp_00
	lda	$1E,x
	bpl	loc_01F277
	cmp	#$FFFF
	bcc	loc_01F285
loc_01F277:
	sec
	lda	$1C,x
	sbc	zp_00
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
loc_01F285:
	rts

sub_01F286:
	sta	zp_00
	lda	$1E,x
	bmi	loc_01F291
	cmp	#$0001
	bcs	loc_01F29F
loc_01F291:
	clc
	lda	$1C,x
	adc	zp_00
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01F29F:
	rts

sub_01F2A0:
	lda	#$0400
	jsl	f:pick_target_player
	lda	$0E,x
	adc	#$FFF2
	sbc	a:$1314,y
	rts

sub_01F2B0:
	pha
	lda	#$0006
	sta	zp_02
	lda	#$0030
	sta	zp_08
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

sub_01F2C3:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	phx
	ldx	#$0000
	lda	#$0020
	sta	a:$3820,x
	lda	#$6000
	sta	a:$3822,x
	lda	#$0040
	sta	a:$3826,x
	lda	#$1F00
	sta	a:$3828,x
	stz	a:$3824,x
	stz	a:$382A,x
	stz	a:$382C,x
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	plx
	lda	#$0009
	sta	hdma_preset
	rts

sub_01F2FF:
	sec
	lda	#$00C4
	sbc	$0A,x
	sta	f:wram_7E3821
	sta	f:wram_7E382A
	lda	$0A,x
	sta	a:wram_040A
	sta	a:wram_044A
	adc	#$0000
	sta	a:wram_03CA
	sta	a:wram_060A
	lda	$0E,x
	sta	a:wram_038E
	lda	$0A,x
	cmp	#$0060
	bcc	loc_01F336
	clc
	lda	a:wram_038A
	adc	#$0006
	sta	a:wram_038A
	bra	loc_01F340
loc_01F336:
	sec
	lda	a:wram_038A
	sbc	#$0008
	sta	a:wram_038A
loc_01F340:
	clc
	lda	$0A,x
	adc	#$000C
	sec
	sbc	a:wram_038A
	bpl	loc_01F356
	cmp	#$FFE8
	bcs	loc_01F35F
	lda	#$0024
	bra	loc_01F359
loc_01F356:
	lda	#$000C
loc_01F359:
	clc
	adc	$0A,x
	sta	a:wram_038A
loc_01F35F:
	rts

sub_01F360:
	lda	#$0053
	sta	$10,x
	lda	#.loword(anim_05CC87)
	sta	$20,x
	lda	#$003C
	sta	$16,x

sub_01F36F:
	lda	a:data_05CC71,y
	sta	$0E,x
	lda	a:data_05CC75,y
	sta	$28,x
	lda	a:data_05CC7B,y
	sta	$2A,x
	lda	a:data_05CC81,y
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	stz	$04,x
	rts

sub_01F38B:
	lda	$0A,x
	adc	#$0028
	sta	zp_12
	lda	$0E,x
	adc	#$FFFA
	sta	zp_14
	phx
	lda	#$0003
	sta	zp_10
	ldy	#$08C0
loc_01F3A2:
	jsl	f:find_free_slot_y_down
	bcc	loc_01F3BB
	tyx
	lda	zp_12
	sta	$0A,x
	lda	zp_14
	sta	$0E,x
	phy
	jsl	f:sub_01CFC5
	ply
	dec	zp_10
	bpl	loc_01F3A2
loc_01F3BB:
	plx
	rts

sub_01F3BD:
	lda	#$0000
	bra	loc_01F3C5
	; CDL: not accessed
	.byte	$A9, $02, $00
loc_01F3C5:
	jsl	f:spawn_homing_missile
	bcc	loc_01F3E2
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFF8
	sta	a:$000E,y
	lda	zp_FC
	sta	a:$001A,y
	lda	zp_FE
	sta	a:$001E,y
loc_01F3E2:
	rts

sub_01F3E3:
	lda	#$48C4
	sta	zp_00
	stz	zp_02
	lda	#$0002
	jsl	f:kill_players_outside
	rts

; Object type $74: stage 4: enemy on a hover bike (HP 16; seen in the
; emulator).
update_hoverbike_rider:
	lda	$06,x
	bpl	loc_01F419
	lda	#$0013
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x
	lda	#$FFF8
	sta	$1A,x
	stz	$06,x
	lda	#$0003
	sta	$16,x
	stz	$00,x
	stz	$20,x
	stz	$22,x
	lda	#$0040
	sta	$24,x
loc_01F419:
	lda	$24,x
	bmi	loc_01F41F
	dec	$24,x
loc_01F41F:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_hoverbike_rider_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hoverbike_rider_states:
	.addr	hoverbike_rider_state_00
	.addr	hoverbike_rider_state_01
	.addr	hoverbike_rider_state_02
	.addr	hoverbike_rider_state_03
	.addr	hoverbike_rider_state_04
	.addr	hoverbike_rider_state_05
	.addr	hoverbike_rider_state_06

hoverbike_rider_state_00:
	inc	$12,x
	ldy	difficulty
	lda	#$4013
	sta	$16,x
	lda	a:hoverbike_rider_hp,y
	sta	$06,x
	lda	#$0020
	sta	$28,x
	lda	#$FFE0
	sta	$2A,x
	ldy	$30,x
	lda	a:data_05CD07,y
	sta	$00,x
	lda	#$3800
	sta	$02,x
	lda	rng_lo
	and	#$003F
	adc	#$0010
	sta	$24,x
	and	#$0001
	dec	a
	eor	#$0000
	sta	$1E,x
	lda	rng_hi
	and	#$3F00
	adc	#$8000
	sta	$1C,x
	sta	$18,x
	lda	rng_lo
	and	#$0001
	adc	#$FFFC
	sta	$1A,x
	lda	#$0028
	sta	$32,x
	lda	#$0004
	sta	$34,x
	rtl

hoverbike_rider_state_01:
	dec	$32,x
	bpl	loc_01F49F
	lda	$30,x
	lsr	a
	inc	a
	inc	a
	sta	$12,x
loc_01F49F:
	jsr	a:sub_01F52D
	rtl

hoverbike_rider_state_03:
	jsr	a:sub_01F55E
	jsr	a:sub_01F52D
	rtl

hoverbike_rider_state_02:
	jsr	a:sub_01F5A0
	jsr	a:sub_01F52D
	rtl

hoverbike_rider_state_04:
	dec	$24,x
	bpl	loc_01F4BA
	lda	#$8000
	sta	$16,x
loc_01F4BA:
	lda	stage_frame_odd
	bne	loc_01F4E7
	lda	#$001F
	sta	zp_06
	stz	zp_04
	lda	$0A,x
	adc	#$0000
	sta	zp_00
	lda	$0E,x
	adc	#$0000
	sta	zp_02
	ldy	#$0440
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	loc_01F4E7
	lda	rng_lo
	and	#$0003
	sta	a:$001A,y
loc_01F4E7:
	rtl

hoverbike_rider_state_05:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bne	loc_01F500
	lda	#.loword(anim_05CD0B)
	sta	$20,x
	inc	$12,x
loc_01F500:
	rtl

hoverbike_rider_state_06:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	ldy	#$0400
	lda	#.loword(anim_05C61E)
	jsl	f:spawn_effect
	bcs	loc_01F52C
	lda	#$FFFC
	sta	a:$001A,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_01F52C:
	rtl

sub_01F52D:
	lda	$0E,x
	cmp	#$0020
	bcs	loc_01F538
	ldy	$1E,x
	bmi	loc_01F545
loc_01F538:
	cmp	#$0090
	bcc	loc_01F541
	; (not executed in the CDL traces)
	lda	$1E,x
	bpl	loc_01F545
loc_01F541:
	lda	$24,x
	bpl	loc_01F55D
loc_01F545:
	lda	rng_lo
	and	#$001F
	adc	#$0010
	sta	$24,x
	lda	$1C,x
	eor	#$FFFF
	sta	$1C,x
	lda	$1E,x
	eor	#$FFFF
	sta	$1E,x
loc_01F55D:
	rts

sub_01F55E:
	lda	stage_frame_mod4
	bne	loc_01F59F
	lda	#$0400
	jsl	f:pick_target_player
	dec	$34,x
	bpl	loc_01F57C
	lda	#$0002
	sta	$34,x
	lda	#$0080
	sta	$32,x
	lda	#$0001
	sta	$12,x
loc_01F57C:
	ldy	#$0440
	jsl	f:find_free_slot_from_y
	bcs	loc_01F59F
	lda	#$0078
	sta	a:$0010,y
	lda	$0A,x
	adc	#$0020
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$001A
	jsl	f:queue_sound
loc_01F59F:
	rts

sub_01F5A0:
	lda	#$0400
	jsl	f:pick_target_player
	lda	$0A,x
	bmi	loc_01F5E2
	cmp	a:$000A,y
	bpl	loc_01F5E2
	lda	#$0080
	sta	$32,x
	lda	#$0001
	sta	$12,x
	ldy	#$0440
	jsl	f:find_free_slot_from_y
	bcs	loc_01F5E2
	lda	#$0076
	sta	a:$0010,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFE0
	sta	a:$000E,y
	lda	#.loword(anim_05CD0B)
	sta	$20,x
	lda	#$0016
	jsl	f:queue_sound
loc_01F5E2:
	rts

; Object type $76: stage 4: projectile. Not identified exactly.
update_object_type_76:
	lda	$12,x
	bne	loc_01F608
	inc	$12,x
	lda	#$0001
	sta	$16,x
	lda	#.loword(anim_05B284)
	sta	$20,x
	lda	#$3000
	sta	$02,x
	lda	#$4000
	sta	$18,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	rtl
loc_01F608:
	cmp	#$0002
	beq	loc_01F642
	lda	$0E,x
	cmp	#$00AC
	bcc	loc_01F632
	lda	#$0030
	jsl	f:queue_sound
	inc	$12,x
	stz	$1C,x
	stz	$1E,x
	lda	#$FFF8
	sta	$1A,x
	lda	#$000F
	sta	$16,x
	stz	$00,x
	stz	$20,x
	stz	$22,x
	rtl
loc_01F632:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
loc_01F642:
	lda	stage_frame_odd
	bne	loc_01F66A
	ldy	#$0440
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect
	bcs	loc_01F66A
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	rng_lo
	sta	a:$001C,y
	and	#$0003
	adc	#$FFFC
	sta	a:$001E,y
loc_01F66A:
	rtl

; Object type $78: stage 4: projectile. Not identified exactly.
update_object_type_78:
	lda	$12,x
	bne	loc_01F692
	inc	$12,x
	lda	#.loword(metasprite_06B13F)
	sta	$00,x
	lda	#$3000
	sta	$02,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8
	sta	$2A,x
	lda	#$000F
	sta	$16,x
	lda	#$0004
	sta	$1A,x
	sta	$1E,x
loc_01F691:
	rtl
loc_01F692:
	lda	$0E,x
	cmp	#$00B0
	bcc	loc_01F691
	stz	$1A,x
	lda	#$FFFC
	sta	$1E,x
	lda	#$C59A
	txy
	jml	f:make_effect_object
