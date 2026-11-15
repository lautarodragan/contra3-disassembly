# RAM map

All RAM names are in `src/ram.inc`, included by `src/common.inc`. The first
pass (milestone 2) replaced RAM operands by symbols mechanically, with the
CDL: every variable the code addresses directly has a symbol, most of them
still a placeholder named by its address (`zp_00`-style for the direct page,
`inidisp_shadow`-style for `$0100-$1FFF`, `wram_7EA000`-style above `$7E:2000`).
The header of `src/ram.inc` lists exactly what was converted and what was
left as a number on purpose; in short:

- indexed operands (`lda $10,x`, `lda a:$1304,x`) are left as numbers: they
  are mostly fields of the structure that X or Y points to (an object slot,
  a player), and naming them as absolute addresses would be wrong;
- direct-page operands of instructions that ran (or may run) with the direct
  page register D other than 0 are left as numbers: in the loader and
  decompressor (`src/engine/gfx_loader.asm`, `src/engine/decompress.asm`,
  `src/sound/`) D points at a context structure at `$1300`, `$1340` or
  `$1F00`, and the comment on the line gives the address really accessed.

## Named variables

These names were checked in the code (the routine named in the comment, or
the ones in the lead's notes confirmed by the code):

| name | address | meaning |
|---|---|---|
| `joy1_held` | `$20` | joypad 1 buttons held (written by sub_008B19; pads 2-4 at $22/$24/$26) |
| `joy2_held` | `$22` | joypad 2 buttons held |
| `joy1_pressed` | `$28` | joypad 1 buttons newly pressed this frame (pads 2-4 at $2A/$2C/$2E) |
| `joy2_pressed` | `$2A` | joypad 2 buttons newly pressed this frame |
| `game_mode` | `$32` | game mode, index into tbl_00A38A (sub_00A377) |
| `game_submode` | `$34` | sub-mode of the current game mode (each mode dispatches it through its own table) |
| `frame_counter` | `$3A` | incremented by sub_00A377 every frame |
| `nmi_busy` | `$3C` | non-zero while the NMI frame handler runs (re-entry guard in nmi) |
| `nmi_mode` | `$42` | NMI frame handler, x2 index into tbl_0081E0 (0, 2 = side-view stages, 4 = top-down stages) |
| `sound_queue_read` | `$54` | read index of sound_queue (sub_0085F3) |
| `sound_queue_write` | `$56` | write index of sound_queue (sub_00868F) |
| `sound_last_queued` | `$5C` | last command queued by sub_00868F (repeats are dropped) |
| `stage_index` | `$70` | stage number - 1 (0-5), set from stage_number in normal play and in the demo; indexes per-stage tables such as tbl_00AC2A |
| `difficulty` | `$84` | difficulty x2: 0 easy, 2 normal, 4 hard (copied from $1E3E) |
| `stage_number` | `$86` | stage number, 1-6 |
| `rng_lo` | `$E8` | random number generator state, low word (sub_00816C) |
| `rng_hi` | `$EA` | random number generator state, high word |
| `oam_hi_bits` | `$9C` | OAM high-table bits being packed by `draw_metasprite` / `draw_shot` |
| `shake_bg1_y` | `$A0` | screen shake: subtracted from BG1 VOFS and added to sprites' y (`update_shake_side_view`) |
| `shake_bg2_y` | `$A2` | screen shake of BG2 (half of `shake_bg1_y`) |
| `target_list_end` | `$AA` | end of the list of shot targets at `$15A0`, built by `update_objects` |
| `oam_ptr` | `$AC` | next free entry of the OAM buffer (`$0FC0`) |
| `oam_hi_ptr` | `$AE` | next byte of the OAM high table (`$11C0`) |
| `sound_queue` | `$0100` | ring of commands for the sound CPU (sub_00868F, sub_0085F3) |
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
sets it to `stage_number - 1` both in normal play (`sub_00A7FE`) and in the
demo (`sub_00A8E1`), and `tbl_00AC2A` uses it to choose between the
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

When you name a variable, rename its placeholder everywhere (src/ and book/), add
it to the table above with how you know, and update its comment in
`src/ram.inc`.
