# Sound driver (SPC700)

The program the sound CPU runs, `spc_driver` (uploaded to ARAM `$0200`;
see [Sound](sound.md#sound-cpu-memory) for the memory map), and the format
of the songs and sound effects it plays. The driver is SPC700 assembly,
`assets/sound/spc_driver.s`, and its sound effects are sequence text,
`assets/sound/spc_sfx.seq`, which the build assembles back to the original
bytes (see [The driver's source](#the-drivers-source)). It was read with
`tools/spc700.py` (an SPC700 disassembler: `python3 tools/spc700.py
build/assets/sound/spc_driver.bin 200 --trace 200 ...` follows the code
from the entry points given); the addresses below are ARAM addresses in
the driver. What is not said here is not worked out.

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
| `$7B` | jumps through the word at `$19FD` (`jmp [!$18FF+x]` with x = `$FE`, inside the code): not used |
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

`sound_table` (`$03E6`): 5 bytes per sound `$01`-`$73`: the channel mask,
the priority, the number of channels (bits 0-3; bits 4-7 set a per-channel
flag that makes notes carry no gate and volume, never set), and the
address of a list of one sequence address per channel (the sound's
header, `sound_NN` in `spc_sfx.seq`). `python3 tools/spcseq.py driver`
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
`$1B37`-`$2DAB` (`assets/sound/spc_sfx.seq`, see
[Sound effects as text](#sound-effects-as-text)). Sound `$58` has two
channels but its second sequence address is 0: the driver starts
channel 7 there anyway (the code that starts a sound does not check), so
it reads the driver's variables at ARAM `$0000` as a sequence. A sequence
that nothing reaches follows `$58`'s first one, much like it (another pan
and note, its own `call` into the shared part): probably the second
channel the header was meant to point at (`sound_58_ch1_unused`). Sound
`$1D`'s header has a second sequence address too (`sound_1D_ch1`, a
lower looping part), but the table gives `$1D` one channel, so it is
never played. Sounds `$31` and `$5F` share a header.

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
The address comes from the code `echo_setup` calls (`L11A1`, which
writes EDL and then ESA = `$00` - *d* x 8 pages, `asl a` three times,
`eor a, #$FF`, `inc a`, `adc a, #$00`); `tools/asset_limits.py`
(`echo_buffer`) reads that code and the largest delay of all the `.seq`
files, so the stage sample blocks' limit follows a song that changes its
delay (see [Assets: size limits](assets.md#size-limits)).

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

**Notes without gate and volume.** When the sound table's bits 4-7 of a
sound are not 0, the driver sets a flag on each of its channels (`$02C6`,
bit 0 of `$26` while the channel runs; `L1A01`) and the note reader
(`L0C8C`) takes a note as `n d` or `n+$80` only: no gate and no volume
byte follow. Such a note uses the gate set by `gate` (`$62`) or
`gate_volume` (`$64`) and the volume set by `volume` (`$63`) or
`gate_volume`; a duration 0 skips the note as above. Without the flag a
note always brings its volume, which replaces what `volume` set, so
`$63` only matters in this mode. No sound sets those bits and no sequence
uses `$63`, so it is never used; `tools/spcseq.py` decodes every note with
its gate and volume.

### Commands

| byte | name | operands | what |
|---|---|---|---|
| `$60` | `drums_on` | | notes play the drum table |
| `$61` | `drums_off` | | |
| `$62` | `gate` | g | the gate of the next notes |
| `$63` | `volume` | v | the volume of the notes in the mode without gate and volume (above); never used |
| `$64` | `gate_volume` | g v | both |
| `$E0` | `rest` | d | release the note, wait *d* |
| `$E1` | `tie` | d g | hold the note *d* longer, with gate *g* |
| `$E2` | `inst` | i | instrument (above) |
| `$E3` | `pan` | p | pan 0-20; `$15`: the instruments' pans are ignored from now on, `$16`: used again |
| `$E4` | `vibrato` | delay rate depth | vibrato from *delay* duration units into each note (see [Vibrato and pitch noise](#vibrato-and-pitch-noise)) |
| `$E5` | `pitch_noise` | rate mask-hi mask-lo | random upward jumps of the pitch, *rate*/256 of the ticks, by a table offset masked with the 16-bit mask (see [Vibrato and pitch noise](#vibrato-and-pitch-noise)) |
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
| `$F9` | `vibrato_fade` | time | the vibrato's depth grows from 0 to *depth* in *time* duration units (after the delay), by *depth*/*time* (16.16) per unit |
| `$FA` | `envelope` | a b decay | *a* < `$A0`: ADSR, attack *a* / 10 and decay *a* mod 10, sustain level *b* / 30 and rate *b* mod 30 + 2; else GAIN = *b*. *decay* x 16: when the gate time is over, instead of releasing the note, its volume falls by that much (in 256ths) per step, and the note is released at 0 |
| `$FB` | `pitch_mod` | m | PMON = *m* (pitch modulation of the voices in *m*) |
| `$FC` | `branch` | a1 a2 | go to *a1*; to *a2* if command `$82` set the driver's flag (cleared by channel 5 when it takes it) |
| `$FD` | `jump` | a | |
| `$FE` | `call` | a | one level: `end` returns |
| `$FF` | `end` | | return from a `call`, else the channel stops |

The operand counts are the driver's table at `$0E27` (the handlers' at
`$0DDD`), but for `branch`, which reads its second address when it uses
it.

### Vibrato and pitch noise

Pitches are in 256ths of a semitone (the note number times 256, plus the
tuning, transpose and detune); the driver adds these offsets to it before
it looks up the DSP pitch (`L1440`).

**Vibrato** (`vibrato delay rate depth`). A note starts its vibrato at
phase 0 and a duration counter at 0 (`L0D4A`); once the counter has
counted *delay* duration units (a unit is a step of the channel's tempo,
256 / (250 x *tempo*) s), the phase *p* (a byte, 256 to a cycle) grows by
*rate* per unit (`L0B83`), and in between, tick by tick, by
*rate* x *tempo* / 256 (`L0A6F`, the value `vibrato` precomputes at
`$0236`), so it moves smoothly. A cycle lasts 256 / *rate* units: the
vibrato's frequency is *rate* x *tempo* x 250 / 65,536 Hz (sound `$1D`,
rate `$96` at tempo `$8C`: 80 Hz). The waveform (`L13C5`) is a triangle:
*m* = *p* / 2 for *p* = 0-64, falling back to 0 at 128, the same downwards
for 128-255 (*m* at most 32); the offset is *m* x *depth* / 4 for a depth
below `$80`, *m* x *depth* from `$80` on, up and then down. So the
vibrato swings by *depth* / 32 semitones each way for a depth below
`$80` (`$64`: about 3 semitones) and by *depth* / 8 from `$80` on (`$FF`:
almost 32).

**Pitch noise** (`pitch_noise rate mask-hi mask-lo`). Every tick (250
per second) an accumulator grows by *rate*; on each tick it overflows
(*rate* / 256 of the ticks), the pitch of that tick is raised by the
word at `pitch_noise_16BC` + *i* (*i* = 0-255) or, for the next 256,
`pitch_noise_17BC` + *i*, *i* being a per-channel counter that
`pitch_noise` resets (`L13F5`; 512 offsets, then they repeat), ANDed
with the mask (in 256ths of a semitone: `$FA96` allows jumps of up to
250 semitones; the driver keeps 7 bits of the semitone, so they
wrap, some of them past the 96 notes of the pitch table). The other
ticks keep the plain pitch. Large masks make a noise of the instrument,
small ones a rough edge.

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

## The driver's source

`assets/sound/spc_driver.s` is the driver as SPC700 assembly, in the syntax
`tools/spc700.py` prints; `tools/spcasm.py` (a small assembler, standard
library only) assembles it, and the build compresses the result like any
asset (`asm=spc700` in the manifest; the source and the `.seq` it
includes are its dependencies). The text was made from the original
binary by `python3 tools/spcasm.py driver-totext BIN OUT.s OUT.seq`: the
code is what the trace reaches from `$0200` and from the two jump tables
(`seq_command_handlers`, `control_command_handlers`), everything else is
data, and the round trip is exact (the ROM's hash; `tests/test_sound.py`
also assembles every opcode as the disassembler prints it). In it:

| ARAM | what |
|---|---|
| `$0200` | `jmp driver_start` |
| `$0203`-`$03E5` | the variables (`.zero`) |
| `$03E6` | `sound_table`, one `.byte` mask, priority, channels and one `.word` header per sound: the label of the sound effect's header, `$3000` / `$4B00` for a song, 0 for an empty entry |
| `$0625` | `fade_speeds` |
| `$0628` | `instrument_sets` (`.word instrument_set_0` ...) |
| `$0636`-`$0895` | `instruments`, `instrument_set_0`, `drum_instruments`, `instrument_set_1` ... `instrument_set_6`: one `.byte` line of 8 per instrument, commented with its number (format in [Instruments](#instruments)) |
| `$0896`-`$1B36` | the code, with the tables it reads: `seq_command_handlers`, `seq_command_operands`, `fir_registers`, `fir_coefficients`, `pitch_table`, `pitch_noise_16BC`, `pitch_noise_17BC`, `control_command_handlers` and three unnamed blocks |
| `$1B37` | `.incseq "spc_sfx.seq"`: the sound effects |
| up to `$3000` | zeros (`.org $3000`) |

Branch and call targets are labels: `driver_start`, the handlers of the
sequence commands named after them (`seq_rest`, `seq_inst`, ... `seq_end`)
and of the control commands (`cmd_pause` ... `cmd_stop_all`), `Lxxxx`
elsewhere. Data operands are numbers (`mov a, !$0347+x`), or a table's name
where the operand is a table of the list above (`mov a,
!seq_command_handlers+1+y`); the variables are not named.

**The layout is fixed.** The code reads its tables at fixed addresses, and
not every reference is a label, so the code and the tables do not move: an
`.org` line precedes each table and each piece of code after data, and
assembling fails if what is before it has grown past it (`.org $0DDD, "the
code reads seq_command_handlers at $0DDD"`). A change to the code or a
table must keep its size (shrinking is fine: `.org` pads with zeros, and a
zero is `nop`). The instruments are edited in place (an instrument is its
8 bytes). The sound effects are the part that may change size.

`spcasm.py` syntax, besides the instructions: `label:`, `name = expr`,
`.org addr [, "why"]`, `.byte`, `.word`, `.zero n`, `.incseq "file"`;
expressions are `$hex`, decimal, `%binary`, labels, `*`, `+`, `-`, and
`<` / `>` for the low and high byte. `python3 tools/spcasm.py space
assets/sound/spc_driver.s` prints the room each `.org` leaves.

## Sound effects as text

`assets/sound/spc_sfx.seq` holds `$1B37`-`$2DAB`: the headers and sequences
of every sound that lives in the driver, in the songs' syntax (see
[Songs as text](#songs-as-text)), in their original order:

```
# sound $3E: an extra life (add_score)
sound_3E:
	song sound_3E_ch0
sound_3E_ch0:
	tempo $7D
	inst $00
	channel_volume $3C
	transpose $05
	note $30 $06 $65 $5A
	...
```

`sound_NN:` is the header of sound `$NN` (one `song` address per channel),
`sound_NN_chK` the sequence of its channel *K*, `Lxxxx` the other jump
targets. Every byte of the file is now a statement: the two sequences no
channel plays (`sound_1D_ch1`, `sound_58_ch1_unused`, see
[The sound table](#the-sound-table)) are written out too, so that their
addresses (`$1D`'s header word, the `call` in `$58`'s) are labels that
follow edits. The driver's source
includes the file at `$1B37` and `sound_table` points at the `sound_NN`
labels, so the two share their labels: a sound effect may grow or shrink,
the sounds after it move and the table follows. What is known of the
sounds from the code that queues them is in the comments (`$04` the default
gun, `$05` the laser, `$07` the crush gun, `$08` the homing gun, `$09` the
spread gun, `$0A` the flame thrower, `$3E` an extra life).

**Size limit.** The sound effects must end by `$3000`, where the song of
the set is uploaded: the `.org $3000` that follows them in the driver's
source stops the build otherwise (`.org $3000, but the bytes before it
reach $30xx: the sound effects must end before the song of the set`).
There are 596 bytes (`$254`) free; the driver asset as a whole keeps its
`max=$2E00` (`$0200`-`$2FFF`).

## Editing a sound effect

Edit `spc_sfx.seq` and run `make` (the ROM is then no longer the original:
`make` reports a `MISMATCH`). `python3 tools/sound_render.py SOUND` plays a
sound in the emulator (`make cores`): from power-on to the title screen, it
puts the command `$84` into the game's sound queue, waits half a second for
the title music to die away, then queues SOUND and records the audio from
its first sample. It prints how long the sound lasts, its median
zero-crossing rate (which follows the pitch: *n* semitones up multiply it
by 2^(*n*/12)) and its level every 0.1 s; `--wav OUT.wav` writes it,
`--against ROM` renders the same sound on a second ROM and prints the
ratios and whether the two are the same sample for sample.

An example, in a throwaway copy: the extra-life sound `$3E`, a fifth higher
(`transpose $05` to `$0C`, 7 semitones, x1.50), slower (`tempo $7D` to
`$50`, durations x1.56) and with one more, quieter repeat at the end
(`channel_volume $02`, `repeat`: 3 bytes more):

```
$ python3 tools/sound_render.py 3E --rom edited.sfc --against build/contra3.sfc
sound $3E on edited.sfc: 1.48 s, zero crossings 7509 Hz (median of the loud part)
  level every 0.1 s: 1962 1832 1727 1694 1604 1499 1394 1314 1293 1225 1144 327 325 308 286
sound $3E on build/contra3.sfc: 0.96 s, zero crossings 5106 Hz (median of the loud part)
  level every 0.1 s: 1966 1880 1717 1657 1588 1517 1398 332 319 306
length x1.54, zero crossings x1.47 (the first ROM against the second)
59694 of 96120 samples differ (see the note on timing: --help)
```

The 76 headers after it in the file moved by 3 bytes (sound `$43`'s
header from `$1E21` to `$1E24`, ... `$5C`'s from `$2D86` to `$2D89`) and
`sound_table` with them; the room before `$3000` went from 596 to 593
bytes. Rendered on both ROMs, the moved sounds `$43`, `$59` and `$6D` and
the unmoved `$04` last as long and have the same zero-crossing rate and
levels, but their samples are not all the same (`$04`: 9,152 of 96,120
differ, `$6D`: 2,556).

**Why two renders differ.** Not because the sounds moved: nothing in the
driver reads the sound effects by address (`sound_table` and every
pointer in `spc_sfx.seq` are labels, now including the two sequences no
channel plays), and the differences are as large for the unmoved `$04`.
They come from *when* the sound starts. The DSP steps the envelopes of
all voices on one counter that runs from power-on (an attack or decay
step falls on fixed samples, whatever the note), and takes key-ons every
other sample, while the driver writes pitches and volumes on its own
250 Hz ticks: a sound that starts at another moment has its envelope
steps and pitch changes a few samples apart. On the edited ROM the
driver is bigger, so its upload at boot takes longer and the driver's
ticks fall elsewhere relative to the game's frames; the same happens on
one ROM when the sound is queued one frame later (`$04` rendered at the
title and one frame later: about 10,000 samples differ; `$6D`, about
14,000). With 3 bytes of padding added after `$3E`'s sequence instead
(every later sound moved, nothing played differently), `$6D` happened to
come out the same sample for sample and `$04` again differed. The real
console does the same. So compare renders by their length, levels and
zero-crossing rate, not sample for sample; `sound_render.py` used to
start recording 4 frames after queueing the commands, which cut the
start of the sound at a point that depended on the timing too and mixed
in the end of the title music: it now waits for silence and starts at
the sound's first sample.
