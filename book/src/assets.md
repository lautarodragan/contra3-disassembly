# Assets

The graphics, the compressed streams the game decompresses to WRAM and the
sound CPU data are not `.byte` lines in `src/`: each block is a file under
`assets/`, included with `.incbin` right after its label. The graphics are
indexed PNGs that the build converts back to the game's tile format and
compresses, byte for byte the original; the palettes and the tilemaps are
text files (GIMP palettes, grids of hex numbers) that it converts the same
way. This page gives the layout, the formats, how to edit a graphic, a
palette or a tilemap, and what was left as it was, and why.

## Layout

```
assets/manifest.txt          every asset: its path and how the build makes it
assets/gfx/<label>.png       graphics (VRAM streams, td_sprite_tiles_16)
assets/gfx/<label>.tilemap   tilemaps loaded to VRAM (text)
assets/wram/<label>.png      the player's tiles (streams decompressed to WRAM $7F)
assets/wram/<label>.bin      the other streams decompressed to WRAM
assets/sound/<label>.bin     sound CPU data
assets/palettes/<label>.gpl  palettes (GIMP palettes)
assets/views.txt             how the gallery shows them (viewing only)
build/assets/<dir>/<label>.bin   the bytes of a PNG, palette or tilemap, made by the build
build/assets/<dir>/<label>.lz    the compressed streams, made by the build
```

The file is named after the label of the block; the label stays in the
`.asm` file, with its comments, right before the include:

```
gfx_0891DE:
	; ASSET: compressed graphics (VRAM), $08:91DE-$08:9224 (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_0891DE.lz"
```

A compressed stream is stored **decompressed**: `assets/gfx/gfx_0891DE.tilemap`
holds the 512 bytes the game decompresses to VRAM (a tilemap, as text), the
build converts them back to `build/assets/gfx/gfx_0891DE.bin` and compresses
them into `build/assets/gfx/gfx_0891DE.lz` with
`tools/c3lz.py`. The `.lz` file is the whole stream, its length word
included, so the size of the stream in the ROM is whatever the compressor
makes of the data. A graphic is stored as a PNG: the build converts
`assets/gfx/gfx_089D7E.png` to the font's tiles in
`build/assets/gfx/gfx_089D7E.bin` (`tools/snesgfx.py`), then compresses
those.

`assets/manifest.txt` says how each asset is made, one line per asset:

```
gfx/gfx_0891DE                   lz-v2  tilemap=bg
gfx/gfx_089249                   lz-v1  png=mode7 tiles=118 tail=00
gfx/gfx_089D7E                   lz-v2  png=2bpp tiles=253
sound/spc_block_1D8002           raw
```

- `lz-v1`, `lz-v2`: the source includes `<path>.lz`, compressed from the
  data with that version of the game's encoder (it came in two versions,
  see [Compression](compression.md#two-versions));
- `raw`: the source includes `<path>.bin`, the data as it is (the
  uncompressed sound blocks and `td_sprite_tiles_16`);
- without `png=`, the data is `assets/<path>.bin`; with `png=FORMAT`, it
  is the first `tiles` tiles of `assets/<path>.png` in that format, followed
  by the bytes that `tail` gives in hex (see [Graphics](#graphics-png));
- with `gpl=LAYOUT`, it is the palette `assets/<path>.gpl` (see
  [Palettes](#palettes-gimp-gpl)); with `tilemap=FORMAT`, the tilemap text
  `assets/<path>.tilemap` (see [Tilemaps](#tilemaps)).

ca65 looks the included path up in `assets/`, then in `build/assets/`:
every assembly of `src/` passes `--bin-include-dir assets
--bin-include-dir build/assets`. In the `Makefile`, `build/assets.mk`
(written by `python3 tools/assets.py makefile` from the manifest) has one
rule per made file (tiles from a PNG, a stream from its data; each also
depends on the three tools), and the made files (`asset_targets`) are
dependencies of `build/main.o`: editing a PNG or a `.bin` remakes that
asset only and reassembles. `make assets` makes them alone. The tools that
assemble `src/` themselves (`tools/srcmap.py`, `tools/cheats.py`,
`tools/shift.py`) go through `ca65_args` in `tools/assets.py`, which first
makes what is out of date. Making everything takes about ten seconds
(`make -j` runs the rules in parallel). The build needs only Python's
standard library.

Why binary files and not `.inc` files of `.byte` lines: the bytes are the
data itself, with no labels, pointers or expressions in them, so a text
form adds nothing but size, and a binary file is what any graphics or
compression tool reads and writes. `.incbin` is ca65's include for such a
file.

## What was moved

A block was moved only if its start and end are certain and nothing else
reads into it or past it:

- the start is a label that the data lists point to (`load_vram`,
  `load_wram`, `load_spc`, `load_spc_raw`) or that the `td_tiles` records
  use;
- the end comes from the data: a compressed stream starts with its length
  (the decompressor stops there); an uncompressed sound block has its size
  in its `load_spc_raw` entry; the raw sprite
  tiles `td_sprite_tiles_16` are `$1800` bytes, the end of the last
  `td_tiles` record that uses them (`+$1700`, `$100` bytes);
- the block's `.byte` lines hold only those bytes (no code, no other label,
  no `LAYOUT` comment saying that something reads across its bounds).

That is 199 blocks, 709,486 bytes in the ROM:

| assets | blocks | in the ROM | stored |
|---|---|---|---|
| `gfx/`, compressed | 98 | 376,310 | 549,343 decompressed |
| `gfx/`, `td_sprite_tiles_16` | 1 | 6,144 | 6,144 |
| `wram/`, compressed | 70 | 172,344 | 321,032 decompressed |
| `sound/`, compressed | 11 | 43,951 | 59,454 decompressed |
| `sound/`, uncompressed | 19 | 110,737 | 110,737 |

Of the 179 streams, 40 need `lz-v1` and 139 are made with `lz-v2` (66 of
these come out the same with either).

The two bytes that follow some sound blocks on the same `.byte` line (the
size or address word of the next block) stay inline after the include. A
CDL comment that fell inside a block is kept above the include with its
offset (`; from +$1600: CDL: not accessed`).

The WRAM streams are moved too although what they decompress to is not
checked for pointers yet: the compressed bytes cannot hold a label either
way, so moving them to a file changes nothing for shifting.

Later, by the same rule: 48 palettes (3,908 bytes in the ROM, see
[Palettes](#palettes-gimp-gpl)), and the 18 tilemaps among the streams
above became text files (see [Tilemaps](#tilemaps)).

## What stays inline, and why

- `gfx_07E9FE`: `draw_td_item_metasprite` reads one byte past the last
  sprite of the metasprite before, which is the first byte of this
  stream's length word (its `LAYOUT` comment). Changing the stream's size
  would change that byte.
- `gfx_14DC62`: the last `td_tiles` record of the centipede DMAs `$100`
  bytes from `td_sprite_tiles_14 + $1F80`, `$80` of them from the start of
  this stream.
- `td_sprite_tiles_14`: for the same reason (a record reads past its end).
- `td_sprite_tiles_13`: the `td_tiles` records only use its first `$A00`
  bytes; the `$1600` bytes after them are not referenced, so where the
  block really ends is not known.
- Six palette blocks of bank `$08` (see
  [Palettes](#palettes-gimp-gpl)), and the tables: banks `$05`-`$07` hold
  pointers.

## Graphics (PNG)

97 assets are graphics whose format is known, stored as indexed PNGs:

| format | assets | what |
|---|---|---|
| `4bpp` | 74 VRAM streams, `td_sprite_tiles_16`, 16 WRAM streams | BG1/BG2 characters and sprites: 32 bytes per 8x8 tile, 16 colours |
| `2bpp` | 1 (`gfx_089D7E`, the font) | BG3 characters: 16 bytes per tile, 4 colours |
| `mode7` | 5 (`gfx_089249`, `gfx_13CC02`, `gfx_148000`, `gfx_158000`, `gfx_168000`) | Mode 7 characters: 64 bytes per tile, one byte per pixel, 256 colours |

`tools/snesgfx.py` converts both ways. The SNES planar formats (`2bpp`,
`4bpp`, `8bpp`) store a tile's rows as bitplane pairs (planes 0 and 1 in
bytes 0-15, row by row, then planes 2 and 3, ...), the leftmost pixel in
bit 7; `mode7` is the high bytes of Mode 7 VRAM, one pixel per byte. A PNG
is 16 tiles (128 pixels) wide, the tiles in order left to right, top to
bottom, as they are in VRAM; the last row is padded with tiles of colour 0.
Each pixel's value in the PNG *is* the colour index in the data.

How the format of each was worked out, from where it is loaded:

- the data lists give each VRAM stream's destination. In the side-view
  stages (`stage_setup_video`: BG12NBA `$00`, BG34NBA `$05`, OBSEL `$03`,
  BG Mode 1) words `$0000`-`$3FFF` are BG1/BG2 characters (4bpp),
  `$4000`-`$4FFF` the BG1/BG2 tilemaps, `$5000`-`$5BFF` BG3 characters
  (2bpp), `$5C00`-`$5FFF` its tilemap and `$6000`-`$7FFF` sprite
  characters (4bpp). The title and the other screens (`init.asm`:
  BG12NBA `$22`, BG34NBA `$55`) have their tilemaps at `$0000`-`$1FFF`
  and characters from `$2000`; the lists of the attract sequence, the
  title, the stage intro screens (`load_list_058808` to `load_list_058868`,
  `load_list_058976`) and `load_list_05CF41` use that layout. The
  top-down stages (Mode 7) have their sprites at `$4000`-`$7FFF`;
- a list of type 3 loads one byte of each VRAM word (`load_vram_byte_list`):
  flags bit 0 clear, the high bytes, which in Mode 7 are the characters
  (`mode7`); bit 0 set, the low bytes, the Mode 7 tilemap;
- the WRAM streams of bank `$7F` (`$7F:0000`-`$7F:FFFF`, two sets of eight
  `$2000`-byte streams, loaded by different lists) are sprite tiles that
  the NMI copies from WRAM to sprite VRAM (the player's frames,
  `player_frames`): 4bpp; `td_sprite_tiles_16` is DMAd to sprite VRAM:
  4bpp;
- every PNG was then looked at: a wrong depth shows at once (rows doubled
  or halved, noise).

**Round trip.** `make` builds the ROM from the PNGs, so the hash check
proves that every PNG gives back the original bytes. `make assets-check`
checks the other direction: each PNG's tiles, drawn again, give the same
pixels, so a PNG holds nothing that the build would drop. The PNG writer
is deterministic (no time or text chunks; zlib level 9), so converting
again gives the same file.

Data that is not a whole number of tiles: 16 streams are one byte longer
than their tiles (8,193 bytes for 256 4bpp tiles, for instance; the
decompressor writes that byte after them). The manifest keeps
it as `tail=` (hex), appended after the tiles.

**Palettes.** The PNG's palette is only for viewing; the build ignores
it. `tools/gfx_palettes.py` picked them: it runs the attract sequence and
the scripted plays in the emulator and, every 120 frames, finds the
characters on screen (BG tilemaps, Mode 7, the OAM buffer) among the
tiles of the PNG assets, and counts the colours each is drawn with (from
`palette_buffer`, the copy of CGRAM). The most frequent palette of each
asset was written into its PNG (`--apply`); palettes that are all black (a
faded-out screen) do not count. 90 of the 97 got a palette this way; the
other 7 (`gfx_0E8307`, `gfx_11C386`, `gfx_148000`, `gfx_15DCD9`,
`gfx_168000`, `gfx_17D20E`, `gfx_1AE9C9`) were never seen on screen at
those moments and keep a grey ramp. An asset shown
with several palettes (a sprite sheet shared by enemies of several
colours) has the most frequent one.

71 PNGs have colours that are those of exactly one palette asset (an
aligned or unaligned run of 2, 16 or 256 colours of it); `assets/views.txt`
links them (a line `palette`, the PNG, the palette, the first colour). `python3 tools/assets.py
sync-palettes` copies the palette's colours into those PNGs, so after
editing a palette, run it to see the graphics in the new colours; `make
assets-check` fails while a linked PNG's colours differ from its
palette's. The others (14 whose colours are in several palettes, the
font among them, the Mode 7 graphics, whose 256 colours come from several
palettes, and the grey ones) keep their colours.

The [Graphics gallery](gallery.md) shows all 97.

## Not graphics, or format not known: still `.bin`

- the 54 streams decompressed to WRAM bank `$7E`: what they hold
  (tilemaps, metatiles, collision data, graphics copied to VRAM later) is
  not worked out per stream yet;
- the 30 sound CPU blocks (11 compressed, 19 not): the driver, the sample
  directories, the samples and the songs; what each is and where it goes
  in the sound CPU's memory is in [Sound](sound.md#sound-cpu-memory).

## Tilemaps

The 18 tilemaps loaded to VRAM are text files, `assets/gfx/<label>.tilemap`
(`tilemap=` in the manifest, `tools/snesmap.py`):

| format | assets | what |
|---|---|---|
| `bg` | 17 | BG maps (Mode 1): one VRAM word per 8x8 cell, 32 cells per row |
| `mode7` | 1 (`gfx_06FADF`) | the Mode 7 map of the title logo: one byte per cell, 128x128 |

- `gfx_06EF5C`, `gfx_06EC94` (BG1, `$4000` and `$4400`) and `gfx_06F184`
  (BG2, `$4800`), loaded by `load_list_05A7DB`, and `gfx_06F313`,
  `gfx_06F68F` (`load_list_05A807`): the opening's scenes
  (`ptrs_05A7AF`; `opening_scene_blank` sets BG1SC `$41`, BG2SC `$49`);
- `gfx_06F84C`, `gfx_06F996`, `gfx_07F78E`: the BG3 map at `$5C00` of the
  closing message, one per difficulty (`ptrs_ending_message_loads`);
- `gfx_088FD4` (`$1000`), `gfx_0891DE` (`$0000`, 8 rows) and `gfx_089225`
  (`$0100`, 8 rows): the Konami logo (`load_list_0587AB`);
- `gfx_18AAE3`, `gfx_18D15B`, `gfx_18FAF5`, `gfx_19AB40`, `gfx_19D779`: the
  stage clear pictures; `gfx_1EEBD0`: the FINAL SCORE screen;
- `gfx_06FADF`: the low bytes of VRAM `$0000`-`$3FFF` (`load_list_058539`,
  a list of type 3 with flags bit 0 set).

A `bg` cell is the word the PPU reads, `vhopppcc cccccccc`: vertical and
horizontal flip, priority, palette (0-7) and character (0-1023). A 2,048-byte
map is one 32x32 screen; the two 512-byte ones are 8 rows of one. The text
has one line per row, one hex number per cell (four digits, or two for
`mode7`), and `#` comments (a header that recalls the bits, the row
number every 8 rows):

```
# gfx_0891DE
# bg tilemap, 32x8 cells (tools/snesmap.py)
...
# row 0
0800 0800 0800 0800 ...
```

Any text editor changes it; the build reads the numbers back (each row
must have its 32 or 128 cells), so the round trip is exact. To convert
another `.bin` that is a tilemap: `python3 tools/assets.py tilemap bg
PATH` (it checks the round trip and records `tilemap=` in the manifest).
Tiled and similar map editors are not used: their formats have no
palette or priority bits per cell.

**Previews.** A tilemap is drawn in the [gallery](gallery.md#tilemaps) when
`assets/views.txt` says which characters and colours the game shows it
with: the graphics assets its load list puts in VRAM (at their VRAM
address), the BG's character base, and the palettes its palette task
copies to CGRAM. 12 have one:

- the five stage clear pictures: characters at `$2000` and `$3000` (the
  BG12NBA `$22` of the screens), `palette_08882C` (`palette_task_058880`);
- the FINAL SCORE screen: `gfx_1FE855`, `gfx_1AE9C9`, `palette_088B7A`
  (`load_list_058976`, `palette_task_05898E`);
- the five maps of the opening: the characters of `load_list_05A7DB` at
  `$0000`-`$3FFF` (stage layout), `palette_0889F0`
  (`palette_task_05A815`, from `opening_cinematic_init`);
- the title logo (Mode 7): `gfx_089249`, `palette_0880AA`
  (`load_title_graphics`).

No preview: the Konami logo's three maps (their characters, `gfx_07E9FE`,
stay inline, see above) and the three BG3 maps of the closing message
(which colours CGRAM holds then is not worked out). The previews are
made by `make book` (`gallery-copy`), from the assets: editing a tilemap,
a graphic or a palette changes them.

## Palettes (GIMP .gpl)

The colours are BGR555 words: bits 0-4 red, 5-9 green, 10-14 blue (bit 15
unused). The game keeps them in two places:

- **bank `$08`**: palette *blocks*, a word (the size in bytes minus 1),
  then the colours. `palette_task_animate` copies size+1 bytes with `mvn`,
  the fades (`palette_task_fade_in`, `palette_task_fade_out`) read as many
  (see [Engine](engine.md#palettes)); the scripts in bank `$05` name the
  block and the destination in the palette buffer. `$08:8000`-`$08:8FD3`
  is a chain of 43 such blocks, each starting where the one before ends
  (its size word gives its end), and `$08:EFCA`-`$08:F089` holds 7 more;
  three of these are followed by one colour that their size word leaves
  out (kept inline after the include);
- **bank `$05`**: four 16-colour palettes (`palette_05912A`,
  `palette_05914A`, `palette_05916A`, `palette_05918A`) that
  `nmi_frame_side_view` DMAs to CGRAM, 32 bytes, from `cgram_upload_src`
  (the flashing of hit bosses).

48 are files: 44 blocks of bank `$08` (`gpl=block`) and the 4 of bank
`$05` (`gpl=colours colours=16`: the DMA copies 32 bytes, so the build
stops if the file does not have 16 colours). The first block,
`palette_088000`, is at `gfx_08`, the label of the bank. Left inline:

- `$08:810C`, `$08:812E`, `$08:8212`: blocks that nothing points to
  (CDL: not accessed);
- `palette_088C3E`: `palette_088C60` is inside it
  (`update_stage2_boss_core` copies `$71` bytes from there);
- the block at `$08:8E68`: its 48 colours are three palettes,
  `palette_088E6A`, `palette_088E8A` and `palette_088EAA`, that
  `stage5_boss_flash_on_hit` copies alone, 33 bytes each (`mvn` with
  `$20`): one byte more than the 16 colours;
- `palette_088ECA`: the 33rd byte of the copy of `palette_088EAA` is its
  first byte.

A palette file is a [GIMP palette](https://developer.gimp.org/core/standards/gpl/)
(`.gpl`), which GIMP, Aseprite, Krita, Inkscape and text editors open:

```
GIMP Palette
Name: palette_088022
Columns: 16
#
  0   0   0	$0000
  0   0  99	$3000
```

One line per colour, in order: red, green and blue (0-255, a 5-bit
component `c` shown as `c << 3 | c >> 2`) and, as the colour's name, the
word. `tools/snespal.py` reads a line as its word when the red, green and
blue are that word's colour, so the round trip is exact (bit 15
included); a line whose colour was changed (an editor keeps the old name)
gives the new colour, each component `>> 3`. `make assets-check` reports
lines that are not exact words; `python3 tools/assets.py normalize`
rewrites them so. The build writes the block (size word and colours) or
the colours to `build/assets/palettes/<label>.bin`. A block may have more
or fewer colours (its size word follows), but where the palette task
copies them is in its script: more colours overwrite the ones after.

## Shifting

The assets move with their banks like the bytes did: the label is in the
source, the file is only its contents. `tools/shift.py build --labels`
also inserts a filler byte before labels that follow an `.incbin` (through
a small macro, `shift_incbin_filler`, that it adds to its copy of
`main.asm`), so assets move relative to each other in the shift test too.

## Editing a graphic

Open the PNG (`assets/gfx/<label>.png`, `assets/wram/<label>.png`) in an
editor that keeps it in **indexed colour** (palette) mode: GIMP (Image >
Mode > Indexed, which it already is), Aseprite, GraphicsGale, Pro Motion,
or Pillow. Draw with the palette's colours; the colour's *index* is what
goes into the ROM, so:

- keep the image indexed, and do not let the editor reorder, sort or
  "optimize" the palette (that renumbers the pixels); changing the
  palette's colours is harmless;
- use only the first 4 (`2bpp`), 16 (`4bpp`) or 256 (`mode7`) colours;
- keep the size, and leave the padding tiles after the last tile (if any)
  colour 0. The build stops with a message naming the tile if not.

Then run `make`. To start from a `.bin` that is not a PNG yet, `python3
tools/assets.py topng FORMAT PATH` converts it and records `png=` in the
manifest (it checks the round trip first).

## Editing a palette or a tilemap

A palette: open `assets/palettes/<label>.gpl` in GIMP (Windows > Dockable
Dialogs > Palettes, then the palette editor), Aseprite (Presets > Load
Palette) or a text editor, change colours, save as a GIMP palette, run
`make`. Colours are 5 bits per component: a value between two SNES
colours is rounded down (`make assets-check` names such lines;
`python3 tools/assets.py normalize` writes them as the exact colours).
Then `python3 tools/assets.py sync-palettes` gives the linked PNGs the new
colours (for viewing). To check a palette in the game, `make emu-test`
(the screenshots that show it will differ from the goldens).

A tilemap: edit the hex numbers of `assets/gfx/<label>.tilemap` (keep 32
cells per row, or 128 for `gfx_06FADF`, and the number of rows), run
`make`; `make book` draws the previews again.

## Editing an asset

Edit the PNG or the `.bin` (or replace it) and run `make`. The stream is
recompressed with the version the manifest gives; if it comes out longer
or shorter, everything after it in its bank moves, which the source
allows since every reference to it is a label (milestone 3). The ROM is
then no longer the original, so `make` reports a `MISMATCH` against
`contra3.sha1` (`make build/contra3.sfc` builds without the check); run it
in the emulator with `make emu-test` (the screenshots that show the edited
graphic will differ from the goldens, the plays should pass).

What the build does not check: the decompressed size. The game
decompresses a stream to the address in its data list until the stream
ends; a larger asset overwrites whatever follows it in VRAM or WRAM. Keep
the size unless you know what is there.

An example, done in a throwaway copy of the repository (before the
graphics were PNGs, so on the `.bin`; on the PNG it is the same edit): in
the 2bpp font `assets/gfx/gfx_089D7E` (loaded at VRAM `$5000` for BG3), tile 73,
the letter N (bytes `$490`-`$49F`), replaced by a framed box with a
cross. The stream went from 1,978 to 1,977 bytes, so the 10 labels after it
in bank `$08` (`gfx_08A538` to the end of the bank) moved down by one
byte. The ROM built, `tools/shift.py build --labels 0.3 --seed 1` built a
shifted copy of it, and both run: the title screen of the shifted ROM, with
the new N in `OPTION` and the copyright lines:

![The title screen with an edited letter N](img/asset-edit-demo.png)

With goldens taken from the edited ROM (`--update-goldens`, in that copy),
the emulator suite's screenshots and scripted plays (`tests/test_screens.py`,
`tests/test_play.py`, 29 tests) pass on the shifted copy: moving the bank
after the edited stream changes nothing on screen.
