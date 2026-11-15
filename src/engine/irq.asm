; engine/irq.asm -- HDMA channel setup and IRQ handler
; Bank $00, $00:8BA7-$00:8CFE. Included by main.asm in segment BANK00.
;
; sub_008BA7 (called from NMI) sets up the HDMA channels from the list
; selected by $46 (data_05822E). irq (also the COP/BRK/ABORT vector)
; dispatches through tbl_008C0E to the raster handlers; sub_008C15 and
; sub_008C8C write the Mode 7 matrix and scroll registers mid-frame.

sub_008BA7:
	sep	#$20
	.a8
	stz	a:HDMAEN
	rep	#$30
	.a16
	lda	$46
	bne	loc_008BB3
	rtl
loc_008BB3:
	asl	a
	tax
	ldy	a:data_05822E,x
loc_008BB8:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	loc_008BD7
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
	bra	loc_008BB8
loc_008BD7:
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
	lda	a:$1E82
	and	#$CF
	sta	a:NMITIMEN
	rep	#$20
	.a16
	ldx	$44
	jsr	(.loword(tbl_008C0E),x)
	.a8
	rep	#$30
	.a16
	plb
	pld
	pla
	ply
	plx
	rti
tbl_008C0E:
	.addr	sub_008C14
	.addr	sub_008C15
	.addr	sub_008C8C

sub_008C14:
	; (not executed in the CDL traces)
	rts

sub_008C15:
	sep	#$20
	.a8
	lda	a:$1FA4
	sta	a:M7A
	lda	a:$1FA5
	sta	a:M7A
	lda	a:$1FA6
	sta	a:M7B
	lda	a:$1FA7
	sta	a:M7B
	lda	a:$1FA8
	sta	a:M7C
	lda	a:$1FA9
	sta	a:M7C
	lda	a:$1FAA
	sta	a:M7D
	lda	a:$1FAB
	sta	a:M7D
	lda	a:$1FAC
	sta	a:M7X
	lda	a:$1FAD
	sta	a:M7X
	lda	a:$1FAE
	sta	a:M7Y
	lda	a:$1FAF
	sta	a:M7Y
	lda	a:$1FB0
	sta	a:BG1HOFS
	lda	a:$1FB1
	sta	a:BG1HOFS
	lda	a:$1FB2
	sta	a:BG1VOFS
	lda	a:$1FB3
	sta	a:BG1VOFS
	ldx	$40
	beq	loc_008C8B
	ldx	#$0070
	stx	a:VTIMEL
	ldx	#$0004
	stx	$44
	lda	#$A1
	sta	a:NMITIMEN
loc_008C8B:
	rts

sub_008C8C:
	.a16
	sep	#$20
	.a8
	lda	a:$1FE4
	sta	a:M7A
	lda	a:$1FE5
	sta	a:M7A
	lda	a:$1FE6
	sta	a:M7B
	lda	a:$1FE7
	sta	a:M7B
	lda	a:$1FE8
	sta	a:M7C
	lda	a:$1FE9
	sta	a:M7C
	lda	a:$1FEA
	sta	a:M7D
	lda	a:$1FEB
	sta	a:M7D
	lda	a:$1FEC
	sta	a:M7X
	lda	a:$1FED
	sta	a:M7X
	lda	a:$1FEE
	sta	a:M7Y
	lda	a:$1FEF
	sta	a:M7Y
	lda	a:$1FF0
	sta	a:BG1HOFS
	lda	a:$1FF1
	sta	a:BG1HOFS
	lda	a:$1FF2
	sta	a:BG1VOFS
	lda	a:$1FF3
	sta	a:BG1VOFS
	ldx	#$0002
	stx	$44
	rts
loc_008CF4:
	.a16
	lda	#$3000
	sta	$4E
	lda	#$3400
	sta	$50
	rtl
