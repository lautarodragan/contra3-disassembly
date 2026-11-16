# Engine: frame flow, video and loading

This page describes the code in `src/engine/`: how a frame runs, how the
game talks to the PPU (shadows, the VRAM queue, palettes, HDMA), how
graphics are decompressed and loaded, how the side-view stages scroll, and
the math helpers. Each routine also has a header comment in the source.

## Boot

`reset` (`src/engine/reset.asm`) switches to native mode, sets the stack at
`$1DFF`, D = 0 and DB = `$05`, turns NMI off and blanks the screen. The
options area `$1E00-$1FFF` survives a reset when it holds
`boot_signature` (the 8 bytes `>JIN L<` + `$0400` at `$1E0A`); otherwise
(cold boot) it is cleared, the signature written and the option defaults
set. Either way the sound driver is uploaded (a type-2 data list, see
[Sound](sound.md)), then `warm_boot` runs. `warm_boot` is also where the
soft reset lands (L+R+Start+Select, then Select, checked by
`read_joypads` on the pads enabled in `soft_reset_pad_mask`): it clears
VRAM, `$0000-$1DFF`, the player blocks `$1F80-$1FFF` and `$7E:2000` to
`$7F:FFFF`, programs every PPU register (`init_ppu_registers`), resets the
VRAM queue, enables NMI (`start_display`, `nmi_mode` 0) and enters the main
loop.

The main loop does nothing but `service_song_set_request`: an upload of
music to the sound CPU requested with `request_song_set`, which can take
longer than a frame. **All of the game runs in the NMI.**

## The frame (NMI)

`nmi` (`src/engine/nmi.asm`) saves the registers, sets D = 0 and DB = `$05`,
copies `nmitimen_shadow`, `htime_shadow` and `vtime_shadow` to the
hardware, and calls the frame handler chosen by `nmi_mode` through
`tbl_nmi_frame_handlers`. If the previous frame's handler is still running
(`nmi_busy`), the NMI returns at once: the game slows down instead of
re-entering.

| `nmi_mode` | handler | used for |
|---|---|---|
| `NMI_MODE_DEFAULT` (0) | `nmi_frame_default` | menus, screens, loading |
| `NMI_MODE_SIDE_VIEW` (2) | `nmi_frame_side_view` | side-view stages |
| `NMI_MODE_TOP_DOWN` (4) | `nmi_frame_top_down` | top-down stages 2 and 5 |

Every handler has the same shape:

1. Vblank work, with the screen forced blank: scroll registers
   (`write_bg_scroll_regs`, or the latched values in the side view), the PPU
   register shadows (`write_ppu_shadows`: `bgmode_shadow`, `tm_shadow`,
   `m7a_shadow`, ...), OAM and palette DMA (`dma_oam_and_palette`: OAM from
   `$7E:0FC0`, CGRAM from `$7E:2200`), the VRAM queue (`run_vram_queue`),
   the loader's pending VRAM chunk (`dma_vram_loader_chunk`), HDMA set-up,
   and in the side view the HUD, the tilemap updates
   (`dma_bg_tilemap_updates`) and the window registers.
2. Brightness: `INIDISP` from `inidisp_shadow`, except while
   `force_blank_frames` is counting down (set to 4 whenever the display is
   switched on or off), which keeps the screen blank for a few frames.
3. The frame's logic: `read_joypads`, the game mode state machine
   (`run_game_mode`, see [Game flow](game-flow.md)), `next_random`,
   `run_palette_tasks`, `run_pending_loads`, `run_vram_tasks` and
   `send_queued_sound`.

The side view latches the horizontal scroll: `BG_HOFS_LATCH` (the previous
frame's `BG_X`) is what is written to `BGnHOFS`, so the scroll seen on
screen matches the tiles queued by the previous frame. The vertical scroll
subtracts the screen shake (`shake_bg1_y`).

Around loading, the game turns the display off and on with
`disable_display_and_nmi` / `enable_nmi` (or `wait_nmi_and_disable_display`,
which waits for the next NMI first), and `reset_video_state` resets
everything video-related between screens.

The IRQ (`irq`, also the COP/BRK/ABORT vector) only serves the two-player
split screen of the top-down stages: `irq_mode` selects
`irq_mode7_top_view` (player 1's Mode 7 matrix) and, from line `$70`,
`irq_mode7_bottom_view` (player 2's).

## The VRAM queue

Code that wants to change VRAM during the frame queues DMA transfers in
`$7E`, and `run_vram_queue` executes them in the next NMI
(`src/engine/vram.asm`). Entries are 11 bytes from `VRAM_QUEUE`
(`$7E:3000`) to `vram_queue_end`: VMAIN, DMAP/BBAD, VRAM address, source
(long) and size. The data normally goes to the buffer at `VRAM_QUEUE_DATA`
(`$7E:3400`):

```
    ldy  #$5800                     ; the word address in video memory
    jsl  f:begin_vram_transfer      ; open an entry (begin_vram_transfer_vmain: A = VMAIN)
    lda  #$2041                     ; a tilemap word
    jsl  f:push_vram_word           ; append data (repeat)
    jsl  f:end_vram_transfer        ; set the entry's size
```

`draw_text` / `draw_text_attr` write strings through the queue. A string
is a VRAM address word followed by tile numbers; `$FD n` changes the
attribute byte, `$FE` starts a new line at the address that follows, `$FF`
ends it; with `text_erase` set the string is erased instead.

Other per-frame VRAM traffic: `run_vram_tasks` (timed lists of queue
entries), the HUD (`upload_p1_hud`), the stage tilemap updates
(`dma_bg_tilemap_updates`) and the loader.

## Palettes

The colours live in WRAM: the 512-byte buffer at `$7E:2200`
(`cgram_dma_src`) is copied to CGRAM every frame. Palette changes are
*palette tasks*: 8 slots of `$10` bytes at `palette_tasks` (fields
`TASK_TYPE`, `TASK_SCRIPT`, `TASK_PROGRESS`, `TASK_ENTRY`, `TASK_DELAY`),
started with `start_palette_task` (script in Y, its first byte is the type)
and run by `run_palette_tasks`:

| type | handler | what |
|---|---|---|
| 1 | `palette_task_animate` | copies a list of palette blocks from bank `$08`, one every *delay* frames, a number of times or forever |
| 2 | `palette_task_darken` | darkens a range step by step (never used) |
| 3 | `palette_task_fade_in` | fades a palette in from black (`fade_palette_from_source`) |
| 4 | `palette_task_fade_out` | fades it out to black |

A fade subtracts the level (0-31) from each 5-bit component of the source
colours; the level moves by *speed*/16 per frame.

In the side view, a 32-byte palette can also be uploaded at a given CGRAM
address (`cgram_upload_addr`, `cgram_upload_addr2`, `cgram_upload_src`).

## Loading and decompression

Graphics, tilemaps and sound data are loaded through *data lists* in bank
`$05` (`load_data_list`, `src/engine/gfx_loader.asm`). A list starts with a
type byte and a flags byte and names streams compressed in the game's
format:

| type | destination | entry |
|---|---|---|
| 0 | VRAM (`load_vram_list`) | VRAM word address, stream |
| 1 | WRAM (`load_wram_list`) | destination (long), stream |
| 2 | sound CPU (`load_spc_list`) | SPC address, stream; or `$FFFE` + a raw block |
| 3+ | one byte of each VRAM word (`load_vram_byte_list`) | as type 0 |

Each type has a *loader context* (`LOADER_VRAM` = `$1300`, `LOADER_WRAM` =
`$1340`, `LOADER_SPC` = `$1F00`) and a 1 KiB ring buffer in `$7E`; the
loader and the decompressor run with the direct page register D pointing at
the context, so their direct-page operands are the `LDR_*` fields
(`LDR_LIST`, `LDR_RING_POS`, `LDR_STATE`, ...).

A list with flags bit 0 clear is loaded at once, with the display off. With
bit 0 set it is *deferred*: `run_pending_loads` decompresses `$80` bytes per
frame (`decompress_chunk`) while the game runs, and the VRAM chunks are
DMAd in the next NMI (`dma_vram_loader_chunk`). This is how a stage loads
the next part of its graphics without stopping.

The decompressor (`src/engine/decompress.asm`) is an LZ77 variant whose
window is the ring buffer itself; it can stop after any byte and resume
(`LDR_STATE`). A stream starts with its length (a word); then, with
n = (command & `$1F`) + 2:

| command | meaning |
|---|---|
| `$00-$7F` | copy (command >> 2) + 2 bytes from ring position (((command & 3) << 8 \| next byte) + `$21`) & `$3FF` |
| `$80-$9F` | command & `$1F` literal bytes follow |
| `$A0-$BF` | n pairs: a zero, then a literal byte |
| `$C0-$DF` | n copies of the next byte |
| `$E0-$FF` | n zeros |

[Compression](compression.md) has the format in detail and the compressor
that reproduces the ROM's streams (`tools/c3lz.py`).

## Side-view scrolling

`src/engine/bg_scroll.asm`. BG1 (the playfield) and BG2 (the background)
each have a scroll state of `$40` bytes: BG1 at `bg1_x` (`$1380`), BG2 at
`bg2_x` (`$13C0`), with the fields `BG_X`, `BG_Y`, `BG_X_DELTA`,
`BG_Y_DELTA`, `BG_PAGE`, `BG_MAP_OFFSET`... The layers' maps are in `$7E`,
made of metatiles of 4x4 tiles (BG1: map at `$7E:9000`, metatiles at
`$7E:5000`; BG2: map at `$7E:F000`, metatiles at `$7E:B000`; decompressed
there by the stage's load list, e.g. `stage1_bg1_map` and
`stage1_bg1_metatiles`, see [Assets](assets.md#wram-streams-of-bank-7e)); when the scroll crosses a tile column or
row, `draw_bg_column` / `draw_bg_row` queue the tiles that enter the screen,
and `update_bg_collision_map` turns the same tiles into the collision map
at `$7E:4000` (one word per tile, the class chosen by tile-number
thresholds; see [Side-view collision map](collision.md)).

Every frame the stage code calls `run_bg1_scroll_mode` and
`run_bg2_scroll_mode`, which dispatch on `bg1_scroll_mode` and
`bg2_scroll_mode`:

- BG1 (`tbl_bg1_scroll_modes`): `bg1_init_horizontal` /
  `bg1_scroll_horizontal` (follow a player who passes `scroll_threshold`,
  or autoscroll with `bg1_autoscroll`), `bg1_init_vertical` /
  `bg1_scroll_vertical` (upwards), `bg1_scroll_stop`, ...
- BG2 (`tbl_bg2_scroll_modes`): parallax at 1/8 of BG1 horizontally
  (`bg2_parallax_x_1_8`), 1/3 vertically (`bg2_parallax_y_1_3`), 1:1
  (`bg2_follow_bg1_x`), autoscroll (`bg2_autoscroll_x`), or drawing a
  whole screen progressively (`bg2_start_draw_screen`).

`bg1_x_delta` and `bg1_y_delta` (the movement of this frame) are what the
object loop subtracts from objects that move with the background.

The stage's enemies are placed as BG1 scrolls (`init_stage_spawns`,
`spawn_stage_objects`): per 256-pixel page, a list of 10-byte entries
{position in the page, type, slot range, x, y, parameter}; an entry is
spawned when the scroll position reaches it, into a free slot of its range
(`find_free_object_slot_in_range`).

## HUD and HDMA

The HUD (lives, weapons, bombs of each player) is a BG3 tilemap buffer at
`hud_buffer` (`$1700`), built by `init_hud`, updated by `update_p1_hud` /
`update_p2_hud` and DMAd by `upload_p1_hud` / `upload_p2_hud`
(`src/engine/hdma.asm`). `init_hud` copies its rows from
`hud_p1_top_template`, `hud_p1_bottom_template` and the player 2 pair
(each label sits 2 bytes before its row: the copy loop counts X from `$20`
down to 2).

HDMA: `setup_hdma_channels` (menus) and `setup_stage_hdma` (side view)
program the channels from the preset `hdma_preset` (`ptrs_hdma_presets`); the side view adds the
window and colour-math channels. `build_scroll_split_hdma` builds tables
that split the screen in horizontal bands with their own scroll
(`scroll_split_pattern`, `scroll_split_y`).

## Math

`src/engine/trig.asm` (bank `$1D`): angles are bytes, 0 = up, `$40` right,
`$80` down, `$C0` left. `calc_angle` (vector to angle, with `atan_table`),
`polar_to_xy`, `set_velocity_from_angle` (an object's velocity from its
angle and a speed), `calc_distance` and `half_distance_squared`. The sine
tables (`quarter_sine`, `quarter_cosine`) hold a quarter wave, value x 256.
Bank `$05` has more: `half_turn_sine` (256 words, half a turn, value x
`$FFFF`, for the unused Mode 7 matrix routine, the wavy ruins and one
object), `circle_chord_widths` (the window circles), `td_boss_sine` /
`td_boss_cosine` (bytes, for `project_around_stage2_boss`) and
`td_distance_table` (distance for dx, dy up to 15).
`next_random` (`src/engine/random.asm`) is a 32-bit shift-register
generator in `rng_lo` / `rng_hi`, stepped once per frame.
