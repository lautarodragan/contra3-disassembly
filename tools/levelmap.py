#!/usr/bin/env python3
"""Level maps and their metatiles <-> text, exactly; level previews (book: Assets).

The WRAM streams the stages draw their playfield from (book: Assets, WRAM
streams of bank $7E).  Formats (FORMATS):

    metatiles  side-view metatile definitions: $20 bytes per metatile, its
               16 BG tilemap words (vhopppcc cccccccc) row by row, 4 rows
               of 4 tiles (draw_bg_column, draw_bg_row).  `first`: the
               number of the first metatile (BG1's second stream, at
               $7E:7000, starts at $100).
    blocks     top-down block definitions: $20 bytes per block, 16 words
               row by row, 4x4 Mode 7 tiles: the low byte is the Mode 7
               character (expand_m7_block); the high byte is not used
               (it looks like the palette / priority / flip bits of a BG
               tilemap word, probably left by the tool that made the maps;
               book: Assets, Level maps).
    bgmap      side-view map: one word per metatile, bits 0-13 the byte
               offset of the metatile (a multiple of $20), bit 14 a
               horizontal and bit 15 a vertical flip of the whole metatile;
               $80-byte pages of 8 rows of 8 metatiles (256x256 pixels).
    blockmap   top-down block map, one of the four $200-byte streams: 8 rows
               of 32 blocks, the block number in the low byte of a word
               (the high byte is not read); in the stream a row is 4 runs of
               8 words $80 bytes apart (build_m7_tilemap).

Text: `#` comments (the tool writes a header that explains the format) and
blank lines are ignored.

    metatiles, blocks   one line per definition: its number in hex, a
                        colon, then its 4 rows of 4 words, the rows
                        separated by `|`:
                            01A: 0C10 0C11 0C12 0C13 | 0C20 ... | ... | ...
                        The number must be the definition's place (the
                        tool checks it, so a line lost or added is caught).
    bgmap               one line per row of a page, 8 cells, a comment
                        `# page N` before each page: a cell is the metatile
                        number in hex (as in the metatiles text), then `h`
                        and/or `v` for a flip:  01A  01Ah  01Av  01Ahv
    blockmap            8 lines of 32 cells, the block numbers in hex (two
                        digits; four when the unread high byte is not 0).

    python3 tools/levelmap.py totext FORMAT IN.bin OUT [--first N]
    python3 tools/levelmap.py fromtext FORMAT IN OUT.bin [--first N]

Library: write_text(path, data, fmt, title, first), read_text(path, fmt,
first) -> bytes, and the preview helpers side_tilemap(), m7_tilemap(),
render().
"""
import argparse
import re
import sys

# format: (file extension, bytes per unit, unit name)
FORMATS = {
    "metatiles": (".metatiles", 0x20, "metatile"),
    "blocks": (".blocks", 0x20, "block"),
    "bgmap": (".map", 0x80, "page"),
    "blockmap": (".map", 0x200, "8 block rows"),
}
FLIP_H, FLIP_V = 0x4000, 0x8000
PAGE = 0x80            # bytes of a side-view map page (BG_MAP_OFFSET steps)
BLOCKMAP = 0x200       # bytes of a block map stream

METATILES_HELP = """\
Side-view metatiles: 4x4 tiles each, as draw_bg_column / draw_bg_row read
them. One line per metatile: its number (hex), then its 4 rows of 4 BG
tilemap words, top row first, rows separated by "|". A word is
vhopppcc cccccccc: $8000 v (vertical flip), $4000 h (horizontal flip),
$2000 o (priority), $1C00 ppp (palette 0-7), $03FF c (character 0-1023).
The map names a metatile by its number (map word = number * $20, plus the
flip bits). Which tiles collide is decided by the tile number (c), per
stage (book: Side-view collision map)."""
BLOCKS_HELP = """\
Top-down blocks: 4x4 Mode 7 tiles each, as expand_m7_block reads them.
One line per block: its number (hex), then its 4 rows of 4 words, top row
first, rows separated by "|". The low byte of a word is the Mode 7
character (00-FF). The high byte is not used: it looks like the high byte
of a BG tilemap word (vhopppcc: palette in bits 2-4, priority in bit 5,
08 0C 2C 34 ...), which Mode 7 does not have, probably left by the tool that made
the maps; kept as it is. (Only blocks 0-3 are ever read whole: as the tile
attributes of a row below the map, by the corner checks of objects on its
last row; book: Top-down stages.) The block map names a
block by its number; the tile attributes (walls, holes) come from the
characters (tile_attrs_stage2 ..., book: Top-down stages)."""
BGMAP_HELP = """\
A side-view map: pages of 8x8 metatiles (256x256 pixels), in the order of
BG_MAP_OFFSET (page N at offset N * $80; stage_bg1_map_offsets /
stage_bg2_map_offsets give the first page by stage layout). The stage reads
a page left to right, top to bottom; scrolling right (or up, on a vertical
stretch) moves to the next page. A cell: the metatile number (hex, as in
the .metatiles text), then h (horizontal flip) and/or v (vertical flip) of
the whole metatile."""
BLOCKMAP_HELP = """\
A top-down block map stream: 8 rows of 32 blocks (32x32 pixels each; the
four streams _0 to _3 are the rows 0-7, 8-15, 16-23 and 24-31 of the
32x32-block map, 1024x1024 pixels). A cell: the block number (hex, as in
the .blocks text)."""


def _words(data):
    return [data[i] | data[i + 1] << 8 for i in range(0, len(data) - 1, 2)]


def _wbytes(words):
    return b"".join(w.to_bytes(2, "little") for w in words)


# ------------------------------------------------------------------ text

def check_bytes(data, fmt):
    """Raise ValueError if the bytes cannot be written in this format."""
    unit = FORMATS[fmt][1]
    if fmt == "blockmap":
        if len(data) != BLOCKMAP:
            raise ValueError(f"{len(data)} bytes: a block map stream is ${BLOCKMAP:X}")
        return
    if len(data) % unit:
        raise ValueError(f"{len(data)} bytes: not a whole number of {FORMATS[fmt][2]}s "
                         f"(${unit:X} bytes)")
    if fmt == "bgmap":
        for i, w in enumerate(_words(data)):
            if w & 0x1F:
                raise ValueError(f"map word {i} (${w:04X}): not a metatile (offset not a "
                                 "multiple of $20)")


def _blockmap_order():
    """Byte offsets in the stream of the words of rows 0-7, columns 0-31."""
    return [(c // 8) * 0x80 + r * 0x10 + (c % 8) * 2 for r in range(8) for c in range(32)]


def text(data, fmt, title=None, first=0):
    check_bytes(data, fmt)
    ext, unit, uname = FORMATS[fmt]
    out = [f"# {title}"] if title else []
    if fmt in ("metatiles", "blocks"):
        n = len(data) // unit
        out.append(f"# {n} {uname}s, ${first:03X}-${first + n - 1:03X} (tools/levelmap.py {fmt})")
        out += ["# " + s for s in (METATILES_HELP if fmt == "metatiles" else BLOCKS_HELP).splitlines()]
        words = _words(data)
        for i in range(n):
            w = words[i * 16:i * 16 + 16]
            rows = [" ".join(f"{v:04X}" for v in w[r * 4:r * 4 + 4]) for r in range(4)]
            out.append(f"{first + i:03X}: " + " | ".join(rows))
    elif fmt == "bgmap":
        pages = len(data) // PAGE
        out.append(f"# {pages} pages (tools/levelmap.py bgmap)")
        out += ["# " + s for s in BGMAP_HELP.splitlines()]
        words = _words(data)
        for p in range(pages):
            out.append(f"# page {p} (map offset ${p * PAGE:04X})")
            for r in range(8):
                cells = []
                for c in range(8):
                    w = words[p * 64 + r * 8 + c]
                    flags = ("h" if w & FLIP_H else "") + ("v" if w & FLIP_V else "")
                    cells.append(f"{(w & 0x3FFF) >> 5:03X}{flags}".ljust(5))
                out.append(" ".join(cells).rstrip())
    else:
        out.append("# 8 rows of 32 blocks (tools/levelmap.py blockmap)")
        out += ["# " + s for s in BLOCKMAP_HELP.splitlines()]
        order = _blockmap_order()
        cells = [data[o] | data[o + 1] << 8 for o in order]
        wide = any(v > 0xFF for v in cells)
        out.append("# columns 0-31")
        for r in range(8):
            out.append(" ".join(f"{v:04X}" if wide or v > 0xFF else f"{v:02X}"
                                for v in cells[r * 32:r * 32 + 32]))
    return "\n".join(out) + "\n"


def write_text(path, data, fmt, title=None, first=0):
    with open(path, "w", newline="\n") as f:
        f.write(text(data, fmt, title, first))


_CELL = re.compile(r"([0-9A-Fa-f]{1,3})(h?v?|vh)")
_HEX4 = re.compile(r"[0-9A-Fa-f]{4}")


def _lines(source):
    for lineno, line in enumerate(source.splitlines(), 1):
        s = line.strip()
        if s and not s.startswith("#"):
            yield lineno, s


def parse(source, fmt, first=0, path="text"):
    """The bytes of a text in this format."""
    out = []
    if fmt in ("metatiles", "blocks"):
        uname = FORMATS[fmt][2]
        n = first
        for lineno, s in _lines(source):
            num, sep, rest = s.partition(":")
            if not sep or not re.fullmatch(r"[0-9A-Fa-f]{1,3}", num.strip()):
                raise ValueError(f"{path}:{lineno}: expected `NNN: words`, the {uname} number first")
            if int(num, 16) != n:
                raise ValueError(f"{path}:{lineno}: {uname} {num.strip()}, expected ${n:03X} "
                                 f"(the {uname}s are numbered in order)")
            rows = rest.split("|")
            if len(rows) != 4:
                raise ValueError(f"{path}:{lineno}: {len(rows)} rows, a {uname} has 4 "
                                 "(separated by |)")
            for row in rows:
                ws = row.split()
                if len(ws) != 4:
                    raise ValueError(f"{path}:{lineno}: a row of {len(ws)} words, a row has 4")
                for w in ws:
                    if not _HEX4.fullmatch(w):
                        raise ValueError(f"{path}:{lineno}: {w!r} is not 4 hex digits")
                    out.append(int(w, 16))
            n += 1
        return _wbytes(out)
    if fmt == "bgmap":
        rows = 0
        for lineno, s in _lines(source):
            cells = s.split()
            if len(cells) != 8:
                raise ValueError(f"{path}:{lineno}: {len(cells)} cells, a page row has 8")
            for c in cells:
                m = _CELL.fullmatch(c)
                if not m:
                    raise ValueError(f"{path}:{lineno}: {c!r} is not a metatile number "
                                     "(hex, up to 1FF) with h/v flags")
                num = int(m.group(1), 16)
                if num > 0x1FF:
                    raise ValueError(f"{path}:{lineno}: metatile {c}: past $1FF (the map "
                                     "word has 14 bits of offset)")
                out.append(num << 5 | (FLIP_H if "h" in m.group(2) else 0)
                           | (FLIP_V if "v" in m.group(2) else 0))
            rows += 1
        if rows % 8:
            raise ValueError(f"{path}: {rows} rows, not a whole number of pages (8 rows each)")
        return _wbytes(out)
    # blockmap
    cells = []
    nrows = 0
    for lineno, s in _lines(source):
        row = s.split()
        if len(row) != 32:
            raise ValueError(f"{path}:{lineno}: {len(row)} cells, a row has 32")
        for c in row:
            if not re.fullmatch(r"[0-9A-Fa-f]{2}|[0-9A-Fa-f]{4}", c):
                raise ValueError(f"{path}:{lineno}: {c!r} is not a block number (2 hex digits)")
            cells.append(int(c, 16))
        nrows += 1
    if nrows != 8:
        raise ValueError(f"{path}: {nrows} rows, a block map stream has 8 "
                         "(build_m7_tilemap reads 8 from each)")
    data = bytearray(BLOCKMAP)
    for o, v in zip(_blockmap_order(), cells):
        data[o:o + 2] = v.to_bytes(2, "little")
    return bytes(data)


def read_text(path, fmt, first=0):
    return parse(open(path).read(), fmt, first, path)


# --------------------------------------------------------------- previews

def page_positions(route, up=()):
    """{page: (column, row)} in pages, for a preview: the pages of `route`
    in the order the stage travels them, the first at the left, each next
    one to the right of the one before, or directly above it for a page of
    `up` (entered while the stage scrolls up: a vertical stretch). One
    continuous path, never wrapped: the picture is as wide and as tall as
    the path needs (rows counted from the top)."""
    out, col, row = {}, 0, 0
    for i, p in enumerate(route):
        if i:
            if p in up:
                row -= 1
            else:
                col += 1
        out[p] = (col, row)
    top = min((r for _, r in out.values()), default=0)
    return {p: (c, r - top) for p, (c, r) in out.items()}


def side_tilemap(map_data, defs, route=None, up=()):
    """A side-view map as a BG tilemap: (cells, width in cells). defs: the
    metatile definitions as WRAM holds them from the metatile base ($1000
    above the map base: BG1 $7E:5000, BG2 $7E:B000), up to $4000 bytes
    (missing bytes are 0). The pages of `route` (default: all, in order)
    are placed by page_positions(), 32x32 tiles each; a cell no page covers
    is None (drawn in colour 0)."""
    words = _words(map_data)
    pages = len(words) // 64
    route = list(range(pages)) if route is None else list(route)
    for p in route:
        if not 0 <= p < pages:
            raise ValueError(f"page {p}: the map has {pages} pages")
    where = page_positions(route, set(up))
    cols = max(c for c, _ in where.values()) + 1
    rows = max(r for _, r in where.values()) + 1
    width = cols * 32
    out = [None] * (width * rows * 32)
    defs = bytes(defs) + bytes(max(0, 0x4000 + 0x20 - len(defs)))
    for p in route:
        px, py = where[p][0] * 32, where[p][1] * 32
        for i in range(64):
            w = words[p * 64 + i]
            off, flip = w & 0x3FFF, w & 0xC000
            mx, my = px + i % 8 * 4, py + i // 8 * 4
            for ty in range(4):
                for tx in range(4):
                    sy = 3 - ty if flip & FLIP_V else ty
                    sx = 3 - tx if flip & FLIP_H else tx
                    o = off + (sy * 4 + sx) * 2
                    out[(my + ty) * width + mx + tx] = (defs[o] | defs[o + 1] << 8) ^ flip
    return out, width


def m7_tilemap(streams, blocks):
    """The 128x128 Mode 7 tilemap build_m7_tilemap makes from the four block
    map streams and the block definitions (as WRAM holds them at $7E:8000,
    up to $1000 bytes: the block maps follow at $7E:9000)."""
    blocks = bytes(blocks[:0x1000]) + bytes(max(0, 0x2000 - len(blocks)))
    order = _blockmap_order()
    out = [0] * (128 * 128)
    for s, data in enumerate(streams):
        data = bytes(data) + bytes(max(0, BLOCKMAP - len(data)))
        for i, o in enumerate(order):
            b = data[o]
            r, c = s * 8 + i // 32, i % 32
            for ty in range(4):
                for tx in range(4):
                    out[(r * 4 + ty) * 128 + c * 4 + tx] = blocks[b * 32 + (ty * 4 + tx) * 2]
    return out, 128


def render(cells, width, chars, bpp, palette, mode7=False):
    """(W, H, pixels, palette) of a tilemap given as cell values (BG words,
    or Mode 7 characters); chars: {character: 64 pixel indices}."""
    rows = len(cells) // width
    W, H = width * 8, rows * 8
    pixels = bytearray(W * H)
    blank = bytes(64)
    cache = {}
    for i, v in enumerate(cells):
        key = v if mode7 or v is None else v & 0xDFFF   # priority does not show
        tile = cache.get(key)
        if tile is None:
            if v is None:               # no page there (side_tilemap)
                tile = blank
            elif mode7:
                tile = bytes(chars.get(v, blank))
            else:
                t, pal = v & 0x3FF, v >> 10 & 7
                src = chars.get(t, blank)
                base = pal << bpp if bpp < 8 else 0
                rws = []
                for y in range(8):
                    sy = 7 - y if v & 0x8000 else y
                    row = list(src[sy * 8:sy * 8 + 8])
                    if v & 0x4000:
                        row.reverse()
                    rws.append(bytes(base + x if x else 0 for x in row))
                tile = b"".join(rws)
            cache[key] = tile
        x0, y0 = i % width * 8, i // width * 8
        for y in range(8):
            p = (y0 + y) * W + x0
            pixels[p:p + 8] = tile[y * 8:y * 8 + 8]
    pal = list(palette)[:256]
    pal += [(0, 0, 0)] * (256 - len(pal))
    return W, H, pixels, pal


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=["totext", "fromtext"])
    ap.add_argument("format", choices=list(FORMATS))
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--first", type=lambda s: int(s, 16), default=0)
    a = ap.parse_args(argv)
    if a.cmd == "totext":
        write_text(a.dst, open(a.src, "rb").read(), a.format, first=a.first)
    else:
        open(a.dst, "wb").write(read_text(a.src, a.format, a.first))
    return 0


if __name__ == "__main__":
    sys.exit(main())
