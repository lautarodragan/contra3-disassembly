; sound/sounds.inc -- Sound and music command numbers (book: Sound, the sound effects)
;
; The commands the game queues (queue_sound) for the sound driver. Named from
; the code that queues them, checked in the emulator (which code queued what,
; in the scripted plays and from power-on) and rendered with
; tools/sound_render.py; the table in the book (Sound: the sound effects) has
; every number with its length and where it is used, including those left
; unnamed here because they serve unrelated events or one event whose meaning
; is not clear ($11, $14, $15, $35, $37, $39, $3D, $44-$4E, $50, $53-$59,
; $5C-$5E, $6D: by number in the code) or are never queued ($06, $1C, $4C,
; $65, $67). SOUND_CMD_STOP and SOUND_CMD_UPLOAD are in ram.inc. The driver's own
; sequences are in assets/sound/spc_sfx.seq, labelled sound_NN.

; ---- menus and screens ----
SOUND_CURSOR            = $01	; a menu cursor moves (title menu, OPTION, CONTINUE, stage select, top-down start positions)
SOUND_SELECT            = $02	; a menu choice is confirmed (title menu, OPTION, CONTINUE, top-down start positions)
SOUND_BONUS_COUNT       = $03	; stage clear screen: each step of the bonus count (stage_clear_count_bonus)
SOUND_EXTRA_LIFE        = $3E	; an extra life from the score (add_score)

; ---- the players ----
SOUND_SHOT_DEFAULT      = $04	; the default gun fires (spawn_shot_default, fire_td_default)
SOUND_SHOT_LASER        = $05	; the laser (spawn_shot_laser_in_slots, fire_td_laser)
SOUND_SHOT_CRUSH        = $07	; the crush gun (spawn_shot_crush_in_slot, fire_td_crush)
SOUND_SHOT_HOMING       = $08	; the homing gun (spawn_shot_homing_in_slot, fire_td_homing)
SOUND_SHOT_SPREAD       = $09	; the spread gun (spawn_shots_spread_in_slots, fire_td_spread)
SOUND_SHOT_FLAME        = $0A	; the flame thrower (spawn_shots_flame, td_play_flame_sound)
SOUND_WEAPON_PICKUP     = $12	; a player touches a weapon item (weapon_capsule states 2-4, td_p1_vs_items, td_p2_vs_items)
SOUND_TANK_ENGINE       = $1E	; stage 1 tank driving (input_tank; also the mid-boss tank moving): loops until $1F replaces it
SOUND_TANK_STOP         = $1F	; the tank stops or the player leaves it (input_tank, midboss_tank_state_06); takes $1E's channel
SOUND_TANK_CANNON       = $20	; the player's tank fires its cannon (player_state_tank: recoil and screen shake)
SOUND_PLAYER_DIE        = $3F	; a player is killed (kill_player, td_player_state_dying)
SOUND_PLAYER_FALL       = $43	; a player dies below the screen (kill_player) or falls in the top-down view (td_player_state_falling)
SOUND_SMART_BOMB        = $5A	; a player's bomb (check_bomb_button, td_check_smart_bomb)
SOUND_BOMB_FLASH        = $5B	; the game sets off a bomb blast itself, setting the players' bomb fields (opening_beam_start_flash, stage4_controller_state_1C)

; ---- enemies ----
SOUND_ENEMY_DIE         = $0B	; a soldier, alien dog, floor bug or top-down runner, gunner or crawler is killed
SOUND_SHOT_DOWN         = $0C	; an enemy projectile or small flier is shot down (stage 1 boss shots, winged bugs, larvae)
SOUND_HANGING_SOLDIER_DIE = $0D	; stage 4: a soldier hanging from the airship is killed (start_dying_soldier_sound_0D)
SOUND_ALIEN_SOLDIER_DIE = $0E	; stage 6: an alien soldier or a heart boss crawler is killed (start_dying_soldier_sound_0E, heart_boss_crawler_die)
SOUND_BOSS_HIT          = $0F	; a shot hits the stage 1 boss (or a part) or the cave beast, while it flashes
SOUND_CLANG             = $10	; a shot hits an armoured target (OBJF_CLANG, update_shots); a top-down target flashes when hit
SOUND_HOVERBIKE_RIDER_DIE = $13	; stage 4: a hover-bike rider is killed (update_hoverbike_rider)
SOUND_THROW             = $16	; a grenade or bomb is thrown (grenade soldier, searchlight craft, hover-bike rider)
SOUND_MISSILE_EXPLODE   = $17	; a homing missile or a stage 4 boss shot explodes (homing_missile_fly, update_stage4_boss_shot)
SOUND_SPIKE_EXTEND      = $18	; stage 3: the spiked climber thrusts its spike up (stage3_spiked_climber_move_spike)
SOUND_SPIKE_RETRACT     = $19	; the spike retracts (also when the climber's core dies); takes $18's channel
SOUND_ENEMY_FIRE        = $1A	; an enemy fires a shell or fireball (mid-boss tank, hover-bike rider, stage 4 boss pods, stage 3 robot debris)
SOUND_WINDOW_CRASH      = $1B	; stage 1: a soldier crashes out through a window (window_jumper_state_02)
SOUND_SNIPER_KILLED     = $1D	; stage 1: the window sniper's bunker sees the sniper dead (sniper_bunker_state_01)
SOUND_FLAME_GEYSER      = $21	; stage 1: a flame geyser fires (update_flame_geyser)
SOUND_FIRE_JET          = $22	; stage 1: a fire jet spews flames (update_fire_jet)
SOUND_FIREBALL_JUMP     = $23	; stage 1: a hopping fireball's big jump (update_hopping_fireball)
SOUND_FIRE_ERUPTION     = $24	; stage 1: the fire eruption (update_fire_eruption)
SOUND_STAGE1_BOSS_FIRE  = $25	; stage 1 boss: its fire attack (stage1_boss_attack_fire)
; $26-$2D: top-down turning sounds by speed 1-8, each higher (td_turn_sounds,
; td_play_turn_sound: the stage 2 boss's spin)
SOUND_TURN_1            = $26
SOUND_TURN_2            = $27
SOUND_TURN_3            = $28
SOUND_TURN_4            = $29
SOUND_TURN_5            = $2A
SOUND_TURN_6            = $2B
SOUND_TURN_7            = $2C
SOUND_TURN_8            = $2D
SOUND_STAGE2_BOSS_TAKE_OFF = $2E ; the stage 2 boss takes off (stage2_boss_state_08)
SOUND_STAGE2_BOSS_DROP  = $2F	; the stage 2 boss falls back or drops onto a player (stage2_boss_state_01, _0A)
SOUND_EXPLOSION         = $30	; an explosion (grenades, turrets, mines, bombs, orbs, top-down targets...; queue_sound_30_throttled)
SOUND_RIDEABLE_MISSILE  = $31	; stage 4: the missiles the players ride, every 64 frames (rideable_missile_state_01)
SOUND_STAGE3_ROBOT_LAND = $32	; stage 3 boss room: the second robot lands (stage3_robot_update_jump)
SOUND_BUMP              = $33	; the second robot bumps (stage3_robot_state_05, _update_jump); the helicopter rope touches the missile
SOUND_STAGE3_ROBOT_JUMP = $34	; the second robot jumps (stage3_robot_state_08)
SOUND_COUNTDOWN_BOMB    = $36	; stage 3: a numbered countdown bomb (update_countdown_bomb)
SOUND_HARD_LANDING      = $38	; stage 4: the snake robot lands fast (snake_robot_state_03; $39 when slow)
SOUND_STAGE5_BOSS_SPIT  = $3A	; the stage 5 boss spits (stage5_boss_spit_step_0)
SOUND_HEART_BOSS_BUG_DIE = $3B	; stage 6: a heart boss bug is killed (heart_boss_bug_die)
SOUND_BOSS_HIT_2        = $3C	; a shot hits the heart boss or the brain boss (boss_hit_sound_timer)
SOUND_BIG_EXPLOSION     = $41	; a boss part or a big target explodes (queue_sound_41_throttled during boss deaths)
SOUND_VEHICLE_EXPLODE   = $42	; stage 1: the wrecked car or the mid-boss tank is destroyed
SOUND_STAGE4_INTRO      = $4F	; stage 4 start, after SOUND_CMD_STOP (layout_init_stage4); the stage's song follows ($63)
SOUND_WALL_WORM_DIE     = $51	; stage 6: the wall worm dies (wall_worm_die)
SOUND_HEART_BOSS_DIE    = $52	; stage 6: the heart boss dies (heart_boss_die)
SOUND_RIDEABLE_MISSILE_ENDING = $5F ; the ending's missile under the helicopter: $31's sequence on music channel 4
SOUND_BOSS_EXPLOSIONS   = $6E	; a boss's death explosions, again and again (queue_sound_6E_throttled, td_play_rumble_sound)

; ---- music: $61-$6B, $71 and $72 all play the song of the set (at ARAM $3000;
; the driver treats them alike, 8 channels for $71/$72); the game uses one
; number per song ----
SOUND_SONG_OPENING      = $61	; opening_cinematic_init
SOUND_SONG_STAGE3_6     = $62	; stages 3 and 6 (layout_init_stage3_common, layout_init_stage6)
SOUND_SONG_STAGE2_4     = $63	; stage 4 (after its intro, $4F) and the top-down stage 2 (topdown_stage_songs)
SOUND_SONG_STAGE1       = $64	; stage 1 (layout_init_stage1_common)
SOUND_SONG_STAGE5       = $66	; the top-down stage 5 (topdown_stage_songs)
SOUND_SONG_BOSS         = $68	; the bosses of stages 1, 2, 3 and 5
SOUND_SONG_HEART_BOSS   = $69	; heart_boss_state_06
SOUND_SONG_STAGE_CLEAR  = $6A	; stage_clear_fade_in
SOUND_SONG_GAME_OVER    = $6B	; game_over_fade_in
SOUND_SONG_TOPDOWN_INTRO = $6F	; the song at ARAM $4B00 (stages 2 and 5's sets only; intro_init)
SOUND_SONG_ENDING       = $71	; ending_sequence_state_18
SOUND_SONG_KONAMI_LOGO  = $72	; konami_logo_start_shine

; ---- driver commands ($74-$7A choose the instrument set: song_start_commands) ----
SOUND_CMD_PAUSE         = $7C	; pause_sounds (run_stage)
SOUND_CMD_UNPAUSE       = $7D
SOUND_CMD_MONO          = $7E	; sound_mode_commands (OPTION)
SOUND_CMD_STEREO        = $7F
SOUND_CMD_FADE_OUT_FAST = $80	; fade the music out, 2 ticks per step (fade_speeds); not used
SOUND_CMD_FADE_OUT      = $81	; fade the music out, 4 ticks per step
SOUND_CMD_BRANCH        = $82	; makes the songs' `branch` take its second address
SOUND_CMD_STOP_MUSIC    = $83	; stops the music (channels 0-5)
