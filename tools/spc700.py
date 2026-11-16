#!/usr/bin/env python3
"""A small SPC700 (the SNES sound CPU) disassembler.

    python3 tools/spc700.py FILE BASE [START [END]]       linear listing
    python3 tools/spc700.py FILE BASE --trace ENTRY...    code reached from
                                                          the entry points

FILE is loaded at the sound CPU address BASE (hex); START/END (hex, END
exclusive) limit the listing. --trace follows branches, jumps and calls
from each ENTRY (hex) and lists only the instructions it reached, with a
blank line after each jump/return; jump tables are not followed (give their
targets as more entries). The syntax is Sony's (the one in the SPC700
manuals and most SNES documents): `mov a, $12`, `mov a, !$1234`,
`mov $12, #$34`, `bbs $12.3, label`, `mov1 c, $1234.5`.

Library use: `decode(mem, pc)` returns (length, text, targets) where targets
are the addresses control can go to next (None in the list for a computed
jump).
"""

import sys

# Operand kinds: d direct page, a absolute (!a), i immediate, r relative,
# m mem.bit (13-bit address, 3-bit bit), u PCALL (upage), D/S two direct
# pages (dst, src stored src first), I d,#i (imm stored first), b d.bit (bit
# from the opcode) with r.
_ROWS = """
00 nop|tcall 0|set1 d.0|bbs d.0,r|or a,d|or a,!a|or a,(x)|or a,[d+x]|or a,#i|or D,S|or1 c,m|asl d|asl !a|push psw|tset1 !a|brk
10 bpl r|tcall 1|clr1 d.0|bbc d.0,r|or a,d+x|or a,!a+x|or a,!a+y|or a,[d]+y|or I|or (x),(y)|decw d|asl d+x|asl a|dec x|cmp x,!a|jmp [!a+x]
20 clrp|tcall 2|set1 d.1|bbs d.1,r|and a,d|and a,!a|and a,(x)|and a,[d+x]|and a,#i|and D,S|or1 c,/m|rol d|rol !a|push a|cbne d,r|bra r
30 bmi r|tcall 3|clr1 d.1|bbc d.1,r|and a,d+x|and a,!a+x|and a,!a+y|and a,[d]+y|and I|and (x),(y)|incw d|rol d+x|rol a|inc x|cmp x,d|call !a
40 setp|tcall 4|set1 d.2|bbs d.2,r|eor a,d|eor a,!a|eor a,(x)|eor a,[d+x]|eor a,#i|eor D,S|and1 c,m|lsr d|lsr !a|push x|tclr1 !a|pcall u
50 bvc r|tcall 5|clr1 d.2|bbc d.2,r|eor a,d+x|eor a,!a+x|eor a,!a+y|eor a,[d]+y|eor I|eor (x),(y)|cmpw ya,d|lsr d+x|lsr a|mov x,a|cmp y,!a|jmp !a
60 clrc|tcall 6|set1 d.3|bbs d.3,r|cmp a,d|cmp a,!a|cmp a,(x)|cmp a,[d+x]|cmp a,#i|cmp D,S|and1 c,/m|ror d|ror !a|push y|dbnz d,r|ret
70 bvs r|tcall 7|clr1 d.3|bbc d.3,r|cmp a,d+x|cmp a,!a+x|cmp a,!a+y|cmp a,[d]+y|cmp I|cmp (x),(y)|addw ya,d|ror d+x|ror a|mov a,x|cmp y,d|reti
80 setc|tcall 8|set1 d.4|bbs d.4,r|adc a,d|adc a,!a|adc a,(x)|adc a,[d+x]|adc a,#i|adc D,S|eor1 c,m|dec d|dec !a|mov y,#i|pop psw|mov I
90 bcc r|tcall 9|clr1 d.4|bbc d.4,r|adc a,d+x|adc a,!a+x|adc a,!a+y|adc a,[d]+y|adc I|adc (x),(y)|subw ya,d|dec d+x|dec a|mov x,sp|div ya,x|xcn a
A0 ei|tcall 10|set1 d.5|bbs d.5,r|sbc a,d|sbc a,!a|sbc a,(x)|sbc a,[d+x]|sbc a,#i|sbc D,S|mov1 c,m|inc d|inc !a|cmp y,#i|pop a|mov (x)+,a
B0 bcs r|tcall 11|clr1 d.5|bbc d.5,r|sbc a,d+x|sbc a,!a+x|sbc a,!a+y|sbc a,[d]+y|sbc I|sbc (x),(y)|movw ya,d|inc d+x|inc a|mov sp,x|das a|mov a,(x)+
C0 di|tcall 12|set1 d.6|bbs d.6,r|mov d,a|mov !a,a|mov (x),a|mov [d+x],a|cmp x,#i|mov !a,x|mov1 m,c|mov d,y|mov !a,y|mov x,#i|pop x|mul ya
D0 bne r|tcall 13|clr1 d.6|bbc d.6,r|mov d+x,a|mov !a+x,a|mov !a+y,a|mov [d]+y,a|mov d,x|mov d+y,x|movw d,ya|mov d+x,y|dec y|mov a,y|cbne d+x,r|daa a
E0 clrv|tcall 14|set1 d.7|bbs d.7,r|mov a,d|mov a,!a|mov a,(x)|mov a,[d+x]|mov a,#i|mov x,!a|not1 m|mov y,d|mov y,!a|notc|pop y|sleep
F0 beq r|tcall 15|clr1 d.7|bbc d.7,r|mov a,d+x|mov a,!a+x|mov a,!a+y|mov a,[d]+y|mov x,d|mov x,d+y|mov D,S|mov y,d+x|inc y|mov y,a|dbnz y,r|stop
"""

OPS = {}
for _line in _ROWS.strip().splitlines():
    _hi, _rest = _line.split(" ", 1)
    for _lo, _text in enumerate(_rest.split("|")):
        OPS[int(_hi, 16) + _lo] = _text
assert len(OPS) == 256

# Mnemonics after which execution does not fall through.
_STOPS = {"jmp", "bra", "ret", "reti", "brk", "stop", "sleep"}


def _length(text):
    n = 1
    ops = text.split(" ", 1)[1] if " " in text else ""
    for tok in ("D", "I"):
        if tok in ops:
            return 3
    for part in ops.split(","):
        part = part.strip().lstrip("[(/")
        if part.startswith("!") or part == "m":
            n += 2
        elif part.startswith(("d", "#i", "r", "u")):
            n += 1
    return n


def decode(mem, pc, labels=None):
    """(length, text, targets) of the instruction at pc in mem (a 64 KiB
    bytes-like). targets: addresses executed next (None: computed)."""
    labels = labels or {}
    op = mem[pc]
    text = OPS[op]
    n = _length(text)
    b = [mem[(pc + k) & 0xFFFF] for k in range(n)]
    mnem = text.split(" ", 1)[0]

    def lab(addr, dp=False):
        if addr in labels:
            return labels[addr]
        return "$%02X" % addr if dp else "$%04X" % addr

    out = text
    targets = []
    if " " in text:
        ops = text.split(" ", 1)[1]
        k = 1
        if "D" in ops:
            ops = ops.replace("D", "$%02X" % b[2]).replace("S", "$%02X" % b[1])
        elif "I" in ops:
            ops = ops.replace("I", "$%02X,#$%02X" % (b[2], b[1]))
        else:
            parts = []
            for part in ops.split(","):
                if "!a" in part:
                    w = b[k] | b[k + 1] << 8
                    k += 2
                    if mnem in ("jmp", "call") and part == "!a":
                        targets.append(w)
                        part = lab(w)
                    else:
                        part = part.replace("!a", "!" + lab(w))
                elif part.lstrip("/") == "m":
                    w = b[k] | b[k + 1] << 8
                    k += 2
                    part = part.replace("m", "$%04X.%d" % (w & 0x1FFF, w >> 13))
                elif part == "#i":
                    part = "#$%02X" % b[k]
                    k += 1
                elif part == "r":
                    t = (pc + n + (b[k] - 256 if b[k] >= 128 else b[k])) & 0xFFFF
                    k += 1
                    targets.append(t)
                    part = lab(t)
                elif part == "u":
                    t = 0xFF00 + b[k]
                    k += 1
                    targets.append(t)
                    part = "$%02X" % b[k - 1]
                elif part.lstrip("[(").startswith("d"):
                    part = part.replace("d", "$%02X" % b[k], 1)
                    k += 1
                parts.append(part)
            ops = ", ".join(parts)
        out = mnem + " " + ops.replace(",", ", ").replace(",  ", ", ")
    if mnem == "jmp" and "[" in text:
        targets.append(None)
    if mnem == "tcall":
        targets.append(None)
    if mnem not in _STOPS:
        targets.append((pc + n) & 0xFFFF)
    return n, out, targets


def trace(mem, entries):
    """Addresses of the instructions reached from the entry points."""
    seen = {}
    todo = list(entries)
    while todo:
        pc = todo.pop()
        while pc is not None and pc not in seen:
            n, text, targets = decode(mem, pc)
            seen[pc] = (n, text)
            nxt = None
            for t in targets:
                if t is None:
                    continue
                if t == (pc + n) & 0xFFFF and text.split(" ", 1)[0] not in _STOPS:
                    nxt = t
                else:
                    todo.append(t)
            pc = nxt
    return seen


def listing(mem, addrs, labels=None):
    labels = labels or {}
    lines = []
    prev_end = None
    for pc in addrs:
        n, text, targets = decode(mem, pc, labels)
        if prev_end is not None and pc != prev_end:
            lines.append("")
        if pc in labels:
            lines.append("%s:" % labels[pc])
        raw = " ".join("%02X" % mem[(pc + k) & 0xFFFF] for k in range(n))
        lines.append("%04X  %-9s  %s" % (pc, raw, text))
        prev_end = pc + n
    return lines


def main(argv):
    if len(argv) < 3:
        print(__doc__)
        return 2
    data = open(argv[1], "rb").read()
    base = int(argv[2], 16)
    mem = bytearray(0x10000)
    mem[base:base + len(data)] = data
    if len(argv) > 3 and argv[3] == "--trace":
        seen = trace(mem, [int(a, 16) for a in argv[4:]])
        addrs = sorted(seen)
        labels = {}
        for pc in addrs:
            for t in decode(mem, pc)[2]:
                if t is not None and t != pc + seen[pc][0]:
                    labels.setdefault(t, "L%04X" % t)
        print("\n".join(listing(mem, addrs, labels)))
        return 0
    start = int(argv[3], 16) if len(argv) > 3 else base
    end = int(argv[4], 16) if len(argv) > 4 else base + len(data)
    pc = start
    addrs = []
    while pc < end:
        addrs.append(pc)
        pc += decode(mem, pc)[0]
    print("\n".join(listing(mem, addrs)))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
