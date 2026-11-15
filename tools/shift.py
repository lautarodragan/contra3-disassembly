#!/usr/bin/env python3
"""Shift test: build a ROM whose code and data sit at other addresses.

Milestone 3 ("shiftable source") means every reference between code and data
goes through a label, so that inserting or removing bytes anywhere keeps the
game working.  This tool builds a perturbed copy of the source to check that:

    python3 tools/shift.py build [--out build/shift] [--amounts SPEC]
                                 [--labels P] [--seed S] [--banks LIST]

copies src/ to OUT/src, inserts filler bytes there and assembles
OUT/contra3.sfc (plus .dbg/.map/.lbl).  The filler is $EA (NOP), harmless if
it ever runs.  Insertion points:

  * bank start: SPEC bytes right after each `.segment "BANKxx"` of main.asm,
    which moves everything in the bank.  The default gives each bank a
    different amount (1-14, see DEFAULT_AMOUNTS) so that a label placed in
    the wrong bank (only its low 16 bits used, e.g. `lda #label`) is caught
    too.  SPEC: "default", "alt" (another assignment), a number for every
    bank, or "BB=N,BB=N" (others 0).  --banks limits shifting to some banks.
  * --labels P: also one byte before a fraction P of the data labels (a
    label whose next statement is data), chosen with --seed, within each
    bank's free space.  This moves data blocks relative to each other: it
    catches tables indexed past their label into the next block.

The space comes from the free space at the end of each bank, which the
linker fills ($FF), so the shifted build fits as long as the amounts do.
The header checksum of the shifted ROM is recomputed.

Then run the emulator suite on it (`make shift-test`), or compare it with
the normal build (`python3 tools/shift.py diff`): the bytes that differ
(apart from the moved ones) are the relocated references, one line of
source each.

    python3 tools/shift.py scan [--cdl PATH]

lists references that are still hardcoded numbers in the source (see
SCAN_DOC below); exit status 1 if there are any that are known pointer
forms.
"""
import argparse
import os
import random
import re
import shutil
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import srcmap  # noqa: E402

FILLER = 0xEA

# Bytes inserted at the start of each bank by default: different values for
# the banks whose labels are most easily confused (code banks $00-$04 and
# $1D, data banks $05-$07), all within each bank's free space (bank $00 has
# the least: 14 bytes before the header).
DEFAULT_AMOUNTS = {
    0x00: 3, 0x01: 7, 0x02: 11, 0x03: 5, 0x04: 9, 0x05: 13, 0x06: 6, 0x07: 10,
    0x1D: 12,
}
ALT_AMOUNTS = {
    0x00: 14, 0x01: 2, 0x02: 6, 0x03: 13, 0x04: 1, 0x05: 4, 0x06: 9, 0x07: 3,
    0x1D: 8,
}


def default_amount(table, bank):
    if bank in table:
        return table[bank]
    return 1 + (bank * 5) % 13      # graphics and sound banks: 1-13


def bank_free(m):
    """Free bytes at the end of each bank in a SrcMap's build."""
    used = {}
    for a, size, _p, _l in m.entries():
        b = a >> 16
        if b == 0 and (a & 0xFFFF) >= 0xFFC0:
            continue                # the header, a segment of its own
        used[b] = max(used.get(b, 0x8000), (a & 0xFFFF) + size)
    free = {}
    for b in range(32):
        end = 0xFFC0 if b == 0 else 0x10000
        free[b] = end - used.get(b, 0x8000)
    return free


def parse_amounts(spec, banks):
    if spec in ("default", "alt"):
        table = DEFAULT_AMOUNTS if spec == "default" else ALT_AMOUNTS
        amounts = {b: default_amount(table, b) for b in range(32)}
    elif re.fullmatch(r"\d+", spec):
        amounts = {b: int(spec) for b in range(32)}
    else:
        amounts = {b: 0 for b in range(32)}
        for item in spec.split(","):
            b, n = item.split("=")
            amounts[int(b, 16)] = int(n)
    if banks:
        keep = {int(b, 16) for b in banks.split(",")}
        amounts = {b: (n if b in keep else 0) for b, n in amounts.items()}
    return amounts


LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):")
DATA_RE = re.compile(r"^\s*\.(byte|word|addr|faraddr|dbyt|res)\b")


def bank_files(main_asm):
    """{bank: [file, ...]} from the .segment/.include lines of main.asm."""
    out, bank = {}, None
    for line in open(main_asm):
        m = re.match(r'\.segment\s+"BANK([0-9A-F]{2})"', line)
        if m:
            bank = int(m.group(1), 16)
            continue
        if re.match(r'\.segment', line):
            bank = None
            continue
        m = re.match(r'\.include\s+"([^"]+\.asm)"', line)
        if m and bank is not None:
            out.setdefault(bank, []).append(m.group(1))
    return out


def data_labels(path):
    """Line indexes of labels whose next statement is data."""
    lines = open(path).read().split("\n")
    found = []
    for i, line in enumerate(lines):
        if not LABEL_RE.match(line):
            continue
        j = i + 1
        while j < len(lines) and (not lines[j].strip() or lines[j].strip().startswith(";")):
            j += 1
        if j < len(lines) and DATA_RE.match(lines[j]):
            found.append(i)
    return found


def fix_checksum(rom_path):
    rom = bytearray(open(rom_path, "rb").read())
    rom[0x7FDC:0x7FE0] = b"\xFF\xFF\x00\x00"
    s = sum(rom) & 0xFFFF
    rom[0x7FDC:0x7FDE] = (s ^ 0xFFFF).to_bytes(2, "little")
    rom[0x7FDE:0x7FE0] = s.to_bytes(2, "little")
    open(rom_path, "wb").write(rom)


def cmd_build(args):
    base = srcmap.SrcMap.build("src", os.path.join(args.out, "base"))
    free = bank_free(base)
    amounts = parse_amounts(args.amounts, args.banks)
    for b, n in amounts.items():
        if n > free[b]:
            sys.exit("bank $%02X: %d bytes to insert but only %d free" % (b, n, free[b]))
    dst = os.path.join(args.out, "src")
    shutil.rmtree(dst, ignore_errors=True)
    shutil.copytree("src", dst)

    # bank starts
    main = os.path.join(dst, "main.asm")
    out = []
    for line in open(main):
        out.append(line)
        m = re.match(r'\.segment\s+"BANK([0-9A-F]{2})"', line)
        if m and amounts[int(m.group(1), 16)]:
            out.append("\t.res\t%d, $%02X\t; shift test\n" % (amounts[int(m.group(1), 16)], FILLER))
    open(main, "w").write("".join(out))

    # data labels
    moved = 0
    if args.labels:
        rng = random.Random(args.seed)
        for bank, files in sorted(bank_files(main).items()):
            budget = free[bank] - amounts[bank]
            if args.banks and amounts[bank] == 0:
                continue
            cands = [(f, i) for f in files for i in data_labels(os.path.join(dst, f))]
            rng.shuffle(cands)
            chosen = {}
            for f, i in cands:
                if budget <= 0:
                    break
                if rng.random() < args.labels:
                    chosen.setdefault(f, set()).add(i)
                    budget -= 1
            for f, idx in chosen.items():
                p = os.path.join(dst, f)
                lines = open(p).read().split("\n")
                for i in sorted(idx, reverse=True):
                    lines.insert(i, "\t.res\t1, $%02X\t; shift test" % FILLER)
                    moved += 1
                open(p, "w").write("\n".join(lines))
    rom, _dbg = srcmap.assemble(dst, args.out)
    fix_checksum(rom)
    print("%s: banks shifted by %s; %d data labels moved by one byte"
          % (rom, " ".join("%02X:%d" % (b, n) for b, n in sorted(amounts.items()) if n), moved))
    return 0


def cmd_diff(args):
    """Bytes that differ between the normal and the shifted build, per line."""
    a = srcmap.SrcMap.load(os.path.join(args.out, "base", "contra3.dbg"))
    b = srcmap.SrcMap.load(os.path.join(args.out, "contra3.dbg"))
    rom_a = open(os.path.join(args.out, "base", "contra3.sfc"), "rb").read()
    rom_b = open(os.path.join(args.out, "contra3.sfc"), "rb").read()

    def off(addr):
        return ((addr >> 16) & 0x7F) << 15 | (addr & 0x7FFF)

    nlines = nbytes = 0
    for path, lines in sorted(a.lines.items()):
        pb = os.path.join(args.out, path)
        bl = b.lines.get(pb, {})
        for ln, spans in sorted(lines.items()):
            sb = bl.get(ln)
            if not sb:
                continue
            da = b"".join(rom_a[off(x):off(x) + n] for x, n in spans)
            db = b"".join(rom_b[off(x):off(x) + n] for x, n in sb)
            if da != db:
                nlines += 1
                nbytes += sum(1 for x, y in zip(da, db) if x != y)
                if args.verbose:
                    print("%s:%d  %s -> %s" % (path, ln, da.hex(), db.hex()))
    print("%d lines with relocated bytes (%d bytes)" % (nlines, nbytes))
    return 0


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("build")
    p.add_argument("--out", default="build/shift")
    p.add_argument("--amounts", default="default")
    p.add_argument("--banks", default="")
    p.add_argument("--labels", type=float, default=0.0)
    p.add_argument("--seed", type=int, default=1)
    p = sub.add_parser("diff")
    p.add_argument("--out", default="build/shift")
    p.add_argument("-v", "--verbose", action="store_true")
    args = ap.parse_args(argv[1:])
    return {"build": cmd_build, "diff": cmd_diff}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
