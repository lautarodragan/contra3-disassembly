# The cartridge

The US ROM is 1 MiB (1,048,576 bytes): 32 banks of 32 KiB in the LoROM
layout, with no coprocessor and no save RAM.

## Mapping

In LoROM each 32 KiB of the ROM file appears in the upper half
(`$8000-$FFFF`) of one bank: bank `$XX` holds file offsets `$XX * $8000` to
`$XX * $8000 + $7FFF`, so a CPU address in bank `$XX` is at file offset
`$XX * $8000` plus the address minus `$8000`:

| bank | CPU addresses | ROM file offsets | source |
|---|---|---|---|
| `$00` | `$00:8000-$00:FFFF` | `$00000-$07FFF` | `src/bank_00.asm` |
| `$01` | `$01:8000-$01:FFFF` | `$08000-$0FFFF` | `src/bank_01.asm` |
| ... | | | |
| `$1F` | `$1F:8000-$1F:FFFF` | `$F8000-$FFFFF` | `src/bank_1F.asm` |

The same ROM is also visible at banks `$80-$9F` (the "FastROM" mirror,
which the CPU can read faster when `MEMSEL` bit 0 is set). Contra III runs
entirely from banks `$00-$1F` at the slow speed:

- no decoded instruction writes `MEMSEL` (`$420D`); the name is only
  defined in `src/snes_registers.inc`;
- the vectors point into bank `$00`, and no long address in the decoded code
  points into `$80-$9F`.

That is why labels are named by their `$00-$1F` address (`sub_0090A8` is at
`$00:90A8`) and why `src/contra3.cfg` places bank `$XX` at `$XX:8000`. The
disassembler can label the `$80+` mirror instead (the `fastrom` hint, see
[The disassembler](disassembler.md#hints)); for this game it is off.

## The internal header

The header is at the end of bank `$00`, CPU `$00:FFC0-$00:FFDF` (file
offset `$7FC0`):

| address | value | field |
|---|---|---|
| `$FFC0-$FFD5` | "CONTRA3 THE ALIEN WARS" | title |
| `$FFD6` | `$00` | cartridge type: ROM only |
| `$FFD7` | `$0A` | ROM size: 2^10 KiB = 1 MiB |
| `$FFD8` | `$00` | SRAM size: none |
| `$FFD9` | `$01` | region: North America |
| `$FFDA` | `$A4` | licensee code (Konami's) |
| `$FFDB` | `$00` | version |
| `$FFDC` | `$F3C3` | checksum complement |
| `$FFDE` | `$0C3C` | checksum |

The checksum is the 16-bit sum of every byte of the ROM, and it matches:
the sum of the 1 MiB built by `make` is `$0C3C`, and `$0C3C + $F3C3 = $FFFF`.

### The title overflows into $FFD5

The title field is 21 bytes (`$FFC0-$FFD4`), and `$FFD5` is the map mode
byte, which for a LoROM SlowROM game is normally `$20`. Contra III's title,
"CONTRA3 THE ALIEN WARS", is 22 characters, and its last letter, the `S`
(`$53`), is at `$FFD5`. So the header has no valid map mode: tools that read
`$FFD5` to tell LoROM from HiROM, or SlowROM from FastROM, get `$53`. The
build reproduces it as it is, since it must match the original.

Because the developer ID at `$FFDA` is not `$33`, there is no extended
header at `$FFB0-$FFBF`. In fact the code of `sub_00FF48` ends with an `RTL`
at `$00:FFB1`, inside that area, and `$FFB2-$FFBF` are `$FF`.

In `src/bank_00.asm` the header and the vectors are plain `.byte` lines
right after that routine. (`tools/disasm.py` has an annotated header
writer, but it only uses it when the data before the header starts exactly
at `$FFB0`, which isn't the case here.)

## Vectors

The 65816 reads its interrupt vectors from `$00:FFE0-$00:FFFF`, one table
for native mode and one for emulation mode:

| vector | native (`$FFE4-$FFEF`) | emulation (`$FFF4-$FFFF`) |
|---|---|---|
| COP | `$8BE2` | `$8BE2` |
| BRK | `$8BE2` | (shared with IRQ) |
| ABORT | `$8BE2` | `$8BE2` |
| NMI | `$819B` | `$819B` |
| RESET | (none) | `$8000` |
| IRQ | `$8BE2` | `$8BE2` |
| unused | `$FFEC`: `$8000` | `$FFF6`: `$8BE2` |

So everything that isn't NMI or reset goes to `$00:8BE2`, which the hints
file names `irq`; NMI goes to `nmi` at `$00:819B`, and reset to `reset` at
`$00:8000`, the very first byte of the ROM. These three are the only names
in `tools/disasm_hints.json` so far, and the starting points of the
disassembler's recursive descent.

`reset` starts in emulation mode, switches to native mode (`CLC`, `XCE`),
disables interrupts, and sets the stack pointer to `$1DFF`,
the direct page to `$0000` and the data bank to `$05`.

One label sits inside the vector table: `data_00FFF6`, the unused emulation
vector. It exists because the generator turned an immediate pair in
`sub_01AE95` (`ldy #.loword(data_00FFF6)` and `lda #^data_00FFF6`) into a
pointer. Whether that really is a pointer is not known yet: `$FFF6` could
just as well be the number -10.
