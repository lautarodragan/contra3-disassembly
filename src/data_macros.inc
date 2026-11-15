; Macros for the game's data formats, so that data with pointers reads as
; what it is and every pointer is a label (see the book, "Shiftability").

; ---------------------------------------------------------------------------
; Animation scripts (bank $05; OBJ_ANIM), run by update_objects.  A script is
; a list of frames of 3 words: the number of frames to show it, the
; metasprite (bank $06) shown when OBJ_FACING is 0 and the one shown
; otherwise.  Some objects never face the other way and keep other values
; in the third word.  A frame of 0 ends the script: its sprites are shown
; and OBJ_ANIM becomes 0.  A negative word (one word, no sprites) jumps to
; that address in bank $05.
; The items of the top-down stages (animate_td_item) use the same format with
; metasprites in bank $07 and OAM attributes in the third word.
; ---------------------------------------------------------------------------
.macro anim_frame frames, sprite, sprite_facing
	.word	frames
	.addr	sprite, sprite_facing
.endmacro

.macro anim_goto script
	.addr	script
.endmacro

.macro anim_end sprite, sprite_facing
	.word	0
	.addr	sprite, sprite_facing
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

; ---------------------------------------------------------------------------
; Player frames (player_frames, 16 bytes per pose; set_player_frame): the
; addresses in bank $7F of the six blocks of the player's tiles that the NMI
; copies to VRAM, then the metasprite (bank $06) for OBJ_FACING 0 and the
; one for the other facing.
; ---------------------------------------------------------------------------
.macro player_frame tiles0, tiles1, tiles2, tiles3, tiles4, tiles5, sprite, sprite_facing
	.word	tiles0, tiles1, tiles2, tiles3, tiles4, tiles5
	.addr	sprite, sprite_facing
.endmacro

; ---------------------------------------------------------------------------
; Palette task scripts (bank $05; start_palette_task, engine/palette_tasks.asm).
; The palettes they copy are in bank $08: a word (number of bytes - 1), then
; the colours.
; ---------------------------------------------------------------------------
; Type 1: every delay+1 frames, copies the next palette of the list to the
; buffer in $7E; repeat times through the list (bit 7: forever).
.macro palette_animate delay, repeat
	.byte	1, delay, repeat
.endmacro

.macro palette_copy palette, destination
	.addr	palette
	.word	destination
.endmacro

.macro palette_copy_end
	.word	0
.endmacro

; Types 3 and 4: fades the colours of palette in (from black) or out at
; destination in $7E; speed 0 = 16 (1/16 level per frame per unit).
.macro palette_fade_in speed, palette, destination
	.byte	3, speed
	.addr	palette
	.word	destination
.endmacro

.macro palette_fade_out speed, palette, destination
	.byte	4, speed
	.addr	palette
	.word	destination
.endmacro
