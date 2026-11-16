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
spc_samples_common:
	; ASSET: sound CPU data (uncompressed), $1B:8002-$1B:DF8F, uploaded by song_set_boot
	; ARAM $5100-$B08D: BRR samples shared by every set (sources 0-19) (book: Sound)
	.incbin	"sound/spc_samples_common.bin"
	.byte	$DC, $1D
	; CDL: read by upload_spc_raw_block
spc_song_ending:
	; ASSET: sound CPU data (uncompressed), $1B:DF92-$1B:FD6D, uploaded by song_set_ending
	; ARAM $3000-$4DDB: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_ending.bin"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
