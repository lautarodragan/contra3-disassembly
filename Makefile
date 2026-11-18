# Contra III: The Alien Wars (USA) disassembly -- build with ca65/ld65.

rom      := build/contra3.sfc
sha1file := contra3.sha1

CA65   ?= ca65
LD65   ?= ld65
PYTHON ?= python3

CA65FLAGS := --cpu 65816 -I src -I build/assets --bin-include-dir assets --bin-include-dir build/assets
LD65FLAGS := -C src/contra3.cfg

# src/main.asm includes every bank file, so it is the only translation unit;
# any file under src/ is a dependency, and so is every asset: the files of
# assets/ (included with .incbin) and the ones the build makes from them in
# build/assets/ (asset_targets, the compressed streams).  build/assets.mk has
# a rule per made file, written by tools/assets.py from assets/manifest.txt
# (book: Assets).
src_files := $(shell find src -name '*.asm' -o -name '*.inc' -o -name '*.bin')
asset_files := $(shell find assets -type f)

.DEFAULT_GOAL := all
include build/assets.mk

build/assets.mk: assets/manifest.txt tools/assets.py $(wildcard assets/sound/*.txt) | build
	$(PYTHON) tools/assets.py makefile > $@.tmp && mv $@.tmp $@

# A failed link must not leave a partial ROM behind that looks up to date.
.DELETE_ON_ERROR:

assets: $(asset_targets)

.PHONY: all assets assets-check compare clean coverage disasm cores bsnes emu-test goldens trace shift-build shift-test book book-check cheats ips cheat-test stage-test compress-test symbols

all: compare

# A bank that overflows (an asset that grew) is reported with its assets
# (tools/assets.py overflow; book: Assets, Size limits).
$(rom): build/main.o src/contra3.cfg
	@echo '$(LD65) $(LD65FLAGS) -m build/contra3.map -Ln build/contra3.lbl -o $@ build/main.o'
	@$(LD65) $(LD65FLAGS) -m build/contra3.map -Ln build/contra3.lbl -o $@ build/main.o 2> build/ld65.log; \
	 s=$$?; cat build/ld65.log >&2; \
	 if [ $$s != 0 ]; then $(PYTHON) tools/assets.py overflow build/ld65.log; exit $$s; fi

# The side-view stages' spawn lists: assets/stages/<name>.spawns (text) ->
# build/assets/stages/<name>_spawns.inc, included by src/data/tables_05.asm
# (tools/spawns.py; book: Assets, Spawn lists).
spawn_incs := $(patsubst assets/stages/%.spawns,build/assets/stages/%_spawns.inc,$(wildcard assets/stages/*.spawns))

build/assets/stages/%_spawns.inc: assets/stages/%.spawns tools/spawns.py src/object_types.inc
	$(PYTHON) tools/spawns.py inc $< $@

build/main.o: $(src_files) $(asset_files) $(asset_targets) $(spawn_incs) build/assets.limits | build
	$(CA65) $(CA65FLAGS) -o $@ src/main.asm

# Every asset fits where the game decompresses it (its max= in the manifest,
# the sizes the code fixes; tools/asset_limits.py).
build/assets.limits: $(src_files) $(asset_files) $(asset_targets) tools/asset_limits.py | build
	$(PYTHON) tools/assets.py limits
	@touch $@

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
	rm -rf build/assets build/assets.mk build/assets.limits build/ld65.log
	rm -rf build/shift build/dbg build/cheats build/patches
	rm -f build/contra3-*.sfc
	rm -rf build/symbols
	rm -f build/contra3.mlb build/contra3.cpu.sym build/contra3-*.mlb build/contra3-*.cpu.sym

# Symbol files for debugging emulators (tools/symbols.py): ROM labels, the
# RAM of src/ram.inc and the hardware registers, from ld65's debug info of a
# link with -g in build/symbols/ (checked to be build/contra3.sfc), as
# build/contra3.mlb (Mesen 2) and build/contra3.cpu.sym (bsnes-plus, WLA DX
# format), next to the ROM so the emulators load them with it.  Each file is
# parsed back and checked against the link.  `make cheats` writes the same
# for the cheat ROM.  See the book's Building page, "Debugging in an emulator".
#   make symbols
symbols: compare
	$(PYTHON) tools/symbols.py build

# What the CDL traces never touched: every unknown byte of the committed CDL,
# by category (free space, header, unreferenced blocks, assets, data, code),
# per bank, with the free space of each bank (tools/coverage.py; book: What
# the traces never touched).  COVERAGE_FLAGS: e.g. --list, --markdown.
#   make coverage [COVERAGE_FLAGS="--banks --top 12"]
COVERAGE_FLAGS ?= --banks

coverage: compare
	$(PYTHON) tools/coverage.py $(COVERAGE_FLAGS)

# Run the generator (tools/disasm.py, a reference/research tool since src/ is
# the source of truth) into build/disasm/: src/ is never overwritten.  Compare
# with `diff -r src build/disasm/src` and port improvements by hand.
# BASEROM defaults to the default build (the original ROM, checked by
# `compare`), CDL to the committed cdl/contra3.cdl (CDL= for none).
#   make disasm [BASEROM=path/to/contra3.sfc] [CDL=path/to/contra3.cdl]
BASEROM ?= $(rom)
CDL     ?= cdl/contra3.cdl

disasm: $(if $(filter $(rom),$(BASEROM)),compare)
	$(PYTHON) tools/disasm.py $(BASEROM) $(if $(CDL),--cdl $(CDL)) \
	    --out build/disasm/src --report build/disasm/disasm_report.md

# Emulator harness (tools/c3emu, tests/, cores/; see the book's Emulator tests
# page).  The cores are libretro builds of snes9x (with the CDL tracer patch)
# and bsnes, cloned at pinned commits into build/src/ (needs git, g++ and
# network access to github.com the first time) and built into build/cores/.
#   make cores        snes9x core -> build/cores/snes9x_libretro.so (~1 min)
#   make bsnes        bsnes core (second opinion) -> build/cores/bsnes_libretro.so
# emu-test: the pytest suite (screenshots of the intro, title, demos and every
# stage start; scripted plays through every stage; CDL checks; the cheats) on
# build/contra3.sfc.  It does not require the hash to match, so it also checks
# a refactor that moves code in the emulator, not just by hash.  ROM=path runs
# it on another ROM (the goldens stay those of the original), TESTS= picks
# test files.
#   make emu-test [ROM=other.sfc] [TESTS="tests/test_screens.py ..."]
# goldens: rewrite tests/goldens/ from the default build (only after changing
# the tests or the core: the default build is the original ROM).
# trace: run the coverage tracer on the default build and merge into cdl/.
SNES9X := build/cores/snes9x_libretro.so
BSNES  := build/cores/bsnes_libretro.so
TESTS  ?= tests
ROM    ?=

cores: $(SNES9X)
bsnes: $(BSNES)

$(SNES9X): cores/build.sh $(wildcard cores/patches/snes9x-*.patch)
	cores/build.sh snes9x

$(BSNES): cores/build.sh $(wildcard cores/patches/bsnes-*.patch)
	cores/build.sh bsnes

emu-test: $(rom) cores
	$(PYTHON) -m pytest $(TESTS) --rom "$(abspath $(or $(ROM),$(rom)))"

goldens: compare cores
	$(PYTHON) -m pytest tests/test_screens.py tests/test_play.py --update-goldens

trace: compare cores
	$(PYTHON) -m tools.trace

# Shift test (milestone 3): build a copy of src/ with filler bytes inserted at
# the start of every bank (a different amount per bank) and, with
# SHIFT_FLAGS="--labels 0.3 --seed N", before some data labels, then run the
# emulator suite on it (the screenshots and the scripted plays through every
# stage; not test_cdl.py, which checks the original reset vector).  It passes only if every reference between code and
# data is a label.  See tools/shift.py and the book's Shiftability page.
#   make shift-test [SHIFT=default|alt|N|BB=N,...] [SHIFT_FLAGS=...]
SHIFT       ?= default
SHIFT_FLAGS ?=

shift-build:
	$(PYTHON) tools/shift.py build --amounts $(SHIFT) $(SHIFT_FLAGS)
	$(PYTHON) tools/shift.py diff

shift-test: shift-build compare cores
	$(PYTHON) -m pytest tests/test_screens.py tests/test_play.py \
	    --rom "$(abspath build/shift/contra3.sfc)"

# The book (book/, published to GitHub Pages by .github/workflows/book.yml).
# book-check: every label, constant and path the book names must exist.
# book: needs mdBook (https://github.com/rust-lang/mdBook) on the PATH.
MDBOOK ?= mdbook

# The gallery page (book/src/gallery.md) is generated from the manifest by
# tools/assets.py and must be up to date; its images are the PNGs of assets/,
# copied into book/src/gallery/ (not tracked) before the book is built.
book-check:
	$(PYTHON) tools/check_book_names.py
	$(PYTHON) tools/assets.py gallery | diff -u book/src/gallery.md - \
	    || { echo 'book/src/gallery.md is out of date: python3 tools/assets.py gallery > book/src/gallery.md'; exit 1; }
	$(PYTHON) tools/brr.py page | diff -u book/src/sound-samples.md - \
	    || { echo 'book/src/sound-samples.md is out of date: python3 tools/brr.py page > book/src/sound-samples.md'; exit 1; }

book: book-check
	$(PYTHON) tools/assets.py gallery-copy book/src
	$(PYTHON) tools/brr.py wav book/src/samples
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

# Emulator tests of the cheats (tests/test_cheats.py): it builds cheat ROMs
# with tools/cheats.py and checks them through RAM reads, mostly against the
# default build doing the same.
#   make cheat-test
cheat-test: compare cores
	$(PYTHON) -m pytest tests/test_cheats.py

# The extra-stage build (src/game/stages.inc, `make cheats CHEATS=extra_stage`:
# a stage inserted as stage 2) in the emulator: tests/test_extra_stage.py
# builds it and plays it against the original's goldens.  Book: Adding a stage.
#   make stage-test
stage-test: compare cores
	$(PYTHON) -m pytest tests/test_extra_stage.py

# Matching compressor (tools/c3lz.py): decompress every compressed block of
# the built ROM, compress it again with each strategy and compare.  Fails if a
# strategy does not round-trip or the original encoder's two versions (v1, v2)
# do not reproduce every block.  See the book's Compression page.
#   make compress-test [COMPRESS_FLAGS="-v -s v1 -s v2"]
COMPRESS_FLAGS ?=

compress-test: compare
	$(PYTHON) tools/test_compressor.py $(COMPRESS_FLAGS)

# The PNG assets (book: Assets): each one's tiles, drawn again, give the same
# PNG pixels, so the PNG holds nothing the build drops.  (That the PNGs give
# the ROM's bytes is what `make` checks.)  And every recorded size limit
# (max= in the manifest) is still what the data lists of src/ give.
#   make assets-check
assets-check:
	$(PYTHON) tools/assets.py check
	$(PYTHON) tools/assets.py limits --verify
	$(PYTHON) tools/brr.py check
