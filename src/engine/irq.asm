; engine/irq.asm -- HDMA channel setup and IRQ handler
; Bank $00, $00:8BA7-$00:8CFE. Included by main.asm in segment BANK00.
;
; setup_hdma_channels (called from NMI) sets up the HDMA channels from the list
; selected by $46 (data_05822E). irq (also the COP/BRK/ABORT vector)
; dispatches through tbl_irq_handlers to the raster handlers; irq_mode7_top_view and
; irq_mode7_bottom_view write the Mode 7 matrix and scroll registers mid-frame.

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
	cpx	#$FFFF
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
	lda	#$05
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
	lda	a:wram_1FA4
	sta	a:M7A
	lda	a:wram_1FA5
	sta	a:M7A
	lda	a:wram_1FA6
	sta	a:M7B
	lda	a:wram_1FA7
	sta	a:M7B
	lda	a:wram_1FA8
	sta	a:M7C
	lda	a:wram_1FA9
	sta	a:M7C
	lda	a:wram_1FAA
	sta	a:M7D
	lda	a:wram_1FAB
	sta	a:M7D
	lda	a:wram_1FAC
	sta	a:M7X
	lda	a:wram_1FAD
	sta	a:M7X
	lda	a:wram_1FAE
	sta	a:M7Y
	lda	a:wram_1FAF
	sta	a:M7Y
	lda	a:wram_1FB0
	sta	a:BG1HOFS
	lda	a:wram_1FB1
	sta	a:BG1HOFS
	lda	a:wram_1FB2
	sta	a:BG1VOFS
	lda	a:wram_1FB3
	sta	a:BG1VOFS
	ldx	zp_40
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
	lda	a:wram_1FE4
	sta	a:M7A
	lda	a:wram_1FE5
	sta	a:M7A
	lda	a:wram_1FE6
	sta	a:M7B
	lda	a:wram_1FE7
	sta	a:M7B
	lda	a:wram_1FE8
	sta	a:M7C
	lda	a:wram_1FE9
	sta	a:M7C
	lda	a:wram_1FEA
	sta	a:M7D
	lda	a:wram_1FEB
	sta	a:M7D
	lda	a:wram_1FEC
	sta	a:M7X
	lda	a:wram_1FED
	sta	a:M7X
	lda	a:wram_1FEE
	sta	a:M7Y
	lda	a:wram_1FEF
	sta	a:M7Y
	lda	a:wram_1FF0
	sta	a:BG1HOFS
	lda	a:wram_1FF1
	sta	a:BG1HOFS
	lda	a:wram_1FF2
	sta	a:BG1VOFS
	lda	a:wram_1FF3
	sta	a:BG1VOFS
	ldx	#$0002
	stx	irq_mode
	rts
reset_vram_queue:
	.a16
	lda	#$3000
	sta	vram_queue_end
	lda	#$3400
	sta	vram_queue_data_ptr
	rtl
