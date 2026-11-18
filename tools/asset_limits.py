#!/usr/bin/env python3
"""How big each asset may be: the capacity of where the game puts it (book:
Assets, "Size limits").

The game decompresses a stream to the address its data list gives, until the
stream ends, and copies a palette block as long as its size word says:
nothing checks the size, so a bigger asset overwrites whatever follows it
in VRAM, WRAM, the sound CPU's RAM or the palette buffer.  This module works out,
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

and every palette task (palette_animate + palette_copy, palette_fade_in,
palette_fade_out): a palette block (gpl=block) goes to palette_buffer
($7E:2200, the copy of CGRAM), its colours only (not its size word).

What follows it (derive): the nearest of

  - a block that the same list loads after it and that starts inside it or
    after it (it overwrites what is there), or one that the list loaded
    before it and that it does not overwrite whole;
  - the start of a block that any list loads in the same space, at or after
    the end of the asset's limit (the blocks that start inside it belong to
    other screens: the original already covers them);
  - for VRAM, a tilemap or character base that the code sets up (an
    immediate value stored to BGnSC, BG12NBA, BG34NBA or OBSEL);
  - for WRAM, a label of src/ram.inc (a buffer the code uses) at or after
    that end;
  - for the sound CPU's RAM, the echo buffer (echo_buffer: the address the
    driver's code gives ESA for the largest echo delay of the sequences);
  - for a palette, the end of the 16-colour palette (32 bytes of CGRAM) it
    ends in;
  - the end of the space: VRAM's $8000 words (the address wraps to 0), the
    end of the WRAM bank, the 512 bytes of palette_buffer, and for type 3 the
    $4000 words of Mode 7's 128x128 tilemap (low bytes) and 256 characters
    (high bytes; tile numbers are 8 bits).

If nothing but the end of WRAM bank $7E (or of the sound CPU's RAM) is found,
the capacity is not known: the limit is the original size.  These limits
are upper bounds: what the code writes elsewhere (VRAM by DMA from code,
WRAM buffers not in ram.inc) is only known where a register value or a
ram.inc label says so.

The limits are recorded in assets/manifest.txt (`max=`, hex) because they
depend on the original size (which blocks of other lists are inside it), and
an edited asset has lost that.  `python3 tools/assets.py limits --verify`
checks that each recorded limit is still what the source gives (derive() of
the limit itself), so a changed data list cannot leave a stale limit behind;
a limit set by hand has its reason in a `# limit: ...` comment on its line.
Three kinds of asset have a size that is fixed, with no `max=`:

  - an uncompressed sound block (load_spc_raw) with a number as its size
    word: that size (with a symbol, `<label>_size`, the assembler computes
    it from the data, and the block has a max= like a stream);
  - raw tiles read by td_tiles records (td_sprite_tiles_13 ...): $100 bytes
    past the record with the largest offset (stream_topdown_sprite_gfx;
    $80 for the second half of a frame of two 16x16 sprites, see
    td_tiles_reads);
  - a palette with `colours=N` in the manifest (gpl=colours: checked by
    tools/snespal.py).

A compressed stream must also stay in its bank: the decompressor reads it
with [LDR_SRC],y, which carries into the next bank, and in LoROM $xx:0000
is not the next bank's ROM.  ld65 enforces it (each bank is a memory area of
$8000 bytes); ld65_diagnosis() names the assets of a bank that overflows.
"""
import os
import re

VRAM_END = 0x10000          # bytes: $8000 words
MODE7_END = 0x4000          # words, one byte each
SPC_END = 0x10000
BANK_SIZE = 0x8000          # LoROM bank: $xx:8000-$xx:FFFF

PALETTE_BUFFER = 0x2200     # palette_buffer, $7E:2200 (ram.inc)
PALETTE_SIZE = 0x200        # CGRAM: 256 colours

SPACE_NAMES = {
    "cgram": "palette_buffer",
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
        elif macro.startswith("palette_fade"):
            self.label, self.dest = args[1], args[2]
        elif macro == "palette_copy":
            self.label, self.dest = args[0], args[1]
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
        if self.type == "palette":
            if PALETTE_BUFFER <= dest < PALETTE_BUFFER + PALETTE_SIZE:
                return "cgram", dest - PALETTE_BUFFER
            return None, None
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
            rel = os.path.relpath(path, os.path.dirname(srcdir.rstrip("/")) or ".")
            if macro == "load_list":
                cur = LoadList(label, _num(args[0]), _num(args[1]), rel, n)
                lists.append(cur)
            elif macro in ("load_vram", "load_wram", "load_spc", "load_spc_raw") and cur:
                cur.entries.append(Entry(cur, len(cur.entries), macro, args))
            elif macro == "load_end":
                cur = None
            # palette tasks (palette_tasks.asm): a palette_animate list of
            # palette_copy, or one fade
            elif macro == "palette_animate":
                cur = LoadList(label, "palette", 0, rel, n)
                lists.append(cur)
            elif macro == "palette_copy" and cur:
                cur.entries.append(Entry(cur, len(cur.entries), macro, args))
            elif macro == "palette_copy_end":
                cur = None
            elif macro in ("palette_fade_in", "palette_fade_out"):
                fade = LoadList(label, "palette", 0, rel, n)
                fade.entries.append(Entry(fade, 0, macro, args))
                lists.append(fade)
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
    """{label: bytes of it that the td_tiles records show} (each half of a
    record is $100 bytes, stream_topdown_sprite_gfx).  A record whose second
    half starts $80 after its first is a frame of two 16x16 sprites, $100
    bytes in all: the DMA still reads $100 from the second half, but its last
    $80 bytes go to tiles the frame does not show, so they need not be part
    of the block (td_tiles_07A3EA reads them past td_sprite_tiles_14; the
    td_tiles macro checks that they are in the bank)."""
    out = {}
    for path in _asm_files(srcdir):
        for line in open(path):
            code = line.split(";")[0].strip()
            if not code.startswith("td_tiles"):
                continue
            halves = []
            for half in code[len("td_tiles"):].split(","):
                m = re.fullmatch(r"\s*(\w+)\s*(?:\+\s*(\$[0-9A-Fa-f]+|\d+))?\s*", half)
                if m:
                    halves.append((m.group(1), _num(m.group(2)) if m.group(2) else 0))
            compact = (len(halves) == 2 and halves[0][0] == halves[1][0]
                       and halves[1][1] - halves[0][1] == 0x80)
            for k, (label, off) in enumerate(halves):
                end = off + (0x80 if compact and k == 1 else 0x100)
                out[label] = max(out.get(label, 0), end)
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


# The driver's code that sets the echo buffer's address (spc_driver.s, L11A1,
# called by echo_setup with the delay in A): ESA = base - delay x 8 pages.
ESA_CODE = re.compile(r"\tasl a\n\tasl a\n\tasl a\n\teor a, #\$FF\n\tinc a\n\tclrc\n"
                      r"\tadc a, #\$([0-9A-Fa-f]{2})\n\w*:?\n?\tmov y, #\$6D\n")
ECHO_SETUP = re.compile(r"^\s*echo_setup\s+\$([0-9A-Fa-f]{2})", re.M)


def echo_buffer(root):
    """(ARAM address, why) of the lowest start of the sound CPU's echo
    buffer, or None.  The DSP writes the echo there (ESA; EDL x 2 KiB,
    up to the end of ARAM), so nothing a list uploads may reach it.  The
    driver sets ESA from the delay of a sequence's echo_setup: ESA = base
    - delay x $800 (the code matched by ESA_CODE in spc_driver.s, base
    $00: the top of ARAM); the largest delay of any song or sound effect
    (any song can play over any stage's samples) gives the lowest start."""
    sound = os.path.join(root, "assets", "sound")
    try:
        code = open(os.path.join(sound, "spc_driver.s")).read()
    except OSError:
        return None
    m = ESA_CODE.search(code)
    if not m:
        return None
    base = int(m.group(1), 16)
    delays = {}
    for name in sorted(os.listdir(sound)):
        if name.endswith(".seq"):
            for d in ECHO_SETUP.findall(open(os.path.join(sound, name)).read()):
                delays.setdefault(int(d, 16), []).append(name)
    if not delays:
        return None
    delay = max(delays)
    files = sorted(set(delays[delay]))
    start = (((base - delay * 8) & 0xFF) << 8) if delay else 0x10000
    return start, (f"the echo buffer at ${start:04X} (the largest echo delay, {delay}: echo_setup "
                   f"in {files[0]}{' and %d more' % (len(files) - 1) if len(files) > 1 else ''}; "
                   f"the driver sets ESA to ${0x100 + base:03X}00 - delay x $800, spc_driver.s)")


class Source:
    """What the limits are derived from, read once."""

    def __init__(self, srcdir):
        self.echo = echo_buffer(os.path.dirname(os.path.abspath(srcdir)))
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
    if space == "cgram":
        return "$%04X" % (off + PALETTE_BUFFER)
    if space == "vram":
        return "$%04X" % (off // 2)
    if space.startswith("wram"):
        return "$%s:%04X" % (space[4:], off)
    return "$%04X" % off


class Limit:
    """note: set when the limit is the size it was derived from (the
    original reaches past what follows it, or the capacity is unknown): the
    source cannot tell a larger number from the original, so the manifest
    line must say so in a `# limit:` comment (record() writes it)."""

    def __init__(self, size, reason, known=True, note=None):
        self.size = size
        self.reason = reason
        self.known = known
        self.note = note

    def __repr__(self):
        return f"Limit(${self.size:X}, {self.reason!r})"


def derive_entry(src, entry, size, sizes):
    """The capacity (Limit) at one load of an asset of `size` bytes (its
    recorded limit, or its original size).  sizes: {label: size} of the
    other blocks (None if not known)."""
    lst = entry.list
    space, start = lst.space(entry)
    if space is None:
        return Limit(size, f"{entry.where} loads it to {entry.dest}, not a number or not in its space: "
                     "original size, capacity unknown", known=False,
                     note="original size, capacity unknown")
    # a palette block starts with its size-1 word, which is not copied
    head = 2 if space == "cgram" else 0
    full, size = size, size - head
    where = f"{entry.where} loads it to {SPACE_NAMES.get(space, 'WRAM')} {_fmt_addr(space, start)}"
    if space == "vram":
        end, end_why = VRAM_END, "the end of VRAM ($8000 words; the address wraps to $0000)"
    elif space in ("m7lo", "m7hi"):
        end = MODE7_END
        end_why = ("the end of the Mode 7 tilemap (128x128 entries, $4000 words)" if space == "m7lo"
                   else "the end of the Mode 7 characters (256 of 64 pixels, $4000 words)")
    elif space == "spc":
        end, end_why = SPC_END, None
    elif space == "cgram":
        end, end_why = PALETTE_SIZE, ("the end of palette_buffer ($7E:2400; CGRAM has 256 colours, "
                                      "and the VRAM loader's ring follows)")
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
        osize = osize - head if osize is not None else None
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
    if space == "cgram":
        row = -(-lim_end // 0x20) * 0x20
        if row < end:
            offer(row - start, f"the end of the 16-colour palette at ${row - 0x20 + PALETTE_BUFFER:04X} "
                  "(the next 32 bytes of CGRAM are another palette)")
    if space == "spc" and src.echo and src.echo[0] >= lim_end:
        offer(src.echo[0] - start, src.echo[1])
    if space.startswith("wram"):
        bank = int(space[4:], 16)
        for addr, name in src.ram:
            if addr >> 16 == bank and (addr & 0xFFFF) >= lim_end:
                offer((addr & 0xFFFF) - start, f"{name} (src/ram.inc) at {_fmt_addr(space, addr & 0xFFFF)}")
    cap, why = best
    if why is None:
        return Limit(full, f"{where}; nothing known after it: original size, capacity unknown",
                     known=False, note="original size, capacity unknown")
    if cap < size:
        return Limit(full, f"{where}; next: {why}, {cap} bytes after its start, which the "
                     f"original already reaches past (its last {size - cap} bytes): "
                     "it cannot grow", known=True,
                     note=f"original size, {_plural(size - cap, 'byte')} past "
                          f"{why.split(', which')[0].split(' (')[0]} (book: Assets, Size limits)")
    return Limit(cap + head, f"{where}; next: {why}"
                 + (" (plus the 2 bytes of its size word)" if head else ""))


def derive(src, label, size, sizes):
    """The limit of an asset (smallest over its loads), or None if it is
    not loaded by a data list."""
    best = None
    for e in src.by_label.get(label, []):
        if e.macro == "load_spc_raw" and e.size_word is not None:
            continue        # a fixed size (fixed_size)
        lim = derive_entry(src, e, size, sizes)
        if best is None or lim.size < best.size or (lim.size == best.size and best.note and not lim.note):
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
                   "or + $80 for a frame of two 16x16 sprites; stream_topdown_sprite_gfx)")
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
    """' (N tiles of FMT + T bytes)' for a PNG asset; ' (N metatiles)',
    ' (N pages)' ... for a level text (tools/levelmap.py)."""
    if getattr(asset, "level", None):
        import levelmap
        unit, name = levelmap.FORMATS[asset.level][1:]
        tail = len(bytes.fromhex(asset.options.get("tail", "")))
        whole, rest = divmod(n - tail, unit)
        extra = (f" + {rest} bytes" if rest else "") + (f" + {tail} tail" if tail else "")
        return f" ({_plural(whole, name)}{extra})"
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
    sizes = notes = None
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
                    notes = limit_notes(root)
                lim = derive(src, label, limit, sizes)
                why = lim.reason if lim else "not loaded by any data list: original size, capacity unknown"
                if a.path in notes and not _derived_note(notes[a.path]):
                    why = f"set by hand: {notes[a.path]} (the source gives: {why})"
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


def limit_notes(root):
    """{path: text} of the manifest lines with a `# limit: ...` comment: a
    max= set by hand, with the reason (book: Assets, raising a limit)."""
    out = {}
    path = os.path.join(root, "assets", "manifest.txt")
    for line in open(path):
        if "#" not in line:
            continue
        data, comment = line.split("#", 1)
        words = data.split()
        comment = comment.strip()
        if words and comment.startswith("limit:"):
            out[words[0]] = comment[len("limit:"):].strip()
    return out


def _derived_note(text):
    """A `# limit:` comment that record() wrote (the original size), not a
    reason given by hand."""
    return text.startswith("original size")


def needs_max(asset, src):
    """An asset whose limit depends on the original size, so it is
    recorded: a compressed stream, a palette block, or another block a list
    loads (an uncompressed sound block whose size the assembler computes)."""
    return (asset.compressed or asset.options.get("gpl") == "block"
            or (label_of(asset) in src.by_label and not fixed_size(src, label_of(asset))))


def verify(assets, root, srcdir):
    """Recorded limits that the source no longer gives, and compressed
    assets without one (messages)."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    notes = limit_notes(root)
    out = []
    for a in assets:
        label = label_of(a)
        if fixed_size(src, label) or (a.path in notes and "max" in a.options):
            continue
        if "max" not in a.options:
            if needs_max(a, src):
                out.append(f"{a.path}: no limit (max=) in the manifest: "
                           f"python3 tools/assets.py limits --record {a.path}")
            continue
        limit = parse_max(a.options["max"])
        lim = derive(src, label, limit, sizes)
        if lim is None:
            lim = Limit(limit, "not loaded by a data list", known=False,
                        note="original size, capacity unknown")
        if lim.size != limit:
            out.append(f"{a.path}: max=${limit:04X}, but the source gives ${lim.size:04X}: {lim.reason}")
        elif lim.note:
            out.append(f"{a.path}: max=${limit:04X} is only right if it is the original size ({lim.reason}); "
                       f"say so on its manifest line: `# limit: {lim.note}`")
    return out


def record(assets, root, srcdir):
    """Set max= on these assets from the source and their current size;
    returns (assets, {path: `# limit:` comment} where one is needed)."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    done, notes = [], {}
    for a in assets:
        n = data_size(a, root)
        lim = derive(src, label_of(a), n, sizes)
        a.options["max"] = "$%04X" % (lim.size if lim else n)
        note = lim.note if lim else "original size, capacity unknown (not loaded by a data list)"
        if note:
            notes[a.path] = "limit: " + note
        done.append(a)
    return done, notes


def report(assets, root, srcdir):
    """Lines: path, size, limit, room, where the limit comes from."""
    src = Source(srcdir)
    sizes = recorded_sizes(assets, root)
    notes = limit_notes(root)
    out = []
    for a in assets:
        label = label_of(a)
        n = data_size(a, root)
        fixed = fixed_size(src, label)
        if fixed:
            limit, why = fixed[0], "exactly: " + fixed[1]
        elif "colours" in a.options:
            limit = 2 * int(a.options["colours"])
            why = f"exactly: colours={a.options['colours']} in the manifest (tools/snespal.py checks it)"
        elif "max" in a.options:
            limit = parse_max(a.options["max"])
            lim = derive(src, label, limit, sizes)
            why = lim.reason if lim else "not loaded by a data list: original size, capacity unknown"
            if a.path in notes and not _derived_note(notes[a.path]):
                why = f"set by hand: {notes[a.path]} (the source gives ${lim.size:04X})" if lim else notes[a.path]
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
            # the spawn lists (tools/spawns.py): their text, its size in the ROM
            spawn = re.match(r'\s*\.include\s+"stages/(\w+)_spawns\.inc"', text)
            if spawn:
                out.setdefault(bank, []).append((f"assets/stages/{spawn.group(1)}.spawns", None))
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
            if path.endswith(".spawns"):
                import spawns
                size, orig = spawns.rom_size(path)
                grew = f" (original {orig:,}, {size - orig:+,})" if orig and size != orig else ""
                lines.append(f"    {path:36} {size:>8,}{grew}")
                continue
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
