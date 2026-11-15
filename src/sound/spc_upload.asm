; sound/spc_upload.asm -- Sound CPU upload
; Bank $00, $00:9324-$00:949B. Included by main.asm in segment BANK00.
;
; load_spc_list loads a type-2 data list (see engine/gfx_loader.asm) into
; the sound CPU's RAM with the IPL ROM transfer protocol on APUIO0-3: for each
; block, spc_start_block sends its address (APUIO2/3) with APUIO1 = 1 and a
; new counter; each byte goes on APUIO1 with the counter on APUIO0, waiting
; for the echo (wait_apuio0_echo). Blocks are raw (upload_spc_raw_block) or
; compressed (upload_spc_compressed_block, through the decompressor). At the
; end of the list the last block's address is sent with APUIO1 = 0: the
; sound CPU jumps there. copy_ring_to_wram (the WRAM list's consumer) is at
; the start of this file.

; WRAM loader: copies the ring's new bytes to [LDR_WRAM_DEST] (advanced).
copy_ring_to_wram:
	ldy	LDR_RING_DONE	; $135A (D=$1340)
	cpy	LDR_RING_POS	; $134C (D=$1340)
	beq	@done
	sep	#$20
@loop:
	.a8
	lda	[LDR_RING],y	; $1343 (D=$1340)
	sta	[LDR_WRAM_DEST]	; $1360 (D=$1340)
	ldx	LDR_WRAM_DEST	; $1360 (D=$1340)
	inx
	stx	LDR_WRAM_DEST	; $1360 (D=$1340)
	iny
	cpy	LDR_RING_POS	; $134C (D=$1340)
	bne	@loop
	rep	#$20
	.a16
	lda	LDR_RING_POS	; $134C (D=$1340)
	sta	LDR_RING_DONE	; $135A (D=$1340)
@done:
	rtl

; X = list (at its flags byte); unless deferred (never), waits for the IPL
; ROM ($BBAA), then uploads every block.
load_spc_list:
	php
	phd
	ldy	#LOADER_SPC
	lda	#$2C00
	jsr	a:init_loader_context
	and	#$0001
	sta	LDR_FLAGS	; $1F16 (D=$1F00)
	beq	@start
	; (not executed in the CDL traces)
	brl	loader_return
@start:
	jsl	f:spc_ipl_handshake
load_spc_list_entries:
	rep	#$20
	ldx	LDR_LIST	; $1F18 (D=$1F00)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF	; [num]
	bne	@not_end
	brl	finish_loader_list
@not_end:
	cmp	#$FFFE	; [num]
	bne	@compressed
	jsl	f:upload_spc_raw_block
	bra	load_spc_list_entries
@compressed:
	jsl	f:upload_spc_compressed_block
	bra	load_spc_list_entries

; Waits for the IPL ROM's $BBAA, starts a transfer ($CC) and sets the
; counter.
spc_ipl_handshake:
	rep	#$20
	lda	#$BBAA	; [num]
	stz	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
@wait_ready:
	cmp	a:APUIO0
	bne	@wait_ready
	sep	#$20
	.a8
	lda	#$01
	sta	a:APUIO1
	lda	#$CC
	sta	a:APUIO0
	jsr	a:wait_apuio0_echo
	lda	#$00
	sta	a:APUIO0
	jsr	a:wait_apuio0_echo
	rep	#$20
	.a16
	lda	#$0001
	sta	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	rtl

; A (8-bit) = value written to APUIO0: waits until the sound CPU echoes it.
wait_apuio0_echo:
	.a8
	cmp	a:APUIO0
	bne	wait_apuio0_echo
	rts

; Starts a new block at SPC address LDR_SPC_DEST.
spc_start_block:
	.a16
	rep	#$20
	rep	#$10
	lda	LDR_SPC_DEST	; $1F22 (D=$1F00)
	sta	a:APUIO2
	sep	#$20
	.a8
	lda	#$01
	sta	a:APUIO1
	lda	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	inc	a
	sta	a:APUIO0
	jsr	a:wait_apuio0_echo
	stz	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	rtl

; Sends the ring's new bytes; after a stream's last chunk, ends the upload
; if the list ends ($FFFF).
upload_ring_to_spc:
	rep	#$20
	ldy	LDR_RING_DONE	; $1F1A (D=$1F00)
	cpy	LDR_RING_POS	; $1F0C (D=$1F00)
	beq	@chunk_done
	sep	#$20
@loop:
	.a8
	lda	[LDR_RING],y	; $1F03 (D=$1F00)
	iny
	sta	a:APUIO1
	xba
	lda	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	inc	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	sta	a:APUIO0
	sep	#$20
	.a8
	jsr	a:wait_apuio0_echo
	cpy	LDR_RING_POS	; $1F0C (D=$1F00)
	bne	@loop
@chunk_done:
	lda	LDR_ACTIVE	; $1F10 (D=$1F00)
	beq	spc_check_list_end
	rep	#$20
	.a16
	lda	LDR_RING_POS	; $1F0C (D=$1F00)
	sta	LDR_RING_DONE	; $1F1A (D=$1F00)
	rtl
spc_check_list_end:
	.a8
	rep	#$20
	.a16
	ldx	LDR_LIST	; $1F18 (D=$1F00)
	lda	f:TABLES_05_BASE,x
	cmp	#$FFFF	; [num]
	bne	@more
	brl	@end
@more:
	rep	#$20
	rtl
@end:
	rep	#$20
	lda	LDR_SPC_DEST	; $1F22 (D=$1F00)
	sta	a:APUIO2
	sep	#$20
	.a8
	inc	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	lda	#$00
	sta	a:APUIO1
	lda	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	sta	a:APUIO0
	jsr	a:wait_apuio0_echo
	stz	a:APUIO0
	rep	#$20
	.a16
	rtl

upload_spc_raw_block:
	rep	#$20
	stz	LDR_ACTIVE	; $1F10 (D=$1F00)
	stz	LDR_RING_LIMIT	; $1F1C (D=$1F00)
	ldx	LDR_LIST	; $1F18 (D=$1F00)
	lda	f:TABLES_05_BASE+2,x
	sta	LDR_SPC_DEST	; $1F22 (D=$1F00)
	lda	f:TABLES_05_BASE+4,x
	sta	LDR_SRC	; $1F00 (D=$1F00)
	sep	#$20
	.a8
	lda	f:TABLES_05_BASE+6,x
	sta	LDR_SRC+2	; $1F02 (D=$1F00)
	rep	#$20
	.a16
	lda	f:TABLES_05_BASE+7,x
	sta	LDR_SRC_POS	; $1F06 (D=$1F00)
	txa
	clc
	adc	#$0009
	sta	LDR_LIST	; $1F18 (D=$1F00)
	jsl	f:spc_start_block
	ldy	#$0000
	sep	#$20
@loop:
	.a8
	lda	[LDR_SRC],y	; $1F00 (D=$1F00)
	iny
	sta	a:APUIO1
	xba
	lda	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	inc	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	sta	a:APUIO0
	sep	#$20
	.a8
	jsr	a:wait_apuio0_echo
	cpy	LDR_SRC_POS	; $1F06 (D=$1F00)
	bne	@loop
	brl	spc_check_list_end

upload_spc_compressed_block:
	.a16
	rep	#$20
	stz	LDR_ACTIVE	; $1F10 (D=$1F00)
	stz	LDR_RING_LIMIT	; $1F1C (D=$1F00)
	ldx	LDR_LIST	; $1F18 (D=$1F00)
	lda	f:TABLES_05_BASE,x
	sta	LDR_SPC_DEST	; $1F22 (D=$1F00)
	inx
	inx
	stx	LDR_LIST	; $1F18 (D=$1F00)
	jsl	f:spc_start_block
@loop:
	jsl	f:decompress_ring
	jsl	f:upload_ring_to_spc
	ldx	LDR_ACTIVE	; $1F10 (D=$1F00)
	bne	@loop
	rtl
