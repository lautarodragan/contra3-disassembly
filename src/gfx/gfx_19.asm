; gfx/gfx_19.asm -- Compressed graphics (bank $19)
; Bank $19, $19:8000-$19:FFFF. Included by main.asm in segment BANK19.
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
gfx_198000:
	; ASSET: compressed graphics (VRAM), $19:8000-$19:9AB0 (from its length word), loaded by load_list_058850
	.incbin	"gfx/gfx_198000.lz"
gfx_199AB1:
	; ASSET: compressed graphics (VRAM), $19:9AB1-$19:AB3F (from its length word), loaded by load_list_058850
	.incbin	"gfx/gfx_199AB1.lz"
gfx_19AB40:
	; ASSET: compressed graphics (VRAM), $19:AB40-$19:AF8B (from its length word), loaded by load_list_058850
	.incbin	"gfx/gfx_19AB40.lz"
gfx_19AF8C:
	; ASSET: compressed graphics (VRAM), $19:AF8C-$19:CAB8 (from its length word), loaded by load_list_058868
	.incbin	"gfx/gfx_19AF8C.lz"
gfx_19CAB9:
	; ASSET: compressed graphics (VRAM), $19:CAB9-$19:D778 (from its length word), loaded by load_list_058868
	.incbin	"gfx/gfx_19CAB9.lz"
gfx_19D779:
	; ASSET: compressed graphics (VRAM), $19:D779-$19:DB1F (from its length word), loaded by load_list_058868
	.incbin	"gfx/gfx_19D779.lz"
stage6_bg1_metatiles:
	; Compressed data for WRAM $7E:5000, $19:DB20-$19:EF61 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG1 metatiles from number 0 (4x4 tilemap words each, $20 bytes; draw_bg_column / draw_bg_row, map base $4000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage6_bg1_metatiles.lz"
gfx_19EF62:
	; ASSET: compressed graphics (VRAM), $19:EF62-$19:FEE4 (from its length word), loaded by load_list_05FDEA
	.incbin	"gfx/gfx_19EF62.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
