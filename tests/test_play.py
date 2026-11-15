"""Scripted plays through every stage (tools/c3emu/plays.py), checked every
CHECK frames against goldens: a hash of the screen (15-bit), of VRAM and of
the audio produced since the previous checkpoint.

The goldens (tests/goldens/play/<play>.json) hold only hashes; they were
taken with the snes9x core from the original ROM.  On a mismatch the test
reports the first checkpoint that differs and saves the actual frame, the
original ROM's frame at that point and a diff mask to out/play/.

The plays run in parallel, one process per play (the cores are
process-wide singletons): C3_JOBS sets the number (default: CPU count).
They also cover the attract sequence frame by frame ("attract").
Together with test_screens.py this is the suite the disassembly's shift
test (`make shift-test`) runs.
"""
import hashlib
import json
import multiprocessing
import os

import pytest
from PIL import ImageChops

from tools.c3emu import plays, retro
from tools.c3emu.rom import rom_path

HERE = os.path.dirname(os.path.abspath(__file__))
GOLDENS = os.path.join(HERE, "goldens", "play")
OUT = os.path.join(os.path.dirname(HERE), "out", "play")
CHECK = 300
ATTRACT_FRAMES = 21000          # logos, intro, title, the three demos, the logo again

NAMES = ["attract"] + list(plays.PLAYS)


def _frames(c, name):
    if name == "attract":
        done = 0
        while done < ATTRACT_FRAMES:
            c.run(CHECK)
            done += CHECK
            yield done
    else:
        yield from plays.run(c, plays.PLAYS[name], every=CHECK)


def _digest(data):
    return hashlib.sha1(data).hexdigest()[:16]


def record(rom, core, name, stop_at=None):
    """Runs a play; returns its checkpoints ([frame, screen, vram, audio]),
    or with stop_at the screen image at that frame."""
    c = retro.Console(rom, core=core, audio=True)
    out = []
    for frame in _frames(c, name):
        if stop_at is not None:
            if frame == stop_at:
                img = c.image()
                c.close()
                return img
            continue
        out.append([frame, _digest(retro.fifteen_bits(c.image())), _digest(c.vram()),
                    _digest(bytes(c.audio))])
        c.audio = bytearray()
    c.close()
    return out


def _worker(args):
    rom, core, name = args
    return name, record(rom, core, name)


@pytest.fixture(scope="session")
def play_runs(request, rom, core):
    """All selected plays, run in parallel once per session."""
    wanted = [item.callspec.params["name"] for item in request.session.items
              if item.originalname == "test_play"]
    jobs = int(os.environ.get("C3_JOBS", os.cpu_count() or 1))
    ctx = multiprocessing.get_context("spawn")
    with ctx.Pool(max(1, min(jobs, len(wanted)))) as pool:
        return dict(pool.imap_unordered(_worker, [(rom, core, n) for n in wanted]))


@pytest.mark.parametrize("name", NAMES)
def test_play(play_runs, rom, core, name, update_goldens):
    got = play_runs[name]
    path = os.path.join(GOLDENS, name + ".json")
    if update_goldens:
        os.makedirs(GOLDENS, exist_ok=True)
        with open(path, "w") as f:
            json.dump({"check": CHECK, "checkpoints": got}, f, indent=0)
        return
    if not os.path.exists(path):
        pytest.fail("no golden %s; run with --update-goldens" % path)
    want = json.load(open(path))["checkpoints"]
    assert len(got) == len(want), "%s: %d checkpoints, golden %d" % (name, len(got), len(want))
    for i, (g, w) in enumerate(zip(got, want)):
        bad = [what for what, x, y in zip(("screen", "vram", "audio"), g[1:], w[1:]) if x != y]
        if bad:
            frame = g[0]
            os.makedirs(OUT, exist_ok=True)
            actual = record(rom, core, name, stop_at=frame)
            golden = record(rom_path(None), core, name, stop_at=frame)
            stem = os.path.join(OUT, "%s_%06d" % (name, frame))
            actual.save(stem + ".actual.png")
            golden.save(stem + ".original.png")
            ImageChops.difference(actual, golden).point(lambda v: 255 if v >= 8 else 0).save(stem + ".diff.png")
            pytest.fail("%s: %s differ(s) first at frame %d of the play (%d of %d checkpoints "
                        "match; see %s.*)" % (name, "/".join(bad), frame, i, len(want), stem))
