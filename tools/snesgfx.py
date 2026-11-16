#!/usr/bin/env python3
"""SNES tile graphics <-> indexed PNG, exactly (book: Assets).

Pure Python (zlib only).  A tile is 8x8 pixels; each pixel is a palette
index, which the PNG stores as is, so that converting tiles to a PNG and
back gives the same bytes.  The PNG's palette is only for viewing.

Formats (FORMATS):

    2bpp, 4bpp, 8bpp  SNES planar tiles (16, 32, 64 bytes): bitplanes in
                      pairs, row by row (planes 0/1 in bytes 0-15, 2/3 in
                      16-31, ...), the leftmost pixel in bit 7
    mode7             Mode 7 characters: 64 bytes per tile, one byte per
                      pixel, row by row (the high bytes of VRAM words)

    python3 tools/snesgfx.py topng FORMAT IN.bin OUT.png [--width TILES]
    python3 tools/snesgfx.py frompng FORMAT IN.png OUT.bin [--tiles N]

Library: tiles_to_png(data, fmt, path, width, palette),
png_to_tiles(path, fmt, tiles) -> bytes.
"""
import argparse
import struct
import sys
import zlib

FORMATS = {"2bpp": (2, 16), "4bpp": (4, 32), "8bpp": (8, 64), "mode7": (8, 64)}
PNG_SIGNATURE = b"\x89PNG\r\n\x1a\n"


# ---------------------------------------------------------------- tiles

def decode_tile(data, fmt):
    """64 palette indices (row by row) of one tile."""
    bpp, size = FORMATS[fmt]
    if fmt == "mode7":
        return list(data[:64])
    out = [0] * 64
    for plane in range(bpp):
        base = (plane >> 1) * 16 + (plane & 1)
        for y in range(8):
            b = data[base + 2 * y]
            for x in range(8):
                if b >> (7 - x) & 1:
                    out[y * 8 + x] |= 1 << plane
    return out


def encode_tile(pixels, fmt):
    bpp, size = FORMATS[fmt]
    if fmt == "mode7":
        return bytes(pixels)
    out = bytearray(size)
    for plane in range(bpp):
        base = (plane >> 1) * 16 + (plane & 1)
        for y in range(8):
            b = 0
            for x in range(8):
                b |= (pixels[y * 8 + x] >> plane & 1) << (7 - x)
            out[base + 2 * y] = b
    return bytes(out)


def tile_count(length, fmt):
    """(tiles, tail bytes) of data of this length."""
    size = FORMATS[fmt][1]
    return length // size, length % size


# ---------------------------------------------------------------- PNG

def _chunk(kind, data):
    crc = zlib.crc32(kind + data) & 0xFFFFFFFF
    return struct.pack(">I", len(data)) + kind + data + struct.pack(">I", crc)


def write_png(path, width, height, pixels, palette):
    """An 8-bit indexed PNG; pixels: width * height indices; palette:
    [(r, g, b), ...].  Deterministic (no time or text chunks)."""
    raw = bytearray()
    for y in range(height):
        raw.append(0)       # filter: none
        raw += bytes(pixels[y * width:(y + 1) * width])
    out = PNG_SIGNATURE
    out += _chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 3, 0, 0, 0))
    out += _chunk(b"PLTE", b"".join(bytes(c) for c in palette))
    out += _chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    out += _chunk(b"IEND", b"")
    with open(path, "wb") as f:
        f.write(out)


def _paeth(a, b, c):
    p = a + b - c
    pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
    if pa <= pb and pa <= pc:
        return a
    return b if pb <= pc else c


def read_png(path):
    """(width, height, pixels, palette) of an indexed PNG (colour type 3,
    bit depth 1, 2, 4 or 8, not interlaced)."""
    data = open(path, "rb").read()
    if data[:8] != PNG_SIGNATURE:
        raise ValueError(f"{path}: not a PNG file")
    pos, idat, palette, header = 8, bytearray(), [], None
    while pos < len(data):
        n, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + n]
        pos += 12 + n
        if kind == b"IHDR":
            header = struct.unpack(">IIBBBBB", body)
        elif kind == b"PLTE":
            palette = [tuple(body[i:i + 3]) for i in range(0, len(body), 3)]
        elif kind == b"IDAT":
            idat += body
        elif kind == b"IEND":
            break
    width, height, depth, ctype, _comp, _filt, interlace = header
    if ctype != 3:
        raise ValueError(f"{path}: not an indexed (palette) PNG (colour type {ctype}); "
                         "the palette indices are the data: save it as indexed colour")
    if interlace:
        raise ValueError(f"{path}: interlaced PNGs are not supported")
    if depth not in (1, 2, 4, 8):
        raise ValueError(f"{path}: bit depth {depth}")
    raw = zlib.decompress(bytes(idat))
    stride = (width * depth + 7) // 8
    bpp = 1                     # bytes per pixel for the filters (at least 1)
    pixels = []
    prev = bytearray(stride)
    p = 0
    for _y in range(height):
        ftype = raw[p]
        line = bytearray(raw[p + 1:p + 1 + stride])
        p += 1 + stride
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b = prev[i]
            c = prev[i - bpp] if i >= bpp else 0
            if ftype == 1:
                line[i] = (line[i] + a) & 0xFF
            elif ftype == 2:
                line[i] = (line[i] + b) & 0xFF
            elif ftype == 3:
                line[i] = (line[i] + ((a + b) >> 1)) & 0xFF
            elif ftype == 4:
                line[i] = (line[i] + _paeth(a, b, c)) & 0xFF
            elif ftype != 0:
                raise ValueError(f"{path}: bad filter type {ftype}")
        prev = line
        if depth == 8:
            pixels += line[:width]
        else:
            per = 8 // depth
            mask = (1 << depth) - 1
            for x in range(width):
                pixels.append(line[x // per] >> (8 - depth * (x % per + 1)) & mask)
    return width, height, pixels, palette


# ---------------------------------------------------------------- both ways

def grey_palette(bpp):
    n = 1 << bpp
    return [(v, v, v) for v in (i * 255 // (n - 1) for i in range(n))]


def snes_palette(words):
    """RGB colours of SNES BGR555 words."""
    out = []
    for w in words:
        r, g, b = w & 31, w >> 5 & 31, w >> 10 & 31
        out.append(tuple(v << 3 | v >> 2 for v in (r, g, b)))
    return out


def tiles_to_png(data, fmt, path, width=16, palette=None):
    """Write the tiles of data (a whole number of tiles) as a PNG, width
    tiles wide; the last row is padded with tiles of colour 0."""
    bpp, size = FORMATS[fmt]
    ntiles, tail = tile_count(len(data), fmt)
    if tail:
        raise ValueError(f"{len(data)} bytes: not a whole number of {fmt} tiles")
    width = max(1, min(width, ntiles))
    rows = (ntiles + width - 1) // width
    W, H = width * 8, rows * 8
    pixels = bytearray(W * H)
    for t in range(ntiles):
        tile = decode_tile(data[t * size:(t + 1) * size], fmt)
        x0, y0 = t % width * 8, t // width * 8
        for y in range(8):
            pixels[(y0 + y) * W + x0:(y0 + y) * W + x0 + 8] = bytes(tile[y * 8:y * 8 + 8])
    palette = list(palette or grey_palette(bpp))
    palette += [(0, 0, 0)] * ((1 << bpp) - len(palette))
    write_png(path, W, H, pixels, palette[:1 << bpp])


def png_to_tiles(path, fmt, tiles=None):
    """The tile data of a PNG made by tiles_to_png: the first `tiles` tiles
    (default: all), row by row.  Fails if a pixel does not fit the format
    or a padding tile is not colour 0."""
    bpp, size = FORMATS[fmt]
    W, H, pixels, _palette = read_png(path)
    if W % 8 or H % 8:
        raise ValueError(f"{path}: {W}x{H} is not a whole number of 8x8 tiles")
    width = W // 8
    total = width * (H // 8)
    tiles = total if tiles is None else tiles
    if tiles > total:
        raise ValueError(f"{path}: {total} tiles, {tiles} expected")
    limit = 1 << bpp
    out = bytearray()
    for t in range(total):
        x0, y0 = t % width * 8, t // width * 8
        tile = [pixels[(y0 + y) * W + x0 + x] for y in range(8) for x in range(8)]
        if t >= tiles:
            if any(tile):
                raise ValueError(f"{path}: tile {t} is past the {tiles} tiles of the "
                                 "asset and must stay colour 0")
            continue
        bad = [v for v in tile if v >= limit]
        if bad:
            raise ValueError(f"{path}: tile {t} uses colour {bad[0]}, "
                             f"{fmt} has {limit} colours")
        out += encode_tile(tile, fmt)
    return bytes(out)


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=["topng", "frompng"])
    ap.add_argument("format", choices=list(FORMATS))
    ap.add_argument("src")
    ap.add_argument("dst")
    ap.add_argument("--width", type=int, default=16, help="tiles per row (topng)")
    ap.add_argument("--tiles", type=int, help="number of tiles (frompng; default all)")
    args = ap.parse_args(argv)
    if args.cmd == "topng":
        tiles_to_png(open(args.src, "rb").read(), args.format, args.dst, args.width)
    else:
        open(args.dst, "wb").write(png_to_tiles(args.src, args.format, args.tiles))
    return 0


if __name__ == "__main__":
    sys.exit(main())
