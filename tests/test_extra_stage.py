"""The extra-stage build (src/game/stages.inc; book: Adding a stage), in the
emulator: `make cheats CHEATS=extra_stage` inserts a side-view stage as
stage 2 (book: Stage 2: Collapsed Tower) and renumbers the original stages
2-6 as 3-7.  The other stages must play exactly as the original, one stage
later (their plays compared with the original's goldens):

- `stage3_boss`, `stage6_boss`: the top-down bosses (stages 3 and 6 now)
  and the next stages, as the original's `stage2_boss` and `stage5_boss`;
- `stage1_boss`: stage 1's boss, then the card of stage 2 and the new
  stage, side view, instead of the top-down stage (compared up to the
  new stage);
- `stage7_ending_easy`: the last stage (stage 7) from its midpoint on EASY,
  the ending, the closing message and the next loop at stage 1 on NORMAL,
  as the original's `stage6_ending_easy`;
- `attract`: the three attract demos (stages 1, 3 and 5 now), as the
  original's;
- the stage select (with the `stage_select` cheat) cycles through 7 stages.

The new stage itself has no golden: it is played by the scripted player of
tools/c3emu/extra_stage.py (which climbs its vertical stretch; lives, bombs
and barrier kept up as in the plays), and the run is checked by its
milestones (ROUTES): from the start, the mid-boss (the tank in slot
$0900), the checkpoint it sets, the climb (bg1_scroll_mode 3, bg1_y up to
-768, the top page), the boss (type $01 in slot $0900) in its arena at
bg1_x $0F00, the stage clear, the card "STAGE 3" and the top-down stage 3;
the same from the checkpoint (a continue: page 8, the boss at bg1_x
$0700); and with two players (2 PLAYERS A).

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

from tools.c3emu import extra_stage, game, plays, retro

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


# The new stage 2, played by tools/c3emu/extra_stage.py: (title menu entry,
# start at the checkpoint, the arena's bg1_x, most frames).  stage2_continue:
# once the mid-boss has set the checkpoint, the player's last life is lost
# (lives and barrier no longer kept up) and the game continued (Start on
# the continue screen): the stage starts again at its checkpoint.
ROUTES = {
    "stage2": (0, False, 0x0F00, 16000),
    "stage2_checkpoint": (0, True, 0x0700, 12000),
    "stage2_2p": (1, False, 0x0F00, 16000),
    "stage2_continue": (0, False, 0x0700, 24000),
}
GAME_MODE_GAME_OVER = 0x0B
BG1_X, BG1_Y, BG1_SCROLL_MODE, BG1_MAP_OFFSET = 0x1380, 0x1398, 0x13BA, 0x13BC
SLOT_0900_TYPE = 0x0900 + plays.OBJ_TYPE
OBJT_STAGE1_BOSS_CONTROLLER, OBJT_MIDBOSS_TANK = 0x01, 0x02


def record_route(rom, core, case):
    """Plays the new stage 2 to the top-down stage 3 with the scripted
    player; returns what was seen along the way."""
    menu, checkpoint, _arena, frames = ROUTES[case]
    c = retro.Console(rom, core=core)
    game.start_game(c, stage=2, menu_downs=menu)
    if checkpoint:
        c.write_ram(plays.CHECKPOINT, 1)
    p = extra_stage.Player(c, ports=(0, 1) if menu else (0,))
    got = {"cards": {}, "slot_0900": set(), "modes": set(), "min_bg1_y": 0, "start_offset": None,
           "arena_x": set(), "checkpoint": 0, "end": None, "frames": 0, "game_over": False,
           "restart_offset": None}
    dying = False
    for n in range(frames):
        if case == "stage2_continue" and c.peek(GAME_MODE) == GAME_MODE_STAGE_PLAY:
            if not dying and got["checkpoint"] and not got["game_over"]:
                dying, p.keep_alive = True, False
                c.write_ram(game.LIVES_P1, 0)
                c.write_ram(game.BARRIER_P1, 0)
            elif dying and got["game_over"] and c.peek16(BG1_SCROLL_MODE) == 1:
                dying, p.keep_alive = False, True
                got["restart_offset"] = c.peek16(BG1_MAP_OFFSET)
                got["arena_x"].clear()
        if dying and c.peek(GAME_MODE) != GAME_MODE_STAGE_PLAY:
            c.hold(*(("start",) if n % 40 < 3 else ()))
            c.run(1)
            got["game_over"] |= c.peek(GAME_MODE) == GAME_MODE_GAME_OVER
            continue
        p.step()
        mode, stage = c.peek(GAME_MODE), c.peek(game.STAGE)
        if mode == GAME_MODE_STAGE_CARD:
            got["cards"][stage] = _card_digit(c)
        if mode != GAME_MODE_STAGE_PLAY:
            continue
        if stage == 2:
            scroll = c.peek16(BG1_SCROLL_MODE)
            if got["start_offset"] is None and scroll == 1:
                got["start_offset"] = c.peek16(BG1_MAP_OFFSET)
            got["modes"].add(scroll)
            y = c.peek16(BG1_Y)
            got["min_bg1_y"] = min(got["min_bg1_y"], y - 0x10000 if y & 0x8000 else y)
            got["slot_0900"].add(c.peek16(SLOT_0900_TYPE))
            if c.peek16(SLOT_0900_TYPE) == OBJT_STAGE1_BOSS_CONTROLLER and scroll == 4:
                got["arena_x"].add(c.peek16(BG1_X))
            got["checkpoint"] = max(got["checkpoint"], c.peek(plays.CHECKPOINT))
        elif stage == 3 and c.peek(NMI_MODE) == 4:     # the top-down frame
            got["end"] = (stage, c.peek(STAGE_INDEX), c.peek(NMI_MODE))
            got["frames"] = n
            break
    if got["end"] is None:
        os.makedirs(os.path.join(ROOT, "out", "extra_stage"), exist_ok=True)
        c.image().save(os.path.join(ROOT, "out", "extra_stage", case + ".png"))
    c.close()
    got["cards"] = sorted(got["cards"].items())
    return got


def _worker(args):
    rom, core, case = args
    if case in ROUTES:
        return case, record_route(rom, core, case)
    return case, record(rom, core, case)


@pytest.fixture(scope="session")
def extra_rom():
    return build_extra_stage()


@pytest.fixture(scope="session")
def runs(request, extra_rom, core):
    wanted = [item.callspec.params["case"] for item in request.session.items
              if item.originalname in ("test_extra_stage_play", "test_extra_stage_route")]
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
    if case == "stage7_ending_easy":
        # the card of stage 7, then (EASY -> NORMAL) the next loop's stage 1
        assert got["cards"] == [(1, 1), (7, 7)], got["cards"]
        assert seen[-1][0] == 1 and seen[-1][4] == 2, seen[-1]
    if case == "attract":
        assert {s[0] for s in seen} >= {1, 3, 5}, seen
        assert not {2, 4, 6, 7} & {s[0] for s in seen if s[2] == 4}, seen


@pytest.mark.parametrize("case", list(ROUTES))
def test_extra_stage_route(runs, case):
    """The new stage 2 from its start (or its checkpoint) to stage 3."""
    got = runs[case]
    _menu, checkpoint, arena, _frames = ROUTES[case]
    checkpoint = checkpoint and case != "stage2_continue"
    # the start: page 0, or page 8 from the checkpoint (bg1_map_offset names
    # the page after the one on screen)
    assert got["start_offset"] == (0x0480 if checkpoint else 0x0080), got
    if not checkpoint:
        assert OBJT_MIDBOSS_TANK in got["slot_0900"], got
    assert got["checkpoint"] == 1, got
    # the climb: vertical scrolling up to the top page, 3 pages up
    assert {2, 3} <= got["modes"] and -0x301 <= got["min_bg1_y"] <= -0x300, got
    # the boss, in its arena (an odd page: stage1_boss_controller_state_00's
    # wall column)
    assert OBJT_STAGE1_BOSS_CONTROLLER in got["slot_0900"], got
    assert got["arena_x"] == {arena}, got
    # the stage clear, the card of stage 3, the top-down stage 3
    assert got["cards"] == [(2, 2), (3, 3)], got
    assert got["end"] == (3, 2, 4), got
    if case == "stage2_continue":
        # game over, the continue, page 8 again
        assert got["game_over"] and got["restart_offset"] == 0x0480, got


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
