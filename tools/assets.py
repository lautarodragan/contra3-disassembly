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
(default 16).  With gpl=LAYOUT the data is the palette assets/<path>.gpl
(tools/snespal.py; LAYOUT block: a size-1 word then the colours, colours:
the colours alone; `colours=N`: the number of colours it must have); with
tilemap=FORMAT the tilemap text assets/<path>.tilemap (tools/snesmap.py: bg,
mode7; `width`: cells per row).  The build converts both to
build/assets/<path>.bin.  `max` is the largest the data may be, in bytes
(hex): what fits where the game decompresses it (tools/asset_limits.py;
`limits`).

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
    python3 tools/assets.py tilemap FORMAT PATH ... [--width N]
                                                 # assets/PATH.bin -> .tilemap (sets tilemap=)
    python3 tools/assets.py check                # every PNG converts back exactly;
                                                 # palettes exact, PNG viewing palettes in sync
    python3 tools/assets.py sync-palettes        # PNG viewing palettes from assets/views.txt
    python3 tools/assets.py normalize            # rewrite the .gpl files with exact words
    python3 tools/assets.py limits [--list | --verify | --record PATH ...]
                                                 # every asset fits (book: Assets, Size limits)
    python3 tools/assets.py overflow LD65_OUTPUT  # the assets of a bank ld65 says overflows
    python3 tools/assets.py gallery              # book/src/gallery.md (make book)
    python3 tools/assets.py gallery-copy DIR     # the PNGs into DIR/gallery/
"""
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import asset_limits  # noqa: E402
import c3lz  # noqa: E402
import snesgfx  # noqa: E402
import snesmap  # noqa: E402
import snespal  # noqa: E402

ROOT = os.path.dirname(HERE)
ASSETS = "assets"
BUILD = os.path.join("build", "assets")
MANIFEST = os.path.join(ASSETS, "manifest.txt")
INCLUDE_DIRS = [ASSETS, BUILD]
KINDS = ("raw", "lz-v1", "lz-v2")
# the tools a generated file depends on
TOOLS = ["tools/assets.py", "tools/c3lz.py", "tools/snesgfx.py", "tools/snespal.py",
         "tools/snesmap.py"]
SRC = "src"


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
    def gpl(self):
        """The layout of the palette (.gpl) that holds the data, or None."""
        return self.options.get("gpl")

    @property
    def tilemap(self):
        """The format of the tilemap text that holds the data, or None."""
        return self.options.get("tilemap")

    @property
    def converted(self):
        """True if the build converts the source to the data."""
        return bool(self.png or self.gpl or self.tilemap)

    @property
    def source(self):
        """The file in the repository that holds the data."""
        ext = ".png" if self.png else ".gpl" if self.gpl else ".tilemap" if self.tilemap else ".bin"
        return os.path.join(ASSETS, self.path + ext)

    @property
    def data_source(self):
        """The file that holds the bytes (made from the PNG, palette or
        tilemap text if there is one)."""
        if self.converted:
            return os.path.join(BUILD, self.path + ".bin")
        return self.source

    @property
    def targets(self):
        """The files the build makes, in order ([]: the source is included
        as is)."""
        out = []
        if self.converted:
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
        if target == self.data_source and self.converted:
            return [self.source]
        return [self.data_source]

    def tiles_from_png(self, root=ROOT):
        data = snesgfx.png_to_tiles(os.path.join(root, self.source), self.png,
                                    int(self.options["tiles"]))
        return data + bytes.fromhex(self.options.get("tail", ""))

    def from_source(self, root=ROOT):
        """The data (decompressed), from the file in the repository."""
        src = os.path.join(root, self.source)
        if self.png:
            return self.tiles_from_png(root)
        if self.gpl:
            words = snespal.read_gpl(src)
            if "colours" in self.options and len(words) != int(self.options["colours"]):
                raise ValueError(f"{self.source}: {len(words)} colours, the game reads "
                                 f"{self.options['colours']}")
            return snespal.to_bytes(words, self.gpl)
        if self.tilemap:
            return snesmap.read_text(src, self.tilemap, int(self.options.get("width", 0)) or None)
        return open(src, "rb").read()


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
    if asset.converted and target == asset.data_source:
        data = asset.from_source(root)
    else:
        data = c3lz.compress(open(os.path.join(root, asset.data_source), "rb").read(),
                             asset.version)
    _write(os.path.join(root, target), data)


def data_bytes(asset, root=ROOT):
    """The asset's data (decompressed), from its source."""
    return asset.from_source(root)


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
            try:
                make_target(a, target, root)
            except ValueError as e:
                hint = ""
                if "past the" in str(e):
                    hint = (f"; to make the asset bigger, raise tiles= in {MANIFEST} "
                            "(within its max=, see the book: Assets, Size limits)")
                sys.exit(f"{e}{hint}")
            n += 1
            if not quiet:
                print(f"{target}: from {' '.join(a.prerequisites(target))}")
    return n


def ca65_args(root=ROOT):
    """Build the out-of-date assets; the ca65 options that let `.incbin`
    find them."""
    build(root)
    errors = check_limits(root)
    if errors:
        sys.exit("\n".join(errors))
    args = []
    for d in INCLUDE_DIRS:
        args += ["--bin-include-dir", os.path.join(root, d)]
    return args


def check_limits(root=ROOT):
    """Error messages for the assets that do not fit (after build())."""
    return asset_limits.check(read_manifest(root), root, os.path.join(root, SRC))


def limits(argv):
    import argparse
    ap = argparse.ArgumentParser(prog="assets.py limits")
    ap.add_argument("--list", action="store_true", help="every asset, its size, limit and why")
    ap.add_argument("--verify", action="store_true",
                    help="each recorded max= is what the source gives")
    ap.add_argument("--record", nargs="+", metavar="PATH",
                    help="set max= from the source and the current size (a new asset)")
    args = ap.parse_args(argv)
    manifest = read_manifest()
    build()
    if args.record:
        known = {a.path: a for a in manifest}
        for p in args.record:
            if p not in known:
                sys.exit(f"{p}: not in {MANIFEST}")
        done = asset_limits.record([known[p] for p in args.record], ROOT, SRC)
        write_manifest(done)
        for a in done:
            print(f"{a.path}: max={a.options['max']}")
        return 0
    if args.list:
        print("\n".join(asset_limits.report(manifest, ROOT, SRC)))
        return 0
    errors = check_limits()
    if args.verify:
        errors += asset_limits.verify(manifest, ROOT, SRC)
    if errors:
        print("\n".join(errors), file=sys.stderr)
        return 1
    print(f"{len(manifest)} assets fit their limits" + (", all as the source gives them" if args.verify else ""))
    return 0


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


VIEWS = os.path.join(ASSETS, "views.txt")


def read_views(root=ROOT):
    """assets/views.txt: ({PNG path: (palette path, first colour)},
    {tilemap path: {option: value}})."""
    links, previews = {}, {}
    path = os.path.join(root, VIEWS)
    if not os.path.exists(path):
        return links, previews
    for n, line in enumerate(open(path), 1):
        words = line.split("#")[0].split()
        if not words:
            continue
        if words[0] == "palette" and len(words) == 4:
            links[words[1]] = (words[2], int(words[3]))
        elif words[0] == "preview" and len(words) > 2:
            previews[words[1]] = dict(w.split("=", 1) for w in words[2:])
        else:
            sys.exit(f"{VIEWS}:{n}: not a palette or preview line")
    return links, previews


def palette_rgb(spec, manifest, root=ROOT):
    """256 (r, g, b) of a CGRAM image: spec "PALETTE@INDEX,..." (colours
    not given are black)."""
    cgram = [(0, 0, 0)] * 256
    for item in spec.split(","):
        p, first = item.split("@")
        words = snespal.read_gpl(os.path.join(root, manifest[p].source))
        for i, w in enumerate(words):
            if int(first) + i < 256:
                cgram[int(first) + i] = snespal.rgb(w)
    return cgram


def linked_palette(asset, links, manifest, root=ROOT):
    """The viewing colours of a PNG asset from the palette it is linked
    to (assets/views.txt), or None."""
    if asset.path not in links:
        return None
    p, first = links[asset.path]
    words = snespal.read_gpl(os.path.join(root, manifest[p].source))
    n = 1 << snesgfx.FORMATS[asset.png][0]
    return [snespal.rgb(w) for w in words[first:first + n]]


def render_preview(asset, view, manifest, root=ROOT):
    """(W, H, pixels, palette) of a tilemap drawn with the characters and
    palettes its preview line gives: chars=ASSET@VRAMWORD,... (the
    character data as loaded to VRAM), base=VRAMWORD (the BG's character
    base), bpp=2|4|8, palette=PALETTE@CGRAMINDEX,..."""
    fmt = asset.tilemap
    width = int(asset.options.get("width", 0)) or snesmap.FORMATS[fmt][1]
    data = asset.from_source(root)
    bpp = int(view.get("bpp", 4))
    vram = bytearray(0x10000 if fmt == "bg" else 0x8000)
    for item in view["chars"].split(","):
        p, addr = item.split("@")
        d = data_bytes(manifest[p], root)
        start = int(addr, 16) * (2 if fmt == "bg" else 1)
        vram[start:start + len(d)] = d[:max(0, len(vram) - start)]
    if fmt == "mode7":
        size, tfmt, base = 64, "mode7", 0
    else:
        size, tfmt, base = 8 * bpp, f"{bpp}bpp", int(view.get("base", "0"), 16) * 2
    chars = {}
    for v in set(snesmap.cells(data, fmt)):
        t = v if fmt == "mode7" else v & 0x3FF
        a = (base + t * size) % len(vram)
        chars[t] = snesgfx.decode_tile(bytes(vram[a:a + size]), tfmt)
    return snesmap.render(data, fmt, width, chars, bpp,
                          palette_rgb(view["palette"], manifest, root))


def sync_palettes(root=ROOT):
    """Give each linked PNG of assets/ the colours of its palette (the
    pixels stay); returns the PNGs changed."""
    links, _ = read_views(root)
    manifest = {a.path: a for a in read_manifest(root)}
    changed = []
    for path in links:
        a = manifest[path]
        colours = linked_palette(a, links, manifest, root)
        src = os.path.join(root, a.source)
        W, H, pixels, old = snesgfx.read_png(src)
        new = colours + list(old[len(colours):])
        if [tuple(c) for c in old] != new:
            snesgfx.write_png(src, W, H, pixels, new)
            changed.append(a.source)
    return changed


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
            comment = "  #" + line.split("#", 1)[1].rstrip("\n") if "#" in line else ""
            line = f"{a.path:32} {a.kind:6} {opts}".rstrip() + comment + "\n"
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
        a.options = {"png": fmt, "tiles": str(tiles),
                     **({"max": a.options["max"]} if "max" in a.options else {})}
        if tail:
            a.options["tail"] = data[len(data) - tail:].hex().upper()
        if width != 16:
            a.options["width"] = str(width)
        if "max" in a.options:
            a.options["max"] = a.options.pop("max")     # last, as written
        if a.tiles_from_png() != data:
            os.remove(png)
            sys.exit(f"{path}: the PNG does not convert back to the same bytes")
        os.remove(a.source.replace(".png", ".bin"))
        done.append(a)
    write_manifest(done)
    return done


def totilemap(paths, fmt, width=None):
    """Turn assets/PATH.bin into the tilemap text assets/PATH.tilemap,
    checking the round trip, and record it in the manifest."""
    manifest = {a.path: a for a in read_manifest()}
    done = []
    for path in paths:
        a = manifest[path]
        if a.converted:
            sys.exit(f"{path}: already converted ({a.source})")
        bin_path = a.source
        data = open(bin_path, "rb").read()
        a.options = dict(a.options, tilemap=fmt)
        if width:
            a.options["width"] = str(width)
        snesmap.write_text(a.source, data, fmt, width, path.split("/")[-1])
        if a.from_source() != data:
            os.remove(a.source)
            sys.exit(f"{path}: the text does not convert back to the same bytes")
        os.remove(bin_path)
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
    pals = [a for a in read_manifest() if a.gpl]
    inexact = 0
    for a in pals:
        lines = snespal.parse_gpl(open(a.source).read(), a.source)
        odd = [i for i, (_w, exact) in enumerate(lines) if not exact]
        if odd:
            print(f"{a.source}: colours {', '.join(map(str, odd))} are not given as exact "
                  "SNES words (python3 tools/assets.py normalize)")
            inexact += 1
    print(f"{len(pals)} palettes, {len(pals) - inexact} exact")
    links, previews = read_views()
    manifest = {a.path: a for a in read_manifest()}
    stale = 0
    for path in links:
        a = manifest[path]
        old = [tuple(c) for c in snesgfx.read_png(a.source)[3]]
        colours = linked_palette(a, links, manifest)
        if old[:len(colours)] != colours:
            print(f"{a.source}: its palette is not that of {links[path][0]} "
                  "(python3 tools/assets.py sync-palettes)")
            stale += 1
    for path, view in previews.items():
        render_preview(manifest[path], view, manifest)
    print(f"{len(links)} PNGs linked to a palette, {len(links) - stale} in sync; "
          f"{len(previews)} tilemap previews")
    return 1 if bad or inexact or stale else 0


def gallery():
    """The book's gallery page: every PNG asset, by directory."""
    titles = {"gfx": "Graphics loaded to VRAM", "wram": "Sprite tiles decompressed to WRAM"}
    out = ["# Graphics gallery", "",
           "Every graphic of `assets/` that is a PNG (see [Assets](assets.md)), as the",
           "build reads it, shown at twice its size: 16 tiles per row, in the colours `tools/gfx_palettes.py`",
           "found on screen (a grey ramp where it found none). Generated by",
           "`python3 tools/assets.py gallery`; the images are copied next to the",
           "book when it is built (`make book`). After the graphics: the tilemaps,",
           "drawn where it is known how the game shows them, and the palettes.", ""]
    groups = {}
    for a in read_manifest():
        if a.png:
            groups.setdefault(a.path.split("/")[0], []).append(a)
    for d, items in groups.items():
        out += [f"## {titles.get(d, d)}", ""]
        for a in items:
            label = a.path.split("/")[1]
            tail = f", tail `{a.options['tail']}`" if "tail" in a.options else ""
            out += [f"### {label}", "",
                    f"`{a.source}`: {a.png}, {a.options['tiles']} tiles{tail}, {a.kind}.", "",
                    f'<img src="gallery/{a.path}.png" alt="{label}" '
                    f'width="{2 * snesgfx.read_png(a.source)[0]}" '
                    'style="image-rendering: pixelated">', ""]
    links, previews = read_views()
    tilemaps = [a for a in read_manifest() if a.tilemap]
    if tilemaps:
        out += ["## Tilemaps", "",
                "The tilemap texts (`.tilemap`). Where `assets/views.txt` says how the",
                "game shows one (the characters its load list puts in VRAM, the colours",
                "of the palette task of the same screen), it is drawn with those",
                "assets, so editing the tilemap, the graphics or the palette changes",
                "the picture.", ""]
        for a in tilemaps:
            label = a.path.split("/")[1]
            width = int(a.options.get("width", 0)) or snesmap.FORMATS[a.tilemap][1]
            rows = len(data_bytes(a)) // snesmap.FORMATS[a.tilemap][0] // width
            out += [f"### {label}", "", f"`{a.source}`: {a.tilemap}, {width}x{rows} cells, {a.kind}.", ""]
            view = previews.get(a.path)
            if view:
                chars = ", ".join(f"`{c.split('@')[0].split('/')[-1]}`" for c in view["chars"].split(","))
                pals = ", ".join(f"`{c.split('@')[0].split('/')[-1]}`" for c in view["palette"].split(","))
                out += [f"Drawn with {chars} and {pals}.", "",
                        f'<img src="gallery/{a.path}.png" alt="{label}" '
                        f'width="{min(512, 8 * width * (2 if width <= 32 else 1))}" '
                        'style="image-rendering: pixelated">', ""]
            else:
                out += ["No preview (see [Assets](assets.md#tilemaps)).", ""]
    pals = [a for a in read_manifest() if a.gpl]
    if pals:
        out += ["## Palettes", "",
                "The palettes (`.gpl`), 16 colours per row. The graphics above whose",
                "colours are those of one of them (`assets/views.txt`) take its colours",
                "(`python3 tools/assets.py sync-palettes`).", ""]
        users = {}
        for png, (p, first) in links.items():
            users.setdefault(p, []).append(f"`{png.split('/')[-1]}`")
        for a in pals:
            label = a.path.split("/")[1]
            n = len(snespal.read_gpl(a.source))
            used = f" Colours of {', '.join(users[a.path])}." if a.path in users else ""
            out += [f"### {label}", "",
                    f"`{a.source}`: {n} colour{'s' if n > 1 else ''} ({a.gpl}).{used}", "",
                    f'<img src="gallery/{a.path}.png" alt="{label}" '
                    f'width="{16 * min(n, 16)}" style="image-rendering: pixelated">', ""]
    return "\n".join(out)


def gallery_copy(dest):
    import shutil
    manifest = {a.path: a for a in read_manifest()}
    _links, previews = read_views()
    for a in manifest.values():
        out = os.path.join(dest, "gallery", a.path + ".png")
        if not (a.png or a.gpl or a.path in previews):
            continue
        os.makedirs(os.path.dirname(out), exist_ok=True)
        if a.png:
            shutil.copyfile(a.source, out)
        elif a.gpl:
            # a swatch: 16 colours per row, 8x8 pixels each
            words = snespal.read_gpl(a.source)
            W, H = 8 * min(len(words), 16), 8 * ((len(words) + 15) // 16)
            pixels = bytearray(W * H)
            for i in range(len(words)):
                for y in range(8):
                    p = (i // 16 * 8 + y) * W + i % 16 * 8
                    pixels[p:p + 8] = bytes([i]) * 8
            snesgfx.write_png(out, W, H, pixels, [snespal.rgb(w) for w in words])
        else:
            snesgfx.write_png(out, *render_preview(a, previews[a.path], manifest))


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
    elif cmd == "sync-palettes":
        for p in sync_palettes():
            print(f"{p}: palette updated")
    elif cmd == "normalize":
        for a in read_manifest():
            if a.gpl and snespal.normalize(a.source):
                print(f"{a.source}: rewritten")
    elif cmd == "tilemap":
        import argparse
        ap = argparse.ArgumentParser(prog="assets.py tilemap")
        ap.add_argument("format", choices=list(snesmap.FORMATS))
        ap.add_argument("paths", nargs="+")
        ap.add_argument("--width", type=int)
        args = ap.parse_args(argv[2:])
        for a in totilemap(args.paths, args.format, args.width):
            print(f"{a.source}: {a.tilemap}")
    elif cmd == "check":
        return check()
    elif cmd == "limits":
        return limits(argv[2:])
    elif cmd == "overflow":
        print(asset_limits.ld65_diagnosis(open(argv[2]).read(), SRC, INCLUDE_DIRS), file=sys.stderr)
    elif cmd == "gallery":
        sys.stdout.write(gallery())
    elif cmd == "gallery-copy":
        gallery_copy(argv[2])
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
