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
BARRIER_P1 = 0x1F88    # barrier (invincibility power-up) timer; poking $80
BARRIER_P2 = 0x1FC8    # every few frames keeps the player invincible
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
