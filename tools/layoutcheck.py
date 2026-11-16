#!/usr/bin/env python3
"""Find data blocks that the code reaches by reading past the end of an
earlier label (tables indexed beyond their label's block).

    python3 tools/layoutcheck.py [--cdl PATH.cdl] [--mark]

For every data label B, takes the instructions that first read B's bytes
(the CDL readers) and the label named in each one's operand (`lda
a:sine_table,y`).  If that label A is an earlier label of the same bank
(and not B itself), the code reads A's table on into B: B must stay right
after A.  tools/shift.py --labels inserts a byte before data labels, which
would break that, unless B is followed by a comment with "LAYOUT:".

--mark adds such a comment after each label found that has none
("; LAYOUT: read on from A (by INSTRUCTION)"), so that `--labels` leaves it
alone.  Only absolute operands are seen: a table read through a pointer
past its end is not found here (the shift test finds it).
"""
import argparse
import bisect
import os
import re
import struct
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import srcmap  # noqa: E402

OPERAND = re.compile(r"^\s*[a-z]{3}\s+(?:a:|f:)?([A-Za-z_]\w*)(?:\s*[-+][^,;]*)?(?:,[xy])?\s*(?:;.*)?$")


def load_readers(path):
    d = open(path, "rb").read()
    h = struct.unpack_from("<H", d, 10)[0]
    n = struct.unpack_from("<I", d, 12)[0]
    w = struct.unpack_from("<I", d, 0x24)[0]
    plane_a = d[h:h + n]
    readers = d[h + 2 * n + w:h + 2 * n + w + 4 * n]
    return plane_a, readers


def lorom_offset(addr):
    return ((addr >> 16) & 0x7F) << 15 | (addr & 0x7FFF)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--cdl", default=os.path.join(os.environ.get("PRIVATE", "../contra3-disassembly-private"),
                                                  "cdl", "contra3.cdl"))
    ap.add_argument("--mark", action="store_true")
    args = ap.parse_args(argv[1:])
    m = srcmap.SrcMap.build("src", "build/dbg")
    plane_a, readers = load_readers(args.cdl)
    labels = sorted((v, n) for n, v in m.labels.items() if v < 0x400000 and (v & 0xFFFF) >= 0x8000)
    starts = [v for v, _n in labels]
    texts = {}

    def line_text(addr):
        r = m.line_at(addr)
        if not r:
            return None, None, None
        if r[0] not in texts:
            texts[r[0]] = open(r[0]).read().split("\n")
        return r[0], r[1], texts[r[0]][r[1] - 1]

    found = []
    for i, (b, name) in enumerate(labels):
        path, ln, text = line_text(b)
        if path is None or "/gfx/" in path or "/sound/" in path:
            continue
        end = labels[i + 1][0] if i + 1 < len(labels) else b + 1
        end = min(end, b + 0x100)
        seen = set()
        for a in range(b, end):
            o = lorom_offset(a)
            if not plane_a[o] & 0x0C:
                continue
            r = struct.unpack_from("<I", readers, 4 * o)[0]
            if not r or r in seen:
                continue
            seen.add(r)
            _p, _l, op = line_text((r - 1) & 0xFFFFFF)
            mm = OPERAND.match(op or "")
            if not mm or mm.group(1) == name or mm.group(1) not in m.labels:
                continue
            x = m.labels[mm.group(1)]
            if x < b and x >> 16 == b >> 16 and b - x < 0x1000:
                found.append((name, mm.group(1), op.strip().split(";")[0].strip(), path, ln))
                break
    for name, prev, op, path, ln in found:
        lines = texts[path]
        j = next(j for j in range(len(lines)) if lines[j].startswith(name + ":"))
        k = j + 1
        has = False
        while k < len(lines) and (not lines[k].strip() or lines[k].strip().startswith(";")):
            has = has or "LAYOUT:" in lines[k]
            k += 1
        print("%-28s read on from %-28s by `%s`%s" % (name, prev, op, "" if not has else " (marked)"))
        if args.mark and not has:
            lines.insert(j + 1, "\t; LAYOUT: read on from %s (%s)" % (prev, op.replace("\t", " ")))
    if args.mark:
        for path, lines in texts.items():
            open(path, "w").write("\n".join(lines))
    print("%d blocks read on from an earlier label" % len(found), file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
