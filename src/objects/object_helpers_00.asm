; objects/object_helpers_00.asm -- Object helpers (bank $00)
; Bank $00, $00:FD8D-$00:FFBF. Included by main.asm in segment BANK00.
;
; Small routines shared by object handlers in all banks (queue_sound_6E_throttled,
; queue_vram_block, queue_vram_blocks, queue_vram_blocks_at_x...), and vector_length (multiplication, ends
; at $00:FFB1 inside the unused extended-header area), followed by $FF padding
; up to the header.

queue_sound_6E_throttled:
	lda	#SOUND_BOSS_EXPLOSIONS
	bra	queue_sound_throttled

queue_sound_41_throttled:
	lda	#SOUND_BIG_EXPLOSION
	bra	queue_sound_throttled

queue_sound_30_throttled:
	lda	#$0030

; Queues sound A (queue_sound) only when the countdown sound_throttle_timer has run
; out, then restarts it at 12-19 frames: for repeated sounds (queue_sound_6E_throttled,
; queue_sound_41_throttled, queue_sound_30_throttled are this with sounds $6E, $41, $30).
queue_sound_throttled:
	ldy	a:sound_throttle_timer
	bpl	@count_down
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:sound_throttle_timer
	pla
	jsl	f:queue_sound
@count_down:
	dec	a:sound_throttle_timer
	rtl

update_song_change:
	lda	a:song_change_state
	bne	@dispatch
	ldy	a:song_change_mode
	beq	song_change_return
@dispatch:
	asl	a
	tax
	lda	f:tbl_song_change_states,x
	sta	zp_00
	jmp	(zp_00)
tbl_song_change_states:
	.addr	song_change_state_00
	.addr	song_change_state_01
	.addr	song_change_state_02
	.addr	song_change_state_03
song_change_return:
	rtl

song_change_state_00:
	cpy	#$0002
	beq	song_change_stop_music
	lda	a:data_05AB58,y
	sta	a:song_change_mode
	inc	a:song_change_state
	lda	#SOUND_CMD_FADE_OUT
	jml	f:queue_sound

song_change_state_01:
	dec	a:song_change_mode
	bpl	song_change_return
; Delay over (or song_change_mode 2): state 2, queue SOUND_CMD_STOP.
song_change_stop_music:
	lda	#$0002
	sta	a:song_change_state
	stz	a:song_change_mode
	lda	#SOUND_CMD_STOP
	jml	f:queue_sound

song_change_state_02:
	ldx	a:song_change_set
	inc	a:song_change_state
	stz	a:song_change_set
	lda	#$0040
	sta	a:song_change_wait
	jml	f:request_song_set

song_change_state_03:
	lda	a:song_change_wait
	bmi	@wait_driver
	dec	a:song_change_wait
	bpl	@return
@wait_driver:
	lda	apu_pending_cmd
	cmp	#$00FF
	beq	@return
	stz	a:song_change_state
@return:
	rtl

; Never executed in the CDL traces (found by the unreferenced-routine heuristic).
; DB is assumed to be $05, the game's usual data bank (hint).
; (no caller found; decoded because it follows the end of a routine)
queue_vram_block_at_map_position:
	; (not executed in the CDL traces)
	sta	zp_00
	phx
	ldx	zp_04
	lda	zp_08
	lsr	a
	lsr	a
	lsr	a
	and	#$001C
	sta	zp_08
	lda	a:bg_scroll_state_addrs,x
	tay
	lda	a:$0000,y
	lsr	a
	lsr	a
	lsr	a
	and	#$003C
	clc
	adc	zp_08
	pha
	and	#$0020
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_06
	pla
	and	#$001C
	clc
	adc	zp_06
	clc
	adc	a:bg_tilemap_vram_addrs,x
	sta	zp_08
	lda	zp_02
	asl	a
	asl	a
	and	#$0380
	sta	zp_02
	lda	a:$0018,y
	asl	a
	asl	a
	and	#$0380
	clc
	adc	zp_02
	and	#$0380
	clc
	adc	zp_08
	plx

queue_vram_block:
	ldy	vram_block_queue_end
	cpy	#$0040
	bcs	queue_vram_block_return
; Entered here with Y = queue offset already loaded (the stage 1 boss).
queue_vram_block_at_y:
	sta	a:vram_block_queue,y
	clc
	adc	#$0020
	sta	a:vram_block_queue+2,y
	clc
	adc	#$0020
	sta	a:vram_block_queue+4,y
	clc
	adc	#$0020
	sta	a:vram_block_queue+6,y
	lda	zp_00
	sta	a:vram_block_src,y
	clc
	lda	vram_block_queue_end
	adc	#$0008
	sta	vram_block_queue_end
queue_vram_block_return:
	rtl

queue_vram_blocks:
	ldx	vram_block_queue_end
	cpx	#$0040
	bcs	queue_vram_block_return

queue_vram_blocks_at_x:
	sta	zp_00
	lda	zp_02
	sta	zp_04
	lda	zp_00
@loop:
	sta	a:vram_block_queue,x
	clc
	adc	#$0020
	sta	a:vram_block_queue+2,x
	clc
	adc	#$0020
	sta	a:vram_block_queue+4,x
	clc
	adc	#$0020
	sta	a:vram_block_queue+6,x
	lda	a:$0000,y
	sta	a:vram_block_src,x
	dec	zp_02
	bne	@same_row
	lda	zp_04
	sta	zp_02
	clc
	lda	zp_00
	adc	#$0080
	sta	zp_00
	bra	@next_block
@same_row:
	clc
	lda	a:vram_block_queue,x
	adc	#$0004
@next_block:
	sta	zp_06
	iny
	iny
	txa
	clc
	adc	#$0008
	tax
	stx	vram_block_queue_end
	lda	zp_06
	cpx	#$0040
	bcs	@return
	cpx	zp_08
	bcc	@loop
@return:
	rtl

; Per frame (side-view stages): shake_bg1_y / shake_bg2_y = shake_timer and
; half of it on two frames out of four (0 on the others), shake_timer
; decremented every 16 frames; or 1 pixel while shake_continuous is set.
update_shake_side_view:
	lda	stage_frame_bit1
	bne	@off_frame
	lda	a:shake_timer
	beq	@no_timer
	lda	stage_frame_counter
	and	#$000F
	bne	@set_shake
	dec	a:shake_timer
@set_shake:
	lda	a:shake_timer
	sta	shake_bg1_y
	lsr	a
	sta	shake_bg2_y
	rtl
@no_timer:
	lda	a:shake_continuous
	beq	@zero_shake
	lda	#$0001
	sta	shake_bg1_y
	rtl
@off_frame:
	stz	a:shake_continuous
@zero_shake:
	stz	shake_bg1_y
	stz	shake_bg2_y
	rtl

clear_hdma_line_buffer:
	lda	#$0000
	sta	f:scroll_hdma_tables
	phx
	phb
	lda	#$01FF
	ldx	#$A000	; [num]
	ldy	#$A001	; [num]
	mvn	#$7E, #$7E
	plb
	plx
	rtl

; A = zp_16 = sqrt(zp_08^2 + zp_0A^2) (8-bit inputs; bitwise square root).
; Uses zp_0C-zp_16.
vector_length:
	sep	#$20
	.a8
	lda	zp_08
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	sta	zp_0C
	sep	#$20
	.a8
	lda	zp_0A
	sta	a:WRMPYA
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	nop
	lda	a:RDMPYL
	clc
	adc	zp_0C
	sta	zp_10
	stz	zp_12
	lda	#$4000
	sta	zp_14
	stz	zp_16
	ldy	#$0008
@loop:
	lda	zp_12
	cmp	zp_16
	beq	@compare_low
	bcc	@bit_zero
	bra	@bit_one
@compare_low:
	lda	zp_10
	cmp	zp_14
	bcs	@bit_one
@bit_zero:
	clc
	rol	zp_16
	bra	@next
@bit_one:
	sec
	lda	zp_10
	sbc	zp_14
	sta	zp_10
	lda	zp_12
	sbc	zp_16
	sta	zp_12
	sec
	rol	zp_16
@next:
	asl	zp_10
	rol	zp_12
	asl	zp_10
	rol	zp_12
	dey
	bne	@loop
	lda	zp_16
	rtl
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
