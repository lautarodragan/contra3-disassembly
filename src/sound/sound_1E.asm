; sound/sound_1E.asm -- Sound data (bank $1E)
; Bank $1E, $1E:8000-$1E:FFFF. Included by main.asm in segment BANK1E.
;
; Data uploaded to the sound CPU (read by upload_spc_raw_block, see
; sound/spc_upload.asm) and compressed graphics (decompress_chunk).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	.word	spc_samples_opening_size
spc_samples_opening:
	; ASSET: sound CPU data (uncompressed), $1E:8002-$1E:9E97, uploaded by song_set_opening
	; ARAM $B08E-$CF23: BRR samples of opening (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_opening.bin"
spc_samples_opening_size = * - spc_samples_opening
	.word	spc_samples_stage3_size
spc_samples_stage3:
	; ASSET: sound CPU data (uncompressed), $1E:9E9A-$1E:C4D0, uploaded by song_set_stage3, song_set_stage_clear_full, song_set_game_over_full (+1 more)
	; ARAM $B08E-$D6C4: BRR samples of stage 3 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage3.bin"
spc_samples_stage3_size = * - spc_samples_stage3
	.word	spc_samples_stage2_size
	; CDL: read by upload_spc_raw_block
spc_samples_stage2:
	; ASSET: sound CPU data (uncompressed), $1E:C4D3-$1E:EBCF, uploaded by song_set_stage2
	; ARAM $B08E-$D78A: BRR samples of stage 2 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage2.bin"
spc_samples_stage2_size = * - spc_samples_stage2
	; CDL: read by decompress_chunk
gfx_1EEBD0:
	; ASSET: compressed graphics (VRAM), $1E:EBD0-$1E:EFA4 (from its length word), loaded by load_list_058976
	.incbin	"gfx/gfx_1EEBD0.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
