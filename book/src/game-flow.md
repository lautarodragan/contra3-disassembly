# Game flow

How the game goes from power-on to the stages and back: the game modes,
the attract mode, the menus, the screens between stages and the side-view
stage state machine. Code in `src/game/`, constants in `src/game/game.inc`.
Everything here was read in the code and checked in the emulator
([Emulator tests](emulator.md); watching `game_mode`, `game_submode`, `stage_state` and
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
(`mode_work`), cleared by `clear_mode_work` when the mode starts;
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
`init_players`.

### After stage 6: the loop

When stage 6 ends (`stage_exit_request`, set by the ending object),
`game_mode_stage_play` sets `stage_number` to 1, clears
`stage_checkpoint` and adds 2 to `option_level`: on EASY and NORMAL the
result is stored in `option_level` and `difficulty`, `continues_left`
starts again from `init_continues` (the new level's) and the game goes to
the stage card of stage 1; on HARD (6) it goes
to `GAME_MODE_FINAL_SCORE` instead. Before that, the ending object
(`update_ending_sequence`, [Enemies and bosses](enemies-late.md#the-ending))
shows a closing message, one BG3 map per difficulty
(`ptrs_ending_message_loads`: `ending_message_easy`,
`ending_message_normal`, `ending_message_hard`):

| level | after the escape | closing message | then |
|---|---|---|---|
| EASY | the lair explodes behind the helicopter | "Congratulations! You've beaten the easy mode. Do you think you are sharp enough to beat the normal mode? Remember, this is not the end. It's just the beginning!" | PUSH START KEY (`ending_sequence_state_29`), Start: stage 1 on NORMAL, 4 continues instead of 2 |
| NORMAL | the same | "You're getting better! But this Alien War only gets harder. So if you want to fully test your game play techniques prepare yourself for the ultimate challenge." | the same: stage 1 on HARD (4 continues) |
| HARD | the brain's last, armoured form chases the helicopter and is shot down | "Way to go! You've conquered the toughest Contra challenge yet. Your heroic deeds have restored peace to a war torn world. The Alien forces have been destroyed by a gaming champion! Your efforts will not be forgotten....." | five pictures over the message, the staff credits over the helicopter, the crowd ("A Peaceful Time Will Come!") and fireworks, FINAL SCORE; Start there goes back to the opening (`GAME_MODE_OPENING`) |

So only a HARD win shows the full ending. The emulator plays run every
row of this table ([Emulator tests](emulator.md): `stage6_ending_easy`,
`stage6_boss` on NORMAL, `stage6_ending_hard`, from stage 6's midpoint;
`option_level`, `difficulty` and `continues_left` read after the Start
press), and the same is seen on the real game. The CDL has them too: the
tracer runs the plays as scenarios (`play_stage6_ending_easy`, ...), so the
loop, the Start presses and FINAL SCORE's return to the opening are no
longer marked "not executed".

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

The captions of scenes 5 and 6 appear part by part
(`opening_hero_face_caption_delays` / `_parts`,
`opening_heroes_caption_delays` / `_parts`; each part is a strip of tiles
from `caption_part_vram_addrs` and `ptrs_caption_part_blocks`). The
vortex is 16 objects (`opening_object_slots`, `opening_vortex_object_y`,
`opening_vortex_object_anims`).

Then `game_mode_opening` loads the title (`opening_load_title_screen`):
the CONTRA III logo is a Mode 7 layer zoomed in from scale 0
(`opening_zoom_title_logo`), the sprite words THE, ALIEN and WARS slide in
(`title_the_x`, `title_alien_x`, `title_wars_x`, drawn by
`draw_title_word_sprites`), the logo shakes (`title_shake`) and the mode
continues at `GAME_MODE_TITLE`, sub-mode 1. Start during the opening skips
straight to the title (`load_title_screen` draws it at full size).

The title menu (`run_title_menu`) moves `title_menu_cursor` with
Up/Down/Select; `title_menu_timeout` (`$0300` frames, reset by every
move) starts the demo. The entries are drawn with the attribute of
`title_menu_attrs_1p` ... `title_menu_attrs_option` at the cursor's index:
four overlapping tables, `$2400` (highlighted) at the cursor's position;
the continue menus do the same (`continue_menu_attrs`,
`continue_player_menu_attrs_1p` ...). While the title is up, `load_demo_stage_graphics`
loads the graphics of the next demo's stage.

Three button codes are in the ROM but nothing calls them:
`check_button_code_unused` (Right, Down, Down+Right, X: only plays a
sound and returns with the carry set, probably once the way into the sound
check), `check_30_lives_code`
(`option_lives` = 30) and `check_stage_select_code` (sets
`stage_select_enabled`, which makes `game_mode_game_start` go to
`game_mode_stage_select`). Each compares the d-pad against a three-step
sequence (`code_unused_dpad_sequence`, `code_30_lives_dpad_sequence`,
`code_stage_select_dpad_sequence`) within a time limit and then waits for
a button.

## The attract demo

`run_demo` (`demo_init`, `demo_play`, `demo_end`). `demo_init` sets the
stage from `demo_stages` and its checkpoint from `demo_stage_checkpoints`,
two players with 3 lives on NORMAL (`demo_init_players`), and resets the
random number generator and `frame_counter` so the game replays exactly.
`demo_play` runs `run_stage` like normal play, but first
`demo_update_input` replaces `joy1_held`/`joy1_pressed` and the pad 2
copies with recorded events: each event is a button word and a frame count
(4 bytes), read through the 24-bit pointers `demo_p1_ptr` / `demo_p2_ptr`
(set from the tables `demo_p1_input_ptrs` / `demo_p2_input_ptrs`). The demo ends after
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
- FINAL SCORE (`run_final_score`) after the ending on HARD; Start
  (`final_score_wait_start`) goes back to the opening.
- SOUND CHECK (`run_sound_check`, game mode 5): the d-pad picks
  `sound_check_id` (`$00-$6A`), Y plays it, B stops, Start goes back to
  the title. No code enters this mode; the `sound_check` cheat option
  enters it from the title ([Cheats](cheats.md#leftovers-of-the-developers)).

## Scores and extra lives

Scores are BCD, 4 bytes, in the player stat blocks (`p1_score`,
`p2_score`; capped at 9999999); `high_score` is updated by
`update_high_score`. `add_score` (A = BCD points, X = stat block `$1F80` /
`$1FC0`; `add_score_for_player_obj` and `add_score_for_topdown_player`
take a player object instead) also counts down the next-extend counter
(`p1_next_extend`, `p2_next_extend`): the first extra life at 20000
points, then one every 60000; lives are capped at 30.

## Stage numbering

`stage_number` (`$86`) is the stage being played, 1-6 (0 during the
opening, which runs as side-view stage 0); `stage_index` (`$70`) is
`stage_number - 1`, set by the stage card and by the demo, and only
selects the stage's frame code (`tbl_stage_runners`). The side-view stages
then work through `stage_layout`, which `stage_init` takes from
`stage_layouts[stage_number]`. Every place that depends on a stage's
number was searched for (every read of `stage_number` and `stage_index`,
every table they index, every comparison of either; `$86` and `$70` are
otherwise only object fields, `$86,x` and `$70,x`) and goes through the
constants and macros of `src/game/stages.inc`: `STAGE_1` ... `STAGE_6` are
the stage numbers of the original stages, `STAGE_COUNT` and `STAGE_LAST`
the loop, `LAYOUT_*` the side-view layouts, and `per_stage_addr`,
`per_stage_word`, `per_stage_byte`, `per_layout_addr`, `per_layout_word`
write the tables. The default build assembles to the original bytes; the
extra-stage build ([Adding a stage](adding-a-stage.md)) inserts a stage 2.

**Comparisons with a stage number** (20 places; the constant each now uses):

| routine | test | what for |
|---|---|---|
| `game_mode_game_start` | `CHEAT_START_STAGE` (`STAGE_1`) | a new game starts at stage 1 |
| `game_mode_stage_select` | `STAGE_COUNT`, `STAGE_COUNT+1`, `STAGE_1` | Up from 1 wraps to the last stage, Down past it to 1 |
| `game_mode_stage_play` | `STAGE_LAST`, `STAGE_1` | after the last stage: the loop (EASY, NORMAL) or FINAL SCORE (HARD), see below |
| `stage_clear_load_next_stage`, `stage_clear_fade_out` | `STAGE_COUNT+1`, `STAGE_1` | the next stage's graphics and number (never wraps: no stage clear after the last stage) |
| `game_mode_opening`, `stage_setup_video` | 0 (`STAGE_OPENING`) | the opening goes to `STAGE_STATE_CINEMATIC` |
| `stage_setup_video` | `STAGE_4` | `draw_bg3_block_map` |
| `fill_bg_screen` | `STAGE_4` | BG1 drawn 64 columns wide |
| `weapon_item_move` (the items' fall) | `STAGE_4` | `weapon_item_stage4`: the item stops at Y `$B4` instead of landing on a floor tile |
| `rideable_missile_state_01` (3 tests) | `STAGE_4` | the missile's sound, and the VRAM addresses of the helicopter's rotors (the stage 4 helicopter or the ending's) |
| `player_weapons.asm`, the down-jump | `STAGE_6` | dropping through a platform only above Y `$74` |
| `fade_out_step` | `STAGE_2`, `STAGE_5` | the top-down stages fade differently |
| `run_topdown_stage` | `STAGE_5` | `tbl_stage5_states` instead of `tbl_stage2_states` |
| `set_m7_patch_tile_attrs` | `STAGE_2` | `tile_attrs_stage2`, else stage 5's |
| `get_target_marker_attr` | `STAGE_2` | the target markers' attribute |
| `get_p1_start_point_index`, `get_p2_start_point_index` | `STAGE_2` | stage 5's start points are 16 entries further |

The top-down code only asks "stage 2?" (or "stage 5?") and takes anything
else for the other one.

**Tables indexed by the stage number** (in bank `$05` unless noted; some
share bytes with their neighbours, marked overlap):

| table | entries | what |
|---|---|---|
| `tbl_stage_runners` (bank `$00`) | by `stage_index` | `enter_side_view_stage` or `enter_top_down_stage`: the side-view / top-down dispatch |
| `stage_layouts` | bytes, 0-6 | the side-view layout (the top-down stages' entries are not used) |
| `ptrs_stage_card_texts` | 1-6, entry 0 overlaps the end of `text_stage_select` | "STAGE n" (`text_stage_1` ...): by position, not by stage; also the stage select |
| `ptrs_stage_clear_pictures` | 1-5, entry 0 is the `palette_copy_end` before it | the stage clear screen's picture (no entry for stage 6) |
| `ptrs_stage_7f_load_lists` | 1-6, entry 0 overlaps `text_stage_clear_bonus`, entry 6 is entry 0 of the next | `load_stage_graphics`: packed data into `$7F` |
| `ptrs_stage_map_load_lists` | 0-6 | `load_stage_graphics`: the stage's metatiles and maps into `$7E` |
| `ptrs_stage_spawn_pages` | 0-6 | the stage's spawn lists (`init_stage_spawns`) |
| `song_lists` + 2, `song_start_commands` + 2 | 0-6 | `load_stage_music`: the stage's song set and start command (the same tables number the songs of the sound check) |
| `demo_stage_checkpoints` | 0-6, entry 0 is the last entry of `demo_stages` | the demo starts stage 1 at its midpoint; `demo_stages` holds stage numbers (1, 2, 4) |

**Tables indexed by the side-view layout** (`stage_layout`: stages 1, 3,
4, 6, the opening, then the same five past the checkpoint, `$0A` bytes
in, which is `LAYOUT_CHECKPOINT`, twice the number of layouts:
`stage_bg1_map_offsets`, `stage_bg2_map_offsets`, `ptrs_stage_load_lists`
(the BG and sprite tiles into VRAM), `tbl_stage_layout_inits` (bank `$00`:
the music, HDMA preset and scroll modes of each start). By
`stage_layout_base` (no checkpoint versions): `stage_respawn_modes` (the
opening's entry overlaps `ptrs_stage_dp_params`), `ptrs_stage_dp_params`
(`load_stage_dp_params`: the per-stage direct page parameters, collision
thresholds among them), `ptrs_stage_palette_tasks`.

**What does not depend on the number.** The HUD, the score board and the
two-player modes (A and B) never read it; a continue restarts the same
`stage_number` from `stage_checkpoint`, which objects set at the midpoint
and every new stage clears; the bosses and mid-bosses come from the spawn
lists and end the stage with `stage_exit_request` (the ending object
too), so they follow the stage's data, not its number; the HDMA and
scroll setup of a stage is its layout's (`tbl_stage_layout_inits`,
`hdma_preset`); the top-down maps follow `topdown_map`. The attract demos
are numbered by `demo_index` (`ptrs_0585CB`, the input tables), only
their stage numbers come from `demo_stages`. The sound check numbers the
songs by `song_lists`, so the extra-stage build leaves that table alone
(`stage_songs`).

## Values useful for cheats

| address | name | effect |
|---|---|---|
| `$1E3C` | `option_lives` | lives at the start of a game (30 with the unused code) |
| `$1E60` | `stage_select_enabled` | non-zero: stage select after the title |
| `$1E62` | `continues_left` | continues |
| `$1E3E` / `$84` | `option_level` / `difficulty` | 0 EASY, 2 NORMAL, 4 HARD |
| `$1E40` | `stage_checkpoint` | 1: start the stage from its midpoint |
| `$1FB6` | `p1_next_extend` | points to the next extra life |
