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
	beq	loc_03E18F
	dec	a
	bne	loc_03E18F
	lda	frame_counter
	lsr	a
	bcs	loc_03E193
loc_03E18F:
	jml	f:draw_p1_view_sprites
loc_03E193:
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
	bmi	loc_03E201
	cmp	#$00B8
	bcs	loc_03E1D8
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E1DA
	cmp	#$00B8
	bcs	loc_03E1D8
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
loc_03E1D8:
	plx
	rts
loc_03E1DA:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E1D8
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
loc_03E201:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E236
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E238
	cmp	#$00B8
	bcs	loc_03E236
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
loc_03E236:
	plx
	rts
loc_03E238:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E236
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
	bmi	loc_03E2C1
	cmp	#$00B8
	bcs	loc_03E298
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E29A
	cmp	#$00B8
	bcs	loc_03E298
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
loc_03E298:
	plx
	rts
loc_03E29A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E298
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
loc_03E2C1:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E2F9
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E2FB
	cmp	#$00B8
	bcs	loc_03E2F9
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
loc_03E2F9:
	plx
	rts
loc_03E2FB:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E2F9
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
	bmi	loc_03E384
	cmp	#$00B8
	bcs	loc_03E358
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E35A
	cmp	#$00B8
	bcs	loc_03E358
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
loc_03E358:
	plx
	rts
loc_03E35A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E358
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
loc_03E384:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E3B9
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E3BB
	cmp	#$00B8
	bcs	loc_03E3B9
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
loc_03E3B9:
	plx
	rts
loc_03E3BB:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E3B9
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
	bmi	loc_03E444
	cmp	#$00B8
	bcs	loc_03E418
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E41A
	cmp	#$00B8
	bcs	loc_03E418
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
loc_03E418:
	plx
	rts
loc_03E41A:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E418
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
loc_03E444:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E476
	asl	a
	tax
	tya
	sec
	sbc	zp_18
	bmi	loc_03E478
	cmp	#$00B8
	bcs	loc_03E476
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
loc_03E476:
	plx
	rts
loc_03E478:
	eor	#$FFFF
	inc	a
	cmp	#$00B8
	bcs	loc_03E476
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
	lda	#$AAAA
	sta	a:wram_11C0
	lda	#$AAAA
	sta	a:wram_11C2
	lda	a:p1_lives
	bne	loc_03E4BC
	brl	loc_03E4C8
loc_03E4BC:
	ldx	#$0EC0
	jsr	a:map_view_player_position
	jsr	a:map_view_p1_marker
	jsr	a:write_map_view_p1_marker
loc_03E4C8:
	lda	a:p2_lives
	bne	loc_03E4D0
	brl	loc_03E4D9
loc_03E4D0:
	ldx	#$0F00
	jsr	a:map_view_player_position
	jsr	a:map_view_p2_marker
loc_03E4D9:
	jsr	a:write_map_view_p2_marker
	jsr	a:draw_map_view_targets
	lda	#$F000
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
	lda	a:data_05E748,y
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
	bcs	loc_03E55E
	lda	#$002A
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
loc_03E55E:
	lda	#$0000
	sta	zp_08
	lda	#$FFE8
	sta	zp_0A
	rts

map_view_p2_marker:
	; (not executed in the CDL traces)
	lda	$0E,x
	and	#$03FF
	cmp	#$0200
	bcs	loc_03E57E
	lda	#$002C
	sta	zp_08
	lda	#$0008
	sta	zp_0A
	rts
loc_03E57E:
	lda	#$0002
	sta	zp_08
	lda	#$FFE8
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
	lda	#$AAAA
	sta	a:wram_11C0
	lda	#$AAAA
	sta	a:wram_11C2
	lda	#$AAAA
	sta	a:wram_11C4
	lda	#$0002
	sta	a:wram_11C6
	lda	a:intro_phase
	dec	a
	beq	loc_03E6A6
	brl	loc_03E6B2
loc_03E6A6:
	jsr	a:draw_intro_banner_sprites
	jsr	a:draw_p1_start_cursor
	jsr	a:draw_p2_start_cursor
	jsr	a:draw_intro_target_markers
loc_03E6B2:
	lda	#$F000
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
	bne	loc_03E6CA
	; (not executed in the CDL traces)
	brl	loc_03E79A
loc_03E6CA:
	phy
	lda	a:p1_start_x
	asl	a
	tay
	lda	a:data_05E788,y
	sta	zp_00
	lda	a:p1_start_y
	asl	a
	tay
	lda	a:data_05E790,y
	sta	zp_02
	ply
	lda	#$3900
	sta	zp_06
	lda	a:p1_start_chosen
	beq	loc_03E6F4
	lda	stage_frame_counter
	bit	#$0004
	beq	loc_03E6F4
	brl	loc_03E79A
loc_03E6F4:
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
	lda	#$8026
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
	lda	#$C026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
loc_03E79A:
	rts

; Player 2's start-point cursor.
draw_p2_start_cursor:
	lda	a:title_menu_cursor
	bne	loc_03E7A3
	brl	loc_03E87B
loc_03E7A3:
	lda	a:p2_lives
	bne	loc_03E7AB
	; (not executed in the CDL traces)
	brl	loc_03E87B
loc_03E7AB:
	phy
	lda	a:p2_start_x
	asl	a
	tay
	lda	a:data_05E788,y
	sta	zp_00
	lda	a:p2_start_y
	asl	a
	tay
	lda	a:data_05E790,y
	sta	zp_02
	ply
	lda	#$3B00
	sta	zp_06
	lda	a:p2_start_chosen
	beq	loc_03E7D5
	lda	stage_frame_counter
	bit	#$0004
	bne	loc_03E7D5
	brl	loc_03E87B
loc_03E7D5:
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
	lda	#$8026
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
	lda	#$C026
	ora	zp_06
	sta	a:$0002,y
	iny
	iny
	iny
	iny
loc_03E87B:
	rts

draw_intro_banner_sprites:
	ldx	#$0014
@loop:
	lda	#$0008
	sta	a:$0001,y
	lda	a:data_05E796,x
	sep	#$20
	.a8
	sta	a:$0000,y
	rep	#$20
	.a16
	lda	a:data_05E7AA,x
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
	bne	loc_03E900
	ldx	#$0002
loc_03E900:
	stx	zp_FA
	lda	#$0000
	ldx	stage_number
	cpx	#$0002
	beq	loc_03E90F
	lda	#$0004
loc_03E90F:
	ora	zp_FA
	tax
	lda	a:data_05E7C0,x
	sta	zp_06
	rts
; Sprites of player 1's view (or the intro / map view ones).
draw_p1_view_sprites:
	rep	#$30
	lda	a:topdown_map
	cmp	#TD_MAP_STAGE2_BOSS
	beq	loc_03E96E
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_03E92A
	brl	loc_03E9A0
loc_03E92A:
	lda	a:intro_phase
	beq	loc_03E932
	brl	draw_intro_sprites
loc_03E932:
	lda	a:map_view_active
	beq	loc_03E93A
	; (not executed in the CDL traces)
	brl	draw_map_view_sprites
loc_03E93A:
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
	bcs	loc_03E956
	jsr	a:draw_small_objects
	jsr	a:draw_td_items
loc_03E956:
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
loc_03E96E:
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
loc_03E9A0:
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
	bcs	loc_03E9BC
	jsr	a:draw_small_objects
	jsr	a:draw_td_items
loc_03E9BC:
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
	beq	loc_03E9DF
	dec	a
	bne	loc_03E9E6
loc_03E9DF:
	lda	a:wram_0EEC
	beq	loc_03E9E6
	sec
	rts
loc_03E9E6:
	clc
	rts

; Sets up project_to_view for player 1's view: centre, anchor, angle
; quadrant (zp_DA) and the two product tables for the angle (zp_D4, zp_D7).
setup_p1_view_projection:
	lda	a:title_menu_cursor
	beq	loc_03E9F0
	dec	a
	beq	loc_03EA17
loc_03E9F0:
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
	bra	loc_03EA3C
loc_03EA17:
	lda	#$FFF0
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
loc_03EA3C:
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
	adc	#$8000
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
	adc	#$8000
	sta	zp_D7
	sep	#$20
	.a8
	lda	#$03
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

; Copies the two target arrows (objects $0200 and $0240) to the first OAM entries.
draw_target_arrows:
	lda	a:wram_020A
	sta	a:wram_0FC0
	lda	a:wram_020E
	sta	a:wram_0FC1
	lda	a:player1_obj
	sta	a:wram_0FC2
	lda	a:wram_024A
	sta	a:wram_0FC4
	lda	a:wram_024E
	sta	a:wram_0FC5
	lda	a:player2_obj
	sta	a:wram_0FC6
	lda	a:wram_11C0
	and	#$FF00
	ora	#$00AA
	sta	a:wram_11C0
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
loc_03EAC2:
	lda	$10,x
	beq	loc_03EB39
	lda	$04,x
	bmi	loc_03EADA
	sec
	sbc	a:p1_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:td_small_object_tiles,y
	bra	loc_03EADE
loc_03EADA:
	lda	$00,x
	beq	loc_03EB39
loc_03EADE:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	loc_03EB39
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	loc_03EB39
	cmp	zp_0E
	bpl	loc_03EB39
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	loc_03EB39
	cmp	#$FFF0
	bmi	loc_03EB39
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
	bcc	loc_03EB39
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03EB39:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	loc_03EAC2
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
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	lda	a:title_menu_cursor
	beq	loc_03EBA6
	dec	a
	bne	loc_03EBAE
loc_03EBA6:
	lda	a:wram_0EEC
	beq	loc_03EBAE
	brl	loc_03EC46
loc_03EBAE:
	stz	zp_08
	ldx	#$0D40
loc_03EBB3:
	lda	$00,x
	beq	loc_03EC34
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03EBD6
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	loc_03EC34
loc_03EBD6:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	loc_03EC2D
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03EC34
loc_03EC2D:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03EC34:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03EC46
	brl	loc_03EBB3
loc_03EC46:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	@return
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03EC77:
	lda	a:title_menu_cursor
	beq	loc_03EC86
	dec	a
	beq	loc_03EC86
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_03EC93
	brl	loc_03ED04
loc_03EC86:
	cpx	#$0EC0
	beq	loc_03EC93
	lda	a:wram_0EEC
	ora	a:wram_0F2C
	bne	loc_03ED04
loc_03EC93:
	lda	$00,x
	beq	loc_03ED04
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03ECB7
	lda	#$8000
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	loc_03ED04
loc_03ECB7:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
loc_03ED04:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03ED16
	brl	loc_03EC77
loc_03ED16:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11A0
	bcs	@return
	lda	#$F000
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
	bne	loc_03ED49
	lda	#$8000
	sta	zp_14
	bra	loc_03ED54
loc_03ED49:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03ED54:
	ldx	#$0B80
	lda	$00,x
	beq	loc_03EDD6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03ED6D
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03EDD6
loc_03ED6D:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	#$0004
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	loc_03EDCF
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03EDD6
loc_03EDCF:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03EDD6:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10D0
	bcs	@return
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03EE0A:
	lda	$00,x
	beq	loc_03EE7B
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03EE2E
	; (not executed in the CDL traces)
	lda	#$8000
	sta	a:$00B0,x
	sta	a:$00B4,x
	bra	loc_03EE7B
loc_03EE2E:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
loc_03EE7B:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03EE8D
	brl	loc_03EE0A
loc_03EE8D:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	@return
	lda	#$F000
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
	bne	loc_03EEC0
	lda	#$8000
	sta	zp_14
	bra	loc_03EECB
loc_03EEC0:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03EECB:
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
	lda	a:stage2_arena_rubble_streams,y
	ldy	#$0020
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
loc_03EF11:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:$7FFE,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_rubble_y,x
	jsr	a:project_to_view
	bcs	loc_03EF2A
	ldy	zp_CA
	jsr	a:draw_topdown_metasprite
loc_03EF2A:
	dec	zp_08
	dec	zp_08
	bne	loc_03EF11
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$1024
	bit	#$0020
	beq	loc_03EF46
	ldy	#$D024
loc_03EF46:
	sty	zp_06
	tay
	lda	a:stage2_arena_debris_streams,y
	ldy	#$0018
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
loc_03EF73:
	lda	zp_C4
	clc
	adc	a:stage2_arena_debris_x,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_debris_y,x
	jsr	a:project_to_view
	bcs	loc_03EFD5
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03EFD5
	cmp	zp_0E
	bpl	loc_03EFD5
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03EFD5
	cmp	#$FFF0
	bmi	loc_03EFD5
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
	bcc	loc_03EFD5
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03EFD5:
	dex
	dex
	bne	loc_03EF73
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1170
	bcs	@return
	lda	#$F000
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
loc_03F00D:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03F016
	dec	zp_CD
loc_03F016:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03F06C
	cmp	zp_0E
	bpl	loc_03F06C
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03F030
	dec	zp_CD
loc_03F030:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03F06C
	cmp	#$FFF0
	bmi	loc_03F06C
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
	bcc	loc_03F06C
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03F06C:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03F00D
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
loc_03F089:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03F092
	dec	zp_CD
loc_03F092:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03F0EC
	cmp	zp_0E
	bpl	loc_03F0EC
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03F0AC
	dec	zp_CD
loc_03F0AC:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03F0EC
	cmp	#$FFF0
	bmi	loc_03F0EC
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
	bcc	loc_03F0EC
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03F0EC:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03F089
	stx	zp_10
	rts

; Projects the map objects ($0AC0-$0EBF): screen position in +$18/+$1C,
; +$2E bit 2 = in projection range, bit 0 = on screen.
project_map_objects:
	ldx	#$0AC0
loc_03F0FA:
	lda	$10,x
	beq	loc_03F155
	cpx	#$0D40
	bcs	loc_03F10A
	cmp	#$0003
	beq	loc_03F155
	bra	loc_03F10E
loc_03F10A:
	lda	$00,x
	bne	loc_03F155
loc_03F10E:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F120
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F14E
loc_03F120:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_00
	sta	$18,x
	lda	zp_02
	sta	$1C,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03F14E
	cmp	zp_0E
	bpl	loc_03F14E
	lda	zp_00
	cmp	#$0100
	bpl	loc_03F14E
	cmp	#$FFF0
	bmi	loc_03F14E
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F155
loc_03F14E:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F155:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_03F0FA
	rts

; Screen positions (+$38/+$3C) of the smart bombs ($8000 when out of range).
project_td_bombs:
	lda	a:wram_0EEC
	bne	loc_03F188
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	loc_03F18D
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F180
	lda	#$8000
	sta	$38,x
	sta	$3C,x
	bra	loc_03F18D
loc_03F180:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
loc_03F188:
	lda	a:wram_0F2C
	bne	loc_03F1AF
loc_03F18D:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	loc_03F1AF
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F1A7
	lda	#$8000
	sta	$38,x
	sta	$3C,x
	bra	loc_03F1AF
loc_03F1A7:
	lda	zp_00
	sta	$38,x
	lda	zp_02
	sta	$3C,x
loc_03F1AF:
	rts

project_stage5_boss_objects:
	ldx	#$0AC0
loc_03F1B3:
	lda	$10,x
	beq	loc_03F1F6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F1C9
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F1EF
loc_03F1C9:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03F1EF
	cmp	zp_0E
	bpl	loc_03F1EF
	lda	zp_00
	cmp	#$0100
	bpl	loc_03F1EF
	cmp	#$FFF0
	bmi	loc_03F1EF
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F1F6
loc_03F1EF:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F1F6:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	loc_03F1B3
	rts

draw_stage5_boss_claw_section:
	ldx	#$10C0
	stx	zp_10
	ldx	#$11D0
	stx	zp_12
	lda	#$8000
	sta	zp_14
	jsr	a:is_p1_view_falling_2
	bcs	loc_03F219
	jsr	a:draw_stage5_boss_claw
loc_03F219:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	@return
	lda	#$F000
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
loc_03F23B:
	lda	$00,x
	beq	loc_03F2BC
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F25E
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	brl	loc_03F2BC
loc_03F25E:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite
	plx
	lda	zp_D0
	bne	loc_03F2B5
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
	bra	loc_03F2BC
loc_03F2B5:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
loc_03F2BC:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	@return
	brl	loc_03F23B
@return:
	rts

is_p1_view_falling_2:
	lda	a:title_menu_cursor
	beq	loc_03F2D7
	; (not executed in the CDL traces)
	dec	a
	bne	loc_03F2DF
loc_03F2D7:
	lda	a:wram_0EEC
	beq	loc_03F2DF
	; (not executed in the CDL traces)
	brl	loc_03F2E1
loc_03F2DF:
	clc
	rts
loc_03F2E1:
	; (not executed in the CDL traces)
	sec
	rts

draw_stage5_boss_arm:
	ldx	#$1100
	stx	zp_10
	ldx	#$11D4
	stx	zp_12
	lda	#$0000
	bne	loc_03F2F9
	lda	#$8000
	sta	zp_14
	bra	loc_03F304
loc_03F2F9:
	; (not executed in the CDL traces)
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F304:
	ldx	#$0BC0
loc_03F307:
	lda	$00,x
	beq	loc_03F384
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F321
	lda	$2E,x
	and	#$FFFB
	sta	$2E,x
	bra	loc_03F37D
loc_03F321:
	lda	$2E,x
	ora	#$0004
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03F37D
	cmp	zp_0E
	bpl	loc_03F37D
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03F37D
	cmp	#$FFF0
	bmi	loc_03F37D
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
	bcc	loc_03F374
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03F374:
	lda	$2E,x
	ora	#$0001
	sta	$2E,x
	bra	loc_03F384
loc_03F37D:
	lda	$2E,x
	and	#$FFFE
	sta	$2E,x
loc_03F384:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03F392
	brl	loc_03F307
loc_03F392:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1130
	bcs	@return
	lda	#$F000
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
	beq	loc_03F408
	cmp	#TD_MAP_STAGE5_BOSS
	bne	loc_03F3C4
	; (not executed in the CDL traces)
	brl	loc_03F43A
loc_03F3C4:
	lda	a:intro_phase
	beq	loc_03F3CC
	brl	draw_intro_sprites
loc_03F3CC:
	lda	a:map_view_active
	beq	loc_03F3D4
	; (not executed in the CDL traces)
	brl	draw_map_view_sprites
loc_03F3D4:
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
	bcs	loc_03F3F0
	jsr	a:draw_small_objects_p2
	jsr	a:draw_td_items_p2
loc_03F3F0:
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
loc_03F408:
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
loc_03F43A:
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
	bcs	loc_03F456
	jsr	a:draw_small_objects_p2
	jsr	a:draw_td_items_p2
loc_03F456:
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
	beq	loc_03F479
	dec	a
	bne	loc_03F480
loc_03F479:
	lda	a:wram_0F2C
	beq	loc_03F480
	sec
	rts
loc_03F480:
	clc
	rts

setup_p2_view_projection:
	lda	a:title_menu_cursor
	beq	loc_03F48A
	dec	a
	beq	loc_03F4B1
loc_03F48A:
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
	bra	loc_03F4D6
loc_03F4B1:
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
loc_03F4D6:
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
	adc	#$8000
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
	adc	#$8000
	sta	zp_D7
	sep	#$20
	.a8
	lda	#$03
	sta	zp_D6
	sta	zp_D9
	rep	#$20
	.a16
	rts

draw_target_arrows_p2:
	lda	a:wram_028A
	sta	a:wram_0FC8
	lda	a:wram_028E
	sta	a:wram_0FC9
	lda	a:wram_0280
	sta	a:wram_0FCA
	lda	a:wram_02CA
	sta	a:wram_0FCC
	lda	a:wram_02CE
	sta	a:wram_0FCD
	lda	a:wram_02C0
	sta	a:wram_0FCE
	lda	a:wram_11C0
	and	#$FF00
	ora	#$00AA
	sta	a:wram_11C0
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
loc_03F55C:
	lda	$10,x
	beq	loc_03F5D3
	lda	$04,x
	bmi	loc_03F574
	sec
	sbc	a:p2_view_angle
	and	#$00FF
	ora	$00,x
	asl	a
	tay
	lda	a:td_small_object_tiles,y
	bra	loc_03F578
loc_03F574:
	lda	$00,x
	beq	loc_03F5D3
loc_03F578:
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcs	loc_03F5D3
	ldy	zp_10
	sec
	lda	zp_02
	sbc	$16,x
	cmp	zp_0C
	bmi	loc_03F5D3
	cmp	zp_0E
	bpl	loc_03F5D3
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	$16,x
	cmp	#$0100
	bpl	loc_03F5D3
	cmp	#$FFF0
	bmi	loc_03F5D3
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
	bcc	loc_03F5D3
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03F5D3:
	txa
	clc
	adc	#$0020
	tax
	cpx	#$0980
	bcs	@return
	brl	loc_03F55C
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
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	lda	a:title_menu_cursor
	beq	loc_03F640
	dec	a
	bne	loc_03F648
loc_03F640:
	lda	a:wram_0F2C
	beq	loc_03F648
	brl	loc_03F6E0
loc_03F648:
	stz	zp_08
	ldx	#$0D40
loc_03F64D:
	lda	$00,x
	beq	loc_03F6CE
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F670
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	loc_03F6CE
loc_03F670:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	loc_03F6C7
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03F6CE
loc_03F6C7:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03F6CE:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03F6E0
	brl	loc_03F64D
loc_03F6E0:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1180
	bcs	@return
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03F711:
	lda	a:title_menu_cursor
	beq	loc_03F720
	dec	a
	beq	loc_03F720
	; (not executed in the CDL traces)
	lda	$2C,x
	beq	loc_03F72D
	brl	loc_03F79E
loc_03F720:
	cpx	#$0F00
	beq	loc_03F72D
	lda	a:wram_0F2C
	ora	a:wram_0EEC
	bne	loc_03F79E
loc_03F72D:
	lda	$00,x
	beq	loc_03F79E
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F751
	lda	#$8000
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	loc_03F79E
loc_03F751:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
loc_03F79E:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03F7B0
	brl	loc_03F711
loc_03F7B0:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	@return
	lda	#$F000
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
	bne	loc_03F7E3
	lda	#$8000
	sta	zp_14
	bra	loc_03F7EE
loc_03F7E3:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F7EE:
	ldx	#$0B80
	lda	$00,x
	beq	loc_03F870
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F807
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03F870
loc_03F807:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	#$0004
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	loc_03F869
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03F870
loc_03F869:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03F870:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$10E0
	bcs	@return
	lda	#$F000
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
	lda	#$8000
	sta	zp_14
	stz	zp_08
	ldx	#$0EC0
loc_03F8A4:
	lda	$00,x
	beq	loc_03F915
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03F8C8
	lda	#$8000
	sta	a:$00B2,x
	sta	a:$00B6,x
	bra	loc_03F915
loc_03F8C8:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
loc_03F915:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0F40
	bcs	loc_03F927
	brl	loc_03F8A4
loc_03F927:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1120
	bcs	@return
	lda	#$F000
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
	bne	loc_03F95A
	lda	#$8000
	sta	zp_14
	bra	loc_03F965
loc_03F95A:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03F965:
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
	lda	a:stage2_arena_rubble_streams,y
	ldy	#$0060
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	lda	#$0012
	sta	zp_08
loc_03F9AB:
	ldx	zp_08
	lda	zp_C4
	clc
	adc	a:$7FFE,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_rubble_y,x
	jsr	a:project_to_view
	bcs	loc_03F9C4
	ldy	zp_CA
	jsr	a:draw_topdown_metasprite_p2
loc_03F9C4:
	dec	zp_08
	dec	zp_08
	bne	loc_03F9AB
	lda	#$0004
	sec
	sbc	zp_16
	lsr	a
	lsr	a
	and	#$003E
	ldy	#$10A4
	bit	#$0020
	beq	loc_03F9E0
	ldy	#$D0A4
loc_03F9E0:
	sty	zp_06
	tay
	lda	a:stage2_arena_debris_streams,y
	ldy	#$0058
	tax
	lda	a:$0000,x
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	lda	zp_18
	and	#$FF80
	sta	zp_C4
	lda	zp_1A
	and	#$FF80
	sta	zp_C6
	ldx	#$0032
loc_03FA0D:
	lda	zp_C4
	clc
	adc	a:stage2_arena_debris_x,x
	tay
	lda	zp_C6
	clc
	adc	a:stage2_arena_debris_y,x
	jsr	a:project_to_view
	bcs	loc_03FA6F
	sec
	lda	zp_02
	clc
	adc	a:screen_shake_offset
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03FA6F
	cmp	zp_0E
	bpl	loc_03FA6F
	ldy	zp_10
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03FA6F
	cmp	#$FFF0
	bmi	loc_03FA6F
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
	bcc	loc_03FA6F
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03FA6F:
	dex
	dex
	bne	loc_03FA0D
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$11C0
	bcs	@return
	lda	#$F000
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
loc_03FAA7:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03FAB0
	dec	zp_CD
loc_03FAB0:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03FB06
	cmp	zp_0E
	bpl	loc_03FB06
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03FACA
	dec	zp_CD
loc_03FACA:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03FB06
	cmp	#$FFF0
	bmi	loc_03FB06
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
	bcc	loc_03FB06
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03FB06:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03FAA7
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
loc_03FB23:
	stz	zp_CD
	lda	a:$0001,y
	bpl	loc_03FB2C
	dec	zp_CD
loc_03FB2C:
	sta	zp_CC
	clc
	lda	zp_02
	adc	zp_CD
	cmp	zp_0C
	bmi	loc_03FB86
	cmp	zp_0E
	bpl	loc_03FB86
	sta	$01,x
	stz	zp_CD
	lda	a:$0000,y
	bpl	loc_03FB46
	dec	zp_CD
loc_03FB46:
	sta	zp_CC
	clc
	lda	zp_00
	adc	zp_CD
	cmp	#$0100
	bpl	loc_03FB86
	cmp	#$FFF0
	bmi	loc_03FB86
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
	bcc	loc_03FB86
	phx
	ldx	zp_12
	lda	zp_14
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	zp_14
	stx	zp_12
	plx
loc_03FB86:
	iny
	iny
	iny
	iny
	dec	zp_C8
	bne	loc_03FB23
	stx	zp_10
	rts

project_map_objects_p2:
	ldx	#$0AC0
loc_03FB94:
	lda	$10,x
	beq	loc_03FBEF
	cpx	#$0D40
	bcs	loc_03FBA4
	cmp	#$0003
	beq	loc_03FBEF
	bra	loc_03FBA8
loc_03FBA4:
	lda	$00,x
	bne	loc_03FBEF
loc_03FBA8:
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FBBA
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FBE8
loc_03FBBA:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_00
	sta	$1A,x
	lda	zp_02
	sta	$1E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03FBE8
	cmp	zp_0E
	bpl	loc_03FBE8
	lda	zp_00
	cmp	#$0100
	bpl	loc_03FBE8
	cmp	#$FFF0
	bmi	loc_03FBE8
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FBEF
loc_03FBE8:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FBEF:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcc	loc_03FB94
	rts

project_td_bombs_p2:
	lda	a:wram_0F2C
	bne	loc_03FC22
	ldx	#$0F40
	lda	$10,x
	dec	a
	bne	loc_03FC27
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FC1A
	lda	#$8000
	sta	$3A,x
	sta	$3E,x
	bra	loc_03FC27
loc_03FC1A:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
loc_03FC22:
	lda	a:wram_0EEC
	bne	loc_03FC49
loc_03FC27:
	ldx	#$0F80
	lda	$10,x
	dec	a
	bne	loc_03FC49
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FC41
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$3A,x
	sta	$3E,x
	bra	loc_03FC49
loc_03FC41:
	lda	zp_00
	sta	$3A,x
	lda	zp_02
	sta	$3E,x
loc_03FC49:
	rts

project_stage5_boss_objects_p2:
	; (not executed in the CDL traces)
	ldx	#$0AC0
loc_03FC4D:
	lda	$10,x
	beq	loc_03FC90
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FC63
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FC89
loc_03FC63:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	lda	zp_02
	cmp	zp_0C
	bmi	loc_03FC89
	cmp	zp_0E
	bpl	loc_03FC89
	lda	zp_00
	cmp	#$0100
	bpl	loc_03FC89
	cmp	#$FFF0
	bmi	loc_03FC89
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FC90
loc_03FC89:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FC90:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0B40
	bcc	loc_03FC4D
	rts

draw_stage5_boss_claw_section_p2:
	; (not executed in the CDL traces)
	ldx	#$10E0
	stx	zp_10
	ldx	#$11D2
	stx	zp_12
	lda	#$8000
	sta	zp_14
	jsr	a:is_p2_view_falling_2
	bcs	loc_03FCB3
	jsr	a:draw_stage5_boss_claw_p2
loc_03FCB3:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1100
	bcs	@return
	lda	#$F000
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
loc_03FCD5:
	lda	$00,x
	beq	loc_03FD56
	asl	a
	tay
	lda	a:ptrs_td_metasprite_sets,y
	sta	zp_C4
	lda	a:ptrs_td_stream_sets,y
	sta	zp_C6
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FCF8
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	brl	loc_03FD56
loc_03FCF8:
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
	sta	a:$1780,y
	lda	a:$0002,x
	sta	a:$1782,y
	lda	a:$0004,x
	sta	a:$1784,y
	ply
	jsr	a:draw_topdown_metasprite_p2
	plx
	lda	zp_D0
	bne	loc_03FD4F
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
	bra	loc_03FD56
loc_03FD4F:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
loc_03FD56:
	inc	zp_08
	inc	zp_08
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0BC0
	bcs	@return
	brl	loc_03FCD5
@return:
	rts

is_p2_view_falling_2:
	; (not executed in the CDL traces)
	lda	a:title_menu_cursor
	beq	loc_03FD71
	dec	a
	bne	loc_03FD79
loc_03FD71:
	lda	a:wram_0F2C
	beq	loc_03FD79
	brl	loc_03FD7B
loc_03FD79:
	clc
	rts
loc_03FD7B:
	sec
	rts

draw_stage5_boss_arm_p2:
	; (not executed in the CDL traces)
	ldx	#$1130
	stx	zp_10
	ldx	#$11D6
	stx	zp_12
	lda	#$0002
	bne	loc_03FD93
	lda	#$8000
	sta	zp_14
	bra	loc_03FD9E
loc_03FD93:
	lda	$00,x
	xba
	and	#$FF00
	ora	#$0080
	sta	zp_14
loc_03FD9E:
	ldx	#$0BC0
loc_03FDA1:
	lda	$00,x
	beq	loc_03FE1E
	ora	$02,x
	sta	zp_04
	ldy	$0A,x
	lda	$0E,x
	jsr	a:project_to_view
	bcc	loc_03FDBB
	lda	$2E,x
	and	#$FFF7
	sta	$2E,x
	bra	loc_03FE17
loc_03FDBB:
	lda	$2E,x
	ora	#$0008
	sta	$2E,x
	ldy	zp_10
	sec
	lda	zp_02
	sbc	#$0008
	cmp	zp_0C
	bmi	loc_03FE17
	cmp	zp_0E
	bpl	loc_03FE17
	sta	a:$0001,y
	sec
	lda	zp_00
	sbc	#$0008
	cmp	#$0100
	bpl	loc_03FE17
	cmp	#$FFF0
	bmi	loc_03FE17
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
	bcc	loc_03FE0E
	ldy	zp_12
	lda	zp_14
	sta	a:$0000,y
	iny
	iny
	lda	#$8000
	sta	zp_14
	sty	zp_12
loc_03FE0E:
	lda	$2E,x
	ora	#$0002
	sta	$2E,x
	bra	loc_03FE1E
loc_03FE17:
	lda	$2E,x
	and	#$FFFD
	sta	$2E,x
loc_03FE1E:
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0EC0
	bcs	loc_03FE2C
	brl	loc_03FDA1
loc_03FE2C:
	lda	zp_14
@loop:
	lsr	a
	bcc	@loop
	ora	#$AAAA
	sta	(zp_12)
	ldx	zp_10
	cpx	#$1160
	bcs	@return
	lda	#$F000
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
