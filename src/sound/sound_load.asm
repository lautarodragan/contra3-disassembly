; sound/sound_load.asm -- Song set loading and sound streaming
; Bank $00, $00:9627-$00:9970. Included by main.asm in segment BANK00.
;
; Music and sound effects come in "song sets": data lists of type 2
; (engine/gfx_loader.asm) in bank $05, in the table song_lists. load_song_set
; (X = list) stops the sound (SOUND_CMD_STOP), makes the running driver enter
; its upload mode (SOUND_CMD_UPLOAD, start_song_set_upload), uploads the list
; and then lets the queue run again; apu_pending_cmd = $FF meanwhile.
; request_song_set does the same from the main loop instead of the NMI: it
; stores the list in pending_spc_list and service_song_set_request (main
; loop, engine/reset.asm) uploads it, while the NMI keeps running the game.
;
; unused_spc_stream_list .. unused_check_spc_busy never run in the traces
; (no caller): a second protocol through APUIO2/3 ($AABB/$A0B0 handshake,
; address, then bytes tagged with a 7-bit counter) to send data to the
; driver while it runs, and a request/status scheme in the LOADER_SPC context
; (LDR_SPC_STREAM_*).

; (no caller found; decoded because it follows the end of a routine)
unused_spc_stream_list:
	; (not executed in the CDL traces)
	.a16
	lda	f:$050000,x
	and	#$00FF
	beq	@no_stream
	brl	unused_request_stream
@no_stream:
	jsl	f:stop_sound_now
	lda	f:$050001,x
	and	#$00FF
	bne	@compressed_list
	brl	unused_stream_raw_list
@compressed_list:
	php
	phd
	lda	#LOADER_SPC
	pha
	pld
	lda	#$2C00
	sta	LDR_RING
	sep	#$20
	.a8
	lda	#$7E
	sta	LDR_RING+2
	rep	#$20
	.a16
	stz	LDR_PENDING
	lda	#$0001
	sta	LDR_FLAGS
	inx
	inx
	stx	LDR_LIST
@loop:
	ldx	LDR_LIST
	lda	f:$050000,x
	cmp	#$FFFF
	beq	@end
	jsr	a:unused_stream_compressed_block
	bra	@loop
@end:
	stz	LDR_FLAGS
	stz	LDR_PENDING
	stz	LDR_ACTIVE
	stz	LDR_RING_LIMIT
	pld
	plp
	rtl

unused_stream_compressed_block:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	LDR_SPC_STREAM_ON
	stz	LDR_ACTIVE
	stz	LDR_RING_LIMIT
	stz	LDR_SPC_COUNTER
	lda	#$AABB
	jsr	a:write_apuio2_wait
	lda	#$A0B0
	jsr	a:write_apuio2_wait
	ldx	LDR_LIST
	lda	f:$050000,x
	sta	LDR_SPC_DEST
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	LDR_SPC_DEST
	rep	#$20
	.a16
	jsr	a:write_apuio2_wait
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	LDR_SPC_DEST+1
	rep	#$20
	.a16
	jsr	a:write_apuio2_wait
	inx
	inx
	stx	LDR_LIST
@loop:
	jsl	f:decompress_ring
	jsr	a:unused_stream_ring
	ldx	LDR_ACTIVE
	bne	@loop
	lda	#$BBAA
	jsr	a:write_apuio2_wait
	rts

unused_stream_ring:
	; (not executed in the CDL traces)
	ldy	LDR_RING_DONE
	cpy	LDR_RING_POS
	beq	@done
@loop:
	sep	#$20
	.a8
	lda	LDR_SPC_COUNTER
	and	#$7F
	xba
	lda	[LDR_RING],y
	iny
	rep	#$20
@wait:
	.a16
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	@wait
	inc	LDR_SPC_COUNTER
	cpy	LDR_RING_POS
	bne	@loop
@done:
	lda	LDR_RING_POS
	sta	LDR_RING_DONE
	rts

write_apuio2_wait:
	; (not executed in the CDL traces)
	sta	a:APUIO2
@wait:
	cmp	a:APUIO2
	bne	@wait
	rts
unused_stream_raw_list:
	php
	phd
	rep	#$20
	inx
	inx
	stx	LDR_LIST
@loop:
	ldx	LDR_LIST
	lda	f:$050000,x
	cmp	#$FFFF
	beq	@end
	jsr	a:unused_stream_raw_block
	bra	@loop
@end:
	pld
	plp
	rtl

unused_stream_raw_block:
	; (not executed in the CDL traces)
	stz	LDR_SPC_COUNTER
	lda	#$AABB
	jsr	a:write_apuio2_wait
	lda	#$A0B0
	jsr	a:write_apuio2_wait
	ldx	LDR_LIST
	lda	f:$050000,x
	sta	LDR_SPC_DEST
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	LDR_SPC_DEST
	rep	#$20
	.a16
	jsr	a:write_apuio2_wait
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	LDR_SPC_DEST+1
	rep	#$20
	.a16
	jsr	a:write_apuio2_wait
	inx
	inx
	stx	LDR_LIST
	sep	#$20
	.a8
	lda	f:$050002,x
	sta	LDR_RING+2
	rep	#$20
	.a16
	lda	f:$050000,x
	dec	a
	dec	a
	sta	LDR_RING
	inx
	inx
	inx
	stx	LDR_LIST
	lda	[LDR_RING]
	sta	LDR_SRC_END
	inc	LDR_RING
	inc	LDR_RING
	jsr	a:unused_stream_raw_bytes
	lda	#$BBAA
	jsr	a:write_apuio2_wait
	rts

unused_stream_raw_bytes:
	; (not executed in the CDL traces)
	ldy	#$0000
@loop:
	sep	#$20
	.a8
	lda	LDR_SPC_COUNTER
	and	#$7F
	xba
	lda	[LDR_RING],y
	iny
	rep	#$20
	.a16
	sta	a:APUIO2
@wait:
	cmp	a:APUIO2
	bne	@wait
	inc	LDR_SPC_COUNTER
	cpy	LDR_SRC_END
	bcc	@loop
	rts
; D is 0 here as far as the code shows: the stz $16 below is probably meant
; for LOADER_SPC+LDR_FLAGS.
unused_request_stream:
	stx	a:pending_spc_list
	stz	a:LOADER_SPC+LDR_SPC_STREAM_ON
	lda	f:$050001,x
	and	#$00FF
	ora	#$C000
	sta	a:LOADER_SPC+LDR_SPC_STREAM_STATUS
	stz	$5A
	stz	$6A
	stz	$16
	rtl

; (no caller found; decoded because it follows the end of a routine)
unused_service_stream:
	; (not executed in the CDL traces)
	phd
	ldy	#LOADER_SPC
	phy
	pld
	lda	LDR_FLAGS
	beq	@check_request
	cmp	#$0004
	beq	@check_request
	brl	@exit
@check_request:
	ldx	LDR_SPC_PENDING_LIST
	bne	@start
	brl	@exit
@start:
	lda	#$0001
	sta	$2A
	sta	LDR_SPC_STREAM_ON
	ldx	LDR_SPC_PENDING_LIST
	stz	LDR_SPC_PENDING_LIST
	stz	$2A
	cpx	#$0000
	bne	@upload
	brl	@exit
@upload:
	jsl	f:load_spc_list
	lda	#$0001
	sta	LDR_PENDING
	lda	#$0002
	sta	LDR_FLAGS
	stz	LDR_ACTIVE
	stz	LDR_RING_LIMIT
	stz	LDR_SPC_COUNTER
	lda	#$AABB
	jsl	f:stream_write_apuio2
	lda	#$A0B0
	jsl	f:stream_write_apuio2
	ldx	LDR_LIST
	sep	#$20
	.a8
	lda	f:$050000,x
	sta	LDR_SPC_STREAM_ID
	inx
	rep	#$20
	.a16
	lda	f:$050000,x
	sta	LDR_SPC_DEST
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	LDR_SPC_DEST
	rep	#$20
	.a16
	jsl	f:stream_write_apuio2
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	LDR_SPC_DEST+1
	rep	#$20
	.a16
	jsl	f:stream_write_apuio2
	inx
	inx
	stx	LDR_LIST
@loop:
	jsl	f:decompress_chunk
	jsl	f:stream_ring_to_apuio2
	lda	LDR_SPC_STREAM_ON
	beq	@aborted
	ldx	LDR_ACTIVE
	bne	@loop
	lda	#$BBAA
	jsl	f:stream_write_apuio2
	lda	LDR_FLAGS
	cmp	#$0002
	bne	@aborted
	lda	LDR_SPC_STREAM_ID
	and	#$0001
	asl	a
	tax
	lda	LDR_SPC_STREAM_ID
	and	#$00FF
	sta	LDR_SPC_STREAM_STATUS,x
	stz	LDR_FLAGS
	stz	LDR_PENDING
	stz	LDR_ACTIVE
	stz	LDR_RING_LIMIT
@exit:
	pld
	rtl
@aborted:
	lda	#$BBAA
	jsl	f:stream_write_apuio2
	lda	LDR_SPC_STREAM_ID
	and	#$0001
	asl	a
	tax
	lda	LDR_SPC_STREAM_ID
	and	#$00FF
	ora	#$8000
	sta	LDR_SPC_STREAM_STATUS,x
	lda	#$0004
	sta	LDR_FLAGS
	rtl

stream_write_apuio2:
	; (not executed in the CDL traces)
	rep	#$20
	sta	LDR_SPC_PORT_WORD
@loop:
	lda	LDR_SPC_STREAM_ON
	beq	@done
	lda	LDR_SPC_PORT_WORD
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	@loop
@done:
	rtl

stream_ring_to_apuio2:
	; (not executed in the CDL traces)
	rep	#$20
	ldy	LDR_RING_DONE
	cpy	LDR_RING_POS
	beq	@done
@loop:
	sep	#$20
	.a8
	lda	LDR_SPC_COUNTER
	and	#$7F
	xba
	lda	[LDR_RING],y
	iny
	rep	#$20
	.a16
	sta	LDR_SPC_PORT_WORD
@wait:
	lda	LDR_SPC_STREAM_ON
	beq	@done
	lda	LDR_SPC_PORT_WORD
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	@wait
	inc	LDR_SPC_COUNTER
	cpy	LDR_RING_POS
	bne	@loop
@done:
	rep	#$20
	lda	LDR_RING_POS
	sta	LDR_RING_DONE
	rtl

; (no caller found; decoded because it follows the end of a routine)
unused_check_spc_busy:
	; (not executed in the CDL traces)
	rep	#$20
	lda	a:pending_spc_list
	bne	@done
	lda	a:LOADER_SPC+LDR_FLAGS
	beq	@done
	cmp	#$0004
	bne	@done
	lda	#$0000
@done:
	rtl

; X = song set list (bank $05). Uploads it now (in the NMI: the game waits).
load_song_set:
	rep	#$30
	lda	#$00FF
	sta	apu_pending_cmd
	jsl	f:upload_spc_list
	stz	apu_pending_cmd
	rtl

; X = song set list: empties the sound queue, stops the driver and uploads
; the list through load_spc_list_entries.
upload_spc_list:
	rep	#$20
	stz	sound_queue_read
	stz	sound_queue_write
	stz	sound_stream_check_index
	stz	sound_cmd_override
	lda	f:$050000,x
	inx
	php
	phd
	ldy	#LOADER_SPC
	lda	#$2C00
	jsr	a:init_loader_context
	rep	#$20
	and	#$0001
	sta	LDR_FLAGS	; $1F16 (D=$1F00)
	jsr	a:start_song_set_upload
	lda	#$0001
	sta	LDR_SPC_COUNTER	; $1F20 (D=$1F00)
	jmp	a:load_spc_list_entries

; Sends SOUND_CMD_STOP and SOUND_CMD_UPLOAD (waiting for each echo), then an
; IPL-style start of a transfer to $3000 ($CC kick) and the first counter.
start_song_set_upload:
	sep	#$20
	.a8
	lda	#SOUND_CMD_STOP
	sta	a:APUIO0
@wait_stop:
	cmp	a:APUIO0
	bne	@wait_stop
	lda	#$FF
@wait_upload:
	sta	a:APUIO0
	cmp	a:APUIO0
	bne	@wait_upload
	lda	#$00
	sta	a:APUIO2
	lda	#$30
	sta	a:APUIO3
	lda	#$01
	sta	a:APUIO1
	xba
	lda	#$CC
	rep	#$20
	.a16
	sta	a:APUIO0
	sep	#$20
@wait_kick:
	.a8
	cmp	a:APUIO0
	bne	@wait_kick
	lda	#$00
	sta	a:APUIO0
@wait_start:
	cmp	a:APUIO0
	bne	@wait_start
	rep	#$20
	.a16
	rts

; X = song set list: uploaded later by the main loop.
request_song_set:
	rep	#$20
	lda	#$00FF
	sta	apu_pending_cmd
	stx	a:pending_spc_list
	rtl

; Main loop: uploads pending_spc_list when requested (apu_pending_cmd = $FF).
service_song_set_request:
	rep	#$20
	lda	apu_pending_cmd
	cmp	#$00FF
	bne	@done
	ldx	a:pending_spc_list
	jsl	f:upload_spc_list
	stz	sound_queue_read
	stz	sound_queue_write
	stz	apu_pending_cmd
@done:
	rtl
