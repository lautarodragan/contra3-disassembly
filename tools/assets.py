#!/usr/bin/env python3
"""The binary assets: graphics, WRAM streams and sound data (book: Assets).

The source includes each asset with `.incbin "<dir>/<label>.<ext>"` right
after its label.  assets/manifest.txt lists them, one per line:

    gfx/gfx_089D7E          lz-v2  png=2bpp tiles=253
    gfx/gfx_088FD4          lz-v1
    gfx/gfx_089249          lz-v1  png=mode7 tiles=118 tail=00
    sound/spc_block_1D8002  raw

  lz-v1, lz-v2  the source includes <path>.lz, a stream compressed with that
                version of the game's encoder (tools/c3lz.py), which the
                build makes in build/assets/ from the decompressed data;
  raw           the source includes <path>.bin, the data as it is.

The data is assets/<path>.bin, or, with png=FORMAT, the tiles of
assets/<path>.png (tools/snesgfx.py: 2bpp, 4bpp, 8bpp, mode7), which the
build converts to build/assets/<path>.bin: the first `tiles` tiles of the
PNG, then the bytes `tail` gives in hex (data that is not a whole number of
tiles).  `width` is the number of tiles per row of the PNG `topng` writes
(default 16).

ca65 looks the included paths up in INCLUDE_DIRS (assets/, then
build/assets/), so every assembly of src/ (the Makefile, tools/srcmap.py,
tools/cheats.py, tools/shift.py) first builds what is out of date and passes
`ca65_args()`.  The Makefile includes build/assets.mk, the rules this tool
writes (`makefile`), so that editing an asset rebuilds what depends on it.

    python3 tools/assets.py makefile > build/assets.mk
    python3 tools/assets.py build [TARGET ...]   # all out-of-date targets, or these
    python3 tools/assets.py list                 # path, kind, sizes
    python3 tools/assets.py topng FORMAT PATH ... [--width N]
                                                 # assets/PATH.bin -> .png (sets png=)
    python3 tools/assets.py check                # every PNG converts back exactly
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import c3lz  # noqa: E402
import snesgfx  # noqa: E402

ROOT = os.path.dirname(HERE)
ASSETS = "assets"
BUILD = os.path.join("build", "assets")
MANIFEST = os.path.join(ASSETS, "manifest.txt")
INCLUDE_DIRS = [ASSETS, BUILD]
KINDS = ("raw", "lz-v1", "lz-v2")
# the tools a generated file depends on
TOOLS = ["tools/assets.py", "tools/c3lz.py", "tools/snesgfx.py"]


class Asset:
    def __init__(self, path, kind, options):
        self.path = path            # e.g. "gfx/gfx_088FD4", relative to assets/
        self.kind = kind
        self.options = options      # {key: value} after the kind

    @property
    def compressed(self):
        return self.kind.startswith("lz-")

    @property
    def version(self):
        return self.kind[3:]

    @property
    def included(self):
        """The file the source includes, relative to an include dir."""
        return self.path + (".lz" if self.compressed else ".bin")

    @property
    def png(self):
        """The tile format of the PNG that holds the data, or None."""
        return self.options.get("png")

    @property
    def source(self):
        """The file in the repository that holds the data."""
        return os.path.join(ASSETS, self.path + (".png" if self.png else ".bin"))

    @property
    def data_source(self):
        """The file that holds the bytes (made from the PNG if there is one)."""
        if self.png:
            return os.path.join(BUILD, self.path + ".bin")
        return self.source

    @property
    def targets(self):
        """The files the build makes, in order ([]: the source is included
        as is)."""
        out = []
        if self.png:
            out.append(self.data_source)
        if self.compressed:
            out.append(os.path.join(BUILD, self.path + ".lz"))
        return out

    @property
    def target(self):
        """The file the source includes, if the build makes it."""
        return self.targets[-1] if self.targets else None

    def prerequisites(self, target=None):
        """What a target is made from (default: the last one)."""
        target = target or self.target
        if target == self.data_source and self.png:
            return [self.source]
        return [self.data_source]

    def tiles_from_png(self, root=ROOT):
        data = snesgfx.png_to_tiles(os.path.join(root, self.source), self.png,
                                    int(self.options["tiles"]))
        return data + bytes.fromhex(self.options.get("tail", ""))


def read_manifest(root=ROOT):
    out = []
    for n, line in enumerate(open(os.path.join(root, MANIFEST)), 1):
        line = line.split("#")[0].split()
        if not line:
            continue
        path, kind, *rest = line
        if kind not in KINDS:
            sys.exit(f"{MANIFEST}:{n}: unknown kind {kind}")
        options = dict(item.split("=", 1) for item in rest)
        out.append(Asset(path, kind, options))
    return out


def _write(path, data):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    open(tmp, "wb").write(data)
    os.replace(tmp, path)


def make_target(asset, target, root=ROOT):
    """Write one of asset.targets from its prerequisite."""
    if asset.png and target == asset.data_source:
        data = asset.tiles_from_png(root)
    else:
        data = c3lz.compress(open(os.path.join(root, asset.data_source), "rb").read(),
                             asset.version)
    _write(os.path.join(root, target), data)


def data_bytes(asset, root=ROOT):
    """The asset's data (decompressed), from its source."""
    if asset.png:
        return asset.tiles_from_png(root)
    return open(os.path.join(root, asset.source), "rb").read()


def _mtime(path):
    try:
        return os.stat(path).st_mtime
    except FileNotFoundError:
        return None


def out_of_date(asset, target, root=ROOT):
    t = _mtime(os.path.join(root, target))
    if t is None:
        return True
    deps = asset.prerequisites(target) + TOOLS
    return any((_mtime(os.path.join(root, d)) or 0) > t for d in deps)


def build(root=ROOT, targets=None, quiet=True):
    """Make every out-of-date target (or the given ones); returns how many."""
    n = 0
    for a in read_manifest(root):
        for target in a.targets:
            if targets is not None:
                if target not in targets:
                    continue
            elif not out_of_date(a, target, root):
                continue
            make_target(a, target, root)
            n += 1
            if not quiet:
                print(f"{target}: from {' '.join(a.prerequisites(target))}")
    return n


def ca65_args(root=ROOT):
    """Build the out-of-date assets; the ca65 options that let `.incbin`
    find them."""
    build(root)
    args = []
    for d in INCLUDE_DIRS:
        args += ["--bin-include-dir", os.path.join(root, d)]
    return args


def makefile(root=ROOT):
    lines = ["# Generated by tools/assets.py from assets/manifest.txt: do not edit.",
             ""]
    targets = []
    for a in read_manifest(root):
        for target in a.targets:
            targets.append(target)
            lines.append(f"{target}: {' '.join(a.prerequisites(target))} {' '.join(TOOLS)}")
            lines.append("\t$(PYTHON) tools/assets.py build $@")
    lines[1:1] = ["asset_targets := \\"] + [f"\t{t} \\" for t in targets] + ["", ""]
    return "\n".join(lines) + "\n"


def png_palette(path):
    """The viewing palette of an asset: from build/gfx_palettes.json
    (tools/gfx_palettes.py) if it has one, else None (a grey ramp)."""
    p = os.path.join(ROOT, "build", "gfx_palettes.json")
    if os.path.exists(p):
        entry = json.load(open(p)).get(path)
        if entry:
            return [tuple(c) for c in entry["colours"]]
    return None


def write_manifest(entries, root=ROOT):
    """Rewrite the manifest lines of these assets (keeping the others and
    the comments)."""
    by_path = {a.path: a for a in entries}
    path = os.path.join(root, MANIFEST)
    out = []
    for line in open(path):
        words = line.split("#")[0].split()
        if words and words[0] in by_path:
            a = by_path[words[0]]
            opts = " ".join(f"{k}={v}" for k, v in a.options.items())
            line = f"{a.path:32} {a.kind:6} {opts}".rstrip() + "\n"
        out.append(line)
    open(path, "w").write("".join(out))


def topng(paths, fmt, width=16):
    """Turn assets/PATH.bin into assets/PATH.png (format fmt), checking the
    round trip, and record it in the manifest."""
    manifest = {a.path: a for a in read_manifest()}
    done = []
    for path in paths:
        a = manifest[path]
        if a.png:
            sys.exit(f"{path}: already a PNG")
        data = open(a.source, "rb").read()
        tiles, tail = snesgfx.tile_count(len(data), fmt)
        body = data[:len(data) - tail]
        png = os.path.join(ASSETS, path + ".png")
        snesgfx.tiles_to_png(body, fmt, png, width, png_palette(path))
        a.options = {"png": fmt, "tiles": str(tiles)}
        if tail:
            a.options["tail"] = data[len(data) - tail:].hex().upper()
        if width != 16:
            a.options["width"] = str(width)
        if a.tiles_from_png() != data:
            os.remove(png)
            sys.exit(f"{path}: the PNG does not convert back to the same bytes")
        os.remove(a.source.replace(".png", ".bin"))
        done.append(a)
    write_manifest(done)
    return done


def check():
    """Every PNG asset: its tiles, drawn again, give the same PNG pixels
    (so the PNG holds nothing that the build would drop)."""
    import tempfile
    bad = 0
    n = 0
    with tempfile.TemporaryDirectory() as tmp:
        for a in read_manifest():
            if not a.png:
                continue
            n += 1
            data = a.tiles_from_png()
            body = data[:len(data) - len(bytes.fromhex(a.options.get("tail", "")))]
            W, H, pixels, _pal = snesgfx.read_png(a.source)
            again = os.path.join(tmp, "again.png")
            snesgfx.tiles_to_png(body, a.png, again, W // 8)
            W2, H2, pixels2, _pal = snesgfx.read_png(again)
            if (W, H, list(pixels)) != (W2, H2, list(pixels2)):
                print(f"{a.source}: does not round-trip")
                bad += 1
    print(f"{n} PNG assets, {n - bad} round-trip exactly")
    return 1 if bad else 0


def main(argv):
    os.chdir(ROOT)
    cmd = argv[1] if len(argv) > 1 else "build"
    if cmd == "makefile":
        sys.stdout.write(makefile())
    elif cmd == "build":
        targets = set(argv[2:]) or None
        if targets:
            known = {t for a in read_manifest() for t in a.targets}
            for t in targets - known:
                sys.exit(f"{t}: not a target of {MANIFEST}")
        build(targets=targets, quiet=False)
    elif cmd == "list":
        for a in read_manifest():
            size = len(data_bytes(a))
            print(f"{a.path:32} {a.kind:6} {a.png or '-':6} {size:7}")
    elif cmd == "check":
        return check()
    elif cmd == "topng":
        import argparse
        ap = argparse.ArgumentParser(prog="assets.py topng")
        ap.add_argument("format", choices=list(snesgfx.FORMATS))
        ap.add_argument("paths", nargs="+")
        ap.add_argument("--width", type=int, default=16)
        args = ap.parse_args(argv[2:])
        for a in topng(args.paths, args.format, args.width):
            print(f"{a.source}: {a.png}, {a.options['tiles']} tiles")
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
