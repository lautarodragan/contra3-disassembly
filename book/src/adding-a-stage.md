# Adding a stage

The number and order of the stages is a build parameter. The default build
is the original game (six stages, `make` checks its SHA-1); the
**extra-stage build** inserts a new side-view stage as stage 2, and the
original stages 2-6 become stages 3-7:

```sh
make cheats CHEATS=extra_stage                  # build/contra3-mod.sfc
make cheats CHEATS="extra_stage stage_select"   # with the stage select (7 entries)
make cheats CHEATS="extra_stage invincible infinite_lives"
make stage-test                                 # tests/test_extra_stage.py
```

The new stage is [Collapsed Tower](stage2-collapsed-tower.md): its own BG1
map and spawn lists, a climb, stage 1's graphics, mid-boss and boss,
stage 5's music. The game plays end to end in 7 stages:
stage 1, the new stage 2, the top-down stage 3, ... the ending after stage
7 and the EASY / NORMAL loop back to stage 1 (checked in the emulator, see
[Testing](#testing)).

## Why through the cheats

The option is `extra_stage` (`CHEAT_EXTRA_STAGE`), built by
`tools/cheats.py` like a cheat, although it is a variant of the game, not
a cheat. That tool already does what a variant build needs: `-D` defines
checked against the documented options, a separate build directory, the
recomputed header checksum, the emulator symbol files of that ROM, and the
same test fixture; and the variant combines with the cheats, which a
level designer wants for testing (`invincible`, `stage_select`,
`start_stage=2`). A separate make target for variants would have duplicated
all of it. The option is defined in `src/game/stages.inc`, with the stage
constants, not in `src/cheats.inc`: `tools/cheats.py` reads its options
from both files. It is not a preset, so `make ips` and the releases do not
ship it.

## How the source does it

`src/game/stages.inc` (included by `src/common.inc`, before
`src/cheats.inc`) holds everything that depends on the number and order
of the stages ([Game flow](game-flow.md#stage-numbering) lists every
place):

- `STAGE_1` ... `STAGE_6`: the `stage_number` of the original game's
  stage n (in the extra-stage build `STAGE_2` is 3 ... `STAGE_6` is 7),
  `STAGE_EXTRA` (2, only in that build), `STAGE_OPENING` (0),
  `STAGE_COUNT` (6 or 7) and `STAGE_LAST` (`STAGE_6`). The code compares
  `stage_number` with these (`cmp #STAGE_4`, `cmp #STAGE_LAST`, `cmp
  #STAGE_COUNT+1`), never with a bare number.
- `per_stage_byte`, `per_stage_word`, `per_stage_addr`: a table indexed
  by `stage_number` (or `stage_index`) lists its entries as the original
  stages 1-6 and then the extra stage's, and the macro emits them in play
  order (1, extra, 2, 3, 4, 5, 6). An empty sixth argument emits nothing
  for the last stage (the stage clear pictures). Entry 0 (the opening),
  where a table has one, is written before the macro.
- `LAYOUT_STAGE1` ... `LAYOUT_OPENING`, `LAYOUT_EXTRA` ($0A),
  `LAYOUT_COUNT` and `LAYOUT_CHECKPOINT`: the side-view layouts.
  `stage_init` adds `LAYOUT_CHECKPOINT` (twice the number of layouts:
  `$0A`, `$0C` with the extra stage) past the midpoint, so a new layout
  moves every checkpoint layout; `per_layout_word` and `per_layout_addr`
  write the tables by layout (stages 1, 3, 4, 6, the opening, the extra
  stage), once for the layouts and once for their checkpoint versions.
- `text_stage_7` is assembled only in the extra-stage build; the stage
  cards are by position ("STAGE n" is whatever plays n-th).
- `load_stage_music` takes the song from `stage_songs` (bank `$04`, only
  in the extra-stage build) instead of `song_lists` + 2 directly: those
  tables also number the sound check's songs, so they keep their order.

Inserting the stage elsewhere than at position 2 means changing the
`STAGE_*` values and the order in which the `per_stage_*` macros emit the
extra entry; the layouts do not depend on the position.

### Room in the banks

The two tables in bank `$00` (`tbl_stage_runners`, `tbl_stage_layout_inits`)
take 6 of its 14 free bytes; the stage's start (`layout_init_extra`) is a
4-byte `jml` to bank `$04`. Bank `$05`, where the stage data lives (DB is
`$05` during play, so the per-stage tables, the load lists, the palette
tasks and the spawn lists must be there), has only 75 bytes free in the
original layout, fewer than the new entries need with the `enemy_hp`
cheat's tables. So the extra-stage build moves `half_turn_sine` (536
bytes, read only with long addressing) to the end of bank `$04`: bank
`$05` then has about 560 bytes free for the new stage's data. The stage's
spawn lists need more: it also moves `td_spawn_offsets_y` and
`td_spawn_offsets_x` (640 bytes, read by `td_place_enemy_near_player`,
which reads them with long addressing in this build), and 530 bytes stay
free (`make cheats` fails at link time when it no longer fits; the free
space of each bank is in the variant's map file, in `build/cheats/`).

## What the level designer provides

The argument to change is the last one (`sx` or `lx`) of the macro,
unless said otherwise; the last column is the placeholder the build had
before the stage was designed (stage 1's), the
[Collapsed Tower](stage2-collapsed-tower.md#how-it-is-built) page has what
the stage uses now.

| what | where | placeholder |
|---|---|---|
| the stage's layout | `stage_layouts` (`LAYOUT_EXTRA`, keep it) | its own layout, $0A |
| BG tiles and sprite tiles into VRAM, for the start and for the checkpoint | `ptrs_stage_load_lists`, both lines (load lists of `load_vram`) | `load_list_058B08`, `load_list_058B2F` |
| the start of the stage: music, HDMA preset, BG2 scroll mode, objects to place | `tbl_stage_layout_inits`, both lines (routines in `src/game/stage.asm`, as `layout_init_stage1` / `layout_init_stage1_checkpoint`) | stage 1's |
| BG1 / BG2 map offsets of the start and of the checkpoint | `stage_bg1_map_offsets`, `stage_bg2_map_offsets` (both lines) | `$0000` / `$0900`, `$0000` / `$0100` |
| the direct page parameters (collision thresholds ...) | `ptrs_stage_dp_params` (a `stage_dp_params_*` block) | `stage_dp_params_058A2B` |
| how a dead player comes back | `stage_respawn_modes` (`respawn_mode`, `tbl_respawn_placement`) | 0 |
| the palettes | `ptrs_stage_palette_tasks` (a palette task) | `palette_task_058B4C` |
| the metatiles and maps (into `$7E`) | `ptrs_stage_map_load_lists` (a load list of `load_wram`; the maps are assets: [Assets](assets.md)) | `load_list_058AE6` (`stage1_bg1_map` ...) |
| the packed data into `$7F` | `ptrs_stage_7f_load_lists` | `load_list_058A93`, shared by every side-view stage |
| the enemies: spawn pages and their spawn lists, including the midpoint object that sets `stage_checkpoint` and the boss that sets `stage_exit_request` | `ptrs_stage_spawn_pages`, pointing to the `table` label of a new spawn list file in `assets/stages/` (text, `tools/spawns.py`: [Assets](assets.md)), included in `src/data/tables_05.asm` like stage 1's | `spawn_pages_059488`, stage 1's (`assets/stages/stage1.spawns`) |
| the music | `stage_songs` (an entry of `song_lists` + 2; a new song is a new entry at the end of `song_lists` and `song_start_commands`) | 1 (stage 1's) |
| the stage clear picture | `ptrs_stage_clear_pictures` (a load list) | `load_list_058808` |
| the frame code | `tbl_stage_runners` | `enter_side_view_stage` |
| the card text | `text_stage_2` ... `text_stage_7` (by position) | "STAGE 2" |
| a demo starting point, only if an attract demo is recorded for it | `demo_stage_checkpoints` | 0 |

The stage's objects themselves are object types (see [Objects](objects.md));
a boss that reuses one of another stage's must not depend on the code
that tests `STAGE_4` or `STAGE_6` ([Game flow](game-flow.md#stage-numbering)).

**A top-down stage** is more than this: the top-down code only tells
stage 2 from stage 5 (`run_topdown_stage`, `set_m7_patch_tile_attrs`,
`get_target_marker_attr`, the start points, `fade_out_step`), so a third
top-down stage needs those tests extended, and its own state table, maps
and tile attributes ([Top-down stages](topdown.md)).

## Testing

`tests/test_extra_stage.py` (`make stage-test`, and part of `make
emu-test`) builds the variant and plays it. The other stages must play
exactly as the original, one stage later, so their plays are compared
with the original's goldens (`tests/goldens/play/`), except on the stage
cards (whose number is checked in VRAM instead):

- the new stage 2, played by a scripted player (see
  [Collapsed Tower](stage2-collapsed-tower.md#testing)) from its start,
  from its checkpoint, with two players and through a continue: the
  mid-boss, the climb, the boss, the stage clear, the card "STAGE 3" and
  the top-down stage 3 (`stage_index` 2, the top-down frame);
- stage 1's boss: the card "STAGE 2", then the side-view stage 2;
- stage 7 from its midpoint on EASY (as `stage6_ending_easy`): the
  ending, the closing message, and stage 1 of the next loop on NORMAL;
- the attract sequence: the demos play stages 1, 3 and 5;
- with `stage_select`: the select screen cycles through STAGE 1 ...
  STAGE 7, and stage 3 starts the top-down stage.

`tools/c3emu/plays.py` takes the top-down stages and the last stage per
play (`EXTRA_TOPDOWN_STAGES`, `EXTRA_LAST_STAGE`) for this.
