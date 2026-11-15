; engine/palette_tasks.asm -- Palette tasks and VRAM script tasks
; Bank $00, $00:9971-$00:9C17. Included by main.asm in segment BANK00.
;
; Eight task slots of $10 bytes at $1200 (sub_009982/sub_009985 start one from
; a script in Y; run_palette_tasks runs them each frame through tbl_palette_task_types): copy
; palettes from bank $08 to the WRAM buffer, and fade them. run_vram_tasks runs a
; second kind of task (slots at $1280) that appends entries to the VRAM
; transfer list.

clear_palette_task:
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
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
	sta	$00,x
	iny
	sty	$02,x
	rtl

run_palette_tasks:
	rep	#$20
	rep	#$10
	ldx	#$1200
@loop:
	stx	zp_FC
	lda	$00,x
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
	lda	$08,x
	beq	@next_frame
	; (not executed in the CDL traces)
	dec	$08,x
	rtl
@next_frame:
	ldy	$02,x
	lda	a:$0000,y
	and	#$00FF
	sta	$08,x
@copy_entry:
	lda	$02,x
	clc
	adc	$06,x
	tay
	lda	a:$0002,y
	beq	@end_of_frames
	phb
	phx
	ldx	a:$0002,y
	lda	a:$0004,y
	tay
	lda	f:$080000,x
	inx
	inx
	mvn	#$08, #$7E
	plx
	plb
	lda	$06,x
	clc
	adc	#$0004
	sta	$06,x
	bra	palette_task_animate
@end_of_frames:
	inc	$04,x
	stz	$06,x
	ldy	$02,x
	lda	a:$0000,y
	bmi	@copy_entry
	xba
	and	#$00FF
	cmp	$04,x
	bcs	@copy_entry
	jmp	a:clear_palette_task

palette_task_darken:
	; (not executed in the CDL traces)
	ldy	$02,x
	lda	$04,x
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
	adc	$04,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	$04,x
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
	ldy	$02,x
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
	adc	$04,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	$04,x
	xba
	and	#$00FF
	bra	fade_palette_from_source

palette_task_fade_in:
	ldy	$02,x
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
	adc	$04,x
	cmp	#$2000
	bcc	@advance
	brl	clear_palette_task
@advance:
	sta	$04,x
	xba
	and	#$00FF
	eor	#$001F
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
	lda	#$08
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
	lda	#$05
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
	.byte	$A2, $80, $12

start_vram_task:
	; (not executed in the CDL traces)
	lda	a:$0000,y
	beq	@start
	lda	$00,x
	bne	@done
@start:
	jsl	f:clear_vram_task
	lda	a:$0000,y
	sta	$00,x
	lda	a:$0002,y
	sta	$02,x
	lda	#$0000
@done:
	rtl

clear_vram_task:
	; (not executed in the CDL traces)
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
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
	lda	$00,x
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
	lda	$08,x
	beq	@next_frame
	dec	$08,x
	rtl
@next_frame:
	lda	$02,x
	sta	zp_00
	lda	(zp_00)
	sta	$08,x
@next_entry:
	inc	$06,x
	inc	$06,x
	ldy	$06,x
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
	inc	$04,x
	stz	$06,x
	ldy	#$0002
	lda	(zp_00),y
	bmi	@next_entry
	cmp	$04,x
	bcs	@next_entry
	jmp	a:clear_vram_task
