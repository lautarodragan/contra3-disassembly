# Contra III: The Alien Wars — emulator harness and CDL tracer

Private companion of the `contra3-disassembly` repository. It holds the
original ROM, a libretro-based test harness, and a code/data logger (CDL)
whose output guides the disassembler.

ROM: `Contra III - The Alien Wars (USA).sfc` (inside the zip), 1 MiB LoROM,
SHA-1 `265886e3f665adf2507e7b2f08b6b2ed9d0018b2`. Reset `$8000`, NMI `$819B`,
IRQ `$8BE2`.

## Layout

| Path | What |
|------|------|
| `cores/build.sh` | clones a libretro core at a pinned commit into `build/src/`, applies `cores/patches/<core>-*.patch`, builds into `build/cores/` |
| `cores/patches/snes9x-cdl.patch` | the CDL tracer and WRAM write watch for snes9x (`cdl.cpp`, `cdl.h` + hooks) |
| `tools/c3emu/retro.py` | ctypes libretro driver: frame-exact run, input on 2 pads, screenshots, save states, WRAM, CDL, write watch |
| `tools/c3emu/cdl.py` | CDL container: load/save/merge/report (`python3 -m tools.c3emu.cdl report cdl/contra3.cdl`) |
| `tools/c3emu/game.py` | Contra III knowledge: RAM addresses, attract-mode timeline, `start_game()` |
| `tools/c3emu/dis.py` | tiny CDL-guided 65816 disassembler for debugging (`python3 -m tools.c3emu.dis 00:8000 00:8040`) |
| `tools/c3emu/rom.py` | extracts and verifies the ROM; honours `$C3_ROM` |
| `tools/trace.py` | coverage tracer: plays scenarios, merges CDLs into `cdl/` |
| `tests/` | pytest suite (screenshot goldens in `tests/goldens/`, CDL checks) |
| `cdl/contra3.cdl`, `cdl/contra3.cdl.json` | merged CDL — format in [docs/CDL_FORMAT.md](docs/CDL_FORMAT.md) |

Gitignored: `build/` (core sources and binaries), `rom/` (extracted ROM),
`out/` (test failure artefacts).

## Requirements

gcc/g++, make, git, Python 3.10+ with Pillow and pytest
(`pip install -r requirements.txt`). Network access to github.com for the
first core build.

## Build the cores

```sh
make cores     # snes9x with the CDL tracer -> build/cores/snes9x_libretro.so (~1 min)
make bsnes     # optional: unpatched bsnes  -> build/cores/bsnes_libretro.so (second opinion)
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
make test                          # original ROM (extracted to rom/ automatically)
make test ROM=path/to/rebuilt.sfc  # any other ROM, e.g. built from the disassembly
python3 -m pytest tests --rom path/to/rebuilt.sfc --core build/cores/bsnes_libretro.so
C3_ROM=... C3_CORE=... python3 -m pytest tests
make goldens                       # rewrite tests/goldens/*.png from the current ROM/core
```

* `test_screens.py`: power-on with no input and compare frames at fixed
  frame numbers (Konami logo, intro, title, the three attract demos) and the
  first 600 frames of each stage (stage chosen by poking `$86`), at 15-bit
  colour precision. On failure the actual frame and a diff go to
  `out/screens/`. A ROM rebuilt byte-exactly must pass unchanged.
* `test_cdl.py`: sanity checks of the tracer (skipped on a core without it).

The suite runs in about 45 s with snes9x.

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

* `attract` — 42000 frames of attract mode (intro, title, demos of stages 1, 2, 4).
* `title_menu` — menu cursor, OPTION screen.
* `stageN` — start at stage N (poke `$86`), random play with infinite lives
  and bombs (poke `$1F8A`, `$1F8C`) for 120000 frames (400000 for the
  top-down stages 2 and 5). When the section counter `$13BD` stops moving
  (a boss) the player switches to aiming everywhere and bombing. The random
  player clears side-view stages on its own, so bosses, stage transitions and
  the end of stage 6 get covered.
* `stageN_hard`, `stageN_easy` — same after setting LEVEL in OPTION through
  the menu (stage 6 on HARD runs 200000 frames, aiming at the full ending).
* `stageN_2p`, `stage1_2pb`, `stage3_2pb` — two-player modes A and B, both pads random.
* `gameover` — no cheats: game over, CONTINUE, game over, END.
* `pause` — pause/unpause.

Add scenarios in `tools/trace.py` (`SCENARIOS`). Set `C3_TRACE_SHOTS=dir` to
get a screenshot of stage scenarios every 4000 frames (to see where the
random player gets stuck).

## Using the driver

```python
from tools.c3emu import game
c = game.boot()                 # original ROM, snes9x
c.cdl_enable()
game.start_game(c, stage=3)
c.hold("right", "y"); c.run(600)
c.image().save("shot.png")
c.peek(game.LIVES_P1)
state = c.save_state(); c.load_state(state)
c.watch(0x1F8A); c.run(1000); print(c.watch_log())   # who writes the lives counter
log = c.cdl_snapshot(); log.save("out/my.cdl")
```

## What we know about the game (RAM, `$7E:xxxx`)

| Address | Meaning |
|---------|---------|
| `$0086` | stage number 1-6; poke right after pressing Start on the title to pick a stage |
| `$0070` | attract demo stage (0-based) |
| `$1E48` | attract demo index (0, 1, 2) |
| `$1F8A` / `$1FCA` | lives ("REST") of player 1 / 2; decremented by `DEC $1D8A,X` at `$01:9B91` with X=`$0200`/`$0240` |
| `$1F8C` / `$1FCC` | smart bombs of player 1 / 2 (A button) |
| `$1F80` | player 1 active weapon slot (0 / 2; X swaps) |
| `$0084` | difficulty in game, x2: 0 EASY, 2 NORMAL, 4 HARD (set from OPTION > LEVEL) |
| `$1E02` | title menu cursor: 0 1 PLAYER, 1 2 PLAYERS A, 2 2 PLAYERS B, 3 OPTION |
| `$1F88` / `$1FC8` | barrier (invincibility power-up) timer of player 1 / 2; keep at `$80` to stay invincible |
| `$13BD` | stage progress/section counter (increments as the stage scrolls; 0-14 in stage 1) |
| `$0200+` | player 1 object (`$0212` state: 7/8 respawn, $0E dying; `$020A`/`$020E` probably X/Y position); player 2 at `$0240` |

The ROM header's 21-byte title field holds `"CONTRA3 THE ALIEN WARS"`, 22
characters, so the final `S` overwrites the map-mode byte (`$FFD5` = `$53`).
Emulators detect LoROM anyway.
