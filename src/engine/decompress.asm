; engine/decompress.asm -- Decompressor
; Bank $00, $00:949C-$00:9626. Included by main.asm in segment BANK00.
;
; An LZ77-style decompressor with a 1 KiB window: the output goes to the
; context's ring buffer (LDR_RING), which is also the window. It runs with D
; at a loader context (LDR_* fields) and can stop at any byte and resume
; later (LDR_STATE), so streams are decompressed in pieces: decompress_ring
; fills the whole ring (1024 bytes), decompress_chunk the next $80 bytes; the
; caller then consumes the bytes from LDR_RING_DONE to LDR_RING_POS. Both
; start a new stream when LDR_ACTIVE is 0 (taking its long address from the
; list at LDR_LIST, clearing the ring) and clear LDR_ACTIVE at its end.
;
; Stream format: a word, the stream length (including the word); then
; commands, n = (byte & $1F) + 2 unless noted:
;   $00-$7F  back-reference: copy (byte >> 2) + 2 bytes from ring position
;            (((byte & 3) << 8 | next byte) + $21) & $3FF
;   $80-$9F  (byte & $1F) literal bytes follow
;   $A0-$BF  n times: a zero, then a literal byte (zero-interleaved bytes)
;   $C0-$DF  n copies of the next byte
;   $E0-$FF  n zeros

; Resets the ring and decompresses up to $400 bytes.
decompress_ring:
	rep	#$20
	lda	#$0400
	sta	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	stz	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	stz	LDR_RING_DONE	; $131A (D=$1300) / $135A (D=$1340) / $1F1A (D=$1F00)
	bra	decompress_continue

; Decompresses up to the next $80 bytes (the limit wraps in the ring).
decompress_chunk:
	rep	#$20
	lda	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340)
	and	#$03FF
	sta	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340)
	sta	LDR_RING_DONE	; $131A (D=$1300) / $135A (D=$1340)
	clc
	adc	#$0080
	sta	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340)
decompress_continue:
	sep	#$20
	.a8
	phb
	lda	#$7E
	pha
	plb
	rep	#$30
	.a16
	lda	LDR_ACTIVE	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	bne	@dispatch
	inc	LDR_ACTIVE	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	ldx	LDR_LIST	; $1318 (D=$1300) / $1358 (D=$1340) / $1F18 (D=$1F00)
	lda	f:$050000,x
	sta	LDR_SRC	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	inx
	inx
	sep	#$20
	.a8
	lda	f:$050000,x
	sta	LDR_SRC+2	; $1302 (D=$1300) / $1342 (D=$1340) / $1F02 (D=$1F00)
	inx
	stx	LDR_LIST	; $1318 (D=$1300) / $1358 (D=$1340) / $1F18 (D=$1F00)
	ldy	#$0000
	stz	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	rep	#$20
	.a16
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	sta	LDR_SRC_END	; $1308 (D=$1300) / $1348 (D=$1340) / $1F08 (D=$1F00)
	iny
	iny
	sty	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	ldy	#$03FE
	lda	#$0000
@clear_window:
	sta	[LDR_RING],y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	dey
	dey
	bpl	@clear_window
	bra	@dispatch
@stream_end:
	.a8
	stz	LDR_ACTIVE	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
@exit:
	plb
	rep	#$20
	.a16
	rtl
@dispatch:
	sep	#$20
	.a8
	lda	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	beq	@next_command
	cmp	#$01
	bne	@not_state1
	brl	@backref_resume
@not_state1:
	cmp	#$02
	bne	@not_state2
	brl	@literal_resume
@not_state2:
	cmp	#$03
	bne	@not_state3
	brl	@rle_resume
@not_state3:
	cmp	#$04
	beq	@zi_loop
	cmp	#$05
	beq	@zi_literal
@next_command:
	ldy	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	cpy	LDR_SRC_END	; $1308 (D=$1300) / $1348 (D=$1340) / $1F08 (D=$1F00)
	bcs	@stream_end
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	iny
	sty	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	cmp	#$80
	bcs	@not_backref
	brl	@backref
@not_backref:
	cmp	#$A0
	bcc	@literal_run
	cmp	#$C0
	bcc	@zero_interleaved
	cmp	#$E0
	bcc	@rle_byte
	bcs	@rle_zero
@zero_interleaved:
	and	#$1F
	clc
	adc	#$02
	sta	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
@zi_loop:
	dec	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	bpl	@zi_zero
	brl	@command_done
@zi_zero:
	lda	#$05
	sta	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	lda	#$00
	ldy	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	sta	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	cpy	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	bcs	@exit
@zi_literal:
	lda	#$04
	sta	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	ldy	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	iny
	sty	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	ldy	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	sta	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	cpy	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	bcc	@zi_loop
	bra	@exit
@rle_byte:
	pha
	ldy	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	iny
	sty	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	bra	@rle_start
@rle_zero:
	pha
	lda	#$00
@rle_start:
	sta	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	lda	#$03
	sta	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	pla
	and	#$1F
	clc
	adc	#$02
	sta	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
@rle_resume:
	lda	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	ldy	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
@rle_loop:
	dec	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	bmi	@rle_done
	sta	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	cpy	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	bcc	@rle_loop
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340)
	brl	@exit
@rle_done:
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	brl	@command_done
@literal_run:
	and	#$1F
	sta	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	lda	#$02
	sta	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
@literal_resume:
	ldx	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
@literal_loop:
	dec	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	bmi	@literal_done
	txy
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	iny
	tyx
	ldy	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	sta	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	cpy	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	bcc	@literal_loop
	stx	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	brl	@exit
@backref:
	sta	LDR_COPY+1	; $130B (D=$1300) / $134B (D=$1340) / $1F0B (D=$1F00)
	lsr	a
	lsr	a
	clc
	adc	#$02
	sta	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	ldy	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	lda	[LDR_SRC],y	; $1300 (D=$1300) / $1340 (D=$1340) / $1F00 (D=$1F00)
	iny
	sty	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	sta	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	rep	#$20
	.a16
	lda	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	sec
	sbc	#$03DF
	and	#$03FF
	sta	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	sep	#$20
	.a8
	lda	#$01
	sta	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
@backref_resume:
	ldx	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
@backref_loop:
	dec	LDR_COUNT	; $130E (D=$1300) / $134E (D=$1340) / $1F0E (D=$1F00)
	bmi	@command_done
	txy
	lda	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	cpy	#$0400
	bcc	@backref_nowrap
	ldy	#$0000
@backref_nowrap:
	tyx
	ldy	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	sta	(LDR_RING),y	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	iny
	sty	LDR_RING_POS	; $130C (D=$1300) / $134C (D=$1340) / $1F0C (D=$1F00)
	cpy	LDR_RING_LIMIT	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	bcc	@backref_loop
	stx	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
	brl	@exit
@literal_done:
	stx	LDR_SRC_POS	; $1306 (D=$1300) / $1346 (D=$1340) / $1F06 (D=$1F00)
	bra	@command_done_keep
@command_done:
	stz	LDR_COPY	; $130A (D=$1300) / $134A (D=$1340) / $1F0A (D=$1F00)
@command_done_keep:
	stz	LDR_STATE	; $1314 (D=$1300) / $1354 (D=$1340) / $1F14 (D=$1F00)
	brl	@next_command
