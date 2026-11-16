; gfx/gfx_0E.asm -- Compressed graphics (bank $0E)
; Bank $0E, $0E:8000-$0E:FFFF. Included by main.asm in segment BANK0E.
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
gfx_0E8000:
	; ASSET: compressed graphics (VRAM), $0E:8000-$0E:8306 (from its length word), loaded by load_list_058B85, load_list_058BB6, load_list_058C97
	.incbin	"gfx/gfx_0E8000.lz"
gfx_0E8307:
	; ASSET: compressed graphics (VRAM), $0E:8307-$0E:8650 (from its length word), loaded by load_list_058B85
	.incbin	"gfx/gfx_0E8307.lz"
gfx_0E8651:
	; ASSET: compressed graphics (VRAM), $0E:8651-$0E:8C88 (from its length word), loaded by load_list_058B85
	.incbin	"gfx/gfx_0E8651.lz"
gfx_0E8C89:
	; ASSET: compressed graphics (VRAM), $0E:8C89-$0E:8F5A (from its length word), loaded by load_list_058BB6, load_list_058C97, load_list_059EB1
	.incbin	"gfx/gfx_0E8C89.lz"
gfx_0E8F5B:
	; ASSET: compressed graphics (VRAM), $0E:8F5B-$0E:9583 (from its length word), loaded by load_list_058BB6, load_list_058C97, load_list_059EB1
	.incbin	"gfx/gfx_0E8F5B.lz"
gfx_0E9584:
	; ASSET: compressed graphics (VRAM), $0E:9584-$0E:9F5D (from its length word), loaded by load_list_058C14, load_list_058C3B
	.incbin	"gfx/gfx_0E9584.lz"
gfx_0E9F5E:
	; ASSET: compressed graphics (VRAM), $0E:9F5E-$0E:A34A (from its length word), loaded by load_list_059EF3, load_list_05ECD0
	.incbin	"gfx/gfx_0E9F5E.lz"
gfx_0EA34B:
	; ASSET: compressed graphics (VRAM), $0E:A34B-$0E:B8F6 (from its length word), loaded by load_list_058C97
	.incbin	"gfx/gfx_0EA34B.lz"
gfx_0EB8F7:
	; ASSET: compressed graphics (VRAM), $0E:B8F7-$0E:C023 (from its length word), loaded by load_list_05FF27
	.incbin	"gfx/gfx_0EB8F7.lz"
gfx_0EC024:
	; ASSET: compressed graphics (VRAM), $0E:C024-$0E:DA4D (from its length word), loaded by load_list_059E9E
	.incbin	"gfx/gfx_0EC024.lz"
gfx_0EDA4E:
	; ASSET: compressed graphics (VRAM), $0E:DA4E-$0E:DD87 (from its length word), loaded by load_list_058C14, load_list_058C3B
	.incbin	"gfx/gfx_0EDA4E.lz"
gfx_0EDD88:
	; ASSET: compressed graphics (VRAM), $0E:DD88-$0E:E8B0 (from its length word), loaded by load_list_058B2F, load_list_059E70
	.incbin	"gfx/gfx_0EDD88.lz"
packed_0EE8B1:
	; Compressed data for WRAM $7E:A000, $0E:E8B1-$0E:F365 (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0EE8B1.lz"
packed_0EF366:
	; Compressed data for WRAM $7E:9000, $0E:F366-$0E:F5A1 (from its length word), loaded by load_list_058687, load_list_058BF8.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0EF366.lz"
packed_0EF5A2:
	; Compressed data for WRAM $7E:9000, $0E:F5A2-$0E:FB9C (from its length word), loaded by load_list_058B5D.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0EF5A2.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
