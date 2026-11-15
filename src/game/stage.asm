; game/stage.asm -- Side-view stage state machine
; Bank $00, $00:BD40-$00:C282. Included by main.asm in segment BANK00.
;
; run_side_view_stage dispatches the stage sub-mode through tbl_stage_states: stage start
; effects (stage_init), stage setup (stage_setup_video: video mode, graphics, BG),
; and the per-frame stage loop (stage_play: players sub_01A624, object lists
; sub_00E1B8/sub_00E989, HUD...).

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

stage_init:
	sep	#$20
	.a8
	lda	#$05
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
	beq	loc_00BD90
	clc
	adc	#$000A
	sta	a:stage_layout
loc_00BD90:
	ldy	#$8AC7
	jsl	f:sub_009982
	ldy	a:stage_layout
	lda	a:data_0589D3,y
	sta	a:wram_13BC
	lda	a:data_0589E7,y
	sta	a:wram_13FC
	ldy	a:stage_layout_base
	ldx	a:data_058A03,y
	jsl	f:load_stage_dp_params
	lda	a:data_0589FB,y
	sta	a:wram_1672
	stz	shake_bg1_y
	stz	shake_bg2_y
	stz	a:shake_continuous
	stz	a:shake_timer
	stz	stage_frame_counter
	lda	#$000E
	sta	a:player1_state
	sta	a:player2_state
	stz	a:wram_1688
	stz	a:player_autopilot_mode
	stz	a:wram_16B6
	stz	a:palette_anim_id
	stz	a:palette_anim_timer
	stz	a:life_transfer_disabled
	ldy	a:stage_layout_base
	lda	a:data_058A21,y
	tay
	ldx	#$1210
	jsl	f:sub_009985
	lda	button_fire
	ora	button_stand_still
	sta	a:wram_1628
	lda	#$005F
	sta	a:wram_16AA
	lda	#$0020
	sta	a:wram_16AC
	lda	#$0001
	sta	f:wram_7E3C1E
	sta	f:wram_7E3E1E
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
	stz	a:p1_view_x
	stz	a:p2_view_x
	lda	#$0280
	sta	a:wram_1646
	stz	a:wram_16B2
	stz	a:wram_1676
	stz	a:wram_167A
	stz	a:wram_167C
	stz	a:wram_167E
	stz	a:wram_1678
	rtl

stage_setup_video:
	lda	stage_number
	bne	loc_00BE6E
	inc	a:stage_state
	inc	a:stage_state
loc_00BE6E:
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
	ldx	#.loword(data_058ADD)
	jsl	f:load_data_list
	ldx	#.loword(data_058AD4)
	jsl	f:load_data_list
	ldy	a:stage_layout
	ldx	a:data_058A0D,y
	jsl	f:load_data_list
	ldx	#$1380
	ldy	#$4000
	jsl	f:sub_00C612
	ldx	#$13C0
	ldy	#$A000
	jsl	f:sub_00C612
	lda	stage_number
	cmp	#$0004
	bne	loc_00BEEA
	jsl	f:sub_00C575
loc_00BEEA:
	jsl	f:sub_00E369
	jsl	f:stage_layout_init
	stz	a:wram_168A
	jsl	f:sub_00CE0A
	stz	a:inidisp_shadow
	stz	a:stage_exit_request
	stz	a:stage_pause_disabled

reset_vram_update_queues:
	stz	zp_B0
	stz	zp_B6
	stz	a:wram_1800
	stz	a:wram_1808
	stz	a:wram_1810
	stz	a:wram_1818
	stz	a:wram_1820
	stz	a:wram_1828
	stz	a:wram_1830
	stz	a:wram_1838
	lda	#$0008
	sta	zp_E2
	stz	cgram_upload_src
	stz	cgram_upload_addr
	rtl

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
	sta	zp_E6
	rts

stage_exit:
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_00BF89
	dec	a:inidisp_shadow
	bne	loc_00BF89
	stz	a:life_transfer_disabled
	stz	a:inidisp_shadow
	stz	hdma_preset
	stz	a:stage_state
	stz	nmi_mode
	lda	#$0001
	sta	mode_result
	rtl

stage_play:
	lda	a:stage_exit_request
	beq	loc_00BF72
	inc	a:stage_state
	rtl
loc_00BF72:
	lda	a:stage_pause_disabled
	bne	loc_00BF79
	stz	pause_disabled
loc_00BF79:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	loc_00BF89
	inc	a:inidisp_shadow
	lda	#$0002
	sta	pause_disabled
loc_00BF89:
	lda	a:p1_lives
	bne	loc_00BF99
	lda	a:p2_lives
	bne	loc_00BF99
	lda	#STAGE_STATE_EXIT
	sta	a:stage_state
loc_00BF99:
	lda	a:wram_1688
	beq	loc_00BFA1
	dec	a:wram_1688
loc_00BFA1:
	lda	#$0FC0
	sta	oam_ptr
	lda	#$11C0
	sta	oam_hi_ptr
	lda	#$8000
	sta	oam_hi_bits
	jsl	f:reset_vram_update_queues
	jsr	a:update_stage_frame_counters
	jsl	f:sub_01A624
	jsl	f:update_shots
	stz	a:wram_023C
	stz	a:wram_027C
	stz	a:wram_1504
	stz	a:wram_1544
	lda	a:wram_16B6
	bne	loc_00BFD4
	jsl	f:sub_00CE3A
loc_00BFD4:
	lda	stage_frame_odd
	bne	loc_00BFE2
	jsl	f:draw_players
	jsl	f:update_objects
	bra	loc_00BFEA
loc_00BFE2:
	jsl	f:update_objects
	jsl	f:draw_players
loc_00BFEA:
	jsl	f:update_objects_0280
	ldy	oam_hi_ptr
	cpy	#$11E0
	bcs	loc_00C034
	ldx	oam_ptr
loc_00BFF7:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	oam_hi_bits
	lsr	oam_hi_bits
	bcc	loc_00BFF7
	lda	oam_hi_bits
	sta	a:$0000,y
loc_00C00C:
	cpx	#$11C0
	bcs	loc_00C034
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
	bra	loc_00C00C
loc_00C034:
	jsl	f:update_shake_side_view
	jsl	f:sub_00FDB4
	jsl	f:update_palette_anim
	rtl

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
	sta	a:wram_13FA
	bra	loc_00C07D

layout_init_stage1:
	jsl	f:sub_01B918
	lda	#$0003
	sta	hdma_preset
	lda	#$0004
	sta	a:wram_13FA
loc_00C07D:
	lda	#$00C1
	sta	a:m7sel_shadow
	stz	a:wram_1666
	lda	#$0064
	jml	f:queue_sound

layout_init_stage3_checkpoint:
	; (not executed in the CDL traces)
	stz	a:wram_13FA
	stz	a:wram_13C0
	stz	a:wram_13D8
	bra	loc_00C0A3

layout_init_stage3:
	lda	#$0007
	sta	hdma_preset
	lda	#$003C
	sta	a:wram_08D0
loc_00C0A3:
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0062
	jml	f:queue_sound

layout_init_stage4_checkpoint:
	; (not executed in the CDL traces)
	lda	#$0063
	jsl	f:queue_sound
	lda	#$000D
	sta	a:wram_0952
	lda	#$000A
	sta	hdma_preset
	lda	#$0030
	sta	a:wram_0978
	bra	loc_00C0DE

layout_init_stage4:
	lda	#$0084
	jsl	f:queue_sound
	lda	#$004F
	jsl	f:queue_sound
	lda	#$0040
	sta	a:bg1sc_shadow
loc_00C0DE:
	lda	#$0002
	sta	a:wram_16B6
	lda	#$0064
	sta	a:wram_0950
	lda	#$00A0
	sta	a:wram_0964
	lda	#$006D
	sta	a:wram_0290
	sta	a:wram_02D0
	stz	a:wram_02B0
	lda	#$0002
	sta	a:wram_02F0
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0004
	sta	a:wram_13BA
	lda	#$000A
	sta	a:wram_13FA
	rtl

layout_init_stage6:
	lda	#$0006
	sta	a:palette_anim_id
	jsl	f:apply_palette_anim_once
	lda	#$0055
	sta	a:wram_08D0
	lda	#$004A
	sta	a:bg2sc_shadow
	lda	#$0062
	jml	f:queue_sound

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

stage_cinematic:
	lda	a:inidisp_shadow
	cmp	#$000F
	bcs	loc_00C17A
	inc	a:inidisp_shadow
loc_00C17A:
	lda	#$0FC0
	sta	oam_ptr
	lda	#$11C0
	sta	oam_hi_ptr
	lda	#$8000
	sta	oam_hi_bits
	jsl	f:reset_vram_update_queues
	jsr	a:update_stage_frame_counters
	jsl	f:sub_00C67D
	jsl	f:sub_00C917
	jsl	f:run_opening_cinematic
	jsl	f:update_objects
	jsl	f:update_objects_0280
	ldy	oam_hi_ptr
	cpy	#$11E0
	bcs	loc_00C1EA
	ldx	oam_ptr
loc_00C1AD:
	lda	#$0080
	sta	$00,x
	inx
	inx
	inx
	inx
	sec
	ror	oam_hi_bits
	lsr	oam_hi_bits
	bcc	loc_00C1AD
	lda	oam_hi_bits
	sta	a:$0000,y
loc_00C1C2:
	cpx	#$11C0
	bcs	loc_00C1EA
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
	bra	loc_00C1C2
loc_00C1EA:
	jsl	f:update_shake_side_view
	jsl	f:sub_00FDB4
	rtl
loc_00C1F3:
	rtl

apply_player_autopilot:
	lda	a:player_autopilot_mode
	beq	loc_00C1F3
	ldy	#$0000
	cpx	#$0200
	beq	loc_00C204
	; (not executed in the CDL traces)
	ldy	#$0002
loc_00C204:
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
	bne	loc_00C242
	lda	#$0100
	ldy	$0A,x
	cpy	#$007A
	bcc	loc_00C22F
	lda	#$0200
loc_00C22F:
	sta	$22,x
	lda	$0A,x
	cmp	#$0030
	bcc	loc_00C241
	cmp	#$00D0
	bcs	loc_00C241
	lda	button_jump
	sta	$2C,x
loc_00C241:
	rtl
loc_00C242:
	cmp	#$0001
	beq	loc_00C248
	rtl
loc_00C248:
	sec
	lda	$0A,x
	sbc	a:data_058CDE,y
	bpl	loc_00C265
	beq	loc_00C257
	cmp	#$FFFE
	bcc	loc_00C25F
loc_00C257:
	stz	$04,x
	lda	#$0000
	sta	$22,x
	rtl
loc_00C25F:
	lda	#$0100
	sta	$22,x
	rtl
loc_00C265:
	cmp	#$0002
	bcc	loc_00C257
	lda	#$0200
	sta	$22,x
	rtl

player_autopilot_mode2:
	lda	$12,x
	cmp	#$0001
	bne	loc_00C280
	lda	#$0400
	sta	$22,x
	lda	button_jump
	sta	$2C,x
loc_00C280:
	sty	$04,x
	rtl
