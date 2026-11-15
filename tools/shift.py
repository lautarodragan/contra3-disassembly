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
    label whose next statement is data, after a .byte line), chosen with
    --seed, within each bank's free space.  This moves data blocks relative to each other: it
    catches tables indexed past their label into the next block.

The space comes from the free space at the end of each bank, which the
linker fills ($FF), so the shifted build fits as long as the amounts do.
The header checksum of the shifted ROM is recomputed.

Then run the emulator suite on it (`make shift-test`), or compare it with
the normal build (`python3 tools/shift.py diff`): the bytes that differ
(apart from the moved ones) are the relocated references, one line of
source each.

    python3 tools/shift.py scan [--cdl PATH]

lists references that are still hardcoded numbers in the source, in the
forms SCAN_DOC (below) names; exit status 1 if there are any.
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
            # The filler byte is appended to the .byte line before the label,
            # so that line numbers stay those of src/ (tools/shift_diag.py and
            # `diff` match lines by number); labels after anything else are
            # left alone.
            texts = {f: open(os.path.join(dst, f)).read().split("\n") for f in files}
            for f, i in cands:
                if budget <= 0:
                    break
                if rng.random() >= args.labels:
                    continue
                lines = texts[f]
                j = i - 1
                while j >= 0 and (not lines[j].strip() or lines[j].strip().startswith(";")):
                    j -= 1
                m = re.match(r"^(\s*\.byte\s+[^;]*?)(\s*;.*)?$", lines[j]) if j >= 0 else None
                if not m:
                    continue
                lines[j] = m.group(1) + ", $%02X" % FILLER + (m.group(2) or "")
                budget -= 1
                moved += 1
            for f in files:
                open(os.path.join(dst, f), "w").write("\n".join(texts[f]))
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


# -- scan: hardcoded references left in the source ---------------------------
SCAN_DOC = """Forms that must not come back (exit status 1): a 16-bit immediate >= $8000
loaded and then handed to a routine or field that takes a ROM pointer
(OBJ_ANIM, OBJ_SPRITE, make_effect_object, start_palette_task, draw_text,
load_data_list, ...); a literal bank $05-$1C pushed and pulled into DB; a
long operand into a ROM bank.  Also counted, for information: the other
16-bit immediates >= $8000 that are loaded (mostly negative numbers, some
pointers not found yet)."""

POINTER_CONSUMERS = re.compile(
    r"^(sta|stx|sty)\t(OBJ_ANIM,[xy]|OBJ_SPRITE,[xy]|a:\$0020,y|a:\$0000,y|cgram_upload_src)$"
    r"|^j[sm][lr]\t[fa]:(make_effect_object|spawn_effect\w*|start_palette_task\w*|draw_text\w*"
    r"|load_data_list|load_song_set|copy_hdma_table)$")


def scan_source(srcdir="src"):
    errors, info = [], 0
    for root, _dirs, files in os.walk(srcdir):
        for f in sorted(files):
            if not f.endswith(".asm"):
                continue
            path = os.path.join(root, f)
            lines = open(path).read().split("\n")
            for i, line in enumerate(lines):
                code = line.split(";")[0].rstrip()
                m = re.match(r"^\t(lda|ldx|ldy)\t#\$([0-9A-F]{4})$", code)
                if m and int(m.group(2), 16) >= 0x8000:
                    hit = False
                    reg = m.group(1)[2]
                    for nxt in lines[i + 1:i + 6]:
                        n = nxt.split(";")[0].strip()
                        if not n:
                            continue
                        if n.endswith(":"):
                            break
                        op = n.split()[0]
                        if op in ("txy", "tyx", "phx", "phy", "plx", "ply", "phb", "plb", "clc", "sec", "pha", "pla") \
                                and reg not in op[1:]:
                            continue
                        hit = bool(POINTER_CONSUMERS.match(n.replace(" ", "\t", 1))) and \
                            (op.startswith("j") or op[2] == reg)
                        break
                    if hit:
                        errors.append("%s:%d: pointer immediate: %s" % (path, i + 1, code.strip()))
                    else:
                        info += 1
                    continue
                m = re.match(r"^\t(lda|ldx|ldy)\t#\$(0[5-9A-F]|1[0-9A-C])$", code)
                if m:
                    nxt = [x.split(";")[0].strip() for x in lines[i + 1:i + 4]]
                    if nxt and nxt[0] in ("pha", "phx", "phy") and "plb" in nxt:
                        errors.append("%s:%d: literal data bank: %s" % (path, i + 1, code.strip()))
                    continue
                m = re.search(r"\bf:\$([0-9A-F]{2})([0-9A-F]{4})\b", code)
                if m:
                    bank, addr = int(m.group(1), 16), int(m.group(2), 16)
                    if 0x01 <= bank <= 0x3F or (bank == 0 and addr >= 0x8000):
                        errors.append("%s:%d: long operand into ROM: %s" % (path, i + 1, code.strip()))
    return errors, info


def cmd_scan(args):
    errors, info = scan_source()
    for e in errors:
        print(e)
    print("%d hardcoded ROM references of the checked forms; %d other 16-bit "
          "immediates >= $8000 loaded (not checked)" % (len(errors), info))
    return 1 if errors else 0


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
    sub.add_parser("scan", help=SCAN_DOC.split("\n")[0])
    args = ap.parse_args(argv[1:])
    return {"build": cmd_build, "diff": cmd_diff, "scan": cmd_scan}[args.cmd](args)


if __name__ == "__main__":
    sys.exit(main(sys.argv))
