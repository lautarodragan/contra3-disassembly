; objects/object_handlers_00c.asm -- Object handlers (bank $00, part 3)
; Bank $00, $00:F27C-$00:FD8C. Included by main.asm in segment BANK00.
;
; The stage 1 boss (type 1, update_stage1_boss_controller) with its attacks
; and parts (types $1F, $20, $22, $23, $26, $27, $29, $38).

; Object type $01: the stage 1 boss (the giant turtle bursting through the
; wall), invisible controller in slot $0900. The turtle is drawn on BG2
; (scrolled by stage1_boss_set_bg2_scroll, bent by HDMA tables at $7E:A000);
; the sprite objects are its hitboxes and parts. States: 0 boss music
; (song_change_*), 1 waits for bg1_scroll_mode 4 and loads the graphics
; (load_list_05AA1F), 2-4 the wall breaks (type $22 chunks, type $23 debris),
; 5 spawns the parts (spawn_stage1_boss_parts: body type $29 with HP 352,
; head type $1F, shell type $20), 6-8 attacks (stage1_boss_run_attack) and
; the slam. Field $32 counts down after the boss dies (explosions), then
; stage_exit_request. Checked in the emulator (o2s1 captures).
update_stage1_boss_controller:
	lda	$32,x
	beq	@no_countdown
	dec	a
	bne	@store_dying_timer
	dec	a
	ldy	#$0100
	sty	a:stage_exit_request
@store_dying_timer:
	sta	$32,x
	jsl	f:make_players_invulnerable
@no_countdown:
	inc	a:boss_work_0
	ldy	#$0012
	lda	stage_frame_mod8
	cmp	#$0005
	bcs	@set_mosaic
	ldy	#$0000
@set_mosaic:
	sty	a:mosaic_shadow
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage1_boss_controller_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage1_boss_controller_states:
	.addr	stage1_boss_controller_state_00
	.addr	stage1_boss_controller_state_01
	.addr	stage1_boss_controller_state_02
	.addr	stage1_boss_controller_state_03
	.addr	stage1_boss_controller_state_04
	.addr	stage1_boss_controller_state_05
	.addr	stage1_boss_controller_state_06
	.addr	stage1_boss_controller_state_07
	.addr	stage1_boss_controller_state_08

stage1_boss_controller_state_00:
	lda	#$0002
	jsl	f:start_palette_anim
	lda	#.loword(song_set_05F48A)
	sta	a:song_change_set
	lda	#$0004
	sta	a:song_change_mode
	stz	$32,x
	inc	$12,x
	lda	#$0040
	sta	zp_04
	lda	#TILE_WALL|TILE_NO_DROP
	sta	zp_02
	ldy	#$4830
	lda	#$0018
	jml	f:update_object_type_28

stage1_boss_controller_state_01:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@return
	stz	hdma_preset
	inc	OBJ_STATE,x
	lda	#$0080
	sta	OBJ_TIMER,x
	stx	zp_FC
	ldx	#.loword(load_list_05AA1F)
	jsl	f:load_data_list
	ldy	#.loword(palette_task_05AA28)
	jsl	f:start_palette_task
	ldx	zp_FC
	jsl	f:clear_hdma_line_buffer
	jsr	a:stage1_boss_init_hdma_table
@return:
	rtl

stage1_boss_controller_state_02:
	lda	OBJ_TIMER,x
	bmi	@wait_song
	dec	OBJ_TIMER,x
	bpl	@return
@wait_song:
	lda	a:song_change_state
	bne	@return
	lda	#$0068
	jsl	f:queue_sound
	lda	#$0058
	jsl	f:queue_sound
	lda	#$0002
	sta	$24,x
	inc	$12,x
	jsr	a:spawn_stage1_boss_wall_chunks
	stz	a:boss_work_2
	lda	#$0020
	sta	a:boss_work_3
	sta	a:boss_work_5
@return:
	rtl

stage1_boss_controller_state_03:
	dec	OBJ_TIMER,x
	beq	@timer_done
	phx
	jsr	a:spawn_stage1_boss_falling_debris
	plx
	ldy	#.loword(vram_blocks_05AAB8)
	lda	#$4018
	sta	zp_0C
	lda	#$0040
	bra	@queue_blocks
@timer_done:
	inc	$12,x
	lda	#$003C
	sta	$16,x
	lda	#$0180
	sta	$0A,x
	lda	#$0080
	sta	$28,x
	lda	#$FFA0	; [num]
	sta	$2A,x
	ldy	#.loword(vram_blocks_05AAC8)
	lda	#$4218
	sta	zp_0C
	lda	#$0030
@queue_blocks:
	sta	zp_08
	lda	a:bg1_x
	bit	#$0100
	beq	@vram_addr_set
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
@vram_addr_set:
	lda	#$0002
	sta	zp_02
	phx
	lda	zp_0C
	jsl	f:queue_vram_blocks
	plx
	rtl

stage1_boss_controller_state_04:
	jsr	a:stage1_boss_push_wall
	lda	$34,x
	bne	@still_pushing
	inc	$12,x
	lda	#$0010
	sta	$24,x
@still_pushing:
	jsr	a:stage1_boss_place_middle_chunks
	jsr	a:stage1_boss_set_bg2_scroll
	rtl

stage1_boss_controller_state_05:
	dec	OBJ_TIMER,x
	bne	@move_body_up
	lda	#$0006
	sta	hdma_preset
	inc	OBJ_STATE,x
	lda	#$0020
	sta	a:boss_work_0
	stz	$36,x
	lda	#$0080
	sta	$38,x
	lda	#$0080
	sta	a:obj_slots+9*OBJ_SIZE+$34
	lda	#$0100
	sta	a:boss_work_1
	jsr	a:spawn_stage1_boss_parts
@move_body_up:
	dec	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	jsr	a:stage1_boss_place_middle_chunks
	jsr	a:stage1_boss_set_bg2_scroll
	rtl

stage1_boss_controller_state_06:
	lda	a:boss_work_3
	cmp	#$0020
	bne	@sway
	lda	$32,x
	bne	@start_slam
	lda	rng_lo
	bit	#$003F
	bne	@sway
@start_slam:
	lda	#$0003
	sta	a:boss_work_4
	inc	$12,x
	rtl
@sway:
	lda	#$2000
	sta	zp_00
	stz	zp_02
	jsr	a:stage1_boss_sway
	jsr	a:stage1_boss_run_attack
	brl	stage1_boss_controller_tail

stage1_boss_controller_state_07:
	lda	a:boss_work_3
	cmp	#$0007
	bcs	@move_down
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0004
	sta	a:shake_timer
	inc	$12,x
	rtl
@move_down:
	stz	zp_00
	lda	#$0002
	sta	zp_02
	jsr	a:stage1_boss_move_down
	jsr	a:stage1_boss_run_attack
	brl	stage1_boss_controller_tail

stage1_boss_controller_state_08:
	lda	a:boss_work_3
	cmp	#$0020
	bcc	@move_up
	dec	a:boss_work_4
	bne	@back_to_state_07
	lda	$32,x
	bne	@back_to_state_07
	lda	#$0020
	sta	a:boss_work_0
	lda	#$0006
	sta	OBJ_STATE,x
	rtl
@back_to_state_07:
	dec	$12,x
	rtl
@move_up:
	stz	zp_00
	lda	#$0002
	sta	zp_02
	jsr	a:stage1_boss_move_up
	jsr	a:stage1_boss_run_attack
	brl	stage1_boss_controller_tail
; Common end of states 6-8: height, BG block, chunks, parts, head HDMA,
; face tiles, death explosions.
stage1_boss_controller_tail:
	jsr	a:stage1_boss_add_height
	jsl	f:stage1_boss_queue_bg_block
	jsr	a:stage1_boss_place_middle_chunks
	jsr	a:stage1_boss_place_parts
	jsr	a:stage1_boss_build_head_hdma
	jsr	a:stage1_boss_queue_face_tiles
	jsr	a:stage1_boss_death_explosions
	rtl

; While the dying countdown (field $32) runs: sound $6E and explosions at
; random around the boss.
stage1_boss_death_explosions:
	lda	$32,x
	beq	@return
	jsl	f:queue_sound_6E_throttled
	lda	$0A,x
	adc	#$FFE0
	sta	zp_00
	lda	$0E,x
	adc	#$0010
	sta	zp_02
	lda	#$007F
	sta	zp_04
	lda	#$007F
	sta	zp_06
	ldy	#$0280
	lda	#.loword(anim_05C516)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFD	; [num]
	sta	a:$001E,y
@return:
	rts

stage1_boss_queue_face_tiles:
	ldy	#.loword(vram_blocks_05AB28)
	lda	$3E,x
	beq	@queue_blocks
	dec	$3E,x
	ldy	#.loword(vram_blocks_05AB30)
@queue_blocks:
	lda	#$0002
	sta	zp_02
	lda	#$0040
	sta	zp_08
	lda	#$4D8C
	phx
	ldx	#$0020
	jsl	f:queue_vram_blocks_at_x
	plx
	rts

stage1_boss_queue_bg_block:
	lda	#$A000	; [num]
	sta	zp_00
	lda	#$0020
	sta	zp_E2
	lda	#$5E00
	jml	f:@queue
@queue:
	ldy	#$0000
	sta	a:vram_block_queue,y
	clc
	adc	#$0010
	sta	a:vram_block_queue+2,y
	clc
	adc	#$0010
	sta	a:vram_block_queue+4,y
	clc
	adc	#$0010
	sta	a:vram_block_queue+6,y
	lda	zp_00
	sta	a:vram_block_src,y
	clc
	lda	vram_block_queue_end
	adc	#$0008
	sta	vram_block_queue_end
	rtl

spawn_stage1_boss_wall_chunks:
	phx
	ldx	#$0300
	ldy	#$0000
@loop:
	lda	#$0022
	sta	$10,x
	lda	#$0001
	sta	$16,x
	lda	#$3800
	sta	$02,x
	lda	#$001C
	sta	$28,x
	lda	#$FFE5	; [num]
	sta	$2A,x
	stz	$30,x
	lda	a:stage1_boss_wall_chunk_x,y
	sta	$0A,x
	lda	a:stage1_boss_wall_chunk_y,y
	sta	$0E,x
	lda	a:stage1_boss_wall_chunk_timers,y
	sta	$24,x
	iny
	iny
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0400
	bcc	@loop
	plx
	lda	#$0008
	sta	$34,x
	rts

; States 2-4: every $20 frames one of the end chunks ($0300 / $03C0,
; alternately) is thrown, the shake and sound $56; $34 counts the pushes.
stage1_boss_push_wall:
	lda	$24,x
	beq	@chunk_flying
	dec	$24,x
	bne	@return
	lda	$30,x
	eor	#$0002
	sta	$30,x
	lda	#$0020
	sta	a:boss_work_7
	brl	@throw_chunk
@return:
	rts
@chunk_flying:
	dec	a:boss_work_7
	bpl	@return2
	lda	#$0020
	sta	$24,x
	stz	a:obj_slots+4*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+4*OBJ_SIZE+OBJ_X_VEL
	stz	a:obj_slots+4*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+4*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+4*OBJ_SIZE+$30
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_X_VEL_SUB
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_X_VEL
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_Y_VEL_SUB
	stz	a:obj_slots+7*OBJ_SIZE+OBJ_Y_VEL
	stz	a:obj_slots+7*OBJ_SIZE+$30
	lda	#$0004
	sta	a:shake_timer
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0056
	jsl	f:queue_sound
	dec	$34,x
@return2:
	rts
@throw_chunk:
	phx
	lda	$30,x
	bne	@right_chunk
	ldx	#$0300
	bra	@set_velocity
@right_chunk:
	ldx	#$03C0
@set_velocity:
	lda	#$4000
	sta	$18,x
	lda	#$FFFE	; [num]
	sta	$1A,x
	lda	#$0000
	sta	$1C,x
	lda	#$FFFF	; [num]
	sta	$1E,x
	lda	#$0001
	sta	$30,x
	plx
	rts

; Places the chunks $0340 / $0380 at 1/3 and 2/3 of the way between $0300
; and $03C0.
stage1_boss_place_middle_chunks:
	stz	zp_00
	sec
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_X
	sbc	a:obj_slots+7*OBJ_SIZE+OBJ_X
	bpl	@abs_dx
	eor	#$FFFF
	inc	zp_00
@abs_dx:
	and	#$00FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$03
	sta	a:WRDIVB
	rep	#$20
	.a16
	stz	zp_02
	sec
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	sbc	a:obj_slots+7*OBJ_SIZE+OBJ_Y
	bpl	@abs_dy
	eor	#$FFFF
	inc	zp_02
@abs_dy:
	and	#$00FF
	pha
	lda	a:RDDIVL
	ldy	zp_00
	bne	@x_step
	eor	#$FFFF
@x_step:
	sta	zp_00
	clc
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_X
	adc	zp_00
	adc	#$0000
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_X
	clc
	adc	zp_00
	adc	#$0000
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_X
	pla
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$03
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	ldy	zp_02
	bne	@y_step
	; (not executed in the CDL traces)
	eor	#$FFFF
@y_step:
	sta	zp_02
	clc
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	adc	zp_02
	sta	a:obj_slots+5*OBJ_SIZE+OBJ_Y
	clc
	adc	zp_02
	sta	a:obj_slots+6*OBJ_SIZE+OBJ_Y
	rts

stage1_boss_init_hdma_table:
	phx
	ldx	#$0000
	lda	#$0008
@loop:
	sta	f:$7EA046,x
	inx
	inx
	cpx	#$003A
	bcc	@loop
	plx
	rts

; Runs the attack in field $36 (tbl_stage1_boss_attacks; $38 = its timer);
; attack 0 picks the next one at random.
stage1_boss_run_attack:
	lda	$36,x
	phx
	asl	a
	tax
	lda	f:tbl_stage1_boss_attacks,x
	plx
	sta	zp_0C
	jmp	(zp_0C)
tbl_stage1_boss_attacks:
	.addr	stage1_boss_attack_choose
	.addr	stage1_boss_attack_falling_shots
	.addr	stage1_boss_attack_tracking_shots
	.addr	stage1_boss_attack_03
	.addr	stage1_boss_attack_fire
	.addr	stage1_boss_attack_fire_stream
	.addr	stage1_boss_attack_06

stage1_boss_attack_06:
	ldy	a:boss_work_5
	cpy	#$002C
	bcs	@dec_bend
	brl	stage1_boss_inc_bend
@dec_bend:
	brl	stage1_boss_dec_bend

stage1_boss_attack_fire:
	lda	#$0002
	sta	$3E,x
	dec	$38,x
	bne	@spawn_fire
	lda	#$0025
	jsl	f:queue_sound
	inc	$36,x
	ldy	difficulty
	lda	a:stage1_boss_fire_timers,y
	sta	$38,x
@spawn_fire:
	jsr	a:stage1_boss_spawn_fire
	ldy	a:boss_work_5
	cpy	#$001C
	bcs	@dec_bend
	brl	stage1_boss_inc_bend
@dec_bend:
	brl	stage1_boss_dec_bend

stage1_boss_attack_fire_stream:
	lda	#$0002
	sta	$3E,x
	lda	#$0001
	sta	a:shake_continuous
	dec	$38,x
	bne	@spawn_shot
	stz	$36,x
	lda	#$0100
	sta	$38,x
@spawn_shot:
	jsr	a:stage1_boss_spawn_fire_stream_shot
	brl	stage1_boss_shift_upper_lines

stage1_boss_attack_falling_shots:
	lda	stage_frame_mod8
	bne	@count_down
	lda	#$0004
	sta	$3E,x
@count_down:
	dec	$38,x
	bne	@fire
	stz	$36,x
	lda	#$0080
	sta	$38,x
@fire:
	jsr	a:stage1_boss_fire_falling_shot
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0010
	bne	stage1_boss_bend_toward_10
stage1_boss_bend_toward_30:
	cpy	#$0030
	bcs	@dec_bend
	brl	stage1_boss_inc_bend
@dec_bend:
	brl	stage1_boss_dec_bend
stage1_boss_bend_toward_10:
	cpy	#$0010
	bcc	@inc_bend
	brl	stage1_boss_dec_bend
@inc_bend:
	; (not executed in the CDL traces)
	brl	stage1_boss_inc_bend

stage1_boss_attack_tracking_shots:
	lda	a:boss_work_0
	and	#$0040
	beq	@count_down
	lda	#$0002
	sta	$3E,x
@count_down:
	dec	$38,x
	bne	@fire
	stz	$36,x
	lda	#$0040
	sta	$38,x
@fire:
	jsr	a:stage1_boss_fire_tracking_shot
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0020
	bne	@toward_10
	cpy	#$0024
	bcs	@dec_bend
	brl	stage1_boss_inc_bend
@dec_bend:
	brl	stage1_boss_dec_bend
@toward_10:
	cpy	#$0010
	bcc	@inc_bend
	brl	stage1_boss_dec_bend
@inc_bend:
	brl	stage1_boss_inc_bend

stage1_boss_attack_03:
	lda	stage_frame_counter
	bit	#$001F
	bne	@count_down
	lda	#$0004
	sta	$3E,x
@count_down:
	dec	$38,x
	bne	@pick_player
	stz	$36,x
	lda	#$0080
	sta	$38,x
	stz	a:obj_slots+9*OBJ_SIZE+OBJ_TIMER
@pick_player:
	ldy	a:boss_work_5
	lda	$38,x
	bit	#$0080
	bne	@player2
	lda	a:p1_lives
	bne	@p1_height
	; (not executed in the CDL traces)
	brl	@p2_height
@p1_height:
	sec
	lda	a:player1_obj+OBJ_Y
	sbc	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	bcs	@toward_8
	brl	stage1_boss_bend_toward_30
@player2:
	lda	a:p2_lives
	bne	@p2_height
	brl	@p1_height
@p2_height:
	; (not executed in the CDL traces)
	sec
	lda	a:player2_obj+OBJ_Y
	sbc	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	bcs	@toward_8
	brl	stage1_boss_bend_toward_30
@toward_8:
	cpy	#$0008
	bcc	@inc_bend
	brl	stage1_boss_dec_bend
@inc_bend:
	; (not executed in the CDL traces)
	brl	stage1_boss_inc_bend

stage1_boss_attack_choose:
	dec	$38,x
	bne	@bend
	lda	rng_lo
	bit	#$0003
	beq	@fire_or_03
	bit	#$0001
	bne	@tracking_shots
	ldy	#$00C0
	lda	#$0001
	bra	@set_attack
@tracking_shots:
	lda	#$0057
	jsl	f:queue_sound
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_TYPE
	cmp	#$0020
	bne	@fire
	ldy	#$0080
	lda	#$0002
	bra	@set_attack
@fire_or_03:
	bit	#$0008
	bne	@attack_03
@fire:
	lda	#$0057
	jsl	f:queue_sound
	stz	$3A,x
	ldy	#$0080
	lda	#$0004
	bra	@set_attack
@attack_03:
	lda	#$0057
	jsl	f:queue_sound
	lda	#$0001
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_TIMER
	ldy	#$0100
	lda	#$0003
@set_attack:
	sta	$36,x
	sty	$38,x
@bend:
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0010
	bne	@toward_10
	cpy	#$0024
	bcs	@keep_bend
	brl	stage1_boss_inc_bend
@keep_bend:
	brl	stage1_boss_shift_upper_lines
@toward_10:
	cpy	#$0010
	bcc	stage1_boss_shift_upper_lines
	brl	stage1_boss_dec_bend
; Adds zp_00/zp_02 to the first $10 lines of the HDMA tables, bend unchanged.
stage1_boss_shift_upper_lines:
	phx
	ldx	#$0000
@loop:
	clc
	lda	f:$7EA0C6,x
	adc	zp_00
	sta	f:$7EA0C6,x
	lda	f:$7EA046,x
	adc	zp_02
	and	#$00FF
	ora	#$4000
	sta	f:$7EA046,x
	inx
	inx
	cpx	#$0020
	bcc	@loop
	plx
	rts

; Probably: moves the body (HDMA lines) up or down by zp_00/zp_02, the
; direction by bit 6 of boss_work_0 (stage1_boss_move_down negates the step,
; stage1_boss_move_up as is).
stage1_boss_sway:
	lda	a:boss_work_0
	and	#$0040
	bne	stage1_boss_move_down
	bra	stage1_boss_move_up

stage1_boss_move_down:
	lda	zp_00
	eor	#$FFFF
	clc
	adc	#$0001
	sta	zp_00
	lda	zp_02
	eor	#$FFFF
	adc	#$0000
	sta	zp_02
	bra	stage1_boss_move_down_tail

stage1_boss_move_up:
	ldy	#$0020
	bra	stage1_boss_step_lower_lines
stage1_boss_move_down_tail:
	ldy	#$0058
stage1_boss_step_lower_lines:
	phx
	ldx	#$0020
	lda	#$003A
	bra	stage1_boss_step_hdma_lines
; Bending the body: boss_work_5 counts the bend; inc/dec step the first $10
; lines of the HDMA tables at $7E:A046/$7E:A0C6 by stage1_boss_hdma_line_steps
; (from offset 0 or $38) and add zp_00/zp_02, as stage1_boss_shift_upper_lines
; does without bending. The attacks bend toward a target value
; (stage1_boss_bend_toward_30, stage1_boss_bend_toward_10).
stage1_boss_inc_bend:
	inc	a:boss_work_5
	ldy	#$0000
	bra	stage1_boss_step_upper_lines
stage1_boss_dec_bend:
	dec	a:boss_work_5
	ldy	#$0038
stage1_boss_step_upper_lines:
	phx
	ldx	#$0000
	lda	#$0020
stage1_boss_step_hdma_lines:
	sta	zp_08
@loop:
	clc
	lda	f:$7EA0C6,x
	adc	a:stage1_boss_hdma_line_steps_sub,y
	sta	zp_04
	lda	f:$7EA046,x
	adc	a:stage1_boss_hdma_line_steps,y
	and	#$00FF
	sta	zp_06
	clc
	lda	zp_04
	adc	zp_00
	sta	f:$7EA0C6,x
	lda	zp_06
	adc	zp_02
	and	#$00FF
	ora	#$4000
	sta	f:$7EA046,x
	iny
	iny
	inx
	inx
	cpx	zp_08
	bcc	@loop
	plx
	rts

stage1_boss_add_height:
	clc
	lda	a:boss_work_2
	adc	zp_00
	sta	a:boss_work_2
	lda	a:boss_work_3
	adc	zp_02
	sta	a:boss_work_3
	rts

stage1_boss_set_bg2_scroll:
	sec
	lda	#$01C0
	sbc	a:obj_slots+4*OBJ_SIZE+OBJ_X
	sta	a:bg2_x
	sec
	lda	#$009C
	sbc	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	sta	a:bg2_y
stage1_boss_place_at_body:
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_X
	adc	#$FFE0
	sta	$0A,x
	lda	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	adc	#$001C
	sta	$0E,x
	rts

; The boss's hitbox objects, slots $0400-$0480: type $29 (body, OBJ_HP 352
; on every difficulty), $1F (head), $20 (shell, HP stage1_boss_shell_hp:
; 128, 256, and $7FFF on hard, so on hard the shell can't really be
; destroyed).
spawn_stage1_boss_parts:
	phx
	ldx	#$0400
	ldy	#$0000
@loop:
	lda	a:stage1_boss_part_types,y
	sta	$10,x
	lda	a:stage1_boss_part_flags,y
	sta	$16,x
	lda	a:stage1_boss_part_hitbox_w,y
	sta	$28,x
	lda	a:stage1_boss_part_hitbox_h,y
	sta	$2A,x
	lda	a:stage1_boss_part_x,y
	sta	$0A,x
	lda	#$0180
	sta	$0E,x
	iny
	iny
	txa
	clc
	adc	#$0040
	tax
	cpy	#$0006
	bcc	@loop
	ldy	difficulty
	lda	#ENEMY_HP($0160)
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_HP
	lda	a:stage1_boss_shell_hp,y
	sta	a:obj_slots+10*OBJ_SIZE+OBJ_HP
	plx
	rts

stage1_boss_build_head_hdma:
	lda	a:boss_work_1
	and	#$01F8
	ora	#$4000
	phx
	ldx	#$0000
@loop:
	sta	f:$7EA006,x
	inx
	inx
	cpx	#$0020
	bcc	@loop
	lda	a:boss_work_1
	bit	#$0100
	beq	@done
	and	#$00F8
	lsr	a
	lsr	a
	lsr	a
	sta	zp_00
	lda	#$00F8
	dex
	dex
@loop2:
	dec	zp_00
	bmi	@done
	clc
	adc	#$0008
	and	#$01F8
	ora	#$4100
	sta	f:$7EA006,x
	dex
	dex
	bra	@loop2
@done:
	plx
	rts

; Keeps the hitbox objects ($0400 body, $0440 head, $0300) where the HDMA
; tables put the BG drawing.
stage1_boss_place_parts:
	sep	#$20
	.a8
	sec
	lda	#$B8
	sbc	f:scroll_hdma_tables+$68
	sta	a:obj_slots+8*OBJ_SIZE+OBJ_Y
	stz	a:obj_slots+8*OBJ_SIZE+OBJ_Y+1
	sec
	lda	#$90
	sbc	f:scroll_hdma_tables+$56
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	stz	a:obj_slots+9*OBJ_SIZE+OBJ_Y+1
	sec
	lda	#$60
	sbc	a:boss_work_1
	sta	a:obj_slots+9*OBJ_SIZE+OBJ_X
	stz	a:obj_slots+9*OBJ_SIZE+OBJ_X+1
	sec
	lda	#$9C
	sbc	f:scroll_hdma_tables+$70
	sta	a:obj_slots+4*OBJ_SIZE+OBJ_Y
	rep	#$20
	.a16
	brl	stage1_boss_place_at_body

spawn_stage1_boss_falling_debris:
	ldy	#$0018
	ldx	#$0600
@loop:
	lda	a:stage1_boss_debris_y,y
	sta	$0E,x
	lda	#$00D0
	sta	$0A,x
	lda	#OBJT_FALLING_DEBRIS
	sta	$10,x
	lda	#$0003
	sta	$16,x
	lda	a:stage1_boss_debris_sprites,y
	sta	$00,x
	lda	a:stage1_boss_debris_x_vels,y
	sta	$1A,x
	stz	$1E,x
	lda	#$3800
	sta	$02,x
	dey
	dey
	bne	@next
	rts
@next:
	clc
	txa
	adc	#$0040
	tax
	bra	@loop

stage1_boss_fire_tracking_shot:
	lda	stage_frame_counter
	bit	#$0040
	beq	stage1_boss_shot_return
	lda	stage_frame_mod8
	bne	stage1_boss_shot_return
	ldy	#$0500
	jsl	f:find_free_slot_from_y
	bcs	stage1_boss_shot_return
	phx
	lda	#OBJT_STAGE1_BOSS_TRACKING_SHOT
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$2800
	sta	a:$0002,y
	lda	#.loword(anim_05AB14)
	sta	a:$0020,y
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_Y
	adc	#$FFE8
	sta	a:$000E,y
	lda	a:obj_slots+10*OBJ_SIZE+OBJ_X
	adc	#$0010
	sta	a:$000A,y
	lda	rng_lo
	sta	a:$001C,x
	lda	#$FFFF	; [num]
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2	; [num]
	sta	a:$002A,y
	plx
stage1_boss_shot_return:
	rts

stage1_boss_fire_falling_shot:
	lda	stage_frame_counter
	bit	#$000F
	bne	stage1_boss_shot_return
	ldy	#$0500
	jsl	f:find_free_slot_from_y
	bcs	@return
	phx
	lda	#OBJT_STAGE1_BOSS_FALLING_SHOT
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$2800
	sta	a:$0002,y
	lda	#.loword(anim_05AAFA)
	sta	a:$0020,y
	lda	#$0001
	sta	a:$0004,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	sta	a:$000E,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_X
	adc	#$0008
	sta	a:$000A,y
	lda	#$0001
	sta	a:$0006,y
	lda	rng_lo
	and	#$0003
	asl	a
	tax
	lda	a:stage1_boss_falling_shot_x_vel_subs,x
	sta	a:$0018,y
	lda	#$FFFF	; [num]
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2	; [num]
	sta	a:$002A,y
	lda	#$FFFF	; [num]
	sta	a:$001E,y
	plx
@return:
	rts

; Object type $26: stage 1 boss projectile that follows the player's height
; (speed stage1_boss_tracking_shot_accels by difficulty).
update_stage1_boss_tracking_shot:
	lda	OBJ_HP,x
	bpl	@alive
	lda	#$000C
	jsl	f:queue_sound
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
@alive:
	lda	rng_temp
	cmp	#$0002
	bcc	@jitter_up
	inc	$0E,x
	bra	@target_player
@jitter_up:
	dec	$0E,x
@target_player:
	ldy	#$0200
	txa
	and	#$0040
	beq	@compare_height
	ldy	#$0240
@compare_height:
	lda	a:$000E,y
	ldy	difficulty
	cmp	$0E,x
	bpl	@accel_down
	sec
	lda	$1C,x
	sbc	a:stage1_boss_tracking_shot_accels,y
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rtl
@accel_down:
	clc
	lda	$1C,x
	adc	a:stage1_boss_tracking_shot_accels,y
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $27: stage 1 boss projectile that falls, then rolls on the
; floor.
update_stage1_boss_falling_shot:
	lda	OBJ_HP,x
	bpl	@alive
	lda	#$000C
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
@alive:
	lda	$12,x
	bne	@not_falling
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@fall
	jsl	f:snap_y_up_to_tile
	inc	$12,x
	lda	#$FFFE	; [num]
	sta	$1E,x
	rtl
@fall:
	clc
	lda	$1C,x
	adc	#$1800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
@bounce:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	@fall
	jsl	f:snap_y_up_to_tile
	inc	$12,x
	stz	$1E,x
	stz	$1C,x
	stz	$04,x
	rtl
@not_falling:
	cmp	#$0001
	beq	@bounce
	rtl

stage1_boss_spawn_fire:
	lda	$3A,x
	bne	@return
	inc	$3A,x
	lda	#.loword(anim_05AB14)
	ldy	#$0500
	jsl	f:spawn_effect
	bcs	@return
	lda	#OBJT_STAGE1_BOSS_FIRE
	sta	a:$0010,y
	lda	#$1200
	sta	a:$0002,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_X
	adc	#$0010
	sta	a:$000A,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	adc	#$FFFC
	sta	a:$000E,y
	lda	#$0080
	sta	a:$0024,y
	sta	a:$0004,y
@return:
	rts

stage1_boss_spawn_fire_stream_shot:
	lda	#.loword(anim_05AB22)
	ldy	#$0500
	jsl	f:spawn_effect
	bcs	@return
	lda	#$000F
	sta	a:$0016,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_X
	adc	#$0010
	sta	a:$000A,y
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	adc	#$FFFC
	sta	a:$000E,y
	lda	#$FFF0	; [num]
	sta	a:$001A,y
	lda	#$001C
	sta	a:$0028,y
	lda	#$FFF8	; [num]
	sta	a:$002A,y
@return:
	rts

; Object type $1F: stage 1 boss, the head (invulnerable target in slot $0440;
; seen in the emulator): pushed back while it is hit (boss_work_1
; down to $E0), else it comes out again (up to $100, or $130 while
; OBJ_TIMER is set).
update_stage1_boss_head:
	lda	OBJ_HIT,x
	bne	@hit
	ldy	#$0130
	lda	OBJ_TIMER,x
	bne	@move_out
	ldy	#$0100
	lda	a:boss_work_1
	cmp	#$0100
	bcs	@move_back
@move_out:
	sty	zp_00
	lda	a:boss_work_1
	clc
	adc	#$0004
	cmp	zp_00
	bcc	@set_out_pos
	lda	zp_00
@set_out_pos:
	sta	a:boss_work_1
	rtl
@hit:
	lda	a:boss_work_1
	ldy	#$00E0
@move_back:
	sty	zp_00
	sec
	sbc	#$000C
	cmp	zp_00
	bcs	@set_back_pos
	lda	zp_00
@set_back_pos:
	sta	a:boss_work_1
	rtl

; Object type $29: stage 1 boss (the giant turtle), main body with HP $160
; (352); fires at the player every stage1_boss_fire_intervals[difficulty] + rnd frames.
update_stage1_boss:
	dec	$34,x
	bpl	@fire_done
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:stage1_boss_fire_intervals,y
	sta	$34,x
	lda	OBJ_Y,x
	adc	#$FFF8
	sta	zp_02
	lda	OBJ_X,x
	adc	#$0010
	sta	zp_00
	jsl	f:fire_bullet_at_player
@fire_done:
	lda	$26,x
	beq	@check_hp
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0060
	sta	cgram_upload_addr
	lda	#$000F
	jsl	f:queue_sound
@check_hp:
	lda	$06,x
	bpl	stage1_boss_play_hit_sound
	lda	#$0100
	sta	a:obj_slots+28*OBJ_SIZE+$32
	lda	#$0110
	sta	a:obj_slots+28*OBJ_SIZE+$3E
	lda	#$0006
	sta	a:obj_slots+28*OBJ_SIZE+$36
	stz	a:obj_slots+9*OBJ_SIZE+OBJ_TIMER
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$C540	; [num] WRAM $7E:C540, the tiles queue_vram_block copies
	sta	zp_00
	ldy	#$0010
	lda	#$4E94
	jml	f:queue_vram_block_at_y

; Object type $20: stage 1 boss (the giant turtle), a part with HP 256:
; explodes when destroyed or when the boss dies (obj_slots+28*OBJ_SIZE+$32).
update_stage1_boss_part:
	sec
	lda	#$0060
	sbc	f:scroll_hdma_tables+$68
	and	#$00FF
	sta	a:$000E,x
	lda	OBJ_STATE,x
	bne	stage1_boss_part_exploding
	lda	a:obj_slots+28*OBJ_SIZE+$32
	bne	@explode
	lda	OBJ_HP,x
	bpl	stage1_boss_play_hit_sound
@explode:
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x
	inc	$12,x
	lda	#$C480	; [num]
	sta	zp_00
	ldy	#$0008
	lda	#$4D14
	jml	f:queue_vram_block_at_y
stage1_boss_play_hit_sound:
	lda	$14,x
	beq	@return
	lda	#$000F
	jml	f:queue_sound
@return:
	rtl
stage1_boss_part_exploding:
	dec	$24,x
	bne	@spawn_debris
	lda	#$8000	; [num]
	sta	$16,x
@spawn_debris:
	lda	stage_frame_mod8
	bne	stage1_boss_play_hit_sound
	lda	$0A,x
	sta	zp_00
	lda	$0E,x
	sta	zp_02
	lda	#$001F
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0500
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#.loword(anim_05C516)
	sta	a:$0020,y
	phx
	lda	rng_lo
	and	#$000E
	tax
	lda	a:random_debris_vel_subs,x
	sta	a:$0018,y
	lda	a:random_debris_vels,x
	sta	a:$001A,y
	plx
	lda	#$FFFE	; [num]
	sta	a:$001E,y
@return:
	rtl

; Object type $22: stage 1 boss, chunks of the metal wall it bursts through
; (slots $0300-$03C0, spawn_stage1_boss_wall_chunks; seen in the emulator).
update_stage1_boss_wall_chunk:
	lda	$30,x
	beq	@animate
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
@animate:
	inc	$24,x
	ldy	#$0000
	lda	$24,x
	and	#$001F
	cmp	#$0006
	bcc	@which_chunk
	ldy	#$0002
@which_chunk:
	cpx	#$03C0
	bne	@set_sprite
	iny
	iny
	iny
	iny
@set_sprite:
	lda	a:stage1_boss_wall_chunk_sprites,y
	sta	$00,x
	rtl

; Object type $23: falling wall debris (stage 1 boss, the turtle breaking
; through the wall); explodes at y >= $C8.
update_falling_debris:
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	@fall
	lda	#$FFFC	; [num]
	sta	OBJ_Y_VEL,x
	txy
	lda	#.loword(anim_05C69C)
	jml	f:make_effect_object
@fall:
	clc
	lda	$1C,x
	adc	#$3000
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $38: stage 1 boss fire breath (spawned near the boss by
; stage1_boss_spawn_fire).
update_stage1_boss_fire:
	dec	OBJ_TIMER,x
	bne	@follow_head
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
@follow_head:
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_X
	sta	$0A,x
	lda	a:obj_slots+9*OBJ_SIZE+OBJ_Y
	adc	#$FFFC
	sta	$0E,x
	lda	stage_frame_counter
	and	#$0004
	lsr	a
	xba
	ora	#$3000
	sta	$02,x
	rtl
