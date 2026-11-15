#!/usr/bin/env python3
"""Rewrite `.byte` data in src/ by address: add labels, turn bytes into pointers.

    python3 tools/datafmt.py label 05:C59A anim_05C59A [ADDR NAME ...]

adds a label in front of the byte at $05:C59A (splitting its `.byte` line),
unless that address already has one (then it prints the existing name).

Library use (the milestone-3 conversion scripts):

    ed = Editor()                         # assembles src/ with debug info
    name = ed.label(0x05C59A, "anim_05C59A")   # existing label or new one
    ed.pointer(0x05A000, 2, "anim_05C59A")     # bytes -> .addr anim_05C59A
    ed.pointer(0x05A010, 3, "gfx_0A8000")      # bytes -> .faraddr gfx_0A8000
    ed.pointer(0x05A020, 1, "^gfx_0A8000")     # byte  -> .byte ^gfx_0A8000
    ed.row(0x05B000, ".word", 3)               # 3 words on one line
    ed.operand(0x00C123, "#$C59A", "#anim_05C59A")   # instruction operand text
    ed.write()                            # rewrites the files; then `make`

Bytes stay where they were; only how they are written changes, so the ROM
must still match (`make`).  A label or pointer must not cut an item in two,
and a pointer must lie inside one run of `.byte` lines (no instruction or
other directive in between).
"""
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import srcmap  # noqa: E402

BYTE_RE = re.compile(r"^(\s*)\.byte\s+((?:\$[0-9A-Fa-f]{2}\s*,\s*)*\$[0-9A-Fa-f]{2})\s*(;.*)?$")
LABEL_RE = re.compile(r"^([A-Za-z_][A-Za-z0-9_]*):\s*(;.*)?$")
ITEM_SIZE = {".byte": 1, ".word": 2, ".addr": 2, ".faraddr": 3, ".dbyt": 2}
PLACEHOLDER_RE = re.compile(r"^(sub|loc|tbl|ptrs|data)_[0-9A-F]{6}$")


class EditError(Exception):
    pass


class Editor:
    def __init__(self, srcdir="src", outdir="build/dbg", smap=None):
        self.srcdir = srcdir
        self.m = smap or srcmap.SrcMap.build(srcdir, outdir)
        self.by_addr = {}
        for name, v in self.m.labels.items():
            self.by_addr.setdefault(v, []).append(name)
        self.labels = {}     # addr -> [new names]
        self.ptrs = {}       # addr -> (size, expr)
        self.rows = {}       # addr -> (directive, count)
        self.operands = {}   # (path, lineno) -> [(old, new)]
        self.files = set()

    # -- queries -----------------------------------------------------------
    def names_at(self, addr):
        return self.by_addr.get(addr, []) + self.labels.get(addr, [])

    def name_at(self, addr):
        """Best existing name at addr (a real name before a placeholder)."""
        names = self.names_at(addr)
        if not names:
            return None
        names = sorted(names, key=lambda n: (bool(PLACEHOLDER_RE.match(n)), n.startswith("loc_"), n))
        return names[0]

    def where(self, addr):
        r = self.m.line_at(addr)
        if not r:
            raise EditError("$%06X: no source line emits this address" % addr)
        return r

    # -- edits -------------------------------------------------------------
    def label(self, addr, name):
        """Name the byte at addr; returns the name to use (an existing one wins)."""
        old = self.name_at(addr)
        if old:
            return old
        path, _ln, la, _size = self.where(addr)
        if la != addr and not self._is_byte_line(path, _ln):
            raise EditError("$%06X: inside an instruction (%s:%d)" % (addr, path, _ln))
        self.labels.setdefault(addr, []).append(name)
        self.by_addr.setdefault(addr, [])
        self.files.add(path)
        return name

    def pointer(self, addr, size, expr):
        for a in range(addr, addr + size):
            path, ln, _la, _s = self.where(a)
            if not self._is_byte_line(path, ln):
                raise EditError("$%06X: not in a .byte line (%s:%d)" % (a, path, ln))
        for a in range(addr + 1, addr + size):
            if a in self.ptrs or self.names_at(a):
                raise EditError("$%06X: pointer at $%06X overlaps a label/pointer" % (a, addr))
        old = self.ptrs.get(addr)
        if old and old != (size, expr):
            raise EditError("$%06X: already a pointer %s" % (addr, old))
        self.ptrs[addr] = (size, expr)
        self.files.add(self.where(addr)[0])

    def row(self, addr, directive, count, itemsize=None, bare=False):
        """count items of itemsize bytes (default: the directive's) on one line.
        directive may be a macro taking that many operands."""
        if itemsize is None:
            itemsize = ITEM_SIZE[directive]
        if isinstance(itemsize, (list, tuple)):
            count = len(itemsize)
        self.rows[addr] = (directive, count, itemsize, bare)
        self.bare = getattr(self, "bare", set())
        if bare:            # a macro without operands (the ROM check verifies the bytes)
            self.bare.add(addr)
        self.files.add(self.where(addr)[0])

    def operand(self, addr, old, new):
        path, ln, la, _s = self.where(addr)
        self.operands.setdefault((path, ln), []).append((old, new))
        self.files.add(path)

    def _is_byte_line(self, path, ln):
        lines = self._lines(path)
        return bool(BYTE_RE.match(lines[ln - 1]))

    _cache = {}

    def _lines(self, path):
        if path not in self._cache:
            self._cache[path] = open(path).read().split("\n")
        return self._cache[path]

    # -- output ------------------------------------------------------------
    def write(self):
        for path in sorted(self.files):
            self._write_file(path)
        self._cache.clear()

    def _write_file(self, path):
        lines = self._lines(path)
        addrs = self.m.lines.get(path, {})
        out = []
        i = 0
        n = len(lines)
        while i < n:
            line = lines[i]
            ln = i + 1
            if (path, ln) in self.operands:
                for old, new in self.operands[(path, ln)]:
                    code, sep, comment = line.partition(";")
                    if old not in code:
                        raise EditError("%s:%d: %r not in %r" % (path, ln, old, line))
                    line = code.replace(old, new, 1) + sep + comment
            m = BYTE_RE.match(line)
            if not m or ln not in addrs:
                if ln in addrs:     # a label in front of another statement
                    for name in self.labels.get(addrs[ln][0][0], []):
                        out.append("%s:" % name)
                out.append(line)
                i += 1
                continue
            # a run of .byte lines, with labels / comments / blank lines inside
            run = []          # (kind, payload): ("b", (addr, [vals], indent, comment)) | ("t", text)
            j = i
            while j < n:
                lj = lines[j]
                mj = BYTE_RE.match(lj)
                if mj and (j + 1) in addrs:
                    a = addrs[j + 1][0][0]
                    vals = [int(x.strip()[1:], 16) for x in mj.group(2).split(",")]
                    run.append(("b", (a, vals, mj.group(1), mj.group(3))))
                    j += 1
                elif (not lj.strip() or lj.strip().startswith(";") or LABEL_RE.match(lj)) \
                        and (path, j + 1) not in self.operands:
                    run.append(("t", lj))
                    j += 1
                else:
                    break
            # trailing text lines belong after the run
            tail = []
            while run and run[-1][0] == "t":
                tail.insert(0, run.pop()[1])
            out.extend(self._emit_run(path, run))
            out.extend(tail)
            i = j
        open(path, "w").write("\n".join(out))

    def _emit_run(self, path, run):
        # flatten
        vals = {}
        starts = set()
        anchors = {}     # addr -> [text lines] before the byte at addr
        pending = []
        indent = "\t"
        comments = {}
        order = []
        for kind, p in run:
            if kind == "t":
                pending.append(p)
                continue
            a, vs, ind, com = p
            indent = ind or "\t"
            if pending:
                anchors.setdefault(a, []).extend(pending)
                pending = []
            starts.add(a)
            if com:
                comments[a] = com
            for k, v in enumerate(vs):
                if a + k in vals:
                    raise EditError("%s: $%06X emitted twice" % (path, a + k))
                vals[a + k] = v
                order.append(a + k)
        out = []
        cur = None   # [directive, [items], remaining_in_row or None, comment]

        def flush():
            nonlocal cur
            if cur:
                d, items, _rem, com = cur[:4]
                if cur[5]:
                    out.append("%s%s%s" % (indent, d, ("\t" + com) if com else ""))
                else:
                    out.append("%s%s\t%s%s" % (indent, d, ", ".join(items), ("\t" + com) if com else ""))
            cur = None

        k = 0
        while k < len(order):
            a = order[k]
            if a in anchors or a in self.labels:
                keep = cur if cur is not None and cur[2] is not None else None
                flush()
                out.extend(anchors.get(a, []))
                for name in self.labels.get(a, []):
                    out.append("%s:" % name)
                if keep:            # a label between the items of a row
                    cur = [keep[0], [], keep[2], None, keep[4], keep[5]]
            if a in self.rows:
                flush()
                d, cnt, isz, bare = self.rows[a]
                cur = [d, [], cnt, comments.get(a), isz, bare]
            elif a in starts and (cur is None or cur[2] is None):
                flush()
            if a in self.ptrs:
                size, expr = self.ptrs[a]
            else:
                size, expr = None, None
            if cur is not None and cur[2] is not None:
                d, isz = cur[0], cur[4]
                if isinstance(isz, (list, tuple)):      # sizes per operand
                    isz = isz[len(cur[4]) - cur[2]]
                    if isz < 0:         # bytes the macro emits itself
                        if size is not None:
                            raise EditError("%s: $%06X pointer in a hidden operand" % (path, a))
                        cur[2] -= 1
                        k += -isz
                        if cur[2] == 0:
                            flush()
                        continue
                if size is not None and size != isz:
                    raise EditError("%s: $%06X pointer of %d bytes in a %s row" % (path, a, size, d))
                item = expr
                if item is None:
                    bs = []
                    for q in range(isz):
                        if order[k + q] != a + q or (q and (a + q) in self.labels):
                            raise EditError("%s: $%06X row item cut" % (path, a))
                        bs.append(vals[a + q])
                    item = "$" + "".join("%02X" % b for b in reversed(bs))
                cur[1].append(item)
                cur[2] -= 1
                k += isz
                if cur[2] == 0:
                    flush()
                continue
            if size is not None:
                flush()
                for q in range(size):
                    if k + q >= len(order) or order[k + q] != a + q:
                        raise EditError("%s: $%06X pointer runs past the data" % (path, a))
                d = {1: ".byte", 2: ".addr", 3: ".faraddr"}[size]
                out.append("%s%s\t%s" % (indent, d, expr))
                k += size
                continue
            if cur is None:
                cur = [".byte", [], None, comments.get(a), 1, False]
            cur[1].append("$%02X" % vals[a])
            k += 1
        flush()
        if pending:
            out.extend(pending)
        return out


def main(argv):
    if len(argv) < 4 or argv[1] != "label" or len(argv) % 2:
        print(__doc__)
        return 1
    ed = Editor()
    for i in range(2, len(argv), 2):
        a = srcmap.parse_addr(argv[i])
        got = ed.label(a, argv[i + 1])
        print("$%06X: %s" % (a, got))
    ed.write()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
