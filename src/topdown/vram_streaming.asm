; topdown/vram_streaming.asm -- Top-down stages: VRAM streaming
; Bank $00, $00:9C18-$00:A376. Included by main.asm in segment BANK00.
;
; Run by the NMI frame handler of the top-down (Mode 7) stages (nmi_frame_top_down):
; stream_topdown_sprite_gfx DMAs the rotated sprite graphics listed at $1780
; (and on the boss maps the boss's Mode 7 characters), upload_m7_block_patches
; writes the queued 4x4-tile blocks of the Mode 7 tilemap ($1800-$1867).

; NMI (top-down): DMAs this frame's sprite graphics to VRAM: the
; rotated frames of the players and enemies chosen by draw_topdown_sprites,
; listed at $1780 (player 1's view, to VRAM $4000) or $17C0 (player 2's view,
; to $4800, odd frames in 2P-A). On the boss maps also the boss's Mode 7
; characters (wram_158C/wram_15AC, wram_15AE bytes to VRAM wram_15AA).
; Nothing during the intro and the map view.
stream_topdown_sprite_gfx:
	lda	a:intro_phase
	bne	loc_009C22
	lda	a:map_view_active
	beq	loc_009C23
loc_009C22:
	rtl
loc_009C23:
	lda	a:title_menu_cursor
	beq	loc_009C33
	dec	a
	bne	loc_009C33
	lda	frame_counter
	lsr	a
	bcc	loc_009C33
	brl	loc_009F45
loc_009C33:
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	bne	loc_009C3E
	brl	loc_009D81
loc_009C3E:
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_009C46
	brl	loc_009E77
loc_009C46:
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	#$4000
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_1780
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_1788
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1784
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_178C
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1790
	sta	a:A1T0L
	ldy	a:wram_1792
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1798
	sta	a:A1T0L
	ldy	a:wram_179A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1794
	sta	a:A1T0L
	ldy	a:wram_1792
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_179C
	sta	a:A1T0L
	ldy	a:wram_179A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17A0
	sta	a:A1T0L
	ldy	a:wram_17A2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17A8
	sta	a:A1T0L
	ldy	a:wram_17AA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17A4
	sta	a:A1T0L
	ldy	a:wram_17A2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17AC
	sta	a:A1T0L
	ldy	a:wram_17AA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17B0
	sta	a:A1T0L
	ldy	a:wram_17B2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17B8
	sta	a:A1T0L
	ldy	a:wram_17BA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17B4
	sta	a:A1T0L
	ldy	a:wram_17B2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17BC
	sta	a:A1T0L
	ldy	a:wram_17BA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl
loc_009D81:
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	a:wram_15AA
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:wram_158C
	sta	a:A1T0L
	ldy	a:wram_15AC
	sty	a:A1B0
	lda	a:wram_15AE
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4000
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_1780
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_1788
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1784
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_178C
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1790
	sta	a:A1T0L
	ldy	a:wram_1792
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1798
	sta	a:A1T0L
	ldy	a:wram_179A
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17A0
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17A8
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_1794
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_179C
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17A4
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17AC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl
loc_009E77:
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	a:wram_15AA
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:wram_158C
	sta	a:A1T0L
	ldy	a:wram_15AC
	sty	a:A1B0
	lda	a:wram_15AE
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4000
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_1780
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_1788
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1784
	sta	a:A1T0L
	ldy	a:wram_1782
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_178C
	sta	a:A1T0L
	ldy	a:wram_178A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1790
	sta	a:A1T0L
	ldy	a:wram_1792
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1798
	sta	a:A1T0L
	ldy	a:wram_179A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_1794
	sta	a:A1T0L
	ldy	a:wram_1792
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_179C
	sta	a:A1T0L
	ldy	a:wram_179A
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl
loc_009F45:
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	bne	loc_009F50
	; (not executed in the CDL traces)
	brl	loc_00A093
loc_009F50:
	cmp	#$0006
	bne	loc_009F58
	; (not executed in the CDL traces)
	brl	loc_00A189
loc_009F58:
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	#$4800
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_17C0
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_17C8
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17C4
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17CC
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D0
	sta	a:A1T0L
	ldy	a:wram_17D2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D8
	sta	a:A1T0L
	ldy	a:wram_17DA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D4
	sta	a:A1T0L
	ldy	a:wram_17D2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17DC
	sta	a:A1T0L
	ldy	a:wram_17DA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17E0
	sta	a:A1T0L
	ldy	a:wram_17E2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17E8
	sta	a:A1T0L
	ldy	a:wram_17EA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17E4
	sta	a:A1T0L
	ldy	a:wram_17E2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17EC
	sta	a:A1T0L
	ldy	a:wram_17EA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17F0
	sta	a:A1T0L
	ldy	a:wram_17F2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17F8
	sta	a:A1T0L
	ldy	a:wram_17FA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17F4
	sta	a:A1T0L
	ldy	a:wram_17F2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17FC
	sta	a:A1T0L
	ldy	a:wram_17FA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl
loc_00A093:
	; (not executed in the CDL traces)
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	a:wram_15AA
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:wram_158C
	sta	a:A1T0L
	ldy	a:wram_15AC
	sty	a:A1B0
	lda	a:wram_15AE
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4800
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_17C0
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_17C8
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17C4
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17CC
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D0
	sta	a:A1T0L
	ldy	a:wram_17D2
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17D8
	sta	a:A1T0L
	ldy	a:wram_17DA
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17E0
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17E8
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17D4
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17DC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17E4
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:wram_17EC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl
loc_00A189:
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	lda	a:wram_15AA
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:wram_158C
	sta	a:A1T0L
	ldy	a:wram_15AC
	sty	a:A1B0
	lda	a:wram_15AE
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4800
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:wram_17C0
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:wram_17C8
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17C4
	sta	a:A1T0L
	ldy	a:wram_17C2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17CC
	sta	a:A1T0L
	ldy	a:wram_17CA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D0
	sta	a:A1T0L
	ldy	a:wram_17D2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D8
	sta	a:A1T0L
	ldy	a:wram_17DA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17D4
	sta	a:A1T0L
	ldy	a:wram_17D2
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:wram_17DC
	sta	a:A1T0L
	ldy	a:wram_17DA
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	rep	#$10
	.i16
	rtl

; NMI (top-down): writes the queued 4x4-tile blocks of the Mode 7 tilemap
; (slots at $1800: flag, $1808: four VRAM row addresses, $1828: 16 tiles), then
; clears the flags. Unused slots point at VRAM $6000 (reset_m7_block_patches).
upload_m7_block_patches:
	sep	#$20
	.a8
	stz	a:VMAIN
	ldx	#$1800
	stx	a:DMAP0
	stz	a:A1B0
	ldy	#$0004
	lda	#$01
	ldx	a:wram_1800
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:wram_1802
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:wram_1804
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:wram_1806
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	rep	#$20
	.a16
	stz	a:wram_1800
	stz	a:wram_1802
	stz	a:wram_1804
	stz	a:wram_1806
	rtl
tbl_m7_block_patch_uploaders:
	.addr	upload_m7_block_patch_0
	.addr	upload_m7_block_patch_0
	.addr	upload_m7_block_patch_1
	.addr	upload_m7_block_patch_2
	.addr	upload_m7_block_patch_3

; DMAs block patch slot 0 (4 rows of 4 tiles).
upload_m7_block_patch_0:
	.a8
	ldx	#$1828
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:wram_1808
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_180A
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_180C
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_180E
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_1:
	ldx	#$1838
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:wram_1810
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1812
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1814
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1816
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_2:
	ldx	#$1848
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:wram_1818
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_181A
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_181C
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_181E
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_3:
	ldx	#$1858
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:wram_1820
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1822
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1824
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:wram_1826
	stx	a:VMADDL
	sta	a:MDMAEN
	rts
