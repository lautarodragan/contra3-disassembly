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
packed_0A9BC6:
	; Compressed data for WRAM $7E:A000, $0A:9BC6-$0A:A37B (from its length word), loaded by load_list_059FBA.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0A9BC6.lz"
gfx_0AA37C:
	; ASSET: compressed graphics (VRAM), $0A:A37C-$0A:B063 (from its length word), loaded by load_list_059E8C
	.incbin	"gfx/gfx_0AA37C.lz"
packed_0AB064:
	; Compressed data for WRAM $7E:5000, $0A:B064-$0A:C13A (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0AB064.lz"
packed_0AC13B:
	; Compressed data for WRAM $7E:B000, $0A:C13B-$0A:CDBB (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0AC13B.lz"
packed_0ACDBC:
	; Compressed data for WRAM $7E:7000, $0A:CDBC-$0A:D870 (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0ACDBC.lz"
packed_0AD871:
	; Compressed data for WRAM $7E:9000, $0A:D871-$0A:DE6C (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0AD871.lz"
packed_0ADE6D:
	; Compressed data for WRAM $7E:F000, $0A:DE6D-$0A:E032 (from its length word), loaded by load_list_0585D1, load_list_058AE6.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0ADE6D.lz"
gfx_0AE033:
	; ASSET: compressed graphics (VRAM), $0A:E033-$0A:E4A1 (from its length word), loaded by load_list_05EB45
	.incbin	"gfx/gfx_0AE033.lz"
gfx_0AE4A2:
	; ASSET: compressed graphics (VRAM), $0A:E4A2-$0A:FD7A (from its length word), loaded by load_list_05F286
	.incbin	"gfx/gfx_0AE4A2.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
