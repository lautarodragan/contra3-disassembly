#!/usr/bin/env python3
"""The sound CPU's samples: BRR files, sample lists, directories, WAV previews.

The samples are BRR data (the DSP's compressed format: blocks of 9 bytes, a
header and 16 4-bit samples), one file per sample in assets/sound/samples/.
A *sample list* (assets/sound/spc_samples_<bank>.txt) says which samples a
block of the ROM holds, in order, where the block goes in the sound CPU's
memory, and each sample's sound source number and loop start:

    at $B08E                     # ARAM address of the first sample
    20  opening-20.brr  0        # source, file, loop start (bytes from the
    21  common-00.brr   63       #   sample's start, a multiple of 9)
    23  -                        # a source with no sample: $FFFF, $FFFF

The block (`brr=list` in assets/manifest.txt) is the samples one after the
other; a directory (`dir=LIST,LIST...`: 64 entries of start and loop
address, DSP register DIR) has, for each source of the lists, its sample's
address and loop address, and zeros for the sources no list names.  So
editing a sample (or its loop) and running `make` moves the samples after
it and their directory entries.

    python3 tools/brr.py wav DIR [--seconds S] every sample as a WAV in DIR
    python3 tools/brr.py page                  the book's sample page (stdout)
    python3 tools/brr.py split SRC DEST        the .bin blocks in SRC -> files in DEST
    python3 tools/brr.py check                 the build's blocks cut again give the files

A WAV is the sample decoded as the DSP decodes it (the four filters,
clamping and wrapping as in the hardware; the same arithmetic as the DSP
of snes9x and bsnes), played once through and then, for a looped sample,
the loop again up to S seconds (default 1), at 32,000 Hz: the pitch the DSP plays it at
with pitch $1000 (the instruments retune it; book: Sound driver). There is
no WAV -> BRR encoder here: BRR encoding is lossy (an encoder picks a
filter and shift per block), so an edited sample is supplied as BRR, made
with an encoder such as BRRtools (`brr_encoder`); its loop start must fall
on a block boundary.
"""
import hashlib
import os
import re
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
ASSETS = "assets"
SAMPLES = os.path.join(ASSETS, "sound", "samples")
NONE = 0xFFFF
DIR_ENTRIES = 64
RATE = 32000


class Entry:
    def __init__(self, source, name, loop):
        self.source = source
        self.name = name        # file in SAMPLES, or None (no sample)
        self.loop = loop


class SampleList:
    def __init__(self, path, root=ROOT):
        self.path = path        # e.g. "sound/spc_samples_stage1", relative to assets/
        self.at = None
        self.entries = []
        file = os.path.join(root, ASSETS, path + ".txt")
        for n, line in enumerate(open(file), 1):
            words = line.split("#")[0].split()
            if not words:
                continue
            where = f"{file}:{n}"
            if words[0] == "at":
                self.at = int(words[1].lstrip("$"), 16)
            elif len(words) == 2 and words[1] == "-":
                self.entries.append(Entry(int(words[0]), None, 0))
            elif len(words) == 3:
                self.entries.append(Entry(int(words[0]), words[1], int(words[2])))
            else:
                sys.exit(f"{where}: expected `source file loop` or `source -`")
        if self.at is None:
            sys.exit(f"{file}: no `at` line")

    def files(self):
        return sorted({os.path.join(ASSETS, "sound", "samples", e.name)
                       for e in self.entries if e.name})

    def layout(self, root=ROOT):
        """[(entry, address, data)] and the block's bytes."""
        out = []
        block = bytearray()
        for e in self.entries:
            if e.name is None:
                out.append((e, None, b""))
                continue
            data = read_sample(os.path.join(root, SAMPLES, e.name))
            if e.loop % 9 or not 0 <= e.loop < len(data):
                sys.exit(f"{self.path}.txt: source {e.source}: loop {e.loop} is not the start "
                         f"of a block of {e.name} ({len(data)} bytes)")
            out.append((e, self.at + len(block), data))
            block += data
        if self.at + len(block) > 0x10000:
            sys.exit(f"{self.path}.txt: the samples go past the end of ARAM")
        return out, bytes(block)


def read_sample(path):
    data = open(path, "rb").read()
    if not data or len(data) % 9:
        sys.exit(f"{path}: {len(data)} bytes, not a whole number of 9-byte BRR blocks")
    for k in range(0, len(data) - 9, 9):
        if data[k] & 1:
            sys.exit(f"{path}: block {k // 9} has the end flag but is not the last")
    if not data[-9] & 1:
        sys.exit(f"{path}: the last block has no end flag")
    return data


def build_block(path, root=ROOT):
    """The bytes of a sample block (manifest option brr=list)."""
    return SampleList(path, root).layout(root)[1]


def build_dir(paths, root=ROOT):
    """The bytes of a directory (manifest option dir=LIST,LIST...)."""
    entries = [(0, 0)] * DIR_ENTRIES
    for path in paths:
        for e, addr, _data in SampleList(path, root).layout(root)[0]:
            entries[e.source] = (NONE, NONE) if addr is None else (addr, addr + e.loop)
    return b"".join(struct.pack("<HH", *x) for x in entries)


def sources(option_value, root=ROOT):
    """The files a brr=/dir= asset is made from (for the Makefile)."""
    out = []
    for path in option_value.split(","):
        out.append(os.path.join(ASSETS, path + ".txt"))
        out += SampleList(path, root).files()
    return out


# -- decoding -----------------------------------------------------------------

def _clamp16(v):
    return -32768 if v < -32768 else 32767 if v > 32767 else v


def decode(data, loop=None, seconds=1.0):
    """16-bit samples of a BRR sample: once through, then, if the last block
    has the loop flag, the loop again until `seconds` have been played."""
    # as blargg's SPC_DSP (snes9x, bsnes): the history holds the doubled
    # samples; p1 is the last one, p2 half the one before
    out = []
    h1 = h2 = 0
    blocks = [data[k:k + 9] for k in range(0, len(data), 9)]
    order = list(range(len(blocks)))
    if loop is not None and blocks[-1][0] & 2:
        again = list(range(loop // 9, len(blocks)))
        while len(order) * 16 < seconds * RATE:
            order += again
    for b in order:
        block = blocks[b]
        header = block[0]
        shift = header >> 4
        filt = header & 0x0C
        for byte in block[1:]:
            for nib in (byte >> 4, byte & 15):
                s = nib - 16 if nib >= 8 else nib
                s = (s << shift) >> 1
                if shift >= 13:
                    s = -2048 if s < 0 else 0
                p1, p2 = h1, h2 >> 1
                if filt >= 8:
                    s += p1 - p2
                    if filt == 8:
                        s += (p2 >> 4) + ((p1 * -3) >> 6)
                    else:
                        s += ((p1 * -13) >> 7) + ((p2 * 3) >> 4)
                elif filt:
                    s += (p1 >> 1) + ((-p1) >> 5)
                s = _clamp16(s)
                s = (s * 2) & 0xFFFF
                s = s - 0x10000 if s & 0x8000 else s
                h2, h1 = h1, s
                out.append(s)
    return out


def wav_bytes(samples, rate=RATE):
    pcm = struct.pack("<%dh" % len(samples), *samples)
    return (b"RIFF" + struct.pack("<I", 36 + len(pcm)) + b"WAVE"
            + b"fmt " + struct.pack("<IHHIIHH", 16, 1, 1, rate, rate * 2, 2, 16)
            + b"data" + struct.pack("<I", len(pcm)) + pcm)


# -- the lists of the manifest ---------------------------------------------------

def manifest_lists(root=ROOT):
    """{list path: [manifest paths of the directories that use it]} and the
    block assets, from assets/manifest.txt."""
    sys.path.insert(0, HERE)
    import assets
    lists, dirs = {}, {}
    for a in assets.read_manifest(root):
        if "brr" in a.options:
            lists[a.path] = []
        if "dir" in a.options:
            dirs[a.path] = a.options["dir"].split(",")
    for d, paths in dirs.items():
        for p in paths:
            lists.setdefault(p, []).append(d)
    return lists


def samples_used(root=ROOT):
    """{file: [(list path, source, loop, address)]}"""
    used = {}
    for path in manifest_lists(root):
        for e, addr, _data in SampleList(path, root).layout(root)[0]:
            if e.name:
                used.setdefault(e.name, []).append((path, e.source, e.loop, addr))
    return used


def write_wavs(dest, seconds=1.0, root=ROOT):
    os.makedirs(dest, exist_ok=True)
    n = 0
    for name, uses in sorted(samples_used(root).items()):
        data = read_sample(os.path.join(root, SAMPLES, name))
        loop = uses[0][2]
        with open(os.path.join(dest, name[:-4] + ".wav"), "wb") as f:
            f.write(wav_bytes(decode(data, loop, seconds)))
        n += 1
    return n


def page(root=ROOT):
    """The book's sample page."""
    out = ["# Sound samples", "",
           "Every BRR sample of `assets/sound/samples/` (see [Sound](sound.md#samples)),",
           "decoded as the DSP decodes it: once through, then the loop up to one second, at",
           "32,000 Hz (the pitch it has at DSP pitch `$1000`; an instrument plays it",
           "higher or lower). Generated by `python3 tools/brr.py page`; the WAV files",
           "are made by `python3 tools/brr.py wav` when the book is built (`make book`).",
           "",
           "| sample | bytes | loop | sources | |",
           "|---|---|---|---|---|"]
    for name, uses in sorted(samples_used(root).items()):
        data = read_sample(os.path.join(root, SAMPLES, name))
        loops = {u[2] for u in uses}
        loop = ("from %d" % uses[0][2]) if data[-9] & 2 else "none"
        if len(loops) > 1:
            loop = "varies"
        where = ", ".join("%s %d" % (p.split("spc_samples_")[1], s) for p, s, _l, _a in uses)
        out.append(f"| `{name}` | {len(data)} | {loop} | {where} | "
                   f'<audio controls preload="none" src="samples/{name[:-4]}.wav"></audio> |')
    return "\n".join(out) + "\n"


# -- the split (how the files were made from the ROM's blocks) -------------------

def split(src, dest):
    """Cut the sample blocks and directories in src (spc_samples_<bank>.bin,
    spc_sample_dir_<bank>.bin: as they were in assets/sound/, or as the build
    makes them in build/assets/sound/) into one file per sample in
    dest/samples/ (identical samples once, named after their first bank and
    source) and the lists dest/spc_samples_<bank>.txt. This is how the files
    were made; `check` does it again from the build and compares."""
    banks = [("common", 0x5100, "boot", range(20))] + [
        (b, 0xB08E, b, range(20, 24))
        for b in ("opening", "stage1", "stage2", "stage3", "stage4", "stage5", "stage6")]
    seen = {}
    os.makedirs(os.path.join(dest, "samples"), exist_ok=True)
    for bank, base, dirname, srcs in banks:
        d = open(os.path.join(src, f"spc_sample_dir_{dirname}.bin"), "rb").read()
        block = open(os.path.join(src, f"spc_samples_{bank}.bin"), "rb").read()
        what = "shared by every song set" if bank == "common" else f"of the {bank} song sets"
        lines = [f"# The samples {what}: the block spc_samples_{bank}, uploaded to ARAM",
                 "# at the address of `at` (book: Sound). One line per sound source: its",
                 "# number, the sample (assets/sound/samples/), the loop start in bytes",
                 "# from the sample's start (a multiple of 9); `-`: no sample ($FFFF).",
                 f"at ${base:04X}"]
        for i in srcs:
            start, loop = struct.unpack_from("<HH", d, 4 * i)
            if start == NONE:
                lines.append(f"{i:<3} -")
                continue
            a = start
            while not block[a - base] & 1:
                a += 9
            data = block[start - base:a + 9 - base]
            h = hashlib.sha1(data).hexdigest()
            if h not in seen:
                seen[h] = f"{bank}-{i:02d}.brr"
                open(os.path.join(dest, "samples", seen[h]), "wb").write(data)
            lines.append(f"{i:<3} {seen[h]:<16} {loop - start}")
        open(os.path.join(dest, f"spc_samples_{bank}.txt"), "w").write(
            "\n".join(lines) + "\n")
    return len(seen)


def check(root=ROOT):
    """Every sample file is used; the blocks and directories the build makes
    (build/assets/sound/), cut again (`split`), give the same sample files
    and lists: the files hold nothing the build drops."""
    import filecmp
    import tempfile
    sys.path.insert(0, HERE)
    import assets
    used = samples_used(root)
    bad = 0
    with tempfile.TemporaryDirectory() as tmp:
        for a in assets.read_manifest(root):
            if a.samples:
                open(os.path.join(tmp, a.path.split("/")[1] + ".bin"), "wb").write(
                    a.from_source(root))
        split(tmp, os.path.join(tmp, "out"))
        here = os.path.join(root, ASSETS, "sound")
        for name in sorted(os.listdir(os.path.join(tmp, "out", "samples"))):
            if not filecmp.cmp(os.path.join(tmp, "out", "samples", name),
                               os.path.join(here, "samples", name), shallow=False):
                print(f"{SAMPLES}/{name}: does not round-trip")
                bad += 1
        for name in sorted(os.listdir(os.path.join(tmp, "out"))):
            if name.endswith(".txt"):
                again = [l.split("#")[0].split() for l in open(os.path.join(tmp, "out", name))]
                have = [l.split("#")[0].split() for l in open(os.path.join(here, name))]
                if [w for w in again if w] != [w for w in have if w]:
                    print(f"assets/sound/{name}: does not round-trip")
                    bad += 1
    for name in sorted(os.listdir(os.path.join(root, SAMPLES))):
        if name.endswith(".brr") and name not in used:
            print(f"{SAMPLES}/{name}: not in any sample list")
            bad += 1
    print(f"{len(used)} samples in {len(manifest_lists(root))} sample lists")
    return 1 if bad else 0


def main(argv):
    os.chdir(ROOT)
    cmd = argv[1] if len(argv) > 1 else ""
    if cmd == "wav" and len(argv) > 2:
        seconds = float(argv[argv.index("--seconds") + 1]) if "--seconds" in argv else 1.0
        print(f"{write_wavs(argv[2], seconds)} WAV files in {argv[2]}")
    elif cmd == "page":
        sys.stdout.write(page())
    elif cmd == "split" and len(argv) > 3:
        print(f"{split(argv[2], argv[3])} samples")
    elif cmd == "check":
        return check()
    else:
        sys.exit(__doc__)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
