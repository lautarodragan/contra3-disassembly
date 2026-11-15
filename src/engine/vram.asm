; engine/vram.asm -- VRAM transfer queue and VRAM helpers
; Bank $00, $00:8CFF-$00:90A7. Included by main.asm in segment BANK00.
;
; The VRAM queue: game code builds DMA transfers to VRAM during the frame and
; run_vram_queue (NMI) executes them. Entries are 11 bytes in $7E from
; VRAM_QUEUE ($7E:3000) up to vram_queue_end: +0 VMAIN, +2 DMAP/BBAD word,
; +4 VRAM word address, +6 source address and +8 bank, +9 size. The data
; usually goes to the buffer at VRAM_QUEUE_DATA ($7E:3400), filled through
; vram_queue_data_ptr: begin_vram_transfer (Y = VRAM address) opens an
; entry, push_vram_word appends data, end_vram_transfer sets the size.
; reset_vram_queue (in engine/irq.asm) empties the queue after it ran.
;
; draw_text / draw_text_attr write a text string through the queue (format
; below). reset_video_state turns the display off and resets PPU, VRAM, OAM,
; palette and loader state. The unused_* routines never ran in the traces.

; NMI: executes the queued transfers on DMA channel 0, then empties the
; queue (falls into reset_vram_queue).
run_vram_queue:
	ldx	#VRAM_QUEUE
@loop:
	cpx	vram_queue_end
	bcs	reset_vram_queue
	lda	f:$7E0004,x
	sta	a:VMADDL
	lda	f:$7E0006,x
	sta	a:A1T0L
	lda	f:$7E0009,x
	sta	a:DAS0L
	lda	f:$7E0002,x
	sta	a:DMAP0
	sep	#$20
	.a8
	lda	f:$7E0000,x
	sta	a:VMAIN
	lda	f:$7E0008,x
	sta	a:A1B0
	lda	#$01
	sta	a:MDMAEN
	rep	#$20
	.a16
	txa
	clc
	adc	#$000B
	tax
	bra	@loop

; Y = VRAM word address. Opens a queue entry (VMAIN $80: increment after the
; high byte, DMAP $01 to VMDATA) whose data starts at vram_queue_data_ptr.
begin_vram_transfer:
	lda	#$0080

; Same with A = VMAIN value ($81 for columns: increment by 32).
begin_vram_transfer_vmain:
	ldx	vram_queue_end
	sta	f:$7E0000,x
	tya
	sta	f:$7E0004,x
	lda	#$1801
	sta	f:$7E0002,x
	lda	vram_queue_data_ptr
	sta	f:$7E0006,x
	lda	#$007E
	sta	f:$7E0008,x
	txa
	clc
	adc	#$000B
	sta	vram_queue_end
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) Same for low bytes only (VMAIN 0, DMAP $00 to VMDATAL).
begin_vram_transfer_low:
	; (not executed in the CDL traces)
	ldx	vram_queue_end
	lda	#$0000
	sta	f:$7E0000,x
	tya
	sta	f:$7E0004,x
	lda	#$1800
	sta	f:$7E0002,x
	lda	vram_queue_data_ptr
	sta	f:$7E0006,x
	lda	#$007E
	sta	f:$7E0008,x
	txa
	clc
	adc	#$000B
	sta	vram_queue_end
	rtl

; (no caller found; decoded because it follows the end of a routine)
push_vram_byte:
	; (not executed in the CDL traces)
	phb
	sep	#$20
	.a8
	ldx	vram_queue_data_ptr
	sta	f:$7E0000,x
	inx
	stx	vram_queue_data_ptr
	rep	#$20
	.a16
	plb
	rtl

; Appends the word in A to the open transfer's data.
push_vram_word:
	ldx	vram_queue_data_ptr
	sta	f:$7E0000,x
	inx
	inx
	stx	vram_queue_data_ptr
	rtl

; Closes the last entry: its size = vram_queue_data_ptr - its source.
end_vram_transfer:
	ldx	vram_queue_end
	sec
	lda	vram_queue_data_ptr
	sbc	f:$7DFFFB,x
	sta	f:$7DFFFE,x
	rtl

; Display, NMI and DMA off; clears HDMA/IRQ modes, objects and OAM, palette
; and VRAM tasks, VRAM, the BG scroll state; re-initialises the PPU
; (init_ppu_registers) and the display (start_display).
reset_video_state:
	stz	hdma_preset
	stz	irq_mode
	lda	#$2200
	sta	cgram_dma_src
	lda	#$0004
	sta	force_blank_frames
	lda	#$0009
	sta	a:bgmode_shadow
	stz	a:mosaic_shadow
	lda	#VRAM_QUEUE
	sta	vram_queue_end
	lda	#VRAM_QUEUE_DATA
	sta	vram_queue_data_ptr
	jsl	f:disable_display_and_nmi
	sep	#$20
	.a8
	rep	#$10
	jsl	f:clear_objects_and_oam
	.a16
	jsl	f:clear_palette_tasks_and_buffer
	jsl	f:clear_vram_tasks
	jsl	f:clear_vram
	jsl	f:clear_bg_scroll_state
	sep	#$20
	.a8
	jsl	f:init_ppu_registers
	rep	#$20
	.a16
	jsl	f:start_display
	rep	#$20
	rtl

clear_vram:
	rep	#$10
	ldy	#$7FFF
	ldx	#$0000
	jsl	f:clear_vram_words
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_vram_0000_0fff:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$0FFF
	ldx	#$0000
	jsl	f:clear_vram_words
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_vram_1000_1fff:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$0FFF
	ldx	#$1000
	jsl	f:clear_vram_words
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_vram_5800_5bff:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$03FF
	ldx	#$5800
	jsl	f:clear_vram_words
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_vram_5800_5bff_2:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$03FF
	ldx	#$5800
	jsl	f:clear_vram_words
	rtl

; X = VRAM word address, Y = word count - 1: writes zeros.
clear_vram_words:
	rep	#$20
	lda	#$0000
	sta	zp_00
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	stx	a:VMADDL
	rep	#$20
	.a16
	lda	zp_00
@loop:
	sta	a:VMDATAL
	dey
	bpl	@loop
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) Builds a Mode 7 tilemap (low bytes) from a map of 4x4
; metatiles at $7E:6000 and metatile data at $7E:4000, 4 rows at a time
; through $7E:3400; sets BGMODE 7.
unused_build_mode7_tilemap:
	; (not executed in the CDL traces)
	ldx	#$6000
	ldy	#$4000
	stx	zp_08
	sty	zp_0A
	stz	a:VMADDL
	sep	#$10
	.i8
	ldx	#$00
	stx	a:VMAIN
	rep	#$10
	.i16
	lda	#$0004
	sta	zp_12
	sta	zp_14
	lda	#$0008
	sta	zp_16
	lda	#$3400
	sta	zp_0C
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
@loop:
	.a16
	jsl	f:unused_mode7_map_row
	lda	zp_08
	clc
	adc	#$0080
	sta	zp_08
	dec	zp_12
	bne	@loop
	jsl	f:unused_dma_mode7_map_rows
	lda	#$3400
	sta	zp_0C
	lda	zp_08
	sec
	sbc	#$01F0
	sta	zp_08
	lda	#$0004
	sta	zp_12
	dec	zp_16
	bne	@loop
	lda	#$0008
	sta	zp_16
	lda	zp_08
	clc
	adc	#$0380
	sta	zp_08
	dec	zp_14
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	lda	#$0007
	sta	a:bgmode_shadow
	rtl

unused_mode7_map_row:
	; (not executed in the CDL traces)
	ldy	zp_08
	lda	a:$0000,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$0002,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$0004,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$0006,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$0008,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$000A,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$000C,y
	and	#$00FF
	jsl	f:unused_mode7_put_metatile
	ldy	zp_08
	lda	a:$000E,y
	and	#$00FF
	jml	f:unused_mode7_put_metatile

unused_dma_mode7_map_rows:
	; (not executed in the CDL traces)
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	sep	#$10
	.i8
	lda	#$1800
	sta	a:DMAP0
	ldx	#$7E
	stx	a:A1B0
	lda	#$0200
	sta	a:DAS0L
	lda	#$3400
	sta	a:A1T0L
	ldx	#$01
	stx	a:MDMAEN
	rep	#$10
	.i16
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	rtl

unused_mode7_put_metatile:
	; (not executed in the CDL traces)
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	zp_0A
	tay
	sep	#$20
	.a8
	ldx	zp_0C
	lda	a:$0000,y
	sta	a:$0000,x
	lda	a:$0002,y
	sta	a:$0001,x
	lda	a:$0004,y
	sta	a:$0002,x
	lda	a:$0006,y
	sta	a:$0003,x
	lda	a:$0008,y
	sta	a:$0080,x
	lda	a:$000A,y
	sta	a:$0081,x
	lda	a:$000C,y
	sta	a:$0082,x
	lda	a:$000E,y
	sta	a:$0083,x
	lda	a:$0010,y
	sta	a:$0100,x
	lda	a:$0012,y
	sta	a:$0101,x
	lda	a:$0014,y
	sta	a:$0102,x
	lda	a:$0016,y
	sta	a:$0103,x
	lda	a:$0018,y
	sta	a:$0180,x
	lda	a:$001A,y
	sta	a:$0181,x
	lda	a:$001C,y
	sta	a:$0182,x
	lda	a:$001E,y
	sta	a:$0183,x
	rep	#$20
	.a16
	txa
	clc
	adc	#$0004
	sta	zp_0C
	rtl

; (no caller found; decoded because it follows the end of a routine)
; (No caller.) Typewriter text: X = string; draws the first character and
; leaves the rest for unused_typewriter_step (one character per call), using
; typewriter_ptr / typewriter_vram_addr / typewriter_attr.
unused_start_typewriter_text:
	; (not executed in the CDL traces)
	stx	typewriter_ptr
	inc	typewriter_active
	jsl	f:draw_text
	bra	typewriter_done

; (no caller found; decoded because it follows the end of a routine)
unused_typewriter_step:
	; (not executed in the CDL traces)
	ldx	typewriter_ptr
	beq	typewriter_done
	jsl	f:begin_vram_transfer
	rep	#$20
	lda	typewriter_vram_addr
	jsl	f:push_vram_word
	lda	typewriter_attr
	ldx	typewriter_ptr
	inc	typewriter_active
	jsl	f:unused_draw_text_continue
	lda	typewriter_active
	bne	typewriter_done
	stz	typewriter_ptr
typewriter_done:
	stz	typewriter_active
	rtl

; A = tile attributes (high byte bits), X = string (bank $05). See draw_text.
draw_text_attr:
	sta	zp_04
	lda	#$0001
	sta	zp_02
	bra	draw_text_common

; (no caller found; decoded because it follows the end of a routine)
unused_draw_text_continue:
	; (not executed in the CDL traces)
	stz	zp_02
	sta	zp_04
	bra	draw_text_common

; X = string in bank $05, written to the VRAM queue with attributes $2000
; (priority). Format: a VRAM word address, then tile numbers (bytes); $FD n:
; attribute high byte becomes n; $FE: a new VRAM address word follows (next
; line); $FF: end. With text_erase set, every tile is written as 0 (the
; string is erased) and text_erase is cleared.
; In the font, tile $00 is a space, $01-$0A the digits 0-9, $0B P, $3C-$4A
; A-O and $4C-$54 R-Z; the strings' labels (text_stage_1 ...) spell them.
draw_text:
	lda	#$0001
	sta	zp_02
	bra	@default_attr
	; CDL: not accessed
	.byte	$64, $02
@default_attr:
	lda	#$2000
	sta	zp_04
draw_text_common:
	stx	zp_00
	lda	zp_02
	beq	@next_char
@new_line:
	ldx	zp_00
	ldy	a:$0000,x
	inx
	inx
	stx	zp_00
	jsl	f:begin_vram_transfer
	lda	typewriter_active
	beq	@no_typewriter
	; (not executed in the CDL traces)
	sty	typewriter_vram_addr
@no_typewriter:
	stz	zp_02
@next_char:
	ldx	zp_00
	lda	a:$0000,x
	inx
	stx	zp_00
	and	#$00FF
	cmp	#$00FF
	beq	@end
	cmp	#$00FE
	beq	@end_line
	cmp	#$00FD
	beq	@set_attr
	ldy	text_erase
	beq	@put_tile
	lda	#$0000
@put_tile:
	ora	zp_04
	jsl	f:push_vram_word
	lda	typewriter_active
	beq	@next_char
	; (not executed in the CDL traces)
	ldx	zp_00
	stx	typewriter_ptr
	lda	zp_04
	sta	typewriter_attr
	inc	typewriter_vram_addr
	lda	a:$0000,x
	and	#$00FF
	cmp	#$00FF
	beq	@end
	bra	@close
@set_attr:
	lda	a:$0000,x
	inx
	stx	zp_00
	sta	zp_05
	bra	@next_char
@end_line:
	jsl	f:end_vram_transfer
	bra	@new_line
@end:
	stz	text_erase
	stz	typewriter_active
@close:
	jsl	f:end_vram_transfer
	rtl
