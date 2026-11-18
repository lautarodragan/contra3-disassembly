; engine/palette_tasks.asm -- Palette tasks and VRAM script tasks
; Bank $00, $00:9971-$00:9C17. Included by main.asm in segment BANK00.
;
; Palette tasks: 8 slots of $10 bytes at palette_tasks ($1200, TASK_*
; fields). start_palette_task (slot $1200) / start_palette_task_at (X = slot)
; start one from a script in Y (bank $05) whose first byte is the type;
; run_palette_tasks runs them every frame through tbl_palette_task_types.
; They work on the palette buffer in $7E (the copy at $7E:2200 is DMAd to
; CGRAM every frame):
;
;   1  palette_task_animate   script: delay byte, repeat byte (bit 7: loop
;                             forever), then {source in bank $08, destination
;                             in $7E} pairs, 0 = end; one pair is copied every
;                             delay+1 frames; a source block is {size-1 word,
;                             colours}
;   2  palette_task_darken    (never run) darkens a range by one step per level
;   3  palette_task_fade_in   script: speed byte (0 = 16), source (bank $08)
;   4  palette_task_fade_out  and destination words; each colour component is
;                             the source's minus the level (fade in: 31 - level)
;
; The level advances by speed/16 per frame; the task ends at level 32.
;
; VRAM tasks: slots at vram_tasks ($1280), half of them run on each frame by
; run_vram_tasks; type 1 (vram_task_script, never run in the traces) copies
; lists of VRAM queue entries into the queue on a timed script.

clear_palette_task:
	stz	TASK_TYPE,x
	stz	TASK_SCRIPT,x
	stz	TASK_PROGRESS,x
	stz	TASK_ENTRY,x
	stz	TASK_DELAY,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	rtl

start_palette_task:
	ldx	#$1200

start_palette_task_at:
	jsl	f:clear_palette_task
	lda	a:$0000,y
	and	#$00FF
	sta	TASK_TYPE,x
	iny
	sty	TASK_SCRIPT,x
	rtl

run_palette_tasks:
	rep	#$20
	rep	#$10
	ldx	#$1200
@loop:
	stx	zp_FC
	lda	TASK_TYPE,x
	beq	@next
	jsl	f:call_palette_task
@next:
	lda	zp_FC
	clc
	adc	#$0010
	tax
	cpx	#$1280
	bcc	@loop
	rtl

call_palette_task:
	dec	a
	phx
	asl	a
	tax
	lda	f:tbl_palette_task_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_palette_task_types:
	.addr	palette_task_animate
	.addr	palette_task_darken
	.addr	palette_task_fade_in
	.addr	palette_task_fade_out

palette_task_animate:
	lda	TASK_DELAY,x
	beq	@next_frame
	; (not executed in the CDL traces)
	dec	TASK_DELAY,x
	rtl
@next_frame:
	ldy	TASK_SCRIPT,x
	lda	a:$0000,y
	and	#$00FF
	sta	TASK_DELAY,x
@copy_entry:
	lda	TASK_SCRIPT,x
	clc
	adc	TASK_ENTRY,x
	tay
	lda	a:$0002,y
	beq	@end_of_frames
	phb
	phx
	ldx	a:$0002,y
	lda	a:$0004,y
	tay
	lda	f:GFX_08_BASE,x
	inx
	inx
	mvn	#^gfx_08, #$7E
	plx
	plb
	lda	TASK_ENTRY,x
	clc
	adc	#$0004
	sta	TASK_ENTRY,x
	bra	palette_task_animate
@end_of_frames:
	inc	TASK_PROGRESS,x
	stz	TASK_ENTRY,x
	ldy	TASK_SCRIPT,x
	lda	a:$0000,y
	bmi	@copy_entry
	xba
	and	#$00FF
	cmp	TASK_PROGRESS,x
	bcs	@copy_entry
	jmp	a:clear_palette_task

palette_task_darken:
	; (not executed in the CDL traces)
	ldy	TASK_SCRIPT,x
	lda	TASK_PROGRESS,x
	xba
	and	#$00FF
	sta	zp_04
	lda	a:$0000,y
	and	#$00FF
	bne	@speed_ok
	lda	#$0010
@speed_ok:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	TASK_PROGRESS,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	TASK_PROGRESS,x
	xba
	and	#$00FF
	sec
	sbc	zp_04
	beq	@done
	sta	zp_02
@step:
	jsl	f:darken_palette_range
	dec	zp_02
	bne	@step
@done:
	rtl

; (Never run.) Script +1/+3: start and end address in $7E; subtracts 1 from
; every non-zero component.
darken_palette_range:
	; (not executed in the CDL traces)
	lda	a:$0003,y
	sta	zp_00
	ldx	a:$0001,y
@loop:
	sec
	lda	f:$7E0000,x
	bit	#$001F
	beq	@green
	dec	a
@green:
	bit	#$03E0
	beq	@blue
	sbc	#$0020
@blue:
	bit	#$7C00
	beq	@store
	sbc	#$0400
@store:
	sta	f:$7E0000,x
	inx
	inx
	cpx	zp_00
	bcc	@loop
	rtl

palette_task_fade_out:
	ldy	TASK_SCRIPT,x
	lda	a:$0000,y
	and	#$00FF
	bne	@speed_ok
	; (not executed in the CDL traces)
	lda	#$0010
@speed_ok:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	TASK_PROGRESS,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	TASK_PROGRESS,x
	xba
	and	#$00FF
	bra	fade_palette_from_source

palette_task_fade_in:
	ldy	TASK_SCRIPT,x
	lda	a:$0000,y
	and	#$00FF
	bne	@speed_ok
	; (not executed in the CDL traces)
	lda	#$0010
@speed_ok:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	TASK_PROGRESS,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	TASK_PROGRESS,x
	xba
	and	#$00FF
	eor	#$001F
; Y = script, A = level (0-31): writes source colours minus level per
; component (clamped at 0) to the destination in $7E.
fade_palette_from_source:
	sta	zp_08
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_0A
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_0C
	ldx	a:$0003,y
	lda	a:$0001,y
	tay
	sep	#$20
	.a8
	lda	#^gfx_08
	pha
	plb
	rep	#$20
	.a16
	lda	a:$0000,y
	sta	zp_02
@loop:
	lda	a:$0002,y
	and	#$001F
	sec
	sbc	zp_08
	bpl	@green
	lda	#$0000
@green:
	sta	zp_00
	lda	a:$0002,y
	and	#$03E0
	sec
	sbc	zp_0A
	bpl	@blue
	lda	#$0000
@blue:
	ora	zp_00
	sta	zp_00
	lda	a:$0002,y
	and	#$7C00
	sec
	sbc	zp_0C
	bpl	@store
	lda	#$0000
@store:
	ora	zp_00
	sta	f:$7E0000,x
	inx
	inx
	iny
	iny
	dec	zp_02
	dec	zp_02
	bpl	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

; (no caller found; decoded because it follows the end of a routine)
unused_start_vram_task_linked:
	; (not executed in the CDL traces)
	jsl	f:start_vram_task
	bne	@done
	ldy	zp_FC
	sty	$0A,x
	lda	a:$0010,y
	sta	$0C,x
@done:
	rtl
	; CDL: not accessed
	; Unreachable (after an rtl, no label): the bytes of `ldx #$1280`, a
	; leftover instruction (book: What the traces never touched).
	.byte	$A2, $80, $12

start_vram_task:
	; (not executed in the CDL traces)
	lda	a:$0000,y
	beq	@start
	lda	TASK_TYPE,x
	bne	@done
@start:
	jsl	f:clear_vram_task
	lda	a:$0000,y
	sta	TASK_TYPE,x
	lda	a:$0002,y
	sta	TASK_SCRIPT,x
	lda	#$0000
@done:
	rtl

clear_vram_task:
	; (not executed in the CDL traces)
	stz	TASK_TYPE,x
	stz	TASK_SCRIPT,x
	stz	TASK_PROGRESS,x
	stz	TASK_ENTRY,x
	stz	TASK_DELAY,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	rtl

run_vram_tasks:
	ldx	#$1280
	lda	frame_counter
	lsr	a
	bcs	@loop
	ldx	#$1290
@loop:
	stx	zp_FC
	lda	TASK_TYPE,x
	beq	@next
	; (not executed in the CDL traces)
	jsl	f:call_vram_task
@next:
	clc
	lda	zp_FC
	adc	#$0020
	tax
	cpx	#$1300
	bcc	@loop
	rtl

call_vram_task:
	; (not executed in the CDL traces)
	dec	a
	phx
	asl	a
	tax
	lda	f:tbl_vram_task_types,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_vram_task_types:
	.addr	vram_task_script

vram_task_script:
	; (not executed in the CDL traces)
	lda	TASK_DELAY,x
	beq	@next_frame
	dec	TASK_DELAY,x
	rtl
@next_frame:
	lda	TASK_SCRIPT,x
	sta	zp_00
	lda	(zp_00)
	sta	TASK_DELAY,x
@next_entry:
	inc	TASK_ENTRY,x
	inc	TASK_ENTRY,x
	ldy	TASK_ENTRY,x
	iny
	iny
	lda	(zp_00),y
	beq	@end_of_frames
	ldx	vram_queue_end
	tay
@copy_loop:
	lda	a:$0000,y
	beq	@entry_done
	sta	f:$7E0000,x
	lda	a:$0002,y
	sta	f:$7E0002,x
	lda	a:$0004,y
	sta	f:$7E0004,x
	lda	a:$0006,y
	sta	f:$7E0006,x
	lda	a:$0008,y
	sta	f:$7E0008,x
	lda	a:$0009,y
	sta	f:$7E0009,x
	tya
	clc
	adc	#$000B
	tay
	txa
	clc
	adc	#$000B
	tax
	bra	@copy_loop
@entry_done:
	stx	vram_queue_end
	ldx	zp_FC
	bra	vram_task_script
@end_of_frames:
	inc	TASK_PROGRESS,x
	stz	TASK_ENTRY,x
	ldy	#$0002
	lda	(zp_00),y
	bmi	@next_entry
	cmp	TASK_PROGRESS,x
	bcs	@next_entry
	jmp	a:clear_vram_task
