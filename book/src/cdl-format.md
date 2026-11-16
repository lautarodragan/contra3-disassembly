# CDL format (SNESCDL v1)

The tracer writes two files:

* `cdl/contra3.cdl` — binary planes, one entry per ROM byte.
* `cdl/contra3.cdl.json` — sidecar: dynamic control flow, per-instruction
  DB/D values, statistics.

Both are produced by `tools/c3emu/cdl.py` (`Cdl.save` / `Cdl.load`), which is
the reference reader. Everything is little-endian.

## Addressing

All per-byte data is indexed by **ROM file offset** (the `.sfc` has no copier
header; 1 MiB = `0x100000` bytes). Contra III is LoROM:

```
offset  = ((bank & 0x7F) << 15) | (addr & 0x7FFF)        # addr >= $8000
address = (offset >> 15) << 16 | 0x8000 | (offset & 0x7FFF)   # bank $00-$1F
```

The game runs its code in banks `$00-$1F` (the SlowROM mirrors), so
CPU addresses in the sidecar are mostly `$00:8000-$1F:FFFF`; they are written
exactly as the CPU saw them (`"BB:AAAA"`), mirrors included.

## Binary file

| Offset          | Size        | Content                                         |
|-----------------|-------------|-------------------------------------------------|
| `0x00`          | 8           | magic `"SNESCDL\0"`                              |
| `0x08`          | u16         | version = 1                                      |
| `0x0A`          | u16         | header size H = 64                               |
| `0x0C`          | u32         | ROM size N                                       |
| `0x10`          | 20          | SHA-1 of the ROM (raw bytes; zero if unknown)    |
| `0x24`          | u32         | WRAM plane size W = `0x20000`                    |
| `0x28`          | 24          | reserved, zero                                   |
| `H`             | N           | **plane A**, one flag byte per ROM byte          |
| `H+N`           | N           | **plane B**, one flag byte per ROM byte          |
| `H+2N`          | W           | **WRAM plane**, plane-A flags for code run from WRAM (`$7E:0000-$7F:FFFF`, offset = `(bank & 1) << 16 | addr`; the `$0000-$1FFF` mirror in other banks maps to `$7E`) |
| `H+2N+W`        | 4·N         | **readers**: u32 per ROM byte                    |

### Plane A

| Bit | Mask | Name      | Meaning |
|-----|------|-----------|---------|
| 0   | 0x01 | `OPCODE`  | first byte of an executed instruction |
| 1   | 0x02 | `OPERAND` | non-first byte of an executed instruction (length from the opcode and the M/X state at that execution) |
| 2   | 0x04 | `DATA`    | read by the CPU as data (any instruction, 8 or 16 bit, incl. MVN/MVP sources, indirect-jump pointers, interrupt vectors). Operand fetches of the executing instruction are excluded. |
| 3   | 0x08 | `DMA`     | read as a general-DMA source or by HDMA (tables and data, direct and indirect) |
| 4   | 0x10 | `M0`      | opcode executed with M=0 (16-bit accumulator) |
| 5   | 0x20 | `M1`      | opcode executed with M=1 (8-bit accumulator; also forced in emulation mode) |
| 6   | 0x40 | `X0`      | opcode executed with X=0 (16-bit index) |
| 7   | 0x80 | `X1`      | opcode executed with X=1 (8-bit index) |

M/X bits are only set on `OPCODE` bytes. Both M0 and M1 set means the same
instruction ran in both widths (the disassembler must pick or split). For an
instruction whose length depends on M (or X), the `OPERAND` bytes are the
union of what was executed.

### Plane B

| Bit | Mask | Name       | Meaning |
|-----|------|------------|---------|
| 0   | 0x01 | `EMU`      | opcode executed in emulation mode (E=1) |
| 1   | 0x02 | `NATIVE`   | opcode executed in native mode (E=0) |
| 2   | 0x04 | `SUB`      | target of a JSR/JSL (direct or `JSR (a,X)`) — a subroutine entry |
| 3   | 0x08 | `JUMP`     | target of JMP/JML (any form), BRA/BRL or a *taken* conditional branch |
| 4   | 0x10 | `INDIRECT` | target of `JMP (a)`, `JMP (a,X)`, `JML [a]`, `JSR (a,X)` |
| 5   | 0x20 | `RETDISP`  | an RTS/RTL landed here and the bytes before it are not an executed JSR/JSL: a "push address, RTS" dispatch target |
| 6   | 0x40 | `IRQ`      | first instruction executed after an NMI/IRQ was taken, or BRK/COP target |
| 7   | 0x80 | `PTRTAB`   | read as the pointer of an indirect jump (jump table entry; 2 bytes, 3 for `JML [a]`) |

### Readers

`readers[i]` is `(24-bit CPU address of the first instruction that read ROM
byte i) + 1`, or 0 when unknown. For general DMA it is the instruction that
started the transfer (the write to `$420B`). HDMA reads and the interrupt
vector fetches have no reader (0). Use it to find the code that owns a table.

## JSON sidecar

```jsonc
{
  "format": "snescdl-sidecar", "version": 1,
  "rom_sha1": "265886e3...", "rom_size": 1048576,
  "flags_a": {"OPCODE": 1, ...}, "flags_b": {"EMU": 1, ...},
  "stats": {"rom_instructions": ..., "wram_instructions": ..., "other_instructions": ...},
  "coverage_bytes": {"code": ..., "data": ..., "both": ..., "unknown": ...},
  "flows": [ {...}, ... ],
  "wram_code": [[start, end], ...],
  "regs": [[offset, DB, D, count], ...]
}
```

* **`flows`** — every distinct dynamic control-flow edge, sorted by source:
  `{"op": "JMP (a,X)", "opcode": 124, "src": "00:8A12", "src_offset": 2578,
  "dst": "00:8B00", "dst_offset": 2816, "ptr": "00:8A40", "ptr_offset": 2624,
  "count": 37}`.
  * `opcode` is one of `0x6C JMP (a)`, `0x7C JMP (a,X)`, `0xDC JML [a]`,
    `0xFC JSR (a,X)`, `0x60 RTS`, `0x6B RTL`. RTS/RTL edges are only the
    dispatch ones (see `RETDISP`); normal returns are not listed.
  * `ptr` is the address the pointer was read from (`(a,X)` forms: bank of
    the instruction, `a+X`; `(a)` and `[a]`: bank 0), `null` for RTS/RTL.
    A `ptr` in WRAM (e.g. `00:0010`) has `ptr_offset: null`: that is a
    pointer variable, not a table.
  * `*_offset` are ROM offsets, `null` when the address is not ROM.
  * `count` is the number of times the edge was taken.
* **`wram_code`** — `[start, end)` WRAM offsets where code was executed.
* **`regs`** — for every executed ROM opcode, each distinct (DB, D) pair seen
  *at the start* of the instruction, with how many executions had it.
  Sorted by offset. Use the most common (or the only) DB to resolve absolute
  operands (`LDA $1234` reads `DB:1234`) and D for direct page.

## Classification used in reports

`code` = OPCODE|OPERAND, `data` = DATA|DMA (plane A) or PTRTAB (plane B),
`both` = both, `unknown` = neither. Unknown bytes are code or data that the
traces never reached, or padding.

## Merging

Planes are OR-ed; `readers` keep the first non-zero value; flow and regs
counts are summed (`python3 -m tools.c3emu.cdl merge out.cdl a.cdl b.cdl`).
