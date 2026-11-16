# Shiftability

Milestone 3 makes the source *shiftable*: inserting or removing bytes
anywhere must not break the game, because every reference between code
and data goes through a label instead of a ROM address written as a
number. This page says how the source expresses references, how that is
tested, how far it has got and what is still fixed.

## How references are written

- **Code operands** were already labels after milestone 1 (every absolute
  and long operand into ROM). What was left were *immediates* that are
  pointers: `lda #$C4CE` before `make_effect_object`, `ldx #$847E` before
  `draw_text_attr`... They are now `lda #.loword(anim_05C4CE)`,
  `ldx #.loword(text_continue)`.
- **Banks** come from labels: a routine that sets DB to the tables' bank
  says `lda #^tables_05` / `pha` / `plb`; the loaders, which read lists
  with a 16-bit pointer in X, read `f:TABLES_05_BASE,x`; the palette tasks
  `f:GFX_08_BASE,x` and `mvn #^gfx_08, #$7E`. `tables_05`, `sprites_06`,
  `sprite_data_07`, `gfx_08` and `sine_products` label the start of their
  data file.
- **Data with pointers** is written with the macros of
  `src/data_macros.inc`, one entry per line, so that the pointers are
  operands: animation scripts (`anim_frame`, `anim_goto`, `anim_end`), the
  lists of `load_data_list` (`load_list`, `load_vram`, `load_wram`,
  `load_spc`, `load_spc_raw`, `load_end`), palette task scripts
  (`palette_animate`, `palette_copy`, `palette_fade_in`, ...), HDMA
  channel lists (`hdma_channel`, `hdma_channel_ind`, `hdma_channels_end`)
  and `player_frame`. Plain pointer tables are `.addr` / `.faraddr` rows.
- **Labels** of data found this way are named after what they are when it
  is clear (`text_game_over`, `ptrs_stage_load_lists`, `demo_p1_input_ptrs`),
  otherwise after their kind and address: `anim_05C4CE` (animation script),
  `td_anim_` (top-down enemy animation), `metasprite_06AEA0`,
  `palette_task_`, `palette_088F92` (a palette in bank `$08`), `text_`,
  `load_list_`, `song_set_` (a type-2 list), `gfx_` / `packed_` /
  `spc_data_` / `spc_block_` (the streams of the lists: VRAM, WRAM, sound
  CPU, uncompressed sound block), `hdma_list_`, `hdma_table_`,
  `vram_blocks_` (lists for `queue_vram_blocks`), `spawn_pages_` /
  `spawn_list_`. Like the `data_` placeholders they mean "not named yet", but say
  what the data is.

Two tools edit the source by ROM address: `tools/srcmap.py` maps an
address to the line that emits it (through ld65's debug file), and
`tools/datafmt.py` adds labels (splitting `.byte` lines), turns bytes into
pointer expressions and macro rows, and rewrites operands; the ROM must
still match afterwards, which proves the values right.

The unused space at the end of every bank is no longer `.byte $FF` lines:
the linker fills it (`fill = yes` in `src/contra3.cfg`), and the header and
vectors are a segment of their own at `$00:FFC0` (`HEADER`), so a bank can
grow until it is full.

### Data blocks and assets

The streams of the data lists are labelled in the graphics and sound banks
and the first word of a stream is its length, so their bounds are exact.
Those that hold graphics (VRAM) or sound CPU data, and the uncompressed
sound blocks, have a comment

    ; ASSET: compressed graphics (VRAM), $0A:8000-$0A:8F11 (from its length word), loaded by load_list_05AA1F

meaning: bounds proven, no pointers inside; a later task can extract them
as binary files for editing. Streams decompressed to WRAM are labelled but
not marked yet (what they decompress to may hold pointers):
`; Compressed data for WRAM ... Not an ASSET yet`.

## The shift test

`tools/shift.py build` copies `src/` to `build/shift/src/`, inserts filler
bytes (`$EA`, NOP, harmless if it ever runs) and assembles
`build/shift/contra3.sfc`, with the header checksum recomputed. Where:

- at the start of every bank, a different amount per bank (1-14 bytes; bank
  `$00` has only 14 free bytes before the header). Everything in a bank
  moves, so any reference into it that is still a number points at the
  wrong place; different amounts also catch a label in the wrong bank
  (`lda #.loword(label)` only uses the low 16 bits, so the ROM would match
  with the label in any bank). `--amounts` picks them: `default`, `alt`
  (another assignment), `max` (each bank by as much as its free space
  allows, up to 256 bytes: the largest shift), a number, or `05=13,06=6`;
  `--banks` limits the shift to some banks;
- with `--files N`, also N bytes between consecutive files of a bank (after
  each `.include` of `main.asm` but the bank's last), as far as the bank's
  free space allows: code and data of one bank move relative to each other;
- with `--labels P --seed S`, also one byte before a fraction of the data
  labels (appended to the `.byte` line before them, so that line numbers
  stay those of `src/`): blocks move relative to each other, which catches
  tables read past their label into the next one. A label followed by a
  comment with `LAYOUT:` is left alone: the block before it is read on into
  it on purpose (see below).

All of these come out of the banks' free space, which is small in the
full banks (`$00`: 14 bytes, `$05`: 74), so `--labels` moves only some of
their labels per seed.

```sh
make shift-test                                          # emulator suite on the shifted ROM
make shift-test SHIFT=05=13                              # only bank $05 moved
make shift-test SHIFT=max
make shift-test SHIFT_FLAGS="--labels 0.3 --seed 2 --files 1"
python3 tools/shift.py diff                              # what relocated, per source line
python3 tools/shift.py scan                              # hardcoded references
```

### The suite

`make shift-test` runs two test files of the [emulator suite](emulator.md) on the
shifted ROM (not `tests/test_cdl.py`, which checks the reset vector of the
original layout):

- `tests/test_screens.py`: screenshots of the intro, title, the three
  attract demos and the first 600 frames of every stage;
- `tests/test_play.py`: scripted plays (`tools/c3emu/plays.py`):
  every stage from its start and from its midpoint (`$1E40` poked, which
  reaches the bosses, the stage clear screens and the next stage), 2-player
  modes A and B (the top-down split screen), HARD, the NORMAL ending of
  stage 6 and the attract sequence, about 330,000 frames of seeded random
  play with infinite lives and the barrier on. Every 60 game frames the
  screen and the sound command ring are compared with goldens taken from
  the original ROM, and the loudness of the audio.

A shifted ROM is not cycle-identical: an indexed read that crosses a page
takes a cycle more, so moving tables changes the timing by a few cycles,
and the game can lag on other frames, an IRQ land elsewhere, a sound reach
the sound CPU some samples later. The plays therefore feed their input
and take their checkpoints by the game's own frame counter
(`frame_counter`), accept a checkpoint within 2 game frames, tolerate a
lone checkpoint that differs in a few pixels (the top-down split screen),
and compare the audio by loudness, failing only on a difference that
lasts. A wrong reference shows as a wrong sprite, tile, palette or a
diverging game, which none of that hides.

### What the tools check

`tools/shift.py scan` needs nothing but the source. It fails on a 16-bit
immediate `>= $8000` handed to a pointer field or routine (`OBJ_ANIM`,
`OBJ_SPRITE`, `make_effect_object`, `start_palette_task`, `draw_text`,
`load_data_list`, `queue_vram_blocks`, `start_dying_soldier_sprite`...),
a literal bank pulled into DB, a long operand into a ROM bank; and on any
other 16-bit immediate `>= $8000` that is loaded or compared (`lda`,
`ldx`, `ldy`, `cmp`, `cpx`, `cpy`) unless its comment has the marker
`[num]`: a value checked to be a number (negative values, flag words,
velocities, OAM attributes, colours, WRAM and VRAM addresses...). `scan
--list` prints the unmarked ones. CI runs it, builds a shifted ROM
(`--labels 0.3`) and its diff; on pushes to `main` a second job runs
the emulator suite on the default and the shifted build (see
[Building](building.md#ci)).

`tools/shift_diag.py` runs the normal and the shifted build through the
same scenario (`attract`, `stageN`, or a play name such as `stage2_boss`)
in the patched snes9x (`make cores`) with the CDL tracer on,
maps every ROM byte the shifted build reads back to its source line and
stops at the first chunk of frames where the shifted build reads data the
normal build never reads, or that another instruction reads first. It
prints the reading instruction and the source lines holding the bad
pointer's value; `-v` dumps the object slots of both runs. With
`--fillers` it runs a `--labels` build to the end and lists every filler
byte read, with the label after it: a table read on into the next block.

`tools/ptrscan.py` follows the value loaded from each data label through
the routine and lists the tables still written as `.byte` whose entries
are used as addresses (indirect reads, `OBJ_SPRITE`, `queue_vram_blocks`,
`load_data_list`, the pointer-taking routines). `tools/layoutcheck.py`
lists the data labels whose bytes are first read by an instruction naming
an earlier label (`lda a:sine_table,y` reading `cosine_table`), and with
`--mark` gives them their `LAYOUT:` comment.

## Status

The default all-bank shift passes the whole suite: `test_screens.py` (13
tests) and `test_play.py` (16 plays), 29 tests. So do these (each a full
run of the 29):

```sh
make shift-test SHIFT=alt
make shift-test SHIFT=max
make shift-test SHIFT_FLAGS="--files 8"
make shift-test SHIFT_FLAGS="--labels 0.3 --seed 1"     # 607 data labels moved
make shift-test SHIFT_FLAGS="--labels 0.3 --seed 2"     # 628
make shift-test SHIFT=alt SHIFT_FLAGS="--labels 0.3 --seed 3 --files 4"
make shift-test SHIFT_FLAGS="--labels 0.5 --seed 4 --files 1"
```

(Each `--labels` run passed when last run; adding a `LAYOUT:` comment
changes which labels a seed picks.) In the top-down split screen (the
play stage2_2p) some checkpoints differ in a
few pixels and are reported as tolerated (see above). The full banks have
little free space, so each `--labels` seed moves only some 60 of bank
`$05`'s 1,000 labels: other seeds may still find a table read past its
end; `shift_diag.py --fillers` says which.

Converted (about 5,000 label references added in all):

- every pointer immediate (`scan` checks all 1,041 remaining 16-bit
  immediates `>= $8000` as verified numbers, marked `[num]`), all
  data-bank setups and long list reads;
- animation scripts (bank `$05`, 132 scripts, 488 entries, and their
  metasprites in banks `$06`/`$07`) and every table of script pointers found;
- the 79 + 12 data lists of `load_data_list` and the song sets, with 180
  streams labelled in banks `$06`-`$1F` (130 marked `ASSET`);
- 46 palette task scripts and the bank `$08` palettes they copy;
- `player_frames`, metasprite tables, the text tables, the HDMA channel
  lists, the stage layout tables (palette tasks, DP parameters, load lists,
  HDMA lists, spawn pages and lists), the demo input pointers, the VRAM
  block tables and the block lists that point into themselves, the scroll
  split patterns (`ptrs_scroll_split_patterns`), the ending's text lists;
- bank `$07`: the top-down sprite sets (`ptrs_td_metasprite_sets`,
  `ptrs_td_tile_lists`): 8 metasprite tables and 9 tile lists by sprite set,
  915 metasprites and 317 `td_tiles` records (macro) giving each rotated
  frame's tiles in WRAM or in the raw tile blocks `td_sprite_tiles_13`,
  `td_sprite_tiles_14`, `td_sprite_tiles_16`.

Some references the earlier passes had read wrong were found by the plays:
`$C540` handed to `queue_vram_block` is a WRAM address, not
`anim_05C540`; `lda a:$FF8A,x` in `td_update_bomb` reads the player's slot
`$80` below the bomb through the WRAM mirror of the next bank, not
`$05:FF8A`; four `ldy #$FFxx` are VRAM block lists at the end of bank
`$05`, not negative numbers.

## Known fixed references

These are still numbers, or depend on layout, on purpose:

- **Overlapping data.** Some tables share bytes: the weapon capsule
  metasprite table (`weapon_capsule_kind_sprites`) starts with the jump word of the
  animation script before it, whose value `$B172` is also a metasprite
  (`$06:B172`); its last entry is the first word of the next table. The
  stage card text table (`ptrs_stage_card_texts`) is indexed from 1, so its entry 0
  is the end of the string before it; likewise the stage graphics table
  `ptrs_0588E1`, whose entry 0 is the "S" and the end byte of CLEAR BONUS
  (it was a pointer to `$05:FF4D` and broke that letter on the stage
  clear screen), and `ptrs_td_tile_lists`, whose entry 0 is entry `$11` of
  `ptrs_td_metasprite_sets`. The animation `anim_05CD0B` ends with a frame
  whose bytes are also read by `update_palette_anim`. Moving one of these
  blocks alone changes the other; to make them independent the bytes
  would have to be duplicated, which changes the ROM.
- **Blocks read on from the one before** carry a `LAYOUT:` comment (some
  140): tables indexed past their label (often a CDL block boundary inside
  one table), `td_walk_y_int` read on into `td_walk_x_int` (the sine and
  cosine of the walk vectors), the HDMA tables that `copy_hdma_table`
  copies with a fixed length, the top-down item metasprites
  (`draw_td_item_metasprite` reads a fifth byte after the last sprite),
  labels inside palettes and block lists that the code points into, the
  last centipede frame (its tiles DMA'd past `td_sprite_tiles_14` into
  `gfx_14DC62`). `--labels` leaves them in place.
- **The third word of animation frames** is a metasprite only for objects
  that can face the other way; effects keep an OAM attribute there
  (`update_effect`, `update_destructible_part`) and the bomber's bomb the
  script of its fire trail. Words `>= $8000` were taken as metasprites
  after checking that `draw_metasprite` reads them.
- **Bank `$05` `data_` blocks** that no tool flags may still hold pointers
  the plays do not reach (unused data, rare paths); `tools/ptrscan.py`
  lists the candidates it can see.
- **One bank of tables.** Most code runs with DB = `^tables_05` and reads
  tables with absolute addresses, and the loaders take 16-bit list pointers
  (`TABLES_05_BASE`): the tables can move inside bank `$05`, not to another
  bank. Likewise metasprites must stay in bank `$06` (top-down ones in
  `$07`), palettes in bank `$08`, and a `td_tiles` record's two halves in
  one bank.
- **Streams do not cross banks**: the decompressor reads with a 16-bit
  index, so a stream has to fit in its bank.
- **The header checksum** (`$00:FFDC`) is the original's; `tools/shift.py`
  recomputes it for the shifted ROM, the normal build keeps it as data.
