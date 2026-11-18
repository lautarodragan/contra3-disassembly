#!/usr/bin/env python3
"""Symbol files for SNES debugging emulators, from ld65's debug info.

    python3 tools/symbols.py build            # make symbols: build/contra3.mlb, build/contra3.cpu.sym
    python3 tools/symbols.py write DBG BASE   # BASE.mlb and BASE.cpu.sym from an ld65 --dbgfile
    python3 tools/symbols.py check BASE DIR   # parse BASE.* back, check against DIR's map and labels

`build` assembles src/ with debug info (ca65 -g, ld65 --dbgfile) into
build/symbols/, checks that the ROM it links is build/contra3.sfc (the
default build, `make` checks it is the original), writes the two files next
to it and checks them.  tools/cheats.py writes the same files for each
cheat ROM (build/contra3-<name>.mlb / .cpu.sym), from that ROM's own link.

What goes in (book: Building, "Debugging in an emulator"):

- every ROM label (type=lab in the debug file): routines, tables, data.
  Cheap locals are named after the label they belong to: `nmi@run_frame`
  (Mesen's label syntax allows `@`, not `.`).  The first line of the
  comment block directly above a label is its comment.  A label of data
  (a directive such as .byte or a data macro of src/data_macros.inc) gets
  a length in the .mlb: up to the next label or the first code line.
- the RAM symbols of src/ram.inc (everything above its "structures"
  section), with their comments; a length only where the comment gives the
  symbol's own extent, "($0200-$0ABF" or "($40 bytes", and no other
  symbol starts inside it.
- the hardware registers of src/snes_registers.inc (tools/snes_regs.py).

Formats, checked against the emulators' parsers:

- Mesen 2 `.mlb` (UI/Debugger/Labels/CodeLabel.cs FromString,
  MesenLabelFile.cs): one `Type:Address[-End]:name[:comment]` per line;
  SnesPrgRom addresses are ROM file offsets (LoROM: bank * $8000 +
  address - $8000), SnesWorkRam offsets in the 128 KiB of WRAM
  ($7E:0000 = 0), SnesRegister CPU addresses ($2100).  Names match
  `^[@_a-zA-Z]+[@_a-zA-Z0-9]*$` and are unique; one label per byte
  (LabelManager.SetLabel deletes a label that another one overlaps), so
  aliases at the same address are listed in the comment of the one kept.
- bsnes-plus `.cpu.sym` (ui-qt/debugger/disassembler/symbols/adapters/
  wla_symbol_file.cpp): WLA DX's `[labels]` section, `BB:AAAA name`, and a
  `[comments]` section in the same form; ';' starts a comment there, so it
  is never in a name or comment.  It looks symbols up by the exact 24-bit
  address an operand resolves to (the direct page in bank $00, absolute
  operands in the data bank, which the game keeps at $05 from nmi), so the
  RAM below $2000 and the registers are listed in banks $00 and $05, and
  the low RAM also at $7E.  bsnes-plus loads <rom>.cpu.sym (then <rom>.sym)
  next to the ROM; the name .cpu.sym also keeps Mesen, which auto-loads
  <rom>.sym before <rom>.mlb, on the .mlb.
"""
import argparse
import bisect
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)

import srcmap  # noqa: E402

RAM_INC = "src/ram.inc"
REG_INC = "src/snes_registers.inc"
DATA_MACROS = "src/data_macros.inc"
# Banks a bsnes-plus operand address of the RAM below $2000 or of a register
# can have: the direct page ($00), the data bank the game runs with ($05, set
# by nmi with `lda #^tables_05 / pha / plb`) and, for the RAM, $7E.
LOW_RAM_BANKS = (0x00, 0x05, 0x7E)
REG_BANKS = (0x00, 0x05)
MESEN_NAME = re.compile(r"^[@_a-zA-Z]+[@_a-zA-Z0-9]*$")
COMMENT_MAX = 200


def rom_offset(addr):
    """LoROM CPU address ($BB:8000-$BB:FFFF) -> ROM file offset."""
    bank, low = addr >> 16, addr & 0xFFFF
    if low < 0x8000:
        raise ValueError("$%06X is not a LoROM ROM address" % addr)
    return (bank & 0x7F) * 0x8000 + (low - 0x8000)


def wram_offset(value):
    """RAM symbol value ($0000-$1FFF or $7E:0000-$7F:FFFF) -> WRAM offset."""
    if value < 0x2000:
        return value
    if 0x7E0000 <= value <= 0x7FFFFF:
        return value - 0x7E0000
    raise ValueError("$%06X is not a WRAM address" % value)


class Source:
    """Lines of the source files, read once."""

    def __init__(self, root):
        self.root = root
        self.cache = {}

    def lines(self, path):
        if path not in self.cache:
            with open(os.path.join(self.root, path)) as f:
                self.cache[path] = f.read().split("\n")
        return self.cache[path]

    def line(self, path, lineno):
        lines = self.lines(path)
        return lines[lineno - 1] if 0 < lineno <= len(lines) else ""


def data_macros(root):
    names = set()
    for line in open(os.path.join(root, DATA_MACROS)):
        m = re.match(r"\s*\.macro\s+(\w+)", line)
        if m:
            names.add(m.group(1))
    return names


def is_data_line(text, macros):
    """True if this source line emits data (a directive or a data macro)."""
    text = text.split(";", 1)[0]
    text = re.sub(r"^\s*(@?\w+:\s*)+", "", text).strip()
    if not text:
        return False
    word = text.split()[0]
    return word.startswith(".") or word in macros


def one_line(text):
    """First sentence of a comment, without what the formats cannot hold."""
    text = " ".join(text.split())
    m = re.match(r"(.+?[.!?])(\s|$)", text)
    if m:
        text = m.group(1)
    if len(text) > COMMENT_MAX:
        text = text[:COMMENT_MAX - 3].rstrip() + "..."
    return text.replace(";", ",")


def header_comment(src, path, lineno):
    """First paragraph of the ';' block directly above a label's line."""
    block = []
    i = lineno - 1
    while i > 0:
        t = src.line(path, i).strip()
        if not t.startswith(";"):
            break
        block.append(t.lstrip(";").strip())
        i -= 1
    block.reverse()
    para = []
    for t in block:
        if not t:
            if para:
                break
            continue
        para.append(t)
    return one_line(" ".join(para)) if para else ""


class Symbols:
    def __init__(self):
        self.rom = []     # dicts: name, addr, length, comment, aliases
        self.ram = []     # dicts: name, value, offset, length, comment, aliases
        self.regs = []    # dicts: name, addr


def read_dbg(path):
    files, lines, syms = {}, {}, []
    with open(path) as f:
        for raw in f:
            kind, _, rest = raw.rstrip("\n").partition("\t")
            if kind not in ("file", "line", "sym"):
                continue
            kv = srcmap._kv(rest)
            if kind == "file":
                files[int(kv["id"])] = kv["name"]
            elif kind == "line":
                lines[int(kv["id"])] = (int(kv["file"]), int(kv["line"]))
            else:
                syms.append(kv)
    return files, lines, syms


def collect(dbg, root=ROOT):
    files, lines, syms = read_dbg(dbg)
    smap = srcmap.SrcMap.load(dbg)
    src = Source(root)
    macros = data_macros(root)
    by_id = {int(s["id"]): s for s in syms}

    def where(s):
        fid, lineno = lines[int(s["def"].split("+")[0])]
        return files[fid], lineno

    out = Symbols()

    # ---- ROM labels ----
    labels = []
    for s in syms:
        if s.get("type") != "lab" or "val" not in s or "seg" not in s:
            continue
        name = s["name"]
        if name.startswith("@"):
            name = by_id[int(s["parent"])]["name"] + name
        path, lineno = where(s)
        labels.append((int(s["val"], 16), name.startswith("@") or "@" in name,
                       path, lineno, name))
    labels.sort()
    starts = sorted({lab[0] for lab in labels})
    entries = list(smap.entries())
    entry_starts = [e[0] for e in entries]
    groups = {}
    for addr, cheap, path, lineno, name in labels:
        groups.setdefault(addr, []).append((cheap, path, lineno, name))
    for addr in starts:
        # Several labels at one address: the last normal one in the source
        # (the one written on the code or data itself, not a bank marker
        # such as tables_05 above it) names it; the others are aliases.
        group = sorted(groups[addr])
        normal = [g for g in group if not g[0]] or group
        primary = normal[-1]
        group.remove(primary)
        group.insert(0, primary)
        cheap, path, lineno, name = primary
        comment = "" if cheap else header_comment(src, path, lineno)
        length = 1
        hit = smap.line_at(addr)
        if hit and is_data_line(src.line(hit[0], hit[1]), macros):
            i = bisect.bisect_right(starts, addr)
            limit = starts[i] if i < len(starts) else (addr | 0xFFFF) + 1
            limit = min(limit, (addr | 0xFFFF) + 1)
            end = addr
            j = bisect.bisect_left(entry_starts, addr)
            while j < len(entries) and entries[j][0] < limit:
                a, size, p, n = entries[j]
                if a > end or not is_data_line(src.line(p, n), macros):
                    break
                end = max(end, min(a + size, limit))
                j += 1
            length = max(1, end - addr)
        out.rom.append({"name": name, "addr": addr, "length": length,
                        "comment": comment,
                        "aliases": [g[3] for g in group[1:]]})

    # ---- RAM (src/ram.inc above "structures") and registers ----
    values = {s["name"]: int(s["val"], 16) for s in syms
              if s.get("type") == "equ" and "val" in s}
    ram = []
    for line in src.lines(RAM_INC):
        if line.startswith("; ---- structures"):
            break
        m = re.match(r"([A-Za-z_]\w*)\s*=\s*([^;]+?)\s*(?:;\s*(.*))?$", line)
        if not m:
            continue
        name, comment = m.group(1), (m.group(3) or "").strip()
        if name == "RAM_INC":
            continue
        if name not in values:
            sys.exit("%s: %s is not in the debug file" % (RAM_INC, name))
        ram.append((values[name], name, comment))
    ram_starts = sorted({r[0] for r in ram})
    seen = {}
    for value, name, comment in ram:
        if value in seen:
            seen[value]["aliases"].append(name)
            continue
        length = own_extent(value, comment)
        if length > 1:
            i = bisect.bisect_right(ram_starts, value)
            if i < len(ram_starts) and ram_starts[i] < value + length:
                length = 1      # other symbols inside: no size claimed
        seen[value] = {"name": name, "value": value, "offset": wram_offset(value),
                       "length": length, "comment": comment.replace(";", ","),
                       "aliases": []}
        out.ram.append(seen[value])

    for line in src.lines(REG_INC):
        m = re.match(r"([A-Za-z_]\w*)\s*=", line)
        if m:
            out.regs.append({"name": m.group(1), "addr": values[m.group(1)]})
    return out


def own_extent(value, comment):
    """Bytes the comment says the symbol itself spans, else 1."""
    if comment.lower().startswith("start of"):
        return 1
    m = re.search(r"\(\$(?:(7[EF]):)?([0-9A-Fa-f]{4})-\$(?:(7[EF]):)?([0-9A-Fa-f]{4})", comment)
    if m:
        start = int(m.group(2), 16) | (int(m.group(1), 16) << 16 if m.group(1) else 0)
        end = int(m.group(4), 16) | (int(m.group(3), 16) << 16 if m.group(3) else 0)
        if m.group(1) and not m.group(3):
            end |= start & 0xFF0000
        if start == value and end > start:
            return end - start + 1
        return 1
    m = re.search(r"\(\$([0-9A-Fa-f]+) bytes", comment)
    if m:
        return int(m.group(1), 16)
    return 1


# ---- writers ----

def mesen_comment(main, aliases):
    text = main
    if aliases:
        text = "also %s. %s" % (", ".join(aliases), main)
    return text.strip().replace("\n", "\\n")


def mesen_line(mtype, addr, length, name, comment):
    a = "%04X" % addr if length <= 1 else "%04X-%04X" % (addr, addr + length - 1)
    line = "%s:%s:%s" % (mtype, a, name)
    return line + (":" + comment if comment else "")


def write_mlb(syms, path):
    out = []
    for r in syms.rom:
        out.append(mesen_line("SnesPrgRom", rom_offset(r["addr"]), r["length"],
                              r["name"], mesen_comment(r["comment"], r["aliases"])))
    for r in syms.ram:
        out.append(mesen_line("SnesWorkRam", r["offset"], r["length"], r["name"],
                              mesen_comment(r["comment"], r["aliases"])))
    for r in syms.regs:
        out.append(mesen_line("SnesRegister", r["addr"], 1, r["name"], ""))
    with open(path, "w", newline="\n") as f:
        f.write("\n".join(out) + "\n")
    return len(out)


def write_sym(syms, path):
    labels, comments = [], []
    for r in syms.rom:
        for name in [r["name"]] + r["aliases"]:
            labels.append((r["addr"], name))
        if r["comment"]:
            comments.append((r["addr"], r["comment"]))
    for r in syms.ram:
        banks = LOW_RAM_BANKS if r["value"] < 0x2000 else (r["value"] >> 16,)
        for bank in banks:
            for name in [r["name"]] + r["aliases"]:
                labels.append(((bank << 16) | (r["value"] & 0xFFFF), name))
    for r in syms.regs:
        for bank in REG_BANKS:
            labels.append(((bank << 16) | r["addr"], r["name"]))
    labels.sort(key=lambda x: x[0])     # stable: aliases stay in source order
    with open(path, "w", newline="\n") as f:
        f.write("; Contra III (USA) symbols for bsnes-plus (WLA DX format), "
                "made by tools/symbols.py\n\n[labels]\n")
        for a, name in labels:
            f.write("%02X:%04X %s\n" % (a >> 16, a & 0xFFFF, name))
        f.write("\n[comments]\n")
        for a, text in comments:
            f.write("%02X:%04X %s\n" % (a >> 16, a & 0xFFFF, text))
    return len(labels), len(comments)


def write(dbg, base, root=ROOT, quiet=False):
    syms = collect(dbg, root)
    n = write_mlb(syms, base + ".mlb")
    nl, nc = write_sym(syms, base + ".cpu.sym")
    if not quiet:
        print("%s.mlb: %d labels; %s.cpu.sym: %d labels, %d comments"
              % (os.path.relpath(base, root), n, os.path.relpath(base, root), nl, nc))
    return syms


# ---- readers, as the emulators parse the files ----

MESEN_TYPES = {"SnesPrgRom", "SnesWorkRam", "SnesSaveRam", "SnesRegister"}


def parse_mlb(path):
    """Mesen 2's CodeLabel.FromString, then LabelManager.SetLabel's overlaps."""
    labels, errors, by_key, by_name = [], [], {}, {}
    for n, row in enumerate(open(path, encoding="utf-8").read().split("\n"), 1):
        if row == "":
            continue
        f = row.split(":", 3)
        if len(f) < 3 or f[0] not in MESEN_TYPES:
            errors.append("%d: bad row %r" % (n, row))
            continue
        try:
            if "-" in f[1]:
                a, e = (int(x, 16) for x in f[1].split("-"))
                if e <= a:
                    raise ValueError
                length = e - a + 1
            else:
                a, length = int(f[1], 16), 1
        except ValueError:
            errors.append("%d: bad address %r" % (n, f[1]))
            continue
        if f[2] and not MESEN_NAME.match(f[2]):
            errors.append("%d: bad name %r" % (n, f[2]))
            continue
        lab = (f[0], a, length, f[2], f[3].replace("\\n", "\n") if len(f) > 3 else "")
        if f[2] in by_name:
            errors.append("%d: %s defined twice (Mesen keeps the last)" % (n, f[2]))
        by_name[f[2]] = lab
        for i in range(a, a + length):
            if (f[0], i) in by_key:
                errors.append("%d: %s overlaps %s (Mesen deletes it)"
                              % (n, f[2], by_key[(f[0], i)][3]))
            by_key[(f[0], i)] = lab
        labels.append(lab)
    return labels, errors


def parse_sym(path):
    """bsnes-plus WlaSymbolFile::read: fixed columns, ';' starts a comment."""
    labels, comments, errors = [], [], []
    section = "labels"
    for n, row in enumerate(open(path).read().split("\n"), 1):
        c = row.find(";")
        if c == 0:
            continue
        if c > 0:
            errors.append("%d: ';' inside a row" % n)
            row = row[:c]
        row = row.strip(" ")
        if not row:
            continue
        if row[0] == "[":
            section = {"[labels]": "labels", "[comments]": "comments"}.get(row, "")
            continue
        if not re.fullmatch(r"[0-9A-F]{2}:[0-9A-F]{4} \S.*", row):
            errors.append("%d: bad row %r" % (n, row))
            continue
        addr = int(row[0:2], 16) << 16 | int(row[3:7], 16)
        (labels if section == "labels" else comments).append((addr, row[8:]))
    return labels, comments, errors


def read_map_segments(path):
    segs = {}
    lines = open(path).read().split("\n")
    i = lines.index("Segment list:")
    for line in lines[i + 4:]:
        f = line.split()
        if len(f) < 5:
            break
        segs[f[0]] = (int(f[1], 16), int(f[2], 16))
    return segs


def read_ld65_labels(path):
    """ld65 -Ln: `al ADDR .name`; the cheap locals only by their own name."""
    out = {}
    for line in open(path):
        f = line.split()
        if len(f) == 3 and f[0] == "al":
            out.setdefault(f[2][1:], set()).add(int(f[1], 16))
    return out


def check(base, linkdir, root=ROOT, rom_path=None):
    """Parse the files back as the emulators do; check them against the link."""
    errors = []
    mlb, e = parse_mlb(base + ".mlb")
    errors += ["mlb " + x for x in e]
    labels, comments, e = parse_sym(base + ".cpu.sym")
    errors += ["sym " + x for x in e]
    segs = read_map_segments(os.path.join(linkdir, "contra3.map"))
    ld65 = read_ld65_labels(os.path.join(linkdir, "contra3.lbl"))
    rom = open(rom_path or os.path.join(linkdir, "contra3.sfc"), "rb").read()

    def in_segment(addr):
        return any(s <= addr <= e + 1 for s, e in segs.values())

    sym_rom = {}
    for addr, name in labels:
        if (addr & 0xFFFF) >= 0x8000 and (addr >> 16) < 0x7E:
            sym_rom.setdefault(name, set()).add(addr)
    nrom = 0
    for t, a, length, name, _ in mlb:
        if t != "SnesPrgRom":
            continue
        nrom += 1
        addrs = sym_rom.get(name, set())
        if len(addrs) != 1:
            errors.append("%s: %d addresses in the .cpu.sym" % (name, len(addrs)))
            continue
        addr = next(iter(addrs))
        if rom_offset(addr) != a:
            errors.append("%s: .mlb offset $%05X, .cpu.sym $%06X" % (name, a, addr))
        own = name.split("@", 1)[1] if "@" in name else name
        own = "@" + own if "@" in name else own
        if addr not in ld65.get(own, ()):
            errors.append("%s: $%06X not in ld65's label file" % (name, addr))
        if not in_segment(addr) or not in_segment(addr + length - 1):
            errors.append("%s: $%06X+%d outside the map's segments" % (name, addr, length))
        if a + length > len(rom):
            errors.append("%s: past the end of the ROM" % name)
    # every ROM label ld65 knows is in the files (aliases in the .cpu.sym)
    known = {}
    for name, addrs in sym_rom.items():
        own = "@" + name.split("@", 1)[1] if "@" in name else name
        for addr in addrs:
            known.setdefault(own, set()).add(addr)
    for name, addrs in ld65.items():
        if (addrs - known.get(name, set())) and any((x & 0xFFFF) >= 0x8000 for x in addrs):
            errors.append("ld65 label %s missing" % name)
    nram = sum(1 for x in mlb if x[0] == "SnesWorkRam")
    nreg = sum(1 for x in mlb if x[0] == "SnesRegister")
    return errors, (nrom, nram, nreg, len(labels), len(comments))


def report(base, linkdir, rom_path=None):
    errors, (nrom, nram, nreg, nl, nc) = check(base, linkdir, rom_path=rom_path)
    for e in errors[:50]:
        print("  " + e, file=sys.stderr)
    if errors:
        sys.exit("%s: %d problems" % (os.path.relpath(base, ROOT), len(errors)))
    print("%s.mlb / .cpu.sym: OK (%d ROM, %d WRAM, %d register labels in the .mlb; "
          "%d labels, %d comments in the .cpu.sym; ROM labels match ld65's)"
          % (os.path.relpath(base, ROOT), nrom, nram, nreg, nl, nc))


def cmd_build(args):
    rom = os.path.join(ROOT, "build", "contra3.sfc")
    if not os.path.exists(rom):
        sys.exit("build/contra3.sfc missing: run `make` first")
    outdir = os.path.join(ROOT, "build", "symbols")
    cwd = os.getcwd()
    os.chdir(ROOT)
    try:
        built, dbg = srcmap.assemble("src", outdir)
    finally:
        os.chdir(cwd)
    if open(built, "rb").read() != open(rom, "rb").read():
        sys.exit("the debug build in build/symbols/ differs from build/contra3.sfc")
    base = os.path.join(ROOT, "build", "contra3")
    write(os.path.join(ROOT, dbg) if not os.path.isabs(dbg) else dbg, base)
    report(base, outdir)


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("build").set_defaults(func=cmd_build)
    p = sub.add_parser("write")
    p.add_argument("dbg")
    p.add_argument("base")
    p.set_defaults(func=lambda a: write(a.dbg, a.base))
    p = sub.add_parser("check")
    p.add_argument("base")
    p.add_argument("linkdir")
    p.set_defaults(func=lambda a: report(a.base, a.linkdir))
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
