"""What we know about Contra III (USA) at runtime, and helpers to drive it.

RAM addresses are WRAM offsets ($7E:xxxx; < $2000 is also the low mirror
visible from every bank). Found empirically with the harness; see README.

Frame numbers are counted from power-on with the snes9x core and are
deterministic (no input before them).
"""
from .retro import Console
from .rom import rom_path

# --- RAM -----------------------------------------------------------------
STAGE = 0x0086         # current stage, 1-6. Writing it right after Start is
                       # pressed on the title screen selects the stage.
DEMO_STAGE = 0x0070    # 0-based stage of the attract-mode demo (0, 1, 3 seen)
LIVES_P1 = 0x1F8A      # "REST" on the stage card; DEC $1D8A,X (X=$200) at $01:9B91
LIVES_P2 = 0x1FCA      # player 2 (player blocks are $40 apart)
BOMBS_P1 = 0x1F8C      # smart bombs (A button by default); player 2 at $1FCC
BOMBS_P2 = 0x1FCC
WEAPON_SLOT_P1 = 0x1F80  # 0/2: which of the two weapon slots is active (X swaps)
PROGRESS = 0x13BD      # stage section counter, grows as the stage advances
BARRIER_P1 = 0x1F88    # barrier (invincibility power-up) timer; poking $80
BARRIER_P2 = 0x1FC8    # every few frames keeps the player invincible
TITLE_CURSOR = 0x1E02  # title menu cursor: 0 1P, 1 2P-A, 2 2P-B, 3 OPTION
LEVEL = 0x0084         # in game: difficulty x2 (0 EASY, 2 NORMAL, 4 HARD)
DEMO_INDEX = 0x1E48    # attract demo counter (0, 1, 2 for stages 1, 2, 4)

# --- timeline from power-on, no input --------------------------------------
FRAME_KONAMI = 600
FRAME_INTRO = 2100     # city burning, alien face
FRAME_TITLE = 3600     # title menu fully drawn
FRAME_DEMO1 = 5000     # attract demo: stage 1 (burning city section)
FRAME_DEMO2 = 11700    # attract demo: stage 2 (top-down)
FRAME_DEMO3 = 18300    # attract demo: stage 4 (hover bikes)
TITLE_READY = 3700     # Start is accepted from here on


def boot(rom=None, core=None):
    return Console(rom or rom_path(), core=core)


def start_game(c, stage=1, menu_downs=0):
    """From power-on: wait for the title, pick a menu entry (0: 1 PLAYER,
    1: 2 PLAYERS A, 2: 2 PLAYERS B, 3: OPTION) and press Start. For games,
    selects `stage` by poking STAGE. Returns with the stage card on screen."""
    if c.frame_count < TITLE_READY:
        c.run(TITLE_READY - c.frame_count)
    for _ in range(menu_downs):
        c.press("down", frames=2, after=8)
    c.press("start", frames=3)
    c.run(20)
    if stage != 1:
        c.write_ram(STAGE, stage)


def set_options(c, level_rights=1, lives_rights=0):
    """From power-on: open OPTION on the title, press Right `lives_rights`
    times on PLAYER (3, 5, ...) and `level_rights` times on LEVEL (NORMAL ->
    HARD; it wraps), then EXIT back to the title with the cursor on 1 PLAYER."""
    if c.frame_count < TITLE_READY:
        c.run(TITLE_READY - c.frame_count)
    for _ in range(3):
        c.press("down", frames=2, after=10)
    c.press("start", frames=3, after=120)
    for _ in range(lives_rights):
        c.press("right", frames=2, after=20)
    c.press("down", frames=2, after=20)
    for _ in range(level_rights):
        c.press("right", frames=2, after=20)
    c.press("down", frames=2, after=20)
    c.press("down", frames=2, after=20)
    c.press("start", frames=3, after=120)
    for _ in range(8):
        if c.peek(TITLE_CURSOR) == 0:
            break
        c.press("up", frames=2, after=10)
