; gfx/gfx_13.asm -- Compressed graphics (bank $13)
; Bank $13, $13:8000-$13:FFFF. Included by main.asm in segment BANK13.
;
; Compressed graphics (decompress_chunk) and tile data DMA'd to VRAM by the top-down
; streaming code (stream_topdown_sprite_gfx).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by decompress_chunk
packed_138000:
	; Compressed data for WRAM $7F:C000, $13:8000-$13:9566 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_138000.lz"
packed_139567:
	; Compressed data for WRAM $7F:E000, $13:9567-$13:AC01 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_139567.lz"
	; CDL: DMA (started in stream_topdown_sprite_gfx)
; Raw sprite tiles (4bpp) of the top-down objects, DMA'd to VRAM by
; stream_topdown_sprite_gfx: the td_tiles records of bank $07 give
; addresses in this block (as offsets from its label).
td_sprite_tiles_13:
	.incbin	"gfx/td_sprite_tiles_13.bin"
	; CDL: not accessed
; $1600 bytes of zeros up to gfx_13CC02: the td_tiles records read only the
; tiles above (td_tiles_079112, the last, up to +$A00), no label or pointer
; points here and the CDL never saw them read: unused.
	.res	$1600, $00
	; CDL: read by decompress_chunk
gfx_13CC02:
	; ASSET: compressed graphics (VRAM), $13:CC02-$13:E41F (from its length word), loaded by load_list_05CF2A
	.incbin	"gfx/gfx_13CC02.lz"
stage2_m7_blocks:
	; Compressed data for WRAM $7E:8000, $13:E420-$13:ED39 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: Mode 7 block definitions, $20 bytes per 4x4-tile block (tile numbers in the even bytes; expand_m7_block, queue_m7_block_patch).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_m7_blocks.lz"
stage2_block_map_0:
	; Compressed data for WRAM $7E:9000, $13:ED3A-$13:EE4D (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: block map, rows 0-7 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_block_map_0.lz"
stage2_block_map_1:
	; Compressed data for WRAM $7E:9400, $13:EE4E-$13:EF61 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: block map, rows 8-15 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_block_map_1.lz"
stage2_block_map_2:
	; Compressed data for WRAM $7E:9800, $13:EF62-$13:F075 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: block map, rows 16-23 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_block_map_2.lz"
stage2_block_map_3:
	; Compressed data for WRAM $7E:9C00, $13:F076-$13:F189 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: block map, rows 24-31 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_block_map_3.lz"
stage2_boss_m7_blocks:
	; Compressed data for WRAM $7E:8000, $13:F18A-$13:F4A4 (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: Mode 7 block definitions, $20 bytes per 4x4-tile block (tile numbers in the even bytes; expand_m7_block, queue_m7_block_patch).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_boss_m7_blocks.lz"
stage2_boss_block_map_0:
	; Compressed data for WRAM $7E:9000, $13:F4A5-$13:F4EE (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: block map, rows 0-7 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_boss_block_map_0.lz"
stage2_boss_block_map_1:
	; Compressed data for WRAM $7E:9400, $13:F4EF-$13:F544 (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: block map, rows 8-15 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_boss_block_map_1.lz"
stage2_boss_block_map_2:
	; Compressed data for WRAM $7E:9800, $13:F545-$13:F568 (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: block map, rows 16-23 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_boss_block_map_2.lz"
stage2_boss_block_map_3:
	; Compressed data for WRAM $7E:9C00, $13:F569-$13:F58C (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: block map, rows 24-31 (32 blocks a row in 4 runs of 8 words $80 apart, block number in the low byte; build_m7_tilemap).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage2_boss_block_map_3.lz"
	; CDL: not accessed
	.byte	$52, $00, $9F, $03, $00, $0C, $03, $13, $0F, $2D, $1D, $5B, $33, $74, $11, $A9
	.byte	$7B, $D9, $32, $C0, $00, $B0, $40, $28, $90, $D4, $78, $0A, $5C, $B2, $BC, $6D
	.byte	$AE, $4B, $8F, $5C, $B4, $55, $A9, $6B, $54, $38, $6E, $1F, $24, $1A, $19, $0F
	.byte	$0E, $01, $03, $DF, $8D, $B5, $F6, $49, $3E, $96, $D8, $EA, $6C, $D4, $B8, $68
	.byte	$50, $30, $C0, $C0, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $F2, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
