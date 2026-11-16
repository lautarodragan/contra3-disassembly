# Curiosities: bugs, leftovers and oddities

This page gathers the strange things the disassembly has turned up: code
that does not do what its authors evidently meant, code and data the game
never uses, tables that share their bytes, and a few other surprises. Most
of them are explained in more detail on other pages or in the source
comments; the entries here summarise them and link there.

Labels are written as in the rest of the book (`update_grenade`); search
`src/` for the label to find the code.

## Bugs in the original game

Only things the code itself shows are listed here. Something that might
be deliberate is under [Other oddities](#other-oddities) instead.

### The stage 6 alien soldiers ignore the difficulty

`object_type_56_set_velocity` sets the walking speed of object type `$56`,
the alien soldiers that `update_alien_soldier_spawner` sends in from the
edges of the screen on stage 6. It loads `difficulty` into Y and then
reads `object_type_56_x_vel_subs_right` / `object_type_56_x_vels_right`
(or the `_left` pair) **without** the `,y` index:

```
	ldy	difficulty
	lda	a:object_type_56_x_vel_subs_right	; no ,y
	sta	$18,x
	lda	a:object_type_56_x_vels_right	; no ,y
	sta	$1A,x
```

- **Meant:** the tables hold one speed per difficulty: 2, 2.5 and 3 pixels
  per frame (EASY, NORMAL, HARD), the same to the left.
- **Does:** always reads the first entry, so every difficulty gets the EASY
  speed of 2 pixels per frame.
- **Effect:** the soldiers are slower on NORMAL and HARD than intended.
  Checked in the emulator: in a stage 6 play on NORMAL and on HARD
  (`difficulty` 2 and 4), every type `$56` soldier walking on the floor had
  an x velocity of exactly `$0002.0000` or `$FFFE.0000`, never 2.5 or 3.

### The grenade blast offset is computed and thrown away

When a soldier's grenade (type `$13`, `update_grenade`) hits a player or a
wall, it turns into `OBJT_GRENADE_BLAST` and computes a new position just
before `start_grenade_blast`:

```
	lda	$0A,x		; x
	clc
	adc	#$0008
	lda	$0A,x		; the sum is lost: x again
	lda	$0E,x		; y
	sec
	sbc	#$0010
	lda	$0E,x		; the difference is lost: y again
```

- **Meant:** probably to move the blast 8 pixels right and 16 pixels up.
  The second `lda` of each pair is probably a `sta` that became an `lda`
  (the two opcodes differ by one bit, `$B5` / `$95`).
- **Does:** nothing; the results are never stored and A is overwritten
  by the next load.
- **Effect:** the blast appears where the grenade is. This follows from
  the code; it was not checked in the emulator, and there is no way to see
  in the game where the blast "should" have been.

## Developer leftovers

Code and data that nothing in the game reaches. 73 routines in `src/` have
the note "no caller found", and 75 labels start with `unused_`
(`unused_apply_hit_flash`, `unused_typewriter_step`, ...); the source
comments describe each of them. The most interesting ones:

**Debug keys.** `debug_player_keys` (side view: with Select held, Up
changes the difficulty, A, B and X kill the player or set lives, bombs and
barrier) and `td_debug_cheat_buttons` (top-down: with X held, weapons,
bombs, barrier and lives) have no caller. The `debug_keys` cheat option
calls them; see [Cheats](cheats.md#leftovers-of-the-developers).
`debug_color_math_keys` (pad 2 changes colour math, `debug_coldata`) and
`debug_window_keys` (Select on pad 1 toggles a window test,
`debug_window_test`, `debug_window_hdma_a`) are similar PPU test routines
(see [RAM map](ram-map.md)).

**Button codes on the title.** `check_button_code_unused` (only plays a
sound), `check_30_lives_code` (30 lives) and `check_stage_select_code` (the
stage select) are never called. The `button_codes` cheat option calls
them; see [Game flow](game-flow.md#the-opening-and-the-title) and
[Cheats](cheats.md#leftovers-of-the-developers).

**The hidden 30 lives option.** `lives_options` has a fourth entry, 30,
that `options_change_lives` never reaches (it cycles through three);
`options_draw_lives` already knows how to draw it
([Cheats](cheats.md)).

**Stage select.** `GAME_MODE_STAGE_SELECT` works ("STAGE SELECT / STAGE
n") but is only entered when `stage_select_enabled` is set, which only the
uncalled button code does ([Game flow](game-flow.md)).

**Sound check.** `GAME_MODE_SOUND_CHECK` (`run_sound_check`, "SOUND CHECK
MODE") is a working sound test that nothing enters. The title menu still
has the way in: `title_menu_unused_sound_check` fades the title out and
returns mode result 3, which `game_mode_title` turns into the sound check,
but nothing jumps to it.

**An empty game mode.** `GAME_MODE_UNUSED_1` (`game_mode_unused_1`) only
returns and is never entered ([Game flow](game-flow.md)).

**Demo recording.** `demo_record_mode` (0 at power-on, never set) makes the
attract demo record both pads to SRAM (`demo_record_p1`, `demo_record_p2`)
instead of playing them back: probably the tool the demos were made with
([Game flow](game-flow.md#the-attract-demo)).

**A second loop?** After stage 6 on EASY or NORMAL, `game_mode_stage_play`
restarts the game at stage 1 one difficulty level higher, with that
level's continues; only HARD goes on to the final score. That code never
ran in the traces, and an emulator play of the NORMAL ending stayed in the
stage mode until it ran out, so it is not known yet whether a normal game
ever gets there or whether it is an abandoned feature
([Game flow](game-flow.md)).

**SPC streaming.** `unused_spc_stream_list` ... `unused_check_spc_busy` are
a second protocol for streaming data to the sound CPU, never used
([Sound driver interface](sound.md#unused-streaming-code)).

**Objects nobody spawns.** Object types `$19`, `$57` and `$60` never ran in
the traces (`$60` is only an `rtl`), type `$28`'s handler is really a
helper, the song change trigger `$4D` never ran
([Enemies and objects](enemies-early.md)); the top-down
`TDT_CENTIPEDE_UNUSED` is a centipede that is never spawned
([Top-down stages](topdown.md)); shot type 1 shares the default shot's
handler but nothing fires it, and the frames of shot type `$08`
(`shot_type_08_attrs`) are never read.

**Small leftovers in the player code.** `player_state_spin_jump_unused` is
a copy of the spin jump firing that nothing calls;
`unused_mosaic_flicker_on_y` flickers the mosaic while Y is held (a test,
probably); `unused_ceiling_result_01B07F` and its eight siblings are
outcomes of `check_ceiling_at_offset`'s decision tree that no branch
reaches; `unused_check_walls_above` and `unused_check_floor_at_feet` are
collision checks with no caller.

**A tiny mystery.** `sub_04C3A2` stores 0 into the HP of slot `$0500`
(the slot of the snake robot's head, `update_snake_robot_head`) and
returns; nothing calls it ([Enemies and bosses](enemies-late.md)).

**Unused utility code.** RAM and VRAM clear routines named by the range
they clear (`clear_ram_1b00_1bff`, `clear_wram_7e8000_and_7ec000`,
`clear_vram_5800_5bff_2` ...), `multiply_16x16`,
`unused_calc_mode7_matrix`, `unused_build_mode7_tilemap`, the typewriter
text routines (`unused_start_typewriter_text`), the
`unused_check_start_skip` pause/exit check, `stop_demo_and_reset_display`
and other routines of the engine that nothing calls.

**Data never read.**

- Code bytes left inside a data list in bank `$05` (a `jsl
  reset_video_state` / `ldx` / `jsl load_data_list` sequence after a
  palette list's end).
- Three load lists of one sound stream each (`unused_load_list_05D0C3`,
  `unused_load_list_05D0CC`, `unused_load_list_05D0D5`), and the
  `unused_dma_list_*` / `unused_vram_dma_*` records (32 of them) at the
  start of bank `$05`.
- Every HDMA preset of `ptrs_hdma_presets` but preset 1.
- The fourth word of `object_type_56_hp`, entry 0 of
  `ptrs_palette_anim_first`, the second half of
  `stage2_boss_pod_offsets_x`.
- RAM that is written but never read by name: `zp_38`, `wram_167C`, `wram_167E`,
  `wram_169E`, `wram_16A0`, `wram_1EB0`, `wram_1EB2`, `wram_1EBC` (see
  `src/ram.inc`).

## Overlapping and shared data

Many tables in bank `$05` share bytes with their neighbours, or are read
beyond their label. The source marks the second kind with a `LAYOUT:`
comment (155 of them; `grep -rn "LAYOUT:" src`), and
[Shiftability](shiftability.md#known-fixed-references) explains why they
matter for anyone who moves data. By kind:

**Bytes that mean two different things.**

- `weapon_capsule_kind_sprites` starts with the jump word of the animation
  script before it. Its value `$B172` points both to that script's target
  (`anim_05B172`, bank `$05`) and, read as a metasprite, to
  `metasprite_06B172` (bank `$06`), which the CDL shows being drawn. Its last entry is also the first word of
  `weapon_capsule_kind_states`.
- `data_059F0C` is read on from `song_change_trigger_sets` by the stage 1
  bomber (`object_type_06_state_04`): the same words give the song set of a
  song change trigger and the drift direction of the bomber's two bombs
  (`update_bomber_bomb`).
- The last frame of the animation `anim_05CD0B` is also entry 0 of
  `ptrs_palette_anim_first` (`update_palette_anim`), and entry 0 of
  `ptrs_palette_anim_second` is the first table's last entry.
- HP tables inside other data: `alien_dog_hp` is the sprite words of an
  `anim_end` (so the dog has 0 HP, one hit, on EASY); `td_runner_hp` is
  also the last frame of the runner's animation (`td_animate_enemy`);
  `heart_boss_hp` reads its HARD entry from the next table;
  `stage1_boss_shell_hp` and `lightning_pylon_hp` are read by other code
  too ([Cheats](cheats.md) explains how the HP cheat copes).
- `ptrs_hdma_presets` entry 0 is never a pointer: its word, `$0008`, is the
  fourth pad bit of `soft_reset_pad_bits` (`read_joypads` reads on into
  it).
- `type_scores` is read as `tbl_object_types+2,y` past the end of the
  handler table.

**Tables indexed from 1, whose entry 0 is the previous table's end.**
`ptrs_stage_card_texts` (entry 0 is the end of the string before it);
`ptrs_0588E1`, whose entry 0 is the "S" and the end byte of
`text_stage_clear_bonus`, and whose entry 6 is entry 0 of `ptrs_0588ED`;
`ptrs_td_tile_lists`, whose entry 0 is entry `$11` of
`ptrs_td_metasprite_sets`.

**Sliding windows.** The menu attribute tables (`title_menu_attrs_1p` ...
`title_menu_attrs_option`, `continue_menu_attrs`,
`continue_player_menu_attrs_2p_b` ...) are one run of words with a single
`$2400` (highlighted) among `$2000`s; each entry's table starts one word
further on, so reading any of them at the cursor's index gives `$2400`
exactly for the entry under the cursor (5 `LAYOUT:` comments;
[Game flow](game-flow.md#the-opening-and-the-title)). The HUD templates
(`hud_p1_top_template` ... `hud_p2_bottom_template`) are read at `+2` to
`+$21` by `init_hud`, whose index counts from `$20` down to 2, so each
label is two bytes before its row.

**A quarter turn later.** Sine and cosine tables that are one table:
`circle15_y` runs into `circle15_x`, `sine_table` into `cosine_table`,
`td_walk_y_int` / `td_walk_y_frac` into their x tables, and
`stage2_boss_pod_offsets_y` into `stage2_boss_pod_offsets_x`: the x value
is the y table read a quarter turn further on.

**Records that run into the next one.** `draw_td_item_metasprite` reads a
fifth byte after the last sprite of a top-down item metasprite, which is
the next metasprite's count (20 comments); `copy_hdma_table` copies HDMA
tables with a fixed length, past the end of the shorter ones (9);
`build_split_line_table` searches on past the end of a split line table
into the next (8); three side-view metasprites share their tail sprites
with the one before; five palettes in bank `$08` have labels inside them
that a palette task copies alone; some VRAM block lists start on an entry
inside the list before, which `queue_vram_blocks` also reaches by reading
on.

**Read past the end, into something else.** The last top-down centipede
frame (`td_tiles_07A3EA`) DMAs `$100` bytes from `td_sprite_tiles_14 +
$1F80`, so half of them come from the compressed graphics after it
(`gfx_14DC62`): those 128 bytes of sprite graphics are compressed data.

**Labels in the middle of a table.** Most of the remaining comments are tables the code indexes beyond their label because the CDL split
one table into blocks: `brain_boss_attack_4_slots` (two words, `$0400` and
`$0540`, whose second word straddles a block), the enemy bullet speeds
(`enemy_bullet_speeds_hard` read on into its `_y_sub` and `_x_sub` parts),
the stage 1 boss debris, the ending crowd, the top-down block animations.
These are not real overlaps, only a label boundary the data does not have.

## Other oddities

**The homing missile's table is not a bug.** `update_homing_missile` reads
its acceleration at `difficulty * 2 + field $3A` (0 when it flies
horizontally, 2 vertically), x from `homing_missile_accel_x` and y from
the next word. It looks as if difficulty and direction collide, but the
words alternate `$1400` and the steering of each difficulty (`$0440`,
`$0580`, `$0780`): flying horizontally, the missile gets `$1400` on x and
the difficulty's value on y; flying vertically, the same index plus 2 gives
the swapped pair. The main axis always accelerates by `$1400` and the
other one steers harder on higher levels. A compact table, not a mistake.

**The cartridge title is one byte too long.** "CONTRA3 THE ALIEN WARS" is
22 characters in a 21-byte field, so the final `S` sits in the map mode
byte at `$FFD5`, and tools that read the header to guess the ROM type get
`$53`. The code of `vector_length` also ends inside the area where an
extended header would be ([The cartridge](cartridge.md)).

**Empty top-down stream slots copy the direct page.**
`stream_topdown_sprite_gfx` DMAs every entry of the sprite graphics list
`td_gfx_stream` every frame without checking whether an enemy filled it.
The boss maps clear the list when they start (`init_stage2_boss_vars`,
`init_stage5_boss_vars`), and an entry nobody has filled since then has
source `$00:0000`: the game copies its own direct page into VRAM,
probably into a part that no sprite on screen uses at the time. The
Mode 7 block patches avoid the check the other way:
`reset_m7_block_patches` points unused slots at VRAM `$6000`, past the map,
so `upload_m7_block_patches` can write all four.

**Animation frames that are not metasprites.** The third word of an
animation frame is the mirrored metasprite, but objects that never face
the other way keep something else there: effects an OAM attribute
(`update_effect`, `update_destructible_part`), the bomber's bomb the script
of its fire trail ([Shiftability](shiftability.md)).

**A read through the next bank.** `td_update_bomb` gets the thrower's
position with `lda a:.loword($000A - $0080),x`, an operand of `$FF8A`.
With X the bomb's slot (`$0F40` or `$0F80`), the address runs past the end
of the data bank (`$05`) into bank `$06`, whose `$0000-$1FFF` is the same
low RAM, and lands on the player's slot `$80` bytes below the bomb.

**Unkillable on HARD.** The HARD entries of `lightning_pylon_hp` and
`stage1_boss_shell_hp` are `$7FFF`, so in practice the pylons and the
stage 1 boss's shell cannot be shot down on HARD. The brain boss's HP is
1025 on EASY but 16982 on NORMAL and 29986 on HARD, a jump nobody has
explained yet ([Enemies and bosses](enemies-late.md#hp-and-difficulty)).

**Dead loads.** A few instructions load a register that the next
instruction overwrites; they change nothing:
`update_stage4_boss_pod` does `ldy $30,x` just before `txy`, and
`ending_crowd_walker_a_state_01`, `ending_crowd_walker_b_state_01` and
`ending_crowd_walker_b_state_03` load `OBJ_FACING` and then the animation
pointer into A (probably a choice of animation by facing that was dropped).
