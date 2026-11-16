"""Scripted plays: deterministic runs through the game, for the screenshot
suite (tests/test_play.py) and for tools that compare two ROMs frame by
frame (the disassembly's tools/shift_diag.py).

A play starts from power-on, picks a stage on the title (poking STAGE, and
CHECKPOINT to start at the stage's midpoint, usually just before its boss),
then plays with seeded random input, infinite lives and bombs and the
barrier kept on (so the run does not depend on dying), choosing among
moves like tools/trace.py: run-and-gun on the side-view stages, aiming
everywhere and bombing when the stage stops progressing (a boss), turning
and wandering on the top-down ones; Start only where the game waits for
it (waits_for_start: the closing message after stage 6 on EASY and NORMAL,
FINAL SCORE), so the ending plays go on into the next loop or back to the
opening.  Everything is deterministic, so two ROMs that behave the same
show the same frames.

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
FRAME_COUNTER = 0x003A  # frame_counter: +1 per frame the game's logic runs
GAME_MODE = 0x0032      # game_mode
MODE_STEP = 0x1C00      # mode_step (run_final_score: 2 waits for Start)
GAME_MODE_STAGE_PLAY = 0x09
GAME_MODE_FINAL_SCORE = 0x0E
OBJ_SLOTS, OBJ_SIZE, OBJ_SLOT_COUNT = 0x0200, 0x40, 35  # slots 0, 1: the players
OBJ_TYPE, OBJ_STATE, OBJ_TIMER = 0x10, 0x12, 0x24
OBJT_ENDING_SEQUENCE = 0x95
ENDING_PUSH_START = 0x29  # ending_sequence_state_29: PUSH START KEY (EASY, NORMAL)
START_AFTER = 300       # game frames a Start-only screen stays before the play presses Start


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
    Play("stage1_boss", 1, 16000, 18, checkpoint=True),      # boss, stage 2 card
    Play("stage2", 2, 18000, 21),
    Play("stage2_boss", 2, 9000, 22, checkpoint=True),       # boss map, stage 3 start
    Play("stage3", 3, 18000, 31),
    Play("stage3_boss", 3, 39000, 34, checkpoint=True),      # boss, stage 4 start
    Play("stage4", 4, 15000, 41),
    Play("stage4_boss", 4, 21000, 44, checkpoint=True),      # boss, stage 5 start
    Play("stage5", 5, 18000, 51),
    Play("stage5_boss", 5, 24000, 52, checkpoint=True),      # boss map
    Play("stage6", 6, 15000, 61),
    Play("stage6_boss", 6, 51000, 65, checkpoint=True),      # last bosses, the ending (NORMAL), stage 1 on HARD
    Play("stage1_2p", 1, 8000, 71, menu=1),
    Play("stage2_2p", 2, 12000, 72, menu=1),                 # split screen
    Play("stage5_2pb_hard", 5, 9000, 73, menu=2, level=1),
    Play("stage6_ending_easy", 6, 47000, 64, checkpoint=True, level=2),   # the ending (EASY), stage 1 on NORMAL
    Play("stage6_ending_hard", 6, 78000, 67, checkpoint=True, level=1),   # the ending (HARD), FINAL SCORE, the opening
]}


def waits_for_start(c):
    """True on the two screens that only Start leaves: the closing
    message's PUSH START KEY after stage 6 on EASY and NORMAL
    (ending_sequence_state_29, once its timer has run out) and FINAL SCORE
    (run_final_score, step 2).  The random moves never press Start (it
    pauses), so the plays press it there (after START_AFTER game frames)."""
    mode = c.peek(GAME_MODE)
    if mode == GAME_MODE_FINAL_SCORE:
        return c.peek(MODE_STEP) == 2
    if mode != GAME_MODE_STAGE_PLAY or c.peek(game.STAGE) != 6:
        return False
    objs = c.ram(OBJ_SLOTS, OBJ_SLOT_COUNT * OBJ_SIZE)
    word = lambda a: objs[a] | objs[a + 1] << 8
    for obj in range(2 * OBJ_SIZE, len(objs), OBJ_SIZE):
        if word(obj + OBJ_TYPE) == OBJT_ENDING_SEQUENCE:
            return word(obj + OBJ_STATE) == ENDING_PUSH_START and word(obj + OBJ_TIMER) & 0x8000 != 0
    return False


def _hold(c, move, port, phase):
    btns = [b for b in move if b != "jump"]
    if "jump" in move and phase:
        btns.append("b")            # holding B jumps once: tap it
    c.hold(*btns, port=port)


def run(c, play, every=300):
    """Plays `play` on a fresh Console; yields the number of game frames
    played every `every` of them (after the stage is picked).  A play lasts
    play.frames game frames.

    The input script advances with the game's own frames (frame_counter,
    incremented by run_game_mode), not with the emulated ones: when the
    game lags (its frame logic overruns and the next NMI is skipped), the
    held buttons stay for the next game frame.  So the game sees the same
    inputs whether or not a frame lags, and a ROM whose CPU timing differs
    by some cycles (another layout) plays the same game."""
    if play.level is not None:
        game.set_options(c, level_rights=play.level)
    game.start_game(c, stage=play.stage, menu_downs=play.menu)
    if play.checkpoint:
        c.write_ram(CHECKPOINT, 1)
    ports = (0, 1) if play.menu else (0,)
    rng = random.Random(play.seed)
    done, left, played = 0, 0, 0
    moves = {}
    last_prog, still, chunk, waiting = None, 0, 0, 0
    counter = c.peek16(FRAME_COUNTER)
    while played < play.frames:
        if waiting > START_AFTER:
            moves = {ports[0]: ("start",)}
            left, chunk, waiting = 8, 0, 0
        elif left == 0:
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
        done += 1
        now = c.peek16(FRAME_COUNTER)
        if now != counter:
            counter = now
            played += 1
            chunk += 1
            left -= 1
            waiting = waiting + 1 if waits_for_start(c) else 0
            if played % 1000 == 0:
                # once per 1000 game frames: is the stage still progressing?
                prog = (c.peek(game.STAGE), c.peek(game.PROGRESS))
                still = still + 1 if prog == last_prog else 0
                last_prog = prog
            if played % every == 0:
                yield played
    for port in ports:
        c.hold(port=port)
