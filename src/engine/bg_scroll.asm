; engine/bg_scroll.asm -- BG scrolling, tilemap updates and stage spawning
; Bank $00, $00:C283-$00:CF0B. Included by main.asm in segment BANK00.
;
; Side-view stages scroll BG1 (the playfield) and BG2 (background). Each
; layer has a scroll state of $40 bytes (BG_* fields): BG1 at bg1_x ($1380),
; BG2 at bg2_x ($13C0), BG3 at $1400. The layers' maps are in $7E (BG1 map
; at $7E:9000, metatiles from $7E:5000; BG2 $7E:F000 / $7E:B000): a map word
; is a metatile number (bits 0-13) and flips (bits 14-15); a metatile is
; 4x4 tiles. When the scroll crosses an 8-pixel column or row, draw_bg_column
; / draw_bg_row queue the new tiles through the VRAM queue, and
; update_bg_collision_map turns them into the collision map at $7E:4000
; (a word per tile, classed by tile-number thresholds zp_C8-zp_DE).
;
; run_bg1_scroll_mode (each frame) runs the BG1 handler bg1_scroll_mode
; (tbl_bg1_scroll_modes): horizontal or vertical stages, following the
; players past scroll_threshold or autoscrolling (bg1_autoscroll). BG2 has
; its own handler (bg2_scroll_mode, tbl_bg2_scroll_modes): parallax at 1/8
; or 1/3 of BG1, autoscroll, drawn progressively, ...
;
; dma_bg_tilemap_updates (NMI) does the other BG DMAs: rows from $7F, an
; extra DMA (bg_dma_vram_addr), groups of 4x4 tile blocks ($1800/$1840).
;
; init_stage_spawns / spawn_stage_objects place the stage's objects as BG1
; scrolls: per 256-pixel page, a list of 10-byte entries {position in the
; page ($FF end), type, first and last slot / $10, x, y, field $3A}.

; NMI (side view). player_tiles_vram_top/player_tiles_vram_bottom: VRAM addresses of 6 rows each, sources at
; $1780; bg_dma_vram_addr: one DMA; $1800-$183E: up to 8 VRAM addresses of
; 4-row blocks (source pointers at $1840).
dma_bg_tilemap_updates:
	sep	#$10
	.i8
	lda	player_tiles_vram_top
	bne	@rows
	brl	@extra_dma
@rows:
	sta	a:VMADDL
	ldx	#$80
	stx	a:VMAIN
	lda	#$1801
	sta	a:DMAP0
	lda	a:player_tile_src
	sta	a:A1T0L
	lda	#$007F
	sta	a:A1B0
	ldy	#$40
	sty	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:player_tile_src+2
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+4
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+6
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+8
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+10
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	player_tiles_vram_bottom
	sta	a:VMADDL
	lda	a:player_tile_src+12
	sta	a:A1T0L
	sty	a:DAS0L
	ldx	#$01
	stx	a:MDMAEN
	lda	a:player_tile_src+14
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+16
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+18
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+20
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
	lda	a:player_tile_src+22
	sta	a:A1T0L
	sty	a:DAS0L
	stx	a:MDMAEN
@extra_dma:
	ldy	#$01
	ldx	#$7E
	stx	a:A1B0
	lda	bg_dma_vram_addr
	beq	@blocks0
	sta	a:VMADDL
	lda	bg_dma_src
	sta	a:A1T0L
	lda	bg_dma_size
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks0:
	lda	a:vram_block_queue
	beq	@blocks1
	sta	a:VMADDL
	lda	a:vram_block_src
	sta	a:A1T0L
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+2
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+4
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+6
	sta	a:VMADDL
	lda	zp_E2
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks1:
	lda	a:vram_block_queue+8
	beq	@blocks2
	sta	a:VMADDL
	lda	a:vram_block_src+1*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+10
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+12
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+14
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks2:
	lda	a:vram_block_queue+16
	beq	@blocks3
	sta	a:VMADDL
	lda	a:vram_block_src+2*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+18
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+20
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+22
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks3:
	lda	a:vram_block_queue+24
	beq	@blocks4
	sta	a:VMADDL
	lda	a:vram_block_src+3*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+26
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+28
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+30
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks4:
	lda	a:vram_block_queue+32
	beq	@blocks5
	sta	a:VMADDL
	lda	a:vram_block_src+4*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+34
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+36
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+38
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks5:
	lda	a:vram_block_queue+40
	beq	@blocks6
	sta	a:VMADDL
	lda	a:vram_block_src+5*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+42
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+44
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+46
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks6:
	lda	a:vram_block_queue+48
	beq	@blocks7
	sta	a:VMADDL
	lda	a:vram_block_src+6*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+50
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+52
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+54
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@blocks7:
	lda	a:vram_block_queue+56
	beq	@done
	sta	a:VMADDL
	lda	a:vram_block_src+7*8
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+58
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+60
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	a:vram_block_queue+62
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
@done:
	rep	#$10
	.i16
	rtl

; Writes BG3 tilemap blocks (4 rows of 4 tiles) listed in bg3_block_sources from
; $7E to VRAM $5C00 (stage 4).
draw_bg3_block_map:
	ldx	#$0000
	ldy	#$0001
	lda	#$5C00
	sta	zp_0E
	sta	zp_00
	lda	#$0008
	sta	zp_0A
@loop:
	lda	a:bg3_block_sources,x
	sta	zp_08
	sep	#$10
	.i8
	lda	#$1801
	sta	a:DMAP0
	ldy	#$80
	sty	a:VMAIN
	lda	#$007E
	sta	a:A1B0
	lda	zp_00
	sta	a:VMADDL
	lda	zp_08
	sta	a:A1T0L
	lda	#$0008
	sta	a:DAS0L
	ldy	#$01
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0020
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0040
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	lda	zp_00
	clc
	adc	#$0060
	sta	a:VMADDL
	lda	#$0008
	sta	a:DAS0L
	sty	a:MDMAEN
	rep	#$10
	.i16
	dec	zp_0A
	bne	@next_column
	lda	#$0008
	sta	zp_0A
	clc
	lda	zp_0E
	adc	#$0080
	sta	zp_0E
	bra	@store_addr
@next_column:
	clc
	lda	zp_00
	adc	#$0004
@store_addr:
	sta	zp_00
	inx
	inx
	cpx	#$0070
	bcs	@done
	brl	@loop
@done:
	rtl

; X = BG state, Y = map base ($4000 BG1, $A000 BG2). With the display off,
; draws the whole screen column by column.
fill_bg_screen:
	stx	zp_FC
	sty	zp_FE
	stz	BG_COLUMN_OFFSET,x
	stz	BG_Y,x
	lda	#$0100
	sta	BG_X,x
	lda	zp_FC
	cmp	#$1380
	bne	@full_width
	lda	stage_number
	cmp	#$0004
	beq	@full_width
	lda	#$0020
	bra	@set_count
@full_width:
	lda	#$003F
@set_count:
	sta	zp_18
@loop:
	ldx	zp_FC
	jsl	f:draw_bg_column
	lda	zp_FC
	cmp	#$1380
	bne	@no_collision
	jsl	f:update_bg_collision_map
@no_collision:
	jsl	f:run_vram_queue
	ldx	zp_FC
	clc
	lda	BG_X,x
	adc	#$0008
	sta	BG_X,x
	cmp	#$01FF
	bcc	@next
	stz	BG_X,x
	clc
	lda	BG_MAP_OFFSET,x
	adc	#$0080
	sta	BG_MAP_OFFSET,x
@next:
	dec	zp_18
	bpl	@loop
	stz	BG_X,x
	stz	$02,x
	lda	#$0000
	sta	a:bg1_scroll_mode
	lda	#$0005
	sta	a:bg2_scroll_mode
	stz	a:bg1_x+BG_PAGE
	rtl

; Dispatch on bg1_scroll_mode.
run_bg1_scroll_mode:
	lda	a:bg1_scroll_mode
	phx
	asl	a
	tax
	lda	f:tbl_bg1_scroll_modes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_bg1_scroll_modes:
	.addr	bg1_init_horizontal
	.addr	bg1_scroll_horizontal
	.addr	bg1_init_vertical
	.addr	bg1_scroll_vertical
	.addr	bg1_scroll_stop
	.addr	bg1_draw_column_at_8
	.addr	bg1_update_vertical

bg1_scroll_stop:
	stz	a:bg1_x_delta
	stz	a:bg1_y_delta
	rtl

bg1_init_horizontal:
	lda	#$0080
	sta	scroll_threshold
	jsl	f:clear_bg1_scroll_deltas
	stz	a:bg1_x+BG_COLUMN_OFFSET
	lda	#$0001
	sta	a:bg1_scroll_mode
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:draw_bg_column
	jsl	f:update_bg_collision_map
	clc
	lda	a:bg1_x
	adc	#$0008
	sta	a:bg1_x
	ldx	#$1380
	ldy	#$4000
	jsl	f:draw_bg_column
	jsl	f:update_bg_collision_map
	lda	#$0002
	sta	a:bg1_x+BG_COLUMN_OFFSET
	sec
	lda	a:bg1_x
	sbc	#$0008
	sta	a:bg1_x
	sta	a:spawn_last_page
	clc
	adc	#$0010
	and	#$FF00
	sta	a:bg1_x+BG_PAGE
	stz	a:spawn_pos_invert
	lda	#$1380
	sta	a:spawn_scroll_var
	rtl

; Follows a player who walks right past scroll_threshold ($80, $A0 when both
; play) by his PLAYER_DX, unless the other player is at the left edge; with
; bg1_autoscroll, scrolls $6800/$10000 pixel a frame.
bg1_scroll_horizontal:
	lda	a:bg1_autoscroll
	bne	@autoscroll
	ldx	#$0080
	lda	a:p1_lives
	beq	@check_p1
	lda	a:p2_lives
	beq	@check_p1
	ldx	#$00A0
@check_p1:
	stx	scroll_threshold
	lda	a:player1_obj+OBJ_X
	cmp	scroll_threshold
	bcc	@check_p2
	ldx	#$0200
	ldy	#$0240
	lda	OBJ_X_VEL,x
	beq	@player_not_moving
	bmi	@player_not_moving
	bra	@push_player
@check_p2:
	lda	a:p2_lives
	beq	@no_scroll
	lda	a:player2_obj+OBJ_X
	cmp	scroll_threshold
	bcc	@no_scroll
	ldx	#$0240
	ldy	#$0200
	lda	OBJ_X_VEL,x
	beq	@player_not_moving
	bmi	@player_not_moving
@push_player:
	lda	a:PLAYER_LIVES,y
	beq	@scroll_by_player
	lda	a:OBJ_X,y
	cmp	#$000C
	bcs	@scroll_by_player
	sec
	lda	OBJ_X,x
	sbc	a:PLAYER_DX,x
	sta	OBJ_X,x
@no_scroll:
	stz	a:bg1_x_delta
	stz	a:PLAYER_DX,x
	rtl
@scroll_by_player:
	clc
	lda	a:PLAYER_DX,x
	sta	a:bg1_x_delta
	bra	@apply
@player_not_moving:
	lda	a:PLAYER_LIVES,y
	beq	@autoscroll
	lda	a:OBJ_X,y
	cmp	#$000C
	bcc	@no_scroll
@autoscroll:
	clc
	lda	a:bg1_x_sub
	adc	#$6800
	sta	a:bg1_x_sub
	lda	#$0000
	adc	#$0001
	sta	a:bg1_x_delta
@apply:
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	BG_X,x
	adc	BG_X_DELTA,x
	sta	BG_X,x
	clc
	lda	BG_COLUMN_OFFSET,x
	asl	a
	asl	a
	asl	a
	adc	BG_X,x
	and	#$FF00
	cmp	BG_PAGE,x
	beq	@draw
	sta	BG_PAGE,x
	clc
	lda	BG_MAP_OFFSET,x
	adc	#$0080
	sta	BG_MAP_OFFSET,x
@draw:
	jsl	f:draw_bg_column
	jmp	a:update_bg_collision_map

bg1_init_vertical:
	lda	#$0060
	sta	scroll_threshold
	jsl	f:clear_bg1_scroll_deltas
	inc	a:bg1_scroll_mode
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:draw_bg_row
	jsl	f:update_bg_collision_map
	clc
	lda	a:bg1_y
	adc	#$0008
	sta	a:bg1_y
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	jsl	f:draw_bg_row
	jsl	f:update_bg_collision_map
	sec
	lda	a:bg1_y
	sbc	#$0008
	sta	a:bg1_y
	clc
	adc	#$00F0
	and	#$FF00
	sta	a:bg1_x+BG_PAGE
	lda	a:bg1_y
	and	#$FF00
	sta	a:spawn_last_page
	lda	#$FFFF	; [num]
	sta	a:spawn_pos_invert
	lda	#$1398
	sta	a:spawn_scroll_var
	rtl
bg1_no_vertical_scroll:
	stz	a:bg1_y_sub
	stz	a:bg1_y_delta
	rtl

; Follows a player who moves up past scroll_threshold, or autoscrolls at
; bg1_autoscroll_speeds[bg1_autoscroll_speed].
bg1_scroll_vertical:
	lda	a:bg1_autoscroll
	bne	@autoscroll
	lda	a:p1_lives
	beq	@check_p2
	lda	a:player1_obj+OBJ_Y
	bmi	@p1_high
	cmp	scroll_threshold
	bcs	@check_p2
@p1_high:
	ldx	#$0200
	lda	OBJ_Y_VEL,x
	bpl	@autoscroll
	bmi	@scroll_by_player
@check_p2:
	lda	a:p2_lives
	beq	bg1_no_vertical_scroll
	; (not executed in the CDL traces)
	lda	a:player2_obj+OBJ_Y
	bmi	@p2_high
	cmp	scroll_threshold
	bcs	bg1_no_vertical_scroll
@p2_high:
	ldx	#$0240
	lda	OBJ_Y_VEL,x
	bpl	@autoscroll
@scroll_by_player:
	clc
	lda	OBJ_Y_SUB,x
	adc	OBJ_Y_VEL_SUB,x
	lda	OBJ_Y,x
	sta	zp_00
	adc	OBJ_Y_VEL,x
	sec
	sbc	zp_00
	sta	a:bg1_y_delta
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	BG_Y,x
	adc	a:bg1_y_delta
	sta	BG_Y,x
	stz	a:bg1_y_sub
	bra	@page
@autoscroll:
	ldy	a:bg1_autoscroll_speed
	clc
	lda	a:bg1_autoscroll_speeds,y
	adc	a:bg1_y_sub
	sta	a:bg1_y_sub
	lda	#$FFFF	; [num]
	adc	#$0000
	sta	a:bg1_y_delta
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	BG_Y,x
	adc	BG_Y_DELTA,x
	sta	BG_Y,x
@page:
	clc
	lda	#$00F0
	adc	BG_Y,x
	and	#$FF00
	cmp	BG_PAGE,x
	beq	@draw
	sta	BG_PAGE,x
	clc
	lda	BG_MAP_OFFSET,x
	adc	#$0080
	sta	BG_MAP_OFFSET,x
@draw:
	jsl	f:draw_bg_row
	jmp	a:update_bg_collision_map

bg1_update_vertical:
	ldx	#$1380
	stx	zp_FC
	ldy	#$4000
	sty	zp_FE
	clc
	lda	#$00F0
	adc	BG_Y,x
	and	#$FF00
	cmp	BG_PAGE,x
	beq	@draw
	sta	BG_PAGE,x
	clc
	lda	BG_MAP_OFFSET,x
	adc	#$0080
	sta	BG_MAP_OFFSET,x
@draw:
	jsl	f:draw_bg_row
	jmp	a:update_bg_collision_map

bg2_draw_column_at_8:
	ldx	#$13C0
	ldy	#$A000	; [num]
	bra	bg_draw_column_at_8

bg1_draw_column_at_8:
	ldx	#$1380
	ldy	#$4000
bg_draw_column_at_8:
	stx	zp_FC
	sty	zp_FE
	clc
	lda	#$0008
	sta	BG_COLUMN_OFFSET,x
	asl	a
	asl	a
	asl	a
	adc	BG_X,x
	and	#$FF00
	lsr	a
	sta	BG_MAP_OFFSET,x
	jml	f:draw_bg_column

; Dispatch on bg2_scroll_mode.
run_bg2_scroll_mode:
	lda	a:bg2_scroll_mode
	phx
	asl	a
	tax
	lda	f:tbl_bg2_scroll_modes,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_bg2_scroll_modes:
	.addr	bg2_scroll_none
	.addr	bg2_start_draw_screen
	.addr	bg2_draw_screen_step
	.addr	bg2_scroll_none_3
	.addr	bg2_parallax_x_1_8_hdma
	.addr	bg2_parallax_x_1_8
	.addr	bg2_autoscroll_x
	.addr	bg2_parallax_y_1_3
	.addr	bg2_scroll_none_8
	.addr	bg2_follow_bg1_x
	.addr	bg2_autoscroll_x
	.addr	bg2_autoscroll_xy
	.addr	bg2_draw_column_at_8

bg2_scroll_none:
	rtl

bg2_draw_screen_step:
	lda	a:bg2_screen_drawn
	bne	@done
	lda	a:bg2_draw_x
	sta	a:bg2_x
	ldx	#$13C0
	stx	zp_FC
	ldy	#$A000	; [num]
	sty	zp_FE
	jsl	f:draw_bg_column
	sec
	lda	a:bg2_draw_x
	sbc	#$0008
	sta	a:bg2_draw_x
	cmp	#$00F8
	bne	@check_end
	clc
	lda	a:bg2_map_offset
	adc	#$0080
	sta	a:bg2_map_offset
	bra	@done
@check_end:
	cmp	#$FFF8	; [num]
	bne	@done
	inc	a:bg2_screen_drawn
@done:
	stz	a:bg2_x
	rtl

bg2_start_draw_screen:
	stz	a:bg2_x+BG_COLUMN_OFFSET
	stz	a:bg2_y
	stz	a:bg2_y_sub
	stz	a:bg2_x
	stz	a:bg2_x_sub
	lda	#$01F8
	sta	a:bg2_draw_x
	inc	a:bg2_scroll_mode
	rtl

bg2_parallax_x_1_8_hdma:
	jsl	f:bg2_parallax_x_1_8
	lda	a:bg2_x
	sta	f:hdma_tables+$01
	sta	f:hdma_tables+$04
	rtl

bg2_scroll_none_3:
	; (not executed in the CDL traces)
	rtl

bg2_parallax_x_1_8:
	stz	a:bg2_x+BG_X_MOVED
	stz	a:bg2_x+BG_Y_MOVED
	clc
	lda	a:bg1_x_delta
	adc	a:bg2_x+BG_X_DELTA
	sta	a:bg2_x+BG_X_DELTA
	sec
	sbc	#$0008
	bmi	@done
	sta	a:bg2_x+BG_X_DELTA
	inc	a:bg2_x
	inc	a:bg2_x+BG_X_MOVED
@done:
	rtl

bg2_autoscroll_x:
	clc
	lda	a:bg2_x_sub
	adc	#$2000
	sta	a:bg2_x_sub
	lda	a:bg2_x
	adc	#$0001
	sta	a:bg2_x
	rtl

bg2_autoscroll_xy:
	sec
	lda	a:bg2_y_sub
	sbc	#$A000
	sta	a:bg2_y_sub
	lda	a:bg2_y
	sbc	#$0000
	sta	a:bg2_y
	jsl	f:bg2_autoscroll_x

bg2_parallax_y_1_3:
	ldx	#$13C0
	stx	zp_FC
	ldy	#$A000	; [num]
	sty	zp_FE
	lda	BG_X,x
	and	#$00FF
	sta	BG_X,x
	stz	$12,x
	stz	$2A,x
	clc
	lda	a:bg1_y_delta
	adc	BG_Y_DELTA,x
	sta	BG_Y_DELTA,x
@loop:
	clc
	adc	#$0003
	bpl	@page
	sta	BG_Y_DELTA,x
	dec	BG_Y,x
	dec	$2A,x
	bra	@loop
@page:
	clc
	lda	#$00F0
	adc	BG_Y,x
	and	#$FF00
	cmp	BG_PAGE,x
	beq	@draw
	sta	BG_PAGE,x
	clc
	lda	BG_MAP_OFFSET,x
	adc	#$0080
	sta	BG_MAP_OFFSET,x
@draw:
	brl	draw_bg_row

bg2_scroll_none_8:
	; (not executed in the CDL traces)
	rtl

bg2_follow_bg1_x:
	clc
	lda	a:bg1_x_delta
	sta	a:bg2_x+BG_X_DELTA
	sta	a:bg2_x+BG_X_MOVED
	stz	a:bg2_x+BG_Y_MOVED
	clc
	adc	a:bg2_x
	sta	a:bg2_x
	rtl

; X = BG state, zp_FE = map base: queues the tile row entering the screen.
draw_bg_row:
	clc
	lda	BG_Y,x
	adc	#$0010
	and	#$0018
	sta	zp_0A
	lda	BG_Y,x
	lsr	a
	sec
	sbc	#$0008
	and	#$0070
	clc
	adc	zp_FE
	adc	BG_MAP_OFFSET,x
	adc	#$5000
	sta	zp_00
	lda	vram_queue_end
	sta	zp_1A
	lda	#$0008
	sta	zp_06
	lda	#$FFFF	; [num]
	sta	zp_0C
	lda	BG_X,x
	and	#$0100
	asl	a
	asl	a
	sta	zp_04
	clc
	lda	BG_Y,x
	adc	#$00F0
	and	#$00F8
	asl	a
	asl	a
	ora	zp_04
	sta	zp_04
	ldx	zp_FE
	cpx	#$4000
	bne	@bg2
	clc
	adc	#$4000
	bra	@queue
@bg2:
	clc
	adc	#$4800
@queue:
	sta	zp_04
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0080
	ldy	zp_04
	jsl	f:begin_vram_transfer_vmain
@loop:
	lda	(zp_00)
	and	#$3FFF
	clc
	adc	#$1000
	adc	zp_FE
	tay
	lda	(zp_00)
	and	#$C000
	cmp	zp_0C
	beq	@same_flip
	sta	zp_0C
	xba
	lsr	a
	ora	zp_0A
	tax
	lda	f:metatile_row_offsets,x
	sta	zp_10
	lda	f:metatile_row_offsets+2,x
	sta	zp_12
	lda	f:metatile_row_offsets+4,x
	sta	zp_14
	lda	f:metatile_row_offsets+6,x
	sta	zp_16
@same_flip:
	ldx	vram_queue_data_ptr
	lda	(zp_10),y
	eor	zp_0C
	sta	a:$0000,x
	lda	(zp_12),y
	eor	zp_0C
	sta	a:$0002,x
	lda	(zp_14),y
	eor	zp_0C
	sta	a:$0004,x
	lda	(zp_16),y
	eor	zp_0C
	sta	a:$0006,x
	txa
	clc
	adc	#$0008
	sta	vram_queue_data_ptr
	inc	zp_00
	inc	zp_00
	dec	zp_06
	bne	@loop
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

; X = BG state, zp_FE = map base: queues the tile column entering the screen
; (7 metatiles for BG1, 8 for BG2).
draw_bg_column:
	lda	BG_COLUMN_OFFSET,x
	asl	a
	asl	a
	asl	a
	clc
	adc	BG_X,x
	and	#$0018
	sta	zp_0A
	lda	BG_X,x
	and	#$00F8
	lsr	a
	lsr	a
	lsr	a
	clc
	adc	BG_COLUMN_OFFSET,x
	sta	zp_08
	lsr	a
	and	#$000E
	clc
	adc	zp_FE
	adc	BG_MAP_OFFSET,x
	adc	#$5000
	sta	zp_02
	lda	vram_queue_end
	sta	zp_1A
	ldy	#$0008
	cpx	#$1380
	bne	@set_count
	ldy	#$0007
@set_count:
	sty	zp_06
	lda	#$FFFF	; [num]
	sta	zp_0C
	ldy	#$0000
	clc
	lda	zp_08
	bit	#$FFE0
	bne	@screen_half
	ldy	#$0100
@screen_half:
	sty	zp_1C
	and	#$001F
	sta	zp_04
	lda	BG_X,x
	and	#$0100
	eor	zp_1C
	asl	a
	asl	a
	ora	zp_04
	ldx	zp_FE
	cpx	#$4000
	bne	@bg2
	clc
	adc	#$4000
	bra	@queue
@bg2:
	clc
	adc	#$4800
@queue:
	sta	zp_04
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	#$0081
	ldy	zp_04
	jsl	f:begin_vram_transfer_vmain
@loop:
	lda	(zp_02)
	and	#$3FFF
	clc
	adc	#$1000
	adc	zp_FE
	tay
	lda	(zp_02)
	and	#$C000
	cmp	zp_0C
	beq	@same_flip
	sta	zp_0C
	xba
	lsr	a
	ora	zp_0A
	tax
	lda	f:metatile_column_offsets,x
	sta	zp_10
	lda	f:metatile_column_offsets+2,x
	sta	zp_12
	lda	f:metatile_column_offsets+4,x
	sta	zp_14
	lda	f:metatile_column_offsets+6,x
	sta	zp_16
@same_flip:
	ldx	vram_queue_data_ptr
	lda	(zp_10),y
	eor	zp_0C
	sta	a:$0000,x
	lda	(zp_12),y
	eor	zp_0C
	sta	a:$0002,x
	lda	(zp_14),y
	eor	zp_0C
	sta	a:$0004,x
	lda	(zp_16),y
	eor	zp_0C
	sta	a:$0006,x
	txa
	clc
	adc	#$0008
	sta	vram_queue_data_ptr
	lda	zp_02
	clc
	adc	#$0010
	sta	zp_02
	dec	zp_06
	bne	@loop
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

clear_bg1_scroll_deltas:
	stz	a:bg1_x+BG_X_DELTA_SUB
	stz	a:bg1_x_delta
	stz	a:bg1_y_sub
	stz	a:bg1_y_delta
	rtl

; (no caller found; decoded because it follows the end of a routine)
clear_bg2_scroll_deltas:
	; (not executed in the CDL traces)
	stz	a:bg2_x+BG_X_DELTA_SUB
	stz	a:bg2_x+BG_X_DELTA
	stz	a:bg2_x+BG_Y_DELTA_SUB
	stz	a:bg2_x+BG_Y_DELTA
	rtl

; Converts the last queued row/column (zp_1A = its entry) into collision
; words at $7E:4000 (TILE_* in ram.inc): the tile number (bits 0-9) against
; the stage's ascending thresholds zp_C8-zp_DE picks the class (a threshold
; of 0 skips its class); the h-flip of the tile (bit 14) becomes
; TILE_FLIPPED on the slope and sloped bar classes.
update_bg_collision_map:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_1A
	ldy	#$0002
	lda	a:$0000,x
	cmp	#$0081
	bne	@set_step
	ldy	#$0040
@set_step:
	sty	zp_06
	lda	a:$0004,x
	and	#$0FFF
	asl	a
	clc
	adc	#$4000
	sta	zp_00
	lda	a:$0006,x
	sta	zp_0E
	lda	a:$0009,x
	sta	zp_02
	ldy	#$0000
@loop:
	lda	(zp_0E),y
	sta	zp_0A
	rol	a
	rol	a
	rol	a
	and	#TILE_FLIPPED
	sta	zp_0C
	lda	zp_0A
	and	#$03FF
	cmp	zp_C8
	bcs	@class1
	lda	#$0000
	bra	@store
@class1:
	cmp	zp_CA
	bcs	@class2
	lda	#TILE_NO_DROP|TILE_CLIMBABLE
	bra	@store
@class2:
	cmp	zp_CC
	bcs	@class3
	lda	#TILE_PLATFORM
	bra	@store
@class3:
	cmp	zp_CE
	bcs	@class4
	lda	#TILE_SLOPE_CLASS|TILE_PLATFORM_SLOPE_UPPER
	bra	@mirror
@class4:
	cmp	zp_D0
	bcs	@class5
	lda	#TILE_SLOPE_CLASS|TILE_PLATFORM_SLOPE_LOWER
	bra	@mirror
@class5:
	cmp	zp_D2
	bcs	@class6
	lda	#TILE_SLOPE_CLASS|TILE_NO_DROP|TILE_SLOPE_UPPER
	bra	@mirror
@class6:
	cmp	zp_D4
	bcs	@class7
	lda	#TILE_SLOPE_CLASS|TILE_NO_DROP|TILE_SLOPE_LOWER
	bra	@mirror
@class7:
	cmp	zp_D6
	bcs	@class8
	lda	#TILE_SLOPE_CLASS|TILE_NO_DROP|TILE_CEILING_SLOPE_LOWER
	bra	@mirror
@class8:
	cmp	zp_D8
	bcs	@class9
	lda	#TILE_SLOPE_CLASS|TILE_NO_DROP|TILE_CEILING_SLOPE_UPPER
	bra	@mirror
@class9:
	cmp	zp_DA
	bcs	@class10
	lda	#TILE_HANG_CLASS|TILE_BAR
	bra	@store
@class10:
	cmp	zp_DC
	bcs	@class11
	lda	#TILE_SLOPE_CLASS|TILE_HANG_CLASS|TILE_BAR_SLOPE_UPPER
	bra	@mirror
@class11:
	cmp	zp_DE
	bcs	@class12
	lda	#TILE_SLOPE_CLASS|TILE_HANG_CLASS|TILE_BAR_SLOPE_LOWER
	bra	@mirror
@class12:
	lda	#TILE_WALL|TILE_NO_DROP
	bra	@store
@mirror:
	eor	zp_0C
@store:
	sta	(zp_00)
	lda	zp_00
	clc
	adc	zp_06
	sta	zp_00
	iny
	iny
	cpy	zp_02
	bcs	@done
	brl	@loop
@done:
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
metatile_column_offsets:
	; CDL: read by draw_bg_column
	.byte	$00, $00
	.byte	$08, $00
	.byte	$10, $00
	.byte	$18, $00, $02, $00, $0A, $00, $12, $00, $1A, $00, $04, $00, $0C, $00, $14, $00
	.byte	$1C, $00, $06, $00, $0E, $00, $16, $00, $1E, $00, $06, $00, $0E, $00, $16, $00
	.byte	$1E, $00, $04, $00, $0C, $00, $14, $00, $1C, $00, $02, $00, $0A, $00, $12, $00
	.byte	$1A, $00, $00, $00, $08, $00, $10, $00, $18, $00, $18, $00, $10, $00, $08, $00
	.byte	$00, $00, $1A, $00, $12, $00, $0A, $00, $02, $00, $1C, $00, $14, $00, $0C, $00
	.byte	$04, $00, $1E, $00, $16, $00, $0E, $00, $06, $00, $1E, $00, $16, $00, $0E, $00
	.byte	$06, $00, $1C, $00, $14, $00, $0C, $00, $04, $00, $1A, $00, $12, $00, $0A, $00
	.byte	$02, $00, $18, $00, $10, $00, $08, $00, $00, $00
metatile_row_offsets:
	; CDL: read by draw_bg_row
	.byte	$00, $00
	.byte	$02, $00
	.byte	$04, $00
	.byte	$06, $00, $08, $00, $0A, $00, $0C, $00, $0E, $00, $10, $00, $12, $00, $14, $00
	.byte	$16, $00, $18, $00, $1A, $00, $1C, $00, $1E, $00, $06, $00, $04, $00, $02, $00
	.byte	$00, $00, $0E, $00, $0C, $00, $0A, $00, $08, $00, $16, $00, $14, $00, $12, $00
	.byte	$10, $00, $1E, $00, $1C, $00, $1A, $00, $18, $00, $18, $00, $1A, $00, $1C, $00
	.byte	$1E, $00, $10, $00, $12, $00, $14, $00, $16, $00, $08, $00, $0A, $00, $0C, $00
	.byte	$0E, $00, $00, $00, $02, $00, $04, $00, $06, $00
	; CDL: not accessed
	.byte	$1E, $00, $1C, $00, $1A, $00, $18, $00, $16, $00, $14, $00, $12, $00, $10, $00
	.byte	$0E, $00, $0C, $00, $0A, $00, $08, $00, $06, $00, $04, $00, $02, $00, $00, $00

; Sets the spawner for a horizontal stage (bg1_x) at the current page.
init_stage_spawns:
	lda	a:bg1_x
	and	#$FF00
	sta	a:spawn_last_page
	lda	a:bg1_map_offset
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	lsr	a
	sec
	sbc	#$0002
	sta	a:spawn_page_index
	stz	a:spawn_entry_offset
	stz	a:spawn_pos_invert
	lda	#$1380
	sta	a:spawn_scroll_var
	lda	stage_number
	asl	a
	tay
	lda	a:ptrs_stage_spawn_pages,y
	sta	a:spawn_pages
	rtl

; Each frame: on a new page, spawns what is left of the old one and moves
; on; then spawns the next entry if its position has been reached.
spawn_stage_objects:
	lda	a:spawn_scroll_var
	sta	zp_02
	lda	a:spawn_pos_invert
	and	#$0001
	sta	zp_04
	lda	(zp_02)
	and	#$FF00
	cmp	a:spawn_last_page
	beq	@current_pos
	sta	a:spawn_last_page
@flush_page:
	lda	#$00FF
	jsl	f:spawn_next_stage_object
	lda	a:$0000,y
	cmp	#$00FF
	bne	@flush_page
	inc	a:spawn_page_index
	inc	a:spawn_page_index
	stz	a:spawn_entry_offset
@current_pos:
	lda	(zp_02)

spawn_next_stage_object:
	eor	a:spawn_pos_invert
	clc
	adc	zp_04
	and	#$00FF
	sta	zp_0C
	lda	a:spawn_page_index
	sta	zp_00
	ldy	a:spawn_pages
	lda	(zp_00),y
	clc
	adc	a:spawn_entry_offset
	tay
	lda	a:$0000,y
	and	#$00FF
	cmp	#$00FF
	beq	@done
	cmp	zp_0C
	beq	@spawn
	bcs	@done
@spawn:
	sta	zp_06
	jsr	a:find_free_object_slot_in_range
	bcs	@done
	lda	a:spawn_pos_invert
	bmi	@inverted
	sec
	lda	zp_0C
	sbc	zp_06
	stz	zp_0A
	sta	zp_08
	bra	@set_fields
@inverted:
	sec
	lda	zp_06
	sbc	zp_0C
	stz	zp_08
	sta	zp_0A
@set_fields:
	lda	a:$0001,y
	and	#$00FF
	sta	OBJ_TYPE,x
	clc
	lda	a:$0004,y
	adc	zp_08
	sta	OBJ_X,x
	sec
	lda	a:$0006,y
	sbc	zp_0A
	sta	OBJ_Y,x
	lda	a:$0008,y
	sta	$3A,x
	stz	OBJ_HP,x
	stz	OBJ_FLAGS,x
	clc
	lda	a:spawn_entry_offset
	adc	#$000A
	sta	a:spawn_entry_offset
@done:
	rtl

; Y = entry: first free object slot between entry bytes 2 and 3 (x $10) in
; X; carry set if none.
find_free_object_slot_in_range:
	lda	a:$0003,y
	and	#$00FF
	asl	a
	asl	a
	asl	a
	asl	a
	tax
	lda	a:$0002,y
	and	#$00FF
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_FC
	clc
@loop:
	lda	OBJ_TYPE,x
	beq	@done
	txa
	clc
	adc	#$0040
	tax
	cpx	zp_FC
	bcc	@loop
@done:
	rts
