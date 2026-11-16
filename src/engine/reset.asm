; engine/reset.asm -- Reset: cold boot, warm boot and the main loop
; Bank $00, $00:8000-$00:816B. Included by main.asm in segment BANK00.
;
; reset: native mode, stack at $1DFF, D = 0, DB = $05, NMI off, forced blank.
; If boot_signature is not in RAM ($1E0A, ">JIN L<" + $0400), it is a cold
; boot: $1E00-$1FFF is cleared, the signature written and the option
; defaults set ($1E3C = 3 lives, $1E3E = 2 normal difficulty, ...). Either
; way the sound driver is uploaded (loader list song_set_boot, type 2) and
; warm_boot follows.
;
; warm_boot (also the target of the soft reset in read_joypads): clears VRAM,
; $0000-$1DFF, $1F80-$1FFF and $7E:2000-$7F:FFFF, initialises the PPU
; (init_ppu_registers), the VRAM queue, the palette buffer address and the
; sound CPU context ($1F00), enables the display (start_display) and NMI
; (nmi_mode 0), and falls into the main loop.
;
; The main loop only calls service_song_set_request (an upload of a song set
; requested with request_song_set); everything else runs in the NMI handler
; (engine/nmi.asm).

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
	lda	#^tables_05
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
	sta	f:persistent_ram
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
	stz	a:p1_score
	stz	a:p1_score_hi
	stz	a:p2_score
	stz	a:p2_score_hi
	lda	#$0000
	sta	a:high_score
	lda	#$0002
	sta	a:high_score_hi
	lda	#$0003
	sta	a:option_lives
	stz	a:demo_index
	stz	a:demo_record_mode
	lda	#$0002
	sta	a:option_level
@upload_sound_driver:
	ldx	#.loword(song_set_boot)
	jsl	f:load_data_list
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
	lda	#^tables_05
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
	jsl	f:clear_vram_words
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
	lda	#$DFFE	; [num]
	ldx	#$2000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7F0000
	lda	#$FFFE	; [num]
	ldx	#$0000
	txy
	iny
	mvn	#$7F, #$7F
	plb
	jsl	f:init_ppu_registers
	lda	#VRAM_QUEUE
	sta	vram_queue_end
	lda	#VRAM_QUEUE_DATA
	sta	vram_queue_data_ptr
	lda	#$2200
	sta	cgram_dma_src
	rep	#$30
	phb
	lda	#$0000
	sta	f:LOADER_SPC
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
	jsl	f:service_song_set_request
	bra	@main_loop
