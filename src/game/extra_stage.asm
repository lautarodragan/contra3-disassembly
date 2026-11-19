; game/extra_stage.asm -- The extra stage's code and data outside bank $05
; Bank $04, assembled only in the extra-stage build (CHEAT_EXTRA_STAGE;
; game/stages.inc). Included by main.asm in segment BANK04.
;
; The extra stage (stage 2 of that build, "Collapsed Tower"; book: Stage 2:
; Collapsed Tower) runs on stage 1's engine set-up: its tables in bank $05
; (data/tables_05.asm) point to stage 1's graphics, palettes and BG2 map,
; and to its own BG1 map (extra_bg1_map, below) and spawn lists
; (assets/stages/extra.spawns).

.if CHEAT_EXTRA_STAGE

; tbl_stage_layout_inits[LAYOUT_EXTRA] and its checkpoint version, through
; layout_init_extra in bank $00: as layout_init_stage1 (the start: the BG2
; tank's HDMA, BG2 at 1/8 of BG1 with it) and layout_init_stage1_checkpoint
; (past the mid-boss: BG2 at 1/8 without the HDMA, mode 5), but the song is
; stage 5's (stage_songs loads its song set, which brings its samples).
layout_init_extra_far:
	lda	a:stage_layout
	cmp	#LAYOUT_EXTRA + LAYOUT_CHECKPOINT
	beq	@checkpoint
	jsl	f:init_tank_hdma_table
	lda	#$0003
	sta	hdma_preset
	lda	#$0004
	sta	a:bg2_scroll_mode
	bra	@common
@checkpoint:
	lda	#$0005
	sta	a:bg2_scroll_mode
@common:
	lda	#$00C1
	sta	a:m7sel_shadow
	stz	a:clamp_player_top
	lda	#SOUND_SONG_STAGE5
	jml	f:queue_sound

; The extra stage's BG1 map (assets/wram/extra_bg1_map.map), decompressed
; to $7E:9000 by load_list_extra_maps; its metatiles are stage 1's
; (stage1_bg1_metatiles at $7E:5000, stage1_bg1_metatiles_2 from metatile
; $100 at $7E:7000) and its own from $1A8 (extra_bg1_metatiles, below).
extra_bg1_map:
	; Extra stage: BG1 map, one word per metatile (byte offset of the metatile, bits 14-15 flip), 8x8 metatiles per $80-byte page.
	; (Not in the default ROM, so not one of the blocks tools/test_compressor.py checks.)
	.incbin	"wram/extra_bg1_map.lz"

; The extra stage's own metatiles (assets/wram/extra_bg1_metatiles.metatiles),
; decompressed to $7E:8500 by load_list_extra_maps, right after the 168 of
; stage1_bg1_metatiles_2 ($100-$1A7): metatiles $1A8 on, up to the map at
; $7E:9000 (88). They are built from stage 1's characters, for the climb
; (book: Stage 2: Collapsed Tower).
extra_bg1_metatiles:
	.incbin	"wram/extra_bg1_metatiles.lz"

.endif
