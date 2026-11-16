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
	bcs	loc_01A564
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	brl	animate_player_somersault
loc_01A564:
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
	beq	loc_01A60B
	txy
	ldx	#$0AC0
	cpy	#$0200
	beq	loc_01A5AD
	ldx	#$0D40
loc_01A5AD:
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
	beq	loc_01A5C8
	; (not executed in the CDL traces)
	tyx
	bra	loc_01A60B
loc_01A5C8:
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
loc_01A60B:
	lda	$36,x
	beq	loc_01A620
	clc
	lda	$34,x
	adc	#$4800
	sta	$34,x
	lda	$36,x
	adc	#$0000
	sta	$36,x
	bra	loc_01A622
loc_01A620:
	stz	$34,x
loc_01A622:
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
	beq	loc_01A654
	lda	joy1_held
	sta	PLAYER_JOY_HELD,x
	lda	joy1_pressed
	sta	PLAYER_JOY_PRESSED,x
	lda	PLAYER_INVULN_TIMER,x
	beq	loc_01A64D
	dec	PLAYER_INVULN_TIMER,x
	bne	loc_01A643
	lda	OBJ_FLAGS,x
	and	#$FFFD
	sta	OBJ_FLAGS,x
loc_01A643:
	bit	#$0003
	bne	loc_01A64D
	lda	#$3200
	bra	loc_01A650
loc_01A64D:
	lda	#$3A00
loc_01A650:
	jsl	f:read_player_input
loc_01A654:
	jsr	a:update_bomb
	ldx	#$0240
	lda	a:p2_lives
	beq	loc_01A687
	lda	joy2_held
	sta	PLAYER_JOY_HELD,x
	lda	joy2_pressed
	sta	PLAYER_JOY_PRESSED,x
	lda	PLAYER_INVULN_TIMER,x
	beq	loc_01A680
	dec	PLAYER_INVULN_TIMER,x
	bne	loc_01A676
	lda	OBJ_FLAGS,x
	and	#$FFFD
	sta	OBJ_FLAGS,x
loc_01A676:
	bit	#$0003
	bne	loc_01A680
	lda	#$3220
	bra	loc_01A683
loc_01A680:
	lda	#$3C20
loc_01A683:
	jsl	f:read_player_input
loc_01A687:
	jsr	a:update_bomb
	jsl	f:run_bg1_scroll_mode
	jsl	f:run_bg2_scroll_mode
	lda	a:p1_lives
	beq	loc_01A6B0
	ldx	#$0200
	jsl	f:run_player_state
	lda	stage_frame_odd
	beq	loc_01A6B0
	lda	#$6000
	sta	zp_B8
	lda	#$6100
	sta	zp_BA
	jsl	f:set_player_frame
loc_01A6B0:
	lda	a:p2_lives
	beq	@return
	ldx	#$0240
	jsl	f:run_player_state
	lda	stage_frame_odd
	bne	@return
	lda	#$6200
	sta	zp_B8
	lda	#$6300
	sta	zp_BA
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
	bne	loc_01A72A
	lda	#$0040
	sta	PLAYER_INVULN_TIMER,x
	lda	#PLAYER_STATE_BIKE
	sta	OBJ_STATE,x
loc_01A72A:
	stz	PLAYER_AIM,x
	cpx	#$0240
	bne	loc_01A739
	cmp	#$0058
	bcc	loc_01A739
	brl	move_player_unless_locked
loc_01A739:
	lda	OBJ_X_VEL,x
	bpl	loc_01A745
	cmp	#$FFFE	; [num]
	bcs	loc_01A745
	brl	move_player_unless_locked
loc_01A745:
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
	beq	loc_01A76B
	lda	#$0002
	sta	PLAYER_AIM,x
	bra	loc_01A775
loc_01A76B:
	bit	#$0400
	beq	loc_01A775
	lda	#$0008
	sta	PLAYER_AIM,x
loc_01A775:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	loc_01A794
	lda	PLAYER_AIM,x
	ora	#$0001
	sta	PLAYER_AIM,x
	lda	PLAYER_JOY_HELD,x
	bit	button_stand_still
	beq	loc_01A78C
	brl	move_player_unless_locked
loc_01A78C:
	lda	#$0002
	sta	OBJ_X_VEL,x
	brl	move_player_unless_locked
loc_01A794:
	bit	#$0200
	bne	loc_01A79C
	brl	move_player_unless_locked
loc_01A79C:
	lda	#$0002
	sta	OBJ_FACING,x
	lda	PLAYER_AIM,x
	ora	#$0004
	sta	PLAYER_AIM,x
	lda	PLAYER_JOY_HELD,x
	bit	button_stand_still
	beq	loc_01A7B1
	brl	move_player_unless_locked
loc_01A7B1:
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	move_player_unless_locked

; Input of state $10 (hanging from a moving object).
input_hang_object:
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	lda	PLAYER_JOY_HELD,x
	bit	a:hang_lock_buttons
	beq	loc_01A7C6
	inc	PLAYER_LOCKED,x
loc_01A7C6:
	bit	#$0100
	beq	loc_01A7D4
	stz	OBJ_FACING,x
	lda	#$0001
	sta	PLAYER_AIM,x
	bra	loc_01A7E3
loc_01A7D4:
	bit	#$0200
	beq	loc_01A7E3
	lda	#$0002
	sta	OBJ_FACING,x
	lda	#$0004
	sta	PLAYER_AIM,x
loc_01A7E3:
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	loc_01A7F4
	lda	PLAYER_AIM,x
	ora	#$0008
	sta	PLAYER_AIM,x
	brl	move_player_unless_locked
loc_01A7F4:
	bit	#$0800
	bne	loc_01A7FC
	brl	move_player_unless_locked
loc_01A7FC:
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
	beq	loc_01A81F
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	bra	loc_01A82C
loc_01A81F:
	bit	#$0200
	beq	loc_01A82E
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
loc_01A82C:
	sta	OBJ_X_VEL,x
loc_01A82E:
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	loc_01A83F
	lda	#$97FF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	bra	loc_01A84C
loc_01A83F:
	bit	#$0400
	beq	loc_01A84E
	lda	#$6800
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0001
loc_01A84C:
	sta	OBJ_Y_VEL,x
loc_01A84E:
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
	beq	loc_01A86F
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_01A8A9
	dec	a:obj_slots+31*OBJ_SIZE+OBJ_STATE
loc_01A86F:
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
loc_01A8A9:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	loc_01A8C1
	lda	PLAYER_CONTACT,x
	bit	#$0200
	bne	loc_01A8E1
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	bra	loc_01A8CE
loc_01A8C1:
	bit	#$0200
	beq	loc_01A8E1
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
loc_01A8CE:
	sta	OBJ_X_VEL_SUB,x
	lda	a:tank_moving
	bne	loc_01A8F0
	inc	a:tank_moving
	lda	#$001E
	jsl	f:queue_sound
	bra	loc_01A8F0
loc_01A8E1:
	lda	a:tank_moving
	beq	loc_01A8F0
	stz	a:tank_moving
	lda	#$001F
	jsl	f:queue_sound
loc_01A8F0:
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
	bcs	loc_01A919
	sec
	lda	#$000A
	sbc	zp_00
	sta	a:tank_move_dx
	brl	move_player
loc_01A919:
	sec
	sbc	zp_00
	sta	a:tank_move_dx
	bne	loc_01A924
	brl	move_player
loc_01A924:
	bpl	loc_01A92F
	lda	#$0001
	sta	a:obj_slots+31*OBJ_SIZE+$34
	brl	move_player
loc_01A92F:
	lda	#$0002
	sta	a:obj_slots+31*OBJ_SIZE+$34
	brl	move_player

; Hanging (states 1, $0D): like input_ground, but fire also stops the
; player (hang_lock_buttons = fire | stand still).
input_hang:
	lda	a:hang_lock_buttons
	bra	loc_01A93F

; On the ground (state 0): button_stand_still sets PLAYER_LOCKED; left/right
; walk at 1.40 pixels a frame unless a solid object blocks that side
; (PCONTACT_BLOCK_*), and set OBJ_FACING and PLAYER_AIM; up/down add to
; PLAYER_AIM.  Ends with move_player_unless_locked.
input_ground:
	lda	button_stand_still
loc_01A93F:
	sta	zp_00
	lda	PLAYER_JOY_HELD,x
	bit	zp_00
	beq	loc_01A94B
	inc	PLAYER_LOCKED,x
	bra	loc_01A958
loc_01A94B:
	bit	#$0300
	bne	loc_01A958
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	bra	loc_01A999

input_air:
	lda	PLAYER_JOY_HELD,x
loc_01A958:
	bit	#$0100
	beq	loc_01A977
	stz	OBJ_FACING,x
	lda	PLAYER_CONTACT,x
	bit	#$0400
	bne	loc_01A970
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
loc_01A970:
	lda	#$0001
	sta	PLAYER_AIM,x
	bra	loc_01A999
loc_01A977:
	lda	PLAYER_JOY_HELD,x
	bit	#$0200
	beq	loc_01A999
	lda	#$0002
	sta	OBJ_FACING,x
	lda	PLAYER_CONTACT,x
	bit	#$0200
	bne	loc_01A994
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
loc_01A994:
	lda	#$0004
	sta	PLAYER_AIM,x
loc_01A999:
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	loc_01A9A9
	lda	PLAYER_AIM,x
	ora	#$0008
	sta	PLAYER_AIM,x
	bra	move_player_unless_locked
loc_01A9A9:
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
	beq	loc_01A9D5
	lda	#$0001
	sta	OBJ_Y_VEL,x
	lda	#$6800
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0008
	sta	PLAYER_AIM,x
	bra	loc_01A9EB
loc_01A9D5:
	lda	PLAYER_JOY_HELD,x
	bit	#$0800
	beq	loc_01A9F4
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$0002
	sta	PLAYER_AIM,x
loc_01A9EB:
	lda	PLAYER_JOY_HELD,x
	bit	a:hang_lock_buttons
	beq	loc_01A9F8
	inc	PLAYER_LOCKED,x
loc_01A9F4:
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
loc_01A9F8:
	lda	PLAYER_JOY_HELD,x
	bit	#$0100
	beq	loc_01AA08
	lda	PLAYER_AIM,x
	ora	#$0001
	sta	PLAYER_AIM,x
	bra	move_player
loc_01AA08:
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
	bcc	loc_01AA3C
	cmp	#$00F0
	bcc	loc_01AA3F
	lda	#$00F0
	bra	loc_01AA3F
loc_01AA3C:
	lda	#$000A
loc_01AA3F:
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
	beq	loc_01AA61
	cmp	#$0031
	bcs	loc_01AA61
	lda	#$0031
loc_01AA61:
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
	bmi	loc_01AA8A
	cmp	#$00FF
	bcc	loc_01AA8A
	lda	#$0004
	sta	PLAYER_CONTACT,x
loc_01AA8A:
	lda	$32,x
	beq	loc_01AA99
	and	#$00FF
	bne	loc_01AA97
	stz	$32,x
	bra	loc_01AA99
loc_01AA97:
	dec	$32,x
loc_01AA99:
	lda	PLAYER_FIRE_DELAY_1,x
	dec	a
	cmp	#$0008
	bcc	loc_01AAA4
	lda	#$0000
loc_01AAA4:
	sta	PLAYER_FIRE_DELAY_1,x
	lda	PLAYER_FIRE_DELAY_2,x
	dec	a
	cmp	#$0008
	bcc	loc_01AAB1
	lda	#$0000
loc_01AAB1:
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
	beq	loc_01AB1E
	clc
	adc	a:PLAYER_BOMB_SPEED,x
	cmp	#$00FF
	bcc	loc_01AB05
	lda	#$0000
loc_01AB05:
	sta	a:PLAYER_BOMB_RADIUS,x
	clc
	lda	a:PLAYER_BOMB_SPEED_SUB,x
	adc	#$0800
	sta	a:PLAYER_BOMB_SPEED_SUB,x
	lda	a:PLAYER_BOMB_SPEED,x
	adc	#$0000
	sta	a:PLAYER_BOMB_SPEED,x
	jsr	a:bomb_hit_targets
loc_01AB1E:
	rts

; Every other frame per player (stage_frame_odd): each object of the
; target list overlapping the square of half-size PLAYER_BOMB_RADIUS around
; PLAYER_BOMB_X/Y gets OBJ_HIT = $0100 and, if OBJF_TARGET and not
; OBJF_INVULNERABLE, loses 1 OBJ_HP; destroyed objects score
; type_scores[OBJ_TYPE] for the player (sub_00B829).
bomb_hit_targets:
	lda	stage_frame_odd
	bne	loc_01AB2A
	cpx	#$0200
	bne	loc_01ABA7
	beq	loc_01AB2F
loc_01AB2A:
	cpx	#$0240
	bne	loc_01ABA7
loc_01AB2F:
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
	beq	loc_01ABA6
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
loc_01ABA6:
	tyx
loc_01ABA7:
	rts

; (no caller found; decoded because it follows the end of a routine)
; Unused debug code (no caller): with Select held, Up cycles the difficulty
; (and sets PLAYER_BOMBS to it), A sets one life and kills the player, B
; kills the player, X sets lives, bombs and barrier to $8000.
debug_player_keys:
	; (not executed in the CDL traces)
	lda	PLAYER_JOY_HELD,x
	bit	#$2000
	beq	loc_01ABFE
	lda	PLAYER_JOY_PRESSED,x
	bit	#$0800
	beq	loc_01ABCE
	inc	difficulty
	inc	difficulty
	lda	difficulty
	and	#$0006
	cmp	#$0006
	bne	loc_01ABC7
	lda	#$0000
loc_01ABC7:
	sta	difficulty
	sta	a:PLAYER_BOMBS,x
	bra	loc_01ABFE
loc_01ABCE:
	lda	PLAYER_JOY_HELD,x
	bit	#$0080
	beq	loc_01ABDD
	lda	#$0001
	sta	a:PLAYER_LIVES,x
	bra	loc_01ABE4
loc_01ABDD:
	lda	PLAYER_JOY_HELD,x
	bit	#$8000
	beq	loc_01ABEB
loc_01ABE4:
	lda	#$0004
	sta	PLAYER_CONTACT,x
	bra	loc_01ABFE
loc_01ABEB:
	lda	PLAYER_JOY_HELD,x
	bit	#$0040
	beq	loc_01ABFE
	lda	#$8000	; [num]
	sta	a:PLAYER_LIVES,x
	sta	a:PLAYER_BOMBS,x
	sta	a:PLAYER_BARRIER,x
loc_01ABFE:
	rts

; State $13 (set by the ending sequence for each player still in the game):
; pose animation (ending_poses), then state $14.
player_state_ending:
	dec	$34,x
	bpl	loc_01AC1A
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
loc_01AC1A:
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
	bmi	loc_01AC2F
	dec	$34,x
	rtl
loc_01AC2F:
	lda	$30,x
	cmp	#$000C
	bcs	loc_01AC53
	dec	$36,x
	bpl	loc_01AC52
	ldy	#$0004
	sty	$36,x
	inc	$30,x
	inc	$30,x
	cpx	#$0200
	beq	loc_01AC4C
	; (not executed in the CDL traces)
	clc
	adc	#$000C
loc_01AC4C:
	tay
	lda	a:ending_wave_poses,y
	sta	PLAYER_POSE,x
loc_01AC52:
	rtl
loc_01AC53:
	lda	PLAYER_JOY_HELD,x
	bit	#$4000
	beq	loc_01AC52
	stz	$30,x
	lda	#$0010
	sta	$36,x
	rtl
loc_01AC62:
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
	beq	loc_01AC83
	jml	f:kill_player
loc_01AC83:
	ldy	a:PLAYER_PLATFORM,x
	beq	loc_01ACA3
	stz	a:PLAYER_PLATFORM,x
	bit	#$0080
	beq	loc_01ACA3
	clc
	lda	OBJ_X,x
	adc	a:$001A,y
	sta	OBJ_X,x
	clc
	lda	OBJ_Y,x
	adc	a:$001E,y
	sta	OBJ_Y,x
	bra	loc_01ACC1
loc_01ACA2:
	; (not executed in the CDL traces)
	rtl
loc_01ACA3:
	jsl	f:check_walls_and_floor
	lda	OBJ_STATE,x
	cmp	#$000B
	bne	loc_01ACA2
	lda	zp_C4
	bne	loc_01ACB5
	brl	loc_0182CD
loc_01ACB5:
	lda	zp_C4
	bit	#$0008
	bne	loc_01ACCF
	bit	#$0010
	bne	loc_01ACC6
loc_01ACC1:
	lda	#$0000
	bra	loc_01ACD6
loc_01ACC6:
	lda	OBJ_FACING,x
	bne	loc_01ACD3
loc_01ACCA:
	lda	#$0010
	bra	loc_01ACD6
loc_01ACCF:
	lda	OBJ_FACING,x
	bne	loc_01ACCA
loc_01ACD3:
	lda	#$0008
loc_01ACD6:
	ldy	$30,x
	beq	loc_01ACDF
	dec	$30,x
	clc
	adc	$30,x
loc_01ACDF:
	lsr	a
	tay
	lda	a:spin_stance_poses,y
	and	#$00FF
	sta	PLAYER_POSE,x
	lda	$30,x
	bne	@return
	lda	a:PLAYER_SPIN,x
	beq	loc_01AD09
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
loc_01AD09:
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
	beq	loc_01AD1F
	jml	f:kill_player
loc_01AD1F:
	jsl	f:animate_player_somersault
	jsl	f:check_bomb_button
	lda	#$FFF2	; [num]
	ldy	OBJ_FACING,x
	bne	loc_01AD31
	lda	#$FFF6	; [num]
loc_01AD31:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_2
	stz	$38,x
	lda	#$0002
	ldy	OBJ_FACING,x
	bne	loc_01AD48
	lda	#$0006
loc_01AD48:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_1
	stz	$38,x
	lda	OBJ_Y_VEL,x
	bmi	loc_01AD5E
	cmp	#$0006
	bcs	loc_01AD6D
loc_01AD5E:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0C00
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_01AD6D:
	bpl	loc_01AD79
	jsl	f:dying_check_ceiling_walls
loc_01AD73:
	lda	#$000C
	sta	OBJ_STATE,x
	rtl
loc_01AD79:
	jsl	f:dying_check_floor_walls
	lda	OBJ_STATE,x
	bne	loc_01AD73
	rtl
loc_01AD82:
	rtl

; State $0D (seen in stage 6): hanging like state 1, but a wall at either
; side (hang_climb_check_walls) switches to climbing (states 2 / 5); aims
; through tbl_hang_climb_aim (the same entries as tbl_hang_aim).
player_state_hang_climb:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	loc_01AD8E
	jml	f:kill_player
loc_01AD8E:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	jsl	f:hang_climb_check_walls
	lda	OBJ_STATE,x
	cmp	#$000D
	bne	loc_01AD82
	lda	zp_C4
	bne	loc_01ADA7
	brl	loc_0182C8
loc_01ADA7:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_01ADB7
	lda	PLAYER_AIM,x
	bit	#$0008
	beq	loc_01ADB7
	brl	loc_0182C8
loc_01ADB7:
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
	beq	loc_01ADFD
	brl	loc_01AE60

hang_aim_right:
	lda	PLAYER_LOCKED,x
	beq	loc_01ADF9
	lda	#$004A
	sta	PLAYER_POSE,x
	bra	loc_01ADFD
loc_01ADF9:
	jsl	f:animate_hang_move_right
loc_01ADFD:
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
	bne	loc_01AE24
	ldy	#$FFF8	; [num]
loc_01AE24:
	sty	zp_14
	lda	#$FFC0	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_up_right:
	lda	PLAYER_LOCKED,x
	beq	loc_01AE3A
	lda	#$004C
	sta	PLAYER_POSE,x
	bra	loc_01AE3E
loc_01AE3A:
	jsl	f:animate_hang_move_right
loc_01AE3E:
	lda	#$0010
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFCB	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_left:
	lda	PLAYER_LOCKED,x
	beq	loc_01AE5C
	lda	#$004A
	sta	PLAYER_POSE,x
	bra	loc_01AE60
loc_01AE5C:
	jsl	f:animate_hang_move_left
loc_01AE60:
	lda	#$0060
	sta	zp_12
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFDF	; [num]
	sta	zp_16
	jml	f:fire_weapon

hang_aim_up_left:
	lda	PLAYER_LOCKED,x
	beq	loc_01AE7E
	lda	#$004C
	sta	PLAYER_POSE,x
	bra	loc_01AE82
loc_01AE7E:
	; (not executed in the CDL traces)
	jsl	f:animate_hang_move_left
loc_01AE82:
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
	bne	loc_01AEA9
	ldy	#$FFF6	; [num]
loc_01AEA9:
	sty	zp_14
	lda	#$0000
	sta	zp_16
	jml	f:fire_weapon

hang_aim_down_right:
	lda	PLAYER_LOCKED,x
	beq	loc_01AEBF
	lda	#$004E
	sta	PLAYER_POSE,x
	bra	loc_01AEC3
loc_01AEBF:
	; (not executed in the CDL traces)
	jsl	f:animate_hang_move_right
loc_01AEC3:
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
	beq	loc_01AEE1
	lda	#$004E
	sta	PLAYER_POSE,x
	bra	loc_01AEE5
loc_01AEE1:
	jsl	f:animate_hang_move_left
loc_01AEE5:
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
	beq	loc_01AF24
	ldy	#$0004
	bit	#$0010
	beq	loc_01AF24
	ldy	#$0008
	bra	loc_01AF24

animate_hang_move_left:
	lda	zp_C4
	ldy	#$0000
	bit	#$0018
	beq	loc_01AF24
	ldy	#$0004
	bit	#$0008
	beq	loc_01AF24
	ldy	#$0008
loc_01AF24:
	tya
	clc
	adc	#$003E
	sta	a:PLAYER_POSE_ADD,x
	lda	stage_frame_mod8
	bne	loc_01AF32
	inc	PLAYER_POSE,x
loc_01AF32:
	lda	PLAYER_POSE,x
	cmp	#$0004
	bcc	@return
	stz	PLAYER_POSE,x
@return:
	rtl

; Wall tiles (collision bit 1) 32 pixels above the feet at x and x+6: climb
; (state 5 / 2) and snap to the tile.
hang_climb_check_walls:
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	beq	loc_01AF54
	lda	#$0005
	sta	OBJ_STATE,x
	brl	snap_x_right_to_tile
loc_01AF54:
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	beq	check_ceiling_hang_height
	lda	#$0002
	sta	OBJ_STATE,x
	brl	snap_x_left_to_tile

check_ceiling_hang_height:
	lda	#$FFD0	; [num]

; Classifies the collision tiles at y + A (x and x+6) like check_hang_bar
; but with the solid bits ($0182); sets zp_C4 and snaps (bumping a ceiling).
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
	bit	#$0182
	beq	loc_01AFAC
	bit	#$0180
	beq	loc_01AFDD
	bit	#$0001
	bne	loc_01AF9F
	bit	#$0080
	beq	loc_01B002
	bne	loc_01B015
loc_01AF9F:
	bit	#$0080
	bne	loc_01AFA7
	brl	loc_01B028
loc_01AFA7:
	beq	loc_01AFAC
	brl	loc_01B03B
loc_01AFAC:
	lda	zp_04
	bit	#$0182
	bne	loc_01AFB6
	brl	loc_01B05C
loc_01AFB6:
	bit	#$0180
	bne	loc_01AFBE
	brl	loc_01B04E
loc_01AFBE:
	bit	#$0001
	beq	loc_01AFD0
	; (not executed in the CDL traces)
	bit	#$0080
	bne	loc_01AFCB
	brl	loc_01B05C
loc_01AFCB:
	beq	loc_01AFD0
	brl	loc_01B05C
loc_01AFD0:
	bit	#$0080
	bne	loc_01AFD8
	; (not executed in the CDL traces)
	brl	loc_01B05F
loc_01AFD8:
	beq	loc_01AFDD
	brl	loc_01B067
loc_01AFDD:
	lda	zp_04
	bit	#$0182
	bne	loc_01AFE7
	brl	loc_01B04E
loc_01AFE7:
	bit	#$0180
	bne	loc_01AFEF
	brl	loc_01B054
loc_01AFEF:
	; (not executed in the CDL traces)
	bit	#$0001
	beq	loc_01AFFB
	bit	#$0080
	beq	loc_01B054
	bne	loc_01B05C
loc_01AFFB:
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B002:
	lda	zp_04
	bit	#$0182
	beq	loc_01B05C
	bit	#$0180
	beq	loc_01B054
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B015:
	lda	zp_04
	bit	#$0182
	beq	loc_01B05C
	bit	#$0180
	beq	loc_01B05C
	bit	#$0080
	beq	loc_01B05F
	bne	loc_01B067
loc_01B028:
	lda	zp_04
	bit	#$0182
	beq	loc_01B06F
	bit	#$0180
	beq	loc_01B06F
	bit	#$0080
	beq	loc_01B06F
	bne	loc_01B06F
loc_01B03B:
	lda	zp_04
	bit	#$0182
	beq	loc_01B077
	bit	#$0180
	beq	loc_01B077
	bit	#$0080
	beq	loc_01B077
	bne	loc_01B077
loc_01B04E:
	lda	#$8000	; [num]
	sta	zp_C4
	rtl
loc_01B054:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_down_to_tile
loc_01B05C:
	stz	zp_C4
	rtl
loc_01B05F:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_01B067:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_01B06F:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_01B077:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

; unused_ceiling_result_*: never reached (no branch or pointer leads here).
; Each sets zp_C4 and goes to a snap routine, like the outcomes of
; check_ceiling_at_offset just above (loc_01B04E-loc_01B077): leftovers of
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
	brl	loc_01961D

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B095:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	loc_019502

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
	brl	loc_019450

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0A8:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0B0:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

; (no caller found; decoded because it follows the end of a routine)
unused_ceiling_result_01B0B8:
	; (not executed in the CDL traces)
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA

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
	beq	loc_01B0F6
	jml	f:kill_player
loc_01B0F6:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	player_state_bike_intro
	lda	#$0002
	sta	$34,x
	brl	loc_0182FD

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
	bne	loc_01B13F
	lda	OBJ_Y,x
	cmp	#$00B2
	bcs	loc_01B125
	lda	#$0002
	sta	$34,x
	bra	loc_01B153
loc_01B125:
	lda	$1D,x
	bpl	loc_01B12E
	cmp	#$FFC0	; [num]
	bcc	loc_01B162
loc_01B12E:
	sec
	lda	OBJ_Y_VEL_SUB,x
	sbc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	bra	loc_01B162
loc_01B13F:
	lda	OBJ_Y,x
	cmp	#$00BA
	bcc	loc_01B14A
	stz	$34,x
	bra	loc_01B12E
loc_01B14A:
	lda	$1D,x
	bmi	loc_01B153
	cmp	#$0040
	bcs	loc_01B162
loc_01B153:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$0800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_01B162:
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
