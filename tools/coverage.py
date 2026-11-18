#!/usr/bin/env python3
"""What the CDL traces never touched: every "unknown" ROM byte, by category.

The code/data log (cdl/contra3.cdl, book: CDL format) marks each ROM byte
as executed, read as data (by the CPU or by DMA), or neither: "unknown".
This tool puts every unknown byte in one category, from the CDL, the source
(the debug info of an assembly with -g, tools/srcmap.py: which line emits
each byte, which label it follows, which labels are referenced), the asset
manifest and tools/coverage_notes.json (what the investigation found that
the tool cannot see by itself).  Book: What the traces never touched.

    python3 tools/coverage.py               # the summary (make coverage)
    python3 tools/coverage.py --banks       # + per bank, and free space per bank
    python3 tools/coverage.py --top N       # + the N largest owners of each group (default 8)
    python3 tools/coverage.py --list        # + every run of unknown bytes
    python3 tools/coverage.py --markdown    # the tables of the book page, in Markdown
    python3 tools/coverage.py --dbg FILE    # use this ld65 debug file (else assemble into build/dbg)

Categories:

  free          the linker's $FF fill at the end of each bank (no source
                line emits it, contra3.cfg) and padding the source writes
                out ($FF/$00 runs, .res)
  hardware      the cartridge header and the interrupt vectors never taken
  leftover      bytes after the last block of a bank that nothing uses, with
                no structure: stale bytes of an earlier build
  unreferenced  blocks no label, pointer or code refers to (each one
                investigated: unused_* labels, comments in the source)
  asset         inside an asset (.incbin): a stream never decompressed, or
                the part of a raw block never read
  data          inside data blocks the code does refer to: whole blocks the
                traces never read, or entries of tables they read in part
  code          instructions never executed: routines that never ran (by
                group), and the paths of routines that ran but were not taken

The same CDL, source and notes always give the same output.
"""
import argparse
import bisect
import collections
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
import assets  # noqa: E402
from opcodes65816 import OPCODES  # noqa: E402
from srcmap import SrcMap  # noqa: E402

CDL = os.path.join(ROOT, "cdl", "contra3.cdl")
NOTES = os.path.join(HERE, "coverage_notes.json")
NBANKS = 32
MNEMONICS = {m for m, _ in OPCODES.values()}
PAD_MIN = 16        # a run of fill bytes at least this long is padding
FILL = {0xFF: (0xFF, 0xEF), 0xEF: (0xFF, 0xEF), 0x00: (0x00,)}

CATEGORIES = ["free", "hardware", "leftover", "unreferenced", "asset", "data", "code"]


def addr_of(off):
    return (off >> 15) << 16 | 0x8000 | (off & 0x7FFF)


def off_of(addr):
    return ((addr >> 16) & 0x7F) << 15 | (addr & 0x7FFF)


def fmt(addr):
    return "$%02X:%04X" % (addr >> 16, addr & 0xFFFF)


def parse_addr(s):
    return int(s.replace("$", "").replace(":", ""), 16)


def load_cdl(path, size):
    """(unknown, used): bytearrays, 1 per ROM byte; used = executed or read."""
    raw = open(path, "rb").read()
    if raw[:8] != b"SNESCDL\0":
        sys.exit("%s: not a SNESCDL file" % path)
    hsize = int.from_bytes(raw[10:12], "little")
    n = int.from_bytes(raw[12:16], "little")
    if n != size:
        sys.exit("%s: the CDL is for a %d-byte ROM, this one has %d" % (path, n, size))
    a = raw[hsize:hsize + n]
    b = raw[hsize + n:hsize + 2 * n]
    executed = bytes(1 if v & 0x03 else 0 for v in a)
    used = bytes(1 if (v & 0x0F) or (w & 0x80) else 0 for v, w in zip(a, b))
    return bytes(1 - u for u in used), used, executed


class Source:
    """Per ROM byte: the kind of line that emits it ('code', 'data',
    'incbin', 'res' or None), the line, and the labels in ROM."""

    def __init__(self, m, size, dbgpath):
        self.kind = [None] * size
        self.line = [None] * size
        self.inc = {}                    # line -> included path, without extension
        texts = {}
        for addr, sz, path, lineno in m.entries():
            if os.path.isabs(path):
                path = os.path.relpath(path, ROOT)
            if path not in texts:
                texts[path] = open(os.path.join(ROOT, path)).read().split("\n")
            text = texts[path][lineno - 1].split(";")[0].strip()
            word = text.split(None, 1)[0].lower() if text else ""
            if word == ".incbin":
                k = "incbin"
                self.inc[(path, lineno)] = os.path.splitext(re.search(r'"([^"]+)"', text).group(1))[0]
            elif word == ".res":
                k = "res"
            elif word in MNEMONICS:
                k = "code"
            else:
                k = "data"
            o = off_of(addr)
            for i in range(o, min(o + sz, size)):
                if self.kind[i] is None:
                    self.kind[i] = k
                    self.line[i] = (path, lineno)
        self.texts = texts
        self.refs = refs_of(dbgpath)
        # labels in ROM, not cheap locals; at one address prefer an unused_
        # name, then the referenced one, then the first by name
        at = collections.defaultdict(list)
        for name, v in m.labels.items():
            if name.startswith("@") or (v >> 16) >= NBANKS or (v & 0xFFFF) < 0x8000:
                continue
            at[off_of(v)].append(name)
        self.labels = []
        for o in sorted(at):
            names = sorted(at[o], key=lambda n: (not n.startswith("unused_"), not self.refs.get(n), n))
            self.labels.append((o, names[0], names))
        self.starts = [o for o, _, _ in self.labels]

    def owner(self, off):
        """(index into labels) of the block holding off, or None."""
        i = bisect.bisect_right(self.starts, off) - 1
        if i < 0 or (self.starts[i] >> 15) != (off >> 15):
            return None
        return i

    def block(self, i):
        start = self.starts[i]
        end = ((start >> 15) + 1) << 15
        if i + 1 < len(self.starts):
            end = min(end, self.starts[i + 1])
        return start, end

    def referenced(self, i):
        return any(self.refs.get(n) for n in self.labels[i][2])


def refs_of(dbgpath):
    """label name -> ROM offsets of the lines that refer to it (ld65's debug
    info; None for a referring line that emits no byte in ROM)."""
    segs, spans, lines, syms = {}, {}, {}, []
    with open(dbgpath) as f:
        for raw in f:
            kind, _, rest = raw.rstrip("\n").partition("\t")
            if kind not in ("seg", "span", "line", "sym"):
                continue
            kv = dict(re.findall(r'(\w+)=("[^"]*"|[^,]*)', rest))
            if kind == "seg":
                segs[kv["id"]] = int(kv["start"], 16)
            elif kind == "span":
                spans[kv["id"]] = (kv["seg"], int(kv["start"]))
            elif kind == "line":
                if "span" in kv:
                    lines[kv["id"]] = kv["span"].split("+")[0]
            else:
                syms.append((kv["name"].strip('"'), kv.get("ref")))
    out = {}
    for name, ref in syms:
        lst = out.setdefault(name, [])
        for lid in (ref.split("+") if ref else []):
            sp = lines.get(lid)
            if sp is None:
                lst.append(None)
                continue
            seg, start = spans[sp]
            addr = segs[seg] + start
            lst.append(off_of(addr) if (addr >> 16) < NBANKS and (addr & 0xFFFF) >= 0x8000 else None)
    return out


def load_notes(path):
    j = json.load(open(path))
    regions = []
    for n in j["regions"]:
        regions.append(dict(n, lo=off_of(parse_addr(n["start"])), hi=off_of(parse_addr(n["end"])) + 1))
    return j, regions


def group(rules, name):
    for rx, g in rules:
        if name and re.search(rx, name):
            return g
    return None


def classify(rom, unknown, used, executed, src, notes, manifest):
    """Runs of unknown bytes: (start, end, category, subcategory, owner)."""
    size = len(rom)
    out = [None] * size
    j, regions = notes
    by_path = {a.path: a for a in manifest}
    size_word_labels = j["size_words"]

    # the last byte of each bank that the game uses (executed or read)
    last_used = [-1] * NBANKS
    for off in range(size):
        if used[off]:
            last_used[off >> 15] = off

    def block_used(i):
        s, e = src.block(i)
        return any(used[s:e])

    # routines: the last label that is not a loc_, up to the next one
    routines = [(o, n) for o, n, _ in src.labels if not n.startswith("loc_")]
    rstarts = [o for o, _ in routines]
    ran = {}

    def routine(off):
        i = bisect.bisect_right(rstarts, off) - 1
        if i < 0 or (rstarts[i] >> 15) != (off >> 15):
            return None, False, False
        start, name = routines[i]
        end = ((start >> 15) + 1) << 15
        if i + 1 < len(rstarts):
            end = min(end, rstarts[i + 1])
        if start not in ran:
            ran[start] = any(executed[start:end])
        k = src.owner(start)
        return name, ran[start], src.referenced(k)

    def callers(name):
        refs = [x for x in src.refs.get(name, []) if x is not None]
        if not src.refs.get(name):
            return "no reference in the source (dead code)"
        if any(src.kind[x] == "code" and executed[x] for x in refs):
            return "called from code that ran, by a path never taken"
        if any(src.kind[x] == "code" for x in refs):
            return "called only from code that never ran"
        return "in tables: entries the traces never used"

    off = 0
    while off < size:
        if not unknown[off]:
            off += 1
            continue
        k = src.kind[off]
        bank = off >> 15
        # one source line at a time
        end = off + 1
        while end < size and unknown[end] and src.line[end] == src.line[off] and src.kind[end] == k \
                and (end >> 15) == bank:
            end += 1
        i = src.owner(off)
        name = src.labels[i][1] if i is not None else None
        if k is None:
            c = ("free", "linker fill", None)
        elif k == "res":
            c = ("free", "padding in the source", name)
        elif k == "code":
            r, did_run, refd = routine(off)
            if did_run:
                c = ("code", "paths not taken in routines that ran", r)
            else:
                g = group(j["code_groups"], r) or callers(r)
                c = ("code", g, r)
        elif k == "incbin":
            inc = src.inc[src.line[off]]
            a = by_path.get(inc)
            s = e = off
            while s > 0 and src.line[s - 1] == src.line[off]:
                s -= 1
            while e < size and src.line[e] == src.line[off]:
                e += 1
            read = any(used[s:e])
            kind = inc.split("/")[0]
            if i is not None and not src.referenced(i) and not read:
                c = ("unreferenced", "assets nothing loads", name or inc)
            elif a is not None and a.compressed:
                c = ("asset", "%s: streams never decompressed" % kind if not read
                     else "%s: stream bytes not read" % kind, name or inc)
            else:
                c = ("asset", "%s: blocks never read" % kind if not read
                     else "%s: parts of blocks never read" % kind, name or inc)
        else:
            # data
            nxt = src.owner(end) if end < size else None
            before_label = nxt is not None and src.starts[nxt] == end and end - off == 2
            if before_label and re.search(size_word_labels, src.labels[nxt][1]):
                c = ("data", "size words never read (sound CPU blocks)", src.labels[nxt][1])
            elif i is not None and src.kind[src.starts[i]] == "incbin" \
                    and not (src.line[off] and src.line[off] == src.line[src.starts[i]]):
                # bytes after the asset of this label, without a label of their own
                if off > last_used[bank]:
                    c = ("leftover", "stale bytes at the end of a bank", name)
                else:
                    c = ("unreferenced", "unlabelled bytes after an asset", name)
            elif i is None:
                c = ("unreferenced", "bytes before the first label of a bank", None)
            elif not src.referenced(i) and not block_used(i):
                c = ("unreferenced", "blocks nothing refers to", name)
            else:
                sub = "entries never read in tables that were read" if block_used(i) else "blocks never read"
                g = group(j["data_groups"], name) or "other tables"
                c = ("data", "%s: %s" % (sub, g), name)
        for x in range(off, end):
            out[x] = c
        off = end

    # padding: runs of fill bytes inside data lines, at least PAD_MIN long:
    # $FF (with a few stray $EF: at most one in 4) up to the next block or
    # the end of the bank's source, $00 only up to the end of the source.
    # The run is cut back to start at an $FF.
    off = 0
    while off < size:
        if not (unknown[off] and out[off][0] in ("data", "leftover", "unreferenced") and rom[off] in FILL
                and src.kind[off] == "data"):
            off += 1
            continue
        e = off
        allowed = FILL[rom[off]]
        while e < size and unknown[e] and rom[e] in allowed and src.kind[e] == "data" and (e >> 15) == (off >> 15):
            e += 1
        s0 = off
        while s0 < e and rom[s0] == 0xEF:
            s0 += 1
        ends_source = e >= size or src.kind[e] is None or (e >> 15) != (off >> 15)
        ends_block = ends_source or (src.owner(e) is not None and src.starts[src.owner(e)] == e)
        if rom[off] == 0:
            ends_block = ends_source
        stray = sum(1 for x in rom[s0:e] if x not in (0, 0xFF))
        if e - s0 >= PAD_MIN and ends_block and 4 * stray <= e - s0:
            for x in range(s0, e):
                out[x] = ("free", "padding in the source", out[x][2])
        off = e

    for n in regions:
        for x in range(n["lo"], n["hi"]):
            if unknown[x]:
                out[x] = (n["category"], n["subcategory"], n.get("owner") or out[x][2])

    runs = []
    off = 0
    while off < size:
        if not unknown[off]:
            off += 1
            continue
        e = off
        while e < size and unknown[e] and out[e] == out[off] and (e >> 15) == (off >> 15):
            e += 1
        runs.append((off, e) + tuple(out[off]))
        off = e
    return runs


def free_space(runs):
    """Per bank: (linker fill, padding in the source, start and length of the
    free run at the end of the bank: free or leftover bytes, up to the
    header at $00:FFC0)."""
    fill = collections.Counter()
    pad = collections.Counter()
    tail = {}
    for s, e, cat, sub, _ in runs:
        if sub == "linker fill":
            fill[s >> 15] += e - s
        elif cat == "free":
            pad[s >> 15] += e - s
    for s, e, cat, sub, _ in runs:
        b = s >> 15
        if cat in ("free", "leftover"):
            t = tail.get(b)
            tail[b] = (t[0], e) if t and t[1] == s else (s, e)
        elif cat != "hardware":
            tail.pop(b, None)
    out = []
    for b in range(NBANKS):
        t = tail.get(b)
        end = (b + 1) << 15 if b else off_of(0x00FFC0)
        if t and t[1] == end:
            out.append((b, fill[b], pad[b], t[0], t[1] - t[0]))
        else:
            out.append((b, fill[b], pad[b], end, 0))
    return out


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--rom", default=os.path.join(ROOT, "build", "contra3.sfc"))
    ap.add_argument("--cdl", default=CDL)
    ap.add_argument("--dbg", default=None, help="ld65 debug file (default: assemble into build/dbg)")
    ap.add_argument("--banks", action="store_true", help="also per bank, with the free space")
    ap.add_argument("--top", type=int, default=8, help="largest owners shown per group")
    ap.add_argument("--list", action="store_true", help="also every run of unknown bytes")
    ap.add_argument("--markdown", action="store_true", help="the book's tables, in Markdown")
    args = ap.parse_args(argv)

    rom = open(args.rom, "rb").read()
    if args.dbg:
        dbg = args.dbg
        m = SrcMap.load(dbg)
    else:
        m = SrcMap.build(srcdir=os.path.join(ROOT, "src"), outdir=os.path.join(ROOT, "build", "dbg"))
        dbg = os.path.join(ROOT, "build", "dbg", "contra3.dbg")
    unknown, used, executed = load_cdl(args.cdl, len(rom))
    src = Source(m, len(rom), dbg)
    notes = load_notes(NOTES)
    runs = classify(rom, unknown, used, executed, src, notes, assets.read_manifest())
    total = sum(unknown)
    assert sum(e - s for s, e, *_ in runs) == total
    if args.markdown:
        markdown(runs, unknown, used, args.top)
    else:
        text(runs, unknown, used, args)
    return 0


def tallies(runs):
    bycat = collections.Counter()
    bysub = collections.Counter()
    byowner = collections.defaultdict(collections.Counter)
    bybank = collections.defaultdict(collections.Counter)
    for s, e, cat, sub, owner in runs:
        bycat[cat] += e - s
        bysub[(cat, sub)] += e - s
        byowner[(cat, sub)][owner] += e - s
        bybank[s >> 15][cat] += e - s
    return bycat, bysub, byowner, bybank


def subs_of(bysub, cat):
    return sorted(((sub, n) for (c, sub), n in bysub.items() if c == cat), key=lambda x: (-x[1], x[0]))


def top_owners(counter, n):
    items = sorted(counter.items(), key=lambda x: (-x[1], x[0] or ""))
    return items[:n], len(items)


def text(runs, unknown, used, args):
    bycat, bysub, byowner, bybank = tallies(runs)
    total = sum(unknown)
    print("unknown bytes (neither executed nor read in the CDL): %d of %d" % (total, len(unknown)))
    for cat in CATEGORIES:
        print("\n%-62s %7d  %5.1f%%" % (cat, bycat[cat], 100.0 * bycat[cat] / total))
        for sub, n in subs_of(bysub, cat):
            print("    %-58s %7d" % (sub, n))
            if args.top and cat not in ("free",):
                items, k = top_owners(byowner[(cat, sub)], args.top)
                for owner, m in items:
                    print("        %-54s %7d" % (owner or "-", m))
                if k > len(items):
                    print("        ... %d more" % (k - len(items)))
    if args.banks:
        print("\nper bank: " + " ".join("%12s" % c for c in CATEGORIES) + "      total")
        for b in range(NBANKS):
            print("$%02X       " % b + " ".join("%12d" % bybank[b][c] for c in CATEGORIES)
                  + " %10d" % sum(bybank[b].values()))
        print("\nfree space: bank, linker fill, padding in the source, free run at the end of the bank")
        for b, fill, pad, start, n in free_space(runs):
            print("$%02X  %6d  %6d  %6d from %s" % (b, fill, pad, n, fmt(addr_of(start)) if n else "-"))
    if args.list:
        print()
        for s, e, cat, sub, owner in runs:
            print("%s-%s %6d  %-12s %-52s %s" % (fmt(addr_of(s)), fmt(addr_of(e - 1)), e - s, cat, sub, owner or ""))


def markdown(runs, unknown, used, top):
    bycat, bysub, byowner, bybank = tallies(runs)
    total = sum(unknown)
    print("| category | group | bytes | largest owners |")
    print("|---|---|--:|---|")
    for cat in CATEGORIES:
        print("| **%s** | | **%d** | |" % (cat, bycat[cat]))
        for sub, n in subs_of(bysub, cat):
            items, k = top_owners(byowner[(cat, sub)], top if cat != "free" else 0)
            owners = ", ".join("`%s` %d" % (o, m) for o, m in items if o)
            if k > len(items) and items:
                owners += ", ... (%d)" % k
            print("| | %s | %d | %s |" % (sub, n, owners))
    print("| **total** | | **%d** | |" % total)
    print()
    print("| bank | " + " | ".join(CATEGORIES) + " | total |")
    print("|---|" + "--:|" * (len(CATEGORIES) + 1))
    for b in range(NBANKS):
        print("| `$%02X` | " % b + " | ".join(str(bybank[b][c]) for c in CATEGORIES)
              + " | %d |" % sum(bybank[b].values()))
    print()
    print("| bank | linker fill | padding in the source | free at the end of the bank |")
    print("|---|--:|--:|---|")
    tf = tp = 0
    for b, fill, pad, start, n in free_space(runs):
        tf += fill
        tp += pad
        where = "%d from `%s`" % (n, fmt(addr_of(start))) if n else "0"
        print("| `$%02X` | %d | %d | %s |" % (b, fill, pad, where))
    print("| total | %d | %d | |" % (tf, tp))


if __name__ == "__main__":
    sys.exit(main())
