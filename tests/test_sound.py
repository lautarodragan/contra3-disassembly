"""The sound tools: tools/spcseq.py (songs as text), tools/brr.py (samples),
tools/spc700.py (disassembler). No emulator needed; that the songs and
samples give the ROM's bytes is what `make` checks."""
import glob
import os
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import brr  # noqa: E402
import spc700  # noqa: E402
import spcseq  # noqa: E402

SONGS = sorted(glob.glob(os.path.join(ROOT, "assets", "sound", "*.seq")))


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
