; object_types.inc -- object type numbers (OBJ_TYPE values)
;
; OBJ_TYPE (+$10) of a slot of the main object list selects its handler in
; tbl_object_types (161 long pointers, index x3). One constant per line,
; sorted by value; types not identified yet have no constant. Shot types
; (SHOT_TYPE, tbl_shot_types) are at the end.

.ifndef OBJECT_TYPES_INC
OBJECT_TYPES_INC = 1

OBJT_FACE_BOSS_LARVA            = $21
OBJT_WINGED_ALIEN_TAIL_SEGMENT  = $25
OBJT_STAGE3_BOSS                = $41
OBJT_STAGE3_ROBOT_CABLES        = $44
OBJT_STAGE3_SECOND_ROBOT        = $45
OBJT_COUNTDOWN_BOMB             = $4C
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
OBJT_CAVE_BEAST_FIREBALL        = $71
OBJT_CAVE_BEAST_BEAM            = $72
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

; Shot types used by the ending fireworks (object_handlers_02.asm).
SHOTT_ENDING_FIREWORK           = $16
SHOTT_SPARK_RANDOM              = $17
SHOTT_SPARK_RADIAL              = $18
SHOTT_SPARK_RADIAL_FAST         = $19
SHOTT_SPARK_RANDOM_B            = $1A

.endif
