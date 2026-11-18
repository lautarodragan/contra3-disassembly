# Building

## Tools

- GNU make.
- [cc65](https://cc65.github.io/) 2.19 or newer, for `ca65` and `ld65`.
  On Debian/Ubuntu `sudo apt install cc65` is enough.
- Python 3 (standard library only): the build converts the graphics from
  PNG and compresses the streams of `assets/` (`tools/assets.py`,
  `tools/snesgfx.py`, `tools/c3lz.py`; see [Assets](assets.md)); the other
  tools use it too.

## make

```sh
make            # builds build/contra3.sfc and checks its SHA-1
make compare    # the same
make clean      # removes what the build made in build/
```

The build is three steps:

1. `tools/assets.py` converts the graphics of `assets/` from PNG to tiles
   and compresses each stream that the manifest marks `lz-v1` or `lz-v2`,
   into `build/assets/` (one make rule per file, in the generated
   `build/assets.mk`; see [Assets](assets.md)).
2. `ca65 --cpu 65816 -I src --bin-include-dir assets --bin-include-dir build/assets -o build/main.o src/main.asm`.
   `src/main.asm` includes every bank file, so it is the only translation
   unit. Every file in `src/`, every file in `assets/` and every stream
   made in `build/assets/` (included with `.incbin`) is a dependency of
   `build/main.o`.
3. `ld65 -C src/contra3.cfg -m build/contra3.map -Ln build/contra3.lbl -o build/contra3.sfc build/main.o`.
   The linker config `src/contra3.cfg` has one memory area per bank
   (`ROM00` to `ROM1F`, `$8000` bytes each at `$XX:8000`, filled with `$FF`)
   and one segment per bank (`BANK00` to `BANK1F`). `src/main.asm` opens
   each bank's segment and includes that bank's files in address order (see
   [Source layout](layout.md)).

Besides the ROM, ld65 writes a map file (`build/contra3.map`, segment sizes)
and a label file (`build/contra3.lbl`). The default build assembles without
debug info (`ca65 -g`), so that label file is empty; `make symbols` (below)
links with it and writes symbol files that emulators load.

## The hash check

`make compare` (the default target) hashes the ROM with `sha1sum` (or
`shasum -a 1`) and compares it with the first field of `contra3.sha1`:

```
build/contra3.sfc: OK (265886e3f665adf2507e7b2f08b6b2ed9d0018b2)
```

Any other result is a failure and `make` exits non-zero. Every change to
`src/` must keep this OK until the project deliberately starts building
something other than the original (the cheats, see the
[Introduction](introduction.md#goals)).

## In the emulator

The hash check proves that the ROM is the original; once the source starts
changing the ROM on purpose (milestone 3 moves code and data around), it is
not enough. The repository has an emulator test suite that boots a ROM in
the snes9x libretro core and compares screenshots of the intro, the title,
the attract demos and the first 600 frames of every stage, and scripted
plays through every stage, with goldens taken from the original. It needs
gcc/g++, git, network access to github.com the first time (to clone the
pinned snes9x), and Python 3 with pytest and Pillow:

```sh
pip install -r requirements.txt
make cores      # builds build/cores/snes9x_libretro.so (~1 min, once)
make emu-test   # the whole suite on build/contra3.sfc (~7 min on 4 cores)
make emu-test TESTS=tests/test_screens.py   # only the screenshots (~1 min)
```

`make emu-test` builds the ROM without requiring it to match the hash, so
it also checks a refactor that moves code. It needs no original ROM file:
the default build is the reference. See [Emulator tests](emulator.md) for
the suite, the cores, the goldens and the CDL tracer.

## Debugging in an emulator

```sh
make symbols    # build/contra3.mlb (Mesen 2) and build/contra3.cpu.sym (bsnes-plus)
```

`tools/symbols.py` assembles `src/` again with debug info into
`build/symbols/` (`ca65 -g`, `ld65 --dbgfile`; the ROM it links must be
`build/contra3.sfc`), reads ld65's debug file and writes, next to the ROM:

- every ROM label: routines, tables, data. A cheap local is named after
  the label it belongs to, `nmi@run_frame` for `@run_frame` in `nmi` (Mesen
  does not allow a dot in a name). The first sentence of the comment block
  directly above a label is its comment, so the debugger shows each
  routine's header. In the `.mlb` a data label covers its bytes (up to the
  next label or the first line of code), so an operand inside a table shows
  as `table+3`;
- the RAM symbols of `src/ram.inc` (not its structure offsets and
  constants), with their comments; where the comment gives the symbol's own
  extent, "($0300-$047F" or "($40 bytes", and no other symbol starts inside
  it, the `.mlb` gives it that length. Several names for one address (the
  work area at `mode_work` is shared by the game modes) are one label, the
  first in `src/ram.inc`, with the others in its comment;
- the hardware registers of `src/snes_registers.inc`.

The game has no save RAM, so there are no SRAM labels.

Each file is then parsed back the way the emulator parses it, and every ROM
label is checked against the label file and the segments of the map of the
same link. `make cheats` writes the same two files for the cheat ROM
(`build/contra3-god-mode.mlb` ...), from its own link: the cheats move code,
so the default build's files do not fit a cheat ROM. CI uploads the files of
the default build and of every preset as the `symbols` artifact of the build
workflow, and the release workflow attaches the default build's two files to
the release.

Both emulators load the files by the ROM's file name, from the ROM's
folder: for another file name or folder, copy the files next to the ROM
and rename them after it (`Contra III.sfc` needs `Contra III.mlb`).

**Mesen 2.** The `.mlb` is Mesen's own label file: one
`type:address[-end]:name:comment` per line, `SnesPrgRom` addresses being
offsets in the ROM file (LoROM: bank × `$8000` + address − `$8000`;
`$00:8000` is `0000`), `SnesWorkRam` offsets in the 128 KiB of WRAM
(`$7E:2200` is `2200`, `$7F:0000` is `10000`) and `SnesRegister` the
register's address. When the debugger opens, Mesen loads `<rom>.mlb` from
the ROM's folder by itself (debugger settings, Integration tab, ".MLB files",
on by default). It skips the `.mlb`, though, when it found a ca65 `.dbg`
or a `.sym` of the same name first: do not put a `contra3.dbg` or
`contra3.sym` next to the ROM (the `.cpu.sym` has another name for this
reason). To load it by hand: in the debugger window, File →
Workspace → Import labels..., and pick the `.mlb`. The disassembly then
shows `nmi`, `lda nmi_busy`, `sta a:INIDISP` and the routines' comments; the
memory viewer names WRAM bytes (`obj_slots`, `td_enemy_shots+5`) and the
label list has all of them.

**bsnes-plus.** The `.cpu.sym` is in WLA DX's format, `[labels]` then
`[comments]`, one `BB:AAAA name` per line. When it loads a ROM, bsnes-plus
reads `<rom>.cpu.sym` (else `<rom>.sym`) from its folder, and the debugger's
disassembly shows operands as `<name>`. It looks a symbol up by the exact
24-bit address an operand resolves to: direct page operands in bank $00 and
absolute ones in the data bank, which the game keeps at $05 (set by `nmi`).
So the RAM below $2000 is listed in banks $00, $05 and $7E, and the
registers in banks $00 and $05. Other tools that read WLA DX symbol
files (Mesen reads them too, without lengths or comments) can use it
renamed to `contra3.sym`.

How the files were checked: both formats against the emulators' source
(Mesen 2's `CodeLabel.FromString` and `LabelManager.SetLabel`, which drops
a label another one overlaps; bsnes-plus's `WlaSymbolFile::read`), and by
running that code itself, compiled outside the emulators, on the files:
Mesen's import takes all 11 804 labels with no error and none dropped, and
bsnes-plus picks its WLA reader and reads the same labels and comments as
`tools/symbols.py check`. They have not been loaded in a running emulator
here (neither runs without a display).

## CI

`.github/workflows/build.yml` runs on every push to `main`, on pull requests
and by hand. Its `build` job installs Ubuntu's `cc65` package, runs `make
compare` (with the system's Python 3 for the assets), `make
assets-check`, builds the cheat presets and their IPS patches, makes the
symbol files (`make symbols`, uploaded as the `symbols` artifact with the
presets' ones), runs the shift
scan and a shifted build, and then fails if the build changed any tracked
file (`git status --porcelain` must be empty).

Its `emulator` job runs on pushes to `main` and by hand, not on pull
requests: it builds the snes9x core (cached, keyed on `cores/build.sh`,
which pins the commit, and the patch), then runs `make emu-test` and `make
shift-test`. It takes about 12-15 minutes; on a failure the frames and diffs
in `out/` are uploaded as an artifact.

## The book

The book's sources are in `book/`: `book/book.toml` and the pages in
`book/src/`, listed in `book/src/SUMMARY.md` (a page missing from the
summary is not built; a summary entry without a file is an error).

```sh
make book-check     # python3 tools/check_book_names.py
make book           # book-check, then mdbook build book (output in book/book/)
mdbook serve book   # live preview at http://localhost:3000
```

`make book` also copies the PNGs of `assets/` into `book/src/gallery/` (not
tracked) for the [Graphics gallery](gallery.md), whose page
`tools/assets.py gallery` generates (`make book-check` fails if it is out of
date). It needs [mdBook](https://github.com/rust-lang/mdBook) on the
`PATH`; CI uses the release tarball of v0.5.4 from GitHub, and the same
binary works locally.

`tools/check_book_names.py` reads every code span and code block in the
book and checks that the names in it exist:

- generated labels such as `load_data_list` must be defined in `src/`, so
  renaming a routine breaks the check until the pages that name it are
  updated;
- other names that look like code (with an underscore, CamelCase, or upper
  case of four letters or more, like `INIDISP`) must be a symbol defined in
  the ca65 sources (a label, a `=` constant, a `.define`, a macro, a segment)
  or appear in `tools/`, the `Makefile` or the workflows;
- paths such as `src/contra3.cfg` must be files or directories in the
  repository, and bare file names such as `nmi.asm` must be the name of
  one.

Names mentioned on purpose although the code doesn't have them (an old
name next to the new one, a made-up example) go in `book/names-ignore.txt`.

`.github/workflows/book.yml` runs the check and builds and publishes the
book to GitHub Pages on every push to `main` that changes `book/`, the
disassembler's report (included in [Progress](progress.md)), the checker or
the workflow.
