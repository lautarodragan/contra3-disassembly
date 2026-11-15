; cheats.inc -- build-time cheats (milestone 4).  Included by common.inc.
;
; Every option is a number defined on the ca65 command line
; (-D CHEAT_X=value), normally through `make cheats CHEATS="..."` or
; tools/cheats.py; an option that is not defined gets its default here.
; With every option at its default the ROM is the original, byte for byte
; (`make` checks it).  Each cheat is an `.if CHEAT_X ... .else <original
; code> .endif` at the place it changes (grep for the name), or a routine
; in objects/cheat_code.asm (end of bank $01) called from such a place.
; The book's "Cheats" page explains each one and where it hooks in.
;
; In CHEATS a bare word sets the option to 1 (`infinite_lives` ->
; CHEAT_INFINITE_LIVES=1), `word=n` sets it to n (`damage_mult=2`).

.ifndef CHEATS_INC
CHEATS_INC = 1

; --- player ---------------------------------------------------------------

; 1: losing a life does not decrement the lives (side view: player_state_dead;
; top-down: topdown_lose_life).
.ifndef CHEAT_INFINITE_LIVES
CHEAT_INFINITE_LIVES = 0
.endif

; 1: enemies, their bullets, crushing and kill_players_outside do not kill
; (side view: kill_player cancels the death; top-down: a hit is undone in
; update_topdown_player).  Falling off the bottom of the screen (side view)
; or into a hole (top-down) still kills; see CHEAT_NO_PIT_DEATH.
.ifndef CHEAT_INVINCIBLE
CHEAT_INVINCIBLE = 0
.endif

; 1 (side view): falling off the bottom of the screen respawns the player
; as after a death (PLAYER_STATE_OUT) without taking a life or the weapon.
.ifndef CHEAT_NO_PIT_DEATH
CHEAT_NO_PIT_DEATH = 0
.endif

; 1: throwing a smart bomb does not use one up (check_bomb_button,
; td_check_smart_bomb).
.ifndef CHEAT_INFINITE_BOMBS
CHEAT_INFINITE_BOMBS = 0
.endif

; 1: a death does not take the weapons away (kill_player,
; topdown_lose_life).  The barrier is still lost.
.ifndef CHEAT_KEEP_WEAPONS
CHEAT_KEEP_WEAPONS = 0
.endif

; WEAPON_* (0-5) given by init_players at the start of a game and after a
; continue, in the active slot (p1_weapon_2 / p2_weapon_2).  0
; (WEAPON_DEFAULT) is the original.
.ifndef CHEAT_START_WEAPON
CHEAT_START_WEAPON = WEAPON_DEFAULT
.endif

; WEAPON_* (0-5) given by init_players in the other slot (p1_weapon_1 /
; p2_weapon_1, X swaps to it).
.ifndef CHEAT_START_WEAPON2
CHEAT_START_WEAPON2 = WEAPON_DEFAULT
.endif

; 1-8: frames between two shots of every weapon (weapon_fire_delays;
; originally 3, 4, 5, 4, 1, 1).  0 keeps the original table.  Side view only.
.ifndef CHEAT_FIRE_DELAY
CHEAT_FIRE_DELAY = 0
.endif

; n >= 1: the players' shots do n times their damage (update_shots, and the
; top-down shot and bomb collisions through sbc_player_damage_x).
.ifndef CHEAT_DAMAGE_MULT
CHEAT_DAMAGE_MULT = 1
.endif

; Percentage of the original HP every enemy and boss starts with (the HP
; tables in bank $05 and the immediates in the handlers, all written with
; ENEMY_HP()).  100 is the original; 0 makes everything die at the first
; hit.  HP_UNKILLABLE stays HP_UNKILLABLE.
.ifndef CHEAT_ENEMY_HP
CHEAT_ENEMY_HP = 100
.endif

; --- game -----------------------------------------------------------------

; n > 0: lives at the start of a game (instead of option_lives); 30 is the
; most the game itself gives (check_30_lives_code, the extra-life cap).
.ifndef CHEAT_START_LIVES
CHEAT_START_LIVES = 0
.endif

; 1-6: the stage a new game starts at (game_mode_game_start).
.ifndef CHEAT_START_STAGE
CHEAT_START_STAGE = 1
.endif

; 1: the stage select screen (game_mode_stage_select) after the title, as
; if stage_select_enabled were set.
.ifndef CHEAT_STAGE_SELECT
CHEAT_STAGE_SELECT = 0
.endif

; n > 0: continues on every difficulty (continues_per_difficulty: 2, 4, 4).
.ifndef CHEAT_CONTINUES
CHEAT_CONTINUES = 0
.endif

; 1: game over does not spend a continue (game_over_fade_in).
.ifndef CHEAT_INFINITE_CONTINUES
CHEAT_INFINITE_CONTINUES = 0
.endif

; --- leftovers of the developers --------------------------------------------

; 1: the unused debug keys are called every frame: debug_player_keys from
; run_player_state (side view; Select held + Up: difficulty, + A: kill with
; one life left, + B: kill, + X: lives, bombs and barrier $8000) and
; td_debug_cheat_buttons from update_topdown_player (top-down; X held + L/R:
; weapons, + A: bombs, + Y: barrier, + B: lives).
.ifndef CHEAT_DEBUG_KEYS
CHEAT_DEBUG_KEYS = 0
.endif

; 1: the unused title screen button codes are checked by title_menu_input:
; Down, Down+Right, Right, Start: 30 lives (check_30_lives_code); Down,
; Down+Left, Left, Start: stage select (check_stage_select_code).
.ifndef CHEAT_BUTTON_CODES
CHEAT_BUTTON_CODES = 0
.endif

; --- checks ---------------------------------------------------------------

.assert CHEAT_START_WEAPON >= 0 && CHEAT_START_WEAPON <= WEAPON_LASER, error, "CHEAT_START_WEAPON: 0-5"
.assert CHEAT_START_WEAPON2 >= 0 && CHEAT_START_WEAPON2 <= WEAPON_LASER, error, "CHEAT_START_WEAPON2: 0-5"
.assert CHEAT_FIRE_DELAY >= 0 && CHEAT_FIRE_DELAY <= 8, error, "CHEAT_FIRE_DELAY: 0-8 (run_player_state zeroes delays above 8)"
.assert CHEAT_DAMAGE_MULT >= 1 && CHEAT_DAMAGE_MULT <= 16, error, "CHEAT_DAMAGE_MULT: 1-16"
.assert CHEAT_ENEMY_HP >= 0 && CHEAT_ENEMY_HP <= 100, error, "CHEAT_ENEMY_HP: 0-100 (percent)"
.assert CHEAT_START_LIVES >= 0 && CHEAT_START_LIVES <= 99, error, "CHEAT_START_LIVES: 0-99"
.assert CHEAT_START_STAGE >= 1 && CHEAT_START_STAGE <= 6, error, "CHEAT_START_STAGE: 1-6"
.assert CHEAT_CONTINUES >= 0 && CHEAT_CONTINUES <= 99, error, "CHEAT_CONTINUES: 0-99"

; Any routine of objects/cheat_code.asm needed.
CHEAT_CODE_NEEDED = (CHEAT_INVINCIBLE | CHEAT_NO_PIT_DEATH | (CHEAT_DAMAGE_MULT > 1))

; --- helpers --------------------------------------------------------------

; An enemy's starting HP: n scaled by CHEAT_ENEMY_HP percent, except
; HP_UNKILLABLE (and HP that is not a positive number, such as $FFFF).
.define ENEMY_HP(n) ((((n) = HP_UNKILLABLE) | ((n) >= $8000) | (CHEAT_ENEMY_HP = 100)) * (n) + ((((n) = HP_UNKILLABLE) | ((n) >= $8000) | (CHEAT_ENEMY_HP = 100)) = 0) * ((n) * CHEAT_ENEMY_HP / 100))

; Per-difficulty HP table row (easy, normal, hard), as words.
.macro enemy_hp_table easy, normal, hard
	.word	ENEMY_HP(easy), ENEMY_HP(normal), ENEMY_HP(hard)
.endmacro

; `sbc $06,x` where A = a target's HP and X = a top-down player shot or
; smart bomb (+$06 = its damage): with CHEAT_DAMAGE_MULT, subtracts it that
; many times (cheat_sbc_damage_x).
.macro sbc_player_damage_x
.if CHEAT_DAMAGE_MULT > 1
	jsl	f:cheat_sbc_damage_x
.else
	sbc	$06,x
.endif
.endmacro

.endif
