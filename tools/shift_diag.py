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

Both ROMs play the same scenario from power-on: `attract` (no input),
`stageN` (start the game at stage N, as the screenshot tests do) or one of
the scripted plays of the private repository (`tools/c3emu/plays.py`, as
`tests/test_play.py` runs them: `stage2_boss`, `stage6`...).  Every
ROM byte the shifted build reads as data is mapped back to the source line
and byte it came from (through the two builds' debug files) and so to its
address in the normal build.  Reads that the normal build never makes in
the same scenario are anomalies: a hardcoded pointer reads the bytes now at
its old address, which are other data or the shift test's filler.  The
shifted run is checked every CHUNK frames and stops at the first chunk with
anomalies (later ones would mostly follow from the first); they are
printed with the instruction that read them (as an address in the normal
build with the nearest label), which tells whose pointer is wrong.

With --fillers it only runs the shifted build, to the end of the scenario,
and lists every filler byte of the shift test that was read, with the
label after it: in a `--labels` build that is a table read past its end
into the next block (mark the next label LAYOUT) or a label inside a
block.  A 16-bit read of a block's last byte also touches the filler after
it and is harmless when the high byte is dropped (draw_text reads its
characters so): those are left out.
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


def _chunks(c, scenario, frames, chunk):
    """Runs the scenario, yielding after every `chunk` frames (up to `frames`):
    `attract` (no input), `stageN` (the game started at stage N, no input),
    or a scripted play of the private repository (tools/c3emu/plays.py:
    seeded random play through a stage, e.g. `stage2_boss`)."""
    from tools.c3emu import game, plays
    if scenario in plays.PLAYS:
        done = 0
        for done in plays.run(c, plays.PLAYS[scenario], every=chunk):
            yield
            if done >= frames:
                return
        return
    if scenario.startswith("stage"):
        game.start_game(c, stage=int(scenario[5:]))
    done = 0
    while done < frames:
        n = min(chunk, frames - done)
        c.run(n)
        done += n
        yield


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


def run_reference(private, rom, scenario, frames, q, wram_at=None):
    sys.path.insert(0, private)
    from tools.c3emu import retro
    c = retro.Console(rom)
    c.cdl_enable(True)
    if wram_at is not None:
        for _ in _chunks(c, scenario, frames, 1):
            if c.frame_count >= wram_at:
                break
        q.put(bytes(c.ram(0, 0x2000)))
    else:
        for _ in _chunks(c, scenario, frames, 60):
            pass
        L = c.lib
        L.retro_cdl_readers.restype = ctypes.c_void_p
        q.put((_plane_a(c), ctypes.string_at(L.retro_cdl_readers(), 4 * len(_plane_a(c)))))
    c.close()


def run_shifted(private, rom, scenario, frames, chunk, ref, ref_readers, mapping, q, harmless=()):
    """Stops at the first chunk with anomalies; returns them with readers."""
    sys.path.insert(0, private)
    from tools.c3emu import retro
    c = retro.Console(rom)
    c.cdl_enable(True)
    seen = bytearray(len(ref))
    prev = bytes(len(ref))
    for _ in _chunks(c, scenario, frames, chunk):
        a = _plane_a(c)
        rd = _readers(c)
        bad = []
        # only the 4 KB blocks where plane A changed since the last chunk
        offs = [off for blk in range(0, len(a), 4096) if a[blk:blk + 4096] != prev[blk:blk + 4096]
                for off in range(blk, min(blk + 4096, len(a)))]
        prev = a
        for off in offs:
            if a[off] & DATA and not seen[off]:
                seen[off] = 1
                orig = mapping.get(off, -1)
                if rd[off] and (rd[off] - 1) & 0xFFFFFF in harmless:
                    continue
                if orig == -1:
                    bad.append((off, None))
                elif not ref[orig] & DATA:
                    bad.append((off, orig))
                elif rd[off]:
                    # read first by another instruction than in the normal build
                    r = rd[off] - 1
                    ro = mapping.get(lorom_offset(r & 0x7FFFFF), -1)
                    want = int.from_bytes(ref_readers[4 * orig:4 * orig + 4], "little")
                    if want and (want - 1) & 0xFFFFFF in harmless:
                        continue
                    if want and ro != -1 and ro != lorom_offset((want - 1) & 0x7FFFFF):
                        bad.append((off, orig))
        if bad:
            rd = _readers(c)
            q.put((c.frame_count, [(off, orig, rd[off]) for off, orig in bad], bytes(c.ram(0, 0x2000))))
            c.close()
            return
    q.put((c.frame_count, [], b""))
    c.close()


def harmless_readers(smap, out):
    """Shifted-build addresses of instructions whose 16-bit read of a block's
    last byte also touches the byte after it, harmlessly: draw_text reads
    each character as a word and keeps the low byte."""
    pcs = set()
    for path, lines in smap.lines.items():
        if not path.endswith("engine/vram.asm"):
            continue
        text = open(path).read().split("\n")
        for i, line in enumerate(text):
            if line.startswith("@next_char:"):
                for k in range(i + 1, i + 4):
                    if "lda\ta:$0000,x" in text[k] and k + 1 in lines:
                        pcs.add(lines[k + 1][0][0])
    return pcs


def run_fillers(private, rom, scenario, frames, q):
    """Runs the whole scenario; returns the ROM offsets read as data, with
    their first readers (the caller keeps those of filler bytes)."""
    sys.path.insert(0, private)
    from tools.c3emu import retro
    c = retro.Console(rom)
    c.cdl_enable(True)
    for _ in _chunks(c, scenario, frames, 600):
        pass
    a = _plane_a(c)
    rd = _readers(c)
    q.put([(off, rd[off]) for off in range(len(a)) if a[off] & DATA])
    c.close()


def report_fillers(args, private, mapping):
    """--fillers: every byte of the shift test's filler read in the scenario,
    with the label after it: the block before that label is read past its
    end (or the label is inside a block); it needs a LAYOUT comment, or the
    reader a fix."""
    shifted = srcmap.SrcMap.load(os.path.join(args.out, "contra3.dbg"))
    labs = sorted((v, n) for n, v in shifted.labels.items() if v >> 16 < 0x40)
    lv = [v for v, _n in labs]
    ctx = mp.get_context("spawn")
    q = ctx.Queue()
    p = ctx.Process(target=run_fillers, args=(private, os.path.abspath(os.path.join(args.out, "contra3.sfc")),
                                             args.scenario, args.frames, q))
    p.start()
    reads = q.get()
    p.join()
    found = {}
    harmless = harmless_readers(shifted, args.out)
    for off, rd in reads:
        if mapping.get(off, -1) != -1 or (rd and (rd - 1) & 0xFFFFFF in harmless):
            continue
        addr = lorom_addr(off)
        i = bisect.bisect_right(lv, addr)
        after = labs[i][1] if i < len(labs) else "?"
        r = shifted.line_at((rd - 1) & 0xFFFFFF) if rd else None
        found.setdefault(after, (addr, "%s:%d" % (r[0], r[1]) if r else "DMA"))
    for name, (addr, reader) in sorted(found.items(), key=lambda kv: kv[1][0]):
        print("filler at $%06X (before %s) read by %s" % (addr, name, reader))
    print("%s: %d fillers read" % (args.scenario, len(found)))
    return 1 if found else 0


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


def find_literal(value, srcdir="src", limit=3):
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
    ap.add_argument("--frames", type=int, default=None,
                    help="frames to run (default: the play's length, or 18300)")
    ap.add_argument("--chunk", type=int, default=60)
    ap.add_argument("--max", type=int, default=40)
    ap.add_argument("-v", "--verbose", action="store_true", help="dump the object slots of both runs")
    ap.add_argument("--fillers", action="store_true",
                    help="run the whole scenario and list the filler bytes read (for --labels builds)")
    args = ap.parse_args(argv[1:])
    private = os.path.abspath(args.private)
    if args.frames is None:
        sys.path.insert(0, private)
        from tools.c3emu import plays
        args.frames = plays.PLAYS[args.scenario].frames if args.scenario in plays.PLAYS else 18300
    mapping, base = build_mapping(args.out)
    if args.fillers:
        return report_fillers(args, private, mapping)
    ctx = mp.get_context("spawn")
    q = ctx.Queue()
    p = ctx.Process(target=run_reference, args=(private, os.path.abspath(os.path.join(args.out, "base", "contra3.sfc")),
                                               args.scenario, args.frames, q))
    p.start()
    ref, ref_readers = q.get()
    p.join()
    p = ctx.Process(target=run_shifted, args=(private, os.path.abspath(os.path.join(args.out, "contra3.sfc")),
                                             args.scenario, args.frames, args.chunk, ref, ref_readers, mapping, q,
                                             harmless_readers(srcmap.SrcMap.load(os.path.join(args.out, "contra3.dbg")),
                                                              args.out) |
                                             harmless_readers(base, args.out)))
    p.start()
    frame, bad, wram_b = q.get()
    p.join()
    objects = []
    if bad:
        # the object slots of both runs at that frame: an animation script or
        # metasprite pointer that did not move with its bank is suspect
        p = ctx.Process(target=run_reference, args=(private, os.path.abspath(os.path.join(args.out, "base", "contra3.sfc")),
                                                   args.scenario, args.frames, q, frame))
        p.start()
        wram_a = q.get()
        p.join()
        w16 = lambda m, a: m[a] | m[a + 1] << 8
        for slot in range(0x0200, 0x0AC0, 0x40):
            ta, tb = w16(wram_a, slot + 0x10), w16(wram_b, slot + 0x10)
            if args.verbose and (ta or tb):
                objects.append("slot $%04X: type $%02X/$%02X sprite $%04X/$%04X anim $%04X/$%04X state $%04X/$%04X" % (
                    slot, ta, tb, w16(wram_a, slot), w16(wram_b, slot), w16(wram_a, slot + 0x20),
                    w16(wram_b, slot + 0x20), w16(wram_a, slot + 0x12), w16(wram_b, slot + 0x12)))
            if not ta or ta != tb:
                continue
            for field, name in ((0x00, "OBJ_SPRITE"), (0x20, "OBJ_ANIM")):
                va, vb = w16(wram_a, slot + field), w16(wram_b, slot + field)
                if va >= 0x8000 and va == vb:
                    objects.append("slot $%04X type $%02X: %s = $%04X in both builds" % (slot, ta, name, va))

    labs = sorted((v, n) for n, v in base.labels.items() if v >> 16 < 0x40)
    lv = [v for v, _n in labs]
    inv = {}

    def where(addr):
        i = bisect.bisect_right(lv, addr) - 1
        return "%s+$%X" % (labs[i][1], addr - labs[i][0]) if i >= 0 else "?"

    if not bad:
        print("%s: no anomalies in %d frames" % (args.scenario, frame))
        return 0
    for o in objects:
        print("  " + o)
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
        for h in (find_literal(low & 0xFFFF) if len(items) > 2 and low & 0xFFF0 not in (0x8000, 0xFFF0, 0xFFE0) else []):
            print("      $%04X in %s" % (low & 0xFFFF, h))
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv))
