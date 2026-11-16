"""The CDL tracer in the patched snes9x core records what it should.

Skipped on a core without the retro_cdl_* exports (e.g. bsnes).
"""
import os
import tempfile

import pytest

from tools.c3emu import cdl as C
from tools.c3emu import game, retro

RESET, NMI, IRQ = 0x8000, 0x819B, 0x8BE2


@pytest.fixture(scope="module")
def log(rom, core):
    c = retro.Console(rom, core=core)
    if not c.has_cdl():
        c.close()
        pytest.skip("core has no CDL tracer")
    c.cdl_enable()
    c.cdl_clear()
    c.run(game.FRAME_DEMO1)
    snap = c.cdl_snapshot()
    c.close()
    return snap


def test_vectors(log):
    """The reset and NMI handlers ran; the NMI one is marked as an interrupt
    entry; the vector table was read as data."""
    reset = C.lorom_offset(RESET)
    nmi = C.lorom_offset(NMI)
    assert log.a[reset] & C.OPCODE
    assert log.b[reset] & C.B_EMU          # the 65816 resets in emulation mode
    assert log.a[nmi] & C.OPCODE
    assert log.b[nmi] & C.B_IRQ
    assert log.a[C.lorom_offset(0xFFEA)] & C.DATA   # native NMI vector


def test_operands_follow_opcodes(log):
    """Every executed instruction's operand bytes are marked, and no byte is
    both an operand and never preceded by an opcode within 3 bytes."""
    for i, v in enumerate(log.a):
        if v & C.OPERAND and not v & C.OPCODE:
            assert any(log.a[j] & C.OPCODE for j in range(max(0, i - 3), i)), hex(i)


def test_flags_recorded(log):
    ops = [v for v in log.a if v & C.OPCODE]
    assert ops
    assert all(v & (C.M0 | C.M1) and v & (C.X0 | C.X1) for v in ops)


def test_data_seen(log):
    """The intro reads lots of ROM as data (graphics are mostly decompressed
    by the CPU into WRAM, so few bytes are DMA'd straight from ROM), and
    every data byte read by an instruction knows its first reader (the
    interrupt vectors are read by the CPU itself, outside any instruction)."""
    data = [i for i, v in enumerate(log.a) if v & C.DATA]
    assert len(data) > 10000
    assert sum(1 for v in log.a if v & C.DMA) > 0
    assert all(log.readers[i] for i in data if i < 0x7FE0)


def test_regs_summary(log):
    """Every executed ROM opcode has at least one DB/D record."""
    have = {off for off, _, _ in log.regs}
    ops = {i for i, v in enumerate(log.a) if v & C.OPCODE}
    assert ops == have


def test_roundtrip(log):
    with tempfile.TemporaryDirectory() as d:
        p = os.path.join(d, "x.cdl")
        log.save(p)
        back = C.Cdl.load(p)
        assert back.a == log.a and back.b == log.b and back.wram == log.wram
        assert back.flows == log.flows and back.regs == log.regs
        assert back.readers == log.readers
