#!/usr/bin/env python3
"""Find the palette each graphics asset is shown with, in the emulator.

    python3 tools/gfx_palettes.py [--out build/gfx_palettes.json] [--every N] [--apply]

Only for viewing: the PNGs of assets/ keep palette indices, and their
palette (the colours a PNG viewer shows) changes nothing in the build (book:
Assets).  This tool picks those colours.  It runs the attract sequence and
the scripted plays (tools/c3emu/plays.py, one process each) and, every N
frames, looks at what is on screen: the BG1-BG3 tilemaps in VRAM (Mode 1;
BG1/BG2 4bpp, BG3 2bpp) or the Mode 7 characters, and the OAM buffer
(oam_buffer, oam_hi_table, obsel_shadow).  For each 8x8 character drawn, it
looks the character's bytes up among the tiles of the PNG-format assets
(assets/manifest.txt) and counts a vote for the colours it is drawn with,
taken from palette_buffer (the copy of CGRAM), unless they are all black
(the screen faded out).  The colours with the most
votes win; an asset with none keeps the grey ramp.  The result maps each
asset path to its colours (lists of [r, g, b]); with --apply, the palette
of each of those PNGs is replaced (the pixels, the data, stay the same).

Needs the snes9x core (make cores) and the default build.
"""
import argparse
import collections
import json
import multiprocessing
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
sys.path.insert(0, ROOT)
import assets  # noqa: E402
import snesgfx  # noqa: E402

PALETTE_BUFFER = 0x2200     # palette_buffer ($7E:2200), 512 bytes
OAM_BUFFER = 0x0FC0         # oam_buffer
OAM_HI = 0x11C0             # oam_hi_table
BGMODE = 0x1E84             # bgmode_shadow
OBSEL = 0x1E86              # obsel_shadow
BGSC = (0x1E8C, 0x1E8E, 0x1E90)   # bg1sc_shadow .. bg3sc_shadow
# BG12NBA/BG34NBA have no shadow: two settings (stage_setup_video, init.asm)
NBA_STAGE = (0x0000, 0x0000, 0x5000)
NBA_SCREEN = (0x2000, 0x2000, 0x5000)
OBJ_SIZES = [((8, 8), (16, 16)), ((8, 8), (32, 32)), ((8, 8), (64, 64)),
             ((16, 16), (32, 32)), ((16, 16), (64, 64)), ((32, 32), (64, 64)),
             ((16, 32), (32, 64)), ((16, 32), (32, 32))]


def tile_index():
    """{(fmt, tile bytes): {asset path}} over the PNG-format assets."""
    idx = collections.defaultdict(set)
    for a in assets.read_manifest():
        fmt = a.options.get("png")
        if not fmt:
            continue
        data = assets.data_bytes(a)
        size = snesgfx.FORMATS[fmt][1]
        key = "4bpp" if fmt == "4bpp" else fmt
        for t in range(len(data) // size):
            tile = data[t * size:(t + 1) * size]
            if any(tile):
                idx[(key, tile)].add(a.path)
    return {k: v for k, v in idx.items() if len(v) <= 3}


def colours(pal, first, n):
    out = []
    for i in range(first, first + n):
        w = pal[2 * i] | pal[2 * i + 1] << 8
        out.append(w)
    return tuple(out)


def snapshot(c, idx, votes):
    vram = c.vram()
    pal = c.ram(PALETTE_BUFFER, 512)
    if not any(pal):
        return
    mode = c.peek(BGMODE) & 7
    seen = []                   # (fmt, tile bytes, colours)
    if mode == 7:
        chars = vram[1::2][:0x4000]
        tmap = vram[0::2][:0x4000]
        for t in set(tmap):
            seen.append(("mode7", bytes(chars[t * 64:(t + 1) * 64]), colours(pal, 0, 256)))
    elif mode == 1:
        sc = [c.peek(a) for a in BGSC]
        nba = NBA_STAGE if (sc[0] >> 2) << 10 == 0x4000 else NBA_SCREEN
        for bg in range(3):
            base = (sc[bg] >> 2) << 10
            size = {0: 1024, 1: 2048, 2: 2048, 3: 4096}[sc[bg] & 3]
            bpp = 2 if bg == 2 else 4
            words = 4 * bpp
            refs = set()
            for i in range(size):
                a = ((base + i) & 0x7FFF) * 2
                refs.add(vram[a] | vram[a + 1] << 8)
            for w in refs:
                t, p = w & 0x3FF, w >> 10 & 7
                addr = ((nba[bg] + t * words) & 0x7FFF) * 2
                tile = bytes(vram[addr:addr + words * 2])
                n = 1 << bpp
                seen.append(("%dbpp" % bpp, tile, colours(pal, p * n, n)))
    obsel = c.peek(OBSEL)
    obase = (obsel & 7) << 13
    gap = ((obsel >> 3 & 3) + 1) << 12
    small, large = OBJ_SIZES[obsel >> 5]
    oam = c.ram(OAM_BUFFER, 512)
    hi = c.ram(OAM_HI, 32)
    for i in range(128):
        y, tile, attr = oam[4 * i + 1], oam[4 * i + 2], oam[4 * i + 3]
        if y >= 224 and y < 240:
            continue
        big = hi[i >> 2] >> ((i & 3) * 2 + 1) & 1
        w, h = large if big else small
        p = attr >> 1 & 7
        cols = colours(pal, 128 + p * 16, 16)
        for ty in range(h // 8):
            for tx in range(w // 8):
                t = (tile & 0xF0) + ((ty << 4) & 0xF0) + ((tile + tx) & 0x0F)
                addr = obase + (gap if attr & 1 else 0) + (t & 0xFF) * 16
                a = (addr & 0x7FFF) * 2
                seen.append(("4bpp", bytes(vram[a:a + 32]), cols))
    for fmt, tile, cols in seen:
        if max(max(w & 31, w >> 5 & 31, w >> 10 & 31) for w in cols[1:]) < 4:
            continue            # black (faded out): no colours to see
        for path in idx.get((fmt, tile), ()):
            votes[path][cols] += 1


def run_one(job):
    name, every = job
    from tools.c3emu import game, plays, retro
    from tools.c3emu.rom import rom_path
    idx = tile_index()
    votes = collections.defaultdict(collections.Counter)
    c = retro.Console(rom_path())
    if name == "attract":
        while c.frame_count < 21000:
            c.run(every)
            snapshot(c, idx, votes)
    else:
        for _ in plays.run(c, plays.PLAYS[name], every=every):
            snapshot(c, idx, votes)
    c.close()
    return {p: [(list(k), n) for k, n in v.items()] for p, v in votes.items()}


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--out", default="build/gfx_palettes.json")
    ap.add_argument("--every", type=int, default=60)
    ap.add_argument("--apply", action="store_true",
                    help="write the palettes into the PNGs of assets/")
    args = ap.parse_args()
    os.chdir(ROOT)
    from tools.c3emu import plays
    jobs = [("attract", args.every)] + [(n, args.every) for n in plays.PLAYS]
    total = collections.defaultdict(collections.Counter)
    with multiprocessing.Pool(int(os.environ.get("C3_JOBS", os.cpu_count()))) as pool:
        for res in pool.imap_unordered(run_one, jobs):
            for p, v in res.items():
                for k, n in v:
                    total[p][tuple(k)] += n
    out = {}
    for p, v in sorted(total.items()):
        words, n = v.most_common(1)[0]
        out[p] = {"colours": [list(c) for c in snesgfx.snes_palette(words)], "votes": n,
                  "of": sum(v.values())}
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    json.dump(out, open(args.out, "w"), indent=1)
    print(f"{args.out}: palettes for {len(out)} assets")
    if args.apply:
        for a in assets.read_manifest():
            if a.png and a.path in out:
                apply_palette(a.source, [tuple(c) for c in out[a.path]["colours"]])
    return 0


def apply_palette(png, palette):
    """Give a PNG of assets/ another palette, keeping its pixels."""
    W, H, pixels, old = snesgfx.read_png(png)
    palette = list(palette) + [(0, 0, 0)] * (len(old) - len(palette))
    snesgfx.write_png(png, W, H, pixels, palette[:len(old)])


if __name__ == "__main__":
    sys.exit(main())
