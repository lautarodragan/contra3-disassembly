; gfx/gfx_14.asm -- Compressed graphics (bank $14)
; Bank $14, $14:8000-$14:FFFF. Included by main.asm in segment BANK14.
;
; Compressed graphics (decompress_chunk) and data read or DMA'd by the top-down
; streaming code (stream_topdown_sprite_gfx).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by decompress_chunk
gfx_148000:
	; ASSET: compressed graphics (VRAM), $14:8000-$14:97EF (from its length word), loaded by load_list_05CFCF
	.incbin	"gfx/gfx_148000.lz"
stage2_boss_m7_chars:
	; Compressed data for WRAM $7E:C000, $14:97F0-$14:9C92 (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: Mode 7 characters of the boss, 3 frames of $600 bytes (stage2_boss_chr_sources), DMAd to VRAM $0040 (high bytes) by stream_topdown_sprite_gfx.
	; No pointers: it decompresses to Mode 7 characters, which the game only copies to VRAM.
	.incbin	"wram/stage2_boss_m7_chars.lz"
stage2_boss_sprite_tiles:
	; Compressed data for WRAM $7E:A000, $14:9C93-$14:A86C (from its length word), loaded by load_list_05CFD8.
	; Stage 2 boss map: 4bpp sprite tiles, DMAd to VRAM $4000 by stream_topdown_sprite_gfx (td_tiles records in $7E).
	; No pointers: it decompresses to 4bpp tiles, which the game only copies to VRAM.
	.incbin	"wram/stage2_boss_sprite_tiles.lz"
gfx_14A86D:
	; ASSET: compressed graphics (VRAM), $14:A86D-$14:BC61 (from its length word), loaded by load_list_05CF33
	.incbin	"gfx/gfx_14A86D.lz"
	; CDL: DMA (started in stream_topdown_sprite_gfx)
; Raw sprite tiles (4bpp) of the top-down objects, DMA'd to VRAM by
; stream_topdown_sprite_gfx: the td_tiles records of bank $07 give
; addresses in this block (as offsets from its label).
td_sprite_tiles_14:
	.incbin	"gfx/td_sprite_tiles_14.bin"
; The centipede's last td_tiles record (td_tiles_07A3EA) DMAs $100 bytes from
; +$1F80, so $80 bytes past the end of these tiles (here the start of
; gfx_14DC62) go to VRAM too: to tiles that its frames do not show (see
; td_tiles_07A3EA).  Whatever follows can change; the td_tiles macro checks
; that the DMA stays in the bank.
	; CDL: read by stream_topdown_sprite_gfx
gfx_14DC62:
	; ASSET: compressed graphics (VRAM), $14:DC62-$14:F0F7 (from its length word), loaded by load_list_05FDCF
	; from +$0080: CDL: read by decompress_chunk
	.incbin	"gfx/gfx_14DC62.lz"
gfx_14F0F8:
	; ASSET: compressed graphics (VRAM), $14:F0F8-$14:FAF6 (from its length word), loaded by load_list_05FDE1
	.incbin	"gfx/gfx_14F0F8.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
