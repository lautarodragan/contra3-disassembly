"""tools/asset_limits.py: the build refuses an asset that no longer fits
where the game decompresses it (book: Assets, Size limits).  No emulator
needed: each test builds one asset in a scratch tree and checks it against
the data lists of src/."""
import os
import random
import shutil
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import asset_limits  # noqa: E402
import assets  # noqa: E402
import snesgfx  # noqa: E402

SRC = os.path.join(ROOT, "src")


@pytest.fixture(scope="module")
def manifest():
    assets.build(ROOT)
    return {a.path: a for a in assets.read_manifest(ROOT)}


def scratch(tmp_path, manifest, path, options=None):
    """A tree with only this asset (its source file copied, the manifest
    line with these options); returns (root, asset)."""
    a = manifest[path]
    opts = dict(a.options, **(options or {}))
    root = str(tmp_path)
    os.makedirs(os.path.join(root, "assets", os.path.dirname(path)))
    shutil.copy(os.path.join(ROOT, a.source), os.path.join(root, a.source))
    line = " ".join([path, a.kind] + [f"{k}={v}" for k, v in opts.items()])
    with open(os.path.join(root, assets.MANIFEST), "w") as f:
        f.write(line + "\n")
    return root, assets.read_manifest(root)[0]


def errors(root):
    assets.build(root)
    return asset_limits.check(assets.read_manifest(root), root, SRC)


def add_tiles(png, n, colour=3):
    """Append n tiles of one colour to a PNG asset (16 tiles a row)."""
    W, H, pixels, pal = snesgfx.read_png(png)
    width = W // 8
    tiles = []
    for t in range((W // 8) * (H // 8)):
        x0, y0 = t % width * 8, t // width * 8
        tiles.append([pixels[(y0 + y) * W + x0 + x] for y in range(8) for x in range(8)])
    # drop the padding (colour 0 tiles at the end), then add
    while tiles and not any(tiles[-1]):
        tiles.pop()
    tiles += [[colour] * 64] * n
    rows = (len(tiles) + width - 1) // width
    out = bytearray(W * rows * 8)
    for t, tile in enumerate(tiles):
        x0, y0 = t % width * 8, t // width * 8
        for y in range(8):
            out[(y0 + y) * W + x0:(y0 + y) * W + x0 + 8] = bytes(tile[y * 8:y * 8 + 8])
    snesgfx.write_png(png, W, rows * 8, out, pal)
    return len(tiles)


# ---------------------------------------------------------------- the manifest

def test_every_asset_fits(manifest):
    assert asset_limits.check(list(manifest.values()), ROOT, SRC) == []


def test_recorded_limits_are_what_the_source_gives(manifest):
    assert asset_limits.verify(list(manifest.values()), ROOT, SRC) == []


def test_every_stream_has_a_limit(manifest):
    for a in manifest.values():
        if a.compressed:
            assert "max" in a.options, a.path


# ---------------------------------------------------------------- PNGs

def test_png_too_big_is_rejected(tmp_path, manifest):
    # gfx_0EDA4E: 32 sprite tiles at VRAM $7600, the same list loads
    # gfx_0DEF88 at $7800: no room for a 33rd tile
    root, a = scratch(tmp_path, manifest, "gfx/gfx_0EDA4E")
    n = add_tiles(os.path.join(root, a.source), 1)
    assert n == 33
    assets.write_manifest([assets.Asset(a.path, a.kind, dict(a.options, tiles="33"))], root)
    errs = errors(root)
    assert len(errs) == 1
    msg = errs[0]
    for text in ("gfx_0EDA4E.png", "1,056 bytes", "33 4bpp tiles", "limit of 1,024",
                 "32 4bpp tiles", "max=$0400", "load_list_058C14", "VRAM $7600",
                 "gfx_0DEF88", "$7800"):
        assert text in msg


def test_png_grows_up_to_its_limit(tmp_path, manifest):
    # the font: 253 2bpp tiles at VRAM $5000; the title's BG3 tilemap is at
    # $5800 (BG3SC = $5A), so 256 tiles fit and 257 do not
    root, a = scratch(tmp_path, manifest, "gfx/gfx_089D7E")
    assert a.options["max"] == "$1000"
    png = os.path.join(root, a.source)
    n = add_tiles(png, 3)
    assets.write_manifest([assets.Asset(a.path, a.kind, dict(a.options, tiles=str(n)))], root)
    assert n == 256 and errors(root) == []
    n = add_tiles(png, 1)
    assets.write_manifest([assets.Asset(a.path, a.kind, dict(a.options, tiles=str(n)))], root)
    errs = errors(root)
    assert len(errs) == 1 and "4,112 bytes" in errs[0] and "BG3SC = $5A" in errs[0]


def test_png_tiles_past_the_count_are_rejected(tmp_path, manifest):
    # drawing more tiles without raising tiles= stops the build too
    root, a = scratch(tmp_path, manifest, "gfx/gfx_0EDA4E")
    add_tiles(os.path.join(root, a.source), 1)
    with pytest.raises(SystemExit, match="raise tiles="):
        assets.build(root)


def test_png_must_be_whole_tiles(tmp_path):
    path = str(tmp_path / "odd.png")
    snesgfx.write_png(path, 12, 8, bytes(96), snesgfx.grey_palette(4))
    with pytest.raises(ValueError, match="whole number of 8x8 tiles"):
        snesgfx.png_to_tiles(path, "4bpp")


# ---------------------------------------------------------------- other kinds

def test_bin_too_big_is_rejected(tmp_path, manifest):
    # a WRAM stream: $7E:9400, the same list loads packed_13EF62 at $7E:9800
    root, a = scratch(tmp_path, manifest, "wram/packed_13EE4E")
    assert a.options["max"] == "$0400"
    data = open(os.path.join(root, a.source), "rb").read()
    open(os.path.join(root, a.source), "wb").write(data + bytes(0x400 - len(data)))
    assert errors(root) == []
    open(os.path.join(root, a.source), "ab").write(b"\x01")
    errs = errors(root)
    assert len(errs) == 1 and "1,025 bytes" in errs[0] and "packed_13EF62" in errs[0]


def test_raw_sound_block_must_match_its_size_word(tmp_path, manifest):
    path = next(p for p in manifest if p.startswith("sound/") and manifest[p].kind == "raw"
                and os.path.getsize(os.path.join(ROOT, manifest[p].source)) == 0x100)
    root, a = scratch(tmp_path, manifest, path)
    assert errors(root) == []
    open(os.path.join(root, a.source), "ab").write(b"\x00")
    errs = errors(root)
    assert len(errs) == 1 and "exactly 256 ($0100)" in errs[0] and "load_spc_raw" in errs[0]


def test_stream_larger_than_a_bank_is_rejected(tmp_path, manifest):
    root, a = scratch(tmp_path, manifest, "wram/packed_0AB064", {"max": "$FFFF"})
    rnd = random.Random(1)
    open(os.path.join(root, a.source), "wb").write(bytes(rnd.randrange(256) for _ in range(0x8000)))
    errs = errors(root)
    assert any("more than a bank" in e for e in errs)


# ---------------------------------------------------------------- derivation

@pytest.fixture(scope="module")
def source():
    return asset_limits.Source(SRC)


def test_tail_byte_overwritten_by_the_next_block(source, manifest):
    # gfx_188000: 8,193 bytes at VRAM $2000; the same list loads gfx_1899A4
    # at $3000 after it, over its last byte: it cannot grow
    lim = asset_limits.derive(source, "gfx_188000", 8193, {})
    assert lim.size == 8193 and "gfx_1899A4" in lim.reason and "cannot grow" in lim.reason


def test_blocks_overwritten_whole_do_not_count(source, manifest):
    # load_list_058C97 loads $7000-$7FFF last (gfx_0EA34B), over the blocks
    # it loaded there before: the limit is the end of VRAM
    sizes = asset_limits.recorded_sizes(list(manifest.values()), ROOT)
    lim = asset_limits.derive(source, "gfx_0EA34B", 0x2000, sizes)
    assert lim.size == 0x2000 and "end of VRAM" in lim.reason


def test_wram_bank_7f_wraps(source):
    lim = asset_limits.derive(source, "packed_11DF75", 0x2000, {})
    assert lim.size == 0x2000 and "WRAM bank $7F" in lim.reason


def test_mode7_characters(source):
    lim = asset_limits.derive(source, "gfx_148000", 12545, {})
    assert lim.size == 0x4000 and "256" in lim.reason


def test_td_tiles_fix_the_size(source):
    assert asset_limits.fixed_size(source, "td_sprite_tiles_16")[0] == 0x1800


def test_unknown_capacity(tmp_path):
    # nothing after it but the end of the sound CPU's RAM
    src = tmp_path / "src"
    src.mkdir()
    (src / "lists.asm").write_text(
        "song_set_x:\n\tload_list\t$02, $00\n\tload_spc\t$C000, song_x\n\tload_end\n")
    lim = asset_limits.derive(asset_limits.Source(str(src)), "song_x", 0x123, {})
    assert lim.size == 0x123 and "original size, capacity unknown" in lim.reason


def test_bank_overflow_names_the_assets():
    out = "src/contra3.cfg:17: Warning: Segment 'BANK0A' overflows memory area 'ROM0A' by 3574 bytes\n"
    msg = asset_limits.ld65_diagnosis(out, SRC, [os.path.join(ROOT, d) for d in assets.INCLUDE_DIRS])
    assert "bank $0A is 3,574 bytes too full" in msg
    assert "wram/packed_0AB064.lz" in msg and "cannot cross" in msg
