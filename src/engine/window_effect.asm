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
	beq	@player1
	lda	a:p1_lives
	beq	@player2
	lda	a:window_player_by_frame,y
	tax
	sta	zp_FE
	bra	@have_player
@player2:
	; (not executed in the CDL traces)
	ldx	#$0240
	stx	zp_FE
	bra	@have_player
@player1:
	ldx	#$0200
	stx	zp_FE
@have_player:
	lda	a:coldata_hdma_buffers,y
	sta	zp_C6
	lda	a:window_hdma_buffers,y
	sta	zp_9E
	sta	zp_1E
	clc
	adc	#$0020
	sta	zp_1C
	lda	a:PLAYER_BOMB_RADIUS,x
	bne	@bomb
	lda	a:PLAYER_BARRIER,x
	bne	@barrier
@windows_off:
	stz	zp_9E
	stz	zp_C6
	jsl	f:end_window_hdma_table
	stz	a:coldata_shadow
	rtl
@barrier:
	jsr	a:setup_barrier_window
	jsl	f:clip_window_circle
	bcs	@windows_off
	jsl	f:build_window_hdma_lines
	jsl	f:build_window_from_widths
	jsr	a:copy_window_hdma_lines
	jsr	a:wobble_barrier_window
	jsl	f:end_window_hdma_table
	rtl
@bomb:
	jsr	a:setup_bomb_window
	jsl	f:clip_window_circle
	bcs	@windows_off
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
	lda	#.loword(barrier_wobble_offsets + $80)
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

; In: A = radius.  Colour math window (colour from bomb_coldata_mask/bomb_coldata_bits)
; around the bomb centre of the player at X.
setup_bomb_window:
	sta	zp_10
	and	a:bomb_coldata_mask
	ora	a:bomb_coldata_bits
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
@loop:
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
	bcc	@loop
	ldx	zp_C6
@loop2:
	sep	#$20
	.a8
	lda	a:$0001,x
	cmp	#$1E
	bne	@found
	inx
	inx
	inx
	cpx	zp_FC
	bcc	@loop2
	; (not executed in the CDL traces)
	sep	#$20
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rep	#$20
	rts
@found:
	.a8
	rep	#$20
	.a16
	clc
	lda	zp_C6
	adc	#$0020
	sta	a:$0001,x
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts

; Wobbles the barrier circle: adds barrier_wobble_offsets (a sine-like table, scrolled
; by stage_frame_counter) to the table, with a colour that changes when the
; barrier has less than $60 frames left (it blinks before running out).
wobble_barrier_window:
	lda	zp_06
	sta	zp_FC
	ldx	zp_FE
	ldy	#$8F40	; [num]
	lda	a:PLAYER_BARRIER,x
	cmp	#$0060
	bcs	@store_colour
	ldy	#$0F20
@store_colour:
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
@loop:
	.a16
	lda	f:barrier_wobble_offsets,x
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
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rts
