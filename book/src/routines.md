# Routines

> **Stub.** This page will list the game's routines by subsystem as they get
> names (milestone 2). Only the entry points below are named so far; what is
> known about each part of the code is in the headers of the files in
> `src/` (see [Source layout](layout.md)).

## Entry points

| label | address | what |
|---|---|---|
| `reset` | `$00:8000` | reset vector |
| `nmi` | `$00:819B` | NMI (vertical blank) vector |
| `irq` | `$00:8BE2` | IRQ vector; also COP, BRK and ABORT |

See [The cartridge](cartridge.md#vectors) for the vector table.

Every other routine is still named by its address, `sub_` plus six hex
digits (for example `sub_00FF48` at `$00:FF48`). The number of routines and
jump tables found is in [Progress](progress.md).

When you name a routine, add it here with what it does, its inputs and
outputs (registers, M/X widths, RAM), and how you know.
