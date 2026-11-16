#!/usr/bin/env python3
"""SNES tilemaps <-> text grids, exactly; tilemap previews (book: Assets).

Formats (FORMATS):

    bg      BG tilemap (Modes 0-6): one little-endian word per 8x8 cell,
            vhopppcc cccccccc: v/h vertical/horizontal flip, o priority,
            ppp palette (0-7), cccccccccc character (0-1023).  A 32x32
            screen is 2,048 bytes, row by row.
    mode7   Mode 7 tilemap: one byte per cell, the character (0-255); the
            low bytes of VRAM words $0000-$3FFF, 128x128 cells.

The text form is one line per row of the map, one cell per column: four hex
digits per cell (bg) or two (mode7), separated by spaces.  Lines starting
with `#` are comments; the tool writes a header that explains the bits and
numbers the columns, and a comment with the row number every 8 rows (blank
lines are ignored too).  Any editor can change it; the build reads it back
to the same bytes.

    python3 tools/snesmap.py totext FORMAT IN.bin OUT.tilemap [--width N]
    python3 tools/snesmap.py fromtext FORMAT IN.tilemap OUT.bin [--width N]

Library: write_text(path, data, fmt, width, title), read_text(path, fmt,
width) -> bytes, cells(data, fmt), render(...) (a preview: the map drawn
with tiles and a palette, as an indexed PNG).
"""
import argparse
import re
import sys

FORMATS = {"bg": (2, 32), "mode7": (1, 128)}     # bytes per cell, default width

BG_HELP = """\
Each cell: the VRAM word in hex, bits vhopppcc cccccccc:
  $8000 v (vertical flip)  $4000 h (horizontal flip)  $2000 o (priority)
  $1C00 ppp (palette 0-7)  $03FF c (character 0-1023)
e.g. 6412 = h flip, palette 1, character $012."""
MODE7_HELP = """\
Each cell: the Mode 7 character (00-FF) in hex."""


def cells(data, fmt):
    n, _w = FORMATS[fmt]
    if len(data) % n:
        raise ValueError(f"{len(data)} bytes: not a whole number of {fmt} cells")
    if n == 1:
        return list(data)
    return [data[i] | data[i + 1] << 8 for i in range(0, len(data), 2)]


def text(data, fmt, width=None, title=None):
    n, default = FORMATS[fmt]
    width = width or default
    c = cells(data, fmt)
    if len(c) % width:
        raise ValueError(f"{len(c)} cells: not a whole number of rows of {width}")
    digits = 2 * n
    out = []
    if title:
        out.append(f"# {title}")
    out.append(f"# {fmt} tilemap, {width}x{len(c) // width} cells (tools/snesmap.py)")
    out += ["# " + line for line in (BG_HELP if fmt == "bg" else MODE7_HELP).splitlines()]
    out.append(f"# one line per row, {width} cells per line (columns 0-{width - 1})")
    for y in range(len(c) // width):
        if y % 8 == 0:
            out.append(f"# row {y}")
        out.append(" ".join(f"{v:0{digits}X}" for v in c[y * width:(y + 1) * width]))
    return "\n".join(out) + "\n"


def write_text(path, data, fmt, width=None, title=None):
    with open(path, "w", newline="\n") as f:
        f.write(text(data, fmt, width, title))


def parse(source, fmt, width=None, path="tilemap"):
    """The bytes of a tilemap text."""
    n, default = FORMATS[fmt]
    width = width or default
    digits = 2 * n
    out = bytearray()
    for lineno, line in enumerate(source.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        words = s.split()
        if len(words) != width:
            raise ValueError(f"{path}:{lineno}: {len(words)} cells, a row has {width}")
        for wd in words:
            if not re.fullmatch(f"[0-9A-Fa-f]{{{digits}}}", wd):
                raise ValueError(f"{path}:{lineno}: {wd!r} is not {digits} hex digits")
            out += int(wd, 16).to_bytes(n, "little")
    return bytes(out)


def read_text(path, fmt, width=None):
    return parse(open(path).read(), fmt, width, path)


# ---------------------------------------------------------------- previews

def render(data, fmt, width, chars, bpp, palette):
    """A preview of a tilemap: (W, H, pixels, palette) for snesgfx.write_png.

    chars: {character number: 64 pixel indices}, the characters the map
    uses (missing ones are drawn in colour 0); bpp: 2, 4 or 8 (the colour
    of a pixel is palette * 2**bpp + index; Mode 7: the index); palette:
    up to 256 (r, g, b)."""
    c = cells(data, fmt)
    rows = len(c) // width
    W, H = width * 8, rows * 8
    pixels = bytearray(W * H)
    blank = [0] * 64
    for i, v in enumerate(c):
        if fmt == "mode7":
            t, pal, hf, vf = v, 0, False, False
        else:
            t, pal, hf, vf = v & 0x3FF, v >> 10 & 7, bool(v & 0x4000), bool(v & 0x8000)
        tile = chars.get(t, blank)
        x0, y0 = i % width * 8, i // width * 8
        base = pal << bpp if bpp < 8 else 0
        for y in range(8):
            sy = 7 - y if vf else y
            row = tile[sy * 8:sy * 8 + 8]
            if hf:
                row = row[::-1]
            p = (y0 + y) * W + x0
            for x in range(8):
                pixels[p + x] = base + row[x] if row[x] else 0
    pal = list(palette)[:256]
    pal += [(0, 0, 0)] * (256 - len(pal))
    return W, H, pixels, pal


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=["totext", "fromtext"])
    ap.add_argument("format", choices=list(FORMATS))
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--width", type=int)
    a = ap.parse_args(argv)
    if a.cmd == "totext":
        write_text(a.dst, open(a.src, "rb").read(), a.format, a.width)
    else:
        open(a.dst, "wb").write(read_text(a.src, a.format, a.width))
    return 0


if __name__ == "__main__":
    sys.exit(main())
