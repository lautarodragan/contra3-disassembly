#!/usr/bin/env python3
"""A small SPC700 assembler, for the sound driver (book: Sound driver).

It assembles the syntax that tools/spc700.py prints (Sony's: `mov a, $12`,
`mov a, !$1234+x`, `mov $12, #$34`, `bbs $12.3, label`, `mov1 c, $1234.5`),
one statement per line, `;` comments:

    label:                     a label (letters, digits, `_`)
    name = EXPR                a constant
    .org $0896 [, "why"]       zeros up to that address (an error if the
                               bytes before it already go past it, which
                               says why if given)
    .byte EXPR, ...            bytes;  .word EXPR, ...  little-endian words
    .zero N                    N zeros
    .incseq "file.seq"         a sequence text (tools/spcseq.py, the songs'
                               syntax) assembled here; its `at` line must be
                               the address it lands at, and its labels and
                               this file's share one name space

An expression is terms joined by `+` and `-`: `$hex`, decimal, `%binary`,
a label or constant, `*` (the address of the statement); `<EXPR` and
`>EXPR` are its low and high byte. Direct page and absolute operands are
told apart by the syntax (`!` for absolute), so an instruction's size never
depends on a label, and the source is assembled in two passes.

    python3 tools/spcasm.py build SRC OUT        assemble SRC to the binary OUT
    python3 tools/spcasm.py sources SRC          SRC and the files it includes
    python3 tools/spcasm.py space SRC            the room (zeros) before each .org
                                                 that has some or says why
    python3 tools/spcasm.py driver-totext BIN    the driver's source, from the
                                                 binary (how assets/sound/
                                                 spc_driver.s was made)
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import spc700  # noqa: E402
import spcseq  # noqa: E402

REGISTERS = {"a", "x", "y", "ya", "sp", "psw", "c"}
_TERM = r"(?:\$[0-9A-Fa-f]+|%[01]+|\d+|[A-Za-z_]\w*|\*)"
EXPR = r"[<>]?%s(?:\s*[-+]\s*%s)*" % (_TERM, _TERM)


class AsmError(Exception):
    pass


class _NoMatch(Exception):
    pass


# -- the instruction templates -----------------------------------------------
#
# Every opcode of tools/spc700.py's table becomes a regex over the operand
# text (spaces removed) and the list of fields it encodes, in byte order.

def _template(text):
    """(mnemonic, regex, fields) for an opcode's text in spc700.OPS. A field
    is (kind, group): d direct page, a absolute, i immediate, r relative,
    m mem.bit (with its bit group), u PCALL's upage."""
    mnem, _, ops = text.partition(" ")
    ops = ops.replace(" ", "")
    rx = ""
    fields = []
    g = 0
    k = 0

    def grp(kind):
        nonlocal g
        g += 1
        fields.append((kind, "e%d" % g))
        return "(?P<e%d>%s)" % (g, EXPR)
    while k < len(ops):
        c = ops[k]
        if ops.startswith("!a", k):
            rx += "!" + grp("a")
            k += 2
        elif ops.startswith("#i", k):
            rx += "#" + grp("i")
            k += 2
        elif c == "d":
            rx += grp("d")
            k += 1
        elif c == "r":
            rx += grp("r")
            k += 1
        elif c == "u":
            rx += grp("u")
            k += 1
        elif c == "m":
            rx += grp("m") + r"\.(?P<bit%d>[0-7])" % g
            k += 1
        elif c == "D":                       # mov D,S: stored S, D
            rx += grp("d")
            dst = fields.pop()
            k += 1
        elif c == "S":
            rx += grp("d")
            fields.append(dst)
            k += 1
        elif c == "I":                       # d,#i: stored i, d
            rx += grp("d") + ",#" + grp("i")
            fields[-2], fields[-1] = fields[-1], fields[-2]
            k += 1
        else:
            rx += re.escape(c)
            k += 1
    return mnem, re.compile("^" + rx + "$"), fields


TEMPLATES = {}      # mnemonic -> [(opcode, regex, fields)]
for _op, _text in spc700.OPS.items():
    _m, _rx, _f = _template(_text)
    TEMPLATES.setdefault(_m, []).append((_op, _rx, _f))


def _length(fields):
    return 1 + sum(2 if k in "am" else 1 for k, _ in fields)


# -- expressions ---------------------------------------------------------------

def evaluate(expr, symbols, pc=None, strict=True):
    """The value of an expression; None if a symbol is not known yet (and
    not strict). A register name raises _NoMatch (the operand is not an
    expression)."""
    expr = expr.replace(" ", "")
    part = None
    if expr[:1] in "<>":
        part, expr = expr[0], expr[1:]
    terms = re.findall(r"([-+]?)(%s)" % _TERM, expr)
    if any(t.lower() in REGISTERS for _, t in terms):
        raise _NoMatch
    total = 0
    for sign, term in terms:
        if term.startswith("$"):
            v = int(term[1:], 16)
        elif term.startswith("%"):
            v = int(term[1:], 2)
        elif term.isdigit():
            v = int(term)
        elif term == "*":
            v = pc
        elif term in symbols:
            v = symbols[term]
        elif strict:
            raise AsmError("unknown symbol %s" % term)
        else:
            return None
        total += -v if sign == "-" else v
    if part == "<":
        return total & 0xFF
    if part == ">":
        return (total >> 8) & 0xFF
    return total


def _match(mnem, ops):
    """[(opcode, match, fields)] of the templates the operands fit."""
    out = []
    for op, rx, fields in TEMPLATES.get(mnem, []):
        m = rx.match(ops)
        if not m:
            continue
        try:
            for _, g in fields:
                evaluate(m.group(g), {}, 0, strict=False)
        except _NoMatch:
            continue
        out.append((op, m, fields))
    return out


def encode(mnem, ops, pc, symbols):
    """The bytes of one instruction (symbols: every label, or {} in the
    first pass, when only the length counts)."""
    ops = ops.replace(" ", "")
    if mnem in ("jmp", "call") and not ops.startswith(("!", "[")):
        ops = "!" + ops                 # spc700.py's `jmp label`, `call label`
    found = _match(mnem, ops)
    if not found:
        raise AsmError("no such instruction: %s %s" % (mnem, ops))
    if len(found) > 1:
        raise AsmError("ambiguous: %s %s" % (mnem, ops))
    op, m, fields = found[0]
    out = bytearray([op])
    n = _length(fields)
    final = bool(symbols)
    for kind, g in fields:
        v = evaluate(m.group(g), symbols, pc, strict=final)
        if v is None:
            v = 0 if kind != "r" else pc + n
        if kind in "diu":
            if kind == "u" and v >= 0xFF00:
                v -= 0xFF00
            if not 0 <= v <= 0xFF:
                raise AsmError("%s: $%X is not a byte" % (m.group(g), v))
            out.append(v)
        elif kind == "a":
            if not 0 <= v <= 0xFFFF:
                raise AsmError("%s: $%X is not an address" % (m.group(g), v))
            out += v.to_bytes(2, "little")
        elif kind == "m":
            bit = int(m.group("bit" + g[1:]))
            if not 0 <= v < 0x2000:
                raise AsmError("%s: $%X is above $1FFF" % (m.group(g), v))
            out += (v | bit << 13).to_bytes(2, "little")
        elif kind == "r":
            d = v - (pc + n)
            if final and not -128 <= d <= 127:
                raise AsmError("%s: branch out of range (%d)" % (m.group(g), d))
            out.append(d & 0xFF)
    assert len(out) == n
    return bytes(out)


# -- the assembler ---------------------------------------------------------------

def _split_args(text):
    return [a.strip() for a in text.split(",")] if text.strip() else []


def _lines(path):
    for n, line in enumerate(open(path), 1):
        yield "%s:%d" % (path, n), line.split(";")[0].rstrip()


def sources(path):
    """The source and the files it includes."""
    out = [path]
    for _, line in _lines(path):
        m = re.match(r'^\s*\.incseq\s+"([^"]+)"', line)
        if m:
            out.append(os.path.join(os.path.dirname(path), m.group(1)))
    return out


def assemble(path, layout=None):
    """(start address, bytes) of the source file; `layout`, a list, gets
    (where, address, zeros added, reason) of each .org."""
    stmts = []
    for where, line in _lines(path):
        s = line.strip()
        if not s:
            continue
        m = re.match(r"^([A-Za-z_]\w*):\s*(.*)$", s)
        if m:
            stmts.append((where, "label", m.group(1)))
            s = m.group(2).strip()
            if not s:
                continue
        m = re.match(r"^([A-Za-z_]\w*)\s*=\s*(.+)$", s)
        if m:
            stmts.append((where, "=", (m.group(1), m.group(2))))
            continue
        word, _, rest = s.partition(" ")
        if word == ".incseq":
            inc = os.path.join(os.path.dirname(path), rest.strip().strip('"'))
            stmts.append((where, word, (inc, open(inc).read())))
        else:
            stmts.append((where, word.lower() if not word.startswith(".") else word, rest.strip()))
    def run(symbols, emit):
        pc = None
        out = bytearray()
        for where, kind, rest in stmts:
            try:
                if kind == ".org":
                    m = re.match(r'^(.*?)(?:,\s*"([^"]*)")?$', rest)
                    a = evaluate(m.group(1), symbols, pc)
                    if pc is None:
                        pc = start = a
                    if a < pc:
                        raise AsmError(".org $%04X, but the bytes before it reach $%04X%s" % (
                            a, pc, ": " + m.group(2) if m.group(2) else ""))
                    if emit:
                        gaps.append((where, a, a - pc, m.group(2)))
                    out += bytes(a - pc)
                    pc = a
                    continue
                if pc is None:
                    raise AsmError("the first statement must be .org")
                if kind == "label":
                    if not emit:
                        if rest in symbols:
                            raise AsmError("%s defined twice" % rest)
                        symbols[rest] = pc
                    continue
                if kind == "=":
                    name, expr = rest
                    v = evaluate(expr, symbols, pc, strict=emit)
                    if not emit and v is not None:
                        symbols[name] = v
                    continue
                if kind == ".incseq":
                    inc, text = rest
                    at, data, labels = spcseq.assemble_with(text, inc, symbols if emit else None)
                    if at != pc:
                        raise AsmError("%s starts at $%04X but lands at $%04X" % (inc, at, pc))
                    if not emit:
                        for k, v in labels.items():
                            if k in symbols:
                                raise AsmError("%s defined twice (%s)" % (k, inc))
                            symbols[k] = v
                    b = data
                elif kind == ".byte":
                    vals = [evaluate(a, symbols, pc, strict=emit) or 0 for a in _split_args(rest)]
                    for v in vals:
                        if not -128 <= v <= 0xFF:
                            raise AsmError("$%X is not a byte" % v)
                    b = bytes(v & 0xFF for v in vals)
                elif kind == ".word":
                    vals = [evaluate(a, symbols, pc, strict=emit) or 0 for a in _split_args(rest)]
                    b = b"".join((v & 0xFFFF).to_bytes(2, "little") for v in vals)
                elif kind == ".zero":
                    b = bytes(evaluate(rest, symbols, pc))
                elif kind.startswith("."):
                    raise AsmError("unknown directive %s" % kind)
                else:
                    b = encode(kind, rest, pc, symbols if emit else {})
            except AsmError as e:
                raise AsmError("%s: %s" % (where, e))
            except SystemExit as e:          # from spcseq
                raise AsmError(str(e))
            out += b
            pc += len(b)
            if pc > 0x10000:
                raise AsmError("%s: past $FFFF" % where)
        return start, bytes(out)

    symbols = {}
    gaps = []
    run(symbols, False)
    result = run(symbols, True)
    if layout is not None:
        layout += gaps
    return result


def space(path):
    """Lines: each .org of the source, and the zeros it adds before itself
    (the room the bytes before it may still grow by)."""
    gaps = []
    assemble(path, gaps)
    return ["%s: .org $%04X, %d ($%X) bytes free before it%s" % (
        w, a, n, n, " (%s)" % why if why else "") for w, a, n, why in gaps if n or why]


def build(path):
    return assemble(path)[1]


# -- the driver's source, from the binary -----------------------------------------
#
# How assets/sound/spc_driver.s was made (python3 tools/spcasm.py
# driver-totext assets/sound/spc_driver.bin, from the binary the ROM holds):
# the code is what tools/spc700.py's trace reaches from $0200 and from the
# two jump tables; the rest is data. The names are those of the book (Sound
# driver), each with how it is known.

DRIVER_AT = 0x0200
SFX_START, SFX_END, SONG_AREA = 0x1B37, 0x2DAC, 0x3000

# data tables: address -> (name or None, size, comment)
DRIVER_TABLES = {
    0x03E6: ("sound_table", 0x73 * 5, "sounds $01-$73, 5 bytes each: channel mask, "
             "priority, channels, the address of the sound's header (one sequence "
             "address per channel); read from $03E6 + 5 x (n - 1) (L197A)"),
    0x0625: ("fade_speeds", 2, "ticks per step of the fade-out of commands $80, $81 "
             "(cmd_fade_out reads $0625 + n - $80)"),
    0x0627: (None, 1, "not read by the code the trace reaches"),
    0x0628: ("instrument_sets", 14, "the instruments $14-$18 of each set chosen by "
             "commands $74-$7A ($0205 = n - $74)"),
    0x0636: ("instruments", 20 * 8, "instruments $00-$13, 8 bytes each: source "
             "(SRCN), tuning (semitones, 256ths), ADSR1, ADSR2, GAIN, pan (0-20), "
             "attenuation"),
    0x06D6: ("instrument_set_0", 5 * 8, "instruments $14-$18 of set 0 (stage 3)"),
    0x06FE: ("drum_instruments", 21 * 8, "the drums: note n of a channel in drums_on "
             "mode plays instrument n of this table"),
    0x07A6: ("instrument_set_1", 5 * 8, "set 1 (stage 2)"),
    0x07CE: ("instrument_set_2", 5 * 8, "set 2 (stage 1)"),
    0x07F6: ("instrument_set_3", 5 * 8, "set 3 (stage 4)"),
    0x081E: ("instrument_set_4", 5 * 8, "set 4 (stage 5)"),
    0x0846: ("instrument_set_5", 5 * 8, "set 5 (stage 6)"),
    0x086E: ("instrument_set_6", 5 * 8, "set 6 (the opening)"),
    0x0DDD: ("seq_command_handlers", 37 * 2, "the sequence commands $60-$64 and "
             "$E0-$FF (pushed and returned to, L0E61)"),
    0x0E27: ("seq_command_operands", 37, "how many operand bytes each command has"),
    0x1191: ("fir_registers", 8, "the DSP's FIR coefficient registers C0-C7"),
    0x1199: ("fir_coefficients", 8, "the echo filter (written by echo_setup)"),
    0x156E: (None, 0x15BC - 0x156E, "read by the code at $09B0, $0940, $0946, $11BD, "
             "$1548, $155F (not worked out)"),
    0x15BC: ("pitch_table", 0x16BC - 0x15BC, "the DSP pitch of each note, 128 words "
             "(index: note and $7F; $60-$7F are the octave below 0)"),
    0x16BC: ("pitch_noise_16BC", 0x100, "pitch_noise's pseudo-random offsets (low "
             "table, read at $141A)"),
    0x17BC: ("pitch_noise_17BC", 0x100, "pitch_noise's pseudo-random offsets (read at "
             "$1411)"),
    0x18FF: ("control_command_handlers", 9 * 2, "commands $7C-$84 (jmp [!$18FF+x], "
             "x = 2 x (n - $7C))"),
    0x1AEF: (None, 4, "read by the code at $19A5"),
}

# code labels named after what jumps there
DRIVER_CODE_NAMES = {0x0896: "driver_start"}
CONTROL_COMMANDS = ["cmd_pause", "cmd_unpause", "cmd_mono", "cmd_stereo", "cmd_fade_out",
                    "cmd_fade_out", "cmd_set_branch_flag", "cmd_stop_music", "cmd_stop_all"]

# immediates that are the low/high byte of a table's address: instruction
# address -> expression
DRIVER_IMMEDIATES = {
    0x0EFF: "<instruments", 0x0F03: ">instruments",
    0x0F2B: "<drum_instruments", 0x0F2F: ">drum_instruments",
    0x197C: "<sound_table", 0x197F: ">sound_table",
}

# what is known of the sounds that live in the driver (comments in the
# .seq), from the code that queues them
SOUND_NOTES = {
    0x04: "the default gun's shot (spawn_shot_default)",
    0x05: "the laser (spawn_shot_laser_in_slots)",
    0x07: "the crush gun (spawn_shot_crush_in_slot)",
    0x08: "the homing gun (spawn_shot_homing_in_slot)",
    0x09: "the spread gun (spawn_shots_spread_in_slots)",
    0x0A: "the flame thrower (spawn_shots_flame)",
    0x3E: "an extra life (add_score)",
}


def _driver_mem(data):
    mem = bytearray(0x10000 + 16)
    mem[DRIVER_AT:DRIVER_AT + len(data)] = data
    return mem


def _word(mem, a):
    return mem[a] | mem[a + 1] << 8


def driver_sounds(mem):
    """{header address: channel count} and {sound: header} of the sounds
    whose sequences are in the driver."""
    headers, by_sound = {}, {}
    for i in range(1, 0x74):
        r = mem[0x03E6 + 5 * (i - 1):0x03E6 + 5 * i]
        ptr = r[3] | r[4] << 8
        if SFX_START <= ptr < SFX_END:
            headers[ptr] = max(headers.get(ptr, 0), r[2] & 15)
            by_sound[i] = ptr
    return headers, by_sound


def driver_totext(data):
    """(the driver's source, the sound effects' .seq text)."""
    mem = _driver_mem(data)
    handlers = [_word(mem, 0x0DDD + 2 * i) for i in range(37)]
    controls = [_word(mem, 0x18FF + 2 * i) for i in range(9)]
    seen = spc700.trace(mem, [DRIVER_AT] + handlers + controls)
    code = {pc for pc in seen if DRIVER_AT <= pc < SFX_START}
    names = dict(DRIVER_CODE_NAMES)
    cmd_bytes = list(range(0x60, 0x65)) + list(range(0xE0, 0x100))
    for b, a in zip(cmd_bytes, handlers):
        names.setdefault(a, "seq_" + spcseq.COMMANDS[b][0])
    for name, a in zip(CONTROL_COMMANDS, controls):
        names.setdefault(a, name)
    for pc in sorted(code):
        n = seen[pc][0]
        for t in spc700.decode(mem, pc)[2]:
            if t is not None and t != pc + n and DRIVER_AT <= t < SFX_START:
                names.setdefault(t, "L%04X" % t)
    tables = {a: v for a, v in DRIVER_TABLES.items() if v[0]}

    def data_ref(a):
        if a in tables:
            return tables[a][0]
        for t, (name, size, _) in tables.items():
            if t - 1 <= a < t + size:
                d = a - t
                return name + ("+%d" % d if d > 0 else "-%d" % -d if d < 0 else "")
        return None

    headers, by_sound = driver_sounds(mem)
    sfx_names = {}
    for i, h in sorted(by_sound.items()):
        sfx_names.setdefault(h, "sound_%02X" % i)

    out = ["; The sound driver (SPC700), uploaded to ARAM $0200 at boot (spc_driver).",
           "; Assembled by tools/spcasm.py; book: Sound driver. The sequences of the sound",
           "; effects are text in spc_sfx.seq (included below). Code and tables stay at",
           "; their addresses (the .org lines check it): the code reads the tables at",
           "; fixed addresses. The sound effects may change size up to $3000.",
           ""]

    def fmt_bytes(bs):
        return ", ".join("$%02X" % b for b in bs)

    def emit_code(pc):
        n, text, _ = spc700.decode(mem, pc, names)
        mnem = text.split(" ")[0]
        if pc in DRIVER_IMMEDIATES:
            text = re.sub(r"#\$[0-9A-F]{2}", "#" + DRIVER_IMMEDIATES[pc], text)
        else:
            def sub(m):
                a = int(m.group(1), 16)
                r = data_ref(a) if a >= DRIVER_AT and not (mnem in ("jmp", "call")) else None
                return "!" + r if r else m.group(0)
            text = re.sub(r"!\$([0-9A-F]{4})", sub, text)
        return n, "\t" + text

    def emit_table(a, end):
        name, size, comment = DRIVER_TABLES.get(a, (None, end - a, ""))
        lines = []
        if comment:
            lines.append("; %s" % comment if not name else "%s:\t; $%04X: %s" % (name, a, comment))
        elif name:
            lines.append("%s:" % name)
        end = min(end, a + size)
        if name == "sound_table":
            for i in range(1, 0x74):
                r = mem[a + 5 * (i - 1):a + 5 * i]
                ptr = r[3] | r[4] << 8
                ref = sfx_names.get(ptr) if ptr in by_sound.values() else None
                note = SOUND_NOTES.get(i, "")
                if not ref:
                    note = "the song at $%04X" % ptr if ptr else "empty"
                lines.append("\t.byte %s\t; $%02X%s" % (fmt_bytes(r[:3]), i, ": " + note if note else ""))
                lines.append("\t.word %s" % (ref or "$%04X" % ptr))
        elif name == "instrument_sets":
            for k in range(7):
                lines.append("\t.word instrument_set_%d" % k)
        elif name and (name.startswith("instrument") or name == "drum_instruments"):
            first = 0x14 if name.startswith("instrument_set_") else 0
            for k in range((end - a) // 8):
                lines.append("\t.byte %s\t; $%02X" % (fmt_bytes(mem[a + 8 * k:a + 8 * k + 8]), first + k))
        elif name in ("seq_command_handlers", "control_command_handlers"):
            first = cmd_bytes if name.startswith("seq") else range(0x7C, 0x85)
            for k in range((end - a) // 2):
                lines.append("\t.word %s\t; $%02X" % (names[_word(mem, a + 2 * k)], first[k]))
        elif name == "seq_command_operands":
            for k in range(0, end - a, 8):
                lines.append("\t.byte %s\t; $%02X-" % (fmt_bytes(mem[a + k:min(end, a + k + 8)]), cmd_bytes[k]))
        elif name == "pitch_table":
            for k in range(0, end - a, 16):
                lines.append("\t.word %s" % ", ".join("$%04X" % _word(mem, a + k + j) for j in range(0, 16, 2)))
        else:
            for k in range(a, end, 16):
                lines.append("\t.byte %s" % fmt_bytes(mem[k:min(end, k + 16)]))
        return lines, end

    pc = DRIVER_AT
    out.append("\t.org $%04X" % pc)
    prev_code = False
    while pc < SFX_START:
        if pc in code:
            if not prev_code:
                if pc != DRIVER_AT:
                    out.append("")
                    out.append("\t.org $%04X" % pc)
            if pc in names:
                out.append("%s:" % names[pc])
            n, line = emit_code(pc)
            out.append(line)
            pc += n
            prev_code = True
            continue
        # data up to the next code or table start
        end = pc + 1
        while end < SFX_START and end not in code and end not in DRIVER_TABLES:
            end += 1
        out.append("")
        name = DRIVER_TABLES.get(pc, (None,))[0]
        fixed = name and not name.startswith("instrument_set_")    # (through instrument_sets)
        out.append("\t.org $%04X" % pc + (', "the code reads %s at $%04X"' % (name, pc)
                                           if fixed else ""))
        if pc == DRIVER_AT + 3 and not any(mem[pc:0x03E6]):
            out.append("; $0203-$03E5: the driver's variables (cleared by driver_start)")
            out.append("\t.zero $%X" % (0x03E6 - pc))
            pc = 0x03E6
        else:
            lines, pc = emit_table(pc, end)
            out += lines
        prev_code = False
    out += ["", "; the sequences of the sound effects (and of sounds $6D, $6E)",
            "\t.org $%04X" % SFX_START, '\t.incseq "spc_sfx.seq"', "",
            "; zeros up to the song of the set ($3000)",
            '\t.org $%04X, "the sound effects must end before the song of the set, at $%04X"'
            % (SONG_AREA, SONG_AREA)]
    title = ["The sequences of the sounds that live in the sound driver (spc_driver.s",
             "includes this file; book: Sound driver). `sound_NN:` is the header of sound",
             "$NN (one sequence address per channel), which the driver's sound_table points",
             "to; `sound_NN_chK` its channels' sequences. Same syntax as the songs. They may",
             "change size: the labels follow, up to $3000 (the song of the set)."]
    notes = {h: ["sound $%02X%s" % (i, ": " + SOUND_NOTES[i] if i in SOUND_NOTES else "")
                 for i in sorted(by_sound) if by_sound[i] == h] for h in headers}
    seq_names = dict(sfx_names)
    for h, count in headers.items():
        for k in range(count):
            p = _word(mem, h + 2 * k)
            if SFX_START <= p < SFX_END:
                seq_names.setdefault(p, "%s_ch%d" % (sfx_names[h], k))
    seq = spcseq.totext(bytes(mem[SFX_START:SFX_END]), SFX_START, headers, title,
                        names=seq_names, notes=notes)
    return "\n".join(out) + "\n", seq


def main(argv):
    cmd = argv[1] if len(argv) > 1 else ""
    try:
        if cmd == "build" and len(argv) == 4:
            data = build(argv[2])
            open(argv[3], "wb").write(data)
        elif cmd == "space" and len(argv) == 3:
            print("\n".join(space(argv[2])))
        elif cmd == "sources" and len(argv) == 3:
            print("\n".join(sources(argv[2])))
        elif cmd == "driver-totext" and len(argv) >= 3:
            asm, seq = driver_totext(open(argv[2], "rb").read())
            if len(argv) == 5:
                open(argv[3], "w").write(asm)
                open(argv[4], "w").write(seq)
            else:
                sys.stdout.write(asm)
        else:
            sys.exit(__doc__)
    except AsmError as e:
        sys.exit(str(e))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
