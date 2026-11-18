#!/usr/bin/env python3
"""Play one sound command in the emulator and render what it sounds like
(book: Sound driver, editing a sound effect).

    python3 tools/sound_render.py SOUND [--rom ROM] [--wav OUT.wav] [--seconds S]
    python3 tools/sound_render.py SOUND --rom EDITED.sfc --against ORIGINAL.sfc

SOUND is the command (hex, e.g. 3E). From power-on the game runs to the
title screen; then the command $84 (stop everything) goes into the game's
sound queue (sound_queue, as queue_sound puts them), and half a second
later, once the title music's notes have died away, SOUND; the audio is
recorded from then for S seconds (default 3) and starts at the sound's
first sample (the silence before it, which depends on when the driver
takes the command, is cut). It prints how long the sound lasts, its median
zero-crossing rate (which follows the pitch: n semitones up multiply it
by 2 ** (n / 12)) and its level every 0.1 s; --wav writes the audio
(stereo, 16 bits, the core's 32,040 Hz: snes9x hands over the DSP's
samples as they are); --against renders the same sound on a second ROM, prints both and
their ratios, and whether the two are the same sample for sample.

Two renders of one sound are rarely the same sample for sample, even on
the same ROM: the DSP steps its envelopes on a counter that runs from
power-on and takes key-ons every other sample, so a sound that starts at
another moment (another frame, or the same frame of a ROM whose CPU
timing differs, as an edited driver uploads for longer at boot) has its
envelope steps and its pitch changes some samples apart (book: Sound
driver, editing a sound effect). The lengths, levels and zero-crossing
rates are what to compare. Needs `make cores`.
"""
import argparse
import os
import struct
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
from c3emu import game, retro  # noqa: E402

RATE = 32040                # snes9x's audio rate: the DSP's samples per second, not resampled
SOUND_QUEUE = 0x0100        # src/ram.inc: sound_queue, sound_queue_write, sound_last_queued
SOUND_QUEUE_WRITE = 0x56
SOUND_LAST_QUEUED = 0x5C
SOUND_CMD_STOP = 0x84
START_FRAME = game.TITLE_READY
QUIET_FRAMES = 30           # after the stop command: the released notes die away


def queue(c, command):
    """Put a command into the game's sound queue, as queue_sound does."""
    w = c.peek(SOUND_QUEUE_WRITE)
    c.write_ram(SOUND_QUEUE + w, bytes([command]))
    c.write_ram(SOUND_QUEUE_WRITE, bytes([(w + 1) & 0xFF]))
    c.write_ram(SOUND_LAST_QUEUED, bytes([command]))


def render(rom, sound, seconds=3.0, core=None):
    """The stereo samples [(l, r), ...] of `sound` played on `rom`, from
    its first sample that is not silent."""
    c = retro.Console(rom, core=core, audio=True)
    c.run(START_FRAME)
    queue(c, SOUND_CMD_STOP)
    c.run(QUIET_FRAMES)
    c.audio = bytearray()
    queue(c, sound)
    c.run(int(seconds * 60) + 2)    # +2: the frame that sends it, the driver's tick
    pcm = bytes(c.audio)
    c.close()
    n = len(pcm) // 4
    samples = list(struct.iter_unpack("<hh", pcm[:n * 4]))
    start = next((k for k, (l, r) in enumerate(samples) if l or r), len(samples))
    return samples[start:start + int(seconds * RATE)]


def wav(samples, path):
    pcm = b"".join(struct.pack("<hh", l, r) for l, r in samples)
    with open(path, "wb") as f:
        f.write(b"RIFF" + struct.pack("<I", 36 + len(pcm)) + b"WAVE" + b"fmt "
                + struct.pack("<IHHIIHH", 16, 1, 2, RATE, RATE * 4, 4, 16)
                + b"data" + struct.pack("<I", len(pcm)) + pcm)


def describe(samples, chunk=RATE // 50, threshold=200):
    """(seconds until the sound falls silent, the median zero-crossing rate
    in Hz of its loud part, [(time, level)] every 1/10 s). The
    zero-crossing rate follows the pitch for one instrument: a sound
    transposed by n semitones has it 2 ** (n / 12) times higher."""
    mono = [(l + r) // 2 for l, r in samples]
    levels = []
    for k in range(0, len(mono) - chunk + 1, chunk):
        x = mono[k:k + chunk]
        levels.append((k / RATE, (sum(v * v for v in x) / len(x)) ** 0.5, x))
    loud = [lv for lv in levels if lv[1] >= threshold]
    length = loud[-1][0] + chunk / RATE if loud else 0.0
    peak = max((lv[1] for lv in levels), default=0)
    rates = sorted(sum(1 for i in range(1, len(x)) if (x[i - 1] < 0) != (x[i] < 0))
                   * RATE / len(x) / 2 for _, rms, x in levels if rms >= peak / 4 and peak)
    zc = rates[len(rates) // 2] if rates else 0.0
    step = 5
    timeline = [(levels[k][0], max(lv[1] for lv in levels[k:k + step]))
                for k in range(0, len(loud and levels[:int(length * 50) + 1]), step)]
    return length, zc, timeline


def report(name, samples):
    length, zc, timeline = describe(samples)
    print(f"{name}: {length:.2f} s, zero crossings {zc:.0f} Hz (median of the loud part)")
    print("  level every 0.1 s: " + " ".join(f"{lv:.0f}" for _, lv in timeline))
    return length, zc


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("sound", help="the sound command, hex")
    ap.add_argument("--rom", default=None)
    ap.add_argument("--against", help="a second ROM to compare with")
    ap.add_argument("--wav", help="write the audio here (with --against: OUT and OUT-against)")
    ap.add_argument("--seconds", type=float, default=3.0)
    ap.add_argument("--core")
    args = ap.parse_args(argv)
    sound = int(args.sound.lstrip("$"), 16)
    rom = args.rom or os.path.join(os.path.dirname(HERE), "build", "contra3.sfc")
    a = render(rom, sound, args.seconds, args.core)
    report(f"sound ${sound:02X} on {rom}", a)
    if args.wav:
        wav(a, args.wav)
    if args.against:
        b = render(args.against, sound, args.seconds, args.core)
        length_b, zc_b = report(f"sound ${sound:02X} on {args.against}", b)
        length_a, zc_a = describe(a)[:2]
        if length_b and zc_b:
            print(f"length x{length_a / length_b:.2f}, zero crossings x{zc_a / zc_b:.2f} "
                  "(the first ROM against the second)")
        n = min(len(a), len(b))
        differ = sum(1 for i in range(n) if a[i] != b[i])
        print("the same sample for sample" if not differ and len(a) == len(b) else
              f"{differ} of {n} samples differ (see the note on timing: --help)")
        if args.wav:
            stem, ext = os.path.splitext(args.wav)
            wav(b, stem + "-against" + ext)
    return 0


if __name__ == "__main__":
    sys.exit(main())
