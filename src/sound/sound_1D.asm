; sound/sound_1D.asm -- Sound data (bank $1D, $8000-$AB9F)
; Bank $1D, $1D:8000-$1D:AB9F. Included by main.asm in segment BANK1D.
;
; Sound data uploaded to the sound CPU (read by upload_spc_raw_block).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).

	.word	spc_sample_dir_opening_size
spc_sample_dir_opening:
	; ASSET: sound CPU data (uncompressed), $1D:8002-$1D:8101, uploaded by song_set_opening
	; ARAM $5000-$50FF: sample directory (opening) (book: Sound)
	.incbin	"sound/spc_sample_dir_opening.bin"
spc_sample_dir_opening_size = * - spc_sample_dir_opening
	.word	spc_sample_dir_stage3_size
spc_sample_dir_stage3:
	; ASSET: sound CPU data (uncompressed), $1D:8104-$1D:8203, uploaded by song_set_stage3, song_set_stage_clear_full, song_set_game_over_full (+1 more)
	; ARAM $5000-$50FF: sample directory (stage 3) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage3.bin"
spc_sample_dir_stage3_size = * - spc_sample_dir_stage3
	.word	spc_sample_dir_stage2_size
spc_sample_dir_stage2:
	; ASSET: sound CPU data (uncompressed), $1D:8206-$1D:8305, uploaded by song_set_stage2
	; ARAM $5000-$50FF: sample directory (stage 2) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage2.bin"
spc_sample_dir_stage2_size = * - spc_sample_dir_stage2
	.word	spc_sample_dir_stage1_size
spc_sample_dir_stage1:
	; ASSET: sound CPU data (uncompressed), $1D:8308-$1D:8407, uploaded by song_set_stage1
	; ARAM $5000-$50FF: sample directory (stage 1) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage1.bin"
spc_sample_dir_stage1_size = * - spc_sample_dir_stage1
	.word	spc_sample_dir_stage4_size
spc_sample_dir_stage4:
	; ASSET: sound CPU data (uncompressed), $1D:840A-$1D:8509, uploaded by song_set_stage4
	; ARAM $5000-$50FF: sample directory (stage 4) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage4.bin"
spc_sample_dir_stage4_size = * - spc_sample_dir_stage4
	.word	spc_sample_dir_stage5_size
spc_sample_dir_stage5:
	; ASSET: sound CPU data (uncompressed), $1D:850C-$1D:860B, uploaded by song_set_stage5
	; ARAM $5000-$50FF: sample directory (stage 5) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage5.bin"
spc_sample_dir_stage5_size = * - spc_sample_dir_stage5
	.word	spc_sample_dir_stage6_size
spc_sample_dir_stage6:
	; ASSET: sound CPU data (uncompressed), $1D:860E-$1D:870D, uploaded by song_set_boss_full
	; ARAM $5000-$50FF: sample directory (stage 6) (book: Sound)
	.incbin	"sound/spc_sample_dir_stage6.bin"
spc_sample_dir_stage6_size = * - spc_sample_dir_stage6
	.word	spc_samples_stage6_size
	; CDL: read by upload_spc_raw_block
spc_samples_stage6:
	; ASSET: sound CPU data (uncompressed), $1D:8710-$1D:AB9F, uploaded by song_set_boss_full
	; ARAM $B08E-$D51D: BRR samples of stage 6 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage6.bin"
spc_samples_stage6_size = * - spc_samples_stage6
