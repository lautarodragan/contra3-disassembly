#!/usr/bin/env python3
"""Turn loc_XXXXXX jump targets into cheap local labels (@name).

    python3 tools/localize.py analyze [FILE|DIR ...] [--list] [--entries]
    python3 tools/localize.py suggest [FILE|DIR ...] > names.txt
    python3 tools/localize.py apply [FILE|DIR ...] [--map FILE] [--auto] [-n] [--check]

In ca65 a cheap local label (@name) is only visible between two normal
symbol definitions: a label "name:", but also "name = ...", "name := ...",
"name .set ...", a .proc/.scope, and a macro whose body defines a label.
Every loc_XXXXXX is a normal label, so converting one merges the two spans
around it, and a cheap local can replace a loc_ only when every reference
to it lies in its span *after* the conversion.

analyze
    For every loc_ label defined in the given files (default: all of src/),
    decides whether it can become a cheap local.  The analysis always reads
    the whole tree.  It starts from every loc_ that is not excluded outright
    and drops, until nothing changes (a fixpoint), each one with a reference
    outside its span when all the remaining candidates are converted.  A
    loc_ must stay a normal label when it is
      external     named in the book, README.md or a tool (tools/*.py);
      expression   referenced other than as the whole operand of a branch,
                   jmp, jml (a data directive such as .addr / .word /
                   .faraddr, a macro argument, #.loword(...), label+1,
                   jmp (label,x) ...);
      conditional  defined inside .if/.else (cheat options), or defined
                   twice;
      other-file   referenced from another file;
      no-scope     defined before the first normal label of its file;
      entry        referenced from another routine (the code between two
                   normal labels that are not loc_): really a routine entry
                   or a shared tail, which deserves a semantic normal name
                   (listed with --entries);
      blocked      referenced across another loc_ that must stay (the
                   reason cascades: give that label a name, re-run).
    Comments are not references, but apply updates them.  --list prints the
    decision for every label, --entries the probable routine entries.

suggest
    Prints, as an "OLD @new" map, the automatic names (see below) of the
    convertible labels of the given files that apply --auto would convert.
    Edit it (replace a generic name by a semantic one, delete a line to keep
    the loc_, add "loc_X @name" lines) and pass it to apply --map.

apply
    --map FILE   lines "loc_XXXXXX @name" (convert to a cheap local) or
                 "OLD new_name" (a normal rename, done by tools/rename.py);
                 blank lines and text after '#' are ignored.
    --auto       also convert, with an automatic name, every convertible
                 loc_ of the given files that the map does not mention and
                 that matches a pattern.
    -n           dry run: check everything, print the counts, write nothing.
    --check      run `make` afterwards (the ROM must still match).
    Refused, nothing written, when a mapped label is not convertible (or
    becomes unreachable because a label between its definition and a
    reference stays), a name is not a valid cheap local name (@ + lower-case
    snake_case, not a mnemonic), or two definitions of the same @name end up
    in one span (existing cheap locals included).  Automatic names never
    clash: they are numbered (@loop, @loop2 ...) and an automatic candidate
    that cannot be reached with the labels that stay is left as loc_.
    Definitions, references and comment mentions are rewritten; a comment
    outside the label's span (or in another file) gets "@name in SCOPE",
    SCOPE being the normal label that encloses the definition.
    Without --check the tool does not build: run `make` (it must print
    OK), `python3 tools/shift.py scan` and `make book-check` yourself.

Automatic names (pattern-based only, they state what the code shows):
    @return      the first instruction is rts, rtl or rti
    @return_clc  clc, then rts/rtl (return with carry clear)
    @return_sec  sec, then rts/rtl (return with carry set)
    @loop        target of a backward branch or jump (a loop top)
    @done        right after the backward branch that closes a loop, and
                 branched to from inside that loop (the loop exit)
    @next        inside a loop body, entered only by forward branches from
                 inside the loop, and followed by at most 8 straight-line
                 instructions up to the branch that closes the loop (the
                 "continue" point: advance the index, test, loop)
Several in one span are numbered @loop, @loop2 ... in source order.  A loc_
that matches no pattern stays loc_ (a positional name such as @L1 says no
more than the address does); name it by hand when the code shows its
purpose.
"""

import argparse
import bisect
import re
import subprocess
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(Path(__file__).resolve().parent))
import rename  # noqa: E402  (tools/rename.py: word matching, normal renames)

LOC = re.compile(r"^loc_[0-9A-F]{6}$")
LOC_WORD = re.compile(r"(?<![A-Za-z0-9_@])loc_[0-9A-F]{6}(?![A-Za-z0-9_@])")
NORMAL_DEF = re.compile(r"^\s*([A-Za-z_]\w*)\s*:(?![=:])")
CHEAP_DEF = re.compile(r"^\s*(@[A-Za-z_]\w*)\s*:")
SYMBOL_DEF = re.compile(r"^\s*([A-Za-z_]\w*)\s*(?::?=(?!=)|\.set\b)", re.I)
SCOPE_DIR = re.compile(r"^\s*\.(proc|scope|endproc|endscope)\b", re.I)
MACRO_START = re.compile(r"^\s*\.mac(?:ro)?\s+([A-Za-z_]\w*)", re.I)
MACRO_END = re.compile(r"^\s*\.endmac(?:ro)?\b", re.I)
IF_START = re.compile(r"^\s*\.if\w*\b", re.I)
IF_GUARD = re.compile(r"^\s*\.ifndef\s+\w+_INC\b")
IF_END = re.compile(r"^\s*\.endif\b", re.I)
INSN = re.compile(r"^\s*(?:@?[A-Za-z_]\w*\s*:\s*)?([a-z]{3})(?:\.[bwl])?\b\s*(.*?)\s*$")
CHEAP_WORD = re.compile(r"(?<![A-Za-z0-9_@])@[A-Za-z_]\w*")
DATA_DIR = re.compile(r"^\s*\.(byte|byt|word|addr|faraddr|dbyt|res|incbin|lobytes|hibytes|bankbytes|dword|align|org)\b", re.I)
VALID_LOCAL = re.compile(r"^@[a-z_][a-z0-9_]*$")

BRANCHES = {"bcc", "bcs", "beq", "bne", "bmi", "bpl", "bvc", "bvs", "bra", "brl"}
COND_BRANCHES = BRANCHES - {"bra", "brl"}
JUMPS = {"jmp", "jml"}
CALLS = {"jsr", "jsl"}
RETURNS = {"rts", "rtl", "rti"}
FLOW = BRANCHES | JUMPS | CALLS | RETURNS | {"brk", "cop", "stp", "wai"}


def split_comment(line):
    """(code, comment) with the comment starting at the first ';' not in quotes."""
    quote = None
    for i, c in enumerate(line):
        if quote:
            if c == quote:
                quote = None
        elif c in "\"'":
            quote = c
        elif c == ";":
            return line[:i], line[i:]
    return line, ""


class Line:
    __slots__ = ("no", "raw", "code", "comment", "label", "cheap", "boundary",
                 "cond", "macro", "mnem", "operand")

    def __init__(self, no, raw):
        self.no = no
        self.raw = raw
        self.code, self.comment = split_comment(raw)
        self.label = self.cheap = self.mnem = self.operand = None
        self.boundary = False      # a normal symbol definition other than a loc_ label
        self.cond = False          # inside .if/.else
        self.macro = False         # inside a .macro body


class Source:
    """Every .asm/.inc file of src/, parsed into lines."""

    def __init__(self):
        self.files = {}
        paths = sorted(p for p in (ROOT / "src").rglob("*") if p.suffix in (".asm", ".inc"))
        texts = {p: p.read_text() for p in paths}
        label_macros = set()
        for t in texts.values():         # macros whose body defines a normal label
            name = None
            for raw in t.split("\n"):
                code = split_comment(raw)[0]
                if (m := MACRO_START.match(code)):
                    name = m.group(1)
                elif MACRO_END.match(code):
                    name = None
                elif name and (NORMAL_DEF.match(code) or SYMBOL_DEF.match(code)):
                    label_macros.add(name)
        self.label_macros = label_macros
        for p, t in texts.items():
            self.files[p] = self._parse(t)

    def _parse(self, text):
        lines = [Line(i, raw) for i, raw in enumerate(text.split("\n"))]
        depth, in_macro, guards = 0, False, 0
        for ln in lines:
            code = ln.code
            if MACRO_START.match(code):
                in_macro = True
                ln.macro = True
                continue
            if MACRO_END.match(code):
                in_macro = False
                ln.macro = True
                continue
            if in_macro:
                ln.macro = True
                continue
            if IF_START.match(code):
                if IF_GUARD.match(code) and depth == 0:
                    guards += 1
                else:
                    depth += 1
                continue
            if IF_END.match(code):
                if depth:
                    depth -= 1
                elif guards:
                    guards -= 1
                continue
            ln.cond = depth > 0
            if (m := NORMAL_DEF.match(code)):
                ln.label = m.group(1)
                ln.boundary = not LOC.match(ln.label)
            elif (m := CHEAP_DEF.match(code)):
                ln.cheap = m.group(1)
            elif SYMBOL_DEF.match(code) or SCOPE_DIR.match(code):
                ln.boundary = True
            if (m := INSN.match(code)):
                ln.mnem, ln.operand = m.group(1), m.group(2)
            elif code.strip() and code.split()[0] in self.label_macros:
                ln.boundary = True
        return lines


def rel(p):
    return str(p.relative_to(ROOT))


def first_insn(lines, i, count=1):
    """The mnemonics of the first `count` instructions from line i on."""
    out = []
    for ln in lines[i:]:
        if ln.mnem:
            out.append(ln.mnem)
            if len(out) == count:
                break
        elif DATA_DIR.match(ln.code) or (ln.code.strip() and not ln.label and not ln.cheap
                                         and not ln.code.strip().startswith(".")):
            break        # data or a macro: not straight code
    return out


class Analysis:
    def __init__(self, src):
        self.src = src
        self.defs = defaultdict(list)       # loc name -> [(path, lineno)]
        self.refs = defaultdict(list)       # loc name -> [(path, lineno, kind)]
        self.mentions = defaultdict(list)   # loc name -> [(path, lineno)] in comments
        for p, lines in src.files.items():
            for ln in lines:
                if ln.macro:
                    continue
                if ln.label and LOC.match(ln.label):
                    self.defs[ln.label].append((p, ln.no))
                code = ln.code
                if ln.label:
                    code = code.split(":", 1)[1]
                for m in LOC_WORD.finditer(code):
                    name = m.group(0)
                    kind = "expression"
                    op = (ln.operand or "").strip()
                    if ln.mnem in BRANCHES | JUMPS | CALLS and re.fullmatch(rf"(?:a:|f:)?{name}", op):
                        kind = "call" if ln.mnem in CALLS else "jump"
                    self.refs[name].append((p, ln.no, kind))
                for m in LOC_WORD.finditer(ln.comment):
                    self.mentions[m.group(0)].append((p, ln.no))
        self.external = defaultdict(list)
        ext = sorted((ROOT / "book" / "src").glob("*.md")) + [ROOT / "README.md"] + \
            sorted((ROOT / "tools").glob("*.py"))
        for f in ext:
            if f.name == "localize.py" or not f.exists():
                continue
            for m in LOC_WORD.finditer(f.read_text()):
                self.external[m.group(0)].append(rel(f))
        # routine boundaries: normal labels that are not loc_ (and symbol defs)
        self.routine_bounds = {p: [ln.no for ln in lines if ln.boundary and not ln.macro]
                               for p, lines in src.files.items()}
        self._run()

    # -- spans -------------------------------------------------------------
    def boundaries(self, keep, cond=True):
        """{path: sorted line numbers of the normal symbol definitions} once
        the loc_ labels in `keep` are converted (every other loc_ stays).
        cond=False leaves out the ones inside .if/.else (for clash checks:
        the widest spans; references are checked with cond=True, the
        narrowest)."""
        out = {}
        for p, lines in self.src.files.items():
            b = []
            for ln in lines:
                if ln.macro or not (ln.boundary or (ln.label and ln.label not in keep)):
                    continue
                if not cond and ln.cond:
                    continue
                b.append(ln.no)
            out[p] = b
        return out

    @staticmethod
    def span(bounds, lineno):
        """The line number of the boundary that starts the span of lineno (-1: file start)."""
        i = bisect.bisect_right(bounds, lineno) - 1
        return bounds[i] if i >= 0 else -1

    def reaches(self, name, bounds):
        """Whether every reference to name lies in the span of its definition."""
        p, d = self.defs[name][0]
        s = self.span(bounds[p], d)
        return all(rp == p and self.span(bounds[p], rl) == s for rp, rl, _ in self.refs[name])

    def closure(self, cand, required=()):
        """Largest subset of cand whose members all reach their references when
        exactly they are converted.  Members of `required` that drop out are
        returned as the second value."""
        cand = set(cand)
        while True:
            bounds = self.boundaries(cand)
            bad = {n for n in cand if not self.reaches(n, bounds)}
            if not bad:
                return cand, set()
            if bad & set(required):
                return cand, bad & set(required)
            cand -= bad

    # -- the analysis ------------------------------------------------------
    def _run(self):
        self.reason = {}
        first_bound = {p: (b[0] if b else None) for p, b in self.routine_bounds.items()}
        cand = set()
        for name, defs in self.defs.items():
            refs = self.refs[name]
            p, d = defs[0]
            lines = self.src.files[p]
            if self.external[name]:
                self.reason[name] = "external"
            elif any(k == "expression" for _, _, k in refs):
                self.reason[name] = "expression"
            elif len(defs) > 1 or lines[d].cond:
                self.reason[name] = "conditional"
            elif any(rp != p for rp, _, _ in refs):
                self.reason[name] = "other-file"
            elif first_bound[p] is None or d < first_bound[p]:
                self.reason[name] = "no-scope"
            elif any(k == "call" for _, _, k in refs) or self._other_routine(name):
                self.reason[name] = "entry"
            else:
                cand.add(name)
        self.convertible, _ = self.closure(cand)
        for n in cand - self.convertible:
            self.reason[n] = "blocked"
        for n in self.convertible:
            self.reason[n] = "convertible"
        self.final_bounds = self.boundaries(self.convertible)

    def _other_routine(self, name):
        p, d = self.defs[name][0]
        rb = self.routine_bounds[p]
        s = self.span(rb, d)
        return any(rp != p or self.span(rb, rl) != s for rp, rl, _ in self.refs[name])

    def routine_of(self, p, lineno):
        s = self.span(self.routine_bounds[p], lineno)
        if s < 0:
            return "(file start)"
        ln = self.src.files[p][s]
        return ln.label or ln.code.strip().split()[0]

    def blockers(self, name):
        """The loc_ labels that stay and lie between name and its references."""
        p, d = self.defs[name][0]
        lines = self.src.files[p]
        out = set()
        for rp, rl, _ in self.refs[name]:
            if rp != p:
                continue
            lo, hi = sorted((d, rl))
            for ln in lines[lo + 1:hi + 1]:
                if ln.label and ln.label != name and ln.label not in self.convertible and LOC.match(ln.label):
                    out.add(ln.label)
        return out

    def entries(self):
        """Probable routine entries: (name, path, line, kind, referencing routines)."""
        out = []
        for name, r in self.reason.items():
            if r not in ("entry", "other-file") and not (r == "external" and self._other_routine(name)):
                continue
            p, d = self.defs[name][0]
            lines = self.src.files[p]
            routines = sorted({self.routine_of(rp, rl) for rp, rl, _ in self.refs[name]
                               if rp != p or self.routine_of(rp, rl) != self.routine_of(p, d)})
            prev = next((ln for ln in reversed(lines[:d]) if ln.mnem or ln.boundary or ln.label), None)
            falls = prev is not None and prev.mnem and prev.mnem not in RETURNS | {"bra", "brl", "jmp", "jml"}
            calls = any(k == "call" for _, _, k in self.refs[name])
            kind = "called" if calls else ("shared tail" if falls else "entry")
            out.append((name, p, d, kind, routines))
        return sorted(out, key=lambda e: (rel(e[1]), e[2]))

    # -- automatic names ---------------------------------------------------
    def patterns(self, p):
        """{loc name: base name} for the loc_ labels of file p matching a pattern."""
        lines = self.src.files[p]
        targets = {}                                   # label (any kind) -> def line
        for ln in lines:
            if ln.label or ln.cheap:
                targets[ln.label or ln.cheap] = ln.no
        loops = []                                     # (top line, closing branch line, mnemonic)
        last_back = {}
        for ln in lines:
            if ln.mnem in BRANCHES | JUMPS and ln.operand:
                t = re.sub(r"^(?:a:|f:)", "", ln.operand.strip())
                if t in targets and targets[t] < ln.no:
                    last_back[t] = ln
        for t, ln in last_back.items():
            if self._reaches_line(lines, targets, targets[t], ln.no):
                loops.append((targets[t], ln.no, ln.mnem))
        loop_tops = {top for top, _, _ in loops}
        out = {}
        for ln in lines:
            name = ln.label
            if not name or not LOC.match(name) or name not in self.convertible:
                continue
            d = ln.no
            refs = [rl for _, rl, _ in self.refs[name]]
            ins = first_insn(lines, d + 1, 2)
            if ins[:1] and ins[0] in RETURNS:
                out[name] = "return"
            elif len(ins) == 2 and ins[0] in ("clc", "sec") and ins[1] in ("rts", "rtl"):
                out[name] = "return_" + ins[0]
            elif d in loop_tops:
                out[name] = "loop"
            elif (done := self._after_loop(lines, d, loops, refs)):
                out[name] = done
            elif self._continue_point(lines, d, loops, refs):
                out[name] = "next"
        return out

    @staticmethod
    def _reaches_line(lines, targets, start, goal):
        """Whether the code from line start can reach line goal (flow followed
        only inside [start, goal]): a backward branch at goal to start closes
        a loop only then, not when the code at start always returns first."""
        seen, todo = set(), [start]
        while todo:
            i = todo.pop()
            while start <= i <= goal and i not in seen:
                seen.add(i)
                if i == goal:
                    return True
                ln = lines[i]
                if ln.mnem in BRANCHES | JUMPS and ln.operand:
                    t = targets.get(re.sub(r"^(?:a:|f:)", "", ln.operand.strip()))
                    if t is not None:
                        todo.append(t)
                if ln.mnem in RETURNS | {"bra", "brl", "jmp", "jml", "brk", "stp"}:
                    break
                if DATA_DIR.match(ln.code) or (ln.code.strip() and not ln.mnem and not ln.label
                                               and not ln.cheap and not ln.code.strip().startswith(".")):
                    break        # data or a macro
                i += 1
        return False

    @staticmethod
    def _after_loop(lines, d, loops, refs):
        prev = next((ln for ln in reversed(lines[:d]) if ln.code.strip() and not ln.code.strip().startswith(".")), None)
        if prev is None or not prev.mnem:
            return None
        for top, close, _ in loops:
            if close == prev.no and any(top <= rl < close for rl in refs):
                return "done"
        return None

    @staticmethod
    def _continue_point(lines, d, loops, refs):
        for top, close, mnem in loops:
            if not (top < d < close) or not refs or not all(top <= rl < d for rl in refs):
                continue
            body = [ln for ln in lines[d + 1:close] if ln.code.strip() and not ln.code.strip().startswith(".")]
            if any(not ln.mnem or ln.mnem in FLOW for ln in body):
                continue
            if len(body) <= 8 and lines[close].mnem in BRANCHES | JUMPS:
                return True
        return False


def resolve_files(args):
    if not args:
        return None
    out = set()
    for a in args:
        p = (Path.cwd() / a).resolve()
        if p.is_dir():
            out.update(q for q in p.rglob("*") if q.suffix in (".asm", ".inc"))
        elif p.exists():
            out.add(p)
        else:
            sys.exit(f"localize: {a}: no such file or directory")
    return out


def selected(an, files):
    return [n for n, defs in an.defs.items() if files is None or defs[0][0] in files]


# -- analyze -----------------------------------------------------------------
REASONS = ["convertible", "entry", "blocked", "other-file", "expression", "conditional", "external", "no-scope"]


def cmd_analyze(a):
    src = Source()
    an = Analysis(src)
    files = resolve_files(a.files)
    names = selected(an, files)
    per_file = defaultdict(lambda: defaultdict(int))
    auto = {}
    for p in {an.defs[n][0][0] for n in names}:
        auto.update(an.patterns(p))
    reach_auto = auto_set(an, set(auto), files)
    for n in names:
        p = an.defs[n][0][0]
        per_file[rel(p)][an.reason[n]] += 1
        if n in reach_auto:
            per_file[rel(p)]["auto"] += 1
    cols = REASONS + ["auto"]
    head = ["file", "loc_"] + cols
    rows = []
    total = defaultdict(int)
    for f in sorted(per_file):
        c = per_file[f]
        n = sum(c[r] for r in REASONS)
        rows.append([f, n] + [c[r] for r in cols])
        for r in cols:
            total[r] += c[r]
        total["loc_"] += n
    rows.append(["total", total["loc_"]] + [total[r] for r in cols])
    w = [max(len(str(r[i])) for r in rows + [head]) for i in range(len(head))]
    print("  ".join(str(h).ljust(w[i]) if i == 0 else str(h).rjust(w[i]) for i, h in enumerate(head)))
    for r in rows:
        print("  ".join(str(x).ljust(w[i]) if i == 0 else str(x).rjust(w[i]) for i, x in enumerate(r)))
    clash = merge_clashes(an, an.convertible, {})
    clash = {n for n in clash if n in names}
    if clash:
        print(f"\n{len(clash)} convertible label(s) lie between two existing cheap locals of the same name"
              "\n(converting all of them would put both in one span: rename one with rename.py --scope).")
    print("\nconvertible: every reference stays in the span once all convertible labels are converted;"
          "\nauto: converted by `apply --auto` (matches a pattern and is reachable while the others stay loc_).")
    if a.list:
        print()
        for n in sorted(names, key=lambda n: (rel(an.defs[n][0][0]), an.defs[n][0][1])):
            p, d = an.defs[n][0]
            r = an.reason[n]
            extra = ""
            if r == "blocked":
                extra = " (across " + ", ".join(sorted(an.blockers(n))) + ")"
            elif r == "external":
                extra = " (" + ", ".join(sorted(set(an.external[n]))) + ")"
            elif n in auto:
                extra = f" (pattern @{auto[n]}{'' if n in reach_auto else ', not reachable while others stay'})"
            print(f"{rel(p)}:{d + 1}: {n} {r}{extra}")
    if a.entries:
        ents = [e for e in an.entries() if files is None or e[1] in files]
        print(f"\nprobable routine entries / shared tails ({len(ents)}):")
        for name, p, d, kind, routines in ents:
            print(f"{rel(p)}:{d + 1}: {name} {kind}, from {', '.join(routines)}")
    return 0


def auto_set(an, pool, files, fixed=frozenset()):
    """The automatic candidates (pool) that stay reachable when only they and
    `fixed` are converted, and whose conversion does not put two existing
    cheap locals of the same name (or a name of `fixed`) into one span."""
    pool = {n for n in pool if files is None or an.defs[n][0][0] in files}
    fixed = dict.fromkeys(fixed) if not isinstance(fixed, dict) else fixed
    while True:
        got, _ = an.closure(pool | set(fixed))
        pool &= got
        merged = merge_clashes(an, got, fixed)
        if not merged:
            return got - set(fixed)
        pool -= merged


def merge_clashes(an, converted, names):
    """The labels of `converted` (not of `names`, the map) lying between two
    definitions of one cheap local name that their conversion puts in a span."""
    bounds = an.boundaries(converted, cond=False)
    seen = defaultdict(list)
    for p, lines in an.src.files.items():
        for ln in lines:
            if ln.macro:
                continue
            n = ln.cheap or (names.get(ln.label) if ln.label else None)
            if n:
                seen[(p, an.span(bounds[p], ln.no), n)].append(ln.no)
    out = set()
    for (p, _, n), nos in seen.items():
        if len(nos) > 1:
            lines = an.src.files[p]
            for ln in lines[min(nos) + 1:max(nos)]:
                if ln.label in converted and ln.label not in names:
                    out.add(ln.label)
    return out


# -- apply -------------------------------------------------------------------
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


def plan(an, files, mapping, auto):
    """{loc: @name} to convert and a list of errors."""
    errors = []
    local = {o: n for o, n in mapping.items() if n.startswith("@")}
    for o, n in local.items():
        if o not in an.defs:
            errors.append(f"{o}: not a loc_ label defined in src/")
            continue
        if not VALID_LOCAL.match(n) or n[1:] in rename.MNEMONICS or n[1:] in rename.REGISTERS:
            errors.append(f"{n}: not a valid cheap local name (@ + lower-case snake_case, not a mnemonic)")
        if an.reason[o] != "convertible":
            errors.append(f"{o}: cannot be a cheap local ({an.reason[o]})")
    if errors:
        return None, errors
    fixed = set(local)
    got, lost = an.closure(fixed, required=fixed)
    if lost:
        for o in sorted(lost):
            errors.append(f"{o}: a reference would be outside its span; these labels between stay normal: "
                          + ", ".join(sorted(b for b in an_blockers(an, o, fixed))))
        return None, errors
    names = dict(local)
    if auto:
        pool = {}
        for p in {an.defs[n][0][0] for n in an.convertible if files is None or an.defs[n][0][0] in files}:
            pool.update(an.patterns(p))
        pool = {o: b for o, b in pool.items() if o not in mapping}
        keep = auto_set(an, set(pool), files, local)
        names.update(number(an, {o: pool[o] for o in keep}, set(names) | keep, local))
    errors += clashes(an, names)
    return names, errors


def an_blockers(an, name, converted):
    p, d = an.defs[name][0]
    lines = an.src.files[p]
    out = set()
    for rp, rl, _ in an.refs[name]:
        lo, hi = sorted((d, rl))
        for ln in lines[lo + 1:hi + 1]:
            if ln.boundary or (ln.label and ln.label not in converted):
                out.add(ln.label or ln.code.strip())
    return out


def number(an, auto, converted, fixed):
    """@base, @base2 ... in source order within each span, skipping the names
    already used there (existing cheap locals and the map's names)."""
    bounds = an.boundaries(converted, cond=False)
    used = defaultdict(set)
    for p, lines in an.src.files.items():
        for ln in lines:
            if ln.cheap and not ln.macro:
                used[(p, an.span(bounds[p], ln.no))].add(ln.cheap)
    for o, n in fixed.items():
        p, d = an.defs[o][0]
        used[(p, an.span(bounds[p], d))].add(n)
    out = {}
    for o in sorted(auto, key=lambda o: (rel(an.defs[o][0][0]), an.defs[o][0][1])):
        p, d = an.defs[o][0]
        key = (p, an.span(bounds[p], d))
        base = "@" + auto[o]
        k, n = 1, base
        while n in used[key]:
            k += 1
            n = f"{base}{k}"
        used[key].add(n)
        out[o] = n
    return out


def clashes(an, names):
    """Two definitions of one @name in a span (spans ignoring conditional labels)."""
    bounds = an.boundaries(set(names), cond=False)
    seen = defaultdict(list)
    for p, lines in an.src.files.items():
        for ln in lines:
            if ln.macro:
                continue
            n = ln.cheap or (names.get(ln.label) if ln.label else None)
            if n:
                seen[(p, an.span(bounds[p], ln.no), n)].append(ln.no)
    return [f"{rel(p)}:{nos[1] + 1}: {n} defined twice in one span (also line {nos[0] + 1})"
            for (p, _, n), nos in seen.items() if len(nos) > 1]


def rewrite(an, names):
    """{path: new text}."""
    bounds = an.boundaries(set(names))
    out = {}
    scope_of = {}
    for o in names:
        p, d = an.defs[o][0]
        s = an.span(bounds[p], d)
        lines = an.src.files[p]
        scope_of[o] = (p, s, lines[s].label if s >= 0 and lines[s].label else rel(p))
    r = LOC_WORD
    for p, lines in an.src.files.items():
        changed = False
        new = []
        for ln in lines:
            code, comment = ln.code, ln.comment

            def in_code(m):
                return names.get(m.group(0), m.group(0))

            def in_comment(m):
                o = m.group(0)
                if o not in names:
                    return o
                sp, s, scope = scope_of[o]
                if sp == p and an.span(bounds[p], ln.no) == s:
                    return names[o]
                return f"{names[o]} in {scope}"
            c2 = r.sub(in_code, code)
            m2 = r.sub(in_comment, comment)
            if c2 != code or m2 != comment:
                changed = True
            new.append(c2 + m2)
        if changed:
            out[p] = "\n".join(new)
    return out


def cmd_apply(a):
    src = Source()
    an = Analysis(src)
    files = resolve_files(a.files)
    pairs = read_map(a.map) if a.map else []
    mapping = {}
    errors = []
    for o, n in pairs:
        if o in mapping:
            errors.append(f"{o}: mapped twice")
        mapping[o] = n
    normal = [(o, n) for o, n in pairs if not n.startswith("@")]
    names, errs = plan(an, files, mapping, a.auto)
    errors += errs
    if not errors and normal:
        if rename.rename_global(normal, True):
            errors.append("normal renames refused (see above)")
    if errors:
        print("localize: refused, nothing written:", file=sys.stderr)
        for e in errors:
            print("  " + e, file=sys.stderr)
        return 1
    texts = rewrite(an, names)
    for p, t in sorted(texts.items()):
        print(f"{rel(p)}: {sum(1 for o in names if an.defs[o][0][0] == p)} label(s)")
        if not a.dry_run:
            p.write_text(t)
    print(f"{len(names)} loc_ label(s) to cheap locals{' (dry run)' if a.dry_run else ''}")
    if normal and not a.dry_run:
        if rename.rename_global(normal, False):
            return 1
    if a.check and not a.dry_run:
        return subprocess.run(["make"], cwd=ROOT).returncode
    if not a.dry_run:
        print("now: make && python3 tools/shift.py scan && make book-check")
    return 0


def cmd_suggest(a):
    src = Source()
    an = Analysis(src)
    files = resolve_files(a.files)
    names, errors = plan(an, files, {}, True)
    for e in errors:
        print("# " + e)
    for o in sorted(names, key=lambda o: (rel(an.defs[o][0][0]), an.defs[o][0][1])):
        p, d = an.defs[o][0]
        print(f"{o} {names[o]}\t# {rel(p)}:{d + 1} in {an.routine_of(p, d)}")
    return 0


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n\n")[0],
                                 formatter_class=argparse.RawDescriptionHelpFormatter, epilog=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("analyze")
    p.add_argument("files", nargs="*")
    p.add_argument("--list", action="store_true", help="the decision for every label")
    p.add_argument("--entries", action="store_true", help="probable routine entries / shared tails")
    p = sub.add_parser("suggest")
    p.add_argument("files", nargs="*")
    p = sub.add_parser("apply")
    p.add_argument("files", nargs="*")
    p.add_argument("--map")
    p.add_argument("--auto", action="store_true")
    p.add_argument("-n", "--dry-run", action="store_true")
    p.add_argument("--check", action="store_true", help="run make afterwards")
    a = ap.parse_args()
    return {"analyze": cmd_analyze, "suggest": cmd_suggest, "apply": cmd_apply}[a.cmd](a)


if __name__ == "__main__":
    sys.exit(main())
