; objects/player.asm -- Players
; Bank $01, $01:A548-$01:B193. Included by main.asm in segment BANK01.
;
; update_players (once per frame from the stage loop) runs both players
; (objects at $0200/$0240, fields PLAYER_* in ram.inc): pad, respawn
; blinking, the input routine of the state (read_player_input,
; tbl_player_input), the bomb (update_bomb, bomb_hit_targets), the state
; handler (run_player_state, tbl_player_states; most handlers are in
; objects/player_weapons.asm) and the player's frame (set_player_frame).
; Also the generic movement (move_player), the hanging and spin-stance
; states and the BG-collision cascade for hanging (check_ceiling_at_offset).

; State $09 (stage 1, seen in the emulator): dropping into the tank; lands
; at y = $C8, then state $0A.
player_state_enter_tank:
	jsr	a:set_player_box_jumping
	lda	OBJ_Y,x
	cmp	#$00C8
	bcs	@landed
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	brl	animate_player_somersault
@landed:
	lda	#$00C8
	sta	OBJ_Y,x
	stz	OBJ_FACING,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	$32,x
	stz	$34,x
	stz	$36,x
	lda	#$00E7
	sta	PLAYER_POSE,x
	inc	OBJ_STATE,x
	rtl

; State $0A (stage 1, seen in the emulator): driving the tank (body box 40
; pixels wide; input_tank moves it, jump leaves it).
player_state_tank:
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFDA
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0004
	sta	a:PLAYER_CENTER_Y,x
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0028
	sta	PLAYER_HITBOX_RIGHT,x
	adc	#$FFE0
	sta	a:PLAYER_CENTER_X,x
	lda	PLAYER_JOY_PRESSED,x
	bit	button_fire
	beq	@recoil
	txy
	ldx	#$0AC0
	cpy	#$0200
	beq	@have_slot_base
	ldx	#$0D40
@have_slot_base:
	lda	$10,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	ora	$B0,x
	ora	$D0,x
	ora	$F0,x
	ora	a:$0110,x
	ora	a:$0130,x
	beq	@fire
	; (not executed in the CDL traces)
	tyx
	bra	@recoil
@fire:
	lda	#$0007
	sta	SHOT_TYPE,x
	lda	#$0010
	sta	SHOT_DAMAGE,x
	lda	#$3348
	sta	SHOT_ATTR,x
	lda	#$FFFF	; [num]
	sta	SHOT_HIT,x
	lda	#$00A0
	sta	OBJ_Y,x
	clc
	lda	a:OBJ_X,y
	adc	#$0020
	sta	OBJ_X,x
	lda	#$0040
	sta	$14,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	tyx
	lda	#$DFFF	; [num]
	sta	$34,x
	lda	#$FFF9	; [num]
	sta	$36,x
	lda	#$0004
	sta	a:shake_timer
	lda	#$0020
	jsl	f:queue_sound
@recoil:
	lda	$36,x
	beq	@no_recoil
	clc
	lda	$34,x
	adc	#$4800
	sta	$34,x
	lda	$36,x
	adc	#$0000
	sta	$36,x
	bra	@return
@no_recoil:
	stz	$34,x
@return:
	rtl
	; CDL: not accessed
	.byte	$6B

; Once per frame from the stage loop: for each player with lives left,
; copies the pad (PLAYER_JOY_HELD/PRESSED), counts PLAYER_INVULN_TIMER down
; (clears PLAYERF_INVULNERABLE at 0; the player blinks between palettes
; every 4 frames meanwhile) and runs read_player_input; updates the bombs
; (update_bomb), then run_player_state and set_player_frame for each
; player (player 1's frame on odd frames, VRAM $6000/$6100; player 2's on
; even ones, $6200/$6300).
update_players:
	ldx	#$0200
	lda	a:p1_lives
	beq	@player1_done
	lda	joy1_held
	sta	PLAYER_JOY_HELD,x
	lda	joy1_pressed
	sta	PLAYER_JOY_PRESSED,x
	lda	PLAYER_INVULN_TIMER,x
	beq	@normal_palette
	dec	PLAYER_INVULN_TIMER,x
	bne	@blink
	lda	OBJ_FLAGS,x
	and	#$FFFD
	sta	OBJ_FLAGS,x
@blink:
	bit	#$0003
	bne	@normal_palette
	lda	#$3200
	bra	@read_input
@normal_palette:
	lda	#$3A00
@read_input:
	jsl	f:read_player_input
@player1_done:
	jsr	a:update_bomb
	ldx	#$0240
	lda	a:p2_lives
	beq	@player2_done
	lda	joy2_held
	sta	PLAYER_JOY_HELD,x
	lda	joy2_pressed
	sta	PLAYER_JOY_PRESSED,x
	lda	PLAYER_INVULN_TIMER,x
	beq	@normal_palette2
	dec	PLAYER_INVULN_TIMER,x
	bne	@blink2
	lda	OBJ_FLAGS,x
	and	#$FFFD
	sta	OBJ_FLAGS,x
@blink2:
	bit	#$0003
	bne	@normal_palette2
	lda	#$3220
	bra	@read_input2
@normal_palette2:
	lda	#$3C20
@read_input2:
	jsl	f:read_player_input
@player2_done:
	jsr	a:update_bomb
	jsl	f:run_bg1_scroll_mode
	jsl	f:run_bg2_scroll_mode
	lda	a:p1_lives
	beq	@player2_state
	ldx	#$0200
	jsl	f:run_player_state
	lda	stage_frame_odd
	beq	@player2_state
	lda	#$6000
	sta	player_tiles_vram_top
	lda	#$6100
	sta	player_tiles_vram_bottom
	jsl	f:set_player_frame
@player2_state:
	lda	a:p2_lives
	beq	@return
	ldx	#$0240
	jsl	f:run_player_state
	lda	stage_frame_odd
	bne	@return
	lda	#$6200
	sta	player_tiles_vram_top
	lda	#$6300
	sta	player_tiles_vram_bottom
	jsl	f:set_player_frame
@return:
	rtl

; In: A = OBJ_ATTR for this frame (palette), X = player.  Clears
; PLAYER_LOCKED, PLAYER_AIM and PLAYER_POSE_ADD, updates PLAYER_SPIN, then
; runs the input routine of the state (tbl_player_input): sets the
; velocity, OBJ_FACING and PLAYER_AIM from the pad.
read_player_input:
	sta	OBJ_ATTR,x
	jsl	f:apply_player_autopilot
	jsl	f:update_spin_flag
	stz	PLAYER_LOCKED,x
	stz	PLAYER_AIM,x
	stz	a:PLAYER_POSE_ADD,x
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_player_input,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_player_input:
	.addr	input_ground
	.addr	input_hang
	.addr	input_climb
	.addr	input_air
	.addr	input_air
	.addr	input_climb
	.addr	input_free_move
	.addr	move_player
	.addr	move_player
	.addr	move_player
	.addr	input_tank
	.addr	move_player_unless_locked
	.addr	input_air
	.addr	input_hang
	.addr	move_player
	.addr	move_player
	.addr	input_hang_object
	.addr	input_bike
	.addr	input_bike_intro
	.addr	move_player_unless_locked
	.addr	move_player_unless_locked

; Input of state $12: the bike drives in; when PLAYER_INVULN_TIMER reaches
; 1, 64 more frames of it and state $11.
input_bike_intro:
	lda	PLAYER_INVULN_TIMER,x
	cmp	#$0001
	bne	@driving
	lda	#$0040
	sta	PLAYER_INVULN_TIMER,x
	lda	#PLAYER_STATE_BIKE
	sta	OBJ_STATE,x
@driving:
	stz	PLAYER_AIM,x
	cpx	#$0240
	bne	@check_speed
	cmp	#$0058
	bcc	@check_speed
	brl	move_player_unless_locked
@check_speed:
	lda	OBJ_X_VEL,x
	bpl	@decelerate
	cmp	#$FFFE	; [num]
	bcs	@decelerate
	brl	move_player_unless_locked
@decelerate:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$3000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	brl	move_player_unless_locked

; Input of state $11 (hover bike): up/down aim, right accelerates.
input_bike:
	stz	OBJ_FACING,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	@check_down
	lda	#$0002
	sta	PLAYER_AIM,x
	bra	@check_right
@check_down:
	bit	#$0400
	beq	@check_right
	lda	#$0008
	sta	PLAYER_AIM,x
@check_right:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	@check_left
	lda	PLAYER_AIM,x
	ora	#$0001
	sta	PLAYER_AIM,x
	lda	PLAYER_JOY_HELD,x
	bit	button_stand_still
	beq	@drive_right
	brl	move_player_unless_locked
@drive_right:
	lda	#$0002
	sta	OBJ_X_VEL,x
	brl	move_player_unless_locked
@check_left:
	bit	#$0200
	bne	@left
	brl	move_player_unless_locked
@left:
	lda	#$0002
	sta	OBJ_FACING,x
	lda	PLAYER_AIM,x
	ora	#$0004
	sta	PLAYER_AIM,x
	lda	PLAYER_JOY_HELD,x
	bit	button_stand_still
	beq	@drive_left
	brl	move_player_unless_locked
@drive_left:
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	move_player_unless_locked

; Input of state $10 (hanging from a moving object).
input_hang_object:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	PLAYER_JOY_HELD,x
	bit	a:hang_lock_buttons
	beq	@check_right
	inc	PLAYER_LOCKED,x
@check_right:
	bit	#$0100
	beq	@check_left
	stz	OBJ_FACING,x
	lda	#$0001
	sta	PLAYER_AIM,x
	bra	@check_down
@check_left:
	bit	#$0200
	beq	@check_down
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$0004
	sta	PLAYER_AIM,x
@check_down:
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	@check_up
	lda	PLAYER_AIM,x
	ora	#$0008
	sta	PLAYER_AIM,x
	brl	move_player_unless_locked
@check_up:
	bit	#$0800
	bne	@aim_up
	brl	move_player_unless_locked
@aim_up:
	lda	PLAYER_AIM,x
	ora	#$0002
	sta	PLAYER_AIM,x
	brl	move_player_unless_locked

; Input of state 6: moves freely in 8 directions (never run in the CDL
; traces; state 6 itself is respawn_on_missile).
input_free_move:
	; (not executed in the CDL traces)
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	@check_left
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	bra	@set_x_vel
@check_left:
	bit	#$0200
	beq	@check_up
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
@set_x_vel:
	sta	OBJ_X_VEL,x
@check_up:
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	@check_down
	lda	#$97FF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	bra	@set_y_vel
@check_down:
	bit	#$0400
	beq	@move
	lda	#$6800
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0001
@set_y_vel:
	sta	OBJ_Y_VEL,x
@move:
	brl	move_player

; Input of state $0A (the tank): left/right drive (sound $1E), jump leaves
; the tank (sound $1F, state 3).
input_tank:
	lda	#$0040
	sta	a:obj_slots+31*OBJ_SIZE+OBJ_FLAGS
	stz	a:obj_slots+31*OBJ_SIZE+$34
	stz	a:PLAYER_PLATFORM,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	beq	@leave_tank
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@drive
	dec	a:obj_slots+31*OBJ_SIZE+OBJ_STATE
@leave_tank:
	stz	a:tank_moving
	lda	#$001F
	jsl	f:queue_sound
	stz	a:tank_move_dx
	stz	a:obj_slots+31*OBJ_SIZE+OBJ_X_VEL
	stz	a:obj_slots+31*OBJ_SIZE+OBJ_X_VEL_SUB
	lda	#$0041
	sta	a:obj_slots+31*OBJ_SIZE+OBJ_FLAGS
	lda	#$0003
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	dec	OBJ_Y,x
	dec	OBJ_Y,x
	lda	#$3FFF
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFA	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0060
	sta	PLAYER_INVULN_TIMER,x
	stz	$32,x
	stz	$34,x
	brl	move_player
@drive:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	@check_left
	lda	PLAYER_CONTACT,x
	bit	#$0200
	bne	@stopped
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	bra	@set_x_vel_sub
@check_left:
	bit	#$0200
	beq	@stopped
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
@set_x_vel_sub:
	sta	OBJ_X_VEL_SUB,x
	lda	a:tank_moving
	bne	@apply_recoil
	inc	a:tank_moving
	lda	#$001E
	jsl	f:queue_sound
	bra	@apply_recoil
@stopped:
	lda	a:tank_moving
	beq	@apply_recoil
	stz	a:tank_moving
	lda	#$001F
	jsl	f:queue_sound
@apply_recoil:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	$34,x
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	$36,x
	sta	OBJ_X_VEL,x
	clc
	lda	OBJ_X_SUB,x
	adc	OBJ_X_VEL_SUB,x
	lda	OBJ_X,x
	sta	zp_00
	adc	OBJ_X_VEL,x
	cmp	#$000A
	bcs	@in_bounds
	sec
	lda	#$000A
	sbc	zp_00
	sta	a:tank_move_dx
	brl	move_player
@in_bounds:
	sec
	sbc	zp_00
	sta	a:tank_move_dx
	bne	@moved
	brl	move_player
@moved:
	bpl	@moving_right
	lda	#$0001
	sta	a:obj_slots+31*OBJ_SIZE+$34
	brl	move_player
@moving_right:
	lda	#$0002
	sta	a:obj_slots+31*OBJ_SIZE+$34
	brl	move_player

; Hanging (states 1, $0D): like input_ground, but fire also stops the
; player (hang_lock_buttons = fire | stand still).
input_hang:
	lda	a:hang_lock_buttons
	bra	input_ground_lock_mask

; On the ground (state 0): button_stand_still sets PLAYER_LOCKED; left/right
; walk at 1.40 pixels a frame unless a solid object blocks that side
; (PCONTACT_BLOCK_*), and set OBJ_FACING and PLAYER_AIM; up/down add to
; PLAYER_AIM.  Ends with move_player_unless_locked.
input_ground:
	lda	button_stand_still
; In: A = the buttons that set PLAYER_LOCKED.
input_ground_lock_mask:
	sta	zp_00
	lda	PLAYER_JOY_HELD,x
	bit	zp_00
	beq	@not_locked
	inc	PLAYER_LOCKED,x
	bra	input_left_right
@not_locked:
	bit	#$0300
	bne	input_left_right
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	bra	input_up_down

input_air:
	lda	PLAYER_JOY_HELD,x
; Left/right: walk (unless PCONTACT_BLOCK_*), OBJ_FACING, PLAYER_AIM.
input_left_right:
	bit	#$0100
	beq	@check_left
	stz	OBJ_FACING,x
	lda	PLAYER_CONTACT,x
	bit	#$0400
	bne	@aim_right
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
@aim_right:
	lda	#$0001
	sta	PLAYER_AIM,x
	bra	input_up_down
@check_left:
	lda	PLAYER_JOY_HELD,x
	bit	#$0200
	beq	input_up_down
	lda	#$0002
	sta	OBJ_FACING,x
	lda	PLAYER_CONTACT,x
	bit	#$0200
	bne	@aim_left
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
@aim_left:
	lda	#$0004
	sta	PLAYER_AIM,x
; Up/down: add to PLAYER_AIM, then move_player_unless_locked.
input_up_down:
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	@check_up
	lda	PLAYER_AIM,x
	ora	#$0008
	sta	PLAYER_AIM,x
	bra	move_player_unless_locked
@check_up:
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	move_player_unless_locked
	lda	PLAYER_AIM,x
	ora	#$0002
	sta	PLAYER_AIM,x
	bra	move_player_unless_locked

; Climbing a wall (states 2, 5): up/down move vertically, left/right only
; aim.  Ends with move_player.
input_climb:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	@check_up
	lda	#$0001
	sta	OBJ_Y_VEL,x
	lda	#$6800
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0008
	sta	PLAYER_AIM,x
	bra	@check_lock
@check_up:
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	@stop
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0002
	sta	PLAYER_AIM,x
@check_lock:
	lda	PLAYER_JOY_HELD,x
	bit	a:hang_lock_buttons
	beq	@check_right
	inc	PLAYER_LOCKED,x
@stop:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
@check_right:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	@check_left
	lda	PLAYER_AIM,x
	ora	#$0001
	sta	PLAYER_AIM,x
	bra	move_player
@check_left:
	lda	PLAYER_JOY_HELD,x
	bit	#$0200
	beq	move_player
	lda	PLAYER_AIM,x
	ora	#$0004
	sta	PLAYER_AIM,x
	bra	move_player

; Zeroes the x velocity while PLAYER_LOCKED, then move_player.
move_player_unless_locked:
	lda	PLAYER_LOCKED,x
	beq	move_player
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x

; Adds the velocity to the position, clamps x to 10..240 (and y to 49 and
; more while clamp_player_top is set) and stores the movement of the frame in
; PLAYER_DX / PLAYER_DY.  In: X = player.  Returns with RTL.
move_player:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	OBJ_X_SUB,x
	sta	OBJ_X_SUB,x
	lda	OBJ_X,x
	sta	zp_00
	adc	OBJ_X_VEL,x
	cmp	#$000A
	bcc	@clamp_left
	cmp	#$00F0
	bcc	@set_x
	lda	#$00F0
	bra	@set_x
@clamp_left:
	lda	#$000A
@set_x:
	sta	OBJ_X,x
	sec
	sbc	zp_00
	sta	a:PLAYER_DX,x
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	OBJ_Y_SUB,x
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	sta	zp_00
	adc	OBJ_Y_VEL,x
	ldy	a:clamp_player_top
	beq	@set_y
	cmp	#$0031
	bcs	@set_y
	lda	#$0031
@set_y:
	sta	OBJ_Y,x
	sec
	sbc	zp_00
	sta	a:PLAYER_DY,x
	rtl

; Per frame, per player: follows the BG scroll, kills the player who fell
; below the screen (PCONTACT_KILLED), counts down the fire delays and the
; barrier (PLAYER_BARRIER), then runs the state handler (tbl_player_states,
; by OBJ_STATE; see PLAYER_STATE_* in ram.inc).  In: X = player.
run_player_state:
.if CHEAT_DEBUG_KEYS
	jsr	a:debug_player_keys
.endif
	sec
	lda	a:OBJ_X,x
	sbc	a:bg1_x_delta
	sta	a:OBJ_X,x
	sec
	lda	a:OBJ_Y,x
	sbc	a:bg1_y_delta
	sta	a:OBJ_Y,x
	bmi	@not_fallen
	cmp	#$00FF
	bcc	@not_fallen
	lda	#$0004
	sta	PLAYER_CONTACT,x
@not_fallen:
	; $32: pass-through flags (high byte) for a few frames (low byte): set
	; to $010A walking off a floor, $020A leaving a bar, $040A dropping,
	; $070A jumping; airborne_falling_collision then ignores floor tiles
	; without TILE_NO_DROP (flag $0100) and bar tiles (flag $0200).
	lda	$32,x
	beq	@fire_delays
	and	#$00FF
	bne	@count_down
	stz	$32,x
	bra	@fire_delays
@count_down:
	dec	$32,x
@fire_delays:
	lda	PLAYER_FIRE_DELAY_1,x
	dec	a
	cmp	#$0008
	bcc	@set_delay_1
	lda	#$0000
@set_delay_1:
	sta	PLAYER_FIRE_DELAY_1,x
	lda	PLAYER_FIRE_DELAY_2,x
	dec	a
	cmp	#$0008
	bcc	@set_delay_2
	lda	#$0000
@set_delay_2:
	sta	PLAYER_FIRE_DELAY_2,x
	lda	a:PLAYER_BARRIER,x
	beq	run_player_state_dispatch
	dec	a:PLAYER_BARRIER,x
run_player_state_dispatch:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_player_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_player_states:
	.addr	player_state_ground
	.addr	player_state_hang
	.addr	player_state_climb_right
	.addr	player_state_jump
	.addr	player_state_fall
	.addr	player_state_climb_left
	.addr	respawn_on_missile
	.addr	player_state_dying
	.addr	player_state_dead
	.addr	player_state_enter_tank
	.addr	player_state_tank
	.addr	player_state_spin_stance
	.addr	player_state_jump
	.addr	player_state_hang_climb
	.addr	player_state_out
	.addr	player_state_respawn
	.addr	player_state_hang_object
	.addr	player_state_bike
	.addr	player_state_bike_intro
	.addr	player_state_ending
	.addr	player_state_ending_wave

; While PLAYER_BOMB_RADIUS is non-zero: grows it by PLAYER_BOMB_SPEED (which
; accelerates by $0800 a frame) up to 255, then 0 = finished; calls
; bomb_hit_targets.
update_bomb:
	lda	a:PLAYER_BOMB_RADIUS,x
	beq	@return
	clc
	adc	a:PLAYER_BOMB_SPEED,x
	cmp	#$00FF
	bcc	@set_radius
	lda	#$0000
@set_radius:
	sta	a:PLAYER_BOMB_RADIUS,x
	clc
	lda	a:PLAYER_BOMB_SPEED_SUB,x
	adc	#$0800
	sta	a:PLAYER_BOMB_SPEED_SUB,x
	lda	a:PLAYER_BOMB_SPEED,x
	adc	#$0000
	sta	a:PLAYER_BOMB_SPEED,x
	jsr	a:bomb_hit_targets
@return:
	rts

; Every other frame per player (stage_frame_odd): each object of the
; target list overlapping the square of half-size PLAYER_BOMB_RADIUS around
; PLAYER_BOMB_X/Y gets OBJ_HIT = $0100 and, if OBJF_TARGET and not
; OBJF_INVULNERABLE, loses 1 OBJ_HP; destroyed objects score
; type_scores[OBJ_TYPE] for the player (sub_00B829).
bomb_hit_targets:
	lda	stage_frame_odd
	bne	@odd_frame
	cpx	#$0200
	bne	@return
	beq	@test_targets
@odd_frame:
	cpx	#$0240
	bne	@return
@test_targets:
	lda	a:PLAYER_BOMB_X,x
	adc	a:PLAYER_BOMB_RADIUS,x
	sta	zp_00
	lda	a:PLAYER_BOMB_X,x
	sbc	a:PLAYER_BOMB_RADIUS,x
	sta	zp_02
	lda	a:PLAYER_BOMB_Y,x
	adc	a:PLAYER_BOMB_RADIUS,x
	sta	zp_04
	lda	a:PLAYER_BOMB_Y,x
	sbc	a:PLAYER_BOMB_RADIUS,x
	sta	zp_06
	txy
	ldx	#$159E
	phx
@loop:
	plx
	inx
	inx
	lda	$00,x
	beq	@done
	phx
	tax
	lda	OBJ_HP,x
	bmi	@loop
	lda	zp_00
	cmp	OBJ_X,x
	bmi	@loop
	lda	zp_06
	cmp	OBJ_Y,x
	bpl	@loop
	lda	zp_04
	cmp	OBJ_HITBOX_TOP,x
	bmi	@loop
	lda	zp_02
	cmp	OBJ_HITBOX_RIGHT,x
	bpl	@loop
	lda	#$0100
	sta	OBJ_HIT,x
	lda	OBJ_FLAGS,x
	bit	#$0010
	beq	@loop
	bit	#$0020
	bne	@loop
	sec
	lda	OBJ_HP,x
	sbc	#$0001
	sta	OBJ_HP,x
	bpl	@loop
	phy
	lda	OBJ_TYPE,x
	asl	a
	tay
	lda	a:type_scores,y
	ply
	phx
	tyx
	jsl	f:add_score_for_player_obj
	plx
	bra	@loop
@done:
	tyx
@return:
	rts

; (no caller found; decoded because it follows the end of a routine)
; Unused debug code (no caller): with Select held, Up cycles the difficulty
; (and sets PLAYER_BOMBS to it), A sets one life and kills the player, B
; kills the player, X sets lives, bombs and barrier to $8000.
debug_player_keys:
	; (not executed in the CDL traces)
	lda	PLAYER_JOY_HELD,x
	bit	#$2000
	beq	@return
	lda	PLAYER_JOY_PRESSED,x
	bit	#$0800
	beq	@check_a
	inc	difficulty
	inc	difficulty
	lda	difficulty
	and	#$0006
	cmp	#$0006
	bne	@set_difficulty
	lda	#$0000
@set_difficulty:
	sta	difficulty
	sta	a:PLAYER_BOMBS,x
	bra	@return
@check_a:
	lda	PLAYER_JOY_HELD,x
	bit	#$0080
	beq	@check_b
	lda	#$0001
	sta	a:PLAYER_LIVES,x
	bra	@kill
@check_b:
	lda	PLAYER_JOY_HELD,x
	bit	#$8000
	beq	@check_x
@kill:
	lda	#$0004
	sta	PLAYER_CONTACT,x
	bra	@return
@check_x:
	lda	PLAYER_JOY_HELD,x
	bit	#$0040
	beq	@return
	lda	#$8000	; [num]
	sta	a:PLAYER_LIVES,x
	sta	a:PLAYER_BOMBS,x
	sta	a:PLAYER_BARRIER,x
@return:
	rts

; State $13 (set by the ending sequence for each player still in the game):
; pose animation (ending_poses), then state $14.
player_state_ending:
	dec	$34,x
	bpl	@animate
	inc	OBJ_STATE,x
	lda	#$0040
	sta	$34,x
	lda	#$0004
	sta	$30,x
	lda	#$0004
	sta	$36,x
	lda	#$0111
	sta	PLAYER_POSE,x
	rtl
@animate:
	lda	$34,x
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:ending_poses,y
	sta	PLAYER_POSE,x
	rtl

; State $14: replays the pose sequence ending_wave_poses while Y is held (probably
; waving).
player_state_ending_wave:
	lda	$34,x
	bmi	@play_sequence
	dec	$34,x
	rtl
@play_sequence:
	lda	$30,x
	cmp	#$000C
	bcs	@sequence_done
	dec	$36,x
	bpl	@return
	ldy	#$0004
	sty	$36,x
	inc	$30,x
	inc	$30,x
	cpx	#$0200
	beq	@set_pose
	; (not executed in the CDL traces)
	clc
	adc	#$000C
@set_pose:
	tay
	lda	a:ending_wave_poses,y
	sta	PLAYER_POSE,x
@return:
	rtl
@sequence_done:
	lda	PLAYER_JOY_HELD,x
	bit	#$4000
	beq	@return
	stz	$30,x
	lda	#$0010
	sta	$36,x
	rtl
; From player_state_ground: state $0B (spin stance), $30 = 8.
enter_spin_stance:
	lda	#$0008
	sta	$30,x
	lda	#$000B
	sta	OBJ_STATE,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	rtl

; State $0B (L+R held on the ground; entered from the ground aim routines
; when PLAYER_SPIN is set): carried by a platform, plays the stance
; animation; fire with PLAYER_SPIN still set starts the spin jump (state
; $0C, where spin_fire_weapon_1/2 fire both weapons around).
player_state_spin_stance:
	jsr	a:set_player_box_standing
	jsl	f:check_bomb_button
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	ldy	a:PLAYER_PLATFORM,x
	beq	@check_floor
	stz	a:PLAYER_PLATFORM,x
	bit	#$0080
	beq	@check_floor
	clc
	lda	OBJ_X,x
	adc	a:$001A,y
	sta	OBJ_X,x
	clc
	lda	OBJ_Y,x
	adc	a:$001E,y
	sta	OBJ_Y,x
	bra	@level
@left_state:
	; (not executed in the CDL traces)
	rtl
@check_floor:
	jsl	f:check_walls_and_floor
	lda	OBJ_STATE,x
	cmp	#$000B
	bne	@left_state
	lda	zp_C4
	bne	@on_floor
	brl	start_player_fall
@on_floor:
	; zp_C4 from check_floor_tiles: bit 3 = a slope rising to the right
	; (its snap routines lower y as x grows), bit 4 = falling to the right.
	; Stance pose offset: 8 facing uphill, $10 facing downhill.
	lda	zp_C4
	bit	#$0008
	bne	@slope_up_right
	bit	#$0010
	bne	@slope_down_right
@level:
	lda	#$0000
	bra	@have_offset
@slope_down_right:
	lda	OBJ_FACING,x
	bne	@facing_uphill
@facing_downhill:
	lda	#$0010
	bra	@have_offset
@slope_up_right:
	lda	OBJ_FACING,x
	bne	@facing_downhill
@facing_uphill:
	lda	#$0008
@have_offset:
	ldy	$30,x
	beq	@set_pose
	dec	$30,x
	clc
	adc	$30,x
@set_pose:
	lsr	a
	tay
	lda	a:spin_stance_poses,y
	and	#$00FF
	sta	PLAYER_POSE,x
	lda	$30,x
	bne	@return
	lda	a:PLAYER_SPIN,x
	beq	@end_stance
	lda	PLAYER_JOY_HELD,x
	bit	button_fire
	beq	@return
	lda	#$FFFA	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$070A
	sta	$32,x
	stz	$34,x
	stz	$36,x
	inc	OBJ_STATE,x
@return:
	rtl
@end_stance:
	lda	#$0000
	sta	OBJ_STATE,x
	stz	$30,x
	rtl

; (no caller found; decoded because it follows the end of a routine)
; No caller: a copy of the spin jump firing (both weapons around), never
; run.
player_state_spin_jump_unused:
	; (not executed in the CDL traces)
	jsr	a:set_player_box_jumping
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsl	f:animate_player_somersault
	jsl	f:check_bomb_button
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
	stz	$38,x
	lda	OBJ_Y_VEL,x
	bmi	@gravity
	cmp	#$0006
	bcs	@check_collision
@gravity:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0C00
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@check_collision:
	bpl	@falling
	jsl	f:dying_check_ceiling_walls
@spin_state:
	lda	#$000C
	sta	OBJ_STATE,x
	rtl
@falling:
	jsl	f:dying_check_floor_walls
	lda	OBJ_STATE,x
	bne	@spin_state
	rtl
hang_climb_return:
	rtl

; State $0D (seen in stage 6): hanging like state 1, but a wall at either
; side (hang_climb_check_walls) switches to climbing (states 2 / 5); aims
; through tbl_hang_climb_aim (the same entries as tbl_hang_aim).
player_state_hang_climb:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	jsl	f:hang_climb_check_walls
	lda	OBJ_STATE,x
	cmp	#$000D
	bne	hang_climb_return
	lda	zp_C4
	bne	@on_bar
	brl	start_player_fall_from_hang
@on_bar:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	@aim
	lda	PLAYER_AIM,x
	bit	#$0008
	beq	@aim
	brl	start_player_fall_from_hang
@aim:
	stz	zp_14
	lda	PLAYER_AIM,x
	phx
	asl	a
	tax
	lda	f:tbl_hang_climb_aim,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hang_climb_aim:
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

hang_aim_none:
	lda	#$004A
	sta	PLAYER_POSE,x
	lda	OBJ_FACING,x
	beq	hang_fire_right
	brl	hang_fire_left

hang_aim_right:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004A
	sta	PLAYER_POSE,x
	bra	hang_fire_right
@animate:
	jsl	f:animate_hang_move_right
; Fire at angle $20 (right) from the hanging pose.
hang_fire_right:
	lda	#$0020
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFDF	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_up:
	lda	#$0052
	sta	PLAYER_POSE,x
	lda	#$0000
	sta	zp_12
	ldy	#$FFFE	; [num]
	lda	OBJ_FACING,x
	bne	@set_muzzle
	ldy	#$FFF8	; [num]
@set_muzzle:
	sty	zp_14
	lda	#$FFC0	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_up_right:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004C
	sta	PLAYER_POSE,x
	bra	@fire
@animate:
	jsl	f:animate_hang_move_right
@fire:
	lda	#$0010
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFCB	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_left:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004A
	sta	PLAYER_POSE,x
	bra	hang_fire_left
@animate:
	jsl	f:animate_hang_move_left
; Fire at angle $60 (left) from the hanging pose.
hang_fire_left:
	lda	#$0060
	sta	zp_12
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFDF	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_up_left:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004C
	sta	PLAYER_POSE,x
	bra	@fire
@animate:
	; (not executed in the CDL traces)
	jsl	f:animate_hang_move_left
@fire:
	lda	#$0070
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFCC	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_down:
	lda	#$0050
	sta	PLAYER_POSE,x
	lda	#$0040
	sta	zp_12
	ldy	#$0000
	lda	OBJ_FACING,x
	bne	@set_muzzle
	ldy	#$FFF6	; [num]
@set_muzzle:
	sty	zp_14
	lda	#$0000
	sta	zp_16
	jml	f:fire_weapon

hang_aim_down_right:
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004E
	sta	PLAYER_POSE,x
	bra	@fire
@animate:
	; (not executed in the CDL traces)
	jsl	f:animate_hang_move_right
@fire:
	lda	#$0030
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFF4	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_down_left:
	; (not executed in the CDL traces)
	lda	PLAYER_LOCKED,x
	beq	@animate
	lda	#$004E
	sta	PLAYER_POSE,x
	bra	@fire
@animate:
	jsl	f:animate_hang_move_left
@fire:
	lda	#$0050
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFF2	; [num]
	sta	zp_16
	jml	f:fire_weapon

; Hand-over-hand animation while moving along a bar (PLAYER_POSE_ADD from
; the bar class in zp_C4).
animate_hang_move_right:
	lda	zp_C4
	ldy	#$0000
	bit	#$0018
	beq	animate_hang_move
	ldy	#$0004
	bit	#$0010
	beq	animate_hang_move
	ldy	#$0008
	bra	animate_hang_move

animate_hang_move_left:
	lda	zp_C4
	ldy	#$0000
	bit	#$0018
	beq	animate_hang_move
	ldy	#$0004
	bit	#$0008
	beq	animate_hang_move
	ldy	#$0008
; In: Y = pose offset (0/4/8, from the bar class bits $18 of zp_C4).
animate_hang_move:
	tya
	clc
	adc	#$003E
	sta	a:PLAYER_POSE_ADD,x
	lda	stage_frame_mod8
	bne	@check_pose
	inc	PLAYER_POSE,x
@check_pose:
	lda	PLAYER_POSE,x
	cmp	#$0004
	bcc	@return
	stz	PLAYER_POSE,x
@return:
	rtl

; Wall tiles (TILE_CLIMBABLE) 32 pixels above the feet at x and x+6: climb
; (state 5 / 2) and snap to the tile.
hang_climb_check_walls:
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
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
	bit	#TILE_CLIMBABLE
	beq	check_ceiling_hang_height
	lda	#$0002
	sta	OBJ_STATE,x
	brl	snap_x_left_to_tile

check_ceiling_hang_height:
	lda	#$FFD0	; [num]

; Classifies the collision tiles at y + A (x and x+6) like check_hang_bar
; but with the ceiling bits (TILE_CEILING_MASK; slopes TILE_CEILING_SLOPES);
; sets zp_C4 and snaps (a ceiling to hang from, state $0D). The tree and its
; label names are those of check_floor_tiles.
check_ceiling_at_offset:
	sta	zp_02
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	lda	zp_06
	bit	#TILE_CEILING_MASK
	beq	@right_none
	bit	#TILE_CEILING_SLOPES
	beq	@right_level
	bit	#TILE_FLIPPED
	bne	@right_fall
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@right_rise_upper
	bne	@right_rise_lower
@right_fall:
	bit	#TILE_CEILING_SLOPE_LOWER
	bne	@to_right_fall_lower
	brl	@right_fall_upper
@to_right_fall_lower:
	beq	@right_none
	brl	@right_fall_lower
@right_none:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	bne	@none_left_ceiling
	brl	@none
@none_left_ceiling:
	bit	#TILE_CEILING_SLOPES
	bne	@none_left_slope
	brl	@level_partial
@none_left_slope:
	bit	#TILE_FLIPPED
	beq	@none_left_rise
	; (not executed in the CDL traces)
	bit	#TILE_CEILING_SLOPE_LOWER
	bne	@none_left_fall_lower
	brl	@none
@none_left_fall_lower:
	beq	@none_left_rise
	brl	@none
@none_left_rise:
	bit	#TILE_CEILING_SLOPE_LOWER
	bne	@none_left_rise_lower
	; (not executed in the CDL traces)
	brl	@rise_below_high
@none_left_rise_lower:
	beq	@right_level
	brl	@rise
@right_level:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	bne	@level_left_ceiling
	brl	@level_partial
@level_left_ceiling:
	bit	#TILE_CEILING_SLOPES
	bne	@level_left_slope
	brl	@level
@level_left_slope:
	; (not executed in the CDL traces)
	bit	#TILE_FLIPPED
	beq	@level_left_rise
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@level
	bne	@none
@level_left_rise:
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@rise_below_high
	bne	@rise
@right_rise_upper:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	beq	@none
	bit	#TILE_CEILING_SLOPES
	beq	@level
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@rise_below_high
	bne	@rise
@right_rise_lower:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	beq	@none
	bit	#TILE_CEILING_SLOPES
	beq	@none
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@rise_below_high
	bne	@rise
@right_fall_upper:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	beq	@fall_below_high
	bit	#TILE_CEILING_SLOPES
	beq	@fall_below_high
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@fall_below_high
	bne	@fall_below_high
@right_fall_lower:
	lda	zp_04
	bit	#TILE_CEILING_MASK
	beq	@fall
	bit	#TILE_CEILING_SLOPES
	beq	@fall
	bit	#TILE_CEILING_SLOPE_LOWER
	beq	@fall
	bne	@fall
@level_partial:
	lda	#$8000	; [num]
	sta	zp_C4
	rtl
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

; unused_ceiling_result_*: never reached (no branch or pointer leads here).
; Each sets zp_C4 and goes to a snap routine, like the outcomes of
; check_ceiling_at_offset just above (@level_partial-@fall): leftovers of
; that decision tree.
; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B07F:
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	zp_C4
	rtl

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B085:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	zp_C4
	brl	snap_y_down_to_tile

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B08D:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right_below

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B095:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right_below

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B09D:
	; (not executed in the CDL traces)
	stz	zp_C4
	rtl

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0A0:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0A8:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	stop_y_slope_up_right_below_high

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0B0:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0B8:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	stop_y_slope_down_right_below_high

; Body box and PLAYER_CENTER_X/Y for the hanging states, from OBJ_FACING.
set_player_box_hanging:
	ldy	OBJ_FACING,x
	lda	OBJ_X,x
	adc	a:hang_box_left_offsets,y
	sta	PLAYER_HITBOX_LEFT,x
	adc	a:hang_box_widths,y
	sta	PLAYER_HITBOX_RIGHT,x
	adc	a:hang_center_x_offsets,y
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	adc	#$FFF8
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0008
	sta	a:PLAYER_CENTER_Y,x
	rts

; State $11 (stage 4, seen in the emulator): riding the hover bike (bobs
; between y $B2 and $BA); jump leaves it. Falls into
; player_state_bike_intro.
player_state_bike:
	jsl	f:check_bomb_button
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	@alive
	jml	f:kill_player
@alive:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	player_state_bike_intro
	lda	#$0002
	sta	$34,x
	brl	start_player_jump

; State $12: on the bike without the kill and jump checks (driving in at the
; start of stage 4); aims and fires from bike_aim_angles...
player_state_bike_intro:
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	#$FFFC
	sta	a:PLAYER_CENTER_X,x
	lda	$34,x
	bne	@sinking
	lda	OBJ_Y,x
	cmp	#$00B2
	bcs	@rising
	lda	#$0002
	sta	$34,x
	bra	@accel_down
@rising:
	lda	$1D,x
	bpl	@accel_up
	cmp	#$FFC0	; [num]
	bcc	@set_box
@accel_up:
	sec
	lda	OBJ_Y_VEL_SUB,x
	sbc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	bra	@set_box
@sinking:
	lda	OBJ_Y,x
	cmp	#$00BA
	bcc	@still_sinking
	stz	$34,x
	bra	@accel_up
@still_sinking:
	lda	$1D,x
	bmi	@accel_down
	cmp	#$0040
	bcs	@set_box
@accel_down:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@set_box:
	clc
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFDC
	sta	PLAYER_HITBOX_TOP,x
	adc	#$000E
	sta	a:PLAYER_CENTER_Y,x
	lda	PLAYER_AIM,x
	asl	a
	tay
	lda	a:bike_aim_angles,y
	sta	zp_12
	lda	a:bike_aim_poses,y
	sta	PLAYER_POSE,x
	lda	rng_temp
	lsr	a
	sta	a:PLAYER_POSE_ADD,x
	lda	a:bike_aim_muzzle_x,y
	sta	zp_14
	lda	a:bike_aim_muzzle_y,y
	sta	zp_16
	jml	f:fire_weapon
