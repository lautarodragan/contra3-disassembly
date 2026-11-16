; effects/window_shapes.asm -- Window shapes
; Bank $02, $02:DDC6-$02:E65E. Included by main.asm in segment BANK02.
;
; Routines called from the NMI frame handlers and from
; engine/window_effect.asm that compute window/HDMA shapes (clip_window_circle,
; build_window_circle, build_window_hdma_lines...).

; NMI (top-down): HDMA channel 2 reads the window table at $7E:3C00 on odd
; frames, $3E00 on even ones (double buffer).
swap_topdown_window_buffer:
	lda	frame_counter
	lsr	a
	bcs	@odd_frame
	brl	@even_frame
@odd_frame:
	lda	#$3C00
	sta	a:A1T2L
	rtl
@even_frame:
	lda	#$3E00
	sta	a:A1T2L
loc_02DDDB:
	rtl

; NMI (top-down): while topdown_window_update_on, builds the window table
; for the next frame into the other buffer (loc_02E0FD / loc_02E3AE).
update_topdown_window:
	lda	a:topdown_window_update_on
	beq	loc_02DDDB
	lda	frame_counter
	lsr	a
	bcc	@even_frame
	jml	f:loc_02E0FD
@even_frame:
	jml	f:loc_02E3AE

; In: zp_10 = radius, zp_14/zp_16 = centre, zp_18/zp_1A = first/last
; line.  Clips the circle to those lines: carry set if nothing is visible,
; else zp_08/zp_0A = first/last line, zp_0C = first row of the circle,
; zp_0E = number of lines.
clip_window_circle:
	lda	zp_10
	asl	a
	sta	zp_06
	lda	zp_14
	clc
	adc	zp_10
	bmi	@not_visible
	beq	@not_visible
	sec
	sbc	zp_06
	cmp	#$0100
	bmi	@clip_top
@not_visible:
	sec
	rtl
@clip_top:
	lda	zp_16
	sec
	sbc	zp_10
	cmp	zp_18
	bmi	@top_clipped
	sta	zp_08
	stz	zp_0C
	bra	@clip_bottom
@top_clipped:
	tay
	clc
	adc	zp_06
	cmp	zp_18
	bmi	@not_visible
	beq	@not_visible
	lda	zp_18
	sta	zp_08
	tya
	sec
	sbc	zp_18
	eor	#$FFFF
	inc	a
	sta	zp_0C
@clip_bottom:
	lda	zp_16
	clc
	adc	zp_10
	cmp	zp_1A
	bmi	@set_last_line
	sec
	sbc	zp_06
	cmp	zp_1A
	bpl	@not_visible
	lda	zp_1A
@set_last_line:
	sta	zp_0A
	lda	zp_0A
	sec
	sbc	zp_08
	sta	zp_0E
	clc
	rtl

; Writes the left/right window positions of each line of the circle (from
; the table circle_chord_widths through the hardware divider/multiplier) to the
; table at zp_1C in $7E.
build_window_circle:
	sep	#$20
	.a8
	lda	zp_10
	sta	a:WRMPYA
	rep	#$20
	.a16
	lda	zp_08
	asl	a
	clc
	adc	zp_1C
	tax
	lda	zp_0E
	sta	zp_02
	lda	zp_0C
	sta	zp_00
	cmp	zp_10
	bcc	@upper_half
	brl	@lower_half
@upper_half:
	sep	#$20
@upper_loop:
	.a8
	lda	zp_00
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	zp_10
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy	a:RDDIVL
	lda	a:circle_chord_widths,y
	sta	a:WRMPYB
	nop
	nop
	nop
	nop
	lda	a:RDMPYH
	rep	#$20
	.a16
	and	#$00FF
	tay
	eor	#$FFFF
	sec
	adc	zp_14
	bpl	@upper_left_clamped
	lda	#$0000
@upper_left_clamped:
	cmp	#$0100
	bcc	@upper_left_on_screen
@upper_empty_line:
	lda	#$0001
	bra	@upper_store_line
@upper_left_on_screen:
	sta	zp_04
	tya
	clc
	adc	zp_14
	bmi	@upper_empty_line
	cmp	#$0100
	bmi	@upper_right_clamped
	lda	#$00FF
@upper_right_clamped:
	and	#$00FF
	xba
	ora	zp_04
@upper_store_line:
	sta	f:$7E0000,x
	sep	#$20
	.a8
	inc	zp_00
	inx
	inx
	dec	zp_02
	beq	@done
	lda	zp_00
	cmp	zp_10
	bcc	@upper_loop
@lower_half:
	.a16
	rep	#$20
	lda	zp_06
	sec
	sbc	zp_00
	sta	zp_00
	sep	#$20
@lower_loop:
	.a8
	lda	zp_00
	sta	a:WRDIVH
	stz	a:WRDIVL
	lda	zp_10
	sta	a:WRDIVB
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	ldy	a:RDDIVL
	lda	a:circle_chord_widths,y
	sta	a:WRMPYB
	nop
	nop
	nop
	nop
	lda	a:RDMPYH
	rep	#$20
	.a16
	and	#$00FF
	tay
	eor	#$FFFF
	sec
	adc	zp_14
	bpl	@lower_left_clamped
	lda	#$0000
@lower_left_clamped:
	cmp	#$0100
	bcc	@lower_left_on_screen
@lower_empty_line:
	lda	#$0001
	bra	@lower_store_line
@lower_left_on_screen:
	sta	zp_04
	tya
	clc
	adc	zp_14
	bmi	@lower_empty_line
	cmp	#$0100
	bmi	@lower_right_clamped
	lda	#$00FF
@lower_right_clamped:
	and	#$00FF
	xba
	ora	zp_04
@lower_store_line:
	sta	f:$7E0000,x
	sep	#$20
	.a8
	dec	zp_00
	inx
	inx
	dec	zp_02
	bne	@lower_loop
@done:
	stx	zp_1C
	rep	#$30
	.a16
	rtl

; Writes the line-count entries of the indirect HDMA table at zp_1E: lines
; above the circle (window off), the circle's lines (pointing into the
; positions), lines below.
build_window_hdma_lines:
	lda	zp_08
	asl	a
	clc
	adc	zp_1C
	sta	zp_00
	ldx	zp_1E
	lda	zp_08
	sec
	sbc	zp_18
	beq	@circle
	cmp	#$0080
	bcc	@above_entry
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$7F
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	pla
@above_entry:
	sep	#$20
	.a8
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
@circle:
	lda	zp_0E
	beq	@below
	cmp	#$0080
	bcc	@circle_entry
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$FF
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	zp_00
	sta	f:$7E0000,x
	clc
	adc	#$00FE
	sta	zp_00
	inx
	inx
	pla
@circle_entry:
	sep	#$20
	.a8
	ora	#$80
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	zp_00
	sta	f:$7E0000,x
	inx
	inx
@below:
	lda	zp_1A
	sec
	sbc	zp_0A
	beq	@done
	cmp	#$0080
	bcc	@below_entry
	sec
	sbc	#$007F
	pha
	sep	#$20
	.a8
	lda	#$7F
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	pla
@below_entry:
	sep	#$20
	.a8
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
@done:
	stx	zp_1E
	rep	#$30
	rtl

; Ends the HDMA table at zp_1E.
end_window_hdma_table:
	ldx	zp_1E
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0001,x
	sep	#$20
	.a8
	lda	#$00
	sta	f:$7E0003,x
	rep	#$30
	.a16
	rtl

; Appends to the indirect HDMA table at zp_1E an entry of 16 lines pointing
; at $3C1E (window off).
add_window_off_16_lines:
	ldx	zp_1E
	sep	#$20
	.a8
	lda	#$10
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	zp_1E
	rtl

; The same with 24 lines.
add_window_off_24_lines:
	ldx	zp_1E
	sep	#$20
	.a8
	lda	#$18
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	zp_1E
	rtl

; The same for zp_1A - zp_18 lines.
add_window_off_span:
	ldx	zp_1E
	sep	#$20
	.a8
	lda	zp_1A
	sec
	sbc	zp_18
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	zp_1E
	rtl

; The same, several entries of one line each.
add_window_off_single_lines:
	; (not executed in the CDL traces)
	ldx	zp_1E
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	sep	#$20
	.a8
	lda	#$01
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	sep	#$20
	.a8
	lda	zp_1A
	clc
	sbc	zp_18
	dec	a
	sta	f:$7E0000,x
	inx
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:$7E0000,x
	inx
	inx
	stx	zp_1E
	rtl

; Like build_window_circle, but the half-widths of the lines come from the
; table at (zp_12) instead of the divider: zp_14 -/+ width, clipped to
; 0-$FF, written from zp_1C.
build_window_from_widths:
	lda	zp_0E
	sta	zp_02
	lda	zp_0C
	asl	a
	tay
	lda	zp_08
	asl	a
	clc
	adc	zp_1C
	tax
@loop:
	lda	zp_14
	sec
	sbc	(zp_12),y
	bpl	@left_clamped
	lda	#$0000
@left_clamped:
	cmp	#$0100
	bcc	@left_on_screen
@empty_line:
	; (not executed in the CDL traces)
	lda	#$0001
	bra	@store_line
@left_on_screen:
	sta	zp_04
	lda	zp_14
	clc
	adc	(zp_12),y
	bmi	@empty_line
	cmp	#$0100
	bmi	@right_clamped
	; (not executed in the CDL traces)
	lda	#$00FF
@right_clamped:
	and	#$00FF
	xba
	ora	zp_04
@store_line:
	sta	f:$7E0000,x
	iny
	iny
	inx
	inx
	dec	zp_02
	bne	@loop
	stx	zp_1C
	rtl
loc_02E0FD:
	rep	#$30
	lda	a:td_p1_bomb+OBJ_TYPE
	dec	a
	bne	loc_02E108
	brl	loc_02E291
loc_02E108:
	bpl	loc_02E133
	sep	#$20
	.a8
	lda	#$01
	sta	f:window_hdma_a
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:window_hdma_a+$01
	sep	#$20
	.a8
	lda	#$00
	sta	f:window_hdma_a+$03
	sep	#$20
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	rtl
loc_02E133:
	; (not executed in the CDL traces)
	ldy	#$0000
	lda	a:td_p1_obj+OBJ_ATTR
	bit	#$2000
	bne	loc_02E141
	ldy	#$0002
loc_02E141:
	sep	#$20
	.a8
	lda	a:bomb_flash_cgadsub_p1,y
	sta	a:CGADSUB
	sta	f:hdma_tables+$63
	sta	f:hdma_tables+$67
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:td_p1_bomb+$06
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	cmp	#$0020
	bcc	loc_02E173
	lda	#$0020
loc_02E173:
	tay
	lda	a:ptrs_bomb_flash_coldata,y
	sta	zp_04
	lda	stage_frame_counter
	lsr	a
	and	#$000F
	tay
	sep	#$20
	.a8
	lda	(zp_04),y
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3C00
	sta	zp_1E
	lda	#$0010
	sta	zp_10
	lda	#.loword(window_widths_05E2F6)
	sta	zp_12
	lda	a:title_menu_cursor
	beq	loc_02E1D8
	dec	a
	bne	loc_02E1A3
	brl	loc_02E208
loc_02E1A3:
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$30
	sta	zp_14
	lda	a:td_p1_bomb+$34
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E1D3
	lda	a:td_p1_obj+$2C
	bne	loc_02E1D3
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E1D3:
	jsl	f:end_window_hdma_table
	rtl
loc_02E1D8:
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$30
	sta	zp_14
	lda	a:td_p1_bomb+$34
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E203
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E203:
	jsl	f:end_window_hdma_table
	rtl
loc_02E208:
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$30
	sta	zp_14
	lda	a:td_p1_bomb+$34
	sta	zp_16
	lda	#$0000
	sta	zp_18
	lda	#$0068
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E22D
loc_02E227:
	jsl	f:add_window_off_single_lines
	bra	loc_02E24E
loc_02E22D:
	lda	#$0000
	beq	loc_02E23A
	lda	a:td_p1_obj+$2C
	ora	a:td_p2_obj+$2C
	bne	loc_02E227
loc_02E23A:
	lda	zp_08
	bne	loc_02E246
	inc	zp_08
	inc	zp_0C
	dec	zp_0E
	beq	loc_02E227
loc_02E246:
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E24E:
	jsl	f:add_window_off_16_lines
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$32
	sta	zp_14
	lda	a:td_p1_bomb+$36
	sta	zp_16
	lda	#$0078
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E277
loc_02E271:
	jsl	f:add_window_off_span
	bra	loc_02E28C
loc_02E277:
	lda	#$0000
	bne	loc_02E284
	lda	a:td_p1_obj+$2C
	ora	a:td_p2_obj+$2C
	bne	loc_02E271
loc_02E284:
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E28C:
	jsl	f:end_window_hdma_table
	rtl
loc_02E291:
	sep	#$20
	.a8
	lda	#$13
	sta	a:CGADSUB
	sta	f:hdma_tables+$63
	sta	f:hdma_tables+$67
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$3F
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:td_p1_bomb+$24
	lsr	a
	lsr	a
	and	#$001F
	ora	#$00C0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3C00
	sta	zp_1E
	lda	a:td_p1_bomb+$24
	asl	a
	and	#$00FF
	sta	zp_10
	lda	a:title_menu_cursor
	beq	loc_02E30C
	dec	a
	bne	loc_02E2DC
	brl	loc_02E341
loc_02E2DC:
	; (not executed in the CDL traces)
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$38
	sta	zp_14
	lda	a:td_p1_bomb+$3C
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E307
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E307:
	jsl	f:end_window_hdma_table
	rtl
loc_02E30C:
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$38
	sta	zp_14
	lda	a:td_p1_bomb+$3C
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E33C
	lda	a:td_p1_obj+$2C
	bne	loc_02E33C
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E33C:
	jsl	f:end_window_hdma_table
	rtl
loc_02E341:
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$38
	sta	zp_14
	lda	a:td_p1_bomb+$3C
	sta	zp_16
	lda	#$0000
	sta	zp_18
	lda	#$0068
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E366
loc_02E360:
	jsl	f:add_window_off_span
	bra	loc_02E373
loc_02E366:
	lda	a:td_p1_obj+$2C
	bne	loc_02E360
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E373:
	jsl	f:add_window_off_16_lines
	lda	#$3C20
	sta	zp_1C
	lda	a:td_p1_bomb+$3A
	sta	zp_14
	lda	a:td_p1_bomb+$3E
	sta	zp_16
	lda	#$0078
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E39C
loc_02E396:
	jsl	f:add_window_off_span
	bra	loc_02E3A9
loc_02E39C:
	lda	a:td_p2_obj+$2C
	bne	loc_02E396
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E3A9:
	jsl	f:end_window_hdma_table
	rtl
loc_02E3AE:
	rep	#$30
	lda	a:td_p2_bomb+OBJ_TYPE
	dec	a
	bne	loc_02E3B9
	brl	loc_02E542
loc_02E3B9:
	bpl	loc_02E3E4
	sep	#$20
	.a8
	lda	#$01
	sta	f:window_hdma_b
	rep	#$20
	.a16
	lda	#$3E1E
	sta	f:window_hdma_b+$01
	sep	#$20
	.a8
	lda	#$00
	sta	f:window_hdma_b+$03
	sep	#$20
	stz	a:CGWSEL
	stz	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	rtl
loc_02E3E4:
	; (not executed in the CDL traces)
	ldy	#$0000
	lda	a:td_p2_obj+OBJ_ATTR
	bit	#$2000
	bne	loc_02E3F2
	ldy	#$0002
loc_02E3F2:
	sep	#$20
	.a8
	lda	a:bomb_flash_cgadsub_p2,y
	sta	a:CGADSUB
	sta	f:hdma_tables+$63
	sta	f:hdma_tables+$67
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:td_p2_bomb+$06
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	asl	a
	cmp	#$0020
	bcc	loc_02E424
	lda	#$0020
loc_02E424:
	tay
	lda	a:ptrs_bomb_flash_coldata,y
	sta	zp_04
	lda	stage_frame_counter
	lsr	a
	and	#$000F
	tay
	sep	#$20
	.a8
	lda	(zp_04),y
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3E00
	sta	zp_1E
	lda	#$0010
	sta	zp_10
	lda	#.loword(window_widths_05E2F6)
	sta	zp_12
	lda	a:title_menu_cursor
	beq	loc_02E489
	dec	a
	bne	loc_02E454
	brl	loc_02E4B9
loc_02E454:
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$30
	sta	zp_14
	lda	a:td_p2_bomb+$34
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E484
	lda	a:td_p2_obj+$2C
	bne	loc_02E484
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E484:
	jsl	f:end_window_hdma_table
	rtl
loc_02E489:
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$30
	sta	zp_14
	lda	a:td_p2_bomb+$34
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E4B4
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E4B4:
	jsl	f:end_window_hdma_table
	rtl
loc_02E4B9:
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$30
	sta	zp_14
	lda	a:td_p2_bomb+$34
	sta	zp_16
	lda	#$0000
	sta	zp_18
	lda	#$0068
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E4DE
loc_02E4D8:
	jsl	f:add_window_off_single_lines
	bra	loc_02E4FF
loc_02E4DE:
	lda	#$0002
	beq	loc_02E4EB
	lda	a:td_p2_obj+$2C
	ora	a:td_p1_obj+$2C
	bne	loc_02E4D8
loc_02E4EB:
	lda	zp_08
	bne	loc_02E4F7
	inc	zp_08
	inc	zp_0C
	dec	zp_0E
	beq	loc_02E4D8
loc_02E4F7:
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E4FF:
	jsl	f:add_window_off_16_lines
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$32
	sta	zp_14
	lda	a:td_p2_bomb+$36
	sta	zp_16
	lda	#$0078
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E528
loc_02E522:
	jsl	f:add_window_off_span
	bra	loc_02E53D
loc_02E528:
	lda	#$0002
	bne	loc_02E535
	lda	a:td_p2_obj+$2C
	ora	a:td_p1_obj+$2C
	bne	loc_02E522
loc_02E535:
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
loc_02E53D:
	jsl	f:end_window_hdma_table
	rtl
loc_02E542:
	sep	#$20
	.a8
	lda	#$13
	sta	a:CGADSUB
	sta	f:hdma_tables+$63
	sta	f:hdma_tables+$67
	lda	#$10
	sta	a:CGWSEL
	lda	#$20
	sta	a:WOBJSEL
	lda	#$3F
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	a:td_p2_bomb+$24
	lsr	a
	lsr	a
	and	#$001F
	ora	#$00C0
	sep	#$20
	.a8
	sta	a:COLDATA
	rep	#$20
	.a16
	lda	#$3E00
	sta	zp_1E
	lda	a:td_p2_bomb+$24
	asl	a
	and	#$00FF
	sta	zp_10
	lda	a:title_menu_cursor
	beq	loc_02E5BD
	dec	a
	bne	loc_02E58D
	brl	loc_02E5F2
loc_02E58D:
	; (not executed in the CDL traces)
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$38
	sta	zp_14
	lda	a:td_p2_bomb+$3C
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E5B8
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E5B8:
	jsl	f:end_window_hdma_table
	rtl
loc_02E5BD:
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$38
	sta	zp_14
	lda	a:td_p2_bomb+$3C
	sta	zp_16
	lda	#$0018
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:add_window_off_24_lines
	jsl	f:clip_window_circle
	bcs	loc_02E5ED
	lda	a:td_p2_obj+$2C
	bne	loc_02E5ED
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E5ED:
	jsl	f:end_window_hdma_table
	rtl
loc_02E5F2:
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$38
	sta	zp_14
	lda	a:td_p2_bomb+$3C
	sta	zp_16
	lda	#$0000
	sta	zp_18
	lda	#$0068
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E617
loc_02E611:
	jsl	f:add_window_off_span
	bra	loc_02E624
loc_02E617:
	lda	a:td_p1_obj+$2C
	bne	loc_02E611
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E624:
	jsl	f:add_window_off_16_lines
	lda	#$3E20
	sta	zp_1C
	lda	a:td_p2_bomb+$3A
	sta	zp_14
	lda	a:td_p2_bomb+$3E
	sta	zp_16
	lda	#$0078
	sta	zp_18
	lda	#$00E0
	sta	zp_1A
	jsl	f:clip_window_circle
	bcc	loc_02E64D
loc_02E647:
	jsl	f:add_window_off_span
	bra	loc_02E65A
loc_02E64D:
	lda	a:td_p2_obj+$2C
	bne	loc_02E647
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
loc_02E65A:
	jsl	f:end_window_hdma_table
	rtl
