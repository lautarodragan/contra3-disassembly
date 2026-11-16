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

	.byte	$96, $1E
spc_block_1E8002:
	; ASSET: sound CPU data (uncompressed), $1E:8002-$1E:9E97, uploaded by song_set_05F3AE
	.incbin	"sound/spc_block_1E8002.bin"
	.byte	$37, $26
spc_block_1E9E9A:
	; ASSET: sound CPU data (uncompressed), $1E:9E9A-$1E:C4D0, uploaded by song_set_05F3C9, song_set_05F4F8, song_set_05F51C (+1 more)
	.incbin	"sound/spc_block_1E9E9A.bin"
	.byte	$FD, $26
	; CDL: read by upload_spc_raw_block
spc_block_1EC4D3:
	; ASSET: sound CPU data (uncompressed), $1E:C4D3-$1E:EBCF, uploaded by song_set_05F3E4
	.incbin	"sound/spc_block_1EC4D3.bin"
	; CDL: read by decompress_chunk
gfx_1EEBD0:
	; ASSET: compressed graphics (VRAM), $1E:EBD0-$1E:EFA4 (from its length word), loaded by load_list_058976
	.incbin	"gfx/gfx_1EEBD0.lz"
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
