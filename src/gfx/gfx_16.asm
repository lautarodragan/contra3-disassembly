; gfx/gfx_16.asm -- Compressed graphics (bank $16)
; Bank $16, $16:8000-$16:FFFF. Included by main.asm in segment BANK16.
;
; Compressed graphics (decompress_chunk), data DMA'd by the top-down streaming code
; (stream_topdown_sprite_gfx) and data read by the attract demo code (demo_read_p1_event).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by decompress_chunk
gfx_168000:
	; ASSET: compressed graphics (VRAM), $16:8000-$16:A8FD (from its length word), loaded by load_list_05D073
	.incbin	"gfx/gfx_168000.lz"
stage5_boss_m7_blocks:
	; Compressed data for WRAM $7E:8000, $16:A8FE-$16:AE8A (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: Mode 7 block definitions, $20 bytes per 4x4-tile block (tile numbers in the even bytes; expand_m7_block, queue_m7_block_patch; the odd bytes are unused).
	; No pointers: it decompresses to Mode 7 tile numbers in the even bytes (expand_m7_block) and BG-tilemap-like high bytes the game does not use (book: Assets, Level maps).
	.incbin	"wram/stage5_boss_m7_blocks.lz"
stage5_boss_block_map_0:
	; Compressed data for WRAM $7E:9000, $16:AE8B-$16:AEF5 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: block map, rows 0-7 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; No pointers: it decompresses to block numbers (build_m7_tilemap).
	.incbin	"wram/stage5_boss_block_map_0.lz"
stage5_boss_block_map_1:
	; Compressed data for WRAM $7E:9400, $16:AEF6-$16:B003 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: block map, rows 8-15 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; No pointers: it decompresses to block numbers (build_m7_tilemap).
	.incbin	"wram/stage5_boss_block_map_1.lz"
stage5_boss_block_map_2:
	; Compressed data for WRAM $7E:9800, $16:B004-$16:B114 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: block map, rows 16-23 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; No pointers: it decompresses to block numbers (build_m7_tilemap).
	.incbin	"wram/stage5_boss_block_map_2.lz"
stage5_boss_block_map_3:
	; Compressed data for WRAM $7E:9C00, $16:B115-$16:B173 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: block map, rows 24-31 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; No pointers: it decompresses to block numbers (build_m7_tilemap).
	.incbin	"wram/stage5_boss_block_map_3.lz"
stage5_boss_m7_chars:
	; Compressed data for WRAM $7E:C000, $16:B174-$16:B622 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: Mode 7 characters of the boss, 4 frames of $280 bytes (stage5_boss_chr_sources), DMAd to VRAM $3200 (high bytes) by stream_topdown_sprite_gfx.
	; No pointers: it decompresses to Mode 7 characters, which the game only copies to VRAM.
	.incbin	"wram/stage5_boss_m7_chars.lz"
stage5_boss_sprite_tiles:
	; Compressed data for WRAM $7E:A000, $16:B623-$16:BE10 (from its length word), loaded by load_list_05D07C.
	; Stage 5 boss map: 4bpp sprite tiles, DMAd to VRAM $4000 by stream_topdown_sprite_gfx (td_tiles records in $7E).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage5_boss_sprite_tiles.lz"
	; CDL: not accessed
; Four 4bpp tiles (a 16x16 sprite, tiles 0 1 / 2 3: a round, shaded
; ball) that nothing reads: no label, pointer or td_tiles record refers to
; them, the CDL never read them, and no other block of the ROM holds these
; tiles, except their bitplanes 0-1 in unused_gfx_13F58D (book: What the
; traces never touched).
unused_tiles_16BE11:
	.incbin	"gfx/unused_tiles_16BE11.bin"
	; CDL: read by decompress_chunk
gfx_16BE91:
	; ASSET: compressed graphics (VRAM), $16:BE91-$16:C751 (from its length word), loaded by load_list_05CF33
	.incbin	"gfx/gfx_16BE91.lz"
	; CDL: DMA (started in stream_topdown_sprite_gfx)
; Raw sprite tiles (4bpp) of the top-down objects, DMA'd to VRAM by
; stream_topdown_sprite_gfx: the td_tiles records of bank $07 give
; addresses in this block (as offsets from its label).
td_sprite_tiles_16:
	; from +$1600: CDL: not accessed
	.incbin	"gfx/td_sprite_tiles_16.bin"
	; CDL: read by decompress_chunk
stage6_bg2_metatiles:
	; Compressed data for WRAM $7E:B000, $16:DF52-$16:F4C4 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG2 metatiles (as BG1, map base $A000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage6_bg2_metatiles.lz"
	; CDL: read by demo_read_p1_event
demo_input_p1_0:
	.byte	$00, $00, $43, $00, $00, $01, $15, $00, $00, $41, $0B, $00, $00, $49, $1C, $00
	.byte	$00, $48, $19, $00, $00, $49, $16, $00, $00, $48, $06, $00, $00, $49, $6B, $00
	.byte	$00, $C9, $10, $00, $00, $49, $08, $00, $00, $48, $01, $00, $00, $40, $4D, $00
	.byte	$00, $C1, $1C, $00, $00, $41, $0E, $00, $00, $40, $54, $02, $00, $48, $2D, $00
	.byte	$00, $40, $03, $00, $00, $00, $1B, $00, $00, $01, $0C, $00, $00, $00, $5E, $00
	.byte	$00, $01, $03, $00, $00, $81, $08, $00, $00, $89, $0C, $00, $00, $81, $04, $00
	.byte	$00, $01, $02, $00, $00, $09, $03, $00, $00, $01, $0A, $00, $00, $09, $26, $00
	.byte	$00, $08, $12, $00, $00, $09, $27, $00, $00, $08, $01, $00, $00, $00, $2E, $00
	.byte	$00, $01, $01, $00, $00, $09, $03, $00, $00, $89, $0E, $00, $00, $09, $19, $00
	.byte	$00, $01, $15, $00, $00, $00, $50, $00, $00, $01, $15, $00, $80, $01, $01, $00
	.byte	$80, $00, $11, $00, $00, $00, $56, $00, $00, $01, $17, $00, $00, $00, $17, $00
	.byte	$00, $01, $80, $00, $00, $49, $11, $00, $00, $48, $52, $00, $00, $4A, $0A, $00
	.byte	$00, $48, $57, $00, $00, $C8, $22, $00
	; CDL: not accessed
	.byte	$00, $48, $80, $00, $00, $49, $0E, $00, $00, $48, $05, $00, $00, $40, $2D, $00
	.byte	$00, $C0, $0C, $00, $00, $CA, $0A, $00, $00, $4A, $19, $00, $00, $48, $08, $00
	.byte	$00, $40, $17, $00, $00, $C0, $24, $00, $00, $40, $19, $00, $00, $C0, $1E, $00
	.byte	$00, $48, $02, $00, $10, $48, $0D, $00, $00, $48, $01, $00, $00, $4A, $01, $00
	.byte	$00, $48, $02, $00, $10, $48, $0B, $00, $00, $4A, $01, $00, $00, $48, $07, $00
	.byte	$10, $48, $01, $00, $10, $40, $03, $00, $10, $41, $01, $00, $10, $40, $02, $00
	.byte	$00, $40, $06, $00, $00, $44, $04, $00, $00, $40, $02, $00, $00, $48, $01, $00
	.byte	$10, $48, $04, $00, $10, $40, $02, $00, $10, $48, $01, $00, $00, $48, $02, $00
	.byte	$00, $40, $01, $00, $00, $48, $0A, $00, $00, $40, $01, $00, $00, $41, $0B, $00
	.byte	$00, $40, $01, $00, $00, $48, $14, $00, $20, $48, $23, $00, $00, $48, $0D, $00
	.byte	$10, $48, $07, $00, $10, $49, $13, $00, $00, $48, $03, $00, $00, $49, $0D, $00
	.byte	$00, $41, $43, $00, $00, $44, $05, $00, $00, $40, $03, $00, $00, $41, $02, $00
	.byte	$00, $C0, $6D, $00, $00, $40, $06, $00, $00, $49, $06, $00, $00, $41, $06, $00
	.byte	$10, $41, $13, $00, $00, $41, $02, $00, $00, $40, $0E, $00, $00, $48, $0E, $00
	.byte	$00, $49, $06, $00, $00, $41, $03, $00, $10, $41, $08, $00, $10, $44, $13, $00
	.byte	$10, $40, $03, $00, $10, $4A, $09, $00, $10, $48, $10, $00, $00, $48, $01, $00
	.byte	$00, $4A, $12, $00, $00, $48, $08, $00, $10, $48, $06, $00, $10, $40, $04, $00
	.byte	$10, $48, $04, $00, $10, $40, $04, $00, $10, $44, $02, $00, $00, $44, $07, $00
	.byte	$00, $40, $01, $00, $00, $42, $08, $00, $00, $40, $04, $00, $00, $42, $05, $00
	.byte	$00, $48, $11, $00, $00, $40, $1B, $00
	; CDL: read by demo_read_p1_event
demo_input_p1_1:
	.byte	$00, $00, $4E, $00, $00, $40, $08, $00, $00, $00, $C9, $01, $20, $00, $11, $00
	.byte	$20, $40, $14, $00, $00, $40, $06, $00, $00, $41, $19, $00, $00, $45, $02, $00
	.byte	$10, $45, $02, $00, $10, $41, $03, $00, $00, $41, $10, $00, $00, $40, $01, $00
	.byte	$00, $48, $03, $00, $00, $4A, $06, $00, $00, $42, $09, $00, $00, $44, $08, $00
	.byte	$00, $46, $06, $00, $00, $42, $14, $00, $00, $4A, $02, $00, $00, $42, $06, $00
	.byte	$00, $4A, $08, $00, $00, $42, $06, $00, $00, $40, $09, $00, $00, $44, $06, $00
	.byte	$00, $40, $05, $00, $00, $48, $02, $00, $00, $49, $04, $00, $00, $41, $18, $00
	.byte	$00, $45, $0D, $00, $00, $41, $16, $00, $00, $49, $06, $00, $00, $41, $02, $00
	.byte	$20, $41, $09, $00, $20, $45, $02, $00, $00, $45, $1C, $00, $00, $41, $0D, $00
	.byte	$10, $45, $0A, $00, $10, $41, $02, $00, $00, $41, $22, $00, $00, $49, $0E, $00
	.byte	$00, $41, $12, $00, $00, $49, $08, $00, $00, $41, $03, $00, $20, $41, $04, $00
	.byte	$00, $41, $07, $00, $00, $45, $04, $00, $00, $41, $02, $00, $00, $40, $0E, $00
	.byte	$00, $49, $08, $00, $00, $41, $07, $00, $00, $45, $03, $00, $00, $41, $02, $00
	.byte	$00, $40, $0E, $00, $00, $00, $09, $00, $00, $08, $08, $00, $00, $00, $8D, $00
	.byte	$00, $09, $0C, $00, $00, $01, $08, $00, $10, $01, $11, $00, $00, $01, $04, $00
	.byte	$00, $05, $10, $00, $00, $01, $06, $00, $20, $01, $0E, $00, $20, $09, $09, $00
	.byte	$00, $09, $0A, $00, $00, $01, $05, $00, $10, $01, $0C, $00, $10, $09, $04, $00
	.byte	$00, $08, $01, $00, $00, $00, $01, $00, $00, $40, $15, $00, $20, $40, $0C, $00
	.byte	$20, $42, $06, $00, $00, $42, $02, $00, $00, $40, $03, $00, $00, $42, $04, $00
	.byte	$10, $42, $02, $00, $10, $48, $03, $00, $10, $40, $01, $00, $10, $48, $02, $00
	.byte	$10, $40, $0A, $00, $00, $40, $01, $00, $00, $4A, $02, $00, $00, $42, $04, $00
	.byte	$00, $CA, $02, $00, $00, $C0, $52, $00, $00, $40, $05, $00, $00, $41, $01, $00
	.byte	$00, $49, $01, $00, $00, $09, $05, $00, $00, $01, $04, $00, $20, $41, $0B, $00
	.byte	$00, $41, $02, $00, $00, $40, $06, $00, $10, $40, $06, $00, $00, $40, $08, $00
	.byte	$00, $C0, $7F, $00, $00, $40, $08, $00, $00, $00, $15, $00, $00, $01, $01, $00
	.byte	$20, $01, $0D, $00, $20, $00, $01, $00, $20, $40, $01, $00, $30, $40, $31, $00
	.byte	$00, $40, $01, $00, $00, $00, $04, $00, $00, $04, $08, $00, $00, $05, $1E, $00
	.byte	$00, $04, $02, $00, $20, $04, $03, $00, $20, $02, $05, $00, $20, $0A, $07, $00
	.byte	$20, $08, $03, $00, $20, $09, $01, $00, $00, $01, $03, $00, $00, $41, $0A, $00
	.byte	$00, $40, $11, $00, $00, $4A, $02, $00, $00, $48, $09, $00, $00, $49, $0A, $00
	.byte	$00, $41, $04, $00, $00, $45, $05, $00, $00, $44, $01, $00, $00, $45, $09, $00
	.byte	$00, $41, $07, $00, $00, $49, $03, $00, $00, $48, $05, $00, $00, $49, $03, $00
demo_input_p1_2:
	; LAYOUT: read on from the demo input before
	.byte	$00, $00, $FE, $00, $00, $40, $01, $01, $00, $42, $04, $00, $00, $02, $17, $00
	.byte	$00, $00, $04, $00, $00, $08, $01, $00, $00, $00, $02, $00, $00, $01, $06, $00
	.byte	$00, $00, $21, $00, $00, $08, $06, $00, $00, $48, $11, $00, $00, $C8, $16, $00
	.byte	$00, $C9, $0C, $00, $00, $C8, $1D, $00, $00, $48, $E9, $00, $00, $C8, $02, $00
	.byte	$00, $CA, $05, $00, $00, $C8, $0B, $00, $00, $C9, $19, $00, $00, $C8, $05, $00
	.byte	$00, $48, $4C, $00, $00, $CA, $03, $00, $00, $C8, $0F, $00, $00, $C9, $03, $00
	.byte	$00, $89, $01, $00, $00, $09, $02, $00, $00, $08, $5B, $00, $00, $0A, $13, $00
	.byte	$00, $08, $02, $00, $00, $0A, $1E, $00, $00, $8A, $0B, $00, $00, $08, $0C, $00
	.byte	$80, $08, $04, $00, $00, $08, $15, $00, $00, $88, $0E, $00, $00, $08, $05, $00
	.byte	$00, $0A, $01, $00, $00, $08, $0A, $00, $80, $08, $09, $00, $00, $08, $02, $00
	.byte	$00, $09, $08, $00, $00, $08, $0A, $00, $00, $48, $43, $00, $00, $C8, $21, $00
	.byte	$00, $48, $26, $00, $00, $49, $11, $00, $00, $48, $52, $00, $00, $4A, $0A, $00
	.byte	$00, $48, $57, $00, $00, $C8, $22, $00, $00, $48, $80, $00, $00, $49, $0E, $00
	.byte	$00, $48, $05, $00, $00, $40, $2D, $00, $00, $C0, $0C, $00, $00, $CA, $0A, $00
	.byte	$00, $4A, $19, $00, $00, $48, $08, $00, $00, $40, $17, $00, $00, $C0, $24, $00
	.byte	$00, $40, $19, $00, $00, $C0, $1E, $00, $00, $48, $02, $00, $10, $48, $0D, $00
	.byte	$00, $48, $01, $00, $00, $4A, $01, $00, $00, $48, $02, $00
	; CDL: not accessed
	.byte	$10, $48, $0B, $00, $00, $4A, $01, $00, $00, $48, $07, $00, $10, $48, $01, $00
	.byte	$10, $40, $03, $00, $10, $41, $01, $00, $10, $40, $02, $00, $00, $40, $06, $00
	.byte	$00, $44, $04, $00, $00, $40, $02, $00, $00, $48, $01, $00, $10, $48, $04, $00
	.byte	$10, $40, $02, $00, $10, $48, $01, $00, $00, $48, $02, $00, $00, $40, $01, $00
	.byte	$00, $48, $0A, $00, $00, $40, $01, $00, $00, $41, $0B, $00, $00, $40, $01, $00
	.byte	$00, $48, $14, $00, $20, $48, $23, $00, $00, $48, $0D, $00, $10, $48, $07, $00
	.byte	$10, $49, $13, $00, $00, $48, $03, $00, $00, $49, $0D, $00, $00, $41, $43, $00
	.byte	$00, $44, $05, $00, $00, $40, $03, $00, $00, $41, $02, $00, $00, $C0, $6D, $00
	.byte	$00, $40, $06, $00, $00, $49, $06, $00, $00, $41, $06, $00, $10, $41, $13, $00
	.byte	$00, $41, $02, $00, $00, $40, $0E, $00, $00, $48, $0E, $00, $00, $49, $06, $00
	.byte	$00, $41, $03, $00, $10, $41, $08, $00, $10, $44, $13, $00, $10, $40, $03, $00
	.byte	$10, $4A, $09, $00, $10, $48, $10, $00, $00, $48, $01, $00, $00, $4A, $12, $00
	.byte	$00, $48, $08, $00, $10, $48, $06, $00, $10, $40, $04, $00, $10, $48, $04, $00
	.byte	$10, $40, $04, $00, $10, $44, $02, $00, $00, $44, $07, $00, $00, $40, $01, $00
	.byte	$00, $42, $08, $00, $00, $40, $04, $00, $00, $42, $05, $00, $00, $48, $11, $00
	.byte	$00, $40, $1B, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
