#!/usr/bin/env python3
"""The side-view stages' spawn lists as text (book: Assets, Spawn lists).

A side-view stage places its enemies, items and triggers as BG1 scrolls
(init_stage_spawns, spawn_stage_objects): ptrs_stage_spawn_pages gives the
stage's page table, one pointer per 256-pixel page of the BG1 map, to a
list of 10-byte entries ended by the word $00FF:

    +0  byte  position in the page: the entry is spawned once the low byte
              of the scroll position reaches it (bg1_x; on a vertical
              stretch 256 - the low byte of bg1_y)
    +1  byte  OBJ_TYPE
    +2  byte  end of the slot range / $10   (exclusive)
    +3  byte  start of the slot range / $10 (find_free_object_slot_in_range)
    +4  word  x on the screen when the scroll is at the position
    +6  word  y on the screen
    +8  word  the object's field $3A (its parameter)

assets/stages/<name>.spawns holds a stage's page table and lists:

    level stage1_bg1                      the gallery's level preview to draw on
    table spawn_pages_059488              the label of the page table
    list spawn_list_0594C0 page 0         a list, its label, the pages using it
      10  OBJT_WEAPON_CAPSULE   -16  48  0006  300-780
      ...
      end                                 the terminator ($FF, $00)
    page 25 spawn_list_0597DA             a page using a list defined elsewhere

An entry line: position (hex), type (an OBJT_ constant of
src/object_types.inc, or $XX), x and y (signed decimal), parameter (hex
word), slot range (hex, start-end, end exclusive).  A list without `end`
runs on into the next one (`list - ` is a list with no label).  `#` starts
a comment.

The build makes build/assets/stages/<name>_spawns.inc (ca65 source: the
labels, the page table as .addr of the labels, the entries), which
src/data/tables_05.asm includes where the data was.

    python3 tools/spawns.py inc SPAWNS OUT        # the include for the build
    python3 tools/spawns.py build                 # every out-of-date include
    python3 tools/spawns.py check                 # parse, limits, text round trip
    python3 tools/spawns.py list [SPAWNS ...]     # entries with their map positions
    python3 tools/spawns.py extract ROM           # assets/stages/*.spawns from a ROM
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
STAGES = os.path.join("assets", "stages")
BUILD = os.path.join("build", "assets", "stages")
OBJECT_TYPES = os.path.join("src", "object_types.inc")
ENTRY = 10
# object slots: $0200-$02BF players and the low-priority pair ($0280,
# $02C0), $0300-$0ABF the 30 slots of update_objects (book: Objects)
SLOT_MIN, SLOT_END = 0x280, 0xAC0
# a BG1 map has at most 32 pages (book: Assets, Size limits)
MAX_PAGES = 32

# (stage, page table address, number of pages) of the original ROM, in the
# order of the data in bank $05; the label of a list is spawn_list_<addr>
ORIGINAL = [(1, 0x059488, 28), (3, 0x0597E6, 26), (6, 0x059C2E, 19)]
# the end of each stage's data in the original (stage 3's runs to the
# airship's list, airship_spawn_x)
ORIGINAL_END = {1: 0x0597E6, 3: 0x059BC8, 6: 0x059E42}
LEVELS = {1: "stage1_bg1", 3: "stage3_bg1", 6: "stage6_bg1"}


HEADER = """\
# Stage STAGE's spawn lists: the enemies, items and triggers of the side view,
# spawned as BG1 scrolls (tools/spawns.py; book: Assets, Spawn lists). The
# build makes them into build/assets/stages/stageSTAGE_spawns.inc, which
# src/data/tables_05.asm includes (bank $05). CDL: read by
# spawn_next_stage_object, find_free_object_slot_in_range; partly not accessed.
#
# `table LABEL`: the page table (ptrs_stage_spawn_pages[stage_number] points
# to it), one list per 256-pixel page of the BG1 map, from page 0 to the
# last page the stage scrolls to. `list LABEL page N[,N]` starts a list
# (`list -`: a list nothing points to); `page N LABEL`: page N uses a list
# defined in another file. `end` closes a list; a list without it runs on
# into the next. One entry per line, in the order they spawn (one a frame):
#
#   pos    hex 00-FE: spawned when the scroll is at the page's start + pos
#          (bg1_x); on a page whose next page is above it (a climb), when
#          bg1_y is at the page's top - pos. Must not go down in a list.
#   type   an OBJT_ constant of src/object_types.inc, or $XX
#   x y    signed decimal: where it appears on the screen at that scroll
#          (256: just past the right edge; -16 past the left)
#   param  hex word: its field $3A (the meaning depends on the type)
#   slots  hex START-END (END excluded): the object slots it may take, the
#          first free one. While none is free it waits; if its page is left
#          before then, the game freezes (book: Assets, Adding an enemy).
"""


class SpawnError(ValueError):
    pass


def object_types(root=ROOT):
    """({name: value}, {value: name}, {value: comment}) of src/object_types.inc
    (the first name of a value)."""
    names, by_value, notes = {}, {}, {}
    for line in open(os.path.join(root, OBJECT_TYPES)):
        m = re.match(r"\s*(OBJT_\w+)\s*=\s*\$([0-9A-Fa-f]+)\s*(?:;\s*(.*))?", line)
        if m:
            v = int(m.group(2), 16)
            names[m.group(1)] = v
            by_value.setdefault(v, m.group(1))
            notes.setdefault(v, (m.group(3) or "").strip())
    return names, by_value, notes


class Entry:
    def __init__(self, pos, type_, x, y, param, start, end, type_name=None, line=0):
        self.pos, self.type, self.x, self.y, self.param = pos, type_, x, y, param
        self.start, self.end = start, end
        self.type_name = type_name      # the OBJT_ name written, or None for $XX
        self.line = line

    def bytes(self):
        return bytes([self.pos, self.type, self.end >> 4, self.start >> 4]) + b"".join(
            (v & 0xFFFF).to_bytes(2, "little") for v in (self.x, self.y, self.param))

    @classmethod
    def from_bytes(cls, b, by_value):
        w = lambda i: b[i] | b[i + 1] << 8
        s = lambda v: v - 0x10000 if v >= 0x8000 else v
        return cls(b[0], b[1], s(w(4)), s(w(6)), w(8), b[3] << 4, b[2] << 4, by_value.get(b[1]))


class SpawnList:
    def __init__(self, label, pages, line=0):
        self.label = label              # None: no label
        self.pages = pages              # the pages of the table pointing to it
        self.entries = []
        self.terminated = False
        self.line = line

    def bytes(self):
        return b"".join(e.bytes() for e in self.entries) + (b"\xff\x00" if self.terminated else b"")


class Spawns:
    """A .spawns file: the page table and the lists, in the order of the
    data."""
    def __init__(self):
        self.level = None
        self.table = None
        self.lists = []
        self.refs = {}                  # page -> label of a list defined elsewhere
        self.comments = []              # the header (lines before `table`)

    def page_labels(self):
        """[label] of the page table, page 0 first."""
        pages = dict(self.refs)
        for lst in self.lists:
            for p in lst.pages:
                pages[p] = lst.label
        return [pages[p] for p in range(len(pages))]

    def list_for_page(self, page):
        """The SpawnList (with the lists it runs on into) of a page, or
        None if it is defined elsewhere."""
        for i, lst in enumerate(self.lists):
            if page in lst.pages:
                return self.lists[i:]
        return None

    def page_entries(self, page):
        """The entries spawned on a page (following a list that runs on
        into the next), or None for a list defined in another file."""
        lists = self.list_for_page(page)
        if lists is None:
            return None
        out = []
        for lst in lists:
            out += lst.entries
            if lst.terminated:
                break
        return out


def _num(word, what, path, n, signed=False, hexa=True, bits=16):
    try:
        v = int(word.lstrip("$"), 16) if hexa else int(word, 10)
    except ValueError:
        raise SpawnError(f"{path}:{n}: {what} {word!r} is not a {'hex' if hexa else 'decimal'} number")
    lo, hi = (-(1 << (bits - 1)), (1 << (bits - 1)) - 1) if signed else (0, (1 << bits) - 1)
    if not lo <= v <= hi:
        raise SpawnError(f"{path}:{n}: {what} {word} is out of range ({lo} to {hi})")
    return v


LABEL = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")


def parse(text, path="spawns", types=None):
    """A Spawns from the text of a .spawns file (SpawnError on a mistake)."""
    names = (types or object_types())[0]
    sp = Spawns()
    cur = None
    for n, raw in enumerate(text.splitlines(), 1):
        line = raw.split("#")[0].split()
        if not line:
            if sp.table is None and raw.startswith("#"):
                sp.comments.append(raw)
            continue
        key = line[0]
        if key == "level" and len(line) == 2:
            sp.level = line[1]
        elif key == "table" and len(line) == 2:
            if not LABEL.match(line[1]):
                raise SpawnError(f"{path}:{n}: {line[1]!r} is not a label")
            sp.table = line[1]
        elif key == "list":
            if len(line) not in (2, 4) or (len(line) == 4 and line[2] != "page"):
                raise SpawnError(f"{path}:{n}: expected `list LABEL [page N[,N...]]`")
            label = None if line[1] == "-" else line[1]
            if label is not None and not LABEL.match(label):
                raise SpawnError(f"{path}:{n}: {label!r} is not a label")
            pages = [_num(p, "page", path, n, hexa=False) for p in line[3].split(",")] if len(line) == 4 else []
            if pages and label is None:
                raise SpawnError(f"{path}:{n}: a list that pages use needs a label")
            if cur is not None and not cur.terminated and not cur.entries and cur.label is None:
                raise SpawnError(f"{path}:{n}: an empty list without a label")
            cur = SpawnList(label, pages, n)
            sp.lists.append(cur)
        elif key == "page":
            if len(line) != 3 or not LABEL.match(line[2]):
                raise SpawnError(f"{path}:{n}: expected `page N LABEL`")
            p = _num(line[1], "page", path, n, hexa=False)
            if p in sp.refs:
                raise SpawnError(f"{path}:{n}: page {p} is given twice")
            sp.refs[p] = line[2]
        elif key == "end":
            if cur is None or cur.terminated:
                raise SpawnError(f"{path}:{n}: `end` outside a list")
            cur.terminated = True
        else:
            if cur is None or cur.terminated:
                raise SpawnError(f"{path}:{n}: an entry outside a list (after `end`?)")
            if len(line) != 6:
                raise SpawnError(f"{path}:{n}: an entry is: position type x y parameter slots "
                                 f"(6 columns, got {len(line)})")
            pos = _num(line[0], "position", path, n, bits=8)
            if pos == 0xFF:
                raise SpawnError(f"{path}:{n}: position FF is the list's terminator; use 00-FE")
            tname = None
            if line[1].startswith("$"):
                typ = _num(line[1], "type", path, n, bits=8)
            elif line[1] in names:
                tname, typ = line[1], names[line[1]]
            else:
                raise SpawnError(f"{path}:{n}: unknown type {line[1]} (an OBJT_ constant of "
                                 f"{OBJECT_TYPES}, or $XX)")
            x = _num(line[2], "x", path, n, signed=True, hexa=False)
            y = _num(line[3], "y", path, n, signed=True, hexa=False)
            param = _num(line[4], "parameter", path, n)
            m = re.match(r"^\$?([0-9A-Fa-f]+)-\$?([0-9A-Fa-f]+)$", line[5])
            if not m:
                raise SpawnError(f"{path}:{n}: slots {line[5]!r}: expected START-END in hex (300-780)")
            start, end = int(m.group(1), 16), int(m.group(2), 16)
            for v in (start, end):
                if v % 0x10 or v > 0xFF0:
                    raise SpawnError(f"{path}:{n}: slot address {v:X}: a multiple of 10 up to FF0 "
                                     "(the entry stores it / $10 in a byte)")
            cur.entries.append(Entry(pos, typ, x, y, param, start, end, tname, n))
    _validate(sp, path)
    return sp


def _validate(sp, path):
    if sp.table is None:
        raise SpawnError(f"{path}: no `table LABEL` line")
    pages = dict(sp.refs)
    labels = {}
    for lst in sp.lists:
        if lst.label:
            if lst.label in labels or lst.label == sp.table:
                raise SpawnError(f"{path}:{lst.line}: label {lst.label} defined twice")
            labels[lst.label] = lst
        for p in lst.pages:
            if p in pages:
                raise SpawnError(f"{path}:{lst.line}: page {p} is given twice")
            pages[p] = lst.label
    for p, label in sp.refs.items():
        if label in labels:
            raise SpawnError(f"{path}: page {p}: {label} is a list of this file; "
                             f"add the page to its `list` line instead")
    missing = [p for p in range(len(pages)) if p not in pages]
    if missing or not pages:
        raise SpawnError(f"{path}: the page table has no list for page(s) "
                         f"{', '.join(map(str, missing)) or '0'}: every page from 0 to the last needs one")
    if len(pages) > MAX_PAGES:
        raise SpawnError(f"{path}: {len(pages)} pages, more than the {MAX_PAGES} of a BG1 map")
    if sp.lists and not sp.lists[-1].terminated:
        raise SpawnError(f"{path}:{sp.lists[-1].line}: the last list has no `end`")
    for lst in sp.lists:
        for e in lst.entries:
            if not (SLOT_MIN <= e.start < e.end <= SLOT_END) or e.start % 0x40 or e.end % 0x40:
                raise SpawnError(f"{path}:{e.line}: slots {e.start:03X}-{e.end:03X}: the range must "
                                 f"be within {SLOT_MIN:03X}-{SLOT_END:03X}, start below end, both "
                                 "slot addresses (multiples of 40)")
            if e.type == 0:
                raise SpawnError(f"{path}:{e.line}: type $00 is a free slot")
        prev = -1
        for e in lst.entries:
            if e.pos < prev:
                raise SpawnError(f"{path}:{e.line}: position {e.pos:02X} after {prev:02X}: the entries "
                                 "of a list are spawned in order, so their positions must not go down")
            prev = e.pos


def read(path, types=None):
    return parse(open(path).read(), path, types)


# ------------------------------------------------------------------ output

def text(sp, types=None, notes=True):
    """The .spawns text of a Spawns."""
    _names, by_value, comments = types or object_types()
    out = list(sp.comments)
    if sp.level:
        out.append(f"level {sp.level}")
    out += [f"table {sp.table}", ""]
    refs = dict(sp.refs)
    for lst in sp.lists:
        # the references to other files' lists come where the table has them
        for p in sorted(refs):
            if lst.pages and p < min(lst.pages):
                out += [f"page {p} {refs.pop(p)}", ""]
        head = f"list {lst.label or '-'}"
        if lst.pages:
            head += " page " + ",".join(map(str, lst.pages))
        if not lst.label:
            head += "    # not referenced"
        out.append(head)
        for e in lst.entries:
            tname = e.type_name or f"${e.type:02X}"
            row = (f"  {e.pos:02X}  {tname:34} {e.x:5d} {e.y:5d}  {e.param:04X}  "
                   f"{e.start:03X}-{e.end:03X}")
            note = comments.get(e.type, "") if notes else ""
            out.append(f"{row}  # {note}" if note else row)
        if lst.terminated:
            out.append("  end")
        else:
            out.append("  # (no end: runs on into the next list)")
        out.append("")
    for p in sorted(refs):
        out += [f"page {p} {refs[p]}", ""]
    return "\n".join(out).rstrip("\n") + "\n"


def inc(sp, source):
    """The ca65 source of a Spawns: labels, page table, entries."""
    out = [f"; Generated from {source} by tools/spawns.py: edit that file, not this one",
           "; (book: Assets, Spawn lists).", f"{sp.table}:"]
    labels = sp.page_labels()
    for i in range(0, len(labels), 4):
        out.append("\t.addr\t" + ", ".join(labels[i:i + 4]))
    prev = None
    for lst in sp.lists:
        if lst.label:
            out.append(f"{lst.label}:")
            if prev is not None and not prev.terminated:
                out.append(f"\t; LAYOUT: read on from {prev.label or 'the list before'} (it has no terminator)")
        for e in lst.entries:
            t = e.type_name or f"${e.type:02X}"
            out.append(f"\t.byte\t${e.pos:02X}, {t}, ${e.end >> 4:02X}, ${e.start >> 4:02X}")
            out.append(f"\t.word\t${e.x & 0xFFFF:04X}, ${e.y & 0xFFFF:04X}, ${e.param:04X}")
        if lst.terminated:
            out.append("\t.byte\t$FF, $00")
        prev = lst
    return "\n".join(out) + "\n"


def table_bytes(sp):
    """The bytes of the lists (not the page table), in order."""
    return b"".join(lst.bytes() for lst in sp.lists)


def size(sp):
    """Bytes in the ROM: the page table and the lists."""
    return 2 * len(sp.page_labels()) + len(table_bytes(sp))


def files(root=ROOT):
    d = os.path.join(root, STAGES)
    if not os.path.isdir(d):
        return []
    return sorted(os.path.join(STAGES, f) for f in os.listdir(d) if f.endswith(".spawns"))


def inc_path(spawns_path):
    name = os.path.basename(spawns_path)[:-len(".spawns")]
    return os.path.join(BUILD, name + "_spawns.inc")


def _mtime(p):
    try:
        return os.stat(p).st_mtime
    except FileNotFoundError:
        return None


def build(root=ROOT, quiet=True):
    """Write every out-of-date include; returns how many."""
    n = 0
    deps = [os.path.join(root, "tools", "spawns.py"), os.path.join(root, OBJECT_TYPES)]
    for f in files(root):
        out = os.path.join(root, inc_path(f))
        t = _mtime(out)
        if t is not None and all((_mtime(d) or 0) <= t for d in deps + [os.path.join(root, f)]):
            continue
        write_inc(os.path.join(root, f), out, f)
        n += 1
        if not quiet:
            print(f"{inc_path(f)}: from {f}")
    return n


def write_inc(src, out, name=None):
    try:
        sp = read(src)
    except SpawnError as e:
        sys.exit(str(e))
    os.makedirs(os.path.dirname(out), exist_ok=True)
    tmp = out + ".tmp"
    open(tmp, "w").write(inc(sp, name or src))
    os.replace(tmp, out)


# --------------------------------------------------------------- positions

def placements(sp, route, up=()):
    """[(entry, page, world_x, world_y, scroll_x, scroll_y, vertical)] of the
    entries of the pages of a preview route (tools/levelmap.page_positions),
    in pixels of that picture: where the object is when it spawns, and the
    top-left of the screen then.  On a page whose next page is drawn above it
    (a vertical stretch) the screen climbs: the entry spawns when bg1_y is
    the page's top minus its position; elsewhere when bg1_x is the page's left
    plus its position (init_stage_spawns, spawn_next_stage_object; traced in
    the plays: the list of page N is the one used while BG1's page is N)."""
    import levelmap
    route = list(route)
    where = levelmap.page_positions(route, set(up))
    out = []
    for i, p in enumerate(route):
        entries = sp.page_entries(p) if p < len(sp.page_labels()) else None
        if not entries:
            continue
        col, row = where[p]
        vertical = i + 1 < len(route) and route[i + 1] in up
        for e in entries:
            if vertical:
                sx, sy = col * 256, row * 256 - e.pos
            else:
                sx, sy = col * 256 + e.pos, row * 256
            out.append((e, p, sx + e.x, sy + e.y, sx, sy, vertical))
    return out


# ------------------------------------------------------------- the gallery

# 3x5 glyphs, drawn twice their size
GLYPHS = {
    "A": "010101111101101", "B": "110101110101110", "C": "011100100100011",
    "D": "110101101101110", "E": "111100110100111", "F": "111100110100100",
    "G": "011100101101011", "H": "101101111101101", "I": "111010010010111",
    "J": "001001001101010", "K": "101101110101101", "L": "100100100100111",
    "M": "101111111101101", "N": "110101101101101", "O": "010101101101010",
    "P": "110101110100100", "Q": "010101101110011", "R": "110101110101101",
    "S": "011100010001110", "T": "111010010010010", "U": "101101101101111",
    "V": "101101101101010", "W": "101101111111101", "X": "101101010101101",
    "Y": "101101010010010", "Z": "111001010100111", "0": "111101101101111",
    "1": "010110010010111", "2": "110001010100111", "3": "110001010001110",
    "4": "101101111001001", "5": "111100110001110", "6": "011100111101111",
    "7": "111001010010010", "8": "111101111101111", "9": "111101111001110",
    "_": "000000000000111", "-": "000000111000000", "$": "011110010011110",
    " ": "000000000000000", ":": "000010000010000",
}
SCALE = 2
ADVANCE = 4 * SCALE
LINE = 6 * SCALE + 2
# palette entries the markers use (a side-view preview uses colours 0-127)
INK, OBJECT, TRIGGER = 253, 254, 255
COLOURS = {INK: (0, 0, 0), OBJECT: (255, 240, 0), TRIGGER: (0, 230, 255)}


def label_of(e):
    name = e.type_name[5:] if e.type_name and e.type_name.startswith("OBJT_") else f"TYPE ${e.type:02X}"
    return f"{name} {e.param:04X}" if e.param else name


def is_trigger(e):
    return bool(e.type_name) and e.type_name.endswith("_TRIGGER")


def draw(W, H, pixels, pal, sp, route, up=()):
    """Draw the spawns of `sp` on a route picture (W x H, 8-bit pixels):
    an object as a box at the place it spawns with its type and parameter;
    a trigger as a line at the screen's edge where it fires (the left edge,
    the top on a vertical stretch).  Returns (W, H, pixels, palette)."""
    px = bytearray(pixels)
    pal = list(pal) + [(0, 0, 0)] * (256 - len(pal))
    for i, c in COLOURS.items():
        pal[i] = c

    def put(x, y, c):
        if 0 <= x < W and 0 <= y < H:
            px[y * W + x] = c

    def rect(x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            a, b = max(0, x0), min(W, x1)
            if a < b:
                px[y * W + a:y * W + b] = bytes([c]) * (b - a)

    def text_at(x, y, s, c):
        rect(x - 1, y - 1, x + ADVANCE * len(s) + 1, y + 5 * SCALE + 1, INK)
        for k, ch in enumerate(s):
            g = GLYPHS.get(ch, GLYPHS[" "])
            for r in range(5):
                for q in range(3):
                    if g[r * 3 + q] == "1":
                        rect(x + k * ADVANCE + q * SCALE, y + r * SCALE,
                             x + k * ADVANCE + (q + 1) * SCALE, y + (r + 1) * SCALE, c)

    boxes = []

    def place(x, y, w):
        """A free spot for a label of width w near (x, y)."""
        for k in range(12):
            yy = y + k * LINE
            if not any(x < bx1 and bx0 < x + w and yy < by1 and by0 < yy + LINE for bx0, by0, bx1, by1 in boxes):
                break
        boxes.append((x, yy, x + w, yy + LINE))
        return yy

    for e, _page, x, y, sx, sy, vertical in placements(sp, route, up):
        s = label_of(e)
        if is_trigger(e):
            if vertical:
                for xx in range(sx, sx + 256, 4):
                    rect(xx, sy, xx + 2, sy + 2, TRIGGER)
                text_at(sx + 4, place(sx + 4, sy + 4, ADVANCE * len(s)), s, TRIGGER)
            else:
                for yy in range(sy, sy + 224, 4):
                    rect(sx, yy, sx + 2, yy + 2, TRIGGER)
                text_at(sx + 4, place(sx + 4, sy + 4, ADVANCE * len(s)), s, TRIGGER)
            continue
        for d in range(-4, 5):
            for c, v in ((INK, 1), (OBJECT, 0)):
                put(x + d, y - 4 - v, c); put(x + d, y + 4 + v, c)
                put(x - 4 - v, y + d, c); put(x + 4 + v, y + d, c)
        text_at(x + 7, place(x + 7, y - 2, ADVANCE * len(s)), s, OBJECT)
    return W, H, bytes(px), pal


def for_level(name, root=ROOT):
    """The Spawns whose `level` line names this level preview, or None."""
    for f in files(root):
        sp = read(os.path.join(root, f))
        if sp.level == name:
            return f, sp
    return None


# ------------------------------------------------------------- extraction

def extract(rom, types=None):
    """{stage: Spawns} of the original ROM (one-time conversion)."""
    types = types or object_types()
    _names, by_value, _notes = types

    def rd(a, n):
        return rom[(a >> 16) * 0x8000 + (a & 0x7FFF):][:n]

    def word(a):
        b = rd(a, 2)
        return 0x050000 | b[0] | b[1] << 8

    out = {}
    starts = {}
    for stage, table, pages in ORIGINAL:
        ptrs = [word(table + 2 * k) for k in range(pages)]
        mine = {p for p in ptrs if table < p < ORIGINAL_END[stage]}
        sp = Spawns()
        sp.table = f"spawn_pages_{table:06X}"
        sp.level = LEVELS[stage]
        sp.comments = [line.replace("STAGE", str(stage)) for line in HEADER.splitlines()]
        for k, p in enumerate(ptrs):
            if p not in mine:
                sp.refs[k] = f"spawn_list_{p:06X}"
        # walk the data: lists start at a pointed address, or after a
        # terminator (an unreferenced list)
        a, end = table + 2 * pages, ORIGINAL_END[stage]
        cur = None
        while a < end:
            if a in mine or cur is None or cur.terminated:
                if cur is not None and not cur.terminated and a not in mine:
                    raise SpawnError(f"{a:06X}: inside a list")
                label = f"spawn_list_{a:06X}" if a in mine else None
                cur = SpawnList(label, [k for k, p in enumerate(ptrs) if p == a])
                sp.lists.append(cur)
            if rd(a, 1)[0] == 0xFF:
                if rd(a + 1, 1)[0] != 0:
                    raise SpawnError(f"{a:06X}: terminator $FF not followed by $00")
                cur.terminated = True
                a += 2
                continue
            cur.entries.append(Entry.from_bytes(rd(a, ENTRY), by_value))
            a += ENTRY
        out[stage] = sp
        starts[stage] = table
    return out


def main(argv):
    os.chdir(ROOT)
    cmd = argv[1] if len(argv) > 1 else "check"
    if cmd == "inc" and len(argv) == 4:
        write_inc(argv[2], argv[3], argv[2])
    elif cmd == "build":
        build(quiet=False)
    elif cmd == "extract" and len(argv) == 3:
        rom = open(argv[2], "rb").read()
        types = object_types()
        os.makedirs(STAGES, exist_ok=True)
        for stage, sp in extract(rom, types).items():
            path = os.path.join(STAGES, f"stage{stage}.spawns")
            open(path, "w").write(text(sp, types))
            print(f"{path}: {len(sp.page_labels())} pages, {sum(len(l.entries) for l in sp.lists)} entries")
    elif cmd == "check":
        types = object_types()
        bad = 0
        for f in files():
            try:
                sp = read(f, types)
            except SpawnError as e:
                print(e)
                bad += 1
                continue
            again = parse(text(sp, types), f, types)
            if inc(again, f) != inc(sp, f):
                print(f"{f}: the text does not read back the same")
                bad += 1
            n = sum(len(lst.entries) for lst in sp.lists)
            print(f"{f}: {len(sp.page_labels())} pages, {n} entries, {size(sp)} bytes")
        return 1 if bad else 0
    elif cmd == "list":
        import assets
        levels = dict(assets.read_levels())
        for f in argv[2:] or files():
            sp = read(f)
            view = levels.get(sp.level, {})
            route = assets.page_list(view["route"]) if "route" in view else range(len(sp.page_labels()))
            up = assets.page_list(view.get("up", ""))
            print(f"{f} (on {sp.level}; picture pixels, screen top-left when spawned)")
            for e, p, x, y, sx, sy, v in placements(sp, route, up):
                print(f"  page {p:2} {e.pos:02X} {label_of(e):34} at {x:5},{y:5}  screen {sx:5},{sy:5}"
                      + (" (climbing)" if v else ""))
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
