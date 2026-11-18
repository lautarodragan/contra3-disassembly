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
	bne	@active
	brl	td_player_state_inactive
@active:
	lda	a:$0648,x
	beq	@check_falling
	dec	a:$0648,x
	bne	@blink
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0002
@blink:
	and	#$0002
	lsr	a
	sta	$00,x
@check_falling:
	lda	$2C,x
	beq	@check_hit
	brl	td_player_state_falling
@check_hit:
	lda	$06,x
	bpl	@alive
.if CHEAT_INVINCIBLE
	stz	$06,x	; cheat: the hit (td_p1_hp = $FFFF) is undone
.else
	brl	td_player_state_dying
.endif
@alive:
.if CHEAT_DEBUG_KEYS
	jsr	a:td_debug_cheat_buttons
.endif
	jsr	a:td_update_turn_speed
	jsr	a:td_update_fire_timer
	jsr	a:td_set_spin_direction
	jsr	a:td_check_smart_bomb
	lda	a:$0640,x
	beq	@no_action
	brl	@run_state
@no_action:
	jsr	a:td_check_turn_buttons_both
	bcc	@not_turn_buttons
	brl	td_player_state_turn_buttons
@not_turn_buttons:
	stz	a:$10CE,x
	lda	a:$066C,x
	bit	zp_92
	beq	@not_jump
	brl	td_player_state_jump
@not_jump:
	bit	#$0F00
	beq	@not_dpad
	brl	td_player_state_walk
@not_dpad:
	bit	zp_96
	beq	@not_r
	brl	td_player_state_walk
@not_r:
	bit	zp_94
	beq	@stand
	brl	td_player_state_walk
@stand:
	brl	td_player_state_stand
@run_state:
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
td_player_start_respawn:
	stz	$00,x
	stz	$06,x
	stz	a:$0648,x
	stz	$16,x
	lda	#$0001
	sta	a:$10CC,x

; State 0: no player (no lives) or respawn: drop in at a start point.
td_player_state_inactive:
	lda	a:$10CA,x
	bne	@respawn
	stz	a:$10CC,x
	stz	$12,x
	lda	a:title_menu_cursor
	beq	@return
	; (not executed in the CDL traces)
	dec	a
	bne	@join_partner
	lda	a:$10F4,x
	beq	@join_partner
	dec	a:$10F4,x
@return:
	rtl
@join_partner:
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
	bne	@has_priority
	lda	#$2000
@has_priority:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	@set_partner_attr
	lda	#$0A00
@set_partner_attr:
	and	#$CFFF
	ora	zp_FA
	sta	$02,x
	rtl
@respawn:
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
	beq	@default_attr
	lda	$2C,x
	beq	@keep_attr
@default_attr:
	lda	#$2800
	cpx	#$0EC0
	beq	@set_attr
	lda	#$2A00
@set_attr:
	sta	$02,x
@keep_attr:
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
	bne	@centered_view
	lda	#$0100
	sta	a:$10D4,x
	sta	a:$10D6,x
@centered_view:
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
	cpx	#$0EC0
	bne	@is_player2
	ldy	#$0F00
	rts
@is_player2:
	ldy	#$0EC0
	rts

; Puts a respawning player at the start point nearest to where it died.
td_set_respawn_position:
	lda	a:title_menu_cursor
	dec	a
	beq	td_respawn_split_screen
	bpl	td_respawn_near_partner
td_respawn_at_start_point:
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
td_respawn_split_screen:
	lda	$2C,x
	bne	td_respawn_at_start_point
	rts
td_respawn_near_partner:
	lda	$2C,x
	beq	@return
	jsr	a:td_get_other_player
	lda	a:$10CA,y
	beq	td_respawn_at_start_point
	lda	a:$002C,y
	bne	td_respawn_at_start_point
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
	bne	@has_priority
	; (not executed in the CDL traces)
	lda	#$2000
@has_priority:
	sta	zp_FA
	lda	#$0800
	cpx	#$0EC0
	beq	@set_attr
	lda	#$0A00
@set_attr:
	ora	zp_FA
	sta	$02,x
@return:
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
	bmi	@negative
	cmp	#$0400
	bpl	@too_big
	rts
@negative:
	lda	#$0000
	rts
@too_big:
	lda	#$03FF
	rts

; A = the object's x clamped to 0..$3FF.
clamp_x_to_map:
	lda	$0A,x
	bmi	@negative
	cmp	#$0400
	bpl	@too_big
	rts
@negative:
	; (not executed in the CDL traces)
	lda	#$0000
	rts
@too_big:
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
	beq	@normal_speed
	lda	a:$0642,x
	bit	#$00FF
	beq	@check_new_press
	xba
	and	#$0030
	bit	a:$066E,x
	bne	@double_tap
	bit	a:$066C,x
	beq	@check_new_press
	rts
@double_tap:
	xba
	ora	#$0008
	sta	a:$0642,x
	lda	#$0004
	sta	a:$0644,x
	rts
@check_new_press:
	lda	a:$066E,x
	and	#$0030
	beq	@count_down
	xba
	ora	#$0008
	sta	a:$0642,x
@normal_speed:
	lda	#$0002
	sta	a:$0644,x
@count_down:
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
	beq	@held
	stz	a:$0646,x
	rts
@held:
	inc	a:$0646,x
	rts

; Carry set when both turn buttons (L and R) are held.
td_check_turn_buttons_both:
	lda	zp_94
	ora	zp_96
	sta	zp_FA
	and	a:$066C,x
	cmp	zp_FA
	beq	@return_sec
	clc
	rts
@return_sec:
	sec
	rts

; +$0656 = 0 or 2 by the turn button pressed last.
td_set_spin_direction:
	lda	#$0007
	cmp	$12,x
	beq	@return
	lda	a:$066E,x
	bit	zp_96
	bne	@r_pressed
	bit	zp_94
	beq	@return
	lda	#$0002
	sta	a:$0656,x
	rts
@r_pressed:
	stz	a:$0656,x
@return:
	rts

; (no caller found; decoded because it follows the end of a routine)
; Never called: with X held, pressed buttons change the weapons, the bombs
; (up to 9), the barrier ($FFFF) and the lives (up to 99) of the player.
; Probably a leftover debug feature.
td_debug_cheat_buttons:
	; (not executed in the CDL traces)
	lda	a:$066C,x
	bit	#$0040
	beq	@return
	lda	a:$066E,x
	bit	#$0020
	beq	@check_r
	inc	a:$10C4,x
	lda	a:$10C4,x
	cmp	#$0006
	bcc	@check_r
	stz	a:$10C4,x
@check_r:
	lda	a:$066E,x
	bit	#$0010
	beq	@check_a
	inc	a:$10C6,x
	lda	a:$10C6,x
	cmp	#$0006
	bcc	@check_a
	stz	a:$10C6,x
@check_a:
	lda	a:$066E,x
	bit	#$0080
	beq	@check_y
	inc	a:$10CC,x
	lda	a:$10CC,x
	cmp	#$0009
	bcc	@check_y
	lda	#$0009
	sta	a:$10CC,x
@check_y:
	lda	a:$066E,x
	bit	#$4000
	beq	@check_b
	lda	#$FFFF	; [num]
	sta	a:$10C8,x
@check_b:
	lda	a:$066E,x
	bit	#$8000
	beq	@return
	inc	a:$10CA,x
	lda	a:$10CA,x
	cmp	#$0063
	bcc	@return
	lda	#$0063
	sta	a:$10CA,x
@return:
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
	lda	#SOUND_SMART_BOMB
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
	beq	@in_state
	sta	$12,x
	lda	#$0008
	sta	a:$0640,x
@in_state:
	lda	a:$0640,x
	cmp	#$0004
	bne	@count_down
	lda	a:$066C,x
	bit	#$8000
	beq	@count_down
	bit	#$4000
	beq	@animate
	jsl	f:td_fire_jump_shot
	bra	@animate
@count_down:
	dec	a:$0640,x
	bpl	@animate
	stz	a:$0640,x
	lda	#$0003
	sta	$12,x
@animate:
	jsl	f:td_set_jump_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_jump_anim:
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rtl
@set_anim:
	lda	#$0000
	ldy	a:$0640,x
	cpy	#$0004
	bne	@add_weapon_slot
	lda	#$0004
@add_weapon_slot:
	ora	a:$10DE,x
	tay
	lda	a:td_player_jump_anims,y
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
	beq	@in_state
	sta	$12,x
@in_state:
	jsl	f:td_set_stand_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_stand_anim:
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rtl
@set_anim:
	ldy	a:$10DE,x
	lda	a:td_player_stand_anims,y
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
	beq	@in_state
	sta	$12,x
	stz	$24,x
@in_state:
	jsl	f:td_set_stand_fire_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	jml	f:td_fire_forward

td_set_stand_fire_anim:
	inc	$24,x
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rtl
@set_anim:
	lda	$24,x
	and	#$0004
	ora	a:$10DE,x
	tay
	lda	a:td_player_stand_fire_anims,y
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
	beq	@in_state
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0004
	sta	$24,x
	lda	#$0001
	sta	a:$0640,x
	stz	a:$064A,x
@in_state:
	lda	$24,x
	beq	@delay_done
	dec	$24,x
	bra	@animate
@delay_done:
	stz	a:$0640,x
	jsr	a:td_check_turn_buttons_both
	bcs	@both_held
	bra	@animate
@both_held:
	lda	a:$066C,x
	bit	button_fire
	bne	td_player_state_spin_fire
@animate:
	jsl	f:td_set_turn_buttons_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	rtl

td_set_turn_buttons_anim:
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rtl
@set_anim:
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
	beq	@in_state
	sta	$12,x
	lda	#$0002
	sta	a:$10CE,x
	lda	#$0001
	sta	a:$0640,x
	sta	a:$064A,x
	sta	a:$065A,x
@in_state:
	jsr	a:td_check_turn_buttons_both
	bcc	@stop_spin
	lda	a:$066C,x
	bit	button_fire
	bne	@check_spin
@stop_spin:
	stz	a:$065A,x
@check_spin:
	lda	a:$065A,x
	bne	@spin
	lda	a:$0654,x
	clc
	adc	a:$0658,x
	and	#$00FF
	cmp	$04,x
	bne	@spin
	brl	td_player_state_turn_buttons
@spin:
	jsr	a:td_set_spin_fire_anim
	jsl	f:td_player_tile_collision
	jsr	a:td_keep_players_together
	jsr	a:td_spin_player
	jmp	a:td_fire_spin_shots

td_set_spin_fire_anim:
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rts
@set_anim:
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
	beq	@in_state
	sta	$12,x
@in_state:
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
	beq	@in_state
	sta	$12,x
@in_state:
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
	beq	@in_state
	pha
	jsr	a:topdown_lose_life
	pla
	sta	$12,x
	lda	#SOUND_PLAYER_DIE
	jsl	f:queue_sound
	lda	#$0020
	jsl	f:set_velocity_from_angle
	stz	$24,x
	lda	#$0001
	sta	a:$064A,x
	stz	$16,x
@in_state:
	lda	$24,x
	cmp	#$0010
	bcc	@advance
	cmp	#$0080
	bcc	@slow_down
	brl	td_player_start_respawn
@slow_down:
	jsl	f:td_halve_x_velocity
	jsl	f:td_halve_y_velocity
@advance:
	inc	$24,x
	jsl	f:td_spin_dying_player
	jsl	f:td_player_tile_collision
	jsl	f:move_topdown_object
	jsr	a:td_keep_players_together
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rtl
@set_anim:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	@add_weapon_slot
	lda	#$0004
@add_weapon_slot:
	ora	a:$10DE,x
	tay
	lda	a:td_player_dying_anims,y
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
	adc	a:td_dying_spin_speeds,y
	and	#$00FF
	sta	$04,x
	rtl

td_halve_x_velocity:
	lda	$1A,x
	cmp	$18,x
	bne	@halve
	cmp	#$FFFF	; [num]
	bne	@halve
	stz	$1A,x
	stz	$18,x
	rtl
@halve:
	lda	$1A,x
	asl	a
	ror	$1A,x
	ror	$18,x
	rtl

td_halve_y_velocity:
	lda	$1E,x
	cmp	$1C,x
	bne	@halve
	cmp	#$FFFF	; [num]
	bne	@halve
	stz	$1E,x
	stz	$1C,x
	rtl
@halve:
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
	beq	@in_state
	pha
	jsr	a:topdown_lose_life
	pla
	sta	$12,x
	lda	#SOUND_PLAYER_FALL
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
@in_state:
	lda	$24,x
	cmp	#$0010
	bcc	@advance
	cmp	#$0080
	bcc	@advance
	brl	td_player_start_respawn
@advance:
	inc	$24,x
	jsr	a:td_spin_falling_player
	jsl	f:td_player_tile_collision
	jsl	f:move_topdown_object
	jsr	a:td_keep_players_together
	jsr	a:zoom_in_falling_view
	jsr	a:td_set_falling_anim
	lda	a:title_menu_cursor
	beq	@fade_view
	dec	a
	bne	@return
@fade_view:
	lda	$24,x
	cmp	#$0020
	bcc	@return
	lsr	a
	bcs	@return
	lda	a:$10F4,x
	beq	@return
	dec	a:$10F4,x
@return:
	rtl

td_set_falling_anim:
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rts
@set_anim:
	lda	#$0000
	ldy	$24,x
	cpy	#$0010
	bcc	@add_weapon_slot
	lda	#$0004
@add_weapon_slot:
	ora	a:$10DE,x
	tay
	lda	a:td_player_falling_anims,y
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
	beq	@zoom
	dec	a
	bne	@return
@zoom:
	lda	a:$10D4,x
	sec
	sbc	#$0004
	sta	a:$10D4,x
	lda	a:$10D6,x
	sec
	sbc	#$0004
	sta	a:$10D6,x
@return:
	rts

; Up/down: forward/backward along the view, left/right: sideways (vectors by view angle).
td_walk_by_dpad:
	ldy	a:$10CE,x
	bne	@return
	jsr	a:td_get_walk_vectors
	lda	a:$066C,x
	bit	#$0800
	beq	@check_back
	jsr	a:td_walk_forward
	bra	@check_sideways
@check_back:
	bit	#$0400
	beq	@check_sideways
	jsr	a:td_walk_backward
@check_sideways:
	lda	a:$066C,x
	bit	#$0100
	beq	@check_left
	bra	td_walk_right
@check_left:
	bit	#$0200
	beq	@return
	bra	td_walk_left
@return:
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
td_walk_right:
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
td_walk_left:
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
	jsr	a:td_get_other_player
	lda	a:$0012,y
	beq	@return
	jsr	a:td_pull_towards_other_player_x
	jsr	a:td_pull_towards_other_player_y
@return:
	rts

td_pull_towards_other_player_x:
	lda	a:$000A,y
	sec
	sbc	#$0090
	cmp	$0A,x
	bpl	@too_far_left
	clc
	adc	#$0120
	cmp	$0A,x
	bmi	@too_far_right
	bne	@return
@too_far_right:
	dec	a
	sta	$0A,x
	stz	a:$0672,x
@return:
	rts
@too_far_left:
	inc	a
	sta	$0A,x
	stz	a:$0672,x
	rts

td_pull_towards_other_player_y:
	lda	a:$000E,y
	sec
	sbc	#$0058
	cmp	$0E,x
	bpl	@too_far_up
	clc
	adc	#$00B0
	cmp	$0E,x
	bmi	@too_far_down
	bne	@return
@too_far_down:
	dec	a
	sta	$0E,x
	stz	a:$0672,x
@return:
	rts
@too_far_up:
	inc	a
	sta	$0E,x
	stz	a:$0672,x
	rts

td_set_walk_anim:
	inc	$24,x
	lda	$22,x
	bne	@set_anim
	inc	$22,x
	rts
@set_anim:
	lda	$24,x
	lsr	a
	and	#$000C
	ora	a:$10DE,x
	tay
	lda	a:td_player_walk_anims,y
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
	bne	@increase_angle
	bit	zp_94
	bne	@decrease_angle
	rts
@increase_angle:
	lda	$04,x
	clc
	adc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts
@decrease_angle:
	lda	$04,x
	sec
	sbc	a:$0644,x
	and	#$00FF
	sta	$04,x
	rts

; Spin fire: angle +8 a frame.
td_spin_player:
	lda	a:$0656,x
	bne	@decrease_angle
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rts
@decrease_angle:
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
	bpl	@lives_left
	; (not executed in the CDL traces)
	stz	a:$10CA,x
@lives_left:
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
	lda	a:td_jump_fire_side_offsets,y
	sta	zp_10
	ldy	#$0020
	bra	fire_topdown_weapon
; Fires the active weapon straight ahead.
td_fire_forward:
	stz	zp_12
	ldy	a:$10DE,x
	sty	zp_14
	lda	a:td_fire_side_offsets,y
	sta	zp_10
	ldy	#$0018

; Fires weapon p1_weapon_1 (zp_14 = 0) or p1_weapon_2 (zp_14 = 2) of player X
; through tbl_topdown_weapons (WEAPON_* order).
fire_topdown_weapon:
	jsr	a:td_get_muzzle_position
	lda	a:$10C4,x
	ldy	zp_14
	beq	@dispatch
	lda	a:$10C6,x
@dispatch:
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
	bcc	@fire
@return:
	rtl
@fire:
	lda	a:$0646,x
	and	#$0003
	bne	@no_sound
	lda	#SOUND_SHOT_DEFAULT
	jsl	f:queue_sound
@no_sound:
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
	beq	@fire
@no_shot:
	rtl
@fire:
	jsl	f:td_find_free_shot_slot
	bcs	@no_shot
	lda	a:$0646,x
	and	#$0007
	bne	@no_sound
	lda	#SOUND_SHOT_SPREAD
	jsl	f:queue_sound
@no_sound:
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
	lda	a:td_spread_angle_offsets,y
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
	bcc	@fire
@return:
	rtl
@fire:
	lda	#SOUND_SHOT_HOMING
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
	bcc	@fire
	rtl
@fire:
	lda	a:$0646,x
	and	#$000F
	bne	@no_sound
	lda	#SOUND_SHOT_LASER
	jsl	f:queue_sound
@no_sound:
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
	bcc	@update_flame
	jsl	f:td_find_free_shot_slot
	bcc	@new_flame
	rtl
@new_flame:
	jsr	a:td_play_flame_sound
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_FLAME
	sta	a:$0010,y
@update_flame:
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
	lda	#SOUND_SHOT_FLAME
	jsl	f:queue_sound
@return:
	rts

fire_td_crush:
	lda	a:$0646,x
	and	#$0001
	bne	@return
	jsl	f:td_find_three_shot_slots
	bcc	@fire
@return:
	rtl
@fire:
	lda	#SOUND_SHOT_CRUSH
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
	bne	@second_weapon
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	@set_end
	ldy	#$0700
	lda	#$0840
@set_end:
	sta	zp_FA
	bra	@loop
@second_weapon:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	@set_end2
	ldy	#$0840
	lda	#$0980
@set_end2:
	sta	zp_FA
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
	cpy	zp_FA
	bcc	@loop
	rtl

td_find_flame_shot:
	lda	zp_14
	bne	@second_weapon
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	@set_end
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
@set_end:
	sta	zp_FA
	bra	@loop
@second_weapon:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	@set_end2
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
@set_end2:
	sta	zp_FA
@loop:
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
	bcc	@loop
	rtl

td_find_three_shot_slots:
	lda	zp_14
	bne	@second_weapon
	ldy	#$0480
	lda	#$05C0
	cpx	#$0EC0
	beq	@set_end
	; (not executed in the CDL traces)
	ldy	#$0700
	lda	#$0840
@set_end:
	sta	zp_FA
	bra	@search
@second_weapon:
	ldy	#$05C0
	lda	#$0700
	cpx	#$0EC0
	beq	@set_end2
	; (not executed in the CDL traces)
	ldy	#$0840
	lda	#$0980
@set_end2:
	sta	zp_FA
@search:
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
	beq	@random_enemy
	jsl	f:td_check_enemies_alive
	bcc	@centipede
	rtl
@random_enemy:
	jsl	f:td_find_free_enemy_slot
	bcc	@place
@no_spawn:
	rtl
@place:
	jsr	a:td_place_enemy_near_player
	bcs	@no_spawn
	ldy	difficulty
	lda	rng_lo
	and	a:td_spawn_type_masks,y
	beq	@set_type
	lda	#$0002
@set_type:
	tay
	lda	a:stage2_spawn_types,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
@centipede:
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
	beq	@random_enemy
	jsl	f:td_check_enemies_alive
	bcc	@centipede
	rtl
@random_enemy:
	jsl	f:td_find_free_enemy_slot
	bcc	@place
@no_spawn:
	rtl
@place:
	jsr	a:td_place_enemy_near_player
	bcs	@no_spawn
	ldy	difficulty
	lda	rng_lo
	and	a:td_spawn_type_masks,y
	beq	@set_type
	lda	#$0002
@set_type:
	tay
	lda	a:stage5_spawn_types,y
	sta	$10,x
	stz	$00,x
	stz	$2E,x
	rtl
@centipede:
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
.if CHEAT_EXTRA_STAGE
	; the tables are in bank $04 in the extra-stage build (data/tables_05.asm):
	; index in X, the enemy in Y
	phx
	tyx
	ply
	lda	f:td_spawn_offsets_x,x
	clc
	adc	zp_FC
	sta	a:$000A,y
	lda	f:td_spawn_offsets_y,x
	clc
	adc	zp_FE
	sta	a:$000E,y
	tyx
.else
	lda	a:td_spawn_offsets_x,y
	clc
	adc	zp_FC
	sta	$0A,x
	lda	a:td_spawn_offsets_y,y
	clc
	adc	zp_FE
	sta	$0E,x
.endif
	lda	#$2000
	sta	$02,x
	jsl	f:td_enemy_tile_collision
@return:
	rts

; zp_FC/zp_FE = position of a living player (random in 2P); carry set if none.
td_pick_spawn_player:
	lda	a:title_menu_cursor
	bne	@two_players
	lda	a:p1_lives
	bne	@one_player
	; (not executed in the CDL traces)
	sec
	rts
@one_player:
	lda	a:td_p1_x
	sta	zp_FC
	lda	a:td_p1_y
	sta	zp_FE
	clc
	rts
@two_players:
	lda	zp_E9
	lsr	a
	bcs	@try_player2
@try_player1:
	lda	a:p1_lives
	bne	@player1
	; (not executed in the CDL traces)
	lda	a:p2_lives
	bne	@try_player2
	sec
	rts
@player1:
	lda	a:td_p1_x
	sta	zp_FC
	lda	a:td_p1_y
	sta	zp_FE
	clc
	rts
@try_player2:
	lda	a:p2_lives
	bne	@player2
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	@try_player1
	sec
	rts
@player2:
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
	bne	@two_players
	lda	a:p1_lives
	bne	@player1
	; (not executed in the CDL traces)
	sec
	rtl
@two_players:
	lda	a:p1_lives
	beq	@only_player2
	lda	a:p2_lives
	beq	@only_player1
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
	bne	@pick
	lda	stage_frame_counter
	xba
	lsr	a
@pick:
	bcc	@player2
@player1:
	lda	a:td_p1_x
	sta	zp_18
	lda	a:td_p1_y
	sta	zp_1A
	clc
	rtl
@player2:
	lda	a:td_p2_x
	sta	zp_18
	lda	a:td_p2_y
	sta	zp_1A
	clc
	rtl
@only_player1:
	; (not executed in the CDL traces)
	lda	a:p1_lives
	bne	@player1
	sec
	rtl
@only_player2:
	lda	a:p2_lives
	bne	@player2
	sec
	rtl

; A = angle from object X to the nearest player (td_get_nearest_player).
td_angle_to_nearest_player:
	jsl	f:td_get_nearest_player
	bcc	@found
	; (not executed in the CDL traces)
	rtl
@found:
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
	bne	@player1_near
	bit	#$0020
	beq	@return_sec
	ldy	#$0D80
	bra	@check_slot
@player1_near:
	ldy	#$0D40
@check_slot:
	lda	a:$0010,y
	bne	@return_sec
	clc
	rtl
@return_sec:
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
	beq	@check_hit
	cmp	#$0004
	bne	@count_down
	jsr	a:td_restore_boss_palette
@count_down:
	dec	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
@return:
	rtl
@check_hit:
	lda	$2E,x
	bit	#$0040
	beq	@return
	and	#$FFBF
	sta	$2E,x
	lda	#$0004
	sta	$2A,x
	lda	#SOUND_CLANG
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
	bcs	@return
	sec
	sbc	$04,x
	beq	@facing
	bit	#$0080
	bne	@decrease_angle
	lda	$04,x
	clc
	adc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
@decrease_angle:
	lda	$04,x
	sec
	sbc	zp_FA
	and	#$00FF
	sta	$04,x
	clc
	rtl
@facing:
	sec
@return:
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
	bra	td_update_enemy_slots

; Runs the enemies ($0D40-$0EBF): handler by type (tbl_td_enemy_types), animation, hit flash.
td_update_enemies:
	ldx	#$0D40
td_update_enemy_slots:
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
	bcc	td_update_enemy_slots

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
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$28,x
	bne	@return
	jml	f:clear_topdown_slot
@return:
	rtl

; Steps the animation script at +$28 (entries of 3 words).
td_animate_enemy:
	ldy	$28,x
	beq	@return
	dec	$22,x
	bmi	@restart_frame
	bne	@return
	tya
	clc
	adc	#$0006
@loop:
	tay
	lda	a:$0000,y
	bmi	@loop
	beq	@end_script
	sty	$28,x
@set_frame:
	sta	$22,x
	lda	a:$0002,y
	sta	$20,x
	lda	$02,x
	and	#$3000
	ora	a:$0004,y
	sta	$02,x
@return:
	rtl
@restart_frame:
	lda	a:$0000,y
	bne	@set_frame
@end_script:
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
	bne	@restore
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
@restore:
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
	lda	#SOUND_CLANG
	jsl	f:queue_sound
@return:
	rtl

; Turns one step towards the nearest player and walks forward ($0C).
td_walk_towards_nearest_player:
	jsr	a:td_get_angle_to_nearest_player
	bcs	@step
	jsr	a:td_turn_one_step
@step:
	jsr	a:td_enemy_step_forward
	rtl

td_get_angle_to_nearest_player:
	jsl	f:td_get_nearest_player
	bcc	@found
	; (not executed in the CDL traces)
	rts
@found:
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
	beq	@return
	bpl	@increase_angle
	cmp	#$8000	; [num]
	bne	@decrease_angle
	lda	rng_lo
	lsr	a
	bcs	@decrease_angle
@increase_angle:
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
@return:
	rts
@decrease_angle:
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
	bne	@decrease_angle
	lda	$04,x
	inc	a
	and	#$00FF
	sta	$04,x
	rts
@decrease_angle:
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
	beq	@off_screen
	brl	clear_topdown_slot
@off_screen:
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
	beq	@off_screen
	brl	clear_topdown_slot
@off_screen:
	inc	$12,x
	rtl

td_runner_state_2:
	lda	$00,x
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	clear_topdown_slot
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	@on_screen
	jsl	f:td_walk_towards_nearest_player
	rtl
@on_screen:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_runner_state_3:
	lda	$06,x
	bmi	@killed
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	jsl	f:td_walk_towards_nearest_player
	rtl
@killed:
	stz	$06,x
	lda	#SOUND_ENEMY_DIE
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	clear_topdown_slot
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	td_gunner_start_chase
	jsl	f:td_walk_towards_nearest_player
	rtl
td_gunner_start_chase:
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
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$06,x
	bmi	td_gunner_explode
	dec	$24,x
	bpl	@walk
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	beq	@facing
@walk:
	jsl	f:td_walk_towards_nearest_player
	rtl
@facing:
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
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$06,x
	bmi	td_gunner_explode
	dec	$24,x
	bpl	@check_fire
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	bne	td_gunner_start_chase
	ldy	difficulty
	lda	a:td_gunner_fire_delays,y
	sta	$24,x
@check_fire:
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
td_gunner_explode:
	lda	#SOUND_ENEMY_DIE
	jsl	f:queue_sound
	jmp	a:td_start_explosion

; TDT_HATCH_TURRET_AIM, stage 2: the gun turret of a hatch (TDMT_GUN_HATCH_*,
; parent in +$3A). Hidden until the hatch opens (parent state 3), then turns
; towards the nearest player and fires when roughly facing it
; (hatch_turret_aim_fire_masks); hides when the hatch closes, explodes when
; the hatch is destroyed. HP 16/32/64 (hatch_turret_hp).
update_hatch_turret_aim:
	lda	$06,x
	bpl	@alive
	brl	hatch_turret_explode
@alive:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	@check_open
	brl	clear_topdown_slot
@check_open:
	cmp	#$0003
	bne	@check_closing
	brl	hatch_turret_aim_open
@check_closing:
	cmp	#$0004
	bne	@check_destroyed
	brl	hatch_turret_hide
@check_destroyed:
	cmp	#$0005
	bne	@run_state
	brl	hatch_turret_explode
@run_state:
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
hatch_turret_aim_open:
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
	adc	a:hatch_turret_aim_half_speeds,y
	sec
	sbc	$04,x
	cmp	a:hatch_turret_aim_turn_speeds,y
	bcc	@facing
	ldy	difficulty
	lda	a:hatch_turret_aim_turn_speeds,y
	jsl	f:td_turn_towards_nearest_player
	rtl
@facing:
	ldy	difficulty
	lda	stage_frame_counter
	and	a:hatch_turret_aim_fire_masks,y
	bne	@return
	jsl	f:td_fire_gun_bullet
@return:
	rtl
hatch_turret_hide:
	lda	#$1000
	sta	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	lda	#$0003
	sta	$12,x

hatch_turret_state_3:
	rtl
hatch_turret_explode:
	stz	$06,x
	lda	#SOUND_ENEMY_DIE
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

hatch_turret_state_4:
	brl	td_start_explosion

; TDT_HATCH_TURRET_SPIN, stage 2: like TDT_HATCH_TURRET_AIM, but it turns all
; the time and fires on a timer (hatch_turret_spin_fire_masks).
update_hatch_turret_spin:
	lda	$06,x
	bpl	@alive
	brl	hatch_turret_explode
@alive:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	@check_open
	brl	clear_topdown_slot
@check_open:
	cmp	#$0003
	bne	@check_closing
	brl	hatch_turret_spin_open
@check_closing:
	cmp	#$0004
	bne	@check_destroyed
	brl	hatch_turret_hide
@check_destroyed:
	cmp	#$0005
	bne	@run_state
	brl	hatch_turret_explode
@run_state:
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
hatch_turret_spin_open:
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
	adc	a:hatch_turret_spin_speeds,y
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
	bpl	@alive
	brl	hatch_turret_explode
@alive:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0001
	bne	@check_open
	brl	clear_topdown_slot
@check_open:
	cmp	#$0003
	bne	@check_closing
	brl	hatch_turret_sweep_open
@check_closing:
	cmp	#$0004
	bne	@check_destroyed
	brl	hatch_turret_hide
@check_destroyed:
	cmp	#$0005
	bne	@run_state
	brl	hatch_turret_explode
@run_state:
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
hatch_turret_sweep_open:
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
	adc	a:hatch_turret_sweep_phase_speeds,y
	and	#$00FF
	sta	$24,x
	ldy	difficulty
	lda	stage_frame_counter
	and	a:hatch_turret_sweep_fire_masks,y
	bne	@turn
	jsl	f:td_fire_gun_bullet
@turn:
	jsr	a:hatch_turret_sweep_turn
	rtl

hatch_turret_sweep_turn:
	ldy	difficulty
	lda	$24,x
	clc
	adc	#$0040
	sec
	sbc	a:hatch_turret_sweep_phase_speeds,y
	and	#$00FF
	bit	#$0080
	bne	@decrease_angle
	lda	$04,x
	clc
	adc	a:hatch_turret_sweep_turn_speeds,y
	and	#$00FF
	sta	$04,x
	rts
@decrease_angle:
	lda	$04,x
	sec
	sbc	a:hatch_turret_sweep_turn_speeds,y
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	td_centipede_despawn
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	td_centipede_unused_on_screen
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
td_centipede_unused_on_screen:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_centipede_unused_state_3:
	; (not executed in the CDL traces)
	jsr	a:td_centipede_check_out_of_range
	bcc	@in_range
	brl	td_centipede_despawn
@in_range:
	jsr	a:td_centipede_check_killed
	bcc	@alive
	brl	td_centipede_killed
@alive:
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
td_centipede_killed:
	lda	#SOUND_EXPLOSION
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
	bcc	@no_wrap
	ldy	#$1900
@no_wrap:
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
	bpl	@return_clc
	sec
	rts
@return_clc:
	clc
	rts

td_centipede_check_out_of_range:
	lda	$2E,x
	bit	#$000C
	bne	@return_clc
	lda	a:td_enemies+3*OBJ_SIZE+$2E
	bit	#$000C
	bne	@return_clc
	lda	a:td_enemies+4*OBJ_SIZE+$2E
	bit	#$000C
	bne	@return_clc
	lda	a:td_enemies+5*OBJ_SIZE+$2E
	bit	#$000C
	bne	@return_clc
	sec
	rts
@return_clc:
	clc
	rts
td_centipede_despawn:
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
	beq	@not_hittable
	lda	#$A000	; [num]
	sta	$16,x
	rts
@not_hittable:
	stz	$16,x
	rts

td_segment_follow_trail:
	ldy	$2C,x
	cpy	#$1900
	bcs	@follow
	tya
	adc	#$0006
	sta	$2C,x
	rts
@follow:
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
	bcc	@no_wrap
	ldy	#$1900
@no_wrap:
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	td_centipede_despawn
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	@on_screen
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
@on_screen:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_bug_centipede_state_3:
	jsr	a:td_centipede_check_out_of_range
	bcc	@in_range
	brl	td_centipede_despawn
@in_range:
	jsr	a:td_centipede_check_killed
	bcc	@alive
	brl	@split
@alive:
	lda	a:td_enemies+5*OBJ_SIZE+OBJ_X
	cmp	$0A,x
	bne	@wiggle
	lda	a:td_enemies+5*OBJ_SIZE+OBJ_Y
	cmp	$0E,x
	beq	@split
@wiggle:
	dec	$24,x
	bpl	@turn
	lda	#$0080
	sta	$24,x
@turn:
	lda	#$0002
	jsl	f:td_turn_towards_nearest_player
	jsr	a:td_centipede_wiggle
	jsr	a:td_centipede_record_trail
	rtl
@split:
	lda	#SOUND_EXPLOSION
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
	bpl	@alive
	brl	td_centipede_bug_explode
@alive:
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
	bmi	td_centipede_bug_stop_and_fire
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
td_centipede_bug_stop_and_fire:
	lda	#$0020
	sta	$24,x
	lda	#$0002
	sta	$12,x

td_centipede_bug_state_2:
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$06,x
	bmi	td_centipede_bug_explode
	dec	$24,x
	bmi	@start_walk
	lda	$24,x
	cmp	#$0010
	bne	@no_fire
	jsl	f:td_fire_enemy_orb
@no_fire:
	lda	#$0002
	sta	$22,x
	jsl	f:td_enemy_tile_collision
	rtl
@start_walk:
	lda	#$A000	; [num]
	sta	$16,x
	txa
	lsr	a
	lsr	a
	lsr	a
	and	#$0018
	clc
	ldy	difficulty
	adc	a:td_centipede_bug_walk_times,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_centipede_bug_state_3:
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	dec	$24,x
	bmi	td_centipede_bug_stop_and_fire
	jsl	f:td_walk_towards_nearest_player
	rtl
td_centipede_bug_explode:
	lda	#SOUND_EXPLOSION
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	td_centipede_despawn
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	td_centipede_start_wiggle
	jsl	f:td_walk_towards_nearest_player
	jsr	a:td_centipede_record_trail
	rtl
td_centipede_start_wiggle:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0080
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_centipede_state_3:
	jsr	a:td_centipede_check_out_of_range
	bcc	@in_range
	brl	td_centipede_despawn
@in_range:
	jsr	a:td_centipede_check_killed
	bcc	@alive
	brl	td_centipede_killed
@alive:
	dec	$24,x
	bmi	@start_aim
	jsr	a:td_centipede_wiggle
	jsr	a:td_centipede_record_trail
	rtl
@start_aim:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_centipede_state_4:
	jsr	a:td_centipede_check_out_of_range
	bcc	@in_range
	brl	td_centipede_despawn
@in_range:
	jsr	a:td_centipede_check_killed
	bcc	@alive
	brl	td_centipede_killed
@alive:
	lda	#$0004
	jsl	f:td_turn_towards_nearest_player
	jsl	f:td_angle_to_nearest_player
	clc
	adc	#$0002
	sec
	sbc	$04,x
	cmp	#$0004
	bcc	td_centipede_start_wiggle
	ldy	difficulty
	lda	stage_frame_counter
	and	a:td_centipede_fire_masks,y
	bne	@no_fire
	ldy	#$0010
	jsl	f:td_fire_enemy_bullet
@no_fire:
	jsr	a:td_centipede_record_trail
	rtl

; (no caller found; decoded because it follows the end of a routine)
td_centipede_start_death_unused:
	; (not executed in the CDL traces)
	lda	#SOUND_EXPLOSION
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
	bcc	@move
	eor	#$007F
@move:
	lsr	a
	jsl	f:td_move_at_angle
	jsl	f:td_enemy_tile_collision
	rts

; TDT_NEST_CRAWLER, stage 5: comes out of a nest (TDMT_NEST, parent in +$3A)
; when it opens, walks towards the nearest player and fires orbs.
; HP 2/16/32 (td_nest_crawler_hp).
update_td_nest_crawler:
	lda	$06,x
	bpl	@alive
	brl	td_nest_crawler_explode
@alive:
	ldy	$3A,x
	lda	a:$0012,y
	cmp	#$0005
	bne	@run_state
	brl	td_nest_crawler_explode
@run_state:
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
	beq	@nest_open
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	rtl
@nest_open:
	lda	#$0002
	sta	$24,x
	lda	#$0002
	sta	$12,x

td_nest_crawler_state_2:
	dec	$24,x
	bmi	td_nest_crawler_start_walk
	jsl	f:td_angle_to_nearest_player
	sta	$04,x
	rtl
td_nest_crawler_start_walk:
	lda	#$2000
	sta	$02,x
	ldy	difficulty
	lda	a:td_nest_crawler_walk_times,y
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_nest_crawler_state_3:
	dec	$24,x
	bmi	@start_fire
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	jsl	f:td_walk_towards_nearest_player
	rtl
@start_fire:
	lda	#$0040
	sta	$24,x
	inc	$12,x

td_nest_crawler_state_4:
	dec	$24,x
	bmi	td_nest_crawler_start_walk
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$24,x
	cmp	#$0020
	bne	@no_fire
	jsl	f:td_fire_enemy_orb
@no_fire:
	lda	#$0002
	sta	$22,x
	jsl	f:td_enemy_tile_collision
	rtl
td_nest_crawler_explode:
	lda	#SOUND_ENEMY_DIE
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	clear_topdown_slot
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	@on_screen
	jsl	f:td_walk_towards_nearest_player
	rtl
@on_screen:
	lda	#$A000	; [num]
	sta	$16,x
	inc	$12,x

td_crawler_state_3:
	lda	$06,x
	bmi	td_crawler_explode
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	jsl	f:td_walk_towards_nearest_player
	rtl
td_crawler_explode:
	stz	$06,x
	lda	#SOUND_ENEMY_DIE
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
	bne	@initialized
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
@initialized:
	dec	$24,x
	bpl	@check_on_screen
	brl	clear_topdown_slot
@check_on_screen:
	lda	$2E,x
	bit	#$0003
	bne	td_spitter_start_chase
	jsl	f:td_walk_towards_nearest_player
	rtl
td_spitter_start_chase:
	lda	#$A000	; [num]
	sta	$16,x
	lda	#$0040
	sta	$24,x
	lda	#$0003
	sta	$12,x

td_spitter_state_3:
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$06,x
	bpl	@alive
	brl	td_crawler_explode
@alive:
	dec	$24,x
	bpl	@walk
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	beq	@facing
@walk:
	jsl	f:td_walk_towards_nearest_player
	rtl
@facing:
	ldy	difficulty
	lda	a:td_spitter_fire_delays,y
	sta	$24,x
	inc	$12,x

td_spitter_state_4:
	lda	$2E,x
	bit	#$000C
	bne	@in_range
	brl	clear_topdown_slot
@in_range:
	lda	$06,x
	bpl	@alive
	brl	td_crawler_explode
@alive:
	dec	$24,x
	bpl	@check_fire
	inc	$24,x
	jsl	f:td_angle_to_nearest_player
	cmp	$04,x
	bne	td_spitter_start_chase
	ldy	difficulty
	lda	a:td_spitter_fire_delays,y
	sta	$24,x
@check_fire:
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
	lda	a:td_item_spread_anims,y
	sta	$20,x
	lda	#$0001
	sta	$14,x
td_item_init_common:
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
	lda	a:td_item_crush_anims,y
	sta	$20,x
	lda	#$0002
	sta	$14,x
	jmp	a:td_item_init_common

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
	lda	a:td_item_homing_anims,y
	sta	$20,x
	lda	#$0003
	sta	$14,x
	jmp	a:td_item_init_common

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
	lda	a:td_item_flame_anims,y
	sta	$20,x
	lda	#$0004
	sta	$14,x
	jmp	a:td_item_init_common

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
	lda	a:td_item_laser_anims,y
	sta	$20,x
	lda	#$0005
	sta	$14,x
	jmp	a:td_item_init_common

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
	lda	a:td_item_barrier_anims,y
	sta	$20,x
	lda	#$0006
	sta	$14,x
	jmp	a:td_item_init_common

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
	lda	a:td_item_bomb_anims,y
	sta	$20,x
	lda	#$0007
	sta	$14,x
	jmp	a:td_item_init_common

animate_td_item:
	ldy	$20,x
	beq	@return
	dec	$22,x
	bmi	@restart_frame
	bne	@return
	tya
	clc
	adc	#$0006
@loop:
	tay
	lda	a:$0000,y
	bmi	@loop
	beq	@end_script
	sty	$20,x
@set_frame:
	sta	$22,x
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
@return:
	rtl
@restart_frame:
	lda	a:$0000,y
	bne	@set_frame
@end_script:
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
	bcs	@return
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
	beq	@return_clc
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
@return_clc:
	clc
@return:
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
	beq	@dying
	jsr	a:stage2_boss_next_frame
@dying:
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
	bpl	@alive
	brl	stage2_boss_start_death
@alive:
	lda	$12,x
	cmp	#$0004
	bcc	@run_state
	cmp	#$0007
	bcs	@run_state
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_TYPE
	bne	@has_cannon
	; (not executed in the CDL traces)
	brl	stage2_boss_choose_attack
@has_cannon:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_STATE
	cmp	#$0004
	bne	@run_state
	brl	stage2_boss_choose_attack
@run_state:
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
	bmi	@fall
	rtl
@fall:
	lda	#SOUND_STAGE2_BOSS_DROP
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
	beq	@landed
	rtl
@landed:
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
	bmi	stage2_boss_start_turn
	rtl
stage2_boss_start_turn:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	lda	#$0004
	sta	$12,x

stage2_boss_state_04:
	jsr	a:stage2_boss_turn_to_player
	bcs	@facing
	rtl
@facing:
	lda	#$0018
	jsl	f:set_velocity_from_angle
	lda	#$0060
	sta	$24,x
	inc	$12,x

stage2_boss_state_05:
	dec	$24,x
	bmi	@stop
	jsr	a:stage2_boss_check_facing_player
	jsr	a:stage2_boss_move
	rtl
@stop:
	lda	a:boss_target_distance
	cmp	#$3C80
	bcc	@near
	; (not executed in the CDL traces)
	brl	stage2_boss_start_turn
@near:
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
	bne	@turn_negative
	stz	$26,x
	bra	stage2_boss_state_06
@turn_negative:
	lda	#$0002
	sta	$26,x

stage2_boss_state_06:
	lda	#$0002
	jsr	a:td_play_turn_sound
	ldy	$26,x
	lda	$04,x
	clc
	adc	a:stage2_boss_turn_steps,y
	and	#$00FF
	sta	$04,x
	cmp	$24,x
	bne	@turning
	brl	stage2_boss_start_turn
@turning:
	jsr	a:stage2_boss_wake_pods
	rtl
stage2_boss_choose_attack:
	lda	#$0007
	sta	$12,x

stage2_boss_state_07:
	ldy	difficulty
	lda	a:stage2_boss_core_hp,y
	lsr	a
	cmp	a:td_boss_core_hp
	bcs	@jump
	lda	a:boss_target_distance
	cmp	#$7F00
	bcs	@jump
	brl	stage2_boss_start_spin_attack
@jump:
	lda	#$0020
	sta	$24,x
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

stage2_boss_state_08:
	dec	$24,x
	bmi	@take_off
	lda	a:td_boss_angle
	inc	a
	inc	a
	and	#$00FF
	sta	a:td_boss_angle
	rtl
@take_off:
	lda	#SOUND_STAGE2_BOSS_TAKE_OFF
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
	beq	@out_of_sight
	rtl
@out_of_sight:
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
	bmi	@drop_on_player
	rtl
@drop_on_player:
	lda	#SOUND_STAGE2_BOSS_DROP
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
	lda	a:stage2_boss_fall_spin_speeds,y
	sta	a:td_map_objects+$3C
	lda	a:stage2_boss_fall_scale_speeds,y
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
	bcs	@landed
	rtl
@landed:
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
	brl	stage2_boss_start_rest
@return:
	rtl
stage2_boss_start_spin_attack:
	lda	#$0080
	sta	$24,x
	stz	$26,x
	jsr	a:stage2_boss_aim_jump
	lda	#$000D
	sta	$12,x

stage2_boss_state_0D:
	dec	$24,x
	bmi	stage2_boss_start_spin_move
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
stage2_boss_start_spin_move:
	lda	#$0040
	sta	$24,x
	inc	$12,x

stage2_boss_state_0E:
	dec	$24,x
	bmi	@stop
	jsr	a:stage2_boss_move
	jsl	f:stage2_boss_spin
	rtl
@stop:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	inc	$12,x

stage2_boss_state_0F:
	lda	$2C,x
	sec
	sbc	#$0010
	bpl	@set_spin
	; (not executed in the CDL traces)
	lda	#$0000
@set_spin:
	sta	$2C,x
	beq	stage2_boss_start_rest
	jmp	a:stage2_boss_spin
stage2_boss_start_rest:
	stz	$1A,x
	stz	$18,x
	stz	$1E,x
	stz	$1C,x
	ldy	difficulty
	lda	a:stage2_boss_state_10_delays,y
	sta	$24,x
	lda	#$0010
	sta	$12,x

stage2_boss_state_10:
	dec	$24,x
	bpl	@wait
	brl	stage2_boss_choose_attack
@wait:
	jsr	a:stage2_boss_wake_pods
	rtl
stage2_boss_start_death:
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
	beq	@finished
	cmp	#$000C
	bcc	@count_down
	and	#$0003
	bne	@count_down
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
@count_down:
	dec	$24,x
	rtl
@finished:
	lda	#$8000	; [num]
	sta	$0A,x
	sta	$0E,x
	inc	$12,x

stage2_boss_state_12:
	rtl

stage2_boss_slow_down:
	lda	$2C,x
	beq	@not_spinning
	; (not executed in the CDL traces)
	sec
	sbc	#$0020
	bcs	@set_spin
	lda	#$0000
@set_spin:
	sta	$2C,x
@not_spinning:
	jsr	a:stage2_boss_slow_down_y
	lda	$1A,x
	ora	$18,x
	beq	@return
	; (not executed in the CDL traces)
	lda	$1A,x
	bmi	@moving_negative
	sec
	lda	$18,x
	sbc	#$4000
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	bcs	@return
@stop:
	stz	$1A,x
	stz	$18,x
	rts
@moving_negative:
	clc
	lda	$18,x
	adc	#$4000
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	bcs	@stop
@return:
	rts

stage2_boss_slow_down_y:
	lda	$1E,x
	ora	$1C,x
	beq	@return
	; (not executed in the CDL traces)
	lda	$1E,x
	bmi	@moving_negative
	sec
	lda	$1C,x
	sbc	#$4000
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bcs	@return
@stop:
	stz	$1E,x
	stz	$1C,x
	rts
@moving_negative:
	clc
	lda	$1C,x
	adc	#$4000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	bcs	@stop
@return:
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
	beq	@player2
	lda	a:td_p1_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$2000
	sta	a:td_p1_obj+OBJ_ATTR
@player2:
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
	beq	@player2
	lda	a:td_p1_obj+OBJ_ATTR
	and	#$CFFF
	ora	#$1000
	sta	a:td_p1_obj+OBJ_ATTR
@player2:
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
	bne	@return
	lda	a:boss_anim_frame
	inc	a
	cmp	#$0003
	bcc	@set_frame
	lda	#$0000
@set_frame:
	sta	a:boss_anim_frame
@return:
	rts

td_select_target_player_long:
	jsr	a:td_select_target_player
	rtl

; Picks the player the boss goes for: the nearest living one; boss_target_player =
; its slot offset (0 or $40), boss_target_distance = half its squared distance.
td_select_target_player:
	lda	a:p1_lives
	ora	a:p2_lives
	bne	@alive
	; (not executed in the CDL traces)
	rts
@alive:
	lda	#$FFFF	; [num]
	sta	zp_0C
	sta	zp_0E
	lda	a:p1_lives
	beq	@check_player2
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
@check_player2:
	lda	a:p2_lives
	beq	@compare
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
@compare:
	lda	zp_0C
	cmp	zp_0E
	beq	@tie
	bcs	@player2
@player1:
	stz	a:boss_target_player
	lda	zp_0C
	sta	a:boss_target_distance
	rts
@tie:
	; (not executed in the CDL traces)
	lda	stage_frame_counter
	xba
	lsr	a
	bcc	@player1
@player2:
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
	beq	@facing
	bit	#$0080
	bne	@decrease_angle
	lda	$04,x
	inc	a
	bra	@set_angle
@decrease_angle:
	lda	$04,x
	dec	a
@set_angle:
	and	#$00FF
	sta	$04,x
	lda	#$0001
	jsr	a:td_play_turn_sound
	clc
	rts
@facing:
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
	bne	@return_sec
	clc
	rts
@return_sec:
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
	lda	a:stage2_boss_jump_speeds,y
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
	bpl	@abs_dy
	eor	#$FFFF
	inc	a
@abs_dy:
	inc	a
	cmp	#$0100
	bcc	@dy_in_range
@return:
	rtl
@dy_in_range:
	sta	zp_DE
	lda	a:td_boss_x
	sec
	sbc	zp_18
	sta	zp_D4
	bpl	@abs_dx
	eor	#$FFFF
	inc	a
@abs_dx:
	inc	a
	cmp	#$0100
	bcs	@return
	sta	a:WRMPYA
	ldy	zp_16
	tya
	sta	zp_D8
	asl	a
	eor	zp_16
	sta	zp_DA
	sep	#$10
	.i8
	ldx	a:td_boss_cosine,y
	stx	a:WRMPYB
	stx	zp_E2
	lda	zp_D4
	eor	zp_D9
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	@positive
	eor	#$FFFF
	inc	a
@positive:
	sta	zp_00
	ldx	a:td_boss_sine,y
	stx	a:WRMPYB
	lda	zp_D4
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	@positive2
	eor	#$FFFF
	inc	a
@positive2:
	sta	zp_02
	ldy	zp_DE
	sty	a:WRMPYA
	stx	a:WRMPYB
	lda	zp_D6
	eor	zp_D7
	asl	a
	lda	a:RDMPYH
	and	#$00FF
	bcc	@positive3
	eor	#$FFFF
@positive3:
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
	bcc	@positive4
	eor	#$FFFF
@positive4:
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
	bmi	stage2_boss_core_start_death
	lda	a:td_boss_state
	cmp	#$0003
	beq	stage2_boss_core_landed
	cmp	#$0009
	beq	stage2_boss_core_airborne
	cmp	#$000C
	beq	stage2_boss_core_landed
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
stage2_boss_core_airborne:
	lda	#$0001
	sta	$12,x

stage2_boss_core_state_1:
	stz	$16,x
	bra	stage2_boss_core_wait
stage2_boss_core_landed:
	lda	#$0002
	sta	$12,x

stage2_boss_core_state_2:
	lda	#$A000	; [num]
	sta	$16,x
stage2_boss_core_wait:
	lda	#$0003
	sta	$12,x

stage2_boss_core_state_3:
	rtl
stage2_boss_core_start_death:
	stz	$06,x
	stz	$16,x
	lda	#$0040
	sta	$24,x
	lda	#SOUND_BIG_EXPLOSION
	jsl	f:queue_sound
	lda	#$0004
	sta	$12,x

stage2_boss_core_state_4:
	dec	$24,x
	bmi	@finished
	lda	$24,x
	bit	#$0003
	bne	@return
	jsl	f:td_spawn_explosion_effect
@return:
	rtl
@finished:
	lda	#$0013
	sta	$20,x
	cmp	$28,x
	bne	@return2
	brl	clear_topdown_slot
@return2:
	rtl

stage2_boss_core_position:
	lda	a:td_map_objects+$3E
	clc
	adc	#$0040
	and	#$007E
	tay
	lda	a:stage2_boss_core_offsets_x,y
	clc
	adc	a:td_boss_x
	sta	$0A,x
	lda	a:stage2_boss_core_offsets_y,y
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
	bne	@end_flash
	lda	$2E,x
	bit	#$0040
	beq	@return
	lda	$20,x
	sta	$2A,x
	ldy	$14,x
	lda	a:stage2_boss_pod_hit_blocks,y
	sta	$20,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	lda	#SOUND_CLANG
	jsl	f:queue_sound
	rtl
@end_flash:
	sta	$20,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
@return:
	rtl

stage2_boss_pod_run_state:
	lda	$06,x
	bpl	@alive
	brl	stage2_boss_pod_start_death
@alive:
	lda	a:td_boss_state
	cmp	#$0011
	bcc	@boss_alive
	; (not executed in the CDL traces)
	brl	stage2_boss_pod_start_death
@boss_alive:
	cmp	#$0003
	beq	stage2_boss_pod_close
	cmp	#$0009
	beq	stage2_boss_pod_airborne
	cmp	#$000C
	beq	stage2_boss_pod_close
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
stage2_boss_pod_airborne:
	lda	#$0001
	sta	$12,x

stage2_boss_pod_state_1:
	stz	$16,x
	rtl
stage2_boss_pod_close:
	lda	#$0002
	sta	$12,x

stage2_boss_pod_state_2:
	ldy	$14,x
	lda	a:stage2_boss_pod_closed_blocks,y
	sta	$20,x
	lda	#$B000	; [num]
	sta	$16,x
	rtl

stage2_boss_pod_state_3:
	ldy	$14,x
	lda	a:stage2_boss_pod_half_open_blocks,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0004
	sta	$12,x

stage2_boss_pod_state_4:
	dec	$24,x
	bne	stage2_boss_pod_return
	ldy	$14,x
	lda	a:stage2_boss_pod_open_blocks,y
	sta	$20,x
	lda	#$0020
	sta	$24,x
	inc	$12,x

stage2_boss_pod_state_5:
	dec	$24,x
	bmi	@half_close
	lda	$24,x
	and	#$000F
	bne	@return
	jsr	a:stage2_boss_pod_fire
@return:
	rtl
@half_close:
	ldy	$14,x
	lda	a:stage2_boss_pod_half_open_blocks,y
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

stage2_boss_pod_state_6:
	dec	$24,x
	beq	stage2_boss_pod_close
stage2_boss_pod_return:
	rtl
stage2_boss_pod_start_death:
	lda	#$0007
	cmp	$12,x
	beq	stage2_boss_pod_state_7
	sta	$12,x
	stz	$16,x
	lda	#SOUND_BIG_EXPLOSION
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x

stage2_boss_pod_state_7:
	dec	$24,x
	bmi	@finished
	lda	$24,x
	bit	#$0003
	bne	@return
	jsl	f:td_spawn_explosion_effect
@return:
	rtl
@finished:
	ldy	$14,x
	lda	a:stage2_boss_pod_destroyed_blocks,y
	sta	$20,x
	cmp	$28,x
	bne	@return
	lda	a:td_boss_state
	cmp	#$0011
	beq	@return
	jsr	a:stage2_boss_pod_drop_item
	bcs	@return2
	brl	clear_topdown_slot
@return2:
	rtl

stage2_boss_pod_drop_item:
	jsl	f:td_find_free_item_slot
	bcs	@return
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
	beq	@return_clc
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
@return_clc:
	clc
@return:
	rts

stage2_boss_pod_position:
	ldy	$14,x
	lda	a:td_map_objects+$3E
	clc
	adc	a:stage2_boss_pod_arm_angles,y
	and	#$007E
	tay
	lda	a:stage2_boss_pod_offsets_x,y
	clc
	adc	a:td_boss_x
	sta	$0A,x
	lda	a:stage2_boss_pod_offsets_y,y
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
	bpl	@alive
	brl	stage2_boss_cannon_start_death
@alive:
	lda	a:td_boss_state
	cmp	#$0011
	bcc	@boss_alive
	; (not executed in the CDL traces)
	brl	stage2_boss_cannon_start_death
@boss_alive:
	cmp	#$0002
	beq	stage2_boss_cannon_stow
	cmp	#$0003
	beq	stage2_boss_cannon_follow
	cmp	#$0004
	beq	stage2_boss_cannon_follow
	cmp	#$0006
	beq	stage2_boss_cannon_attack
	cmp	#$0009
	beq	stage2_boss_cannon_stow
	cmp	#$000C
	beq	stage2_boss_cannon_follow
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
stage2_boss_cannon_follow:
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
stage2_boss_cannon_stow:
	lda	#$0002
	cmp	$12,x
	beq	stage2_boss_cannon_state_2
	sta	$12,x
	jsr	a:stage2_boss_cannon_close

stage2_boss_cannon_state_2:
	lda	a:td_boss_angle
	sta	$04,x
	rtl
stage2_boss_cannon_attack:
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
	adc	a:stage2_boss_cannon_turn_steps,y
	and	#$00FF
	sta	$04,x
	jsr	a:stage2_boss_cannon_fire
	rtl
stage2_boss_cannon_start_death:
	lda	#$0004
	cmp	$12,x
	beq	stage2_boss_cannon_state_4
	sta	$12,x
	stz	$16,x
	lda	#SOUND_BIG_EXPLOSION
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x
	lda	#$0004
	sta	$12,x

stage2_boss_cannon_state_4:
	dec	$24,x
	bmi	@finished
	lda	$24,x
	bit	#$0003
	bne	@return
	jsl	f:td_spawn_explosion_effect
@return:
	rtl
@finished:
	lda	#$141C
	sta	$26,x
	stz	$00,x
	lda	#$0012
	sta	$20,x
	cmp	$28,x
	bne	@return2
	brl	clear_topdown_slot
@return2:
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
	beq	@facing
	bit	#$0080
	bne	@decrease_angle
	lda	$04,x
	inc	a
	bra	@set_angle
@decrease_angle:
	lda	$04,x
	dec	a
@set_angle:
	and	#$00FF
	sta	$04,x
	clc
	rts
@facing:
	sec
	rts

stage2_boss_cannon_fire:
	ldy	difficulty
	cpy	#$0004
	bcs	@flame
	lda	stage_frame_counter
	and	a:stage2_boss_cannon_fire_masks,y
	bne	@return
	ldy	#$001C
	jsl	f:td_fire_enemy_bullet
@return:
	rts
@flame:
	; (not executed in the CDL traces)
	jsl	f:td_find_free_enemy_shot_slot
	bcs	@return2
	lda	stage_frame_counter
	and	#$000F
	bne	@no_sound
	lda	#$0014
	jsl	f:queue_sound
@no_sound:
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
	lda	a:td_circle_r32_y,x
	sta	zp_08
	lda	a:td_circle_r32_x,x
	plx
	clc
	adc	$0A,x
	sta	a:$000A,y
	lda	zp_08
	clc
	adc	$0E,x
	sta	a:$000E,y
@return2:
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
	lda	a:stage2_boss_chr_sources,y
	sta	a:boss_chr_stream_src
	rtl

td_play_turn_sound:
	cmp	#$0000
	beq	@return
	bpl	@positive
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
@positive:
	pha
	cmp	#$0008
	bcc	@clamped
	lda	#$0008
@clamped:
	asl	a
	tay
	pla
	clc
	adc	a:turn_sound_counter
	sta	a:turn_sound_counter
	cmp	a:td_turn_sound_thresholds,y
	bcc	@return
	stz	a:turn_sound_counter
	lda	a:td_turn_sounds,y
	jsl	f:queue_sound
@return:
	rts

td_play_rumble_sound:
	lda	#SOUND_BOSS_EXPLOSIONS
	ldy	a:rumble_sound_timer
	bpl	@count_down
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:rumble_sound_timer
	pla
	jsl	f:queue_sound
@count_down:
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
	beq	@enemy_shots
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
@enemy_shots:
	ldx	#$0300
@loop3:
	lda	$10,x
	beq	@next3
	jsl	f:run_topdown_shot_handler
@next3:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0480
	bcc	@loop3
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
	bne	@running
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
	bra	@set_palette
@running:
	dec	$12,x
	beq	td_end_shot
	jsl	f:td_check_enemy_shot_tile
	bcs	td_end_shot
	jsl	f:move_td_shot
@set_palette:
	lda	$12,x
	and	#$0006
	tay
	lda	$02,x
	and	#$3000
	ora	a:td_enemy_bullet_palettes,y
	sta	$02,x
	rtl

update_td_shot_impact:
	dec	$12,x
	bne	td_shot_type_none
td_free_shot:
	stz	$10,x
	stz	$00,x

td_shot_type_none:
	rtl

; Shot X hit something: becomes TDS_IMPACT (a spark), except the flame and
; the crush blasts; a crush missile explodes.
td_end_shot:
	lda	$10,x
	cmp	#TDS_FLAME
	beq	@return
	cmp	#TDS_CRUSH
	bne	@not_crush
	brl	td_crush_missile_explode
@not_crush:
	cmp	#TDS_CRUSH_BLAST
	beq	@return
	cmp	#TDS_CRUSH_BLAST_PART
	beq	@return
	cmp	#TDS_BOSS_SPIT
	beq	@return
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
@return:
	rtl

td_shot_hidden:
	stz	$00,x
	lda	#$FFFF	; [num]
	sta	$04,x
	rtl

; TDS_DEFAULT (and type 1): 16 frames at speed $80, damage 2.
update_td_default_shot:
	lda	$12,x
	bne	@running
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
@running:
	dec	$12,x
	bne	@check_tile
	brl	td_end_shot
@check_tile:
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
	bne	@running
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
@running:
	cmp	#$0008
	bne	@count_down
	lda	#$0102
	sta	$00,x
	lda	#$0008
	sta	$16,x
@count_down:
	dec	$12,x
	bne	@check_tile
	brl	td_end_shot
@check_tile:
	jsl	f:td_check_shot_tile
	bcc	@move
	brl	td_end_shot
@move:
	jmp	a:move_td_shot

; TDS_HOMING: picks a visible hittable target (+$16 bit 13, cycling with
; homing_target_cursor) and turns towards it 8 units a frame; $40 frames, damage 2.
update_td_homing_shot:
	lda	$12,x
	beq	@start
	brl	@running
@start:
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
	bne	@boss_view
	ldy	a:homing_target_cursor
	bne	@search
	ldy	#$0AC0
	sty	a:homing_target_cursor
@search:
	lda	a:$0016,y
	bit	#$2000
	beq	@next
	lda	a:$002E,y
	bit	#$0003
	beq	@next
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	@set_cursor
	lda	#$0AC0
@set_cursor:
	sta	a:homing_target_cursor
	rtl
@next:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	@check_end
	lda	#$0AC0
@check_end:
	tay
	cpy	a:homing_target_cursor
	bne	@search
	stz	$14,x
	rtl
@boss_view:
	; (not executed in the CDL traces)
	ldy	a:homing_target_cursor
	bne	@search2
	ldy	#$0AC0
	sty	a:homing_target_cursor
@search2:
	lda	a:$0016,y
	bit	#$2000
	beq	@next2
	lda	a:$002E,y
	bit	#$0003
	beq	@next2
	sty	$14,x
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	@set_cursor2
	lda	#$0AC0
@set_cursor2:
	sta	a:homing_target_cursor
	rtl
@next2:
	tya
	clc
	adc	#$0040
	cmp	#$0EC0
	bcc	@check_end2
	lda	#$0AC0
@check_end2:
	tay
	cpy	a:homing_target_cursor
	bne	@search2
	stz	$14,x
	rtl
@running:
	dec	$12,x
	bne	@check_tile
	brl	td_end_shot
@check_tile:
	jsl	f:td_check_shot_tile
	bcc	@steer
	brl	td_end_shot
@steer:
	lda	$12,x
	cmp	#$000A
	bcc	@move
	jsl	f:td_homing_shot_turn
	jsl	f:td_homing_shot_set_velocity
@move:
	jmp	a:move_td_shot

td_homing_shot_turn:
	ldy	$14,x
	beq	@return
	lda	a:$0010,y
	beq	@return
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
	beq	@return
	bit	#$0080
	bne	@decrease_angle
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	rtl
@decrease_angle:
	lda	$04,x
	sec
	sbc	#$0008
	and	#$00FF
	sta	$04,x
@return:
	rtl

td_homing_shot_set_velocity:
	lda	#$0080
	jsl	f:set_velocity_from_angle
	rtl

; TDS_LASER: a segment kept at a distance ahead of the player; 7 frames,
; damage 4.
update_td_laser_shot:
	lda	$12,x
	bne	@running
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
@running:
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
	lda	a:td_laser_segment_distances,y
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
	bne	@check_tile
	brl	td_end_shot
@check_tile:
	jsl	f:td_check_shot_tile
	bcc	td_flicker_shot
	brl	td_end_shot

td_flicker_shot:
	ldy	#$0000
	lda	stage_frame_counter
	bit	#$0002
	bne	@set_palette
	ldy	#$0002
@set_palette:
	lda	$02,x
	and	#$3000
	ora	a:td_flicker_palettes,y
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
	bne	@running
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
@running:
	dec	$12,x
	bne	@update
	brl	td_free_shot
@update:
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
	lda	a:td_flame_segment_distances,y
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
	bcs	@set_sprite
	ldy	#$0010
	cmp	#$0006
	bcs	@set_sprite
	ldy	#$0020
@set_sprite:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:td_shot_anim_sprites,y
	sta	$00,x
	rts

; TDS_CRUSH: 16 frames, damage 2; on a hit becomes TDS_CRUSH_BLAST.
update_td_crush_missile:
	lda	$12,x
	bne	@running
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
@running:
	dec	$12,x
	bne	@check_tile
	brl	td_crush_blast_end
@check_tile:
	jsl	f:td_check_shot_tile
	bcs	td_crush_missile_explode
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
td_crush_missile_explode:
	stz	$12,x
	lda	#TDS_CRUSH_BLAST
	sta	$10,x
	rtl

; TDS_CRUSH_BLAST: $40 frames of explosions around the hit point, damage 1;
; starts its two TDS_CRUSH_BLAST_PART slots.
update_td_crush_blast:
	lda	$12,x
	bne	td_crush_blast_next_frame
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
td_crush_blast_scatter:
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
td_crush_blast_next_frame:
	dec	$12,x
	bne	td_crush_blast_tick
td_crush_blast_end:
	lda	#$0000
	ldy	$1A,x
	sta	a:$0010,y
	sta	a:$0012,y
	ldy	$1E,x
	sta	a:$0010,y
	sta	a:$0012,y
	jmp	a:td_free_shot
td_crush_blast_tick:
	jsl	f:td_check_shot_tile
	jsl	f:td_crush_blast_frame
	lda	$12,x
	and	#$0007
	beq	td_crush_blast_scatter
	ldy	$1A,x
	cmp	#$0002
	beq	@start_part
	ldy	$1E,x
	cmp	#$0005
	beq	@start_part
	rtl
@start_part:
	lda	#$0000
	sta	a:$0012,y
	lda	#TDS_CRUSH_BLAST_PART
	sta	a:$0010,y
	stx	$1A,y
	rtl

update_td_crush_blast_part:
	lda	$12,x
	bne	@running
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
@running:
	dec	$12,x
	bne	@check_tile
	; (not executed in the CDL traces)
	lda	#TDS_HIDDEN
	sta	$10,x
	rtl
@check_tile:
	jsl	f:td_check_shot_tile

td_crush_blast_frame:
	lda	#$0008
	sec
	sbc	$12,x
	asl	a
	and	#$000E
	tay
	lda	a:td_crush_blast_sprites,y
	sta	$00,x
	lda	$02,x
	and	#$3000
	ora	a:td_crush_blast_palettes,y
	sta	$02,x
	lda	a:td_crush_blast_flags,y
	sta	$16,x
	rtl

; TDS_CANNON_FLAME: the stage 2 boss cannon's flame on HARD (not executed in
; the CDL traces).
update_td_cannon_flame:
	; (not executed in the CDL traces)
	lda	$12,x
	bne	@running
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
@running:
	lda	#$0007
	sec
	sbc	$12,x
	asl	a
	tay
	lda	a:td_laser_segment_distances,y
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
	bne	@check_tile
	brl	td_end_shot
@check_tile:
	jsl	f:td_check_shot_tile
	bcc	@flicker
	brl	td_end_shot
@flicker:
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
	bpl	@move
	brl	td_free_shot
@move:
	jsl	f:move_td_shot
	rtl

td_boss_spit_frame:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	lda	a:td_shot_anim_sprites_2,y
	sta	$00,x
	rts

; TDS_ENEMY_ORB: $40 frames straight ahead.
update_td_enemy_orb:
	lda	$12,x
	bne	@count_down
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
@count_down:
	dec	$12,x
	bne	@move
	brl	td_free_shot
@move:
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
	bne	@count_down
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
@count_down:
	dec	$12,x
	bne	@steer
	brl	td_free_shot
@steer:
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
	bne	@decrease_angle
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:td_homing_orb_turn_speeds,y
	and	#$00FF
	sta	$04,x
	rts
@decrease_angle:
	ldy	difficulty
	lda	$04,x
	sec
	sbc	a:td_homing_orb_turn_speeds,y
	and	#$00FF
	sta	$04,x
	rts

td_enemy_orb_frame:
	lda	$12,x
	ldy	#$0000
	cmp	#$0038
	bcs	td_enemy_orb_frame_tail
	ldy	#$0010
	cmp	#$0030
	bcs	td_enemy_orb_frame_tail
	ldy	#$0020
	cmp	#$0008
	bcs	td_enemy_orb_frame_tail
	ldy	#$0030
td_enemy_orb_frame_tail:
	bra	td_set_shot_anim_sprite

td_homing_orb_frame:
	lda	$12,x
	ldy	#$0000
	cmp	#$0078
	bcs	td_set_shot_anim_sprite
	ldy	#$0010
	cmp	#$0070
	bcs	td_set_shot_anim_sprite
	ldy	#$0020
	cmp	#$0008
	bcs	td_enemy_orb_frame_tail
	ldy	#$0030
td_set_shot_anim_sprite:
	lda	stage_frame_counter
	asl	a
	and	#$000E
	sta	zp_00
	tya
	ora	zp_00
	tay
	lda	a:td_shot_anim_sprites,y
	sta	$00,x
	rts

; Player shot X against the tile attribute map: carry set when it hits a wall
; or a map object tile (TDA_MAP_OBJECT, which damages that object).
td_check_shot_tile:
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	bne	@check
	clc
	rtl
@check:
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
	beq	@empty
	bit	#TDA_SPECIAL
	bne	@special
	plx
	bit	#TDA_SET_PRIORITY
	beq	@check_wall
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	@set_priority
	ldy	#$0000
@set_priority:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:td_sprite_priorities,y
	sta	$02,x
	pla
@check_wall:
	and	#TDA_WALL_MASK
	beq	@return_clc
@return_sec:
	sec
	rts
@empty:
	plx
@return_clc:
	clc
	rts
@special:
	plx
	cmp	#TDA_MAP_OBJECT
	bne	@return_clc
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE5_BOSS
	bne	@hit_map_object
	ldy	#$0EC0
	cpx	#$0700
	bcc	@check_player
	; (not executed in the CDL traces)
	ldy	#$0F00
@check_player:
	lda	a:$0012,y
	cmp	#$0005
	beq	@return_sec
	bra	@return_clc
@hit_map_object:
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	@return_sec2
	bit	#$1000
	beq	@return_sec2
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@return_sec2
	jsl	f:td_score_shot_kill
@return_sec2:
	sec
	rts

; Enemy shot X against the tile attribute map: carry set on a wall.
td_check_enemy_shot_tile:
	lda	a:boss_centered_view
	beq	@check
	clc
	rtl
@check:
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
	beq	@not_solid
	bit	#TDA_SPECIAL
	beq	@normal_tile
@not_solid:
	plx
@return_clc:
	clc
	rts
@normal_tile:
	plx
	bit	#TDA_SET_PRIORITY
	beq	@check_wall
	ldy	#$0000
	bit	#TDA_PRIORITY_HIGH
	beq	@set_priority
	ldy	#$0002
@set_priority:
	pha
	lda	$02,x
	and	#$CFFF
	ora	a:td_sprite_priorities,y
	sta	$02,x
	pla
@check_wall:
	and	#TDA_WALL_MASK
	beq	@return_clc
	sec
	rts

; Enemy X against the tile attribute map: corners (td_read_enemy_corner_tiles),
; walls (td_push_out_of_walls), special tiles (td_enemy_tile_effect).
td_enemy_tile_collision:
	lda	a:boss_centered_view
	beq	@check
	; (not executed in the CDL traces)
	clc
	rtl
@check:
	jsr	a:td_read_enemy_corner_tiles
	jsr	a:td_push_out_of_walls
	jsr	a:td_enemy_tile_effect
	rtl

td_enemy_tile_effect:
	lda	$0E,x
	bpl	@y_in_map
@return_sec:
	sec
	rts
@y_in_map:
	lda	$0A,x
	bmi	@return_sec
	lda	zp_04
	beq	td_tile_no_effect
	bit	#TDA_SPECIAL
	beq	td_enemy_tile_priority
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
	bcc	@return
	lda	$04,x
	clc
	adc	#$0008
	and	#$00FF
	sta	$04,x
	tya
	bne	@return_clc
	lda	stage_frame_counter
	bit	#$0007
	bne	@return_clc
	dec	$06,x
@return_clc:
	clc
@return:
	rts
td_enemy_tile_priority:
	bit	#TDA_SET_PRIORITY
	beq	@return_sec
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	@set_priority
	ldy	#$0000
@set_priority:
	lda	$02,x
	and	#$CFFF
	ora	a:td_sprite_priorities,y
	sta	$02,x
@return_sec:
	sec
	rts

td_tile_no_effect:
	clc
	rts

; Reads the tile attributes ($7E:4000) of the 2x2 tiles around the object
; (X): its tile and the right, lower and lower-right neighbours, or the
; upper / left ones, by which quarter of the tile it is in. On tile row 127
; the lower neighbours are past the map: $7E:8000-$7E:8080, the first block
; definitions (both their bytes), read as attributes (emulator: changing
; those bytes changes how enemies at the map's bottom edge are pushed).
td_read_enemy_corner_tiles:
	lda	$02,x
	bit	#$2000
	bne	@read_corners
	brl	td_read_tiles_low_priority
@read_corners:
	lda	$0E,x
	bit	#$0004
	bne	@bottom_half
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	@right_half
	brl	@top_left
@right_half:
	beq	@bottom_half
	brl	@top_right
@bottom_half:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	@bottom_left
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
	beq	@no_top_left
	lda	#$0001
	tsb	zp_06
@no_top_left:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right
	lda	#$0002
	tsb	zp_06
@no_top_right:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left
	lda	#$0004
	tsb	zp_06
@no_bottom_left:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right
	lda	#$0008
	tsb	zp_06
@no_bottom_right:
	plx
	rts
@bottom_left:
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
	beq	@no_top_right2
	lda	#$0002
	tsb	zp_06
@no_top_right2:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	@no_top_left2
	lda	#$0001
	tsb	zp_06
@no_top_left2:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left2
	lda	#$0004
	tsb	zp_06
@no_bottom_left2:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right2
	lda	#$0008
	tsb	zp_06
@no_bottom_right2:
	plx
	rts
@top_right:
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
	beq	@no_bottom_left3
	lda	#$0004
	tsb	zp_06
@no_bottom_left3:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	@no_top_left3
	lda	#$0001
	tsb	zp_06
@no_top_left3:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right3
	lda	#$0002
	tsb	zp_06
@no_top_right3:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right3
	lda	#$0008
	tsb	zp_06
@no_bottom_right3:
	plx
	rts
@top_left:
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
	beq	@no_bottom_right4
	lda	#$0008
	tsb	zp_06
@no_bottom_right4:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_08
	beq	@no_top_left4
	lda	#$0001
	tsb	zp_06
@no_top_left4:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right4
	lda	#$0002
	tsb	zp_06
@no_top_right4:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_enemy_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left4
	lda	#$0004
	tsb	zp_06
@no_bottom_left4:
	plx
	rts

td_enemy_tile_wall_shape:
	bit	#TDA_SPECIAL
	bne	@special
	and	#TDA_WALL_MASK
	rts
@special:
	cmp	#TDA_HOLE
	beq	@solid
	cmp	#TDA_PUSH_RIGHT
	bcc	@solid
	lda	#$0000
	rts
@solid:
	lda	#$0001
	rts
td_read_tiles_low_priority:
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
	bne	@no_walls
	lda	$0E,x
	cmp	#$0100
	bcc	@no_walls
	cmp	#$0200
	bcs	@no_walls
	lda	$0A,x
	cmp	#$0100
	bcc	@no_walls
	cmp	#$0200
	bcs	@no_walls
	cmp	#$0154
	bcc	@walls_left
	cmp	#$01AC
	bcs	@walls_right
@no_walls:
	stz	zp_06
	rts
@walls_left:
	lda	#$0005
	sta	zp_06
	rts
@walls_right:
	lda	#$000A
	sta	zp_06
	rts

; Player X against the tile attribute map: corners, walls, then the special
; tile under it (td_player_tile_effect, tbl_td_player_special_tiles).
td_player_tile_collision:
	lda	a:boss_centered_view
	beq	@check
	clc
	rtl
@check:
	jsr	a:td_read_player_corner_tiles
	jsr	a:td_push_out_of_walls
	jsr	a:td_player_tile_effect
	rtl

td_player_tile_effect:
	lda	zp_04
	beq	@empty
	cmp	#TDA_SAND_PIT
	beq	@not_sand
	stz	a:$0672,x
@not_sand:
	bit	#TDA_SPECIAL
	bne	@special
	bit	#TDA_SET_PRIORITY
	beq	@return_clc
	ldy	#$0002
	bit	#TDA_PRIORITY_HIGH
	beq	@set_priority
	ldy	#$0000
@set_priority:
	lda	$02,x
	and	#$CFFF
	ora	a:td_sprite_priorities,y
	sta	$02,x
@return_clc:
	clc
	rts
@empty:
	stz	a:$0672,x
	clc
	rts
@special:
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
	bpl	@return_clc
	lda	a:$0090,x
	cmp	#$0002
	bne	@touch_object
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE5_BOSS
	beq	@return_clc
	jsr	a:td_bomb_hits_map_object_tile
	clc
	rts
@touch_object:
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	@return_clc
	lda	#$FFFF	; [num]
	sta	$06,x
@return_clc:
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
	bne	@own_view
	; (not executed in the CDL traces)
	jsr	a:td_whirl_around_cell
	bcc	@return
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:td_whirl_turn_speeds,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:td_whirl_turn_speeds,y
	and	#$00FF
	sta	a:$0658,x
	clc
@return:
	rts
@own_view:
	jsr	a:td_whirl_around_cell
	bcc	@return2
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:td_whirl_turn_speeds,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:td_whirl_turn_speeds,y
	and	#$00FF
	sta	a:$0654,x
	clc
@return2:
	rts

td_tile_sand_pit:
	lda	a:td_boss_state
	cmp	#$0008
	bcs	@no_pull
	ldy	difficulty
	lda	a:stage5_boss_hp,y
	lsr	a
	cmp	a:td_boss_hp
	bcs	@pull
@no_pull:
	stz	a:$0672,x
@return_clc:
	clc
	rts
@pull:
	lda	a:palette_cycle_paused
	bne	@return_clc
	lda	a:title_menu_cursor
	dec	a
	dec	a
	bne	@own_view
	; (not executed in the CDL traces)
	jsr	a:td_spiral_into_sand_pit
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:td_sand_pit_turn_speeds,y
	and	#$00FF
	sta	$04,x
	lda	a:$0658,x
	clc
	adc	a:td_sand_pit_turn_speeds,y
	and	#$00FF
	sta	a:$0658,x
	clc
	rts
@own_view:
	jsr	a:td_spiral_into_sand_pit
	ldy	difficulty
	lda	$04,x
	clc
	adc	a:td_sand_pit_turn_speeds,y
	and	#$00FF
	sta	$04,x
	lda	a:$0654,x
	clc
	adc	a:td_sand_pit_turn_speeds,y
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

; As td_read_enemy_corner_tiles, for a player (the same reads past the map
; on tile row 127).
td_read_player_corner_tiles:
	lda	$02,x
	bit	#$2000
	bne	@read_corners
	brl	td_read_tiles_low_priority
@read_corners:
	lda	$0E,x
	bit	#$0004
	bne	@bottom_half
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	bne	@right_half
	brl	@top_left
@right_half:
	beq	@bottom_half
	brl	@top_right
@bottom_half:
	asl	a
	asl	a
	asl	a
	asl	a
	and	#$3F80
	sta	zp_FA
	lda	$0A,x
	bit	#$0004
	beq	@bottom_left
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
	beq	@no_top_left
	lda	#$0001
	tsb	zp_06
@no_top_left:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right
	lda	#$0002
	tsb	zp_06
@no_top_right:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left
	lda	#$0004
	tsb	zp_06
@no_bottom_left:
	lda	f:$7E4081,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right
	lda	#$0008
	tsb	zp_06
@no_bottom_right:
	plx
	rts
@bottom_left:
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
	beq	@no_top_right2
	lda	#$0002
	tsb	zp_06
@no_top_right2:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	@no_top_left2
	lda	#$0001
	tsb	zp_06
@no_top_left2:
	lda	f:$7E407F,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left2
	lda	#$0004
	tsb	zp_06
@no_bottom_left2:
	lda	f:$7E4080,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right2
	lda	#$0008
	tsb	zp_06
@no_bottom_right2:
	plx
	rts
@top_right:
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
	beq	@no_bottom_left3
	lda	#$0004
	tsb	zp_06
@no_bottom_left3:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	@no_top_left3
	lda	#$0001
	tsb	zp_06
@no_top_left3:
	lda	f:$7E3F81,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right3
	lda	#$0002
	tsb	zp_06
@no_top_right3:
	lda	f:$7E4001,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0E
	beq	@no_bottom_right3
	lda	#$0008
	tsb	zp_06
@no_bottom_right3:
	plx
	rts
@top_left:
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
	beq	@no_bottom_right4
	lda	#$0008
	tsb	zp_06
@no_bottom_right4:
	lda	f:$7E3F7F,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_08
	beq	@no_top_left4
	lda	#$0001
	tsb	zp_06
@no_top_left4:
	lda	f:$7E3F80,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0A
	beq	@no_top_right4
	lda	#$0002
	tsb	zp_06
@no_top_right4:
	lda	f:$7E3FFF,x
	and	#$00FF
	jsr	a:td_player_tile_wall_shape
	sta	zp_0C
	beq	@no_bottom_left4
	lda	#$0004
	tsb	zp_06
@no_bottom_left4:
	plx
	rts

td_player_tile_wall_shape:
	bit	#TDA_SPECIAL
	bne	@special
	and	#TDA_WALL_MASK
	rts
@special:
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
	bcc	@check_top_left
	brl	td_wall_slope_down_left_multi
@check_top_left:
	lda	zp_08
	cmp	#$0005
	bcc	@check_top_right
	brl	td_wall_slope_up_left_multi
@check_top_right:
	lda	zp_0A
	cmp	#$0005
	bcc	@check_bottom_right
	brl	td_wall_slope_up_right_multi
@check_bottom_right:
	lda	zp_0E
	cmp	#$0005
	bcc	@return
	brl	td_wall_slope_down_right_multi
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
td_wall_snap_up:
	lda	$0E,x
	and	#$FFF8
	ora	#$0003
	sta	$0E,x
	stz	$0C,x
	rts

td_wall_push_top:
	plx
td_wall_snap_down:
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
	bcc	@snap
	brl	td_wall_slope_down_left_multi
@snap:
	jsr	a:td_wall_snap_left
	bra	td_wall_snap_down

td_wall_push_not_top_left:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	@snap
	brl	td_wall_slope_up_left_multi
@snap:
	jsr	a:td_wall_snap_left
	bra	td_wall_snap_up

td_wall_push_not_top_right:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	@snap
	brl	td_wall_slope_up_right_multi
@snap:
	jsr	a:td_wall_snap_right
	bra	td_wall_snap_up

td_wall_push_not_bottom_right:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	@snap
	brl	td_wall_slope_down_right_multi
@snap:
	jsr	a:td_wall_snap_right
	bra	td_wall_snap_down

td_wall_push_top_right:
	plx
	lda	zp_0A
	cmp	#$0004
	bcc	@slide
	brl	td_wall_slope_down_left
@slide:
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
	sbc	a:td_wall_push_dx,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:td_wall_push_dy,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF	; [num]
	sta	$0C,x
	rts

td_wall_push_bottom_right:
	plx
	lda	zp_0E
	cmp	#$0004
	bcc	@slide
	brl	td_wall_slope_up_left
@slide:
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
	sbc	a:td_wall_push_dx,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:td_wall_push_dy,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts

td_wall_push_bottom_left:
	plx
	lda	zp_0C
	cmp	#$0004
	bcc	@slide
	brl	td_wall_slope_up_right
@slide:
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
	adc	a:td_wall_push_dx,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:td_wall_push_dy,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	stz	$0C,x
	rts

td_wall_push_top_left:
	plx
	lda	zp_08
	cmp	#$0004
	bcc	@slide
	brl	td_wall_slope_down_right
@slide:
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
	adc	a:td_wall_push_dx,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:td_wall_push_dy,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	sta	$0C,x
	rts
td_wall_slope_down_left_multi:
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
	bra	td_wall_slope_down_left_tail
td_wall_slope_down_left:
	lda	$0E,x
	and	#$0007
	eor	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
td_wall_slope_down_left_tail:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:td_wall_push_diag,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:td_wall_push_diag,y
	sta	$0E,x
	stz	$08,x
	lda	#$FFFF	; [num]
	sta	$0C,x
	rts
td_wall_slope_up_left_multi:
	lda	$0E,x
	and	#$0003
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0003
	bra	td_wall_slope_up_left_tail
td_wall_slope_up_left:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
td_wall_slope_up_left_tail:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	sec
	sbc	a:td_wall_push_diag,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:td_wall_push_diag,y
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	rts
td_wall_slope_up_right_multi:
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
	bra	td_wall_slope_up_right_tail
td_wall_slope_up_right:
	lda	$0E,x
	and	#$0007
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	$0A,x
	and	#$0007
	eor	#$0007
td_wall_slope_up_right_tail:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:td_wall_push_diag,y
	sta	$0A,x
	lda	$0E,x
	sec
	sbc	a:td_wall_push_diag,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	stz	$0C,x
	rts
td_wall_slope_down_right_multi:
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
	bra	td_wall_slope_down_right_tail
td_wall_slope_down_right:
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
td_wall_slope_down_right_tail:
	ora	zp_FA
	asl	a
	tay
	lda	$0A,x
	clc
	adc	a:td_wall_push_diag,y
	sta	$0A,x
	lda	$0E,x
	clc
	adc	a:td_wall_push_diag,y
	sta	$0E,x
	lda	#$FFFF	; [num]
	sta	$08,x
	sta	$0C,x
	rts

td_check_lower_level_x:
	lda	$02,x
	bit	#$2000
	beq	@low_priority
	rts
@low_priority:
	ldy	$0A,x
	cpy	#$0150
	bcc	@return_sec
	cpy	#$01B0
	rts
@return_sec:
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
	lda	a:td_trap_timer_slots,y
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
	bcc	@set_timer
	ldy	#$0002
@set_timer:
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
	bne	@pressed
	rts
@pressed:
	lda	$0E,x
	cmp	#$0100
	bcs	@not_switch0
	brl	@switch0
@not_switch0:
	cmp	#$0300
	bcs	@switch2
	brl	@switch1
@switch2:
	lda	a:td_switch_events+2*SWEV_SIZE+SWEV_ACTIVE
	beq	@start_switch2
	rts
@start_switch2:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:td_switch_events+2*SWEV_SIZE+SWEV_ACTIVE
	lda	#$0008
	sta	a:td_switch_events+2*SWEV_SIZE+SWEV_STEPS
	stz	a:td_switch_events+2*SWEV_SIZE+SWEV_TIMER
	ldy	#$0000
	lda	$0A,x
	cmp	#$0220
	bcc	@switch2_dir
	ldy	#$0002
@switch2_dir:
	sty	a:td_switch_events+2*SWEV_SIZE+SWEV_DIR
	lda	a:td_switch2_vram_addrs,y
	sta	a:td_switch_events+2*SWEV_SIZE+SWEV_VRAM
	lda	a:td_switch2_x,y
	sta	a:td_switch_events+2*SWEV_SIZE+SWEV_X
	lda	#$0390
	sta	a:td_switch_events+2*SWEV_SIZE+SWEV_Y
	rts
@switch1:
	lda	a:td_switch_events+1*SWEV_SIZE+SWEV_ACTIVE
	beq	@start_switch1
	rts
@start_switch1:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:td_switch_events+1*SWEV_SIZE+SWEV_ACTIVE
	lda	#$0008
	sta	a:td_switch_events+1*SWEV_SIZE+SWEV_STEPS
	stz	a:td_switch_events+1*SWEV_SIZE+SWEV_TIMER
	ldy	#$0000
	lda	$0A,x
	cmp	#$0140
	bcc	@switch1_dir
	ldy	#$0002
@switch1_dir:
	sty	a:td_switch_events+1*SWEV_SIZE+SWEV_DIR
	lda	a:td_switch1_vram_addrs,y
	sta	a:td_switch_events+1*SWEV_SIZE+SWEV_VRAM
	lda	a:td_switch1_x,y
	sta	a:td_switch_events+1*SWEV_SIZE+SWEV_X
	lda	#$0230
	sta	a:td_switch_events+1*SWEV_SIZE+SWEV_Y
	rts
@switch0:
	lda	a:td_switch_events+SWEV_ACTIVE
	beq	@start_switch0
	rts
@start_switch0:
	lda	#$0001
	sta	a:screen_shake_offset
	sta	a:screen_shake_timer
	lda	#$0001
	sta	a:td_switch_events+SWEV_ACTIVE
	lda	#$0008
	sta	a:td_switch_events+SWEV_STEPS
	stz	a:td_switch_events+SWEV_TIMER
	ldy	#$0000
	lda	$0A,x
	cmp	#$0300
	bcc	@switch0_dir
	ldy	#$0002
@switch0_dir:
	sty	a:td_switch_events+SWEV_DIR
	lda	a:td_switch0_vram_addrs,y
	sta	a:td_switch_events+SWEV_VRAM
	lda	a:td_switch0_x,y
	sta	a:td_switch_events+SWEV_X
	lda	#$0050
	sta	a:td_switch_events+SWEV_Y
	rts

td_bomb_hits_map_object_tile:
	jsr	a:td_get_map_object_at
	lda	a:$0016,y
	bpl	@return_sec
	bit	#$1000
	beq	@return_sec
	lda	a:$002E,y
	ora	#$0040
	sta	a:$002E,y
	lda	a:$0006,y
	sec
	sbc_player_damage_x
	sta	a:$0006,y
	bpl	@return_sec
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
@return_sec:
	sec
	rts

; Y = the map object owning the TDA_MAP_OBJECT tile under X (by 256-pixel
; cell: stage2_map_object_by_cell on stage 2, stage5_map_object_by_cell on stage 5; $0AC0 on the
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
	beq	@stage2
	cmp	#TD_MAP_STAGE5
	beq	@stage5
	ldy	#$0AC0
	rts
@stage2:
	lda	a:stage2_map_object_by_cell,y
	tay
	rts
@stage5:
	lda	a:stage5_map_object_by_cell,y
	tay
	rts

; Moves object X around the centre of its 32 x 32-pixel cell (whirlpool);
; carry clear at the centre.
td_whirl_around_cell:
	lda	$0A,x
	and	#$001F
	bne	@off_centre_x
@centre:
	ldy	#$0010
	clc
	rts
@off_centre_x:
	sec
	sbc	#$0010
	sta	zp_08
	sta	zp_FC
	lda	$0E,x
	and	#$001F
	beq	@centre
	sec
	sbc	#$0010
	sta	zp_0A
	sta	zp_FE
	jsl	f:calc_angle
	pha
	lda	zp_FE
	bpl	@abs_dy
	eor	#$FFFF
	inc	a
@abs_dy:
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_FA
	lda	zp_FC
	bpl	@abs_dx
	eor	#$FFFF
	inc	a
@abs_dx:
	ora	zp_FA
	tay
	lda	a:td_distance_table,y
	and	#$00FF
	tay
	beq	@move
	lda	stage_frame_counter
	bit	#$0007
	bne	@move
	dey
@move:
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
	beq	@start_spiral
	lda	a:$0670,x
	pha
	bra	@move
@start_spiral:
	lda	#$0001
	sta	a:$0672,x
	jsl	f:calc_angle
	pha
	lda	zp_FC
	sta	zp_08
	lda	zp_FE
	sta	zp_0A
@move:
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
	beq	@stage2_boss
	cmp	#TD_MAP_STAGE5_BOSS
	beq	@stage5_boss
	jsr	a:td_aim_p1_target_arrow
	jsr	a:td_p1_shots_vs_enemies
	jsr	a:td_p1_vs_enemies
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p1_bomb_vs_map_objects
@return:
	rtl
@stage2_boss:
	jsr	a:td_aim_p1_arrow_stage2_boss
	jsr	a:td_p1_vs_stage2_boss
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return2
	jsr	a:td_p1_bomb_vs_stage2_boss
@return2:
	rtl
@stage5_boss:
	jsr	a:td_aim_p1_arrow_stage5_boss
	jsr	a:td_p1_vs_stage5_boss
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	@return3
	jsr	a:td_p1_bomb_vs_map_objects
@return3:
	rtl

; Player 1's shots ($0480-) against the enemies ($0D40-$0EBF).
td_p1_shots_vs_enemies:
	ldy	#$0D40
@enemy_loop:
	lda	a:$0016,y
	bmi	@hittable
	brl	@next_enemy
@hittable:
	lda	a:$002E,y
	bit	#$0003
	bne	@on_screen
	brl	@next_enemy
@on_screen:
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
@next_enemy:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	@return
	brl	@enemy_loop
@return:
	rts

; Player 1's body against the enemies.
td_p1_vs_enemies:
	jsr	a:td_p1_vs_items
	lda	a:td_p1_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	#$000C
	clc
	adc	a:td_p1_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p1_y
	sta	zp_1A
	ldx	#$0D40
@loop:
	lda	$16,x
	bpl	@next
	lda	$02,x
	eor	a:td_p1_obj+OBJ_ATTR
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next
	lda	a:p1_barrier_timer
	beq	@kill_player
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	@next
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
td_p1_vs_enemy_shots:
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
@loop:
	lda	$16,x
	bit	#$4000
	bne	@check_touch
	bit	#$8000
	beq	@next
	lda	a:td_p1_hit_flags
	bpl	@next
@check_touch:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next
	lda	$16,x
	bpl	@pick_up
	lda	a:p1_barrier_timer
	bne	@barrier
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@barrier:
	bra	@next
@pick_up:
	lda	#SOUND_WEAPON_PICKUP
	jsl	f:queue_sound
	lda	$14,x
	cmp	#TDIK_BARRIER
	bcs	@barrier_or_bomb
	ldy	a:p1_weapon_select
	sta	a:$1F84,y
	bra	@taken
@barrier_or_bomb:
	beq	@barrier_item
	lda	a:p1_bombs
	inc	a
	cmp	#$000A
	bcc	@set_bombs
	; (not executed in the CDL traces)
	lda	#$0009
@set_bombs:
	sta	a:p1_bombs
	bra	@taken
@barrier_item:
	; (not executed in the CDL traces)
	lda	#$0200
	sta	a:p1_barrier_timer
@taken:
	stz	$24,x
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop
	rts

td_p1_vs_stage2_boss:
	ldx	#$0480
@shot_loop:
	lda	$10,x
	dec	a
	bpl	@active
	brl	@next_shot
@active:
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	@check_cannon
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0003
	beq	@check_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@check_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@check_body
	jsl	f:td_end_shot
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
	lda	a:td_boss_core_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_core_hp
	bpl	@check_body
	; (not executed in the CDL traces)
	ldy	#$0B40
	jsl	f:td_score_shot_kill
@check_body:
	lda	a:td_boss_x
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	@check_cannon
	lda	a:td_boss_y
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	@check_cannon
	jsl	f:td_end_shot
@check_cannon:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	@check_pods
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	bit	#$0003
	bne	@cannon_on_screen
	brl	@check_pods
@cannon_on_screen:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	@check_pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	@check_pods
	jsl	f:td_end_shot
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	sec
	sbc_player_damage_x
	sta	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	@check_pods
	; (not executed in the CDL traces)
	ldy	#$0B80
	jsl	f:td_score_shot_kill
@check_pods:
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
@next_shot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	@done
	brl	@shot_loop
@done:
	jsr	a:td_p1_vs_items
	lda	a:td_p1_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	@pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	a:td_p1_x
	cmp	#$001C
	bcs	@pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	a:td_p1_y
	cmp	#$001C
	bcs	@pods
	lda	a:p1_barrier_timer
	beq	@kill_player
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	dec	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	@pods
	; (not executed in the CDL traces)
	ldx	#$0B80
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	@pods
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@pods:
	ldx	#$0BC0
@pod_loop:
	lda	$16,x
	bpl	@next_pod
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	@next_pod
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	@next_pod
	lda	a:p1_barrier_timer
	beq	@kill_player2
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next_pod
	; (not executed in the CDL traces)
	ldy	#$1F80
	jsl	f:td_score_kill
	bra	@next_pod
@kill_player2:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@next_pod:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@pod_loop
	lda	a:p1_barrier_timer
	beq	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0040
	bne	@damage_core
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
@damage_core:
	dec	a:td_boss_core_hp
	bpl	@check_boss_body
	; (not executed in the CDL traces)
	ldx	#$0B40
	ldy	#$1F80
	jsl	f:td_score_kill
@check_boss_body:
	lda	a:td_map_objects+$16
	bpl	@enemy_shots
	lda	a:td_boss_x
	clc
	adc	#$001A
	sec
	sbc	a:td_p1_x
	cmp	#$0034
	bcs	@enemy_shots
	lda	a:td_boss_y
	clc
	adc	#$001A
	sec
	sbc	a:td_p1_y
	cmp	#$0034
	bcs	@enemy_shots
	lda	a:p1_barrier_timer
	bne	@enemy_shots
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@enemy_shots:
	jmp	a:td_p1_vs_enemy_shots

td_p1_bomb_vs_stage2_boss:
	lda	#$0DC0
	sta	zp_1E
	bra	td_p1_bomb_vs_slots

; Player 1's smart bomb against the map objects ($0AC0-).
td_p1_bomb_vs_map_objects:
	lda	#$0EC0
	sta	zp_1E
td_p1_bomb_vs_slots:
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
	bra	td_aim_p1_arrow_at_nearest

td_aim_p1_arrow_stage5_boss:
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:td_check_nearest_target
	ldx	zp_1A
	bne	@found
	; (not executed in the CDL traces)
	brl	td_hide_p1_arrow
@found:
	bra	td_aim_p1_arrow_at_target
td_aim_p1_arrow_at_nearest:
	ldx	zp_1A
	bne	td_aim_p1_arrow_at_target
	brl	td_p1_arrow_no_target
td_aim_p1_arrow_at_target:
	lda	zp_18
	cmp	#$2000
	bcc	@near
	lda	$2E,x
	and	#$FFEF
	sta	$2E,x
	bra	td_point_p1_arrow
@near:
	lda	$2E,x
	ora	#$0010
	sta	$2E,x
	bra	td_point_p1_arrow

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
td_point_p1_arrow:
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
td_set_p1_arrow_sprites:
	lda	a:title_menu_cursor
	beq	@full_screen
	dec	a
	beq	@split_screen
@full_screen:
	lda	a:td_arrow_lr_sprites,y
	beq	@no_lr_arrow
	sta	a:td_arrow_objs
	lda	a:td_arrow_lr_x,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0070
	sta	a:td_arrow_objs+OBJ_Y
	bra	@tb_arrow
@no_lr_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
@tb_arrow:
	lda	a:td_arrow_tb_sprites,y
	beq	@no_tb_arrow
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:td_arrow_tb_y,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
@no_tb_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
@split_screen:
	lda	a:td_arrow_lr_sprites,y
	beq	@no_lr_arrow2
	sta	a:td_arrow_objs
	lda	a:td_arrow_lr_x,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0030
	sta	a:td_arrow_objs+OBJ_Y
	bra	@tb_arrow2
@no_lr_arrow2:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
@tb_arrow2:
	lda	a:td_arrow_tb_sprites,y
	beq	@no_tb_arrow2
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:td_arrow_tb_y_top_half,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
@no_tb_arrow2:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
td_p1_arrow_no_target:
	lda	#$FFFF	; [num]
	sta	a:targets_left_flag
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	jmp	a:td_set_p1_arrow_sprites

td_aim_p1_arrow_stage2_boss:
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	td_p1_arrow_no_target
	cmp	#$0009
	beq	td_p1_arrow_no_target
	cmp	#$000A
	beq	td_p1_arrow_no_target
	cmp	#$000B
	beq	td_p1_arrow_no_target
	cmp	#$0011
	bcc	td_aim_p1_arrow_at_boss
td_hide_p1_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
td_aim_p1_arrow_at_boss:
	lda	$0A,x
	sec
	sbc	a:p1_view_x
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:p1_view_y
	sta	zp_1E
	jmp	a:td_point_p1_arrow

td_p1_vs_stage5_boss:
	jsr	a:td_p1_shots_vs_stage5_boss
	jsr	a:td_p1_vs_items
	jmp	a:td_p1_body_vs_stage5_boss

td_p1_shots_vs_stage5_boss:
	ldx	#$0480
@shot_loop:
	lda	$10,x
	dec	a
	bpl	@active
	brl	@next_shot
@active:
	lda	a:td_map_objects+$16
	bpl	@check_parts
	lda	a:td_map_objects+$2E
	bit	#$0003
	beq	@check_parts
	lda	a:td_boss_x
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@check_parts
	lda	a:td_boss_y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@check_parts
	jsl	f:td_end_shot
	lda	a:td_map_objects+$2E
	ora	#$0040
	sta	a:td_map_objects+$2E
	lda	a:td_boss_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_hp
	bpl	@check_parts
	; (not executed in the CDL traces)
	ldy	#$0AC0
	jsl	f:td_score_shot_kill
@check_parts:
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
@next_shot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0700
	bcs	@return
	brl	@shot_loop
@return:
	rts
td_p1_body_vs_stage5_boss:
	lda	a:td_p1_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	a:td_map_objects+$16
	bpl	@parts
	lda	a:td_boss_x
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_x
	cmp	#$0024
	bcs	@parts
	lda	a:td_boss_y
	clc
	adc	#$0012
	sec
	sbc	a:td_p1_y
	cmp	#$0024
	bcs	@parts
	lda	a:td_map_objects+$2E
	bit	#$0040
	bne	@damage
	ora	#$0040
	sta	a:td_map_objects+$2E
@damage:
	dec	a:td_boss_hp
	bpl	@parts
	; (not executed in the CDL traces)
	ldx	#$0AC0
	ldy	#$1F80
	jsl	f:td_score_kill
@parts:
	ldx	#$0B40
@loop:
	lda	$16,x
	bpl	@next
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p1_x
	cmp	#$0014
	bcs	@next
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p1_y
	cmp	#$0014
	bcs	@next
	lda	a:p1_barrier_timer
	beq	@kill_player
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next
	ldy	#$1F80
	jsl	f:td_score_enemy_kill
	bra	@next
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p1_hp
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
	jmp	a:td_p1_vs_enemy_shots
td_run_p2_collisions:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	@stage2_boss
	cmp	#TD_MAP_STAGE5_BOSS
	beq	@stage5_boss
	jsr	a:td_aim_p2_target_arrow
	jsr	a:td_p2_shots_vs_enemies
	jsr	a:td_p2_vs_enemies
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return
	jsr	a:td_p2_bomb_vs_map_objects
@return:
	rtl
@stage2_boss:
	; (not executed in the CDL traces)
	jsr	a:td_aim_p2_arrow_stage2_boss
	jsr	a:td_p2_vs_stage2_boss
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return2
	jsr	a:td_p2_bomb_vs_stage2_boss
@return2:
	rtl
@stage5_boss:
	jsr	a:td_aim_p2_arrow_stage5_boss
	jsr	a:td_p2_vs_stage5_boss
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	@return3
	jsr	a:td_p2_bomb_vs_map_objects
@return3:
	rtl

td_p2_shots_vs_enemies:
	ldy	#$0D40
@enemy_loop:
	lda	a:$0016,y
	bmi	@hittable
	brl	@next_enemy
@hittable:
	lda	a:$002E,y
	bit	#$0003
	bne	@on_screen
	brl	@next_enemy
@on_screen:
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
@next_enemy:
	tya
	clc
	adc	#$0040
	tay
	cpy	#$0EC0
	bcs	@return
	brl	@enemy_loop
@return:
	rts

td_p2_vs_enemies:
	jsr	a:td_p2_vs_items
	lda	a:td_p2_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	#$000C
	clc
	adc	a:td_p2_x
	sta	zp_18
	lda	#$000C
	clc
	adc	a:td_p2_y
	sta	zp_1A
	ldx	#$0D40
@loop:
	lda	$16,x
	bpl	@next
	lda	$02,x
	eor	a:td_p2_obj+OBJ_ATTR
	bit	#$3000
	bne	@next
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next
	lda	a:p2_barrier_timer
	beq	@kill_player
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	@next
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
td_p2_vs_enemy_shots:
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
@loop:
	lda	$16,x
	bit	#$4000
	bne	@check_touch
	bit	#$8000
	beq	@next
	lda	a:td_p2_hit_flags
	bpl	@next
@check_touch:
	lda	zp_18
	sec
	sbc	$0A,x
	cmp	#$0018
	bcs	@next
	lda	zp_1A
	sec
	sbc	$0E,x
	cmp	#$0018
	bcs	@next
	lda	$16,x
	bpl	@pick_up
	lda	a:p2_barrier_timer
	bne	@barrier
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@barrier:
	bra	@next
@pick_up:
	lda	#SOUND_WEAPON_PICKUP
	jsl	f:queue_sound
	lda	$14,x
	cmp	#TDIK_BARRIER
	bcs	@barrier_or_bomb
	ldy	a:p2_weapon_select
	sta	a:$1FC4,y
	bra	@taken
@barrier_or_bomb:
	; (not executed in the CDL traces)
	beq	@barrier_item
	lda	a:p2_bombs
	inc	a
	cmp	#$000A
	bcc	@set_bombs
	lda	#$0009
@set_bombs:
	sta	a:p2_bombs
	bra	@taken
@barrier_item:
	lda	#$0200
	sta	a:p2_barrier_timer
@taken:
	stz	$24,x
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop
	rts

td_p2_vs_stage2_boss:
	; (not executed in the CDL traces)
	ldx	#$0700
@shot_loop:
	lda	$10,x
	dec	a
	bpl	@active
	brl	@next_shot
@active:
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	@check_cannon
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0003
	beq	@check_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@check_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@check_body
	jsl	f:td_end_shot
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
	lda	a:td_boss_core_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_core_hp
	bpl	@check_body
	ldy	#$0B40
	jsl	f:td_score_shot_kill
@check_body:
	lda	a:td_boss_x
	clc
	adc	#$0016
	sec
	sbc	$0A,x
	cmp	#$002C
	bcs	@check_cannon
	lda	a:td_boss_y
	clc
	adc	#$0016
	sec
	sbc	$0E,x
	cmp	#$002C
	bcs	@check_cannon
	jsl	f:td_end_shot
@check_cannon:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	@check_pods
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	bit	#$0003
	bne	@cannon_on_screen
	brl	@check_pods
@cannon_on_screen:
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000A
	sec
	sbc	$0A,x
	cmp	#$0014
	bcs	@check_pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000A
	sec
	sbc	$0E,x
	cmp	#$0014
	bcs	@check_pods
	jsl	f:td_end_shot
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	sec
	sbc_player_damage_x
	sta	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	@check_pods
	ldy	#$0B80
	jsl	f:td_score_shot_kill
@check_pods:
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
@next_shot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@done
	brl	@shot_loop
@done:
	jsr	a:td_p2_vs_items
	lda	a:td_p2_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	a:td_map_objects+3*OBJ_SIZE+$16
	bpl	@pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_X
	clc
	adc	#$000E
	sec
	sbc	a:td_p2_x
	cmp	#$001C
	bcs	@pods
	lda	a:td_map_objects+3*OBJ_SIZE+OBJ_Y
	clc
	adc	#$000E
	sec
	sbc	a:td_p2_y
	cmp	#$001C
	bcs	@pods
	lda	a:p2_barrier_timer
	beq	@kill_player
	lda	a:td_map_objects+3*OBJ_SIZE+$2E
	ora	#$0040
	sta	a:td_map_objects+3*OBJ_SIZE+$2E
	dec	a:td_map_objects+3*OBJ_SIZE+OBJ_HP
	bpl	@pods
	ldx	#$0B80
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	@pods
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@pods:
	ldx	#$0BC0
@pod_loop:
	lda	$16,x
	bpl	@next_pod
	lda	$0A,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	@next_pod
	lda	$0E,x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	@next_pod
	lda	a:p2_barrier_timer
	beq	@kill_player2
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next_pod
	ldy	#$1FC0
	jsl	f:td_score_kill
	bra	@next_pod
@kill_player2:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@next_pod:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@pod_loop
	lda	a:p2_barrier_timer
	beq	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+$16
	bpl	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	@check_boss_body
	lda	a:td_map_objects+2*OBJ_SIZE+$2E
	bit	#$0040
	bne	@damage_core
	ora	#$0040
	sta	a:td_map_objects+2*OBJ_SIZE+$2E
@damage_core:
	dec	a:td_boss_core_hp
	bpl	@check_boss_body
	ldx	#$0B40
	ldy	#$1FC0
	jsl	f:td_score_kill
@check_boss_body:
	lda	a:td_map_objects+$16
	bpl	@enemy_shots
	lda	a:td_boss_x
	clc
	adc	#$001A
	sec
	sbc	a:td_p2_x
	cmp	#$0034
	bcs	@enemy_shots
	lda	a:td_boss_y
	clc
	adc	#$001A
	sec
	sbc	a:td_p2_y
	cmp	#$0034
	bcs	@enemy_shots
	lda	a:p2_barrier_timer
	bne	@enemy_shots
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@enemy_shots:
	jmp	a:td_p2_vs_enemy_shots

td_p2_bomb_vs_stage2_boss:
	; (not executed in the CDL traces)
	lda	#$0DC0
	sta	zp_1E
	bra	td_p2_bomb_vs_slots

td_p2_bomb_vs_map_objects:
	lda	#$0EC0
	sta	zp_1E
td_p2_bomb_vs_slots:
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
	bra	td_aim_p2_arrow_at_nearest

td_aim_p2_arrow_stage5_boss:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	zp_18
	stz	zp_1A
	ldx	#$0AC0
	jsr	a:td_check_nearest_target_p2
	ldx	zp_1A
	bne	@found
	brl	td_hide_p2_arrow
@found:
	bra	td_aim_p2_arrow_at_target
td_aim_p2_arrow_at_nearest:
	ldx	zp_1A
	bne	td_aim_p2_arrow_at_target
	; (not executed in the CDL traces)
	brl	td_p2_arrow_no_target
td_aim_p2_arrow_at_target:
	lda	zp_18
	cmp	#$2000
	bcc	@near
	lda	$2E,x
	and	#$FFDF
	sta	$2E,x
	bra	td_point_p2_arrow
@near:
	lda	$2E,x
	ora	#$0020
	sta	$2E,x
	bra	td_point_p2_arrow

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
td_point_p2_arrow:
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
td_set_p2_arrow_sprites:
	lda	a:title_menu_cursor
	beq	@full_screen
	dec	a
	beq	@split_screen
@full_screen:
	lda	a:td_p2_arrow_lr_sprites,y
	beq	@no_lr_arrow
	sta	a:td_arrow_objs
	lda	a:td_p2_arrow_lr_x,y
	sta	a:td_arrow_objs+OBJ_X
	lda	#$0070
	sta	a:td_arrow_objs+OBJ_Y
	bra	@tb_arrow
@no_lr_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+OBJ_Y
@tb_arrow:
	lda	a:td_p2_arrow_tb_sprites,y
	beq	@no_tb_arrow
	sta	a:td_arrow_objs+1*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	lda	a:td_p2_arrow_tb_y,y
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
@no_tb_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	rts
@split_screen:
	lda	a:td_p2_arrow_lr_sprites,y
	beq	@no_lr_arrow2
	sta	a:td_arrow_objs+2*OBJ_SIZE
	lda	a:td_p2_arrow_lr_x,y
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_X
	lda	#$00A8
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
	bra	@tb_arrow2
@no_lr_arrow2:
	lda	#$00F0
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
@tb_arrow2:
	lda	a:td_p2_arrow_tb_sprites,y
	beq	@no_tb_arrow2
	sta	a:td_arrow_objs+3*OBJ_SIZE
	lda	#$0078
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_X
	lda	a:td_p2_arrow_tb_y_bottom_half,y
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
@no_tb_arrow2:
	lda	#$00F0
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
td_p2_arrow_no_target:
	; (not executed in the CDL traces)
	lda	#$FFFF	; [num]
	sta	a:targets_left_flag
	lda	stage_frame_counter
	asl	a
	and	#$000E
	tay
	jmp	a:td_set_p2_arrow_sprites

td_aim_p2_arrow_stage2_boss:
	; (not executed in the CDL traces)
	ldx	#$0AC0
	lda	$12,x
	cmp	#$0003
	bcc	td_p2_arrow_no_target
	cmp	#$0009
	beq	td_p2_arrow_no_target
	cmp	#$000A
	beq	td_p2_arrow_no_target
	cmp	#$000B
	beq	td_p2_arrow_no_target
	cmp	#$0011
	bcc	td_aim_p2_arrow_at_boss
td_hide_p2_arrow:
	lda	#$00F0
	sta	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
	sta	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	rts
td_aim_p2_arrow_at_boss:
	lda	$0A,x
	sec
	sbc	a:p2_view_x
	sta	zp_1C
	lda	$0E,x
	sec
	sbc	a:p2_view_y
	sta	zp_1E
	jmp	a:td_point_p2_arrow

td_p2_vs_stage5_boss:
	; (not executed in the CDL traces)
	jsr	a:td_p2_shots_vs_stage5_boss
	jsr	a:td_p2_vs_items
	jmp	a:td_p2_body_vs_stage5_boss

td_p2_shots_vs_stage5_boss:
	; (not executed in the CDL traces)
	ldx	#$0700
@shot_loop:
	lda	$10,x
	dec	a
	bpl	@active
	brl	@next_shot
@active:
	lda	a:td_map_objects+$16
	bpl	@check_parts
	lda	a:td_map_objects+$2E
	bit	#$0003
	beq	@check_parts
	lda	a:td_boss_x
	clc
	adc	#$000E
	sec
	sbc	$0A,x
	cmp	#$001C
	bcs	@check_parts
	lda	a:td_boss_y
	clc
	adc	#$000E
	sec
	sbc	$0E,x
	cmp	#$001C
	bcs	@check_parts
	jsl	f:td_end_shot
	lda	a:td_map_objects+$2E
	ora	#$0040
	sta	a:td_map_objects+$2E
	lda	a:td_boss_hp
	sec
	sbc_player_damage_x
	sta	a:td_boss_hp
	bpl	@check_parts
	ldy	#$0AC0
	jsl	f:td_score_shot_kill
@check_parts:
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
@next_shot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	@shot_loop
@return:
	rts
td_p2_body_vs_stage5_boss:
	lda	a:td_p2_hit_flags
	bmi	@vulnerable
	rts
@vulnerable:
	lda	a:td_map_objects+$16
	bpl	@parts
	lda	a:td_boss_x
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_x
	cmp	#$0024
	bcs	@parts
	lda	a:td_boss_y
	clc
	adc	#$0012
	sec
	sbc	a:td_p2_y
	cmp	#$0024
	bcs	@parts
	lda	a:td_map_objects+$2E
	bit	#$0040
	bne	@damage
	ora	#$0040
	sta	a:td_map_objects+$2E
@damage:
	dec	a:td_boss_hp
	bpl	@parts
	ldx	#$0AC0
	ldy	#$1FC0
	jsl	f:td_score_kill
@parts:
	ldx	#$0B40
@loop:
	lda	$16,x
	bpl	@next
	lda	$0A,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p2_x
	cmp	#$0014
	bcs	@next
	lda	$0E,x
	clc
	adc	#$000A
	sec
	sbc	a:td_p2_y
	cmp	#$0014
	bcs	@next
	lda	a:p2_barrier_timer
	beq	@kill_player
	lda	$2E,x
	ora	#$0040
	sta	$2E,x
	dec	$06,x
	bpl	@next
	ldy	#$1FC0
	jsl	f:td_score_enemy_kill
	bra	@next
@kill_player:
	lda	#$FFFF	; [num]
	sta	a:td_p2_hp
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@loop
	jmp	a:td_p2_vs_enemy_shots

; Stage 2: block animations of the map (four blocks a frame through the
; patch slots), and timers at $1880 that redraw a spot and spawn an object.
td_update_stage2_map_events:
	lda	a:m7_patch_flags
	ora	a:m7_patch_flags+2
	ora	a:m7_patch_flags+4
	ora	a:m7_patch_flags+6
	beq	@patches_free
	brl	@trap_timers
@patches_free:
	lda	a:block_anim_timer_left
	beq	@right_block_anim
	dec	a:block_anim_timer_left
	asl	a
	tay
	lda	a:td_block_anim_frames,y
	beq	@right_block_anim
	tax
	ldy	a:td_block_anim_blocks_0,x
	lda	a:td_block_anim_vram_left_0,x
	phx
	jsl	f:set_m7_block_patch_0
	plx
	ldy	a:td_block_anim_blocks_1,x
	lda	a:td_block_anim_vram_left_1,x
	phx
	jsl	f:set_m7_block_patch_1
	plx
	ldy	a:td_block_anim_blocks_2,x
	lda	a:td_block_anim_vram_left_2,x
	phx
	jsl	f:set_m7_block_patch_2
	plx
	ldy	a:td_block_anim_blocks_3,x
	lda	a:td_block_anim_vram_left_3,x
	jml	f:set_m7_block_patch_3
@right_block_anim:
	lda	a:block_anim_timer_right
	beq	@trap_timers
	dec	a:block_anim_timer_right
	asl	a
	tay
	lda	a:td_block_anim_frames,y
	beq	@trap_timers
	tax
	ldy	a:td_block_anim_blocks_0,x
	lda	a:td_block_anim_vram_right_0,x
	phx
	jsl	f:set_m7_block_patch_0
	plx
	ldy	a:td_block_anim_blocks_1,x
	lda	a:td_block_anim_vram_right_1,x
	phx
	jsl	f:set_m7_block_patch_1
	plx
	ldy	a:td_block_anim_blocks_2,x
	lda	a:td_block_anim_vram_right_2,x
	phx
	jsl	f:set_m7_block_patch_2
	plx
	ldy	a:td_block_anim_blocks_3,x
	lda	a:td_block_anim_vram_right_3,x
	jml	f:set_m7_block_patch_3
@trap_timers:
	ldx	#$002C
@loop:
	lda	a:$187E,x
	beq	@next
	dec	a:$187E,x
	beq	@redraw_trap
	cmp	#$0020
	bne	@next
	pha
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	pla
	jsl	f:td_find_free_item_slot
	bcs	@no_slot
	lda	#TDI_BLAST
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	a:td_trap_blast_x,x
	sta	a:$000A,y
	lda	a:td_trap_blast_y,x
	sta	a:$000E,y
@no_slot:
	bra	@next
@redraw_trap:
	phx
	ldy	#$0057
	lda	a:td_trap_vram_addrs,x
	jsl	f:queue_m7_block_patch
	plx
	bcc	@next
	; (not executed in the CDL traces)
	inc	a:$187E,x
@next:
	dex
	dex
	bne	@loop
	rtl

; Stage 5: runs the three switch events ($18B0, $18BE, $18CC, $0E bytes
; each) started by td_trigger_switch_event.
td_update_switch_events:
	ldx	#$18B0
@loop:
	lda	$00,x
	beq	@next
	jsr	a:td_step_switch_event
@next:
	txa
	clc
	adc	#$000E
	tax
	cpx	#$18DA
	bcc	@loop
	rtl

td_step_switch_event:
	lda	#$0001
	sta	a:screen_shake_timer
	jsr	a:td_switch_event_explosion
	lda	$04,x
	inc	$04,x
	ldy	difficulty
	cmp	a:td_switch_event_step_delays,y
	bcs	@next_step
	rts
@next_step:
	jsr	a:td_patch_switch_event_block
	bcs	@return
	lda	#SOUND_EXPLOSION
	jsl	f:queue_sound
	dec	$02,x
	beq	@finished
	stz	$04,x
	ldy	$06,x
	lda	$08,x
	clc
	adc	a:td_switch_event_step_x,y
	sta	$08,x
	lda	$0C,x
	clc
	adc	a:td_switch_event_step_vram,y
	sta	$0C,x
@return:
	rts
@finished:
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
	lda	a:td_switch_event_blocks,y
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
