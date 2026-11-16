; gfx/gfx_15.asm -- Compressed graphics (bank $15)
; Bank $15, $15:8000-$15:FFFF. Included by main.asm in segment BANK15.
;
; Compressed graphics (decompress_chunk) and data read by the attract demo code
; (demo_read_p2_event).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by decompress_chunk
gfx_158000:
	; ASSET: compressed graphics (VRAM), $15:8000-$15:A476 (from its length word), loaded by load_list_05D01F
	.incbin	"gfx/gfx_158000.lz"
packed_15A477:
	; Compressed data for WRAM $7E:8000, $15:A477-$15:A9E9 (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15A477.lz"
packed_15A9EA:
	; Compressed data for WRAM $7E:9000, $15:A9EA-$15:AAFD (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15A9EA.lz"
packed_15AAFE:
	; Compressed data for WRAM $7E:9400, $15:AAFE-$15:AC11 (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15AAFE.lz"
packed_15AC12:
	; Compressed data for WRAM $7E:9800, $15:AC12-$15:AD25 (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15AC12.lz"
packed_15AD26:
	; Compressed data for WRAM $7E:9C00, $15:AD26-$15:AE2D (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15AD26.lz"
packed_15AE2E:
	; Compressed data for WRAM $7E:A000, $15:AE2E-$15:C2B2 (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15AE2E.lz"
packed_15C2B3:
	; Compressed data for WRAM $7E:C000, $15:C2B3-$15:D809 (from its length word), loaded by load_list_05D028.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15C2B3.lz"
packed_15D80A:
	; Compressed data for WRAM $7E:5000, $15:D80A-$15:DCD8 (from its length word), loaded by load_list_05A84B.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/packed_15D80A.lz"
gfx_15DCD9:
	; ASSET: compressed graphics (VRAM), $15:DCD9-$15:F396 (from its length word), loaded by load_list_059EEA, load_list_05F8D1
	.incbin	"gfx/gfx_15DCD9.lz"
	; CDL: read by demo_read_p2_event
demo_input_p2_0:
	.byte	$00, $00, $65, $00, $00, $01, $96, $00, $00, $00, $32, $00, $00, $01, $AB, $00
	.byte	$00, $00, $1F, $00, $00, $02, $60, $00, $00, $00, $21, $00, $20, $00, $04, $00
	.byte	$30, $00, $3D, $00, $30, $40, $8D, $00, $00, $00, $02, $01, $00, $01, $03, $00
	.byte	$00, $00, $1D, $00, $00, $01, $0D, $00, $00, $81, $19, $00, $00, $01, $2B, $00
	.byte	$00, $81, $0F, $00, $00, $01, $28, $00, $00, $81, $0F, $00, $00, $01, $09, $00
	.byte	$00, $09, $20, $00, $00, $01, $7C, $00, $00, $00, $02, $00, $00, $40, $03, $00
	.byte	$00, $41, $08, $00, $00, $45, $47, $00, $00, $41, $0A, $00, $00, $40, $10, $00
	.byte	$00, $00, $01, $00, $00, $40, $08, $00, $00, $42, $05, $00, $00, $C2, $0B, $00
	.byte	$00, $42, $09, $00, $00, $40, $0E, $00, $00, $00, $95, $00, $00, $01, $9E, $00
	.byte	$00, $49, $01, $00, $00, $48, $02, $00, $00, $40, $13, $00, $00, $41, $42, $00
	.byte	$00, $49, $01, $00, $00, $48, $05, $00, $00, $4A, $05, $00, $00, $48, $02, $00
	.byte	$00, $4A, $44, $00
	; CDL: not accessed
	.byte	$00, $48, $02, $00, $00, $49, $10, $00, $00, $48, $04, $00, $10, $48, $1B, $00
	.byte	$10, $4A, $37, $00, $10, $48, $07, $00, $10, $49, $09, $00, $00, $49, $06, $00
	.byte	$00, $41, $13, $00, $00, $01, $01, $00, $00, $09, $02, $00, $00, $08, $05, $00
	.byte	$00, $00, $17, $00, $00, $01, $37, $00, $00, $09, $0B, $00, $00, $08, $0A, $00
	.byte	$00, $0A, $4E, $00, $00, $08, $02, $00, $00, $48, $02, $00, $10, $49, $34, $00
	.byte	$00, $49, $02, $00, $00, $41, $0F, $00, $00, $49, $11, $00, $00, $41, $04, $00
	.byte	$00, $40, $C9, $00, $00, $42, $11, $00, $00, $40, $02, $00, $00, $48, $01, $00
	.byte	$00, $40, $01, $00, $00, $41, $01, $00, $00, $40, $1A, $00, $00, $42, $42, $00
	.byte	$10, $42, $02, $00, $10, $48, $02, $00, $10, $49, $1D, $00, $00, $49, $01, $00
	.byte	$00, $48, $02, $00, $00, $C0, $01, $00, $00, $C2, $07, $00, $00, $CA, $03, $00
	.byte	$00, $C8, $01, $00, $00, $48, $03, $00, $00, $41, $0F, $00, $00, $40, $02, $00
	.byte	$00, $42, $13, $00, $00, $40, $09, $00, $00, $44, $0D, $00, $00, $41, $84, $00
	.byte	$20, $41, $02, $00, $30, $41, $01, $00, $30, $49, $26, $00, $30, $41, $02, $00
	.byte	$30, $49, $04, $00, $30, $41, $08, $00, $20, $41, $03, $00, $00, $41, $06, $00
	.byte	$20, $41, $03, $00, $20, $49, $05, $00, $30, $49, $50, $00, $30, $41, $10, $00
	.byte	$20, $41, $07, $00, $00, $41, $96, $00, $10, $41, $20, $00, $00, $41, $13, $00
	.byte	$00, $45, $1E, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$EF, $EF, $EF, $EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF, $FF, $FF
	.byte	$EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; CDL: read by demo_read_p2_event
demo_input_p2_1:
	.byte	$00, $00, $78, $00, $00, $40, $0F, $00, $00, $00, $B4, $01, $20, $00, $09, $00
	.byte	$20, $08, $08, $00, $20, $0A, $01, $00, $20, $02, $15, $00, $00, $02, $0A, $00
	.byte	$00, $00, $02, $00, $00, $80, $01, $00, $00, $C0, $5A, $00, $00, $80, $01, $00
	.byte	$00, $00, $18, $00, $00, $01, $15, $00, $10, $01, $12, $00, $00, $01, $02, $00
	.byte	$00, $C0, $45, $00, $00, $80, $01, $00, $00, $02, $02, $00, $00, $06, $14, $00
	.byte	$00, $02, $01, $00, $00, $00, $01, $00, $00, $01, $01, $00, $00, $00, $6E, $00
	.byte	$00, $01, $03, $00, $20, $01, $05, $00, $20, $05, $02, $00, $20, $04, $03, $00
	.byte	$20, $00, $01, $00, $20, $01, $01, $00, $20, $05, $02, $00, $20, $04, $09, $00
	.byte	$20, $00, $01, $00, $20, $02, $01, $00, $00, $02, $02, $00, $00, $00, $03, $00
	.byte	$00, $02, $13, $00, $00, $00, $16, $00, $00, $08, $0C, $00, $00, $00, $0B, $00
	.byte	$80, $02, $09, $00, $00, $02, $01, $00, $00, $00, $04, $00, $00, $04, $04, $00
	.byte	$00, $06, $09, $00, $00, $86, $01, $00, $00, $C2, $01, $00, $00, $C0, $02, $00
	.byte	$00, $80, $30, $00, $00, $00, $04, $00, $20, $00, $08, $00, $20, $04, $02, $00
	.byte	$20, $05, $01, $00, $20, $04, $01, $00, $20, $05, $05, $00, $00, $05, $01, $00
	.byte	$00, $01, $06, $00, $00, $00, $0D, $00, $00, $01, $05, $00, $00, $00, $04, $00
	.byte	$00, $01, $04, $00, $00, $00, $17, $00, $00, $01, $05, $00, $10, $01, $1C, $00
	.byte	$10, $00, $19, $00, $10, $01, $11, $00, $10, $00, $03, $00, $10, $40, $01, $00
	.byte	$00, $40, $2B, $00, $20, $40, $02, $00, $30, $40, $7F, $00, $00, $40, $1F, $00
	.byte	$00, $41, $6A, $00, $10, $41, $13, $00, $00, $41, $D1, $00, $00, $45, $03, $00
	.byte	$00, $44, $0A, $00, $00, $45, $0C, $00, $00, $41, $11, $00, $00, $C1, $09, $00
	.byte	$00, $C0, $57, $00, $00, $80, $02, $00, $00, $00, $09, $00, $00, $01, $0C, $00
	.byte	$00, $05, $01, $00, $00, $04, $1D, $00, $00, $48, $03, $00, $00, $41, $0F, $00
	; CDL: not accessed
	.byte	$00, $40, $02, $00, $00, $42, $13, $00, $00, $40, $09, $00, $00, $44, $0D, $00
	.byte	$00, $41, $84, $00, $20, $41, $02, $00, $30, $41, $01, $00, $30, $49, $26, $00
	.byte	$30, $41, $02, $00, $30, $49, $04, $00, $30, $41, $08, $00, $20, $41, $03, $00
	.byte	$00, $41, $06, $00, $20, $41, $03, $00, $20, $49, $05, $00, $30, $49, $50, $00
	.byte	$30, $41, $10, $00, $20, $41, $07, $00, $00, $41, $96, $00, $10, $41, $20, $00
	.byte	$00, $41, $13, $00, $00, $45, $1E, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $EF, $EF, $EF, $EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $EF, $FF, $FF, $EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; CDL: read by demo_read_p2_event
demo_input_p2_2:
	.byte	$00, $00, $3E, $01, $00, $08, $B3, $00, $00, $0A, $0E, $00, $00, $08, $07, $00
	.byte	$00, $48, $17, $01, $00, $4A, $03, $00, $00, $08, $09, $00, $80, $08, $06, $00
	.byte	$80, $0A, $03, $00, $00, $0A, $0C, $00, $00, $02, $16, $00, $00, $00, $01, $00
	.byte	$00, $08, $07, $00, $00, $00, $02, $00, $00, $02, $08, $00, $00, $00, $01, $00
	.byte	$00, $01, $4A, $00, $00, $00, $01, $00, $00, $08, $01, $00, $00, $00, $01, $00
	.byte	$00, $02, $06, $00, $00, $0A, $0C, $00, $00, $4A, $39, $00, $00, $48, $02, $00
	.byte	$00, $4A, $01, $00, $00, $CA, $03, $00, $00, $C8, $03, $00, $00, $CA, $03, $00
	.byte	$00, $C8, $03, $00, $00, $C9, $03, $00, $00, $C1, $01, $00, $00, $41, $03, $00
	.byte	$00, $49, $02, $00, $00, $41, $03, $00, $00, $49, $06, $00, $00, $41, $06, $00
	.byte	$00, $49, $01, $00, $00, $48, $02, $00, $00, $40, $13, $00, $00, $41, $42, $00
	.byte	$00, $49, $01, $00, $00, $48, $05, $00, $00, $4A, $05, $00, $00, $48, $02, $00
	.byte	$00, $4A, $44, $00, $00, $48, $02, $00, $00, $49, $10, $00, $00, $48, $04, $00
	.byte	$10, $48, $1B, $00, $10, $4A, $37, $00, $10, $48, $07, $00, $10, $49, $09, $00
	.byte	$00, $49, $06, $00, $00, $41, $13, $00, $00, $01, $01, $00, $00, $09, $02, $00
	.byte	$00, $08, $05, $00, $00, $00, $17, $00, $00, $01, $37, $00, $00, $09, $0B, $00
	.byte	$00, $08, $0A, $00, $00, $0A, $4E, $00, $00, $08, $02, $00, $00, $48, $02, $00
	.byte	$10, $49, $34, $00, $00, $49, $02, $00, $00, $41, $0F, $00, $00, $49, $11, $00
	.byte	$00, $41, $04, $00, $00, $40, $C9, $00, $00, $42, $11, $00, $00, $40, $02, $00
	.byte	$00, $48, $01, $00, $00, $40, $01, $00, $00, $41, $01, $00, $00, $40, $1A, $00
	.byte	$00, $42, $42, $00, $10, $42, $02, $00, $10, $48, $02, $00, $10, $49, $1D, $00
	.byte	$00, $49, $01, $00, $00, $48, $02, $00, $00, $C0, $01, $00, $00, $C2, $07, $00
	.byte	$00, $CA, $03, $00, $00, $C8, $01, $00, $00, $48, $03, $00, $00, $41, $0F, $00
	.byte	$00, $40, $02, $00, $00, $42, $13, $00
	; CDL: not accessed
	.byte	$00, $40, $09, $00, $00, $44, $0D, $00, $00, $41, $84, $00, $20, $41, $02, $00
	.byte	$30, $41, $01, $00, $30, $49, $26, $00, $30, $41, $02, $00, $30, $49, $04, $00
	.byte	$30, $41, $08, $00, $20, $41, $03, $00, $00, $41, $06, $00, $20, $41, $03, $00
	.byte	$20, $49, $05, $00, $30, $49, $50, $00, $30, $41, $10, $00, $20, $41, $07, $00
	.byte	$00, $41, $96, $00, $10, $41, $20, $00, $00, $41, $13, $00, $00, $45, $1E, $00
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF, $EF, $EF, $EF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF, $FF, $FF, $EF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $EF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
