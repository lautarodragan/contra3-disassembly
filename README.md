# Contra III: The Alien Wars (USA) — disassembly

A ca65 disassembly of *Contra III: The Alien Wars* (SNES, USA) that rebuilds
the original ROM byte for byte:

    build/contra3.sfc  sha1: 265886e3f665adf2507e7b2f08b6b2ed9d0018b2

(Work in progress — see `docs/disasm_report.md` for how much is code vs. data.)

## Building

Requirements: GNU make and [cc65](https://cc65.github.io/) 2.19 or newer
(`ca65`, `ld65`; `apt install cc65` on Debian/Ubuntu is enough).

    make            # builds build/contra3.sfc and checks it against contra3.sha1
    make compare    # same
    make clean

The build does not need the original ROM: all code and data are in `src/`.
