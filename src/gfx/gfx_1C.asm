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
spc_song_stage3:
	; ASSET: compressed sound CPU data, $1C:8002-$1C:9778 (from its length word), loaded by song_set_stage3
	; ARAM $3000-$4BC5: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage3.lz"
	.byte	$CB, $1D
spc_song_stage2:
	; ASSET: compressed sound CPU data, $1C:977B-$1C:B139 (from its length word), loaded by song_set_stage2
	; ARAM $3000-$4DCA: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage2.lz"
	.byte	$AA, $0D
spc_song_stage1:
	; ASSET: compressed sound CPU data, $1C:B13C-$1C:BDE4 (from its length word), loaded by song_set_stage1
	; ARAM $3000-$3DA9: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage1.lz"
	.byte	$D8, $15
spc_song_stage4:
	; ASSET: compressed sound CPU data, $1C:BDE7-$1C:D15B (from its length word), loaded by song_set_stage4
	; ARAM $3000-$45D7: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage4.lz"
	.byte	$CB, $1D
spc_song_stage5:
	; ASSET: compressed sound CPU data, $1C:D15E-$1C:E6BA (from its length word), loaded by song_set_stage5
	; ARAM $3000-$4DCA: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage5.lz"
	.byte	$E6, $10
	; CDL: read by decompress_chunk
spc_song_stage6:
	; ASSET: compressed sound CPU data, $1C:E6BD-$1C:F57F (from its length word), loaded by song_set_stage6
	; ARAM $3000-$40E5: song (sequence data) (book: Sound)
	.incbin	"sound/spc_song_stage6.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
