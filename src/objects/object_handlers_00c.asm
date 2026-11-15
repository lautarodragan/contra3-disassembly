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
	beq	loc_00F290
	dec	a
	bne	loc_00F28A
	dec	a
	ldy	#$0100
	sty	a:stage_exit_request
loc_00F28A:
	sta	$32,x
	jsl	f:make_players_invulnerable
loc_00F290:
	inc	a:boss_work_0
	ldy	#$0012
	lda	stage_frame_mod8
	cmp	#$0005
	bcs	loc_00F2A0
	ldy	#$0000
loc_00F2A0:
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
	lda	#$A000
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
	bmi	loc_00F322
	dec	OBJ_TIMER,x
	bpl	loc_00F34B
loc_00F322:
	lda	a:song_change_state
	bne	loc_00F34B
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
loc_00F34B:
	rtl

stage1_boss_controller_state_03:
	dec	OBJ_TIMER,x
	beq	loc_00F362
	phx
	jsr	a:spawn_stage1_boss_falling_debris
	plx
	ldy	#.loword(vram_blocks_05AAB8)
	lda	#$4018
	sta	zp_0C
	lda	#$0040
	bra	loc_00F383
loc_00F362:
	inc	$12,x
	lda	#$003C
	sta	$16,x
	lda	#$0180
	sta	$0A,x
	lda	#$0080
	sta	$28,x
	lda	#$FFA0
	sta	$2A,x
	ldy	#$AAC8
	lda	#$4218
	sta	zp_0C
	lda	#$0030
loc_00F383:
	sta	zp_08
	lda	a:bg1_x
	bit	#$0100
	beq	loc_00F395
	clc
	lda	zp_0C
	adc	#$0400
	sta	zp_0C
loc_00F395:
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
	bne	loc_00F3B1
	inc	$12,x
	lda	#$0010
	sta	$24,x
loc_00F3B1:
	jsr	a:stage1_boss_place_middle_chunks
	jsr	a:stage1_boss_set_bg2_scroll
	rtl

stage1_boss_controller_state_05:
	dec	OBJ_TIMER,x
	bne	loc_00F3DF
	lda	#$0006
	sta	hdma_preset
	inc	OBJ_STATE,x
	lda	#$0020
	sta	a:boss_work_0
	stz	$36,x
	lda	#$0080
	sta	$38,x
	lda	#$0080
	sta	a:wram_0474
	lda	#$0100
	sta	a:boss_work_1
	jsr	a:spawn_stage1_boss_parts
loc_00F3DF:
	dec	a:wram_030E
	jsr	a:stage1_boss_place_middle_chunks
	jsr	a:stage1_boss_set_bg2_scroll
	rtl

stage1_boss_controller_state_06:
	lda	a:boss_work_3
	cmp	#$0020
	bne	loc_00F405
	lda	$32,x
	bne	loc_00F3FC
	lda	rng_lo
	bit	#$003F
	bne	loc_00F405
loc_00F3FC:
	lda	#$0003
	sta	a:boss_work_4
	inc	$12,x
	rtl
loc_00F405:
	lda	#$2000
	sta	zp_00
	stz	zp_02
	jsr	a:stage1_boss_sway
	jsr	a:stage1_boss_run_attack
	brl	loc_00F46D

stage1_boss_controller_state_07:
	lda	a:boss_work_3
	cmp	#$0007
	bcs	loc_00F42D
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0004
	sta	a:shake_timer
	inc	$12,x
	rtl
loc_00F42D:
	stz	zp_00
	lda	#$0002
	sta	zp_02
	jsr	a:stage1_boss_move_down
	jsr	a:stage1_boss_run_attack
	brl	loc_00F46D

stage1_boss_controller_state_08:
	lda	a:boss_work_3
	cmp	#$0020
	bcc	loc_00F45D
	dec	a:boss_work_4
	bne	loc_00F45A
	lda	$32,x
	bne	loc_00F45A
	lda	#$0020
	sta	a:boss_work_0
	lda	#$0006
	sta	OBJ_STATE,x
	rtl
loc_00F45A:
	dec	$12,x
	rtl
loc_00F45D:
	stz	zp_00
	lda	#$0002
	sta	zp_02
	jsr	a:stage1_boss_move_up
	jsr	a:stage1_boss_run_attack
	brl	loc_00F46D
loc_00F46D:
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
	lda	#$FFFD
	sta	a:$001E,y
@return:
	rts

stage1_boss_queue_face_tiles:
	ldy	#.loword(vram_blocks_05AB28)
	lda	$3E,x
	beq	loc_00F4C3
	dec	$3E,x
	ldy	#.loword(vram_blocks_05AB30)
loc_00F4C3:
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
	lda	#$A000
	sta	zp_00
	lda	#$0020
	sta	zp_E2
	lda	#$5E00
	jml	f:loc_00F4EB
loc_00F4EB:
	ldy	#$0000
	sta	a:$1800,y
	clc
	adc	#$0010
	sta	a:$1802,y
	clc
	adc	#$0010
	sta	a:$1804,y
	clc
	adc	#$0010
	sta	a:$1806,y
	lda	zp_00
	sta	a:$1840,y
	clc
	lda	zp_B6
	adc	#$0008
	sta	zp_B6
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
	lda	#$FFE5
	sta	$2A,x
	stz	$30,x
	lda	a:data_05AA50,y
	sta	$0A,x
	lda	a:data_05AA58,y
	sta	$0E,x
	lda	a:data_05AA60,y
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
	beq	loc_00F572
	dec	$24,x
	bne	@return
	lda	$30,x
	eor	#$0002
	sta	$30,x
	lda	#$0020
	sta	a:boss_work_7
	brl	loc_00F5B1
@return:
	rts
loc_00F572:
	dec	a:boss_work_7
	bpl	@return
	lda	#$0020
	sta	$24,x
	stz	a:wram_0318
	stz	a:wram_031A
	stz	a:wram_031C
	stz	a:wram_031E
	stz	a:wram_0330
	stz	a:wram_03D8
	stz	a:wram_03DA
	stz	a:wram_03DC
	stz	a:wram_03DE
	stz	a:wram_03F0
	lda	#$0004
	sta	a:shake_timer
	lda	#$0056
	jsl	f:queue_sound
	lda	#$0056
	jsl	f:queue_sound
	dec	$34,x
@return:
	rts
loc_00F5B1:
	phx
	lda	$30,x
	bne	loc_00F5BB
	ldx	#$0300
	bra	loc_00F5BE
loc_00F5BB:
	ldx	#$03C0
loc_00F5BE:
	lda	#$4000
	sta	$18,x
	lda	#$FFFE
	sta	$1A,x
	lda	#$0000
	sta	$1C,x
	lda	#$FFFF
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
	lda	a:wram_030A
	sbc	a:wram_03CA
	bpl	loc_00F5E9
	eor	#$FFFF
	inc	zp_00
loc_00F5E9:
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
	lda	a:wram_030E
	sbc	a:wram_03CE
	bpl	loc_00F608
	eor	#$FFFF
	inc	zp_02
loc_00F608:
	and	#$00FF
	pha
	lda	a:RDDIVL
	ldy	zp_00
	bne	loc_00F616
	eor	#$FFFF
loc_00F616:
	sta	zp_00
	clc
	lda	a:wram_030A
	adc	zp_00
	adc	#$0000
	sta	a:wram_034A
	clc
	adc	zp_00
	adc	#$0000
	sta	a:wram_038A
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
	bne	loc_00F64C
	; (not executed in the CDL traces)
	eor	#$FFFF
loc_00F64C:
	sta	zp_02
	clc
	lda	a:wram_030E
	adc	zp_02
	sta	a:wram_034E
	clc
	adc	zp_02
	sta	a:wram_038E
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
	bcs	loc_00F69A
	brl	loc_00F882
loc_00F69A:
	brl	loc_00F88A

stage1_boss_attack_fire:
	lda	#$0002
	sta	$3E,x
	dec	$38,x
	bne	loc_00F6B6
	lda	#$0025
	jsl	f:queue_sound
	inc	$36,x
	ldy	difficulty
	lda	a:data_05AB52,y
	sta	$38,x
loc_00F6B6:
	jsr	a:stage1_boss_spawn_fire
	ldy	a:boss_work_5
	cpy	#$001C
	bcs	loc_00F6C4
	brl	loc_00F882
loc_00F6C4:
	brl	loc_00F88A

stage1_boss_attack_fire_stream:
	lda	#$0002
	sta	$3E,x
	lda	#$0001
	sta	a:shake_continuous
	dec	$38,x
	bne	loc_00F6DD
	stz	$36,x
	lda	#$0100
	sta	$38,x
loc_00F6DD:
	jsr	a:stage1_boss_spawn_fire_stream_shot
	brl	loc_00F828

stage1_boss_attack_falling_shots:
	lda	stage_frame_mod8
	bne	loc_00F6EC
	lda	#$0004
	sta	$3E,x
loc_00F6EC:
	dec	$38,x
	bne	loc_00F6F7
	stz	$36,x
	lda	#$0080
	sta	$38,x
loc_00F6F7:
	jsr	a:stage1_boss_fire_falling_shot
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0010
	bne	loc_00F710
loc_00F705:
	cpy	#$0030
	bcs	loc_00F70D
	brl	loc_00F882
loc_00F70D:
	brl	loc_00F88A
loc_00F710:
	cpy	#$0010
	bcc	loc_00F718
	brl	loc_00F88A
loc_00F718:
	; (not executed in the CDL traces)
	brl	loc_00F882

stage1_boss_attack_tracking_shots:
	lda	a:boss_work_0
	and	#$0040
	beq	loc_00F728
	lda	#$0002
	sta	$3E,x
loc_00F728:
	dec	$38,x
	bne	loc_00F733
	stz	$36,x
	lda	#$0040
	sta	$38,x
loc_00F733:
	jsr	a:stage1_boss_fire_tracking_shot
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0020
	bne	loc_00F74C
	cpy	#$0024
	bcs	loc_00F749
	brl	loc_00F882
loc_00F749:
	brl	loc_00F88A
loc_00F74C:
	cpy	#$0010
	bcc	loc_00F754
	brl	loc_00F88A
loc_00F754:
	brl	loc_00F882

stage1_boss_attack_03:
	lda	stage_frame_counter
	bit	#$001F
	bne	loc_00F763
	lda	#$0004
	sta	$3E,x
loc_00F763:
	dec	$38,x
	bne	loc_00F771
	stz	$36,x
	lda	#$0080
	sta	$38,x
	stz	a:wram_0464
loc_00F771:
	ldy	a:boss_work_5
	lda	$38,x
	bit	#$0080
	bne	loc_00F78F
	lda	a:p1_lives
	bne	loc_00F783
	; (not executed in the CDL traces)
	brl	loc_00F797
loc_00F783:
	sec
	lda	a:wram_020E
	sbc	a:wram_044E
	bcs	loc_00F7A3
	brl	loc_00F705
loc_00F78F:
	lda	a:p2_lives
	bne	loc_00F797
	brl	loc_00F783
loc_00F797:
	; (not executed in the CDL traces)
	sec
	lda	a:wram_024E
	sbc	a:wram_044E
	bcs	loc_00F7A3
	brl	loc_00F705
loc_00F7A3:
	cpy	#$0008
	bcc	loc_00F7AB
	brl	loc_00F88A
loc_00F7AB:
	; (not executed in the CDL traces)
	brl	loc_00F882

stage1_boss_attack_choose:
	dec	$38,x
	bne	loc_00F80A
	lda	rng_lo
	bit	#$0003
	beq	loc_00F7DD
	bit	#$0001
	bne	loc_00F7C6
	ldy	#$00C0
	lda	#$0001
	bra	loc_00F806
loc_00F7C6:
	lda	#$0057
	jsl	f:queue_sound
	lda	a:wram_0490
	cmp	#$0020
	bne	loc_00F7E2
	ldy	#$0080
	lda	#$0002
	bra	loc_00F806
loc_00F7DD:
	bit	#$0008
	bne	loc_00F7F3
loc_00F7E2:
	lda	#$0057
	jsl	f:queue_sound
	stz	$3A,x
	ldy	#$0080
	lda	#$0004
	bra	loc_00F806
loc_00F7F3:
	lda	#$0057
	jsl	f:queue_sound
	lda	#$0001
	sta	a:wram_0464
	ldy	#$0100
	lda	#$0003
loc_00F806:
	sta	$36,x
	sty	$38,x
loc_00F80A:
	ldy	a:boss_work_5
	lda	a:boss_work_0
	and	#$0010
	bne	loc_00F820
	cpy	#$0024
	bcs	loc_00F81D
	brl	loc_00F882
loc_00F81D:
	brl	loc_00F828
loc_00F820:
	cpy	#$0010
	bcc	loc_00F828
	brl	loc_00F88A
loc_00F828:
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
	bra	loc_00F876

stage1_boss_move_up:
	ldy	#$0020
	bra	loc_00F879
loc_00F876:
	ldy	#$0058
loc_00F879:
	phx
	ldx	#$0020
	lda	#$003A
	bra	loc_00F897
loc_00F882:
	inc	a:boss_work_5
	ldy	#$0000
	bra	loc_00F890
loc_00F88A:
	dec	a:boss_work_5
	ldy	#$0038
loc_00F890:
	phx
	ldx	#$0000
	lda	#$0020
loc_00F897:
	sta	zp_08
@loop:
	clc
	lda	f:$7EA0C6,x
	adc	a:data_05921A,y
	sta	zp_04
	lda	f:$7EA046,x
	adc	a:data_0591AA,y
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
	sbc	a:wram_030A
	sta	a:bg2_x
	sec
	lda	#$009C
	sbc	a:wram_030E
	sta	a:bg2_y
loc_00F8F6:
	lda	a:wram_030A
	adc	#$FFE0
	sta	$0A,x
	lda	a:wram_030E
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
	lda	a:data_05AADA,y
	sta	$10,x
	lda	a:data_05AAD4,y
	sta	$16,x
	lda	a:data_05AAE0,y
	sta	$28,x
	lda	a:data_05AAE6,y
	sta	$2A,x
	lda	a:data_05AAEC,y
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
	sta	a:wram_0406
	lda	a:stage1_boss_shell_hp,y
	sta	a:wram_0486
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
	beq	loc_00F98C
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
	bmi	loc_00F98C
	clc
	adc	#$0008
	and	#$01F8
	ora	#$4100
	sta	f:$7EA006,x
	dex
	dex
	bra	@loop2
loc_00F98C:
	plx
	rts

; Keeps the hitbox objects ($0400 body, $0440 head, $0300) where the HDMA
; tables put the BG drawing.
stage1_boss_place_parts:
	sep	#$20
	.a8
	sec
	lda	#$B8
	sbc	f:wram_7EA068
	sta	a:wram_040E
	stz	a:wram_040F
	sec
	lda	#$90
	sbc	f:wram_7EA056
	sta	a:wram_044E
	stz	a:wram_044F
	sec
	lda	#$60
	sbc	a:boss_work_1
	sta	a:wram_044A
	stz	a:wram_044B
	sec
	lda	#$9C
	sbc	f:wram_7EA070
	sta	a:wram_030E
	rep	#$20
	.a16
	brl	loc_00F8F6

spawn_stage1_boss_falling_debris:
	ldy	#$0018
	ldx	#$0600
loc_00F9CB:
	lda	a:data_05AA68,y
	sta	$0E,x
	lda	#$00D0
	sta	$0A,x
	lda	#OBJT_FALLING_DEBRIS
	sta	$10,x
	lda	#$0003
	sta	$16,x
	lda	a:data_05AA80,y
	sta	$00,x
	lda	a:data_05AA98,y
	sta	$1A,x
	stz	$1E,x
	lda	#$3800
	sta	$02,x
	dey
	dey
	bne	loc_00F9F5
	rts
loc_00F9F5:
	clc
	txa
	adc	#$0040
	tax
	bra	loc_00F9CB

stage1_boss_fire_tracking_shot:
	lda	stage_frame_counter
	bit	#$0040
	beq	loc_00FA54
	lda	stage_frame_mod8
	bne	loc_00FA54
	ldy	#$0500
	jsl	f:find_free_slot_from_y
	bcs	loc_00FA54
	phx
	lda	#OBJT_STAGE1_BOSS_TRACKING_SHOT
	sta	a:$0010,y
	lda	#$001F
	sta	a:$0016,y
	lda	#$2800
	sta	a:$0002,y
	lda	#.loword(anim_05AB14)
	sta	a:$0020,y
	lda	a:wram_048E
	adc	#$FFE8
	sta	a:$000E,y
	lda	a:wram_048A
	adc	#$0010
	sta	a:$000A,y
	lda	rng_lo
	sta	a:$001C,x
	lda	#$FFFF
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2
	sta	a:$002A,y
	plx
loc_00FA54:
	rts

stage1_boss_fire_falling_shot:
	lda	stage_frame_counter
	bit	#$000F
	bne	loc_00FA54
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
	lda	a:wram_044E
	sta	a:$000E,y
	lda	a:wram_044A
	adc	#$0008
	sta	a:$000A,y
	lda	#$0001
	sta	a:$0006,y
	lda	rng_lo
	and	#$0003
	asl	a
	tax
	lda	a:data_05AAF2,x
	sta	a:$0018,y
	lda	#$FFFF
	sta	a:$001A,y
	lda	#$000E
	sta	a:$0028,y
	lda	#$FFF2
	sta	a:$002A,y
	lda	#$FFFF
	sta	a:$001E,y
	plx
@return:
	rts

; Object type $26: stage 1 boss projectile that follows the player's height
; (speed data_05AB46 by difficulty).
update_stage1_boss_tracking_shot:
	lda	OBJ_HP,x
	bpl	loc_00FAD3
	lda	#$000C
	jsl	f:queue_sound
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
loc_00FAD3:
	lda	rng_temp
	cmp	#$0002
	bcc	loc_00FADE
	inc	$0E,x
	bra	loc_00FAE0
loc_00FADE:
	dec	$0E,x
loc_00FAE0:
	ldy	#$0200
	txa
	and	#$0040
	beq	loc_00FAEC
	ldy	#$0240
loc_00FAEC:
	lda	a:$000E,y
	ldy	difficulty
	cmp	$0E,x
	bpl	loc_00FB05
	sec
	lda	$1C,x
	sbc	a:data_05AB46,y
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	rtl
loc_00FB05:
	clc
	lda	$1C,x
	adc	a:data_05AB46,y
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl

; Object type $27: stage 1 boss projectile that falls, then rolls on the
; floor.
update_stage1_boss_falling_shot:
	lda	OBJ_HP,x
	bpl	loc_00FB2A
	lda	#$000C
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
loc_00FB2A:
	lda	$12,x
	bne	loc_00FB6B
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	loc_00FB44
	jsl	f:snap_y_up_to_tile
	inc	$12,x
	lda	#$FFFE
	sta	$1E,x
	rtl
loc_00FB44:
	clc
	lda	$1C,x
	adc	#$1800
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	rtl
loc_00FB54:
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	beq	loc_00FB44
	jsl	f:snap_y_up_to_tile
	inc	$12,x
	stz	$1E,x
	stz	$1C,x
	stz	$04,x
	rtl
loc_00FB6B:
	cmp	#$0001
	beq	loc_00FB54
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
	lda	a:wram_044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:wram_044E
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
	lda	a:wram_044A
	adc	#$0010
	sta	a:$000A,y
	lda	a:wram_044E
	adc	#$FFFC
	sta	a:$000E,y
	lda	#$FFF0
	sta	a:$001A,y
	lda	#$001C
	sta	a:$0028,y
	lda	#$FFF8
	sta	a:$002A,y
@return:
	rts

; Object type $1F: stage 1 boss, the head (invulnerable target in slot $0440;
; seen in the emulator): pushed back while it is hit (boss_work_1
; down to $E0), else it comes out again (up to $100, or $130 while
; OBJ_TIMER is set).
update_stage1_boss_head:
	lda	OBJ_HIT,x
	bne	loc_00FC0B
	ldy	#$0130
	lda	OBJ_TIMER,x
	bne	loc_00FBF8
	ldy	#$0100
	lda	a:boss_work_1
	cmp	#$0100
	bcs	loc_00FC11
loc_00FBF8:
	sty	zp_00
	lda	a:boss_work_1
	clc
	adc	#$0004
	cmp	zp_00
	bcc	loc_00FC07
	lda	zp_00
loc_00FC07:
	sta	a:boss_work_1
	rtl
loc_00FC0B:
	lda	a:boss_work_1
	ldy	#$00E0
loc_00FC11:
	sty	zp_00
	sec
	sbc	#$000C
	cmp	zp_00
	bcs	loc_00FC1D
	lda	zp_00
loc_00FC1D:
	sta	a:boss_work_1
	rtl

; Object type $29: stage 1 boss (the giant turtle), main body with HP $160
; (352); fires at the player every data_05AB4C[difficulty] + rnd frames.
update_stage1_boss:
	dec	$34,x
	bpl	loc_00FC43
	ldy	difficulty
	lda	rng_lo
	and	#$007F
	adc	a:data_05AB4C,y
	sta	$34,x
	lda	OBJ_Y,x
	adc	#$FFF8
	sta	zp_02
	lda	OBJ_X,x
	adc	#$0010
	sta	zp_00
	jsl	f:fire_bullet_at_player
loc_00FC43:
	lda	$26,x
	beq	loc_00FC58
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	lda	#$0060
	sta	cgram_upload_addr
	lda	#$000F
	jsl	f:queue_sound
loc_00FC58:
	lda	$06,x
	bpl	loc_00FCBD
	lda	#$0100
	sta	a:wram_0932
	lda	#$0110
	sta	a:wram_093E
	lda	#$0006
	sta	a:wram_0936
	stz	a:wram_0464
	lda	#$8000
	sta	$16,x
	lda	#.loword(anim_05C540)
	sta	zp_00
	ldy	#$0010
	lda	#$4E94
	jml	f:loc_00FE7D

; Object type $20: stage 1 boss (the giant turtle), a part with HP 256:
; explodes when destroyed or when the boss dies (wram_0932).
update_stage1_boss_part:
	sec
	lda	#$0060
	sbc	f:wram_7EA068
	and	#$00FF
	sta	a:$000E,x
	lda	OBJ_STATE,x
	bne	loc_00FCC9
	lda	a:wram_0932
	bne	loc_00FCA0
	lda	OBJ_HP,x
	bpl	loc_00FCBD
loc_00FCA0:
	lda	#$0030
	jsl	f:queue_sound
	lda	#$0040
	sta	$24,x
	inc	$12,x
	lda	#$C480
	sta	zp_00
	ldy	#$0008
	lda	#$4D14
	jml	f:loc_00FE7D
loc_00FCBD:
	lda	$14,x
	beq	@return
	lda	#$000F
	jml	f:queue_sound
@return:
	rtl
loc_00FCC9:
	dec	$24,x
	bne	loc_00FCD2
	lda	#$8000
	sta	$16,x
loc_00FCD2:
	lda	stage_frame_mod8
	bne	loc_00FCBD
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
	lda	a:data_05C838,x
	sta	a:$0018,y
	lda	a:data_05C828,x
	sta	a:$001A,y
	plx
	lda	#$FFFE
	sta	a:$001E,y
@return:
	rtl

; Object type $22: stage 1 boss, chunks of the metal wall it bursts through
; (slots $0300-$03C0, spawn_stage1_boss_wall_chunks; seen in the emulator).
update_stage1_boss_wall_chunk:
	lda	$30,x
	beq	loc_00FD25
	clc
	lda	OBJ_Y_VEL_SUB,x
	adc	#$1000
	sta	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y_VEL,x
	adc	#$0000
	sta	OBJ_Y_VEL,x
loc_00FD25:
	inc	$24,x
	ldy	#$0000
	lda	$24,x
	and	#$001F
	cmp	#$0006
	bcc	loc_00FD37
	ldy	#$0002
loc_00FD37:
	cpx	#$03C0
	bne	loc_00FD40
	iny
	iny
	iny
	iny
loc_00FD40:
	lda	a:data_05AAB0,y
	sta	$00,x
	rtl

; Object type $23: falling wall debris (stage 1 boss, the turtle breaking
; through the wall); explodes at y >= $C8.
update_falling_debris:
	lda	OBJ_Y,x
	cmp	#$00C8
	bcc	loc_00FD5A
	lda	#$FFFC
	sta	OBJ_Y_VEL,x
	txy
	lda	#.loword(anim_05C69C)
	jml	f:make_effect_object
loc_00FD5A:
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
	bne	loc_00FD73
	lda	#$8000
	sta	OBJ_FLAGS,x
loc_00FD73:
	lda	a:wram_044A
	sta	$0A,x
	lda	a:wram_044E
	adc	#$FFFC
	sta	$0E,x
	lda	stage_frame_counter
	and	#$0004
	lsr	a
	xba
	ora	#$3000
	sta	$02,x
	rtl
