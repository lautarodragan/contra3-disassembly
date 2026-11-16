; gfx/gfx_11.asm -- Compressed graphics (bank $11)
; Bank $11, $11:8000-$11:FFFF. Included by main.asm in segment BANK11.
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
gfx_118000:
	; ASSET: compressed graphics (VRAM), $11:8000-$11:9D0D (from its length word), loaded by load_list_059EC9
	.incbin	"gfx/gfx_118000.lz"
gfx_119D0E:
	; ASSET: compressed graphics (VRAM), $11:9D0E-$11:B7AE (from its length word), loaded by load_list_059EC9, load_list_05FF30
	.incbin	"gfx/gfx_119D0E.lz"
stage6_bg_anim_tiles:
	; Compressed data for WRAM $7E:A000, $11:B7AF-$11:C385 (from its length word), loaded by load_list_058C6F.
	; Stage 6: 3 frames of $400 bytes of 4bpp BG tiles, DMAd to VRAM $3A90 by update_stage6_bg_tile_animator.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/stage6_bg_anim_tiles.lz"
gfx_11C386:
	; ASSET: compressed graphics (VRAM), $11:C386-$11:CDE9 (from its length word), loaded by load_list_059E95
	.incbin	"gfx/gfx_11C386.lz"
packed_11CDEA:
	; Compressed data for WRAM $7F:C000, $11:CDEA-$11:DF74 (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_11CDEA.lz"
packed_11DF75:
	; Compressed data for WRAM $7F:E000, $11:DF75-$11:EB27 (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_11DF75.lz"
gfx_11EB28:
	; ASSET: compressed graphics (VRAM), $11:EB28-$11:F1F2 (from its length word), loaded by load_list_058530
	.incbin	"gfx/gfx_11EB28.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
