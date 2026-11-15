# Routines

> **Stub.** This page will list the game's routines by subsystem as they get
> names (milestone 2). Only the entry points below are named so far; what is
> known about each part of the code is in the headers of the files in
> `src/` (see [Source layout](layout.md)).

## Entry points

| label | address | what |
|---|---|---|
| `reset` | `$00:8000` | reset vector |
| `nmi` | `$00:819B` | NMI (vertical blank) vector |
| `irq` | `$00:8BE2` | IRQ vector; also COP, BRK and ABORT |

See [The cartridge](cartridge.md#vectors) for the vector table.

Every other routine is still named by its address, `sub_` plus six hex
digits (for example `sub_00FD8D` at `$00:FD8D`). The number of routines and
jump tables found is in [Progress](progress.md).

When you name a routine, add it here with what it does, its inputs and
outputs (registers, M/X widths, RAM), and how you know.

## Game flow

The game mode handlers, the attract mode, the menus and screens and the
side-view stage state machine (`src/game/`) are described in
[Game flow](game-flow.md), starting from `run_game_mode`; each routine has a
header comment in the source.

## Objects and players

The object system is described in [Objects](objects.md). Its main routines
(`src/objects/`, `src/engine/window_effect.asm`, `src/effects/`), each with
a header comment in the source:

| label | address | what |
|---|---|---|
| `update_objects` | `$00:E989` | main object loop: movement, target list, contact with players, animation, handler, hit flash, drawing |
| `update_objects_0280` | `$00:E97E` | the same for slots `$0280-$02FF` |
| `call_object_handler` | `$00:EB04` | `JML` to the handler of `OBJ_TYPE` in `tbl_object_types` |
| `draw_players` | `$00:E960` | draws both players, alternating which goes first |
| `draw_metasprite` | `$00:EB1A` | appends a metasprite (bank `$06`) to the OAM buffer |
| `update_shots` | `$00:E1B8` | player shot loop; damage to enemies |
| `draw_shot` | `$00:E2D7` | one OAM entry for a shot |
| `call_shot_handler` | `$00:E355` | `JML` through `tbl_shot_types` |
| `fire_weapon` | `$00:D6DC` | fire button: shot spawner of the active weapon (`tbl_fire_weapon`) |
| `spin_fire_weapon_1` / `_2` | `$00:D656` / `$00:D692` | spin jump: fires both weapons around |
| `update_players` | `$01:A624` | per frame: pad, blinking, input, bombs, states, frames of both players |
| `read_player_input` | `$01:A6CF` | per-state input routine (`tbl_player_input`) |
| `run_player_state` | `$01:AA6A` | timers, then the state handler (`tbl_player_states`) |
| `move_player` | `$01:AA20` | velocity, screen clamp, `PLAYER_DX`/`PLAYER_DY` |
| `kill_player` | `$01:9A76` | death: knock-back, weapon and barrier lost |
| `respawn_player` | `$01:9E14` | respawn state, 96 frames of invulnerability |
| `check_bomb_button` | `$01:801B` | throws a smart bomb |
| `update_bomb` / `bomb_hit_targets` | `$01:AAF4` / `$01:AB1F` | the bomb blast and its damage |
| `set_player_frame` | `$01:8063` | the player's tiles and metasprite for its pose |
| `snap_y_up_to_tile` ... | `$01:93DB`... | align an object to the 8-pixel BG grid (landing, walls) |
| `find_free_slot` ... | `$01:9E83`... | allocate an object slot |
| `spawn_enemy_bullet` | `$01:A11C` | enemy bullet, speed by difficulty |
| `fire_bullet_at_player` | `$01:A0E9` | aim and fire an enemy bullet |
| `angle_to_player` | `$01:A0C8` | angle from an object to a player |
| `solid_object_vs_players` | `$01:9F1A` | solid objects: platforms and walls for the players |
| `kill_players_outside` | `$01:A296` | kills players outside a box |
| `update_player_window` | `$00:E7EF` | window HDMA of the barrier and the bomb |
| `update_shake_side_view` | `$00:FF01` | screen shake |
| `vector_length` | `$00:FF48` | `sqrt(x^2 + y^2)` of two 8-bit values |

### Object handlers, banks $00 and $01

The per-type handlers (`update_<enemy>`, states `<enemy>_state_NN`) are
listed in [Enemies and objects: banks $00, $01](enemies-early.md). Helpers
they share:

| label | address | what |
|---|---|---|
| `update_effect` | `$01:CFF5` | type `$1D`: plays an animation, then frees the slot |
| `make_effect_object` | `$01:CF66` | turns the slot in Y into an effect playing animation A |
| `spawn_effect` / `spawn_effect_random_offset` | `$01:CF25` / `$01:CF3C` | allocate an effect (at a random offset) |
| `start_dying_soldier` ... | `$01:D201`... | a killed soldier becomes type `$1B` (thrown back, explodes) |
| `start_grenade_blast` | `$01:D2A1` | an object becomes a grenade blast (type `$1A`) |
| `get_bg_tile_at_object` | `$00:E16E` | BG map entry under an object: floor/wall collision |
| `find_free_shot_slot_up_to` | `$00:E122` | free player shot slot from X up to `zp_06` |

## Top-down stages

The routines of stages 2 and 5 (`src/topdown/`) are described in
[Top-down stages](topdown.md), starting from `run_topdown_stage`; each
routine has a header comment in the source.

## Engine and sound

The engine (`src/engine/`) and the sound CPU interface (`src/sound/`) are
described in [Engine: frame flow, video and loading](engine.md) and
[Sound driver interface](sound.md). The main routines:

| label | address | what |
|---|---|---|
| `warm_boot` | `$00:80A3` | RAM/VRAM/PPU initialisation after a reset or soft reset, then the main loop |
| `nmi_frame_default` / `nmi_frame_side_view` / `nmi_frame_top_down` | `$00:81E6` / `$00:823C` / `$00:83A3` | the frame handlers (`nmi_mode`) |
| `next_random` | `$00:816C` | random number generator, once per frame |
| `read_joypads` | `$00:8B19` | pads, newly pressed buttons, soft reset |
| `queue_sound` | `$00:868F` | A = sound command: queue it for the sound CPU |
| `send_queued_sound` | `$00:85F3` | per frame: send the next queued command |
| `send_sound_command_now` | `$00:8624` | send a command and wait for the echo |
| `reset_sound_queue` | `$00:865C` | empty the queue, stop all sound |
| `load_song_set` / `request_song_set` | `$00:98D4` / `$00:994F` | upload a song set now / from the main loop |
| `load_stage_music` | `$04:D9F1` | song set and start command of the stage |
| `disable_display_and_nmi` / `enable_nmi` | `$00:85A9` / `$00:85C1` | display and NMI off / on around loading |
| `reset_video_state` | `$00:8DBE` | reset PPU, VRAM, OAM, palettes and tasks |
| `init_ppu_registers` | `$00:86AC` | every PPU register to its start-up value |
| `run_vram_queue` | `$00:8CFF` | NMI: execute the queued VRAM DMAs |
| `begin_vram_transfer` / `push_vram_word` / `end_vram_transfer` | `$00:8D41` / `$00:8DA5` / `$00:8DB0` | build a queued VRAM transfer |
| `draw_text` | `$00:9024` | X = string: write it to the BG tilemap through the queue |
| `load_data_list` | `$00:90A8` | X = data list (bank `$05`): load compressed graphics/data to VRAM, WRAM or the sound CPU |
| `run_pending_loads` | `$00:90C7` | per frame: next chunk of deferred lists |
| `decompress_ring` / `decompress_chunk` | `$00:949C` / `$00:94A9` | the decompressor (resumable, 1 KiB window) |
| `start_palette_task` / `run_palette_tasks` | `$00:9982` / `$00:9995` | palette animations and fades |
| `run_bg1_scroll_mode` / `run_bg2_scroll_mode` | `$00:C67D` / `$00:C917` | side-view scrolling of BG1 / BG2 |
| `draw_bg_column` / `draw_bg_row` | `$00:CB29` / `$00:CA52` | queue the tiles entering the screen |
| `update_bg_collision_map` | `$00:CC37` | collision map from the queued tiles |
| `spawn_stage_objects` | `$00:CE3A` | place the stage's objects as BG1 scrolls |
| `init_hud` / `update_p1_hud` / `upload_p1_hud` | `$00:E369` / `$00:E3DA` / `$00:E4F6` | the HUD |
| `setup_stage_hdma` | `$00:E575` | side view: HDMA channels |
| `build_scroll_split_hdma` | `$00:E5F7` | HDMA table for horizontally split scrolling |
| `calc_angle` / `polar_to_xy` / `set_velocity_from_angle` / `calc_distance` | `$1D:ABA0` / `$1D:ACA4` / `$1D:AD8A` / `$1D:AED0` | angles and distances |
