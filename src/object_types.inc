; object_types.inc -- object type numbers (OBJ_TYPE values)
;
; OBJ_TYPE (+$10) of a slot of the main object list selects its handler in
; tbl_object_types (161 long pointers, index x3). One constant per line,
; sorted by value; types not identified yet have no constant. Shot types
; (SHOT_TYPE, tbl_shot_types) are at the end.

.ifndef OBJECT_TYPES_INC
OBJECT_TYPES_INC = 1

OBJT_FOOT_SOLDIER               = $0A	; running foot soldier (update_foot_soldier)
OBJT_BOMBER_BOMB                = $0C	; bomb of the stage 1 bomber plane
OBJT_POPUP_TURRET               = $0D	; gun turret rising from the rubble (stage 1)
OBJT_WEAPON_CAPSULE             = $0F	; flying weapon capsule
OBJT_BOUNCING_DEBRIS            = $10	; debris that bounces and blinks out
OBJT_GRENADE                    = $13	; grenade thrown by soldiers
OBJT_WINDOW_SNIPER              = $17	; sniper in a window (stages 1, 3)
OBJT_ENEMY_BULLET               = $18	; enemy bullet
OBJT_GRENADE_BLAST              = $1A	; explosion of a grenade
OBJT_DYING_SOLDIER              = $1B	; killed soldier thrown back (start_dying_soldier)
OBJT_EFFECT                     = $1D	; animation effect: explosion, spark, fire (make_effect_object)
OBJT_ALIEN_DOG                  = $1E	; alien dog (stage 1)
OBJT_STAGE1_BOSS_PART           = $20	; stage 1 boss (giant turtle), part with HP 256
OBJT_FACE_BOSS_LARVA            = $21
OBJT_FALLING_DEBRIS             = $23	; wall debris falling in the stage 1 boss fight
OBJT_WINGED_ALIEN_TAIL_SEGMENT  = $25
OBJT_STAGE1_BOSS_TRACKING_SHOT  = $26	; stage 1 boss projectile following the player's height
OBJT_STAGE1_BOSS_FALLING_SHOT   = $27	; stage 1 boss projectile that falls and rolls
OBJT_STAGE1_BOSS                = $29	; stage 1 boss (giant turtle), main body, HP 352
OBJT_STAGE1_BOSS_FIRE           = $38	; stage 1 boss fire breath
OBJT_STAGE3_SPIKED_CLIMBER      = $3D	; stage 3 mid-boss climbing the girder, HP 160
OBJT_STAGE3_SPIKED_CLIMBER_CORE = $40	; its weak point, HP 80
OBJT_STAGE3_BOSS                = $41
OBJT_STAGE3_ROBOT_CABLES        = $44
OBJT_STAGE3_SECOND_ROBOT        = $45
OBJT_DEBRIS_EXPLOSION           = $46	; explosion on a solid BG tile
OBJT_ROLLING_MINE               = $4A	; rolling disc (stage 3)
OBJT_DEBRIS_SPARK               = $4B	; effect flying in a random direction
OBJT_COUNTDOWN_BOMB             = $4C
OBJT_STAGE3_WINGED_BUG          = $4F	; winged alien bug (stage 3)
OBJT_WALL_HATCH                 = $50	; wall hatch (stage 3)
OBJT_HEART_BOSS                 = $58
OBJT_WALL_WORM                  = $5B
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
OBJT_STAGE4_BOSS                = $69
OBJT_STAGE4_BOSS_POD            = $6A
OBJT_STAGE4_TANK                = $6E	; tank at the start of stage 4, HP 315
OBJT_CAVE_BEAST_FIREBALL        = $71
OBJT_CAVE_BEAST_BEAM            = $72
OBJT_HOVERBIKE_RIDER            = $74	; enemy on a hover bike (stage 4)
OBJT_FACE_BOSS_SIDE_HEAD        = $75
OBJT_FACE_BOSS_NECK             = $77
OBJT_SNAKE_ROBOT                = $79
OBJT_LIGHTNING_PYLON            = $7A
OBJT_LIGHTNING_BOLT             = $7B
OBJT_SPIKED_MINE                = $7D
OBJT_AIRSHIP_GUN_ARM            = $7F
OBJT_SNAKE_ROBOT_HEAD           = $81
OBJT_STAGE4_BOSS_SHOT           = $82
OBJT_STAGE4_BOSS_FIREBALL       = $83
OBJT_HELICOPTER_ROPE            = $84
OBJT_SKELETON_EYE_FIREBALL      = $87
OBJT_SNAKE_ROBOT_DEBRIS         = $88
OBJT_BRAIN_BOSS                 = $8A
OBJT_BRAIN_BOSS_ORB_RING        = $8B
OBJT_BRAIN_BOSS_CHAIN           = $8C
OBJT_WINGED_ALIEN_TAIL_TIP      = $8D
OBJT_BRAIN_BOSS_EYEBALL         = $90
OBJT_BRAIN_BOSS_ROLLING_EYE     = $91
OBJT_BRAIN_BOSS_ORB_ARCH        = $92
OBJT_BRAIN_BOSS_ORB             = $93
OBJT_BRAIN_BOSS_ORB_CLUSTER     = $94
OBJT_ENDING_SEQUENCE            = $95
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

.endif
