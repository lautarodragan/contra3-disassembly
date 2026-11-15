; engine/window_effect.asm -- Window effects of the barrier and the bomb
; Bank $00, $00:E7EF-$00:E95F. Included by main.asm in segment BANK00.
;
; update_player_window (from the side-view NMI frame handler) builds the window
; HDMA tables around a player while its bomb is exploding
; (PLAYER_BOMB_RADIUS) or it has the barrier (PLAYER_BARRIER), with the
; circle routines of effects/window_shapes.asm (clip_window_circle,
; build_window_circle, build_window_hdma_lines, end_window_hdma_table).

; Per frame (side-view stages): picks one player (alternating by
; stage_frame_odd when both are alive) and builds the window HDMA tables in
; $7E:xxxx for it: the bomb blast (a colour-math circle of radius A =
; PLAYER_BOMB_RADIUS around PLAYER_BOMB_X/Y, setup_bomb_window) or, with
; the barrier, a wavy circle around PLAYER_CENTER_X/Y (setup_barrier_window,
; copy_window_hdma_lines, wobble_barrier_window); none: windows off (coldata_shadow = 0).
update_player_window:
	lda	stage_frame_odd
	asl	a
	tay
	lda	a:p2_lives
	beq	loc_00E80C
	lda	a:p1_lives
	beq	loc_00E805
	lda	a:data_05A39E,y
	tax
	sta	zp_FE
	bra	loc_00E811
loc_00E805:
	; (not executed in the CDL traces)
	ldx	#$0240
	stx	zp_FE
	bra	loc_00E811
loc_00E80C:
	ldx	#$0200
	stx	zp_FE
loc_00E811:
	lda	a:data_05A3A2,y
	sta	zp_C6
	lda	a:data_05A3A6,y
	sta	zp_9E
	sta	zp_1E
	clc
	adc	#$0020
	sta	zp_1C
	lda	a:PLAYER_BOMB_RADIUS,x
	bne	loc_00E855
	lda	a:PLAYER_BARRIER,x
	bne	loc_00E839
loc_00E82D:
	stz	zp_9E
	stz	zp_C6
	jsl	f:end_window_hdma_table
	stz	a:coldata_shadow
	rtl
loc_00E839:
	jsr	a:setup_barrier_window
	jsl	f:clip_window_circle
	bcs	loc_00E82D
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
	jsr	a:copy_window_hdma_lines
	jsr	a:wobble_barrier_window
	jsl	f:end_window_hdma_table
	rtl
loc_00E855:
	jsr	a:setup_bomb_window
	jsl	f:clip_window_circle
	bcs	loc_00E82D
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_circle
	jsl	f:end_window_hdma_table
	rtl

; Window settings (W12SEL/TMW shadows) and a circle of radius $18 around
; PLAYER_CENTER_X/Y of the player at X, for the barrier.
setup_barrier_window:
	lda	#$0022
	sta	a:w12sel_shadow
	lda	#$0203
	sta	a:tmw_shadow
	stz	a:coldata_shadow
	lda	#$A42A
	sta	zp_12
	lda	#$0018
	sta	zp_10
	lda	a:PLAYER_CENTER_X,x
	sta	zp_14
	lda	a:PLAYER_CENTER_Y,x
	sta	zp_16
	stz	zp_18
	lda	#$00E0
	sta	zp_1A
	rts

; In: A = radius.  Colour math window (colour from wram_16AA/wram_16AC)
; around the bomb centre of the player at X.
setup_bomb_window:
	sta	zp_10
	and	a:wram_16AA
	ora	a:wram_16AC
	sta	a:coldata_shadow
	lda	#$0023
	sta	a:w12sel_shadow
	lda	#$0200
	sta	a:tmw_shadow
	lda	a:PLAYER_BOMB_X,x
	sta	zp_14
	lda	a:PLAYER_BOMB_Y,x
	sta	zp_16
	stz	zp_18
	lda	#$00E0
	sta	zp_1A
	stz	zp_C6
	rts

; Copies the 16-byte line-count part of the window HDMA table (zp_9E) to
; zp_C6 and points its entries $20 bytes further (the colour table of the
; barrier).
copy_window_hdma_lines:
	ldx	zp_9E
	ldy	zp_C6
	tya
	clc
	adc	#$0010
	sta	zp_FC
loc_00E8CC:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	a:$0000,x
	sta	a:$0000,y
	inx
	inx
	iny
	iny
	cpy	zp_FC
	bcc	loc_00E8CC
	ldx	zp_C6
loc_00E8E4:
	sep	#$20
	.a8
	lda	a:$0001,x
	cmp	#$1E
	bne	loc_00E8FF
	inx
	inx
	inx
	cpx	zp_FC
	bcc	loc_00E8E4
	; (not executed in the CDL traces)
	sep	#$20
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rep	#$20
	rts
loc_00E8FF:
	.a8
	rep	#$20
	.a16
	clc
	lda	zp_C6
	adc	#$0020
	sta	a:$0001,x
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts

; Wobbles the barrier circle: adds data_05A3AA (a sine-like table, scrolled
; by stage_frame_counter) to the table, with a colour that changes when the
; barrier has less than $60 frames left (it blinks before running out).
wobble_barrier_window:
	lda	zp_06
	sta	zp_FC
	ldx	zp_FE
	ldy	#$8F40
	lda	a:PLAYER_BARRIER,x
	cmp	#$0060
	bcs	loc_00E927
	ldy	#$0F20
loc_00E927:
	sty	zp_00
	lda	stage_frame_counter
	asl	a
	asl	a
	eor	#$FFFF
	and	#$007F
	tax
	ldy	zp_C6
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00E93E:
	.a16
	lda	f:data_05A3AA,x
	and	#$00FF
	ora	zp_00
	xba
	sta	a:$0020,y
	iny
	iny
	inx
	txa
	and	#$007F
	tax
	dec	zp_FC
	bne	loc_00E93E
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rts
