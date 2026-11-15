#!/usr/bin/env python3
"""Rename symbols across the source and the book.

    python3 tools/rename.py OLD NEW [OLD NEW ...]   rename one or more symbols
    python3 tools/rename.py --map FILE              rename every pair in FILE
    python3 tools/rename.py --scope LABEL @old @new rename a cheap local label
    options: -n / --dry-run (show what would change, write nothing)

A mapping file has one "OLD NEW" pair per line; blank lines and text after
'#' are ignored.  All pairs are checked first and applied together (a batch
is all or nothing), so pairs may even swap names.

What is renamed: every whole-word occurrence (letters, digits, '_' and '@'
count as word characters; a name inside a path such as src/engine/nmi.asm is
left alone) in src/**/*.asm, *.inc and *.cfg, comments
included (CDL comments such as "read by sub_X" name routines), and in the
`code spans` and fenced code blocks of book/src/*.md and README.md (never
in their prose).  A name that could be an English word (no '_' and no
digit, e.g. "reset") is only renamed in the code part of source lines, not
in comments.  tools/disasm_hints.json (the generator's hints) and
docs/disasm_report.md (the generator's report, a record of the CDL pass) are
not touched.

Refused, with nothing written:
  * OLD is not defined in src/ (a label "OLD:", a constant "OLD = ...",
    ".define OLD" ...);
  * NEW is not a valid ca65 identifier, is a 65816 mnemonic or a register
    name (a, x, y, s, z, f), or a cheap local name for a global (or the
    other way round);
  * NEW already appears as a word anywhere in src/ or in the code of the
    book or README.md (a collision), unless it is itself renamed away in the
    same batch; mentions in the book of names listed in book/names-ignore.txt
    (made-up examples, old names) don't count;
  * the same OLD twice, or two OLDs to the same NEW.

Cheap local labels (@name) are only valid between two normal labels in
ca65, so they are renamed only inside the scope of the normal label given
with --scope, and only in src/.

After renaming: make (the hash must still match) and make book-check.
"""

import argparse
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
WORD = r"[A-Za-z0-9_@]"
IDENT = re.compile(r"^[A-Za-z_][A-Za-z0-9_]*$")
LOCAL = re.compile(r"^@[A-Za-z_][A-Za-z0-9_]*$")
MNEMONICS = set("""
adc and asl bcc bcs beq bit bmi bne bpl bra brk brl bvc bvs clc cld cli clv cmp cop cpx cpy
dec dex dey eor inc inx iny jml jmp jsl jsr lda ldx ldy lsr mvn mvp nop ora pea pei per pha
phb phd phk php phx phy pla plb pld plp plx ply rep rol ror rti rtl rts sbc sec sed sei sep
sta stp stx sty stz tax tay tcd tcs tdc trb tsb tsc tsx txa txs txy tya tyx wai wdm xba xce
""".split())
REGISTERS = {"a", "x", "y", "s", "z", "f"}
DEFINITION = [
    r"^\s*{n}\s*:(?!=)",                  # label:
    r"^\s*{n}\s*:?=(?!=)",                # name = / name :=
    r"^\s*{n}\s+\.set\b",
    r"\.define\s+{n}\b",
    r"\.(?:macro|mac|proc|scope|struct|enum|union)\s+{n}\b",
]
NORMAL_LABEL = re.compile(r"^([A-Za-z_]\w*)\s*:(?!=)")


def source_files():
    src = ROOT / "src"
    return sorted(p for p in src.rglob("*") if p.suffix in (".asm", ".inc", ".cfg"))


def text_files():
    return sorted((ROOT / "book" / "src").glob("*.md")) + [ROOT / "README.md"]


def word_re(names):
    alt = "|".join(re.escape(n) for n in sorted(names, key=len, reverse=True))
    # '/' and '.' around a name mean a path or a file name (engine/nmi.asm)
    return re.compile(rf"(?<![A-Za-z0-9_@./])(?:{alt})(?![A-Za-z0-9_@/]|\.[A-Za-z])")


FENCE = re.compile(r"(```.*?```|`[^`\n]*`)", re.S)


def plain_word(name):
    return not re.search(r"[_0-9]", name)


def sub_in(path, text, r, repl, old_names):
    """Apply r (repl) where renames are allowed in this file; return (text, n)."""
    if path.suffix == ".md":
        total = 0
        def code(m):
            nonlocal total
            t, n = r.subn(repl, m.group(0))
            total += n
            return t
        return FENCE.sub(code, text), total
    if not any(plain_word(o) for o in old_names):
        return r.subn(repl, text)
    total = 0
    out = []
    for line in text.split("\n"):
        code, sep, comment = line.partition(";")
        t, n = r.subn(repl, code)
        # names with '_' or digits are renamed in comments too
        r2 = word_re([o for o in old_names if not plain_word(o)]) if any(not plain_word(o) for o in old_names) else None
        if r2 and sep:
            comment, n2 = r2.subn(repl, comment)
            n += n2
        total += n
        out.append(t + sep + comment)
    return "\n".join(out), total


def is_defined(name, texts):
    pats = [re.compile(p.format(n=re.escape(name)), re.I if "\\." in p else 0) for p in DEFINITION]
    for text in texts.values():
        for line in text.splitlines():
            code = line.split(";", 1)[0]
            if any(p.search(code) for p in pats):
                return True
    return False


def check_new(old, new, errors):
    if LOCAL.match(old):
        if not LOCAL.match(new):
            errors.append(f"{new}: a cheap local label must be renamed to @name")
            return
        bare = new[1:]
    else:
        if not IDENT.match(new):
            errors.append(f"{new}: not a valid ca65 identifier (or a cheap local name for a global)")
            return
        bare = new
    if bare.lower() in MNEMONICS or bare.lower() in REGISTERS:
        errors.append(f"{new}: reserved (a 65816 mnemonic or a register name)")


def rename_global(pairs, dry_run):
    files = source_files() + text_files()
    texts = {p: p.read_text() for p in files}
    src_texts = {p: t for p, t in texts.items() if p.suffix != ".md"}
    errors = []
    ignore_file = ROOT / "book" / "names-ignore.txt"
    ignored = {l.split("#", 1)[0].strip() for l in ignore_file.read_text().splitlines()} if ignore_file.exists() else set()
    olds = [o for o, _ in pairs]
    news = [n for _, n in pairs]
    for dup in {o for o in olds if olds.count(o) > 1}:
        errors.append(f"{dup}: renamed twice")
    for dup in {n for n in news if news.count(n) > 1}:
        errors.append(f"{dup}: target of two renames")
    renamed_away = set(olds)
    for old, new in pairs:
        if LOCAL.match(old):
            errors.append(f"{old}: cheap local label; use --scope LABEL")
            continue
        if old == new:
            errors.append(f"{old}: same name")
            continue
        check_new(old, new, errors)
        if not is_defined(old, src_texts):
            errors.append(f"{old}: not defined in src/")
        if new not in renamed_away:
            r = word_re([new])
            hits = []
            for p, t in texts.items():
                if p.suffix == ".md" and new in ignored:
                    continue   # an intentional mention (example, old name), see book/names-ignore.txt
                scan = FENCE.findall(t) if p.suffix == ".md" else [t]
                if any(r.search(x) for x in scan):
                    hits.append(str(p.relative_to(ROOT)))
            if hits:
                errors.append(f"{new}: already used ({', '.join(hits[:5])}{' ...' if len(hits) > 5 else ''})")
    if errors:
        print("rename: refused, nothing written:", file=sys.stderr)
        for e in errors:
            print("  " + e, file=sys.stderr)
        return 1
    mapping = dict(pairs)
    r = word_re(mapping)
    total = 0
    for p, t in texts.items():
        new_t, n = sub_in(p, t, r, lambda m: mapping[m.group(0)], list(mapping))
        if n:
            total += n
            print(f"{p.relative_to(ROOT)}: {n}")
            if not dry_run:
                p.write_text(new_t)
    print(f"{len(pairs)} symbol(s), {total} occurrence(s){' (dry run)' if dry_run else ''}")
    print("now: make && make book-check")
    return 0


def rename_local(scope, old, new, dry_run):
    errors = []
    if not LOCAL.match(old):
        errors.append(f"{old}: --scope is for cheap local labels (@name)")
    check_new(old, new, errors)
    hits = []
    for p in source_files():
        lines = p.read_text().split("\n")
        start = next((i for i, l in enumerate(lines)
                      if (m := NORMAL_LABEL.match(l)) and m.group(1) == scope), None)
        if start is None:
            continue
        end = next((i for i in range(start + 1, len(lines)) if NORMAL_LABEL.match(lines[i])), len(lines))
        hits.append((p, lines, start, end))
    if len(hits) != 1:
        errors.append(f"{scope}: normal label defined {len(hits)} times in src/ (need exactly 1)")
    if errors:
        print("rename: refused, nothing written:", file=sys.stderr)
        for e in errors:
            print("  " + e, file=sys.stderr)
        return 1
    p, lines, start, end = hits[0]
    body = "\n".join(lines[start:end])
    if not re.search(rf"^\s*{re.escape(old)}\s*:", body, re.M):
        print(f"rename: refused: {old} is not defined in the scope of {scope}", file=sys.stderr)
        return 1
    if word_re([new]).search(body):
        print(f"rename: refused: {new} is already used in the scope of {scope}", file=sys.stderr)
        return 1
    body, n = word_re([old]).subn(new, body)
    print(f"{p.relative_to(ROOT)}: {n}{' (dry run)' if dry_run else ''}")
    if not dry_run:
        p.write_text("\n".join(lines[:start] + body.split("\n") + lines[end:]))
    return 0


def read_map(path):
    pairs = []
    for i, line in enumerate(Path(path).read_text().splitlines(), 1):
        line = line.split("#", 1)[0].strip()
        if not line:
            continue
        parts = line.split()
        if len(parts) != 2:
            sys.exit(f"{path}:{i}: expected 'OLD NEW'")
        pairs.append(tuple(parts))
    return pairs


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("names", nargs="*", help="OLD NEW pairs")
    ap.add_argument("--map", help="file of OLD NEW lines")
    ap.add_argument("--scope", help="normal label whose cheap locals to rename")
    ap.add_argument("-n", "--dry-run", action="store_true")
    a = ap.parse_args()
    if len(a.names) % 2:
        ap.error("names must come in OLD NEW pairs")
    pairs = list(zip(a.names[::2], a.names[1::2]))
    if a.map:
        pairs += read_map(a.map)
    if not pairs:
        ap.error("nothing to rename")
    if a.scope:
        if len(pairs) != 1:
            ap.error("--scope renames one cheap local at a time")
        return rename_local(a.scope, *pairs[0], a.dry_run)
    return rename_global(pairs, a.dry_run)


if __name__ == "__main__":
    sys.exit(main())
