; gfx/gfx_10.asm -- Compressed graphics (bank $10)
; Bank $10, $10:8000-$10:FFFF. Included by main.asm in segment BANK10.
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
gfx_108000:
	; ASSET: compressed graphics (VRAM), $10:8000-$10:9C16 (from its length word), loaded by load_list_058C97
	.incbin	"gfx/gfx_108000.lz"
gfx_109C17:
	; ASSET: compressed graphics (VRAM), $10:9C17-$10:B926 (from its length word), loaded by load_list_058C97
	.incbin	"gfx/gfx_109C17.lz"
gfx_10B927:
	; ASSET: compressed graphics (VRAM), $10:B927-$10:D5A1 (from its length word), loaded by load_list_058C97, load_list_059EC9
	.incbin	"gfx/gfx_10B927.lz"
gfx_10D5A2:
	; ASSET: compressed graphics (VRAM), $10:D5A2-$10:F1FD (from its length word), loaded by load_list_058C97
	.incbin	"gfx/gfx_10D5A2.lz"
stage6_bg1_map:
	; Compressed data for WRAM $7E:9000, $10:F1FE-$10:F730 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG1 map, one word per metatile (byte offset of the metatile, bits 14-15 flip), 8x8 metatiles per $80-byte page.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage6_bg1_map.lz"
stage6_bg2_map:
	; Compressed data for WRAM $7E:F000, $10:F731-$10:F8C0 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG2 map (as BG1).
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage6_bg2_map.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
