; objects/player_shots.asm -- Player shots: firing and spawning
; Bank $00, $00:D656-$00:DDC7. Included by main.asm in segment BANK00.
;
; fire_weapon (fire button) and spin_fire_weapon_1/2 (spin jump) dispatch
; by weapon (WEAPON_*) through tbl_fire_weapon / tbl_spin_fire_1 /
; tbl_spin_fire_2 to the spawners, which allocate slots of the shot list
; (find_free_shot_slot_up_to and friends) and set position, velocity (64-direction tables
; vel8_x_sub, vel8_x, vel8_y_sub, vel8_y indexed by the angle),
; SHOT_TYPE, SHOT_DAMAGE and SHOT_ATTR.  The shots' handlers are in
; objects/object_handlers_00b.asm (tbl_shot_types).

; Spin jump: fires PLAYER_WEAPON_1 without the button check, at an angle
; that turns by a weapon-dependent step each shot (kept in the player's
; $36).  In: X = player, zp_14/zp_16 = muzzle offset.
spin_fire_weapon_1:
	lda	PLAYER_FIRE_DELAY_1,x
	bne	loc_00D655
	lda	a:PLAYER_WEAPON_1,x
	pha
	asl	a
	tay
	lda	a:weapon_fire_delays,y
	sta	PLAYER_FIRE_DELAY_1,x
	txy
	lda	#$0AC0
	cpy	#$0200
	beq	loc_00D671
	lda	#$0D40
loc_00D671:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_spin_fire_1,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spin_fire_1:
	.addr	spin_shot_default_1
	.addr	spin_shots_spread_1
	.addr	spin_shot_crush_1
	.addr	spin_shot_homing_1
	.addr	spin_shots_flame_1
	.addr	spin_shot_laser_1

; Spin jump: the same for PLAYER_WEAPON_2 (angle in $34, offset by half a
; turn).
spin_fire_weapon_2:
	lda	PLAYER_FIRE_DELAY_2,x
	bne	loc_00D655
	lda	a:PLAYER_WEAPON_2,x
	pha
	asl	a
	tay
	lda	a:weapon_fire_delays,y
	sta	PLAYER_FIRE_DELAY_2,x
	txy
	lda	#$0C00
	cpy	#$0200
	beq	loc_00D6AD
	lda	#$0E80
loc_00D6AD:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_spin_fire_2,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_spin_fire_2:
	.addr	spin_shot_default_2
	.addr	spin_shots_spread_2
	.addr	spin_shot_crush_2
	.addr	spin_shot_homing_2
	.addr	spin_shots_flame_2
	.addr	spin_shot_laser_2
loc_00D6CE:
	lda	PLAYER_JOY_HELD,x
	bit	button_fire
	beq	loc_00D740
	lda	#$000E
	sta	a:PLAYER_POSE_ADD,x
	bra	loc_00D6E2

; If button_fire is held: fires the weapon of the active slot
; (PLAYER_WEAPON_SLOT = 2: PLAYER_WEAPON_1 into the player's first 10 shot
; slots, delay PLAYER_FIRE_DELAY_1; 0: PLAYER_WEAPON_2 into the next 10,
; PLAYER_FIRE_DELAY_2) when its delay is 0, reloading the delay from
; weapon_fire_delays.  In: X = player, zp_12 = angle ($00 up, $20 right,
; $80 per turn), zp_14/zp_16 = muzzle offset from OBJ_X/OBJ_Y.  The
; spawners return with X = player and set $38 (shooting pose) to 1.
fire_weapon:
	lda	PLAYER_JOY_HELD,x
	bit	button_fire
	beq	loc_00D740
loc_00D6E2:
	lda	a:PLAYER_WEAPON_SLOT,x
	beq	loc_00D723
	lda	PLAYER_FIRE_DELAY_1,x
	bne	loc_00D740
	lda	a:PLAYER_WEAPON_1,x
	pha
	asl	a
	tay
	lda	a:weapon_fire_delays,y
	sta	PLAYER_FIRE_DELAY_1,x
	txy
	lda	#$0AC0
	cpy	#$0200
	beq	loc_00D702
	lda	#$0D40
loc_00D702:
	tax
	clc
	adc	#$0140
	sta	zp_06
	pla
	phx
	asl	a
	tax
	lda	f:tbl_fire_weapon,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_fire_weapon:
	.addr	spawn_shot_default
	.addr	spawn_shots_spread
	.addr	spawn_shot_crush
	.addr	spawn_shot_homing
	.addr	spawn_shots_flame
	.addr	spawn_shot_laser
loc_00D723:
	lda	PLAYER_FIRE_DELAY_2,x
	bne	loc_00D740
	lda	a:PLAYER_WEAPON_2,x
	pha
	asl	a
	tay
	lda	a:weapon_fire_delays,y
	sta	PLAYER_FIRE_DELAY_2,x
	txy
	lda	#$0C00
	cpy	#$0200
	beq	loc_00D702
	lda	#$0E80
	bra	loc_00D702
loc_00D740:
	rtl

spin_shot_default_2:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0008
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	spawn_shot_default

spin_shot_default_1:
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0008
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	spawn_shot_default
loc_00D769:
	tyx
	rtl

; WEAPON_DEFAULT: one shot (shot type 1, damage 2) at angle zp_12; sound 4.
spawn_shot_default:
	jsl	f:find_free_shot_slot_up_to
	bcs	loc_00D769
	lda	#$0001
	sta	SHOT_TYPE,x
	sta	$04,x
	lda	#$0002
	sta	SHOT_DAMAGE,x
	lda	#$3E0C
	sta	$14,x
	stz	SHOT_HIT,x
	phy
	ldy	#$3F82
	lda	stage_frame_odd
	bne	loc_00D78F
	ldy	#$3FEC
loc_00D78F:
	sty	SHOT_ATTR,x
	ldy	zp_12
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	ply
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	OBJ_X,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	OBJ_Y,x
	tyx
	lda	#$0001
	sta	PLAYER_SHOT_POSE,x
	lda	#$0004
	jsl	f:queue_sound
	rtl

spin_shots_spread_2:
	jsr	a:find_spread_shot_slots
	beq	loc_00D7CC
	rtl
loc_00D7CC:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0020
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D820

spin_shots_spread_1:
	; (not executed in the CDL traces)
	jsr	a:find_spread_shot_slots
	beq	loc_00D7E9
	rtl
loc_00D7E9:
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0020
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	loc_00D820

; Returns Z set and X = the first of 5 free shot slots (tries X and X+$A0),
; else Z clear and X = Y (the player).
find_spread_shot_slots:
	lda	SHOT_TYPE,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	beq	loc_00D819
	txa
	clc
	adc	#$00A0
	tax
	lda	SHOT_TYPE,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	beq	loc_00D819
	tyx
loc_00D819:
	rts

; WEAPON_SPREAD: five shots (type 2, damage 2) fanned around zp_12, in five
; consecutive free slots (find_spread_shot_slots); sound 9.
spawn_shots_spread:
	jsr	a:find_spread_shot_slots
	beq	loc_00D820
	rtl
loc_00D820:
	lda	#$0005
	sta	zp_10
	sec
	lda	zp_12
	sbc	#$000C
	and	#$007E
	sta	zp_12
loc_00D830:
	lda	#$0002
	sta	SHOT_TYPE,x
	lda	#$3F84
	sta	SHOT_ATTR,x
	lda	#$0001
	sta	$04,x
	lda	#$3F0E
	sta	$14,x
	lda	#$0002
	sta	SHOT_DAMAGE,x
	sty	zp_FE
	clc
	lda	zp_12
	adc	#$0004
	and	#$007E
	sta	zp_12
	tay
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	ldy	zp_FE
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	OBJ_X,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	OBJ_Y,x
	txa
	clc
	adc	#$0020
	tax
	dec	zp_10
	bne	loc_00D830
	tyx
	lda	#$0001
	sta	PLAYER_SHOT_POSE,x
	lda	#$0009
	jsl	f:queue_sound
	rtl

spin_shot_crush_2:
	jsr	a:find_crush_shot_slot
	beq	loc_00D89B
	rtl
loc_00D89B:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D8E9

spin_shot_crush_1:
	jsr	a:find_crush_shot_slot
	beq	loc_00D8B8
	rtl
loc_00D8B8:
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	loc_00D8E9

; Returns Z set and X = a free slot among X, X+$60, X+$C0, else Z clear and
; X = Y.
find_crush_shot_slot:
	lda	SHOT_TYPE,x
	beq	loc_00D8E2
	txa
	clc
	adc	#$0060
	tax
	lda	SHOT_TYPE,x
	beq	loc_00D8E2
	txa
	clc
	adc	#$0060
	tax
	lda	SHOT_TYPE,x
	beq	loc_00D8E2
	tyx
loc_00D8E2:
	rts

; WEAPON_CRUSH: a missile (types 3 / 13) at angle zp_12.
spawn_shot_crush:
	jsr	a:find_crush_shot_slot
	beq	loc_00D8E9
	rtl
loc_00D8E9:
	lda	#$0003
	sta	SHOT_TYPE,x
	lda	#$0004
	sta	SHOT_DAMAGE,x
	sty	zp_FE
	lda	zp_12
	tay
	lsr	a
	lsr	a
	lsr	a
	pha
	sta	$00,x
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	ply
	lda	a:data_05A014,y
	sta	SHOT_ATTR,x
	ldy	zp_FE
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	OBJ_X,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	OBJ_Y,x
	lda	#$0010
	sta	$04,x
	lda	#$0020
	sta	$14,x
	tyx
	lda	#$0001
	sta	PLAYER_SHOT_POSE,x
	lda	#$0007
	jsl	f:queue_sound
	rtl

spin_shot_homing_2:
	jsl	f:find_free_homing_shot_slot
	bcc	loc_00D94A
	tyx
	rtl
loc_00D94A:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00D982

spin_shot_homing_1:
	; (not executed in the CDL traces)
	jsl	f:find_free_homing_shot_slot
	bcc	loc_00D969
	tyx
	rtl
loc_00D969:
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	loc_00D982

; WEAPON_HOMING: a homing missile (type 4, damage 2) in a slot found by
; find_free_homing_shot_slot; sound 8.
spawn_shot_homing:
	jsl	f:find_free_homing_shot_slot
	bcc	loc_00D982
	tyx
	rtl
loc_00D982:
	lda	#$0004
	sta	SHOT_TYPE,x
	lda	#$0002
	sta	SHOT_DAMAGE,x
	phy
	stx	zp_04
	sec
	lda	zp_06
	sbc	zp_04
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	#$0006
	clc
	adc	zp_12
	and	#$007E
	tay
	sta	$04,x
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	ply
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	OBJ_X,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	OBJ_Y,x
	lda	#$305E
	sta	SHOT_ATTR,x
	tyx
	lda	#$0001
	sta	PLAYER_SHOT_POSE,x
	lda	#$0008
	jsl	f:queue_sound
	rtl

spin_shots_flame_2:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0004
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	spawn_shots_flame

spin_shots_flame_1:
	; (not executed in the CDL traces)
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0004
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	spawn_shots_flame
loc_00DA06:
	tyx
	rtl

; WEAPON_FLAME: a chain of 10 flame shots occupying all 10 slots of the
; weapon; the chain's head keeps state in the first slot's OBJ_STATE.
spawn_shots_flame:
	lda	$12,x
	beq	loc_00DA0F
	brl	loc_00DA80
loc_00DA0F:
	lda	SHOT_TYPE,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	ora	$B0,x
	ora	$D0,x
	ora	$F0,x
	ora	a:$0110,x
	ora	a:$0130,x
	bne	loc_00DA06
	inc	$12,x
	stz	OBJ_X_VEL,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	lda	zp_12
	asl	a
	asl	a
	sta	$14,x
	sta	$34,x
	sta	$54,x
	sta	$74,x
	sta	$94,x
	sta	$B4,x
	sta	$D4,x
	sta	$F4,x
	lda	#$8000	; [num]
	sta	$2A,x
	sta	$4A,x
	sta	$6A,x
	sta	$8A,x
	sta	$AA,x
	sta	$CA,x
	sta	$EA,x
	sta	a:$010A,x
	sta	a:$012A,x
	phx
	tyx
	lda	zp_12
	lsr	a
	lsr	a
	lsr	a
	tay
	clc
	lda	OBJ_X,x
	adc	zp_14
	adc	a:data_05A024,y
	sta	zp_00
	clc
	lda	OBJ_Y,x
	adc	zp_16
	adc	a:data_05A034,y
	ply
	sta	a:OBJ_Y,y
	lda	zp_00
	sta	a:OBJ_X,y
	rtl
loc_00DA80:
	lda	stage_frame_counter
	bit	#$000F
	bne	loc_00DA8E
	lda	#$000A
	jsl	f:queue_sound
loc_00DA8E:
	lda	$D4,x
	sta	$F4,x
	lda	$B4,x
	sta	$D4,x
	lda	$94,x
	sta	$B4,x
	lda	$74,x
	sta	$94,x
	lda	$54,x
	sta	$74,x
	lda	$34,x
	sta	$54,x
	lda	$14,x
	sta	$34,x
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	zp_00
	sec
	lda	OBJ_X,x
	sbc	zp_00
	cmp	#$0005
	bcc	loc_00DAD3
	cmp	#$FFFB	; [num]
	bcs	loc_00DAD3
	bmi	loc_00DACB
	sec
	lda	OBJ_X,x
	sbc	#$0005
	bra	loc_00DAD5
loc_00DACB:
	clc
	lda	OBJ_X,x
	adc	#$0005
	bra	loc_00DAD5
loc_00DAD3:
	lda	zp_00
loc_00DAD5:
	sta	OBJ_X,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	zp_00
	sec
	lda	OBJ_Y,x
	sbc	zp_00
	cmp	#$0005
	bcc	loc_00DB00
	cmp	#$FFFB	; [num]
	bcs	loc_00DB00
	bmi	loc_00DAF8
	sec
	lda	OBJ_Y,x
	sbc	#$0005
	bra	loc_00DB02
loc_00DAF8:
	clc
	lda	OBJ_Y,x
	adc	#$0005
	bra	loc_00DB02
loc_00DB00:
	lda	zp_00
loc_00DB02:
	sta	OBJ_Y,x
	phy
	lda	zp_12
	asl	a
	asl	a
	sta	zp_06
	tay
	sec
	lda	zp_06
	sbc	$14,x
	beq	loc_00DB17
	bmi	loc_00DB1B
	bpl	loc_00DB2D
loc_00DB17:
	lda	zp_06
	bra	loc_00DB40
loc_00DB1B:
	cmp	#$FF00	; [num]
	bcc	loc_00DB37
	cmp	#$FFF0	; [num]
	bcs	loc_00DB17
loc_00DB25:
	sec
	lda	$14,x
	sbc	#$0010
	bra	loc_00DB3D
loc_00DB2D:
	cmp	#$0100
	bcs	loc_00DB25
	cmp	#$0010
	bcc	loc_00DB17
loc_00DB37:
	clc
	lda	$14,x
	adc	#$0010
loc_00DB3D:
	and	#$01FF
loc_00DB40:
	sta	$14,x
	lda	$F4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$CE,x
	sta	$EE,x
	clc
	adc	#$FFF0
	sta	a:$012E,x
	clc
	lda	a:data_058F1A,y
	adc	$CA,x
	sta	$EA,x
	sta	a:$012A,x
	lda	$D4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$AE,x
	sta	$CE,x
	clc
	adc	#$FFF4
	sta	a:$010E,x
	clc
	lda	a:data_058F1A,y
	adc	$AA,x
	sta	$CA,x
	sta	a:$010A,x
	lda	$B4,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$8E,x
	sta	$AE,x
	clc
	lda	a:data_058F1A,y
	adc	$8A,x
	sta	$AA,x
	lda	$94,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$6E,x
	sta	$8E,x
	clc
	lda	a:data_058F1A,y
	adc	$6A,x
	sta	$8A,x
	lda	$74,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$4E,x
	sta	$6E,x
	clc
	lda	a:data_058F1A,y
	adc	$4A,x
	sta	$6A,x
	lda	$54,x
	tay
	clc
	lda	a:data_058E9A,y
	adc	$2E,x
	sta	$4E,x
	clc
	lda	a:data_058F1A,y
	adc	$2A,x
	sta	$4A,x
	lda	$14,x
	sta	$34,x
	lda	OBJ_Y,x
	sta	$2E,x
	lda	OBJ_X,x
	sta	$2A,x
	lda	#$0005
	sta	SHOT_TYPE,x
	lda	#$0006
	sta	$30,x
	sta	$50,x
	sta	$70,x
	sta	$90,x
	sta	$B0,x
	sta	$D0,x
	sta	$F0,x
	sta	a:$0110,x
	sta	a:$0130,x
	stz	$04,x
	lda	#$3F62
	sta	$24,x
	inc	a
	inc	a
	sta	$44,x
	sta	$64,x
	inc	a
	inc	a
	sta	$84,x
	sta	$A4,x
	inc	a
	inc	a
	sta	$C4,x
	sta	$E4,x
	inc	a
	inc	a
	sta	a:$0104,x
	sta	a:$0124,x
	lda	#$0001
	sta	$26,x
	sta	$46,x
	sta	$66,x
	sta	$86,x
	sta	$A6,x
	sta	$C6,x
	sta	$E6,x
	lda	#$0001
	sta	$00,x
	sta	$20,x
	sta	$40,x
	sta	$60,x
	sta	$80,x
	sta	$A0,x
	sta	$C0,x
	sta	a:$0100,x
	sta	$E0,x
	sta	a:$0120,x
	plx
	rtl

spin_shot_laser_2:
	jsr	a:check_laser_shot_slots
	beq	loc_00DC43
	rtl
loc_00DC43:
	clc
	lda	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_2,y
	adc	#$0040
	and	#$007E
	sta	zp_12
	bra	loc_00DC8E

spin_shot_laser_1:
	jsr	a:check_laser_shot_slots
	beq	loc_00DC60
	rtl
loc_00DC60:
	clc
	lda	a:PLAYER_SPIN_ANGLE_1,y
	adc	#$0010
	and	#$007E
	sta	a:PLAYER_SPIN_ANGLE_1,y
	sta	zp_12
	bra	loc_00DC8E

; Returns Z set when the 9 shot slots from X are free, else Z clear and X =
; Y.
check_laser_shot_slots:
	lda	SHOT_TYPE,x
	ora	$30,x
	ora	$50,x
	ora	$70,x
	ora	$90,x
	ora	$B0,x
	ora	$D0,x
	ora	$F0,x
	ora	a:$0110,x
	beq	loc_00DC87
	tyx
loc_00DC87:
	rts

; WEAPON_LASER: a laser beam (several shot slots, find via
; check_laser_shot_slots).
spawn_shot_laser:
	jsr	a:check_laser_shot_slots
	beq	loc_00DC8E
	rtl
loc_00DC8E:
	lda	#$000C
	sta	$30,x
	lda	#$000B
	sta	SHOT_TYPE,x
	sta	$50,x
	sta	$70,x
	sta	$90,x
	sta	$B0,x
	sta	$D0,x
	sta	$F0,x
	sta	a:$0110,x
	sty	zp_FE
	ldy	zp_12
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	sta	$58,x
	sta	$78,x
	sta	$98,x
	sta	$B8,x
	sta	$D8,x
	sta	$F8,x
	sta	a:$0118,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	sta	$5A,x
	sta	$7A,x
	sta	$9A,x
	sta	$BA,x
	sta	$DA,x
	sta	$FA,x
	sta	a:$011A,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	sta	$5C,x
	sta	$7C,x
	sta	$9C,x
	sta	$BC,x
	sta	$DC,x
	sta	$FC,x
	sta	a:$011C,x
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	sta	$5E,x
	sta	$7E,x
	sta	$9E,x
	sta	$BE,x
	sta	$DE,x
	sta	$FE,x
	sta	a:$011E,x
	lda	zp_12
	lsr	a
	lsr	a
	lsr	a
	tay
	lda	a:data_05A064,y
	sta	SHOT_ATTR,x
	lda	a:data_05A044,y
	sta	zp_00
	lda	a:data_05A054,y
	sta	zp_02
	lda	#$0004
	sta	$44,x
	inc	a
	inc	a
	sta	$64,x
	inc	a
	inc	a
	sta	$84,x
	inc	a
	inc	a
	inc	a
	sta	$A4,x
	inc	a
	inc	a
	sta	$C4,x
	inc	a
	inc	a
	sta	$E4,x
	inc	a
	inc	a
	inc	a
	sta	a:$0104,x
	sta	$24,x
	lda	a:data_05A064,y
	sta	$54,x
	sta	$74,x
	sta	$94,x
	sta	$B4,x
	sta	$D4,x
	sta	$F4,x
	sta	a:$0114,x
	ldy	zp_FE
	clc
	lda	a:OBJ_X,y
	adc	zp_14
	sta	OBJ_X,x
	sta	$2A,x
	clc
	adc	zp_00
	sta	$4A,x
	clc
	adc	zp_00
	sta	$6A,x
	clc
	adc	zp_00
	sta	$8A,x
	clc
	adc	zp_00
	sta	$AA,x
	clc
	adc	zp_00
	sta	$CA,x
	clc
	adc	zp_00
	sta	$EA,x
	clc
	adc	zp_00
	sta	a:$010A,x
	clc
	lda	a:OBJ_Y,y
	adc	zp_16
	sta	OBJ_Y,x
	sta	$2E,x
	clc
	adc	zp_02
	sta	$4E,x
	clc
	adc	zp_02
	sta	$6E,x
	clc
	adc	zp_02
	sta	$8E,x
	clc
	adc	zp_02
	sta	$AE,x
	clc
	adc	zp_02
	sta	$CE,x
	clc
	adc	zp_02
	sta	$EE,x
	clc
	adc	zp_02
	sta	a:$010E,x
	lda	#$0004
	sta	SHOT_DAMAGE,x
	dec	SHOT_HIT,x
	dec	$36,x
	dec	$56,x
	dec	$76,x
	dec	$96,x
	dec	$B6,x
	dec	$D6,x
	dec	$F6,x
	dec	a:$0116,x
	tyx
	lda	#$0001
	sta	PLAYER_SHOT_POSE,x
	lda	#$0005
	jsl	f:queue_sound
	rtl
