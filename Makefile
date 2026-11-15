# Contra III: The Alien Wars (USA) disassembly -- build with ca65/ld65.

rom      := build/contra3.sfc
sha1file := contra3.sha1

CA65   ?= ca65
LD65   ?= ld65
PYTHON ?= python3

CA65FLAGS := --cpu 65816 -I src
LD65FLAGS := -C src/contra3.cfg

# src/main.asm includes every bank file, so it is the only translation unit;
# any file under src/ is a dependency.
src_files := $(shell find src -name '*.asm' -o -name '*.inc' -o -name '*.bin')

# A failed link must not leave a partial ROM behind that looks up to date.
.DELETE_ON_ERROR:

.PHONY: all compare clean disasm emu-test shift-build shift-test book book-check cheats ips cheat-test compress-test

all: compare

$(rom): build/main.o src/contra3.cfg
	$(LD65) $(LD65FLAGS) -m build/contra3.map -Ln build/contra3.lbl -o $@ build/main.o

build/main.o: $(src_files) | build
	$(CA65) $(CA65FLAGS) -o $@ src/main.asm

build:
	mkdir -p build

# Check the built ROM against the original's SHA-1 (contra3.sha1).
compare: $(rom)
	@if command -v sha1sum >/dev/null; then sum=$$(sha1sum $(rom) | cut -d' ' -f1); \
	 else sum=$$(shasum -a 1 $(rom) | cut -d' ' -f1); fi; \
	 want=$$(cut -d' ' -f1 $(sha1file)); \
	 if [ "$$sum" = "$$want" ]; then echo "$(rom): OK ($$sum)"; \
	 else echo "$(rom): MISMATCH (got $$sum, want $$want)"; exit 1; fi

clean:
	rm -f build/main.o build/contra3.sfc build/contra3.map build/contra3.lbl
	rm -rf build/shift build/dbg build/cheats build/patches
	rm -f build/contra3-*.sfc

# Run the generator (tools/disasm.py, a reference/research tool since src/ is
# the source of truth) into build/disasm/: src/ is never overwritten.  Compare
# with `diff -r src build/disasm/src` and port improvements by hand.
#   make disasm BASEROM=path/to/contra3.sfc [CDL=path/to/contra3.cdl]
disasm:
	$(PYTHON) tools/disasm.py $(BASEROM) $(if $(CDL),--cdl $(CDL)) \
	    --out build/disasm/src --report build/disasm/disasm_report.md

# Run the emulator test suite of the private companion repository (screenshots
# of the intro, title, demos and every stage start, with the snes9x libretro
# core) on the ROM built from src/.  Checks a refactor in the emulator, not
# just by hash.  The private repo needs its cores built (`make cores` there).
#   make emu-test [PRIVATE=../contra3-disassembly-private]
PRIVATE ?= ../contra3-disassembly-private

emu-test: $(rom)
	@test -f "$(PRIVATE)/tests/test_screens.py" || \
	  { echo "emu-test: no emulator test suite in PRIVATE=$(PRIVATE)"; exit 1; }
	$(MAKE) -C "$(PRIVATE)" test ROM="$(abspath $(rom))"

# Shift test (milestone 3): build a copy of src/ with filler bytes inserted at
# the start of every bank (a different amount per bank) and, with
# SHIFT_FLAGS="--labels 0.3 --seed N", before some data labels, then run the
# emulator suite on it (the screenshots and the scripted plays through every
# stage; not test_cdl.py, which checks the original reset vector).  It passes only if every reference between code and
# data is a label.  See tools/shift.py and the book's Shiftability page.
#   make shift-test [SHIFT=default|alt|N|BB=N,...] [SHIFT_FLAGS=...] [PRIVATE=...]
SHIFT       ?= default
SHIFT_FLAGS ?=

shift-build:
	$(PYTHON) tools/shift.py build --amounts $(SHIFT) $(SHIFT_FLAGS)
	$(PYTHON) tools/shift.py diff

shift-test: shift-build
	@test -f "$(PRIVATE)/tests/test_screens.py" || \
	  { echo "shift-test: no emulator test suite in PRIVATE=$(PRIVATE)"; exit 1; }
	$(MAKE) -C "$(PRIVATE)" test ROM="$(abspath build/shift/contra3.sfc)" \
	    TESTS="tests/test_screens.py tests/test_play.py"

# The book (book/, published to GitHub Pages by .github/workflows/book.yml).
# book-check: every label, constant and path the book names must exist.
# book: needs mdBook (https://github.com/rust-lang/mdBook) on the PATH.
MDBOOK ?= mdbook

book-check:
	$(PYTHON) tools/check_book_names.py

book: book-check
	$(MDBOOK) build book

# Cheats (milestone 4): optional changes chosen at build time, defined in
# src/cheats.inc (`python3 tools/cheats.py list`).  The default build above
# never has any.  A word sets an option to 1, word=n to n; the ROM goes to
# build/contra3-<options>.sfc (or build/contra3-<preset>.sfc) with its header
# checksum recomputed.
#   make cheats CHEATS="infinite_lives invincible damage_mult=2"
#   make cheats PRESET=god-mode
# ips: IPS patches of every preset (tools/cheats.py PRESETS) against the
# default build, which `compare` proves to be the original ROM, into
# build/patches/.  See the README ("Cheats") and the book's Cheats page.
CHEATS ?=
PRESET ?=

cheats:
	$(PYTHON) tools/cheats.py build $(if $(PRESET),--preset $(PRESET)) $(CHEATS)

ips: compare
	$(PYTHON) tools/cheats.py ips

# Emulator tests of the cheats (tests/test_cheats.py of the private
# repository): it builds cheat ROMs from this checkout with tools/cheats.py
# and checks them through RAM reads.
#   make cheat-test [PRIVATE=../contra3-disassembly-private]
cheat-test:
	@test -f "$(PRIVATE)/tests/test_cheats.py" || \
	  { echo "cheat-test: no tests/test_cheats.py in PRIVATE=$(PRIVATE)"; exit 1; }
	$(MAKE) -C "$(PRIVATE)" cores
	cd "$(PRIVATE)" && C3_DISASM="$(CURDIR)" $(PYTHON) -m pytest tests/test_cheats.py

# Matching compressor (tools/c3lz.py): decompress every compressed block of
# the built ROM, compress it again with each strategy and compare.  Fails if a
# strategy does not round-trip or the original encoder's two versions (v1, v2)
# do not reproduce every block.  See the book's Compression page.
#   make compress-test [COMPRESS_FLAGS="-v -s v1 -s v2"]
COMPRESS_FLAGS ?=

compress-test: compare
	$(PYTHON) tools/test_compressor.py $(COMPRESS_FLAGS)
