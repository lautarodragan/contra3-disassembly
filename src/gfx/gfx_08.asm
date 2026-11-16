; gfx/gfx_08.asm -- Palettes and compressed graphics (bank $08)
; Bank $08, $08:8000-$08:FFFF. Included by main.asm in segment BANK08.
;
; Palettes copied to the WRAM palette buffer by the palette tasks (palette_task_animate,
; palette_task_fade_in; see engine/palette_tasks.asm) and by stage5_boss_restore_palette, then graphics
; compressed for decompress_chunk.
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.
;
; A palette here is a block: a word, its size in bytes minus 1, then the
; colours (BGR555 words); palette_task_animate copies size+1 bytes with mvn
; and the fades read as many. Each palette whose bounds are certain is a
; GIMP palette in assets/palettes/ (tools/snespal.py); the build writes the
; block from it. Inline: the blocks that nothing points to, palette_088C3E
; (palette_088C60 is inside it), the colours of the block at $08:8E68 (three
; palettes the stage 5 boss copies alone, 33 bytes each) and palette_088ECA
; (the first byte of which the last of those copies reads).

; The bank of the palettes: the palette tasks read f:GFX_08_BASE,x and copy
; with mvn #^gfx_08.
gfx_08:
GFX_08_BASE = ^gfx_08 << 16

	; CDL: read by palette_task_animate
palette_088000:
	; ASSET: palette: a size-1 word and 16 colours, $08:8000-$08:8021 (from its size word), used by palette_task_0587C3
	.incbin	"palettes/palette_088000.bin"
palette_088022:
	; ASSET: palette: a size-1 word and 16 colours, $08:8022-$08:8043 (from its size word), used by palette_task_0587C3
	.incbin	"palettes/palette_088022.bin"
palette_088044:
	; ASSET: palette: a size-1 word and 16 colours, $08:8044-$08:8065 (from its size word), used by palette_task_0587D8
	.incbin	"palettes/palette_088044.bin"
palette_088066:
	; ASSET: palette: a size-1 word and 16 colours, $08:8066-$08:8087 (from its size word), used by palette_task_0587E1
	.incbin	"palettes/palette_088066.bin"
palette_088088:
	; ASSET: palette: a size-1 word and 16 colours, $08:8088-$08:80A9 (from its size word), used by palette_task_0587EA
	.incbin	"palettes/palette_088088.bin"
palette_0880AA:
	; ASSET: palette: a size-1 word and 48 colours, $08:80AA-$08:810B (from its size word), used by palette_task_05854B
	.incbin	"palettes/palette_0880AA.bin"
	; CDL: not accessed
	.byte	$1F, $00, $00, $00, $13, $50, $11, $50, $0E, $54, $0B, $54, $09, $54, $06, $54
	.byte	$00, $54, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $1F, $00, $00, $00, $D5, $46, $CD, $09, $65, $08, $00, $00, $CD, $5D
	.byte	$E7, $2C, $21, $0C, $00, $00, $42, $18, $D6, $7C, $B2, $08, $00, $00, $3B, $1A
	.byte	$F6, $10, $44, $10
	; CDL: read by palette_task_animate
palette_088150:
	; ASSET: palette: a size-1 word and 96 colours, $08:8150-$08:8211 (from its size word), used by palette_task_058B4C
	.incbin	"palettes/palette_088150.bin"
	; CDL: not accessed
	.byte	$3F, $00, $0E, $5E, $00, $44, $B5, $7E, $FF, $7F, $0E, $5E, $11, $00, $BF, $56
	.byte	$FF, $7F, $0E, $5E, $7F, $02, $00, $50, $1F, $00, $0E, $5E, $B5, $11, $19, $00
	.byte	$00, $00, $0E, $5E, $A5, $14, $31, $46, $FF, $7F, $0E, $5E, $50, $66, $92, $6E
	.byte	$D4, $76, $0E, $5E, $1D, $2C, $FF, $01, $74, $4E, $00, $00, $00, $00, $00, $00
	.byte	$00, $00
	; CDL: read by palette_task_animate, palette_task_fade_in
palette_088254:
	; ASSET: palette: a size-1 word and 48 colours, $08:8254-$08:82B5 (from its size word), used by palette_task_058AC7, palette_task_05A815, palette_task_05A830 (+2 more)
	.incbin	"palettes/palette_088254.bin"
palette_0882B6:
	; ASSET: palette: a size-1 word and 32 colours, $08:82B6-$08:82F7 (from its size word), used by palette_task_058AC7, palette_task_05A815
	.incbin	"palettes/palette_0882B6.bin"
palette_0882F8:
	; ASSET: palette: a size-1 word and 96 colours, $08:82F8-$08:83B9 (from its size word), used by palette_task_058BE7
	.incbin	"palettes/palette_0882F8.bin"
palette_0883BA:
	; ASSET: palette: a size-1 word and 48 colours, $08:83BA-$08:841B (from its size word), used by palette_task_058B4C
	.incbin	"palettes/palette_0883BA.bin"
palette_08841C:
	; ASSET: palette: a size-1 word and 16 colours, $08:841C-$08:843D (from its size word), used by palette_task_05AA28
	.incbin	"palettes/palette_08841C.bin"
palette_08843E:
	; ASSET: palette: a size-1 word and 128 colours, $08:843E-$08:853F (from its size word), used by palette_task_058C62
	.incbin	"palettes/palette_08843E.bin"
palette_088540:
	; ASSET: palette: a size-1 word and 96 colours, $08:8540-$08:8601 (from its size word), used by palette_task_058CCD
	.incbin	"palettes/palette_088540.bin"
palette_088602:
	; ASSET: palette: a size-1 word and 48 colours, $08:8602-$08:8663 (from its size word), used by palette_task_058BE7
	.incbin	"palettes/palette_088602.bin"
palette_088664:
	; ASSET: palette: a size-1 word and 48 colours, $08:8664-$08:86C5 (from its size word), used by palette_task_058C62
	.incbin	"palettes/palette_088664.bin"
palette_0886C6:
	; ASSET: palette: a size-1 word and 48 colours, $08:86C6-$08:8727 (from its size word), used by palette_task_058CCD
	.incbin	"palettes/palette_0886C6.bin"
palette_088728:
	; ASSET: palette: a size-1 word and 48 colours, $08:8728-$08:8789 (from its size word), used by palette_task_05E7E2
	.incbin	"palettes/palette_088728.bin"
palette_08878A:
	; ASSET: palette: a size-1 word and 80 colours, $08:878A-$08:882B (from its size word), used by palette_task_05F8DA
	.incbin	"palettes/palette_08878A.bin"
palette_08882C:
	; ASSET: palette: a size-1 word and 128 colours, $08:882C-$08:892D (from its size word), used by palette_task_058880
	.incbin	"palettes/palette_08882C.bin"
palette_08892E:
	; ASSET: palette: a size-1 word and 96 colours, $08:892E-$08:89EF (from its size word), used by palette_task_058889
	.incbin	"palettes/palette_08892E.bin"
palette_0889F0:
	; ASSET: palette: a size-1 word and 128 colours, $08:89F0-$08:8AF1 (from its size word), used by palette_task_05A815
	.incbin	"palettes/palette_0889F0.bin"
palette_088AF2:
	; ASSET: palette: a size-1 word and 1 colour, $08:8AF2-$08:8AF5 (from its size word), used by palette_task_05A845
	.incbin	"palettes/palette_088AF2.bin"
	; CDL: read by palette_task_animate
palette_088AF6:
	; ASSET: palette: a size-1 word and 16 colours, $08:8AF6-$08:8B17 (from its size word), used by palette_task_05854B, palette_task_05A815, palette_task_05A82A
	.incbin	"palettes/palette_088AF6.bin"
palette_088B18:
	; ASSET: palette: a size-1 word and 48 colours, $08:8B18-$08:8B79 (from its size word), used by palette_task_05FEE8
	.incbin	"palettes/palette_088B18.bin"
palette_088B7A:
	; ASSET: palette: a size-1 word and 80 colours, $08:8B7A-$08:8C1B (from its size word), used by palette_task_05898E
	.incbin	"palettes/palette_088B7A.bin"
palette_088C1C:
	; ASSET: palette: a size-1 word and 16 colours, $08:8C1C-$08:8C3D (from its size word), used by palette_task_058558
	.incbin	"palettes/palette_088C1C.bin"
palette_088C3E:
	.byte	$9F, $00, $00, $00, $63, $08, $E7, $14
	.byte	$2A, $21, $8C, $2D, $F1, $35, $D9, $52, $3D, $5F, $49, $29, $20, $08, $60, $10
	.byte	$A2, $18, $E4, $20, $26, $29, $68, $31, $AA, $39
palette_088C60:
	; LAYOUT: inside the palette before (its colours from here are copied alone)
	.byte	$00, $00, $00, $0C, $41, $18
	.byte	$A4, $24, $07, $31, $6A, $3D, $CD, $49, $30, $56, $00, $00, $41, $08, $83, $10
	.byte	$E6, $1C, $49, $29, $AC, $35, $0F, $42, $93, $52, $A0, $0C, $03, $19, $66, $25
	.byte	$0B, $3A, $B0, $4E, $08, $00, $1D, $00, $BD, $35, $40, $6C, $61, $6D, $80, $73
	.byte	$D4, $12, $9D, $67, $0E, $00, $BD, $14, $BD, $56, $00, $00, $20, $08, $60, $10
	.byte	$A2, $18, $E4, $20, $68, $31, $0D, $46, $91, $56, $00, $00, $44, $0C, $A7, $18
	.byte	$0A, $25, $6D, $31, $F1, $41, $96, $56, $1A, $67, $62, $10, $C5, $1C, $28, $29
	.byte	$8B, $35, $EE, $41, $51, $4E, $B4, $5A, $17, $67, $00, $00, $C5, $18, $07, $21
	.byte	$69, $2D, $EE, $3D, $92, $52, $F5, $5E, $7A, $6F
palette_088CE0:
	; ASSET: palette: a size-1 word and 64 colours, $08:8CE0-$08:8D61 (from its size word), used by palette_task_05CFB2, palette_task_05D006, palette_task_05D056 (+1 more)
	.incbin	"palettes/palette_088CE0.bin"
	; CDL: read by palette_task_fade_in
palette_088D62:
	; ASSET: palette: a size-1 word and 11 colours, $08:8D62-$08:8D79 (from its size word), used by palette_task_05F576, palette_task_05F57C
	.incbin	"palettes/palette_088D62.bin"
palette_088D7A:
	; ASSET: palette: a size-1 word and 3 colours, $08:8D7A-$08:8D81 (from its size word), used by palette_task_05F582, palette_task_05F588
	.incbin	"palettes/palette_088D7A.bin"
	; CDL: read by palette_task_animate; partly not accessed
palette_088D82:
	; ASSET: palette: a size-1 word and 16 colours, $08:8D82-$08:8DA3 (from its size word), used by palette_task_05D006
	.incbin	"palettes/palette_088D82.bin"
palette_088DA4:
	; ASSET: palette: a size-1 word and 80 colours, $08:8DA4-$08:8E45 (from its size word), used by palette_task_05D056, palette_task_05D0AA
	.incbin	"palettes/palette_088DA4.bin"
palette_088E46:
	; ASSET: palette: a size-1 word and 16 colours, $08:8E46-$08:8E67 (from its size word), used by palette_task_05D0AA
	.incbin	"palettes/palette_088E46.bin"
	; $08:8E68: the size-1 word of a 48-colour block that no palette task
	; copies; its colours are the three palettes below, copied alone
	.byte	$5F, $00
	; CDL: read by stage5_boss_restore_palette
palette_088E6A:
	; LAYOUT: inside the palette before (its colours from here are copied alone)
	.byte	$64, $18, $A5, $20, $09, $2D, $6B, $41, $AF, $49, $53, $62, $F8, $6E, $3B, $73
	.byte	$66, $0C, $AB, $18, $0D, $29, $70, $31, $B4, $35, $59, $4E, $FF, $66, $3F, $73
palette_088E8A:
	; LAYOUT: inside the palette before (its colours from here are copied alone)
	.byte	$64, $18, $A4, $1C, $E8, $28, $4A, $3D, $8E, $45, $32, $5E, $D7, $6A, $1A, $6F
	.byte	$66, $0C, $AB, $18, $0E, $29, $70, $31, $D4, $35, $9A, $52, $3F, $6B, $3F, $73
palette_088EAA:
	; LAYOUT: inside the palette before (its colours from here are copied alone)
	.byte	$43, $14, $84, $1C, $C7, $28, $49, $39, $6D, $45, $12, $5E, $B7, $6A, $1A, $6F
	.byte	$66, $0C, $AB, $18, $0E, $29, $90, $31, $D4, $39, $BA, $52, $5F, $6F, $5F, $77
	; CDL: read by palette_task_animate
palette_088ECA:
	; LAYOUT: inside the palette before (its colours from here are copied alone)
	.byte	$3F, $00, $CE, $39, $BD, $36, $FE, $1D, $FC, $2B, $7D, $11, $9A, $04, $FB, $0C
	.byte	$96, $00, $70, $00, $29, $00, $06, $00, $BD, $1D, $E0, $03, $95, $04, $29, $00
	.byte	$AF, $08, $CE, $39, $7B, $5B, $B6, $4A, $73, $3E, $32, $32, $CE, $29, $11, $32
	.byte	$8D, $25, $0A, $15, $A4, $0C, $62, $04, $FA, $0C, $DC, $20, $95, $04, $29, $00
	.byte	$B0, $08
palette_088F0C:
	; ASSET: palette: a size-1 word and 16 colours, $08:8F0C-$08:8F2D (from its size word), used by palette_task_05CFB2, palette_task_05D006, palette_task_05D056 (+1 more)
	.incbin	"palettes/palette_088F0C.bin"
palette_088F2E:
	; ASSET: palette: a size-1 word and 16 colours, $08:8F2E-$08:8F4F (from its size word), used by palette_task_05CFB2, palette_task_05D056
	.incbin	"palettes/palette_088F2E.bin"
palette_088F50:
	; ASSET: palette: a size-1 word and 32 colours, $08:8F50-$08:8F91 (from its size word), used by palette_task_05CFB2
	.incbin	"palettes/palette_088F50.bin"
palette_088F92:
	; ASSET: palette: a size-1 word and 32 colours, $08:8F92-$08:8FD3 (from its size word), used by palette_task_058412, palette_task_058B4C, palette_task_058BE7 (+5 more)
	.incbin	"palettes/palette_088F92.bin"
	; CDL: read by decompress_chunk
gfx_088FD4:
	; ASSET: compressed graphics (VRAM), $08:8FD4-$08:91DD (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_088FD4.lz"
gfx_0891DE:
	; ASSET: compressed graphics (VRAM), $08:91DE-$08:9224 (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_0891DE.lz"
gfx_089225:
	; ASSET: compressed graphics (VRAM), $08:9225-$08:9248 (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_089225.lz"
gfx_089249:
	; ASSET: compressed graphics (VRAM), $08:9249-$08:9D7D (from its length word), loaded by load_list_058527
	.incbin	"gfx/gfx_089249.lz"
gfx_089D7E:
	; ASSET: compressed graphics (VRAM), $08:9D7E-$08:A537 (from its length word), loaded by load_list_058542, load_list_058808, load_list_058820 (+6 more)
	.incbin	"gfx/gfx_089D7E.lz"
gfx_08A538:
	; ASSET: compressed graphics (VRAM), $08:A538-$08:C077 (from its length word), loaded by load_list_059EDC, load_list_05F8C3
	.incbin	"gfx/gfx_08A538.lz"
gfx_08C078:
	; ASSET: compressed graphics (VRAM), $08:C078-$08:D8AE (from its length word), loaded by load_list_05A7DB
	.incbin	"gfx/gfx_08C078.lz"
gfx_08D8AF:
	; ASSET: compressed graphics (VRAM), $08:D8AF-$08:EFC9 (from its length word), loaded by load_list_05A7DB
	.incbin	"gfx/gfx_08D8AF.lz"
	; CDL: read by palette_task_animate
palette_08EFCA:
	; ASSET: palette: a size-1 word and 32 colours, $08:EFCA-$08:F00B (from its size word), used by palette_task_05F8E3
	.incbin	"palettes/palette_08EFCA.bin"
	; CDL: read by palette_task_fade_in; partly not accessed
palette_08F00C:
	; ASSET: palette: a size-1 word and 6 colours, $08:F00C-$08:F019 (from its size word), used by palette_task_05FED3, palette_task_05FED9
	.incbin	"palettes/palette_08F00C.bin"
palette_08F01A:
	; ASSET: palette: a size-1 word and 7 colours, $08:F01A-$08:F029 (from its size word), used by palette_task_05FEC7, palette_task_05FECD
	.incbin	"palettes/palette_08F01A.bin"
palette_08F02A:
	; ASSET: palette: a size-1 word and 3 colours, $08:F02A-$08:F031 (from its size word), used by palette_task_05CD29, palette_task_05CD2F
	.incbin	"palettes/palette_08F02A.bin"
palette_08F032:
	; ASSET: palette: a size-1 word and 12 colours, $08:F032-$08:F04B (from its size word), used by palette_task_05CD35, palette_task_05CD3B
	.incbin	"palettes/palette_08F032.bin"
	; one more colour that the size word leaves out (the fades copy size+1 bytes)
	.byte	$1F, $73
palette_08F04E:
	; ASSET: palette: a size-1 word and 14 colours, $08:F04E-$08:F06B (from its size word), used by palette_task_05CD41, palette_task_05CD47
	.incbin	"palettes/palette_08F04E.bin"
	; one more colour that the size word leaves out (the fades copy size+1 bytes)
	.byte	$54, $42
palette_08F06E:
	; ASSET: palette: a size-1 word and 13 colours, $08:F06E-$08:F089 (from its size word), used by palette_task_05CD4D, palette_task_05CD53
	.incbin	"palettes/palette_08F06E.bin"
	; CDL: not accessed
	.byte	$9F, $52, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
