"""The extra-stage build (src/game/stages.inc; book: Adding a stage), in the
emulator: `make cheats CHEATS=extra_stage` inserts a side-view stage as
stage 2 and renumbers the original stages 2-6 as 3-7.  Until the stage is
designed it is stage 1's data, so the game must play exactly as the
original, one stage later:

- `stage2_boss`: the new stage 2 from its midpoint (stage 1's boss), the
  stage clear, then stage 3, the top-down stage, plays frame for frame as
  the original's `stage1_boss` (its golden, tests/goldens/play/);
- `stage3_boss`, `stage6_boss`: the top-down bosses (stages 3 and 6 now)
  and the next stages, as the original's `stage2_boss` and `stage5_boss`;
- `stage1_boss`: stage 1's boss, then the card of stage 2 and the new
  stage, side view, instead of the top-down stage;
- `stage7_ending_easy`: the last stage (stage 7) from its midpoint on EASY,
  the ending, the closing message and the next loop at stage 1 on NORMAL,
  as the original's `stage6_ending_easy`;
- `attract`: the three attract demos (stages 1, 3 and 5 now), as the
  original's;
- the stage select (with the `stage_select` cheat) cycles through 7 stages.

The screens are compared with the original's goldens at every checkpoint
except those on a stage card, whose number differs (the card's number is
checked in VRAM instead).  Run with `make stage-test` (or within
`make emu-test`); skipped when there is no cc65.
"""
import hashlib
import json
import multiprocessing
import os
import shutil
import subprocess
import sys

import pytest

from tools.c3emu import game, plays, retro

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
GOLDENS = os.path.join(HERE, "goldens", "play")
CHECK = 60
SLACK = 2
ATTRACT_FRAMES = 21000

GAME_MODE = 0x0032
STAGE_INDEX = 0x0070       # stage_index
NMI_MODE = 0x0042          # nmi_mode: 2 on the side-view stages, 4 on the top-down ones
OPTION_LEVEL = 0x1E3E
GAME_MODE_STAGE_SELECT = 0x07
GAME_MODE_STAGE_CARD = 0x08
GAME_MODE_STAGE_PLAY = 0x09
CARD_DIGIT_VRAM = 0x5A6D + 6   # text_stage_n: "STAGE n" at BG3 $5A6D, the digit 6 tiles in

EXTRA = dict(topdown=plays.EXTRA_TOPDOWN_STAGES, last=plays.EXTRA_LAST_STAGE)
# variant play -> (Play, golden of the original play it must reproduce)
CASES = {
    "stage2_boss": (plays.Play("x_stage2_boss", 2, 16000, 18, checkpoint=True, **EXTRA), "stage1_boss"),
    "stage3_boss": (plays.Play("x_stage3_boss", 3, 9000, 22, checkpoint=True, **EXTRA), "stage2_boss"),
    "stage6_boss": (plays.Play("x_stage6_boss", 6, 24000, 52, checkpoint=True, **EXTRA), "stage5_boss"),
    "stage1_boss": (plays.Play("x_stage1_boss", 1, 16000, 18, checkpoint=True, **EXTRA), "stage1_boss"),
    "stage7_ending_easy": (plays.Play("x_stage7_ending_easy", 7, 47000, 64, checkpoint=True,
                                      level=2, **EXTRA), "stage6_ending_easy"),
    "attract": (None, "attract"),
}


def build_extra_stage(*more):
    """Builds the extra-stage ROM (with more options) with tools/cheats.py."""
    if not shutil.which("ca65"):
        pytest.skip("no ca65 (cc65) on the PATH")
    opts = ["extra_stage", *more]
    subprocess.run([sys.executable, os.path.join(ROOT, "tools", "cheats.py"), "build", *opts],
                   cwd=ROOT, check=True, stdout=subprocess.DEVNULL)
    return os.path.join(ROOT, "build", "cheats", "-".join(o.replace("=", "").lower() for o in opts),
                        "contra3.sfc")


def _digest(data):
    return hashlib.sha1(data).hexdigest()[:12]


def _card_digit(c):
    vram = c.vram()
    return vram[CARD_DIGIT_VRAM * 2] - 1      # tile n + 1 shows n


def record(rom, core, case):
    """Runs a case on the variant: per checkpoint (every CHECK game frames)
    the screen hashes within SLACK frames, the game mode and stage; the
    number shown on each stage's card; and the states seen."""
    play, _golden = CASES[case]
    c = retro.Console(rom, core=core)
    checks, cards, seen = {}, {}, []
    if play is None:
        def frames():
            counter, n = c.peek16(plays.FRAME_COUNTER), 0
            while n < ATTRACT_FRAMES + SLACK:
                c.run(1)
                now = c.peek16(plays.FRAME_COUNTER)
                if now != counter:
                    counter, n = now, n + 1
                    yield n
        it = frames()
    else:
        it = plays.run(c, play, every=1)
    for frame in it:
        mode, stage = c.peek(GAME_MODE), c.peek(game.STAGE)
        state = (stage, c.peek(STAGE_INDEX), mode, c.peek(NMI_MODE), c.peek(OPTION_LEVEL))
        if not seen or seen[-1][1] != state:
            seen.append((frame, state))
        if mode == GAME_MODE_STAGE_CARD:
            # the last number read on the card (VRAM still holds the
            # previous screen's until the card is drawn)
            cards[stage] = _card_digit(c)
        near = (frame + SLACK) // CHECK * CHECK
        if near and abs(frame - near) <= SLACK:
            e = checks.setdefault(near, {"hashes": [], "card": False})
            e["hashes"].append(_digest(retro.fifteen_bits(c.image())))
            if frame == near:
                e["card"] = mode == GAME_MODE_STAGE_CARD
                e["stage"] = stage
    c.close()
    return {"checks": checks, "cards": sorted(cards.items()), "seen": seen}


def _worker(args):
    rom, core, case = args
    return case, record(rom, core, case)


@pytest.fixture(scope="session")
def extra_rom():
    return build_extra_stage()


@pytest.fixture(scope="session")
def runs(request, extra_rom, core):
    wanted = [item.callspec.params["case"] for item in request.session.items
              if item.originalname == "test_extra_stage_play"]
    if not wanted:
        return {}
    jobs = int(os.environ.get("C3_JOBS", os.cpu_count() or 1))
    ctx = multiprocessing.get_context("spawn")
    with ctx.Pool(max(1, min(jobs, len(wanted)))) as pool:
        return dict(pool.imap_unordered(_worker, [(extra_rom, core, n) for n in wanted]))


def _compare(got, golden, until=None):
    """Checkpoints differing from the golden (stage cards and those from
    `until` on excepted); returns (bad frames, card checkpoints skipped)."""
    want = json.load(open(os.path.join(GOLDENS, golden + ".json")))["screen"]
    bad, cards = [], 0
    for frame, h in want:
        if until is not None and frame >= until:
            break
        e = got["checks"].get(frame)
        if e is None:
            bad.append(frame)
        elif e["card"]:
            cards += 1
        elif h not in e["hashes"]:
            bad.append(frame)
    # a lone differing checkpoint is tolerated as in test_play (a raster
    # split moved by a cycle-timing change); two in a row are not
    lone = [f for f in bad if f - CHECK not in bad and f + CHECK not in bad]
    return [f for f in bad if f not in lone], cards


@pytest.mark.parametrize("case", list(CASES))
def test_extra_stage_play(runs, case):
    got = runs[case]
    _play, golden = CASES[case]
    seen = [s for _f, s in got["seen"]]
    if case == "stage1_boss":
        # the original goes on to the top-down stage 2: compare up to the
        # new stage, then it must be the side-view stage 2
        start2 = next(f for f, s in got["seen"] if s[0] == 2 and s[2] == GAME_MODE_STAGE_PLAY)
        bad, cards = _compare(got, golden, until=start2 - CHECK)
        assert (2, 1, GAME_MODE_STAGE_PLAY, 2) in [s[:4] for s in seen], seen
        assert got["cards"] == [(1, 1), (2, 2)], got["cards"]
    else:
        bad, cards = _compare(got, golden)
    assert all(stage == shown for stage, shown in got["cards"]), got["cards"]
    assert not bad, "%s: differs from the original's %s at game frames %s" % (case, golden, bad[:8])
    if case == "stage2_boss":
        assert got["cards"] == [(2, 2), (3, 3)], got["cards"]
        # stage 3 is the top-down stage (stage_index 2), not the side view
        assert any(s[0] == 3 and s[1] == 2 and s[2] == GAME_MODE_STAGE_PLAY and s[3] == 4
                   for s in seen), seen
        assert cards > 0
    if case == "stage7_ending_easy":
        # the card of stage 7, then (EASY -> NORMAL) the next loop's stage 1
        assert got["cards"] == [(1, 1), (7, 7)], got["cards"]
        assert seen[-1][0] == 1 and seen[-1][4] == 2, seen[-1]
    if case == "attract":
        assert {s[0] for s in seen} >= {1, 3, 5}, seen
        assert not {2, 4, 6, 7} & {s[0] for s in seen if s[2] == 4}, seen


def test_stage_select_seven_stages(core):
    rom = build_extra_stage("stage_select")
    c = retro.Console(rom, core=core)
    try:
        c.run(game.TITLE_READY)
        c.press("start", frames=3, after=400)
        assert c.peek(GAME_MODE) == GAME_MODE_STAGE_SELECT
        assert c.peek(game.STAGE) == 1
        c.press("up", frames=2, after=10)         # 1 wraps to the last stage
        assert c.peek(game.STAGE) == 7
        c.run(4)
        assert _card_digit(c) == 7
        c.press("down", frames=2, after=10)       # and back to 1
        assert c.peek(game.STAGE) == 1
        for n in range(2, 8):
            c.press("down", frames=2, after=10)
            assert c.peek(game.STAGE) == n
            c.run(4)
            assert _card_digit(c) == n
        c.press("up", frames=2, after=10)
        c.press("up", frames=2, after=10)
        c.press("up", frames=2, after=10)
        c.press("up", frames=2, after=10)          # 7 -> 3: the top-down stage
        c.press("start", frames=3, after=600)
        assert c.peek(GAME_MODE) == GAME_MODE_STAGE_PLAY
        assert c.peek(game.STAGE) == 3 and c.peek(STAGE_INDEX) == 2
        assert c.peek(NMI_MODE) == 4               # the top-down frame
    finally:
        c.close()
