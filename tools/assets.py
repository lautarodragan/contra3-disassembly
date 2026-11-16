#!/usr/bin/env python3
"""The binary assets: graphics, WRAM streams and sound data in assets/.

The source includes each one with `.incbin "<dir>/<label>.<ext>"` right after
its label (book: Assets).  ca65 looks such a path up in the directories
INCLUDE_DIRS gives (relative to the repository root), so every assembly of
src/ (the Makefile, tools/srcmap.py, tools/cheats.py, tools/shift.py) passes
`ca65_args()`.

    assets/gfx/<label>.lz     compressed VRAM graphics (as in the ROM)
    assets/gfx/<label>.bin    uncompressed graphics
    assets/wram/<label>.lz    compressed streams decompressed to WRAM
    assets/sound/<label>.lz   compressed sound CPU data
    assets/sound/<label>.bin  uncompressed sound CPU data
"""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
INCLUDE_DIRS = ["assets"]


def ca65_args(root=ROOT):
    """The ca65 options that let `.incbin` find the assets."""
    args = []
    for d in INCLUDE_DIRS:
        args += ["--bin-include-dir", os.path.join(root, d)]
    return args
