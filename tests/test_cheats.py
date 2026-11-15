"""Build-time cheats of the disassembly (milestone 4), checked in the emulator.

Each test builds a cheat ROM from the disassembly checkout with its
tools/cheats.py (options as in `make cheats CHEATS="..."`) and checks the
effect through RAM reads, usually against the original ROM doing the same.

    python3 -m pytest tests/test_cheats.py                  # disassembly at ../contra3-disassembly
    C3_DISASM=path/to/contra3-disassembly python3 -m pytest tests/test_cheats.py
    make cheat-test PRIVATE=...                             # from the disassembly

Skipped when there is no disassembly with tools/cheats.py, or no cc65.
"""
import collections
import os
import random
import shutil
import subprocess
import sys

import pytest

from tools.c3emu import game, retro

HERE = os.path.dirname(os.path.abspath(__file__))
DISASM = os.environ.get("C3_DISASM") or os.path.join(
    os.path.dirname(os.path.dirname(HERE)), "contra3-disassembly")

# RAM ($7E:xxxx)
P1_STATE = 0x0212          # player 1 OBJ_STATE
P1_Y = 0x020E              # player 1 OBJ_Y
P1_WEAPON_1 = 0x1F84       # slot I: fires at the start (PLAYER_WEAPON_SLOT = 2)
P1_WEAPON_2 = 0x1F86       # slot II (X swaps)
P1_BOMB_RADIUS = 0x1510    # PLAYER_BOMB_RADIUS of player 1: non-zero while a bomb blasts
GAME_MODE = 0x0032
CONTINUES = 0x1E62         # continues_left
OPTION_LIVES = 0x1E3C
STAGE_SELECT = 0x1E60      # stage_select_enabled
TD_P1_STATE = 0x0ED2       # top-down player 1 +$12
PLAYER_STATE_DYING = 0x07
PLAYER_STATE_OUT = 0x0E
TD_STATE_DYING = 8
GAME_MODE_STAGE_SELECT = 7
GAME_MODE_STAGE_PLAY = 9
GAME_MODE_GAME_OVER = 0x0B
GAME_MODE_CONTINUE = 0x0C


@pytest.fixture(scope="session")
def build():
    """build(*options) -> path of the cheat ROM (built once per option set)."""
    tool = os.path.join(DISASM, "tools", "cheats.py")
    if not os.path.exists(tool):
        pytest.skip("no disassembly with tools/cheats.py at %s (set C3_DISASM)" % DISASM)
    if not shutil.which("ca65"):
        pytest.skip("no ca65 (cc65) on the PATH")
    cache = {}

    def _build(*options):
        if options not in cache:
            name = "-".join(o.replace("=", "").lower() for o in options)
            subprocess.run([sys.executable, tool, "build", *options], cwd=DISASM,
                           check=True, stdout=subprocess.DEVNULL)
            cache[options] = os.path.join(DISASM, "build", "contra3-%s.sfc" % name)
        return cache[options]
    return _build


class Run:
    """A console started on a stage (the title's 1 PLAYER, stage poked)."""

    def __init__(self, rom, core, stage=1, settle=300, checkpoint=False):
        self.c = retro.Console(rom, core=core)
        game.start_game(self.c, stage=stage)
        if checkpoint:
            self.c.write_ram(0x1E40, 1)
        self.c.run(settle)

    def __enter__(self):
        return self.c

    def __exit__(self, *exc):
        self.c.close()


def side_walk(c, frames, fire=True, seed=1, watch=P1_STATE, dying=PLAYER_STATE_DYING):
    """Walk right (jumping now and then, firing), counting deaths (entries
    into the dying state); returns (deaths, lowest lives seen)."""
    rnd = random.Random(seed)
    deaths, prev, low = 0, None, c.peek(game.LIVES_P1)
    for i in range(frames):
        if i % 30 == 0:
            c.hold("right", *(["y"] if fire else []), *(["b"] if rnd.random() < 0.3 else []))
        c.run(1)
        st = c.peek(watch)
        if st == dying and prev != dying:
            deaths += 1
        prev = st
        low = min(low, c.peek(game.LIVES_P1))
    c.hold()
    return deaths, low


def topdown_walk(c, frames, seed=2):
    """Random walking and firing on a top-down stage; returns (deaths, lowest lives)."""
    rnd = random.Random(seed)
    deaths, prev, low = 0, None, c.peek(game.LIVES_P1)
    for i in range(frames):
        if i % 20 == 0:
            c.hold(rnd.choice(["up", "up", "down", "left", "right"]), "y",
                   *([rnd.choice(["l", "r"])] if rnd.random() < 0.3 else []))
        c.run(1)
        st = c.peek(TD_P1_STATE)
        if st == TD_STATE_DYING and prev != TD_STATE_DYING:
            deaths += 1
        prev = st
        low = min(low, c.peek(game.LIVES_P1))
    c.hold()
    return deaths, low


# --- lives and death ---------------------------------------------------------

def test_original_dies(rom, core):
    """The scenarios below do kill the player in the original game."""
    with Run(rom, core, stage=1) as c:
        deaths, low = side_walk(c, 3000)
    assert deaths >= 1 and low < 3
    with Run(rom, core, stage=2, settle=600) as c:
        deaths, low = topdown_walk(c, 4000)
    assert deaths >= 1 and low < 3


def test_infinite_lives(build, core):
    rom = build("infinite_lives")
    with Run(rom, core, stage=1) as c:
        deaths, low = side_walk(c, 4000)
        assert deaths >= 2
        assert low == 3 and c.peek(game.LIVES_P1) >= 3
    with Run(rom, core, stage=2, settle=600) as c:
        deaths, low = topdown_walk(c, 6000)
        assert deaths >= 2
        assert low == 3


def test_invincible(build, core):
    rom = build("invincible")
    with Run(rom, core, stage=1) as c:
        deaths, low = side_walk(c, 4000)
        assert deaths == 0 and low == 3
        assert c.peek(game.PROGRESS) > 0          # the stage went on
    with Run(rom, core, stage=2, settle=600) as c:
        deaths, low = topdown_walk(c, 6000)
        assert deaths == 0


def test_no_pit_death(rom, build, core):
    """Player 1 put below the screen: dies in the original, respawns
    (PLAYER_STATE_OUT, no life taken, weapon kept) with the cheat."""
    def drop(path):
        with Run(path, core, stage=1, settle=600) as c:
            c.write_ram(P1_WEAPON_1, [5, 0])          # laser in the active slot
            c.write_ram(P1_Y, [0x10, 0x01])           # y = $0110
            states = set()
            for _ in range(200):
                c.run(1)
                states.add(c.peek(P1_STATE))
            return states, c.peek(game.LIVES_P1), c.peek(P1_WEAPON_1)
    states, lives, weapon = drop(rom)
    assert PLAYER_STATE_DYING in states and lives == 2
    states, lives, weapon = drop(build("no_pit_death"))
    assert PLAYER_STATE_DYING not in states and PLAYER_STATE_OUT in states
    assert lives == 3 and weapon == 5


def test_keep_weapons(rom, build, core):
    def weapon_after_death(path):
        with Run(path, core, stage=1) as c:
            c.write_ram(P1_WEAPON_1, [5, 0])          # laser in the active slot
            deaths, _ = side_walk(c, 3000, fire=False)
            assert deaths >= 1
            return c.peek(P1_WEAPON_1)
    assert weapon_after_death(rom) == 0
    assert weapon_after_death(build("keep_weapons")) == 5


def test_start_values(build, core):
    """start_weapon, start_weapon2, start_lives, start_stage, continues."""
    rom = build("start_weapon=5", "start_weapon2=1", "start_lives=30",
                "start_stage=3", "continues=7")
    c = retro.Console(rom, core=core)
    try:
        c.run(game.TITLE_READY)
        c.press("start", frames=3, after=800)
        assert c.peek(GAME_MODE) == GAME_MODE_STAGE_PLAY
        assert c.peek(game.STAGE) == 3
        assert c.peek(game.LIVES_P1) == 30
        assert c.peek(P1_WEAPON_1) == 5 and c.peek(P1_WEAPON_2) == 1
        assert c.peek(CONTINUES) == 7
    finally:
        c.close()


def test_infinite_continues(rom, build, core):
    """A game over with 1 life: the original spends a continue (4 -> 3)."""
    def continues_after_game_over(path):
        with Run(path, core, stage=1) as c:
            c.write_ram(game.LIVES_P1, 1)
            for _ in range(40):
                side_walk(c, 300, fire=False)
                if c.peek(GAME_MODE) in (GAME_MODE_GAME_OVER, GAME_MODE_CONTINUE):
                    break
            assert c.peek(GAME_MODE) in (GAME_MODE_GAME_OVER, GAME_MODE_CONTINUE)
            c.run(200)
            return c.peek(CONTINUES)
    assert continues_after_game_over(rom) == 3
    assert continues_after_game_over(build("infinite_continues")) == 4


# --- weapons and damage ----------------------------------------------------------

def test_infinite_bombs(rom, build, core):
    def bombs_after_throw(path):
        with Run(path, core, stage=1, settle=500) as c:
            assert c.peek(game.BOMBS_P1) == 1
            c.press("a", frames=2)
            c.run(2)
            assert c.peek(P1_BOMB_RADIUS) != 0         # a bomb was thrown
            c.run(200)
            return c.peek(game.BOMBS_P1)
    assert bombs_after_throw(rom) == 0
    assert bombs_after_throw(build("infinite_bombs")) == 1


def shots_spawned(path, core, frames=300):
    with Run(path, core, stage=1, settle=500) as c:
        c.hold("y")
        spawned, prev = 0, set()
        for _ in range(frames):
            c.run(1)
            ram = c.ram(0x0AC0, 40 * 0x20)
            now = {s for s in range(40) if ram[s * 0x20 + 0x10] or ram[s * 0x20 + 0x11]}
            spawned += len(now - prev)
            prev = now
        return spawned


def test_fire_delay(rom, build, core):
    assert shots_spawned(build("fire_delay=1"), core) > shots_spawned(rom, core) * 1.2


def hp_decrements(c, frames, base, count):
    """How much objects' +$06 (HP) went down per frame while firing to the
    right, as a Counter: slots of $40 from `base`."""
    rnd = random.Random(3)
    seen = collections.Counter()

    def snap():
        r = c.ram(base, count * 0x40)
        return [(r[s * 0x40 + 0x10], int.from_bytes(r[s * 0x40 + 6:s * 0x40 + 8], "little", signed=True))
                for s in range(count)]
    prev = snap()
    for i in range(frames):
        if i % 30 == 0:
            c.hold("right", "y", *(["b"] if rnd.random() < 0.3 else []))
        c.write_ram(game.LIVES_P1, 5)
        c.run(1)
        cur = snap()
        for (t, hp), (pt, php) in zip(cur, prev):
            if t and t == pt and 0 < php - hp < 64:
                seen[php - hp] += 1
        prev = cur
    return seen


def test_damage_mult(rom, build, core):
    with Run(rom, core, stage=1) as c:
        orig = hp_decrements(c, 3000, 0x0300, 31)
    with Run(build("damage_mult=2"), core, stage=1) as c:
        cheat = hp_decrements(c, 3000, 0x0300, 31)
    assert orig.most_common(1)[0][0] == 2          # default gun: 2 per hit
    assert cheat.most_common(1)[0][0] == 4
    assert cheat[2] < cheat[4] // 4


# --- enemies --------------------------------------------------------------------

def max_hp_by_type(path, core, stage=1, frames=4000):
    """Highest HP seen per object type while walking right without firing
    (invincible, so the walk goes on): the HP each type starts with."""
    with Run(path, core, stage=stage) as c:
        best = {}
        for i in range(frames):
            if i % 40 == 0:
                c.hold("right", *(["b"] if i % 80 == 0 else []))
            c.run(1)
            r = c.ram(0x0300, 31 * 0x40)
            for s in range(31):
                t = r[s * 0x40 + 0x10]
                hp = r[s * 0x40 + 6] | r[s * 0x40 + 7] << 8
                if t and hp < 0x8000:
                    best[t] = max(best.get(t, 0), hp)
        return best


@pytest.mark.parametrize("percent", [50, 0])
def test_enemy_hp(build, core, percent):
    orig = max_hp_by_type(build("invincible"), core)
    cheat = max_hp_by_type(build("invincible", "enemy_hp=%d" % percent), core)
    checked = 0
    for t, hp in orig.items():
        if t not in cheat or hp < 2 or hp in (0x0FFF, 0x7FFF) or t == 0x1D:
            continue                                # $1D: a fire effect, not an enemy
        assert cheat[t] == hp * percent // 100, "type $%02X: %d -> %d" % (t, hp, cheat[t])
        checked += 1
    assert checked >= 3


# --- game ------------------------------------------------------------------------

def test_stage_select(build, core):
    c = retro.Console(build("stage_select"), core=core)
    try:
        c.run(game.TITLE_READY)
        c.press("start", frames=3, after=400)
        assert c.peek(GAME_MODE) == GAME_MODE_STAGE_SELECT
        c.press("down", frames=2, after=10)
        c.press("down", frames=2, after=10)
        assert c.peek(game.STAGE) == 3
        c.press("start", frames=3, after=600)
        assert c.peek(GAME_MODE) == GAME_MODE_STAGE_PLAY
        assert c.peek(game.STAGE) == 3 and c.peek(0x0070) == 2
    finally:
        c.close()


@pytest.mark.parametrize("direction,effect", [("right", "30 lives"), ("left", "stage select")])
def test_button_codes(rom, build, core, direction, effect):
    def enter(path):
        c = retro.Console(path, core=core)
        try:
            c.run(game.TITLE_READY)
            c.hold("down"); c.run(3)
            c.hold("down", direction); c.run(3)
            c.hold(direction); c.run(3)
            c.hold(); c.run(1)
            c.press("start", frames=3, after=400)
            return c.peek(OPTION_LIVES), c.peek(STAGE_SELECT), c.peek(GAME_MODE)
        finally:
            c.close()
    assert enter(rom) == (3, 0, GAME_MODE_STAGE_PLAY)
    lives, select, mode = enter(build("button_codes"))
    if effect == "30 lives":
        assert (lives, select, mode) == (30, 0, GAME_MODE_STAGE_PLAY)
    else:
        assert (lives, select, mode) == (3, 1, GAME_MODE_STAGE_SELECT)


def test_debug_keys(build, core):
    rom = build("debug_keys")
    with Run(rom, core, stage=1, settle=500) as c:      # side view: Select + X
        c.hold("select", "x")
        c.run(4)
        c.hold()
        c.run(2)
        assert c.peek16(game.LIVES_P1) == 0x8000
        assert c.peek16(game.BARRIER_P1) > 0x7000
    with Run(rom, core, stage=2, settle=600) as c:      # top-down: X held, Y pressed
        c.hold("up", "y")                               # until the player is in play
        for _ in range(200):
            c.run(5)
            if c.peek(TD_P1_STATE):
                break
        assert c.peek(TD_P1_STATE) and c.peek16(game.BARRIER_P1) == 0
        c.hold("x")
        c.run(4)
        c.hold("x", "y")
        c.run(2)
        c.hold()
        c.run(2)
        assert c.peek16(game.BARRIER_P1) > 0xFF00      # $FFFF, counting down


def test_option_30_lives(rom, build, core):
    """OPTION, PLAYER: Right three times goes 3, 5, 7, 30 with the cheat
    (back to 3 in the original)."""
    def lives_after_options(path):
        c = retro.Console(path, core=core)
        try:
            game.set_options(c, level_rights=0, lives_rights=3)
            c.press("start", frames=3, after=800)
            assert c.peek(GAME_MODE) == GAME_MODE_STAGE_PLAY
            return c.peek(OPTION_LIVES), c.peek(game.LIVES_P1)
        finally:
            c.close()
    assert lives_after_options(rom) == (3, 3)
    assert lives_after_options(build("option_30_lives")) == (30, 30)
