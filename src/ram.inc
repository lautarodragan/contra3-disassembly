; RAM symbols (WRAM $7E:0000-$7F:FFFF; $0000-$1FFF is also visible in banks $00-$3F).
;
; Placeholders are named by address: zp_XX for the direct page ($00-$FF,
; with D = 0), wram_XXXX for $0100-$1FFF, wram_7EXXXX / wram_7FXXXX above.
; Rename them with tools/rename.py as their meaning is established, and
; put the evidence in the comment (see the book, "Contributing").
;
; What is a symbol and what is still a number (milestone 2, first pass,
; done mechanically with the CDL):
;   - absolute operands below $2000 without index (a:wram_1E02), long
;     operands to bank $00 below $2000 or to $7E:2000-$7F:FFFF, and
;     JMP (abs) / JML [abs] pointers;
;   - direct-page operands without index (lda zp_3A, lda (zp_00),y,
;     lda [zp_00],y) of instructions that ran with D = 0 in the CDL traces,
;     or never ran and are not in a routine that changes D or is called
;     from one.
;   Left as numbers on purpose:
;   - indexed operands (lda $10,x / lda a:$1304,x / sta f:$7EA000,x):
;     usually a field of the structure X or Y points to (an object slot,
;     a player), not an address; see the structure notes below;
;   - direct-page operands of instructions run with D != 0 ($1300, $1340,
;     $1F00: the loader/decompressor contexts, see engine/gfx_loader.asm)
;     or that may run with D != 0;
;   - immediates (#$1E00 used as a RAM pointer), and $7E:0000-$7E:1FFF.

.ifndef RAM_INC
RAM_INC = 1

; ---- direct page ($0000-$00FF, D = 0) ----

zp_00               = $00
zp_01               = $01
zp_02               = $02
zp_03               = $03
zp_04               = $04
zp_05               = $05
zp_06               = $06
zp_08               = $08
zp_09               = $09
zp_0A               = $0A
zp_0B               = $0B
zp_0C               = $0C
zp_0E               = $0E
zp_10               = $10
zp_12               = $12
zp_14               = $14
zp_16               = $16
zp_18               = $18
zp_1A               = $1A
zp_1C               = $1C
zp_1E               = $1E
joy1_held           = $20	; joypad 1 buttons held (written by read_joypads; pads 2-4 at $22/$24/$26)
joy2_held           = $22	; joypad 2 buttons held
joy1_pressed        = $28	; joypad 1 buttons newly pressed this frame (pads 2-4 at $2A/$2C/$2E)
joy2_pressed        = $2A	; joypad 2 buttons newly pressed this frame
soft_reset_pad_mask = $30	; pads whose L+R+Start+Select+Select resets the game (bit 0 pad 1, bit 1 pad 2; tested by read_joypads against soft_reset_pad_bits); 3 from warm_boot
game_mode           = $32	; game mode, index into tbl_game_modes (run_game_mode)
game_submode        = $34	; sub-mode of the current game mode (each mode dispatches it through its own table)
mode_result               = $36	; result of the current game mode's handler, read by the mode (0 = still running; 1/2/3 = done, meaning depends on the mode); cleared by set_game_mode
zp_38               = $38	; cleared by set_submode / next_game_mode_keep_submode on every mode change; never read by name
frame_counter       = $3A	; incremented by run_game_mode every frame
nmi_busy            = $3C	; non-zero while the NMI frame handler runs (re-entry guard in nmi)
force_blank_frames  = $3E	; frames left with forced blank: the NMI frame handlers decrement it and keep INIDISP blanked while it is still non-zero (4 after display changes)
m7_split_screen               = $40	; non-zero (2) in 2-player mode A: the IRQ switches to player 2's Mode 7 matrix at line $70 (irq_mode7_top_view)
nmi_mode            = $42	; NMI frame handler, x2 index into tbl_nmi_frame_handlers (0, 2 = side-view stages, 4 = top-down stages)
irq_mode            = $44	; IRQ handler, x2 index into tbl_irq_handlers (0 none, 2 irq_mode7_top_view, 4 irq_mode7_bottom_view)
hdma_preset         = $46	; HDMA preset: index into ptrs_hdma_presets (setup_hdma_channels, nmi_frame_default) or, minus 1, into ptrs_stage_hdma_lists (setup_stage_hdma, side-view stages); 0 = none
cgram_dma_src       = $48	; low word of the $7E:xxxx buffer DMAd to CGRAM (512 bytes) every frame by dma_oam_and_palette; always $2200
demo_mode               = $4A	; 2 while the attract demo plays (demo_init): run_stage then skips the pause check
demo_timer               = $4C	; frames left in the attract demo ($0800 from demo_init, demo_play); also set to $0100 by the unused game_mode_stage_select
vram_queue_end      = $4E	; end of the VRAM DMA queue at $7E:3000 (11-byte entries; run and reset by run_vram_queue)
vram_queue_data_ptr = $50	; next free byte of the queue's data buffer at $7E:3400
apu_pending_cmd     = $52	; last command written to APUIO0, waiting for the sound CPU to echo it; $FF while a song set upload is requested/running (nothing is sent)
sound_queue_read    = $54	; read index of sound_queue (send_queued_sound)
sound_queue_write   = $56	; write index of sound_queue (queue_sound)
sound_stream_check_index = $5A	; when non-zero, send_queued_sound checks the stream status word at $1F2D+this (stream code, never run in the traces)
sound_last_queued   = $5C	; last command queued by queue_sound (repeats are dropped)
pause_disabled               = $64	; non-zero: Start does not pause (run_stage); 2 while a stage fades in or a cinematic runs (run_side_view_stage, stage_play)
paused               = $66	; 1 while the game is paused (run_stage toggles it with Start)
wait_timer               = $68	; frames to wait, decremented by tick_wait_timer ($50 in game_mode_game_start, where bit 2 blinks the chosen menu entry)
sound_cmd_override  = $6A	; when non-zero, sent by send_queued_sound before the queue (set from a finished stream; never run in the traces)
stage_index         = $70	; stage number - 1 (0-5), set from stage_number in normal play and in the demo; indexes per-stage tables such as tbl_stage_runners
mode_timer               = $76	; frame countdown used by game modes (game over wait, stage clear screen)
stage_frame_counter               = $78	; incremented every stage frame by update_stage_frame_counters; cleared at stage init
difficulty          = $84	; difficulty x2: 0 easy, 2 normal, 4 hard (copied from $1E3E)
stage_number        = $86	; stage number, 1-6
button_fire               = $88	; joypad mask of the fire button, $4000 = Y (set by game_mode_stage_card / demo_init_players; read by the player code)
button_jump               = $8A	; joypad mask of the jump button, $8000 = B
button_bomb               = $8C	; joypad mask of the smart bomb button, $0080 = A
button_stand_still               = $8E	; joypad mask, $0010 = R: while held the player does not walk (player code skips the horizontal speed)
zp_92               = $92
zp_94               = $94
zp_96               = $96
cgram_upload_addr   = $98	; CGRAM address (byte) of a 32-byte palette DMA from $05:cgram_upload_src in nmi_frame_side_view; 0 = none
cgram_upload_addr2  = $99	; CGRAM address of a second copy of the same 32 bytes; 0 = none
cgram_upload_src    = $9A	; bank $05 address of the palette uploaded by nmi_frame_side_view
oam_hi_bits         = $9C	; OAM high-table bits being packed (2 per sprite, shifted in from the top; $8000 = empty) by draw_metasprite / draw_shot
zp_9E               = $9E
shake_bg1_y         = $A0	; screen shake: subtracted from BG1 VOFS (nmi) and added to sprite y (draw_metasprite); update_shake_side_view
shake_bg2_y         = $A2	; screen shake for BG2 VOFS (half of shake_bg1_y)
scroll_threshold    = $A6	; screen x (or y) a player must pass to scroll BG1 (bg1_scroll_horizontal / bg1_scroll_vertical)
target_list_end     = $AA	; end of the target list at $15A0 (slots of OBJF_TARGET objects, 0-terminated), built by update_objects
oam_ptr             = $AC	; next free entry of the OAM buffer ($0FC0-$11BF), reset every frame by the stage loop
oam_hi_ptr          = $AE	; next byte of the OAM high table ($11C0-$11DF)
bg_dma_vram_addr    = $B0	; VRAM address of an extra DMA done by dma_bg_tilemap_updates (0 = none)
bg_dma_size         = $B2	; its size in bytes
bg_dma_src          = $B4	; its source address in $7E
vram_block_queue_end = $B6	; offset in vram_block_queue of the next free entry (+8 per block, 8 entries; queue_vram_block)
player_tiles_vram_top = $B8	; VRAM address of the top 6 rows of the player tiles DMAd this frame from player_tile_src ($6000 player 1, $6200 player 2; 0 = none; update_players)
player_tiles_vram_bottom = $BA	; VRAM address of the bottom 6 rows ($6100 / $6300)
stage_frame_odd               = $BC	; stage_frame_counter & 1 (update_stage_frame_counters)
stage_frame_mod4               = $BE	; stage_frame_counter & 3
stage_frame_mod8               = $C0	; stage_frame_counter & 7
zp_C4               = $C4
zp_C6               = $C6
zp_C8               = $C8
zp_CA               = $CA
zp_CC               = $CC
zp_CD               = $CD
zp_CE               = $CE
zp_D0               = $D0
zp_D2               = $D2
zp_D4               = $D4
zp_D6               = $D6
zp_D7               = $D7
zp_D8               = $D8
zp_D9               = $D9
zp_DA               = $DA
zp_DC               = $DC
zp_DD               = $DD
zp_DE               = $DE
zp_E0               = $E0
zp_E2               = $E2	; side view: bytes per row of the vram_block_queue DMAs (8; $20 for the stage 1 boss); the top-down code uses it as a temporary
stage_frame_bit1               = $E4	; stage_frame_counter & 2
rng_temp            = $E6	; complement of rng_lo saved by next_random; some objects read it as a second random value
rng_lo              = $E8	; random number generator state, low word (next_random)
zp_E9               = $E9
rng_hi              = $EA	; random number generator state, high word
zp_EB               = $EB
text_erase               = $F0
typewriter_vram_addr               = $F2
typewriter_ptr               = $F4
typewriter_active               = $F6
typewriter_attr               = $F8
zp_FA               = $FA
zp_FC               = $FC
zp_FE               = $FE

; ---- $0100-$1FFF ----

sound_queue         = $0100	; ring of commands for the sound CPU (queue_sound, send_queued_sound)
obj_slots           = $0200	; side view: the main object list, 35 slots of OBJ_SIZE bytes ($0200-$0ABF; slot n at obj_slots+n*OBJ_SIZE, the players are slots 0 and 1); fixed slots read or written directly are written obj_slots+n*OBJ_SIZE+field
td_arrow_objs       = $0200	; top-down: 4 objects of OBJ_SIZE bytes, the target arrows (OBJ_SPRITE, OBJ_X, OBJ_Y only), 2 per view: copied to the first OAM entries by draw_target_arrows / draw_target_arrows_p2, aimed in stage_play.asm
player1_obj         = $0200	; player 1 object ($40 bytes; player 2 at $0240)
player1_state       = $0212	; player 1 object field +$12, state
player2_obj         = $0240	; player 2 object ($40 bytes)
player2_state       = $0252	; player 2 object field +$12, state
td_enemy_shots      = $0300	; top-down: enemy shots, 12 slots of SHOT_SIZE bytes ($0300-$047F, update_topdown_shots; the stage 5 boss's spit uses the first 8)
td_p1_shots         = $0480	; top-down: player 1's shots, slots of SHOT_SIZE bytes ($0480-$06FF)
td_p2_shots         = $0700	; top-down: player 2's shots, slots of SHOT_SIZE bytes ($0700-$097F)
td_items            = $0980	; top-down: items and effects (TDI_*), 5 slots of OBJ_SIZE bytes ($0980-$0ABF, update_td_items)
td_map_objects      = $0AC0	; top-down: map objects (targets, bosses), 10 slots of OBJ_SIZE bytes ($0AC0-$0D3F, update_map_objects); td_boss_* are fields of the first
td_boss_angle       = $0AC4	; top-down boss maps, object $0AC0 +$04: the boss's angle (stage 2: rotation of the boss layer)
td_boss_hp          = $0AC6	; object $0AC0 +$06: stage 5 boss HP (512/1024/2048); top-down targets: first target's HP
td_boss_x           = $0ACA	; object $0AC0 +$0A: boss map x (stage 2: centre of the boss layer, $8000 while off the map)
td_boss_y           = $0ACE	; object $0AC0 +$0E: boss map y
td_boss_state       = $0AD2	; object $0AC0 +$12: boss state (tbl_stage2_boss_states / tbl_stage5_boss_states)
td_boss_core_hp     = $0B46	; object $0B40 +$06: HP of the stage 2 boss core (256/384/512) / stage 5 boss claw (32/128/256)
td_enemies          = $0D40	; top-down: enemies, 6 slots of OBJ_SIZE bytes ($0D40-$0EBF, td_update_enemies)
td_p1_obj           = $0EC0	; top-down: player 1's object (td_p1_* are its fields)
td_p1_angle         = $0EC4	; top-down player 1 (object $0EC0) +$04: facing angle
td_p1_hp            = $0EC6	; top-down player 1 +$06: set to $FFFF when hit (negative = killed; the barrier prevents it)
td_p1_x_frac        = $0EC8	; top-down player 1 +$08: x, fraction
td_p1_x             = $0ECA	; top-down player 1 +$0A: map x ($000-$3FF)
td_p1_y_frac        = $0ECC	; top-down player 1 +$0C: y, fraction
td_p1_y             = $0ECE	; top-down player 1 +$0E: map y
td_p1_state         = $0ED2	; top-down player 1 +$12: state (tbl_topdown_player_states; 5 = jump: enemy shots miss)
td_p1_hit_flags     = $0ED6	; top-down player 1 +$16: bit 15 set when it can be hit
td_p2_obj           = $0F00	; top-down: player 2's object (td_p2_*)
td_p2_angle         = $0F04	; top-down player 2 (object $0F00) +$04: facing angle
td_p2_hp            = $0F06	; top-down player 2 +$06: $FFFF when hit
td_p2_x_frac        = $0F08	; top-down player 2 +$08
td_p2_x             = $0F0A	; top-down player 2 +$0A: map x
td_p2_y_frac        = $0F0C	; top-down player 2 +$0C
td_p2_y             = $0F0E	; top-down player 2 +$0E: map y
td_p2_state         = $0F12	; top-down player 2 +$12: state
td_p2_hit_flags     = $0F16	; top-down player 2 +$16: bit 15 set when it can be hit
td_p1_bomb          = $0F40	; top-down: player 1's smart bomb object (td_p1_bomb_*); while it is active the window effect (window_shapes.asm) draws its circle
td_p1_bomb_x        = $0F4A	; player 1's smart bomb (object $0F40) +$0A: centre x
td_p1_bomb_y        = $0F4E	; player 1's smart bomb +$0E: centre y
td_p1_bomb_radius   = $0F54	; player 1's smart bomb +$14: radius (grows for $70 frames)
td_p2_bomb          = $0F80	; top-down: player 2's smart bomb object
td_p2_bomb_x        = $0F8A	; player 2's smart bomb (object $0F80) +$0A
td_p2_bomb_y        = $0F8E	; player 2's smart bomb +$0E
td_p2_bomb_radius   = $0F94	; player 2's smart bomb +$14: radius
oam_buffer          = $0FC0	; OAM buffer, 128 entries of 4 bytes (x, y, tile and attributes), DMAd to OAM every frame; filled from oam_ptr
oam_hi_table        = $11C0	; OAM high table (2 bits per sprite: x bit 8, size), 32 bytes; filled from oam_hi_ptr
palette_tasks       = $1200	; 8 palette task slots of $10 bytes, $1200-$127F (TASK_* fields; run_palette_tasks)
vram_tasks          = $1280	; VRAM script task slots, $1280-$12FF (TASK_* fields; run_vram_tasks runs half of them each frame)
bg1_x               = $1380	; BG1 scroll state ($40 bytes, BG_* fields): horizontal scroll
bg1_x_sub           = $1384	; BG1 horizontal scroll fraction (autoscroll adds $6800 a frame, bg1_scroll_horizontal)
bg1_x_delta         = $138E	; BG1 horizontal movement this frame; objects with OBJF_MOVE subtract it
bg1_y               = $1398	; BG1 vertical scroll
bg1_y_sub           = $13A4	; BG1 vertical scroll fraction (vertical autoscroll, bg1_scroll_vertical)
bg1_y_delta         = $13A6	; BG1 vertical movement this frame; objects subtract it
bg1_autoscroll      = $13B4	; non-zero: BG1 scrolls by itself instead of following the players
bg1_autoscroll_speed = $13B6	; vertical autoscroll speed: index into bg1_autoscroll_speeds
bg1_scroll_mode     = $13BA	; BG1 scroll handler: index into tbl_bg1_scroll_modes (run_bg1_scroll_mode)
bg1_map_offset      = $13BC	; BG1 BG_MAP_OFFSET: +$80 per 256-pixel page; its high byte is stage_progress
stage_progress      = $13BD	; stage progress counter
bg2_x               = $13C0	; BG2 scroll state ($40 bytes, BG_* fields): horizontal scroll
bg2_draw_x          = $13C2	; column being drawn by bg2_draw_screen_step (from $1F8 down)
bg2_x_sub           = $13C4	; BG2 horizontal scroll fraction (bg2_autoscroll_x)
bg2_y               = $13D8	; BG2 vertical scroll
bg2_y_sub           = $13DC	; BG2 vertical scroll fraction (bg2_autoscroll_xy)
bg2_scroll_mode     = $13FA	; BG2 scroll handler: index into tbl_bg2_scroll_modes (run_bg2_scroll_mode)
bg2_map_offset      = $13FC	; BG2 BG_MAP_OFFSET
bg2_screen_drawn    = $13FE	; set by bg2_draw_screen_step when the whole screen is drawn
bg3_x               = $1400	; BG3 scroll state ($40 bytes, BG_* fields): written to BG3HOFS/BG3VOFS by write_bg_scroll_regs
stage_ram           = $1500	; start of $1500-$18FF (player parallel fields / top-down view blocks, stage and object variables, HUD buffer), cleared from here by demo_init, opening_init, game_mode_stage_card and clear_topdown_ram ($1500-$18FF), init_stage2_boss_vars ($1500-$16FF)
p1_view_angle_frozen = $150A	; top-down: 1 while player 1 spins (td_player_state_spin_fire) or is thrown back by a hit: p1_view_angle stops following the player's angle (update_topdown_views); cleared at the respawn and in the fall (emulator: values 0/1)
p1_view_anchor_x           = $150C	; screen x where player 1's view puts its centre (the player): $80 in 1P, $60 in 2P-A (split screen)
p1_view_anchor_y           = $150E	; screen y of player 1's view centre: $A0 in 1P, $34 in 2P-A
p1_view_x           = $1510	; map x player 1's view is centred on (player 1's x, update_topdown_views); in the side view this byte is player1_obj+PLAYER_BOMB_RADIUS ($1500 + PLAYER_* fields)
p1_view_y           = $1512	; map y player 1's view is centred on
p1_view_angle           = $1514	; angle of player 1's view (256 units per turn); the Mode 7 angle is its negation
p1_facing_in_view   = $1518	; top-down: player 1's angle relative to its view (player angle = p1_view_angle + this): 2P-B's shared view does not turn, so turning changes this (td_tile_whirl_player); 2P-A starts it at $40
p1_start_x           = $1526	; intro: start point column 0-3 chosen by player 1, then the Mode 7 centre x the zoom-in moves to (set_start_points)
p1_start_y           = $1528	; intro: start point row 0-3, then the Mode 7 centre y of the zoom-in
p1_start_chosen           = $152A	; 2 once player 1 has chosen a start point (move_start_cursors)
p1_td_joy_held           = $152C	; player 1's joypad held buttons, copied by update_topdown_players
p1_td_joy_pressed           = $152E	; player 1's joypad newly pressed buttons, copied by update_topdown_players
p2_view_angle_frozen = $154A	; top-down: as p1_view_angle_frozen, for player 2
p2_view_anchor_x           = $154C	; screen x of player 2's view centre ($60 in 2P-A, like player 1)
p2_view_anchor_y           = $154E	; screen y of player 2's view centre ($AC in 2P-A: lower half)
p2_view_x           = $1550	; map x player 2's view is centred on
p2_view_y           = $1552	; map y player 2's view is centred on
p2_view_angle           = $1554	; angle of player 2's view
p2_facing_in_view   = $1558	; top-down: as p1_facing_in_view, for player 2
p2_start_x           = $1566	; intro: player 2's start point column, then zoom-in target x
p2_start_y           = $1568	; intro: player 2's start point row, then zoom-in target y
p2_start_chosen           = $156A	; 2 once player 2 has chosen a start point
p2_td_joy_held           = $156C	; player 2's joypad held buttons (update_topdown_players)
p2_td_joy_pressed           = $156E	; player 2's joypad newly pressed buttons
topdown_boss_end_step           = $1580	; step of the boss state after the boss is defeated (tbl_stage2_boss_end_steps / tbl_stage5_boss_end_steps)
map_view_step           = $1582	; step of the Select map view, index into tbl_map_view_steps (update_map_view); 0 = not open
td_palette_anim_timer           = $1584	; 0-$5F, the palette tasks of stages 2 and 5 start at 0 and $20 (step_palette_anim_timer)
topdown_window_update_on           = $1586	; non-zero during play: the NMI (update_topdown_window) rebuilds the window HDMA tables at $7E:3C00/$7E:3E00
fade_target_brightness           = $1588	; brightness ($00-$0F) that update_topdown_fade moves inidisp_shadow towards
intro_step           = $158A	; step of the start-point intro, index into tbl_intro_steps (update_topdown_intro)
boss_chr_stream_src           = $158C	; boss maps: source address of the boss's Mode 7 characters DMAd by stream_topdown_sprite_gfx
intro_phase           = $158E	; 1 while choosing the start point, 2 while zooming in, 0 in play (stops the views and BG streaming)
map_view_active           = $1590	; 1 while the Select map view is open (map_view_open / map_view_close)
boss_anim_frame     = $1592	; top-down boss maps: frame of the boss's Mode 7 graphics (stage 2: 0-2, cycled every 4 frames; stage 5: 0-$18, the body opening)
topdown_map           = $1594	; top-down map x2: 0 stage 2, 2 stage 2 boss, 4 stage 5, 6 stage 5 boss (TD_MAP_*); set by init_stage2_vars etc.
homing_target_cursor= $1596	; slot where the next TDS_HOMING shot starts looking for a target ($0AC0-$0E80)
targets_left_flag           = $159A	; set to $FFFF (negative) when the target-arrow search finds no target left (stage_play.asm); check_targets_destroyed then ends the section
topdown_timer           = $159C	; general timer of the top-down state machine (intro, boss end, targets destroyed)
boss_target_player  = $159E	; player the boss (and the stage 5 targets) go for: 0 = player 1, $40 = player 2 (td_select_target_player)
boss_target_distance= $15A0	; half the squared distance to boss_target_player
screen_shake_offset           = $15A2	; added (negated every other frame) to the Mode 7 vertical scroll by compute_m7_matrix; decays in update_screen_shake
screen_shake_timer           = $15A4	; frames of full screen shake left (update_screen_shake)
boss_centered_view           = $15A8	; 2 on the stage 2 boss map (init_stage2_boss_vars), else 0: update_topdown_views computes the view around the boss object ($0AC0) instead of the player
boss_chr_stream_vram           = $15AA	; VRAM word address of the boss characters
boss_chr_stream_bank           = $15AC	; bank of boss_chr_stream_src
boss_chr_stream_size           = $15AE	; bytes of boss characters to DMA each frame
stage5_boss_flash_counter = $15B0	; stage 5 boss: incremented by stage5_boss_flash_on_hit, picks the flash colour (every 2 frames, 4 colours of ptrs_stage5_boss_flash_palettes)
td_push_speed_frac  = $15B2	; speed of the TDA_PUSH_* tiles, fraction ($8000 from init_stage5_vars: half a pixel a frame)
td_push_speed       = $15B4	; speed of the TDA_PUSH_* tiles, whole pixels a frame (0)
palette_cycle_speed           = $15B6	; stage 5 boss map: colour rotation speed of animate_stage5_boss_palettes, high byte steps per frame or low byte frames per step; negative rotates the other way
palette_cycle_counter           = $15B8	; frame counter of the colour rotation (animate_stage5_boss_palettes)
stage5_boss_palette_step= $15BC	; step of stage5_boss_update_palette_cycle
palette_cycle_paused           = $15BE	; non-zero stops the colour rotation of animate_stage5_boss_palettes
stage5_boss_body_step= $15C0	; step of stage5_boss_animate_body
stage5_boss_cycle_pause = $15C4	; stage 5 boss below half HP: pause reloaded into palette_cycle_paused each time it runs out, 8 then one less each time (the colour rotation speeds up; stage5_boss_palette_step_2)
stage5_boss_spit_step= $15C8	; step of stage5_boss_update_spit
stage5_boss_spit_timer= $15CA	; timer of stage5_boss_update_spit
stage5_boss_spit_position= $15CC	; which of the 4 edge positions the stage 5 boss spits from (x2)
turn_sound_counter  = $15CE	; accumulated turning of the stage 2 boss; a sound every so many units (td_play_turn_sound)
rumble_sound_timer  = $15D0	; frames to the next rumble sound while a boss explodes (td_play_rumble_sound)
map_view_saved_inidisp = $15D2	; Select map view: inidisp_shadow saved when it opens, faded back to by map_view_restore_brightness
map_view_saved_p1_brightness = $15D4	; Select map view: p1_view_brightness saved when it opens
map_view_saved_p2_brightness = $15D6	; Select map view: p2_view_brightness saved when it opens
stage_state           = $1600	; side-view stage state, index into tbl_stage_states (STAGE_STATE_*)
spawn_entry_offset  = $1602	; offset of the next entry in the current page's spawn list (10-byte entries)
spawn_pages         = $1604	; the stage's table of spawn lists per page (from ptrs_stage_spawn_pages by stage_number)
spawn_page_index    = $1606	; current page x2 (index into spawn_pages)
spawn_pos_invert    = $1608	; 0, or $FFFF when positions count backwards (vertical scrolling, bg1_init_vertical)
spawn_scroll_var    = $160A	; address of the scroll variable spawning follows (bg1_x or bg1_y)
spawn_last_page     = $160C	; page (high byte) of that variable last seen by spawn_stage_objects
debug_coldata       = $1612	; debug_color_math_keys (no caller): COLDATA value, changed by A / B on pad 2
obj06_map_ptr       = $161C	; object type $06 (stage 1 section 9 scene): read pointer in the $7E:F300 block map while it redraws the BG into the VRAM queue (object_type_06_state_02)
obj06_attr_ptr      = $161E	; object type $06: read pointer in $7E:A000 (high bytes of the tilemap words it queues)
obj06_vram_offset   = $1620	; object type $06: VRAM offset of the next chunk, +$20 a frame; the redraw ends at $1000
obj06_block_column  = $1622	; object type $06: tile column inside the current block (0-$18, step 8)
hang_lock_buttons   = $1628	; buttons that keep a hanging player from moving (input_hang, input_hang_object, input_ground): button_fire | button_stand_still (stage_init)
debug_window_test   = $162C	; debug_window_keys (no caller): 1 while the window test is on (Select on pad 1 toggles it)
boss_work_0         = $1636	; boss_work_0-7 ($1636-$1645): work variables of the big scripted object of the moment (stage 1 boss, stage 3 spiked climber, the ending...), meaning set by each
boss_work_1         = $1638	; stage 1 boss: how far the head is out ($E0-$130; update_stage1_boss_head pushes it back while shot)
boss_work_2         = $163A
boss_work_3         = $163C	; stage 1 boss: height of the body (the slam attack raises it to $20, then drops it below 7)
boss_work_4         = $163E
boss_work_5         = $1640
boss_work_6         = $1642
boss_work_7         = $1644
homing_target_slot  = $1646	; side view: slot where the next homing missile (update_homing_shot) starts its round-robin search for an OBJF_TARGET object ($0280-$0A80; stage_init sets $0280)
tank_driver           = $1658
wram_165A           = $165A	; stage 1 tank: set to 1 when its damage counter reaches 8 (or player 1 is gone), then cleared when the tank swaps its BG blocks; probably the request to redraw it damaged (vram_blocks_05AF49 / _55)
tank_move_dx        = $165C	; stage 1 tank: x movement of the tank this frame (input_tank); non-zero shakes the screen (shake_continuous)
shake_continuous    = $1660	; non-zero: 1-pixel shake (update_shake_side_view) until cleared
shake_timer         = $1662	; shake amplitude in pixels, decremented every 16 frames (update_shake_side_view); objects set it for explosions
clamp_player_top    = $1666	; non-zero: move_player keeps the players' y at $31 or more (vertical autoscroll sections; set by the stage trigger type $42 and the spiked climber)
update_objects_stop = $166A	; slot where update_objects stops ($0AC0; $0300 for update_objects_0280)
obj06_dither_step   = $166C	; object type $06: step of the dither fade of state 8 ($3F down to 0, one every 2 frames; indexes object_type_06_dither_offsets)
stage_layout           = $1670	; side-view stage layout x2 (stage_layouts[stage_number], + $0A from the checkpoint); indexes the per-stage tables of stage_init and stage_layout_init
respawn_mode        = $1672	; respawn mode (from stage_respawn_modes, changed by triggers such as type $42): how player state $0F places the player (tbl_respawn_placement) and the state, pose and y velocity after it
scroll_split_y      = $1674	; vertical position the scroll-split HDMA table is built for (build_scroll_split_hdma)
scroll_split_pattern = $1676	; scroll-split pattern, 1-based index into ptrs_scroll_split_patterns; 0 = off
song_change_state   = $1678	; state of update_song_change (stage_frame): 0 idle, 1 delay, 2 stop the music (sound $84), 3 wait for the upload of song_change_set
song_change_wait    = $167A	; update_song_change: frames to wait after requesting the song set
wram_167C           = $167C	; only cleared, by stage_init; never read by name
wram_167E           = $167E	; only cleared, by stage_init; never read by name
song_change_mode    = $1680	; non-zero starts a song change (update_song_change): index into data_05AB58 (delay after sound $81); 2 = stop at once
song_change_set     = $1682	; song set list to load when the song changes (request_song_set); $F48A: the boss music
stage_exit_request           = $1686	; set by objects (end of the stage); stage_play then moves to STAGE_STATE_EXIT
clear_enemies_timer = $1688	; frames left (decremented by stage_frame) during which enemies that check it destroy themselves; set to 2 or 4 when a boss appears or dies (spiked climber, stage 4 controller, soldiers of type $7E...)
airship_spawn_index = $168A	; stage 4 airship section: offset of the next entry of airship_spawn_x / airship_spawn_type_y / airship_spawn_params (+6 per spawn; scroll_bg1_by_velocity_and_spawn)
bg1_vel_x_sub       = $168C	; stage 4 airship section: BG1 horizontal scroll speed, fraction (scroll_bg1_by_velocity_and_spawn adds it to bg1_x_sub; the stage 4 controller steers it)
bg1_vel_x           = $168E	; stage 4 airship section: BG1 horizontal scroll speed, pixels
bg1_vel_y_sub       = $1690	; stage 4 airship section: BG1 vertical scroll speed, fraction
bg1_vel_y           = $1692	; stage 4 airship section: BG1 vertical scroll speed, pixels; object type $06 (stage 1) uses it as a countdown ($80) instead
bg1_moved_x         = $1694	; stage 4 airship section: BG1's x movement this frame (scroll_bg1_by_velocity_and_spawn), subtracted from the objects that ride with the airship (scroll_with_airship)
bg1_moved_y         = $1696	; stage 4 airship section: BG1's y movement this frame
stage_layout_base           = $1698	; stage_layouts[stage_number], without the checkpoint offset
wram_169A           = $169A	; ending: set from the missile position (sub_1DB44A), and also used as the column counter of the ending text (sub_1DB98D); two uses, not named
wram_169C           = $169C	; ending: set from the missile position (sub_1DB44A); the ending text uses it as the line index (sub_1DB98D)
wram_169E           = $169E	; ending: set from the missile position by sub_1DB44A; never read by name
wram_16A0           = $16A0	; ending: set with wram_169E by sub_1DB44A; never read by name
ending_arm_lengths  = $16A2	; ending creature: lengths of its 4 arms ($16A2-$16A9, one word each; ending_creature_extend_arms, ending_sequence_state_0B)
bomb_coldata_mask   = $16AA	; ANDed with the bomb radius to make the colour of the bomb window (setup_bomb_window): $5F in the stages (stage_init), $FFFF for the opening's beam flash, $FF for the stage 4 ending
bomb_coldata_bits   = $16AC	; ORed into that colour: $20 in the stages (stage_init), 0 for the opening, $1F for the stage 4 ending
tank_moving         = $16AE	; stage 1 tank: 1 while it drives (input_tank plays sound $1E when it starts and $1F when it stops)
sound_throttle_timer = $16B0	; countdown of queue_sound_throttled: a sound is queued only when it is negative, then it restarts at 12-19 frames
trail_buffers_used           = $16B2
player_autopilot_mode           = $16B4	; non-zero: apply_player_autopilot forces the players' input (1-3, tbl_player_autopilot_modes); set by objects
spawn_disabled      = $16B6	; non-zero: stage_frame does not call spawn_stage_objects (stage 4 airship and ending scripted sections)
boss_hit_sound_timer = $16BA	; heart and brain bosses: frames before the hit sound ($3C) can play again (4 after each)
stage_pause_disabled           = $16BC	; non-zero: pause stays disabled during the stage (stage_play); set by an object
palette_anim_id           = $16BE	; palette animation of the stage (x2 index into data_05CD1B/data_05CD21); 0 = none (start_palette_anim)
palette_anim_timer           = $16C0	; frames until the next step of the palette animation (update_palette_anim)
hud_buffer          = $1700	; HUD tiles (tilemap words): rows of $20 bytes, p1 top $1700, p2 top $1720, p1 bottom $1740, p2 bottom $1760 (init_hud, update_p1_hud)
player_tile_src     = $1780	; side view: 12 source addresses (bank $7F) of the tiles of the player updated this frame (players 1 and 2 alternate frames): 6 rows for the top half (to VRAM player_tiles_vram_top), 6 for the bottom; written by set_player_frame from player_frames, DMAd by dma_bg_tilemap_updates
td_gfx_stream       = $1780	; top-down: sprite graphics stream list, entries of GFXS_SIZE bytes (8 for player 1's view, 8 from $17C0 for player 2's), filled by the sprite routines (draw_enemies ...), DMAd to VRAM $4000/$4800 by stream_topdown_sprite_gfx
m7_patch_flags      = $1800	; top-down: 4 Mode 7 block patch slots, flag words (2 = pending; set_m7_block_patch_0..3, uploaded by upload_m7_block_patches)
vram_block_queue    = $1800	; side view: up to 8 queued tile blocks, 8 bytes each: VRAM addresses of 4 rows (queue_vram_block, queue_vram_blocks; vram_block_queue_end); DMAd by dma_bg_tilemap_updates (vram_block_src: their sources); reset_vram_update_queues empties it
m7_patch_vram       = $1808	; top-down: VRAM addresses of the 4 rows of each patch slot (8 bytes per slot; reset_m7_block_patches points them at $6000)
m7_patch_tiles      = $1828	; top-down: the 16 tiles of each patch slot (16 bytes per slot)
vram_block_src      = $1840	; side view: source address (bank $7E) of each queued block of vram_block_queue (stride 8, first word)
block_anim_timer_left= $18AC	; stage 2: frames left of the TDA_BLOCK_ANIM block animation, left half of the map
block_anim_timer_right= $18AE	; stage 2: same, right half (x >= $200)
td_switch_events    = $18B0	; stage 5: the three switch events started by td_trigger_switch_event (SWEV_SIZE bytes each, SWEV_* fields; td_update_switch_events)
stage5_boss_claw_x  = $1900	; stage 5 boss claw: map x saved by stage5_boss_claw_state_1 and written back to the claw every frame after it (loc_02F650)
stage5_boss_claw_y  = $1902	; stage 5 boss claw: saved map y
wram_1B00           = $1B00	; start of the $1B00-$1BFF clear of clear_ram_1b00_1bff (no caller); $1B00-$1BFF has no other direct access
mode_work           = $1C00	; start of the work area $1C00-$1CFF of the current game mode, cleared by clear_mode_work; see the aliases below
mode_step           = $1C00	; step of the current game mode's handler (run_demo, run_title_menu, run_stage_clear, run_options, run_final_score, run_sound_check)
continue_cursor     = $1C00	; continue menu cursor (game_mode_continue)
demo_result         = $1C02	; attract demo: result passed to mode_result when it ends (1 = time out, 2 = Start pressed)
title_menu_timeout  = $1C02	; title menu: frames left before the demo starts ($0300, reset by any cursor move)
continue_option_count = $1C02	; continue menu: number of entries (2 CONTINUE/END, 3 for the player choice)
stage_bonus         = $1C02	; stage clear screen: bonus, BCD, low word (10000 at the start)
options_cursor      = $1C02	; OPTION screen: cursor (0 PLAYER, 1 LEVEL, 2 SOUND, 3 EXIT)
sound_check_id      = $1C02	; SOUND CHECK: selected entry ($00-$6A, index into sound_check_sound_ids)
demo_p1_timer       = $1C04	; attract demo: frames left of player 1's current input
stage_bonus_hi      = $1C04	; stage clear screen: bonus, BCD, high word
options_lives_index = $1C04	; OPTION screen: PLAYER entry (index into lives_options)
sound_check_repeat_delay = $1C04	; SOUND CHECK: auto-repeat delay of the d-pad
demo_p2_timer       = $1C06	; attract demo: frames left of player 2's current input
demo_p1_ptr         = $1C08	; attract demo: 24-bit pointer to player 1's input events (4 bytes each: buttons, frames)
code1_progress      = $1C08	; title: progress (x2) in the button code of check_button_code_unused
code1_timer         = $1C0A	; title: frames left to finish that code
demo_p2_ptr         = $1C0B	; attract demo: 24-bit pointer to player 2's input events
code2_progress      = $1C0C	; title: progress in the 30-lives code (check_30_lives_code)
demo_p1_input       = $1C0E	; attract demo: player 1 buttons currently played back / recorded
code2_timer         = $1C0E	; title: frames left to finish the 30-lives code
demo_p2_input       = $1C10	; attract demo: player 2 buttons currently played back / recorded
code3_progress      = $1C10	; title: progress in the stage select code (check_stage_select_code)
code3_timer         = $1C12	; title: frames left to finish the stage select code
konami_logo_step           = $1C60	; step of run_konami_logo (index into tbl_konami_logo_steps)
konami_logo_done           = $1C62	; set by konami_logo_fade_out when the logo has faded out; game_mode_konami_logo then starts the intro
konami_logo_count1           = $1C64	; Konami logo counters (palette cycle index, number of shine steps)
konami_logo_count2           = $1C66	; Konami logo counter
konami_logo_count3           = $1C68	; Konami logo counter
konami_logo_timer           = $1C6A	; Konami logo wait timer
opening_state           = $1C80	; state of the intro cinematic (opening_cinematic_step, index into tbl_opening_states)
opening_step           = $1C82	; step inside the current intro scene (each scene's own table)
opening_scene           = $1C84	; intro scene 0-6 (index into tbl_opening_scenes); see the book, Game flow
opening_scene_timer           = $1C86	; frames into the current intro scene, compared with opening_scene_durations
opening_step_timer           = $1C88	; frame counter of the current intro scene step
opening_flash_accum           = $1C8A	; fraction accumulator of the beam flash (opening_beam_flash)
opening_flash_speed_lo           = $1C8C	; speed of the beam flash, low word
opening_flash_speed_hi           = $1C8E	; speed of the beam flash, high word
opening_caption_index           = $1C90	; next caption piece drawn by opening_draw_caption_part
opening_caption_timer           = $1C92	; frames until the next caption piece
opening_frame_counter           = $1C96	; incremented every frame of the intro cinematic (opening_cinematic_step); drives the parallax
persistent_ram      = $1E00	; $1E00-$1FFF: options, scores, player stat blocks and PPU shadows; kept across a reset while boot_signature is valid, cleared from here on a cold boot (reset)
title_menu_cursor   = $1E02	; title menu choice; also read during play as 1 player (0) / 2 players (1)
boot_signature      = $1E0A	; 8 bytes ">JIN L<" + $0400: if present at reset, $1E00-$1FFF (options) survived and is not cleared
option_lives           = $1E3C	; OPTION > PLAYER: lives at the start of a game (3/5/7, from lives_options; 30 with check_30_lives_code); 3 at power-on
option_level           = $1E3E	; OPTION > LEVEL, x2: 0 EASY, 2 NORMAL, 4 HARD; copied to difficulty by init_players
stage_checkpoint           = $1E40	; 1 once the stage's midpoint is reached (set by objects); stage_init then starts the second half (stage_layout + $0A); cleared when a new stage starts
topdown_state           = $1E42	; state of the top-down stage, index into tbl_stage2_states / tbl_stage5_states (run_topdown_stage)
high_score           = $1E44	; high score, BCD, low word (update_high_score)
high_score_hi           = $1E46	; high score, BCD, high word
demo_index          = $1E48	; attract demo index
demo_record_mode           = $1E4A	; non-zero: the demo records pad input to SRAM ($70:0000 / $70:0400) instead of playing it back (debug; 0 at power-on, never set)
stage_gfx_loaded           = $1E4C	; non-zero: game_mode_stage_card skips load_stage_graphics (already loaded by the stage clear screen); cleared by init_new_game
pause_saved_brightness           = $1E4E	; inidisp_shadow saved while paused (apply_pause_dimming)
pause_saved_p1_brightness           = $1E50	; player 1 view brightness ($1FB4) saved while paused
pause_saved_p2_brightness           = $1E52	; player 2 view brightness ($1FF4) saved while paused
option_sound           = $1E54	; OPTION > SOUND, x2: index into sound_mode_commands (stereo / mono)
title_the_x           = $1E56	; X of the sprite word THE on the title (opening_slide_title_the, draw_title_word_sprites)
title_alien_x           = $1E58	; X of the sprite word ALIEN on the title
title_wars_x           = $1E5A	; X of the sprite word WARS on the title
title_tm_x          = $1E5C	; X of the TM mark sprite next to WARS on the title ($B0; checked by poking it)
life_transfer_disabled           = $1E5E	; non-zero: a player out of lives cannot take one from the other with A (update_life_transfer); set by some bosses
stage_select_enabled           = $1E60	; non-zero: game_mode_game_start goes to game_mode_stage_select; only set by the unused check_stage_select_code
continues_left           = $1E62	; continues left (init_continues from continues_per_difficulty; decremented on game over)
title_shake           = $1E64	; amplitude of the title shake (opening_shake_title)
inidisp_shadow      = $1E80	; INIDISP (brightness) written by the NMI frame handlers
nmitimen_shadow     = $1E82	; written to NMITIMEN by nmi and irq
bgmode_shadow       = $1E84	; BGMODE, written by write_ppu_shadows
obsel_shadow        = $1E86	; OBSEL, written by write_ppu_shadows
mosaic_shadow       = $1E8A	; MOSAIC, written by write_ppu_shadows
bg1sc_shadow        = $1E8C	; BG1SC, written by write_ppu_shadows
bg2sc_shadow        = $1E8E	; BG2SC, written by write_ppu_shadows
bg3sc_shadow        = $1E90	; BG3SC, written by write_ppu_shadows
bg4sc_shadow        = $1E92	; BG4SC, written by write_ppu_shadows
cgwsel_shadow       = $1E94	; CGWSEL, written by write_ppu_shadows
cgadsub_shadow      = $1E96	; CGADSUB, written by write_ppu_shadows
coldata_shadow      = $1E98	; COLDATA, written by write_ppu_shadows
tm_shadow           = $1E9A	; TM (main screen layers), written by write_ppu_shadows
ts_shadow           = $1E9C	; TS (sub screen layers), written by write_ppu_shadows
m7a_shadow          = $1E9E	; M7A (word, low byte first), written by write_ppu_shadows
m7b_shadow          = $1EA0	; M7B (word)
m7c_shadow          = $1EA2	; M7C (word)
m7d_shadow          = $1EA4	; M7D (word)
m7x_shadow          = $1EA6	; M7X (word)
m7y_shadow          = $1EA8	; M7Y (word)
m7sel_shadow        = $1EAA	; M7SEL, written by write_ppu_shadows
w12sel_shadow       = $1EAC	; W12SEL (low byte) and W34SEL (high byte), word-written by nmi_frame_side_view
wobjsel_shadow      = $1EAE	; WOBJSEL (low byte) and WH0 (high byte), word-written by nmi_frame_side_view
wram_1EB0           = $1EB0	; written $FF by stage_init and opening_cinematic_init with the window/colour math shadows, never read by name; probably the shadow of the window positions (WH1/WH2)
wram_1EB2           = $1EB2	; cleared with wram_1EB0; never read by name; probably the shadow of WH3/WH4
wbglog_shadow       = $1EB8	; WBGLOG, written by nmi_frame_side_view
tmw_shadow          = $1EBA	; TMW (low byte) and TSW (high byte), word-written by nmi_frame_side_view
wram_1EBC           = $1EBC	; cleared with tmw_shadow by the debug window keys; never read by name; probably a PPU register shadow
htime_shadow        = $1EC0	; written to HTIMEL/H by nmi
vtime_shadow        = $1EC2	; written to VTIMEL/H by nmi
hdmaen_shadow       = $1EC4	; HDMAEN, written by nmi_frame_top_down
pending_spc_list           = $1F2C
p1_weapon_slot      = $1F80	; player 1 active weapon slot (player 2: $1FC0)
p1_weapon_slot_other = $1F82	; player 1 inactive weapon slot (p1_weapon_slot xor 2; both 2 while p1_spin): update_weapon_swap
p1_weapon_1         = $1F84	; player 1 weapon (WEAPON_*) of the first slot, fired when p1_weapon_slot = 2 (spin_fire_weapon_1); PLAYER_WEAPON_1
p1_weapon_2         = $1F86	; player 1 weapon of the second slot, fired when p1_weapon_slot = 0 (spin_fire_weapon_2)
p1_barrier_timer    = $1F88	; player 1 barrier (invincibility) timer
p1_lives            = $1F8A	; player 1 lives
p1_bombs            = $1F8C	; player 1 smart bombs
p1_spin             = $1F8E	; 1 while player 1 holds L+R or spin-jumps: both weapons fire (update_spin_flag); PLAYER_SPIN
p1_m7_center_x           = $1F90	; Mode 7 rotation centre x of player 1's view (copied to p1_m7x by compute_m7_matrix)
p1_m7_center_y           = $1F92	; Mode 7 rotation centre y of player 1's view
p1_m7_scale_x           = $1F94	; Mode 7 scale of player 1's view, $0100 = 1:1, larger = zoomed out ($0500 in the intro and the map view)
p1_m7_scale_y           = $1F96	; Mode 7 vertical scale of player 1's view
p1_m7_angle           = $1F98	; Mode 7 rotation angle of player 1's view (256 units per turn)
p1_m7_hofs           = $1F9A	; Mode 7 horizontal scroll of player 1's view (copied to p1_bg1hofs)
p1_m7_vofs           = $1F9C	; Mode 7 vertical scroll of player 1's view (copied to p1_bg1vofs minus screen_shake_offset)
p1_weapon_select    = $1F9E	; player 1 weapon slot choice toggled (0/2) by X in update_weapon_swap; p1_weapon_slot = this xor 2
p1_score           = $1FA0	; player 1 score, BCD, low word (add_score; player stat block + $20)
p1_score_hi           = $1FA2	; player 1 score, BCD, high word (max 9999999)
p1_m7a           = $1FA4	; M7A for player 1's view, computed by compute_m7_matrix, written by the IRQ (irq_mode7_top_view)
p1_m7a_hi           = $1FA5	; high byte of p1_m7a
p1_m7b           = $1FA6	; M7B for player 1's view
p1_m7b_hi           = $1FA7	; high byte of p1_m7b
p1_m7c           = $1FA8	; M7C for player 1's view
p1_m7c_hi           = $1FA9	; high byte of p1_m7c
p1_m7d           = $1FAA	; M7D for player 1's view
p1_m7d_hi           = $1FAB	; high byte of p1_m7d
p1_m7x           = $1FAC	; M7X for player 1's view
p1_m7x_hi           = $1FAD	; high byte of p1_m7x
p1_m7y           = $1FAE	; M7Y for player 1's view
p1_m7y_hi           = $1FAF	; high byte of p1_m7y
p1_bg1hofs           = $1FB0	; BG1HOFS for player 1's view (IRQ irq_mode7_top_view)
p1_bg1hofs_hi           = $1FB1	; high byte of p1_bg1hofs
p1_bg1vofs           = $1FB2	; BG1VOFS for player 1's view
p1_bg1vofs_hi           = $1FB3	; high byte of p1_bg1vofs
p1_view_brightness           = $1FB4	; brightness of player 1's view (top half in 2P-A), written to the INIDISP HDMA table by the top-down NMI (nmi_frame_top_down)
p1_next_extend           = $1FB6	; player 1 points left until the next extra life, BCD, low word (stat block + $36; starts at 20000, +60000 per life; add_score)
p1_next_extend_hi           = $1FB8	; high word of p1_next_extend
p2_weapon_slot      = $1FC0	; player 2 active weapon slot (by the $40 stride of the player blocks)
p2_weapon_slot_other = $1FC2	; player 2 inactive weapon slot
p2_weapon_1         = $1FC4	; player 2 weapon of the first slot
p2_weapon_2         = $1FC6	; player 2 weapon of the second slot
p2_barrier_timer    = $1FC8	; player 2 barrier (invincibility) timer
p2_lives            = $1FCA	; player 2 lives
p2_bombs            = $1FCC	; player 2 smart bombs
p2_spin             = $1FCE	; same for player 2
p2_m7_center_x           = $1FD0	; Mode 7 rotation centre x of player 2's view (2P-A split screen)
p2_m7_center_y           = $1FD2	; Mode 7 rotation centre y of player 2's view
p2_m7_scale_x           = $1FD4	; Mode 7 scale of player 2's view
p2_m7_scale_y           = $1FD6	; Mode 7 vertical scale of player 2's view
p2_m7_angle           = $1FD8	; Mode 7 rotation angle of player 2's view
p2_m7_hofs           = $1FDA	; Mode 7 horizontal scroll of player 2's view
p2_m7_vofs           = $1FDC	; Mode 7 vertical scroll of player 2's view
p2_weapon_select    = $1FDE	; player 2 weapon slot choice toggled by X
p2_score           = $1FE0	; player 2 score, BCD, low word
p2_score_hi           = $1FE2	; player 2 score, BCD, high word
p2_m7a           = $1FE4	; M7A for player 2's view (compute_p2_m7_matrix; IRQ irq_mode7_bottom_view at the split)
p2_m7a_hi           = $1FE5	; high byte of p2_m7a
p2_m7b           = $1FE6	; M7B for player 2's view
p2_m7b_hi           = $1FE7	; high byte of p2_m7b
p2_m7c           = $1FE8	; M7C for player 2's view
p2_m7c_hi           = $1FE9	; high byte of p2_m7c
p2_m7d           = $1FEA	; M7D for player 2's view
p2_m7d_hi           = $1FEB	; high byte of p2_m7d
p2_m7x           = $1FEC	; M7X for player 2's view
p2_m7x_hi           = $1FED	; high byte of p2_m7x
p2_m7y           = $1FEE	; M7Y for player 2's view
p2_m7y_hi           = $1FEF	; high byte of p2_m7y
p2_bg1hofs           = $1FF0	; BG1HOFS for player 2's view
p2_bg1hofs_hi           = $1FF1	; high byte of p2_bg1hofs
p2_bg1vofs           = $1FF2	; BG1VOFS for player 2's view
p2_bg1vofs_hi           = $1FF3	; high byte of p2_bg1vofs
p2_view_brightness           = $1FF4	; brightness of player 2's view (bottom half in 2P-A)
p2_next_extend           = $1FF6	; player 2 points left until the next extra life, BCD, low word
p2_next_extend_hi           = $1FF8	; high word of p2_next_extend

; ---- $7E:2000-$7F:FFFF ----

wram_7E2000         = $7E2000	; start of RAM clears: $7E:2000-$7E:23FF (clear_palette_tasks_and_buffer), $7E:2000-$7E:FFFF (warm_boot), clear_topdown_ram
palette_buffer      = $7E2200	; palette DMAd to CGRAM every frame by dma_oam_and_palette (512 bytes; cgram_dma_src)
hdma_tables         = $7E3800	; 8 HDMA tables of 32 bytes ($7E:3800-$7E:38FF) for the channels set up by setup_stage_hdma (side view: BG2 scroll of the stage 1 tank, parallax, the missile...) and init_topdown_hdma (top-down: the tables at +$60-+$E0, the split screen brightness at +$A1-+$A7, written by nmi_frame_top_down); the layout depends on the stage
window_hdma_a       = $7E3C00	; window HDMA table, odd frames (top-down: double buffer with window_hdma_b, built by update_topdown_window; swap_topdown_window_buffer); +$1E: its data
window_hdma_b       = $7E3E00	; window HDMA table, even frames
wram_7E4000         = $7E4000	; start of the $7E:4000-$7E:FFFF clear (clear_wram_7e4000_7effff); the tile attribute map is at $7E:4000
wram_7E8000         = $7E8000	; start of the $7E:8000-$7E:9FFF clear (clear_wram_7e8000_and_7ec000, no caller)
scroll_hdma_tables  = $7EA000	; HDMA scroll tables of effects ($7E:A000-$7E:A5FF: the opening parallax and ruins wave, object type $4E, the stage 1 boss, the ending...; clear_hdma_line_buffer clears $200 bytes); other stages load data here
wram_7EC000         = $7EC000	; start of the $7E:C000-$7E:DFFF clear (clear_wram_7e8000_and_7ec000)
effect_hdma_buf     = $7EE800	; HDMA data of stage effects at $7E:E800-$7E:E9FF: the tables of the winged alien and of the ending missile written directly, or the line tables of fill_line_hdma_table (up from the centre at $E800, down at $E900)
winged_alien_hdma_state = $7EE823	; winged alien: step of its HDMA band effect (0 from winged_alien_step_2, 1 while the band grows or shrinks, 2 when it reached its limit; sub_04A313 / sub_04A32A)
winged_alien_hdma_center_y = $7EE825	; winged alien: screen y of the band (OBJ_Y when it starts)
winged_alien_hdma_height = $7EE827	; winged alien: height of the band, +-4 a frame (between 1 and $74)
winged_alien_hdma_lines = $7EE829	; winged alien: address in effect_hdma_buf of the line table built by sub_04A34A ($E880 + $1E0)
winged_alien_hdma_counts = $7EE82B	; winged alien: 6 words, the line counts of the effect_hdma_buf entries built by winged_alien_warp_write_hdma (2 above the band, 2 in it, 2 below; sub_04A37A)
line_hdma_ind       = $7EEA00	; indirect HDMA table pointing into the line tables of fill_line_hdma_table
debug_window_hdma_a = $7EF800	; debug_window_keys (no caller): window HDMA table (indirect, 2 entries of $FF lines)
debug_window_hdma_b = $7EFA00	; debug_window_keys: second window HDMA table
wram_7F0000         = $7F0000	; start of the $7F:0000-$7F:FFFF clear (warm_boot)

; ---- structures (offsets, not addresses) ----
;
; Use these only on an indexed operand whose index register was checked to
; hold a slot address (lda OBJ_STATE,x / lda a:OBJ_FLAGS,y); the same
; numbers index other structures elsewhere.  See the book, "Objects".
;
; Main object list: slots of OBJ_SIZE bytes from $0200: players at $0200 /
; $0240 (see PLAYER_* below), $0280 and $02C0 run by update_objects_0280, and
; $0300-$0ABF (30 slots) run by update_objects.  New objects are allocated in
; $0300-$077F (find_free_slot / find_free_slot_y search upwards); enemy bullets
; (spawn_enemy_bullet) search downwards from $0740.  Freed by clearing the slot
; (OBJ_FLAGS bit 15, or OBJ_TYPE 0 = free).
OBJ_SIZE            = $40
OBJ_SPRITE          = $00	; metasprite pointer (bank $06) drawn by draw_metasprite; 0 = not drawn.  Set from the animation script (OBJ_ANIM) or by the handler
OBJ_ATTR            = $02	; OAM attribute bits (high byte: flip, priority, palette) ORed into every sprite of the metasprite
OBJ_FACING          = $04	; 0: an animation frame shows its first sprite, else its second (the mirrored one); players: 0 right, 2 left
OBJ_ANGLE           = $04	; the same field as OBJ_FACING, used as an 8-bit angle ($00 up, $40 right, $80 down, $C0 left) by objects moved with set_velocity_from_angle (larvae, face boss side heads); with a non-zero angle the animation shows the second sprite
OBJ_HP              = $06	; hit points: a shot subtracts its SHOT_DAMAGE, the bomb 1, the barrier 1; below 0 = destroyed (add_score_for_player_obj adds type_scores[type] to the score). Negative also means "not a target"
HP_UNKILLABLE       = $0FFF	; OBJ_HP of bodies that should not die from shots (cave beast, snake robot body; the part that takes damage is another object): 4095 HP, more than 2000 default-gun hits
OBJ_X_SUB           = $08	; x position, fraction
OBJ_X               = $0A	; x position, pixels (screen; also the hitbox left edge)
OBJ_Y_SUB           = $0C	; y position, fraction
OBJ_Y               = $0E	; y position, pixels (screen; also the hitbox bottom edge)
OBJ_TYPE            = $10	; object type: handler index into tbl_object_types (call_object_handler); 0 = free slot
OBJ_STATE           = $12	; state of the type's handler (player1_state is player 1's)
OBJ_HIT             = $14	; non-zero during the frame the object was hit (shots store their SHOT_TYPE, the bomb $0100, the barrier 1); shows the flash palette, cleared by update_objects after drawing
OBJ_FLAGS           = $16	; OBJF_* bits below
OBJ_X_VEL_SUB       = $18	; x velocity, fraction (added to OBJ_X_SUB when OBJF_MOVE)
OBJ_X_VEL           = $1A	; x velocity, pixels
OBJ_Y_VEL_SUB       = $1C	; y velocity, fraction
OBJ_Y_VEL           = $1E	; y velocity, pixels
OBJ_ANIM            = $20	; animation script pointer (bank $05), 0 = none: entries of 3 words (duration, sprite, mirrored sprite); a negative word is a jump to that address, 0 ends the script (update_objects)
OBJ_ANIM_TIMER      = $22	; frames left in the current animation entry; store 0 with a new OBJ_ANIM to start it
OBJ_TIMER           = $24	; general-purpose counter of the handler (mostly a countdown)
OBJ_SAVED_ATTR      = $26	; OBJ_ATTR saved while the hit flash palette replaces it (update_objects)
OBJ_HITBOX_W        = $28	; hitbox width: box spans OBJ_X .. OBJ_X+OBJ_HITBOX_W
OBJ_HITBOX_H        = $2A	; hitbox height, negative: box spans OBJ_Y+OBJ_HITBOX_H .. OBJ_Y
OBJ_HITBOX_RIGHT    = $2C	; OBJ_X + OBJ_HITBOX_W, computed each frame for OBJF_TARGET objects (read by shot and bomb collision)
OBJ_HITBOX_TOP      = $2E	; OBJ_Y + OBJ_HITBOX_H, likewise
; $30-$3B: free for the handler (no common meaning)
OBJ_TOUCHED_BY      = $3C	; slot of the player whose body overlaps the object this frame (OBJF_TOUCH); not cleared by the loop
;
; OBJ_FLAGS bits (tested in update_objects, update_shots, bomb_hit_targets):
OBJF_MOVE           = $0001	; add the velocity to the position and follow the BG scroll ($138E/$13A6)
OBJF_OFFSCREEN_KILL = $0002	; freed when OBJ_X or OBJ_Y leaves -$20..$11F
OBJF_HARMFUL        = $0004	; touching it kills the player (ORed into PLAYER_CONTACT; removed while the player has the barrier)
OBJF_TOUCH          = $0008	; check the overlap with a player's body (sets OBJ_TOUCHED_BY, ORs OBJ_FLAGS into PLAYER_CONTACT)
OBJF_TARGET         = $0010	; listed in shot_targets each frame: shots, the bomb and the barrier hit it
OBJF_INVULNERABLE   = $0020	; hit (OBJ_HIT set, shots stop) but OBJ_HP is not reduced and no flash
OBJF_CLANG          = $4000	; a shot that hits it without damage plays sound $10
OBJF_DELETE         = $8000	; free the slot after its handler returns
;
; Player objects ($0200 player 1, $0240 player 2) are slots of the same
; list run by their own code (update_players); the fields above with the same
; meaning are OBJ_SPRITE, OBJ_ATTR, OBJ_FACING, the position and velocity,
; OBJ_STATE (PLAYER_STATE_* below) and OBJ_FLAGS (0 = not present,
; bit 1 = invulnerable after respawn, bit 15 = not touchable).  Others
; differ:
; Player OBJ_FLAGS: 0 = absent (game over); also
PLAYERF_INVULNERABLE = $0002	; set while PLAYER_INVULN_TIMER runs: enemies' bodies do not kill
PLAYERF_INTANGIBLE  = $8000	; dying / not on the screen: not touched by objects
PLAYER_HITBOX_LEFT  = $06	; body box, left (= OBJ_X)
PLAYER_HITBOX_BOTTOM = $10	; body box, bottom (= OBJ_Y)
PLAYER_FIRE_DELAY_2 = $14	; frames before PLAYER_WEAPON_2 can fire again (reloaded from weapon_fire_delays[weapon] by spin_fire_weapon_2 / fire_weapon)
PLAYER_POSE         = $20	; pose (index of the frame tables player_frames.., 16 bytes each), not an animation pointer
PLAYER_JOY_HELD     = $22	; joypad buttons held (copied from joy1_held/joy2_held)
PLAYER_INVULN_TIMER = $24	; respawn invulnerability: counts down, the player blinks, OBJ_FLAGS bit 1 cleared at 0
PLAYER_AIM          = $26	; directions held this frame: 1 right, 2 up, 4 left, 8 down (index of the aim tables)
PLAYER_HITBOX_RIGHT = $28	; body box, right
PLAYER_HITBOX_TOP   = $2A	; body box, top
PLAYER_JOY_PRESSED  = $2C	; joypad buttons newly pressed (copied from joy1_pressed/joy2_pressed)
PLAYER_LOCKED       = $2E	; non-zero while the "stand still" button (button_stand_still / wram_1628) is held: no walking
PLAYER_SPIN_ANGLE_2 = $34	; angle of the next spin-jump shot of PLAYER_WEAPON_2 (spin_shot_*_2); also used by other states
PLAYER_SPIN_ANGLE_1 = $36	; angle of the next spin-jump shot of PLAYER_WEAPON_1 (spin_shot_*_1)
PLAYER_SHOT_POSE    = $38	; set to 1 by the shot spawners: added to the frame index (shooting pose) by set_player_frame, which clears it
PLAYER_FIRE_DELAY_1 = $3A	; frames before PLAYER_WEAPON_1 can fire again (spin_fire_weapon_1 / fire_weapon)
PLAYER_CONTACT      = $3C	; contact flags, PCONTACT_* bits
; Player parallel fields at slot + $1300 ($1500 player 1, $1540 player 2):
PLAYER_POSE_ADD     = $1300	; added to PLAYER_POSE (shooting poses), cleared every frame
PLAYER_PLATFORM     = $1304	; slot of the solid object the player was last pushed by / stands on (solid_object_vs_player)
PLAYER_DX           = $1306	; x movement of this frame (move_player)
PLAYER_DY           = $130C	; y movement of this frame
PLAYER_BOMB_RADIUS  = $1310	; bomb blast half-size, 0 = no bomb active (check_bomb_button starts it, update_bomb grows it to $FF)
PLAYER_CENTER_X     = $1312	; point enemies aim at (angle_to_player, fire_bullet_at_player)
PLAYER_CENTER_Y     = $1314
PLAYER_BOMB_SPEED_SUB = $1318	; bomb growth per frame, fraction (accelerates by $0800 a frame)
PLAYER_BOMB_SPEED   = $131A	; bomb growth per frame, pixels
PLAYER_BOMB_X       = $131C	; bomb centre (PLAYER_CENTER_X when it was thrown)
PLAYER_BOMB_Y       = $131E
; Player stat block at slot + $1D80 ($1F80 player 1, $1FC0 player 2; see
; p1_* / p2_*):
PLAYER_STATS_STRIDE = $40
PLAYER_WEAPON_SLOT  = $1D80	; p1_weapon_slot: 2 = fire PLAYER_WEAPON_1, 0 = PLAYER_WEAPON_2
PLAYER_WEAPON_SLOT_OTHER = $1D82	; the other slot value (equal to PLAYER_WEAPON_SLOT when both fire)
PLAYER_WEAPON_1     = $1D84	; weapon (WEAPON_*) in the first slot (active at the start)
PLAYER_WEAPON_2     = $1D86	; weapon in the second slot
PLAYER_BARRIER      = $1D88	; p1_barrier_timer
PLAYER_LIVES        = $1D8A	; p1_lives
PLAYER_BOMBS        = $1D8C	; p1_bombs
PLAYER_SPIN         = $1D8E	; 1 while L and R are both held or in the spin jump (state PLAYER_STATE_SPIN_JUMP): both weapons fire (update_spin_flag)

; Player states (OBJ_STATE of a player; handlers in tbl_player_states, input
; handling in tbl_player_input).  Seen in the emulator: 0 on the ground, 3 jump,
; 4 falling (also the drop-in after a respawn), 7 / 8 death, $0E / $0F
; respawn.  The others (climbing, hanging, scripted moves) are not
; identified yet.
PLAYER_STATE_GROUND = $00	; standing / walking / crouching
PLAYER_STATE_JUMP   = $03	; jumping (player_state_jump)
PLAYER_STATE_FALL   = $04	; falling (player_state_fall)
PLAYER_STATE_WAIT_MISSILE = $06	; respawning in the stage 4 sky: waits for a rideable missile (type $65) to be placed on (respawn_on_missile)
PLAYER_STATE_DYING  = $07	; hit: thrown back (player_state_dying), entered at kill_player
PLAYER_STATE_DEAD   = $08	; lying dead; when the countdown at +$30 ends, takes a life (player_state_dead)
PLAYER_STATE_ENTER_TANK = $09	; stage 1: dropping into the tank (player_state_enter_tank)
PLAYER_STATE_TANK   = $0A	; stage 1: driving the tank (player_state_tank, input_tank)
PLAYER_STATE_SPIN_STANCE = $0B	; L+R held on the ground (player_state_spin_stance)
PLAYER_STATE_SPIN_JUMP = $0C	; spin jump: fire pressed during PLAYER_STATE_SPIN_STANCE
PLAYER_STATE_HANG_CLIMB = $0D	; hanging, can grab a wall and climb (player_state_hang_climb; seen in stage 6)
PLAYER_STATE_OUT    = $0E	; waiting to respawn (player_state_out: needs lives left)
PLAYER_STATE_RESPAWN = $0F	; respawning (player_state_respawn)
PLAYER_STATE_HANG_OBJECT = $10	; hanging from a moving object (stage 3; player_state_hang_object)
PLAYER_STATE_BIKE   = $11	; stage 4: riding the hover bike (player_state_bike; the bike is type $6D)
PLAYER_STATE_BIKE_INTRO = $12	; stage 4: driving in on the bike, invulnerable (player_state_bike_intro)
PLAYER_STATE_ENDING = $13	; ending: posing on the helicopter (player_state_ending, set by the ending sequence)
PLAYER_STATE_ENDING_WAVE = $14	; ending: pose animation replayed while Y is held (player_state_ending_wave)
;
; Weapons (PLAYER_WEAPON_1 / PLAYER_WEAPON_2, p1_weapon_1...): index of the
; shot spawners tbl_spin_fire_1 / tbl_spin_fire_2 / tbl_fire_weapon and of weapon_fire_delays
; (fire delay); checked in the emulator by poking p1_weapon_1.
WEAPON_DEFAULT      = 0	; the starting gun
WEAPON_SPREAD       = 1	; S
WEAPON_CRUSH        = 2	; C (missiles that explode)
WEAPON_HOMING       = 3	; H
WEAPON_FLAME        = 4	; F
WEAPON_LASER        = 5	; L
;
; PLAYER_CONTACT bits:
PCONTACT_KILLED     = $0004	; killed: harmful object, enemy bullet, fell off the screen (checked by the states, kill_player)
PCONTACT_ON_OBJECT  = $0080	; standing on a solid object
PCONTACT_BLOCK_LEFT = $0200	; a solid object on the left: cannot walk left
PCONTACT_BLOCK_RIGHT = $0400	; a solid object on the right: cannot walk right
;
; Secondary object list (player shots): 40 slots of SHOT_SIZE bytes at
; $0AC0-$0FBF, run by update_shots: player 1's shots in $0AC0-$0D3F (first
; weapon slot $0AC0-$0BFF, second $0C00-$0D3F), player 2's in $0D40-$0FBF
; ($0D40 / $0E80).  Position and velocity at the same offsets as OBJ_*.
SHOT_SIZE           = $20
SHOT_ATTR           = $02	; OAM tile and attributes of the shot's single sprite; bit 8 set = 16x16 at (x, y), clear = 8x8 at (x+4, y+4); 0 = not drawn
SHOTA_LARGE         = $0100	; SHOT_ATTR bit: 16x16 sprite
SHOT_DAMAGE         = $06	; subtracted from the target's OBJ_HP; 0 = does not hit
SHOT_TYPE           = $10	; handler index into tbl_shot_types (call_shot_handler); 0 = free
SHOT_HIT            = $16	; set to 1 when the shot hit something (the handler then removes it); negative when it destroyed the target

; ---- top-down stages (src/topdown/) ----
;
; topdown_map values (x2 indexes of the per-map jump tables).
TD_MAP_STAGE2       = $0000	; stage 2 main map
TD_MAP_STAGE2_BOSS  = $0002	; stage 2 boss map
TD_MAP_STAGE5       = $0004	; stage 5 main map
TD_MAP_STAGE5_BOSS  = $0006	; stage 5 boss map
; Mode 7 scale (p1_m7_scale_x/y): texels per pixel, 8.8 fixed point.
M7_SCALE_1X         = $0100	; 1:1, normal play
M7_SCALE_MAP        = $0500	; zoomed out to the whole map (intro and map view)
;
; Tile attributes: one byte per Mode 7 tile in the map at $7E:4000
; (build_tile_attr_rows, tables tile_attrs_stage2 ...). Below $80, bits
; 0-2 are a wall shape and bit 4 changes the object's sprite priority;
; from $ED up, special tiles whose handler is entry $FF - attribute of
; tbl_td_player_special_tiles (and of tbl_td_enemy_special_tiles, where
; most of them kill the enemy).
TDA_FLOOR           = $00	; walkable
TDA_WALL_MASK       = $07	; wall shape: 1 solid; 3, 4, 5 seen too (td_push_out_of_walls pushes along them)
TDA_PRIORITY_HIGH   = $08	; with TDA_SET_PRIORITY: priority $2000, else $1000 (the other way round for enemy shots)
TDA_SET_PRIORITY    = $10	; sets the priority bits ($3000) of +$02 of who walks on it (passing under or over a structure)
TDA_SPECIAL         = $80	; special tile, the values below
TDA_FALL_DOWN_RIGHT = $ED	; stage 5 slopes, $ED-$F4: the player slides that way and falls (td_tile_fall_*)
TDA_FALL_DOWN_LEFT  = $EE
TDA_FALL_UP_RIGHT   = $EF
TDA_FALL_UP_LEFT    = $F0
TDA_FALL_UP         = $F1
TDA_FALL_DOWN       = $F2
TDA_FALL_RIGHT      = $F3
TDA_FALL_LEFT       = $F4
TDA_PUSH_RIGHT      = $F5	; stage 5 sand currents, $F5-$F8: move the player (and enemies) by td_push_speed a frame
TDA_PUSH_LEFT       = $F6
TDA_PUSH_UP         = $F7
TDA_PUSH_DOWN       = $F8
TDA_SAND_PIT        = $F9	; stage 5 boss: the funnel; pulls the player in a spiral to the centre (td_spiral_into_sand_pit)
TDA_WHIRL           = $FA	; stage 5: whirlpool; turns the player (enemies lose HP) around the centre of its 32x32 cell
TDA_SWITCH          = $FB	; stage 5: Y or A here starts a switch event (td_trigger_switch_event)
TDA_MAP_OBJECT      = $FC	; part of a map object (target, boss): blocks shots, which hit the object (td_get_map_object_at)
TDA_TRAP            = $FD	; stage 2: 500 points, then a TDI_BLAST explodes there (td_trigger_trap)
TDA_BLOCK_ANIM      = $FE	; stage 2: shakes the screen and animates map blocks (td_trigger_block_anim)
TDA_HOLE            = $FF	; hole: the player falls (td_player_state_falling), an enemy dies
; Top-down sprite graphics stream entry (td_gfx_stream, stream_topdown_sprite_gfx):
GFXS_SIZE           = $08
GFXS_SRC            = $00	; source address of the first $100-byte chunk
GFXS_BANK           = $02	; its bank (also used for GFXS_SRC2)
GFXS_SRC2           = $04	; source address of the second chunk
; Stage 5 switch event (td_switch_events, td_step_switch_event):
SWEV_SIZE           = $0E
SWEV_ACTIVE         = $00	; non-zero while the event runs (td_trigger_switch_event sets 1)
SWEV_STEPS          = $02	; block patches left (8 at the start)
SWEV_TIMER          = $04	; frames since the last step (compared with td_switch_event_step_delays[difficulty])
SWEV_DIR            = $06	; 0 or 2: which side of the switch, index of td_switch_event_step_x / _vram
SWEV_X              = $08	; map x of the next patch (explosions around it)
SWEV_Y              = $0A	; map y of the next patch
SWEV_VRAM           = $0C	; VRAM address of the next block patch (queue_m7_block_patch)

; ---- engine and sound constants ----

; nmi_mode values (frame handler, tbl_nmi_frame_handlers)
NMI_MODE_DEFAULT    = 0	; nmi_frame_default: menus, screens, loading
NMI_MODE_SIDE_VIEW  = 2	; nmi_frame_side_view: side-view stages
NMI_MODE_TOP_DOWN   = 4	; nmi_frame_top_down: top-down Mode 7 stages
; Sound CPU commands (APUIO0) with a known meaning
SOUND_CMD_STOP      = $84	; queued first by reset_sound_queue before screen changes and sent before uploads: stops all sound (by its use)
SOUND_CMD_UPLOAD    = $FF	; sent by start_song_set_upload after SOUND_CMD_STOP: the driver enters its upload loop
; VRAM DMA queue in $7E (run_vram_queue)
VRAM_QUEUE          = $3000	; start of the queue entries ($7E:3000)
VRAM_QUEUE_DATA     = $3400	; start of the data buffer ($7E:3400)

; Loader contexts (engine/gfx_loader.asm): the loader and the decompressor
; run with the direct page register D at one of these, so their direct-page
; operands are the LDR_* fields below (the "; $13xx (D=$1300)" comments give
; the address really accessed).
LOADER_VRAM         = $1300	; context of VRAM lists (type 0, and 3+), ring buffer $7E:2400
LOADER_WRAM         = $1340	; context of WRAM lists (type 1), ring buffer $7E:2800
LOADER_SPC          = $1F00	; context of sound CPU lists (type 2), ring buffer $7E:2C00
LDR_SRC             = $00	; long pointer to the compressed stream (or raw block)
LDR_RING            = $03	; long pointer to the context's 1 KiB ring buffer (decompressor output and window)
LDR_SRC_POS         = $06	; read offset in the stream (raw SPC block: its size)
LDR_SRC_END         = $08	; stream length: its first word (offset where it ends)
LDR_COPY            = $0A	; back-reference position in the ring / RLE byte (+1: command byte)
LDR_RING_POS        = $0C	; write offset in the ring (bytes decompressed so far)
LDR_COUNT           = $0E	; bytes left in the current command
LDR_ACTIVE          = $10	; non-zero while a stream is being decompressed
LDR_PENDING         = $12	; non-zero while a deferred list is being loaded frame by frame
LDR_STATE           = $14	; decompressor state to resume in (0 = read a command; 1-5 = inside a command)
LDR_FLAGS           = $16	; the list's flags byte (bit 0: deferred, or low bytes for types 3+)
LDR_LIST            = $18	; pointer to the next entry of the list (bank $05)
LDR_RING_DONE       = $1A	; ring offset up to which the output was consumed (DMAd/copied/sent)
LDR_RING_LIMIT      = $1C	; ring offset where the decompressor stops this call
LDR_VRAM_DEST       = $22	; VRAM: word address of the next chunk
LDR_DMA_READY       = $26	; VRAM: a decompressed chunk waits for dma_vram_loader_chunk (NMI)
LDR_WRAM_DEST       = $20	; WRAM: long pointer to the next destination byte
LDR_SPC_COUNTER     = $20	; SPC: transfer counter written to APUIO0
LDR_SPC_DEST        = $22	; SPC: address of the block
LDR_SPC_STREAM_ID   = $24	; SPC streaming (never run): id byte of the stream
LDR_SPC_STREAM_ON   = $26	; SPC streaming: cleared to abort the stream
LDR_SPC_PORT_WORD   = $28	; SPC streaming: word being written to APUIO2/3
LDR_SPC_PENDING_LIST = $2C	; SPC: song set list to upload (pending_spc_list)
LDR_SPC_STREAM_STATUS = $2E	; SPC streaming: status word per stream (2 words)
; BG scroll states ($40 bytes): BG1 at $1380 (bg1_x), BG2 at $13C0 (bg2_x),
; BG3 at $1400 (engine/bg_scroll.asm; X = the state's address).
BG_X                = $00	; horizontal scroll, pixels
BG_X_SUB            = $04	; horizontal scroll, fraction (bg1_x_sub; the BG1/BG2 autoscrolls add to it with carry into BG_X)
BG_HOFS_LATCH       = $0A	; BG_X of the previous frame: what nmi_frame_side_view writes to BGnHOFS (BG1/BG2)
BG_X_DELTA_SUB      = $0C	; fraction of BG_X_DELTA: cleared with it (clear_bg1_scroll_deltas, clear_bg2_scroll_deltas); the stage 4 missile's BG3 HDMA scroll (stage4_scroll_bg3_lower) adds BG_X_DELTA_SUB / BG_X_DELTA to BG_X_SUB / its table
BG_X_DELTA          = $0E	; horizontal movement of this frame (objects subtract it, bg1_x_delta; BG2 parallax: accumulator of BG1's)
BG_X_MOVED          = $12	; BG2: pixels BG_X moved this frame (bg2_parallax_x_1_8 counts its steps, bg2_follow_bg1_x copies bg1_x_delta; read by the line scroll ramp at add_bg2_line_scroll_ramp)
BG_Y                = $18	; vertical scroll, pixels
BG_Y_SUB            = $1C	; vertical scroll, fraction (bg2_y_sub; scroll_bg1_by_velocity_and_spawn adds to BG1's with carry into BG_Y)
BG_VOFS_LATCH       = $22	; BG_Y minus the shake offset, written to BGnVOFS one frame later
BG_Y_DELTA_SUB      = $24	; fraction of BG_Y_DELTA: the BG1 vertical autoscroll adds its speed here with carry into bg1_y_delta (bg1_y_sub); cleared with it
BG_Y_DELTA          = $26	; vertical movement of this frame (bg1_y_delta; BG2: accumulator of BG1's)
BG_Y_MOVED          = $2A	; BG2: pixels BG_Y moved this frame (bg2_parallax_y_1_3 counts its steps down)
BG_PAGE             = $30	; 256-pixel page of the scroll position last seen (a new one advances BG_MAP_OFFSET)
BG_COLUMN_OFFSET    = $32	; tile columns added to the column draw_bg_column draws (0 or 8)
BG_MAP_OFFSET       = $3C	; offset of the current page in the layer's map in $7E (+$80 per page)
; Palette task and VRAM task slots ($10 bytes; palette_tasks, vram_tasks)
TASK_TYPE           = $00	; handler (1-based index into tbl_palette_task_types / tbl_vram_task_types), 0 = free
TASK_SCRIPT         = $02	; script address (bank $05)
TASK_PROGRESS       = $04	; animations: frames done / loops done; fades: level x $100 (8.8, up to $2000)
TASK_ENTRY          = $06	; animations: offset of the current entry in the script
TASK_DELAY          = $08	; animations: frames left before the next entry

.endif
