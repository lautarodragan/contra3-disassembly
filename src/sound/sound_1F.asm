; sound/sound_1F.asm -- Sound data (bank $1F)
; Bank $1F, $1F:8000-$1F:FFFF. Included by main.asm in segment BANK1F.
;
; Data uploaded to the sound CPU (read by upload_spc_raw_block, see
; sound/spc_upload.asm) and compressed graphics (decompress_chunk).
;
; Data only (no code). The labels name the compressed streams and blocks that
; the data lists in data/tables_05.asm point to; "; ASSET:" marks a block whose
; bounds are exact and that holds no pointers; such blocks (and the WRAM
; streams) are binary files in assets/, included with .incbin (book: Assets).
; Other blocks start at a CDL comment.

	.byte	$44, $25
spc_samples_stage1:
	; ASSET: sound CPU data (uncompressed), $1F:8002-$1F:A545, uploaded by song_set_stage1
	; ARAM $B08E-$D5D1: BRR samples of stage 1 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage1.bin"
	.byte	$78, $21
spc_samples_stage4:
	; ASSET: sound CPU data (uncompressed), $1F:A548-$1F:C6BF, uploaded by song_set_stage4
	; ARAM $B08E-$D205: BRR samples of stage 4 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage4.bin"
	.byte	$93, $21
	; CDL: read by upload_spc_raw_block
spc_samples_stage5:
	; ASSET: sound CPU data (uncompressed), $1F:C6C2-$1F:E854, uploaded by song_set_stage5
	; ARAM $B08E-$D220: BRR samples of stage 5 (sources 20-23) (book: Sound)
	.incbin	"sound/spc_samples_stage5.bin"
	; CDL: read by decompress_chunk
gfx_1FE855:
	; ASSET: compressed graphics (VRAM), $1F:E855-$1F:FFB1 (from its length word), loaded by load_list_058976
	.incbin	"gfx/gfx_1FE855.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
