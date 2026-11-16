"""Coverage tracer: plays Contra III many ways with the CDL on, merges the
logs and writes cdl/contra3.cdl (+ .json sidecar).

    python3 -m tools.trace                    # all scenarios, merged into cdl/
    python3 -m tools.trace --list
    python3 -m tools.trace attract stage3 -j 4
    python3 -m tools.trace --fresh            # don't merge with the existing CDL

Each scenario runs in its own process (cores are process-wide singletons),
starts from power-on, and returns its own CDL; the results are OR-merged into
the committed one, so coverage only ever grows. Everything is deterministic:
random inputs come from a seeded generator.

Besides its own scenarios, the tracer runs every scripted play of
tools/c3emu/plays.py (the screenshot suite's) as a scenario named
play_<name> (play_stage6_boss, play_stage6_ending_easy,
play_stage6_ending_hard, ...), through plays.run with the CDL on.  The plays reach what the random scenarios do
not: they start at the stages' checkpoints and press Start where the game
waits for it, so they go through the closing message's PUSH START KEY and
FINAL SCORE into the next loop (EASY, NORMAL) or the opening (HARD).
"""
import argparse
import multiprocessing
import os
import random
import sys
import time

from tools.c3emu import cdl as C
from tools.c3emu import game, plays, retro
from tools.c3emu.rom import rom_path

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "cdl", "contra3.cdl")
# Debugging: a directory where stage scenarios drop a screenshot every 4000 frames.
SHOTS = os.environ.get("C3_TRACE_SHOTS")

SIDE_MOVES = [("right",), ("right", "y"), ("right", "y"), ("right", "b"),
              ("right", "jump", "y"), ("right", "jump", "y"), ("jump", "y"),
              ("up", "jump", "y"), ("right", "up", "jump"), ("left", "jump"),
              ("right", "b", "y"), ("y",), ("up", "y"), ("down", "y"),
              ("right", "up", "y"), ("down", "b"), ("left", "y"), ("left",),
              ("x",), ("a",), ("l", "y"), ("r", "y"), ("l", "r", "y")]
# Used when the stage stops progressing (usually a boss): aim everywhere, bomb.
BOSS_MOVES = [("up", "y"), ("right", "up", "y"), ("left", "up", "y"), ("y",),
              ("right", "y"), ("left", "y"), ("jump", "y"), ("jump", "up", "y"),
              ("a",), ("down", "y"), ("right", "jump", "y"), ("left", "jump", "y"),
              ("l", "up", "y"), ("r", "right", "up", "y"), ("x",)]
TOP_MOVES = [("up", "y"), ("up",), ("down", "y"), ("left", "y"), ("right", "y"),
             ("up", "left", "y"), ("up", "right", "y"), ("down", "left", "y"),
             ("down", "right", "y"), ("l",), ("r",), ("l", "y"), ("r", "y"),
             ("x",), ("a",), ("b", "y"), ("y",)]


class Player:
    """Random inputs with a seeded generator, re-chosen every few frames,
    with optional infinite lives (poking the lives counter)."""

    def __init__(self, c, seed, moves=SIDE_MOVES, lives=True, ports=(0,), barrier=False):
        self.c = c
        self.barrier = barrier
        self.rng = random.Random(seed)
        self.moves = moves
        self.lives = lives
        self.ports = ports

    def play(self, frames, hold=(4, 40)):
        """Random moves for `frames` frames. A move containing "jump" holds
        its other buttons and taps B every 6 frames (holding B jumps once)."""
        c = self.c
        left = frames
        while left > 0:
            n = min(left, self.rng.randint(*hold))
            chosen = {port: self.rng.choice(self.moves) for port in self.ports}
            if self.lives:
                # Only for players in the game: poking player 2's lives in a
                # 1P game spawns a second soldier that blocks scrolling.
                c.write_ram(game.LIVES_P1, 5)
                c.write_ram(game.BOMBS_P1, 2)
                if len(self.ports) > 1:
                    c.write_ram(game.LIVES_P2, 5)
                    c.write_ram(game.BOMBS_P2, 2)
            if self.barrier:
                c.write_ram(game.BARRIER_P1, 0x80)
                if len(self.ports) > 1:
                    c.write_ram(game.BARRIER_P2, 0x80)
            done = 0
            while done < n:
                step = min(6, n - done)
                phase = (done // 6) % 2 == 0
                for port, mv in chosen.items():
                    btns = [b for b in mv if b != "jump"]
                    if "jump" in mv and phase:
                        btns.append("b")
                    c.hold(*btns, port=port)
                c.run(step)
                done += step
            left -= n
        for port in self.ports:
            c.hold(port=port)


# --- scenarios ---------------------------------------------------------------
# Each takes a Console with the CDL on. Names are what the command line takes.

def sc_attract(c):
    """Power-on, no input: logos, intro, title, three demo stages, twice."""
    c.run(42000)


def sc_title_menu(c):
    """Title menu: cursor moves, OPTION screen and its entries."""
    c.run(game.TITLE_READY)
    rng = random.Random(7)
    for _ in range(4):
        c.press("down", frames=2, after=10)
    for _ in range(4):
        c.press("up", frames=2, after=10)
    for _ in range(3):
        c.press("down", frames=2, after=10)
    c.press("start", frames=3, after=120)
    # Wander around the option screen pressing everything.
    for _ in range(400):
        c.press(*rng.choice([("up",), ("down",), ("left",), ("right",), ("a",),
                             ("b",), ("y",), ("x",), ("l",), ("r",), ("select",)]),
                frames=2, after=rng.randint(4, 20))
    c.press("start", frames=3, after=300)
    c.run(3000)


def _stage(stage, seed, frames=120000, moves=None, ports=(0,), menu=0, barrier=False,
           level=None):
    """level: None keeps NORMAL; else Right presses on OPTION/LEVEL (1 HARD, 2 EASY)."""
    def run(c):
        if level is not None:
            game.set_options(c, level_rights=level)
        game.start_game(c, stage=stage, menu_downs=menu)
        c.run(300)
        p = Player(c, seed, lives=True, ports=ports, barrier=barrier)
        left = frames
        seen = []
        last_prog, still = None, 0
        while left > 0:
            cur = c.peek(game.STAGE)
            if not seen or seen[-1] != cur:
                seen.append(cur)
            prog = c.peek(game.PROGRESS)
            if prog != last_prog or cur != seen[-1]:
                last_prog, still = prog, 0
            else:
                still += 1
            if moves:
                p.moves = moves
            elif cur in (2, 5):
                p.moves = TOP_MOVES + [("a",)] * (2 if still > 5 else 0)
            else:
                p.moves = BOSS_MOVES if still > 5 and still % 10 < 7 else SIDE_MOVES
            p.play(min(left, 1000))
            left -= 1000
            if SHOTS and (frames - left) % 4000 == 0:
                c.image().save(os.path.join(SHOTS, "%s-%07d-s%d-p%d.png" % (
                    run.__name__, c.frame_count, cur, prog)))
        return "stages seen %s" % seen
    run.__name__ = "stage%d" % stage
    run.__doc__ = "Stage %d onwards, %d frames random play, infinite lives, ports %s%s" % (
        stage, frames, ports, {None: "", 1: ", HARD", 2: ", EASY"}[level])
    return run


def sc_gameover(c):
    """Stage 1 without cheats until game over, continue, die again, END."""
    game.start_game(c)
    c.run(300)
    p = Player(c, 11, lives=False)
    for _ in range(2):
        for _ in range(200):
            p.play(300)
            if c.peek(game.LIVES_P1) == 0 and c.peek(0x0212) == 0x0E:
                break
        c.run(600)
        c.press("start", frames=3, after=600)     # CONTINUE
        p.play(3000)
    for _ in range(200):
        p.play(300)
    c.run(600)
    c.press("down", frames=3, after=20)
    c.press("start", frames=3, after=1200)        # END
    c.run(4000)


def sc_pause(c):
    """Pause/unpause in a stage."""
    game.start_game(c)
    c.run(400)
    p = Player(c, 21)
    for _ in range(30):
        p.play(120)
        c.press("start", frames=3, after=60)
        c.press("select", frames=3, after=30)
        c.press("start", frames=3, after=20)


SCENARIOS = {"attract": sc_attract, "title_menu": sc_title_menu,
             "gameover": sc_gameover, "pause": sc_pause}
for _s in range(1, 7):
    # Top-down stages need long wandering to find their targets.
    SCENARIOS["stage%d" % _s] = _stage(_s, 100 + _s, frames=400000 if _s in (2, 5) else 120000)
    SCENARIOS["stage%d_hard" % _s] = _stage(_s, 400 + _s, frames=200000 if _s == 6 else 60000, level=1)
    SCENARIOS["stage%d_easy" % _s] = _stage(_s, 500 + _s, frames=30000, level=2)
    SCENARIOS["stage%d_2p" % _s] = _stage(_s, 200 + _s, frames=20000, ports=(0, 1), menu=1)
SCENARIOS["stage1_2pb"] = _stage(1, 301, frames=20000, ports=(0, 1), menu=2)
SCENARIOS["stage3_2pb"] = _stage(3, 303, frames=20000, ports=(0, 1), menu=2)


def _play(play):
    def run(c):
        for _ in plays.run(c, play, every=1000):
            pass
        return "stage %d at the end" % c.peek(game.STAGE)
    run.__name__ = "play_" + play.name
    run.__doc__ = "Scripted play %s (tools/c3emu/plays.py), %d game frames" % (
        play.name, play.frames)
    return run


for _p in plays.PLAYS.values():
    SCENARIOS["play_" + _p.name] = _play(_p)


def run_scenario(name, rom=None):
    t = time.time()
    c = retro.Console(rom or rom_path())
    c.cdl_enable()
    c.cdl_clear()
    info = SCENARIOS[name](c) or ""
    snap = c.cdl_snapshot()
    frames = c.frame_count
    c.close()
    return name, snap, frames, time.time() - t, info


def _worker(args):
    name, rom = args
    return run_scenario(name, rom)


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("scenarios", nargs="*")
    ap.add_argument("--list", action="store_true")
    ap.add_argument("--fresh", action="store_true", help="ignore the existing CDL")
    ap.add_argument("--out", default=OUT)
    ap.add_argument("--rom", default=None)
    ap.add_argument("-j", "--jobs", type=int, default=os.cpu_count())
    args = ap.parse_args(argv)
    if args.list:
        for k, f in SCENARIOS.items():
            print("%-24s %s" % (k, (f.__doc__ or "").strip().splitlines()[0]))
        return 0
    names = args.scenarios or list(SCENARIOS)
    for n in names:
        if n not in SCENARIOS:
            raise SystemExit("unknown scenario %s (see --list)" % n)
    rom = rom_path(args.rom)
    merged = None
    if not args.fresh and os.path.exists(args.out):
        merged = C.Cdl.load(args.out)
    with multiprocessing.get_context("spawn").Pool(max(1, args.jobs)) as pool:
        for name, snap, frames, dt, info in pool.imap_unordered(_worker, [(n, rom) for n in names]):
            before = merged.coverage()[0] if merged else None
            merged = snap if merged is None else merged.merge(snap)
            after = merged.coverage()[0]
            gain = "" if before is None else " (+%d code, +%d data bytes)" % (
                after["code"] + after["both"] - before["code"] - before["both"],
                after["data"] + after["both"] - before["data"] - before["both"])
            print("%-24s %7d frames %6.1fs%s %s" % (name, frames, dt, gain, info), flush=True)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    merged.save(args.out)
    print(merged.report())
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
