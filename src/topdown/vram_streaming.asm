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
; characters (boss_chr_stream_size bytes from boss_chr_stream_src to boss_chr_stream_vram).
; Nothing during the intro and the map view.
stream_topdown_sprite_gfx:
	lda	a:intro_phase
	bne	@return
	lda	a:map_view_active
	beq	loc_009C23
@return:
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
	lda	a:td_gfx_stream+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+2*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+3*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+2*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+3*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+4*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+4*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+5*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+5*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+4*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+4*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+5*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+5*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+6*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+6*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+7*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+7*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+6*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+6*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+7*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+7*GFXS_SIZE+GFXS_BANK
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
	lda	a:boss_chr_stream_vram
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:boss_chr_stream_src
	sta	a:A1T0L
	ldy	a:boss_chr_stream_bank
	sty	a:A1B0
	lda	a:boss_chr_stream_size
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4000
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:td_gfx_stream+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+2*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+3*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+4*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+5*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+4*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+5*GFXS_SIZE+GFXS_SRC2
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
	lda	a:boss_chr_stream_vram
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:boss_chr_stream_src
	sta	a:A1T0L
	ldy	a:boss_chr_stream_bank
	sty	a:A1B0
	lda	a:boss_chr_stream_size
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4000
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:td_gfx_stream+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+1*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+1*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+2*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+3*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+2*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+2*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+3*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+3*GFXS_SIZE+GFXS_BANK
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
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+10*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+11*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+10*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+11*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+12*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+12*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+13*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+13*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+12*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+12*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+13*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+13*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+14*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+14*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+15*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+15*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+14*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+14*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+15*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+15*GFXS_SIZE+GFXS_BANK
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
	lda	a:boss_chr_stream_vram
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:boss_chr_stream_src
	sta	a:A1T0L
	ldy	a:boss_chr_stream_bank
	sty	a:A1B0
	lda	a:boss_chr_stream_size
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4800
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+10*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+11*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	ldy	#$80
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+12*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+13*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+12*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:td_gfx_stream+13*GFXS_SIZE+GFXS_SRC2
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
	lda	a:boss_chr_stream_vram
	sta	a:VMADDL
	lda	#$1900
	sta	a:DMAP0
	lda	a:boss_chr_stream_src
	sta	a:A1T0L
	ldy	a:boss_chr_stream_bank
	sty	a:A1B0
	lda	a:boss_chr_stream_size
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	#$4800
	sta	a:VMADDL
	lda	#$1801
	sta	a:DMAP0
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	lda	#$0100
	sta	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+8*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+8*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+9*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+9*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+10*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC
	sta	a:A1T0L
	ldy	a:td_gfx_stream+11*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+10*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+10*GFXS_SIZE+GFXS_BANK
	sty	a:A1B0
	stx	a:DAS0H
	stx	a:MDMAEN
	lda	a:td_gfx_stream+11*GFXS_SIZE+GFXS_SRC2
	sta	a:A1T0L
	ldy	a:td_gfx_stream+11*GFXS_SIZE+GFXS_BANK
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
	ldx	a:m7_patch_flags
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:m7_patch_flags+2
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:m7_patch_flags+4
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	ldx	a:m7_patch_flags+6
	jsr	(.loword(tbl_m7_block_patch_uploaders),x)
	rep	#$20
	.a16
	stz	a:m7_patch_flags
	stz	a:m7_patch_flags+2
	stz	a:m7_patch_flags+4
	stz	a:m7_patch_flags+6
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
	ldx	a:m7_patch_vram
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+2
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+4
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+6
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_1:
	ldx	#$1838
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:m7_patch_vram+8
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+10
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+12
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+14
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_2:
	ldx	#$1848
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:m7_patch_vram+16
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+18
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+20
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+22
	stx	a:VMADDL
	sta	a:MDMAEN
	rts

upload_m7_block_patch_3:
	ldx	#$1858
	stx	a:A1T0L
	sty	a:DAS0L
	ldx	a:m7_patch_vram+24
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+26
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+28
	stx	a:VMADDL
	sta	a:MDMAEN
	sty	a:DAS0L
	ldx	a:m7_patch_vram+30
	stx	a:VMADDL
	sta	a:MDMAEN
	rts
