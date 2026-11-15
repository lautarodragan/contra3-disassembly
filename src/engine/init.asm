; engine/init.asm -- PPU init and RAM clear helpers
; Bank $00, $00:86AC-$00:8985. Included by main.asm in segment BANK00.
;
; init_ppu_registers writes every PPU register with its start-up value (and
; the shadows at $1E84-$1E9C); the clear_* routines zero RAM areas with MVN
; (each named by what it clears; those named by address have no caller).

init_ppu_registers:
	php
	sep	#$20
	.a8
	rep	#$10
	lda	#$8F
	sta	a:INIDISP
	lda	#$03
	sta	a:obsel_shadow
	sta	a:OBSEL
	lda	#$00
	sta	a:OAMADDL
	sta	a:OAMADDH
	lda	#$09
	sta	a:BGMODE
	lda	#$00
	sta	a:mosaic_shadow
	sta	a:MOSAIC
	lda	#$01
	sta	a:bg1sc_shadow
	sta	a:BG1SC
	lda	#$11
	sta	a:bg2sc_shadow
	sta	a:BG2SC
	lda	#$5A
	sta	a:bg3sc_shadow
	sta	a:BG3SC
	lda	#$59
	sta	a:bg4sc_shadow
	sta	a:BG4SC
	lda	#$22
	sta	a:BG12NBA
	lda	#$55
	sta	a:BG34NBA
	lda	#$00
	sta	a:BG1HOFS
	sta	a:BG1HOFS
	sta	a:BG1VOFS
	sta	a:BG1VOFS
	sta	a:BG2HOFS
	sta	a:BG2HOFS
	sta	a:BG2VOFS
	sta	a:BG2VOFS
	sta	a:BG3HOFS
	sta	a:BG3HOFS
	sta	a:BG3VOFS
	sta	a:BG3VOFS
	sta	a:BG4HOFS
	sta	a:BG4HOFS
	sta	a:BG4VOFS
	sta	a:BG4VOFS
	lda	#$80
	sta	a:VMAIN
	lda	#$00
	sta	a:VMADDL
	sta	a:VMADDH
	sta	a:M7SEL
	sta	a:M7A
	lda	#$01
	sta	a:M7A
	lda	#$00
	sta	a:M7B
	sta	a:M7B
	sta	a:M7C
	sta	a:M7C
	sta	a:M7D
	lda	#$01
	sta	a:M7D
	lda	#$00
	sta	a:M7X
	sta	a:M7X
	sta	a:M7Y
	sta	a:M7Y
	sta	a:CGADD
	sta	a:W12SEL
	sta	a:W34SEL
	sta	a:WOBJSEL
	sta	a:WH0
	sta	a:WH1
	sta	a:WH2
	sta	a:WH3
	sta	a:WBGLOG
	sta	a:WOBJLOG
	lda	#$17
	sta	a:tm_shadow
	sta	a:TM
	lda	#$17
	sta	a:ts_shadow
	sta	a:TS
	lda	#$00
	sta	a:TMW
	sta	a:TSW
	lda	#$30
	sta	a:cgwsel_shadow
	sta	a:CGWSEL
	lda	#$00
	sta	a:cgadsub_shadow
	sta	a:CGADSUB
	lda	#$E0
	sta	a:coldata_shadow
	sta	a:COLDATA
	lda	#$00
	sta	a:SETINI
	sta	a:NMITIMEN
	lda	#$FF
	sta	a:WRIO
	lda	#$00
	sta	a:WRMPYA
	sta	a:WRMPYB
	sta	a:WRDIVL
	sta	a:WRDIVH
	sta	a:WRDIVB
	sta	a:HTIMEL
	sta	a:HTIMEH
	sta	a:VTIMEL
	sta	a:VTIMEH
	sta	a:MDMAEN
	sta	a:HDMAEN
	lda	#$09
	sta	a:BGMODE
	lda	#$01
	sta	a:BG1SC
	lda	#$11
	sta	a:BG2SC
	lda	#$5A
	sta	a:BG3SC
	lda	#$22
	sta	a:BG12NBA
	lda	#$55
	sta	a:BG34NBA
	lda	#$17
	sta	a:TM
	sta	a:TS
	lda	#$81
	sta	a:nmitimen_shadow
	sta	a:NMITIMEN
	plp
	.a16
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_ram_0000_1bff:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:zp_00
	lda	#$1BFE
	ldx	#$0000
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_zp_84_fe:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:difficulty
	lda	#$007A
	ldx	#$0084
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_ram_0200_1bff:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:player1_obj
	lda	#$19FE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

clear_mode_work:
	rep	#$30
	phb
	lda	#$0000
	sta	f:mode_work
	lda	#$00FE
	ldx	#$1C00
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_zp_70_fe:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:stage_index
	lda	#$008E
	ldx	#$0070
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_ram_1200_1aff:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:palette_tasks
	lda	#$08FE
	ldx	#$1200
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; Clears $1380-$147F: the BG scroll states (BG1 $1380, BG2 $13C0, BG3 $1400).
clear_bg_scroll_state:
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	phb
	lda	#$0000
	sta	f:bg1_x
	lda	#$00FE
	ldx	#$1380
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; Clears $0200-$0FBF (main and secondary object lists) and the OAM buffer at
; $7E:0FC0-$7E:11DF.
clear_objects_and_oam:
	.a8
	rep	#$30
	.a16
	phb
	lda	#$0000
	sta	f:player1_obj
	lda	#$0DBE
	ldx	#$0200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:$7E0FC0
	lda	#$021E
	ldx	#$0FC0
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl

; Clears $1200-$127F (palette task slots) and $7E:2000-$7E:23FF (palette
; buffers, the one DMAd to CGRAM at $7E:2200).
clear_palette_tasks_and_buffer:
	rep	#$30
	phb
	lda	#$0000
	sta	f:palette_tasks
	lda	#$007E
	ldx	#$1200
	txy
	iny
	mvn	#$00, #$00
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E2000
	lda	#$03FE
	ldx	#$2000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl

; Clears $1280-$12FF (VRAM script task slots).
clear_vram_tasks:
	rep	#$30
	phb
	lda	#$0000
	sta	f:vram_tasks
	lda	#$007E
	ldx	#$1280
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_ram_1b00_1bff:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1B00
	lda	#$00FE
	ldx	#$1B00
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

clear_wram_7e4000_7effff:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E4000
	lda	#$BFFE	; [num]
	ldx	#$4000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_wram_7e8000_and_7ec000:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E8000
	lda	#$1FFE
	ldx	#$8000	; [num]
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7EC000
	lda	#$1FFE
	ldx	#$C000	; [num]
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl
