; objects/object_handlers_01a.asm -- Object handlers (bank $01, part 1)
; Bank $01, $01:B194-$01:CF8A. Included by main.asm in segment BANK01.
;
; Handlers of object types dispatched through tbl_object_types and their helpers;
; spawn_effect..sub_01CF66 are helpers used by every bank.

; Object type $02: the stage 1 mid-boss, a tank that crashes down through a
; building (section 8, slot $0900; seen in the emulator). Drawn on BG2
; (bg2_x/bg2_y follow its position), HP 256. Waits for the scroll stop and
; the BG2 screen (state 0, which also deletes the player tank in slot 31),
; breaks the building (state 1: tile blocks, dust), falls (2-3), lands
; (4), then drives left and right (5-7) throwing shells (type $1C) from its
; top. Destroyed: explosions (8, shake_and_explode_state), then state $0A
; resumes the scroll and sets stage_checkpoint.
update_midboss_tank:
	lda	OBJ_STATE,x
	pha
	beq	@dispatch
	cmp	#$0008
	bcs	@set_bg2_scroll
	lda	OBJ_HP,x
	bpl	@alive
	pla
	lda	#SOUND_VEHICLE_EXPLODE
	jsl	f:queue_sound
	stz	$18,x
	stz	$1A,x
	stz	$16,x
	stz	$06,x
	lda	#$0080
	sta	$24,x
	lda	#$0008
	sta	$12,x
	lda	#$B540	; [num]
	sta	zp_00
	lda	#$4D8C
	jsl	f:queue_vram_block
	lda	#$B520	; [num]
	sta	zp_00
	lda	#$4E0C
	jsl	f:queue_vram_block
	lda	#$B560	; [num]
	sta	zp_00
	lda	#$4D90
	jml	f:queue_vram_block
@alive:
	lda	$26,x
	beq	@set_bg2_scroll
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
@set_bg2_scroll:
	sec
	lda	#$00A8
	sbc	$0E,x
	sta	a:bg2_y
	sec
	lda	#$015C
	sbc	$0A,x
	sta	a:bg2_x
@dispatch:
	pla
	phx
	asl	a
	tax
	lda	f:tbl_midboss_tank_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_midboss_tank_states:
	.addr	midboss_tank_state_00
	.addr	midboss_tank_state_01
	.addr	midboss_tank_state_02
	.addr	midboss_tank_state_03
	.addr	midboss_tank_state_04
	.addr	midboss_tank_state_05
	.addr	midboss_tank_state_06
	.addr	midboss_tank_state_07
	.addr	midboss_tank_state_08
	.addr	shake_and_explode_state
	.addr	midboss_tank_state_0A

midboss_tank_state_00:
	lda	#$8000	; [num]
	sta	a:obj_slots+31*OBJ_SIZE+OBJ_FLAGS
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@return
	lda	a:bg2_screen_drawn
	beq	@return
	lda	#$0050
	sta	OBJ_HITBOX_W,x
	lda	#$FFC0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#ENEMY_HP($0100)
	sta	OBJ_HP,x
	lda	#$0080
	sta	a:boss_work_0
	lda	#$009C
	sta	OBJ_X,x
	lda	#$00A8
	sta	OBJ_Y,x
	lda	#.loword(vram_blocks_05ACDF)
	sta	$30,x
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
	lda	#$0044
	jsl	f:queue_sound
@return:
	rtl

midboss_tank_state_01:
	lda	#$0003
	sta	a:shake_timer
	lda	#$0078
	sta	zp_00
	lda	#$00D0
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C69C)
	jsl	f:spawn_effect_random_offset
	bcs	@debris_done
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@debris_done:
	stx	zp_FA
	stz	zp_00
	stz	zp_0C
	lda	$24,x
	cmp	#$0010
	bcc	@check_phase
	lda	#$0000
	sta	$24,x
@check_phase:
	cmp	#$0003
	bcs	@next_frame
	cmp	#$0000
	beq	@vram_offset_set
	ldy	#$0010
	sty	zp_00
	ldy	#$0100
	sty	zp_0C
	cmp	#$0001
	beq	@vram_offset_set
	lda	#$0020
	sta	zp_00
	lda	#$0200
	sta	zp_0C
@vram_offset_set:
	lda	a:bg1_x
	bit	#$0100
	beq	@queue_blocks
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
@queue_blocks:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	clc
	lda	$30,x
	adc	zp_00
	tay
	clc
	lda	#$4010
	adc	zp_0C
	jsl	f:queue_vram_blocks
	ldx	zp_FA
	lda	$24,x
	cmp	#$0002
	bne	@next_frame
	clc
	lda	$30,x
	adc	#$0030
	sta	$30,x
	cmp	#.loword(vram_blocks_05ACDF + $240)	; past the last block
	bcc	@next_frame
	inc	$12,x
	lda	#$0060
	sta	$24,x
@next_frame:
	inc	$24,x
	rtl

midboss_tank_state_02:
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	#$8000	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	OBJ_X_VEL,x
	lda	#$0001
	sta	OBJ_FACING,x
	lda	#SOUND_TANK_ENGINE
	jsl	f:queue_sound
@return:
	rtl

midboss_tank_state_03:
	inc	a:shake_continuous
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	@queue_tiles
	lda	#$401D
	sta	OBJ_FLAGS,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0001
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@queue_tiles:
	ldy	#.loword(vram_blocks_05AC97)
	lda	stage_frame_bit1
	bne	@frame_set
	ldy	#.loword(vram_blocks_05ACA7)
@frame_set:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	#$4E08
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

midboss_tank_state_04:
	lda	OBJ_TIMER,x
	bne	@timer_running
	ldy	#.loword(vram_blocks_05ACB7)
	inc	OBJ_STATE,x
	lda	#$4D88
	pha
	lda	#$0040
	bra	@queue_blocks
@timer_running:
	ldy	#.loword(vram_blocks_05ACC7)
	dec	$24,x
	lda	#$4E88
	pha
	lda	#$0020
@queue_blocks:
	sta	zp_08
	lda	#$0004
	sta	zp_02
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

midboss_tank_state_05:
	inc	a:shake_continuous
	lda	OBJ_X,x
	cmp	#$0028
	bcs	midboss_tank_queue_move_tiles
	inc	OBJ_STATE,x
	stz	OBJ_X_VEL,x
	stz	OBJ_FACING,x
	lda	#$0001
	sta	$38,x
	rtl

midboss_tank_state_06:
	inc	a:shake_continuous
	lda	OBJ_FACING,x
	beq	@moving_right
	lda	OBJ_X,x
	cmp	$34,x
	bcs	midboss_tank_queue_move_tiles
	bcc	@stop
@moving_right:
	lda	$0A,x
	cmp	#$0090
	bcc	midboss_tank_queue_move_tiles
@stop:
	lda	#$0100
	sta	$30,x
	lda	#SOUND_TANK_STOP
	jsl	f:queue_sound
	stz	$18,x
	stz	$1A,x
	lda	#$0007
	sta	$12,x
	rtl
midboss_tank_queue_move_tiles:
	lda	stage_frame_bit1
	bne	@frame_2
	lda	#$B600	; [num]
	sta	zp_FC
	ldy	#.loword(vram_blocks_05ACCF)
	lda	#$4E88
	pha
	bra	@queue_blocks
@frame_2:
	lda	#$BF40	; [num]
	sta	zp_FC
	ldy	#.loword(vram_blocks_05ACD7)
	lda	#$4E88
	pha
@queue_blocks:
	lda	#$0020
	sta	zp_08
	lda	#$0004
	sta	zp_02
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	zp_FC
	sta	zp_00
	lda	#$4E08
	jsl	f:queue_vram_block
	lda	$38,x
	bne	midboss_tank_throw_shells
	rtl

midboss_tank_state_07:
	lda	difficulty
	cmp	#$0004
	bcs	@check_timer
	stz	$38,x
@check_timer:
	lda	$30,x
	bne	@wait
	lda	$04,x
	eor	#$0001
	sta	$04,x
	beq	@move_right
	lda	#$0060
	sta	$34,x
	lda	#$FFFF	; [num]
	bra	@set_x_vel
@move_right:
	lda	#$0000
@set_x_vel:
	sta	$1A,x
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0006
	sta	$12,x
	lda	#SOUND_TANK_ENGINE
	jsl	f:queue_sound
	bra	loc_01B4D0
@wait:
	dec	$30,x
; Every midboss_tank_shell_masks[difficulty] frames throws a shell
; (type $1C) with a random velocity, sound $1A.
midboss_tank_throw_shells:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:midboss_tank_shell_masks,y
	bne	@pick_tile
	jsl	f:find_free_slot_y
	bcs	@pick_tile
	lda	$0A,x
	adc	#$0002
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFC0
	sta	a:$000E,y
	lda	#OBJT_MIDBOSS_TANK_SHELL
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$3000
	sta	a:$0002,y
	lda	#$0008
	sta	a:$0028,y
	lda	#$FFF8	; [num]
	sta	a:$002A,y
	phx
	lda	rng_lo
	and	#$0007
	asl	a
	sta	zp_00
	tax
	lda	a:midboss_tank_shell_y_vels,x
	sta	a:$001E,y
	lda	rng_hi
	and	#$0007
	asl	a
	clc
	adc	zp_00
	sta	zp_00
	tax
	lda	a:midboss_tank_shell_x_vel_subs,x
	sta	a:$0018,y
	lda	zp_00
	and	#$000F
	tax
	lda	a:midboss_tank_shell_x_vels,x
	sta	a:$001A,y
	plx
	lda	#SOUND_ENEMY_FIRE
	jsl	f:queue_sound
@pick_tile:
	lda	rng_temp
	bne	loc_01B4D5
loc_01B4D0:
	lda	#$B5A0	; [num]
	bra	loc_01B4D8
loc_01B4D5:
	lda	#$B580	; [num]
loc_01B4D8:
	sta	zp_00
	lda	#$4D8C
	jml	f:queue_vram_block

midboss_tank_state_08:
	jsl	f:queue_sound_41_throttled
	dec	$24,x
	bne	@explosions
	inc	$12,x
	lda	#$0030
	sta	$24,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	rtl
@explosions:
	lda	$0A,x
	sta	zp_00
	lda	#$00B0
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rtl

midboss_tank_state_0A:
	lda	#$0000
	sta	a:bg2_x
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0001
	sta	a:bg1_scroll_mode
	lda	#$0001
	sta	a:stage_checkpoint
	rtl

; Object type $1C: shell thrown by the mid-boss tank (type $02,
; midboss_tank_throw_shells; seen in the emulator): a finned bomb whose
; sprite follows its vertical speed; explodes on the floor (y >= $C8) or
; when shot.
update_midboss_tank_shell:
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	@check_hit
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	bra	@explode
@check_hit:
	lda	$14,x
	beq	@pick_sprite
@explode:
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
@pick_sprite:
	lda	$1E,x
	bpl	@falling
	cmp	#$FFFE	; [num]
	bcs	@rising_slow
	lda	#.loword(metasprite_06AF96)
	bra	@set_sprite
@rising_slow:
	lda	#.loword(metasprite_06AFB9)
	bra	@set_sprite
@falling:
	cmp	#$0001
	bcs	@vel_1_up
	lda	#.loword(metasprite_06AFB4)
	bra	@set_sprite
@vel_1_up:
	cmp	#$0003
	bcs	@vel_3_up
	lda	#.loword(metasprite_06AFAF)
	bra	@set_sprite
@vel_3_up:
	lda	#.loword(metasprite_06AFAA)
@set_sprite:
	sta	$00,x
	lda	$1E,x
	bmi	@gravity
	cmp	#$0003
	bcs	@return
@gravity:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
@return:
	rtl

; Object type $6E: stage 4: the tank at the start (HP 315; seen in the
; emulator).
update_stage4_tank:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_stage4_tank_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage4_tank_states:
	.addr	stage4_tank_state_00
	.addr	stage4_tank_state_01
	.addr	stage4_tank_state_02
	.addr	stage4_tank_state_03

stage4_tank_state_00:
	inc	OBJ_STATE,x
	lda	#$0180
	sta	OBJ_X,x
	lda	#$00C0
	sta	OBJ_Y,x
	lda	#$0060
	sta	OBJ_HITBOX_W,x
	lda	#$FFC0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_TIMER,x
	lda	#$0003
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	#.loword(vram_blocks_05AF1F)
	lda	#$4608
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#$0008
	sta	a:bg1_y
	rtl

stage4_tank_state_01:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0100
	sta	OBJ_X,x
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#$1000
	sta	OBJ_TIMER,x
	lda	#ENEMY_HP($0140)
	sta	OBJ_HP,x
	inc	OBJ_STATE,x
@return:
	rtl

stage4_tank_state_02:
	lda	OBJ_HP,x
	bpl	@alive
	inc	OBJ_STATE,x
	stz	OBJ_FLAGS,x
	lda	#$0080
	sta	OBJ_TIMER,x
	rtl
@alive:
	lda	$26,x
	beq	@flash_done
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$6050
	sta	cgram_upload_addr
@flash_done:
	lda	$24,x
	bpl	@advance
	; (not executed in the CDL traces)
	lda	#$F000	; [num]
	sta	$18,x
	stz	$1A,x
	lda	$0A,x
	cmp	#$0100
	bcc	@scroll
	lda	#$0100
	sta	$24,x
	dec	$12,x
	stz	$16,x
	rtl
@advance:
	dec	$24,x
	lda	$0A,x
	cmp	#$0090
	bcs	@check_speed
	stz	$18,x
	stz	$1A,x
	bra	@fire_missile
@check_speed:
	lda	$1A,x
	bpl	@accelerate_left
	cmp	#$FFFF	; [num]
	bcc	@fire_missile
@accelerate_left:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	@scroll
@fire_missile:
	lda	stage_frame_counter
	and	#$007F
	bne	@scroll
	lda	#$0000
	jsl	f:spawn_homing_missile
	bcc	@scroll
	lda	#$0002
	sta	$1A,x
	lda	#$00A0
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
@scroll:
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:bg1_x
	lda	#$0003
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	stage_frame_bit1
	bne	@frame_2
	ldy	#.loword(vram_blocks_05AF25)
	bra	@queue_blocks
@frame_2:
	ldy	#.loword(vram_blocks_05AF2B)
@queue_blocks:
	lda	#$4688
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

stage4_tank_state_03:
	dec	OBJ_TIMER,x
	bpl	@burning
	lda	#$0200
	sta	OBJ_TIMER,x
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	ldy	#.loword(vram_blocks_05946A)
	lda	#$4608
	phx
	jsl	f:queue_vram_blocks
	plx
	bra	@hide
@burning:
	lda	stage_frame_odd
	bne	@hide
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:bg1_x
	lda	#.loword(anim_05C5B8)
	bra	@spawn_explosion
@hide:
	lda	#.loword(anim_05C4CE)
	stz	a:bg1_x
@spawn_explosion:
	pha
	jsl	f:queue_sound_41_throttled
	lda	$0A,x
	sta	zp_00
	lda	#$00B4
	sta	zp_02
	lda	#$001F
	sta	zp_06
	lda	#$003F
	sta	zp_04
	ldy	#$0500
	pla
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFF8	; [num]
	sta	a:$001A,y
@return:
	rtl

; Object type $09: the tank the players can drive in stage 1 (sections 4-5;
; seen in the emulator), drawn on BG2 (tiles queue_vram_blocks, position
; through the HDMA table at $7E:3800, init_tank_hdma_table). A player who
; lands on its hatch (player_tank_check_boarding) enters it
; (PLAYER_STATE_ENTER_TANK, then PLAYER_STATE_TANK) and becomes tank_driver.
; The tank's damage counter is obj_slots+31*OBJ_SIZE+OBJ_HP (OBJ_HP of slot $09C0): objects
; with OBJ_FLAGS bit $1000 touching it decrement it.
update_player_tank:
	lda	OBJ_STATE,x
	cmp	#$0003
	beq	@smoke
	lda	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	beq	@dispatch
	cmp	#$0009
	bcs	@dispatch
@smoke:
	; (not executed in the CDL traces)
	lda	stage_frame_mod8
	bne	@dispatch
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@dispatch
	lda	#$FFFE	; [num]
	sta	a:$001E,y
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_player_tank_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_player_tank_states:
	.addr	player_tank_state_00
	.addr	player_tank_state_01
	.addr	player_tank_state_02
	.addr	player_tank_state_03
	.addr	player_tank_state_04

player_tank_state_00:
	stz	a:tank_moving
	lda	#$0041
	sta	OBJ_FLAGS,x
	lda	#$FFDA	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0058
	sta	OBJ_HITBOX_W,x
	stz	$34,x
	lda	#.loword(vram_blocks_05AF3D)
	sta	$3A,x
	lda	#$0010
	sta	OBJ_HP,x
	stz	$38,x
	inc	OBJ_STATE,x
	lda	#$0200
	sta	a:tank_driver
	stz	a:wram_165A
	stz	a:tank_move_dx
	rtl

player_tank_state_01:
	lda	a:player1_obj+OBJ_FLAGS
	beq	@check_player2
	bmi	@check_player2
	ldy	#$0200
	jsr	a:player_tank_check_boarding
	lda	a:player1_state
	cmp	#$0009
	beq	player_tank_state_02
@check_player2:
	lda	a:player2_obj+OBJ_FLAGS
	beq	player_tank_push_and_damage
	bmi	player_tank_push_and_damage
	ldy	#$0240
	jsr	a:player_tank_check_boarding
	bra	player_tank_push_and_damage

player_tank_state_02:
	lda	a:tank_driver
	tay
	lda	a:$1306,y
	sta	OBJ_X_VEL,x
	clc
	lda	a:$000A,y
	adc	#$FFD8
	sta	OBJ_X,x
	tya
	eor	#$0040
	tay
	lda	a:$0016,y
	beq	player_tank_push_and_damage
	bmi	player_tank_push_and_damage
	lda	$34,x
	sta	zp_0C
	jsl	f:solid_object_vs_player
; Pushes the objects with OBJ_FLAGS bit $0800 out of the tank; those with
; bit $1000 count down its damage (obj_slots+31*OBJ_SIZE+OBJ_HP).
player_tank_push_and_damage:
	lda	$34,x
	asl	a
	tay
	lda	a:player_tank_push_flags_right,y
	sta	zp_02
	lda	a:player_tank_push_flags_left,y
	sta	zp_00
	lda	#$0080
	sta	zp_04
	ldy	#$0280
@loop:
	lda	a:$0016,y
	bit	#$0800
	beq	@next
	jsr	a:solid_object_vs_object
	lda	zp_0E
	beq	@next
	bit	#$1000
	beq	@next
	lda	a:$0010,y
	cmp	#OBJT_FLAME_GEYSER_FLAME
	beq	@destroyed
	lda	#$0200
	sta	a:$003C,y
	dec	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	bne	@check_damage
@destroyed:
	; (not executed in the CDL traces)
	stz	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x
	bra	@damaged
@check_damage:
	lda	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	cmp	#$0008
	bne	@next
@damaged:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	a:wram_165A
	lda	#.loword(vram_blocks_05AF49)
	sta	$3A,x
	bra	@set_scroll
@next:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
@set_scroll:
	sec
	lda	#$0168
	sbc	$0A,x
	sta	f:hdma_tables+$07
	lda	a:tank_move_dx
	bne	@shake
	lda	a:wram_165A
	bne	player_tank_animate
	rtl
@shake:
	inc	a:shake_continuous
player_tank_animate:
	lda	stage_frame_mod4
	bne	@return
	lda	#$0003
	sta	zp_02
	lda	a:wram_165A
	beq	@normal_tiles
	; (not executed in the CDL traces)
	stz	a:wram_165A
	lda	#$0030
	sta	zp_08
	lda	#$4E8C
	ldy	#.loword(vram_blocks_05AF55)
	bra	@queue
@normal_tiles:
	ldy	$3A,x
	lda	rng_temp
	bne	@set_count
	clc
	lda	a:$003A,x
	adc	#$0006
	tay
@set_count:
	lda	#$0018
	sta	zp_08
	lda	#$4F0C
@queue:
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rtl

player_tank_state_04:
	lda	a:bg2_scroll_mode
	cmp	#$0002
	bne	@return
	lda	#$0000
	sta	f:hdma_tables+$07
	stz	a:bg2_x
	stz	hdma_preset
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@return:
	rtl

player_tank_state_03:
	; (not executed in the CDL traces)
	dec	OBJ_TIMER,x
	beq	@gone
	lda	OBJ_X,x
	cmp	#$FF80	; [num]
	bcs	@moving
	cmp	#$FF00	; [num]
	bcc	@moving
@gone:
	lda	#$0004
	sta	$12,x
	stz	$16,x
	lda	#$0000
	sta	f:hdma_tables+$07
	rtl
@moving:
	lda	a:wram_165A
	bne	player_tank_animate
	lda	stage_frame_odd
	bne	@push
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C5DC)
	jsl	f:spawn_effect_random_offset
@push:
	jsr	a:player_tank_push_objects
	lda	$24,x
	cmp	#$0060
	bcs	@set_scroll
	lda	stage_frame_odd
	bne	@set_scroll
	sta	f:hdma_tables+$07
	rtl
@set_scroll:
	sec
	lda	#$0168
	sbc	$0A,x
	sta	f:hdma_tables+$07
	rtl

init_tank_hdma_table:
	lda	#$007F
	sta	f:hdma_tables
	lda	#$1C00
	sta	f:hdma_tables+$02
	lda	#$0000
	sta	f:hdma_tables+$04
	lda	#$007F
	sta	f:hdma_tables+$06
	lda	#$0000
	sta	f:hdma_tables+$08
	lda	#$0000
	sta	f:hdma_tables+$0A
	rtl

set_solid_push_flags:
	lda	#$0080
	sta	zp_04
	lda	#$0200
	sta	zp_02
	lda	#$0400
	sta	zp_00
	ldy	#$0280
	rts

; The object at X is solid for the players (solid_object_vs_player) and
; pushes foot soldiers (type $0A) and alien dogs (type $1E) out of it
; (solid_object_vs_object).
solid_object_vs_players_and_soldiers:
	lda	a:player1_obj+OBJ_FLAGS
	beq	@player2
	ldy	#$0200
	stz	zp_0C
	jsl	f:solid_object_vs_player
	beq	@push_soldiers
@player2:
	lda	a:player2_obj+OBJ_FLAGS
	beq	@push_soldiers
	ldy	#$0240
	stz	zp_0C
	jsl	f:solid_object_vs_player
@push_soldiers:
	jsr	a:set_solid_push_flags
@loop:
	lda	a:$0010,y
	cmp	#$000A
	beq	@push
	cmp	#$001E
	bne	@next
@push:
	jsr	a:solid_object_vs_object
@next:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	rtl

player_tank_push_objects:
	; (not executed in the CDL traces)
	lda	a:player1_obj+OBJ_FLAGS
	beq	@player2
	bmi	@player2
	ldy	#$0200
	stz	zp_0C
	jsl	f:solid_object_vs_player
	beq	@push_objects
@player2:
	lda	a:player2_obj+OBJ_FLAGS
	beq	@push_objects
	bmi	@push_objects
	ldy	#$0240
	stz	zp_0C
	jsl	f:solid_object_vs_player
@push_objects:
	jsr	a:set_solid_push_flags
@loop:
	lda	a:$0016,y
	bit	#$0800
	beq	@next
	jsr	a:solid_object_vs_object
	lda	zp_0E
	beq	@next
	bit	#$1000
	beq	@next
	lda	#$0200
	sta	a:$003C,y
@next:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	rts

; Solid for the player at Y; when that player stands on the tank 40-48
; pixels right of its x, it enters: tank_driver = Y, player state 9.
player_tank_check_boarding:
	lda	$34,x
	sta	zp_0C
	jsl	f:solid_object_vs_player
	lda	a:$003C,y
	bit	#$0080
	beq	@not_boarding
	clc
	lda	$0A,x
	adc	#$0020
	bmi	@not_boarding
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	@not_boarding
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	@board
@not_boarding:
	lda	$0A,x
	cmp	#$FF80	; [num]
	bcs	@return
	cmp	#$FF00	; [num]
	bcc	@return
	lda	#$0004
	sta	$12,x
	stz	$16,x
@return:
	rts
@board:
	sty	a:tank_driver
	lda	$0A,x
	clc
	adc	#$0028
	sta	a:$000A,y
	lda	#$0009
	sta	a:$0012,y
	inc	$12,x
	lda	#$0000
	sta	a:$0018,y
	sta	a:$001A,y
	sta	a:$0024,y
	lda	a:$0016,y
	ora	#$0002
	sta	a:$0016,y
	rts
solid_object_vs_object_return:
	rts

; Pushes the object at Y out of the hitbox of the object at X along the
; shallower axis and ORs the side flag (zp_00 left, zp_02 right, zp_04 top)
; into its field $3E; zp_0E = its OBJ_FLAGS (0: no overlap).
solid_object_vs_object:
	stz	zp_0E
	clc
	lda	$0A,x
	adc	$28,x
	sec
	sbc	a:$000A,y
	bmi	solid_object_vs_object_return
	sta	zp_10
	clc
	lda	a:$000A,y
	adc	a:$0028,y
	sec
	sbc	$0A,x
	bmi	solid_object_vs_object_return
	sta	zp_12
	clc
	lda	$0E,x
	adc	$2A,x
	sec
	sbc	a:$000E,y
	bpl	solid_object_vs_object_return
	eor	#$FFFF
	inc	a
	sta	zp_14
	clc
	lda	a:$000E,y
	adc	a:$002A,y
	sec
	sbc	$0E,x
	bpl	solid_object_vs_object_return
	eor	#$FFFF
	inc	a
	sta	zp_16
	lda	a:$0016,y
	sta	zp_0E
	lda	zp_10
	cmp	zp_12
	bcc	@min_x_set
	lda	zp_12
@min_x_set:
	sta	zp_08
	lda	zp_14
	cmp	zp_16
	bcc	@min_y_set
	lda	zp_16
@min_y_set:
	sta	zp_0A
	lda	zp_0A
	cmp	zp_08
	bcs	@push_sideways
	lda	zp_14
	cmp	zp_16
	bcs	@return2
	; (not executed in the CDL traces)
	lda	a:$001E,y
	bmi	@return
	clc
	lda	$0E,x
	adc	$2A,x
	sta	a:$000E,y
	lda	zp_04
	ora	a:$003E,y
	sta	a:$003E,y
@return:
	rts
@return2:
	rts
@push_sideways:
	lda	zp_10
	cmp	zp_12
	bcs	@push_left
	clc
	lda	$0A,x
	adc	$28,x
	sta	a:$000A,y
	lda	zp_02
	ora	a:$003E,y
	sta	a:$003E,y
	rts
@push_left:
	sec
	lda	$0A,x
	sbc	a:$0028,y
	sta	a:$000A,y
	lda	zp_00
	ora	a:$003E,y
	sta	a:$003E,y
	rts

; Object type $0A: running foot soldier (stage 1; checked in the emulator).
; Killed: becomes type $1B (dying soldier).
update_foot_soldier:
	lda	$30,x
	bmi	kill_foot_soldier
	lda	OBJ_HP,x
	bpl	foot_soldier_run_state
; Turns the soldier into a dying soldier (type $1B).
kill_foot_soldier:
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
foot_soldier_run_state:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_foot_soldier_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_foot_soldier_states:
	.addr	foot_soldier_state_00
	.addr	foot_soldier_state_01
	.addr	foot_soldier_state_02
	.addr	foot_soldier_state_03
	.addr	foot_soldier_state_04
	.addr	foot_soldier_state_05

soldier_stop_and_run:
	stz	$1C,x
	stz	$1E,x
	lda	#$0008
	sta	$24,x

soldier_set_run_direction:
	lda	$0A,x
	cmp	#$0080
	bcc	@run_right
	lda	#$0002
	sta	$04,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	rts
@run_right:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	rts
stop_and_init_foot_soldier:
	jsr	a:soldier_stop_and_run
	bra	init_foot_soldier_keep_timer

init_foot_soldier_running:
	lda	#$000C
	sta	$24,x
	lda	#$0003
	sta	$12,x
	jsr	a:soldier_set_run_direction
	jsl	f:foot_soldier_state_00
	lda	#$0068
	sta	$0E,x
	rtl

; Turns the slot into a foot soldier with HP soldier_hp[difficulty] (the
; others have 0) and a random start delay.
init_foot_soldier_with_hp:
	lda	rng_lo
	and	#$003F
	sta	$24,x
init_foot_soldier_keep_timer:
	ldy	difficulty
	lda	a:soldier_hp,y
	sta	$06,x
	lda	#$0001
	sta	$12,x
	lda	#$3600
	bra	init_foot_soldier_common

foot_soldier_state_00:
	stz	OBJ_HP,x
	lda	#$3400
init_foot_soldier_common:
	sta	$02,x
	lda	#OBJT_FOOT_SOLDIER
	sta	$10,x
	lda	#$00C8
	sta	$0E,x
	lda	#$081F
	sta	$16,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE0	; [num]
	sta	$2A,x
	inc	$12,x
	lda	#.loword(anim_05AF9C)
	sta	$20,x
	lda	#$0003
	sta	$30,x
	rtl

foot_soldier_state_02:
	lda	OBJ_X,x
	cmp	#$0020
	bcc	foot_soldier_state_01
	cmp	#$00D0
	bcs	foot_soldier_state_01
	dec	OBJ_TIMER,x
	bpl	foot_soldier_state_01
	lda	#$0006
	sta	OBJ_TIMER,x
	lda	$3E,x
	bne	foot_soldier_pushed
	lda	#.loword(anim_05AFB6)
	sta	OBJ_ANIM,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	inc	OBJ_STATE,x

foot_soldier_state_01:
	lda	$3E,x
	beq	foot_soldier_return
foot_soldier_pushed:
	bit	#$0004
	beq	@not_run_over
	; (not executed in the CDL traces)
	brl	kill_foot_soldier
@not_run_over:
	dec	$30,x
	stz	$3E,x
	stz	$22,x
	bit	#$0200
	beq	@check_pushed_left
	inc	$0A,x
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	bra	foot_soldier_return
@check_pushed_left:
	bit	#$0400
	beq	foot_soldier_return
	dec	$0A,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	lda	#$0002
	sta	$04,x
foot_soldier_return:
	rtl

foot_soldier_state_03:
	lda	$3E,x
	beq	@not_pushed
	; (not executed in the CDL traces)
	brl	kill_foot_soldier
@not_pushed:
	lda	$20,x
	bne	@wait_fire
	lda	#$0001
	sta	$12,x
	lda	#.loword(anim_05AF9C)
	sta	$20,x
	lda	#$7000
	sta	$24,x
	lda	$0A,x
	cmp	#$0080
	bcs	@run_right
	lda	#$0002
	sta	$04,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	rtl
@run_right:
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	rtl
@wait_fire:
	dec	$24,x
	bne	@return
	lda	$0E,x
	adc	#$FFEA
	sta	zp_02
	lda	$04,x
	bne	@facing_left
	lda	$0A,x
	adc	#$0008
	sta	zp_00
	lda	#$0010
	jml	f:spawn_enemy_bullet
@facing_left:
	lda	$0A,x
	sta	zp_00
	lda	#$0030
	jml	f:spawn_enemy_bullet
@return:
	rtl

; Object type $35: soldier crashing out through a window (stage 1, the
; cafe and the next buildings; seen in the emulator), HP soldier_hp. Waits
; behind the window until x < $D0, breaks it (queue_object_tiles, shards:
; type $10 debris), jumps down and lands as a foot soldier
; (stop_and_init_foot_soldier).
update_window_jumper:
	lda	OBJ_HP,x
	bpl	@dispatch
	brl	kill_foot_soldier
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_window_jumper_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_window_jumper_states:
	.addr	window_jumper_state_00
	.addr	window_jumper_state_01
	.addr	window_jumper_state_02
	.addr	window_jumper_state_03
	.addr	window_jumper_state_04

window_jumper_state_00:
	lda	#.loword(vram_blocks_05AFCE)
	sta	$32,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	sta	$34,x
	ldy	difficulty
	lda	a:soldier_hp,y
	sta	OBJ_HP,x
	inc	OBJ_STATE,x
	rtl

window_jumper_state_01:
	lda	OBJ_X,x
	cmp	#$00D0
	bcs	@return
	inc	OBJ_STATE,x
@return:
	rtl

window_jumper_state_02:
	lda	$34,x
	bne	@queue_tiles
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$FFFD	; [num]
	sta	OBJ_Y_VEL,x
	lda	#.loword(metasprite_06B1C1)
	sta	OBJ_SPRITE,x
	lda	#$3600
	sta	OBJ_ATTR,x
	lda	OBJ_X,x
	sta	zp_10
	phx
	ldx	#$000A
	ldy	#$0300
@loop:
	jsl	f:find_free_slot_from_y
	bcc	@spawn_debris
@next:
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bpl	@loop
	plx
	lda	#SOUND_WINDOW_CRASH
	jsl	f:queue_sound
	inc	$12,x
	rtl
@spawn_debris:
	lda	#OBJT_BOUNCING_DEBRIS
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	a:window_jumper_glass_x_offsets,x
	adc	zp_10
	sta	a:$000A,y
	lda	a:window_jumper_glass_y,x
	sta	a:$000E,y
	lda	a:window_jumper_glass_x_vels,x
	sta	a:$001A,y
	lda	a:window_jumper_glass_x_vel_subs,x
	sta	a:$0018,y
	lda	#$0020
	sta	a:$0024,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$FFFE	; [num]
	sta	a:$0030,y
	lda	#.loword(metasprite_06B1EB)
	sta	a:$0000,y
	sta	a:$0032,y
	bra	@next
@queue_tiles:
	lda	stage_frame_mod4
	cmp	#$0003
	bne	@return
	jsl	f:queue_object_tiles
@return:
	rtl

window_jumper_state_03:
	lda	OBJ_Y_VEL,x
	bmi	window_jumper_fall
	lda	#$081F
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	inc	OBJ_STATE,x

window_jumper_state_04:
	lda	$3E,x
	beq	@check_floor
	; (not executed in the CDL traces)
	brl	kill_foot_soldier
@check_floor:
	lda	#$00C8
	cmp	$0E,x
	bcs	window_jumper_fall
	brl	stop_and_init_foot_soldier
window_jumper_fall:
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

foot_soldier_state_04:
	dec	OBJ_TIMER,x
	bpl	@return
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_ANIM,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	ldy	#.loword(metasprite_06B16D)
	lda	OBJ_FACING,x
	beq	@set_sprite
	ldy	#.loword(metasprite_06B427)
@set_sprite:
	sty	$00,x
@return:
	rtl

foot_soldier_state_05:
	lda	#$00C8
	cmp	OBJ_Y,x
	bcs	@fall
	sta	OBJ_Y,x
	lda	#$0001
	sta	OBJ_STATE,x
	lda	#.loword(anim_05AF9C)
	sta	OBJ_ANIM,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	rtl
@fall:
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $0B: invisible soldier spawner (stage 1 from the start): every
; soldier_spawn_delays_right[difficulty] + rnd frames a foot soldier runs in from the right
; edge, every soldier_spawn_delays_left + rnd frames one from the left, unless a big
; enemy (OBJ_FLAGS bit $0040, slots $0900-$09FF) is near that edge; some
; get HP (init_foot_soldier_with_hp), the others die at the first hit.
update_soldier_spawner:
	lda	OBJ_STATE,x
	bne	@count_right
	lda	#$0040
	sta	$32,x
	lda	#$0080
	sta	$34,x
	inc	OBJ_STATE,x
@count_right:
	dec	$32,x
	bne	@count_left
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:soldier_spawn_delays_right,y
	sta	$32,x
	ldy	#$0900
@loop:
	lda	a:$0016,y
	bit	#$0040
	beq	@next
	lda	a:$000A,y
	adc	a:$0028,y
	cmp	#$00F8
	bcs	@count_left
@next:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	@loop
	ldy	#$0300
	jsl	f:find_free_slot_from_y
	bcs	@return
	phx
	tyx
	lda	#$0110
	sta	$0A,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	lda	#$0002
	sta	$04,x
	bra	@init_soldier
@count_left:
	dec	$34,x
	bne	@return
	ldy	difficulty
	lda	rng_hi
	and	#$00FF
	adc	a:soldier_spawn_delays_left,y
	sta	$34,x
	ldy	#$0900
@loop2:
	lda	a:$0016,y
	bit	#$0040
	beq	@next2
	lda	a:$000A,y
	bmi	@return
	cmp	#$0008
	bcc	@return
@next2:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	@loop2
	ldy	#$0300
	jsl	f:find_free_slot_from_y
	bcs	@return
	phx
	tyx
	lda	#$FFF0	; [num]
	sta	$0A,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
@init_soldier:
	ldy	difficulty
	lda	rng_lo
	and	#$000F
	cmp	a:soldier_hp_odds,y
	bcs	@no_hp
	jsl	f:init_foot_soldier_with_hp
	plx
@return:
	rtl
@no_hp:
	jsl	f:foot_soldier_state_00
	plx
	rtl

; Object type $73: stage 4, on the hover-bike road before the airship: a
; jetpack soldier (seen in the emulator): flies up in an arc from below the
; screen (y $F0) trailing flame (effects), then hovers, drifting left and
; right, and fires; HP (difficulty + 1) * 2 = 2/6/10 (6 seen on NORMAL);
; dies as type $1B. Spawned by stage4_spawn_jetpack_soldier
; (update_stage4_controller, states 9-A).
update_jetpack_soldier:
	lda	a:clear_enemies_timer
	bne	@clearing
	lda	OBJ_HP,x
	bpl	@dispatch
	bmi	@die
@clearing:
	lda	$02,x
	bne	@die
	; (not executed in the CDL traces)
	lda	#$3800
	sta	$02,x
@die:
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	lda	#.loword(metasprite_06C7EA)
	jml	f:start_dying_soldier_sprite
@dispatch:
	ldy	$30,x
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_jetpack_soldier_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_jetpack_soldier_states:
	.addr	jetpack_soldier_state_00
	.addr	jetpack_soldier_state_01
	.addr	jetpack_soldier_state_02
	.addr	jetpack_soldier_state_03

jetpack_soldier_state_00:
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06C5CF)
	sta	OBJ_SPRITE,x
	lda	#$3600
	cpy	difficulty
	beq	@set_attr
	bcc	@set_attr
	lda	#$3800
@set_attr:
	sta	$02,x
	lda	#$0003
	sta	$16,x
	lda	difficulty
	inc	a
	asl	a
	sta	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFE1	; [num]
	sta	$2A,x
	lda	#$00F0
	sta	$0E,x
	stz	$32,x
	stz	$34,x
	lda	a:jetpack_soldier_y_vels,y
	sta	$1E,x
	lda	a:jetpack_soldier_x,y
	sta	$0A,x
	lda	#$0015
	jml	f:queue_sound

jetpack_soldier_state_01:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	lda	OBJ_Y_VEL,x
	bmi	@fall
	inc	OBJ_STATE,x
	lda	#$0013
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05B002)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
@fall:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	lda	stage_frame_odd
	bne	@return
	ldy	#$0700
	jsl	f:find_free_slot_y_down
	bcc	@return
	lda	#.loword(anim_05C4CE)
	jsl	f:make_effect_object
	lda	$0E,x
	adc	#$FFEC
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$FFF8	; [num]
	sta	a:$001A,y
	lda	#$0002
	sta	a:$001E,y
@return:
	rtl

jetpack_soldier_state_02:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$6000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

jetpack_soldier_state_03:
	stz	zp_00
	stz	zp_02
	lda	OBJ_Y_VEL,x
	bpl	@falling
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	@decelerate
@falling:
	lda	#$3000
	sta	$1C,x
	lda	$32,x
	bne	@count_down
	lda	$0E,x
	cmp	a:jetpack_soldier_bounce_y,y
	bcc	@decelerate
	lda	#$FFFD	; [num]
	sta	$1E,x
	lda	#$0004
	sta	zp_00
	lda	rng_hi
	and	#$003F
	adc	#$0010
	sta	$32,x
@count_down:
	dec	$32,x
@decelerate:
	sec
	lda	$18,x
	sbc	#$1000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	bpl	@set_x_vel
	cmp	#$FFFC	; [num]
	bcs	@set_x_vel
	lda	#$FFFC	; [num]
	sta	zp_02
	lda	rng_lo
	sta	$18,x
	lda	#.loword(anim_05AFFC)
	sta	$20,x
	stz	$22,x
	lda	#$0003
@set_x_vel:
	sta	$1A,x
	lda	zp_02
	ora	zp_00
	beq	@try_fire
	ldy	#$0500
	jsl	f:find_free_slot_y_down
	bcc	@try_fire
	lda	#.loword(anim_05C61E)
	jsl	f:make_effect_object
	lda	zp_02
	sta	a:$001A,y
	lda	zp_00
	sta	a:$001E,y
	lda	$0A,x
	adc	#$FFF8
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFE8
	sta	a:$000E,y
@try_fire:
	lda	difficulty
	cmp	$30,x
	bcc	@return
	lda	$34,x
	bpl	@fire_wait
	lda	$0A,x
	cmp	#$0050
	bcc	@left_side
	lda	$00,x
	cmp	#.loword(metasprite_06C80C)
	bne	@return
	lda	#$0028
	bra	@fire
@left_side:
	lda	$00,x
	cmp	#.loword(metasprite_06C5F1)
	bne	@return
	lda	#$0020
@fire:
	pha
	lda	#$0040
	sta	$34,x
	lda	$0E,x
	sta	zp_02
	lda	$0A,x
	sta	zp_00
	pla
	jml	f:spawn_enemy_bullet
@fire_wait:
	dec	$34,x
@return:
	rtl

; Object type $7E: stage 4: soldiers hanging from the airship's hull (seen in
; the emulator). The one placed by the airship spawn list (state 0, HP 128,
; field $34 = 1) swings along the hull, spawns more of them (they drop from
; the top of the screen onto the hull, state 4); killing it clears the
; others (clear_enemies_timer). The others hang,
; move towards a player, drop onto the road and run off (states 4-7). Dies as
; type $1B.
update_airship_hanging_soldier:
	lda	a:clear_enemies_timer
	bne	@die
	lda	OBJ_HP,x
	bpl	@dispatch
@die:
	lda	$34,x
	beq	@dying_soldier
	lda	#$0004
	sta	a:clear_enemies_timer
	inc	a:obj_slots+29*OBJ_SIZE+OBJ_TIMER
	inc	a:obj_slots+29*OBJ_SIZE+OBJ_TIMER
@dying_soldier:
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	lda	#.loword(metasprite_06C7EA)
	jml	f:start_dying_soldier_sound_0D
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_airship_hanging_soldier_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_airship_hanging_soldier_states:
	.addr	airship_hanging_soldier_state_00
	.addr	airship_hanging_soldier_state_01
	.addr	airship_hanging_soldier_state_02
	.addr	airship_hanging_soldier_state_03
	.addr	airship_hanging_soldier_state_04
	.addr	airship_hanging_soldier_state_05
	.addr	airship_hanging_soldier_state_06
	.addr	airship_hanging_soldier_state_07

airship_hanging_soldier_state_00:
	jsl	f:airship_hanging_soldier_state_03
	lda	#$0600
	sta	$02,x
	lda	#ENEMY_HP($0080)
	sta	$06,x
	lda	#$0018
	sta	$0A,x
	stz	$30,x
	stz	$32,x
	lda	#$0010
	sta	$36,x
	inc	$34,x
	rtl

airship_hanging_soldier_state_02:
	sec
	lda	#$0080
	sbc	a:bg1_y
	sta	OBJ_Y,x
	lda	rng_hi
	bit	#$0007
	bne	@steer
	dec	OBJ_STATE,x
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#.loword(metasprite_06C697)
	sta	OBJ_SPRITE,x
@steer:
	lda	$30,x
	bne	@accelerate_right
	lda	$1A,x
	bpl	@accelerate_left
	cmp	#$FFFD	; [num]
	bcc	airship_hanging_soldier_state_01
@accelerate_left:
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	airship_hanging_soldier_state_01
@accelerate_right:
	lda	$1A,x
	bmi	@add_right
	cmp	#$0003
	bcs	airship_hanging_soldier_state_01
@add_right:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x

airship_hanging_soldier_state_01:
	lda	OBJ_X,x
	cmp	#$00E0
	bcc	@check_left_edge
	lda	OBJ_X_VEL,x
	bpl	@reverse
	bmi	@count_down
@check_left_edge:
	cmp	#$0010
	bcs	@count_down
	lda	$1A,x
	bmi	@reverse
@count_down:
	dec	$32,x
	bpl	@spawn_timer
	bra	@new_turn_time
@reverse:
	eor	#$FFFF
	sta	$1A,x
	lda	$18,x
	eor	#$FFFF
	sta	$18,x
@new_turn_time:
	lda	rng_lo
	and	#$003F
	adc	#$0010
	sta	$32,x
	lda	$30,x
	eor	#$0002
	sta	$30,x
@spawn_timer:
	dec	$36,x
	bpl	@fall
	ldy	difficulty
	lda	rng_lo
	and	#$001F
	adc	a:airship_hanging_soldier_spawn_delays,y
	sta	$36,x
	phx
	ldx	#$06C0
	jsl	f:find_free_slot_x_down
	bcc	@no_slot
	jsl	f:airship_hanging_soldier_reset_sprite
	lda	#OBJT_AIRSHIP_HANGING_SOLDIER
	sta	$10,x
	lda	#$0004
	sta	$12,x
	lda	rng_lo
	and	#$0006
	tay
	lda	a:airship_hanging_soldier_spawn_x,y
	sta	$0A,x
@no_slot:
	plx
@fall:
	bra	airship_hanging_soldier_state_04

airship_hanging_soldier_state_03:
	inc	OBJ_STATE,x

airship_hanging_soldier_reset_sprite:
	lda	#$0001
	sta	$16,x
	lda	#.loword(metasprite_06C697)
	sta	$00,x
	lda	#$0800
	sta	$02,x
	stz	$06,x
	lda	#$0010
	sta	$28,x
	lda	#$FFD8	; [num]
	sta	$2A,x
	stz	$34,x
	rtl

airship_hanging_soldier_state_04:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	sec
	lda	#$0080
	sbc	a:bg1_y
	cmp	OBJ_Y,x
	bcs	@return
	lda	#$401F
	sta	OBJ_FLAGS,x
	lda	OBJ_ATTR,x
	ora	#$3000
	sta	OBJ_ATTR,x
	lda	#.loword(anim_05B01A)
	sta	OBJ_ANIM,x
	inc	OBJ_STATE,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
@return:
	rtl

airship_hanging_soldier_state_05:
	sec
	lda	#$0080
	sbc	a:bg1_y
	sta	OBJ_Y,x
	lda	#$0080
	jsl	f:pick_target_player
	sec
	lda	$0A,x
	sbc	a:$1312,y
	bpl	@player_left
	ldy	#$0002
	eor	#$FFFF
	bra	@check_distance
@player_left:
	ldy	#$FFFE	; [num]
@check_distance:
	cmp	#$0030
	bcs	@set_x_vel
	inc	$12,x
	stz	$20,x
	stz	$22,x
	lda	#.loword(metasprite_06C697)
	sta	$00,x
@set_x_vel:
	sty	$1A,x
	rtl

airship_hanging_soldier_state_06:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$3000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00B0
	bcc	@return
	lda	#$0003
	sta	OBJ_FLAGS,x
	inc	OBJ_STATE,x
	lda	#.loword(anim_05B01A)
	sta	OBJ_ANIM,x
	lda	#$0002
	sta	OBJ_FACING,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$FFF8	; [num]
	sta	OBJ_X_VEL,x
@return:
	rtl

airship_hanging_soldier_state_07:
	rtl

; Object type $0D: gun turret that rises out of the rubble (stage 1, HP 16;
; seen in the emulator).
update_popup_turret:
	lda	$3E,x
	bne	@destroyed
	lda	OBJ_HP,x
	bpl	@dispatch
@destroyed:
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	stz	$3E,x
	stz	$06,x
	lda	#.loword(vram_blocks_05B056)
	sta	$32,x
	lda	#$0001
	sta	$34,x
	lda	#$0003
	sta	$16,x
	lda	#$0005
	sta	$12,x
	lda	#$0020
	sta	$24,x
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_popup_turret_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_popup_turret_states:
	.addr	popup_turret_state_00
	.addr	popup_turret_state_01
	.addr	popup_turret_state_02
	.addr	popup_turret_state_03
	.addr	popup_turret_state_04
	.addr	popup_turret_state_05

popup_turret_state_00:
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#ENEMY_HP($0010)
	sta	OBJ_HP,x
	inc	OBJ_STATE,x
	rtl

popup_turret_state_01:
	lda	OBJ_X,x
	cmp	#$00E8
	bcs	@return
	lda	#.loword(vram_blocks_05B046)
	sta	$32,x
	inc	OBJ_STATE,x
@return:
	rtl

popup_turret_state_02:
	lda	stage_frame_mod8
	cmp	#$0001
	bne	@return
	jsl	f:queue_object_tiles
	lda	$32,x
	clc
	adc	#$0004
	sta	$32,x
	cmp	#.loword(vram_blocks_05B052)
	bcc	@return
	lda	#$481F
	sta	$16,x
	inc	$12,x
	lda	#$0010
	sta	$24,x
@return:
	rtl

popup_turret_state_03:
	dec	OBJ_TIMER,x
	bne	@return
	lda	#$0021
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

popup_turret_state_04:
	dec	OBJ_TIMER,x
	bne	@animate
	lda	#$0080
	sta	OBJ_TIMER,x
	dec	OBJ_STATE,x
	rtl
@animate:
	lda	$24,x
	cmp	#$0020
	beq	@fire
	cmp	#$0010
	beq	@fire
	lda	$34,x
	bne	queue_object_tiles_every_4
	inc	$34,x
	lda	#.loword(vram_blocks_05B04E)
	sta	$32,x
	bra	queue_object_tiles_every_4
@fire:
	lda	$0A,x
	sta	zp_00
	lda	#$00B8
	sta	zp_02
	lda	#$0030
	jsl	f:spawn_enemy_bullet
	lda	#$0001
	sta	$34,x
	lda	#.loword(vram_blocks_05B052)
	sta	$32,x

queue_object_tiles_every_4:
	lda	stage_frame_mod4
	cmp	#$0001
	bne	queue_object_tiles_return

; Queues the BG tiles of a BG-drawn object: field $32 = tile data, VRAM
; address object_tile_vram_addrs[field $3A] (popup turret, type $35).
queue_object_tiles:
	lda	#$0001
	sta	zp_02
	lda	#$0010
	sta	zp_08
	ldy	$3A,x
	lda	a:object_tile_vram_addrs,y
	ldy	$32,x
	phx
	jsl	f:queue_vram_blocks
	plx
	stz	$34,x
queue_object_tiles_return:
	rtl

popup_turret_state_05:
	lda	$34,x
	beq	@count_down
	jsl	f:queue_object_tiles_every_4
@count_down:
	dec	$24,x
	bne	@explosions
	lda	#$8000	; [num]
	sta	$16,x
	rtl
@explosions:
	lda	stage_frame_mod8
	bne	@return
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect
	bcs	@return
	lda	rng_hi
	and	#$001F
	adc	$0A,x
	sta	a:$000A,y
	lda	#$00C8
	sta	a:$000E,y
	lda	#$FFFF	; [num]
	sta	a:$001E,y
@return:
	rtl

; Object type $50: stage 3: wall hatch (HP 8; seen in the emulator).
update_wall_hatch:
	inc	$34,x
	lda	OBJ_HP,x
	bpl	@dispatch
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#.loword(anim_05C516)
	jsl	f:make_effect_object
	lda	$0A,x
	adc	#$0008
	sta	$0A,x
	lda	$0E,x
	adc	#$FFF8
	sta	$0E,x
	lda	#$69C0
	sta	zp_00
	lda	$3A,x
	jml	f:queue_vram_block
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_wall_hatch_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_wall_hatch_states:
	.addr	wall_hatch_state_00
	.addr	wall_hatch_state_01
	.addr	wall_hatch_state_02
	.addr	wall_hatch_state_03
	.addr	wall_hatch_state_02
	.addr	wall_hatch_state_05

wall_hatch_state_00:
	inc	OBJ_STATE,x
	ldy	difficulty
	lda	a:wall_hatch_hp,y
	sta	OBJ_HP,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#$0015
	sta	OBJ_TIMER,x
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	$3A,x
	and	#$F7FF
	sta	$3A,x
	stz	$30,x
	rtl

wall_hatch_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0003
	bne	@check_mode_1
	lda	OBJ_Y,x
	bmi	@return
	cmp	#$0020
	bcs	@open
	rtl
@check_mode_1:
	cmp	#$0001
	bne	@return
	lda	$0A,x
	cmp	#$00E0
	bcs	@return
@open:
	inc	$12,x
@return:
	rtl

wall_hatch_state_02:
	dec	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	bpl	@animate
	inc	OBJ_STATE,x
	lda	#$0030
	sta	$34,x
	lda	#$4013
	sta	OBJ_FLAGS,x
	rtl
@animate:
	bit	#$0007
	bne	@return
	lsr	a
	lsr	a
	tay
	lda	$12,x
	cmp	#$0002
	beq	@opening
	lda	a:wall_hatch_close_tiles,y
	bra	@queue
@opening:
	lda	a:wall_hatch_open_tiles,y
@queue:
	sta	zp_00
	lda	$3A,x
	jsl	f:queue_vram_block
@return:
	rtl

wall_hatch_state_03:
	lda	a:bg1_scroll_mode
	cmp	#$0003
	bne	@check_mode_1
	lda	OBJ_Y,x
	cmp	#$00C0
	bcc	@aim
	bcs	@close
@check_mode_1:
	cmp	#$0001
	bne	@aim
	lda	$0A,x
	cmp	#$0020
	bcs	@aim
@close:
	lda	#$0015
	sta	$24,x
	lda	#$0003
	sta	$16,x
	inc	$12,x
	rtl
@aim:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:wall_hatch_turn_masks,y
	bne	@draw
	lda	#$0800
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	and	#$003E
	sec
	sbc	$30,x
	bmi	@diff_negative
	cmp	#$001E
	bcs	@dec_angle
	cmp	#$0002
	bcc	@draw
@inc_angle:
	lda	$30,x
	inc	a
	inc	a
	bra	@set_angle
@diff_negative:
	cmp	#$FFE2	; [num]
	bcc	@inc_angle
	cmp	#$FFFE	; [num]
	bcs	@draw
@dec_angle:
	lda	$30,x
	dec	a
	dec	a
@set_angle:
	and	#$003E
	sta	$30,x
@draw:
	lda	$30,x
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$000E
	tay
	lda	a:wall_hatch_aim_tiles,y
	sta	zp_00
	lda	$3A,x
	sty	zp_FE
	jsl	f:queue_vram_block
	lda	$34,x
	and	#$007F
	bne	@return
	ldy	zp_FE
	clc
	lda	$0A,x
	adc	a:wall_hatch_muzzle_x,y
	sta	zp_00
	clc
	lda	$0E,x
	adc	a:wall_hatch_muzzle_y,y
	sta	zp_02
	lda	$30,x
	jsl	f:spawn_enemy_bullet
@return:
	rtl

wall_hatch_state_05:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Object type $04 (also the entry of type $54, which nothing creates): the
; armored barricade blocking the street in stage 1 (section 4, twice; seen
; in the emulator). Solid. When the scroll stops (type $08) it creates its
; core (type $14, slot 27) and two cannons (type $15, slots 25-26); when
; the core is destroyed it deletes them, kills a window sniper (type $17),
; collapses (tile blocks, explosions, shake) and the scroll resumes.
update_barricade:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_barricade_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_barricade_states:
	.addr	barricade_state_00
	.addr	barricade_state_01
	.addr	barricade_state_02
	.addr	barricade_state_03
	.addr	barricade_state_04
	.addr	barricade_state_05

barricade_state_00:
	lda	#$0041
	sta	OBJ_FLAGS,x
	lda	#$0060
	sta	OBJ_HITBOX_W,x
	lda	#$FF10	; [num]
	sta	OBJ_HITBOX_H,x
	inc	OBJ_STATE,x
barricade_return:
	rtl

barricade_state_01:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	barricade_return
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	#$0000
	lda	#$2002
@loop:
	sta	a:$4670,y
	iny
	iny
	cpy	#$0010
	bcc	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	inc	$12,x
	lda	#OBJT_BARRICADE_CORE
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_TYPE
	lda	#$4010
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_FLAGS
	lda	#$00C0
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_X
	lda	#$00B0
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_Y
	lda	#$0010
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_HITBOX_W
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_HITBOX_W
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFF0	; [num]
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_HITBOX_H
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_HITBOX_H
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_HITBOX_H
	lda	#ENEMY_HP($0040)
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_HP
	lda	#OBJT_BARRICADE_CANNON
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_TYPE
	lda	#$00A8
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_X
	lda	#$00C8
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_X
	lda	#$0080
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_Y
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_Y
	lda	#ENEMY_HP($0028)
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_HP
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_HP
	lda	#$4194
	sta	a:obj_slots+25*OBJ_SIZE+$30
	lda	#$4198
	sta	a:obj_slots+26*OBJ_SIZE+$30
	lda	#$7480
	sta	a:obj_slots+25*OBJ_SIZE+$32
	lda	#$7560
	sta	a:obj_slots+25*OBJ_SIZE+$34
	lda	#$7600
	sta	a:obj_slots+25*OBJ_SIZE+$36
	lda	#$74A0
	sta	a:obj_slots+26*OBJ_SIZE+$32
	lda	#$75E0
	sta	a:obj_slots+26*OBJ_SIZE+$34
	lda	#$7620
	sta	a:obj_slots+26*OBJ_SIZE+$36
	lda	#$0000
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_TIMER
	lda	#$0018
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_TIMER
	stz	a:obj_slots+27*OBJ_SIZE+OBJ_SPRITE
	stz	a:obj_slots+25*OBJ_SIZE+OBJ_SPRITE
	stz	a:obj_slots+26*OBJ_SIZE+OBJ_SPRITE
	stz	a:obj_slots+27*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+25*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+26*OBJ_SIZE+OBJ_ANIM
	stz	a:obj_slots+25*OBJ_SIZE+OBJ_STATE
	stz	a:obj_slots+26*OBJ_SIZE+OBJ_STATE
	rtl

barricade_state_02:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	a:obj_slots+27*OBJ_SIZE+OBJ_HP
	bpl	@return
	lda	#$8000	; [num]
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+25*OBJ_SIZE+OBJ_FLAGS
	sta	a:obj_slots+26*OBJ_SIZE+OBJ_FLAGS
	inc	$12,x
@return:
	rtl

barricade_state_03:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	#.loword(vram_blocks_05B0A0)
	sta	$30,x
	lda	#$0044
	jsl	f:queue_sound
	inc	$12,x
	ldy	#$0300
@loop:
	lda	a:$0010,y
	cmp	#OBJT_WINDOW_SNIPER
	beq	@kill_type_17
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0740
	bcc	@loop
	rtl
@kill_type_17:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	a:$0006,y
	rtl

barricade_state_04:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	stage_frame_counter
	and	#$000F
	bne	@return
	inc	$12,x
@return:
	rtl

barricade_state_05:
	lda	#$0004
	sta	a:shake_timer
	jsl	f:solid_object_vs_players_and_soldiers
	lda	stage_frame_odd
	bne	@queue_tiles
	lda	#$00A0
	sta	zp_00
	lda	#$00D8
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	@queue_tiles
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@queue_tiles:
	stx	zp_FA
	lda	#$0030
	sta	zp_08
	lda	stage_frame_counter
	and	#$000F
	cmp	#$0004
	bcs	barricade_collapse_wait
	phx
	asl	a
	tax
	lda	f:tbl_barricade_collapse_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_barricade_collapse_steps:
	.addr	barricade_collapse_wait
	.addr	barricade_collapse_step_1
	.addr	barricade_collapse_step_2
	.addr	barricade_collapse_step_3

barricade_collapse_step_1:
	stz	zp_00
	stz	zp_0C
	bra	barricade_collapse_queue

barricade_collapse_step_2:
	lda	#$0100
	sta	zp_0C
	lda	#$000C
	sta	zp_00
	bra	barricade_collapse_queue

barricade_collapse_step_3:
	lda	#$0200
	sta	zp_0C
	lda	#$0018
	sta	zp_00
	lda	#$0018
	sta	zp_08
barricade_collapse_queue:
	lda	#$0003
	sta	zp_02
	clc
	lda	$30,x
	adc	zp_00
	tay
	clc
	lda	#$4114
	adc	zp_0C
	jsl	f:queue_vram_blocks
	ldx	zp_FA
	lda	stage_frame_counter
	and	#$000F
	cmp	#$0002
	bne	barricade_collapse_wait
	clc
	lda	$30,x
	adc	#$001E
	sta	$30,x
	cmp	#.loword(vram_blocks_05B0A0 + $D2)
	bcc	barricade_collapse_wait
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0001
	sta	a:bg1_scroll_mode

barricade_collapse_wait:
	rtl

; Object type $14: the barricade's core (the red light at its foot, slot
; 27, HP 64; seen in the emulator), made by update_barricade; flashes its
; palette when hit. Destroying it brings the barricade down.
update_barricade_core:
	lda	OBJ_SAVED_ATTR,x
	beq	@return
	lda	#.loword(palette_05914A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
@return:
	rtl

; Object type $15: a cannon on the barricade (slots 25-26, HP 40; seen in
; the emulator), made by update_barricade: every $28 frames swaps its tile
; and lobs a cannonball (type $16); destroyed: a burst of explosions.
update_barricade_cannon:
	lda	OBJ_STATE,x
	beq	@alive
	lda	stage_frame_mod4
	bne	@return
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	lda	#$000F
	sta	zp_04
	lda	#$000F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	dec	$24,x
	bne	@return
	lda	#$8000	; [num]
	sta	$16,x
@return:
	rtl
@alive:
	lda	$06,x
	bpl	@animate
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	inc	$12,x
	lda	#$0008
	sta	$24,x
	lda	$36,x
	bra	@queue_tile
@animate:
	inc	$24,x
	lda	$24,x
	cmp	#$0028
	bne	@check_drop
	stz	$24,x
	lda	$32,x
	bra	@queue_tile
@check_drop:
	cmp	#$0020
	bcc	@return2
	bne	@return2
	phx
	ldx	#$03C0
	jsl	f:find_free_slot_from_x
	ply
	bcs	@return2
	lda	#OBJT_BARRICADE_CANNONBALL
	sta	$10,x
	lda	#$3E00
	sta	$02,x
	lda	#.loword(metasprite_06B40D)
	sta	$00,x
	lda	#$180F
	sta	$16,x
	lda	rng_lo
	and	#$0001
	adc	#$FFFE
	sta	$1A,x
	lda	#$4000
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8	; [num]
	sta	$2A,x
	lda	a:$000A,y
	adc	#$FFF8
	sta	$0A,x
	lda	a:$000E,y
	adc	#$FFF8
	sta	$0E,x
	tyx
	lda	$34,x
@queue_tile:
	sta	zp_00
	lda	$30,x
	jsl	f:queue_vram_block
@return2:
	rtl

; Object type $16: cannonball lobbed by a barricade cannon (type $15; seen
; in the emulator): falls with gravity and explodes on the floor or on
; contact.
update_barricade_cannonball:
	lda	OBJ_TOUCHED_BY,x
	bne	@explode
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	@return
@explode:
	lda	#$FFFF	; [num]
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@return:
	rtl

; Object type $0F: flying weapon capsule: shot down, it drops a falcon
; weapon item (all side-view stages; seen in the emulator).
update_weapon_capsule:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_weapon_capsule_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_weapon_capsule_states:
	.addr	weapon_capsule_state_00
	.addr	weapon_capsule_state_01
	.addr	weapon_capsule_state_02
	.addr	weapon_capsule_state_03
	.addr	weapon_capsule_state_04

weapon_capsule_state_00:
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFF0	; [num]
	sta	OBJ_HITBOX_H,x
	inc	OBJ_STATE,x
	lda	$3E,x
	beq	@flying
	jsr	a:weapon_capsule_set_kind
	rtl
@flying:
	lda	#$0012
	sta	$16,x
	lda	#.loword(anim_05B172)
	sta	$20,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	lda	$0E,x
	sta	$34,x
	lda	$0A,x
	bpl	@from_right
	lda	#$FFF0	; [num]
	sta	$0A,x
	lda	#$0002
	sta	$1A,x
	rtl
@from_right:
	lda	#$0100
	sta	$0A,x
	lda	#$FFFD	; [num]
	sta	$1A,x
	rtl

weapon_capsule_state_01:
	jsr	a:weapon_capsule_check_shot
	lda	$34,x
	cmp	$0E,x
	bcc	@accel_up
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	@move
@accel_up:
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
@move:
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	clc
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	rtl

weapon_capsule_state_02:
	ldy	OBJ_TOUCHED_BY,x
	beq	@not_touched
	lda	#SOUND_WEAPON_PICKUP
	jsl	f:queue_sound
	lda	#$8000	; [num]
	sta	$16,x
	lda	a:$1D82,y
	bne	@weapon_2
	lda	$3A,x
	sta	a:$1D84,y
	lda	#$0000
	sta	a:$0036,y
	rtl
@weapon_2:
	lda	$3A,x
	sta	a:$1D86,y
	lda	#$0000
	sta	a:$0034,y
	rtl
@not_touched:
	brl	weapon_item_move

weapon_capsule_state_03:
	ldy	OBJ_TOUCHED_BY,x
	beq	@not_touched
	lda	#SOUND_WEAPON_PICKUP
	jsl	f:queue_sound
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0200
	sta	a:$1D88,y
@not_touched:
	brl	weapon_item_move

weapon_capsule_state_04:
	ldy	#$3E00
	lda	stage_frame_odd
	bne	@set_attr
	ldy	#$3200
@set_attr:
	sty	$02,x
	ldy	$3C,x
	beq	@not_touched
	lda	#$8000	; [num]
	sta	$16,x
	lda	#SOUND_WEAPON_PICKUP
	jsl	f:queue_sound
	lda	a:$1D8C,y
	inc	a
	cmp	#$0009
	bcc	@set_bombs
	; (not executed in the CDL traces)
	lda	#$0009
@set_bombs:
	sta	a:$1D8C,y
@not_touched:
	brl	weapon_item_move
; Common end of the item states 2-4 (weapon, barrier, bombs): blinks out
; when field $36 runs low, lands on the floor (weapon_item_stage4 in
; stage 4), weapon_item_gravity.
weapon_item_move:
	lda	$3E,x
	beq	@timer
	lda	$0E,x
	cmp	#$00C0
	bcs	@explode
	brl	weapon_item_gravity
@explode:
	lda	#$FFFE	; [num]
	sta	$1E,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
@timer:
	dec	$36,x
	bne	@check_blink
	lda	#$8000	; [num]
	sta	$16,x
	rtl
@check_blink:
	lda	$36,x
	cmp	#$0030
	bcs	@check_stage
	lda	stage_frame_odd
	beq	@show
	stz	$00,x
	bra	@check_stage
@show:
	lda	$38,x
	sta	$00,x
@check_stage:
	lda	stage_number
	cmp	#$0004
	bne	@check_floor
	brl	weapon_item_stage4
@check_floor:
	stz	zp_00
	lda	$1E,x
	bmi	@rising
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	and	#TILE_FLOOR_MASK
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_FLOOR_MASK
	beq	@right_clear
	lda	zp_04
	beq	@fall
	brl	stop_and_snap_y_up_to_tile
@right_clear:
	lda	zp_04
	beq	@fall
@fall:
	bra	weapon_item_gravity
@rising:
	lda	#$FFF0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	and	#TILE_CEILING_MASK
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CEILING_MASK
	beq	@right_clear2
	lda	zp_04
	beq	@fall2
	jsl	f:snap_y_down_to_tile
@fall2:
	bra	weapon_item_gravity
@right_clear2:
	lda	zp_04
	beq	weapon_item_gravity
weapon_item_gravity:
	clc
	lda	$1C,x
	adc	#$2000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

weapon_capsule_check_shot:
	lda	$06,x
	bpl	weapon_capsule_return
	stz	$18,x
	stz	$1A,x

; Sprite (weapon_capsule_kind_sprites) and state offset (weapon_capsule_kind_states) from the kind in field
; $3A, then flies (y velocity -2).
weapon_capsule_set_kind:
	stz	$20,x
	stz	$22,x
	lda	$3A,x
	asl	a
	tay
	lda	a:weapon_capsule_kind_sprites,y
	sta	$00,x
	sta	$38,x
	clc
	lda	a:weapon_capsule_kind_states,y
	adc	$12,x
	sta	$12,x
	cmp	#$0003
	bne	@set_timer
	lda	#$3000
	sta	$02,x
@set_timer:
	lda	#$0200
	sta	$36,x
	stz	$1C,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	lda	#$000B
	sta	$16,x
weapon_capsule_return:
	rts
weapon_item_stage4:
	lda	$0E,x
	cmp	#$00B4
	bcs	@on_floor
	brl	weapon_item_gravity
@on_floor:
	lda	a:respawn_mode
	cmp	#$0005
	bcs	@stop
	; (not executed in the CDL traces)
	brl	weapon_item_gravity
@stop:
	stz	$1C,x
	stz	$1E,x
	sec
	lda	$0A,x
	sbc	#$0008
	sta	$0A,x
	rtl

; Object type $11: the wrecked car at the start of stage 1 (HP 16; seen in
; the emulator). Solid (players and soldiers stand on it); destroyed: it
; explodes into bouncing debris (type $10) and keeps burning.
update_wrecked_car:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_wrecked_car_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_wrecked_car_states:
	.addr	wrecked_car_state_00
	.addr	wrecked_car_state_01
	.addr	wrecked_car_state_02

wrecked_car_state_00:
	lda	#.loword(metasprite_06B374)
	sta	OBJ_SPRITE,x
	lda	#$4013
	sta	OBJ_FLAGS,x
	lda	#$3E00
	sta	OBJ_ATTR,x
	lda	#$0080
	sta	$30,x
	lda	#$0200
	sta	$34,x
	lda	#$0400
	sta	$36,x
	lda	#ENEMY_HP($0010)
	sta	OBJ_HP,x
	lda	#$FFD8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0034
	sta	OBJ_HITBOX_W,x
	inc	OBJ_STATE,x
	rtl
wrecked_car_solid:
	jml	f:solid_object_vs_players_and_soldiers

wrecked_car_state_01:
	lda	OBJ_HP,x
	bpl	wrecked_car_solid
	lda	#SOUND_VEHICLE_EXPLODE
	jsl	f:queue_sound
	inc	$12,x
	lda	#$0003
	sta	$16,x
	lda	#.loword(metasprite_06B3C1)
	sta	$00,x
	sta	$32,x
	lda	#$FFFB	; [num]
	sta	$30,x
	sta	$1E,x
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	lda	#$0060
	sta	$24,x
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	phx
	ldy	#$000A
	ldx	#$0300
@loop:
	lda	$10,x
	beq	@spawn_debris
@next:
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0780
	bcc	@loop
	; (not executed in the CDL traces)
	plx
	rtl
@spawn_debris:
	lda	a:wrecked_car_debris_sprites,y
	sta	$00,x
	sta	$32,x
	lda	#$0003
	sta	$16,x
	lda	#OBJT_BOUNCING_DEBRIS
	sta	$10,x
	lda	#$3E00
	sta	$02,x
	lda	#$0040
	sta	$24,x
	lda	zp_00
	sta	$0A,x
	lda	zp_02
	sta	$0E,x
	lda	a:wrecked_car_debris_y_vels,y
	sta	$1E,x
	sta	$30,x
	lda	a:wrecked_car_debris_x_vels,y
	sta	$1A,x
	dey
	dey
	bne	@next
	plx
	rtl

wrecked_car_state_02:
	lda	stage_frame_odd
	bne	@debris
	lda	OBJ_X,x
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	lda	#$003F
	sta	zp_04
	lda	#$001F
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	update_bouncing_debris
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	bra	update_bouncing_debris
@debris:
	lda	stage_frame_mod8
	bne	update_bouncing_debris
	; (not executed in the CDL traces)
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	update_bouncing_debris
	lda	#OBJT_BOUNCING_DEBRIS
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	rng_lo
	and	#$003F
	adc	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	adc	#$0000
	sta	a:$000E,y
	lda	#$0018
	sta	a:$0024,y
	lda	#$3400
	sta	a:$0002,y
	lda	#$FFFC	; [num]
	sta	a:$0030,y
	lda	#.loword(metasprite_06B1EB)
	sta	a:$0000,y
	sta	a:$0032,y
	lda	#$8000	; [num]
	sta	a:$0018,y
	lda	rng_hi
	bmi	@drift_left
	bra	update_bouncing_debris
@drift_left:
	lda	a:$001A,y
	dec	a
	sta	a:$001A,y

; Object type $10: debris that falls, bounces off the floor
; (get_bg_tile_at_object) and blinks out (stage 1, the wrecked car).
update_bouncing_debris:
	dec	OBJ_TIMER,x
	bne	@check_blink
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@check_blink:
	lda	$24,x
	cmp	#$0010
	bcs	@check_floor
	lda	stage_frame_odd
	bne	@show
	stz	$00,x
	bra	@check_floor
@show:
	lda	$32,x
	sta	$00,x
@check_floor:
	lda	$1E,x
	bmi	@gravity
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@gravity
	jsl	f:snap_y_up_to_tile
	lda	$30,x
	beq	@stop
	inc	a
	sta	$30,x
	sta	$1E,x
@gravity:
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
@stop:
	; (not executed in the CDL traces)
	stz	$1C,x
	rtl

; Object type $43: stage 3 section 9: the grey wall closing the way into the
; building (seen in the emulator), solid for the players, HP 64. Destroyed: an
; explosion burst, BG blocks erase it and the scroll resumes
; (bg1_scroll_mode 1).
update_stage3_breakable_wall:
	lda	OBJ_STATE,x
	bne	@active
	inc	OBJ_STATE,x
	lda	#$4071
	sta	OBJ_FLAGS,x
	lda	#$FF00	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$0020
	sta	OBJ_HITBOX_W,x
	lda	#ENEMY_HP($0040)
	sta	OBJ_HP,x
	rtl
@active:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@solid
	lda	#$4051
	sta	$16,x
@solid:
	jsl	f:solid_object_vs_players
	lda	$06,x
	bpl	@flash
	lda	#SOUND_BIG_EXPLOSION
	jsl	f:queue_sound
	lda	#$0005
	sta	a:shake_timer
	lda	#$00FF
	sta	zp_FA
	lda	#$0078
	sta	zp_FE
	lda	#$0004
	sta	zp_08
	lda	#$2208
	jsl	f:spawn_explosion_burst
	lda	#$0001
	sta	zp_02
	lda	#$0020
	sta	zp_08
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	clc
	adc	#$411C
	ldy	#.loword(vram_blocks_05B1C0)
	phx
	jsl	f:queue_vram_blocks
	plx
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0001
	sta	a:bg1_scroll_mode
	rtl
@flash:
	lda	$26,x
	beq	@return
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0030
	sta	cgram_upload_addr
@return:
	rtl

; Object type $12: soldier throwing grenades (stage 1, HP 6 on NORMAL; seen
; in the emulator): stands facing the nearest player, winds up and throws a
; grenade (type $13) with a speed by the distance; killed: type $1B.
update_grenade_soldier:
	jsr	a:grenade_soldier_aim_at_nearest_player
	lda	$06,x
	bpl	@dispatch
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_grenade_soldier_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_grenade_soldier_states:
	.addr	grenade_soldier_state_00
	.addr	grenade_soldier_state_01
	.addr	grenade_soldier_state_02
	.addr	grenade_soldier_state_03
	.addr	grenade_soldier_state_02
	.addr	grenade_soldier_state_05
	.addr	grenade_soldier_state_02
	.addr	grenade_soldier_state_01

grenade_soldier_state_00:
	lda	#$3400
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	stz	OBJ_ANIM,x
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	ldy	difficulty
	lda	a:grenade_soldier_hp,y
	sta	OBJ_HP,x
	inc	OBJ_STATE,x

grenade_soldier_state_01:
	ldy	OBJ_FACING,x
	lda	a:grenade_soldier_idle_sprites,y
	sta	OBJ_SPRITE,x
	ldy	difficulty
	lda	a:grenade_soldier_wait_times,y
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x
	rtl

grenade_soldier_state_02:
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
@return:
	rtl

grenade_soldier_state_03:
	ldy	OBJ_FACING,x
	lda	a:grenade_soldier_windup_sprites,y
	sta	OBJ_SPRITE,x
	lda	#$000C
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#SOUND_THROW
	jml	f:queue_sound

grenade_soldier_state_05:
	jsl	f:find_free_slot_y
	bcs	@no_slot
	lda	#OBJT_GRENADE
	sta	a:$0010,y
	lda	$0A,x
	clc
	phy
	ldy	$04,x
	adc	a:grenade_soldier_grenade_x_offsets,y
	ply
	sta	a:$000A,y
	lda	$04,x
	sta	a:$0004,y
	lda	$0E,x
	clc
	adc	#$FFE0
	sta	a:$000E,y
	phx
	tyx
	lda	zp_1E
	lsr	a
	lsr	a
	and	#$003C
	ora	$04,x
	tay
	lda	a:grenade_soldier_grenade_x_vels,y
	sta	$1A,x
	lda	a:grenade_soldier_grenade_x_vel_subs,y
	sta	$18,x
	lda	#$FFFA	; [num]
	sta	$1E,x
	stz	$1C,x
	plx
	ldy	$04,x
	lda	a:grenade_soldier_throw_sprites,y
	sta	$00,x
	lda	#$0010
	sta	$24,x
	lda	#$0006
	sta	$12,x
	rtl
@no_slot:
	; (not executed in the CDL traces)
	ldy	$04,x
	lda	a:grenade_soldier_idle_sprites,y
	sta	$00,x
	lda	#$000C
	sta	$24,x
	lda	#$0002
	sta	$12,x
	rtl

grenade_soldier_aim_at_nearest_player:
	lda	a:p1_lives
	ora	a:p2_lives
	beq	@return
	lda	a:p1_lives
	beq	@check_p2
	ldy	#$0200
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_18
	bpl	@p1_dist
	eor	#$FFFF
	inc	a
@p1_dist:
	sta	zp_1C
@check_p2:
	lda	a:p2_lives
	beq	@nearest_p1
	ldy	#$0240
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_1A
	bpl	@p2_dist
	eor	#$FFFF
	inc	a
@p2_dist:
	sta	zp_1E
	ldy	#$0002
	cmp	zp_1C
	bcc	@face_player
@nearest_p1:
	lda	zp_1C
	sta	zp_1E
	ldy	#$0000
@face_player:
	lda	$12,x
	cmp	#$0003
	bcc	@set_facing
	cmp	#$0007
	bcc	@return
@set_facing:
	stz	$04,x
	lda	a:$0018,y
	bpl	@return
	lda	#$0002
	sta	$04,x
@return:
	rts

; Object type $13: grenade/shell thrown by soldiers: explodes into type $1A
; when it touches a player or a solid BG tile (bit $2000).
update_grenade:
	lda	OBJ_STATE,x
	bne	@flying
	lda	#$3000
	sta	OBJ_ATTR,x
	lda	#$180D
	sta	OBJ_FLAGS,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#.loword(anim_05B284)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	inc	OBJ_STATE,x
	rtl
@flying:
	lda	$3C,x
	bne	@explode
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_NO_DROP
	beq	@fall
; Bug: x + 8 and y - $10 are computed but never stored (the second lda of
; each pair was probably meant as sta), so the blast starts at the grenade.
@explode:
	lda	#OBJT_GRENADE_BLAST
	sta	$10,x
	lda	$0A,x
	clc
	adc	#$0008
	lda	$0A,x
	lda	$0E,x
	sec
	sbc	#$0010
	lda	$0E,x
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	jml	f:start_grenade_blast
@fall:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	bcc	@return
	inc	$1E,x
	lda	$1E,x
	cmp	#$0006
	bmi	@return
	lda	#$0006
	sta	$1E,x
	stz	$1C,x
@return:
	rtl

; Object type $17: sniper in a window (stage 1 and 3, HP 6; seen in the
; emulator).
update_window_sniper:
	lda	OBJ_STATE,x
	cmp	#$0003
	bcs	@check_hp
	jsr	a:window_sniper_aim_at_nearest_player
	jsl	f:window_sniper_set_aim_sprite
@check_hp:
	lda	$06,x
	bpl	@dispatch
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
@dispatch:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_window_sniper_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_window_sniper_states:
	.addr	window_sniper_state_00
	.addr	window_sniper_state_01
	.addr	window_sniper_state_02
	.addr	window_sniper_state_03
	.addr	window_sniper_state_02
	.addr	window_sniper_state_01

window_sniper_state_00:
	lda	#$2600
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
	lda	#$001F
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	ldy	difficulty
	lda	a:window_sniper_hp,y
	sta	OBJ_HP,x
	inc	OBJ_STATE,x

window_sniper_state_01:
	ldy	difficulty
	lda	a:window_sniper_fire_delays,y
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x
	rtl

window_sniper_state_02:
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
@return:
	rtl

window_sniper_state_03:
	lda	OBJ_X,x
	sta	zp_18
	lda	OBJ_Y,x
	sta	zp_1A
	lda	$34,x
	sta	zp_1C
	phx
	lda	$32,x
	tax
	lda	zp_18
	clc
	adc	a:window_sniper_muzzle_x,x
	sta	zp_00
	lda	zp_1A
	clc
	adc	a:window_sniper_muzzle_y,x
	sta	zp_02
	lda	zp_1C
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	plx
	jsl	f:spawn_enemy_bullet
	bcc	@return
	jsl	f:window_sniper_set_fire_sprite
	lda	#$0010
	sta	$24,x
	lda	#$0004
	sta	$12,x
@return:
	rtl

; Picks the nearer player (x distance) and the aim direction to it (field
; $32).
window_sniper_aim_at_nearest_player:
	lda	#$FFFF	; [num]
	sta	zp_1C
	sta	zp_1E
	lda	a:player1_obj+OBJ_FLAGS
	beq	@check_p2
	sec
	lda	a:player1_obj+OBJ_X
	sbc	$0A,x
	sta	zp_18
	bpl	@p1_dist
	eor	#$FFFF
	inc	a
@p1_dist:
	sta	zp_1C
@check_p2:
	lda	a:player2_obj+OBJ_FLAGS
	beq	@compare
	sec
	lda	a:player2_obj+OBJ_X
	sbc	$0A,x
	sta	zp_1A
	bpl	@p2_dist
	eor	#$FFFF
	inc	a
@p2_dist:
	sta	zp_1E
@compare:
	ldy	#$0000
	lda	zp_1E
	cmp	zp_1C
	bne	@pick_nearest
	cmp	#$FFFF	; [num]
	beq	@return
@pick_nearest:
	bcs	@set_target
	ldy	#$0002
@set_target:
	lda	a:window_sniper_player_slots,y
	sta	$30,x
	stz	$04,x
	lda	a:$0018,y
	bpl	@aim
	lda	#$0002
	sta	$04,x
@aim:
	ldy	$30,x
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sta	$34,x
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	ora	$04,x
	sta	$32,x
@return:
	rts

window_sniper_set_aim_sprite:
	ldy	$32,x
	lda	a:window_sniper_aim_sprites,y
	sta	$00,x
	rtl

window_sniper_set_fire_sprite:
	ldy	$32,x
	lda	a:window_sniper_fire_sprites,y
	sta	$00,x
	rtl

; Effects (type $1D, update_effect): spawn_effect finds a free slot from Y
; (up to $08C0) and makes it an effect playing animation A; carry set when
; there is none. spawn_effect_random_offset also places it at
; (zp_00 + rnd & zp_04, zp_02 - rnd & zp_06). make_effect_object turns the
; slot at Y (often the object itself, txy) into an effect playing animation A.
spawn_effect:
	pha
@loop:
	lda	a:$0010,y
	beq	@found
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	pla
	rtl
@found:
	clc
	pla
	bra	make_effect_object

spawn_effect_random_offset:
	pha
@loop:
	lda	a:$0010,y
	beq	@found
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	pla
	rtl
@found:
	lda	rng_lo
	and	zp_04
	adc	zp_00
	sta	a:$000A,y
	lda	rng_hi
	and	zp_06
	eor	#$FFFF
	adc	zp_02
	sta	a:$000E,y
	clc
	pla

make_effect_object:
	sta	a:$0020,y
	lda	#$0003
	sta	a:$0016,y
	lda	#OBJT_EFFECT
	sta	a:$0010,y
	lda	#.loword(metasprite_06AEA0)
	sta	a:$0000,y
	lda	#$3200
	sta	a:$0002,y
	lda	#$0000
	sta	a:$0022,y
	sta	a:$0004,y
	rtl
