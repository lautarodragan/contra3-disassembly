# Progress

**Milestone 1 is done:** the source in `src/` builds the original ROM byte
for byte (see [Building](building.md)), and it has been checked against the
emulator's code/data log (CDL): every byte the game executed in the traces
is decoded as code, nothing decoded as code is read as data, and the data
bank of every absolute operand is known. `src/` is now the source of truth;
the generator is a reference tool (see [The disassembler](disassembler.md)).

**Milestone 2 (names, many files) has started.** Done so far:

- `src/` is split into 80 files by subsystem (see [Source layout](layout.md));
- RAM operands are symbols from `src/ram.inc` (see [RAM map](ram-map.md)):
  about 10,900 operands (5,723 direct-page, 4,820 absolute, 220 long, 171
  indirect-jump pointers) now name one of 1,196 RAM addresses, most still
  placeholders; 306 direct-page operands that run (or may run) with D other
  than 0, and all indexed operands, are numbers on purpose;
- a rename tool and naming conventions for the parallel naming work (see
  [Contributing: naming](contributing.md)).

Still to do: real names for the routines, tables and variables. Milestones
3 and 4 (shiftable source, cheats; see the
[Introduction](introduction.md#goals)) have not started.

The rest of this page is `docs/disasm_report.md`, the report that
`tools/disasm.py` wrote along with the source in the CDL pass, included here
as it is in the repository so that there is one copy of the numbers. It
describes the generated source as committed in the CDL pass (one file per
bank, RAM operands still numbers); hand edits to `src/` don't update it.

How to read it:

- **Code vs. data.** Bytes the generator decoded as instructions are code;
  everything else is `.byte` data, including code that nothing the analysis
  can see calls. Code is only in banks `$00`-`$04` and `$1D`, each one
  contiguous block (the rest of those banks is data or `$FF` padding). The
  other banks are data: graphics and other data read by the decompressors
  in bank `$00`, the sound data uploaded to the sound CPU (banks `$1A`-`$1F`),
  tables in bank `$05`.
- **Comparison with the CDL.** "Confirmed" code ran in the traces;
  "static analysis only" code never ran (unexecuted branches, routines
  nothing in the traces called, the heuristically found routines). In the
  source, `; (not executed in the CDL traces)` marks where such code starts.
  Data bytes are split by how the CDL saw them; in the source each data
  block says who read it (`; CDL: read by ...`).
- **Operands as labels vs. numbers.** Operands that point into ROM with a
  known bank are labels; RAM addresses and other numbers are still numbers.
  No absolute or long operand is a hardcoded ROM address anymore; what is
  left for milestone 3 are immediates that are really pointers (counted as
  "other immediates") and pointers inside `.byte` data.
- **Absolute operands left as numbers.** The list after the tables gives
  every operand of `$8000` or more whose bank couldn't be established; it is
  empty now.

---

{{#include ../../docs/disasm_report.md:3:}}
