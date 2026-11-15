; game/opening.asm -- Opening cinematic
; Bank $00, $00:EBC4-$00:F27B. Included by main.asm in segment BANK00.
;
; The opening cinematic of GAME_MODE_OPENING, run as stage 0 by the
; side-view stage code (stage_cinematic -> run_opening_cinematic): seven
; scenes (city, vortex, beam strike, ruins and the alien, scrolling text,
; the hero's face, both heroes) with their HDMA parallax / wave tables and
; captions. It clears both players' lives at its start.

; Stage layout init of the opening (stage 0).
layout_init_opening:
	lda	#$0005
	sta	a:bg1_scroll_mode
	lda	#$000C
	sta	a:bg2_scroll_mode
	lda	#$0001
	sta	a:cgadsub_shadow
	rtl

; The opening cinematic, state in opening_state (tbl_opening_states):
; init, blank, load the scene's graphics, run the scene for
; opening_scene_durations[opening_scene] frames, next scene
; (opening_scene_next_states), done (mode_result + 1).
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
	ldy	#.loword(palette_05A815)
	jsl	f:start_palette_task
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
	beq	@last_scene
	lda	#$0004
	sta	a:bg1_scroll_mode
	lda	#$0000
	sta	a:bg2_scroll_mode
	rtl
@last_scene:
	lda	#$0005
	sta	a:bg1_scroll_mode
	lda	#$000C
	sta	a:bg2_scroll_mode
	rtl

opening_scene_load:
	jsr	a:opening_clear_objects
	jsr	a:opening_set_layers_normal
	lda	a:opening_scene
	cmp	#$0005
	beq	@scene5_tiles
	cmp	#$0004
	bne	@load_scene_gfx
	rep	#$10
	ldy	#$0FFF
	ldx	#$4000
	jsl	f:clear_vram_words
	bra	@loaded
@scene5_tiles:
	rep	#$10
	ldy	#$03FF
	ldx	#$4400
	jsl	f:clear_vram_words
@load_scene_gfx:
	lda	a:opening_scene
	asl	a
	tay
	lda	a:ptrs_05A7AF,y
	tax
	jsl	f:load_data_list
@loaded:
	inc	a:opening_state
	lda	a:opening_scene
	beq	@return
	lda	#$000F
	sta	a:inidisp_shadow
@return:
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
	bcc	opening_scene_run_return
	lda	a:opening_scene
	inc	a
	bra	opening_set_scene

; (no caller found; decoded because it follows the end of a routine)
opening_next_scene_unused:
	; (not executed in the CDL traces)
	cmp	#$0007
	bcc	opening_set_scene
	lda	#$0000
opening_set_scene:
	sta	a:opening_scene
	asl	a
	tay
	lda	a:opening_scene_next_states,y
	sta	a:opening_state
	stz	a:opening_scene_timer
opening_scene_run_return:
	rtl

opening_cinematic_done:
	inc	a:mode_result
	rtl

; Scenes (tbl_opening_scenes, see the book): 0 city (A.D. 2636), 1 vortex,
; 2 beam strike, 3 ruins and the alien, 4 scrolling text, 5 the hero's face
; and caption, 6 both heroes and caption.
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
	beq	@check_level
	and	#$000F
	sta	a:inidisp_shadow
@check_level:
	cmp	#$000F
	bcs	@run_step
	inc	a:inidisp_shadow
@run_step:
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
@loop:
	lda	f:data_05A85B,x
	sta	f:$7EA000,x
	inx
	cpx	#$0016
	bcc	@loop
	lda	#$000D
	sta	hdma_preset
	stz	a:bg1_x_sub
	lda	#$0100
	sta	a:bg1_x
	stz	a:bg2_y_sub
	stz	a:bg2_y
	jsr	a:opening_set_layers_flash
	ldy	#.loword(palette_05A830)
	jsl	f:start_palette_task
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	sta	$0E,x
	lda	#$3C00
	sta	$02,x
	lda	#.loword(metasprite_06D12A)
	sta	$00,x
	inc	a:opening_step
	jsr	a:opening_update_parallax
	rts

opening_city_wait:
	jsr	a:opening_is_scene_ending
	bcc	opening_city_idle
	ldy	#.loword(palette_05A836)
	jsl	f:start_palette_task
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
	lda	a:bg2_y
	and	#$00FF
	cmp	#$00E0
	beq	@stop_scroll
	lda	a:bg2_y_sub
	sec
	sbc	#$1000
	sta	a:bg2_y_sub
	bcs	@update
	dec	a:bg2_y
@update:
	jsr	a:opening_update_parallax
	rts
@stop_scroll:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	bra	@update

opening_vortex_spawn_objects:
	jsr	a:opening_set_layers_normal
	ldy	#$0000
@loop:
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
	bcc	@loop
	ldy	#.loword(palette_05A845)
	jsl	f:start_palette_task
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
	lda	#.loword(anim_05A95F)
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
	bcc	@update
	inc	a:opening_step
@update:
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
	bcs	@update
	lda	a:opening_flash_speed_lo
	clc
	adc	#$8000
	sta	a:opening_flash_speed_lo
	bcc	@accumulate
	inc	a:opening_flash_speed_hi
@accumulate:
	lda	a:opening_flash_accum
	clc
	adc	a:opening_flash_speed_lo
	sta	a:opening_flash_accum
	lda	a:p1_view_x
	adc	a:opening_flash_speed_hi
	cmp	#$00FE
	bcc	@store
	lda	#$00FE
@store:
	sta	a:p1_view_x
	sta	a:p2_view_x
@update:
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
	sta	a:bg1_x
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
	bcc	@return
	stz	a:opening_step_timer
	inc	a:opening_step
@return:
	rts

opening_ruins_fade:
	lda	a:opening_step_timer
	cmp	#$003F
	bcs	@next_step
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	lsr	a
	tay
	lda	a:data_05A8B1,y
	and	#$00FF
	sta	a:p1_view_x
	sta	a:p2_view_x
	beq	@next_step
	rts
@next_step:
	stz	a:opening_step_timer
	inc	a:opening_step
	rts

opening_ruins_spawn_alien:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$0050
	bcc	@return
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
	lda	#.loword(metasprite_06CEC8)
	sta	$00,x
	ldy	#.loword(palette_05A82A)
	jsl	f:start_palette_task
	stz	a:opening_step_timer
	inc	a:opening_step
@return:
	rts

opening_ruins_alien_wait:
	inc	a:opening_step_timer
	lda	a:opening_step_timer
	cmp	#$003C
	bcc	@return
	ldx	#$0300
	lda	#.loword(metasprite_06CFF9)
	sta	$00,x
	stz	a:opening_step_timer
	inc	a:opening_step
@return:
	rts

opening_ruins_idle:
	rts

opening_scene_scrolling_text:
	lda	a:opening_step
	beq	@init
	dec	a
	beq	@scroll
	; (not executed in the CDL traces)
	bne	@return2
@init:
	lda	#$0000
	sta	hdma_preset
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	rts
@scroll:
	lda	a:bg1_x
	clc
	adc	#$0004
	sta	a:bg1_x
	cmp	#$0900
	bcc	@return
	; (not executed in the CDL traces)
	inc	a:opening_step
@return:
	rts
@return2:
	; (not executed in the CDL traces)
	rts

opening_scene_hero_face:
	lda	a:opening_step
	bne	@caption
	stz	a:bg2_y
	stz	a:bg1_x
	stz	a:opening_caption_index
	stz	a:opening_caption_timer
	inc	a:opening_step
@caption:
	sep	#$20
	.a8
	ldy	a:opening_caption_index
	inc	a:opening_caption_timer
	lda	a:opening_caption_timer
	cmp	a:data_05A8D1,y
	bcc	opening_caption_return
	lda	a:data_05A8DB,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:opening_draw_caption_part
	inc	a:opening_caption_index
	lda	a:opening_caption_index
	cmp	#$0001
	bne	opening_caption_next
	ldy	#.loword(palette_05A83C)
	jsl	f:start_palette_task
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
	lda	#.loword(metasprite_06D16F)
	sta	$00,x
opening_caption_next:
	stz	a:opening_caption_timer
opening_caption_return:
	rep	#$20
	rts

opening_scene_heroes:
	lda	a:opening_step
	beq	@init
	dec	a
	beq	@scroll
	bne	@caption
@init:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:opening_step
	rts
@scroll:
	lda	a:bg1_x
	clc
	adc	#$0004
	sta	a:bg1_x
	cmp	#$0080
	bcc	@return
	stz	a:opening_caption_index
	stz	a:opening_caption_timer
	inc	a:opening_step
@return:
	rts
@caption:
	sep	#$20
	.a8
	ldy	a:opening_caption_index
	inc	a:opening_caption_timer
	lda	a:opening_caption_timer
	cmp	a:data_05A8E5,y
	bcc	@check_end
	lda	a:data_05A8F3,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:opening_draw_caption_part
	inc	a:opening_caption_index
	lda	a:opening_caption_index
	cmp	#$0001
	bne	opening_caption_next
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
	lda	#.loword(metasprite_06D190)
	sta	$00,x
	stz	a:opening_caption_timer
@check_end:
	rep	#$20
	jsr	a:opening_is_scene_ending
	bcc	@return2
	jsr	a:opening_clear_objects
@return2:
	rts

; A = entry: queues a strip of caption tiles (data_05A901...) with queue_vram_blocks.
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
	jsl	f:queue_vram_blocks
	plx
	rts

; Carry set if the scene ends next frame.
opening_is_scene_ending:
	lda	a:opening_scene
	asl	a
	tay
	lda	a:opening_scene_timer
	inc	a
	cmp	a:opening_scene_durations,y
	rts

; Writes the HDMA scroll table at $7E:A000 from bg1_x and opening_frame_counter.
opening_update_parallax:
	lda	a:bg1_x
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

; Clears the 16 object slots listed in data_05A9D9.
opening_clear_objects:
	ldy	#$0000
@loop:
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
	bcc	@loop
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

; Y = parameters: fills a table with a value modulated by the sign of a
; sine table (data_058010); used for the wavy ruins effect.
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
@loop:
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
	beq	@positive
	pla
	eor	#$FFFF
	inc	a
	bra	@add
@positive:
	pla
@add:
	clc
	adc	(zp_00)
	sta	[zp_08],y
	iny
	iny
	cpy	zp_04
	bcc	@loop
	plx
	rtl

opening_init_ruins_wave:
	ldy	#$0000
	ldx	#$0000
@loop:
	lda	a:data_05A9F9,y
	sta	f:$7EA000,x
	inx
	iny
	cpy	#$0009
	bcc	@loop
	ldy	#$0000
	ldx	#$0000
@loop2:
	lda	a:data_05AA03,y
	sta	f:$7EA400,x
	inx
	iny
	cpy	#$0009
	bcc	@loop2
	lda	a:bg1_x
	sta	f:wram_7EA010
	lda	a:bg1_y
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
