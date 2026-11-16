# Enemies and objects: banks $00, $01

The object types whose handlers are in `src/objects/object_handlers_00a.asm`,
`object_handlers_00c.asm`, `object_handlers_01a.asm` and
`object_handlers_01b.asm`: stage 1, most of stage 3, the start of stage 4,
the generic objects every stage uses (enemy bullets, effects, the weapon
capsule, the dying soldier) and the invisible *stage triggers*. The player
shots' handlers (`object_handlers_00b.asm`) are at the end. For banks
`$02`, `$04` and `$1D` see [Enemies and bosses: banks $02, $04, $1D](enemies-late.md).

## How they were identified

As for the other banks: in the emulator each side-view stage was played by
the tracer's random player (infinite lives) for 150000 frames; every 4 frames
the slots `$0280-$0ABF` were dumped, and each time a slot got a new
`OBJ_TYPE` (a spawn) the frame was saved three times (0, 30 and 90 frames
later) with the slot's position and hitbox drawn on it. The "section" in the
table is the stage progress counter (`stage_progress`) at the spawn. Names come
from what is on screen at that position, checked against the code (what it
spawns, how it dies). Types whose shape could not be told apart, or that
draw nothing, keep update_object_type_XX and their states
object_type_XX_state_NN. Handlers dispatch on `OBJ_STATE` through
`tbl_<name>_states`; state routines are `<name>_state_NN` (NN = the
`OBJ_STATE` value, hex). Identified types have an `OBJT_*` constant in
`src/object_types.inc`.

## Types

| type | handler | what it is |
|---|---|---|
| $01 | `update_stage1_boss_controller` | the stage 1 boss (the giant turtle bursting through the wall), invisible controller in slot `$0900`: boss music (`song_change_set`), graphics (`load_list_05AA1F`), the wall breaking (types `$22`, `$23`), then spawns the parts (`spawn_stage1_boss_parts`) and runs the attacks (`tbl_stage1_boss_attacks`) and the slam; the turtle itself is drawn on BG2 and bent by HDMA. Checked in the emulator |
| $02 | `update_object_type_02` | seen once in stage 1 (section 8); sets `OBJ_HP` to $100 in state 0 and runs 11 states. Not identified |
| $03 | `update_bg2_scroll_mode_trigger` | stage trigger: sets `bg2_map_offset` from field `$3A`, waits for `bg2_screen_drawn`, then sets `bg2_scroll_mode` |
| $04, $54 | `update_object_type_04` | seen in stage 1 (section 4, a red soldier on a building ledge, probably). Not identified with certainty |
| $05 | `update_bg1_autoscroll_trigger` | stage trigger: turns `bg1_autoscroll` on |
| $06 | `update_object_type_06` | stage 1 scripted scene (section 9): BG/HDMA effect with 9 states. Not identified |
| $07 | `update_load_list_trigger` | stage trigger: loads the list `ptrs_trigger_load_lists`[field `$3A`] with `load_data_list` |
| $08 | `update_object_type_08` | stage trigger (stage 1 section 4): stops `bg1_autoscroll`, `bg1_scroll_mode` = 4 |
| $09 | `update_player_tank` | the tank the players can drive (stage 1 sections 4-5; seen in the emulator), drawn on BG2: a player landing on its hatch enters it (`PLAYER_STATE_ENTER_TANK`, `PLAYER_STATE_TANK`); damage counter `obj_slots+31*OBJ_SIZE+OBJ_HP` (`$09C6`) |
| $0A | `update_foot_soldier` | running foot soldier (stage 1; checked in the emulator). Killed: becomes type $1B (dying soldier) |
| $0B | `update_soldier_spawner` | invisible spawner (stage 1): foot soldiers run in from the left and right edges at random intervals by difficulty (`soldier_spawn_delays_right`, `soldier_spawn_delays_left`) |
| $0C | `update_bomber_bomb` | bomb dropped by the bomber plane (stage 1 section 10, seen in the emulator); falls with gravity, trailing type $1D fire effects |
| $0D | `update_popup_turret` | gun turret that rises out of the rubble (stage 1, HP 16; seen in the emulator) |
| $0E | `update_bg1_scroll_mode_trigger` | stage trigger: sets `bg1_scroll_mode` from field `$3A`, stops `bg1_autoscroll`, rounds the BG1 position |
| $0F | `update_weapon_capsule` | flying weapon capsule: shot down, it drops a falcon weapon item (all side-view stages; seen in the emulator) |
| $10 | `update_bouncing_debris` | debris that falls, bounces off the floor (`get_bg_tile_at_object`) and blinks out (stage 1, the wrecked car) |
| $11 | `update_object_type_11` | stage 1, HP 16. Not identified |
| $12 | `update_object_type_12` | stage 1 soldier variant, HP 6 (seen in the emulator). Not identified exactly |
| $13 | `update_grenade` | grenade/shell thrown by soldiers: explodes into type $1A when it touches a player or a solid BG tile (bit $2000) |
| $14 | `update_object_type_14` | stage 1 section 4: part of the wall structure, HP 64 (flashes its palette when hit). Not identified exactly |
| $15 | `update_object_type_15` | stage 1 section 4: destructible wall gun, HP 40; destroyed: a burst of explosions. Not identified exactly |
| $16 | `update_object_type_16` | falls with gravity and explodes on the floor or on contact (stage 1 section 4) |
| $17 | `update_window_sniper` | sniper in a window (stage 1 and 3, HP 6; seen in the emulator) |
| $18 | `update_enemy_bullet` | enemy bullet (`spawn_enemy_bullet` allocates them); deleted when it touches a player |
| $19 | `update_object_type_19` | plays an animation and deletes itself; never run in the CDL traces |
| $1A | `update_grenade_blast` | explosion of a grenade (type $13): harmful for $20 frames, spawns type $1D sparks |
| $1B | `update_dying_soldier` | killed soldier thrown back (`start_dying_soldier`*), then an explosion effect |
| $1C | `update_object_type_1C` | falling fragment (sprite by vertical speed) that explodes on the floor or when shot (stage 1 section 9). Not identified |
| $1D | `update_effect` | effect (explosion, spark, fire): plays `OBJ_ANIM` and frees itself when the script ends (`make_effect_object`) |
| $1E | `update_alien_dog` | alien dog that jumps out at the player (stage 1 sections 2-3; seen in the emulator) |
| $1F | `update_stage1_boss_head` | stage 1 boss: the head (invulnerable target, slot `$0440`; seen in the emulator): pushed back while shot (`boss_work_1`), comes out again otherwise |
| $20 | `update_stage1_boss_part` | stage 1 boss (the giant turtle), a part with HP 256: explodes when destroyed or when the boss dies (`obj_slots+28*OBJ_SIZE+$32`) |
| $22 | `update_stage1_boss_wall_chunk` | stage 1 boss: the four chunks of the metal wall it bursts through (slots `$0300-$03C0`; seen in the emulator) |
| $23 | `update_falling_debris` | falling wall debris (stage 1 boss, the turtle breaking through the wall); explodes at y >= $C8 |
| $24 | `update_object_type_24` | stage 6 alien soldier (seen in the emulator) |
| $26 | `update_stage1_boss_tracking_shot` | stage 1 boss projectile that follows the player's height (speed `stage1_boss_tracking_shot_accels` by difficulty) |
| $27 | `update_stage1_boss_falling_shot` | stage 1 boss projectile that falls, then rolls on the floor |
| $28 | `update_object_type_28` | the handler is a fill routine (also called directly as a helper); probably never used as a type |
| $29 | `update_stage1_boss` | stage 1 boss (the giant turtle), main body with HP $160 (352); fires at the player every `stage1_boss_fire_intervals`[difficulty] + rnd frames |
| $2A | `update_object_type_2A` | advances the state of the type $06 object and deletes the type $2F one. Not identified |
| $2B | `update_object_type_2B` | stage 1 burning section. Not identified |
| $2C | `update_object_type_2C` | stage 1 burning section: fire pillar. Not identified exactly |
| $2D | `update_object_type_2D` | stage 1 burning section: fire. Not identified exactly |
| $2E | `update_object_type_2E` | stage 1 burning section: fireball. Not identified exactly |
| $2F | `update_object_type_2F` | stage 1 burning section: spawns type $30 (falling fire). Not identified exactly |
| $30 | `update_object_type_30` | stage 1 burning section: falling fire. Not identified exactly |
| $31 | `update_object_type_31` | stage 1 burning section: flying fireball enemy, HP 64. Not identified exactly |
| $32 | `update_object_type_32` | stage 1 section 10: fireballs. Not identified exactly |
| $33 | `update_object_type_33` | stage 1 section 10. Not identified |
| $34 | `update_object_type_34` | stage 1 section 2. Not identified |
| $35 | `update_object_type_35` | stage 1 (the cafe front), HP 1. Not identified |
| $38 | `update_stage1_boss_fire` | stage 1 boss fire breath (spawned near the boss by `stage1_boss_spawn_fire`) |
| $39 | `update_swing_pivot` | stage 3 (sections 2, 4): pivot of a rotating swing; carries the players hanging from it (`PLAYER_STATE_HANG_OBJECT`, seen in the emulator) around, up/down moves them along the arm |
| $3A | `update_swing_handle` | stage 3: a handle on a swing's arm; touching it grabs the swing (`swing_grab_handle`) |
| $3B | `update_scroll_modes_trigger` | stage trigger: sets `bg2_scroll_mode` from field `$3B`, then as type `$0E` |
| $3C | `update_object_type_3C` | stage 3 BG effect (palette cycling, line scroll table at `$7E:E000`). Not identified |
| $3D | `update_stage3_spiked_climber` | stage 3 mid-boss: the spiked machine climbing the girder (HP 160; seen in the emulator) |
| $3E | `update_object_type_3E` | does nothing (rtl); stage 3 spiked climber's arm |
| $3F | `update_object_type_3F` | stage 3 spiked climber, spike arm |
| $40 | `update_stage3_spiked_climber_core` | stage 3 spiked climber, its weak point (HP 80) |
| $42 | `update_respawn_clamp_trigger` | stage trigger (stages 3, 6): copies fields `$3A`/`$3B` into `clamp_player_top` / `respawn_mode` |
| $43 | `update_stage3_breakable_wall` | stage 3 section 9: the grey wall closing the way into the building (seen in the emulator), solid, HP 64; destroyed, BG blocks erase it and the scroll resumes |
| $46 | `update_debris_explosion` | becomes an explosion effect (type $1D) where there is a solid BG tile (stage 3 boss) |
| $47 | `update_homing_missile` | small missile homing on a player (stages 3, 4; seen in the emulator), fired by the stage 4 tank, the snake robot and the spiked climber (`spawn_homing_missile`) |
| $48, $51 | `update_jumping_soldier` | stage 3: green soldier walking towards a player and jumping from platform to platform (seen in the emulator); `$48` let out by type `$49` (section 10), `$51` dropped by the searchlight craft (section 8), starting with a jump; dies as a dying soldier |
| $49 | `update_jumping_soldier_spawner` | stage 3 section 10 (the climb up the building): invisible, lets out type `$48` soldiers in bursts (`jumping_soldier_spawner_burst_counts`) |
| $4A | `update_rolling_mine` | stage 3: rolling disc (HP 6; seen in the emulator) |
| $4B | `update_debris_spark` | becomes a type $1D effect flying in a random direction (stage 3 boss) |
| $4D | `update_song_change_trigger` | stage trigger: starts a song change (`update_song_change`: `song_change_mode` / `song_change_set` from `song_change_trigger_modes`); never run in the CDL traces |
| $4E | `update_stage3_searchlight_craft` | stage 3 sections 7-8: the mid-boss, a flying craft with a searchlight drawn on BG2 (slot `$0900`, 27 states; seen in the emulator): drops type `$51` soldiers, throws grenades, HP 64/72/80 |
| $4F | `update_stage3_winged_bug` | stage 3: winged alien bug (HP 8; seen in the emulator) |
| $50 | `update_wall_hatch` | stage 3: wall hatch (HP 8; seen in the emulator) |
| $52 | `stage3_spiked_climber_state_0B` | not a type: state `$0B` of the spiked climber, also in the handler table; never created |
| $53 | `update_passive_part` | does nothing: a hitbox moved by another object (the spiked climber's body, stage 3; also stages 4 and 6) |
| $55 | `update_stage6_bg_tile_animator` | stage 6 (slot 27, from `layout_init_stage6`): every 8 frames DMAs the next of 4 frames of the organic background tiles to VRAM `$3A90` (`stage6_bg_tile_animator_tile_frames`) |
| $56 | `update_alien_soldier` | stage 6: alien soldier running along the floor and jumping off ledges (seen in the emulator), sent by type `$5C` |
| $57 | `update_bg2_screen_size_trigger` | stage trigger: puts field `$3A` in the screen size bits of BG2SC (`bg2sc_shadow`). Unused: no spawn list or code creates it, never run in the CDL traces |
| $59 | `stage3_spiked_climber_state_08` | not a type: state 8 of the spiked climber (makes its arms, type `$5A`), also in the handler table; never created |
| $5A | `update_stage3_spiked_climber_arm` | stage 3 spiked climber: the segments of its two arms reaching to the wall, and its spiked body (slot `$0340`) (seen in the emulator) |
| $5C | `update_alien_soldier_spawner` | stage 6: invisible spawner of alien soldiers (type `$56`) from the screen edges (`alien_soldier_spawn_delays_right`, `alien_soldier_spawn_delays_left`) |
| $60 | `update_unused_type_60` | does nothing (rtl). Unused: no spawn list or code creates it, never run in the CDL traces |
| $6B, $6C | `update_destructible_part`, `update_destructible_part_2` | part of a bigger enemy that explodes when destroyed (`$6B` seen in stage 4 at the airship; `$6C` never created: no spawn list or code stores it, never run in the CDL traces) |
| $6D | `update_player_bike` | stage 4: the hover bike under each player (slots `$0280`/`$02C0`); puts the player back in `PLAYER_STATE_BIKE` when it lands on it |
| $6E | `update_stage4_tank` | stage 4: the tank at the start (HP 315; seen in the emulator) |
| $73 | `update_jetpack_soldier` | stage 4, under the airship: jetpack soldier flying up from below the screen trailing flame, hovering and firing (HP 2/4/6; seen in the emulator); spawned by the hanging soldiers' leader (type `$7E`); dies as type $1B |
| $74 | `update_hoverbike_rider` | stage 4: enemy on a hover bike (HP 16; seen in the emulator) |
| $76 | `update_hoverbike_rider_bomb` | stage 4: bomb dropped by a hover-bike rider (seen in the emulator): falls to the road, then burns along it |
| $78 | `update_hoverbike_rider_shot` | stage 4: shot of a hover-bike rider (seen in the emulator), down at 45 degrees |
| $7E | `update_airship_hanging_soldier` | stage 4: soldiers hanging from the airship's hull (seen in the emulator); the one from the airship spawn list (HP 128) spawns the others and type `$73`, and its death clears them; the others drop onto the road and run off; dies as type $1B |
| $86 | `update_trail_segment` | segment of a chain that follows the path of the one before it (`spawn_trail_chain`, ring buffers at `$7E:E000`): the skeleton robot's eye fireballs, the helicopter rope, the brain boss's chain |
| $89 | `update_checkpoint_trigger` | stage trigger: sets `stage_checkpoint` (the midpoint a continue starts from); stage 3 spawn list, page 14 |

Several low types are invisible **stage triggers**: placed by the stage's
object list, they copy their parameter (fields `$3A`/`$3B`) into a stage
variable (scroll limits, the section, loader lists) and delete themselves at
once (`OBJF_DELETE`): `$03`, `$05`, `$07`, `$08`, `$0E`, `$3B`, `$42`, `$4D`, `$57`, `$89`.

## Shared helpers

- **Effects** (type `$1D`, `update_effect`): explosions, sparks and fire are
  objects that only play an animation script (`OBJ_ANIM`) and free
  themselves at its end. `make_effect_object` turns the slot in Y into one
  (handlers kill themselves with `txy` / `make_effect_object`),
  `spawn_effect` allocates a new one, `spawn_effect_random_offset` also
  places it at a random offset.
- **Killed soldiers**: soldier handlers jump to `start_dying_soldier` (or
  `start_dying_soldier_sprite`, `start_dying_soldier_sound_0D`,
  `start_dying_soldier_sound_0E`; all end in `start_dying_soldier_common`),
  which turn the object into type `$1B`
  (`update_dying_soldier`): thrown up and back, then an explosion.
- `get_bg_tile_at_object` reads the BG map entry under an object (plus an
  offset): floor and wall collision of grenades, debris and bouncing objects.
- **Solid objects**: `solid_object_vs_player` pushes a player out of an
  object (`solid_push_player_up`... through `tbl_solid_push_up`...);
  `solid_object_vs_object` does the same for another object (the tank pushing
  soldiers, `solid_object_vs_players_and_soldiers`).
- **Spawners**: `update_soldier_spawner` (stage 1) and
  `update_alien_soldier_spawner` (stage 6) send soldiers in from the screen
  edges, unless a big enemy (`OBJ_FLAGS` bit `$0040`, slots `$0900-$09FF`)
  is near that edge.
- **Music**: `update_song_change` (each frame, from `stage_frame`) fades and
  stops the music and loads the song set `song_change_set` when
  `song_change_mode` is set (bosses, type `$4D`).
- **Boss work variables**: `boss_work_0`-`boss_work_7` (`$1636-$1645`) are used
  by whichever big scripted object runs (stage 1 boss, spiked climber,
  ending...), with a different meaning each time.

## Hit points

An enemy's `OBJ_HP` is set by its first state, either a constant (popup
turret 16, types `$09`/`$11` 16, `$43` 64, type `$02` 256, the stage 4 tank
320) or from a table indexed by `difficulty` (0, 2, 4 = easy, normal, hard).
A shot takes `SHOT_DAMAGE` (2 for most weapons, 4 for the crush missile, 3
for the laser), the bomb and the barrier 1 per frame; the object dies when
`OBJ_HP` goes below 0, so an object with 0 HP dies at the first hit.

| table | used by | easy | normal | hard |
|---|---|---|---|---|
| `soldier_hp` | `update_foot_soldier`, type `$35` | 0 | 1 | 3 |
| `object_type_12_hp` | `update_object_type_12` | 4 | 6 | 8 |
| `object_type_31_hp` | `update_object_type_31` | 16 | 64 | `$7FFF` |
| `window_sniper_hp` | `update_window_sniper` | 4 | 6 | 8 |
| `alien_dog_hp` | `update_alien_dog` | 0 | 2 | 8 |
| `wall_hatch_hp` | `update_wall_hatch` | 4 | 8 | 16 |
| `rolling_mine_hp` | `update_rolling_mine` | 4 | 6 | 16 |
| `jumping_soldier_hp` | types `$48`, `$51` | 0 | 0 | 1 |
| `stage3_searchlight_craft_hp` | `update_stage3_searchlight_craft` | 64 | 72 | 80 |
| `alien_soldier_hp` | types `$56`, `$24` | 1 | 2 | 3 |
| `stage3_spiked_climber_hp` | `update_stage3_spiked_climber` | 96 | 160 | 184 |
| `stage3_spiked_climber_core_hp` | its core (type `$40`) | 56 | 80 | 128 |
| `hoverbike_rider_hp` | `update_hoverbike_rider` | 8 | 16 | 32 |

The stage 1 boss's HP is set by the boss controller (type `$01`,
`spawn_stage1_boss_parts`): the body (type `$29`) gets 352 on every
difficulty, the shell (type `$20`) `stage1_boss_shell_hp` = 128, 256, `$7FFF`
(so on hard the shell cannot really be destroyed); the head (`$1F`) is
invulnerable.

## Tables

The handlers' tables in `src/data/tables_05.asm` are named after the object
and the field they fill (`window_sniper_muzzle_x`,
`stage1_boss_part_types`...), with a comment saying which state reads them
and with what index. Patterns that recur:

- by `difficulty`: delays, timers, HP and frame masks (`stage1_boss_fire_intervals`,
  `soldier_spawn_delays_right`, `wall_hatch_turn_masks`: the action happens
  when `stage_frame_counter & mask` is 0);
- by aim direction: a metasprite and a muzzle offset for `spawn_enemy_bullet`
  (`window_sniper_aim_sprites`, `rolling_mine_muzzle_x`, `wall_hatch_muzzle_y`);
- debris and fragments spawned in a loop: x, y, velocity and sprite per piece
  (`stage1_boss_debris_y`, `object_type_35_debris_x_vels`), often read
  past the end into the next table (`; LAYOUT`);
- random velocities: `random_debris_vels` / `random_debris_vel_subs`, and the
  parts of the hard enemy bullet table (`enemy_bullet_speeds_hard_x`,
  `enemy_bullet_speeds_hard_y_sub`, `enemy_bullet_speeds_hard_x_sub`: the
  table at `+$10`, `+$50`, `+$60`, as `spawn_enemy_bullet` reads it);
- the stage 4 airship is placed by a spawn list of its own
  (`airship_spawn_x`, read by `scroll_bg1_by_velocity_and_spawn` as BG1
  scrolls), not by the stage's spawn pages.

Shot handlers set `SHOT_ATTR` from small frame tables (`crush_shot_attrs`,
`laser_shot_attrs`, `spent_shot_attrs`... by direction or countdown).
`circle15_x` / `circle15_y` are a 256-step circle of radius 15 (y = -15 cos,
x = 15 sin, `$00` up), used by the flame shot and by bank `$04` handlers.
Unreachable code keeps an `unused_` name saying what it does
(`unused_apply_hit_flash`, `unused_ceiling_result_01B07F`...).

## Player shots

`object_handlers_00b.asm` holds the handlers of the shot list
(`tbl_shot_types`, see [Objects](objects.md)):

| shot type | handler | weapon | damage |
|---|---|---|---|
| `$01` | `update_default_shot` | default gun (and spread after 1 frame) | 2 |
| `$02` | `update_spread_shot` | spread, first frame | 2 |
| `$03` | `update_crush_shot` | crush missile | 4 |
| `$0D` | `update_crush_blast` | crush missile's blast | 4 (8 from type `$07`) |
| `$04` | `update_homing_shot` | homing missile | 2 |
| `$05`, `$06` | `update_shot_type_05`, `update_shot_type_06` | flame (head, trail; not checked which is which) | |
| `$0A`, `$0B` | `update_laser_shot` | laser segments (delayed, then 3) | 3 |
| `$15` | `update_spent_shot` | any shot that hit without killing, bouncing back | 0 |

## Open questions

- Type `$08` is a stage trigger whose variables are not named yet.
- Type `$06` is a scripted scene (BG/HDMA) of stage 1.
- Type `$02` (stage 1 section 8, HP 256, shares `shake_and_explode_state`
  with `$34`) is not identified.
- The burning section of stage 1 (`$2B`-`$33`) and the stage 4 soldiers need
  a closer look in the emulator (the random player's bombs flash the
  screen in most captures).
