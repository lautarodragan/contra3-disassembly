; topdown/support_04.asm -- Top-down stages: Mode 7 map and palettes (bank $04)
; Bank $04, $04:DA07-$04:E21A. Included by main.asm in segment BANK04.
;
; Per-map palette animation (animate_topdown_palettes), building the Mode 7
; tilemap and the tile attribute map from the block map (build_m7_tilemap),
; and queueing 4x4-tile block changes of the tilemap (queue_m7_block_patch).

; Per-map palette animation (tbl_topdown_palette_anims by topdown_map).
animate_topdown_palettes:
	ldx	a:topdown_map
	jmp	(.loword(tbl_topdown_palette_anims),x)
tbl_topdown_palette_anims:
	.addr	animate_stage2_palettes
	.addr	animate_stage2_palettes
	.addr	animate_stage5_palettes
	.addr	animate_stage5_boss_palettes

animate_stage2_palettes:
	jsl	f:start_stage2_palette_tasks
	jmp	a:step_palette_anim_timer

animate_stage5_palettes:
	jsl	f:start_stage5_palette_tasks
	jsl	f:step_palette_anim_timer

; Cycles colours $38-$3F of the palette buffer ($7E:2270), palette_cycle_speed
; steps per frame (high byte) or frames per step (low byte), unless palette_cycle_paused.
animate_stage5_boss_palettes:
	jmp	a:cycle_palette_colors

; Counts td_palette_anim_timer from 0 to $5F, wrapping.
step_palette_anim_timer:
	inc	a:td_palette_anim_timer
	lda	a:td_palette_anim_timer
	cmp	#$0060
	bcc	@return
	stz	a:td_palette_anim_timer
@return:
	rtl

; Starts the stage 2 palette tasks at timer 0 and $20.
start_stage2_palette_tasks:
	lda	a:td_palette_anim_timer
	bne	@second_task
	ldy	#.loword(palette_task_05F576)
	jml	f:start_palette_task
@second_task:
	cmp	#$0020
	bne	@return
	ldy	#.loword(palette_task_05F57C)
	jml	f:start_palette_task
@return:
	rtl

; Starts the stage 5 palette tasks at timer 0 and $20.
start_stage5_palette_tasks:
	lda	a:td_palette_anim_timer
	bne	@second_task
	ldy	#.loword(palette_task_05F582)
	jml	f:start_palette_task
@second_task:
	cmp	#$0020
	bne	@return
	ldy	#.loword(palette_task_05F588)
	jml	f:start_palette_task
@return:
	rtl

; Body of animate_stage5_boss_palettes (comment there); a negative
; palette_cycle_speed rotates the other way (not run in the traces).
cycle_palette_colors:
	lda	a:palette_cycle_paused
	bne	@return
	lda	a:palette_cycle_speed
	beq	@return
	bmi	@backwards
	cmp	#$0100
	bcs	@several_per_frame
	dec	a:palette_cycle_counter
	bmi	@rotate_once
	bne	@return
@rotate_once:
	and	#$00FF
	sta	a:palette_cycle_counter
	jsr	a:rotate_palette_colors_up
	rtl
@several_per_frame:
	xba
	and	#$00FF
	sta	a:palette_cycle_counter
@loop:
	jsr	a:rotate_palette_colors_up
	dec	a:palette_cycle_counter
	bne	@loop
@return:
	rtl
@backwards:
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
	cmp	#$0100
	bcs	@several_back_per_frame
	dec	a:palette_cycle_counter
	bmi	@rotate_back_once
	bne	@return2
@rotate_back_once:
	and	#$00FF
	sta	a:palette_cycle_counter
	jsr	a:rotate_palette_colors_down
	rtl
@several_back_per_frame:
	xba
	and	#$00FF
	sta	a:palette_cycle_counter
@loop2:
	jsr	a:rotate_palette_colors_down
	dec	a:palette_cycle_counter
	bne	@loop2
@return2:
	rtl

; Rotates the 8 colours at $7E:2270 by one entry.
rotate_palette_colors_up:
	phb
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	a:$227E
	ldx	#$2270
@loop:
	ldy	a:$0000,x
	sta	a:$0000,x
	tya
	inx
	inx
	cpx	#$2280
	bcc	@loop
	plb
	rts

; Rotates the 8 colours at $7E:2270 the other way.
rotate_palette_colors_down:
	; (not executed in the CDL traces)
	phb
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	lda	a:$2270
	ldx	#$227E
@loop:
	ldy	a:$0000,x
	sta	a:$0000,x
	tya
	dex
	dex
	cpx	#$2270
	bcs	@loop
	plb
	rts

; Builds the 128x128 Mode 7 tilemap in VRAM from the map of 4x4-tile blocks at
; $7E:9000 (block definitions at $7E:8000, 32 bytes each), a row of blocks at a time
; through $7E:3400, and the tile attribute map at $7E:4000 (build_tile_attr_rows).
build_m7_tilemap:
	stz	a:VMADDL
	sep	#$10
	.i8
	ldx	#$00
	stx	a:VMAIN
	rep	#$10
	.i16
	lda	#$4000
	sta	zp_0A
	lda	#$3400
	sta	zp_0C
	lda	#$9000	; [num]
	sta	zp_08
	lda	#$0004
	sta	zp_12
	sta	zp_14
	lda	#$0008
	sta	zp_16
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
@loop:
	.a16
	jsl	f:expand_m7_block_row
	lda	zp_08
	clc
	adc	#$0080
	sta	zp_08
	dec	zp_12
	bne	@loop
	jsl	f:upload_m7_tilemap_rows
	jsl	f:build_tile_attr_rows
	lda	#$3400
	sta	zp_0C
	lda	zp_08
	sec
	sbc	#$01F0
	sta	zp_08
	lda	#$0004
	sta	zp_12
	dec	zp_16
	bne	@loop
	lda	#$0008
	sta	zp_16
	lda	zp_08
	clc
	adc	#$0380
	sta	zp_08
	dec	zp_14
	bne	@loop
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

; Expands 8 blocks of the block map into 4 tile rows at $7E:3400.
expand_m7_block_row:
	ldy	zp_08
	lda	a:$0000,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$0002,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$0004,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$0006,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$0008,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$000A,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$000C,y
	jsl	f:expand_m7_block
	ldy	zp_08
	lda	a:$000E,y
	jml	f:expand_m7_block

; Expands one block (A) into 4x4 tiles at zp_0C.
expand_m7_block:
	and	#$00FF
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$8000
	tay
	sep	#$20
	.a8
	ldx	zp_0C
	lda	a:$0000,y
	sta	a:$0000,x
	lda	a:$0002,y
	sta	a:$0001,x
	lda	a:$0004,y
	sta	a:$0002,x
	lda	a:$0006,y
	sta	a:$0003,x
	lda	a:$0008,y
	sta	a:$0080,x
	lda	a:$000A,y
	sta	a:$0081,x
	lda	a:$000C,y
	sta	a:$0082,x
	lda	a:$000E,y
	sta	a:$0083,x
	lda	a:$0010,y
	sta	a:$0100,x
	lda	a:$0012,y
	sta	a:$0101,x
	lda	a:$0014,y
	sta	a:$0102,x
	lda	a:$0016,y
	sta	a:$0103,x
	lda	a:$0018,y
	sta	a:$0180,x
	lda	a:$001A,y
	sta	a:$0181,x
	lda	a:$001C,y
	sta	a:$0182,x
	lda	a:$001E,y
	sta	a:$0183,x
	rep	#$20
	.a16
	txa
	clc
	adc	#$0004
	sta	zp_0C
	rtl

; DMAs the 4 tile rows at $7E:3400 to the Mode 7 tilemap (VRAM low bytes).
upload_m7_tilemap_rows:
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	sep	#$10
	.i8
	lda	#$1800
	sta	a:DMAP0
	ldx	#$7E
	stx	a:A1B0
	lda	#$0200
	sta	a:DAS0L
	lda	#$3400
	sta	a:A1T0L
	ldx	#$01
	stx	a:MDMAEN
	rep	#$10
	.i16
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20

build_tile_attr_rows_none:
	.a16
	rtl

; Translates the 4 tile rows at $7E:3400 into the tile attribute map
; ($7E:4000, one byte per tile, read by the collision code) with the map's table.
build_tile_attr_rows:
	ldx	a:topdown_map
	jmp	(.loword(tbl_tile_attr_builders),x)
tbl_tile_attr_builders:
	.addr	build_tile_attr_rows_stage2
	.addr	build_tile_attr_rows_none
	.addr	build_tile_attr_rows_stage5
	.addr	build_tile_attr_rows_stage5_boss

build_tile_attr_rows_stage2:
	ldy	#$0000
@loop:
	lda	a:$3400,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	sta	(zp_0A)
	rep	#$20
	.a16
	inc	zp_0A
	iny
	cpy	#$0200
	bcc	@loop
	rtl

build_tile_attr_rows_stage5:
	ldy	#$0000
@loop:
	lda	a:$3400,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	sta	(zp_0A)
	rep	#$20
	.a16
	inc	zp_0A
	iny
	cpy	#$0200
	bcc	@loop
	rtl

build_tile_attr_rows_stage5_boss:
	ldy	#$0000
@loop:
	lda	a:$3400,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5_boss,x
	sta	(zp_0A)
	rep	#$20
	.a16
	inc	zp_0A
	iny
	cpy	#$0200
	bcc	@loop
	rtl

; Queues a 4x4-tile block (Y) at VRAM address A in the first free patch
; slot; carry set when all four are taken.
queue_m7_block_patch:
	ldx	a:m7_patch_flags
	beq	set_m7_block_patch_0
	ldx	a:m7_patch_flags+2
	bne	@slot_1_taken
	brl	set_m7_block_patch_1
@slot_1_taken:
	ldx	a:m7_patch_flags+4
	bne	@slot_2_taken
	brl	set_m7_block_patch_2
@slot_2_taken:
	ldx	a:m7_patch_flags+6
	bne	@all_taken
	brl	set_m7_block_patch_3
@all_taken:
	sec
	rtl

; Fills patch slot 0: VRAM row addresses from A, tiles of block Y.
set_m7_block_patch_0:
	rep	#$30
	sta	zp_FE
	sta	a:m7_patch_vram
	clc
	adc	#$0080
	sta	a:m7_patch_vram+2
	clc
	adc	#$0080
	sta	a:m7_patch_vram+4
	clc
	adc	#$0080
	sta	a:m7_patch_vram+6
	tya
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$8000
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	a:$0000,y
	sta	a:m7_patch_tiles
	lda	a:$0002,y
	sta	a:m7_patch_tiles+1
	lda	a:$0004,y
	sta	a:m7_patch_tiles+2
	lda	a:$0006,y
	sta	a:m7_patch_tiles+3
	lda	a:$0008,y
	sta	a:m7_patch_tiles+4
	lda	a:$000A,y
	sta	a:m7_patch_tiles+5
	lda	a:$000C,y
	sta	a:m7_patch_tiles+6
	lda	a:$000E,y
	sta	a:m7_patch_tiles+7
	lda	a:$0010,y
	sta	a:m7_patch_tiles+8
	lda	a:$0012,y
	sta	a:m7_patch_tiles+9
	lda	a:$0014,y
	sta	a:m7_patch_tiles+10
	lda	a:$0016,y
	sta	a:m7_patch_tiles+11
	lda	a:$0018,y
	sta	a:m7_patch_tiles+12
	lda	a:$001A,y
	sta	a:m7_patch_tiles+13
	lda	a:$001C,y
	sta	a:m7_patch_tiles+14
	lda	a:$001E,y
	sta	a:m7_patch_tiles+15
	rep	#$20
	.a16
	lda	#$0002
	sta	a:m7_patch_flags

; Shared tail of set_m7_block_patch_0-3 (Y = the block's tiles, DB = $7E,
; zp_FE = VRAM address): unless boss_centered_view, writes the attribute
; of each of the 16 tiles (tile_attrs_stage2 on stage 2, else
; tile_attrs_stage5) into the tile attribute map at $7E:4000 + address.
; Restores DB, returns carry clear.
set_m7_patch_tile_attrs:
	lda	a:boss_centered_view
	beq	@set_attrs
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl
@set_attrs:
	lda	stage_number
	cmp	#$0002
	beq	@stage2_attrs
	brl	@stage5_attrs
@stage2_attrs:
	lda	zp_FE
	clc
	adc	#$4000
	sta	zp_FC
	lda	a:$0000,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0000,x
	rep	#$20
	.a16
	lda	a:$0002,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0001,x
	rep	#$20
	.a16
	lda	a:$0004,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0002,x
	rep	#$20
	.a16
	lda	a:$0006,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0003,x
	rep	#$20
	.a16
	lda	a:$0008,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0080,x
	rep	#$20
	.a16
	lda	a:$000A,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0081,x
	rep	#$20
	.a16
	lda	a:$000C,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0082,x
	rep	#$20
	.a16
	lda	a:$000E,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0083,x
	rep	#$20
	.a16
	lda	a:$0010,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0100,x
	rep	#$20
	.a16
	lda	a:$0012,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0101,x
	rep	#$20
	.a16
	lda	a:$0014,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0102,x
	rep	#$20
	.a16
	lda	a:$0016,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0103,x
	rep	#$20
	.a16
	lda	a:$0018,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0180,x
	rep	#$20
	.a16
	lda	a:$001A,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0181,x
	rep	#$20
	.a16
	lda	a:$001C,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0182,x
	rep	#$20
	.a16
	lda	a:$001E,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage2,x
	ldx	zp_FC
	sta	a:$0183,x
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl
@stage5_attrs:
	lda	zp_FE
	clc
	adc	#$4000
	sta	zp_FC
	lda	a:$0000,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0000,x
	rep	#$20
	.a16
	lda	a:$0002,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0001,x
	rep	#$20
	.a16
	lda	a:$0004,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0002,x
	rep	#$20
	.a16
	lda	a:$0006,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0003,x
	rep	#$20
	.a16
	lda	a:$0008,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0080,x
	rep	#$20
	.a16
	lda	a:$000A,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0081,x
	rep	#$20
	.a16
	lda	a:$000C,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0082,x
	rep	#$20
	.a16
	lda	a:$000E,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0083,x
	rep	#$20
	.a16
	lda	a:$0010,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0100,x
	rep	#$20
	.a16
	lda	a:$0012,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0101,x
	rep	#$20
	.a16
	lda	a:$0014,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0102,x
	rep	#$20
	.a16
	lda	a:$0016,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0103,x
	rep	#$20
	.a16
	lda	a:$0018,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0180,x
	rep	#$20
	.a16
	lda	a:$001A,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0181,x
	rep	#$20
	.a16
	lda	a:$001C,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0182,x
	rep	#$20
	.a16
	lda	a:$001E,y
	and	#$00FF
	tax
	sep	#$20
	.a8
	lda	f:tile_attrs_stage5,x
	ldx	zp_FC
	sta	a:$0183,x
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl

set_m7_block_patch_1:
	rep	#$30
	sta	zp_FE
	sta	a:m7_patch_vram+8
	clc
	adc	#$0080
	sta	a:m7_patch_vram+10
	clc
	adc	#$0080
	sta	a:m7_patch_vram+12
	clc
	adc	#$0080
	sta	a:m7_patch_vram+14
	tya
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$8000
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	a:$0000,y
	sta	a:m7_patch_tiles+16
	lda	a:$0002,y
	sta	a:m7_patch_tiles+17
	lda	a:$0004,y
	sta	a:m7_patch_tiles+18
	lda	a:$0006,y
	sta	a:m7_patch_tiles+19
	lda	a:$0008,y
	sta	a:m7_patch_tiles+20
	lda	a:$000A,y
	sta	a:m7_patch_tiles+21
	lda	a:$000C,y
	sta	a:m7_patch_tiles+22
	lda	a:$000E,y
	sta	a:m7_patch_tiles+23
	lda	a:$0010,y
	sta	a:m7_patch_tiles+24
	lda	a:$0012,y
	sta	a:m7_patch_tiles+25
	lda	a:$0014,y
	sta	a:m7_patch_tiles+26
	lda	a:$0016,y
	sta	a:m7_patch_tiles+27
	lda	a:$0018,y
	sta	a:m7_patch_tiles+28
	lda	a:$001A,y
	sta	a:m7_patch_tiles+29
	lda	a:$001C,y
	sta	a:m7_patch_tiles+30
	lda	a:$001E,y
	sta	a:m7_patch_tiles+31
	rep	#$20
	.a16
	lda	#$0004
	sta	a:m7_patch_flags+2
	jmp	a:set_m7_patch_tile_attrs

set_m7_block_patch_2:
	rep	#$30
	sta	zp_FE
	sta	a:m7_patch_vram+16
	clc
	adc	#$0080
	sta	a:m7_patch_vram+18
	clc
	adc	#$0080
	sta	a:m7_patch_vram+20
	clc
	adc	#$0080
	sta	a:m7_patch_vram+22
	tya
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$8000
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	a:$0000,y
	sta	a:m7_patch_tiles+32
	lda	a:$0002,y
	sta	a:m7_patch_tiles+33
	lda	a:$0004,y
	sta	a:m7_patch_tiles+34
	lda	a:$0006,y
	sta	a:m7_patch_tiles+35
	lda	a:$0008,y
	sta	a:m7_patch_tiles+36
	lda	a:$000A,y
	sta	a:m7_patch_tiles+37
	lda	a:$000C,y
	sta	a:m7_patch_tiles+38
	lda	a:$000E,y
	sta	a:m7_patch_tiles+39
	lda	a:$0010,y
	sta	a:m7_patch_tiles+40
	lda	a:$0012,y
	sta	a:m7_patch_tiles+41
	lda	a:$0014,y
	sta	a:m7_patch_tiles+42
	lda	a:$0016,y
	sta	a:m7_patch_tiles+43
	lda	a:$0018,y
	sta	a:m7_patch_tiles+44
	lda	a:$001A,y
	sta	a:m7_patch_tiles+45
	lda	a:$001C,y
	sta	a:m7_patch_tiles+46
	lda	a:$001E,y
	sta	a:m7_patch_tiles+47
	rep	#$20
	.a16
	lda	#$0006
	sta	a:m7_patch_flags+4
	jmp	a:set_m7_patch_tile_attrs
set_m7_block_patch_3:
	rep	#$30
	sta	zp_FE
	sta	a:m7_patch_vram+24
	clc
	adc	#$0080
	sta	a:m7_patch_vram+26
	clc
	adc	#$0080
	sta	a:m7_patch_vram+28
	clc
	adc	#$0080
	sta	a:m7_patch_vram+30
	tya
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$8000
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	a:$0000,y
	sta	a:m7_patch_tiles+48
	lda	a:$0002,y
	sta	a:m7_patch_tiles+49
	lda	a:$0004,y
	sta	a:m7_patch_tiles+50
	lda	a:$0006,y
	sta	a:m7_patch_tiles+51
	lda	a:$0008,y
	sta	a:m7_patch_tiles+52
	lda	a:$000A,y
	sta	a:m7_patch_tiles+53
	lda	a:$000C,y
	sta	a:m7_patch_tiles+54
	lda	a:$000E,y
	sta	a:m7_patch_tiles+55
	lda	a:$0010,y
	sta	a:m7_patch_tiles+56
	lda	a:$0012,y
	sta	a:m7_patch_tiles+57
	lda	a:$0014,y
	sta	a:m7_patch_tiles+58
	lda	a:$0016,y
	sta	a:m7_patch_tiles+59
	lda	a:$0018,y
	sta	a:m7_patch_tiles+60
	lda	a:$001A,y
	sta	a:m7_patch_tiles+61
	lda	a:$001C,y
	sta	a:m7_patch_tiles+62
	lda	a:$001E,y
	sta	a:m7_patch_tiles+63
	rep	#$20
	.a16
	lda	#$0008
	sta	a:m7_patch_flags+6
	jmp	a:set_m7_patch_tile_attrs
