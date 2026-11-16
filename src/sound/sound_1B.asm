; sound/sound_1B.asm -- Sound data (bank $1B)
; Bank $1B, $1B:8000-$1B:FFFF. Included by main.asm in segment BANK1B.
;
; Data uploaded to the sound CPU (read by upload_spc_raw_block, see
; sound/spc_upload.asm).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	; CDL: read by upload_spc_raw_block; partly not accessed
	.byte	$8E, $5F
spc_block_1B8002:
	; ASSET: sound CPU data (uncompressed), $1B:8002-$1B:DF8F, uploaded by song_set_05F55B
	.incbin	"sound/spc_block_1B8002.bin"
	.byte	$DC, $1D
	; CDL: read by upload_spc_raw_block
spc_block_1BDF92:
	; ASSET: sound CPU data (uncompressed), $1B:DF92-$1B:FD6D, uploaded by song_set_05F4C3
	.incbin	"sound/spc_block_1BDF92.bin"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
