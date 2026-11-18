"""A scripted player for the extra stage (stage 2 of the extra-stage build,
`make cheats CHEATS=extra_stage`; book: Stage 2: Collapsed Tower), for
tests/test_extra_stage.py.

The random moves of plays.py do not get up a vertical stretch: the climb
of the extra stage (BG1 pages 10-13, bg1_scroll_mode 3) needs jumps at
given places.  This player reads the game's state every frame and acts
on it, so it does not depend on the exact timing of the ROM (a shifted
build plays the same way):

- side view, scrolling right (bg1_scroll_mode 1): run right firing,
  jumping now and then; climb a wall it walks into (player states 2, 5:
  hold Up), drop from a bar or a ceiling (states 1, $0D);
- an arena (bg1_scroll_mode 4: the mid-boss, the boss): stay at the left
  and fire right and up, a smart bomb now and then;
- the climb (bg1_scroll_mode 2-3, or while bg1_y is negative before the
  stage scrolls right again): the waypoints of CLIMB, in screen x, one
  per platform: walk to x, jump (straight up through the slab above, or
  towards `dir`), and move on once landed higher; 'pillar': walk right
  into the concrete pillar and hold Up to its top.

With `keep_alive` the player's lives, bombs and barrier are written back
every 30 frames, as plays.py does, so a run does not depend on dying.
"""
from . import game

PLAYER_X = 0x020A
PLAYER_Y = 0x020E
PLAYER_STATE = 0x0212
BG1_X = 0x1380
BG1_Y = 0x1398
BG1_SCROLL_MODE = 0x13BA
GAME_MODE = 0x0032
GAME_MODE_STAGE_PLAY = 0x09

# (kind, screen x, direction): see the module's docstring.  Built for the
# BG1 map's pages 10-13 (assets/wram/extra_bg1_map.map).
CLIMB = [("up", 70, None), ("up", 80, None), ("up", 110, None), ("up", 120, None),
         ("up", 145, None), ("pillar", None, "right"), ("dir", 212, "left"),
         ("dir", 135, "left"), ("up", 80, None), ("dir", 90, "right"),
         ("up", 130, None), ("up", 145, None), ("up", 175, None)]


def _s16(v):
    return v - 0x10000 if v & 0x8000 else v


class Player:
    def __init__(self, c, ports=(0,), keep_alive=True):
        self.c = c
        self.ports = ports
        self.keep_alive = keep_alive
        self.frame = 0
        self.wp = 0
        self.phase = 0
        self.t = 0
        self.y0 = 0

    def _hold(self, *buttons):
        for p in self.ports:
            self.c.hold(*buttons, port=p)

    def step(self):
        """Chooses the input for one frame and runs it."""
        c = self.c
        self.frame += 1
        if self.keep_alive and self.frame % 30 == 0:
            c.write_ram(game.LIVES_P1, 5)
            c.write_ram(game.BOMBS_P1, 2)
            c.write_ram(game.BARRIER_P1, 0x80)
            if len(self.ports) > 1:
                c.write_ram(game.LIVES_P2, 5)
                c.write_ram(game.BOMBS_P2, 2)
                c.write_ram(game.BARRIER_P2, 0x80)
        if c.peek(GAME_MODE) != GAME_MODE_STAGE_PLAY:
            self._hold()
        else:
            mode = c.peek16(BG1_SCROLL_MODE)
            if mode in (2, 3) or (mode == 0 and _s16(c.peek16(BG1_Y)) < 0 and self.wp < len(CLIMB)):
                self._climb()
            elif mode == 4:
                self._arena()
            else:
                self._run()
        c.run(1)

    def _run(self):
        # each player by its own state (player 2's object is $40 after player 1's)
        for port in self.ports:
            state = self.c.peek16(PLAYER_STATE + 0x40 * port)
            if state in (2, 5):
                buttons = ("right", "up")
            elif state in (1, 0x0D):            # hanging: down + a fresh jump drops
                buttons = ("down", "b") if self.frame % 8 < 4 else ("down",)
            elif (self.frame // 25) % 3:
                buttons = ("right", "y")
            else:
                buttons = ("right", "b", "y")
            self.c.hold(*buttons, port=port)

    def _arena(self):
        if self.c.peek16(PLAYER_X) > 70:
            self._hold("left", "y")
        elif self.frame % 600 < 4:
            self._hold("a")
        elif (self.frame // 40) % 2:
            self._hold("right", "y")
        else:
            self._hold("right", "up", "y")

    def _climb(self):
        c = self.c
        if self.wp >= len(CLIMB):
            self._hold("up", "y")
            return
        kind, x, d = CLIMB[self.wp]
        state = c.peek16(PLAYER_STATE)
        px = c.peek16(PLAYER_X)
        wy = _s16(c.peek16(PLAYER_Y)) + _s16(c.peek16(BG1_Y))   # the feet in the map
        more = [d] if d else []
        if self.phase == 0:
            if kind == "pillar":
                if state in (2, 5):
                    self.phase = 2
                    self._hold("up")
                else:
                    self._hold("right")
                return
            if state == 2:              # on a wall at the right: off it
                self._hold("left", "down")
            elif state == 5:
                self._hold("right", "down")
            elif state in (1, 0x0D):    # hanging: drop
                self._hold(*(("down", "b") if self.frame % 8 < 4 else ("down",)))
            elif state != 0:
                self._hold("y")
            elif abs(px - x) > 2:
                self._hold("right" if px < x else "left")
            else:
                self.phase, self.t, self.y0 = 1, 0, wy
                self._hold("b", *more)
        elif self.phase == 1:
            self.t += 1
            self._hold(*((["b"] if self.t < 10 else []) + more))
            if self.t > 20 and state == 0:
                if wy < self.y0 - 20:
                    self.wp += 1
                self.phase = 0
        else:
            if state not in (2, 5):
                if state == 0:
                    self.wp += 1
                    self.phase = 0
            self._hold("up")
