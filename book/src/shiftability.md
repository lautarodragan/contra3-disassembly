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
`build/shift/contra3.sfc`, with the header checksum recomputed:

- at the start of every bank, a different amount per bank (1-14 bytes; bank
  `$00` has only 14 free bytes before the header). Everything in a bank
  moves, so any reference into it that is still a number points at the
  wrong place; different amounts also catch a label in the wrong bank
  (`lda #.loword(label)` only uses the low 16 bits, so the ROM would match
  with the label in any bank);
- with `--labels P --seed S`, also one byte before a fraction of the data
  labels (appended to the `.byte` line before them, so that line numbers
  stay those of `src/`): blocks move relative to each other, which catches
  tables read past their label into the next one.

`--amounts` picks the banks and amounts (`default`, `alt`, a number, or
`05=13,06=6`). Then:

```sh
make shift-test PRIVATE=../contra3-disassembly-private   # emulator suite on the shifted ROM
make shift-test SHIFT=05=13                              # only bank $05 moved
python3 tools/shift.py diff                              # what relocated, per source line
python3 tools/shift.py scan                              # hardcoded references of known forms
```

`make shift-test` runs the screenshot suite of the private repository on
the shifted ROM: it passes only if the intro, title, demos and stage starts
look exactly as in the original.

`tools/shift.py scan` needs nothing but the source: it fails on the forms
that have all been converted (a 16-bit immediate `>= $8000` handed to a
pointer field or routine such as `OBJ_ANIM`, `OBJ_SPRITE`,
`make_effect_object`, `start_palette_task`, `draw_text`,
`load_data_list`, `queue_vram_blocks`...; a literal bank pulled into DB; a
long operand into a ROM bank), and counts the other 16-bit immediates
`>= $8000` (mostly negative numbers). CI runs it, builds the shifted ROM
(`--labels 0.3`) and its diff; it cannot run the emulator (that needs the
ROM-holding private repository).

### Finding what breaks: `tools/shift_diag.py`

The screenshots say *that* something broke, not *what*. `tools/shift_diag.py`
runs the normal and the shifted build through the same scenario
(`--scenario attract` or `stageN`) in the patched snes9x of the private
repository with the CDL tracer on, maps every ROM byte the shifted build
reads back to its source line (through the two debug files) and stops at
the first chunk of frames where the shifted build reads data that the
normal build never reads, or that another instruction reads first. It
prints the reading instruction (as an address of the normal build with the
nearest label) and the source lines holding the bad pointer's value;
`-v` dumps the object slots of both runs. A hardcoded pointer reads what
is now at its old address, so this gives a precise worklist; it is how the
references below were found after the systematic passes.

## Status

Converted so far (about 3,000 label references added):

- every pointer immediate the scan knows (some 420: animation scripts,
  metasprites, palettes and palette tasks, text, HDMA tables and lists, song
  sets, data lists, VRAM block lists, wave parameters, title sprite groups,
  top-down enemy animations), all data-bank setups and long list reads;
- animation scripts (bank `$05`, 132 scripts, 488 entries, and their
  metasprites in banks `$06`/`$07`) and every table of script pointers found;
- the 79 + 12 data lists of `load_data_list` and the song sets, with 180
  streams labelled in banks `$06`-`$1F` (130 marked `ASSET`);
- 46 palette task scripts and the bank `$08` palettes they copy;
- `player_frames`, 27 metasprite tables, the text tables (and the 39
  strings, named after their text), the HDMA channel lists, the stage
  layout tables (palette tasks, DP parameters, load lists, HDMA lists,
  spawn pages and lists), the demo input pointers, the VRAM block tables.

Shifted alone, banks `$00`, `$01`, `$02`, `$03`, `$04`, `$06` and `$1D`
show no anomaly in `tools/shift_diag.py` over the attract sequence, and
with all of them shifted together every screenshot test passes (the CDL
tracer's own vector check (`tests/test_cdl.py`) fails by design: it expects the reset
code at `$00:8000`). So do they with a byte also inserted before 186 of
their data labels:

```sh
python3 tools/shift.py build --amounts 00=3,01=7,02=11,03=5,04=9,06=6,1D=12 \
    --banks 00,01,02,03,04,06,1D --labels 0.3 --seed 2
``` Bank `$05`
runs the intro, title, the stage 1 demo and part of the stage 2 demo; the
graphics/sound banks the attract sequence until the top-down sprite
graphics stream. Not yet shiftable: most of bank `$05`'s other tables,
bank `$07`, and the graphics bank holding the top-down sprite graphics
(`$13`).

## Known fixed references

These are still numbers, or depend on layout, on purpose or for now:

- **Overlapping data.** Some tables share bytes: the weapon capsule
  metasprite table (`data_05B17E`) starts with the jump word of the
  animation script before it, whose value `$B172` is also a metasprite
  (`$06:B172`); its last entry is the first word of the next table. The
  stage card text table (`data_058428`) is indexed from 1, so its entry 0
  is the end of the string before it. The animation `anim_05CD0B` ends with
  a frame whose bytes are also read by `update_palette_anim`. Moving one of
  these blocks alone changes the other; to make them independent the
  bytes would have to be duplicated, which changes the ROM.
- **The third word of animation frames** is a metasprite only for objects
  that can face the other way; effects keep an OAM attribute there
  (`update_effect`, `update_destructible_part`) and the bomber's bomb the
  script of its fire trail. Words `>= $8000` were taken as metasprites
  after checking that `draw_metasprite` reads them; an attribute with the
  vertical-flip bit set would have been mislabelled the same way and would
  show up in the shift test.
- **Top-down sprite graphics**: the tables in bank `$07` that give the
  ROM address (bank `$13`) of each rotated enemy and player frame for the
  VRAM stream (`stream_topdown_sprite_gfx`, the lists at `$1780`/`$17C0`)
  are still `.byte`, as are the top-down map event and spawn tables.
- **Bank `$05` tables** not converted yet: the 900-odd `data_` blocks
  include more pointer tables (found so far by the shift diagnostics as
  they come); `tools/shift.py scan` also counts some 970 16-bit immediates
  `>= $8000` that are loaded and not checked (mostly negative velocities,
  offsets and masks).
- **One bank of tables.** Most code runs with DB = `^tables_05` and reads
  tables with absolute addresses, and the loaders take 16-bit list pointers
  (`TABLES_05_BASE`): the tables can move inside bank `$05`, not to another
  bank. Likewise metasprites must stay in bank `$06` (top-down ones in
  `$07`) and palettes in bank `$08`.
- **Streams do not cross banks**: the decompressor reads with a 16-bit
  index, so a stream has to fit in its bank.
- **The header checksum** (`$00:FFDC`) is the original's; `tools/shift.py`
  recomputes it for the shifted ROM, the normal build keeps it as data.
