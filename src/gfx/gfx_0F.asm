; gfx/gfx_0F.asm -- Compressed graphics (bank $0F)
; Bank $0F, $0F:8000-$0F:FFFF. Included by main.asm in segment BANK0F.
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
gfx_0F8000:
	; ASSET: compressed graphics (VRAM), $0F:8000-$0F:945F (from its length word), loaded by load_list_058C14, load_list_058C3B, load_list_059EDC (+1 more)
	.incbin	"gfx/gfx_0F8000.lz"
gfx_0F9460:
	; ASSET: compressed graphics (VRAM), $0F:9460-$0F:AC8F (from its length word), loaded by load_list_058C14, load_list_058C3B, load_list_05FF30
	.incbin	"gfx/gfx_0F9460.lz"
gfx_0FAC90:
	; ASSET: compressed graphics (VRAM), $0F:AC90-$0F:C8E4 (from its length word), loaded by load_list_058C14, load_list_058C3B
	.incbin	"gfx/gfx_0FAC90.lz"
gfx_0FC8E5:
	; ASSET: compressed graphics (VRAM), $0F:C8E5-$0F:D146 (from its length word), loaded by load_list_058C14
	.incbin	"gfx/gfx_0FC8E5.lz"
gfx_0FD147:
	; ASSET: compressed graphics (VRAM), $0F:D147-$0F:EDE9 (from its length word), loaded by load_list_058C3B, load_list_05ECD9
	.incbin	"gfx/gfx_0FD147.lz"
packed_0FEDEA:
	; Compressed data for WRAM $7E:5000, $0F:EDEA-$0F:F83A (from its length word), loaded by load_list_058687, load_list_058BF8.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0FEDEA.lz"
packed_0FF83B:
	; Compressed data for WRAM $7E:B000, $0F:F83B-$0F:FDB6 (from its length word), loaded by load_list_058687, load_list_058BF8.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0FF83B.lz"
packed_0FFDB7:
	; Compressed data for WRAM $7E:F000, $0F:FDB7-$0F:FF11 (from its length word), loaded by load_list_058687, load_list_058BF8.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_0FFDB7.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
