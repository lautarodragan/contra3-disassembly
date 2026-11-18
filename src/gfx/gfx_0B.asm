; gfx/gfx_0B.asm -- Compressed graphics (bank $0B)
; Bank $0B, $0B:8000-$0B:FFFF. Included by main.asm in segment BANK0B.
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
packed_0B8000:
	; Compressed data for WRAM $7F:0000, $0B:8000-$0B:935B (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0B8000.lz"
packed_0B935C:
	; Compressed data for WRAM $7F:2000, $0B:935C-$0B:AA9B (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0B935C.lz"
packed_0BAA9C:
	; Compressed data for WRAM $7F:4000, $0B:AA9C-$0B:BCFC (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0BAA9C.lz"
packed_0BBCFD:
	; Compressed data for WRAM $7F:6000, $0B:BCFD-$0B:C6A0 (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0BBCFD.lz"
packed_0BC6A1:
	; Compressed data for WRAM $7F:8000, $0B:C6A1-$0B:D88B (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0BC6A1.lz"
packed_0BD88C:
	; Compressed data for WRAM $7F:A000, $0B:D88C-$0B:E86D (from its length word), loaded by load_list_0585D1, load_list_058687, load_list_058A93.
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/packed_0BD88C.lz"
gfx_0BE86E:
	; ASSET: compressed graphics (VRAM), $0B:E86E-$0B:FE1D (from its length word), loaded by load_list_05FEDF
	.incbin	"gfx/gfx_0BE86E.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
