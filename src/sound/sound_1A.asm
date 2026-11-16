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
spc_driver:
	; ASSET: compressed sound CPU data, $1A:8002-$1A:A5EB (from its length word), loaded by song_set_boot
	; ARAM $0200-$2FFF: the sound driver (SPC700 code, tables, sound effects) (book: Sound)
	.incbin	"sound/spc_driver.lz"
	.byte	$00, $20
spc_song_konami_logo:
	; ASSET: compressed sound CPU data, $1A:A5EE-$1A:A8C7 (from its length word), loaded by song_set_konami_logo
	; ARAM $3000-$4FFF: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_konami_logo.lz"
	.byte	$00, $01
spc_sample_dir_boot:
	; ASSET: sound CPU data (uncompressed), $1A:A8CA-$1A:A9C9, uploaded by song_set_boot
	; ARAM $5000-$50FF: sample directory (boot) (book: Sound)
	.incbin	"sound/spc_sample_dir_boot.bin"
	.byte	$D8, $12
spc_song_boss:
	; ASSET: sound CPU data (uncompressed), $1A:A9CC-$1A:BCA3, uploaded by song_set_boss_full
	; ARAM $3000-$42D7: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_boss.bin"
	.byte	$32, $02
spc_song_stage_clear:
	; ASSET: compressed sound CPU data, $1A:BCA6-$1A:BE81 (from its length word), loaded by song_set_stage_clear
	; ARAM $3000-$3231: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage_clear.lz"
	.byte	$28, $02
spc_song_game_over:
	; ASSET: compressed sound CPU data, $1A:BE84-$1A:C08A (from its length word), loaded by song_set_game_over
	; ARAM $3000-$3227: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_game_over.lz"
	.byte	$20, $0A
spc_song_opening:
	; ASSET: compressed sound CPU data, $1A:C08D-$1A:CA20 (from its length word), loaded by song_set_opening
	; ARAM $3000-$3A1F: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_opening.lz"
	.byte	$A6, $1F
	; CDL: read by upload_spc_raw_block
spc_song_heart_boss:
	; ASSET: sound CPU data (uncompressed), $1A:CA23-$1A:E9C8, uploaded by song_set_heart_boss_full
	; ARAM $3000-$4FA5: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_heart_boss.bin"
	; CDL: read by decompress_chunk
gfx_1AE9C9:
	; ASSET: compressed graphics (VRAM), $1A:E9C9-$1A:F381 (from its length word), loaded by load_list_058976
	.incbin	"gfx/gfx_1AE9C9.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
