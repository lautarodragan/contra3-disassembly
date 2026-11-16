; object_types.inc -- object type numbers (OBJ_TYPE values)
;
; OBJ_TYPE (+$10) of a slot of the main object list selects its handler in
; tbl_object_types (161 long pointers, index x3). One constant per line,
; sorted by value; types not identified yet have no constant. Shot types
; (SHOT_TYPE, tbl_shot_types) are at the end.

.ifndef OBJECT_TYPES_INC
OBJECT_TYPES_INC = 1

OBJT_STAGE1_BOSS_CONTROLLER     = $01	; stage 1 boss (giant turtle): invisible controller (update_stage1_boss_controller)
OBJT_MIDBOSS_TANK               = $02	; stage 1 mid-boss: tank crashing down through a building (BG2), HP 256
OBJT_BARRICADE                  = $04	; stage 1 section 4: armored barricade, collapses when its core (type $14) is destroyed
OBJT_BOMBER_RAID                = $06	; stage 1: Mode 7 bomber plane, then the burning street (scene controller)
OBJT_SCROLL_STOP_TRIGGER        = $08	; stage trigger: stops the BG1 scroll (bg1_scroll_mode 4)
OBJT_PLAYER_TANK                = $09	; tank the players can drive (stage 1)
OBJT_FOOT_SOLDIER               = $0A	; running foot soldier (update_foot_soldier)
OBJT_SOLDIER_SPAWNER            = $0B	; invisible: sends foot soldiers in from the screen edges
OBJT_BOMBER_BOMB                = $0C	; bomb of the stage 1 bomber plane
OBJT_POPUP_TURRET               = $0D	; gun turret rising from the rubble (stage 1)
OBJT_WEAPON_CAPSULE             = $0F	; flying weapon capsule
OBJT_BOUNCING_DEBRIS            = $10	; debris that bounces and blinks out
OBJT_WRECKED_CAR                = $11	; stage 1: wrecked car, solid, HP 16; explodes into debris
OBJT_GRENADE_SOLDIER            = $12	; stage 1: soldier throwing grenades (type $13), HP 6
OBJT_GRENADE                    = $13	; grenade thrown by soldiers
OBJT_BARRICADE_CORE             = $14	; the barricade's red core, HP 64
OBJT_BARRICADE_CANNON           = $15	; cannon on the barricade, HP 40; lobs type $16
OBJT_BARRICADE_CANNONBALL       = $16	; ball lobbed by a barricade cannon
OBJT_WINDOW_SNIPER              = $17	; sniper in a window (stages 1, 3)
OBJT_ENEMY_BULLET               = $18	; enemy bullet
OBJT_UNUSED_PUFF_EFFECT         = $19	; smoke puff then a burst; never created
OBJT_GRENADE_BLAST              = $1A	; explosion of a grenade
OBJT_DYING_SOLDIER              = $1B	; killed soldier thrown back (start_dying_soldier)
OBJT_MIDBOSS_TANK_SHELL         = $1C	; shell thrown by the mid-boss tank (type $02)
OBJT_EFFECT                     = $1D	; animation effect: explosion, spark, fire (make_effect_object)
OBJT_ALIEN_DOG                  = $1E	; alien dog (stage 1)
OBJT_STAGE1_BOSS_HEAD           = $1F	; stage 1 boss: the head (invulnerable target)
OBJT_STAGE1_BOSS_PART           = $20	; stage 1 boss (giant turtle), part with HP 256
OBJT_FACE_BOSS_LARVA            = $21
OBJT_STAGE1_BOSS_WALL_CHUNK     = $22	; stage 1 boss: chunk of the wall it bursts through
OBJT_FALLING_DEBRIS             = $23	; wall debris falling in the stage 1 boss fight
OBJT_FACE_BOSS_SOLDIER          = $24	; stage 6: alien soldier dropped where a face boss side head was
OBJT_WINGED_ALIEN_TAIL_SEGMENT  = $25
OBJT_STAGE1_BOSS_TRACKING_SHOT  = $26	; stage 1 boss projectile following the player's height
OBJT_STAGE1_BOSS_FALLING_SHOT   = $27	; stage 1 boss projectile that falls and rolls
OBJT_STAGE1_BOSS                = $29	; stage 1 boss (giant turtle), main body, HP 352
OBJT_BOMBER_RAID_END_TRIGGER    = $2A	; stage trigger: puts the fire out (bomber raid state 8), deletes the fire jet
OBJT_HOPPING_FIREBALL           = $2B	; stage 1 fire: fireball hopping out of the fire, trailing type $2E
OBJT_FLAME_GEYSER               = $2C	; stage 1: invisible, shoots flames (type $2D) up from the floor
OBJT_FLAME_GEYSER_FLAME         = $2D
OBJT_FALLING_FLAME              = $2E	; harmful flame falling back into the fire
OBJT_FIRE_JET                   = $2F	; stage 1 fire: invisible, spews arcs of flames (type $30)
OBJT_FIRE_JET_FLAME             = $30
OBJT_LEAPING_FIREBALL           = $31	; stage 1 fire: fireball leaping out of the fire, HP 64
OBJT_ERUPTION_FIREBALL          = $32
OBJT_FIRE_ERUPTION              = $33	; stage 1 fire: invisible, throws fireballs (type $32) up, shakes the screen
OBJT_SNIPER_BUNKER              = $34	; stage 1: bunker of a window sniper; sends soldiers out, blown up with the sniper
OBJT_WINDOW_JUMPER              = $35	; stage 1: soldier crashing out through a window, then a foot soldier
OBJT_STAGE1_BOSS_FIRE           = $38	; stage 1 boss fire breath
OBJT_SWING_PIVOT                = $39	; stage 3: pivot of a rotating swing the players hang from
OBJT_SWING_HANDLE               = $3A	; stage 3: handle on a swing's arm
OBJT_STAGE3_FUNNEL_CLOUDS       = $3C	; stage 3 start: animates the funnel clouds, slants BG2 (slot 27)
OBJT_STAGE3_SPIKED_CLIMBER      = $3D	; stage 3 mid-boss climbing the girder, HP 160
OBJT_STAGE3_SPIKED_CLIMBER_BODY = $3E	; spiked climber: spiked body (slot $0340); handler does nothing
OBJT_STAGE3_SPIKED_CLIMBER_SPIKE = $3F	; spiked climber: the spike it thrusts up
OBJT_STAGE3_SPIKED_CLIMBER_CORE = $40	; its weak point, HP 80
OBJT_STAGE3_BOSS                = $41
OBJT_RESPAWN_CLAMP_TRIGGER      = $42	; stage trigger: clamp_player_top, respawn_mode from fields $3A/$3B
OBJT_STAGE3_BREAKABLE_WALL      = $43	; stage 3: wall closing the way into the building, HP 64
OBJT_STAGE3_ROBOT_CABLES        = $44
OBJT_STAGE3_SECOND_ROBOT        = $45
OBJT_DEBRIS_EXPLOSION           = $46	; explosion on a solid BG tile
OBJT_HOMING_MISSILE             = $47	; small missile homing on a player (update_homing_missile)
OBJT_JUMPING_SOLDIER            = $48	; stage 3: green soldier jumping between platforms (update_jumping_soldier)
OBJT_JUMPING_SOLDIER_SPAWNER    = $49	; stage 3: invisible, lets out type $48 in bursts
OBJT_ROLLING_MINE               = $4A	; rolling disc (stage 3)
OBJT_DEBRIS_SPARK               = $4B	; effect flying in a random direction
OBJT_COUNTDOWN_BOMB             = $4C
OBJT_SONG_CHANGE_TRIGGER        = $4D	; stage trigger: song change (update_song_change_trigger)
OBJT_STAGE3_SEARCHLIGHT_CRAFT   = $4E	; stage 3 mid-boss: flying craft with a searchlight (BG2)
OBJT_STAGE3_WINGED_BUG          = $4F	; winged alien bug (stage 3)
OBJT_WALL_HATCH                 = $50	; wall hatch (stage 3)
OBJT_DROPPED_JUMPING_SOLDIER    = $51	; as $48, dropped by the searchlight craft (starts with a jump)
OBJT_PASSIVE_PART               = $53	; hitbox moved by another object; handler does nothing
OBJT_STAGE6_BG_TILE_ANIMATOR    = $55	; stage 6: animates BG tiles (slot 27)
OBJT_ALIEN_SOLDIER              = $56	; stage 6: running alien soldier (sent by type $5C)
OBJT_BG2_SCREEN_SIZE_TRIGGER    = $57	; stage trigger: BG2SC screen size from field $3A; unused
OBJT_HEART_BOSS                 = $58
OBJT_STAGE3_SPIKED_CLIMBER_ARM  = $5A	; stage 3 spiked climber: arm segments, spiked body
OBJT_WALL_WORM                  = $5B
OBJT_ALIEN_SOLDIER_SPAWNER      = $5C	; stage 6: sends alien soldiers (type $56) in from the edges
OBJT_CAVE_BEAST                 = $5D
OBJT_WINGED_ALIEN               = $5E
OBJT_FACE_BOSS                  = $5F
OBJT_FLOOR_MOUTH                = $61
OBJT_FLOOR_MOUTH_BUG            = $62
OBJT_WALL_WORM_LARVA            = $63
OBJT_STAGE4_CONTROLLER          = $64
OBJT_RIDEABLE_MISSILE           = $65
OBJT_CAVE_ROCK                  = $66
OBJT_HEART_BOSS_BUG             = $67
OBJT_HEART_BOSS_CRAWLER         = $68	; stage 6: crawler out of the heart boss pods
OBJT_STAGE4_BOSS                = $69
OBJT_STAGE4_BOSS_POD            = $6A
OBJT_DESTRUCTIBLE_PART          = $6B	; part of a bigger enemy that explodes when destroyed
OBJT_DESTRUCTIBLE_PART_2        = $6C	; as $6B, other explosion (never created: no spawn found, never run in the CDL traces)
OBJT_PLAYER_BIKE                = $6D	; stage 4: a player's hover bike (slots $0280/$02C0)
OBJT_STAGE4_TANK                = $6E	; tank at the start of stage 4, HP 315
OBJT_CAVE_BEAST_EMBER           = $70	; stage 6: ember sprayed by the cave beast
OBJT_CAVE_BEAST_FIREBALL        = $71
OBJT_CAVE_BEAST_BEAM            = $72
OBJT_JETPACK_SOLDIER            = $73	; stage 4: jetpack soldier under the airship
OBJT_HOVERBIKE_RIDER            = $74	; enemy on a hover bike (stage 4)
OBJT_FACE_BOSS_SIDE_HEAD        = $75
OBJT_HOVERBIKE_RIDER_BOMB       = $76	; stage 4: bomb of a hover-bike rider, burns on the road
OBJT_FACE_BOSS_NECK             = $77
OBJT_HOVERBIKE_RIDER_SHOT       = $78	; stage 4: shot of a hover-bike rider
OBJT_SNAKE_ROBOT                = $79
OBJT_LIGHTNING_PYLON            = $7A
OBJT_LIGHTNING_BOLT             = $7B
OBJT_AIRSHIP_TURRET             = $7C	; stage 4: dome gun turret under the airship, HP 20
OBJT_SPIKED_MINE                = $7D
OBJT_AIRSHIP_HANGING_SOLDIER    = $7E	; stage 4: soldier hanging from the airship hull
OBJT_AIRSHIP_GUN_ARM            = $7F
OBJT_AIRSHIP_GUN_ARM_SHELL      = $80	; stage 4: shell fired by an airship gun arm
OBJT_SNAKE_ROBOT_HEAD           = $81
OBJT_STAGE4_BOSS_SHOT           = $82
OBJT_STAGE4_BOSS_FIREBALL       = $83
OBJT_HELICOPTER_ROPE            = $84
OBJT_HELICOPTER_ROPE_BOOMERANG  = $85	; stage 4: blade thrown by the enemy on the rope
OBJT_TRAIL_SEGMENT              = $86	; segment of a chain following its leader's path (spawn_trail_chain)
OBJT_SKELETON_EYE_FIREBALL      = $87
OBJT_SNAKE_ROBOT_DEBRIS         = $88
OBJT_CHECKPOINT_TRIGGER         = $89	; stage trigger: sets stage_checkpoint (stage 3)
OBJT_BRAIN_BOSS                 = $8A
OBJT_BRAIN_BOSS_ORB_RING        = $8B
OBJT_BRAIN_BOSS_CHAIN           = $8C
OBJT_WINGED_ALIEN_TAIL_TIP      = $8D
OBJT_BRAIN_BOSS_SPIKED_BALL     = $8E	; final boss: spiked ball launched from the mouth
OBJT_BRAIN_BOSS_ENCIRCLING_ORB  = $8F	; final boss: orb circling a player
OBJT_BRAIN_BOSS_EYEBALL         = $90
OBJT_BRAIN_BOSS_ROLLING_EYE     = $91
OBJT_BRAIN_BOSS_ORB_ARCH        = $92
OBJT_BRAIN_BOSS_ORB             = $93
OBJT_BRAIN_BOSS_ORB_CLUSTER     = $94
OBJT_ENDING_SEQUENCE            = $95
OBJT_ENDING_CREATURE_CLAW_SEGMENT = $96	; ending (HARD): claw segment of the last creature
OBJT_ENDING_EXPLOSION           = $98
OBJT_ENDING_CROWD_MEMBER_A      = $9A
OBJT_ENDING_CROWD_MEMBER_B      = $9B
OBJT_ENDING_CROWD_MEMBER_C      = $9C
OBJT_ENDING_CROWD_MEMBER_D      = $9D
OBJT_ENDING_CROWD_WALKER_A      = $9E
OBJT_ENDING_CROWD_WALKER_B      = $9F
OBJT_CAVE_BEAST_TARGET          = $A0

; Shot types (SHOT_TYPE, tbl_shot_types): the player shots
; (object_handlers_00b.asm) and the ending fireworks ($16-$1A,
; object_handlers_02.asm).
SHOTT_DEFAULT                   = $01	; default gun bullet (and spread bullets after their first frame)
SHOTT_SPREAD                    = $02	; spread gun bullet, first frame
SHOTT_CRUSH                     = $03	; crush missile
SHOTT_HOMING                    = $04	; homing missile
SHOTT_LASER                     = $0B	; laser segment
SHOTT_CRUSH_BLAST               = $0D	; blast of a crush missile
SHOTT_SPENT                     = $15	; shot bouncing back after a hit that did not destroy the target
SHOTT_ENDING_FIREWORK           = $16
SHOTT_SPARK_RANDOM              = $17
SHOTT_SPARK_RADIAL              = $18
SHOTT_SPARK_RADIAL_FAST         = $19
SHOTT_SPARK_RANDOM_B            = $1A

; ---- top-down stages (src/topdown/) ----
; Their objects have their own type numbers (see Top-down stages in the
; book for the slots). HP values are easy / normal / hard; an object dies
; when its HP (+$06) goes negative.
;
; Enemy types (+$10 of the slots $0D40-$0EBF, and of the stage 5 boss arm
; in $0B40-$0EBF; handlers in tbl_td_enemy_types).
TDT_NONE                        = $00	; also $07: no handler
TDT_GUNNER                      = $01	; stage 2: walks to the nearest player, turns to face it and fires bullets; HP 0/2/4
TDT_RUNNER                      = $02	; stage 2: walks to the nearest player; HP 0/2/4
TDT_CENTIPEDE_UNUSED            = $03	; head of a 4-part centipede like TDT_CENTIPEDE (never spawned)
TDT_CENTIPEDE_SEGMENT           = $04	; body segment of TDT_CENTIPEDE / TDT_CENTIPEDE_UNUSED (follows the head's trail)
TDT_CRAWLER                     = $05	; stage 5: walks to the nearest player; HP 2/4/8
TDT_NEST_CRAWLER                = $06	; stage 5: comes out of a nest (TDMT_NEST), fires orbs; HP 2/16/32
TDT_EXPLOSION                   = $08	; an enemy's explosion (td_start_explosion)
TDT_HATCH_TURRET_SPIN           = $09	; stage 2: turret of TDMT_GUN_HATCH_SPIN, turns all the time; HP 16/32/64
TDT_STAGE5_BOSS_CLAW            = $0A	; stage 5 boss: claw at the end of the arm; HP 32/128/256, shared by the whole arm
TDT_STAGE5_BOSS_ARM_SEGMENT     = $0B	; stage 5 boss: 12 arm segments (follow the claw's trail)
TDT_BUG_CENTIPEDE               = $0C	; stage 5: centipede head, 3 segments; HP 16/64/128 (whole body); splits into 4 TDT_CENTIPEDE_BUG
TDT_BUG_CENTIPEDE_SEGMENT       = $0D	; body segment of TDT_BUG_CENTIPEDE
TDT_CENTIPEDE_BUG               = $0E	; stage 5: bug left by a TDT_BUG_CENTIPEDE, fires orbs; HP 2/4/8
TDT_CENTIPEDE                   = $0F	; stage 2: centipede head with 3 TDT_CENTIPEDE_SEGMENT; HP 16/64/128 (whole body)
TDT_HATCH_TURRET_AIM            = $10	; stage 2: turret of a gun hatch, aims at the nearest player; HP 16/32/64
TDT_HATCH_TURRET_SWEEP          = $11	; stage 2: turret of TDMT_GUN_HATCH_SWEEP, sweeps left and right; HP 16/32/64
TDT_SPITTER                     = $12	; stage 5: walks, turns to face the nearest player and fires orbs; HP 2/4/8
TDT_STAGE5_BOSS_ARM_BASE        = $13	; stage 5 boss: base of the arm
;
; Map object types (+$10 of the slots $0AC0-$0D3F; tbl_map_object_types).
TDMT_GUN_HATCH_AIM              = $01	; stage 2 target: a hatch in the floor that opens near a player and lets out TDT_HATCH_TURRET_AIM; HP 32/80/128
TDMT_NEST                       = $02	; stage 5 target: a nest that lets out TDT_NEST_CRAWLER; HP 32/80/128
TDMT_STAGE2_BOSS                = $03	; stage 2 boss: the body (a Mode 7 layer): drops from above, walks, jumps on the player
TDMT_STAGE2_BOSS_CORE           = $04	; stage 2 boss: its weak point, HP 256/384/512; the boss dies with it
TDMT_STAGE2_BOSS_CANNON         = $05	; stage 2 boss: cannon turning around the body, HP 128/192/256
TDMT_STAGE2_BOSS_POD            = $06	; stage 2 boss: one of 6 spiked pods that fire, HP 32/64/128
TDMT_GUN_HATCH_SPIN             = $07	; stage 2 target: hatch with TDT_HATCH_TURRET_SPIN; HP 32/80/128
TDMT_STAGE5_BOSS                = $08	; stage 5 boss: the creature in the sand pit (a Mode 7 layer), HP 512/1024/2048
TDMT_GUN_HATCH_SWEEP            = $0C	; stage 2 target: hatch with TDT_HATCH_TURRET_SWEEP; HP 32/80/128
TDMT_GUN_HATCH_NO_FIRE          = $0D	; stage 2 target: opens only while the nearest player does not hold fire
TDMT_GUN_HATCH_BEHIND           = $0E	; stage 2 target: opens only behind the nearest player's back
;
; Item and effect types (+$10 of the slots $0980-$0ABF; tbl_td_item_types).
; Items carry their kind in +$14: 1-5 the weapon (WEAPON_SPREAD ...), then
; TDIK_BARRIER and TDIK_BOMB.
TDI_BLAST                       = $01	; blast that hurts players and enemies (damage 16), set off by the stage 2 traps
TDI_EXPLOSION                   = $02	; explosion effect, no collision (td_spawn_explosion_effect)
TDI_SPREAD                      = $03	; weapon item S
TDI_CRUSH                       = $04	; weapon item C
TDI_HOMING                      = $05	; weapon item H
TDI_FLAME                       = $06	; weapon item F
TDI_LASER                       = $07	; weapon item L
TDI_BARRIER                     = $08	; barrier: invincible for $200 frames
TDI_BOMB                        = $09	; one more smart bomb (up to 9)
TDIK_BARRIER                    = 6	; item kind (+$14) of TDI_BARRIER
TDIK_BOMB                       = 7	; item kind of TDI_BOMB
;
; Shot types (+$10 of the slots $0300-$097F; tbl_topdown_shot_types is
; indexed by type + 8). Damage is +$06.
TDS_IMPACT                      = $FFFE	; a shot that hit something: spark, then the slot is freed (td_end_shot)
TDS_HIDDEN                      = $FFFF	; no sprite
TDS_DEFAULT                     = $02	; default gun, damage 2
TDS_SPREAD                      = $03	; spread gun, damage 2
TDS_ENEMY_BULLET                = $04	; enemy bullet
TDS_HOMING                      = $05	; homing missile, damage 2
TDS_LASER                       = $06	; laser, damage 4
TDS_FLAME                       = $07	; flame, damage 1
TDS_CRUSH                       = $08	; crush missile, damage 2; becomes TDS_CRUSH_BLAST
TDS_CRUSH_BLAST                 = $09	; crush blast, damage 1 for $40 frames
TDS_CRUSH_BLAST_PART            = $0A	; the two outer parts of a crush blast
TDS_BOSS_SPIT                   = $0B	; stage 5 boss: shots spat from the pit's edge
TDS_CANNON_FLAME                = $0C	; stage 2 boss cannon on HARD: flame
TDS_ENEMY_ORB                   = $0D	; enemy orb (td_fire_enemy_orb)
TDS_HOMING_ORB                  = $0E	; stage 5 boss claw: orb that steers towards a player

.endif
