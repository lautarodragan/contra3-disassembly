; objects/object_handlers_01b.asm -- Object handlers (bank $01, part 2)
; Bank $01, $01:CF8B-$01:F6A7. Included by main.asm in segment BANK01.
;
; Handlers of object types dispatched through tbl_object_types and their helpers.

; (no caller found; decoded because it follows the end of a routine)
; Adds fields $30/$32 to the y velocity (a gravity of its own), then falls
; into update_debris_explosion. Never reached.
unused_debris_explosion_with_gravity:
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
	beq	@return
	lda	#.loword(anim_05C59A)
	sta	$20,x
	stz	$22,x
	lda	#OBJT_EFFECT
	sta	$10,x
	lda	#$0003
	sta	$16,x
	stz	$1A,x
	lda	#$FFFE	; [num]
	sta	$1E,x
@return:
	rtl

; Object type $4B: becomes a type $1D effect flying in a random direction
; (stage 3 boss).
update_debris_spark:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	make_debris_effect_return

make_debris_effect:
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
	lda	a:enemy_bullet_speeds_hard,y
	sta	$1E,x
	lda	a:enemy_bullet_speeds_hard_x,y
	sta	$1A,x
	lda	a:enemy_bullet_speeds_hard_y_sub,y
	sta	$1C,x
	lda	a:enemy_bullet_speeds_hard_x_sub,y
	sta	$18,x
make_debris_effect_return:
	rtl

; Object type $1D: effect (explosion, spark, fire): plays OBJ_ANIM and frees
; itself when the script ends (make_effect_object).
update_effect:
	ldy	OBJ_ANIM,x
	bne	@playing
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@playing:
	lda	a:$0004,y
	sta	$02,x
	rtl

spawn_explosion_burst:
	phx
	pha
	xba
	and	#$003E
	tax
	pla
	and	#$00FF
	sta	zp_04
	ldy	#$0700
@loop:
	jsl	f:find_free_slot_y_down
	bcc	@next
	lda	#.loword(anim_05C558)
	jsl	f:make_effect_object
	lda	a:enemy_bullet_speeds_hard,x
	sta	a:$001E,y
	lda	a:enemy_bullet_speeds_hard_x,x
	sta	a:$001A,y
	lda	a:enemy_bullet_speeds_hard_y_sub,x
	sta	a:$001C,y
	lda	a:enemy_bullet_speeds_hard_x_sub,x
	sta	a:$0018,y
	lda	zp_FA
	sta	a:$000A,y
	lda	zp_FE
	sta	a:$000E,y
@next:
	txa
	clc
	adc	zp_08
	and	#$003E
	tax
	tya
	sec
	sbc	#$0040
	cmp	#$0340
	bcc	@done
	tay
	dec	zp_04
	bne	@loop
@done:
	plx
	rtl

; Object type $1E: alien dog that jumps out at the player (stage 1 sections
; 2-3; seen in the emulator).
update_alien_dog:
	lda	OBJ_HP,x
	bpl	@dispatch
	jmp	a:kill_alien_dog
@dispatch:
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
	sta	OBJ_FLAGS,x
	lda	#$3800
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_FACING,x
	lda	#.loword(anim_05C714)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x

alien_dog_state_01:
	jsr	a:alien_dog_check_player_close
	bcc	alien_dog_enter_state_02
	rtl

alien_dog_check_player_close:
	lda	a:p1_lives
	beq	@check_p2
	lda	$0A,x
	sec
	sbc	#$0020
	cmp	a:player1_obj+OBJ_X
	bcs	@return
@check_p2:
	lda	a:p2_lives
	beq	@return_clc
	lda	$0A,x
	sec
	sbc	#$0020
	cmp	a:player2_obj+OBJ_X
	bcs	@return
@return_clc:
	clc
@return:
	rts

alien_dog_check_player_in_range:
	lda	a:p1_lives
	beq	@check_p2
	lda	$0A,x
	clc
	adc	#$0050
	cmp	a:player1_obj+OBJ_X
	bcs	@return
@check_p2:
	lda	a:p2_lives
	beq	@return_clc
	lda	$0A,x
	clc
	adc	#$0050
	cmp	a:player2_obj+OBJ_X
	bcs	@return
@return_clc:
	clc
@return:
	rts
alien_dog_enter_state_02:
	stz	$04,x
	lda	#.loword(anim_05C752)
	sta	$20,x
	stz	$22,x
	inc	$12,x

alien_dog_state_02:
	lda	difficulty
	beq	@return
	jsr	a:alien_dog_check_player_in_range
	bcc	@jump
@return:
	rtl
@jump:
	lda	#$081F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0	; [num]
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
	lda	#$8000	; [num]
	sta	$1C,x
	stz	$04,x
	lda	#.loword(anim_05C778)
	sta	$20,x
	stz	$22,x
	inc	$12,x

alien_dog_state_03:
	lda	OBJ_Y,x
	cmp	#$00C8
	bcs	@landed
	rtl
@landed:
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

alien_dog_state_04:
	lda	$3E,x
	beq	@return
	; (not executed in the CDL traces)
	stz	$3E,x
	bra	kill_alien_dog
@return:
	rtl
; Killed: sound $0B, thrown back (state 5), then an explosion.
kill_alien_dog:
	lda	#$000B
	jsl	f:queue_sound
	stz	$06,x
	lda	#$0007
	sta	$16,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFC	; [num]
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
	dec	OBJ_TIMER,x
	bne	@fall
	lda	OBJ_X,x
	sta	OBJ_X,x
	lda	OBJ_Y,x
	sec
	sbc	#$0010
	sta	OBJ_Y,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rtl
@fall:
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
	lda	OBJ_STATE,x
	bne	@check_touch
	lda	#$180F
	sta	OBJ_FLAGS,x
	jsl	f:enemy_bullet_cycle_palette
	lda	#$0008
	sta	$28,x
	lda	#$FFF8	; [num]
	sta	$2A,x
	stz	$20,x
	lda	#.loword(metasprite_06AF55)
	sta	$00,x
	inc	$12,x
	rtl
@check_touch:
	lda	$3C,x
	beq	enemy_bullet_cycle_palette
	lda	#$8000	; [num]
	sta	$16,x

enemy_bullet_cycle_palette:
	lda	stage_frame_counter
	and	#$0006
	tay
	lda	a:enemy_bullet_palette_attrs,y
	sta	$02,x
	rtl

; Object type $1B: killed soldier thrown back (start_dying_soldier*), then
; an explosion effect.
update_dying_soldier:
	lda	OBJ_STATE,x
	bne	dying_soldier_state_01
; Entry points used by soldier handlers when killed: turn the object into
; type $1B (thrown back, then an explosion). With sprite A and sound $0E
; (here), $0D (start_dying_soldier_sound_0D) or $0B
; (start_dying_soldier_sprite); start_dying_soldier takes the sprite from
; dying_soldier_sprites by OBJ_FACING.
start_dying_soldier_sound_0E:
	sta	$00,x
	lda	#$000E
	bra	start_dying_soldier_with_sound
start_dying_soldier_sound_0D:
	sta	$00,x
	lda	#$000D
start_dying_soldier_with_sound:
	jsl	f:queue_sound
	bra	start_dying_soldier_common
start_dying_soldier_sprite:
	sta	$00,x
	bra	start_dying_soldier_sound_0B
start_dying_soldier:
	ldy	$04,x
	lda	a:dying_soldier_sprites,y
	sta	$00,x
start_dying_soldier_sound_0B:
	lda	#$000B
	jsl	f:queue_sound
start_dying_soldier_common:
	ldy	$04,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	stz	$20,x
	lda	#$0003
	sta	$16,x
	lda	a:dying_soldier_x_vels,y
	sta	$1A,x
	lda	a:dying_soldier_x_vel_subs,y
	sta	$18,x
	lda	#$FFFC	; [num]
	sta	$1E,x
	lda	#$0000
	sta	$1C,x
	lda	#$0010
	sta	$24,x
	lda	#$0001
	sta	$12,x
	rtl
dying_soldier_state_01:
	dec	$24,x
	bne	@fall
	lda	$0A,x
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	#$0010
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rtl
@fall:
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
	lda	OBJ_STATE,x
	bne	@wait_anim
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05C7A6)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x
	rtl
@wait_anim:
	lda	$20,x
	bne	@return
	lda	$16,x
	ora	#$8000
	sta	$16,x
@return:
	rtl

; Object type $1A: explosion of a grenade (type $13): harmful for $20
; frames, spawns type $1D sparks.
update_grenade_blast:
	lda	OBJ_STATE,x
	bne	grenade_blast_state_01
; Turns the object into a grenade blast (type $1A, also entered from
; update_grenade).
start_grenade_blast:
	stz	$1A,x
	stz	$18,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	stz	$1C,x
	lda	$0E,x
	sta	$30,x
	stz	$04,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0	; [num]
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
grenade_blast_state_01:
	lda	$24,x
	bne	@check_touch
	lda	#$8000	; [num]
	sta	$16,x
	rtl
@check_touch:
	lda	$3C,x
	beq	@check_sprite
	stz	$3C,x
	lda	#$0003
	sta	$16,x
@check_sprite:
	lda	$00,x
	bne	@check_anim
	lda	#.loword(anim_05C516)
	sta	$20,x
	stz	$22,x
	lda	$30,x
	sta	$0E,x
@check_anim:
	lda	$20,x
	bne	@sparks
	; (not executed in the CDL traces)
	stz	$00,x
@sparks:
	dec	$24,x
	lda	$24,x
	bit	#$0007
	bne	@return
	jsl	f:find_free_slot_y
	bcs	@return
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0006,y
	lda	#$FFFE	; [num]
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
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; The hit flash as update_objects does it: while OBJ_HIT, OBJ_ATTR saved in
; OBJ_SAVED_ATTR and set to palette 1 (priority kept); restored the next
; frame. Never reached.
unused_apply_hit_flash:
	; (not executed in the CDL traces)
	lda	$26,x
	bne	@restore
	lda	$14,x
	beq	@return
	lda	$02,x
	sta	$26,x
	and	#$3000
	ora	#$0200
	sta	$02,x
@return:
	rtl
@restore:
	lda	$26,x
	sta	$02,x
	stz	$26,x
	rtl

; Object type $2F: stage 1 burning section: spawns type $30 (falling fire).
; Not identified exactly.
update_object_type_2F:
	lda	OBJ_STATE,x
	bne	@active
	lda	#$0004
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	stz	$32,x
@return:
	rtl
@active:
	lda	$0A,x
	cmp	#$0120
	bcc	@on_screen
	cmp	#$FF80	; [num]
	bcs	@on_screen
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	$16,x
	rtl
@on_screen:
	lda	$32,x
	bne	@spawn_fire
	dec	$24,x
	bne	@return
	ldy	difficulty
	lda	#$0024
	sta	$32,x
	lda	a:object_type_2F_delays,y
	sta	$24,x
	lda	#$0022
	jsl	f:queue_sound
@spawn_fire:
	lda	stage_frame_mod4
	bne	@return
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	@return
	dec	$32,x
	lda	#$0030
	sta	a:$0010,y
	lda	#$8000	; [num]
	sta	a:$0018,y
	lda	#$0002
	sta	a:$001A,y
	lda	#$FFF9	; [num]
	sta	a:$001E,y
	bra	place_fire_object

; Object type $2B: stage 1 burning section. Not identified.
update_object_type_2B:
	lda	OBJ_STATE,x
	bne	@active
	lda	$3A,x
	sta	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
	lda	#.loword(metasprite_06AEA5)
	sta	OBJ_SPRITE,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	inc	OBJ_STATE,x
	rtl
@active:
	clc
	lda	#$1900
	adc	$1C,x
	sta	$1C,x
	lda	#$0000
	adc	$1E,x
	sta	$1E,x
	lda	#$00C0
	cmp	$0E,x
	bcs	@spawn_fireball
	sta	$0E,x
	lda	#$FFFD	; [num]
	dec	$24,x
	bne	@set_y_vel
	lda	$3A,x
	sta	$24,x
	lda	#$0023
	jsl	f:queue_sound
	lda	#$FFFA	; [num]
@set_y_vel:
	sta	$1E,x
@spawn_fireball:
	lda	stage_frame_mod4
	bne	place_fire_object_return
	ldy	#$08C0
	jsl	f:find_free_slot_y_down
	bcc	place_fire_object_return
	lda	#$002E
	sta	a:$0010,y
	lda	#$0004
	sta	a:$001E,y
; Makes the object at Y a fire (flags $0D, anim_05C7E8) at the position of
; the object at X.
place_fire_object:
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
	lda	#$FFF4	; [num]
	sta	a:$002A,y
place_fire_object_return:
	rtl

; Object type $30: stage 1 burning section: falling fire. Not identified
; exactly.
update_object_type_30:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$3000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x

; Object type $2E: stage 1 burning section: fireball. Not identified
; exactly.
update_object_type_2E:
	lda	OBJ_Y,x
	cmp	#$00B8
	bcc	@return
	txa
	bit	#$0040
	bne	@explode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@explode:
	lda	#$0001
	sta	$16,x
	lda	#.loword(anim_05C4CE)
	sta	$20,x
	lda	#OBJT_EFFECT
	sta	$10,x
	stz	$22,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	ldy	#$FFFF	; [num]
	lda	rng_hi
	bpl	@set_dir
	ldy	#$0000
@set_dir:
	sty	zp_00
	lda	rng_lo
	sta	$18,x
	and	#$0001
	eor	zp_00
	sta	$1A,x
@return:
	rtl

; Object type $31: stage 1 burning section: flying fireball enemy, HP 64.
; Not identified exactly.
update_object_type_31:
	lda	OBJ_STATE,x
	bne	@active
	ldy	difficulty
	lda	$3A,x
	and	#$00FF
	sta	$32,x
	lda	$3B,x
	and	#$00FF
	ora	#$FF00
	sta	$34,x
	lda	#$0004
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	a:object_type_31_hp,y
	sta	OBJ_HP,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	brl	@land
@active:
	lda	$30,x
	bne	@flying
	lda	$20,x
	bne	@wait
	stz	$22,x
	lda	#.loword(anim_05C59A)
	sta	$20,x
	lda	#$00B8
	sta	$0E,x
	lda	#$3000
	sta	$02,x
@wait:
	dec	$24,x
	bne	@return
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
@return:
	rtl
@flying:
	lda	$06,x
	bpl	@alive
	stz	$04,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
@alive:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	stage_frame_mod4
	bne	@check_floor
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	@check_floor
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
@check_floor:
	lda	$0E,x
	cmp	#$00C4
	bcc	@return2
@land:
	lda	#$0003
	sta	$16,x
	stz	$22,x
	lda	#.loword(anim_05C4CE)
	sta	$20,x
	stz	$30,x
	lda	#$FFFD	; [num]
	sta	$1E,x
	lda	#$00C0
	sta	$0E,x
	stz	$04,x
	lda	#$3E00
	sta	$02,x
@return2:
	rtl

; Object type $32: stage 1 section 10: fireballs. Not identified exactly.
update_object_type_32:
	lda	OBJ_HP,x
	bmi	@explode
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00CC
	bcc	@return
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
@explode:
	lda	#$0001
	sta	$16,x
	lda	#.loword(anim_05C59A)
	sta	$20,x
	lda	#OBJT_EFFECT
	sta	$10,x
	stz	$22,x
@return:
	rtl

; Object type $33: stage 1 section 10. Not identified.
update_object_type_33:
	lda	OBJ_FLAGS,x
	bne	@active
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$FFFF	; [num]
	sta	OBJ_TIMER,x
@return:
	rtl
@active:
	inc	$24,x
	lda	$0A,x
	cmp	#$0030
	bcs	@rumble
	lda	#$8000	; [num]
	sta	$16,x
	rtl
@rumble:
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$FFFD	; [num]
	lda	$24,x
	bit	#$0100
	bne	@set_y_vel
	bit	#$00FF
	bne	@shake
	lda	#$0024
	jsl	f:queue_sound
@shake:
	lda	#$0004
	sta	a:shake_timer
	ldy	#$FFF9	; [num]
@set_y_vel:
	sty	$30,x
	lda	stage_frame_odd
	bne	@return
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	@return
	tya
	bit	#$0040
	beq	@fireball
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	#.loword(anim_05C516)
	sta	a:$0020,y
	bra	@place
@fireball:
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
	lda	#$FFF4	; [num]
	sta	a:$002A,y
@place:
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
	ldy	#$FFFF	; [num]
	lda	rng_hi
	bpl	@set_dir
	ldy	#$0000
@set_dir:
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
	lda	OBJ_STATE,x
	bne	@active
	ldy	difficulty
	sec
	lda	$3A,x
	sbc	a:object_type_2C_delay_cuts,y
	sta	$30,x
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$00C8
	sta	OBJ_Y,x
	lda	#$FFFD	; [num]
	sta	$34,x
	rtl
@active:
	lda	$32,x
	beq	@wait
	bmi	@decelerate
	sec
	lda	$36,x
	sbc	#$C000
	sta	$36,x
	lda	$34,x
	sbc	#$0000
	sta	$34,x
	cmp	#$FFF0	; [num]
	bcs	@spawn_fire
	lda	#$FFFF	; [num]
	sta	$32,x
	bra	@spawn_fire
@decelerate:
	clc
	lda	$36,x
	adc	#$4000
	sta	$36,x
	lda	$34,x
	adc	#$0000
	sta	$34,x
	cmp	#$FFFB	; [num]
	bcc	@spawn_fire
	stz	$32,x
	bra	@spawn_fire
@wait:
	dec	$24,x
	bne	@spawn_fire
	lda	$30,x
	sta	$24,x
	lda	#$0001
	sta	$32,x
	lda	#$0021
	jsl	f:queue_sound
@spawn_fire:
	lda	stage_frame_mod4
	bne	@return
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcs	@return
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
	lda	#$FFF2	; [num]
	sta	a:$002A,y
@return:
	rtl

; Object type $2D: stage 1 burning section: fire. Not identified exactly.
update_object_type_2D:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$C000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	jml	f:update_effect

; Object type $34: stage 1 section 2. Not identified.
update_object_type_34:
	lda	OBJ_STATE,x
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
	.addr	object_type_34_state_02
	.addr	object_type_34_state_02
	.addr	shake_and_explode_state
	.addr	object_type_34_state_05

object_type_34_state_00:
	inc	OBJ_STATE,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	sta	$38,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	rtl

object_type_34_state_01:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	cmp	#$0017
	bne	@return
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	@spawn_soldiers
	lda	#$001D
	jsl	f:queue_sound
	inc	$12,x
	lda	#.loword(vram_blocks_05C848)
	sta	$32,x
	lda	#$4418
	sta	$30,x
	lda	#$0060
	sta	$24,x
@return:
	rtl
@spawn_soldiers:
	dec	$38,x
	bne	@return2
	lda	zp_EB
	and	#$003F
	adc	#$0020
	sta	$38,x
	ldy	#$0700
	jsl	f:find_free_slot_y_down
	bcc	@return2
	lda	$0A,x
	adc	#$0018
	sta	a:$000A,y
	phx
	tyx
	jsl	f:init_foot_soldier_running
	plx
@return2:
	rtl

object_type_34_state_02:
	lda	stage_frame_mod4
	cmp	#$0002
	bne	@return
	inc	OBJ_STATE,x
	lda	#$0030
	sta	zp_08
	lda	#$0002
	sta	zp_02
	ldy	$32,x
	lda	$30,x
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#.loword(vram_blocks_05C854)
	sta	$32,x
	lda	#$4000
	sta	$30,x
@return:
	rtl

object_type_34_state_05:
	lda	stage_frame_mod8
	bne	@return
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	lda	$34,x
	sta	zp_04
	lda	$36,x
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C59A)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFE	; [num]
	sta	a:$001E,y
@return:
	rtl

; State shared by type $02 (state 9) and type $34: shakes the screen and
; spawns explosions around the object for OBJ_TIMER frames, then the next
; state.
shake_and_explode_state:
	lda	#$0003
	sta	a:shake_timer
	dec	$24,x
	bne	spawn_explosion_near_object
	inc	$12,x
	rtl
; One explosion at random within fields $34/$36 around the object; every
; other frame it flies off with a random debris velocity. Also jumped to
; from the brain boss and the stage 3 boss.
spawn_explosion_near_object:
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
	bcs	@return
	lda	stage_frame_odd
	bne	@with_debris
	lda	#.loword(anim_05C5EE)
	sta	a:$0020,y
@return:
	rtl
@with_debris:
	phx
	lda	rng_lo
	and	#$000E
	tax
	lda	a:random_debris_vel_subs,x
	sta	a:$0018,y
	lda	a:random_debris_vels,x
	sta	a:$001E,y
	lda	rng_hi
	adc	stage_frame_counter
	and	#$000E
	tax
	lda	a:random_debris_vel_subs,x
	sta	a:$001C,y
	lda	a:random_debris_vels,x
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
; REP #$30, then falls into update_swing_pivot. Never reached.
unused_swing_pivot_entry:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10

; Object type $39: stage 3 (sections 2 and 4): pivot of a rotating swing the
; players hang from (PLAYER_STATE_HANG_OBJECT, seen in the emulator): turns
; its angle (field $30, speed $38) and carries the players whose field $3E
; is this pivot around it (swing_carry_player); up/down moves them along
; the arm (swing_player_climb), past its end they drop.
update_swing_pivot:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	txa
	sta	$3E,x
	jsr	a:init_swing_pivot
	rtl
@active:
	stx	zp_FC
	lda	$0A,x
	cmp	#$0120
	bcc	@check_y
	cmp	#$FFE0	; [num]
	bcc	@delete
@check_y:
	lda	$0E,x
	cmp	#$0120
	bcc	@update
	cmp	#$FFE0	; [num]
	bcs	@update
@delete:
	lda	#$8000	; [num]
	sta	$16,x
@update:
	jsr	a:advance_swing_angle
	ldy	#$0200
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	@player2
	jsr	a:swing_player_climb
	jsr	a:swing_carry_player
@player2:
	ldy	#$0240
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	@return
	jsr	a:swing_player_climb
	jsr	a:swing_carry_player
@return:
	rtl

; Object type $3A: a handle on a swing's arm (pivot in field $34): follows
; the pivot's angle; a player touching it grabs the swing (swing_grab_handle:
; state $10, radius = the distance to the pivot). Freed with its pivot.
update_swing_handle:
	ldy	$34,x
	lda	a:$0016,y
	bne	@follow
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@follow:
	jsr	a:swing_handle_follow_pivot
	ldy	#$0200
	jsl	f:swing_check_grab
	bcs	@player2
	jsr	a:swing_grab_handle
@player2:
	ldy	#$0240
	jsl	f:swing_check_grab
	bcs	@return
	jsr	a:swing_grab_handle
@return:
	rtl

init_swing_pivot:
	ldy	$3A,x
	lda	a:swing_speeds,y
	sta	$38,x
	lda	a:swing_handle_counts,y
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
	lda	a:swing_start_angles,y
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
@loop:
	lda	#$0010
	sta	zp_08
@loop2:
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	@done
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
	lda	#$FFF0	; [num]
	sta	a:$002A,y
	dec	zp_00
	bne	@loop2
	sec
	lda	zp_06
	sbc	#$0080
	sta	zp_06
	bmi	@done
	lda	zp_02
	sta	zp_00
	lda	zp_0A
	sta	zp_04
	bra	@loop
@done:
	plx
	rts

advance_swing_angle:
	clc
	lda	$30,x
	adc	$38,x
	and	#$00FF
	sta	$30,x
	rts

swing_handle_follow_pivot:
	lda	$32,x
	cmp	$3A,x
	bcc	@radius_set
	inc	$3A,x
@radius_set:
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
	lda	a:swing_handle_sprites,y
	sta	$00,x
	rts

swing_player_climb:
	lda	$16,x
	bpl	@alive
	; (not executed in the CDL traces)
	brl	swing_drop_player
@alive:
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
	bne	swing_player_climb_done
	lda	$22,x
	bit	#$0300
	beq	swing_player_climb_done
	bit	#$0200
	beq	@step
	ldy	#$0020
@step:
	tya
	clc
	adc	zp_02
	and	#$003E
	tay
	ldx	zp_FE
	clc
	lda	$34,x
	adc	a:swing_climb_steps_sub,y
	sta	$34,x
	lda	$36,x
	adc	a:swing_climb_steps,y
	cmp	#$0008
	bcs	@set_radius
	lda	#$0008
@set_radius:
	sta	$36,x
	ldx	zp_FC
	cmp	$36,x
	bcc	swing_player_climb_done
; The player at zp_FE leaves the swing (start_player_drop).
swing_drop_player:
	ldx	zp_FE
	jsl	f:start_player_drop
	stz	$3E,x
swing_player_climb_done:
	ldx	zp_FC
	rts

swing_carry_player:
	ldy	zp_FE
	lda	a:$0016,y
	bmi	swing_drop_player
	beq	swing_drop_player
	lda	a:$003E,y
	cmp	$3E,x
	bne	@return
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
	bcs	@check_right
	brl	swing_drop_player
@check_right:
	cmp	#$00F6
	bcc	@set_x
	; (not executed in the CDL traces)
	brl	swing_drop_player
@set_x:
	sta	a:$000A,y
	clc
	lda	$0E,x
	adc	zp_0A
	clc
	adc	#$0028
	sta	a:$000E,y
@return:
	rts

swing_grab_handle:
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
	bpl	@abs_dy
	eor	#$FFFF
@abs_dy:
	sta	zp_0A
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bpl	@abs_dx
	eor	#$FFFF
@abs_dx:
	sta	zp_08
	plx
	phy
	jsl	f:vector_length
	ply
	cmp	#$0008
	bcs	@check_max
	lda	#$0008
	bra	@set_radius
@check_max:
	cmp	$36,x
	bcc	@set_radius
	sec
	lda	$36,x
	sbc	#$0004
@set_radius:
	sta	a:$0036,y
	lda	#$0000
	sta	a:$0034,y
	rts

swing_check_grab:
	lda	a:$0016,y
	beq	@return_sec
	bmi	@return_sec
	lda	a:$003E,y
	cmp	$34,x
	beq	@return_sec
	lda	a:$0032,y
	bit	#$0400
	bne	@return_sec
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
	bmi	@return_sec
	lda	zp_06
	cmp	$0E,x
	bpl	@return_sec
	lda	$0A,x
	adc	$28,x
	cmp	zp_00
	bmi	@return_sec
	lda	$0E,x
	adc	$2A,x
	cmp	zp_04
	bpl	@return_sec
	clc
	rtl
@return_sec:
	sec
	rtl

; Object types $48 and $51: stage 3 (type $51: the flying machine with a
; searchlight, section 8). Not identified exactly.
update_object_type_48:
	lda	OBJ_HP,x
	bpl	@dispatch
	stz	OBJ_HP,x
	lda	#.loword(metasprite_06C1CC)
	jml	f:start_dying_soldier_sprite
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_48_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_48_states:
	.addr	object_type_48_state_00
	.addr	object_type_48_state_01
	.addr	object_type_48_state_02
	.addr	object_type_48_state_00
	.addr	object_type_48_state_02

object_type_48_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3800
	sta	OBJ_ATTR,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	difficulty
	lda	a:object_type_48_hp,y
	sta	OBJ_HP,x
	lda	OBJ_TYPE,x
	cmp	#$0051
	bne	object_type_48_start_walking
	jmp	a:object_type_48_jump
object_type_48_start_walking:
	jsl	f:snap_y_up_to_tile
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	jsr	a:object_type_48_set_x_velocity
	stz	$1E,x
	stz	$1C,x
	stz	$0C,x
	stz	$08,x
	stz	$24,x
	stz	$04,x
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcs	@set_anim
	lda	#$0002
	sta	$04,x
@set_anim:
	lda	#.loword(anim_05C926)
	sta	$20,x
	stz	$22,x
	inc	$12,x
	rtl

object_type_48_state_01:
	lda	OBJ_TIMER,x
	beq	@count_down
	lda	#$0004
	sta	zp_02
	lda	#$0008
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$0004
	bne	@wall_ahead
	bit	#$2000
	beq	@jump_toward_target
@wall_ahead:
	ldy	$38,x
	lda	a:$000A,y
	clc
	adc	#$0018
	sec
	sbc	$0A,x
	cmp	#$0030
	bcs	@count_down
	lda	a:$000E,y
	clc
	adc	#$0008
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	@jump_toward_target
@count_down:
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcs	@jump_toward_target
	rtl
@jump_toward_target:
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcc	@jump_left
	lda	#$8000	; [num]
	sta	$18,x
	stz	$1A,x
	bra	object_type_48_jump
@jump_left:
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
object_type_48_jump:
	lda	#$FFFC	; [num]
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

object_type_48_state_02:
	lda	$32,x
	clc
	adc	#$0020
	cmp	OBJ_Y,x
	bcs	@fall
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0004
	bne	@landed
	bit	#$2000
	bne	@landed
@fall:
	lda	$1E,x
	bmi	@accelerate
	cmp	#$0004
	bcs	@return
@accelerate:
	lda	$1C,x
	clc
	adc	#$4000
	sta	$1C,x
	bcc	@return
	inc	$1E,x
@return:
	rtl
@landed:
	lda	#$0000
	sta	$12,x
	jmp	a:object_type_48_start_walking

object_type_48_set_x_velocity:
	ldy	$38,x
	lda	a:$000A,y
	cmp	$0A,x
	bcc	@move_left
	ldy	difficulty
	lda	a:object_type_48_speeds_right,y
	and	#$FF00
	sta	$18,x
	lda	a:object_type_48_speeds_right,y
	and	#$00FF
	sta	$1A,x
	bra	@return
@move_left:
	ldy	difficulty
	lda	a:object_type_48_speeds_left,y
	and	#$FF00
	sta	$18,x
	lda	a:object_type_48_speeds_left,y
	ora	#$FF00
	sta	$1A,x
@return:
	rts

; Object type $49: stage 3 section 10: green shielded soldiers. Not
; identified exactly.
update_object_type_49:
	lda	OBJ_Y,x
	cmp	#$00E8
	bcc	@dispatch
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@dispatch:
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
	sta	OBJ_FLAGS,x
	stz	OBJ_TIMER,x
	stz	$30,x
	stz	$32,x
	inc	OBJ_STATE,x
	rtl

object_type_49_state_01:
	lda	stage_frame_counter
	and	#$001F
	bne	@return
	jsl	f:find_free_slot_y
	bcs	@return
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
	beq	@count
	lda	a:player2_obj+OBJ_FLAGS
	bit	#$0001
	beq	@count
	; (not executed in the CDL traces)
	lda	#$0240
	sta	a:$0038,y
@count:
	inc	$32,x
	inc	$30,x
	ldy	difficulty
	lda	a:object_type_49_burst_counts,y
	cmp	$30,x
	bcs	@return
	stz	$24,x
	inc	$12,x
@return:
	rtl

object_type_49_state_02:
	lda	$32,x
	cmp	#$0018
	bcs	@return
	inc	OBJ_TIMER,x
	ldy	difficulty
	lda	a:object_type_49_burst_delays,y
	cmp	OBJ_TIMER,x
	bcs	@return
	stz	$30,x
	stz	OBJ_TIMER,x
	stz	OBJ_STATE,x
@return:
	rtl

; Object type $4A: stage 3: rolling disc (HP 6; seen in the emulator).
update_rolling_mine:
	lda	OBJ_HP,x
	bpl	@dispatch
	lda	#$0030
	jsl	f:queue_sound
	txy
	lda	#$FFFE	; [num]
	sta	$1E,x
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@dispatch:
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
	sta	OBJ_FLAGS,x
	lda	a:rolling_mine_hp,y
	sta	OBJ_HP,x
	lda	#$3800
	sta	OBJ_ATTR,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE4	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	$3A,x
	sty	OBJ_FACING,x
	lda	a:rolling_mine_x_vel_subs,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:rolling_mine_x_vels,y
	sta	OBJ_X_VEL,x
	stz	$32,x
	lda	#.loword(anim_05C96C)
	sta	OBJ_ANIM,x
	inc	OBJ_STATE,x
	rtl

rolling_mine_state_01:
	lda	OBJ_TIMER,x
	bmi	@follow_floor
	dec	OBJ_TIMER,x
@follow_floor:
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	@on_floor
	inc	$12,x
	rtl
@on_floor:
	lda	$24,x
	bpl	@return
	lda	$30,x
	bne	@triggered
	ldy	#$0200
	jsr	a:rolling_mine_check_player
	ldy	#$0240
	jsr	a:rolling_mine_check_player
	rtl
@triggered:
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
@return:
	rtl

rolling_mine_state_02:
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0005
	bcs	@check_wall
@gravity:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
@check_wall:
	jsr	a:rolling_mine_check_wall
	lda	$1E,x
	bmi	@return
	jsl	f:object_follow_floor
	lda	zp_FC
	beq	@return
	lda	$32,x
	bne	@bounced
	lda	#$0020
	sta	$24,x
	inc	$32,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	stz	$1C,x
	rtl
@bounced:
	stz	$32,x
	lda	#$0001
	sta	$12,x
@return:
	rtl

rolling_mine_state_03:
	lda	OBJ_ANIM,x
	bne	@return
	lda	#$0040
	sta	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
@return:
	rtl

rolling_mine_state_05:
	lda	OBJ_ANIM,x
	bne	@return
	lda	#$0080
	sta	OBJ_TIMER,x
	ldy	OBJ_FACING,x
	lda	a:rolling_mine_x_vel_subs,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:rolling_mine_x_vels,y
	sta	OBJ_X_VEL,x
	lda	#$003F
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05C96C)
	sta	OBJ_ANIM,x
	lda	#$0001
	sta	OBJ_STATE,x
@return:
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
	lda	a:rolling_mine_aim_sprites,y
	sta	$00,x
	dec	$24,x
	lda	$24,x
	bmi	@timer_done
	cmp	#$0010
	bne	@return
	clc
	lda	a:rolling_mine_muzzle_x,y
	adc	$0A,x
	sta	zp_00
	clc
	lda	a:rolling_mine_muzzle_y,y
	adc	$0E,x
	sta	zp_02
	lda	zp_FE
	jsl	f:spawn_enemy_bullet
@return:
	rtl
@timer_done:
	lda	#.loword(anim_05C9B0)
	sta	$20,x
	lda	#$0005
	sta	$12,x
	rtl

rolling_mine_check_player:
	lda	a:$0016,y
	beq	@return
	clc
	lda	$0A,x
	adc	#$0008
	sec
	sbc	a:$1312,y
	bpl	@abs_dx
	eor	#$FFFF
@abs_dx:
	cmp	#$0050
	bcs	@return
	lda	#$0001
	sta	$30,x
@return:
	rts

rolling_mine_check_wall:
	lda	#$0010
	sta	zp_00
	lda	#$FFF0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	@check_left
	lda	#$0002
	sta	$04,x
	lda	#$87FF	; [num]
	sta	$18,x
	lda	#$FFFE	; [num]
	sta	$1A,x
@check_left:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	@return
	stz	$04,x
	lda	#$7800
	sta	$18,x
	lda	#$0001
	sta	$1A,x
@return:
	rts

; Object type $4E: stage 3 section 7, 27 states (a mid-boss, probably). Not
; identified.
update_object_type_4E:
	lda	OBJ_HP,x
	bpl	@flash
	lda	#$0018
	sta	OBJ_STATE,x
@flash:
	lda	$26,x
	beq	@dispatch
	lda	#.loword(palette_05916A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
@dispatch:
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
	.addr	object_type_4E_state_0B
	.addr	object_type_4E_state_0C
	.addr	object_type_4E_state_0D
	.addr	object_type_4E_state_0E
	.addr	object_type_4E_state_0F
	.addr	object_type_4E_state_10
	.addr	object_type_4E_state_0B
	.addr	object_type_4E_state_12
	.addr	object_type_4E_state_13
	.addr	object_type_4E_state_0E
	.addr	object_type_4E_state_15
	.addr	object_type_4E_state_0F
	.addr	object_type_4E_state_17
	.addr	object_type_4E_state_18
	.addr	object_type_4E_state_0E
	.addr	object_type_4E_state_1A
	; CDL: not accessed
	.byte	$6B

object_type_4E_state_00:
	lda	#$0000
	sta	OBJ_FLAGS,x
	lda	#$0006
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	stz	$38,x
	stz	OBJ_ANIM,x
	stz	OBJ_SPRITE,x
	inc	OBJ_STATE,x
	rtl

object_type_4E_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bcc	@return
	inc	OBJ_STATE,x
@return:
	rtl

object_type_4E_state_04:
	stz	$36,x
	stz	$38,x
	inc	OBJ_STATE,x
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
	adc	a:object_type_4E_tile_row_vram_addrs,y
	pha
	lda	$38,x
	asl	a
	tay
	lda	a:ptrs_object_type_4E_tile_rows,y
	tay
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$38,x
	lda	$38,x
	cmp	#$0005
	bcc	@return
	inc	$12,x
@return:
	rtl

object_type_4E_state_02:
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	a:bg2_x
	stz	a:bg2_y
	inc	OBJ_STATE,x
	rtl

object_type_4E_state_03:
	jsr	a:object_type_4E_set_bg2_scroll
	lda	$0E,x
	cmp	#$0020
	bcs	@return
	stz	$16,x
	stz	$1E,x
	inc	$12,x
@return:
	rtl

object_type_4E_set_bg2_scroll:
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
	sta	OBJ_FLAGS,x
	lda	#$0001
	sta	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	rtl

object_type_4E_state_07:
	jsr	a:object_type_4E_set_bg2_scroll
	lda	$0E,x
	cmp	#$0043
	bcc	@return
	stz	$16,x
	stz	$1E,x
	inc	$12,x
@return:
	rtl

object_type_4E_state_08:
	phx
	ldx	#$0000
@loop:
	lda	a:object_type_4E_buffer_init,x
	sta	f:$7EA000,x
	inx
	inx
	cpx	#$0008
	bcc	@loop
	lda	a:bg2_x
	sta	f:scroll_hdma_tables+$08
	ldx	#$0000
@loop2:
	sta	f:$7EA100,x
	inx
	inx
	cpx	#$0078
	bcc	@loop2
	plx
	inc	$12,x
	rtl

object_type_4E_state_09:
	lda	#$400D
	sta	OBJ_FLAGS,x
	ldy	difficulty
	lda	a:object_type_4E_hp,y
	sta	OBJ_HP,x
	inc	OBJ_STATE,x
	stz	OBJ_TIMER,x
	stz	$30,x
	stz	$32,x
	lda	#$0008
	sta	hdma_preset
	rtl

object_type_4E_state_0A:
	lda	#$006D
	sta	zp_06
	lda	OBJ_X,x
	sta	zp_04
	lda	#$00B6
	sta	zp_02
	lda	OBJ_X,x
	sta	zp_00
	phx
	jsr	a:build_bg2_slant_table
	plx
	stz	$30,x
	inc	$12,x
	rtl

object_type_4E_state_0B:
	lda	#$0002
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#.loword(vram_blocks_05CA6C)
	lda	#$4D8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

object_type_4E_state_0E:
	lda	#$0002
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#.loword(vram_blocks_05CA78)
	lda	#$4D8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

object_type_4E_state_0C:
	jsr	a:object_type_4E_pick_target
	inc	$12,x
	rtl

object_type_4E_pick_target:
	lda	#$0200
	sta	$34,x
	lda	a:player1_obj+OBJ_FLAGS
	bit	#$0001
	beq	@check_p2
	lda	rng_lo
	and	#$0001
	beq	@return
@check_p2:
	lda	a:player2_obj+OBJ_FLAGS
	bit	#$0001
	beq	@return
	; (not executed in the CDL traces)
	lda	#$0240
	sta	$34,x
@return:
	rts

object_type_4E_state_0D:
	jsr	a:object_type_4E_set_bg2_scroll
	lda	a:bg2_x
	sta	f:scroll_hdma_tables+$08
	lda	stage_frame_counter
	and	#$000F
	bne	@sway
	jsl	f:find_free_slot_y
	bcs	@sway
	lda	stage_frame_counter
	and	#$0010
	bne	@spawn_grenade
	lda	#$0016
	jsl	f:queue_sound
@spawn_grenade:
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
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$0000
	sta	a:$001C,y
	sta	a:$0012,y
@sway:
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
	lda	f:half_turn_sine,x
	plx
	lsr	a
	lsr	a
	xba
	and	#$003F
	sta	$32,x
	lda	$30,x
	bit	#$0040
	beq	@build_slant
	lda	$32,x
	eor	#$FFFF
	inc	a
	sta	$32,x
@build_slant:
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
	jsr	a:build_bg2_slant_table
	plx
	jsr	a:object_type_4E_track_target
	inc	$24,x
	lda	$24,x
	cmp	#$00F0
	bcc	@return
	stz	$30,x
	stz	$32,x
	stz	$24,x
	stz	$1A,x
	inc	$12,x
@return:
	rtl

object_type_4E_state_0F:
	jsr	a:object_type_4E_set_bg2_scroll
	lda	a:bg2_x
	sta	f:scroll_hdma_tables+$08
	stz	$1A,x
	stz	$18,x
	inc	$24,x
	lda	$24,x
	cmp	#$0078
	bcc	@return
	stz	$24,x
	stz	$1A,x
	inc	$12,x
@return:
	rtl

object_type_4E_state_12:
	lda	OBJ_FLAGS,x
	ora	#$0010
	sta	OBJ_FLAGS,x
	stz	OBJ_X_SUB,x
	lda	OBJ_X,x
	cmp	#$0080
	bcs	@right_half
	lda	#$0000
	bra	@set_x_vel
@right_half:
	lda	#$FFFF	; [num]
@set_x_vel:
	sta	$1A,x
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#.loword(vram_blocks_05CA88)
	lda	#$4C8C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	$12,x
	rtl

object_type_4E_state_13:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0258
	bcc	@spawn
	stz	OBJ_TIMER,x
	stz	OBJ_X_VEL,x
	inc	OBJ_STATE,x
	rtl
@spawn:
	lda	stage_frame_counter
	and	#$001F
	bne	@update
	jsl	f:find_free_slot_y
	bcs	@update
	lda	#$0051
	sta	a:$0010,y
	lda	stage_frame_counter
	and	#$0020
	beq	@left
	lda	#$0000
	sta	a:$001A,y
	lda	#$0008
	bra	@place
@left:
	lda	#$FFFF	; [num]
	sta	a:$001A,y
	lda	#$FFE8	; [num]
@place:
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	#$8000	; [num]
	sta	a:$0018,y
	lda	$0E,x
	sec
	sbc	#$0010
	sta	a:$000E,y
	lda	#$0003
	sta	a:$0012,y
	lda	#$0200
	sta	a:$0038,y
	lda	a:player1_obj+OBJ_FLAGS
	bit	#$0001
	beq	@check_p2
	lda	rng_lo
	and	#$0001
	beq	@update
@check_p2:
	lda	a:player2_obj+OBJ_FLAGS
	bit	#$0001
	beq	@update
	; (not executed in the CDL traces)
	lda	#$0240
	sta	a:$0038,y
@update:
	jsr	a:object_type_4E_set_bg2_scroll
	lda	a:bg2_x
	sta	f:scroll_hdma_tables+$08
	jsr	a:object_type_4E_keep_in_range

object_type_4E_slant_to_target:
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
	bne	@target_x
	jsr	a:object_type_4E_pick_target
	lda	a:player1_obj+OBJ_FLAGS
	ora	a:player2_obj+OBJ_FLAGS
	and	#$0001
	bne	@target_x
	lda	zp_04
	bra	@build
@target_x:
	lda	$34,x
	tay
	lda	a:$000A,y
@build:
	sta	zp_00
	phx
	jsr	a:build_bg2_slant_table
	plx
	rtl

object_type_4E_state_10:
	jsr	a:object_type_4E_pick_target
	jsl	f:object_type_4E_slant_to_target
	inc	$12,x
	rtl

object_type_4E_state_15:
	lda	OBJ_FLAGS,x
	and	#$FFEF
	sta	OBJ_FLAGS,x
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#.loword(vram_blocks_05CA95)
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
	sta	OBJ_STATE,x
	rtl

; Builds per-line BG2 horizontal offsets at $7E:A100 for a slanted line from
; x zp_04 (line zp_06) to x zp_00 (line zp_02): the BG2-drawn body of type
; $4E leaning towards its target.
build_bg2_slant_table:
	lda	zp_02
	sec
	sbc	zp_06
	sta	zp_0A
	bpl	@lines_ok
	; (not executed in the CDL traces)
	jmp	a:@return
@lines_ok:
	lda	zp_00
	sec
	sbc	zp_04
	bcc	@leftward
	sta	zp_08
	lda	#$0000
	sta	zp_10
	bra	@divide
@leftward:
	eor	#$FFFF
	inc	a
	sta	zp_08
	lda	#$FFFF	; [num]
	sta	zp_10
@divide:
	ldx	#$0000
	lda	zp_08
@loop:
	sec
	sbc	zp_0A
	bcc	@store_step
	inx
	cmp	zp_0A
	bcc	@store_frac
	cpx	#$0003
	bcc	@loop
	; (not executed in the CDL traces)
	lda	#$0000
@store_frac:
	sta	zp_08
@store_step:
	stx	zp_14
	lda	zp_04
	sta	zp_0C
	lda	zp_06
	sta	zp_0E
	stz	zp_12
	ldx	#$0000
@line_loop:
	lda	zp_10
	bmi	@mirror
	lda	zp_0C
	bra	@store
@mirror:
	lda	zp_04
	asl	a
	sec
	sbc	zp_0C
@store:
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
	beq	@return_clc
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
	bmi	@line_loop
	inc	zp_0C
	lda	zp_12
	sec
	sbc	zp_0A
	sta	zp_12
	bra	@line_loop
@return_clc:
	clc
@return:
	rts

; (no caller found; decoded because it follows the end of a routine)
; build_bg2_slant_table from x Y (line 0) to x -A (line $100). Never
; reached.
unused_build_bg2_slant_full_height:
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
	jsr	a:build_bg2_slant_table
	plx
	rtl

object_type_4E_keep_in_range:
	lda	$0A,x
	cmp	#$00B0
	bcs	object_type_4E_move_left
	cmp	#$0050
	bcs	object_type_4E_range_done
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	bra	object_type_4E_range_done

; (no caller found; decoded because it follows the end of a routine)
; x velocity -0.5, then the end of object_type_4E_keep_in_range. Never
; reached.
unused_object_type_4E_drift_left:
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
object_type_4E_range_done:
	jmp	a:object_type_4E_bob

object_type_4E_track_target:
	lda	$34,x
	tay
	lda	a:$0016,y
	bit	#$0001
	bne	@target_x
	jsr	a:object_type_4E_pick_target
	lda	a:player1_obj+OBJ_FLAGS
	ora	a:player2_obj+OBJ_FLAGS
	and	#$0001
	bne	@target_x
	lda	#$0080
	bra	@compare
@target_x:
	lda	$34,x
	tay
	lda	a:$000A,y
@compare:
	cmp	$0A,x
	beq	object_type_4E_stop
	bmi	object_type_4E_move_left
	lda	$0A,x
	cmp	#$00B0
	bcs	object_type_4E_stop
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	bra	object_type_4E_bob
object_type_4E_move_left:
	lda	$0A,x
	cmp	#$0050
	bcc	object_type_4E_stop
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	bra	object_type_4E_bob
object_type_4E_stop:
	stz	$18,x
	stz	$1A,x
; Moves the body 1 pixel up and down every 4 frames (bit 0 of OBJ_Y).
object_type_4E_bob:
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
	ldy	#.loword(vram_blocks_05CA9D)
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
	lda	#$FFFE	; [num]
	sta	$1E,x
	inc	$12,x
	lda	#$0030
	jsl	f:queue_sound
	rtl

object_type_4E_state_1A:
	jsr	a:object_type_4E_set_bg2_scroll
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
	bcs	@shake
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@shake:
	lda	#$0003
	sta	a:shake_timer
	lda	$1E,x
	bmi	@accelerate
	cmp	#$0001
	bcs	@check_bottom
@accelerate:
	lda	$1C,x
	clc
	adc	#$2000
	sta	$1C,x
	bcc	@check_bottom
	inc	$1E,x
@check_bottom:
	lda	$0E,x
	cmp	#$0140
	bcc	@return
	lda	#$8000	; [num]
	sta	$16,x
	stz	$10,x
	stz	a:bg1_scroll_mode
	stz	a:bg2_scroll_mode
	stz	a:bg2_x
@return:
	rtl

; Object type $4F: stage 3: winged alien bug (HP 8; seen in the emulator).
update_stage3_winged_bug:
	inc	$32,x
	lda	a:clear_enemies_timer
	bne	@die
	lda	OBJ_HP,x
	bpl	@dispatch
@die:
	lda	#$000C
	jsl	f:queue_sound
	ldy	#$0200
	jsr	a:stage3_winged_bug_release_player
	ldy	#$0240
	jsr	a:stage3_winged_bug_release_player
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
@dispatch:
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
	lda	OBJ_Y,x
	bmi	@check_speed
	cmp	$30,x
	bcc	@check_speed
	inc	OBJ_STATE,x
	lda	#.loword(anim_05CAA1)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
@check_speed:
	lda	$1E,x
	bmi	@accelerate
	cmp	#$0002
	bcs	@update
@accelerate:
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
@update:
	jsr	a:stage3_winged_bug_aim
	jsr	a:stage3_winged_bug_grab_players
	jsr	a:stage3_winged_bug_count_down
	rtl

stage3_winged_bug_state_02:
	clc
	lda	$30,x
	adc	#$FFF0
	cmp	OBJ_Y,x
	bcc	@check_speed
	dec	OBJ_STATE,x
	lda	#.loword(anim_05CAAF)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
@check_speed:
	lda	$1E,x
	bpl	@accelerate_up
	cmp	#$FFFF	; [num]
	bcc	@update
@accelerate_up:
	sec
	lda	$1C,x
	sbc	#$3000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
@update:
	jsr	a:stage3_winged_bug_aim
	jsr	a:stage3_winged_bug_grab_players
	jsr	a:stage3_winged_bug_count_down
	rtl

stage3_winged_bug_aim:
	lda	$32,x
	bit	#$001F
	bne	@return
	txa
	and	#$0040
	clc
	adc	#$0200
	tay
	lda	a:$0016,y
	bne	@target
	tya
	eor	#$0040
	tay
@target:
	lda	a:$000A,y
	cmp	$0A,x
	bmi	@target_left
	stz	$04,x
	lda	rng_hi
	adc	$0E,x
	sta	$18,x
	stz	$1A,x
	rts
@target_left:
	lda	#$0002
	sta	$04,x
	lda	rng_hi
	adc	$0E,x
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
@return:
	rts

stage3_winged_bug_state_03:
	jsr	a:stage3_winged_bug_grab_players
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
	bne	@fall
	lda	OBJ_X,x
	adc	#$FFFE
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	lda	#$0007
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C672)
	jsl	f:spawn_effect_random_offset
	bcs	@fall
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@fall:
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

stage3_winged_bug_grab_players:
	ldy	#$0200
	jsr	a:stage3_winged_bug_grab_player
	ldy	#$0240
	jsr	a:stage3_winged_bug_grab_player
stage3_winged_bug_grab_return:
	rts

stage3_winged_bug_grab_player:
	lda	a:$0016,y
	beq	stage3_winged_bug_grab_return
	bmi	stage3_winged_bug_grab_return
	bit	#$0002
	bne	stage3_winged_bug_grab_return
	txa
	cmp	a:$003E,y
	beq	@carry
	lda	a:$003E,y
	bne	@return
	lda	$0A,x
	cmp	#$000C
	bcc	@return
	cmp	#$00E0
	bcs	@return
	adc	$28,x
	sta	zp_00
	lda	a:$1312,y
	cmp	$0A,x
	bcc	@return
	cmp	zp_00
	bcs	@return
	lda	$0E,x
	adc	#$FFF0
	sta	zp_00
	lda	a:$000E,y
	adc	#$FFE0
	sta	zp_02
	cmp	zp_00
	bcc	@return
	cmp	$0E,x
	bcs	@return
	stz	$1E,x
	lda	#$F000	; [num]
	sta	$1C,x
	sta	$18,x
	stz	$1A,x
	lda	#$0003
	sta	$12,x
	txa
	sta	a:$003E,y
@carry:
	lda	#$0000
	sta	a:$001A,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	lda	$0A,x
	cmp	#$000C
	bcc	stage3_winged_bug_drop_player
	cmp	#$00E0
	bcs	stage3_winged_bug_drop_player
	adc	#$0004
	sta	a:$000A,y
	lda	$0E,x
	bpl	@set_y
	lda	#$0004
	sta	a:$003C,y
@set_y:
	adc	#$001C
	sta	a:$000E,y
@return:
	rts

stage3_winged_bug_release_player:
	txa
	cmp	a:$003E,y
	bne	stage3_winged_bug_release_return
stage3_winged_bug_drop_player:
	lda	#$0000
	sta	a:$003E,y
	lda	#$FFFC	; [num]
	sta	a:$001E,y
stage3_winged_bug_release_return:
	rts

stage3_winged_bug_state_00:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:stage3_winged_bug_spawn_masks,y
	bne	@return
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#OBJT_STAGE3_WINGED_BUG
	sta	a:$0010,y
	lda	#$001B
	sta	a:$0016,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$001C
	sta	a:$0028,y
	lda	#$FFD8	; [num]
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
@return:
	rtl

stage3_winged_bug_count_down:
	dec	$24,x
	bpl	@return
	lda	#$0003
	sta	$12,x
	lda	#.loword(anim_05CAA1)
	sta	$20,x
@return:
	rts

; Object type $56: stage 6. Not identified.
update_object_type_56:
	lda	OBJ_HP,x
	bpl	@dispatch
	stz	OBJ_HP,x
	lda	OBJ_FACING,x
	tay
	lda	a:object_type_56_dying_sprites,y
	jml	f:start_dying_soldier_sound_0E
@dispatch:
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
	.addr	object_type_56_state_02

object_type_56_state_00:
	ldy	difficulty
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	a:object_type_56_hp,y
	sta	OBJ_HP,x
	lda	#$3400
	sta	OBJ_ATTR,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	jsr	a:pick_random_player_local
	lda	a:$000A,y
	cmp	$0A,x
	bcc	@face_left
	stz	$04,x
	bra	@start
@face_left:
	lda	#$0002
	sta	$04,x
@start:
	lda	#.loword(anim_05CAF7)
	sta	$20,x
	stz	$22,x
	jsr	a:object_type_56_set_velocity
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$30,x
	stz	$32,x
	stz	$24,x
	inc	$12,x
	rtl

object_type_56_set_velocity:
	lda	$04,x
	bne	@left
	ldy	difficulty
	lda	a:object_type_56_x_vel_subs_right
	sta	$18,x
	lda	a:object_type_56_x_vels_right
	sta	$1A,x
	bra	@return
@left:
	ldy	difficulty
	lda	a:object_type_56_x_vel_subs_left
	sta	$18,x
	lda	a:object_type_56_x_vels_left
	sta	$1A,x
@return:
	rts

object_type_56_state_01:
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	@return
	lda	#$FFFD	; [num]
	sta	$1E,x
	lda	$04,x
	tay
	lda	a:object_type_56_jump_x_vels,y
	sta	$1A,x
	stz	$1C,x
	stz	$18,x
	lda	#.loword(anim_05CB11)
	sta	$20,x
	stz	$22,x
	inc	$12,x
@return:
	rtl

object_type_56_state_02:
	lda	OBJ_Y_VEL,x
	bmi	@accelerate
	cmp	#$0004
	bcs	@check_floor
@accelerate:
	lda	$1C,x
	clc
	adc	#$4000
	sta	$1C,x
	bcc	@check_floor
	inc	$1E,x
@check_floor:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$807E
	beq	@return
	jsr	a:object_type_56_set_velocity
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
@return:
	rtl

; Y = a player slot: $0200 or $0240 at random when both are present (bit 0
; of OBJ_FLAGS), else the present one.
pick_random_player:
	jsr	a:pick_random_player_local
	rtl

pick_random_player_local:
	lda	#$0200
	tay
	lda	a:player1_obj+OBJ_FLAGS
	bit	#$0001
	beq	@check_p2
	lda	rng_lo
	and	#$0001
	beq	@return
@check_p2:
	lda	a:player2_obj+OBJ_FLAGS
	bit	#$0001
	beq	@return
	lda	#$0240
	tay
@return:
	rts

; Object type $5C: stage 6, invisible spawner of alien soldiers (type $56):
; every alien_soldier_spawn_delays_right[difficulty] + rnd frames one from the right edge, every
; alien_soldier_spawn_delays_left + rnd frames one from the left, dropped onto the floor
; (drop_object_to_floor); none while a big enemy is near the right edge.
update_alien_soldier_spawner:
	lda	OBJ_STATE,x
	bne	@active
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	$30,x
	lda	#$0078
	sta	$32,x
	inc	OBJ_STATE,x
	rtl
@active:
	dec	$30,x
	lda	$30,x
	bne	@count_left
	jsr	a:spawn_alien_soldier_right
@count_left:
	dec	$32,x
	lda	$32,x
	bne	@return
	jsr	a:spawn_alien_soldier_left
@return:
	rtl

spawn_alien_soldier_right:
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:alien_soldier_spawn_delays_right,y
	sta	$30,x
	ldy	#$0900
@loop:
	lda	a:$0016,y
	bit	#$0040
	beq	@next
	; (not executed in the CDL traces)
	lda	a:$000A,y
	adc	a:$0028,y
	cmp	#$00F8
	bcs	spawn_alien_soldier_return
@next:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	@loop
	jsl	f:find_free_slot_y
	bcs	spawn_alien_soldier_return
	lda	#$00FF
	sta	a:$000A,y
	jsr	a:drop_object_to_floor
init_alien_soldier_at_y:
	lda	#$0056
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
spawn_alien_soldier_return:
	rts

spawn_alien_soldier_left:
	ldy	difficulty
	lda	rng_lo
	and	#$00FF
	adc	a:alien_soldier_spawn_delays_left,y
	sta	$32,x
	jsl	f:find_free_slot_y
	bcs	spawn_alien_soldier_return
	lda	#$0000
	sta	a:$000A,y
	jsr	a:drop_object_to_floor
	bra	init_alien_soldier_at_y

; Moves the object at Y down from y $78 to the first solid BG tile.
drop_object_to_floor:
	lda	#$0078
	sta	zp_05
	phx
	tyx
@loop:
	lda	zp_05
	sta	$0E,x
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$807E
	bne	@found
	lda	zp_05
	clc
	adc	#$0004
	sta	zp_05
	cmp	#$00BC
	bcc	@loop
	bcs	@not_found
@found:
	txy
	plx
	rts
@not_found:
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
	lda	OBJ_HP,x
	bpl	@dispatch
	stz	OBJ_HP,x
	lda	OBJ_FACING,x
	tay
	lda	a:object_type_56_dying_sprites,y
	jml	f:start_dying_soldier_sound_0E
@dispatch:
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
	.addr	object_type_56_state_02

object_type_24_state_00:
	ldy	difficulty
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	a:object_type_56_hp,y
	sta	OBJ_HP,x
	lda	#$2400
	sta	OBJ_ATTR,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	jsr	a:pick_random_player_local
	lda	a:$000A,y
	cmp	$0A,x
	bcc	@face_left
	stz	$04,x
	bra	@start
@face_left:
	lda	#$0002
	sta	$04,x
@start:
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
	bne	@return
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	lda	#.loword(anim_05CB11)
	sta	$20,x
	stz	$22,x
	inc	$12,x
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; REP #$30, then falls into update_stage3_spiked_climber. Never reached.
unused_spiked_climber_entry:
	; (not executed in the CDL traces)
	rep	#$20
	rep	#$10

; Object type $3D: stage 3 mid-boss: the spiked machine climbing the girder
; (HP 160; seen in the emulator).
update_stage3_spiked_climber:
	lda	OBJ_STATE,x
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
	inc	OBJ_STATE,x
	lda	#$0060
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	a:clear_enemies_timer
	rtl

stage3_spiked_climber_state_02:
	dec	OBJ_TIMER,x
	bpl	@return
	inc	OBJ_STATE,x
	lda	#$0060
	sta	OBJ_TIMER,x
	phx
	ldx	#.loword(load_list_059E95)
	jsl	f:load_data_list
	plx
@return:
	rtl

stage3_spiked_climber_state_00:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	stage3_spiked_climber_return
	inc	OBJ_STATE,x
	lda	#$FFF8	; [num]
	sta	a:boss_work_0
	lda	#$0200
	sta	a:boss_work_2
	stz	a:boss_work_4
	stz	a:boss_work_5
	stz	a:boss_work_1
	stz	a:boss_work_6
stage3_spiked_climber_return:
	rtl

stage3_spiked_climber_state_03:
	dec	OBJ_TIMER,x
	bpl	stage3_spiked_climber_return
	lda	#$0108
	sta	OBJ_Y,x
	lda	#$0078
	sta	OBJ_X,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	lda	#$0008
	sta	$3A,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	txa
	sta	$3E,x
	phx
	ldx	#$0340
	ldy	#$0000
	jsr	a:spiked_climber_init_part
	ldx	#$0380
	ldy	#$0002
	lda	#$FFFE	; [num]
	sta	$24,x
	jsr	a:spiked_climber_init_part
	ldx	#$0300
	ldy	#$0004
	jsr	a:spiked_climber_init_part
	lda	#$4010
	sta	$16,x
	ldy	difficulty
	lda	a:stage3_spiked_climber_core_hp,y
	sta	$06,x
	lda	#$FFF8	; [num]
	sta	$2A,x
	plx
	jsr	a:init_swing_pivot
	rtl

stage3_spiked_climber_state_04:
	lda	OBJ_Y,x
	cmp	#$0080
	bcs	stage3_spiked_climber_state_05
	inc	OBJ_STATE,x
	stz	OBJ_Y_VEL,x

stage3_spiked_climber_state_05:
	lda	a:boss_work_6
	beq	@move
	jsr	a:spiked_climber_check_fallen
	lda	$16,x
	beq	@return
@move:
	stx	zp_FC
	jsr	a:spiked_climber_move_x
	jsr	a:spiked_climber_place_parts
	lda	a:boss_work_6
	beq	@check_pause
	lda	#$0003
	sta	$38,x
	bra	@advance
@check_pause:
	lda	a:boss_work_1
	beq	@count_down
	dec	a:boss_work_1
	bra	@carry_players
@count_down:
	dec	a:boss_work_2
	bpl	@advance
	lda	#$0040
	sta	a:boss_work_1
	ldy	difficulty
	lda	rng_lo
	and	#$00FF
	adc	a:stage3_spiked_climber_state_05_delays,y
	sta	a:boss_work_2
	lda	$38,x
	eor	#$FFFF
	inc	a
	sta	$38,x
@advance:
	jsr	a:advance_swing_angle
@carry_players:
	ldy	#$0200
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	@player2
	jsr	a:swing_player_climb
	jsr	a:swing_carry_player
@player2:
	ldy	#$0240
	sty	zp_FE
	lda	a:$003E,y
	cmp	$3E,x
	bne	@return
	jsr	a:swing_player_climb
	jsr	a:swing_carry_player
@return:
	rtl

stage3_spiked_climber_state_06:
	lda	a:bg1_y
	bpl	@return
	cmp	#$FF58	; [num]
	bcs	@return
	inc	OBJ_STATE,x
	lda	#$0002
	sta	a:respawn_mode
	lda	#$0001
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$FFFB	; [num]
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	lda	#$0048
	jsl	f:queue_sound
@return:
	rtl

stage3_spiked_climber_state_07:
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	bne	@fall
	inc	OBJ_STATE,x
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	rtl
@fall:
	clc
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL_SUB
	adc	#$1000
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	adc	#$0000
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	clc
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	adc	#$EC00
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	adc	#$FFFF
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	rtl

; Object type $3E: does nothing (rtl); stage 3 spiked climber's arm.
update_object_type_3E:
	rtl

; Object type $40: stage 3 spiked climber, its weak point (HP 80).
update_stage3_spiked_climber_core:
	lda	a:boss_work_6
	bne	@flash
	lda	OBJ_HP,x
	bpl	@flash
	inc	a:boss_work_6
	lda	#$0030
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$0019
	jsl	f:queue_sound
@flash:
	ldy	#$3E00
	lda	$26,x
	beq	@set_attr
	ldy	#$3200
@set_attr:
	sty	a:obj_slots+5*OBJ_SIZE+OBJ_ATTR
	sty	a:obj_slots+6*OBJ_SIZE+OBJ_ATTR
	rtl

; Object type $3F: stage 3 spiked climber, spike arm.
update_object_type_3F:
	ldy	#.loword(metasprite_06B8B6)
	lda	stage_frame_bit1
	bne	@set_sprite
	ldy	#.loword(metasprite_06B8C3)
@set_sprite:
	sty	$00,x
	jsr	a:object_type_3F_move_spikes
	rtl

spiked_climber_init_part:
	lda	a:spiked_climber_part_sprites,y
	sta	$00,x
	lda	a:spiked_climber_part_types,y
	sta	$10,x
	lda	#$003C
	sta	$16,x
	lda	#$3E00
	sta	$02,x
	lda	a:spiked_climber_part_hitbox_w,y
	sta	$28,x
	lda	#$FFDC	; [num]
	sta	$2A,x
	lda	#$0180
	sta	$0A,x
	sta	$0E,x
	rts

spiked_climber_place_parts:
	clc
	lda	$0A,x
	adc	#$0004
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_X
	clc
	adc	#$FFF4
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	clc
	adc	#$000C
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
	lda	stage_frame_counter
	and	#$001F
	lsr	a
	lsr	a
	sta	zp_00
	lda	stage_frame_counter
	bit	#$0020
	beq	@bob
	lda	zp_00
	eor	#$FFFF
	and	#$0007
	sta	zp_00
@bob:
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
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	dec	a
	dec	a
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	inc	a
	inc	a
	clc
	adc	zp_02
	adc	a:boss_work_0
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_Y
	rts

object_type_3F_move_spikes:
	lda	a:boss_work_6
	bne	@retract
	inc	$24,x
	lda	difficulty
	beq	@retract
	lda	$24,x
	bit	#$0300
	beq	@extend
@retract:
	and	#$03FF
	cmp	#$0100
	bne	@retract_step
	lda	#$0019
	jsl	f:queue_sound
@retract_step:
	lda	a:boss_work_0
	cmp	#$FFF8	; [num]
	bcs	@return
	clc
	lda	a:boss_work_0
	adc	#$0004
	cmp	#$FFF8	; [num]
	bcc	@store
	lda	#$FFF8	; [num]
	bra	@store
@extend:
	and	#$00FF
	bne	@extend_step
	lda	#$0018
	jsl	f:queue_sound
@extend_step:
	lda	a:boss_work_0
	cmp	#$FFD4	; [num]
	bcc	@return
	clc
	lda	a:boss_work_0
	adc	#$FFFF
@store:
	sta	a:boss_work_0
@return:
	rts

spiked_climber_move_x:
	ldy	a:boss_work_4
	bne	@dir_left
	lda	$0A,x
	cmp	#$0088
	bcs	@reverse
	lda	$1A,x
	bmi	@accelerate
	cmp	#$0001
	bcs	@return
	bcc	@accelerate
@dir_left:
	lda	$0A,x
	cmp	#$0068
	bcc	@reverse
	lda	$1A,x
	bpl	@accelerate
	cmp	#$FFFF	; [num]
	bcc	@return
	bcs	@accelerate
@reverse:
	lda	a:boss_work_4
	eor	#$0002
	sta	a:boss_work_4
	rts
@accelerate:
	clc
	lda	$18,x
	adc	a:spiked_climber_move_x_accel_subs,y
	sta	$18,x
	lda	$1A,x
	adc	a:spiked_climber_move_x_accels,y
	sta	$1A,x
@return:
	rts

spiked_climber_check_fallen:
	lda	$0E,x
	cmp	#$0100
	bcc	@falling
	lda	#$8000	; [num]
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_FLAGS
	inc	$12,x
	stz	$16,x
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_SPRITE
	lda	#$0001
	sta	a:bg1_autoscroll
	sta	a:clamp_player_top
	lda	#$0002
	sta	a:bg1_scroll_mode
	sta	a:bg1_autoscroll_speed
	lda	#$0007
	sta	a:bg2_scroll_mode
	lda	#.loword(anim_05CB49)
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$0080
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	lda	#$0130
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_Y_VEL
	rts
@falling:
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
	bcs	@return
	lda	#$FFFA	; [num]
	sta	a:$001E,y
@return:
	rts

; Object type $59: not seen. Not identified.
update_object_type_59:
	lda	#$004E
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	stz	zp_04
	stx	zp_FC
	ldx	#$03C0
@loop:
	lda	#$005A
	sta	$10,x
	lda	#.loword(anim_05CC0B)
	sta	$20,x
	lda	#$3E00
	sta	$02,x
	lda	#$003D
	sta	$16,x
	lda	#$FFF4	; [num]
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
	bcc	@loop
	lda	#.loword(metasprite_06B9EA)
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_SPRITE
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_SPRITE
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+16*OBJ_SIZE+OBJ_ANIM
	ldx	#$0340
	lda	zp_04
	sta	$38,x
	lda	#$005A
	sta	$10,x
	lda	#$FF80	; [num]
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
	stz	a:boss_work_0
	stz	a:boss_work_1
	stz	a:boss_work_2
	ldx	zp_FC
	stz	$30,x
	stz	$32,x
	stz	$24,x
	rtl

stage3_spiked_climber_state_09:
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X
	bmi	@accelerate
	cmp	#$007C
	bcc	@accelerate
	lda	#$0049
	jsl	f:queue_sound
	lda	#$007C
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	lda	#$0003
	sta	a:shake_timer
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	inc	$12,x
	rtl
@accelerate:
	clc
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	adc	#$2000
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL_SUB
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	adc	#$0000
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X_VEL
	rtl

stage3_spiked_climber_state_0A:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@jitter
	inc	OBJ_STATE,x
	inc	a:boss_work_0
	rtl
@jitter:
	lda	stage_frame_counter
	bit	#$0002
	beq	@jitter_left
	lda	#$0001
	bra	@move
@jitter_left:
	lda	#$FFFF	; [num]
@move:
	clc
	adc	a:obj_slots+5*OBJ_SIZE+OBJ_X
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	lda	$24,x
	beq	@fire_check
	dec	$24,x
	lda	a:boss_work_1
	beq	@return
	ldy	$36,x
	lda	a:stage3_spiked_climber_segment_slots,y
	tay
	lda	$30,x
	sta	a:$0030,y
	lda	$32,x
	sta	a:$0032,y
	inc	$36,x
	inc	$36,x
	dec	a:boss_work_1
@return:
	rtl
@fire_check:
	lda	#$0001
	sta	a:boss_work_0
	ldy	a:boss_work_2
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	bmi	@return
	cmp	a:stage3_spiked_climber_missile_y,y
	bcc	@return
	phx
	ldx	#$0340
	lda	#$FFFF	; [num]
	sta	zp_FE
	lda	#$FFFE	; [num]
	sta	zp_FC
	jsr	a:spiked_climber_fire_missile
	lda	#$0001
	sta	zp_FE
	jsr	a:spiked_climber_fire_missile
	plx
	phx
	inc	a:boss_work_2
	inc	a:boss_work_2
	stz	$36,x
	lda	#$000A
	sta	zp_02
	inc	a
	sta	a:boss_work_1
	lda	$30,x
	eor	#$0016
	sta	$30,x
	sta	a:obj_slots+7*OBJ_SIZE+$30
	lda	$32,x
	eor	#$0002
	sta	$32,x
	sta	a:obj_slots+7*OBJ_SIZE+$32
	bne	@backward
	lda	#$0040
	ldx	#$03C0
	bra	@set_step
@backward:
	lda	#$FFC0	; [num]
	ldx	#$0600
@set_step:
	sta	zp_00
	ldy	#$0000
@loop:
	lda	#$004F
	sta	$24,x
	lda	a:stage3_spiked_climber_segment_x_vel_subs,y
	sta	$18,x
	lda	a:stage3_spiked_climber_segment_x_vels,y
	sta	$1A,x
	lda	a:stage3_spiked_climber_segment_x_accel_subs,y
	sta	$3A,x
	lda	a:stage3_spiked_climber_segment_x_accels,y
	sta	$3E,x
	txa
	clc
	adc	zp_00
	tax
	iny
	iny
	dec	zp_02
	bne	@loop
	ldx	#$0340
	lda	#$004F
	sta	$24,x
	lda	#$C7FF	; [num]
	sta	$18,x
	lda	#$FFFE	; [num]
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
	lda	a:boss_work_0
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
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_X
	adc	a:object_type_5A_x_offsets,y
	sta	OBJ_X,x
	clc
	lda	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	adc	a:object_type_5A_y_offsets,y
	sta	OBJ_Y,x

object_type_5A_state_01:
	ldy	$32,x
	lda	a:object_type_5A_anchor_y_addrs,y
	sta	zp_00
	clc
	lda	$38,x
	adc	$30,x
	tay
	sec
	lda	(zp_00)
	sbc	OBJ_Y,x
	sec
	sbc	a:object_type_5A_y_gaps,y
	beq	@timer
	bpl	@move_down
	dec	OBJ_Y,x
	bra	@timer
@move_down:
	inc	$0E,x
@timer:
	lda	$24,x
	beq	@accelerate
	dec	$24,x
	bne	@accelerate
	cpx	#$03C0
	beq	@shake
	cpx	#$0600
	bne	@stop
@shake:
	lda	#$0002
	sta	a:shake_timer
	lda	#$0049
	jsl	f:queue_sound
@stop:
	stz	$18,x
	stz	$1A,x
	stz	$3A,x
	stz	$3E,x
@accelerate:
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
	lda	a:obj_slots+16*OBJ_SIZE+OBJ_X
	cmp	OBJ_X,x
	bcs	@return
	sta	OBJ_X,x
@return:
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
	ldy	#.loword(vram_blocks_05CCA3)
	jsr	a:spiked_climber_queue_tiles
	inc	$12,x
	stz	a:boss_work_5
	lda	#$0040
	sta	a:boss_work_6
	lda	#$0003
	sta	$32,x
	rtl

stage3_spiked_climber_state_0C:
	inc	OBJ_STATE,x
	clc
	lda	$30,x
	adc	#$4280
	ldy	#.loword(vram_blocks_05CCBB)
	jsr	a:spiked_climber_queue_tiles
	rtl

stage3_spiked_climber_state_0D:
	lda	#$00F0
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HITBOX_W
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFE2	; [num]
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HITBOX_H
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_HITBOX_H
	jsr	a:spiked_climber_init_hdma
	inc	$12,x
	clc
	lda	$30,x
	adc	#$4300
	ldy	#.loword(vram_blocks_05CCAF)
	jsr	a:spiked_climber_queue_tiles
	lda	#$0003
	sta	a:shake_timer
	lda	#$0020
	sta	$24,x
	lda	#$004A
	jsl	f:queue_sound
	rtl

stage3_spiked_climber_state_0E:
	jsr	a:spiked_climber_kill_players_outside
	lda	#$0001
	sta	a:shake_continuous
	lda	f:hdma_tables+$21
	cmp	#$00A0
	bcc	@widen
	inc	$12,x
@widen:
	inc	a
	inc	a
	sta	f:hdma_tables+$21
	sta	f:hdma_tables+$2A
	lda	a:obj_slots+7*OBJ_SIZE+OBJ_X
	dec	a
	dec	a
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_X
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_X
	rtl

stage3_spiked_climber_state_0F:
	jsr	a:spiked_climber_kill_players_outside
	lda	#$0003
	sta	a:shake_timer
	lda	#$8000	; [num]
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+10*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+11*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+12*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+13*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+14*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+15*OBJ_SIZE+OBJ_FLAGS
	sta	$16,x
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_FLAGS
	stz	a:obj_slots+16*OBJ_SIZE+OBJ_FLAGS
	inc	$12,x
	phx
	lda	$10,x
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_TYPE
	lda	$12,x
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_STATE
	ldy	#$0002
	ldx	#$0400
	jsr	a:spiked_climber_init_hitbox
	ldx	#$0440
	jsr	a:spiked_climber_init_hitbox
	lda	#$006C
	sta	$0E,x
	ldy	#$0004
	ldx	#$0380
	jsr	a:spiked_climber_init_hitbox
	lda	#$0002
	sta	$04,x
	ldy	#$0000
	ldx	#$0340
	jsr	a:spiked_climber_set_hitbox
	lda	#.loword(anim_05CCDD)
	sta	$20,x
	lda	#$401D
	sta	$16,x
	ldy	difficulty
	lda	a:stage3_spiked_climber_hp,y
	sta	$06,x
	jsr	a:spiked_climber_place_bg
	plx
	rtl

stage3_spiked_climber_state_10:
	jsr	a:spiked_climber_kill_players_outside
	lda	$06,x
	bpl	@alive
	lda	#$0100
	sta	$24,x
	lda	#$8000	; [num]
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_FLAGS
	stz	$1A,x
	stz	$18,x
	stz	$1C,x
	stz	$1E,x
	stz	$16,x
	inc	$12,x
	rtl
@alive:
	lda	$20,x
	bne	@check_chase
	ldy	#$0000
	lda	$0A,x
	cmp	#$0058
	bcc	@set_facing
	ldy	#$0002
@set_facing:
	lda	a:stage3_spiked_climber_side_facings,y
	cmp	$04,x
	beq	@check_chase
	sta	$04,x
	lda	a:stage3_spiked_climber_side_flags,y
	sta	$16,x
	lda	#.loword(anim_05CCDD)
	sta	$20,x
@check_chase:
	ldy	difficulty
	lda	$0A,x
	cmp	a:stage3_spiked_climber_chase_max_x,y
	bcc	@chase
	stz	$1C,x
	stz	$1E,x
	bra	@horizontal
@chase:
	jsr	a:spiked_climber_dy_to_player
	bmi	@dy_negative
	cmp	#$000C
	bcc	@go_down
@go_up:
	lda	$0E,x
	cmp	#$0040
	bcs	@accel_up
	lda	#$0002
	sta	$1E,x
	stz	$1C,x
	bra	@accel_down
@accel_up:
	lda	#$1000
	jsr	a:spiked_climber_accel_up
	bra	@horizontal
@dy_negative:
	cmp	#$FFF4	; [num]
	bcs	@go_up
@go_down:
	lda	$0E,x
	cmp	#$00BC
	bcc	@accel_down
	lda	#$FFFE	; [num]
	sta	$1E,x
	stz	$1C,x
	bra	@accel_up
@accel_down:
	lda	#$1000
	jsr	a:spiked_climber_accel_down
@horizontal:
	ldy	a:boss_work_5
	bne	@moving_left
	lda	$0A,x
	cmp	a:boss_work_6
	bcs	@turn
	cmp	#$0098
	bcc	@speed_right
	lda	#$004B
	jsl	f:queue_sound
	lda	#$0002
	sta	a:shake_timer
	phy
	jsr	a:spiked_climber_spawn_debris
	ply
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$8000	; [num]
	sta	$18,x
	dec	$32,x
	bmi	@turn
@speed_right:
	lda	$1A,x
	bmi	@accelerate
	cmp	#$0003
	bcs	@place_bg
	bcc	@accelerate
@moving_left:
	lda	$0A,x
	cmp	#$003C
	bcc	@turn
	lda	$1A,x
	bpl	@accelerate
	cmp	#$FFFE	; [num]
	bcc	@place_bg
	bcs	@accelerate
@turn:
	lda	a:boss_work_5
	eor	#$0002
	sta	a:boss_work_5
	lda	#$0001
	sta	$32,x
	lda	rng_lo
	and	#$0006
	tay
	lda	a:stage3_spiked_climber_turn_x,y
	sta	a:boss_work_6
	bra	@place_bg
@accelerate:
	clc
	lda	$18,x
	adc	a:stage3_spiked_climber_x_accel_subs,y
	sta	$18,x
	lda	$1A,x
	adc	a:stage3_spiked_climber_x_accels,y
	sta	$1A,x
@place_bg:
	jsr	a:spiked_climber_place_bg
	rtl

stage3_spiked_climber_state_11:
	jsr	a:spiked_climber_kill_players_outside
	dec	$24,x
	bpl	@explosions
	inc	$12,x
	stz	$20,x
	stz	$00,x
	rtl
@explosions:
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
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001A,y
@return:
	rtl

stage3_spiked_climber_state_12:
	jsr	a:spiked_climber_kill_players_outside
	lda	#$0001
	sta	a:shake_continuous
	lda	f:hdma_tables+$21
	bpl	@shrink
	lda	#$0000
	sta	f:hdma_tables+$21
	sta	f:hdma_tables+$2A
	phx
	ldx	#.loword(load_list_059EB1)
	jsl	f:load_data_list
	plx
	inc	$12,x
	lda	#$0020
	sta	$24,x
	rtl
@shrink:
	sec
	sbc	#$0004
	sta	f:hdma_tables+$21
	sta	f:hdma_tables+$2A
	rtl

stage3_spiked_climber_state_13:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0002
	sta	a:bg1_scroll_mode
	lda	#$0007
	sta	hdma_preset
@return:
	rtl

spiked_climber_accel_up:
	sta	zp_00
	lda	$1E,x
	bpl	@accelerate
	cmp	#$FFFF	; [num]
	bcc	@return
@accelerate:
	sec
	lda	$1C,x
	sbc	zp_00
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
@return:
	rts

spiked_climber_accel_down:
	sta	zp_00
	lda	$1E,x
	bmi	@accelerate
	cmp	#$0001
	bcs	@return
@accelerate:
	clc
	lda	$1C,x
	adc	zp_00
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
@return:
	rts

spiked_climber_dy_to_player:
	lda	#$0400
	jsl	f:pick_target_player
	lda	$0E,x
	adc	#$FFF2
	sbc	a:$1314,y
	rts

spiked_climber_queue_tiles:
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

spiked_climber_init_hdma:
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
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	lda	#$0009
	sta	hdma_preset
	rts

spiked_climber_place_bg:
	sec
	lda	#$00C4
	sbc	$0A,x
	sta	f:hdma_tables+$21
	sta	f:hdma_tables+$2A
	lda	$0A,x
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_X
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_X
	adc	#$0000
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_X
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_X
	lda	$0E,x
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_Y
	lda	$0A,x
	cmp	#$0060
	bcc	@x_low
	clc
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_X
	adc	#$0006
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
	bra	@clamp
@x_low:
	sec
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_X
	sbc	#$0008
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
@clamp:
	clc
	lda	$0A,x
	adc	#$000C
	sec
	sbc	a:obj_slots+6*OBJ_SIZE+OBJ_X
	bpl	@part_left
	cmp	#$FFE8	; [num]
	bcs	@return
	lda	#$0024
	bra	@set_part_x
@part_left:
	lda	#$000C
@set_part_x:
	clc
	adc	$0A,x
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
@return:
	rts

spiked_climber_init_hitbox:
	lda	#$0053
	sta	$10,x
	lda	#.loword(anim_05CC87)
	sta	$20,x
	lda	#$003C
	sta	$16,x

spiked_climber_set_hitbox:
	lda	a:spiked_climber_hitbox_y,y
	sta	$0E,x
	lda	a:spiked_climber_hitbox_w,y
	sta	$28,x
	lda	a:spiked_climber_hitbox_h,y
	sta	$2A,x
	lda	a:spiked_climber_hitbox_sprites,y
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	stz	$04,x
	rts

spiked_climber_spawn_debris:
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
@loop:
	jsl	f:find_free_slot_y_down
	bcc	@done
	tyx
	lda	zp_12
	sta	$0A,x
	lda	zp_14
	sta	$0E,x
	phy
	jsl	f:make_debris_effect
	ply
	dec	zp_10
	bpl	@loop
@done:
	plx
	rts

spiked_climber_fire_missile:
	lda	#$0000
	bra	@spawn
	; CDL: not accessed
	.byte	$A9, $02, $00
@spawn:
	jsl	f:spawn_homing_missile
	bcc	@return
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFF8
	sta	a:$000E,y
	lda	zp_FC
	sta	a:$001A,y
	lda	zp_FE
	sta	a:$001E,y
@return:
	rts

; Kills the players above y $48 or below y $C4 (kill_players_outside with A
; = 2: the barrier does not protect).
spiked_climber_kill_players_outside:
	lda	#$48C4
	sta	zp_00
	stz	zp_02
	lda	#$0002
	jsl	f:kill_players_outside
	rts

; Object type $74: stage 4: enemy on a hover bike (HP 16; seen in the
; emulator).
update_hoverbike_rider:
	lda	OBJ_HP,x
	bpl	@timer
	lda	#$0013
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x
	lda	#$FFF8	; [num]
	sta	$1A,x
	stz	$06,x
	lda	#$0003
	sta	$16,x
	stz	$00,x
	stz	$20,x
	stz	$22,x
	lda	#$0040
	sta	$24,x
@timer:
	lda	$24,x
	bmi	@dispatch
	dec	$24,x
@dispatch:
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
	inc	OBJ_STATE,x
	ldy	difficulty
	lda	#$4013
	sta	OBJ_FLAGS,x
	lda	a:hoverbike_rider_hp,y
	sta	OBJ_HP,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	$30,x
	lda	a:hoverbike_rider_sprites,y
	sta	OBJ_SPRITE,x
	lda	#$3800
	sta	OBJ_ATTR,x
	lda	rng_lo
	and	#$003F
	adc	#$0010
	sta	OBJ_TIMER,x
	and	#$0001
	dec	a
	eor	#$0000
	sta	OBJ_Y_VEL,x
	lda	rng_hi
	and	#$3F00
	adc	#$8000
	sta	OBJ_Y_VEL_SUB,x
	sta	OBJ_X_VEL_SUB,x
	lda	rng_lo
	and	#$0001
	adc	#$FFFC
	sta	OBJ_X_VEL,x
	lda	#$0028
	sta	$32,x
	lda	#$0004
	sta	$34,x
	rtl

hoverbike_rider_state_01:
	dec	$32,x
	bpl	@move
	lda	$30,x
	lsr	a
	inc	a
	inc	a
	sta	OBJ_STATE,x
@move:
	jsr	a:hoverbike_rider_keep_in_bounds
	rtl

hoverbike_rider_state_03:
	jsr	a:hoverbike_rider_fire
	jsr	a:hoverbike_rider_keep_in_bounds
	rtl

hoverbike_rider_state_02:
	jsr	a:hoverbike_rider_drop_bomb
	jsr	a:hoverbike_rider_keep_in_bounds
	rtl

hoverbike_rider_state_04:
	dec	OBJ_TIMER,x
	bpl	@smoke
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@smoke:
	lda	stage_frame_odd
	bne	@return
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
	bcs	@return
	lda	rng_lo
	and	#$0003
	sta	a:$001A,y
@return:
	rtl

hoverbike_rider_state_05:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bne	@return
	lda	#.loword(anim_05CD0B)
	sta	OBJ_ANIM,x
	inc	OBJ_STATE,x
@return:
	rtl

hoverbike_rider_state_06:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$3000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	ldy	#$0400
	lda	#.loword(anim_05C61E)
	jsl	f:spawn_effect
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001A,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
@return:
	rtl

hoverbike_rider_keep_in_bounds:
	lda	$0E,x
	cmp	#$0020
	bcs	@check_bottom
	ldy	$1E,x
	bmi	@reverse_y
@check_bottom:
	cmp	#$0090
	bcc	@check_timer
	; (not executed in the CDL traces)
	lda	$1E,x
	bpl	@reverse_y
@check_timer:
	lda	$24,x
	bpl	@return
@reverse_y:
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
@return:
	rts

hoverbike_rider_fire:
	lda	stage_frame_mod4
	bne	@return
	lda	#$0400
	jsl	f:pick_target_player
	dec	$34,x
	bpl	@fire
	lda	#$0002
	sta	$34,x
	lda	#$0080
	sta	$32,x
	lda	#$0001
	sta	$12,x
@fire:
	ldy	#$0440
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0078
	sta	a:$0010,y
	lda	$0A,x
	adc	#$0020
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	#$001A
	jsl	f:queue_sound
@return:
	rts

hoverbike_rider_drop_bomb:
	lda	#$0400
	jsl	f:pick_target_player
	lda	$0A,x
	bmi	@return
	cmp	a:$000A,y
	bpl	@return
	lda	#$0080
	sta	$32,x
	lda	#$0001
	sta	$12,x
	ldy	#$0440
	jsl	f:find_free_slot_from_y
	bcs	@return
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
@return:
	rts

; Object type $76: stage 4: projectile. Not identified exactly.
update_object_type_76:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05B284)
	sta	OBJ_ANIM,x
	lda	#$3000
	sta	OBJ_ATTR,x
	lda	#$4000
	sta	OBJ_X_VEL_SUB,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	rtl
@active:
	cmp	#$0002
	beq	@burning
	lda	$0E,x
	cmp	#$00AC
	bcc	@fall
	lda	#$0030
	jsl	f:queue_sound
	inc	$12,x
	stz	$1C,x
	stz	$1E,x
	lda	#$FFF8	; [num]
	sta	$1A,x
	lda	#$000F
	sta	$16,x
	stz	$00,x
	stz	$20,x
	stz	$22,x
	rtl
@fall:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
@burning:
	lda	stage_frame_odd
	bne	@return
	ldy	#$0440
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect
	bcs	@return
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	rng_lo
	sta	a:$001C,y
	and	#$0003
	adc	#$FFFC
	sta	a:$001E,y
@return:
	rtl

; Object type $78: stage 4: projectile. Not identified exactly.
update_object_type_78:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06B13F)
	sta	OBJ_SPRITE,x
	lda	#$3000
	sta	OBJ_ATTR,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$0004
	sta	OBJ_X_VEL,x
	sta	OBJ_Y_VEL,x
@return:
	rtl
@active:
	lda	$0E,x
	cmp	#$00B0
	bcc	@return
	stz	$1A,x
	lda	#$FFFC	; [num]
	sta	$1E,x
	lda	#.loword(anim_05C59A)
	txy
	jml	f:make_effect_object
