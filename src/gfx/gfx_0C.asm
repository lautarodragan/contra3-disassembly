; gfx/gfx_0C.asm -- Compressed graphics (bank $0C)
; Bank $0C, $0C:8000-$0C:FFFF. Included by main.asm in segment BANK0C.
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
gfx_0C8000:
	; ASSET: compressed graphics (VRAM), $0C:8000-$0C:98A1 (from its length word), loaded by load_list_058B85, load_list_058BB6
	.incbin	"gfx/gfx_0C8000.lz"
gfx_0C98A2:
	; ASSET: compressed graphics (VRAM), $0C:98A2-$0C:AFBE (from its length word), loaded by load_list_058B85, load_list_058BB6
	.incbin	"gfx/gfx_0C98A2.lz"
gfx_0CAFBF:
	; ASSET: compressed graphics (VRAM), $0C:AFBF-$0C:C65D (from its length word), loaded by load_list_058B85, load_list_058BB6
	.incbin	"gfx/gfx_0CAFBF.lz"
gfx_0CC65E:
	; ASSET: compressed graphics (VRAM), $0C:C65E-$0C:DB2C (from its length word), loaded by load_list_058B85, load_list_058BB6
	.incbin	"gfx/gfx_0CC65E.lz"
gfx_0CDB2D:
	; ASSET: compressed graphics (VRAM), $0C:DB2D-$0C:F4BC (from its length word), loaded by load_list_059E9E
	.incbin	"gfx/gfx_0CDB2D.lz"
gfx_0CF4BD:
	; ASSET: compressed graphics (VRAM), $0C:F4BD-$0C:FCB9 (from its length word), loaded by load_list_059E9E
	.incbin	"gfx/gfx_0CF4BD.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
