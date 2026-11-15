; engine/init.asm -- PPU init and RAM clear helpers
; Bank $00, $00:86AC-$00:8985. Included by main.asm in segment BANK00.
;
; sub_0086AC writes every PPU register with its start-up value (and the shadow
; copies at $1E8x); sub_008819 to sub_008959 clear RAM areas with MVN.

sub_0086AC:
	php
	sep	#$20
	.a8
	rep	#$10
	lda	#$8F
	sta	a:INIDISP
	lda	#$03
	sta	a:wram_1E86
	sta	a:OBSEL
	lda	#$00
	sta	a:OAMADDL
	sta	a:OAMADDH
	lda	#$09
	sta	a:BGMODE
	lda	#$00
	sta	a:wram_1E8A
	sta	a:MOSAIC
	lda	#$01
	sta	a:wram_1E8C
	sta	a:BG1SC
	lda	#$11
	sta	a:wram_1E8E
	sta	a:BG2SC
	lda	#$5A
	sta	a:wram_1E90
	sta	a:BG3SC
	lda	#$59
	sta	a:wram_1E92
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
	sta	a:wram_1E9A
	sta	a:TM
	lda	#$17
	sta	a:wram_1E9C
	sta	a:TS
	lda	#$00
	sta	a:TMW
	sta	a:TSW
	lda	#$30
	sta	a:wram_1E94
	sta	a:CGWSEL
	lda	#$00
	sta	a:wram_1E96
	sta	a:CGADSUB
	lda	#$E0
	sta	a:wram_1E98
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
sub_008819:
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
sub_008830:
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
sub_008847:
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

sub_00885E:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1C00
	lda	#$00FE
	ldx	#$1C00
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008875:
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
sub_00888C:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1200
	lda	#$08FE
	ldx	#$1200
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

sub_0088A3:
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	phb
	lda	#$0000
	sta	f:wram_1380
	lda	#$00FE
	ldx	#$1380
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

sub_0088BA:
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

sub_0088E7:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1200
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

sub_008914:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1280
	lda	#$007E
	ldx	#$1280
	txy
	iny
	mvn	#$00, #$00
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00892B:
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

sub_008942:
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E4000
	lda	#$BFFE
	ldx	#$4000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008959:
	; (not executed in the CDL traces)
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7E8000
	lda	#$1FFE
	ldx	#$8000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_7EC000
	lda	#$1FFE
	ldx	#$C000
	txy
	iny
	mvn	#$7E, #$7E
	plb
	rtl
