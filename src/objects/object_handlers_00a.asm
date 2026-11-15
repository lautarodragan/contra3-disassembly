; objects/object_handlers_00a.asm -- Object handlers (bank $00, part 1)
; Bank $00, $00:CF0C-$00:D655. Included by main.asm in segment BANK00.
;
; Handlers of object types dispatched through tbl_object_types (see
; objects/object_loop.asm) and helpers they share.

scroll_bg1_by_velocity_and_spawn:
	clc
	lda	a:wram_168C
	adc	a:bg1_x_sub
	sta	a:bg1_x_sub
	lda	a:bg1_x
	sta	zp_00
	adc	a:wram_168E
	sta	a:bg1_x
	sec
	sbc	zp_00
	sta	a:wram_1694
	clc
	lda	a:wram_1690
	adc	a:wram_139C
	sta	a:wram_139C
	lda	a:bg1_y
	sta	zp_00
	adc	a:wram_1692
	sta	a:bg1_y
	sec
	sbc	zp_00
	sta	a:wram_1696
	ldy	a:wram_168A
	lda	a:data_059BC8,y
	cmp	a:bg1_x
	bcc	loc_00CF7D
	phx
	ldx	#$0600
	jsl	f:find_free_slot_from_x
	bcc	loc_00CF59
	; (not executed in the CDL traces)
	plx
	rtl
loc_00CF59:
	lda	a:data_059BCA,y
	pha
	and	#$00FF
	sta	$10,x
	pla
	xba
	and	#$00FF
	sec
	sbc	a:bg1_y
	sta	$0E,x
	lda	a:data_059BCC,y
	sta	$3A,x
	stz	$0A,x
	tya
	clc
	adc	#$0006
	sta	a:wram_168A
	plx
loc_00CF7D:
	rtl

; Object type $55: stage 6: palette cycling (cgram_upload_*). Not identified
; exactly.
update_object_type_55:
	lda	stage_frame_counter
	and	#$0007
	dec	a
	bne	loc_00CF9D
	lda	stage_frame_counter
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_059E42,y
	sta	bg_dma_src
	lda	#$0400
	sta	bg_dma_size
	lda	#$3A90
	sta	bg_dma_vram_addr
loc_00CF9D:
	rtl

; Object type $57: never run in the CDL traces.
update_object_type_57:
	; (not executed in the CDL traces)
	lda	a:bg2sc_shadow
	and	#$FFFC
	ora	$3A,x
	sta	a:bg2sc_shadow
	lda	#$8000
	sta	$16,x
	rtl

; Object type $28: the handler is a fill routine (also called directly as a
; helper); probably never used as a type.
update_object_type_28:
	phx
	tax
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00CFB9:
	.a16
	lda	zp_02
	sta	a:$0000,y
	tya
	clc
	adc	zp_04
	tay
	dex
	bne	loc_00CFB9
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	rtl

; Object type $08: invisible stage trigger (stage 1 section 4): stops
; bg1_autoscroll, sets bg1_scroll_mode = 4 and adjusts the scroll target.
update_object_type_08:
	lda	#$8000
	sta	$16,x
	stz	a:bg1_autoscroll
	lda	#$0004
	sta	a:bg1_scroll_mode
	stz	a:bg1_autoscroll_speed
	lda	a:spawn_scroll_var
	sta	zp_02
	lda	(zp_02)
	clc
	adc	#$0080
	and	#$FF00
	sta	a:spawn_last_page
	sta	(zp_02)
	rtl

; Object type $89: not seen. Not identified.
update_object_type_89:
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	a:stage_checkpoint
	rtl

; Object type $03: stage trigger (stages 1, 3, 6): sets bg2_map_offset from
; field $3A, waits for bg2_screen_drawn, then sets bg2_scroll_mode (low
; nibble of field $3A) and deletes itself.
update_bg2_scroll_mode_trigger:
	lda	$12,x
	bne	loc_00D019
	lda	#$0001
	sta	a:bg2_scroll_mode
	lda	$3A,x
	and	#$FFF0
	sta	a:bg2_map_offset
	inc	$12,x
	stz	a:bg2_screen_drawn
	rtl
loc_00D019:
	lda	a:bg2_screen_drawn
	beq	loc_00D02B
	lda	$3A,x
	and	#$000F
	sta	a:bg2_scroll_mode
	lda	#$8000
	sta	$16,x
loc_00D02B:
	rtl

; Object type $05: stage trigger: turns bg1_autoscroll on and deletes itself.
update_bg1_autoscroll_trigger:
	lda	#$0001
	sta	a:bg1_autoscroll
	lda	#$8000
	sta	$16,x
	rtl

; Object type $3B: stage trigger: sets bg2_scroll_mode from field $3B (and
; wram_13F0), then does what type $0E does.
update_scroll_modes_trigger:
	clc
	lda	a:bg2_y
	adc	#$00FF
	and	#$FF00
	sta	a:wram_13F0
	lda	$3B,x
	and	#$00FF
	sta	a:bg2_scroll_mode

; Object type $0E: stage trigger: sets bg1_scroll_mode from field $3A, stops
; bg1_autoscroll, rounds the BG1 position up to 256 and deletes itself.
update_bg1_scroll_mode_trigger:
	lda	$3A,x
	and	#$00FF
	sta	a:bg1_scroll_mode
	stz	a:bg1_autoscroll
	clc
	lda	a:bg1_x
	adc	#$00FF
	and	#$FF00
	sta	a:bg1_x
	clc
	lda	a:bg1_y
	adc	#$00FF
	and	#$FF00
	sta	a:bg1_y
	lda	#$8000
	sta	$16,x
	rtl

; Object type $07: stage trigger: loads the list
; data_059E4A[field $3A] with load_data_list and deletes itself.
update_load_list_trigger:
	lda	#$8000
	sta	$16,x
	lda	$3A,x
	tay
	stx	zp_FA
	ldx	a:data_059E4A,y
	jsl	f:load_data_list
	ldx	zp_FA
	rtl

; Object type $42: invisible stage trigger: copies fields $3A/$3B into
; wram_1666 / wram_1672.
update_object_type_42:
	sep	#$20
	.a8
	stz	a:wram_1673
	lda	$3B,x
	sta	a:wram_1672
	stz	a:wram_1667
	lda	$3A,x
	sta	a:wram_1666
	rep	#$20
	.a16
	lda	#$8000
	sta	$16,x
	rtl

; Object type $4D: stage trigger: starts a song change (update_song_change):
; song_change_mode / song_change_set from
; data_059F06; never run in the CDL traces.
update_song_change_trigger:
	; (not executed in the CDL traces)
	lda	#$8000
	sta	$16,x
	ldy	$3A,x
	lda	a:data_059F06,y
	sta	a:song_change_mode
	lda	a:data_059F08,y
	sta	a:song_change_set
	rtl

; Object type $06: stage 1 scripted scene (section 9): BG/HDMA effect with 9
; states. Not identified.
update_object_type_06:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_object_type_06_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_object_type_06_states:
	.addr	object_type_06_state_00
	.addr	object_type_06_state_01
	.addr	object_type_06_state_02
	.addr	object_type_06_state_03
	.addr	object_type_06_state_04
	.addr	object_type_06_state_05
	.addr	object_type_06_state_06
	.addr	object_type_06_state_07
	.addr	object_type_06_state_08

object_type_06_state_00:
	lda	a:bg1_scroll_mode
	cmp	#$0004
	bne	loc_00D0E5
	inc	$12,x
loc_00D0E5:
	rtl

object_type_06_state_01:
	lda	#$003F
	sta	a:wram_166C
	lda	#$A000
	sta	a:wram_161E
	lda	#$F300
	sta	a:wram_161C
	stz	a:wram_1620
	stz	a:wram_1622
	inc	$12,x
	lda	#$0005
	sta	a:bg2_scroll_mode
	rtl

object_type_06_state_02:
	lda	#$0008
	sta	zp_08
	stx	zp_FE
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	a:wram_1620
	jsl	f:begin_vram_transfer
loc_00D11D:
	lda	a:wram_161C
	tay
	lda	a:$0000,y
	and	#$3FFF
	clc
	adc	a:wram_1622
	tay
loc_00D12C:
	lda	a:$5000,y
	and	#$00FF
	sta	zp_0A
	ldx	a:wram_161E
	lda	a:$0000,x
	and	#$00FF
	xba
	ora	zp_0A
	ldx	vram_queue_data_ptr
	sta	a:$0000,x
	inc	vram_queue_data_ptr
	inc	vram_queue_data_ptr
	inc	a:wram_161E
	iny
	iny
	tya
	and	#$0007
	bne	loc_00D12C
	inc	a:wram_161C
	inc	a:wram_161C
	lda	a:wram_161C
	and	#$000F
	bne	loc_00D196
	clc
	lda	a:wram_161C
	adc	#$0070
	sta	a:wram_161C
	cmp	#$F500
	bcc	loc_00D196
	sec
	sbc	#$0200
	sta	a:wram_161C
	clc
	lda	a:wram_1622
	adc	#$0008
	cmp	#$0020
	bcc	loc_00D187
	lda	#$0000
loc_00D187:
	sta	a:wram_1622
	bne	loc_00D196
	clc
	lda	a:wram_161C
	adc	#$0010
	sta	a:wram_161C
loc_00D196:
	dec	zp_08
	beq	loc_00D19D
	brl	loc_00D11D
loc_00D19D:
	jsl	f:end_vram_transfer
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FE
	clc
	lda	a:wram_1620
	adc	#$0020
	sta	a:wram_1620
	cmp	#$1000
	bcc	loc_00D1BC
	inc	$12,x
loc_00D1BC:
	rtl

object_type_06_state_03:
	stx	zp_FC
	lda	#$0005
	sta	hdma_preset
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	ldy	#$3800
	lda	#$0018
	sta	a:$0000,y
	lda	a:bg1_x
	sta	a:$0001,y
	lda	#$0048
	sta	a:$0003,y
	lda	#$0101
	sta	a:$0005,y
	lda	a:bg1_x
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3820
	lda	#$0018
	sta	a:$0000,y
	lda	#$0000
	sta	a:$0001,y
	lda	#$0002
	sta	a:$0003,y
	lda	#$0100
	sta	a:$0005,y
	lda	#$FFFF
	sta	a:$0007,y
	lda	#$0000
	sta	a:$0009,y
	ldy	#$3840
	lda	#$0918
	sta	a:$0000,y
	lda	#$0702
	sta	a:$0002,y
	lda	#$0901
	sta	a:$0004,y
	lda	#$0000
	sta	a:$0006,y
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	ldx	zp_FC
	inc	$12,x
	stz	$24,x
	stz	$38,x
	stz	$30,x
	lda	#$7FFF
	sta	$1C,x
	lda	#$FFFD
	sta	$1E,x
	stz	a:boss_work_0
	lda	#$00A0
	sta	f:wram_7E3824
	lda	#$0320
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	stz	a:m7b_shadow
	stz	a:m7c_shadow
	lda	#$0180
	sta	a:m7x_shadow
	lda	#$00A8
	sta	a:m7y_shadow
	lda	#$00C1
	sta	a:m7sel_shadow
	lda	#$0001
	sta	a:wram_1672
	lda	#$0045
	jsl	f:queue_sound
	lda	#$0080
	sta	a:wram_1692
loc_00D28F:
	rtl

object_type_06_state_04:
	lda	a:wram_1692
	bmi	loc_00D29A
	dec	a:wram_1692
	bpl	loc_00D28F
loc_00D29A:
	lda	a:m7d_shadow
	cmp	#$0280
	bcs	object_type_06_state_05
	lda	#$0046
	jsl	f:queue_sound
	inc	$12,x
	lda	a:wram_0290
	bne	object_type_06_state_05
	phx
	ldy	#$0300
	ldx	#$0004
loc_00D2B7:
	lda	#OBJT_BOMBER_BOMB
	sta	a:$0010,y
	lda	#.loword(anim_059F12)
	sta	a:$0020,y
	lda	#$3E00
	sta	a:$0002,y
	lda	#$0003
	sta	a:$0016,y
	lda	#$4000
	sta	a:$001C,y
	lda	#$0003
	sta	a:$001E,y
	lda	#$0038
	sta	a:$000E,y
	lda	a:data_059F08,x
	sta	a:$000A,y
	lda	a:data_059F0C,x
	sta	a:$0034,y
	tya
	clc
	adc	#$0040
	tay
	dex
	dex
	bne	loc_00D2B7
	plx

object_type_06_state_05:
	sec
	lda	a:m7a_shadow
	sbc	#$0008
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	cmp	#$002A
	bcs	loc_00D323
	lda	#$0047
	jsl	f:queue_sound
	inc	$12,x
	stz	hdma_preset
	stz	$24,x
	stx	zp_FC
	ldx	#.loword(data_059FBA)
	jsl	f:load_data_list
	ldx	zp_FC
	rtl
loc_00D323:
	cmp	#$01D0
	bcs	loc_00D332
	lda	stage_frame_odd
	bne	loc_00D332
	dec	a:m7b_shadow
	dec	a:m7c_shadow
loc_00D332:
	clc
	lda	$1C,x
	adc	#$0700
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
	clc
	lda	a:boss_work_0
	adc	$1C,x
	sta	a:boss_work_0
	lda	f:wram_7E3824
	adc	$1E,x
	sta	f:wram_7E3824
	sep	#$20
	.a8
	lda	a:bg1_y
	dec	a
	sta	f:wram_7E3827
	lda	f:wram_7E3842
	cmp	#$47
	bcs	loc_00D37B
	sec
	lda	$38,x
	sbc	$1C,x
	sta	$38,x
	lda	f:wram_7E3842
	sbc	$1E,x
	sta	f:wram_7E3842
	sta	f:wram_7E3823
loc_00D37B:
	rep	#$20
	.a16
	rtl

object_type_06_state_06:
	lda	#$0003
	sta	a:shake_timer
	inc	$24,x
	lda	$24,x
	cmp	#$0100
	bcs	loc_00D394
	cmp	#$00D8
	bne	loc_00D3C0
	bra	loc_00D3C0
loc_00D394:
	inc	$12,x
	lda	#$0001
	sta	a:bg1_scroll_mode
	lda	#$0004
	sta	hdma_preset
	stz	$32,x
	lda	#$007F
	sta	f:wram_7E3820
	lda	#$0020
	sta	f:wram_7E3823
	lda	#$0020
	sta	f:wram_7E3826
	lda	#$0000
	sta	f:wram_7E3829
	rtl
loc_00D3C0:
	lda	#$0008
	sta	zp_00
	lda	#$00D0
	sta	zp_02
	lda	#$00FF
	sta	zp_04
	lda	#$0007
	sta	zp_06
	ldy	#$0300
	lda	#.loword(anim_05C4CE)
	jsl	f:spawn_effect_random_offset
	bcs	loc_00D3E6
	lda	#$FFFC
	sta	a:$001E,y
loc_00D3E6:
	rtl

object_type_06_state_08:
	phx
	lda	#$0038
	sta	zp_02
	ldx	a:wram_166C
	lda	a:data_059F6A,x
	and	#$00FF
	tay
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	sep	#$20
loc_00D401:
	.a8
	lda	a:$A000,y
	ora	f:data_059F2A,x
	sta	a:$A000,y
	lda	a:$A001,y
	ora	f:data_059F2A,x
	sta	a:$A001,y
	lda	a:$A380,y
	ora	f:data_059F2A,x
	sta	a:$A380,y
	lda	a:$A381,y
	ora	f:data_059F2A,x
	sta	a:$A381,y
	lda	a:$A700,y
	ora	f:data_059F2A,x
	sta	a:$A700,y
	lda	a:$A701,y
	ora	f:data_059F2A,x
	sta	a:$A701,y
	lda	a:$AA80,y
	ora	f:data_059F2A,x
	sta	a:$AA80,y
	lda	a:$AA81,y
	ora	f:data_059F2A,x
	sta	a:$AA81,y
	rep	#$20
	.a16
	tya
	clc
	adc	#$0010
	tay
	sep	#$20
	.a8
	dec	zp_02
	bne	loc_00D401
	rep	#$20
	.a16
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	plx
	lda	stage_frame_odd
	bne	loc_00D47E
	dec	a:wram_166C
	bne	loc_00D47E
	lda	#$8000
	sta	$16,x
	stz	hdma_preset
	stz	a:wram_1672
	rtl
loc_00D47E:
	bra	loc_00D48E

object_type_06_state_07:
	lda	#$00C0
	sta	zp_00
	stz	zp_02
	lda	#$0000
	jsl	f:kill_players_outside
loc_00D48E:
	lda	a:bg2_x
	sta	f:wram_7E3821
	sta	f:wram_7E3824
	lda	a:bg1_x
	and	#$00FF
	sta	f:wram_7E3827
	inc	$32,x
	lda	$32,x
	asl	a
	and	#$0006
	tay
	lda	a:data_059FAA,y
	sta	bg_dma_src
	lda	#$0380
	sta	bg_dma_size
	lda	#$2E40
	sta	bg_dma_vram_addr
	rtl

; Object type $2A: advances the state of the type $06 object and deletes the
; type $2F one. Not identified.
update_object_type_2A:
	ldy	#$09C0
loc_00D4BF:
	lda	a:$0010,y
	cmp	#$0006
	beq	loc_00D4D2
	; (not executed in the CDL traces)
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0AC0
	bcc	loc_00D4BF
loc_00D4D2:
	lda	a:$0012,y
	inc	a
	sta	a:$0012,y
	lda	#$8000
	sta	$16,x
	ldy	#$0280
loc_00D4E1:
	lda	a:$0010,y
	cmp	#$002F
	beq	loc_00D4EE
	; (not executed in the CDL traces)
	ldy	#$02C0
	bra	loc_00D4E1
loc_00D4EE:
	lda	#$8000
	sta	a:$0016,y
	rtl

; Object type $0C: bomb dropped by the bomber plane (stage 1 section 10,
; seen in the emulator); falls with gravity, trailing type $1D fire effects.
update_bomber_bomb:
	lda	stage_frame_odd
	bne	loc_00D530
	ldy	$20,x
	lda	a:$0004,y
	sta	zp_00
	ldy	#$0840
	jsl	f:find_free_slot_y_down
	bcc	loc_00D530
	lda	zp_00
	sta	a:$0020,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
	lda	#$E000
	sta	a:$001C,y
	lda	#$FFFD
	sta	a:$001E,y
	lda	#$0003
	sta	a:$0016,y
	lda	#OBJT_EFFECT
	sta	a:$0010,y
loc_00D530:
	sec
	lda	$1C,x
	sbc	#$0900
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	lda	$34,x
	bpl	loc_00D553
	sec
	lda	$18,x
	sbc	#$1400
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rtl
loc_00D553:
	clc
	lda	$18,x
	adc	#$1400
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	rtl

; Object type $3C: stage 3 BG effect (palette cycling, line scroll table at
; $7E:E000). Not identified.
update_object_type_3C:
	lda	stage_frame_counter
	bit	#$0007
	bne	loc_00D57F
	and	#$0018
	lsr	a
	lsr	a
	tay
	lda	a:data_059FB2,y
	sta	bg_dma_src
	lda	#$02E0
	sta	bg_dma_size
	lda	#$0E80
	sta	bg_dma_vram_addr
loc_00D57F:
	lda	#$0001
	sta	a:scroll_split_pattern
	clc
	lda	a:bg2_y
	adc	#$0200
	sta	a:scroll_split_y
	cmp	#$0090
	bcs	loc_00D5A2
	lda	#$8000
	sta	$16,x
	stz	a:scroll_split_pattern
	stz	a:scroll_split_y
	stz	hdma_preset
	rtl
loc_00D5A2:
	ldy	#$001E
	lda	#$0800
	sta	zp_08
loc_00D5AA:
	lda	#$0000
	sta	zp_04
	sta	zp_0A
	lda	a:wram_13D2

add_line_scroll_ramp:
	sta	zp_02
	stz	zp_00
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_00D5C0:
	.a16
	clc
	lda	a:$E800,y
	adc	zp_00
	sta	a:$E800,y
	lda	a:$E000,y
	adc	zp_02
	sta	a:$E000,y
	clc
	lda	zp_00
	adc	zp_08
	sta	zp_00
	lda	zp_02
	adc	zp_0A
	sta	zp_02
	dey
	dey
	cpy	zp_04
	bne	loc_00D5C0
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl
loc_00D5ED:
	lda	stage_frame_counter
	lsr	a
	lsr	a
	lsr	a
	and	#$0007
	bit	#$0004
	beq	loc_00D5FD
	eor	#$FFFF
loc_00D5FD:
	and	#$0003
	pha
	clc
	adc	a:scroll_split_y
	sta	a:scroll_split_y
	pla
	clc
	adc	#$0000
	sta	a:bg2_y

update_stage4_line_scroll:
	lda	#$0002
	sta	a:scroll_split_pattern
	clc
	lda	a:bg2_y
	adc	#$0100
	sta	a:scroll_split_y
	cmp	#$0002
	bcs	loc_00D630
	inc	$12,x
	stz	a:scroll_split_pattern
	stz	a:scroll_split_y
	stz	hdma_preset
	rtl
loc_00D630:
	ldy	#$001A
	lda	#$0012
	sta	zp_04
	lda	#$0000
	sta	zp_08
	lda	#$0001
	sta	zp_0A
	lda	#$000C
	jsl	f:add_line_scroll_ramp
	ldy	#$0012
	lda	#$6000
	sta	zp_08
	brl	loc_00D5AA
	; CDL: not accessed
	.byte	$6B
loc_00D655:
	rtl
