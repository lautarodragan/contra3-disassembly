#!/usr/bin/env python3
"""How big each asset may be: the capacity of where the game puts it (book:
Assets, "Size limits").

The game decompresses a stream to the address its data list gives, until the
stream ends: nothing checks the size, so a bigger asset overwrites whatever
follows it in VRAM, WRAM or the sound CPU's RAM.  This module works out,
from the source, what follows each asset there, and checks the assets
against their limits.

Where an asset goes (parse_lists): every data list of src/ (the load_list,
load_vram, load_wram, load_spc, load_spc_raw macros, data_macros.inc; lists
whose label starts with `unused_` are never loaded and are left out):

  type 0     VRAM, from the word address: 2 bytes per word;
  type 1     WRAM, in the bank of the destination (copy_ring_to_wram
             advances only the low word of the address: it wraps in the bank);
  type 2     the sound CPU's RAM (64 KiB);
  type 3+    VRAM, one byte per word (the low bytes for the first stream of
             a list with flags bit 0 set, else the high bytes): Mode 7.

What follows it (derive): the nearest of

  - a block that the same list loads after it and that starts inside it or
    after it (it overwrites what is there), or one that the list loaded
    before it and that it does not overwrite whole;
  - the start of a block that any list loads in the same space, at or after
    the end of the asset's limit (the blocks that start inside it belong to
    other screens: the original already covers them);
  - for WRAM, a label of src/ram.inc (a buffer the code uses) at or after
    that end;
  - the end of the space: VRAM's $8000 words (the address wraps to 0), the
    end of the WRAM bank, and for type 3 the $4000 words of Mode 7's 128x128
    tilemap (low bytes) and 256 characters (high bytes; tile numbers are 8
    bits).

If nothing but the end of WRAM bank $7E or of the sound CPU's RAM is found,
the capacity is not known.

The limits are recorded in assets/manifest.txt (`max=`, hex) because they
depend on the original size (which blocks of other lists are inside it), and
an edited asset has lost that.  `python3 tools/assets.py limits --verify`
checks that each recorded limit is still what the source gives (derive() of
the limit itself), so a changed data list cannot leave a stale limit behind.
Two kinds of asset have a size that the code fixes, with no `max=`:

  - an uncompressed sound block (load_spc_raw): its size word;
  - raw tiles read by td_tiles records (td_sprite_tiles_16): $100 bytes
    past the record with the largest offset (stream_topdown_sprite_gfx).

A compressed stream must also stay in its bank: the decompressor reads it
with [LDR_SRC],y, which carries into the next bank, and in LoROM $xx:0000
is not the next bank's ROM.  ld65 enforces it (each bank is a memory area of
$8000 bytes); bank_overflow() names the assets of a bank that overflows.
"""
import os
import re

VRAM_END = 0x10000          # bytes: $8000 words
MODE7_END = 0x4000          # words, one byte each
SPC_END = 0x10000
BANK_SIZE = 0x8000          # LoROM bank: $xx:8000-$xx:FFFF

SPACE_NAMES = {
    "vram": "VRAM",
    "m7lo": "VRAM (Mode 7 tilemap, low bytes)",
    "m7hi": "VRAM (Mode 7 characters, high bytes)",
    "spc": "the sound CPU's RAM",
}


class Entry:
    def __init__(self, lst, index, macro, args):
        self.list = lst
        self.index = index          # order in the list
        self.macro = macro
        self.args = args
        self.label = None
        self.dest = None            # address as written
        self.size_word = None       # load_spc_raw: the size, or None
        if macro == "load_spc_raw":
            self.dest, self.label = args[0], args[1]
            self.size_word = _num(args[2])
        else:
            self.dest, self.label = args[0], args[1]

    @property
    def where(self):
        return f"{self.list.label} ({self.list.path}:{self.list.line})"


class LoadList:
    def __init__(self, label, ltype, flags, path, line):
        self.label = label
        self.type = ltype
        self.flags = flags
        self.path = path
        self.line = line
        self.entries = []

    def space(self, entry):
        """(space, start offset in bytes) of an entry; the unit of a type-3
        space is a VRAM word (one byte each)."""
        dest = _num(entry.dest)
        if dest is None:
            return None, None
        if self.type == 0:
            return "vram", dest * 2
        if self.type == 1:
            return "wram%02X" % (dest >> 16), dest & 0xFFFF
        if self.type == 2:
            return "spc", dest
        low = self.flags & 1 and entry.index == 0
        return ("m7lo" if low else "m7hi"), dest


def _num(text):
    text = text.strip()
    if re.fullmatch(r"\$[0-9A-Fa-f]+", text):
        return int(text[1:], 16)
    if re.fullmatch(r"\d+", text):
        return int(text)
    return None


LABEL_RE = re.compile(r"^([A-Za-z_]\w*):")


def _asm_files(srcdir):
    out = []
    for d, _dirs, files in os.walk(srcdir):
        for f in files:
            if f.endswith(".asm"):
                out.append(os.path.join(d, f))
    return sorted(out)


def parse_lists(srcdir):
    """Every data list of the source, in file order."""
    lists = []
    for path in _asm_files(srcdir):
        label, cur = None, None
        for n, line in enumerate(open(path), 1):
            code = line.split(";")[0].strip()
            m = LABEL_RE.match(code)
            if m:
                label = m.group(1)
                code = code[m.end():].strip()
            if not code:
                continue
            words = code.split(None, 1)
            macro = words[0]
            args = [a.strip() for a in words[1].split(",")] if len(words) > 1 else []
            if macro == "load_list":
                cur = LoadList(label, _num(args[0]), _num(args[1]),
                               os.path.relpath(path, os.path.dirname(srcdir.rstrip("/")) or "."), n)
                lists.append(cur)
            elif macro in ("load_vram", "load_wram", "load_spc", "load_spc_raw") and cur:
                cur.entries.append(Entry(cur, len(cur.entries), macro, args))
            elif macro == "load_end":
                cur = None
    return lists


def ram_labels(srcdir):
    """[(address, name)] of the ram.inc labels in WRAM banks $7E-$7F above
    the first 8 KiB (the buffers there)."""
    out = []
    path = os.path.join(srcdir, "ram.inc")
    if not os.path.exists(path):
        return out
    for line in open(path):
        m = re.match(r"^(\w+)\s*=\s*\$(7[EF][0-9A-Fa-f]{4})\b", line)
        if m:
            addr = int(m.group(2), 16)
            if addr & 0xFFFF >= 0x2000 or addr >> 16 == 0x7F:
                out.append((addr, m.group(1)))
    return out


def td_tiles_reads(srcdir):
    """{label: bytes the td_tiles records read from it} (each half of a
    record is $100 bytes, stream_topdown_sprite_gfx)."""
    out = {}
    for path in _asm_files(srcdir):
        for line in open(path):
            code = line.split(";")[0].strip()
            if not code.startswith("td_tiles"):
                continue
            for half in code[len("td_tiles"):].split(","):
                m = re.fullmatch(r"\s*(\w+)\s*(?:\+\s*(\$[0-9A-Fa-f]+|\d+))?\s*", half)
                if m:
                    off = _num(m.group(2)) if m.group(2) else 0
                    out[m.group(1)] = max(out.get(m.group(1), 0), off + 0x100)
    return out


VRAM_REGS = ("BG1SC", "BG2SC", "BG3SC", "BG4SC", "BG12NBA", "BG34NBA", "OBSEL")


def vram_bases(srcdir):
    """[(word address, why)] of the VRAM areas the code sets up: the
    immediate values stored to BGnSC, BG12NBA, BG34NBA and OBSEL (or their
    shadows): where a tilemap, characters or sprite characters start."""
    out = {}
    for path in _asm_files(srcdir):
        last = None
        for n, line in enumerate(open(path), 1):
            code = line.split(";")[0].strip()
            m = re.fullmatch(r"lda\s+#\$([0-9A-Fa-f]+)", code)
            if m:
                last = int(m.group(1), 16)
                continue
            m = re.fullmatch(r"sta\s+(?:a:)?(\w+)", code)
            if not m or last is None:
                if code and not code.startswith("sta"):
                    last = None
                continue
            reg = m.group(1).upper().replace("_SHADOW", "")
            if reg not in VRAM_REGS:
                continue
            v = last & 0xFF
            if reg.endswith("SC"):
                bases = [(v & 0xFC) << 8]
                what = "a tilemap"
            elif reg == "OBSEL":
                bases = [(v & 7) << 13]
                what = "the sprite characters"
            else:
                bases = [(v & 0x0F) << 12, (v >> 4) << 12]
                what = "characters"
            where = f"{reg} = ${v:02X} ({os.path.relpath(path, os.path.dirname(srcdir.rstrip('/')) or '.')}:{n})"
            for b in bases:
                out.setdefault(b, f"{where}: {what} at ${b:04X}")
    return sorted(out.items())


class Source:
    """What the limits are derived from, read once."""

    def __init__(self, srcdir):
        self.lists = [lst for lst in parse_lists(srcdir)
                      if not (lst.label or "").startswith("unused_")]
        self.ram = ram_labels(srcdir)
        self.td_reads = td_tiles_reads(srcdir)
        self.vram_bases = vram_bases(srcdir)
        self.by_label = {}
        for lst in self.lists:
            for e in lst.entries:
                self.by_label.setdefault(e.label, []).append(e)

    def starts(self, space):
        """[(offset, entry)] of every block any list loads in this space."""
        out = []
        for lst in self.lists:
            for e in lst.entries:
                sp, off = lst.space(e)
                if sp == space:
                    out.append((off, e))
        return out


def _fmt_addr(space, off):
    if space == "vram":
        return "$%04X" % (off // 2)
    if space.startswith("wram"):
        return "$%s:%04X" % (space[4:], off)
    return "$%04X" % off


class Limit:
    def __init__(self, size, reason, known=True):
        self.size = size
        self.reason = reason
        self.known = known

    def __repr__(self):
        return f"Limit(${self.size:X}, {self.reason!r})"


def derive_entry(src, entry, size, sizes):
    """The capacity (Limit) at one load of an asset of `size` bytes (its
    recorded limit, or its original size).  sizes: {label: size} of the
    other blocks (None if not known)."""
    lst = entry.list
    space, start = lst.space(entry)
    if space is None:
        return Limit(size, f"{entry.where} loads it to {entry.dest}, not a number: "
                     "original size, capacity unknown", known=False)
    where = f"{entry.where} loads it to {SPACE_NAMES.get(space, 'WRAM')} {_fmt_addr(space, start)}"
    if space == "vram":
        end, end_why = VRAM_END, "the end of VRAM ($8000 words; the address wraps to $0000)"
    elif space in ("m7lo", "m7hi"):
        end = MODE7_END
        end_why = ("the end of the Mode 7 tilemap (128x128 entries, $4000 words)" if space == "m7lo"
                   else "the end of the Mode 7 characters (256 of 64 pixels, $4000 words)")
    elif space == "spc":
        end, end_why = SPC_END, None
    else:
        end = 0x10000
        end_why = (f"the end of WRAM bank ${space[4:]} (the address wraps to ${space[4:]}:0000)"
                   if space == "wram7F" else None)
    best = (end - start, end_why)

    def offer(d, why):
        nonlocal best
        if d < best[0]:
            best = (d, why)

    # the same list: what it loads after this block, or before it and does
    # not overwrite whole
    for other in lst.entries:
        if other is entry:
            continue
        sp, off = lst.space(other)
        if sp != space or off is None or off <= start:
            continue
        d = off - start
        osize = sizes.get(other.label)
        if other.index < entry.index and osize is not None and d + osize <= size:
            continue    # loaded before and overwritten whole: not there any more
        when = "after" if other.index > entry.index else "before"
        offer(d, f"{other.label}, which the same list loads {when} it at {_fmt_addr(space, off)}")
    # any list: blocks that start at or after the end of the limit
    lim_end = start + (size & ~1 if space == "vram" else size)
    for off, other in src.starts(space):
        if off >= lim_end and other.label != entry.label:
            offer(off - start, f"{other.label}, which {other.list.label} loads at {_fmt_addr(space, off)}")
    if space == "vram":
        for word, why in src.vram_bases:
            if word * 2 >= lim_end:
                offer(word * 2 - start, why)
    if space.startswith("wram"):
        bank = int(space[4:], 16)
        for addr, name in src.ram:
            if addr >> 16 == bank and (addr & 0xFFFF) >= lim_end:
                offer((addr & 0xFFFF) - start, f"{name} (src/ram.inc) at {_fmt_addr(space, addr & 0xFFFF)}")
    cap, why = best
    if why is None:
        return Limit(size, f"{where}; nothing known after it: original size, capacity unknown",
                     known=False)
    if cap < size:
        return Limit(size, f"{where}; next: {why}, {cap} bytes after its start, which the "
                     f"original already reaches past (its last {size - cap} bytes): "
                     "it cannot grow", known=True)
    return Limit(cap, f"{where}; next: {why}")


def derive(src, label, size, sizes):
    """The limit of an asset (smallest over its loads), or None if it is
    not loaded by a data list."""
    best = None
    for e in src.by_label.get(label, []):
        if e.macro == "load_spc_raw":
            continue
        lim = derive_entry(src, e, size, sizes)
        if best is None or lim.size < best.size or (lim.size == best.size and best.known is False):
            best = lim
    return best


def fixed_size(src, label):
    """(size, reason) of an asset whose size the code fixes, or None."""
    words = {e.size_word for e in src.by_label.get(label, []) if e.macro == "load_spc_raw"}
    words.discard(None)
    if words:
        if len(words) > 1:
            return None
        n = words.pop()
        uses = sorted({e.list.label for e in src.by_label[label] if e.macro == "load_spc_raw"})
        return n, (f"load_spc_raw uploads ${n:04X} bytes of it ({', '.join(uses[:3])}"
                   f"{' ...' if len(uses) > 3 else ''}): change the size there with the data")
    if label in src.td_reads:
        n = src.td_reads[label]
        return n, (f"the td_tiles records read ${n:04X} bytes of it (the largest offset + $100, "
                   "stream_topdown_sprite_gfx)")
    return None


# ---------------------------------------------------------------- checks

def label_of(asset):
    return asset.path.rsplit("/", 1)[-1]


def parse_max(text):
    return int(text.lstrip("$"), 16)


def data_size(asset, root):
    """Bytes of the asset's data (decompressed), from the file the build
    compresses or includes (made first, for a PNG)."""
    return os.path.getsize(os.path.join(root, asset.data_source))


def _plural(n, word):
    return f"{n:,} {word}{'' if n == 1 else 's'}"


def _tiles_note(asset, n):
    """' (N tiles of FMT + T bytes)' for a PNG asset."""
    if not asset.png:
        return ""
    import snesgfx
    size = snesgfx.FORMATS[asset.png][1]
    tail = len(bytes.fromhex(asset.options.get("tail", "")))
    return f" ({_plural((n - tail) // size, asset.png + ' tile')}{f' + {tail} tail' if tail else ''})"


def recorded_sizes(assets, root):
    """{label: size} for derive(): the recorded limit, else the data's size."""
    out = {}
    for a in assets:
        if "max" in a.options:
            out[label_of(a)] = parse_max(a.options["max"])
        else:
            try:
                out[label_of(a)] = data_size(a, root)
            except OSError:
                pass
    return out


def check(assets, root, srcdir):
    """Error messages (empty: every asset fits)."""
    src = Source(srcdir)
    errors = []
    sizes = None
    for a in assets:
        label = label_of(a)
        try:
            n = data_size(a, root)
        except OSError:
            continue        # not made yet (the build reports it)
        fixed = fixed_size(src, label)
        if fixed and n != fixed[0]:
            errors.append(f"{a.source}: {n:,} bytes{_tiles_note(a, n)}, but the code uses "
                          f"exactly {fixed[0]:,} (${fixed[0]:04X}): {fixed[1]}")
        if "max" in a.options:
            limit = parse_max(a.options["max"])
            if n > limit:
                if sizes is None:
                    sizes = recorded_sizes(assets, root)
                lim = derive(src, label, limit, sizes)
                why = lim.reason if lim else "not loaded by any data list: original size, capacity unknown"
                errors.append(
                    f"{a.source}: {n:,} bytes{_tiles_note(a, n)} decompressed, more than its "
                    f"limit of {limit:,}{_tiles_note(a, limit)} (max=${limit:04X} in "
                    f"assets/manifest.txt). Where it comes from: {why}. A bigger asset "
                    "would overwrite what follows it (book: Assets, Size limits).")
        if a.compressed:
            lz = os.path.join(root, a.target)
            if os.path.exists(lz) and os.path.getsize(lz) > BANK_SIZE:
                errors.append(f"{a.target}: the compressed stream is {os.path.getsize(lz):,} bytes, "
                              f"more than a bank (${BANK_SIZE:04X}): a stream cannot cross a bank")
    return errors


def verify(assets, root, srcdir):
    """Recorded limits that the source no longer gives, and compressed
    assets without one (messages)."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    out = []
    for a in assets:
        label = label_of(a)
        if fixed_size(src, label):
            continue
        if "max" not in a.options:
            if a.compressed:
                out.append(f"{a.path}: no limit (max=) in the manifest: "
                           f"python3 tools/assets.py limits --record {a.path}")
            continue
        limit = parse_max(a.options["max"])
        lim = derive(src, label, limit, sizes)
        if lim is None:
            continue        # not loaded by a list: the original size, kept
        if lim.size != limit:
            out.append(f"{a.path}: max=${limit:04X}, but the source gives ${lim.size:04X}: {lim.reason}")
    return out


def record(assets, root, srcdir):
    """Set max= on these assets from the source and their current size;
    returns them."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    done = []
    for a in assets:
        n = data_size(a, root)
        lim = derive(src, label_of(a), n, sizes)
        a.options["max"] = "$%04X" % (lim.size if lim else n)
        done.append(a)
    return done


def report(assets, root, srcdir):
    """Lines: path, size, limit, room, where the limit comes from."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    out = []
    for a in assets:
        label = label_of(a)
        n = data_size(a, root)
        fixed = fixed_size(src, label)
        if fixed:
            limit, why = fixed[0], "exactly: " + fixed[1]
        elif "max" in a.options:
            limit = parse_max(a.options["max"])
            lim = derive(src, label, limit, sizes)
            why = lim.reason if lim else "not loaded by a data list: original size, capacity unknown"
        else:
            limit, why = None, "no limit recorded"
        room = "-" if limit is None else f"{limit - n:+,}"
        out.append(f"{a.path:32} {n:7,} {'-' if limit is None else format(limit, ','):>7} {room:>7}  {why}")
    return out


# ---------------------------------------------------------------- banks

OVERFLOW_RE = re.compile(r"Segment\W+BANK([0-9A-Fa-f]{2})\W+overflows memory area\W+\w+\W+by (\d+) bytes")
RANGE_RE = re.compile(r"\$([0-9A-F]{2}):([0-9A-F]{4})-\$([0-9A-F]{2}):([0-9A-F]{4})")


def bank_assets(srcdir):
    """{bank: [(included path, original size in the ROM or None)]} from
    main.asm's segments and the .incbin lines (the original size from the
    address range in the comment above it, if any)."""
    out = {}
    bank = None
    for line in open(os.path.join(srcdir, "main.asm")):
        m = re.match(r'\.segment\s+"BANK([0-9A-F]{2})"', line)
        if m:
            bank = int(m.group(1), 16)
            continue
        if line.startswith(".segment"):
            bank = None
            continue
        m = re.match(r'\.include\s+"([^"]+\.asm)"', line)
        if not (m and bank is not None):
            continue
        comments = []
        for text in open(os.path.join(srcdir, m.group(1))):
            # (tools/shift.py includes some through a macro)
            inc = re.match(r'\s*(?:\.incbin|shift_incbin_filler)\s+"([^"]+)"', text)
            if inc:
                orig = None
                for c in comments:
                    r = RANGE_RE.search(c)
                    if r:
                        orig = int(r.group(4), 16) - int(r.group(2), 16) + 1
                out.setdefault(bank, []).append((inc.group(1), orig))
            if text.strip().startswith(";"):
                comments.append(text)
            elif text.strip():
                comments = []
    return out


def ld65_diagnosis(output, srcdir, include_dirs):
    """A message naming the assets of each bank ld65 says overflows."""
    lines = []
    banks = bank_assets(srcdir)
    for m in OVERFLOW_RE.finditer(output):
        bank, over = int(m.group(1), 16), int(m.group(2))
        lines.append(f"bank ${bank:02X} is {over:,} bytes too full. Its assets (in the ROM; "
                     "the original in brackets where its source comment gives it):")
        for path, orig in banks.get(bank, []):
            size = None
            for d in include_dirs:
                if os.path.exists(os.path.join(d, path)):
                    size = os.path.getsize(os.path.join(d, path))
                    break
            grew = f" (original {orig:,}, {size - orig:+,})" if orig and size is not None and size != orig else ""
            lines.append(f"    {path:36} {size if size is None else format(size, ','):>8}{grew}")
        lines.append(f"  A bank is ${BANK_SIZE:04X} bytes and a compressed stream cannot cross into the next one "
                     "(the decompressor reads it with [LDR_SRC],y, which would go on at $xx:0000, not ROM in LoROM). "
                     "Make the stream compress better, or make room in the bank (book: Assets, Size limits).")
    return "\n".join(lines)
