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
	.byte	$10, $02, $7F, $DE, $7F, $FF, $7C, $20, $7C, $41, $7C, $62, $7C, $83, $7C, $A4
	.byte	$7C, $C5, $EE, $89, $51, $04, $3C, $04, $4C, $04, $49, $04, $44, $04, $FC, $82
	.byte	$42, $04, $7C, $D6, $7D, $25, $FA, $81, $4E, $AF, $43, $44, $4D, $00, $42, $3C
	.byte	$48, $40, $00, $44, $4D, $00, $41, $4A, $4C, $00, $4D, $AF, $3C, $47, $40, $00
	.byte	$3C, $49, $3F, $00, $00, $00, $00, $00, $00, $00, $4F, $4D, $40, $AF, $00, $44
	.byte	$49, $00, $45, $3C, $0B, $3C, $49, $00, $4A, $49, $47, $53, $2E, $00, $00, $6D
	.byte	$4A, $09, $A7, $81, $3E, $AF, $4A, $0B, $53, $4C, $44, $42, $43, $4E, $40, $3F
	.byte	$00, $48, $4F, $4D, $44, $3E, $30, $F3, $02, $0B, $01, $F9, $01, $B7, $01, $F3
	.byte	$02, $27, $02, $23, $09, $FB, $02, $29, $02, $07, $02, $0D, $0A, $27, $02, $2F
	.byte	$04, $F5, $AF, $4A, $4C, $46, $4D, $00, $44, $49, $00, $4E, $43, $44, $4D, $00
	.byte	$00, $00, $00, $42, $AF, $3C, $48, $40, $00, $3C, $40, $4C, $00, $4D, $40, $0B
	.byte	$3C, $4C, $3C, $4E, $40, $47, $AF, $53, $00, $4A, $51, $49, $40, $3F, $00, $3D
	.byte	$53, $00, $00, $00, $00, $4E, $43, $40, $AF, $00, $3C, $4F, $4E, $43, $4A, $4C
	.byte	$4D, $2E, $00, $00, $00, $00, $00, $00, $00, $00, $7D, $CA, $02, $79, $02, $AD
	.byte	$02, $97, $02, $85, $0A, $09, $0A, $E9, $0A, $6F, $11, $7D, $02, $67, $09, $B7
	.byte	$02, $F5, $0A, $E7, $F0, $03, $01, $0A, $AD, $0A, $07, $02, $93, $0B, $0D, $22
	.byte	$53, $12, $2F, $09, $F3, $03, $3D, $0B, $01, $0A, $99, $2A, $57, $E4, $02, $F9
	.byte	$03, $4B, $03, $49, $0B, $35, $02, $EF, $0B, $45, $2A, $91, $02, $F1, $03, $07
	.byte	$02, $8D, $0B, $53, $19, $8F, $1A, $E3, $E8, $81, $50, $AF, $44, $4A, $47, $3C
	.byte	$4E, $4A, $4C, $00, $00, $48, $3C, $53, $00, $3D, $40, $00, $4D, $AF, $4F, $3D
	.byte	$45, $40, $3E, $4E, $00, $4E, $4A, $00, $00, $00, $00, $00, $4D, $40, $50, $AF
	.byte	$40, $4C, $40, $00, $0B, $40, $49, $3C, $47, $4E, $44, $40, $4D, $00, $4F, $49
	.byte	$47, $AF, $40, $4D, $4D, $00, $00, $00, $00, $00, $00, $00, $00, $00, $4D, $0B
	.byte	$40, $3E, $44, $AF, $3C, $47, $47, $53, $00, $3C, $4F, $4E, $43, $4A, $4C, $44
	.byte	$54, $40, $3F, $00, $3D, $AF, $53, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$4E, $43, $40, $48, $2E, $32, $00, $7C, $6F, $7C, $90, $7C, $B1, $7C, $D2, $97
	.byte	$00, $33, $18, $34, $18, $35, $18, $36, $18, $37, $18, $38, $18, $39, $18, $3A
	.byte	$18, $80, $18, $81, $18, $82, $18, $7C, $D4, $E5, $97, $83, $18, $84, $18, $85
	.byte	$18, $86, $18, $87, $18, $88, $18, $89, $18, $8A, $18, $8B, $18, $8C, $18, $8D
	.byte	$18, $8E, $7D, $0A, $E6, $83, $8F, $18, $90, $7D, $4A, $FA, $81, $2C, $AF, $00
	.byte	$02, $0A, $0A, $03, $00, $46, $4A, $49, $3C, $48, $44, $00, $00, $00, $00, $00
	.byte	$7D, $D5, $7D, $F6, $7E, $17, $7E, $38, $7E, $59, $7E, $7A, $7E, $9B, $7E, $BC
	.byte	$7E, $DD, $7E, $FE, $7F, $1F, $7F, $40, $7F, $61, $7F, $82, $7F, $A3, $63, $C4
	; CDL: read by decompress_chunk
stage6_bg1_metatiles_2:
	; Compressed data for WRAM $7E:7000, $09:FA34-$09:FBF3 (from its length word), loaded by load_list_058C6F.
	; Stage 6: BG1 metatiles $100 and up (they continue stage6_bg1_metatiles at $7E:7000).
	; No pointers: it decompresses to BG tilemap words, which draw_bg_column / draw_bg_row copy to VRAM.
	.incbin	"wram/stage6_bg1_metatiles_2.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
