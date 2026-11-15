; sound/sound_queue.asm -- Sound command queue
; Bank $00, $00:85F3-$00:86AB. Included by main.asm in segment BANK00.
;
; Commands for the sound CPU are queued in a ring at $0100 (queue_sound queues
; the command in A, skipping repeats; $56 write index, $54 read index) and
; sent one per frame to APUIO0 by send_queued_sound. reset_sound_queue resets the queue with
; command $84.

send_queued_sound:
	.a16
	sep	#$30
	.a8
	.i8
	lda	apu_pending_cmd
	beq	@ready
	cmp	#$FF
	beq	@check_stream
	cmp	a:APUIO0
	bne	@check_stream
	stz	apu_pending_cmd
@ready:
	lda	sound_cmd_override
	beq	@from_queue
	; (not executed in the CDL traces)
	stz	sound_cmd_override
	bra	@send
@from_queue:
	ldx	sound_queue_read
	cpx	sound_queue_write
	beq	@check_stream
	lda	a:$0100,x
	inx
	stx	sound_queue_read
@send:
	sta	apu_pending_cmd
	sta	a:APUIO0
@check_stream:
	rep	#$30
	.a16
	.i16
	lda	sound_stream_check_index
	bne	check_sound_stream_index
	rtl

send_sound_command_now:
	php
	sep	#$20
	.a8
	stz	apu_pending_cmd
	sta	a:APUIO0
@wait:
	cmp	a:APUIO0
	bne	@wait
	stz	sound_queue_read
	stz	sound_queue_write
	stz	sound_stream_check_index
	stz	sound_cmd_override
	rep	#$20
	.a16
	plp
	rtl

; (no caller found; decoded because it follows the end of a routine)
stop_sound_now:
	; (not executed in the CDL traces)
	php
	rep	#$20
	pha
	sep	#$20
	.a8
	lda	#$84
	stz	$52
	sta	a:APUIO0
@wait:
	cmp	a:APUIO0
	bne	@wait
	stz	$54
	stz	$56
	stz	$5A
	stz	$6A
	rep	#$20
	.a16
	pla
	plp
	rtl

reset_sound_queue:
	sep	#$20
	.a8
	lda	#$84
	sta	a:sound_queue
	stz	sound_queue_read
	lda	#$01
	sta	sound_queue_write
	stz	sound_stream_check_index
	stz	sound_cmd_override
	rep	#$20
	.a16
	rtl

; (no caller found; decoded because it follows the end of a routine)
check_sound_stream:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	sound_stream_check_index
check_sound_stream_index:
	ldy	sound_stream_check_index
	lda	a:$1F2D,y
	bit	#$8000
	beq	@stream_done
	bit	#$4000
	bne	@done
	stz	sound_stream_check_index
@done:
	rtl
@stream_done:
	and	#$00FF
	sta	sound_cmd_override
	stz	sound_stream_check_index
	rtl

queue_sound:
	phx
	phy
	php
	sep	#$30
	.a8
	.i8
	cmp	sound_last_queued
	beq	@done
	ldx	sound_queue_write
	sta	sound_last_queued
	sta	a:$0100,x
	inx
	stx	sound_queue_write
	cpx	sound_queue_read
	bne	@done
	; (not executed in the CDL traces)
	inc	sound_queue_read
@done:
	plp
	.a16
	.i16
	ply
	plx
	rtl
