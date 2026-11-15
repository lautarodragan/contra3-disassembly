"""pytest configuration: which ROM and which core the suite runs.

    python3 -m pytest tests                       # original ROM (from the zip)
    python3 -m pytest tests --rom build/contra3.sfc   # e.g. the rebuilt ROM
    C3_ROM=... C3_CORE=... python3 -m pytest tests    # same, via environment
    python3 -m pytest tests --update-goldens      # rewrite tests/goldens/*.png
"""
import os
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
if ROOT not in sys.path:
    sys.path.insert(0, ROOT)

from tools.c3emu import retro            # noqa: E402
from tools.c3emu.rom import rom_path     # noqa: E402


def pytest_addoption(parser):
    parser.addoption("--rom", default=None,
                     help="ROM to test (default: $C3_ROM, else the original from the zip)")
    parser.addoption("--core", default=None,
                     help="libretro core (default: $C3_CORE, else build/cores/snes9x_libretro.so)")
    parser.addoption("--update-goldens", action="store_true",
                     help="write the screenshots as the new goldens instead of comparing")


@pytest.fixture(scope="session")
def rom(request):
    return rom_path(request.config.getoption("--rom"))


@pytest.fixture(scope="session")
def core(request):
    path = request.config.getoption("--core") or retro.default_core()
    if not os.path.exists(path):
        pytest.skip("no libretro core at %s (run `make cores`)" % path)
    return path


@pytest.fixture(scope="session")
def update_goldens(request):
    return request.config.getoption("--update-goldens")
