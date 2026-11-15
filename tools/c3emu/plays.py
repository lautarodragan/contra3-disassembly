"""Scripted plays: deterministic runs through the game, for the screenshot
suite (tests/test_play.py) and for tools that compare two ROMs frame by
frame (the disassembly's tools/shift_diag.py).

A play starts from power-on, picks a stage on the title (poking STAGE, and
CHECKPOINT to start at the stage's midpoint, usually just before its boss),
then plays with seeded random input, infinite lives and bombs and the
barrier kept on (so the run does not depend on dying), choosing among
moves like tools/trace.py: run-and-gun on the side-view stages, aiming
everywhere and bombing when the stage stops progressing (a boss), turning
and wandering on the top-down ones.  Everything is deterministic, so two
ROMs that behave the same show the same frames.

    from tools.c3emu import plays, retro
    c = retro.Console(rom)
    for frame in plays.run(c, plays.PLAYS["stage2_boss"], every=300):
        ...                     # called every 300 frames of play
"""
import random

from . import game

SIDE_MOVES = [("right",), ("right", "y"), ("right", "y"), ("right", "b"),
              ("right", "jump", "y"), ("right", "jump", "y"), ("jump", "y"),
              ("up", "jump", "y"), ("right", "up", "jump"), ("left", "jump"),
              ("right", "b", "y"), ("y",), ("up", "y"), ("down", "y"),
              ("right", "up", "y"), ("down", "b"), ("left", "y"), ("left",),
              ("x",), ("a",), ("l", "y"), ("r", "y"), ("l", "r", "y")]
BOSS_MOVES = [("up", "y"), ("right", "up", "y"), ("left", "up", "y"), ("y",),
              ("right", "y"), ("left", "y"), ("jump", "y"), ("jump", "up", "y"),
              ("a",), ("down", "y"), ("right", "jump", "y"), ("left", "jump", "y"),
              ("l", "up", "y"), ("r", "right", "up", "y"), ("x",)]
TOP_MOVES = [("up", "y"), ("up",), ("down", "y"), ("left", "y"), ("right", "y"),
             ("up", "left", "y"), ("up", "right", "y"), ("down", "left", "y"),
             ("down", "right", "y"), ("l",), ("r",), ("l", "y"), ("r", "y"),
             ("x",), ("a",), ("b", "y"), ("y",)]

CHECKPOINT = 0x1E40     # stage_checkpoint: 1 starts the stage at its midpoint


class Play:
    def __init__(self, name, stage, frames, seed, checkpoint=False, menu=0, level=None):
        self.name = name
        self.stage = stage
        self.frames = frames
        self.seed = seed
        self.checkpoint = checkpoint
        self.menu = menu            # title menu entry: 0 1P, 1 2P-A, 2 2P-B
        self.level = level          # None NORMAL, 1 HARD, 2 EASY (Right presses on OPTION/LEVEL)

    def __repr__(self):
        return "Play(%s)" % self.name


PLAYS = {p.name: p for p in [
    Play("stage1", 1, 12000, 11),
    Play("stage1_boss", 1, 15000, 15, checkpoint=True),      # boss, stage 2 card
    Play("stage2", 2, 18000, 21),
    Play("stage2_boss", 2, 9000, 22, checkpoint=True),       # boss map, stage 3 start
    Play("stage3", 3, 18000, 31),
    Play("stage3_boss", 3, 39000, 32, checkpoint=True),      # boss, stage 4 start
    Play("stage4", 4, 15000, 41),
    Play("stage4_boss", 4, 21000, 42, checkpoint=True),      # boss, stage 5 start
    Play("stage5", 5, 18000, 51),
    Play("stage5_boss", 5, 24000, 52, checkpoint=True),      # boss map
    Play("stage6", 6, 15000, 61),
    Play("stage6_boss", 6, 64000, 63, checkpoint=True),      # last bosses, the ending (NORMAL)
    Play("stage1_2p", 1, 8000, 71, menu=1),
    Play("stage2_2p", 2, 12000, 72, menu=1),                 # split screen
    Play("stage5_2pb_hard", 5, 9000, 73, menu=2, level=1),
]}


def _hold(c, move, port, phase):
    btns = [b for b in move if b != "jump"]
    if "jump" in move and phase:
        btns.append("b")            # holding B jumps once: tap it
    c.hold(*btns, port=port)


def run(c, play, every=300):
    """Plays `play` on a fresh Console; yields the number of frames played
    every `every` frames (after the stage is picked)."""
    if play.level is not None:
        game.set_options(c, level_rights=play.level)
    game.start_game(c, stage=play.stage, menu_downs=play.menu)
    if play.checkpoint:
        c.write_ram(CHECKPOINT, 1)
    ports = (0, 1) if play.menu else (0,)
    rng = random.Random(play.seed)
    done, left = 0, 0
    moves = {}
    last_prog, still, chunk = None, 0, 0
    while done < play.frames:
        if done % 1000 == 0:
            # once per 1000 frames: is the stage still progressing?
            prog = (c.peek(game.STAGE), c.peek(game.PROGRESS))
            still = still + 1 if prog == last_prog else 0
            last_prog = prog
        if left == 0:
            stage = c.peek(game.STAGE)
            if stage in (2, 5):
                pool = TOP_MOVES + [("a",)] * (2 if still > 5 else 0)
            else:
                pool = BOSS_MOVES if still > 5 and still % 10 < 7 else SIDE_MOVES
            moves = {port: rng.choice(pool) for port in ports}
            left = rng.randint(4, 40)
            chunk = 0
            c.write_ram(game.LIVES_P1, 5)
            c.write_ram(game.BOMBS_P1, 2)
            c.write_ram(game.BARRIER_P1, 0x80)
            if len(ports) > 1:
                c.write_ram(game.LIVES_P2, 5)
                c.write_ram(game.BOMBS_P2, 2)
                c.write_ram(game.BARRIER_P2, 0x80)
        for port, mv in moves.items():
            _hold(c, mv, port, (chunk // 6) % 2 == 0)
        c.run(1)
        chunk += 1
        left -= 1
        done += 1
        if done % every == 0:
            yield done
    for port in ports:
        c.hold(port=port)
