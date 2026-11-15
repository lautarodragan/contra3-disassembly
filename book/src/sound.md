# Sound driver interface

The music and sound effects are played by a program running on the sound
CPU (SPC700), uploaded at boot. This page describes what the main CPU does
to talk to it (`src/sound/`); the driver itself and the music data (banks
`$1A`, `$1B`, `$1D`, `$1E`, `$1F`) are not disassembled yet.

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
the songs are numbered by the tables below.

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
