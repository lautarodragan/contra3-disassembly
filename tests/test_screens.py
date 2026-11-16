"""Screenshots at fixed frames compared against goldens, at 15-bit precision.

The goldens were taken with the snes9x core from the original ROM. A ROM
rebuilt from the disassembly must match them pixel for pixel: the whole point
of a byte-exact disassembly is that nothing on screen changes.

On a mismatch the actual frame and a diff mask go to out/screens/.
"""
import os

import pytest
from PIL import Image, ImageChops

from tools.c3emu import game, retro

HERE = os.path.dirname(os.path.abspath(__file__))
GOLDENS = os.path.join(HERE, "goldens")
OUT = os.path.join(os.path.dirname(HERE), "out", "screens")

# Power-on with no input: (name, frame).
ATTRACT = [
    ("konami", game.FRAME_KONAMI),
    ("intro", game.FRAME_INTRO),
    ("title", game.FRAME_TITLE),
    ("demo_stage1", game.FRAME_DEMO1),
    ("demo_stage2", game.FRAME_DEMO2),
    ("demo_stage4", game.FRAME_DEMO3),
]

# Start pressed at the title, stage poked, then N frames: (name, stage, frames).
STAGES = [
    ("stage1_start", 1, 600),
    ("stage2_start", 2, 600),
    ("stage3_start", 3, 600),
    ("stage4_start", 4, 600),
    ("stage5_start", 5, 600),
    ("stage6_start", 6, 600),
]


def check(name, image, update):
    path = os.path.join(GOLDENS, name + ".png")
    if update:
        os.makedirs(GOLDENS, exist_ok=True)
        image.save(path)
        return
    if not os.path.exists(path):
        pytest.fail("no golden %s; run with --update-goldens" % path)
    golden = Image.open(path).convert("RGB")
    if golden.size != image.size:
        pytest.fail("%s: size %s, golden %s" % (name, image.size, golden.size))
    a, b = retro.fifteen_bits(image), retro.fifteen_bits(golden)
    if a != b:
        os.makedirs(OUT, exist_ok=True)
        image.save(os.path.join(OUT, name + ".actual.png"))
        diff = ImageChops.difference(image, golden).point(lambda v: 255 if v >= 8 else 0)
        diff.save(os.path.join(OUT, name + ".diff.png"))
        bad = sum(1 for i in range(0, len(a), 3) if a[i:i + 3] != b[i:i + 3])
        pytest.fail("%s: %d pixels differ (see %s)" % (name, bad, OUT))


@pytest.fixture(scope="module")
def attract(rom, core):
    """One run from power-on, frames captured at every ATTRACT checkpoint."""
    c = retro.Console(rom, core=core)
    shots = {}
    for name, frame in sorted(ATTRACT, key=lambda x: x[1]):
        c.run(frame - c.frame_count)
        shots[name] = c.image()
    c.close()
    return shots


@pytest.mark.parametrize("name", [n for n, _ in ATTRACT])
def test_attract(attract, name, update_goldens):
    check(name, attract[name], update_goldens)


@pytest.mark.parametrize("name,stage,frames", STAGES, ids=[s[0] for s in STAGES])
def test_stage_start(rom, core, name, stage, frames, update_goldens):
    c = retro.Console(rom, core=core)
    game.start_game(c, stage=stage)
    c.run(frames)
    assert c.peek(game.STAGE) == stage
    check(name, c.image(), update_goldens)
    c.close()


def test_deterministic(rom, core):
    """Two power-ons give the same frame: the goldens depend on it."""
    frames = []
    for _ in range(2):
        c = retro.Console(rom, core=core)
        c.run(game.FRAME_DEMO1)
        frames.append(retro.fifteen_bits(c.image()))
        c.close()
    assert frames[0] == frames[1]
