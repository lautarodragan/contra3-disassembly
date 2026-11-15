"""A minimal CDL-guided 65816 disassembler, for poking around while tracing.

It is a debugging aid for this harness, not the project's disassembler: it
shows a range of ROM using the CDL to pick M/X widths and to tell code from
data.

    python3 -m tools.c3emu.dis 00:AD40 00:AD90 [--cdl cdl/contra3.cdl]
"""
import argparse
import sys

from . import cdl as C
from .rom import rom_path

# mnemonic, addressing mode
_T = """
BRK s|ORA dxi|COP s|ORA sr|TSB d|ORA d|ASL d|ORA dil|PHP i|ORA #m|ASL A|PHD i|TSB a|ORA a|ASL a|ORA al
BPL r|ORA diy|ORA di|ORA siy|TRB d|ORA dx|ASL dx|ORA dily|CLC i|ORA ay|INC A|TCS i|TRB a|ORA ax|ASL ax|ORA alx
JSR a|AND dxi|JSL al|AND sr|BIT d|AND d|ROL d|AND dil|PLP i|AND #m|ROL A|PLD i|BIT a|AND a|ROL a|AND al
BMI r|AND diy|AND di|AND siy|BIT dx|AND dx|ROL dx|AND dily|SEC i|AND ay|DEC A|TSC i|BIT ax|AND ax|ROL ax|AND alx
RTI i|EOR dxi|WDM #1|EOR sr|MVP bm|EOR d|LSR d|EOR dil|PHA i|EOR #m|LSR A|PHK i|JMP a|EOR a|LSR a|EOR al
BVC r|EOR diy|EOR di|EOR siy|MVN bm|EOR dx|LSR dx|EOR dily|CLI i|EOR ay|PHY i|TCD i|JML al|EOR ax|LSR ax|EOR alx
RTS i|ADC dxi|PER rl|ADC sr|STZ d|ADC d|ROR d|ADC dil|PLA i|ADC #m|ROR A|RTL i|JMP ai|ADC a|ROR a|ADC al
BVS r|ADC diy|ADC di|ADC siy|STZ dx|ADC dx|ROR dx|ADC dily|SEI i|ADC ay|PLY i|TDC i|JMP axi|ADC ax|ROR ax|ADC alx
BRA r|STA dxi|BRL rl|STA sr|STY d|STA d|STX d|STA dil|DEY i|BIT #m|TXA i|PHB i|STY a|STA a|STX a|STA al
BCC r|STA diy|STA di|STA siy|STY dx|STA dx|STX dy|STA dily|TYA i|STA ay|TXS i|TXY i|STZ a|STA ax|STZ ax|STA alx
LDY #x|LDA dxi|LDX #x|LDA sr|LDY d|LDA d|LDX d|LDA dil|TAY i|LDA #m|TAX i|PLB i|LDY a|LDA a|LDX a|LDA al
BCS r|LDA diy|LDA di|LDA siy|LDY dx|LDA dx|LDX dy|LDA dily|CLV i|LDA ay|TSX i|TYX i|LDY ax|LDA ax|LDX ay|LDA alx
CPY #x|CMP dxi|REP #1|CMP sr|CPY d|CMP d|DEC d|CMP dil|INY i|CMP #m|DEX i|WAI i|CPY a|CMP a|DEC a|CMP al
BNE r|CMP diy|CMP di|CMP siy|PEI d|CMP dx|DEC dx|CMP dily|CLD i|CMP ay|PHX i|STP i|JML ail|CMP ax|DEC ax|CMP alx
CPX #x|SBC dxi|SEP #1|SBC sr|CPX d|SBC d|INC d|SBC dil|INX i|SBC #m|NOP i|XBA i|CPX a|SBC a|INC a|SBC al
BEQ r|SBC diy|SBC di|SBC siy|PEA a|SBC dx|INC dx|SBC dily|SED i|SBC ay|PLX i|XCE i|JSR axi|SBC ax|INC ax|SBC alx
"""
OPS = [tuple(x.split()) for x in "|".join(_T.split("\n")[1:-1]).split("|")]
assert len(OPS) == 256
SIZES = {"s": 1, "i": 0, "A": 0, "#1": 1, "d": 1, "dx": 1, "dy": 1, "dxi": 1,
         "di": 1, "diy": 1, "dil": 1, "dily": 1, "sr": 1, "siy": 1, "r": 1,
         "a": 2, "ax": 2, "ay": 2, "ai": 2, "axi": 2, "ail": 2, "rl": 2,
         "bm": 2, "al": 3, "alx": 3}
FMT = {"s": "#${0:02X}", "i": "", "A": "A", "#1": "#${0:02X}", "#m": "#${0:0{w}X}",
       "#x": "#${0:0{w}X}", "d": "${0:02X}", "dx": "${0:02X},X", "dy": "${0:02X},Y",
       "dxi": "(${0:02X},X)", "di": "(${0:02X})", "diy": "(${0:02X}),Y",
       "dil": "[${0:02X}]", "dily": "[${0:02X}],Y", "sr": "${0:02X},S",
       "siy": "(${0:02X},S),Y", "a": "${0:04X}", "ax": "${0:04X},X",
       "ay": "${0:04X},Y", "ai": "(${0:04X})", "axi": "(${0:04X},X)",
       "ail": "[${0:04X}]", "al": "${0:06X}", "alx": "${0:06X},X"}


def length(op, m8=True, x8=True):
    mode = OPS[op][1]
    if mode == "#m":
        return 2 if m8 else 3
    if mode == "#x":
        return 2 if x8 else 3
    return 1 + SIZES[mode]


def disasm(rom, off, addr, m8=True, x8=True):
    op = rom[off]
    mn, mode = OPS[op]
    n = length(op, m8, x8)
    raw = rom[off:off + n]
    val = int.from_bytes(raw[1:], "little") if n > 1 else 0
    if mode == "r":
        text = "$%04X" % ((addr + 2 + (val - 256 if val > 127 else val)) & 0xFFFF)
    elif mode == "rl":
        text = "$%04X" % ((addr + 3 + val) & 0xFFFF)
    elif mode == "bm":
        text = "$%02X,$%02X" % (raw[2], raw[1])
    else:
        text = FMT[mode].format(val, w=2 * (n - 1))
    return n, "%s %s" % (mn, text) if text else mn, raw


def parse_addr(s):
    return int(s.replace(":", "").replace("$", ""), 16)


def main(argv):
    ap = argparse.ArgumentParser()
    ap.add_argument("start")
    ap.add_argument("end")
    ap.add_argument("--cdl", default="cdl/contra3.cdl")
    args = ap.parse_args(argv)
    rom = open(rom_path(), "rb").read()
    log = C.Cdl.load(args.cdl)
    a, end = parse_addr(args.start), parse_addr(args.end)
    while a < end:
        off = C.lorom_offset(a)
        fa, fb = log.a[off], log.b[off]
        tags = "".join(k[0] for k, v in (("SUB", C.B_SUB), ("JUMP", C.B_JUMP),
                       ("INDIRECT", C.B_INDIRECT), ("RETDISP", C.B_RETDISP)) if fb & v)
        if fa & C.OPCODE:
            m8 = not (fa & C.M0) if fa & (C.M0 | C.M1) else True
            x8 = not (fa & C.X0) if fa & (C.X0 | C.X1) else True
            n, text, raw = disasm(rom, off, a & 0xFFFF, m8, x8)
            mx = ("m" if fa & C.M0 else "") + ("M" if fa & C.M1 else "") + \
                 ("x" if fa & C.X0 else "") + ("X" if fa & C.X1 else "")
            print("%s %-4s %-12s %-16s ; %s" % (C.fmt(a), tags, raw.hex(" "), text, mx))
            a += n
        else:
            kind = C.Cdl.classify(log, off)
            print("%s %-4s %02X  .byte          ; %s" % (C.fmt(a), tags, rom[off], kind))
            a += 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
