# Game flow

How the game goes from power-on to the stages and back: the game modes,
the attract mode, the menus, the screens between stages and the side-view
stage state machine. Code in `src/game/`, constants in `src/game/game.inc`.
Everything here was read in the code and checked in the emulator of the
private repository (watching `game_mode`, `game_submode`, `stage_state` and
`opening_scene` frame by frame from power-on, taking screenshots, and
poking `game_mode` to enter the modes the traces never reach).

## Game modes

`run_game_mode` runs once per frame from the NMI frame handler: it
increments `frame_counter` and jumps to the handler of `game_mode` in
`tbl_game_modes`. Most handlers step their own sub-mode, `game_submode`,
with `next_submode`; they leave with `set_game_mode` (A = new mode,
sub-mode 0), `next_game_mode` or `next_game_mode_keep_submode`. A handler
that runs a bigger piece of code (a menu, a screen, a stage) waits for it
to set `mode_result` (0 = still running, other values = how it ended).
Each mode's private variables live in the work area `$1C00-$1CFF`
(`mode_work`), cleared by `clear_ram_1c00_1cff` when the mode starts;
`src/ram.inc` gives the same addresses a name per mode (`mode_step`,
`demo_p1_ptr`, `options_cursor`, `stage_bonus`, ...).

| value | constant | handler | what |
|---|---|---|---|
| `$00` | `GAME_MODE_KONAMI_LOGO` | `game_mode_konami_logo` | Konami logo (`run_konami_logo`); Start skips to the title |
| `$01` | `GAME_MODE_UNUSED_1` | `game_mode_unused_1` | just returns; never entered |
| `$02` | `GAME_MODE_OPENING` | `game_mode_opening` | opening cinematic, then the title logo animation |
| `$03` | `GAME_MODE_TITLE` | `game_mode_title` | title menu (`run_title_menu`) |
| `$04` | `GAME_MODE_DEMO` | `game_mode_demo` | attract demo (`run_demo`) |
| `$05` | `GAME_MODE_SOUND_CHECK` | `game_mode_sound_check` | "SOUND CHECK MODE" (`run_sound_check`); unreachable |
| `$06` | `GAME_MODE_GAME_START` | `game_mode_game_start` | the chosen title entry blinks; new game |
| `$07` | `GAME_MODE_STAGE_SELECT` | `game_mode_stage_select` | stage select; only with `stage_select_enabled` |
| `$08` | `GAME_MODE_STAGE_CARD` | `game_mode_stage_card` | stage name, scores and lives before a stage |
| `$09` | `GAME_MODE_STAGE_PLAY` | `game_mode_stage_play` | a stage (`run_stage_with_life_transfer`) |
| `$0A` | `GAME_MODE_STAGE_CLEAR` | `game_mode_stage_clear` | stage clear bonus screen (`run_stage_clear`) |
| `$0B` | `GAME_MODE_GAME_OVER` | `game_mode_game_over` | GAME OVER; spends a continue |
| `$0C` | `GAME_MODE_CONTINUE` | `game_mode_continue` | CONTINUE / END, then 1 PLAYER / 2 PLAYERS A / B |
| `$0D` | `GAME_MODE_OPTIONS` | `game_mode_options` | "OPTION MODE" (`run_options`) |
| `$0E` | `GAME_MODE_FINAL_SCORE` | `game_mode_final_score` | "FINAL SCORE" after the ending (`run_final_score`) |

The usual sequence, with no input from power-on: Konami logo (about 300
frames) → opening (about 2300 frames) → title → after `$0300` frames
without input, demo → Konami logo again. The demos cycle through stages
1, 2 and 4 (`demo_stages`, `demo_index`).

A game: title (Start) → `GAME_MODE_GAME_START` (`init_new_game`,
`init_continues`) → stage card → stage → stage clear → stage card of the
next stage → ... When both players are out of lives the stage ends and
`game_mode_stage_play` goes to game over; with `continues_left` the
continue menu restarts the same stage (from `stage_checkpoint`) after
`init_players`. After stage 6, on HARD the game goes to the final score;
on EASY and NORMAL the code (never run in the traces) restarts at stage 1
with `option_level` one step harder and the continues of that level.

`title_menu_cursor` values are `TITLE_1_PLAYER`, `TITLE_2_PLAYERS_A`,
`TITLE_2_PLAYERS_B`, `TITLE_OPTION`; it stays meaningful during play (0 =
one player).

## The opening and the title

`game_mode_opening` sets `stage_number` to 0 and runs the side-view stage
code (`run_side_view_stage`): stage 0 has no gameplay, its setup goes to
`STAGE_STATE_CINEMATIC`, whose frame (`stage_cinematic`) runs
`run_opening_cinematic` (`src/game/opening.asm`). The cinematic steps
`opening_state` through `tbl_opening_states` and plays seven scenes
(`opening_scene`, `tbl_opening_scenes`), each for
`opening_scene_durations[scene]` frames:

| scene | handler | on screen |
|---|---|---|
| 0 | `opening_scene_city` | the city at night fades in, "A.D. 2636" |
| 1 | `opening_scene_vortex` | a vortex forms in the clouds above the city |
| 2 | `opening_scene_beam` | the beam strikes, white flash (`opening_beam_flash`) |
| 3 | `opening_scene_ruins` | the ruined city, the alien's face appears |
| 4 | `opening_scene_scrolling_text` | the red text "The Alien Wars begin..." scrolls by |
| 5 | `opening_scene_hero_face` | the hero's face, "It's time for revenge." |
| 6 | `opening_scene_heroes` | both heroes, "Let's attack aggressively." |

Then `game_mode_opening` loads the title (`opening_load_title_screen`):
the CONTRA III logo is a Mode 7 layer zoomed in from scale 0
(`opening_zoom_title_logo`), the sprite words THE, ALIEN and WARS slide in
(`title_the_x`, `title_alien_x`, `title_wars_x`, drawn by
`draw_title_word_sprites`), the logo shakes (`title_shake`) and the mode
continues at `GAME_MODE_TITLE`, sub-mode 1. Start during the opening skips
straight to the title (`load_title_screen` draws it at full size).

The title menu (`run_title_menu`) moves `title_menu_cursor` with
Up/Down/Select; `title_menu_timeout` (`$0300` frames, reset by every
move) starts the demo. While the title is up, `load_demo_stage_graphics`
loads the graphics of the next demo's stage.

Three button codes are in the ROM but nothing calls them:
`check_button_code_unused` (only plays a sound), `check_30_lives_code`
(`option_lives` = 30) and `check_stage_select_code` (sets
`stage_select_enabled`, which makes `game_mode_game_start` go to
`game_mode_stage_select`). Each compares the d-pad against a three-step
sequence (`data_0586D3`, `data_0586D9`, `data_0586DF`) within a time
limit and then waits for a button.

## The attract demo

`run_demo` (`demo_init`, `demo_play`, `demo_end`). `demo_init` sets the
stage from `demo_stages` and its checkpoint from `demo_stage_checkpoints`,
two players with 3 lives on NORMAL (`demo_init_players`), and resets the
random number generator and `frame_counter` so the game replays exactly.
`demo_play` runs `run_stage` like normal play, but first
`demo_update_input` replaces `joy1_held`/`joy1_pressed` and the pad 2
copies with recorded events: each event is a button word and a frame count
(4 bytes), read through the 24-bit pointers `demo_p1_ptr` / `demo_p2_ptr`
(set from the tables `data_0584EC` / `data_0584F5`). The demo ends after
`demo_timer` (`$0800`) frames, at the end of the stage or on Start
(`demo_result`). `demo_mode` keeps `run_stage` from pausing.

A debug flag, `demo_record_mode` (cleared at power-on, never set), makes
`demo_update_input` record the pads instead, to SRAM at `$70:0000` and
`$70:0400` (`demo_record_p1`, `demo_record_p2`).

## The stage frame: pause, weapons, lives

`run_stage` is the frame of every stage (and of the demo):

- `update_weapon_swap`: X swaps the player's two weapon slots.
- pause: Start (from a player with lives) toggles `paused`, plays
  `pause_sounds[paused]` and dims the screen (`apply_pause_dimming`); not
  in the demo (`demo_mode`) or while `pause_disabled` is set (fades,
  cinematics, `stage_pause_disabled`).
- then the stage code by `stage_index` (`tbl_stage_runners`):
  `enter_side_view_stage` (stages 1, 3, 4, 6) or `enter_top_down_stage`
  (stages 2 and 5).

`run_stage_with_life_transfer` first runs `update_life_transfer`: in a
two-player game a player with no lives left takes one from the other
player by pressing A, if the other has at least 2 (not while
`life_transfer_disabled`, which some bosses set).

## Side-view stages

`run_side_view_stage` dispatches `stage_state`:

| value | constant | handler | what |
|---|---|---|---|
| 0 | `STAGE_STATE_INIT` | `stage_init` | per-layout parameters, players start dead (they drop in), colour math |
| 1 | `STAGE_STATE_SETUP` | `stage_setup_video` | BG modes and maps, graphics, `stage_layout_init` |
| 2 | `STAGE_STATE_PLAY` | `stage_play` | fade in, one frame (`stage_frame`) |
| 3 | `STAGE_STATE_EXIT` | `stage_exit` | fade out; `mode_result` = 1 |
| 4 | `STAGE_STATE_CINEMATIC` | `stage_cinematic` | the opening (stage 0) |

`stage_play` moves to `STAGE_STATE_EXIT` when objects set
`stage_exit_request` (end of the stage) or when both players are out of
lives. The per-stage choices go through `stage_layout`
(`stage_layouts[stage_number]`, x2: stage 1 → 0, 3 → 2, 4 → 4, 6 → 6,
opening → 8), plus `$0A` when the stage restarts past its midpoint
(`stage_checkpoint`, set by objects at the midpoint and cleared when a new
stage starts). `stage_layout_init` starts each layout's music and effects
(`layout_init_stage1`, `layout_init_stage1_checkpoint`, ...).
`apply_player_autopilot` replaces the players' input while objects set
`player_autopilot_mode` (scripted walks).

`update_palette_anim` (`src/game/stage_palette_anim.asm`) runs the palette
animation chosen by objects with `start_palette_anim`.

## Screens between stages

- Stage card (`game_mode_stage_card`): the stage name, the score board
  (`draw_score_board`: HI SCORE, 1P/2P SCORE, REST), the stage music; it
  also sets the button masks the player code reads (`button_fire` Y,
  `button_jump` B, `button_bomb` A, `button_stand_still` R).
- Stage clear (`run_stage_clear`): a picture of the stage, a 10000-point
  `stage_bonus` counted into the living players' scores 100 points a frame
  (`transfer_stage_bonus`), and the next stage's graphics loaded in the
  meantime (`load_stage_graphics`, so `stage_gfx_loaded` skips the load on
  the stage card).
- Game over and continue: `continues_left` comes from
  `continues_per_difficulty` (2 on EASY, 4 on NORMAL and HARD); each game
  over spends one.
- OPTION (`run_options`): PLAYER (`option_lives` 3/5/7 from
  `lives_options`), LEVEL (`option_level`, `DIFFICULTY_*`), SOUND
  (`option_sound`, sent with `sound_mode_commands`), EXIT. The options, the
  high score and `demo_record_mode` survive a reset (see `boot_signature`).
- FINAL SCORE (`run_final_score`) after the ending.
- SOUND CHECK (`run_sound_check`, game mode 5): the d-pad picks
  `sound_check_id` (`$00-$6A`), Y plays it, B stops. No code enters this
  mode.

## Scores and extra lives

Scores are BCD, 4 bytes, in the player stat blocks (`p1_score`,
`p2_score`; capped at 9999999); `high_score` is updated by
`update_high_score`. `add_score` (A = BCD points, X = stat block `$1F80` /
`$1FC0`; `add_score_for_player_obj` and `add_score_for_topdown_player`
take a player object instead) also counts down the next-extend counter
(`p1_next_extend`, `p2_next_extend`): the first extra life at 20000
points, then one every 60000; lives are capped at 30.

## Values useful for cheats

| address | name | effect |
|---|---|---|
| `$1E3C` | `option_lives` | lives at the start of a game (30 with the unused code) |
| `$1E60` | `stage_select_enabled` | non-zero: stage select after the title |
| `$1E62` | `continues_left` | continues |
| `$1E3E` / `$84` | `option_level` / `difficulty` | 0 EASY, 2 NORMAL, 4 HARD |
| `$1E40` | `stage_checkpoint` | 1: start the stage from its midpoint |
| `$1FB6` | `p1_next_extend` | points to the next extra life |
