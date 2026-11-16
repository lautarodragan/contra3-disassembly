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
enemy generator (`spawn_stage2_enemies`), the items (`update_td_items`), the shots
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
(`boss_centered_view` set) the view is computed around the boss instead.

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
The block map and the block definitions are decompressed there by the
map's load list (`stage2_block_map_0`-`_3` and `stage2_m7_blocks` for
stage 2, and the same for the two boss maps and stage 5; see
[Assets](assets.md#wram-streams-of-bank-7e)), with the sprite tiles at
`$7E:A000`-`$7E:EFFF` and, on the boss maps, the boss's Mode 7
characters at `$7E:C000`.

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
| `$0980-$0ABF` | `$40` | items and effects (`TDI_*`): weapon items, barrier, bomb, explosions, trap blasts | `update_td_items`, `tbl_td_item_types` |
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
| 5 | `td_player_state_jump` | B: a jump of 8 frames; the player is drawn bigger and enemy shots miss it; Y at mid-jump fires (`td_fire_jump_shot`) |
| 6 | `td_player_state_turn_buttons` | L and R held together |
| 7 | `td_player_state_spin_fire` | L+R+Y: the player spins 8 units a frame firing both weapons sideways |
| 8 | `td_player_state_dying` | hit: spins, slows down, respawns after `$80` frames |
| 9 | `td_player_state_falling` | fall into a hole (`TDA_HOLE`, or the slopes `TDA_FALL_*`): the view zooms in and fades out while the player spins |

L and R turn the player and its view (`td_turn_player`, speed from
`td_update_turn_speed`). The animations depend on the weapon slot in use
(`p1_weapon_select`, 0 or 2): `td_player_stand_anims`,
`td_player_walk_anims` ... have one entry per slot, and the shots leave
from one side or the other (`td_fire_side_offsets`: -12 or +13 pixels). Weapons are the same as on the side-view stages
(`WEAPON_DEFAULT` ... `WEAPON_LASER`, the player's two slots), fired by
`fire_topdown_weapon` through `tbl_topdown_weapons` (`fire_td_spread`
fires five shots at random spreads, `fire_td_flame` keeps one flame shot
alive). A (`button_bomb`) throws a smart bomb (`td_check_smart_bomb`): an
object at `$0F40`/`$0F80` whose radius grows for `$70` frames
(`td_update_bomb`) and that hits map objects (`td_p1_bomb_vs_map_objects`).

## Enemies and targets

The first part of each top-down stage is to destroy its targets: five map
objects spawned at the start (`spawn_stage2_targets`, sets chosen by
difficulty and at random; positions `stage2_target_x` / `stage2_target_y`,
floor blocks at `stage2_target_vram_addrs`; stage 5's `stage5_target_*`) and drawn into the floor. The arrow points at
the nearest one (two arrow sprites per view, one on the left or right edge
and one on the top or bottom edge, from `td_arrow_lr_sprites`,
`td_arrow_tb_sprites` and their positions, by eighth of a turn); when `td_aim_p1_target_arrow` finds none left it sets
`targets_left_flag`, and `check_targets_destroyed` waits `$80` frames,
fades out and moves to the boss map.

Meanwhile `spawn_stage2_enemies` (`spawn_stage5_enemies`) keeps enemies
coming: in alternating periods of `$200` frames it either puts a random
type (`stage2_spawn_types`: mostly `TDT_RUNNER`, sometimes `TDT_GUNNER`;
stage 5: `TDT_SPITTER`, `TDT_CRAWLER`) at a random offset around a player
(`td_place_enemy_near_player`) whenever one of the slots `$0DC0-$0EBF` is
free, or, when none is alive, spawns a centipede (`TDT_CENTIPEDE`, stage 5
`TDT_BUG_CENTIPEDE`). Each enemy runs its type's handler from
`tbl_td_enemy_types`, its animation (`td_animate_enemy`) and hit flash
(`td_flash_enemy_on_hit`). A walking enemy that appears already on screen
is dropped (`td_enemy_state_spawn`); one that leaves the range of the
views (`+$2E` bits 2-3) is freed. Points go to the owner of the shot
(`td_score_shot_kill`, tables `td_enemy_scores` and
`td_map_object_scores`).

The types (constants in `src/object_types.inc`; identified by dumping the
slots every frame in the emulator, isolating each type and taking
screenshots; HP easy / normal / hard, an object dies when its HP goes
negative):

| type | constant | handler | what | HP |
|---|---|---|---|---|
| `$01` | `TDT_GUNNER` | `update_td_gunner` | stage 2 alien that walks, turns to the player and fires | 0/2/4 |
| `$02` | `TDT_RUNNER` | `update_td_runner` | stage 2 alien that walks to the nearest player | 0/2/4 |
| `$03` | `TDT_CENTIPEDE_UNUSED` | `update_td_centipede_unused` | a centipede never spawned | 16/64/128 |
| `$04` | `TDT_CENTIPEDE_SEGMENT` | `update_td_centipede_segment` | body segment of a centipede | (head's) |
| `$05` | `TDT_CRAWLER` | `update_td_crawler` | stage 5 creature that walks to the player | 2/4/8 |
| `$06` | `TDT_NEST_CRAWLER` | `update_td_nest_crawler` | stage 5 creature out of a nest, fires orbs | 2/16/32 |
| `$08` | `TDT_EXPLOSION` | `update_td_explosion` | an enemy's explosion (`td_start_explosion`) | |
| `$09` | `TDT_HATCH_TURRET_SPIN` | `update_hatch_turret_spin` | stage 2 hatch turret, turns all the time | 16/32/64 |
| `$0A` | `TDT_STAGE5_BOSS_CLAW` | `update_stage5_boss_claw` | stage 5 boss: claw of the arm | 32/128/256 |
| `$0B` | `TDT_STAGE5_BOSS_ARM_SEGMENT` | `update_stage5_boss_arm_segment` | stage 5 boss: arm segment (12) | (claw's) |
| `$0C` | `TDT_BUG_CENTIPEDE` | `update_td_bug_centipede` | stage 5 centipede; splits into four bugs | 16/64/128 |
| `$0D` | `TDT_BUG_CENTIPEDE_SEGMENT` | `update_td_bug_centipede_segment` | its body segments | (head's) |
| `$0E` | `TDT_CENTIPEDE_BUG` | `update_td_centipede_bug` | bug left by it; fires an orb | 2/4/8 |
| `$0F` | `TDT_CENTIPEDE` | `update_td_centipede` | stage 2 spiked centipede, fires | 16/64/128 |
| `$10` | `TDT_HATCH_TURRET_AIM` | `update_hatch_turret_aim` | stage 2 hatch turret aiming at the player | 16/32/64 |
| `$11` | `TDT_HATCH_TURRET_SWEEP` | `update_hatch_turret_sweep` | stage 2 hatch turret sweeping | 16/32/64 |
| `$12` | `TDT_SPITTER` | `update_td_spitter` | stage 5 creature that turns to the player and fires orbs | 2/4/8 |
| `$13` | `TDT_STAGE5_BOSS_ARM_BASE` | `update_stage5_boss_arm_base` | stage 5 boss: end of the arm in the pit | (claw's) |

A centipede is a head and three segments in fixed slots (`$0DC0`, `$0E00`,
`$0E40`, `$0E80`): the head records its positions in a ring at
`$7E:1900-$1AFF` (`td_centipede_record_trail`) and each segment replays
them some steps behind (`td_segment_follow_trail`); hits on any part count
against the sum of their HP (`td_centipede_check_killed`).

Map objects (`tbl_map_object_types`, `TDMT_*`) are the targets and the
bosses; HP is `+$06` too (`td_get_map_object_at` finds the one that owns a
tile through `stage2_map_object_by_cell` / `stage5_map_object_by_cell`):

| type | constant | handler | what | HP |
|---|---|---|---|---|
| `$01` | `TDMT_GUN_HATCH_AIM` | `update_gun_hatch_aim` | stage 2 target: a hatch that opens near a player and lets out a turret | 32/80/128 |
| `$02` | `TDMT_NEST` | `update_td_nest` | stage 5 target: a nest that lets out a `TDT_NEST_CRAWLER` | 32/80/128 |
| `$03` | `TDMT_STAGE2_BOSS` | `update_stage2_boss` | stage 2 boss, the body | (core's) |
| `$04` | `TDMT_STAGE2_BOSS_CORE` | `update_stage2_boss_core` | its weak point | 256/384/512 |
| `$05` | `TDMT_STAGE2_BOSS_CANNON` | `update_stage2_boss_cannon` | its cannon | 128/192/256 |
| `$06` | `TDMT_STAGE2_BOSS_POD` | `update_stage2_boss_pod` | one of its six spiked pods | 32/64/128 |
| `$07` | `TDMT_GUN_HATCH_SPIN` | `update_gun_hatch_spin` | stage 2 target with a spinning turret | 32/80/128 |
| `$08` | `TDMT_STAGE5_BOSS` | `update_stage5_boss` | stage 5 boss | 512/1024/2048 |
| `$0C` | `TDMT_GUN_HATCH_SWEEP` | `update_gun_hatch_sweep` | stage 2 target with a sweeping turret | 32/80/128 |
| `$0D` | `TDMT_GUN_HATCH_NO_FIRE` | `update_gun_hatch_no_fire` | HARD: opens only while the player does not fire | 32/80/128 |
| `$0E` | `TDMT_GUN_HATCH_BEHIND` | `update_gun_hatch_behind` | HARD: opens only behind the player's back | 32/80/128 |

A gun hatch is a floor block (`+$20`: `$50` closed, `$5B` opening, `$59`
open, `$57` destroyed). When a player comes near (`+$2E` bits 4-5) it
opens and lets its turret out into `$0D40` (player 1) or `$0D80`
(`td_get_hatch_enemy_slot`, `gun_hatch_spawn_turret`); the turret, which
keeps its hatch in `+$3A`, hides when it closes and explodes with it. A
destroyed target may drop an item (`td_spawn_item_drop`).

Items and effects (`$0980-$0ABF`, `tbl_td_item_types`, `TDI_*`):
`TDI_BLAST` (a trap's blast, damage 16 to enemies, deadly to players
without the barrier), `TDI_EXPLOSION` (decoration), and the items
`TDI_SPREAD` ... `TDI_LASER`, `TDI_BARRIER`, `TDI_BOMB`, which stay
`$140` frames. Touching one (`td_p1_vs_items`) puts the weapon into the
active slot, gives `$200` frames of barrier, or one more smart bomb (up
to 9).

Shots (`tbl_topdown_shot_types`, indexed by type + 8, `TDS_*`): the
player's (`TDS_DEFAULT` damage 2, `TDS_SPREAD` 2, `TDS_HOMING` 2,
`TDS_LASER` 4, `TDS_FLAME` 1, `TDS_CRUSH` 2 then `TDS_CRUSH_BLAST` 1 for
`$40` frames), and the enemies' (`TDS_ENEMY_BULLET`, `TDS_ENEMY_ORB`,
`TDS_HOMING_ORB`, `TDS_BOSS_SPIT`, `TDS_CANNON_FLAME`). A shot that hits
becomes `TDS_IMPACT` (`td_end_shot`).

Collisions are checked for one player per frame (alternating in
two-player games, `td_run_collisions`): its shots against the enemies,
its body against the enemies and the items, its bomb against the map
objects, and the target arrow; the boss maps have their own versions
(`td_p1_vs_stage2_boss`, `td_p1_vs_stage5_boss` ...). Enemy shots miss a
jumping player (state 5).

## Bosses

Both bosses are drawn in the Mode 7 layer, their graphics streamed from
`$7E` by frame (`boss_anim_frame`, `stage2_boss_stream_chr`,
`stage5_boss_stream_chr`).

**Stage 2** (`TDMT_STAGE2_BOSS` at `$0AC0`, states `tbl_stage2_boss_states`):
a spiked machine with six arms. The map is the boss: `boss_centered_view`
makes the views follow the boss object (`td_boss_x`, `td_boss_y`,
`td_boss_angle`) and the floor of the arena is drawn with sprites
(`draw_stage2_boss_arena`); everything else is projected around the boss
by `project_around_stage2_boss`, which multiplies with the hardware
multiplier instead of the tables of `sine_products.asm`. The boss falls
in (Mode 7 scale from 0 up to 1:1, screen shake), turns to the nearest
player (`td_select_target_player`) and walks at it, spins, or jumps: the
scale shrinks to 0, the boss is moved over the player and falls again. It
dies with its core (`TDMT_STAGE2_BOSS_CORE`, `td_boss_core_hp`); below
half of the core's HP it always jumps. The cannon
(`TDMT_STAGE2_BOSS_CANNON`) turns around the body and fires, the six pods
(`TDMT_STAGE2_BOSS_POD`, `+$14` = arm) open and fire, and drop items when
destroyed. The parts sit on circles around the body: the core at radius
`$12` (`stage2_boss_core_offsets_x`), the pods at `$42`
(`stage2_boss_pod_offsets_x`, angle `stage2_boss_pod_arm_angles` plus the
body's); a pod's look is a floor block per state (`stage2_boss_pod_closed_blocks`,
`stage2_boss_pod_half_open_blocks`, `stage2_boss_pod_open_blocks`,
`stage2_boss_pod_hit_blocks`, `stage2_boss_pod_destroyed_blocks`). The fall
spins and grows the view by difficulty (`stage2_boss_fall_spin_speeds`,
`stage2_boss_fall_scale_speeds`). Checked in the emulator (`stage_checkpoint` poked to 1 at the
start to begin at the boss).

**Stage 5** (`TDMT_STAGE5_BOSS`, states `tbl_stage5_boss_states`): a
creature at the bottom of a sand funnel (`$200,$200`). It sends its arm
out of the pit at the nearest player (`stage5_boss_spawn_arm`: claw at
`$0B40`, arm base at `$0B80`, twelve segments from `$0BC0`, run by
`update_stage5_boss_arm` with the enemy handlers): the claw turns to its
target, reaches out recording a trail that the segments follow, fires
`TDS_HOMING_ORB`, and pulls back; damage to any part of the arm counts
against the claw's HP. The boss also spits shots from the edge of the
pit (`stage5_boss_update_spit`; the four edges are `stage5_boss_pit_edge_x`
/ `stage5_boss_pit_edge_y`, where the arm comes out too) and the funnel tiles (`TDA_SAND_PIT`)
pull the players to the centre (`td_spiral_into_sand_pit`). Its HP is
`td_boss_hp`.

## Tile attributes

The tile attribute map at `$7E:4000` (one byte per tile, built by
`build_tile_attr_rows` from `tile_attrs_stage2`, `tile_attrs_stage5`,
`tile_attrs_stage5_boss`; none on the stage 2 boss map) holds `TDA_*`
values (`src/ram.inc`):

| value | constant | effect |
|---|---|---|
| `$00` | `TDA_FLOOR` | walkable |
| bits 0-2 | `TDA_WALL_MASK` | wall: 1 solid, 3-5 other shapes (`td_push_out_of_walls` checks the 2 x 2 tiles around an object and pushes it out, by `td_wall_push_dx`, `td_wall_push_dy`, `td_wall_push_diag`) |
| bit 4 (+ bit 3) | `TDA_SET_PRIORITY`, `TDA_PRIORITY_HIGH` | sets the sprite priority of who crosses it: under or over a structure |
| `$ED-$F4` | `TDA_FALL_*` | stage 5 slopes: the player slides that way and falls |
| `$F5-$F8` | `TDA_PUSH_*` | stage 5 currents: move players and enemies by `td_push_speed` |
| `$F9` | `TDA_SAND_PIT` | stage 5 boss funnel |
| `$FA` | `TDA_WHIRL` | stage 5 whirlpool: turns the player around the cell's centre; enemies lose HP |
| `$FB` | `TDA_SWITCH` | stage 5: Y or A here starts a switch event (`td_update_switch_events`; start points `td_switch0_x` ..., blocks `td_switch_event_blocks`) |
| `$FC` | `TDA_MAP_OBJECT` | a target or boss: blocks shots, which damage it (`td_get_map_object_at`) |
| `$FD` | `TDA_TRAP` | stage 2: 500 points, then a `TDI_BLAST` there `$30` frames later (`td_trap_timer_slots`, `td_trap_blast_x`, `td_trap_vram_addrs`) |
| `$FE` | `TDA_BLOCK_ANIM` | stage 2: shake and a block animation (`td_block_anim_frames`, `td_block_anim_blocks_0` ...) |
| `$FF` | `TDA_HOLE` | the player falls (state 9), an enemy dies |

Special values (from `$ED` up) are handled by entry `$FF` - value of
`tbl_td_player_special_tiles` (players) and `tbl_td_enemy_special_tiles`
(enemies: most kill them).

## For cheats

- Player 1's HP is `td_p1_hp` (`$0EC6`): any hit writes `$FFFF` unless
  `p1_barrier_timer` (`$1F88`) is non-zero; the items set it to `$200`.
- The boss HP: stage 5 `td_boss_hp` (`$0AC6`); stage 2 core and stage 5
  claw `td_boss_core_hp` (`$0B46`); the HP tables are `stage2_boss_core_hp`,
  `stage5_boss_hp` ... (by difficulty, in bank `$05`).
- Smart bombs: `p1_bombs`, up to 9 from items. Weapons: `td_p1_vs_items`
  writes the item kind (`WEAPON_*`) into the active weapon slot.
- `td_debug_cheat_buttons` is a leftover, never called, that changes
  weapons, bombs, barrier and lives with X and other buttons.

## Palettes

`animate_topdown_palettes` runs a per-map animation: palette tasks
restarted every `$60` frames on stages 2 and 5, and on the stage 5 boss
map a rotation of colours `$38-$3F` (`rotate_palette_colors_up`).

## Still to do

Many state routines are named only by number (`stage2_boss_state_0B`
...); the stage 5 slopes and whirlpools were read in the code but not
watched in the emulator; shot type 1 shares the default shot's handler
but nothing fires it. Data that milestone 3 must turn into labels: the
pointers in `sprite_data_07.asm` (metasprites and stream tables read
through `ptrs_td_metasprite_sets` / `ptrs_td_tile_lists`), the per-angle
walking vectors (`td_walk_y_int`, `td_walk_x_int`, `td_walk_y_frac`,
`td_walk_x_frac`), the stream-list pointers built from immediates in
`draw_enemies`, the animation scripts loaded as immediates into `+$28` by
the enemy handlers, and the loader lists passed as immediates
(`load_stage2_assets` and its siblings).
