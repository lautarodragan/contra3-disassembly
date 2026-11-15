# Top-down stages

Stages 2 and 5 are seen from above: the floor is a single Mode 7 background
that rotates around the player, and everything else (players, enemies,
shots) is sprites whose positions are rotated in software to match. The
code is in `src/topdown/`; the stage is entered from `tbl_stage_runners`
(indexed by `stage_index`), which sends stages 2 and 5 to
`run_topdown_stage`. The NMI frame handler for these stages is
`nmi_frame_top_down` (`nmi_mode` 4).

Everything here was read in the code and checked in the emulator where
the text says so (`$86` poked to 2 right after Start on the title).

## Coordinates and angles

Objects live in map coordinates: the map is 128 x 128 Mode 7 tiles, so
x and y run from 0 to `$3FF` (`clamp_x_to_map`, `clamp_y_to_map`).
Angles are bytes, 256 units per turn. A player's facing angle is object
field `+$04`; the angle of a player's *view* (`p1_view_angle`) follows
it, so turning with L/R turns the whole floor under a player who stays
pointing up the screen. In the emulator, holding R for 30 frames moved
both from 0 to `$3C`, and `p1_m7_angle` to `$C4` (the Mode 7 angle is the
view angle negated).

## The state machine

`run_topdown_stage` runs one state per frame, from `tbl_stage2_states` or
`tbl_stage5_states` (stage 5) indexed by `topdown_state`:

| state | stage 2 | stage 5 | what |
|---|---|---|---|
| 0 | `topdown_state_init` | same | clear RAM (`clear_topdown_ram`), NMI mode 4, common graphics, PPU (`init_topdown_ppu`); next state 1, or 4 when the game continues at the boss (`stage_checkpoint`) |
| 1 | `stage2_state_setup` | `stage5_state_setup` | clear objects, variables (`init_stage2_vars`), spawn the targets (`spawn_stage2_targets`), graphics (`load_stage2_assets`, which also builds the Mode 7 map) |
| 2 | `stage2_state_intro` | `stage5_state_intro` | the start-point intro (`update_topdown_intro`) |
| 3 | `stage2_state_play` | `stage5_state_play` | play, until every target is destroyed (`check_targets_destroyed`) |
| 4 | `stage2_state_boss_setup` | `stage5_state_boss_setup` | the boss map: objects cleared, boss graphics, the boss spawned, boss music |
| 5 | `stage2_state_boss` | `stage5_state_boss` | the boss fight; `update_stage2_boss_end` waits for the boss's defeat, fades out and leaves |

`topdown_map` tells the four maps apart (`TD_MAP_STAGE2`,
`TD_MAP_STAGE2_BOSS`, `TD_MAP_STAGE5`, `TD_MAP_STAGE5_BOSS`); much of the
code dispatches on it. Every play state ends with `update_topdown_fade`
(brightness towards `fade_target_brightness`) and
`check_topdown_game_over`.

A play frame (`stage2_state_play`) runs, in order: the Select map view
(`update_map_view`, which suspends the rest while open), the players
(`update_topdown_players`), the smart bombs (`td_update_bombs`), the map
objects (`update_map_objects`), the enemies (`td_update_enemies`), the
enemy generator (`spawn_stage2_enemies`), the slots at `$0980`, the shots
(`update_topdown_shots`), the stage's map events
(`td_update_stage2_map_events`), screen shake (`update_screen_shake`),
palette animation (`animate_topdown_palettes`), the views
(`update_topdown_views`) and the collisions (`td_run_collisions`).

## The intro: choosing a starting point

`update_topdown_intro` runs `tbl_intro_steps`. `intro_init` shows the
whole map zoomed out (`init_intro_views`: scale `M7_SCALE_MAP`, centre
`$200,$200`) under "CHOOSE YOUR STARTING POINT", and puts each player's
cursor on a random cell of a 4 x 4 grid (`randomize_start_cursors`).
`move_start_cursors` moves it with the D-pad (`p1_start_x` column,
`p1_start_y` row, wrapping); Y or Start chooses (`p1_start_chosen` = 2).
`set_start_points` then looks the cell up in `start_points_x` /
`start_points_y` (16 points per stage; stage 5's follow, at
`start_points_x_stage5`), and `intro_zoom_in` zooms back to
`M7_SCALE_1X`, 4 units a frame, spinning the view 2 units a frame and
sliding the centre towards the chosen point (`zoom_in_views`). The same
tables give the respawn point: a player who dies comes back at the start
point nearest to where it was (`td_set_respawn_position`).

## The map view (Select)

`update_map_view` (steps in `tbl_map_view_steps`): Select fades out,
`map_view_open` sets scale `M7_SCALE_MAP` with the centre at `$0000` so the
whole map fits the screen, `draw_map_view_sprites` marks the players and
the targets at 1/5 scale, and the next Select restores the views
(`map_view_close`) and the brightness saved at the start. While it is open
(`map_view_active`) nothing else runs and nothing is streamed.

## Mode 7 views

Each player has a *view*: a Mode 7 transform centred on the player. In
one-player games and in 2-player mode B there is one; in 2-player mode A
(`title_menu_cursor` 1) the screen is split into two halves of `$70`
lines (`m7_split_screen`), player 1's on top.

The variables of a view are in the player's stat block (player 1 at
`$1F80`, player 2 at `$1FC0`):

| player 1 | what |
|---|---|
| `p1_m7_center_x`, `p1_m7_center_y` | rotation centre (map coordinates) |
| `p1_m7_scale_x`, `p1_m7_scale_y` | scale, 8.8: `M7_SCALE_1X` in play, `M7_SCALE_MAP` zoomed out |
| `p1_m7_angle` | rotation |
| `p1_m7_hofs`, `p1_m7_vofs` | scroll |
| `p1_m7a` ... `p1_m7d`, `p1_m7x`, `p1_m7y`, `p1_bg1hofs`, `p1_bg1vofs` | the register values |
| `p1_view_brightness` | brightness of that half of the screen |

`update_topdown_views` sets centre, scroll and angle from the player:
centre = the player's position (`p1_view_x`, `p1_view_y`), scroll =
centre minus where the player is drawn on the screen (`p1_view_anchor_x`,
`p1_view_anchor_y`: `$80,$A0` in one-player games, `$60,$34` and
`$60,$AC` split), angle = minus `p1_view_angle`. On the stage 2 boss map
(`wram_15A8` set) the view is computed around the boss instead.

Every frame the NMI calls `compute_m7_matrix` (and `compute_p2_m7_matrix`
in mode A). It builds the matrix from `sine_table` / `cosine_table`
(128 words each, half a turn, the sign coming from bit 7 of the angle)
multiplied by the scale (`multiply_sine_scale`):

    M7A =  cos(angle) * scale_x     M7B = sin(angle) * scale_x
    M7C = -sin(angle) * scale_y     M7D = cos(angle) * scale_y

and copies the centre and scroll to `p1_m7x`, `p1_m7y`, `p1_bg1hofs`,
`p1_bg1vofs` (the vertical scroll minus `screen_shake_offset`, which
`update_screen_shake` flips every other frame while it decays). The PPU
registers are written by the IRQ, not the NMI: `init_topdown_irq` sets an
IRQ at line 8 (line 0 for the split screen) whose handler
`irq_mode7_top_view` writes player 1's values and, in mode A, re-arms the
IRQ at line `$70` for `irq_mode7_bottom_view` with player 2's.
HDMA (`init_topdown_hdma`, channels 2-7) changes the BG mode, the main
screen, colour math and brightness by section of the screen (status bar
at the top, then Mode 7), and the window.

## The map: blocks, tile attributes and patches

The 128 x 128 tilemap is built from a map of 4 x 4-tile blocks:
`build_m7_tilemap` reads the block map at `$7E:9000` (one byte per block,
32 x 32), expands each block from its definition at `$7E:8000`
(`expand_m7_block`), and writes the tilemap four tile rows at a time
(`upload_m7_tilemap_rows`). For the same rows `build_tile_attr_rows`
translates each tile through the map's table (`tile_attrs_stage2`,
`tile_attrs_stage5`, `tile_attrs_stage5_boss`) into the *tile attribute
map* at `$7E:4000`, one byte per tile (index `(y / 8) * 128 + x / 8`),
which the collision code of the players and the shots reads (walls,
holes).

Things that change on the floor are tilemap changes, not sprites: the
targets and turrets of `update_map_objects` show a block (object field
`+$20`) at a VRAM address (`+$26`), and `update_map_object_block` queues a
change with `queue_m7_block_patch`. There are four patch slots at `$1800`
(flag, four VRAM row addresses at `$1808`, 16 tiles at `$1828`);
`upload_m7_block_patches` writes them in the NMI. Unused slots point at
VRAM `$6000`, past the Mode 7 data (`reset_m7_block_patches`), so the
uploader can write all four without checking.

## Sprites in a rotating world

Sprites cannot rotate, so `draw_topdown_sprites` (run by the NMI, one view
per frame, alternating in mode A) does it by hand. `project_to_view`
turns a map position into a screen position around the view's centre and
angle. It does not multiply: `sine_products.asm` holds 65 tables of
`floor(k * sin(a))` for k up to `$BF`, one per angle of a quarter turn;
`setup_p1_view_projection` points `zp_D4` and `zp_D7` at the tables for
the angle and its complement, and the quadrant routines
(`tbl_project_quadrants`) add and subtract the looked-up products.
Objects farther than `$B8` pixels on an axis are not drawn.

The rotation of the sprites themselves is done with graphics: enemies
and players have one metasprite per angle step, chosen from their angle
minus the view angle (`draw_enemies`, `draw_topdown_players`), and their
graphics are streamed: the routines list the source of each rotated
frame at `$1780` (`$17C0` for player 2's view), and
`stream_topdown_sprite_gfx` DMAs up to 4 KB of sprite tiles to VRAM
`$4000` in the next NMI. On the boss maps the same routine also streams
the boss's Mode 7 characters (the bosses are part of the floor).

Small objects (shots, `$0300-$097F`) are one sprite each, the tile picked
by angle (`draw_small_objects`). `draw_target_arrows` puts the arrow that
points to the nearest target (objects `$0200` and `$0240`, aimed by
`td_aim_p1_target_arrow`) in the first OAM entries.

## Objects

The top-down stages use the object RAM in their own way:

| slots | size | what | run by |
|---|---|---|---|
| `$0200`, `$0240` | `$40` | target arrows (one per view) | `td_aim_p1_target_arrow` |
| `$0300-$047F` | `$20` | enemy shots | `update_topdown_shots` |
| `$0480-$06FF` | `$20` | player 1's shots (second weapon from `$05C0`) | `update_topdown_shots` |
| `$0700-$097F` | `$20` | player 2's shots | `update_topdown_shots` |
| `$0980-$0ABF` | `$40` | other objects (not identified yet) | `sub_02A9F8` |
| `$0AC0-$0D3F` | `$40` | map objects: the targets, the bosses | `update_map_objects`, `tbl_map_object_types` |
| `$0D40-$0EBF` | `$40` | enemies | `td_update_enemies`, `tbl_td_enemy_types` |
| `$0EC0`, `$0F00` | `$40` | players 1 and 2 | `update_topdown_player` |
| `$0F40`, `$0F80` | `$40` | smart bombs of players 1 and 2 | `td_update_bombs` |

Fields common to these objects: `+$04` angle, `+$08/+$0A` x,
`+$0C/+$0E` y, `+$10` type, `+$12` state, `+$18-$1E` velocity
(`move_topdown_object`). The players also use parallel blocks: slot +
`$0640` is the player's top-down block at `$1500` / `$1540` (view,
joypad copies `p1_td_joy_held` / `p1_td_joy_pressed`, start point), and
slot + `$10C0` is the stat block at `$1F80` / `$1FC0` (lives, weapons,
the Mode 7 view).

## Players

`update_topdown_players` copies each joypad into its block and runs
`update_topdown_player`, whose state (`tbl_topdown_player_states`) is
chosen from the buttons every frame (states checked in the emulator):

| state | routine | what |
|---|---|---|
| 0 | `td_player_state_inactive` | no player, or dropping in at a start point |
| 1 | `td_player_state_stand` | standing |
| 2 | `td_player_state_stand_fire` | standing, Y held |
| 3 | `td_player_state_walk` | walking: up/down forward and back along the view, left/right sideways (`td_walk_by_dpad`) |
| 4 | `td_player_state_walk_fire` | walking and firing |
| 5 | `sub_0291CB` | B pressed: a short action (8 frames), not identified yet |
| 6 | `td_player_state_turn_buttons` | L and R held together |
| 7 | `td_player_state_spin_fire` | L+R+Y: the player spins 8 units a frame firing both weapons sideways |
| 8 | `td_player_state_dying` | hit: spins, slows down, respawns after `$80` frames |
| 9 | `td_player_state_falling` | the view zooms in and fades out while the player spins (probably a fall into a hole) |

L and R turn the player and its view (`td_turn_player`, speed from
`td_update_turn_speed`). Weapons are the same as on the side-view stages
(`WEAPON_DEFAULT` ... `WEAPON_LASER`, the player's two slots), fired by
`fire_topdown_weapon` through `tbl_topdown_weapons` (`fire_td_spread`
fires five shots at random spreads, `fire_td_flame` keeps one flame shot
alive). A (`button_bomb`) throws a smart bomb (`td_check_smart_bomb`): an
object at `$0F40`/`$0F80` whose radius grows for `$70` frames
(`td_update_bomb`) and that hits map objects (`td_p1_bomb_vs_map_objects`).

## Enemies and targets

The first part of each top-down stage is to destroy its targets: five map objects
spawned at the start (`spawn_stage2_targets`, types chosen by difficulty
and at random) and drawn into the floor. The arrow points at the nearest
one; when `td_aim_p1_target_arrow` finds none left it sets
`targets_left_flag`, and `check_targets_destroyed` waits `$80` frames,
fades out and moves to the boss map.

Meanwhile `spawn_stage2_enemies` (`spawn_stage5_enemies`) keeps enemies
coming: in alternating periods of `$200` frames it either puts a random
type (by difficulty) at a random offset around a player
(`td_place_enemy_near_player`) whenever one of the slots `$0DC0-$0EBF` is
free, or, when none is alive, spawns type `$0F` (`$0C` in stage 5). Each
enemy runs its type's handler from `tbl_td_enemy_types`, its animation
(`td_animate_enemy`) and hit flash (`td_flash_enemy_on_hit`). Points go
to the owner of the shot (`td_score_shot_kill`, tables
`td_enemy_scores` and `td_map_object_scores`).

Collisions are checked for one player per frame (alternating in
two-player games, `td_run_collisions`): its shots against the enemies,
its body against the enemies, its bomb against the map objects, and the
target arrow.

## Palettes

`animate_topdown_palettes` runs a per-map animation: palette tasks
restarted every `$60` frames on stages 2 and 5, and on the stage 5 boss
map a rotation of colours `$38-$3F` (`rotate_palette_colors_up`).

## Still to do

The enemy, map object and shot handlers (`tbl_td_enemy_types`,
`tbl_map_object_types`, `tbl_topdown_shot_types`, `tbl_02AA20`), the
bosses, the stage 2 boss camera (`sub_02B2AE`) and the tile attribute
values are not named yet. Data that milestone 3 must turn into labels:
the pointers in `sprite_data_07.asm` (metasprites and stream tables read
through `data_078806` / `data_078828`), the per-angle walking vectors
(`data_079118`, `data_079198`, `data_079398`, `data_079418`), the
stream-list pointers built from immediates in `draw_enemies`, and the
loader lists passed as immediates (`load_stage2_assets` and its
siblings).
