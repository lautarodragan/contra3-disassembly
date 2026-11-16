; sound/sound_1A.asm -- Sound data (bank $1A)
; Bank $1A, $1A:8000-$1A:FFFF. Included by main.asm in segment BANK1A.
;
; Data uploaded to the sound CPU (read by upload_spc_raw_block, see
; sound/spc_upload.asm) and compressed graphics (decompress_chunk).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	.byte	$00, $2E
spc_data_1A8002:
	; ASSET: compressed sound CPU data, $1A:8002-$1A:A5EB (from its length word), loaded by song_set_05F55B
	.incbin	"sound/spc_data_1A8002.lz"
	.byte	$00, $20
spc_data_1AA5EE:
	; ASSET: compressed sound CPU data, $1A:A5EE-$1A:A8C7 (from its length word), loaded by song_set_05F537
	.incbin	"sound/spc_data_1AA5EE.lz"
	.byte	$00, $01
spc_block_1AA8CA:
	; ASSET: sound CPU data (uncompressed), $1A:A8CA-$1A:A9C9, uploaded by song_set_05F55B
	.incbin	"sound/spc_block_1AA8CA.bin"
	.byte	$D8, $12
spc_block_1AA9CC:
	; ASSET: sound CPU data (uncompressed), $1A:A9CC-$1A:BCA3, uploaded by song_set_05F46B
	.incbin	"sound/spc_block_1AA9CC.bin"
	.byte	$32, $02
spc_data_1ABCA6:
	; ASSET: compressed sound CPU data, $1A:BCA6-$1A:BE81 (from its length word), loaded by song_set_05F4EF
	.incbin	"sound/spc_data_1ABCA6.lz"
	.byte	$28, $02
spc_data_1ABE84:
	; ASSET: compressed sound CPU data, $1A:BE84-$1A:C08A (from its length word), loaded by song_set_05F513
	.incbin	"sound/spc_data_1ABE84.lz"
	.byte	$20, $0A
spc_data_1AC08D:
	; ASSET: compressed sound CPU data, $1A:C08D-$1A:CA20 (from its length word), loaded by song_set_05F3AE
	.incbin	"sound/spc_data_1AC08D.lz"
	.byte	$A6, $1F
	; CDL: read by upload_spc_raw_block
spc_block_1ACA23:
	; ASSET: sound CPU data (uncompressed), $1A:CA23-$1A:E9C8, uploaded by song_set_05F4A4
	.incbin	"sound/spc_block_1ACA23.bin"
	; CDL: read by decompress_chunk
gfx_1AE9C9:
	; ASSET: compressed graphics (VRAM), $1A:E9C9-$1A:F381 (from its length word), loaded by load_list_058976
	.incbin	"gfx/gfx_1AE9C9.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
