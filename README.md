# Contra III: The Alien Wars (USA) — disassembly

A ca65 disassembly of *Contra III: The Alien Wars* (SNES, USA) that rebuilds
the original ROM byte for byte:

    build/contra3.sfc  sha1: 265886e3f665adf2507e7b2f08b6b2ed9d0018b2

Status: milestone 1 (matching build), checked against the emulator's
code/data log (CDL). **`src/` is the source of truth** and is edited by hand;
the generator in `tools/` is kept for reference and research only. See
[`docs/disasm_report.md`](docs/disasm_report.md) for how much of the ROM is
decoded as code vs. data, how much of the code the CDL saw run, and how many
operands are labels vs. numbers.

**[The book](https://lautarodragan.github.io/contra3-disassembly/)** (sources
in [`book/`](book/)) explains the project at length: goals, building, the
cartridge and its header, how the disassembler works, progress, and (as they
get filled in) the RAM map and the routines.

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

### Checking in the emulator

`make` proves the ROM is identical to the original. To also run it, use the
emulator test suite of the private companion repository
(`contra3-disassembly-private`: snes9x libretro core, screenshots of the
intro, title, demos and every stage start compared with goldens):

```
make emu-test [PRIVATE=../contra3-disassembly-private]
```

It builds `build/contra3.sfc` (without requiring the hash to match, so it
also checks refactors that move code) and runs `make test ROM=...` in the
private repository (needs Python 3 + pytest + Pillow there; the first run
builds the core with `make cores`, which needs network access). About a
minute.

## Layout

| path | contents |
|---|---|
| `src/main.asm` | top-level file: includes every bank |
| `src/bank_XX.asm` | bank `$XX` (`$XX:8000-$XX:FFFF`), one ld65 segment `BANKXX` each |
| `src/contra3.cfg` | ld65 memory map: 32 LoROM banks of `$8000` at `$XX:8000` |
| `src/common.inc` | included by every bank (`.p816`, register names) |
| `src/snes_registers.inc` | SNES hardware register names (`INIDISP`, `NMITIMEN`, `DMAP0`, ...) |
| `contra3.sha1` | SHA-1 of the original ROM |
| `tools/disasm.py` | the disassembler that generated `src/` (reference only now) |
| `tools/disasm_hints.json` | hand-written hints for the disassembler |
| `tools/cdl.py` | reads the emulator's code/data log (CDL) for the disassembler |
| `docs/disasm_report.md` | coverage / quality report written by the disassembler with the CDL (included in the book's Progress page) |
| `book/` | the book (mdBook): `book.toml`, pages in `book/src/`, `names-ignore.txt` |
| `tools/check_book_names.py` | checks that every label, constant and path the book names exists |

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
  data bank (the DB each instruction ran with, from the CDL, or tracked
  statically through `PHK/PLB`, `LDA #n/PHA/PLB`, `PEA/PLB`, `MVN`), jump
  tables, recognised pointer immediates (`#.loword(label)` / `#^label`) and
  data-pointer tables (`.addr label`); a reference into the middle of a table
  is `table+n`. Everything else is still a number; turning the remaining
  ROM pointers (immediates, `f:$050000,x` bank bases, pointers inside
  `.byte` data) into labels is part of making the source shiftable
  (milestone 3).
- Comments from the CDL (the emulator's code/data log, see below):
  `; (not executed in the CDL traces)` where code that never ran in the
  traces starts; `; $1F8A (D=$1F00)` after a direct-page operand of an
  instruction that ran with the direct page register D other than 0 (the
  address really accessed); `; CDL: read by sub_..., DMA (started in
  sub_...)` or `; CDL: not accessed` above data, naming the routine of the
  first instruction that read it.
- The internal header and the vectors at the end of `bank_00.asm`
  (`rom_header`, `vectors`) have one line per field with a comment.

## The generator (`tools/disasm.py`)

**`src/` is the source of truth.** The generator produced it (last time
with the CDL, see below) and is now a reference / research tool: run it into
a scratch directory, compare, and port improvements to `src/` by hand or by
a script. By default it writes into `build/disasm/`, never into `src/`.

```
make disasm BASEROM=path/to/original.sfc [CDL=path/to/contra3.cdl]
# or
python3 tools/disasm.py ROM [--hints tools/disasm_hints.json] [--cdl FILE] \
                            [--out build/disasm/src] [--report build/disasm/disasm_report.md]
diff -r src build/disasm/src
```

It is deterministic: with the committed hints and the same CDL it reproduces
the generated `src/` and `docs/disasm_report.md` exactly (the report records
the CDL's SHA-1). Without a CDL the output is close but differs (no CDL
comments, a few operands stay numbers, a few false pointers come back).

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
comments, data ranges, M/X/DB overrides, routines' return widths, no-return
routines, inline tables, jump-table lengths, routines taking ROM pointers in
registers, and addresses that must not be decoded.

### Feeding a CDL

The private repository's emulator tracer writes `cdl/contra3.cdl` (+
`contra3.cdl.json`), format "SNESCDL" v1 (spec in that repository's
`docs/CDL_FORMAT.md`; summary in the docstring of `tools/cdl.py`). Pass it
with `--cdl`. The generator uses it this way:

- every executed opcode's M/X (per flag, when unique) and DB override the
  static guesses; D values other than 0 are written as comments;
- bytes only read as data / DMA'd are never decoded as code (jump tables are
  read as data too and are still scanned);
- executed code still unreached is seeded (none for this game);
- pointer addresses read by indirect jumps give minimum jump-table lengths;
- pointer candidates whose code ran but whose target was never read are
  rejected;
- the comments described under "Conventions" above.

The result of the comparison (every executed byte was already decoded, no
conflicts, the numbers per category) is in the report and in the book's
"The disassembler" page.

## The book

```
make book-check     # every label/constant/path the book names must exist
make book           # book-check + mdbook build book (needs mdBook v0.5.4)
```

`.github/workflows/book.yml` runs the check, builds the book and deploys it
to GitHub Pages on pushes to `main` that touch `book/`, the report, the
checker or the workflow. For the deploy to work, the repository's Pages
source must be set to **GitHub Actions** (Settings → Pages → Build and
deployment → Source). When you rename a label, fix the pages that name it in
the same commit, or the check fails.

## Roadmap

1. Matching disassembly (this).
2. Semantic names for all routines/variables, split into many files.
3. Shiftable: no hardcoded ROM addresses anywhere (code and data tables).
4. Optional cheats as build flags.
