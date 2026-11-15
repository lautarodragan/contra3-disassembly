; engine/hdma.asm -- HUD, stage HDMA and HDMA tables
; Bank $00, $00:E369-$00:E7EE. Included by main.asm in segment BANK00.
;
; The HUD (lives, weapons, bombs) is a buffer of BG3 tilemap words at
; hud_buffer ($1700-$177F) built by init_hud from templates and updated by
; update_p1_hud / update_p2_hud (each frame, the two players alternating in
; two-player games), then DMAd to VRAM ($5C25/$5C42, player 2 $5C35/$5C52)
; by upload_p1_hud / upload_p2_hud in the NMI. Lives are shown as two digits
; (lives - 1, via the hardware divider), the two weapon slots by 2x2 icons
; (hud_weapon_tiles_*), the active slot by its palette
; (hud_weapon_slot_attrs).
;
; setup_stage_hdma (side-view NMI) programs the HDMA channels: the preset
; hdma_preset (ptrs_stage_hdma_lists), channel 3 for the window (table at zp_9E, WH0/WH1)
; and channel 4 for COLDATA (table at zp_C6).
;
; build_scroll_split_hdma builds, from a pattern (scroll_split_pattern,
; data_05A25A) and a position (scroll_split_y), an indirect HDMA table at
; $7E:D000 / values at $7E:D400 that splits the screen in horizontal bands
; with their own scroll (each band's value comes from a handler: BG1 x, BG2 x
; or a table); nmi_frame_side_view copies them to $7E:D200 / $7E:D800.
; init_line_hdma_table / fill_line_hdma_table build a per-line table at
; $7E:E800 (two halves of 127 lines, indirect HDMA list at $7E:EA00).

; Clears hud_buffer, draws the HUD label text and copies the templates
; (data_05A14F.. + 2, 32 bytes per row) for player 1 and, with two players,
; player 2.
init_hud:
	rep	#$30
	phb
	lda	#$0000
	sta	f:hud_buffer
	lda	#$007E
	ldx	#$1700
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	#$2000
	ldx	#.loword(text_1p)
	jsl	f:draw_text_attr
	ldx	#$0020
@copy_p1_top:
	lda	a:data_05A14F,x
	sta	a:$16FE,x
	dex
	dex
	bne	@copy_p1_top
	ldx	#$0020
@copy_p1_bottom:
	lda	a:data_05A18F,x
	sta	a:$173E,x
	dex
	dex
	bne	@copy_p1_bottom
	lda	a:title_menu_cursor
	beq	@done
	lda	#$2400
	ldx	#.loword(text_2p)
	jsl	f:draw_text_attr
	ldx	#$0020
@copy_p2_top:
	lda	a:data_05A16F,x
	sta	a:$171E,x
	dex
	dex
	bne	@copy_p2_top
	ldx	#$0020
@copy_p2_bottom:
	lda	a:data_05A1AF,x
	sta	a:$175E,x
	dex
	dex
	bne	@copy_p2_bottom
@done:
	rtl

update_hud_alternating:
	lda	a:title_menu_cursor
	beq	update_p1_hud
	lda	frame_counter
	lsr	a
	bcc	update_p1_hud
	brl	update_p2_hud

; Lives digits, weapon icons and palettes, bombs of player 1 into hud_buffer.
update_p1_hud:
	lda	a:p1_lives
	beq	@lives_digits
	dec	a
@lives_digits:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	inc	a
	sta	a:hud_buffer+$44
	lda	a:RDMPYL
	inc	a
	sta	a:hud_buffer+$46
	ldx	a:p1_weapon_slot
	lda	a:hud_weapon_slot_attrs,x
	sta	a:hud_buffer+$0B
	sta	a:hud_buffer+$0D
	sta	a:hud_buffer+$4B
	sta	a:hud_buffer+$4D
	ldx	a:p1_weapon_slot_other
	lda	a:hud_weapon_slot_attrs,x
	sta	a:hud_buffer+$11
	sta	a:hud_buffer+$13
	sta	a:hud_buffer+$51
	sta	a:hud_buffer+$53
	ldx	a:p1_weapon_1
	lda	a:hud_weapon_tiles_tl,x
	sta	a:hud_buffer+$0A
	lda	a:hud_weapon_tiles_tr,x
	sta	a:hud_buffer+$0C
	lda	a:hud_weapon_tiles_bl,x
	sta	a:hud_buffer+$4A
	lda	a:hud_weapon_tiles_br,x
	sta	a:hud_buffer+$4C
	ldx	a:p1_weapon_2
	lda	a:hud_weapon_tiles_tl,x
	sta	a:hud_buffer+$10
	lda	a:hud_weapon_tiles_tr,x
	sta	a:hud_buffer+$12
	lda	a:hud_weapon_tiles_bl,x
	sta	a:hud_buffer+$50
	lda	a:hud_weapon_tiles_br,x
	sta	a:hud_buffer+$52
	lda	a:p1_bombs
	inc	a
	sta	a:hud_buffer+$5C
	rep	#$20
	.a16
	rtl

update_p2_hud:
	lda	a:p2_lives
	beq	@lives_digits
	dec	a
@lives_digits:
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$0A
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	lda	a:RDDIVL
	inc	a
	sta	a:hud_buffer+$64
	lda	a:RDMPYL
	inc	a
	sta	a:hud_buffer+$66
	ldx	a:p2_weapon_slot
	lda	a:hud_weapon_slot_attrs,x
	sta	a:hud_buffer+$2B
	sta	a:hud_buffer+$2D
	sta	a:hud_buffer+$6B
	sta	a:hud_buffer+$6D
	ldx	a:p2_weapon_slot_other
	lda	a:hud_weapon_slot_attrs,x
	sta	a:hud_buffer+$31
	sta	a:hud_buffer+$33
	sta	a:hud_buffer+$71
	sta	a:hud_buffer+$73
	ldx	a:p2_weapon_1
	lda	a:hud_weapon_tiles_tl,x
	sta	a:hud_buffer+$2A
	lda	a:hud_weapon_tiles_tr,x
	sta	a:hud_buffer+$2C
	lda	a:hud_weapon_tiles_bl,x
	sta	a:hud_buffer+$6A
	lda	a:hud_weapon_tiles_br,x
	sta	a:hud_buffer+$6C
	ldx	a:p2_weapon_2
	lda	a:hud_weapon_tiles_tl,x
	sta	a:hud_buffer+$30
	lda	a:hud_weapon_tiles_tr,x
	sta	a:hud_buffer+$32
	lda	a:hud_weapon_tiles_bl,x
	sta	a:hud_buffer+$70
	lda	a:hud_weapon_tiles_br,x
	sta	a:hud_buffer+$72
	lda	a:p2_bombs
	inc	a
	sta	a:hud_buffer+$7C
	rep	#$20
	.a16
	rtl

upload_hud_alternating:
	lda	frame_counter
	lsr	a
	bcs	upload_p1_hud
	brl	upload_p2_hud

upload_p1_hud:
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	ldx	#$5C25
	stx	a:VMADDL
	ldx	#$1801
	stx	a:DMAP0
	stz	a:A1B0
	ldx	#$170A
	stx	a:A1T0L
	ldx	#$0010
	stx	a:DAS0L
	lda	#$01
	sta	a:MDMAEN
	ldx	#$5C42
	stx	a:VMADDL
	ldx	#$1744
	stx	a:A1T0L
	ldx	#$001A
	stx	a:DAS0L
	sta	a:MDMAEN
	rep	#$20
	.a16
	rtl

upload_p2_hud:
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	ldx	#$5C35
	stx	a:VMADDL
	ldx	#$1801
	stx	a:DMAP0
	stz	a:A1B0
	ldx	#$172A
	stx	a:A1T0L
	ldx	#$0010
	stx	a:DAS0L
	lda	#$01
	sta	a:MDMAEN
	ldx	#$5C52
	stx	a:VMADDL
	ldx	#$1764
	stx	a:A1T0L
	ldx	#$001A
	stx	a:DAS0L
	sta	a:MDMAEN
	rep	#$20
	.a16
	rtl
hdma_return:
	rtl

; Does nothing before stage_state 2.
setup_stage_hdma:
	stz	zp_00
	sep	#$20
	.a8
	stz	a:HDMAEN
	rep	#$30
	.a16
	lda	a:stage_state
	cmp	#$0002
	bcc	hdma_return
	lda	hdma_preset
	beq	@window_channel
	dec	a
	asl	a
	tax
	ldy	a:ptrs_stage_hdma_lists,x
@channel_loop:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	@channels_done
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	sta	$06,x
	tya
	clc
	adc	#$0008
	tay
	bra	@channel_loop
@channels_done:
	lda	a:$0002,y
	sta	zp_00
@window_channel:
	lda	zp_9E
	beq	@coldata_channel
	sta	a:A1T3L
	lda	#$2641
	sta	a:DMAP3
	lda	#$0008
	ora	zp_00
	sta	zp_00
@coldata_channel:
	lda	zp_C6
	beq	@enable
	sta	a:A1T4L
	lda	#$3242
	sta	a:DMAP4
	lda	#$0010
	ora	zp_00
	sta	zp_00
@enable:
	sep	#$20
	.a8
	lda	#$7E
	sta	a:A1B3
	sta	a:DASB3
	sta	a:A1B4
	sta	a:DASB4
	lda	zp_00
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl
split_hdma_return:
	rtl

; Called by nmi_frame_side_view; does nothing while scroll_split_pattern = 0.
build_scroll_split_hdma:
	lda	a:scroll_split_pattern
	beq	split_hdma_return
	dec	a
	asl	a
	tay
	lda	#$D000
	sta	zp_00
	lda	a:data_05A25A,y
	sta	zp_04
	lda	#$D400
	phx
	jsr	a:build_split_line_table
	jsr	a:fill_split_values
	plx
	rtl
split_skip_entry:
	iny
	iny
	iny
	iny
	bra	split_entry_loop

build_split_line_table:
	sta	zp_02
	sta	zp_FC
	lda	zp_00
	sta	zp_FE
	stz	zp_08
	stz	zp_0C
	lda	a:scroll_split_y
	and	#$FF00
	xba
	asl	a
	tay
	lda	(zp_04),y
	sta	zp_06
	ldy	#$0000
split_entry_loop:
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	sec
	lda	(zp_06),y
	sbc	a:scroll_split_y
	bmi	split_skip_entry
	beq	split_skip_entry
	cmp	#$00DF
	bcc	@line_count
	inc	zp_0C
	lda	#$00DF
@line_count:
	and	#$00FF
	sta	zp_0A
	sec
	sbc	zp_08
	and	#$007F
	pha
	lda	zp_0A
	sta	zp_08
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	(zp_00)
	inc	zp_00
	lda	zp_02
	inc	a
	inc	a
	clc
	adc	#$0400
	sta	(zp_00)
	inc	zp_00
	inc	zp_00
	iny
	iny
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	lda	(zp_06),y
	pha
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	pla
	sta	(zp_02)
	inc	zp_02
	inc	zp_02
	inc	zp_02
	inc	zp_02
	iny
	iny
	lda	zp_0C
	bne	@end
	bra	split_entry_loop
@end:
	lda	#$0000
	sta	(zp_00)
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts

fill_split_values:
	ldx	zp_FE
	lda	f:$7E0000,x
	beq	@done
	ldx	zp_FC
	lda	f:$7E0000,x
	sta	zp_02
	and	#$00FE
	jsr	a:call_split_value_handler
	inc	zp_FE
	inc	zp_FE
	inc	zp_FE
	inc	zp_FC
	inc	zp_FC
	inc	zp_FC
	inc	zp_FC
	bra	fill_split_values
@done:
	rts

call_split_value_handler:
	tay
	lda	a:tbl_05A35C,y
	sta	zp_00
	jmp	(zp_00)

split_value_from_table:
	lda	zp_03
	and	#$00FF
	phx
	tax
	lda	f:$7EE000,x
	plx
	sta	f:$7E0002,x
	rts

split_value_bg1_x:
	lda	a:bg1_x
	sta	f:$7E0002,x
	rts

split_value_bg2_x:
	lda	a:bg2_x
	sta	f:$7E0002,x
	rts

; (no caller found; decoded because it follows the end of a routine)
unused_debug_scroll_split:
	; (not executed in the CDL traces)
	lda	#$0007
	sta	hdma_preset
	lda	joy1_held
	bit	#JOY_UP
	beq	@no_up
	dec	a:scroll_split_y
@no_up:
	bit	#JOY_DOWN
	beq	@wrap
	inc	a:scroll_split_y
@wrap:
	lda	a:scroll_split_y
	and	#$01FF
	sta	a:scroll_split_y
	lda	#$D000
	sta	zp_00
	lda	#$A260
	sta	zp_04
	lda	#$D400
	rts
init_line_hdma_table:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	stz	a:$E800
	phx
	phb
	lda	#$03FF
	ldx	#$E800
	ldy	#$E801
	mvn	#$7E, #$7E
	plb
	plx
	lda	#$00FF
	sta	a:$EA00
	stz	a:$EA06
	lda	#$FFE8
	sta	a:$EA02
	lda	#$E900
	sta	a:$EA04
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

; A = divisor of the slope, Y = line offset of the centre. Fills
; $7E:E800 (going up from the centre) with zp_00 + n * slope and $7E:E900
; (going down) with zp_00 - n * slope.
fill_line_hdma_table:
	pha
	tya
	asl	a
	clc
	adc	#$E800
	sta	f:wram_7EEA01
	clc
	adc	#$00FC
	sta	f:wram_7EEA04
	pla
	phx
	stz	zp_02
	stz	zp_04
	pha
	lda	#$00FF
	sta	a:WRDIVL
	pla
	sep	#$20
	.a8
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	rep	#$20
	.a16
	lda	a:RDDIVL
	asl	a
	sta	zp_03
	asl	zp_03
	asl	zp_03
	asl	zp_03
	stz	zp_08
	stz	zp_0A
	stz	zp_06
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldx	#$00FE
	ldy	#$0000
@loop:
	clc
	lda	zp_00
	adc	zp_08
	sta	a:$E800,x
	clc
	lda	zp_00
	adc	zp_0A
	sta	a:$E900,y
	clc
	lda	zp_06
	adc	zp_02
	sta	zp_06
	lda	zp_08
	adc	zp_04
	sta	zp_08
	eor	#$FFFF
	inc	a
	sta	zp_0A
	iny
	iny
	dex
	dex
	bpl	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	rtl
