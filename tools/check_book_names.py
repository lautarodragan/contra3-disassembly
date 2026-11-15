#!/usr/bin/env python3
"""Check that the book only names symbols and files that exist.

    python3 tools/check_book_names.py      (or: make book-check)

Every `code span` and fenced code block in book/src/**/*.md is scanned for
things that look like code names, and every code span for paths into the repo:

  * generated labels (`sub_0090A8`, `loc_`, `tbl_`, `ptrs_`, `data_` + six hex
    digits), which disappear as routines get real names, must be defined in
    src/;
  * other identifiers that look like names: `snake_case` with an underscore,
    `CamelCase`, upper-case constants of four or more characters (`INIDISP`,
    `NMITIMEN`, `FOO_BAR`; three-letter ones are mostly mnemonics and are not
    checked). Each must be a symbol defined in the ca65 sources, or appear in
    tools/, the Makefile or the workflows (script, function, make variable,
    hint field names);
  * a name ending in `_` (`sub_`) is a family: some symbol must start with it;
  * paths (`src/main.asm`, `tools/`, `docs/disasm_report.md`) must be tracked
    files or directories (or files the build makes, see GENERATED); bare file
    names (`bank_00.asm`) must be the name of a tracked file.

Symbols defined in the ca65 sources (src/**/*.asm, *.inc, *.cfg) are:
labels (`name:`, also cheap locals `@name:`), constants (`name = ...`,
`name := ...`, `.set`), `.define`, `.macro`, `.proc`, `.scope`, `.struct`,
`.enum`, `.union` names, segment names (`.segment "BANK00"`), and the
MEMORY/SEGMENTS names of the ld65 config.

Lower-case words without an underscore (`reset`, `nmi`) cannot be told apart
from English and are not checked, nor are `.directives` or `$addresses`.

Names and paths a page mentions on purpose although the repository doesn't
have them (old names next to new ones, history, made-up examples, files in
other repositories) go in
book/names-ignore.txt, one per line.

Exits non-zero, listing page:line and the name, when something is missing.
"""

import bisect
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BOOK = ROOT / "book" / "src"
IGNORE_FILE = ROOT / "book" / "names-ignore.txt"

# files and directories the build makes, which a fresh checkout doesn't have
GENERATED = {"build", "build/contra3.sfc", "build/contra3.map", "build/contra3.lbl",
             "build/main.o", "book/book"}

AUTO_LABEL = re.compile(r"^(?:sub|loc|tbl|ptrs|data)_[0-9A-F]{6}$")
IDENT = re.compile(r"@?[A-Za-z_][A-Za-z0-9_]*")
PATH = re.compile(r"^(?:src|tools|docs|book|build|\.github)(?:/[\w./*-]*)?$|^[\w.-]+(?:/[\w.*-]+)+\.\w+$")
FILE = re.compile(r"^[\w.-]+\.(?:asm|inc|cfg|py|json|md|yml|toml|txt|sha1)$")

# ca65 definitions, one regex per kind; group 1 is the name
DEFINITIONS = [
    re.compile(r"^\s*(@?[A-Za-z_]\w*)\s*:(?!=)"),                 # label:
    re.compile(r"^\s*([A-Za-z_]\w*)\s*:?=(?!=)"),                 # name = / name :=
    re.compile(r"^\s*([A-Za-z_]\w*)\s+\.set\b", re.I),            # name .set
    re.compile(r"\.define\s+([A-Za-z_]\w*)", re.I),
    re.compile(r"\.(?:macro|mac|proc|scope|struct|enum|union)\s+([A-Za-z_]\w*)", re.I),
    re.compile(r"\.segment\s+\"(\w+)\"", re.I),
]


def strip_comment(line):
    """Drop a ca65 / ld65 comment, leaving strings alone."""
    out, quote = [], None
    for ch in line:
        if quote:
            if ch == quote:
                quote = None
        elif ch in "\"'":
            quote = ch
        elif ch in ";#":
            break
        out.append(ch)
    return "".join(out)


def asm_symbols():
    """Every symbol the ca65 sources and the ld65 config define."""
    names = set()
    for pattern in ("src/**/*.asm", "src/**/*.inc", "src/**/*.cfg"):
        for f in ROOT.glob(pattern):
            for line in f.read_text(errors="replace").splitlines():
                line = strip_comment(line)
                for rx in DEFINITIONS:
                    names.update(rx.findall(line))
    return names


def tool_identifiers():
    """Every identifier in the tools, the Makefile and the workflows: script
    options, function names, hint fields, make targets and variables."""
    names = set()
    for pattern in ("tools/**/*.py", "tools/**/*.json", "Makefile", ".github/workflows/*.yml"):
        for f in ROOT.glob(pattern):
            names.update(re.findall(r"[A-Za-z_][A-Za-z0-9_]*", f.read_text(errors="replace")))
    return names


def looks_like_name(tok):
    """Whether a token in a code span is meant as a code identifier."""
    bare = tok.lstrip("@")
    if not bare or bare[0].isdigit():
        return False
    if AUTO_LABEL.match(bare):
        return True
    if re.fullmatch(r"[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]*)+", bare):  # snake_case, FOO_BAR, sub_
        return True
    if re.fullmatch(r"[A-Z][A-Z0-9]{3,}", bare):  # INIDISP; not LDA, ROM, NMI
        return True
    if re.fullmatch(r"[A-Z][a-z0-9]+(?:[A-Z][A-Za-z0-9]*)+", bare):  # CamelCase
        return True
    if re.fullmatch(r"[a-z][a-z0-9]*[A-Z][A-Za-z0-9]*", bare):  # camelCase
        return True
    return False


def tracked_files():
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True).stdout.split()
    return out or [str(p.relative_to(ROOT)) for p in ROOT.rglob("*") if p.is_file()]


def main():
    symbols = asm_symbols()
    tool_names = tool_identifiers()
    ordered = sorted(symbols | tool_names)
    files = tracked_files()
    dirs = {"/".join(f.split("/")[:i]) for f in files for i in range(1, f.count("/") + 1)}
    basenames = {f.rsplit("/", 1)[-1] for f in files}
    ignore = set()
    if IGNORE_FILE.exists():
        ignore = {l.strip() for l in IGNORE_FILE.read_text().splitlines()
                  if l.strip() and not l.startswith("#")}

    def known(tok):
        if tok in ignore:
            return True
        if AUTO_LABEL.match(tok.lstrip("@")):
            return tok in symbols  # generated labels must still be in the code
        if tok.endswith("_"):  # a family: sub_, loc_ ...
            i = bisect.bisect_left(ordered, tok)
            return i < len(ordered) and ordered[i].startswith(tok)
        return tok in symbols or tok in tool_names

    def path_exists(p):
        p = p.rstrip("/")
        return ("*" in p or p in GENERATED or p in dirs or p in files
                or (ROOT / p).exists() and p not in ("",))

    problems = []
    for page in sorted(BOOK.rglob("*.md")):
        rel = page.relative_to(ROOT)
        in_block = False
        for n, line in enumerate(page.read_text().splitlines(), 1):
            if line.lstrip().startswith("```"):
                in_block = not in_block
                continue
            spans = [line] if in_block else re.findall(r"`([^`]+)`", line)
            for span in spans:
                for chunk in re.split(r"[\s,()\[\]{}|=+*<>;\"']+", span):
                    if not chunk:
                        continue
                    if not in_block:
                        if PATH.match(chunk):
                            if chunk not in ignore and not path_exists(chunk):
                                problems.append((rel, n, chunk, "path"))
                            continue
                        if FILE.match(chunk):
                            if chunk not in basenames and chunk not in ignore:
                                problems.append((rel, n, chunk, "file"))
                            continue
                    if chunk.startswith("-") or "/" in chunk:
                        continue  # --out, path/to/rom.sfc
                    chunk = re.sub(r"[#$][$0-9A-Fa-f:]*", " ", chunk)  # $00:8000, #$30, f:$7E2000
                    for tok in IDENT.findall(chunk):
                        if looks_like_name(tok) and not known(tok):
                            problems.append((rel, n, tok, "name"))
    for rel, n, tok, kind in problems:
        print(f"{rel}:{n}: {kind} `{tok}` not found")
    if problems:
        print(f"{len(problems)} problem(s). Fix the page, or list intentional names in book/names-ignore.txt.")
        return 1
    print("book names OK")
    return 0


if __name__ == "__main__":
    sys.exit(main())
