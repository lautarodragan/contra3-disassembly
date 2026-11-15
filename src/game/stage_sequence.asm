; game/stage_sequence.asm -- Scripted stage sequence
; Bank $00, $00:EBC4-$00:F27B. Included by main.asm in segment BANK00.
;
; A scripted sequence run from the stage state machine (run_opening_cinematic, state in
; $1C80, table tbl_opening_states): colour-math fades, graphics loads, and state
; tables at $1C82; it clears both players' lives ($1F8A/$1FCA) at its start.

layout_init_opening:
	lda	#$0005
	sta	a:wram_13BA
	lda	#$000C
	sta	a:wram_13FA
	lda	#$0001
	sta	a:cgadsub_shadow
	rtl

run_opening_cinematic:
	jsl	f:opening_cinematic_step
	rtl

opening_cinematic_step:
	inc	a:opening_frame_counter
	lda	a:opening_state
	phx
	asl	a
	tax
	lda	f:tbl_opening_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_states:
	.addr	opening_cinematic_init
	.addr	opening_scene_blank
	.addr	opening_scene_load
	.addr	opening_scene_start
	.addr	opening_scene_run
	.addr	opening_cinematic_done

opening_cinematic_init:
	lda	#$0061
	jsl	f:queue_sound
	ldx	#.loword(data_05A84B)
	jsl	f:load_data_list
	ldy	#$A815
	jsl	f:sub_009982
	stz	a:opening_frame_counter
	lda	#$0020
	sta	a:CGWSEL
	sta	a:cgwsel_shadow
	lda	#$003F
	sta	a:CGADSUB
	sta	a:cgadsub_shadow
	lda	#$0023
	sta	a:W12SEL
	sta	a:w12sel_shadow
	lda	#$0200
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
	lda	#$0013
	sta	a:tm_shadow
	stz	a:p1_lives
	stz	a:p2_lives
	stz	zp_B8
	stz	a:p1_view_x
	stz	a:p2_view_x
	stz	a:opening_scene
	inc	a:opening_state
	rtl

opening_scene_blank:
	lda	#$0080
	sta	a:INIDISP
	sta	a:inidisp_shadow
	lda	#$0041
	sta	a:BG1SC
	sta	a:bg1sc_shadow
	lda	#$0049
	sta	a:BG2SC
	sta	a:bg2sc_shadow
	stz	a:opening_scene_timer
	inc	a:opening_state
	lda	a:opening_scene
	cmp	#$0004
	beq	loc_00ECA0
	lda	#$0004
	sta	a:wram_13BA
	lda	#$0000
	sta	a:wram_13FA
	rtl
loc_00ECA0:
	lda	#$0005
	sta	a:wram_13BA
	lda	#$000C
	sta	a:wram_13FA
	rtl

opening_scene_load:
	jsr	a:opening_clear_objects
	jsr	a:opening_set_layers_normal
	lda	a:opening_scene
	cmp	#$0005
	beq	loc_00ECCE
	cmp	#$0004
	bne	loc_00ECDA
	rep	#$10
	ldy	#$0FFF
	ldx	#$4000
	jsl	f:clear_vram_words
	bra	loc_00ECE7
loc_00ECCE:
	rep	#$10
	ldy	#$03FF
	ldx	#$4400
	jsl	f:clear_vram_words
loc_00ECDA:
	lda	a:opening_scene
	asl	a
	tay
	lda	a:ptrs_05A7AF,y
	tax
	jsl	f:load_data_list
loc_00ECE7:
	inc	a:opening_state
	lda	a:opening_scene
	beq	loc_00ECF5
	lda	#$000F
	sta	a:inidisp_shadow
loc_00ECF5:
	rtl

opening_scene_start:
	stz	a:opening_scene_timer
	stz	a:opening_step
	inc	a:opening_state
	rtl

opening_scene_run:
	jsr	a:opening_run_scene
	lda	a:opening_scene
	asl	a
	tay
	inc	a:opening_scene_timer
	lda	a:opening_scene_timer
	cmp	a:opening_scene_durations,y
	bcc	loc_00ED2F
	lda	a:opening_scene
	inc	a
	bra	loc_00ED21

; (no caller found; decoded because it follows the end of a routine)
opening_next_scene_unused:
	; (not executed in the CDL traces)
	cmp	#$0007
	bcc	loc_00ED21
	lda	#$0000
loc_00ED21:
	sta	a:opening_scene
	asl	a
	tay
	lda	a:opening_scene_next_states,y
	sta	a:opening_state
	stz	a:opening_scene_timer
loc_00ED2F:
	rtl

opening_cinematic_done:
	inc	a:mode_result
	rtl

opening_run_scene:
	lda	a:opening_scene
	phx
	asl	a
	tax
	lda	f:tbl_opening_scenes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_scenes:
	.addr	opening_scene_city
	.addr	opening_scene_vortex
	.addr	opening_scene_beam
	.addr	opening_scene_ruins
	.addr	opening_scene_scrolling_text
	.addr	opening_scene_hero_face
	.addr	opening_scene_heroes

opening_scene_city:
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00ED60
	and	#$000F
	sta	a:inidisp_shadow
loc_00ED60:
	cmp	#$000F
	bcs	loc_00ED68
	inc	a:inidisp_shadow
loc_00ED68:
	lda	a:opening_step
	phx
	asl	a
	tax
	lda	f:tbl_opening_city_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_city_steps:
	.addr	opening_city_init
	.addr	opening_city_wait
	.addr	opening_city_idle

opening_city_init:
	ldx	#$0000
loc_00ED81:
	lda	f:data_05A85B,x
	sta	f:$7EA000,x
	inx
	cpx	#$0016
	bcc	loc_00ED81
	lda	#$000D
	sta	hdma_preset
	stz	a:wram_1384
	lda	#$0100
	sta	a:wram_1380
	stz	a:wram_13DC
	stz	a:wram_13D8
	jsr	a:opening_set_layers_flash
	ldy	#$A830
	jsl	f:sub_009982
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	sta	$0E,x
	lda	#$3C00
	sta	$02,x
	lda	#$D12A
	sta	$00,x
	inc	a:opening_step
	jsr	a:opening_update_parallax
	rts

opening_city_wait:
	jsr	a:opening_is_scene_ending
	bcc	opening_city_idle
	ldy	#$A836
	jsl	f:sub_009982
	inc	a:opening_step

opening_city_idle:
	jsr	a:opening_update_parallax
	rts

opening_scene_vortex:
	lda	a:opening_step
	phx
	asl	a
	tax
	lda	f:tbl_opening_vortex_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_vortex_steps:
	.addr	opening_vortex_init
	.addr	opening_vortex_scroll
	.addr	opening_vortex_spawn_objects
	.addr	opening_vortex_idle

opening_vortex_init:
	jsr	a:opening_update_parallax
	inc	a:opening_step
	rts

opening_vortex_scroll:
	lda	a:wram_13D8
	and	#$00FF
	cmp	#$00E0
	beq	loc_00EE1F
	lda	a:wram_13DC
	sec
	sbc	#$1000
	sta	a:wram_13DC
	bcs	loc_00EE1B
	dec	a:wram_13D8
loc_00EE1B:
	jsr	a:opening_update_parallax
	rts
loc_00EE1F:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	bra	loc_00EE1B

opening_vortex_spawn_objects:
	jsr	a:opening_set_layers_normal
	ldy	#$0000
loc_00EE32:
	lda	a:data_05A9D9,y
	tax
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	a:data_05A871,y
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	lda	#$0000
	sta	$04,x
	lda	a:data_05A891,y
	sta	$20,x
	stz	$22,x
	iny
	iny
	cpy	#$0020
	bcc	loc_00EE32
	ldy	#$A845
	jsl	f:sub_009982
	inc	a:opening_step

opening_vortex_idle:
	jsr	a:opening_update_parallax
	rts

opening_scene_beam:
	lda	a:opening_step
	phx
	asl	a
	tax
	lda	f:tbl_opening_beam_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_beam_steps:
	.addr	opening_beam_init
	.addr	opening_beam_wait
	.addr	opening_beam_start_flash
	.addr	opening_beam_flash

opening_beam_init:
	jsr	a:opening_clear_objects
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$0068
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	lda	#$0000
	sta	$04,x
	lda	#$A95F
	sta	$20,x
	stz	$22,x
	inc	a:opening_step
	stz	a:opening_step_timer
	jsr	a:opening_update_parallax
	rts

opening_beam_wait:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$0010
	bcc	loc_00EEC5
	inc	a:opening_step
loc_00EEC5:
	jsr	a:opening_update_parallax
	rts

opening_beam_start_flash:
	stz	a:title_menu_cursor
	stz	a:p1_view_x
	stz	a:opening_flash_accum
	stz	a:opening_flash_speed_lo
	stz	a:opening_flash_speed_hi
	stz	a:wram_16AC
	lda	#$FFFF
	sta	a:wram_16AA
	lda	#$0080
	sta	a:wram_151E
	sta	a:wram_151C
	sta	a:wram_155E
	sta	a:wram_155C
	lda	#$005B
	jsl	f:queue_sound
	inc	a:opening_step
	jsr	a:opening_update_parallax
	rts

opening_beam_flash:
	lda	a:p1_view_x
	cmp	#$00FE
	bcs	loc_00EF33
	lda	a:opening_flash_speed_lo
	clc
	adc	#$8000
	sta	a:opening_flash_speed_lo
	bcc	loc_00EF15
	inc	a:opening_flash_speed_hi
loc_00EF15:
	lda	a:opening_flash_accum
	clc
	adc	a:opening_flash_speed_lo
	sta	a:opening_flash_accum
	lda	a:p1_view_x
	adc	a:opening_flash_speed_hi
	cmp	#$00FE
	bcc	loc_00EF2D
	lda	#$00FE
loc_00EF2D:
	sta	a:p1_view_x
	sta	a:p2_view_x
loc_00EF33:
	jsr	a:opening_update_parallax
	rts

opening_scene_ruins:
	jsr	a:opening_update_ruins_wave
	lda	a:opening_step
	phx
	asl	a
	tax
	lda	f:tbl_opening_ruins_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_opening_ruins_steps:
	.addr	opening_ruins_init
	.addr	opening_ruins_wait
	.addr	opening_ruins_fade
	.addr	opening_ruins_spawn_alien
	.addr	opening_ruins_alien_wait
	.addr	opening_ruins_idle

opening_ruins_init:
	lda	#$0000
	sta	a:wram_1380
	lda	#$0040
	sta	a:BG1SC
	sta	a:bg1sc_shadow
	lda	#$000E
	sta	hdma_preset
	jsr	a:opening_init_ruins_wave
	lda	#$0000
	sta	f:wram_7E2250
	jsr	a:opening_clear_objects
	stz	a:opening_step_timer
	inc	a:opening_step
	rts

opening_ruins_wait:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$001E
	bcc	loc_00EF8F
	stz	a:opening_step_timer
	inc	a:opening_step
loc_00EF8F:
	rts

opening_ruins_fade:
	lda	a:opening_step_timer
	cmp	#$003F
	bcs	loc_00EFAF
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	lsr	a
	tay
	lda	a:data_05A8B1,y
	and	#$00FF
	sta	a:p1_view_x
	sta	a:p2_view_x
	beq	loc_00EFAF
	rts
loc_00EFAF:
	stz	a:opening_step_timer
	inc	a:opening_step
	rts

opening_ruins_spawn_alien:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$0050
	bcc	loc_00EFEF
	jsr	a:opening_set_layers_flash
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$0054
	sta	$0E,x
	lda	#$3800
	sta	$02,x
	lda	#$CEC8
	sta	$00,x
	ldy	#$A82A
	jsl	f:sub_009982
	stz	a:opening_step_timer
	inc	a:opening_step
loc_00EFEF:
	rts

opening_ruins_alien_wait:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$003C
	bcc	loc_00F009
	ldx	#$0300
	lda	#$CFF9
	sta	$00,x
	stz	a:opening_step_timer
	inc	a:opening_step
loc_00F009:
	rts

opening_ruins_idle:
	rts

opening_scene_scrolling_text:
	lda	a:opening_step
	beq	loc_00F015
	dec	a
	beq	loc_00F026
	; (not executed in the CDL traces)
	bne	loc_00F039
loc_00F015:
	lda	#$0000
	sta	hdma_preset
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	rts
loc_00F026:
	lda	a:wram_1380
	clc
	adc	#$0004
	sta	a:wram_1380
	cmp	#$0900
	bcc	loc_00F038
	; (not executed in the CDL traces)
	inc	a:opening_step
loc_00F038:
	rts
loc_00F039:
	; (not executed in the CDL traces)
	rts

opening_scene_hero_face:
	lda	a:opening_step
	bne	loc_00F04E
	stz	a:wram_13D8
	stz	a:wram_1380
	stz	a:opening_caption_index
	stz	a:opening_caption_timer
	inc	a:opening_step
loc_00F04E:
	sep	#$20
	.a8
	ldy	a:opening_caption_index
	inc	a:opening_caption_timer
	lda	a:opening_caption_timer
	cmp	a:data_05A8D1,y
	bcc	loc_00F09C
	lda	a:data_05A8DB,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:opening_draw_caption_part
	inc	a:opening_caption_index
	lda	a:opening_caption_index
	cmp	#$0001
	bne	loc_00F099
	ldy	#$A83C
	jsl	f:sub_009982
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$00C8
	sta	$0E,x
	lda	#$3A00
	sta	$02,x
	lda	#$D16F
	sta	$00,x
loc_00F099:
	stz	a:opening_caption_timer
loc_00F09C:
	rep	#$20
	rts

opening_scene_heroes:
	lda	a:opening_step
	beq	loc_00F0A9
	dec	a
	beq	loc_00F0B5
	bne	loc_00F0CE
loc_00F0A9:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	rts
loc_00F0B5:
	lda	a:wram_1380
	clc
	adc	#$0004
	sta	a:wram_1380
	cmp	#$0080
	bcc	loc_00F0CD
	stz	a:opening_caption_index
	stz	a:opening_caption_timer
	inc	a:opening_step
loc_00F0CD:
	rts
loc_00F0CE:
	sep	#$20
	.a8
	ldy	a:opening_caption_index
	inc	a:opening_caption_timer
	lda	a:opening_caption_timer
	cmp	a:data_05A8E5,y
	bcc	loc_00F115
	lda	a:data_05A8F3,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:opening_draw_caption_part
	inc	a:opening_caption_index
	lda	a:opening_caption_index
	cmp	#$0001
	bne	loc_00F099
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	lda	#$3C00
	sta	$02,x
	lda	#$D190
	sta	$00,x
	stz	a:opening_caption_timer
loc_00F115:
	rep	#$20
	jsr	a:opening_is_scene_ending
	bcc	loc_00F11F
	jsr	a:opening_clear_objects
loc_00F11F:
	rts

opening_draw_caption_part:
	asl	a
	tay
	lda	a:data_05A901,y
	sta	zp_02
	lda	a:data_05A909,y
	sta	zp_08
	lda	a:data_05A911,y
	pha
	lda	a:data_05A919,y
	tay
	pla
	phx
	jsl	f:sub_00FEA3
	plx
	rts

opening_is_scene_ending:
	lda	a:opening_scene
	asl	a
	tay
	lda	a:opening_scene_timer
	inc	a
	cmp	a:opening_scene_durations,y
	rts

opening_update_parallax:
	lda	a:wram_1380
	sta	f:wram_7EA013
	lda	a:opening_frame_counter
	lsr	a
	lsr	a
	eor	#$FFFF
	sta	f:wram_7EA004
	lda	a:opening_frame_counter
	lsr	a
	sta	f:wram_7EA007
	lsr	a
	sta	f:wram_7EA00A
	lsr	a
	sta	f:wram_7EA00D
	lsr	a
	sta	f:wram_7EA010
	rts

opening_clear_objects:
	ldy	#$0000
loc_00F177:
	lda	a:data_05A9D9,y
	tax
	stz	$10,x
	stz	$00,x
	stz	$16,x
	stz	$20,x
	stz	$22,x
	iny
	iny
	cpy	#$0020
	bcc	loc_00F177
	rts

opening_set_layers_flash:
	lda	#$0003
	sta	a:tm_shadow
	sta	a:TM
	lda	#$0010
	sta	a:ts_shadow
	sta	a:TS
	lda	#$0002
	sta	a:cgwsel_shadow
	sta	a:CGWSEL
	rts

opening_set_layers_normal:
	lda	#$0013
	sta	a:tm_shadow
	sta	a:TM
	lda	#$0002
	sta	a:ts_shadow
	sta	a:TS
	lda	#$0020
	sta	a:cgwsel_shadow
	sta	a:CGWSEL
	rts

build_wave_table:
	lda	a:$0000,y
	sta	zp_00
	lda	a:$0002,y
	asl	a
	sta	zp_02
	lda	a:$0004,y
	clc
	adc	#$0040
	asl	a
	sta	zp_04
	lda	a:$0006,y
	sta	zp_08
	lda	a:$0008,y
	sta	zp_0A
	phx
	ldy	zp_02
loc_00F1E7:
	tya
	and	#$003F
	asl	a
	asl	a
	asl	a
	tax
	lda	f:data_058010,x
	rol	a
	rol	a
	and	#$0001
	pha
	tya
	bit	#$0040
	beq	loc_00F206
	pla
	eor	#$FFFF
	inc	a
	bra	loc_00F207
loc_00F206:
	pla
loc_00F207:
	clc
	adc	(zp_00)
	sta	[zp_08],y
	iny
	iny
	cpy	zp_04
	bcc	loc_00F1E7
	plx
	rtl

opening_init_ruins_wave:
	ldy	#$0000
	ldx	#$0000
loc_00F21A:
	lda	a:data_05A9F9,y
	sta	f:$7EA000,x
	inx
	iny
	cpy	#$0009
	bcc	loc_00F21A
	ldy	#$0000
	ldx	#$0000
loc_00F22E:
	lda	a:data_05AA03,y
	sta	f:$7EA400,x
	inx
	iny
	cpy	#$0009
	bcc	loc_00F22E
	lda	a:wram_1380
	sta	f:wram_7EA010
	lda	a:wram_1398
	inc	a
	sta	f:wram_7EA410
	ldy	#$AA0D
	jsl	f:build_wave_table
	ldy	#$AA16
	jsl	f:build_wave_table
	rts

opening_update_ruins_wave:
	lda	a:opening_frame_counter
	and	#$007E
	clc
	adc	#$A020
	sta	f:wram_7EA004
	lda	a:opening_frame_counter
	clc
	adc	#$0010
	and	#$003F
	asl	a
	clc
	adc	#$A420
	sta	f:wram_7EA404
	rts
