// tests/test_brr_dsp.py: plays one BRR sample on voice 0 of snes9x's DSP
// (blargg's SPC_DSP.cpp, compiled alone with a stub snes9x.h) at pitch $1000,
// GAIN $7F, voice and main volumes $7F, no echo, and prints what the voice
// decodes (its BRR buffer, "d N") and the left output ("o N").
//     harness SAMPLE.brr LOOP_OFFSET(-1: none) COUNT
#include "snes9x.h"
struct SSettings Settings = {0, 2, 0, {100, 100, 100, 100, 100, 100, 100, 100, 100}};
#define private public
#include "dsp/SPC_DSP.h"
#undef private
#include <stdio.h>
#include <stdlib.h>

static unsigned char ram[0x10000];

int main(int argc, char** argv)
{
	if (argc != 4)
		return 2;
	FILE* f = fopen(argv[1], "rb");
	if (!f)
		return 2;
	fread(ram + 0x1000, 1, 0xE000, f);
	fclose(f);
	int loop = atoi(argv[2]), count = atoi(argv[3]);
	int start = 0x1000, loop_addr = 0x1000 + (loop < 0 ? 0 : loop);
	ram[0x200] = start & 0xFF; ram[0x201] = start >> 8;          // DIR = 2, source 0
	ram[0x202] = loop_addr & 0xFF; ram[0x203] = loop_addr >> 8;
	static SPC_DSP dsp;
	dsp.init(ram);
	dsp.reset();
	short out[2 * 64];
	static const unsigned char regs[][2] = {
		{0x6C, 0x20}, {0x5D, 0x02},                                  // FLG: no echo writes; DIR
		{0x0C, 0x7F}, {0x1C, 0x7F}, {0x2C, 0}, {0x3C, 0},            // MVOL, EVOL
		{0x4D, 0}, {0x3D, 0}, {0x2D, 0}, {0x5C, 0},                  // EON, NON, PMON, KOF
		{0x00, 0x7F}, {0x01, 0x7F}, {0x02, 0x00}, {0x03, 0x10},      // VOL, PITCH $1000
		{0x04, 0}, {0x05, 0}, {0x07, 0x7F},                          // SRCN 0, GAIN $7F
		{0x4C, 0x01}};                                               // KON voice 0
	for (unsigned i = 0; i < sizeof regs / sizeof regs[0]; i++)
		dsp.write(regs[i][0], regs[i][1]);
	SPC_DSP::voice_t* v = &dsp.m.voices[0];
	int pos = v->buf_pos, got = 0;
	while (got < count) {
		dsp.set_output(out, 2 * 64);
		dsp.run(32);                       // one sample
		for (int i = 0; i < dsp.sample_count(); i += 2)
			printf("o %d\n", out[i]);
		if (v->buf_pos != pos) {           // four new samples decoded
			for (int i = 0; i < 4; i++)
				printf("d %d\n", v->buf[pos + i]);
			got += 4;
			pos = v->buf_pos;
		}
	}
	return 0;
}
