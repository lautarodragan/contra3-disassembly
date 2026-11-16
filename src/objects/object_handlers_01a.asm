; objects/object_handlers_01a.asm -- Object handlers (bank $01, part 1)
; Bank $01, $01:B194-$01:CF8A. Included by main.asm in segment BANK01.
;
; Handlers of object types dispatched through tbl_object_types and their helpers;
; spawn_effect..sub_01CF66 are helpers used by every bank.

; Object type $02: seen once in stage 1 (section 8); sets OBJ_HP to $100 in
; state 0 and runs 11 states. Not identified.
update_object_type_02:
	lda	OBJ_STATE,x
	pha
	beq	loc_01B200
	cmp	#$0008
	bcs	loc_01B1EE
	lda	OBJ_HP,x
	bpl	loc_01B1E0
	pla
	lda	#$0042
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
loc_01B1E0:
	lda	$26,x
	beq	loc_01B1EE
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
loc_01B1EE:
	sec
	lda	#$00A8
	sbc	$0E,x
	sta	a:bg2_y
	sec
	lda	#$015C
	sbc	$0A,x
	sta	a:bg2_x
loc_01B200:
	pla
	phx
	asl	a
	tax
	lda	f:tbl_object_type_02_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_02_states:
	.addr	object_type_02_state_00
	.addr	object_type_02_state_01
	.addr	object_type_02_state_02
	.addr	object_type_02_state_03
	.addr	object_type_02_state_04
	.addr	object_type_02_state_05
	.addr	object_type_02_state_06
	.addr	object_type_02_state_07
	.addr	object_type_02_state_08
	.addr	shake_and_explode_state
	.addr	object_type_02_state_0A

object_type_02_state_00:
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

object_type_02_state_01:
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
	bcs	loc_01B293
	lda	#$FFFC	; [num]
	sta	a:$001E,y
loc_01B293:
	stx	zp_FA
	stz	zp_00
	stz	zp_0C
	lda	$24,x
	cmp	#$0010
	bcc	loc_01B2A5
	lda	#$0000
	sta	$24,x
loc_01B2A5:
	cmp	#$0003
	bcs	loc_01B30F
	cmp	#$0000
	beq	loc_01B2C8
	ldy	#$0010
	sty	zp_00
	ldy	#$0100
	sty	zp_0C
	cmp	#$0001
	beq	loc_01B2C8
	lda	#$0020
	sta	zp_00
	lda	#$0200
	sta	zp_0C
loc_01B2C8:
	lda	a:bg1_x
	bit	#$0100
	beq	loc_01B2D8
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
loc_01B2D8:
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
	bne	loc_01B30F
	clc
	lda	$30,x
	adc	#$0030
	sta	$30,x
	cmp	#.loword(vram_blocks_05ACDF + $240)	; past the last block
	bcc	loc_01B30F
	inc	$12,x
	lda	#$0060
	sta	$24,x
loc_01B30F:
	inc	$24,x
	rtl

object_type_02_state_02:
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
	lda	#$001E
	jsl	f:queue_sound
@return:
	rtl

object_type_02_state_03:
	inc	a:shake_continuous
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	loc_01B353
	lda	#$401D
	sta	OBJ_FLAGS,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0001
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_01B353:
	ldy	#.loword(vram_blocks_05AC97)
	lda	stage_frame_bit1
	bne	loc_01B35D
	ldy	#.loword(vram_blocks_05ACA7)
loc_01B35D:
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	#$4E08
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

object_type_02_state_04:
	lda	OBJ_TIMER,x
	bne	loc_01B383
	ldy	#.loword(vram_blocks_05ACB7)
	inc	OBJ_STATE,x
	lda	#$4D88
	pha
	lda	#$0040
	bra	loc_01B38F
loc_01B383:
	ldy	#.loword(vram_blocks_05ACC7)
	dec	$24,x
	lda	#$4E88
	pha
	lda	#$0020
loc_01B38F:
	sta	zp_08
	lda	#$0004
	sta	zp_02
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

object_type_02_state_05:
	inc	a:shake_continuous
	lda	OBJ_X,x
	cmp	#$0028
	bcs	loc_01B3E0
	inc	OBJ_STATE,x
	stz	OBJ_X_VEL,x
	stz	OBJ_FACING,x
	lda	#$0001
	sta	$38,x
	rtl

object_type_02_state_06:
	inc	a:shake_continuous
	lda	OBJ_FACING,x
	beq	loc_01B3C3
	lda	OBJ_X,x
	cmp	$34,x
	bcs	loc_01B3E0
	bcc	loc_01B3CA
loc_01B3C3:
	lda	$0A,x
	cmp	#$0090
	bcc	loc_01B3E0
loc_01B3CA:
	lda	#$0100
	sta	$30,x
	lda	#$001F
	jsl	f:queue_sound
	stz	$18,x
	stz	$1A,x
	lda	#$0007
	sta	$12,x
	rtl
loc_01B3E0:
	lda	stage_frame_bit1
	bne	loc_01B3F2
	lda	#$B600	; [num]
	sta	zp_FC
	ldy	#.loword(vram_blocks_05ACCF)
	lda	#$4E88
	pha
	bra	loc_01B3FE
loc_01B3F2:
	lda	#$BF40	; [num]
	sta	zp_FC
	ldy	#.loword(vram_blocks_05ACD7)
	lda	#$4E88
	pha
loc_01B3FE:
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
	bne	loc_01B459
	rtl

object_type_02_state_07:
	lda	difficulty
	cmp	#$0004
	bcs	loc_01B428
	stz	$38,x
loc_01B428:
	lda	$30,x
	bne	loc_01B457
	lda	$04,x
	eor	#$0001
	sta	$04,x
	beq	loc_01B43F
	lda	#$0060
	sta	$34,x
	lda	#$FFFF	; [num]
	bra	loc_01B442
loc_01B43F:
	lda	#$0000
loc_01B442:
	sta	$1A,x
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0006
	sta	$12,x
	lda	#$001E
	jsl	f:queue_sound
	bra	loc_01B4D0
loc_01B457:
	dec	$30,x
loc_01B459:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:object_type_02_fragment_masks,y
	bne	loc_01B4CC
	jsl	f:find_free_slot_y
	bcs	loc_01B4CC
	lda	$0A,x
	adc	#$0002
	sta	a:$000A,y
	lda	$0E,x
	adc	#$FFC0
	sta	a:$000E,y
	lda	#$001C
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
	lda	a:object_type_02_fragment_y_vels,x
	sta	a:$001E,y
	lda	rng_hi
	and	#$0007
	asl	a
	clc
	adc	zp_00
	sta	zp_00
	tax
	lda	a:object_type_02_fragment_x_vel_subs,x
	sta	a:$0018,y
	lda	zp_00
	and	#$000F
	tax
	lda	a:object_type_02_fragment_x_vels,x
	sta	a:$001A,y
	plx
	lda	#$001A
	jsl	f:queue_sound
loc_01B4CC:
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

object_type_02_state_08:
	jsl	f:queue_sound_41_throttled
	dec	$24,x
	bne	loc_01B4FB
	inc	$12,x
	lda	#$0030
	sta	$24,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	rtl
loc_01B4FB:
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

object_type_02_state_0A:
	lda	#$0000
	sta	a:bg2_x
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0001
	sta	a:bg1_scroll_mode
	lda	#$0001
	sta	a:stage_checkpoint
	rtl

; Object type $1C: falling fragment (sprite by vertical speed) that explodes
; on the floor or when shot (stage 1 section 9). Not identified.
update_object_type_1C:
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	loc_01B549
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	bra	loc_01B54D
loc_01B549:
	lda	$14,x
	beq	loc_01B555
loc_01B54D:
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
loc_01B555:
	lda	$1E,x
	bpl	loc_01B568
	cmp	#$FFFE	; [num]
	bcs	loc_01B563
	lda	#.loword(metasprite_06AF96)
	bra	loc_01B57F
loc_01B563:
	lda	#.loword(metasprite_06AFB9)
	bra	loc_01B57F
loc_01B568:
	cmp	#$0001
	bcs	loc_01B572
	lda	#.loword(metasprite_06AFB4)
	bra	loc_01B57F
loc_01B572:
	cmp	#$0003
	bcs	loc_01B57C
	lda	#.loword(metasprite_06AFAF)
	bra	loc_01B57F
loc_01B57C:
	lda	#.loword(metasprite_06AFAA)
loc_01B57F:
	sta	$00,x
	lda	$1E,x
	bmi	loc_01B58A
	cmp	#$0003
	bcs	loc_01B599
loc_01B58A:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01B599:
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
	bpl	loc_01B60F
	inc	OBJ_STATE,x
	stz	OBJ_FLAGS,x
	lda	#$0080
	sta	OBJ_TIMER,x
	rtl
loc_01B60F:
	lda	$26,x
	beq	loc_01B61D
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$6050
	sta	cgram_upload_addr
loc_01B61D:
	lda	$24,x
	bpl	loc_01B639
	; (not executed in the CDL traces)
	lda	#$F000	; [num]
	sta	$18,x
	stz	$1A,x
	lda	$0A,x
	cmp	#$0100
	bcc	loc_01B682
	lda	#$0100
	sta	$24,x
	dec	$12,x
	stz	$16,x
	rtl
loc_01B639:
	dec	$24,x
	lda	$0A,x
	cmp	#$0090
	bcs	loc_01B648
	stz	$18,x
	stz	$1A,x
	bra	loc_01B662
loc_01B648:
	lda	$1A,x
	bpl	loc_01B651
	cmp	#$FFFF	; [num]
	bcc	loc_01B662
loc_01B651:
	sec
	lda	$18,x
	sbc	#$2000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	loc_01B682
loc_01B662:
	lda	stage_frame_counter
	and	#$007F
	bne	loc_01B682
	lda	#$0000
	jsl	f:spawn_homing_missile
	bcc	loc_01B682
	lda	#$0002
	sta	$1A,x
	lda	#$00A0
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
loc_01B682:
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:bg1_x
	lda	#$0003
	sta	zp_02
	lda	#$0018
	sta	zp_08
	lda	stage_frame_bit1
	bne	loc_01B69E
	ldy	#.loword(vram_blocks_05AF25)
	bra	loc_01B6A1
loc_01B69E:
	ldy	#.loword(vram_blocks_05AF2B)
loc_01B6A1:
	lda	#$4688
	phx
	jsl	f:queue_vram_blocks
	plx
	rtl

stage4_tank_state_03:
	dec	OBJ_TIMER,x
	bpl	loc_01B6D1
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
	bra	loc_01B6E3
loc_01B6D1:
	lda	stage_frame_odd
	bne	loc_01B6E3
	sec
	lda	#$0140
	sbc	$0A,x
	sta	a:bg1_x
	lda	#.loword(anim_05C5B8)
	bra	loc_01B6E9
loc_01B6E3:
	lda	#.loword(anim_05C4CE)
	stz	a:bg1_x
loc_01B6E9:
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
	beq	loc_01B723
	lda	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	beq	loc_01B74B
	cmp	#$0009
	bcs	loc_01B74B
loc_01B723:
	; (not executed in the CDL traces)
	lda	stage_frame_mod8
	bne	loc_01B74B
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
	bcs	loc_01B74B
	lda	#$FFFE	; [num]
	sta	a:$001E,y
loc_01B74B:
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
	beq	loc_01B7A8
	bmi	loc_01B7A8
	ldy	#$0200
	jsr	a:player_tank_check_boarding
	lda	a:player1_state
	cmp	#$0009
	beq	player_tank_state_02
loc_01B7A8:
	lda	a:player2_obj+OBJ_FLAGS
	beq	loc_01B7DD
	bmi	loc_01B7DD
	ldy	#$0240
	jsr	a:player_tank_check_boarding
	bra	loc_01B7DD

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
	beq	loc_01B7DD
	bmi	loc_01B7DD
	lda	$34,x
	sta	zp_0C
	jsl	f:solid_object_vs_player
loc_01B7DD:
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
loc_01B7F3:
	lda	a:$0016,y
	bit	#$0800
	beq	loc_01B83E
	jsr	a:solid_object_vs_object
	lda	zp_0E
	beq	loc_01B83E
	bit	#$1000
	beq	loc_01B83E
	lda	a:$0010,y
	cmp	#$002D
	beq	loc_01B81A
	lda	#$0200
	sta	a:$003C,y
	dec	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	bne	loc_01B829
loc_01B81A:
	; (not executed in the CDL traces)
	stz	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x
	bra	loc_01B831
loc_01B829:
	lda	a:obj_slots+31*OBJ_SIZE+OBJ_HP
	cmp	#$0008
	bne	loc_01B83E
loc_01B831:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	a:wram_165A
	lda	#.loword(vram_blocks_05AF49)
	sta	$3A,x
	bra	loc_01B849
loc_01B83E:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B7F3
loc_01B849:
	sec
	lda	#$0168
	sbc	$0A,x
	sta	f:hdma_tables+$07
	lda	a:tank_move_dx
	bne	loc_01B85E
	lda	a:wram_165A
	bne	loc_01B861
	rtl
loc_01B85E:
	inc	a:shake_continuous
loc_01B861:
	lda	stage_frame_mod4
	bne	loc_01B89B
	lda	#$0003
	sta	zp_02
	lda	a:wram_165A
	beq	loc_01B87F
	; (not executed in the CDL traces)
	stz	a:wram_165A
	lda	#$0030
	sta	zp_08
	lda	#$4E8C
	ldy	#.loword(vram_blocks_05AF55)
	bra	loc_01B895
loc_01B87F:
	ldy	$3A,x
	lda	rng_temp
	bne	loc_01B88D
	clc
	lda	a:$003A,x
	adc	#$0006
	tay
loc_01B88D:
	lda	#$0018
	sta	zp_08
	lda	#$4F0C
loc_01B895:
	phx
	jsl	f:queue_vram_blocks
	plx
loc_01B89B:
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
	beq	loc_01B8C6
	lda	OBJ_X,x
	cmp	#$FF80	; [num]
	bcs	loc_01B8D5
	cmp	#$FF00	; [num]
	bcc	loc_01B8D5
loc_01B8C6:
	lda	#$0004
	sta	$12,x
	stz	$16,x
	lda	#$0000
	sta	f:hdma_tables+$07
	rtl
loc_01B8D5:
	lda	a:wram_165A
	bne	loc_01B861
	lda	stage_frame_odd
	bne	loc_01B8FA
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
loc_01B8FA:
	jsr	a:player_tank_push_objects
	lda	$24,x
	cmp	#$0060
	bcs	loc_01B90D
	lda	stage_frame_odd
	bne	loc_01B90D
	sta	f:hdma_tables+$07
	rtl
loc_01B90D:
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
	beq	loc_01B966
	ldy	#$0200
	stz	zp_0C
	jsl	f:solid_object_vs_player
	beq	loc_01B974
loc_01B966:
	lda	a:player2_obj+OBJ_FLAGS
	beq	loc_01B974
	ldy	#$0240
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_01B974:
	jsr	a:set_solid_push_flags
loc_01B977:
	lda	a:$0010,y
	cmp	#$000A
	beq	loc_01B984
	cmp	#$001E
	bne	loc_01B987
loc_01B984:
	jsr	a:solid_object_vs_object
loc_01B987:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B977
	rtl

player_tank_push_objects:
	; (not executed in the CDL traces)
	lda	a:player1_obj+OBJ_FLAGS
	beq	loc_01B9A5
	bmi	loc_01B9A5
	ldy	#$0200
	stz	zp_0C
	jsl	f:solid_object_vs_player
	beq	loc_01B9B5
loc_01B9A5:
	lda	a:player2_obj+OBJ_FLAGS
	beq	loc_01B9B5
	bmi	loc_01B9B5
	ldy	#$0240
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_01B9B5:
	jsr	a:set_solid_push_flags
loc_01B9B8:
	lda	a:$0016,y
	bit	#$0800
	beq	loc_01B9D2
	jsr	a:solid_object_vs_object
	lda	zp_0E
	beq	loc_01B9D2
	bit	#$1000
	beq	loc_01B9D2
	lda	#$0200
	sta	a:$003C,y
loc_01B9D2:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	loc_01B9B8
	rts

; Solid for the player at Y; when that player stands on the tank 40-48
; pixels right of its x, it enters: tank_driver = Y, player state 9.
player_tank_check_boarding:
	lda	$34,x
	sta	zp_0C
	jsl	f:solid_object_vs_player
	lda	a:$003C,y
	bit	#$0080
	beq	loc_01BA08
	clc
	lda	$0A,x
	adc	#$0020
	bmi	loc_01BA08
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	loc_01BA08
	clc
	adc	#$0008
	cmp	a:$000A,y
	bcs	loc_01BA1C
loc_01BA08:
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
loc_01BA1C:
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
loc_01BA46:
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
	bmi	loc_01BA46
	sta	zp_10
	clc
	lda	a:$000A,y
	adc	a:$0028,y
	sec
	sbc	$0A,x
	bmi	loc_01BA46
	sta	zp_12
	clc
	lda	$0E,x
	adc	$2A,x
	sec
	sbc	a:$000E,y
	bpl	loc_01BA46
	eor	#$FFFF
	inc	a
	sta	zp_14
	clc
	lda	a:$000E,y
	adc	a:$002A,y
	sec
	sbc	$0E,x
	bpl	loc_01BA46
	eor	#$FFFF
	inc	a
	sta	zp_16
	lda	a:$0016,y
	sta	zp_0E
	lda	zp_10
	cmp	zp_12
	bcc	loc_01BA94
	lda	zp_12
loc_01BA94:
	sta	zp_08
	lda	zp_14
	cmp	zp_16
	bcc	loc_01BA9E
	lda	zp_16
loc_01BA9E:
	sta	zp_0A
	lda	zp_0A
	cmp	zp_08
	bcs	loc_01BAC3
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
loc_01BAC3:
	lda	zp_10
	cmp	zp_12
	bcs	loc_01BADA
	clc
	lda	$0A,x
	adc	$28,x
	sta	a:$000A,y
	lda	zp_02
	ora	a:$003E,y
	sta	a:$003E,y
	rts
loc_01BADA:
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
	bmi	loc_01BAF4
	lda	OBJ_HP,x
	bpl	loc_01BAFF
loc_01BAF4:
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
loc_01BAFF:
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
	bcc	loc_01BB3A
	lda	#$0002
	sta	$04,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	rts
loc_01BB3A:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	rts
loc_01BB45:
	jsr	a:soldier_stop_and_run
	bra	loc_01BB68

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
loc_01BB68:
	ldy	difficulty
	lda	a:soldier_hp,y
	sta	$06,x
	lda	#$0001
	sta	$12,x
	lda	#$3600
	bra	loc_01BB7E

foot_soldier_state_00:
	stz	OBJ_HP,x
	lda	#$3400
loc_01BB7E:
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
	bne	loc_01BBCE
	lda	#.loword(anim_05AFB6)
	sta	OBJ_ANIM,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	inc	OBJ_STATE,x

foot_soldier_state_01:
	lda	$3E,x
	beq	loc_01BC07
loc_01BBCE:
	bit	#$0004
	beq	loc_01BBD6
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BBD6:
	dec	$30,x
	stz	$3E,x
	stz	$22,x
	bit	#$0200
	beq	loc_01BBF1
	inc	$0A,x
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	bra	loc_01BC07
loc_01BBF1:
	bit	#$0400
	beq	loc_01BC07
	dec	$0A,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	lda	#$0002
	sta	$04,x
loc_01BC07:
	rtl

foot_soldier_state_03:
	lda	$3E,x
	beq	loc_01BC0F
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BC0F:
	lda	$20,x
	bne	loc_01BC46
	lda	#$0001
	sta	$12,x
	lda	#.loword(anim_05AF9C)
	sta	$20,x
	lda	#$7000
	sta	$24,x
	lda	$0A,x
	cmp	#$0080
	bcs	loc_01BC39
	lda	#$0002
	sta	$04,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$97FF	; [num]
	sta	$18,x
	rtl
loc_01BC39:
	stz	$04,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
	rtl
loc_01BC46:
	dec	$24,x
	bne	loc_01BC6E
	lda	$0E,x
	adc	#$FFEA
	sta	zp_02
	lda	$04,x
	bne	loc_01BC63
	lda	$0A,x
	adc	#$0008
	sta	zp_00
	lda	#$0010
	jml	f:spawn_enemy_bullet
loc_01BC63:
	lda	$0A,x
	sta	zp_00
	lda	#$0030
	jml	f:spawn_enemy_bullet
loc_01BC6E:
	rtl

; Object type $35: stage 1 (the cafe front), HP 1. Not identified.
update_object_type_35:
	lda	OBJ_HP,x
	bpl	loc_01BC76
	brl	loc_01BAF4
loc_01BC76:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_35_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_35_states:
	.addr	object_type_35_state_00
	.addr	object_type_35_state_01
	.addr	object_type_35_state_02
	.addr	object_type_35_state_03
	.addr	object_type_35_state_04

object_type_35_state_00:
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

object_type_35_state_01:
	lda	OBJ_X,x
	cmp	#$00D0
	bcs	@return
	inc	OBJ_STATE,x
@return:
	rtl

object_type_35_state_02:
	lda	$34,x
	bne	loc_01BD30
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
loc_01BCD2:
	jsl	f:find_free_slot_from_y
	bcc	loc_01BCED
loc_01BCD8:
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bpl	loc_01BCD2
	plx
	lda	#$001B
	jsl	f:queue_sound
	inc	$12,x
	rtl
loc_01BCED:
	lda	#OBJT_BOUNCING_DEBRIS
	sta	a:$0010,y
	lda	#$0001
	sta	a:$0016,y
	lda	a:object_type_35_debris_x_offsets,x
	adc	zp_10
	sta	a:$000A,y
	lda	a:object_type_35_debris_y,x
	sta	a:$000E,y
	lda	a:object_type_35_debris_x_vels,x
	sta	a:$001A,y
	lda	a:object_type_35_debris_x_vel_subs,x
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
	bra	loc_01BCD8
loc_01BD30:
	lda	stage_frame_mod4
	cmp	#$0003
	bne	@return
	jsl	f:queue_object_tiles
@return:
	rtl

object_type_35_state_03:
	lda	OBJ_Y_VEL,x
	bmi	loc_01BD62
	lda	#$081F
	sta	OBJ_FLAGS,x
	lda	#$0010
	sta	OBJ_HITBOX_W,x
	lda	#$FFE0	; [num]
	sta	OBJ_HITBOX_H,x
	inc	OBJ_STATE,x

object_type_35_state_04:
	lda	$3E,x
	beq	loc_01BD58
	; (not executed in the CDL traces)
	brl	loc_01BAF4
loc_01BD58:
	lda	#$00C8
	cmp	$0E,x
	bcs	loc_01BD62
	brl	loc_01BB45
loc_01BD62:
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

foot_soldier_state_04:
	dec	OBJ_TIMER,x
	bpl	loc_01BD8C
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_ANIM,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	ldy	#.loword(metasprite_06B16D)
	lda	OBJ_FACING,x
	beq	loc_01BD8A
	ldy	#.loword(metasprite_06B427)
loc_01BD8A:
	sty	$00,x
loc_01BD8C:
	rtl

foot_soldier_state_05:
	lda	#$00C8
	cmp	OBJ_Y,x
	bcs	loc_01BDA5
	sta	OBJ_Y,x
	lda	#$0001
	sta	OBJ_STATE,x
	lda	#.loword(anim_05AF9C)
	sta	OBJ_ANIM,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	rtl
loc_01BDA5:
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
	bne	loc_01BDC4
	lda	#$0040
	sta	$32,x
	lda	#$0080
	sta	$34,x
	inc	OBJ_STATE,x
loc_01BDC4:
	dec	$32,x
	bne	loc_01BE16
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:soldier_spawn_delays_right,y
	sta	$32,x
	ldy	#$0900
loc_01BDD7:
	lda	a:$0016,y
	bit	#$0040
	beq	loc_01BDEA
	lda	a:$000A,y
	adc	a:$0028,y
	cmp	#$00F8
	bcs	loc_01BE16
loc_01BDEA:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	loc_01BDD7
	ldy	#$0300
	jsl	f:find_free_slot_from_y
	bcs	loc_01BE71
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
	bra	loc_01BE60
loc_01BE16:
	dec	$34,x
	bne	loc_01BE71
	ldy	difficulty
	lda	rng_hi
	and	#$00FF
	adc	a:soldier_spawn_delays_left,y
	sta	$34,x
	ldy	#$0900
loc_01BE29:
	lda	a:$0016,y
	bit	#$0040
	beq	loc_01BE3B
	lda	a:$000A,y
	bmi	loc_01BE71
	cmp	#$0008
	bcc	loc_01BE71
loc_01BE3B:
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0A00
	bcc	loc_01BE29
	ldy	#$0300
	jsl	f:find_free_slot_from_y
	bcs	loc_01BE71
	phx
	tyx
	lda	#$FFF0	; [num]
	sta	$0A,x
	lda	#$0001
	sta	$1A,x
	lda	#$A800	; [num]
	sta	$18,x
loc_01BE60:
	ldy	difficulty
	lda	rng_lo
	and	#$000F
	cmp	a:soldier_hp_odds,y
	bcs	loc_01BE72
	jsl	f:init_foot_soldier_with_hp
	plx
loc_01BE71:
	rtl
loc_01BE72:
	jsl	f:foot_soldier_state_00
	plx
	rtl

; Object type $73: stage 4: soldier dropping onto the road (HP 6); dies as
; type $1B.
update_object_type_73:
	lda	a:clear_enemies_timer
	bne	loc_01BE83
	lda	OBJ_HP,x
	bpl	loc_01BE98
	bmi	loc_01BE8C
loc_01BE83:
	lda	$02,x
	bne	loc_01BE8C
	; (not executed in the CDL traces)
	lda	#$3800
	sta	$02,x
loc_01BE8C:
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	lda	#.loword(metasprite_06C7EA)
	jml	f:start_dying_soldier_sprite
loc_01BE98:
	ldy	$30,x
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_73_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_73_states:
	.addr	object_type_73_state_00
	.addr	object_type_73_state_01
	.addr	object_type_73_state_02
	.addr	object_type_73_state_03

object_type_73_state_00:
	inc	OBJ_STATE,x
	lda	#.loword(metasprite_06C5CF)
	sta	OBJ_SPRITE,x
	lda	#$3600
	cpy	difficulty
	beq	loc_01BEC4
	bcc	loc_01BEC4
	lda	#$3800
loc_01BEC4:
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
	lda	a:object_type_73_y_vels,y
	sta	$1E,x
	lda	a:object_type_73_x,y
	sta	$0A,x
	lda	#$0015
	jml	f:queue_sound

object_type_73_state_01:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$2000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
	lda	OBJ_Y_VEL,x
	bmi	loc_01BF16
	inc	OBJ_STATE,x
	lda	#$0013
	sta	OBJ_FLAGS,x
	lda	#.loword(anim_05B002)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
loc_01BF16:
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

object_type_73_state_02:
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

object_type_73_state_03:
	stz	zp_00
	stz	zp_02
	lda	OBJ_Y_VEL,x
	bpl	loc_01BF80
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	bra	loc_01BFA6
loc_01BF80:
	lda	#$3000
	sta	$1C,x
	lda	$32,x
	bne	loc_01BFA4
	lda	$0E,x
	cmp	a:object_type_73_bounce_y,y
	bcc	loc_01BFA6
	lda	#$FFFD	; [num]
	sta	$1E,x
	lda	#$0004
	sta	zp_00
	lda	rng_hi
	and	#$003F
	adc	#$0010
	sta	$32,x
loc_01BFA4:
	dec	$32,x
loc_01BFA6:
	sec
	lda	$18,x
	sbc	#$1000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	bpl	loc_01BFCD
	cmp	#$FFFC	; [num]
	bcs	loc_01BFCD
	lda	#$FFFC	; [num]
	sta	zp_02
	lda	rng_lo
	sta	$18,x
	lda	#.loword(anim_05AFFC)
	sta	$20,x
	stz	$22,x
	lda	#$0003
loc_01BFCD:
	sta	$1A,x
	lda	zp_02
	ora	zp_00
	beq	loc_01BFFF
	ldy	#$0500
	jsl	f:find_free_slot_y_down
	bcc	loc_01BFFF
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
loc_01BFFF:
	lda	difficulty
	cmp	$30,x
	bcc	loc_01C03B
	lda	$34,x
	bpl	loc_01C039
	lda	$0A,x
	cmp	#$0050
	bcc	loc_01C01C
	lda	$00,x
	cmp	#.loword(metasprite_06C80C)
	bne	loc_01C03B
	lda	#$0028
	bra	loc_01C026
loc_01C01C:
	lda	$00,x
	cmp	#.loword(metasprite_06C5F1)
	bne	loc_01C03B
	lda	#$0020
loc_01C026:
	pha
	lda	#$0040
	sta	$34,x
	lda	$0E,x
	sta	zp_02
	lda	$0A,x
	sta	zp_00
	pla
	jml	f:spawn_enemy_bullet
loc_01C039:
	dec	$34,x
loc_01C03B:
	rtl

; Object type $7E: stage 4: soldier (HP 128); dies as type $1B.
update_object_type_7E:
	lda	a:clear_enemies_timer
	bne	loc_01C045
	lda	OBJ_HP,x
	bpl	loc_01C061
loc_01C045:
	lda	$34,x
	beq	loc_01C055
	lda	#$0004
	sta	a:clear_enemies_timer
	inc	a:obj_slots+29*OBJ_SIZE+OBJ_TIMER
	inc	a:obj_slots+29*OBJ_SIZE+OBJ_TIMER
loc_01C055:
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	lda	#.loword(metasprite_06C7EA)
	jml	f:start_dying_soldier_sound_0D
loc_01C061:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_7E_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_7E_states:
	.addr	object_type_7E_state_00
	.addr	object_type_7E_state_01
	.addr	object_type_7E_state_02
	.addr	object_type_7E_state_03
	.addr	object_type_7E_state_04
	.addr	object_type_7E_state_05
	.addr	object_type_7E_state_06
	.addr	object_type_7E_state_07

object_type_7E_state_00:
	jsl	f:object_type_7E_state_03
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

object_type_7E_state_02:
	sec
	lda	#$0080
	sbc	a:bg1_y
	sta	OBJ_Y,x
	lda	rng_hi
	bit	#$0007
	bne	loc_01C0BF
	dec	OBJ_STATE,x
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	lda	#.loword(metasprite_06C697)
	sta	OBJ_SPRITE,x
loc_01C0BF:
	lda	$30,x
	bne	loc_01C0DD
	lda	$1A,x
	bpl	loc_01C0CC
	cmp	#$FFFD	; [num]
	bcc	object_type_7E_state_01
loc_01C0CC:
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bra	object_type_7E_state_01
loc_01C0DD:
	lda	$1A,x
	bmi	loc_01C0E6
	cmp	#$0003
	bcs	object_type_7E_state_01
loc_01C0E6:
	clc
	lda	$18,x
	adc	#$3000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x

object_type_7E_state_01:
	lda	OBJ_X,x
	cmp	#$00E0
	bcc	loc_01C102
	lda	OBJ_X_VEL,x
	bpl	loc_01C111
	bmi	loc_01C10B
loc_01C102:
	cmp	#$0010
	bcs	loc_01C10B
	lda	$1A,x
	bmi	loc_01C111
loc_01C10B:
	dec	$32,x
	bpl	loc_01C12E
	bra	loc_01C11D
loc_01C111:
	eor	#$FFFF
	sta	$1A,x
	lda	$18,x
	eor	#$FFFF
	sta	$18,x
loc_01C11D:
	lda	rng_lo
	and	#$003F
	adc	#$0010
	sta	$32,x
	lda	$30,x
	eor	#$0002
	sta	$30,x
loc_01C12E:
	dec	$36,x
	bpl	loc_01C162
	ldy	difficulty
	lda	rng_lo
	and	#$001F
	adc	a:object_type_7E_spawn_delays,y
	sta	$36,x
	phx
	ldx	#$06C0
	jsl	f:find_free_slot_x_down
	bcc	loc_01C161
	jsl	f:object_type_7E_reset_sprite
	lda	#$007E
	sta	$10,x
	lda	#$0004
	sta	$12,x
	lda	rng_lo
	and	#$0006
	tay
	lda	a:object_type_7E_spawn_x,y
	sta	$0A,x
loc_01C161:
	plx
loc_01C162:
	bra	object_type_7E_state_04

object_type_7E_state_03:
	inc	OBJ_STATE,x

object_type_7E_reset_sprite:
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

object_type_7E_state_04:
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

object_type_7E_state_05:
	sec
	lda	#$0080
	sbc	a:bg1_y
	sta	OBJ_Y,x
	lda	#$0080
	jsl	f:pick_target_player
	sec
	lda	$0A,x
	sbc	a:$1312,y
	bpl	loc_01C1D6
	ldy	#$0002
	eor	#$FFFF
	bra	loc_01C1D9
loc_01C1D6:
	ldy	#$FFFE	; [num]
loc_01C1D9:
	cmp	#$0030
	bcs	loc_01C1E9
	inc	$12,x
	stz	$20,x
	stz	$22,x
	lda	#.loword(metasprite_06C697)
	sta	$00,x
loc_01C1E9:
	sty	$1A,x
	rtl

object_type_7E_state_06:
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

object_type_7E_state_07:
	rtl

; Object type $0D: gun turret that rises out of the rubble (stage 1, HP 16;
; seen in the emulator).
update_popup_turret:
	lda	$3E,x
	bne	loc_01C226
	lda	OBJ_HP,x
	bpl	loc_01C24A
loc_01C226:
	lda	#$0030
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
loc_01C24A:
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
	bne	loc_01C2C8
	lda	#$0080
	sta	OBJ_TIMER,x
	dec	OBJ_STATE,x
	rtl
loc_01C2C8:
	lda	$24,x
	cmp	#$0020
	beq	loc_01C2E1
	cmp	#$0010
	beq	loc_01C2E1
	lda	$34,x
	bne	queue_object_tiles_every_4
	inc	$34,x
	lda	#.loword(vram_blocks_05B04E)
	sta	$32,x
	bra	queue_object_tiles_every_4
loc_01C2E1:
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
	bne	loc_01C31B

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
loc_01C31B:
	rtl

popup_turret_state_05:
	lda	$34,x
	beq	loc_01C324
	jsl	f:queue_object_tiles_every_4
loc_01C324:
	dec	$24,x
	bne	loc_01C32E
	lda	#$8000	; [num]
	sta	$16,x
	rtl
loc_01C32E:
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
	bpl	loc_01C385
	lda	#$0030
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
loc_01C385:
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
	bne	loc_01C3E2
	lda	OBJ_Y,x
	bmi	loc_01C3F0
	cmp	#$0020
	bcs	loc_01C3EE
	rtl
loc_01C3E2:
	cmp	#$0001
	bne	loc_01C3F0
	lda	$0A,x
	cmp	#$00E0
	bcs	loc_01C3F0
loc_01C3EE:
	inc	$12,x
loc_01C3F0:
	rtl

wall_hatch_state_02:
	dec	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	bpl	loc_01C404
	inc	OBJ_STATE,x
	lda	#$0030
	sta	$34,x
	lda	#$4013
	sta	OBJ_FLAGS,x
	rtl
loc_01C404:
	bit	#$0007
	bne	loc_01C423
	lsr	a
	lsr	a
	tay
	lda	$12,x
	cmp	#$0002
	beq	loc_01C418
	lda	a:wall_hatch_close_tiles,y
	bra	loc_01C41B
loc_01C418:
	lda	a:wall_hatch_open_tiles,y
loc_01C41B:
	sta	zp_00
	lda	$3A,x
	jsl	f:queue_vram_block
loc_01C423:
	rtl

wall_hatch_state_03:
	lda	a:bg1_scroll_mode
	cmp	#$0003
	bne	loc_01C435
	lda	OBJ_Y,x
	cmp	#$00C0
	bcc	loc_01C44E
	bcs	loc_01C441
loc_01C435:
	cmp	#$0001
	bne	loc_01C44E
	lda	$0A,x
	cmp	#$0020
	bcs	loc_01C44E
loc_01C441:
	lda	#$0015
	sta	$24,x
	lda	#$0003
	sta	$16,x
	inc	$12,x
	rtl
loc_01C44E:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:wall_hatch_turn_masks,y
	bne	loc_01C48F
	lda	#$0800
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	lsr	a
	lsr	a
	and	#$003E
	sec
	sbc	$30,x
	bmi	loc_01C47C
	cmp	#$001E
	bcs	loc_01C486
	cmp	#$0002
	bcc	loc_01C48F
loc_01C476:
	lda	$30,x
	inc	a
	inc	a
	bra	loc_01C48A
loc_01C47C:
	cmp	#$FFE2	; [num]
	bcc	loc_01C476
	cmp	#$FFFE	; [num]
	bcs	loc_01C48F
loc_01C486:
	lda	$30,x
	dec	a
	dec	a
loc_01C48A:
	and	#$003E
	sta	$30,x
loc_01C48F:
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

; Object types $04 and $54: seen in stage 1 (section 4, a red soldier on a
; building ledge, probably). Not identified with certainty.
update_object_type_04:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_04_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_04_states:
	.addr	object_type_04_state_00
	.addr	object_type_04_state_01
	.addr	object_type_04_state_02
	.addr	object_type_04_state_03
	.addr	object_type_04_state_04
	.addr	object_type_04_state_05

object_type_04_state_00:
	lda	#$0041
	sta	OBJ_FLAGS,x
	lda	#$0060
	sta	OBJ_HITBOX_W,x
	lda	#$FF10	; [num]
	sta	OBJ_HITBOX_H,x
	inc	OBJ_STATE,x
loc_01C4FA:
	rtl

object_type_04_state_01:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	loc_01C4FA
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
	lda	#$0014
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
	lda	#$0015
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

object_type_04_state_02:
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

object_type_04_state_03:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	#.loword(vram_blocks_05B0A0)
	sta	$30,x
	lda	#$0044
	jsl	f:queue_sound
	inc	$12,x
	ldy	#$0300
@loop:
	lda	a:$0010,y
	cmp	#$0017
	beq	loc_01C622
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0740
	bcc	@loop
	rtl
loc_01C622:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	a:$0006,y
	rtl

object_type_04_state_04:
	jsl	f:solid_object_vs_players_and_soldiers
	lda	stage_frame_counter
	and	#$000F
	bne	@return
	inc	$12,x
@return:
	rtl

object_type_04_state_05:
	lda	#$0004
	sta	a:shake_timer
	jsl	f:solid_object_vs_players_and_soldiers
	lda	stage_frame_odd
	bne	loc_01C66B
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
	bcs	loc_01C66B
	lda	#$FFFD	; [num]
	sta	a:$001E,y
loc_01C66B:
	stx	zp_FA
	lda	#$0030
	sta	zp_08
	lda	stage_frame_counter
	and	#$000F
	cmp	#$0004
	bcs	object_type_04_collapse_wait
	phx
	asl	a
	tax
	lda	f:tbl_object_type_04_collapse_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_04_collapse_steps:
	.addr	object_type_04_collapse_wait
	.addr	object_type_04_collapse_step_1
	.addr	object_type_04_collapse_step_2
	.addr	object_type_04_collapse_step_3

object_type_04_collapse_step_1:
	stz	zp_00
	stz	zp_0C
	bra	loc_01C6B2

object_type_04_collapse_step_2:
	lda	#$0100
	sta	zp_0C
	lda	#$000C
	sta	zp_00
	bra	loc_01C6B2

object_type_04_collapse_step_3:
	lda	#$0200
	sta	zp_0C
	lda	#$0018
	sta	zp_00
	lda	#$0018
	sta	zp_08
loc_01C6B2:
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
	bne	object_type_04_collapse_wait
	clc
	lda	$30,x
	adc	#$001E
	sta	$30,x
	cmp	#.loword(vram_blocks_05B0A0 + $D2)
	bcc	object_type_04_collapse_wait
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0001
	sta	a:bg1_scroll_mode

object_type_04_collapse_wait:
	rtl

; Object type $14: stage 1 section 4: part of the wall structure, HP 64
; (flashes its palette when hit). Not identified exactly.
update_object_type_14:
	lda	OBJ_SAVED_ATTR,x
	beq	@return
	lda	#.loword(palette_05914A)
	sta	cgram_upload_src
	lda	#$0050
	sta	cgram_upload_addr
@return:
	rtl

; Object type $15: stage 1 section 4: destructible wall gun, HP 40;
; destroyed: a burst of explosions. Not identified exactly.
update_object_type_15:
	lda	OBJ_STATE,x
	beq	loc_01C731
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
loc_01C731:
	lda	$06,x
	bpl	loc_01C747
	lda	#$0030
	jsl	f:queue_sound
	inc	$12,x
	lda	#$0008
	sta	$24,x
	lda	$36,x
	bra	loc_01C7AD
loc_01C747:
	inc	$24,x
	lda	$24,x
	cmp	#$0028
	bne	loc_01C756
	stz	$24,x
	lda	$32,x
	bra	loc_01C7AD
loc_01C756:
	cmp	#$0020
	bcc	loc_01C7B5
	bne	loc_01C7B5
	phx
	ldx	#$03C0
	jsl	f:find_free_slot_from_x
	ply
	bcs	loc_01C7B5
	lda	#$0016
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
loc_01C7AD:
	sta	zp_00
	lda	$30,x
	jsl	f:queue_vram_block
loc_01C7B5:
	rtl

; Object type $16: falls with gravity and explodes on the floor or on
; contact (stage 1 section 4).
update_object_type_16:
	lda	OBJ_TOUCHED_BY,x
	bne	loc_01C7CF
	lda	OBJ_Y_VEL_SUB,x
	adc	#$2000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	loc_01C7E0
loc_01C7CF:
	lda	#$FFFF	; [num]
	sta	$1E,x
	stz	$18,x
	stz	$1A,x
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_01C7E0:
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
	beq	loc_01C813
	jsr	a:weapon_capsule_set_kind
	rtl
loc_01C813:
	lda	#$0012
	sta	$16,x
	lda	#.loword(anim_05B172)
	sta	$20,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	lda	$0E,x
	sta	$34,x
	lda	$0A,x
	bpl	loc_01C835
	lda	#$FFF0	; [num]
	sta	$0A,x
	lda	#$0002
	sta	$1A,x
	rtl
loc_01C835:
	lda	#$0100
	sta	$0A,x
	lda	#$FFFD	; [num]
	sta	$1A,x
	rtl

weapon_capsule_state_01:
	jsr	a:weapon_capsule_check_shot
	lda	$34,x
	cmp	$0E,x
	bcc	loc_01C85A
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bra	loc_01C869
loc_01C85A:
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
loc_01C869:
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
	beq	loc_01C8AB
	lda	#$0012
	jsl	f:queue_sound
	lda	#$8000	; [num]
	sta	$16,x
	lda	a:$1D82,y
	bne	loc_01C89F
	lda	$3A,x
	sta	a:$1D84,y
	lda	#$0000
	sta	a:$0036,y
	rtl
loc_01C89F:
	lda	$3A,x
	sta	a:$1D86,y
	lda	#$0000
	sta	a:$0034,y
	rtl
loc_01C8AB:
	brl	loc_01C8F5

weapon_capsule_state_03:
	ldy	OBJ_TOUCHED_BY,x
	beq	loc_01C8C4
	lda	#$0012
	jsl	f:queue_sound
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0200
	sta	a:$1D88,y
loc_01C8C4:
	brl	loc_01C8F5

weapon_capsule_state_04:
	ldy	#$3E00
	lda	stage_frame_odd
	bne	loc_01C8D1
	ldy	#$3200
loc_01C8D1:
	sty	$02,x
	ldy	$3C,x
	beq	loc_01C8F2
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0012
	jsl	f:queue_sound
	lda	a:$1D8C,y
	inc	a
	cmp	#$0009
	bcc	loc_01C8EF
	; (not executed in the CDL traces)
	lda	#$0009
loc_01C8EF:
	sta	a:$1D8C,y
loc_01C8F2:
	brl	loc_01C8F5
loc_01C8F5:
	lda	$3E,x
	beq	loc_01C910
	lda	$0E,x
	cmp	#$00C0
	bcs	loc_01C903
	brl	loc_01C98D
loc_01C903:
	lda	#$FFFE	; [num]
	sta	$1E,x
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
loc_01C910:
	dec	$36,x
	bne	loc_01C91A
	lda	#$8000	; [num]
	sta	$16,x
	rtl
loc_01C91A:
	lda	$36,x
	cmp	#$0030
	bcs	loc_01C92D
	lda	stage_frame_odd
	beq	loc_01C929
	stz	$00,x
	bra	loc_01C92D
loc_01C929:
	lda	$38,x
	sta	$00,x
loc_01C92D:
	lda	stage_number
	cmp	#$0004
	bne	loc_01C937
	brl	loc_01C9D8
loc_01C937:
	stz	zp_00
	lda	$1E,x
	bmi	loc_01C963
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	and	#$807E
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$807E
	beq	loc_01C95D
	lda	zp_04
	beq	loc_01C961
	brl	loc_0193D7
loc_01C95D:
	lda	zp_04
	beq	loc_01C961
loc_01C961:
	bra	loc_01C98D
loc_01C963:
	lda	#$FFF0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	and	#$0182
	sta	zp_04
	lda	#$0010
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	bit	#$0182
	beq	loc_01C989
	lda	zp_04
	beq	loc_01C987
	jsl	f:snap_y_down_to_tile
loc_01C987:
	bra	loc_01C98D
loc_01C989:
	lda	zp_04
	beq	loc_01C98D
loc_01C98D:
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
	bpl	loc_01C9D7
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
	bne	loc_01C9C6
	lda	#$3000
	sta	$02,x
loc_01C9C6:
	lda	#$0200
	sta	$36,x
	stz	$1C,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	lda	#$000B
	sta	$16,x
loc_01C9D7:
	rts
loc_01C9D8:
	lda	$0E,x
	cmp	#$00B4
	bcs	loc_01C9E2
	brl	loc_01C98D
loc_01C9E2:
	lda	a:respawn_mode
	cmp	#$0005
	bcs	loc_01C9ED
	; (not executed in the CDL traces)
	brl	loc_01C98D
loc_01C9ED:
	stz	$1C,x
	stz	$1E,x
	sec
	lda	$0A,x
	sbc	#$0008
	sta	$0A,x
	rtl

; Object type $11: stage 1, HP 16. Not identified.
update_object_type_11:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_11_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_11_states:
	.addr	object_type_11_state_00
	.addr	object_type_11_state_01
	.addr	object_type_11_state_02

object_type_11_state_00:
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
loc_01CA3F:
	jml	f:solid_object_vs_players_and_soldiers

object_type_11_state_01:
	lda	OBJ_HP,x
	bpl	loc_01CA3F
	lda	#$0042
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
loc_01CA81:
	lda	$10,x
	beq	loc_01CA92
loc_01CA85:
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0780
	bcc	loc_01CA81
	; (not executed in the CDL traces)
	plx
	rtl
loc_01CA92:
	lda	a:object_type_11_debris_sprites,y
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
	lda	a:object_type_11_debris_y_vels,y
	sta	$1E,x
	sta	$30,x
	lda	a:object_type_11_debris_x_vels,y
	sta	$1A,x
	dey
	dey
	bne	loc_01CA85
	plx
	rtl

object_type_11_state_02:
	lda	stage_frame_odd
	bne	loc_01CAF1
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
loc_01CAF1:
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
	bmi	loc_01CB43
	bra	update_bouncing_debris
loc_01CB43:
	lda	a:$001A,y
	dec	a
	sta	a:$001A,y

; Object type $10: debris that falls, bounces off the floor
; (get_bg_tile_at_object) and blinks out (stage 1, the wrecked car).
update_bouncing_debris:
	dec	OBJ_TIMER,x
	bne	loc_01CB54
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_01CB54:
	lda	$24,x
	cmp	#$0010
	bcs	loc_01CB67
	lda	stage_frame_odd
	bne	loc_01CB63
	stz	$00,x
	bra	loc_01CB67
loc_01CB63:
	lda	$32,x
	sta	$00,x
loc_01CB67:
	lda	$1E,x
	bmi	loc_01CB82
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	loc_01CB82
	jsl	f:snap_y_up_to_tile
	lda	$30,x
	beq	loc_01CB92
	inc	a
	sta	$30,x
	sta	$1E,x
loc_01CB82:
	clc
	lda	$1C,x
	adc	#$2800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
loc_01CB92:
	; (not executed in the CDL traces)
	stz	$1C,x
	rtl

; Object type $43: stage 3 section 9, HP 64. Not identified.
update_object_type_43:
	lda	OBJ_STATE,x
	bne	loc_01CBB0
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
loc_01CBB0:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	loc_01CBBD
	lda	#$4051
	sta	$16,x
loc_01CBBD:
	jsl	f:solid_object_vs_players
	lda	$06,x
	bpl	loc_01CC13
	lda	#$0041
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
loc_01CC13:
	lda	$26,x
	beq	@return
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0030
	sta	cgram_upload_addr
@return:
	rtl

; Object type $12: stage 1 soldier variant, HP 6 (seen in the emulator). Not
; identified exactly.
update_object_type_12:
	jsr	a:object_type_12_aim_at_nearest_player
	lda	$06,x
	bpl	loc_01CC34
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
loc_01CC34:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_12_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_12_states:
	.addr	object_type_12_state_00
	.addr	object_type_12_state_01
	.addr	object_type_12_state_02
	.addr	object_type_12_state_03
	.addr	object_type_12_state_02
	.addr	object_type_12_state_05
	.addr	object_type_12_state_02
	.addr	object_type_12_state_01

object_type_12_state_00:
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
	lda	a:object_type_12_hp,y
	sta	OBJ_HP,x
	inc	OBJ_STATE,x

object_type_12_state_01:
	ldy	OBJ_FACING,x
	lda	a:object_type_12_idle_sprites,y
	sta	OBJ_SPRITE,x
	ldy	difficulty
	lda	a:object_type_12_wait_times,y
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	OBJ_STATE,x
	rtl

object_type_12_state_02:
	dec	OBJ_TIMER,x
	bne	@return
	inc	OBJ_STATE,x
@return:
	rtl

object_type_12_state_03:
	ldy	OBJ_FACING,x
	lda	a:object_type_12_windup_sprites,y
	sta	OBJ_SPRITE,x
	lda	#$000C
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	OBJ_STATE,x
	lda	#$0016
	jml	f:queue_sound

object_type_12_state_05:
	jsl	f:find_free_slot_y
	bcs	loc_01CD06
	lda	#OBJT_GRENADE
	sta	a:$0010,y
	lda	$0A,x
	clc
	phy
	ldy	$04,x
	adc	a:object_type_12_grenade_x_offsets,y
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
	lda	a:object_type_12_grenade_x_vels,y
	sta	$1A,x
	lda	a:object_type_12_grenade_x_vel_subs,y
	sta	$18,x
	lda	#$FFFA	; [num]
	sta	$1E,x
	stz	$1C,x
	plx
	ldy	$04,x
	lda	a:object_type_12_throw_sprites,y
	sta	$00,x
	lda	#$0010
	sta	$24,x
	lda	#$0006
	sta	$12,x
	rtl
loc_01CD06:
	; (not executed in the CDL traces)
	ldy	$04,x
	lda	a:object_type_12_idle_sprites,y
	sta	$00,x
	lda	#$000C
	sta	$24,x
	lda	#$0002
	sta	$12,x
	rtl

object_type_12_aim_at_nearest_player:
	lda	a:p1_lives
	ora	a:p2_lives
	beq	loc_01CD76
	lda	a:p1_lives
	beq	loc_01CD38
	ldy	#$0200
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_18
	bpl	loc_01CD36
	eor	#$FFFF
	inc	a
loc_01CD36:
	sta	zp_1C
loc_01CD38:
	lda	a:p2_lives
	beq	loc_01CD57
	ldy	#$0240
	sec
	lda	a:$000A,y
	sbc	$0A,x
	sta	zp_1A
	bpl	loc_01CD4E
	eor	#$FFFF
	inc	a
loc_01CD4E:
	sta	zp_1E
	ldy	#$0002
	cmp	zp_1C
	bcc	loc_01CD5E
loc_01CD57:
	lda	zp_1C
	sta	zp_1E
	ldy	#$0000
loc_01CD5E:
	lda	$12,x
	cmp	#$0003
	bcc	loc_01CD6A
	cmp	#$0007
	bcc	loc_01CD76
loc_01CD6A:
	stz	$04,x
	lda	a:$0018,y
	bpl	loc_01CD76
	lda	#$0002
	sta	$04,x
loc_01CD76:
	rts

; Object type $13: grenade/shell thrown by soldiers: explodes into type $1A
; when it touches a player or a solid BG tile (bit $2000).
update_grenade:
	lda	OBJ_STATE,x
	bne	loc_01CD99
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
loc_01CD99:
	lda	$3C,x
	bne	loc_01CDAA
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$2000
	beq	loc_01CDCA
; Bug: x + 8 and y - $10 are computed but never stored (the second lda of
; each pair was probably meant as sta), so the blast starts at the grenade.
loc_01CDAA:
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
	lda	#$0030
	jsl	f:queue_sound
	jml	f:start_grenade_blast
loc_01CDCA:
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
	bcs	loc_01CDF3
	jsr	a:window_sniper_aim_at_nearest_player
	jsl	f:window_sniper_set_aim_sprite
loc_01CDF3:
	lda	$06,x
	bpl	loc_01CE02
	stz	$06,x
	lda	#OBJT_DYING_SOLDIER
	sta	$10,x
	jml	f:start_dying_soldier
loc_01CE02:
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
	beq	loc_01CEB5
	sec
	lda	a:player1_obj+OBJ_X
	sbc	$0A,x
	sta	zp_18
	bpl	loc_01CEB3
	eor	#$FFFF
	inc	a
loc_01CEB3:
	sta	zp_1C
loc_01CEB5:
	lda	a:player2_obj+OBJ_FLAGS
	beq	loc_01CECA
	sec
	lda	a:player2_obj+OBJ_X
	sbc	$0A,x
	sta	zp_1A
	bpl	loc_01CEC8
	eor	#$FFFF
	inc	a
loc_01CEC8:
	sta	zp_1E
loc_01CECA:
	ldy	#$0000
	lda	zp_1E
	cmp	zp_1C
	bne	loc_01CED8
	cmp	#$FFFF	; [num]
	beq	loc_01CF14
loc_01CED8:
	bcs	loc_01CEDD
	ldy	#$0002
loc_01CEDD:
	lda	a:window_sniper_player_slots,y
	sta	$30,x
	stz	$04,x
	lda	a:$0018,y
	bpl	loc_01CEEE
	lda	#$0002
	sta	$04,x
loc_01CEEE:
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
loc_01CF14:
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
	beq	loc_01CF38
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	pla
	rtl
loc_01CF38:
	clc
	pla
	bra	make_effect_object

spawn_effect_random_offset:
	pha
@loop:
	lda	a:$0010,y
	beq	loc_01CF4F
	tya
	clc
	adc	#$0040
	tay
	cmp	#$08C0
	bcc	@loop
	pla
	rtl
loc_01CF4F:
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
