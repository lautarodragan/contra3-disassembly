; game/game.inc -- constants of the game flow (game modes, stage states,
; title menu entries, difficulty). Included by common.inc.

.ifndef GAME_INC
GAME_INC = 1

; game_mode values: index into tbl_game_modes (run_game_mode). A mode's
; handler runs its sub-mode game_submode and ends with set_game_mode,
; next_game_mode or next_submode. Checked in the emulator by poking
; game_mode (see the book, "Game flow").
GAME_MODE_KONAMI_LOGO   = $00	; game_mode_konami_logo
GAME_MODE_UNUSED_1      = $01	; game_mode_unused_1 (just returns)
GAME_MODE_OPENING       = $02	; game_mode_opening: opening cinematic, then the title logo
GAME_MODE_TITLE         = $03	; game_mode_title: title menu
GAME_MODE_DEMO          = $04	; game_mode_demo: attract demo
GAME_MODE_SOUND_CHECK   = $05	; game_mode_sound_check: "SOUND CHECK MODE" (unreachable)
GAME_MODE_GAME_START    = $06	; game_mode_game_start: chosen entry blinks, new game
GAME_MODE_STAGE_SELECT  = $07	; game_mode_stage_select (only with stage_select_enabled)
GAME_MODE_STAGE_CARD    = $08	; game_mode_stage_card: stage name, scores, lives
GAME_MODE_STAGE_PLAY    = $09	; game_mode_stage_play: a stage (side-view or top-down)
GAME_MODE_STAGE_CLEAR   = $0A	; game_mode_stage_clear: bonus screen
GAME_MODE_GAME_OVER     = $0B	; game_mode_game_over
GAME_MODE_CONTINUE      = $0C	; game_mode_continue: CONTINUE / END, then the player choice
GAME_MODE_OPTIONS       = $0D	; game_mode_options: "OPTION MODE"
GAME_MODE_FINAL_SCORE   = $0E	; game_mode_final_score: after stage 6 on HARD

; stage_state values: index into tbl_stage_states (run_side_view_stage).
STAGE_STATE_INIT        = 0	; stage_init
STAGE_STATE_SETUP       = 1	; stage_setup_video
STAGE_STATE_PLAY        = 2	; stage_play
STAGE_STATE_EXIT        = 3	; stage_exit: fade out, mode_result = 1
STAGE_STATE_CINEMATIC   = 4	; stage_cinematic: the opening cinematic (stage_number 0)

; title_menu_cursor values
TITLE_1_PLAYER          = 0
TITLE_2_PLAYERS_A       = 1
TITLE_2_PLAYERS_B       = 2
TITLE_OPTION            = 3

; difficulty / option_level values (x2)
DIFFICULTY_EASY         = 0
DIFFICULTY_NORMAL       = 2
DIFFICULTY_HARD         = 4

; joypad bits (joy1_held, joy1_pressed, ...; the SNES auto-read layout)
JOY_B                   = $8000
JOY_Y                   = $4000
JOY_SELECT              = $2000
JOY_START               = $1000
JOY_UP                  = $0800
JOY_DOWN                = $0400
JOY_LEFT                = $0200
JOY_RIGHT               = $0100
JOY_A                   = $0080
JOY_X                   = $0040
JOY_L                   = $0020
JOY_R                   = $0010
JOY_DPAD                = $0F00

.endif
