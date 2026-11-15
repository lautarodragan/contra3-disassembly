; engine/reset.asm -- Reset: cold boot, warm boot and the main loop
; Bank $00, $00:8000-$00:816B. Included by main.asm in segment BANK00.
;
; The reset vector (reset) and the warm boot entry loc_0080A3 (jumped to by
; the soft-reset check in engine/joypad.asm): CPU, stack, PPU and RAM setup.
; The main loop at the end only polls sub_00995A (sound); the game itself runs
; in the NMI handler (engine/nmi.asm).

reset:
	.a8
	.i8
	clc
	xce
	sei
	cld
	rep	#$30
	.a16
	.i16
	ldx	#$1DFF
	txs
	ldx	#$0000
	phx
	pld
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	lda	a:RDNMI
	lda	#$00
	sta	a:NMITIMEN
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	lda	a:wram_1E0A
	cmp	#$4A3E
	bne	loc_008044
	; (not executed in the CDL traces)
	lda	a:wram_1E0C
	cmp	#$4E49
	bne	loc_008044
	lda	a:wram_1E0E
	cmp	#$3C4C
	bne	loc_008044
	lda	a:wram_1E10
	cmp	#$0400
	beq	loc_00809C
loc_008044:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1E00
	lda	#$01FE
	ldx	#$1E00
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$4A3E
	sta	a:wram_1E0A
	lda	#$4E49
	sta	a:wram_1E0C
	lda	#$3C4C
	sta	a:wram_1E0E
	lda	#$0400
	sta	a:wram_1E10
	stz	a:wram_1FA0
	stz	a:wram_1FA2
	stz	a:wram_1FE0
	stz	a:wram_1FE2
	lda	#$0000
	sta	a:wram_1E44
	lda	#$0002
	sta	a:wram_1E46
	lda	#$0003
	sta	a:wram_1E3C
	stz	a:demo_index
	stz	a:wram_1E4A
	lda	#$0002
	sta	a:wram_1E3E
loc_00809C:
	ldx	#.loword(data_05F55B)
	jsl	f:sub_0090A8
loc_0080A3:
	sei
	cld
	rep	#$30
	ldx	#$1DFF
	txs
	ldx	#$0000
	phx
	pld
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	lda	a:RDNMI
	lda	#$00
	sta	a:NMITIMEN
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	rep	#$10
	ldy	#$7FFF
	ldx	#$0000
	jsl	f:sub_008E4B
	rep	#$30
	phb
	lda	#$0000
	sta	f:zp_00
	lda	#$1DFE
	ldx	#$0000
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:p1_weapon_slot
	lda	#$007E
	ldx	#$1F80
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E2000
	lda	#$DFFE
	ldx	#$2000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7F0000
	lda	#$FFFE
	ldx	#$0000
	txy
	iny
	mvn	#$7F, #$7F
	plb
	jsl	f:sub_0086AC
	lda	#$3000
	sta	zp_4E
	lda	#$3400
	sta	zp_50
	lda	#$2200
	sta	zp_48
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1F00
	lda	#$003E
	ldx	#$1F00
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$0003
	sta	zp_30
	jsl	f:sub_00848F
	stz	nmi_mode
	stz	zp_44
	lda	#$0081
	sta	a:nmitimen_shadow
	cli
loc_008166:
	jsl	f:sub_00995A
	bra	loc_008166
