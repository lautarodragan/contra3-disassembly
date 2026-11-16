#!/usr/bin/env python3
"""SNES palettes <-> GIMP palette files (.gpl), exactly (book: Assets).

A SNES colour is a BGR555 word: bits 0-4 red, 5-9 green, 10-14 blue; bit 15
is unused by the PPU but kept.  A .gpl file is a GIMP palette (GIMP,
Aseprite, Krita, Inkscape and others read and write it): one colour per
line, "R G B<tab>NAME".  This tool writes the exact word as the name:

    GIMP Palette
    Name: palette_088022
    Columns: 16
    #
      0   0   0	$0000
    255 255 255	$7FFF

and reads a line back as:

  - the word of its name, if the name is a word ($XXXX) and R G B is that
    word's colour (so the word, bit 15 included, comes back exactly);
  - else the colour R G B, each component >> 3 (an edited colour: an
    editor that changes R G B keeps the old name).  A component whose
    low 3 bits are not those of a SNES colour is rounded down; `normalize`
    rewrites the file with the words.

A colour component c (0-31) is shown as c << 3 | c >> 2 (0, 8, ... 255), so
that 31 is white.

Layouts (how the colours sit in the ROM):

    block    a size-1 word, then the colours (the palette blocks of bank
             $08 that the palette tasks copy: palette_task_animate,
             palette_task_fade_in)
    colours  the colours alone

    python3 tools/snespal.py togpl LAYOUT IN.bin OUT.gpl [--name NAME]
    python3 tools/snespal.py fromgpl LAYOUT IN.gpl OUT.bin
    python3 tools/snespal.py normalize FILE.gpl ...

Library: write_gpl(path, words, name), read_gpl(path) -> words,
to_bytes(words, layout), from_bytes(data, layout) -> words, rgb(word).
"""
import argparse
import os
import re
import sys

LAYOUTS = ("block", "colours")
HEADER = "GIMP Palette"


def rgb(word):
    """(r, g, b), 0-255, of a BGR555 word (bit 15 ignored)."""
    return tuple(c << 3 | c >> 2 for c in (word & 31, word >> 5 & 31, word >> 10 & 31))


def word_of_rgb(r, g, b):
    return (r >> 3) | (g >> 3) << 5 | (b >> 3) << 10


def from_bytes(data, layout):
    """The colour words of a palette as the ROM holds it."""
    if layout == "block":
        size = data[0] | data[1] << 8
        if size + 3 != len(data) or size % 2 == 0:
            raise ValueError(f"palette block of {len(data)} bytes with size word ${size:04X}")
        data = data[2:]
    elif layout != "colours":
        raise ValueError(f"layout {layout}: one of {', '.join(LAYOUTS)}")
    if len(data) % 2:
        raise ValueError(f"{len(data)} bytes: not a whole number of colours")
    return [data[i] | data[i + 1] << 8 for i in range(0, len(data), 2)]


def to_bytes(words, layout):
    out = bytearray()
    if layout == "block":
        if not words:
            raise ValueError("a palette block needs at least one colour")
        out += (2 * len(words) - 1).to_bytes(2, "little")
    elif layout != "colours":
        raise ValueError(f"layout {layout}: one of {', '.join(LAYOUTS)}")
    for w in words:
        out += w.to_bytes(2, "little")
    return bytes(out)


def gpl_text(words, name, comment=None):
    lines = [HEADER, f"Name: {name}", "Columns: 16"]
    for c in (comment or "").splitlines():
        lines.append(("# " + c).rstrip())
    lines.append("#")
    for w in words:
        r, g, b = rgb(w)
        lines.append(f"{r:3} {g:3} {b:3}\t${w:04X}")
    return "\n".join(lines) + "\n"


def write_gpl(path, words, name=None, comment=None):
    name = name or os.path.splitext(os.path.basename(path))[0]
    with open(path, "w", newline="\n") as f:
        f.write(gpl_text(words, name, comment))


COLOUR_RE = re.compile(r"^\s*(\d+)\s+(\d+)\s+(\d+)(?:\s+(.*?))?\s*$")


def parse_gpl(text, path="palette"):
    """[(word, exact)] of a .gpl text: exact is False for a colour taken
    from R G B that is not a SNES colour, or whose name is not its word."""
    lines = text.splitlines()
    if not lines or lines[0].strip() != HEADER:
        raise ValueError(f"{path}: not a GIMP palette (first line {HEADER!r})")
    out = []
    for n, line in enumerate(lines[1:], 2):
        s = line.strip()
        if not s or s.startswith("#") or re.match(r"^(Name|Columns):", s):
            continue
        m = COLOUR_RE.match(line)
        if not m:
            raise ValueError(f"{path}:{n}: not a colour line (R G B [name]): {line!r}")
        r, g, b = (int(v) for v in m.group(1, 2, 3))
        if max(r, g, b) > 255:
            raise ValueError(f"{path}:{n}: component over 255")
        name = (m.group(4) or "").strip()
        w = re.fullmatch(r"\$([0-9A-Fa-f]{4})", name)
        if w and rgb(int(w.group(1), 16)) == (r, g, b):
            out.append((int(w.group(1), 16), True))
        else:
            word = word_of_rgb(r, g, b)
            out.append((word, rgb(word) == (r, g, b) and name == f"${word:04X}"))
    return out


def read_gpl(path):
    """The colour words of a .gpl file."""
    return [w for w, _exact in parse_gpl(open(path).read(), path)]


def normalize(path):
    """Rewrite a .gpl file in the form write_gpl gives, keeping its name and
    comments; returns True if it changed."""
    text = open(path).read()
    words = read_gpl(path)
    name = os.path.splitext(os.path.basename(path))[0]
    comment = []
    for line in text.splitlines()[1:]:
        s = line.strip()
        if s.startswith("Name:"):
            name = s[5:].strip()
        elif s.startswith("#") and not COLOUR_RE.match(line):
            if s != "#":
                comment.append(s[1:].strip())
    new = gpl_text(words, name, "\n".join(comment))
    if new != text:
        with open(path, "w", newline="\n") as f:
            f.write(new)
        return True
    return False


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("cmd", choices=["togpl", "fromgpl", "normalize"])
    ap.add_argument("args", nargs="+")
    ap.add_argument("--name")
    a = ap.parse_args(argv)
    if a.cmd == "normalize":
        for p in a.args:
            if normalize(p):
                print(f"{p}: rewritten")
        return 0
    layout, src, dst = a.args
    if a.cmd == "togpl":
        write_gpl(dst, from_bytes(open(src, "rb").read(), layout), a.name)
    else:
        open(dst, "wb").write(to_bytes(read_gpl(src), layout))
    return 0


if __name__ == "__main__":
    sys.exit(main())
