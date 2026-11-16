# Enemies and bosses: banks $02, $04, $1D

The object types whose handlers are in `src/objects/object_handlers_02.asm`,
`object_handlers_04a.asm`, `object_handlers_04b.asm` and
`object_handlers_1D.asm`: the stage 3 boss room, most of stage 4, stage 6
from its first room to the final boss, and the ending. (Stage 1, the top-down
stages 2 and 5 and the rest use other banks; see [Objects](objects.md).)

## How they were identified

In the emulator (the snes9x harness, see [Emulator tests](emulator.md)), every stage
was played by the random player of the tracer, on NORMAL and on HARD, with
the barrier kept on. Every 8 frames the 34 slots `$0280-$0ABF` were dumped
(`OBJ_TYPE`, `OBJ_STATE`, `OBJ_HP`, position) and, for each type, a few
screenshots were saved with the slots' positions marked on them. A type is
named after what moves at its position; when the shape on screen and the code
disagree or the object is too small to tell, it keeps a generic enemy_type_XX name.

## How a handler looks

`call_object_handler` jumps to the type's entry in `tbl_object_types` with
X = the slot. Almost every handler then dispatches on `OBJ_STATE`:

```text
update_ending_crowd_walker_a:
        lda     OBJ_STATE,x
        phx
        asl     a
        tax
        lda     f:tbl_ending_crowd_walker_a_states,x
        plx
        sta     zp_00
        jmp     (zp_00)
```

The state routines are named `<enemy>_state_NN`, NN being the (first)
`OBJ_STATE` value that selects them; state 0 usually sets the sprite
attributes, `OBJ_FLAGS`, the hitbox and `OBJ_HP` and increments the state.
Many state routines fall through into the next one. A boss usually checks
`OBJ_HP` before dispatching: negative HP switches it to its death states
(explosions, then the next stage section).

Types in the table below have an `OBJT_*` constant in
`src/object_types.inc`.

## Slot `$0900`: the boss slot

The big enemies live in slot `$0900`, and some of them change type in place
when beaten:

- stage 3: `update_stage3_boss` is first a robot, then (after both robots) the
  skeleton robot, with new HP (1024, stored by `stage3_boss_check_hp`);
- stage 6: `update_face_boss` stores `OBJT_BRAIN_BOSS` into its own
  `OBJ_TYPE` (state 9), and when the brain is beaten `update_brain_boss`
  stores `OBJT_ENDING_SEQUENCE`: the ending is the last state machine of the
  final boss.

Objects that should not be killed by shots have `OBJ_HP` = `HP_UNKILLABLE` (`$0FFF`, 4095):
`update_cave_beast`, `update_snake_robot`; the part that takes damage is a
separate object (`update_cave_beast_target`, `update_snake_robot_head`).

## The types

HP is the initial `OBJ_HP`: one number when it is fixed, easy/normal/hard
when it is read from a table indexed by `difficulty`.

### Stage 3

| type | handler | what | HP |
|---|---|---|---|
| `$41` | `update_stage3_boss` | boss room: the first humanoid robot lowered on cables (states `$00-$09`), then the giant skeleton robot breaking through the back wall (states `$0A-$1A`) | 320, then 1024 |
| `$44` | `update_stage3_robot_cables` | the cables that lower the robots; waits for state 3 of slot `$0900` | |
| `$45` | `update_stage3_second_robot` | the second robot (slot `$08C0`); shares the robot states (`stage3_robot_state_00`...) | 320 |
| `$4C` | `update_countdown_bomb` | skeleton robot: numbered bombs ("3", "2", "1") stuck to the walls | |
| `$87` | `update_skeleton_eye_fireball` | skeleton robot: fireballs from its eyes | |

### Stage 4

| type | handler | what | HP |
|---|---|---|---|
| `$64` | `update_stage4_controller` | invisible controller of the whole stage (32 states): bike scenes, airship, helicopter, boss | |
| `$65` | `update_rideable_missile` | the missiles the players stand on in the sky; also the missile under the helicopter in the ending (slot `$0280`) | |
| `$79` | `update_snake_robot` | body of the segmented snake robot rising from the road; it walks on two segmented legs (feet in slots `$0300`, `$0700`, 256 HP each) | `$0FFF` |
| `$81` | `update_snake_robot_head` | its head, the target | 320 |
| `$88` | `update_snake_robot_debris` | its 16 pieces when destroyed | |
| `$7A` | `update_lightning_pylon` | alien airship: hanging emitters of lightning | 64/96/`$7FFF` |
| `$7B` | `update_lightning_bolt` | the lightning bolts and their sparks | |
| `$7C` | `update_airship_turret` | airship: dome gun turrets under the hull (seen in the emulator), aimed at a player (3 frames drawn on BG), firing enemy bullets | 20 |
| `$7D` | `update_spiked_mine` | airship: clusters of spiked mines | |
| `$7F` | `update_airship_gun_arm` | airship: hanging cannon arms | 128 |
| `$80` | `update_airship_gun_arm_shell` | shell fired by a gun arm (seen in the emulator): down at 45 degrees trailing smoke, then burns along the road | |
| `$84` | `update_helicopter_rope` | helicopter: the rope, its segments and the enemy hanging at its end (one handler, several states) | |
| `$85` | `update_helicopter_rope_boomerang` | helicopter scene: spinning blade thrown by the enemy on the rope (`helicopter_rope_state_0A`; seen in the emulator), flies out and comes back | |
| `$69` | `update_stage4_boss` | boss: green armoured flying fortress with a red eye | 384 |
| `$6A` | `update_stage4_boss_pod` | its upper and lower pods | 128 |
| `$82` | `update_stage4_boss_shot` | its spread shots | |
| `$83` | `update_stage4_boss_fireball` | fireballs from the eye (can be shot down) | 16 |

### Stage 6

| type | handler | what | HP |
|---|---|---|---|
| `$5B` | `update_wall_worm` | the giant worm bursting from the wall at the start | 64/128/256 |
| `$63` | `update_wall_worm_larva` | larvae it spits | 4/8/16 |
| `$61` | `update_floor_mouth` | toothed mouths in the floor | 32/40/48 |
| `$62` | `update_floor_mouth_bug` | bugs they release | 1/1/2 |
| `$58` | `update_heart_boss` | the giant heart with tendrils | 128/256/384 |
| `$67` | `update_heart_boss_bug` | crawling bugs around it, drawn on BG (tile scripts); they release type `$68` | 32/64/128 |
| `$68` | `update_heart_boss_crawler` | grey crawlers coming out of the heart's bugs (seen in the emulator); they walk on the ceiling (y `$48`) or the floor (y `$B8`) and drop or jump to the other side when level with a player | 0/2/4 |
| `$5D` | `update_cave_beast` | dark cave: controller of the hunched beast | `$0FFF` |
| `$A0` | `update_cave_beast_target` | the part of the beast that takes damage (handler: a bare `rtl`) | 320 |
| `$66` | `update_cave_rock` | rocks piling up on the floor | |
| `$70` | `update_cave_beast_ember` | fiery embers the beast sprays (`cave_beast_state_14`; seen in the emulator): thrown up, falling, harmful | |
| `$71` | `update_cave_beast_fireball` | projectile aimed at a player (`aim_velocity_at_player`) | |
| `$72` | `update_cave_beast_beam` | segments of the beast's beam | |
| `$5E` | `update_winged_alien` | vertical section: winged skeletal alien | 128/160/192 |
| `$25` | `update_winged_alien_tail_segment` | its 16 tail segments | |
| `$8D` | `update_winged_alien_tail_tip` | the tip of its tail | |
| `$5F` | `update_face_boss` | giant face with two side heads; becomes `update_brain_boss` | 128/256/384 |
| `$75` | `update_face_boss_side_head` | the side heads on necks | 128/192/256 |
| `$77` | `update_face_boss_neck` | neck segments | |
| `$21` | `update_face_boss_larva` | larvae spat by the central mouth | 2/4/8 |
| `$8A` | `update_brain_boss` | final boss: the giant brain (type `$6F` has the same handler but is never created: no code stores `$6F`) | see below |
| `$8B` | `update_brain_boss_orb_ring` | (hard) a ring of orbs bursting out of the brain | |
| `$8C` | `update_brain_boss_chain` | chain of red links swung from the brain | |
| `$8E` | `update_brain_boss_spiked_ball` | spiked balls launched from its mouth, falling and exploding on the floor (seen on NORMAL and HARD) | |
| `$8F` | `update_brain_boss_encircling_orb` | (attack 2) spiked orbs circling a player, closing in, blinking, then bursting (seen in the emulator) | |
| `$90` | `update_brain_boss_eyeball` | eyeballs thrown by the brain | 12 |
| `$91` | `update_brain_boss_rolling_eye` | eye pods rolling on the floor | |
| `$92` | `update_brain_boss_orb_arch` | arch of blue orbs forming arms | |
| `$93` | `update_brain_boss_orb` | blue orbs scattered around | |
| `$94` | `update_brain_boss_orb_cluster` | blue orbs gathering on the brain | |

### The ending

| type | handler | what | HP |
|---|---|---|---|
| `$95` | `update_ending_sequence` | the escape: helicopter, players on the missile, the lair exploding; on HARD only, a last creature (the brain's final, armoured form) chases the helicopter; the closing message; on HARD the pictures, credits and crowd (below) | 384 (hard) |
| `$96` | `update_ending_creature_claw_segment` | (hard) segments of the claws of that creature (`ending_creature_spawn_claw`; seen in the emulator) | |
| `$98` | `update_ending_explosion` | explosions along the floor of the lair | |
| `$9A-$9D` | `update_ending_crowd_member` | the crowd cheering under the helicopter (one handler, four types) | |
| `$9E`, `$9F` | `update_ending_crowd_walker_a`, `update_ending_crowd_walker_b` | crowd members walking back and forth | |
| `$97` | `ending_init_text_screen` | not an object handler: the setup of the ending's text screen, called with `jsr` by `ending_sequence_state_1E`; it ends with `rts`, so run as a handler (`jsl`) it would crash. Never spawned | |
| `$99` | `update_unused_type_99` | does nothing (rtl). Unused: no code creates it, never run in the CDL traces | |

The ending object's states (`tbl_ending_sequence_states`), as the emulator
plays `stage6_ending_easy`, `stage6_boss` (NORMAL) and `stage6_ending_hard`
run them from the brain's death ([Emulator tests](emulator.md)):

| states | what | difficulty |
|---|---|---|
| `$00-$07` | the helicopter comes down, the players grab the missile, it lifts them; `ending_sequence_state_07` branches on `difficulty` | all |
| `$08-$0E` | the brain's last form rises and chases the helicopter, its claws (`$96`) reaching up; 384 HP, shot from the missile. When its HP goes below 0, `update_ending_sequence` jumps to `$0F` | HARD only |
| `$25-$28` | instead: the lair shakes and explodes, the view scrolls up (`ending_shake_and_explode`, `ending_start_vertical_autoscroll`), then on to `$10` | EASY, NORMAL |
| `$0F-$16` | (`$0F`: the last form falls away) the flight out of the lair, over the clouds and the sea, and the fade out | all |
| `$17`, `$18` | the closing message: `ptrs_ending_message_loads` by `difficulty` (the BG3 maps `ending_message_easy`, `_normal`, `_hard`), faded in | all |
| `$29`, `$2A` | PUSH START KEY; Start ends the stage, and the game loops to stage 1 one level up ([Game flow](game-flow.md#after-stage-6-the-loop)) | EASY, NORMAL |
| `$19-$1D` | five pictures (`ptrs_05FDBC`, `boss_work_4` 0-8) over the message | HARD |
| `$1E-$24` | the staff credits over the helicopter (`ending_init_text_screen`, `ending_run_text_script`), the crowd and the fireworks; then the stage ends and the game goes to FINAL SCORE | HARD |

So the last form, the credits and the crowd are only seen on HARD.
`spawn_ending_crowd` creates 6, 7 or 8 crowd members on easy, normal and
hard (`ending_crowd_counts`), but only the HARD ending reaches it.

The fireworks at the very end run in the *player-shot* list, which is free
then: `spawn_ending_firework` (called by the ending once the helicopter has
left the screen) allocates a shot slot (`find_free_shot_slot`) of type
`SHOTT_ENDING_FIREWORK` (`update_ending_firework`), which after 15 frames
bursts into 16 sparks (`spawn_firework_sparks`) of one of the types
`$17-$1A` (`update_spark_random`, `update_spark_radial`,
`update_spark_radial_fast`), falling under gravity (`apply_spark_gravity`).

## Shared helpers

- Bosses drawn on BG2 flash by uploading a white palette while hit
  (`boss_flash_palette`, `flash_palette_on_hit`), scroll BG2 to follow their
  object (`winged_alien_set_bg2_scroll`, `cave_beast_set_bg2_scroll`,
  `face_boss_place_parts`) and redraw parts of themselves through the VRAM
  block queue (`queue_vram_blocks`).
- Chains (the helicopter rope, the brain boss's chain, the skeleton robot's
  eye fireballs, the claws of the last creature of the ending) are trail
  chains: `spawn_trail_chain` creates type `$86` segments that replay the
  positions of the segment before them from ring buffers at `$7E:E000`
  (`trail_segment_follow`, `trail_pass_to_next`, `delete_trail_chain`).
- The brain boss picks an attack in `boss_work_0` (0-7):
  `tbl_brain_boss_attack_starts` starts it, `tbl_brain_boss_attacks` runs it
  every frame (attacks 4 and 5 are step sequences,
  `tbl_brain_boss_attack_4_steps`, `tbl_brain_boss_attack_5_steps`).
- The winged alien runs a script of steps (`winged_alien_run_step`,
  `tbl_winged_alien_steps`). It vanishes and reappears stretched into
  vertical lines (`winged_alien_warp_out`, `winged_alien_warp_in`): a
  per-line BG2 vertical scroll table for HDMA (preset `$0F`) whose height
  shrinks or grows by 4 lines per frame.
- The face boss has more parts than its heads: two eyes (slots 6, 7, type
  `$53`, HP `face_boss_eye_hp` 64/128/256) that look towards the players
  (`face_boss_update_eyes`), and once both heads are gone it spawns alien
  soldiers (type `$24`) on their sides (`face_boss_spawn_soldier_at_lost_head`).
  When it dies, BG blocks erase the face and uncover the brain
  (`face_boss_death_tiles_step`, `face_boss_reveal_brain_step`).
- The side heads lunge at a player recording their path in RAM buffers
  (`face_boss_side_head_path_buffers`, `$1900`/`$1A00`), pull their neck
  segments after them (`face_boss_side_head_spawn_neck`) and return along
  the path; every 32 frames the face makes them fire three bullets
  (`face_boss_make_heads_fire`, `face_boss_side_head_fire`).
- The snake robot's legs are placed either by angles around the hips
  (`snake_robot_place_legs_by_angle`) or as midpoints between hip and foot
  (`snake_robot_place_legs_between`); the body follows the feet
  (`snake_robot_walk_body`).
- Stage 4's opening shows hover-bike riders passing in the background:
  type `$53` objects that do nothing (`stage4_spawn_passing_rider`); after
  the missile is dropped, BG1 HDMA bands fly the helicopter away
  (`rideable_missile_helicopter_leaves`).

## HP and difficulty

The per-difficulty HP tables are in `src/data/tables_05.asm`, two bytes per
difficulty (`difficulty` is 0, 2, 4):
`wall_worm_hp`, `wall_worm_larva_hp`, `floor_mouth_hp`,
`floor_mouth_bug_hp`, `heart_boss_hp`, `heart_boss_bug_hp`,
`winged_alien_hp`, `face_boss_hp`, `face_boss_side_head_hp`,
`face_boss_larva_hp`, `lightning_pylon_hp`, `brain_boss_hp`. The fixed ones
are immediates in the state 0 routines (for example `lda #$0140` /
`sta OBJ_HP,x` in `stage3_robot_state_00`).

Oddities:

- `lightning_pylon_hp` has two entries ($40, $60); on HARD the code reads the
  following word, `$7FFF`, so the pylons can't really be destroyed.
- `brain_boss_hp` is `$0401`, `$4256`, `$7532` (1025, 16982, 29986): the
  brain is beaten in phases, `brain_boss_state_06` halves `OBJ_HP` when it is
  at least `$100`, and the attacks change with the HP left. Why easy starts
  so much lower than normal is not understood yet.
- Bodies that must not die from shots use 4095 (`$0FFF`).

## Open questions

- Types `$6F` and `$99` are never created (`$97` is not a real object
  type, see the table).
- The helpers and tables of these handlers are named, except `sub_04C3A2`
  (never called). Many names of BG block tables say what the code does with
  them (`stage3_boss_state_0C_delays`, `ptrs_rideable_missile_anim_blocks`)
  but not what the blocks show.
