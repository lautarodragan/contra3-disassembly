"""Locating the ROM.

The reference ROM is the default build of the disassembly, build/contra3.sfc
(`make`), which is byte-identical to the original cartridge dump: it is
checked here by SHA-1, as `make compare` does. Every tool that needs "the
ROM" goes through `rom_path()`, which honours the C3_ROM environment variable
so the same tests/tracer can run against another ROM (a shifted build, a
cheat build, ...).

    python3 -m tools.c3emu.rom
"""
import hashlib
import os

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
DEFAULT = os.path.join(ROOT, "build", "contra3.sfc")
SHA1 = "265886e3f665adf2507e7b2f08b6b2ed9d0018b2"
SIZE = 0x100000


def sha1(data):
    return hashlib.sha1(data).hexdigest()


def original():
    """The default build, build/contra3.sfc, after checking that it is the
    original ROM byte for byte."""
    if not os.path.exists(DEFAULT):
        raise SystemExit("no %s: run `make` first" % DEFAULT)
    with open(DEFAULT, "rb") as f:
        got = sha1(f.read())
    if got != SHA1:
        raise SystemExit("%s has SHA-1 %s, expected %s (the default build must "
                         "match the original; run `make`)" % (DEFAULT, got, SHA1))
    return DEFAULT


def rom_path(explicit=None):
    """The ROM to run: an explicit path, else $C3_ROM, else the default
    build (checked against the original's SHA-1)."""
    path = explicit or os.environ.get("C3_ROM")
    if path:
        return os.path.abspath(path)
    return original()


def is_original(path):
    with open(path, "rb") as f:
        return sha1(f.read()) == SHA1


if __name__ == "__main__":
    print(rom_path())
