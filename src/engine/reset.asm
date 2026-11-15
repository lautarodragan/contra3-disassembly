; engine/reset.asm -- Reset: cold boot, warm boot and the main loop
; Bank $00, $00:8000-$00:816B. Included by main.asm in segment BANK00.
;
; The reset vector (reset) and the warm boot entry warm_boot (jumped to by
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
	lda	a:boot_signature
	cmp	#$4A3E
	bne	@cold_boot
	; (not executed in the CDL traces)
	lda	a:boot_signature+2
	cmp	#$4E49
	bne	@cold_boot
	lda	a:boot_signature+4
	cmp	#$3C4C
	bne	@cold_boot
	lda	a:boot_signature+6
	cmp	#$0400
	beq	@upload_sound_driver
@cold_boot:
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
	sta	a:boot_signature
	lda	#$4E49
	sta	a:boot_signature+2
	lda	#$3C4C
	sta	a:boot_signature+4
	lda	#$0400
	sta	a:boot_signature+6
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
@upload_sound_driver:
	ldx	#.loword(data_05F55B)
	jsl	f:sub_0090A8
warm_boot:
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
	jsl	f:init_ppu_registers
	lda	#$3000
	sta	vram_queue_end
	lda	#$3400
	sta	vram_queue_data_ptr
	lda	#$2200
	sta	cgram_dma_src
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
	sta	soft_reset_pad_mask
	jsl	f:start_display
	stz	nmi_mode
	stz	irq_mode
	lda	#$0081
	sta	a:nmitimen_shadow
	cli
@main_loop:
	jsl	f:sub_00995A
	bra	@main_loop
