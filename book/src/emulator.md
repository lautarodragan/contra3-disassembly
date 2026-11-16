# Emulator tests and the CDL tracer

`make` proves that `build/contra3.sfc` is the original ROM byte for byte
(SHA-1 `265886e3f665adf2507e7b2f08b6b2ed9d0018b2`). Once the source changes
the ROM on purpose (the shift test moves code and data, the cheats change
the game), the hash is not enough: the ROM has to be run. The repository
has a libretro-based harness for that, a pytest suite, and a code/data
logger (CDL) whose output guides the disassembler.

None of it needs the original ROM file. The reference is the default build,
which the harness checks against the SHA-1 above before using it.

## Layout

| Path | What |
|------|------|
| `cores/build.sh` | clones a libretro core at a pinned commit into `build/src/`, applies `cores/patches/<core>-*.patch`, builds into `build/cores/` |
| `cores/patches/bsnes-wram.patch` | exposes WRAM through `retro_get_memory_data` in bsnes (from the-advocate) |
| `cores/patches/snes9x-cdl.patch` | the CDL tracer and WRAM write watch for snes9x (`cdl.cpp`, `cdl.h` + hooks) |
| `tools/c3emu/retro.py` | ctypes libretro driver: frame-exact run, input on 2 pads, screenshots, save states, WRAM, CDL, write watch |
| `tools/c3emu/cdl.py` | CDL container: load/save/merge/report (`python3 -m tools.c3emu.cdl report cdl/contra3.cdl`) |
| `tools/c3emu/game.py` | Contra III knowledge: RAM addresses, attract-mode timeline, `start_game()` |
| `tools/c3emu/plays.py` | scripted deterministic plays through every stage (`tests/test_play.py`, `tools/shift_diag.py`) |
| `tools/c3emu/dis.py` | tiny CDL-guided 65816 disassembler for debugging (`python3 -m tools.c3emu.dis 00:8000 00:8040`) |
| `tools/c3emu/rom.py` | finds the ROM to run: `--rom`, else `$C3_ROM`, else `build/contra3.sfc` checked by SHA-1 |
| `tools/trace.py` | coverage tracer: plays scenarios, merges CDLs into `cdl/` |
| `tests/` | pytest suite (`pytest.ini`, `requirements.txt` at the root); goldens in `tests/goldens/` |
| `cdl/contra3.cdl`, `cdl/contra3.cdl.json` | merged CDL, format in [CDL format](cdl-format.md) |

Gitignored: `build/` (core sources in `build/src/`, binaries in
`build/cores/`), `out/` (test failure artefacts).

## Requirements

gcc/g++, make, git, cc65, Python 3.10+ with Pillow and pytest
(`pip install -r requirements.txt`). Network access to github.com for the
first core build.

## Build the cores

```sh
make cores     # snes9x with the CDL tracer -> build/cores/snes9x_libretro.so (~1 min)
make bsnes     # optional: bsnes (+WRAM patch) -> build/cores/bsnes_libretro.so (second opinion)
```

The upstream commits are pinned in `cores/build.sh`. To change the patch, edit
the sources in `build/src/snes9x`, then regenerate it:

```sh
cd build/src/snes9x
git add -N cdl.cpp cdl.h
git diff -- cdl.cpp cdl.h cpuexec.cpp getset.h dma.cpp libretro/Makefile.common \
    > ../../../cores/patches/snes9x-cdl.patch
```

`cores/build.sh` re-applies the patch on a clean checkout whenever the patch
or the pinned commit changes.

## Run the tests

```sh
make emu-test                        # the whole suite on build/contra3.sfc
make emu-test TESTS=tests/test_screens.py
make emu-test ROM=path/to/other.sfc  # any other ROM (the goldens stay the original's)
make shift-test                      # screens and plays on a shifted build (Shiftability page)
make cheat-test                      # tests/test_cheats.py (Cheats page)
python3 -m pytest tests --rom build/contra3.sfc --core build/cores/bsnes_libretro.so
C3_ROM=... C3_CORE=... python3 -m pytest tests
make goldens                         # rewrite tests/goldens/ from the default build
```

`make emu-test` builds `build/contra3.sfc` without requiring the hash to
match, so it also checks a refactor that moves code. `make goldens` (and
`make trace`) do require it: the goldens and the CDL are those of the
original game. When a play fails, `tests/test_play.py` also renders the
original's frame from the default build, so that diagnostic needs a
matching `build/contra3.sfc` (checkout of `main`, `make`).

* `test_screens.py`: power-on with no input and compare frames at fixed
  frame numbers (Konami logo, intro, title, the three attract demos) and the
  first 600 frames of each stage (stage chosen by poking `$86`), at 15-bit
  colour precision. On failure the actual frame and a diff go to
  `out/screens/`. A ROM rebuilt byte-exactly must pass unchanged.
* `test_play.py`: scripted plays (`tools/c3emu/plays.py`): from power-on,
  pick a stage on the title (poking `$86`, and `$1E40` = 1 to start at the
  stage's midpoint, which reaches its boss), then play with seeded random
  input (advancing with the game's own frames, so that a lag frame does not
  change what the game sees), infinite lives and bombs and the barrier
  kept on. The random moves never press Start (it pauses); the plays press
  it on the two screens that wait for it, 300 game frames after they
  appear: the closing message's PUSH START KEY and FINAL SCORE
  (`plays.waits_for_start`). 17 plays: every stage from its start and
  from its midpoint (the bosses, the stage transitions), 2-player modes A
  and B (the top-down split screen), HARD; the three endings from stage
  6's midpoint: `stage6_boss` (NORMAL: the closing message, then stage 1
  of the next loop on HARD), `stage6_ending_easy` (EASY: the same, the
  next loop on NORMAL with its 4 continues) and `stage6_ending_hard` (the
  last form chasing the helicopter, the closing message, the pictures and
  the crowd, FINAL SCORE, back to the opening); plus the attract
  sequence. Every 60 game frames (counted by the game's `frame_counter`, so
  a lag frame moves nothing) the screen (15-bit) and the sound command ring
  (`$0100-$01FF`, what `queue_sound` sends) are hashed, and the loudness of
  every half second of audio is taken (within 8% over 1.5 s, and only a
  difference lasting 3 s fails: the exact samples move when the CPU's
  timing changes by some cycles, as in a ROM with another layout, and a
  sound effect can start a frame later), and compared with
  `tests/goldens/play/<play>.json` (taken from the original). A checkpoint
  matches if any game frame within 2 of it does, and a lone checkpoint
  differing in at most 64 pixels from the original's frame between two
  matching ones is reported as tolerated (an IRQ landing elsewhere in the
  top-down split screen). On a mismatch the first differing checkpoint is
  reported and the actual frame, the original's frame and a diff go to
  `out/play/`. The plays run in parallel (`C3_JOBS`, default the CPU
  count); about 330,000 frames, 100 s on 4 cores.
* `test_cdl.py`: sanity checks of the tracer (skipped on a core without it).
  It checks the reset vector of the original layout, so the shift test
  leaves it out.
* `test_cheats.py`: the build-time cheats (milestone 4). Builds cheat ROMs
  from this checkout (`C3_DISASM` for another one; needs cc65) with
  `tools/cheats.py` and checks them through RAM reads, mostly against the
  default build doing the same: lives that don't go down after deaths (side
  view and top-down), no deaths with invincibility, respawn instead of a pit
  death, weapons kept, start values, continues, bombs, fire rate, doubled
  damage, scaled enemy HP, stage select, the title button codes, the debug
  keys, 30 lives in OPTION. About 3 minutes.

The screenshot tests run in about 45 s with snes9x (2 min with bsnes). The
goldens were taken with snes9x. bsnes matches them pixel for pixel except
`demo_stage4` (frame 18300): by the third attract demo the two cores'
timing has drifted enough that the recorded demo plays out differently
(12437 pixels). Every other frame, including all six stage starts, is
identical.

## Run the tracer

```sh
make trace                                  # all scenarios, merged into cdl/
python3 -m tools.trace --list               # scenario names
python3 -m tools.trace stage3 stage6 -j 2   # some scenarios, merged into cdl/
python3 -m tools.trace --fresh              # rebuild cdl/ from scratch
python3 -m tools.c3emu.cdl report cdl/contra3.cdl
```

Each scenario boots the game in its own process with the CDL on and returns
its log; logs are OR-merged into `cdl/contra3.cdl` (coverage only grows).
Inputs are random but seeded, so runs are reproducible. Scenarios:

* `attract`: 42000 frames of attract mode (intro, title, demos of stages 1, 2, 4).
* `title_menu`: menu cursor, OPTION screen.
* `stageN`: start at stage N (poke `$86`), random play with infinite lives
  and bombs (poke `$1F8A`, `$1F8C`) for 120000 frames (400000 for the
  top-down stages 2 and 5). When the section counter `$13BD` stops moving
  (a boss) the player switches to aiming everywhere and bombing. The random
  player clears side-view stages on its own, so bosses, stage transitions and
  the end of stage 6 get covered.
* `stageN_hard`, `stageN_easy`: same after setting LEVEL in OPTION through
  the menu (stage 6 on HARD runs 200000 frames, aiming at the full ending).
* `stageN_2p`, `stage1_2pb`, `stage3_2pb`: two-player modes A and B, both pads random.
* `gameover`: no cheats: game over, CONTINUE, game over, END.
* `pause`: pause/unpause.

Add scenarios in `tools/trace.py` (`SCENARIOS`). Set `C3_TRACE_SHOTS=dir` to
get a screenshot of stage scenarios every 4000 frames (to see where the
random player gets stuck).

## Using the driver

```python
from tools.c3emu import game
c = game.boot()                 # build/contra3.sfc, snes9x
c.cdl_enable()
game.start_game(c, stage=3)
c.hold("right", "y"); c.run(600)
c.image().save("shot.png")
c.peek(game.LIVES_P1)
state = c.save_state(); c.load_state(state)
c.watch(0x1F8A); c.run(1000); print(c.watch_log())   # who writes the lives counter
log = c.cdl_snapshot(); log.save("out/my.cdl")
```

## What the harness knows about the game (RAM, `$7E:xxxx`)

These are the addresses the harness pokes and reads; the [RAM map](ram-map.md)
has their names in the source.

| Address | Meaning |
|---------|---------|
| `$0086` | stage number 1-6; poke right after pressing Start on the title to pick a stage |
| `$0070` | attract demo stage (0-based) |
| `$1E48` | attract demo index (0, 1, 2) |
| `$1F8A` / `$1FCA` | lives ("REST") of player 1 / 2 |
| `$1F8C` / `$1FCC` | smart bombs of player 1 / 2 (A button) |
| `$1F80` | player 1 active weapon slot (0 / 2; X swaps) |
| `$0084` | difficulty in game, x2: 0 EASY, 2 NORMAL, 4 HARD (set from OPTION > LEVEL) |
| `$1E02` | title menu cursor: 0 1 PLAYER, 1 2 PLAYERS A, 2 2 PLAYERS B, 3 OPTION |
| `$1F88` / `$1FC8` | barrier (invincibility power-up) timer of player 1 / 2; keep at `$80` to stay invincible |
| `$13BD` | stage progress/section counter (increments as the stage scrolls; 0-14 in stage 1) |
| `$0200+` | player 1 object; player 2 at `$0240` |
