; topdown/stage_play.asm -- Top-down stages: gameplay (part 1)
; Bank $02, $02:8E33-$02:DDC5. Included by main.asm in segment BANK02.
;
; Players, objects and map handling of the top-down stages, reached from the
; state handlers in topdown/stage_states.asm: the players and their weapons,
; the enemy generators and enemies (tbl_td_enemy_types, TDT_*), items
; (tbl_td_item_types, TDI_*), map objects and the stage 2 boss
; (tbl_map_object_types, TDMT_*), shots (tbl_topdown_shot_types, TDS_*),
; the tile attribute map (TDA_*), the collisions and the map events.

; Copies each joypad into its player's block (p1_td_joy_held ...) and
; runs update_topdown_player for $0EC0 and $0F00.
update_topdown_players:
	lda	joy1_held
	sta	a:p1_td_joy_held
	lda	joy1_pressed
	sta	a:p1_td_joy_pressed
	ldx	#$0EC0
	jsl	f:update_topdown_player
	lda	joy2_held
	sta	a:p2_td_joy_held
	lda	joy2_pressed
	sta	a:p2_td_joy_pressed
	ldx	#$0F00

; Player X ($0EC0 / $0F00): state from tbl_topdown_player_states, chosen
; from the buttons (L+R, fire, D-pad) unless an action runs (+$0640).
update_topdown_player:
	lda	$12,x
	bne	loc_028E58
	brl	td_player_state_inactive
loc_028E58:
	lda	a:$0648,x
	beq	loc_028E70
	dec	a:$0648,x
	bne	loc_028E6A
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0002
loc_028E6A:
	and	#$0002
	lsr	a
	sta	$00,x
loc_028E70:
	lda	$2C,x
	beq	loc_028E77
	brl	td_player_state_falling
loc_028E77:
	lda	$06,x
	bpl	loc_028E7E
.if CHEAT_INVINCIBLE
	stz	$06,x	; cheat: the hit (td_p1_hp = $FFFF) is undone
.else
	brl	td_player_state_dying
.endif
loc_028E7E:
.if CHEAT_DEBUG_KEYS
	jsr	a:td_debug_cheat_buttons
.endif
	jsr	a:td_update_turn_speed
	jsr	a:td_update_fire_timer
	jsr	a:td_set_spin_direction
	jsr	a:td_check_smart_bomb
	lda	a:$0640,x
	beq	loc_028E92
	brl	loc_028EC0
loc_028E92:
	jsr	a:td_check_turn_buttons_both
	bcc	loc_028E9A
	brl	td_player_state_turn_buttons
loc_028E9A:
	stz	a:$10CE,x
	lda	a:$066C,x
	bit	zp_92
	beq	loc_028EA7
	brl	td_player_state_jump
loc_028EA7:
	bit	#$0F00
	beq	loc_028EAF
	brl	td_player_state_walk
loc_028EAF:
	bit	zp_96
	beq	loc_028EB6
	brl	td_player_state_walk
loc_028EB6:
	bit	zp_94
	beq	loc_028EBD
	brl	td_player_state_walk
loc_028EBD:
	brl	td_player_state_stand
loc_028EC0:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_topdown_player_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_topdown_player_states:
	.addr	td_player_state_inactive
	.addr	td_player_state_stand
	.addr	td_player_state_stand_fire
	.addr	td_player_state_walk
	.addr	td_player_state_walk_fire
	.addr	td_player_state_jump
	.addr	td_player_state_turn_buttons
	.addr	td_player_state_spin_fire
	.addr	td_player_state_dying
	.addr	td_player_state_falling
loc_028EE3:
	stz	$00,x
	stz	$06,x
	stz	a:$0648,x
	stz	$16,x
	lda	#$0001
	sta	a:$10CC,x

; State 0: no player (no lives) or respawn: drop in at a start point.
td_player_state_inactive:
	lda	a:$10CA,x
	bne	loc_028F4B
	stz	a:$10CC,x
	stz	$12,x
	lda	a:title_menu_cursor
	beq	@return
	; (not executed in the CDL traces)
	dec	a
	bne	loc_028F0D
	lda	a:$10F4,x
	beq	loc_028F0D
	dec	a:$10F4,x
@return:
	rtl
loc_028F0D:
	; (not executed in the CDL traces)
	jsr	a:td_get_other_player
	lda	a:$002C,y
	sta	$2C,x
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$000E,y
	sta	$0E,x
	lda	a:$0004,y
	eor	#$0080
	sta	$04,x
	stz	$08,x
	stz	$0C,x
	lda	a:$0002,y
	and	#$3000
	bne	loc_028F36
	lda	#$2000
loc_028F36:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	loc_028F43
	lda	#$0A00
loc_028F43:
	and	#$CFFF
	ora	zp_FA
	sta	$02,x
	rtl
loc_028F4B:
	lda	#$0002
	sta	a:$0644,x
	lda	#$00C0
	sta	a:$0648,x
	lda	#$0001
	sta	$00,x
	lda	#$0003
	sta	$20,x
	lda	#$0004
	sta	$06,x
	lda	$02,x
	beq	loc_028F6E
	lda	$2C,x
	beq	loc_028F7B
loc_028F6E:
	lda	#$2800
	cpx	#$0EC0
	beq	loc_028F79
	lda	#$2A00
loc_028F79:
	sta	$02,x
loc_028F7B:
	stz	$2E,x
	stz	$16,x
	lda	a:inidisp_shadow
	sta	a:$10F4,x
	lda	a:$0654,x
	clc
	adc	a:$0658,x
	and	#$00FF
	sta	$04,x
	stz	a:$064A,x
	jsr	a:td_set_respawn_position
	lda	a:boss_centered_view
	bne	loc_028FA5
	lda	#$0100
	sta	a:$10D4,x
	sta	a:$10D6,x
loc_028FA5:
	stz	$2C,x
	stz	a:$10CE,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	stz	a:$0640,x
	lda	#$0001
	sta	$12,x
	rtl

; Y = the other player's slot.
td_get_other_player:
	; (not executed in the CDL traces)
	cpx	#$0EC0
	bne	loc_028FC4
	ldy	#$0F00
	rts
loc_028FC4:
	ldy	#$0EC0
	rts

; Puts a respawning player at the start point nearest to where it died.
td_set_respawn_position:
	lda	a:title_menu_cursor
	dec	a
	beq	loc_028FEE
	bpl	loc_028FF3
loc_028FD0:
	lda	$2C,x
	beq	td_respawn_none
	lda	a:topdown_map
	lsr	a
	phx
	asl	a
	tax
	lda	f:tbl_respawn_by_map,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_respawn_by_map:
	.addr	respawn_at_start_point_stage2
	.addr	td_respawn_none
	.addr	respawn_at_start_point_stage5
	.addr	td_respawn_none

; tbl_respawn_by_map entry of the stage 5 boss map: nothing to do.
td_respawn_none:
	rts
loc_028FEE:
	lda	$2C,x
	bne	loc_028FD0
	rts
loc_028FF3:
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_029036
	jsr	a:td_get_other_player
	lda	a:$10CA,y
	beq	loc_028FD0
	lda	a:$002C,y
	bne	loc_028FD0
	lda	a:$000A,y
	sta	$0A,x
	lda	a:$000E,y
	sta	$0E,x
	lda	a:$0004,y
	eor	#$0080
	sta	$04,x
	stz	$08,x
	stz	$0C,x
	lda	a:$0002,y
	and	#$3000
	bne	loc_029025
	lda	#$2000
loc_029025:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	loc_029032
	lda	#$0A00
loc_029032:
	ora	zp_FA
	sta	$02,x
loc_029036:
	rts

respawn_at_start_point_stage2:
	jsr	a:clamp_y_to_map
	xba
	and	#$0003
	asl	a
	asl	a
	sta	zp_FA
	jsr	a:clamp_x_to_map
	xba
	and	#$0003
	ora	zp_FA
	asl	a
	tay
	lda	a:start_points_x,y
	sta	$0A,x
	lda	a:start_points_y,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

; A = the object's y clamped to 0..$3FF.
clamp_y_to_map:
	lda	$0E,x
	bmi	loc_029066
	cmp	#$0400
	bpl	loc_02906A
	rts
loc_029066:
	lda	#$0000
	rts
loc_02906A:
	lda	#$03FF
	rts

; A = the object's x clamped to 0..$3FF.
clamp_x_to_map:
	lda	$0A,x
	bmi	loc_029078
	cmp	#$0400
	bpl	loc_02907C
	rts
loc_029078:
	; (not executed in the CDL traces)
	lda	#$0000
	rts
loc_02907C:
	lda	#$03FF
	rts

respawn_at_start_point_stage5:
	jsr	a:clamp_y_to_map
	xba
	and	#$0003
	asl	a
	asl	a
	sta	zp_FA
	jsr	a:clamp_x_to_map
	xba
	and	#$0003
	ora	zp_FA
	asl	a
	tay
	lda	a:start_points_x_stage5,y
	sta	$0A,x
	lda	a:start_points_y_stage5,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

; Turning speed (+$0644, 2 or 4) while L or R is held.
td_update_turn_speed:
	lda	a:$066C,x
	and	#$0030
	beq	loc_0290E1
	lda	a:$0642,x
	bit	#$00FF
	beq	loc_0290D2
	xba
	and	#$0030
	bit	a:$066E,x
	bne	loc_0290C4
	bit	a:$066C,x
	beq	loc_0290D2
	rts
loc_0290C4:
	xba
	ora	#$0008
	sta	a:$0642,x
	lda	#$0004
	sta	a:$0644,x
	rts
loc_0290D2:
	lda	a:$066E,x
	and	#$0030
	beq	loc_0290E7
	xba
	ora	#$0008
	sta	a:$0642,x
loc_0290E1:
	lda	#$0002
	sta	a:$0644,x
loc_0290E7:
	lda	a:$0642,x
	and	#$00FF
	beq	@return
	dec	a:$0642,x
@return:
	rts

; +$0646 counts the frames fire is held (0 when newly pressed); the weapons fire on some of them.
td_update_fire_timer:
	lda	a:$066E,x
	bit	button_fire
	beq	loc_0290FE
	stz	a:$0646,x
	rts
loc_0290FE:
	inc	a:$0646,x
	rts

; Carry set when both turn buttons (L and R) are held.
td_check_turn_buttons_both:
	lda	zp_94
	ora	zp_96
	sta	zp_FA
	and	a:$066C,x
	cmp	zp_FA
	beq	loc_029111
	clc
	rts
loc_029111:
	sec
	rts

; +$0656 = 0 or 2 by the turn button pressed last.
td_set_spin_direction:
	lda	#$0007
	cmp	$12,x
	beq	loc_02912F
	lda	a:$066E,x
	bit	zp_96
	bne	loc_02912C
	bit	zp_94
	beq	loc_02912F
	lda	#$0002
	sta	a:$0656,x
	rts
loc_02912C:
	stz	a:$0656,x
loc_02912F:
	rts

; (no caller found; decoded because it follows the end of a routine)
; Never called: with X held, pressed buttons change the weapons, the bombs
; (up to 9), the barrier ($FFFF) and the lives (up to 99) of the player.
; Probably a leftover debug feature.
td_debug_cheat_buttons:
	; (not executed in the CDL traces)
	lda	a:$066C,x
	bit	#$0040
	beq	loc_0291A4
	lda	a:$066E,x
	bit	#$0020
	beq	loc_02914E
	inc	a:$10C4,x
	lda	a:$10C4,x
	cmp	#$0006
	bcc	loc_02914E
	stz	a:$10C4,x
loc_02914E:
	lda	a:$066E,x
	bit	#$0010
	beq	loc_029164
	inc	a:$10C6,x
	lda	a:$10C6,x
	cmp	#$0006
	bcc	loc_029164
	stz	a:$10C6,x
loc_029164:
	lda	a:$066E,x
	bit	#$0080
	beq	loc_02917D
	inc	a:$10CC,x
	lda	a:$10CC,x
	cmp	#$0009
	bcc	loc_02917D
	lda	#$0009
	sta	a:$10CC,x
loc_02917D:
	lda	a:$066E,x
	bit	#$4000
	beq	loc_02918B
	lda	#$FFFF	; [num]
	sta	a:$10C8,x
loc_02918B:
	lda	a:$066E,x
	bit	#$8000
	beq	loc_0291A4
	inc	a:$10CA,x
	lda	a:$10CA,x
	cmp	#$0063
	bcc	loc_0291A4
	lda	#$0063
	sta	a:$10CA,x
loc_0291A4:
	rts

; A (button_bomb) with bombs left: sound $5A, starts the bomb (+$0090).
td_check_smart_bomb:
	lda	a:$066E,x
	bit	button_bomb
	beq	@return
	lda	a:$10CC,x
	beq	@return
	lda	a:$0090,x
	dec	a
	beq	@return
	lda	#$005A
	jsl	f:queue_sound
.if !CHEAT_INFINITE_BOMBS
	dec	a:$10CC,x
.endif
	lda	#$0001
	sta	a:$0090,x
	stz	a:$0092,x
@return:
	rts

; State 5 (B): a jump of 8 frames; the player is drawn bigger, enemy shots
; miss it (td_p1_vs_enemies), and Y+B at mid-jump fires (td_fire_jump_shot).
; Checked in the emulator.
td_player_state_jump:
	lda	#$0005
	cmp	$12,x
	beq	loc_0291DA
	sta	$12,x
	lda	#$0008
	sta	a:$0640,x
loc_0291DA:
	lda	a:$0640,x
	cmp	#$0004
	bne	loc_0291F5
	lda	a:$066C,x
	bit	#$8000
	beq	loc_0291F5
	bit	#$4000
	beq	loc_029202
	jsl	f:td_fire_jump_shot
	bra	loc_029202
loc_0291F5:
	dec	a:$0640,x
	bpl	loc_029202
	stz	a:$0640,x
	lda	#$0003
	sta	$12,x
loc_029202:
	jsl	f:td_set_jump_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_jump_anim:
	lda	$22,x
	bne	loc_029215
	inc	$22,x
	rtl
loc_029215:
	lda	#$0000
	ldy	a:$0640,x
	cpy	#$0004
	bne	loc_029223
	lda	#$0004
loc_029223:
	ora	a:$10DE,x
	tay
	lda	a:data_05D15E,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rtl

; State 1: standing.
td_player_state_stand:
	lda	a:$066C,x
	bit	button_fire
	bne	td_player_state_stand_fire
	lda	#$0001
	cmp	$12,x
	beq	loc_029243
	sta	$12,x
loc_029243:
	jsl	f:td_set_stand_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_stand_anim:
	lda	$22,x
	bne	loc_029256
	inc	$22,x
	rtl
loc_029256:
	ldy	a:$10DE,x
	lda	a:data_05D166,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rtl

; State 2: standing and firing.
td_player_state_stand_fire:
	lda	#$0002
	cmp	$12,x
	beq	loc_029270
	sta	$12,x
	stz	$24,x
loc_029270:
	jsl	f:td_set_stand_fire_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	jml	f:td_fire_forward

td_set_stand_fire_anim:
	inc	$24,x
	lda	$22,x
	bne	loc_029288
	inc	$22,x
	rtl
loc_029288:
	lda	$24,x
	and	#$0004
	ora	a:$10DE,x
	tay
	lda	a:data_05D16A,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rtl

; State 6: both turn buttons held (fire then spins, state 7).
td_player_state_turn_buttons:
	lda	#$0006
	cmp	$12,x
	beq	loc_0292BA
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0004
	sta	$24,x
	lda	#$0001
	sta	a:$0640,x
	stz	a:$064A,x
loc_0292BA:
	lda	$24,x
	beq	loc_0292C2
	dec	$24,x
	bra	loc_0292D3
loc_0292C2:
	stz	a:$0640,x
	jsr	a:td_check_turn_buttons_both
	bcs	loc_0292CC
	bra	loc_0292D3
loc_0292CC:
	lda	a:$066C,x
	bit	button_fire
	bne	td_player_state_spin_fire
loc_0292D3:
	jsl	f:td_set_turn_buttons_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_turn_buttons_anim:
	lda	$22,x
	bne	loc_0292E6
	inc	$22,x
	rtl
loc_0292E6:
	lda	#$0005
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rtl

; State 7: L+R+fire: spins 8 units a frame firing both weapons sideways.
td_player_state_spin_fire:
	lda	#$0007
	cmp	$12,x
	beq	loc_02930D
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0001
	sta	a:$0640,x
	sta	a:$064A,x
	sta	a:$065A,x
loc_02930D:
	jsr	a:td_check_turn_buttons_both
	bcc	loc_029319
	lda	a:$066C,x
	bit	button_fire
	bne	loc_02931C
loc_029319:
	stz	a:$065A,x
loc_02931C:
	lda	a:$065A,x
	bne	loc_029332
	lda	a:$0654,x
	clc
	adc	a:$0658,x
	and	#$00FF
	cmp	$04,x
	bne	loc_029332
	brl	td_player_state_turn_buttons
loc_029332:
	jsr	a:td_set_spin_fire_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	jsr	a:td_spin_player
	jmp	a:td_fire_spin_shots

td_set_spin_fire_anim:
	lda	$22,x
	bne	loc_029349
	inc	$22,x
	rts
loc_029349:
	lda	#$0006
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rts

; State 3: walking (D-pad, relative to the view).
td_player_state_walk:
	lda	a:$066C,x
	bit	button_fire
	bne	td_player_state_walk_fire
	lda	#$0003
	cmp	$12,x
	beq	loc_029365
	sta	$12,x
loc_029365:
	jsr	a:td_turn_player
	jsl	f:td_player_tile_collision
	jsr	a:td_walk_by_dpad
	jsr	a:td_keep_players_together
	jsr	a:td_set_walk_anim
	rtl

; State 4: walking and firing.
td_player_state_walk_fire:
	lda	#$0004
	cmp	$12,x
	beq	loc_02937F
	sta	$12,x
loc_02937F:
	jsr	a:td_turn_player
	jsl	f:td_player_tile_collision
	jsr	a:td_walk_by_dpad
	jsr	a:td_keep_players_together
	jsr	a:td_set_walk_anim
	jml	f:td_fire_forward

; State 8: hit: loses a life, sound $3F, spins and slows down; respawns after $80 frames.
td_player_state_dying:
	lda	#$0008
	cmp	$12,x
	beq	loc_0293B9
	pha
	jsr	a:topdown_lose_life
	pla
	sta	$12,x
	lda	#$003F
	jsl	f:queue_sound
	lda	#$0020
	jsl	f:set_velocity_from_angle
	stz	$24,x
	lda	#$0001
	sta	a:$064A,x
	stz	$16,x
loc_0293B9:
	lda	$24,x
	cmp	#$0010
	bcc	loc_0293D0
	cmp	#$0080
	bcc	loc_0293C8
	brl	loc_028EE3
loc_0293C8:
	jsl	f:td_halve_x_velocity
	jsl	f:td_halve_y_velocity
loc_0293D0:
	inc	$24,x
	jsl	f:td_spin_dying_player
	jsl	f:td_player_tile_collision
	jsl	f:move_topdown_object
	jsr	a:td_keep_players_together
	lda	$22,x
	bne	loc_0293E8
	inc	$22,x
	rtl
loc_0293E8:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	loc_0293F5
	lda	#$0004
loc_0293F5:
	ora	a:$10DE,x
	tay
	lda	a:data_05D172,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rtl

td_spin_dying_player:
	lda	$24,x
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	tay
	lda	$04,x
	clc
	adc	a:data_05D17A,y
	and	#$00FF
	sta	$04,x
	rtl

td_halve_x_velocity:
	lda	$1A,x
	cmp	$18,x
	bne	loc_029429
	cmp	#$FFFF	; [num]
	bne	loc_029429
	stz	$1A,x
	stz	$18,x
	rtl
loc_029429:
	lda	$1A,x
	asl	a
	ror	$1A,x
	ror	$18,x
	rtl

td_halve_y_velocity:
	lda	$1E,x
	cmp	$1C,x
	bne	loc_029441
	cmp	#$FFFF	; [num]
	bne	loc_029441
	stz	$1E,x
	stz	$1C,x
	rtl
loc_029441:
	lda	$1E,x
	asl	a
	ror	$1E,x
	ror	$1C,x
	rtl

; State 9 (+$2C set): loses a life, sound $43, spins while its view zooms
; in and fades out (probably a fall into a pit); respawns after $80 frames.
td_player_state_falling:
	lda	#$0009
	cmp	$12,x
	beq	loc_029477
	pha
	jsr	a:topdown_lose_life
	pla
	sta	$12,x
	lda	#$0043
	jsl	f:queue_sound
	stz	$24,x
	stz	a:$064A,x
	stz	$16,x
	lda	$02,x
	and	#$CFFF
	ora	#$1000
	sta	$02,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
loc_029477:
	lda	$24,x
	cmp	#$0010
	bcc	loc_029486
	cmp	#$0080
	bcc	loc_029486
	brl	loc_028EE3
loc_029486:
	inc	$24,x
	jsr	a:td_spin_falling_player
	jsl	f:td_player_tile_collision
	jsl	f:move_topdown_object
	jsr	a:td_keep_players_together
	jsr	a:zoom_in_falling_view
	jsr	a:td_set_falling_anim
	lda	a:title_menu_cursor
	beq	loc_0294A4
	dec	a
	bne	loc_0294B6
loc_0294A4:
	lda	$24,x
	cmp	#$0020
	bcc	loc_0294B6
	lsr	a
	bcs	loc_0294B6
	lda	a:$10F4,x
	beq	loc_0294B6
	dec	a:$10F4,x
loc_0294B6:
	rtl

td_set_falling_anim:
	lda	$22,x
	bne	loc_0294BE
	inc	$22,x
	rts
loc_0294BE:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	loc_0294CB
	lda	#$0004
loc_0294CB:
	ora	a:$10DE,x
	tay
	lda	a:data_05D18C,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rts

td_spin_falling_player:
	lda	$04,x
	clc
	adc	#$0002
	and	#$00FF
	sta	$04,x
	rts

zoom_in_falling_view:
	lda	a:title_menu_cursor
	beq	loc_0294EF
	dec	a
	bne	loc_029503
loc_0294EF:
	lda	a:$10D4,x
	sec
	sbc	#$0004
	sta	a:$10D4,x
	lda	a:$10D6,x
	sec
	sbc	#$0004
	sta	a:$10D6,x
loc_029503:
	rts

; Up/down: forward/backward along the view, left/right: sideways (vectors by view angle).
td_walk_by_dpad:
	ldy	a:$10CE,x
	bne	loc_029532
	jsr	a:td_get_walk_vectors
	lda	a:$066C,x
	bit	#$0800
	beq	loc_029519
	jsr	a:td_walk_forward
	bra	loc_029521
loc_029519:
	bit	#$0400
	beq	loc_029521
	jsr	a:td_walk_backward
loc_029521:
	lda	a:$066C,x
	bit	#$0100
	beq	loc_02952B
	bra	loc_029595
loc_02952B:
	bit	#$0200
	beq	loc_029532
	bra	loc_0295B1
loc_029532:
	rts

; Walking velocity for the player's view angle (tables in bank $07).
td_get_walk_vectors:
	lda	a:$0654,x
	asl	a
	tay
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	lda	a:td_walk_x_int,y
	sta	zp_1A
	lda	a:td_walk_x_frac,y
	sta	zp_18
	lda	a:td_walk_y_int,y
	sta	zp_1E
	lda	a:td_walk_y_frac,y
	sta	zp_1C
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts

td_walk_forward:
	lda	zp_18
	sta	$18,x
	lda	zp_1A
	sta	$1A,x
	lda	zp_1C
	sta	$1C,x
	lda	zp_1E
	sta	$1E,x
	jsl	f:move_topdown_object
	rts

td_walk_backward:
	sec
	lda	#$0000
	sbc	zp_18
	sta	$18,x
	lda	#$0000
	sbc	zp_1A
	sta	$1A,x
	sec
	lda	#$0000
	sbc	zp_1C
	sta	$1C,x
	lda	#$0000
	sbc	zp_1E
	sta	$1E,x
	jsl	f:move_topdown_object
	rts
loc_029595:
	sec
	lda	#$0000
	sbc	zp_1C
	sta	$18,x
	lda	#$0000
	sbc	zp_1E
	sta	$1A,x
	lda	zp_18
	sta	$1C,x
	lda	zp_1A
	sta	$1E,x
	jsl	f:move_topdown_object
	rts
loc_0295B1:
	lda	zp_1C
	sta	$18,x
	lda	zp_1E
	sta	$1A,x
	sec
	lda	#$0000
	sbc	zp_18
	sta	$1C,x
	lda	#$0000
	sbc	zp_1A
	sta	$1E,x
	jsl	f:move_topdown_object
	rts

; 2P-B: keeps the players within one screen of each other.
td_keep_players_together:
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	@return
	; (not executed in the CDL traces)
	jsr	a:td_get_other_player
	lda	a:$0012,y
	beq	@return
	jsr	a:td_pull_towards_other_player_x
	jsr	a:td_pull_towards_other_player_y
@return:
	rts

td_pull_towards_other_player_x:
	; (not executed in the CDL traces)
	lda	a:$000A,y
	sec
	sbc	#$0090
	cmp	$0A,x
	bpl	loc_0295FF
	clc
	adc	#$0120
	cmp	$0A,x
	bmi	loc_0295F8
	bne	loc_0295FE
loc_0295F8:
	dec	a
	sta	$0A,x
	stz	a:$0672,x
loc_0295FE:
	rts
loc_0295FF:
	inc	a
	sta	$0A,x
	stz	a:$0672,x
	rts

td_pull_towards_other_player_y:
	; (not executed in the CDL traces)
	lda	a:$000E,y
	sec
	sbc	#$0058
	cmp	$0E,x
	bpl	loc_029622
	clc
	adc	#$00B0
	cmp	$0E,x
	bmi	loc_02961B
	bne	loc_029621
loc_02961B:
	dec	a
	sta	$0E,x
	stz	a:$0672,x
loc_029621:
	rts
loc_029622:
	inc	a
	sta	$0E,x
	stz	a:$0672,x
	rts

td_set_walk_anim:
	inc	$24,x
	lda	$22,x
	bne	loc_029632
	inc	$22,x
	rts
loc_029632:
	lda	$24,x
	lsr	a
	and	#$000C
	ora	a:$10DE,x
	tay
	lda	a:data_05D194,y
	cmp	$20,x
	beq	@return
	sta	$20,x
	stz	$22,x
@return:
	rts

; L/R turn the player (and its view) by the turning speed.
td_turn_player:
	lda	a:$066C,x
	bit	zp_96
	bne	loc_029654
	bit	zp_94
	bne	loc_029660
	rts
loc_029654:
	lda	$04,x
	clc
	adc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts
loc_029660:
	lda	$04,x
	sec
	sbc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts

; Spin fire: angle +8 a frame.
td_spin_player:
	lda	a:$0656,x
	bne	loc_02967D
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rts
loc_02967D:
	; (not executed in the CDL traces)
	lda	$04,x
	sec
	sbc	#$0008
	and	#$00FF
	sta	$04,x
	rts

; Takes a life (dying, falling); loses the weapons as on the side-view stages.
topdown_lose_life:
	lda	$12,x
	cmp	#$0008
	beq	loc_0296B0
	cmp	#$0009
	beq	loc_0296B0
.if CHEAT_INFINITE_LIVES
	lda	a:$10CA,x	; cheat: the life is not taken
.else
	dec	a:$10CA,x
.endif
	bpl	loc_02969D
	; (not executed in the CDL traces)
	stz	a:$10CA,x
loc_02969D:
.if !CHEAT_KEEP_WEAPONS
	lda	a:$10C2,x
	beq	loc_0296A5
	stz	a:$10C6,x
loc_0296A5:
	lda	a:$10C0,x
	beq	loc_0296AD
	stz	a:$10C4,x
loc_0296AD:
.endif
	stz	a:$10C8,x
loc_0296B0:
	rts
; Spin fire: fires both weapons at +$40 and +$C0 from the player's angle.
td_fire_spin_shots:
	stz	zp_14
	lda	#$0040
	sta	zp_12
	lda	#$003C
	sta	zp_10
	ldy	#$001E
	jsl	f:fire_topdown_weapon
	lda	#$0002
	sta	zp_14
	lda	#$00C0
	sta	zp_12
	lda	#$00C4
	sta	zp_10
	ldy	#$001E
	bra	fire_topdown_weapon

; Fires the active weapon from the jump (muzzle $20 ahead).
td_fire_jump_shot:
	stz	zp_12
	ldy	a:$10DE,x
	sty	zp_14
	lda	a:data_05D1A8,y
	sta	zp_10
	ldy	#$0020
	bra	fire_topdown_weapon
; Fires the active weapon straight ahead.
td_fire_forward:
	stz	zp_12
	ldy	a:$10DE,x
	sty	zp_14
	lda	a:data_05D1A4,y
	sta	zp_10
	ldy	#$0018

; Fires weapon p1_weapon_1 (zp_14 = 0) or p1_weapon_2 (zp_14 = 2) of player X
; through tbl_topdown_weapons (WEAPON_* order).
fire_topdown_weapon:
	jsr	a:td_get_muzzle_position
	lda	a:$10C4,x
	ldy	zp_14
	beq	loc_029705
	lda	a:$10C6,x
loc_029705:
	phx
	asl	a
	tax
	lda	f:tbl_topdown_weapons,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_topdown_weapons:
	.addr	fire_td_default
	.addr	fire_td_spread
	.addr	fire_td_crush
	.addr	fire_td_homing
	.addr	fire_td_flame
	.addr	fire_td_laser

; zp_1C/zp_1E = player position + offset at angle (player angle + zp_12).
td_get_muzzle_position:
	lda	$04,x
	clc
	adc	zp_12
	and	#$00FF
	sta	zp_1A
	lda	$04,x
	clc
	adc	zp_10
	jsl	f:polar_to_xy
	lda	zp_08
	sta	zp_0C
	clc
	adc	$0A,x
	sta	zp_1C
	lda	zp_0A
	sta	zp_0E
	clc
	adc	$0E,x
	sta	zp_1E
	rts

fire_td_default:
	lda	a:$0646,x
	lsr	a
	bcs	@return
	jsl	f:td_find_free_shot_slot
	bcc	loc_029751
@return:
	rtl
loc_029751:
	lda	a:$0646,x
	and	#$0003
	bne	loc_029760
	lda	#$0004
	jsl	f:queue_sound
loc_029760:
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_DEFAULT
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	rtl

fire_td_spread:
	lda	a:$0646,x
	and	#$0003
	beq	loc_029785
loc_029784:
	rtl
loc_029785:
	jsl	f:td_find_free_shot_slot
	bcs	loc_029784
	lda	a:$0646,x
	and	#$0007
	bne	loc_02979A
	lda	#$0009
	jsl	f:queue_sound
loc_02979A:
	lda	#$0005
	sta	zp_18
@loop:
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_SPREAD
	sta	a:$0010,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	lda	rng_lo
	and	#$0008
	clc
	adc	zp_18
	asl	a
	phy
	tay
	lda	a:data_05D1AA,y
	ply
	clc
	adc	zp_1A
	and	#$00FF
	sta	a:$0004,y
	dec	zp_18
	beq	@return
	jsl	f:td_find_free_shot_slot
	bcc	@loop
@return:
	rtl

fire_td_homing:
	lda	a:$0646,x
	and	#$0003
	bne	@return
	jsl	f:td_find_free_shot_slot
	bcc	loc_0297E7
@return:
	rtl
loc_0297E7:
	lda	#$0008
	jsl	f:queue_sound
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_HOMING
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	rtl

fire_td_laser:
	jsl	f:td_find_free_shot_slot
	bcc	loc_029811
	rtl
loc_029811:
	lda	a:$0646,x
	and	#$000F
	bne	loc_029820
	lda	#$0005
	jsl	f:queue_sound
loc_029820:
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_LASER
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_10
	sta	a:$001A,y
	lda	zp_12
	sta	a:$000C,y
	rtl

fire_td_flame:
	jsl	f:td_find_flame_shot
	bcc	loc_029858
	jsl	f:td_find_free_shot_slot
	bcc	loc_029849
	; (not executed in the CDL traces)
	rtl
loc_029849:
	jsr	a:td_play_flame_sound
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_FLAME
	sta	a:$0010,y
loc_029858:
	jsr	a:td_play_flame_sound
	lda	zp_1A
	sta	a:$0014,y
	lda	zp_1C
	sta	a:$0008,y
	lda	zp_1E
	sta	a:$000C,y
	rtl

td_play_flame_sound:
	lda	a:$0646,x
	and	#$000F
	bne	@return
	lda	#$000A
	jsl	f:queue_sound
@return:
	rts

fire_td_crush:
	lda	a:$0646,x
	and	#$0001
	bne	@return
	jsl	f:td_find_three_shot_slots
	bcc	loc_02988A
@return:
	rtl
loc_02988A:
	lda	#$0007
	jsl	f:queue_sound
	lda	#$0000
	sta	a:$0012,y
	sta	a:$0000,y
	lda	#TDS_CRUSH
	sta	a:$0010,y
	lda	zp_1A
	sta	a:$0004,y
	lda	zp_1C
	sta	a:$000A,y
	lda	zp_1E
	sta	a:$000E,y
	lda	zp_02
	sta	a:$001A,y
	phy
	tay
	lda	#TDS_HIDDEN
	sta	a:$0010,y
	ply
	lda	zp_04
	sta	a:$001E,y
	phy
	tay
	lda	#TDS_HIDDEN
	sta	a:$0010,y
	ply
	rtl

; Y = a free shot slot of player X ($0480-$05BF, second weapon $05C0-$06FF;
; player 2 $0700/$0840); carry set when none.
td_find_free_shot_slot:
	lda	zp_14
	bne	loc_0298E5
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_0298E1
	ldy	#$0700
	lda	#$0840
loc_0298E1:
	sta	zp_FA
	bra	loc_0298F8
loc_0298E5:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_0298F6
	ldy	#$0840
	lda	#$0980
loc_0298F6:
	sta	zp_FA
loc_0298F8:
	lda	a:$0010,y
	bne	@next
	clc
	rtl
@next:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	loc_0298F8
	rtl

td_find_flame_shot:
	lda	zp_14
	bne	loc_029923
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_02991F
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
loc_02991F:
	sta	zp_FA
	bra	loc_029936
loc_029923:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_029934
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
loc_029934:
	sta	zp_FA
loc_029936:
	lda	a:$0010,y
	cmp	#$0007
	bne	@next
	lda	a:$0012,y
	cmp	#$000E
	bne	@next
	clc
	rtl
@next:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	loc_029936
	rtl

td_find_three_shot_slots:
	lda	zp_14
	bne	loc_02996C
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	loc_029968
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
loc_029968:
	sta	zp_FA
	bra	loc_02997F
loc_02996C:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	loc_02997D
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
loc_02997D:
	sta	zp_FA
loc_02997F:
	phx
	ldx	#$0006
@loop:
	lda	a:$0010,y
	bne	@next
	dex
	dex
	sty	$00,x
	bne	@next
	clc
	plx
	rtl
@next:
	tya
	clc
	adc	#$0020
	tay
	cpy	zp_FA
	bcc	@loop
	plx
	rtl

; Stage 2 enemy generator: alternating $200-frame periods, either a random
; enemy type (by difficulty) near a player when a slot of $0DC0-$0EBF is free,
; or type $0F when none is alive.
spawn_stage2_enemies:
	lda	stage_frame_counter
	bit	#$0200
	beq	loc_0299AB
	jsl	f:td_check_enemies_alive
	bcc	loc_0299CE
	rtl
loc_0299AB:
	jsl	f:td_find_free_enemy_slot
	bcc	loc_0299B2
loc_0299B1:
	rtl
loc_0299B2:
	jsr	a:td_place_enemy_near_player
	bcs	loc_0299B1
	ldy	difficulty
	lda	rng_lo
	and	a:td_spawn_type_masks,y
	beq	loc_0299C3
	lda	#$0002
loc_0299C3:
	tay
	lda	a:stage2_spawn_types,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
loc_0299CE:
	ldx	#$0DC0
	jsr	a:td_place_enemy_near_player
	bcs	@return
	lda	#TDT_CENTIPEDE
	sta	$10,x
	stz	$00,x
	stz	$2E,x
@return:
	rtl

; Stage 5 enemy generator (as spawn_stage2_enemies, type $0C).
spawn_stage5_enemies:
	lda	stage_frame_counter
	bit	#$0200
	beq	loc_0299EE
	jsl	f:td_check_enemies_alive
	bcc	loc_029A11
	rtl
loc_0299EE:
	jsl	f:td_find_free_enemy_slot
	bcc	loc_0299F5
loc_0299F4:
	rtl
loc_0299F5:
	jsr	a:td_place_enemy_near_player
	bcs	loc_0299F4
	ldy	difficulty
	lda	rng_lo
	and	a:td_spawn_type_masks,y
	beq	loc_029A06
	lda	#$0002
loc_029A06:
	tay
	lda	a:stage5_spawn_types,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
loc_029A11:
	ldx	#$0DC0
	jsr	a:td_place_enemy_near_player
	bcs	@return
	lda	#TDT_BUG_CENTIPEDE
	sta	$10,x
	stz	$00,x
	stz	$2E,x
@return:
	rtl

; Enemy X at a random offset from a player (td_pick_spawn_player).
td_place_enemy_near_player:
	jsr	a:td_pick_spawn_player
	bcs	@return
	lda	rng_lo
	and	#$00FF
	asl	a
	tay
	lda	a:td_spawn_offsets_x,y
	clc
	adc	zp_FC
	sta	$0A,x
	lda	a:td_spawn_offsets_y,y
	clc
	adc	zp_FE
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	jsl	f:td_enemy_tile_collision
@return:
	rts

; zp_FC/zp_FE = position of a living player (random in 2P); carry set if none.
td_pick_spawn_player:
	lda	a:title_menu_cursor
	bne	loc_029A61
	lda	a:p1_lives
	bne	loc_029A55
	; (not executed in the CDL traces)
	sec
	rts
loc_029A55:
	lda	a:td_p1_x
	sta	zp_FC
	lda	a:td_p1_y
	sta	zp_FE
	clc
	rts
loc_029A61:
	lda	zp_E9
	lsr	a
	bcs	loc_029A7E
loc_029A66:
	lda	a:p1_lives
	bne	loc_029A72
	; (not executed in the CDL traces)
	lda	a:p2_lives
	bne	loc_029A7E
	sec
	rts
loc_029A72:
	lda	a:td_p1_x
	sta	zp_FC
	lda	a:td_p1_y
	sta	zp_FE
	clc
	rts
loc_029A7E:
	lda	a:p2_lives
	bne	loc_029A8A
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	loc_029A66
	sec
	rts
loc_029A8A:
	lda	a:td_p2_x
	sta	zp_FC
	lda	a:td_p2_y
	sta	zp_FE
	clc
	rts

; zp_18/zp_1A = position of the living player nearest to object X (random
; when both are as near); carry set when no player is alive.
td_get_nearest_player:
	lda	a:title_menu_cursor
	bne	loc_029AA2
	lda	a:p1_lives
	bne	loc_029AE0
	; (not executed in the CDL traces)
	sec
	rtl
loc_029AA2:
	lda	a:p1_lives
	beq	loc_029AFF
	lda	a:p2_lives
	beq	loc_029AF8
	lda	a:td_p1_x
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:td_p1_y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:half_distance_squared
	sta	zp_18
	lda	a:td_p2_x
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:td_p2_y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:half_distance_squared
	cmp	zp_18
	bne	loc_029ADE
	lda	stage_frame_counter
	xba
	lsr	a
loc_029ADE:
	bcc	loc_029AEC
loc_029AE0:
	lda	a:td_p1_x
	sta	zp_18
	lda	a:td_p1_y
	sta	zp_1A
	clc
	rtl
loc_029AEC:
	lda	a:td_p2_x
	sta	zp_18
	lda	a:td_p2_y
	sta	zp_1A
	clc
	rtl
loc_029AF8:
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	loc_029AE0
	sec
	rtl
loc_029AFF:
	lda	a:p2_lives
	bne	loc_029AEC
	sec
	rtl

; A = angle from object X to the nearest player (td_get_nearest_player).
td_angle_to_nearest_player:
	jsl	f:td_get_nearest_player
	bcc	loc_029B0D
	; (not executed in the CDL traces)
	rtl
loc_029B0D:
	lda	zp_18
	sec
	sbc	$0A,x
	sta	zp_08
	lda	zp_1A
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	clc
	rtl

; Clears the $40-byte slot X.
clear_topdown_slot:
	phx
	phy
	phb
	lda	#$0000
	sta	f:$000000,x
	txy
	iny
	lda	#$003E
	mvn	#$00, #$00
	plb
	ply
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_topdown_slot_y:
	; (not executed in the CDL traces)
	phx
	phy
	phb
	tyx
	lda	#$0000
	sta	f:$000000,x
	iny
	lda	#$003E
	mvn	#$00, #$00
	plb
	ply
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
td_fill_trail_buffer:
	; (not executed in the CDL traces)
	phx
	phb
	ldx	#$1900
	sta	f:$7E0000,x
	txy
	iny
	iny
	lda	#$01FD
	mvn	#$7E, #$7E
	plb
	plx
	rtl

; (no caller found; decoded because it follows the end of a routine)
td_find_free_enemy_slot_any:
	; (not executed in the CDL traces)
	ldx	#$0D40
@loop:
	lda	$10,x
	bne	@next
	clc
	rtl
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
	rtl

; Y = the enemy slot a map object lets its enemy out into: $0D40 when player
; 1 is near (+$2E bit 4), $0D80 for player 2 (bit 5); carry set when it is
; in use or no player is near.
td_get_hatch_enemy_slot:
	lda	$2E,x
	bit	#$0010
	bne	loc_029B88
	bit	#$0020
	beq	loc_029B92
	ldy	#$0D80
	bra	loc_029B8B
loc_029B88:
	ldy	#$0D40
loc_029B8B:
	lda	a:$0010,y
	bne	loc_029B92
	clc
	rtl
loc_029B92:
	sec
	rtl

; X = a free slot in $0DC0-$0EBF; carry set when none.
td_find_free_enemy_slot:
	ldx	#$0DC0
@loop:
	lda	$10,x
	bne	@next
	clc
	rtl
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
	rtl

; Carry set when a slot of $0DC0-$0EBF is in use.
td_check_enemies_alive:
	phx
	ldx	#$0DC0
@loop:
	lda	$10,x
	beq	@next
	plx
	sec
	rtl
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
	plx
	clc
	rtl

; Y = a free enemy shot slot ($0300-$047F); carry set when none.
td_find_free_enemy_shot_slot:
	ldy	#$0300
@loop:
	lda	a:$0010,y
	bne	@next
	clc
	rtl
@next:
	tya
	clc
	adc	#$0020
	tay
	cpy	#$0480
	bcc	@loop
	rtl

; Y = a free item/effect slot ($0980-$0ABF); carry set when none.
td_find_free_item_slot:
	ldy	#$0980
@loop:
	lda	a:$0010,y
	bne	@next
	clc
	rtl
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0AC0
	bcc	@loop
	rtl

; Hit flash of a boss drawn in the Mode 7 layer: when +$2E bit 6 (hit) is
; set, fills the palette range zp_02 (zp_04 bytes) with white for 4 frames,
; then td_restore_boss_palette copies it back from zp_00 (bank $08).
td_flash_boss_palette_on_hit:
	lda	$2A,x
	beq	loc_029C04
	cmp	#$0004
	bne	loc_029BFA
	jsr	a:td_restore_boss_palette
loc_029BFA:
	dec	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_029C03:
	rtl
loc_029C04:
	lda	$2E,x
	bit	#$0040
	beq	loc_029C03
	and	#$FFBF
	sta	$2E,x
	lda	#$0004
	sta	$2A,x
	lda	#$0010
	jsl	f:queue_sound
	phx
	phb
	ldx	zp_02
	lda	#$7FFF
	sta	f:$7E0000,x
	txy
	iny
	iny
	lda	zp_04
	dec	a
	dec	a
	dec	a
	mvn	#$7E, #$7E
	plb
	plx
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	rtl

td_restore_boss_palette:
	phx
	phb
	ldx	zp_00
	ldy	zp_02
	lda	zp_04
	mvn	#^gfx_08, #$7E
	plb
	plx
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	rts

; Turns object X by A (at most) towards the nearest player; carry set when
; already facing it.
td_turn_towards_nearest_player:
	pha
	jsl	f:td_angle_to_nearest_player
	ply
	sty	zp_FA
	bcs	loc_029C7E
	sec
	sbc	$04,x
	beq	loc_029C7D
	bit	#$0080
	bne	loc_029C71
	lda	$04,x
	clc
	adc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
loc_029C71:
	lda	$04,x
	sec
	sbc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
loc_029C7D:
	sec
loc_029C7E:
	rtl

; Velocity A along the angle +$04, then move_topdown_object.
td_move_at_angle:
	jsl	f:set_velocity_from_angle

; Adds the velocity (+$18/+$1A, +$1C/+$1E) to the position (+$08/+$0A, +$0C/+$0E).
move_topdown_object:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rtl

; Stage 5 boss: runs the slots $0B40-$0EBF (claw, arm base, arm segments)
; with the enemy handlers (td_update_enemies from $0B40).
update_stage5_boss_arm:
	ldx	#$0B40
	bra	loc_029CA6

; Runs the enemies ($0D40-$0EBF): handler by type (tbl_td_enemy_types), animation, hit flash.
td_update_enemies:
	ldx	#$0D40
loc_029CA6:
	lda	$10,x
	beq	@next
	jsl	f:td_run_enemy_handler
	jsl	f:td_animate_enemy
	jsl	f:td_flash_enemy_on_hit
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_029CA6

; Type 0 / 7: nothing (also the end of td_update_enemies).
td_enemy_type_none:
	rtl

td_run_enemy_handler:
	lda	$10,x
	phx
	asl	a
	tax
	lda	f:tbl_td_enemy_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_enemy_types:
	.addr	td_enemy_type_none
	.addr	update_td_gunner
	.addr	update_td_runner
	.addr	update_td_centipede_unused
	.addr	update_td_centipede_segment
	.addr	update_td_crawler
	.addr	update_td_nest_crawler
	.addr	td_enemy_type_none
	.addr	update_td_explosion
	.addr	update_hatch_turret_spin
	.addr	update_stage5_boss_claw
	.addr	update_stage5_boss_arm_segment
	.addr	update_td_bug_centipede
	.addr	update_td_bug_centipede_segment
	.addr	update_td_centipede_bug
	.addr	update_td_centipede
	.addr	update_hatch_turret_aim
	.addr	update_hatch_turret_sweep
	.addr	update_td_spitter
	.addr	update_stage5_boss_arm_base

; TDT_EXPLOSION: an enemy turned into an explosion by td_start_explosion;
; freed when the animation ends or it is out of range.
update_td_explosion:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_explosion_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_explosion_states:
	.addr	td_start_explosion
	.addr	td_explosion_state_1

; Turns object X into TDT_EXPLOSION (the explosion animation).
td_start_explosion:
	lda	#TDT_EXPLOSION
	sta	$10,x
	lda	#$0009
	sta	$00,x
	lda	#.loword(td_anim_05D45A)
	sta	$28,x
	stz	$22,x
	stz	$16,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0001
	sta	$12,x
	rtl

td_explosion_state_1:
	lda	$2E,x
	bit	#$000C
	bne	loc_029D3B
	brl	clear_topdown_slot
loc_029D3B:
	lda	$28,x
	bne	@return
	jml	f:clear_topdown_slot
@return:
	rtl

; Steps the animation script at +$28 (entries of 3 words).
td_animate_enemy:
	ldy	$28,x
	beq	loc_029D6E
	dec	$22,x
	bmi	loc_029D6F
	bne	loc_029D6E
	tya
	clc
	adc	#$0006
@loop:
	tay
	lda	a:$0000,y
	bmi	@loop
	beq	loc_029D74
	sty	$28,x
loc_029D5D:
	sta	$22,x
	lda	a:$0002,y
	sta	$20,x
	lda	$02,x
	and	#$3000
	ora	a:$0004,y
	sta	$02,x
loc_029D6E:
	rtl
loc_029D6F:
	lda	a:$0000,y
	bne	loc_029D5D
loc_029D74:
	sta	$22,x
	sta	$28,x
	lda	a:$0002,y
	sta	$20,x
	lda	$02,x
	and	#$3000
	ora	a:$0004,y
	sta	$02,x
	rtl

; Hit flash: palette swapped to 3 for a frame when +$2E bit 6 is set.
td_flash_enemy_on_hit:
	lda	stage_frame_counter
	bit	#$0001
	bne	@return
	lda	$2A,x
	bne	loc_029DAC
	lda	$2E,x
	bit	#$0040
	beq	@return
	and	#$FFBF
	sta	$2E,x
	lda	$02,x
	sta	$2A,x
	and	#$3000
	ora	#$0600
	sta	$02,x
@return:
	rtl
loc_029DAC:
	lda	$2A,x
	sta	$02,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rtl

td_play_hit_sound:
	lda	$2A,x
	bne	@return
	lda	$2E,x
	bit	#$0040
	beq	@return
	lda	#$0010
	jsl	f:queue_sound
@return:
	rtl

; Turns one step towards the nearest player and walks forward ($0C).
td_walk_towards_nearest_player:
	jsr	a:td_get_angle_to_nearest_player
	bcs	loc_029DD5
	jsr	a:td_turn_one_step
loc_029DD5:
	jsr	a:td_enemy_step_forward
	rtl

td_get_angle_to_nearest_player:
	jsl	f:td_get_nearest_player
	bcc	loc_029DE0
	; (not executed in the CDL traces)
	rts
loc_029DE0:
	lda	zp_18
	sec
	sbc	$0A,x
	sta	zp_08
	lda	zp_1A
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sta	zp_10
	clc
	rts

td_turn_one_step:
	lda	zp_10
	sec
	sbc	$04,x
	xba
	and	#$FF00
	beq	loc_029E15
	bpl	loc_029E0D
	cmp	#$8000	; [num]
	bne	loc_029E16
	lda	rng_lo
	lsr	a
	bcs	loc_029E16
loc_029E0D:
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
loc_029E15:
	rts
loc_029E16:
	lda	$04,x
	dec	a
	and	#$00FF
	sta	$04,x
	rts

td_enemy_step_forward:
	lda	#$000C
	jsl	f:set_velocity_from_angle
	jsl	f:move_topdown_object
	jsl	f:td_enemy_tile_collision
	rts

; (no caller found; decoded because it follows the end of a routine)
td_turn_by_direction_unused:
	; (not executed in the CDL traces)
	lda	$3C,x
	bne	loc_029E3C
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
	rts
loc_029E3C:
	lda	$04,x
	dec	a
	and	#$00FF
	sta	$04,x
	rts

; Fires a TDS_ENEMY_BULLET from enemy X along its angle, Y pixels ahead
; (only when the enemy is on screen and a shot slot is free).
td_fire_enemy_bullet:
	lda	$2E,x
	bit	#$0003
	beq	@return
	phy
	jsl	f:td_find_free_enemy_shot_slot
	pla
	bcs	@return
	pha
	lda	#TDS_ENEMY_BULLET
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	pla
	phy
	tay
	lda	$04,x
	jsl	f:polar_to_xy
	ply
	lda	$0A,x
	clc
	adc	zp_08
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_0A
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	lda	$04,x
	sta	a:$0004,y
	phx
	phy
	tyx
	lda	#$0020
	jsl	f:set_velocity_from_angle
	ply
	plx
	lda	#$FFFF	; [num]
	sta	a:$0004,y
@return:
	rtl

; TDT_RUNNER, stage 2: an alien that walks towards the nearest player for
; up to $40 frames until it is on screen, then while it is in range.
; HP 0/2/4 (td_runner_hp). Spawned by spawn_stage2_enemies.
update_td_runner:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_runner_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_runner_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_runner_state_2
	.addr	td_runner_state_3
	.addr	td_runner_state_4

; State 0 shared by the walking enemies: freed if it appears on screen
; (+$2E bits 0-1), else cleared and on to state 1.
td_enemy_state_spawn:
	lda	$2E,x
	bit	#$0003
	beq	loc_029EC7
	brl	clear_topdown_slot
loc_029EC7:
	stz	$3E,x
	stz	$3C,x
	stz	$00,x
	stz	$20,x
	stz	$28,x
	stz	$02,x
	stz	$2A,x
	stz	$16,x
	stz	$08,x
	stz	$0C,x
	inc	$12,x
	rtl

; State 1 shared by the walking enemies: as state 0, one more frame.
td_enemy_state_appear:
	lda	$2E,x
	bit	#$0003
	beq	loc_029EE8
	brl	clear_topdown_slot
loc_029EE8:
	inc	$12,x
	rtl

td_runner_state_2:
	lda	$00,x
	bne	loc_029F0A
	ldy	difficulty
	lda	a:td_runner_hp,y
	sta	$06,x
	lda	#$0006
	sta	$00,x
	lda	#.loword(td_anim_05D4A8)
	sta	$28,x
	lda	#$2000
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_029F0A:
	dec	$24,x
	bpl	loc_029F11
	brl	clear_topdown_slot
loc_029F11:
	lda	$2E,x
	bit	#$0003
	bne	loc_029F1D
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_029F1D:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_runner_state_3:
	lda	$06,x
	bmi	loc_029F37
	lda	$2E,x
	bit	#$000C
	bne	loc_029F32
	brl	clear_topdown_slot
loc_029F32:
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_029F37:
	stz	$06,x
	lda	#$000B
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

td_runner_state_4:
	brl	td_start_explosion

; TDT_GUNNER, stage 2: like TDT_RUNNER, but once on screen it turns to face
; the nearest player and fires bullets (td_fire_gun_bullet) every
; td_gunner_fire_delays frames. HP 0/2/4 (td_gunner_hp).
update_td_gunner:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_gunner_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_gunner_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_gunner_state_2
	.addr	td_gunner_state_3
	.addr	td_gunner_state_4

td_gunner_state_2:
	lda	$00,x
	bne	loc_029F80
	ldy	difficulty
	lda	a:td_gunner_hp,y
	sta	$06,x
	lda	#$0006
	sta	$00,x
	lda	#.loword(td_anim_05D4E0)
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_029F80:
	dec	$24,x
	bpl	loc_029F87
	brl	clear_topdown_slot
loc_029F87:
	lda	$2E,x
	bit	#$0003
	bne	loc_029F93
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_029F93:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#.loword(td_anim_05D4E0)
	sta	$28,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_gunner_state_3:
	lda	$2E,x
	bit	#$000C
	bne	loc_029FB1
	brl	clear_topdown_slot
loc_029FB1:
	lda	$06,x
	bmi	loc_02A012
	dec	$24,x
	bpl	loc_029FC3
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	beq	loc_029FC8
loc_029FC3:
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_029FC8:
	lda	#$0001
	sta	$20,x
	stz	$28,x
	ldy	difficulty
	lda	a:td_gunner_fire_delays,y
	sta	$24,x
	inc	$12,x

td_gunner_state_4:
	lda	$2E,x
	bit	#$000C
	bne	loc_029FE2
	brl	clear_topdown_slot
loc_029FE2:
	lda	$06,x
	bmi	loc_02A012
	dec	$24,x
	bpl	loc_029FFB
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	bne	loc_029F93
	ldy	difficulty
	lda	a:td_gunner_fire_delays,y
	sta	$24,x
loc_029FFB:
	ldy	difficulty
	lda	a:td_gunner_fire_delays,y
	lsr	a
	cmp	$24,x
	bne	@return
	jsl	f:td_fire_gun_bullet
	lda	#.loword(td_anim_05D4CE)
	sta	$28,x
	stz	$22,x
	rtl
@return:
	rtl
loc_02A012:
	lda	#$000B
	jsl	f:queue_sound
	jmp	a:td_start_explosion

; TDT_HATCH_TURRET_AIM, stage 2: the gun turret of a hatch (TDMT_GUN_HATCH_*,
; parent in +$3A). Hidden until the hatch opens (parent state 3), then turns
; towards the nearest player and fires when roughly facing it
; (hatch_turret_aim_fire_masks); hides when the hatch closes, explodes when
; the hatch is destroyed. HP 16/32/64 (hatch_turret_hp).
update_hatch_turret_aim:
	lda	$06,x
	bpl	loc_02A023
	brl	loc_02A0D4
loc_02A023:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A030
	brl	clear_topdown_slot
loc_02A030:
	cmp	#$0003
	bne	loc_02A038
	brl	loc_02A077
loc_02A038:
	cmp	#$0004
	bne	loc_02A040
	brl	loc_02A0C3
loc_02A040:
	cmp	#$0005
	bne	loc_02A048
	brl	loc_02A0D4
loc_02A048:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_hatch_turret_aim_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hatch_turret_aim_states:
	.addr	hatch_turret_state_0
	.addr	hatch_turret_state_1
	.addr	hatch_turret_aim_state_2
	.addr	hatch_turret_state_3
	.addr	hatch_turret_state_4

hatch_turret_state_0:
	stz	$06,x
	stz	$16,x
	lda	#$0006
	sta	$00,x
	stz	$20,x
	stz	$28,x
	lda	#$1200
	sta	$02,x
	inc	$12,x
	rtl

hatch_turret_state_1:
	rtl
loc_02A077:
	lda	$12,x
	cmp	#$0002
	beq	hatch_turret_aim_state_2
	ldy	difficulty
	lda	a:hatch_turret_hp,y
	sta	$06,x
	lda	#$A000	; [num]
	sta	$16,x
	lda	#.loword(td_anim_05D4E0)
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

hatch_turret_aim_state_2:
	jsl	f:td_angle_to_nearest_player
	ldy	difficulty
	clc
	adc	a:data_05D500,y
	sec
	sbc	$04,x
	cmp	a:data_05D4FA,y
	bcc	loc_02A0B5
	ldy	difficulty
	lda	a:data_05D4FA,y
	jsl	f:td_turn_towards_nearest_player
	rtl
loc_02A0B5:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:hatch_turret_aim_fire_masks,y
	bne	@return
	jsl	f:td_fire_gun_bullet
@return:
	rtl
loc_02A0C3:
	lda	#$1000
	sta	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	lda	#$0003
	sta	$12,x

hatch_turret_state_3:
	rtl
loc_02A0D4:
	stz	$06,x
	lda	#$000B
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

hatch_turret_state_4:
	brl	td_start_explosion

; TDT_HATCH_TURRET_SPIN, stage 2: like TDT_HATCH_TURRET_AIM, but it turns all
; the time and fires on a timer (hatch_turret_spin_fire_masks).
update_hatch_turret_spin:
	lda	$06,x
	bpl	loc_02A0EC
	brl	loc_02A0D4
loc_02A0EC:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A0F9
	brl	clear_topdown_slot
loc_02A0F9:
	cmp	#$0003
	bne	loc_02A101
	brl	loc_02A12A
loc_02A101:
	cmp	#$0004
	bne	loc_02A109
	brl	loc_02A0C3
loc_02A109:
	cmp	#$0005
	bne	loc_02A111
	; (not executed in the CDL traces)
	brl	loc_02A0D4
loc_02A111:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_hatch_turret_spin_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hatch_turret_spin_states:
	.addr	hatch_turret_state_0
	.addr	hatch_turret_state_1
	.addr	hatch_turret_spin_state_2
	.addr	hatch_turret_state_3
	.addr	hatch_turret_state_4
loc_02A12A:
	lda	$12,x
	cmp	#$0002
	beq	hatch_turret_spin_state_2
	ldy	difficulty
	lda	a:hatch_turret_hp,y
	sta	$06,x
	lda	#$A000	; [num]
	sta	$16,x
	lda	#.loword(td_anim_05D4E0)
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

hatch_turret_spin_state_2:
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05D50C,y
	and	#$00FF
	sta	$04,x
	ldy	difficulty
	lda	stage_frame_counter
	and	a:hatch_turret_spin_fire_masks,y
	bne	@return
	jsl	f:td_fire_gun_bullet
@return:
	rtl

; TDT_HATCH_TURRET_SWEEP, stage 2: like TDT_HATCH_TURRET_AIM, but it sweeps
; left and right (hatch_turret_sweep_fire_masks).
update_hatch_turret_sweep:
	lda	$06,x
	bpl	loc_02A16E
	brl	loc_02A0D4
loc_02A16E:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	loc_02A17B
	brl	clear_topdown_slot
loc_02A17B:
	cmp	#$0003
	bne	loc_02A183
	brl	loc_02A1AC
loc_02A183:
	cmp	#$0004
	bne	loc_02A18B
	brl	loc_02A0C3
loc_02A18B:
	cmp	#$0005
	bne	loc_02A193
	brl	loc_02A0D4
loc_02A193:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_hatch_turret_sweep_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_hatch_turret_sweep_states:
	.addr	hatch_turret_state_0
	.addr	hatch_turret_state_1
	.addr	hatch_turret_sweep_state_2
	.addr	hatch_turret_state_3
	.addr	hatch_turret_state_4
loc_02A1AC:
	lda	$12,x
	cmp	#$0002
	beq	hatch_turret_sweep_state_2
	ldy	difficulty
	lda	a:hatch_turret_hp,y
	sta	$06,x
	lda	#$A000	; [num]
	sta	$16,x
	lda	#.loword(td_anim_05D4E0)
	sta	$28,x
	stz	$24,x
	lda	#$2200
	sta	$02,x
	lda	#$0002
	sta	$12,x

hatch_turret_sweep_state_2:
	ldy	difficulty
	lda	$24,x
	clc
	adc	a:data_05D518,y
	and	#$00FF
	sta	$24,x
	ldy	difficulty
	lda	stage_frame_counter
	and	a:hatch_turret_sweep_fire_masks,y
	bne	loc_02A1EA
	jsl	f:td_fire_gun_bullet
loc_02A1EA:
	jsr	a:hatch_turret_sweep_turn
	rtl

hatch_turret_sweep_turn:
	ldy	difficulty
	lda	$24,x
	clc
	adc	#$0040
	sec
	sbc	a:data_05D518,y
	and	#$00FF
	bit	#$0080
	bne	loc_02A20E
	lda	$04,x
	clc
	adc	a:data_05D51E,y
	and	#$00FF
	sta	$04,x
	rts
loc_02A20E:
	lda	$04,x
	sec
	sbc	a:data_05D51E,y
	and	#$00FF
	sta	$04,x
	rts

; Fires a TDS_ENEMY_BULLET from the gun of enemy X ($12 pixels ahead,
; slightly to the side); only when it is on screen.
td_fire_gun_bullet:
	lda	$2E,x
	bit	#$0003
	beq	@return
	jsl	f:td_find_free_enemy_shot_slot
	bcs	@return
	lda	#TDS_ENEMY_BULLET
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	phy
	ldy	#$0012
	lda	$04,x
	clc
	adc	#$FFEC
	jsl	f:polar_to_xy
	lda	zp_08
	sta	zp_FC
	lda	zp_0A
	sta	zp_FE
	ply
	lda	$0A,x
	clc
	adc	zp_FC
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_FE
	sta	a:$000E,y
	lda	$04,x
	sta	a:$0004,y
	lda	#$0020
	jsl	f:set_velocity_from_angle_y
	lda	#$FFFF	; [num]
	sta	a:$0004,y
@return:
	rtl

; TDT_CENTIPEDE_UNUSED: a centipede like TDT_CENTIPEDE (HP 16/64/128,
; td_centipede_unused_hp); no generator spawns it (not executed in the CDL
; traces).
update_td_centipede_unused:
	; (not executed in the CDL traces)
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_centipede_unused_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_centipede_unused_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_centipede_unused_state_2
	.addr	td_centipede_unused_state_3
	.addr	td_centipede_unused_state_4

td_centipede_unused_state_2:
	; (not executed in the CDL traces)
	lda	$00,x
	bne	loc_02A2BB
	ldy	difficulty
	lda	a:td_centipede_unused_hp,y
	sta	$06,x
	lda	#TDT_CENTIPEDE_SEGMENT
	sta	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	lda	#$2400
	sta	$02,x
	lda	#.loword(td_anim_05D530)
	sta	$28,x
	jsr	a:td_centipede_init_trail
loc_02A2BB:
	dec	$24,x
	bpl	loc_02A2C2
	brl	loc_02A39A
loc_02A2C2:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A2F3
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl

td_centipede_init_trail:
	; (not executed in the CDL traces)
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$1870
	sta	a:td_enemies+3*OBJ_SIZE+$2C
	lda	#$17E0
	sta	a:td_enemies+4*OBJ_SIZE+$2C
	lda	#$1750
	sta	a:td_enemies+5*OBJ_SIZE+$2C
	lda	#$0040
	sta	$24,x
	rts
loc_02A2F3:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_centipede_unused_state_3:
	; (not executed in the CDL traces)
	jsr	a:td_centipede_check_out_of_range
	bcc	loc_02A302
	brl	loc_02A39A
loc_02A302:
	jsr	a:td_centipede_check_killed
	bcc	loc_02A30A
	brl	loc_02A312
loc_02A30A:
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
loc_02A312:
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

td_centipede_unused_state_4:
	phx
	ldx	#$0E00
	jsl	f:td_start_explosion
	ldx	#$0E40
	jsl	f:td_start_explosion
	ldx	#$0E80
	jsl	f:td_start_explosion
	plx
	jml	f:td_start_explosion

td_centipede_record_trail:
	ldy	$2C,x
	lda	$04,x
	jsr	a:td_write_trail_word
	lda	$0A,x
	jsr	a:td_write_trail_word
	lda	$0E,x
	jsr	a:td_write_trail_word
	sty	$2C,x
	rts

td_write_trail_word:
	phx
	tyx
	sta	f:$7E0000,x
	iny
	iny
	cpy	#$1B00
	bcc	loc_02A35D
	ldy	#$1900
loc_02A35D:
	plx
	rts

td_centipede_check_killed:
	jsl	f:td_play_hit_sound
	lda	$06,x
	clc
	adc	a:td_enemies+3*OBJ_SIZE+OBJ_HP
	clc
	adc	a:td_enemies+4*OBJ_SIZE+OBJ_HP
	clc
	adc	a:td_enemies+5*OBJ_SIZE+OBJ_HP
	bpl	loc_02A375
	sec
	rts
loc_02A375:
	clc
	rts

td_centipede_check_out_of_range:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A398
	lda	a:td_enemies+3*OBJ_SIZE+$2E
	bit	#$000C
	bne	loc_02A398
	lda	a:td_enemies+4*OBJ_SIZE+$2E
	bit	#$000C
	bne	loc_02A398
	lda	a:td_enemies+5*OBJ_SIZE+$2E
	bit	#$000C
	bne	loc_02A398
	sec
	rts
loc_02A398:
	clc
	rts
loc_02A39A:
	phx
	ldx	#$0E80
	jsl	f:clear_topdown_slot
	ldx	#$0E40
	jsl	f:clear_topdown_slot
	ldx	#$0E00
	jsl	f:clear_topdown_slot
	plx
	jsl	f:clear_topdown_slot
	rtl

; TDT_CENTIPEDE_SEGMENT: body segment of a centipede ($0E00, $0E40, $0E80);
; follows the trail its head records at $7E:1900-$1AFF, each segment a few
; positions behind. Hit damage counts for the whole centipede.
update_td_centipede_segment:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_centipede_segment_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_centipede_segment_states:
	.addr	td_centipede_segment_state_0
	.addr	td_centipede_segment_state_1

td_centipede_segment_state_0:
	lda	#$0007
	sta	$00,x
	lda	#$2400
	sta	$02,x
	lda	#.loword(td_anim_05D530)
	sta	$28,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_ANGLE
	sta	$04,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_X
	sta	$0A,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_Y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	stz	$2E,x
	stz	$16,x
	stz	$06,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

td_centipede_segment_state_1:
	jsl	f:td_play_hit_sound
	jsr	a:td_segment_set_hittable
	jsr	a:td_segment_follow_trail
	jsl	f:td_enemy_tile_collision
	rtl

td_segment_set_hittable:
	lda	$2E,x
	bit	#$0003
	beq	loc_02A417
	lda	#$A000	; [num]
	sta	$16,x
	rts
loc_02A417:
	stz	$16,x
	rts

td_segment_follow_trail:
	ldy	$2C,x
	cpy	#$1900
	bcs	loc_02A428
	tya
	adc	#$0006
	sta	$2C,x
	rts
loc_02A428:
	jsr	a:td_read_trail_word
	sta	$04,x
	jsr	a:td_read_trail_word
	sta	$0A,x
	jsr	a:td_read_trail_word
	sta	$0E,x
	sty	$2C,x
	rts

td_read_trail_word:
	phx
	tyx
	lda	f:$7E0000,x
	iny
	iny
	cpy	#$1B00
	bcc	loc_02A44A
	ldy	#$1900
loc_02A44A:
	plx
	rts

; TDT_BUG_CENTIPEDE, stage 5: centipede head ($0DC0) with three
; TDT_BUG_CENTIPEDE_SEGMENT; HP 16/64/128 for the whole body
; (td_bug_centipede_hp, the sum of the four parts). When killed, the four
; parts become TDT_CENTIPEDE_BUG running off in random directions.
; Spawned by spawn_stage5_enemies when no enemy is alive.
update_td_bug_centipede:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_bug_centipede_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_bug_centipede_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_bug_centipede_state_2
	.addr	td_bug_centipede_state_3

td_bug_centipede_state_2:
	lda	$00,x
	bne	loc_02A4AB
	ldy	difficulty
	lda	a:td_bug_centipede_hp,y
	sta	$06,x
	lda	#TDT_BUG_CENTIPEDE_SEGMENT
	sta	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	lda	#$2E00
	sta	$02,x
	lda	#.loword(td_anim_05D544)
	sta	$28,x
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$18AC
	sta	a:td_enemies+3*OBJ_SIZE+$2C
	lda	#$1858
	sta	a:td_enemies+4*OBJ_SIZE+$2C
	lda	#$1804
	sta	a:td_enemies+5*OBJ_SIZE+$2C
	lda	#$0040
	sta	$24,x
loc_02A4AB:
	dec	$24,x
	bpl	loc_02A4B2
	brl	loc_02A39A
loc_02A4B2:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A4C1
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
loc_02A4C1:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_bug_centipede_state_3:
	jsr	a:td_centipede_check_out_of_range
	bcc	loc_02A4D8
	brl	loc_02A39A
loc_02A4D8:
	jsr	a:td_centipede_check_killed
	bcc	loc_02A4E0
	brl	loc_02A505
loc_02A4E0:
	lda	a:td_enemies+5*OBJ_SIZE+OBJ_X
	cmp	$0A,x
	bne	loc_02A4EE
	lda	a:td_enemies+5*OBJ_SIZE+OBJ_Y
	cmp	$0E,x
	beq	loc_02A505
loc_02A4EE:
	dec	$24,x
	bpl	loc_02A4F7
	lda	#$0080
	sta	$24,x
loc_02A4F7:
	lda	#$0002
	jsl	f:td_turn_towards_nearest_player
	jsr	a:td_centipede_wiggle
	jsr	a:td_centipede_record_trail
	rtl
loc_02A505:
	lda	#$0030
	jsl	f:queue_sound
	lda	#TDT_CENTIPEDE_BUG
	sta	a:td_enemies+2*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	stz	a:td_enemies+2*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+3*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+4*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+5*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+2*OBJ_SIZE+OBJ_HP
	stz	a:td_enemies+3*OBJ_SIZE+OBJ_HP
	stz	a:td_enemies+4*OBJ_SIZE+OBJ_HP
	stz	a:td_enemies+5*OBJ_SIZE+OBJ_HP
	lda	rng_lo
	ldy	#$0DC0
	jsr	a:td_set_bug_direction
	lda	zp_E9
	ldy	#$0E00
	jsr	a:td_set_bug_direction
	lda	rng_hi
	ldy	#$0E40
	jsr	a:td_set_bug_direction
	lda	zp_EB
	ldy	#$0E80
	jsr	a:td_set_bug_direction
	rtl

td_set_bug_direction:
	and	#$00FF
	sta	a:$0038,y
	rts

; TDT_BUG_CENTIPEDE_SEGMENT: body segment of TDT_BUG_CENTIPEDE (follows its trail).
update_td_bug_centipede_segment:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_bug_centipede_segment_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_bug_centipede_segment_states:
	.addr	td_bug_centipede_segment_state_0
	.addr	td_bug_centipede_segment_state_1

td_bug_centipede_segment_state_0:
	lda	#$0007
	sta	$00,x
	lda	#$2E00
	sta	$02,x
	lda	#.loword(td_anim_05D544)
	sta	$28,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_ANGLE
	sta	$04,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_X
	sta	$0A,x
	lda	a:td_enemies+2*OBJ_SIZE+OBJ_Y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	stz	$2E,x
	stz	$16,x
	stz	$06,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

td_bug_centipede_segment_state_1:
	jsl	f:td_play_hit_sound
	jsr	a:td_segment_set_hittable
	jsr	a:td_segment_follow_trail
	jsl	f:td_enemy_tile_collision
	rtl

; TDT_CENTIPEDE_BUG, stage 5: what is left of a TDT_BUG_CENTIPEDE: runs off
; for $20 frames, fires an orb, then walks towards the nearest player.
; HP 2/4/8 (td_centipede_bug_hp).
update_td_centipede_bug:
	lda	$06,x
	bpl	loc_02A5B6
	brl	loc_02A678
loc_02A5B6:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_centipede_bug_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_centipede_bug_states:
	.addr	td_centipede_bug_state_0
	.addr	td_centipede_bug_state_1
	.addr	td_centipede_bug_state_2
	.addr	td_centipede_bug_state_3

td_centipede_bug_state_0:
	ldy	difficulty
	lda	a:td_centipede_bug_hp,y
	sta	$06,x
	stz	$3E,x
	stz	$3C,x
	stz	$20,x
	stz	$2A,x
	lda	#$A000	; [num]
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	lda	#$0007
	sta	$00,x
	lda	#.loword(td_anim_05D544)
	sta	$28,x
	lda	#$2E00
	sta	$02,x
	lda	#$0020
	sta	$24,x
	inc	$12,x

td_centipede_bug_state_1:
	dec	$24,x
	bmi	loc_02A61B
	lda	$04,x
	pha
	lda	$38,x
	sta	$04,x
	lda	$24,x
	jsl	f:set_velocity_from_angle
	jsl	f:move_topdown_object
	pla
	clc
	adc	#$0010
	and	#$00FF
	sta	$04,x
	rtl
loc_02A61B:
	lda	#$0020
	sta	$24,x
	lda	#$0002
	sta	$12,x

td_centipede_bug_state_2:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A62F
	brl	clear_topdown_slot
loc_02A62F:
	lda	$06,x
	bmi	loc_02A678
	dec	$24,x
	bmi	loc_02A64C
	lda	$24,x
	cmp	#$0010
	bne	loc_02A642
	jsl	f:td_fire_enemy_orb
loc_02A642:
	lda	#$0002
	sta	$22,x
	jsl	f:td_enemy_tile_collision
	rtl
loc_02A64C:
	lda	#$A000	; [num]
	sta	$16,x
	txa
	lsr	a
	lsr	a
	lsr	a
	and	#$0018
	clc
	ldy	difficulty
	adc	a:data_05D558,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_centipede_bug_state_3:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A66F
	brl	clear_topdown_slot
loc_02A66F:
	dec	$24,x
	bmi	loc_02A61B
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A678:
	lda	#$0030
	jsl	f:queue_sound
	jmp	a:td_start_explosion

; TDT_CENTIPEDE, stage 2: centipede head ($0DC0) with three
; TDT_CENTIPEDE_SEGMENT; wiggles towards the nearest player and fires bullets
; when facing it (td_centipede_fire_masks). HP 16/64/128 for the whole body
; (td_centipede_hp). Spawned by spawn_stage2_enemies when no enemy is alive.
update_td_centipede:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_centipede_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_centipede_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_centipede_state_2
	.addr	td_centipede_state_3
	.addr	td_centipede_state_4
	.addr	td_centipede_state_5

td_centipede_state_2:
	lda	$00,x
	bne	loc_02A6E5
	ldy	difficulty
	lda	a:td_centipede_hp,y
	sta	$06,x
	lda	#TDT_CENTIPEDE_SEGMENT
	sta	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	lda	#$2400
	sta	$02,x
	lda	#.loword(td_anim_05D530)
	sta	$28,x
	lda	#$0007
	sta	$00,x
	lda	#$1900
	sta	$2C,x
	lda	#$18AC
	sta	a:td_enemies+3*OBJ_SIZE+$2C
	lda	#$1858
	sta	a:td_enemies+4*OBJ_SIZE+$2C
	lda	#$1804
	sta	a:td_enemies+5*OBJ_SIZE+$2C
	lda	#$0040
	sta	$24,x
loc_02A6E5:
	dec	$24,x
	bpl	loc_02A6EC
	brl	loc_02A39A
loc_02A6EC:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A6FB
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
loc_02A6FB:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_centipede_state_3:
	jsr	a:td_centipede_check_out_of_range
	bcc	loc_02A712
	brl	loc_02A39A
loc_02A712:
	jsr	a:td_centipede_check_killed
	bcc	loc_02A71A
	brl	loc_02A312
loc_02A71A:
	dec	$24,x
	bmi	loc_02A725
	jsr	a:td_centipede_wiggle
	jsr	a:td_centipede_record_trail
	rtl
loc_02A725:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_centipede_state_4:
	jsr	a:td_centipede_check_out_of_range
	bcc	loc_02A734
	brl	loc_02A39A
loc_02A734:
	jsr	a:td_centipede_check_killed
	bcc	loc_02A73C
	brl	loc_02A312
loc_02A73C:
	lda	#$0004
	jsl	f:td_turn_towards_nearest_player
	jsl	f:td_angle_to_nearest_player
	clc
	adc	#$0002
	sec
	sbc	$04,x
	cmp	#$0004
	bcc	loc_02A6FB
	ldy	difficulty
	lda	stage_frame_counter
	and	a:td_centipede_fire_masks,y
	bne	loc_02A763
	ldy	#$0010
	jsl	f:td_fire_enemy_bullet
loc_02A763:
	jsr	a:td_centipede_record_trail
	rtl

; (no caller found; decoded because it follows the end of a routine)
td_centipede_start_death_unused:
	; (not executed in the CDL traces)
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0005
	sta	$12,x

td_centipede_state_5:
	; (not executed in the CDL traces)
	phx
	ldx	#$0E00
	jsl	f:td_start_explosion
	ldx	#$0E40
	jsl	f:td_start_explosion
	ldx	#$0E80
	jsl	f:td_start_explosion
	plx
	jml	f:td_start_explosion

td_centipede_wiggle:
	lda	$24,x
	and	#$007F
	cmp	#$0040
	bcc	loc_02A79B
	eor	#$007F
loc_02A79B:
	lsr	a
	jsl	f:td_move_at_angle
	jsl	f:td_enemy_tile_collision
	rts

; TDT_NEST_CRAWLER, stage 5: comes out of a nest (TDMT_NEST, parent in +$3A)
; when it opens, walks towards the nearest player and fires orbs.
; HP 2/16/32 (td_nest_crawler_hp).
update_td_nest_crawler:
	lda	$06,x
	bpl	loc_02A7AC
	brl	loc_02A86C
loc_02A7AC:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0005
	bne	loc_02A7B9
	brl	loc_02A86C
loc_02A7B9:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_nest_crawler_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_nest_crawler_states:
	.addr	td_nest_crawler_state_0
	.addr	td_nest_crawler_state_1
	.addr	td_nest_crawler_state_2
	.addr	td_nest_crawler_state_3
	.addr	td_nest_crawler_state_4

td_nest_crawler_state_0:
	ldy	difficulty
	lda	a:td_nest_crawler_hp,y
	sta	$06,x
	stz	$3C,x
	stz	$08,x
	stz	$0C,x
	lda	#$0005
	sta	$00,x
	lda	#.loword(td_anim_05D570)
	sta	$28,x
	lda	#$0000
	sta	$02,x
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0001
	sta	$12,x

td_nest_crawler_state_1:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0003
	beq	loc_02A809
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	rtl
loc_02A809:
	lda	#$0002
	sta	$24,x
	lda	#$0002
	sta	$12,x

td_nest_crawler_state_2:
	dec	$24,x
	bmi	loc_02A81E
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	rtl
loc_02A81E:
	lda	#$2000
	sta	$02,x
	ldy	difficulty
	lda	a:data_05D58A,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_nest_crawler_state_3:
	dec	$24,x
	bmi	loc_02A842
	lda	$2E,x
	bit	#$000C
	bne	loc_02A83D
	brl	clear_topdown_slot
loc_02A83D:
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A842:
	lda	#$0040
	sta	$24,x
	inc	$12,x

td_nest_crawler_state_4:
	dec	$24,x
	bmi	loc_02A81E
	lda	$2E,x
	bit	#$000C
	bne	loc_02A857
	brl	clear_topdown_slot
loc_02A857:
	lda	$24,x
	cmp	#$0020
	bne	loc_02A862
	jsl	f:td_fire_enemy_orb
loc_02A862:
	lda	#$0002
	sta	$22,x
	jsl	f:td_enemy_tile_collision
	rtl
loc_02A86C:
	lda	#$000B
	jsl	f:queue_sound
	jmp	a:td_start_explosion

; TDT_CRAWLER, stage 5: walks towards the nearest player. HP 2/4/8
; (td_crawler_hp). Spawned by spawn_stage5_enemies.
update_td_crawler:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_crawler_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_crawler_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_crawler_state_2
	.addr	td_crawler_state_3

td_crawler_state_2:
	lda	$00,x
	bne	loc_02A8AC
	ldy	difficulty
	lda	a:td_crawler_hp,y
	sta	$06,x
	lda	#$0005
	sta	$00,x
	lda	#.loword(td_anim_05D596)
	sta	$28,x
	lda	#$2200
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_02A8AC:
	dec	$24,x
	bpl	loc_02A8B3
	brl	clear_topdown_slot
loc_02A8B3:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A8BF
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A8BF:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_crawler_state_3:
	lda	$06,x
	bmi	loc_02A8D9
	lda	$2E,x
	bit	#$000C
	bne	loc_02A8D4
	brl	clear_topdown_slot
loc_02A8D4:
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A8D9:
	stz	$06,x
	lda	#$000B
	jsl	f:queue_sound
	jmp	a:td_start_explosion

; TDT_SPITTER, stage 5: walks, turns to face the nearest player and fires
; orbs (td_spitter_fire_delays). HP 2/4/8 (td_spitter_hp). Spawned by
; spawn_stage5_enemies.
update_td_spitter:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_spitter_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_spitter_states:
	.addr	td_enemy_state_spawn
	.addr	td_enemy_state_appear
	.addr	td_spitter_state_2
	.addr	td_spitter_state_3
	.addr	td_spitter_state_4

td_spitter_state_2:
	lda	$00,x
	bne	loc_02A91D
	ldy	difficulty
	lda	a:td_spitter_hp,y
	sta	$06,x
	lda	#$0005
	sta	$00,x
	lda	#.loword(td_anim_05D570)
	sta	$28,x
	lda	#$2000
	sta	$02,x
	lda	#$0040
	sta	$24,x
loc_02A91D:
	dec	$24,x
	bpl	loc_02A924
	brl	clear_topdown_slot
loc_02A924:
	lda	$2E,x
	bit	#$0003
	bne	loc_02A930
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A930:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_spitter_state_3:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A949
	brl	clear_topdown_slot
loc_02A949:
	lda	$06,x
	bpl	loc_02A950
	brl	loc_02A8D9
loc_02A950:
	dec	$24,x
	bpl	loc_02A95E
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	beq	loc_02A963
loc_02A95E:
	jsl	f:td_walk_towards_nearest_player
	rtl
loc_02A963:
	ldy	difficulty
	lda	a:td_spitter_fire_delays,y
	sta	$24,x
	inc	$12,x

td_spitter_state_4:
	lda	$2E,x
	bit	#$000C
	bne	loc_02A976
	brl	clear_topdown_slot
loc_02A976:
	lda	$06,x
	bpl	loc_02A97D
	brl	loc_02A8D9
loc_02A97D:
	dec	$24,x
	bpl	loc_02A992
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	bne	loc_02A930
	ldy	difficulty
	lda	a:td_spitter_fire_delays,y
	sta	$24,x
loc_02A992:
	ldy	difficulty
	lda	a:td_spitter_fire_delays,y
	lsr	a
	cmp	$24,x
	bne	@return
	jsl	f:td_fire_enemy_orb
	lda	#$0002
	sta	$22,x
@return:
	rtl

; Fires a TDS_ENEMY_ORB from enemy X ($0C pixels ahead); only on screen.
td_fire_enemy_orb:
	lda	$2E,x
	bit	#$0003
	beq	@return
	jsl	f:td_find_free_enemy_shot_slot
	bcs	@return
	lda	#TDS_ENEMY_ORB
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	lda	$04,x
	sta	a:$0004,y
	phy
	ldy	#$000C
	jsl	f:polar_to_xy
	ply
	lda	$0A,x
	clc
	adc	zp_08
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_0A
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	lda	a:$0004,y
	ora	#$FF00
	sta	a:$0004,y
@return:
	rtl

; Runs the item and effect objects ($0980-$0ABF) by type (tbl_td_item_types,
; TDI_*), then their animation (animate_td_item).
update_td_items:
	ldx	#$0980
@loop:
	lda	$10,x
	beq	@next
	jsl	f:run_td_item_handler
	jsl	f:animate_td_item
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop
	rtl

run_td_item_handler:
	phx
	asl	a
	tax
	lda	f:tbl_td_item_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_types:
	.addr	td_item_none
	.addr	update_td_blast
	.addr	update_td_explosion_effect
	.addr	update_td_item_spread
	.addr	update_td_item_crush
	.addr	update_td_item_homing
	.addr	update_td_item_flame
	.addr	update_td_item_laser
	.addr	update_td_item_barrier
	.addr	update_td_item_bomb

; TDI_BLAST: a blast (damage 16, +$16 bit 15) that hurts the enemies and the
; players (unless barrier) until its animation ends. Set off by the stage 2
; traps (TDA_TRAP).
update_td_blast:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_blast_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_blast_states:
	.addr	td_blast_state_0
	.addr	td_blast_state_1

td_blast_state_0:
	lda	#.loword(anim_05D5BC)
	sta	$20,x
	stz	$22,x
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0010
	sta	$06,x
	stz	$04,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0001
	sta	$12,x

td_blast_state_1:
	lda	$20,x
	bne	td_item_none
	brl	clear_topdown_slot

td_item_none:
	rtl

; TDI_EXPLOSION: an explosion animation at a random offset of up to 8
; pixels, no collision (td_spawn_explosion_effect).
update_td_explosion_effect:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_explosion_effect_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_explosion_effect_states:
	.addr	td_explosion_effect_state_0
	.addr	td_explosion_effect_state_1

td_explosion_effect_state_0:
	lda	#.loword(anim_05D610)
	sta	$20,x
	stz	$22,x
	stz	$16,x
	stz	$04,x
	lda	rng_lo
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$0A,x
	sta	$0A,x
	lda	rng_hi
	and	#$000F
	sec
	sbc	#$0008
	clc
	adc	$0E,x
	sta	$0E,x
	lda	#$0001
	sta	$12,x

td_explosion_effect_state_1:
	lda	$20,x
	bne	@return
	brl	clear_topdown_slot
@return:
	rtl

; TDI_SPREAD ... TDI_BOMB: an item on the floor for $140 frames; its kind is
; in +$14 (1-5 the weapon WEAPON_*, TDIK_BARRIER, TDIK_BOMB) and the player
; picks it up by touching it (td_p1_vs_items). Dropped by destroyed targets
; and boss pods (td_spawn_item_drop).
update_td_item_spread:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_spread_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_spread_states:
	.addr	td_item_spread_state_0
	.addr	td_item_state_1

td_item_spread_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D664,y
	sta	$20,x
	lda	#$0001
	sta	$14,x
loc_02AADA:
	lda	#$4000
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0140
	sta	$24,x
	lda	#$0001
	sta	$12,x

td_item_state_1:
	dec	$24,x
	bpl	@return
	brl	clear_topdown_slot
@return:
	rtl

update_td_item_crush:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_crush_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_crush_states:
	.addr	td_item_crush_state_0
	.addr	td_item_state_1

td_item_crush_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D668,y
	sta	$20,x
	lda	#$0002
	sta	$14,x
	jmp	a:loc_02AADA

update_td_item_homing:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_homing_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_homing_states:
	.addr	td_item_homing_state_0
	.addr	td_item_state_1

td_item_homing_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D66C,y
	sta	$20,x
	lda	#$0003
	sta	$14,x
	jmp	a:loc_02AADA

update_td_item_flame:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_flame_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_flame_states:
	.addr	td_item_flame_state_0
	.addr	td_item_state_1

td_item_flame_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D670,y
	sta	$20,x
	lda	#$0004
	sta	$14,x
	jmp	a:loc_02AADA

update_td_item_laser:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_laser_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_laser_states:
	.addr	td_item_laser_state_0
	.addr	td_item_state_1

td_item_laser_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D674,y
	sta	$20,x
	lda	#$0005
	sta	$14,x
	jmp	a:loc_02AADA

update_td_item_barrier:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_barrier_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_barrier_states:
	.addr	td_item_barrier_state_0
	.addr	td_item_state_1

td_item_barrier_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D678,y
	sta	$20,x
	lda	#$0006
	sta	$14,x
	jmp	a:loc_02AADA

update_td_item_bomb:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_item_bomb_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_item_bomb_states:
	.addr	td_item_bomb_state_0
	.addr	td_item_state_1

td_item_bomb_state_0:
	ldy	a:boss_centered_view
	lda	a:data_05D67C,y
	sta	$20,x
	lda	#$0007
	sta	$14,x
	jmp	a:loc_02AADA

animate_td_item:
	ldy	$20,x
	beq	loc_02ABF4
	dec	$22,x
	bmi	loc_02ABF5
	bne	loc_02ABF4
	tya
	clc
	adc	#$0006
@loop:
	tay
	lda	a:$0000,y
	bmi	@loop
	beq	loc_02ABFA
	sty	$20,x
loc_02ABE8:
	sta	$22,x
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
loc_02ABF4:
	rtl
loc_02ABF5:
	lda	a:$0000,y
	bne	loc_02ABE8
loc_02ABFA:
	sta	$22,x
	sta	$20,x
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	rtl

; Stage 5 boss: runs the map objects $0AC0-$0B3F (the boss) by type.
update_stage5_boss_objects:
	ldx	#$0AC0
@loop:
	lda	$10,x
	beq	@next
	jsl	f:run_map_object_handler
	jsr	a:update_map_object_block
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	@loop
	rtl

; Runs the map objects ($0AC0-$0D3F: targets, turrets, boss parts) by type
; (tbl_map_object_types), then update_map_object_block.
update_map_objects:
	ldx	#$0AC0
@loop:
	lda	$10,x
	beq	@next
	jsl	f:run_map_object_handler
	jsr	a:update_map_object_block
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@loop

td_map_object_none:
	rtl

run_map_object_handler:
	phx
	asl	a
	tax
	lda	f:tbl_map_object_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_map_object_types:
	.addr	td_map_object_none
	.addr	update_gun_hatch_aim
	.addr	update_td_nest
	.addr	update_stage2_boss
	.addr	update_stage2_boss_core
	.addr	update_stage2_boss_cannon
	.addr	update_stage2_boss_pod
	.addr	update_gun_hatch_spin
	.addr	update_stage5_boss
	.addr	td_map_object_none
	.addr	td_map_object_none
	.addr	td_map_object_none
	.addr	update_gun_hatch_sweep
	.addr	update_gun_hatch_no_fire
	.addr	update_gun_hatch_behind
	.addr	td_map_object_none
	.addr	td_map_object_none
	.addr	td_map_object_none
	.addr	td_map_object_none
	.addr	td_map_object_none

; Spawns a TDI_EXPLOSION at object X's position.
td_spawn_explosion_effect:
	jsl	f:td_find_free_item_slot
	bcs	@return
	lda	#TDI_EXPLOSION
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
@return:
	rtl

; Destroyed map object X may drop an item: kind td_item_drop_kinds by its
; +$14 and random (0 = none), type td_item_kind_types. Carry set when no
; slot is free.
td_spawn_item_drop:
	jsl	f:td_find_free_item_slot
	bcs	loc_02ACCB
	lda	$14,x
	asl	a
	sta	zp_FA
	lda	rng_lo
	and	#$0003
	ora	zp_FA
	asl	a
	phy
	tay
	lda	a:td_item_drop_kinds,y
	ply
	sta	a:$0014,y
	cmp	#$0000
	beq	loc_02ACCA
	asl	a
	phy
	tay
	lda	a:td_item_kind_types,y
	ply
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_02ACCA:
	clc
loc_02ACCB:
	rtl

; Map objects are drawn in the Mode 7 tilemap: when the block wanted
; (+$20) changes, queues it at VRAM address +$26 (queue_m7_block_patch).
update_map_object_block:
	lda	$20,x
	cmp	$28,x
	beq	@return
	sta	$28,x
	tay
	lda	$26,x
	phx
	jsl	f:queue_m7_block_patch
	plx
	bcc	@return
	stz	$28,x
@return:
	rts

; TDMT_STAGE2_BOSS ($0AC0): the stage 2 boss, a spiked machine with six arms
; drawn as the Mode 7 layer (the arena floor is sprites,
; draw_stage2_boss_arena). It falls from above (Mode 7 scale growing from 0
; to 1:1, screen shake), turns and walks towards the nearest player, and
; jumps on it (scale shrinking, then growing again over the player).
; Its parts: TDMT_STAGE2_BOSS_CORE, TDMT_STAGE2_BOSS_CANNON and six
; TDMT_STAGE2_BOSS_POD. It dies with the core. Checked in the emulator.
update_stage2_boss:
	lda	$12,x
	cmp	#$0011
	beq	loc_02ACEC
	jsr	a:stage2_boss_next_frame
loc_02ACEC:
	jsr	a:td_select_target_player
	jsl	f:stage2_boss_run_state
	jsl	f:stage2_boss_stream_chr
	lda	$04,x
	clc
	adc	#$0002
	lsr	a
	and	#$007E
	sta	$3E,x
	rtl

stage2_boss_run_state:
	lda	a:td_boss_core_hp
	bpl	loc_02AD0C
	brl	loc_02B04C
loc_02AD0C:
	lda	$12,x
	cmp	#$0004
	bcc	loc_02AD2B
	cmp	#$0007
	bcs	loc_02AD2B
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_TYPE
	bne	loc_02AD20
	; (not executed in the CDL traces)
	brl	loc_02AE9A
loc_02AD20:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_STATE
	cmp	#$0004
	bne	loc_02AD2B
	brl	loc_02AE9A
loc_02AD2B:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage2_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_boss_states:
	.addr	stage2_boss_state_00
	.addr	stage2_boss_state_01
	.addr	stage2_boss_state_02
	.addr	stage2_boss_state_03
	.addr	stage2_boss_state_04
	.addr	stage2_boss_state_05
	.addr	stage2_boss_state_06
	.addr	stage2_boss_state_07
	.addr	stage2_boss_state_08
	.addr	stage2_boss_state_09
	.addr	stage2_boss_state_0A
	.addr	stage2_boss_state_0B
	.addr	stage2_boss_state_0C
	.addr	stage2_boss_state_0D
	.addr	stage2_boss_state_0E
	.addr	stage2_boss_state_0F
	.addr	stage2_boss_state_10
	.addr	stage2_boss_state_11
	.addr	stage2_boss_state_12

stage2_boss_state_00:
	lda	#$8000	; [num]
	sta	a:td_boss_x
	sta	a:td_boss_y
	lda	#$00F0
	sta	a:p1_m7_center_x
	sta	a:p2_m7_center_x
	lda	#$0110
	sta	a:p1_m7_center_y
	sta	a:p2_m7_center_y
	stz	$2E,x
	stz	$16,x
	lda	#$0040
	sta	$24,x
	inc	$12,x

stage2_boss_state_01:
	dec	$24,x
	bmi	loc_02AD8B
	rtl
loc_02AD8B:
	lda	#$002F
	jsl	f:queue_sound
	stz	$20,x
	stz	$28,x
	lda	a:p1_view_x
	sta	a:td_boss_x
	lda	a:p1_view_y
	sta	a:td_boss_y
	lda	#$0000
	sta	a:p1_m7_scale_x
	sta	a:p2_m7_scale_x
	sta	a:p1_m7_scale_y
	sta	a:p2_m7_scale_y
	lda	#$0080
	sta	a:td_boss_angle
	jsr	a:td_set_players_priority_1
	inc	$12,x

stage2_boss_state_02:
	lda	a:td_boss_angle
	inc	a
	inc	a
	and	#$00FF
	sta	a:td_boss_angle
	inc	a:p1_m7_scale_x
	inc	a:p2_m7_scale_x
	inc	a:p1_m7_scale_y
	inc	a:p2_m7_scale_y
	inc	a:p1_m7_scale_x
	inc	a:p2_m7_scale_x
	inc	a:p1_m7_scale_y
	inc	a:p2_m7_scale_y
	lda	a:p2_m7_scale_y
	cmp	#M7_SCALE_1X
	beq	loc_02ADE8
	rtl
loc_02ADE8:
	lda	#$0056
	jsl	f:queue_sound
	jsr	a:td_set_players_priority_2
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0010
	sta	a:screen_shake_timer
	lda	#$0004
	sta	a:screen_shake_offset
	lda	#$0020
	sta	$24,x
	inc	$12,x

stage2_boss_state_03:
	dec	$24,x
	bmi	loc_02AE0F
	rtl
loc_02AE0F:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0004
	sta	$12,x

stage2_boss_state_04:
	jsr	a:stage2_boss_turn_to_player
	bcs	loc_02AE22
	rtl
loc_02AE22:
	lda	#$0018
	jsl	f:set_velocity_from_angle
	lda	#$0060
	sta	$24,x
	inc	$12,x

stage2_boss_state_05:
	dec	$24,x
	bmi	loc_02AE3B
	jsr	a:stage2_boss_check_facing_player
	jsr	a:stage2_boss_move
	rtl
loc_02AE3B:
	lda	a:boss_target_distance
	cmp	#$3C80
	bcc	loc_02AE46
	; (not executed in the CDL traces)
	brl	loc_02AE0F
loc_02AE46:
	lda	$04,x
	sta	$24,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	$04,x
	bit	#$0080
	bne	loc_02AE77
	stz	$26,x
	bra	stage2_boss_state_06
loc_02AE77:
	lda	#$0002
	sta	$26,x

stage2_boss_state_06:
	lda	#$0002
	jsr	a:td_play_turn_sound
	ldy	$26,x
	lda	$04,x
	clc
	adc	a:data_05D7B2,y
	and	#$00FF
	sta	$04,x
	cmp	$24,x
	bne	loc_02AE96
	brl	loc_02AE0F
loc_02AE96:
	jsr	a:stage2_boss_wake_pods
	rtl
loc_02AE9A:
	lda	#$0007
	sta	$12,x

stage2_boss_state_07:
	ldy	difficulty
	lda	a:stage2_boss_core_hp,y
	lsr	a
	cmp	a:td_boss_core_hp
	bcs	loc_02AEB5
	lda	a:boss_target_distance
	cmp	#$7F00
	bcs	loc_02AEB5
	brl	loc_02AFD2
loc_02AEB5:
	lda	#$0020
	sta	$24,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

stage2_boss_state_08:
	dec	$24,x
	bmi	loc_02AED4
	lda	a:td_boss_angle
	inc	a
	inc	a
	and	#$00FF
	sta	a:td_boss_angle
	rtl
loc_02AED4:
	lda	#$002E
	jsl	f:queue_sound
	stz	$16,x
	jsr	a:td_set_players_priority_1
	inc	$12,x

stage2_boss_state_09:
	lda	a:td_boss_angle
	inc	a
	inc	a
	and	#$00FF
	sta	a:td_boss_angle
	dec	a:p1_m7_scale_x
	dec	a:p2_m7_scale_x
	dec	a:p1_m7_scale_y
	dec	a:p2_m7_scale_y
	dec	a:p1_m7_scale_x
	dec	a:p2_m7_scale_x
	dec	a:p1_m7_scale_y
	dec	a:p2_m7_scale_y
	beq	loc_02AF08
	rtl
loc_02AF08:
	lda	#M7_SCALE_1X
	sta	a:p1_m7_scale_x
	sta	a:p2_m7_scale_x
	sta	a:p1_m7_scale_y
	sta	a:p2_m7_scale_y
	lda	#$8000	; [num]
	sta	a:td_boss_x
	sta	a:td_boss_y
	lda	#$0020
	sta	$24,x
	inc	$12,x

stage2_boss_state_0A:
	dec	$24,x
	bmi	loc_02AF2C
	rtl
loc_02AF2C:
	lda	#$002F
	jsl	f:queue_sound
	stz	a:p1_m7_scale_x
	stz	a:p2_m7_scale_x
	stz	a:p1_m7_scale_y
	stz	a:p2_m7_scale_y
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sta	a:td_boss_x
	lda	a:$0ECE,y
	sta	a:td_boss_y
	ldy	difficulty
	lda	a:data_05D7B6,y
	sta	a:td_map_objects+$3C
	lda	a:data_05D7BC,y
	sta	a:td_map_objects+$3A
	inc	$12,x

stage2_boss_state_0B:
	lda	a:td_boss_angle
	clc
	adc	a:td_map_objects+$3C
	and	#$00FF
	sta	a:td_boss_angle
	lda	a:p1_m7_scale_x
	clc
	adc	a:td_map_objects+$3A
	sta	a:p1_m7_scale_x
	lda	a:p2_m7_scale_x
	clc
	adc	a:td_map_objects+$3A
	sta	a:p2_m7_scale_x
	lda	a:p1_m7_scale_y
	clc
	adc	a:td_map_objects+$3A
	sta	a:p1_m7_scale_y
	lda	a:p2_m7_scale_y
	clc
	adc	a:td_map_objects+$3A
	sta	a:p2_m7_scale_y
	cmp	#M7_SCALE_1X
	bcs	loc_02AF99
	rtl
loc_02AF99:
	lda	#$0056
	jsl	f:queue_sound
	lda	#M7_SCALE_1X
	sta	a:p1_m7_scale_x
	sta	a:p2_m7_scale_x
	sta	a:p1_m7_scale_y
	sta	a:p2_m7_scale_y
	jsr	a:td_set_players_priority_2
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0010
	sta	a:screen_shake_timer
	lda	#$0004
	sta	a:screen_shake_offset
	lda	#$0020
	sta	$24,x
	inc	$12,x

stage2_boss_state_0C:
	dec	$24,x
	bpl	@return
	brl	loc_02B02D
@return:
	rtl
loc_02AFD2:
	lda	#$0080
	sta	$24,x
	stz	$26,x
	jsr	a:stage2_boss_aim_jump
	lda	#$000D
	sta	$12,x

stage2_boss_state_0D:
	dec	$24,x
	bmi	loc_02AFFE
	lda	$2C,x
	clc
	adc	#$0010
	sta	$2C,x

stage2_boss_spin:
	lda	$2C,x
	xba
	and	#$00FF
	pha
	jsr	a:td_play_turn_sound
	pla
	clc
	adc	$04,x
	sta	$04,x
	rtl
loc_02AFFE:
	lda	#$0040
	sta	$24,x
	inc	$12,x

stage2_boss_state_0E:
	dec	$24,x
	bmi	loc_02B011
	jsr	a:stage2_boss_move
	jsl	f:stage2_boss_spin
	rtl
loc_02B011:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

stage2_boss_state_0F:
	lda	$2C,x
	sec
	sbc	#$0010
	bpl	loc_02B026
	; (not executed in the CDL traces)
	lda	#$0000
loc_02B026:
	sta	$2C,x
	beq	loc_02B02D
	jmp	a:stage2_boss_spin
loc_02B02D:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	ldy	difficulty
	lda	a:data_05D7C2,y
	sta	$24,x
	lda	#$0010
	sta	$12,x

stage2_boss_state_10:
	dec	$24,x
	bpl	loc_02B048
	brl	loc_02AE9A
loc_02B048:
	jsr	a:stage2_boss_wake_pods
	rtl
loc_02B04C:
	stz	$06,x
	stz	$16,x
	lda	#$0200
	sta	$24,x
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:screen_shake_offset
	lda	#$0011
	sta	$12,x

stage2_boss_state_11:
	jsl	f:td_play_rumble_sound
	jsr	a:stage2_boss_slow_down
	jsr	a:stage2_boss_move
	jsl	f:stage2_boss_spin
	lda	$24,x
	beq	loc_02B0A9
	cmp	#$000C
	bcc	loc_02B0A6
	and	#$0003
	bne	loc_02B0A6
	lda	rng_hi
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0A,x
	sta	a:td_map_objects+1*OBJ_SIZE+OBJ_X
	lda	rng_lo
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0E,x
	sta	a:td_map_objects+1*OBJ_SIZE+OBJ_Y
	phx
	ldx	#$0B00
	jsl	f:td_spawn_explosion_effect
	plx
loc_02B0A6:
	dec	$24,x
	rtl
loc_02B0A9:
	lda	#$8000	; [num]
	sta	$0A,x
	sta	$0E,x
	inc	$12,x

stage2_boss_state_12:
	rtl

stage2_boss_slow_down:
	lda	$2C,x
	beq	loc_02B0C2
	; (not executed in the CDL traces)
	sec
	sbc	#$0020
	bcs	loc_02B0C0
	lda	#$0000
loc_02B0C0:
	sta	$2C,x
loc_02B0C2:
	jsr	a:stage2_boss_slow_down_y
	lda	$1A,x
	ora	$18,x
	beq	loc_02B0F6
	; (not executed in the CDL traces)
	lda	$1A,x
	bmi	loc_02B0E5
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bcs	loc_02B0F6
loc_02B0E0:
	stz	$1A,x
	stz	$18,x
	rts
loc_02B0E5:
	clc
	lda	$18,x
	adc	#$4000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	bcs	loc_02B0E0
loc_02B0F6:
	rts

stage2_boss_slow_down_y:
	lda	$1E,x
	ora	$1C,x
	beq	loc_02B128
	; (not executed in the CDL traces)
	lda	$1E,x
	bmi	loc_02B117
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bcs	loc_02B128
loc_02B112:
	stz	$1E,x
	stz	$1C,x
	rts
loc_02B117:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bcs	loc_02B112
loc_02B128:
	rts

stage2_boss_wake_pods:
	ldy	#$0BC0
@loop:
	lda	a:$0012,y
	cmp	#$0002
	bne	@next
	lda	#$0003
	sta	a:$0012,y
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	@loop
	rts

td_set_players_priority_2:
	lda	a:p1_lives
	beq	loc_02B157
	lda	a:td_p1_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$2000
	sta	a:td_p1_obj+OBJ_ATTR
loc_02B157:
	lda	a:p2_lives
	beq	@return
	; (not executed in the CDL traces)
	lda	a:td_p2_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$2000
	sta	a:td_p2_obj+OBJ_ATTR
@return:
	rts

td_set_players_priority_1:
	lda	a:p1_lives
	beq	loc_02B17A
	lda	a:td_p1_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$1000
	sta	a:td_p1_obj+OBJ_ATTR
loc_02B17A:
	lda	a:p2_lives
	beq	@return
	; (not executed in the CDL traces)
	lda	a:td_p2_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$1000
	sta	a:td_p2_obj+OBJ_ATTR
@return:
	rts

stage2_boss_next_frame:
	lda	stage_frame_counter
	and	#$0003
	bne	loc_02B1A2
	lda	a:boss_anim_frame
	inc	a
	cmp	#$0003
	bcc	loc_02B19F
	lda	#$0000
loc_02B19F:
	sta	a:boss_anim_frame
loc_02B1A2:
	rts

td_select_target_player_long:
	jsr	a:td_select_target_player
	rtl

; Picks the player the boss goes for: the nearest living one; boss_target_player =
; its slot offset (0 or $40), boss_target_distance = half its squared distance.
td_select_target_player:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_02B1B0
	; (not executed in the CDL traces)
	rts
loc_02B1B0:
	lda	#$FFFF	; [num]
	sta	zp_0C
	sta	zp_0E
	lda	a:p1_lives
	beq	loc_02B1D2
	lda	a:td_p1_x
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:td_p1_y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:half_distance_squared
	sta	zp_0C
loc_02B1D2:
	lda	a:p2_lives
	beq	loc_02B1ED
	; (not executed in the CDL traces)
	lda	a:td_p2_x
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:td_p2_y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:half_distance_squared
	sta	zp_0E
loc_02B1ED:
	lda	zp_0C
	cmp	zp_0E
	beq	loc_02B1FE
	bcs	loc_02B204
loc_02B1F5:
	stz	a:boss_target_player
	lda	zp_0C
	sta	a:boss_target_distance
	rts
loc_02B1FE:
	; (not executed in the CDL traces)
	lda	stage_frame_counter
	xba
	lsr	a
	bcc	loc_02B1F5
loc_02B204:
	lda	#$0040
	sta	a:boss_target_player
	lda	zp_0E
	sta	a:boss_target_distance
	rts

stage2_boss_turn_to_player:
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	$04,x
	and	#$00FF
	beq	loc_02B249
	bit	#$0080
	bne	loc_02B239
	lda	$04,x
	inc	a
	bra	loc_02B23C
loc_02B239:
	lda	$04,x
	dec	a
loc_02B23C:
	and	#$00FF
	sta	$04,x
	lda	#$0001
	jsr	a:td_play_turn_sound
	clc
	rts
loc_02B249:
	sec
	rts

stage2_boss_check_facing_player:
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	cmp	$04,x
	bne	loc_02B268
	clc
	rts
loc_02B268:
	sec
	rts

stage2_boss_aim_jump:
	lda	$04,x
	pha
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sta	$04,x
	ldy	difficulty
	lda	a:data_05D7C8,y
	jsl	f:set_velocity_from_angle
	pla
	sta	$04,x
	rts

stage2_boss_move:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rts

; Stage 2 boss map: rotates the point (zp_18, zp_1A) around the boss
; (td_boss_x / td_boss_y) by the angle zp_16 with the hardware multiplier;
; screen position (plus zp_1C / zp_1E) in zp_00 / zp_02. This is the
; boss-centred camera (boss_centered_view).
project_around_stage2_boss:
	lda	a:td_boss_y
	sec
	sbc	zp_1A
	sta	zp_D6
	bpl	loc_02B2BC
	eor	#$FFFF
	inc	a
loc_02B2BC:
	inc	a
	cmp	#$0100
	bcc	loc_02B2C3
loc_02B2C2:
	rtl
loc_02B2C3:
	sta	zp_DE
	lda	a:td_boss_x
	sec
	sbc	zp_18
	sta	zp_D4
	bpl	loc_02B2D3
	eor	#$FFFF
	inc	a
loc_02B2D3:
	inc	a
	cmp	#$0100
	bcs	loc_02B2C2
	sta	a:WRMPYA
	ldy	zp_16
	tya
	sta	zp_D8
	asl	a
	eor	zp_16
	sta	zp_DA
	sep	#$10
	.i8
	ldx	a:data_05D868,y
	stx	a:WRMPYB
	stx	zp_E2
	lda	zp_D4
	eor	zp_D9
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B301
	eor	#$FFFF
	inc	a
loc_02B301:
	sta	zp_00
	ldx	a:data_05D828,y
	stx	a:WRMPYB
	lda	zp_D4
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B31A
	eor	#$FFFF
	inc	a
loc_02B31A:
	sta	zp_02
	ldy	zp_DE
	sty	a:WRMPYA
	stx	a:WRMPYB
	lda	zp_D6
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B334
	eor	#$FFFF
loc_02B334:
	adc	zp_00
	clc
	adc	zp_1C
	sta	zp_00
	ldx	zp_E2
	stx	a:WRMPYB
	lda	zp_D6
	eor	zp_D9
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	loc_02B350
	eor	#$FFFF
loc_02B350:
	adc	zp_1E
	sec
	sbc	zp_02
	sta	zp_02
	rep	#$10
	.i16
	clc
	rtl

; TDMT_STAGE2_BOSS_CORE: the stage 2 boss's weak point, at the centre of the
; body; hittable only while the boss is on the ground. HP 256/384/512
; (stage2_boss_core_hp); below half HP the boss always jumps instead of
; spinning (stage2_boss_state_07).
update_stage2_boss_core:
	jsr	a:stage2_boss_core_position
	lda	#.loword(palette_088C60)
	sta	zp_00
	lda	#$2260
	sta	zp_02
	lda	#$0070
	sta	zp_04
	jsl	f:td_flash_boss_palette_on_hit
	lda	$06,x
	bmi	loc_02B3C6
	lda	a:td_boss_state
	cmp	#$0003
	beq	loc_02B3B6
	cmp	#$0009
	beq	loc_02B3AD
	cmp	#$000C
	beq	loc_02B3B6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage2_boss_core_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_boss_core_states:
	.addr	stage2_boss_core_state_0
	.addr	stage2_boss_core_state_1
	.addr	stage2_boss_core_state_2
	.addr	stage2_boss_core_state_3
	.addr	stage2_boss_core_state_4

stage2_boss_core_state_0:
	ldy	difficulty
	lda	a:stage2_boss_core_hp,y
	sta	$06,x
	stz	$20,x
	stz	$28,x
	stz	$2E,x
loc_02B3AD:
	lda	#$0001
	sta	$12,x

stage2_boss_core_state_1:
	stz	$16,x
	bra	loc_02B3C0
loc_02B3B6:
	lda	#$0002
	sta	$12,x

stage2_boss_core_state_2:
	lda	#$A000	; [num]
	sta	$16,x
loc_02B3C0:
	lda	#$0003
	sta	$12,x

stage2_boss_core_state_3:
	rtl
loc_02B3C6:
	stz	$06,x
	stz	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0041
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

stage2_boss_core_state_4:
	dec	$24,x
	bmi	loc_02B3EB
	lda	$24,x
	bit	#$0003
	bne	@return
	jsl	f:td_spawn_explosion_effect
@return:
	rtl
loc_02B3EB:
	lda	#$0013
	sta	$20,x
	cmp	$28,x
	bne	@return
	brl	clear_topdown_slot
@return:
	rtl

stage2_boss_core_position:
	lda	a:td_map_objects+$3E
	clc
	adc	#$0040
	and	#$007E
	tay
	lda	a:data_05DA64,y
	clc
	adc	a:td_boss_x
	sta	$0A,x
	lda	a:data_05DA44,y
	clc
	adc	a:td_boss_y
	sta	$0E,x
	rts

; TDMT_STAGE2_BOSS_POD: one of the six spiked pods at the ends of the stage 2
; boss's arms (+$14 = arm x2); opens and fires bullets; drops an item when
; destroyed. HP 32/64/128 (stage2_boss_pod_hp).
update_stage2_boss_pod:
	jsr	a:stage2_boss_pod_position
	jsl	f:stage2_boss_pod_run_state
	lda	$2A,x
	bne	loc_02B442
	lda	$2E,x
	bit	#$0040
	beq	loc_02B44D
	lda	$20,x
	sta	$2A,x
	ldy	$14,x
	lda	a:data_05D98C,y
	sta	$20,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	lda	#$0010
	jsl	f:queue_sound
	rtl
loc_02B442:
	sta	$20,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_02B44D:
	rtl

stage2_boss_pod_run_state:
	lda	$06,x
	bpl	loc_02B455
	brl	loc_02B502
loc_02B455:
	lda	a:td_boss_state
	cmp	#$0011
	bcc	loc_02B460
	; (not executed in the CDL traces)
	brl	loc_02B502
loc_02B460:
	cmp	#$0003
	beq	loc_02B4A6
	cmp	#$0009
	beq	loc_02B49E
	cmp	#$000C
	beq	loc_02B4A6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage2_boss_pod_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_boss_pod_states:
	.addr	stage2_boss_pod_state_0
	.addr	stage2_boss_pod_state_1
	.addr	stage2_boss_pod_state_2
	.addr	stage2_boss_pod_state_3
	.addr	stage2_boss_pod_state_4
	.addr	stage2_boss_pod_state_5
	.addr	stage2_boss_pod_state_6
	.addr	stage2_boss_pod_state_7

stage2_boss_pod_state_0:
	ldy	difficulty
	lda	a:stage2_boss_pod_hp,y
	sta	$06,x
	lda	#$2000
	sta	$02,x
	stz	$2A,x
	stz	$2E,x
loc_02B49E:
	lda	#$0001
	sta	$12,x

stage2_boss_pod_state_1:
	stz	$16,x
	rtl
loc_02B4A6:
	lda	#$0002
	sta	$12,x

stage2_boss_pod_state_2:
	ldy	$14,x
	lda	a:data_05D968,y
	sta	$20,x
	lda	#$B000	; [num]
	sta	$16,x
	rtl

stage2_boss_pod_state_3:
	ldy	$14,x
	lda	a:data_05D974,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0004
	sta	$12,x

stage2_boss_pod_state_4:
	dec	$24,x
	bne	loc_02B501
	ldy	$14,x
	lda	a:data_05D980,y
	sta	$20,x
	lda	#$0020
	sta	$24,x
	inc	$12,x

stage2_boss_pod_state_5:
	dec	$24,x
	bmi	loc_02B4EF
	lda	$24,x
	and	#$000F
	bne	@return
	jsr	a:stage2_boss_pod_fire
@return:
	rtl
loc_02B4EF:
	ldy	$14,x
	lda	a:data_05D974,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

stage2_boss_pod_state_6:
	dec	$24,x
	beq	loc_02B4A6
loc_02B501:
	rtl
loc_02B502:
	lda	#$0007
	cmp	$12,x
	beq	stage2_boss_pod_state_7
	sta	$12,x
	stz	$16,x
	lda	#$0041
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x

stage2_boss_pod_state_7:
	dec	$24,x
	bmi	loc_02B529
	lda	$24,x
	bit	#$0003
	bne	loc_02B528
	jsl	f:td_spawn_explosion_effect
loc_02B528:
	rtl
loc_02B529:
	ldy	$14,x
	lda	a:data_05D998,y
	sta	$20,x
	cmp	$28,x
	bne	loc_02B528
	lda	a:td_boss_state
	cmp	#$0011
	beq	loc_02B528
	jsr	a:stage2_boss_pod_drop_item
	bcs	@return
	brl	clear_topdown_slot
@return:
	rtl

stage2_boss_pod_drop_item:
	jsl	f:td_find_free_item_slot
	bcs	loc_02B583
	lda	rng_hi
	and	#$0004
	sta	zp_FA
	lda	rng_lo
	and	#$0003
	ora	zp_FA
	asl	a
	phy
	tay
	lda	a:stage2_boss_pod_drop_kinds,y
	ply
	sta	a:$0014,y
	cmp	#$0000
	beq	loc_02B582
	asl	a
	phy
	tay
	lda	a:stage2_boss_pod_item_types,y
	ply
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
loc_02B582:
	clc
loc_02B583:
	rts

stage2_boss_pod_position:
	ldy	$14,x
	lda	a:td_map_objects+$3E
	clc
	adc	a:data_05DC04,y
	and	#$007E
	tay
	lda	a:data_05DB04,y
	clc
	adc	a:td_boss_x
	sta	$0A,x
	lda	a:data_05DAE4,y
	clc
	adc	a:td_boss_y
	sta	$0E,x
	rts

stage2_boss_pod_fire:
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	ldy	#$0000
	jsl	f:td_fire_enemy_bullet
	rts

; TDMT_STAGE2_BOSS_CANNON: the cannon turning around the stage 2 boss's body
; ($3A pixels from the centre); fires bullets (flames on HARD,
; TDS_CANNON_FLAME). HP 128/192/256 (stage2_boss_cannon_hp).
update_stage2_boss_cannon:
	jsl	f:stage2_boss_cannon_run_state
	jml	f:td_flash_enemy_on_hit

stage2_boss_cannon_run_state:
	jsl	f:td_play_hit_sound
	jsr	a:stage2_boss_cannon_position
	lda	$06,x
	bpl	loc_02B5C8
	brl	loc_02B66E
loc_02B5C8:
	lda	a:td_boss_state
	cmp	#$0011
	bcc	loc_02B5D3
	; (not executed in the CDL traces)
	brl	loc_02B66E
loc_02B5D3:
	cmp	#$0002
	beq	loc_02B636
	cmp	#$0003
	beq	loc_02B61B
	cmp	#$0004
	beq	loc_02B61B
	cmp	#$0006
	beq	loc_02B648
	cmp	#$0009
	beq	loc_02B636
	cmp	#$000C
	beq	loc_02B61B
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage2_boss_cannon_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage2_boss_cannon_states:
	.addr	stage2_boss_cannon_state_0
	.addr	stage2_boss_cannon_state_1
	.addr	stage2_boss_cannon_state_2
	.addr	stage2_boss_cannon_state_3
	.addr	stage2_boss_cannon_state_4

stage2_boss_cannon_state_0:
	ldy	difficulty
	lda	a:stage2_boss_cannon_hp,y
	sta	$06,x
	jsr	a:stage2_boss_cannon_close
	stz	$2E,x
	lda	a:td_boss_angle
	sta	$04,x
loc_02B61B:
	lda	#$0001
	cmp	$12,x
	beq	stage2_boss_cannon_state_1
	sta	$12,x
	jsr	a:stage2_boss_cannon_open
	lda	#$A000	; [num]
	sta	$16,x

stage2_boss_cannon_state_1:
	lda	a:td_boss_angle
	jsr	a:td_turn_towards_angle
	jsr	a:stage2_boss_cannon_end_anim
	rtl
loc_02B636:
	lda	#$0002
	cmp	$12,x
	beq	stage2_boss_cannon_state_2
	sta	$12,x
	jsr	a:stage2_boss_cannon_close

stage2_boss_cannon_state_2:
	lda	a:td_boss_angle
	sta	$04,x
	rtl
loc_02B648:
	lda	#$0003
	cmp	$12,x
	beq	stage2_boss_cannon_state_3
	sta	$12,x
	jsr	a:stage2_boss_cannon_open
	lda	#$A000	; [num]
	sta	$16,x

stage2_boss_cannon_state_3:
	jsr	a:stage2_boss_cannon_end_anim
	ldy	a:td_map_objects+$26
	lda	$04,x
	clc
	adc	a:data_05D81E,y
	and	#$00FF
	sta	$04,x
	jsr	a:stage2_boss_cannon_fire
	rtl
loc_02B66E:
	lda	#$0004
	cmp	$12,x
	beq	stage2_boss_cannon_state_4
	sta	$12,x
	stz	$16,x
	lda	#$0041
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x
	lda	#$0004
	sta	$12,x

stage2_boss_cannon_state_4:
	dec	$24,x
	bmi	loc_02B69A
	lda	$24,x
	bit	#$0003
	bne	@return
	jsl	f:td_spawn_explosion_effect
@return:
	rtl
loc_02B69A:
	lda	#$141C
	sta	$26,x
	stz	$00,x
	lda	#$0012
	sta	$20,x
	cmp	$28,x
	bne	@return
	brl	clear_topdown_slot
@return:
	rtl

stage2_boss_cannon_end_anim:
	lda	$28,x
	cmp	$20,x
	bne	@return
	lda	#$0002
	sta	$00,x
	lda	#$2000
	sta	$02,x
	stz	$28,x
	stz	$20,x
@return:
	rts

stage2_boss_cannon_close:
	lda	#$0036
	sta	$20,x
	lda	#$149C
	sta	$26,x
	stz	$00,x
	stz	$02,x
	rts

stage2_boss_cannon_open:
	lda	$00,x
	bne	@return
	lda	#$0037
	sta	$20,x
	lda	#$149C
	sta	$26,x
	stz	$00,x
	stz	$02,x
@return:
	rts

stage2_boss_cannon_position:
	lda	a:td_boss_angle
	ldy	#$003A
	jsl	f:polar_to_xy
	lda	zp_08
	clc
	adc	a:td_boss_x
	sta	$0A,x
	lda	zp_0A
	clc
	adc	a:td_boss_y
	sta	$0E,x
	rts

td_turn_towards_angle:
	sec
	sbc	$04,x
	and	#$00FF
	beq	loc_02B71C
	bit	#$0080
	bne	loc_02B712
	lda	$04,x
	inc	a
	bra	loc_02B715
loc_02B712:
	lda	$04,x
	dec	a
loc_02B715:
	and	#$00FF
	sta	$04,x
	clc
	rts
loc_02B71C:
	sec
	rts

stage2_boss_cannon_fire:
	ldy	difficulty
	cpy	#$0004
	bcs	loc_02B734
	lda	stage_frame_counter
	and	a:stage2_boss_cannon_fire_masks,y
	bne	@return
	ldy	#$001C
	jsl	f:td_fire_enemy_bullet
@return:
	rts
loc_02B734:
	; (not executed in the CDL traces)
	jsl	f:td_find_free_enemy_shot_slot
	bcs	loc_02B77C
	lda	stage_frame_counter
	and	#$000F
	bne	loc_02B748
	lda	#$0014
	jsl	f:queue_sound
loc_02B748:
	lda	#TDS_CANNON_FLAME
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$04,x
	sta	a:$0004,y
	clc
	adc	#$0002
	lsr	a
	lsr	a
	asl	a
	and	#$007E
	phx
	tax
	lda	a:data_05D9A4,x
	sta	zp_08
	lda	a:data_05D9C4,x
	plx
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	zp_08
	clc
	adc	$0E,x
	sta	a:$000E,y
loc_02B77C:
	rts

stage2_boss_stream_chr:
	lda	#$0040
	sta	a:boss_chr_stream_vram
	lda	#$007E
	sta	a:boss_chr_stream_bank
	lda	#$0600
	sta	a:boss_chr_stream_size
	lda	a:boss_anim_frame
	asl	a
	tay
	lda	a:data_05DC30,y
	sta	a:boss_chr_stream_src
	rtl

td_play_turn_sound:
	cmp	#$0000
	beq	loc_02B7C8
	bpl	loc_02B7A6
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
loc_02B7A6:
	pha
	cmp	#$0008
	bcc	loc_02B7AF
	lda	#$0008
loc_02B7AF:
	asl	a
	tay
	pla
	clc
	adc	a:turn_sound_counter
	sta	a:turn_sound_counter
	cmp	a:data_05DC34,y
	bcc	loc_02B7C8
	stz	a:turn_sound_counter
	lda	a:data_05DC44,y
	jsl	f:queue_sound
loc_02B7C8:
	rts

td_play_rumble_sound:
	lda	#$006E
	ldy	a:rumble_sound_timer
	bpl	loc_02B7E2
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:rumble_sound_timer
	pla
	jsl	f:queue_sound
loc_02B7E2:
	dec	a:rumble_sound_timer
	rtl

; Runs the shots: player 1's ($0480-$06FF), player 2's ($0700-$097F) and the
; others ($0300-$047F), by type + 8 (tbl_topdown_shot_types).
update_topdown_shots:
	ldy	#$0EC0
	sty	zp_18
	lda	a:$0002,y
	and	#$3000
	sta	zp_1A
	ldx	#$0480
@loop:
	lda	$10,x
	beq	@next
	jsl	f:run_topdown_shot_handler
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcc	@loop
	lda	a:title_menu_cursor
	beq	loc_02B82E
	ldy	#$0F00
	sty	zp_18
	lda	a:$0002,y
	and	#$3000
	sta	zp_1A
@loop2:
	lda	$10,x
	beq	@next2
	jsl	f:run_topdown_shot_handler
@next2:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcc	@loop2
loc_02B82E:
	ldx	#$0300
@loop:
	lda	$10,x
	beq	@next
	jsl	f:run_topdown_shot_handler
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop
	rtl

run_topdown_shot_handler:
	clc
	adc	#$0008
	phx
	asl	a
	tax
	lda	f:tbl_topdown_shot_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_topdown_shot_types:
	.addr	td_shot_hidden
	.addr	td_shot_hidden
	.addr	td_shot_hidden
	.addr	td_shot_hidden
	.addr	td_shot_hidden
	.addr	td_shot_hidden
	.addr	update_td_shot_impact
	.addr	td_shot_hidden
	.addr	td_shot_type_none
	.addr	update_td_default_shot
	.addr	update_td_default_shot
	.addr	update_td_spread_shot
	.addr	update_td_enemy_bullet
	.addr	update_td_homing_shot
	.addr	update_td_laser_shot
	.addr	update_td_flame_shot
	.addr	update_td_crush_missile
	.addr	update_td_crush_blast
	.addr	update_td_crush_blast_part
	.addr	update_td_boss_spit
	.addr	update_td_cannon_flame
	.addr	update_td_enemy_orb
	.addr	update_td_homing_orb

; TDS_ENEMY_BULLET: $40 frames, ends on walls (td_check_enemy_shot_tile).
update_td_enemy_bullet:
	lda	$12,x
	bne	loc_02B8AA
	lda	#$0040
	sta	$12,x
	lda	#$0003
	sta	$06,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	#$01F4
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	$02,x
	and	#$3000
	sta	$02,x
	bra	loc_02B8B8
loc_02B8AA:
	dec	$12,x
	beq	td_end_shot
	jsl	f:td_check_enemy_shot_tile
	bcs	td_end_shot
	jsl	f:move_td_shot
loc_02B8B8:
	lda	$12,x
	and	#$0006
	tay
	lda	$02,x
	and	#$3000
	ora	a:data_05DC56,y
	sta	$02,x
	rtl

update_td_shot_impact:
	dec	$12,x
	bne	td_shot_type_none
loc_02B8CD:
	stz	$10,x
	stz	$00,x

td_shot_type_none:
	rtl

; Shot X hit something: becomes TDS_IMPACT (a spark), except the flame and
; the crush blasts; a crush missile explodes.
td_end_shot:
	lda	$10,x
	cmp	#TDS_FLAME
	beq	loc_02B913
	cmp	#TDS_CRUSH
	bne	loc_02B8E1
	brl	loc_02BC8B
loc_02B8E1:
	cmp	#TDS_CRUSH_BLAST
	beq	loc_02B913
	cmp	#TDS_CRUSH_BLAST_PART
	beq	loc_02B913
	cmp	#TDS_BOSS_SPIT
	beq	loc_02B913
	lda	#TDS_IMPACT
	sta	$10,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	#$0101
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0004
	sta	$16,x
	lda	#$0002
	sta	$12,x
loc_02B913:
	rtl

td_shot_hidden:
	stz	$00,x
	lda	#$FFFF	; [num]
	sta	$04,x
	rtl

; TDS_DEFAULT (and type 1): 16 frames at speed $80, damage 2.
update_td_default_shot:
	lda	$12,x
	bne	loc_02B94C
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0080
	jsl	f:set_velocity_from_angle
	stz	$08,x
	stz	$0C,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	#$0100
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	rtl
loc_02B94C:
	dec	$12,x
	bne	loc_02B953
	brl	td_end_shot
loc_02B953:
	jsl	f:td_check_shot_tile
	bcc	move_td_shot
	brl	td_end_shot

move_td_shot:
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sta	$0E,x
	rtl

; TDS_SPREAD: as TDS_DEFAULT, bigger after 8 frames; damage 2.
update_td_spread_shot:
	lda	$12,x
	bne	loc_02B9A7
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0080
	jsl	f:set_velocity_from_angle
	stz	$08,x
	stz	$0C,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	#$0110
	sta	$00,x
	lda	#$0004
	sta	$16,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	rtl
loc_02B9A7:
	cmp	#$0008
	bne	loc_02B9B6
	lda	#$0102
	sta	$00,x
	lda	#$0008
	sta	$16,x
loc_02B9B6:
	dec	$12,x
	bne	loc_02B9BD
	brl	td_end_shot
loc_02B9BD:
	jsl	f:td_check_shot_tile
	bcc	loc_02B9C6
	brl	td_end_shot
loc_02B9C6:
	jmp	a:move_td_shot

; TDS_HOMING: picks a visible hittable target (+$16 bit 13, cycling with
; homing_target_cursor) and turns towards it 8 units a frame; $40 frames, damage 2.
update_td_homing_shot:
	lda	$12,x
	beq	loc_02B9D0
	brl	loc_02BA83
loc_02B9D0:
	lda	#$0040
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0000
	sta	$00,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	lda	#$0080
	jsl	f:set_velocity_from_angle
	lda	a:boss_centered_view
	bne	loc_02BA3F
	ldy	a:homing_target_cursor
	bne	loc_02BA06
	ldy	#$0AC0
	sty	a:homing_target_cursor
loc_02BA06:
	lda	a:$0016,y
	bit	#$2000
	beq	loc_02BA29
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02BA29
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA25
	lda	#$0AC0
loc_02BA25:
	sta	a:homing_target_cursor
	rtl
loc_02BA29:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA36
	lda	#$0AC0
loc_02BA36:
	tay
	cpy	a:homing_target_cursor
	bne	loc_02BA06
	stz	$14,x
	rtl
loc_02BA3F:
	; (not executed in the CDL traces)
	ldy	a:homing_target_cursor
	bne	loc_02BA4A
	ldy	#$0AC0
	sty	a:homing_target_cursor
loc_02BA4A:
	lda	a:$0016,y
	bit	#$2000
	beq	loc_02BA6D
	lda	a:$002E,y
	bit	#$0003
	beq	loc_02BA6D
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA69
	lda	#$0AC0
loc_02BA69:
	sta	a:homing_target_cursor
	rtl
loc_02BA6D:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	loc_02BA7A
	lda	#$0AC0
loc_02BA7A:
	tay
	cpy	a:homing_target_cursor
	bne	loc_02BA4A
	stz	$14,x
	rtl
loc_02BA83:
	dec	$12,x
	bne	loc_02BA8A
	brl	td_end_shot
loc_02BA8A:
	jsl	f:td_check_shot_tile
	bcc	loc_02BA93
	brl	td_end_shot
loc_02BA93:
	lda	$12,x
	cmp	#$000A
	bcc	loc_02BAA2
	jsl	f:td_homing_shot_turn
	jsl	f:td_homing_shot_set_velocity
loc_02BAA2:
	jmp	a:move_td_shot

td_homing_shot_turn:
	ldy	$14,x
	beq	loc_02BAE3
	lda	a:$0010,y
	beq	loc_02BAE3
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	$04,x
	beq	loc_02BAE3
	bit	#$0080
	bne	loc_02BAD8
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rtl
loc_02BAD8:
	lda	$04,x
	sec
	sbc	#$0008
	and	#$00FF
	sta	$04,x
loc_02BAE3:
	rtl

td_homing_shot_set_velocity:
	lda	#$0080
	jsl	f:set_velocity_from_angle
	rtl

; TDS_LASER: a segment kept at a distance ahead of the player; 7 frames,
; damage 4.
update_td_laser_shot:
	lda	$12,x
	bne	loc_02BB08
	lda	#$0007
	sta	$12,x
	lda	#$0004
	sta	$06,x
	lda	#$0100
	sta	$00,x
	lda	#$0008
	sta	$16,x
	lda	zp_1A
	sta	$02,x
loc_02BB08:
	ldy	zp_18
	lda	a:$0004,y
	clc
	adc	$1A,x
	pha
	jsr	a:td_get_laser_muzzle_distance
	pla
	jsl	f:polar_to_xy
	lda	zp_08
	sta	zp_FC
	lda	zp_0A
	sta	zp_FE
	ldy	zp_18
	lda	a:$0004,y
	clc
	adc	$0C,x
	and	#$00FF
	sta	$04,x
	lda	#$0007
	sec
	sbc	$12,x
	asl	a
	tay
	lda	a:data_05DC62,y
	tay
	lda	$04,x
	jsl	f:polar_to_xy
	ldy	zp_18
	lda	a:$000A,y
	clc
	adc	zp_08
	clc
	adc	zp_FC
	sta	$0A,x
	lda	a:$000E,y
	clc
	adc	zp_0A
	clc
	adc	zp_FE
	sta	$0E,x
	dec	$12,x
	bne	loc_02BB5F
	brl	td_end_shot
loc_02BB5F:
	jsl	f:td_check_shot_tile
	bcc	td_flicker_shot
	brl	td_end_shot

td_flicker_shot:
	ldy	#$0000
	lda	stage_frame_counter
	bit	#$0002
	bne	loc_02BB75
	ldy	#$0002
loc_02BB75:
	lda	$02,x
	and	#$3000
	ora	a:data_05DC7A,y
	sta	$02,x
	rtl

td_get_laser_muzzle_distance:
	ldy	zp_18
	lda	a:$0012,y
	ldy	#$0022
	cmp	#$0005
	beq	@return
	ldy	#$001E
	cmp	#$0007
	beq	@return
	ldy	#$0017
@return:
	rts

; TDS_FLAME: flame in front of the player, 14 frames, damage 1.
update_td_flame_shot:
	lda	$12,x
	bne	loc_02BBCC
	lda	#$000E
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:td_flame_shot_frame
	lda	$14,x
	sta	$18,x
	lda	$08,x
	sta	$0A,x
	sta	$1A,x
	lda	$0C,x
	sta	$0E,x
	sta	$1E,x
	rtl
loc_02BBCC:
	dec	$12,x
	bne	loc_02BBD3
	brl	loc_02B8CD
loc_02BBD3:
	jsl	f:td_check_shot_tile
	jsr	a:td_flame_shot_frame
	lda	$18,x
	sta	zp_10
	lda	$1A,x
	sta	zp_12
	lda	$1E,x
	sta	zp_14
	lda	#$000E
	sec
	sbc	$12,x
	and	#$000E
	tay
	lda	a:data_05DCFC,y
	tay
	lda	$14,x
	sta	$18,x
	jsl	f:polar_to_xy
	lda	$08,x
	sta	$1A,x
	clc
	adc	zp_08
	sta	$0A,x
	lda	$0C,x
	sta	$1E,x
	clc
	adc	zp_0A
	sta	$0E,x
	lda	zp_10
	sta	$14,x
	lda	zp_12
	sta	$08,x
	lda	zp_14
	sta	$0C,x
	rtl

td_flame_shot_frame:
	lda	$12,x
	ldy	#$0000
	cmp	#$000A
	bcs	loc_02BC30
	ldy	#$0010
	cmp	#$0006
	bcs	loc_02BC30
	ldy	#$0020
loc_02BC30:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:data_05DC86,y
	sta	$00,x
	rts

; TDS_CRUSH: 16 frames, damage 2; on a hit becomes TDS_CRUSH_BLAST.
update_td_crush_missile:
	lda	$12,x
	bne	loc_02BC66
	lda	#$0010
	sta	$12,x
	lda	#$0002
	sta	$06,x
	lda	#$0200
	sta	$00,x
	lda	zp_1A
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	stz	$08,x
	stz	$0C,x
	rtl
loc_02BC66:
	dec	$12,x
	bne	loc_02BC6D
	brl	loc_02BCDE
loc_02BC6D:
	jsl	f:td_check_shot_tile
	bcs	loc_02BC8B
	lda	$1A,x
	pha
	lda	$1E,x
	pha
	lda	#$0080
	jsl	f:set_velocity_from_angle
	jsl	f:move_td_shot
	pla
	sta	$1E,x
	pla
	sta	$1A,x
	rtl
loc_02BC8B:
	stz	$12,x
	lda	#TDS_CRUSH_BLAST
	sta	$10,x
	rtl

; TDS_CRUSH_BLAST: $40 frames of explosions around the hit point, damage 1;
; starts its two TDS_CRUSH_BLAST_PART slots.
update_td_crush_blast:
	lda	$12,x
	bne	loc_02BCDA
	lda	#$0040
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF	; [num]
	sta	$04,x
	jsl	f:td_crush_blast_frame
	lda	$0A,x
	sta	$18,x
	lda	$0E,x
	sta	$1C,x
loc_02BCB2:
	lda	rng_lo
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_00
	lda	rng_hi
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_02
	lda	$18,x
	clc
	adc	zp_00
	sta	$0A,x
	lda	$1C,x
	clc
	adc	zp_02
	sta	$0E,x
	jml	f:td_check_shot_tile
loc_02BCDA:
	dec	$12,x
	bne	loc_02BCF4
loc_02BCDE:
	lda	#$0000
	ldy	$1A,x
	sta	a:$0010,y
	sta	a:$0012,y
	ldy	$1E,x
	sta	a:$0010,y
	sta	a:$0012,y
	jmp	a:loc_02B8CD
loc_02BCF4:
	jsl	f:td_check_shot_tile
	jsl	f:td_crush_blast_frame
	lda	$12,x
	and	#$0007
	beq	loc_02BCB2
	ldy	$1A,x
	cmp	#$0002
	beq	loc_02BD12
	ldy	$1E,x
	cmp	#$0005
	beq	loc_02BD12
	rtl
loc_02BD12:
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_CRUSH_BLAST_PART
	sta	a:$0010,y
	stx	$1A,y
	rtl

update_td_crush_blast_part:
	lda	$12,x
	bne	loc_02BD6D
	lda	#$0008
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$FFFF	; [num]
	sta	$04,x
	ldy	a:$001A,x
	lda	a:$0002,y
	sta	$02,x
	jsl	f:td_crush_blast_frame
	lda	rng_lo
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_00
	lda	rng_hi
	and	#$001F
	sec
	sbc	#$0010
	sta	zp_02
	ldy	a:$001A,x
	lda	a:$0018,y
	clc
	adc	zp_00
	sta	$0A,x
	lda	a:$001C,y
	clc
	adc	zp_02
	sta	$0E,x
	jml	f:td_check_shot_tile
loc_02BD6D:
	dec	$12,x
	bne	loc_02BD77
	; (not executed in the CDL traces)
	lda	#TDS_HIDDEN
	sta	$10,x
	rtl
loc_02BD77:
	jsl	f:td_check_shot_tile

td_crush_blast_frame:
	lda	#$0008
	sec
	sbc	$12,x
	asl	a
	and	#$000E
	tay
	lda	a:data_05DCC6,y
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	a:data_05DCD6,y
	sta	$02,x
	lda	a:data_05DCE6,y
	sta	$16,x
	rtl

; TDS_CANNON_FLAME: the stage 2 boss cannon's flame on HARD (not executed in
; the CDL traces).
update_td_cannon_flame:
	; (not executed in the CDL traces)
	lda	$12,x
	bne	loc_02BDC1
	lda	#$0007
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	#$0100
	sta	$00,x
	lda	#$0008
	sta	$16,x
	lda	#$2C00
	sta	$02,x
	jsl	f:td_check_enemy_shot_tile
	jsl	f:td_flicker_shot
	rtl
loc_02BDC1:
	lda	#$0007
	sec
	sbc	$12,x
	asl	a
	tay
	lda	a:data_05DC62,y
	clc
	adc	#$0020
	tay
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_ANGLE
	sta	$04,x
	jsl	f:polar_to_xy
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	zp_08
	sta	$0A,x
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	zp_0A
	sta	$0E,x
	dec	$12,x
	bne	loc_02BDF1
	brl	td_end_shot
loc_02BDF1:
	jsl	f:td_check_shot_tile
	bcc	loc_02BDFA
	brl	td_end_shot
loc_02BDFA:
	jmp	a:td_flicker_shot

; TDS_BOSS_SPIT: shot spat by the stage 5 boss (stage5_boss_spawn_spit).
update_td_boss_spit:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_boss_spit_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_boss_spit_states:
	.addr	td_boss_spit_state_0
	.addr	td_boss_spit_state_1
	.addr	td_boss_spit_state_2
	.addr	td_boss_spit_state_3

td_boss_spit_state_0:
	lda	#$0001
	sta	$06,x
	lda	#$FFFF	; [num]
	sta	$04,x
	lda	#$0008
	sta	$16,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	inc	$12,x

td_boss_spit_state_1:
	jsr	a:td_boss_spit_frame
	lda	$14,x
	beq	@return
	jsl	f:move_td_shot
@return:
	rtl

td_boss_spit_state_2:
	lda	#$0004
	sta	$14,x
	lda	#$018E
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	stz	$06,x
	lda	#$0003
	sta	$12,x

td_boss_spit_state_3:
	dec	$14,x
	bpl	loc_02BE5D
	brl	loc_02B8CD
loc_02BE5D:
	jsl	f:move_td_shot
	rtl

td_boss_spit_frame:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	lda	a:data_05DCA6,y
	sta	$00,x
	rts

; TDS_ENEMY_ORB: $40 frames straight ahead.
update_td_enemy_orb:
	lda	$12,x
	bne	loc_02BE8F
	lda	#$0040
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:td_enemy_orb_frame
loc_02BE8F:
	dec	$12,x
	bne	loc_02BE96
	brl	loc_02B8CD
loc_02BE96:
	jsr	a:td_enemy_orb_frame
	lda	$04,x
	and	#$00FF
	sta	$04,x
	lda	$04,x
	and	#$00FF
	sta	$04,x
	lda	#$0020
	jsl	f:set_velocity_from_angle
	lda	$04,x
	ora	#$FF00
	sta	$04,x
	jsl	f:move_td_shot
	rtl

; TDS_HOMING_ORB: $80 frames, steering towards the player in +$14
; (td_homing_orb_steer, rate by difficulty).
update_td_homing_orb:
	lda	$12,x
	bne	loc_02BEDA
	lda	#$0080
	sta	$12,x
	lda	#$0001
	sta	$06,x
	lda	$02,x
	and	#$3000
	ora	#$0E00
	sta	$02,x
	lda	#$0008
	sta	$16,x
	jsr	a:td_homing_orb_frame
loc_02BEDA:
	dec	$12,x
	bne	loc_02BEE1
	brl	loc_02B8CD
loc_02BEE1:
	jsr	a:td_homing_orb_frame
	lda	$04,x
	and	#$00FF
	sta	$04,x
	jsr	a:td_homing_orb_steer
	lda	#$0020
	jsl	f:set_velocity_from_angle
	lda	$04,x
	ora	#$FF00
	sta	$04,x
	jsl	f:move_td_shot
	rtl

td_homing_orb_steer:
	ldy	$14,x
	lda	a:$000A,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$000E,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	$04,x
	bit	#$0080
	bne	loc_02BF2D
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DCF6,y
	and	#$00FF
	sta	$04,x
	rts
loc_02BF2D:
	ldy	difficulty
	lda	$04,x
	sec
	sbc	a:data_05DCF6,y
	and	#$00FF
	sta	$04,x
	rts

td_enemy_orb_frame:
	lda	$12,x
	ldy	#$0000
	cmp	#$0038
	bcs	loc_02BF58
	ldy	#$0010
	cmp	#$0030
	bcs	loc_02BF58
	ldy	#$0020
	cmp	#$0008
	bcs	loc_02BF58
	ldy	#$0030
loc_02BF58:
	bra	loc_02BF77

td_homing_orb_frame:
	lda	$12,x
	ldy	#$0000
	cmp	#$0078
	bcs	loc_02BF77
	ldy	#$0010
	cmp	#$0070
	bcs	loc_02BF77
	ldy	#$0020
	cmp	#$0008
	bcs	loc_02BF58
	ldy	#$0030
loc_02BF77:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:data_05DC86,y
	sta	$00,x
	rts

; Player shot X against the tile attribute map: carry set when it hits a wall
; or a map object tile (TDA_MAP_OBJECT, which damages that object).
td_check_shot_tile:
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	bne	loc_02BF93
	clc
	rtl
loc_02BF93:
	jsr	a:td_shot_tile_effect
	jsr	a:td_check_lower_level_x
	rtl

td_shot_tile_effect:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	beq	loc_02BFE1
	bit	#TDA_SPECIAL
	bne	loc_02BFE4
	plx
	bit	#TDA_SET_PRIORITY
	beq	loc_02BFDA
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	loc_02BFCE
	ldy	#$0000
loc_02BFCE:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
	pla
loc_02BFDA:
	and	#TDA_WALL_MASK
	beq	loc_02BFE2
loc_02BFDF:
	sec
	rts
loc_02BFE1:
	plx
loc_02BFE2:
	clc
	rts
loc_02BFE4:
	plx
	cmp	#TDA_MAP_OBJECT
	bne	loc_02BFE2
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_02C007
	ldy	#$0EC0
	cpx	#$0700
	bcc	loc_02BFFD
	; (not executed in the CDL traces)
	ldy	#$0F00
loc_02BFFD:
	lda	a:$0012,y
	cmp	#$0005
	beq	loc_02BFDF
	bra	loc_02BFE2
loc_02C007:
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	loc_02C02C
	bit	#$1000
	beq	loc_02C02C
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	loc_02C02C
	jsl	f:td_score_shot_kill
loc_02C02C:
	sec
	rts

; Enemy shot X against the tile attribute map: carry set on a wall.
td_check_enemy_shot_tile:
	lda	a:boss_centered_view
	beq	loc_02C035
	clc
	rtl
loc_02C035:
	jsr	a:td_enemy_shot_tile_effect
	jsr	a:td_check_lower_level_x
	rtl

td_enemy_shot_tile_effect:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	beq	loc_02C05F
	bit	#TDA_SPECIAL
	beq	loc_02C062
loc_02C05F:
	plx
loc_02C060:
	clc
	rts
loc_02C062:
	plx
	bit	#TDA_SET_PRIORITY
	beq	loc_02C07F
	ldy	#$0000
	bit	#TDA_PRIORITY_HIGH
	beq	loc_02C073
	ldy	#$0002
loc_02C073:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
	pla
loc_02C07F:
	and	#TDA_WALL_MASK
	beq	loc_02C060
	sec
	rts

; Enemy X against the tile attribute map: corners (td_read_enemy_corner_tiles),
; walls (td_push_out_of_walls), special tiles (td_enemy_tile_effect).
td_enemy_tile_collision:
	lda	a:boss_centered_view
	beq	loc_02C08D
	; (not executed in the CDL traces)
	clc
	rtl
loc_02C08D:
	jsr	a:td_read_enemy_corner_tiles
	jsr	a:td_push_out_of_walls
	jsr	a:td_enemy_tile_effect
	rtl

td_enemy_tile_effect:
	lda	$0E,x
	bpl	loc_02C09D
loc_02C09B:
	sec
	rts
loc_02C09D:
	lda	$0A,x
	bmi	loc_02C09B
	lda	zp_04
	beq	td_tile_no_effect
	bit	#TDA_SPECIAL
	beq	loc_02C105
	eor	#$00FF
	phx
	asl	a
	tax
	lda	f:tbl_td_enemy_special_tiles,x
	plx
	sta	zp_00
	jmp	(zp_00)
; Indexed by $FF - attribute (TDA_HOLE first).
tbl_td_enemy_special_tiles:
	.addr	td_tile_kill_enemy
	.addr	td_tile_no_effect
	.addr	td_tile_no_effect
	.addr	td_tile_no_effect
	.addr	td_tile_no_effect
	.addr	td_tile_whirl_enemy
	.addr	td_tile_no_effect
	.addr	td_tile_push_down
	.addr	td_tile_push_up
	.addr	td_tile_push_left
	.addr	td_tile_push_right
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy
	.addr	td_tile_kill_enemy

td_tile_kill_enemy:
	lda	#$FFFF	; [num]
	sta	$06,x
	sec
	rts

td_tile_whirl_enemy:
	jsr	a:td_whirl_around_cell
	bcc	loc_02C104
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	tya
	bne	loc_02C103
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_02C103
	dec	$06,x
loc_02C103:
	clc
loc_02C104:
	rts
loc_02C105:
	bit	#TDA_SET_PRIORITY
	beq	loc_02C11F
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	loc_02C115
	ldy	#$0000
loc_02C115:
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
loc_02C11F:
	sec
	rts

td_tile_no_effect:
	clc
	rts

td_read_enemy_corner_tiles:
	lda	$02,x
	bit	#$2000
	bne	loc_02C12D
	brl	loc_02C2DF
loc_02C12D:
	lda	$0E,x
	bit	#$0004
	bne	loc_02C14C
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	loc_02C147
	brl	loc_02C26A
loc_02C147:
	beq	loc_02C14C
	brl	loc_02C210
loc_02C14C:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	loc_02C1B6
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	loc_02C17B
	lda	#$0001
	tsb	zp_06
loc_02C17B:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	loc_02C18E
	lda	#$0002
	tsb	zp_06
loc_02C18E:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	loc_02C1A1
	lda	#$0004
	tsb	zp_06
loc_02C1A1:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	loc_02C1B4
	lda	#$0008
	tsb	zp_06
loc_02C1B4:
	plx
	rts
loc_02C1B6:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	loc_02C1D5
	lda	#$0002
	tsb	zp_06
loc_02C1D5:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	loc_02C1E8
	lda	#$0001
	tsb	zp_06
loc_02C1E8:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	loc_02C1FB
	lda	#$0004
	tsb	zp_06
loc_02C1FB:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	loc_02C20E
	lda	#$0008
	tsb	zp_06
loc_02C20E:
	plx
	rts
loc_02C210:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	loc_02C22F
	lda	#$0004
	tsb	zp_06
loc_02C22F:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	loc_02C242
	lda	#$0001
	tsb	zp_06
loc_02C242:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	loc_02C255
	lda	#$0002
	tsb	zp_06
loc_02C255:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	loc_02C268
	lda	#$0008
	tsb	zp_06
loc_02C268:
	plx
	rts
loc_02C26A:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	loc_02C289
	lda	#$0008
	tsb	zp_06
loc_02C289:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	loc_02C29C
	lda	#$0001
	tsb	zp_06
loc_02C29C:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	loc_02C2AF
	lda	#$0002
	tsb	zp_06
loc_02C2AF:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	loc_02C2C2
	lda	#$0004
	tsb	zp_06
loc_02C2C2:
	plx
	rts

td_enemy_tile_wall_shape:
	bit	#TDA_SPECIAL
	bne	loc_02C2CD
	and	#TDA_WALL_MASK
	rts
loc_02C2CD:
	cmp	#TDA_HOLE
	beq	loc_02C2DB
	cmp	#TDA_PUSH_RIGHT
	bcc	loc_02C2DB
	lda	#$0000
	rts
loc_02C2DB:
	lda	#$0001
	rts
loc_02C2DF:
	lda	$0E,x
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	lda	f:$7E4000,x
	and	#$00FF
	plx
	sta	zp_04
	lda	a:topdown_map
	bne	loc_02C325
	lda	$0E,x
	cmp	#$0100
	bcc	loc_02C325
	cmp	#$0200
	bcs	loc_02C325
	lda	$0A,x
	cmp	#$0100
	bcc	loc_02C325
	cmp	#$0200
	bcs	loc_02C325
	cmp	#$0154
	bcc	loc_02C328
	cmp	#$01AC
	bcs	loc_02C32E
loc_02C325:
	stz	zp_06
	rts
loc_02C328:
	lda	#$0005
	sta	zp_06
	rts
loc_02C32E:
	lda	#$000A
	sta	zp_06
	rts

; Player X against the tile attribute map: corners, walls, then the special
; tile under it (td_player_tile_effect, tbl_td_player_special_tiles).
td_player_tile_collision:
	lda	a:boss_centered_view
	beq	loc_02C33B
	clc
	rtl
loc_02C33B:
	jsr	a:td_read_player_corner_tiles
	jsr	a:td_push_out_of_walls
	jsr	a:td_player_tile_effect
	rtl

td_player_tile_effect:
	lda	zp_04
	beq	loc_02C372
	cmp	#TDA_SAND_PIT
	beq	loc_02C351
	stz	a:$0672,x
loc_02C351:
	bit	#TDA_SPECIAL
	bne	loc_02C377
	bit	#TDA_SET_PRIORITY
	beq	loc_02C370
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	loc_02C366
	ldy	#$0000
loc_02C366:
	lda	$02,x
	and	#$CFFF
	ora	a:data_05DF42,y
	sta	$02,x
loc_02C370:
	clc
	rts
loc_02C372:
	stz	a:$0672,x
	clc
	rts
loc_02C377:
	eor	#$00FF
	phx
	asl	a
	tax
	lda	f:tbl_td_player_special_tiles,x
	plx
	sta	zp_00
	jmp	(zp_00)
; Indexed by $FF - attribute (TDA_HOLE first).
tbl_td_player_special_tiles:
	.addr	td_tile_hole
	.addr	td_tile_block_anim_trigger
	.addr	td_tile_trap
	.addr	td_tile_map_object
	.addr	td_tile_switch
	.addr	td_tile_whirl_player
	.addr	td_tile_sand_pit
	.addr	td_tile_push_down
	.addr	td_tile_push_up
	.addr	td_tile_push_left
	.addr	td_tile_push_right
	.addr	td_tile_fall_left
	.addr	td_tile_fall_right
	.addr	td_tile_fall_down
	.addr	td_tile_fall_up
	.addr	td_tile_fall_up_left
	.addr	td_tile_fall_up_right
	.addr	td_tile_fall_down_left
	.addr	td_tile_fall_down_right

td_tile_block_anim_trigger:
	jsr	a:td_trigger_block_anim
	clc
	rts

td_tile_trap:
	jsr	a:td_trigger_trap
	clc
	rts

td_tile_map_object:
	lda	$16,x
	bpl	loc_02C3DD
	lda	a:$0090,x
	cmp	#$0002
	bne	loc_02C3D0
	; (not executed in the CDL traces)
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE5_BOSS
	beq	loc_02C3DD
	jsr	a:td_bomb_hits_map_object_tile
	clc
	rts
loc_02C3D0:
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	loc_02C3DD
	lda	#$FFFF	; [num]
	sta	$06,x
loc_02C3DD:
	clc
	rts

td_tile_switch:
	jsr	a:td_trigger_switch_event
	clc
	rts

td_tile_whirl_player:
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	loc_02C40C
	; (not executed in the CDL traces)
	jsr	a:td_whirl_around_cell
	bcc	@return
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	a:$0658,x
	clc
@return:
	rts
loc_02C40C:
	jsr	a:td_whirl_around_cell
	bcc	@return
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:data_05DD1E,y
	and	#$00FF
	sta	a:$0654,x
	clc
@return:
	rts

td_tile_sand_pit:
	lda	a:td_boss_state
	cmp	#$0008
	bcs	loc_02C440
	ldy	difficulty
	lda	a:stage5_boss_hp,y
	lsr	a
	cmp	a:td_boss_hp
	bcs	loc_02C445
loc_02C440:
	stz	a:$0672,x
loc_02C443:
	clc
	rts
loc_02C445:
	lda	a:palette_cycle_paused
	bne	loc_02C443
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	loc_02C470
	; (not executed in the CDL traces)
	jsr	a:td_spiral_into_sand_pit
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	a:$0658,x
	clc
	rts
loc_02C470:
	jsr	a:td_spiral_into_sand_pit
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:data_05DD24,y
	and	#$00FF
	sta	a:$0654,x
	clc
	rts

td_tile_push_right:
	clc
	lda	$08,x
	adc	a:td_push_speed_frac
	sta	$08,x
	lda	$0A,x
	adc	a:td_push_speed
	sta	$0A,x
	clc
	rts

td_tile_push_left:
	sec
	lda	$08,x
	sbc	a:td_push_speed_frac
	sta	$08,x
	lda	$0A,x
	sbc	a:td_push_speed
	sta	$0A,x
	clc
	rts

td_tile_push_down:
	clc
	lda	$0C,x
	adc	a:td_push_speed_frac
	sta	$0C,x
	lda	$0E,x
	adc	a:td_push_speed
	sta	$0E,x
	clc
	rts

td_tile_push_up:
	sec
	lda	$0C,x
	sbc	a:td_push_speed_frac
	sta	$0C,x
	lda	$0E,x
	sbc	a:td_push_speed
	sta	$0E,x
	clc
	rts

td_tile_fall_left:
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	stz	$1C,x
	stz	$1E,x
	brl	td_tile_hole

td_tile_fall_right:
	lda	#$8000	; [num]
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	stz	$1C,x
	stz	$1E,x
	bra	td_tile_hole

td_tile_fall_down:
	stz	$18,x
	stz	$1A,x
	lda	#$8000	; [num]
	sta	$1C,x
	lda	#$0000
	sta	$1E,x
	bra	td_tile_hole

td_tile_fall_up:
	stz	$18,x
	stz	$1A,x
	lda	#$8000	; [num]
	sta	$1C,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	bra	td_tile_hole

td_tile_fall_up_left:
	lda	#$A57E	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	lda	#$A57E	; [num]
	sta	$1C,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	bra	td_tile_hole

td_tile_fall_up_right:
	lda	#$5A82
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	lda	#$A57E	; [num]
	sta	$1C,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	bra	td_tile_hole

td_tile_fall_down_left:
	lda	#$A57E	; [num]
	sta	$18,x
	lda	#$FFFF	; [num]
	sta	$1A,x
	lda	#$5A82
	sta	$1C,x
	lda	#$0000
	sta	$1E,x
	bra	td_tile_hole

td_tile_fall_down_right:
	lda	#$5A82
	sta	$18,x
	lda	#$0000
	sta	$1A,x
	lda	#$5A82
	sta	$1C,x
	lda	#$0000
	sta	$1E,x

td_tile_hole:
	lda	#$0002
	sta	$2C,x
	clc
	rts

td_read_player_corner_tiles:
	lda	$02,x
	bit	#$2000
	bne	loc_02C57B
	brl	loc_02C2DF
loc_02C57B:
	lda	$0E,x
	bit	#$0004
	bne	loc_02C59A
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	loc_02C595
	brl	loc_02C6B8
loc_02C595:
	beq	loc_02C59A
	brl	loc_02C65E
loc_02C59A:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	loc_02C604
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	loc_02C5C9
	lda	#$0001
	tsb	zp_06
loc_02C5C9:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	loc_02C5DC
	lda	#$0002
	tsb	zp_06
loc_02C5DC:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	loc_02C5EF
	lda	#$0004
	tsb	zp_06
loc_02C5EF:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	loc_02C602
	lda	#$0008
	tsb	zp_06
loc_02C602:
	plx
	rts
loc_02C604:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	loc_02C623
	lda	#$0002
	tsb	zp_06
loc_02C623:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	loc_02C636
	lda	#$0001
	tsb	zp_06
loc_02C636:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	loc_02C649
	lda	#$0004
	tsb	zp_06
loc_02C649:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	loc_02C65C
	lda	#$0008
	tsb	zp_06
loc_02C65C:
	plx
	rts
loc_02C65E:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	loc_02C67D
	lda	#$0004
	tsb	zp_06
loc_02C67D:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	loc_02C690
	lda	#$0001
	tsb	zp_06
loc_02C690:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	loc_02C6A3
	lda	#$0002
	tsb	zp_06
loc_02C6A3:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	loc_02C6B6
	lda	#$0008
	tsb	zp_06
loc_02C6B6:
	plx
	rts
loc_02C6B8:
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	zp_FA
	phx
	tax
	stz	zp_06
	lda	f:$7E4000,x
	and	#$00FF
	sta	zp_04
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	loc_02C6D7
	lda	#$0008
	tsb	zp_06
loc_02C6D7:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	loc_02C6EA
	lda	#$0001
	tsb	zp_06
loc_02C6EA:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	loc_02C6FD
	lda	#$0002
	tsb	zp_06
loc_02C6FD:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	loc_02C710
	lda	#$0004
	tsb	zp_06
loc_02C710:
	plx
	rts

td_player_tile_wall_shape:
	bit	#TDA_SPECIAL
	bne	loc_02C71B
	and	#TDA_WALL_MASK
	rts
loc_02C71B:
	lda	#$0000
	rts

td_push_out_of_walls:
	lda	zp_06
	asl	a
	phx
	tax
	jmp	(.loword(tbl_td_wall_push_cases),x)
tbl_td_wall_push_cases:
	.addr	td_wall_push_none
	.addr	td_wall_push_top_left
	.addr	td_wall_push_top_right
	.addr	td_wall_push_top
	.addr	td_wall_push_bottom_left
	.addr	td_wall_push_left
	.addr	td_wall_push_none
	.addr	td_wall_push_not_bottom_right
	.addr	td_wall_push_bottom_right
	.addr	td_wall_push_none
	.addr	td_wall_push_right
	.addr	td_wall_push_not_bottom_left
	.addr	td_wall_push_bottom
	.addr	td_wall_push_not_top_right
	.addr	td_wall_push_not_top_left
	.addr	td_wall_push_all

td_wall_push_none:
	plx
	rts

td_wall_push_all:
	plx
	lda	zp_0C
	cmp	#$0005
	bcc	loc_02C754
	brl	loc_02C8D2
loc_02C754:
	lda	zp_08
	cmp	#$0005
	bcc	loc_02C75E
	brl	loc_02C917
loc_02C75E:
	lda	zp_0A
	cmp	#$0005
	bcc	loc_02C768
	brl	loc_02C950
loc_02C768:
	lda	zp_0E
	cmp	#$0005
	bcc	@return
	brl	loc_02C995
@return:
	rts

td_wall_push_right:
	plx

td_wall_snap_left:
	lda	$0A,x
	and	#$FFF8
	ora	#$0003
	sta	$0A,x
	stz	$08,x
	rts

td_wall_push_left:
	plx

td_wall_snap_right:
	lda	$0A,x
	and	#$FFF8
	ora	#$0004
	sta	$0A,x
	lda	#$FFFF	; [num]
	sta	$08,x
	rts

td_wall_push_bottom:
	plx
loc_02C793:
	lda	$0E,x
	and	#$FFF8
	ora	#$0003
	sta	$0E,x
	stz	$0C,x
	rts

td_wall_push_top:
	plx
loc_02C7A1:
	lda	$0E,x
	and	#$FFF8
	ora	#$0004
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$0C,x
	rts

td_wall_push_not_bottom_left:
	plx
	lda	zp_0A
	cmp	#$0004
	bcc	loc_02C7BC
	brl	loc_02C8D2
loc_02C7BC:
	jsr	a:td_wall_snap_left
	bra	loc_02C7A1

td_wall_push_not_top_left:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	loc_02C7CC
	brl	loc_02C917
loc_02C7CC:
	jsr	a:td_wall_snap_left
	bra	loc_02C793

td_wall_push_not_top_right:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	loc_02C7DC
	brl	loc_02C950
loc_02C7DC:
	jsr	a:td_wall_snap_right
	bra	loc_02C793

td_wall_push_not_bottom_right:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	loc_02C7EC
	brl	loc_02C995
loc_02C7EC:
	jsr	a:td_wall_snap_right
	bra	loc_02C7A1

td_wall_push_top_right:
	plx
	lda	zp_0A
	cmp	#$0004
	bcc	loc_02C7FC
	brl	loc_02C8E9
loc_02C7FC:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DDAA,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF	; [num]
	sta	$0C,x
	rts

td_wall_push_bottom_right:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	loc_02C835
	brl	loc_02C928
loc_02C835:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DDAA,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

td_wall_push_bottom_left:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	loc_02C868
	brl	loc_02C967
loc_02C868:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DDAA,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	stz	$0C,x
	rts

td_wall_push_top_left:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	loc_02C8A1
	brl	loc_02C9B2
loc_02C8A1:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DD2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DDAA,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	sta	$0C,x
	rts
loc_02C8D2:
	lda	$0E,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	bra	loc_02C8FB
loc_02C8E9:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
loc_02C8FB:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DE2A,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF	; [num]
	sta	$0C,x
	rts
loc_02C917:
	lda	$0E,x
	and	#$0003
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	bra	loc_02C937
loc_02C928:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
loc_02C937:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts
loc_02C950:
	lda	$0E,x
	and	#$0003
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	bra	loc_02C979
loc_02C967:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
loc_02C979:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:data_05DE2A,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	stz	$0C,x
	rts
loc_02C995:
	lda	$0E,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	ora	#$0004
	eor	#$0007
	bra	loc_02C9C7
loc_02C9B2:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
loc_02C9C7:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:data_05DE2A,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:data_05DE2A,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	sta	$0C,x
	rts

td_check_lower_level_x:
	lda	$02,x
	bit	#$2000
	beq	loc_02C9EB
	rts
loc_02C9EB:
	ldy	$0A,x
	cpy	#$0150
	bcc	loc_02C9F6
	cpy	#$01B0
	rts
loc_02C9F6:
	sec
	rts

; TDA_TRAP: 500 points and a timer per column ($187E): $30 frames later a
; TDI_BLAST explodes there (td_update_stage2_map_events).
td_trigger_trap:
	lda	$0A,x
	and	#$FFE0
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	tay
	lda	a:data_05DEAA,y
	beq	@return
	tay
	lda	a:$187E,y
	bne	@return
	lda	#$0050
	sta	a:$187E,y
	phx
	lda	#$0500
	jsl	f:add_score_for_topdown_player
	plx
@return:
	rts

; TDA_BLOCK_ANIM: screen shake, sound $11 and $20 frames of block
; animation (block_anim_timer_left for x < $200, block_anim_timer_right for the right half).
td_trigger_block_anim:
	ldy	#$0000
	lda	$0A,x
	cmp	#$0200
	bcc	loc_02CA2A
	ldy	#$0002
loc_02CA2A:
	lda	a:$18AC,y
	bne	@return
	lda	#$0020
	sta	a:$18AC,y
	lda	#$0001
	sta	a:screen_shake_offset
	lda	#$0030
	sta	a:screen_shake_timer
	lda	#$0011
	jsl	f:queue_sound
@return:
	rts

; TDA_SWITCH: Y or A pressed here starts one of three events (by y) run by
; td_update_switch_events: shake, explosions and map blocks redrawn step by
; step.
td_trigger_switch_event:
	lda	a:$066C,x
	bit	#$4080
	bne	loc_02CA52
	rts
loc_02CA52:
	lda	$0E,x
	cmp	#$0100
	bcs	loc_02CA5C
	brl	loc_02CAE6
loc_02CA5C:
	cmp	#$0300
	bcs	loc_02CA64
	brl	loc_02CAA5
loc_02CA64:
	lda	a:wram_18CC
	beq	loc_02CA6A
	rts
loc_02CA6A:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:wram_18CC
	lda	#$0008
	sta	a:wram_18CE
	stz	a:wram_18D0
	ldy	#$0000
	lda	$0A,x
	cmp	#$0220
	bcc	loc_02CA8F
	ldy	#$0002
loc_02CA8F:
	sty	a:wram_18D2
	lda	a:data_05DEEA,y
	sta	a:wram_18D8
	lda	a:data_05DEEE,y
	sta	a:wram_18D4
	lda	#$0390
	sta	a:wram_18D6
	rts
loc_02CAA5:
	lda	a:wram_18BE
	beq	loc_02CAAB
	rts
loc_02CAAB:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:wram_18BE
	lda	#$0008
	sta	a:wram_18C0
	stz	a:wram_18C2
	ldy	#$0000
	lda	$0A,x
	cmp	#$0140
	bcc	loc_02CAD0
	ldy	#$0002
loc_02CAD0:
	sty	a:wram_18C4
	lda	a:data_05DEF2,y
	sta	a:wram_18CA
	lda	a:data_05DEF6,y
	sta	a:wram_18C6
	lda	#$0230
	sta	a:wram_18C8
	rts
loc_02CAE6:
	lda	a:wram_18B0
	beq	loc_02CAEC
	rts
loc_02CAEC:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:wram_18B0
	lda	#$0008
	sta	a:wram_18B2
	stz	a:wram_18B4
	ldy	#$0000
	lda	$0A,x
	cmp	#$0300
	bcc	loc_02CB11
	ldy	#$0002
loc_02CB11:
	sty	a:wram_18B6
	lda	a:data_05DEFA,y
	sta	a:wram_18BC
	lda	a:data_05DEFE,y
	sta	a:wram_18B8
	lda	#$0050
	sta	a:wram_18BA
	rts

td_bomb_hits_map_object_tile:
	; (not executed in the CDL traces)
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	loc_02CB57
	bit	#$1000
	beq	loc_02CB57
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	loc_02CB57
	phx
	phy
	txa
	tyx
	clc
	adc	#$10C0
	tay
	jsl	f:td_score_kill
	ply
	plx
loc_02CB57:
	sec
	rts

; Y = the map object owning the TDA_MAP_OBJECT tile under X (by 256-pixel
; cell: data_05DF02 on stage 2, data_05DF22 on stage 5; $0AC0 on the
; boss maps).
td_get_map_object_at:
	lda	$0A,x
	xba
	and	#$0003
	sta	zp_FA
	lda	$0E,x
	asl	a
	asl	a
	xba
	and	#$000C
	ora	zp_FA
	asl	a
	tay
	lda	a:topdown_map
	beq	loc_02CB7B
	cmp	#TD_MAP_STAGE5
	beq	loc_02CB80
	ldy	#$0AC0
	rts
loc_02CB7B:
	lda	a:data_05DF02,y
	tay
	rts
loc_02CB80:
	lda	a:data_05DF22,y
	tay
	rts

; Moves object X around the centre of its 32 x 32-pixel cell (whirlpool);
; carry clear at the centre.
td_whirl_around_cell:
	lda	$0A,x
	and	#$001F
	bne	loc_02CB91
loc_02CB8C:
	ldy	#$0010
	clc
	rts
loc_02CB91:
	sec
	sbc	#$0010
	sta	zp_08
	sta	zp_FC
	lda	$0E,x
	and	#$001F
	beq	loc_02CB8C
	sec
	sbc	#$0010
	sta	zp_0A
	sta	zp_FE
	jsl	f:calc_angle
	pha
	lda	zp_FE
	bpl	loc_02CBB5
	eor	#$FFFF
	inc	a
loc_02CBB5:
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	zp_FC
	bpl	loc_02CBC3
	eor	#$FFFF
	inc	a
loc_02CBC3:
	ora	zp_FA
	tay
	lda	a:data_05DF46,y
	and	#$00FF
	tay
	beq	loc_02CBD7
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_02CBD7
	dey
loc_02CBD7:
	pla
	phy
	inc	a
	and	#$00FF
	jsl	f:polar_to_xy
	lda	$0A,x
	and	#$FFE0
	clc
	adc	#$0010
	clc
	adc	zp_08
	sta	$0A,x
	lda	$0E,x
	and	#$FFE0
	clc
	adc	#$0010
	clc
	adc	zp_0A
	sta	$0E,x
	ply
	sec
	rts

; Stage 5 boss: moves player X one angle step around ($200,$200) and one
; pixel closer (the funnel pulls it in).
td_spiral_into_sand_pit:
	lda	$0A,x
	sec
	sbc	#$0200
	sta	zp_08
	sta	zp_FC
	lda	$0E,x
	sec
	sbc	#$0200
	sta	zp_0A
	sta	zp_FE
	lda	a:$0672,x
	beq	loc_02CC1F
	lda	a:$0670,x
	pha
	bra	loc_02CC32
loc_02CC1F:
	lda	#$0001
	sta	a:$0672,x
	jsl	f:calc_angle
	pha
	lda	zp_FC
	sta	zp_08
	lda	zp_FE
	sta	zp_0A
loc_02CC32:
	jsl	f:calc_distance
	tay
	iny
	pla
	phy
	inc	a
	and	#$00FF
	sta	a:$0670,x
	jsl	f:polar_to_xy
	lda	#$0200
	clc
	adc	zp_08
	sta	$0A,x
	lda	#$0200
	clc
	adc	zp_0A
	sta	$0E,x
	ply
	rts
; Player 1: target arrow, shots vs enemies, body vs enemies, bomb vs map objects
; (each map has its own set).
td_run_p1_collisions:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	loc_02CC79
	cmp	#TD_MAP_STAGE5_BOSS
	beq	loc_02CC89
	jsr	a:td_aim_p1_target_arrow
	jsr	a:td_p1_shots_vs_enemies
	jsr	a:td_p1_vs_enemies
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p1_bomb_vs_map_objects
@return:
	rtl
loc_02CC79:
	jsr	a:td_aim_p1_arrow_stage2_boss
	jsr	a:td_p1_vs_stage2_boss
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p1_bomb_vs_stage2_boss
@return:
	rtl
loc_02CC89:
	jsr	a:td_aim_p1_arrow_stage5_boss
	jsr	a:td_p1_vs_stage5_boss
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p1_bomb_vs_map_objects
@return:
	rtl

; Player 1's shots ($0480-) against the enemies ($0D40-$0EBF).
td_p1_shots_vs_enemies:
	ldy	#$0D40
loc_02CC9C:
	lda	a:$0016,y
	bmi	loc_02CCA4
	brl	loc_02CD58
loc_02CCA4:
	lda	a:$002E,y
	bit	#$0003
	bne	loc_02CCAF
	brl	loc_02CD58
loc_02CCAF:
	lda	#$0008
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$0008
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0480
@loop:
	lda	$10,x
	dec	a
	bmi	@next
	lda	a:$0002,y
	eor	$02,x
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	jsl	f:td_score_shot_kill
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcc	@loop
	lda	#$000C
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$000C
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0980
@loop2:
	lda	$16,x
	bpl	@next2
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next2
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next2
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
@next2:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop2
loc_02CD58:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	@return
	brl	loc_02CC9C
@return:
	rts

; Player 1's body against the enemies.
td_p1_vs_enemies:
	jsr	a:td_p1_vs_items
	lda	a:td_p1_hit_flags
	bmi	loc_02CD70
	rts
loc_02CD70:
	lda	#$000C
	clc
	adc	a:td_p1_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p1_y
	sta	zp_1A
	ldx	#$0D40
loc_02CD85:
	lda	$16,x
	bpl	loc_02CDC6
	lda	$02,x
	eor	a:td_p1_obj+OBJ_ATTR
	bit	#$3000
	bne	loc_02CDC6
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02CDC6
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02CDC6
	lda	a:p1_barrier_timer
	beq	loc_02CDC0
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02CDC6
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	loc_02CDC6
loc_02CDC0:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02CDC6:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02CD85
loc_02CDD1:
	lda	a:td_p1_state
	cmp	#$0005
	beq	@return
	lda	#$0008
	clc
	adc	a:td_p1_x
	sta	zp_18
	lda	#$0008
	clc
	adc	a:td_p1_y
	sta	zp_1A
	ldx	#$0300
@loop:
	lda	$10,x
	dec	a
	bmi	@next
	lda	$02,x
	eor	a:td_p1_obj+OBJ_ATTR
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	@next
	jsl	f:td_end_shot
	lda	a:p1_barrier_timer
	bne	@next
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop
@return:
	rts

; Player 1 against the item/effect objects: picks up items (weapon into the
; active slot, barrier $200 frames, one more bomb up to 9), and is killed by
; blasts unless the barrier is on.
td_p1_vs_items:
	lda	#$000C
	clc
	adc	a:td_p1_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p1_y
	sta	zp_1A
	ldx	#$0980
loc_02CE41:
	lda	$16,x
	bit	#$4000
	bne	loc_02CE52
	bit	#$8000
	beq	loc_02CEA8
	lda	a:td_p1_hit_flags
	bpl	loc_02CEA8
loc_02CE52:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02CEA8
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02CEA8
	lda	$16,x
	bpl	loc_02CE77
	lda	a:p1_barrier_timer
	bne	loc_02CE75
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02CE75:
	bra	loc_02CEA8
loc_02CE77:
	lda	#$0012
	jsl	f:queue_sound
	lda	$14,x
	cmp	#TDIK_BARRIER
	bcs	loc_02CE8D
	ldy	a:p1_weapon_select
	sta	a:$1F84,y
	bra	loc_02CEA6
loc_02CE8D:
	beq	loc_02CEA0
	lda	a:p1_bombs
	inc	a
	cmp	#$000A
	bcc	loc_02CE9B
	; (not executed in the CDL traces)
	lda	#$0009
loc_02CE9B:
	sta	a:p1_bombs
	bra	loc_02CEA6
loc_02CEA0:
	; (not executed in the CDL traces)
	lda	#$0200
	sta	a:p1_barrier_timer
loc_02CEA6:
	stz	$24,x
loc_02CEA8:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02CE41
	rts

td_p1_vs_stage2_boss:
	ldx	#$0480
loc_02CEB7:
	lda	$10,x
	dec	a
	bpl	loc_02CEBF
	brl	loc_02CFD5
loc_02CEBF:
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	loc_02CF2B
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0003
	beq	loc_02CF09
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02CF09
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02CF09
	jsl	f:td_end_shot
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
	lda	a:td_boss_core_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_core_hp
	bpl	loc_02CF09
	; (not executed in the CDL traces)
	ldy	#$0B40
	jsl	f:td_score_shot_kill
loc_02CF09:
	lda	a:td_boss_x
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	loc_02CF2B
	lda	a:td_boss_y
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	loc_02CF2B
	jsl	f:td_end_shot
loc_02CF2B:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	loc_02CF78
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	bit	#$0003
	bne	loc_02CF3B
	brl	loc_02CF78
loc_02CF3B:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	loc_02CF78
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	loc_02CF78
	jsl	f:td_end_shot
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	sec
	sbc_player_damage_x
	sta	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	loc_02CF78
	; (not executed in the CDL traces)
	ldy	#$0B80
	jsl	f:td_score_shot_kill
loc_02CF78:
	ldy	#$0BC0
@loop:
	lda	a:$0016,y
	bpl	@next
	lda	a:$002E,y
	bit	#$0003
	beq	@next
	lda	a:$000A,y
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@next
	lda	a:$000E,y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$0016,y
	bit	#$1000
	beq	@next
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	; (not executed in the CDL traces)
	jsl	f:td_score_shot_kill
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	@loop
loc_02CFD5:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	loc_02CFE3
	brl	loc_02CEB7
loc_02CFE3:
	jsr	a:td_p1_vs_items
	lda	a:td_p1_hit_flags
	bmi	loc_02CFEC
	rts
loc_02CFEC:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	loc_02D036
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	a:td_p1_x
	cmp	#$001C
	bcs	loc_02D036
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	a:td_p1_y
	cmp	#$001C
	bcs	loc_02D036
	lda	a:p1_barrier_timer
	beq	loc_02D030
	; (not executed in the CDL traces)
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	dec	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	loc_02D036
	ldx	#$0B80
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	loc_02D036
loc_02D030:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02D036:
	ldx	#$0BC0
loc_02D039:
	lda	$16,x
	bpl	loc_02D07A
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	loc_02D07A
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	loc_02D07A
	; (not executed in the CDL traces)
	lda	a:p1_barrier_timer
	beq	loc_02D074
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D07A
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	loc_02D07A
loc_02D074:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02D07A:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D039
	lda	a:p1_barrier_timer
	beq	loc_02D0CC
	; (not executed in the CDL traces)
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	loc_02D0CC
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	loc_02D0CC
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	loc_02D0CC
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0040
	bne	loc_02D0BD
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
loc_02D0BD:
	dec	a:td_boss_core_hp
	bpl	loc_02D0CC
	ldx	#$0B40
	ldy	#$1F80
	jsl	f:td_score_kill
loc_02D0CC:
	lda	a:td_map_objects+$16
	bpl	loc_02D0FC
	lda	a:td_boss_x
	clc
	adc	#$001A
	sec
	sbc	a:td_p1_x
	cmp	#$0034
	bcs	loc_02D0FC
	lda	a:td_boss_y
	clc
	adc	#$001A
	sec
	sbc	a:td_p1_y
	cmp	#$0034
	bcs	loc_02D0FC
	lda	a:p1_barrier_timer
	bne	loc_02D0FC
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02D0FC:
	jmp	a:loc_02CDD1

td_p1_bomb_vs_stage2_boss:
	lda	#$0DC0
	sta	zp_1E
	bra	loc_02D10B

; Player 1's smart bomb against the map objects ($0AC0-).
td_p1_bomb_vs_map_objects:
	lda	#$0EC0
	sta	zp_1E
loc_02D10B:
	lda	a:td_p1_bomb_radius
	asl	a
	sta	zp_1C
	lsr	a
	clc
	adc	a:td_p1_bomb_x
	sta	zp_18
	lda	a:td_p1_bomb_y
	clc
	adc	a:td_p1_bomb_radius
	sta	zp_1A
	ldx	#$0AC0
@loop:
	lda	$16,x
	bpl	@next
	lda	$2E,x
	bit	#$0003
	beq	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	@next
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	lda	$06,x
	sec
	sbc	a:td_p1_bomb+$06
	sta	$06,x
	bpl	@next
	ldy	#$1F80
	jsl	f:td_score_kill
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_1E
	bcc	@loop
	ldx	#$0300
@loop2:
	lda	$10,x
	dec	a
	bmi	@next2
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	@next2
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	@next2
	jsl	f:td_end_shot
@next2:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop2
	rts

; Points the arrow (objects $0200/$0240) at the nearest map target of
; $0AC0-$0D3F; when none is left, targets_left_flag = $FFFF.
td_aim_p1_target_arrow:
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
@loop:
	jsr	a:td_check_nearest_target
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@loop
	bra	loc_02D1BD

td_aim_p1_arrow_stage5_boss:
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:td_check_nearest_target
	ldx	zp_1A
	bne	loc_02D1BB
	; (not executed in the CDL traces)
	brl	loc_02D2C8
loc_02D1BB:
	bra	loc_02D1C4
loc_02D1BD:
	ldx	zp_1A
	bne	loc_02D1C4
	brl	loc_02D29A
loc_02D1C4:
	lda	zp_18
	cmp	#$2000
	bcc	loc_02D1D4
	lda	$2E,x
	and	#$FFEF
	sta	$2E,x
	bra	loc_02D206
loc_02D1D4:
	lda	$2E,x
	ora	#$0010
	sta	$2E,x
	bra	loc_02D206

; Keeps in zp_1A the target X nearer to player 1's view than zp_18.
td_check_nearest_target:
	lda	$10,x
	beq	@return
	lda	$0A,x
	sec
	sbc	a:p1_view_x
	sta	zp_08
	lda	$0E,x
	sec
	sbc	a:p1_view_y
	sta	zp_0A
	jsl	f:half_distance_squared
	cmp	zp_18
	bcs	@return
	sta	zp_18
	stx	zp_1A
	lda	zp_08
	sta	zp_1C
	lda	zp_0A
	sta	zp_1E
@return:
	rts
loc_02D206:
	lda	zp_1C
	sta	zp_08
	lda	zp_1E
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	a:p1_view_angle
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
loc_02D222:
	lda	a:title_menu_cursor
	beq	loc_02D22A
	dec	a
	beq	loc_02D262
loc_02D22A:
	lda	a:data_05E046,y
	beq	loc_02D240
	sta	a:td_arrow_objs
	lda	a:data_05E066,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0070
	sta	a:td_arrow_objs+OBJ_Y
	bra	loc_02D246
loc_02D240:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
loc_02D246:
	lda	a:data_05E056,y
	beq	loc_02D25B
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:data_05E076,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02D25B:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02D262:
	lda	a:data_05E046,y
	beq	loc_02D278
	sta	a:td_arrow_objs
	lda	a:data_05E066,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0030
	sta	a:td_arrow_objs+OBJ_Y
	bra	loc_02D27E
loc_02D278:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
loc_02D27E:
	lda	a:data_05E056,y
	beq	loc_02D293
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:data_05E086,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02D293:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02D29A:
	lda	#$FFFF	; [num]
	sta	a:targets_left_flag
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	jmp	a:loc_02D222

td_aim_p1_arrow_stage2_boss:
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	loc_02D29A
	cmp	#$0009
	beq	loc_02D29A
	cmp	#$000A
	beq	loc_02D29A
	cmp	#$000B
	beq	loc_02D29A
	cmp	#$0011
	bcc	loc_02D2D2
loc_02D2C8:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02D2D2:
	lda	$0A,x
	sec
	sbc	a:p1_view_x
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:p1_view_y
	sta	zp_1E
	jmp	a:loc_02D206

td_p1_vs_stage5_boss:
	jsr	a:td_p1_shots_vs_stage5_boss
	jsr	a:td_p1_vs_items
	jmp	a:loc_02D3AF

td_p1_shots_vs_stage5_boss:
	ldx	#$0480
loc_02D2F1:
	lda	$10,x
	dec	a
	bpl	loc_02D2F9
	brl	loc_02D3A0
loc_02D2F9:
	lda	a:td_map_objects+$16
	bpl	loc_02D343
	lda	a:td_map_objects+$2E
	bit	#$0003
	beq	loc_02D343
	lda	a:td_boss_x
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02D343
	lda	a:td_boss_y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02D343
	jsl	f:td_end_shot
	lda	a:td_map_objects+$2E
	ora	#$0040
	sta	a:td_map_objects+$2E
	lda	a:td_boss_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_hp
	bpl	loc_02D343
	; (not executed in the CDL traces)
	ldy	#$0AC0
	jsl	f:td_score_shot_kill
loc_02D343:
	ldy	#$0B40
@loop:
	lda	a:$0016,y
	bpl	@next
	lda	a:$002E,y
	bit	#$0003
	beq	@next
	lda	a:$000A,y
	clc
	adc	#$0006
	sec
	sbc	$0A,x
	cmp	#$000C
	bcs	@next
	lda	a:$000E,y
	clc
	adc	#$0006
	sec
	sbc	$0E,x
	cmp	#$000C
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$0016,y
	bit	#$1000
	beq	@next
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	jsl	f:td_score_shot_kill_enemy
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcc	@loop
loc_02D3A0:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	@return
	brl	loc_02D2F1
@return:
	rts
loc_02D3AF:
	lda	a:td_p1_hit_flags
	bmi	loc_02D3B5
	rts
loc_02D3B5:
	lda	a:td_map_objects+$16
	bpl	loc_02D3F7
	lda	a:td_boss_x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	loc_02D3F7
	lda	a:td_boss_y
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	loc_02D3F7
	; (not executed in the CDL traces)
	lda	a:td_map_objects+$2E
	bit	#$0040
	bne	loc_02D3E8
	ora	#$0040
	sta	a:td_map_objects+$2E
loc_02D3E8:
	dec	a:td_boss_hp
	bpl	loc_02D3F7
	ldx	#$0AC0
	ldy	#$1F80
	jsl	f:td_score_kill
loc_02D3F7:
	ldx	#$0B40
loc_02D3FA:
	lda	$16,x
	bpl	loc_02D43B
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p1_x
	cmp	#$0014
	bcs	loc_02D43B
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p1_y
	cmp	#$0014
	bcs	loc_02D43B
	lda	a:p1_barrier_timer
	beq	loc_02D435
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D43B
	ldy	#$1F80
	jsl	f:td_score_enemy_kill
	bra	loc_02D43B
loc_02D435:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
loc_02D43B:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02D3FA
	jmp	a:loc_02CDD1
td_run_p2_collisions:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	loc_02D46B
	cmp	#TD_MAP_STAGE5_BOSS
	beq	loc_02D47B
	jsr	a:td_aim_p2_target_arrow
	jsr	a:td_p2_shots_vs_enemies
	jsr	a:td_p2_vs_enemies
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p2_bomb_vs_map_objects
@return:
	rtl
loc_02D46B:
	; (not executed in the CDL traces)
	jsr	a:td_aim_p2_arrow_stage2_boss
	jsr	a:td_p2_vs_stage2_boss
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p2_bomb_vs_stage2_boss
@return:
	rtl
loc_02D47B:
	jsr	a:td_aim_p2_arrow_stage5_boss
	jsr	a:td_p2_vs_stage5_boss
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p2_bomb_vs_map_objects
@return:
	rtl

td_p2_shots_vs_enemies:
	ldy	#$0D40
loc_02D48E:
	lda	a:$0016,y
	bmi	loc_02D496
	brl	loc_02D54A
loc_02D496:
	lda	a:$002E,y
	bit	#$0003
	bne	loc_02D4A1
	brl	loc_02D54A
loc_02D4A1:
	lda	#$0008
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$0008
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0700
@loop:
	lda	$10,x
	dec	a
	bmi	@next
	lda	a:$0002,y
	eor	$02,x
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	jsl	f:td_score_shot_kill
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcc	@loop
	lda	#$000C
	clc
	adc	a:$000A,y
	sta	zp_18
	lda	#$000C
	clc
	adc	a:$000E,y
	sta	zp_1A
	ldx	#$0980
@loop2:
	lda	$16,x
	bpl	@next2
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next2
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next2
	; (not executed in the CDL traces)
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
@next2:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop2
loc_02D54A:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	@return
	brl	loc_02D48E
@return:
	rts

td_p2_vs_enemies:
	jsr	a:td_p2_vs_items
	lda	a:td_p2_hit_flags
	bmi	loc_02D562
	rts
loc_02D562:
	lda	#$000C
	clc
	adc	a:td_p2_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p2_y
	sta	zp_1A
	ldx	#$0D40
loc_02D577:
	lda	$16,x
	bpl	loc_02D5B8
	lda	$02,x
	eor	a:td_p2_obj+OBJ_ATTR
	bit	#$3000
	bne	loc_02D5B8
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02D5B8
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02D5B8
	lda	a:p2_barrier_timer
	beq	loc_02D5B2
	; (not executed in the CDL traces)
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D5B8
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	loc_02D5B8
loc_02D5B2:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02D5B8:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02D577
loc_02D5C3:
	lda	a:td_p2_state
	cmp	#$0005
	beq	@return
	lda	#$0008
	clc
	adc	a:td_p2_x
	sta	zp_18
	lda	#$0008
	clc
	adc	a:td_p2_y
	sta	zp_1A
	ldx	#$0300
@loop:
	lda	$10,x
	dec	a
	bmi	@next
	lda	$02,x
	eor	a:td_p2_obj+OBJ_ATTR
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0010
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0010
	bcs	@next
	jsl	f:td_end_shot
	lda	a:p2_barrier_timer
	bne	@next
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@next:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop
@return:
	rts

td_p2_vs_items:
	lda	#$000C
	clc
	adc	a:td_p2_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p2_y
	sta	zp_1A
	ldx	#$0980
loc_02D633:
	lda	$16,x
	bit	#$4000
	bne	loc_02D644
	bit	#$8000
	beq	loc_02D69A
	lda	a:td_p2_hit_flags
	bpl	loc_02D69A
loc_02D644:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	loc_02D69A
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	loc_02D69A
	lda	$16,x
	bpl	loc_02D669
	lda	a:p2_barrier_timer
	bne	loc_02D667
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02D667:
	bra	loc_02D69A
loc_02D669:
	lda	#$0012
	jsl	f:queue_sound
	lda	$14,x
	cmp	#TDIK_BARRIER
	bcs	loc_02D67F
	ldy	a:p2_weapon_select
	sta	a:$1FC4,y
	bra	loc_02D698
loc_02D67F:
	; (not executed in the CDL traces)
	beq	loc_02D692
	lda	a:p2_bombs
	inc	a
	cmp	#$000A
	bcc	loc_02D68D
	lda	#$0009
loc_02D68D:
	sta	a:p2_bombs
	bra	loc_02D698
loc_02D692:
	lda	#$0200
	sta	a:p2_barrier_timer
loc_02D698:
	stz	$24,x
loc_02D69A:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	loc_02D633
	rts

td_p2_vs_stage2_boss:
	; (not executed in the CDL traces)
	ldx	#$0700
loc_02D6A9:
	lda	$10,x
	dec	a
	bpl	loc_02D6B1
	brl	loc_02D7C7
loc_02D6B1:
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	loc_02D71D
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0003
	beq	loc_02D6FB
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02D6FB
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02D6FB
	jsl	f:td_end_shot
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
	lda	a:td_boss_core_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_core_hp
	bpl	loc_02D6FB
	ldy	#$0B40
	jsl	f:td_score_shot_kill
loc_02D6FB:
	lda	a:td_boss_x
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	loc_02D71D
	lda	a:td_boss_y
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	loc_02D71D
	jsl	f:td_end_shot
loc_02D71D:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	loc_02D76A
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	bit	#$0003
	bne	loc_02D72D
	brl	loc_02D76A
loc_02D72D:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	loc_02D76A
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	loc_02D76A
	jsl	f:td_end_shot
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	sec
	sbc_player_damage_x
	sta	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	loc_02D76A
	ldy	#$0B80
	jsl	f:td_score_shot_kill
loc_02D76A:
	ldy	#$0BC0
@loop:
	lda	a:$0016,y
	bpl	@next
	lda	a:$002E,y
	bit	#$0003
	beq	@next
	lda	a:$000A,y
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@next
	lda	a:$000E,y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$0016,y
	bit	#$1000
	beq	@next
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	jsl	f:td_score_shot_kill
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0D40
	bcc	@loop
loc_02D7C7:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	loc_02D7D5
	brl	loc_02D6A9
loc_02D7D5:
	jsr	a:td_p2_vs_items
	lda	a:td_p2_hit_flags
	bmi	loc_02D7DE
	rts
loc_02D7DE:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	loc_02D828
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	a:td_p2_x
	cmp	#$001C
	bcs	loc_02D828
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	a:td_p2_y
	cmp	#$001C
	bcs	loc_02D828
	lda	a:p2_barrier_timer
	beq	loc_02D822
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	dec	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	loc_02D828
	ldx	#$0B80
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	loc_02D828
loc_02D822:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02D828:
	ldx	#$0BC0
loc_02D82B:
	lda	$16,x
	bpl	loc_02D86C
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	loc_02D86C
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	loc_02D86C
	lda	a:p2_barrier_timer
	beq	loc_02D866
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02D86C
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	loc_02D86C
loc_02D866:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02D86C:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	loc_02D82B
	lda	a:p2_barrier_timer
	beq	loc_02D8BE
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	loc_02D8BE
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	loc_02D8BE
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	loc_02D8BE
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0040
	bne	loc_02D8AF
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
loc_02D8AF:
	dec	a:td_boss_core_hp
	bpl	loc_02D8BE
	ldx	#$0B40
	ldy	#$1FC0
	jsl	f:td_score_kill
loc_02D8BE:
	lda	a:td_map_objects+$16
	bpl	loc_02D8EE
	lda	a:td_boss_x
	clc
	adc	#$001A
	sec
	sbc	a:td_p2_x
	cmp	#$0034
	bcs	loc_02D8EE
	lda	a:td_boss_y
	clc
	adc	#$001A
	sec
	sbc	a:td_p2_y
	cmp	#$0034
	bcs	loc_02D8EE
	lda	a:p2_barrier_timer
	bne	loc_02D8EE
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02D8EE:
	jmp	a:loc_02D5C3

td_p2_bomb_vs_stage2_boss:
	; (not executed in the CDL traces)
	lda	#$0DC0
	sta	zp_1E
	bra	loc_02D8FD

td_p2_bomb_vs_map_objects:
	lda	#$0EC0
	sta	zp_1E
loc_02D8FD:
	lda	a:td_p2_bomb_radius
	asl	a
	sta	zp_1C
	lsr	a
	clc
	adc	a:td_p2_bomb_x
	sta	zp_18
	lda	a:td_p2_bomb_y
	clc
	adc	a:td_p2_bomb_radius
	sta	zp_1A
	ldx	#$0AC0
@loop:
	lda	$16,x
	bpl	@next
	lda	$2E,x
	bit	#$0003
	beq	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	@next
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	lda	$06,x
	sec
	sbc	a:td_p2_bomb+$06
	sta	$06,x
	bpl	@next
	ldy	#$1FC0
	jsl	f:td_score_kill
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_1E
	bcc	@loop
	ldx	#$0300
@loop2:
	lda	$10,x
	dec	a
	bmi	@next2
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	zp_1C
	bcs	@next2
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	zp_1C
	bcs	@next2
	jsl	f:td_end_shot
@next2:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop2
	rts

td_aim_p2_target_arrow:
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
@loop:
	jsr	a:td_check_nearest_target_p2
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@loop
	bra	loc_02D9AF

td_aim_p2_arrow_stage5_boss:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:td_check_nearest_target_p2
	ldx	zp_1A
	bne	loc_02D9AD
	brl	loc_02DABA
loc_02D9AD:
	bra	loc_02D9B6
loc_02D9AF:
	ldx	zp_1A
	bne	loc_02D9B6
	; (not executed in the CDL traces)
	brl	loc_02DA8C
loc_02D9B6:
	lda	zp_18
	cmp	#$2000
	bcc	loc_02D9C6
	lda	$2E,x
	and	#$FFDF
	sta	$2E,x
	bra	loc_02D9F8
loc_02D9C6:
	lda	$2E,x
	ora	#$0020
	sta	$2E,x
	bra	loc_02D9F8

td_check_nearest_target_p2:
	lda	$10,x
	beq	@return
	lda	$0A,x
	sec
	sbc	a:p2_view_x
	sta	zp_08
	lda	$0E,x
	sec
	sbc	a:p2_view_y
	sta	zp_0A
	jsl	f:half_distance_squared
	cmp	zp_18
	bcs	@return
	sta	zp_18
	stx	zp_1A
	lda	zp_08
	sta	zp_1C
	lda	zp_0A
	sta	zp_1E
@return:
	rts
loc_02D9F8:
	lda	zp_1C
	sta	zp_08
	lda	zp_1E
	sta	zp_0A
	jsl	f:calc_angle
	sec
	sbc	a:p2_view_angle
	clc
	adc	#$0010
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	and	#$000E
	tay
loc_02DA14:
	lda	a:title_menu_cursor
	beq	loc_02DA1C
	dec	a
	beq	loc_02DA54
loc_02DA1C:
	; (not executed in the CDL traces)
	lda	a:data_05E096,y
	beq	loc_02DA32
	sta	a:td_arrow_objs
	lda	a:data_05E0B6,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0070
	sta	a:td_arrow_objs+OBJ_Y
	bra	loc_02DA38
loc_02DA32:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
loc_02DA38:
	lda	a:data_05E0A6,y
	beq	loc_02DA4D
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:data_05E0C6,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02DA4D:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
loc_02DA54:
	lda	a:data_05E096,y
	beq	loc_02DA6A
	sta	a:td_arrow_objs+2*OBJ_SIZE
	lda	a:data_05E0B6,y
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_X
	lda	#$00A8
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
	bra	loc_02DA70
loc_02DA6A:
	lda	#$00F0
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
loc_02DA70:
	lda	a:data_05E0A6,y
	beq	loc_02DA85
	sta	a:td_arrow_objs+3*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_X
	lda	a:data_05E0D6,y
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
loc_02DA85:
	lda	#$00F0
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
loc_02DA8C:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	a:targets_left_flag
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	jmp	a:loc_02DA14

td_aim_p2_arrow_stage2_boss:
	; (not executed in the CDL traces)
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	loc_02DA8C
	cmp	#$0009
	beq	loc_02DA8C
	cmp	#$000A
	beq	loc_02DA8C
	cmp	#$000B
	beq	loc_02DA8C
	cmp	#$0011
	bcc	loc_02DAC4
loc_02DABA:
	lda	#$00F0
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
loc_02DAC4:
	lda	$0A,x
	sec
	sbc	a:p2_view_x
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:p2_view_y
	sta	zp_1E
	jmp	a:loc_02D9F8

td_p2_vs_stage5_boss:
	; (not executed in the CDL traces)
	jsr	a:td_p2_shots_vs_stage5_boss
	jsr	a:td_p2_vs_items
	jmp	a:loc_02DBA1

td_p2_shots_vs_stage5_boss:
	; (not executed in the CDL traces)
	ldx	#$0700
loc_02DAE3:
	lda	$10,x
	dec	a
	bpl	loc_02DAEB
	brl	loc_02DB92
loc_02DAEB:
	lda	a:td_map_objects+$16
	bpl	loc_02DB35
	lda	a:td_map_objects+$2E
	bit	#$0003
	beq	loc_02DB35
	lda	a:td_boss_x
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	loc_02DB35
	lda	a:td_boss_y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	loc_02DB35
	jsl	f:td_end_shot
	lda	a:td_map_objects+$2E
	ora	#$0040
	sta	a:td_map_objects+$2E
	lda	a:td_boss_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_hp
	bpl	loc_02DB35
	ldy	#$0AC0
	jsl	f:td_score_shot_kill
loc_02DB35:
	ldy	#$0B40
@loop:
	lda	a:$0016,y
	bpl	@next
	lda	a:$002E,y
	bit	#$0003
	beq	@next
	lda	a:$000A,y
	clc
	adc	#$0006
	sec
	sbc	$0A,x
	cmp	#$000C
	bcs	@next
	lda	a:$000E,y
	clc
	adc	#$0006
	sec
	sbc	$0E,x
	cmp	#$000C
	bcs	@next
	jsl	f:td_end_shot
	lda	a:$0016,y
	bit	#$1000
	beq	@next
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@next
	jsl	f:td_score_shot_kill_enemy
@next:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcc	@loop
loc_02DB92:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	loc_02DAE3
@return:
	rts
loc_02DBA1:
	lda	a:td_p2_hit_flags
	bmi	loc_02DBA7
	rts
loc_02DBA7:
	lda	a:td_map_objects+$16
	bpl	loc_02DBE9
	lda	a:td_boss_x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	loc_02DBE9
	lda	a:td_boss_y
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	loc_02DBE9
	lda	a:td_map_objects+$2E
	bit	#$0040
	bne	loc_02DBDA
	ora	#$0040
	sta	a:td_map_objects+$2E
loc_02DBDA:
	dec	a:td_boss_hp
	bpl	loc_02DBE9
	ldx	#$0AC0
	ldy	#$1FC0
	jsl	f:td_score_kill
loc_02DBE9:
	ldx	#$0B40
loc_02DBEC:
	lda	$16,x
	bpl	loc_02DC2D
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p2_x
	cmp	#$0014
	bcs	loc_02DC2D
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p2_y
	cmp	#$0014
	bcs	loc_02DC2D
	lda	a:p2_barrier_timer
	beq	loc_02DC27
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	loc_02DC2D
	ldy	#$1FC0
	jsl	f:td_score_enemy_kill
	bra	loc_02DC2D
loc_02DC27:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
loc_02DC2D:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_02DBEC
	jmp	a:loc_02D5C3

; Stage 2: block animations of the map (four blocks a frame through the
; patch slots), and timers at $1880 that redraw a spot and spawn an object.
td_update_stage2_map_events:
	lda	a:wram_1800
	ora	a:wram_1802
	ora	a:wram_1804
	ora	a:wram_1806
	beq	loc_02DC4C
	brl	loc_02DCC8
loc_02DC4C:
	lda	a:block_anim_timer_left
	beq	loc_02DC8A
	dec	a:block_anim_timer_left
	asl	a
	tay
	lda	a:data_05E13C,y
	beq	loc_02DC8A
	tax
	ldy	a:data_05E17C,x
	lda	a:data_05E1BC,x
	phx
	jsl	f:set_m7_block_patch_0
	plx
	ldy	a:data_05E18C,x
	lda	a:data_05E1CC,x
	phx
	jsl	f:set_m7_block_patch_1
	plx
	ldy	a:data_05E19C,x
	lda	a:data_05E1DC,x
	phx
	jsl	f:set_m7_block_patch_2
	plx
	ldy	a:data_05E1AC,x
	lda	a:data_05E1EC,x
	jml	f:set_m7_block_patch_3
loc_02DC8A:
	lda	a:block_anim_timer_right
	beq	loc_02DCC8
	dec	a:block_anim_timer_right
	asl	a
	tay
	lda	a:data_05E13C,y
	beq	loc_02DCC8
	tax
	ldy	a:data_05E17C,x
	lda	a:data_05E1FC,x
	phx
	jsl	f:set_m7_block_patch_0
	plx
	ldy	a:data_05E18C,x
	lda	a:data_05E20C,x
	phx
	jsl	f:set_m7_block_patch_1
	plx
	ldy	a:data_05E19C,x
	lda	a:data_05E21C,x
	phx
	jsl	f:set_m7_block_patch_2
	plx
	ldy	a:data_05E1AC,x
	lda	a:data_05E22C,x
	jml	f:set_m7_block_patch_3
loc_02DCC8:
	ldx	#$002C
loc_02DCCB:
	lda	a:$187E,x
	beq	loc_02DD14
	dec	a:$187E,x
	beq	loc_02DD03
	cmp	#$0020
	bne	loc_02DD14
	pha
	lda	#$0030
	jsl	f:queue_sound
	pla
	jsl	f:td_find_free_item_slot
	bcs	loc_02DD01
	lda	#TDI_BLAST
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	a:data_05E0E4,x
	sta	a:$000A,y
	lda	a:data_05E110,x
	sta	a:$000E,y
loc_02DD01:
	bra	loc_02DD14
loc_02DD03:
	phx
	ldy	#$0057
	lda	a:data_05E23C,x
	jsl	f:queue_m7_block_patch
	plx
	bcc	loc_02DD14
	; (not executed in the CDL traces)
	inc	a:$187E,x
loc_02DD14:
	dex
	dex
	bne	loc_02DCCB
	rtl

; Stage 5: runs the three switch events ($18B0, $18BE, $18CC, $0E bytes
; each) started by td_trigger_switch_event.
td_update_switch_events:
	ldx	#$18B0
loc_02DD1C:
	lda	$00,x
	beq	loc_02DD23
	jsr	a:td_step_switch_event
loc_02DD23:
	txa
	clc
	adc	#$000E
	tax
	cpx	#$18DA
	bcc	loc_02DD1C
	rtl

td_step_switch_event:
	lda	#$0001
	sta	a:screen_shake_timer
	jsr	a:td_switch_event_explosion
	lda	$04,x
	inc	$04,x
	ldy	difficulty
	cmp	a:data_05E26A,y
	bcs	loc_02DD44
	rts
loc_02DD44:
	jsr	a:td_patch_switch_event_block
	bcs	@return
	lda	#$0030
	jsl	f:queue_sound
	dec	$02,x
	beq	loc_02DD69
	stz	$04,x
	ldy	$06,x
	lda	$08,x
	clc
	adc	a:data_05E270,y
	sta	$08,x
	lda	$0C,x
	clc
	adc	a:data_05E274,y
	sta	$0C,x
@return:
	rts
loc_02DD69:
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	rts

td_patch_switch_event_block:
	lda	$06,x
	asl	a
	asl	a
	clc
	adc	$02,x
	asl	a
	tay
	lda	a:data_05E276,y
	tay
	lda	$0C,x
	phx
	jsl	f:queue_m7_block_patch
	plx
	rts

td_switch_event_explosion:
	lda	$04,x
	bit	#$0007
	bne	@return
	jsl	f:td_find_free_item_slot
	bcs	@return
	lda	#TDI_EXPLOSION
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	rng_lo
	and	#$0007
	sec
	sbc	#$0004
	clc
	adc	$08,x
	sta	a:$000A,y
	lda	rng_hi
	and	#$0007
	sec
	sbc	#$0004
	clc
	adc	$0A,x
	sta	a:$000E,y
@return:
	rts
