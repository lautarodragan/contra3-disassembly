# Side-view collision map

The side-view stages (1, 3, 4, 6) collide the players and some objects with
BG1 through a *collision map*: one word per 8x8 tile at `$7E:4000`, built
from the tiles as they are drawn. The top-down stages use the same RAM for a
different map (one byte per Mode 7 tile, the `TDA_*` attributes of
[Top-down stages](topdown.md)); nothing here applies to them.

## Where it comes from

The map is laid out like a 64x32 tilemap: entry
`((x & $100) << 2) | (y / 8) * 32 | (x / 8) & 31`, with `x` and `y` the
position in BG1 (screen position plus `bg1_x`/`bg1_y`, wrapping at 512 and
256 pixels), which is what `get_bg_tile_at_object` computes for an object
plus an offset (`zp_00`, `zp_02`); it returns 0 below the screen
(y >= `$E0`).

When the scroll crosses a tile column or row, `draw_bg_column`/`draw_bg_row`
queue the new BG1 tiles and `update_bg_collision_map` turns the same
tilemap words into collision words: the tile number (bits 0-9) is compared
with twelve ascending thresholds `zp_C8`-`zp_DE`, loaded per stage by
`load_stage_dp_params` from `ptrs_stage_dp_params` (indexed by
`stage_layout_base`), and the first threshold above it picks the class; a
threshold of 0 skips its class. So the collision of a tile is decided by
where its graphics were put in VRAM: each stage keeps its solid tiles at the
top of the BG tile range. For the slope classes the tile's horizontal flip
(bit 14 of the tilemap word) becomes `TILE_FLIPPED`.

| tiles | stage 1 | stage 3 | stage 6 | word |
|---|---|---|---|---|
| below `zp_C8` | `$000-$390` | `$000-$367` | `$000-$3B4` | `$0000` (nothing) |
| class 1 | `$391-$3EC` | `$368-$3D3` | `$3B5-$3E9` | `$2002` |
| class 2 | `$3ED-$3F3` | `$3D4-$3D6` | `$3EA-$3F1` | `$0004` |
| class 3 | `$3F4-$3F7` | - | `$3F2-$3F7` | `$4008` (+flip) |
| class 4 | `$3F8-$3F9` | - | `$3F8-$3FF` | `$4010` (+flip) |
| class 5 | - | `$3D7-$3DF` | - | `$6020` (+flip) |
| class 6 | - | `$3E0-$3E8` | - | `$6040` (+flip) |
| class 7 | - | `$3E9-$3EB` | - | `$6080` (+flip) |
| class 8 | - | `$3EC-$3EE` | - | `$6100` (+flip) |
| class 9 | `$3FA-$3FB` | `$3EF-$3F0` | - | `$1200` |
| class 10 | `$3FC-$3FD` | `$3F1-$3F2` | - | `$5400` (+flip) |
| class 11 | `$3FE-$3FF` | `$3F3-$3F4` | - | `$5800` (+flip) |
| class 12 | - | `$3F5-$3FF` | - | `$A000` |

Stage 4 (`stage_dp_params_058A5F`, first threshold `$400`) has no BG
collision at all: the hover bikes and the missiles are objects. A few
objects also write words directly with the fill helper
`update_object_type_28`: a column of `$A000` at the right edge of the stage
1 boss arena (`stage1_boss_controller_state_00`), a column of `$2002` for the
stage 3 robot's cables, a row of `$2002` in the ending.

Values seen in the collision map during the scripted plays of
`tools/c3emu/plays.py` (the whole map read every 120 frames): stage 1
`$0004 $2002 $1200 $4008/9 $4010/1 $5400/1 $5800/1 $A000` (the last only in the
boss arena), stage 3 `$0004 $2002 $1200 $5401 $5801 $6020/1 $6040/1 $6080/1
$6100/1 $A000`, stage 4 nothing, stage 6 `$0004 $2002 $4008/9 $4010/1`.

## The bits

The words are one shape bit (bits 1-11) plus group flags (bits 12-15) and
the flip (bit 0). Constants in `src/ram.inc`:

| bit | constant | meaning | evidence |
|---|---|---|---|
| 0 | `TILE_FLIPPED` | the slope falls to the right (else it rises) | the flip of the BG tile; a falling slope built of flipped tiles is walked down smoothly, the stage 3 overlays |
| 1 | `TILE_CLIMBABLE` | solid: floor, a wall the player climbs, a ceiling the player hangs from | experiments below; the climbable towers and cylinders of stages 1 and 3 |
| 2 | `TILE_PLATFORM` | floor only, dropped through with down + jump | the ledges of the stage 1 boss building; experiments |
| 3, 4 | `TILE_PLATFORM_SLOPE_UPPER`, `_LOWER` | slope of platform (no `TILE_NO_DROP`), upper and lower tile of a 16-pixel column | the girders of stages 1 and 6; experiments |
| 5, 6 | `TILE_SLOPE_UPPER`, `TILE_SLOPE_LOWER` | slope of solid floor | the bevelled corners in stage 3; experiments |
| 7, 8 | `TILE_CEILING_SLOPE_LOWER`, `_UPPER` | slope of a ceiling (hung from) | stage 3 corners: bit 8 above bit 7; experiments |
| 9 | `TILE_BAR` | level bar: the player hangs from it (state 1) | the beams of stages 1 and 3 |
| 10, 11 | `TILE_BAR_SLOPE_UPPER`, `_LOWER` | sloped bar | the slanted beams of stage 1; experiments |
| 12 | `TILE_HANG_CLASS` | probably "a bar": set on the three bar classes | never tested by the code |
| 13 | `TILE_NO_DROP` | floor that is never passed through | down + jump; the falling player's `$32` flag |
| 14 | `TILE_SLOPE_CLASS` | probably "a slope": set on every slope and sloped bar class | never tested by the code |
| 15 | `TILE_WALL` | solid, not climbable: floor and a wall; not a ceiling | stage 3's girder blocks, the stage 1 boss wall; experiments |

Masks: `TILE_FLOOR_MASK` (`$807E`, what the feet stand on),
`TILE_FLOOR_SLOPES` (`$0078`), `TILE_FLOOR_SLOPE_LOWER` (`$0050`, the lower
tile of either kind of floor slope), `TILE_CEILING_MASK` (`$0182`),
`TILE_CEILING_SLOPES`, `TILE_BAR_MASK` (`$0E00`), `TILE_BAR_SLOPES`,
`TILE_WALL_MASK` (`$8002`, what stops the player sideways).

## Slopes

Every slope rises or falls 8 pixels per 16, on the 16-pixel grid of the
stage: the slope snap routines (`stop_y_slope_up_right` and its siblings in
`src/objects/player_weapons.asm`) take `t = ((x + bg1_x) & 15) / 2` and put
the feet on the line of the tile row. Each 16-pixel column of a slope is
two tiles high, an *upper* and a *lower* tile (both 8-pixel columns of the
pair carry the same class), and the next column is one row higher (rising)
or lower (falling). Each tree tests only the lower bit
(`TILE_FLOOR_SLOPE_LOWER`, `TILE_CEILING_SLOPE_LOWER`, `TILE_BAR_SLOPE_LOWER`)
to tell the two apart, and `TILE_FLIPPED` for the direction. Ceiling slopes
are numbered the other way round (bit 7 is the lower tile).

## Who reads it

- **Feet** (`airborne_falling_collision`, `dying_check_floor_walls`):
  `check_floor_tiles` on the tiles at x and x+6 at the feet. While the
  player's `$32` countdown runs with flag `$0100` (10 frames after a jump,
  `start_player_jump`, or a fall start, `start_player_fall`), floor tiles
  without `TILE_NO_DROP` are ignored: that is how down + jump drops through
  a platform. Flag `$0200` (`start_player_fall_from_hang`) ignores bars the
  same way.
- **Ground** (`check_walls_and_floor` for `player_state_ground` and
  `player_state_spin_stance`): `classify_floor_tiles`, the same tree with
  the `snap_y_*` routines. Down + jump (`player_state_ground`) starts a fall
  unless one of the two tiles has `TILE_NO_DROP` (then it jumps; standing on
  an object counts as `TILE_NO_DROP`; stage 6 has an exception by height).
- **Walls**: the tile 32 pixels above the feet (and 8 pixels while
  airborne), at x (left) or x+6 (right): `TILE_WALL` stops the player,
  `TILE_CLIMBABLE` starts climbing (state 5 on the left, 2 on the right);
  `TILE_WALL` is tested first. The climbing states follow the
  `TILE_CLIMBABLE` tiles (`hop_off_wall_top` at the top).
- **Ceiling** (`check_ceiling_hang_height`, `check_ceiling_at_offset`):
  the tiles 48 pixels above the feet with `TILE_CEILING_MASK`; while rising
  a ceiling makes the player hang from it (state `$0D`,
  `player_state_hang_climb`), and the hanging state moves along it. A
  `TILE_WALL` or `TILE_PLATFORM` tile is jumped through from below.
- **Bars** (`check_hang_bar`, `classify_hang_bar_tiles`): the same height,
  `TILE_BAR_MASK`; state 1 (`player_state_hang`), hand over hand by the bar
  class in `zp_C4` (`animate_hang_move_right`).
- **Objects**: `object_check_floor_tiles` (walking enemies, the same tree),
  `weapon_item_move` (`TILE_FLOOR_MASK` down, `TILE_CEILING_MASK` up),
  `update_grenade` (explodes on `TILE_NO_DROP`), `rolling_mine_check_wall`
  (`TILE_WALL_MASK`), `drop_object_to_floor`; some only test for a non-zero
  word (`update_bouncing_debris`, `update_debris_spark`).
- `respawn_on_floor` searches the map for the first non-zero word.

## The decision trees

`check_floor_tiles`, `classify_floor_tiles`, `classify_hang_bar_tiles`,
`check_ceiling_at_offset` and `object_check_floor_tiles` have one shape: the right tile (`zp_06`, at
x+6) falls into one of six classes by the tree's mask: nothing
(`@right_none`), level (`@right_level`), a rising slope's upper or lower tile
(`@right_rise_upper`, `@right_rise_lower`), a falling slope's
(`@right_fall_upper`, `@right_fall_lower`); then the left tile (`zp_04`, at
x) picks the outcome (nodes `@<right class>_left_<test>`). The outcome sets
`zp_C4` and jumps to a snap routine, and is named after both: `@none` (0),
`@level` (2), `@rise` (8, `stop_y_slope_up_right`/`snap_y_slope_up_right`),
`@fall` (`$10`, `..._down_right`), with the snap's suffix (`_below`,
`_above`, `_below_high`). Bit 15 of `zp_C4` (`_partial`) is set when only
one of the two tiles is of that kind (the other empty, or level next to a
slope); `classify_floor_tiles` sets `$8011` when only the left foot is on a
falling slope (`@fall_left_only`). `@to_*` labels are trampolines: a `beq`
that is never taken and a `brl` to a node out of branch range. The trees
handle impossible combinations too, so some outcomes are odd (the ceiling
tree gives nothing for a level ceiling at the left hand and a rising
slope's lower tile at the right; the bar tree gives nothing for a falling
bar slope at the left hand alone).

## How the bits were verified

- **Overlays.** During the plays of every side-view stage, the collision
  map was drawn over the screen, a coloured box per class: `$2002` covers the
  ground and the climbable towers (stage 1) and cylinders (stage 3),
  `$A000` stage 3's girder blocks (stood on, not climbed) and the stage 1
  boss's right wall, `$0004` the building ledges, `$1200` the beams the
  player hangs from, `$4008`/`$4010` the slanted girders (stages 1 and 6),
  `$5400`/`$5800` slanted beams, `$6020`-`$6100` the bevelled corners of stage
  3's ducts (floor slopes below, ceiling slopes above, the upper class
  above the lower one in each 16-pixel column).
- **Writing words into the map** in the emulator (WRAM `$7E:4000`, the
  player standing still at the start of stage 1 so that nothing redraws
  them; `tools/c3emu`):
  - floor (the rows under the feet replaced): the player stands on `$0002`,
    `$0004`, `$2002`, `$8000`, `$A000`, falls through `$0001`, `$2000`,
    `$4000`, `$1000`, `$0080`, `$0100`;
  - down + jump: drops through `$0004` and `$8000`, jumps on `$2002`,
    `$2004` and `$A000`;
  - a column ahead, walking into it: `$0002`/`$2002` start climbing (state
    2; holding up climbs to the top); `$8000`, `$A000` and `$8002` stop the
    player without climbing; `$0004`, `$2000`, `$0200`, `$0040`, `$0080` are
    walked through;
  - a row above the jump: `$0002`, `$2002`, `$0080` and `$0081` are grabbed
    (state `$0D`; the player then moves along it and drops with down + jump);
    `$0004`, `$8000`, `$A000`, `$0020` are jumped through; `$1200` is a bar
    (state 1);
  - slopes built of 16-pixel columns, upper tile above lower tile: walked up
    1 pixel per 2 (`$6020`/`$6040` and `$4008`/`$4010`), walked down with
    the flipped words; with upper and lower swapped the player jumps
    between rows and ends up climbing. A rising bar of `$5400`/`$5800` is
    followed hand over hand, swapped it drops the player; a falling ceiling
    of `$6101`/`$6081` is followed while hanging.
