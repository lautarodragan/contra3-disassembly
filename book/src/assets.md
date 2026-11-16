# Assets

The graphics, the compressed streams the game decompresses to WRAM and the
sound CPU data are not `.byte` lines in `src/`: each block is a file under
`assets/`, included with `.incbin` right after its label. This page gives
the layout, what was moved and what was left inline, and why.

## Layout

```
assets/gfx/<label>.lz       compressed graphics streams (load_vram lists)
assets/gfx/<label>.bin      uncompressed graphics (td_sprite_tiles_16)
assets/wram/<label>.lz      compressed streams decompressed to WRAM (load_wram)
assets/sound/<label>.lz     compressed sound CPU data (load_spc)
assets/sound/<label>.bin    uncompressed sound CPU blocks (load_spc_raw)
```

The file is named after the label of the block; the label stays in the
`.asm` file, with its comments, right before the include:

```
gfx_0891DE:
	; ASSET: compressed graphics (VRAM), $08:91DE-$08:9224 (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_0891DE.lz"
```

The path is relative to `assets/`: every assembly of `src/` passes
`--bin-include-dir assets` to ca65 (the `Makefile`, and
`tools/srcmap.py`, `tools/cheats.py` and `tools/shift.py` through
`ca65_args` in `tools/assets.py`), and the `Makefile` makes every file
under `assets/` a dependency of `build/main.o`.

Why binary files and not `.inc` files of `.byte` lines: the bytes are the
data itself, with no labels, pointers or expressions in them, so a text
form adds nothing but size, and a binary file is what any graphics or
compression tool reads and writes. `.incbin` is ca65's include for such a
file. A `.lz` file is a whole stream as the ROM holds it, length word
included.

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

That is 199 blocks, 709,486 bytes:

| files | blocks | bytes |
|---|---|---|
| `assets/gfx/*.lz` | 98 | 376,310 |
| `assets/gfx/*.bin` | 1 | 6,144 |
| `assets/wram/*.lz` | 70 | 172,344 |
| `assets/sound/*.lz` | 11 | 43,951 |
| `assets/sound/*.bin` | 19 | 110,737 |

The two bytes that follow some sound blocks on the same `.byte` line (the
size or address word of the next block) stay inline after the include. A
CDL comment that fell inside a block is kept above the include with its
offset (`; from +$1600: CDL: not accessed`).

The WRAM streams are moved too although what they decompress to is not
checked for pointers yet: the compressed bytes cannot hold a label either
way, so moving them to a file changes nothing for shifting.

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
- The palettes of bank `$08` and the other tables: they are not marked
  `ASSET` (palettes overlap: some labels are inside the palette before),
  and banks `$05`-`$07` hold pointers.

## Shifting

The assets move with their banks like the bytes did: the label is in the
source, the file is only its contents. `tools/shift.py build --labels`
also inserts a filler byte before labels that follow an `.incbin` (through
a small macro, `shift_incbin_filler`, that it adds to its copy of
`main.asm`), so assets move relative to each other in the shift test too.
