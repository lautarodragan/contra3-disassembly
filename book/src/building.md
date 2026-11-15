# Building

## Tools

- GNU make.
- [cc65](https://cc65.github.io/) 2.19 or newer, for `ca65` and `ld65`.
  On Debian/Ubuntu `sudo apt install cc65` is enough.
- Python 3, only for the tools (the disassembler and the book's names
  check), not for building the ROM.

## make

```sh
make            # builds build/contra3.sfc and checks its SHA-1
make compare    # the same
make clean      # removes what the build made in build/
```

The build is two steps:

1. `ca65 --cpu 65816 -I src -o build/main.o src/main.asm`.
   `src/main.asm` includes every bank file, so it is the only translation
   unit. Every file in `src/` is a dependency of `build/main.o`.
2. `ld65 -C src/contra3.cfg -m build/contra3.map -Ln build/contra3.lbl -o build/contra3.sfc build/main.o`.
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
not enough. The private companion repository has a test suite that boots a
ROM in the snes9x libretro core and compares screenshots of the intro, the
title, the attract demos and the first 600 frames of every stage with
goldens taken from the original. To run it on `build/contra3.sfc`:

```sh
make emu-test PRIVATE=path/to/contra3-disassembly-private
```

`PRIVATE` defaults to `../contra3-disassembly-private`. The target builds
the ROM (without requiring it to match the hash) and runs `make test
ROM=...` in that repository, which needs Python 3 with pytest and Pillow and
builds the core the first time (`make cores` there; it needs network access
to GitHub). It takes about a minute.

## CI

`.github/workflows/build.yml` runs on every push to `main`, on pull requests
and by hand. It installs Ubuntu's `cc65` package, runs `make compare`, and
then fails if the build changed any tracked file (`git status --porcelain`
must be empty).

## The book

The book's sources are in `book/`: `book/book.toml` and the pages in
`book/src/`, listed in `book/src/SUMMARY.md` (a page missing from the
summary is not built; a summary entry without a file is an error).

```sh
make book-check     # python3 tools/check_book_names.py
make book           # book-check, then mdbook build book (output in book/book/)
mdbook serve book   # live preview at http://localhost:3000
```

`make book` needs [mdBook](https://github.com/rust-lang/mdBook) on the
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
