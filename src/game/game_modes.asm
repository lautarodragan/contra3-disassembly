; game/game_modes.asm -- Game mode state machine
; Bank $00, $00:A377-$00:AD7B. Included by main.asm in segment BANK00.
;
; run_game_mode increments the frame counter $3A and dispatches the game mode $32
; through tbl_game_modes (15 modes, game_mode_konami_logo..sub_00AB76); many modes dispatch a
; sub-mode $34 through their own table. Also the end-of-life/continue checks
; (run_stage) and the per-stage choice between side-view and top-down
; (tbl_stage_runners, indexed by $70).

run_game_mode:
	.a16
	rep	#$30
	inc	frame_counter
	lda	game_mode
	phx
	asl	a
	tax
	lda	f:tbl_game_modes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_game_modes:
	.addr	game_mode_konami_logo
	.addr	game_mode_unused_1
	.addr	game_mode_opening
	.addr	game_mode_title
	.addr	game_mode_demo
	.addr	game_mode_sound_check
	.addr	game_mode_game_start
	.addr	game_mode_stage_select
	.addr	game_mode_stage_card
	.addr	game_mode_stage_play
	.addr	game_mode_stage_clear
	.addr	game_mode_game_over
	.addr	game_mode_continue
	.addr	game_mode_options
	.addr	game_mode_final_score

game_mode_konami_logo:
	lda	game_submode
	bne	loc_00A3C1
	ldx	#$F537
	jsl	f:sub_0098D4
	stz	a:konami_logo_step
	stz	a:konami_logo_done
	lda	#$0005
	sta	force_blank_frames
	inc	game_submode
loc_00A3C0:
	rtl
loc_00A3C1:
	jsl	f:run_konami_logo
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A3D9
	; (not executed in the CDL traces)
	lda	#$0002
	sta	force_blank_frames
	lda	#$0003
	brl	set_game_mode
loc_00A3D9:
	lda	a:konami_logo_done
	beq	loc_00A3C0
	lda	#$0002
	brl	set_game_mode

game_mode_unused_1:
	; (not executed in the CDL traces)
	rtl

game_mode_opening:
	lda	game_submode
	asl	a
	tax
	jmp	(.loword(tbl_opening_submodes),x)
tbl_opening_submodes:
	.addr	opening_init
	.addr	opening_start_music
	.addr	opening_run_cinematic
	.addr	opening_load_title
	.addr	opening_zoom_title_logo
	.addr	opening_zoom_title_logo
	.addr	opening_zoom_title_logo
	.addr	opening_zoom_title_logo_last
	.addr	opening_slide_title_the
	.addr	opening_slide_title_alien
	.addr	opening_slide_title_wars
	.addr	opening_shake_title

opening_init:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	stz	a:stage_state
	stz	a:topdown_state
	stz	a:title_menu_cursor
	stz	stage_number
	brl	next_submode

opening_start_music:
	jsl	f:sub_04D9F1
	brl	next_submode

opening_run_cinematic:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A44B
	; (not executed in the CDL traces)
	stz	nmi_mode
	stz	hdma_preset
	brl	next_game_mode
loc_00A44B:
	lda	#$0002
	sta	nmi_mode
	jsl	f:run_side_view_stage
	lda	mode_result
	beq	loc_00A45F
	stz	nmi_mode
	stz	hdma_preset
	brl	next_submode
loc_00A45F:
	rtl

opening_load_title:
	jsl	f:clear_ram_1c00_1cff
	stz	a:title_menu_cursor
	jsl	f:opening_load_title_screen
	brl	next_submode

opening_zoom_title_logo:
	lda	a:m7a_shadow
	clc
	adc	#$0020
	sta	a:m7a_shadow
	lda	a:m7d_shadow
	clc
	adc	#$0020
	sta	a:m7d_shadow
	cmp	#$0100
	bcc	loc_00A490
	stz	a:m7a_shadow
	stz	a:m7d_shadow
	brl	next_submode
loc_00A490:
	rtl

opening_zoom_title_logo_last:
	lda	a:m7a_shadow
	clc
	adc	#$0010
	sta	a:m7a_shadow
	lda	a:m7d_shadow
	clc
	adc	#$0010
	sta	a:m7d_shadow
	cmp	#$0100
	bcc	loc_00A490
	lda	#$0100
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	lda	#$0100
	sta	a:title_the_x
	lda	#$FFA0
	sta	a:title_alien_x
	lda	#$0100
	sta	a:title_wars_x
	lda	#$FF80
	sta	a:wram_1E5C
	lda	#$0046
	jsl	f:queue_sound
	stz	a:title_shake
	lda	#$0001
	sta	hdma_preset
	brl	next_submode

opening_slide_title_the:
	jsl	f:draw_title_word_sprites
	lda	a:title_the_x
	sec
	sbc	#$0004
	sta	a:title_the_x
	cmp	#$0068
	bmi	loc_00A4F1
	rtl
loc_00A4F1:
	lda	#$0068
	sta	a:title_the_x
	lda	#$0046
	jsl	f:queue_sound
	brl	next_submode

opening_slide_title_alien:
	jsl	f:draw_title_word_sprites
	lda	a:title_alien_x
	clc
	adc	#$0004
	sta	a:title_alien_x
	cmp	#$0050
	bpl	loc_00A515
	rtl
loc_00A515:
	lda	#$0050
	sta	a:title_alien_x
	lda	#$0046
	jsl	f:queue_sound
	brl	next_submode

opening_slide_title_wars:
	jsl	f:draw_title_word_sprites
	lda	a:title_wars_x
	sec
	sbc	#$0004
	sta	a:title_wars_x
	cmp	#$0050
	bmi	loc_00A539
	rtl
loc_00A539:
	lda	#$0050
	sta	a:title_wars_x
	lda	#$0047
	jsl	f:queue_sound
	lda	#$0004
	sta	a:title_shake
	brl	next_submode

opening_shake_title:
	lda	#$00B0
	sta	a:wram_1E5C
	jsl	f:draw_title_word_sprites
	ldy	a:title_shake
	lda	frame_counter
	bit	#$0002
	beq	loc_00A569
	tya
	eor	#$FFFF
	inc	a
	tay
loc_00A569:
	sty	a:wram_1398
	sty	a:wram_1418
	lda	a:title_shake
	beq	loc_00A57F
	lda	frame_counter
	bit	#$000F
	bne	loc_00A57E
	dec	a:title_shake
loc_00A57E:
	rtl
loc_00A57F:
	lda	#$0001
	sta	game_submode
	brl	next_game_mode_keep_submode

game_mode_title:
	lda	game_submode
	bne	loc_00A5B9
	lda	#$0068
	sta	a:title_the_x
	lda	#$0050
	sta	a:title_alien_x
	lda	#$0050
	sta	a:title_wars_x
	lda	#$00B0
	sta	a:wram_1E5C
	stz	a:title_shake
	jsl	f:clear_ram_1c00_1cff
	stz	a:title_menu_cursor
	jsl	f:load_title_screen
	lda	#$0001
	sta	hdma_preset
	brl	next_submode
loc_00A5B9:
	jsl	f:run_title_menu
	jsl	f:draw_title_word_sprites
	lda	mode_result
	asl	a
	tax
	jmp	(.loword(tbl_title_results),x)
tbl_title_results:
	.addr	title_result_none
	.addr	title_result_timeout
	.addr	title_result_start
	.addr	title_result_sound_check

title_result_timeout:
	brl	next_game_mode

title_result_start:
	lda	#$0006
	brl	set_game_mode

title_result_sound_check:
	; (not executed in the CDL traces)
	lda	#$0005
	brl	set_game_mode

title_result_none:
	rtl

game_mode_demo:
	lda	game_submode
	bne	loc_00A60D
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A5F7
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A5F7:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	lda	#$0001
	sta	a:title_menu_cursor
	jsl	f:clear_ram_1c00_1cff
	brl	next_submode
loc_00A60D:
	jsl	f:run_demo
	lda	mode_result
	beq	loc_00A624
	dec	a
	bne	loc_00A61E
	lda	#$0000
	brl	set_game_mode
loc_00A61E:
	; (not executed in the CDL traces)
	lda	#$0003
	brl	set_game_mode
loc_00A624:
	rtl

game_mode_sound_check:
	; (not executed in the CDL traces)
	lda	game_submode
	bne	loc_00A63B
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	stz	a:inidisp_shadow
	brl	next_submode
loc_00A63B:
	jsl	f:run_sound_check
	lda	mode_result
	beq	loc_00A649
	lda	#$0003
	brl	set_game_mode
loc_00A649:
	rtl

game_mode_game_start:
	lda	game_submode
	dec	a
	beq	loc_00A65F
	bpl	loc_00A67F
	lda	#$0001
	sta	stage_number
	stz	a:stage_checkpoint
	ldx	#$0050
	brl	next_submode_with_timer
loc_00A65F:
	lda	wait_timer
	and	#$0004
	sta	zp_F0
	lda	a:title_menu_cursor
	asl	a
	tay
	ldx	a:data_05840A,y
	lda	#$2400
	jsl	f:sub_009015
	jsl	f:tick_wait_timer
	bne	loc_00A67E
	brl	next_submode
loc_00A67E:
	rtl
loc_00A67F:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A692
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A692:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	jsr	a:init_new_game
	jsr	a:init_continues
	lda	a:title_menu_cursor
	cmp	#$0003
	bcs	loc_00A6BA
	lda	a:stage_select_enabled
	beq	loc_00A6B4
	; (not executed in the CDL traces)
	lda	#$0007
	brl	set_game_mode
loc_00A6B4:
	lda	#$0008
	brl	set_game_mode
loc_00A6BA:
	lda	#$000D
	brl	set_game_mode

init_new_game:
	stz	a:stage_gfx_loaded

init_players:
	stz	a:stage_state
	stz	a:topdown_state
	stz	a:life_transfer_disabled
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:wram_1F82
	stz	a:wram_1FC2
	stz	a:p1_weapon_1
	stz	a:p2_weapon_1
	stz	a:p1_weapon_2
	stz	a:p2_weapon_2
	stz	a:wram_1F9E
	stz	a:wram_1FDE
	stz	a:p1_barrier_timer
	stz	a:p2_barrier_timer
	lda	#$0001
	sta	a:p1_bombs
	sta	a:p2_bombs
	stz	a:p1_spin
	stz	a:p2_spin
	stz	a:p1_score
	stz	a:p1_score_hi
	stz	a:p2_score
	stz	a:p2_score_hi
	lda	#$0000
	sta	a:p1_next_extend
	sta	a:p2_next_extend
	lda	#$0002
	sta	a:p1_next_extend_hi
	sta	a:p2_next_extend_hi
	lda	a:option_lives
	sta	a:p1_lives
	lda	a:title_menu_cursor
	beq	loc_00A72B
	lda	a:option_lives
loc_00A72B:
	sta	a:p2_lives
	lda	a:option_level
	sta	difficulty
	rts

init_continues:
	ldy	difficulty
	lda	a:continues_per_difficulty,y
	sta	a:continues_left
	rts

game_mode_stage_select:
	; (not executed in the CDL traces)
	lda	game_submode
	dec	a
	beq	loc_00A77C
	bmi	loc_00A747
	brl	loc_00A7E1
loc_00A747:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	ldx	#$841B
	lda	#$2400
	jsl	f:sub_009015
	lda	#$0100
	sta	demo_timer
	brl	next_submode
loc_00A77C:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A78B
	and	#$000F
	sta	a:inidisp_shadow
loc_00A78B:
	cmp	#$000F
	bcs	loc_00A795
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A795:
	plp
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	jsl	f:sub_009024
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A7B4
	lda	#$0002
	jsl	f:queue_sound
	brl	next_submode
loc_00A7B4:
	bit	#$2C00
	bne	loc_00A7BA
	rtl
loc_00A7BA:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	beq	loc_00A7D2
	dec	stage_number
	bne	loc_00A7E0
	lda	#$0006
	sta	stage_number
	rtl
loc_00A7D2:
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	loc_00A7E0
	lda	#$0001
	sta	stage_number
loc_00A7E0:
	rtl
loc_00A7E1:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A7F4
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A7F4:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	next_game_mode

game_mode_stage_card:
	lda	game_submode
	dec	a
	bne	loc_00A806
	brl	loc_00A870
loc_00A806:
	bmi	loc_00A80B
	brl	loc_00A8B8
loc_00A80B:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:draw_score_board
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	lda	#$2400
	jsl	f:sub_009015
	stz	a:stage_state
	stz	a:topdown_state
	stz	a:life_transfer_disabled
	lda	#$0020
	sta	zp_94
	lda	#$0010
	sta	zp_96
	lda	#$4000
	sta	button_fire
	lda	#$8000
	sta	button_jump
	sta	zp_92
	lda	#$0080
	sta	button_bomb
	lda	#$0010
	sta	button_stand_still
	brl	next_submode
loc_00A870:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A87F
	and	#$000F
	sta	a:inidisp_shadow
loc_00A87F:
	cmp	#$000F
	bcs	loc_00A889
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A889:
	plp
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	a:stage_gfx_loaded
	bne	loc_00A8AB
	lda	stage_number
	jsl	f:load_stage_graphics
loc_00A8AB:
	lda	#$0002
	sta	a:stage_gfx_loaded
	jsl	f:sub_04D9F1
	brl	next_submode
loc_00A8B8:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A8CB
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A8CB:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	demo_mode
	lda	#$0002
	sta	pause_disabled
	lda	stage_number
	dec	a
	sta	stage_index
	brl	next_game_mode

game_mode_stage_play:
	jsl	f:run_stage_with_life_transfer
	lda	mode_result
	beq	loc_00A931
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_00A8FB
	jsl	f:reset_sound_queue
	lda	#$000B
	brl	set_game_mode
loc_00A8FB:
	lda	stage_number
	cmp	#$0006
	bcc	loc_00A92B
	lda	#$0001
	sta	stage_number
	stz	a:stage_checkpoint
	lda	a:option_level
	inc	a
	inc	a
	cmp	#$0006
	bcc	loc_00A91A
	lda	#$000E
	brl	set_game_mode
loc_00A91A:
	; (not executed in the CDL traces)
	sta	a:option_level
	sta	difficulty
	stz	a:stage_gfx_loaded
	jsr	a:init_continues
	lda	#$0008
	brl	set_game_mode
loc_00A92B:
	lda	#$000A
	brl	set_game_mode
loc_00A931:
	rtl

game_mode_stage_clear:
	lda	game_submode
	bne	loc_00A945
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	brl	next_submode
loc_00A945:
	jsl	f:run_stage_clear
	lda	mode_result
	beq	loc_00A953
	lda	#$0008
	brl	set_game_mode
loc_00A953:
	rtl

game_mode_game_over:
	lda	game_submode
	phx
	asl	a
	tax
	lda	f:tbl_game_over_submodes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_game_over_submodes:
	.addr	game_over_init
	.addr	game_over_fade_in
	.addr	game_over_wait_continue
	.addr	game_over_wait_final
	.addr	game_over_fade_out

game_over_init:
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:draw_score_board
	ldx	#$8472
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$F513
	jsl	f:sub_0098D4
	brl	next_submode

game_over_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A9B3
	and	#$000F
	sta	a:inidisp_shadow
loc_00A9B3:
	cmp	#$000F
	bcs	loc_00A9BD
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A9BD:
	plp
	lda	#$006B
	jsl	f:queue_sound
	dec	a:continues_left
	bmi	loc_00A9D2
	lda	#$0080
	sta	mode_timer
	brl	next_submode
loc_00A9D2:
	; (not executed in the CDL traces)
	lda	#$0180
	sta	mode_timer
	lda	#$0003
	sta	game_submode
	rtl

game_over_wait_continue:
	dec	mode_timer
	bne	loc_00A9E4
	brl	next_game_mode
loc_00A9E4:
	rtl

game_over_wait_final:
	; (not executed in the CDL traces)
	dec	mode_timer
	bne	loc_00A9EC
	brl	next_submode
loc_00A9EC:
	rtl

game_over_fade_out:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00AA00
	dec	a:inidisp_shadow
	plp
	rtl
loc_00AA00:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	loc_00AAA8

game_mode_continue:
	lda	game_submode
	asl	a
	tax
	jmp	(.loword(tbl_continue_submodes),x)
tbl_continue_submodes:
	.addr	continue_init
	.addr	continue_menu
	.addr	continue_player_menu
	.addr	continue_fade_out

continue_init:
	lda	#$0002
	sta	a:continue_option_count
	stz	a:continue_cursor
	brl	next_submode

continue_menu:
	jsr	a:continue_move_cursor
	jsr	a:continue_draw_menu
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00AA5C
	lda	#$0002
	jsl	f:queue_sound
	lda	a:continue_cursor
	beq	loc_00AA46
	; (not executed in the CDL traces)
	lda	#$0003
	brl	set_submode
loc_00AA46:
	lda	a:title_menu_cursor
	sta	a:continue_cursor
	lda	#$0003
	sta	a:continue_option_count
	ldx	#$8490
	jsl	f:sub_009024
	brl	next_submode
loc_00AA5C:
	rtl

continue_player_menu:
	jsr	a:continue_move_cursor
	jsr	a:continue_draw_player_menu
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00AA7F
	lda	#$0002
	jsl	f:queue_sound
	lda	a:continue_cursor
	sta	a:title_menu_cursor
	stz	a:continue_cursor
	brl	next_submode
loc_00AA7F:
	rtl

continue_fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00AA93
	dec	a:inidisp_shadow
	plp
	rtl
loc_00AA93:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	a:continue_cursor
	bne	loc_00AAA8
	jsr	a:init_players
	lda	#$0008
	brl	set_game_mode
loc_00AAA8:
	; (not executed in the CDL traces)
	stz	a:stage_checkpoint
	lda	#$0003
	brl	set_game_mode

continue_move_cursor:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$2C00
	beq	loc_00AAE5
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_00AAD8
	lda	a:continue_cursor
	inc	a
	cmp	a:continue_option_count
	bcc	loc_00AAD4
	lda	#$0000
loc_00AAD4:
	sta	a:continue_cursor
	rts
loc_00AAD8:
	lda	a:continue_cursor
	dec	a
	bpl	loc_00AAE2
	lda	a:continue_option_count
	dec	a
loc_00AAE2:
	sta	a:continue_cursor
loc_00AAE5:
	rts

continue_draw_menu:
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$847E
	pha
	jsl	f:sub_009015
	pla
	ldx	#$1E62
	ldy	#$5A35
	jsl	f:draw_digit_of_value
	lda	a:continue_cursor
	eor	#$0001
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$848A
	jsl	f:sub_009015
	rts

draw_digit_of_value:
	sta	zp_FA
	phx
	jsl	f:sub_008D41
	plx
	lda	$00,x
	inc	a
	jsl	f:draw_digit
	jsl	f:sub_008DB0
	rtl

continue_draw_player_menu:
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058404,y
	ldx	#$8599
	jsl	f:sub_009015
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058402,y
	ldx	#$85A6
	jsl	f:sub_009015
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058400,y
	ldx	#$85B4
	jsl	f:sub_009015
	rts

game_mode_options:
	lda	game_submode
	bne	loc_00AB68
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	bra	next_submode
loc_00AB68:
	jsl	f:run_options
	lda	mode_result
	beq	loc_00AB75
	lda	#$0003
	bra	set_game_mode
loc_00AB75:
	rtl

game_mode_final_score:
	lda	game_submode
	bne	loc_00AB88
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	bra	next_submode
loc_00AB88:
	jsl	f:run_final_score
	lda	mode_result
	beq	loc_00AB95
	; (not executed in the CDL traces)
	lda	#$0002
	bra	set_game_mode
loc_00AB95:
	rtl
	; CDL: not accessed
	.byte	$A2, $80, $00
next_submode_with_timer:
	stx	wait_timer
next_submode:
	lda	game_submode
	inc	a
	bra	set_submode
next_game_mode:
	lda	game_mode
	inc	a

set_game_mode:
	sta	game_mode
	lda	#$0000
	sta	mode_result
set_submode:
	sta	game_submode
	stz	zp_38
	rtl
next_game_mode_keep_submode:
	inc	game_mode
	stz	mode_result
	stz	zp_38
	rtl

tick_wait_timer:
	lda	wait_timer
	beq	loc_00ABBC
	dec	wait_timer
loc_00ABBC:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00ABBD:
	; (not executed in the CDL traces)
	jsl	f:sub_00ABC6
	rep	#$20
	stz	demo_mode
	rtl

sub_00ABC6:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	stz	paused
	jsl	f:disable_display_and_nmi
	sep	#$20
	.a8
	jsl	f:clear_ram_1c00_1cff
	jsl	f:start_display
	rep	#$20
	.a16
	rtl

run_stage_with_life_transfer:
	jsr	a:update_life_transfer

run_stage:
	rep	#$30
	jsr	a:update_weapon_swap
	lda	demo_mode
	bne	loc_00AC1B
	lda	pause_disabled
	bne	loc_00AC1B
	lda	#$0000
	ldy	a:p1_lives
	beq	loc_00ABF7
	ora	joy1_pressed
loc_00ABF7:
	ldy	a:p2_lives
	beq	loc_00ABFE
	ora	joy2_pressed
loc_00ABFE:
	bit	#$1000
	beq	loc_00AC16
	lda	paused
	eor	#$0001
	sta	paused
	asl	a
	tay
	lda	a:pause_sounds,y
	jsl	f:queue_sound
	jsr	a:apply_pause_dimming
loc_00AC16:
	lda	paused
	beq	loc_00AC1B
	rtl
loc_00AC1B:
	lda	stage_index
	phx
	asl	a
	tax
	lda	f:tbl_stage_runners,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage_runners:
	.addr	enter_side_view_stage
	.addr	enter_top_down_stage
	.addr	enter_side_view_stage
	.addr	enter_side_view_stage
	.addr	enter_top_down_stage
	.addr	enter_side_view_stage

enter_side_view_stage:
	lda	#$0002
	sta	nmi_mode
	jml	f:run_side_view_stage

enter_top_down_stage:
	lda	#$0004
	sta	nmi_mode
	inc	stage_frame_counter
	jml	f:run_topdown_stage

update_weapon_swap:
	jsr	a:update_weapon_swap_p1
	lda	a:p2_spin
	beq	loc_00AC5C
	lda	#$0002
	sta	a:wram_1FC2
	sta	a:p2_weapon_slot
	rts
loc_00AC5C:
	lda	a:p2_lives
	beq	loc_00AC71
	lda	joy2_pressed
	bit	#$0040
	beq	loc_00AC71
	lda	a:wram_1FDE
	eor	#$0002
	sta	a:wram_1FDE
loc_00AC71:
	lda	a:wram_1FDE
	sta	a:wram_1FC2
	eor	#$0002
	sta	a:p2_weapon_slot
	rts

update_weapon_swap_p1:
	lda	a:p1_spin
	beq	loc_00AC8D
	lda	#$0002
	sta	a:wram_1F82
	sta	a:p1_weapon_slot
	rts
loc_00AC8D:
	lda	a:p1_lives
	beq	loc_00ACA2
	lda	joy1_pressed
	bit	#$0040
	beq	loc_00ACA2
	lda	a:wram_1F9E
	eor	#$0002
	sta	a:wram_1F9E
loc_00ACA2:
	lda	a:wram_1F9E
	sta	a:wram_1F82
	eor	#$0002
	sta	a:p1_weapon_slot
	rts

apply_pause_dimming:
	lda	paused
	beq	loc_00ACCF
	lda	a:inidisp_shadow
	sta	a:pause_saved_brightness
	lda	a:p1_view_brightness
	sta	a:pause_saved_p1_brightness
	lda	a:p2_view_brightness
	sta	a:pause_saved_p2_brightness
	jsr	a:dim_screen_brightness
	jsr	a:dim_p1_brightness
	jsr	a:dim_p2_brightness
	rts
loc_00ACCF:
	lda	a:pause_saved_brightness
	sta	a:inidisp_shadow
	lda	a:pause_saved_p1_brightness
	sta	a:p1_view_brightness
	lda	a:pause_saved_p2_brightness
	sta	a:p2_view_brightness
	rts

dim_screen_brightness:
	lda	a:inidisp_shadow
	bit	#$0080
	bne	loc_00ACF9
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00ACF6
	; (not executed in the CDL traces)
	lda	#$0000
loc_00ACF6:
	sta	a:inidisp_shadow
loc_00ACF9:
	rts

dim_p1_brightness:
	lda	a:p1_view_brightness
	bit	#$0080
	bne	loc_00AD11
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD0E
	lda	#$0000
loc_00AD0E:
	sta	a:p1_view_brightness
loc_00AD11:
	rts

dim_p2_brightness:
	lda	a:p2_view_brightness
	bit	#$0080
	bne	loc_00AD29
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD26
	lda	#$0000
loc_00AD26:
	sta	a:p2_view_brightness
loc_00AD29:
	rts

update_life_transfer:
	lda	a:life_transfer_disabled
	bne	loc_00AD5A
	lda	a:title_menu_cursor
	beq	loc_00AD5A
	jsr	a:life_transfer_to_p1
	jmp	a:life_transfer_to_p2

life_transfer_to_p1:
	lda	a:p1_lives
	bne	loc_00AD5A
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#$0080
	beq	loc_00AD5A
	lda	a:p2_lives
	cmp	#$0002
	bcc	loc_00AD5A
	inc	a:p1_lives
	dec	a:p2_lives
	lda	#$0001
	sta	a:p1_bombs
loc_00AD5A:
	rts
life_transfer_to_p2:
	lda	a:p2_lives
	bne	loc_00AD7B
	; (not executed in the CDL traces)
	lda	joy2_pressed
	bit	#$0080
	beq	loc_00AD7B
	lda	a:p1_lives
	cmp	#$0002
	bcc	loc_00AD7B
	inc	a:p2_lives
	dec	a:p1_lives
	lda	#$0001
	sta	a:p2_bombs
loc_00AD7B:
	rts
