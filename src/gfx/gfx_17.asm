; gfx/gfx_17.asm -- Compressed graphics (bank $17)
; Bank $17, $17:8000-$17:FFFF. Included by main.asm in segment BANK17.
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
stage2_sprite_tiles_1:
	; Compressed data for WRAM $7E:A000, $17:8000-$17:98AC (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: 4bpp sprite tiles, DMAd to VRAM $4000 by stream_topdown_sprite_gfx (td_tiles records in $7E).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage2_sprite_tiles_1.lz"
stage2_sprite_tiles_2:
	; Compressed data for WRAM $7E:C000, $17:98AD-$17:AFD9 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: 4bpp sprite tiles, DMAd to VRAM $4000 by stream_topdown_sprite_gfx (td_tiles records in $7E).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage2_sprite_tiles_2.lz"
stage2_sprite_tiles_3:
	; Compressed data for WRAM $7E:E000, $17:AFDA-$17:B952 (from its length word), loaded by load_list_058623, load_list_05CF7E.
	; Stage 2: 4bpp sprite tiles, DMAd to VRAM $4000 by stream_topdown_sprite_gfx (td_tiles records in $7E).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage2_sprite_tiles_3.lz"
gfx_17B953:
	; ASSET: compressed graphics (VRAM), $17:B953-$17:CE4C (from its length word), loaded by load_list_05A7DB
	.incbin	"gfx/gfx_17B953.lz"
gfx_17CE4D:
	; ASSET: compressed graphics (VRAM), $17:CE4D-$17:D20D (from its length word), loaded by load_list_05A7DB
	.incbin	"gfx/gfx_17CE4D.lz"
gfx_17D20E:
	; ASSET: compressed graphics (VRAM), $17:D20E-$17:E598 (from its length word), loaded by load_list_05FDD8
	.incbin	"gfx/gfx_17D20E.lz"
gfx_17E599:
	; ASSET: compressed graphics (VRAM), $17:E599-$17:F3F7 (from its length word), loaded by load_list_05FDC6
	.incbin	"gfx/gfx_17E599.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
