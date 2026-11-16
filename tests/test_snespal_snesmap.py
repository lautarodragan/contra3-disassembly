"""tools/snespal.py and tools/snesmap.py: palettes and tilemaps <-> text are
exact, and an edited palette line reads as its new colour.  No emulator
needed."""
import os
import random
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import snesmap  # noqa: E402
import snespal  # noqa: E402


@pytest.mark.parametrize("layout", snespal.LAYOUTS)
def test_palette_round_trip(tmp_path, layout):
    rnd = random.Random(layout)
    for n in (1, 3, 16, 128):
        # every bit, bit 15 included
        words = [rnd.randrange(0x10000) for _ in range(n)]
        data = snespal.to_bytes(words, layout)
        assert snespal.from_bytes(data, layout) == words
        path = str(tmp_path / "p.gpl")
        snespal.write_gpl(path, words)
        assert snespal.read_gpl(path) == words
        assert all(exact for _w, exact in snespal.parse_gpl(open(path).read()))
        assert not snespal.normalize(path)


def test_block_size_word():
    assert snespal.to_bytes([0x7FFF, 0], "block") == bytes([3, 0, 0xFF, 0x7F, 0, 0])
    with pytest.raises(ValueError):
        snespal.from_bytes(bytes([4, 0, 0xFF, 0x7F, 0, 0]), "block")


def test_edited_line(tmp_path):
    path = str(tmp_path / "p.gpl")
    snespal.write_gpl(path, [0x8000 | 0x001F, 0x7FFF])
    text = open(path).read()
    # an editor changed the first colour to green and kept the old name
    text = text.replace("255   0   0\t$801F", "  0 255   0\t$801F")
    open(path, "w").write(text)
    assert snespal.read_gpl(path) == [0x03E0, 0x7FFF]
    assert snespal.normalize(path)
    assert "  0 255   0\t$03E0" in open(path).read()
    # a colour that is not a SNES one rounds down
    open(path, "w").write("GIMP Palette\n250 9 0\n")
    assert snespal.read_gpl(path) == [31 | 1 << 5]


@pytest.mark.parametrize("fmt", list(snesmap.FORMATS))
def test_tilemap_round_trip(tmp_path, fmt):
    rnd = random.Random(fmt)
    n, width = snesmap.FORMATS[fmt]
    for rows in (1, 8, 32):
        data = bytes(rnd.randrange(256) for _ in range(n * width * rows))
        path = str(tmp_path / "m.tilemap")
        snesmap.write_text(path, data, fmt, title="test")
        assert snesmap.read_text(path, fmt) == data


def test_tilemap_errors():
    with pytest.raises(ValueError, match="2 cells"):
        snesmap.parse("0000 0000\n", "bg", 32)
    with pytest.raises(ValueError, match="hex digits"):
        snesmap.parse("000\n", "bg", 1)


def test_render_flips():
    tile = list(range(64))
    # one cell, h and v flip, palette 1, 4bpp: colour = 16 + index (0 stays 0)
    W, H, pixels, _pal = snesmap.render(bytes([0, 0xC4]), "bg", 1, {0: tile}, 4, [])
    assert (W, H) == (8, 8)
    assert pixels[0] == 16 + 63 and pixels[63] == 0
