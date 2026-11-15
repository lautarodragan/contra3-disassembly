; sound/sound_queue.asm -- Sound command queue
; Bank $00, $00:85F3-$00:86AB. Included by main.asm in segment BANK00.
;
; Sound and music commands are single bytes written to APUIO0; the sound
; CPU echoes them back on APUIO0 when it has taken them. queue_sound appends
; the command in A to the ring at sound_queue ($0100, indexes
; sound_queue_write / sound_queue_read), dropping a repeat of the last
; command queued in the same frame (sound_last_queued, cleared by the NMI
; frame handlers). send_queued_sound, once per frame, sends the next command
; once the previous one (apu_pending_cmd) has been echoed.
; send_sound_command_now sends one at once and waits for the echo (stage
; music start). reset_sound_queue restarts the queue with SOUND_CMD_STOP.
; check_sound_stream / sound_cmd_override belong to the streaming code in
; sound/sound_load.asm, which never runs in the traces.

; Once per frame (NMI): if the last command was echoed (or none is pending),
; sends sound_cmd_override or the next queued command to APUIO0. Nothing is
; sent while apu_pending_cmd is $FF (song set upload).
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

; A = command (8-bit). Sends it to APUIO0, waits for the echo and empties the
; queue.
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
; (No caller.) Sends SOUND_CMD_STOP, waits for the echo and empties the queue.
stop_sound_now:
	; (not executed in the CDL traces)
	php
	rep	#$20
	pha
	sep	#$20
	.a8
	lda	#SOUND_CMD_STOP
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
	pla
	plp
	rtl

; Empties the queue and queues SOUND_CMD_STOP as its first command.
reset_sound_queue:
	sep	#$20
	.a8
	lda	#SOUND_CMD_STOP
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
; (No caller.) Checks the status word of stream 1 at $1F2E: when the stream
; has finished (bit 15 clear), its id is sent through sound_cmd_override.
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

; A = sound command (low byte). Appends it to the queue unless it repeats
; sound_last_queued; on overflow the oldest entry is dropped. Keeps all
; registers and flags.
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
