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
	bcc	loc_04802A
	lda	#$0001
	sta	a:shake_continuous
	ldy	#$0050
	jsl	f:flash_palette_on_hit
	lda	stage_frame_counter
	and	#$000C
	lsr	a
	lsr	a
	bit	#$0002
	beq	loc_048023
	eor	#$FFFF
loc_048023:
	clc
	adc	#$0100
	sta	a:bg2_y
loc_04802A:
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
	bne	loc_0480E1
	inc	OBJ_STATE,x
	stz	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$401D
	sta	OBJ_FLAGS,x
loc_0480E1:
	rtl

stage3_robot_state_02:
	dec	OBJ_TIMER,x
	bpl	loc_0480E1
	ldy	difficulty
	lda	a:stage3_robot_wait_times,y
	sta	OBJ_TIMER,x
	jsr	a:stage3_robot_pick_direction
	ldy	zp_00
	lda	OBJ_Y,x
	cmp	#$00CF
	bcs	loc_048120
	lda	OBJ_X,x
	cmp	#$0070
	bcc	loc_04810C
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	bra	loc_048113
loc_04810C:
	; (not executed in the CDL traces)
	stz	OBJ_FACING,x
	lda	#$0001
	sta	OBJ_X_VEL,x
loc_048113:
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E83B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
loc_048120:
	lda	zp_06
	cmp	#$0070
	bcc	loc_04814B
	lda	zp_04
	cmp	#$0030
	bcs	loc_04814B
	lda	zp_00
	sta	OBJ_FACING,x
	lda	#$0004
	sta	$36,x
	lda	#$FFF8	; [num]
	sta	$32,x
	stz	$34,x
loc_04813E:
	lda	#$0003
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E81D)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
loc_04814B:
	lda	OBJ_X,x
	cmp	#$0031
	bcc	loc_048157
	cmp	#$00AF
	bcc	loc_04816E
loc_048157:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_jump_x_vels,y
	sta	$34,x
	lda	#$0005
	sta	$36,x
	lda	#$FFFB	; [num]
	sta	$32,x
	brl	loc_04813E
loc_04816E:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_hop_x_vels,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFB	; [num]
	sta	$32,x
	brl	loc_04813E
loc_048185:
	rtl

stage3_second_robot_state_02:
	dec	OBJ_TIMER,x
	bpl	loc_048185
	ldy	difficulty
	lda	a:stage3_second_robot_wait_times,y
	sta	OBJ_TIMER,x
	jsr	a:stage3_robot_pick_direction
	lda	OBJ_Y,x
	cmp	#$00CF
	bcs	loc_0481A8
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E83B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
loc_0481A8:
	lda	zp_04
	cmp	#$0050
	bcs	loc_0481C5
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
loc_0481C5:
	ldy	#$0000
	lda	OBJ_X,x
	cmp	#$0070
	bcc	loc_0481D2
	ldy	#$0002
loc_0481D2:
	lda	a:stage3_robot_facings,y
	sta	OBJ_FACING,x
	lda	a:stage3_robot_hop_x_vels,y
	sta	$34,x
	lda	#$0004
	sta	$36,x
	lda	#$FFFD	; [num]
	sta	$32,x
	brl	loc_04813E

stage3_boss_state_06:
	lda	OBJ_HP,x
	bmi	loc_048216
	dec	$3E,x
	bpl	loc_04821C
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
loc_048216:
	lda	#$0002
	sta	OBJ_STATE,x
	rtl
loc_04821C:
	jsr	a:stage3_robot_pick_direction
	lda	zp_00
	sta	OBJ_FACING,x
	rtl

stage3_second_robot_state_06:
	lda	OBJ_HP,x
	bmi	loc_04822C
	dec	$3E,x
	bpl	loc_048239
loc_04822C:
	lda	#$0002
	sta	OBJ_STATE,x
	lda	#.loword(anim_05E829)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	rtl
loc_048239:
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
	bcc	loc_048265
	cmp	#$00B0
	bcc	loc_048299
	lda	OBJ_X_VEL,x
	bmi	loc_048299
	lda	#$00B0
	sta	OBJ_X,x
	bpl	loc_04826E
loc_048265:
	lda	OBJ_X_VEL,x
	bpl	loc_048299
	lda	#$0030
	sta	OBJ_X,x
loc_04826E:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	bra	loc_048299

stage3_robot_state_05:
	lda	OBJ_X,x
	cmp	#$0010
	bcc	loc_048284
	cmp	#$00D0
	bcc	loc_048299
	stz	OBJ_FACING,x
	bra	loc_048289
loc_048284:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	OBJ_FACING,x
loc_048289:
	lda	#$0033
	jsl	f:queue_sound
	lda	#.loword(anim_05E841)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	loc_048306
loc_048299:
	lda	OBJ_Y_VEL,x
	bpl	loc_0482CA
	lda	OBJ_Y,x
	cmp	#$0090
	bcs	loc_04831A
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
	bra	loc_04830B
loc_0482CA:
	lda	OBJ_Y,x
	cmp	#$00D0
	bcc	loc_04831A
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
	bcs	loc_0482F6
	lda	#$0030
	sta	OBJ_X,x
	bra	loc_048306
loc_0482F6:
	sec
	lda	#$00B0
	sbc	OBJ_X,x
	cmp	#$0008
	bcs	loc_048306
	lda	#$00B0
	sta	OBJ_X,x
loc_048306:
	lda	#$0002
	sta	OBJ_STATE,x
loc_04830B:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	#$0003
	sta	a:shake_timer
	rtl
loc_04831A:
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
	bpl	loc_04834A
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
loc_04834A:
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
	bne	loc_048396
	lda	rng_hi
	adc	OBJ_X,x
	bit	#$0001
	bne	loc_048396
	lda	OBJ_FACING,x
	eor	#$0002
	sta	OBJ_FACING,x
loc_048396:
	lda	OBJ_X,x
	cmp	#$0010
	bcs	loc_0483A6
	stz	OBJ_FACING,x
	lda	#$0003
	sta	OBJ_X_VEL,x
	bra	loc_0483B5
loc_0483A6:
	cmp	#$00D8
	bcc	loc_0483B5
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$FFFD	; [num]
	sta	OBJ_X_VEL,x
loc_0483B5:
	lda	OBJ_FACING,x
	beq	loc_0483D3
	lda	OBJ_X_VEL,x
	bpl	loc_0483C2
	cmp	#$FFFD	; [num]
	bcc	loc_0483EB
loc_0483C2:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bra	loc_0483EB
loc_0483D3:
	lda	OBJ_X_VEL,x
	bmi	loc_0483DC
	cmp	#$0003
	bcs	loc_0483EB
loc_0483DC:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
loc_0483EB:
	lda	OBJ_Y_VEL,x
	bmi	loc_0483F7
	jsl	f:object_follow_floor
	lda	zp_FC
	bne	loc_048411
loc_0483F7:
	lda	OBJ_Y_VEL,x
	bmi	loc_048400
	cmp	#$0005
	bcs	loc_04842D
loc_048400:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$5000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	loc_04842D
loc_048411:
	lda	rng_lo
	adc	OBJ_X,x
	and	#$000F
	bne	loc_04842D
	lda	#.loword(anim_05E86B)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$FFF9	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0034
	jsl	f:queue_sound
loc_04842D:
	rtl

stage3_robot_state_09:
	dec	OBJ_TIMER,x
	bpl	loc_048439
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
loc_048439:
	brl	loc_04834A

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
	bpl	loc_0484B8
	lda	#.loword(anim_05E7EB)
	sta	OBJ_ANIM,x
	inc	OBJ_STATE,x
	ldy	#$0200
	jsr	a:stage3_cables_crush_player
	ldy	#$0240
	jsr	a:stage3_cables_crush_player
	lda	#$0040
	sta	zp_04
	lda	#$2002
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
	jml	f:update_object_type_28
loc_0484B8:
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
	bpl	loc_048501
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_048501:
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
	beq	loc_048575
	stz	zp_00
	sec
	lda	a:$000A,y
	sbc	OBJ_X,x
	bpl	loc_048565
	eor	#$FFFF
	inc	zp_00
	inc	zp_00
loc_048565:
	sta	zp_04
	sec
	lda	a:$000E,y
	sbc	OBJ_Y,x
	bpl	loc_048572
	eor	#$FFFF
loc_048572:
	sta	zp_06
	rts
loc_048575:
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
	bne	loc_048604
	ldy	#$0800
	jsl	f:find_free_slot_y_down
	bcc	loc_048604
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
	beq	loc_0485DC
	eor	#$FFFF
loc_0485DC:
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
	bne	loc_048604
	lda	#$001A
	jsl	f:queue_sound
loc_048604:
	rts

stage3_boss_check_hp:
	lda	$38,x
	bne	loc_048631
	lda	OBJ_HP,x
	bpl	loc_048630
	lda	OBJ_STATE,x
	cmp	#$0002
	bne	loc_048630
	lda	#$0007
	sta	OBJ_STATE,x
	lda	#ENEMY_HP($0030)
	sta	OBJ_HP,x
loc_04861E:
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$0080
	sta	OBJ_TIMER,x
	stz	OBJ_ANIM,x
	stz	$30,x
	stz	OBJ_FACING,x
	inc	$38,x
loc_048630:
	rts
loc_048631:
	cmp	#$0002
	bcs	loc_04864D
	lda	OBJ_HP,x
	bmi	loc_04863C
	bpl	loc_048630
loc_04863C:
	inc	OBJ_STATE,x
	lda	#ENEMY_HP($0400)
	sta	OBJ_HP,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	bra	loc_04861E
loc_04864D:
	lda	OBJ_HP,x
	bpl	loc_048630
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
	beq	loc_048675
	lda	$30,x
	sta	OBJ_SPRITE,x
	stz	$30,x
	bra	loc_04867B
loc_048675:
	lda	OBJ_SPRITE,x
	sta	$30,x
	stz	OBJ_SPRITE,x
loc_04867B:
	rts

stage3_boss_state_0A:
	lda	a:obj_slots+27*OBJ_SIZE+OBJ_TYPE
	bne	loc_048699
	dec	OBJ_TIMER,x
	bne	loc_048699
	lda	#.loword(song_set_05F48A)
	sta	a:song_change_set
	lda	#$0004
	sta	a:song_change_mode
	lda	#$0004
	sta	a:shake_timer
	inc	OBJ_STATE,x
loc_048699:
	rtl

stage3_boss_state_0B:
	lda	a:song_change_state
	bne	loc_048699
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
	bne	loc_04873C
	dec	$32,x
	dec	$32,x
	bpl	loc_048704
	inc	OBJ_STATE,x
	lda	#$004E
	jml	f:queue_sound
loc_048704:
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
loc_04873C:
	rtl

stage3_boss_state_0D:
	jsr	a:stage3_boss_break_wall
	dec	a:boss_work_4
	bne	loc_048751
	stz	$34,x
	stz	$36,x
	lda	#$4010
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	rtl
loc_048751:
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
	bne	loc_0487A1
	lda	#$0083
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	lda	#$0100
	sta	a:stage_exit_request
	lda	#$001F
	sta	$34,x
	lda	#$001F
	sta	$36,x
loc_0487A1:
	brl	loc_048929

stage3_boss_state_19:
	lda	#$006D
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	rtl

stage3_boss_state_1A:
	stz	a:boss_work_2
	jsr	a:stage3_boss_break_wall
	lda	OBJ_Y,x
	bmi	loc_0487C2
	cmp	#$00D8
	bcc	loc_0487C2
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
loc_0487C2:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	#$0001
	sta	a:shake_continuous
	jml	f:loc_01D83E

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
	bcs	loc_048819
	lda	a:stage3_boss_state_0E_steps,y
	bra	loc_048821
loc_048819:
	lda	#$0060
	sta	$3E,x
	inc	OBJ_STATE,x
	rtl
loc_048821:
	clc
	adc	$34,x
	sta	$34,x
	and	#$0020
	bne	loc_048830
	lda	#$000C
	bra	loc_048833
loc_048830:
	lda	#$0000
loc_048833:
	jsr	a:stage3_boss_queue_tiles
	rtl

stage3_boss_state_0F:
	stz	$34,x
	lda	#$0000
	jsr	a:stage3_boss_queue_tiles
	dec	$3E,x
	bne	loc_048847
	inc	OBJ_STATE,x
	stz	$36,x
loc_048847:
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
	bne	loc_04886C
	inc	OBJ_STATE,x
	stz	$30,x
	lda	#$003E
	sta	$32,x
	rtl
loc_04886C:
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
	beq	loc_0488A3
	lda	#$000C
loc_0488A3:
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
	beq	loc_0488C6
	lda	#$000C
loc_0488C6:
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
	bne	loc_048923
	lda	#$00A2
	sta	a:boss_work_4
	lda	#$0002
	sta	a:boss_work_2
	lda	#$000D
	sta	OBJ_STATE,x
	lda	#$004E
	jml	f:queue_sound
loc_048923:
	stz	a:boss_work_2
	jsr	a:stage3_boss_break_wall
loc_048929:
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
	bcs	loc_0489A1
	cpy	#$000E
	bcc	loc_04895C
	cmp	#$0000
	beq	loc_0489A1
loc_04895C:
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
loc_0489A1:
	inc	a:boss_work_3
	ldy	a:boss_work_2
	lda	a:boss_work_3
	cmp	a:stage3_boss_wall_step_delays,y
	bcc	loc_0489CB
	stz	a:boss_work_3
	clc
	lda	a:boss_work_1
	adc	a:stage3_boss_wall_step_dirs,y
	bpl	loc_0489C0
	stz	a:boss_work_1
	bra	loc_0489CB
loc_0489C0:
	cmp	#$0008
	bcc	loc_0489C8
	lda	#$0008
loc_0489C8:
	sta	a:boss_work_1
loc_0489CB:
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
	bne	loc_048A5B
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
	bcc	loc_048A5A
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
loc_048A5A:
	plx
loc_048A5B:
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
	bcs	loc_048ADB
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
loc_048ADB:
	plx
	rts

; Object type $4C. Stage 3, skeleton robot: numbered bombs ("3", "2", "1")
; that stick to the walls of the room and explode.
update_countdown_bomb:
	lda	OBJ_STATE,x
	bne	loc_048B25
	lda	#$FFE8	; [num]
	sta	zp_02
	lda	#$0018
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bne	loc_048B0C
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bne	loc_048B0C
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bne	loc_048B0C
	lda	#$0018
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	beq	loc_048B24
loc_048B0C:
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
loc_048B24:
	rtl
loc_048B25:
	cmp	#$0002
	beq	loc_048B45
	lda	OBJ_SPRITE,x
	cmp	$34,x
	beq	loc_048B39
	sta	$34,x
	lda	#$0036
	jsl	f:queue_sound
loc_048B39:
	lda	OBJ_ANIM,x
	bne	@return
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x
@return:
	rtl
loc_048B45:
	dec	OBJ_TIMER,x
	bne	loc_048B4F
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_048B4F:
	lda	#$0030
	jsl	f:queue_sound_throttled
	lda	stage_frame_mod4
	bne	@return
	ldy	#$0280
	jsl	f:find_free_slot_y_to_end
	bcs	@return
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
@return:
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
	bne	loc_048C5B
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
loc_048C5B:
	bra	loc_048C79

skeleton_eye_fireball_state_02:
	dec	OBJ_TIMER,x
	bpl	loc_048C6A
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	jml	f:delete_trail_chain
loc_048C6A:
	dec	$36,x
	bpl	loc_048C79
	dec	OBJ_STATE,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL,x
	lda	#.loword(anim_05C636)
	sta	OBJ_ANIM,x
loc_048C79:
	lda	stage_frame_bit1
	bne	loc_048C84
	lda	OBJ_ATTR,x
	eor	#$0E00
	sta	OBJ_ATTR,x
loc_048C84:
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
	bpl	loc_048CFB
	inc	OBJ_STATE,x
	lda	#$0063
	jsl	f:queue_sound
	stz	OBJ_TIMER,x
loc_048CFB:
	lda	OBJ_TIMER,x
	cmp	#$0090
	bne	loc_048D29
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
loc_048D29:
	jsr	a:scroll_bg1_bg2_right_16
	rtl

stage4_controller_state_03:
	jsr	a:stage4_spawn_weapon_capsule
	jsr	a:stage4_spawn_passing_rider_every_8

stage4_controller_state_02:
	dec	OBJ_TIMER,x
	bpl	loc_048D3E
	lda	#$00C0
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_048D3E:
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
	jml	f:loc_00D5ED
@return:
	rtl

stage4_controller_state_06:
	lda	a:bg1_x
	clc
	adc	#$0010
	and	#$00FF
	bne	loc_048DB2
	inc	OBJ_STATE,x
	lda	#$4000
	sta	$34,x
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0100
loc_048DB2:
	sta	a:bg1_x
	jml	f:loc_00D5ED

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
	bcc	loc_048DE0
	inc	OBJ_STATE,x
	stz	a:bg1_x
loc_048DE0:
	jml	f:loc_00D5ED

stage4_controller_state_08:
	dec	OBJ_TIMER,x
	bpl	loc_048DEF
	lda	#$0140
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_048DEF:
	jml	f:loc_00D5ED

stage4_controller_state_0A:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	bne	loc_048E0D
	lda	#$0002
	sta	a:clear_enemies_timer
	inc	OBJ_STATE,x
	rtl

stage4_controller_state_09:
	dec	OBJ_TIMER,x
	bpl	loc_048E0D
	inc	OBJ_STATE,x
	lda	#$006E
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
loc_048E0D:
	jsr	a:stage4_spawn_dropping_soldier
	jml	f:loc_00D5ED

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
	jml	f:loc_00D5ED

stage4_controller_state_0C:
	ldy	OBJ_TIMER,x
	lda	a:bg1_x
	cmp	#$01E0
	bcs	loc_048E56
	lda	#$0040
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_048E56:
	cmp	a:stage4_scroll_waypoints_x,y
	bcs	loc_048E5F
	inc	OBJ_TIMER,x
	inc	OBJ_TIMER,x
loc_048E5F:
	lda	a:bg1_vel_x_sub+1
	cmp	a:stage4_scroll_target_speeds,y
	beq	loc_048E91
	bmi	loc_048E7E
	sec
	lda	a:bg1_vel_x_sub
	sbc	#$0800
	sta	a:bg1_vel_x_sub
	lda	a:bg1_vel_x
	sbc	#$0000
	sta	a:bg1_vel_x
	bra	loc_048E91
loc_048E7E:
	clc
	lda	a:bg1_vel_x_sub
	adc	#$0800
	sta	a:bg1_vel_x_sub
	lda	a:bg1_vel_x
	adc	#$0000
	sta	a:bg1_vel_x
loc_048E91:
	ldy	$36,x
	bne	loc_048EBE
	lda	a:bg1_y
	cmp	#$000C
	bcs	loc_048E9F
	inc	$36,x
loc_048E9F:
	lda	a:bg1_vel_y_sub+1
	bpl	loc_048EA9
	cmp	#$FF80	; [num]
	bcc	loc_048EE7
loc_048EA9:
	sec
	lda	a:bg1_vel_y_sub
	sbc	#$0400
	sta	a:bg1_vel_y_sub
	lda	a:bg1_vel_y
	sbc	#$0000
	sta	a:bg1_vel_y
	bra	loc_048EE7
loc_048EBE:
	lda	a:bg1_y
	bmi	loc_048ECA
	cmp	#$0010
	bcc	loc_048ECA
	stz	$36,x
loc_048ECA:
	lda	a:bg1_vel_y_sub+1
	bmi	loc_048ED4
	cmp	#$0080
	bcs	loc_048EE7
loc_048ED4:
	clc
	lda	a:bg1_vel_y_sub
	adc	#$0400
	sta	a:bg1_vel_y_sub
	lda	a:bg1_vel_y
	adc	#$0000
	sta	a:bg1_vel_y
loc_048EE7:
	jsl	f:scroll_bg1_by_velocity_and_spawn
	jml	f:loc_00D5ED

stage4_controller_state_0D:
	dec	OBJ_TIMER,x
	bpl	loc_048F01
	lda	#$0079
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	lda	#$0001
	sta	a:stage_checkpoint
	inc	OBJ_STATE,x
loc_048F01:
	jml	f:loc_00D5ED

stage4_controller_state_0E:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	cmp	#$0079
	beq	loc_048F1D
	inc	OBJ_STATE,x
	lda	#$0100
	sta	OBJ_TIMER,x
	phx
	ldx	#.loword(load_list_05ECD0)
	jsl	f:load_data_list
	plx
loc_048F1D:
	jml	f:loc_00D5ED

stage4_controller_state_0F:
	dec	OBJ_TIMER,x
	bpl	loc_048F35
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	#$0084
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	lda	#$0004
	sta	a:bg1_scroll_mode
loc_048F35:
	jsr	a:stage4_spawn_weapon_capsule
	jml	f:loc_00D5ED

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
	bmi	loc_048F91
	cmp	#$0040
	bcc	loc_048F91
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_X_VEL
	inc	OBJ_STATE,x
	lda	#$0006
	sta	a:respawn_mode
loc_048F91:
	jml	f:loc_00D5ED

stage4_controller_state_12:
	lda	a:p1_lives
	beq	loc_048FA2
	lda	a:player1_state
	cmp	#$0001
	bne	loc_048FC7
loc_048FA2:
	lda	a:title_menu_cursor
	beq	loc_048FB4
	lda	a:p2_lives
	beq	loc_048FB4
	lda	a:player2_state
	cmp	#$0001
	bne	loc_048FC7
loc_048FB4:
	inc	OBJ_STATE,x
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_ANIM_TIMER
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_SPRITE
	lda	#$000B
	sta	a:bg2_scroll_mode
	stz	$30,x
loc_048FC7:
	jml	f:update_stage4_line_scroll

stage4_controller_state_13:
	jsl	f:update_stage4_line_scroll
	bra	loc_048FE1

stage4_controller_state_14:
	lda	a:bg2_y
	cmp	#$FE00	; [num]
	bne	loc_048FE1
	lda	#$000A
	sta	a:bg2_scroll_mode
	inc	OBJ_STATE,x
loc_048FE1:
	lda	a:bg1_y
	cmp	#$0010
	beq	loc_049000
	lda	#$C000	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	#$FFFF	; [num]
	sta	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL
	sec
	lda	#$0078
	sbc	a:obj_slots+24*OBJ_SIZE+OBJ_Y
	sta	a:bg1_y
	rtl
loc_049000:
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+24*OBJ_SIZE+OBJ_Y_VEL
	rtl

stage4_controller_state_15:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
	cmp	#$0084
	beq	loc_049017
	lda	#.loword(anim_05C558)
	sta	a:boss_work_0
	inc	OBJ_STATE,x
loc_049017:
	rtl

stage4_controller_state_16:
	lda	stage_frame_odd
	beq	loc_049017
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
	beq	loc_0490DE
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
loc_0490DE:
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_18:
	lda	stage_frame_odd
	beq	loc_04911E
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x

stage4_controller_state_19:
	dec	OBJ_TIMER,x
	bne	loc_049105
	inc	OBJ_STATE,x
	lda	#$0017
	sta	a:tm_shadow
	lda	#$0049
	sta	a:bg2sc_shadow
	lda	#$0069
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_TYPE
loc_049105:
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
loc_04911E:
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
	bcs	loc_0491DF
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
loc_0491DF:
	jsr	a:stage4_scroll_bg3_lower
	rtl

stage4_controller_state_1D:
	dec	OBJ_TIMER,x
	bpl	loc_0491EE
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
loc_0491EE:
	lda	#$00FE
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	stz	a:player1_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player2_obj+PLAYER_BOMB_SPEED_SUB
	stz	a:player1_obj+PLAYER_BOMB_SPEED
	stz	a:player2_obj+PLAYER_BOMB_SPEED
	bra	loc_049231

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
	bpl	loc_04921D
	lda	#$0000
loc_04921D:
	sta	a:player1_obj+PLAYER_BOMB_RADIUS
	sta	a:player2_obj+PLAYER_BOMB_RADIUS
	lda	stage_frame_odd
	bne	loc_049231
	lda	a:player1_obj+PLAYER_BOMB_Y
	inc	a
	sta	a:player1_obj+PLAYER_BOMB_Y
	sta	a:player2_obj+PLAYER_BOMB_Y
loc_049231:
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
	bra	loc_049285

; Turns the slot at X into a rideable missile (type $65, state 7, 120 pixels
; wide platform).
make_rideable_missile:
	sty	$34,x
	lda	#OBJT_RIDEABLE_MISSILE
	sta	OBJ_TYPE,x
	lda	#$0007
	sta	OBJ_STATE,x
	stz	OBJ_X_VEL,x
loc_049285:
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
	bne	loc_0492BE
	lda	OBJ_Y_VEL_SUB,x
	bne	loc_0492BE
	inc	OBJ_STATE,x
loc_0492BE:
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
	bne	loc_0492EB
	inc	OBJ_STATE,x
loc_0492EB:
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
	bne	loc_049329
	lda	#$0031
	ldy	stage_number
	cpy	#$0004
	beq	loc_049325
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0017
	bcc	loc_049322
	cmp	#$0025
	bcc	loc_049329
	cmp	#$0029
	bcs	loc_049329
loc_049322:
	lda	#$005F
loc_049325:
	jsl	f:queue_sound
loc_049329:
	jsr	a:rideable_missile_carry_players
	inc	$30,x
	lda	$32,x
	inc	a
	and	#$0007
	cmp	#$0006
	bne	loc_04933C
	lda	#$0000
loc_04933C:
	sta	$32,x
	and	#$0006
	sta	zp_FC
	lda	stage_frame_odd
	bne	loc_04939A
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
	beq	loc_049365
	lda	#$4804
loc_049365:
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
	beq	loc_04938B
	lda	#$4880
loc_04938B:
	ply
	pha
	lda	a:ptrs_rideable_missile_anim_blocks_2,y
	tay
	pla
	ldx	#$0030
	jsl	f:queue_vram_blocks_at_x
	plx
loc_04939A:
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
	beq	loc_0493FD
	clc
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_X
	adc	#$FF90
	cmp	OBJ_X,x
	bpl	loc_04941A
	inc	OBJ_STATE,x
	rtl
loc_0493FD:
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$FF90
	cmp	OBJ_X,x
	bpl	loc_04941A
	lda	#$0200
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_SAVED_ATTR
	sec
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	sbc	#$0004
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	inc	OBJ_STATE,x
loc_04941A:
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
	bcc	loc_049456
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
loc_049456:
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
	bpl	loc_04949D
	stz	a:bg2_x
	rtl
loc_04949D:
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
	beq	loc_04952B
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$6050
	sta	cgram_upload_addr
loc_04952B:
	lda	OBJ_HP,x
	bpl	loc_04953B
	lda	#$0001
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
loc_04953B:
	jsr	a:stage4_boss_move
	lda	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	beq	loc_0495A1
	inc	a:boss_work_1
	lda	a:boss_work_1
	cmp	#$0070
	bcc	loc_0495A0
	bit	#$0007
	bne	loc_0495A0
	cmp	#$0090
	bcc	loc_049564
	stz	a:boss_work_1
	lda	a:boss_work_2
	eor	#$0002
	sta	a:boss_work_2
loc_049564:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	loc_0495A0
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
loc_0495A0:
	rtl
loc_0495A1:
	lda	stage_frame_counter
	bit	#$003F
	bne	@return
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#OBJT_STAGE4_BOSS_FIREBALL
	sta	a:$0010,y
	lda	OBJ_X,x
	adc	#$0020
	sta	a:$000A,y
	lda	OBJ_Y,x
	adc	#$FFE0
	sta	a:$000E,y
@return:
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
	bcs	loc_0495FC
	lda	rng_lo
	and	#$0003
	adc	#$FFF5
	sta	a:$001A,y
loc_0495FC:
	jsr	a:stage4_boss_move
	rtl

; Object type $6A. Stage 4 boss: the upper and lower pods of stage4_boss (128
; HP each).
update_stage4_boss_pod:
	lda	OBJ_HP,x
	bpl	loc_049633
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
loc_049633:
	lda	a:boss_work_2
	eor	$30,x
	bne	@return
	jsr	a:stage4_boss_pod_fire
@return:
	rtl

; Object type $82. Stage 4 boss: spread shots.
update_stage4_boss_shot:
	lda	OBJ_TOUCHED_BY,x
	bne	loc_049646
	lda	OBJ_HP,x
	bpl	loc_04965A
loc_049646:
	lda	#$0017
	jsl	f:queue_sound
	lda	#$FFF8	; [num]
	sta	OBJ_X_VEL,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
loc_04965A:
	lda	OBJ_STATE,x
	bne	loc_049690
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
loc_049690:
	dec	OBJ_TIMER,x
	bmi	loc_049646
	lda	OBJ_Y_VEL_SUB,x
	bne	loc_04969C
	lda	OBJ_Y_VEL,x
	beq	loc_0496AF
loc_04969C:
	lda	OBJ_Y_VEL,x
	bpl	loc_0496B0
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_0496AF:
	rtl
loc_0496B0:
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
	bpl	loc_0496CC
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_0496CC:
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
	bne	loc_04973E
	inc	OBJ_STATE,x
	sty	$30,x
	bra	loc_04973E

stage4_boss_fireball_state_02:
	ldy	$30,x
	lda	a:$0012,y
	cmp	#$0005
	beq	loc_04972D
	dec	OBJ_STATE,x
	bra	loc_04973E
loc_04972D:
	clc
	lda	a:$000E,y
	adc	#$FFF6
	cmp	OBJ_Y,x
	bcc	loc_04973C
	inc	OBJ_Y,x
	bra	loc_04973E
loc_04973C:
	dec	OBJ_Y,x
loc_04973E:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	lda	stage_frame_mod4
	bne	loc_04976E
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	loc_04976E
	lda	#.loword(anim_05C558)
	jsl	f:make_effect_object
	lda	OBJ_X,x
	adc	#$0004
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
loc_04976E:
	ldy	#$07C0
loc_049771:
	clc
	lda	a:$000A,y
	adc	#$0070
	cmp	OBJ_X,x
	bmi	loc_04979F
	lda	a:$000A,y
	cmp	OBJ_X,x
	bpl	loc_04979F
	sec
	lda	a:$000E,y
	sbc	OBJ_Y,x
	bpl	loc_04978E
	eor	#$FFFF
loc_04978E:
	cmp	#$000A
	bcs	loc_04979F
	lda	#$0006
	sta	a:$0012,y
	lda	#$FFFF	; [num]
	sta	OBJ_HP,x
	rtl
loc_04979F:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_049771
	rtl

; Player slot X (state 1, 3 or 4, above y $E0): x = $10 (player 1) or $30
; (player 2), y = $C3, stops its vertical motion. Called for both players by
; stage4_controller_state_1C after the boss.
stage4_reposition_player:
	lda	OBJ_FLAGS,x
	beq	loc_0497DF
	bmi	loc_0497DF
	lda	OBJ_STATE,x
	cmp	#$0001
	beq	loc_0497C2
	; (not executed in the CDL traces)
	cmp	#$0003
	beq	loc_0497C2
	cmp	#$0004
	beq	loc_0497C2
loc_0497C2:
	lda	OBJ_Y,x
	cmp	#$00E0
	bcs	loc_0497DF
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
loc_0497DF:
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

; Adds the 16.16 speed wram_140C/wram_140E to wram_1404/wram_7E3824:
; wram_7E3824 is the BG3 horizontal scroll of the lower band of the HDMA table
; at $7E:3820 (hdma_preset $0B, set up by stage4_controller_state_16).
stage4_scroll_bg3_lower:
	clc
	lda	a:bg3_x+BG_X_SUB
	adc	a:bg3_x+BG_X_DELTA_SUB
	sta	a:bg3_x+BG_X_SUB
	lda	f:wram_7E3824
	adc	a:bg3_x+BG_X_DELTA
	sta	f:wram_7E3824
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
	bne	loc_0498D3
	lda	$32,x
	cmp	OBJ_X,x
	bcs	loc_0498F7
	lda	OBJ_X_VEL,x
	bpl	loc_0498C2
	cmp	#$FFFE	; [num]
	bcc	loc_0498FE
loc_0498C2:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bra	loc_0498FE
loc_0498D3:
	clc
	lda	$32,x
	adc	#$0008
	cmp	OBJ_X,x
	bcc	loc_0498F7
	lda	OBJ_X_VEL,x
	bmi	loc_0498E6
	cmp	#$0001
	bcs	loc_0498FE
loc_0498E6:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	bra	loc_0498FE
loc_0498F7:
	lda	$30,x
	eor	#$0002
	sta	$30,x
loc_0498FE:
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
	beq	loc_049918
	eor	#$FFFF
loc_049918:
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
	beq	loc_049949
	lda	a:obj_slots+20*OBJ_SIZE+OBJ_FLAGS
	ora	a:obj_slots+21*OBJ_SIZE+OBJ_FLAGS
	bne	loc_04994A
	lda	#$8000	; [num]
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_FLAGS
	lda	#$4011
	sta	OBJ_FLAGS,x
	lda	#$00C8
	sta	$32,x
loc_049949:
	rts
loc_04994A:
	lda	zp_00
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_X
	sec
	lda	#$00B0
	sbc	zp_02
	sta	a:obj_slots+22*OBJ_SIZE+OBJ_Y
	lda	a:obj_slots+20*OBJ_SIZE+OBJ_FLAGS
	beq	loc_04996B
	lda	zp_00
	sta	a:obj_slots+20*OBJ_SIZE+OBJ_X
	sec
	lda	#$0030
	sbc	zp_02
	sta	a:obj_slots+20*OBJ_SIZE+OBJ_Y
loc_04996B:
	lda	a:obj_slots+21*OBJ_SIZE+OBJ_FLAGS
	beq	loc_049949
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
	lda	f:wram_7E3801
	adc	$38,x
	sta	f:wram_7E3801
	sta	f:wram_7E3806
	cmp	#$0200
	bcc	loc_049A05
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
loc_049A05:
	clc
	lda	$3E,x
	adc	#$0C00
	sta	$3E,x
	lda	f:wram_7E3803
	adc	#$0000
	sta	f:wram_7E3803
	sta	f:wram_7E3808
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
	bpl	loc_049AF4
	phx
	ldy	#$0000
	ldx	#$07C0
	lda	$10,x
	beq	loc_049AE2
	iny
	iny
	ldx	#$0840
	lda	$10,x
	beq	loc_049AE2
	iny
	iny
	ldx	#$0880
	lda	$10,x
	bne	loc_049AE9
loc_049AE2:
	lda	#$0073
	sta	$10,x
	sty	$30,x
loc_049AE9:
	plx
	lda	rng_lo
	and	#$003F
	adc	#$0048
	sta	$32,x
loc_049AF4:
	rts

stage4_spawn_hoverbike_rider:
	dec	$32,x
	bpl	loc_049B31
	ldy	#$0400
	jsl	f:find_free_slot_y_down
	bcc	loc_049B31
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
	bne	loc_049B31
	inc	OBJ_STATE,x
loc_049B31:
	rts

; Every 8 frames: stage4_spawn_passing_rider.
stage4_spawn_passing_rider_every_8:
	lda	stage_frame_mod8
	bne	loc_049B73

; Bike section: makes a type $53 (OBJT_PASSIVE_PART, not a target) hover-bike
; rider passing in the background from the left at 7-10 pixels per frame (seen
; in the emulator); stage4_controller_state_01 turns one into a real
; OBJT_HOVERBIKE_RIDER.
stage4_spawn_passing_rider:
	ldy	#$0400
	jsl	f:find_free_slot_y_down
	bcc	loc_049B31
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
loc_049B73:
	rts

scroll_with_airship:
	sec
	lda	OBJ_X,x
	sbc	a:bg1_moved_x
	sta	OBJ_X,x
	cmp	#$0100
	bcc	loc_049B86
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
loc_049B86:
	sec
	lda	OBJ_Y,x
	sbc	a:bg1_moved_y
	sta	OBJ_Y,x
	rts

airship_part_explode:
	lda	#$0030
	jsl	f:queue_sound_throttled
	lda	stage_frame_odd
	bne	loc_049BD4
	dec	OBJ_TIMER,x
	bpl	loc_049BA4
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_049BA4:
	ldy	#$0580
	jsl	f:find_free_slot_y_down
	bcc	loc_049BD4
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
loc_049BD4:
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
	beq	loc_049C1A
	lda	#$0030
	sta	cgram_upload_addr
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
loc_049C1A:
	lda	OBJ_HP,x
	bpl	loc_049C2A
	lda	#$0006
	sta	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	stz	OBJ_HP,x
loc_049C2A:
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
	beq	loc_049C61
	rtl
loc_049C61:
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
	bmi	loc_049C84
	cmp	#$0070
	bcs	loc_049C95
loc_049C84:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	loc_049CAF
loc_049C95:
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_049CA7
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
loc_049CA7:
	lsr	OBJ_Y_VEL,x
	ror	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL_SUB,x
	beq	loc_049CB9
loc_049CAF:
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:sub_04A16E
	rtl
loc_049CB9:
	inc	OBJ_STATE,x
	lda	#$401D
	sta	OBJ_FLAGS,x
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:sub_04A16E
	rtl

winged_alien_state_03:
	lda	OBJ_HP,x
	ldy	difficulty
	cmp	a:data_05ECE8,y
	bcs	loc_049CDA
	lda	#$0004
	sta	OBJ_STATE,x
	stz	$3A,x
loc_049CDA:
	lda	OBJ_X,x
	bmi	loc_049D26
	cmp	#$00D0
	bcc	loc_049D26
	lda	#$0055
	jsl	f:queue_sound
	lda	a:player1_obj+OBJ_FLAGS
	ora	a:player2_obj+OBJ_FLAGS
	and	#$0001
	bne	loc_049CFC
	lda	#$0078
	sta	zp_00
	bra	loc_049D05
loc_049CFC:
	jsl	f:pick_random_player
	lda	a:$000E,y
	sta	zp_00
loc_049D05:
	lda	OBJ_Y,x
	bmi	loc_049D12
	cmp	zp_00
	bcc	loc_049D12
	ldy	#$0002
	bra	loc_049D15
loc_049D12:
	ldy	#$0000
loc_049D15:
	lda	a:data_05ECEE,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:data_05ECF2,y
	sta	OBJ_Y_VEL,x
	lda	#$FFFA	; [num]
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
loc_049D26:
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
	beq	loc_049D4C
	lda	rng_lo
	and	#$0001
	bne	loc_049D4C
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_049D4C:
	lda	OBJ_X_VEL,x
	bmi	loc_049D5E
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_049D70
	and	#$0004
	lsr	a
	lsr	a
	bra	loc_049D6B
loc_049D5E:
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_049D70
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
loc_049D6B:
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
loc_049D70:
	inc	a:obj_slots+22*OBJ_SIZE+$38
	inc	a:obj_slots+22*OBJ_SIZE+$38
	jsr	a:sub_04A16E
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
	bcs	loc_049DC2
	lda	#$FFFD	; [num]
	sta	a:$001E,y
loc_049DC2:
	inc	$3A,x

winged_alien_state_04_step_1:
	lda	OBJ_X,x
	bmi	loc_049DDE
	cmp	#$0048
	bcc	loc_049DDE
	lda	OBJ_X_VEL_SUB,x
	clc
	adc	#$8000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	bmi	loc_049DF8
loc_049DDE:
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
loc_049DF8:
	jsr	a:sub_04A16E
	rtl

winged_alien_state_05:
	jsr	a:winged_alien_run_step
	jsr	a:sub_04A16E
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

sub_049E26:
	ldy	#$0000
	lda	a:obj_slots+22*OBJ_SIZE+$36
	cmp	#$00D0
	bne	loc_049E34
	iny
	bra	loc_049E4D
loc_049E34:
	clc
	adc	#$0004
	sta	a:obj_slots+22*OBJ_SIZE+$36
	and	#$01FF
	clc
	sbc	#$00D0
	cmp	#$0008
	bcs	loc_049E4D
	; (not executed in the CDL traces)
	lda	#$00D0
	sta	a:obj_slots+22*OBJ_SIZE+$36
loc_049E4D:
	lda	a:obj_slots+22*OBJ_SIZE+$38
	cmp	#$01F2
	bne	loc_049E58
	iny
	bra	loc_049E71
loc_049E58:
	sec
	sbc	#$0001
	sta	a:obj_slots+22*OBJ_SIZE+$38
	and	#$01FF
	clc
	sbc	#$01F2
	cmp	#$0002
	bcs	loc_049E71
	lda	#$01F2
	sta	a:obj_slots+22*OBJ_SIZE+$38
loc_049E71:
	cpy	#$0002
	beq	loc_049E78
	clc
	rts
loc_049E78:
	sec
	rts

winged_alien_step_0:
	jsr	a:sub_049E26
	bcc	loc_049E8B
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_TIMER,x
	inc	$3A,x
loc_049E8B:
	jsr	a:sub_04A2B2
	rts

winged_alien_step_1:
	lda	OBJ_X,x
	bmi	loc_049EC9
	cmp	#$0048
	bcc	loc_049EC9
	lda	OBJ_X_VEL_SUB,x
	sec
	sbc	#$4000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	lda	OBJ_Y,x
	bmi	loc_049EC5
	cmp	#$0010
	bcc	loc_049EC1
	lda	OBJ_Y_VEL_SUB,x
	sec
	sbc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	bra	loc_049EC5
loc_049EC1:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
loc_049EC5:
	jsr	a:sub_04A2C5
	rts
loc_049EC9:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	inc	$3A,x
	rts

winged_alien_step_2:
	lda	#$0000
	sta	f:wram_7EE823
	lda	#$0074
	sta	f:wram_7EE827
	lda	OBJ_Y,x
	sta	f:wram_7EE825
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
	jsr	a:sub_04A2D2
	lda	f:wram_7EE823
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
	bne	loc_049F41
	lda	#$0078
	sta	zp_00
	bra	loc_049F4A
loc_049F41:
	jsl	f:pick_random_player
	lda	a:$000E,y
	sta	zp_00
loc_049F4A:
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
	sta	f:wram_7EE823
	lda	OBJ_Y,x
	sta	f:wram_7EE825
	rts

winged_alien_step_7:
	jsr	a:sub_04A2E9
	lda	f:wram_7EE823
	cmp	#$0002
	bcc	@return
	lda	#$401D
	sta	OBJ_FLAGS,x
	stz	hdma_preset
	stz	OBJ_TIMER,x
	inc	$3A,x
	jsr	a:sub_04A2B2
@return:
	rts

winged_alien_step_8:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0008
	bcc	loc_049FC2
	jsl	f:pick_random_player
	lda	OBJ_Y,x
	clc
	adc	#$0032
	cmp	a:$000E,y
	bcs	loc_049FB4
	lda	#$0090
	sta	a:obj_slots+22*OBJ_SIZE+$36
loc_049FB4:
	stz	a:obj_slots+22*OBJ_SIZE+$38
	lda	#$FFFA	; [num]
	sta	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_TIMER,x
	inc	$3A,x
loc_049FC2:
	jsr	a:sub_04A2C5
	rts

winged_alien_step_9:
	lda	OBJ_X,x
	bmi	loc_049FE2
	cmp	#$0040
	bcs	loc_049FE2
	; (not executed in the CDL traces)
	lda	OBJ_X_VEL_SUB,x
	clc
	adc	#$1F40
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	jsr	a:sub_04A2C5
	rts
loc_049FE2:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_TIMER,x
	stz	$3A,x
	jsr	a:sub_04A2B2
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
	lda	a:data_05ECFC,y
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
	bmi	loc_04A047
	cmp	#$0140
	bcs	loc_04A088
loc_04A047:
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
	bcs	loc_04A084
	lda	#$FFFD	; [num]
	sta	a:$001E,y
loc_04A084:
	jsr	a:winged_alien_set_bg2_scroll
	rtl
loc_04A088:
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
loc_04A11F:
	lda	a:data_05ECFC,y
	tax
	lda	#OBJT_WINGED_ALIEN_TAIL_SEGMENT
	sta	$10,x
	lda	#$003C
	sta	$16,x
	stz	$12,x
	cpy	#$0010
	bcs	loc_04A139
	lda	#.loword(metasprite_06C46D)
	bra	loc_04A13C
loc_04A139:
	lda	#.loword(metasprite_06C472)
loc_04A13C:
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
	bcc	loc_04A11F
	plx
	lda	#$008D
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_TYPE
	rts

sub_04A16E:
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
	lda	a:data_05ED20,y
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
	lda	a:data_05ED24,y
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
	bmi	loc_04A230
	lsr	a
	bra	loc_04A232
loc_04A230:
	sec
	ror	a
loc_04A232:
	pha
	lda	f:circle15_x,x
	bmi	loc_04A23C
	lsr	a
	bra	loc_04A23E
loc_04A23C:
	sec
	ror	a
loc_04A23E:
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
	lda	a:data_05ED34,y
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

sub_04A2B2:
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_04A2C4
	and	#$0008
	lsr	a
	lsr	a
	lsr	a
loc_04A2BF:
	sta	$30,x
	jsr	a:winged_alien_queue_tiles
loc_04A2C4:
	rts

sub_04A2C5:
	lda	stage_frame_counter
	bit	#$0001
	bne	loc_04A2C4
	and	#$0002
	lsr	a
	bra	loc_04A2BF

sub_04A2D2:
	lda	f:wram_7EE823
	phx
	asl	a
	tax
	lda	f:tbl_04A2E3,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_04A2E3:
	.addr	sub_04A300
	.addr	sub_04A32A
	.addr	sub_04A349

sub_04A2E9:
	lda	f:wram_7EE823
	phx
	asl	a
	tax
	lda	f:tbl_04A2FA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_04A2FA:
	.addr	sub_04A300
	.addr	sub_04A313
	.addr	sub_04A349

sub_04A300:
	jsr	a:sub_04A34A
	jsr	a:sub_04A374
	lda	#$0001
	sta	f:wram_7EE823
	lda	#$000F
	sta	hdma_preset
	rts

sub_04A313:
	jsr	a:sub_04A374
	lda	f:wram_7EE827
	clc
	adc	#$0004
	sta	f:wram_7EE827
	bmi	loc_04A341
	cmp	#$0075
	bcs	loc_04A341
	rts

sub_04A32A:
	jsr	a:sub_04A374
	lda	f:wram_7EE827
	sec
	sbc	#$0004
	sta	f:wram_7EE827
	bmi	loc_04A341
	cmp	#$0001
	bcc	loc_04A341
	rts
loc_04A341:
	lda	#$0002
	sta	f:wram_7EE823
	rts

sub_04A349:
	; (not executed in the CDL traces)
	rts

sub_04A34A:
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
	sta	f:wram_7EE829
	plx
	rts

sub_04A374:
	jsr	a:sub_04A37A
	jmp	a:loc_04A40A

sub_04A37A:
	lda	f:wram_7EE827
	lsr	a
	sta	zp_00
	lda	f:wram_7EE825
	sec
	sbc	zp_00
	cmp	#$0002
	bmi	loc_04A399
	bcc	loc_04A399
	cmp	#$00F0
	bcc	loc_04A39C
	; (not executed in the CDL traces)
	lda	#$00F0
	bra	loc_04A39C
loc_04A399:
	lda	#$0002
loc_04A39C:
	sta	zp_02
	lsr	a
	pha
	adc	#$0000
	sta	f:wram_7EE82B
	pla
	sta	f:wram_7EE82D
	lda	f:wram_7EE827
	clc
	adc	zp_02
	sta	zp_04
	cmp	#$00F0
	bcc	loc_04A3C4
	lda	#$00F0
	sta	zp_04
	sec
	sbc	zp_02
	bra	loc_04A3D0
loc_04A3C4:
	lda	f:wram_7EE827
	cmp	#$0002
	bcs	loc_04A3D0
	lda	#$0002
loc_04A3D0:
	lsr	a
	pha
	adc	#$0000
	sta	f:wram_7EE82F
	pla
	sta	f:wram_7EE831
	lda	#$00F0
	sec
	sbc	zp_04
	bpl	loc_04A3E9
	; (not executed in the CDL traces)
	lda	#$0000
loc_04A3E9:
	cmp	#$0080
	bcc	loc_04A3FE
	sec
	sbc	#$007F
	sta	f:wram_7EE835
	lda	#$007F
	sta	f:wram_7EE833
	rts
loc_04A3FE:
	sta	f:wram_7EE833
	lda	#$0000
	sta	f:wram_7EE835
	rts
loc_04A40A:
	lda	f:wram_7EE82B
	ora	#$0080
	sta	f:wram_7EE800
	lda	f:wram_7EE82B
	clc
	adc	f:wram_7EE82D
	asl	a
	sta	zp_00
	lda	f:wram_7EE829
	sec
	sbc	zp_00
	sta	f:wram_7EE801
	lda	f:wram_7EE82D
	ora	#$0080
	sta	f:wram_7EE803
	lda	f:wram_7EE82D
	asl	a
	sta	zp_00
	lda	f:wram_7EE829
	sec
	sbc	zp_00
	sta	f:wram_7EE804
	lda	f:wram_7EE82F
	sta	f:wram_7EE806
	lda	f:wram_7EE829
	sta	f:wram_7EE807
	lda	f:wram_7EE831
	sta	f:wram_7EE809
	lda	f:wram_7EE829
	sta	f:wram_7EE80A
	lda	f:wram_7EE833
	ora	#$0080
	sta	f:wram_7EE80C
	lda	f:wram_7EE829
	sta	f:wram_7EE80D
	lda	f:wram_7EE835
	ora	#$0080
	sta	f:wram_7EE80F
	lda	f:wram_7EE833
	asl	a
	clc
	adc	f:wram_7EE829
	sta	f:wram_7EE810
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
	bpl	loc_04A4AB
	brl	loc_04A626
loc_04A4AB:
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
	jsr	a:sub_04A810
	jsr	a:face_boss_place_parts
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	loc_04A4F5
	rtl
loc_04A4F5:
	lda	#$0006
	jsl	f:apply_palette_anim_once
loc_04A4FC:
	lda	#$0044
	jsl	f:queue_sound
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x

face_boss_state_02:
	dec	OBJ_TIMER,x
	bne	loc_04A518
	lda	#$0044
	jsl	f:queue_sound
loc_04A518:
	lda	stage_frame_counter
	lsr	a
	bcs	loc_04A52A
	lda	OBJ_Y,x
	inc	a
	sta	OBJ_Y,x
	cmp	#$0020
	bpl	loc_04A537
	jsr	a:face_boss_place_parts
loc_04A52A:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	rtl
loc_04A537:
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
	beq	loc_04A55E
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	loc_04A586
loc_04A55E:
	dec	OBJ_TIMER,x
	bpl	loc_04A573
	lda	a:obj_slots+8*OBJ_SIZE+$30
	ora	a:obj_slots+9*OBJ_SIZE+$30
	bne	loc_04A56D
	brl	loc_04A5CD
loc_04A56D:
	stz	OBJ_TIMER,x
	stz	$38,x
	bra	loc_04A576
loc_04A573:
	jsr	a:sub_04A6B8
loc_04A576:
	jsr	a:sub_04A6CA
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	lda	#$0002
	sta	a:shake_timer
	rtl
loc_04A586:
	lda	#$0006
	sta	OBJ_STATE,x

face_boss_state_06:
	jsr	a:sub_04A74A
	ldy	difficulty
	lda	stage_frame_counter
	and	a:data_05ED64,y
	bne	loc_04A5AC
	lda	rng_lo
	bit	#$0001
	bne	loc_04A5A6
	ldy	#$0300
	jsr	a:sub_04A9BD
	bra	loc_04A5AC
loc_04A5A6:
	ldy	#$0300
	jsr	a:sub_04A9E5
loc_04A5AC:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:data_05ED6A,y
	bne	loc_04A5BA
	lda	#$0030
	sta	$36,x
loc_04A5BA:
	ldy	#$0300
	jsr	a:face_boss_spit_larva
	jsr	a:sub_04A93B
	jsr	a:sub_04A907
	lda	#$0002
	sta	a:shake_timer
	rtl
loc_04A5CD:
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_state_04:
	lda	stage_frame_counter
	lsr	a
	bcs	loc_04A5E4
	lda	OBJ_Y,x
	dec	a
	sta	OBJ_Y,x
	cmp	#$FFF0	; [num]
	bmi	loc_04A5F4
	jsr	a:face_boss_place_parts
loc_04A5E4:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	jsr	a:sub_04A997
	rtl
loc_04A5F4:
	ldy	#$0700
	jsr	a:sub_04A9A8
	lda	#$0030
	sta	$36,x
	sta	OBJ_TIMER,x
	lda	#$0005
	sta	OBJ_STATE,x

face_boss_state_05:
	dec	OBJ_TIMER,x
	bpl	loc_04A60D
	brl	loc_04A4FC
loc_04A60D:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:sub_04A74A
	ldy	#$0700
	jsr	a:face_boss_spit_larva
	jsr	a:sub_04A93B
	jsr	a:sub_04A907
	jsr	a:sub_04A997
	rtl
loc_04A626:
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	lda	#$8000	; [num]
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_FLAGS
	lda	#$FFFF	; [num]
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_HP
	sta	a:obj_slots+7*OBJ_SIZE+OBJ_HP
	jsr	a:sub_04A74A
	jsr	a:sub_04A907
	lda	#$0300
	sta	OBJ_TIMER,x
	lda	#$0007
	sta	OBJ_STATE,x

face_boss_state_07:
	dec	OBJ_TIMER,x
	bmi	loc_04A681
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
loc_04A681:
	lda	#$0059
	jsl	f:queue_sound
	lda	#$0080
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x

face_boss_state_08:
	lda	OBJ_ANIM_TIMER,x
	beq	loc_04A69D
	jsr	a:sub_04A95D
	dec	OBJ_ANIM_TIMER,x
loc_04A69D:
	dec	OBJ_TIMER,x
	bmi	loc_04A6A2
	rtl
loc_04A6A2:
	lda	#$0003
	sta	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x

face_boss_state_09:
	jsr	a:sub_04A97A
	dec	OBJ_ANIM_TIMER,x
	bne	@return
	lda	#OBJT_BRAIN_BOSS
	sta	OBJ_TYPE,x
	stz	OBJ_STATE,x
@return:
	rtl

sub_04A6B8:
	ldy	difficulty
	lda	rng_lo
	and	a:data_05ED70,y
	cmp	#$0008
	bcc	loc_04A6C7
	lda	#$0000
loc_04A6C7:
	sta	$38,x
	rts

sub_04A6CA:
	jsr	a:sub_04A6D0
	jmp	a:loc_04A70D

sub_04A6D0:
	lda	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	loc_04A70C
	lda	a:obj_slots+8*OBJ_SIZE+$30
	bne	loc_04A70C
	lda	a:obj_slots+9*OBJ_SIZE+$34
	bne	loc_04A70C
	lda	$38,x
	bit	#$0001
	beq	loc_04A70C
	bit	#$0004
	beq	loc_04A700
	lda	a:obj_slots+9*OBJ_SIZE+$30
	bne	loc_04A70C
	lda	#$0002
	sta	a:obj_slots+8*OBJ_SIZE+$30
	stz	a:obj_slots+8*OBJ_SIZE+$32
	sta	a:obj_slots+8*OBJ_SIZE+$34
	rts
loc_04A700:
	lda	#$0002
	sta	a:obj_slots+8*OBJ_SIZE+$30
	stz	a:obj_slots+8*OBJ_SIZE+$32
	stz	a:obj_slots+8*OBJ_SIZE+$34
loc_04A70C:
	rts
loc_04A70D:
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	bne	loc_04A749
	lda	a:obj_slots+9*OBJ_SIZE+$30
	bne	loc_04A749
	lda	a:obj_slots+8*OBJ_SIZE+$34
	bne	loc_04A749
	lda	$38,x
	bit	#$0002
	beq	loc_04A749
	bit	#$0004
	beq	loc_04A73D
	lda	a:obj_slots+8*OBJ_SIZE+$30
	bne	loc_04A749
	lda	#$0002
	sta	a:obj_slots+9*OBJ_SIZE+$30
	sta	a:obj_slots+9*OBJ_SIZE+$32
	sta	a:obj_slots+9*OBJ_SIZE+$34
	rts
loc_04A73D:
	lda	#$0002
	sta	a:obj_slots+9*OBJ_SIZE+$30
	sta	a:obj_slots+9*OBJ_SIZE+$32
	stz	a:obj_slots+9*OBJ_SIZE+$34
loc_04A749:
	rts

sub_04A74A:
	jsr	a:sub_04A751
	jsr	a:sub_04A77A
	rts

sub_04A751:
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_TYPE
	cmp	#$0053
	bne	loc_04A779
	lda	a:obj_slots+6*OBJ_SIZE+OBJ_HP
	bpl	loc_04A769
	lda	#$8006	; [num]
	sta	$30,x
	ldy	#$0380
	jmp	a:loc_04A7B3
loc_04A769:
	ldy	#$0200
	lda	a:p1_lives
	bne	loc_04A774
	; (not executed in the CDL traces)
	ldy	#$0240
loc_04A774:
	jsr	a:sub_04A7A3
	sta	$30,x
loc_04A779:
	rts

sub_04A77A:
	lda	a:obj_slots+7*OBJ_SIZE+OBJ_TYPE
	cmp	#$0053
	bne	loc_04A7A2
	lda	a:obj_slots+7*OBJ_SIZE+OBJ_HP
	bpl	loc_04A792
	lda	#$8006	; [num]
	sta	$32,x
	ldy	#$03C0
	jmp	a:loc_04A7B3
loc_04A792:
	ldy	#$0240
	lda	a:p2_lives
	bne	loc_04A79D
	ldy	#$0200
loc_04A79D:
	jsr	a:sub_04A7A3
	sta	$32,x
loc_04A7A2:
	rts

sub_04A7A3:
	lda	a:$1312,y
	asl	a
	asl	a
	asl	a
	asl	a
	xba
	and	#$000E
	tay
	lda	a:data_05ED76,y
	rts
loc_04A7B3:
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
	beq	loc_04A7E9
	cmp	#$0020
	bne	loc_04A7DD
	jsr	a:spawn_face_boss_larva
loc_04A7DD:
	ldy	#$8000	; [num]
	dec	$36,x
	beq	loc_04A7E7
	ldy	#$8002	; [num]
loc_04A7E7:
	sty	$34,x
loc_04A7E9:
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

sub_04A810:
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
	lda	a:data_05ED86,y
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
	lda	a:data_05ED86,y
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

sub_04A907:
	jsr	a:face_boss_queue_tiles
	jmp	a:loc_04A924

face_boss_queue_tiles:
	lda	$30,x
	bpl	@return
	and	#$0006
	sta	$30,x
	tay
	lda	a:data_05ED8C,y
	sta	zp_00
	lda	#$4C8C
	jsl	f:queue_vram_block
@return:
	rts
loc_04A924:
	lda	$32,x
	bpl	@return
	and	#$0006
	sta	$32,x
	tay
	lda	a:data_05ED94,y
	sta	zp_00
	lda	#$4C90
	jsl	f:queue_vram_block
@return:
	rts

sub_04A93B:
	lda	$34,x
	bpl	@return
	and	#$0002
	sta	$34,x
	tay
	lda	a:data_05ED9C,y
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

sub_04A95D:
	lda	OBJ_ANIM_TIMER,x
	asl	a
	tay
	lda	a:data_05EDB6,y
	pha
	lda	#$0004
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	a:data_05EDAE,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

sub_04A97A:
	lda	OBJ_ANIM_TIMER,x
	asl	a
	tay
	lda	a:data_05EDDC,y
	pha
	lda	#$0008
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	a:data_05EDD6,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

sub_04A997:
	lda	stage_frame_counter
	bit	#$001F
	bne	@return
	lda	#$0010
	sta	a:obj_slots+8*OBJ_SIZE+$3A
	sta	a:obj_slots+9*OBJ_SIZE+$3A
@return:
	rts

sub_04A9A8:
	lda	a:obj_slots+8*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	beq	loc_04A9B2
	bra	sub_04A9BD
loc_04A9B2:
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_TYPE
	cmp	#$0075
	beq	@return
	; (not executed in the CDL traces)
	bra	sub_04A9E5
@return:
	rts

sub_04A9BD:
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0024
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

sub_04A9E5:
	jsl	f:find_free_slot_from_y
	bcs	@return
	lda	#$0024
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
	bpl	loc_04AA24
	stz	OBJ_HP,x
	lda	#$0008
	sta	OBJ_STATE,x
loc_04AA24:
	lda	OBJ_SAVED_ATTR,x
	beq	loc_04AA32
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
loc_04AA32:
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
	cmp	a:data_05EE28,y
	bcc	@return
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

floor_mouth_state_03:
	lda	#$0000
	jsr	a:sub_04ABA3
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_02:
	lda	OBJ_TIMER,x
	and	#$0007
	bne	loc_04AAB2
	lda	OBJ_TIMER,x
	and	#$0008
	bne	loc_04AAAC
	lda	#$0000
	bra	loc_04AAAF
loc_04AAAC:
	lda	#$0001
loc_04AAAF:
	jsr	a:sub_04ABA3
loc_04AAB2:
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
	jsr	a:sub_04ABA3
	inc	OBJ_STATE,x
	rtl

floor_mouth_state_07:
	lda	#$0001
	sta	OBJ_STATE,x
	rtl

floor_mouth_state_08:
	lda	#$0002
	jsr	a:sub_04ABA3
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

sub_04AB6A:
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

sub_04ABA3:
	asl	a
	tay
	lda	#$0001
	sta	zp_02
	lda	#$0008
	sta	zp_08
	lda	a:data_05EE1C,y
	tay
	jsr	a:sub_04AB6A
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; Object type $62. Stage 6: bug released by floor_mouth. HP by difficulty:
; 1/1/2 (floor_mouth_bug_hp).
update_floor_mouth_bug:
	lda	OBJ_HP,x
	bpl	loc_04ABC6
	lda	#$0007
	sta	OBJ_STATE,x
loc_04ABC6:
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
	lda	a:data_05EE38,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:data_05EE3E,y
	sta	OBJ_X_VEL,x
	lda	a:data_05EE44,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:data_05EE4A,y
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
	bcc	loc_04AC4E
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
loc_04AC4E:
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
	bcc	loc_04ACBA
	lda	#$0007
	bra	loc_04ACBD
loc_04ACBA:
	lda	#$0002
loc_04ACBD:
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
	bcc	loc_04ACF8
	brl	loc_04AD6B
loc_04ACF8:
	lda	OBJ_HP,x
	bpl	loc_04ACFF
	brl	loc_04AD6B
loc_04ACFF:
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
	lda	a:data_05EE64,y
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
	bmi	loc_04AD5C
	lda	#$0010
	jml	f:set_velocity_from_angle
loc_04AD5C:
	lda	#$0002
	sta	OBJ_STATE,x

larva_state_02:
	jsr	a:larva_turn_toward_player
	lda	#$0010
	jml	f:set_velocity_from_angle
loc_04AD6B:
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
	bmi	loc_04ADA7
	inc	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts
loc_04ADA7:
	.a8
	dec	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts

; Y = the player the larva chases: the one in play, or by the parity of the
; slot when both are.
larva_pick_player:
	lda	a:p2_lives
	bne	loc_04ADB5
loc_04ADB1:
	ldy	#$0200
	rts
loc_04ADB5:
	lda	a:p1_lives
	bne	loc_04ADBE
loc_04ADBA:
	ldy	#$0240
	rts
loc_04ADBE:
	txa
	bit	#$0040
	beq	loc_04ADB1
	bra	loc_04ADBA

; Object type $21. Stage 6: larva spat by face_boss's central mouth; crawls
; toward a player. HP by difficulty: 2/4/8 (face_boss_larva_hp).
update_face_boss_larva:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	loc_04ADCE
	brl	loc_04AD6B
loc_04ADCE:
	lda	OBJ_HP,x
	bpl	loc_04ADD5
	brl	loc_04AD6B
loc_04ADD5:
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
loc_04AE0B:
	lda	#.loword(anim_05EE68)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0100
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x

face_boss_larva_state_01:
	dec	OBJ_TIMER,x
	bmi	loc_04AE2A
	jsr	a:larva_turn_toward_player
	lda	#$0010
	jml	f:set_velocity_from_angle
loc_04AE2A:
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
	bmi	loc_04AE0B
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
	bmi	loc_04AE7E
	lda	OBJ_ANGLE,x
	clc
	adc	zp_00
	sta	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts
loc_04AE7E:
	.a8
	lda	OBJ_ANGLE,x
	sec
	sbc	zp_00
	sta	OBJ_ANGLE,x
	rep	#$20
	.a16
	rts

; Object type $68. Stage 6, heart_boss: small creatures around the heart's
; ceiling pods (not identified exactly). HP by difficulty: 0/2/4
; (data_05EEA0).
update_enemy_type_68:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	loc_04AE93
	brl	loc_04AFE7
loc_04AE93:
	lda	OBJ_HP,x
	bpl	loc_04AE9A
	brl	loc_04AFE7
loc_04AE9A:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_enemy_type_68_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_enemy_type_68_states:
	.addr	enemy_type_68_state_00
	.addr	enemy_type_68_state_01
	.addr	enemy_type_68_state_02
	.addr	enemy_type_68_state_03
	.addr	enemy_type_68_state_04
	.addr	enemy_type_68_state_05

enemy_type_68_state_00:
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$3400
	sta	OBJ_ATTR,x
	ldy	difficulty
	lda	a:data_05EEA0,y
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
	lda	a:data_05EEA6,y
	sta	OBJ_Y_VEL,x
	lda	a:data_05EEAA,y
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0000
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_FACING,x
	stz	OBJ_X_SUB,x
	stz	OBJ_Y_SUB,x
	ldy	$30,x
	lda	a:data_05EEAE,y
	sta	OBJ_SPRITE,x
	stz	OBJ_ANIM,x
	lda	#$0001
	sta	OBJ_STATE,x

enemy_type_68_state_01:
	ldy	$30,x
	jsr	a:sub_04AF1C
	bcs	loc_04AF2A
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	a:data_05EEB6,y
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	a:data_05EEB2,y
	sta	OBJ_Y_VEL,x
	rtl

sub_04AF1C:
	bne	loc_04AF24
	lda	OBJ_Y,x
	cmp	#$00B8
	rts
loc_04AF24:
	lda	#$0048
	cmp	OBJ_Y,x
	rts
loc_04AF2A:
	ldy	$30,x
	lda	a:data_05EEBA,y
	sta	OBJ_Y,x
	stz	OBJ_Y_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:data_05EEBE,y
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x

enemy_type_68_state_02:
	jsr	a:sub_04AF5C
	bcc	loc_04AF5B
	lda	$30,x
	bne	loc_04AF59
	brl	loc_04AFBC
loc_04AF59:
	bra	loc_04AF8F
loc_04AF5B:
	rtl

sub_04AF5C:
	lda	a:p1_lives
	beq	loc_04AF70
	lda	a:player1_obj+PLAYER_CENTER_X
	clc
	adc	#$0020
	sec
	sbc	OBJ_X,x
	cmp	#$0002
	bcc	loc_04AF86
loc_04AF70:
	lda	a:p2_lives
	beq	loc_04AF84
	lda	a:player2_obj+PLAYER_CENTER_X
	clc
	adc	#$0020
	sec
	sbc	OBJ_X,x
	cmp	#$0002
	bcc	loc_04AF86
loc_04AF84:
	clc
	rts
loc_04AF86:
	lda	rng_lo
	bit	#$0001
	bne	loc_04AF84
	sec
	rts
loc_04AF8F:
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

enemy_type_68_state_03:
	lda	OBJ_Y,x
	cmp	#$00B8
	bcc	@return
	brl	loc_04AF2A
@return:
	rtl
loc_04AFBC:
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

enemy_type_68_state_04:
	lda	#$0048
	cmp	OBJ_Y,x
	bcc	@return
	brl	loc_04AF2A
@return:
	rtl
loc_04AFE7:
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

enemy_type_68_state_05:
	; (not executed in the CDL traces)
	rtl

; Object type $58. Stage 6: the giant heart with tendrils (second boss of the
; stage). HP by difficulty: 128/256/384 (heart_boss_hp).
update_heart_boss:
	lda	#$0060
	jsl	f:boss_flash_palette
	lda	a:boss_hit_sound_timer
	beq	loc_04B014
	dec	a:boss_hit_sound_timer
loc_04B014:
	lda	OBJ_SAVED_ATTR,x
	beq	loc_04B02A
	lda	a:boss_hit_sound_timer
	bne	loc_04B02A
	lda	#$003C
	jsl	f:queue_sound
	lda	#$0004
	sta	a:boss_hit_sound_timer
loc_04B02A:
	lda	OBJ_HP,x
	bpl	loc_04B031
	brl	loc_04B08A
loc_04B031:
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
	jsr	a:sub_04B17C
	lda	#$0001
	sta	a:stage_checkpoint
	jsr	a:spawn_heart_boss_bug
	lda	#$0009
	sta	a:bg2_scroll_mode
	inc	OBJ_STATE,x

heart_boss_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	beq	loc_04B084
	jsr	a:sub_04B14B
	rtl
loc_04B084:
	inc	OBJ_STATE,x

heart_boss_state_02:
	jsr	a:sub_04B14B
	rtl
loc_04B08A:
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
	bmi	loc_04B0D8
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
loc_04B0D8:
	lda	#$0003
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

heart_boss_state_04:
	jsr	a:sub_04B12E
	dec	OBJ_TIMER,x
	beq	loc_04B0E7
	rtl
loc_04B0E7:
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
	bmi	loc_04B10C
	bne	@return
	lda	#$0083
	jsl	f:queue_sound
@return:
	rtl
loc_04B10C:
	phx
	ldx	#.loword(song_set_05F497)
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

sub_04B12E:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	OBJ_TIMER,x
	asl	a
	tay
	lda	a:data_05EF04,y
	pha
	lda	a:data_05EEFE,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

sub_04B14B:
	lda	OBJ_ANIM_TIMER,x
	inc	OBJ_ANIM_TIMER,x
	bit	#$0007
	bne	loc_04B17B
	ldy	zp_B6
	cpy	#$0010
	bcc	loc_04B15E
	; (not executed in the CDL traces)
	dec	OBJ_ANIM_TIMER,x
	rts
loc_04B15E:
	lsr	a
	lsr	a
	and	#$0002
	tay
	lda	a:data_05EF3C,y
	tay
	lda	#$0003
	sta	zp_02
	lda	#$0030
	sta	zp_08
	lda	#$4D90
	phx
	jsl	f:queue_vram_blocks
	plx
loc_04B17B:
	rts

sub_04B17C:
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
loc_04B1C7:
	ldy	#$03C0
	jsl	f:find_free_slot_from_y
	bcs	loc_04B1EE
	lda	#OBJT_HEART_BOSS_BUG
	sta	a:$0010,y
	lda	a:data_05EF56,x
	sta	a:$000A,y
	lda	a:data_05EF5E,x
	sta	a:$000E,y
	lda	a:data_05EF66,x
	sta	a:$0030,y
	lda	a:data_05EF6E,x
	sta	a:$0032,y
loc_04B1EE:
	dex
	dex
	bne	loc_04B1C7
	plx
	rts

; Object type $67. Stage 6, heart_boss: crawling bugs. HP by difficulty:
; 32/64/128 (heart_boss_bug_hp).
update_heart_boss_bug:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	cmp	#$0003
	bcc	loc_04B1FF
	brl	loc_04B283
loc_04B1FF:
	lda	OBJ_HP,x
	bpl	loc_04B206
	brl	loc_04B283
loc_04B206:
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
loc_04B23D:
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
	lda	a:data_05EF7E,y
	sta	OBJ_TIMER,x
	lda	#$0001
	sta	OBJ_STATE,x

heart_boss_bug_state_01:
	dec	OBJ_TIMER,x
	bmi	loc_04B260
	rtl
loc_04B260:
	ldy	$30,x
	lda	a:data_05EF96,y
	sta	$34,x
	stz	$36,x
	lda	#$0030
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

heart_boss_bug_state_02:
	jsl	f:sub_04B2E7
	dec	OBJ_TIMER,x
	bmi	loc_04B23D
	lda	OBJ_TIMER,x
	cmp	#$0020
	bne	@return
	jsr	a:sub_04B2C1
@return:
	rtl
loc_04B283:
	lda	#$003B
	jsl	f:queue_sound
	lda	#$0003
	sta	OBJ_STATE,x

heart_boss_bug_state_03:
	stz	OBJ_HP,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	ldy	$30,x
	lda	a:data_05EFC6,y
	jsl	f:sub_04B32B
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

sub_04B2C1:
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
	adc	a:data_05EFCA,y
	ply
	sta	a:$000E,y
@return:
	rts

sub_04B2E7:
	ldy	$34,x
	beq	loc_04B32A
	lda	$36,x
	bne	loc_04B300
	lda	zp_B6
	cmp	#$0040
	bcs	loc_04B32A
	lda	a:$0000,y
	sta	$36,x
	lda	a:$0002,y
	bra	sub_04B32B
loc_04B300:
	dec	$36,x
	bne	loc_04B32A
	lda	zp_B6
	cmp	#$0040
	bcc	loc_04B30E
	; (not executed in the CDL traces)
	inc	$36,x
	rtl
loc_04B30E:
	iny
	iny
	iny
	iny
	lda	a:$0000,y
	beq	loc_04B326
	bpl	loc_04B31D
	; (not executed in the CDL traces)
	tay
	lda	a:$0000,y
loc_04B31D:
	sty	$34,x
	sta	$36,x
	lda	a:$0002,y
	bra	sub_04B32B
loc_04B326:
	sta	$34,x
	sta	$36,x
loc_04B32A:
	rtl

sub_04B32B:
	sta	zp_00
	lda	$32,x
	jml	f:queue_vram_block

; Object type $5B. Stage 6: the giant worm that bursts out of the wall at the
; start of the stage. HP by difficulty: 64/128/256 (wall_worm_hp).
update_wall_worm:
	lda	OBJ_HP,x
	bpl	loc_04B33A
	brl	loc_04B383
loc_04B33A:
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
	beq	loc_04B369
loc_04B368:
	rtl
loc_04B369:
	jsr	a:sub_04B486
	bcs	loc_04B368
	inc	OBJ_STATE,x

wall_worm_state_02:
	jsr	a:wall_worm_flash_palette
	jsr	a:sub_04B3EF
	jsr	a:sub_04B434
	jsr	a:spawn_wall_worm_larva
	jsr	a:sub_04B403
	jsr	a:sub_04B447
	rtl
loc_04B383:
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
	bmi	loc_04B3D5
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
loc_04B3D5:
	lda	#$0004
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_STATE,x

wall_worm_state_04:
	jsr	a:sub_04B469
	dec	OBJ_TIMER,x
	bne	loc_04B368
	stz	a:bg1_scroll_mode
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

sub_04B3EF:
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

sub_04B403:
	lda	$34,x
	bpl	@return
	and	#$0002
	sta	$34,x
	tay
	lda	a:data_05EFE8,y
	sta	OBJ_FLAGS,x
	lda	a:data_05EFEC,y
	sta	OBJ_HITBOX_H,x
	lda	a:data_05EFF0,y
	sta	OBJ_Y,x
	lda	a:data_05EFD4,y
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

sub_04B434:
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

sub_04B447:
	lda	$36,x
	bpl	@return
	and	#$0002
	sta	$36,x
	tay
	lda	a:data_05EFF4,y
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

sub_04B469:
	lda	#$0003
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	OBJ_TIMER,x
	asl	a
	tay
	lda	a:data_05F002,y
	pha
	lda	a:data_05EFFA,y
	ply
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

sub_04B486:
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
	jsr	a:sub_04BDC6
	ldy	#$0840
	lda	a:$0006,y
	bpl	loc_04B539
	lda	#$0026
	sta	OBJ_STATE,x
loc_04B539:
	ldy	#$0840
	lda	a:$0026,y
	beq	loc_04B552
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0020
	sta	cgram_upload_addr
	lda	#$000F
	jsl	f:queue_sound
loc_04B552:
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
	lda	a:data_05F024,y
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
loc_04B674:
	jsr	a:sub_04BBBD
	stz	zp_0C
	jsl	f:sub_04BE03
	phx
	ldx	#$0840
	stz	zp_0C
	jsl	f:sub_04BE03
	ldx	#$0800
	stz	zp_0C
	jsl	f:sub_04BE03
	ldx	#$0880
	stz	zp_0C
	jsl	f:sub_04BE03
	plx
	jsr	a:cave_beast_set_bg2_scroll
	rtl

cave_beast_state_03:
	lda	OBJ_TIMER,x
	bit	#$003F
	bne	loc_04B6AC
	lda	#$0053
	jsl	f:queue_sound
loc_04B6AC:
	dec	OBJ_Y,x
	lda	OBJ_Y,x
	cmp	#$00B9
	bcs	loc_04B6BC
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674
loc_04B6BC:
	lda	#$0003
	sta	a:shake_timer
	jsl	f:find_free_slot_y
	bcs	loc_04B6F1
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
loc_04B6F1:
	inc	OBJ_TIMER,x
	jmp	a:loc_04B674
loc_04B6F6:
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
loc_04B6FB:
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$000A
	jsr	a:sub_04BC10
	inc	OBJ_STATE,x
	rtl
loc_04B710:
	stz	OBJ_X_VEL,x
	bra	loc_04B6FB

cave_beast_state_06:
	lda	OBJ_Y_VEL,x
	bmi	loc_04B72F
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_04B72F
	bit	#$0004
	beq	loc_04B729
	lda	#$0009
	bra	loc_04B72C
loc_04B729:
	lda	#$000A
loc_04B72C:
	jsr	a:sub_04BC10
loc_04B72F:
	lda	OBJ_X,x
	cmp	#$002D
	bmi	loc_04B740
	cmp	#$00AD
	bcc	loc_04B749
	; (not executed in the CDL traces)
	lda	#$00AD
	bra	loc_04B743
loc_04B740:
	lda	#$002D
loc_04B743:
	sta	OBJ_X,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
loc_04B749:
	stz	zp_00
loc_04B74B:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F02C,y
	sta	zp_02
	lda	OBJ_Y_VEL,x
	bmi	loc_04B7B2
	ldy	zp_02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	loc_04B77A
	ldy	zp_02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0010
	bcc	loc_04B7A7
loc_04B77A:
	ldy	#$0800
	lda	a:$000E,y
	cmp	#$0098
	bcc	loc_04B7B2
	ldy	zp_02
	lda	a:$000E,y
	ldy	#$0800
	sec
	sbc	a:$000E,y
	cmp	#$0020
	bcs	loc_04B7B2
	ldy	zp_02
	lda	a:$000A,y
	ldy	#$0800
	sec
	sbc	a:$000A,y
	cmp	#$0080
	bcs	loc_04B7B2
loc_04B7A7:
	ldy	zp_02
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
loc_04B7B2:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	loc_04B74B
	lda	OBJ_Y,x
	cmp	#$00B8
	bcc	loc_04B7DD
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
	jmp	a:loc_04B7EC
loc_04B7DD:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1400
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_04B7EC:
	jmp	a:loc_04B674

cave_beast_state_07:
	lda	#$0009
	jsr	a:sub_04BC10
	lda	#$0003
	sta	a:shake_timer
	stz	$30,x
	stz	OBJ_TIMER,x
	lda	#$0056
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	jmp	a:loc_04B7EC

cave_beast_state_08:
	lda	a:shake_timer
	bne	loc_04B816
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_04B816:
	jmp	a:loc_04B7EC

cave_beast_state_09:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	OBJ_X,x
	bcc	loc_04B839

cave_beast_state_0D:
	stz	$3A,x
	lda	#$4000
loc_04B829:
	sta	$38,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	inc	OBJ_STATE,x
	lda	#$0054
	jsl	f:queue_sound
	rtl
loc_04B839:
	lda	#$FFFF	; [num]
	sta	$3A,x
	lda	#$C000	; [num]
	bra	loc_04B829

cave_beast_state_0A:
	lda	$3A,x
	bmi	loc_04B855
	lda	OBJ_X,x
	cmp	#$00AD
	bcc	loc_04B87F
	lda	#$00AD
	sta	OBJ_X,x
	bra	loc_04B861
loc_04B855:
	lda	OBJ_X,x
	cmp	#$002D
	bpl	loc_04B87F
	lda	#$002D
	sta	OBJ_X,x
loc_04B861:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$00B8
	sta	OBJ_Y,x
	lda	#$0000
	sta	a:shake_continuous
	lda	#$0007
	jsr	a:sub_04BC10
	inc	OBJ_STATE,x
	jmp	a:loc_04B674
loc_04B87F:
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
	bpl	loc_04B89A
	eor	#$FFFF
	inc	a
loc_04B89A:
	cmp	#$0004
	bcs	loc_04B8A7
	lda	zp_00
	sta	OBJ_X_VEL_SUB,x
	lda	zp_02
	sta	OBJ_X_VEL,x
loc_04B8A7:
	jsl	f:find_free_slot_y
	bcs	loc_04B8D6
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
loc_04B8D6:
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_04B8ED
	bit	#$0004
	beq	loc_04B8E7
	lda	#$0007
	bra	loc_04B8EA
loc_04B8E7:
	lda	#$0008
loc_04B8EA:
	jsr	a:sub_04BC10
loc_04B8ED:
	lda	#$0001
	sta	a:shake_continuous
	jmp	a:loc_04B674

cave_beast_state_11:
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

cave_beast_state_12:
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

cave_beast_state_13:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	loc_04B934
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F030,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	loc_04B934
	ldy	#$0840
	lda	a:$0016,y
	and	#$FFDF
	sta	a:$0016,y
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
loc_04B934:
	jmp	a:loc_04B674

cave_beast_state_14:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	loc_04B934
	jsl	f:find_free_slot_y
	bcs	loc_04B962
	lda	#$0070
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0006,y
	lda	OBJ_X,x
	adc	#$0014
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
loc_04B962:
	inc	$30,x
	ldy	difficulty
	lda	a:data_05F034,y
	cmp	$30,x
	bcs	loc_04B973
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
loc_04B973:
	jmp	a:loc_04B674

cave_beast_state_15:
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

cave_beast_state_17:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	loc_04B9A8
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F03C,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0002
	bcc	loc_04B934
	lda	#$0014
	jsl	f:queue_sound
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
loc_04B9A8:
	jmp	a:loc_04B674

cave_beast_state_18:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0001
	bne	loc_04B9E4
	lda	$30,x
	bne	loc_04B9E7
	jsl	f:find_free_slot_y
	bcs	loc_04BA0A
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
loc_04B9E4:
	jmp	a:loc_04B674
loc_04B9E7:
	jsl	f:find_free_slot_y
	bcs	loc_04BA0A
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
	bcc	loc_04B9E4
loc_04BA0A:
	stz	OBJ_TIMER,x
	stz	$30,x
	stz	$32,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

cave_beast_state_19:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	and	#$0007
	bne	loc_04BA43
	lda	$30,x
	asl	a
	tay
	lda	a:data_05F040,y
	jsr	a:sub_04BC10
	inc	$30,x
	lda	$30,x
	cmp	#$0004
	bcc	loc_04BA43
	ldy	#$0840
	lda	a:$0016,y
	ora	#$0020
	sta	a:$0016,y
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
loc_04BA43:
	jmp	a:loc_04B674

cave_beast_state_1B:
	ldy	#$0840
	lda	a:$0006,y
	cmp	#$0080
	bcs	loc_04BA55
	inc	OBJ_STATE,x
	bra	loc_04BA5A
loc_04BA55:
	lda	#$0005
	sta	OBJ_STATE,x
loc_04BA5A:
	stz	OBJ_TIMER,x
	stz	$30,x
	jmp	a:loc_04B674

cave_beast_state_1C:
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$0001
	sta	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

cave_beast_state_1D:
	lda	OBJ_TIMER,x
	bit	#$003F
	bne	loc_04BA83
	lda	#$0053
	jsl	f:queue_sound
loc_04BA83:
	lda	OBJ_Y,x
	cmp	#$0140
	bcc	loc_04BA95
	stz	OBJ_Y_VEL,x
	stz	OBJ_TIMER,x
	stz	$30,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674
loc_04BA95:
	jmp	a:loc_04B6BC

cave_beast_state_1E:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	#$0040
	bcc	loc_04BAAB
	cmp	#$00A0
	bcs	loc_04BAB0
	bcc	loc_04BAB5
loc_04BAAB:
	lda	#$0040
	bra	loc_04BAB5
loc_04BAB0:
	lda	#$00A0
	bra	loc_04BAB5
loc_04BAB5:
	sta	OBJ_X,x
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

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
	jmp	a:loc_04B674

cave_beast_state_20:
	lda	OBJ_X,x
	cmp	#$0080
	bcc	loc_04BAE3
	jmp	a:loc_04B6F6
loc_04BAE3:
	jmp	a:loc_04B710

cave_beast_state_24:
	lda	#$0005
	sta	OBJ_STATE,x
	stz	OBJ_TIMER,x
	stz	$30,x
	jmp	a:loc_04B674

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
	jsr	a:sub_04BC10
	inc	OBJ_STATE,x
	jmp	a:loc_04B674

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
	bcs	loc_04BB59
	lda	#$FFFD	; [num]
	sta	a:$001E,y
loc_04BB59:
	lda	OBJ_Y_VEL,x
	bmi	loc_04BB62
	cmp	#$0001
	bcs	loc_04BB6E
loc_04BB62:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	bcc	loc_04BB6E
	inc	OBJ_Y_VEL,x
loc_04BB6E:
	lda	OBJ_Y,x
	cmp	#$0140
	bcs	loc_04BB78
	jmp	a:loc_04B6BC
loc_04BB78:
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
	bcc	loc_04BBAA
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_04BBAA:
	jmp	a:loc_04B674

; (no caller found; decoded because it follows the end of a routine)
sub_04BBAD:
	; (not executed in the CDL traces)
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0078
	bcc	loc_04BBBA
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_04BBBA:
	jmp	a:loc_04B674

sub_04BBBD:
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

sub_04BC10:
	asl	a
	tay
	lda	a:data_05F048,y
	sta	zp_02
	lda	a:data_05F05E,y
	sta	zp_08
	lda	a:data_05F074,y
	pha
	lda	a:data_05F08A,y
	tay
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_04BC2C:
	; (not executed in the CDL traces)
	clc
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_04BC2E:
	; (not executed in the CDL traces)
	sec
	rts

; Object type $66. Stage 6, dark cave: the rocks that pile up on the floor (up
; to 18).
update_cave_rock:
	lda	OBJ_STATE,x
	bne	loc_04BC6F
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
loc_04BC6F:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00F0
	bcc	loc_04BC7E
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04BC7E:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $70. Stage 6, cave_beast: small embers flying around the beast
; (not identified exactly).
update_enemy_type_70:
	lda	OBJ_STATE,x
	bne	loc_04BCD7
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
loc_04BCD7:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$012C
	bcc	loc_04BCE6
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04BCE6:
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
	bmi	loc_04BCFE
	cmp	#$0006
	bcs	loc_04BD0D
loc_04BCFE:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_04BD0D:
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
	bne	loc_04BD59
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
loc_04BD59:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$012C
	bcc	loc_04BD68
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04BD68:
	lda	stage_frame_counter
	and	#$0003
	asl	a
	tay
	lda	a:data_05F0C6,y
	sta	OBJ_SPRITE,x
	rtl

; Object type $72. Stage 6, cave_beast: segments of the beast's beam.
update_cave_beast_beam:
	lda	OBJ_STATE,x
	bne	loc_04BD59
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

sub_04BDC6:
	stz	zp_00
loc_04BDC8:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F02C,y
	tay
	lda	a:$0016,y
	beq	loc_04BDF9
	lda	a:$000E,y
	cmp	#$0056
	bcc	loc_04BDEA
	cmp	#$00B9
	bcc	loc_04BDF9
	; (not executed in the CDL traces)
	lda	#$00B8
	sta	a:$000E,y
	bra	loc_04BDF9
loc_04BDEA:
	lda	#$0057
	sta	a:$000E,y
	lda	a:$003C,y
	ora	#$0004
	sta	a:$003C,y
loc_04BDF9:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	loc_04BDC8
	rts

sub_04BE03:
	ldy	#$0200
	lda	a:$0016,y
	beq	loc_04BE13
	bmi	loc_04BE13
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_04BE13:
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
	bpl	loc_04BE2B
	brl	loc_04BFA2
loc_04BE2B:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	loc_04BE33
	; (not executed in the CDL traces)
	brl	loc_04BFA2
loc_04BE33:
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
	bcs	loc_04BE80
	rtl
loc_04BE80:
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
	adc	a:data_05F0E8,y
	sta	OBJ_X,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0034
	sta	OBJ_Y,x
	lda	$30,x
	beq	loc_04BEB5
	jsr	a:sub_04C137
	bcc	loc_04BED0
loc_04BEB5:
	ldy	#.loword(metasprite_06C4BC)
	lda	$3A,x
	dec	a
	bpl	loc_04BEC3
	lda	#$0000
	ldy	#.loword(metasprite_06C49F)
loc_04BEC3:
	sty	OBJ_SPRITE,x
	sta	$3A,x
	cmp	#$0008
	bne	@return
	jsr	a:sub_04C1DA
@return:
	rtl
loc_04BED0:
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C4BC)
	sta	OBJ_SPRITE,x
	lda	#$3600
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	jsr	a:sub_04BF56
	bcs	loc_04BE80
	sty	$38,x
	lda	#$0080
	sta	OBJ_FACING,x
	lda	$34,x
	asl	a
	ora	$32,x
	tay
	lda	a:data_05F0D4,y
	sta	$36,x
	ldy	$34,x
	lda	a:data_05F0DC,y
	sta	OBJ_TIMER,x
	jsr	a:sub_04BFC1
	lda	#$0003
	sta	OBJ_STATE,x

face_boss_side_head_state_03:
	dec	OBJ_TIMER,x
	bmi	loc_04BF79
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
	beq	loc_04BF4E
	bit	#$0080
	beq	loc_04BF45
	lda	OBJ_ANGLE,x
	dec	a
	dec	a
	bra	loc_04BF49
loc_04BF45:
	lda	OBJ_ANGLE,x
	inc	a
	inc	a
loc_04BF49:
	and	#$00FF
	sta	OBJ_ANGLE,x
loc_04BF4E:
	lda	#$0020
	jsl	f:set_velocity_from_angle
	rtl

sub_04BF56:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_04BF60
	; (not executed in the CDL traces)
	sec
	rts
loc_04BF60:
	lda	rng_lo
	lsr	a
	bcc	loc_04BF6F
loc_04BF65:
	lda	a:p1_lives
	beq	loc_04BF6F
	ldy	#$0200
	clc
	rts
loc_04BF6F:
	lda	a:p2_lives
	beq	loc_04BF65
	; (not executed in the CDL traces)
	ldy	#$0240
	clc
	rts
loc_04BF79:
	ldy	$34,x
	lda	a:data_05F0DC,y
	sta	OBJ_TIMER,x
	jsr	a:sub_04C18A
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_side_head_state_04:
	dec	OBJ_TIMER,x
	bpl	loc_04BF8F
	brl	loc_04BE80
loc_04BF8F:
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
loc_04BFA2:
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

sub_04BFC1:
	lda	$34,x
	beq	loc_04BFC8
	brl	loc_04C073
loc_04BFC8:
	lda	$32,x
	bne	loc_04C01E
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
loc_04C01E:
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
loc_04C073:
	lda	$32,x
	bne	loc_04C097
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
	bra	loc_04C0B8
loc_04C097:
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
loc_04C0B8:
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

sub_04C137:
	lda	$34,x
	bne	loc_04C167
	lda	$32,x
	bne	loc_04C153
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+11*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+12*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+13*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+14*OBJ_SIZE+OBJ_TYPE
	clc
	beq	loc_04C166
	sec
	rts
loc_04C153:
	lda	a:obj_slots+15*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+16*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+17*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+18*OBJ_SIZE+OBJ_TYPE
	ora	a:obj_slots+19*OBJ_SIZE+OBJ_TYPE
	clc
	beq	loc_04C166
	sec
loc_04C166:
	rts
loc_04C167:
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
	beq	loc_04C166
	sec
	rts

sub_04C18A:
	lda	$34,x
	bne	loc_04C1B8
	lda	$32,x
	bne	loc_04C1A5
	lda	#$0002
	sta	a:obj_slots+10*OBJ_SIZE+$36
	sta	a:obj_slots+11*OBJ_SIZE+$36
	sta	a:obj_slots+12*OBJ_SIZE+$36
	sta	a:obj_slots+13*OBJ_SIZE+$36
	sta	a:obj_slots+14*OBJ_SIZE+$36
	rts
loc_04C1A5:
	lda	#$0002
	sta	a:obj_slots+15*OBJ_SIZE+$36
	sta	a:obj_slots+16*OBJ_SIZE+$36
	sta	a:obj_slots+17*OBJ_SIZE+$36
	sta	a:obj_slots+18*OBJ_SIZE+$36
	sta	a:obj_slots+19*OBJ_SIZE+$36
	rts
loc_04C1B8:
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

sub_04C1DA:
	ldy	#$0400
	jsl	f:find_free_slot_from_y
	bcc	loc_04C1E6
	brl	loc_04C26D
loc_04C1E6:
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
	bcs	loc_04C26D
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
	bcs	loc_04C26D
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
loc_04C26D:
	rts

; Object type $77. Stage 6, face_boss: neck segments of the side heads.
update_face_boss_neck:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_HP
	bpl	loc_04C276
	; (not executed in the CDL traces)
	brl	loc_04C383
loc_04C276:
	ldy	$30,x
	lda	a:data_05F0E4,y
	tay
	lda	a:$0006,y
	bpl	loc_04C284
	brl	loc_04C383
loc_04C284:
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
	beq	loc_04C2B5
	; (not executed in the CDL traces)
	dec	a
	beq	@return
	brl	loc_04C378
@return:
	rtl
loc_04C2B5:
	dec	$34,x
	bmi	loc_04C2BA
	rtl
loc_04C2BA:
	lda	#$003D
	sta	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C4D9)
	sta	OBJ_SPRITE,x
	lda	#$2600
	sta	OBJ_ATTR,x
	ldy	$30,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	clc
	adc	a:data_05F0E8,y
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
	beq	loc_04C2F7
	dec	a
	beq	@return
	brl	loc_04C359
@return:
	; (not executed in the CDL traces)
	rtl
loc_04C2F7:
	lda	OBJ_Y,x
	inc	a
	inc	a
	sta	OBJ_Y,x
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0034
	cmp	OBJ_Y,x
	bcc	loc_04C309
	rtl
loc_04C309:
	lda	#$0034
	sta	OBJ_Y,x
	lda	#$3600
	sta	OBJ_ATTR,x
	stz	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x

face_boss_neck_state_03:
	lda	$36,x
	beq	loc_04C325
	dec	a
	beq	@return
	brl	loc_04C33A
@return:
	; (not executed in the CDL traces)
	rtl
loc_04C325:
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
loc_04C33A:
	lda	#$0004
	sta	OBJ_STATE,x

face_boss_neck_state_04:
	dec	OBJ_TIMER,x
	bpl	loc_04C346
	brl	loc_04C359
loc_04C346:
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
loc_04C359:
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
	brl	loc_04C378
@return:
	rtl
loc_04C378:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0007
	sta	OBJ_STATE,x

face_boss_neck_state_07:
	rtl
loc_04C383:
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
	bpl	loc_04C3C2
	lda	#$0010
	sta	OBJ_STATE,x
	lda	#$0000
	sta	a:$0006,y
	sta	a:$0016,y
loc_04C3C2:
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
	lda	a:data_05F0EC,y
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
	lda	a:data_05F156,y
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
	lda	a:data_05F186,y
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
	jmp	a:loc_04CD2B

snake_robot_state_01:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F114,y
	pha
	lda	a:data_05F156,y
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
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

snake_robot_state_02:
	ldy	#$0300
	lda	a:$000E,y
	bmi	loc_04C51D
	cmp	#$00B0
	bcc	loc_04C51D
	stz	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B
loc_04C51D:
	stz	zp_02
loc_04C51F:
	lda	zp_02
	asl	a
	tay
	lda	a:ptrs_05F17E,y
	sta	zp_04
	stz	zp_00
loc_04C52A:
	lda	zp_00
	asl	a
	tay
	lda	(zp_04),y
	tay
	lda	a:$0036,y
	dec	a
	dec	a
	bmi	loc_04C53B
	sta	a:$0036,y
loc_04C53B:
	inc	zp_00
	lda	zp_00
	cmp	#$0007
	bcc	loc_04C52A
	inc	zp_02
	lda	zp_02
	cmp	#$0002
	bcc	loc_04C51F
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	bcc	loc_04C559
	inc	OBJ_Y_VEL,x
loc_04C559:
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

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
	bcc	loc_04C599
	lda	#$0038
	bra	loc_04C59C
loc_04C599:
	lda	#$0039
loc_04C59C:
	jsl	f:queue_sound
	stz	$30,x
	stz	$38,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

snake_robot_state_04:
	lda	$30,x
	bne	loc_04C5D7
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcc	loc_04C5C5
	inc	$30,x
	jmp	a:loc_04CD2B
loc_04C5C5:
	lda	OBJ_Y_VEL_SUB,x
	sec
	sbc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	bcs	loc_04C5D1
	dec	OBJ_Y_VEL,x
loc_04C5D1:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C5D7:
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcs	loc_04C60E
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
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C60E:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$8000
	sta	OBJ_Y_VEL_SUB,x
	bcc	loc_04C61A
	inc	OBJ_Y_VEL,x
loc_04C61A:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

snake_robot_state_05:
	ldy	#$0300
	lda	a:$000E,y
	sta	$34,x
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F156,y
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
	bmi	loc_04C658
	cmp	#$0080
	bcc	loc_04C658
	inc	$38,x
loc_04C658:
	lda	$38,x
	asl	a
	tay
	lda	a:data_05F0F4,y
	sta	zp_00
	lda	a:data_05F0F8,y
	sta	zp_02
	lda	a:data_05F0FC,y
	sta	zp_04
	lda	a:data_05F100,y
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
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

snake_robot_state_06:
	ldy	#$0500
	lda	a:$003A,y
	sec
	sbc	a:$0006,y
	cmp	#$0020
	bcs	loc_04C6D5
	lda	OBJ_X,x
	bmi	loc_04C6D2
	cmp	#$0028
	bcc	loc_04C6D2
	cmp	#$00B0
	bcs	loc_04C6D2
	bra	loc_04C6E1
loc_04C6D2:
	jmp	a:loc_04C83E
loc_04C6D5:
	ldy	#$0500
	lda	a:$0006,y
	sta	a:$003A,y
	jmp	a:loc_04C80E
loc_04C6E1:
	stz	zp_00
loc_04C6E3:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F17A,y
	sta	zp_02
	lda	a:data_05F186,y
	tay
	lda	a:$0030,y
	beq	loc_04C6F8
	jmp	a:loc_04C78F
loc_04C6F8:
	lda	a:$001E,y
	bpl	loc_04C700
	jmp	a:loc_04C77A
loc_04C700:
	lda	a:$000E,y
	cmp	#$00B0
	bcc	loc_04C77A
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
	lda	a:data_05F0F4,y
	sta	zp_04
	lda	a:data_05F0F8,y
	sta	zp_06
	lda	a:data_05F0FC,y
	sta	zp_08
	lda	a:data_05F100,y
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
	lda	a:data_05F188,y
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
	bra	loc_04C78F
loc_04C77A:
	lda	a:$001C,y
	clc
	adc	#$8000
	sta	a:$001C,y
	lda	a:$001E,y
	adc	#$0000
	sta	a:$001E,y
	bra	loc_04C78F
loc_04C78F:
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcs	loc_04C79B
	jmp	a:loc_04C6E3
loc_04C79B:
	jsl	f:pick_random_player
	lda	a:$000A,y
	cmp	OBJ_X,x
	bmi	loc_04C7C9
	lda	a:$000E,y
	sbc	#$0018
	cmp	OBJ_Y,x
	bpl	loc_04C805
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
	bra	loc_04C805
loc_04C7C9:
	lda	#$0000
	jsl	f:spawn_homing_missile
	bcc	loc_04C805
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
	lda	a:data_05F104,y
	sta	zp_00
	lda	a:data_05F108,y
	sta	zp_02
	ply
	lda	zp_00
	sta	a:$001C,y
	lda	zp_02
	sta	a:$001E,y
loc_04C805:
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C80E:
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
	bcs	loc_04C83E
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$FFFA	; [num]
	sta	a:$001A,y
loc_04C83E:
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
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B

snake_robot_state_07:
	stz	$38,x
	lda	OBJ_X,x
	bmi	loc_04C894
	cmp	#$0080
	bcs	loc_04C896
loc_04C894:
	inc	$38,x
loc_04C896:
	lda	$38,x
	asl	a
	tay
	lda	a:data_05F10C,y
	sta	zp_00
	lda	a:data_05F110,y
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
	jsr	a:sub_04CCAC
	jsr	a:sub_04CBE2
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	jsl	f:fire_bullet_at_player
	jmp	a:loc_04CD2B

snake_robot_state_08:
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$0400
	sta	OBJ_Y_VEL_SUB,x
	bcc	loc_04C911
	inc	OBJ_Y_VEL,x
loc_04C911:
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
	bne	loc_04C9AB
	ldy	#$0300
	lda	a:$000E,y
	sec
	sbc	OBJ_Y,x
	cmp	#$0060
	bcc	loc_04C951
	inc	$30,x
loc_04C951:
	lda	OBJ_X,x
	clc
	adc	a:data_05F17A
	sta	zp_00
	ldy	#$0300
	lda	a:$000A,y
	cmp	zp_00
	bpl	loc_04C970
	lda	a:$000A,y
	inc	a
	cmp	zp_00
	bpl	loc_04C97B
	sta	a:$000A,y
	bra	loc_04C97B
loc_04C970:
	lda	a:$000A,y
	dec	a
	cmp	zp_00
	bmi	loc_04C97B
	sta	a:$000A,y
loc_04C97B:
	lda	OBJ_X,x
	clc
	adc	a:data_05F17C
	sta	zp_00
	ldy	#$0700
	lda	a:$000A,y
	cmp	zp_00
	bpl	loc_04C99A
	lda	a:$000A,y
	inc	a
	cmp	zp_00
	bpl	loc_04C9A5
	sta	a:$000A,y
	bra	loc_04C9A5
loc_04C99A:
	lda	a:$000A,y
	dec	a
	cmp	zp_00
	bmi	loc_04C9A5
	sta	a:$000A,y
loc_04C9A5:
	jsr	a:sub_04CBE2
	jmp	a:loc_04CD2B
loc_04C9AB:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F134,y
	pha
	lda	a:data_05F156,y
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
	jmp	a:loc_04CD2B

snake_robot_state_09:
	lda	OBJ_Y_VEL,x
	bmi	loc_04CA15
	ldy	#$0300
	lda	a:$000E,y
	bmi	loc_04CA15
	cmp	#$00B0
	bcc	loc_04CA15
	stz	$30,x
	stz	OBJ_TIMER,x
	lda	#$0003
	sta	OBJ_STATE,x
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B
loc_04CA15:
	stz	zp_02
loc_04CA17:
	lda	zp_02
	asl	a
	tay
	lda	a:ptrs_05F17E,y
	sta	zp_04
	stz	zp_00
loc_04CA22:
	lda	zp_00
	asl	a
	tay
	lda	(zp_04),y
	tay
	lda	a:$0036,y
	sec
	sbc	#$0004
	bmi	loc_04CA35
	sta	a:$0036,y
loc_04CA35:
	inc	zp_00
	lda	zp_00
	cmp	#$0007
	bcc	loc_04CA22
	inc	zp_02
	lda	zp_02
	cmp	#$0002
	bcc	loc_04CA17
	lda	OBJ_Y_VEL_SUB,x
	clc
	adc	#$0400
	sta	OBJ_Y_VEL_SUB,x
	bcc	loc_04CA53
	inc	OBJ_Y_VEL,x
loc_04CA53:
	jsr	a:sub_04CB63
	jmp	a:loc_04CD2B

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
	lda	a:data_05F156,y
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
	jmp	a:loc_04CD2B

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
	bcs	loc_04CAF3
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$FFFA	; [num]
	sta	a:$001A,y
loc_04CAF3:
	jsl	f:update_snake_robot_debris
	jmp	a:loc_04CD2B

; Object type $88. Stage 4: the 16 pieces of snake_robot when it is destroyed.
update_snake_robot_debris:
	lda	a:$0024,x
	inc	a
	sta	a:$0024,x
	cmp	#$0168
	bcs	loc_04CB1A
	lda	a:$000A,x
	bit	#$FE00
	bne	loc_04CB1A
	lda	a:$000E,x
	clc
	adc	#$0100
	bit	#$FE00
	beq	loc_04CB22
loc_04CB1A:
	lda	#$8000	; [num]
	sta	a:$0016,x
	bra	loc_04CB61
loc_04CB22:
	lda	a:$001E,x
	bmi	loc_04CB3B
	lda	a:$000E,x
	bmi	loc_04CB3B
	cmp	#$00B8
	bcc	loc_04CB3B
	lda	a:$001E,x
	eor	#$FFFF
	inc	a
	sta	a:$001E,x
loc_04CB3B:
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
loc_04CB61:
	rtl
	; CDL: not accessed
	.byte	$6B

sub_04CB63:
	phx
	stx	zp_10
	stz	zp_0A
@loop:
	lda	zp_0A
	asl	a
	tay
	lda	a:data_05F17A,y
	pha
	lda	a:data_05F176,y
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
	lda	a:ptrs_05F17E,y
	sta	zp_0C
	lda	a:ptrs_05F182,y
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

sub_04CBE2:
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F17A,y
	pha
	lda	a:data_05F176,y
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
loc_04CC0A:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F190,y
	tax
	lda	$0E,x
	pha
	lda	a:data_05F1B4,y
	tax
	pla
	clc
	adc	$0E,x
	lsr	a
	pha
	lda	a:data_05F1D8,y
	tax
	pla
	sta	$0E,x
	sta	zp_08
	lda	a:data_05F190,y
	tax
	lda	$0A,x
	pha
	lda	a:data_05F1B4,y
	tax
	pla
	clc
	adc	$0A,x
	lsr	a
	cpy	#$0000
	beq	loc_04CC42
	cpy	#$0012
	bne	loc_04CC66
loc_04CC42:
	pha
	lda	zp_08
	ldx	zp_06
	sec
	sbc	$0E,x
	bpl	loc_04CC50
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
loc_04CC50:
	cmp	#$0030
	bcc	loc_04CC58
	lda	#$0030
loc_04CC58:
	sta	zp_0A
	lda	#$0030
	sec
	sbc	zp_0A
	sta	zp_04
	pla
	sec
	sbc	zp_04
loc_04CC66:
	pha
	lda	a:data_05F1D8,y
	tax
	pla
	sta	$0A,x
	inc	zp_00
	lda	zp_00
	cmp	#$0012
	bcc	loc_04CC0A
	stz	zp_00
@loop:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F186,y
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
	lda	a:data_05F18C,y
	tay
	pla
	sta	a:$000E,y
	pla
	sta	a:$000A,y
	inc	zp_00
	lda	zp_00
	cmp	#$0002
	bcc	@loop
	plx
	rts

sub_04CCAC:
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:data_05F17A
	ldy	#$0700
	adc	a:$000A,y
	sec
	sbc	a:data_05F17C
	clc
	lsr	a
	sta	zp_02
	ldy	#$0300
	lda	a:$000A,y
	sec
	sbc	a:data_05F17A
	ldy	#$0700
	clc
	adc	a:data_05F17C
	sec
	sbc	a:$000A,y
	bpl	loc_04CCDF
	eor	#$FFFF
	inc	a
loc_04CCDF:
	cmp	#$0060
	bcc	loc_04CCE7
	; (not executed in the CDL traces)
	lda	#$0060
loc_04CCE7:
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
	lda	a:data_05F156,y
	tay
	lda	zp_02
	sta	a:$0032,y
	sta	$32,x
	lda	zp_04
	sta	a:$0034,y
	lda	$36,x
	inc	a
	cmp	#$0008
	bcc	loc_04CD18
	lda	#$0000
loc_04CD18:
	sta	$36,x
	asl	a
	tay
	lda	a:data_05F156,y
	tay
	lda	a:$0032,y
	sta	OBJ_X,x
	lda	a:$0034,y
	sta	OBJ_Y,x
	rts
loc_04CD2B:
	ldy	#$0500
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	rtl

; Object type $81. Stage 4: head of snake_robot (320 HP).
update_snake_robot_head:
	lda	a:data_05F154
	tay
	lda	a:$0010,y
	bne	@return
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@return:
	rtl

; Object type $7C. Stage 4, airship: small parts under the airship (20 HP; not
; identified exactly).
update_enemy_type_7C:
	jsr	a:scroll_with_airship
	lda	OBJ_HP,x
	bpl	loc_04CD65
	lda	#$001C
	sta	$30,x
	jsr	a:sub_04CE28
	lda	#$0010
	sta	OBJ_TIMER,x
	stz	OBJ_FLAGS,x
	stz	OBJ_HP,x
	lda	#$0004
	sta	OBJ_STATE,x
loc_04CD65:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_enemy_type_7C_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_enemy_type_7C_states:
	.addr	enemy_type_7C_state_00
	.addr	enemy_type_7C_state_01
	.addr	enemy_type_7C_state_02
	.addr	enemy_type_7C_state_03
	.addr	airship_part_explode

enemy_type_7C_state_00:
	inc	OBJ_STATE,x
	stz	OBJ_FLAGS,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	ldy	$3A,x
	lda	a:data_05F1FC,y
	sta	OBJ_TIMER,x
	lda	difficulty
	asl	a
	clc
	adc	#$0010
	sta	OBJ_HP,x
	rtl

enemy_type_7C_state_01:
	cmp	#$0002
	beq	enemy_type_7C_state_03
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
	stz	$30,x
@return:
	rtl

enemy_type_7C_state_02:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	bit	#$0007
	bne	@return
	jsr	a:sub_04CE28
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

enemy_type_7C_state_03:
	lda	#$0400
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	and	#$003E
	cmp	#$0018
	bcs	loc_04CDE6
	lda	#$0018
	bra	loc_04CDEE
loc_04CDE6:
	cmp	#$0028
	bcc	loc_04CDEE
	lda	#$0028
loc_04CDEE:
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
	lda	a:data_05F222,y
	sta	$30,x
	phy
	jsr	a:sub_04CE28
	ply
	clc
	lda	a:data_05F228,y
	adc	OBJ_Y,x
	sta	zp_02
	clc
	lda	a:data_05F22E,y
	adc	OBJ_X,x
	sta	zp_00
	dec	OBJ_TIMER,x
	bpl	loc_04CE26
	lda	#$0100
	sta	OBJ_TIMER,x
	pla
	jml	f:spawn_enemy_bullet
loc_04CE26:
	pla
	rtl

sub_04CE28:
	ldy	$30,x
	lda	a:data_05F202,y
	sta	zp_00
	lda	a:data_05F204,y
	pha
	ldy	$3A,x
	lda	a:data_05F234,y
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
	bpl	loc_04CE80
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
	lda	a:data_05F23A,y
	sta	zp_FC
	jsl	f:queue_vram_block
	lda	#$5000
	sta	zp_00
	clc
	lda	zp_FC
	adc	#$0080
	jml	f:queue_vram_block
loc_04CE80:
	lda	OBJ_STATE,x
	bne	loc_04CE9F
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
loc_04CE9F:
	cmp	#$0002
	bne	loc_04CEA7
	; (not executed in the CDL traces)
	brl	airship_part_explode
loc_04CEA7:
	dec	OBJ_TIMER,x
	bpl	@return
	ldy	$3A,x
	lda	a:data_05F260,y
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
	bne	loc_04CEE7
	lda	a:$0016,y
	bne	loc_04CEED
loc_04CEE7:
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04CEED:
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
	bpl	loc_04CF48
	inc	OBJ_STATE,x
	lda	#$0020
	sta	OBJ_TIMER,x
	inc	OBJ_FACING,x
loc_04CF48:
	clc
	lda	OBJ_Y,x
	adc	#$0008
	sta	OBJ_Y,x
	rtl

lightning_bolt_state_03:
	dec	OBJ_TIMER,x
	bpl	loc_04CF5B
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04CF5B:
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
	bcc	loc_04D020
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
loc_04D020:
	plx
	stz	$3A,x
	lda	#$0100
	sta	$36,x
	rtl

spiked_mine_state_01:
	jsr	a:scroll_with_airship
	lda	$3A,x
	bne	loc_04D044
	clc
	lda	$38,x
	adc	#$0002
	bmi	loc_04D053
	cmp	#$0010
	bcc	loc_04D053
	ldy	#$0002
	sty	$3A,x
	bra	loc_04D053
loc_04D044:
	sec
	lda	$38,x
	sbc	#$0002
	bpl	loc_04D053
	cmp	#$FFB0	; [num]
	bcs	loc_04D053
	stz	$3A,x
loc_04D053:
	sta	$38,x
	sta	f:wram_7EA0E2
	lda	#$0200
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	asl	a
	cmp	$36,x
	bcc	loc_04D079
	clc
	lda	$36,x
	adc	#$0002
	cmp	#$0160
	bcc	loc_04D087
	lda	#$0160
	bra	loc_04D087
loc_04D079:
	sec
	lda	$36,x
	sbc	#$0002
	cmp	#$00A0
	bcs	loc_04D087
	lda	#$00A0
loc_04D087:
	and	#$01FE
	sta	$36,x
	sta	f:wram_7EA0E0
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
	beq	loc_04D0BB
	lda	#.loword(metasprite_06C82E)
loc_04D0BB:
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
	jsr	a:sub_04D0EA
	jsr	a:sub_04D142
	rtl

spiked_mine_state_04:
	jsr	a:sub_04D0EA
	jsr	a:sub_04D158
	rtl

sub_04D0EA:
	ldy	$3E,x
	lda	a:$0010,y
	cmp	#$007D
	beq	loc_04D106
	lda	#$FFFB	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	txy
	lda	#.loword(anim_05C516)
	jsl	f:make_effect_object
loc_04D106:
	phx
	lda	f:wram_7EA0E0
	and	#$01FE
	tay
	clc
	adc	f:wram_7EA0E2
	sta	f:wram_7EA0E0
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

sub_04D142:
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

sub_04D158:
	lda	zp_02
	sta	OBJ_Y,x
	lda	zp_00
	sta	OBJ_X,x
	rts

; Object type $7F. Stage 4, airship: the hanging cannon arms (128 HP).
update_airship_gun_arm:
	jsr	a:scroll_with_airship
	lda	OBJ_HP,x
	bpl	loc_04D1A6
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
loc_04D1A6:
	lda	$12,x
	bne	loc_04D1C6
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
loc_04D1C6:
	cmp	#$0002
	bne	loc_04D1CE
	; (not executed in the CDL traces)
	brl	airship_part_explode
loc_04D1CE:
	lda	$24,x
	beq	loc_04D207
	lda	#$0800
	jsl	f:pick_target_player
	sec
	lda	a:$000A,y
	sbc	$0A,x
	bmi	loc_04D1E6
	cmp	#$0060
	bcs	loc_04D207
loc_04D1E6:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	loc_04D207
	lda	#$0080
	sta	a:$0010,y
	lda	$0A,x
	adc	#$000C
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	stz	$24,x
loc_04D207:
	rtl

; Object type $80. Stage 4, airship: seen briefly at the end of the airship
; (not identified exactly).
update_enemy_type_80:
	lda	OBJ_STATE,x
	bne	loc_04D230
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
loc_04D230:
	cmp	#$0002
	beq	loc_04D26C
	lda	OBJ_Y,x
	cmp	#$00B0
	bcc	loc_04D247
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$FFF8	; [num]
	sta	OBJ_X_VEL,x
	inc	OBJ_STATE,x
loc_04D247:
	ldy	#$05C0
	jsl	f:find_free_slot_y_down
	bcc	loc_04D2AC
	lda	#.loword(anim_05C672)
	jsl	f:make_effect_object
	lda	#$FFFA	; [num]
	sta	a:$001A,y
	sta	a:$001E,y
	lda	OBJ_X,x
	sta	a:$000A,y
	lda	OBJ_Y,x
	sta	a:$000E,y
	bra	loc_04D2AC
loc_04D26C:
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
	bcs	loc_04D2AC
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
loc_04D2AC:
	ldy	OBJ_ANIM,x
	lda	a:$0004,y
	sta	OBJ_ATTR,x
	rtl

; Object type $84. Stage 4, helicopter: the rope hanging from the helicopter;
; one handler for the anchor (state 4), the segments (state 5) and the enemy
; at the end (states 2/3/8/9, with HP).
update_helicopter_rope:
	cpx	#$0900
	bne	loc_04D2ED
	lda	OBJ_HP,x
	bmi	loc_04D2C6
	lda	OBJ_Y,x
	cmp	#$0180
	bmi	loc_04D2ED
	; (not executed in the CDL traces)
	bcc	loc_04D2ED
loc_04D2C6:
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
loc_04D2ED:
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
	bcs	loc_04D389
	cmp	#$0078
	bcs	loc_04D3B3
	jsl	f:spawn_helicopter_rope
	lda	#$0006
	sta	OBJ_STATE,x
	rtl
loc_04D389:
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
	bcs	loc_04D3B3
	lda	#$FFFC	; [num]
	sta	a:$001A,y
	lda	#$0004
	sta	a:$001E,y
loc_04D3B3:
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
	bcc	loc_04D421
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
loc_04D421:
	plx
	stz	a:boss_work_1
	lda	#$0004
	sta	a:boss_work_5
	rtl

helicopter_rope_state_05:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_FLAGS
	cmp	#$0001
	bne	loc_04D43A
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04D43A:
	lda	#$0000
	ldy	a:boss_work_4
	bne	loc_04D445
	lda	#.loword(metasprite_06CB86)
loc_04D445:
	sta	OBJ_SPRITE,x
	jsr	a:sub_04D686
	jsr	a:sub_04D6E7
	jsr	a:sub_04D701
	rtl

helicopter_rope_state_03:
	jsr	a:sub_04D70A
	jsr	a:sub_04D7C7

sub_04D457:
	jsr	a:sub_04D686
	jsr	a:sub_04D724
	jml	f:trail_pass_to_next

helicopter_rope_state_04:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_FLAGS
	cmp	#$0001
	bne	loc_04D46F
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04D46F:
	stz	OBJ_FLAGS,x
	lda	#$0000
	ldy	a:boss_work_4
	bne	loc_04D488
	lda	#.loword(metasprite_06CB77)
	ldy	stage_frame_bit1
	bne	loc_04D483
	lda	#.loword(metasprite_06CB72)
loc_04D483:
	ldy	#$0000
	sty	OBJ_FLAGS,x
loc_04D488:
	sta	OBJ_SPRITE,x
	lda	a:boss_work_1
	beq	loc_04D4F6
	lda	#.loword(metasprite_06CB72)
	sta	OBJ_SPRITE,x
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	jsr	a:sub_04D6DD
	jsr	a:sub_04D6E7
	jsr	a:sub_04D701
	lda	a:boss_work_2
	bne	loc_04D4F5
	ldy	a:boss_work_3
	lda	OBJ_X,x
	cmp	#$0084
	bcc	loc_04D4C8
	cpy	#$0140
	bcc	loc_04D4F5
	cpy	#$0144
	bcs	loc_04D4F5
	lda	a:boss_work_7
	bmi	loc_04D4F5
	lda	#$FFFF	; [num]
	bra	loc_04D4DA
loc_04D4C8:
	cpy	#$00C0
	bcs	loc_04D4F5
	cpy	#$00BC
	bcc	loc_04D4F5
	lda	a:boss_work_7
	bpl	loc_04D4F5
	lda	#$0001
loc_04D4DA:
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_X_VEL
	stz	a:boss_work_1
	lda	#$0004
	sta	a:boss_work_5
	lda	#$0006
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
	lda	#$FFFC	; [num]
	sta	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL_SUB
loc_04D4F5:
	rtl
loc_04D4F6:
	jsr	a:sub_04D686
	jsr	a:sub_04D701
	jsr	a:sub_04D737
	rtl

helicopter_rope_state_06:
	lda	#$0007
	sta	OBJ_STATE,x
	lda	OBJ_X_VEL,x
	bpl	loc_04D513
	stz	a:boss_work_0
	stz	OBJ_FACING,x
	lda	#$0240
	bra	loc_04D51E
loc_04D513:
	lda	#$0002
	sta	a:boss_work_0
	sta	OBJ_FACING,x
	lda	#$01C2
loc_04D51E:
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
	adc	a:data_05F329,y
	sta	zp_00
	clc
	lda	OBJ_Y,x
	adc	#$FFEE
	sta	zp_02
	jsr	a:sub_04D6DD
	jsr	a:sub_04D6E7
	lda	a:boss_work_4
	bne	loc_04D563
	stz	a:boss_work_5
	bra	loc_04D566
loc_04D563:
	dec	a:boss_work_4
loc_04D566:
	jml	f:trail_pass_to_next
loc_04D56A:
	brl	helicopter_rope_state_03

helicopter_rope_state_08:
	lda	a:boss_work_3
	cmp	#$00FD
	bcc	loc_04D56A
	cmp	#$0103
	bcs	loc_04D56A
	inc	OBJ_STATE,x

helicopter_rope_state_09:
	lda	stage_frame_mod4
	bne	loc_04D5C0
	inc	a:boss_work_5
	lda	a:boss_work_5
	cmp	#$0004
	bcc	loc_04D5C0
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
	bcc	loc_04D5BB
	stz	OBJ_FACING,x
	bra	loc_04D5C0
loc_04D5BB:
	lda	#$0002
	sta	OBJ_FACING,x
loc_04D5C0:
	brl	sub_04D457

helicopter_rope_state_0A:
	dec	OBJ_TIMER,x
	bne	loc_04D5D0
	inc	OBJ_STATE,x
	stz	a:boss_work_4
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
loc_04D5D0:
	lda	OBJ_TIMER,x
	cmp	#$0014
	bne	loc_04D5FB
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	loc_04D5FB
	lda	#$0085
	sta	a:$0010,y
	lda	OBJ_FACING,x
	sta	a:$0004,y
	lda	OBJ_X,x
	adc	#$0008
	sta	a:$000A,y
	lda	OBJ_Y,x
	adc	#$0000
	sta	a:$000E,y
loc_04D5FB:
	jsl	f:sub_04D457
	lda	#$007C
	sta	OBJ_Y,x
	jml	f:trail_pass_to_next

helicopter_rope_state_0B:
	lda	stage_frame_mod4
	bne	loc_04D61C
	dec	a:boss_work_5
	bne	loc_04D61C
	lda	#$0003
	sta	OBJ_STATE,x
	lda	#$0002
	sta	a:boss_work_2
loc_04D61C:
	jsr	a:sub_04D70A
	brl	sub_04D457

helicopter_rope_state_0C:
	lda	OBJ_Y,x
	cmp	#$0180
	bcs	loc_04D632
	lda	OBJ_X,x
	bpl	loc_04D638
	cmp	#$FFC8	; [num]
	bcs	loc_04D638
loc_04D632:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_04D638:
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

sub_04D686:
	phx
	lda	a:boss_work_3
	and	#$01FE
	tay
	clc
	lda	a:circle15_x,y
	bpl	loc_04D695
	sec
loc_04D695:
	ror	a
	sta	zp_00
	clc
	lda	a:circle15_y,y
	bpl	loc_04D69F
	sec
loc_04D69F:
	ror	a
	sta	zp_02
	ldy	a:boss_work_5
loc_04D6A5:
	cpy	#$0000
	beq	loc_04D6BF
	clc
	lda	zp_00
	bpl	loc_04D6B0
	sec
loc_04D6B0:
	ror	a
	sta	zp_00
	clc
	lda	zp_02
	bpl	loc_04D6B9
	sec
loc_04D6B9:
	ror	a
	sta	zp_02
	dey
	bra	loc_04D6A5
loc_04D6BF:
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

sub_04D6DD:
	lda	$32,x
	inc	a
	inc	a
	and	#$0006
	sta	$32,x
	rts

sub_04D6E7:
	ldy	a:boss_work_1
	clc
	adc	a:data_05F28F,y
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

sub_04D701:
	lda	zp_02
	sta	OBJ_Y,x
	lda	zp_00
	sta	OBJ_X,x
	rts

sub_04D70A:
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
	lda	a:data_05F293,y
	sta	OBJ_SPRITE,x
	rts

sub_04D724:
	ldy	$3A,x
	clc
	lda	a:data_05F2B3,y
	adc	zp_00
	sta	OBJ_X,x
	clc
	lda	a:data_05F2D3,y
	adc	zp_02
	sta	OBJ_Y,x
	rts

sub_04D737:
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y_VEL
	bpl	loc_04D73D
	rts
loc_04D73D:
	ldy	#$0800
	lda	a:$000E,y
	cmp	OBJ_Y,x
	bcc	loc_04D7C6
	clc
	adc	#$FFF0
	cmp	OBJ_Y,x
	bcs	loc_04D7C6
	lda	a:$000A,y
	cmp	OBJ_X,x
	bcs	loc_04D7C6
	clc
	adc	a:$0028,y
	cmp	OBJ_X,x
	bcc	loc_04D7C6
	ldy	#$04C0
	jsl	f:find_free_slot_y_down
	bcc	loc_04D78B
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
loc_04D78B:
	ldy	#$0003
	lda	rng_lo
	and	#$0001
	bne	loc_04D79B
	lda	#$0080
	ldy	#$0008
loc_04D79B:
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
loc_04D7C6:
	rts

sub_04D7C7:
	lda	a:boss_work_3
	ldy	a:boss_work_0
	beq	loc_04D7F3
	cmp	#$0160
	bcs	loc_04D817
	lda	a:boss_work_7
	bmi	loc_04D7DE
	cmp	#$0004
	bcs	loc_04D82A
loc_04D7DE:
	clc
	lda	a:boss_work_6
	adc	#$8000
	sta	a:boss_work_6
	lda	a:boss_work_7
	adc	#$0000
	sta	a:boss_work_7
	bra	loc_04D82A
loc_04D7F3:
	cmp	#$00A4
	bcc	loc_04D817
	lda	a:boss_work_7
	bpl	loc_04D802
	cmp	#$FFFD	; [num]
	bcc	loc_04D82A
loc_04D802:
	sec
	lda	a:boss_work_6
	sbc	#$8000
	sta	a:boss_work_6
	lda	a:boss_work_7
	sbc	#$0000
	sta	a:boss_work_7
	bra	loc_04D82A
loc_04D817:
	lda	a:boss_work_0
	eor	#$0002
	sta	a:boss_work_0
	sta	OBJ_FACING,x
	lda	a:boss_work_2
	beq	loc_04D82A
	dec	a:boss_work_2
loc_04D82A:
	clc
	lda	a:boss_work_7
	adc	a:boss_work_3
	sta	a:boss_work_3
	rts

; Object type $85. Stage 4, helicopter scene: a spinning projectile thrown
; upward that curves (probably by the enemy on helicopter_rope).
update_enemy_type_85:
	lda	OBJ_STATE,x
	bne	loc_04D866
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
	lda	a:data_05F33B,y
	sta	OBJ_X_VEL,x
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$2000
	sta	OBJ_Y_VEL_SUB,x
	rtl
loc_04D866:
	ldy	OBJ_FACING,x
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	a:data_05F33F,y
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	a:data_05F343,y
	sta	OBJ_X_VEL,x
	rtl
