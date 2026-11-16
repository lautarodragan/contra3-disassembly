; objects/object_handlers_00a.asm -- Object handlers (bank $00, part 1)
; Bank $00, $00:CF0C-$00:D655. Included by main.asm in segment BANK00.
;
; Handlers of object types dispatched through tbl_object_types (see
; objects/object_loop.asm) and helpers they share.

scroll_bg1_by_velocity_and_spawn:
	clc
	lda	a:bg1_vel_x_sub
	adc	a:bg1_x_sub
	sta	a:bg1_x_sub
	lda	a:bg1_x
	sta	zp_00
	adc	a:bg1_vel_x
	sta	a:bg1_x
	sec
	sbc	zp_00
	sta	a:bg1_moved_x
	clc
	lda	a:bg1_vel_y_sub
	adc	a:bg1_x+BG_Y_SUB
	sta	a:bg1_x+BG_Y_SUB
	lda	a:bg1_y
	sta	zp_00
	adc	a:bg1_vel_y
	sta	a:bg1_y
	sec
	sbc	zp_00
	sta	a:bg1_moved_y
	ldy	a:airship_spawn_index
	lda	a:airship_spawn_x,y
	cmp	a:bg1_x
	bcc	@return
	phx
	ldx	#$0600
	jsl	f:find_free_slot_from_x
	bcc	@slot_found
	; (not executed in the CDL traces)
	plx
	rtl
@slot_found:
	lda	a:airship_spawn_type_y,y
	pha
	and	#$00FF
	sta	$10,x
	pla
	xba
	and	#$00FF
	sec
	sbc	a:bg1_y
	sta	$0E,x
	lda	a:airship_spawn_params,y
	sta	$3A,x
	stz	$0A,x
	tya
	clc
	adc	#$0006
	sta	a:airship_spawn_index
	plx
@return:
	rtl

; Object type $55: stage 6 (placed in slot 27 by layout_init_stage6): animates
; BG tiles of the organic background: every 8 frames DMAs $400 bytes, one of
; the frames stage6_bg_tile_animator_tile_frames, to VRAM $3A90.
update_stage6_bg_tile_animator:
	lda	stage_frame_counter
	and	#$0007
	dec	a
	bne	@return
	lda	stage_frame_counter
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:stage6_bg_tile_animator_tile_frames,y
	sta	bg_dma_src
	lda	#$0400
	sta	bg_dma_size
	lda	#$3A90
	sta	bg_dma_vram_addr
@return:
	rtl

; Object type $57: stage trigger: puts field $3A in the screen size bits of
; BG2SC (bg2sc_shadow) and deletes itself. Unused: no spawn list or code
; creates a type $57, and it was never run in the CDL traces.
update_bg2_screen_size_trigger:
	; (not executed in the CDL traces)
	lda	a:bg2sc_shadow
	and	#$FFFC
	ora	$3A,x
	sta	a:bg2sc_shadow
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Object type $28's entry in tbl_object_types points at this fill routine,
; but nothing creates a type $28 (no spawn list entry, no code writes it):
; it is only called directly, as a helper. Stores zp_02 at $7E:Y, A times,
; Y += zp_04 each time. Its callers write collision words (TILE_*) into the
; collision map at $7E:4000: a column of TILE_WALL for the stage 1 boss's
; right wall, a column of TILE_CLIMBABLE for the stage 3 robot's cables
; (stage3_robot_cables_state_02) and a row for the ending's floor.
fill_wram_words:
	phx
	tax
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
@loop:
	.a16
	lda	zp_02
	sta	a:$0000,y
	tya
	clc
	adc	zp_04
	tay
	dex
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	rtl

; Object type $08: invisible stage trigger (spawn lists of stages 1, 3 and
; 6, in front of the mid-bosses and bosses): stops the BG1 scroll
; (bg1_autoscroll off, bg1_scroll_mode = 4, bg1_scroll_stop) and rounds the
; scroll position (bg1_x or bg1_y, through spawn_scroll_var) to the nearest
; 256-pixel page, which becomes spawn_last_page. Objects of those places
; wait for bg1_scroll_mode = 4 (among others the barricade, the mid-boss
; tank, the bomber raid and the spiked climber).
update_scroll_stop_trigger:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	stz	a:bg1_autoscroll
	lda	#$0004
	sta	a:bg1_scroll_mode
	stz	a:bg1_autoscroll_speed
	lda	a:spawn_scroll_var
	sta	zp_02
	lda	(zp_02)
	clc
	adc	#$0080
	and	#$FF00
	sta	a:spawn_last_page
	sta	(zp_02)
	rtl

; Object type $89: stage trigger: sets stage_checkpoint (the stage's midpoint:
; a continue starts from here) and deletes itself. Placed by stage 3's spawn
; list (page 14, at the searchlight craft).
update_checkpoint_trigger:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	#$0001
	sta	a:stage_checkpoint
	rtl

; Object type $03: stage trigger (stages 1, 3, 6): sets bg2_map_offset from
; field $3A, waits for bg2_screen_drawn, then sets bg2_scroll_mode (low
; nibble of field $3A) and deletes itself.
update_bg2_scroll_mode_trigger:
	lda	OBJ_STATE,x
	bne	@wait_drawn
	lda	#$0001
	sta	a:bg2_scroll_mode
	lda	$3A,x
	and	#$FFF0
	sta	a:bg2_map_offset
	inc	OBJ_STATE,x
	stz	a:bg2_screen_drawn
	rtl
@wait_drawn:
	lda	a:bg2_screen_drawn
	beq	@return
	lda	$3A,x
	and	#$000F
	sta	a:bg2_scroll_mode
	lda	#$8000	; [num]
	sta	$16,x
@return:
	rtl

; Object type $05: stage trigger: turns bg1_autoscroll on and deletes itself.
update_bg1_autoscroll_trigger:
	lda	#$0001
	sta	a:bg1_autoscroll
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Object type $3B: stage trigger: sets bg2_scroll_mode from field $3B (and
; bg2_x+BG_PAGE), then does what type $0E does.
update_scroll_modes_trigger:
	clc
	lda	a:bg2_y
	adc	#$00FF
	and	#$FF00
	sta	a:bg2_x+BG_PAGE
	lda	$3B,x
	and	#$00FF
	sta	a:bg2_scroll_mode

; Object type $0E: stage trigger: sets bg1_scroll_mode from field $3A, stops
; bg1_autoscroll, rounds the BG1 position up to 256 and deletes itself.
update_bg1_scroll_mode_trigger:
	lda	$3A,x
	and	#$00FF
	sta	a:bg1_scroll_mode
	stz	a:bg1_autoscroll
	clc
	lda	a:bg1_x
	adc	#$00FF
	and	#$FF00
	sta	a:bg1_x
	clc
	lda	a:bg1_y
	adc	#$00FF
	and	#$FF00
	sta	a:bg1_y
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	rtl

; Object type $07: stage trigger: loads the list
; ptrs_trigger_load_lists[field $3A] with load_data_list and deletes itself.
update_load_list_trigger:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	lda	$3A,x
	tay
	stx	zp_FA
	ldx	a:ptrs_trigger_load_lists,y
	jsl	f:load_data_list
	ldx	zp_FA
	rtl

; Object type $42: stage trigger (stages 3 and 6): copies fields $3A/$3B into
; clamp_player_top / respawn_mode and deletes itself.
update_respawn_clamp_trigger:
	sep	#$20
	.a8
	stz	a:respawn_mode+1
	lda	$3B,x
	sta	a:respawn_mode
	stz	a:clamp_player_top+1
	lda	$3A,x
	sta	a:clamp_player_top
	rep	#$20
	.a16
	lda	#$8000	; [num]
	sta	$16,x
	rtl

; Object type $4D: stage trigger: starts a song change (update_song_change):
; song_change_mode / song_change_set from
; song_change_trigger_modes; never run in the CDL traces.
update_song_change_trigger:
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	ldy	$3A,x
	lda	a:song_change_trigger_modes,y
	sta	a:song_change_mode
	lda	a:song_change_trigger_sets,y
	sta	a:song_change_set
	rtl

; Object type $06: the bomber raid of stage 1 (section 9, slot $09C0; seen
; in the emulator). Waits for the scroll stop (state 0), redraws the BG
; through the VRAM queue (states 1-2), sets up Mode 7 and HDMA (state 3);
; a bomber plane drawn in Mode 7 flies in and grows (m7a/m7d, states 4-5),
; drops two bombs (type $0C) and the street blows up (state 6: shake,
; explosions); then the street burns (state 7: bomber_raid_animate_fire,
; kill_players_outside kills players who fall into the fire) through the
; fire section, until type $2A sets state 8, which dissolves the fire band
; (a dither of the tilemap at $7E:A000) and deletes the object.
update_bomber_raid:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_bomber_raid_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_bomber_raid_states:
	.addr	bomber_raid_state_00
	.addr	bomber_raid_state_01
	.addr	bomber_raid_state_02
	.addr	bomber_raid_state_03
	.addr	bomber_raid_state_04
	.addr	bomber_raid_state_05
	.addr	bomber_raid_state_06
	.addr	bomber_raid_state_07
	.addr	bomber_raid_state_08

bomber_raid_state_00:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	@return
	inc	OBJ_STATE,x
@return:
	rtl

bomber_raid_state_01:
	lda	#$003F
	sta	a:bomber_raid_dither_step
	lda	#$A000	; [num]
	sta	a:bomber_raid_attr_ptr
	lda	#$F300	; [num]
	sta	a:bomber_raid_map_ptr
	stz	a:bomber_raid_vram_offset
	stz	a:bomber_raid_block_column
	inc	OBJ_STATE,x
	lda	#$0005
	sta	a:bg2_scroll_mode
	rtl

bomber_raid_state_02:
	lda	#$0008
	sta	zp_08
	stx	zp_FE
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	a:bomber_raid_vram_offset
	jsl	f:begin_vram_transfer
@block_loop:
	lda	a:bomber_raid_map_ptr
	tay
	lda	a:$0000,y
	and	#$3FFF
	clc
	adc	a:bomber_raid_block_column
	tay
@loop:
	lda	a:$5000,y
	and	#$00FF
	sta	zp_0A
	ldx	a:bomber_raid_attr_ptr
	lda	a:$0000,x
	and	#$00FF
	xba
	ora	zp_0A
	ldx	vram_queue_data_ptr
	sta	a:$0000,x
	inc	vram_queue_data_ptr
	inc	vram_queue_data_ptr
	inc	a:bomber_raid_attr_ptr
	iny
	iny
	tya
	and	#$0007
	bne	@loop
	inc	a:bomber_raid_map_ptr
	inc	a:bomber_raid_map_ptr
	lda	a:bomber_raid_map_ptr
	and	#$000F
	bne	@next_block
	clc
	lda	a:bomber_raid_map_ptr
	adc	#$0070
	sta	a:bomber_raid_map_ptr
	cmp	#$F500	; [num]
	bcc	@next_block
	sec
	sbc	#$0200
	sta	a:bomber_raid_map_ptr
	clc
	lda	a:bomber_raid_block_column
	adc	#$0008
	cmp	#$0020
	bcc	@store_column
	lda	#$0000
@store_column:
	sta	a:bomber_raid_block_column
	bne	@next_block
	clc
	lda	a:bomber_raid_map_ptr
	adc	#$0010
	sta	a:bomber_raid_map_ptr
@next_block:
	dec	zp_08
	beq	@done
	brl	@block_loop
@done:
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FE
	clc
	lda	a:bomber_raid_vram_offset
	adc	#$0020
	sta	a:bomber_raid_vram_offset
	cmp	#$1000
	bcc	@return
	inc	$12,x
@return:
	rtl

bomber_raid_state_03:
	stx	zp_FC
	lda	#$0005
	sta	hdma_preset
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	#$3800
	lda	#$0018
	sta	a:$0000,y
	lda	a:bg1_x
	sta	a:$0001,y
	lda	#$0048
	sta	a:$0003,y
	lda	#$0101
	sta	a:$0005,y
	lda	a:bg1_x
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3820
	lda	#$0018
	sta	a:$0000,y
	lda	#$0000
	sta	a:$0001,y
	lda	#$0002
	sta	a:$0003,y
	lda	#$0100
	sta	a:$0005,y
	lda	#$FFFF	; [num]
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3840
	lda	#$0918
	sta	a:$0000,y
	lda	#$0702
	sta	a:$0002,y
	lda	#$0901
	sta	a:$0004,y
	lda	#$0000
	sta	a:$0006,y
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FC
	inc	$12,x
	stz	$24,x
	stz	$38,x
	stz	$30,x
	lda	#$7FFF
	sta	$1C,x
	lda	#$FFFD	; [num]
	sta	$1E,x
	stz	a:boss_work_0
	lda	#$00A0
	sta	f:hdma_tables+$24
	lda	#$0320
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	stz	a:m7b_shadow
	stz	a:m7c_shadow
	lda	#$0180
	sta	a:m7x_shadow
	lda	#$00A8
	sta	a:m7y_shadow
	lda	#$00C1
	sta	a:m7sel_shadow
	lda	#$0001
	sta	a:respawn_mode
	lda	#$0045
	jsl	f:queue_sound
	lda	#$0080
	sta	a:bg1_vel_y
bomber_raid_return:
	rtl

bomber_raid_state_04:
	lda	a:bg1_vel_y
	bmi	@check_zoom
	dec	a:bg1_vel_y
	bpl	bomber_raid_return
@check_zoom:
	lda	a:m7d_shadow
	cmp	#$0280
	bcs	bomber_raid_state_05
	lda	#$0046
	jsl	f:queue_sound
	inc	$12,x
	lda	a:obj_slots+2*OBJ_SIZE+OBJ_TYPE
	bne	bomber_raid_state_05
	phx
	ldy	#$0300
	ldx	#$0004
@loop:
	lda	#OBJT_BOMBER_BOMB
	sta	a:$0010,y
	lda	#.loword(anim_059F12)
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$4000
	sta	a:$001C,y
	lda	#$0003
	sta	a:$001E,y
	lda	#$0038
	sta	a:$000E,y
	lda	a:song_change_trigger_sets,x
	sta	a:$000A,y
	lda	a:data_059F0C,x
	sta	a:$0034,y
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bne	@loop
	plx

bomber_raid_state_05:
	sec
	lda	a:m7a_shadow
	sbc	#$0008
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	cmp	#$002A
	bcs	@still_zooming
	lda	#$0047
	jsl	f:queue_sound
	inc	$12,x
	stz	hdma_preset
	stz	$24,x
	stx	zp_FC
	ldx	#.loword(load_list_059FBA)
	jsl	f:load_data_list
	ldx	zp_FC
	rtl
@still_zooming:
	cmp	#$01D0
	bcs	@skip_rotate
	lda	stage_frame_odd
	bne	@skip_rotate
	dec	a:m7b_shadow
	dec	a:m7c_shadow
@skip_rotate:
	clc
	lda	$1C,x
	adc	#$0700
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	clc
	lda	a:boss_work_0
	adc	$1C,x
	sta	a:boss_work_0
	lda	f:hdma_tables+$24
	adc	$1E,x
	sta	f:hdma_tables+$24
	sep	#$20
	.a8
	lda	a:bg1_y
	dec	a
	sta	f:hdma_tables+$27
	lda	f:hdma_tables+$42
	cmp	#$47
	bcs	@return
	sec
	lda	$38,x
	sbc	$1C,x
	sta	$38,x
	lda	f:hdma_tables+$42
	sbc	$1E,x
	sta	f:hdma_tables+$42
	sta	f:hdma_tables+$23
@return:
	rep	#$20
	.a16
	rtl

bomber_raid_state_06:
	lda	#$0003
	sta	a:shake_timer
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$0100
	bcs	@shake_done
	cmp	#$00D8
	bne	@spawn_debris
	bra	@spawn_debris
@shake_done:
	inc	$12,x
	lda	#$0001
	sta	a:bg1_scroll_mode
	lda	#$0004
	sta	hdma_preset
	stz	$32,x
	lda	#$007F
	sta	f:hdma_tables+$20
	lda	#$0020
	sta	f:hdma_tables+$23
	lda	#$0020
	sta	f:hdma_tables+$26
	lda	#$0000
	sta	f:hdma_tables+$29
	rtl
@spawn_debris:
	lda	#$0008
	sta	zp_00
	lda	#$00D0
	sta	zp_02
	lda	#$00FF
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	@return
	lda	#$FFFC	; [num]
	sta	a:$001E,y
@return:
	rtl

bomber_raid_state_08:
	phx
	lda	#$0038
	sta	zp_02
	ldx	a:bomber_raid_dither_step
	lda	a:bomber_raid_dither_offsets,x
	and	#$00FF
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
@loop:
	.a8
	lda	a:$A000,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A000,y
	lda	a:$A001,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A001,y
	lda	a:$A380,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A380,y
	lda	a:$A381,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A381,y
	lda	a:$A700,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A700,y
	lda	a:$A701,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$A701,y
	lda	a:$AA80,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$AA80,y
	lda	a:$AA81,y
	ora	f:bomber_raid_dither_masks,x
	sta	a:$AA81,y
	rep	#$20
	.a16
	tya
	clc
	adc	#$0010
	tay
	sep	#$20
	.a8
	dec	zp_02
	bne	@loop
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	lda	stage_frame_odd
	bne	@not_done
	dec	a:bomber_raid_dither_step
	bne	@not_done
	lda	#$8000	; [num]
	sta	$16,x
	stz	hdma_preset
	stz	a:respawn_mode
	rtl
@not_done:
	bra	bomber_raid_animate_fire

bomber_raid_state_07:
	lda	#$00C0
	sta	zp_00
	stz	zp_02
	lda	#$0000
	jsl	f:kill_players_outside
bomber_raid_animate_fire:
	lda	a:bg2_x
	sta	f:hdma_tables+$21
	sta	f:hdma_tables+$24
	lda	a:bg1_x
	and	#$00FF
	sta	f:hdma_tables+$27
	inc	$32,x
	lda	$32,x
	asl	a
	and	#$0006
	tay
	lda	a:bomber_raid_fire_tile_frames,y
	sta	bg_dma_src
	lda	#$0380
	sta	bg_dma_size
	lda	#$2E40
	sta	bg_dma_vram_addr
	rtl

; Object type $2A: invisible stage trigger at the end of stage 1's fire
; section (spawn list page 25; seen in the emulator): moves the bomber raid
; (type $06) from state 7 (burning) to state 8 (the fire dissolves) and
; deletes the fire jet (type $2F) in slot $0280 or $02C0.
update_bomber_raid_end_trigger:
	ldy	#$09C0
@loop:
	lda	a:$0010,y
	cmp	#OBJT_BOMBER_RAID
	beq	@found_type_06
	; (not executed in the CDL traces)
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0AC0
	bcc	@loop
@found_type_06:
	lda	a:$0012,y
	inc	a
	sta	a:$0012,y
	lda	#$8000	; [num]
	sta	$16,x
	ldy	#$0280
@loop2:
	lda	a:$0010,y
	cmp	#OBJT_FIRE_JET
	beq	@found_type_2f
	; (not executed in the CDL traces)
	ldy	#$02C0
	bra	@loop2
@found_type_2f:
	lda	#$8000	; [num]
	sta	a:$0016,y
	rtl

; Object type $0C: bomb dropped by the bomber plane (stage 1 section 10,
; seen in the emulator); falls with gravity, trailing type $1D fire effects.
update_bomber_bomb:
	lda	stage_frame_odd
	bne	@fall
	ldy	OBJ_ANIM,x
	lda	a:$0004,y
	sta	zp_00
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	@fall
	lda	zp_00
	sta	a:$0020,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$E000	; [num]
	sta	a:$001C,y
	lda	#$FFFD	; [num]
	sta	a:$001E,y
	lda	#$0003
	sta	a:$0016,y
	lda	#OBJT_EFFECT
	sta	a:$0010,y
@fall:
	sec
	lda	$1C,x
	sbc	#$0900
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	lda	$34,x
	bpl	@drift_right
	sec
	lda	$18,x
	sbc	#$1400
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rtl
@drift_right:
	clc
	lda	$18,x
	adc	#$1400
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	rtl

; Object type $3C: put in slot 27 by layout_init_stage3 (seen in the
; emulator at the start of stage 3): every 8 frames DMAs one of 4 tile
; frames (stage3_funnel_cloud_tile_frames) to VRAM $0E80, which makes the
; funnel clouds hanging from the sky twist; also sets a scroll split at
; bg2_y + $200 with a line-scroll ramp on BG2 ($7E:E000) until that falls
; below $90, then clears it and deletes itself.
update_stage3_funnel_clouds:
	lda	stage_frame_counter
	bit	#$0007
	bne	@scroll_split
	and	#$0018
	lsr	a
	lsr	a
	tay
	lda	a:stage3_funnel_cloud_tile_frames,y
	sta	bg_dma_src
	lda	#$02E0
	sta	bg_dma_size
	lda	#$0E80
	sta	bg_dma_vram_addr
@scroll_split:
	lda	#$0001
	sta	a:scroll_split_pattern
	clc
	lda	a:bg2_y
	adc	#$0200
	sta	a:scroll_split_y
	cmp	#$0090
	bcs	@not_done
	lda	#$8000	; [num]
	sta	$16,x
	stz	a:scroll_split_pattern
	stz	a:scroll_split_y
	stz	hdma_preset
	rtl
@not_done:
	ldy	#$001E
	lda	#$0800
	sta	zp_08
add_bg2_line_scroll_ramp:
	lda	#$0000
	sta	zp_04
	sta	zp_0A
	lda	a:bg2_x+BG_X_MOVED

add_line_scroll_ramp:
	sta	zp_02
	stz	zp_00
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
@loop:
	.a16
	clc
	lda	a:$E800,y
	adc	zp_00
	sta	a:$E800,y
	lda	a:$E000,y
	adc	zp_02
	sta	a:$E000,y
	clc
	lda	zp_00
	adc	zp_08
	sta	zp_00
	lda	zp_02
	adc	zp_0A
	sta	zp_02
	dey
	dey
	cpy	zp_04
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
wobble_stage4_line_scroll:
	lda	stage_frame_counter
	lsr	a
	lsr	a
	lsr	a
	and	#$0007
	bit	#$0004
	beq	@apply_wobble
	eor	#$FFFF
@apply_wobble:
	and	#$0003
	pha
	clc
	adc	a:scroll_split_y
	sta	a:scroll_split_y
	pla
	clc
	adc	#$0000
	sta	a:bg2_y

update_stage4_line_scroll:
	lda	#$0002
	sta	a:scroll_split_pattern
	clc
	lda	a:bg2_y
	adc	#$0100
	sta	a:scroll_split_y
	cmp	#$0002
	bcs	@not_done
	inc	OBJ_STATE,x
	stz	a:scroll_split_pattern
	stz	a:scroll_split_y
	stz	hdma_preset
	rtl
@not_done:
	ldy	#$001A
	lda	#$0012
	sta	zp_04
	lda	#$0000
	sta	zp_08
	lda	#$0001
	sta	zp_0A
	lda	#$000C
	jsl	f:add_line_scroll_ramp
	ldy	#$0012
	lda	#$6000
	sta	zp_08
	brl	add_bg2_line_scroll_ramp
	; CDL: not accessed
	.byte	$6B
spin_fire_return:
	rtl
