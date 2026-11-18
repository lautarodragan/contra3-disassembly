; objects/player_weapons.asm -- Player states (and the spin/bomb buttons)
; Bank $01, $01:8000-$01:9E43. Included by main.asm in segment BANK01.
;
; Despite the file name, most of this is the players' state handlers
; (tbl_player_states in objects/player.asm): ground, jump, fall, hang,
; climb, death and respawn, each with its aim table (tbl_ground_aim...)
; whose entries set the pose and call fire_weapon with the shot angle in
; zp_12 ($00 up, $20 right, $40 down, $60 left; $80 per turn) and the
; muzzle offset in zp_14/zp_16.  Also: the spin and bomb buttons
; (update_spin_flag, check_bomb_button), the player frame upload
; (set_player_frame), tile snapping used by every object
; (snap_y_up_to_tile...), unused debug code (debug_color_math_keys, debug_window_keys), and
; the handler of object type 109 (update_player_bike).

; PLAYER_SPIN = 1 while L and R are both held or the player is in the spin
; jump (state $0C), else 0.  In: X = player.
update_spin_flag:
	.a16
	.i16
	stz	a:PLAYER_SPIN,x
	lda	OBJ_STATE,x
	cmp	#$000C
	beq	@spinning
	lda	PLAYER_JOY_HELD,x
	and	#$0030
	beq	@return
	cmp	#$0030
	beq	@spinning
@return:
	rtl
@spinning:
	inc	a:PLAYER_SPIN,x
	rtl

; If button_bomb was pressed, no bomb of this player is active and
; PLAYER_BOMBS > 0: uses a bomb and starts the blast at PLAYER_CENTER_X/Y
; (PLAYER_BOMB_RADIUS = 1, speed 1), sound $5A.  In: X = player.
check_bomb_button:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_bomb
	beq	@return
	lda	a:PLAYER_BOMB_RADIUS,x
	bne	@return
	lda	a:PLAYER_BOMBS,x
	beq	@return
	inc	a:PLAYER_BOMB_RADIUS,x
.if !CHEAT_INFINITE_BOMBS
	dec	a:PLAYER_BOMBS,x
.endif
	stz	a:PLAYER_BOMB_SPEED_SUB,x
	lda	#$0001
	sta	a:PLAYER_BOMB_SPEED,x
	lda	a:PLAYER_CENTER_X,x
	sta	a:PLAYER_BOMB_X,x
	lda	a:PLAYER_CENTER_Y,x
	sta	a:PLAYER_BOMB_Y,x
	lda	#SOUND_SMART_BOMB
	jsl	f:queue_sound
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; While Y ($4000) is held, mosaic_shadow alternates $12 / 0 every frame.
; Never reached (a leftover test, probably).
unused_mosaic_flicker_on_y:
	; (not executed in the CDL traces)
	lda	PLAYER_JOY_HELD,x
	bit	#$4000
	beq	@return
	ldy	#$0012
	lda	stage_frame_odd
	beq	@set_mosaic
	ldy	#$0000
@set_mosaic:
	sty	a:mosaic_shadow
@return:
	rtl

; Looks up the player's frame (PLAYER_POSE + PLAYER_POSE_ADD + $38, 16
; bytes per frame at player_frames): six VRAM source addresses for the
; player's tiles ($1780-$1796, uploaded by the NMI) and the metasprite of
; each facing (OBJ_SPRITE).  Clears $38.  In: X = player.
set_player_frame:
	lda	PLAYER_POSE,x
	clc
	adc	a:PLAYER_POSE_ADD,x
	clc
	adc	$38,x
	asl	a
	asl	a
	asl	a
	asl	a
	tay
	lda	a:player_frames,y
	sta	a:player_tile_src
	clc
	adc	#$0200
	sta	a:player_tile_src+12
	lda	a:player_frames+2,y
	sta	a:player_tile_src+2
	clc
	adc	#$0200
	sta	a:player_tile_src+14
	lda	a:player_frames+4,y
	sta	a:player_tile_src+4
	clc
	adc	#$0200
	sta	a:player_tile_src+16
	lda	a:player_frames+6,y
	sta	a:player_tile_src+6
	clc
	adc	#$0200
	sta	a:player_tile_src+18
	lda	a:player_frames+8,y
	sta	a:player_tile_src+8
	clc
	adc	#$0200
	sta	a:player_tile_src+20
	lda	a:player_frames+10,y
	sta	a:player_tile_src+10
	clc
	adc	#$0200
	sta	a:player_tile_src+22
	stz	$38,x
	lda	OBJ_FACING,x
	bne	@facing_left
	lda	a:player_frames+12,y
	sta	OBJ_SPRITE,x
	rtl
@facing_left:
	lda	a:player_frames+14,y
	sta	OBJ_SPRITE,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
debug_color_math_off:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:cgwsel_shadow
	rtl

; (no caller found; decoded because it follows the end of a routine)
; No caller (debug): pad 2 sets color math (CGADSUB, COLDATA via debug_coldata).
debug_color_math_keys:
	; (not executed in the CDL traces)
	lda	hdma_preset
	cmp	#$0004
	beq	debug_color_math_off
	lda	#$0000
	sta	a:cgwsel_shadow
	ldy	#$0052
	lda	joy2_held
	bit	#$2000
	beq	@no_blend
	lda	joy2_held
	bit	#$0040
	bne	@set_cgadsub
@no_blend:
	ldy	#$0000
@set_cgadsub:
	sty	a:cgadsub_shadow
	bit	#$4000
	beq	@set_coldata
	lda	a:cgadsub_shadow
	and	#$0012
	sta	a:cgadsub_shadow
@set_coldata:
	lda	a:debug_coldata
	sta	a:coldata_shadow
	lda	joy2_pressed
	bit	#$0080
	beq	@check_b
	inc	a:debug_coldata
	rtl
@check_b:
	bit	#$8000
	beq	@return
	dec	a:debug_coldata
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; No caller (debug): Select on pad 1 toggles a window test; the buttons
; change TMW, W12SEL, WOBJSEL.
debug_window_keys:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#$2000
	beq	@check_test
	lda	a:debug_window_test
	eor	#$0001
	sta	a:debug_window_test
@check_test:
	lda	a:debug_window_test
	bne	@test_on
	brl	@test_off
@test_on:
	lda	joy1_pressed
	bit	#$8000
	beq	@check_y
	lda	a:tmw_shadow
	pha
	inc	a
	and	#$001F
	sta	zp_00
	pla
	and	#$FF00
	ora	zp_00
	sta	a:tmw_shadow
@check_y:
	lda	joy1_pressed
	bit	#$4000
	beq	@check_l
	lda	a:tmw_shadow
	pha
	and	#$00FF
	sta	a:tmw_shadow
	pla
	xba
	inc	a
	and	#$001F
	xba
	ora	a:tmw_shadow
	sta	a:tmw_shadow
@check_l:
	lda	joy1_pressed
	bit	#$0020
	beq	@check_r
	lda	a:w12sel_shadow
	pha
	inc	a
	and	#$0003
	sta	a:w12sel_shadow
	pla
	clc
	adc	#$0010
	and	#$0030
	ora	a:w12sel_shadow
	sta	a:w12sel_shadow
@check_r:
	lda	joy1_pressed
	bit	#$0010
	beq	@set_hdma
	lda	a:wobjsel_shadow
	clc
	adc	#$0010
	and	#$0030
	sta	a:wobjsel_shadow
@set_hdma:
	lda	#$00FF
	sta	f:debug_window_hdma_a
	lda	#$F807	; [num]
	sta	f:debug_window_hdma_a+$01
	lda	#$00FF
	sta	f:debug_window_hdma_a+$03
	lda	#$F887	; [num]
	sta	f:debug_window_hdma_a+$04
	lda	#$00FF
	sta	f:debug_window_hdma_b
	lda	#$FA07	; [num]
	sta	f:debug_window_hdma_b+$01
	lda	#$00FF
	sta	f:debug_window_hdma_b+$03
	lda	#$FA87	; [num]
	sta	f:debug_window_hdma_b+$04
	rtl
@test_off:
	stz	a:tmw_shadow
	stz	a:wram_1EBC
	rtl

; Sets both players' PLAYER_INVULN_TIMER to a small negative number (it
; then takes ~65000 frames to run out) and PLAYERF_INVULNERABLE: used by
; object handlers (stage ends, bosses).
make_players_invulnerable:
	phx
	ldx	#$0200
@loop:
	clc
	lda	stage_frame_mod4
	adc	#$FFFC
	sta	PLAYER_INVULN_TIMER,x
	lda	OBJ_FLAGS,x
	ora	#$0002
	sta	OBJ_FLAGS,x
	cpx	#$0240
	beq	@done
	ldx	#$0240
	bra	@loop
@done:
	plx
	rtl

; Object type $6D: the hover bike of a player (stage 4), in slot $0280 or
; $02C0 (field $30 selects the player through bike_player_slots). Follows the
; player; when the player falls back to y >= $A4 it puts them back in
; PLAYER_STATE_BIKE; deleted when the player's state is 1.
update_player_bike:
	ldy	$30,x
	lda	a:bike_player_slots,y
	tay
	lda	a:$0012,y
	cmp	#$0001
	bne	@dispatch
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
@dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_player_bike_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_player_bike_states:
	.addr	player_bike_state_00
	.addr	player_bike_state_01
	.addr	player_bike_state_02

player_bike_state_00:
	ldy	$30,x
	stz	OBJ_FLAGS,x
	stz	OBJ_TIMER,x
	lda	#$00B4
	sta	OBJ_Y,x
	lda	a:bike_attrs,y
	sta	OBJ_ATTR,x
	inc	OBJ_STATE,x
	rtl

player_bike_state_01:
	lda	OBJ_TIMER,x
	bmi	@hide
	dec	OBJ_TIMER,x
	bra	@follow
@hide:
	stz	OBJ_SPRITE,x
@follow:
	lda	a:$000A,y
	sta	OBJ_X,x
	lda	a:$000E,y
	sta	OBJ_Y,x
	lda	a:$0012,y
	cmp	#PLAYER_STATE_BIKE
	beq	@return
	cmp	#PLAYER_STATE_BIKE_INTRO
	beq	@return
	lda	a:$0016,y
	beq	@return
	bmi	@return
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06CB8B)
	sta	OBJ_SPRITE,x
@return:
	rtl

player_bike_state_02:
	lda	OBJ_Y,x
	cmp	#$00B1
	bcc	@check_player
	dec	OBJ_Y,x
@check_player:
	lda	a:$0016,y
	beq	@back_to_state_1
	bmi	@back_to_state_1
	lda	a:$000A,y
	sta	OBJ_X,x
	lda	a:$0032,y
	bne	@return
	lda	a:$000E,y
	cmp	#$00A4
	bcc	@return
	lda	#$0002
	sta	OBJ_TIMER,x
	lda	#PLAYER_STATE_BIKE
	sta	a:OBJ_STATE,y
	lda	#$00B4
	sta	a:$000E,y
	lda	#$7400
	sta	a:$001C,y
	lda	#$0000
	sta	a:$001E,y
@back_to_state_1:
	dec	OBJ_STATE,x
@return:
	rtl
start_player_fall_left:
	dec	OBJ_X,x
	lda	#$0000
	bra	enter_fall_state

; Moves 1 pixel right and starts falling (state 4): leaving a wall on the
; left. start_player_fall_left does the same to the left.
start_player_fall_right:
	inc	OBJ_X,x
	lda	#$0000
	bra	enter_fall_state

; Starts a fall (state 4) with $32 = $040A: dropping down from a bar or an
; object (down + jump).
start_player_drop:
	lda	#$040A
	bra	enter_fall_state
; From the hanging states (no bar any more, or down + jump): $32 = $020A.
start_player_fall_from_hang:
	lda	#$020A
	bra	enter_fall_state
; Walking off the floor (ground, climb, spin stance): $32 = $010A.
start_player_fall:
	lda	#$010A
; In: A = $32.  State 4, pose $D3, then player_state_fall.
enter_fall_state:
	sta	$32,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#$00D3
	sta	PLAYER_POSE,x
	stz	$38,x
	bra	player_state_fall
; Climbing, the wall ends above the hands but not at the feet: a small
; jump (state 3) over the top.
hop_off_wall_top:
	lda	#$DFFF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFB	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0003
	sta	OBJ_STATE,x
	stz	$32,x
	bra	player_state_jump
; Jump pressed while climbing a wall on the right: 1 pixel left, jump.
wall_jump_left:
	dec	OBJ_X,x
	bra	start_player_jump
; Jump pressed while climbing a wall on the left: 1 pixel right, jump.
wall_jump_right:
	inc	OBJ_X,x
; The normal jump: y velocity -6, pose $68, state 3, $32 = $070A.
start_player_jump:
	lda	#$0068
	sta	PLAYER_POSE,x
	stz	$38,x
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFA	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0003
	sta	OBJ_STATE,x
	lda	#$070A
	sta	$32,x
	bra	player_state_jump

; State 4, falling: dies on PCONTACT_KILLED, may throw a bomb, then aims and
; fires by PLAYER_AIM (tbl_fall_aim).
player_state_fall:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsr	a:set_player_box_standing
	jsl	f:check_bomb_button
	stz	zp_C4
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_fall_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_fall_aim:
	.addr	fall_aim_none
	.addr	fall_aim_right
	.addr	fall_aim_up
	.addr	fall_aim_up_right
	.addr	fall_aim_left
	.addr	fall_aim_none
	.addr	fall_aim_up_left
	.addr	fall_aim_none
	.addr	fall_aim_down
	.addr	fall_aim_down_right
	.addr	fall_aim_none
	.addr	fall_aim_none
	.addr	fall_aim_down_left

; States 3 and $0C, jumping: dies on PCONTACT_KILLED, may throw a bomb,
; somersault animation, aims and fires (tbl_jump_aim).
player_state_jump:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsr	a:set_player_box_jumping
	jsl	f:check_bomb_button
	stz	zp_C4
	jsl	f:animate_player_somersault
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_jump_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_jump_aim:
	.addr	jump_aim_none
	.addr	jump_aim_right
	.addr	jump_aim_up
	.addr	jump_aim_up_right
	.addr	jump_aim_left
	.addr	jump_aim_none
	.addr	jump_aim_up_left
	.addr	jump_aim_none
	.addr	jump_aim_down
	.addr	jump_aim_down_right
	.addr	jump_aim_none
	.addr	jump_aim_none
	.addr	jump_aim_down_left

fall_aim_none:
	lda	OBJ_FACING,x
	bne	fall_aim_left

fall_aim_right:
	lda	#$0020
	sta	zp_12
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	lda	#$00D3
	sta	PLAYER_POSE,x
	bra	airborne_fire_and_move

fall_aim_left:
	lda	#$0060
	sta	zp_12
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	lda	#$00D3
	sta	PLAYER_POSE,x
	bra	airborne_fire_and_move

jump_aim_none:
	lda	OBJ_FACING,x
	bne	jump_aim_left

jump_aim_right:
	lda	#$0020
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	bra	airborne_fire_and_move

jump_aim_left:
	lda	#$0060
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
; Jump and fall aims: fire (both weapons around in the spin jump, state
; $0C), gravity, then the collision for the direction of motion.
airborne_fire_and_move:
	lda	OBJ_STATE,x
	cmp	#$000C
	bne	@fire
	lda	#$FFF2	; [num]
	ldy	OBJ_FACING,x
	bne	@set_muzzle_2
	lda	#$FFF6	; [num]
@set_muzzle_2:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_2
	stz	$38,x
	lda	#$0002
	ldy	OBJ_FACING,x
	bne	@set_muzzle_1
	lda	#$0006
@set_muzzle_1:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_1
	bra	@clear_shot_pose
@fire:
	jsl	f:fire_weapon
	lda	OBJ_STATE,x
	cmp	#$0003
	bne	@gravity_check
@clear_shot_pose:
	stz	$38,x
@gravity_check:
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0006
	bcs	@collide
@gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@collide:
	lda	OBJ_Y_VEL,x
	bmi	@rising
	brl	airborne_falling_collision
@rising:
	brl	airborne_rising_collision

fall_aim_up:
	lda	#$00D7
	sta	PLAYER_POSE,x
	lda	#$0000
	sta	zp_12
	lda	OBJ_FACING,x
	bne	@facing_left
	lda	#$FFFE	; [num]
	bra	@set_muzzle
@facing_left:
	lda	#$FFF9	; [num]
@set_muzzle:
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_up:
	lda	#$0000
	sta	zp_12
	lda	#$FFFC	; [num]
	sta	zp_14
	lda	#$FFD0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

fall_aim_up_right:
	lda	#$00D5
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_12
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_up_right:
	lda	#$0010
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFD4	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

fall_aim_up_left:
	lda	#$00D5
	sta	PLAYER_POSE,x
	lda	#$0070
	sta	zp_12
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_up_left:
	lda	#$0070
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFD0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

fall_aim_down:
	lda	#$00DB
	sta	PLAYER_POSE,x
	lda	#$0040
	sta	zp_12
	lda	OBJ_FACING,x
	bne	@set_muzzle
	lda	#$FFF9	; [num]
	bra	@set_muzzle
@set_muzzle:
	lda	#$FFFD	; [num]
	sta	zp_14
	lda	#$FFFC	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_down:
	lda	#$0040
	sta	zp_12
	lda	#$FFF9	; [num]
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

fall_aim_down_right:
	lda	#$00D9
	sta	PLAYER_POSE,x
	lda	#$0030
	sta	zp_12
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_down_right:
	lda	#$0030
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

fall_aim_down_left:
	lda	#$00D9
	sta	PLAYER_POSE,x
	lda	#$0050
	sta	zp_12
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

jump_aim_down_left:
	; (not executed in the CDL traces)
	lda	#$0050
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	airborne_fire_and_move

; PLAYER_POSE cycles $3A-$3D, every 2 frames going up, every 4 going down.
animate_player_somersault:
	lda	PLAYER_POSE,x
	cmp	#$003A
	bcs	@check_direction
@reset_pose:
	lda	#$003A
	sta	PLAYER_POSE,x
	rtl
@check_direction:
	lda	OBJ_Y_VEL,x
	bpl	@falling
	lda	stage_frame_odd
	bne	@return
	beq	@next_pose
@falling:
	lda	stage_frame_mod4
	bne	@return
@next_pose:
	inc	PLAYER_POSE,x
	lda	PLAYER_POSE,x
	cmp	#$003E
	bcs	@reset_pose
@return:
	rtl

; Classifies the collision tiles under the feet (zp_04 at x, zp_06 at x+6):
; floor, slopes; sets zp_C4 and snaps the player onto the floor.
; The five tile trees (this one, classify_floor_tiles, classify_hang_bar_tiles,
; check_ceiling_at_offset, object_check_floor_tiles) have the same shape:
; the right tile (zp_06) is put in one of six classes by the tree's mask (no
; tile: @right_none; level: @right_level; a slope rising to the right, upper
; or lower tile of its 16-pixel column: @right_rise_upper/_lower; flipped,
; falling to the right: @right_fall_upper/_lower), then the left tile
; (zp_04, nodes @<right class>_left_<test>) picks the outcome. Outcomes are
; named after the zp_C4 class and the snap routine they end in: @none (0),
; @level (2), @rise (8: stop_y_slope_up_right...), @fall ($10: ...down_right...),
; with the snap's suffix (_below, _above, _below_high); _partial ($8000 set
; in zp_C4) when only one tile is that kind (the other one empty, or level
; next to a slope). @to_* (and the *_lower stubs among the left nodes) are
; trampolines: a beq never taken and a brl to a node out of branch range.
; Here: TILE_FLOOR_MASK, the slopes of TILE_FLOOR_SLOPES.
check_floor_tiles:
	lda	zp_06
	bit	#TILE_FLOOR_MASK
	beq	@right_none
	bit	#TILE_FLOOR_SLOPES
	beq	@right_level
	bit	#TILE_FLIPPED
	bne	@right_fall
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@right_rise_upper
	bne	@right_rise_lower
@right_fall:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@to_right_fall_lower
	brl	@right_fall_upper
@to_right_fall_lower:
	beq	@right_none
	brl	@right_fall_lower
@right_none:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@none_left_floor
	brl	@none
@none_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@none_left_slope
	brl	@level_partial
@none_left_slope:
	bit	#TILE_FLIPPED
	beq	@none_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@none_left_fall_lower
	brl	@fall_below
@none_left_fall_lower:
	; (not executed in the CDL traces)
	beq	@none_left_rise
	brl	@fall
@none_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@none_left_rise_lower
	brl	@rise
@none_left_rise_lower:
	beq	@right_level
	brl	@rise_below_high
@right_level:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@level_left_floor
	brl	@level_partial
@level_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@level_left_slope
	brl	@level
@level_left_slope:
	bit	#TILE_FLIPPED
	beq	@level_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@level_partial
	bne	@level_partial
@level_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@level_partial
	bne	@rise_below_high
@right_rise_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@rise_below
	bit	#TILE_FLOOR_SLOPES
	beq	@level_partial
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	; (not executed in the CDL traces)
	bne	@rise_below_high
@right_rise_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@rise
	bit	#TILE_FLOOR_SLOPES
	beq	@level_partial
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	bne	@rise_below_high
@right_fall_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@fall
	bit	#TILE_FLOOR_SLOPES
	beq	@level_partial
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@fall
	bne	@fall
@right_fall_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@fall_below_high
	bit	#TILE_FLOOR_SLOPES
	beq	@fall_below_high
	; (not executed in the CDL traces)
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@fall_below_high
	bne	@fall_below_high
@level:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_up_to_tile
@level_partial:
	lda	#$8002	; [num]
	sta	zp_C4
	rtl
@fall_below:
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right_below
@rise_below:
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right_below
@none:
	stz	zp_C4
	rtl
@rise:
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right
@rise_below_high:
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right_below_high
@fall:
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right
@fall_below_high:
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right_below_high
; Moving up: walls 32 and 8 pixels above the feet (TILE_CLIMBABLE: climb,
; state 2 / 5; TILE_WALL: blocked); a ceiling 48 pixels above the feet
; (check_ceiling_hang_height: TILE_CLIMBABLE or a ceiling slope) starts
; hanging from it (state $0D).
airborne_rising_collision:
	jsl	f:check_ceiling_hang_height
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left_wall
	bmi	@block_right
	lda	#$0002
	sta	OBJ_STATE,x
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	bpl	@return
	brl	snap_y_down_to_tile
@return:
	rtl
@check_left_wall:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left_low
	; (not executed in the CDL traces)
	bmi	@block_left
	lda	#$0005
	sta	OBJ_STATE,x
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	bpl	@return
	brl	snap_y_down_to_tile
@check_left_low:
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_right_low
@block_left:
	; (not executed in the CDL traces)
	jsl	f:snap_x_right_if_moving_left
	lda	zp_C4
	beq	@return2
	bmi	@return2
	lda	#$000D
	sta	OBJ_STATE,x
@return2:
	rtl
@check_right_low:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@no_wall
@block_right:
	jsl	f:snap_x_left_if_moving_right
	lda	zp_C4
	beq	@return3
	; (not executed in the CDL traces)
	bmi	@return3
	lda	#$000D
	sta	OBJ_STATE,x
@return3:
	rtl
@no_wall:
	lda	zp_C4
	beq	@return4
	lda	#$000D
	sta	OBJ_STATE,x
	lda	zp_C4
	bpl	@return4
	brl	snap_y_down_to_tile
@return4:
	rtl
airborne_kill_player:
	; (not executed in the CDL traces)
	jml	f:kill_player
; Moving down: lands on an object (PCONTACT_ON_OBJECT) or the BG floor
; (check_floor_tiles; $32 bit 8 ignores floor tiles without TILE_NO_DROP),
; walls as above, then a bar 48 pixels up starts hanging (state 1).
airborne_falling_collision:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	bne	airborne_kill_player
	bit	#$0080
	beq	@check_floor
	lda	#$0000
	sta	OBJ_STATE,x
	lda	#$0014
	sta	PLAYER_POSE,x
	rtl
@check_floor:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	bit	#TILE_NO_DROP
	bne	@check_right_foot
	lda	$32,x
	bit	#$0100
	beq	@check_right_foot
	stz	zp_04
@check_right_foot:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	bit	#TILE_NO_DROP
	bne	@classify_floor
	lda	$32,x
	bit	#$0100
	beq	@classify_floor
	stz	zp_06
@classify_floor:
	jsl	f:check_floor_tiles
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left_wall
	bmi	@block_right
	lda	#$0002
	sta	OBJ_STATE,x
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	bpl	@return
	brl	snap_y_up_to_tile
@return:
	rtl
@check_left_wall:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left_low
	bmi	@block_left
	lda	#$0005
	sta	OBJ_STATE,x
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	bpl	@return2
	brl	snap_y_up_to_tile
@return2:
	rtl
@check_left_low:
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_right_low
@block_left:
	jsl	f:snap_x_right_if_moving_left
	lda	zp_C4
	beq	@check_bar
	bmi	@check_bar
	; (not executed in the CDL traces)
	lda	#$0000
	sta	OBJ_STATE,x
	rtl
@check_right_low:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@no_wall
@block_right:
	jsl	f:snap_x_left_if_moving_right
	lda	zp_C4
	beq	@check_bar
	bmi	@check_bar
	lda	#$0000
	sta	OBJ_STATE,x
	rtl
@no_wall:
	lda	zp_C4
	beq	@check_bar
	lda	#$0000
	sta	OBJ_STATE,x
	lda	zp_C4
	bpl	@return3
	brl	snap_y_up_to_tile
@return3:
	rtl
@check_bar:
	stz	zp_00
	lda	#$FFD0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	bit	#TILE_BAR_MASK
	beq	@check_bar_right
	lda	$32,x
	bit	#$0200
	beq	@check_bar_right
	stz	zp_04
@check_bar_right:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	bit	#TILE_BAR_MASK
	beq	@classify_bar
	lda	$32,x
	bit	#$0200
	beq	@classify_bar
	stz	zp_06
@classify_bar:
	jsl	f:classify_hang_bar_tiles
	lda	zp_C4
	beq	@return4
	lda	#$0001
	sta	OBJ_STATE,x
@return4:
	rtl

; Body box and PLAYER_CENTER_X/Y while jumping (smaller).  RTS.
set_player_box_jumping:
	ldy	OBJ_FACING,x
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	a:jump_center_x_offsets,y
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	adc	#$FFF2
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0006
	sta	a:PLAYER_CENTER_Y,x
	rts
ground_return:
	rtl

; State 0, on the ground: dies on PCONTACT_KILLED, follows the platform
; object it stands on (PLAYER_PLATFORM), then aims and fires
; (tbl_ground_aim); the jump, the spin stance (PLAYER_SPIN) and falling
; start from here.
player_state_ground:
	jsl	f:check_bomb_button
	jsr	a:set_player_box_standing
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	ldy	a:PLAYER_PLATFORM,x
	beq	@check_floor
	bit	#$0080
	beq	@check_floor
	clc
	lda	OBJ_X_SUB,x
	adc	a:$0018,y
	sta	OBJ_X_SUB,x
	lda	OBJ_X,x
	adc	a:$001A,y
	sta	OBJ_X,x
	clc
	lda	OBJ_Y_SUB,x
	adc	a:$001C,y
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	adc	a:$001E,y
	sta	OBJ_Y,x
	lda	#$8002	; [num]
	sta	zp_C4
	lda	#TILE_NO_DROP
	sta	zp_12
	bra	@check_jump
@check_floor:
	jsl	f:check_walls_and_floor
	lda	OBJ_STATE,x
	bne	ground_return
	lda	zp_C4
	bne	@on_floor
	brl	start_player_fall
@on_floor:
	bit	#$0078
	beq	@check_jump
	clc
	lda	a:PLAYER_CENTER_Y,x
	adc	#$FFFC
	sta	a:PLAYER_CENTER_Y,x
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@no_jump
	lda	PLAYER_AIM,x
	cmp	#$0008
	beq	@down_jump
	brl	start_player_jump
@down_jump:
	lda	zp_12
	bit	#TILE_NO_DROP
	beq	@not_on_platform
	brl	start_player_jump
@not_on_platform:
	lda	stage_number
	cmp	#$0006
	beq	@stage6
	brl	start_player_fall
@stage6:
	lda	OBJ_Y,x
	cmp	#$0074
	bcc	@drop
	brl	start_player_jump
@drop:
	brl	start_player_fall
@no_jump:
	lda	a:PLAYER_SPIN,x
	beq	@aim
	brl	enter_spin_stance
@aim:
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_ground_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_ground_aim:
	.addr	ground_aim_none
	.addr	ground_aim_right
	.addr	ground_aim_up
	.addr	ground_aim_up_right
	.addr	ground_aim_left
	.addr	ground_aim_none
	.addr	ground_aim_up_left
	.addr	ground_aim_none
	.addr	ground_aim_down
	.addr	ground_aim_down_right
	.addr	ground_aim_none
	.addr	ground_aim_none
	.addr	ground_aim_down_left

ground_aim_none:
	lda	#$0001
	sta	PLAYER_LOCKED,x
	lda	OBJ_FACING,x
	beq	ground_aim_right
	brl	ground_aim_left

ground_aim_right:
	lda	#$0020
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	stz	PLAYER_POSE,x
	lda	zp_C4
	bpl	@fire
@pose_14:
	lda	#$0014
	sta	PLAYER_POSE,x
@fire:
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$0002
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon_walking
@slope:
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	lda	zp_C4
	bmi	@pose_14
	bit	#$0028
	bne	@uphill
	lda	#$00BA
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B0
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0028
	bne	@walk_uphill
	lda	#$0074
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0068
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0010
	sta	zp_14
	lda	#$FFDB	; [num]
	sta	zp_16
	jml	f:fire_weapon

ground_aim_up:
	lda	#$0000
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	ldy	#$001A
	lda	zp_C4
	bpl	@set_pose
@pose_dd:
	ldy	#$00DD
@set_pose:
	sty	PLAYER_POSE,x
	ldy	#$FFF9	; [num]
	lda	OBJ_FACING,x
	bne	@set_muzzle
	ldy	#$FFFE	; [num]
@set_muzzle:
	sty	zp_14
	lda	#$FFC0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@slope:
	lda	zp_C4
	bmi	@pose_dd
	bit	#$0028
	bne	@slope_up_right
	lda	OBJ_FACING,x
	bne	@uphill
	lda	#$FFFF	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00BC
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@uphill:
	lda	#$FFF8	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00B2
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@slope_up_right:
	lda	OBJ_FACING,x
	bne	@downhill
	lda	#$FFFF	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00B2
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@downhill:
	lda	#$FFF8	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00BC
	sta	PLAYER_POSE,x
	jml	f:fire_weapon

ground_aim_up_right:
	lda	#$0010
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	ldy	#$001C
	lda	zp_C4
	bpl	@set_pose
@pose_24:
	ldy	#$0024
@set_pose:
	sty	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$001E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@slope:
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	lda	zp_C4
	bmi	@pose_24
	bit	#$0028
	bne	@uphill
	lda	#$00BE
	sta	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B4
	sta	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0028
	bne	@walk_uphill
	lda	#$008C
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0011
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0080
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon

ground_aim_left:
	lda	#$0060
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	ldy	#$0000
	lda	zp_C4
	bpl	@set_pose
@pose_14:
	ldy	#$0014
@set_pose:
	sty	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$0002
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon_walking
@slope:
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	lda	zp_C4
	bmi	@pose_14
	bit	#$0050
	bne	@uphill
	lda	#$00BA
	sta	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B0
	sta	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0050
	bne	@walk_uphill
	lda	#$0074
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0068
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDB	; [num]
	sta	zp_16
	jml	f:fire_weapon

ground_aim_up_left:
	lda	#$0070
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	; (not executed in the CDL traces)
	ldy	#$001C
	lda	zp_C4
	bpl	@set_pose
@pose_24:
	ldy	#$0024
@set_pose:
	sty	PLAYER_POSE,x
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$001E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
@slope:
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	; (not executed in the CDL traces)
	lda	zp_C4
	bmi	@pose_24
	bit	#$0050
	bne	@uphill
	lda	#$00BE
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B4
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0050
	bne	@walk_uphill
	lda	#$008C
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE5	; [num]
	sta	zp_14
	lda	#$FFC9	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0080
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon

ground_aim_down:
	lda	PLAYER_LOCKED,x
	beq	@not_locked
	; (not executed in the CDL traces)
	brl	@aim_down
@not_locked:
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFF2
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0006
	sta	a:PLAYER_CENTER_Y,x
	lda	OBJ_FACING,x
	bne	@crouch_left
	lda	#$0020
	ldy	#$0018
	bra	@crouch_fire
@crouch_left:
	lda	#$0060
	ldy	#$FFDE	; [num]
@crouch_fire:
	sta	zp_12
	sty	zp_14
	lda	#$FFF2	; [num]
	sta	zp_16
	lda	#$002A
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@slope:
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	adc	#$000A
	sta	a:PLAYER_CENTER_Y,x
	lda	zp_C4
	ldy	OBJ_FACING,x
	bne	@slope_left
	ldy	#$0020
	sty	zp_12
	lda	zp_C4
	bit	#$0028
	bne	@slope_right_uphill
	lda	#$0012
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00C0
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@slope_right_uphill:
	lda	#$0010
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00B6
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@slope_left:
	ldy	#$0060
	sty	zp_12
	bit	#$0028
	bne	@slope_left_downhill
	lda	#$FFE4	; [num]
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00B6
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@slope_left_downhill:
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00C0
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@aim_down:
	; (not executed in the CDL traces)
	lda	#$0040
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@aim_down_slope
	bpl	@pose_df
@pose_e1:
	lda	#$00E1
	bra	@set_pose
@pose_df:
	lda	#$00DF
@set_pose:
	sta	PLAYER_POSE,x
	ldy	#$FFFD	; [num]
	lda	OBJ_FACING,x
	bne	@set_muzzle
	ldy	#$FFF9	; [num]
@set_muzzle:
	sty	zp_14
	lda	#$FFFC	; [num]
	sta	zp_16
	jml	f:fire_weapon
@aim_down_slope:
	bmi	@pose_e1
	bit	#$0028
	bne	@aim_down_slope_up_right
	lda	OBJ_FACING,x
	bne	@aim_down_uphill
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF6	; [num]
	sta	zp_16
	lda	#$00E5
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@aim_down_uphill:
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF6	; [num]
	sta	zp_16
	lda	#$00E3
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@aim_down_slope_up_right:
	lda	OBJ_FACING,x
	bne	@aim_down_downhill
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF4	; [num]
	sta	zp_16
	lda	#$00E3
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
@aim_down_downhill:
	lda	#$FFFC	; [num]
	sta	zp_14
	lda	#$FFF4	; [num]
	sta	zp_16
	lda	#$00E5
	sta	PLAYER_POSE,x
	jml	f:fire_weapon

ground_aim_down_right:
	lda	#$0030
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	@set_pose
@pose_34:
	ldy	#$0034
@set_pose:
	sty	PLAYER_POSE,x
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$002E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@slope:
	; (not executed in the CDL traces)
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	lda	zp_C4
	bmi	@pose_34
	bit	#$0028
	bne	@uphill
	lda	#$00C2
	sta	PLAYER_POSE,x
	lda	#$000A
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B8
	sta	PLAYER_POSE,x
	lda	#$000B
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0028
	bne	@walk_uphill
	lda	#$00A4
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0014
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0098
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000D
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon

ground_aim_down_left:
	lda	#$0050
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	@slope
	lda	PLAYER_LOCKED,x
	beq	@walk
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	@set_pose
@pose_34:
	ldy	#$0034
@set_pose:
	sty	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk:
	lda	#$002E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@slope:
	; (not executed in the CDL traces)
	ldy	PLAYER_LOCKED,x
	beq	@walk_slope
	lda	zp_C4
	bmi	@pose_34
	bit	#$0050
	bne	@uphill
	lda	#$00C2
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
@uphill:
	lda	#$00B8
	sta	PLAYER_POSE,x
	lda	#$FFEA	; [num]
	sta	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_slope:
	bit	#$0050
	bne	@walk_uphill
	lda	#$00A4
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE4	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
@walk_uphill:
	lda	#$0098
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon

; Ground states (player_state_ground, player_state_spin_stance): a wall tile
; (TILE_CLIMBABLE) 32 pixels above the feet at x starts climbing left
; (state 5), at x+6 climbing right (state 2), with a snap; TILE_WALL there
; only snaps. Then the tiles under the feet (zp_04 at x, zp_06 at x+6, zp_12
; both) are classified like check_floor_tiles (sets zp_C4, snaps onto the
; floor).
check_walls_and_floor:
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL
	beq	@check_climb_left
	; (not executed in the CDL traces)
	jsl	f:snap_x_right_to_tile
	bra	@check_floor
@check_climb_left:
	bit	#$0002
	beq	@check_right
	lda	#$0005
	sta	OBJ_STATE,x
	brl	snap_x_right_to_tile
@check_right:
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL
	beq	@check_climb_right
	jsl	f:snap_x_left_to_tile
	bra	@check_floor
@check_climb_right:
	bit	#TILE_CLIMBABLE
	beq	@check_floor
	lda	#$0002
	sta	OBJ_STATE,x
	brl	snap_x_left_to_tile
@check_floor:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	ora	zp_04
	sta	zp_12
	brl	classify_floor_tiles

; PLAYER_POSE steps by 2 every 8 frames through 0-$0A.
animate_player_walk:
	lda	stage_frame_mod8
	bne	@check_pose
	inc	PLAYER_POSE,x
	inc	PLAYER_POSE,x
@check_pose:
	lda	PLAYER_POSE,x
	cmp	#$000C
	bcc	@return
	stz	PLAYER_POSE,x
@return:
	rtl

; Body box (x .. x+6, y-36 .. y) and PLAYER_CENTER_X/Y on the ground.  RTS.
set_player_box_standing:
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	#$FFFC
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFDC
	sta	PLAYER_HITBOX_TOP,x
	adc	#$000E
	sta	a:PLAYER_CENTER_Y,x
	rts

; State 1, hanging from a bar or a hanging object: drops on jump + down,
; jumps on jump, else aims and fires (tbl_hang_aim).
player_state_hang:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	ldy	a:PLAYER_PLATFORM,x
	beq	@check_bar
	lda	PLAYER_CONTACT,x
	bit	#$2000
	beq	@check_bar
	clc
	lda	OBJ_X_SUB,x
	adc	a:$0018,y
	sta	OBJ_X_SUB,x
	lda	OBJ_X,x
	adc	a:$001A,y
	sta	OBJ_X,x
	clc
	lda	OBJ_Y_SUB,x
	adc	a:$001C,y
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	adc	a:$001E,y
	sta	OBJ_Y,x
	bra	@check_jump
@check_bar:
	jsl	f:check_hang_bar
	lda	a:zp_C4
	bne	@check_jump
	brl	start_player_fall_from_hang
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	run_hang_aim
	lda	PLAYER_AIM,x
	bit	#$0008
	beq	@jump
	brl	start_player_fall_from_hang
@jump:
	brl	start_player_jump
; Dispatch by PLAYER_AIM (tbl_hang_aim); also player_state_hang_object.
run_hang_aim:
	stz	zp_14
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_hang_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hang_aim:
	.addr	hang_aim_none
	.addr	hang_aim_right
	.addr	hang_aim_up
	.addr	hang_aim_up_right
	.addr	hang_aim_left
	.addr	hang_aim_none
	.addr	hang_aim_up_left
	.addr	hang_aim_none
	.addr	hang_aim_down
	.addr	hang_aim_down_right
	.addr	hang_aim_none
	.addr	hang_aim_none
	.addr	hang_aim_down_left

; Reads the collision tiles 48 pixels above the feet (x and x+6) and
; classifies them (classify_hang_bar_tiles): zp_C4 = 0 when there is no bar
; to hang from.
check_hang_bar:
	stz	zp_00
	lda	#$FFD0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06

; The tree of check_floor_tiles on the bar classes (TILE_BAR_MASK; sloped
; bars TILE_BAR_SLOPES): zp_04/zp_06 = the tiles at the hands (x, x+6).
classify_hang_bar_tiles:
	lda	zp_06
	bit	#TILE_BAR_MASK
	beq	@right_none
	bit	#TILE_BAR_SLOPES
	beq	@right_level
	bit	#TILE_FLIPPED
	bne	@right_fall
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@right_rise_upper
	bne	@right_rise_lower
@right_fall:
	bit	#TILE_BAR_SLOPE_LOWER
	bne	@to_right_fall_lower
	brl	@right_fall_upper
@to_right_fall_lower:
	beq	@right_none
	brl	@right_fall_lower
@right_none:
	lda	zp_04
	bit	#TILE_BAR_MASK
	bne	@none_left_bar
	brl	@none
@none_left_bar:
	bit	#TILE_BAR_SLOPES
	bne	@none_left_slope
	brl	@level_partial
@none_left_slope:
	bit	#TILE_FLIPPED
	beq	@none_left_rise
	bit	#TILE_BAR_SLOPE_LOWER
	bne	@none_left_fall_lower
	brl	@none
@none_left_fall_lower:
	; (not executed in the CDL traces)
	beq	@none_left_rise
	brl	@none
@none_left_rise:
	bit	#TILE_BAR_SLOPE_LOWER
	bne	@none_left_rise_lower
	; (not executed in the CDL traces)
	brl	@rise_below_high
@none_left_rise_lower:
	beq	@right_level
	brl	@rise
@right_level:
	lda	zp_04
	bit	#TILE_BAR_MASK
	bne	@level_left_bar
	brl	@level_partial
@level_left_bar:
	bit	#TILE_BAR_SLOPES
	bne	@level_left_slope
	brl	@level
@level_left_slope:
	bit	#TILE_FLIPPED
	beq	@level_left_rise
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@level
	bne	@level
@level_left_rise:
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@rise_below_high
	; (not executed in the CDL traces)
	bne	@rise
@right_rise_upper:
	lda	zp_04
	bit	#TILE_BAR_MASK
	beq	@none
	bit	#TILE_BAR_SLOPES
	beq	@level
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@rise_below_high
	; (not executed in the CDL traces)
	bne	@rise
@right_rise_lower:
	lda	zp_04
	bit	#TILE_BAR_MASK
	beq	@none
	bit	#TILE_BAR_SLOPES
	beq	@level
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@rise_below_high
	bne	@rise
@right_fall_upper:
	lda	zp_04
	bit	#TILE_BAR_MASK
	beq	@fall_below_high
	bit	#TILE_BAR_SLOPES
	beq	@fall_below_high
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@fall_below_high
	bne	@fall_below_high
@right_fall_lower:
	lda	zp_04
	bit	#TILE_BAR_MASK
	beq	@fall
	bit	#TILE_BAR_SLOPES
	beq	@fall
	bit	#TILE_BAR_SLOPE_LOWER
	beq	@fall
	bne	@fall
@level_partial:
	lda	#$8000	; [num]
	sta	zp_C4
	brl	snap_y_down_to_tile
@level:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_down_to_tile
@none:
	stz	zp_C4
	rtl
@rise_below_high:
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right_below_high
@rise:
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right
@fall_below_high:
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right_below_high
@fall:
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right

; State $10 (stage 3, seen in the emulator): hanging from a moving object;
; jump lets go (down + jump drops).
player_state_hang_object:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@aim
	stz	$3E,x
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	@jump
	brl	start_player_drop
@jump:
	brl	start_player_jump
@aim:
	brl	run_hang_aim

; State 2, climbing a wall on the right (TILE_CLIMBABLE at x+6): aims and fires
; (tbl_climb_right_aim); falls when the wall ends.
player_state_climb_right:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	lda	OBJ_X,x
	adc	#$FFF6
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	#$FFFE
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	adc	#$FFF8
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE0
	sta	PLAYER_HITBOX_TOP,x
	adc	#$000C
	sta	a:PLAYER_CENTER_Y,x
	jsl	f:check_bomb_button
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	bne	@on_wall
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	bne	@wall_top
	; (not executed in the CDL traces)
	brl	start_player_fall
@wall_top:
	brl	hop_off_wall_top
@on_wall:
	stz	OBJ_FACING,x
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_climb_right_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_climb_right_aim:
	.addr	climb_right_aim_none
	.addr	climb_right_aim_right
	.addr	climb_right_aim_up
	.addr	climb_right_aim_up_right
	.addr	climb_right_aim_left
	.addr	climb_right_aim_none
	.addr	climb_right_aim_up_left
	.addr	climb_right_aim_none
	.addr	climb_right_aim_down
	.addr	climb_right_aim_down_right
	.addr	climb_right_aim_none
	.addr	climb_right_aim_none
	.addr	climb_right_aim_down_left

climb_right_aim_none:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@no_jump
	brl	start_player_fall_left
@no_jump:
	brl	climb_right_fire_left

climb_right_aim_right:
	lda	#$0058
	sta	PLAYER_POSE,x
	lda	#$0020
	sta	zp_12
	lda	#$0006
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_up:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$0066
	sta	PLAYER_POSE,x
	bra	@check_jump
@climb:
	jsl	f:climb_right_check_ceiling
	beq	@animate
	; (not executed in the CDL traces)
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	brl	wall_jump_left
@fire:
	lda	#$0000
	sta	zp_12
	lda	#$FFF3	; [num]
	sta	zp_14
	lda	#$FFBC	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_up_right:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$005A
	sta	PLAYER_POSE,x
	bra	@fire
@climb:
	jsl	f:climb_right_check_ceiling
	beq	@animate
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@fire:
	lda	#$0010
	sta	zp_12
	lda	#$0002
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_left:
	jsl	f:climb_right_check_ceiling
	bne	@leave_wall
	jsl	f:climb_right_check_floor
	beq	@check_jump
@leave_wall:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	@check_jump
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	climb_right_fire_left
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	start_player_fall_left
; Aiming away from the wall (left), also the idle pose.
climb_right_fire_left:
	lda	#$005E
	sta	PLAYER_POSE,x
	lda	#$0060
	sta	zp_12
	lda	#$FFCC	; [num]
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_up_left:
	jsl	f:climb_right_check_ceiling
	bne	@leave_wall
	jsl	f:climb_right_check_floor
	beq	@aim
@leave_wall:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	@aim
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
@aim:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$0060
	sta	PLAYER_POSE,x
	bra	@check_jump
@animate:
	; (not executed in the CDL traces)
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	; (not executed in the CDL traces)
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	wall_jump_left
@fire:
	lda	#$0070
	sta	zp_12
	lda	#$FFD5	; [num]
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_down:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$0064
	sta	PLAYER_POSE,x
	bra	@check_jump
@climb:
	jsl	f:climb_right_check_floor
	beq	@animate
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	brl	start_player_fall_left
@fire:
	lda	#$0040
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFF8	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_down_right:
	; (not executed in the CDL traces)
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$005C
	sta	PLAYER_POSE,x
	bra	@fire
@climb:
	jsl	f:climb_right_check_floor
	beq	@animate
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@fire:
	lda	#$0030
	sta	zp_12
	stz	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_down_left:
	; (not executed in the CDL traces)
	jsl	f:climb_right_check_ceiling
	bne	@leave_wall
	jsl	f:climb_right_check_floor
	beq	@aim
@leave_wall:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	@aim
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
@aim:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$0062
	sta	PLAYER_POSE,x
	bra	@check_jump
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	start_player_fall_left
@fire:
	lda	#$0050
	sta	zp_12
	lda	#$FFD2	; [num]
	sta	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon

; Climbing: a solid tile 48 pixels above (x) stops the climb (snap down, A =
; $0E).
climb_right_check_ceiling:
	stz	zp_00
	lda	#$FFD0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@return
	jsl	f:snap_y_down_to_tile
	lda	#$000E
@return:
	rtl

; Climbing: a solid tile under the feet (x) lands the player (snap up, A =
; 1).
climb_right_check_floor:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@return
	jsl	f:snap_y_up_to_tile
	lda	#$0001
@return:
	rtl

; Climbing animation: poses $54-$57, one step every 8 frames.
animate_player_climb:
	lda	stage_frame_mod8
	bne	@check_pose
	inc	PLAYER_POSE,x
@check_pose:
	lda	PLAYER_POSE,x
	cmp	#$0054
	bcc	@reset_pose
	cmp	#$0058
	bcs	@reset_pose
	rtl
@reset_pose:
	lda	#$0054
	sta	PLAYER_POSE,x
	rtl
; Stops the horizontal motion too (weapon_item_move).
stop_and_snap_y_up_to_tile:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x

; Moves the object up to the top of its 8-pixel BG tile row (taking the BG
; scroll bg1_y into account) and stops its vertical motion: landing.
; Used by the players and by object handlers.  In: X = slot.
snap_y_up_to_tile:
	clc
	lda	a:bg1_y
	adc	OBJ_Y,x
	and	#$0007
	sta	zp_0E
	sec
	lda	OBJ_Y,x
	sbc	zp_0E
	sta	OBJ_Y,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_SUB,x
	rtl

; Stops the vertical motion and moves the object down to the last line of
; its tile row: bumping a ceiling.  In: X = slot.
snap_y_down_to_tile:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_SUB,x
	clc
	lda	a:bg1_y
	adc	OBJ_Y,x
	eor	#$FFFF
	and	#$0007
	sta	zp_0E
	clc
	lda	OBJ_Y,x
	adc	zp_0E
	sta	OBJ_Y,x
	rtl

snap_x_left_if_moving_right:
	lda	OBJ_X_VEL,x
	bmi	snap_x_left_return

; Moves the object left to the left edge of its tile column (offset zp_00,
; BG scroll bg1_x) and stops its horizontal motion: a wall on the right.
snap_x_left_to_tile:
	clc
	lda	OBJ_X,x
	adc	zp_00
	adc	a:bg1_x
	and	#$0007
	sta	zp_0E
	sec
	lda	OBJ_X,x
	sbc	zp_0E
	sta	OBJ_X,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_SUB,x
snap_x_left_return:
	rtl

snap_x_right_if_moving_left:
	lda	OBJ_X_VEL,x
	bpl	snap_x_right_return

; Moves the object right to the right edge of its tile column and stops its
; horizontal motion: a wall on the left.
snap_x_right_to_tile:
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$0007
	sta	zp_0E
	sec
	lda	OBJ_X,x
	sbc	zp_0E
	clc
	adc	#$0007
	sta	OBJ_X,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_SUB,x
snap_x_right_return:
	rtl

; Slope snapping (zp_C4 8: slope rising to the right, $10: falling to the
; right; 1 pixel up per 2 across, so 8 pixels over 16).  t = ((x + bg1_x)
; & 15) / 2 (the falling ones add zp_00 to x) and row = the screen y of the
; top of the object's 8-pixel BG tile row; each sets OBJ_Y to the slope
; surface in that row, the row above or the row below.  snap_y_slope_*
; (objects: object_check_floor_tiles, classify_floor_tiles) keep the
; velocity; stop_y_slope_* (the players' floor, ceiling and bar checks) also
; stop the vertical motion and end 1 pixel higher (_high: 2 pixels).
; y = row + 6 - t.
stop_y_slope_up_right:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	eor	#$FFFF
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row + 7 - t.
snap_y_slope_up_right:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	eor	#$FFFF
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	sta	OBJ_Y,x
	rtl
; y = row + 13 - t.
stop_y_slope_up_right_below_high:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	clc
	adc	zp_10
	sta	zp_0E
	sec
	lda	#$000E
	sbc	zp_0E
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row - t.
snap_y_slope_up_right_above:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	clc
	adc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	sec
	sbc	zp_0E
	sta	OBJ_Y,x
	rtl
; y = row + 14 - t.
stop_y_slope_up_right_below:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	eor	#$FFFF
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row + 15 - t.
snap_y_slope_up_right_below:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	a:bg1_x
	and	#$000F
	eor	#$FFFF
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	sta	OBJ_Y,x
	rtl
; y = row + t - 1.
stop_y_slope_down_right:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row + t.
snap_y_slope_down_right:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	sta	OBJ_Y,x
	rtl
; y = row + 6 + t.
stop_y_slope_down_right_below_high:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	eor	#$FFFF
	lsr	a
	and	#$0007
	clc
	adc	zp_10
	sta	zp_0E
	sec
	lda	#$000E
	sbc	zp_0E
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row + t - 7.
snap_y_slope_down_right_above:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	eor	#$FFFF
	lsr	a
	and	#$0007
	clc
	adc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	and	#$FFF8
	sec
	sbc	zp_0E
	sta	OBJ_Y,x
	rtl
; y = row + 7 + t.
stop_y_slope_down_right_below:
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	dec	a
	sta	OBJ_Y,x
	rtl
; y = row + 8 + t.
snap_y_slope_down_right_below:
	lda	a:bg1_y
	and	#$0007
	sta	zp_10
	lda	OBJ_X,x
	clc
	adc	zp_00
	clc
	adc	a:bg1_x
	and	#$000F
	lsr	a
	and	#$0007
	sec
	sbc	zp_10
	sta	zp_0E
	lda	OBJ_Y,x
	clc
	adc	zp_10
	clc
	adc	#$0008
	and	#$FFF8
	clc
	adc	zp_0E
	sta	OBJ_Y,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
; The second half of check_walls_and_floor alone: reads the tiles under the
; feet and classifies them. Never reached.
unused_check_floor_at_feet:
	; (not executed in the CDL traces)
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	ora	zp_04
	sta	zp_12
; The ground states' classification of zp_04/zp_06 (check_walls_and_floor):
; the tree of check_floor_tiles, ending in the snap_y_* routines (they keep the
; velocity); @fall_left_only and @fall_below_left_only set $8011.
classify_floor_tiles:
	lda	zp_06
	bit	#TILE_FLOOR_MASK
	bne	@right_floor
	brl	@right_none
@right_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@right_slope
	brl	@right_level
@right_slope:
	bit	#TILE_FLIPPED
	bne	@right_fall
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@to_right_rise_lower
	brl	@right_rise_upper
@to_right_rise_lower:
	beq	@right_fall
	brl	@right_rise_lower
@right_fall:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@to_right_fall_lower
	brl	@right_fall_upper
@to_right_fall_lower:
	beq	@right_none
	brl	@right_fall_lower
@right_none:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@none_left_floor
	brl	@none
@none_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@none_left_slope
	brl	@level_partial
@none_left_slope:
	bit	#TILE_FLIPPED
	beq	@none_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@none_left_fall_lower
	brl	@fall_below_left_only
@none_left_fall_lower:
	; (not executed in the CDL traces)
	beq	@none_left_rise
	brl	@fall_left_only
@none_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@none_left_rise_lower
	brl	@rise_partial
@none_left_rise_lower:
	beq	@right_level
	brl	@rise_above_partial
@right_level:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@level_left_floor
	brl	@level_partial
@level_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@level_left_slope
	brl	@level
@level_left_slope:
	bit	#TILE_FLIPPED
	beq	@level_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@level_left_fall_lower
	; (not executed in the CDL traces)
	brl	@level_partial
@level_left_fall_lower:
	beq	@level_left_rise
	brl	@level_partial
@level_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@level_left_rise_lower
	brl	@rise_partial
@level_left_rise_lower:
	; (not executed in the CDL traces)
	beq	@right_rise_upper
	brl	@rise_above_partial
@right_rise_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@rise_upper_left_floor
	brl	@rise_below_partial
@rise_upper_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@rise_upper_left_slope
	; (not executed in the CDL traces)
	brl	@level_partial
@rise_upper_left_slope:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@rise_upper_left_lower
	brl	@rise
@rise_upper_left_lower:
	; (not executed in the CDL traces)
	beq	@right_rise_lower
	brl	@rise_above
@right_rise_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@rise_lower_left_floor
	brl	@rise_partial
@rise_lower_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@rise_lower_left_slope
	brl	@level_partial
@rise_lower_left_slope:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@rise_lower_left_lower
	brl	@rise
@rise_lower_left_lower:
	beq	@right_fall_upper
	brl	@rise_above
@right_fall_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@fall_upper_left_floor
	brl	@fall_partial
@fall_upper_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@fall_upper_left_slope
	brl	@fall_partial
@fall_upper_left_slope:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@fall_upper_left_lower
	brl	@fall
@fall_upper_left_lower:
	beq	@right_fall_lower
	brl	@fall
@right_fall_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@fall_lower_left_floor
	; (not executed in the CDL traces)
	brl	@fall_above_partial
@fall_lower_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@fall_lower_left_slope
	; (not executed in the CDL traces)
	brl	@fall_above_partial
@fall_lower_left_slope:
	bit	#TILE_FLOOR_SLOPE_LOWER
	bne	@fall_lower_left_lower
	; (not executed in the CDL traces)
	brl	@fall_above
@fall_lower_left_lower:
	beq	@none
	brl	@fall_above
@none:
	stz	zp_C4
	rtl
@fall_below_left_only:
	lda	#$8011	; [num]
	sta	zp_C4
	brl	snap_y_slope_down_right_below
@fall_left_only:
	; (not executed in the CDL traces)
	lda	#$8011	; [num]
	sta	zp_C4
	brl	snap_y_slope_down_right
@level:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_up_to_tile
@level_partial:
	lda	#$8002	; [num]
	sta	zp_C4
	brl	snap_y_up_to_tile
@rise_partial:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	snap_y_slope_up_right
@rise_above_partial:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	snap_y_slope_up_right_above
@rise_below_partial:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	snap_y_slope_up_right_below
@rise:
	lda	#$0008
	sta	zp_C4
	brl	snap_y_slope_up_right
@rise_above:
	lda	#$0008
	sta	zp_C4
	brl	snap_y_slope_up_right_above
@fall_partial:
	lda	#$8010	; [num]
	sta	zp_C4
	brl	snap_y_slope_down_right
@fall:
	lda	#$0010
	sta	zp_C4
	brl	snap_y_slope_down_right
@fall_above_partial:
	; (not executed in the CDL traces)
	lda	#$8010	; [num]
	sta	zp_C4
	brl	snap_y_slope_down_right_above
@fall_above:
	lda	#$0010
	sta	zp_C4
	brl	snap_y_slope_down_right_above

; State 5, climbing a wall on the left.
player_state_climb_left:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	lda	OBJ_X,x
	adc	#$0008
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	#$FFFC
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	adc	#$FFF8
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE0
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0006
	sta	a:PLAYER_CENTER_Y,x
	jsl	f:check_bomb_button
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	bne	@on_wall
	; (not executed in the CDL traces)
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	bne	@wall_top
	brl	start_player_fall
@wall_top:
	brl	hop_off_wall_top
@on_wall:
	lda	#$0002
	sta	OBJ_FACING,x
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_climb_left_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_climb_left_aim:
	.addr	climb_left_aim_none
	.addr	climb_left_aim_right
	.addr	climb_left_aim_up
	.addr	climb_left_aim_up_right
	.addr	climb_left_aim_left
	.addr	climb_left_aim_none
	.addr	climb_left_aim_up_left
	.addr	climb_left_aim_none
	.addr	climb_left_aim_down
	.addr	climb_left_aim_down_right
	.addr	climb_left_aim_none
	.addr	climb_left_aim_none
	.addr	climb_left_aim_down_left

climb_left_aim_none:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@no_jump
	brl	start_player_fall_right
@no_jump:
	bra	climb_left_fire_right

climb_left_aim_right:
	jsl	f:climb_left_check_ceiling
	bne	@leave_wall
	jsl	f:climb_left_check_floor
	beq	@check_jump
@leave_wall:
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	climb_left_fire_right
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	start_player_fall_right
; Aiming away from the wall (right), also the idle pose.
climb_left_fire_right:
	lda	#$005E
	sta	PLAYER_POSE,x
	lda	#$0020
	sta	zp_12
	lda	#$002A
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_up:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$0066
	sta	PLAYER_POSE,x
	bra	@check_jump
@climb:
	; (not executed in the CDL traces)
	jsl	f:climb_left_check_ceiling
	beq	@animate
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	brl	wall_jump_right
@fire:
	lda	#$0000
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_up_right:
	jsl	f:climb_left_check_ceiling
	bne	@leave_wall
	jsl	f:climb_left_check_floor
	beq	@aim
@leave_wall:
	; (not executed in the CDL traces)
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
@aim:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$0060
	sta	PLAYER_POSE,x
	bra	@check_jump
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	wall_jump_right
@fire:
	lda	#$0010
	sta	zp_12
	lda	#$0020
	sta	zp_14
	lda	#$FFCC	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_left:
	lda	#$0058
	sta	PLAYER_POSE,x
	lda	#$0060
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_up_left:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$005A
	sta	PLAYER_POSE,x
	bra	@fire
@climb:
	; (not executed in the CDL traces)
	jsl	f:climb_left_check_ceiling
	beq	@animate
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@fire:
	lda	#$0070
	sta	zp_12
	lda	#$FFF4	; [num]
	sta	zp_14
	lda	#$FFC6	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_down:
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$0064
	sta	PLAYER_POSE,x
	bra	@check_jump
@climb:
	jsl	f:climb_left_check_floor
	beq	@animate
	; (not executed in the CDL traces)
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	jsl	f:start_player_fall_right
@fire:
	lda	#$0040
	sta	zp_12
	lda	#$0006
	sta	zp_14
	lda	#$FFF8	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_down_right:
	; (not executed in the CDL traces)
	jsl	f:climb_left_check_ceiling
	bne	@leave_wall
	jsl	f:climb_left_check_floor
	beq	@aim
@leave_wall:
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
@aim:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$0062
	sta	PLAYER_POSE,x
	bra	@check_jump
@animate:
	jsl	f:animate_player_climb
@check_jump:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@fire
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	start_player_fall_right
@fire:
	lda	#$0030
	sta	zp_12
	lda	#$0024
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_down_left:
	; (not executed in the CDL traces)
	lda	PLAYER_LOCKED,x
	beq	@climb
	lda	#$005C
	sta	PLAYER_POSE,x
	bra	@fire
@climb:
	jsl	f:climb_left_check_floor
	beq	@animate
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
@animate:
	jsl	f:animate_player_climb
@fire:
	lda	#$0050
	sta	zp_12
	lda	#$FFF6	; [num]
	sta	zp_14
	lda	#$FFED	; [num]
	sta	zp_16
	jml	f:fire_weapon

; As climb_right_check_ceiling, at x+6.
climb_left_check_ceiling:
	lda	#$0006
	sta	zp_00
	lda	#$FFD0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@return
	; (not executed in the CDL traces)
	jsl	f:snap_y_down_to_tile
	lda	#$000E
@return:
	rtl

; As climb_right_check_floor, at x+6.
climb_left_check_floor:
	lda	#$0006
	sta	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@return
	jsl	f:snap_y_up_to_tile
	lda	#$0001
@return:
	rtl
; Entered (JML) by the state handlers when PLAYER_CONTACT has
; PCONTACT_KILLED: death sound ($3F, or $43 when below the screen), thrown
; back away from OBJ_FACING, loses the weapon of the active slot (both when
; dual-firing) and the barrier, PLAYERF_INTANGIBLE, state 7 (dying).
kill_player:
.if CHEAT_INVINCIBLE | CHEAT_NO_PIT_DEATH
	jsr	a:cheat_filter_death	; returns only if the player dies
.endif
	lda	#SOUND_PLAYER_DIE
	ldy	OBJ_Y,x
	cpy	#$00F8
	bcc	@play_sound
	bmi	@play_sound
	lda	#SOUND_PLAYER_FALL
@play_sound:
	jsl	f:queue_sound
	stz	$30,x
	stz	$34,x
	stz	$36,x
	stz	$3E,x
	lda	OBJ_FACING,x
	beq	@facing_right
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	bra	@set_y_vel
@facing_right:
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
@set_y_vel:
	lda	#$DFFF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFB	; [num]
	sta	OBJ_Y_VEL,x
.if !CHEAT_KEEP_WEAPONS
	lda	a:PLAYER_WEAPON_SLOT,x
	bne	loc_019ABF
	stz	a:PLAYER_WEAPON_2,x
	bra	loc_019ACA
loc_019ABF:
	lda	a:PLAYER_WEAPON_SLOT_OTHER,x
	beq	loc_019AC7
	stz	a:PLAYER_WEAPON_2,x
loc_019AC7:
	stz	a:PLAYER_WEAPON_1,x
loc_019ACA:
.else
loc_019ACA:	; cheat: the weapons are kept
.endif
	lda	#$0007
	sta	OBJ_STATE,x
	lda	#$00E8
	sta	PLAYER_POSE,x
	stz	a:PLAYER_POSE_ADD,x
	stz	$32,x
	lda	#$0028
	sta	$30,x
	stz	PLAYER_INVULN_TIMER,x
	stz	$38,x
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	stz	a:PLAYER_BARRIER,x
	rtl

; State 7: thrown back with gravity until it lands (or leaves the screen),
; then state 8.
player_state_dying:
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	lda	OBJ_Y,x
	adc	#$FFF2
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	lda	OBJ_Y,x
	bmi	@on_screen
	cmp	#$0120
	bcs	@dead
@on_screen:
	dec	$30,x
	lda	$30,x
	beq	@gravity_check
	bit	#$0007
	bne	@gravity_check
	inc	PLAYER_POSE,x
	lda	#$00ED
	cmp	PLAYER_POSE,x
	bne	@gravity_check
	lda	#$00E9
	sta	PLAYER_POSE,x
@gravity_check:
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0006
	bcs	@collide
@gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@collide:
	stz	zp_C4
	lda	OBJ_Y_VEL,x
	bpl	@falling
	jsl	f:dying_check_ceiling_walls
@still_dying:
	lda	#$0007
	sta	OBJ_STATE,x
	rtl
@falling:
	jsl	f:dying_check_floor_walls
	lda	OBJ_STATE,x
	bne	@still_dying
@dead:
	lda	#$0008
	sta	OBJ_STATE,x
	lda	#$0020
	sta	$30,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	lda	#$00ED
	sta	PLAYER_POSE,x
	rtl

; State 8: lies dead for $20 frames, then takes a life (PLAYER_LIVES) and
; sets PLAYER_BOMBS to 1 (0 when it was the last life); state $0E.
player_state_dead:
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFF0
	sta	PLAYER_HITBOX_TOP,x
	dec	$30,x
	bpl	@return
	stz	OBJ_X,x
	stz	OBJ_Y,x
	stz	OBJ_SPRITE,x
	stz	PLAYER_POSE,x
	stz	a:PLAYER_POSE_ADD,x
	stz	OBJ_FLAGS,x
	lda	#$000E
	sta	OBJ_STATE,x
	lda	#$0000
.if CHEAT_INFINITE_LIVES
	ldy	a:PLAYER_LIVES,x	; cheat: the life is not taken (Z clear)
.else
	dec	a:PLAYER_LIVES,x
.endif
	beq	@set_bombs
	lda	#$0001
@set_bombs:
	sta	a:PLAYER_BOMBS,x
@return:
	rtl

; State $0E: if lives remain, resets the player and goes to state $0F.
player_state_out:
	lda	a:PLAYER_LIVES,x
	beq	@return
	stz	OBJ_X,x
	stz	OBJ_Y,x
	stz	OBJ_SPRITE,x
	stz	PLAYER_POSE,x
	stz	a:PLAYER_POSE_ADD,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	$32,x
	stz	PLAYER_INVULN_TIMER,x
	stz	$38,x
	stz	OBJ_FLAGS,x
	stz	PLAYER_CONTACT,x
	lda	#$000F
	sta	OBJ_STATE,x
	stz	a:PLAYER_BARRIER,x
@return:
	rtl

; State $0F: places the player by respawn_mode (tbl_respawn_placement) and
; calls respawn_player.
player_state_respawn:
	lda	a:respawn_mode
	phx
	asl	a
	tax
	lda	f:tbl_respawn_placement,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_respawn_placement:
	.addr	respawn_on_floor
	.addr	respawn_on_floor_high
	.addr	respawn_on_right_wall
	.addr	respawn_at_bottom
	.addr	respawn_on_floor_low
	.addr	respawn_on_bike
	.addr	respawn_on_missile
	.addr	respawn_above_slot_0280
	.addr	respawn_at_upper_left

; Respawn mode 8: x $20 (player 2: $40), y $5A.
respawn_at_upper_left:
	lda	#$0020
	cpx	#$0200
	beq	@set_x
	lda	#$0040
@set_x:
	sta	OBJ_X,x
	lda	#$005A
	sta	OBJ_Y,x
	brl	respawn_player

; Respawn mode 7: above the object in slot $0280 (y - $18), x $58 (player 2:
; $98).
respawn_above_slot_0280:
	sec
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	sbc	#$0018
	sta	OBJ_Y,x
	lda	#$0058
	cpx	#$0200
	beq	@set_x
	; (not executed in the CDL traces)
	lda	#$0098
@set_x:
	sta	OBJ_X,x
	brl	respawn_player

; Respawn mode 6, and the handler of state 6 (PLAYER_STATE_WAIT_MISSILE):
; placed on the first rideable missile (type $65, slots $07C0-$087F) with x
; < $44; until there is one, does nothing.
respawn_on_missile:
	ldy	#$07C0
@loop:
	lda	a:$0010,y
	cmp	#$0065
	bne	@next_slot
	lda	a:$000A,y
	bmi	@next_slot
	cmp	#$0044
	bcs	@next_slot
	txa
	sec
	sbc	#$0200
	lsr	a
	clc
	adc	#$0020
	adc	a:$000A,y
	sta	OBJ_X,x
	clc
	lda	a:$000E,y
	adc	#$0024
	sta	OBJ_Y,x
	jml	f:respawn_player
@next_slot:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0880
	bcc	@loop
	rtl

; Respawn mode 5: drives in from the left on the bike (state $12, x velocity
; 8).
respawn_on_bike:
	lda	#$00B4
	sta	OBJ_Y,x
	lda	#$000A
	sta	OBJ_X,x
	jsl	f:respawn_player
	lda	#$0008
	sta	OBJ_X_VEL,x
	rtl

; Respawn mode 4: as respawn_on_floor, searching from $40 below the top.
respawn_on_floor_low:
	lda	#$0040
	sta	zp_0E
	lda	#$000E
	bra	respawn_on_floor_search

; Respawn mode 1: as respawn_on_floor, searching from $20 below the top.
respawn_on_floor_high:
	lda	#$0020
	sta	zp_0E
	lda	#$0012
	bra	respawn_on_floor_search

; Respawn mode 0: searches the collision map ($7E:4000) down from y $30 for
; the first solid tile and places the player there (x $38, player 2: $20).
respawn_on_floor:
	lda	#$0030
	sta	zp_0E
	lda	#$0014
; In: zp_0E = first row (y below the top), A = rows to search per column.
respawn_on_floor_search:
	sta	zp_08
	sta	zp_02
	lda	#$0020
	sta	zp_06
	lda	#$0038
	cpx	#$0200
	beq	@have_x
	lda	#$0020
@have_x:
	stx	zp_FC
	stz	zp_04
	clc
	adc	a:bg1_x
	bit	#$0100
	beq	@have_half
	ldy	#$0800
	sty	zp_04
@have_half:
	lsr	a
	lsr	a
	and	#$003E
	sta	zp_00
	lda	a:bg1_y
	clc
	adc	zp_0E
	asl	a
	asl	a
	asl	a
	and	#$07C0
	sta	zp_12
@next_row:
	sta	zp_0A
	ora	zp_00
	ora	zp_04
@test_tile:
	tax
	lda	f:$7E4000,x
	beq	@empty
	txa
	and	#$003E
	asl	a
	asl	a
	sta	zp_00
	txa
	and	#$07C0
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	a:bg1_y
	and	#$00FF
	ldx	zp_FC
	sec
	sbc	#$0038
	bmi	@clamp_top
	cmp	#$0020
	bcs	@set_y
@clamp_top:
	lda	#$0020
@set_y:
	sta	OBJ_Y,x
	sec
	lda	zp_00
	sbc	a:bg1_x
	and	#$00FF
	sta	OBJ_X,x
	brl	respawn_player
@empty:
	clc
	lda	zp_0A
	adc	#$0040
	and	#$07C0
	dec	zp_02
	bne	@next_row
	lda	zp_08
	sta	zp_02
	lda	zp_12
	sta	zp_0A
	dec	zp_06
	bne	@next_column
	; (not executed in the CDL traces)
	ldx	zp_FC
	brl	@not_found
@next_column:
	clc
	lda	zp_00
	adc	#$0002
	cmp	#$0040
	bcc	@column_ok
	lda	zp_04
	adc	#$0800
	and	#$0800
	sta	zp_04
	lda	#$0000
@column_ok:
	sta	zp_00
	ora	zp_04
	ora	zp_12
	brl	@test_tile
@not_found:
	; (not executed in the CDL traces)
	lda	#$0080
	sta	OBJ_X,x
	sta	OBJ_Y,x
	brl	respawn_player

; Respawn mode 2: climbing the right wall (state 2) at x $D2.
respawn_on_right_wall:
	lda	#$0070
	cpx	#$0200
	beq	@set_y
	lda	#$0088
@set_y:
	sta	OBJ_Y,x
	lda	#$00D2
	sta	OBJ_X,x
	brl	respawn_player

; Respawn mode 3: x $78, y $BC.
respawn_at_bottom:
	lda	#$0078
	cpx	#$0200
	beq	@set_x
	; (not executed in the CDL traces)
	lda	#$0058
@set_x:
	sta	OBJ_X,x
	lda	#$00BC
	sta	OBJ_Y,x
	brl	respawn_player

; Thrown back, moving up: ceiling and wall collision.
dying_check_ceiling_walls:
	lda	#$FFF8	; [num]
	jsl	f:check_ceiling_at_offset
	lda	#$0006
	sta	zp_00
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left
	brl	snap_x_left_to_tile
@check_left:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_ceiling
	brl	snap_x_right_to_tile
@check_ceiling:
	lda	zp_C4
	beq	@return
	bpl	@return
	; (not executed in the CDL traces)
	brl	snap_y_down_to_tile
@return:
	rtl

; Thrown back, falling: floor and wall collision; on the floor, state 0
; (then player_state_dying goes to state 8).
dying_check_floor_walls:
	lda	PLAYER_CONTACT,x
	bit	#$0080
	beq	@check_floor
	; (not executed in the CDL traces)
	stz	OBJ_STATE,x
	rtl
@check_floor:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	jsl	f:check_floor_tiles
	lda	#$0006
	sta	zp_00
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@check_left
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	beq	@return
	bmi	@return
	stz	OBJ_STATE,x
@return:
	rtl
@check_left:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#TILE_WALL_MASK
	beq	@no_wall
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	beq	@return2
	bmi	@return2
	stz	OBJ_STATE,x
@return2:
	rtl
@no_wall:
	lda	zp_C4
	beq	@return3
	stz	OBJ_STATE,x
	lda	zp_C4
	bpl	@return3
	brl	snap_y_up_to_tile
@return3:
	rtl

; Sets the state, y velocity and pose of respawn mode respawn_mode
; (respawn_states/93/81), 96 frames of PLAYER_INVULN_TIMER, OBJ_FLAGS = 3
; (present + PLAYERF_INVULNERABLE).
respawn_player:
	ldy	a:respawn_mode
	lda	a:respawn_states,y
	and	#$00FF
	sta	OBJ_STATE,x
	tya
	asl	a
	tay
	lda	a:respawn_y_vels,y
	sta	OBJ_Y_VEL,x
	lda	a:respawn_poses,y
	sta	PLAYER_POSE,x
	stz	OBJ_FACING,x
	stz	$32,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	a:PLAYER_POSE_ADD,x
	lda	#$0060
	sta	PLAYER_INVULN_TIMER,x
	lda	#$0003
	sta	OBJ_FLAGS,x
	rtl
