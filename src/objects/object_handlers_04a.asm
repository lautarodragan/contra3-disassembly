; objects/object_handlers_04a.asm -- Object handlers (bank $04, part 1)
; Bank $04, $04:8000-$04:D877. Included by main.asm in segment BANK04.
;
; Handlers of object types dispatched through tbl_object_types and their
; helpers: the stage 3 boss room (robots, skeleton robot), stage 4
; (controller, snake robot, airship parts, helicopter, missiles, boss) and
; most of stage 6 (wall worm, floor mouths, heart, cave beast, winged alien,
; face boss). Each handler dispatches OBJ_STATE (+$12) through a table of
; state routines (tbl_<name>_states, <name>_state_NN).

; Object type $41. Stage 3 boss room. States $00-$09: the first of the two
; humanoid robots lowered on cables (stage3_robot_cables), 320 HP; when both
; robots are beaten it becomes the giant skeleton robot that breaks through
; the back wall (states $0A-$1A, 1024 HP set in stage3_boss_check_hp), which throws
; countdown_bomb and fires skeleton_eye_fireball. Seen in the emulator: slot
; $0900, stage 3 sections 12-13.
update_stage3_boss:
	.a16
	.i16
	lda	OBJ_STATE,x
	cmp	#$000D
	bcc	@dispatch
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$0050
	jsl	f:flash_palette_on_hit
	lda	stage_frame_counter
	and	#$000C
	lsr	a
	lsr	a
	bit	#$0002
	beq	@apply_wobble
	eor	#$FFFF
@apply_wobble:
	clc
	adc	#$0100
	sta	a:bg2_y
@dispatch:
	inc	a:boss_work_0
	jsr	a:stage3_boss_check_hp
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage3_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage3_boss_states:
	.addr	stage3_robot_state_00
	.addr	stage3_robot_state_01
	.addr	stage3_robot_state_02
	.addr	stage3_robot_state_03
	.addr	stage3_robot_state_04
	.addr	stage3_robot_state_05
	.addr	stage3_boss_state_06
	.addr	stage3_robot_state_07
	.addr	stage3_robot_state_08
	.addr	stage3_robot_state_09
	.addr	stage3_boss_state_0A
	.addr	stage3_boss_state_0B
	.addr	stage3_boss_state_0C
	.addr	stage3_boss_state_0D
	.addr	stage3_boss_state_0E
	.addr	stage3_boss_state_0F
	.addr	stage3_boss_state_0E
	.addr	stage3_boss_state_11
	.addr	stage3_boss_state_12
	.addr	stage3_boss_state_0E
	.addr	stage3_boss_state_14
	.addr	stage3_boss_state_15
	.addr	stage3_boss_state_16
	.addr	stage3_boss_state_17
	.addr	stage3_boss_state_18
	.addr	stage3_boss_state_19
	.addr	stage3_boss_state_1A

; Object type $45. Stage 3 boss room: the second humanoid robot (320 HP, slot
; $08C0); shares most states with stage3_boss's robot form.
update_stage3_second_robot:
	jsr	a:stage3_boss_check_hp
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage3_second_robot_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage3_second_robot_states:
	.addr	stage3_robot_state_00
	.addr	stage3_robot_state_01
	.addr	stage3_second_robot_state_02
	.addr	stage3_robot_state_03
	.addr	stage3_robot_state_04
	.addr	stage3_robot_state_05
	.addr	stage3_second_robot_state_06
	.addr	stage3_robot_state_07
	.addr	stage3_robot_state_08
	.addr	stage3_robot_state_09
	.addr	stage3_second_robot_state_0A

stage3_robot_state_00:
	inc	OBJ_STATE,x
	ldy	$3A,x
	lda	a:stage3_robot_attrs,y
	sta	OBJ_ATTR,x
	lda	#$403D
	sta	OBJ_FLAGS,x
	lda	a:stage3_robot_sprites,y
	sta	OBJ_SPRITE,x
	lda	#$001A
	sta	OBJ_HITBOX_W,x
	lda	#$FFB8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#ENEMY_HP($0140)
	sta	OBJ_HP,x
	stz	$38,x
	phx
	ldy	#.loword(palette_task_05E7E2)
	jsl	f:start_palette_task
	plx
	rtl

stage3_robot_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	stage3_robot_return
	inc	OBJ_STATE,x
	stz	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$401D
	sta	OBJ_FLAGS,x
stage3_robot_return:
	rtl

stage3_robot_state_02:
	dec	OBJ_TIMER,x
	bpl	stage3_robot_return
	ldy	difficulty
	lda	a:stage3_robot_wait_times,y
	sta	OBJ_TIMER,x
	jsr	a:stage3_robot_pick_direction
	ldy	zp_00
	lda	OBJ_Y,x
	cmp	#$00CF
	bcs	@on_floor
	lda	OBJ_X,x
	cmp	#$0070
	bcc	@walk_right
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	bra	@start_walk
@walk_right:
	; (not executed in the CDL traces)
	stz	OBJ_FACING,x
	lda	#$0001
	sta	OBJ_X_VEL,x
@start_walk:
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E83B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
@on_floor:
	lda	zp_06
	cmp	#$0070
	bcc	stage3_robot_jump_or_hop
	lda	zp_04
	cmp	#$0030
	bcs	stage3_robot_jump_or_hop
	lda	zp_00
	sta	OBJ_FACING,x
	lda	#$0004
	sta	$36,x
	lda	#$FFF8	; [num]
	sta	$32,x
	stz	$34,x
stage3_robot_start_jump:
	lda	#$0003
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E81D)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
stage3_robot_jump_or_hop:
	lda	OBJ_X,x
	cmp	#$0031
	bcc	@near_edge
	cmp	#$00AF
	bcc	@hop
@near_edge:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_jump_x_vels,y
	sta	$34,x
	lda	#$0005
	sta	$36,x
	lda	#$FFFB	; [num]
	sta	$32,x
	brl	stage3_robot_start_jump
@hop:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_hop_x_vels,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFB	; [num]
	sta	$32,x
	brl	stage3_robot_start_jump
stage3_second_robot_return:
	rtl

stage3_second_robot_state_02:
	dec	OBJ_TIMER,x
	bpl	stage3_second_robot_return
	ldy	difficulty
	lda	a:stage3_second_robot_wait_times,y
	sta	OBJ_TIMER,x
	jsr	a:stage3_robot_pick_direction
	lda	OBJ_Y,x
	cmp	#$00CF
	bcs	@on_floor
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E83B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
@on_floor:
	lda	zp_04
	cmp	#$0050
	bcs	@hop
	lda	zp_00
	sta	OBJ_FACING,x
	lda	#$0006
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E847)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$00C0
	sta	$3E,x
	rtl
@hop:
	ldy	#$0000
	lda	OBJ_X,x
	cmp	#$0070
	bcc	@have_side
	ldy	#$0002
@have_side:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_hop_x_vels,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFD	; [num]
	sta	$32,x
	brl	stage3_robot_start_jump

stage3_boss_state_06:
	lda	OBJ_HP,x
	bmi	@end_shooting
	dec	$3E,x
	bpl	@aim
	ldy	OBJ_FACING,x
	lda	OBJ_X,x
	adc	a:stage3_robot_gun_x_offsets,y
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$FFBE
	sta	zp_02
	lda	a:stage3_robot_bullet_dirs_1,y
	jsl	f:spawn_enemy_bullet
	lda	a:stage3_robot_bullet_dirs_2,y
	jsl	f:spawn_enemy_bullet
	lda	a:stage3_robot_bullet_dirs_3,y
	jsl	f:spawn_enemy_bullet
@end_shooting:
	lda	#$0002
	sta	OBJ_STATE,x
	rtl
@aim:
	jsr	a:stage3_robot_pick_direction
	lda	zp_00
	sta	OBJ_FACING,x
	rtl

stage3_second_robot_state_06:
	lda	OBJ_HP,x
	bmi	@end_shooting
	dec	$3E,x
	bpl	@spawn_debris
@end_shooting:
	lda	#$0002
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E829)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
@spawn_debris:
	jsr	a:stage3_second_robot_spawn_debris
	rtl

stage3_robot_state_03:
	lda	OBJ_ANIM,x
	bne	@return
	lda	$36,x
	sta	OBJ_STATE,x
	lda	$32,x
	sta	OBJ_Y_VEL,x
	lda	$34,x
	sta	OBJ_X_VEL,x
@return:
	rtl

stage3_robot_state_04:
	lda	OBJ_X,x
	cmp	#$0030
	bcc	@left_edge
	cmp	#$00B0
	bcc	stage3_robot_update_jump
	lda	OBJ_X_VEL,x
	bmi	stage3_robot_update_jump
	lda	#$00B0
	sta	OBJ_X,x
	bpl	@stop_x
@left_edge:
	lda	OBJ_X_VEL,x
	bpl	stage3_robot_update_jump
	lda	#$0030
	sta	OBJ_X,x
@stop_x:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	bra	stage3_robot_update_jump

stage3_robot_state_05:
	lda	OBJ_X,x
	cmp	#$0010
	bcc	@face_right
	cmp	#$00D0
	bcc	stage3_robot_update_jump
	stz	OBJ_FACING,x
	bra	@bump
@face_right:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	OBJ_FACING,x
@bump:
	lda	#$0033
	jsl	f:queue_sound
	lda	#.loword(anim_05E841)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	stage3_robot_land
stage3_robot_update_jump:
	lda	OBJ_Y_VEL,x
	bpl	@falling
	lda	OBJ_Y,x
	cmp	#$0090
	bcs	stage3_robot_apply_gravity
	lda	#$0033
	jsl	f:queue_sound
	lda	#$0090
	sta	OBJ_Y,x
	lda	#.loword(anim_05E835)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0006
	sta	OBJ_STATE,x
	lda	#$0080
	sta	$3E,x
	lda	#.loword(anim_05E88B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	stage3_robot_stop
@falling:
	lda	OBJ_Y,x
	cmp	#$00D0
	bcc	stage3_robot_apply_gravity
	lda	#$0032
	jsl	f:queue_sound
	lda	#$00D0
	sta	OBJ_Y,x
	lda	#.loword(anim_05E829)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	sec
	lda	OBJ_X,x
	sbc	#$0030
	cmp	#$0008
	bcs	@check_right_edge
	lda	#$0030
	sta	OBJ_X,x
	bra	stage3_robot_land
@check_right_edge:
	sec
	lda	#$00B0
	sbc	OBJ_X,x
	cmp	#$0008
	bcs	stage3_robot_land
	lda	#$00B0
	sta	OBJ_X,x
stage3_robot_land:
	lda	#$0002
	sta	OBJ_STATE,x
stage3_robot_stop:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	#$0003
	sta	a:shake_timer
	rtl
stage3_robot_apply_gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

stage3_robot_state_07:
	dec	OBJ_TIMER,x
	bpl	stage3_robot_explode
	inc	OBJ_STATE,x
	lda	#$0C00
	sta	OBJ_TIMER,x
	lda	#.loword(anim_05E871)
	sta	OBJ_ANIM,x
	lda	#$001D
	sta	OBJ_FLAGS,x
	lda	#$FFE2	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
	rtl
stage3_robot_explode:
	jsr	a:toggle_sprite_visible
	jsl	f:queue_sound_30_throttled
	lda	stage_frame_odd
	bne	@return
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$000C
	sta	zp_02
	lda	#$000F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C5B8)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	rng_lo
	and	#$0001
	adc	#$FFFE
	sta	a:$001E,y
@return:
	rtl

stage3_robot_state_08:
	lda	stage_frame_mod8
	bne	@clamp_x
	lda	rng_hi
	adc	OBJ_X,x
	bit	#$0001
	bne	@clamp_x
	lda	OBJ_FACING,x
	eor	#$0002
	sta	OBJ_FACING,x
@clamp_x:
	lda	OBJ_X,x
	cmp	#$0010
	bcs	@check_right_edge
	stz	OBJ_FACING,x
	lda	#$0003
	sta	OBJ_X_VEL,x
	bra	@accelerate
@check_right_edge:
	cmp	#$00D8
	bcc	@accelerate
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$FFFD	; [num]
	sta	OBJ_X_VEL,x
@accelerate:
	lda	OBJ_FACING,x
	beq	@facing_right
	lda	OBJ_X_VEL,x
	bpl	@accel_left
	cmp	#$FFFD	; [num]
	bcc	@vertical
@accel_left:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bra	@vertical
@facing_right:
	lda	OBJ_X_VEL,x
	bmi	@accel_right
	cmp	#$0003
	bcs	@vertical
@accel_right:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
@vertical:
	lda	OBJ_Y_VEL,x
	bmi	@airborne
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	@on_floor
@airborne:
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0005
	bcs	@return
@gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$5000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	@return
@on_floor:
	lda	rng_lo
	adc	OBJ_X,x
	and	#$000F
	bne	@return
	lda	#.loword(anim_05E86B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$FFF9	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0034
	jsl	f:queue_sound
@return:
	rtl

stage3_robot_state_09:
	dec	OBJ_TIMER,x
	bpl	@explode
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
@explode:
	brl	stage3_robot_explode

stage3_second_robot_state_0A:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Object type $44. Stage 3 boss room: the cables that lower the two robots
; from the ceiling; waits until stage3_boss (slot $0900) reaches state 3.
update_stage3_robot_cables:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage3_robot_cables_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage3_robot_cables_states:
	.addr	stage3_robot_cables_state_00
	.addr	stage3_robot_cables_state_01
	.addr	stage3_robot_cables_state_02
	.addr	stage3_robot_cables_state_03
	.addr	stage3_robot_cables_state_04

stage3_robot_cables_state_00:
	inc	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	lda	#.loword(metasprite_06BE1D)
	sta	OBJ_SPRITE,x
	rtl

stage3_robot_cables_state_01:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	@return
	lda	#$0018
	sta	OBJ_TIMER,x
	lda	#.loword(vram_blocks_05E7C8)
	sta	$30,x
	inc	OBJ_STATE,x
@return:
	rtl

stage3_robot_cables_state_02:
	dec	OBJ_TIMER,x
	bpl	@draw_cable
	lda	#.loword(anim_05E7EB)
	sta	OBJ_ANIM,x
	inc	OBJ_STATE,x
	ldy	#$0200
	jsr	a:stage3_cables_crush_player
	ldy	#$0240
	jsr	a:stage3_cables_crush_player
	lda	#$0040
	sta	zp_04
	lda	#TILE_NO_DROP|TILE_CLIMBABLE
	sta	zp_02
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	asl	a
	clc
	adc	#$4402
	tay
	lda	#$000A
	jml	f:fill_wram_words
@draw_cable:
	lda	OBJ_TIMER,x
	bit	#$0007
	bne	@return
	lda	#$0001
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4200
	ldy	$30,x
	phx
	jsl	f:queue_vram_blocks
	plx
	clc
	lda	$30,x
	adc	#$0006
	sta	$30,x
@return:
	rtl

stage3_robot_cables_state_03:
	lda	OBJ_SPRITE,x
	bne	@return
	inc	OBJ_STATE,x
	lda	#$0010
	sta	OBJ_TIMER,x
	lda	#.loword(vram_blocks_05E7DA)
	sta	$30,x
@return:
	rtl

stage3_robot_cables_state_04:
	dec	OBJ_TIMER,x
	bpl	@draw_cable
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@draw_cable:
	lda	OBJ_TIMER,x
	bit	#$0007
	bne	@return
	lda	#$0002
	sta	zp_02
	lda	#$0010
	sta	zp_08
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4090
	ldy	$30,x
	phx
	jsl	f:queue_vram_blocks
	plx
	clc
	lda	$30,x
	adc	#$0004
	sta	$30,x
@return:
	rtl

stage3_cables_crush_player:
	lda	a:$0016,y
	beq	@return
	bmi	@return
	lda	a:$000A,y
	cmp	#$000D
	bcs	@return
	lda	#$0004
	sta	a:$003C,y
@return:
	rts

stage3_robot_pick_direction:
	lda	#$0400
	jsl	f:pick_target_player
	lda	a:boss_work_0
	and	#$0300
	beq	@random
	stz	zp_00
	sec
	lda	a:$000A,y
	sbc	OBJ_X,x
	bpl	@store_dx
	eor	#$FFFF
	inc	zp_00
	inc	zp_00
@store_dx:
	sta	zp_04
	sec
	lda	a:$000E,y
	sbc	OBJ_Y,x
	bpl	@store_dy
	eor	#$FFFF
@store_dy:
	sta	zp_06
	rts
@random:
	lda	rng_lo
	and	#$00FF
	sta	zp_06
	lda	rng_hi
	and	#$00FF
	sta	zp_04
	and	#$0002
	sta	zp_00
	rts

stage3_second_robot_spawn_debris:
	lda	stage_frame_mod4
	bne	@return
	ldy	#$0800
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#$0046
	sta	a:$0010,y
	lda	#$3800
	sta	a:$0002,y
	lda	#$000F
	sta	a:$0016,y
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$FFE6
	sta	a:$000E,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4	; [num]
	sta	a:$002A,y
	phx
	tya
	ldy	$04,x
	tax
	lda	a:stage3_second_robot_debris_sprites,y
	sta	$00,x
	lda	a:stage3_second_robot_debris_x_offsets,y
	clc
	adc	zp_00
	sta	$0A,x
	lda	stage_frame_counter
	bit	#$0010
	beq	@add_dir
	eor	#$FFFF
@add_dir:
	and	#$000E
	clc
	adc	a:stage3_second_robot_debris_dirs,y
	tay
	lda	a:vel8_y_sub,y
	sta	$1C,x
	lda	a:vel8_y,y
	sta	$1E,x
	lda	a:vel8_x_sub,y
	sta	$18,x
	lda	a:vel8_x,y
	sta	$1A,x
	plx
	lda	stage_frame_mod8
	bne	@return
	lda	#$001A
	jsl	f:queue_sound
@return:
	rts

stage3_boss_check_hp:
	lda	$38,x
	bne	@phase_2
	lda	OBJ_HP,x
	bpl	@return
	lda	OBJ_STATE,x
	cmp	#$0002
	bne	@return
	lda	#$0007
	sta	OBJ_STATE,x
	lda	#ENEMY_HP($0030)
	sta	OBJ_HP,x
@start_explosion:
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$0080
	sta	OBJ_TIMER,x
	stz	OBJ_ANIM,x
	stz	$30,x
	stz	OBJ_FACING,x
	inc	$38,x
@return:
	rts
@phase_2:
	cmp	#$0002
	bcs	@phase_3
	lda	OBJ_HP,x
	bmi	@become_skeleton
	bpl	@return
@become_skeleton:
	inc	OBJ_STATE,x
	lda	#ENEMY_HP($0400)
	sta	OBJ_HP,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	bra	@start_explosion
@phase_3:
	lda	OBJ_HP,x
	bpl	@return
	lda	#$0016
	sta	OBJ_STATE,x
	lda	#$0004
	sta	$36,x
	stz	$34,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_HP,x
	jsl	f:make_players_invulnerable
	rts

toggle_sprite_visible:
	lda	$30,x
	beq	@hide
	lda	$30,x
	sta	OBJ_SPRITE,x
	stz	$30,x
	bra	@return
@hide:
	lda	OBJ_SPRITE,x
	sta	$30,x
	stz	OBJ_SPRITE,x
@return:
	rts

stage3_boss_state_0A:
	lda	a:obj_slots+27*OBJ_SIZE+OBJ_TYPE
	bne	stage3_boss_return
	dec	OBJ_TIMER,x
	bne	stage3_boss_return
	lda	#.loword(song_set_boss)
	sta	a:song_change_set
	lda	#$0004
	sta	a:song_change_mode
	lda	#$0004
	sta	a:shake_timer
	inc	OBJ_STATE,x
stage3_boss_return:
	rtl

stage3_boss_state_0B:
	lda	a:song_change_state
	bne	stage3_boss_return
	lda	#$0068
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	lda	#$0100
	sta	a:bg2_y
	stz	a:boss_work_3
	stz	a:boss_work_1
	lda	#$0002
	sta	a:boss_work_2
	lda	#$00A2
	sta	a:boss_work_4
	lda	#$0030
	sta	$30,x
	lda	#$0008
	sta	$32,x
	lda	#$0068
	sta	OBJ_X,x
	lda	#$0080
	sta	OBJ_Y,x
	lda	#$0028
	sta	OBJ_HITBOX_W,x
	lda	#$FFC8	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_FLAGS,x
	phx
	ldx	#.loword(load_list_05EB45)
	jsl	f:load_data_list
	plx
	lda	#$0004
	jsl	f:start_palette_anim
	rtl

stage3_boss_state_0C:
	dec	$30,x
	bne	@return
	dec	$32,x
	dec	$32,x
	bpl	@draw_step
	inc	OBJ_STATE,x
	lda	#$004E
	jml	f:queue_sound
@draw_step:
	lda	#$0002
	sta	zp_02
	lda	#$0010
	sta	zp_08
	lda	$32,x
	tay
	asl	a
	clc
	adc	#.loword(vram_blocks_05EB21)
	pha
	lda	a:stage3_boss_state_0C_delays,y
	sta	$30,x
	tya
	lsr	a
	and	#$0002
	tay
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	a:stage3_boss_state_0C_vram_addrs,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#$004D
	jsl	f:queue_sound
@return:
	rtl

stage3_boss_state_0D:
	jsr	a:stage3_boss_break_wall
	dec	a:boss_work_4
	bne	@check_palette
	stz	$34,x
	stz	$36,x
	lda	#$4010
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	rtl
@check_palette:
	lda	a:boss_work_4
	cmp	#$0040
	bcc	@return
	phx
	ldy	#.loword(palette_task_05CD35)
	ldx	#$1210
	jsl	f:start_palette_task_at
	plx
@return:
	rtl

stage3_boss_state_17:
	lda	#$0070
	sta	OBJ_X,x
	lda	#$0080
	sta	OBJ_Y,x
	lda	#$3400
	sta	OBJ_ATTR,x
	lda	#.loword(metasprite_06C257)
	sta	OBJ_SPRITE,x
	inc	OBJ_STATE,x
	rtl

stage3_boss_state_18:
	stz	a:boss_work_2
	jsr	a:stage3_boss_break_wall
	lda	a:boss_work_1
	bne	@palette
	lda	#$0083
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	lda	#$0100
	sta	a:stage_exit_request
	lda	#$001F
	sta	$34,x
	lda	#$001F
	sta	$36,x
@palette:
	brl	stage3_boss_maybe_start_palette

stage3_boss_state_19:
	lda	#$006D
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	rtl

stage3_boss_state_1A:
	stz	a:boss_work_2
	jsr	a:stage3_boss_break_wall
	lda	OBJ_Y,x
	bmi	@gravity
	cmp	#$00D8
	bcc	@gravity
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
@gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	#$0001
	sta	a:shake_continuous
	jml	f:spawn_explosion_near_object

stage3_boss_state_16:
	jsl	f:queue_sound_6E_throttled
	lda	#$0003
	sta	a:shake_timer
	lda	#$00C0
	sta	zp_02
	lda	#$0038
	sta	zp_00
	lda	#$007F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	stage3_boss_state_0E
	lda	#$FFFD	; [num]
	sta	a:$001E,y

stage3_boss_state_0E:
	ldy	$36,x
	lda	$34,x
	cmp	a:stage3_boss_state_0E_limits,y
	bcs	@limit_reached
	lda	a:stage3_boss_state_0E_steps,y
	bra	@step
@limit_reached:
	lda	#$0060
	sta	$3E,x
	inc	OBJ_STATE,x
	rtl
@step:
	clc
	adc	$34,x
	sta	$34,x
	and	#$0020
	bne	@frame_0
	lda	#$000C
	bra	@queue_tiles
@frame_0:
	lda	#$0000
@queue_tiles:
	jsr	a:stage3_boss_queue_tiles
	rtl

stage3_boss_state_0F:
	stz	$34,x
	lda	#$0000
	jsr	a:stage3_boss_queue_tiles
	dec	$3E,x
	bne	@fire_eyes
	inc	OBJ_STATE,x
	stz	$36,x
@fire_eyes:
	lda	$3E,x
	cmp	#$0040
	bne	@return
	lda	#$006C
	jsr	a:spawn_skeleton_eye_fireball
	lda	#$0084
	jsr	a:spawn_skeleton_eye_fireball
@return:
	rtl

stage3_boss_state_11:
	jsr	a:queue_sound_35_every_32
	dec	$3E,x
	bne	@spawn_explosion
	inc	OBJ_STATE,x
	stz	$30,x
	lda	#$003E
	sta	$32,x
	rtl
@spawn_explosion:
	lda	#$0084
	sta	zp_02
	lda	#$0070
	sta	zp_00
	lda	#$000F
	sta	zp_04
	lda	#$0000
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C5B8)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$0002
	sta	a:$001E,y
@return:
	rtl

stage3_boss_state_12:
	jsr	a:queue_sound_35_every_32
	jsr	a:stage3_boss_spawn_debris_sparks
	lda	stage_frame_counter
	and	#$0004
	beq	@queue_tiles
	lda	#$000C
@queue_tiles:
	jsr	a:stage3_boss_queue_tiles
	lda	$32,x
	cmp	#$0144
	bcc	@return
	lda	#$0013
	sta	OBJ_STATE,x
	lda	#$0002
	sta	$36,x
	stz	$34,x
@return:
	rtl

stage3_boss_state_14:
	stz	$34,x
	lda	stage_frame_counter
	and	#$0004
	beq	@queue_tiles
	lda	#$000C
@queue_tiles:
	jsr	a:stage3_boss_queue_tiles
	dec	$3E,x
	dec	$3E,x
	bne	@return
	inc	OBJ_STATE,x
	lda	#$0080
	sta	$3E,x
	stz	OBJ_FLAGS,x
	lda	#$0006
	sta	zp_FE
	lda	#$0800
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	sec
	sbc	#$0018
	and	#$007E
	sta	zp_FC
@loop:
	lda	zp_FC
	jsr	a:spawn_countdown_bomb
	clc
	lda	zp_FC
	adc	#$0008
	and	#$007E
	sta	zp_FC
	dec	zp_FE
	bne	@loop
@return:
	rtl

stage3_boss_state_15:
	dec	$3E,x
	bne	@break_wall
	lda	#$00A2
	sta	a:boss_work_4
	lda	#$0002
	sta	a:boss_work_2
	lda	#$000D
	sta	OBJ_STATE,x
	lda	#$004E
	jml	f:queue_sound
@break_wall:
	stz	a:boss_work_2
	jsr	a:stage3_boss_break_wall
stage3_boss_maybe_start_palette:
	lda	a:boss_work_1
	cmp	#$0004
	bne	@return
	phx
	ldy	#.loword(palette_task_05CD3B)
	ldx	#$1210
	jsl	f:start_palette_task_at
	plx
@return:
	rtl

stage3_boss_break_wall:
	lda	#$0003
	sta	a:shake_timer
	phx
	lda	a:boss_work_1
	asl	a
	tay
	lda	a:boss_work_3
	cmp	#$0003
	bcs	@step_timer
	cpy	#$000E
	bcc	@queue_wall
	cmp	#$0000
	beq	@step_timer
@queue_wall:
	ldx	#$0001
	stx	zp_02
	ldx	#$0020
	stx	zp_08
	asl	a
	tax
	tya
	asl	a
	asl	a
	asl	a
	clc
	adc	a:ptrs_stage3_boss_wall_blocks,x
	tay
	clc
	adc	#$0008
	sta	zp_FE
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	pha
	clc
	adc	a:stage3_boss_wall_vram_addrs_b,x
	sta	zp_FC
	pla
	clc
	adc	a:stage3_boss_wall_vram_addrs_a,x
	jsl	f:queue_vram_blocks
	ldx	#$0001
	stx	zp_02
	ldx	#$0040
	stx	zp_08
	lda	zp_FC
	ldy	zp_FE
	jsl	f:queue_vram_blocks
@step_timer:
	inc	a:boss_work_3
	ldy	a:boss_work_2
	lda	a:boss_work_3
	cmp	a:stage3_boss_wall_step_delays,y
	bcc	@done
	stz	a:boss_work_3
	clc
	lda	a:boss_work_1
	adc	a:stage3_boss_wall_step_dirs,y
	bpl	@not_negative
	stz	a:boss_work_1
	bra	@done
@not_negative:
	cmp	#$0008
	bcc	@store_step
	lda	#$0008
@store_step:
	sta	a:boss_work_1
@done:
	plx
	rts

queue_sound_35_every_32:
	lda	stage_frame_counter
	bit	#$001F
	bne	@return
	lda	#$0035
	jsl	f:queue_sound
@return:
	rts

stage3_boss_spawn_debris_sparks:
	ldy	difficulty
	clc
	lda	$30,x
	adc	a:stage3_boss_debris_rates,y
	sta	$30,x
	lda	$32,x
	adc	#$0000
	sta	$32,x
	lda	stage_frame_mod4
	bne	@return
	phx
	lda	$32,x
	and	#$007E
	pha
	clc
	adc	#$0004
	sta	$34,x
	pla
	tax
	ldy	#$08C0
	jsl	f:find_free_slot_y_down
	bcc	@no_slot
	lda	#.loword(anim_05EB37)
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$004B
	sta	a:$0010,y
	lda	#$000F
	sta	a:$0016,y
	lda	#$000C
	sta	a:$0028,y
	lda	#$FFF4	; [num]
	sta	a:$002A,y
	lda	a:vel8_y,x
	sta	a:$001E,y
	lda	a:vel8_x,x
	sta	a:$001A,y
	lda	a:vel8_y_sub,x
	sta	a:$001C,y
	lda	a:vel8_x_sub,x
	sta	a:$0018,y
	txa
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	tax
	lda	a:stage3_boss_debris_x,x
	and	#$00FF
	sta	a:$000A,y
	lda	#$0082
	sta	a:$000E,y
@no_slot:
	plx
@return:
	rts

stage3_boss_queue_tiles:
	pha
	lda	#$0002
	sta	zp_02
	lda	#$0030
	sta	zp_08
	lda	$34,x
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	pla
	clc
	adc	a:ptrs_stage3_boss_tile_frames,y
	tay
	lda	#$4D0C
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

spawn_countdown_bomb:
	phx
	tax
	ldy	#$0300
	jsl	f:find_free_slot_from_y
	bcs	@done
	lda	a:vel8_y,x
	sta	a:$001E,y
	lda	a:vel8_x,x
	sta	a:$001A,y
	lda	a:vel8_y_sub,x
	sta	a:$001C,y
	lda	a:vel8_x_sub,x
	sta	a:$0018,y
	txa
	clc
	adc	#$004A
	and	#$0070
	sta	a:$0032,y
	lda	#$0080
	sta	a:$000A,y
	lda	#$0090
	sta	a:$000E,y
	lda	#.loword(metasprite_06C218)
	sta	a:$0000,y
	sta	a:$0034,y
	lda	#$3800
	sta	a:$0002,y
	lda	#OBJT_COUNTDOWN_BOMB
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	#.loword(anim_05EB5A)
	sta	a:$0020,y
@done:
	plx
	rts

; Object type $4C. Stage 3, skeleton robot: numbered bombs ("3", "2", "1")
; that stick to the walls of the room and explode.
update_countdown_bomb:
	lda	OBJ_STATE,x
	bne	@counting
	lda	#$FFE8	; [num]
	sta	zp_02
	lda	#$0018
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bne	@stick
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bne	@stick
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bne	@stick
	lda	#$0018
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	beq	@return
@stick:
	lda	OBJ_Y,x
	and	#$FFF8
	sta	OBJ_Y,x
	lda	OBJ_X,x
	and	#$FFF8
	sta	OBJ_X,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	inc	OBJ_STATE,x
@return:
	rtl
@counting:
	cmp	#$0002
	beq	@exploding
	lda	OBJ_SPRITE,x
	cmp	$34,x
	beq	@wait_anim
	sta	$34,x
	lda	#$0036
	jsl	f:queue_sound
@wait_anim:
	lda	OBJ_ANIM,x
	bne	@return2
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x
@return2:
	rtl
@exploding:
	dec	OBJ_TIMER,x
	bne	@explode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@explode:
	lda	#$0030
	jsl	f:queue_sound_throttled
	lda	stage_frame_mod4
	bne	@return3
	ldy	#$0280
	jsl	f:find_free_slot_y_to_end
	bcs	@return3
	lda	#.loword(anim_05C51C)
	sta	a:$0020,y
	lda	#$001D
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8	; [num]
	sta	a:$002A,y
	lda	rng_lo
	inc	rng_lo
	and	#$001F
	pha
	adc	OBJ_X,x
	sta	a:$000A,y
	pla
	adc	OBJ_Y,x
	sta	a:$000E,y
	phx
	lda	rng_hi
	dec	rng_hi
	and	#$001F
	eor	#$FFFF
	adc	$32,x
	and	#$007E
	tax
	lda	a:vel8_y,x
	sta	a:$001E,y
	lda	a:vel8_x,x
	sta	a:$001A,y
	lda	a:vel8_y_sub,x
	sta	a:$001C,y
	lda	a:vel8_x_sub,x
	sta	a:$0018,y
	plx
@return3:
	rtl

spawn_skeleton_eye_fireball:
	sta	zp_FC
	jsl	f:find_free_slot_y
	bcs	@return
	lda	#OBJT_SKELETON_EYE_FIREBALL
	sta	a:$0010,y
	lda	zp_FC
	sta	a:$000A,y
	phx
	tyx
	lda	#$0001
	sta	zp_00
	lda	#$000A
	sta	zp_04
	lda	#$0005
	ldy	#$0380
	jsl	f:spawn_trail_chain
	plx
@return:
	rts

; Object type $87. Stage 3, skeleton robot: fireballs from its eyes.
update_skeleton_eye_fireball:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_skeleton_eye_fireball_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_skeleton_eye_fireball_states:
	.addr	skeleton_eye_fireball_state_00
	.addr	skeleton_eye_fireball_state_01
	.addr	skeleton_eye_fireball_state_02

skeleton_eye_fireball_state_00:
	inc	OBJ_STATE,x
	lda	#.loword(anim_05C6BA)
	sta	OBJ_ANIM,x
	lda	#$000D
	sta	OBJ_FLAGS,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$3000
	sta	OBJ_ATTR,x
	lda	#$0074
	sta	OBJ_Y,x
	ldy	difficulty
	lda	a:skeleton_eye_fireball_delays,y
	sta	OBJ_TIMER,x
	rtl

skeleton_eye_fireball_state_01:
	lda	OBJ_ANIM,x
	bne	@blink
	inc	OBJ_STATE,x
	lda	rng_lo
	adc	OBJ_X,x
	and	#$000F
	adc	#$0010
	sta	$36,x
	lda	#$0800
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:skeleton_eye_fireball_sprites,y
	sta	OBJ_SPRITE,x
	lda	a:skeleton_eye_fireball_x_vels,y
	sta	OBJ_X_VEL,x
	lda	a:skeleton_eye_fireball_y_vels,y
	sta	OBJ_Y_VEL,x
@blink:
	bra	skeleton_eye_fireball_blink

skeleton_eye_fireball_state_02:
	dec	OBJ_TIMER,x
	bpl	@move
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	jml	f:delete_trail_chain
@move:
	dec	$36,x
	bpl	skeleton_eye_fireball_blink
	dec	OBJ_STATE,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL,x
	lda	#.loword(anim_05C636)
	sta	OBJ_ANIM,x
skeleton_eye_fireball_blink:
	lda	stage_frame_bit1
	bne	@trail
	lda	OBJ_ATTR,x
	eor	#$0E00
	sta	OBJ_ATTR,x
@trail:
	jml	f:trail_pass_to_next

; Object type $64. Stage 4: invisible controller present for the whole stage
; (position 0,0, 32 states): drives the hover-bike scenes, the airship, the
; helicopter and the boss.
update_stage4_controller:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage4_controller_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage4_controller_states:
	.addr	stage4_controller_state_00
	.addr	stage4_controller_state_01
	.addr	stage4_controller_state_02
	.addr	stage4_controller_state_03
	.addr	stage4_controller_state_04
	.addr	stage4_controller_state_05
	.addr	stage4_controller_state_06
	.addr	stage4_controller_state_07
	.addr	stage4_controller_state_08
	.addr	stage4_controller_state_09
	.addr	stage4_controller_state_0A
	.addr	stage4_controller_state_0B
	.addr	stage4_controller_state_0C
	.addr	stage4_controller_state_0D
	.addr	stage4_controller_state_0E
	.addr	stage4_controller_state_0F
	.addr	stage4_controller_state_10
	.addr	stage4_controller_state_11
	.addr	stage4_controller_state_12
	.addr	stage4_controller_state_13
	.addr	stage4_controller_state_14
	.addr	stage4_controller_state_15
	.addr	stage4_controller_state_16
	.addr	stage4_controller_state_17
	.addr	stage4_controller_state_18
	.addr	stage4_controller_state_19
	.addr	stage4_controller_state_1A
	.addr	stage4_controller_state_1B
	.addr	stage4_controller_state_1C
	.addr	stage4_controller_state_1D
	.addr	stage4_controller_state_1E
	.addr	stage4_controller_state_1F

stage4_controller_state_00:
	lda	#$0100
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	stz	a:clear_enemies_timer
	lda	#$0018
	sta	$34,x
	lda	#$0080
	sta	$38,x
	rtl

stage4_controller_state_01:
	dec	OBJ_TIMER,x
	bpl	@check_rider
	inc	OBJ_STATE,x
	lda	#$0063
	jsl	f:queue_sound
	stz	OBJ_TIMER,x
@check_rider:
	lda	OBJ_TIMER,x
	cmp	#$0090
	bne	@scroll
	jsr	a:stage4_spawn_passing_rider
	lda	#$0060
	sta	a:$000E,y
	lda	#$3600
	sta	a:$0002,y
	lda	#$0074
	sta	a:$0010,y
	lda	#$0005
	sta	a:$0012,y
	lda	#.loword(metasprite_06C6EB)
	sta	a:$0000,y
	lda	#$0004
	sta	a:$001A,y
@scroll:
	jsr	a:scroll_bg1_bg2_right_16
	rtl

stage4_controller_state_03:
	jsr	a:stage4_spawn_weapon_capsule
	jsr	a:stage4_spawn_passing_rider_every_8

stage4_controller_state_02:
	dec	OBJ_TIMER,x
	bpl	@scroll
	lda	#$00C0
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@scroll:
	jsr	a:scroll_bg1_bg2_right_16
	rtl

stage4_controller_state_04:
	jsr	a:stage4_spawn_hoverbike_rider
	jsr	a:scroll_bg1_bg2_right_16
	rtl

stage4_controller_state_05:
	jsr	a:scroll_bg1_bg2_right_16
	lda	a:bg1_x
	and	#$00FF
	cmp	#$0010
	bne	@return
	stz	a:bg1_x
	lda	#$0041
	sta	a:bg1sc_shadow
	lda	#$000A
	sta	hdma_preset
	lda	#$51A0
	sta	zp_00
	lda	#$4018
	jsl	f:queue_vram_block
	lda	#$0001
	sta	zp_02
	lda	#$0030
	sta	zp_08
	lda	#$401C
	ldy	#.loword(vram_blocks_05ECC6)
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	OBJ_STATE,x
	lda	#$0010
	sta	a:bg1_x
	sta	a:bg1_x+BG_HOFS_LATCH
	jml	f:wobble_stage4_line_scroll
@return:
	rtl

stage4_controller_state_06:
	lda	a:bg1_x
	clc
	adc	#$0010
	and	#$00FF
	bne	@store_x
	inc	OBJ_STATE,x
	lda	#$4000
	sta	$34,x
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0100
@store_x:
	sta	a:bg1_x
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_07:
	lda	#$0008
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	$34,x
	ldy	#.loword(vram_blocks_05946A)
	phx
	jsl	f:queue_vram_blocks
	plx
	clc
	lda	$34,x
	adc	#$0080
	sta	$34,x
	cmp	#$4300
	bcc	@wobble
	inc	OBJ_STATE,x
	stz	a:bg1_x
@wobble:
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_08:
	dec	OBJ_TIMER,x
	bpl	@wobble
	lda	#$0140
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@wobble:
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0A:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	bne	stage4_controller_drop_soldiers
	lda	#$0002
	sta	a:clear_enemies_timer
	inc	OBJ_STATE,x
	rtl

stage4_controller_state_09:
	dec	OBJ_TIMER,x
	bpl	stage4_controller_drop_soldiers
	inc	OBJ_STATE,x
	lda	#$006E
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
stage4_controller_drop_soldiers:
	jsr	a:stage4_spawn_dropping_soldier
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0B:
	phx
	ldx	#.loword(load_list_05ECD9)
	jsl	f:load_data_list
	plx
	lda	#$FFFC	; [num]
	sta	a:bg1_vel_x
	lda	#$8000	; [num]
	sta	a:bg1_vel_x_sub
	lda	#$0005
	sta	a:bg1_scroll_mode
	lda	#$0008
	sta	a:bg1_x+BG_COLUMN_OFFSET
	lda	#$0B80
	sta	a:bg1_x
	stz	OBJ_TIMER,x
	stz	$36,x
	inc	OBJ_STATE,x
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0C:
	ldy	OBJ_TIMER,x
	lda	a:bg1_x
	cmp	#$01E0
	bcs	@check_waypoint
	lda	#$0040
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@check_waypoint:
	cmp	a:stage4_scroll_waypoints_x,y
	bcs	@adjust_speed
	inc	OBJ_TIMER,x
	inc	OBJ_TIMER,x
@adjust_speed:
	lda	a:bg1_vel_x_sub+1
	cmp	a:stage4_scroll_target_speeds,y
	beq	@vertical
	bmi	@speed_up
	sec
	lda	a:bg1_vel_x_sub
	sbc	#$0800
	sta	a:bg1_vel_x_sub
	lda	a:bg1_vel_x
	sbc	#$0000
	sta	a:bg1_vel_x
	bra	@vertical
@speed_up:
	clc
	lda	a:bg1_vel_x_sub
	adc	#$0800
	sta	a:bg1_vel_x_sub
	lda	a:bg1_vel_x
	adc	#$0000
	sta	a:bg1_vel_x
@vertical:
	ldy	$36,x
	bne	@sink
	lda	a:bg1_y
	cmp	#$000C
	bcs	@check_rise_speed
	inc	$36,x
@check_rise_speed:
	lda	a:bg1_vel_y_sub+1
	bpl	@accel_up
	cmp	#$FF80	; [num]
	bcc	@scroll
@accel_up:
	sec
	lda	a:bg1_vel_y_sub
	sbc	#$0400
	sta	a:bg1_vel_y_sub
	lda	a:bg1_vel_y
	sbc	#$0000
	sta	a:bg1_vel_y
	bra	@scroll
@sink:
	lda	a:bg1_y
	bmi	@check_sink_speed
	cmp	#$0010
	bcc	@check_sink_speed
	stz	$36,x
@check_sink_speed:
	lda	a:bg1_vel_y_sub+1
	bmi	@accel_down
	cmp	#$0080
	bcs	@scroll
@accel_down:
	clc
	lda	a:bg1_vel_y_sub
	adc	#$0400
	sta	a:bg1_vel_y_sub
	lda	a:bg1_vel_y
	adc	#$0000
	sta	a:bg1_vel_y
@scroll:
	jsl	f:scroll_bg1_by_velocity_and_spawn
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0D:
	dec	OBJ_TIMER,x
	bpl	@wobble
	lda	#$0079
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	lda	#$0001
	sta	a:stage_checkpoint
	inc	OBJ_STATE,x
@wobble:
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0E:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	cmp	#$0079
	beq	@wobble
	inc	OBJ_STATE,x
	lda	#$0100
	sta	OBJ_TIMER,x
	phx
	ldx	#.loword(load_list_05ECD0)
	jsl	f:load_data_list
	plx
@wobble:
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_0F:
	dec	OBJ_TIMER,x
	bpl	@spawn_capsule
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	#$0084
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	lda	#$0004
	sta	a:bg1_scroll_mode
@spawn_capsule:
	jsr	a:stage4_spawn_weapon_capsule
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_10:
	inc	OBJ_STATE,x
	ldy	#$0800
	lda	#OBJT_RIDEABLE_MISSILE
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	#$0002
	sta	a:$0034,y
	lda	#.loword(anim_05EBB8)
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0001
	sta	a:$001A,y
	lda	#$FF80	; [num]
	sta	a:$000A,y
	stz	a:bg1_y
	jml	f:update_stage4_line_scroll

stage4_controller_state_11:
	sec
	lda	#$0140
	sbc	a:obj_slots+24*OBJ_SIZE+OBJ_X
	sta	a:bg1_x
	lda	a:obj_slots+24*OBJ_SIZE+OBJ_X
	bmi	@wobble
	cmp	#$0040
	bcc	@wobble
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_X_VEL
	inc	OBJ_STATE,x
	lda	#$0006
	sta	a:respawn_mode
@wobble:
	jml	f:wobble_stage4_line_scroll

stage4_controller_state_12:
	lda	a:p1_lives
	beq	@check_p2
	lda	a:player1_state
	cmp	#$0001
	bne	@line_scroll
@check_p2:
	lda	a:title_menu_cursor
	beq	@next_state
	lda	a:p2_lives
	beq	@next_state
	lda	a:player2_state
	cmp	#$0001
	bne	@line_scroll
@next_state:
	inc	OBJ_STATE,x
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_ANIM_TIMER
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_SPRITE
	lda	#$000B
	sta	a:bg2_scroll_mode
	stz	$30,x
@line_scroll:
	jml	f:update_stage4_line_scroll

stage4_controller_state_13:
	jsl	f:update_stage4_line_scroll
	bra	stage4_controller_follow_slot_24

stage4_controller_state_14:
	lda	a:bg2_y
	cmp	#$FE00	; [num]
	bne	stage4_controller_follow_slot_24
	lda	#$000A
	sta	a:bg2_scroll_mode
	inc	OBJ_STATE,x
stage4_controller_follow_slot_24:
	lda	a:bg1_y
	cmp	#$0010
	beq	@stop
	lda	#$C000	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	#$FFFF	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL
	sec
	lda	#$0078
	sbc	a:obj_slots+24*OBJ_SIZE+OBJ_Y
	sta	a:bg1_y
	rtl
@stop:
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL
	rtl

stage4_controller_state_15:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	cmp	#$0084
	beq	stage4_controller_state_15_return
	lda	#.loword(anim_05C558)
	sta	a:boss_work_0
	inc	OBJ_STATE,x
stage4_controller_state_15_return:
	rtl

stage4_controller_state_16:
	lda	stage_frame_odd
	beq	stage4_controller_state_15_return
	inc	OBJ_STATE,x
	lda	#$4200
	jsr	a:stage4_queue_tiles
	lda	#$000B
	sta	hdma_preset
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0030
	sta	a:$3800
	lda	#$1001
	sta	a:$3802
	lda	#$0100
	sta	a:$3806
	sta	a:$3810
	lda	#$0001
	sta	a:$3816
	lda	#$0010
	sta	a:$3808
	stz	a:$3812
	stz	a:$3818
	lda	#$3000
	sta	a:$380C
	lda	#$1F00
	sta	a:$3804
	sta	a:$380E
	lda	#$001F
	sta	a:$380A
	sta	a:$3814
	sta	a:$3820
	lda	#$7F00
	sta	a:$3822
	stz	a:$3826
	lda	a:bg2_x
	sta	a:$3824
	lda	a:bg2_x_sub
	sta	a:bg2_x_sub
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	lda	#$0180
	sta	a:bg2_map_offset
	lda	#$0001
	sta	a:bg2_scroll_mode
	stz	a:bg2_screen_drawn
	lda	#$0015
	sta	a:tm_shadow
	lda	#$2000
	sta	a:bg3_x+BG_X_DELTA_SUB
	lda	#$0001
	sta	a:bg3_x+BG_X_DELTA
	rtl

stage4_controller_state_17:
	lda	a:bg2_screen_drawn
	beq	@scroll_bg3
	inc	OBJ_STATE,x
	stz	a:bg2_scroll_mode
	lda	#$0002
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_STATE
	lda	#$FFFC	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_X_VEL
	lda	#$0001
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL
	lda	#$0050
	jsl	f:queue_sound
	phx
	ldx	#.loword(load_list_05ECD0)
	jsl	f:load_data_list
	plx
@scroll_bg3:
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_18:
	lda	stage_frame_odd
	beq	stage4_controller_state_19_return
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x

stage4_controller_state_19:
	dec	OBJ_TIMER,x
	bne	@queue_blocks
	inc	OBJ_STATE,x
	lda	#$0017
	sta	a:tm_shadow
	lda	#$0049
	sta	a:bg2sc_shadow
	lda	#$0069
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
@queue_blocks:
	lda	#$0004
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#.loword(vram_blocks_05EC34)
	lda	#$4588
	phx
	jsl	f:queue_vram_blocks
	plx
	jsr	a:stage4_scroll_bg3_lower
stage4_controller_state_19_return:
	rtl

stage4_controller_state_1A:
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_1B:
	lda	#$0001
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	stz	a:player1_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player2_obj+PLAYER_BOMB_SPEED_SUB
	lda	#$000C
	sta	a:player1_obj+PLAYER_BOMB_SPEED
	sta	a:player2_obj+PLAYER_BOMB_SPEED
	lda	#$00D8
	sta	a:player1_obj+PLAYER_BOMB_X
	sta	a:player2_obj+PLAYER_BOMB_X
	lda	#$0080
	sta	a:player1_obj+PLAYER_BOMB_Y
	sta	a:player2_obj+PLAYER_BOMB_Y
	lda	#$001F
	sta	a:bomb_coldata_bits
	lda	#$00FF
	sta	a:bomb_coldata_mask
	inc	OBJ_STATE,x
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_1C:
	lda	#$00E0
	cmp	a:player1_obj+PLAYER_BOMB_RADIUS
	bcs	@scroll_bg3
	lda	#$00FE
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	stz	a:player1_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player2_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player1_obj+PLAYER_BOMB_SPEED
	stz	a:player2_obj+PLAYER_BOMB_SPEED
	lda	#$005B
	jsl	f:queue_sound
	lda	#$0002
	sta	a:life_transfer_disabled
	lda	#$0080
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	#$0003
	sta	a:player_autopilot_mode
	lda	#$FFD8	; [num]
	sta	a:bg1_y
	lda	#$4580
	jsr	a:stage4_queue_tiles
	lda	#$000C
	sta	hdma_preset
	lda	#$8000	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_FLAGS
	lda	#$0008
	sta	a:obj_slots+23*OBJ_SIZE+OBJ_STATE
	stz	a:obj_slots+23*OBJ_SIZE+OBJ_X_VEL
	lda	#$4000
	sta	a:obj_slots+23*OBJ_SIZE+OBJ_X_VEL_SUB
	lda	#$00A0
	sta	a:obj_slots+23*OBJ_SIZE+OBJ_Y
	lda	#$0000
	sta	a:obj_slots+23*OBJ_SIZE+OBJ_X
	phx
	ldx	#$0200
	jsr	a:stage4_reposition_player
	ldx	#$0240
	jsr	a:stage4_reposition_player
	plx
@scroll_bg3:
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_1D:
	dec	OBJ_TIMER,x
	bpl	@hold_bomb
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
@hold_bomb:
	lda	#$00FE
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	stz	a:player1_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player2_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player1_obj+PLAYER_BOMB_SPEED
	stz	a:player2_obj+PLAYER_BOMB_SPEED
	bra	stage4_controller_move_bomb_left

stage4_controller_state_1E:
	dec	OBJ_TIMER,x
	bpl	stage4_controller_state_1F
	inc	OBJ_STATE,x
	lda	#$0100
	sta	a:stage_exit_request

stage4_controller_state_1F:
	sec
	lda	a:player1_obj+PLAYER_BOMB_RADIUS
	sbc	#$0004
	bpl	@store_radius
	lda	#$0000
@store_radius:
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	lda	stage_frame_odd
	bne	stage4_controller_move_bomb_left
	lda	a:player1_obj+PLAYER_BOMB_Y
	inc	a
	sta	a:player1_obj+PLAYER_BOMB_Y
	sta	a:player2_obj+PLAYER_BOMB_Y
stage4_controller_move_bomb_left:
	lda	a:player1_obj+PLAYER_BOMB_X
	dec	a
	sta	a:player1_obj+PLAYER_BOMB_X
	sta	a:player2_obj+PLAYER_BOMB_X
	stz	a:player1_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player2_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player1_obj+PLAYER_BOMB_SPEED
	stz	a:player2_obj+PLAYER_BOMB_SPEED
	rtl

; Object type $65. Stage 4 (sky section) and the ending: the missiles the
; players stand on and jump between; in the ending, the missile under the
; helicopter (slot $0280).
update_rideable_missile:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_rideable_missile_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_rideable_missile_states:
	.addr	rideable_missile_state_00
	.addr	rideable_missile_state_01
	.addr	rideable_missile_state_02
	.addr	rideable_missile_state_03
	.addr	rideable_missile_state_04
	.addr	rideable_missile_state_05
	.addr	rideable_missile_state_06
	.addr	rideable_missile_state_07
	.addr	rideable_missile_state_08

rideable_missile_state_00:
	lda	#$FF80	; [num]
	sta	OBJ_X,x
	lda	#$0078
	sta	OBJ_Y,x
	inc	OBJ_STATE,x
	bra	init_rideable_missile

; Turns the slot at X into a rideable missile (type $65, state 7, 120 pixels
; wide platform).
make_rideable_missile:
	sty	$34,x
	lda	#OBJT_RIDEABLE_MISSILE
	sta	OBJ_TYPE,x
	lda	#$0007
	sta	OBJ_STATE,x
	stz	OBJ_X_VEL,x
init_rideable_missile:
	lda	#$0078
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	$3A,x
	stz	$3E,x
	stz	$38,x
	stz	$36,x
	stz	$30,x
	stz	$32,x
	rtl

rideable_missile_state_02:
	sec
	lda	OBJ_Y_VEL_SUB,x
	sbc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	bne	@accelerate
	lda	OBJ_Y_VEL_SUB,x
	bne	@accelerate
	inc	OBJ_STATE,x
@accelerate:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$3000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	jsr	a:rideable_missile_set_hdma
	jsr	a:rideable_missile_exhaust
	bra	rideable_missile_state_01

rideable_missile_state_03:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$0800
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	cmp	#$FFFE	; [num]
	bne	@leave
	inc	OBJ_STATE,x
@leave:
	jsr	a:rideable_missile_helicopter_leaves
	jsr	a:rideable_missile_set_hdma
	jsr	a:rideable_missile_exhaust
	bra	rideable_missile_state_01

rideable_missile_state_04:
	jsr	a:rideable_missile_helicopter_leaves
	jsr	a:rideable_missile_set_hdma
	jsr	a:rideable_missile_exhaust

rideable_missile_state_01:
	lda	stage_frame_counter
	bit	#$003F
	bne	@carry
	lda	#$0031
	ldy	stage_number
	cpy	#$0004
	beq	@play_sound
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0017
	bcc	@sound_5f
	cmp	#$0025
	bcc	@carry
	cmp	#$0029
	bcs	@carry
@sound_5f:
	lda	#$005F
@play_sound:
	jsl	f:queue_sound
@carry:
	jsr	a:rideable_missile_carry_players
	inc	$30,x
	lda	$32,x
	inc	a
	and	#$0007
	cmp	#$0006
	bne	@store_frame
	lda	#$0000
@store_frame:
	sta	$32,x
	and	#$0006
	sta	zp_FC
	lda	stage_frame_odd
	bne	@return
	lda	$30,x
	and	#$0006
	tay
	lda	#$0006
	sta	zp_02
	lda	#$0030
	sta	zp_08
	phy
	lda	#$4404
	ldy	stage_number
	cpy	#$0004
	beq	@have_vram_addr
	lda	#$4804
@have_vram_addr:
	ply
	pha
	lda	a:ptrs_rideable_missile_anim_blocks,y
	tay
	pla
	phx
	jsl	f:queue_vram_blocks
	ldy	zp_FC
	lda	#$0002
	sta	zp_02
	lda	#$0040
	sta	zp_08
	phy
	lda	#$4480
	ldy	stage_number
	cpy	#$0004
	beq	@have_vram_addr2
	lda	#$4880
@have_vram_addr2:
	ply
	pha
	lda	a:ptrs_rideable_missile_anim_blocks_2,y
	tay
	pla
	ldx	#$0030
	jsl	f:queue_vram_blocks_at_x
	plx
@return:
	rtl

rideable_missile_state_07:
	lda	$34,x
	lsr	a
	tay
	lda	#$FF80	; [num]
	sta	OBJ_X,x
	lda	a:rideable_missile_start_y,y
	and	#$00FF
	sta	zp_00
	lda	rng_hi
	and	#$0007
	clc
	adc	zp_00
	sta	OBJ_Y,x
	tya
	clc
	adc	$30,x
	and	#$0003
	tay
	lda	a:rideable_missile_speed_fracs,y
	xba
	and	#$FF00
	sta	zp_00
	ldy	difficulty
	lda	a:rideable_missile_base_speeds,y
	clc
	adc	zp_00
	sta	OBJ_X_VEL_SUB,x
	lda	#$0000
	adc	#$0000
	sta	OBJ_X_VEL,x
	lda	#$0005
	sta	OBJ_STATE,x
	inc	$30,x
	rtl

rideable_missile_state_05:
	jsr	a:rideable_missile_carry_players
	jsr	a:rideable_missile_set_hdma
	jsr	a:rideable_missile_exhaust
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	beq	@check_boss
	clc
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_X
	adc	#$FF90
	cmp	OBJ_X,x
	bpl	@return
	inc	OBJ_STATE,x
	rtl
@check_boss:
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$FF90
	cmp	OBJ_X,x
	bpl	@return
	lda	#$0200
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_SAVED_ATTR
	sec
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	sbc	#$0004
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	inc	OBJ_STATE,x
@return:
	rtl

rideable_missile_state_06:
	lda	OBJ_X,x
	adc	#$0080
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$FFF5
	sta	zp_02
	phx
	ldx	#$0006
	ldy	#$06C0
@loop:
	jsl	f:find_free_slot_y_down
	bcc	@done
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	zp_00
	sta	a:$000A,y
	sbc	#$0018
	sta	zp_00
	lda	zp_02
	sta	a:$000E,y
	lda	a:rideable_missile_explosion_x_vels,x
	sta	a:$001A,y
	dex
	dex
	bpl	@loop
@done:
	plx
	inc	OBJ_STATE,x
	lda	#$0030
	jml	f:queue_sound

rideable_missile_state_08:
	lda	OBJ_X,x
	adc	#$FFE8
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$007F
	sta	zp_06
	lda	#$003F
	sta	zp_04
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	lda	#$FFFE	; [num]
	sta	a:$001A,y
	sec
	lda	#$0140
	sbc	a:$000A,x
	sta	a:bg1_x
	brl	rideable_missile_state_01

; Object type $69. Stage 4 boss: the green armoured flying fortress with a red
; eye at the end of the sky section (384 HP, slot $0900); fires
; stage4_boss_shot and stage4_boss_fireball.
update_stage4_boss:
	lda	OBJ_FLAGS,x
	bpl	@dispatch
	stz	a:bg2_x
	rtl
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage4_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage4_boss_states:
	.addr	stage4_boss_state_00
	.addr	stage4_boss_state_01
	.addr	stage4_boss_state_02
	.addr	stage4_boss_state_03
	.addr	stage4_boss_state_04

stage4_boss_state_00:
	lda	#$4001
	sta	OBJ_FLAGS,x
	lda	#$0180
	sta	OBJ_X,x
	lda	#$0088
	sta	OBJ_Y,x
	lda	#ENEMY_HP($0180)
	sta	OBJ_HP,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFD0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$017F
	sta	$32,x
	stz	$30,x
	stz	a:boss_work_2
	inc	OBJ_STATE,x
	phx
	ldx	#$0700
	ldy	#$0000
	stz	$30,x
	jsr	a:stage4_boss_init_part
	lda	#ENEMY_HP($0080)
	sta	$06,x
	ldx	#$0740
	sta	$06,x
	lda	#$0002
	sta	$30,x
	sta	$04,x
	jsr	a:stage4_boss_init_part
	ldx	#$0780
	ldy	#$0002
	jsr	a:stage4_boss_init_part
	plx
	stz	a:boss_work_1
	rtl

stage4_boss_state_01:
	lda	stage_frame_mod8
	bne	stage4_boss_state_02
	dec	$32,x
	lda	$32,x
	cmp	#$00E1
	bcs	stage4_boss_state_02
	inc	OBJ_STATE,x

stage4_boss_state_02:
	lda	OBJ_SAVED_ATTR,x
	beq	@check_hp
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$6050
	sta	cgram_upload_addr
@check_hp:
	lda	OBJ_HP,x
	bpl	@move
	lda	#$0001
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
@move:
	jsr	a:stage4_boss_move
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	beq	@fire_fireball
	inc	a:boss_work_1
	lda	a:boss_work_1
	cmp	#$0070
	bcc	@return
	bit	#$0007
	bne	@return
	cmp	#$0090
	bcc	@fire_shot
	stz	a:boss_work_1
	lda	a:boss_work_2
	eor	#$0002
	sta	a:boss_work_2
@fire_shot:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#OBJT_STAGE4_BOSS_SHOT
	sta	a:$0010,y
	lda	rng_hi
	and	#$0003
	clc
	adc	#$FFFE
	sta	a:$001E,y
	lda	rng_lo
	and	#$F800
	ora	#$8000
	sta	a:$001C,y
	lda	rng_lo
	and	#$003F
	eor	#$FFFF
	clc
	adc	OBJ_Y,x
	sta	a:$000E,y
	lda	OBJ_X,x
	adc	#$0000
	sta	a:$000A,y
@return:
	rtl
@fire_fireball:
	lda	stage_frame_counter
	bit	#$003F
	bne	@return2
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@return2
	lda	#OBJT_STAGE4_BOSS_FIREBALL
	sta	a:$0010,y
	lda	OBJ_X,x
	adc	#$0020
	sta	a:$000A,y
	lda	OBJ_Y,x
	adc	#$FFE0
	sta	a:$000E,y
@return2:
	rtl

stage4_boss_state_03:
	dec	OBJ_TIMER,x
	bne	stage4_boss_state_04
	inc	a:obj_slots+29*OBJ_SIZE+OBJ_STATE
	inc	OBJ_STATE,x

stage4_boss_state_04:
	jsl	f:queue_sound_6E_throttled
	lda	OBJ_X,x
	sta	zp_00
	lda	#$00FF
	sta	zp_02
	lda	#$00FF
	sta	zp_06
	stz	zp_04
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@move
	lda	rng_lo
	and	#$0003
	adc	#$FFF5
	sta	a:$001A,y
@move:
	jsr	a:stage4_boss_move
	rtl

; Object type $6A. Stage 4 boss: the upper and lower pods of stage4_boss (128
; HP each).
update_stage4_boss_pod:
	lda	OBJ_HP,x
	bpl	@alive
	phx
	lda	$30,x
	tax
	lda	#$0001
	sta	zp_02
	lda	#$0010
	sta	zp_08
	ldy	a:ptrs_stage4_boss_pod_wreck_blocks,x
	lda	a:stage4_boss_pod_wreck_vram_addrs,x
	jsl	f:queue_vram_blocks
	plx
	lda	#$0041
	jsl	f:queue_sound
	ldy	$30,x
	lda	#$FFFC	; [num]
	sta	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@alive:
	lda	a:boss_work_2
	eor	$30,x
	bne	@return
	jsr	a:stage4_boss_pod_fire
@return:
	rtl

; Object type $82. Stage 4 boss: spread shots.
update_stage4_boss_shot:
	lda	OBJ_TOUCHED_BY,x
	bne	@explode
	lda	OBJ_HP,x
	bpl	@alive
@explode:
	lda	#$0017
	jsl	f:queue_sound
	lda	#$FFF8	; [num]
	sta	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
@alive:
	lda	OBJ_STATE,x
	bne	@fly
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06C83F)
	sta	OBJ_SPRITE,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	rng_lo
	and	#$001F
	adc	#$0090
	sta	OBJ_TIMER,x
	lda	rng_lo
	and	#$7800
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	rtl
@fly:
	dec	OBJ_TIMER,x
	bmi	@explode
	lda	OBJ_Y_VEL_SUB,x
	bne	@decelerate
	lda	OBJ_Y_VEL,x
	beq	@return
@decelerate:
	lda	OBJ_Y_VEL,x
	bpl	@decel_falling
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@return:
	rtl
@decel_falling:
	sec
	lda	OBJ_Y_VEL_SUB,x
	sbc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $83. Stage 4 boss: fireballs from the red eye (16 HP: can be
; shot down).
update_stage4_boss_fireball:
	lda	OBJ_HP,x
	bpl	@alive
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@alive:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage4_boss_fireball_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage4_boss_fireball_states:
	.addr	stage4_boss_fireball_state_00
	.addr	stage4_boss_fireball_state_01
	.addr	stage4_boss_fireball_state_02

stage4_boss_fireball_state_00:
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06AF8C)
	sta	OBJ_SPRITE,x
	lda	#$3200
	sta	OBJ_ATTR,x
	lda	#$0013
	sta	OBJ_FLAGS,x
	lda	#$000C
	sta	OBJ_HITBOX_W,x
	lda	#$FFF4	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#ENEMY_HP($0010)
	sta	OBJ_HP,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	rtl

stage4_boss_fireball_state_01:
	lda	rng_lo
	and	#$00C0
	clc
	adc	#$07C0
	tay
	lda	a:$0012,y
	cmp	#$0005
	bne	stage4_boss_fireball_move
	inc	OBJ_STATE,x
	sty	$30,x
	bra	stage4_boss_fireball_move

stage4_boss_fireball_state_02:
	ldy	$30,x
	lda	a:$0012,y
	cmp	#$0005
	beq	@follow
	dec	OBJ_STATE,x
	bra	stage4_boss_fireball_move
@follow:
	clc
	lda	a:$000E,y
	adc	#$FFF6
	cmp	OBJ_Y,x
	bcc	@move_up
	inc	OBJ_Y,x
	bra	stage4_boss_fireball_move
@move_up:
	dec	OBJ_Y,x
stage4_boss_fireball_move:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	lda	stage_frame_mod4
	bne	@check_missiles
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@check_missiles
	lda	#.loword(anim_05C558)
	jsl	f:make_effect_object
	lda	OBJ_X,x
	adc	#$0004
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
@check_missiles:
	ldy	#$07C0
@missile_loop:
	clc
	lda	a:$000A,y
	adc	#$0070
	cmp	OBJ_X,x
	bmi	@next_missile
	lda	a:$000A,y
	cmp	OBJ_X,x
	bpl	@next_missile
	sec
	lda	a:$000E,y
	sbc	OBJ_Y,x
	bpl	@abs_dy
	eor	#$FFFF
@abs_dy:
	cmp	#$000A
	bcs	@next_missile
	lda	#$0006
	sta	a:$0012,y
	lda	#$FFFF	; [num]
	sta	OBJ_HP,x
	rtl
@next_missile:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@missile_loop
	rtl

; Player slot X (state 1, 3 or 4, above y $E0): x = $10 (player 1) or $30
; (player 2), y = $C3, stops its vertical motion. Called for both players by
; stage4_controller_state_1C after the boss.
stage4_reposition_player:
	lda	OBJ_FLAGS,x
	beq	@return
	bmi	@return
	lda	OBJ_STATE,x
	cmp	#$0001
	beq	@check_y
	; (not executed in the CDL traces)
	cmp	#$0003
	beq	@check_y
	cmp	#$0004
	beq	@check_y
@check_y:
	lda	OBJ_Y,x
	cmp	#$00E0
	bcs	@return
	txa
	and	#$0040
	lsr	a
	clc
	adc	#$0010
	sta	OBJ_X,x
	lda	#$00C3
	sta	OBJ_Y,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_FACING,x
@return:
	rts

scroll_bg1_bg2_right_16:
	clc
	lda	a:bg1_x
	adc	#$0010
	sta	a:bg1_x
	sta	a:bg2_x
	rts

; Players standing on the missile (rideable_missile_carry_player) move with
; it.
rideable_missile_carry_players:
	ldy	#$0200
	jsr	a:rideable_missile_carry_player
	ldy	#$0240
	jsr	a:rideable_missile_carry_player
	rts

rideable_missile_carry_player:
	lda	a:$0016,y
	beq	@return
	bmi	@return
	lda	a:$0032,y
	bne	@return
	clc
	lda	a:$000A,y
	adc	#$0006
	cmp	OBJ_X,x
	bmi	@return
	clc
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	cmp	a:$000A,y
	bmi	@return
	sec
	lda	a:$000E,y
	sbc	#$0028
	sta	zp_00
	cmp	OBJ_Y,x
	bpl	@return
	sec
	lda	OBJ_Y,x
	sbc	#$0009
	cmp	zp_00
	bpl	@return
	lda	#$2000
	ora	a:$003C,y
	sta	a:$003C,y
	txa
	sta	a:$1304,y
	lda	#$0001
	cmp	a:$0012,y
	beq	@return
	sta	a:$0012,y
	clc
	lda	OBJ_Y,x
	adc	#$0023
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$001E,y
@return:
	rts

stage4_queue_tiles:
	ldy	#$0007
	sty	zp_02
	ldy	#$0038
	sty	zp_08
	ldy	#.loword(vram_blocks_05EC26)
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Adds the 16.16 speed wram_140C/wram_140E to wram_1404/hdma_tables+$24:
; hdma_tables+$24 is the BG3 horizontal scroll of the lower band of the HDMA table
; at $7E:3820 (hdma_preset $0B, set up by stage4_controller_state_16).
stage4_scroll_bg3_lower:
	clc
	lda	a:bg3_x+BG_X_SUB
	adc	a:bg3_x+BG_X_DELTA_SUB
	sta	a:bg3_x+BG_X_SUB
	lda	f:hdma_tables+$24
	adc	a:bg3_x+BG_X_DELTA
	sta	f:hdma_tables+$24
	rts

rideable_missile_set_hdma:
	phx
	ldy	$34,x
	sec
	lda	#$0098
	sbc	$0E,x
	pha
	sec
	lda	#$0040
	sbc	$0A,x
	pha
	lda	a:rideable_missile_hdma_offsets,y
	tax
	pla
	sta	f:$7E3800,x
	pla
	sta	f:$7E3802,x
	plx
	rts

; stage4_boss: moves left and right around field $32, scrolls BG2 with it (the
; boss is drawn on BG2) with a small vertical wobble, and places its parts
; (slots $0700, $0740: the pods; $0780: the core); when both pods are
; destroyed the core is removed and the boss itself becomes the target.
stage4_boss_move:
	lda	$30,x
	bne	@moving_right
	lda	$32,x
	cmp	OBJ_X,x
	bcs	@turn
	lda	OBJ_X_VEL,x
	bpl	@accel_left
	cmp	#$FFFE	; [num]
	bcc	@scroll_bg2
@accel_left:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bra	@scroll_bg2
@moving_right:
	clc
	lda	$32,x
	adc	#$0008
	cmp	OBJ_X,x
	bcc	@turn
	lda	OBJ_X_VEL,x
	bmi	@accel_right
	cmp	#$0001
	bcs	@scroll_bg2
@accel_right:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	bra	@scroll_bg2
@turn:
	lda	$30,x
	eor	#$0002
	sta	$30,x
@scroll_bg2:
	sec
	lda	#$01A0
	sbc	OBJ_X,x
	sta	a:bg2_x
	lda	stage_frame_counter
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000F
	bit	#$0008
	beq	@apply_wobble
	eor	#$FFFF
@apply_wobble:
	and	#$0007
	sta	zp_02
	clc
	adc	#$0000
	sta	a:bg2_y
	sec
	lda	OBJ_X,x
	sbc	#$0020
	sta	zp_00
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	beq	@return
	lda	a:obj_slots+20*OBJ_SIZE+OBJ_FLAGS
	ora	a:obj_slots+21*OBJ_SIZE+OBJ_FLAGS
	bne	@place_parts
	lda	#$8000	; [num]
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	lda	#$4011
	sta	OBJ_FLAGS,x
	lda	#$00C8
	sta	$32,x
@return:
	rts
@place_parts:
	lda	zp_00
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_X
	sec
	lda	#$00B0
	sbc	zp_02
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_Y
	lda	a:obj_slots+20*OBJ_SIZE+OBJ_FLAGS
	beq	@lower_pod
	lda	zp_00
	sta	a:obj_slots+20*OBJ_SIZE+OBJ_X
	sec
	lda	#$0030
	sbc	zp_02
	sta	a:obj_slots+20*OBJ_SIZE+OBJ_Y
@lower_pod:
	lda	a:obj_slots+21*OBJ_SIZE+OBJ_FLAGS
	beq	@return
	lda	zp_00
	sta	a:obj_slots+21*OBJ_SIZE+OBJ_X
	sec
	lda	#$00C8
	sbc	zp_02
	sta	a:obj_slots+21*OBJ_SIZE+OBJ_Y
	rts

rideable_missile_exhaust:
	lda	stage_frame_mod4
	bne	@return
	ldy	#$0500
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	a:boss_work_0
	jsl	f:make_effect_object
	lda	#$FFF8	; [num]
	sta	a:$001A,y
	lda	OBJ_X,x
	adc	#$FFF8
	sta	a:$000A,y
	clc
	lda	OBJ_Y,x
	adc	#$FFF5
	sta	a:$000E,y
@return:
	rts

; rideable_missile states 3-4 (stage 4 sky): accelerates the BG1 scroll of the
; top HDMA bands ($7E:3801/3806, $7E:3803/3808) so that the helicopter drawn
; on BG1 flies away (seen in the emulator); when done, makes the three other
; missiles (slots $07C0, $0840, $0880).
rideable_missile_helicopter_leaves:
	clc
	lda	$36,x
	adc	#$0500
	sta	$36,x
	lda	$38,x
	adc	#$0000
	sta	$38,x
	clc
	lda	$3A,x
	adc	$36,x
	sta	$3A,x
	lda	f:hdma_tables+$01
	adc	$38,x
	sta	f:hdma_tables+$01
	sta	f:hdma_tables+$06
	cmp	#$0200
	bcc	@still_leaving
	inc	OBJ_STATE,x
	lda	#$4000
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	$30,x
	lda	#.loword(anim_05C606)
	sta	a:boss_work_0
	phx
	ldy	#$0000
	ldx	#$07C0
	jsl	f:make_rideable_missile
	ldy	#$0004
	ldx	#$0840
	jsl	f:make_rideable_missile
	iny
	iny
	ldx	#$0880
	jsl	f:make_rideable_missile
	plx
	rts
@still_leaving:
	clc
	lda	$3E,x
	adc	#$0C00
	sta	$3E,x
	lda	f:hdma_tables+$03
	adc	#$0000
	sta	f:hdma_tables+$03
	sta	f:hdma_tables+$08
	clc
	lda	a:bg3_x+BG_X_DELTA_SUB
	adc	#$2000
	sta	a:bg3_x+BG_X_DELTA_SUB
	lda	a:bg3_x+BG_X_DELTA
	adc	#$0000
	sta	a:bg3_x+BG_X_DELTA
	rts

stage4_boss_init_part:
	lda	a:stage4_boss_part_types,y
	sta	OBJ_TYPE,x
	lda	a:stage4_boss_part_flags,y
	sta	OBJ_FLAGS,x
	lda	a:stage4_boss_part_anims,y
	sta	OBJ_ANIM,x
	lda	#$0180
	sta	OBJ_X,x
	lda	a:stage4_boss_part_hitbox_w,y
	sta	OBJ_HITBOX_W,x
	lda	a:stage4_boss_part_hitbox_h,y
	sta	OBJ_HITBOX_H,x
	lda	#$0E00
	sta	OBJ_ATTR,x
	rts

; stage4_boss_pod (not on easy, while boss_work_1 is $20-$31, every 8 frames):
; fires a type $6B shot, moving left and up or down by pod
; (stage4_boss_pod_shot_y_vels, stage4_boss_pod_shot_anims; field $30 = pod).
stage4_boss_pod_fire:
	lda	OBJ_X,x
	cmp	#$00E0
	bcs	@return
	lda	difficulty
	beq	@return
	lda	a:boss_work_1
	cmp	#$0020
	bcc	@return
	cmp	#$0032
	bcs	@return
	bit	#$0007
	bne	@return
	ldy	#$06C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	$30,x
	phx
	tax
	lda	#$001F
	sta	a:$0016,y
	lda	#$006B
	sta	a:$0010,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8	; [num]
	sta	a:$002A,y
	lda	#$FFFD	; [num]
	sta	a:$001A,y
	lda	a:stage4_boss_pod_shot_y_vels,x
	sta	a:$001E,y
	lda	a:stage4_boss_pod_shot_anims,x
	sta	a:$0020,y
	plx
	lda	OBJ_X,x
	adc	#$0000
	sta	a:$000A,y
	lda	OBJ_Y,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$001A
	jsl	f:queue_sound
@return:
	rts

; stage4_controller states 9-A: every 72-135 frames makes the first free of
; slots $07C0/$0840/$0880 a type $73 soldier dropping onto the road (seen in
; the emulator).
stage4_spawn_dropping_soldier:
	dec	$32,x
	bpl	@return
	phx
	ldy	#$0000
	ldx	#$07C0
	lda	$10,x
	beq	@found
	iny
	iny
	ldx	#$0840
	lda	$10,x
	beq	@found
	iny
	iny
	ldx	#$0880
	lda	$10,x
	bne	@set_delay
@found:
	lda	#OBJT_JETPACK_SOLDIER
	sta	$10,x
	sty	$30,x
@set_delay:
	plx
	lda	rng_lo
	and	#$003F
	adc	#$0048
	sta	$32,x
@return:
	rts

stage4_spawn_hoverbike_rider:
	dec	$32,x
	bpl	stage4_spawn_hoverbike_rider_return
	ldy	#$0400
	jsl	f:find_free_slot_y_down
	bcc	stage4_spawn_hoverbike_rider_return
	lda	#$0074
	sta	a:$0010,y
	lda	rng_lo
	and	#$003F
	adc	#$0020
	sta	a:$000E,y
	and	#$0002
	sta	a:$0030,y
	lda	#$0100
	sta	a:$000A,y
	ldy	difficulty
	lda	rng_hi
	and	#$001F
	lda	a:hoverbike_rider_spawn_delays,y
	sta	$32,x
	dec	$34,x
	bne	stage4_spawn_hoverbike_rider_return
	inc	OBJ_STATE,x
stage4_spawn_hoverbike_rider_return:
	rts

; Every 8 frames: stage4_spawn_passing_rider.
stage4_spawn_passing_rider_every_8:
	lda	stage_frame_mod8
	bne	stage4_spawn_passing_rider_return

; Bike section: makes a type $53 (OBJT_PASSIVE_PART, not a target) hover-bike
; rider passing in the background from the left at 7-10 pixels per frame (seen
; in the emulator); stage4_controller_state_01 turns one into a real
; OBJT_HOVERBIKE_RIDER.
stage4_spawn_passing_rider:
	ldy	#$0400
	jsl	f:find_free_slot_y_down
	bcc	stage4_spawn_hoverbike_rider_return
	lda	#$0053
	sta	a:$0010,y
	lda	#$0003
	sta	a:$0016,y
	lda	#.loword(metasprite_06C6EB)
	sta	a:$0000,y
	lda	#$3800
	sta	a:$0002,y
	lda	rng_lo
	and	#$0003
	adc	#$0007
	sta	a:$001A,y
	lda	rng_lo
	and	#$003F
	adc	#$0030
	sta	a:$000E,y
	lda	#$FFE8	; [num]
	sta	a:$000A,y
stage4_spawn_passing_rider_return:
	rts

scroll_with_airship:
	sec
	lda	OBJ_X,x
	sbc	a:bg1_moved_x
	sta	OBJ_X,x
	cmp	#$0100
	bcc	@scroll_y
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@scroll_y:
	sec
	lda	OBJ_Y,x
	sbc	a:bg1_moved_y
	sta	OBJ_Y,x
	rts

airship_part_explode:
	lda	#$0030
	jsl	f:queue_sound_throttled
	lda	stage_frame_odd
	bne	@return
	dec	OBJ_TIMER,x
	bpl	@spawn_explosion
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@spawn_explosion:
	ldy	#$0580
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	rng_lo
	and	#$001F
	sta	zp_00
	lda	OBJ_Y,x
	sbc	zp_00
	sta	a:$000E,y
	lda	rng_hi
	and	#$0007
	pha
	adc	OBJ_X,x
	sta	a:$000A,y
	pla
	adc	#$FFF8
	sta	a:$001A,y
@return:
	rtl

stage4_spawn_weapon_capsule:
	dec	$38,x
	bpl	@return
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#$000F
	sta	a:$0010,y
	lda	rng_hi
	and	#$001F
	adc	#$0040
	sta	a:$000E,y
	and	#$0001
	inc	a
	sta	a:$003A,y
	lda	rng_lo
	and	#$0001
	clc
	adc	#$FFFF
	sta	a:$000A,y
	lda	#$0100
	sta	$38,x
@return:
	rts

; Object type $5E. Stage 6, vertical section: the winged skeletal alien with a
; segmented tail. HP by difficulty: 128/160/192 (winged_alien_hp).
update_winged_alien:
	ldy	OBJ_SAVED_ATTR,x
	beq	@check_hp
	lda	#$0030
	sta	cgram_upload_addr
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	lda	#$0006
	sta	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_HP,x
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_states:
	.addr	winged_alien_state_00
	.addr	winged_alien_state_01
	.addr	winged_alien_state_02
	.addr	winged_alien_state_03
	.addr	winged_alien_state_04
	.addr	winged_alien_state_05
	.addr	winged_alien_state_06
	.addr	winged_alien_state_07

winged_alien_state_00:
	lda	#$004A
	sta	a:bg2sc_shadow
	stz	a:bg2_x
	stz	a:bg2_y
	inc	OBJ_STATE,x
	rtl

winged_alien_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	@start
	rtl
@start:
	ldy	difficulty
	lda	a:winged_alien_hp,y
	sta	OBJ_HP,x
	jsr	a:winged_alien_spawn_tail
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	rtl

winged_alien_state_02:
	lda	#$0080
	sta	OBJ_X,x
	lda	OBJ_Y,x
	bmi	@descend
	cmp	#$0070
	bcs	@slow_down
@descend:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	@place
@slow_down:
	lda	stage_frame_counter
	bit	#$0007
	bne	@halve_speed
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
@halve_speed:
	lsr	OBJ_Y_VEL,x
	ror	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL_SUB,x
	beq	@stopped
@place:
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:winged_alien_place_parts
	rtl
@stopped:
	inc	OBJ_STATE,x
	lda	#$401D
	sta	OBJ_FLAGS,x
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:winged_alien_place_parts
	rtl

winged_alien_state_03:
	lda	OBJ_HP,x
	ldy	difficulty
	cmp	a:winged_alien_phase_2_hp,y
	bcs	@check_x
	lda	#$0004
	sta	OBJ_STATE,x
	stz	$3A,x
@check_x:
	lda	OBJ_X,x
	bmi	@decelerate
	cmp	#$00D0
	bcc	@decelerate
	lda	#$0055
	jsl	f:queue_sound
	lda	a:player1_obj+OBJ_FLAGS
	ora	a:player2_obj+OBJ_FLAGS
	and	#$0001
	bne	@aim_player
	lda	#$0078
	sta	zp_00
	bra	@have_target_y
@aim_player:
	jsl	f:pick_random_player
	lda	a:$000E,y
	sta	zp_00
@have_target_y:
	lda	OBJ_Y,x
	bmi	@above_target
	cmp	zp_00
	bcc	@above_target
	ldy	#$0002
	bra	@set_swoop
@above_target:
	ldy	#$0000
@set_swoop:
	lda	a:winged_alien_swoop_y_vel_subs,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:winged_alien_swoop_y_vels,y
	sta	OBJ_Y_VEL,x
	lda	#$FFFA	; [num]
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
@decelerate:
	lda	OBJ_X_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sta	zp_00
	adc	#$0000
	sta	OBJ_X_VEL,x
	eor	#$FFFF
	and	zp_00
	bit	#$8000
	beq	@flap
	lda	rng_lo
	and	#$0001
	bne	@flap
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@flap:
	lda	OBJ_X_VEL,x
	bmi	@flap_slow
	lda	stage_frame_counter
	bit	#$0003
	bne	@place
	and	#$0004
	lsr	a
	lsr	a
	bra	@set_frame
@flap_slow:
	lda	stage_frame_counter
	bit	#$0007
	bne	@place
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
@set_frame:
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
@place:
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:winged_alien_place_parts
	rtl

winged_alien_state_04:
	lda	$3A,x
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_state_04_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_state_04_steps:
	.addr	winged_alien_state_04_step_0
	.addr	winged_alien_state_04_step_1

winged_alien_state_04_step_0:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFA	; [num]
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	lda	OBJ_X,x
	adc	#$FFE0
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@next_step
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@next_step:
	inc	$3A,x

winged_alien_state_04_step_1:
	lda	OBJ_X,x
	bmi	@stop
	cmp	#$0048
	bcc	@stop
	lda	OBJ_X_VEL_SUB,x
	clc
	adc	#$8000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	bmi	@place
@stop:
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$00D0
	sta	a:obj_slots+22*OBJ_SIZE+$36
	lda	#$01F2
	sta	a:obj_slots+22*OBJ_SIZE+$38
	inc	OBJ_STATE,x
	stz	$3A,x
	stz	OBJ_TIMER,x
@place:
	jsr	a:winged_alien_place_parts
	rtl

winged_alien_state_05:
	jsr	a:winged_alien_run_step
	jsr	a:winged_alien_place_parts
	rtl

; State 5: runs step field $3A of tbl_winged_alien_steps.
winged_alien_run_step:
	lda	$3A,x
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_steps:
	.addr	winged_alien_step_0
	.addr	winged_alien_step_1
	.addr	winged_alien_step_2
	.addr	winged_alien_step_3
	.addr	winged_alien_step_4
	.addr	winged_alien_step_5
	.addr	winged_alien_step_6
	.addr	winged_alien_step_7
	.addr	winged_alien_step_8
	.addr	winged_alien_step_9

; Steps fields $36 and $38 of the tail root (slot 22, $0780) towards $D0 and
; $1F2; carry set when both are there.
winged_alien_ease_tail_params:
	ldy	#$0000
	lda	a:obj_slots+22*OBJ_SIZE+$36
	cmp	#$00D0
	bne	@step_36
	iny
	bra	@check_38
@step_36:
	clc
	adc	#$0004
	sta	a:obj_slots+22*OBJ_SIZE+$36
	and	#$01FF
	clc
	sbc	#$00D0
	cmp	#$0008
	bcs	@check_38
	; (not executed in the CDL traces)
	lda	#$00D0
	sta	a:obj_slots+22*OBJ_SIZE+$36
@check_38:
	lda	a:obj_slots+22*OBJ_SIZE+$38
	cmp	#$01F2
	bne	@step_38
	iny
	bra	@check_both
@step_38:
	sec
	sbc	#$0001
	sta	a:obj_slots+22*OBJ_SIZE+$38
	and	#$01FF
	clc
	sbc	#$01F2
	cmp	#$0002
	bcs	@check_both
	lda	#$01F2
	sta	a:obj_slots+22*OBJ_SIZE+$38
@check_both:
	cpy	#$0002
	beq	@return_sec
	clc
	rts
@return_sec:
	sec
	rts

winged_alien_step_0:
	jsr	a:winged_alien_ease_tail_params
	bcc	@flap
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_TIMER,x
	inc	$3A,x
@flap:
	jsr	a:winged_alien_flap_slow
	rts

winged_alien_step_1:
	lda	OBJ_X,x
	bmi	@stop
	cmp	#$0048
	bcc	@stop
	lda	OBJ_X_VEL_SUB,x
	sec
	sbc	#$4000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	lda	OBJ_Y,x
	bmi	@flap
	cmp	#$0010
	bcc	@stop_y
	lda	OBJ_Y_VEL_SUB,x
	sec
	sbc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	bra	@flap
@stop_y:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
@flap:
	jsr	a:winged_alien_flap_fast
	rts
@stop:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	inc	$3A,x
	rts

winged_alien_step_2:
	lda	#$0000
	sta	f:winged_alien_hdma_state
	lda	#$0074
	sta	f:winged_alien_hdma_height
	lda	OBJ_Y,x
	sta	f:winged_alien_hdma_center_y
	lda	#$000D
	sta	OBJ_FLAGS,x
	lda	#$003D
	jsl	f:queue_sound
	stz	OBJ_TIMER,x
	inc	$3A,x
	lda	#$0001
	jsr	a:winged_alien_queue_tiles
	rts

winged_alien_step_3:
	jsr	a:winged_alien_warp_out
	lda	f:winged_alien_hdma_state
	cmp	#$0002
	bcc	@return
	lda	#$0180
	sta	OBJ_Y,x
	lda	#$0078
	sta	OBJ_X,x
	inc	$3A,x
	stz	OBJ_TIMER,x
@return:
	rts

winged_alien_step_4:
	stz	hdma_preset
	inc	$3A,x
	rts

winged_alien_step_5:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0030
	bcc	@return
	inc	$3A,x
	stz	OBJ_TIMER,x
@return:
	rts

winged_alien_step_6:
	lda	a:player1_obj+OBJ_FLAGS
	ora	a:player2_obj+OBJ_FLAGS
	and	#$0001
	bne	@aim_player
	lda	#$0078
	sta	zp_00
	bra	@have_target_y
@aim_player:
	jsl	f:pick_random_player
	lda	a:$000E,y
	sta	zp_00
@have_target_y:
	lda	rng_lo
	and	#$000F
	sta	zp_02
	lda	zp_00
	sbc	zp_02
	sbc	#$0032
	sta	OBJ_Y,x
	lda	#$0090
	sta	OBJ_X,x
	lda	#$0080
	sta	a:obj_slots+22*OBJ_SIZE+$36
	lda	#$0040
	sta	a:obj_slots+22*OBJ_SIZE+$38
	inc	$3A,x
	lda	#$0000
	sta	f:winged_alien_hdma_state
	lda	OBJ_Y,x
	sta	f:winged_alien_hdma_center_y
	rts

winged_alien_step_7:
	jsr	a:winged_alien_warp_in
	lda	f:winged_alien_hdma_state
	cmp	#$0002
	bcc	@return
	lda	#$401D
	sta	OBJ_FLAGS,x
	stz	hdma_preset
	stz	OBJ_TIMER,x
	inc	$3A,x
	jsr	a:winged_alien_flap_slow
@return:
	rts

winged_alien_step_8:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0008
	bcc	@flap
	jsl	f:pick_random_player
	lda	OBJ_Y,x
	clc
	adc	#$0032
	cmp	a:$000E,y
	bcs	@swoop
	lda	#$0090
	sta	a:obj_slots+22*OBJ_SIZE+$36
@swoop:
	stz	a:obj_slots+22*OBJ_SIZE+$38
	lda	#$FFFA	; [num]
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_TIMER,x
	inc	$3A,x
@flap:
	jsr	a:winged_alien_flap_fast
	rts

winged_alien_step_9:
	lda	OBJ_X,x
	bmi	@stop
	cmp	#$0040
	bcs	@stop
	; (not executed in the CDL traces)
	lda	OBJ_X_VEL_SUB,x
	clc
	adc	#$1F40
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	jsr	a:winged_alien_flap_fast
	rts
@stop:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_TIMER,x
	stz	$3A,x
	jsr	a:winged_alien_flap_slow
	rts

winged_alien_state_06:
	stz	hdma_preset
	lda	#$8000	; [num]
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	phx
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:winged_alien_tail_slots,y
	tax
	lda	#$0001
	sta	$12,x
	sta	$16,x
	inc	zp_00
	lda	zp_00
	cmp	#$0010
	bcc	@loop
	plx
	lda	#$0025
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_TYPE
	lda	#$0001
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_STATE
	lda	#$0001
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	lda	#$0002
	jsr	a:winged_alien_queue_tiles
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL_SUB,x
	inc	OBJ_STATE,x
	jsr	a:winged_alien_set_bg2_scroll
	rtl

winged_alien_state_07:
	lda	OBJ_Y,x
	bmi	@fall
	cmp	#$0140
	bcs	@gone
@fall:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	jsl	f:queue_sound_41_throttled
	lda	OBJ_X,x
	adc	#$FFE0
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@scroll_bg2
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@scroll_bg2:
	jsr	a:winged_alien_set_bg2_scroll
	rtl
@gone:
	lda	#$0002
	sta	a:bg1_scroll_mode
	lda	#$0049
	sta	a:bg2sc_shadow
	stz	a:bg2_x
	stz	a:bg2_y
	lda	#$0082
	jsl	f:queue_sound
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

winged_alien_spawn_tail:
	lda	#$000D
	sta	OBJ_FLAGS,x
	lda	#$0080
	sta	OBJ_X,x
	lda	#$FFC0	; [num]
	sta	OBJ_Y,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	$30,x
	lda	#$0053
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_TYPE
	lda	#$003D
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$0012
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFC0	; [num]
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0053
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_TYPE
	lda	#$003D
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	lda	#$0053
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_TYPE
	lda	#$003D
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	lda	#.loword(metasprite_06C46D)
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_SPRITE
	lda	#$3600
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_ATTR
	lda	#$0008
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFF8	; [num]
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0080
	sta	a:obj_slots+22*OBJ_SIZE+$36
	lda	#$0010
	sta	a:obj_slots+22*OBJ_SIZE+$38
	phx
	lda	#$0780
	sta	zp_00
	ldy	#$0000
@loop:
	lda	a:winged_alien_tail_slots,y
	tax
	lda	#OBJT_WINGED_ALIEN_TAIL_SEGMENT
	sta	$10,x
	lda	#$003C
	sta	$16,x
	stz	$12,x
	cpy	#$0010
	bcs	@small_sprite
	lda	#.loword(metasprite_06C46D)
	bra	@set_sprite
@small_sprite:
	lda	#.loword(metasprite_06C472)
@set_sprite:
	sta	$00,x
	lda	#$3600
	sta	$02,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8	; [num]
	sta	$2A,x
	lda	zp_00
	sta	$30,x
	stz	$32,x
	lda	#$0080
	sta	$36,x
	lda	#$0010
	sta	$38,x
	stx	zp_00
	iny
	iny
	cpy	#$0020
	bcc	@loop
	plx
	lda	#$008D
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_TYPE
	rts

; Places the winged alien's other hitboxes (slots 4, 5: type $53; slot 22: the
; tail root) relative to it; the wing hitbox height follows the wing frame
; (winged_alien_wing_hitbox_h); then winged_alien_set_bg2_scroll.
winged_alien_place_parts:
	lda	OBJ_X,x
	sec
	sbc	#$0028
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0030
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	lda	OBJ_X,x
	sec
	sbc	#$0050
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0010
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	phy
	lda	$30,x
	and	#$0001
	asl	a
	tay
	lda	a:winged_alien_wing_hitbox_h,y
	ply
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0040
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_HITBOX_W
	lda	OBJ_X,x
	clc
	adc	#$FFC8
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0014
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_Y

winged_alien_set_bg2_scroll:
	lda	#$00B8
	sec
	sbc	OBJ_X,x
	and	#$00FF
	sta	a:bg2_x
	lda	#$0175
	sec
	sbc	OBJ_Y,x
	and	#$01FF
	sta	a:bg2_y
	rts

; Object type $8D. Stage 6, winged_alien: the tip of the tail.
update_winged_alien_tail_tip:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_tail_tip_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_tail_tip_states:
	.addr	winged_alien_tail_tip_state_00
	.addr	winged_alien_tail_state_01
	.addr	winged_alien_tail_state_02

; Object type $25. Stage 6: one of the 16 tail segments of winged_alien
; (states shared with winged_alien_tail_tip).
update_winged_alien_tail_segment:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_tail_segment_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_tail_segment_states:
	.addr	winged_alien_tail_segment_state_00
	.addr	winged_alien_tail_state_01
	.addr	winged_alien_tail_state_02

winged_alien_tail_tip_state_00:
	lda	a:$0036,x
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:winged_alien_tail_tip_sprites,y
	sta	OBJ_SPRITE,x

winged_alien_tail_segment_state_00:
	stx	zp_00
	lda	$30,x
	tay
	lda	a:$0038,y
	sta	$38,x
	lda	a:$0036,y
	clc
	adc	$38,x
	sta	$36,x
	and	#$01FE
	tax
	lda	f:circle15_y,x
	bmi	@y_negative
	lsr	a
	bra	@y_halved
@y_negative:
	sec
	ror	a
@y_halved:
	pha
	lda	f:circle15_x,x
	bmi	@x_negative
	lsr	a
	bra	@x_halved
@x_negative:
	sec
	ror	a
@x_halved:
	clc
	adc	a:$000A,y
	ldx	zp_00
	sta	$0A,x
	pla
	clc
	adc	a:$000E,y
	ldx	zp_00
	sta	$0E,x
	rtl

winged_alien_tail_state_01:
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	rng_lo
	sta	OBJ_Y_VEL_SUB,x
	asl	a
	sta	OBJ_X_VEL_SUB,x
	lda	rng_lo
	and	#$0001
	sec
	sbc	#$0001
	sta	OBJ_X_VEL,x
	lda	rng_lo
	eor	#$CA63
	adc	frame_counter
	sta	rng_lo
	stz	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	rtl

winged_alien_tail_state_02:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0078
	bcc	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@return:
	rtl

winged_alien_queue_tiles:
	asl	a
	tay
	lda	a:ptrs_winged_alien_wing_blocks,y
	tay
	lda	#$0003
	sta	zp_02
	lda	#$0030
	sta	zp_08
	lda	#$4D0C
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Every 8 frames: wing frame (field $30) 0/1, drawn on BG by
; winged_alien_queue_tiles; winged_alien_flap_fast does the same every 2
; frames.
winged_alien_flap_slow:
	lda	stage_frame_counter
	bit	#$0007
	bne	winged_alien_flap_return
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
winged_alien_set_wing_frame:
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
winged_alien_flap_return:
	rts

winged_alien_flap_fast:
	lda	stage_frame_counter
	bit	#$0001
	bne	winged_alien_flap_return
	and	#$0002
	lsr	a
	bra	winged_alien_set_wing_frame

; Script steps 2-3: the alien vanishes stretched into vertical lines (seen in
; the emulator), a per-line BG2 vertical scroll (HDMA preset $0F, table built
; at $7E:E800) whose visible height (winged_alien_hdma_height) shrinks by 4 per frame;
; winged_alien_warp_in makes it grow back (steps 6-7). winged_alien_hdma_state is the
; step: start, shrink/grow, done.
winged_alien_warp_out:
	lda	f:winged_alien_hdma_state
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_warp_out_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_warp_out_steps:
	.addr	winged_alien_warp_start
	.addr	winged_alien_warp_shrink
	.addr	winged_alien_warp_done

winged_alien_warp_in:
	lda	f:winged_alien_hdma_state
	phx
	asl	a
	tax
	lda	f:tbl_winged_alien_warp_in_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_winged_alien_warp_in_steps:
	.addr	winged_alien_warp_start
	.addr	winged_alien_warp_grow
	.addr	winged_alien_warp_done

winged_alien_warp_start:
	jsr	a:winged_alien_warp_fill_lines
	jsr	a:winged_alien_warp_update_hdma
	lda	#$0001
	sta	f:winged_alien_hdma_state
	lda	#$000F
	sta	hdma_preset
	rts

winged_alien_warp_grow:
	jsr	a:winged_alien_warp_update_hdma
	lda	f:winged_alien_hdma_height
	clc
	adc	#$0004
	sta	f:winged_alien_hdma_height
	bmi	winged_alien_warp_finish
	cmp	#$0075
	bcs	winged_alien_warp_finish
	rts

winged_alien_warp_shrink:
	jsr	a:winged_alien_warp_update_hdma
	lda	f:winged_alien_hdma_height
	sec
	sbc	#$0004
	sta	f:winged_alien_hdma_height
	bmi	winged_alien_warp_finish
	cmp	#$0001
	bcc	winged_alien_warp_finish
	rts
winged_alien_warp_finish:
	lda	#$0002
	sta	f:winged_alien_hdma_state
	rts

winged_alien_warp_done:
	; (not executed in the CDL traces)
	rts

; Fills $7E:E880 with one BG2 vertical scroll value per line, counting down
; from bg2_y + $F0.
winged_alien_warp_fill_lines:
	phx
	ldx	#$0000
	lda	#$00F0
	clc
	adc	a:bg2_y
	and	#$01FF
@loop:
	sta	f:$7EE880,x
	dec	a
	and	#$01FF
	inx
	inx
	cpx	#$03C0
	bcc	@loop
	lda	#$01E0
	clc
	adc	#$E880
	sta	f:winged_alien_hdma_lines
	plx
	rts

winged_alien_warp_update_hdma:
	jsr	a:winged_alien_warp_compute_bands
	jmp	a:winged_alien_warp_write_hdma

; From the visible height (winged_alien_hdma_height) and the alien's y (winged_alien_hdma_center_y): the
; line counts of the HDMA bands (winged_alien_hdma_counts-835);
; winged_alien_warp_update_hdma writes them into the HDMA table at $7E:E800.
winged_alien_warp_compute_bands:
	lda	f:winged_alien_hdma_height
	lsr	a
	sta	zp_00
	lda	f:winged_alien_hdma_center_y
	sec
	sbc	zp_00
	cmp	#$0002
	bmi	@min_2
	bcc	@min_2
	cmp	#$00F0
	bcc	@store_top
	; (not executed in the CDL traces)
	lda	#$00F0
	bra	@store_top
@min_2:
	lda	#$0002
@store_top:
	sta	zp_02
	lsr	a
	pha
	adc	#$0000
	sta	f:winged_alien_hdma_counts
	pla
	sta	f:winged_alien_hdma_counts+2
	lda	f:winged_alien_hdma_height
	clc
	adc	zp_02
	sta	zp_04
	cmp	#$00F0
	bcc	@check_min_height
	lda	#$00F0
	sta	zp_04
	sec
	sbc	zp_02
	bra	@store_middle
@check_min_height:
	lda	f:winged_alien_hdma_height
	cmp	#$0002
	bcs	@store_middle
	lda	#$0002
@store_middle:
	lsr	a
	pha
	adc	#$0000
	sta	f:winged_alien_hdma_counts+4
	pla
	sta	f:winged_alien_hdma_counts+6
	lda	#$00F0
	sec
	sbc	zp_04
	bpl	@check_bottom
	; (not executed in the CDL traces)
	lda	#$0000
@check_bottom:
	cmp	#$0080
	bcc	@bottom_fits
	sec
	sbc	#$007F
	sta	f:winged_alien_hdma_counts+10
	lda	#$007F
	sta	f:winged_alien_hdma_counts+8
	rts
@bottom_fits:
	sta	f:winged_alien_hdma_counts+8
	lda	#$0000
	sta	f:winged_alien_hdma_counts+10
	rts
winged_alien_warp_write_hdma:
	lda	f:winged_alien_hdma_counts
	ora	#$0080
	sta	f:effect_hdma_buf
	lda	f:winged_alien_hdma_counts
	clc
	adc	f:winged_alien_hdma_counts+2
	asl	a
	sta	zp_00
	lda	f:winged_alien_hdma_lines
	sec
	sbc	zp_00
	sta	f:effect_hdma_buf+$01
	lda	f:winged_alien_hdma_counts+2
	ora	#$0080
	sta	f:effect_hdma_buf+$03
	lda	f:winged_alien_hdma_counts+2
	asl	a
	sta	zp_00
	lda	f:winged_alien_hdma_lines
	sec
	sbc	zp_00
	sta	f:effect_hdma_buf+$04
	lda	f:winged_alien_hdma_counts+4
	sta	f:effect_hdma_buf+$06
	lda	f:winged_alien_hdma_lines
	sta	f:effect_hdma_buf+$07
	lda	f:winged_alien_hdma_counts+6
	sta	f:effect_hdma_buf+$09
	lda	f:winged_alien_hdma_lines
	sta	f:effect_hdma_buf+$0A
	lda	f:winged_alien_hdma_counts+8
	ora	#$0080
	sta	f:effect_hdma_buf+$0C
	lda	f:winged_alien_hdma_lines
	sta	f:effect_hdma_buf+$0D
	lda	f:winged_alien_hdma_counts+10
	ora	#$0080
	sta	f:effect_hdma_buf+$0F
	lda	f:winged_alien_hdma_counts+8
	asl	a
	clc
	adc	f:winged_alien_hdma_lines
	sta	f:effect_hdma_buf+$10
	lda	#$0000
	sta	f:zp_12
	rts

; Object type $5F. Stage 6: the giant face with two side heads on necks
; (face_boss_side_head, face_boss_neck); spits face_boss_larva. HP by
; difficulty: 128/256/384 (face_boss_hp).
update_face_boss:
	lda	#$0030
	jsl	f:boss_flash_palette
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	face_boss_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_face_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_face_boss_states:
	.addr	face_boss_state_00
	.addr	face_boss_state_01
	.addr	face_boss_state_02
	.addr	face_boss_state_03
	.addr	face_boss_state_04
	.addr	face_boss_state_05
	.addr	face_boss_state_06
	.addr	face_boss_state_07
	.addr	face_boss_state_08
	.addr	face_boss_state_09

face_boss_state_00:
	ldy	difficulty
	lda	a:face_boss_hp,y
	sta	OBJ_HP,x
	lda	#$004A
	sta	a:bg2sc_shadow
	stz	$30,x
	stz	$32,x
	stz	$34,x
	jsr	a:face_boss_init_parts
	jsr	a:face_boss_place_parts
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	@start
	rtl
@start:
	lda	#$0006
	jsl	f:apply_palette_anim_once
face_boss_set_state_02:
	lda	#$0044
	jsl	f:queue_sound
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x

face_boss_state_02:
	dec	OBJ_TIMER,x
	bne	@descend
	lda	#$0044
	jsl	f:queue_sound
@descend:
	lda	stage_frame_counter
	lsr	a
	bcs	@shake
	lda	OBJ_Y,x
	inc	a
	sta	OBJ_Y,x
	cmp	#$0020
	bpl	@arrived
	jsr	a:face_boss_place_parts
@shake:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:face_boss_update_eyes
	jsr	a:face_boss_draw_eyes
	rtl
@arrived:
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#$0024
	sta	OBJ_Y,x
	jsr	a:face_boss_place_parts
	lda	#$0200
	sta	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x

face_boss_state_03:
	lda	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	beq	@attack
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	@heads_lost
@attack:
	dec	OBJ_TIMER,x
	bpl	@pick_attack
	lda	a:obj_slots+8*OBJ_SIZE+$30
	ora	a:obj_slots+9*OBJ_SIZE+$30
	bne	@reset_attack
	brl	face_boss_set_state_04
@reset_attack:
	stz	OBJ_TIMER,x
	stz	$38,x
	bra	@send_heads
@pick_attack:
	jsr	a:face_boss_pick_head_attack
@send_heads:
	jsr	a:face_boss_send_side_heads
	jsr	a:face_boss_update_eyes
	jsr	a:face_boss_draw_eyes
	lda	#$0002
	sta	a:shake_timer
	rtl
@heads_lost:
	lda	#$0006
	sta	OBJ_STATE,x

face_boss_state_06:
	jsr	a:face_boss_update_eyes
	ldy	difficulty
	lda	stage_frame_counter
	and	a:face_boss_soldier_spawn_masks,y
	bne	@check_spit
	lda	rng_lo
	bit	#$0001
	bne	@right_soldier
	ldy	#$0300
	jsr	a:face_boss_spawn_left_soldier
	bra	@check_spit
@right_soldier:
	ldy	#$0300
	jsr	a:face_boss_spawn_right_soldier
@check_spit:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:face_boss_larva_spit_masks,y
	bne	@spit
	lda	#$0030
	sta	$36,x
@spit:
	ldy	#$0300
	jsr	a:face_boss_spit_larva
	jsr	a:face_boss_draw_mouth
	jsr	a:face_boss_draw_eyes
	lda	#$0002
	sta	a:shake_timer
	rtl
face_boss_set_state_04:
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_state_04:
	lda	stage_frame_counter
	lsr	a
	bcs	@shake
	lda	OBJ_Y,x
	dec	a
	sta	OBJ_Y,x
	cmp	#$FFF0	; [num]
	bmi	@risen
	jsr	a:face_boss_place_parts
@shake:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:face_boss_update_eyes
	jsr	a:face_boss_draw_eyes
	jsr	a:face_boss_make_heads_fire
	rtl
@risen:
	ldy	#$0700
	jsr	a:face_boss_spawn_soldier_at_lost_head
	lda	#$0030
	sta	$36,x
	sta	OBJ_TIMER,x
	lda	#$0005
	sta	OBJ_STATE,x

face_boss_state_05:
	dec	OBJ_TIMER,x
	bpl	@spit
	brl	face_boss_set_state_02
@spit:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:face_boss_update_eyes
	ldy	#$0700
	jsr	a:face_boss_spit_larva
	jsr	a:face_boss_draw_mouth
	jsr	a:face_boss_draw_eyes
	jsr	a:face_boss_make_heads_fire
	rtl
face_boss_die:
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#$8000	; [num]
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$FFFF	; [num]
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_HP
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HP
	jsr	a:face_boss_update_eyes
	jsr	a:face_boss_draw_eyes
	lda	#$0300
	sta	OBJ_TIMER,x
	lda	#$0007
	sta	OBJ_STATE,x

face_boss_state_07:
	dec	OBJ_TIMER,x
	bmi	@explosions_done
	jsl	f:queue_sound_41_throttled
	lda	#$0004
	sta	a:shake_timer
	lda	#$0040
	sta	zp_00
	lda	#$0040
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rtl
@explosions_done:
	lda	#$0059
	jsl	f:queue_sound
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x

face_boss_state_08:
	lda	OBJ_ANIM_TIMER,x
	beq	@wait
	jsr	a:face_boss_death_tiles_step
	dec	OBJ_ANIM_TIMER,x
@wait:
	dec	OBJ_TIMER,x
	bmi	@reveal_brain
	rtl
@reveal_brain:
	lda	#$0003
	sta	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x

face_boss_state_09:
	jsr	a:face_boss_reveal_brain_step
	dec	OBJ_ANIM_TIMER,x
	bne	@return
	lda	#OBJT_BRAIN_BOSS
	sta	OBJ_TYPE,x
	stz	OBJ_STATE,x
@return:
	rtl

; Random attack bits in field $38 (bit 0: left head, bit 1: right head, bit 2:
; both), masked by difficulty (face_boss_head_attack_masks); only values below
; 8 are kept.
face_boss_pick_head_attack:
	ldy	difficulty
	lda	rng_lo
	and	a:face_boss_head_attack_masks,y
	cmp	#$0008
	bcc	@store
	lda	#$0000
@store:
	sta	$38,x
	rts

; Starts the lunge of the side heads (slots 8, 9: field $30 = 2) chosen in
; field $38, when they are idle; face_boss_send_left_head does the left one.
face_boss_send_side_heads:
	jsr	a:face_boss_send_left_head
	jmp	a:face_boss_send_right_head

face_boss_send_left_head:
	lda	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	@return
	lda	a:obj_slots+8*OBJ_SIZE+$30
	bne	@return
	lda	a:obj_slots+9*OBJ_SIZE+$34
	bne	@return
	lda	$38,x
	bit	#$0001
	beq	@return
	bit	#$0004
	beq	@left_only
	lda	a:obj_slots+9*OBJ_SIZE+$30
	bne	@return
	lda	#$0002
	sta	a:obj_slots+8*OBJ_SIZE+$30
	stz	a:obj_slots+8*OBJ_SIZE+$32
	sta	a:obj_slots+8*OBJ_SIZE+$34
	rts
@left_only:
	lda	#$0002
	sta	a:obj_slots+8*OBJ_SIZE+$30
	stz	a:obj_slots+8*OBJ_SIZE+$32
	stz	a:obj_slots+8*OBJ_SIZE+$34
@return:
	rts
face_boss_send_right_head:
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	@return
	lda	a:obj_slots+9*OBJ_SIZE+$30
	bne	@return
	lda	a:obj_slots+8*OBJ_SIZE+$34
	bne	@return
	lda	$38,x
	bit	#$0002
	beq	@return
	bit	#$0004
	beq	@right_only
	lda	a:obj_slots+8*OBJ_SIZE+$30
	bne	@return
	lda	#$0002
	sta	a:obj_slots+9*OBJ_SIZE+$30
	sta	a:obj_slots+9*OBJ_SIZE+$32
	sta	a:obj_slots+9*OBJ_SIZE+$34
	rts
@right_only:
	lda	#$0002
	sta	a:obj_slots+9*OBJ_SIZE+$30
	sta	a:obj_slots+9*OBJ_SIZE+$32
	stz	a:obj_slots+9*OBJ_SIZE+$34
@return:
	rts

; The two eyes (slots 6 and 7, type $53, HP face_boss_eye_hp): while alive
; each picks a frame looking towards a player
; (face_boss_eye_frame_toward_player; left eye player 1, right eye player 2);
; when shot (HP < 0) the frame becomes $8006 and the slot an explosion.
face_boss_update_eyes:
	jsr	a:face_boss_update_left_eye
	jsr	a:face_boss_update_right_eye
	rts

face_boss_update_left_eye:
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_TYPE
	cmp	#$0053
	bne	@return
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_HP
	bpl	@alive
	lda	#$8006	; [num]
	sta	$30,x
	ldy	#$0380
	jmp	a:face_boss_eye_explode
@alive:
	ldy	#$0200
	lda	a:p1_lives
	bne	@look
	; (not executed in the CDL traces)
	ldy	#$0240
@look:
	jsr	a:face_boss_eye_frame_toward_player
	sta	$30,x
@return:
	rts

face_boss_update_right_eye:
	lda	a:obj_slots+7*OBJ_SIZE+OBJ_TYPE
	cmp	#$0053
	bne	@return
	lda	a:obj_slots+7*OBJ_SIZE+OBJ_HP
	bpl	@alive
	lda	#$8006	; [num]
	sta	$32,x
	ldy	#$03C0
	jmp	a:face_boss_eye_explode
@alive:
	ldy	#$0240
	lda	a:p2_lives
	bne	@look
	ldy	#$0200
@look:
	jsr	a:face_boss_eye_frame_toward_player
	sta	$32,x
@return:
	rts

; A = eye frame (face_boss_eye_frames) from the top 3 bits of field $1312,y of
; player Y (p1_view_y; compared with object x elsewhere in the side view,
; apparently the player's x).
face_boss_eye_frame_toward_player:
	lda	a:$1312,y
	asl	a
	asl	a
	asl	a
	asl	a
	xba
	and	#$000E
	tay
	lda	a:face_boss_eye_frames,y
	rts
face_boss_eye_explode:
	lda	#$0041
	jsl	f:queue_sound
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001A,y
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rts

face_boss_spit_larva:
	lda	$36,x
	beq	@return
	cmp	#$0020
	bne	@set_mouth_frame
	jsr	a:spawn_face_boss_larva
@set_mouth_frame:
	ldy	#$8000	; [num]
	dec	$36,x
	beq	@store_frame
	ldy	#$8002	; [num]
@store_frame:
	sty	$34,x
@return:
	rts

spawn_face_boss_larva:
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#OBJT_FACE_BOSS_LARVA
	sta	a:$0010,y
	lda	rng_lo
	and	#$0080
	ora	#$0040
	sta	a:$0004,y
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	clc
	adc	#$0048
	sta	a:$000E,y
@return:
	rts

; face_boss_state_00: the hitboxes in slots 4 and 5 (type $53, not targets),
; the eyes (slots 6, 7, HP face_boss_eye_hp by difficulty) and the side heads
; (slots 8, 9, OBJT_FACE_BOSS_SIDE_HEAD).
face_boss_init_parts:
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$00FA
	sta	OBJ_X,x
	lda	#$FFA0	; [num]
	sta	OBJ_Y,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0053
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_TYPE
	lda	#$003D
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	lda	#$0030
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFC0	; [num]
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0053
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_TYPE
	lda	#$003D
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$0030
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFC0	; [num]
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0053
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_TYPE
	ldy	difficulty
	lda	a:face_boss_eye_hp,y
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_HP
	lda	#$4011
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_FLAGS
	lda	#$000C
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFF4	; [num]
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0053
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_TYPE
	ldy	difficulty
	lda	a:face_boss_eye_hp,y
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HP
	lda	#$4011
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_FLAGS
	lda	#$000C
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFF4	; [num]
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0075
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	stz	a:obj_slots+8*OBJ_SIZE+$32
	lda	#$0075
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	lda	#$0002
	sta	a:obj_slots+9*OBJ_SIZE+$32
	rts

face_boss_place_parts:
	stz	a:bg2_x
	lda	#$0124
	sec
	sbc	OBJ_Y,x
	and	#$01FF
	sta	a:bg2_y
	lda	OBJ_X,x
	sec
	sbc	#$0074
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0018
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	lda	OBJ_X,x
	clc
	adc	#$0048
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0018
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	lda	OBJ_X,x
	sec
	sbc	#$0006
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0020
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_Y
	lda	OBJ_X,x
	clc
	adc	#$0006
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_X
	lda	OBJ_Y,x
	clc
	adc	#$0020
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_Y
	rts

; face_boss_queue_tiles (left eye, field $30) and the right eye (field $32):
; when the frame has bit 15 set, one VRAM block from face_boss_left_eye_tiles
; / face_boss_right_eye_tiles.
face_boss_draw_eyes:
	jsr	a:face_boss_queue_tiles
	jmp	a:face_boss_draw_right_eye

face_boss_queue_tiles:
	lda	$30,x
	bpl	@return
	and	#$0006
	sta	$30,x
	tay
	lda	a:face_boss_left_eye_tiles,y
	sta	zp_00
	lda	#$4C8C
	jsl	f:queue_vram_block
@return:
	rts
face_boss_draw_right_eye:
	lda	$32,x
	bpl	@return
	and	#$0006
	sta	$32,x
	tay
	lda	a:face_boss_right_eye_tiles,y
	sta	zp_00
	lda	#$4C90
	jsl	f:queue_vram_block
@return:
	rts

; When field $34 has bit 15 set (face_boss_spit_larva): the mouth frame, 2
; blocks from ptrs_face_boss_mouth_blocks.
face_boss_draw_mouth:
	lda	$34,x
	bpl	@return
	and	#$0002
	sta	$34,x
	tay
	lda	a:ptrs_face_boss_mouth_blocks,y
	tay
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	#$4D0C
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rts

; face_boss_state_08 (4 steps) and face_boss_reveal_brain_step (state 9, 3
; steps): BG blocks that erase the face and uncover the brain, whose type then
; replaces the face (seen in the emulator).
face_boss_death_tiles_step:
	lda	OBJ_ANIM_TIMER,x
	asl	a
	tay
	lda	a:ptrs_face_boss_death_blocks,y
	pha
	lda	#$0004
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	a:face_boss_death_vram_addrs,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

face_boss_reveal_brain_step:
	lda	OBJ_ANIM_TIMER,x
	asl	a
	tay
	lda	a:ptrs_face_boss_reveal_blocks,y
	pha
	lda	#$0008
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	a:face_boss_reveal_vram_addrs,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Every 32 frames sets field $3A of both side heads to $10; at 8 the head
; fires (face_boss_side_head_fire).
face_boss_make_heads_fire:
	lda	stage_frame_counter
	bit	#$001F
	bne	@return
	lda	#$0010
	sta	a:obj_slots+8*OBJ_SIZE+$3A
	sta	a:obj_slots+9*OBJ_SIZE+$3A
@return:
	rts

; Spawns an alien soldier (type $24) on the side whose head is gone
; (face_boss_spawn_left_soldier, face_boss_spawn_right_soldier).
face_boss_spawn_soldier_at_lost_head:
	lda	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	beq	@check_right
	bra	face_boss_spawn_left_soldier
@check_right:
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	beq	@return
	; (not executed in the CDL traces)
	bra	face_boss_spawn_right_soldier
@return:
	rts

face_boss_spawn_left_soldier:
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#OBJT_FACE_BOSS_SOLDIER
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	OBJ_X,x
	clc
	adc	#$FF97
	sta	a:$000A,y
	lda	OBJ_Y,x
	clc
	adc	#$0034
	sta	a:$000E,y
@return:
	rts

face_boss_spawn_right_soldier:
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#OBJT_FACE_BOSS_SOLDIER
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	OBJ_X,x
	clc
	adc	#$005E
	sta	a:$000A,y
	lda	OBJ_Y,x
	clc
	adc	#$0034
	sta	a:$000E,y
@return:
	rts

; A = CGRAM address: while the hit flash runs (OBJ_SAVED_ATTR set), uploads
; the flash palette ($05:912A) there (bosses drawn on BG2: face boss, heart
; boss).
boss_flash_palette:
	ldy	OBJ_SAVED_ATTR,x
	beq	@return
	sta	cgram_upload_addr
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
@return:
	rtl

; Object type $61. Stage 6: toothed mouths in the floor that release
; floor_mouth_bug. HP by difficulty: 32/40/48 (floor_mouth_hp).
update_floor_mouth:
	lda	OBJ_HP,x
	bpl	@flash
	stz	OBJ_HP,x
	lda	#$0008
	sta	OBJ_STATE,x
@flash:
	lda	OBJ_SAVED_ATTR,x
	beq	@dispatch
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_floor_mouth_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_floor_mouth_states:
	.addr	floor_mouth_state_00
	.addr	floor_mouth_state_01
	.addr	floor_mouth_state_02
	.addr	floor_mouth_state_03
	.addr	floor_mouth_state_04
	.addr	floor_mouth_state_05
	.addr	floor_mouth_state_06
	.addr	floor_mouth_state_07
	.addr	floor_mouth_state_08
	.addr	floor_mouth_state_09

floor_mouth_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	ldy	difficulty
	lda	a:floor_mouth_hp,y
	sta	OBJ_HP,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_01:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	ldy	difficulty
	cmp	a:floor_mouth_wait_times,y
	bcc	@return
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_state_03:
	lda	#$0000
	jsr	a:floor_mouth_set_tiles
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_02:
	lda	OBJ_TIMER,x
	and	#$0007
	bne	@tick
	lda	OBJ_TIMER,x
	and	#$0008
	bne	@frame_1
	lda	#$0000
	bra	@set_tiles
@frame_1:
	lda	#$0001
@set_tiles:
	jsr	a:floor_mouth_set_tiles
@tick:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$001E
	bcc	@return
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_state_04:
	stz	$30,x
@loop:
	jsl	f:find_free_slot_y
	bcs	@return
	lda	#OBJT_FLOOR_MOUTH_BUG
	sta	a:$0010,y
	lda	OBJ_X,x
	clc
	adc	#$0008
	sta	a:$000A,y
	lda	OBJ_Y,x
	sec
	sbc	#$0008
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0008,y
	sta	a:$000C,y
	lda	$30,x
	sta	a:$0030,y
	inc	$30,x
	lda	$30,x
	cmp	#$0003
	bcc	@loop
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_state_05:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0078
	bcc	@return
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_state_06:
	lda	#$0001
	jsr	a:floor_mouth_set_tiles
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_07:
	lda	#$0001
	sta	OBJ_STATE,x
	rtl

floor_mouth_state_08:
	lda	#$0002
	jsr	a:floor_mouth_set_tiles
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#.loword(anim_05C558)
	sta	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	lda	OBJ_X,x
	clc
	adc	#$0008
	sta	OBJ_X,x
	lda	OBJ_Y,x
	sec
	sbc	#$0008
	sta	OBJ_Y,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_09:
	lda	OBJ_ANIM,x
	bne	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	stz	OBJ_SPRITE,x
	stz	OBJ_TYPE,x
@return:
	rtl

; zp_00 = BG1 tilemap VRAM address under the mouth (from its position and the
; BG1 scroll).
floor_mouth_tilemap_addr:
	lda	OBJ_X,x
	clc
	adc	#$0010
	clc
	adc	a:bg1_x
	sta	zp_02
	and	#$00E0
	lsr	a
	lsr	a
	lsr	a
	sta	zp_00
	lda	OBJ_Y,x
	sec
	sbc	#$0010
	clc
	adc	a:bg1_y
	and	#$00E0
	asl	a
	asl	a
	clc
	adc	zp_00
	sta	zp_00
	lda	zp_02
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$4000
	clc
	adc	zp_00
	sta	zp_00
	rts

; A = frame (0 closed, 1 open, 2 destroyed): one 8-byte block from
; ptrs_floor_mouth_tiles at floor_mouth_tilemap_addr.
floor_mouth_set_tiles:
	asl	a
	tay
	lda	#$0001
	sta	zp_02
	lda	#$0008
	sta	zp_08
	lda	a:ptrs_floor_mouth_tiles,y
	tay
	jsr	a:floor_mouth_tilemap_addr
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Object type $62. Stage 6: bug released by floor_mouth. HP by difficulty:
; 1/1/2 (floor_mouth_bug_hp).
update_floor_mouth_bug:
	lda	OBJ_HP,x
	bpl	@dispatch
	lda	#$0007
	sta	OBJ_STATE,x
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_floor_mouth_bug_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_floor_mouth_bug_states:
	.addr	floor_mouth_bug_state_00
	.addr	floor_mouth_bug_state_01
	.addr	floor_mouth_bug_state_02
	.addr	floor_mouth_bug_state_01
	.addr	aim_velocity_at_player
	.addr	floor_mouth_bug_state_05
	.addr	floor_mouth_bug_state_06
	.addr	floor_mouth_bug_state_07
	.addr	floor_mouth_bug_state_08

floor_mouth_bug_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3600
	sta	OBJ_ATTR,x
	ldy	difficulty
	lda	a:floor_mouth_bug_hp,y
	sta	OBJ_HP,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	$30,x
	asl	a
	tay
	lda	a:floor_mouth_bug_x_vel_subs,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:floor_mouth_bug_x_vels,y
	sta	OBJ_X_VEL,x
	lda	a:floor_mouth_bug_y_vel_subs,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:floor_mouth_bug_y_vels,y
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_TIMER,x
	lda	#.loword(anim_05EE50)
	sta	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_bug_state_01:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$003C
	bcc	floor_mouth_bug_return
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_bug_state_02:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
floor_mouth_bug_return:
	rtl

aim_velocity_at_player:
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	jsl	f:pick_random_player
	sec
	lda	a:$1312,y
	sbc	zp_00
	sta	zp_08
	sec
	lda	a:$1314,y
	sbc	zp_02
	sta	zp_0A
	jsl	f:calc_angle
	lsr	a
	lsr	a
	and	#$00FE
	ldy	difficulty
	clc
	adc	a:ptrs_enemy_bullet_speeds,y
	tay
	lda	a:$0000,y
	sta	OBJ_Y_VEL,x
	lda	a:$0010,y
	sta	OBJ_X_VEL,x
	lda	a:$0050,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:$0060,y
	sta	OBJ_X_VEL_SUB,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_bug_state_05:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0040
	bcc	@return
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_bug_state_06:
	inc	$30,x
	lda	$30,x
	cmp	#$0004
	bcc	@again
	lda	#$0007
	bra	@set_state
@again:
	lda	#$0002
@set_state:
	sta	OBJ_STATE,x
	rtl

floor_mouth_bug_state_07:
	stz	OBJ_HP,x
	lda	#$000B
	jsl	f:queue_sound
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$3000
	sta	OBJ_ATTR,x
	lda	#.loword(anim_05C59A)
	sta	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x
	rtl

floor_mouth_bug_state_08:
	lda	OBJ_ANIM,x
	bne	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	stz	OBJ_SPRITE,x
	stz	OBJ_TYPE,x
@return:
	rtl

; Object type $63. Stage 6: larva spat by wall_worm (states shared with
; face_boss_larva). HP by difficulty: 4/8/16 (wall_worm_larva_hp).
update_wall_worm_larva:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	@check_hp
	brl	larva_die
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	larva_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_wall_worm_larva_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_wall_worm_larva_states:
	.addr	wall_worm_larva_state_00
	.addr	wall_worm_larva_state_01
	.addr	larva_state_02
	.addr	larva_state_03

wall_worm_larva_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	ldy	difficulty
	lda	a:wall_worm_larva_hp,y
	sta	OBJ_HP,x
	lda	#$0014
	sta	OBJ_HITBOX_W,x
	lda	#$FFEC	; [num]
	sta	OBJ_HITBOX_H,x
	lda	rng_lo
	and	#$0002
	tay
	lda	a:wall_worm_larva_start_angles,y
	sta	OBJ_FACING,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	lda	#.loword(anim_05EE68)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x

wall_worm_larva_state_01:
	dec	OBJ_TIMER,x
	bmi	@chase
	lda	#$0010
	jml	f:set_velocity_from_angle
@chase:
	lda	#$0002
	sta	OBJ_STATE,x

larva_state_02:
	jsr	a:larva_turn_toward_player
	lda	#$0010
	jml	f:set_velocity_from_angle
larva_die:
	lda	#$000C
	jsl	f:queue_sound
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	#.loword(anim_05C4CE)
	txy
	jml	f:make_effect_object

larva_state_03:
	; (not executed in the CDL traces)
	rtl

; Turns OBJ_ANGLE one step towards the target player (larva_pick_player);
; the caller then moves along it (set_velocity_from_angle).
larva_turn_toward_player:
	jsr	a:larva_pick_player
	lda	a:$000A,y
	sec
	sbc	OBJ_X,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	sta	zp_0A
	jsl	f:calc_angle
	sep	#$20
	.a8
	sec
	sbc	OBJ_ANGLE,x
	bmi	@dec_angle
	inc	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts
@dec_angle:
	.a8
	dec	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts

; Y = the player the larva chases: the one in play, or by the parity of the
; slot when both are.
larva_pick_player:
	lda	a:p2_lives
	bne	@check_p1
@player1:
	ldy	#$0200
	rts
@check_p1:
	lda	a:p1_lives
	bne	@both_alive
@player2:
	ldy	#$0240
	rts
@both_alive:
	txa
	bit	#$0040
	beq	@player1
	bra	@player2

; Object type $21. Stage 6: larva spat by face_boss's central mouth; crawls
; toward a player. HP by difficulty: 2/4/8 (face_boss_larva_hp).
update_face_boss_larva:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	@check_hp
	brl	larva_die
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	larva_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_face_boss_larva_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_face_boss_larva_states:
	.addr	face_boss_larva_state_00
	.addr	face_boss_larva_state_01
	.addr	face_boss_larva_state_02
	.addr	larva_state_03

face_boss_larva_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	ldy	difficulty
	lda	a:face_boss_larva_hp,y
	sta	OBJ_HP,x
	lda	#$0014
	sta	OBJ_HITBOX_W,x
	lda	#$FFEC	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
face_boss_larva_set_state_01:
	lda	#.loword(anim_05EE68)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0100
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_larva_state_01:
	dec	OBJ_TIMER,x
	bmi	@head_back
	jsr	a:larva_turn_toward_player
	lda	#$0010
	jml	f:set_velocity_from_angle
@head_back:
	lda	#$0001
	sta	$30,x
	lda	#$0010
	sta	$32,x
	lda	#$0200
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x

face_boss_larva_state_02:
	dec	OBJ_TIMER,x
	bmi	face_boss_larva_set_state_01
	lda	#$0010
	jsr	a:face_boss_larva_turn_toward_boss
	lda	#$0010
	jml	f:set_velocity_from_angle

; Turns OBJ_ANGLE by zp_00 towards the face boss (slot $0900; state 2 of the
; larva, probably going back to the mouth).
face_boss_larva_turn_toward_boss:
	sta	zp_00
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	sec
	sbc	#$0008
	sec
	sbc	OBJ_X,x
	sta	zp_08
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0004
	sec
	sbc	OBJ_Y,x
	sta	zp_0A
	jsl	f:calc_angle
	sep	#$20
	.a8
	sec
	sbc	OBJ_ANGLE,x
	bmi	@dec_angle
	lda	OBJ_ANGLE,x
	clc
	adc	zp_00
	sta	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts
@dec_angle:
	.a8
	lda	OBJ_ANGLE,x
	sec
	sbc	zp_00
	sta	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts

; Object type $68. Stage 6, heart_boss: grey crawlers that come out of the
; pods (type $67) on the ceiling and the floor (seen in the emulator). HP by difficulty: 0/2/4
; (heart_boss_crawler_hp).
update_heart_boss_crawler:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	@check_hp
	brl	heart_boss_crawler_die
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	heart_boss_crawler_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_heart_boss_crawler_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_heart_boss_crawler_states:
	.addr	heart_boss_crawler_state_00
	.addr	heart_boss_crawler_state_01
	.addr	heart_boss_crawler_state_02
	.addr	heart_boss_crawler_state_03
	.addr	heart_boss_crawler_state_04
	.addr	heart_boss_crawler_state_05

heart_boss_crawler_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	ldy	difficulty
	lda	a:heart_boss_crawler_hp,y
	sta	OBJ_HP,x
	lda	#$0014
	sta	OBJ_HITBOX_W,x
	lda	#$FFEC	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0070
	cmp	OBJ_Y,x
	lda	#$0000
	rol	a
	asl	a
	sta	$30,x
	tay
	lda	a:heart_boss_crawler_start_y_vels,y
	sta	OBJ_Y_VEL,x
	lda	a:heart_boss_crawler_start_y_vel_subs,y
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0000
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_FACING,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	ldy	$30,x
	lda	a:heart_boss_crawler_sprites,y
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	lda	#$0001
	sta	OBJ_STATE,x

heart_boss_crawler_state_01:
	ldy	$30,x
	jsr	a:heart_boss_crawler_check_landed
	bcs	heart_boss_crawler_land
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	a:heart_boss_crawler_gravity_subs,y
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	a:heart_boss_crawler_gravity,y
	sta	OBJ_Y_VEL,x
	rtl

; Y = 0: carry set at y >= $B8 (floor); else at y <= $48 (ceiling).
heart_boss_crawler_check_landed:
	bne	@ceiling
	lda	OBJ_Y,x
	cmp	#$00B8
	rts
@ceiling:
	lda	#$0048
	cmp	OBJ_Y,x
	rts
heart_boss_crawler_land:
	ldy	$30,x
	lda	a:heart_boss_crawler_landing_y,y
	sta	OBJ_Y,x
	stz	OBJ_Y_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:heart_boss_crawler_walk_anims,y
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x

heart_boss_crawler_state_02:
	jsr	a:heart_boss_crawler_check_player_x
	bcc	@return
	lda	$30,x
	bne	@drop
	brl	heart_boss_crawler_set_state_04
@drop:
	bra	heart_boss_crawler_set_state_03
@return:
	rtl

; Carry set (half of the time, at random) when a living player's
; p1_view_y/p2_view_y + $20 is within 2 pixels of the object's x: then it
; drops (or jumps) to the other side.
heart_boss_crawler_check_player_x:
	lda	a:p1_lives
	beq	@check_p2
	lda	a:player1_obj+PLAYER_CENTER_X
	clc
	adc	#$0020
	sec
	sbc	OBJ_X,x
	cmp	#$0002
	bcc	@coin_flip
@check_p2:
	lda	a:p2_lives
	beq	@no
	lda	a:player2_obj+PLAYER_CENTER_X
	clc
	adc	#$0020
	sec
	sbc	OBJ_X,x
	cmp	#$0002
	bcc	@coin_flip
@no:
	clc
	rts
@coin_flip:
	lda	rng_lo
	bit	#$0001
	bne	@no
	sec
	rts
heart_boss_crawler_set_state_03:
	stz	$30,x
	lda	#.loword(metasprite_06C307)
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0000
	sta	OBJ_X_VEL_SUB,x
	lda	#$0003
	sta	OBJ_Y_VEL,x
	lda	#$0000
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0003
	sta	OBJ_STATE,x

heart_boss_crawler_state_03:
	lda	OBJ_Y,x
	cmp	#$00B8
	bcc	@return
	brl	heart_boss_crawler_land
@return:
	rtl
heart_boss_crawler_set_state_04:
	lda	#$0002
	sta	$30,x
	stz	OBJ_ANIM,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0000
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0004
	sta	OBJ_STATE,x

heart_boss_crawler_state_04:
	lda	#$0048
	cmp	OBJ_Y,x
	bcc	@return
	brl	heart_boss_crawler_land
@return:
	rtl
heart_boss_crawler_die:
	lda	#$000E
	jsl	f:queue_sound
	lda	#$001D
	sta	OBJ_TYPE,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	#.loword(anim_05C4CE)
	txy
	jml	f:make_effect_object

heart_boss_crawler_state_05:
	; (not executed in the CDL traces)
	rtl

; Object type $58. Stage 6: the giant heart with tendrils (second boss of the
; stage). HP by difficulty: 128/256/384 (heart_boss_hp).
update_heart_boss:
	lda	#$0060
	jsl	f:boss_flash_palette
	lda	a:boss_hit_sound_timer
	beq	@check_flash
	dec	a:boss_hit_sound_timer
@check_flash:
	lda	OBJ_SAVED_ATTR,x
	beq	@check_hp
	lda	a:boss_hit_sound_timer
	bne	@check_hp
	lda	#$003C
	jsl	f:queue_sound
	lda	#$0004
	sta	a:boss_hit_sound_timer
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	heart_boss_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_heart_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_heart_boss_states:
	.addr	heart_boss_state_00
	.addr	heart_boss_state_01
	.addr	heart_boss_state_02
	.addr	heart_boss_state_03
	.addr	heart_boss_state_04
	.addr	heart_boss_state_05
	.addr	heart_boss_state_06

heart_boss_state_00:
	ldy	difficulty
	lda	a:heart_boss_hp,y
	sta	OBJ_HP,x
	lda	#$0049
	sta	a:bg2sc_shadow
	lda	#$0080
	sta	a:bg2_x
	stz	a:bg2_y
	jsr	a:heart_boss_init_hitboxes
	lda	#$0001
	sta	a:stage_checkpoint
	jsr	a:spawn_heart_boss_bug
	lda	#$0009
	sta	a:bg2_scroll_mode
	inc	OBJ_STATE,x

heart_boss_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	@start
	jsr	a:heart_boss_beat
	rtl
@start:
	inc	OBJ_STATE,x

heart_boss_state_02:
	jsr	a:heart_boss_beat
	rtl
heart_boss_die:
	lda	#$0052
	jsl	f:queue_sound
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#$8000	; [num]
	ldy	$30,x
	sta	a:$0016,y
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x

heart_boss_state_03:
	dec	OBJ_TIMER,x
	bmi	@explosions_done
	lda	#$0004
	sta	a:shake_timer
	lda	#$0080
	sta	zp_00
	lda	#$00A0
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rtl
@explosions_done:
	lda	#$0003
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

heart_boss_state_04:
	jsr	a:heart_boss_queue_death_tiles
	dec	OBJ_TIMER,x
	beq	@tiles_done
	rtl
@tiles_done:
	lda	#$0081
	jsl	f:queue_sound
	phx
	ldx	#.loword(load_list_059EC9)
	jsl	f:load_data_list
	plx
	lda	#$0080
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

heart_boss_state_05:
	dec	OBJ_TIMER,x
	bmi	@request_song
	bne	@return
	lda	#$0083
	jsl	f:queue_sound
@return:
	rtl
@request_song:
	phx
	ldx	#.loword(song_set_heart_boss)
	jsl	f:request_song_set
	plx
	inc	OBJ_STATE,x

heart_boss_state_06:
	lda	apu_pending_cmd
	cmp	#$00FF
	beq	@return
	lda	#$0069
	jsl	f:queue_sound
	stz	a:bg1_scroll_mode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@return:
	rtl

; heart_boss_state_04: BG blocks by OBJ_TIMER (3-1); word 0 of
; heart_boss_death_vram_addrs is the hard HP of heart_boss_hp.
heart_boss_queue_death_tiles:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	OBJ_TIMER,x
	asl	a
	tay
	lda	a:ptrs_heart_boss_death_blocks,y
	pha
	lda	a:heart_boss_death_vram_addrs,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Every 8 frames alternates the two frames of the heart
; (ptrs_heart_boss_beat_blocks, VRAM $4D90).
heart_boss_beat:
	lda	OBJ_ANIM_TIMER,x
	inc	OBJ_ANIM_TIMER,x
	bit	#$0007
	bne	@return
	ldy	vram_block_queue_end
	cpy	#$0010
	bcc	@queue_frame
	; (not executed in the CDL traces)
	dec	OBJ_ANIM_TIMER,x
	rts
@queue_frame:
	lsr	a
	lsr	a
	and	#$0002
	tay
	lda	a:ptrs_heart_boss_beat_blocks,y
	tay
	lda	#$0003
	sta	zp_02
	lda	#$0030
	sta	zp_08
	lda	#$4D90
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rts

; The heart's own hitbox and a big type $53 one (not a target) under it, slot
; kept in field $30.
heart_boss_init_hitboxes:
	lda	#$001D
	sta	OBJ_FLAGS,x
	lda	#$0110
	sta	OBJ_X,x
	lda	#$0090
	sta	OBJ_Y,x
	lda	#$0040
	sta	OBJ_HITBOX_W,x
	lda	#$FFD0	; [num]
	sta	OBJ_HITBOX_H,x
	jsl	f:find_free_slot_y
	bcs	@return
	sty	$30,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$0120
	sta	a:$000A,y
	lda	#$00C0
	sta	a:$000E,y
	lda	#$0050
	sta	a:$0028,y
	lda	#$FF60	; [num]
	sta	a:$002A,y
	clc
@return:
	rts

spawn_heart_boss_bug:
	phx
	ldx	#$0008
@loop:
	ldy	#$03C0
	jsl	f:find_free_slot_from_y
	bcs	@next
	lda	#OBJT_HEART_BOSS_BUG
	sta	a:$0010,y
	lda	a:heart_boss_bug_x,x
	sta	a:$000A,y
	lda	a:heart_boss_bug_y,x
	sta	a:$000E,y
	lda	a:heart_boss_bug_kinds,x
	sta	a:$0030,y
	lda	a:heart_boss_bug_vram_addrs,x
	sta	a:$0032,y
@next:
	dex
	dex
	bne	@loop
	plx
	rts

; Object type $67. Stage 6, heart_boss: crawling bugs. HP by difficulty:
; 32/64/128 (heart_boss_bug_hp).
update_heart_boss_bug:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	@check_hp
	brl	heart_boss_bug_die
@check_hp:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	heart_boss_bug_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_heart_boss_bug_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_heart_boss_bug_states:
	.addr	heart_boss_bug_state_00
	.addr	heart_boss_bug_state_01
	.addr	heart_boss_bug_state_02
	.addr	heart_boss_bug_state_03

heart_boss_bug_state_00:
	ldy	difficulty
	lda	a:heart_boss_bug_hp,y
	sta	OBJ_HP,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_FACING,x
	lda	#$001D
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	$34,x
	stz	$36,x
heart_boss_bug_start_wait:
	phx
	jsl	f:next_random
	plx
	lda	rng_lo
	and	#$0003
	sta	zp_FA
	lda	difficulty
	asl	a
	ora	zp_FA
	asl	a
	tay
	lda	a:heart_boss_bug_wait_times,y
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x

heart_boss_bug_state_01:
	dec	OBJ_TIMER,x
	bmi	@start_script
	rtl
@start_script:
	ldy	$30,x
	lda	a:ptrs_heart_boss_bug_tile_scripts,y
	sta	$34,x
	stz	$36,x
	lda	#$0030
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

heart_boss_bug_state_02:
	jsl	f:heart_boss_bug_run_tile_script
	dec	OBJ_TIMER,x
	bmi	heart_boss_bug_start_wait
	lda	OBJ_TIMER,x
	cmp	#$0020
	bne	@return
	jsr	a:heart_boss_bug_spawn_crawler
@return:
	rtl
heart_boss_bug_die:
	lda	#$003B
	jsl	f:queue_sound
	lda	#$0003
	sta	OBJ_STATE,x

heart_boss_bug_state_03:
	stz	OBJ_HP,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	ldy	$30,x
	lda	a:heart_boss_bug_dead_tiles,y
	jsl	f:heart_boss_bug_set_tile
	lda	OBJ_X,x
	clc
	adc	#$000A
	sta	OBJ_X,x
	lda	OBJ_Y,x
	sec
	sbc	#$0008
	sta	OBJ_Y,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	rtl

; Spawns a type $68 crawler at the pod (update_heart_boss_crawler), y offset by kind.
heart_boss_bug_spawn_crawler:
	ldy	#$03C0
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0068
	sta	a:$0010,y
	lda	OBJ_X,x
	clc
	adc	#$0008
	sta	a:$000A,y
	phy
	ldy	$30,x
	lda	OBJ_Y,x
	clc
	adc	a:heart_boss_bug_crawler_y_offsets,y
	ply
	sta	a:$000E,y
@return:
	rts

; Runs the BG tile script at field $34 ({frames, tile} words, 0 ends), one
; tile at VRAM field $32 (heart_boss_bug_set_tile).
heart_boss_bug_run_tile_script:
	ldy	$34,x
	beq	@return
	lda	$36,x
	bne	@count_down
	lda	vram_block_queue_end
	cmp	#$0040
	bcs	@return
	lda	a:$0000,y
	sta	$36,x
	lda	a:$0002,y
	bra	heart_boss_bug_set_tile
@count_down:
	dec	$36,x
	bne	@return
	lda	vram_block_queue_end
	cmp	#$0040
	bcc	@next_entry
	; (not executed in the CDL traces)
	inc	$36,x
	rtl
@next_entry:
	iny
	iny
	iny
	iny
	lda	a:$0000,y
	beq	@end_script
	bpl	@set_entry
	; (not executed in the CDL traces)
	tay
	lda	a:$0000,y
@set_entry:
	sty	$34,x
	sta	$36,x
	lda	a:$0002,y
	bra	heart_boss_bug_set_tile
@end_script:
	sta	$34,x
	sta	$36,x
@return:
	rtl

heart_boss_bug_set_tile:
	sta	zp_00
	lda	$32,x
	jml	f:queue_vram_block

; Object type $5B. Stage 6: the giant worm that bursts out of the wall at the
; start of the stage. HP by difficulty: 64/128/256 (wall_worm_hp).
update_wall_worm:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	wall_worm_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_wall_worm_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_wall_worm_states:
	.addr	wall_worm_state_00
	.addr	wall_worm_state_01
	.addr	wall_worm_state_02
	.addr	wall_worm_state_03
	.addr	wall_worm_state_04

wall_worm_state_00:
	ldy	difficulty
	lda	a:wall_worm_hp,y
	sta	OBJ_HP,x
	stz	$34,x
	stz	$36,x
	inc	OBJ_STATE,x

wall_worm_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	wall_worm_try_init_hitboxes
wall_worm_return:
	rtl
wall_worm_try_init_hitboxes:
	jsr	a:wall_worm_init_hitboxes
	bcs	wall_worm_return
	inc	OBJ_STATE,x

wall_worm_state_02:
	jsr	a:wall_worm_flash_palette
	jsr	a:wall_worm_toggle_mouth
	jsr	a:wall_worm_toggle_anim_frame
	jsr	a:spawn_wall_worm_larva
	jsr	a:wall_worm_draw_mouth
	jsr	a:wall_worm_draw_anim_frame
	rtl
wall_worm_die:
	lda	#$0051
	jsl	f:queue_sound
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#$8000	; [num]
	ldy	$30,x
	sta	a:$0016,y
	ldy	$32,x
	sta	a:$0016,y
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x

wall_worm_state_03:
	dec	OBJ_TIMER,x
	bmi	@explosions_done
	lda	#$0004
	sta	a:shake_timer
	lda	OBJ_X,x
	sta	zp_00
	lda	#$0080
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$007F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rtl
@explosions_done:
	lda	#$0004
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_STATE,x

wall_worm_state_04:
	jsr	a:wall_worm_queue_death_tiles
	dec	OBJ_TIMER,x
	bne	wall_worm_return
	stz	a:bg1_scroll_mode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Every 64 frames toggles the mouth (field $34: 0 closed, 2 open, bit 15 =
; redraw); larvae come only while it is open (spawn_wall_worm_larva).
; wall_worm_draw_mouth sets the worm's flags, hitbox and y and draws the
; frame.
wall_worm_toggle_mouth:
	lda	stage_frame_counter
	bit	#$003F
	bne	@return
	and	#$0040
	asl	a
	asl	a
	xba
	asl	a
	ora	#$8000
	sta	$34,x
@return:
	rts

wall_worm_draw_mouth:
	lda	$34,x
	bpl	@return
	and	#$0002
	sta	$34,x
	tay
	lda	a:wall_worm_mouth_flags,y
	sta	OBJ_FLAGS,x
	lda	a:wall_worm_mouth_hitbox_h,y
	sta	OBJ_HITBOX_H,x
	lda	a:wall_worm_mouth_y,y
	sta	OBJ_Y,x
	lda	a:ptrs_wall_worm_mouth_blocks,y
	tay
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	#$4590
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rts

; Every 8 frames toggles a small BG animation (field $36), drawn by
; wall_worm_draw_anim_frame (VRAM $4598).
wall_worm_toggle_anim_frame:
	lda	stage_frame_counter
	dec	a
	bit	#$0007
	bne	@return
	lsr	a
	lsr	a
	and	#$0002
	ora	#$8000
	sta	$36,x
@return:
	rts

wall_worm_draw_anim_frame:
	lda	$36,x
	bpl	@return
	and	#$0002
	sta	$36,x
	tay
	lda	a:ptrs_wall_worm_anim_blocks,y
	tay
	lda	#$0001
	sta	zp_02
	lda	#$0008
	sta	zp_08
	lda	#$4598
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rts

; wall_worm_state_04: BG blocks by OBJ_TIMER (4-1).
wall_worm_queue_death_tiles:
	lda	#$0003
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	OBJ_TIMER,x
	asl	a
	tay
	lda	a:ptrs_wall_worm_death_blocks,y
	pha
	lda	a:wall_worm_death_vram_addrs,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; The worm's hitbox and two type $53 ones (slots $03C0, $0400) kept in fields
; $30, $32.
wall_worm_init_hitboxes:
	lda	#$003F
	sta	OBJ_FLAGS,x
	lda	#$0090
	sta	OBJ_X,x
	lda	#$0080
	sta	OBJ_Y,x
	lda	#$0040
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	#$03C0
	sty	$30,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$003F
	sta	a:$0016,y
	lda	#$0088
	sta	a:$000A,y
	lda	#$0060
	sta	a:$000E,y
	lda	#$0050
	sta	a:$0028,y
	lda	#$FFD8	; [num]
	sta	a:$002A,y
	ldy	#$0400
	sty	$32,x
	lda	#$0053
	sta	a:$0010,y
	lda	#$003F
	sta	a:$0016,y
	lda	#$00A0
	sta	a:$000A,y
	lda	#$0038
	sta	a:$000E,y
	lda	#$0048
	sta	a:$0028,y
	lda	#$FFC8	; [num]
	sta	a:$002A,y
	clc
	rts

wall_worm_flash_palette:
	lda	OBJ_SAVED_ATTR,x
	beq	@return
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0020
	sta	cgram_upload_addr
@return:
	rts

spawn_wall_worm_larva:
	lda	$34,x
	beq	@return
	lda	stage_frame_counter
	bit	#$001F
	bne	@return
	ldy	#$03C0
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#OBJT_WALL_WORM_LARVA
	sta	a:$0010,y
	lda	#$0090
	sta	a:$000A,y
	lda	#$0080
	sta	a:$000E,y
@return:
	rts

; Object type $5D. Stage 6, dark cave: controller of the hunched beast section
; (4095 HP, i.e. not killed by shots; slot $0900); spawns cave_rock,
; cave_beast_target and its attacks.
update_cave_beast:
	jsr	a:cave_beast_clamp_players_y
	ldy	#$0840
	lda	a:$0006,y
	bpl	@check_flash
	lda	#$0026
	sta	OBJ_STATE,x
@check_flash:
	ldy	#$0840
	lda	a:$0026,y
	beq	@dispatch
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0020
	sta	cgram_upload_addr
	lda	#$000F
	jsl	f:queue_sound
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_cave_beast_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_cave_beast_states:
	.addr	cave_beast_state_00
	.addr	cave_beast_state_01
	.addr	cave_beast_state_02
	.addr	cave_beast_state_03
	.addr	cave_beast_state_04
	.addr	cave_beast_state_05
	.addr	cave_beast_state_06
	.addr	cave_beast_state_07
	.addr	cave_beast_state_08
	.addr	cave_beast_state_09
	.addr	cave_beast_state_0A
	.addr	cave_beast_state_07
	.addr	cave_beast_state_08
	.addr	cave_beast_state_0D
	.addr	cave_beast_state_0A
	.addr	cave_beast_state_07
	.addr	cave_beast_state_08
	.addr	cave_beast_state_11
	.addr	cave_beast_state_12
	.addr	cave_beast_state_13
	.addr	cave_beast_state_14
	.addr	cave_beast_state_15
	.addr	cave_beast_state_04
	.addr	cave_beast_state_17
	.addr	cave_beast_state_18
	.addr	cave_beast_state_19
	.addr	cave_beast_state_04
	.addr	cave_beast_state_1B
	.addr	cave_beast_state_1C
	.addr	cave_beast_state_1D
	.addr	cave_beast_state_1E
	.addr	cave_beast_state_03
	.addr	cave_beast_state_20
	.addr	cave_beast_state_06
	.addr	cave_beast_state_07
	.addr	cave_beast_state_08
	.addr	cave_beast_state_24
	.addr	update_cave_beast_target
	.addr	cave_beast_state_26
	.addr	cave_beast_state_27

; Object type $A0. Stage 6, dark cave: the part of the hunched beast that
; takes damage (320 HP, slot $0840). The handler is a bare rtl: cave_beast
; moves it and reads its HP; also cave_beast's state $25.
update_cave_beast_target:
	rtl

cave_beast_state_00:
	lda	#$0006
	jsl	f:start_palette_anim
	lda	#$0008
	sta	a:respawn_mode
	lda	#$004A
	sta	a:bg2sc_shadow
	stz	a:bg2_x
	stz	a:bg2_y
	inc	OBJ_STATE,x
	rtl

cave_beast_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@return
	inc	OBJ_STATE,x
@return:
	rtl

cave_beast_state_02:
	lda	#$0079
	sta	OBJ_FLAGS,x
	lda	#HP_UNKILLABLE
	sta	OBJ_HP,x
	lda	#$0034
	sta	OBJ_HITBOX_W,x
	lda	#$FFA8	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	#$0800
	lda	#$0053
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	#HP_UNKILLABLE
	sta	a:OBJ_HP,y
	lda	#$0030
	sta	a:$0028,y
	lda	#$FFE8	; [num]
	sta	a:$002A,y
	ldy	difficulty
	lda	a:cave_beast_target_hp,y
	sta	zp_00
	ldy	#$0840
	lda	#OBJT_CAVE_BEAST_TARGET
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	zp_00
	sta	a:$0006,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFE0	; [num]
	sta	a:$002A,y
	ldy	#$0880
	lda	#$0053
	sta	a:$0010,y
	lda	#$0078
	sta	a:$0016,y
	lda	#HP_UNKILLABLE
	sta	a:OBJ_HP,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFC0	; [num]
	sta	a:$002A,y
	lda	#$00AD
	sta	OBJ_X,x
	lda	#$01E0
	sta	OBJ_Y,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
cave_beast_update_body:
	jsr	a:cave_beast_place_parts
	stz	zp_0C
	jsl	f:object_solid_vs_players
	phx
	ldx	#$0840
	stz	zp_0C
	jsl	f:object_solid_vs_players
	ldx	#$0800
	stz	zp_0C
	jsl	f:object_solid_vs_players
	ldx	#$0880
	stz	zp_0C
	jsl	f:object_solid_vs_players
	plx
	jsr	a:cave_beast_set_bg2_scroll
	rtl

cave_beast_state_03:
	lda	OBJ_TIMER,x
	bit	#$003F
	bne	@rise
	lda	#$0053
	jsl	f:queue_sound
@rise:
	dec	OBJ_Y,x
	lda	OBJ_Y,x
	cmp	#$00B9
	bcs	cave_beast_drop_rock
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body
cave_beast_drop_rock:
	lda	#$0003
	sta	a:shake_timer
	jsl	f:find_free_slot_y
	bcs	@next
	lda	#OBJT_CAVE_ROCK
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	phy
	ldy	#$0800
	lda	a:$000A,y
	sta	zp_00
	ply
	lda	rng_lo
	and	#$003F
	adc	zp_00
	sta	a:$000A,y
	lda	#$00B8
	sta	a:$000E,y
@next:
	inc	OBJ_TIMER,x
	jmp	a:cave_beast_update_body
cave_beast_jump_left:
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
cave_beast_start_jump:
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$000A
	jsr	a:cave_beast_queue_frame
	inc	OBJ_STATE,x
	rtl
cave_beast_jump_right:
	stz	OBJ_X_VEL,x
	bra	cave_beast_start_jump

cave_beast_state_06:
	lda	OBJ_Y_VEL,x
	bmi	@clamp_x
	lda	stage_frame_counter
	bit	#$0003
	bne	@clamp_x
	bit	#$0004
	beq	@frame_0a
	lda	#$0009
	bra	@queue_frame
@frame_0a:
	lda	#$000A
@queue_frame:
	jsr	a:cave_beast_queue_frame
@clamp_x:
	lda	OBJ_X,x
	cmp	#$002D
	bmi	@left_wall
	cmp	#$00AD
	bcc	@check_players
	; (not executed in the CDL traces)
	lda	#$00AD
	bra	@store_x
@left_wall:
	lda	#$002D
@store_x:
	sta	OBJ_X,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
@check_players:
	stz	zp_00
@player_loop:
	lda	zp_00
	asl	a
	tay
	lda	a:cave_beast_player_slots,y
	sta	zp_02
	lda	OBJ_Y_VEL,x
	bmi	@next_player
	ldy	zp_02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	@check_landing
	ldy	zp_02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0010
	bcc	@crush
@check_landing:
	ldy	#$0800
	lda	a:$000E,y
	cmp	#$0098
	bcc	@next_player
	ldy	zp_02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0020
	bcs	@next_player
	ldy	zp_02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	@next_player
@crush:
	ldy	zp_02
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
@next_player:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@player_loop
	lda	OBJ_Y,x
	cmp	#$00B8
	bcc	@gravity
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$00B8
	sta	OBJ_Y,x
	sta	$32,x
	lda	a:bg1_y
	sta	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body_jmp
@gravity:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1400
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
cave_beast_update_body_jmp:
	jmp	a:cave_beast_update_body

cave_beast_state_07:
	lda	#$0009
	jsr	a:cave_beast_queue_frame
	lda	#$0003
	sta	a:shake_timer
	stz	$30,x
	stz	OBJ_TIMER,x
	lda	#$0056
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body_jmp

cave_beast_state_08:
	lda	a:shake_timer
	bne	@body
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body_jmp

cave_beast_state_09:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	OBJ_X,x
	bcc	cave_beast_set_left_speed

cave_beast_state_0D:
	stz	$3A,x
	lda	#$4000
cave_beast_set_speed:
	sta	$38,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	inc	OBJ_STATE,x
	lda	#$0054
	jsl	f:queue_sound
	rtl
cave_beast_set_left_speed:
	lda	#$FFFF	; [num]
	sta	$3A,x
	lda	#$C000	; [num]
	bra	cave_beast_set_speed

cave_beast_state_0A:
	lda	$3A,x
	bmi	@moving_left
	lda	OBJ_X,x
	cmp	#$00AD
	bcc	@accelerate
	lda	#$00AD
	sta	OBJ_X,x
	bra	@stop
@moving_left:
	lda	OBJ_X,x
	cmp	#$002D
	bpl	@accelerate
	lda	#$002D
	sta	OBJ_X,x
@stop:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$00B8
	sta	OBJ_Y,x
	lda	#$0000
	sta	a:shake_continuous
	lda	#$0007
	jsr	a:cave_beast_queue_frame
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body
@accelerate:
	lda	OBJ_X_VEL_SUB,x
	sta	zp_00
	lda	OBJ_X_VEL,x
	sta	zp_02
	lda	zp_00
	clc
	adc	$38,x
	sta	zp_00
	lda	zp_02
	adc	$3A,x
	sta	zp_02
	bpl	@check_max
	eor	#$FFFF
	inc	a
@check_max:
	cmp	#$0004
	bcs	@spawn_rock
	lda	zp_00
	sta	OBJ_X_VEL_SUB,x
	lda	zp_02
	sta	OBJ_X_VEL,x
@spawn_rock:
	jsl	f:find_free_slot_y
	bcs	@animate
	lda	#OBJT_CAVE_ROCK
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	phy
	ldy	#$0800
	lda	a:$000A,y
	sta	zp_00
	ply
	lda	rng_lo
	and	#$003F
	adc	zp_00
	sta	a:$000A,y
	lda	#$00B8
	sta	a:$000E,y
@animate:
	lda	stage_frame_counter
	bit	#$0003
	bne	@shake
	bit	#$0004
	beq	@frame_8
	lda	#$0007
	bra	@queue_frame
@frame_8:
	lda	#$0008
@queue_frame:
	jsr	a:cave_beast_queue_frame
@shake:
	lda	#$0001
	sta	a:shake_continuous
	jmp	a:cave_beast_update_body

cave_beast_state_11:
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_12:
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_13:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	cave_beast_update_body_jmp2
	lda	$30,x
	asl	a
	tay
	lda	a:cave_beast_state_13_frames,y
	jsr	a:cave_beast_queue_frame
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	cave_beast_update_body_jmp2
	ldy	#$0840
	lda	a:$0016,y
	and	#$FFDF
	sta	a:$0016,y
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
cave_beast_update_body_jmp2:
	jmp	a:cave_beast_update_body

cave_beast_state_14:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	cave_beast_update_body_jmp2
	jsl	f:find_free_slot_y
	bcs	@count
	lda	#OBJT_CAVE_BEAST_EMBER
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	OBJ_X,x
	adc	#$0014
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
@count:
	inc	$30,x
	ldy	difficulty
	lda	a:cave_beast_state_14_counts,y
	cmp	$30,x
	bcs	@body
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body

cave_beast_state_15:
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_17:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	@body
	lda	$30,x
	asl	a
	tay
	lda	a:cave_beast_state_17_frames,y
	jsr	a:cave_beast_queue_frame
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	cave_beast_update_body_jmp2
	lda	#$0014
	jsl	f:queue_sound
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body

cave_beast_state_18:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0001
	bne	@body
	lda	$30,x
	bne	@spawn_beam
	jsl	f:find_free_slot_y
	bcs	@done
	lda	#OBJT_CAVE_BEAST_FIREBALL
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	OBJ_X,x
	clc
	adc	#$0004
	sta	a:$000A,y
	lda	OBJ_Y,x
	sec
	sbc	#$0040
	sta	a:$000E,y
	tya
	sta	$32,x
	inc	$30,x
@body:
	jmp	a:cave_beast_update_body
@spawn_beam:
	jsl	f:find_free_slot_y
	bcs	@done
	lda	$32,x
	sta	a:$0030,y
	lda	#OBJT_CAVE_BEAST_BEAM
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	inc	$30,x
	lda	$30,x
	cmp	#$000A
	bcc	@body
@done:
	stz	OBJ_TIMER,x
	stz	$30,x
	stz	$32,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_19:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	@body
	lda	$30,x
	asl	a
	tay
	lda	a:cave_beast_state_19_frames,y
	jsr	a:cave_beast_queue_frame
	inc	$30,x
	lda	$30,x
	cmp	#$0004
	bcc	@body
	ldy	#$0840
	lda	a:$0016,y
	ora	#$0020
	sta	a:$0016,y
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body

cave_beast_state_1B:
	ldy	#$0840
	lda	a:$0006,y
	cmp	#$0080
	bcs	@repeat
	inc	OBJ_STATE,x
	bra	@reset
@repeat:
	lda	#$0005
	sta	OBJ_STATE,x
@reset:
	stz	OBJ_TIMER,x
	stz	$30,x
	jmp	a:cave_beast_update_body

cave_beast_state_1C:
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$0001
	sta	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_1D:
	lda	OBJ_TIMER,x
	bit	#$003F
	bne	@sink
	lda	#$0053
	jsl	f:queue_sound
@sink:
	lda	OBJ_Y,x
	cmp	#$0140
	bcc	@drop_rock
	stz	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body
@drop_rock:
	jmp	a:cave_beast_drop_rock

cave_beast_state_1E:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	#$0040
	bcc	@clamp_left
	cmp	#$00A0
	bcs	@clamp_right
	bcc	@store_x
@clamp_left:
	lda	#$0040
	bra	@store_x
@clamp_right:
	lda	#$00A0
	bra	@store_x
@store_x:
	sta	OBJ_X,x
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_05:
	jsl	f:pick_random_player
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcc	cave_beast_state_20
	stz	OBJ_TIMER,x
	lda	#$0009
	sta	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_20:
	lda	OBJ_X,x
	cmp	#$0080
	bcc	@jump_right
	jmp	a:cave_beast_jump_left
@jump_right:
	jmp	a:cave_beast_jump_right

cave_beast_state_24:
	lda	#$0005
	sta	OBJ_STATE,x
	stz	OBJ_TIMER,x
	stz	$30,x
	jmp	a:cave_beast_update_body

cave_beast_state_26:
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$0000
	ldy	#$0800
	sta	a:$0016,y
	ldy	#$0840
	sta	a:$0016,y
	sta	a:$0006,y
	stz	OBJ_HP,x
	stz	OBJ_TIMER,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_Y_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0006
	jsr	a:cave_beast_queue_frame
	inc	OBJ_STATE,x
	jmp	a:cave_beast_update_body

cave_beast_state_27:
	jsl	f:queue_sound_41_throttled
	lda	OBJ_X,x
	adc	#$FFE0
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$003F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@fall
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@fall:
	lda	OBJ_Y_VEL,x
	bmi	@accelerate
	cmp	#$0001
	bcs	@check_gone
@accelerate:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	bcc	@check_gone
	inc	OBJ_Y_VEL,x
@check_gone:
	lda	OBJ_Y,x
	cmp	#$0140
	bcs	@gone
	jmp	a:cave_beast_drop_rock
@gone:
	stz	a:bg1_scroll_mode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	ldy	#$0840
	sta	a:$0016,y
	ldy	#$0800
	sta	a:$0016,y
	ldy	#$0880
	sta	a:$0016,y
	stz	a:respawn_mode
	lda	#$0082
	jsl	f:queue_sound
	rtl

cave_beast_state_04:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$003C
	bcc	@body
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body

; (no caller found; decoded because it follows the end of a routine)
; Not called: like cave_beast_state_04 with 120 frames.
cave_beast_unused_wait_state:
	; (not executed in the CDL traces)
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0078
	bcc	@body
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@body:
	jmp	a:cave_beast_update_body

; Slots $0800 (type $53), $0840 (cave_beast_target) and $0880 (type $53)
; follow the beast.
cave_beast_place_parts:
	ldy	#$0800
	lda	OBJ_X,x
	sec
	sbc	#$0028
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	ldy	#$0840
	lda	OBJ_X,x
	sec
	sbc	#$000A
	sta	a:$000A,y
	lda	OBJ_Y,x
	sec
	sbc	#$0020
	sta	a:$000E,y
	ldy	#$0880
	lda	OBJ_X,x
	clc
	adc	#$0030
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	rts

cave_beast_set_bg2_scroll:
	lda	OBJ_X,x
	sec
	sbc	#$00AD
	eor	#$FFFF
	inc	a
	sta	a:bg2_x
	lda	OBJ_Y,x
	sec
	sbc	#$01C0
	eor	#$FFFF
	inc	a
	sta	a:bg2_y
	rts

; A = frame: queues the BG blocks of a frame of the beast
; (cave_beast_frame_block_counts, cave_beast_frame_block_sizes,
; cave_beast_frame_vram_addrs, ptrs_cave_beast_frame_blocks).
cave_beast_queue_frame:
	asl	a
	tay
	lda	a:cave_beast_frame_block_counts,y
	sta	zp_02
	lda	a:cave_beast_frame_block_sizes,y
	sta	zp_08
	lda	a:cave_beast_frame_vram_addrs,y
	pha
	lda	a:ptrs_cave_beast_frame_blocks,y
	tay
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; (no caller found; decoded because it follows the end of a routine)
; Not called.
cave_beast_unused_return_clc:
	; (not executed in the CDL traces)
	clc
	rts

; (no caller found; decoded because it follows the end of a routine)
cave_beast_unused_return_sec:
	; (not executed in the CDL traces)
	sec
	rts

; Object type $66. Stage 6, dark cave: the rocks that pile up on the floor (up
; to 18).
update_cave_rock:
	lda	OBJ_STATE,x
	bne	@fly
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	stz	OBJ_HP,x
	lda	rng_lo
	sta	OBJ_X_VEL_SUB,x
	lda	rng_lo
	and	#$0007
	sbc	#$0004
	sta	OBJ_X_VEL,x
	lda	rng_hi
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_TIMER,x
	lda	#.loword(metasprite_06AEB6)
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x
	rtl
@fly:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00F0
	bcc	@gravity
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@gravity:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $70. Stage 6, cave_beast: fiery embers it sprays (cave_beast_state_14;
; seen in the emulator): thrown up, fall under gravity, harmful, palette
; cycling.
update_cave_beast_ember:
	lda	OBJ_STATE,x
	bne	@fly
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	stz	OBJ_HP,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	rng_lo
	sta	OBJ_X_VEL_SUB,x
	lda	rng_lo
	and	#$0003
	sbc	#$0003
	sta	OBJ_X_VEL,x
	lda	rng_hi
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFF9	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$30,x
	stz	$32,x
	stz	OBJ_TIMER,x
	lda	#.loword(metasprite_06C376)
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x
	rtl
@fly:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$012C
	bcc	@cycle_palette
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@cycle_palette:
	lda	stage_frame_counter
	and	#$0007
	xba
	asl	a
	asl	a
	asl	a
	asl	a
	ora	#$3000
	sta	OBJ_ATTR,x
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0006
	bcs	@halve_x
@gravity:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@halve_x:
	lda	OBJ_Y_VEL,x
	bmi	@return
	sec
	ror	OBJ_X_VEL,x
	ror	OBJ_X_VEL_SUB,x
@return:
	rtl

; Object type $71. Stage 6, cave_beast: projectile aimed at a player
; (aim_velocity_at_player, double speed), removed after 300 frames.
update_cave_beast_fireball:
	lda	OBJ_STATE,x
	bne	cave_beast_fireball_fly
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	stz	OBJ_HP,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	stz	$36,x
	stz	OBJ_TIMER,x
	lda	#.loword(metasprite_06AF82)
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	lda	OBJ_X,x
	sta	$32,x
	lda	OBJ_Y,x
	sta	$34,x
	jsl	f:aim_velocity_at_player
	asl	OBJ_X_VEL_SUB,x
	rol	OBJ_X_VEL,x
	asl	OBJ_Y_VEL_SUB,x
	rol	OBJ_Y_VEL,x
	rtl
cave_beast_fireball_fly:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$012C
	bcc	@animate
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@animate:
	lda	stage_frame_counter
	and	#$0003
	asl	a
	tay
	lda	a:cave_beast_fireball_sprites,y
	sta	OBJ_SPRITE,x
	rtl

; Object type $72. Stage 6, cave_beast: segments of the beast's beam.
update_cave_beast_beam:
	lda	OBJ_STATE,x
	bne	cave_beast_fireball_fly
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	stz	OBJ_HP,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	$36,x
	stz	OBJ_TIMER,x
	lda	#.loword(metasprite_06AF82)
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	stz	OBJ_FACING,x
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	lda	$30,x
	tay
	lda	a:$0032,y
	sta	OBJ_X,x
	lda	a:$0034,y
	sta	OBJ_Y,x
	lda	a:$0018,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:$001A,y
	sta	OBJ_X_VEL,x
	lda	a:$001C,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:$001E,y
	sta	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	rtl

; Keeps the players (cave_beast_player_slots) between y $57 and $B8 in the
; dark cave.
cave_beast_clamp_players_y:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:cave_beast_player_slots,y
	tay
	lda	a:$0016,y
	beq	@next
	lda	a:$000E,y
	cmp	#$0056
	bcc	@clamp_top
	cmp	#$00B9
	bcc	@next
	; (not executed in the CDL traces)
	lda	#$00B8
	sta	a:$000E,y
	bra	@next
@clamp_top:
	lda	#$0057
	sta	a:$000E,y
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
@next:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@loop
	rts

; solid_object_vs_player for both players (when alive) against object X.
object_solid_vs_players:
	ldy	#$0200
	lda	a:$0016,y
	beq	@player2
	bmi	@player2
	stz	zp_0C
	jsl	f:solid_object_vs_player
@player2:
	ldy	#$0240
	lda	a:$0016,y
	beq	@return
	bmi	@return
	stz	zp_0C
	jsl	f:solid_object_vs_player
@return:
	rtl

; Object type $75. Stage 6, face_boss: the two side heads that reach out on
; necks. HP by difficulty: 128/192/256 (face_boss_side_head_hp).
update_face_boss_side_head:
	lda	OBJ_HP,x
	bpl	@check_boss
	brl	face_boss_side_head_die
@check_boss:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	@dispatch
	; (not executed in the CDL traces)
	brl	face_boss_side_head_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_face_boss_side_head_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_face_boss_side_head_states:
	.addr	face_boss_side_head_state_00
	.addr	face_boss_side_head_state_01
	.addr	face_boss_side_head_state_02
	.addr	face_boss_side_head_state_03
	.addr	face_boss_side_head_state_04
	.addr	face_boss_side_head_state_05

face_boss_side_head_state_00:
	ldy	difficulty
	lda	a:face_boss_side_head_hp,y
	sta	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C49F)
	sta	OBJ_SPRITE,x
	lda	#$2600
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_side_head_state_01:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0002
	bcs	face_boss_side_head_set_state_02
	rtl
face_boss_side_head_set_state_02:
	lda	#$4019
	sta	OBJ_FLAGS,x
	stz	$30,x
	lda	#.loword(metasprite_06C49F)
	sta	OBJ_SPRITE,x
	lda	#$2600
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	lda	#$0002
	sta	OBJ_STATE,x

face_boss_side_head_state_02:
	ldy	$32,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	clc
	adc	a:face_boss_side_head_x_offsets,y
	sta	OBJ_X,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0034
	sta	OBJ_Y,x
	lda	$30,x
	beq	@idle
	jsr	a:face_boss_side_head_has_neck
	bcc	@start_lunge
@idle:
	ldy	#.loword(metasprite_06C4BC)
	lda	$3A,x
	dec	a
	bpl	@set_sprite
	lda	#$0000
	ldy	#.loword(metasprite_06C49F)
@set_sprite:
	sty	OBJ_SPRITE,x
	sta	$3A,x
	cmp	#$0008
	bne	@return
	jsr	a:face_boss_side_head_fire
@return:
	rtl
@start_lunge:
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C4BC)
	sta	OBJ_SPRITE,x
	lda	#$3600
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	jsr	a:face_boss_side_head_pick_player
	bcs	face_boss_side_head_set_state_02
	sty	$38,x
	lda	#$0080
	sta	OBJ_FACING,x
	lda	$34,x
	asl	a
	ora	$32,x
	tay
	lda	a:face_boss_side_head_path_buffers,y
	sta	$36,x
	ldy	$34,x
	lda	a:face_boss_side_head_lunge_times,y
	sta	OBJ_TIMER,x
	jsr	a:face_boss_side_head_spawn_neck
	lda	#$0003
	sta	OBJ_STATE,x

face_boss_side_head_state_03:
	dec	OBJ_TIMER,x
	bmi	face_boss_side_head_set_state_04
	ldy	$36,x
	lda	OBJ_X,x
	sta	a:$0000,y
	iny
	iny
	lda	OBJ_Y,x
	sta	a:$0000,y
	iny
	iny
	sty	$36,x
	ldy	$38,x
	lda	a:$1312,y
	sec
	sbc	OBJ_X,x
	sta	zp_08
	lda	a:$1314,y
	sec
	sbc	OBJ_Y,x
	sta	zp_0A
	jsl	f:calc_angle
	rep	#$20
	sec
	sbc	OBJ_ANGLE,x
	beq	@move
	bit	#$0080
	beq	@inc_angle
	lda	OBJ_ANGLE,x
	dec	a
	dec	a
	bra	@store_angle
@inc_angle:
	lda	OBJ_ANGLE,x
	inc	a
	inc	a
@store_angle:
	and	#$00FF
	sta	OBJ_ANGLE,x
@move:
	lda	#$0020
	jsl	f:set_velocity_from_angle
	rtl

; Y = a random living player's slot (carry clear), carry set if none.
face_boss_side_head_pick_player:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	@coin_flip
	; (not executed in the CDL traces)
	sec
	rts
@coin_flip:
	lda	rng_lo
	lsr	a
	bcc	@try_p2
@try_p1:
	lda	a:p1_lives
	beq	@try_p2
	ldy	#$0200
	clc
	rts
@try_p2:
	lda	a:p2_lives
	beq	@try_p1
	; (not executed in the CDL traces)
	ldy	#$0240
	clc
	rts
face_boss_side_head_set_state_04:
	ldy	$34,x
	lda	a:face_boss_side_head_lunge_times,y
	sta	OBJ_TIMER,x
	jsr	a:face_boss_side_head_retract_neck
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_side_head_state_04:
	dec	OBJ_TIMER,x
	bpl	@retract
	brl	face_boss_side_head_set_state_02
@retract:
	ldy	$36,x
	dey
	dey
	lda	a:$0000,y
	sta	OBJ_Y,x
	dey
	dey
	lda	a:$0000,y
	sta	OBJ_X,x
	sty	$36,x
	rtl
face_boss_side_head_die:
	lda	OBJ_X,x
	clc
	adc	#$0010
	sta	OBJ_X,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	#$0005
	sta	OBJ_STATE,x

face_boss_side_head_state_05:
	rtl

; At the start of a lunge: makes slots 10-14 (left head), 15-19 (right head)
; or 10-19 (both) OBJT_FACE_BOSS_NECK segments; face_boss_side_head_has_neck
; (carry set while any is alive) and face_boss_side_head_retract_neck ($36 =
; 2) control them.
face_boss_side_head_spawn_neck:
	lda	$34,x
	beq	@one_head
	brl	@both_heads
@one_head:
	lda	$32,x
	bne	@right_head
	lda	#$0077
	sta	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+11*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+12*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+13*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+14*OBJ_SIZE+OBJ_TYPE
	stz	a:obj_slots+10*OBJ_SIZE+$30
	stz	a:obj_slots+11*OBJ_SIZE+$30
	stz	a:obj_slots+12*OBJ_SIZE+$30
	stz	a:obj_slots+13*OBJ_SIZE+$30
	stz	a:obj_slots+14*OBJ_SIZE+$30
	lda	#$1900
	sta	a:obj_slots+10*OBJ_SIZE+$32
	sta	a:obj_slots+11*OBJ_SIZE+$32
	sta	a:obj_slots+12*OBJ_SIZE+$32
	sta	a:obj_slots+13*OBJ_SIZE+$32
	sta	a:obj_slots+14*OBJ_SIZE+$32
	lda	#$0000
	sta	a:obj_slots+10*OBJ_SIZE+$34
	lda	#$000C
	sta	a:obj_slots+11*OBJ_SIZE+$34
	lda	#$0018
	sta	a:obj_slots+12*OBJ_SIZE+$34
	lda	#$0024
	sta	a:obj_slots+13*OBJ_SIZE+$34
	lda	#$0030
	sta	a:obj_slots+14*OBJ_SIZE+$34
	rts
@right_head:
	lda	#$0077
	sta	a:obj_slots+15*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+17*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+18*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+19*OBJ_SIZE+OBJ_TYPE
	lda	#$0002
	sta	a:obj_slots+15*OBJ_SIZE+$30
	sta	a:obj_slots+16*OBJ_SIZE+$30
	sta	a:obj_slots+17*OBJ_SIZE+$30
	sta	a:obj_slots+18*OBJ_SIZE+$30
	sta	a:obj_slots+19*OBJ_SIZE+$30
	lda	#$1A00
	sta	a:obj_slots+15*OBJ_SIZE+$32
	sta	a:obj_slots+16*OBJ_SIZE+$32
	sta	a:obj_slots+17*OBJ_SIZE+$32
	sta	a:obj_slots+18*OBJ_SIZE+$32
	sta	a:obj_slots+19*OBJ_SIZE+$32
	lda	#$0000
	sta	a:obj_slots+15*OBJ_SIZE+$34
	lda	#$000C
	sta	a:obj_slots+16*OBJ_SIZE+$34
	lda	#$0018
	sta	a:obj_slots+17*OBJ_SIZE+$34
	lda	#$0024
	sta	a:obj_slots+18*OBJ_SIZE+$34
	lda	#$0030
	sta	a:obj_slots+19*OBJ_SIZE+$34
	rts
@both_heads:
	lda	$32,x
	bne	@right_side
	stz	a:obj_slots+10*OBJ_SIZE+$30
	stz	a:obj_slots+11*OBJ_SIZE+$30
	stz	a:obj_slots+12*OBJ_SIZE+$30
	stz	a:obj_slots+13*OBJ_SIZE+$30
	stz	a:obj_slots+14*OBJ_SIZE+$30
	stz	a:obj_slots+15*OBJ_SIZE+$30
	stz	a:obj_slots+16*OBJ_SIZE+$30
	stz	a:obj_slots+17*OBJ_SIZE+$30
	stz	a:obj_slots+18*OBJ_SIZE+$30
	stz	a:obj_slots+19*OBJ_SIZE+$30
	bra	@set_types
@right_side:
	lda	#$0002
	sta	a:obj_slots+10*OBJ_SIZE+$30
	sta	a:obj_slots+11*OBJ_SIZE+$30
	sta	a:obj_slots+12*OBJ_SIZE+$30
	sta	a:obj_slots+13*OBJ_SIZE+$30
	sta	a:obj_slots+14*OBJ_SIZE+$30
	sta	a:obj_slots+15*OBJ_SIZE+$30
	sta	a:obj_slots+16*OBJ_SIZE+$30
	sta	a:obj_slots+17*OBJ_SIZE+$30
	sta	a:obj_slots+18*OBJ_SIZE+$30
	sta	a:obj_slots+19*OBJ_SIZE+$30
@set_types:
	lda	#$0077
	sta	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+11*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+12*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+13*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+14*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+15*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+16*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+17*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+18*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+19*OBJ_SIZE+OBJ_TYPE
	lda	#$1900
	sta	a:obj_slots+10*OBJ_SIZE+$32
	sta	a:obj_slots+11*OBJ_SIZE+$32
	sta	a:obj_slots+12*OBJ_SIZE+$32
	sta	a:obj_slots+13*OBJ_SIZE+$32
	sta	a:obj_slots+14*OBJ_SIZE+$32
	sta	a:obj_slots+15*OBJ_SIZE+$32
	sta	a:obj_slots+16*OBJ_SIZE+$32
	sta	a:obj_slots+17*OBJ_SIZE+$32
	sta	a:obj_slots+18*OBJ_SIZE+$32
	sta	a:obj_slots+19*OBJ_SIZE+$32
	lda	#$0000
	sta	a:obj_slots+10*OBJ_SIZE+$34
	lda	#$000C
	sta	a:obj_slots+11*OBJ_SIZE+$34
	lda	#$0018
	sta	a:obj_slots+12*OBJ_SIZE+$34
	lda	#$0024
	sta	a:obj_slots+13*OBJ_SIZE+$34
	lda	#$0030
	sta	a:obj_slots+14*OBJ_SIZE+$34
	lda	#$003C
	sta	a:obj_slots+15*OBJ_SIZE+$34
	lda	#$0048
	sta	a:obj_slots+16*OBJ_SIZE+$34
	lda	#$0054
	sta	a:obj_slots+17*OBJ_SIZE+$34
	lda	#$0060
	sta	a:obj_slots+18*OBJ_SIZE+$34
	lda	#$006C
	sta	a:obj_slots+19*OBJ_SIZE+$34
	rts

face_boss_side_head_has_neck:
	lda	$34,x
	bne	@both_heads
	lda	$32,x
	bne	@right_head
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+11*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+12*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+13*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+14*OBJ_SIZE+OBJ_TYPE
	clc
	beq	@return
	sec
	rts
@right_head:
	lda	a:obj_slots+15*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+16*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+17*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+18*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+19*OBJ_SIZE+OBJ_TYPE
	clc
	beq	@return
	sec
@return:
	rts
@both_heads:
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+11*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+12*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+13*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+14*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+15*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+16*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+17*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+18*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+19*OBJ_SIZE+OBJ_TYPE
	clc
	beq	@return
	sec
	rts

face_boss_side_head_retract_neck:
	lda	$34,x
	bne	@both_heads
	lda	$32,x
	bne	@right_head
	lda	#$0002
	sta	a:obj_slots+10*OBJ_SIZE+$36
	sta	a:obj_slots+11*OBJ_SIZE+$36
	sta	a:obj_slots+12*OBJ_SIZE+$36
	sta	a:obj_slots+13*OBJ_SIZE+$36
	sta	a:obj_slots+14*OBJ_SIZE+$36
	rts
@right_head:
	lda	#$0002
	sta	a:obj_slots+15*OBJ_SIZE+$36
	sta	a:obj_slots+16*OBJ_SIZE+$36
	sta	a:obj_slots+17*OBJ_SIZE+$36
	sta	a:obj_slots+18*OBJ_SIZE+$36
	sta	a:obj_slots+19*OBJ_SIZE+$36
	rts
@both_heads:
	lda	#$0002
	sta	a:obj_slots+10*OBJ_SIZE+$36
	sta	a:obj_slots+11*OBJ_SIZE+$36
	sta	a:obj_slots+12*OBJ_SIZE+$36
	sta	a:obj_slots+13*OBJ_SIZE+$36
	sta	a:obj_slots+14*OBJ_SIZE+$36
	sta	a:obj_slots+15*OBJ_SIZE+$36
	sta	a:obj_slots+16*OBJ_SIZE+$36
	sta	a:obj_slots+17*OBJ_SIZE+$36
	sta	a:obj_slots+18*OBJ_SIZE+$36
	sta	a:obj_slots+19*OBJ_SIZE+$36
	rts

; Three enemy bullets (type $18) from the head: down, down-right, down-left.
face_boss_side_head_fire:
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcc	@fire_down
	brl	@return
@fire_down:
	lda	#$0018
	sta	a:$0010,y
	lda	OBJ_X,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001C,y
	lda	#$0002
	sta	a:$001E,y
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0018
	sta	a:$0010,y
	lda	OBJ_X,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	#$0002
	sta	a:$001A,y
	sta	a:$001E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0018
	sta	a:$0010,y
	lda	OBJ_X,x
	clc
	adc	#$0010
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001C,y
	lda	#$FFFE	; [num]
	sta	a:$001A,y
	lda	#$0002
	sta	a:$001E,y
@return:
	rts

; Object type $77. Stage 6, face_boss: neck segments of the side heads.
update_face_boss_neck:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	@check_head
	; (not executed in the CDL traces)
	brl	face_boss_neck_die
@check_head:
	ldy	$30,x
	lda	a:face_boss_neck_head_slots,y
	tay
	lda	a:$0006,y
	bpl	@dispatch
	brl	face_boss_neck_die
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_face_boss_neck_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_face_boss_neck_states:
	.addr	face_boss_neck_state_00
	.addr	face_boss_neck_state_01
	.addr	face_boss_neck_state_02
	.addr	face_boss_neck_state_03
	.addr	face_boss_neck_state_04
	.addr	face_boss_neck_state_05
	.addr	face_boss_neck_state_06
	.addr	face_boss_neck_state_07

face_boss_neck_state_00:
	stz	OBJ_HP,x
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_neck_state_01:
	lda	$36,x
	beq	@wait
	; (not executed in the CDL traces)
	dec	a
	beq	@return
	brl	face_boss_neck_set_state_07
@return:
	rtl
@wait:
	dec	$34,x
	bmi	@appear
	rtl
@appear:
	lda	#$003D
	sta	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C4D9)
	sta	OBJ_SPRITE,x
	lda	#$2600
	sta	OBJ_ATTR,x
	ldy	$30,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	clc
	adc	a:face_boss_side_head_x_offsets,y
	sta	OBJ_X,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$001C
	sta	OBJ_Y,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0002
	sta	OBJ_STATE,x

face_boss_neck_state_02:
	lda	$36,x
	beq	@descend
	dec	a
	beq	@return
	brl	face_boss_neck_set_state_05
@return:
	; (not executed in the CDL traces)
	rtl
@descend:
	lda	OBJ_Y,x
	inc	a
	inc	a
	sta	OBJ_Y,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0034
	cmp	OBJ_Y,x
	bcc	@in_place
	rtl
@in_place:
	lda	#$0034
	sta	OBJ_Y,x
	lda	#$3600
	sta	OBJ_ATTR,x
	stz	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x

face_boss_neck_state_03:
	lda	$36,x
	beq	@follow_path
	dec	a
	beq	@return
	brl	@retract
@return:
	; (not executed in the CDL traces)
	rtl
@follow_path:
	inc	OBJ_TIMER,x
	ldy	$32,x
	lda	a:$0000,y
	sta	OBJ_X,x
	iny
	iny
	lda	a:$0000,y
	sta	OBJ_Y,x
	iny
	iny
	sty	$32,x
	rtl
@retract:
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_neck_state_04:
	dec	OBJ_TIMER,x
	bpl	@retract
	brl	face_boss_neck_set_state_05
@retract:
	ldy	$32,x
	dey
	dey
	lda	a:$0000,y
	sta	OBJ_Y,x
	dey
	dey
	lda	a:$0000,y
	sta	OBJ_X,x
	sty	$32,x
	rtl
face_boss_neck_set_state_05:
	lda	#$2600
	sta	OBJ_ATTR,x
	lda	#$0005
	sta	OBJ_STATE,x

face_boss_neck_state_05:
	lda	OBJ_Y,x
	dec	a
	dec	a
	sta	OBJ_Y,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$001C
	cmp	OBJ_Y,x
	bcc	@return
	brl	face_boss_neck_set_state_07
@return:
	rtl
face_boss_neck_set_state_07:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0007
	sta	OBJ_STATE,x

face_boss_neck_state_07:
	rtl
face_boss_neck_die:
	lda	OBJ_X,x
	clc
	adc	#$0010
	sta	OBJ_X,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	#$0006
	sta	OBJ_STATE,x

face_boss_neck_state_06:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; Not called and not executed: stores 0 into OBJ_HP of slot $0500 (the slot of
; snake_robot_head, which follows); probably a leftover, kept unnamed.
sub_04C3A2:
	; (not executed in the CDL traces)
	ldy	#$0500
	lda	#$0000
	sta	a:$0006,y
	rtl

; Object type $79. Stage 4, hover-bike section: body of the segmented snake-
; like robot that rises from the road (4095 HP: not killed by shots; slot
; $0900); snake_robot_head is the target.
update_snake_robot:
	ldy	#$0500
	lda	a:$0006,y
	bpl	@dispatch
	lda	#$0010
	sta	OBJ_STATE,x
	lda	#$0000
	sta	a:$0006,y
	sta	a:$0016,y
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_snake_robot_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_snake_robot_states:
	.addr	snake_robot_state_00
	.addr	snake_robot_state_01
	.addr	snake_robot_state_02
	.addr	snake_robot_state_03
	.addr	snake_robot_state_04
	.addr	snake_robot_state_05
	.addr	snake_robot_state_06
	.addr	snake_robot_state_07
	.addr	snake_robot_state_08
	.addr	snake_robot_state_09
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_0A
	.addr	snake_robot_state_10
	.addr	snake_robot_state_11

snake_robot_state_0A:
	; (not executed in the CDL traces)
	rtl

snake_robot_state_00:
	lda	#$0080
	sta	OBJ_X,x
	lda	#$0010
	sta	OBJ_Y,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#HP_UNKILLABLE
	sta	OBJ_HP,x
	lda	#$0001
	sta	OBJ_HITBOX_W,x
	lda	#$FFFF	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	#$0500
	lda	#OBJT_SNAKE_ROBOT_HEAD
	sta	a:$0010,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#.loword(metasprite_06C65B)
	sta	a:$0000,y
	lda	#$401C
	sta	a:$0016,y
	phy
	ldy	difficulty
	lda	a:snake_robot_head_hp,y
	ply
	sta	a:$0006,y
	sta	a:$003A,y
	lda	#$0020
	sta	a:$0028,y
	lda	#$FFE0	; [num]
	sta	a:$002A,y
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_leg_slots,y
	tay
	lda	#$0053
	sta	a:$0010,y
	lda	#.loword(metasprite_06C670)
	sta	a:$0000,y
	lda	#$3E00
	sta	a:$0002,y
	inc	zp_00
	lda	zp_00
	cmp	#$0010
	bcc	@loop
	stz	zp_00
@loop2:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_foot_slots,y
	tay
	lda	#$0053
	sta	a:$0010,y
	lda	#$000D
	sta	a:$0016,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#ENEMY_HP($0100)
	sta	a:$0006,y
	lda	#$0010
	sta	a:$0028,y
	lda	#$FFF0	; [num]
	sta	a:$002A,y
	lda	#.loword(metasprite_06C7E5)
	sta	a:$0000,y
	lda	#$0080
	sta	a:$000A,y
	lda	#$0010
	sta	a:$000E,y
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	sta	a:$001E,y
	sta	a:$001C,y
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@loop2
	stz	$30,x
	stz	$32,x
	stz	$34,x
	stz	$3E,x
	lda	#$00C0
	sta	$36,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_01:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_leg_start_angles,y
	pha
	lda	a:snake_robot_leg_slots,y
	tay
	pla
	sta	a:$0036,y
	inc	zp_00
	lda	zp_00
	cmp	#$0010
	bcc	@loop
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_place_legs_by_angle
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_02:
	ldy	#$0300
	lda	a:$000E,y
	bmi	@bend_legs
	cmp	#$00B0
	bcc	@bend_legs
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_place_legs_by_angle
	jmp	a:snake_robot_sync_slot_0500
@bend_legs:
	stz	zp_02
@leg_loop:
	lda	zp_02
	asl	a
	tay
	lda	a:ptrs_snake_robot_leg_segments,y
	sta	zp_04
	stz	zp_00
@segment_loop:
	lda	zp_00
	asl	a
	tay
	lda	(zp_04),y
	tay
	lda	a:$0036,y
	dec	a
	dec	a
	bmi	@next_segment
	sta	a:$0036,y
@next_segment:
	inc	zp_00
	lda	zp_00
	cmp	#$0007
	bcc	@segment_loop
	inc	zp_02
	lda	zp_02
	cmp	#$0002
	bcc	@leg_loop
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	bcc	@place
	inc	OBJ_Y_VEL,x
@place:
	jsr	a:snake_robot_place_legs_by_angle
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_03:
	ldy	#$0700
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF	; [num]
	sta	a:$001A,y
	ldy	#$0300
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$0018,y
	lda	#$FFFF	; [num]
	sta	a:$001A,y
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	cmp	#$0002
	bcc	@soft_landing
	lda	#$0038
	bra	@play_sound
@soft_landing:
	lda	#$0039
@play_sound:
	jsl	f:queue_sound
	stz	$30,x
	stz	$38,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_04:
	lda	$30,x
	bne	@decelerate
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcc	@accel_up
	inc	$30,x
	jmp	a:snake_robot_sync_slot_0500
@accel_up:
	lda	OBJ_Y_VEL_SUB,x
	sec
	sbc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	bcs	@place
	dec	OBJ_Y_VEL,x
@place:
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500
@decelerate:
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcs	@brake
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	$30,x
	stz	OBJ_TIMER,x
	ldy	#$0700
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	sta	a:$001A,y
	sta	a:$0018,y
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500
@brake:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$8000
	sta	OBJ_Y_VEL_SUB,x
	bcc	@place2
	inc	OBJ_Y_VEL,x
@place2:
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_05:
	ldy	#$0300
	lda	a:$000E,y
	sta	$34,x
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_leg_slots,y
	tay
	lda	OBJ_X,x
	sta	a:$0032,y
	lda	OBJ_Y,x
	sta	a:$0034,y
	inc	zp_00
	lda	zp_00
	cmp	#$0008
	bcc	@loop
	stz	$30,x
	stz	$36,x
	stz	$38,x
	stz	OBJ_TIMER,x
	lda	OBJ_X,x
	bmi	@pick_dir
	cmp	#$0080
	bcc	@pick_dir
	inc	$38,x
@pick_dir:
	lda	$38,x
	asl	a
	tay
	lda	a:snake_robot_step_foot_a_x_vel_subs,y
	sta	zp_00
	lda	a:snake_robot_step_foot_a_x_vels,y
	sta	zp_02
	lda	a:snake_robot_step_foot_b_x_vel_subs,y
	sta	zp_04
	lda	a:snake_robot_step_foot_b_x_vels,y
	sta	zp_06
	ldy	#$0300
	lda	#$0001
	sta	a:$0030,y
	lda	#$0000
	sta	a:$001C,y
	sta	a:$001E,y
	lda	zp_00
	sta	a:$0018,y
	lda	zp_02
	sta	a:$001A,y
	ldy	#$0700
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001C,y
	lda	#$FFFE	; [num]
	sta	a:$001E,y
	lda	zp_04
	sta	a:$0018,y
	lda	zp_06
	sta	a:$001A,y
	inc	OBJ_STATE,x
	jsr	a:snake_robot_walk_body
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_06:
	ldy	#$0500
	lda	a:$003A,y
	sec
	sbc	a:$0006,y
	cmp	#$0020
	bcs	@hit
	lda	OBJ_X,x
	bmi	@out_of_range
	cmp	#$0028
	bcc	@out_of_range
	cmp	#$00B0
	bcs	@out_of_range
	bra	@step_feet
@out_of_range:
	jmp	a:@end_walk
@hit:
	ldy	#$0500
	lda	a:$0006,y
	sta	a:$003A,y
	jmp	a:@hit_effect
@step_feet:
	stz	zp_00
@foot_loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_hip_x_offsets,y
	sta	zp_02
	lda	a:snake_robot_foot_slots,y
	tay
	lda	a:$0030,y
	beq	@check_falling
	jmp	a:@next_foot
@check_falling:
	lda	a:$001E,y
	bpl	@check_ground
	jmp	a:@foot_gravity
@check_ground:
	lda	a:$000E,y
	cmp	#$00B0
	bcc	@foot_gravity
	lda	#$00B0
	sta	a:$000E,y
	lda	$32,x
	clc
	adc	#$0020
	clc
	adc	zp_02
	sta	a:$000A,y
	phy
	lda	$38,x
	asl	a
	tay
	lda	a:snake_robot_step_foot_a_x_vel_subs,y
	sta	zp_04
	lda	a:snake_robot_step_foot_a_x_vels,y
	sta	zp_06
	lda	a:snake_robot_step_foot_b_x_vel_subs,y
	sta	zp_08
	lda	a:snake_robot_step_foot_b_x_vels,y
	sta	zp_0A
	ply
	lda	#$0001
	sta	a:$0030,y
	lda	#$0000
	sta	a:$000C,y
	sta	a:$001C,y
	sta	a:$001E,y
	lda	zp_04
	sta	a:$0018,y
	lda	zp_06
	sta	a:$001A,y
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_other_foot_slots,y
	tay
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001C,y
	lda	#$FFFC	; [num]
	sta	a:$001E,y
	lda	zp_08
	sta	a:$0018,y
	lda	zp_0A
	sta	a:$001A,y
	lda	#$0037
	jsl	f:queue_sound
	bra	@next_foot
@foot_gravity:
	lda	a:$001C,y
	clc
	adc	#$8000
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	bra	@next_foot
@next_foot:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcs	@attack
	jmp	a:@foot_loop
@attack:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	OBJ_X,x
	bmi	@fire_missile
	lda	a:$000E,y
	sbc	#$0018
	cmp	OBJ_Y,x
	bpl	@walk
	lda	OBJ_X,x
	sta	zp_00
	clc
	adc	#$0010
	lda	OBJ_Y,x
	sec
	sbc	#$0008
	sta	zp_02
	lda	#$0010
	jsl	f:spawn_enemy_bullet
	bra	@walk
@fire_missile:
	lda	#$0000
	jsl	f:spawn_homing_missile
	bcc	@walk
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0018,x
	lda	#$FFFF	; [num]
	sta	a:$001A,x
	phy
	lda	stage_frame_counter
	and	#$0001
	asl	a
	tay
	lda	a:snake_robot_missile_y_vel_subs,y
	sta	zp_00
	lda	a:snake_robot_missile_y_vels,y
	sta	zp_02
	ply
	lda	zp_00
	sta	a:$001C,y
	lda	zp_02
	sta	a:$001E,y
@walk:
	jsr	a:snake_robot_walk_body
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500
@hit_effect:
	lda	OBJ_X,x
	adc	#$FFF0
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$001F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@end_walk
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$FFFA	; [num]
	sta	a:$001A,y
@end_walk:
	ldy	#$0700
	lda	#$00B0
	sta	a:$000E,y
	ldy	#$0300
	lda	#$00B0
	sta	a:$000E,y
	ldy	#$0700
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	lda	#$0000
	sta	a:$0030,y
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_walk_body
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_07:
	stz	$38,x
	lda	OBJ_X,x
	bmi	@left_half
	cmp	#$0080
	bcs	@set_jump
@left_half:
	inc	$38,x
@set_jump:
	lda	$38,x
	asl	a
	tay
	lda	a:snake_robot_jump_x_vel_subs,y
	sta	zp_00
	lda	a:snake_robot_jump_x_vels,y
	sta	zp_02
	ldy	#$0700
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	lda	#$8000	; [num]
	sta	a:$001C,y
	lda	zp_02
	sta	a:$001A,y
	lda	zp_00
	sta	a:$0018,y
	ldy	#$0300
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	lda	#$8000	; [num]
	sta	a:$001C,y
	lda	zp_02
	sta	a:$001A,y
	lda	zp_00
	sta	a:$0018,y
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$8000	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	zp_02
	sta	OBJ_X_VEL,x
	lda	zp_00
	sta	OBJ_X_VEL_SUB,x
	stz	$30,x
	stz	$38,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:snake_robot_walk_body
	jsr	a:snake_robot_place_legs_between
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	jsl	f:fire_bullet_at_player
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_08:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$0400
	sta	OBJ_Y_VEL_SUB,x
	bcc	@feet_gravity
	inc	OBJ_Y_VEL,x
@feet_gravity:
	ldy	#$0300
	lda	a:$001C,y
	clc
	adc	#$0400
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	ldy	#$0700
	lda	a:$001C,y
	clc
	adc	#$0400
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	lda	$30,x
	bne	@fold_legs
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcc	@align_foot_a
	inc	$30,x
@align_foot_a:
	lda	OBJ_X,x
	clc
	adc	a:snake_robot_hip_x_offsets
	sta	zp_00
	ldy	#$0300
	lda	a:$000A,y
	cmp	zp_00
	bpl	@foot_a_left
	lda	a:$000A,y
	inc	a
	cmp	zp_00
	bpl	@align_foot_b
	sta	a:$000A,y
	bra	@align_foot_b
@foot_a_left:
	lda	a:$000A,y
	dec	a
	cmp	zp_00
	bmi	@align_foot_b
	sta	a:$000A,y
@align_foot_b:
	lda	OBJ_X,x
	clc
	adc	a:snake_robot_hip_x_offset_b
	sta	zp_00
	ldy	#$0700
	lda	a:$000A,y
	cmp	zp_00
	bpl	@foot_b_left
	lda	a:$000A,y
	inc	a
	cmp	zp_00
	bpl	@place
	sta	a:$000A,y
	bra	@place
@foot_b_left:
	lda	a:$000A,y
	dec	a
	cmp	zp_00
	bmi	@place
	sta	a:$000A,y
@place:
	jsr	a:snake_robot_place_legs_between
	jmp	a:snake_robot_sync_slot_0500
@fold_legs:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_leg_fold_angles,y
	pha
	lda	a:snake_robot_leg_slots,y
	tay
	pla
	sta	a:$0036,y
	inc	zp_00
	lda	zp_00
	cmp	#$0010
	bcc	@loop
	ldy	#$0700
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	ldy	#$0300
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	sta	a:$001A,y
	sta	a:$0018,y
	inc	OBJ_STATE,x
	stz	$30,x
	stz	$38,x
	stz	OBJ_TIMER,x
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_09:
	lda	OBJ_Y_VEL,x
	bmi	@bend_legs
	ldy	#$0300
	lda	a:$000E,y
	bmi	@bend_legs
	cmp	#$00B0
	bcc	@bend_legs
	stz	$30,x
	stz	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x
	jsr	a:snake_robot_place_legs_by_angle
	jmp	a:snake_robot_sync_slot_0500
@bend_legs:
	stz	zp_02
@leg_loop:
	lda	zp_02
	asl	a
	tay
	lda	a:ptrs_snake_robot_leg_segments,y
	sta	zp_04
	stz	zp_00
@segment_loop:
	lda	zp_00
	asl	a
	tay
	lda	(zp_04),y
	tay
	lda	a:$0036,y
	sec
	sbc	#$0004
	bmi	@next_segment
	sta	a:$0036,y
@next_segment:
	inc	zp_00
	lda	zp_00
	cmp	#$0007
	bcc	@segment_loop
	inc	zp_02
	lda	zp_02
	cmp	#$0002
	bcc	@leg_loop
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$0400
	sta	OBJ_Y_VEL_SUB,x
	bcc	@place
	inc	OBJ_Y_VEL,x
@place:
	jsr	a:snake_robot_place_legs_by_angle
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_10:
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_HP,x
	lda	#$0005
	sta	OBJ_X_VEL,x
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_leg_slots,y
	tay
	lda	#OBJT_SNAKE_ROBOT_DEBRIS
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	rng_lo
	adc	stage_frame_counter
	sta	rng_lo
	and	#$0003
	sta	a:$001A,y
	lda	#$8000	; [num]
	sta	a:$0018,y
	lda	zp_E9
	adc	stage_frame_counter
	sta	zp_E9
	ora	#$FFF8
	sta	a:$001E,y
	lda	#$8000	; [num]
	sta	a:$001C,y
	lda	#$0000
	sta	a:$0024,y
	inc	zp_00
	lda	zp_00
	cmp	#$0010
	bcc	@loop
	lda	#$0041
	jsl	f:queue_sound
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:snake_robot_sync_slot_0500

snake_robot_state_11:
	lda	OBJ_X,x
	adc	#$FFE0
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$0010
	sta	zp_02
	lda	#$001F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@debris
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$FFFA	; [num]
	sta	a:$001A,y
@debris:
	jsl	f:update_snake_robot_debris
	jmp	a:snake_robot_sync_slot_0500

; Object type $88. Stage 4: the 16 pieces of snake_robot when it is destroyed.
update_snake_robot_debris:
	lda	a:$0024,x
	inc	a
	sta	a:$0024,x
	cmp	#$0168
	bcs	@remove
	lda	a:$000A,x
	bit	#$FE00
	bne	@remove
	lda	a:$000E,x
	clc
	adc	#$0100
	bit	#$FE00
	beq	@move
@remove:
	lda	#$8000	; [num]
	sta	a:$0016,x
	bra	@return
@move:
	lda	a:$001E,x
	bmi	@gravity
	lda	a:$000E,x
	bmi	@gravity
	cmp	#$00B8
	bcc	@gravity
	lda	a:$001E,x
	eor	#$FFFF
	inc	a
	sta	a:$001E,x
@gravity:
	lda	a:$001C,x
	clc
	adc	#$4000
	sta	a:$001C,x
	lda	a:$001E,x
	adc	#$0000
	sta	a:$001E,x
	lda	a:$0018,x
	sec
	sbc	#$2000
	sta	a:$0018,x
	lda	a:$001A,x
	sbc	#$0000
	sta	a:$001A,x
@return:
	rtl
	; CDL: not accessed
	.byte	$6B

; Places the segments of both legs (ptrs_snake_robot_leg_segments) one after
; the other on a circle around the previous one
; (ptrs_snake_robot_leg_parents), adding each segment's angle (field $36); the
; legs hang from the hips (snake_robot_hip_slots, offsets
; snake_robot_hip_x_offsets). Seen in the emulator: the robot walks on two
; segmented legs with feet in slots $0300 and $0700.
snake_robot_place_legs_by_angle:
	phx
	stx	zp_10
	stz	zp_0A
@loop:
	lda	zp_0A
	asl	a
	tay
	lda	a:snake_robot_hip_x_offsets,y
	pha
	lda	a:snake_robot_hip_slots,y
	tay
	pla
	ldx	zp_10
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	a:$0036,y
	sta	zp_08
	lda	zp_0A
	asl	a
	tay
	lda	a:ptrs_snake_robot_leg_segments,y
	sta	zp_0C
	lda	a:ptrs_snake_robot_leg_parents,y
	sta	zp_0E
	stz	zp_00
@loop2:
	lda	zp_00
	asl	a
	tay
	lda	(zp_0C),y
	tax
	lda	(zp_0E),y
	sta	zp_02
	lda	zp_08
	clc
	adc	$36,x
	sta	zp_08
	and	#$00FF
	asl	a
	phx
	tax
	lda	f:circle15_y,x
	sta	zp_04
	lda	f:circle15_x,x
	sta	zp_06
	plx
	ldy	zp_02
	lda	a:$000A,y
	clc
	adc	zp_04
	sta	$0A,x
	lda	a:$000E,y
	clc
	adc	zp_06
	sta	$0E,x
	inc	zp_00
	lda	zp_00
	cmp	#$0007
	bcc	@loop2
	inc	zp_0A
	lda	zp_0A
	cmp	#$0002
	bcc	@loop
	plx
	rts

; Hips at the body; each leg segment at the midpoint of two others
; (snake_robot_midpoint_from_a, snake_robot_midpoint_from_b into
; snake_robot_midpoint_slots), bent by the distance between foot and body; the
; ankles (snake_robot_ankle_slots) at the feet.
snake_robot_place_legs_between:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_hip_x_offsets,y
	pha
	lda	a:snake_robot_hip_slots,y
	tay
	pla
	clc
	adc	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@loop
	phx
	stx	zp_06
	stz	zp_00
@midpoint_loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_midpoint_from_a,y
	tax
	lda	$0E,x
	pha
	lda	a:snake_robot_midpoint_from_b,y
	tax
	pla
	clc
	adc	$0E,x
	lsr	a
	pha
	lda	a:snake_robot_midpoint_slots,y
	tax
	pla
	sta	$0E,x
	sta	zp_08
	lda	a:snake_robot_midpoint_from_a,y
	tax
	lda	$0A,x
	pha
	lda	a:snake_robot_midpoint_from_b,y
	tax
	pla
	clc
	adc	$0A,x
	lsr	a
	cpy	#$0000
	beq	@bend
	cpy	#$0012
	bne	@store_x
@bend:
	pha
	lda	zp_08
	ldx	zp_06
	sec
	sbc	$0E,x
	bpl	@clamp_dist
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
@clamp_dist:
	cmp	#$0030
	bcc	@store_dist
	lda	#$0030
@store_dist:
	sta	zp_0A
	lda	#$0030
	sec
	sbc	zp_0A
	sta	zp_04
	pla
	sec
	sbc	zp_04
@store_x:
	pha
	lda	a:snake_robot_midpoint_slots,y
	tax
	pla
	sta	$0A,x
	inc	zp_00
	lda	zp_00
	cmp	#$0012
	bcc	@midpoint_loop
	stz	zp_00
@ankle_loop:
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_foot_slots,y
	tay
	lda	a:$000A,y
	clc
	adc	#$0008
	pha
	lda	a:$000E,y
	clc
	adc	#$0008
	pha
	lda	zp_00
	asl	a
	tay
	lda	a:snake_robot_ankle_slots,y
	tay
	pla
	sta	a:$000E,y
	pla
	sta	a:$000A,y
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@ankle_loop
	plx
	rts

; Body between the two feet, higher when they are close, through a delay ring
; of 8 positions kept in fields $32/$34 of the leg slots.
snake_robot_walk_body:
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:snake_robot_hip_x_offsets
	ldy	#$0700
	adc	a:$000A,y
	sec
	sbc	a:snake_robot_hip_x_offset_b
	clc
	lsr	a
	sta	zp_02
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:snake_robot_hip_x_offsets
	ldy	#$0700
	clc
	adc	a:snake_robot_hip_x_offset_b
	sec
	sbc	a:$000A,y
	bpl	@clamp_spread
	eor	#$FFFF
	inc	a
@clamp_spread:
	cmp	#$0060
	bcc	@height
	; (not executed in the CDL traces)
	lda	#$0060
@height:
	lsr	a
	sta	zp_00
	lda	#$0060
	sec
	sbc	zp_00
	sta	zp_04
	lda	$34,x
	sec
	sbc	zp_04
	sta	zp_04
	lda	$36,x
	asl	a
	tay
	lda	a:snake_robot_leg_slots,y
	tay
	lda	zp_02
	sta	a:$0032,y
	sta	$32,x
	lda	zp_04
	sta	a:$0034,y
	lda	$36,x
	inc	a
	cmp	#$0008
	bcc	@store_ring_index
	lda	#$0000
@store_ring_index:
	sta	$36,x
	asl	a
	tay
	lda	a:snake_robot_leg_slots,y
	tay
	lda	a:$0032,y
	sta	OBJ_X,x
	lda	a:$0034,y
	sta	OBJ_Y,x
	rts
snake_robot_sync_slot_0500:
	ldy	#$0500
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	rtl

; Object type $81. Stage 4: head of snake_robot (320 HP).
update_snake_robot_head:
	lda	a:snake_robot_body_slot
	tay
	lda	a:$0010,y
	bne	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@return:
	rtl

; Object type $7C. Stage 4, airship: dome gun turrets under the hull (20 HP;
; seen in the emulator), drawn on BG, aiming at a player.
update_airship_turret:
	jsr	a:scroll_with_airship
	lda	OBJ_HP,x
	bpl	@dispatch
	lda	#$001C
	sta	$30,x
	jsr	a:airship_turret_draw_frame
	lda	#$0010
	sta	OBJ_TIMER,x
	stz	OBJ_FLAGS,x
	stz	OBJ_HP,x
	lda	#$0004
	sta	OBJ_STATE,x
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_airship_turret_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_airship_turret_states:
	.addr	airship_turret_state_00
	.addr	airship_turret_state_01
	.addr	airship_turret_state_02
	.addr	airship_turret_state_03
	.addr	airship_part_explode

airship_turret_state_00:
	inc	OBJ_STATE,x
	stz	OBJ_FLAGS,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	$3A,x
	lda	a:airship_turret_delays,y
	sta	OBJ_TIMER,x
	lda	difficulty
	asl	a
	clc
	adc	#$0010
	sta	OBJ_HP,x
	rtl

airship_turret_state_01:
	cmp	#$0002
	beq	airship_turret_state_03
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
	stz	$30,x
@return:
	rtl

airship_turret_state_02:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	bit	#$0007
	bne	@return
	jsr	a:airship_turret_draw_frame
	clc
	lda	$30,x
	adc	#$0004
	sta	$30,x
	cmp	#$0010
	bne	@return
	inc	OBJ_STATE,x
	lda	#$4010
	sta	OBJ_FLAGS,x
@return:
	rtl

airship_turret_state_03:
	lda	#$0400
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	and	#$003E
	cmp	#$0018
	bcs	@check_max
	lda	#$0018
	bra	@aim
@check_max:
	cmp	#$0028
	bcc	@aim
	lda	#$0028
@aim:
	pha
	sec
	sbc	#$0018
	ldy	#$FFFE	; [num]
@loop:
	iny
	iny
	sec
	sbc	#$0006
	bpl	@loop
	lda	a:airship_turret_aim_frames,y
	sta	$30,x
	phy
	jsr	a:airship_turret_draw_frame
	ply
	clc
	lda	a:airship_turret_gun_y_offsets,y
	adc	OBJ_Y,x
	sta	zp_02
	clc
	lda	a:airship_turret_gun_x_offsets,y
	adc	OBJ_X,x
	sta	zp_00
	dec	OBJ_TIMER,x
	bpl	@wait
	lda	#$0100
	sta	OBJ_TIMER,x
	pla
	jml	f:spawn_enemy_bullet
@wait:
	pla
	rtl

; Draws frame field $30 (tile pair airship_turret_frame_tiles) at VRAM
; airship_turret_vram_addrs[field $3A].
airship_turret_draw_frame:
	ldy	$30,x
	lda	a:airship_turret_frame_tiles,y
	sta	zp_00
	lda	a:airship_turret_frame_tiles_b,y
	pha
	ldy	$3A,x
	lda	a:airship_turret_vram_addrs,y
	sta	zp_FC
	jsl	f:queue_vram_block
	pla
	sta	zp_00
	clc
	lda	zp_FC
	adc	#$0080
	jsl	f:queue_vram_block
	rts

; Object type $7A. Stage 4, under the alien airship: hanging emitters that
; drop lightning_bolt. HP by difficulty: 64/96/$7FFF (lightning_pylon_hp).
update_lightning_pylon:
	jsr	a:scroll_with_airship
	lda	OBJ_HP,x
	bpl	@alive
	; (not executed in the CDL traces)
	lda	#$0002
	sta	OBJ_STATE,x
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	ldy	$3A,x
	lda	#$0010
	sta	OBJ_TIMER,x
	lda	#$59C0
	sta	zp_00
	lda	a:lightning_pylon_vram_addrs,y
	sta	zp_FC
	jsl	f:queue_vram_block
	lda	#$5000
	sta	zp_00
	clc
	lda	zp_FC
	adc	#$0080
	jml	f:queue_vram_block
@alive:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#$4010
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFC0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_TIMER,x
	ldy	difficulty
	lda	a:lightning_pylon_hp,y
	sta	OBJ_HP,x
	rtl
@active:
	cmp	#$0002
	bne	@fire_timer
	; (not executed in the CDL traces)
	brl	airship_part_explode
@fire_timer:
	dec	OBJ_TIMER,x
	bpl	@return
	ldy	$3A,x
	lda	a:lightning_pylon_fire_delays,y
	sta	OBJ_TIMER,x
	ldy	#$0580
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#OBJT_LIGHTNING_BOLT
	sta	a:$0010,y
	clc
	lda	OBJ_X,x
	adc	#$0001
	sta	a:$000A,y
	clc
	lda	OBJ_Y,x
	adc	#$0008
	sta	a:$000E,y
	txa
	sta	a:$0032,y
@return:
	rtl

; Object type $7B. Stage 4, airship: the lightning bolts and their sparks.
update_lightning_bolt:
	ldy	$32,x
	lda	a:$0010,y
	cmp	#$007A
	bne	@pylon_gone
	lda	a:$0016,y
	bne	@dispatch
@pylon_gone:
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@dispatch:
	jsr	a:scroll_with_airship
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_lightning_bolt_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_lightning_bolt_states:
	.addr	lightning_bolt_state_00
	.addr	lightning_bolt_state_01
	.addr	lightning_bolt_state_02
	.addr	lightning_bolt_state_03

lightning_bolt_state_00:
	inc	OBJ_STATE,x
	lda	#$0018
	sta	OBJ_TIMER,x
	lda	#$000C
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05F246)
	sta	OBJ_ANIM,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFC0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$3000
	sta	OBJ_ATTR,x
	rtl

lightning_bolt_state_01:
	dec	OBJ_TIMER,x
	bpl	@return
	inc	OBJ_STATE,x
	lda	#$0008
	sta	OBJ_TIMER,x
	lda	#$0014
	jml	f:queue_sound
@return:
	rtl

lightning_bolt_state_02:
	dec	OBJ_TIMER,x
	bpl	@fall
	inc	OBJ_STATE,x
	lda	#$0020
	sta	OBJ_TIMER,x
	inc	OBJ_FACING,x
@fall:
	clc
	lda	OBJ_Y,x
	adc	#$0008
	sta	OBJ_Y,x
	rtl

lightning_bolt_state_03:
	dec	OBJ_TIMER,x
	bpl	@sparks
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@sparks:
	lda	stage_frame_odd
	bne	@return
	ldy	#$0580
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#.loword(anim_05C672)
	jsl	f:make_effect_object
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	rng_lo
	and	#$0007
	pha
	clc
	adc	#$FFFC
	sta	a:$001E,y
	pla
	clc
	adc	#$FFF7
	sta	a:$001A,y
	inc	rng_lo
@return:
	rtl

; Object type $7D. Stage 4, airship: clusters of spiked mines dropped by the
; airship.
update_spiked_mine:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_spiked_mine_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spiked_mine_states:
	.addr	spiked_mine_state_00
	.addr	spiked_mine_state_01
	.addr	spiked_mine_state_02
	.addr	spiked_mine_state_03
	.addr	spiked_mine_state_04

spiked_mine_state_00:
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06C81D)
	sta	OBJ_SPRITE,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$001E
	sta	OBJ_HITBOX_W,x
	lda	#$FFE2	; [num]
	sta	OBJ_HITBOX_H,x
	stz	$30,x
	stz	$32,x
	stz	zp_FC
	stx	zp_02
	phx
	ldx	#$0A80
@loop:
	cpx	#$07C0
	bcc	@done
	jsl	f:find_free_slot_x_down
	bcc	@loop
	lda	#OBJT_SPIKED_MINE
	sta	$10,x
	lda	#$0002
	sta	$12,x
	lda	zp_FC
	sta	$30,x
	phx
	tax
	lda	#$F000	; [num]
	sta	f:$7EA070,x
	sta	f:$7EA072,x
	sta	f:$7EA074,x
	sta	f:$7EA076,x
	sta	f:$7EA078,x
	sta	f:$7EA07A,x
	sta	f:$7EA07C,x
	sta	f:$7EA07E,x
	plx
	lda	zp_02
	sta	$3E,x
	stz	$34,x
	clc
	lda	zp_FC
	adc	#$0010
	sta	zp_FC
	cmp	#$0070
	bcc	@loop
	inc	$34,x
@done:
	plx
	stz	$3A,x
	lda	#$0100
	sta	$36,x
	rtl

spiked_mine_state_01:
	jsr	a:scroll_with_airship
	lda	$3A,x
	bne	@swing_back
	clc
	lda	$38,x
	adc	#$0002
	bmi	@store_swing
	cmp	#$0010
	bcc	@store_swing
	ldy	#$0002
	sty	$3A,x
	bra	@store_swing
@swing_back:
	sec
	lda	$38,x
	sbc	#$0002
	bpl	@store_swing
	cmp	#$FFB0	; [num]
	bcs	@store_swing
	stz	$3A,x
@store_swing:
	sta	$38,x
	sta	f:scroll_hdma_tables+$E2
	lda	#$0200
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	asl	a
	cmp	$36,x
	bcc	@dec_angle
	clc
	lda	$36,x
	adc	#$0002
	cmp	#$0160
	bcc	@store_angle
	lda	#$0160
	bra	@store_angle
@dec_angle:
	sec
	lda	$36,x
	sbc	#$0002
	cmp	#$00A0
	bcs	@store_angle
	lda	#$00A0
@store_angle:
	and	#$01FE
	sta	$36,x
	sta	f:scroll_hdma_tables+$E0
	txy
	clc
	lda	$30,x
	adc	$32,x
	tax
	lda	a:$000E,y
	sta	f:$7EA000,x
	lda	a:$000A,y
	sta	f:$7EA070,x
	tyx
	lda	$32,x
	adc	#$0002
	and	#$000E
	sta	$32,x
	rtl

spiked_mine_state_02:
	lda	#.loword(metasprite_06C81D)
	ldy	$34,x
	beq	@set_sprite
	lda	#.loword(metasprite_06C82E)
@set_sprite:
	sta	OBJ_SPRITE,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$403C
	sta	OBJ_FLAGS,x
	lda	#$001E
	sta	OBJ_HITBOX_W,x
	lda	#$FFE2	; [num]
	sta	OBJ_HITBOX_H,x
	stz	$32,x
	inc	OBJ_STATE,x
	lda	$34,x
	beq	@return
	inc	OBJ_STATE,x
@return:
	rtl

spiked_mine_state_03:
	jsr	a:spiked_mine_follow
	jsr	a:spiked_mine_pass_position
	rtl

spiked_mine_state_04:
	jsr	a:spiked_mine_follow
	jsr	a:spiked_mine_set_position
	rtl

; A chain member: position = the recorded position of the one before (ring
; buffers at $7E:A000/$7E:A070) plus a point on a circle turning by
; scroll_hdma_tables+$E2; explodes when the leader (field $3E) is gone.
spiked_mine_follow:
	ldy	$3E,x
	lda	a:$0010,y
	cmp	#$007D
	beq	@leader_alive
	lda	#$FFFB	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	txy
	lda	#.loword(anim_05C516)
	jsl	f:make_effect_object
@leader_alive:
	phx
	lda	f:scroll_hdma_tables+$E0
	and	#$01FE
	tay
	clc
	adc	f:scroll_hdma_tables+$E2
	sta	f:scroll_hdma_tables+$E0
	clc
	lda	$32,x
	adc	#$0004
	and	#$000E
	clc
	adc	$30,x
	tax
	lda	a:circle15_x,y
	adc	f:$7EA070,x
	sta	zp_00
	lda	a:circle15_y,y
	adc	f:$7EA000,x
	sta	zp_02
	plx
	lda	$32,x
	inc	a
	inc	a
	and	#$000E
	sta	$32,x
	rts

; Records the position for the next mine of the chain, then
; spiked_mine_set_position (OBJ_X/OBJ_Y = zp_00/zp_02).
spiked_mine_pass_position:
	clc
	adc	#$0010
	clc
	adc	$30,x
	phx
	tax
	lda	zp_00
	sta	f:$7EA070,x
	lda	zp_02
	sta	f:$7EA000,x
	plx

spiked_mine_set_position:
	lda	zp_02
	sta	OBJ_Y,x
	lda	zp_00
	sta	OBJ_X,x
	rts

; Object type $7F. Stage 4, airship: the hanging cannon arms (128 HP).
update_airship_gun_arm:
	jsr	a:scroll_with_airship
	lda	OBJ_HP,x
	bpl	@alive
	; (not executed in the CDL traces)
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#$0002
	sta	OBJ_STATE,x
	lda	#$0020
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	zp_02
	lda	#$0018
	sta	zp_08
	ldy	#.loword(vram_blocks_05F272)
	lda	#$4100
	phx
	ldx	#$0000
	jsl	f:queue_vram_blocks_at_x
	lda	#$0001
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#.loword(vram_blocks_05F272)
	lda	#$451C
	ldx	#$0018
	jsl	f:queue_vram_blocks_at_x
	plx
@alive:
	lda	$12,x
	bne	@active
	inc	$12,x
	lda	#$4010
	sta	$16,x
	lda	#ENEMY_HP($0080)
	sta	$06,x
	lda	#$003C
	sta	$28,x
	lda	#$FFE2	; [num]
	sta	$2A,x
	lda	#$0001
	sta	$24,x
	rtl
@active:
	cmp	#$0002
	bne	@check_fire
	; (not executed in the CDL traces)
	brl	airship_part_explode
@check_fire:
	lda	$24,x
	beq	@return
	lda	#$0800
	jsl	f:pick_target_player
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bmi	@fire
	cmp	#$0060
	bcs	@return
@fire:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#OBJT_AIRSHIP_GUN_ARM_SHELL
	sta	a:$0010,y
	lda	$0A,x
	adc	#$000C
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	stz	$24,x
@return:
	rtl

; Object type $80. Stage 4, airship: shell fired by a gun arm
; (update_airship_gun_arm; seen in the emulator): flies down at 45 degrees
; trailing smoke, then burns along the road.
update_airship_gun_arm_shell:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$0003
	sta	OBJ_X_VEL,x
	sta	OBJ_Y_VEL,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#.loword(anim_05F278)
	sta	OBJ_ANIM,x
	lda	#$0015
	jml	f:queue_sound
@active:
	cmp	#$0002
	beq	@crashed
	lda	OBJ_Y,x
	cmp	#$00B0
	bcc	@trail
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$FFF8	; [num]
	sta	OBJ_X_VEL,x
	inc	OBJ_STATE,x
@trail:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@set_attr
	lda	#.loword(anim_05C672)
	jsl	f:make_effect_object
	lda	#$FFFA	; [num]
	sta	a:$001A,y
	sta	a:$001E,y
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	bra	@set_attr
@crashed:
	jsl	f:queue_sound_41_throttled
	lda	#$001F
	sta	zp_04
	lda	#$0007
	sta	zp_06
	lda	OBJ_X,x
	sta	zp_00
	lda	#$00B0
	sta	zp_02
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	@set_attr
	lda	rng_hi
	and	#$0003
	adc	#$FFF8
	sta	a:$001E,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8	; [num]
	sta	a:$002A,y
	lda	#$000F
	sta	a:$0016,y
@set_attr:
	ldy	OBJ_ANIM,x
	lda	a:$0004,y
	sta	OBJ_ATTR,x
	rtl

; Object type $84. Stage 4, helicopter: the rope hanging from the helicopter;
; one handler for the anchor (state 4), the segments (state 5) and the enemy
; at the end (states 2/3/8/9, with HP).
update_helicopter_rope:
	cpx	#$0900
	bne	@dispatch
	lda	OBJ_HP,x
	bmi	@fall_off
	lda	OBJ_Y,x
	cmp	#$0180
	bmi	@dispatch
	; (not executed in the CDL traces)
	bcc	@dispatch
@fall_off:
	jsl	f:delete_trail_chain
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#.loword(metasprite_06CB30)
	sta	OBJ_SPRITE,x
	lda	#$0002
	sta	OBJ_X_VEL,x
	stz	OBJ_Y_VEL,x
	lda	#$000C
	sta	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_HP,x
	lda	#$0015
	jsl	f:queue_sound
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_helicopter_rope_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_helicopter_rope_states:
	.addr	helicopter_rope_state_00
	.addr	helicopter_rope_state_01
	.addr	helicopter_rope_state_02
	.addr	helicopter_rope_state_03
	.addr	helicopter_rope_state_04
	.addr	helicopter_rope_state_05
	.addr	helicopter_rope_state_06
	.addr	helicopter_rope_state_07
	.addr	helicopter_rope_state_08
	.addr	helicopter_rope_state_09
	.addr	helicopter_rope_state_0A
	.addr	helicopter_rope_state_0B
	.addr	helicopter_rope_state_0C

helicopter_rope_state_00:
	lda	a:bg2_scroll_mode
	cmp	#$000B
	bne	@return
	inc	OBJ_STATE,x
	lda	#$01C0
	sta	OBJ_TIMER,x
	phx
	ldx	#.loword(load_list_05F286)
	jsl	f:load_data_list
	plx
@return:
	rtl

helicopter_rope_state_01:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0015
	jsl	f:queue_sound
	lda	#.loword(metasprite_06C859)
	sta	OBJ_SPRITE,x
	lda	#$3400
	sta	OBJ_ATTR,x
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#$00F0
	sta	OBJ_Y,x
	stz	OBJ_X,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFEE	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#ENEMY_HP($0080)
	sta	OBJ_HP,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$8000	; [num]
	sta	OBJ_Y_VEL_SUB,x
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	inc	OBJ_STATE,x
@return:
	rtl

helicopter_rope_state_02:
	lda	OBJ_Y,x
	cmp	#$0060
	bcs	@smoke
	cmp	#$0078
	bcs	@return
	jsl	f:spawn_helicopter_rope
	lda	#$0006
	sta	OBJ_STATE,x
	rtl
@smoke:
	lda	#$000F
	sta	zp_06
	sta	zp_04
	lda	OBJ_X,x
	adc	#$FFF0
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	ldy	#$0700
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001A,y
	lda	#$0004
	sta	a:$001E,y
@return:
	rtl

spawn_helicopter_rope:
	lda	#$0001
	sta	zp_00
	lda	#$0006
	sta	zp_04
	lda	#$0003
	ldy	#$0940
	jsl	f:spawn_trail_chain
	stz	$34,x
	lda	#$0002
	sta	$32,x
	lda	#$0008
	sta	zp_FC
	phx
	ldx	#$08C0
@loop:
	jsl	f:find_free_slot_x_down
	bcc	@done
	lda	#OBJT_HELICOPTER_ROPE
	sta	$10,x
	lda	#$0005
	sta	$12,x
	lda	zp_FC
	sta	$34,x
	lda	#$3400
	sta	$02,x
	phx
	ldx	zp_FC
	lda	#$8000	; [num]
	sta	f:$7EA070,x
	sta	f:$7EA072,x
	sta	f:$7EA074,x
	sta	f:$7EA076,x
	plx
	clc
	lda	zp_FC
	adc	#$0008
	sta	zp_FC
	cmp	#$0070
	bcc	@loop
	lda	#$0004
	sta	$12,x
	lda	#$3400
	sta	$02,x
	stz	$16,x
@done:
	plx
	stz	a:boss_work_1
	lda	#$0004
	sta	a:boss_work_5
	rtl

helicopter_rope_state_05:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_FLAGS
	cmp	#$0001
	bne	@boss_alive
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@boss_alive:
	lda	#$0000
	ldy	a:boss_work_4
	bne	@set_sprite
	lda	#.loword(metasprite_06CB86)
@set_sprite:
	sta	OBJ_SPRITE,x
	jsr	a:helicopter_rope_swing_offset
	jsr	a:helicopter_rope_store_position
	jsr	a:helicopter_rope_set_position
	rtl

helicopter_rope_state_03:
	jsr	a:helicopter_rope_enemy_pick_sprite
	jsr	a:helicopter_rope_swing

; The enemy at the end of the rope (slot $0900): helicopter_rope_swing_offset,
; then its position by sprite frame (helicopter_rope_enemy_offset), then
; trail_pass_to_next.
helicopter_rope_place_enemy:
	jsr	a:helicopter_rope_swing_offset
	jsr	a:helicopter_rope_enemy_offset
	jml	f:trail_pass_to_next

helicopter_rope_state_04:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_FLAGS
	cmp	#$0001
	bne	@boss_alive
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@boss_alive:
	stz	OBJ_FLAGS,x
	lda	#$0000
	ldy	a:boss_work_4
	bne	@set_sprite
	lda	#.loword(metasprite_06CB77)
	ldy	stage_frame_bit1
	bne	@clear_flags
	lda	#.loword(metasprite_06CB72)
@clear_flags:
	ldy	#$0000
	sty	OBJ_FLAGS,x
@set_sprite:
	sta	OBJ_SPRITE,x
	lda	a:boss_work_1
	beq	@swing
	lda	#.loword(metasprite_06CB72)
	sta	OBJ_SPRITE,x
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	jsr	a:helicopter_rope_next_ring_index
	jsr	a:helicopter_rope_store_position
	jsr	a:helicopter_rope_set_position
	lda	a:boss_work_2
	bne	@return
	ldy	a:boss_work_3
	lda	OBJ_X,x
	cmp	#$0084
	bcc	@left_side
	cpy	#$0140
	bcc	@return
	cpy	#$0144
	bcs	@return
	lda	a:boss_work_7
	bmi	@return
	lda	#$FFFF	; [num]
	bra	@jump_off
@left_side:
	cpy	#$00C0
	bcs	@return
	cpy	#$00BC
	bcc	@return
	lda	a:boss_work_7
	bpl	@return
	lda	#$0001
@jump_off:
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_X_VEL
	stz	a:boss_work_1
	lda	#$0004
	sta	a:boss_work_5
	lda	#$0006
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	lda	#$FFFC	; [num]
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL_SUB
@return:
	rtl
@swing:
	jsr	a:helicopter_rope_swing_offset
	jsr	a:helicopter_rope_set_position
	jsr	a:helicopter_rope_check_missile_contact
	rtl

helicopter_rope_state_06:
	lda	#$0007
	sta	OBJ_STATE,x
	lda	OBJ_X_VEL,x
	bpl	@moving_right
	stz	a:boss_work_0
	stz	OBJ_FACING,x
	lda	#$0240
	bra	@set_swing
@moving_right:
	lda	#$0002
	sta	a:boss_work_0
	sta	OBJ_FACING,x
	lda	#$01C2
@set_swing:
	sta	a:boss_work_3
	stz	a:boss_work_6
	stz	a:boss_work_7
	lda	#.loword(anim_05F2F3)
	sta	OBJ_ANIM,x
	lda	#$0016
	sta	a:boss_work_4

helicopter_rope_state_07:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	ldy	OBJ_FACING,x
	clc
	lda	OBJ_X,x
	adc	a:helicopter_rope_jump_x_offsets,y
	sta	zp_00
	clc
	lda	OBJ_Y,x
	adc	#$FFEE
	sta	zp_02
	jsr	a:helicopter_rope_next_ring_index
	jsr	a:helicopter_rope_store_position
	lda	a:boss_work_4
	bne	@count_down
	stz	a:boss_work_5
	bra	@trail
@count_down:
	dec	a:boss_work_4
@trail:
	jml	f:trail_pass_to_next
helicopter_rope_goto_state_03:
	brl	helicopter_rope_state_03

helicopter_rope_state_08:
	lda	a:boss_work_3
	cmp	#$00FD
	bcc	helicopter_rope_goto_state_03
	cmp	#$0103
	bcs	helicopter_rope_goto_state_03
	inc	OBJ_STATE,x

helicopter_rope_state_09:
	lda	stage_frame_mod4
	bne	@place
	inc	a:boss_work_5
	lda	a:boss_work_5
	cmp	#$0004
	bcc	@place
	lda	#$0100
	sta	a:boss_work_3
	lda	#$7FFF
	sta	a:boss_work_4
	stz	a:boss_work_6
	stz	a:boss_work_7
	inc	OBJ_STATE,x
	lda	#.loword(anim_05F30B)
	sta	OBJ_ANIM,x
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	#$0400
	jsl	f:pick_target_player
	lda	a:$000A,y
	cmp	OBJ_X,x
	bcc	@face_left
	stz	OBJ_FACING,x
	bra	@place
@face_left:
	lda	#$0002
	sta	OBJ_FACING,x
@place:
	brl	helicopter_rope_place_enemy

helicopter_rope_state_0A:
	dec	OBJ_TIMER,x
	bne	@check_throw
	inc	OBJ_STATE,x
	stz	a:boss_work_4
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
@check_throw:
	lda	OBJ_TIMER,x
	cmp	#$0014
	bne	@place
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	@place
	lda	#OBJT_HELICOPTER_ROPE_BOOMERANG
	sta	a:$0010,y
	lda	OBJ_FACING,x
	sta	a:$0004,y
	lda	OBJ_X,x
	adc	#$0008
	sta	a:$000A,y
	lda	OBJ_Y,x
	adc	#$0000
	sta	a:$000E,y
@place:
	jsl	f:helicopter_rope_place_enemy
	lda	#$007C
	sta	OBJ_Y,x
	jml	f:trail_pass_to_next

helicopter_rope_state_0B:
	lda	stage_frame_mod4
	bne	@place
	dec	a:boss_work_5
	bne	@place
	lda	#$0003
	sta	OBJ_STATE,x
	lda	#$0002
	sta	a:boss_work_2
@place:
	jsr	a:helicopter_rope_enemy_pick_sprite
	brl	helicopter_rope_place_enemy

helicopter_rope_state_0C:
	lda	OBJ_Y,x
	cmp	#$0180
	bcs	@gone
	lda	OBJ_X,x
	bpl	@fall
	cmp	#$FFC8	; [num]
	bcs	@fall
@gone:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@fall:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	stage_frame_odd
	bne	@return
	ldy	#$0700
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	OBJ_X,x
	adc	#$0000
	sta	a:$000A,y
	lda	rng_lo
	and	#$000F
	adc	OBJ_Y,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$FFF8	; [num]
	sta	a:$001A,y
@return:
	rtl

; zp_00/zp_02 = the recorded position of the segment before (ring buffers
; $7E:A000/$7E:A070) plus a point on a circle at the swing angle
; (boss_work_3), halved boss_work_5 + 1 times; then
; helicopter_rope_next_ring_index.
helicopter_rope_swing_offset:
	phx
	lda	a:boss_work_3
	and	#$01FE
	tay
	clc
	lda	a:circle15_x,y
	bpl	@x_halved
	sec
@x_halved:
	ror	a
	sta	zp_00
	clc
	lda	a:circle15_y,y
	bpl	@y_halved
	sec
@y_halved:
	ror	a
	sta	zp_02
	ldy	a:boss_work_5
@shrink_loop:
	cpy	#$0000
	beq	@add_parent
	clc
	lda	zp_00
	bpl	@x_shrunk
	sec
@x_shrunk:
	ror	a
	sta	zp_00
	clc
	lda	zp_02
	bpl	@y_shrunk
	sec
@y_shrunk:
	ror	a
	sta	zp_02
	dey
	bra	@shrink_loop
@add_parent:
	clc
	lda	$32,x
	adc	#$0000
	and	#$0006
	clc
	adc	$34,x
	tax
	lda	zp_00
	adc	f:$7EA070,x
	sta	zp_00
	lda	zp_02
	adc	f:$7EA000,x
	sta	zp_02
	plx

helicopter_rope_next_ring_index:
	lda	$32,x
	inc	a
	inc	a
	and	#$0006
	sta	$32,x
	rts

; Stores zp_00/zp_02 into the ring buffer for the next segment (offset
; helicopter_rope_ring_offsets[boss_work_1]); helicopter_rope_set_position
; sets OBJ_X/OBJ_Y from them.
helicopter_rope_store_position:
	ldy	a:boss_work_1
	clc
	adc	a:helicopter_rope_ring_offsets,y
	clc
	adc	$34,x
	phx
	tax
	lda	zp_00
	sta	f:$7EA070,x
	lda	zp_02
	sta	f:$7EA000,x
	plx
	rts

helicopter_rope_set_position:
	lda	zp_02
	sta	OBJ_Y,x
	lda	zp_00
	sta	OBJ_X,x
	rts

; Sprite of the enemy on the rope by swing angle (boss_work_3) and OBJ_FACING
; (helicopter_rope_enemy_sprites); the index is kept in field $3A for the
; offsets (helicopter_rope_enemy_x_offsets, helicopter_rope_enemy_y_offsets).
helicopter_rope_enemy_pick_sprite:
	clc
	lda	a:boss_work_3
	adc	#$0020
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	clc
	adc	OBJ_FACING,x
	tay
	sty	$3A,x
	lda	a:helicopter_rope_enemy_sprites,y
	sta	OBJ_SPRITE,x
	rts

helicopter_rope_enemy_offset:
	ldy	$3A,x
	clc
	lda	a:helicopter_rope_enemy_x_offsets,y
	adc	zp_00
	sta	OBJ_X,x
	clc
	lda	a:helicopter_rope_enemy_y_offsets,y
	adc	zp_02
	sta	OBJ_Y,x
	rts

; A rope segment touching the missile of slot $0800 (while the enemy is not
; rising): spark, sound $33, and the enemy (slot $0900) goes to state 3 or 8.
helicopter_rope_check_missile_contact:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL
	bpl	@check_contact
	rts
@check_contact:
	ldy	#$0800
	lda	a:$000E,y
	cmp	OBJ_Y,x
	bcc	@return
	clc
	adc	#$FFF0
	cmp	OBJ_Y,x
	bcs	@return
	lda	a:$000A,y
	cmp	OBJ_X,x
	bcs	@return
	clc
	adc	a:$0028,y
	cmp	OBJ_X,x
	bcc	@return
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	@hit_enemy
	lda	#$0033
	jsl	f:queue_sound
	lda	#.loword(anim_05C6BA)
	jsl	f:make_effect_object
	lda	#$FFFC	; [num]
	sta	a:$001A,y
	lda	#$FFFE	; [num]
	sta	a:$001E,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	lda	OBJ_X,x
	sta	a:$000A,y
@hit_enemy:
	ldy	#$0003
	lda	rng_lo
	and	#$0001
	bne	@set_enemy_state
	lda	#$0080
	ldy	#$0008
@set_enemy_state:
	sty	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	sta	a:boss_work_2
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_X_VEL
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_ANIM_TIMER
	lda	#$0002
	sta	a:boss_work_1
	clc
	lda	a:boss_work_3
	adc	#$00FE
	and	#$01FE
	sta	a:boss_work_3
@return:
	rts

; Pendulum: the angular speed (boss_work_6/7) is pushed back towards the
; middle and the direction reverses past $A4/$160; adds it to the angle
; boss_work_3.
helicopter_rope_swing:
	lda	a:boss_work_3
	ldy	a:boss_work_0
	beq	@direction_0
	cmp	#$0160
	bcs	@reverse
	lda	a:boss_work_7
	bmi	@inc_speed
	cmp	#$0004
	bcs	@add_speed
@inc_speed:
	clc
	lda	a:boss_work_6
	adc	#$8000
	sta	a:boss_work_6
	lda	a:boss_work_7
	adc	#$0000
	sta	a:boss_work_7
	bra	@add_speed
@direction_0:
	cmp	#$00A4
	bcc	@reverse
	lda	a:boss_work_7
	bpl	@dec_speed
	cmp	#$FFFD	; [num]
	bcc	@add_speed
@dec_speed:
	sec
	lda	a:boss_work_6
	sbc	#$8000
	sta	a:boss_work_6
	lda	a:boss_work_7
	sbc	#$0000
	sta	a:boss_work_7
	bra	@add_speed
@reverse:
	lda	a:boss_work_0
	eor	#$0002
	sta	a:boss_work_0
	sta	OBJ_FACING,x
	lda	a:boss_work_2
	beq	@add_speed
	dec	a:boss_work_2
@add_speed:
	clc
	lda	a:boss_work_7
	adc	a:boss_work_3
	sta	a:boss_work_3
	rts

; Object type $85. Stage 4, helicopter scene: spinning blade thrown by the
; enemy at the end of the rope (helicopter_rope_state_0A; seen in the
; emulator); flies out sideways and comes back like a boomerang.
update_helicopter_rope_boomerang:
	lda	OBJ_STATE,x
	bne	@fly
	inc	OBJ_STATE,x
	lda	#.loword(anim_05F32D)
	sta	OBJ_ANIM,x
	lda	#$000F
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	OBJ_FACING,x
	lda	a:helicopter_rope_boomerang_x_vels,y
	sta	OBJ_X_VEL,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$2000
	sta	OBJ_Y_VEL_SUB,x
	rtl
@fly:
	ldy	OBJ_FACING,x
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	a:helicopter_rope_boomerang_x_accel_subs,y
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	a:helicopter_rope_boomerang_x_accels,y
	sta	OBJ_X_VEL,x
	rtl
