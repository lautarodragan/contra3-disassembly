# What the traces never touched

The [CDL](cdl-format.md) records, for every ROM byte, whether the game ran
it as code or read it as data (by the CPU or by DMA) in the traces of the
tracer ([Emulator tests](emulator.md#run-the-tracer): random sessions of
every stage, difficulty and mode, and the scripted plays). Of the 1,048,576
bytes, **100,317** are neither: the CDL calls them *unknown*. This page
accounts for every one of them.

`tools/coverage.py` (`make coverage`) does the accounting. It reads the
committed CDL, assembles the source with debug info (which line emits each
byte, which label it follows, which labels the source refers to and from
where), the asset manifest, and `tools/coverage_notes.json`, where the few
things it cannot see by itself are written down with the evidence. Every
unknown byte gets exactly one category; the output is deterministic.

```sh
make coverage                                  # summary, per bank, free space
make coverage COVERAGE_FLAGS="--top 12"        # the 12 largest owners of each group
make coverage COVERAGE_FLAGS=--list            # every run of unknown bytes
make coverage COVERAGE_FLAGS=--markdown        # the tables below
```

The numbers below are those of the committed CDL; nothing here comes from a
new trace or another emulator experiment.

## In short

| category | bytes | what it is |
|---|--:|---|
| free | 67,221 | the linker's `$FF` fill at the end of the banks (61,371) and padding the source writes out (5,850) |
| code | 12,924 | instructions never executed (the `; (not executed in the CDL traces)` stretches) |
| data | 18,696 | inside data blocks the code refers to: blocks never read, or table entries never read |
| unreferenced | 902 | blocks nothing refers to: an unused BG map, sprite tiles and palettes, three load lists, three stray bytes |
| asset | 512 | the end of a raw tile block never DMA'd |
| hardware | 60 | the cartridge header and the interrupt vectors never taken |
| leftover | 2 | a stale colour word at the end of bank `$08` |

So two thirds of the "unknown" ROM is free space, an eighth is code that
did not run (for most of it the reason is known: debug features, unused
routines, two-player situations and the map view the random plays never
reached), and most of the rest is data the code can reach but the traces
did not: animation frames, table entries, the end of the attract demos'
inputs. Under 1% is data nothing refers to, and each block of it is
identified below.

## By category

How each group is decided:

- **free / linker fill**: no source line emits the byte; `contra3.cfg` fills
  every bank to its end with `$FF`. **padding in the source**: a `.res`, or
  a run of at least 16 bytes of `$FF` (a few stray `$EF` allowed) that ends
  a block, or of `$00` that ends the bank's source.
- **hardware**: the regions of `tools/coverage_notes.json`: `rom_header`
  (no code reads it) and the vectors that are never taken (COP, BRK,
  ABORT, the emulation-mode ones; the power-on fetch of the reset vector is
  not in the traces, the NMI and IRQ vectors are).
- **unreferenced**: an asset whose label nothing refers to and which was
  never read; a data block whose labels have no reference in the source
  and none of whose bytes were read; bytes after an asset with no label of
  their own.
- **asset**: inside an `.incbin` (by the directory of the asset): a
  compressed stream never decompressed, or the part of a raw block never
  read.
- **data**: the other `.byte` / `.word` / `.addr` / macro lines, by owner
  (the label before them), split into *blocks never read* and *entries
  never read in tables that were read*, and grouped by the owner's name
  (`data_groups` in the notes). The size words before the sound CPU blocks
  (the upload lists carry the sizes, `load_spc_raw`) are a group of their
  own.
- **code**: the routine is the last label before the instruction that is
  not a `loc_`. If any of its bytes ran, the bytes are *paths not taken*.
  Otherwise the routine's name puts it in a group (`code_groups` in the
  notes: debug features, `unused_` names, the map view, player 2), or else
  the references to it do: none at all; only from code that never ran;
  from code that ran (the call was on a path never taken); or only from
  data (a pointer-table entry never used).

`make coverage COVERAGE_FLAGS=--markdown`, with the 5 largest owners of
each group:

| category | group | bytes | largest owners |
|---|---|--:|---|
| **free** | | **67221** | |
| | linker fill | 61371 |  |
| | padding in the source | 5850 |  |
| **hardware** | | **60** | |
| | cartridge header | 32 | `rom_header` 32 |
| | interrupt vectors never taken | 28 | `vectors` 28 |
| **leftover** | | **2** | |
| | stale bytes at the end of a bank | 2 | `palette_08F06E` 2 |
| **unreferenced** | | **902** | |
| | assets nothing loads | 872 | `unused_warning_message` 528, `unused_tiles_16BE11` 128, `unused_gfx_13F58D` 82, `unused_palette_088212` 66, `unused_palette_08810C` 34, ... (6) |
| | blocks nothing refers to | 27 | `unused_load_list_05D0C3` 9, `unused_load_list_05D0CC` 9, `unused_load_list_05D0D5` 9 |
| | stray code bytes | 3 | `unused_start_vram_task_linked` 3 |
| **asset** | | **512** | |
| | gfx: parts of blocks never read | 512 | `td_sprite_tiles_16` 512 |
| **data** | | **18696** | |
| | blocks never read: metasprites, animations and sprite tile lists | 7175 | `metasprite_07D9FD` 1841, `map_view_player_marker_sprites` 64, `anim_05C7A6` 60, `metasprite_06CCC6` 53, `metasprite_06CCFB` 53, ... (273) |
| | entries never read in tables that were read: metasprites, animations and sprite tile lists | 4045 | `td_small_object_tiles` 1178, `player_frames` 1158, `td_metasprites_player` 216, `td_tile_list_player` 216, `metasprite_06AD54` 99, ... (127) |
| | entries never read in tables that were read: other tables | 2338 | `type_scores` 195, `enemy_bullet_speeds_normal` 160, `stage2_boss_pod_offsets_x` 128, `stage2_target_type_sets` 104, `stage5_target_type_sets` 68, ... (257) |
| | blocks never read: other tables | 2025 | `unused_long_pointers_068000` 1296, `text_sound_check_mode` 19, `bomb_flash_coldata_blue` 16, `bomb_flash_coldata_white` 16, `load_list_059EDC` 14, ... (74) |
| | entries never read in tables that were read: trigonometry tables | 1634 | `sine_products` 1040, `half_turn_sine` 408, `td_boss_cosine` 128, `td_boss_sine` 32, `circle15_x` 16, ... (7) |
| | entries never read in tables that were read: demo inputs the demos end before reading | 990 | `demo_input_p1_0` 312, `demo_input_p2_0` 260, `demo_input_p1_2` 244, `demo_input_p2_1` 88, `demo_input_p2_2` 80, ... (6) |
| | blocks never read: sound check and song set lists | 255 | `sound_check_sound_ids` 112, `song_set_ending_full` 31, `song_set_heart_boss_full` 31, `song_set_game_over_full` 27, `song_set_konami_logo_full` 27, ... (6) |
| | blocks never read: trigonometry tables | 168 | `td_circle_r32_x` 128, `td_circle_r32_y` 32, `m7_matrix_sine_phases` 8 |
| | size words never read (sound CPU blocks) | 60 | `spc_driver` 2, `spc_sample_dir_boot` 2, `spc_sample_dir_opening` 2, `spc_sample_dir_stage1` 2, `spc_sample_dir_stage2` 2, ... (30) |
| | colours a palette's size word leaves out | 4 | `palette_08F032` 2, `palette_08F04E` 2 |
| | size words never read | 2 | `palette_088E46` 2 |
| **code** | | **12924** | |
| | paths not taken in routines that ran | 4212 | `stream_topdown_sprite_gfx` 458, `update_topdown_views` 355, `ground_aim_down` 139, `build_td_p2_bomb_window` 132, `ground_aim_down_left` 130, ... (223) |
| | two-player situations the traces did not reach | 2261 | `td_p2_vs_stage2_boss` 581, `draw_stage2_boss_arena_p2` 335, `draw_stage5_boss_arm_p2` 207, `draw_stage2_boss_cannon_p2` 195, `td_p2_shots_vs_stage5_boss` 189, ... (18) |
| | named unused: nothing in the game reaches it | 1906 | `unused_service_stream` 213, `unused_build_mode7_tilemap` 121, `unused_mode7_put_metatile` 119, `player_state_spin_jump_unused` 113, `unused_mode7_map_row` 96, ... (56) |
| | debug and test features (sound check, stage select, button codes, debug keys, demo recording) | 1533 | `debug_window_keys` 196, `game_mode_stage_select` 193, `td_debug_cheat_buttons` 117, `check_stage_select_code` 97, `check_30_lives_code` 89, ... (23) |
| | the top-down Select map view (never opened in the traces) | 814 | `map_view_open` 107, `map_view_player_position` 90, `draw_map_view_targets` 85, `draw_map_view_sprites` 74, `map_view_close` 73, ... (14) |
| | in tables: entries the traces never used | 787 | `player_tank_state_03` 98, `update_td_cannon_flame` 98, `climb_right_aim_down_left` 78, `climb_left_aim_down_right` 71, `palette_task_darken` 58, ... (29) |
| | called only from code that never ran | 717 | `multiply_scaled_approx` 116, `vram_task_script` 112, `player_tank_push_objects` 75, `clear_object_slot` 65, `stream_ring_to_apuio2` 49, ... (20) |
| | no reference in the source (dead code) | 560 | `queue_vram_block_at_map_position` 82, `multiply_16x16` 62, `clear_wram_7e8000_and_7ec000` 45, `begin_vram_transfer_low` 42, `clear_ram_0000_1bff` 23, ... (25) |
| | called from code that ran, by a path never taken | 134 | `spawn_shot_type_07_blasts` 95, `check_sound_stream_index` 26, `game_over_to_title` 9, `airborne_kill_player` 4 |
| **total** | | **100317** | |

Reading the code groups:

- **Debug and test features** are the leftovers of
  [Curiosities](curiosities.md#developer-leftovers): the sound check, the
  stage select, the button codes, the debug keys and demo recording. The
  game never enters them.
- **Named unused** and **no reference in the source** are dead code: the
  second group is the routines that nothing in the source refers to, most
  of them found by the unreferenced-routine heuristic of the
  [disassembler](disassembler.md#how-it-works) ("no caller found"); the
  clear routines and `multiply_16x16` are typical.
- **Two-player situations** and **the map view** are reachable, but the
  random plays never got there: most of the first group is player 2 in the
  boss fights of the top-down stages, and no traced session opened the map
  (Select in a top-down stage).
- **In tables** are handlers of states, aims or palette tasks that the
  traces never selected (the tank's state 3, aiming down while climbing a
  wall); **called only from code that never ran** follow from the groups
  above (`multiply_scaled_approx` is called by `unused_calc_mode7_matrix`).
- **Paths not taken** are branches inside routines that ran: error cases,
  rare situations, the other player's side.

## By bank

| bank | free | hardware | leftover | unreferenced | asset | data | code | total |
|---|--:|--:|--:|--:|--:|--:|--:|--:|
| `$00` | 14 | 60 | 0 | 3 | 0 | 70 | 4320 | 4467 |
| `$01` | 2331 | 0 | 0 | 0 | 0 | 105 | 2522 | 4958 |
| `$02` | 130 | 0 | 0 | 0 | 0 | 172 | 3470 | 3772 |
| `$03` | 436 | 0 | 0 | 0 | 0 | 1040 | 1896 | 3372 |
| `$04` | 7284 | 0 | 0 | 0 | 0 | 43 | 669 | 7996 |
| `$05` | 75 | 0 | 0 | 27 | 0 | 5123 | 0 | 5225 |
| `$06` | 190 | 0 | 0 | 0 | 0 | 4811 | 0 | 5001 |
| `$07` | 1021 | 0 | 0 | 0 | 0 | 6170 | 0 | 7191 |
| `$08` | 3956 | 0 | 2 | 134 | 0 | 6 | 0 | 4098 |
| `$09` | 1036 | 0 | 0 | 528 | 0 | 0 | 0 | 1564 |
| `$0A` | 645 | 0 | 0 | 0 | 0 | 0 | 0 | 645 |
| `$0B` | 482 | 0 | 0 | 0 | 0 | 0 | 0 | 482 |
| `$0C` | 838 | 0 | 0 | 0 | 0 | 0 | 0 | 838 |
| `$0D` | 1432 | 0 | 0 | 0 | 0 | 0 | 0 | 1432 |
| `$0E` | 1123 | 0 | 0 | 0 | 0 | 0 | 0 | 1123 |
| `$0F` | 238 | 0 | 0 | 0 | 0 | 0 | 0 | 238 |
| `$10` | 1855 | 0 | 0 | 0 | 0 | 0 | 0 | 1855 |
| `$11` | 3597 | 0 | 0 | 0 | 0 | 0 | 0 | 3597 |
| `$12` | 438 | 0 | 0 | 0 | 0 | 0 | 0 | 438 |
| `$13` | 8225 | 0 | 0 | 82 | 0 | 0 | 0 | 8307 |
| `$14` | 1289 | 0 | 0 | 0 | 0 | 0 | 0 | 1289 |
| `$15` | 1857 | 0 | 0 | 0 | 0 | 428 | 0 | 2285 |
| `$16` | 1339 | 0 | 0 | 128 | 512 | 556 | 0 | 2535 |
| `$17` | 3080 | 0 | 0 | 0 | 0 | 0 | 0 | 3080 |
| `$18` | 242 | 0 | 0 | 0 | 0 | 0 | 0 | 242 |
| `$19` | 283 | 0 | 0 | 0 | 0 | 0 | 0 | 283 |
| `$1A` | 3198 | 0 | 0 | 0 | 0 | 16 | 0 | 3214 |
| `$1B` | 658 | 0 | 0 | 0 | 0 | 4 | 0 | 662 |
| `$1C` | 2688 | 0 | 0 | 0 | 0 | 12 | 0 | 2700 |
| `$1D` | 12976 | 0 | 0 | 0 | 0 | 128 | 47 | 13151 |
| `$1E` | 4187 | 0 | 0 | 0 | 0 | 6 | 0 | 4193 |
| `$1F` | 78 | 0 | 0 | 0 | 0 | 6 | 0 | 84 |

Banks `$00`-`$04` and `$1D` hold the code; `$05`-`$07` the tables,
animations and metasprites; the others graphics, maps and sound data, which
the game reads whole (a compressed stream is read to its end, a sound
block is uploaded entirely), so their unknown bytes are almost only free
space.

## Free space per bank

For a hack: where a bank has room. *Linker fill* is the `$FF` that no
source line emits (`contra3.cfg` fills every bank, see
[Shiftability](shiftability.md)): code or data added at the end of a bank's
last file goes there without moving anything. *Padding in the source* is
fill the source writes out; most of it is the `$1600` zeros at
`$13:B602`-`$13:CC01` (after `td_sprite_tiles_13`), which can be replaced
by new data as long as `gfx_13CC02` stays where it is or its references
follow it. The last column is the free run that ends the bank (in bank
`$00`, the run before the header at `$00:FFC0`).

| bank | linker fill | padding in the source | free at the end of the bank |
|---|--:|--:|---|
| `$00` | 14 | 0 | 14 from `$00:FFB2` |
| `$01` | 2331 | 0 | 2331 from `$01:F6E5` |
| `$02` | 130 | 0 | 130 from `$02:FF7E` |
| `$03` | 436 | 0 | 436 from `$03:FE4C` |
| `$04` | 7284 | 0 | 7284 from `$04:E38C` |
| `$05` | 75 | 0 | 75 from `$05:FFB5` |
| `$06` | 190 | 0 | 190 from `$06:FF42` |
| `$07` | 1021 | 0 | 1021 from `$07:FC03` |
| `$08` | 3942 | 14 | 3958 from `$08:F08A` |
| `$09` | 1036 | 0 | 1036 from `$09:FBF4` |
| `$0A` | 645 | 0 | 645 from `$0A:FD7B` |
| `$0B` | 482 | 0 | 482 from `$0B:FE1E` |
| `$0C` | 838 | 0 | 838 from `$0C:FCBA` |
| `$0D` | 1432 | 0 | 1432 from `$0D:FA68` |
| `$0E` | 1123 | 0 | 1123 from `$0E:FB9D` |
| `$0F` | 238 | 0 | 238 from `$0F:FF12` |
| `$10` | 1855 | 0 | 1855 from `$10:F8C1` |
| `$11` | 3597 | 0 | 3597 from `$11:F1F3` |
| `$12` | 438 | 0 | 438 from `$12:FE4A` |
| `$13` | 2593 | 5632 | 2593 from `$13:F5DF` |
| `$14` | 1289 | 0 | 1289 from `$14:FAF7` |
| `$15` | 1665 | 192 | 1713 from `$15:F94F` |
| `$16` | 1327 | 12 | 1339 from `$16:FAC5` |
| `$17` | 3080 | 0 | 3080 from `$17:F3F8` |
| `$18` | 242 | 0 | 242 from `$18:FF0E` |
| `$19` | 283 | 0 | 283 from `$19:FEE5` |
| `$1A` | 3198 | 0 | 3198 from `$1A:F382` |
| `$1B` | 658 | 0 | 658 from `$1B:FD6E` |
| `$1C` | 2688 | 0 | 2688 from `$1C:F580` |
| `$1D` | 12976 | 0 | 12976 from `$1D:CD50` |
| `$1E` | 4187 | 0 | 4187 from `$1E:EFA5` |
| `$1F` | 78 | 0 | 78 from `$1F:FFB2` |
| total | 61371 | 5850 | |

The `$05` fill is where the cheat ROMs put their scaled HP tables
(`cheat_enemy_hp_tables`, [Cheats](cheats.md)). The padding of banks
`$15` and `$16` is `$FF` (with a few `$EF` in bank `$15`) between the
attract demos' input blocks.

## What the unreferenced bytes are

Each block that nothing refers to was disassembled as code and as data,
searched for elsewhere in the ROM (also in every decompressed asset) and
compared with its neighbours. The source now names them (`unused_` labels,
with the evidence in a comment), and the four graphics and palettes are
assets, so they appear in the [gallery](gallery.md).

**A legal notice for Japan** (`unused_warning_message`, `$09:F824`, 528
bytes). Right after `gfx_09EBBA` comes a compressed stream that no load
list, pointer or label refers to; its length word ends it exactly where
`stage6_bg1_metatiles_2` begins. It decompresses to a 32x32 BG map in the
character numbers of the font of the closing messages (`gfx_089D7E`,
the same numbering as `ending_message_easy`):

> WARNING
>
> THIS GAME IS FOR SALE AND USE IN JAPAN ONLY.
> THE COPYRIGHTED MUSIC, CHARACTERS,ART WORKS IN THIS
> GAME AER SEPARATELY OWNED BY THE AUTHORS.
> THE PUBLIC PERFORMANCE OUTSIDE THIS TERRITORY IS
> PROHIBITED BY LAWS AND THE VIOLATOR&nbsp; MAY BE SUBJECT TO
> SEVERE PENALTIES UNLESS SPECIALLY AUTHORIZED BY THEM.
>
> (the Konami logo) &copy; 1992 KONAMI

(typos as in the ROM: "AER", the double space). "WARNING" uses palette 1,
the Konami logo (characters of the same font) palette 6. The US game never
shows it: probably a screen of the Japanese release left in this ROM. Drawn
with the font and the CGRAM of the easy closing message's screen (checked
in the emulator, `tests/test_previews.py`):

<img src="gallery/gfx/unused_warning_message.png" alt="unused_warning_message" width="512" style="image-rendering: pixelated">

**A sprite nobody draws** (`unused_tiles_16BE11`, `$16:BE11`, 128 bytes):
four 4bpp tiles after `stage5_boss_sprite_tiles`, a 16x16 round shaded
ball (tiles 0 1 / 2 3). No label, pointer or `td_tiles` record refers to
them, and the tiles occur nowhere else in the ROM, raw or in any
decompressed asset, except in **`unused_gfx_13F58D`** (`$13:F58D`, 82
bytes), a compressed stream at the end of bank `$13` that nothing loads,
which decompresses to their bitplanes 0 and 1 (as 2bpp tiles) followed by
blank tiles. Grey levels, as no palette is known:

<img src="gallery/gfx/unused_tiles_16BE11.png" alt="unused_tiles_16BE11" width="128" style="image-rendering: pixelated">

**Three palettes nobody uses** (`unused_palette_08810C`,
`unused_palette_08812E`, `unused_palette_088212`): blocks of the palette
chain of bank `$08` (each starts where the one before ends, its size word
gives its end, see [Assets](assets.md)) that no palette task names. The
first is a ramp of 7 colours from purple to blue, the third eight 4-colour palettes whose
first 24 colours are also those of `palette_08843E`.

**A table of 324 long pointers** (`unused_long_pointers_068000`, the first
1,296 bytes of bank `$06`, before the first metasprite): `$7F:0000` to
`$7F:AC80` in steps of `$C0`, then `$7F:AD80` to `$7F:FF00` in steps of
`$100`, then `$08:8000` to `$08:8900` in steps of `$100`, each with a zero
byte. `draw_metasprite` only takes the bank of `sprites_06`; nothing refers
to these bytes. What it was for is not known.

**Three bytes of code after a return** (`$00:9B47`, in
`src/engine/palette_tasks.asm`): `ldx #$1280` right after the `rtl` of
`unused_start_vram_task_linked`, with no label: unreachable.

**Three one-stream load lists** (`unused_load_list_05D0C3` ...), already
named before this survey ([Curiosities](curiosities.md#developer-leftovers)).

The rest of the "unread but known" bytes are listed by the tool
(`--list`); a few details:

- the **size words** before every sound CPU block (`$2E00` before
  `spc_driver`, the size of its upload) are never read: the upload lists
  give the sizes themselves;
- **`td_sprite_tiles_16`** from `+$1600` (16 tiles) is never DMA'd: no
  `td_tiles` record reaches that far in the traces;
- the end of bank `$08` holds one more colour word, `$529F`, after the last
  palette block (the only *leftover*);
- the **attract demos** stop before the end of their recorded inputs, so
  the tails of `demo_input_p1_0` ... are never read.
