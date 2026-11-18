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

The numbers have names in `src/sound/sounds.inc` (`SOUND_*`; see
[The sound effects](#the-sound-effects)); what the driver does with each
command is in [Sound driver: commands](sound-driver.md#commands).

## The sound effects

Every command `$01`-`$73` plays a sound (the driver's
[sound table](sound-driver.md#the-sound-table)). Each was named from the
code that queues it (`lda #SOUND_...` before `queue_sound` or one of its
wrappers, and the tables `td_turn_sounds`, `topdown_stage_songs`,
`pause_sounds`, `sound_mode_commands`), and checked in the emulator: with
a write watch on `sound_queue` and on the stack (the return address of the
`jsl queue_sound`), the scripted plays (`tools/c3emu/plays.py`, every
stage, the bosses and the endings) and 30,000 frames from power-on
(intro, title, attract demos) queued 98 of the numbers, each from the
code below (the others are marked). Each was rendered with
`tools/sound_render.py` (on the title screen, so with the opening's stage
samples): its length is how long it sounds (*loops*: still playing after 6
seconds, until another sound takes its channel, as `$19` takes `$18`'s and
`$1F` `$1E`'s). A name is given only where the code says what triggers
the sound; the others are used by numbers in the code, with the routines
here.

| sound | name | length | queued by |
|---|---|---|---|
| `$01` | `SOUND_CURSOR` | 0.24 s | `title_menu_update_cursor`, `game_mode_stage_select`, `continue_move_cursor`, `options_move_cursor` ... |
| `$02` | `SOUND_SELECT` | 0.68 s | `title_menu_start_pressed`, `game_mode_stage_select`, `continue_menu`, `continue_player_menu` ... |
| `$03` | `SOUND_BONUS_COUNT` | 0.34 s | `stage_clear_count_bonus` |
| `$04` | `SOUND_SHOT_DEFAULT` | 0.38 s | `spawn_shot_default`, `fire_td_default` |
| `$05` | `SOUND_SHOT_LASER` | 1.08 s | `spawn_shot_laser_in_slots`, `fire_td_laser` |
| `$06` |  | 0.98 s | never queued |
| `$07` | `SOUND_SHOT_CRUSH` | 0.78 s | `spawn_shot_crush_in_slot`, `fire_td_crush` |
| `$08` | `SOUND_SHOT_HOMING` | 0.66 s | `spawn_shot_homing_in_slot`, `fire_td_homing` |
| `$09` | `SOUND_SHOT_SPREAD` | 0.36 s | `spawn_shots_spread_in_slots`, `fire_td_spread` |
| `$0A` | `SOUND_SHOT_FLAME` | 0.52 s | `spawn_shots_flame`, `td_play_flame_sound` |
| `$0B` | `SOUND_ENEMY_DIE` | 0.36 s | `kill_alien_dog`, `start_dying_soldier`, `floor_mouth_bug_state_07`, `td_runner_state_3` ... |
| `$0C` | `SOUND_SHOT_DOWN` | 0.58 s | `update_stage1_boss_tracking_shot`, `update_stage1_boss_falling_shot`, `update_stage3_winged_bug`, `larva_die` |
| `$0D` | `SOUND_HANGING_SOLDIER_DIE` | 0.60 s | `update_dying_soldier` |
| `$0E` | `SOUND_ALIEN_SOLDIER_DIE` | 0.66 s | `update_dying_soldier`, `heart_boss_crawler_die` |
| `$0F` | `SOUND_BOSS_HIT` | 0.20 s | `update_stage1_boss`, `stage1_boss_play_hit_sound`, `update_cave_beast` |
| `$10` | `SOUND_CLANG` | 0.10 s | `update_shots`, `td_flash_boss_palette_on_hit`, `td_play_hit_sound`, `update_stage2_boss_pod` ... |
| `$11` |  | 0.84 s | `td_trigger_block_anim` |
| `$12` | `SOUND_WEAPON_PICKUP` | 0.62 s | `weapon_capsule_state_02`, `weapon_capsule_state_03`, `weapon_capsule_state_04`, `td_p1_vs_items` ... |
| `$13` | `SOUND_HOVERBIKE_RIDER_DIE` | 0.88 s | `update_hoverbike_rider` |
| `$14` |  | 0.84 s | `cave_beast_state_17`, `lightning_bolt_state_01`, `stage2_boss_cannon_fire` |
| `$15` |  | 0.98 s | `jetpack_soldier_state_00`, `update_airship_gun_arm_shell`, `update_helicopter_rope`, `helicopter_rope_state_01` |
| `$16` | `SOUND_THROW` | 0.64 s | `grenade_soldier_state_03`, `stage3_searchlight_craft_pick_target`, `hoverbike_rider_drop_bomb` |
| `$17` | `SOUND_MISSILE_EXPLODE` | 0.20 s | `update_stage4_boss_shot`, `homing_missile_fly` |
| `$18` | `SOUND_SPIKE_EXTEND` | loops | `stage3_spiked_climber_move_spike` (not in the plays) |
| `$19` | `SOUND_SPIKE_RETRACT` | 0.36 s | `update_stage3_spiked_climber_core`, `stage3_spiked_climber_move_spike` (not in the plays) |
| `$1A` | `SOUND_ENEMY_FIRE` | 0.40 s | `midboss_tank_throw_shells`, `hoverbike_rider_fire`, `stage3_second_robot_spawn_debris`, `stage4_boss_pod_fire` |
| `$1B` | `SOUND_WINDOW_CRASH` | 0.52 s | `window_jumper_state_02` |
| `$1C` |  | 1.64 s | never queued |
| `$1D` | `SOUND_SNIPER_KILLED` | 1.78 s | `sniper_bunker_state_01` |
| `$1E` | `SOUND_TANK_ENGINE` | loops | `midboss_tank_state_02`, `midboss_tank_state_07`, `input_tank` |
| `$1F` | `SOUND_TANK_STOP` | 0.42 s | `midboss_tank_state_06`, `input_tank` |
| `$20` | `SOUND_TANK_CANNON` | 1.26 s | `player_state_tank` |
| `$21` | `SOUND_FLAME_GEYSER` | 1.36 s | `update_flame_geyser` |
| `$22` | `SOUND_FIRE_JET` | 3.30 s | `update_fire_jet` |
| `$23` | `SOUND_FIREBALL_JUMP` | 1.90 s | `update_hopping_fireball` |
| `$24` | `SOUND_FIRE_ERUPTION` | 4.91 s | `update_fire_eruption` |
| `$25` | `SOUND_STAGE1_BOSS_FIRE` | 1.50 s | `stage1_boss_attack_fire` (not in the plays) |
| `$26` | `SOUND_TURN_1` | 0.80 s | `td_play_turn_sound` (not in the plays) |
| `$27` | `SOUND_TURN_2` | 0.80 s | `td_play_turn_sound` |
| `$28` | `SOUND_TURN_3` | 0.80 s | `td_play_turn_sound` |
| `$29` | `SOUND_TURN_4` | 0.80 s | `td_play_turn_sound` |
| `$2A` | `SOUND_TURN_5` | 0.80 s | `td_play_turn_sound` |
| `$2B` | `SOUND_TURN_6` | 0.80 s | `td_play_turn_sound` |
| `$2C` | `SOUND_TURN_7` | 0.80 s | `td_play_turn_sound` |
| `$2D` | `SOUND_TURN_8` | 0.80 s | `td_play_turn_sound` |
| `$2E` | `SOUND_STAGE2_BOSS_TAKE_OFF` | 1.74 s | `stage2_boss_state_08` |
| `$2F` | `SOUND_STAGE2_BOSS_DROP` | 0.98 s | `stage2_boss_state_01`, `stage2_boss_state_09` |
| `$30` | `SOUND_EXPLOSION` | 0.88 s | `update_stage1_boss_part`, `update_popup_turret`, `update_wall_hatch`, `update_barricade_cannon` ... |
| `$31` | `SOUND_RIDEABLE_MISSILE` | 3.62 s | `rideable_missile_state_01` |
| `$32` | `SOUND_STAGE3_ROBOT_LAND` | 0.52 s | `stage3_robot_update_jump` |
| `$33` | `SOUND_BUMP` | 0.44 s | `stage3_robot_state_05`, `stage3_robot_update_jump`, `helicopter_rope_check_missile_contact` |
| `$34` | `SOUND_STAGE3_ROBOT_JUMP` | 1.08 s | `stage3_robot_state_08` |
| `$35` |  | 1.46 s | `queue_sound_35_every_32` |
| `$36` | `SOUND_COUNTDOWN_BOMB` | 0.56 s | `update_countdown_bomb` |
| `$37` |  | 0.18 s | `snake_robot_state_06` |
| `$38` | `SOUND_HARD_LANDING` | 0.62 s | `snake_robot_state_03` |
| `$39` |  | 0.42 s | `snake_robot_state_03`, `brain_boss_attack_4_turn` |
| `$3A` | `SOUND_STAGE5_BOSS_SPIT` | 1.38 s | `stage5_boss_spit_step_0` |
| `$3B` | `SOUND_HEART_BOSS_BUG_DIE` | 0.50 s | `heart_boss_bug_die` |
| `$3C` | `SOUND_BOSS_HIT_2` | 0.40 s | `update_heart_boss`, `update_brain_boss` |
| `$3D` |  | 0.96 s | `winged_alien_step_2` |
| `$3E` | `SOUND_EXTRA_LIFE` | 0.96 s | `check_button_code_unused`, `add_score` |
| `$3F` | `SOUND_PLAYER_DIE` | 0.92 s | `td_player_state_dying`, `kill_player` |
| `$40` | | | empty entry |
| `$41` | `SOUND_BIG_EXPLOSION` | 1.18 s | `update_stage3_breakable_wall`, `update_stage4_boss_pod`, `face_boss_eye_explode`, `snake_robot_state_10` ... |
| `$42` | `SOUND_VEHICLE_EXPLODE` | 1.14 s | `update_midboss_tank`, `wrecked_car_state_01` |
| `$43` | `SOUND_PLAYER_FALL` | 2.78 s | `check_30_lives_code`, `kill_player`, `td_player_state_falling` |
| `$44` |  | 2.80 s | `midboss_tank_state_00`, `barricade_state_03`, `face_boss_set_state_02`, `face_boss_state_02` |
| `$45` |  | 2.90 s | `bomber_raid_state_03` |
| `$46` |  | 2.90 s | `opening_zoom_title_logo_last`, `opening_slide_title_the`, `opening_slide_title_alien`, `bomber_raid_state_04` |
| `$47` |  | 5.75 s | `opening_slide_title_wars`, `bomber_raid_state_05` |
| `$48` |  | 2.90 s | `stage3_spiked_climber_state_06` (not in the plays) |
| `$49` |  | 0.96 s | `stage3_spiked_climber_state_09`, `stage3_spiked_climber_arm_state_01`, `ending_sequence_state_09` |
| `$4A` |  | 1.94 s | `stage3_spiked_climber_arm_state_02`, `ending_sequence_state_08` |
| `$4B` |  | 0.46 s | `stage3_spiked_climber_state_10` (not in the plays) |
| `$4C` |  | 0.50 s | never queued |
| `$4D` |  | 0.48 s | `stage3_boss_return` |
| `$4E` |  | 3.14 s | `stage3_boss_return`, `stage3_boss_state_15` |
| `$4F` | `SOUND_STAGE4_INTRO` | 3.88 s | `layout_init_stage4` |
| `$50` |  | loops | `stage4_controller_state_17` |
| `$51` | `SOUND_WALL_WORM_DIE` | 2.00 s | `wall_worm_die` |
| `$52` | `SOUND_HEART_BOSS_DIE` | 2.00 s | `heart_boss_die` |
| `$53` |  | 0.80 s | `cave_beast_state_03`, `cave_beast_state_19` |
| `$54` |  | 1.20 s | `cave_beast_set_speed` |
| `$55` |  | 0.46 s | `winged_alien_state_03` |
| `$56` |  | 0.94 s | `stage1_boss_controller_state_07`, `stage1_boss_push_wall`, `cave_beast_state_07`, `stage2_boss_state_02` ... |
| `$57` |  | 1.16 s | `stage1_boss_attack_choose` |
| `$58` |  | 0.80 s | `stage1_boss_controller_state_02` |
| `$59` |  | 2.02 s | `check_stage_select_code`, `face_boss_state_07`, `ending_sequence_state_25`, `brain_boss_state_07` |
| `$5A` | `SOUND_SMART_BOMB` | 4.29 s | `check_bomb_button`, `td_check_smart_bomb` |
| `$5B` | `SOUND_BOMB_FLASH` | 2.16 s | `opening_beam_start_flash`, `stage4_controller_state_19_return` |
| `$5C` |  | 1.44 s | `ending_creature_aim_arm` |
| `$5D` |  | 2.12 s | `ending_creature_rise_and_sink` |
| `$5E` |  | 1.02 s | `ending_creature_swing` |
| `$5F` | `SOUND_RIDEABLE_MISSILE_ENDING` | 3.62 s | `rideable_missile_state_01` |
| `$60` | | | empty entry |
| `$61` | `SOUND_SONG_OPENING` | the song of the set | `opening_cinematic_init` |
| `$62` | `SOUND_SONG_STAGE3_6` | the song of the set | `layout_init_stage3_common`, `layout_init_stage6` |
| `$63` | `SOUND_SONG_STAGE2_4` | the song of the set | `layout_init_stage4_checkpoint`, `stage4_controller_state_01`, `intro_play_music` |
| `$64` | `SOUND_SONG_STAGE1` | the song of the set | `layout_init_stage1_common` |
| `$65` |  | the song of the set | never queued |
| `$66` | `SOUND_SONG_STAGE5` | the song of the set | `intro_play_music` |
| `$67` |  | the song of the set | never queued |
| `$68` | `SOUND_SONG_BOSS` | the song of the set | `stage1_boss_controller_state_02`, `stage3_boss_return`, `stage2_state_boss_setup`, `stage5_state_boss_setup` |
| `$69` | `SOUND_SONG_HEART_BOSS` | the song of the set | `heart_boss_state_06` |
| `$6A` | `SOUND_SONG_STAGE_CLEAR` | the song of the set | `stage_clear_fade_in` |
| `$6B` | `SOUND_SONG_GAME_OVER` | the song of the set | `game_over_fade_in` (not in the plays) |
| `$6C` | | | empty entry |
| `$6D` |  | 1.74 s | `title_menu_start_pressed`, `stage3_boss_state_19` |
| `$6E` | `SOUND_BOSS_EXPLOSIONS` | 2.24 s | `queue_sound_6E_throttled`, `td_play_rumble_sound` |
| `$6F` | `SOUND_SONG_TOPDOWN_INTRO` | the song at `$4B00` | `intro_init` |
| `$70` | | | empty entry |
| `$71` | `SOUND_SONG_ENDING` | the song of the set | `ending_sequence_state_18` |
| `$72` | `SOUND_SONG_KONAMI_LOGO` | the song of the set | `konami_logo_start_shine` |
| `$73` | | | empty entry |

Notes:

- `$61`-`$6B`, `$71` and `$72` are the same command to the driver: play
  the song of the set at `$3000` (8 channels for `$71`, `$72`); the game
  gives each song its own number. `$6F` plays the song at `$4B00`, which
  only the sets of stages 2 and 5 have (silent elsewhere).
- Never queued: `$06`, `$1C`, `$4C`,
  and the song numbers `$65`, `$67`; `sound_check_play` (the unreachable
  sound check screen, reachable with the `sound_check` cheat) plays every
  sound and song but `$18`, `$19`, `$1E` and `$1F`
  ([Cheats](cheats.md#leftovers-of-the-developers)).
- `$31` and `$5F` share their sequence (`$5F` plays it on music channel
  4: the ending's missile, `$31` stage 4's).
- `$3E`, `$43` and `$59` also acknowledge the title screen's button codes
  (`check_button_code_unused`, `check_30_lives_code`,
  `check_stage_select_code`).
- `SOUND_CMD_PAUSE` ... `SOUND_CMD_STOP_MUSIC` (`$7C`-`$83`) name the
  driver's commands the game sends; `$74`-`$7A` (the instrument sets) are
  the data of `song_start_commands`.

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
