"""tools/spawns.py: the spawn lists as text read back exactly, edits read
as meant, malformed text is refused, the include matches the ROM, and the
gallery draws the markers.  No emulator needed."""
import os
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import spawns  # noqa: E402

TYPES = spawns.object_types(ROOT)
FILES = spawns.files(ROOT)


def _read(f):
    return spawns.read(os.path.join(ROOT, f), TYPES)


def test_files():
    assert [os.path.basename(f) for f in FILES] == ["extra.spawns", "stage1.spawns", "stage3.spawns", "stage6.spawns"]


@pytest.mark.parametrize("f", FILES)
def test_text_round_trip(f):
    sp = _read(f)
    text = open(os.path.join(ROOT, f)).read()
    assert spawns.text(sp, TYPES) == text
    again = spawns.parse(text, f, TYPES)
    assert spawns.inc(again, f) == spawns.inc(sp, f)


def test_bytes_match_rom():
    """The lists of the text are the bytes of the original ROM (the build
    checks the same through the SHA-1)."""
    rom = os.path.join(ROOT, "build", "contra3.sfc")
    if not os.path.exists(rom):
        pytest.skip("no build/contra3.sfc")
    data = open(rom, "rb").read()
    got = spawns.extract(data, TYPES)
    for stage, table, pages in spawns.ORIGINAL:
        sp = _read(f"assets/stages/stage{stage}.spawns")
        start = 5 * 0x8000 + (table & 0x7FFF) + 2 * pages
        end = 5 * 0x8000 + (spawns.ORIGINAL_END[stage] & 0x7FFF)
        assert spawns.table_bytes(sp) == data[start:end]
        assert spawns.table_bytes(got[stage]) == data[start:end]
        assert sp.page_labels() == got[stage].page_labels()


HEAD = "table pages_x\nlist list_a page 0\n"


def _parse(body):
    return spawns.parse(HEAD + body, "t.spawns", TYPES)


def test_entry():
    sp = _parse("  10  OBJT_WEAPON_CAPSULE  -16  48  0006  300-780\n  end\n")
    e = sp.lists[0].entries[0]
    assert e.bytes() == bytes([0x10, 0x0F, 0x78, 0x30, 0xF0, 0xFF, 0x30, 0x00, 0x06, 0x00])
    sp = _parse("  FE  $36  512  -1  ABCD  9C0-AC0\n  end\n")
    assert sp.lists[0].bytes() == bytes([0xFE, 0x36, 0xAC, 0x9C, 0x00, 0x02, 0xFF, 0xFF, 0xCD, 0xAB, 0xFF, 0x00])
    inc = spawns.inc(sp, "t")
    assert "pages_x:\n\t.addr\tlist_a\nlist_a:\n" in inc
    assert "\t.byte\t$FE, OBJT_DELETE_OBJECT_TRIGGER, $AC, $9C" not in inc   # $36 written as a number
    assert "\t.byte\t$FE, $36, $AC, $9C\n\t.word\t$0200, $FFFF, $ABCD\n\t.byte\t$FF, $00\n" in inc


def test_shared_and_foreign_pages():
    sp = spawns.parse("table t\nlist a page 0,2\n  end\npage 1 elsewhere\nlist b page 3\n"
                      "  10  OBJT_ALIEN_DOG  256  190  0000  280-300\nlist c\n  end\n", "t", TYPES)
    assert sp.page_labels() == ["a", "elsewhere", "a", "b"]
    assert [e.type for e in sp.page_entries(3)] == [0x1E]      # b runs on into c
    assert sp.page_entries(1) is None
    assert "c:\n\t; LAYOUT: read on from b" in spawns.inc(sp, "t")


@pytest.mark.parametrize("body, message", [
    ("  10  OBJT_NO_SUCH  0  0  0000  300-780\n  end\n", "unknown type"),
    ("  FF  OBJT_ALIEN_DOG  0  0  0000  300-780\n  end\n", "terminator"),
    ("  10  OBJT_ALIEN_DOG  0  0  0000  300-310\n  end\n", "slot addresses"),
    ("  10  OBJT_ALIEN_DOG  0  0  0000  200-300\n  end\n", "within"),
    ("  10  OBJT_ALIEN_DOG  0  0  0000\n  end\n", "6 columns"),
    ("  10  OBJT_ALIEN_DOG  40000  0  0000  300-780\n  end\n", "out of range"),
    ("  20  OBJT_ALIEN_DOG  0  0  0000  300-780\n  10  OBJT_ALIEN_DOG  0  0  0000  300-780\n  end\n",
     "must not go down"),
    ("  10  OBJT_ALIEN_DOG  0  0  0000  300-780\n", "no `end`"),
    ("  end\nlist b page 2\n  end\n", "no list for page"),
])
def test_refused(body, message):
    with pytest.raises(spawns.SpawnError, match=message):
        _parse(body)


def test_placements_and_draw():
    sp = spawns.parse("table t\nlist a page 0\n  20  OBJT_ALIEN_DOG  256  190  0000  280-300\n  end\n"
                      "list b page 1\n  10  OBJT_ALIEN_DOG  16  -1  0000  280-300\n"
                      "  40  OBJT_SCROLL_STOP_TRIGGER  0  0  0000  9C0-AC0\n  end\n"
                      "list c page 2\n  end\n", "t", TYPES)
    # page 2 above page 1: page 1's list is read while the screen climbs
    got = [(p, x, y, v) for _e, p, x, y, _sx, _sy, v in spawns.placements(sp, [0, 1, 2], [2])]
    assert got == [(0, 0x20 + 256, 256 + 190, False), (1, 256 + 16, 256 - 0x10 - 1, True),
                   (1, 256, 256 - 0x40, True)]
    W, H = 512, 512
    _, _, px, pal = spawns.draw(W, H, bytes(W * H), [(0, 0, 0)] * 128, sp, [0, 1, 2], [2])
    assert pal[spawns.OBJECT] == spawns.COLOURS[spawns.OBJECT]
    assert px[(256 + 190) * W + 0x20 + 256 + 4] == spawns.OBJECT    # the box around the dog
    assert spawns.TRIGGER in px


# The extra stage's snipers and grenade soldiers do not fall (their
# handlers have no gravity: OBJ_Y, their feet, stays where they spawn), so
# each must spawn standing on something (book: Stage 2: Collapsed Tower,
# Visual review): a tile with a floor collision class under its feet (as
# the players stand), or one of these places that look like a floor but
# have no collision, (x, y) of the gallery's picture as tools/spawns.py
# places them: the cafe's roof, a window of the green block, three windows
# of the tower facade on the climb.
EXTRA_SILLS = {(828, 848), (1384, 874), (2600, 688), (2728, 560), (2728, 368)}
STANDING = ("OBJT_WINDOW_SNIPER", "OBJT_GRENADE_SOLDIER")


def test_extra_stage_standing_spawns():
    import assets
    manifest = {a.path: a for a in assets.read_manifest(ROOT)}
    view = dict(assets.read_levels(ROOT))["extra_bg1"]
    cells, width, _ = assets.level_cells(view, manifest, ROOT)
    sp = spawns.read(os.path.join(ROOT, "assets", "stages", "extra.spawns"), TYPES)
    route = assets.page_list(view["route"])

    def floor(x, y):
        # stage 1's thresholds (book: Side-view collision map): classes 1-4
        # ($391-$3F9) are floors; the bars ($3FA-$3FF) are not
        w = cells[(y // 8) * width + x // 8] if y >= 0 else None
        return w is not None and 0x391 <= (w & 0x3FF) <= 0x3F9

    bad = []
    for e, page, x, y, _sx, _sy, _v in spawns.placements(sp, route, assets.page_list(view["up"])):
        if e.type_name not in STANDING or (x, y) in EXTRA_SILLS:
            continue
        if y % 8 or not (floor(x, y) or floor(x + 8, y)) or floor(x, y - 8) or floor(x + 8, y - 8):
            bad.append((page, f"{e.pos:02X}", e.type_name, x, y))
    assert not bad, bad
