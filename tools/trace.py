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
"""
import argparse
import multiprocessing
import os
import random
import sys
import time

from tools.c3emu import cdl as C
from tools.c3emu import game, retro
from tools.c3emu.rom import rom_path

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "cdl", "contra3.cdl")

SIDE_MOVES = [("right",), ("right", "y"), ("right", "y"), ("right", "b"),
              ("right", "b", "y"), ("y",), ("up", "y"), ("down", "y"),
              ("right", "up", "y"), ("down", "b"), ("left", "y"), ("left",),
              ("x",), ("a",), ("l", "y"), ("r", "y"), ("l", "r", "y")]
TOP_MOVES = [("up", "y"), ("up",), ("down", "y"), ("left", "y"), ("right", "y"),
             ("up", "left", "y"), ("up", "right", "y"), ("down", "left", "y"),
             ("down", "right", "y"), ("l",), ("r",), ("l", "y"), ("r", "y"),
             ("x",), ("a",), ("b", "y"), ("y",)]


class Player:
    """Random inputs with a seeded generator, re-chosen every few frames,
    with optional infinite lives (poking the lives counter)."""

    def __init__(self, c, seed, moves=SIDE_MOVES, lives=True, ports=(0,)):
        self.c = c
        self.rng = random.Random(seed)
        self.moves = moves
        self.lives = lives
        self.ports = ports

    def play(self, frames, hold=(4, 40)):
        c = self.c
        left = frames
        while left > 0:
            n = min(left, self.rng.randint(*hold))
            for port in self.ports:
                c.hold(*self.rng.choice(self.moves), port=port)
            if self.lives:
                c.write_ram(game.LIVES_P1, 5)
                c.write_ram(game.LIVES_P2, 5)
            c.run(n)
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


def _stage(stage, seed, frames=30000, moves=None, ports=(0,), menu=0):
    def run(c):
        game.start_game(c, stage=stage, menu_downs=menu)
        c.run(300)
        mv = moves or (TOP_MOVES if stage in (2, 5) else SIDE_MOVES)
        Player(c, seed, mv, lives=True, ports=ports).play(frames)
    run.__doc__ = "Stage %d, random play, infinite lives, ports %s" % (stage, ports)
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
    SCENARIOS["stage%d" % _s] = _stage(_s, 100 + _s)
    SCENARIOS["stage%d_2p" % _s] = _stage(_s, 200 + _s, frames=15000, ports=(0, 1), menu=1)
SCENARIOS["stage1_2pb"] = _stage(1, 301, frames=15000, ports=(0, 1), menu=2)


def run_scenario(name, rom=None):
    t = time.time()
    c = retro.Console(rom or rom_path())
    c.cdl_enable()
    c.cdl_clear()
    SCENARIOS[name](c)
    snap = c.cdl_snapshot()
    frames = c.frame_count
    c.close()
    return name, snap, frames, time.time() - t


def _worker(args):
    name, rom = args
    name, snap, frames, dt = run_scenario(name, rom)
    # Ship the plain fields back (the Cdl object pickles fine, but keep it explicit).
    return name, snap, frames, dt


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
            print("%-12s %s" % (k, (f.__doc__ or "").strip().splitlines()[0]))
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
        for name, snap, frames, dt in pool.imap_unordered(_worker, [(n, rom) for n in names]):
            before = merged.coverage()[0] if merged else None
            merged = snap if merged is None else merged.merge(snap)
            after = merged.coverage()[0]
            gain = "" if before is None else " (+%d code, +%d data bytes)" % (
                after["code"] + after["both"] - before["code"] - before["both"],
                after["data"] + after["both"] - before["data"] - before["both"])
            print("%-12s %7d frames %6.1fs%s" % (name, frames, dt, gain), flush=True)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    merged.save(args.out)
    print(merged.report())
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
