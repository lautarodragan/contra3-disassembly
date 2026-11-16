#!/usr/bin/env python3
"""Map ROM addresses to source lines (and back) through ld65's debug file.

    python3 tools/srcmap.py addr 05:C59A          # which file/line emits $05:C59A
    python3 tools/srcmap.py line src/data/tables_05.asm 120

Library use (tools/shift.py, tools/label_at.py):

    m = SrcMap.build(srcdir="src", outdir="build/dbg")   # assemble with -g
    m = SrcMap.load("build/dbg/contra3.dbg")
    m.line_at(0x05C59A)   -> (path, lineno, line_start_address, size)
    m.lines[path][lineno] -> [(address, size), ...]
    m.symbols             -> {name: value}
    m.cheap_labels        -> [(name, address)] of the cheap locals (@name)

Only lines that emit bytes have addresses. Addresses are 24-bit CPU
addresses ($BB:AAAA, LoROM: bank BB at $8000-$FFFF).
"""
import bisect
import os
import re
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import assets  # noqa: E402

CA65 = os.environ.get("CA65", "ca65")
LD65 = os.environ.get("LD65", "ld65")


def assemble(srcdir, outdir, defines=(), cfg=None, rom_name="contra3.sfc"):
    """Assemble srcdir/main.asm with debug info; returns (rom, dbg) paths."""
    os.makedirs(outdir, exist_ok=True)
    obj = os.path.join(outdir, "main.o")
    rom = os.path.join(outdir, rom_name)
    dbg = os.path.join(outdir, "contra3.dbg")
    cmd = [CA65, "--cpu", "65816", "-g", "-I", srcdir, *assets.ca65_args(), "-o", obj]
    for d in defines:
        cmd += ["-D", d]
    cmd.append(os.path.join(srcdir, "main.asm"))
    subprocess.run(cmd, check=True)
    link = subprocess.run([LD65, "-C", cfg or os.path.join(srcdir, "contra3.cfg"),
                           "--dbgfile", dbg, "-m", os.path.join(outdir, "contra3.map"),
                           "-Ln", os.path.join(outdir, "contra3.lbl"),
                           "-o", rom, obj], stderr=subprocess.PIPE, text=True)
    sys.stderr.write(link.stderr)
    if link.returncode:
        # a bank that overflows: name its assets (book: Assets, Size limits)
        sys.stderr.write(assets.asset_limits.ld65_diagnosis(
            link.stderr, srcdir, [os.path.join(assets.ROOT, d) for d in assets.INCLUDE_DIRS]) + "\n")
        sys.exit(f"{LD65} failed ({srcdir})")
    return rom, dbg


def _kv(rest):
    out = {}
    for item in re.findall(r'(\w+)=("[^"]*"|[^,]*)', rest):
        out[item[0]] = item[1].strip('"')
    return out


class SrcMap:
    def __init__(self):
        self.files = {}      # file id -> path
        self.lines = {}      # path -> {lineno: [(addr, size), ...]}
        self.symbols = {}    # name -> value (labels and constants)
        self.labels = {}     # name -> address (labels only; one of the cheap locals of each @name)
        self.cheap_labels = []   # (name, address) of every cheap local label (@name)
        self._starts = []    # sorted line start addresses
        self._entries = []   # parallel: (addr, size, path, lineno)

    @classmethod
    def build(cls, srcdir="src", outdir="build/dbg", defines=()):
        _, dbg = assemble(srcdir, outdir, defines)
        return cls.load(dbg)

    @classmethod
    def load(cls, dbgpath):
        m = cls()
        segs, spans, rawlines = {}, {}, []
        with open(dbgpath) as f:
            for raw in f:
                kind, _, rest = raw.rstrip("\n").partition("\t")
                if kind not in ("file", "seg", "span", "line", "sym"):
                    continue
                kv = _kv(rest)
                if kind == "file":
                    m.files[int(kv["id"])] = kv["name"]
                elif kind == "seg":
                    segs[int(kv["id"])] = int(kv["start"], 16)
                elif kind == "span":
                    spans[int(kv["id"])] = (int(kv["seg"]), int(kv["start"]), int(kv["size"]))
                elif kind == "line":
                    if "span" in kv and "type" not in kv:
                        rawlines.append((int(kv["file"]), int(kv["line"]), kv["span"]))
                elif kind == "sym":
                    if "val" in kv:
                        v = int(kv["val"], 16)
                        m.symbols[kv["name"]] = v
                        if kv.get("type") == "lab":
                            m.labels[kv["name"]] = v
                            if kv["name"].startswith("@"):
                                m.cheap_labels.append((kv["name"], v))
        entries = []
        for fid, lineno, spanlist in rawlines:
            path = m.files[fid]
            for sid in spanlist.split("+"):
                seg, start, size = spans[int(sid)]
                addr = segs[seg] + start
                m.lines.setdefault(path, {}).setdefault(lineno, []).append((addr, size))
                entries.append((addr, size, path, lineno))
        entries.sort()
        m._entries = entries
        m._starts = [e[0] for e in entries]
        return m

    def line_at(self, addr):
        """(path, lineno, line_address, size) of the line emitting addr, or None."""
        i = bisect.bisect_right(self._starts, addr) - 1
        while i >= 0:
            a, size, path, lineno = self._entries[i]
            if a <= addr < a + size:
                return path, lineno, a, size
            if a + size <= addr and (i == 0 or self._entries[i - 1][0] != a):
                return None
            i -= 1
        return None

    def entries(self):
        return iter(self._entries)


def parse_addr(s):
    s = s.replace("$", "")
    if ":" in s:
        b, a = s.split(":")
        return int(b, 16) << 16 | int(a, 16)
    return int(s, 16)


def main(argv):
    if len(argv) < 2:
        print(__doc__)
        return 1
    m = SrcMap.build()
    if argv[1] == "addr":
        for s in argv[2:]:
            r = m.line_at(parse_addr(s))
            print(s, "->", "%s:%d ($%02X:%04X, %d bytes)" % (r[0], r[1], r[2] >> 16, r[2] & 0xFFFF, r[3]) if r else "nothing")
    elif argv[1] == "line":
        path, lineno = argv[2], int(argv[3])
        for a, size in m.lines.get(path, {}).get(lineno, []):
            print("$%02X:%04X %d bytes" % (a >> 16, a & 0xFFFF, size))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
