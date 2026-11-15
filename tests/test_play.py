"""Scripted plays through every stage (tools/c3emu/plays.py), checked every
CHECK frames against goldens: a hash of the screen (15-bit) and of the
sound command ring (WRAM $0100-$01FF, what queue_sound sends to the sound
CPU); and the loudness of the audio stream in blocks of AUDIO_BLOCK bytes,
within AUDIO_TOLERANCE.  The audio itself is not compared exactly: when a
command reaches the sound CPU depends on the main CPU's timing to the
cycle, which changes in a ROM with another layout (indexed reads that
cross a page take a cycle more), so a sound can start a few samples
earlier or later; a wrong song or sample is far louder or quieter.  VRAM is not compared: the
game DMAs some WRAM to VRAM that never shows (the empty slots of the
top-down sprite stream copy the direct page), and WRAM holds ROM addresses,
which differ in a ROM rebuilt with another layout.

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
CHECK = 60
AUDIO_BLOCK = 65536           # bytes: 16384 stereo samples, about 0.5 s
AUDIO_TOLERANCE = 0.08        # relative difference of mean absolute amplitude
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


def _level(block):
    v = memoryview(block).cast("h")
    return sum(map(abs, v)) // len(v)


def _digest(data):
    return hashlib.sha1(data).hexdigest()[:12]


def record(rom, core, name, stop_at=None):
    """Runs a play; returns {"screen": [[frame, hash], ...], "sound": [[frame,
    hash], ...], "audio": [[frame, level], ...]} (an audio entry per complete
    block, with the checkpoint by which it was complete), or with stop_at
    the screen image at that frame."""
    c = retro.Console(rom, core=core, audio=True)
    screen, sound, audio = [], [], []
    for frame in _frames(c, name):
        if stop_at is not None:
            if frame == stop_at:
                img = c.image()
                c.close()
                return img
            c.audio = bytearray()
            continue
        screen.append([frame, _digest(retro.fifteen_bits(c.image()))])
        sound.append([frame, _digest(c.ram(0x0100, 0x100))])
        n = len(c.audio) // AUDIO_BLOCK * AUDIO_BLOCK
        for k in range(0, n, AUDIO_BLOCK):
            audio.append([frame, _level(bytes(c.audio[k:k + AUDIO_BLOCK]))])
        del c.audio[:n]
    c.close()
    return {"screen": screen, "sound": sound, "audio": audio}


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
            json.dump(dict(got, check=CHECK, audio_block=AUDIO_BLOCK), f, indent=0)
        return
    if not os.path.exists(path):
        pytest.fail("no golden %s; run with --update-goldens" % path)
    want = json.load(open(path))
    first = None
    for what in ("screen", "sound", "audio"):
        g, w = got[what], want[what]
        if what == "screen" and len(g) != len(w):
            pytest.fail("%s: %d checkpoints, golden %d" % (name, len(g), len(w)))
        for i, (x, y) in enumerate(zip(g, w)):
            if what == "audio":
                bad = abs(x[1] - y[1]) > AUDIO_TOLERANCE * max(x[1], y[1]) + 16
            else:
                bad = x[1] != y[1]
            if bad:
                if first is None or x[0] < first[0]:
                    first = (x[0], what, i, len(w))
                break
    if first:
        frame, what, i, n = first
        os.makedirs(OUT, exist_ok=True)
        actual = record(rom, core, name, stop_at=frame)
        golden = record(rom_path(None), core, name, stop_at=frame)
        stem = os.path.join(OUT, "%s_%06d" % (name, frame))
        actual.save(stem + ".actual.png")
        golden.save(stem + ".original.png")
        ImageChops.difference(actual, golden).point(lambda v: 255 if v >= 8 else 0).save(stem + ".diff.png")
        pytest.fail("%s: %s differs first at frame %d of the play (%s %d of %d match; see %s.*)"
                    % (name, what, frame, what, i, n, stem))
