#!/usr/bin/env python3
"""Find what breaks in a shifted build: run it in the emulator with the CDL
tracer and report the first reads of ROM data that the normal build doesn't
make.

    python3 tools/shift_diag.py [--private ../contra3-disassembly-private]
                                [--out build/shift] [--scenario attract]
                                [--frames N] [--chunk 60]

Needs the build of `tools/shift.py build` in OUT (OUT/contra3.sfc and the
normal build in OUT/base/) and the private companion repository (patched
snes9x core with the CDL tracer, tools/c3emu).

Both ROMs play the same scenario from power-on: `attract` (no input) or
`stageN` (start the game at stage N, as the screenshot tests do).  Every
ROM byte the shifted build reads as data is mapped back to the source line
and byte it came from (through the two builds' debug files) and so to its
address in the normal build.  Reads that the normal build never makes in
the same scenario are anomalies: a hardcoded pointer reads the bytes now at
its old address, which are other data or the shift test's filler.  The
shifted run is checked every CHUNK frames and stops at the first chunk with
anomalies (later ones would mostly follow from the first); they are
printed with the instruction that read them (as an address in the normal
build with the nearest label), which tells whose pointer is wrong.
"""
import argparse
import bisect
import ctypes
import multiprocessing as mp
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import srcmap  # noqa: E402

DATA = 0x04 | 0x08     # plane A: read as data, or by DMA/HDMA


def lorom_offset(addr):
    return ((addr >> 16) & 0x7F) << 15 | (addr & 0x7FFF)


def lorom_addr(off):
    return (off >> 15) << 16 | 0x8000 | (off & 0x7FFF)


def _start(c, game, scenario):
    if scenario.startswith("stage"):
        game.start_game(c, stage=int(scenario[5:]))


def _plane_a(c):
    L = c.lib
    L.retro_cdl_rom_size.restype = ctypes.c_uint32
    L.retro_cdl_plane_a.restype = ctypes.c_void_p
    return ctypes.string_at(L.retro_cdl_plane_a(), L.retro_cdl_rom_size())


def _readers(c):
    L = c.lib
    L.retro_cdl_rom_size.restype = ctypes.c_uint32
    L.retro_cdl_readers.restype = ctypes.c_void_p
    n = L.retro_cdl_rom_size()
    return (ctypes.c_uint32 * n).from_address(L.retro_cdl_readers())


def run_reference(private, rom, scenario, frames, q):
    sys.path.insert(0, private)
    from tools.c3emu import game, retro
    c = retro.Console(rom)
    c.cdl_enable(True)
    _start(c, game, scenario)
    c.run(frames)
    q.put(_plane_a(c))
    c.close()


def run_shifted(private, rom, scenario, frames, chunk, ref, mapping, q):
    """Stops at the first chunk with anomalies; returns them with readers."""
    sys.path.insert(0, private)
    from tools.c3emu import game, retro
    c = retro.Console(rom)
    c.cdl_enable(True)
    _start(c, game, scenario)
    seen = bytearray(len(ref))
    done = 0
    while done < frames:
        n = min(chunk, frames - done)
        c.run(n)
        done += n
        a = _plane_a(c)
        bad = []
        for off in range(len(a)):
            if a[off] & DATA and not seen[off]:
                seen[off] = 1
                orig = mapping.get(off, -1)
                if orig == -1:
                    bad.append((off, None))
                elif not ref[orig] & DATA:
                    bad.append((off, orig))
        if bad:
            rd = _readers(c)
            q.put((c.frame_count, [(off, orig, rd[off]) for off, orig in bad]))
            c.close()
            return
    q.put((c.frame_count, []))
    c.close()


def build_mapping(out):
    """{shifted ROM offset: normal ROM offset} for every emitted byte."""
    a = srcmap.SrcMap.load(os.path.join(out, "base", "contra3.dbg"))
    b = srcmap.SrcMap.load(os.path.join(out, "contra3.dbg"))
    prefix = os.path.join(out, "")
    mapping = {}
    for pb, lines in b.lines.items():
        pa = pb[len(prefix):] if pb.startswith(prefix) else pb
        la = a.lines.get(pa)
        if not la:
            continue
        for ln, spans in lines.items():
            sa = la.get(ln)
            if not sa:
                continue
            xa = [x for s, n in sa for x in range(s, s + n)]
            xb = [x for s, n in spans for x in range(s, s + n)]
            for x, y in zip(xb, xa):
                mapping[lorom_offset(x)] = lorom_offset(y)
    return mapping, a


def find_literal(value, srcdir="src", limit=6):
    """Source lines with the 16-bit value as a literal: an operand or word,
    or two adjacent bytes of a .byte line (little-endian)."""
    import re
    word = "$%04X" % value
    pair = re.compile(r"\$%02X,\s*\$%02X\b" % (value & 0xFF, value >> 8))
    hits = []
    for root, _dirs, files in os.walk(srcdir):
        for f in sorted(files):
            if not f.endswith(".asm") or "/gfx" in root or f.startswith("sound_1"):
                continue            # data-only banks hold no pointers
            path = os.path.join(root, f)
            for n, line in enumerate(open(path), 1):
                code = line.split(";")[0]
                if re.search(r"\%s\b" % word, code) or (".byte" in code and pair.search(code)):
                    hits.append("%s:%d: %s" % (path, n, code.strip()[:70]))
                    if len(hits) >= limit:
                        return hits
    return hits


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--private", default=os.environ.get("PRIVATE", "../contra3-disassembly-private"))
    ap.add_argument("--out", default="build/shift")
    ap.add_argument("--scenario", default="attract")
    ap.add_argument("--frames", type=int, default=18300)
    ap.add_argument("--chunk", type=int, default=60)
    ap.add_argument("--max", type=int, default=40)
    args = ap.parse_args(argv[1:])
    private = os.path.abspath(args.private)
    mapping, base = build_mapping(args.out)
    ctx = mp.get_context("spawn")
    q = ctx.Queue()
    p = ctx.Process(target=run_reference, args=(private, os.path.abspath(os.path.join(args.out, "base", "contra3.sfc")),
                                               args.scenario, args.frames, q))
    p.start()
    ref = q.get()
    p.join()
    p = ctx.Process(target=run_shifted, args=(private, os.path.abspath(os.path.join(args.out, "contra3.sfc")),
                                             args.scenario, args.frames, args.chunk, ref, mapping, q))
    p.start()
    frame, bad = q.get()
    p.join()

    labs = sorted((v, n) for n, v in base.labels.items() if v >> 16 < 0x40)
    lv = [v for v, _n in labs]
    inv = {}

    def where(addr):
        i = bisect.bisect_right(lv, addr) - 1
        return "%s+$%X" % (labs[i][1], addr - labs[i][0]) if i >= 0 else "?"

    if not bad:
        print("%s: no anomalies in %d frames" % (args.scenario, frame))
        return 0
    print("%s: %d anomalous data reads by frame %d (first chunk with any):" % (args.scenario, len(bad), frame))
    # group by reader
    groups = {}
    for off, orig, rd in bad:
        groups.setdefault(rd, []).append((off, orig))
    for rd, items in sorted(groups.items(), key=lambda kv: -len(kv[1]))[:args.max]:
        if rd:
            r = rd - 1
            ro = mapping.get(lorom_offset(r & 0x7FFFFF), -1)
            rname = where(lorom_addr(ro)) if ro != -1 else "$%06X (shifted)" % r
        else:
            rname = "DMA/HDMA"
        first = items[0]
        lo = lorom_addr(first[0])
        desc = ("filler" if first[1] is None else "normal-build $%06X (%s)" % (lorom_addr(first[1]), where(lorom_addr(first[1]))))
        print("  reader %-40s %4d bytes, first at shifted $%06X = %s" % (rname, len(items), lo, desc))
        low = min(lorom_addr(o) for o, _x in items)
        for h in find_literal(low & 0xFFFF):
            print("      $%04X in %s" % (low & 0xFFFF, h))
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
