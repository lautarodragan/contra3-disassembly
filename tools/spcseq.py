#!/usr/bin/env python3
"""The sound driver's sequences (songs, sound effects) as text, and back.

A song (assets/sound/spc_song_*.seq) is text, one statement per line, that
the build assembles to the bytes the game uploads to the sound CPU
(book: Sound driver, the sequence format):

    at $3000                       ARAM address of the first byte
    song L300C L31D1 ...           a song header: one address per channel
    L300C:                         a label (any name; L + hex is the default)
        tempo $46
        inst $0D
        note $24 $18 $64 $50       note, duration, gate, volume
        note $24 . $64 $50         `.`: the duration of the note before
        note $24 $18 . $50         `.`: the gate of the note before (1 byte)
        rest $18
        loop1 $02 $00 $00
        jump L300C
        end
        .byte $12 $34              bytes as they are (not reached)
        .zero 300                  that many zeros (not reached)
    .org $4B00                     zeros up to that address (a song the
                                   driver plays from a fixed address)

Numbers are hex with `$`, or decimal; a command's operands are its bytes in
order, except the addresses of `song`, `jump`, `call` and `branch`, which
are labels (or `$XXXX` for an address outside the file). Every statement
is exactly its bytes, so the text gives back the file it was made from
(`make` checks it through the ROM's hash); labels make the addresses follow
when a sequence changes length.

    python3 tools/spcseq.py totext BIN AT [--song ADDR...]  binary -> text (stdout)
    python3 tools/spcseq.py build SEQ OUT                    text -> binary
    python3 tools/spcseq.py driver                           the driver's sound table
                                                             and its sequences (stdout)

`totext` follows the channels from the song headers at AT and at each
--song address, like a disassembler follows code: notes and commands are
decoded where a channel can go, the rest is `.byte`.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)

# Commands: byte -> (name, operand bytes). The handlers are in the driver's
# table at $0DDD (bytes $60-$64, $E0-$FF), the operand counts in its table
# at $0E27 (FC reads a second address when the driver's flag $2A.0 is set).
COMMANDS = {
    0x60: ("drums_on", 0), 0x61: ("drums_off", 0), 0x62: ("gate", 1),
    0x63: ("volume", 1), 0x64: ("gate_volume", 2),
    0xE0: ("rest", 1), 0xE1: ("tie", 2), 0xE2: ("inst", 1), 0xE3: ("pan", 1),
    0xE4: ("vibrato", 3), 0xE5: ("pitch_noise", 3), 0xE6: ("loop1_start", 0),
    0xE7: ("loop1", 3), 0xE8: ("loop2_start", 0), 0xE9: ("loop2", 3),
    0xEA: ("tempo", 1), 0xEB: ("tempo_fade", 2), 0xEC: ("transpose", 1),
    0xED: ("skip3", 3), 0xEE: ("channel_volume", 1), 0xEF: ("channel_volume_fade", 2),
    0xF0: ("glide", 1), 0xF1: ("bend", 3), 0xF2: ("detune", 1), 0xF3: ("slide", 3),
    0xF4: ("echo", 3), 0xF5: ("echo_setup", 3), 0xF6: ("repeat_start", 0),
    0xF7: ("repeat", 0), 0xF8: ("pan_fade", 2), 0xF9: ("vibrato_fade", 1),
    0xFA: ("envelope", 3), 0xFB: ("pitch_mod", 1), 0xFC: ("branch", 4),
    0xFD: ("jump", 2), 0xFE: ("call", 2), 0xFF: ("end", 0),
}
BY_NAME = {name: (byte, n) for byte, (name, n) in COMMANDS.items()}
ADDRESS_OPS = {"jump": 1, "call": 1, "branch": 2}   # operands that are addresses
STOPS = {"jump", "end", "branch"}                   # no next statement
NOTES = 0x60                                        # (byte & $7F) < $60: a note
STOP_ALL = range(0x65, 0x80)                        # stops every channel (unused)


def decode_at(mem, pc):
    """(length, kind, values) of the statement at pc: kind is 'note' (values:
    note, duration or None, gate or None, volume byte), a command name, or
    'stopall'."""
    b = mem[pc]
    if (b & 0x7F) < NOTES:
        n = 1
        dur = None
        if not b & 0x80:
            dur = mem[pc + n]
            n += 1
        v = mem[pc + n]
        n += 1
        if v & 0x80:
            return n, "note", (b & 0x7F, dur, None, v & 0x7F)
        vol = mem[pc + n]
        return n + 1, "note", (b & 0x7F, dur, v, vol)
    if b in COMMANDS:
        name, k = COMMANDS[b]
        return 1 + k, name, tuple(mem[pc + 1:pc + 1 + k])
    return 1, "stopall", (b,)


def targets(kind, values):
    if kind in ("jump", "call"):
        return [values[0] | values[1] << 8]
    if kind == "branch":
        return [values[0] | values[1] << 8, values[2] | values[3] << 8]
    return []


def trace(mem, entries, lo, hi):
    """{address: length} of the statements reached from the channel entry
    points (within lo..hi), and the set of addresses jumped or called to."""
    seen = {}
    labels = set(entries)
    todo = list(entries)
    while todo:
        pc = todo.pop()
        while lo <= pc < hi and pc not in seen:
            n, kind, values = decode_at(mem, pc)
            if pc + n > hi:
                break
            seen[pc] = n
            for t in targets(kind, values):
                labels.add(t)
                todo.append(t)
            if kind in STOPS or kind == "stopall":
                break
            pc += n
    return seen, labels


def _h(v):
    return "$%02X" % v


def totext(data, at, songs=(), title=None):
    """The text of a song file: data loaded at `at`; song headers at `at`
    and at each address of `songs` (channel count from the first pointer)."""
    lo, hi = at, at + len(data)
    mem = bytearray(0x10000 + 16)
    mem[lo:hi] = data
    headers = {}
    for s in [at] + list(songs):
        first = mem[s] | mem[s + 1] << 8
        count = (first - s) // 2 if s < first <= s + 16 and not (first - s) % 2 else 0
        if not count:
            continue
        headers[s] = [mem[s + 2 * i] | mem[s + 2 * i + 1] << 8 for i in range(count)]
    entries = [p for ptrs in headers.values() for p in ptrs if lo <= p < hi]
    seen, labels = trace(mem, entries, lo, hi)
    # statements that overlap another one or a header are dropped (their
    # bytes become .byte lines)
    taken = set()
    for s, ptrs in headers.items():
        taken.update(range(s, s + 2 * len(ptrs)))
    stmts = {}
    for pc in sorted(seen):
        span = set(range(pc, pc + seen[pc]))
        if span & taken:
            continue
        stmts[pc] = seen[pc]
        taken |= span
    labels = {a for a in labels if a in stmts or a in headers or not lo <= a < hi}
    name = {a: "L%04X" % a for a in labels}

    def ref(a):
        return name.get(a, "$%04X" % a)

    out = []
    if title:
        out += ["# " + line for line in title]
    out.append("at $%04X" % at)
    pc = lo
    pending = []

    def flush():
        while pending:
            out.append("\t.byte " + " ".join(_h(x) for x in pending[:16]))
            del pending[:16]

    while pc < hi:
        if pc in labels and lo <= pc:
            flush()
            out.append("%s:" % name[pc])
        if pc in headers:
            flush()
            out.append("\tsong " + " ".join(ref(p) for p in headers[pc]))
            pc += 2 * len(headers[pc])
            continue
        if pc in stmts:
            flush()
            n, kind, values = decode_at(mem, pc)
            if kind == "note":
                note, dur, gate, vol = values
                raw_vol = mem[pc + n - 1]
                out.append("\tnote %s %s %s %s" % (_h(note), "." if dur is None else _h(dur),
                                                    "." if gate is None else _h(gate),
                                                    _h(vol if gate is None else raw_vol)))
            elif kind in ADDRESS_OPS:
                addrs = targets(kind, values)
                out.append("\t%s %s" % (kind, " ".join(ref(a) for a in addrs)))
            else:
                out.append(("\t%s %s" % (kind, " ".join(_h(v) for v in values))).rstrip())
            pc += n
            continue
        zeros = 0
        while pc + zeros < hi and mem[pc + zeros] == 0 and pc + zeros not in stmts \
                and pc + zeros not in headers and (zeros == 0 or pc + zeros not in labels):
            zeros += 1
        if zeros >= 16:
            flush()
            if pc + zeros in headers and pc + zeros != at:
                out.append(".org $%04X" % (pc + zeros))
            else:
                out.append("\t.zero %d" % zeros)
            pc += zeros
            continue
        pending.append(mem[pc])
        pc += 1
        if pc in labels or pc in stmts or pc in headers:
            flush()
    flush()
    return "\n".join(out) + "\n"


# -- assembling --------------------------------------------------------------

def _num(tok, where):
    try:
        if tok.startswith("$"):
            return int(tok[1:], 16)
        return int(tok, 10)
    except ValueError:
        sys.exit(f"{where}: `{tok}` is not a number")


def assemble(text, where="<text>"):
    """(at, bytes) of a song file's text."""
    at = None
    stmts = []          # (line, kind, args)
    for n, line in enumerate(text.split("\n"), 1):
        line = line.split("#")[0].strip()
        if not line:
            continue
        w = f"{where}:{n}"
        m = re.match(r"^([A-Za-z_]\w*):$", line)
        if m:
            stmts.append((w, "label", m.group(1)))
            continue
        words = line.split()
        if words[0] == "at":
            at = _num(words[1], w)
            continue
        stmts.append((w, words[0], words[1:]))
    if at is None:
        sys.exit(f"{where}: no `at` line")

    def size(w, kind, args, pc=None):
        if kind == "label":
            return 0
        if kind == ".zero":
            return _num(args[0], w)
        if kind == ".org":
            target = _num(args[0], w)
            if pc is not None and target < pc:
                sys.exit(f"{w}: .org ${target:04X}, but the data before it reaches ${pc:04X}")
            return target - pc if pc is not None else 0
        if kind == "song":
            return 2 * len(args)
        if kind == ".byte":
            return len(args)
        if kind == "note":
            if len(args) != 4:
                sys.exit(f"{w}: note takes 4 operands (note, duration, gate, volume)")
            return 2 + (args[1] != ".") + (args[2] != ".")
        if kind not in BY_NAME:
            sys.exit(f"{w}: unknown statement `{kind}`")
        return 1 + BY_NAME[kind][1]

    labels = {}
    pc = at
    for w, kind, args in stmts:
        if kind == "label":
            if args in labels:
                sys.exit(f"{w}: label {args} defined twice")
            labels[args] = pc
        pc += size(w, kind, args, pc)

    def addr(tok, w):
        if tok.startswith("$"):
            return _num(tok, w)
        if tok not in labels:
            sys.exit(f"{w}: unknown label {tok}")
        return labels[tok]

    def byte(tok, w):
        v = _num(tok, w)
        if not 0 <= v <= 0xFF:
            sys.exit(f"{w}: {tok} is not a byte")
        return v

    out = bytearray()
    for w, kind, args in stmts:
        if kind == "label":
            continue
        if kind == "song":
            for a in args:
                out += addr(a, w).to_bytes(2, "little")
        elif kind == ".byte":
            out += bytes(byte(a, w) for a in args)
        elif kind == ".zero":
            out += bytes(_num(args[0], w))
        elif kind == ".org":
            out += bytes(_num(args[0], w) - at - len(out))
        elif kind == "note":
            note = byte(args[0], w)
            if note >= NOTES:
                sys.exit(f"{w}: note {args[0]} is not below $60")
            if args[1] == ".":
                out.append(note | 0x80)
            else:
                out += bytes([note, byte(args[1], w)])
            vol = byte(args[3], w)
            if args[2] == ".":
                if vol >= 0x80:
                    sys.exit(f"{w}: the volume of a note without gate must be below $80")
                out.append(vol | 0x80)
            else:
                gate = byte(args[2], w)
                if gate >= 0x80:
                    sys.exit(f"{w}: gate {args[2]} must be below $80")
                out += bytes([gate, vol])
        else:
            code, count = BY_NAME[kind]
            if kind in ADDRESS_OPS:
                if len(args) != ADDRESS_OPS[kind]:
                    sys.exit(f"{w}: {kind} takes {ADDRESS_OPS[kind]} address(es)")
                ops = b"".join(addr(a, w).to_bytes(2, "little") for a in args)
            else:
                if len(args) != count:
                    sys.exit(f"{w}: {kind} takes {count} operand(s)")
                ops = bytes(byte(a, w) for a in args)
            out.append(code)
            out += ops
    return at, bytes(out)


def build(path):
    return assemble(open(path).read(), path)[1]


# -- the driver -----------------------------------------------------------------

DRIVER = os.path.join("assets", "sound", "spc_driver.bin")
DRIVER_AT = 0x0200
SOUND_TABLE = 0x03E6       # 5-byte records of sounds $01-$73


def driver_mem(root=ROOT):
    data = open(os.path.join(root, DRIVER), "rb").read()
    mem = bytearray(0x10000 + 16)
    mem[DRIVER_AT:DRIVER_AT + len(data)] = data
    return mem


def sound_table(mem):
    """[(id, channel mask, priority, channels, flags, pointer)] of sounds $01-$73."""
    out = []
    for i in range(1, 0x74):
        r = mem[SOUND_TABLE + 5 * (i - 1):SOUND_TABLE + 5 * i]
        out.append((i, r[0], r[1], r[2] & 15, r[2] >> 4, r[3] | r[4] << 8))
    return out


def driver_text(root=ROOT):
    """The sound table and the sequences that live in the driver."""
    mem = driver_mem(root)
    table = sound_table(mem)
    out = ["sound mask pri ch flags pointer -> channels"]
    entries = []
    for i, mask, pri, ch, fl, ptr in table:
        ptrs = [mem[ptr + 2 * k] | mem[ptr + 2 * k + 1] << 8 for k in range(ch)] if ptr else []
        if ptr and ptr < 0x3000:
            entries += [p for p in ptrs if 0x1B37 <= p < 0x2DAC]
        out.append("$%02X   $%02X  $%02X  %d  %d     $%04X  %s" % (
            i, mask, pri, ch, fl, ptr,
            " ".join("$%04X" % p for p in ptrs) if ptr and ptr < 0x3000 else
            "(the song at $%04X)" % ptr if ptr else "-"))
    seen, labels = trace(mem, entries, 0x1B37, 0x2DAC)
    out.append("")
    for pc in sorted(seen):
        if pc in labels:
            out.append("L%04X:" % pc)
        n, kind, values = decode_at(mem, pc)
        out.append("  %04X  %-14s %s %s" % (pc, " ".join("%02X" % x for x in mem[pc:pc + n]), kind,
                                            " ".join(_h(v) for v in values) if kind != "note" else
                                            " ".join("." if v is None else _h(v) for v in values)))
    return "\n".join(out) + "\n"


def main(argv):
    os.chdir(ROOT)
    cmd = argv[1] if len(argv) > 1 else ""
    if cmd == "totext" and len(argv) > 3:
        songs = []
        if "--song" in argv:
            songs = [int(a.lstrip("$"), 16) for a in argv[argv.index("--song") + 1:]]
        data = open(argv[2], "rb").read()
        sys.stdout.write(totext(data, int(argv[3].lstrip("$"), 16), songs))
    elif cmd == "build" and len(argv) > 3:
        open(argv[3], "wb").write(build(argv[2]))
    elif cmd == "driver":
        sys.stdout.write(driver_text())
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
