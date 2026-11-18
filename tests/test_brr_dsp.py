"""tools/brr.py against the DSP of snes9x (blargg's SPC_DSP, the core's
source in build/src/snes9x after `make cores`): the samples it decodes are
the DSP's sample for sample, and gaussian() gives the voice's output at
pitch $1000.  Compiles tests/brr_dsp_harness.cpp with SPC_DSP.cpp alone
(g++); skipped without them."""
import os
import shutil
import subprocess
import sys

import pytest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(ROOT, "tools"))
import brr  # noqa: E402

DSP = os.path.join(ROOT, "build", "src", "snes9x", "apu", "bapu", "dsp")
FILES = ["SPC_DSP.cpp", "SPC_DSP.h", "blargg_common.h", "blargg_config.h",
         "blargg_endian.h", "blargg_source.h"]
STUB = """#include <stdint.h>
typedef unsigned char bool8;
typedef int32_t int32;
struct SSettings { bool8 HardDisableAudio; int32 InterpolationMethod;
                   bool8 SeparateEchoBuffer; int ChannelsVolumePercent[9]; };
extern struct SSettings Settings;
"""
# (sample, its loop start or None): looped and not, the filters, a long one
SAMPLES = [("common-09.brr", 27), ("common-12.brr", None), ("common-17.brr", 2232),
           ("opening-20.brr", None), ("stage2-22.brr", 4707), ("stage4-22.brr", 3330)]


@pytest.fixture(scope="module")
def harness(tmp_path_factory):
    if not os.path.exists(os.path.join(DSP, "SPC_DSP.cpp")) or not shutil.which("g++"):
        pytest.skip("needs the snes9x source (make cores) and g++")
    d = tmp_path_factory.mktemp("dsp")
    # SPC_DSP.cpp includes "../../../snes9x.h": dsp/ three levels below the stub
    src = d / "a" / "b" / "dsp"
    src.mkdir(parents=True)
    for f in FILES:
        shutil.copy(os.path.join(DSP, f), src / f)
    (d / "a" / "snes9x.h").write_text("")
    (d / "snes9x.h").write_text(STUB)
    shutil.copy(os.path.join(ROOT, "tests", "brr_dsp_harness.cpp"), d / "a" / "b" / "h.cpp")
    exe = d / "harness"
    subprocess.run(["g++", "-O1", "-w", "-I", str(d), "-o", str(exe), str(d / "a" / "b" / "h.cpp"),
                    str(src / "SPC_DSP.cpp")], check=True)
    return str(exe)


def run(exe, path, loop, count):
    out = subprocess.run([exe, path, str(-1 if loop is None else loop), str(count)],
                         capture_output=True, text=True, check=True).stdout.split("\n")
    return ([int(x[2:]) for x in out if x.startswith("d ")][:count],
            [int(x[2:]) for x in out if x.startswith("o ")])


@pytest.mark.parametrize("name,loop", SAMPLES)
def test_decode_and_output_match_the_dsp(harness, name, loop):
    path = os.path.join(ROOT, brr.SAMPLES, name)
    data = brr.read_sample(path)
    ours = brr.decode(data, loop, seconds=0.2)
    count = len(ours) // 4 * 4
    decoded, output = run(harness, path, loop, count)
    assert decoded == ours[:count]
    # the output: gaussian(), then GAIN $7F (envelope $7F0 / 2048, low bit
    # cleared), voice volume and main volume ($7F / 128 each); 7 samples
    # later (key on, interpolation); up to where a sample with no loop ends
    # (its last block silences the voice)
    expect = [((((((s * 0x7F0) >> 11) & ~1) * 0x7F) >> 7) * 0x7F) >> 7
              for s in brr.gaussian(ours)]
    n = min(len(output) - 7, count - (32 if loop is None else 0))
    assert n > 1000
    assert output[7:7 + n] == expect[:n]
