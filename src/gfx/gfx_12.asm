; gfx/gfx_12.asm -- Compressed graphics (bank $12)
; Bank $12, $12:8000-$12:FFFF. Included by main.asm in segment BANK12.
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
packed_128000:
	; Compressed data for WRAM $7F:0000, $12:8000-$12:9416 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_128000.lz"
packed_129417:
	; Compressed data for WRAM $7F:2000, $12:9417-$12:A7E7 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_129417.lz"
packed_12A7E8:
	; Compressed data for WRAM $7F:4000, $12:A7E8-$12:BC15 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_12A7E8.lz"
packed_12BC16:
	; Compressed data for WRAM $7F:6000, $12:BC16-$12:CFED (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_12BC16.lz"
packed_12CFEE:
	; Compressed data for WRAM $7F:8000, $12:CFEE-$12:E609 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_12CFEE.lz"
packed_12E60A:
	; Compressed data for WRAM $7F:A000, $12:E60A-$12:FE49 (from its length word), loaded by load_list_058623, load_list_05CF4A.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_12E60A.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
