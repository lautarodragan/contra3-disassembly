; gfx/gfx_0D.asm -- Compressed graphics (bank $0D)
; Bank $0D, $0D:8000-$0D:FFFF. Included by main.asm in segment BANK0D.
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
packed_0D8000:
	; Compressed data for WRAM $7E:B000, $0D:8000-$0D:8CC3 (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0D8000.lz"
packed_0D8CC4:
	; Compressed data for WRAM $7E:5000, $0D:8CC4-$0D:9C9D (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0D8CC4.lz"
packed_0D9C9E:
	; Compressed data for WRAM $7E:7000, $0D:9C9E-$0D:A5E4 (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0D9C9E.lz"
packed_0DA5E5:
	; Compressed data for WRAM $7E:F000, $0D:A5E5-$0D:A727 (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0DA5E5.lz"
gfx_0DA728:
	; ASSET: compressed graphics (VRAM), $0D:A728-$0D:BCEA (from its length word), loaded by load_list_058AD4
	.incbin	"gfx/gfx_0DA728.lz"
gfx_0DBCEB:
	; ASSET: compressed graphics (VRAM), $0D:BCEB-$0D:C2FD (from its length word), loaded by load_list_058B08
	.incbin	"gfx/gfx_0DBCEB.lz"
gfx_0DC2FE:
	; ASSET: compressed graphics (VRAM), $0D:C2FE-$0D:C90B (from its length word), loaded by load_list_058B08, load_list_058B85, load_list_058BB6 (+2 more)
	.incbin	"gfx/gfx_0DC2FE.lz"
gfx_0DC90C:
	; ASSET: compressed graphics (VRAM), $0D:C90C-$0D:D6D2 (from its length word), loaded by load_list_058B08
	.incbin	"gfx/gfx_0DC90C.lz"
gfx_0DD6D3:
	; ASSET: compressed graphics (VRAM), $0D:D6D3-$0D:DC1F (from its length word), loaded by load_list_058B85, load_list_058BB6, load_list_058C97 (+2 more)
	.incbin	"gfx/gfx_0DD6D3.lz"
gfx_0DDC20:
	; ASSET: compressed graphics (VRAM), $0D:DC20-$0D:E217 (from its length word), loaded by load_list_059E62
	.incbin	"gfx/gfx_0DDC20.lz"
gfx_0DE218:
	; ASSET: compressed graphics (VRAM), $0D:E218-$0D:EF87 (from its length word), loaded by load_list_059E79, load_list_05AA1F
	.incbin	"gfx/gfx_0DE218.lz"
gfx_0DEF88:
	; ASSET: compressed graphics (VRAM), $0D:EF88-$0D:FA67 (from its length word), loaded by load_list_058C14, load_list_058C3B
	.incbin	"gfx/gfx_0DEF88.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
