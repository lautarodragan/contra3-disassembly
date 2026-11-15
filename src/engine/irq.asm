; engine/irq.asm -- HDMA channel setup and IRQ handler
; Bank $00, $00:8BA7-$00:8CFE. Included by main.asm in segment BANK00.
;
; setup_hdma_channels (from nmi_frame_default) programs the HDMA channels
; from the preset hdma_preset (data_05822E). irq (also the COP/BRK/ABORT
; vector) acknowledges TIMEUP, masks the H/V IRQ in NMITIMEN and dispatches
; on irq_mode through tbl_irq_handlers. The two handlers serve the two-player
; split screen of the top-down stages: irq_mode7_top_view loads player 1's
; Mode 7 matrix and BG1 scroll ($1FA4-$1FB3) and, when m7_split_screen is set,
; schedules irq_mode7_bottom_view at line $70, which loads player 2's
; ($1FE4-$1FF3).
; reset_vram_queue (end of the file) belongs to engine/vram.asm.

; hdma_preset = 0: just HDMAEN = 0. Otherwise the preset's list in bank $05
; (pointer at data_05822E + 2*preset): 7-byte entries {channel register
; base $43x0, DMAP/BBAD word, table address (3 bytes)}, ended by $FFFF and
; the HDMAEN value.
setup_hdma_channels:
	sep	#$20
	.a8
	stz	a:HDMAEN
	rep	#$30
	.a16
	lda	hdma_preset
	bne	@setup
	rtl
@setup:
	asl	a
	tax
	ldy	a:data_05822E,x
@loop:
	ldx	a:$0000,y
	cpx	#$FFFF	; [num]
	bcs	@done
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	tya
	clc
	adc	#$0007
	tay
	bra	@loop
@done:
	sep	#$20
	.a8
	lda	a:$0002,y
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl

irq:
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	phx
	phy
	pha
	phd
	phb
	sep	#$20
	.a8
	ldx	#$0000
	phx
	pld
	lda	#^tables_05
	pha
	plb
	lda	a:TIMEUP
	lda	a:nmitimen_shadow
	and	#$CF
	sta	a:NMITIMEN
	rep	#$20
	.a16
	ldx	irq_mode
	jsr	(.loword(tbl_irq_handlers),x)
	.a8
	rep	#$30
	.a16
	plb
	pld
	pla
	ply
	plx
	rti
tbl_irq_handlers:
	.addr	irq_none
	.addr	irq_mode7_top_view
	.addr	irq_mode7_bottom_view

irq_none:
	; (not executed in the CDL traces)
	rts

irq_mode7_top_view:
	sep	#$20
	.a8
	lda	a:p1_m7a
	sta	a:M7A
	lda	a:p1_m7a_hi
	sta	a:M7A
	lda	a:p1_m7b
	sta	a:M7B
	lda	a:p1_m7b_hi
	sta	a:M7B
	lda	a:p1_m7c
	sta	a:M7C
	lda	a:p1_m7c_hi
	sta	a:M7C
	lda	a:p1_m7d
	sta	a:M7D
	lda	a:p1_m7d_hi
	sta	a:M7D
	lda	a:p1_m7x
	sta	a:M7X
	lda	a:p1_m7x_hi
	sta	a:M7X
	lda	a:p1_m7y
	sta	a:M7Y
	lda	a:p1_m7y_hi
	sta	a:M7Y
	lda	a:p1_bg1hofs
	sta	a:BG1HOFS
	lda	a:p1_bg1hofs_hi
	sta	a:BG1HOFS
	lda	a:p1_bg1vofs
	sta	a:BG1VOFS
	lda	a:p1_bg1vofs_hi
	sta	a:BG1VOFS
	ldx	m7_split_screen
	beq	@done
	ldx	#$0070
	stx	a:VTIMEL
	ldx	#$0004
	stx	irq_mode
	lda	#$A1
	sta	a:NMITIMEN
@done:
	rts

irq_mode7_bottom_view:
	.a16
	sep	#$20
	.a8
	lda	a:p2_m7a
	sta	a:M7A
	lda	a:p2_m7a_hi
	sta	a:M7A
	lda	a:p2_m7b
	sta	a:M7B
	lda	a:p2_m7b_hi
	sta	a:M7B
	lda	a:p2_m7c
	sta	a:M7C
	lda	a:p2_m7c_hi
	sta	a:M7C
	lda	a:p2_m7d
	sta	a:M7D
	lda	a:p2_m7d_hi
	sta	a:M7D
	lda	a:p2_m7x
	sta	a:M7X
	lda	a:p2_m7x_hi
	sta	a:M7X
	lda	a:p2_m7y
	sta	a:M7Y
	lda	a:p2_m7y_hi
	sta	a:M7Y
	lda	a:p2_bg1hofs
	sta	a:BG1HOFS
	lda	a:p2_bg1hofs_hi
	sta	a:BG1HOFS
	lda	a:p2_bg1vofs
	sta	a:BG1VOFS
	lda	a:p2_bg1vofs_hi
	sta	a:BG1VOFS
	ldx	#$0002
	stx	irq_mode
	rts
; Empties the VRAM DMA queue (vram_queue_end, vram_queue_data_ptr).
reset_vram_queue:
	.a16
	lda	#VRAM_QUEUE
	sta	vram_queue_end
	lda	#VRAM_QUEUE_DATA
	sta	vram_queue_data_ptr
	rtl
