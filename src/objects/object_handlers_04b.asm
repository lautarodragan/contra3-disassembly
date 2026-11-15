; objects/object_handlers_04b.asm -- Object handlers (bank $04, part 2)
; Bank $04, $04:E21B-$04:FFFF. Included by main.asm in segment BANK04.
;
; The crowd of the ending: spawn_ending_crowd (called by ending_sequence in
; bank $1D) and the handlers of object types $9A-$9F.

spawn_ending_crowd:
	lda	zp_00
	pha
	phx
	phy
	stz	zp_00
loc_04E222:
	lda	zp_00
	asl	a
	tay
	lda	a:data_05F5EE,y
	tax
	tya
	asl	a
	tay
	lda	a:data_05F58E,y
	sta	$10,x
	lda	a:data_05F590,y
	sta	$02,x
	lda	a:data_05F5AE,y
	sta	$20,x
	lda	a:data_05F5B0,y
	sta	$04,x
	lda	a:data_05F5CE,y
	sta	$0A,x
	lda	a:data_05F5D0,y
	sta	$32,x
	lda	#$0001
	sta	$16,x
	stz	$22,x
	stz	$16,x
	stz	$18,x
	stz	$1A,x
	stz	$1C,x
	stz	$1E,x
	stz	$08,x
	stz	$0C,x
	stz	$24,x
	stz	$12,x
	jsr	a:place_ending_crowd_member
	inc	zp_00
	lda	zp_00
	ldy	difficulty
	cmp	a:ending_crowd_counts,y
	bcc	loc_04E222
	ply
	plx
	pla
	sta	zp_00
	rtl

; Object type $9A-$9D. Ending: the crowd cheering under the helicopter (one
; handler for four types); spawn_ending_crowd creates 6/7/8 of them on
; easy/normal/hard.
update_ending_crowd_member:
	jsr	a:place_ending_crowd_member
	rtl

update_ending_crowd_walker_a:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_ending_crowd_walker_a_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_ending_crowd_walker_a_states:
	.addr	ending_crowd_walker_a_state_00
	.addr	ending_crowd_walker_a_state_01
	.addr	ending_crowd_walker_a_state_02

ending_crowd_walker_a_state_00:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00B4
	bcs	loc_04E2BC
	lda	OBJ_FACING,x
	bne	loc_04E2AD
	lda	OBJ_X,x
	inc	a
	and	#$00FF
	cmp	#$0030
	bcs	loc_04E2C4
	sta	OBJ_X,x
	bra	loc_04E2C0
loc_04E2AD:
	lda	OBJ_X,x
	dec	a
	and	#$00FF
	cmp	#$0008
	bcc	loc_04E2C4
	sta	OBJ_X,x
	bra	loc_04E2C0
loc_04E2BC:
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_04E2C0:
	jsr	a:place_ending_crowd_member
	rtl
loc_04E2C4:
	lda	OBJ_FACING,x
	eor	#$0002
	and	#$0002
	sta	OBJ_FACING,x
	bra	loc_04E2C0

ending_crowd_walker_a_state_01:
	lda	OBJ_FACING,x
	lda	#.loword(anim_05F642)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	loc_04E2BC

ending_crowd_walker_a_state_02:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00B4
	bcc	loc_04E2C0
	lda	#.loword(anim_05F650)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_TIMER,x
	stz	OBJ_STATE,x
	bra	loc_04E2C0

; Object type $9F. Ending: another crowd member walking back and forth.
update_ending_crowd_walker_b:
	lda	OBJ_STATE,x
	phx
	asl	a
	tax
	lda	f:tbl_ending_crowd_walker_b_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_ending_crowd_walker_b_states:
	.addr	ending_crowd_walker_b_state_00
	.addr	ending_crowd_walker_b_state_01
	.addr	ending_crowd_walker_b_state_02
	.addr	ending_crowd_walker_b_state_03
	.addr	ending_crowd_walker_b_state_04

ending_crowd_walker_b_state_00:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00F0
	bcc	loc_04E317
loc_04E313:
	stz	OBJ_TIMER,x
	inc	OBJ_STATE,x
loc_04E317:
	jsr	a:place_ending_crowd_member
	rtl

ending_crowd_walker_b_state_01:
	lda	OBJ_FACING,x
	lda	#.loword(anim_05F678)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	loc_04E313

ending_crowd_walker_b_state_02:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00B4
	bcc	loc_04E317
	bcs	loc_04E313

ending_crowd_walker_b_state_03:
	lda	OBJ_FACING,x
	lda	#.loword(anim_05F680)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	bra	loc_04E313

ending_crowd_walker_b_state_04:
	inc	OBJ_TIMER,x
	lda	OBJ_TIMER,x
	cmp	#$00B4
	bcs	loc_04E372
	lda	OBJ_FACING,x
	bne	loc_04E359
	lda	OBJ_X,x
	inc	a
	inc	a
	and	#$00FF
	cmp	#$00E8
	bcs	loc_04E366
	sta	OBJ_X,x
	bra	loc_04E317
loc_04E359:
	lda	OBJ_X,x
	dec	a
	dec	a
	cmp	#$00C0
	bcc	loc_04E366
	sta	OBJ_X,x
	bra	loc_04E317
loc_04E366:
	lda	OBJ_FACING,x
	eor	#$0002
	and	#$0002
	sta	OBJ_FACING,x
	bra	loc_04E317
loc_04E372:
	lda	#.loword(anim_05F66A)
	sta	OBJ_ANIM,x
	stz	OBJ_ANIM_TIMER,x
	stz	OBJ_TIMER,x
	stz	OBJ_STATE,x
	bra	loc_04E317

place_ending_crowd_member:
	lda	#$0100
	sec
	sbc	a:bg1_y
	clc
	adc	$32,x
	sta	OBJ_Y,x
	rts
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
