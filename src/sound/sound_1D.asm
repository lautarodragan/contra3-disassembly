; sound/sound_1D.asm -- Sound data (bank $1D, $8000-$AB9F)
; Bank $1D, $1D:8000-$1D:AB9F. Included by main.asm in segment BANK1D.
;
; Sound data uploaded to the sound CPU (read by upload_spc_raw_block).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).

	.byte	$00, $01
spc_block_1D8002:
	; ASSET: sound CPU data (uncompressed), $1D:8002-$1D:8101, uploaded by song_set_05F3AE
	.incbin	"sound/spc_block_1D8002.bin"
	.byte	$00, $01
spc_block_1D8104:
	; ASSET: sound CPU data (uncompressed), $1D:8104-$1D:8203, uploaded by song_set_05F3C9, song_set_05F4F8, song_set_05F51C (+1 more)
	.incbin	"sound/spc_block_1D8104.bin"
	.byte	$00, $01
spc_block_1D8206:
	; ASSET: sound CPU data (uncompressed), $1D:8206-$1D:8305, uploaded by song_set_05F3E4
	.incbin	"sound/spc_block_1D8206.bin"
	.byte	$00, $01
spc_block_1D8308:
	; ASSET: sound CPU data (uncompressed), $1D:8308-$1D:8407, uploaded by song_set_05F3FF
	.incbin	"sound/spc_block_1D8308.bin"
	.byte	$00, $01
spc_block_1D840A:
	; ASSET: sound CPU data (uncompressed), $1D:840A-$1D:8509, uploaded by song_set_05F41A
	.incbin	"sound/spc_block_1D840A.bin"
	.byte	$00, $01
spc_block_1D850C:
	; ASSET: sound CPU data (uncompressed), $1D:850C-$1D:860B, uploaded by song_set_05F435
	.incbin	"sound/spc_block_1D850C.bin"
	.byte	$00, $01
spc_block_1D860E:
	; ASSET: sound CPU data (uncompressed), $1D:860E-$1D:870D, uploaded by song_set_05F46B
	.incbin	"sound/spc_block_1D860E.bin"
	.byte	$90, $24
	; CDL: read by upload_spc_raw_block
spc_block_1D8710:
	; ASSET: sound CPU data (uncompressed), $1D:8710-$1D:AB9F, uploaded by song_set_05F46B
	.incbin	"sound/spc_block_1D8710.bin"
