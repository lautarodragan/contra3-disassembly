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

.PHONY: all compare clean disasm

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

# Regenerate src/ from an original ROM.  This OVERWRITES hand edits in src/:
# only use it while the generator is still the source of truth (see README).
#   make disasm BASEROM=path/to/contra3.sfc [CDL=path/to/cdl]
disasm:
	$(PYTHON) tools/disasm.py $(BASEROM) $(if $(CDL),--cdl $(CDL))
