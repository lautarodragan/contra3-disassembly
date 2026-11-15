; engine/gfx_loader.asm -- Loader for graphics/data lists
; Bank $00, $00:90A8-$00:9323. Included by main.asm in segment BANK00.
;
; load_data_list loads a "data list" (X = its address in bank $05): byte 0
; the type, byte 1 flags, then entries until $FFFF. Every entry names a
; stream compressed in the format of engine/decompress.asm; each type has its
; own context (LOADER_VRAM, LOADER_WRAM, LOADER_SPC: the D register points at
; it, fields LDR_*) and 1 KiB ring buffer in $7E for the decompressor output:
;
;   0  VRAM (load_vram_list): entries {VRAM word address, stream (long)}
;   1  WRAM (load_wram_list): entries {destination (long), stream (long)}
;   2  sound CPU (load_spc_list, sound/spc_upload.asm): {SPC address,
;      stream}, or $FFFE + {SPC address, raw block (long), size}
;   3+ VRAM, one byte of each word (load_vram_byte_list): flags bit 0 set,
;      low bytes (VMAIN 0); clear, high bytes; used for Mode 7 data
;
; With flags bit 0 clear (types 0-1), a list is loaded at once with the
; display off (disable_display_and_nmi ... enable_nmi). With bit 0 set it is
; deferred: LDR_PENDING is set and the list is loaded a chunk per frame by
; run_pending_loads (decompress_chunk: $80 bytes) while the game runs, the
; VRAM chunks being DMAd in the next NMI by dma_vram_loader_chunk. The same
; entry point (load_data_list) serves both.

; X = data list in bank $05; dispatches on its type byte (see above).
load_data_list:
	rep	#$20
	lda	f:TABLES_05_BASE,x
	inx
	and	#$00FF
	beq	load_vram_list
	cmp	#$0001
	bne	@not_wram
	brl	load_wram_list
@not_wram:
	cmp	#$0002
	bne	@not_spc
	brl	load_spc_list
@not_spc:
	brl	load_vram_byte_list

; Once per frame: one step of the deferred VRAM list and of the deferred
; WRAM list.
run_pending_loads:
	jsl	f:step_vram_loader
	jmp	a:step_wram_loader
load_vram_list:
	php
	phd
	ldy	#LOADER_VRAM
	lda	#$2400
	jsr	a:init_loader_context
	sep	#$20
	.a8
	and	#$01
	bne	defer_vram_list
@loop:
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	beq	finish_list_enable_nmi
	jsl	f:load_vram_stream
	bra	@loop
finish_list_enable_nmi:
	jsl	f:enable_nmi
finish_loader_list:
	stz	LDR_FLAGS	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	stz	LDR_PENDING	; $1312 (D=$1300) / $1352 (D=$1340) / $1F12 (D=$1F00)
	stz	LDR_ACTIVE	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	stz	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
loader_return:
	pld
	plp
	rtl
defer_vram_list:
	.a8
	rep	#$20
	.a16
	inc	LDR_PENDING	; $1312 (D=$1300)
	bra	step_vram_loader_start

; Deferred VRAM list: decompresses the next $80-byte chunk (starting the
; next stream when the last one ended) and sets LDR_DMA_READY for the NMI.
; Waits while the previous chunk has not been DMAd yet.
step_vram_loader:
	php
	phd
	rep	#$20
	ldy	#LOADER_VRAM
	phy
	pld
	lda	LDR_DMA_READY	; $1326 (D=$1300)
	bne	loader_return
step_vram_loader_start:
	lda	LDR_PENDING	; $1312 (D=$1300)
	beq	loader_return
	lda	LDR_ACTIVE	; $1310 (D=$1300)
	bne	@decompress
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	beq	finish_loader_list
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	inx
	inx
	stx	LDR_LIST	; $1318 (D=$1300)
	stz	LDR_RING_LIMIT	; $131C (D=$1300)
@decompress:
	stz	LDR_DMA_READY	; $1326 (D=$1300)
	jsl	f:decompress_chunk
	inc	LDR_DMA_READY	; $1326 (D=$1300)
	bra	loader_return

; NMI: if LDR_DMA_READY, DMAs the chunk waiting in the VRAM ring.
dma_vram_loader_chunk:
	php
	phd
	rep	#$20
	rep	#$10
	ldy	#LOADER_VRAM
	phy
	pld
	lda	LDR_DMA_READY	; $1326 (D=$1300)
	beq	loader_return
	stz	LDR_DMA_READY	; $1326 (D=$1300)
	jsl	f:dma_ring_to_vram
	brl	loader_return

; Immediate: decompresses one VRAM stream ring by ring and DMAs each.
load_vram_stream:
	rep	#$20
	stz	LDR_ACTIVE	; $1310 (D=$1300)
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	inx
	inx
	stx	LDR_LIST	; $1318 (D=$1300)
@loop:
	jsl	f:decompress_ring
	jsl	f:dma_ring_to_vram
	ldx	LDR_ACTIVE	; $1310 (D=$1300)
	bne	@loop
	rtl

; DMAs the ring's new bytes (LDR_RING_DONE to LDR_RING_POS) to VRAM at
; LDR_VRAM_DEST (advanced).
dma_ring_to_vram:
	php
	rep	#$20
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	ldx	#$01
	stx	a:DMAP0
	lda	LDR_VRAM_DEST	; $1322 (D=$1300)
	sta	a:VMADDL
	lda	LDR_RING_POS	; $130C (D=$1300)
	sec
	sbc	LDR_RING_DONE	; $131A (D=$1300)
	beq	dma_ring_done
	lsr	a
	clc
	adc	LDR_VRAM_DEST	; $1322 (D=$1300)
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	ldx	#$18
	stx	a:BBAD0
dma_ring_chunk:
	lda	LDR_RING	; $1303 (D=$1300)
	clc
	adc	LDR_RING_DONE	; $131A (D=$1300)
	sta	a:A1T0L
	ldx	LDR_RING+2	; $1305 (D=$1300)
	stx	a:A1B0
	lda	LDR_RING_POS	; $130C (D=$1300)
	sec
	sbc	LDR_RING_DONE	; $131A (D=$1300)
	sta	a:DAS0L
	lda	LDR_RING_POS	; $130C (D=$1300)
	sta	LDR_RING_DONE	; $131A (D=$1300)
	ldx	#$01
	stx	a:MDMAEN
dma_ring_done:
	plp
	.i16
	rtl
; Types 3 and up. Note: after the first low-byte stream (flags bit 0 set) it
; continues with the high-byte loop.
load_vram_byte_list:
	php
	phd
	rep	#$20
	rep	#$10
	ldy	#LOADER_VRAM
	lda	#$2400
	jsr	a:init_loader_context
	sep	#$20
	.a8
	and	#$01
	bne	@loop_low
@loop_high:
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	bne	@next_high
	brl	finish_list_enable_nmi
@next_high:
	jsl	f:load_vram_stream_high
	bra	@loop_high
@loop_low:
	.a8
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	bne	@next_low
	; (not executed in the CDL traces)
	brl	finish_list_enable_nmi
@next_low:
	jsl	f:load_vram_stream_low
	bra	@loop_high

load_vram_stream_high:
	rep	#$20
	stz	LDR_ACTIVE	; $1310 (D=$1300)
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	inx
	inx
	stx	LDR_LIST	; $1318 (D=$1300)
@loop:
	jsl	f:decompress_ring
	jsl	f:dma_ring_to_vram_high
	ldx	LDR_ACTIVE	; $1310 (D=$1300)
	bne	@loop
	rtl

load_vram_stream_low:
	rep	#$20
	stz	LDR_ACTIVE	; $1310 (D=$1300)
	ldx	LDR_LIST	; $1318 (D=$1300)
	lda	f:TABLES_05_BASE,x
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	inx
	inx
	stx	LDR_LIST	; $1318 (D=$1300)
@loop:
	jsl	f:decompress_ring
	jsl	f:dma_ring_to_vram_low
	ldx	LDR_ACTIVE	; $1310 (D=$1300)
	bne	@loop
	rtl

dma_ring_to_vram_low:
	php
	rep	#$20
	sep	#$10
	.i8
	ldy	#$18
	ldx	#$00
	bra	dma_ring_to_vram_byte

dma_ring_to_vram_high:
	.i16
	php
	rep	#$20
	sep	#$10
	.i8
	ldy	#$19
	ldx	#$80
dma_ring_to_vram_byte:
	stx	a:VMAIN
	ldx	#$00
	stx	a:DMAP0
	lda	LDR_VRAM_DEST	; $1322 (D=$1300)
	sta	a:VMADDL
	lda	LDR_RING_POS	; $130C (D=$1300)
	sec
	sbc	LDR_RING_DONE	; $131A (D=$1300)
	bne	@nonempty
	brl	dma_ring_done
@nonempty:
	clc
	adc	LDR_VRAM_DEST	; $1322 (D=$1300)
	sta	LDR_VRAM_DEST	; $1322 (D=$1300)
	sty	a:BBAD0
	jmp	a:dma_ring_chunk

; Y = context (D is set to it), A = ring buffer address in $7E, X = list
; (at its flags byte). Resets the context, stores the flags (LDR_FLAGS) and
; the list pointer; returns the flags in A.
init_loader_context:
	.i16
	phy
	pld
	stz	LDR_ACTIVE	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	stz	LDR_PENDING	; $1312 (D=$1300) / $1352 (D=$1340) / $1F12 (D=$1F00)
	stz	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	sta	LDR_RING	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	sep	#$20
	.a8
	lda	#$7E
	sta	LDR_RING+2	; $1305 (D=$1300) / $1345 (D=$1340) / $1F05 (D=$1F00)
	lda	f:TABLES_05_BASE,x
	sta	LDR_FLAGS	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	inx
	stx	LDR_LIST	; $1318 (D=$1300) / $1358 (D=$1340) / $1F18 (D=$1F00)
	lda	LDR_FLAGS	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	rep	#$20
	.a16
	rts
; WRAM list (type 1), immediate or deferred (step_wram_loader).
load_wram_list:
	php
	phd
	ldy	#LOADER_WRAM
	lda	#$2800
	jsr	a:init_loader_context
	sep	#$20
	.a8
	and	#$01
	bne	@deferred
@loop:
	rep	#$20
	.a16
	ldx	LDR_LIST	; $1358 (D=$1340)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	bne	@next
	brl	finish_loader_list
@next:
	jsl	f:load_wram_stream
	bra	@loop
@deferred:
	.a8
	rep	#$20
	.a16
	inc	LDR_PENDING	; $1352 (D=$1340)
	bra	step_wram_loader_start
; Deferred WRAM list: decompresses the next chunk and copies it to its
; destination.
step_wram_loader:
	php
	phd
	ldy	#LOADER_WRAM
	phy
	pld
step_wram_loader_start:
	lda	LDR_PENDING	; $1352 (D=$1340)
	bne	@active
	brl	loader_return
@active:
	lda	LDR_ACTIVE	; $1350 (D=$1340)
	bne	@decompress
	ldx	LDR_LIST	; $1358 (D=$1340)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF
	bne	@next_stream
	brl	finish_loader_list
@next_stream:
	sta	LDR_WRAM_DEST	; $1360 (D=$1340)
	inx
	inx
	sep	#$20
	.a8
	lda	f:TABLES_05_BASE,x
	sta	LDR_WRAM_DEST+2	; $1362 (D=$1340)
	inx
	stx	LDR_LIST	; $1358 (D=$1340)
	rep	#$20
	.a16
	stz	LDR_RING_LIMIT	; $135C (D=$1340)
@decompress:
	jsl	f:decompress_chunk
	jsl	f:copy_ring_to_wram
	brl	loader_return

load_wram_stream:
	rep	#$20
	stz	LDR_ACTIVE	; $1350 (D=$1340)
	stz	LDR_RING_LIMIT	; $135C (D=$1340)
	ldx	LDR_LIST	; $1358 (D=$1340)
	lda	f:TABLES_05_BASE,x
	sta	LDR_WRAM_DEST	; $1360 (D=$1340)
	inx
	inx
	sep	#$20
	.a8
	lda	f:TABLES_05_BASE,x
	sta	LDR_WRAM_DEST+2	; $1362 (D=$1340)
	inx
	stx	LDR_LIST	; $1358 (D=$1340)
	rep	#$20
@loop:
	.a16
	jsl	f:decompress_ring
	jsl	f:copy_ring_to_wram
	ldx	LDR_ACTIVE	; $1350 (D=$1340)
	bne	@loop
	rtl
