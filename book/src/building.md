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
and a label file (`build/contra3.lbl`, every label with its address), which
emulator debuggers can load.

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

## CI

`.github/workflows/build.yml` runs on every push to `main`, on pull requests
and by hand. Its `build` job installs Ubuntu's `cc65` package, runs `make
compare` (with the system's Python 3 for the assets), `make
assets-check`, builds the cheat presets and their IPS patches, runs the shift
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
