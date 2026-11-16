; topdown/sprite_render.asm -- Top-down stages: sprite projection and OAM
; Bank $03, $03:E180-$03:FFFF. Included by main.asm in segment BANK03.
;
; draw_topdown_sprites (from the top-down NMI frame handler nmi_frame_top_down)
; projects every object from map coordinates into the rotated view
; (project_to_view, with the tables of sine_products.asm) and builds the OAM
; buffer at $0FC0 (high table $11C0), one player view per frame (alternate
; frames in 2P-A). It also picks the rotated graphics of the players and
; enemies and lists them at $1780/$17C0 for stream_topdown_sprite_gfx.

; NMI (top-down): builds the OAM buffer for player 1's view (player 2's on
; odd frames in 2P-A): projects every object through the view's rotation.
draw_topdown_sprites:
	.a16
	.i16
	rep	#$30
	lda	a:title_menu_cursor
	beq	@player1_view
	dec	a
	bne	@player1_view
	lda	frame_counter
	lsr	a
	bcs	@player2_view
@player1_view:
	jml	f:draw_p1_view_sprites
@player2_view:
	jml	f:draw_p2_view_sprites

; Rotates the map point (Y = x, A = y) into the view set up by
; setup_p1_view_projection: screen x/y in zp_00/zp_02; carry set when farther than
; $B8 pixels on an axis. Uses the products of sine_products.asm.
project_to_view:
	phx
	ldx	zp_DA
	jmp	(.loword(tbl_project_quadrants),x)
tbl_project_quadrants:
	.addr	project_quadrant_0
	.addr	project_quadrant_1
	.addr	project_quadrant_2
	.addr	project_quadrant_3

; project_to_view for view angles $00-$3F.
project_quadrant_0:
	sec
	sbc	zp_1A
	bmi	@above
	cmp	#$00B8
	bcs	@far
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@left
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	[zp_D7],y
	sec
	sbc	zp_DD
	clc
	adc	zp_1E
	sta	zp_02
	clc
@far:
	plx
	rts
@left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	[zp_D4],y
	sec
	sbc	zp_E0
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts
@above:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@above_left
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	clc
@far2:
	plx
	rts
@above_left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts

; project_to_view for view angles $40-$7F.
project_quadrant_1:
	sec
	sbc	zp_1A
	bmi	@above
	cmp	#$00B8
	bcs	@far
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@left
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	[zp_D7],y
	sec
	sbc	zp_DD
	clc
	adc	zp_1C
	sta	zp_00
	clc
@far:
	plx
	rts
@left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
@above:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@above_left
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	clc
@far2:
	plx
	rts
@above_left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts

; project_to_view for view angles $80-$BF.
project_quadrant_2:
	sec
	sbc	zp_1A
	bmi	@above
	cmp	#$00B8
	bcs	@far
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@left
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
@far:
	plx
	rts
@left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts
@above:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@above_left
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_DD
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1E
	sta	zp_02
	clc
@far2:
	plx
	rts
@above_left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	lda	zp_E0
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
	plx
	rts

; project_to_view for view angles $C0-$FF.
project_quadrant_3:
	sec
	sbc	zp_1A
	bmi	@above
	cmp	#$00B8
	bcs	@far
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@left
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	clc
	adc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	sec
	sbc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
@far:
	plx
	rts
@left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	clc
	adc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	[zp_D4],y
	sec
	sbc	zp_E0
	clc
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
@above:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	@above_left
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D4],y
	sta	zp_DD
	lda	[zp_D7],y
	txy
	sec
	sbc	[zp_D4],y
	clc
	adc	zp_1E
	sta	zp_02
	lda	zp_DD
	clc
	adc	[zp_D7],y
	clc
	adc	zp_1C
	sta	zp_00
	clc
@far2:
	plx
	rts
@above_left:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	@far2
	asl	a
	tay
	lda	[zp_D7],y
	sta	zp_E0
	lda	[zp_D4],y
	txy
	sec
	sbc	[zp_D7],y
	eor	#$FFFF
	sec
	adc	zp_1C
	sta	zp_00
	lda	zp_E0
	clc
	adc	[zp_D4],y
	eor	#$FFFF
	sec
	adc	zp_1E
	sta	zp_02
	clc
	plx
	rts
; Sprites of the Select map view: players, targets at 1/5 scale.
draw_map_view_sprites:
	; (not executed in the CDL traces)
	ldy	#$0FC0
	lda	#$AAAA	; [num]
	sta	a:oam_hi_table
	lda	#$AAAA	; [num]
	sta	a:oam_hi_table+2
	lda	a:p1_lives
	bne	@p1_marker
	brl	@p2
@p1_marker:
	ldx	#$0EC0
	jsr	a:map_view_player_position
	jsr	a:map_view_p1_marker
	jsr	a:write_map_view_p1_marker
@p2:
	lda	a:p2_lives
	bne	@p2_marker
	brl	@write_p2_marker
@p2_marker:
	ldx	#$0F00
	jsr	a:map_view_player_position
	jsr	a:map_view_p2_marker
@write_p2_marker:
	jsr	a:write_map_view_p2_marker
	jsr	a:draw_map_view_targets
	lda	#$F000	; [num]
@loop:
	sta	a:$0000,y
	iny
	iny
	iny
	iny
	cpy	#$11C0
	bcc	@loop
	rtl

map_view_player_position:
	; (not executed in the CDL traces)
	phy
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$000A
	clc
	adc	a:RDDIVL
	sta	zp_02
	lda	$04,x
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:map_view_player_marker_sprites,y
	sta	zp_04
	lda	$02,x
	and	#$0E00
	ora	#$3100
	sta	zp_06
	ply
	rts

map_view_p1_marker:
	; (not executed in the CDL traces)
	lda	$0E,x
	and	#$03FF
	cmp	#$0200
	bcs	@lower_half
	lda	#$002A
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
@lower_half:
	lda	#$0000
	sta	zp_08
	lda	#$FFE8	; [num]
	sta	zp_0A
	rts

map_view_p2_marker:
	; (not executed in the CDL traces)
	lda	$0E,x
	and	#$03FF
	cmp	#$0200
	bcs	@lower_half
	lda	#$002C
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
@lower_half:
	lda	#$0002
	sta	zp_08
	lda	#$FFE8	; [num]
	sta	zp_0A
	rts

write_map_view_p1_marker:
	; (not executed in the CDL traces)
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	zp_0A
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_08
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts

write_map_view_p2_marker:
	; (not executed in the CDL traces)
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	zp_0A
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_08
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts

draw_map_view_targets:
	; (not executed in the CDL traces)
	jsr	a:get_target_marker_attr
	ldx	#$0AC0
@loop:
	lda	$10,x
	beq	@next
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$000A
	clc
	adc	a:RDDIVL
	sta	zp_02
	jsr	a:write_target_marker
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@loop
	rts

write_target_marker:
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0008
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	rts
; Sprites of the start-point intro (cursors).
draw_intro_sprites:
	ldy	#$0FC0
	lda	#$AAAA	; [num]
	sta	a:oam_hi_table
	lda	#$AAAA	; [num]
	sta	a:oam_hi_table+2
	lda	#$AAAA	; [num]
	sta	a:oam_hi_table+4
	lda	#$0002
	sta	a:oam_hi_table+6
	lda	a:intro_phase
	dec	a
	beq	@choosing
	brl	@hide_rest
@choosing:
	jsr	a:draw_intro_banner_sprites
	jsr	a:draw_p1_start_cursor
	jsr	a:draw_p2_start_cursor
	jsr	a:draw_intro_target_markers
@hide_rest:
	lda	#$F000	; [num]
@loop:
	sta	a:$0000,y
	iny
	iny
	iny
	iny
	cpy	#$11C0
	bcc	@loop
	rtl

; Player 1's start-point cursor (blinks once chosen).
draw_p1_start_cursor:
	lda	a:p1_lives
	bne	@has_lives
	; (not executed in the CDL traces)
	brl	@return
@has_lives:
	phy
	lda	a:p1_start_x
	asl	a
	tay
	lda	a:start_cursor_x,y
	sta	zp_00
	lda	a:p1_start_y
	asl	a
	tay
	lda	a:start_cursor_y,y
	sta	zp_02
	ply
	lda	#$3900
	sta	zp_06
	lda	a:p1_start_chosen
	beq	@draw
	lda	stage_frame_counter
	bit	#$0004
	beq	@draw
	brl	@return
@draw:
	lda	zp_02
	sec
	sbc	#$0008
	sta	a:$0001,y
	sep	#$20
	.a8
	lda	zp_00
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0000
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$4026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$8026	; [num]
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$C026	; [num]
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
@return:
	rts

; Player 2's start-point cursor.
draw_p2_start_cursor:
	lda	a:title_menu_cursor
	bne	@two_players
	brl	@return
@two_players:
	lda	a:p2_lives
	bne	@has_lives
	; (not executed in the CDL traces)
	brl	@return
@has_lives:
	phy
	lda	a:p2_start_x
	asl	a
	tay
	lda	a:start_cursor_x,y
	sta	zp_00
	lda	a:p2_start_y
	asl	a
	tay
	lda	a:start_cursor_y,y
	sta	zp_02
	ply
	lda	#$3B00
	sta	zp_06
	lda	a:p2_start_chosen
	beq	@draw
	lda	stage_frame_counter
	bit	#$0004
	bne	@draw
	brl	@return
@draw:
	lda	zp_02
	clc
	adc	#$0008
	sta	a:$0001,y
	lda	zp_00
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$002C
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$0026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	sec
	sbc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$4026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	sec
	sbc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$8026	; [num]
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	lda	zp_02
	clc
	adc	#$0010
	sta	a:$0001,y
	lda	zp_00
	clc
	adc	#$0010
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	#$C026	; [num]
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
@return:
	rts

draw_intro_banner_sprites:
	ldx	#$0014
@loop:
	lda	#$0008
	sta	a:$0001,y
	lda	a:intro_banner_sprite_x,x
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	a:intro_banner_sprite_tiles,x
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	dex
	dex
	bne	@loop
	rts

draw_intro_target_markers:
	jsr	a:get_target_marker_attr
	ldx	#$0AC0
@loop:
	lda	$10,x
	beq	@next
	lda	$0A,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_00
	lda	$0E,x
	and	#$03FF
	sta	a:WRDIVL
	sep	#$20
	.a8
	lda	#$05
	sta	a:WRDIVB
	rep	#$20
	.a16
	nop
	nop
	nop
	nop
	lda	#$001A
	clc
	adc	a:RDDIVL
	sta	zp_02
	jsr	a:write_target_marker
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0D40
	bcc	@loop
	rts

get_target_marker_attr:
	ldx	#$0000
	lda	stage_frame_counter
	bit	#$0003
	bne	@pick_stage
	ldx	#$0002
@pick_stage:
	stx	zp_FA
	lda	#$0000
	ldx	stage_number
	cpx	#$0002
	beq	@combine
	lda	#$0004
@combine:
	ora	zp_FA
	tax
	lda	a:td_target_marker_attrs,x
	sta	zp_06
	rts
; Sprites of player 1's view (or the intro / map view ones).
draw_p1_view_sprites:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	@stage2_boss
	cmp	#TD_MAP_STAGE5_BOSS
	bne	@normal_map
	brl	@stage5_boss
@normal_map:
	lda	a:intro_phase
	beq	@not_intro
	brl	draw_intro_sprites
@not_intro:
	lda	a:map_view_active
	beq	@play
	; (not executed in the CDL traces)
	brl	draw_map_view_sprites
@play:
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p1_view_projection
	jsr	a:draw_target_arrows
	jsr	a:start_oam_list
	jsr	a:is_p1_view_falling
	bcs	@end_small
	jsr	a:draw_small_objects
	jsr	a:draw_td_items
@end_small:
	jsr	a:end_small_sprites
	jsr	a:draw_enemies
	jsr	a:draw_topdown_players
	jsr	a:project_map_objects
	jsr	a:project_td_bombs
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
@stage2_boss:
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p1_view_projection
	jsr	a:draw_target_arrows
	jsr	a:start_oam_list
	jsr	a:draw_small_objects
	jsr	a:draw_td_items
	jsr	a:end_small_sprites
	jsr	a:draw_stage2_boss_cannon
	jsr	a:draw_players_stage2_boss
	jsr	a:draw_stage2_boss_arena
	jsr	a:project_map_objects
	jsr	a:project_td_bombs
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
@stage5_boss:
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p1_view_projection
	jsr	a:draw_target_arrows
	jsr	a:start_oam_list
	jsr	a:is_p1_view_falling
	bcs	@end_small2
	jsr	a:draw_small_objects
	jsr	a:draw_td_items
@end_small2:
	jsr	a:end_small_sprites
	jsr	a:project_stage5_boss_objects
	jsr	a:draw_stage5_boss_claw_section
	jsr	a:draw_stage5_boss_arm
	jsr	a:draw_topdown_players
	jsr	a:project_td_bombs
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

is_p1_view_falling:
	lda	a:title_menu_cursor
	beq	@check_fall
	dec	a
	bne	@return_clc
@check_fall:
	lda	a:td_p1_obj+$2C
	beq	@return_clc
	sec
	rts
@return_clc:
	clc
	rts

; Sets up project_to_view for player 1's view: centre, anchor, angle
; quadrant (zp_DA) and the two product tables for the angle (zp_D4, zp_D7).
setup_p1_view_projection:
	lda	a:title_menu_cursor
	beq	@full_screen
	dec	a
	beq	@top_half
@full_screen:
	lda	#$0008
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
	bra	@tables
@top_half:
	lda	#$FFF0	; [num]
	sta	a:zp_0C
	lda	#$0068
	sta	a:zp_0E
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
@tables:
	asl	a
	asl	a
	asl	a
	xba
	and	#$0006
	sta	zp_DA
	lda	zp_16
	and	#$003F
	xba
	sta	zp_D4
	lsr	a
	clc
	adc	zp_D4
	clc
	adc	#.loword(sine_products)
	sta	zp_D4
	lda	zp_16
	and	#$003F
	eor	#$003F
	inc	a
	xba
	sta	zp_D7
	lsr	a
	clc
	adc	zp_D7
	clc
	adc	#.loword(sine_products)
	sta	zp_D7
	sep	#$20
	.a8
	lda	#^sine_products
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

; Copies the two target arrows (objects $0200 and $0240) to the first OAM entries.
draw_target_arrows:
	lda	a:td_arrow_objs+OBJ_X
	sta	a:oam_buffer
	lda	a:td_arrow_objs+OBJ_Y
	sta	a:oam_buffer+1
	lda	a:td_arrow_objs
	sta	a:oam_buffer+2
	lda	a:td_arrow_objs+1*OBJ_SIZE+OBJ_X
	sta	a:oam_buffer+4
	lda	a:td_arrow_objs+1*OBJ_SIZE+OBJ_Y
	sta	a:oam_buffer+5
	lda	a:td_arrow_objs+1*OBJ_SIZE
	sta	a:oam_buffer+6
	lda	a:oam_hi_table
	and	#$FF00
	ora	#$00AA
	sta	a:oam_hi_table
	rts

; OAM write pointer zp_10 = $0FD0, high table pointer zp_12 = $11C0.
start_oam_list:
	ldx	#$0FD0
	stx	zp_10
	ldx	#$11C0
	stx	zp_12
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
	rts

; One sprite per object of the $20-byte slots $0300-$097F (shots), its tile
; picked by its angle relative to the view (td_small_object_tiles).
draw_small_objects:
	ldx	#$0300
@slot_loop:
	lda	$10,x
	beq	@next_slot
	lda	$04,x
	bmi	@fixed_tile
	sec
	sbc	a:p1_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:td_small_object_tiles,y
	bra	@tile_ready
@fixed_tile:
	lda	$00,x
	beq	@next_slot
@tile_ready:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	@next_slot
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	@next_slot
	cmp	zp_0E
	bpl	@next_slot
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	@next_slot
	cmp	#$FFF0	; [num]
	bmi	@next_slot
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	lda	$16,x
	cmp	#$0008
	ror	zp_14
	bcc	@next_slot
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@next_slot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	@slot_loop
@return:
	rts

draw_td_items:
	ldx	#$0980
@loop:
	lda	$00,x
	beq	@next
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	@next
	lda	$02,x
	ora	#$0100
	sta	zp_06
	ldy	$00,x
	phx
	jsr	a:draw_td_item_metasprite
	plx
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop
	rts

; Ends the first OAM section: hides the entries left up to $10C0.
end_small_sprites:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10C0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10C0
	bcc	@loop2
@return:
	rts

; Enemies ($0D40-$0EBF): metasprite by type and relative angle, and their
; graphics queued in the stream list at $1780 (stream_topdown_sprite_gfx).
draw_enemies:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	lda	a:title_menu_cursor
	beq	@check_fall
	dec	a
	bne	@draw
@check_fall:
	lda	a:td_p1_obj+$2C
	beq	@draw
	brl	@hide_rest
@draw:
	stz	zp_08
	ldx	#$0D40
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	@next_slot
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_enemy_sprite_attrs,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	@next_slot
@some_drawn:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1120
	bcc	@loop2
@return:
	rts

; Players ($0EC0, $0F00), like draw_enemies; their screen positions in +$B0/+$B4.
draw_topdown_players:
	ldx	#$1180
	stx	zp_10
	ldx	#$11DC
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
@slot_loop:
	lda	a:title_menu_cursor
	beq	@one_view
	dec	a
	beq	@one_view
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	@draw
	brl	@next_slot
@one_view:
	cpx	#$0EC0
	beq	@draw
	lda	a:td_p1_obj+$2C
	ora	a:td_p2_obj+$2C
	bne	@next_slot
@draw:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	#$8000	; [num]
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	@next_slot
@in_range:
	lda	zp_00
	sta	a:$00B0,x
	lda	zp_02
	sta	a:$00B4,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_player_sprite_attrs,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_player_stream_slots,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11A0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11A0
	bcc	@loop2
@return:
	rts

draw_stage2_boss_cannon:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$0000
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@cannon
@keep_hi_bits:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@cannon:
	ldx	#$0B80
	lda	$00,x
	beq	@hide_rest
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	@hide_rest
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	#$0004
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ora	a:td_enemy_sprite_attrs
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	@hide_rest
@some_drawn:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10D0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10D0
	bcc	@loop2
@return:
	rts

draw_players_stage2_boss:
	ldx	#$10E0
	stx	zp_10
	ldx	#$11D2
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	@next_slot
@in_range:
	lda	zp_00
	sta	a:$00B0,x
	lda	zp_02
	sta	a:$00B4,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_player_sprite_attrs,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_player_stream_slots,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1100
	bcc	@loop2
@return:
	rts

draw_stage2_boss_arena:
	ldx	#$1120
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$0000
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@rubble
@keep_hi_bits:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@rubble:
	lda	#$1028
	sta	zp_06
	lda	#$0040
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:stage2_arena_rubble_metasprites,y
	sta	zp_CA
	lda	a:stage2_arena_rubble_tile_list,y
	ldy	#$0020
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
@rubble_loop:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:stage2_arena_rubble_x - 2,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_rubble_y,x
	jsr	a:project_to_view
	bcs	@next_rubble
	ldy	zp_CA
	jsr	a:draw_topdown_metasprite
@next_rubble:
	dec	zp_08
	dec	zp_08
	bne	@rubble_loop
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$1024
	bit	#$0020
	beq	@debris
	ldy	#$D024	; [num]
@debris:
	sty	zp_06
	tay
	lda	a:stage2_arena_debris_tile_list,y
	ldy	#$0018
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
@debris_loop:
	lda	zp_C4
	clc
	adc	a:stage2_arena_debris_x,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_debris_y,x
	jsr	a:project_to_view
	bcs	@next_debris
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	@next_debris
	cmp	zp_0E
	bpl	@next_debris
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	@next_debris
	cmp	#$FFF0	; [num]
	bmi	@next_debris
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	@next_debris
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@next_debris:
	dex
	dex
	bne	@debris_loop
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1170
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1170
	bcc	@loop2
@return:
	rts

; Writes the metasprite at Y to OAM at screen zp_00/zp_02 (+screen shake),
; clipped to the view; zp_D0 = number of sprites written.
draw_topdown_metasprite:
	stz	zp_D0
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
@sprite_loop:
	stz	zp_CD
	lda	a:$0001,y
	bpl	@y_extended
	dec	zp_CD
@y_extended:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	@next_sprite
	cmp	zp_0E
	bpl	@next_sprite
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	@x_extended
	dec	zp_CD
@x_extended:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	@next_sprite
	cmp	#$FFF0	; [num]
	bmi	@next_sprite
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	inc	zp_D0
	lda	a:$0003,y
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_14
	bcc	@next_sprite
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000	; [num]
	sta	zp_14
	stx	zp_12
	plx
@next_sprite:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	@sprite_loop
	stx	zp_10
	rts

draw_td_item_metasprite:
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
@sprite_loop:
	stz	zp_CD
	lda	a:$0001,y
	bpl	@y_extended
	dec	zp_CD
@y_extended:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	@next_sprite
	cmp	zp_0E
	bpl	@next_sprite
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	@x_extended
	dec	zp_CD
@x_extended:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	@next_sprite
	cmp	#$FFF0	; [num]
	bmi	@next_sprite
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	lda	a:$0003,y
	and	#$C0FF
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	lda	a:$0004,y
	lsr	a
	ror	zp_14
	bcc	@next_sprite
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000	; [num]
	sta	zp_14
	stx	zp_12
	plx
@next_sprite:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	@sprite_loop
	stx	zp_10
	rts

; Projects the map objects ($0AC0-$0EBF): screen position in +$18/+$1C,
; +$2E bit 2 = in projection range, bit 0 = on screen.
project_map_objects:
	ldx	#$0AC0
@slot_loop:
	lda	$10,x
	beq	@next_slot
	cpx	#$0D40
	bcs	@enemy_slot
	cmp	#$0003
	beq	@next_slot
	bra	@project
@enemy_slot:
	lda	$00,x
	bne	@next_slot
@project:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_00
	sta	$18,x
	lda	zp_02
	sta	$1C,x
	lda	zp_02
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	lda	zp_00
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@slot_loop
	rts

; Screen positions (+$38/+$3C) of the smart bombs ($8000 when out of range).
project_td_bombs:
	lda	a:td_p1_obj+$2C
	bne	@check_p2_fall
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	@p2_bomb
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@p1_in_range
	lda	#$8000	; [num]
	sta	$38,x
	sta	$3C,x
	bra	@p2_bomb
@p1_in_range:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
@check_p2_fall:
	lda	a:td_p2_obj+$2C
	bne	@return
@p2_bomb:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	@return
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@p2_in_range
	lda	#$8000	; [num]
	sta	$38,x
	sta	$3C,x
	bra	@return
@p2_in_range:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
@return:
	rts

project_stage5_boss_objects:
	ldx	#$0AC0
@slot_loop:
	lda	$10,x
	beq	@next_slot
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	lda	zp_00
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	@slot_loop
	rts

draw_stage5_boss_claw_section:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	jsr	a:is_p1_view_falling_2
	bcs	@hide_rest
	jsr	a:draw_stage5_boss_claw
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10E0
	bcc	@loop2
@return:
	rts

draw_stage5_boss_claw:
	stz	zp_08
	ldx	#$0B40
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	@next_slot
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_enemy_sprite_attrs,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	@next_slot
@some_drawn:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	@return
	brl	@slot_loop
@return:
	rts

is_p1_view_falling_2:
	lda	a:title_menu_cursor
	beq	@check_fall
	; (not executed in the CDL traces)
	dec	a
	bne	@return_clc
@check_fall:
	lda	a:td_p1_obj+$2C
	beq	@return_clc
	; (not executed in the CDL traces)
	brl	@return_sec
@return_clc:
	clc
	rts
@return_sec:
	; (not executed in the CDL traces)
	sec
	rts

draw_stage5_boss_arm:
	ldx	#$1100
	stx	zp_10
	ldx	#$11D4
	stx	zp_12
	lda	#$0000
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@segments
@keep_hi_bits:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@segments:
	ldx	#$0BC0
@slot_loop:
	lda	$00,x
	beq	@next_slot
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	@on_screen
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@on_screen:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1130
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1130
	bcc	@loop2
@return:
	rts
; Sprites of player 2's view (2P-A, odd frames).
draw_p2_view_sprites:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	@stage2_boss
	cmp	#TD_MAP_STAGE5_BOSS
	bne	@normal_map
	; (not executed in the CDL traces)
	brl	@stage5_boss
@normal_map:
	lda	a:intro_phase
	beq	@not_intro
	brl	draw_intro_sprites
@not_intro:
	lda	a:map_view_active
	beq	@play
	; (not executed in the CDL traces)
	brl	draw_map_view_sprites
@play:
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p2_view_projection
	jsr	a:draw_target_arrows_p2
	jsr	a:start_oam_list_p2
	jsr	a:is_p2_view_falling
	bcs	@end_small
	jsr	a:draw_small_objects_p2
	jsr	a:draw_td_items_p2
@end_small:
	jsr	a:end_small_sprites_p2
	jsr	a:draw_enemies_p2
	jsr	a:draw_topdown_players_p2
	jsr	a:project_map_objects_p2
	jsr	a:project_td_bombs_p2
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
@stage2_boss:
	; (not executed in the CDL traces)
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p2_view_projection
	jsr	a:draw_target_arrows_p2
	jsr	a:start_oam_list_p2
	jsr	a:draw_small_objects_p2
	jsr	a:draw_td_items_p2
	jsr	a:end_small_sprites_p2
	jsr	a:draw_stage2_boss_cannon_p2
	jsr	a:draw_players_stage2_boss_p2
	jsr	a:draw_stage2_boss_arena_p2
	jsr	a:project_map_objects_p2
	jsr	a:project_td_bombs_p2
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
@stage5_boss:
	sep	#$20
	.a8
	lda	#^sprite_data_07
	pha
	plb
	rep	#$20
	.a16
	jsr	a:setup_p2_view_projection
	jsr	a:draw_target_arrows_p2
	jsr	a:start_oam_list_p2
	jsr	a:is_p2_view_falling
	bcs	@end_small2
	jsr	a:draw_small_objects_p2
	jsr	a:draw_td_items_p2
@end_small2:
	jsr	a:end_small_sprites_p2
	jsr	a:project_stage5_boss_objects_p2
	jsr	a:draw_stage5_boss_claw_section_p2
	jsr	a:draw_stage5_boss_arm_p2
	jsr	a:draw_topdown_players_p2
	jsr	a:project_td_bombs_p2
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

is_p2_view_falling:
	lda	a:title_menu_cursor
	beq	@check_fall
	dec	a
	bne	@return_clc
@check_fall:
	lda	a:td_p2_obj+$2C
	beq	@return_clc
	sec
	rts
@return_clc:
	clc
	rts

setup_p2_view_projection:
	lda	a:title_menu_cursor
	beq	@full_screen
	dec	a
	beq	@bottom_half
@full_screen:
	; (not executed in the CDL traces)
	lda	#$0008
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p2_view_anchor_x
	sta	zp_1C
	lda	a:p2_view_anchor_y
	sta	zp_1E
	lda	a:p2_view_x
	sta	zp_18
	lda	a:p2_view_y
	sta	zp_1A
	lda	a:p2_view_angle
	sta	zp_16
	bra	@tables
@bottom_half:
	lda	#$0068
	sta	a:zp_0C
	lda	#$00E0
	sta	a:zp_0E
	lda	a:p2_view_anchor_x
	sta	zp_1C
	lda	a:p2_view_anchor_y
	sta	zp_1E
	lda	a:p2_view_x
	sta	zp_18
	lda	a:p2_view_y
	sta	zp_1A
	lda	a:p2_view_angle
	sta	zp_16
@tables:
	asl	a
	asl	a
	asl	a
	xba
	and	#$0006
	sta	zp_DA
	lda	zp_16
	and	#$003F
	xba
	sta	zp_D4
	lsr	a
	clc
	adc	zp_D4
	clc
	adc	#.loword(sine_products)
	sta	zp_D4
	lda	zp_16
	and	#$003F
	eor	#$003F
	inc	a
	xba
	sta	zp_D7
	lsr	a
	clc
	adc	zp_D7
	clc
	adc	#.loword(sine_products)
	sta	zp_D7
	sep	#$20
	.a8
	lda	#^sine_products
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

draw_target_arrows_p2:
	lda	a:td_arrow_objs+2*OBJ_SIZE+OBJ_X
	sta	a:oam_buffer+8
	lda	a:td_arrow_objs+2*OBJ_SIZE+OBJ_Y
	sta	a:oam_buffer+9
	lda	a:td_arrow_objs+2*OBJ_SIZE
	sta	a:oam_buffer+10
	lda	a:td_arrow_objs+3*OBJ_SIZE+OBJ_X
	sta	a:oam_buffer+12
	lda	a:td_arrow_objs+3*OBJ_SIZE+OBJ_Y
	sta	a:oam_buffer+13
	lda	a:td_arrow_objs+3*OBJ_SIZE
	sta	a:oam_buffer+14
	lda	a:oam_hi_table
	and	#$FF00
	ora	#$00AA
	sta	a:oam_hi_table
	rts

start_oam_list_p2:
	ldx	#$0FD0
	stx	zp_10
	ldx	#$11C0
	stx	zp_12
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
	rts

draw_small_objects_p2:
	ldx	#$0300
@slot_loop:
	lda	$10,x
	beq	@next_slot
	lda	$04,x
	bmi	@fixed_tile
	sec
	sbc	a:p2_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:td_small_object_tiles,y
	bra	@tile_ready
@fixed_tile:
	lda	$00,x
	beq	@next_slot
@tile_ready:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	@next_slot
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	@next_slot
	cmp	zp_0E
	bpl	@next_slot
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	@next_slot
	cmp	#$FFF0	; [num]
	bmi	@next_slot
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	lda	$16,x
	cmp	#$0008
	ror	zp_14
	bcc	@next_slot
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@next_slot:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	@slot_loop
@return:
	rts

draw_td_items_p2:
	ldx	#$0980
@loop:
	lda	$00,x
	beq	@next
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	@next
	lda	$02,x
	ora	#$0100
	sta	zp_06
	ldy	$00,x
	phx
	jsr	a:draw_td_item_metasprite_p2
	plx
@next:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0AC0
	bcc	@loop
	rts

end_small_sprites_p2:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10C0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10C0
	bcc	@loop2
@return:
	rts

draw_enemies_p2:
	ldx	#$1120
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	lda	a:title_menu_cursor
	beq	@check_fall
	dec	a
	bne	@draw
@check_fall:
	lda	a:td_p2_obj+$2C
	beq	@draw
	brl	@hide_rest
@draw:
	stz	zp_08
	ldx	#$0D40
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	@next_slot
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_enemy_sprite_attrs_p2_view,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots_p2_view,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	@next_slot
@some_drawn:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1180
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1180
	bcc	@loop2
@return:
	rts

draw_topdown_players_p2:
	ldx	#$11A0
	stx	zp_10
	ldx	#$11DE
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
@slot_loop:
	lda	a:title_menu_cursor
	beq	@one_view
	dec	a
	beq	@one_view
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	@draw
	brl	@next_slot
@one_view:
	cpx	#$0F00
	beq	@draw
	lda	a:td_p2_obj+$2C
	ora	a:td_p1_obj+$2C
	bne	@next_slot
@draw:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	#$8000	; [num]
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	@next_slot
@in_range:
	lda	zp_00
	sta	a:$00B2,x
	lda	zp_02
	sta	a:$00B6,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_player_sprite_attrs_p2_view,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_player_stream_slots_p2_view,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11C0
	bcc	@loop2
@return:
	rts

draw_stage2_boss_cannon_p2:
	; (not executed in the CDL traces)
	ldx	#$10D0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$0002
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@cannon
@keep_hi_bits:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@cannon:
	ldx	#$0B80
	lda	$00,x
	beq	@hide_rest
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	@hide_rest
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	#$0004
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ora	a:td_enemy_sprite_attrs_p2_view
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots_p2_view
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	@hide_rest
@some_drawn:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$10E0
	bcc	@loop2
@return:
	rts

draw_players_stage2_boss_p2:
	; (not executed in the CDL traces)
	ldx	#$1100
	stx	zp_10
	ldx	#$11D4
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	#$8000	; [num]
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	@next_slot
@in_range:
	lda	zp_00
	sta	a:$00B2,x
	lda	zp_02
	sta	a:$00B6,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_player_sprite_attrs_p2_view,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_player_stream_slots_p2_view,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1120
	bcc	@loop2
@return:
	rts

draw_stage2_boss_arena_p2:
	; (not executed in the CDL traces)
	ldx	#$1170
	stx	zp_10
	ldx	#$11DA
	stx	zp_12
	lda	#$0002
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@rubble
@keep_hi_bits:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@rubble:
	lda	#$10A8
	sta	zp_06
	lda	#$0040
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	tay
	lda	a:stage2_arena_rubble_metasprites,y
	sta	zp_CA
	lda	a:stage2_arena_rubble_tile_list,y
	ldy	#$0060
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
@rubble_loop:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:stage2_arena_rubble_x - 2,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_rubble_y,x
	jsr	a:project_to_view
	bcs	@next_rubble
	ldy	zp_CA
	jsr	a:draw_topdown_metasprite_p2
@next_rubble:
	dec	zp_08
	dec	zp_08
	bne	@rubble_loop
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$10A4
	bit	#$0020
	beq	@debris
	ldy	#$D0A4	; [num]
@debris:
	sty	zp_06
	tay
	lda	a:stage2_arena_debris_tile_list,y
	ldy	#$0058
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
@debris_loop:
	lda	zp_C4
	clc
	adc	a:stage2_arena_debris_x,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_debris_y,x
	jsr	a:project_to_view
	bcs	@next_debris
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	@next_debris
	cmp	zp_0E
	bpl	@next_debris
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	@next_debris
	cmp	#$FFF0	; [num]
	bmi	@next_debris
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	@next_debris
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@next_debris:
	dex
	dex
	bne	@debris_loop
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$11C0
	bcc	@loop2
@return:
	rts

draw_topdown_metasprite_p2:
	stz	zp_D0
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
@sprite_loop:
	stz	zp_CD
	lda	a:$0001,y
	bpl	@y_extended
	dec	zp_CD
@y_extended:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	@next_sprite
	cmp	zp_0E
	bpl	@next_sprite
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	@x_extended
	dec	zp_CD
@x_extended:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	@next_sprite
	cmp	#$FFF0	; [num]
	bmi	@next_sprite
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	inc	zp_D0
	lda	a:$0003,y
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	sec
	ror	zp_14
	bcc	@next_sprite
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000	; [num]
	sta	zp_14
	stx	zp_12
	plx
@next_sprite:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	@sprite_loop
	stx	zp_10
	rts

draw_td_item_metasprite_p2:
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sta	zp_02
	lda	a:$0000,y
	and	#$00FF
	sta	zp_C8
	ldx	zp_10
@sprite_loop:
	stz	zp_CD
	lda	a:$0001,y
	bpl	@y_extended
	dec	zp_CD
@y_extended:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	@next_sprite
	cmp	zp_0E
	bpl	@next_sprite
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	@x_extended
	dec	zp_CD
@x_extended:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	@next_sprite
	cmp	#$FFF0	; [num]
	bmi	@next_sprite
	ror	zp_14
	sep	#$20
	.a8
	sta	$00,x
	rep	#$20
	.a16
	lda	a:$0003,y
	and	#$C0FF
	ora	zp_06
	sta	$02,x
	inx
	inx
	inx
	inx
	lda	a:$0004,y
	lsr	a
	ror	zp_14
	bcc	@next_sprite
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000	; [num]
	sta	zp_14
	stx	zp_12
	plx
@next_sprite:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	@sprite_loop
	stx	zp_10
	rts

project_map_objects_p2:
	ldx	#$0AC0
@slot_loop:
	lda	$10,x
	beq	@next_slot
	cpx	#$0D40
	bcs	@enemy_slot
	cmp	#$0003
	beq	@next_slot
	bra	@project
@enemy_slot:
	lda	$00,x
	bne	@next_slot
@project:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_00
	sta	$1A,x
	lda	zp_02
	sta	$1E,x
	lda	zp_02
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	lda	zp_00
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	@slot_loop
	rts

project_td_bombs_p2:
	lda	a:td_p2_obj+$2C
	bne	@check_p2_fall
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	@p2_bomb
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@p1_in_range
	lda	#$8000	; [num]
	sta	$3A,x
	sta	$3E,x
	bra	@p2_bomb
@p1_in_range:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
@check_p2_fall:
	lda	a:td_p1_obj+$2C
	bne	@return
@p2_bomb:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	@return
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@p2_in_range
	; (not executed in the CDL traces)
	lda	#$8000	; [num]
	sta	$3A,x
	sta	$3E,x
	bra	@return
@p2_in_range:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
@return:
	rts

project_stage5_boss_objects_p2:
	; (not executed in the CDL traces)
	ldx	#$0AC0
@slot_loop:
	lda	$10,x
	beq	@next_slot
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	lda	zp_00
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	@slot_loop
	rts

draw_stage5_boss_claw_section_p2:
	; (not executed in the CDL traces)
	ldx	#$10E0
	stx	zp_10
	ldx	#$11D2
	stx	zp_12
	lda	#$8000	; [num]
	sta	zp_14
	jsr	a:is_p2_view_falling_2
	bcs	@hide_rest
	jsr	a:draw_stage5_boss_claw_p2
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1100
	bcc	@loop2
@return:
	rts

draw_stage5_boss_claw_p2:
	; (not executed in the CDL traces)
	stz	zp_08
	ldx	#$0B40
@slot_loop:
	lda	$00,x
	beq	@next_slot
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_tile_lists,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	@next_slot
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	$20,x
	xba
	lsr	a
	lsr	a
	sta	zp_FA
	lda	$04,x
	sec
	sbc	zp_16
	clc
	adc	#$0004
	lsr	a
	lsr	a
	and	#$003E
	clc
	adc	zp_FA
	tay
	lda	$02,x
	phx
	ldx	zp_08
	ora	a:td_enemy_sprite_attrs_p2_view,x
	sta	zp_06
	lda	(zp_C4),y
	pha
	lda	(zp_C6),y
	ldy	a:td_enemy_stream_slots_p2_view,x
	tax
	lda	a:$0000,x
	sta	a:td_gfx_stream+GFXS_SRC,y
	lda	a:$0002,x
	sta	a:td_gfx_stream+GFXS_BANK,y
	lda	a:$0004,x
	sta	a:td_gfx_stream+GFXS_SRC2,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	@some_drawn
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	@next_slot
@some_drawn:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
@next_slot:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	@return
	brl	@slot_loop
@return:
	rts

is_p2_view_falling_2:
	; (not executed in the CDL traces)
	lda	a:title_menu_cursor
	beq	@check_fall
	dec	a
	bne	@return_clc
@check_fall:
	lda	a:td_p2_obj+$2C
	beq	@return_clc
	brl	@return_sec
@return_clc:
	clc
	rts
@return_sec:
	sec
	rts

draw_stage5_boss_arm_p2:
	; (not executed in the CDL traces)
	ldx	#$1130
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$0002
	bne	@keep_hi_bits
	lda	#$8000	; [num]
	sta	zp_14
	bra	@segments
@keep_hi_bits:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
@segments:
	ldx	#$0BC0
@slot_loop:
	lda	$00,x
	beq	@next_slot
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	@in_range
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	@off_screen
@in_range:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	@off_screen
	cmp	zp_0E
	bpl	@off_screen
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	@off_screen
	cmp	#$FFF0	; [num]
	bmi	@off_screen
	ror	zp_14
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	zp_04
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	sty	zp_10
	sec
	ror	zp_14
	bcc	@on_screen
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000	; [num]
	sta	zp_14
	sty	zp_12
@on_screen:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	@next_slot
@off_screen:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
@next_slot:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	@hide_rest
	brl	@slot_loop
@hide_rest:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1160
	bcs	@return
	lda	#$F000	; [num]
@loop2:
	sta	$00,x
	inx
	inx
	inx
	inx
	cpx	#$1160
	bcc	@loop2
@return:
	rts
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
