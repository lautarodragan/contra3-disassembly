# Enemies and bosses: banks $02, $04, $1D

The object types whose handlers are in `src/objects/object_handlers_02.asm`,
`object_handlers_04a.asm`, `object_handlers_04b.asm` and
`object_handlers_1D.asm`: the stage 3 boss room, most of stage 4, stage 6
from its first room to the final boss, and the ending. (Stage 1, the top-down
stages 2 and 5 and the rest use other banks; see [Objects](objects.md).)

## How they were identified

In the emulator (the snes9x harness of the private repository), every stage
was played by the random player of the tracer, on NORMAL and on HARD, with
the barrier kept on. Every 8 frames the 34 slots `$0280-$0ABF` were dumped
(`OBJ_TYPE`, `OBJ_STATE`, `OBJ_HP`, position) and, for each type, a few
screenshots were saved with the slots' positions marked on them. A type is
named after what moves at its position; when the shape on screen and the code
disagree or the object is too small to tell, it keeps enemy_type_XX (as in `update_enemy_type_7C`).

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
`src/object_types.inc` (none for the update_enemy_type_XX ones yet).

## Slot `$0900`: the boss slot

The big enemies live in slot `$0900`, and some of them change type in place
when beaten:

- stage 3: `update_stage3_boss` is first a robot, then (after both robots) the
  skeleton robot, with new HP (1024, stored by `sub_048605`);
- stage 6: `update_face_boss` stores `OBJT_BRAIN_BOSS` into its own
  `OBJ_TYPE` (state 9), and when the brain is beaten `update_brain_boss`
  stores `OBJT_ENDING_SEQUENCE`: the ending is the last state machine of the
  final boss.

Objects that should not be killed by shots have `OBJ_HP` = `$0FFF` (4095):
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
| `$79` | `update_snake_robot` | body of the segmented snake robot rising from the road | `$0FFF` |
| `$81` | `update_snake_robot_head` | its head, the target | 320 |
| `$88` | `update_snake_robot_debris` | its 16 pieces when destroyed | |
| `$7A` | `update_lightning_pylon` | alien airship: hanging emitters of lightning | 64/96/`$7FFF` |
| `$7B` | `update_lightning_bolt` | the lightning bolts and their sparks | |
| `$7C` | `update_enemy_type_7C` | airship: small parts under it (not identified exactly) | 20 |
| `$7D` | `update_spiked_mine` | airship: clusters of spiked mines | |
| `$7F` | `update_airship_gun_arm` | airship: hanging cannon arms | 128 |
| `$80` | `update_enemy_type_80` | airship: seen briefly at its end (not identified exactly) | |
| `$84` | `update_helicopter_rope` | helicopter: the rope, its segments and the enemy hanging at its end (one handler, several states) | |
| `$85` | `update_enemy_type_85` | helicopter scene: a spinning projectile thrown upward (probably by the enemy on the rope) | |
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
| `$67` | `update_heart_boss_bug` | crawling bugs around it | 32/64/128 |
| `$68` | `update_enemy_type_68` | small creatures at the heart's ceiling pods (not identified exactly) | 0/2/4 |
| `$5D` | `update_cave_beast` | dark cave: controller of the hunched beast | `$0FFF` |
| `$A0` | `update_cave_beast_target` | the part of the beast that takes damage (handler: a bare `rtl`) | 320 |
| `$66` | `update_cave_rock` | rocks piling up on the floor | |
| `$70` | `update_enemy_type_70` | embers around the beast (not identified exactly) | |
| `$71` | `update_cave_beast_fireball` | projectile aimed at a player (`aim_velocity_at_player`) | |
| `$72` | `update_cave_beast_beam` | segments of the beast's beam | |
| `$5E` | `update_winged_alien` | vertical section: winged skeletal alien | 128/160/192 |
| `$25` | `update_winged_alien_tail_segment` | its 16 tail segments | |
| `$8D` | `update_winged_alien_tail_tip` | the tip of its tail | |
| `$5F` | `update_face_boss` | giant face with two side heads; becomes `update_brain_boss` | 128/256/384 |
| `$75` | `update_face_boss_side_head` | the side heads on necks | 128/192/256 |
| `$77` | `update_face_boss_neck` | neck segments | |
| `$21` | `update_face_boss_larva` | larvae spat by the central mouth | 2/4/8 |
| `$8A` | `update_brain_boss` | final boss: the giant brain (`$6F` uses the same handler; not seen) | see below |
| `$8B` | `update_brain_boss_orb_ring` | (hard) a ring of orbs bursting out of the brain | |
| `$8C` | `update_brain_boss_chain` | chain of red links swung from the brain | |
| `$8E` | `update_enemy_type_8E` | (hard) spiked orbs around the brain (not identified exactly) | |
| `$8F` | `update_enemy_type_8F` | glowing orbs thrown by the brain (not identified exactly) | |
| `$90` | `update_brain_boss_eyeball` | eyeballs thrown by the brain | 12 |
| `$91` | `update_brain_boss_rolling_eye` | eye pods rolling on the floor | |
| `$92` | `update_brain_boss_orb_arch` | arch of blue orbs forming arms | |
| `$93` | `update_brain_boss_orb` | blue orbs scattered around | |
| `$94` | `update_brain_boss_orb_cluster` | blue orbs gathering on the brain | |

### The ending

| type | handler | what | HP |
|---|---|---|---|
| `$95` | `update_ending_sequence` | the escape: helicopter, players on the missile, the lair exploding; on HARD a last creature chases the helicopter | 384 (hard) |
| `$96` | `update_enemy_type_96` | (hard) segments of the claws of that creature (not identified exactly) | |
| `$98` | `update_ending_explosion` | explosions along the floor of the lair | |
| `$9A-$9D` | `update_ending_crowd_member` | the crowd cheering under the helicopter (one handler, four types) | |
| `$9E`, `$9F` | `update_ending_crowd_walker_a`, `update_ending_crowd_walker_b` | crowd members walking back and forth | |
| `$97`, `$99` | `update_enemy_type_97`, `update_enemy_type_99` | not seen in the emulator | |

`spawn_ending_crowd` creates 6, 7 or 8 crowd members on easy, normal and
hard (`ending_crowd_counts`): a bigger crowd for a harder game.

The fireworks at the very end run in the *player-shot* list, which is free
then: `spawn_ending_firework` (called by the ending once the helicopter has
left the screen) allocates a shot slot (`find_free_shot_slot`) of type
`SHOTT_ENDING_FIREWORK` (`update_ending_firework`), which after 15 frames
bursts into 16 sparks (`spawn_firework_sparks`) of one of the types
`$17-$1A` (`update_spark_random`, `update_spark_radial`,
`update_spark_radial_fast`), falling under gravity (`apply_spark_gravity`).

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

- The exact role of `update_enemy_type_68`, `update_enemy_type_70`, `update_enemy_type_7C`,
  `update_enemy_type_80`, `update_enemy_type_85`, `update_enemy_type_8E`, `update_enemy_type_8F` and
  `update_enemy_type_96`; types `$6F`, `$97` and `$99` were never seen.
- Most helpers of these handlers still have their address names (sub_04xxxx,
  sub_1Dxxxx), as do the many animation-script and metasprite pointers they
  load as immediates (`lda #$E83B` / `sta OBJ_ANIM,x`): those are bank `$05`
  and `$06` addresses that a later milestone has to turn into labels.
