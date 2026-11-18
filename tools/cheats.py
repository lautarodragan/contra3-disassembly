#!/usr/bin/env python3
"""Build-time cheats (milestone 4): build a modified ROM, make IPS patches.

    python3 tools/cheats.py list                         # options and presets
    python3 tools/cheats.py build infinite_lives damage_mult=2
    python3 tools/cheats.py build --preset god-mode
    python3 tools/cheats.py ips [PRESET ...]             # IPS patches of presets

An option is a word of src/cheats.inc without the CHEAT_ prefix, in lower
case: a bare word sets it to 1 (`infinite_lives` -> -D CHEAT_INFINITE_LIVES=1),
`word=n` sets it to n.  `build` assembles src/ with those defines into
build/cheats/<name>/, recomputes the header checksum (the normal build keeps
the original's as data) and copies the ROM to build/contra3-<name>.sfc, where
<name> is the options joined by '-' (`infinite_lives-damage_mult2`) or the
preset's name, with its emulator symbol files build/contra3-<name>.mlb and
.cpu.sym (tools/symbols.py: the addresses of that ROM, not the default's).

`ips` builds each preset (all by default) and writes
build/patches/contra3-<preset>.ips against build/contra3.sfc, the default
build, which must be the original ROM (`make` checks it; its SHA-1 is in
contra3.sha1): no copy of the original is needed.  Each patch is checked by
applying it back.  `make cheats CHEATS="..."` / `make cheats PRESET=...` and
`make ips` call this.
"""
import argparse
import hashlib
import os
import re
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)

import assets  # noqa: E402
import make_ips  # noqa: E402
import symbols  # noqa: E402

CHEATS_INC = os.path.join(ROOT, "src", "cheats.inc")
# files whose `.ifndef CHEAT_X` blocks are options: the cheats, and the
# extra-stage build variant (src/game/stages.inc, book: Adding a stage)
OPTION_FILES = [os.path.join(ROOT, "src", "game", "stages.inc"), CHEATS_INC]
BASE_ROM = os.path.join(ROOT, "build", "contra3.sfc")
SHA1_FILE = os.path.join(ROOT, "contra3.sha1")

# Presets: name -> options.  `make ips` makes one patch per preset; the
# README's "Cheats" table and the book's Cheats page describe them.
PRESETS = {
    "infinite-lives": ["infinite_lives"],
    "invincible": ["invincible"],
    "god-mode": ["invincible", "no_pit_death", "infinite_lives",
                 "infinite_bombs", "keep_weapons"],
    "infinite-bombs": ["infinite_bombs"],
    "keep-weapons": ["keep_weapons"],
    "full-arsenal": ["start_weapon=5", "start_weapon2=1", "keep_weapons"],
    "rapid-fire": ["fire_delay=1"],
    "double-damage": ["damage_mult=2"],
    "half-enemy-hp": ["enemy_hp=50"],
    "one-hit-kills": ["enemy_hp=0"],
    "stage-select": ["stage_select"],
    "30-lives": ["start_lives=30", "option_30_lives", "infinite_continues"],
    "sound-check": ["sound_check"],
    "debug-keys": ["debug_keys", "button_codes", "sound_check"],
}


def known_options():
    """CHEAT_* options of src/cheats.inc (and src/game/stages.inc): name ->
    (default, comment above)."""
    opts = {}
    comment = []
    doc = ""
    for line in (l for path in OPTION_FILES for l in open(path)):
        line = line.strip()
        if line.startswith(";"):
            comment.append(line[1:].strip())
        elif line == "":
            comment = []
        elif line.startswith(".ifndef CHEAT_"):
            doc = " ".join(c for c in comment if c)
            comment = []
        else:
            m = re.match(r"(CHEAT_[A-Z0-9_]+)\s*=\s*(\S+)$", line)
            if m and doc is not None:
                opts[m.group(1)] = (m.group(2), doc)
            doc = None
    return opts


def parse_options(words):
    """['infinite_lives', 'damage_mult=2'] -> [('CHEAT_INFINITE_LIVES', 1), ...]"""
    known = known_options()
    out = []
    for w in words:
        name, _, value = w.partition("=")
        sym = "CHEAT_" + name.upper().replace("-", "_")
        if sym not in known:
            sys.exit("unknown cheat %r (python3 tools/cheats.py list)" % w)
        if value == "":
            value = "1"
        if not re.fullmatch(r"\d+", value):
            sys.exit("cheat %r: the value must be a number" % w)
        out.append((sym, int(value)))
    return out


def rom_name(words):
    return "-".join(w.replace("=", "").lower() for w in words)


def fix_checksum(rom):
    """Recompute the LoROM header checksum ($00:FFDC) and its complement."""
    rom = bytearray(rom)
    rom[0x7FDC:0x7FE0] = b"\xFF\xFF\x00\x00"
    s = sum(rom) & 0xFFFF
    rom[0x7FDC:0x7FDE] = (s ^ 0xFFFF).to_bytes(2, "little")
    rom[0x7FDE:0x7FE0] = s.to_bytes(2, "little")
    return bytes(rom)


def sha1(data):
    return hashlib.sha1(data).hexdigest()


def build(words, name=None, quiet=False):
    """Assemble src/ with the cheats' defines; returns the ROM's path."""
    defs = parse_options(words)
    name = name or rom_name(words) or "none"
    out = os.path.join(ROOT, "build", "cheats", name)
    os.makedirs(out, exist_ok=True)
    ca65 = os.environ.get("CA65", "ca65")
    ld65 = os.environ.get("LD65", "ld65")
    obj = os.path.join(out, "main.o")
    sfc = os.path.join(out, "contra3.sfc")
    cmd = [ca65, "--cpu", "65816", "-g", "-I", "src", *assets.ca65_args(ROOT)]
    for sym, value in defs:
        cmd += ["-D", "%s=%d" % (sym, value)]
    cmd += ["-o", obj, "src/main.asm"]
    subprocess.run(cmd, cwd=ROOT, check=True)
    subprocess.run([ld65, "-C", "src/contra3.cfg",
                    "-m", os.path.join(out, "contra3.map"),
                    "-Ln", os.path.join(out, "contra3.lbl"),
                    "--dbgfile", os.path.join(out, "contra3.dbg"),
                    "-o", sfc, obj], cwd=ROOT, check=True)
    rom = open(sfc, "rb").read()
    if defs:
        rom = fix_checksum(rom)
        open(sfc, "wb").write(rom)
    dst = os.path.join(ROOT, "build", "contra3-%s.sfc" % name)
    shutil.copyfile(sfc, dst)
    # the emulator symbol files of this ROM, from its own link (book:
    # Building, "Debugging in an emulator")
    base = dst[:-len(".sfc")]
    symbols.write(os.path.join(out, "contra3.dbg"), base, quiet=True)
    errors, _ = symbols.check(base, out)
    if errors:
        sys.exit("%s: %s" % (os.path.relpath(base, ROOT), "; ".join(errors[:5])))
    if not quiet:
        print("%s: %s (%s)" % (os.path.relpath(dst, ROOT), sha1(rom),
                               " ".join("%s=%d" % d for d in defs) or "no cheats"))
    return dst


def read_base():
    if not os.path.exists(BASE_ROM):
        sys.exit("%s missing: run `make` first" % os.path.relpath(BASE_ROM, ROOT))
    base = open(BASE_ROM, "rb").read()
    want = open(SHA1_FILE).read().split()[0]
    if sha1(base) != want:
        sys.exit("%s is not the original ROM (SHA-1 %s, want %s)"
                 % (os.path.relpath(BASE_ROM, ROOT), sha1(base), want))
    return base, want


def cmd_list(_args):
    for sym, (default, doc) in known_options().items():
        print("%-22s default %-14s %s" % (sym[6:].lower(), default, doc))
    print()
    for name, words in PRESETS.items():
        print("preset %-16s %s" % (name, " ".join(words)))


def cmd_build(args):
    if args.preset:
        if args.preset not in PRESETS:
            sys.exit("unknown preset %r (%s)" % (args.preset, ", ".join(PRESETS)))
        build(PRESETS[args.preset] + args.options, name=args.preset)
    else:
        build(args.options)


def cmd_ips(args):
    base, base_sha1 = read_base()
    names = args.presets or list(PRESETS)
    outdir = os.path.join(ROOT, "build", "patches")
    os.makedirs(outdir, exist_ok=True)
    lines = []
    for name in names:
        if name not in PRESETS:
            sys.exit("unknown preset %r" % name)
        path = build(PRESETS[name], name=name, quiet=True)
        rom = open(path, "rb").read()
        patch = make_ips.build_patch(base, rom)
        if make_ips.apply_patch(base, patch) != rom:
            sys.exit("%s: the patch does not reproduce the ROM" % name)
        ips = os.path.join(outdir, "contra3-%s.ips" % name)
        open(ips, "wb").write(patch)
        line = "%-30s %6d bytes  patched ROM sha1 %s  (%s)" % (
            os.path.basename(ips), len(patch), sha1(rom), " ".join(PRESETS[name]))
        print(line)
        lines.append(line)
    with open(os.path.join(outdir, "README.txt"), "w") as f:
        f.write("IPS patches for Contra III: The Alien Wars (USA).\n"
                "Apply to the original ROM, SHA-1 %s (1 MiB, no copier header).\n\n"
                % base_sha1)
        f.write("\n".join(lines) + "\n")


def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("list").set_defaults(func=cmd_list)
    p = sub.add_parser("build")
    p.add_argument("options", nargs="*")
    p.add_argument("--preset")
    p.set_defaults(func=cmd_build)
    p = sub.add_parser("ips")
    p.add_argument("presets", nargs="*")
    p.set_defaults(func=cmd_ips)
    args = ap.parse_args()
    args.func(args)


if __name__ == "__main__":
    main()
