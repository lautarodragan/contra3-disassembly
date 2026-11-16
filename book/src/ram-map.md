# RAM map

All RAM names are in `src/ram.inc`, included by `src/common.inc`. The first
pass (milestone 2) replaced RAM operands by symbols mechanically, with the
CDL: every variable the code addresses directly has a symbol, most of them
still a placeholder named by its address (`zp_00`-style for the direct page,
`wram_13CE`-style for `$0100-$1FFF`, `wram_7EA000`-style above `$7E:2000`).
The header of `src/ram.inc` lists exactly what was converted and what was
left as a number on purpose; in short:

- indexed operands (`lda $10,x`, `lda a:$1304,x`) are left as numbers: they
  are mostly fields of the structure that X or Y points to (an object slot,
  a player), and naming them as absolute addresses would be wrong;
- direct-page operands of instructions that ran (or may run) with the direct
  page register D other than 0 are not variables: in the loader and
  decompressor (`src/engine/gfx_loader.asm`, `src/engine/decompress.asm`,
  `src/sound/`) D points at a loader context (`LOADER_VRAM` = `$1300`,
  `LOADER_WRAM` = `$1340`, `LOADER_SPC` = `$1F00`) and the operands are its
  fields (`LDR_*` constants); the comment on the line gives the address
  really accessed.

## Named variables

These names were checked in the code (the routine named in the comment, or
the ones in the lead's notes confirmed by the code):

| name | address | meaning |
|---|---|---|
| `joy1_held` | `$20` | joypad 1 buttons held (written by `read_joypads`; pads 2-4 at $22/$24/$26) |
| `joy2_held` | `$22` | joypad 2 buttons held |
| `joy1_pressed` | `$28` | joypad 1 buttons newly pressed this frame (pads 2-4 at $2A/$2C/$2E) |
| `joy2_pressed` | `$2A` | joypad 2 buttons newly pressed this frame |
| `game_mode` | `$32` | game mode, index into tbl_00A38A (sub_00A377) |
| `game_submode` | `$34` | sub-mode of the current game mode (each mode dispatches it through its own table) |
| `frame_counter` | `$3A` | incremented by sub_00A377 every frame |
| `nmi_busy` | `$3C` | non-zero while the NMI frame handler runs (re-entry guard in nmi) |
| `nmi_mode` | `$42` | NMI frame handler, x2 index into `tbl_nmi_frame_handlers`: 0 menus/screens, 2 side-view stages, 4 top-down stages (`NMI_MODE_*` constants) |
| `sound_queue_read` | `$54` | read index of `sound_queue` (`send_queued_sound`) |
| `sound_queue_write` | `$56` | write index of `sound_queue` (`queue_sound`) |
| `sound_last_queued` | `$5C` | last command queued by `queue_sound` this frame (repeats are dropped) |
| `stage_index` | `$70` | stage number - 1 (0-5), set from stage_number in normal play and in the demo; indexes per-stage tables such as tbl_00AC2A |
| `difficulty` | `$84` | difficulty x2: 0 easy, 2 normal, 4 hard (copied from $1E3E) |
| `stage_number` | `$86` | stage number, 1-6 |
| `rng_lo` | `$E8` | random number generator state, low word (`next_random`) |
| `rng_hi` | `$EA` | random number generator state, high word |
| `oam_hi_bits` | `$9C` | OAM high-table bits being packed by `draw_metasprite` / `draw_shot` |
| `shake_bg1_y` | `$A0` | screen shake: subtracted from BG1 VOFS and added to sprites' y (`update_shake_side_view`) |
| `shake_bg2_y` | `$A2` | screen shake of BG2 (half of `shake_bg1_y`) |
| `target_list_end` | `$AA` | end of the list of shot targets at `$15A0`, built by `update_objects` |
| `oam_ptr` | `$AC` | next free entry of the OAM buffer (`$0FC0`) |
| `oam_hi_ptr` | `$AE` | next byte of the OAM high table (`$11C0`) |
| `sound_queue` | `$0100` | ring of 256 commands for the sound CPU (`queue_sound`, `send_queued_sound`) |
| `player1_obj` | `$0200` | player 1 object ($40 bytes; player 2 at $0240) |
| `player1_state` | `$0212` | player 1 object field +$12, state |
| `player2_obj` | `$0240` | player 2 object ($40 bytes) |
| `player2_state` | `$0252` | player 2 object field +$12, state |
| `stage_progress` | `$13BD` | stage progress counter |
| `shake_continuous` | `$1660` | non-zero: 1-pixel screen shake until cleared |
| `shake_timer` | `$1662` | screen shake amplitude, counted down every 16 frames |
| `update_objects_stop` | `$166A` | slot where `update_objects` stops |
| `title_menu_cursor` | `$1E02` | title menu choice; also read during play as 1 player (0) / 2 players (1) |
| `demo_index` | `$1E48` | attract demo index |
| `nmitimen_shadow` | `$1E82` | written to NMITIMEN by nmi and irq |
| `htime_shadow` | `$1EC0` | written to HTIMEL/H by nmi |
| `vtime_shadow` | `$1EC2` | written to VTIMEL/H by nmi |
| `p1_weapon_slot` | `$1F80` | player 1 active weapon slot (player 2: $1FC0) |
| `p1_weapon_1` | `$1F84` | player 1 weapon (`WEAPON_*`) of the first slot, fired when `p1_weapon_slot` = 2 |
| `p1_weapon_2` | `$1F86` | player 1 weapon of the second slot, fired when `p1_weapon_slot` = 0 |
| `p1_barrier_timer` | `$1F88` | player 1 barrier (invincibility) timer |
| `p1_lives` | `$1F8A` | player 1 lives |
| `p1_bombs` | `$1F8C` | player 1 smart bombs |
| `p1_spin` | `$1F8E` | 1 while L+R are held or in the spin jump: both weapons fire |
| `p2_weapon_slot` | `$1FC0` | player 2 active weapon slot (by the $40 stride of the player blocks) |
| `p2_weapon_1` | `$1FC4` | player 2 weapon of the first slot |
| `p2_weapon_2` | `$1FC6` | player 2 weapon of the second slot |
| `p2_barrier_timer` | `$1FC8` | player 2 barrier (invincibility) timer |
| `p2_lives` | `$1FCA` | player 2 lives |
| `p2_bombs` | `$1FCC` | player 2 smart bombs |
| `p2_spin` | `$1FCE` | player 2, as `p1_spin` |

`stage_index` (`$70`) had been noted as the attract-demo stage; the code
sets it to `stage_number - 1` both in normal play (`game_mode_stage_card`) and in the
demo (`game_mode_stage_play`), and `tbl_stage_runners` uses it to choose between the
side-view and the top-down stage code, so it is the 0-based stage number.

## Structures

The main object list has slots of `$40` bytes from `$0200` (players at
`$0200` and `$0240`); the player shots are a second list of 40 slots of
`$20` bytes at `$0AC0`. Code reaches a field with X holding the slot
address, so the field offsets appear as direct-page numbers (`lda $12,x`).
`src/ram.inc` defines them as constants (`OBJ_*`, `PLAYER_*`, `SHOT_*`),
applied where the index register was checked to hold a slot; the players
also have fields at slot + `$1300` and a stat block at slot + `$1D80`, so
`p1_lives` (`$1F8A`) also appears as `lda a:PLAYER_LIVES,x` with X =
`$0200`. See [Objects](objects.md) for the layout.

Code that reads or writes a fixed slot directly (a boss and its parts,
the stage 1 tank in slot 31, the ending's missile in slot 2) addresses
`obj_slots + n*OBJ_SIZE + field` (`obj_slots` = `$0200`, so slot n is at
`$0200 + n*$40`): for example `obj_slots+31*OBJ_SIZE+OBJ_HP` is `$09C6`.
The player slots are written `player1_obj+field` / `player2_obj+field`.
Offsets `$30-$3A` have no common meaning and stay numbers (`+$32`).

The top-down stages lay the same RAM out differently (see
[Top-down stages](topdown.md)); their direct accesses use the bases
`td_arrow_objs` (`$0200`, the target arrows), `td_enemy_shots` (`$0300`),
`td_p1_shots` (`$0480`), `td_p2_shots` (`$0700`) with `SHOT_SIZE` slots,
and `td_items` (`$0980`), `td_map_objects` (`$0AC0`), `td_enemies`
(`$0D40`), `td_p1_obj` / `td_p2_obj` (`$0EC0` / `$0F00`), `td_p1_bomb` /
`td_p2_bomb` (`$0F40` / `$0F80`) with `OBJ_SIZE` slots. The common fields
(`OBJ_ANGLE`, the position, `OBJ_TYPE`, `OBJ_STATE`, the velocity) keep
their `OBJ_*` names; the others stay numbers. The OAM buffer is
`oam_buffer` (`$0FC0`, 4 bytes per sprite) and `oam_hi_table` (`$11C0`).

When you name a variable, rename its placeholder everywhere (src/ and book/), add
it to the table above with how you know, and update its comment in
`src/ram.inc`.

## Game flow variables

The variables of the game modes (`mode_result`, the per-mode work area
`mode_work` and its aliases), the options (`option_lives`, `option_level`,
`option_sound`), scores (`p1_score`, `high_score`, `p1_next_extend`),
`continues_left`, `stage_state`, `stage_layout`, `stage_checkpoint` and
the opening's state are listed with their meaning in `src/ram.inc`; how
they are used is in [Game flow](game-flow.md).

## Object variables

Besides the object slots, the object handlers use `song_change_state`,
`song_change_mode`, `song_change_set`, `song_change_wait` (music changes,
`update_song_change`), `boss_work_0`-`boss_work_7` (`$1636-$1645`: work
variables of the big scripted object of the moment: stage 1 boss, spiked
climber, ending...), `tank_driver` (stage 1 tank) and `trail_buffers_used`
(which `$7E:E000` ring buffers trail chains use).

Other side-view stage variables: `respawn_mode` (how player state `$0F`
places a player, from `stage_respawn_modes` and changed by triggers),
`clamp_player_top` (keeps the players below the top in vertical
autoscroll), `clear_enemies_timer` (frames during which enemies destroy
themselves when a boss appears or dies), `spawn_disabled` (stops
`spawn_stage_objects`), `homing_target_slot` (round robin of the homing
missile), `hang_lock_buttons`, `bomb_coldata_mask` / `bomb_coldata_bits`
(colour of the bomb window), `sound_throttle_timer`
(`queue_sound_throttled`), `boss_hit_sound_timer`; the stage 1 tank's
`tank_moving` / `tank_move_dx`; the stage 4 airship section's
`bg1_vel_x` ... `bg1_moved_y` and `airship_spawn_index`; the ending's
`ending_arm_lengths`; the work variables of object type `$06`
(`obj06_map_ptr` ...); and the debug leftovers `debug_coldata`,
`debug_window_test`.

## Top-down stage variables

The Mode 7 view of each player (`p1_m7_center_x` ... `p1_view_brightness`,
in the player stat blocks), the per-player top-down blocks at `$1500` /
`$1540` (`p1_view_x`, `p1_start_x`, `p1_td_joy_held` ...) and the state
variables (`topdown_state`, `topdown_map`, `intro_step`, `map_view_step`)
are described in [Top-down stages](topdown.md), with the boss variables
(`boss_anim_frame`, `boss_target_player`, `stage5_boss_spit_step` ...)
the view controls `p1_view_angle_frozen` / `p1_facing_in_view` (and
player 2's), the map view's saved brightness (`map_view_saved_inidisp` ...),
and the fields of fixed slots read directly (`td_p1_x`, `td_p1_hp`,
`td_boss_hp`, `td_boss_core_hp` ...). The top-down stages reuse
`$1780-$17FF` and `$1800-$1867` differently from the side-view stages,
so each use has its own base: in the side view `player_tile_src` (`$1780`,
the sources of the player tiles DMAd this frame, with
`player_tiles_vram_top` / `player_tiles_vram_bottom`), `vram_block_queue`
(`$1800`, 8 tile blocks of 4 VRAM row addresses, `vram_block_queue_end`)
and `vram_block_src` (`$1840`); in the top-down stages `td_gfx_stream`
(`$1780`, the sprite graphics stream, `GFXS_*` entries), `m7_patch_flags`,
`m7_patch_vram` and `m7_patch_tiles` (`$1800`, `$1808`, `$1828`: the four
Mode 7 block patch slots), and `td_switch_events` (`$18B0`, stage 5's
switch events, `SWEV_*` fields). The tile attribute map at `$7E:4000`
is also used differently by the two kinds of stage.
`$1500-$153F` / `$1540-$157F` are the players' top-down blocks in the
top-down stages but the players' `PLAYER_*` parallel fields (slot +
`$1300`) in the side view, where the code writes them
`player1_obj+PLAYER_BOMB_X` and so on; `stage_ram` (`$1500`) is where
the stage setup clears `$1500-$18FF`.

## Engine and sound variables

Described in [Engine](engine.md) and [Sound](sound.md); each has a comment
in `src/ram.inc`:

| name | address | meaning |
|---|---|---|
| `force_blank_frames` | `$3E` | frames the NMI keeps the screen blanked (4 after a display change) |
| `irq_mode` | `$44` | IRQ handler index (top-down split screen) |
| `hdma_preset` | `$46` | HDMA channel preset (`setup_hdma_channels`, `setup_stage_hdma`) |
| `cgram_dma_src` | `$48` | WRAM address of the palette DMAd to CGRAM every frame (`$2200`) |
| `vram_queue_end` | `$4E` | end of the VRAM DMA queue (`VRAM_QUEUE` = `$7E:3000`) |
| `vram_queue_data_ptr` | `$50` | next free byte of the queue's data (`VRAM_QUEUE_DATA` = `$7E:3400`) |
| `apu_pending_cmd` | `$52` | sound command waiting for the driver's echo; `$FF` during an upload |
| `cgram_upload_addr` | `$98` | CGRAM address of a 32-byte palette upload (side view) |
| `rng_temp` | `$E6` | complement of `rng_lo`, read by some objects as a random value |
| `text_erase` | `$F0` | `draw_text` erases instead of writing |
| `palette_tasks` | `$1200` | 8 palette task slots (`TASK_*` fields) |
| `vram_tasks` | `$1280` | VRAM script task slots |
| `LOADER_VRAM` / `LOADER_WRAM` | `$1300` / `$1340` | loader contexts (`LDR_*` fields) |
| `bg1_x` | `$1380` | BG1 scroll state (`BG_*` fields, e.g. `bg1_x+BG_PAGE`); `bg1_y` at `$1398` |
| `bg1_x_delta` / `bg1_y_delta` | `$138E` / `$13A6` | BG1 movement of this frame |
| `bg1_scroll_mode` | `$13BA` | BG1 scroll handler (`tbl_bg1_scroll_modes`) |
| `bg2_x` | `$13C0` | BG2 scroll state; `bg2_y` at `$13D8` |
| `bg2_scroll_mode` | `$13FA` | BG2 scroll handler (`tbl_bg2_scroll_modes`) |
| `bg3_x` | `$1400` | BG3 scroll state (written to the BG3 scroll registers by `write_bg_scroll_regs`) |
| `spawn_pages` ... | `$1602-$160C` | stage object spawner (`spawn_stage_objects`) |
| `scroll_split_pattern` | `$1676` | scroll-split HDMA pattern (0 = off), `scroll_split_y` at `$1674` |
| `hud_buffer` | `$1700` | HUD tilemap buffer, 4 rows of `$20` bytes |
| `boot_signature` | `$1E0A` | `>JIN L<` + `$0400`: keeps `$1E00-$1FFF` across a reset |
| `inidisp_shadow` ... `hdmaen_shadow` | `$1E80-$1EC4` | PPU register shadows (`write_ppu_shadows`, the NMI frame handlers) |
| `LOADER_SPC` | `$1F00` | sound CPU loader context; `pending_spc_list` (`$1F2C`) is the song set requested from the main loop |
