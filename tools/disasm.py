#!/usr/bin/env python3
"""Recursive-descent 65816 disassembler for Contra III (LoROM) emitting ca65 source.

Usage:
    python3 tools/disasm.py ROM.sfc [--hints tools/disasm_hints.json]
                            [--cdl PATH] [--out src] [--report report.md]

The output (src/bank_XX.asm, src/contra3.cfg, ...) is meant to be committed and
then edited by hand; this tool only (re)generates a starting point.  All of its
knowledge that was not derived automatically lives in the hints file, so a rerun
(e.g. when a CDL becomes available) reproduces and improves the same output.

How it works
------------
1. Seeds: the reset/NMI/IRQ vectors, the hints' entry points, and (optionally)
   every instruction start found in a CDL.
2. Recursive descent with a worklist.  Each path carries a CPU state:
   M/X widths, the data bank (DB, when known), a model of the bytes pushed
   since the routine entry (to understand PHP/PLP, PHK/PLB, LDA #n/PHA/PLB,
   PEA/PLB) and the last immediate loaded into A.
   * REP/SEP change M/X; PLP restores the M/X saved by the matching PHP.
   * JSR/JSL: the callee is queued with the caller's state; decoding resumes
     after the call assuming M/X/DB survive the call, unless a hint (or the
     automatic return-state inference, see below) says otherwise.
   * Branches, JMP/JML/BRL follow their targets.
   * JMP (abs,X) / JSR (abs,X) read a table of words in the program bank.
     Its length is guessed (stop at the first non-pointer, at the first byte
     that is already code or labelled, or at the lowest target) unless a
     hint gives it.
   * BRK/COP/WDM/STP are treated as "this is not code": decoding stops before
     them.  A hint can force them.
   * lda table,x / sta ptr / jmp (ptr) and the long form ending in
     jml [ptr] (3-byte entries) are recognised as jump tables too.
3. Return-state inference: after a pass, routines whose every RTS/RTL leaves
   M/X different from the entry state are recorded and the analysis reruns,
   so callers resume with the right widths.
4. Unreferenced routines: code right after the end of a routine (RTS, RTL,
   JMP, BRA...) that decodes into a plausible routine is decoded too and
   marked with a comment.  With a CDL, executed code not reached statically
   is seeded first.
5. Pointer recovery (after decoding): lda #lo/sta p + lda #bank/sta p+2
   pairs, ROM pointers passed in X to routines that read f:$BB0000,x, and
   tables of 16-bit data pointers (read via (dp),y or passed to such
   routines) become label expressions / .addr tables.
6. Emission: every byte not decoded as an instruction is emitted as data.
   Operands that point into ROM become labels when the bank is certain (code
   targets, long addresses, absolute addresses with a known DB, jump tables);
   everything else stays a number.  Operand sizes are forced (a:, f:, z: is
   implicit for numbers < $100) and .a8/.a16/.i8/.i16 are emitted whenever the
   width of the next instruction differs from the assembler's current notion.
"""

import argparse
import collections
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from opcodes65816 import OPCODES, operand_len, BRANCHES  # noqa: E402
import snes_regs  # noqa: E402

BANK_SIZE = 0x8000
NUM_BANKS = 32
ROM_SIZE = BANK_SIZE * NUM_BANKS

SUSPICIOUS = {'brk', 'cop', 'wdm', 'stp'}
# instructions that change the accumulator (for the "A holds a known
# immediate" tracker used to resolve LDA #n / PHA / PLB)
A_WRITERS = {'lda', 'pla', 'adc', 'sbc', 'and', 'ora', 'eor', 'txa', 'tya',
             'tdc', 'tsc', 'xba', 'mvn', 'mvp'}
A_RMW_ACC = {'asl', 'lsr', 'rol', 'ror', 'inc', 'dec'}


# ---------------------------------------------------------------------------
# address helpers
# ---------------------------------------------------------------------------

def parse_addr(s):
    """'00:8000', '$008000', '0x8000', '008000' or int -> 24-bit int."""
    if isinstance(s, int):
        return s
    s = s.strip().replace('$', '').replace('0x', '')
    if ':' in s:
        b, a = s.split(':')
        return (int(b, 16) << 16) | int(a, 16)
    return int(s, 16)


def fmt_addr(a):
    return '%02X:%04X' % (a >> 16, a & 0xFFFF)


def rom_offset(addr):
    """CPU address -> ROM file offset, or None if not ROM.

    Only the canonical banks $00-$1F (and their FastROM mirrors $80-$9F) are
    accepted: this game does not use the other mirrors, and accepting them
    would make labels ambiguous."""
    bank = (addr >> 16) & 0xFF
    lo = addr & 0xFFFF
    if lo < 0x8000:
        return None
    b = bank & 0x7F
    if b >= NUM_BANKS:
        return None
    return b * BANK_SIZE + (lo - 0x8000)


class Config:
    def __init__(self, fastrom=False):
        self.fastrom = fastrom

    def canon(self, offset):
        """ROM offset -> canonical CPU address used for labels."""
        bank = offset // BANK_SIZE
        if self.fastrom:
            bank |= 0x80
        return (bank << 16) | (0x8000 + offset % BANK_SIZE)


# ---------------------------------------------------------------------------
# analysis state
# ---------------------------------------------------------------------------

State = collections.namedtuple('State', 'm8 x8 db stack a_imm routine')


class Instr:
    __slots__ = ('off', 'op', 'mn', 'mode', 'length', 'operand', 'm8', 'x8',
                 'db', 'target', 'force')

    def __init__(self, off, op, mn, mode, length, operand, m8, x8, db):
        self.off = off
        self.op = op
        self.mn = mn
        self.mode = mode
        self.length = length
        self.operand = operand
        self.m8 = m8
        self.x8 = x8
        self.db = db
        self.target = None   # resolved ROM offset of a code target
        self.force = False


class Disassembler:
    def __init__(self, rom, hints, cfg, cdl=None):
        self.rom = rom
        self.hints = hints
        self.cfg = cfg
        self.cdl = cdl
        self.warnings = []

        # ROM offsets the hints say are data
        self.data_mask = bytearray(ROM_SIZE)
        for r in hints.get('data', []):
            s = rom_offset(parse_addr(r['start']))
            e = rom_offset(parse_addr(r['end']))
            for i in range(s, e + 1):
                self.data_mask[i] = 1
        if cdl:
            for off in cdl.data_offsets:
                self.data_mask[off] = 1

        self.mx_override = {}
        for k, v in hints.get('mx_overrides', {}).items():
            self.mx_override[rom_offset(parse_addr(k))] = v
        self.call_returns = {}
        for k, v in hints.get('call_returns', {}).items():
            self.call_returns[rom_offset(parse_addr(k))] = v
        self.noreturn = {rom_offset(parse_addr(a)) for a in hints.get('noreturn', [])}
        self.inline_tables = {}
        for k, v in hints.get('inline_tables', {}).items():
            self.inline_tables[rom_offset(parse_addr(k))] = v
        self.table_hints = {}
        for t in hints.get('jump_tables', []):
            self.table_hints[rom_offset(parse_addr(t['addr']))] = t
        if cdl:
            for base, n in cdl.table_hints.items():
                self.table_hints.setdefault(base, {'min_count': n})
        self.force_code = {rom_offset(parse_addr(a)) for a in hints.get('force_code', [])}
        self.no_table_at = {rom_offset(parse_addr(a)) for a in hints.get('no_auto_table', [])}

        self.auto_call_returns = {}

    # -- decoding ---------------------------------------------------------

    def decode(self, off, m8, x8):
        op = self.rom[off]
        mn, mode = OPCODES[op]
        n = operand_len(mode, m8, x8)
        if (off % BANK_SIZE) + 1 + n > BANK_SIZE:
            return None
        operand = int.from_bytes(self.rom[off + 1:off + 1 + n], 'little') if n else None
        return Instr(off, op, mn, mode, 1 + n, operand, m8, x8, None)

    def pc_bank(self, off):
        return self.cfg.canon(off) >> 16

    # -- main analysis ----------------------------------------------------

    def run(self, speculate=True):
        # Iterate: each pass knows the code entry points found by the previous
        # one (so table scans stop in front of them) and the inferred call
        # return states.  Stop when nothing changes.  Then (optionally) look
        # for unreferenced routines right after the end of known code and
        # repeat.
        self.prev_code_entries = set()
        self.speculative = {}     # off -> (m8, x8)
        self.spec_source = {}     # off -> 'cdl' | 'heuristic'
        self.passes = 0
        self.no_speculate = {rom_offset(parse_addr(a)) for a in self.hints.get('not_code', [])}
        for rnd in range(40):
            for it in range(10):
                self.passes += 1
                changed = self._pass()
                entries = set(self.direct_targets)
                sig = (frozenset(entries), tuple(sorted((k, len(v[1])) for k, v in self.tables.items())))
                if not changed and sig == getattr(self, '_sig', None):
                    break
                self._sig = sig
                self.prev_code_entries = entries
            if not speculate:
                break
            self._banks_cache = self._code_banks()
            new = self._cdl_unreached() if self.cdl else {}
            src = 'cdl'
            if not new:
                new = self._find_unreferenced()
                src = 'heuristic'
            if not new:
                break
            self.speculative.update(new)
            for o in new:
                self.spec_source[o] = src

    # -- immediate pointers -----------------------------------------------

    def find_immediate_pointers(self):
        """Find long pointers built from immediates, e.g.
               lda #$9A3C / sta $00 / sep #$20 / lda #$05 / sta $02
        (also with ldx/stx, ldy/sty, in either order, within a few
        instructions of straight-line code).  When the pair forms a ROM
        address, both immediates become label expressions
        (#.loword(label) / #^label)."""
        self.imm_ptrs = {}
        loads = {'sta': 'lda', 'stx': 'ldx', 'sty': 'ldy'}
        stores = []   # (off, addr, value, width8, load instr)
        for off in sorted(self.instrs):
            ins = self.instrs[off]
            if ins.mn not in loads or ins.mode not in ('dp', 'abs', 'long'):
                continue
            # immediate load directly before (fall-through predecessor)
            prev = None
            for back in (2, 3):
                p = self.instrs.get(off - back)
                if p is not None and p.length == back:
                    prev = p
                    break
            if prev is None or prev.mn != loads[ins.mn] or prev.mode not in ('immm', 'immx'):
                continue
            addr = ins.operand
            stores.append((off, addr, prev.operand, prev.length == 2, prev))
        n = len(stores)
        for i in range(n):
            off, addr, val, w8, ld = stores[i]
            if w8 or val < 0x8000:
                continue
            for j in range(max(0, i - 4), min(n, i + 5)):
                if j == i:
                    continue
                off2, addr2, val2, w82, ld2 = stores[j]
                if abs(off2 - off) > 24 or addr2 != addr + 2:
                    continue
                bank = val2 & 0xFF
                if (not w82 and val2 > 0xFF) or (w82 and val2 > 0xFF) or val2 > 0xFF:
                    continue
                tgt = rom_offset((bank << 16) | val)
                if tgt is None or self.cfg.canon(tgt) != ((bank << 16) | val):
                    continue
                if ld.off in self.imm_ptrs or ld2.off in self.imm_ptrs:
                    continue
                self.imm_ptrs[ld.off] = ('lo', tgt)
                self.imm_ptrs[ld2.off] = ('bank', tgt)
                self.labels.setdefault(tgt, 'data')
                break

    def find_data_pointer_tables(self):
        """Tables of 16-bit data pointers:
               lda table,x|y   (M16, DB known)
               sta ptr         (direct page)
               ...             (straight-line, <= 12 instructions)
               lda (ptr),y     (any instruction using (ptr) or (ptr),y)
        The table is read while its entries are >= $8000, do not run into
        code, labels or other tables.  Entries become `.addr label` where
        the label is in the bank DB had at the indirect access."""
        self.data_tables = {}
        for start, bank in getattr(self, 'pending_ptr_tables', []):
            if start not in self.data_tables:
                self._add_data_ptr_table(start, bank)
        ends = ('rts', 'rtl', 'rti', 'jmp', 'jml', 'bra', 'brl')
        for off in sorted(self.instrs):
            ld = self.instrs[off]
            if ld.mn != 'lda' or ld.m8 or ld.mode not in ('absx', 'absy', 'abs'):
                continue
            if ld.db is None:
                continue
            st_ = self.instrs.get(off + ld.length)
            if st_ is None or st_.mn != 'sta' or st_.mode != 'dp':
                continue
            ptr = st_.operand
            cur = st_.off + st_.length
            use = None
            for _ in range(12):
                ins = self.instrs.get(cur)
                if ins is None:
                    break
                if ins.mode in ('dpi', 'dpiy') and ins.operand == ptr and ins.mn != 'pei':
                    use = ins
                    break
                if ins.mn in ends or ins.mn in ('jsr', 'jsl'):
                    break
                if ins.operand == ptr and ins.mode == 'dp' and ins.mn.startswith('st'):
                    break
                cur += ins.length
            if use is None or use.db is None:
                continue
            start = rom_offset((ld.db << 16) | ld.operand)
            if start is None or start in self.data_tables or start in self.tables:
                continue
            self._add_data_ptr_table(start, use.db, 1 if ld.mode == 'abs' else 256)

    def _add_data_ptr_table(self, start, bank, maxn=256):
        targets = []
        o = start
        limit = (start // BANK_SIZE + 1) * BANK_SIZE
        while o + 2 <= limit and len(targets) < maxn:
            if o != start and o in self.labels:
                break
            if any(i in self.owner or i in self.table_bytes for i in (o, o + 1)):
                break
            if o + 1 in self.labels:
                break
            v = self.rom[o] | (self.rom[o + 1] << 8)
            t = rom_offset((bank << 16) | v)
            if v < 0x8000 or t is None or t in self.owner or t in self.table_bytes:
                break
            if start <= t < o + 2:
                break
            targets.append(t)
            o += 2
        if not targets:
            return
        self.data_tables[start] = (targets, 2)
        for i in range(start, start + 2 * len(targets)):
            self.table_bytes.add(i)
        if self.labels.get(start) in (None, 'data'):
            self.labels[start] = 'ptrs'
        for t in targets:
            self.labels.setdefault(t, 'data')

    def find_pointer_args(self):
        """Routines that take a ROM pointer in X or Y: detected when the
        routine reads `f:$BB0000,x` (or ,y) before changing the register, or
        declared in the hints ("pointer_args": {"00:90A8": {"reg": "x",
        "bank": "05"}}).  At each call site, the closest preceding
        `ldx #imm` / `ldy #imm` in straight-line code becomes a label."""
        writes = {'x': {'ldx', 'tax', 'tsx', 'tyx', 'plx', 'inx', 'dex'},
                  'y': {'ldy', 'tay', 'txy', 'ply', 'iny', 'dey'}}
        args = {}
        for r in self.routines:
            off = r
            for _ in range(12):
                ins = self.instrs.get(off)
                if ins is None:
                    break
                if ins.mode in ('longx',) and ins.operand & 0xFFFF == 0:
                    args[r] = ('x', ins.operand >> 16)
                    break
                if ins.mn in writes['x'] or ins.mn in BRANCHES or ins.mn in (
                        'jsr', 'jsl', 'jmp', 'jml', 'rts', 'rtl'):
                    break
                off += ins.length
        for k, v in self.hints.get('pointer_args', {}).items():
            args[rom_offset(parse_addr(k))] = (v['reg'], parse_addr(v['bank']))
        self.pointer_args = args
        self.pending_ptr_tables = []
        label_offs = set(self.labels)
        for off, ins in self.instrs.items():
            if ins.mn not in ('jsr', 'jsl') or ins.target not in args:
                continue
            reg, bank = args[ins.target]
            cur = off
            for _ in range(8):
                if cur in label_offs:
                    break
                prev = None
                for back in (1, 2, 3, 4):
                    p = self.instrs.get(cur - back)
                    if p is not None and p.length == back:
                        prev = p
                        break
                if prev is None:
                    break
                cur = prev.off
                if prev.mn == 't' + 'a' + reg:
                    p2 = None
                    for back in (3, 4):
                        q = self.instrs.get(prev.off - back)
                        if q is not None and q.length == back:
                            p2 = q
                            break
                    if (p2 is not None and p2.mn == 'lda' and not p2.m8 and p2.db is not None
                            and p2.mode in ('absx', 'absy') and prev.off not in label_offs):
                        start = rom_offset((p2.db << 16) | p2.operand)
                        if start is not None:
                            self.pending_ptr_tables.append((start, bank))
                    break
                if prev.mn == 'ld' + reg and prev.mode == 'immx' and prev.length == 3:
                    tgt = rom_offset((bank << 16) | prev.operand)
                    if tgt is not None and prev.off not in self.imm_ptrs:
                        self.imm_ptrs[prev.off] = ('lo', tgt)
                        self.labels.setdefault(tgt, 'data')
                    break
                if prev.mn in writes[reg] or prev.mn in BRANCHES or prev.mn in (
                        'jsr', 'jsl', 'jmp', 'jml', 'rts', 'rtl', 'rti'):
                    break

    # -- unreferenced routines -------------------------------------------

    def _code_banks(self):
        banks = collections.Counter(o // BANK_SIZE for o in self.instrs)
        return {b for b, n in banks.items() if n >= 200}

    def _cdl_unreached(self):
        """First opcode of every run of CDL-executed code not decoded yet."""
        out = {}
        for off, mx in self.cdl.code_starts.items():
            if off in self.owner or off in self.speculative:
                continue
            out[off] = mx
        # keep only run heads
        heads = {}
        for off in sorted(out):
            if not any((off - k) in out for k in (1, 2, 3, 4)):
                heads[off] = out[off]
        return heads

    def _find_unreferenced(self):
        """Candidates: the first byte after an instruction that ends control
        flow (RTS/RTL/RTI/JMP/JML/BRA/BRL), not yet decoded, in a bank that
        already holds a fair amount of code, which decodes into a plausible
        routine (see _plausible)."""
        out = {}
        banks = self._code_banks()
        for off, ins in list(self.instrs.items()):
            if ins.mn not in ('rts', 'rtl', 'rti', 'jmp', 'jml', 'bra', 'brl'):
                continue
            if ins.mn in ('jmp', 'jml') and ins.mode in ('absi', 'absil'):
                pass
            cand = off + ins.length
            if cand % BANK_SIZE == 0 or cand // BANK_SIZE not in banks:
                continue
            if cand in self.owner or cand in self.table_bytes or self.data_mask[cand]:
                continue
            if cand in self.speculative or cand in self.no_speculate:
                continue
            for m8, x8 in [(ins.m8, ins.x8), (False, False), (True, False), (True, True), (False, True)]:
                if self._plausible(cand, m8, x8):
                    out[cand] = (m8, x8)
                    break
        return out

    def _plausible(self, start, m8, x8, limit=600):
        if self.rom[start] in (0x00, 0xFF, 0x02, 0x42, 0xDB):
            return False
        seen = {}
        todo = [(start, m8, x8)]
        count = 0
        ended = False
        while todo:
            off, m8, x8 = todo.pop()
            while True:
                if off in seen:
                    if seen[off] != (m8, x8):
                        alt = self.decode(off, m8, x8)
                        if alt is None or alt.length != self.decode(off, *seen[off]).length:
                            return False
                    break
                if off in self.owner:
                    if self.owner[off] != off:
                        return False
                    ended = True
                    break   # joins known code
                if off in self.table_bytes or self.data_mask[off]:
                    return False
                ins = self.decode(off, m8, x8)
                if ins is None or ins.mn in SUSPICIOUS:
                    return False
                for i in range(off + 1, off + ins.length):
                    if i in self.owner or i in self.table_bytes or self.data_mask[i]:
                        return False
                seen[off] = (m8, x8)
                count += 1
                if count > limit:
                    return False
                mn, mode, opd = ins.mn, ins.mode, ins.operand
                if mn == 'rep':
                    m8 = m8 and not (opd & 0x20)
                    x8 = x8 and not (opd & 0x10)
                elif mn == 'sep':
                    m8 = m8 or bool(opd & 0x20)
                    x8 = x8 or bool(opd & 0x10)
                nxt = off + ins.length
                if mn in BRANCHES:
                    rel = opd - (0x100 if (mode == 'rel' and opd & 0x80) else 0) \
                        - (0x10000 if (mode == 'rell' and opd & 0x8000) else 0)
                    t = rom_offset((self.cfg.canon(off) & 0xFF0000)
                                   | ((self.cfg.canon(off) + ins.length + rel) & 0xFFFF))
                    if t is None:
                        return False
                    todo.append((t, m8, x8))
                    if mn in ('bra', 'brl'):
                        ended = True
                        break
                elif mn in ('jsr', 'jsl', 'jmp', 'jml') and mode in ('abs', 'long'):
                    if mode == 'abs':
                        t = rom_offset((self.cfg.canon(off) & 0xFF0000) | opd)
                    else:
                        t = rom_offset(opd)
                    if t is None or t // BANK_SIZE not in self._banks_cache:
                        return False
                    if t in self.owner and self.owner[t] != t:
                        return False
                    if mn in ('jmp', 'jml'):
                        todo.append((t, m8, x8)) if t not in self.owner else None
                        ended = True
                        break
                elif mn in ('rts', 'rtl', 'rti') or mode in ('absi', 'absil', 'absix') and mn in ('jmp', 'jml'):
                    ended = True
                    break
                off = nxt
        return ended and count >= 2

    def _seed(self):
        seeds = []
        vec = self.rom[0x7FE0:0x8000]

        def vec_word(cpu):
            i = cpu - 0xFFE0
            return vec[i] | (vec[i + 1] << 8)

        for cpu, name, emu in [(0xFFFC, 'reset', True), (0xFFEA, 'nmi', False),
                               (0xFFEE, 'irq', False), (0xFFE4, 'cop', False),
                               (0xFFE6, 'brk', False), (0xFFE8, 'abort', False),
                               (0xFFFE, 'irq_emu', True), (0xFFF4, 'cop_emu', True),
                               (0xFFFA, 'nmi_emu', True), (0xFFF8, 'abort_emu', True)]:
            target = vec_word(cpu)
            off = rom_offset(target)
            if off is None:
                continue
            seeds.append((off, True, True, 0 if emu else None))
        for e in self.hints.get('entry_points', []):
            off = rom_offset(parse_addr(e['addr']))
            seeds.append((off, e.get('m', 8) == 8, e.get('x', 8) == 8,
                          parse_addr(e['db']) if 'db' in e else None))
        for off, (m8, x8) in sorted(getattr(self, 'speculative', {}).items()):
            seeds.append((off, m8, x8, None))
        if self.cdl:
            for off in sorted(self.cdl.extra_entries):
                m8, x8 = self.cdl.code_starts.get(off, (True, True))
                seeds.append((off, m8, x8, None))
        return seeds

    def _pass(self):
        self.instrs = {}          # off -> Instr
        self.owner = {}           # off -> instr start offset
        self.visited = {}         # off -> {(m8, x8): db}
        self.labels = {}          # off -> kind ('sub','loc','data','jt','ptr')
        self.routines = set()
        self.tables = {}          # off -> (kind, [entry target offsets], entry size)
        self.conflicts = []
        self.stops = []
        self.data_refs = {}       # instr off -> target ROM offset (data label)
        self.table_bytes = set()  # ROM offsets claimed by jump tables
        self.direct_targets = set()  # targets of jsr/jsl/jmp/branches
        self.cdl_corrections = set()  # offsets where the CDL fixed M/X
        self.warnings = []
        self.work = collections.deque()

        for off, m8, x8, db in self._seed():
            self._queue(off, State(m8, x8, db, (), None, off), 'sub')
        while self.work:
            off, st = self.work.popleft()
            self._trace(off, st)
        self._assign_cdl_tables()
        return self._infer_returns()

    def _queue(self, off, st, kind, direct=True):
        if off is None:
            return
        if direct:
            self.direct_targets.add(off)
        prev = self.labels.get(off)
        if kind == 'sub' or prev is None:
            self.labels[off] = kind if prev != 'sub' else 'sub'
        if kind == 'sub':
            self.routines.add(off)
            st = st._replace(stack=(), routine=off)
        ov = self.mx_override.get(off)
        if ov:
            st = st._replace(m8=ov.get('m', 8 if st.m8 else 16) == 8,
                             x8=ov.get('x', 8 if st.x8 else 16) == 8)
            if 'db' in ov:
                st = st._replace(db=parse_addr(ov['db']))
        self.work.append((off, st))

    def _trace(self, off, st):
        self._hist = collections.deque(maxlen=16)
        while True:
            if off is None or off >= ROM_SIZE:
                return
            if off in self.owner and self.owner[off] != off:
                self.conflicts.append((off, 'jump into the middle of instruction at %s'
                                       % fmt_addr(self.cfg.canon(self.owner[off]))))
                return
            if self.cdl and off in self.cdl.code_starts:
                cm8, cx8 = self.cdl.code_starts[off]
                if (cm8, cx8) != (st.m8, st.x8):
                    self.cdl_corrections.add(off)
                    st = st._replace(m8=cm8, x8=cx8)
            vis = self.visited.get(off)
            key = (st.m8, st.x8)
            if vis is not None and key in vis:
                vdb = vis[key]
                if vdb == st.db or vdb is None:
                    return
                # DB disagreement: forget it and re-propagate with DB unknown
                st = st._replace(db=None)
                vis[key] = None
                self.instrs[off].db = None
            elif vis is not None:
                # same instruction reached with other M/X widths: fine as long
                # as its length does not depend on them
                old = self.instrs[off]
                alt = self.decode(off, st.m8, st.x8)
                if alt is None or alt.length != old.length:
                    self.conflicts.append((off, 'reached with M%d X%d, decoded as M%d X%d'
                                           % (8 if st.m8 else 16, 8 if st.x8 else 16,
                                              8 if old.m8 else 16, 8 if old.x8 else 16)))
                    return
                vis[key] = st.db
                if old.db != st.db:
                    old.db = None
            if off in self.table_bytes:
                self.conflicts.append((off, 'code runs into jump table'))
                return
            if self.data_mask[off] and off not in self.force_code:
                self.stops.append((off, 'hint says data'))
                return
            if vis is None:
                ins = self.decode(off, st.m8, st.x8)
                if ins is None:
                    self.stops.append((off, 'instruction crosses bank end'))
                    return
                for i in range(off + 1, off + ins.length):
                    if i in self.owner or self.data_mask[i] or i in self.table_bytes:
                        self.conflicts.append((off, 'instruction overlaps code/data at %s'
                                               % fmt_addr(self.cfg.canon(i))))
                        return
                if ins.mn in SUSPICIOUS and off not in self.force_code:
                    self.stops.append((off, 'suspicious opcode %s' % ins.mn))
                    return
                ins.db = st.db
                self.instrs[off] = ins
                for i in range(off, off + ins.length):
                    self.owner[i] = off
                self.visited[off] = {key: st.db}
            else:
                ins = self.instrs[off]
            self._hist.append(ins)
            st = self._step(ins, st)
            if st is None:
                return
            off += ins.length

    # -- per-instruction semantics ---------------------------------------

    def _code_target(self, ins, addr16=None, addr24=None):
        """ROM offset of a jump/branch target, or None if outside ROM."""
        if addr24 is not None:
            return rom_offset(addr24)
        bank = self.pc_bank(ins.off)
        return rom_offset((bank << 16) | addr16)

    def _step(self, ins, st):
        """Apply `ins` to `st`, queue code targets, return the fall-through
        state or None if control does not fall through."""
        mn, mode, opd = ins.mn, ins.mode, ins.operand
        m8, x8, db, stack, a_imm = st.m8, st.x8, st.db, list(st.stack), st.a_imm
        nxt = ins.off + ins.length
        pc_bank = self.pc_bank(ins.off)

        def push(*vals):
            stack.extend(vals)

        def pop(n):
            out = []
            for _ in range(n):
                out.append(stack.pop() if stack else None)
            return out

        if mn == 'rep':
            if opd & 0x20:
                m8 = False
            if opd & 0x10:
                x8 = False
        elif mn == 'sep':
            if opd & 0x20:
                m8 = True
            if opd & 0x10:
                x8 = True
        elif mn == 'php':
            push(('P', m8, x8))
        elif mn == 'plp':
            v = pop(1)[0]
            if isinstance(v, tuple):
                m8, x8 = v[1], v[2]
            else:
                self.warnings.append((ins.off, 'PLP without matching PHP; M/X kept'))
        elif mn == 'phk':
            push(pc_bank)
        elif mn == 'phb':
            push(db)
        elif mn == 'pea':
            push(opd >> 8, opd & 0xFF)
        elif mn == 'pha':
            if m8:
                push(a_imm & 0xFF if a_imm is not None else None)
            else:
                push(a_imm >> 8 if a_imm is not None else None,
                     a_imm & 0xFF if a_imm is not None else None)
        elif mn in ('phx', 'phy'):
            push(*([None] * (1 if x8 else 2)))
        elif mn in ('phd',):
            push(None, None)
        elif mn == 'pei':
            push(None, None)
        elif mn == 'per':
            push(None, None)
        elif mn == 'plb':
            v = pop(1)[0]
            db = v if isinstance(v, int) else None
        elif mn == 'pla':
            pop(1 if m8 else 2)
        elif mn in ('plx', 'ply'):
            pop(1 if x8 else 2)
        elif mn == 'pld':
            pop(2)
        elif mn == 'xce':
            pass  # assume native mode throughout (the reset code switches once)
        elif mn in ('mvn', 'mvp'):
            db = opd & 0xFF
        elif mn == 'tcs' or mn == 'txs':
            stack = []

        # accumulator tracker
        if mn == 'lda' and mode == 'immm':
            a_imm = opd
        elif mn in A_WRITERS or (mn in A_RMW_ACC and mode == 'acc'):
            a_imm = None

        new = State(m8, x8, db, tuple(stack), a_imm, st.routine)

        # control flow
        if mn in BRANCHES:
            rel = opd - (0x100 if (mode == 'rel' and opd & 0x80) else 0) \
                - (0x10000 if (mode == 'rell' and opd & 0x8000) else 0)
            t16 = ((self.cfg.canon(ins.off) + ins.length + rel) & 0xFFFF)
            tgt = self._code_target(ins, addr16=t16)
            ins.target = tgt
            self._queue(tgt, new, 'loc')
            if mn in ('bra', 'brl'):
                return None
            return new
        if mn == 'per':
            rel = opd - (0x10000 if opd & 0x8000 else 0)
            t16 = (self.cfg.canon(ins.off) + ins.length + rel) & 0xFFFF
            ins.target = self._code_target(ins, addr16=t16)
            if ins.target is not None:
                self.labels.setdefault(ins.target, 'data')
            return new
        if mn == 'jmp' and mode == 'abs':
            tgt = self._code_target(ins, addr16=opd)
            ins.target = tgt
            self._queue(tgt, new, 'loc')
            return None
        if mn == 'jml' and mode == 'long':
            tgt = self._code_target(ins, addr24=opd)
            ins.target = tgt
            self._queue(tgt, new, 'loc')
            return None
        if mn in ('jsr', 'jsl') and mode in ('abs', 'long'):
            if mode == 'abs':
                tgt = self._code_target(ins, addr16=opd)
            else:
                tgt = self._code_target(ins, addr24=opd)
            ins.target = tgt
            if tgt is None:
                self.warnings.append((ins.off, 'call outside ROM'))
                return State(m8, x8, db, tuple(stack), None, st.routine)
            self._queue(tgt, new, 'sub')
            if tgt in self.inline_tables:
                self._inline_table(ins, tgt, new)
                return None
            if tgt in self.noreturn:
                return None
            ret = self.call_returns.get(tgt) or self.auto_call_returns.get(tgt)
            m8r, x8r = m8, x8
            if ret:
                if 'm' in ret:
                    m8r = ret['m'] == 8
                if 'x' in ret:
                    x8r = ret['x'] == 8
            return State(m8r, x8r, db, tuple(stack), None, st.routine)
        if mode == 'absix' and mn in ('jmp', 'jsr'):
            self._jump_table(ins, new)
            if mn == 'jsr':
                return new._replace(a_imm=None)
            return None
        if mn in ('jmp', 'jml') and mode in ('absi', 'absil'):
            # indirect through a RAM pointer.  Recognise the idiom
            #   lda table,x / sta ptr / jmp (ptr)
            # and otherwise leave it to a CDL.
            if not self._ram_pointer_table(ins, new):
                self.warnings.append((ins.off, 'indirect jump through RAM ($%04X)' % opd))
            return None
        if mn in ('rts', 'rtl', 'rti', 'stp'):
            return None

        # data references with a known bank
        tgt = None
        if mode in ('long', 'longx'):
            tgt = rom_offset(opd)
        elif mode in ('abs', 'absx', 'absy') and opd >= 0x8000:
            edb = db
            if edb is None and self.cdl:
                edb = self.cdl.db.get(ins.off)
            if edb is not None:
                tgt = rom_offset((edb << 16) | opd)
        if tgt is not None:
            self.data_refs[ins.off] = tgt
            self.labels.setdefault(tgt, 'data')
        return new

    # -- tables -----------------------------------------------------------

    def _looks_like_code(self, off, st):
        """Cheap plausibility check for a candidate code pointer."""
        if off is None or self.data_mask[off]:
            return False
        if off in self.owner:
            return self.owner[off] == off
        ins = self.decode(off, st.m8, st.x8)
        if ins is None or ins.mn in SUSPICIOUS:
            return False
        return True

    def _scan_table(self, start, st, entry_size, bank, count=None, min_count=0):
        """Read a table of code pointers starting at ROM offset `start`.
        Returns the list of target offsets."""
        targets = []
        off = start
        limit = (start // BANK_SIZE + 1) * BANK_SIZE
        while off + entry_size <= limit:
            if count is not None and len(targets) >= count:
                break
            checks = count is None and len(targets) >= min_count
            if checks:
                if off != start and (off in self.labels or off in self.owner
                                     or off in self.prev_code_entries
                                     or off + 1 in self.prev_code_entries):
                    break
                if any(t is not None and start <= t < off + entry_size for t in targets):
                    break
                if any(self.data_mask[i] for i in range(off, off + entry_size)):
                    break
                if any(i in self.owner or i in self.table_bytes
                       for i in range(off, off + entry_size)):
                    break
            v = int.from_bytes(self.rom[off:off + entry_size], 'little')
            if v == 0:
                # null entry (unused slot)
                targets.append(None)
                off += entry_size
                continue
            if entry_size == 2:
                t = rom_offset((bank << 16) | v)
            else:
                t = rom_offset(v)
            if checks and not self._looks_like_code(t, st):
                break
            targets.append(t)
            off += entry_size
        if count is None:
            while targets and targets[-1] is None:
                targets.pop()
        return targets

    def _jump_table(self, ins, st):
        bank = self.pc_bank(ins.off)
        start = rom_offset((bank << 16) | ins.operand)
        if start is None:
            self.warnings.append((ins.off, 'jump table outside ROM'))
            return
        hint = self.table_hints.get(start)
        if start in self.no_table_at and not hint:
            return
        count = hint.get('count') if hint else None
        if start in self.tables:
            targets = self.tables[start][1]
        else:
            targets = self._scan_table(start, st, 2, bank, count,
                                       hint.get('min_count', 0) if hint else 0)
        self._register_table(start, 'word', targets, 2, st)
        if not targets:
            self.warnings.append((ins.off, 'empty jump table at %s' % fmt_addr(self.cfg.canon(start))))

    def _ram_pointer_table(self, ins, st):
        """Recognise a jump through a RAM pointer loaded from a ROM table:
            lda table,x|y (M16) ... sta ptr ... jmp (ptr)          -> word table
            lda table,y ... sta ptr ... lda table+2,y ... sta ptr+2
                ... jml [ptr]                                      -> long table
        """
        ptr = ins.operand
        long_jump = ins.mn == 'jml'
        hist = list(self._hist)[:-1][-14:]
        stores = {}   # pointer byte offset (0 or 2) -> source lda

        def is_store(prev, addr):
            return prev.mn == 'sta' and ((prev.mode == 'dp' and addr < 0x100 and prev.operand == addr)
                                         or (prev.mode == 'abs' and prev.operand == addr))
        pending = None
        for prev in reversed(hist):
            if prev.mn in BRANCHES or prev.mn in ('jsr', 'jsl', 'rts', 'rtl'):
                break
            if pending is None:
                for k in (0, 2):
                    if k not in stores and is_store(prev, ptr + k):
                        pending = k
                continue
            if prev.mn == 'lda':
                stores[pending] = prev
                pending = None
                if 0 in stores and (not long_jump or 2 in stores):
                    break
                continue
            if prev.mn not in ('plx', 'ply', 'phx', 'phy', 'clc', 'sec', 'tax', 'tay'):
                pending = None
        src = stores.get(0)
        if src is None or src.m8 or src.mode not in ('absx', 'absy', 'longx'):
            return False
        if long_jump:
            hi = stores.get(2)
            if hi is None or hi.mode != src.mode or hi.operand != src.operand + 2:
                return False
        if src.mode == 'longx':
            start = rom_offset(src.operand)
        elif src.db is not None:
            start = rom_offset((src.db << 16) | src.operand)
        else:
            return False
        if start is None:
            return False
        size = 3 if long_jump else 2
        bank = self.pc_bank(ins.off)
        hint = self.table_hints.get(start)
        if start in self.no_table_at and not hint:
            return False
        count = hint.get('count') if hint else None
        if start in self.tables:
            targets = self.tables[start][1]
        else:
            targets = self._scan_table(start, st, size, bank, count,
                                       hint.get('min_count', 0) if hint else 0)
        if not any(t is not None for t in targets):
            return False
        self._register_table(start, 'word' if size == 2 else 'long', targets, size, st)
        return True

    def _inline_table(self, ins, dispatcher, st):
        """`jsr/jsl dispatcher` followed by an inline table of pointers."""
        h = self.inline_tables[dispatcher]
        size = 3 if h.get('entry') == 'long' else 2
        start = ins.off + ins.length
        bank = self.pc_bank(ins.off)
        tst = State(h.get('m', 8 if st.m8 else 16) == 8, h.get('x', 8 if st.x8 else 16) == 8,
                    st.db, (), None, None)
        targets = self._scan_table(start, tst, size, bank, h.get('count'))
        self._register_table(start, 'word' if size == 2 else 'long', targets, size, tst)

    def _register_table(self, start, kind, targets, size, st):
        self.tables[start] = (kind, targets, size)
        for i in range(start, start + size * len(targets)):
            self.table_bytes.add(i)
        self.labels[start] = 'jt' if self.labels.get(start) in (None, 'data') else self.labels[start]
        for t in targets:
            if t is not None:
                self._queue(t, st._replace(stack=(), a_imm=None), 'sub', direct=False)

    def _assign_cdl_tables(self):
        if not self.cdl:
            return
        # indirect jump targets observed at runtime become routine entries
        # (already seeded); nothing else to do here.

    # -- return-state inference ------------------------------------------

    def _infer_returns(self):
        """Find routines whose returns always leave M/X different from the
        state they were entered with.  Returns True if anything changed."""
        changed = False
        for r in sorted(self.routines):
            if r in self.call_returns or r not in self.visited:
                continue
            em8, ex8 = self.instrs[r].m8, self.instrs[r].x8
            exits = set()
            seen = set()
            todo = [r]
            while todo:
                o = todo.pop()
                if o in seen or o not in self.instrs:
                    continue
                seen.add(o)
                ins = self.instrs[o]
                if ins.mn in ('rts', 'rtl'):
                    exits.add((ins.m8, ins.x8))
                    continue
                if ins.mn in ('rti', 'stp'):
                    continue
                if ins.mn in BRANCHES or (ins.mn in ('jmp', 'jml') and ins.mode in ('abs', 'long')):
                    if ins.target is not None:
                        todo.append(ins.target)
                    if ins.mn in ('bra', 'brl', 'jmp', 'jml'):
                        continue
                if ins.mode in ('absix', 'absi', 'absil') and ins.mn in ('jmp', 'jml'):
                    continue
                todo.append(o + ins.length)
            # an RTS's M/X is the state *before* it executes = state at exit
            if len(exits) == 1:
                m8, x8 = exits.pop()
                if (m8, x8) != (em8, ex8):
                    want = {}
                    if m8 != em8:
                        want['m'] = 8 if m8 else 16
                    if x8 != ex8:
                        want['x'] = 8 if x8 else 16
                    if self.auto_call_returns.get(r) != want:
                        self.auto_call_returns[r] = want
                        changed = True
        return changed


# ---------------------------------------------------------------------------
# emission
# ---------------------------------------------------------------------------

class Emitter:
    def __init__(self, d, cfg, hints):
        self.d = d
        self.cfg = cfg
        self.rom = d.rom
        self.names = {}
        for k, v in hints.get('labels', {}).items():
            self.names[rom_offset(parse_addr(k))] = v
        self.comments = {}
        for k, v in hints.get('comments', {}).items():
            self.comments[rom_offset(parse_addr(k))] = v
        self.stats = collections.Counter()
        self.rom_numbers = []     # (instr offset, reason) of ROM-range numbers
        self._build_labels()

    def _build_labels(self):
        d = self.d
        labels = dict(d.labels)
        for off, ins in d.instrs.items():
            if ins.target is not None:
                labels.setdefault(ins.target, 'loc')
        for start, (kind, targets, size) in d.tables.items():
            for t in targets:
                if t is not None:
                    labels.setdefault(t, 'sub')
        # header vectors
        for off in self._vector_targets():
            labels.setdefault(off, 'sub')
        for off in self.names:
            labels.setdefault(off, 'data')
        self.label_kind = labels
        self.label_name = {}
        for off, kind in labels.items():
            if off in self.names:
                self.label_name[off] = self.names[off]
                continue
            prefix = {'sub': 'sub', 'loc': 'loc', 'data': 'data', 'jt': 'tbl', 'ptrs': 'ptrs'}[kind]
            self.label_name[off] = '%s_%06X' % (prefix, self.cfg.canon(off))
        # labels that fall inside an instruction become `name = host + n`
        self.inner = collections.defaultdict(list)
        for off in list(self.label_name):
            host = d.owner.get(off)
            if host is not None and host != off:
                self.inner[host].append(off)
                if host not in self.label_name:
                    self.label_kind[host] = 'loc'
                    self.label_name[host] = 'loc_%06X' % self.cfg.canon(host)

    def _vector_targets(self):
        out = []
        for i in range(0x7FE4, 0x8000, 2):
            v = self.rom[i] | (self.rom[i + 1] << 8)
            o = rom_offset(v)
            if o is not None and v != 0xFFFF:
                out.append(o)
        return out

    def ref(self, off):
        """Label expression for ROM offset `off`."""
        return self.label_name[off]

    def same(self, off, value, bits):
        """True if the label at `off` evaluates to `value` (low `bits` bits),
        i.e. replacing the number by the label keeps the ROM identical."""
        return (self.cfg.canon(off) & ((1 << bits) - 1)) == value

    def has_label(self, off):
        return off is not None and off in self.label_name

    # -- operand formatting ---------------------------------------------

    def fmt_operand(self, ins):
        mode, v = ins.mode, ins.operand
        d = self.d
        st = self.stats

        def num(val, width):
            return '$%0*X' % (width * 2, val)

        def absval(val, data_tgt=None, prefix='a:'):
            if data_tgt is not None and self.has_label(data_tgt) and self.same(data_tgt, val, 16):
                st['operand_label'] += 1
                return prefix + self.ref(data_tgt)
            if val >= 0x8000:
                st['operand_rom_number'] += 1
                self.rom_numbers.append((ins.off, 'DB unknown' if ins.db is None else
                                         'DB=$%02X' % ins.db))
            else:
                reg = snes_regs.NAMES.get(val)
                if reg and ins.db not in (0x7E, 0x7F):
                    st['operand_register'] += 1
                    return prefix + reg
                st['operand_ram_number'] += 1
            return prefix + num(val, 2)

        if mode in ('imp',):
            return ''
        if mode == 'acc':
            return 'a'
        if mode in ('immm', 'immx') and ins.off in d.imm_ptrs:
            kind, tgt = d.imm_ptrs[ins.off]
            st['immediate_label'] += 1
            if kind == 'lo':
                return '#.loword(%s)' % self.ref(tgt)
            return '#^%s' % self.ref(tgt)
        if mode in ('imm8', 'immm', 'immx'):
            st['immediate'] += 1
            return '#' + num(v, ins.length - 1)
        if mode == 'sig':
            return num(v, 1)
        if mode in ('rel', 'rell'):
            if self.has_label(ins.target):
                st['operand_label'] += 1
                return self.ref(ins.target)
            raise RuntimeError('branch without target label at %X' % ins.off)
        if ins.mn == 'per':
            if self.has_label(ins.target):
                st['operand_label'] += 1
                return self.ref(ins.target)
            raise RuntimeError('per without target label')
        if ins.mn == 'pea':
            st['immediate'] += 1
            return num(v, 2)
        if mode == 'blk':
            # machine order: dst, src; ca65 syntax: mvn #src, #dst
            return '#$%02X, #$%02X' % (v >> 8, v & 0xFF)
        if mode == 'dp':
            return num(v, 1)
        if mode == 'dpx':
            return num(v, 1) + ',x'
        if mode == 'dpy':
            return num(v, 1) + ',y'
        if mode == 'dpi':
            return '(' + num(v, 1) + ')'
        if mode == 'dpix':
            return '(' + num(v, 1) + ',x)'
        if mode == 'dpiy':
            return '(' + num(v, 1) + '),y'
        if mode == 'dpil':
            return '[' + num(v, 1) + ']'
        if mode == 'dpily':
            return '[' + num(v, 1) + '],y'
        if mode == 'sr':
            return num(v, 1) + ',s'
        if mode == 'sriy':
            return '(' + num(v, 1) + ',s),y'
        if mode == 'absi':
            st['operand_ram_number'] += 1
            return '(' + num(v, 2) + ')'
        if mode == 'absil':
            st['operand_ram_number'] += 1
            return '[' + num(v, 2) + ']'
        if mode == 'absix':
            tbl = rom_offset((self.cfg.canon(ins.off) & 0xFF0000) | v)
            if self.has_label(tbl):
                st['operand_label'] += 1
                return '(.loword(' + self.ref(tbl) + '),x)'
            st['operand_rom_number'] += 1
            return '(' + num(v, 2) + ',x)'
        if mode == 'abs':
            if ins.mn in ('jsr', 'jmp'):
                if self.has_label(ins.target) and self.same(ins.target, v, 16):
                    st['operand_label'] += 1
                    return 'a:' + self.ref(ins.target)
                st['operand_rom_number'] += 1
                return 'a:' + num(v, 2)
            return absval(v, d.data_refs.get(ins.off))
        if mode in ('absx', 'absy'):
            return absval(v, d.data_refs.get(ins.off)) + (',x' if mode == 'absx' else ',y')
        if mode in ('long', 'longx'):
            tgt = ins.target if ins.mn in ('jsl', 'jml') else d.data_refs.get(ins.off)
            if self.has_label(tgt) and self.same(tgt, v, 24):
                st['operand_label'] += 1
                s = 'f:' + self.ref(tgt)
            else:
                if rom_offset(v) is not None:
                    st['operand_rom_number'] += 1
                else:
                    st['operand_ram_number'] += 1
                s = 'f:' + num(v, 3)
            return s + (',x' if mode == 'longx' else '')
        raise RuntimeError('unhandled mode ' + mode)

    # -- bank emission -----------------------------------------------------

    def emit_bank(self, bank):
        d = self.d
        out = []
        w = out.append
        start = bank * BANK_SIZE
        end = start + BANK_SIZE
        cpu_bank = self.cfg.canon(start) >> 16
        w('; Bank $%02X (ROM $%05X-$%05X), CPU $%02X:8000-$%02X:FFFF' %
          (cpu_bank, start, end - 1, cpu_bank, cpu_bank))
        w('; Generated by tools/disasm.py, then maintained by hand.')
        w('')
        w('.include "common.inc"')
        w('')
        w('.segment "BANK%02X"' % bank)
        w('')
        asm_m8 = asm_x8 = None
        table_entry = {}
        for tstart, (kind, targets, size) in d.tables.items():
            for i, t in enumerate(targets):
                table_entry[tstart + i * size] = (t, size)
        for tstart, (targets, size) in d.data_tables.items():
            for i, t in enumerate(targets):
                table_entry[tstart + i * size] = (t, size)
        hdr = 0x7FB0 if bank == 0 else None
        off = start
        pending_data = []
        data_start = None

        def flush():
            nonlocal pending_data, data_start
            if pending_data:
                self._emit_data(w, data_start, pending_data)
            pending_data = []
            data_start = None

        while off < end:
            if hdr is not None and off == hdr:
                flush()
                self._emit_header(w)
                off = end
                break
            if off in self.label_name or off in self.comments:
                flush()
                if off in self.comments:
                    for line in self.comments[off].splitlines():
                        w('; ' + line)
                kind = self.label_kind.get(off)
                if kind == 'sub' and off in self.label_name and off in d.instrs:
                    w('')
                src = d.spec_source.get(off)
                if src == 'heuristic':
                    w('; (no caller found; decoded because it follows the end of a routine)')
                elif src == 'cdl':
                    w('; (no caller found statically; executed according to the CDL)')
                w('%s:' % self.label_name[off])
            if off in table_entry and off not in d.instrs:
                t, size = table_entry[off]
                if (all(i not in d.owner and i not in self.label_name
                        for i in range(off + 1, off + size))
                        and (t is None or (self.has_label(t) and self.same(
                            t, int.from_bytes(self.rom[off:off + size], 'little'), size * 8)))):
                    flush()
                    if t is None:
                        w('\t.addr\t$0000' if size == 2 else '\t.faraddr\t$000000')
                    else:
                        w(('\t.addr\t' if size == 2 else '\t.faraddr\t') + self.ref(t))
                    self.stats['table_entries'] += 1
                    self.stats['data_bytes'] += size
                    self.stats['table_bytes'] += size
                    off += size
                    continue
            ins = d.instrs.get(off)
            if ins is not None:
                flush()
                if asm_m8 != ins.m8:
                    w('\t.a8' if ins.m8 else '\t.a16')
                    asm_m8 = ins.m8
                if asm_x8 != ins.x8:
                    w('\t.i8' if ins.x8 else '\t.i16')
                    asm_x8 = ins.x8
                if ins.mn in SUSPICIOUS:
                    w('\t.byte\t$%02X, $%02X\t; %s' % (ins.op, ins.operand, ins.mn))
                else:
                    opnd = self.fmt_operand(ins)
                    w('\t%s%s' % (ins.mn, ('\t' + opnd) if opnd else ''))
                for inner in sorted(self.inner.get(off, [])):
                    w('%s = %s + %d' % (self.label_name[inner], self._host_name(off), inner - off))
                self.stats['code_bytes'] += ins.length
                self.stats['instructions'] += 1
                off += ins.length
                continue
            if data_start is None:
                data_start = off
            pending_data.append(self.rom[off])
            self.stats['data_bytes'] += 1
            off += 1
        flush()
        w('')
        return '\n'.join(out)

    def _host_name(self, off):
        if off in self.label_name:
            return self.label_name[off]
        # instruction without a label: give it a local anchor
        name = 'anchor_%06X' % self.cfg.canon(off)
        self.label_name[off] = name
        self.label_kind[off] = 'loc'
        raise RuntimeError('host without label (should have been pre-created): ' + name)

    def _emit_data(self, w, start, data):
        for i in range(0, len(data), 16):
            chunk = data[i:i + 16]
            w('\t.byte\t' + ', '.join('$%02X' % b for b in chunk))

    def _emit_header(self, w):
        r = self.rom
        b = r[0x7FB0:0x8000]
        w('')
        w('; ---------------------------------------------------------------------------')
        w('; Internal ROM header ($00:FFB0-$00:FFFF)')
        w('; The title is 22 characters long and overflows into $FFD5 (normally the')
        w('; map mode byte); it is reproduced exactly as in the original ROM.')
        w('; ---------------------------------------------------------------------------')
        w('rom_header:')
        w('\t.byte\t' + ', '.join('$%02X' % x for x in b[0:0x10]) + '\t; maker code, game code, reserved, expansion')
        w('\t.byte\t"%s"\t; title (22 chars, $FFC0-$FFD5)' % b[0x10:0x26].decode('ascii'))
        w('\t.byte\t$%02X\t; $FFD6 cartridge type' % b[0x26])
        w('\t.byte\t$%02X\t; $FFD7 ROM size' % b[0x27])
        w('\t.byte\t$%02X\t; $FFD8 SRAM size' % b[0x28])
        w('\t.byte\t$%02X\t; $FFD9 region' % b[0x29])
        w('\t.byte\t$%02X\t; $FFDA developer ID' % b[0x2A])
        w('\t.byte\t$%02X\t; $FFDB version' % b[0x2B])
        w('\t.word\t$%04X\t; $FFDC checksum complement' % (b[0x2C] | b[0x2D] << 8))
        w('\t.word\t$%04X\t; $FFDE checksum' % (b[0x2E] | b[0x2F] << 8))
        names = ['native: reserved', 'native: reserved', 'native COP', 'native BRK',
                 'native ABORT', 'native NMI', 'native (unused)', 'native IRQ',
                 'emulation: reserved', 'emulation: reserved', 'emulation COP',
                 'emulation (unused)', 'emulation ABORT', 'emulation NMI',
                 'emulation RESET', 'emulation IRQ/BRK']
        w('vectors:')
        for i in range(16):
            v = b[0x30 + 2 * i] | (b[0x31 + 2 * i] << 8)
            o = rom_offset(v)
            if o is not None and o in self.label_name and v != 0xFFFF:
                w('\t.addr\t%s\t; %s' % (self.label_name[o], names[i]))
            else:
                w('\t.word\t$%04X\t; %s' % (v, names[i]))
        self.stats['data_bytes'] += 0x50


# ---------------------------------------------------------------------------
# output files
# ---------------------------------------------------------------------------

def write_cfg(path, cfg):
    lines = ['# ld65 memory map for Contra III (USA): 1 MiB LoROM, 32 banks of $8000.',
             '# Generated by tools/disasm.py.', '', 'MEMORY {']
    for b in range(NUM_BANKS):
        cpu = cfg.canon(b * BANK_SIZE)
        lines.append('    ROM%02X: start = $%06X, size = $8000, fill = yes, fillval = $FF;' % (b, cpu))
    lines.append('}')
    lines.append('')
    lines.append('SEGMENTS {')
    for b in range(NUM_BANKS):
        lines.append('    BANK%02X: load = ROM%02X, type = ro;' % (b, b))
    lines.append('}')
    with open(path, 'w') as f:
        f.write('\n'.join(lines) + '\n')


def write_main(path):
    lines = ['; Contra III: The Alien Wars (USA) -- top-level file.', ';',
             '; Every bank lives in its own file; the linker config (contra3.cfg)',
             '; places segment BANKxx at $xx:8000.', '']
    for b in range(NUM_BANKS):
        lines.append('.include "bank_%02X.asm"' % b)
    with open(path, 'w') as f:
        f.write('\n'.join(lines) + '\n')


def write_common(path):
    with open(path, 'w') as f:
        f.write('; Included by every bank file.\n\n'
                '.ifndef COMMON_INC\nCOMMON_INC = 1\n\n'
                '.p816\n.smart -\n\n'
                '.include "snes_registers.inc"\n\n.endif\n')


def make_report(d, em, cfg, path):
    st = em.stats
    total = ROM_SIZE
    lines = ['# Disassembly quality report', '',
             'Generated by `tools/disasm.py` (static recursive descent%s).' %
             (' + CDL' if d.cdl else ''), '',
             '| metric | value |', '|---|---|',
             '| ROM size | %d bytes |' % total,
             '| code bytes (decoded instructions) | %d (%.1f%%) |' % (st['code_bytes'], 100.0 * st['code_bytes'] / total),
             '| data bytes (.byte / tables / header) | %d (%.1f%%) |' % (st['data_bytes'], 100.0 * st['data_bytes'] / total),
             '| of which jump-table bytes (.addr/.faraddr) | %d |' % st['table_bytes'],
             '| instructions | %d |' % st['instructions'],
             '| routines (call / table / vector targets) | %d |' % len(d.routines),
             '| jump tables | %d |' % len(d.tables),
             '| data pointer tables | %d (%d entries) |' % (len(d.data_tables), sum(len(v[0]) for v in d.data_tables.values())),
             '| table entries emitted as .addr/.faraddr | %d |' % st['table_entries'],
             '| labels | %d |' % len(em.label_name),
             '| operands as labels | %d |' % st['operand_label'],
             '| operands as hardware register names | %d |' % st['operand_register'],
             '| operands: hardcoded ROM addresses ($8000+) | %d |' % st['operand_rom_number'],
             '| operands: hardcoded RAM/other addresses | %d |' % st['operand_ram_number'],
             '| immediates turned into pointer expressions (#.loword/#^) | %d |' % st['immediate_label'],
             '| other immediates (some may still be pointers) | %d |' % st['immediate'],
             '| M/X conflicts and overlaps | %d |' % len(set(d.conflicts)),
             '| decoding stops (suspicious opcode etc.) | %d |' % len(set(d.stops)),
             '| auto-inferred call return states | %d |' % len(d.auto_call_returns),
             '| routines found heuristically (no known caller) | %d |' % sum(
                 1 for o, k in d.spec_source.items() if k == 'heuristic' and o in d.instrs),
             '']
    per_bank = collections.Counter()
    for ins in d.instrs.values():
        per_bank[ins.off // BANK_SIZE] += ins.length
    lines += ['## Code bytes per bank', '', '| bank | code bytes | % |', '|---|---|---|']
    for b in range(NUM_BANKS):
        lines.append('| $%02X | %d | %.1f%% |' % (b, per_bank[b], 100.0 * per_bank[b] / BANK_SIZE))
    lines.append('')

    def section(title, items):
        items = sorted(set(items))
        lines.append('## %s (%d)' % (title, len(items)))
        lines.append('')
        for off, msg in sorted(set(items))[:400]:
            lines.append('- `%s` %s' % (fmt_addr(cfg.canon(off)), msg))
        if len(items) > 400:
            lines.append('- ... %d more' % (len(items) - 400))
        lines.append('')

    section('M/X conflicts and overlaps', d.conflicts)
    section('Decoding stops', d.stops)
    section('Warnings', d.warnings)
    section('Absolute operands >= $8000 left as numbers (bank unknown; may be ROM or, with DB=$7E/$7F, WRAM)',
            em.rom_numbers)
    heur = sorted(o for o, k in d.spec_source.items() if k == 'heuristic' and o in d.instrs)
    lines.append('## Routines without a known caller, decoded heuristically (%d)' % len(heur))
    lines.append('')
    lines.append('Code right after the end of a routine that decodes as a plausible routine.')
    lines.append('These are either dead code or reached through pointers not identified yet;')
    lines.append('a CDL will confirm or refute them (add refuted ones to "not_code" in the hints).')
    lines.append('')
    for o in heur:
        lines.append('- `%s`' % fmt_addr(cfg.canon(o)))
    lines.append('')
    if d.cdl:
        lines.append('## M/X corrected by the CDL (%d)' % len(d.cdl_corrections))
        lines.append('')
        for o in sorted(d.cdl_corrections)[:400]:
            lines.append('- `%s`' % fmt_addr(cfg.canon(o)))
        lines.append('')
    lines.append('## Auto-inferred call return states (%d)' % len(d.auto_call_returns))
    lines.append('')
    for r, v in sorted(d.auto_call_returns.items()):
        lines.append('- `%s` returns with %s' % (fmt_addr(cfg.canon(r)),
                                                ', '.join('%s%d' % (k.upper(), x) for k, x in sorted(v.items()))))
    lines.append('')
    with open(path, 'w') as f:
        f.write('\n'.join(lines))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split('\n')[0])
    ap.add_argument('rom')
    here = os.path.dirname(os.path.abspath(__file__))
    ap.add_argument('--hints', default=os.path.join(here, 'disasm_hints.json'))
    ap.add_argument('--cdl', help='code/data log produced by the emulator (see tools/cdl.py)')
    ap.add_argument('--out', default=os.path.join(here, '..', 'src'))
    ap.add_argument('--report', default=os.path.join(here, '..', 'docs', 'disasm_report.md'))
    args = ap.parse_args()

    rom = open(args.rom, 'rb').read()
    if len(rom) != ROM_SIZE:
        sys.exit('expected a %d-byte ROM' % ROM_SIZE)
    with open(args.hints) as f:
        hints = json.load(f)
    cfg = Config(fastrom=hints.get('fastrom', False))
    cdl = None
    if args.cdl:
        import cdl as cdlmod
        cdl = cdlmod.load(args.cdl, rom)

    d = Disassembler(rom, hints, cfg, cdl)
    d.run()
    d.find_immediate_pointers()
    d.find_pointer_args()
    d.find_data_pointer_tables()
    em = Emitter(d, cfg, hints)
    os.makedirs(args.out, exist_ok=True)
    for b in range(NUM_BANKS):
        text = em.emit_bank(b)
        with open(os.path.join(args.out, 'bank_%02X.asm' % b), 'w') as f:
            f.write(text)
    write_cfg(os.path.join(args.out, 'contra3.cfg'), cfg)
    write_main(os.path.join(args.out, 'main.asm'))
    write_common(os.path.join(args.out, 'common.inc'))
    snes_regs.write_inc(os.path.join(args.out, 'snes_registers.inc'))
    os.makedirs(os.path.dirname(args.report), exist_ok=True)
    make_report(d, em, cfg, args.report)
    st = em.stats
    print('code %d bytes, data %d bytes, %d instructions, %d labels, %d conflicts, %d stops'
          % (st['code_bytes'], st['data_bytes'], st['instructions'], len(em.label_name),
             len(d.conflicts), len(d.stops)))


if __name__ == '__main__':
    main()
