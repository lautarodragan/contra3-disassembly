#!/usr/bin/env python3
"""Find data tables whose entries the code uses as ROM addresses.

    python3 tools/ptrscan.py [--cdl PATH.cdl.json] [--prefix data_] [-v]

For every instruction that loads a register from a data label (`lda
a:data_05A25A,y`, `ldx table`, ...), follows the loaded value forward
through the routine (a few dozen instructions, along the fall-through path
and unconditional branches) and reports how it is used:

  ptr   the value is used as an address: stored to a variable that is then
        read through `(var)`, `(var),y` or `[var]`; moved to X or Y that
        index an absolute operand below $0100 (`lda a:$0002,x`) while DB
        is a ROM bank (from the CDL sidecar); stored to OBJ_ANIM or
        OBJ_SPRITE; handed in Y to queue_vram_blocks, in X to
        load_data_list, or in A to a routine of tools/shift.py's
        POINTER_CONSUMERS;
  num   none of that happened before the value was overwritten.

Only a hint: "num" does not prove a table holds no pointers (the value
may be used after the window, or stored in RAM and used elsewhere), and
"ptr" names the table, not which of its words.  The tables flagged ptr
are listed (-v: all) only when still written as .byte with a word >= $8000
in their first four words (or with some .byte line before the next
label): the worklist.  The CDL readers and the book say what
they are.
"""
import argparse
import json
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import srcmap  # noqa: E402

LINE_RE = re.compile(r"^(?:(@?[A-Za-z_][A-Za-z0-9_]*):)?\s*(?:([a-z]{3})\b)?\s*([^;]*?)\s*(?:;.*)?$")
READ_RE = re.compile(r"^(?:a:|f:)?([A-Za-z_][A-Za-z0-9_]*)(?:\s*\+\s*\$?[0-9A-Fa-f]+)?(?:,([xy]))?$")
SMALL_ABS = re.compile(r"^a:\$00[0-9A-F]{2},([xy])$")
CONSUMERS_A = re.compile(r"^(make_effect_object|spawn_effect\w*|start_palette_task\w*|draw_text\w*"
                         r"|load_song_set|copy_hdma_table|build_wave_table|setup_hdma_from_list)$")
WINDOW = 40


def parse(path):
    out = []
    for n, line in enumerate(open(path), 1):
        m = LINE_RE.match(line.rstrip("\n"))
        if not m:
            continue
        label, op, arg = m.group(1), m.group(2), (m.group(3) or "").strip()
        if label:
            out.append((n, "label", label))
        if op and not line.lstrip().startswith("."):
            out.append((n, op, arg))
    return out


def load_db(path, smap):
    if not path or not os.path.exists(path):
        return None
    j = json.load(open(path))
    db = {}
    for off, d, _dp, _c in j.get("regs", []):
        db.setdefault(off, set()).add(d)
    return db


def lorom_offset(addr):
    return ((addr >> 16) & 0x7F) << 15 | (addr & 0x7FFF)


def follow(ins, i, reg, labels_at, db_at):
    """Uses of the value loaded into reg ('a', 'x', 'y') by ins[i]."""
    regs = {reg}
    stores = set()
    k = i + 1
    steps = 0
    while k < len(ins) and steps < WINDOW:
        n, op, arg = ins[k]
        steps += 1
        if op == "label":
            k += 1
            continue
        # indirect use of a stored copy
        for s in stores:
            if re.search(r"[(\[]%s[)\]]" % re.escape(s), arg):
                return "ptr", "(%s) at line %d" % (s, n)
        if op in ("sta", "stx", "sty") and op[2] in regs:
            dest = arg.split(",")[0]
            if re.match(r"^(OBJ_ANIM|OBJ_SPRITE)$", dest) and arg.endswith(",x"):
                return "ptr", "%s %s at line %d" % (op, arg, n)
            if "," not in arg:
                stores.add(re.sub(r"^a:", "", dest))
        elif op in ("tax", "tay", "txa", "tya", "txy", "tyx"):
            src, dst = op[1], op[2]
            if src in regs:
                regs.add(dst)
            else:
                regs.discard(dst)
        elif op in ("lda", "ldx", "ldy", "pla", "plx", "ply", "xba") and \
                (op[2] if op[0] != "x" else "a") in regs:
            regs.discard(op[2] if op[0] != "x" else "a")
        elif op in ("inc", "dec", "asl", "lsr", "rol", "ror") and arg in ("", "a"):
            pass
        elif op in ("adc", "sbc", "and", "ora", "eor"):
            pass
        m = SMALL_ABS.match(arg)
        if m and m.group(1) in regs and op not in ("sta", "stx", "sty", "stz"):
            dbs = db_at(n)
            if dbs and all(0x00 < d < 0x40 or 0x80 <= d < 0xC0 for d in dbs):
                return "ptr", "%s %s with DB=%s at line %d" % (op, arg, ",".join("%02X" % d for d in sorted(dbs)), n)
        if op in ("jsl", "jsr", "jml", "jmp"):
            target = arg.split(":")[-1]
            j = labels_at.get(target)
            if j is not None and stores:
                # a routine of the same file that reads a stored copy indirectly
                for n2, op2, arg2 in ins[j:j + 60]:
                    hit = [s for s in stores if re.search(r"[(\[]%s[)\]]" % re.escape(s), arg2)]
                    if hit:
                        return "ptr", "(%s) in %s at line %d" % (hit[0], target, n2)
                    if op2 in ("rts", "rtl"):
                        break
            if target == "queue_vram_blocks" and "y" in regs:
                return "ptr", "Y to queue_vram_blocks at line %d" % n
            if target == "load_data_list" and "x" in regs:
                return "ptr", "X to load_data_list at line %d" % n
            if CONSUMERS_A.match(target) and "a" in regs:
                return "ptr", "A to %s at line %d" % (target, n)
            if op in ("jml", "jmp"):
                break
            regs &= {"x", "y"} if target else regs
        if op in ("rts", "rtl", "rti"):
            break
        if op in ("bra", "brl"):
            j = labels_at.get(arg)
            if j is None:
                break
            k = j
            continue
        if not regs and not stores:
            break
        k += 1
    return "num", ""


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--cdl", default=os.path.join(os.environ.get("PRIVATE", "../contra3-disassembly-private"),
                                                  "cdl", "contra3.cdl.json"))
    ap.add_argument("--prefix", default="data_", help="labels to report (prefix)")
    ap.add_argument("-v", "--verbose", action="store_true", help="also list tables only read as numbers")
    args = ap.parse_args(argv[1:])
    smap = srcmap.SrcMap.build("src", "build/dbg")
    db = load_db(args.cdl, smap)
    results = {}
    for root, _d, files in os.walk("src"):
        for f in sorted(files):
            if not f.endswith(".asm"):
                continue
            path = os.path.join(root, f)
            ins = parse(path)
            labels_at = {arg: i for i, (n, op, arg) in enumerate(ins) if op == "label"}
            lines = smap.lines.get(path, {})

            def db_at(n, lines=lines):
                if db is None or n not in lines:
                    return None
                return db.get(lorom_offset(lines[n][0][0]))

            for i, (n, op, arg) in enumerate(ins):
                if op not in ("lda", "ldx", "ldy"):
                    continue
                m = READ_RE.match(arg)
                if not m or not m.group(1).startswith(args.prefix):
                    continue
                kind, why = follow(ins, i, op[2], labels_at, db_at)
                results.setdefault(m.group(1), []).append((kind, "%s:%d" % (path, n), why))
    rom = open("build/dbg/contra3.sfc", "rb").read()
    nptr = 0
    for name in sorted(results, key=lambda x: smap.symbols.get(x, 0)):
        uses = results[name]
        ptr = [u for u in uses if u[0] == "ptr"]
        addr = smap.labels.get(name)
        form = ""
        words = ""
        if addr is not None:
            r = smap.line_at(addr)
            if r:
                # the block: from the label's line to the next label
                lines = open(r[0]).read().split("\n")
                k = r[1] - 1
                block = []
                while k < len(lines) and (k == r[1] - 1 or not re.match(r"^[A-Za-z_]\w*:", lines[k])):
                    block.append(lines[k].strip())
                    k += 1
                form = ".byte" if any(b.startswith(".byte") for b in block) else \
                    (block[0].split()[0] if block and block[0] else "")
            o = lorom_offset(addr)
            words = " ".join("%04X" % (rom[o + 2 * k] | rom[o + 2 * k + 1] << 8) for k in range(4))
        if ptr and form == ".byte":
            nptr += 1
        elif not args.verbose:
            continue
        u = (ptr or uses)[0]
        print("%-4s %-14s %-8s %s  %s  %s" % ("ptr" if ptr else "num", name, form, words, u[1], u[2]))
    print("%d labels read; %d still .byte, used as pointers, holding words >= $8000" % (len(results), nptr), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
