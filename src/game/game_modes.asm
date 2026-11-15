; game/game_modes.asm -- Game mode state machine
; Bank $00, $00:A377-$00:AD7B. Included by main.asm in segment BANK00.
;
; run_game_mode (every frame) dispatches game_mode (GAME_MODE_*, game.inc)
; through tbl_game_modes; each mode steps its own sub-mode game_submode
; (next_submode, set_game_mode...). The modes and their order are described
; in the book ("Game flow"). Also the code shared by every stage frame
; (run_stage: pause, weapon swap, side-view or top-down dispatch), the
; life transfer between players, the new-game / continue initialisation
; of the players and the opening's title logo animation.

; Called once per frame by the NMI frame handler: increments frame_counter
; and jumps to the handler of game_mode (GAME_MODE_*) in tbl_game_modes.
; Handlers end with rtl; they change mode with set_game_mode / next_game_mode
; and step their sub-mode game_submode with next_submode.
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

; GAME_MODE_KONAMI_LOGO. Submode 0 loads the song set and resets the logo;
; then runs run_konami_logo until konami_logo_done -> GAME_MODE_OPENING.
; Start skips to GAME_MODE_TITLE.
game_mode_konami_logo:
	lda	game_submode
	bne	@running
	ldx	#$F537
	jsl	f:load_song_set
	stz	a:konami_logo_step
	stz	a:konami_logo_done
	lda	#$0005
	sta	force_blank_frames
	inc	game_submode
@return:
	rtl
@running:
	jsl	f:run_konami_logo
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	@check_done
	; (not executed in the CDL traces)
	lda	#$0002
	sta	force_blank_frames
	lda	#GAME_MODE_TITLE
	brl	set_game_mode
@check_done:
	lda	a:konami_logo_done
	beq	@return
	lda	#GAME_MODE_OPENING
	brl	set_game_mode

; Mode 1: never entered.
game_mode_unused_1:
	; (not executed in the CDL traces)
	rtl

; GAME_MODE_OPENING: the opening cinematic (run by the side-view stage code
; with stage_number 0, see stage_cinematic), then the title logo: Mode 7
; zoom of CONTRA III, the words THE / ALIEN / WARS sliding in, a shake;
; ends in GAME_MODE_TITLE, sub-mode 1 (title already drawn).
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

; Clears $1500-$18FF, the stage state and the title cursor; stage_number = 0.
opening_init:
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
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
	jsl	f:load_stage_music
	brl	next_submode

; Runs run_side_view_stage (stage 0 = cinematic) until mode_result;
; Start skips to the title.
opening_run_cinematic:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	@no_skip
	; (not executed in the CDL traces)
	stz	nmi_mode
	stz	hdma_preset
	brl	next_game_mode
@no_skip:
	lda	#$0002
	sta	nmi_mode
	jsl	f:run_side_view_stage
	lda	mode_result
	beq	@return
	stz	nmi_mode
	stz	hdma_preset
	brl	next_submode
@return:
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
	bcc	opening_zoom_return
	stz	a:m7a_shadow
	stz	a:m7d_shadow
	brl	next_submode
opening_zoom_return:
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
	bcc	opening_zoom_return
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
	sta	a:title_tm_x
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
	bmi	@arrived
	rtl
@arrived:
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
	bpl	@arrived
	rtl
@arrived:
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
	bmi	@arrived
	rtl
@arrived:
	lda	#$0050
	sta	a:title_wars_x
	lda	#$0047
	jsl	f:queue_sound
	lda	#$0004
	sta	a:title_shake
	brl	next_submode

opening_shake_title:
	lda	#$00B0
	sta	a:title_tm_x
	jsl	f:draw_title_word_sprites
	ldy	a:title_shake
	lda	frame_counter
	bit	#$0002
	beq	@store_offset
	tya
	eor	#$FFFF
	inc	a
	tay
@store_offset:
	sty	a:wram_1398
	sty	a:wram_1418
	lda	a:title_shake
	beq	@to_title_menu
	lda	frame_counter
	bit	#$000F
	bne	@return
	dec	a:title_shake
@return:
	rtl
@to_title_menu:
	lda	#$0001
	sta	game_submode
	brl	next_game_mode_keep_submode

; GAME_MODE_TITLE. Submode 0 draws the title (load_title_screen); then
; run_title_menu; mode_result 1 (timeout) -> GAME_MODE_DEMO,
; 2 (Start) -> GAME_MODE_GAME_START, 3 -> GAME_MODE_SOUND_CHECK (unreachable).
game_mode_title:
	lda	game_submode
	bne	@running
	lda	#$0068
	sta	a:title_the_x
	lda	#$0050
	sta	a:title_alien_x
	lda	#$0050
	sta	a:title_wars_x
	lda	#$00B0
	sta	a:title_tm_x
	stz	a:title_shake
	jsl	f:clear_ram_1c00_1cff
	stz	a:title_menu_cursor
	jsl	f:load_title_screen
	lda	#$0001
	sta	hdma_preset
	brl	next_submode
@running:
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
	lda	#GAME_MODE_GAME_START
	brl	set_game_mode

title_result_sound_check:
	; (not executed in the CDL traces)
	lda	#GAME_MODE_SOUND_CHECK
	brl	set_game_mode

title_result_none:
	rtl

; GAME_MODE_DEMO: fades out, sets 2 players, runs run_demo; mode_result 1
; (demo over) -> GAME_MODE_KONAMI_LOGO, 2 (Start) -> GAME_MODE_TITLE.
game_mode_demo:
	lda	game_submode
	bne	@running
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	lda	#$0001
	sta	a:title_menu_cursor
	jsl	f:clear_ram_1c00_1cff
	brl	next_submode
@running:
	jsl	f:run_demo
	lda	mode_result
	beq	@return
	dec	a
	bne	@to_title
	lda	#GAME_MODE_KONAMI_LOGO
	brl	set_game_mode
@to_title:
	; (not executed in the CDL traces)
	lda	#GAME_MODE_TITLE
	brl	set_game_mode
@return:
	rtl

; GAME_MODE_SOUND_CHECK ("SOUND CHECK MODE"): run_sound_check, then
; GAME_MODE_TITLE. Nothing in the game enters this mode (the title menu's
; result 3 is only set by the unreferenced title_menu_unused_sound_check).
game_mode_sound_check:
	; (not executed in the CDL traces)
	lda	game_submode
	bne	@running
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_ram_1c00_1cff
	stz	a:inidisp_shadow
	brl	next_submode
@running:
	jsl	f:run_sound_check
	lda	mode_result
	beq	@return
	lda	#GAME_MODE_TITLE
	brl	set_game_mode
@return:
	rtl

; GAME_MODE_GAME_START: stage_number = 1, blinks the chosen title entry for
; $50 frames (wait_timer), fades out, init_new_game + init_continues, then
; GAME_MODE_OPTIONS for OPTION, GAME_MODE_STAGE_SELECT if
; stage_select_enabled, else GAME_MODE_STAGE_CARD.
game_mode_game_start:
	lda	game_submode
	dec	a
	beq	@blink
	bpl	@fade_out
	lda	#$0001
	sta	stage_number
	stz	a:stage_checkpoint
	ldx	#$0050
	brl	next_submode_with_timer
@blink:
	lda	wait_timer
	and	#$0004
	sta	text_erase
	lda	a:title_menu_cursor
	asl	a
	tay
	ldx	a:data_05840A,y
	lda	#$2400
	jsl	f:draw_text_attr
	jsl	f:tick_wait_timer
	bne	@return
	brl	next_submode
@return:
	rtl
@fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	jsr	a:init_new_game
	jsr	a:init_continues
	lda	a:title_menu_cursor
	cmp	#TITLE_OPTION
	bcs	@to_options
	lda	a:stage_select_enabled
	beq	@to_stage_card
	; (not executed in the CDL traces)
	lda	#GAME_MODE_STAGE_SELECT
	brl	set_game_mode
@to_stage_card:
	lda	#GAME_MODE_STAGE_CARD
	brl	set_game_mode
@to_options:
	lda	#GAME_MODE_OPTIONS
	brl	set_game_mode

; New game: clears stage_gfx_loaded and falls into init_players.
init_new_game:
	stz	a:stage_gfx_loaded

; Resets both players' weapons, barrier, bombs (1), scores, next-extend
; counters (20000) and lives (option_lives; player 2 gets 0 in a 1-player
; game); difficulty = option_level. Also used by the continue.
init_players:
	stz	a:stage_state
	stz	a:topdown_state
	stz	a:life_transfer_disabled
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:p1_weapon_slot_other
	stz	a:p2_weapon_slot_other
	stz	a:p1_weapon_1
	stz	a:p2_weapon_1
	stz	a:p1_weapon_2
	stz	a:p2_weapon_2
	stz	a:p1_weapon_select
	stz	a:p2_weapon_select
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
	beq	@store_p2_lives
	lda	a:option_lives
@store_p2_lives:
	sta	a:p2_lives
	lda	a:option_level
	sta	difficulty
	rts

; continues_left = continues_per_difficulty[difficulty].
init_continues:
	ldy	difficulty
	lda	a:continues_per_difficulty,y
	sta	a:continues_left
	rts

; GAME_MODE_STAGE_SELECT (never run): Up/Down/Select choose stage_number
; 1-6 on the stage card screen, Start -> GAME_MODE_STAGE_CARD.
game_mode_stage_select:
	; (not executed in the CDL traces)
	lda	game_submode
	dec	a
	beq	@fade_in
	bmi	@init
	brl	@fade_out
@init:
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:load_data_list
	ldy	#$8412
	jsl	f:sub_009982
	ldx	#$841B
	lda	#$2400
	jsl	f:draw_text_attr
	lda	#$0100
	sta	demo_timer
	brl	next_submode
@fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
	and	#$000F
	sta	a:inidisp_shadow
@check_level:
	cmp	#$000F
	bcs	@select
	inc	a:inidisp_shadow
	plp
	rtl
@select:
	plp
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	jsl	f:draw_text
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	@check_move
	lda	#$0002
	jsl	f:queue_sound
	brl	next_submode
@check_move:
	bit	#$2C00
	bne	@move
	rtl
@move:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_UP
	beq	@next_stage
	dec	stage_number
	bne	@return
	lda	#$0006
	sta	stage_number
	rtl
@next_stage:
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	@return
	lda	#$0001
	sta	stage_number
@return:
	rtl
@fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	next_game_mode

; GAME_MODE_STAGE_CARD: draws the stage name (data_058428), scores and
; lives; button masks; fades in, loads the stage graphics unless
; stage_gfx_loaded, starts the music, fades out; stage_index =
; stage_number - 1 -> GAME_MODE_STAGE_PLAY.
game_mode_stage_card:
	lda	game_submode
	dec	a
	bne	@not_submode1
	brl	@fade_in
@not_submode1:
	bmi	@init
	brl	@fade_out
@init:
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_ram_1c00_1cff
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:load_data_list
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:draw_score_board
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	lda	#$2400
	jsl	f:draw_text_attr
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
@fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
	and	#$000F
	sta	a:inidisp_shadow
@check_level:
	cmp	#$000F
	bcs	@faded_in
	inc	a:inidisp_shadow
	plp
	rtl
@faded_in:
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
	bne	@gfx_loaded
	lda	stage_number
	jsl	f:load_stage_graphics
@gfx_loaded:
	lda	#$0002
	sta	a:stage_gfx_loaded
	jsl	f:load_stage_music
	brl	next_submode
@fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
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

; GAME_MODE_STAGE_PLAY: run_stage_with_life_transfer until mode_result.
; No lives left -> GAME_MODE_GAME_OVER; stage < 6 -> GAME_MODE_STAGE_CLEAR;
; after stage 6: on HARD -> GAME_MODE_FINAL_SCORE, otherwise (never run)
; the game restarts at stage 1 one level harder.
game_mode_stage_play:
	jsl	f:run_stage_with_life_transfer
	lda	mode_result
	beq	@return
	lda	a:p1_lives
	ora	a:p2_lives
	bne	@lives_left
	jsl	f:reset_sound_queue
	lda	#GAME_MODE_GAME_OVER
	brl	set_game_mode
@lives_left:
	lda	stage_number
	cmp	#$0006
	bcc	@to_stage_clear
	lda	#$0001
	sta	stage_number
	stz	a:stage_checkpoint
	lda	a:option_level
	inc	a
	inc	a
	cmp	#$0006
	bcc	@next_loop
	lda	#GAME_MODE_FINAL_SCORE
	brl	set_game_mode
@next_loop:
	; (not executed in the CDL traces)
	sta	a:option_level
	sta	difficulty
	stz	a:stage_gfx_loaded
	jsr	a:init_continues
	lda	#GAME_MODE_STAGE_CARD
	brl	set_game_mode
@to_stage_clear:
	lda	#GAME_MODE_STAGE_CLEAR
	brl	set_game_mode
@return:
	rtl

; GAME_MODE_STAGE_CLEAR: run_stage_clear, then GAME_MODE_STAGE_CARD.
game_mode_stage_clear:
	lda	game_submode
	bne	@running
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_ram_1c00_1cff
	brl	next_submode
@running:
	jsl	f:run_stage_clear
	lda	mode_result
	beq	@return
	lda	#GAME_MODE_STAGE_CARD
	brl	set_game_mode
@return:
	rtl

; GAME_MODE_GAME_OVER: score board and GAME OVER; uses a continue: with
; continues left -> GAME_MODE_CONTINUE, else back to the title.
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
	jsl	f:reset_video_state
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:load_data_list
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:draw_score_board
	ldx	#$8472
	lda	#$2400
	jsl	f:draw_text_attr
	ldx	#$F513
	jsl	f:load_song_set
	brl	next_submode

game_over_fade_in:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	@check_level
	and	#$000F
	sta	a:inidisp_shadow
@check_level:
	cmp	#$000F
	bcs	@faded_in
	inc	a:inidisp_shadow
	plp
	rtl
@faded_in:
	plp
	lda	#$006B
	jsl	f:queue_sound
	dec	a:continues_left
	bmi	@no_continues
	lda	#$0080
	sta	mode_timer
	brl	next_submode
@no_continues:
	; (not executed in the CDL traces)
	lda	#$0180
	sta	mode_timer
	lda	#$0003
	sta	game_submode
	rtl

game_over_wait_continue:
	dec	mode_timer
	bne	@return
	brl	next_game_mode
@return:
	rtl

game_over_wait_final:
	; (not executed in the CDL traces)
	dec	mode_timer
	bne	@return
	brl	next_submode
@return:
	rtl

game_over_fade_out:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	game_over_to_title

; GAME_MODE_CONTINUE: CONTINUE / END (continue_cursor), then the player
; choice (1 PLAYER, 2 PLAYERS A/B, stored in title_menu_cursor);
; init_players -> GAME_MODE_STAGE_CARD (the stage and stage_checkpoint
; are kept); END -> GAME_MODE_TITLE.
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
	bit	#JOY_START
	beq	@return
	lda	#$0002
	jsl	f:queue_sound
	lda	a:continue_cursor
	beq	@continue_chosen
	; (not executed in the CDL traces)
	lda	#$0003
	brl	set_submode
@continue_chosen:
	lda	a:title_menu_cursor
	sta	a:continue_cursor
	lda	#$0003
	sta	a:continue_option_count
	ldx	#$8490
	jsl	f:draw_text
	brl	next_submode
@return:
	rtl

continue_player_menu:
	jsr	a:continue_move_cursor
	jsr	a:continue_draw_player_menu
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_START
	beq	@return
	lda	#$0002
	jsl	f:queue_sound
	lda	a:continue_cursor
	sta	a:title_menu_cursor
	stz	a:continue_cursor
	brl	next_submode
@return:
	rtl

continue_fade_out:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	@faded_out
	dec	a:inidisp_shadow
	plp
	rtl
@faded_out:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	a:continue_cursor
	bne	game_over_to_title
	jsr	a:init_players
	lda	#GAME_MODE_STAGE_CARD
	brl	set_game_mode
game_over_to_title:
	; (not executed in the CDL traces)
	stz	a:stage_checkpoint
	lda	#GAME_MODE_TITLE
	brl	set_game_mode

; Up/Down/Select move continue_cursor through continue_option_count entries.
continue_move_cursor:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#JOY_SELECT|JOY_UP|JOY_DOWN
	beq	@return
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#JOY_UP
	bne	@move_up
	lda	a:continue_cursor
	inc	a
	cmp	a:continue_option_count
	bcc	@store
	lda	#$0000
@store:
	sta	a:continue_cursor
	rts
@move_up:
	lda	a:continue_cursor
	dec	a
	bpl	@store_up
	lda	a:continue_option_count
	dec	a
@store_up:
	sta	a:continue_cursor
@return:
	rts

continue_draw_menu:
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$847E
	pha
	jsl	f:draw_text_attr
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
	jsl	f:draw_text_attr
	rts

; Draws the word at X + 1 as one digit at VRAM word address Y, tile
; attributes in A.
draw_digit_of_value:
	sta	zp_FA
	phx
	jsl	f:begin_vram_transfer
	plx
	lda	$00,x
	inc	a
	jsl	f:draw_digit
	jsl	f:end_vram_transfer
	rtl

continue_draw_player_menu:
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058404,y
	ldx	#$8599
	jsl	f:draw_text_attr
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058402,y
	ldx	#$85A6
	jsl	f:draw_text_attr
	lda	a:continue_cursor
	asl	a
	tay
	lda	a:data_058400,y
	ldx	#$85B4
	jsl	f:draw_text_attr
	rts

; GAME_MODE_OPTIONS: run_options, then GAME_MODE_TITLE.
game_mode_options:
	lda	game_submode
	bne	@running
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_ram_1c00_1cff
	bra	next_submode
@running:
	jsl	f:run_options
	lda	mode_result
	beq	@return
	lda	#GAME_MODE_TITLE
	bra	set_game_mode
@return:
	rtl

; GAME_MODE_FINAL_SCORE ("FINAL SCORE" after the ending): run_final_score,
; then GAME_MODE_OPENING.
game_mode_final_score:
	lda	game_submode
	bne	@running
	jsl	f:reset_sound_queue
	jsl	f:reset_video_state
	jsl	f:clear_ram_1c00_1cff
	bra	next_submode
@running:
	jsl	f:run_final_score
	lda	mode_result
	beq	@return
	; (not executed in the CDL traces)
	lda	#GAME_MODE_OPENING
	bra	set_game_mode
@return:
	rtl
	; CDL: not accessed
	.byte	$A2, $80, $00
; wait_timer = X, then next_submode.
next_submode_with_timer:
	stx	wait_timer
; game_submode + 1 (clears zp_38). Jumped to (brl) by the mode handlers, returns with rtl.
next_submode:
	lda	game_submode
	inc	a
	bra	set_submode
; game_mode + 1, sub-mode 0.
next_game_mode:
	lda	game_mode
	inc	a

; game_mode = A, sub-mode 0, mode_result = 0.
set_game_mode:
	sta	game_mode
	lda	#$0000
	sta	mode_result
; game_submode = A.
set_submode:
	sta	game_submode
	stz	zp_38
	rtl
; game_mode + 1 keeping game_submode (the opening enters the title at sub-mode 1).
next_game_mode_keep_submode:
	inc	game_mode
	stz	mode_result
	stz	zp_38
	rtl

; Decrements wait_timer down to 0; Z set when it is 0.
tick_wait_timer:
	lda	wait_timer
	beq	@return
	dec	wait_timer
@return:
	rtl

; (no caller found; decoded because it follows the end of a routine)
; Never called: unpause_and_reset_display, demo_mode = 0.
stop_demo_and_reset_display:
	; (not executed in the CDL traces)
	jsl	f:unpause_and_reset_display
	rep	#$20
	stz	demo_mode
	rtl

; Never called: paused = 0, display off, clears the mode work area, display on.
unpause_and_reset_display:
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

; update_life_transfer, then run_stage.
run_stage_with_life_transfer:
	jsr	a:update_life_transfer

; One frame of a stage: weapon swap (X), pause / unpause with Start
; (not in the demo or while pause_disabled; pause_sounds, apply_pause_dimming),
; then the side-view or top-down stage code chosen by stage_index
; (tbl_stage_runners). Also called by demo_play.
run_stage:
	rep	#$30
	jsr	a:update_weapon_swap
	lda	demo_mode
	bne	@run
	lda	pause_disabled
	bne	@run
	lda	#$0000
	ldy	a:p1_lives
	beq	@check_p2
	ora	joy1_pressed
@check_p2:
	ldy	a:p2_lives
	beq	@check_start
	ora	joy2_pressed
@check_start:
	bit	#JOY_START
	beq	@check_paused
	lda	paused
	eor	#$0001
	sta	paused
	asl	a
	tay
	lda	a:pause_sounds,y
	jsl	f:queue_sound
	jsr	a:apply_pause_dimming
@check_paused:
	lda	paused
	beq	@run
	rtl
@run:
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

; X toggles each player's weapon slot (p1_weapon_slot / p2_weapon_slot and
; their copies); $1F8E / $1FCE non-zero force slot 2.
update_weapon_swap:
	jsr	a:update_weapon_swap_p1
	lda	a:p2_spin
	beq	@not_forced
	lda	#$0002
	sta	a:p2_weapon_slot_other
	sta	a:p2_weapon_slot
	rts
@not_forced:
	lda	a:p2_lives
	beq	@apply
	lda	joy2_pressed
	bit	#JOY_X
	beq	@apply
	lda	a:p2_weapon_select
	eor	#$0002
	sta	a:p2_weapon_select
@apply:
	lda	a:p2_weapon_select
	sta	a:p2_weapon_slot_other
	eor	#$0002
	sta	a:p2_weapon_slot
	rts

update_weapon_swap_p1:
	lda	a:p1_spin
	beq	@not_forced
	lda	#$0002
	sta	a:p1_weapon_slot_other
	sta	a:p1_weapon_slot
	rts
@not_forced:
	lda	a:p1_lives
	beq	@apply
	lda	joy1_pressed
	bit	#JOY_X
	beq	@apply
	lda	a:p1_weapon_select
	eor	#$0002
	sta	a:p1_weapon_select
@apply:
	lda	a:p1_weapon_select
	sta	a:p1_weapon_slot_other
	eor	#$0002
	sta	a:p1_weapon_slot
	rts

; On pause: saves inidisp_shadow and the top-down view brightnesses and
; lowers them by 4; on unpause: restores them.
apply_pause_dimming:
	lda	paused
	beq	@unpause
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
@unpause:
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
	bne	@return
	and	#$000F
	sec
	sbc	#$0004
	bpl	@store
	; (not executed in the CDL traces)
	lda	#$0000
@store:
	sta	a:inidisp_shadow
@return:
	rts

dim_p1_brightness:
	lda	a:p1_view_brightness
	bit	#$0080
	bne	@return
	and	#$000F
	sec
	sbc	#$0004
	bpl	@store
	lda	#$0000
@store:
	sta	a:p1_view_brightness
@return:
	rts

dim_p2_brightness:
	lda	a:p2_view_brightness
	bit	#$0080
	bne	@return
	and	#$000F
	sec
	sbc	#$0004
	bpl	@store
	lda	#$0000
@store:
	sta	a:p2_view_brightness
@return:
	rts

; Two players only, unless life_transfer_disabled: a player with no
; lives who presses A takes one from the other player (if they have 2+).
update_life_transfer:
	lda	a:life_transfer_disabled
	bne	life_transfer_return
	lda	a:title_menu_cursor
	beq	life_transfer_return
	jsr	a:life_transfer_to_p1
	jmp	a:life_transfer_to_p2

life_transfer_to_p1:
	lda	a:p1_lives
	bne	life_transfer_return
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#JOY_A
	beq	life_transfer_return
	lda	a:p2_lives
	cmp	#$0002
	bcc	life_transfer_return
	inc	a:p1_lives
	dec	a:p2_lives
	lda	#$0001
	sta	a:p1_bombs
life_transfer_return:
	rts
life_transfer_to_p2:
	lda	a:p2_lives
	bne	@return
	; (not executed in the CDL traces)
	lda	joy2_pressed
	bit	#JOY_A
	beq	@return
	lda	a:p1_lives
	cmp	#$0002
	bcc	@return
	inc	a:p2_lives
	dec	a:p1_lives
	lda	#$0001
	sta	a:p2_bombs
@return:
	rts
