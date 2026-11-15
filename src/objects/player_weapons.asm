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
	beq	loc_018017
	lda	PLAYER_JOY_HELD,x
	and	#$0030
	beq	@return
	cmp	#$0030
	beq	loc_018017
@return:
	rtl
loc_018017:
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
	lda	#$005A
	jsl	f:queue_sound
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_01804E:
	; (not executed in the CDL traces)
	lda	PLAYER_JOY_HELD,x
	bit	#$4000
	beq	loc_018062
	ldy	#$0012
	lda	stage_frame_odd
	beq	loc_01805F
	ldy	#$0000
loc_01805F:
	sty	a:mosaic_shadow
loc_018062:
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
	sta	a:wram_1780
	clc
	adc	#$0200
	sta	a:wram_178C
	lda	a:player_frames+2,y
	sta	a:wram_1782
	clc
	adc	#$0200
	sta	a:wram_178E
	lda	a:player_frames+4,y
	sta	a:wram_1784
	clc
	adc	#$0200
	sta	a:wram_1790
	lda	a:player_frames+6,y
	sta	a:wram_1786
	clc
	adc	#$0200
	sta	a:wram_1792
	lda	a:player_frames+8,y
	sta	a:wram_1788
	clc
	adc	#$0200
	sta	a:wram_1794
	lda	a:player_frames+10,y
	sta	a:wram_178A
	clc
	adc	#$0200
	sta	a:wram_1796
	stz	$38,x
	lda	OBJ_FACING,x
	bne	loc_0180CB
	lda	a:player_frames+12,y
	sta	OBJ_SPRITE,x
	rtl
loc_0180CB:
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
; No caller (debug): pad 2 sets color math (CGADSUB, COLDATA via wram_1612).
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
	beq	loc_0180F6
	lda	joy2_held
	bit	#$0040
	bne	loc_0180F9
loc_0180F6:
	ldy	#$0000
loc_0180F9:
	sty	a:cgadsub_shadow
	bit	#$4000
	beq	loc_01810A
	lda	a:cgadsub_shadow
	and	#$0012
	sta	a:cgadsub_shadow
loc_01810A:
	lda	a:wram_1612
	sta	a:coldata_shadow
	lda	joy2_pressed
	bit	#$0080
	beq	loc_01811B
	inc	a:wram_1612
	rtl
loc_01811B:
	bit	#$8000
	beq	@return
	dec	a:wram_1612
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; No caller (debug): Select on pad 1 toggles a window test; the buttons
; change TMW, W12SEL, WOBJSEL.
debug_window_keys:
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#$2000
	beq	loc_018134
	lda	a:wram_162C
	eor	#$0001
	sta	a:wram_162C
loc_018134:
	lda	a:wram_162C
	bne	loc_01813C
	brl	loc_0181E1
loc_01813C:
	lda	joy1_pressed
	bit	#$8000
	beq	loc_018156
	lda	a:tmw_shadow
	pha
	inc	a
	and	#$001F
	sta	zp_00
	pla
	and	#$FF00
	ora	zp_00
	sta	a:tmw_shadow
loc_018156:
	lda	joy1_pressed
	bit	#$4000
	beq	loc_018174
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
loc_018174:
	lda	joy1_pressed
	bit	#$0020
	beq	loc_018194
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
loc_018194:
	lda	joy1_pressed
	bit	#$0010
	beq	loc_0181A8
	lda	a:wobjsel_shadow
	clc
	adc	#$0010
	and	#$0030
	sta	a:wobjsel_shadow
loc_0181A8:
	lda	#$00FF
	sta	f:wram_7EF800
	lda	#$F807	; [num]
	sta	f:wram_7EF801
	lda	#$00FF
	sta	f:wram_7EF803
	lda	#$F887	; [num]
	sta	f:wram_7EF804
	lda	#$00FF
	sta	f:wram_7EFA00
	lda	#$FA07	; [num]
	sta	f:wram_7EFA01
	lda	#$00FF
	sta	f:wram_7EFA03
	lda	#$FA87	; [num]
	sta	f:wram_7EFA04
	rtl
loc_0181E1:
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
	beq	loc_018205
	ldx	#$0240
	bra	@loop
loc_018205:
	plx
	rtl

; Object type $6D: the hover bike of a player (stage 4), in slot $0280 or
; $02C0 (field $30 selects the player through data_05AB6C). Follows the
; player; when the player falls back to y >= $A4 it puts them back in
; PLAYER_STATE_BIKE; deleted when the player's state is 1.
update_player_bike:
	ldy	$30,x
	lda	a:data_05AB6C,y
	tay
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_01821B
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_01821B:
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
	lda	a:data_05AB70,y
	sta	OBJ_ATTR,x
	inc	OBJ_STATE,x
	rtl

player_bike_state_01:
	lda	OBJ_TIMER,x
	bmi	loc_01824B
	dec	OBJ_TIMER,x
	bra	loc_01824D
loc_01824B:
	stz	OBJ_SPRITE,x
loc_01824D:
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
	bcc	loc_01827C
	dec	OBJ_Y,x
loc_01827C:
	lda	a:$0016,y
	beq	loc_0182B2
	bmi	loc_0182B2
	lda	a:$000A,y
	sta	OBJ_X,x
	lda	a:$0032,y
	bne	loc_0182B4
	lda	a:$000E,y
	cmp	#$00A4
	bcc	loc_0182B4
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
loc_0182B2:
	dec	OBJ_STATE,x
loc_0182B4:
	rtl
loc_0182B5:
	dec	OBJ_X,x
	lda	#$0000
	bra	loc_0182D0

; Moves 1 pixel right and starts falling (state 4): leaving a wall on the
; left. loc_0182B5 does the same to the left.
start_player_fall_right:
	inc	OBJ_X,x
	lda	#$0000
	bra	loc_0182D0

; Starts a fall (state 4) with $32 = $040A: dropping down from a bar or an
; object (down + jump).
start_player_drop:
	lda	#$040A
	bra	loc_0182D0
loc_0182C8:
	lda	#$020A
	bra	loc_0182D0
loc_0182CD:
	lda	#$010A
loc_0182D0:
	sta	$32,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#$00D3
	sta	PLAYER_POSE,x
	stz	$38,x
	bra	player_state_fall
loc_0182E4:
	lda	#$DFFF	; [num]
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFB	; [num]
	sta	OBJ_Y_VEL,x
	lda	#$0003
	sta	OBJ_STATE,x
	stz	$32,x
	bra	player_state_jump
loc_0182F7:
	dec	OBJ_X,x
	bra	loc_0182FD
loc_0182FB:
	inc	OBJ_X,x
loc_0182FD:
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
	beq	loc_018322
	jml	f:kill_player
loc_018322:
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
	beq	loc_01835F
	jml	f:kill_player
loc_01835F:
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
	bra	loc_0183E9

fall_aim_left:
	lda	#$0060
	sta	zp_12
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	lda	#$00D3
	sta	PLAYER_POSE,x
	bra	loc_0183E9

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
	bra	loc_0183E9

jump_aim_left:
	lda	#$0060
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
loc_0183E9:
	lda	OBJ_STATE,x
	cmp	#$000C
	bne	loc_01841E
	lda	#$FFF2	; [num]
	ldy	OBJ_FACING,x
	bne	loc_0183FA
	lda	#$FFF6	; [num]
loc_0183FA:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_2
	stz	$38,x
	lda	#$0002
	ldy	OBJ_FACING,x
	bne	loc_018411
	lda	#$0006
loc_018411:
	sta	zp_14
	lda	#$FFD8	; [num]
	sta	zp_16
	jsl	f:spin_fire_weapon_1
	bra	loc_018429
loc_01841E:
	jsl	f:fire_weapon
	lda	OBJ_STATE,x
	cmp	#$0003
	bne	loc_01842B
loc_018429:
	stz	$38,x
loc_01842B:
	lda	OBJ_Y_VEL,x
	bmi	loc_018434
	cmp	#$0006
	bcs	loc_018443
loc_018434:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_018443:
	lda	OBJ_Y_VEL,x
	bmi	loc_01844A
	brl	loc_01871A
loc_01844A:
	brl	loc_018682

fall_aim_up:
	lda	#$00D7
	sta	PLAYER_POSE,x
	lda	#$0000
	sta	zp_12
	lda	OBJ_FACING,x
	bne	loc_018460
	lda	#$FFFE	; [num]
	bra	loc_018463
loc_018460:
	lda	#$FFF9	; [num]
loc_018463:
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_up:
	lda	#$0000
	sta	zp_12
	lda	#$FFFC	; [num]
	sta	zp_14
	lda	#$FFD0	; [num]
	sta	zp_16
	brl	loc_0183E9

fall_aim_up_right:
	lda	#$00D5
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_12
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_up_right:
	lda	#$0010
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFD4	; [num]
	sta	zp_16
	brl	loc_0183E9

fall_aim_up_left:
	lda	#$00D5
	sta	PLAYER_POSE,x
	lda	#$0070
	sta	zp_12
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_up_left:
	lda	#$0070
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFD0	; [num]
	sta	zp_16
	brl	loc_0183E9

fall_aim_down:
	lda	#$00DB
	sta	PLAYER_POSE,x
	lda	#$0040
	sta	zp_12
	lda	OBJ_FACING,x
	bne	loc_0184E4
	lda	#$FFF9	; [num]
	bra	loc_0184E4
loc_0184E4:
	lda	#$FFFD	; [num]
	sta	zp_14
	lda	#$FFFC	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_down:
	lda	#$0040
	sta	zp_12
	lda	#$FFF9	; [num]
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	loc_0183E9

fall_aim_down_right:
	lda	#$00D9
	sta	PLAYER_POSE,x
	lda	#$0030
	sta	zp_12
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_down_right:
	lda	#$0030
	sta	zp_12
	lda	#$0008
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	loc_0183E9

fall_aim_down_left:
	lda	#$00D9
	sta	PLAYER_POSE,x
	lda	#$0050
	sta	zp_12
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	brl	loc_0183E9

jump_aim_down_left:
	; (not executed in the CDL traces)
	lda	#$0050
	sta	zp_12
	lda	#$FFF0	; [num]
	sta	zp_14
	lda	#$FFE0	; [num]
	sta	zp_16
	brl	loc_0183E9

; PLAYER_POSE cycles $3A-$3D, every 2 frames going up, every 4 going down.
animate_player_somersault:
	lda	PLAYER_POSE,x
	cmp	#$003A
	bcs	loc_018562
loc_01855C:
	lda	#$003A
	sta	PLAYER_POSE,x
	rtl
loc_018562:
	lda	OBJ_Y_VEL,x
	bpl	loc_01856C
	lda	stage_frame_odd
	bne	loc_018579
	beq	loc_018570
loc_01856C:
	lda	stage_frame_mod4
	bne	loc_018579
loc_018570:
	inc	PLAYER_POSE,x
	lda	PLAYER_POSE,x
	cmp	#$003E
	bcs	loc_01855C
loc_018579:
	rtl

; Classifies the collision tiles under the feet (zp_04 at x, zp_06 at x+6):
; floor, slopes; sets zp_C4 and snaps the player onto the floor.
check_floor_tiles:
	lda	zp_06
	bit	#$807E
	beq	loc_01859F
	bit	#$0078
	beq	loc_0185D0
	bit	#$0001
	bne	loc_018592
	bit	#$0050
	beq	loc_0185F5
	bne	loc_018608
loc_018592:
	bit	#$0050
	bne	loc_01859A
	brl	loc_01861B
loc_01859A:
	beq	loc_01859F
	brl	loc_01862E
loc_01859F:
	lda	zp_04
	bit	#$807E
	bne	loc_0185A9
	brl	loc_01865F
loc_0185A9:
	bit	#$0078
	bne	loc_0185B1
	brl	loc_018649
loc_0185B1:
	bit	#$0001
	beq	loc_0185C3
	bit	#$0050
	bne	loc_0185BE
	brl	loc_01864F
loc_0185BE:
	; (not executed in the CDL traces)
	beq	loc_0185C3
	brl	loc_018672
loc_0185C3:
	bit	#$0050
	bne	loc_0185CB
	brl	loc_018662
loc_0185CB:
	beq	loc_0185D0
	brl	loc_01866A
loc_0185D0:
	lda	zp_04
	bit	#$807E
	bne	loc_0185DA
	brl	loc_018649
loc_0185DA:
	bit	#$0078
	bne	loc_0185E2
	brl	loc_018641
loc_0185E2:
	bit	#$0001
	beq	loc_0185EE
	bit	#$0050
	beq	loc_018649
	bne	loc_018649
loc_0185EE:
	bit	#$0050
	beq	loc_018649
	bne	loc_01866A
loc_0185F5:
	lda	zp_04
	bit	#$807E
	beq	loc_018657
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018662
	; (not executed in the CDL traces)
	bne	loc_01866A
loc_018608:
	lda	zp_04
	bit	#$807E
	beq	loc_018662
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018662
	bne	loc_01866A
loc_01861B:
	lda	zp_04
	bit	#$807E
	beq	loc_018672
	bit	#$0078
	beq	loc_018649
	bit	#$0050
	beq	loc_018672
	bne	loc_018672
loc_01862E:
	lda	zp_04
	bit	#$807E
	beq	loc_01867A
	bit	#$0078
	beq	loc_01867A
	; (not executed in the CDL traces)
	bit	#$0050
	beq	loc_01867A
	bne	loc_01867A
loc_018641:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_up_to_tile
loc_018649:
	lda	#$8002	; [num]
	sta	zp_C4
	rtl
loc_01864F:
	lda	#$0010
	sta	zp_C4
	brl	loc_01961D
loc_018657:
	lda	#$0008
	sta	zp_C4
	brl	loc_019502
loc_01865F:
	stz	zp_C4
	rtl
loc_018662:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_01866A:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_018672:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565
loc_01867A:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_018682:
	jsl	f:check_ceiling_hang_height
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0186AC
	bmi	loc_0186F5
	lda	#$0002
	sta	OBJ_STATE,x
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	bpl	loc_0186AB
	brl	snap_y_down_to_tile
loc_0186AB:
	rtl
loc_0186AC:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0186C9
	; (not executed in the CDL traces)
	bmi	loc_0186D7
	lda	#$0005
	sta	OBJ_STATE,x
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	bpl	loc_0186AB
	brl	snap_y_down_to_tile
loc_0186C9:
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0186E7
loc_0186D7:
	; (not executed in the CDL traces)
	jsl	f:snap_x_right_if_moving_left
	lda	zp_C4
	beq	@return
	bmi	@return
	lda	#$000D
	sta	OBJ_STATE,x
@return:
	rtl
loc_0186E7:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_018705
loc_0186F5:
	jsl	f:snap_x_left_if_moving_right
	lda	zp_C4
	beq	@return
	; (not executed in the CDL traces)
	bmi	@return
	lda	#$000D
	sta	OBJ_STATE,x
@return:
	rtl
loc_018705:
	lda	zp_C4
	beq	@return
	lda	#$000D
	sta	OBJ_STATE,x
	lda	zp_C4
	bpl	@return
	brl	snap_y_down_to_tile
@return:
	rtl
loc_018716:
	; (not executed in the CDL traces)
	jml	f:kill_player
loc_01871A:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	bne	loc_018716
	bit	#$0080
	beq	loc_018731
	lda	#$0000
	sta	OBJ_STATE,x
	lda	#$0014
	sta	PLAYER_POSE,x
	rtl
loc_018731:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	bit	#$2000
	bne	loc_018749
	lda	$32,x
	bit	#$0100
	beq	loc_018749
	stz	zp_04
loc_018749:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	bit	#$2000
	bne	loc_018762
	lda	$32,x
	bit	#$0100
	beq	loc_018762
	stz	zp_06
loc_018762:
	jsl	f:check_floor_tiles
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_01878C
	bmi	loc_0187D6
	lda	#$0002
	sta	OBJ_STATE,x
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	bpl	@return
	brl	snap_y_up_to_tile
@return:
	rtl
loc_01878C:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0187AA
	bmi	loc_0187B8
	lda	#$0005
	sta	OBJ_STATE,x
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	bpl	@return
	brl	snap_y_up_to_tile
@return:
	rtl
loc_0187AA:
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0187C8
loc_0187B8:
	jsl	f:snap_x_right_if_moving_left
	lda	zp_C4
	beq	loc_0187F7
	bmi	loc_0187F7
	; (not executed in the CDL traces)
	lda	#$0000
	sta	OBJ_STATE,x
	rtl
loc_0187C8:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_0187E6
loc_0187D6:
	jsl	f:snap_x_left_if_moving_right
	lda	zp_C4
	beq	loc_0187F7
	bmi	loc_0187F7
	lda	#$0000
	sta	OBJ_STATE,x
	rtl
loc_0187E6:
	lda	zp_C4
	beq	loc_0187F7
	lda	#$0000
	sta	OBJ_STATE,x
	lda	zp_C4
	bpl	@return
	brl	snap_y_up_to_tile
@return:
	rtl
loc_0187F7:
	stz	zp_00
	lda	#$FFD0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	bit	#$0E00
	beq	loc_018812
	lda	$32,x
	bit	#$0200
	beq	loc_018812
	stz	zp_04
loc_018812:
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	bit	#$0E00
	beq	loc_01882B
	lda	$32,x
	bit	#$0200
	beq	loc_01882B
	stz	zp_06
loc_01882B:
	jsl	f:classify_hang_bar_tiles
	lda	zp_C4
	beq	@return
	lda	#$0001
	sta	OBJ_STATE,x
@return:
	rtl

; Body box and PLAYER_CENTER_X/Y while jumping (smaller).  RTS.
set_player_box_jumping:
	ldy	OBJ_FACING,x
	lda	OBJ_X,x
	sta	PLAYER_HITBOX_LEFT,x
	adc	#$0006
	sta	PLAYER_HITBOX_RIGHT,x
	adc	a:data_05AB74,y
	sta	a:PLAYER_CENTER_X,x
	lda	OBJ_Y,x
	adc	#$FFF2
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0006
	sta	a:PLAYER_CENTER_Y,x
	rts
loc_01885D:
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
	beq	loc_018870
	jml	f:kill_player
loc_018870:
	ldy	a:PLAYER_PLATFORM,x
	beq	loc_0188A4
	bit	#$0080
	beq	loc_0188A4
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
	lda	#$2000
	sta	zp_12
	bra	loc_0188C2
loc_0188A4:
	jsl	f:sub_018EF5
	lda	OBJ_STATE,x
	bne	loc_01885D
	lda	zp_C4
	bne	loc_0188B3
	brl	loc_0182CD
loc_0188B3:
	bit	#$0078
	beq	loc_0188C2
	clc
	lda	a:PLAYER_CENTER_Y,x
	adc	#$FFFC
	sta	a:PLAYER_CENTER_Y,x
loc_0188C2:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_0188F3
	lda	PLAYER_AIM,x
	cmp	#$0008
	beq	loc_0188D2
	brl	loc_0182FD
loc_0188D2:
	lda	zp_12
	bit	#$2000
	beq	loc_0188DC
	brl	loc_0182FD
loc_0188DC:
	lda	stage_number
	cmp	#$0006
	beq	loc_0188E6
	brl	loc_0182CD
loc_0188E6:
	lda	OBJ_Y,x
	cmp	#$0074
	bcc	loc_0188F0
	brl	loc_0182FD
loc_0188F0:
	brl	loc_0182CD
loc_0188F3:
	lda	a:PLAYER_SPIN,x
	beq	loc_0188FB
	brl	loc_01AC62
loc_0188FB:
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
	beq	loc_018971
	lda	PLAYER_LOCKED,x
	beq	loc_018959
	stz	PLAYER_POSE,x
	lda	zp_C4
	bpl	loc_01894B
loc_018946:
	lda	#$0014
	sta	PLAYER_POSE,x
loc_01894B:
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018959:
	lda	#$0002
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:loc_00D6CE
loc_018971:
	ldy	PLAYER_LOCKED,x
	beq	loc_0189A4
	lda	zp_C4
	bmi	loc_018946
	bit	#$0028
	bne	loc_018991
	lda	#$00BA
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018991:
	lda	#$00B0
	sta	PLAYER_POSE,x
	lda	#$0010
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_0189A4:
	bit	#$0028
	bne	loc_0189C1
	lda	#$0074
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0010
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_0189C1:
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
	beq	loc_018A06
	ldy	#$001A
	lda	zp_C4
	bpl	loc_0189EF
loc_0189EC:
	ldy	#$00DD
loc_0189EF:
	sty	PLAYER_POSE,x
	ldy	#$FFF9	; [num]
	lda	OBJ_FACING,x
	bne	loc_0189FB
	ldy	#$FFFE	; [num]
loc_0189FB:
	sty	zp_14
	lda	#$FFC0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018A06:
	lda	zp_C4
	bmi	loc_0189EC
	bit	#$0028
	bne	loc_018A39
	lda	OBJ_FACING,x
	bne	loc_018A26
	lda	#$FFFF	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00BC
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018A26:
	lda	#$FFF8	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00B2
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018A39:
	lda	OBJ_FACING,x
	bne	loc_018A50
	lda	#$FFFF	; [num]
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	lda	#$00B2
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018A50:
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
	beq	loc_018AA5
	lda	PLAYER_LOCKED,x
	beq	loc_018A8D
	ldy	#$001C
	lda	zp_C4
	bpl	loc_018A7D
loc_018A7A:
	ldy	#$0024
loc_018A7D:
	sty	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018A8D:
	lda	#$001E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000C
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018AA5:
	ldy	PLAYER_LOCKED,x
	beq	loc_018AD8
	lda	zp_C4
	bmi	loc_018A7A
	bit	#$0028
	bne	loc_018AC5
	lda	#$00BE
	sta	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018AC5:
	lda	#$00B4
	sta	PLAYER_POSE,x
	lda	#$000C
	sta	zp_14
	lda	#$FFC7	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018AD8:
	bit	#$0028
	bne	loc_018AF5
	lda	#$008C
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0011
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018AF5:
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
	beq	loc_018B4F
	lda	PLAYER_LOCKED,x
	beq	loc_018B37
	ldy	#$0000
	lda	zp_C4
	bpl	loc_018B27
loc_018B24:
	ldy	#$0014
loc_018B27:
	sty	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018B37:
	lda	#$0002
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:loc_00D6CE
loc_018B4F:
	ldy	PLAYER_LOCKED,x
	beq	loc_018B82
	lda	zp_C4
	bmi	loc_018B24
	bit	#$0050
	bne	loc_018B6F
	lda	#$00BA
	sta	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDA	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018B6F:
	lda	#$00B0
	sta	PLAYER_POSE,x
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018B82:
	bit	#$0050
	bne	loc_018B9F
	lda	#$0074
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFDD	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018B9F:
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
	beq	loc_018BF9
	lda	PLAYER_LOCKED,x
	beq	loc_018BE1
	; (not executed in the CDL traces)
	ldy	#$001C
	lda	zp_C4
	bpl	loc_018BD1
loc_018BCE:
	ldy	#$0024
loc_018BD1:
	sty	PLAYER_POSE,x
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018BE1:
	lda	#$001E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018BF9:
	ldy	PLAYER_LOCKED,x
	beq	loc_018C2C
	; (not executed in the CDL traces)
	lda	zp_C4
	bmi	loc_018BCE
	bit	#$0050
	bne	loc_018C19
	lda	#$00BE
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018C19:
	lda	#$00B4
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018C2C:
	bit	#$0050
	bne	loc_018C49
	lda	#$008C
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE5	; [num]
	sta	zp_14
	lda	#$FFC9	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018C49:
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
	beq	loc_018C68
	; (not executed in the CDL traces)
	brl	loc_018D19
loc_018C68:
	lda	zp_C4
	bit	#$0002
	beq	loc_018CA2
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFF2
	sta	PLAYER_HITBOX_TOP,x
	adc	#$0006
	sta	a:PLAYER_CENTER_Y,x
	lda	OBJ_FACING,x
	bne	loc_018C8A
	lda	#$0020
	ldy	#$0018
	bra	loc_018C90
loc_018C8A:
	lda	#$0060
	ldy	#$FFDE	; [num]
loc_018C90:
	sta	zp_12
	sty	zp_14
	lda	#$FFF2	; [num]
	sta	zp_16
	lda	#$002A
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018CA2:
	lda	OBJ_Y,x
	sta	PLAYER_HITBOX_BOTTOM,x
	adc	#$FFE4
	sta	PLAYER_HITBOX_TOP,x
	adc	#$000A
	sta	a:PLAYER_CENTER_Y,x
	lda	zp_C4
	ldy	OBJ_FACING,x
	bne	loc_018CE9
	ldy	#$0020
	sty	zp_12
	lda	zp_C4
	bit	#$0028
	bne	loc_018CD6
	lda	#$0012
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00C0
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018CD6:
	lda	#$0010
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00B6
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018CE9:
	ldy	#$0060
	sty	zp_12
	bit	#$0028
	bne	loc_018D06
	lda	#$FFE4	; [num]
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00B6
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018D06:
	lda	#$FFE6	; [num]
	sta	zp_14
	lda	#$FFE5	; [num]
	sta	zp_16
	lda	#$00C0
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018D19:
	; (not executed in the CDL traces)
	lda	#$0040
	sta	zp_12
	lda	zp_C4
	bit	#$0002
	beq	loc_018D46
	bpl	loc_018D2C
loc_018D27:
	lda	#$00E1
	bra	loc_018D2F
loc_018D2C:
	lda	#$00DF
loc_018D2F:
	sta	PLAYER_POSE,x
	ldy	#$FFFD	; [num]
	lda	OBJ_FACING,x
	bne	loc_018D3B
	ldy	#$FFF9	; [num]
loc_018D3B:
	sty	zp_14
	lda	#$FFFC	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018D46:
	bmi	loc_018D27
	bit	#$0028
	bne	loc_018D77
	lda	OBJ_FACING,x
	bne	loc_018D64
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF6	; [num]
	sta	zp_16
	lda	#$00E5
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018D64:
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF6	; [num]
	sta	zp_16
	lda	#$00E3
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018D77:
	lda	OBJ_FACING,x
	bne	loc_018D8E
	lda	#$FFFA	; [num]
	sta	zp_14
	lda	#$FFF4	; [num]
	sta	zp_16
	lda	#$00E3
	sta	PLAYER_POSE,x
	jml	f:fire_weapon
loc_018D8E:
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
	beq	loc_018DE3
	lda	PLAYER_LOCKED,x
	beq	loc_018DCB
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	loc_018DBB
loc_018DB8:
	ldy	#$0034
loc_018DBB:
	sty	PLAYER_POSE,x
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018DCB:
	lda	#$002E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$000A
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018DE3:
	; (not executed in the CDL traces)
	ldy	PLAYER_LOCKED,x
	beq	loc_018E16
	lda	zp_C4
	bmi	loc_018DB8
	bit	#$0028
	bne	loc_018E03
	lda	#$00C2
	sta	PLAYER_POSE,x
	lda	#$000A
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018E03:
	lda	#$00B8
	sta	PLAYER_POSE,x
	lda	#$000B
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018E16:
	bit	#$0028
	bne	loc_018E33
	lda	#$00A4
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$0014
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018E33:
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
	beq	loc_018E8D
	lda	PLAYER_LOCKED,x
	beq	loc_018E75
	; (not executed in the CDL traces)
	ldy	#$002C
	lda	zp_C4
	bpl	loc_018E65
loc_018E62:
	ldy	#$0034
loc_018E65:
	sty	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018E75:
	lda	#$002E
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018E8D:
	; (not executed in the CDL traces)
	ldy	PLAYER_LOCKED,x
	beq	loc_018EC0
	lda	zp_C4
	bmi	loc_018E62
	bit	#$0050
	bne	loc_018EAD
	lda	#$00C2
	sta	PLAYER_POSE,x
	lda	#$FFEC	; [num]
	sta	zp_14
	lda	#$FFEC	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018EAD:
	lda	#$00B8
	sta	PLAYER_POSE,x
	lda	#$FFEA	; [num]
	sta	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018EC0:
	bit	#$0050
	bne	loc_018EDD
	lda	#$00A4
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE4	; [num]
	sta	zp_14
	lda	#$FFF0	; [num]
	sta	zp_16
	jml	f:fire_weapon
loc_018EDD:
	lda	#$0098
	sta	a:PLAYER_POSE_ADD,x
	jsl	f:animate_player_walk
	lda	#$FFE8	; [num]
	sta	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon

sub_018EF5:
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8000
	beq	loc_018F0B
	; (not executed in the CDL traces)
	jsl	f:snap_x_right_to_tile
	bra	loc_018F3E
loc_018F0B:
	bit	#$0002
	beq	loc_018F18
	lda	#$0005
	sta	OBJ_STATE,x
	brl	snap_x_right_to_tile
loc_018F18:
	lda	#$0006
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$8000
	beq	loc_018F31
	jsl	f:snap_x_left_to_tile
	bra	loc_018F3E
loc_018F31:
	bit	#$0002
	beq	loc_018F3E
	lda	#$0002
	sta	OBJ_STATE,x
	brl	snap_x_left_to_tile
loc_018F3E:
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
	brl	loc_019699

; PLAYER_POSE steps by 2 every 8 frames through 0-$0A.
animate_player_walk:
	lda	stage_frame_mod8
	bne	loc_018F62
	inc	PLAYER_POSE,x
	inc	PLAYER_POSE,x
loc_018F62:
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
	beq	loc_018F96
	jml	f:kill_player
loc_018F96:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	ldy	a:PLAYER_PLATFORM,x
	beq	loc_018FC9
	lda	PLAYER_CONTACT,x
	bit	#$2000
	beq	loc_018FC9
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
	bra	loc_018FD5
loc_018FC9:
	jsl	f:check_hang_bar
	lda	a:zp_C4
	bne	loc_018FD5
	brl	loc_0182C8
loc_018FD5:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_018FE8
	lda	PLAYER_AIM,x
	bit	#$0008
	beq	loc_018FE5
	brl	loc_0182C8
loc_018FE5:
	brl	loc_0182FD
loc_018FE8:
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

classify_hang_bar_tiles:
	lda	zp_06
	bit	#$0E00
	beq	loc_019050
	bit	#$0C00
	beq	loc_019081
	bit	#$0001
	bne	loc_019043
	bit	#$0800
	beq	loc_0190A6
	bne	loc_0190B9
loc_019043:
	bit	#$0800
	bne	loc_01904B
	brl	loc_0190CC
loc_01904B:
	beq	loc_019050
	brl	loc_0190DF
loc_019050:
	lda	zp_04
	bit	#$0E00
	bne	loc_01905A
	brl	loc_019102
loc_01905A:
	bit	#$0C00
	bne	loc_019062
	brl	loc_0190F2
loc_019062:
	bit	#$0001
	beq	loc_019074
	bit	#$0800
	bne	loc_01906F
	brl	loc_019102
loc_01906F:
	; (not executed in the CDL traces)
	beq	loc_019074
	brl	loc_019102
loc_019074:
	bit	#$0800
	bne	loc_01907C
	; (not executed in the CDL traces)
	brl	loc_019105
loc_01907C:
	beq	loc_019081
	brl	loc_01910D
loc_019081:
	lda	zp_04
	bit	#$0E00
	bne	loc_01908B
	brl	loc_0190F2
loc_01908B:
	bit	#$0C00
	bne	loc_019093
	brl	loc_0190FA
loc_019093:
	bit	#$0001
	beq	loc_01909F
	bit	#$0800
	beq	loc_0190FA
	bne	loc_0190FA
loc_01909F:
	bit	#$0800
	beq	loc_019105
	; (not executed in the CDL traces)
	bne	loc_01910D
loc_0190A6:
	lda	zp_04
	bit	#$0E00
	beq	loc_019102
	bit	#$0C00
	beq	loc_0190FA
	bit	#$0800
	beq	loc_019105
	; (not executed in the CDL traces)
	bne	loc_01910D
loc_0190B9:
	lda	zp_04
	bit	#$0E00
	beq	loc_019102
	bit	#$0C00
	beq	loc_0190FA
	bit	#$0800
	beq	loc_019105
	bne	loc_01910D
loc_0190CC:
	lda	zp_04
	bit	#$0E00
	beq	loc_019115
	bit	#$0C00
	beq	loc_019115
	bit	#$0800
	beq	loc_019115
	bne	loc_019115
loc_0190DF:
	lda	zp_04
	bit	#$0E00
	beq	loc_01911D
	bit	#$0C00
	beq	loc_01911D
	bit	#$0800
	beq	loc_01911D
	bne	loc_01911D
loc_0190F2:
	lda	#$8000	; [num]
	sta	zp_C4
	brl	snap_y_down_to_tile
loc_0190FA:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_down_to_tile
loc_019102:
	stz	zp_C4
	rtl
loc_019105:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194AB
loc_01910D:
	lda	#$0008
	sta	zp_C4
	brl	loc_019450
loc_019115:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195BA
loc_01911D:
	lda	#$0010
	sta	zp_C4
	brl	loc_019565

; State $10 (stage 3, seen in the emulator): hanging from a moving object;
; jump lets go (down + jump drops).
player_state_hang_object:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	loc_019130
	jml	f:kill_player
loc_019130:
	jsr	a:set_player_box_hanging
	jsl	f:check_bomb_button
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_01914C
	stz	$3E,x
	lda	PLAYER_JOY_HELD,x
	bit	#$0400
	beq	loc_019149
	brl	start_player_drop
loc_019149:
	brl	loc_0182FD
loc_01914C:
	brl	loc_018FE8

; State 2, climbing a wall on the right (BG wall bit at x+6): aims and fires
; (tbl_climb_right_aim); falls when the wall ends.
player_state_climb_right:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	loc_01915A
	jml	f:kill_player
loc_01915A:
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
	bit	#$0002
	bne	loc_0191A9
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	bne	loc_0191A6
	; (not executed in the CDL traces)
	brl	loc_0182CD
loc_0191A6:
	brl	loc_0182E4
loc_0191A9:
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
	beq	loc_0191DD
	brl	loc_0182B5
loc_0191DD:
	brl	loc_019285

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
	beq	loc_019203
	lda	#$0066
	sta	PLAYER_POSE,x
	bra	loc_019211
loc_019203:
	jsl	f:climb_right_check_ceiling
	beq	loc_01920D
	; (not executed in the CDL traces)
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_01920D:
	jsl	f:animate_player_climb
loc_019211:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_01921A
	brl	loc_0182F7
loc_01921A:
	lda	#$0000
	sta	zp_12
	lda	#$FFF3	; [num]
	sta	zp_14
	lda	#$FFBC	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_up_right:
	lda	PLAYER_LOCKED,x
	beq	loc_019238
	lda	#$005A
	sta	PLAYER_POSE,x
	bra	loc_019246
loc_019238:
	jsl	f:climb_right_check_ceiling
	beq	loc_019242
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_019242:
	jsl	f:animate_player_climb
loc_019246:
	lda	#$0010
	sta	zp_12
	lda	#$0002
	sta	zp_14
	lda	#$FFC8	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_left:
	jsl	f:climb_right_check_ceiling
	bne	loc_019265
	jsl	f:climb_right_check_floor
	beq	loc_019272
loc_019265:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	loc_019272
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
loc_019272:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_019285
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	loc_0182B5
loc_019285:
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
	bne	loc_0192A9
	jsl	f:climb_right_check_floor
	beq	loc_0192B6
loc_0192A9:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	loc_0192B6
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
loc_0192B6:
	lda	PLAYER_LOCKED,x
	beq	loc_0192C1
	lda	#$0060
	sta	PLAYER_POSE,x
	bra	loc_0192C5
loc_0192C1:
	; (not executed in the CDL traces)
	jsl	f:animate_player_climb
loc_0192C5:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_0192D8
	; (not executed in the CDL traces)
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	loc_0182F7
loc_0192D8:
	lda	#$0070
	sta	zp_12
	lda	#$FFD5	; [num]
	sta	zp_14
	lda	#$FFCA	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_down:
	lda	PLAYER_LOCKED,x
	beq	loc_0192F6
	lda	#$0064
	sta	PLAYER_POSE,x
	bra	loc_019304
loc_0192F6:
	jsl	f:climb_right_check_floor
	beq	loc_019300
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_019300:
	jsl	f:animate_player_climb
loc_019304:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_01930D
	brl	loc_0182B5
loc_01930D:
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
	beq	loc_01932B
	lda	#$005C
	sta	PLAYER_POSE,x
	bra	loc_019339
loc_01932B:
	jsl	f:climb_right_check_floor
	beq	loc_019335
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_019335:
	jsl	f:animate_player_climb
loc_019339:
	lda	#$0030
	sta	zp_12
	stz	zp_14
	lda	#$FFEE	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_right_aim_down_left:
	; (not executed in the CDL traces)
	jsl	f:climb_right_check_ceiling
	bne	loc_019355
	jsl	f:climb_right_check_floor
	beq	loc_019362
loc_019355:
	ldy	OBJ_X,x
	cpy	#$000B
	bcc	loc_019362
	dec	a
	sta	OBJ_STATE,x
	dec	OBJ_X,x
	rtl
loc_019362:
	lda	PLAYER_LOCKED,x
	beq	loc_01936D
	lda	#$0062
	sta	PLAYER_POSE,x
	bra	loc_019371
loc_01936D:
	jsl	f:animate_player_climb
loc_019371:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_019384
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	brl	loc_0182B5
loc_019384:
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
	bne	loc_0193C4
	inc	PLAYER_POSE,x
loc_0193C4:
	lda	PLAYER_POSE,x
	cmp	#$0054
	bcc	loc_0193D1
	cmp	#$0058
	bcs	loc_0193D1
	rtl
loc_0193D1:
	lda	#$0054
	sta	PLAYER_POSE,x
	rtl
loc_0193D7:
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
	bmi	loc_01942E

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
loc_01942E:
	rtl

snap_x_right_if_moving_left:
	lda	OBJ_X_VEL,x
	bpl	loc_01944F

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
loc_01944F:
	rtl
loc_019450:
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
loc_019480:
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
loc_0194AB:
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
loc_0194DD:
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
loc_019502:
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
loc_019536:
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
loc_019565:
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
loc_019592:
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
loc_0195BA:
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
loc_0195F2:
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
loc_01961D:
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
loc_019651:
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
sub_019680:
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
loc_019699:
	lda	zp_06
	bit	#$807E
	bne	loc_0196A3
	brl	loc_0196CA
loc_0196A3:
	bit	#$0078
	bne	loc_0196AB
	brl	loc_0196FB
loc_0196AB:
	bit	#$0001
	bne	loc_0196BD
	bit	#$0050
	bne	loc_0196B8
	brl	loc_01972C
loc_0196B8:
	beq	loc_0196BD
	brl	loc_01974B
loc_0196BD:
	bit	#$0050
	bne	loc_0196C5
	brl	loc_01976A
loc_0196C5:
	beq	loc_0196CA
	brl	loc_019789
loc_0196CA:
	lda	zp_04
	bit	#$807E
	bne	loc_0196D4
	brl	loc_0197A8
loc_0196D4:
	bit	#$0078
	bne	loc_0196DC
	brl	loc_0197C3
loc_0196DC:
	bit	#$0001
	beq	loc_0196EE
	bit	#$0050
	bne	loc_0196E9
	brl	loc_0197AB
loc_0196E9:
	; (not executed in the CDL traces)
	beq	loc_0196EE
	brl	loc_0197B3
loc_0196EE:
	bit	#$0050
	bne	loc_0196F6
	brl	loc_0197CB
loc_0196F6:
	beq	loc_0196FB
	brl	loc_0197D3
loc_0196FB:
	lda	zp_04
	bit	#$807E
	bne	loc_019705
	brl	loc_0197C3
loc_019705:
	bit	#$0078
	bne	loc_01970D
	brl	loc_0197BB
loc_01970D:
	bit	#$0001
	beq	loc_01971F
	bit	#$0050
	bne	loc_01971A
	; (not executed in the CDL traces)
	brl	loc_0197C3
loc_01971A:
	beq	loc_01971F
	brl	loc_0197C3
loc_01971F:
	bit	#$0050
	bne	loc_019727
	brl	loc_0197CB
loc_019727:
	; (not executed in the CDL traces)
	beq	loc_01972C
	brl	loc_0197D3
loc_01972C:
	lda	zp_04
	bit	#$807E
	bne	loc_019736
	brl	loc_0197DB
loc_019736:
	bit	#$0078
	bne	loc_01973E
	; (not executed in the CDL traces)
	brl	loc_0197C3
loc_01973E:
	bit	#$0050
	bne	loc_019746
	brl	loc_0197E3
loc_019746:
	; (not executed in the CDL traces)
	beq	loc_01974B
	brl	loc_0197EB
loc_01974B:
	lda	zp_04
	bit	#$807E
	bne	loc_019755
	brl	loc_0197CB
loc_019755:
	bit	#$0078
	bne	loc_01975D
	brl	loc_0197C3
loc_01975D:
	bit	#$0050
	bne	loc_019765
	brl	loc_0197E3
loc_019765:
	beq	loc_01976A
	brl	loc_0197EB
loc_01976A:
	lda	zp_04
	bit	#$807E
	bne	loc_019774
	brl	loc_0197F3
loc_019774:
	bit	#$0078
	bne	loc_01977C
	brl	loc_0197F3
loc_01977C:
	bit	#$0050
	bne	loc_019784
	brl	loc_0197FB
loc_019784:
	beq	loc_019789
	brl	loc_0197FB
loc_019789:
	lda	zp_04
	bit	#$807E
	bne	loc_019793
	; (not executed in the CDL traces)
	brl	loc_019803
loc_019793:
	bit	#$0078
	bne	loc_01979B
	; (not executed in the CDL traces)
	brl	loc_019803
loc_01979B:
	bit	#$0050
	bne	loc_0197A3
	; (not executed in the CDL traces)
	brl	loc_01980B
loc_0197A3:
	beq	loc_0197A8
	brl	loc_01980B
loc_0197A8:
	stz	zp_C4
	rtl
loc_0197AB:
	lda	#$8011	; [num]
	sta	zp_C4
	brl	loc_019651
loc_0197B3:
	; (not executed in the CDL traces)
	lda	#$8011	; [num]
	sta	zp_C4
	brl	loc_019592
loc_0197BB:
	lda	#$0002
	sta	zp_C4
	brl	snap_y_up_to_tile
loc_0197C3:
	lda	#$8002	; [num]
	sta	zp_C4
	brl	snap_y_up_to_tile
loc_0197CB:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	loc_019480
loc_0197D3:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	loc_0194DD
loc_0197DB:
	lda	#$8008	; [num]
	sta	zp_C4
	brl	loc_019536
loc_0197E3:
	lda	#$0008
	sta	zp_C4
	brl	loc_019480
loc_0197EB:
	lda	#$0008
	sta	zp_C4
	brl	loc_0194DD
loc_0197F3:
	lda	#$8010	; [num]
	sta	zp_C4
	brl	loc_019592
loc_0197FB:
	lda	#$0010
	sta	zp_C4
	brl	loc_019592
loc_019803:
	; (not executed in the CDL traces)
	lda	#$8010	; [num]
	sta	zp_C4
	brl	loc_0195F2
loc_01980B:
	lda	#$0010
	sta	zp_C4
	brl	loc_0195F2

; State 5, climbing a wall on the left.
player_state_climb_left:
	lda	PLAYER_CONTACT,x
	bit	#$0004
	beq	loc_01981E
	jml	f:kill_player
loc_01981E:
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
	bit	#$0002
	bne	loc_01986A
	; (not executed in the CDL traces)
	lda	#$FFF8	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	bne	loc_019867
	brl	loc_0182CD
loc_019867:
	brl	loc_0182E4
loc_01986A:
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
	beq	loc_0198A1
	brl	start_player_fall_right
loc_0198A1:
	bra	loc_0198C8

climb_left_aim_right:
	jsl	f:climb_left_check_ceiling
	bne	loc_0198AF
	jsl	f:climb_left_check_floor
	beq	loc_0198B5
loc_0198AF:
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
loc_0198B5:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_0198C8
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	start_player_fall_right
loc_0198C8:
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
	beq	loc_0198EB
	lda	#$0066
	sta	PLAYER_POSE,x
	bra	loc_0198F9
loc_0198EB:
	; (not executed in the CDL traces)
	jsl	f:climb_left_check_ceiling
	beq	loc_0198F5
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
loc_0198F5:
	jsl	f:animate_player_climb
loc_0198F9:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_019902
	brl	loc_0182FB
loc_019902:
	lda	#$0000
	sta	zp_12
	lda	#$0004
	sta	zp_14
	lda	#$FFBE	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_up_right:
	jsl	f:climb_left_check_ceiling
	bne	loc_019921
	jsl	f:climb_left_check_floor
	beq	loc_019927
loc_019921:
	; (not executed in the CDL traces)
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
loc_019927:
	lda	PLAYER_LOCKED,x
	beq	loc_019932
	lda	#$0060
	sta	PLAYER_POSE,x
	bra	loc_019936
loc_019932:
	jsl	f:animate_player_climb
loc_019936:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_019949
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	loc_0182FB
loc_019949:
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
	beq	loc_01997F
	lda	#$005A
	sta	PLAYER_POSE,x
	bra	loc_01998D
loc_01997F:
	; (not executed in the CDL traces)
	jsl	f:climb_left_check_ceiling
	beq	loc_019989
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_019989:
	jsl	f:animate_player_climb
loc_01998D:
	lda	#$0070
	sta	zp_12
	lda	#$FFF4	; [num]
	sta	zp_14
	lda	#$FFC6	; [num]
	sta	zp_16
	jml	f:fire_weapon

climb_left_aim_down:
	lda	PLAYER_LOCKED,x
	beq	loc_0199AB
	lda	#$0064
	sta	PLAYER_POSE,x
	bra	loc_0199B9
loc_0199AB:
	jsl	f:climb_left_check_floor
	beq	loc_0199B5
	; (not executed in the CDL traces)
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
loc_0199B5:
	jsl	f:animate_player_climb
loc_0199B9:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_0199C3
	; (not executed in the CDL traces)
	jsl	f:start_player_fall_right
loc_0199C3:
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
	bne	loc_0199E2
	jsl	f:climb_left_check_floor
	beq	loc_0199E8
loc_0199E2:
	dec	a
	sta	OBJ_STATE,x
	inc	OBJ_X,x
	rtl
loc_0199E8:
	lda	PLAYER_LOCKED,x
	beq	loc_0199F3
	lda	#$0062
	sta	PLAYER_POSE,x
	bra	loc_0199F7
loc_0199F3:
	jsl	f:animate_player_climb
loc_0199F7:
	lda	PLAYER_JOY_PRESSED,x
	bit	button_jump
	beq	loc_019A0A
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	lda	#$0001
	sta	OBJ_X_VEL,x
	brl	start_player_fall_right
loc_019A0A:
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
	beq	loc_019A28
	lda	#$005C
	sta	PLAYER_POSE,x
	bra	loc_019A36
loc_019A28:
	jsl	f:climb_left_check_floor
	beq	loc_019A32
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
loc_019A32:
	jsl	f:animate_player_climb
loc_019A36:
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
	lda	#$003F
	ldy	OBJ_Y,x
	cpy	#$00F8
	bcc	loc_019A85
	bmi	loc_019A85
	lda	#$0043
loc_019A85:
	jsl	f:queue_sound
	stz	$30,x
	stz	$34,x
	stz	$36,x
	stz	$3E,x
	lda	OBJ_FACING,x
	beq	loc_019AA1
	lda	#$0001
	sta	OBJ_X_VEL,x
	lda	#$6800
	sta	OBJ_X_VEL_SUB,x
	bra	loc_019AAB
loc_019AA1:
	lda	#$FFFE	; [num]
	sta	OBJ_X_VEL,x
	lda	#$97FF	; [num]
	sta	OBJ_X_VEL_SUB,x
loc_019AAB:
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
	bmi	loc_019B09
	cmp	#$0120
	bcs	loc_019B52
loc_019B09:
	dec	$30,x
	lda	$30,x
	beq	loc_019B22
	bit	#$0007
	bne	loc_019B22
	inc	PLAYER_POSE,x
	lda	#$00ED
	cmp	PLAYER_POSE,x
	bne	loc_019B22
	lda	#$00E9
	sta	PLAYER_POSE,x
loc_019B22:
	lda	OBJ_Y_VEL,x
	bmi	loc_019B2B
	cmp	#$0006
	bcs	loc_019B3A
loc_019B2B:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$4000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_019B3A:
	stz	zp_C4
	lda	OBJ_Y_VEL,x
	bpl	loc_019B4A
	jsl	f:dying_check_ceiling_walls
loc_019B44:
	lda	#$0007
	sta	OBJ_STATE,x
	rtl
loc_019B4A:
	jsl	f:dying_check_floor_walls
	lda	OBJ_STATE,x
	bne	loc_019B44
loc_019B52:
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
	bpl	loc_019B9C
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
	beq	loc_019B99
	lda	#$0001
loc_019B99:
	sta	a:PLAYER_BOMBS,x
loc_019B9C:
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

; State $0F: places the player by wram_1672 (tbl_respawn_placement) and
; calls respawn_player.
player_state_respawn:
	lda	a:wram_1672
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
	beq	loc_019BF5
	lda	#$0040
loc_019BF5:
	sta	OBJ_X,x
	lda	#$005A
	sta	OBJ_Y,x
	brl	respawn_player

; Respawn mode 7: above the object in slot $0280 (y - $18), x $58 (player 2:
; $98).
respawn_above_slot_0280:
	sec
	lda	a:wram_028E
	sbc	#$0018
	sta	OBJ_Y,x
	lda	#$0058
	cpx	#$0200
	beq	loc_019C13
	; (not executed in the CDL traces)
	lda	#$0098
loc_019C13:
	sta	OBJ_X,x
	brl	respawn_player

; Respawn mode 6, and the handler of state 6 (PLAYER_STATE_WAIT_MISSILE):
; placed on the first rideable missile (type $65, slots $07C0-$087F) with x
; < $44; until there is one, does nothing.
respawn_on_missile:
	ldy	#$07C0
loc_019C1B:
	lda	a:$0010,y
	cmp	#$0065
	bne	loc_019C49
	lda	a:$000A,y
	bmi	loc_019C49
	cmp	#$0044
	bcs	loc_019C49
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
loc_019C49:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0880
	bcc	loc_019C1B
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
	bra	loc_019C85

; Respawn mode 1: as respawn_on_floor, searching from $20 below the top.
respawn_on_floor_high:
	lda	#$0020
	sta	zp_0E
	lda	#$0012
	bra	loc_019C85

; Respawn mode 0: searches the collision map ($7E:4000) down from y $30 for
; the first solid tile and places the player there (x $38, player 2: $20).
respawn_on_floor:
	lda	#$0030
	sta	zp_0E
	lda	#$0014
loc_019C85:
	sta	zp_08
	sta	zp_02
	lda	#$0020
	sta	zp_06
	lda	#$0038
	cpx	#$0200
	beq	loc_019C99
	lda	#$0020
loc_019C99:
	stx	zp_FC
	stz	zp_04
	clc
	adc	a:bg1_x
	bit	#$0100
	beq	loc_019CAB
	ldy	#$0800
	sty	zp_04
loc_019CAB:
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
loc_019CC0:
	sta	zp_0A
	ora	zp_00
	ora	zp_04
loc_019CC6:
	tax
	lda	f:$7E4000,x
	beq	loc_019D03
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
	bmi	loc_019CF0
	cmp	#$0020
	bcs	loc_019CF3
loc_019CF0:
	lda	#$0020
loc_019CF3:
	sta	OBJ_Y,x
	sec
	lda	zp_00
	sbc	a:bg1_x
	and	#$00FF
	sta	OBJ_X,x
	brl	respawn_player
loc_019D03:
	clc
	lda	zp_0A
	adc	#$0040
	and	#$07C0
	dec	zp_02
	bne	loc_019CC0
	lda	zp_08
	sta	zp_02
	lda	zp_12
	sta	zp_0A
	dec	zp_06
	bne	loc_019D21
	; (not executed in the CDL traces)
	ldx	zp_FC
	brl	loc_019D42
loc_019D21:
	clc
	lda	zp_00
	adc	#$0002
	cmp	#$0040
	bcc	loc_019D39
	lda	zp_04
	adc	#$0800
	and	#$0800
	sta	zp_04
	lda	#$0000
loc_019D39:
	sta	zp_00
	ora	zp_04
	ora	zp_12
	brl	loc_019CC6
loc_019D42:
	; (not executed in the CDL traces)
	lda	#$0080
	sta	OBJ_X,x
	sta	OBJ_Y,x
	brl	respawn_player

; Respawn mode 2: climbing the right wall (state 2) at x $D2.
respawn_on_right_wall:
	lda	#$0070
	cpx	#$0200
	beq	loc_019D57
	lda	#$0088
loc_019D57:
	sta	OBJ_Y,x
	lda	#$00D2
	sta	OBJ_X,x
	brl	respawn_player

; Respawn mode 3: x $78, y $BC.
respawn_at_bottom:
	lda	#$0078
	cpx	#$0200
	beq	loc_019D6C
	; (not executed in the CDL traces)
	lda	#$0058
loc_019D6C:
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
	bit	#$8002
	beq	loc_019D93
	brl	snap_x_left_to_tile
loc_019D93:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_019DA1
	brl	snap_x_right_to_tile
loc_019DA1:
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
	beq	loc_019DB5
	; (not executed in the CDL traces)
	stz	OBJ_STATE,x
	rtl
loc_019DB5:
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
	bit	#$8002
	beq	loc_019DEE
	jsl	f:snap_x_left_to_tile
	lda	zp_C4
	beq	@return
	bmi	@return
	stz	OBJ_STATE,x
@return:
	rtl
loc_019DEE:
	stz	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$8002
	beq	loc_019E06
	jsl	f:snap_x_right_to_tile
	lda	zp_C4
	beq	@return
	bmi	@return
	stz	OBJ_STATE,x
@return:
	rtl
loc_019E06:
	lda	zp_C4
	beq	@return
	stz	OBJ_STATE,x
	lda	zp_C4
	bpl	@return
	brl	snap_y_up_to_tile
@return:
	rtl

; Sets the state, y velocity and pose of respawn mode wram_1672
; (respawn_states/93/81), 96 frames of PLAYER_INVULN_TIMER, OBJ_FLAGS = 3
; (present + PLAYERF_INVULNERABLE).
respawn_player:
	ldy	a:wram_1672
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
