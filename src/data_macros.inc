; Macros for the game's data formats, so that data with pointers reads as
; what it is and every pointer is a label (see the book, "Shiftability").

; ---------------------------------------------------------------------------
; Animation scripts (bank $05; OBJ_ANIM), run by update_objects.  A script is
; a list of frames of 3 words: the number of frames to show it, the
; metasprite (bank $06) shown when OBJ_FACING is 0 and the one shown
; otherwise.  Some objects never face the other way and keep other values
; in the third word.  A negative first word is a jump to that address (in
; bank $05), 0 ends the script (OBJ_ANIM = 0, the last sprite stays).
; ---------------------------------------------------------------------------
.macro anim_frame frames, sprite, sprite_facing
	.word	frames
	.addr	sprite, sprite_facing
.endmacro

.macro anim_goto script
	.addr	script
.endmacro

.macro anim_end
	.word	0
.endmacro

; ---------------------------------------------------------------------------
; Data lists (bank $05) for load_data_list (engine/gfx_loader.asm): a type
; byte (0 VRAM, 1 WRAM, 2 sound CPU, 3+ VRAM one byte of each word) and a
; flags byte (bit 0: load a chunk per frame), then entries, then $FFFF.
; Every stream is compressed in the format of engine/decompress.asm.
; ---------------------------------------------------------------------------
.macro load_list type, flags
	.byte	type, flags
.endmacro

.macro load_vram vram_address, stream
	.word	vram_address
	.faraddr	stream
.endmacro

.macro load_wram destination, stream
	.faraddr	destination, stream
.endmacro

.macro load_spc spc_address, stream
	.word	spc_address
	.faraddr	stream
.endmacro

; An uncompressed block of size bytes.
.macro load_spc_raw spc_address, block, size
	.word	$FFFE, spc_address
	.faraddr	block
	.word	size
.endmacro

.macro load_end
	.word	$FFFF
.endmacro
