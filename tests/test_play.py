"""Scripted plays through every stage (tools/c3emu/plays.py), checked every
CHECK frames against goldens: a hash of the screen (15-bit) and of the
sound command ring (WRAM $0100-$01FF, what queue_sound sends to the sound
CPU); and the loudness of the audio stream in blocks of AUDIO_BLOCK bytes,
within AUDIO_TOLERANCE.  The audio itself is not compared exactly: when a
command reaches the sound CPU depends on the main CPU's timing to the
cycle, which changes in a ROM with another layout (indexed reads that
cross a page take a cycle more), so a sound can start a few samples
earlier or later; a wrong song or sample is far louder or quieter.  For
the same reason a busy moment can lag a frame earlier or later than in the
original, so a checkpoint matches its golden if any of the frames within
SLACK of it does; and a lone checkpoint that differs in at most
PIXEL_TOLERANCE pixels from the original ROM's frame, between two that
match, is tolerated (reported, not failed): in the top-down split screen
an IRQ can land a few cycles elsewhere in the game code and move a sprite
for a frame.  VRAM is not compared: the
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
PIXEL_TOLERANCE = 64           # pixels: a lone differing checkpoint (see test_play)
SLACK = 2                     # frames: a checkpoint matches the golden within +-SLACK frames
AUDIO_BLOCK = 65536           # bytes: 16384 stereo samples, about 0.5 s
AUDIO_TOLERANCE = 0.08        # relative difference of mean absolute amplitude
ATTRACT_FRAMES = 21000          # logos, intro, title, the three demos, the logo again

NAMES = ["attract"] + list(plays.PLAYS)


def _frames(c, name):
    """Yields after every frame of the play."""
    if name == "attract":
        for done in range(1, ATTRACT_FRAMES + 1):
            c.run(1)
            yield done
    else:
        yield from plays.run(c, plays.PLAYS[name], every=1)


def _level(block):
    v = memoryview(block).cast("h")
    return sum(map(abs, v)) // len(v)


def _digest(data):
    return hashlib.sha1(data).hexdigest()[:12]


def record(rom, core, name, stop_at=None):
    """Runs a play; returns {"screen": [[frame, hash, [hashes]], ...],
    "sound": [...], "audio": [[frame, level], ...]}: per checkpoint, the
    hash at that frame and those of the SLACK frames around it; an audio
    entry per complete block, with the frame by which it was complete.
    With stop_at, returns the screen image at that frame."""
    c = retro.Console(rom, core=core, audio=True)
    screen, sound, audio = {}, {}, []
    for frame in _frames(c, name):
        if stop_at is not None:
            if frame == stop_at:
                img = c.image()
                c.close()
                return img
            c.audio = bytearray()
            continue
        near = (frame + SLACK) // CHECK * CHECK
        if near and abs(frame - near) <= SLACK:
            for d, h in ((screen, _digest(retro.fifteen_bits(c.image()))),
                         (sound, _digest(c.ram(0x0100, 0x100)))):
                e = d.setdefault(near, [near, None, []])
                e[2].append(h)
                if frame == near:
                    e[1] = h
        n = len(c.audio) // AUDIO_BLOCK * AUDIO_BLOCK
        for k in range(0, n, AUDIO_BLOCK):
            audio.append([frame, _level(bytes(c.audio[k:k + AUDIO_BLOCK]))])
        del c.audio[:n]
    c.close()
    out = lambda d: [e for _f, e in sorted(d.items()) if e[1] is not None]
    return {"screen": out(screen), "sound": out(sound), "audio": audio}


def images_at(rom, core, name, frames):
    """{frame: screen image} for the given frames of a play."""
    c = retro.Console(rom, core=core)
    want, out = set(frames), {}
    for frame in _frames(c, name):
        if frame in want:
            out[frame] = c.image()
            if len(out) == len(want):
                break
    c.close()
    return out


def pixels_differing(a, b):
    x, y = retro.fifteen_bits(a), retro.fifteen_bits(b)
    return sum(1 for i in range(0, len(x), 3) if x[i:i + 3] != y[i:i + 3])


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
            got = {k: [e[:2] for e in v] for k, v in got.items()}
            json.dump(dict(got, check=CHECK, slack=SLACK, audio_block=AUDIO_BLOCK), f, indent=0)
        return
    if not os.path.exists(path):
        pytest.fail("no golden %s; run with --update-goldens" % path)
    want = json.load(open(path))
    first = None
    isolated = []
    for what in ("screen", "sound", "audio"):
        g, w = got[what], want[what]
        if what == "screen" and len(g) != len(w):
            pytest.fail("%s: %d checkpoints, golden %d" % (name, len(g), len(w)))
        bad = []
        for i, (x, y) in enumerate(zip(g, w)):
            if what == "audio":
                miss = abs(x[1] - y[1]) > AUDIO_TOLERANCE * max(x[1], y[1]) + 16
            else:
                miss = y[1] not in x[2]
            if miss:
                bad.append(i)
        if what == "screen":
            # A lone checkpoint whose screen differs in a few pixels, between
            # two that match, is tolerated (checked below): a sprite or a
            # raster split a cycle-timing change can move for one frame.
            isolated = [i for i in bad if i - 1 not in bad and i + 1 not in bad and 0 < i < len(g) - 1]
            bad = [i for i in bad if i not in isolated]
        if bad:
            i = bad[0]
            if first is None or g[i][0] < first[0]:
                first = (g[i][0], what, i, len(w))
    if isolated and first is None:
        frames = [got["screen"][i][0] for i in isolated]
        span = sorted({f + d for f in frames for d in range(-SLACK, SLACK + 1)})
        act = images_at(rom, core, name, span)
        orig = images_at(rom_path(None), core, name, frames)
        for i, f in zip(isolated, frames):
            n = min(pixels_differing(act[f + d], orig[f]) for d in range(-SLACK, SLACK + 1) if f + d in act)
            if n > PIXEL_TOLERANCE:
                first = (f, "screen (%d pixels)" % n, i, len(want["screen"]))
                break
            print("%s: frame %d differs in %d pixels, tolerated" % (name, f, n))
    if first:
        frame, what, i, n = first
        os.makedirs(OUT, exist_ok=True)
        actual = record(rom, core, name, stop_at=frame)
        golden = record(rom_path(None), core, name, stop_at=frame)
        stem = os.path.join(OUT, "%s_%06d" % (name, frame))
        actual.save(stem + ".actual.png")
        golden.save(stem + ".original.png")
        ImageChops.difference(actual, golden).point(lambda v: 255 if v >= 8 else 0).save(stem + ".diff.png")
        pytest.fail("%s: %s differs first at frame %d of the play (checkpoint %d of %d; see %s.*)"
                    % (name, what, frame, i, n, stem))
