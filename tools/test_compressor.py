#!/usr/bin/env python3
"""Test the matching compressor (tools/c3lz.py) on every compressed block.

    python3 tools/test_compressor.py [-v] [-s STRATEGY ...] [-b LABEL ...]
    make compress-test

The blocks are the ones the source marks as compressed: "; ASSET: compressed
..." (VRAM graphics, sound CPU streams) and "; Compressed data for WRAM ...".
Each is read from the built ROM (build/contra3.sfc) at its label, for the
length its length word gives; the labels' addresses come from a debug build
(tools/srcmap.py, build/dbg).  Nothing extracted is written to disk.

For each strategy: decompress the block, compress the result, compare with
the block.  Prints the number of exact matches and, for the mismatches, the
first differing byte, the size difference and the commands there.  Also checks
that every strategy round-trips (decompress(compress(x)) == x) on the blocks
and on a few synthetic inputs.  The original encoder came in two versions
(v1, v2); the last line counts the blocks that one of them reproduces.  Exits
non-zero if a strategy fails a round trip or a block is reproduced by neither.
"""
import argparse
import glob
import os
import random
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from c3lz import STRATEGIES, compress, decompress, parse  # noqa: E402
from srcmap import SrcMap  # noqa: E402

ROM = "build/contra3.sfc"
MARKER = re.compile(r";\s*(ASSET: compressed|Compressed data for WRAM)")
LABEL = re.compile(r"^(\w+):")


def lorom_offset(addr):
    return (addr >> 16 & 0x7F) * 0x8000 + (addr & 0x7FFF)


def find_blocks(srcdir="src"):
    """[(label, kind)] of every compressed-block marker, in file order."""
    blocks = []
    for path in sorted(glob.glob(os.path.join(srcdir, "**", "*.asm"), recursive=True)):
        lines = open(path).read().split("\n")
        for i, line in enumerate(lines):
            m = MARKER.search(line)
            if not m:
                continue
            j = i - 1
            while j >= 0 and not LABEL.match(lines[j]):
                j -= 1
            kind = "WRAM" if m.group(1).startswith("Compressed") else (
                "sound" if "sound" in line else "VRAM")
            blocks.append((LABEL.match(lines[j]).group(1), kind))
    return blocks


def load_blocks():
    srcmap = SrcMap.build()
    rom = open(ROM, "rb").read()
    dbg_rom = open(os.path.join("build", "dbg", "contra3.sfc"), "rb").read()
    if rom != dbg_rom:
        sys.exit(f"{ROM} is not the ROM src/ builds: run make first")
    out = []
    for label, kind in find_blocks():
        o = lorom_offset(srcmap.labels[label])
        n = rom[o] | rom[o + 1] << 8
        out.append((label, kind, rom[o:o + n]))
    return out


def describe(cmds, at):
    """The command covering stream offset `at` and the next one."""
    k = 0
    while k + 1 < len(cmds) and cmds[k + 1][4] <= at:
        k += 1
    parts = []
    for c in cmds[k:k + 2]:
        kind, pos, n, arg, _ = c
        if kind == 'R':
            parts.append(f"copy {n} from ring ${arg:03X} @{pos}")
        elif kind == 'B':
            parts.append(f"run {n}x${arg:02X} @{pos}")
        elif kind == '0':
            parts.append(f"zeros {n} @{pos}")
        elif kind == 'Z':
            parts.append(f"0/byte x{n} @{pos}")
        else:
            parts.append(f"{n} literals @{pos}")
    return ", ".join(parts)


def synthetic():
    rnd = random.Random(1)
    yield b""
    yield b"\x00"
    yield bytes(5000)
    yield b"\xff" * 70 + b"\x00" * 3
    yield bytes(rnd.randrange(4) for _ in range(3000))
    yield bytes(rnd.randrange(256) for _ in range(3000))
    yield bytes((0, rnd.randrange(256))[i & 1] for i in range(500))
    yield bytes(rnd.choice((0, 0, 0, 1, 0xFF)) for _ in range(4000))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("-s", "--strategy", action="append", choices=list(STRATEGIES),
                    help="strategies to test (default: all)")
    ap.add_argument("-b", "--block", action="append", help="only these labels")
    ap.add_argument("-v", "--verbose", action="store_true",
                    help="list every mismatch and the blocks per encoder version")
    args = ap.parse_args()

    blocks = load_blocks()
    if args.block:
        blocks = [b for b in blocks if b[0] in args.block]
    raws = [decompress(b) for _, _, b in blocks]
    total_in = sum(len(b) for _, _, b in blocks)
    print(f"{len(blocks)} compressed blocks, {total_in} bytes, "
          f"{sum(map(len, raws))} bytes decompressed")

    failed = False
    exact = {}
    for name in args.strategy or STRATEGIES:
        hits, size, lines = set(), 0, []
        for (label, kind, orig), raw in zip(blocks, raws):
            ours = compress(raw, name)
            size += len(ours)
            if decompress(ours) != raw:
                failed = True
                lines.append(f"    {label}: ROUND TRIP FAILED")
            if ours == orig:
                hits.add(label)
                continue
            at = next((k for k in range(min(len(ours), len(orig)))
                       if k >= 2 and ours[k] != orig[k]), min(len(ours), len(orig)))
            lines.append(f"    {label:16} {kind:5} size {len(ours) - len(orig):+5}, first "
                         f"difference at byte {at}: ROM {describe(parse(orig), at)}"
                         f" | ours {describe(parse(ours), at)}")
        for data in synthetic():
            if decompress(compress(data, name)) != data:
                failed = True
                lines.append(f"    synthetic input of {len(data)} bytes: ROUND TRIP FAILED")
        exact[name] = hits
        print(f"{name:16} {len(hits):4}/{len(blocks)} exact, "
              f"total {size} bytes ({size - total_in:+d})")
        for line in lines if args.verbose else lines[:3]:
            print(line)
        if not args.verbose and len(lines) > 3:
            print(f"    ... {len(lines) - 3} more (-v lists them all)")

    if "v1" in exact and "v2" in exact:
        v1, v2 = exact["v1"], exact["v2"]
        either = v1 | v2
        print(f"v1 or v2         {len(either):4}/{len(blocks)} exact "
              f"(both {len(v1 & v2)}, v1 only {len(v1 - v2)}, v2 only {len(v2 - v1)})")
        if args.verbose:
            for title, s in (("v1 only", v1 - v2), ("v2 only", v2 - v1),
                             ("neither", {b[0] for b in blocks} - either)):
                print(f"  {title}: {' '.join(b[0] for b in blocks if b[0] in s) or '-'}")
        if len(either) != len(blocks):
            failed = True
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main())
