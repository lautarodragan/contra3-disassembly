; game/stage.asm -- Side-view stage state machine
; Bank $00, $00:BD40-$00:C282. Included by main.asm in segment BANK00.
;
; run_side_view_stage dispatches stage_state (STAGE_STATE_*) through
; tbl_stage_states: stage_init, stage_setup_video, stage_play (one frame:
; stage_frame), stage_exit (fade out) and stage_cinematic (the opening,
; stage 0). Also the per-layout stage start (stage_layout_init) and the
; scripted player input (apply_player_autopilot).

; Side-view stage state machine, state in stage_state (STAGE_STATE_*,
; tbl_stage_states). pause_disabled = 2 on entry (stage_play clears it).
run_side_view_stage:
	rep	#$30
	lda	#$0002
	sta	pause_disabled
	lda	a:stage_state
	phx
	asl	a
	tax
	lda	f:tbl_stage_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage_states:
	.addr	stage_init
	.addr	stage_setup_video
	.addr	stage_play
	.addr	stage_exit
	.addr	stage_cinematic

; STAGE_STATE_INIT: stage_layout from stage_layouts[stage_number] (+$0A
; past the checkpoint), per-layout scroll parameters, the players start
; dead (state $0E, they drop in), colour math and window defaults.
stage_init:
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	inc	a:stage_state
	lda	#$0080
	sta	a:inidisp_shadow
	jsl	f:reset_sound_queue
	ldx	stage_number
	lda	a:stage_layouts,x
	and	#$00FF
	sta	a:stage_layout
	sta	a:stage_layout_base
	ldy	a:stage_checkpoint
	beq	@no_checkpoint
	clc
	adc	#$000A
	sta	a:stage_layout
@no_checkpoint:
	ldy	#.loword(palette_task_058AC7)
	jsl	f:start_palette_task
	ldy	a:stage_layout
	lda	a:stage_bg1_map_offsets,y
	sta	a:bg1_map_offset
	lda	a:stage_bg2_map_offsets,y
	sta	a:bg2_map_offset
	ldy	a:stage_layout_base
	ldx	a:ptrs_stage_dp_params,y
	jsl	f:load_stage_dp_params
	lda	a:stage_respawn_modes,y
	sta	a:respawn_mode
	stz	shake_bg1_y
	stz	shake_bg2_y
	stz	a:shake_continuous
	stz	a:shake_timer
	stz	stage_frame_counter
	lda	#$000E
	sta	a:player1_state
	sta	a:player2_state
	stz	a:clear_enemies_timer
	stz	a:player_autopilot_mode
	stz	a:spawn_disabled
	stz	a:palette_anim_id
	stz	a:palette_anim_timer
	stz	a:life_transfer_disabled
	ldy	a:stage_layout_base
	lda	a:ptrs_stage_palette_tasks,y
	tay
	ldx	#$1210
	jsl	f:start_palette_task_at
	lda	button_fire
	ora	button_stand_still
	sta	a:hang_lock_buttons
	lda	#$005F
	sta	a:bomb_coldata_mask
	lda	#$0020
	sta	a:bomb_coldata_bits
	lda	#$0001
	sta	f:window_hdma_a+$1E
	sta	f:window_hdma_b+$1E
	lda	#$0020
	sta	a:CGWSEL
	sta	a:cgwsel_shadow
	lda	#$003F
	sta	a:CGADSUB
	sta	a:cgadsub_shadow
	lda	#$0022
	sta	a:W12SEL
	sta	a:w12sel_shadow
	lda	#$0203
	sta	a:TMW
	sta	a:tmw_shadow
	lda	#$00E0
	sta	a:COLDATA
	stz	a:coldata_shadow
	lda	#$00FF
	sta	a:wram_1EB0
	stz	a:wram_1EB2
	lda	#$0030
	sta	a:wobjsel_shadow
	stz	a:player1_obj+PLAYER_BOMB_RADIUS
	stz	a:player2_obj+PLAYER_BOMB_RADIUS
	lda	#$0280
	sta	a:homing_target_slot
	stz	a:trail_buffers_used
	stz	a:scroll_split_pattern
	stz	a:song_change_wait
	stz	a:wram_167C
	stz	a:wram_167E
	stz	a:song_change_state
	rtl

; STAGE_STATE_SETUP: BG modes and maps, graphics, stage_layout_init.
; Stage 0 (the opening) goes on to STAGE_STATE_CINEMATIC instead of
; STAGE_STATE_PLAY.
stage_setup_video:
	lda	stage_number
	bne	@not_opening
	inc	a:stage_state
	inc	a:stage_state
@not_opening:
	inc	a:stage_state
	lda	#$0041
	sta	a:bg1sc_shadow
	sta	a:BG1SC
	lda	#$0049
	sta	a:bg2sc_shadow
	sta	a:BG2SC
	lda	#$005C
	sta	a:bg3sc_shadow
	sta	a:BG3SC
	lda	#$0000
	sta	a:BG12NBA
	lda	#$0005
	sta	a:BG34NBA
	lda	#$0003
	sta	a:obsel_shadow
	lda	#$0009
	sta	a:bgmode_shadow
	sta	a:BGMODE
	lda	#$0017
	sta	a:tm_shadow
	lda	#$0002
	sta	a:ts_shadow
	ldx	#.loword(load_list_058ADD)
	jsl	f:load_data_list
	ldx	#.loword(load_list_058AD4)
	jsl	f:load_data_list
	ldy	a:stage_layout
	ldx	a:ptrs_stage_load_lists,y
	jsl	f:load_data_list
	ldx	#$1380
	ldy	#$4000
	jsl	f:fill_bg_screen
	ldx	#$13C0
	ldy	#$A000	; [num]
	jsl	f:fill_bg_screen
	lda	stage_number
	cmp	#$0004
	bne	@not_stage4
	jsl	f:draw_bg3_block_map
@not_stage4:
	jsl	f:init_hud
	jsl	f:stage_layout_init
	stz	a:airship_spawn_index
	jsl	f:init_stage_spawns
	stz	a:inidisp_shadow
	stz	a:stage_exit_request
	stz	a:stage_pause_disabled

; Empties the per-frame VRAM update lists ($1800 list, vram_block_queue_end, bg_dma_vram_addr).
reset_vram_update_queues:
	stz	bg_dma_vram_addr
	stz	vram_block_queue_end
	stz	a:vram_block_queue
	stz	a:vram_block_queue+8
	stz	a:vram_block_queue+16
	stz	a:vram_block_queue+24
	stz	a:vram_block_queue+32
	stz	a:vram_block_queue+40
	stz	a:vram_block_queue+48
	stz	a:vram_block_queue+56
	lda	#$0008
	sta	zp_E2
	stz	cgram_upload_src
	stz	cgram_upload_addr
	rtl

; stage_frame_counter + 1 and its low bits in stage_frame_odd/mod4/mod8/bit1.
update_stage_frame_counters:
	inc	stage_frame_counter
	lda	stage_frame_counter
	and	#$0007
	sta	stage_frame_mod8
	and	#$0003
	sta	stage_frame_mod4
	and	#$0001
	sta	stage_frame_odd
	lda	stage_frame_counter
	and	#$0002
	sta	stage_frame_bit1
	lda	stage_frame_counter
	and	#$0004
	sta	rng_temp
	rts

; STAGE_STATE_EXIT: keeps the stage running while fading out (every 8th
; frame), then stage_state = 0, nmi_mode = 0, mode_result = 1.
stage_exit:
	lda	stage_frame_counter
	bit	#$0007
	bne	stage_frame
	dec	a:inidisp_shadow
	bne	stage_frame
	stz	a:life_transfer_disabled
	stz	a:inidisp_shadow
	stz	hdma_preset
	stz	a:stage_state
	stz	nmi_mode
	lda	#$0001
	sta	mode_result
	rtl

; STAGE_STATE_PLAY: exit when stage_exit_request is set or both players are
; out of lives; else fade in and run one frame (stage_frame).
stage_play:
	lda	a:stage_exit_request
	beq	@not_exiting
	inc	a:stage_state
	rtl
@not_exiting:
	lda	a:stage_pause_disabled
	bne	@fade_in
	stz	pause_disabled
@fade_in:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	stage_frame
	inc	a:inidisp_shadow
	lda	#$0002
	sta	pause_disabled
; One frame of a side-view stage: players, objects (order alternating by
; stage_frame_odd), hides the unused sprites, BG scroll, palette animation.
stage_frame:
	lda	a:p1_lives
	bne	@check_timer_1688
	lda	a:p2_lives
	bne	@check_timer_1688
	lda	#STAGE_STATE_EXIT
	sta	a:stage_state
@check_timer_1688:
	lda	a:clear_enemies_timer
	beq	@frame
	dec	a:clear_enemies_timer
@frame:
	lda	#$0FC0
	sta	oam_ptr
	lda	#$11C0
	sta	oam_hi_ptr
	lda	#$8000	; [num]
	sta	oam_hi_bits
	jsl	f:reset_vram_update_queues
	jsr	a:update_stage_frame_counters
	jsl	f:update_players
	jsl	f:update_shots
	stz	a:player1_obj+PLAYER_CONTACT
	stz	a:player2_obj+PLAYER_CONTACT
	stz	a:player1_obj+PLAYER_PLATFORM
	stz	a:player2_obj+PLAYER_PLATFORM
	lda	a:spawn_disabled
	bne	@objects
	jsl	f:spawn_stage_objects
@objects:
	lda	stage_frame_odd
	bne	@odd_frame
	jsl	f:draw_players
	jsl	f:update_objects
	bra	@hide_unused_sprites
@odd_frame:
	jsl	f:update_objects
	jsl	f:draw_players
@hide_unused_sprites:
	jsl	f:update_objects_0280
	ldy	oam_hi_ptr
	cpy	#$11E0
	bcs	@sprites_done
	ldx	oam_ptr
@loop:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	oam_hi_bits
	lsr	oam_hi_bits
	bcc	@loop
	lda	oam_hi_bits
	sta	a:$0000,y
@loop2:
	cpx	#$11C0
	bcs	@sprites_done
	iny
	iny
	lda	#$0080
	sta	$00,x
	sta	$04,x
	sta	$08,x
	sta	$0C,x
	sta	$10,x
	sta	$14,x
	sta	$18,x
	sta	$1C,x
	lda	#$5555
	sta	a:$0000,y
	txa
	clc
	adc	#$0020
	tax
	bra	@loop2
@sprites_done:
	jsl	f:update_shake_side_view
	jsl	f:update_song_change
	jsl	f:update_palette_anim
	rtl

; Per-layout start of a side-view stage (music, effects): tbl_stage_layout_inits[stage_layout / 2].
stage_layout_init:
	lda	a:stage_layout
	lsr	a
	phx
	asl	a
	tax
	lda	f:tbl_stage_layout_inits,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage_layout_inits:
	.addr	layout_init_stage1
	.addr	layout_init_stage3
	.addr	layout_init_stage4
	.addr	layout_init_stage6
	.addr	layout_init_opening
	.addr	layout_init_stage1_checkpoint
	.addr	layout_init_stage3_checkpoint
	.addr	layout_init_stage4_checkpoint
	.addr	layout_init_stage6
	.addr	layout_init_opening

layout_init_stage1_checkpoint:
	lda	#$0000
	sta	a:bg2_scroll_mode
	bra	layout_init_stage1_common

layout_init_stage1:
	jsl	f:init_tank_hdma_table
	lda	#$0003
	sta	hdma_preset
	lda	#$0004
	sta	a:bg2_scroll_mode
layout_init_stage1_common:
	lda	#$00C1
	sta	a:m7sel_shadow
	stz	a:clamp_player_top
	lda	#SOUND_SONG_STAGE1
	jml	f:queue_sound

layout_init_stage3_checkpoint:
	stz	a:bg2_scroll_mode
	stz	a:bg2_x
	stz	a:bg2_y
	bra	layout_init_stage3_common

layout_init_stage3:
	lda	#$0007
	sta	hdma_preset
	lda	#OBJT_STAGE3_FUNNEL_CLOUDS
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_TYPE
layout_init_stage3_common:
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#SOUND_SONG_STAGE3_6
	jml	f:queue_sound

layout_init_stage4_checkpoint:
	lda	#SOUND_SONG_STAGE2_4
	jsl	f:queue_sound
	lda	#$000D
	sta	a:obj_slots+29*OBJ_SIZE+OBJ_STATE
	lda	#$000A
	sta	hdma_preset
	lda	#$0030
	sta	a:obj_slots+29*OBJ_SIZE+$38
	bra	layout_init_stage4_common

layout_init_stage4:
	lda	#SOUND_CMD_STOP
	jsl	f:queue_sound
	lda	#SOUND_STAGE4_INTRO
	jsl	f:queue_sound
	lda	#$0040
	sta	a:bg1sc_shadow
layout_init_stage4_common:
	lda	#$0002
	sta	a:spawn_disabled
	lda	#$0064
	sta	a:obj_slots+29*OBJ_SIZE+OBJ_TYPE
	lda	#$00A0
	sta	a:obj_slots+29*OBJ_SIZE+OBJ_TIMER
	lda	#$006D
	sta	a:obj_slots+2*OBJ_SIZE+OBJ_TYPE
	sta	a:obj_slots+3*OBJ_SIZE+OBJ_TYPE
	stz	a:obj_slots+2*OBJ_SIZE+$30
	lda	#$0002
	sta	a:obj_slots+3*OBJ_SIZE+$30
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0004
	sta	a:bg1_scroll_mode
	lda	#$000A
	sta	a:bg2_scroll_mode
	rtl

layout_init_stage6:
	lda	#$0006
	sta	a:palette_anim_id
	jsl	f:apply_palette_anim_once
	lda	#OBJT_STAGE6_BG_TILE_ANIMATOR
	sta	a:obj_slots+27*OBJ_SIZE+OBJ_TYPE
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#SOUND_SONG_STAGE3_6
	jml	f:queue_sound

; Copies 12 words from X to zp_C8-zp_DF (per-layout parameters, ptrs_stage_dp_params).
load_stage_dp_params:
	lda	a:$0000,x
	sta	zp_C8
	lda	a:$0002,x
	sta	zp_CA
	lda	a:$0004,x
	sta	zp_CC
	lda	a:$0006,x
	sta	zp_CE
	lda	a:$0008,x
	sta	zp_D0
	lda	a:$000A,x
	sta	zp_D2
	lda	a:$000C,x
	sta	zp_D4
	lda	a:$000E,x
	sta	zp_D6
	lda	a:$0010,x
	sta	zp_D8
	lda	a:$0012,x
	sta	zp_DA
	lda	a:$0014,x
	sta	zp_DC
	lda	a:$0016,x
	sta	zp_DE
	rtl

; STAGE_STATE_CINEMATIC: one frame of the opening cinematic (run_opening_cinematic)
; with objects and sprites.
stage_cinematic:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	@frame
	inc	a:inidisp_shadow
@frame:
	lda	#$0FC0
	sta	oam_ptr
	lda	#$11C0
	sta	oam_hi_ptr
	lda	#$8000	; [num]
	sta	oam_hi_bits
	jsl	f:reset_vram_update_queues
	jsr	a:update_stage_frame_counters
	jsl	f:run_bg1_scroll_mode
	jsl	f:run_bg2_scroll_mode
	jsl	f:run_opening_cinematic
	jsl	f:update_objects
	jsl	f:update_objects_0280
	ldy	oam_hi_ptr
	cpy	#$11E0
	bcs	@sprites_done
	ldx	oam_ptr
@loop:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	oam_hi_bits
	lsr	oam_hi_bits
	bcc	@loop
	lda	oam_hi_bits
	sta	a:$0000,y
@loop2:
	cpx	#$11C0
	bcs	@sprites_done
	iny
	iny
	lda	#$0080
	sta	$00,x
	sta	$04,x
	sta	$08,x
	sta	$0C,x
	sta	$10,x
	sta	$14,x
	sta	$18,x
	sta	$1C,x
	lda	#$5555
	sta	a:$0000,y
	txa
	clc
	adc	#$0020
	tax
	bra	@loop2
@sprites_done:
	jsl	f:update_shake_side_view
	jsl	f:update_song_change
	rtl
player_autopilot_off:
	rtl

; X = player object. When player_autopilot_mode is non-zero, replaces the
; player's input (fields $22 held / $2C pressed) as scripted by mode 1-3.
apply_player_autopilot:
	lda	a:player_autopilot_mode
	beq	player_autopilot_off
	ldy	#$0000
	cpx	#$0200
	beq	@player1
	; (not executed in the CDL traces)
	ldy	#$0002
@player1:
	stz	$2C,x
	stz	$22,x
	phx
	asl	a
	tax
	lda	f:tbl_player_autopilot_modes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_player_autopilot_modes:
	.addr	$0000
	.addr	player_autopilot_mode1
	.addr	player_autopilot_mode2
	.addr	player_autopilot_mode3

player_autopilot_mode3:
	rtl

player_autopilot_mode1:
	lda	$12,x
	bne	@check_state
	lda	#$0100
	ldy	$0A,x
	cpy	#$007A
	bcc	@store_input
	lda	#$0200
@store_input:
	sta	$22,x
	lda	$0A,x
	cmp	#$0030
	bcc	@return
	cmp	#$00D0
	bcs	@return
	lda	button_jump
	sta	$2C,x
@return:
	rtl
@check_state:
	cmp	#$0001
	beq	@walk_to_target
	rtl
@walk_to_target:
	sec
	lda	$0A,x
	sbc	a:autopilot_target_x,y
	bpl	@check_left
	beq	@stop
	cmp	#$FFFE	; [num]
	bcc	@walk_right
@stop:
	stz	$04,x
	lda	#$0000
	sta	$22,x
	rtl
@walk_right:
	lda	#$0100
	sta	$22,x
	rtl
@check_left:
	cmp	#$0002
	bcc	@stop
	lda	#$0200
	sta	$22,x
	rtl

player_autopilot_mode2:
	lda	$12,x
	cmp	#$0001
	bne	@store_y
	lda	#$0400
	sta	$22,x
	lda	button_jump
	sta	$2C,x
@store_y:
	sty	$04,x
	rtl
