; gfx/gfx_18.asm -- Compressed graphics (bank $18)
; Bank $18, $18:8000-$18:FFFF. Included by main.asm in segment BANK18.
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
gfx_188000:
	; ASSET: compressed graphics (VRAM), $18:8000-$18:99A3 (from its length word), loaded by load_list_058808
	.incbin	"gfx/gfx_188000.lz"
gfx_1899A4:
	; ASSET: compressed graphics (VRAM), $18:99A4-$18:AAE2 (from its length word), loaded by load_list_058808
	.incbin	"gfx/gfx_1899A4.lz"
gfx_18AAE3:
	; ASSET: compressed graphics (VRAM), $18:AAE3-$18:AF1F (from its length word), loaded by load_list_058808
	.incbin	"gfx/gfx_18AAE3.lz"
gfx_18AF20:
	; ASSET: compressed graphics (VRAM), $18:AF20-$18:C895 (from its length word), loaded by load_list_058820
	.incbin	"gfx/gfx_18AF20.lz"
gfx_18C896:
	; ASSET: compressed graphics (VRAM), $18:C896-$18:D15A (from its length word), loaded by load_list_058820
	.incbin	"gfx/gfx_18C896.lz"
gfx_18D15B:
	; ASSET: compressed graphics (VRAM), $18:D15B-$18:D4E2 (from its length word), loaded by load_list_058820
	.incbin	"gfx/gfx_18D15B.lz"
gfx_18D4E3:
	; ASSET: compressed graphics (VRAM), $18:D4E3-$18:E9DE (from its length word), loaded by load_list_058838
	.incbin	"gfx/gfx_18D4E3.lz"
gfx_18E9DF:
	; ASSET: compressed graphics (VRAM), $18:E9DF-$18:FAF4 (from its length word), loaded by load_list_058838
	.incbin	"gfx/gfx_18E9DF.lz"
gfx_18FAF5:
	; ASSET: compressed graphics (VRAM), $18:FAF5-$18:FF0D (from its length word), loaded by load_list_058838
	.incbin	"gfx/gfx_18FAF5.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
