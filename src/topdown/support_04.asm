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

; Cycles colours $38-$3F of the palette buffer ($7E:2270), wram_15B6
; steps per frame (high byte) or frames per step (low byte), unless wram_15BE.
animate_stage5_boss_palettes:
	jmp	a:loc_04DA68

; Counts wram_1584 from 0 to $5F, wrapping.
step_palette_anim_timer:
	inc	a:wram_1584
	lda	a:wram_1584
	cmp	#$0060
	bcc	loc_04DA35
	stz	a:wram_1584
loc_04DA35:
	rtl

; Starts the stage 2 palette tasks at timer 0 and $20.
start_stage2_palette_tasks:
	lda	a:wram_1584
	bne	loc_04DA42
	ldy	#$F576
	jml	f:start_palette_task
loc_04DA42:
	cmp	#$0020
	bne	loc_04DA4E
	ldy	#$F57C
	jml	f:start_palette_task
loc_04DA4E:
	rtl

; Starts the stage 5 palette tasks at timer 0 and $20.
start_stage5_palette_tasks:
	lda	a:wram_1584
	bne	loc_04DA5B
	ldy	#$F582
	jml	f:start_palette_task
loc_04DA5B:
	cmp	#$0020
	bne	loc_04DA67
	ldy	#$F588
	jml	f:start_palette_task
loc_04DA67:
	rtl
loc_04DA68:
	lda	a:wram_15BE
	bne	loc_04DA99
	lda	a:wram_15B6
	beq	loc_04DA99
	bmi	loc_04DA9A
	cmp	#$0100
	bcs	loc_04DA8A
	dec	a:wram_15B8
	bmi	loc_04DA80
	bne	loc_04DA99
loc_04DA80:
	and	#$00FF
	sta	a:wram_15B8
	jsr	a:rotate_palette_colors_up
	rtl
loc_04DA8A:
	xba
	and	#$00FF
	sta	a:wram_15B8
loc_04DA91:
	jsr	a:rotate_palette_colors_up
	dec	a:wram_15B8
	bne	loc_04DA91
loc_04DA99:
	rtl
loc_04DA9A:
	; (not executed in the CDL traces)
	eor	#$FFFF
	inc	a
	cmp	#$0100
	bcs	loc_04DAB4
	dec	a:wram_15B8
	bmi	loc_04DAAA
	bne	loc_04DAC3
loc_04DAAA:
	and	#$00FF
	sta	a:wram_15B8
	jsr	a:rotate_palette_colors_down
	rtl
loc_04DAB4:
	xba
	and	#$00FF
	sta	a:wram_15B8
loc_04DABB:
	jsr	a:rotate_palette_colors_down
	dec	a:wram_15B8
	bne	loc_04DABB
loc_04DAC3:
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
loc_04DAD3:
	ldy	a:$0000,x
	sta	a:$0000,x
	tya
	inx
	inx
	cpx	#$2280
	bcc	loc_04DAD3
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
loc_04DAF2:
	ldy	a:$0000,x
	sta	a:$0000,x
	tya
	dex
	dex
	cpx	#$2270
	bcs	loc_04DAF2
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
	lda	#$9000
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
loc_04DB31:
	.a16
	jsl	f:expand_m7_block_row
	lda	zp_08
	clc
	adc	#$0080
	sta	zp_08
	dec	zp_12
	bne	loc_04DB31
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
	bne	loc_04DB31
	lda	#$0008
	sta	zp_16
	lda	zp_08
	clc
	adc	#$0380
	sta	zp_08
	dec	zp_14
	bne	loc_04DB31
	sep	#$20
	.a8
	lda	#$05
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
	lda	#$05
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

sub_04DC6C:
	.a16
	rtl

; Translates the 4 tile rows at $7E:3400 into the tile attribute map
; ($7E:4000, one byte per tile, read by the collision code) with the map's table.
build_tile_attr_rows:
	ldx	a:topdown_map
	jmp	(.loword(tbl_tile_attr_builders),x)
tbl_tile_attr_builders:
	.addr	build_tile_attr_rows_stage2
	.addr	sub_04DC6C
	.addr	build_tile_attr_rows_stage5
	.addr	build_tile_attr_rows_stage5_boss

build_tile_attr_rows_stage2:
	ldy	#$0000
loc_04DC7E:
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
	bcc	loc_04DC7E
	rtl

build_tile_attr_rows_stage5:
	ldy	#$0000
loc_04DC9B:
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
	bcc	loc_04DC9B
	rtl

build_tile_attr_rows_stage5_boss:
	ldy	#$0000
loc_04DCB8:
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
	bcc	loc_04DCB8
	rtl

; Queues a 4x4-tile block (Y) at VRAM address A in the first free patch
; slot; carry set when all four are taken.
queue_m7_block_patch:
	ldx	a:wram_1800
	beq	set_m7_block_patch_0
	ldx	a:wram_1802
	bne	loc_04DCDF
	brl	set_m7_block_patch_1
loc_04DCDF:
	ldx	a:wram_1804
	bne	loc_04DCE7
	brl	set_m7_block_patch_2
loc_04DCE7:
	ldx	a:wram_1806
	bne	loc_04DCEF
	brl	set_m7_block_patch_3
loc_04DCEF:
	sec
	rtl

; Fills patch slot 0: VRAM row addresses from A, tiles of block Y.
set_m7_block_patch_0:
	rep	#$30
	sta	zp_FE
	sta	a:wram_1808
	clc
	adc	#$0080
	sta	a:wram_180A
	clc
	adc	#$0080
	sta	a:wram_180C
	clc
	adc	#$0080
	sta	a:wram_180E
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
	sta	a:wram_1828
	lda	a:$0002,y
	sta	a:wram_1829
	lda	a:$0004,y
	sta	a:wram_182A
	lda	a:$0006,y
	sta	a:wram_182B
	lda	a:$0008,y
	sta	a:wram_182C
	lda	a:$000A,y
	sta	a:wram_182D
	lda	a:$000C,y
	sta	a:wram_182E
	lda	a:$000E,y
	sta	a:wram_182F
	lda	a:$0010,y
	sta	a:wram_1830
	lda	a:$0012,y
	sta	a:wram_1831
	lda	a:$0014,y
	sta	a:wram_1832
	lda	a:$0016,y
	sta	a:wram_1833
	lda	a:$0018,y
	sta	a:wram_1834
	lda	a:$001A,y
	sta	a:wram_1835
	lda	a:$001C,y
	sta	a:wram_1836
	lda	a:$001E,y
	sta	a:wram_1837
	rep	#$20
	.a16
	lda	#$0002
	sta	a:wram_1800
loc_04DD8A:
	lda	a:wram_15A8
	beq	loc_04DD99
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl
loc_04DD99:
	lda	stage_number
	cmp	#$0002
	beq	loc_04DDA3
	brl	loc_04DEF5
loc_04DDA3:
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
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl
loc_04DEF5:
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
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	clc
	rtl

set_m7_block_patch_1:
	rep	#$30
	sta	zp_FE
	sta	a:wram_1810
	clc
	adc	#$0080
	sta	a:wram_1812
	clc
	adc	#$0080
	sta	a:wram_1814
	clc
	adc	#$0080
	sta	a:wram_1816
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
	sta	a:wram_1838
	lda	a:$0002,y
	sta	a:wram_1839
	lda	a:$0004,y
	sta	a:wram_183A
	lda	a:$0006,y
	sta	a:wram_183B
	lda	a:$0008,y
	sta	a:wram_183C
	lda	a:$000A,y
	sta	a:wram_183D
	lda	a:$000C,y
	sta	a:wram_183E
	lda	a:$000E,y
	sta	a:wram_183F
	lda	a:$0010,y
	sta	a:wram_1840
	lda	a:$0012,y
	sta	a:wram_1841
	lda	a:$0014,y
	sta	a:wram_1842
	lda	a:$0016,y
	sta	a:wram_1843
	lda	a:$0018,y
	sta	a:wram_1844
	lda	a:$001A,y
	sta	a:wram_1845
	lda	a:$001C,y
	sta	a:wram_1846
	lda	a:$001E,y
	sta	a:wram_1847
	rep	#$20
	.a16
	lda	#$0004
	sta	a:wram_1802
	jmp	a:loc_04DD8A

set_m7_block_patch_2:
	rep	#$30
	sta	zp_FE
	sta	a:wram_1818
	clc
	adc	#$0080
	sta	a:wram_181A
	clc
	adc	#$0080
	sta	a:wram_181C
	clc
	adc	#$0080
	sta	a:wram_181E
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
	sta	a:wram_1848
	lda	a:$0002,y
	sta	a:wram_1849
	lda	a:$0004,y
	sta	a:wram_184A
	lda	a:$0006,y
	sta	a:wram_184B
	lda	a:$0008,y
	sta	a:wram_184C
	lda	a:$000A,y
	sta	a:wram_184D
	lda	a:$000C,y
	sta	a:wram_184E
	lda	a:$000E,y
	sta	a:wram_184F
	lda	a:$0010,y
	sta	a:wram_1850
	lda	a:$0012,y
	sta	a:wram_1851
	lda	a:$0014,y
	sta	a:wram_1852
	lda	a:$0016,y
	sta	a:wram_1853
	lda	a:$0018,y
	sta	a:wram_1854
	lda	a:$001A,y
	sta	a:wram_1855
	lda	a:$001C,y
	sta	a:wram_1856
	lda	a:$001E,y
	sta	a:wram_1857
	rep	#$20
	.a16
	lda	#$0006
	sta	a:wram_1804
	jmp	a:loc_04DD8A
set_m7_block_patch_3:
	rep	#$30
	sta	zp_FE
	sta	a:wram_1820
	clc
	adc	#$0080
	sta	a:wram_1822
	clc
	adc	#$0080
	sta	a:wram_1824
	clc
	adc	#$0080
	sta	a:wram_1826
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
	sta	a:wram_1858
	lda	a:$0002,y
	sta	a:wram_1859
	lda	a:$0004,y
	sta	a:wram_185A
	lda	a:$0006,y
	sta	a:wram_185B
	lda	a:$0008,y
	sta	a:wram_185C
	lda	a:$000A,y
	sta	a:wram_185D
	lda	a:$000C,y
	sta	a:wram_185E
	lda	a:$000E,y
	sta	a:wram_185F
	lda	a:$0010,y
	sta	a:wram_1860
	lda	a:$0012,y
	sta	a:wram_1861
	lda	a:$0014,y
	sta	a:wram_1862
	lda	a:$0016,y
	sta	a:wram_1863
	lda	a:$0018,y
	sta	a:wram_1864
	lda	a:$001A,y
	sta	a:wram_1865
	lda	a:$001C,y
	sta	a:wram_1866
	lda	a:$001E,y
	sta	a:wram_1867
	rep	#$20
	.a16
	lda	#$0008
	sta	a:wram_1806
	jmp	a:loc_04DD8A
