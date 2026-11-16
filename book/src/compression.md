# Compression

Graphics, tilemaps, stage data and most sound CPU data are stored in one
LZ77-style format, decompressed by `src/engine/decompress.asm` (see
[Loading and decompression](engine.md#loading-and-decompression)).
`tools/c3lz.py` decompresses it and has a *matching compressor*: an encoder
that turns the decompressed data back into the exact bytes of the ROM. With
it, the graphics and data can later be built from editable files without
changing the ROM. This page gives the format, the encoder and how it was
found, and how to test it.

## The format

A stream is a little-endian word, the length of the stream including the
word, then commands until that length is reached (that is the only end
condition; the decompressed size is not stored). The output goes to the
loader's 1 KiB ring buffer (`LDR_RING`), which is also the window: the
decompressor clears it to zero when a stream starts and writes from
position 0. With n = (command & `$1F`) + 2:

| command | bytes | output |
|---|---|---|
| `$00-$7F` | 2 | back-reference: (command >> 2) + 2 bytes (2..33) copied from ring position (((command & 3) << 8 \| next byte) + `$21`) & `$3FF` |
| `$80-$9F` | 1 + count | command & `$1F` literal bytes (0..31) |
| `$A0-$BF` | 1 + n | n times (2..33): a zero, then the next literal byte |
| `$C0-$DF` | 2 | n copies of the next byte (2..33) |
| `$E0-$FF` | 1 | n zeros (2..33) |

A back-reference gives an absolute ring position, not a distance. It is
copied one byte at a time, so it can overlap the bytes it writes (a source
one byte back repeats a byte) and, early in a stream, it can read ring
positions not written yet, which are zero. The decompressor can stop after
any output byte and resume later (`LDR_STATE`): `decompress_ring` fills the
ring, `decompress_chunk` the next `$80` bytes; this does not change the
output, which is the same as decompressing the whole stream at once into a
1 KiB ring.

## The encoder

Every compressed block of the ROM is reproduced byte for byte by this
greedy encoder (`compress` in `tools/c3lz.py`). At each position it works
out:

- **back-reference**: the longest match, 2 to 33 bytes (fewer near the end
  of the data: it never compares past the end), whose source starts at most
  991 bytes back or in the 33 zero bytes just before the data; overlapping
  the current position is allowed. Of the sources with that length, the
  *nearest* one. The stored position is the source's position in the ring;
- **byte run** / **zero run**: the bytes equal to the first one, at most 33
  (or fewer, see the two versions below);
- **zero-interleaved run**: the (zero, byte) pairs, at most 17, complete pairs
  only.

It takes the command that saves the most bytes compared with literals
(back-reference: length - 2; byte run: length - 2; zero run: length - 1;
zero-interleaved: pairs - 1), ties going to byte run, then back-reference,
then zero run, then zero-interleaved; a command that saves nothing (a
2-byte back-reference or run) still beats a literal. When no command is
possible the byte is a literal; literals are gathered into runs of up to 31,
written when a command comes or the run reaches 31 (a count of 0 is never
used). There is no lazy matching or look-ahead: each choice depends only on
the position.

### Two versions

The encoder came in two versions, which differ only in the length of the
byte and zero runs:

- **v1**: a run stops 2 bytes before the end of the 33-byte look-ahead,
  which is shorter near the end of the data: at most min(33, bytes left) - 2,
  so never more than 31.
- **v2**: a run can use the whole look-ahead: at most min(33, bytes left).

v1 gives itself away where it is worse than v2: a run of exactly 32 bytes is
a run of 31 and a literal (v2: one run of 32); a long run of zeros is a
31-byte zero run and then 33-byte back-references one byte back, where v2
writes 33-byte zero runs; near the end of a block a run is a back-reference
instead. 66 blocks have none of these cases and come out the same with both;
40 need v1 and 75 need v2:

| blocks | v1 only | both | v2 only |
|---|---|---|---|
| VRAM graphics (100) | 11 | 37 | 52 |
| WRAM `$7E` streams (54) | 23 | 24 | 7 |
| WRAM `$7F` streams (16) | 0 | 0 | 16 |
| sound CPU data (11) | 6 | 5 | 0 |

So v1 made the sound data, most of the `$7E` streams and some graphics
sets (banks `$06`-`$08`, `$13`-`$16`, `$1E`); v2 made most graphics sets
and the `$7F` streams of banks `$0B` and `$11`-`$13`. `python3 tools/test_compressor.py -v -s v1 -s v2` lists the
blocks of each.

The build compresses every stream from its decompressed data (a PNG or a
`.bin`, see [Assets](assets.md)), so it needs to know which version made each one:
`assets/manifest.txt` gives it (`lz-v1` or `lz-v2`) per stream. The two
streams still inline in the source (`gfx_07E9FE`, `gfx_14DC62`, see
[Assets](assets.md#what-stays-inline-and-why)) are the ROM's bytes.

### Why this is an LZSS.C descendant

The encoder is not Haruhiko Okumura's LZSS.C (1989) as published, but its
parameters are LZSS.C's, with a ring of N = 1024 and a look-ahead of
F = 33:

- the decompressor adds `$21` to the stored position, that is, subtracts
  N - F = `$3DF`: the stored value is the source's position in an encoder
  ring whose first byte went to N - F, which is where LZSS.C starts writing
  (r = N - F);
- the farthest source used is 991 = N - F bytes back, as many positions as
  LZSS.C keeps in its tree;
- the only prefilled bytes that are ever matched are the 33 just before the
  data, the F strings LZSS.C inserts before it starts (positions r - 1 to
  r - F); the fill value is zero (LZSS.C uses spaces), which is also what
  the game clears its ring to.

What differs: the output is a command stream with run commands instead of
LZSS.C's flag bytes; of equally long matches the encoder takes the nearest,
where LZSS.C's binary tree takes whichever it meets first (another source in
about a third of the back-references); it chooses by bytes saved; and it does
not compare past the end of the data, where LZSS.C compares stale bytes. So
it is a rewrite on LZSS.C's frame (a hash chain or a plain search going
backwards gives the nearest match), not the original program with a new
output stage.

## Results

`make compress-test` (or `python3 tools/test_compressor.py`) reads the 181
compressed blocks from the built ROM: the 111 marked `; ASSET: compressed`
(100 VRAM graphics sets, 11 sound CPU streams) and the 70 marked
`; Compressed data for WRAM` (600,775 bytes, 941,381 decompressed). It
decompresses each, compresses it again with every strategy of
`tools/c3lz.py`, and compares:

| strategy | exact | size vs ROM | what it is |
|---|---|---|---|
| v1 | 106/181 | +958 | the encoder above, runs of v1 |
| v2 | 141/181 | -1,805 | the encoder above, runs of v2 |
| v1 or v2 | **181/181** | | each block with the version that made it |
| v1-okumura-tree | 10/181 | +958 | v1 with LZSS.C's binary tree choosing among equally long matches |
| v2-okumura-tree | 10/181 | -1,805 | the same for v2 |
| v2-farthest | 10/181 | -1,805 | v2 taking the farthest of equally long matches |
| v2-lazy | 14/181 | -607 | v2 writing a literal when the next position saves more |
| lzss-nearest | 5/181 | +10,700 | literals and back-references only |
| okumura | 0/181 | +10,700 | the same with LZSS.C's tree |

For each mismatch the test prints the first differing byte, the size
difference and the commands there in the ROM and in its output. It also
checks that every strategy round-trips (decompressing its output gives the
input back), on the blocks and on a few synthetic inputs, and fails if one
does not or if a block is reproduced by neither v1 nor v2.

The blocks come from `build/contra3.sfc` at their labels, whose addresses
come from a debug build (`tools/srcmap.py` builds one in build/dbg), so the
test checks what the build put in the ROM, whatever the source form of
each stream (see [Assets](assets.md)). The 19 uncompressed sound blocks
(`; ASSET: sound CPU data (uncompressed)`) are not streams and are skipped.

```
python3 tools/c3lz.py d stream.bin data.bin        # decompress
python3 tools/c3lz.py c data.bin stream.bin v1     # compress (default v2)
```
