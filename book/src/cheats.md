# Cheats

Milestone 4: optional changes to the game, chosen when the ROM is built.
The default build never has any (`make` still checks the original's
SHA-1); a cheat build is the same source assembled with some `CHEAT_*`
symbols defined, so it changes the ROM's hash, and its header checksum is
recomputed.

## Building

```sh
make cheats CHEATS="infinite_lives invincible damage_mult=2"
make cheats PRESET=god-mode
python3 tools/cheats.py list          # every option with its default and description
make ips                              # IPS patches of all presets, in build/patches/
```

`CHEATS` is a list of options: a bare word sets an option to 1
(`infinite_lives` is `-D CHEAT_INFINITE_LIVES=1`), `word=n` sets it to n.
The ROM goes to `build/contra3-<options>.sfc`
(`build/contra3-infinite_lives-invincible-damage_mult2.sfc`) or
`build/contra3-<preset>.sfc`; the objects, map and debug file to
`build/cheats/<name>/`. `tools/cheats.py` does the work: it checks the
option names against `src/cheats.inc`, runs `ca65 -D ...` and `ld65`, and
fixes the checksum at `$00:FFDC` (and its complement) the way
`tools/shift.py` does for the shifted build.

## How the source does it

`src/cheats.inc` (included by `src/common.inc`) gives every option its
default when the command line did not define it, documents it and checks
its range. Each cheat is then written where it changes the game:

- an `.if CHEAT_X` / `.else` / `.endif` around the original instructions,
  which stay as they were in the `.else` branch;
- data that a cheat changes: the table keeps its original line in the
  `.else` branch (`weapon_fire_delays`, `continues_per_difficulty`), or its
  values go through a function of the option (`ENEMY_HP()`, which is the
  identity at the default);
- longer code: a routine in `src/objects/cheat_code.asm`, at the end of
  bank `$01` (the bank of the player code, with about 2 KB free), called
  from an `.if` at the hook. The file assembles to nothing in the default
  build.

New code refers to everything by label, so it moves with the rest of the
source (see [Shiftability](shiftability.md)). Bank `$00` has only 14 free
bytes, so its hooks are as small as possible: a `JSL` into bank `$01`
replaces six bytes in `update_shots`, the other bank `$00` cheats replace
instructions with ones of the same size or remove some. A build with a
cheat that no longer fits fails at link time (ld65 reports the overflow).

## The options

### Lives and death

| option | default | effect |
|---|---|---|
| `infinite_lives` | 0 | losing a life does not decrement the lives |
| `invincible` | 0 | nothing kills the player except falling off the screen (side view) or into a hole (top-down) |
| `no_pit_death` | 0 | side view: falling off the bottom of the screen respawns the player without losing a life |
| `keep_weapons` | 0 | dying does not take the weapons away |
| `start_lives` | 0 | n > 0: lives at the start of a game, instead of the OPTION setting |
| `option_30_lives` | 0 | OPTION's PLAYER setting offers 30 after 3, 5, 7 |

**Infinite lives.** Side view: `player_state_dead` takes the life with
`dec a:PLAYER_LIVES,x`; the cheat replaces it with a load of the same
size (`ldy a:PLAYER_LIVES,x`), which leaves the Z flag clear just like a
decrement that did not reach 0, so the bombs are still reset to 1.
Top-down: `topdown_lose_life` (`dec a:$10CA,x` on the stat block) is
replaced in the same way.

**Invincibility.** On the side-view stages a player is killed only through
`PCONTACT_KILLED` in `PLAYER_CONTACT` (see [Objects](objects.md)), set by
harmful objects in `update_objects`, crushing (`solid_object_vs_player`),
`kill_players_outside` and falling below the screen (`run_player_state`);
every state handler that sees it jumps to `kill_player`. So the cheat has a
single hook: the first instruction of `kill_player` calls
`cheat_filter_death`, which clears the bit and runs the state handler again
through `run_player_state_dispatch` (the dispatch at the end of
`run_player_state`), so the frame goes on as if nothing had happened. A
death below the screen (`OBJ_Y` from `$F8` down, the same test
`kill_player` uses for its sound) is let through, unless `no_pit_death`.
The barrier's side effect (enemies touched lose HP) does not come with it.

Top-down: every hit writes `$FFFF` into the player's HP field (`td_p1_hp`
for player 1) unless the barrier is on; `update_topdown_player` sends a
player with negative HP to `td_player_state_dying`. The cheat clears the
field there instead. Falling into a hole (state 9, `$2C` of the player) is
not affected.

**No pit death.** In `cheat_filter_death`, a death below the screen puts
the player into `PLAYER_STATE_OUT`, the state a dead player waits in:
`player_state_out` and `player_state_respawn` place it back on the stage
the way the respawn mode of the moment says (`tbl_respawn_placement`: on
the floor, on the bike, waiting for a missile...) with the respawn
invulnerability, but no life is taken and the weapon stays. The barrier is
lost (`player_state_out` clears it).

**Keep weapons.** `kill_player` clears the active weapon slot (both slots
when dual-firing) and `topdown_lose_life` both slots; the cheat leaves
those instructions out.

**Start lives.** `init_players` loads `option_lives` for each player; the
cheat loads the constant `CHEAT_START_LIVES` instead (an immediate load of the same size).
Up to 30 is what the game handles itself (the extra-life cap; the unused
button code gives 30); the REST counter shows two digits.

**30 lives in OPTION.** `lives_options` has a fourth entry, 30, that
`options_change_lives` never reaches (it cycles through three entries);
`options_get_lives_index` and `options_draw_lives` already handle it. The
cheat makes the cycle four entries long (`OPTION_LIVES_LAST`, 2 by
default, is the last index).

### Weapons and damage

| option | default | effect |
|---|---|---|
| `infinite_bombs` | 0 | smart bombs are not used up |
| `start_weapon` | 0 | `WEAPON_*` in slot I (the one that fires at the start) |
| `start_weapon2` | 0 | `WEAPON_*` in slot II (X swaps to it) |
| `fire_delay` | 0 | 1-8: frames between shots of every weapon (side view) |
| `damage_mult` | 1 | the players' shots (and top-down bombs) do n times their damage |

Weapons are `WEAPON_DEFAULT` (0), `WEAPON_SPREAD` (1), `WEAPON_CRUSH` (2),
`WEAPON_HOMING` (3), `WEAPON_FLAME` (4), `WEAPON_LASER` (5).

**Infinite bombs.** `check_bomb_button` and `td_check_smart_bomb` lose
their `dec` of the bomb counter (`PLAYER_BOMBS`, `$10CC` of the top-down
stat block). The player still needs at least one bomb: a game starts with
one, and a death sets it to 1.

**Start weapons.** `init_players` (new game and continue) clears the four
weapon slots; with the cheat it stores `CHEAT_START_WEAPON` into
`p1_weapon_1` / `p2_weapon_1` (slot I of the HUD, the one that fires at
the start: `update_weapon_swap` sets `PLAYER_WEAPON_SLOT` to 2 every frame
until X is pressed) and `CHEAT_START_WEAPON2` into `p1_weapon_2` /
`p2_weapon_2`. With `keep_weapons` they last the whole
game.

**Fire delay.** `weapon_fire_delays` (frames before the next shot, per
weapon: 3, 4, 5, 4, 1, 1) is replaced by one value for all six.
`run_player_state` counts the delays down and zeroes any above 8, so the
option is limited to 1-8. The shots also need free slots (10 per weapon),
which limits the real rate: holding fire with the default gun spawns 130
shots in 300 frames instead of 100. The top-down stages fire on their own
timer (`td_update_fire_timer`) and are not affected.

**Damage multiplier.** Side view: `update_shots` subtracts `SHOT_DAMAGE`
from the target's `OBJ_HP`; with the cheat it calls `cheat_shot_damage`,
which subtracts it n times (the flags of the last subtraction tell
`update_shots` whether the target died). Top-down: the 16 collision
routines that subtract a player shot's or bomb's damage (`+$06`) from a
target (`td_p1_shots_vs_enemies`, `td_p1_vs_stage2_boss`,
`td_bomb_hits_map_object_tile`...) use the macro `sbc_player_damage_x`,
which is `sbc $06,x` by default and a call of `cheat_sbc_damage_x`
otherwise. The bomb and barrier of the side view (1 HP per frame) are not
multiplied.

### Enemies

| option | default | effect |
|---|---|---|
| `enemy_hp` | 100 | percentage of their HP that enemies and bosses start with; 0: one hit kills |

Enemies get their HP in their first state, from a table by difficulty in
bank `$05` or from an immediate (see [Enemies and objects](enemies-early.md#hit-points)
and [the late banks](enemies-late.md#hp-and-difficulty), and the HP
column of [Top-down stages](topdown.md)). Every one of those values is
written `ENEMY_HP(n)` in the source: the tables (`soldier_hp`,
`stage2_boss_core_hp`, `brain_boss_hp`... 43 of them) and the immediates
(`stage3_robot_state_00`, `spawn_stage1_boss_parts`'s 352 for the stage 1
boss's body, `popup_turret_state_00`, the stage 4 tank...). `ENEMY_HP(n)`
is `n * CHEAT_ENEMY_HP / 100`, except for `HP_UNKILLABLE` and `$7FFF`
(objects that are not meant to be destroyed by shots, such as the hard
stage 1 shell and lightning pylons) and values that are not positive HP.
An object dies when its HP goes below 0, so 0 HP means the first hit. HP
that bosses set again during the fight from immediates (the skeleton
robot's 1024 in `stage3_boss_check_hp`) are scaled too; the thresholds the
bosses compare their HP against are not, so their later phases come
sooner.

Some HP tables share their bytes with other data: a few top-down tables
are also the last frame of the animation script before them
(`td_runner_hp` after the runner's script, read by `td_animate_enemy`),
`alien_dog_hp` is the sprite words of an `anim_end`, `heart_boss_hp` reads
its third entry from the next table, `stage1_boss_shell_hp` and
`lightning_pylon_hp` are read by other code too. With the cheat their
labels move to scaled copies at the end of bank `$05`
(`cheat_enemy_hp_tables`) and the original bytes stay, unlabelled, for the
other readers.

Not covered: the HP of the player's own tank (`player_tank_state_00`),
and enemy objects whose HP is not set with one of the tables or
immediates found (shots that can be shot down, for example).

### Game

| option | default | effect |
|---|---|---|
| `start_stage` | 1 | 1-6: the stage a new game starts at |
| `stage_select` | 0 | the stage select screen after the title |
| `continues` | 0 | n > 0: continues on every difficulty |
| `infinite_continues` | 0 | game over does not spend a continue |

**Start stage.** `game_mode_game_start` sets `stage_number` to 1; the
constant is `CHEAT_START_STAGE`.

**Stage select.** `game_mode_game_start` goes to
`GAME_MODE_STAGE_SELECT` when `stage_select_enabled` is set, which only
the unused button code does (and `title_menu_init` clears it on every
title). The cheat drops the test. `game_mode_stage_select` works: "STAGE
SELECT / STAGE n", Up/Down/Select change the stage, Start goes to the
stage card (checked in the emulator).

**Continues.** `continues_per_difficulty` (2, 4, 4) becomes three times
the option; `infinite_continues` replaces the `dec a:continues_left` of
`game_over_fade_in` by a load, so the count never goes negative.

### Leftovers of the developers

| option | default | effect |
|---|---|---|
| `debug_keys` | 0 | the unused debug keys run every frame |
| `button_codes` | 0 | the unused title screen codes work |

**Debug keys.** Two routines with no caller: `debug_player_keys` (side
view), now called (`JSR`) at the top of `run_player_state` for each
player, and `td_debug_cheat_buttons` (top-down), called from
`update_topdown_player` next to the other per-frame player routines. Both
read the player's own pad.

| stage | hold | press | effect |
|---|---|---|---|
| side view | Select | Up | next difficulty (`difficulty`); the bombs are set to it too |
| side view | Select | A (held) | one life left, and killed |
| side view | Select | B (held) | killed |
| side view | Select | X (held) | lives, bombs and barrier set to `$8000` |
| top-down | X | L / R | next weapon in slot 1 / 2 |
| top-down | X | A | one more bomb (up to 9) |
| top-down | X | Y | barrier `$FFFF` |
| top-down | X | B | one more life (up to 99) |

X also swaps the weapons, as in normal play.

**Button codes.** `check_30_lives_code` and `check_stage_select_code`
(see [Game flow](game-flow.md)) are called (`JSR`) at the top of
`title_menu_input`. On the title screen, on either pad: Down, Down+Right,
Right, then Start sets `option_lives` to 30 (it survives a reset, like the
other options); Down, Down+Left, Left, then Start (not on OPTION) sets
`stage_select_enabled`. The three directions must come within 16 frames
and Start within 12 more. The Down also moves the menu cursor one entry
down: entered on 1 PLAYER, the codes start a 2 PLAYERS A game. `check_button_code_unused` (Down, Down+Right... then X: a sound) is left
uncalled.

## Presets and patches

`make ips` builds each preset of `tools/cheats.py` and writes
`build/patches/contra3-<preset>.ips` with `tools/make_ips.py` (ported from
the Wario Land 3 disassembly), against `build/contra3.sfc`: the default
build is byte-identical to the original ROM, so no copy of it is needed,
and `make ips` depends on `make compare`. Each patch is applied back to the
base and compared with the cheat ROM before it is written.

| preset | options |
|---|---|
| `infinite-lives` | `infinite_lives` |
| `invincible` | `invincible` |
| `god-mode` | `invincible no_pit_death infinite_lives infinite_bombs keep_weapons` |
| `infinite-bombs` | `infinite_bombs` |
| `keep-weapons` | `keep_weapons` |
| `full-arsenal` | `start_weapon=5 start_weapon2=1 keep_weapons` (laser and spread) |
| `rapid-fire` | `fire_delay=1` |
| `double-damage` | `damage_mult=2` |
| `half-enemy-hp` | `enemy_hp=50` |
| `one-hit-kills` | `enemy_hp=0` |
| `stage-select` | `stage_select` |
| `30-lives` | `start_lives=30 option_30_lives infinite_continues` |
| `debug-keys` | `debug_keys button_codes` |

The patches apply to the original ROM (SHA-1
`265886e3f665adf2507e7b2f08b6b2ed9d0018b2`, 1 MiB, no copier header) and
only one at a time: two patches both change the header checksum, and
patches whose code moves the same bank overlap. Combine options with
`make cheats` instead. The release workflow
(`.github/workflows/release.yml`) runs `make ips` on a `v*` tag and
attaches the patches to a GitHub release; CI never needs the original ROM.

## Testing

The emulator suite of the private repository has `tests/test_cheats.py`:
it builds cheat ROMs from this repository (`C3_DISASM`, by default
`../contra3-disassembly`) with `tools/cheats.py` and checks them through
RAM reads: lives that do not go down after deaths (side view and
top-down), no death while walking into stage 1, bombs that stay, the
weapons at the start, the stage select screen, scaled HP tables, doubled
damage, the button codes, the debug keys, the 30 lives in OPTION. `make cheat-test` runs it (about 3 minutes):

```sh
make cheat-test PRIVATE=../contra3-disassembly-private
```

Besides those, a ROM with the `god-mode` options and `enemy_hp=0` was
played with the tracer's random player (no pokes): stages 1, 3, 4 and 6
were cleared (stage 6 up to the ending text) without losing a life, and the
bosses of stages 2 and 5 (started at the boss with `stage_checkpoint`)
were beaten; the random player does not find the top-down targets on its
own.

The screenshot suite (`make emu-test` with `ROM=` a cheat build) passes for
cheats that do not change what the attract mode and the stage starts show,
with one exception: the hooks that run every frame (`debug_keys`) cost a
few cycles, and the top-down attract demo, which runs close to the frame
budget, then drifts by a few frames (a death 3 frames later), so
`demo_stage2` and `demo_stage4` differ. A recorded demo replays inputs by
frame, so any change to the frame timing does that.
