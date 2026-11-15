# Contra III: The Alien Wars (USA) — disassembly

A ca65 disassembly of *Contra III: The Alien Wars* (SNES, USA) that rebuilds
the original ROM byte for byte:

    build/contra3.sfc  sha1: 265886e3f665adf2507e7b2f08b6b2ed9d0018b2

Status: milestone 1 (matching build from generated source). See
[`docs/disasm_report.md`](docs/disasm_report.md) for how much of the ROM is
decoded as code vs. data and how many operands are labels vs. numbers.

## Building

Requirements:

- GNU make
- [cc65](https://cc65.github.io/) 2.19 or newer (`ca65`, `ld65`).
  `sudo apt install cc65` on Debian/Ubuntu is enough.

```
make            # builds build/contra3.sfc and checks it against contra3.sha1
make compare    # same
make clean
```

The build does not need the original ROM: all code and data are in `src/`.
Never commit a ROM (`*.sfc` is ignored).

## Layout

| path | contents |
|---|---|
| `src/main.asm` | top-level file: includes every bank |
| `src/bank_XX.asm` | bank `$XX` (`$XX:8000-$XX:FFFF`), one ld65 segment `BANKXX` each |
| `src/contra3.cfg` | ld65 memory map: 32 LoROM banks of `$8000` at `$XX:8000` |
| `src/common.inc` | included by every bank (`.p816`, register names) |
| `src/snes_registers.inc` | SNES hardware register names (`INIDISP`, `NMITIMEN`, `DMAP0`, ...) |
| `contra3.sha1` | SHA-1 of the original ROM |
| `tools/disasm.py` | the disassembler that generated `src/` |
| `tools/disasm_hints.json` | hand-written hints for the disassembler |
| `tools/cdl.py` | reads the emulator's code/data log (CDL) as hints |
| `docs/disasm_report.md` | coverage / quality report written by the disassembler |

The game runs in banks `$00-$1F` (SlowROM; it never jumps to the `$80+`
mirrors), so labels are named and placed by their `$00-$1F` address, e.g.
`sub_0090A8` is at `$00:90A8`.

Label prefixes: `sub_` (called / dispatched routine), `loc_` (branch or jump
target), `tbl_` (jump table), `ptrs_` (table of data pointers), `data_`
(anything else referenced). Labels named in the hints file keep their name.

### Conventions in the source

- Operand sizes are always explicit so that the source assembles to the same
  bytes no matter what the symbols evaluate to: `a:` for absolute, `f:` for
  long, plain `$xx` for direct page. Immediate widths follow `.a8/.a16/.i8/.i16`
  directives, which the generator emits whenever the width changes (`.smart`
  is off).
- `mvn #src, #dst` / `mvp #src, #dst` (ca65 order; the machine code stores
  dst first).
- `BRK`/`COP`/`WDM` never appear as code; such bytes are data.
- Operands that point into ROM are labels whenever the bank is certain:
  branch/jump/call targets, long addresses, absolute addresses with a known
  data bank (DB is tracked through `PHK/PLB`, `LDA #n/PHA/PLB`, `PEA/PLB`,
  `MVN`), jump tables, recognised pointer immediates
  (`#.loword(label)` / `#^label`) and data-pointer tables (`.addr label`).
  Everything else is still a number; turning those into labels is part of
  making the source shiftable (milestone 3).

## The generator (`tools/disasm.py`)

```
make disasm BASEROM=path/to/original.sfc [CDL=path/to/contra3.cdl]
# or
python3 tools/disasm.py ROM [--hints tools/disasm_hints.json] [--cdl FILE] \
                            [--out src] [--report docs/disasm_report.md]
```

It is deterministic: rerunning it on the original ROM with the committed hints
reproduces `src/` exactly. **After milestone 1 the committed `src/` is the
source of truth** and is edited by hand (renames, comments, splitting into
files). From then on, run the generator with `--out` pointing to a scratch
directory and port its improvements by hand (or by a script) instead of
overwriting `src/`.

What it does (details in the module docstring):

1. Recursive descent from the reset/NMI/IRQ vectors and the hints' entry
   points, tracking M/X (`REP`/`SEP`, `PHP`/`PLP` pairs), DB and a model of
   the stack. Calls are assumed to preserve M/X unless the callee is known
   (hint or automatic inference) to return with other widths. The same
   instruction may be reached with different M/X as long as its length does
   not change.
2. Jump tables: `JMP (abs,X)`, `JSR (abs,X)`, `lda table,x / sta ptr /
   jmp (ptr)` and the long variant `lda t,y / sta ptr / lda t+2,y /
   sta ptr+2 / jml [ptr]`. Table length is guessed (stop at the first
   implausible pointer, existing code, a label, or a known entry point);
   the analysis is iterated until stable.
3. Unreferenced routines that follow the end of known code and decode
   plausibly (marked with a comment in the source).
4. Pointer recovery (immediates and data-pointer tables, see above).
5. Emission with forced operand sizes; labels inside instructions become
   `name = host + n`. Every label substitution is checked to evaluate to the
   original number.

### Hints (`tools/disasm_hints.json`)

The `_doc` key in the file lists every field: extra entry points, names,
comments, data ranges, M/X overrides, routines' return widths, no-return
routines, inline tables, jump-table lengths, routines taking ROM pointers in
registers, and addresses that must not be decoded.

### Feeding a CDL

The private repository's emulator tracer writes `cdl/contra3.cdl` (+
`contra3.cdl.json`), format "SNESCDL" v1. Pass it with `--cdl`. The loader
(`tools/cdl.py`) turns it into hints:

- every executed opcode's M/X (when unique) overrides the static guess;
- bytes only read as data / DMA'd are never decoded as code;
- call/jump/indirect-jump targets become entry points, and executed code
  still unreached is seeded;
- pointer addresses read by indirect jumps give minimum jump-table lengths;
- the DB seen at an instruction lets its absolute operand become a label.

## Roadmap

1. Matching disassembly (this).
2. Semantic names for all routines/variables, split into many files.
3. Shiftable: no hardcoded ROM addresses anywhere (code and data tables).
4. Optional cheats as build flags.
