"""tools/levelmap.py: level maps and metatiles <-> text are exact, edits
read back as meant, malformed text is refused, and the previews follow the
data.  No emulator needed."""
import os
import random
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import asset_limits  # noqa: E402
import assets  # noqa: E402
import levelmap  # noqa: E402


def _random(fmt, rnd):
    if fmt in ("metatiles", "blocks"):
        return bytes(rnd.randrange(256) for _ in range(0x20 * rnd.randrange(1, 40)))
    if fmt == "bgmap":
        words = [rnd.randrange(0x200) << 5 | rnd.choice((0, 0x4000, 0x8000, 0xC000))
                 for _ in range(64 * rnd.randrange(1, 5))]
        return b"".join(w.to_bytes(2, "little") for w in words)
    return bytes(b for _ in range(256) for b in (rnd.randrange(256), rnd.choice((0, 0, 1))))


@pytest.mark.parametrize("fmt", list(levelmap.FORMATS))
def test_round_trip(tmp_path, fmt):
    rnd = random.Random(fmt)
    for first in (0, 0x100):
        for _ in range(5):
            data = _random(fmt, rnd)
            path = str(tmp_path / ("x" + levelmap.FORMATS[fmt][0]))
            levelmap.write_text(path, data, fmt, "test", first)
            assert levelmap.read_text(path, fmt, first) == data


def test_bgmap_cells():
    page = "\n".join(["000 001h 002v 003hv 1FF 0A vh 7"] * 8)
    page = page.replace(" vh ", " 00Avh ")
    data = levelmap.parse(page, "bgmap")
    words = [data[i] | data[i + 1] << 8 for i in range(0, 16, 2)]
    assert words == [0, 0x20 | 0x4000, 0x40 | 0x8000, 0x60 | 0xC000, 0x3FE0, 0x140,
                     0x140 | 0xC000, 0xE0]


def test_blockmap_layout():
    # row r, column c is the word at (c // 8) * $80 + r * $10 + (c % 8) * 2
    rows = [" ".join(f"{(r * 32 + c) & 0xFF:02X}" for c in range(32)) for r in range(8)]
    data = levelmap.parse("\n".join(rows), "blockmap")
    assert data[0x80 * 1 + 0x10 * 2 + 3 * 2] == (2 * 32 + 11) & 0xFF


@pytest.mark.parametrize("fmt,text,msg", [
    ("metatiles", "001: " + " | ".join(["0000 0000 0000 0000"] * 4), r"expected \$000"),
    ("metatiles", "000: " + " | ".join(["0000 0000 0000 0000"] * 3), "3 rows"),
    ("metatiles", "000: " + " | ".join(["0000 0000 0000 000"] * 4), "not 4 hex digits"),
    ("bgmap", "000 " * 7, "7 cells"),
    ("bgmap", "\n".join(["000 " * 8] * 7), "not a whole number of pages"),
    ("bgmap", "\n".join(["200 " * 8] * 8), r"past \$1FF"),
    ("bgmap", "\n".join(["00x " * 8] * 8), "not a metatile number"),
    ("blockmap", "\n".join(["00 " * 32] * 7), "7 rows"),
    ("blockmap", "\n".join(["000 " * 32] * 8), "not a block number"),
])
def test_errors(fmt, text, msg):
    with pytest.raises(ValueError, match=msg):
        levelmap.parse(text, fmt)


def test_bgmap_refuses_odd_offsets():
    with pytest.raises(ValueError, match="multiple of"):
        levelmap.text(b"\x10\x00" * 64, "bgmap")


def test_assets_and_previews():
    """Every level asset reads back to bytes of whole units, and each level
    preview of assets/views.txt renders; changing a map cell changes it."""
    manifest = {a.path: a for a in assets.read_manifest()}
    levels = [a for a in manifest.values() if a.level]
    assert len(levels) == 41
    for a in levels:
        n = len(a.from_source()) - len(bytes.fromhex(a.options.get("tail", "")))
        assert n % levelmap.FORMATS[a.level][1] == 0
    views = dict(assets.read_levels())
    assert len(views) == 13
    view = views["stage1_bg1"]
    W, H, pixels, _pal = assets.render_level(view, manifest)
    assert (W, H) == (2048, 1024)
    cells, width, mode7 = assets.level_cells(view, manifest)
    assert not mode7 and width == 256


def test_page_positions_stack_vertical_stretches():
    # 0-2 right, 3-4 up, 5 right; bands of 4 columns
    where = levelmap.page_positions(8, per_row=4, up={3, 4})
    assert where[0] == (0, 2) and where[2] == (2, 2)
    assert where[3] == (2, 1) and where[4] == (2, 0) and where[5] == (3, 0)
    assert where[6] == (0, 3) and where[7] == (1, 3)
    cells, width = levelmap.side_tilemap(bytes(8 * levelmap.PAGE), bytes(0x20), 4, {3, 4})
    assert width == 4 * 32 and len(cells) == width * 4 * 32
    assert cells[0] is None and cells[2 * 32 * width] == 0


def test_limit_note_counts_units():
    a = assets.Asset("wram/x", "lz-v1", {"level": "metatiles"})
    assert asset_limits._tiles_note(a, 0x2020) == " (257 metatiles)"
    a = assets.Asset("wram/y", "lz-v1", {"level": "blockmap", "tail": "00"})
    assert asset_limits._tiles_note(a, 0x201) == " (1 8 block rows + 1 tail)"
