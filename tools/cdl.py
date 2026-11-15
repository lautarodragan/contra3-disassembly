"""Loader for the emulator's code/data log (CDL), as hints for tools/disasm.py.

The CDL is produced by the patched snes9x core in the private companion
repository (`make trace` there, which writes cdl/contra3.cdl and
cdl/contra3.cdl.json).  This module only *reads* it.  It follows the
"SNESCDL" version 1 specification (docs/CDL_FORMAT.md in that repository,
reference reader tools/c3emu/cdl.py there); if the format changes, adapt
load().

Binary file (little-endian), all per-byte planes indexed by ROM file offset:

    0x00  8   magic "SNESCDL\\0"
    0x08  u16 version (1)
    0x0A  u16 header size H (64)
    0x0C  u32 ROM size N
    0x10  20  SHA-1 of the ROM (zero if unknown)
    0x24  u32 WRAM plane size W (0x20000)
    H         plane A, N bytes:  01 OPCODE  02 OPERAND  04 DATA  08 DMA
                                 10 M0  20 M1  40 X0  80 X1 (M/X on opcodes only)
    H+N       plane B, N bytes:  01 EMU  02 NATIVE  04 SUB (JSR/JSL target)
                                 08 JUMP (JMP/JML/BRA/BRL/taken branch target)
                                 10 INDIRECT (target of JMP (a)/(a,X)/JML [a]/JSR (a,X))
                                 20 RETDISP (RTS/RTL "push address" dispatch target)
                                 40 IRQ (first instruction of an NMI/IRQ handler)
                                 80 PTRTAB (read as an indirect-jump pointer)
    H+2N      WRAM plane, W bytes (plane-A flags for code run from WRAM)
    H+2N+W    readers, N x u32: 24-bit PC + 1 of the first instruction that
              read the byte (for DMA: the write to $420B), 0 = unknown

JSON sidecar <file>.json: "flows" (dynamic jumps: opcode, src, dst, ptr and
their ROM offsets), "regs" ([offset, DB, D, count] for every executed opcode
and every distinct DB/D pair seen at the start of the instruction),
"wram_code", "stats", "coverage_bytes".

What the disassembler takes from it (class Cdl below):

  mx            ROM offset -> (m8, x8) for every executed opcode; each of
                m8/x8 is True/False, or None when the opcode ran with both
                widths (left to static analysis).
  executed      bytearray, 1 for every byte executed (opcode or operand).
  data_only     bytes read as data / DMA'd / used as jump pointers and never
                executed (never decoded as code).
  accessed      bytearray: plane A DATA|DMA bits (+ 0x80 for PTRTAB), 0 if
                the byte was never read.
  entries       ROM offset -> 'sub' (called, indirect, interrupt or
                RTS-dispatch target) or 'loc' (only jumped/branched to).
  table_hints   ROM offset of a jump table -> minimum number of entries,
                from the pointer addresses observed by indirect jumps whose
                pointer lives in ROM.
  db, d         ROM offset of an executed opcode -> frozenset of the DB / D
                values seen there.  For MVN/MVP the destination bank (which
                becomes DB after the first byte moved) is dropped when other
                values were also seen.
  readers       ROM offset -> CPU address of the first reader, or None.
  flows         the sidecar's flow records.
"""

import collections
import hashlib
import json
import os
import struct

MAGIC = b"SNESCDL\0"
HEADER = struct.Struct("<8sHHI20sI24x")
assert HEADER.size == 64

# plane A
OPCODE, OPERAND, DATA, DMA, M0, M1, X0, X1 = (1 << i for i in range(8))
# plane B
B_EMU, B_NATIVE, B_SUB, B_JUMP, B_INDIRECT, B_RETDISP, B_IRQ, B_PTRTAB = (1 << i for i in range(8))

INDIRECT_OPS = {0x6C, 0x7C, 0xDC, 0xFC}
BLOCK_MOVES = {0x44, 0x54}


def _lorom_offset(addr):
    bank, a = (addr >> 16) & 0xFF, addr & 0xFFFF
    if bank in (0x7E, 0x7F) or a < 0x8000:
        return None
    return (((bank & 0x7F) << 15) | (a & 0x7FFF)) & 0xFFFFF


def _addr(s):
    return int(s.replace(':', '').replace('$', ''), 16)


class Cdl:
    def __init__(self):
        self.name = None
        self.sha1 = None
        self.mx = {}
        self.executed = None
        self.data_only = set()
        self.accessed = None
        self.entries = {}
        self.table_hints = {}
        self.db = {}
        self.d = {}
        self.readers = None
        self.flows = []
        self.mx_both = 0          # opcodes seen with both M or both X widths

    def reader(self, off):
        r = self.readers[off] if self.readers is not None else 0
        return r - 1 if r else None


def load(path, rom):
    raw = open(path, 'rb').read()
    if len(raw) < HEADER.size:
        raise ValueError('%s: too short for a SNESCDL file' % path)
    magic, version, hsize, size, sha, wsize = HEADER.unpack_from(raw)
    if magic != MAGIC:
        raise ValueError('%s: not a SNESCDL file' % path)
    if version != 1:
        raise ValueError('%s: CDL format version %d not supported (expected 1)' % (path, version))
    if size != len(rom):
        raise ValueError('CDL is for a %d-byte ROM, this one has %d bytes' % (size, len(rom)))
    if any(sha) and sha != hashlib.sha1(rom).digest():
        raise ValueError('%s: CDL was recorded with a different ROM (SHA-1 mismatch)' % path)
    a = raw[hsize:hsize + size]
    b = raw[hsize + size:hsize + 2 * size]
    rd_at = hsize + 2 * size + wsize
    if len(raw) < rd_at + 4 * size:
        raise ValueError('%s: truncated (no readers plane)' % path)

    c = Cdl()
    c.name = os.path.basename(path)
    c.sha1 = hashlib.sha1(raw).hexdigest()
    c.readers = struct.unpack_from('<%dI' % size, raw, rd_at)
    c.executed = bytearray(size)
    c.accessed = bytearray(size)
    for off in range(size):
        v = a[off]
        w = b[off]
        if v & (OPCODE | OPERAND):
            c.executed[off] = 1
        if v & (DATA | DMA) or w & B_PTRTAB:
            c.accessed[off] = (v & (DATA | DMA)) | (0x80 if w & B_PTRTAB else 0)
            if not v & (OPCODE | OPERAND):
                c.data_only.add(off)
        if v & OPCODE:
            m = v & (M0 | M1)
            x = v & (X0 | X1)
            m8 = True if m == M1 else False if m == M0 else None
            x8 = True if x == X1 else False if x == X0 else None
            if m8 is None or x8 is None:
                c.mx_both += 1
            if w & B_EMU and not w & B_NATIVE:
                m8 = x8 = True
            c.mx[off] = (m8, x8)
            if w & (B_SUB | B_INDIRECT | B_IRQ | B_RETDISP):
                c.entries[off] = 'sub'
            elif w & B_JUMP:
                c.entries[off] = 'loc'

    side = path + '.json'
    if os.path.exists(side):
        j = json.load(open(side))
        ptrs = collections.defaultdict(set)    # (opcode, src offset) -> ptr offsets
        for fl in j.get('flows', []):
            op = fl['opcode']
            src = fl.get('src_offset')
            if src is None:
                src = _lorom_offset(_addr(fl['src']))
            ptr = fl.get('ptr_offset')
            c.flows.append(fl)
            if op in INDIRECT_OPS and src is not None and ptr is not None:
                ptrs[(op, src)].add(ptr)
        for (op, src), ps in ptrs.items():
            lo = rom[src + 1] | (rom[src + 2] << 8)
            if op in (0x7C, 0xFC):
                # (a,X): the table is in the program bank at a
                base = (src & ~0x7FFF) | (lo & 0x7FFF)
                size_ = 2
            else:
                # (a) / [a] with the pointer in ROM: the observed pointer
                # addresses are the table entries themselves
                base = min(ps)
                size_ = 3 if op == 0xDC else 2
            n = (max(ps) - base) // size_ + 1
            if n > 0:
                c.table_hints[base] = max(n, c.table_hints.get(base, 0))
        dbs = collections.defaultdict(set)
        ds = collections.defaultdict(set)
        for off, db, d, count in j.get('regs', []):
            dbs[off].add(db)
            ds[off].add(d)
        for off, s in dbs.items():
            if rom[off] in BLOCK_MOVES and len(s) > 1:
                s.discard(rom[off + 1])      # destination bank (machine order: dst, src)
            c.db[off] = frozenset(s)
        for off, s in ds.items():
            c.d[off] = frozenset(s)
    return c
