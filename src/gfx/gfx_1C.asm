; gfx/gfx_1C.asm -- Compressed graphics (bank $1C)
; Bank $1C, $1C:8000-$1C:FFFF. Included by main.asm in segment BANK1C.
;
; Graphics compressed for the decompressor (decompress_chunk, see
; engine/decompress.asm).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	.byte	$C6, $1B
spc_data_1C8002:
	; ASSET: compressed sound CPU data, $1C:8002-$1C:9778 (from its length word), loaded by song_set_05F3C9
	.incbin	"sound/spc_data_1C8002.lz"
	.byte	$CB, $1D
spc_data_1C977B:
	; ASSET: compressed sound CPU data, $1C:977B-$1C:B139 (from its length word), loaded by song_set_05F3E4
	.incbin	"sound/spc_data_1C977B.lz"
	.byte	$AA, $0D
spc_data_1CB13C:
	; ASSET: compressed sound CPU data, $1C:B13C-$1C:BDE4 (from its length word), loaded by song_set_05F3FF
	.incbin	"sound/spc_data_1CB13C.lz"
	.byte	$D8, $15
spc_data_1CBDE7:
	; ASSET: compressed sound CPU data, $1C:BDE7-$1C:D15B (from its length word), loaded by song_set_05F41A
	.incbin	"sound/spc_data_1CBDE7.lz"
	.byte	$CB, $1D
spc_data_1CD15E:
	; ASSET: compressed sound CPU data, $1C:D15E-$1C:E6BA (from its length word), loaded by song_set_05F435
	.incbin	"sound/spc_data_1CD15E.lz"
	.byte	$E6, $10
	; CDL: read by decompress_chunk
spc_data_1CE6BD:
	; ASSET: compressed sound CPU data, $1C:E6BD-$1C:F57F (from its length word), loaded by song_set_05F450
	.incbin	"sound/spc_data_1CE6BD.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
