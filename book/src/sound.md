# Sound driver interface

The music and sound effects are played by a program running on the sound
CPU (SPC700), uploaded at boot. This page describes what the main CPU does
to talk to it (`src/sound/`) and what it uploads where in the sound CPU's
memory (ARAM); the driver's own code is not disassembled into `src/` (it
is the asset `assets/sound/spc_driver.s`, SPC700 assembly that
`tools/spcasm.py` assembles, with its sound effects as text in
`assets/sound/spc_sfx.seq`; see [Sound driver](sound-driver.md)).

## Commands

Everything the game asks of the driver is a one-byte *command* written to
`APUIO0`; the driver acknowledges a command by echoing it back on `APUIO0`.

- `queue_sound` (A = command) appends a command to a ring of 256 bytes at
  `sound_queue` (`$0100`, indexes `sound_queue_write` / `sound_queue_read`).
  The same command queued twice in a frame is dropped
  (`sound_last_queued`, cleared by every NMI frame handler); on overflow the
  oldest command is lost.
- `send_queued_sound`, once per frame at the end of the NMI, sends the next
  command once the driver has echoed the previous one
  (`apu_pending_cmd`). So at most one command reaches the driver per frame.
- `send_sound_command_now` sends a command at once and waits for the echo
  (used to start a song right after loading it); `reset_sound_queue`
  empties the queue and queues `SOUND_CMD_STOP` (`$84`), which the game
  sends before every change of screen and before uploads: it stops all
  sound (by its use).

Sound effect and music numbers are listed with the code that queues them;
the songs are numbered by the tables below. What the driver does with
each command is in [Sound driver: commands](sound-driver.md#commands).

## Uploads

The driver and the music are uploaded with the protocol of the sound CPU's
IPL ROM (`src/sound/spc_upload.asm`): the address of a block goes on
`APUIO2/3`, then each byte on `APUIO1` with a counter on `APUIO0` that the
sound CPU echoes; the last block's address is sent with `APUIO1` = 0 and the
sound CPU jumps there. What is uploaded is described by a *data list* of
type 2 (see [Engine: loading](engine.md#loading-and-decompression)): raw
blocks (`upload_spc_raw_block`) or compressed streams decompressed on the
fly (`upload_spc_compressed_block`).

- At boot, `reset` uploads the driver from the IPL ROM state
  (`load_spc_list`, after `spc_ipl_handshake`).
- Later uploads replace the *song set*: the music and samples of a stage
  or screen. `load_song_set` (X = list) stops the driver
  (`SOUND_CMD_STOP`), sends `SOUND_CMD_UPLOAD` (`$FF`), after which the
  driver takes a new transfer itself (`start_song_set_upload`), and uploads
  the list; `apu_pending_cmd` is `$FF` meanwhile so that no command is sent.
  It runs inside the NMI, so the game stops while it uploads.
- `request_song_set` stores the list in `pending_spc_list` instead; the main
  loop (`service_song_set_request`) uploads it while the NMI keeps running
  the game.

`load_stage_music` loads song set number `stage_number` and sends its start
command: song *k* has its list at `song_lists` + 2*k* and its start command
at `song_start_commands` + 2*k*. The sound check screen
(`sound_check_play`) uses the same tables.

## Unused streaming code

`unused_spc_stream_list` ... `unused_check_spc_busy` (in
`src/sound/sound_load.asm`) have no caller and never ran in the traces. They
implement a second protocol on `APUIO2/3` (a `$AABB` / `$A0B0` handshake, an
address, then bytes tagged with a 7-bit counter) to send data to the driver
while it plays, with a request/status scheme in the `LOADER_SPC` context
(`LDR_SPC_STREAM_STATUS`, `LDR_SPC_STREAM_ON`), `sound_stream_check_index` and `sound_cmd_override`.

## Sound CPU memory

What the upload lists put where (the `load_spc` / `load_spc_raw` entries
of the `song_set_` lists in `src/data/tables_05.asm`), checked in the
emulator: the sound CPU's 64 KiB, read from a save state of the snes9x
core (its `SND:` block starts with them), held each uploaded block at its
address at the start of every stage, and the driver at `$0200` after boot.

| ARAM | what |
|---|---|
| `$0000`-`$00EF` | the driver's variables (direct page) |
| `$00F0`-`$00FF` | the sound CPU's I/O registers (DSP address/data, timers, ports) |
| `$0100`-`$01CF` | variables (`$0100`-`$018E`) and the stack (from `$01CF` down) |
| `$0200`-`$2FFF` | the driver, `spc_driver` (uploaded at boot); `$2DAC`-`$2FFF` are zeros, the room the sound effects may grow into |
| `$3000`-`$4FFF` | the song of the current song set (`spc_song_`), at most `$2000` bytes |
| `$5000`-`$50FF` | the sample directory (`spc_sample_dir_`), DSP register DIR = `$50` |
| `$5100`-`$B08D` | the samples every set shares, sources 0-19 (`spc_samples_common`, uploaded at boot) |
| `$B08E`-`$D78A` | the samples of the current stage, sources 20-23 (`spc_samples_` of the stage) |
| top of ARAM | the echo buffer: the driver sets ESA to `$10000` - EDL x `$800` |

Inside the driver (`spc_driver`, loaded at `$0200`): `$0200` jumps to the
start-up code at `$0896`; `$0203`-`$03E5` are variables (zeros in the
file, cleared again at start-up); `$03E6`-`$0895` are tables (sounds,
instruments); `$0896`-`$1B36` is code with a few tables in it; `$1B37`-`$2DAB`
are the sequences of the sound effects and of the songs that live in the
driver (`assets/sound/spc_sfx.seq`). The [Sound driver](sound-driver.md)
page describes the driver, its source, its commands, instruments and the
format of the songs and sound effects, which are text files
(`assets/sound/spc_song_stage1.seq` ...).

### The blocks

Every song set is a list of type 2; the game loads one with
`load_song_set` or `request_song_set` (see [Uploads](#uploads)). At boot,
`reset` loads `song_set_boot`: the driver, the boot directory and the
common samples. The stage song sets replace the directory, the stage
samples and the song; the others replace only the song (the stage's
directory and samples stay):

| list | `$5000` directory | `$B08E` samples | `$3000` song | used by |
|---|---|---|---|---|
| `song_set_boot` | `spc_sample_dir_boot` | (`$5100`: `spc_samples_common`) | (`$0200`: `spc_driver`) | `reset` |
| `song_set_opening` | `spc_sample_dir_opening` | `spc_samples_opening` | `spc_song_opening` | stage 0 (the opening cinematic) |
| `song_set_stage1` | `spc_sample_dir_stage1` | `spc_samples_stage1` | `spc_song_stage1` | stage 1 |
| `song_set_stage2` | `spc_sample_dir_stage2` | `spc_samples_stage2` | `spc_song_stage2` | stage 2 |
| `song_set_stage3` | `spc_sample_dir_stage3` | `spc_samples_stage3` | `spc_song_stage3` | stage 3 |
| `song_set_stage4` | `spc_sample_dir_stage4` | `spc_samples_stage4` | `spc_song_stage4` | stage 4 |
| `song_set_stage5` | `spc_sample_dir_stage5` | `spc_samples_stage5` | `spc_song_stage5` | stage 5 |
| `song_set_stage6` | `spc_sample_dir_stage6` | `spc_samples_stage6` | `spc_song_stage6` | stage 6 |
| `song_set_boss` | | | `spc_song_boss` | the bosses of stages 1 and 3 |
| `song_set_boss_full` | `spc_sample_dir_stage6` | `spc_samples_stage6` | `spc_song_boss` | the stage 2 boss (`load_stage2_boss_assets`); sound check |
| `song_set_heart_boss` | | | `spc_song_heart_boss` | `heart_boss_state_05` |
| `song_set_heart_boss_full` | `spc_sample_dir_stage6` | `spc_samples_stage6` | `spc_song_heart_boss` | sound check |
| `song_set_ending` | | | `spc_song_ending` | `ending_sequence_state_18` |
| `song_set_ending_full` | `spc_sample_dir_stage6` | `spc_samples_stage6` | `spc_song_ending` | sound check |
| `song_set_stage_clear` | | | `spc_song_stage_clear` | the stage clear screen |
| `song_set_stage_clear_full` | `spc_sample_dir_stage3` | `spc_samples_stage3` | `spc_song_stage_clear` | sound check |
| `song_set_game_over` | | | `spc_song_game_over` | the game over screen |
| `song_set_game_over_full` | `spc_sample_dir_stage3` | `spc_samples_stage3` | `spc_song_game_over` | sound check |
| `song_set_konami_logo` | | | `spc_song_konami_logo` | the Konami logo (`game_mode_konami_logo`) |
| `song_set_konami_logo_full` | `spc_sample_dir_stage3` | `spc_samples_stage3` | `spc_song_konami_logo` | sound check |

The stage of a stage set is its place in `song_lists`
(`load_stage_music` uses entry `stage_number` + 1), checked in the
emulator (ARAM at the start of each stage). The `_full` sets also load
a directory and samples; only the sound check (and the stage 2 boss) use
them, to have samples that suit the song whatever was loaded before.
`spc_sample_dir_boot` is the same 256 bytes as `spc_sample_dir_stage3`.
The songs of stages 2 and 5 end with the same `$2CB` bytes (from `$4B00`):
a second song, the top-down stages' intro (sound `$6F`, queued by
`intro_init`).

Three lists of type 0 that nothing uses (`unused_load_list_05D0C3` ...)
point at song streams with VRAM address `$3000`: probably song sets whose
type byte was changed.


## Samples

The DSP plays *BRR* samples: blocks of 9 bytes, a header byte (bits 4-7
shift, bits 2-3 filter, bit 1 loop, bit 0 end) and 16 samples of 4 bits.
A voice plays a *sound source*: entry *n* of the sample directory (at
DIR x `$100` = `$5000`) is two words, the address of the sample and the
address its loop starts at; at the block with the end bit the voice jumps
to the loop address if the loop bit is set, else it stops.

Contra III uses 24 sources: 0-19 are the samples of
`spc_samples_common`, uploaded once at boot, and 20-23 the four samples
of the current stage (the `$B08E` block of the stage's song set). Each
directory holds the same entries 0-19 and its stage's 20-23; entries 24-63
are zeros; stages 2 and 4 have no source 23 (`$FFFF`, `$FFFF`). In both
blocks the samples follow each other in source order with no gap, each
ending at its block with the end bit, so the directory gives every
sample's bounds.

The 16 blocks of samples and directories are made by the build from 30
files, one per sample: `assets/sound/samples/<bank>-<source>.brr`,
the BRR bytes of the sample as they are in ARAM (no header). A sample
used by several blocks is stored once, under the first bank and source
that has it (`common-00.brr` is also source 20 of stage 6 and source 21 of
the opening and of stage 3). A *sample list*,
`assets/sound/spc_samples_<bank>.txt`, gives a block's samples:

```
at $B08E
20  opening-20.brr   0
21  stage2-21.brr    2025
22  stage2-22.brr    4707
23  -
```

`at` is the address the block is uploaded to (the address of its
`load_spc_raw` entry), then one line per source: its number, the sample,
and where its loop starts, in bytes from the sample's start (a multiple of
9; 0 for the samples that do not loop). The manifest makes each block from
its list (`brr=list`) and each directory from the common list and the
stage's (`dir=sound/spc_samples_common,sound/spc_samples_stage1`;
`spc_sample_dir_boot` from the common list and stage 3's). The upload
lists give the size of a block as `<label>_size`, set after its include
(as is the size word the ROM keeps before each uncompressed block), so a
block may change size.

`tools/brr.py` builds them (`split` is how the files were cut from the
blocks), and `make assets-check` runs `python3 tools/brr.py check`: the
blocks and directories the build makes, cut again, give the same files and
lists. With the ROM's hash check, that is a round trip in both directions.

**Listening.** The [Sound samples](sound-samples.md) page has every
sample as a WAV, as the DSP plays it at pitch `$1000` (`python3
tools/brr.py wav DIR` writes them; `make book` does it for the book).
`tools/brr.py` decodes a sample as the DSP does, which
`tests/test_brr_dsp.py` checks against snes9x's DSP itself (blargg's
`SPC_DSP.cpp` from the core's source, compiled alone, `make cores`): six
samples (looped and not, every filter) on a voice at pitch `$1000`, and
the decoded samples are the DSP's sample for sample (all 30 samples were
compared once). The DSP does not output its decoded samples as they are,
though: every voice goes through its Gaussian interpolation, which at
pitch `$1000` mixes each sample with its neighbours (370, 1305 and 374
2048ths: a low-pass, about -11 dB at 16 kHz). The first WAVs left that
out and sounded brighter than the game; `gaussian()` now applies it, and
the test checks the voice's output (after GAIN and volumes) against it
too, sample for sample.

**Editing a sample.** Replace its `.brr` file with BRR data and run
`make`. There is no WAV to BRR encoder here: BRR encoding is lossy (an
encoder chooses a filter and a shift for each block), so a WAV cannot be
turned back into the bytes it came from, and an edited sound must be
encoded with a BRR encoder such as BRRtools (`brr_encoder`). The file
must be a whole number of blocks, with the end bit in the last block only,
and the loop bit there if it loops; set its loop start in the lists that
use it. A sample that grows moves the samples after it, and their
directory entries follow. The limits of the manifest (`max=`, see
[Assets: size limits](assets.md#size-limits)) keep the common samples
below `$B08E`, where the stage samples start, and the stage samples below
`$D800`, where the echo buffer starts (`max=$2772`), both derived from the
source: the second from the driver's code that sets the echo buffer's
address and the largest echo delay of the sequences (see
[Sound driver: echo](sound-driver.md#echo)).
