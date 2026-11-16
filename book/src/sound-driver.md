# Sound driver (SPC700)

The program the sound CPU runs, `spc_driver` (`assets/sound/spc_driver.bin`,
uploaded to ARAM `$0200`; see [Sound](sound.md#sound-cpu-memory) for the
memory map), and the format of the songs and sound effects it plays. It
was read from the driver's code with `tools/spc700.py` (an SPC700
disassembler: `python3 tools/spc700.py assets/sound/spc_driver.bin 200
--trace 200 ...` follows the code from the entry points given); the
addresses below are ARAM addresses in the driver. What is not said here is
not worked out.

## The driver

`$0200` jumps to the start-up code at `$0896`: stack at `$01CF`, the
variables cleared (`$0000`-`$00EF`, `$0100`-`$018E`, `$0203`-`$03E5`),
echo off, DSP DIR = `$50` (the directory at `$5000`), main volume `$7F`,
timer 0 at 8,000 / 32 = 250 Hz. The main loop then, for each tick of
timer 0:

- writes the DSP registers it keeps in direct page (echo volume, echo
  feedback, EON, FLG, KON, KOF, NON, PMON);
- reads a command from the main CPU on `$F4` (APUIO0), when there is a new
  one, and echoes it (see [Commands](#commands));
- advances the fade-out, if one is running;
- runs each of the 8 *channels* that plays something: channel *n* drives
  DSP voice *n*. A channel's duration counter advances by *tempo* / 256
  units per tick, so a duration of *d* lasts *d* x 256 / (250 x *tempo*)
  seconds; when it runs out the channel reads its sequence on (notes and
  commands, below), and every tick it updates pitch (vibrato, slides) and
  volume (fades).

Channels 0-5 play the music (a song's mask is `$3F`); the sound effects
take channels 6 and 7, and an 8-channel song (sounds `$71`, `$72`) all
eight. Each channel remembers the sound it plays and its priority.

## Commands

A command is the byte the game writes to APUIO0 (see
[Sound driver interface](sound.md#commands)):

| command | what the driver does |
|---|---|
| `$01`-`$73` | play sound *n* from the sound table (below); 0 and the empty entries (`$40`, `$60`, `$6C`, `$70`, `$73`) do nothing |
| `$74`-`$7A` | choose the instrument set *n* - `$74` (instruments `$14`-`$18`, below): the start command of a song set (`song_start_commands`) |
| `$7B` | reads a jump address from before its table (`$18FD`): not used |
| `$7C` | pause: channels 6 and 7 stop and are silenced, sound effects on music channels too, and the music plays at about a fifth of its volume (x 50 / 256) |
| `$7D` | end of pause |
| `$7E`, `$7F` | mono (every pan centred), stereo |
| `$80`, `$81` | fade the music out, at speed 2 or 4 (ticks per step, `$0625`); at the end the music stops |
| `$82` | sets the flag that makes `branch` take its second address (`$2A` bit 0) |
| `$83` | stops the music (channels 0-5) |
| `$84` | stops everything (`SOUND_CMD_STOP`) |
| `$85`-`$FE` | ignored |
| `$FF` | receive data: the driver runs the IPL ROM's transfer protocol itself until a block of address 0 (`SOUND_CMD_UPLOAD`, `start_song_set_upload`) |

### The sound table

`$03E6`: 5 bytes per sound `$01`-`$73`: the channel mask, the priority,
the number of channels (bits 0-3; bits 4-7 set a per-channel flag that
makes notes carry no gate and volume, never set), and the address of a
list of one sequence address per channel. `python3 tools/spcseq.py driver`
prints the table and decodes the sequences of the sound effects.

- `$01`-`$3F`: one channel. The driver gives it channel 6 or 7: the one
  that already plays the same sound (it restarts), else the one with the
  lower priority (channel 6 on a tie); the sound plays only if its
  priority is at least that channel's. `$19` takes the place of `$18`, and
  `$1F` of `$1E`, on the channel that plays it.
- `$41`-`$5B`: two channels, 6 and 7, if the priority is at least channel
  6's.
- `$5C`-`$5F`: on music channels (0-1, 0-1, 2-3, 4), whatever plays there.
- `$61`-`$6B`, `$71`, `$72`: the song at `$3000` (the song set's song):
  6 channels, or 8 for `$71` and `$72`. The game uses `$62` and `$63` for
  the stage songs, `$61` (opening), `$68` (bosses), `$69` (heart boss),
  `$6A` (stage clear), `$6B` (game over), `$71` (ending), `$72` (Konami
  logo).
- `$6D`, `$6E`: 6-channel sequences in the driver (`$6D`: queued when the
  title's start is pressed and by `stage3_boss_state_19`; `$6E`: by
  `queue_sound_6E_throttled` and `td_play_rumble_sound`); `$6F`: the song at
  `$4B00`, which only the songs of stages 2 and 5 have (the top-down
  intro, `intro_init`).

The sequences of sounds `$01`-`$5F`, `$6D` and `$6E` are in the driver,
`$1B37`-`$2DAB`.

## Instruments

`inst n` loads an instrument: 8 bytes, the sound source (DSP SRCN), a
coarse and a fine tuning (semitones, and 256ths of one, added to the note),
ADSR1, ADSR2, GAIN, the pan (0-20, 10 is the centre) and an attenuation
subtracted from the volume.

- `$00`-`$13`: the table at `$0636` (source *n* for instrument *n*: the
  common samples);
- `$14`-`$18`: from the instrument set chosen by commands `$74`-`$7A`
  (pointers at `$0628`, 5 instruments each: `$06D6`, `$07A6`, `$07CE`,
  `$07F6`, `$081E`, `$0846`, `$086E`): the stage's samples (sources
  20-23), tuned per stage. The opening uses set 6, stage 1 set 2, stage 2
  set 1, stage 3 set 0, stage 4 set 3, stage 5 set 4, stage 6 set 5;
- `$19` and up: `$0636` + 8 *n*, which runs into the drum table.

Drums (`drums_on`): each note number *n* plays instrument *n* of the drum
table at `$06FE` (21 instruments) at a fixed note (`$3C`).

The pitch of a note is the note number plus the transpose and the
instrument's tuning, in 256ths of a semitone, looked up in the table at
`$15BC` (96 notes, interpolated). Index `$48` is DSP pitch `$10BE`, about a
semitone above `$1000` (the sample played at 32 kHz); index 0 is `$0042`.
Note numbers are given as numbers, not names: which note a sample plays
depends on the sample.

## Echo

`echo_setup d f x` sets the echo delay EDL = *d* (the buffer is *d* x 2 KiB
at the top of ARAM: ESA = `$10000` - *d* x `$800`) and the feedback EFB = *f*; the FIR
filter is always the table at `$1199` (`$0C $21 $2B $2B $13 $FE $F3 $F9`).
`echo m l r` sets EON = *m* (the voices that echo) and the echo volumes;
*m* = 0 turns the echo off. The songs use delays 3 and 5: the buffer is
`$D800`-`$FFFF`, just above the stage samples (the largest ends at `$D78A`).

## Sequences

A sequence is a list of notes and commands, read when the channel's
duration runs out. A song is a header (one address per channel) and the
channels' sequences; it lives at `$3000` (the song of the set) or in the
driver. The names are those of `tools/spcseq.py`; the operands are bytes.

### Notes

| bytes | |
|---|---|
| `n d g v` | note *n* (`$00`-`$5F`) for duration *d*, gate *g*, volume *v* |
| `n+$80 g v` | the same with the duration of the note before |
| `n d v+$80` | the gate of the note before |
| `n+$80 v+$80` | both |

The gate is the part of the duration the note is held, in percent; from
100 (`$64`) on, the note is not released before the next one. A duration
0 ends with the duration counter at 0 or below: the note does not play
(its bytes are read and skipped). In the text: `note n d g v`, with `.`
for the duration or gate of the note before.

Bytes `$65`-`$7F` stop every channel (as command `$84`); no sequence uses
them.

### Commands

| byte | name | operands | what |
|---|---|---|---|
| `$60` | `drums_on` | | notes play the drum table |
| `$61` | `drums_off` | | |
| `$62` | `gate` | g | the gate of the next notes |
| `$63` | `volume` | v | the volume kept for notes without one (never needed: see the sound table's flag) |
| `$64` | `gate_volume` | g v | both |
| `$E0` | `rest` | d | release the note, wait *d* |
| `$E1` | `tie` | d g | hold the note *d* longer, with gate *g* |
| `$E2` | `inst` | i | instrument (above) |
| `$E3` | `pan` | p | pan 0-20; `$15`: the instruments' pans are ignored from now on, `$16`: used again |
| `$E4` | `vibrato` | delay rate depth | vibrato, starting after *delay* |
| `$E5` | `pitch_noise` | rate mask-hi mask-lo | every time *rate* overflows an accumulator, a pseudo-random offset (tables at `$16BC`, `$17BC`) masked with the 16-bit mask is added to the pitch |
| `$E6` | `loop1_start` | | where `loop1` goes back to |
| `$E7` | `loop1` | count vol pitch | go back to `loop1_start` until played *count* times (0: for ever), each time adding *vol* (signed) to the volume and *pitch*/32 semitone to the pitch; then the offsets are reset |
| `$E8` | `loop2_start` | | the same for a second loop; also resets its counter and offsets (`loop2` does not when it ends) |
| `$E9` | `loop2` | count vol pitch | |
| `$EA` | `tempo` | t | the channel's tempo |
| `$EB` | `tempo_fade` | time t | to tempo *t* in *time* steps |
| `$EC` | `transpose` | n | semitones (signed) |
| `$ED` | `skip3` | a b c | nothing (its 3 operands are skipped) |
| `$EE` | `channel_volume` | v | |
| `$EF` | `channel_volume_fade` | time v | |
| `$F0` | `glide` | time | the next notes slide from the note before, in *time* |
| `$F1` | `bend` | delay time n | the next notes start *n* semitones low and slide up in *time*, after *delay* |
| `$F2` | `detune` | n | *n* x 4 256ths of a semitone (signed) |
| `$F3` | `slide` | delay time note | after a note: slide to *note* (plus transpose) in *time*, after *delay* (the driver looks ahead for it while the note plays) |
| `$F4` | `echo` | eon l r | see [Echo](#echo) |
| `$F5` | `echo_setup` | delay feedback x | *x* is not used |
| `$F6` | `repeat_start` | | |
| `$F7` | `repeat` | | the first `repeat` after `repeat_start` ends a section; each later one plays the section again and goes on after itself |
| `$F8` | `pan_fade` | time p | |
| `$F9` | `vibrato_fade` | time | the vibrato grows to its depth in *time* |
| `$FA` | `envelope` | a b decay | *a* < `$A0`: ADSR, attack *a* / 10 and decay *a* mod 10, sustain level *b* / 30 and rate *b* mod 30 + 2; else GAIN = *b*. *decay* x 16: when the gate time is over, instead of releasing the note, its volume falls by that much (in 256ths) per step, and the note is released at 0 |
| `$FB` | `pitch_mod` | m | PMON = *m* (pitch modulation of the voices in *m*) |
| `$FC` | `branch` | a1 a2 | go to *a1*; to *a2* if command `$82` set the driver's flag (cleared by channel 5 when it takes it) |
| `$FD` | `jump` | a | |
| `$FE` | `call` | a | one level: `end` returns |
| `$FF` | `end` | | return from a `call`, else the channel stops |

The operand counts are the driver's table at `$0E27` (the handlers' at
`$0DDD`), but for `branch`, which reads its second address when it uses
it.

## Songs as text

The 14 songs are text files, `assets/sound/spc_song_<name>.seq`, that the
build assembles (`seq=text` in the manifest, `tools/spcseq.py`) and then
compresses or includes like the other assets:

```
at $3000
	song L300C L31D1 ...
L300C:
	tempo $6F
	echo $27 $3C $50
	echo_setup $05 $46 $02
	rest $14
	inst $0D
	...
	note $34 $0C $50 $5A
	note $39 . . $5A
	...
```

`at` is the ARAM address, `song` a header, `Lxxxx:` a label (any name
does), one statement per line, each exactly its bytes: the round trip is
exact (the ROM's hash checks it). The text was made by `python3
tools/spcseq.py totext`, which follows each channel from the headers like a
disassembler follows code; the bytes no channel reaches are `.byte` lines
(mostly an `end` after a `jump`), `.zero N` (the Konami logo's song is 331
bytes and 7,861 zeros), and in the songs of stages 2 and 5 `.org $4B00`,
the zeros up to the top-down intro, which the driver plays from that
address. Addresses are labels, so a sequence may change length; the song
must stay below `$5000` (`max=$2000`) and the intro at `$4B00`.
