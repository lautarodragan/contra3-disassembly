; gfx/gfx_0A.asm -- Compressed graphics (bank $0A)
; Bank $0A, $0A:8000-$0A:FFFF. Included by main.asm in segment BANK0A.
;
; Graphics compressed for the decompressor (decompress_chunk, see
; engine/decompress.asm).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by decompress_chunk
gfx_0A8000:
	; ASSET: compressed graphics (VRAM), $0A:8000-$0A:9BC5 (from its length word), loaded by load_list_059E79
	.incbin	"gfx/gfx_0A8000.lz"
stage1_bomber_fire_tiles:
	; Compressed data for WRAM $7E:A000, $0A:9BC6-$0A:A37B (from its length word), loaded by load_list_059FBA.
	; Stage 1 bomber raid: 4 frames of $380 bytes of 4bpp BG tiles (the fire), DMAd to VRAM $2E40 by bomber_raid_animate_fire (bomber_raid_fire_tile_frames).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage1_bomber_fire_tiles.lz"
gfx_0AA37C:
	; ASSET: compressed graphics (VRAM), $0A:A37C-$0A:B063 (from its length word), loaded by load_list_059E8C
	.incbin	"gfx/gfx_0AA37C.lz"
stage1_bg1_metatiles:
	; Compressed data for WRAM $7E:5000, $0A:B064-$0A:C13A (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; Stage 1: BG1 metatiles from number 0 (4x4 tilemap words each, $20 bytes; draw_bg_column / draw_bg_row, map base $4000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage1_bg1_metatiles.lz"
stage1_bg2_metatiles:
	; Compressed data for WRAM $7E:B000, $0A:C13B-$0A:CDBB (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; Stage 1: BG2 metatiles (as BG1, map base $A000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage1_bg2_metatiles.lz"
stage1_bg1_metatiles_2:
	; Compressed data for WRAM $7E:7000, $0A:CDBC-$0A:D870 (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; Stage 1: BG1 metatiles $100 and up (they continue stage1_bg1_metatiles at $7E:7000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage1_bg1_metatiles_2.lz"
stage1_bg1_map:
	; Compressed data for WRAM $7E:9000, $0A:D871-$0A:DE6C (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; Stage 1: BG1 map, one word per metatile (byte offset of the metatile, bits 14-15 flip), 8x8 metatiles per $80-byte page.
	; No pointers: it decompresses to metatile offsets from the metatile base in WRAM (draw_bg_column / draw_bg_row).
	.incbin	"wram/stage1_bg1_map.lz"
stage1_bg2_map:
	; Compressed data for WRAM $7E:F000, $0A:DE6D-$0A:E032 (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; Stage 1: BG2 map (as BG1).
	; No pointers: it decompresses to metatile offsets from the metatile base in WRAM (draw_bg_column / draw_bg_row).
	.incbin	"wram/stage1_bg2_map.lz"
gfx_0AE033:
	; ASSET: compressed graphics (VRAM), $0A:E033-$0A:E4A1 (from its length word), loaded by load_list_05EB45
	.incbin	"gfx/gfx_0AE033.lz"
gfx_0AE4A2:
	; ASSET: compressed graphics (VRAM), $0A:E4A2-$0A:FD7A (from its length word), loaded by load_list_05F286
	.incbin	"gfx/gfx_0AE4A2.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
