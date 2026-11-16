"""tools/snesgfx.py: tiles <-> PNG is exact, and the PNG reader takes what
image editors write (checked with Pillow: other bit depths, filters,
compression levels).  No emulator needed."""
import os
import random
import sys

import pytest
from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import snesgfx  # noqa: E402


@pytest.mark.parametrize("fmt", list(snesgfx.FORMATS))
def test_round_trip(tmp_path, fmt):
    rnd = random.Random(fmt)
    size = snesgfx.FORMATS[fmt][1]
    for ntiles in (1, 15, 16, 37):
        data = bytes(rnd.randrange(256) for _ in range(ntiles * size))
        path = str(tmp_path / "t.png")
        snesgfx.tiles_to_png(data, fmt, path, width=16)
        assert snesgfx.png_to_tiles(path, fmt, ntiles) == data
        # and Pillow sees the same indices
        im = Image.open(path)
        assert im.mode == "P"
        assert list(im.tobytes()) == list(snesgfx.read_png(path)[2])


@pytest.mark.parametrize("bits", [1, 2, 4, 8])
@pytest.mark.parametrize("optimize", [False, True])
def test_reads_pillow_pngs(tmp_path, bits, optimize):
    rnd = random.Random(bits)
    w, h = 24, 16
    pixels = [rnd.randrange(1 << bits) for _ in range(w * h)]
    im = Image.new("P", (w, h))
    im.putdata(pixels)
    im.putpalette([v for i in range(1 << bits) for v in (i, i, i)])
    path = str(tmp_path / "p.png")
    im.save(path, bits=bits, optimize=optimize)
    W, H, got, _pal = snesgfx.read_png(path)
    assert (W, H) == (w, h)
    if not optimize:
        assert list(got) == pixels


def test_rejects_rgb(tmp_path):
    path = str(tmp_path / "rgb.png")
    Image.new("RGB", (8, 8)).save(path)
    with pytest.raises(ValueError, match="indexed"):
        snesgfx.read_png(path)


def test_padding_must_stay_blank(tmp_path):
    data = bytes(range(32)) * 3
    path = str(tmp_path / "pad.png")
    snesgfx.tiles_to_png(data, "4bpp", path, width=2)    # 3 tiles in a 2x2 grid
    W, H, pixels, pal = snesgfx.read_png(path)
    pixels = bytearray(pixels)
    pixels[8 * W + 8 + 1] = 1                             # draw in the 4th tile
    snesgfx.write_png(path, W, H, pixels, pal)
    with pytest.raises(ValueError, match="past the 3 tiles"):
        snesgfx.png_to_tiles(path, "4bpp", 3)
