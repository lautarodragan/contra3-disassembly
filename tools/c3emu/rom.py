"""Locating and extracting the ROM.

The original ROM lives in the repository as the No-Intro zip. It is extracted
on demand to rom/contra3.sfc (gitignored) and verified by SHA-1. Every tool
that needs "the ROM" goes through `rom_path()`, which honours the C3_ROM
environment variable so the same tests/tracer can run against a ROM rebuilt
from the disassembly.

    python3 -m tools.c3emu.rom --extract
"""
import hashlib
import os
import sys
import zipfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ZIP = os.path.join(ROOT, "Contra III - The Alien Wars (USA).zip")
MEMBER = "Contra III - The Alien Wars (USA).sfc"
EXTRACTED = os.path.join(ROOT, "rom", "contra3.sfc")
SHA1 = "265886e3f665adf2507e7b2f08b6b2ed9d0018b2"
SIZE = 0x100000


def sha1(data):
    return hashlib.sha1(data).hexdigest()


def extract(force=False):
    """Extracts the original ROM to rom/contra3.sfc and returns its path."""
    if os.path.exists(EXTRACTED) and not force:
        with open(EXTRACTED, "rb") as f:
            if sha1(f.read()) == SHA1:
                return EXTRACTED
    with zipfile.ZipFile(ZIP) as z:
        data = z.read(MEMBER)
    if sha1(data) != SHA1:
        raise SystemExit("the ROM in the zip has SHA-1 %s, expected %s"
                         % (sha1(data), SHA1))
    os.makedirs(os.path.dirname(EXTRACTED), exist_ok=True)
    tmp = EXTRACTED + ".tmp"
    with open(tmp, "wb") as f:
        f.write(data)
    os.replace(tmp, EXTRACTED)
    return EXTRACTED


def rom_path(explicit=None):
    """The ROM to run: an explicit path, else $C3_ROM, else the original
    (extracted from the zip if needed)."""
    path = explicit or os.environ.get("C3_ROM")
    if path:
        return os.path.abspath(path)
    return extract()


def is_original(path):
    with open(path, "rb") as f:
        return sha1(f.read()) == SHA1


if __name__ == "__main__":
    if "--extract" in sys.argv:
        print(extract(force="--force" in sys.argv))
    else:
        print(rom_path())
