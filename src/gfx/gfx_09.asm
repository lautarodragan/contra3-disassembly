; gfx/gfx_09.asm -- Compressed graphics (bank $09)
; Bank $09, $09:8000-$09:FFFF. Included by main.asm in segment BANK09.
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
gfx_098000:
	; ASSET: compressed graphics (VRAM), $09:8000-$09:998D (from its length word), loaded by load_list_058B08, load_list_058B2F
	.incbin	"gfx/gfx_098000.lz"
gfx_09998E:
	; ASSET: compressed graphics (VRAM), $09:998E-$09:B32C (from its length word), loaded by load_list_058B08, load_list_058B2F
	.incbin	"gfx/gfx_09998E.lz"
gfx_09B32D:
	; ASSET: compressed graphics (VRAM), $09:B32D-$09:CD48 (from its length word), loaded by load_list_058B08, load_list_058B2F
	.incbin	"gfx/gfx_09B32D.lz"
gfx_09CD49:
	; ASSET: compressed graphics (VRAM), $09:CD49-$09:E637 (from its length word), loaded by load_list_058B08, load_list_058B2F
	.incbin	"gfx/gfx_09CD49.lz"
stage1_bomber_m7_chars:
	; Compressed data for WRAM $7E:A000, $09:E638-$09:EBB9 (from its length word), loaded by load_list_059EFC.
	; Stage 1 bomber raid: Mode 7 characters (the bomber), the high bytes of VRAM $0000-$0FFF written by bomber_raid_state_02 (bomber_raid_pixel_ptr).
	; No pointers: it decompresses to Mode 7 characters, which the game only copies to VRAM.
	.incbin	"wram/stage1_bomber_m7_chars.lz"
gfx_09EBBA:
	; ASSET: compressed graphics (VRAM), $09:EBBA-$09:F823 (from its length word), loaded by load_list_059E79
	.incbin	"gfx/gfx_09EBBA.lz"
	; CDL: not accessed
; A compressed BG map that nothing loads: no load list, pointer or label
; refers to it, and the CDL never read it. Its length word ($0210) ends it
; exactly where stage6_bg1_metatiles_2 starts. It decompresses to a 32x32
; BG3 map in the font of the closing messages (gfx_089D7E, the same
; character numbers as ending_message_easy): "WARNING / THIS GAME IS FOR
; SALE AND USE IN JAPAN ONLY. ..." and a (c) 1992 KONAMI line, a legal
; notice of the Japanese release left in the US ROM (book: What the traces
; never touched).
unused_warning_message:
	; ASSET: compressed BG map, $09:F824-$09:FA33 (from its length word), loaded by nothing
	.incbin	"gfx/unused_warning_message.lz"
	; CDL: read by decompress_chunk
stage6_bg1_metatiles_2:
	; Compressed data for WRAM $7E:7000, $09:FA34-$09:FBF3 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG1 metatiles $100 and up (they continue stage6_bg1_metatiles at $7E:7000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage6_bg1_metatiles_2.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
