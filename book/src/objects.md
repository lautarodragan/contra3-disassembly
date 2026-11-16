# Objects

Almost everything that moves on a side-view stage is an *object*: a slot of
`$40` bytes in the main object list, run every frame by `update_objects`
(`src/objects/object_loop.asm`) which calls the slot's handler by its
type. The players' shots live in a second, smaller list (`update_shots`,
`src/objects/secondary_objects.asm`). The field offsets are constants in
`src/ram.inc` (`OBJ_*`, `PLAYER_*`, `SHOT_*`); code addresses a field with
the slot address in X (or Y), so `lda $12,x` is `lda OBJ_STATE,x`.

Use the constants only where X/Y was checked to hold a slot: the same
numbers index other structures (the target list, the OAM buffer,
animation scripts) in the same routines.

## The main object list

| slots | use | run by |
|---|---|---|
| `$0200`, `$0240` | player 1, player 2 (`player1_obj`, `player2_obj`) | `update_players` (players), drawn by `draw_players` |
| `$0280`, `$02C0` | two low-priority slots: the players' hover bikes (type `$6D`, stage 4), effects and other objects that must be drawn behind everything | `update_objects_0280` (after the main list and the players, so their sprites come last in OAM) |
| `$0300-$0ABF` | 30 slots: enemies, bosses, items, enemy bullets, effects | `update_objects` |

New objects are allocated in `$0300-$077F`: `find_free_slot` (X) and
`find_free_slot_y` (Y) return the first slot whose `OBJ_TYPE` is 0, with carry
clear; enemy bullets (`spawn_enemy_bullet`, type `$18`) search downwards from
`$0740` (`find_free_slot_y_down`, carry set when found). A slot is freed by clearing
its `$40` bytes (`OBJF_DELETE`, `OBJF_OFFSCREEN_KILL`, `delete_self_and_linked`).

### Fields

| offset | constant | meaning |
|---|---|---|
| `$00` | `OBJ_SPRITE` | metasprite pointer (bank `$06`), drawn by `draw_metasprite`; 0 = not drawn |
| `$02` | `OBJ_ATTR` | OAM attribute bits (flip, priority, palette) ORed into every sprite |
| `$04` | `OBJ_FACING` | 0: animation frames show their first sprite, else the second (mirrored) one |
| `$04` | `OBJ_ANGLE` | the same field used as an 8-bit angle (`$00` up, `$40` right, `$80` down, `$C0` left) by objects moved with `set_velocity_from_angle` (larvae, the face boss's side heads) |
| `$06` | `OBJ_HP` | hit points; below 0 = destroyed (also: not a target any more); `HP_UNKILLABLE` (`$0FFF`) for bodies whose damage goes to another object |
| `$08`/`$0A` | `OBJ_X_SUB`/`OBJ_X` | x position (fraction, pixels), screen coordinates |
| `$0C`/`$0E` | `OBJ_Y_SUB`/`OBJ_Y` | y position |
| `$10` | `OBJ_TYPE` | type: index of the handler in `tbl_object_types`; 0 = free slot |
| `$12` | `OBJ_STATE` | the handler's state |
| `$14` | `OBJ_HIT` | non-zero for the frame the object was hit (flash) |
| `$16` | `OBJ_FLAGS` | `OBJF_*` bits, below |
| `$18`/`$1A` | `OBJ_X_VEL_SUB`/`OBJ_X_VEL` | x velocity (8.8 over two words) |
| `$1C`/`$1E` | `OBJ_Y_VEL_SUB`/`OBJ_Y_VEL` | y velocity |
| `$20` | `OBJ_ANIM` | animation script (bank `$05`), 0 = none |
| `$22` | `OBJ_ANIM_TIMER` | frames left in the current animation entry |
| `$24` | `OBJ_TIMER` | general counter of the handler |
| `$26` | `OBJ_SAVED_ATTR` | `OBJ_ATTR` saved during the hit flash |
| `$28` | `OBJ_HITBOX_W` | hitbox width: x from `OBJ_X` to `OBJ_X + OBJ_HITBOX_W` |
| `$2A` | `OBJ_HITBOX_H` | hitbox height, negative: y from `OBJ_Y + OBJ_HITBOX_H` to `OBJ_Y` |
| `$2C` | `OBJ_HITBOX_RIGHT` | `OBJ_X + OBJ_HITBOX_W`, kept up to date for targets |
| `$2E` | `OBJ_HITBOX_TOP` | `OBJ_Y + OBJ_HITBOX_H`, likewise |
| `$30-$3B` | | free for the handler (recurring uses: `$3A` = the parameter given by the stage's spawn list, `$3E` = a linked slot: next segment of a trail chain, the swing a player hangs from) |
| `$3C` | `OBJ_TOUCHED_BY` | slot of the player touching the object (`OBJF_TOUCH`) |

`OBJ_FLAGS` bits:

| bit | constant | meaning |
|---|---|---|
| `$0001` | `OBJF_MOVE` | `update_objects` adds the velocity and follows the BG scroll |
| `$0002` | `OBJF_OFFSCREEN_KILL` | freed when x or y leaves `-$20..$11F` |
| `$0004` | `OBJF_HARMFUL` | touching it kills the player |
| `$0008` | `OBJF_TOUCH` | tested against the players' bodies |
| `$0010` | `OBJF_TARGET` | shots, the bomb and the barrier can hit it |
| `$0020` | `OBJF_INVULNERABLE` | hit, but no damage and no flash |
| `$4000` | `OBJF_CLANG` | a shot that hits it plays sound `$10` |
| `$8000` | `OBJF_DELETE` | freed after its handler returns |

### One frame of `update_objects`

For each slot in use, in order:

1. `OBJF_MOVE`: position += velocity, minus this frame's BG scroll
   (`bg1_x_delta`, `bg1_y_delta`), so objects stay put in the level.
2. `OBJF_OFFSCREEN_KILL`: free the slot when it is off the screen.
3. `OBJF_TARGET`: compute `OBJ_HITBOX_RIGHT`/`OBJ_HITBOX_TOP` and append the
   slot to the *target list* at `$15A0` (`target_list_end`; 0-terminated).
   The shots and the bomb only look at this list.
4. `OBJF_TOUCH`: compare the hitbox with the body box of one player (the
   one handled first this frame, alternating by `stage_frame_odd`). On overlap
   `OBJ_TOUCHED_BY` = player slot (items read this to give the weapon to
   that player) and, unless the player is invulnerable (respawn), the
   object's `OBJ_FLAGS` are ORed into the player's `PLAYER_CONTACT`. With the
   barrier, `OBJF_HARMFUL` is removed first and a target object loses 1 HP.
5. Animation: `OBJ_ANIM` points at entries of 3 words (duration, sprite,
   mirrored sprite); when `OBJ_ANIM_TIMER` runs out the next entry is
   loaded; a negative duration word is a jump to that address, 0 ends the
   script. The sprite chosen by `OBJ_FACING` goes to `OBJ_SPRITE`.
6. The handler: `call_object_handler` jumps (`JML`) through
   `tbl_object_types` (161 entries of 3 bytes in bank `$05`).
7. `OBJF_DELETE`: clear the slot. Otherwise the hit flash (if `OBJ_HIT` and
   not `OBJF_INVULNERABLE`: palette 1 for one frame), `draw_metasprite`,
   and `OBJ_HIT` = 0.

## Players

The players use the same slots with their own code (`update_players`, once
per frame, `src/objects/player.asm`): the position, velocity, sprite,
`OBJ_FACING` (0 right, 2 left) and `OBJ_STATE` fields have the same
meaning, the others differ (`PLAYER_*` in `src/ram.inc`):

| offset | constant | meaning |
|---|---|---|
| `$06`, `$10`, `$28`, `$2A` | `PLAYER_HITBOX_LEFT/BOTTOM/RIGHT/TOP` | body box, recomputed by each state |
| `$14` | `PLAYER_FIRE_DELAY_2` | frames before weapon 2 can fire again |
| `$16` | `OBJ_FLAGS` | 0 = absent; `PLAYERF_INVULNERABLE` (`$0002`); `PLAYERF_INTANGIBLE` (`$8000`) |
| `$20` | `PLAYER_POSE` | pose: index of the player frame tables (`player_frames`...) |
| `$22` | `PLAYER_JOY_HELD` | the pad's buttons held |
| `$24` | `PLAYER_INVULN_TIMER` | invulnerability after a respawn (blinking) |
| `$26` | `PLAYER_AIM` | directions held: 1 right, 2 up, 4 left, 8 down |
| `$2C` | `PLAYER_JOY_PRESSED` | the pad's buttons newly pressed |
| `$2E` | `PLAYER_LOCKED` | the "stand still" button (R) is held |
| `$3A` | `PLAYER_FIRE_DELAY_1` | frames before weapon 1 can fire again |
| `$3C` | `PLAYER_CONTACT` | `PCONTACT_*`: `$0004` killed, `$0080` on a solid object, `$0200`/`$0400` blocked left/right |

Players also have fields at slot + `$1300` (`$1500`, `$1540`):
`PLAYER_POSE_ADD`, `PLAYER_PLATFORM`, `PLAYER_DX`/`PLAYER_DY` (movement of
the frame), the bomb (`PLAYER_BOMB_RADIUS`, `PLAYER_BOMB_SPEED`,
`PLAYER_BOMB_X`/`Y`) and `PLAYER_CENTER_X`/`Y` (where enemies aim); and a
stat block at slot + `$1D80` (`$1F80`, `$1FC0`; `p1_*` / `p2_*` in the
[RAM map](ram-map.md)): `PLAYER_WEAPON_SLOT`, `PLAYER_WEAPON_1`,
`PLAYER_WEAPON_2`, `PLAYER_BARRIER`, `PLAYER_LIVES`, `PLAYER_BOMBS`,
`PLAYER_SPIN`.

### States

`OBJ_STATE` of a player selects both its input routine (`tbl_player_input`,
called by `read_player_input`) and its handler (`tbl_player_states`, called
by `run_player_state`). Identified so far (`PLAYER_STATE_*` in
`src/ram.inc`; seen in the emulator or from the code):

| state | constant | handler | |
|---|---|---|---|
| `$00` | `PLAYER_STATE_GROUND` | `player_state_ground` | standing, walking, crouching |
| `$01` | | `player_state_hang` | hanging from a bar (BG) or an object |
| `$02` | | `player_state_climb_right` | climbing a wall on the right |
| `$03` | `PLAYER_STATE_JUMP` | `player_state_jump` | jumping (somersault) |
| `$04` | `PLAYER_STATE_FALL` | `player_state_fall` | falling; also the drop-in after a respawn |
| `$05` | | `player_state_climb_left` | climbing a wall on the left |
| `$06` | `PLAYER_STATE_WAIT_MISSILE` | `respawn_on_missile` | stage 4 sky: waits for a rideable missile to be put on |
| `$07` | `PLAYER_STATE_DYING` | `player_state_dying` | thrown back |
| `$08` | `PLAYER_STATE_DEAD` | `player_state_dead` | lying dead, then a life is taken |
| `$09` | `PLAYER_STATE_ENTER_TANK` | `player_state_enter_tank` | stage 1: dropping into the tank (type `$09`) |
| `$0A` | `PLAYER_STATE_TANK` | `player_state_tank` | stage 1: driving the tank (`input_tank`) |
| `$0B` | `PLAYER_STATE_SPIN_STANCE` | `player_state_spin_stance` | L+R held |
| `$0C` | `PLAYER_STATE_SPIN_JUMP` | `player_state_jump` | spin jump, both weapons fire around |
| `$0D` | `PLAYER_STATE_HANG_CLIMB` | `player_state_hang_climb` | hanging; a wall at the side starts climbing (seen in stage 6) |
| `$0E` | `PLAYER_STATE_OUT` | `player_state_out` | waiting to respawn |
| `$0F` | `PLAYER_STATE_RESPAWN` | `player_state_respawn` | placed according to `respawn_mode` |
| `$10` | `PLAYER_STATE_HANG_OBJECT` | `player_state_hang_object` | hanging from a swing (types `$39`/`$3A`, stage 3) |
| `$11` | `PLAYER_STATE_BIKE` | `player_state_bike` | stage 4: riding the hover bike (type `$6D` in slot `$0280`/`$02C0`) |
| `$12` | `PLAYER_STATE_BIKE_INTRO` | `player_state_bike_intro` | stage 4: driving in on the bike |
| `$13` | `PLAYER_STATE_ENDING` | `player_state_ending` | ending: posing on the helicopter |
| `$14` | `PLAYER_STATE_ENDING_WAVE` | `player_state_ending_wave` | ending: pose replayed while Y is held |

States 9-`$12` were seen in the emulator (player 1's state logged every 4
frames by the random player, with a screenshot at the first frame of each),
`$13`/`$14` are set by the ending sequence. The respawn mode (`respawn_mode`)
selects a placement in `tbl_respawn_placement` (`respawn_on_floor`,
`respawn_on_right_wall`, `respawn_on_bike`, `respawn_on_missile`...) and the
state from `respawn_states`. Each state recomputes the body
box (`set_player_box_standing`, `set_player_box_jumping`,
`set_player_box_hanging`...) and `PLAYER_CENTER_X`/`Y`, and aims and fires
through a table indexed by `PLAYER_AIM` (`tbl_ground_aim`, `tbl_jump_aim`,
`tbl_fall_aim`, `tbl_hang_aim`, `tbl_climb_right_aim`,
`tbl_climb_left_aim`) whose entries choose a pose and call `fire_weapon`
with the shot angle (`$00` up, `$20` right, `$40` down, `$60` left) and the
muzzle position; the entries are named `<table>_aim_<direction>` (`ground_aim_up_right`,
`hang_aim_none`...; `none` fires the way the player faces).

### Getting killed

Nothing hurts a player directly: contact sets `PCONTACT_KILLED` in
`PLAYER_CONTACT` (touching an `OBJF_HARMFUL` object, enemies and their
bullets alike, in `update_objects`; being outside limits set by a stage
object, `kill_players_outside`; being crushed by a solid object,
`solid_object_vs_player`; falling off the bottom of the screen in
`run_player_state`), and the player's state handlers jump to `kill_player`
when they see it: death sound, knock-back (`PLAYER_STATE_DYING`), loss of
the active weapon and of the barrier, then `PLAYER_STATE_DEAD`, a life
taken (`PLAYER_LIVES`) and the bombs reset to 1. Protection:

- `PLAYER_INVULN_TIMER` after a respawn (`PLAYERF_INVULNERABLE`): contact is
  ignored;
- the barrier (`PLAYER_BARRIER`, `p1_barrier_timer`, counted down every
  frame by `run_player_state`): `OBJF_HARMFUL` is ignored and enemies touched
  lose 1 HP per frame.

### Weapons

Each player has two weapon slots (`PLAYER_WEAPON_1`, `PLAYER_WEAPON_2`;
X swaps them, `PLAYER_WEAPON_SLOT` = 2 fires weapon 1, 0 fires weapon 2)
holding a `WEAPON_*` number:

| value | constant | weapon | fire delay (`weapon_fire_delays`) |
|---|---|---|---|
| 0 | `WEAPON_DEFAULT` | the starting gun | 3 |
| 1 | `WEAPON_SPREAD` | S | 4 |
| 2 | `WEAPON_CRUSH` | C | 5 |
| 3 | `WEAPON_HOMING` | H | 4 |
| 4 | `WEAPON_FLAME` | F | 1 |
| 5 | `WEAPON_LASER` | L | 1 |

(checked by poking `p1_weapon_1` in the emulator). The fire button calls
the shot spawners of `src/objects/player_shots.asm` through one of three
tables indexed by weapon (`tbl_spin_fire_1`, `tbl_spin_fire_2`, `tbl_fire_weapon`), which
reload `PLAYER_FIRE_DELAY_1/2` from `weapon_fire_delays`. Weapon 1's shots
use the first 10 shot slots of the player, weapon 2's the next 10.
Holding L and R (`PLAYER_SPIN`) and jumping fires both, in a circle
(`spin_fire_weapon_1` / `_2`, angles `PLAYER_SPIN_ANGLE_1` / `_2`).

Shot damage (`SHOT_DAMAGE`, set by the spawners; seen in the emulator):
default gun 2, spread 2 per pellet, homing 2, laser 3, flame 1 per flame,
crush: two shot types, damage 4 and 0.

## For cheats and hacks

- Player death is only `PCONTACT_KILLED` (bit 2 of `PLAYER_CONTACT`,
  `$023C` / `$027C`), tested by every state handler before `kill_player`.
  Keeping `p1_barrier_timer` non-zero, or a non-zero `PLAYER_INVULN_TIMER`
  (`$0224`) with `PLAYERF_INVULNERABLE` in `$0216`, makes player 1 immune
  to enemies and their bullets, but not to falling off the screen
  (`run_player_state`); the barrier also does not protect from
  `kill_players_outside` called with a non-zero A.
- Lives: `p1_lives` (`dec` in `player_state_dead`); bombs: `p1_bombs`
  (`dec` in `check_bomb_button`); weapons: `p1_weapon_1` / `p1_weapon_2`
  (`WEAPON_*`), lost in `kill_player`.
- Damage to enemies: `update_shots` (`OBJ_HP` minus `SHOT_DAMAGE`; patch
  the `sbc` or the damages set by the spawners), the bomb in
  `bomb_hit_targets` (1 per frame per player), the barrier in
  `update_objects` (1 per frame).
- Fire rate: `weapon_fire_delays` (frames between shots per weapon, bank
  `$05`); the spawners also need free shot slots (10 per weapon).
- Enemy bullet speed: `ptrs_enemy_bullet_speeds` (one table for easy and
  normal, a faster one for hard).
- Respawn invulnerability: 96 frames (`respawn_player`);
  `make_players_invulnerable` is what bosses and stage ends use.
- The stage 1 boss's body has 352 HP on every difficulty (`spawn_stage1_boss_parts`,
  `lda #$0160 / sta a:obj_slots+8*OBJ_SIZE+OBJ_HP`); its shell has `stage1_boss_shell_hp` (128, 256,
  and `$7FFF` on hard).
- Unused debug code: `debug_player_keys` (Select + Up: difficulty, Select
  + X: lives, bombs and barrier `$8000`) has no caller.

## Player shots: the secondary list

40 slots of `$20` bytes at `$0AC0-$0FBF`: player 1's shots in
`$0AC0-$0D3F`, player 2's in `$0D40-$0FBF`. `update_shots` calls each
shot's handler through `tbl_shot_types`, draws it as a single sprite, moves
it, frees it off the screen, and tests it against the target list:

| offset | constant | meaning |
|---|---|---|
| `$02` | `SHOT_ATTR` | tile and attributes; bit 8 (`SHOTA_LARGE`): 16x16 |
| `$06` | `SHOT_DAMAGE` | subtracted from the target's `OBJ_HP` |
| `$08-$0E` | `OBJ_X_SUB`... | position, as in the main list |
| `$10` | `SHOT_TYPE` | handler index in `tbl_shot_types`; 0 = free |
| `$16` | `SHOT_HIT` | 1 = hit something, negative = destroyed it |
| `$18-$1E` | `OBJ_X_VEL_SUB`... | velocity |

**Damage to enemies** is computed in `update_shots`: the target's
`OBJ_HP` -= `SHOT_DAMAGE` (skipped for `OBJF_INVULNERABLE`); when it goes
negative the shooter scores `type_scores[OBJ_TYPE]` (BCD, `add_score_for_player_obj`).
The bomb (`bomb_hit_targets`) and the barrier (`update_objects`) take 1 HP per
frame. Each player's shots are only tested every other frame.

## Sprites

`draw_metasprite` appends an object's metasprite (bank `$06`: a count,
then 4 bytes per sprite: dx, dy, tile, attributes) to the OAM buffer at
`oam_ptr` (`$0FC0`), with the size/x-high bits packed in `oam_hi_bits`
and written at `oam_hi_ptr` (`$11C0`). It adds the screen shake
(`shake_bg1_y`) to y.
