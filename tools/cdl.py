"""Loader for the emulator's code/data log (CDL), as hints for tools/disasm.py.

The CDL is produced by the patched snes9x core in the contra3-disassembly-private
repository (`make trace` there).  This module only *reads* it; it is written
against format version 1 (64-byte header "SNESCDL\\0", plane A, plane B, WRAM
plane, plus a JSON sidecar <file>.json).  If the format changes, adapt load().

What the disassembler takes from it (class Cdl below):
  code_starts   ROM offset -> (m8, x8) for every executed opcode whose M/X
                widths were unique; offsets executed with both widths are in
                mx_ambiguous and are left to static analysis.
  data_offsets  bytes read as data / DMA'd and never executed.
  table_hints   ROM offset of a jump table -> number of entries, from the
                pointer addresses observed by indirect jumps (JMP (a,X),
                JSR (a,X), JMP (a), JML [a]) when the pointer lives in ROM.
  db            ROM offset of an instruction -> DB value, when only one DB was
                ever seen there (lets absolute operands become labels).
  extra_entries ROM offsets that were jump/call/indirect targets.

Usage: python3 tools/disasm.py ROM --cdl path/to/contra3.cdl
"""

import collections
import json
import os
import struct

MAGIC = b"SNESCDL\0"
HEADER = struct.Struct("<8sHHI20sI24x")

# plane A
OPCODE, OPERAND, DATA, DMA, M0, M1, X0, X1 = (1 << i for i in range(8))
# plane B
B_EMU, B_NATIVE, B_SUB, B_JUMP, B_INDIRECT, B_RETDISP, B_IRQ, B_PTRTAB = (1 << i for i in range(8))

INDIRECT_OPS = {0x6C, 0x7C, 0xDC, 0xFC}


def _lorom_offset(addr):
    bank, a = (addr >> 16) & 0xFF, addr & 0xFFFF
    if bank in (0x7E, 0x7F) or a < 0x8000:
        return None
    return (((bank & 0x7F) << 15) | (a & 0x7FFF)) & 0xFFFFF


def _addr(s):
    return int(s.replace(':', '').replace('$', ''), 16)


class Cdl:
    def __init__(self):
        self.code_starts = {}
        self.mx_ambiguous = set()
        self.data_offsets = set()
        self.table_hints = {}
        self.db = {}
        self.extra_entries = set()
        self.flows = []


def load(path, rom):
    raw = open(path, 'rb').read()
    magic, version, hsize, size, sha, wsize = HEADER.unpack_from(raw)
    if magic != MAGIC:
        raise ValueError('%s: not a SNESCDL file' % path)
    if version != 1:
        raise ValueError('%s: CDL format version %d not supported (expected 1)' % (path, version))
    if size != len(rom):
        raise ValueError('CDL is for a %d-byte ROM' % size)
    a = raw[hsize:hsize + size]
    b = raw[hsize + size:hsize + 2 * size]
    c = Cdl()
    for off in range(size):
        v = a[off]
        if v & OPCODE:
            m = v & (M0 | M1)
            x = v & (X0 | X1)
            if m in (M0, M1) and x in (X0, X1):
                c.code_starts[off] = (m == M1, x == X1)
            else:
                c.mx_ambiguous.add(off)
        elif not (v & OPERAND) and (v & (DATA | DMA) or b[off] & B_PTRTAB):
            c.data_offsets.add(off)
        if b[off] & (B_SUB | B_JUMP | B_INDIRECT) and v & OPCODE:
            c.extra_entries.add(off)

    side = path + '.json'
    if os.path.exists(side):
        j = json.load(open(side))
        ptrs = collections.defaultdict(set)    # (opcode, src offset) -> ptr offsets
        for fl in j.get('flows', []):
            op = fl['opcode']
            src = _lorom_offset(_addr(fl['src']))
            ptr = _lorom_offset(_addr(fl['ptr'])) if fl.get('ptr') else None
            c.flows.append(fl)
            if op in INDIRECT_OPS and src is not None and ptr is not None:
                ptrs[(op, src)].add(ptr)
        for (op, src), ps in ptrs.items():
            lo = rom[src + 1] | (rom[src + 2] << 8)
            if op in (0x7C, 0xFC):
                base = (src & ~0x7FFF) | (lo & 0x7FFF)
                size_ = 2
            else:
                # pointer copied from a table into RAM: the observed pointer
                # addresses are the table entries themselves
                base = min(ps)
                size_ = 3 if op == 0xDC else 2
            n = (max(ps) - base) // size_ + 1
            if n > 0:
                c.table_hints[base] = max(n, c.table_hints.get(base, 0))
        dbs = collections.defaultdict(set)
        for off, db, d, count in j.get('regs', []):
            dbs[off].add(db)
        for off, s in dbs.items():
            if len(s) == 1:
                c.db[off] = next(iter(s))
    return c
