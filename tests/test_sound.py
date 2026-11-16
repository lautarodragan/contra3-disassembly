"""The sound tools: tools/spcseq.py (songs as text), tools/brr.py (samples),
tools/spc700.py (disassembler), tools/spcasm.py (assembler, the driver). No
emulator needed; that the songs, samples and driver give the ROM's bytes is
what `make` checks."""
import glob
import os
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import brr  # noqa: E402
import spc700  # noqa: E402
import spcasm  # noqa: E402
import spcseq  # noqa: E402

SONGS = sorted(glob.glob(os.path.join(ROOT, "assets", "sound", "spc_song_*.seq")))
DRIVER = os.path.join(ROOT, "assets", "sound", "spc_driver.s")


@pytest.mark.parametrize("path", SONGS, ids=os.path.basename)
def test_song_text_round_trip(path):
    """text -> bytes -> text -> the same bytes, and the same statements."""
    text = open(path).read()
    at, data = spcseq.assemble(text, path)
    songs = [0x4B00] if ".org $4B00" in text else []
    again = spcseq.totext(data, at, songs)
    assert spcseq.assemble(again)[1] == data
    strip = [line.split("#")[0].split() for line in text.split("\n")]
    assert [w for w in strip if w] == [line.split() for line in again.split("\n") if line.strip()]


def test_song_edit_moves_labels():
    text = "at $3000\n\tsong A\nA:\n\tnote $10 $08 $64 $40\n\tjump A\n"
    at, data = spcseq.assemble(text)
    assert data == bytes([0x02, 0x30, 0x10, 0x08, 0x64, 0x40, 0xFD, 0x02, 0x30])
    longer = text.replace("\tsong A\n", "\tsong A\n\t.byte $00\n")
    assert spcseq.assemble(longer)[1][:2] == bytes([0x03, 0x30])


def test_note_forms():
    for b in ([0x10, 0x08, 0x64, 0x40], [0x90, 0x64, 0x40], [0x10, 0x08, 0xC0], [0x90, 0xC0]):
        data = bytes([0x02, 0x30] + b + [0xFF])
        text = spcseq.totext(data, 0x3000)
        assert spcseq.assemble(text)[1] == data


def test_brr_decode_silence_and_wav():
    block = bytes([0x01]) + bytes(8)            # one block, end flag, zeros
    assert brr.decode(block) == [0] * 16
    wav = brr.wav_bytes([0, 1, -1])
    assert wav[:4] == b"RIFF" and wav[8:12] == b"WAVE" and len(wav) == 44 + 6


def test_brr_lists():
    assert brr.check(ROOT) == 0


def test_spc700_decode():
    mem = bytearray(0x10000)
    mem[0x200:0x206] = bytes([0x5F, 0x96, 0x08, 0x8F, 0x30, 0xF1])
    assert spc700.decode(mem, 0x200)[:2] == (3, "jmp $0896")
    assert spc700.decode(mem, 0x203)[:2] == (3, "mov $F1, #$30")


def test_spcasm_every_opcode():
    """Each of the 256 opcodes, as spc700.py prints it, assembles to its bytes."""
    for op in range(256):
        for operands in ([0x12, 0x34], [0xF0, 0x05], [0x80, 0x7F]):
            mem = bytearray(0x10010)
            mem[0x1000] = op
            mem[0x1001:0x1003] = bytes(operands)
            n, text, _ = spc700.decode(mem, 0x1000)
            mnem, _, ops = text.partition(" ")
            assert spcasm.encode(mnem, ops, 0x1000, {"_": 0}) == bytes(mem[0x1000:0x1000 + n]), text


def test_spcasm_labels_and_directives(tmp_path):
    (tmp_path / "s.seq").write_text("at $0210\nS:\n\tsong S1\nS1:\n\tinst $01\n\tend\n")
    (tmp_path / "a.s").write_text(
        "\t.org $0200\nstart:\tmov a, #<S\n\tmov y, #>S\n\tbne start\n\tcall !far\n"
        "far:\tjmp [!table+x]\ntable:\t.word start, S1\n\t.org $0210\n"
        '\t.incseq "s.seq"\n\t.org $0220\n')
    at, data = spcasm.assemble(str(tmp_path / "a.s"))
    assert at == 0x200 and len(data) == 0x20
    assert data[:13] == bytes([0xE8, 0x10, 0x8D, 0x02, 0xD0, 0xFA, 0x3F, 0x09, 0x02,
                               0x1F, 0x0C, 0x02, 0x00])
    assert data[0x10:0x17] == bytes([0x12, 0x02, 0xE2, 0x01, 0xFF, 0, 0])
    (tmp_path / "a.s").write_text("\t.org $0200\n\t.byte 1, 2, 3\n\t.org $0202\n")
    with pytest.raises(spcasm.AsmError, match="reach"):
        spcasm.assemble(str(tmp_path / "a.s"))


def test_driver_round_trip(tmp_path):
    """The driver's source assembles to the $2E00 bytes of $0200-$2FFF, and
    the generator's text of those bytes assembles to them again."""
    at, data = spcasm.assemble(DRIVER)
    assert at == 0x0200 and len(data) == 0x2E00
    asm, seq = spcasm.driver_totext(data)
    (tmp_path / "spc_driver.s").write_text(asm)
    (tmp_path / "spc_sfx.seq").write_text(seq)
    assert spcasm.assemble(str(tmp_path / "spc_driver.s")) == (at, data)


def test_driver_sound_effect_edit_moves_the_rest(tmp_path):
    """A sound effect that grows moves the ones after it, and the sound
    table follows (its entries are the labels of spc_sfx.seq)."""
    sfx = open(os.path.join(os.path.dirname(DRIVER), "spc_sfx.seq")).read()
    (tmp_path / "spc_driver.s").write_text(open(DRIVER).read())
    (tmp_path / "spc_sfx.seq").write_text(sfx)
    at, before = spcasm.assemble(str(tmp_path / "spc_driver.s"))
    head = sfx.index("sound_3E_ch0:\n")
    end = sfx.index("\tend\n", head)
    (tmp_path / "spc_sfx.seq").write_text(sfx[:end] + "\tchannel_volume $02\n" + sfx[end:])
    at, after = spcasm.assemble(str(tmp_path / "spc_driver.s"))
    assert len(after) == len(before) == 0x2E00

    def table(data):
        return [data[0x3E6 - at + 5 * i + 3] | data[0x3E6 - at + 5 * i + 4] << 8
                for i in range(0x73)]
    edited = table(before)[0x3E - 1]
    for old, new in zip(table(before), table(after)):
        assert new == (old + 2 if edited < old < 0x3000 else old)
