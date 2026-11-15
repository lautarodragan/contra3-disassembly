; objects/object_helpers_00.asm -- Object helpers (bank $00)
; Bank $00, $00:FD8D-$00:FFBF. Included by main.asm in segment BANK00.
;
; Small routines shared by object handlers in all banks (queue_sound_6E_throttled,
; queue_vram_block, queue_vram_blocks, queue_vram_blocks_at_x...), and vector_length (multiplication, ends
; at $00:FFB1 inside the unused extended-header area), followed by $FF padding
; up to the header.

queue_sound_6E_throttled:
	lda	#$006E
	bra	queue_sound_throttled

queue_sound_41_throttled:
	lda	#$0041
	bra	queue_sound_throttled

queue_sound_30_throttled:
	lda	#$0030

; Queues sound A (queue_sound) only when the countdown wram_16B0 has run
; out, then restarts it at 12-19 frames: for repeated sounds (queue_sound_6E_throttled,
; queue_sound_41_throttled, queue_sound_30_throttled are this with sounds $6E, $41, $30).
queue_sound_throttled:
	ldy	a:wram_16B0
	bpl	loc_00FDB0
	pha
	lda	rng_lo
	and	#$0007
	adc	#$000C
	sta	a:wram_16B0
	pla
	jsl	f:queue_sound
loc_00FDB0:
	dec	a:wram_16B0
	rtl

update_song_change:
	lda	a:song_change_state
	bne	loc_00FDBE
	ldy	a:song_change_mode
	beq	loc_00FDD1
loc_00FDBE:
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
loc_00FDD1:
	rtl

song_change_state_00:
	cpy	#$0002
	beq	loc_00FDEC
	lda	a:data_05AB58,y
	sta	a:song_change_mode
	inc	a:song_change_state
	lda	#$0081
	jml	f:queue_sound

song_change_state_01:
	dec	a:song_change_mode
	bpl	loc_00FDD1
loc_00FDEC:
	lda	#$0002
	sta	a:song_change_state
	stz	a:song_change_mode
	lda	#$0084
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
	bmi	loc_00FE19
	dec	a:song_change_wait
	bpl	loc_00FE23
loc_00FE19:
	lda	apu_pending_cmd
	cmp	#$00FF
	beq	loc_00FE23
	stz	a:song_change_state
loc_00FE23:
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
	lda	a:data_05AB64,x
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
	adc	a:data_05AB68,x
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
	ldy	zp_B6
	cpy	#$0040
	bcs	loc_00FEA2
loc_00FE7D:
	sta	a:$1800,y
	clc
	adc	#$0020
	sta	a:$1802,y
	clc
	adc	#$0020
	sta	a:$1804,y
	clc
	adc	#$0020
	sta	a:$1806,y
	lda	zp_00
	sta	a:$1840,y
	clc
	lda	zp_B6
	adc	#$0008
	sta	zp_B6
loc_00FEA2:
	rtl

queue_vram_blocks:
	ldx	zp_B6
	cpx	#$0040
	bcs	loc_00FEA2

queue_vram_blocks_at_x:
	sta	zp_00
	lda	zp_02
	sta	zp_04
	lda	zp_00
loc_00FEB2:
	sta	a:$1800,x
	clc
	adc	#$0020
	sta	a:$1802,x
	clc
	adc	#$0020
	sta	a:$1804,x
	clc
	adc	#$0020
	sta	a:$1806,x
	lda	a:$0000,y
	sta	a:$1840,x
	dec	zp_02
	bne	loc_00FEE2
	lda	zp_04
	sta	zp_02
	clc
	lda	zp_00
	adc	#$0080
	sta	zp_00
	bra	loc_00FEE9
loc_00FEE2:
	clc
	lda	a:$1800,x
	adc	#$0004
loc_00FEE9:
	sta	zp_06
	iny
	iny
	txa
	clc
	adc	#$0008
	tax
	stx	zp_B6
	lda	zp_06
	cpx	#$0040
	bcs	@return
	cpx	zp_08
	bcc	loc_00FEB2
@return:
	rtl

; Per frame (side-view stages): shake_bg1_y / shake_bg2_y = shake_timer and
; half of it on two frames out of four (0 on the others), shake_timer
; decremented every 16 frames; or 1 pixel while shake_continuous is set.
update_shake_side_view:
	lda	stage_frame_bit1
	bne	loc_00FF28
	lda	a:shake_timer
	beq	loc_00FF1D
	lda	stage_frame_counter
	and	#$000F
	bne	loc_00FF14
	dec	a:shake_timer
loc_00FF14:
	lda	a:shake_timer
	sta	shake_bg1_y
	lsr	a
	sta	shake_bg2_y
	rtl
loc_00FF1D:
	lda	a:shake_continuous
	beq	loc_00FF2B
	lda	#$0001
	sta	shake_bg1_y
	rtl
loc_00FF28:
	stz	a:shake_continuous
loc_00FF2B:
	stz	shake_bg1_y
	stz	shake_bg2_y
	rtl

clear_hdma_line_buffer:
	lda	#$0000
	sta	f:wram_7EA000
	phx
	phb
	lda	#$01FF
	ldx	#$A000
	ldy	#$A001
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
loc_00FF7F:
	lda	zp_12
	cmp	zp_16
	beq	loc_00FF89
	bcc	loc_00FF8F
	bra	loc_00FF94
loc_00FF89:
	lda	zp_10
	cmp	zp_14
	bcs	loc_00FF94
loc_00FF8F:
	clc
	rol	zp_16
	bra	loc_00FFA4
loc_00FF94:
	sec
	lda	zp_10
	sbc	zp_14
	sta	zp_10
	lda	zp_12
	sbc	zp_16
	sta	zp_12
	sec
	rol	zp_16
loc_00FFA4:
	asl	zp_10
	rol	zp_12
	asl	zp_10
	rol	zp_12
	dey
	bne	loc_00FF7F
	lda	zp_16
	rtl
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
