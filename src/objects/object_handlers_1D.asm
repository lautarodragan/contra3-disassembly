; objects/object_handlers_1D.asm -- Object handlers (bank $1D)
; Bank $1D, $1D:AF27-$1D:CCDF. Included by main.asm in segment BANK1D.
;
; Handlers of object types dispatched through tbl_object_types and their
; helpers: the final boss of stage 6 (brain_boss and its attacks) and the
; ending (ending_sequence, ending_explosion).

; Object type $95. Ending after brain_boss: the helicopter arrives, the
; players hang on the missile (rideable_missile in slot $0280), the lair
; explodes; on HARD a last creature chases the helicopter (384 HP set in state
; 8). Then spawns the crowd (spawn_ending_crowd) and the fireworks
; (spawn_ending_firework).
update_ending_sequence:
	lda	OBJ_STATE,x
	cmp	#$0009
	bcs	loc_1DAF38
	lda	#.loword(palette_05918A)
	sta	cgram_upload_src
	lda	#$0030
	sta	cgram_upload_addr
loc_1DAF38:
	lda	OBJ_SAVED_ATTR,x
	beq	loc_1DAF46
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$B030	; [num]
	sta	cgram_upload_addr
loc_1DAF46:
	lda	OBJ_HP,x
	bpl	loc_1DAF72
	stz	OBJ_HP,x
	lda	#$0001
	sta	OBJ_FLAGS,x
	lda	#$0002
	sta	a:clear_enemies_timer
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$000F
	sta	OBJ_STATE,x
	lda	#$8000	; [num]
	sta	a:obj_slots+29*OBJ_SIZE+OBJ_FLAGS
	lda	#$076F
	sta	f:effect_hdma_buf
	lda	#$0200
	sta	OBJ_TIMER,x
loc_1DAF72:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_ending_sequence_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_ending_sequence_states:
	.addr	ending_sequence_state_00
	.addr	ending_sequence_state_01
	.addr	ending_sequence_state_02
	.addr	ending_sequence_state_03
	.addr	ending_sequence_state_04
	.addr	ending_sequence_state_05
	.addr	ending_sequence_state_06
	.addr	ending_sequence_state_07
	.addr	ending_sequence_state_08
	.addr	ending_sequence_state_09
	.addr	ending_sequence_state_0A
	.addr	ending_sequence_state_0B
	.addr	ending_sequence_state_0C
	.addr	ending_sequence_state_0D
	.addr	ending_sequence_state_0E
	.addr	ending_sequence_state_0F
	.addr	ending_sequence_state_10
	.addr	ending_sequence_state_11
	.addr	ending_sequence_state_12
	.addr	ending_sequence_state_12
	.addr	ending_sequence_state_14
	.addr	ending_sequence_state_15
	.addr	ending_sequence_state_16
	.addr	ending_sequence_state_17
	.addr	ending_sequence_state_18
	.addr	ending_sequence_state_19
	.addr	ending_sequence_state_1A
	.addr	ending_sequence_state_1B
	.addr	ending_sequence_state_1C
	.addr	ending_sequence_state_1A
	.addr	ending_sequence_state_1E
	.addr	ending_sequence_state_1F
	.addr	ending_sequence_state_20
	.addr	ending_sequence_state_21
	.addr	ending_sequence_state_22
	.addr	ending_sequence_state_23
	.addr	ending_sequence_state_24
	.addr	ending_sequence_state_25
	.addr	ending_sequence_state_26
	.addr	ending_sequence_state_27
	.addr	ending_sequence_state_28
	.addr	ending_sequence_state_29
	.addr	ending_sequence_state_2A

ending_sequence_state_00:
	inc	OBJ_STATE,x
	lda	#$0002
	sta	a:spawn_disabled
	lda	#$8000	; [num]
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_FLAGS
	lda	#$0002
	sta	a:bg2_scroll_mode
	lda	#$0480
	sta	a:bg2_map_offset
	stz	a:bg2_screen_drawn
	lda	#$01F8
	sta	a:bg2_draw_x
	stz	a:bg2_x+BG_COLUMN_OFFSET
	rtl

ending_sequence_state_01:
	lda	a:bg2_screen_drawn
	beq	@return
	inc	OBJ_STATE,x
	stz	a:bg2_scroll_mode
	lda	#OBJT_RIDEABLE_MISSILE
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_TYPE
	lda	#$0001
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_FLAGS
	lda	#$0078
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_HITBOX_W
	lda	#$FFF8	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_HITBOX_H
	lda	#$0001
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_STATE
	lda	#$FFF0	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	lda	#$0042
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_X
	lda	#$8000	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	#$076F
	sta	f:effect_hdma_buf
	lda	#$7FE8
	sta	f:effect_hdma_buf+$02
	lda	#$E809	; [num]
	sta	f:effect_hdma_buf+$04
	lda	#$7F00
	sta	f:effect_hdma_buf+$06
	sta	f:effect_hdma_buf+$08
	lda	#$0000
	sta	f:effect_hdma_buf+$0A
	lda	#$0011
	sta	hdma_preset
	lda	#$0007
	sta	a:respawn_mode
@return:
	rtl

ending_sequence_state_02:
	jsr	a:ending_set_missile_hdma
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	@return
	cmp	#$006C
	bcc	@return
	inc	OBJ_STATE,x
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	#$0001
	sta	a:player_autopilot_mode
	stz	a:clamp_player_top
@return:
	rtl

ending_sequence_state_03:
	jsr	a:ending_set_missile_hdma
	lda	a:p1_lives
	beq	loc_1DB097
	lda	a:player1_state
	cmp	#$0001
	bne	loc_1DB0AB
loc_1DB097:
	lda	a:p2_lives
	beq	loc_1DB0A4
	; (not executed in the CDL traces)
	lda	a:player2_state
	cmp	#$0001
	bne	loc_1DB0AB
loc_1DB0A4:
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x
loc_1DB0AB:
	rtl

ending_sequence_state_04:
	jsr	a:ending_set_missile_hdma
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$FFFF	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	lda	#$8000	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	inc	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_05:
	jsr	a:ending_set_missile_hdma
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bpl	@return
	cmp	#$FFDD	; [num]
	bcs	@return
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	lda	#$0080
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_06:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0080
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_07:
	dec	OBJ_TIMER,x
	bpl	loc_1DB102
	lda	difficulty
	cmp	#$0004
	beq	loc_1DB0FF
	lda	#$0100
	sta	OBJ_TIMER,x
	lda	#$0025
	sta	OBJ_STATE,x
	rtl
loc_1DB0FF:
	inc	OBJ_STATE,x
	rtl
loc_1DB102:
	ldy	#.loword(vram_blocks_05FF59)
	lda	OBJ_TIMER,x
	bit	#$0008
	bne	loc_1DB10F
	ldy	#.loword(vram_blocks_05FF5D)
loc_1DB10F:
	jsr	a:queue_brain_boss_tiles
	rtl

ending_sequence_state_08:
	lda	#$004A
	jsl	f:queue_sound
	stz	a:boss_work_0
	lda	#$0010
	sta	a:boss_work_1
	inc	OBJ_STATE,x
	jsr	a:ending_creature_spawn_claws
	stz	$30,x
	lda	#$401D
	sta	OBJ_FLAGS,x
	lda	#$002C
	sta	OBJ_HITBOX_W,x
	lda	#$FFB0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$006A
	sta	OBJ_X,x
	lda	#$00C0
	sta	OBJ_Y,x
	lda	#ENEMY_HP($0180)
	sta	OBJ_HP,x
	stz	$34,x
	stz	$36,x
	lda	#$0001
	sta	$3A,x
	phx
	ldx	#$0940
	lda	#$0053
	sta	$10,x
	lda	#$003C
	sta	$16,x
	lda	#$007C
	sta	$28,x
	lda	#$FFD8	; [num]
	sta	$2A,x
	lda	#$0042
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	plx
	rtl

ending_sequence_state_09:
	stz	zp_00
	lda	#$00FF
	sta	zp_04
	jsr	a:ending_shake_and_explode
	jsr	a:ending_queue_tile_changes
	lda	a:boss_work_0
	cmp	#$0012
	bcc	@return
	lda	#$0049
	jsl	f:queue_sound
	inc	OBJ_STATE,x
	jsr	a:ending_start_vertical_autoscroll
	lda	#$0002
	sta	a:spawn_disabled
@return:
	rtl

ending_sequence_state_0A:
	lda	a:bg1_y
	bit	#$00FF
	beq	loc_1DB1D0
	bit	#$0080
	bne	loc_1DB1D0
	inc	OBJ_STATE,x
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0004
	sta	a:bg1_scroll_mode
	lda	#$0100
	sta	OBJ_TIMER,x

ending_sequence_state_0B:
	jsr	a:ending_scroll_bg1_up_faster
	dec	OBJ_TIMER,x
	bpl	loc_1DB1D0
	inc	OBJ_STATE,x
	lda	#$8000	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
loc_1DB1D0:
	lda	stage_frame_odd
	bne	loc_1DB1F2
	lda	a:ending_arm_lengths
	cmp	#$000A
	bcs	loc_1DB1E3
	inc	a
	sta	a:ending_arm_lengths
	sta	a:ending_arm_lengths+2
loc_1DB1E3:
	lda	a:ending_arm_lengths+4
	cmp	#$000C
	bcs	loc_1DB1F2
	inc	a
	sta	a:ending_arm_lengths+4
	sta	a:ending_arm_lengths+6
loc_1DB1F2:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:ending_creature_place_arm_bases
	jsr	a:ending_creature_update_angles
	jsr	a:ending_creature_set_arm_angles
	jsr	a:ending_creature_feed_arms
	rtl

ending_sequence_state_0C:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	loc_1DB237
	cmp	#$0040
	bcc	loc_1DB237
	stz	a:player_autopilot_mode
	ldy	#$0200
	jsr	a:ending_protect_player
	ldy	#$0240
	jsr	a:ending_protect_player
	inc	OBJ_STATE,x

ending_sequence_state_0D:
	lda	stage_frame_counter
	bit	#$01FF
	bne	loc_1DB22E
	inc	OBJ_STATE,x
	lda	#$0400
	sta	$36,x
loc_1DB22E:
	jsr	a:ending_creature_extend_arms
	jsr	a:ending_missile_bob_default
	jsr	a:ending_creature_rise_and_sink
loc_1DB237:
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_creature_place_arm_bases
	jsr	a:ending_creature_update_angles
	jsr	a:ending_creature_set_arm_angles
	jsr	a:ending_creature_feed_arms
	jsr	a:ending_set_missile_hdma
	rtl

ending_sequence_state_0E:
	jsr	a:ending_missile_bob_default
	jsr	a:ending_creature_rise_and_sink
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_creature_place_arm_bases
	jsr	a:ending_creature_update_angles
	jsr	a:ending_creature_aim_arms
	jsr	a:ending_creature_feed_arms
	jsr	a:ending_set_missile_hdma
	dec	$36,x
	bpl	@return
	dec	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_14:
	lda	a:bg1_y
	and	#$01FF
	cmp	#$0004
	bcs	loc_1DB2BB
	clc
	adc	#$0200
	sta	a:bg1_y
	clc
	adc	#$0100
	and	#$FF00
	sta	a:bg1_x+BG_PAGE
	inc	OBJ_STATE,x
	lda	#$0006
	sta	a:bg1_scroll_mode
	lda	#$0012
	sta	hdma_preset
	lda	#$0004
	sta	a:ts_shadow
	lda	#$0001
	sta	a:player_autopilot_mode
	lda	#$0001
	sta	a:life_transfer_disabled
	lda	#$6000
	sta	a:boss_work_0
	lda	#$FFFF	; [num]
	sta	a:boss_work_1
	jsl	f:ending_sequence_state_15
	lda	a:bg2_y
	sta	a:bg2_x+BG_VOFS_LATCH
	rtl
loc_1DB2BB:
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_missile_bob_default
	jsr	a:ending_set_missile_hdma
	rtl

ending_sequence_state_10:
	jsr	a:ending_creature_place_arm_bases
	dec	OBJ_TIMER,x
	bpl	loc_1DB2F1
	inc	OBJ_STATE,x
	phx
	ldx	#.loword(load_list_05F8C3)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05F8DA)
	jsl	f:start_palette_task
	plx
	stz	OBJ_X,x
	lda	#$0180
	sta	OBJ_Y,x
	lda	#$0200
	sta	OBJ_TIMER,x
	lda	#$0100
	sta	f:effect_hdma_buf+$09
loc_1DB2F1:
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_missile_bob_default
	jsr	a:ending_set_missile_hdma
	lda	a:boss_work_0
	cmp	#$0014
	bcs	@return
	jsr	a:ending_queue_tile_changes
@return:
	rtl

ending_sequence_state_15:
	jsr	a:ending_set_scroll_split
	jsr	a:ending_scroll_bg1_up_slower
	lda	#$0064
	sta	zp_00
	lda	#$0080
	sta	zp_02
	jsr	a:ending_missile_bob
	jsr	a:ending_bg2_follow_missile
	lda	a:bg1_y
	bpl	@return
	stz	a:bg1_y
	lda	#$0004
	sta	a:bg1_scroll_mode
	lda	#$00C0
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	stz	a:boss_work_2
	stz	a:boss_work_3
@return:
	rtl

ending_sequence_state_20:
	jsr	a:ending_parallax_speed_increase
	lda	a:boss_work_4
	bmi	loc_1DB360
	cmp	#$0046
	bcc	loc_1DB360
	stz	a:boss_work_2
	stz	a:boss_work_3
	inc	OBJ_STATE,x
	lda	#$0006
	sta	a:bg1_scroll_mode
	lda	#$0900
	sta	a:bg1_map_offset
	sta	a:bg1_x+BG_PAGE
	jsl	f:spawn_ending_crowd
loc_1DB360:
	jsr	a:ending_set_scroll_split
	jsr	a:ending_run_text_script
	lda	#$0074
	sta	zp_00
	lda	#$0080
	sta	zp_02
	jsr	a:ending_missile_bob
	jsr	a:ending_bg2_follow_missile
	rtl

ending_sequence_state_21:
	jsr	a:ending_parallax_speed_decrease
	jsr	a:ending_scroll_bg1_down
	jsr	a:ending_run_text_script
	lda	#$0088
	sta	zp_00
	lda	#$0090
	sta	zp_02
	jsr	a:ending_missile_bob
	jsr	a:ending_bg2_follow_missile
	jsr	a:ending_set_scroll_split
	lda	#$0100
	cmp	a:bg1_y
	bcs	@return
	sta	a:bg1_y
	inc	OBJ_STATE,x
	lda	a:bg1_x
	and	#$0100
	asl	a
	asl	a
	asl	a
	clc
	adc	#$4640
	tay
	lda	#$2002
	sta	zp_02
	lda	#$0002
	sta	zp_04
	lda	#$0020
	jsl	f:update_object_type_28
	lda	#$0060
	sta	OBJ_TIMER,x
	lda	#$0002
	sta	a:player_autopilot_mode
@return:
	rtl

ending_sequence_state_22:
	dec	OBJ_TIMER,x
	bpl	ending_sequence_state_24
	inc	OBJ_STATE,x
	lda	a:p1_lives
	beq	loc_1DB3E2
	lda	#PLAYER_STATE_ENDING
	sta	a:player1_state
	lda	#$0040
	sta	a:player1_obj+$34
loc_1DB3E2:
	lda	a:p2_lives
	beq	loc_1DB3F3
	; (not executed in the CDL traces)
	lda	#PLAYER_STATE_ENDING
	sta	a:player2_state
	lda	#$0040
	sta	a:player2_obj+$34
loc_1DB3F3:
	stz	a:player_autopilot_mode
	lda	#$01F0
	sta	OBJ_TIMER,x
	bra	ending_sequence_state_24

ending_sequence_state_23:
	dec	OBJ_TIMER,x
	bpl	ending_sequence_state_24
	lda	#$0100
	sta	a:stage_exit_request
	inc	OBJ_STATE,x

ending_sequence_state_24:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bpl	loc_1DB412
	jsl	f:spawn_ending_firework
loc_1DB412:
	jsr	a:ending_parallax_speed_decrease
	jsr	a:ending_missile_fly_up
	jsr	a:ending_bg2_follow_missile
	jsr	a:ending_set_scroll_split
	rtl

ending_set_missile_hdma:
	sec
	lda	#$0077
	sbc	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	sta	f:effect_hdma_buf+$07
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	loc_1DB434
	cmp	#$0008
	bcs	loc_1DB437
loc_1DB434:
	lda	#$0008
loc_1DB437:
	ora	#$0700
	sta	f:effect_hdma_buf
loc_1DB43E:
	rts

ending_bg2_follow_missile:
	sec
	lda	#$0078
	sbc	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	sta	a:bg2_y
	rts

; From the ending object's y: the HDMA value effect_hdma_buf+$09 ($141 - y), slot 29's
; y and the bases of the creature's arms (wram_169A-wram_16A0, read by
; ending_creature_feed_arm).
ending_creature_place_arm_bases:
	sec
	lda	#$0141
	sbc	OBJ_Y,x
	sta	f:effect_hdma_buf+$09
	clc
	lda	OBJ_Y,x
	adc	#$FFF0
	sta	a:obj_slots+29*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0010
	sta	a:wram_169E
	sta	a:wram_16A0
	clc
	adc	#$FFE0
	sta	a:wram_169A
	sta	a:wram_169C
	rts

ending_queue_tile_changes:
	ldy	a:boss_work_0
	bmi	loc_1DB43E
	cpy	#$0014
	bcs	loc_1DB43E
	dec	a:boss_work_1
	bpl	loc_1DB43E
	lda	stage_frame_odd
	beq	loc_1DB43E
	phx
	lda	#$0001
	sta	zp_02
	lda	#$0018
	sta	zp_08
	clc
	lda	a:ending_tile_change_columns,y
	and	#$000F
	adc	#$4B80
	sta	zp_FC
	eor	#$001C
	sta	zp_FA
	clc
	lda	a:ending_tile_change_block_offsets,y
	and	#$00FF
	adc	#.loword(vram_blocks_05F914)
	tay
	clc
	adc	#$0006
	sta	zp_FE
	lda	zp_FC
	jsl	f:queue_vram_blocks
	lda	#$0001
	sta	zp_02
	lda	#$0030
	sta	zp_08
	ldy	zp_FE
	lda	zp_FA
	ldx	#$0018
	jsl	f:queue_vram_blocks_at_x
	plx
	ldy	a:boss_work_0
	lda	a:ending_tile_change_columns,y
	and	#$00FF
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sta	a:boss_work_1
	inc	a:boss_work_0
	rts

ending_creature_update_angles:
	jsr	a:ending_creature_swing
	clc
	lda	$32,x
	sta	a:boss_work_7
	adc	#$0064
	and	#$00FF
	sta	a:boss_work_6
	rts

ending_creature_set_arm_angles:
	eor	#$007F
	and	#$00FF
	sta	a:boss_work_4
	sec
	sbc	#$0094
	and	#$00FF
	sta	a:boss_work_5
	rts

; Ending on HARD: the creature chasing the helicopter. Turns its two arms
; (slots $0300, $0440; angles in boss_work_4/5, lengths at $16A2) towards a
; player at intervals (sound $5C).
ending_creature_aim_arms:
	phx
	ldx	#$0300
	ldy	#$0000
	jsr	a:ending_creature_aim_arm
	ldx	#$0440
	ldy	#$0002
	jsr	a:ending_creature_aim_arm
	plx
	rts

ending_creature_aim_arm:
	lda	a:obj_slots+28*OBJ_SIZE+$36
	cmp	#$03C0
	bcs	loc_1DB55B
	cmp	#$0040
	bcc	loc_1DB55B
	and	#$0040
	eor	a:ending_creature_arm_sides,y
	beq	loc_1DB55B
	lda	a:obj_slots+28*OBJ_SIZE+$36
	and	#$003F
	cmp	#$003F
	bne	loc_1DB556
	phy
	lda	#$0020
	jsl	f:pick_target_player
	jsl	f:angle_to_player
	ply
	sta	a:obj_slots+28*OBJ_SIZE+$38
	lda	#$005C
	jsl	f:queue_sound
	rts
loc_1DB556:
	cmp	#$0020
	bcs	loc_1DB575
loc_1DB55B:
	lda	a:ending_arm_lengths,y
	cmp	#$0001
	bcc	@return
	dec	a
	sta	a:ending_arm_lengths,y
	clc
	lda	a:$163E,y
	adc	a:ending_creature_arm_retract_turns,y
	and	#$00FF
	sta	a:$163E,y
@return:
	rts
loc_1DB575:
	sec
	lda	a:obj_slots+28*OBJ_SIZE+$38
	sbc	a:$163E,y
	bpl	loc_1DB582
	eor	#$FFFF
	inc	a
loc_1DB582:
	cmp	#$0004
	bcc	loc_1DB594
	clc
	lda	a:$163E,y
	adc	a:ending_creature_arm_aim_turns,y
	and	#$00FF
	sta	a:$163E,y
loc_1DB594:
	lda	a:ending_arm_lengths,y
	cmp	#$0020
	bcs	@return
	inc	a
	inc	a
	sta	a:ending_arm_lengths,y
@return:
	rts

ending_creature_extend_arms:
	lda	stage_frame_odd
	bne	@return
	lda	a:ending_arm_lengths
	cmp	#$000A
	bcs	@return
	inc	a
	sta	a:ending_arm_lengths
	sta	a:ending_arm_lengths+2
@return:
	rts

ending_creature_swing:
	lda	$32,x
	ldy	$30,x
	bne	loc_1DB5CD
	ldy	$34,x
	sec
	sbc	a:ending_creature_swing_speeds,y
	and	#$00FF
	sta	$32,x
	cmp	#$0018
	bcc	loc_1DB5DE
	rts
loc_1DB5CD:
	ldy	$34,x
	clc
	adc	a:ending_creature_swing_speeds,y
	and	#$00FF
	sta	$32,x
	cmp	#$007C
	bcs	loc_1DB5E5
	rts
loc_1DB5DE:
	lda	#$005E
	jsl	f:queue_sound
loc_1DB5E5:
	lda	$30,x
	eor	#$0002
	sta	$30,x
	rts

; Writes each arm root (slots $0300, $0440, $0580, $0640) into the trail
; ring buffers ($7E:E000-E2FF) that the claw segments follow.
ending_creature_feed_arms:
	phx
	ldx	#$0300
	ldy	#$0000
	jsr	a:ending_creature_feed_arm
	ldx	#$0440
	ldy	#$0002
	jsr	a:ending_creature_feed_arm
	ldx	#$0580
	ldy	#$0004
	jsr	a:ending_creature_feed_arm
	ldx	#$0640
	ldy	#$0006
	jsr	a:ending_creature_feed_arm
	plx
	rts

ending_creature_feed_arm:
	lda	a:ending_arm_lengths,y
	sta	$30,x
	clc
	lda	$32,x
	adc	#$0004
	cmp	#$0010
	bcc	loc_1DB628
	sec
	sbc	#$0010
loc_1DB628:
	clc
	adc	$34,x
	tax
	lda	a:ending_creature_arm_root_x,y
	sta	f:$7EE000,x
	lda	a:$169A,y
	sta	f:$7EE100,x
	lda	a:$163E,y
	sta	f:$7EE200,x
	rts

ending_start_vertical_autoscroll:
	lda	#$0002
	sta	a:bg1_scroll_mode
	sta	a:bg1_autoscroll
	lda	#$0004
	sta	a:bg1_autoscroll_speed
	lda	#$2000
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	sta	a:boss_work_2
	sta	OBJ_Y_VEL_SUB,x
	lda	#$FFFF	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	sta	a:boss_work_3
	sta	OBJ_Y_VEL,x
	rts

; The BG1 vertical scroll speed boss_work_2/boss_work_3 (16.16, added to
; bg1_y): ending_scroll_bg1_down accelerates it towards +3,
; ending_scroll_bg1_up_faster towards -6 and ending_scroll_bg1_up_slower
; towards -1.
ending_scroll_bg1_down:
	lda	a:boss_work_3
	cmp	#$0003
	bcs	loc_1DB6A2
	clc
	lda	a:boss_work_2
	adc	#$1800
	sta	a:boss_work_2
	lda	a:boss_work_3
	adc	#$0000
	sta	a:boss_work_3
	bra	loc_1DB6A2

ending_scroll_bg1_up_faster:
	lda	a:boss_work_3
	bpl	loc_1DB68F
	cmp	#$FFFA	; [num]
	bcc	loc_1DB6A2
loc_1DB68F:
	sec
	lda	a:boss_work_2
	sbc	#$1000
	sta	a:boss_work_2
	lda	a:boss_work_3
	sbc	#$0000
	sta	a:boss_work_3
loc_1DB6A2:
	clc
	lda	a:bg1_x+BG_Y_SUB
	adc	a:boss_work_2
	sta	a:bg1_x+BG_Y_SUB
	lda	a:bg1_y
	adc	a:boss_work_3
	sta	a:bg1_y
	rts

ending_scroll_bg1_up_slower:
	lda	a:boss_work_3
	cmp	#$FFFF	; [num]
	bcs	loc_1DB6A2
	clc
	lda	a:boss_work_2
	adc	#$1000
	sta	a:boss_work_2
	lda	a:boss_work_3
	adc	#$0000
	sta	a:boss_work_3
	bra	loc_1DB6A2

; The speed boss_work_0/boss_work_1 that ending_set_scroll_split adds to the
; scroll split bands: decreased by $C800 per frame down to -1, increased by
; $1000 up to 6 (ending_parallax_speed_increase).
ending_parallax_speed_decrease:
	lda	a:boss_work_1
	bpl	loc_1DB6DD
	cmp	#$FFFF	; [num]
	bcc	loc_1DB70E
loc_1DB6DD:
	sec
	lda	a:boss_work_0
	sbc	#$C800
	sta	a:boss_work_0
	lda	a:boss_work_1
	sbc	#$0000
	sta	a:boss_work_1
	rts

ending_parallax_speed_increase:
	lda	a:boss_work_1
	cmp	#$0006
	bmi	loc_1DB6FB
	bcs	loc_1DB70E
loc_1DB6FB:
	clc
	lda	a:boss_work_0
	adc	#$1000
	sta	a:boss_work_0
	lda	a:boss_work_1
	adc	#$0000
	sta	a:boss_work_1
loc_1DB70E:
	rts

; Moves the object up (2 px per frame) to y $C4 and down slowly to y $100
; (sound $5D), alternating with field $34.
ending_creature_rise_and_sink:
	lda	$34,x
	beq	loc_1DB722
	stz	OBJ_Y_VEL_SUB,x
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00C4
	bcc	loc_1DB739
loc_1DB721:
	rts
loc_1DB722:
	lda	#$C000	; [num]
	sta	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$0100
	bcc	loc_1DB721
	lda	#$005D
	jsl	f:queue_sound
	bra	loc_1DB739
loc_1DB739:
	lda	$34,x
	eor	#$0002
	sta	$34,x
	rts

; Player at Y, if it has lives: 96 frames of invulnerability
; (PLAYER_INVULN_TIMER, PLAYERF_INVULNERABLE).
ending_protect_player:
	lda	a:$1D8A,y
	beq	@return
	lda	a:$0016,y
	bmi	@return
	lda	#$0060
	sta	a:$0024,y
	lda	#$0003
	sta	a:$0016,y
@return:
	rts

; ending_missile_bob with the band y $40-$60: the missile of slot $0280 bobs
; up and down between zp_00 and zp_02 (field $3A = direction).
ending_missile_bob_default:
	lda	#$0040
	sta	zp_00
	lda	#$0060
	sta	zp_02

ending_missile_bob:
	ldy	$3A,x
	bne	loc_1DB790
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	loc_1DB790
	cmp	zp_00
	bcs	loc_1DB771
	inc	$3A,x
loc_1DB771:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB+1
	bpl	loc_1DB77B
	cmp	#$FF80	; [num]
	bcc	loc_1DB7B8
loc_1DB77B:
	sec
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	sbc	#$0400
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	sbc	#$0000
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	bra	loc_1DB7B8
loc_1DB790:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	loc_1DB79B
	cmp	zp_02
	bcc	loc_1DB79B
	stz	$3A,x
loc_1DB79B:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB+1
	bmi	loc_1DB7A5
	cmp	#$0080
	bcs	loc_1DB7B8
loc_1DB7A5:
	clc
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	adc	#$0400
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	adc	#$0000
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
loc_1DB7B8:
	rts

; Accelerates the missile of slot $0280 upwards until it is above the screen.
ending_missile_fly_up:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bpl	loc_1DB7CA
	cmp	#$FFF0	; [num]
	bcs	loc_1DB7CA
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	rts
loc_1DB7CA:
	sec
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	sbc	#$0400
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	sbc	#$0000
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	rts

ending_set_scroll_split:
	lda	#$0003
	sta	a:scroll_split_pattern
	lda	a:bg1_y
	sta	a:scroll_split_y
	phx
	ldx	#$0006
	lda	a:boss_work_0
	sta	zp_00
	lda	a:boss_work_1
	sta	zp_02
@loop:
	clc
	lda	zp_00
	adc	f:$7EE402,x
	sta	f:$7EE402,x
	lda	zp_02
	adc	f:$7EE002,x
	sta	f:$7EE002,x
	lda	zp_02
	asl	a
	ror	zp_02
	ror	zp_00
	dex
	dex
	bne	@loop
	plx
	rts

; (Hard) the four claws of the last creature: trail chains of type $96 from
; slots $0300 (5 segments), $0440 (5), $0580 (3) and $0640 (3)
; (ending_creature_spawn_claw: A = count - 1, Y = flags, X = first slot).
ending_creature_spawn_claws:
	phx
	ldy	#$000C
	lda	#$0000
	sta	zp_08
	lda	#$0004
	sta	zp_0A
	lda	#$0004
	ldx	#$0300
	jsr	a:ending_creature_spawn_claw
	lda	#$0004
	ldy	#$000C
	ldx	#$0440
	jsr	a:ending_creature_spawn_claw
	lda	#$000E
	sta	zp_0A
	lda	#$0002
	ldy	#$0000
	ldx	#$0580
	jsr	a:ending_creature_spawn_claw
	lda	#$0002
	ldy	#$0000
	ldx	#$0640
	jsr	a:ending_creature_spawn_claw
	plx
	rts

ending_creature_spawn_claw:
	sta	zp_02
	sty	zp_04
	ldy	#$0000
@loop:
	lda	#$0096
	sta	OBJ_TYPE,x
	lda	zp_04
	sta	OBJ_FLAGS,x
	lda	#.loword(metasprite_06C503)
	sta	OBJ_SPRITE,x
	lda	#$0600
	sta	OBJ_ATTR,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	phx
	phy
	lda	#$0180
	sta	$0A,x
	ldx	zp_08
	ldy	#$0008
@loop2:
	sta	f:$7EE000,x
	inx
	inx
	dey
	bpl	@loop2
	ply
	plx
	lda	zp_08
	sta	$34,x
	lda	zp_0A
	sta	$38,x
	stz	$30,x
	stz	$32,x
	clc
	txa
	adc	#$0040
	sta	$36,x
	tax
	clc
	lda	zp_08
	adc	#$0010
	sta	zp_08
	dec	zp_02
	bpl	@loop
	sec
	txa
	sbc	#$0040
	tax
	stz	$36,x
	rts

; Object type $96. Ending on HARD: segments of the claws of the creature that
; rises behind the brain (not identified exactly).
update_enemy_type_96:
	lda	a:clear_enemies_timer
	beq	loc_1DB8CB
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_1DB8CB:
	clc
	lda	$32,x
	adc	$34,x
	phx
	tax
	lda	f:$7EE000,x
	sta	zp_FC
	lda	f:$7EE100,x
	sta	zp_FE
	lda	f:$7EE200,x
	sta	zp_FA
	plx
	ldy	$30,x
	jsl	f:polar_to_xy
	clc
	lda	zp_FC
	adc	zp_08
	sta	OBJ_X,x
	sta	zp_FC
	clc
	lda	zp_FE
	adc	zp_0A
	sta	OBJ_Y,x
	sta	zp_FE
	ldy	$36,x
	beq	loc_1DB940
	lda	$30,x
	sta	a:$0030,y
	clc
	lda	$32,x
	adc	$38,x
	cmp	#$0010
	bcc	loc_1DB914
	sec
	sbc	#$0010
loc_1DB914:
	clc
	adc	$34,x
	clc
	adc	#$0010
	phx
	tax
	lda	zp_FC
	sta	f:$7EE000,x
	lda	zp_FE
	sta	f:$7EE100,x
	lda	zp_FA
	sta	f:$7EE200,x
	plx
loc_1DB930:
	lda	$32,x
	inc	a
	inc	a
	cmp	#$0010
	bcc	loc_1DB93D
	sec
	sbc	#$0010
loc_1DB93D:
	sta	$32,x
	rtl
loc_1DB940:
	lda	zp_FA
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:ending_claw_segment_sprites,y
	sta	OBJ_SPRITE,x
	bra	loc_1DB930

; Object type $97. Not seen in the emulator.
update_enemy_type_97:
	stz	a:boss_work_7
	lda	#$FFFF	; [num]
	sta	a:boss_work_4
	stz	a:boss_work_6
	lda	#$0010
	sta	a:boss_work_5
	jsl	f:clear_hdma_line_buffer
	lda	#$0002
	sta	a:cgwsel_shadow
	lda	#$0013
	sta	a:cgadsub_shadow
	lda	#$0001
	sta	a:bgmode_shadow
	phx
	ldy	#.loword(palette_task_05F8E3)
	jsl	f:start_palette_task
	plx
	phx
	ldx	#.loword(load_list_05F8D1)
	jsl	f:load_data_list
	plx
loc_1DB98C:
	rts

; Runs ending_text_script: shows the closing text lines (ptrs_ending_text_a/b)
; fading in with ending_text_fade_attrs, then erases them by DMA.
ending_run_text_script:
	ldy	a:wram_169A
	lda	a:boss_work_5
	bne	loc_1DB99F
	lda	a:boss_work_7
	bit	#$0010
	bne	loc_1DBA0F
	beq	loc_1DB9F4
loc_1DB99F:
	dec	a:boss_work_5
	bne	loc_1DB98C
	ldy	a:boss_work_4
	iny
	sty	a:boss_work_4
	lda	a:ending_text_script,y
	and	#$00FF
	cmp	#$00FE
	bcc	loc_1DB9C5
	ldy	#$0040
	cmp	#$00FE
	beq	loc_1DB9C1
	ldy	#$0160
loc_1DB9C1:
	sty	a:boss_work_5
	rts
loc_1DB9C5:
	ldy	#$0020
	sta	a:boss_work_7
	and	#$000F
	sta	a:wram_169C
	phx
	lda	a:boss_work_7
	bit	#$0010
	bne	loc_1DB9EF
	tax
	ldy	a:boss_work_6
	lda	a:ptrs_ending_text_a,y
	sta	f:$7EE900,x
	lda	a:ptrs_ending_text_b,y
	sta	f:$7EE910,x
	ldy	#$0000
loc_1DB9EF:
	sty	a:wram_169A
	plx
	rts
loc_1DB9F4:
	iny
	cpy	#$0020
	bcc	loc_1DBA36
	ldy	#$0060
	lda	a:wram_169C
	beq	loc_1DBA05
	ldy	#$0020
loc_1DBA05:
	sty	a:boss_work_5
	inc	a:boss_work_6
	inc	a:boss_work_6
	rts
loc_1DBA0F:
	dey
	bne	loc_1DBA36
	ldy	#$0020
	lda	a:wram_169C
	beq	loc_1DBA1D
	ldy	#$0001
loc_1DBA1D:
	sty	a:boss_work_5
	inc	a
	inc	a
	xba
	lsr	a
	lsr	a
	clc
	adc	#$5C20
	sta	bg_dma_vram_addr
	lda	#$A000	; [num]
	sta	bg_dma_src
	lda	#$00C0
	sta	bg_dma_size
	rts
loc_1DBA36:
	sty	a:wram_169A
	phx
	tya
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:ending_text_fade_attrs,y
	pha
	sec
	sbc	#$0400
	sta	zp_FC
	ldx	a:wram_169C
	lda	f:$7EE900,x
	tax
	pla
	jsl	f:draw_text_attr
	ldx	a:wram_169C
	lda	f:$7EE910,x
	tax
	lda	zp_FC
	jsl	f:draw_text_attr
	plx
	rts

; Shakes the screen and, every other frame, spawns an explosion effect
; (anim_05C69C) in the area zp_00/zp_04.
ending_shake_and_explode:
	lda	#$0004
	sta	a:shake_timer
	lda	stage_frame_odd
	beq	@return
	stz	zp_06
	lda	#$00C0
	sta	zp_02
	ldy	#$0700
	lda	#.loword(anim_05C69C)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rts

ending_sequence_state_16:
	jsr	a:ending_parallax_speed_increase
	jsr	a:ending_set_scroll_split
	lda	#$0030
	sta	zp_00
	lda	#$0040
	sta	zp_02
	jsr	a:ending_missile_bob
	jsr	a:ending_bg2_follow_missile
	lda	OBJ_TIMER,x
	bmi	loc_1DBAAA
	dec	OBJ_TIMER,x
	bpl	loc_1DBAE9
loc_1DBAAA:
	dec	a:inidisp_shadow
	dec	a:inidisp_shadow
	beq	loc_1DBAB4
	bpl	loc_1DBAE9
loc_1DBAB4:
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	stz	a:tm_shadow
	stz	hdma_preset
	inc	OBJ_STATE,x
	lda	#$00F0
	sta	a:bg2_y
	lda	#$0024
	sta	OBJ_TIMER,x
	phx
	ldy	#.loword(palette_task_05FECD)
	jsl	f:start_palette_task
	ldx	#$1210
	ldy	#.loword(palette_task_05FED9)
	jsl	f:start_palette_task_at
	plx
	stz	a:boss_work_4
	lda	#$0081
	jsl	f:queue_sound
loc_1DBAE9:
	rtl

ending_sequence_state_17:
	dec	OBJ_TIMER,x
	bpl	loc_1DBB2D
	lda	#$0080
	sta	OBJ_TIMER,x
	phx
	ldy	difficulty
	ldx	a:ptrs_ending_message_loads,y
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05FEE8)
	jsl	f:start_palette_task
	plx
	inc	OBJ_STATE,x
	lda	#$0081
	jsl	f:queue_sound
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+2*OBJ_SIZE+$3A
	lda	#$FFDD	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	ldy	a:p1_lives
	beq	loc_1DBB25
	sta	a:player1_obj+OBJ_Y
loc_1DBB25:
	ldy	a:p2_lives
	beq	loc_1DBB2D
	; (not executed in the CDL traces)
	sta	a:player2_obj+OBJ_Y
loc_1DBB2D:
	rtl

ending_sequence_state_18:
	dec	OBJ_TIMER,x
	bpl	loc_1DBB6A
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	difficulty
	cmp	#$0004
	beq	loc_1DBB45
	lda	#$0029
	sta	OBJ_STATE,x
	bra	loc_1DBB47
loc_1DBB45:
	inc	OBJ_STATE,x
loc_1DBB47:
	phx
	ldx	#.loword(song_set_05F4C3)
	jsl	f:load_song_set
	lda	#$0071
	jsl	f:queue_sound
	ldy	#.loword(palette_task_05FEC7)
	jsl	f:start_palette_task
	ldx	#.loword(load_list_05FEDF)
	jsl	f:load_data_list
	plx
	lda	#$0013
	sta	hdma_preset
loc_1DBB6A:
	rtl

ending_sequence_state_19:
	dec	OBJ_TIMER,x
	bpl	@return
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
	phx
	ldy	a:boss_work_4
	lda	a:ptrs_05FDBC,y
	tax
	jsl	f:load_data_list
	plx
@return:
	rtl

ending_sequence_state_1A:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0004
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_1B:
	dec	OBJ_TIMER,x
	bpl	loc_1DBBA8
	lda	#$00E0
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	phx
	ldx	#$1210
	ldy	#.loword(palette_task_05FED3)
	jsl	f:start_palette_task_at
	plx
	rtl
loc_1DBBA8:
	lda	difficulty
	cmp	#$0004
	bne	@return
	lda	stage_frame_odd
	beq	@return
	lda	OBJ_TIMER,x
	and	#$0002
	tay
	lda	a:ending_hard_tile_vram_addrs,y
	pha
	lda	a:ending_hard_tile_block_offsets,y
	ldy	a:boss_work_4
	clc
	adc	a:ptrs_ending_hard_tile_blocks,y
	tay
	lda	#$0004
	sta	zp_02
	lda	#$0040
	sta	zp_08
	pla
	phx
	jsl	f:queue_vram_blocks
	plx
@return:
	rtl

ending_sequence_state_1C:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0014
	sta	OBJ_TIMER,x
	lda	#$0019
	sta	OBJ_STATE,x
	phx
	ldx	#$1210
	ldy	#.loword(palette_task_05FED9)
	jsl	f:start_palette_task_at
	plx
	inc	a:boss_work_4
	inc	a:boss_work_4
	lda	a:boss_work_4
	cmp	#$000A
	bcc	@return
	lda	#$0054
	sta	OBJ_TIMER,x
	lda	#$001D
	sta	OBJ_STATE,x
	phx
	ldy	#.loword(palette_task_05FECD)
	jsl	f:start_palette_task
	plx
@return:
	rtl

ending_sequence_state_1E:
	dec	OBJ_TIMER,x
	bmi	loc_1DBC1D
	brl	loc_1DBBA8
loc_1DBC1D:
	lda	#$0380
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x
	stz	hdma_preset
	jsr	a:update_enemy_type_97
	rtl

ending_sequence_state_1F:
	lda	stage_frame_odd
	beq	loc_1DBC58
	sec
	lda	OBJ_TIMER,x
	sbc	#$0080
	sta	OBJ_TIMER,x
	bne	loc_1DBC49
	inc	OBJ_STATE,x
	lda	#$0012
	sta	hdma_preset
	lda	#$001F
	sta	a:tm_shadow
	stz	a:inidisp_shadow
	rtl
loc_1DBC49:
	adc	#$5C00
	sta	bg_dma_vram_addr
	lda	#$A000	; [num]
	sta	bg_dma_src
	lda	#$00FE
	sta	bg_dma_size
loc_1DBC58:
	rtl

ending_sequence_state_25:
	dec	OBJ_TIMER,x
	bpl	loc_1DBC89
	lda	stage_frame_odd
	beq	loc_1DBC89
	lda	#$0002
	sta	zp_02
	lda	#$0020
	sta	zp_08
	ldy	#.loword(vram_blocks_05946A)
	lda	#$4C0C
	phx
	jsl	f:queue_vram_blocks
	plx
	inc	OBJ_STATE,x
	jsr	a:ending_start_vertical_autoscroll
	lda	#$0012
	sta	a:boss_work_0
	lda	#$0059
	jsl	f:queue_sound
loc_1DBC89:
	lda	#$0058
	sta	zp_00
	lda	#$003F
	sta	zp_04
	jsr	a:ending_shake_and_explode
	rtl

ending_sequence_state_26:
	lda	a:bg1_y
	bit	#$00FF
	beq	loc_1DBCBB
	bit	#$0080
	bne	loc_1DBCBB
	inc	OBJ_STATE,x
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0004
	sta	a:bg1_scroll_mode
	lda	#$0100
	sta	OBJ_TIMER,x
loc_1DBCBB:
	jsr	a:ending_scroll_bg1_up_faster
	rtl

ending_sequence_state_27:
	dec	OBJ_TIMER,x
	bpl	loc_1DBCBB
	inc	OBJ_STATE,x
	lda	#$8000	; [num]
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_Y_VEL_SUB
	bra	loc_1DBCBB

ending_sequence_state_28:
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_Y
	bmi	loc_1DBCBB
	cmp	#$0010
	bcc	loc_1DBCBB
	lda	#$0010
	sta	OBJ_TIMER,x
	lda	#$0010
	sta	OBJ_STATE,x
	bra	loc_1DBCBB

ending_sequence_state_0F:
	lda	OBJ_Y,x
	cmp	#$0108
	bcc	loc_1DBCF5
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	inc	OBJ_STATE,x
	lda	#$0010
	sta	OBJ_TIMER,x
loc_1DBCF5:
	lda	OBJ_TIMER,x
	bmi	loc_1DBCFD
	dec	OBJ_TIMER,x
	bra	loc_1DBD02
loc_1DBCFD:
	lda	#$8000	; [num]
	sta	OBJ_Y_VEL_SUB,x
loc_1DBD02:
	jsr	a:ending_missile_bob_default
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_creature_place_arm_bases
	jsr	a:ending_set_missile_hdma
	jsr	a:ending_shake_and_flash
	lda	#$003F
	sta	zp_04
	sta	zp_06
	jsr	a:ending_spawn_floor_explosions
	rtl

ending_sequence_state_11:
	jsr	a:ending_missile_bob_default
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_set_missile_hdma
	jsr	a:ending_floor_explosions_rise
	jsr	a:ending_shake_and_flash
	dec	OBJ_TIMER,x
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

ending_sequence_state_12:
	jsr	a:ending_missile_bob_default
	jsr	a:ending_scroll_bg1_up_faster
	jsr	a:ending_set_missile_hdma
	jsr	a:ending_floor_explosions_rise
	jsr	a:ending_shake_and_flash
	inc	OBJ_STATE,x
	lda	#$0002
	sta	a:stage_pause_disabled
	rtl

; Object type $98. Ending: explosions along the floor of the lair.
update_ending_explosion:
	ldy	OBJ_ANIM,x
	bne	loc_1DBD54
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_1DBD54:
	lda	a:$0004,y
	sta	OBJ_ATTR,x
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$8000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $99. Not seen in the emulator.
update_enemy_type_99:
	; (not executed in the CDL traces)
	rtl

; Shakes the screen and now and then uploads the flash palette.
ending_shake_and_flash:
	lda	#$0002
	sta	a:shake_timer
	lda	stage_frame_counter
	bit	#$0001
	bne	@return
	lda	rng_lo
	and	#$0003
	bne	@return
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$3040
	sta	cgram_upload_addr
@return:
	rts

; Raises the source of the floor explosions to y $E0 (one pixel every 4
; frames), then ending_spawn_floor_explosions: two OBJT_ENDING_EXPLOSION
; effects thrown up and outwards (ending_explosion_x_vels by side).
ending_floor_explosions_rise:
	lda	OBJ_Y,x
	cmp	#$00E0
	bcc	loc_1DBD96
	lda	stage_frame_mod4
	bne	loc_1DBD96
	dec	OBJ_Y,x
loc_1DBD96:
	lda	#$00FF
	sta	zp_04
	lda	#$007F
	sta	zp_06

ending_spawn_floor_explosions:
	lda	OBJ_X,x
	adc	#$FFF0
	sta	zp_00
	lda	OBJ_Y,x
	sta	zp_02
	ldy	#$02C0
	lda	#$0001
	sta	zp_FC
loc_1DBDB3:
	lda	rng_lo
	adc	rng_hi
	adc	stage_frame_mod8
	sta	rng_lo
	tya
	adc	frame_counter
	adc	rng_hi
	sta	rng_hi
	lda	#.loword(anim_05C558)
	jsl	f:spawn_effect_random_offset
	bcs	loc_1DBDF6
	lda	#OBJT_ENDING_EXPLOSION
	sta	a:$0010,y
	lda	#$FFFE	; [num]
	sta	a:$001E,y
	phx
	ldx	#$0000
	lda	a:$000A,y
	cmp	#$0080
	bcc	loc_1DBDE5
	inx
	inx
loc_1DBDE5:
	lda	a:ending_explosion_x_vel_subs,x
	sta	a:$0018,y
	lda	a:ending_explosion_x_vels,x
	sta	a:$001A,y
	plx
	dec	zp_FC
	bpl	loc_1DBDB3
loc_1DBDF6:
	jsl	f:queue_sound_6E_throttled
	rts

ending_sequence_state_29:
	lda	OBJ_TIMER,x
	bmi	loc_1DBE03
	dec	OBJ_TIMER,x
	bpl	ending_sequence_state_2A
loc_1DBE03:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	bne	loc_1DBE11
	jsr	a:ending_blink_push_start_key
	bra	ending_sequence_state_2A
loc_1DBE11:
	; (not executed in the CDL traces)
	phx
	ldx	#.loword(text_push_start_key_blank)
	lda	#$0400
	jsl	f:draw_text_attr
	plx
	lda	#$0100
	sta	a:stage_exit_request
	lda	#$0084
	jsl	f:queue_sound
	inc	OBJ_STATE,x

ending_sequence_state_2A:
	jsr	a:ending_spawn_text_screen_sparkles
	rtl

; On the last text screen, not on easy: random effects (anim_05C6EA /
; anim_05C702) over the screen (seen in the emulator).
ending_spawn_text_screen_sparkles:
	lda	difficulty
	beq	loc_1DBE60
	lda	#$00FF
	sta	zp_06
	sta	zp_04
	sta	zp_02
	lda	#$0010
	sta	zp_00
	lda	#.loword(anim_05C6EA)
	ldy	stage_frame_odd
	bne	loc_1DBE4C
	lda	#.loword(anim_05C702)
loc_1DBE4C:
	ldy	#$0300
	jsl	f:spawn_effect_random_offset
	bcs	loc_1DBE60
	lda	rng_lo
	and	#$0007
	adc	#$FFFA
	sta	a:$001A,y
loc_1DBE60:
	rts

; Blinks the text "PUSH START KEY" (text_push_start_key and its blank
; text_push_start_key_blank) every 16 frames.
ending_blink_push_start_key:
	phx
	ldx	#.loword(text_push_start_key)
	lda	stage_frame_counter
	bit	#$0010
	bne	loc_1DBE6F
	ldx	#.loword(text_push_start_key_blank)
loc_1DBE6F:
	lda	#$0400
	jsl	f:draw_text_attr
	plx
	rts

; Object type $6F, $8A. Stage 6 final boss: the giant brain (type $8A, slot
; $0900); its attacks are the brain_boss_* types. Type $6F uses the same
; handler but was not seen in the emulator. Initial HP by difficulty:
; $0401/$4256/$7532 (brain_boss_hp), halved in state 6 when at least $100.
update_brain_boss:
	lda	a:boss_work_7
	bmi	loc_1DBE80
	dec	a:boss_work_7
loc_1DBE80:
	lda	OBJ_SAVED_ATTR,x
	beq	loc_1DBEA5
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0030
	sta	cgram_upload_addr
	lda	a:boss_hit_sound_timer
	bmi	loc_1DBE98
	dec	a:boss_hit_sound_timer
	bra	loc_1DBEA5
loc_1DBE98:
	lda	#$003C
	jsl	f:queue_sound
	lda	#$0004
	sta	a:boss_hit_sound_timer
loc_1DBEA5:
	lda	OBJ_HP,x
	bpl	loc_1DBED8
	lda	#$0002
	sta	a:clear_enemies_timer
	lda	#$0002
	sta	a:boss_work_1
	lda	#$0008
	sta	OBJ_STATE,x
	lda	#$0030
	sta	OBJ_FLAGS,x
	lda	#$0100
	sta	OBJ_TIMER,x
	stz	OBJ_HP,x
	lda	#$003F
	sta	$34,x
	lda	#$001F
	sta	$36,x
	stz	OBJ_Y_VEL,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_X_VEL_SUB,x
loc_1DBED8:
	lda	OBJ_STATE,x
	beq	loc_1DBEEE
	sec
	lda	#$0160
	sbc	OBJ_X,x
	sta	a:bg2_x
	sec
	lda	#$0140
	sbc	OBJ_Y,x
	sta	a:bg2_y
loc_1DBEEE:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_brain_boss_states:
	.addr	brain_boss_state_00
	.addr	brain_boss_state_01
	.addr	brain_boss_state_02
	.addr	brain_boss_state_03
	.addr	brain_boss_state_04
	.addr	brain_boss_state_05
	.addr	brain_boss_state_06
	.addr	brain_boss_state_07
	.addr	brain_boss_state_08
	.addr	brain_boss_state_09
	.addr	brain_boss_state_0A

brain_boss_state_00:
	inc	OBJ_STATE,x
	ldy	difficulty
	lda	#$0031
	sta	OBJ_FLAGS,x
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	a:brain_boss_hp,y
	sta	OBJ_HP,x
	lda	#$0038
	sta	OBJ_HITBOX_W,x
	lda	#$FFD0	; [num]
	sta	OBJ_HITBOX_H,x
	lda	#$014B
	sta	$36,x
	stz	$38,x
	stz	$34,x
	sec
	lda	#$0140
	sbc	a:bg2_y
	sta	OBJ_Y,x
	lda	#$0060
	sta	OBJ_X,x
	stz	a:boss_work_1
	phx
	ldx	#.loword(load_list_05FF27)
	jsl	f:load_data_list
	plx
	stz	a:boss_work_6
	stz	a:boss_hit_sound_timer
	jml	f:init_line_hdma_table

brain_boss_state_01:
	dec	OBJ_TIMER,x
	bpl	loc_1DBF72
	lda	#$8000	; [num]
	sta	OBJ_Y_VEL_SUB,x
	inc	OBJ_STATE,x
	lda	#$0040
	sta	OBJ_TIMER,x
	lda	#$0010
	sta	hdma_preset
loc_1DBF72:
	jml	f:init_line_hdma_table

brain_boss_state_02:
	jsr	a:brain_boss_pulse
	lda	OBJ_Y,x
	bmi	@return
	cmp	#$0070
	bcc	@return
	stz	OBJ_Y_VEL_SUB,x
	inc	OBJ_STATE,x
	stz	hdma_preset
@return:
	rtl

brain_boss_state_03:
	jsr	a:brain_boss_spawn_orb_clusters
	jsr	a:brain_boss_random_spin
	lda	rng_lo
	and	#$00FF
	sta	a:boss_work_2
	lda	#$0001
	sta	a:boss_work_3
	stz	a:boss_work_4
	inc	OBJ_STATE,x
	rtl

brain_boss_state_04:
	lda	a:boss_work_4
	cmp	#$0001
	bcs	loc_1DBFD4
	lda	stage_frame_counter
	bit	#$003F
	bne	loc_1DBFB5
	jsr	a:brain_boss_random_spin
loc_1DBFB5:
	lda	#$0001
	sta	a:shake_continuous
	lda	a:boss_work_3
	cmp	#$0030
	bcs	loc_1DBFCA
	lda	stage_frame_odd
	bne	loc_1DBFCA
	inc	a:boss_work_3
loc_1DBFCA:
	clc
	lda	a:boss_work_2
	adc	$3E,x
	sta	a:boss_work_2
	rtl
loc_1DBFD4:
	cmp	#$0002
	beq	loc_1DC005
	lda	#$0060
	sta	OBJ_TIMER,x
	ldy	#$0300
@loop:
	lda	a:$0006,y
	bne	loc_1DBFEE
	tya
	clc
	adc	#$0040
	tay
	bra	@loop
loc_1DBFEE:
	lda	#$0030
	sta	a:$0016,y
	lda	a:$0024,y
	lsr	a
	sta	a:boss_work_0
	inc	a:boss_work_4
	ldy	#.loword(vram_blocks_05FF5D)
	jsr	a:queue_brain_boss_tiles
loc_1DC004:
	rtl
loc_1DC005:
	dec	OBJ_TIMER,x
	bpl	loc_1DC004
	lda	#$0011
	sta	OBJ_FLAGS,x
	lda	rng_hi
	and	#$003F
	adc	#$0200
	sta	a:boss_work_7
	inc	OBJ_STATE,x
	lda	a:boss_work_0
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_attack_starts,x
	plx
	sta	zp_00
	jmp	(zp_00)
; Brain boss attacks: boss_work_0 (0-7, chosen in state 4) selects the
; routine that starts the attack (this table, state 4) and the one that runs
; it every frame (tbl_brain_boss_attacks, state 5); attacks 4 and 5 are
; sequences of steps (boss_work_6).
tbl_brain_boss_attack_starts:
	.addr	brain_boss_attack_start_0
	.addr	brain_boss_attack_start_1
	.addr	brain_boss_attack_start_2
	.addr	brain_boss_attack_start_3
	.addr	brain_boss_attack_start_4
	.addr	brain_boss_attack_start_5
	.addr	brain_boss_attack_start_6
	.addr	brain_boss_attack_start_7

brain_boss_state_05:
	lda	a:boss_work_0
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_attacks,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_brain_boss_attacks:
	.addr	brain_boss_attack_0
	.addr	brain_boss_attack_1
	.addr	brain_boss_attack_2
	.addr	brain_boss_attack_3
	.addr	brain_boss_attack_4
	.addr	brain_boss_attack_5
	.addr	brain_boss_attack_6
	.addr	brain_boss_attack_7

brain_boss_state_06:
	lda	OBJ_HP,x
	cmp	#$0100
	bcc	loc_1DC065
	lsr	a
	sta	OBJ_HP,x
loc_1DC065:
	inc	OBJ_STATE,x
	stz	$3A,x
	lda	#$0010
	sta	hdma_preset
	lda	#$014B
	sta	$36,x
	lda	#$0031
	sta	OBJ_FLAGS,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	stz	$3E,x
	jsr	a:brain_boss_pulse
	stz	a:boss_work_6
	rtl

brain_boss_state_07:
	lda	$36,x
	ldy	$3A,x
	bne	loc_1DC0E1
	cmp	#$0111
	bcs	loc_1DC0DB
	inc	$3A,x
	lda	#$0004
	sta	zp_FC
@loop:
	jsl	f:find_free_slot_y
	bcs	loc_1DC0C6
	lda	#.loword(anim_05C6DE)
	jsl	f:make_effect_object
	lda	OBJ_Y,x
	adc	#$FFE4
	sta	a:$000E,y
	lda	OBJ_X,x
	adc	#$001C
	sta	a:$000A,y
	lda	zp_FC
	sta	a:$001A,y
	dec	zp_FC
	lda	zp_FC
	cmp	#$FFFB	; [num]
	bne	@loop
loc_1DC0C6:
	lda	#$0180
	sta	OBJ_Y,x
	lda	#$0105
	sta	$36,x
	lda	#$0020
	sta	OBJ_TIMER,x
	lda	#$0003
	sta	a:shake_timer
loc_1DC0DB:
	dec	$36,x
	jsr	a:brain_boss_build_hdma
	rtl
loc_1DC0E1:
	cpy	#$0002
	beq	loc_1DC10A
	dec	OBJ_TIMER,x
	bpl	loc_1DC106
	inc	$3A,x
	lda	#$0060
	sta	OBJ_X,x
	ldy	a:boss_work_1
	lda	a:brain_boss_reappear_y,y
	sta	OBJ_Y,x
	ldy	#.loword(vram_blocks_05FF59)
	jsr	a:queue_brain_boss_tiles
	lda	#$0059
	jsl	f:queue_sound
loc_1DC106:
	jsr	a:brain_boss_build_hdma
	rtl
loc_1DC10A:
	cmp	#$014B
	bcc	loc_1DC119
	ldy	a:boss_work_1
	lda	a:brain_boss_reappear_states,y
	sta	OBJ_STATE,x
	stz	hdma_preset
loc_1DC119:
	inc	$36,x
	jsr	a:brain_boss_build_hdma
	lda	#$0001
	sta	a:shake_continuous
	rtl

brain_boss_state_08:
	lda	#$0004
	sta	a:shake_timer
	dec	OBJ_TIMER,x
	bpl	loc_1DC13D
	lda	#$0006
	sta	OBJ_STATE,x
	phx
	ldx	#.loword(load_list_05FF30)
	jsl	f:load_data_list
	plx
loc_1DC13D:
	jsl	f:queue_sound_41_throttled
	jml	f:loc_01D83E

brain_boss_state_09:
	lda	#$0200
	sta	OBJ_TIMER,x
	inc	OBJ_STATE,x

brain_boss_state_0A:
	lda	#.loword(palette_05918A)
	sta	cgram_upload_src
	lda	#$0030
	sta	cgram_upload_addr
	dec	OBJ_TIMER,x
	bpl	loc_1DC175
	lda	#OBJT_ENDING_SEQUENCE
	sta	OBJ_TYPE,x
	stz	OBJ_STATE,x
	clc
	lda	a:bg1_x
	and	#$0100
	eor	#$0000
	xba
	asl	a
	asl	a
	clc
	adc	#$0040
	sta	a:bg1sc_shadow
loc_1DC175:
	lda	OBJ_TIMER,x
	cmp	#$0180
	bne	loc_1DC182
	inc	a:boss_work_6
	inc	a:boss_work_6
loc_1DC182:
	lda	OBJ_TIMER,x
	cmp	#$0180
	bcs	loc_1DC18D
	jsl	f:queue_sound_6E_throttled
loc_1DC18D:
	lda	#$0004
	sta	a:shake_timer
	lda	#$00FF
	sta	zp_02
	stz	zp_00
	sta	zp_04
	sta	zp_06
	ldy	a:boss_work_6
	lda	a:brain_boss_death_effect_y_vels,y
	sta	zp_FC
	lda	a:brain_boss_death_effect_anims,y
	ldy	#$02C0
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	zp_FC
	sta	a:$001E,y
@return:
	rtl

brain_boss_attack_0:
	jsr	a:brain_boss_sway_x
	lda	#$0070
	sta	zp_00
	lda	#$00A0
	sta	zp_02
	jsr	a:brain_boss_sway_y
	lda	a:boss_work_7
	bpl	loc_1DC1D0
	inc	OBJ_STATE,x
	rtl
loc_1DC1D0:
	lda	stage_frame_counter
	bit	#$001F
	bne	loc_1DC1E5
	lda	rng_lo
	bit	#$0001
	bne	loc_1DC1E5
	lda	$36,x
	eor	#$0002
	sta	$36,x
loc_1DC1E5:
	lda	#$0001
	sta	zp_00
	lda	#$FFFF	; [num]
	sta	zp_02
	jsr	a:brain_boss_oscillate
	lda	stage_frame_counter
	bit	#$003F
	bne	loc_1DC208
	lda	rng_hi
	bit	#$0001
	bne	loc_1DC208
	lda	$38,x
	eor	#$FFFF
	inc	a
	sta	$38,x
loc_1DC208:
	lda	a:boss_work_3
	cmp	#$0024
	bcc	loc_1DC217
	lda	#$FFFF	; [num]
	sta	$38,x
	bra	loc_1DC221
loc_1DC217:
	cmp	#$0014
	bcs	loc_1DC221
	lda	#$0002
	sta	$38,x
loc_1DC221:
	clc
	lda	a:boss_work_3
	adc	$38,x
	sta	a:boss_work_3
	lda	a:boss_work_4
	cmp	#$FFE8	; [num]
	bcc	@return
	sec
	lda	a:boss_work_4
	sbc	#$0004
	sta	a:boss_work_4
@return:
	rtl

brain_boss_attack_5:
	lda	a:boss_work_6
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_attack_5_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_brain_boss_attack_5_steps:
	.addr	brain_boss_attack_5_step_00
	.addr	brain_boss_attack_5_step_01
	.addr	brain_boss_attack_5_step_02
	.addr	brain_boss_attack_5_step_03
	.addr	brain_boss_attack_5_step_00
	.addr	brain_boss_attack_5_step_05

brain_boss_attack_5_step_00:
	lda	OBJ_Y,x
	cmp	#$00BC
	bcc	@return
	stz	OBJ_Y_VEL,x
	lda	#$0003
	sta	a:shake_timer
	inc	a:boss_work_6
	lda	a:boss_work_6
	cmp	#$0005
	beq	@return
	lda	#$0050
	sta	OBJ_TIMER,x
	lda	#$008C
	ldy	#$0340
	jsr	a:brain_boss_fill_slots
@return:
	rtl

brain_boss_attack_5_step_01:
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$FFFE	; [num]
	sta	OBJ_Y_VEL,x
	inc	a:boss_work_6
@return:
	rtl

brain_boss_attack_5_step_03:
	lda	a:boss_work_7
	bpl	@return
	lda	#$0001
	sta	OBJ_Y_VEL,x
	inc	a:boss_work_6
@return:
	rtl

brain_boss_attack_5_step_02:
	lda	OBJ_Y,x
	cmp	#$0070
	bcs	@return
	stz	OBJ_Y_VEL,x
	inc	a:boss_work_6
@return:
	rtl

brain_boss_attack_5_step_05:
	rtl

brain_boss_attack_3:
	lda	a:boss_work_6
	bne	loc_1DC2C0
	ldy	a:difficulty
	lda	a:brain_boss_attack_3_min_y,y
	cmp	OBJ_Y,x
	bcc	@return
	inc	a:boss_work_6
	stz	OBJ_Y_VEL,x
@return:
	rtl
loc_1DC2C0:
	lda	#$0001
	sta	a:shake_continuous
	jsr	a:brain_boss_sway_x
	lda	a:boss_work_7
	bpl	loc_1DC2D1
	inc	OBJ_STATE,x
	rtl
loc_1DC2D1:
	lda	stage_frame_mod8
	bne	loc_1DC31A
	lda	rng_lo
	and	#$0001
	bne	loc_1DC2F0
	lda	#$008E
	phx
	jsr	a:brain_boss_spawn_minion
	bcs	loc_1DC31A
	lda	#$3400
	sta	$02,x
	txy
	jsr	a:brain_boss_launch_from_mouth
	plx
	rtl
loc_1DC2F0:
	ldy	#$0800
	jsl	f:find_free_slot_y_down
	bcc	loc_1DC31A
	lda	#$000F
	sta	a:$0010,y
	lda	#$0001
	sta	a:$003E,y
	jsr	a:brain_boss_launch_from_mouth
	lda	rng_hi
	xba
	and	#$0007
	inc	a
	cmp	#$0006
	bcc	loc_1DC317
	lda	#$0007
loc_1DC317:
	sta	a:$003A,y
loc_1DC31A:
	rtl

brain_boss_attack_2:
	jsr	a:brain_boss_sway_x
	lda	#$0038
	sta	zp_00
	lda	#$0040
	sta	zp_02
	jsr	a:brain_boss_sway_y
	lda	a:boss_work_3
	cmp	#$00F0
	bcs	loc_1DC34E
	lda	stage_frame_counter
	bit	#$007F
	bne	loc_1DC341
	lda	$36,x
	eor	#$0002
	sta	$36,x
loc_1DC341:
	lda	#$0004
	sta	zp_00
	lda	#$FFFC	; [num]
	sta	zp_02
	jsr	a:brain_boss_oscillate
loc_1DC34E:
	lda	stage_frame_odd
	bne	@return
	dec	a:boss_work_3
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

brain_boss_attack_6:
	jsr	a:brain_boss_sway_x
	lda	#$0078
	sta	zp_00
	lda	#$0080
	sta	zp_02
	jsr	a:brain_boss_sway_y
	lda	a:boss_work_7
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

brain_boss_attack_1:
	lda	a:boss_work_6
	bne	loc_1DC39D
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$1480
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	lda	OBJ_Y,x
	cmp	#$00C0
	bcc	@return
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	lda	#$0004
	sta	a:shake_timer
	inc	a:boss_work_6
@return:
	rtl
loc_1DC39D:
	lda	#$0001
	sta	a:shake_continuous
	lda	stage_frame_counter
	bit	#$007F
	bne	loc_1DC3F4
	lda	#$0091
	phx
	jsr	a:brain_boss_spawn_minion
	bcs	loc_1DC3F3
	lda	#$0001
	sta	$3A,x
	lda	#$0040
	sta	$38,x
	lda	#$0004
	sta	$24,x
	lda	#$00B0
	sta	$0E,x
	stx	zp_FC
	stz	zp_FE
	lda	difficulty
	lsr	a
	lsr	a
	sta	zp_FA
@loop:
	lda	#$0091
	jsr	a:brain_boss_spawn_minion
	bcs	loc_1DC3ED
	clc
	lda	zp_FE
	adc	#$001C
	sta	zp_FE
	lda	zp_FC
	sta	$38,x
	lda	zp_FE
	sta	$36,x
	dec	zp_FA
	bpl	@loop
loc_1DC3ED:
	ldx	zp_FC
	lda	zp_FE
	sta	$36,x
loc_1DC3F3:
	plx
loc_1DC3F4:
	lda	a:boss_work_7
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

brain_boss_attack_4:
	lda	a:boss_work_7
	bpl	loc_1DC404
	inc	OBJ_STATE,x
	rtl
loc_1DC404:
	ldy	$38,x
	lda	#$0001
	sta	a:shake_continuous
	lda	a:boss_work_6
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_attack_4_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_brain_boss_attack_4_steps:
	.addr	brain_boss_attack_4_step_00
	.addr	brain_boss_attack_4_step_01
	.addr	brain_boss_attack_4_step_02
	.addr	brain_boss_attack_4_step_03
	.addr	brain_boss_attack_4_step_04
	.addr	brain_boss_attack_4_step_05
	.addr	brain_boss_attack_4_step_06
	.addr	brain_boss_attack_4_step_04
	.addr	brain_boss_attack_4_step_01

brain_boss_attack_4_step_00:
	lda	OBJ_Y,x
	cmp	#$007C
	bcs	loc_1DC437
	inc	OBJ_Y,x
loc_1DC437:
	inc	a:boss_work_3
	lda	a:boss_work_3
	cmp	#$0014
	bcc	@return
	inc	a:boss_work_6
	lda	#$0004
	sta	a:shake_timer
@return:
	rtl

brain_boss_attack_4_step_01:
	lda	OBJ_X,x
	cmp	#$0040
	bcs	loc_1DC458
	lda	#$0000
	bra	loc_1DC467
loc_1DC458:
	cmp	#$0090
	bcc	loc_1DC462
	lda	#$0002
	bra	loc_1DC467
loc_1DC462:
	lda	rng_lo
	and	#$0002
loc_1DC467:
	sta	$38,x
	tay
	lda	a:brain_boss_attack_4_slots,y
	tay
	lda	a:$000A,y
	sta	a:$0036,y
	lda	a:$000E,y
	sta	a:$0038,y
	lda	#$0002
	sta	a:boss_work_6
	rtl

brain_boss_attack_4_step_06:
	tya
	clc
	adc	#$0004
	tay

brain_boss_attack_4_step_05:
	lda	$3E,x
	cmp	#$00D0
	bcs	loc_1DC490
	inc	$3E,x
loc_1DC490:
	bra	loc_1DC4A1

brain_boss_attack_4_step_03:
	tya
	clc
	adc	#$0004
	tay

brain_boss_attack_4_step_02:
	lda	$3E,x
	cmp	#$00C0
	bcc	loc_1DC4A1
	dec	$3E,x
loc_1DC4A1:
	clc
	lda	a:boss_work_4
	adc	a:brain_boss_attack_4_angle_steps,y
	sta	a:boss_work_4
	sta	a:boss_work_2
	cmp	a:brain_boss_attack_4_angle_limits,y
	bne	loc_1DC4DA
	inc	a:boss_work_6
	lda	a:boss_work_6
	cmp	#$0004
	beq	loc_1DC4C3
	cmp	#$0007
	bne	loc_1DC4DA
loc_1DC4C3:
	lda	rng_lo
	and	#$000F
	adc	#$0004
	sta	OBJ_TIMER,x
	lda	#$0004
	sta	a:shake_timer
	lda	#$0039
	jsl	f:queue_sound
loc_1DC4DA:
	ldy	$38,x
	lda	a:brain_boss_attack_4_slots,y
	tay
	sec
	lda	a:$0036,y
	sbc	a:$000A,y
	clc
	adc	OBJ_X,x
	sta	OBJ_X,x
	sec
	lda	a:$0038,y
	sbc	a:$000E,y
	clc
	adc	OBJ_Y,x
	sta	OBJ_Y,x
	rtl

brain_boss_attack_4_step_04:
	dec	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	bpl	@return
	lda	$38,x
	eor	#$0002
	sta	$38,x
	tay
	lda	a:brain_boss_attack_4_slots,y
	tay
	lda	a:$000A,y
	sta	a:$0036,y
	lda	#$00B0
	sta	a:$0038,y
	inc	a:boss_work_6
@return:
	rtl

brain_boss_attack_7:
	lda	stage_frame_counter
	bit	#$003F
	bne	loc_1DC544
	lda	#$0093
	phx
	jsr	a:brain_boss_spawn_minion
	bcs	loc_1DC544
	lda	#$0003
	ldy	rng_lo
	bpl	loc_1DC535
	lda	#$FFFD	; [num]
loc_1DC535:
	sta	$1E,x
	lda	#$0001
	ldy	rng_hi
	bpl	loc_1DC541
	lda	#$FFFF	; [num]
loc_1DC541:
	sta	$1A,x
	plx
loc_1DC544:
	lda	#$0060
	sta	zp_00
	lda	#$0080
	sta	zp_02
	jsr	a:brain_boss_sway_y
	lda	a:boss_work_7
	bpl	@return
	inc	OBJ_STATE,x
@return:
	rtl

brain_boss_attack_start_0:
	lda	#$008B
	ldy	#$0700
	jsr	a:brain_boss_fill_slots
	lda	#$0001
	sta	$38,x
	stz	$36,x
	stz	$32,x
	stz	$34,x
	lda	#$0001
	sta	a:boss_work_3
	lda	#$FFFC	; [num]
	sta	a:boss_work_4
	rtl

brain_boss_attack_start_5:
	lda	#$0001
	sta	OBJ_Y_VEL,x
	rtl

brain_boss_attack_start_3:
	lda	#$FFFF	; [num]
	sta	OBJ_Y_VEL,x
	rtl

brain_boss_attack_start_2:
	lda	#$0002
	jsl	f:pick_target_player
	sty	a:boss_work_4
	lda	#$008F
	ldy	#$0500
	jsr	a:brain_boss_fill_slots
	lda	#$0001
	sta	$38,x
	stz	$36,x
	lda	#$0120
	sta	a:boss_work_3
	rtl

brain_boss_attack_start_6:
	lda	#$0090
	phx
	jsr	a:brain_boss_spawn_minion
	lda	#$3400
	sta	$02,x
	stz	$16,x
	plx
	rtl

brain_boss_attack_start_1:
	stz	OBJ_TIMER,x
	clc
	lda	a:boss_work_7
	adc	#$0100
	sta	a:boss_work_7
	lda	#$0002
	sta	OBJ_X_VEL,x
	rtl

brain_boss_attack_start_4:
	lda	#$0092
	ldy	#$0580
	jsr	a:brain_boss_fill_slots
	lda	#$8000	; [num]
	sta	a:obj_slots+4*OBJ_SIZE+$3A
	sta	a:obj_slots+9*OBJ_SIZE+$3A
	lda	#$0001
	sta	a:obj_slots+8*OBJ_SIZE+$3A
	sta	a:obj_slots+13*OBJ_SIZE+$3A
	lda	#$0080
	sta	a:boss_work_2
	sta	a:boss_work_4
	lda	#$00D0
	sta	$3E,x
	stz	a:boss_work_3
	lda	a:boss_work_7
	adc	#$0060
	sta	a:boss_work_7
	rtl

brain_boss_attack_start_7:
	lda	difficulty
	cmp	#$0004
	bne	@return
	lda	#$0300
	sta	a:boss_work_7
@return:
	rtl

; Object type $94. Stage 6, brain_boss: cluster of blue orbs gathering on the
; brain.
update_brain_boss_orb_cluster:
	lda	a:boss_work_4
	cmp	#$0002
	beq	loc_1DC62E
	lda	a:boss_work_3
	cmp	#$0030
	bcc	loc_1DC62C
	lda	OBJ_HIT,x
	beq	loc_1DC629
	lda	#$0001
	sta	a:boss_work_4
	sta	OBJ_HP,x
loc_1DC629:
	lda	a:boss_work_3
loc_1DC62C:
	bra	loc_1DC687
loc_1DC62E:
	lda	OBJ_FLAGS,x
	cmp	#$0030
	bne	loc_1DC65C
	dec	$30,x
	bpl	loc_1DC63F
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl
loc_1DC63F:
	lda	stage_frame_counter
	bit	#$0004
	bne	loc_1DC64B
	lda	$3A,x
	sta	OBJ_SPRITE,x
	rtl
loc_1DC64B:
	stz	OBJ_SPRITE,x
	rtl

; Object type $8B. Stage 6, brain_boss (hard): a ring of 16 orbs that bursts
; out of the brain.
update_brain_boss_orb_ring:
	lda	a:clear_enemies_timer
	bne	loc_1DC65C
	lda	a:boss_work_7
	bmi	loc_1DC65C
	lda	OBJ_HP,x
	bpl	loc_1DC674
loc_1DC65C:
	lda	#$0004
	sta	a:shake_timer
	jsr	a:brain_orb_set_velocity
	lda	#$0030
	jsl	f:queue_sound
	lda	#.loword(anim_05C4CE)
	txy
	jml	f:make_effect_object
loc_1DC674:
	lda	a:boss_work_3
	cpx	#$0500
	bcc	loc_1DC687
	clc
	adc	a:boss_work_4
	eor	#$FFFF
	clc
	adc	#$0020
loc_1DC687:
	pha
	jsr	a:brain_orb_angle
	ply
	jsl	f:polar_to_xy
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	adc	zp_08
	sta	OBJ_X,x
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	adc	#$FFE4
	adc	zp_0A
	sta	OBJ_Y,x
	rtl

; Object type $8C. Stage 6, brain_boss: chain of red links swung from the
; brain.
update_brain_boss_chain:
	lda	a:clear_enemies_timer
	beq	loc_1DC6AF
	brl	loc_1DC7C9
loc_1DC6AF:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_brain_boss_chain_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_brain_boss_chain_states:
	.addr	brain_boss_chain_state_00
	.addr	brain_boss_chain_state_01
	.addr	brain_boss_chain_state_02
	.addr	brain_boss_chain_state_03

brain_boss_chain_state_00:
	inc	OBJ_STATE,x
	lda	#$0090
	sta	OBJ_Y,x
	lda	#$003E
	sta	$32,x
	lda	#$0000
	sta	$34,x
	stz	$36,x
	lda	#.loword(metasprite_06C569)
	sta	zp_08
	lda	#$3E00
	sta	zp_0A
	lda	#$0008
	sta	zp_0C
	lda	#$FFF8	; [num]
	sta	zp_0E
	lda	#$403C
	sta	zp_10
	stz	zp_00
	lda	#$000A
	sta	zp_04
	lda	#$000C
	ldy	#$0340
	jml	f:loc_01A41C

brain_boss_chain_state_02:
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	sec
	sbc	OBJ_X,x
	bpl	loc_1DC712
	eor	#$FFFF
loc_1DC712:
	cmp	#$0004
	bcs	loc_1DC749
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	adc	#$FFE4
	sec
	sbc	OBJ_Y,x
	bpl	loc_1DC72A
	eor	#$FFFF
loc_1DC72A:
	cmp	#$0004
	bcs	loc_1DC749
	inc	OBJ_STATE,x
	lda	#$0070
	sta	OBJ_TIMER,x
	lda	#$0180
	sta	OBJ_X,x
	jml	f:trail_pass_to_next

brain_boss_chain_state_01:
	lda	a:boss_work_6
	cmp	#$0005
	bne	loc_1DC749
	inc	OBJ_STATE,x
loc_1DC749:
	lda	#$0001
	sta	a:shake_continuous
	lda	OBJ_X,x
	bmi	loc_1DC761
	cmp	#$0020
	bcc	loc_1DC761
	cmp	#$00E0
	bcc	loc_1DC765
	stz	$36,x
	bra	loc_1DC765
loc_1DC761:
	inc	$36,x
	inc	$36,x
loc_1DC765:
	lda	$36,x
	bne	loc_1DC783
	lda	OBJ_X_VEL,x
	bpl	loc_1DC772
	cmp	#$FFFC	; [num]
	bcc	loc_1DC79B
loc_1DC772:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$3000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	bra	loc_1DC79B
loc_1DC783:
	lda	OBJ_X_VEL,x
	bmi	loc_1DC78C
	cmp	#$0004
	bcs	loc_1DC79B
loc_1DC78C:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$3000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
loc_1DC79B:
	lda	$34,x
	inc	a
	inc	a
	and	#$003E
	sta	$34,x
	tay
	lda	a:enemy_bullet_speeds_hard_y_sub,y
	asl	a
	sta	zp_00
	lda	a:enemy_bullet_speeds_hard,y
	rol	a
	sta	zp_02
	clc
	lda	OBJ_Y_SUB,x
	adc	zp_00
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	adc	zp_02
	sta	OBJ_Y,x
	jml	f:trail_pass_to_next

brain_boss_chain_state_03:
	dec	OBJ_TIMER,x
	bpl	loc_1DC7D2
	inc	a:obj_slots+28*OBJ_SIZE+OBJ_STATE
loc_1DC7C9:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	jml	f:delete_trail_chain
loc_1DC7D2:
	jml	f:trail_pass_to_next

; Object type $8E. Stage 6, brain_boss (hard): spiked orbs around the brain
; (not identified exactly).
update_enemy_type_8E:
	lda	OBJ_Y,x
	cmp	#$00B4
	bcc	loc_1DC7F1
	lda	#$0030
	jsl	f:queue_sound
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_1DC7F1:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$3000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $8F. Stage 6, brain_boss: glowing orbs thrown by the brain (not
; identified exactly).
update_enemy_type_8F:
	lda	a:clear_enemies_timer
	bne	loc_1DC835
	lda	a:boss_work_3
	cmp	#$00F0
	bcc	loc_1DC822
	bne	loc_1DC817
	lda	#$001C
	sta	OBJ_FLAGS,x
	bra	loc_1DC81B
loc_1DC817:
	lda	stage_frame_odd
	beq	loc_1DC81E
loc_1DC81B:
	lda	#.loword(metasprite_06C536)
loc_1DC81E:
	sta	OBJ_SPRITE,x
	bra	loc_1DC847
loc_1DC822:
	cmp	#$0002
	bcc	loc_1DC835
	ldy	a:boss_work_4
	lda	a:$0016,y
	beq	loc_1DC835
	bmi	loc_1DC835
	lda	OBJ_HP,x
	bpl	loc_1DC847
loc_1DC835:
	jsr	a:brain_orb_set_velocity
	lda	#$0030
	jsl	f:queue_sound
	lda	#.loword(anim_05C4CE)
	txy
	jml	f:make_effect_object
loc_1DC847:
	jsr	a:brain_orb_angle
	ldy	a:boss_work_3
	cpy	#$0040
	bcc	loc_1DC855
	ldy	#$0040
loc_1DC855:
	jsl	f:polar_to_xy
	ldy	a:boss_work_4
	clc
	lda	a:$1312,y
	adc	zp_08
	sta	OBJ_X,x
	clc
	lda	a:$1314,y
	adc	zp_0A
	sta	OBJ_Y,x
	rtl

; Object type $90. Stage 6, brain_boss: eyeballs (12 HP) thrown by the brain.
update_brain_boss_eyeball:
	lda	OBJ_HP,x
	bmi	loc_1DC87B
	lda	a:clear_enemies_timer
	bne	loc_1DC87B
	lda	a:boss_work_7
	bpl	loc_1DC88A
loc_1DC87B:
	lda	#$0030
	jsl	f:queue_sound
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
loc_1DC88A:
	lda	OBJ_STATE,x
	bne	loc_1DC8DE
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	sta	OBJ_X,x
	sta	zp_FC
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	adc	#$FFE0
	sta	OBJ_Y,x
	sta	zp_FE
	phx
	lda	stage_frame_counter
	bit	#$001F
	bne	loc_1DC8DC
	lda	#$0090
	jsr	a:brain_boss_spawn_minion
	bcs	loc_1DC8DC
	inc	$12,x
	lda	zp_FC
	sta	$0A,x
	lda	zp_FE
	sta	$0E,x
	stz	$30,x
	lda	difficulty
	lsr	a
	sta	$06,x
	clc
	lda	rng_lo
	and	#$0001
	adc	#$0001
	bit	#$0001
	bne	loc_1DC8D7
	eor	#$FFFF
	inc	a
loc_1DC8D7:
	sta	$1A,x
	jsr	a:brain_eyeball_random_jump
loc_1DC8DC:
	plx
	rtl
loc_1DC8DE:
	lda	OBJ_Y_VEL,x
	bmi	loc_1DC902
	lda	OBJ_Y,x
	bmi	loc_1DC902
	cmp	#$00B0
	bcc	loc_1DC902
	jsr	a:brain_eyeball_random_jump
	lda	$30,x
	bne	loc_1DC902
	lda	OBJ_X_VEL,x
	eor	#$FFFF
	inc	a
	sta	OBJ_X_VEL,x
	inc	$30,x
	lda	#$0002
	sta	a:shake_timer
loc_1DC902:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$3C00
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
	rtl

; Object type $91. Stage 6, brain_boss: eye pods rolling on the floor.
update_brain_boss_rolling_eye:
	lda	a:clear_enemies_timer
	bne	loc_1DC91C
	lda	a:boss_work_7
	bpl	loc_1DC924
loc_1DC91C:
	txy
	lda	#.loword(anim_05C672)
	jml	f:make_effect_object
loc_1DC924:
	lda	$3A,x
	beq	loc_1DC960
	lda	OBJ_X,x
	bpl	loc_1DC931
	cmp	#$FF80	; [num]
	bcc	loc_1DC91C
loc_1DC931:
	lda	$38,x
	cmp	#$FFC0	; [num]
	bne	loc_1DC957
	dec	OBJ_TIMER,x
	bpl	@return
	lda	#$0040
	sta	$38,x
	sec
	lda	OBJ_X,x
	sbc	$36,x
	inc	a
	sta	OBJ_X,x
	lda	a:difficulty
	lsr	a
	and	#$0002
	tay
	lda	a:brain_boss_rolling_eye_delays,y
	sta	OBJ_TIMER,x
@return:
	rtl
loc_1DC957:
	sec
	lda	$38,x
	sbc	#$0004
	sta	$38,x
	rtl
loc_1DC960:
	ldy	$38,x
	lda	a:$0016,y
	beq	loc_1DC91C
	lda	a:$0038,y
	ldy	$36,x
	jsl	f:polar_to_xy
	ldy	$38,x
	clc
	lda	a:$000A,y
	adc	zp_08
	sta	OBJ_X,x
	clc
	lda	a:$000E,y
	adc	zp_0A
	sta	OBJ_Y,x
	rtl

; Object type $92. Stage 6, brain_boss: arch of blue orbs forming arms around
; the brain.
update_brain_boss_orb_arch:
	lda	a:clear_enemies_timer
	bne	loc_1DC98D
	lda	a:boss_work_7
	bpl	loc_1DC995
loc_1DC98D:
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
loc_1DC995:
	lda	a:boss_work_2
	ldy	$3A,x
	bmi	loc_1DC9CA
	cpx	#$0440
	bcs	loc_1DC9A5
	clc
	adc	#$FFE0
loc_1DC9A5:
	clc
	adc	#$0010
	sta	a:boss_work_2
	ldy	a:boss_work_3
	jsl	f:polar_to_xy
	txa
	clc
	adc	#$FFC0
	tay
	clc
	lda	a:$000A,y
	adc	zp_08
	sta	OBJ_X,x
	clc
	lda	a:$000E,y
	adc	zp_0A
	sta	OBJ_Y,x
	rtl
loc_1DC9CA:
	lda	a:boss_work_4
	cpx	#$0440
	bcc	loc_1DC9D8
	clc
	adc	a:obj_slots+28*OBJ_SIZE+$3E
	bra	loc_1DC9DC
loc_1DC9D8:
	sec
	sbc	a:obj_slots+28*OBJ_SIZE+$3E
loc_1DC9DC:
	and	#$00FF
	sta	a:boss_work_2
	ldy	#$0014
	jsl	f:polar_to_xy
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	adc	zp_08
	sta	OBJ_X,x
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	adc	#$FFE8
	adc	zp_0A
	sta	OBJ_Y,x
	rtl

; Object type $93. Stage 6, brain_boss: blue orbs scattered around the room.
update_brain_boss_orb:
	lda	a:boss_work_7
	bmi	loc_1DCA0A
	lda	a:clear_enemies_timer
	beq	loc_1DCA19
loc_1DCA0A:
	lda	#$0030
	jsl	f:queue_sound
	txy
	lda	#.loword(anim_05C4CE)
	jml	f:make_effect_object
loc_1DCA19:
	lda	OBJ_Y,x
	ldy	OBJ_Y_VEL,x
	bmi	loc_1DCA26
	cmp	#$00B8
	bcc	loc_1DCA38
	bra	loc_1DCA2B
loc_1DCA26:
	cmp	#$0020
	bcs	loc_1DCA38
loc_1DCA2B:
	tya
	eor	#$FFFF
	inc	a
	sta	OBJ_Y_VEL,x
	lda	#$0002
	sta	a:shake_timer
loc_1DCA38:
	lda	OBJ_X,x
	ldy	OBJ_X_VEL,x
	bmi	loc_1DCA45
	cmp	#$00F0
	bcc	loc_1DCA51
	bra	loc_1DCA4A
loc_1DCA45:
	cmp	#$0008
	bcs	loc_1DCA51
loc_1DCA4A:
	tya
	eor	#$FFFF
	inc	a
	sta	OBJ_X_VEL,x
loc_1DCA51:
	rtl

; Fills the slots from $0300 up to Y with objects of type A
; (brain_boss_init_minion), numbering them in OBJ_TIMER.
brain_boss_fill_slots:
	sta	zp_02
	sty	zp_04
	phx
	stz	zp_00
	ldx	#$0300
@loop:
	jsr	a:brain_boss_init_minion
	lda	zp_00
	sta	$24,x
	inc	zp_00
	inc	zp_00
	clc
	txa
	adc	#$0040
	tax
	cmp	zp_04
	bcc	@loop
	plx
	rts

brain_boss_spawn_minion:
	pha
	jsl	f:find_free_slot
	pla
	bcs	loc_1DCAC8
	bra	loc_1DCA7F

; Slot X becomes an object of type zp_02 at the brain's mouth (slot $0900 x
; + $1C), HP 10 + difficulty, 8x8 hitbox.
brain_boss_init_minion:
	lda	zp_02
loc_1DCA7F:
	sta	OBJ_TYPE,x
	stz	OBJ_STATE,x
	stz	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_X_VEL_SUB,x
	stz	OBJ_X_VEL,x
	stz	OBJ_Y_VEL_SUB,x
	stz	OBJ_Y_VEL,x
	clc
	lda	difficulty
	adc	#$000A
	sta	OBJ_HP,x
	lda	#$0008
	sta	OBJ_HITBOX_W,x
	lda	#$FFF8	; [num]
	sta	OBJ_HITBOX_H,x
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	sta	OBJ_X,x
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	adc	#$FFE4
	sta	OBJ_Y,x
	lda	a:boss_work_0
	asl	a
	tay
	lda	a:brain_boss_minion_flags,y
	sta	OBJ_FLAGS,x
	lda	a:brain_boss_minion_sprites,y
	sta	OBJ_SPRITE,x
	lda	a:brain_boss_minion_attrs,y
	sta	OBJ_ATTR,x
	clc
loc_1DCAC8:
	rts

brain_orb_set_velocity:
	jsr	a:brain_orb_angle
	jsr	a:brain_orb_angle
	lsr	a
	and	#$007E
	tay
	lda	a:vel8_y,y
	sta	OBJ_Y_VEL,x
	lda	a:vel8_x,y
	sta	OBJ_X_VEL,x
	lda	a:vel8_y_sub,y
	sta	OBJ_Y_VEL_SUB,x
	lda	a:vel8_x_sub,y
	sta	OBJ_X_VEL_SUB,x
	rts

brain_orb_angle:
	lda	OBJ_TIMER,x
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$0020
	clc
	adc	a:boss_work_2
	cpx	#$0500
	bcc	loc_1DCB00
	clc
	adc	#$0010
loc_1DCB00:
	and	#$00FF
	rts

brain_boss_oscillate:
	lda	$36,x
	bne	loc_1DCB21
	lda	$34,x
	bmi	loc_1DCB10
	cmp	zp_00
	bcs	loc_1DCB38
loc_1DCB10:
	clc
	lda	$32,x
	adc	#$1000
	sta	$32,x
	lda	$34,x
	adc	#$0000
	sta	$34,x
	bra	loc_1DCB38
loc_1DCB21:
	lda	$34,x
	bpl	loc_1DCB29
	cmp	zp_02
	bcc	loc_1DCB38
loc_1DCB29:
	sec
	lda	$32,x
	sbc	#$1000
	sta	$32,x
	lda	$34,x
	sbc	#$0000
	sta	$34,x
loc_1DCB38:
	clc
	lda	$32,x
	adc	$30,x
	sta	$30,x
	lda	$34,x
	adc	a:boss_work_2
	sta	a:boss_work_2
	rts

; Grows and shrinks the brain (field $36 between $120 and $14B) and builds
; its line HDMA table (brain_boss_build_hdma).
brain_boss_pulse:
	lda	$36,x
	ldy	$34,x
	beq	loc_1DCB56
	inc	a
	cmp	#$014B
	bcc	loc_1DCB64
	bra	loc_1DCB5C
loc_1DCB56:
	dec	a
	cmp	#$0120
	bcs	loc_1DCB64
loc_1DCB5C:
	pha
	tya
	eor	#$0001
	sta	$34,x
	pla
loc_1DCB64:
	sta	$36,x

brain_boss_build_hdma:
	sec
	lda	a:bg2_y
	sta	zp_00
	and	#$01FE
	sbc	#$00A0
	tay
	lda	$36,x
	jsl	f:fill_line_hdma_table
	rts

brain_boss_sway_x:
	lda	OBJ_X,x
	bmi	loc_1DCB8C
	cmp	#$0040
	bcc	loc_1DCB8C
	cmp	#$0088
	bcc	loc_1DCB91
	stz	$38,x
	bra	loc_1DCB91
loc_1DCB8C:
	lda	#$0001
	sta	$38,x
loc_1DCB91:
	lda	$38,x
	bne	loc_1DCBAE
	lda	OBJ_X_VEL,x
	bpl	loc_1DCB9E
	cmp	#$FFFF	; [num]
	bcc	loc_1DCBC6
loc_1DCB9E:
	sec
	lda	OBJ_X_VEL_SUB,x
	sbc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	sbc	#$0000
	sta	OBJ_X_VEL,x
	rts
loc_1DCBAE:
	lda	OBJ_X_VEL,x
	bmi	loc_1DCBB7
	cmp	#$0001
	bcs	loc_1DCBC6
loc_1DCBB7:
	clc
	lda	OBJ_X_VEL_SUB,x
	adc	#$1000
	sta	OBJ_X_VEL_SUB,x
	lda	OBJ_X_VEL,x
	adc	#$0000
	sta	OBJ_X_VEL,x
loc_1DCBC6:
	rts

; (no caller found; decoded because it follows the end of a routine)
brain_boss_sway_y_default:
	; (not executed in the CDL traces)
	lda	#$0040
	sta	zp_00
	lda	#$0080
	sta	zp_02

brain_boss_sway_y:
	lda	OBJ_Y,x
	bmi	loc_1DCBE1
	cmp	zp_00
	bcc	loc_1DCBE1
	cmp	zp_02
	bcc	loc_1DCBE6
	stz	$3E,x
	bra	loc_1DCBE6
loc_1DCBE1:
	lda	#$0001
	sta	$3E,x
loc_1DCBE6:
	lda	$3E,x
	bne	loc_1DCC03
	lda	OBJ_Y_VEL,x
	bpl	loc_1DCBF3
	cmp	#$FFFF	; [num]
	bcc	loc_1DCC1B
loc_1DCBF3:
	sec
	lda	OBJ_Y_VEL_SUB,x
	sbc	#$1800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	sbc	#$0000
	sta	OBJ_Y_VEL,x
	rts
loc_1DCC03:
	lda	OBJ_Y_VEL,x
	bmi	loc_1DCC0C
	cmp	#$0001
	bcs	loc_1DCC1B
loc_1DCC0C:
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$1800
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_1DCC1B:
	rts

queue_brain_boss_tiles:
	lda	#$0002
	sta	zp_02
	lda	#$0010
	sta	zp_08
	lda	#$4C0C
	phx
	jsl	f:queue_vram_blocks
	plx
	rts

brain_boss_launch_from_mouth:
	clc
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_X
	adc	#$001C
	sta	a:$000A,y
	lda	a:obj_slots+28*OBJ_SIZE+OBJ_Y
	sta	a:$000E,y
	lda	rng_lo
	and	#$0003
	clc
	adc	#$FFFE
	sta	a:$001A,y
	lda	rng_hi
	sta	a:$0018,y
	lda	#$FFFE	; [num]
	sta	a:$001E,y
	rts

brain_boss_spawn_orb_clusters:
	phx
	lda	difficulty
	bne	loc_1DCC65
	; (not executed in the CDL traces)
	ldx	#$0400
	lda	#$0000
	bra	loc_1DCC6D
loc_1DCC65:
	ldx	#$0300
	lda	rng_lo
	and	#$000E
loc_1DCC6D:
	sta	zp_00
loc_1DCC6F:
	lda	#OBJT_BRAIN_BOSS_ORB_CLUSTER
	sta	$10,x
	lda	#$4031
	sta	$16,x
	lda	#$0008
	sta	$28,x
	lda	#$FFF8	; [num]
	sta	$2A,x
	lda	#$0058
	sta	$30,x
	stz	$06,x
	lda	zp_00
	and	#$000E
	tay
	lda	a:brain_boss_minion_sprites,y
	sta	$00,x
	sta	$3A,x
	lda	a:brain_boss_minion_attrs,y
	sta	$02,x
	sty	$24,x
	inc	zp_00
	inc	zp_00
	lda	difficulty
	bne	loc_1DCCAA
	; (not executed in the CDL traces)
	inc	zp_00
	inc	zp_00
loc_1DCCAA:
	lda	zp_00
	cmp	#$0010
	bcc	loc_1DCCB3
	stz	zp_00
loc_1DCCB3:
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0500
	bcc	loc_1DCC6F
	plx
	rts

brain_boss_random_spin:
	lda	rng_lo
	and	#$0003
	clc
	adc	#$0005
	bit	#$0004
	bne	loc_1DCCD1
	eor	#$FFFF
loc_1DCCD1:
	sta	$3E,x
	rts

brain_eyeball_random_jump:
	clc
	lda	rng_hi
	and	#$0001
	adc	#$FFF9
	sta	OBJ_Y_VEL,x
	rts
