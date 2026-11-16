"""The gallery's previews against the game: each `cgram` line of
assets/views.txt names a preview (a `level` or a `preview` line), a play
of tools/c3emu/plays.py (or `poweron`) and a game frame where the game
shows that screen with a steady palette.  At that frame the CGRAM
(Console.cgram()) must hold the colours the preview's palette= gives, at
every index it sets and every index its pixels show (minus skip=, colours
written by code or an animation, explained in a note line).  So a preview
built from the wrong palette, or a palette placed at the wrong index, fails
here, and editing a palette asset changes both sides alike.

As in test_play.py, a frame matches if any game frame within SLACK of it
does (a ROM with another layout can lag a frame elsewhere).  The plays run
in parallel, one process per play (C3_JOBS, default the CPU count); the
longest is stage6_ending_hard up to FINAL SCORE.
"""
import multiprocessing
import os
import sys

import pytest

from tools.c3emu import plays, retro

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import assets  # noqa: E402

SLACK = 2
REFS = assets.read_cgram_refs(ROOT)


def capture(rom, core, play, frames):
    """{frame: [CGRAM at frame - SLACK .. frame + SLACK]} along `play`."""
    want = {}
    for f in frames:
        for k in range(f - SLACK, f + SLACK + 1):
            want.setdefault(k, []).append(f)
    out = {f: [] for f in frames}
    c = retro.Console(rom, core=core)
    last = max(want)
    if play == "poweron":
        for k in sorted(want):
            c.run(k - c.frame_count)
            for f in want[k]:
                out[f].append(c.cgram())
    else:
        for k in plays.run(c, plays.PLAYS[play], every=1):
            for f in want.get(k, ()):
                out[f].append(c.cgram())
            if k >= last:
                break
    c.close()
    return play, out


def _worker(args):
    return capture(*args)


@pytest.fixture(scope="session")
def cgrams(request, rom, core):
    """The CGRAM around every frame the selected cgram lines name, the plays
    run in parallel once per session."""
    names = {item.callspec.params["name"] for item in request.session.items
             if item.originalname == "test_preview_palette"}
    by_play = {}
    for name, play, frame, _skip in REFS:
        if name in names:
            by_play.setdefault(play, set()).add(frame)
    jobs = int(os.environ.get("C3_JOBS", os.cpu_count() or 1))
    ctx = multiprocessing.get_context("spawn")
    with ctx.Pool(max(1, min(jobs, len(by_play)))) as pool:
        return dict(pool.imap_unordered(
            _worker, [(rom, core, p, sorted(fs)) for p, fs in by_play.items()]))


def test_refs():
    """Every cgram line names a preview and a play that exist; every
    level line and every tilemap preview has one."""
    _links, previews = assets.read_views(ROOT)
    levels = dict(assets.read_levels(ROOT))
    names = [r[0] for r in REFS]
    for name, play, _frame, _skip in REFS:
        assert name in levels or name in previews, name
        assert play == "poweron" or play in plays.PLAYS, play
    assert len(names) == len(set(names)), "a preview with two cgram lines"
    missing = sorted((set(levels) | set(previews)) - set(names))
    assert not missing, ("previews without a cgram line in assets/views.txt (a play and a "
                         "frame where the game shows them): %s" % ", ".join(missing))


@pytest.mark.parametrize("name,play,frame,skip", REFS, ids=[r[0] for r in REFS])
def test_preview_palette(cgrams, name, play, frame, skip):
    indices, words = assets.preview_cgram_indices(name, skip, ROOT)
    tries = cgrams[play][frame]
    assert tries, "frame %d of %s not reached" % (frame, play)
    misses = []
    for cg in tries:
        bad = [i for i in indices if cg[i] != words[i]]
        if not bad:
            return
        misses.append(bad)
    cg = tries[len(tries) // 2]
    bad = misses[len(tries) // 2]
    pytest.fail("%s: at frame %d of %s, %d of the %d CGRAM indices it checks differ "
                "(index: preview, CGRAM): %s" % (
                    name, frame, play, len(bad), len(indices),
                    ", ".join("%d: $%04X $%04X" % (i, words[i], cg[i]) for i in bad[:16])))
