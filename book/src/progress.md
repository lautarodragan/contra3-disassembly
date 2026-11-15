# Progress

**Milestone 1 is done:** the source in `src/` builds the original ROM byte
for byte (see [Building](building.md)). Milestones 2 to 4 (names and files,
shiftable source, cheats; see the [Introduction](introduction.md#goals)) have
not started.

The rest of this page is `docs/disasm_report.md`, the report that
`tools/disasm.py` writes along with the source, included here as it is in
the repository so that there is one copy of the numbers. It describes the
generated source as committed; hand edits to `src/` don't update it.

How to read it:

- **Code vs. data.** Bytes the generator decoded as instructions are code;
  everything else is `.byte` data, including code that nothing the analysis
  can see calls. So far code was found only in banks `$00`-`$04` and `$1D`.
  The rest of the ROM is presumably mostly graphics, music and level data,
  but that hasn't been checked yet.
- **Operands as labels vs. numbers.** Operands that point into ROM with a
  known bank are labels; RAM addresses and other numbers are still numbers.
  Turning the remaining ROM addresses into labels is part of milestone 3.
- **Absolute operands left as numbers.** The last list gives every operand
  of `$8000` or more whose bank the generator couldn't establish: with DB
  unknown, or with DB `$7E`, where `$8000-$FFFF` is WRAM rather than ROM.

---

{{#include ../../docs/disasm_report.md:3:}}
