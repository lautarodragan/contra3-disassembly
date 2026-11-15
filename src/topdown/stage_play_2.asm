; topdown/stage_play_2.asm -- Top-down stages: gameplay (part 2)
; Bank $02, $02:E65F-$02:FCCA. Included by main.asm in segment BANK02.
;
; More code of the top-down stages (reached from the state handlers), and
; compute_m7_matrix, run by their NMI frame handler.

; Runs the two smart bomb objects ($0F40 player 1, $0F80 player 2).
td_update_bombs:
	ldx	#$0F40
loc_02E662:
	jsr	a:td_update_bomb
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0FC0
	bcc	loc_02E662
	rtl

; Smart bomb X (type 1, started by td_check_smart_bomb): grows its radius (+$14)
; for $70 frames, then the slot is cleared.
td_update_bomb:
	lda	$10,x
	dec	a
	beq	loc_02E68E
	lda	a:$1048,x
	beq	loc_02E68B
	; (not executed in the CDL traces)
	dec	a:$1048,x
	beq	loc_02E68B
	lda	a:$1048,x
	sta	$06,x
	lda	#$0002
	sta	$10,x
	rts
loc_02E68B:
	stz	$10,x
	rts
loc_02E68E:
	lda	$12,x
	bne	loc_02E6A9
	lda	a:data_05FF8A,x
	sta	$0A,x
	lda	a:data_05FF8E,x
	sta	$0E,x
	lda	#$0001
	sta	$06,x
	stz	$24,x
	stz	$22,x
	stz	$00,x
	inc	$12,x
loc_02E6A9:
	inc	$24,x
	lda	$24,x
	cmp	#$0070
	bcc	loc_02E6B7
	jsl	f:clear_topdown_slot
	rts
loc_02E6B7:
	lda	$24,x
	lsr	a
	lsr	a
	sta	zp_18
	asl	a
	asl	a
	asl	a
	sec
	sbc	zp_18
	sta	$14,x
	rts

; Scale 1:1, the players at their start points, view anchors and angles by 1P / 2P mode.
init_topdown_views:
	lda	#M7_SCALE_1X
	sta	a:p1_m7_scale_x
	sta	a:p2_m7_scale_x
	sta	a:p1_m7_scale_y
	sta	a:p2_m7_scale_y
	lda	a:title_menu_cursor
	beq	loc_02E723
	dec	a
	bne	loc_02E6E0
	brl	loc_02E751
loc_02E6E0:
	; (not executed in the CDL traces)
	lda	a:p1_view_x
	sta	a:wram_0ECA
	stz	a:wram_0EC8
	lda	a:p1_view_y
	sta	a:wram_0ECE
	stz	a:wram_0ECC
	lda	a:p2_view_x
	sta	a:wram_0F0A
	stz	a:wram_0F08
	lda	a:p2_view_y
	sta	a:wram_0F0E
	stz	a:wram_0F0C
	stz	a:wram_150A
	stz	a:wram_154A
	stz	a:wram_1518
	stz	a:wram_1558
	stz	a:p1_view_angle
	stz	a:p2_view_angle
	stz	a:wram_0ED2
	stz	a:wram_0F12
	stz	a:wram_0EC4
	stz	a:wram_0F04
	rtl
loc_02E723:
	lda	#$0080
	sta	a:p1_view_anchor_x
	lda	#$00A0
	sta	a:p1_view_anchor_y
	lda	a:p1_view_x
	sta	a:wram_0ECA
	stz	a:wram_0EC8
	lda	a:p1_view_y
	sta	a:wram_0ECE
	stz	a:wram_0ECC
	stz	a:wram_150A
	stz	a:p1_view_angle
	stz	a:wram_1518
	stz	a:wram_0ED2
	stz	a:wram_0EC4
	rtl
loc_02E751:
	lda	#$0060
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	lda	#$0034
	sta	a:p1_view_anchor_y
	lda	#$00AC
	sta	a:p2_view_anchor_y
	lda	a:p1_view_x
	sta	a:wram_0ECA
	stz	a:wram_0EC8
	lda	a:p1_view_y
	sta	a:wram_0ECE
	stz	a:wram_0ECC
	lda	a:p2_view_x
	sta	a:wram_0F0A
	stz	a:wram_0F08
	lda	a:p2_view_y
	sta	a:wram_0F0E
	stz	a:wram_0F0C
	stz	a:wram_150A
	stz	a:wram_154A
	stz	a:p1_view_angle
	stz	a:p2_view_angle
	lda	#$0040
	sta	a:wram_1518
	sta	a:wram_1558
	stz	a:wram_0ED2
	stz	a:wram_0F12
	lda	#$0040
	sta	a:wram_0EC4
	sta	a:wram_0F04
	rtl

; Each view's Mode 7 centre, scroll and angle from its player (1P, 2P-A
; split, 2P-B shared), or around the boss when boss_centered_view is set.
update_topdown_views:
	rep	#$30
	lda	a:map_view_active
	ora	a:intro_phase
	beq	loc_02E7BA
	; (not executed in the CDL traces)
	rtl
loc_02E7BA:
	lda	a:title_menu_cursor
	beq	loc_02E7C8
	dec	a
	bne	loc_02E7C5
	brl	loc_02E86D
loc_02E7C5:
	; (not executed in the CDL traces)
	brl	loc_02E9C9
loc_02E7C8:
	lda	a:boss_centered_view
	beq	loc_02E7D0
	brl	loc_02E809
loc_02E7D0:
	lda	a:wram_0ECA
	sta	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_m7_hofs
	lda	a:wram_0ECE
	sta	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_m7_vofs
	lda	a:wram_150A
	bne	loc_02E7FB
	lda	a:wram_0EC4
	sta	a:p1_view_angle
loc_02E7FB:
	lda	a:p1_view_angle
	eor	#$00FF
	inc	a
	and	#$00FF
	sta	a:p1_m7_angle
	rtl
loc_02E809:
	lda	a:wram_0ECA
	sta	a:p1_view_x
	lda	a:wram_0ECE
	sta	a:p1_view_y
	lda	a:wram_150A
	bne	loc_02E820
	lda	a:wram_0EC4
	sta	a:p1_view_angle
loc_02E820:
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	jsl	f:sub_02B2AE
	bcc	loc_02E84D
	lda	#$0200
	sta	a:p1_m7_hofs
	sta	a:p1_m7_vofs
	stz	a:p1_m7_angle
	bra	loc_02E86C
loc_02E84D:
	lda	#$00F0
	sec
	sbc	zp_00
	sta	a:p1_m7_hofs
	lda	#$0110
	sec
	sbc	zp_02
	sta	a:p1_m7_vofs
	lda	a:wram_0AC4
	sec
	sbc	a:p1_view_angle
	eor	#$0080
	sta	a:p1_m7_angle
loc_02E86C:
	rtl
loc_02E86D:
	lda	a:boss_centered_view
	beq	loc_02E875
	; (not executed in the CDL traces)
	brl	loc_02E8F4
loc_02E875:
	lda	a:wram_0ECA
	sta	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_m7_hofs
	lda	a:wram_0ECE
	sta	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_m7_vofs
	lda	a:wram_150A
	bne	loc_02E8A7
	lda	a:wram_0EC4
	sec
	sbc	a:wram_1518
	and	#$00FF
	sta	a:p1_view_angle
loc_02E8A7:
	lda	a:p1_view_angle
	eor	#$00FF
	inc	a
	and	#$00FF
	sta	a:p1_m7_angle
	lda	a:wram_0F0A
	sta	a:p2_view_x
	sta	a:p2_m7_center_x
	sec
	sbc	a:p2_view_anchor_x
	sta	a:p2_m7_hofs
	lda	a:wram_0F0E
	sta	a:p2_view_y
	sta	a:p2_m7_center_y
	sec
	sbc	a:p2_view_anchor_y
	sta	a:p2_m7_vofs
	lda	a:wram_154A
	bne	loc_02E8E6
	lda	a:wram_0F04
	sec
	sbc	a:wram_1558
	and	#$00FF
	sta	a:p2_view_angle
loc_02E8E6:
	lda	a:p2_view_angle
	eor	#$00FF
	inc	a
	and	#$00FF
	sta	a:p2_m7_angle
	rtl
loc_02E8F4:
	; (not executed in the CDL traces)
	lda	a:wram_0ECA
	sta	a:p1_view_x
	lda	a:wram_0ECE
	sta	a:p1_view_y
	lda	a:wram_150A
	bne	loc_02E912
	lda	a:wram_0EC4
	sec
	sbc	a:wram_1518
	and	#$00FF
	sta	a:p1_view_angle
loc_02E912:
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	jsl	f:sub_02B2AE
	bcc	loc_02E93F
	lda	#$0200
	sta	a:p1_m7_hofs
	sta	a:p1_m7_vofs
	stz	a:p1_m7_angle
	bra	loc_02E95E
loc_02E93F:
	lda	#$00F0
	sec
	sbc	zp_00
	sta	a:p1_m7_hofs
	lda	#$0110
	sec
	sbc	zp_02
	sta	a:p1_m7_vofs
	lda	a:wram_0AC4
	sec
	sbc	a:p1_view_angle
	eor	#$0080
	sta	a:p1_m7_angle
loc_02E95E:
	lda	a:wram_0F0A
	sta	a:p2_view_x
	lda	a:wram_0F0E
	sta	a:p2_view_y
	lda	a:wram_154A
	bne	loc_02E97C
	lda	a:wram_0F04
	sec
	sbc	a:wram_1558
	and	#$00FF
	sta	a:p2_view_angle
loc_02E97C:
	lda	a:p2_view_x
	sta	zp_18
	lda	a:p2_view_y
	sta	zp_1A
	lda	a:p2_view_angle
	sta	zp_16
	lda	a:p2_view_anchor_x
	sta	zp_1C
	lda	a:p2_view_anchor_y
	sta	zp_1E
	jsl	f:sub_02B2AE
	bcc	loc_02E9A9
	lda	#$0200
	sta	a:p2_m7_hofs
	sta	a:p2_m7_vofs
	stz	a:p2_m7_angle
	bra	loc_02E9C8
loc_02E9A9:
	lda	#$00F0
	sec
	sbc	zp_00
	sta	a:p2_m7_hofs
	lda	#$0110
	sec
	sbc	zp_02
	sta	a:p2_m7_vofs
	lda	a:wram_0AC4
	sec
	sbc	a:p2_view_angle
	eor	#$0080
	sta	a:p2_m7_angle
loc_02E9C8:
	rtl
loc_02E9C9:
	lda	a:boss_centered_view
	beq	loc_02E9D1
	brl	loc_02EA1D
loc_02E9D1:
	jsr	a:sub_02EAA4
	lda	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	#$0080
	sta	a:p1_m7_hofs
	lda	#$0080
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	jsr	a:sub_02EAFD
	lda	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	#$007C
	sta	a:p1_m7_vofs
	lda	#$007C
	sta	a:p1_view_anchor_y
	sta	a:p2_view_anchor_y
	lda	a:wram_150A
	bne	loc_02EA0E
	lda	a:wram_0EC4
	sta	a:wram_1518
loc_02EA0E:
	lda	a:wram_154A
	bne	loc_02EA19
	lda	a:wram_0F04
	sta	a:wram_1558
loc_02EA19:
	stz	a:p1_m7_angle
	rtl
loc_02EA1D:
	jsr	a:sub_02EAA4
	lda	#$0080
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	jsr	a:sub_02EAFD
	lda	#$007C
	sta	a:p1_view_anchor_y
	sta	a:p2_view_anchor_y
	lda	a:wram_150A
	bne	loc_02EA40
	lda	a:wram_0EC4
	sta	a:wram_1518
loc_02EA40:
	lda	a:wram_154A
	bne	loc_02EA4B
	lda	a:wram_0F04
	sta	a:wram_1558
loc_02EA4B:
	lda	a:p1_view_x
	sta	zp_18
	lda	a:p1_view_y
	sta	zp_1A
	lda	a:p1_view_angle
	sta	zp_16
	lda	a:p1_view_anchor_x
	sta	zp_1C
	lda	a:p1_view_anchor_y
	sta	zp_1E
	jsl	f:sub_02B2AE
	bcc	loc_02EA7E
	lda	#$0200
	sta	a:p1_m7_hofs
	sta	a:p1_m7_vofs
	sta	a:p1_m7_center_x
	sta	a:p1_m7_center_y
	stz	a:p1_m7_angle
	bra	loc_02EAA3
loc_02EA7E:
	lda	#$00F0
	sta	a:p1_m7_center_x
	sec
	sbc	zp_00
	sta	a:p1_m7_hofs
	lda	#$0110
	sta	a:p1_m7_center_y
	sec
	sbc	zp_02
	sta	a:p1_m7_vofs
	lda	a:wram_0AC4
	sec
	sbc	a:p1_view_angle
	eor	#$0080
	sta	a:p1_m7_angle
loc_02EAA3:
	rtl

sub_02EAA4:
	; (not executed in the CDL traces)
	jsr	a:sub_02EAEA
	jsr	a:sub_02EAAE
	jsr	a:sub_02EAC1
	rts

sub_02EAAE:
	; (not executed in the CDL traces)
	lda	a:wram_0ED2
	beq	loc_02EAC0
	lda	a:wram_0ECA
	cmp	zp_18
	beq	loc_02EABC
	bpl	loc_02EAD4
loc_02EABC:
	cmp	zp_1A
	bmi	loc_02EAE0
loc_02EAC0:
	rts

sub_02EAC1:
	; (not executed in the CDL traces)
	lda	a:wram_0F12
	beq	loc_02EAD3
	lda	a:wram_0F0A
	cmp	zp_18
	beq	loc_02EACF
	bpl	loc_02EAD4
loc_02EACF:
	cmp	zp_1A
	bmi	loc_02EAE0
loc_02EAD3:
	rts
loc_02EAD4:
	sec
	sbc	#$0048
	sta	a:p1_view_x
	sta	a:p2_view_x
	bra	sub_02EAEA
loc_02EAE0:
	clc
	adc	#$0048
	sta	a:p1_view_x
	sta	a:p2_view_x

sub_02EAEA:
	; (not executed in the CDL traces)
	lda	a:p1_view_x
	clc
	adc	#$0048
	sta	zp_18
	lda	a:p1_view_x
	sec
	sbc	#$0048
	sta	zp_1A
	rts

sub_02EAFD:
	; (not executed in the CDL traces)
	jsr	a:sub_02EB43
	jsr	a:sub_02EB07
	jsr	a:sub_02EB1A
	rts

sub_02EB07:
	; (not executed in the CDL traces)
	lda	a:p1_lives
	beq	loc_02EB19
	lda	a:wram_0ECE
	cmp	zp_18
	beq	loc_02EB15
	bpl	loc_02EB2D
loc_02EB15:
	cmp	zp_1A
	bmi	loc_02EB39
loc_02EB19:
	rts

sub_02EB1A:
	; (not executed in the CDL traces)
	lda	a:p2_lives
	beq	loc_02EB2C
	lda	a:wram_0F0E
	cmp	zp_18
	beq	loc_02EB28
	bpl	loc_02EB2D
loc_02EB28:
	cmp	zp_1A
	bmi	loc_02EB39
loc_02EB2C:
	rts
loc_02EB2D:
	sec
	sbc	#$002C
	sta	a:p1_view_y
	sta	a:p2_view_y
	bra	sub_02EB43
loc_02EB39:
	clc
	adc	#$002C
	sta	a:p1_view_y
	sta	a:p2_view_y

sub_02EB43:
	; (not executed in the CDL traces)
	lda	a:p1_view_y
	clc
	adc	#$002C
	sta	zp_18
	lda	a:p1_view_y
	sec
	sbc	#$002C
	sta	zp_1A
	rts

; Collisions of one player per frame (alternating in 2P): shots, body, bomb, target arrow.
td_run_collisions:
	rep	#$30
	lda	a:title_menu_cursor
	beq	loc_02EB6B
	lda	stage_frame_counter
	lsr	a
	bcs	loc_02EB6B
	lda	a:wram_0F12
	beq	loc_02EB74
	jml	f:td_run_p2_collisions
loc_02EB6B:
	lda	a:wram_0ED2
	beq	loc_02EB74
	jml	f:td_run_p1_collisions
loc_02EB74:
	; (not executed in the CDL traces)
	rtl

; Adds the points of victim Y to the score of the owner of shot X ($1F80 for
; player 1's shots below $0700, else $1FC0).
td_score_shot_kill:
	phx
	phy
	jsr	a:td_score_shot_kill_2
	ply
	plx
	rtl

td_score_shot_kill_2:
	cpx	#$0700
	bcs	loc_02EB8E
	tyx
	jsr	a:td_get_kill_points
	ldx	#$1F80
	jsl	f:add_score
	rts
loc_02EB8E:
	tyx
	jsr	a:td_get_kill_points
	ldx	#$1FC0
	jsl	f:add_score
	rts

; As td_score_shot_kill, points from td_enemy_scores.
td_score_shot_kill_enemy:
	phx
	phy
	jsr	a:td_score_shot_kill_enemy_2
	ply
	plx
	rtl

td_score_shot_kill_enemy_2:
	cpx	#$0700
	bcs	loc_02EBB3
	tyx
	jsr	a:td_get_enemy_points
	ldx	#$1F80
	jsl	f:add_score
	rts
loc_02EBB3:
	; (not executed in the CDL traces)
	tyx
	jsr	a:td_get_enemy_points
	ldx	#$1FC0
	jsl	f:add_score
	rts

; Adds the points of victim X to the score block Y.
td_score_kill:
	phx
	jsr	a:td_score_kill_2
	plx
	rtl

td_score_kill_2:
	jsr	a:td_get_kill_points
	tyx
	jsl	f:add_score
	rts

sub_02EBCE:
	; (not executed in the CDL traces)
	phx
	jsr	a:sub_02EBD4
	plx
	rtl

sub_02EBD4:
	; (not executed in the CDL traces)
	jsr	a:td_get_enemy_points
	tyx
	jsl	f:add_score
	rts

; A = points of object X: td_enemy_scores for enemies ($0D40-), else td_map_object_scores.
td_get_kill_points:
	cpx	#$0D40
	bcs	td_get_enemy_points
	lda	$10,x
	asl	a
	tax
	lda	a:td_map_object_scores,x
	rts

; A = points of object X by its type (td_enemy_scores).
td_get_enemy_points:
	lda	$10,x
	asl	a
	tax
	lda	a:td_enemy_scores,x
	rts

; Sets up the top-down HDMA channels 2-7 and their tables at $7E:3C00/$7E:3E00
; (window, indirect) and $7E:3860-$7E:38E0 (CGADSUB, TM, INIDISP, SETINI, BGMODE by screen section), by 1P / 2P-A.
; Sets up HDMA channels 2-7: the window (indirect, tables $7E:3C00/$7E:3E00) and
; per screen section CGADSUB, TM, INIDISP, SETINI and BGMODE ($7E:3860-$7E:38E0),
; with the tables for 1P or 2P-A.
init_topdown_hdma:
	rep	#$30
	jsr	a:setup_topdown_hdma_channels
	sep	#$20
	.a8
	lda	#$01
	sta	f:wram_7E3C00
	sta	f:wram_7E3E00
	rep	#$20
	.a16
	lda	#$3C1E
	sta	f:wram_7E3C01
	lda	#$3E1E
	sta	f:wram_7E3E01
	sep	#$20
	.a8
	lda	#$00
	sta	f:wram_7E3C03
	sta	f:wram_7E3E03
	rep	#$20
	.a16
	lda	#$0001
	sta	f:wram_7E3E1E
	sta	f:wram_7E3C1E
	lda	a:title_menu_cursor
	beq	loc_02EC34
	dec	a
	beq	loc_02EC71
loc_02EC34:
	ldx	#$E496
	ldy	#$38E0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E49F
	ldy	#$38C0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4A8
	ldy	#$38A0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4B1
	ldy	#$3880
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4BA
	ldy	#$3860
	lda	#$001F
	jsr	a:copy_hdma_table
	rtl
loc_02EC71:
	ldx	#$E4C3
	ldy	#$38E0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4CC
	ldy	#$38C0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4D5
	ldy	#$38A0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4DE
	ldy	#$3880
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#$E4E7
	ldy	#$3860
	lda	#$001F
	jsr	a:copy_hdma_table
	rtl

; MVN of A+1 bytes from $05:X to $7E:Y.
copy_hdma_table:
	phb
	mvn	#$05, #$7E
	plb
	rts

; Channel parameters and table addresses of HDMA channels 2-7.
setup_topdown_hdma_channels:
	lda	#$0000
	sta	a:MDMAEN
	ldx	#$4370
	lda	#$0500
	sta	$00,x
	lda	#$38E0
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	rep	#$20
	.a16
	ldx	#$4360
	lda	#$3300
	sta	$00,x
	lda	#$38C0
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	rep	#$20
	.a16
	ldx	#$4350
	lda	#$0000
	sta	$00,x
	lda	#$38A0
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	rep	#$20
	.a16
	ldx	#$4340
	lda	#$2C00
	sta	$00,x
	lda	#$3880
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	rep	#$20
	.a16
	ldx	#$4330
	lda	#$3100
	sta	$00,x
	lda	#$3860
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	rep	#$20
	.a16
	ldx	#$4320
	lda	#$2641
	sta	$00,x
	lda	#$3C00
	sta	$02,x
	sep	#$20
	.a8
	lda	#$7E
	sta	$04,x
	sta	$07,x
	rep	#$20
	.a16
	rts

; IRQ for the Mode 7 matrix: line 8 (1P, 2P-B) or line 0 with m7_split_screen (2P-A).
init_topdown_irq:
	lda	a:title_menu_cursor
	beq	loc_02ED43
	dec	a
	beq	loc_02ED5D
loc_02ED43:
	lda	#$0000
	sta	a:htime_shadow
	lda	#$0008
	sta	a:vtime_shadow
	lda	#$00A1
	sta	a:nmitimen_shadow
	lda	#$0002
	sta	irq_mode
	stz	m7_split_screen
	rtl
loc_02ED5D:
	lda	#$0000
	sta	a:htime_shadow
	lda	#$0000
	sta	a:vtime_shadow
	lda	#$00A1
	sta	a:nmitimen_shadow
	lda	#$0002
	sta	irq_mode
	sta	m7_split_screen
	rtl

; NMI: player 1's Mode 7 matrix from p1_m7_angle and the scales (sine_table,
; cosine_table, multiply_sine_scale), and the centre and scroll register values
; (vertical scroll minus screen_shake_offset); player 2's too in 2P-A.
compute_m7_matrix:
	rep	#$30
	lda	a:title_menu_cursor
	beq	loc_02ED85
	dec	a
	bne	loc_02ED85
	jsl	f:compute_p2_m7_matrix
loc_02ED85:
	lda	a:p1_m7_angle
	clc
	adc	#$0040
	xba
	pha
	lda	a:p1_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:cosine_table,y
	sta	zp_0A
	lda	a:p1_m7_scale_x
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EDAB
	eor	#$FFFF
	inc	a
loc_02EDAB:
	sta	a:p1_m7a
	lda	a:p1_m7_angle
	xba
	pha
	lda	a:p1_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:sine_table,y
	sta	zp_0A
	lda	a:p1_m7_scale_x
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EDD0
	eor	#$FFFF
	inc	a
loc_02EDD0:
	sta	a:p1_m7b
	lda	a:p1_m7_angle
	xba
	pha
	lda	a:p1_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:sine_table,y
	sta	zp_0A
	lda	a:p1_m7_scale_y
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bmi	loc_02EDF5
	eor	#$FFFF
	inc	a
loc_02EDF5:
	sta	a:p1_m7c
	lda	a:p1_m7_angle
	clc
	adc	#$0040
	xba
	pha
	lda	a:p1_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:cosine_table,y
	sta	zp_0A
	lda	a:p1_m7_scale_y
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EE1E
	eor	#$FFFF
	inc	a
loc_02EE1E:
	sta	a:p1_m7d
	lda	a:p1_m7_center_x
	sta	a:p1_m7x
	lda	a:p1_m7_center_y
	sta	a:p1_m7y
	lda	a:p1_m7_hofs
	sta	a:p1_bg1hofs
	lda	a:p1_m7_vofs
	sec
	sbc	a:screen_shake_offset
	sta	a:p1_bg1vofs
	rtl

; Player 2's Mode 7 matrix (2P-A split screen).
compute_p2_m7_matrix:
	lda	a:p2_m7_angle
	clc
	adc	#$0040
	xba
	pha
	lda	a:p2_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:cosine_table,y
	sta	zp_0A
	lda	a:p2_m7_scale_x
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EE64
	eor	#$FFFF
	inc	a
loc_02EE64:
	sta	a:p2_m7a
	lda	a:p2_m7_angle
	xba
	pha
	lda	a:p2_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:sine_table,y
	sta	zp_0A
	lda	a:p2_m7_scale_x
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EE89
	eor	#$FFFF
	inc	a
loc_02EE89:
	sta	a:p2_m7b
	lda	a:p2_m7_angle
	xba
	pha
	lda	a:p2_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:sine_table,y
	sta	zp_0A
	lda	a:p2_m7_scale_y
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bmi	loc_02EEAE
	eor	#$FFFF
	inc	a
loc_02EEAE:
	sta	a:p2_m7c
	lda	a:p2_m7_angle
	clc
	adc	#$0040
	xba
	pha
	lda	a:p2_m7_angle
	and	#$007F
	asl	a
	tay
	lda	a:cosine_table,y
	sta	zp_0A
	lda	a:p2_m7_scale_y
	sta	zp_08
	jsr	a:multiply_sine_scale
	asl	a
	ply
	bpl	loc_02EED7
	eor	#$FFFF
	inc	a
loc_02EED7:
	sta	a:p2_m7d
	lda	a:p2_m7_center_x
	sta	a:p2_m7x
	lda	a:p2_m7_center_y
	sta	a:p2_m7y
	lda	a:p2_m7_hofs
	sta	a:p2_bg1hofs
	lda	a:p2_m7_vofs
	sec
	sbc	a:screen_shake_offset
	sta	a:p2_bg1vofs
	rtl

; zp_00-zp_03 = zp_0A (sine) * zp_08 (scale), 16 x 16 bits with the hardware multiplier.
multiply_sine_scale:
	sep	#$20
	.a8
	lda	zp_0A
	sta	a:WRMPYA
	lda	zp_08
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	nop
	stz	zp_02
	lda	a:RDMPYL
	sta	zp_00
	sep	#$20
	.a8
	lda	zp_09
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	clc
	lda	zp_01
	adc	a:RDMPYL
	sta	zp_01
	bcc	loc_02EF24
	; (not executed in the CDL traces)
	inc	zp_03
loc_02EF24:
	sep	#$20
	.a8
	lda	zp_0B
	sta	a:WRMPYA
	lda	zp_08
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	clc
	lda	zp_01
	adc	a:RDMPYL
	sta	zp_01
	bcc	loc_02EF3F
	inc	zp_03
loc_02EF3F:
	sep	#$20
	.a8
	lda	zp_09
	sta	a:WRMPYB
	rep	#$20
	.a16
	nop
	clc
	lda	zp_02
	adc	a:RDMPYL
	sta	zp_02
	rts
	; CDL: not accessed
	.byte	$C2, $30

; Counts screen_shake_timer down and makes screen_shake_offset alternate sign
; every other frame, decaying when the timer is over.
update_screen_shake:
	lda	a:screen_shake_timer
	beq	loc_02EF6E
	dec	a:screen_shake_timer
loc_02EF5C:
	lda	stage_frame_counter
	and	#$0001
	bne	loc_02EF6D
	lda	a:screen_shake_offset
	eor	#$FFFF
	inc	a
	sta	a:screen_shake_offset
loc_02EF6D:
	rtl
loc_02EF6E:
	lda	a:screen_shake_offset
	beq	loc_02EF6D
	bmi	loc_02EF81
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_02EF5C
	dec	a:screen_shake_offset
	bra	loc_02EF5C
loc_02EF81:
	lda	stage_frame_counter
	bit	#$0003
	bne	loc_02EF5C
	inc	a:screen_shake_offset
	bra	loc_02EF5C

sub_02EF8D:
	jsl	f:sub_02EFA2
	jsr	a:sub_02F109
	jsr	a:sub_02F1B1
	jsr	a:sub_02F257
	jsr	a:sub_02F365
	jsl	f:sub_02F18F
	rtl

sub_02EFA2:
	lda	$06,x
	bpl	loc_02EFA9
	brl	loc_02F09A
loc_02EFA9:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02EFB8,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02EFB8:
	.addr	sub_02EFCC
	.addr	sub_02EFFE
	.addr	sub_02F00D
	.addr	sub_02F03B
	.addr	sub_02F04D
	.addr	sub_02F057
	.addr	sub_02F065
	.addr	sub_02F082
	.addr	sub_02F0B3
	.addr	sub_02F0FB

sub_02EFCC:
	ldy	difficulty
	lda	a:data_05E670,y
	sta	$06,x
	stz	$16,x
	stz	$2E,x
	stz	$00,x
	stz	$20,x
	stz	$2A,x
	lda	#$0200
	sta	$0A,x
	sta	$0E,x
	stz	$08,x
	stz	$0C,x
	stz	a:wram_15C0
	stz	a:wram_15BC
	stz	a:wram_15C8
loc_02EFF1:
	jsr	a:sub_02F3CF
	lda	#$0040
	sta	$24,x
	lda	#$0001
	sta	$12,x

sub_02EFFE:
	dec	$24,x
	bmi	loc_02F003
	rtl
loc_02F003:
	lda	#$0040
	sta	$24,x
	lda	#$0002
	sta	$12,x

sub_02F00D:
	dec	$24,x
	bmi	loc_02F015
	jsr	a:sub_02F225
	rtl
loc_02F015:
	ldy	difficulty
	lda	a:data_05E670,y
	lsr	a
	cmp	$06,x
	bcc	loc_02F031
	jsl	f:sub_02B1A3
	lda	a:wram_15A0
	cmp	#$4000
	bcs	loc_02F02E
	brl	loc_02F060
loc_02F02E:
	; (not executed in the CDL traces)
	brl	loc_02F07D
loc_02F031:
	lda	#$0058
	sta	$24,x
	lda	#$0003
	sta	$12,x

sub_02F03B:
	dec	$24,x
	bmi	loc_02F043
	jsr	a:sub_02F225
	rtl
loc_02F043:
	lda	#$0040
	sta	$24,x
	lda	#$0004
	sta	$12,x

sub_02F04D:
	dec	$24,x
	bmi	loc_02F052
	rtl
loc_02F052:
	lda	#$0005
	sta	$12,x

sub_02F057:
	jsr	a:sub_02F75F
	bne	loc_02F05F
	brl	loc_02EFF1
loc_02F05F:
	rtl
loc_02F060:
	lda	#$0006
	sta	$12,x

sub_02F065:
	jsr	a:sub_02F75F
	bne	loc_02F06D
	brl	loc_02EFF1
loc_02F06D:
	jsl	f:sub_02B1A3
	lda	a:wram_15A0
	cmp	#$4000
	bcs	loc_02F07D
	jsr	a:sub_02F237
	rtl
loc_02F07D:
	lda	#$0007
	sta	$12,x

sub_02F082:
	jsr	a:sub_02F75F
	bne	loc_02F08A
	; (not executed in the CDL traces)
	brl	loc_02EFF1
loc_02F08A:
	jsl	f:sub_02B1A3
	lda	a:wram_15A0
	cmp	#$4000
	bcc	loc_02F060
	jsr	a:sub_02F225
	rtl
loc_02F09A:
	lda	#$0008
	cmp	$12,x
	beq	sub_02F0B3
	sta	$12,x
	stz	$16,x
	lda	#$0200
	sta	$24,x
	sta	a:screen_shake_timer
	lda	#$0002
	sta	a:screen_shake_offset

sub_02F0B3:
	jsl	f:sub_02B7C9
	lda	$24,x
	beq	loc_02F0EF
	cmp	#$000C
	bcc	loc_02F0EC
	and	#$0003
	bne	loc_02F0EC
	lda	rng_hi
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0A,x
	sta	a:wram_0B0A
	lda	rng_lo
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0E,x
	sta	a:wram_0B0E
	phx
	ldx	#$0B00
	jsl	f:sub_02AC72
	plx
loc_02F0EC:
	dec	$24,x
	rtl
loc_02F0EF:
	stz	$06,x
	lda	#$0080
	sta	$24,x
	lda	#$0009
	sta	$12,x

sub_02F0FB:
	lda	$24,x
	and	#$0003
	bne	loc_02F106
	jsl	f:sub_02AC72
loc_02F106:
	dec	$24,x
	rtl

sub_02F109:
	lda	a:wram_0AD2
	cmp	#$0008
	bcs	loc_02F182
	cmp	#$0001
	beq	loc_02F14F
	cmp	#$0002
	beq	loc_02F164
	cmp	#$0003
	beq	loc_02F164
	cmp	#$0004
	beq	loc_02F164
	cmp	#$0005
	beq	loc_02F164
	cmp	#$0006
	beq	loc_02F164
	cmp	#$0007
	beq	loc_02F164
	; (not executed in the CDL traces)
	lda	a:wram_15C0
	phx
	asl	a
	tax
	lda	f:tbl_02F144,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F144:
	.addr	sub_02F14C
	.addr	sub_02F155
	.addr	sub_02F16A
	.addr	sub_02F188

sub_02F14C:
	; (not executed in the CDL traces)
	stz	a:wram_1592
loc_02F14F:
	lda	#$0001
	sta	a:wram_15C0

sub_02F155:
	lda	a:wram_1592
	bne	loc_02F160
	lda	#$1000
	sta	$16,x
	rts
loc_02F160:
	dec	a:wram_1592
	rts
loc_02F164:
	lda	#$0002
	sta	a:wram_15C0

sub_02F16A:
	lda	a:wram_1592
	cmp	#$0017
	bcc	loc_02F17E
	lda	#$0017
	sta	a:wram_1592
	lda	#$B000
	sta	$16,x
	rts
loc_02F17E:
	inc	a:wram_1592
	rts
loc_02F182:
	lda	#$0003
	sta	a:wram_15C0

sub_02F188:
	lda	#$0018
	sta	a:wram_1592
	rts

sub_02F18F:
	lda	#$3200
	sta	a:boss_chr_stream_vram
	lda	#$007E
	sta	a:boss_chr_stream_bank
	lda	#$0280
	sta	a:boss_chr_stream_size
	lda	a:wram_1592
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:data_05E676,y
	sta	a:boss_chr_stream_src
	rtl

sub_02F1B1:
	lda	a:wram_15BC
	phx
	asl	a
	tax
	lda	f:tbl_02F1C1,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F1C1:
	.addr	sub_02F1C7
	.addr	sub_02F1D9
	.addr	sub_02F204

sub_02F1C7:
	stz	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	lda	#$0001
	sta	a:palette_cycle_paused
	lda	#$0001
	sta	a:wram_15BC

sub_02F1D9:
	lda	a:wram_0AD2
	cmp	#$0008
	bcs	loc_02F1EB
	ldy	difficulty
	lda	a:data_05E670,y
	lsr	a
	cmp	$06,x
	bcs	loc_02F1EC
loc_02F1EB:
	rts
loc_02F1EC:
	lda	#$0008
	sta	a:wram_15C4
	sta	a:palette_cycle_paused
	lda	#$0100
	sta	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	lda	#$0002
	sta	a:wram_15BC

sub_02F204:
	lda	a:wram_15C4
	beq	loc_02F21C
	lda	a:palette_cycle_paused
	bne	loc_02F219
	dec	a:wram_15C4
	lda	a:wram_15C4
	sta	a:palette_cycle_paused
	bra	loc_02F21C
loc_02F219:
	dec	a:palette_cycle_paused
loc_02F21C:
	lda	a:wram_0AD2
	cmp	#$0008
	bcs	sub_02F1C7
	rts

sub_02F225:
	jsl	f:sub_02B1A3
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sta	$3E,x
	lda	a:$0ECE,y
	sta	$3C,x
	rts

sub_02F237:
	lda	stage_frame_counter
	eor	#$00FF
	and	#$00FF
	ldy	#$0040
	jsl	f:polar_to_xy
	lda	#$0200
	clc
	adc	zp_08
	sta	$3E,x
	lda	#$0200
	clc
	adc	zp_0A
	sta	$3C,x
	rts

sub_02F257:
	lda	a:wram_0AC6
	bpl	loc_02F25F
	brl	loc_02F306
loc_02F25F:
	lda	a:wram_15C8
	phx
	asl	a
	tax
	lda	f:tbl_02F26F,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F26F:
	.addr	sub_02F27C
	.addr	sub_02F2A9
	.addr	sub_02F2B8
	.addr	sub_02F300
	.addr	sub_02F32D
loc_02F279:
	stz	a:wram_15C8

sub_02F27C:
	lda	a:wram_0AD2
	cmp	#$0006
	beq	loc_02F285
	rts
loc_02F285:
	lda	#$003A
	jsl	f:queue_sound
	lda	rng_lo
	and	#$0006
	sta	a:wram_15CC
	lda	#$0020
	sta	a:wram_15CA
	lda	#$0300
	jsr	a:sub_02F336
	stz	a:wram_0314
	lda	#$0001
	sta	a:wram_15C8

sub_02F2A9:
	dec	a:wram_15CA
	bmi	loc_02F2AF
	rts
loc_02F2AF:
	stz	a:wram_15CA
	lda	#$0002
	sta	a:wram_15C8

sub_02F2B8:
	lda	a:wram_15CA
	inc	a:wram_15CA
	cmp	#$0020
	bcs	loc_02F2DC
	bit	#$0003
	bne	loc_02F2DB
	lsr	a
	and	#$000E
	tay
	lda	a:data_05E67E,y
	tay
	lda	#$0001
	sta	a:$0014,y
	tya
	jsr	a:sub_02F336
loc_02F2DB:
	rts
loc_02F2DC:
	lda	#$0000
	sta	a:wram_15CA
	stz	a:wram_0314
	stz	a:wram_0334
	stz	a:wram_0354
	stz	a:wram_0374
	stz	a:wram_0394
	stz	a:wram_03B4
	stz	a:wram_03D4
	stz	a:wram_03F4
	lda	#$0003
	sta	a:wram_15C8

sub_02F300:
	dec	a:wram_15CA
	bmi	loc_02F306
	; (not executed in the CDL traces)
	rts
loc_02F306:
	lda	#$0020
	sta	a:wram_15CA
	lda	#$0002
	sta	a:wram_0312
	sta	a:wram_0332
	sta	a:wram_0352
	sta	a:wram_0372
	sta	a:wram_0392
	sta	a:wram_03B2
	sta	a:wram_03D2
	sta	a:wram_03F2
	lda	#$0004
	sta	a:wram_15C8

sub_02F32D:
	dec	a:wram_15CA
	bpl	loc_02F335
	brl	loc_02F279
loc_02F335:
	rts

sub_02F336:
	phx
	tax
	lda	#$000B
	sta	$10,x
	stz	$12,x
	lda	#$2000
	sta	$02,x
	ldy	a:wram_15CC
	lda	a:data_05E6A6,y
	sta	$0A,x
	stz	$08,x
	lda	a:data_05E6AE,y
	sta	$0E,x
	stz	$0C,x
	lda	a:data_05E68E,y
	sta	$1A,x
	stz	$18,x
	lda	a:data_05E696,y
	sta	$1E,x
	stz	$1C,x
	plx
	rts

sub_02F365:
	lda	a:wram_15B0
	inc	a:wram_15B0
	lsr	a
	and	#$0006
	tay
	lda	a:data_05E69E,y
	sta	zp_00
	lda	#$22A0
	sta	zp_02
	lda	#$0020
	sta	zp_04
	lda	$2A,x
	beq	loc_02F390
	jsr	a:sub_02F3C1
	dec	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rts
loc_02F390:
	lda	$2E,x
	bit	#$0040
	beq	sub_02F3C1
	and	#$FFBF
	sta	$2E,x
	lda	#$0004
	sta	$2A,x
	lda	#$0010
	jsl	f:queue_sound
	phx
	phb
	ldx	zp_02
	lda	#$7FFF
	sta	f:$7E0000,x
	txy
	iny
	iny
	lda	zp_04
	dec	a
	dec	a
	dec	a
	mvn	#$7E, #$7E
	plb
	plx
	rts

sub_02F3C1:
	phx
	phb
	ldx	zp_00
	ldy	zp_02
	lda	zp_04
	mvn	#$08, #$7E
	plb
	plx
	rts

sub_02F3CF:
	jsl	f:sub_02B1A3
	ldy	a:wram_159E
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sta	a:wram_0B44
	clc
	adc	#$0020
	asl	a
	asl	a
	xba
	asl	a
	and	#$0006
	tay
	lda	a:data_05E6A6,y
	sta	a:wram_0B4A
	lda	a:data_05E6AE,y
	sta	a:wram_0B4E
	lda	#$000A
	sta	a:wram_0B50
	lda	#$0013
	sta	a:wram_0B90
	lda	#$000B
	sta	a:wram_0BD0
	sta	a:wram_0C10
	sta	a:wram_0C50
	sta	a:wram_0C90
	sta	a:wram_0CD0
	sta	a:wram_0D10
	sta	a:wram_0D50
	sta	a:wram_0D90
	sta	a:wram_0DD0
	sta	a:wram_0E10
	sta	a:wram_0E50
	sta	a:wram_0E90
	stz	a:wram_0B52
	stz	a:wram_0B92
	stz	a:wram_0BD2
	stz	a:wram_0C12
	stz	a:wram_0C52
	stz	a:wram_0C92
	stz	a:wram_0CD2
	stz	a:wram_0D12
	stz	a:wram_0D52
	stz	a:wram_0D92
	stz	a:wram_0DD2
	stz	a:wram_0E12
	stz	a:wram_0E52
	stz	a:wram_0E92
	sec
	lda	#$1900
	sta	a:wram_0B7A
	sbc	#$0020
	sta	a:wram_0BFA
	sbc	#$0020
	sta	a:wram_0C3A
	sbc	#$0020
	sta	a:wram_0C7A
	sbc	#$0020
	sta	a:wram_0CBA
	sbc	#$0020
	sta	a:wram_0CFA
	sbc	#$0020
	sta	a:wram_0D3A
	sbc	#$0020
	sta	a:wram_0D7A
	sbc	#$0020
	sta	a:wram_0DBA
	sbc	#$0020
	sta	a:wram_0DFA
	sbc	#$0020
	sta	a:wram_0E3A
	sbc	#$0020
	sta	a:wram_0E7A
	sbc	#$0020
	sta	a:wram_0EBA
	sbc	#$0020
	sta	a:wram_0BBA
	rts

sub_02F4B8:
	lda	a:wram_0AC6
	bpl	loc_02F4C0
	brl	loc_02F5B6
loc_02F4C0:
	jsr	a:sub_02F745
	bcc	loc_02F4C8
	brl	loc_02F5B6
loc_02F4C8:
	lda	a:wram_0AD2
	cmp	#$0002
	beq	loc_02F532
	cmp	#$0003
	bne	loc_02F4D8
	brl	loc_02F55B
loc_02F4D8:
	cmp	#$0004
	bne	loc_02F4E0
	brl	loc_02F575
loc_02F4E0:
	cmp	#$0005
	bne	loc_02F4E8
	brl	loc_02F58B
loc_02F4E8:
	cmp	#$0006
	beq	loc_02F55B
	cmp	#$0007
	beq	loc_02F55B
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02F501,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F501:
	.addr	sub_02F50F
	.addr	sub_02F531
	.addr	sub_02F554
	.addr	sub_02F564
	.addr	sub_02F57E
	.addr	sub_02F5A3
	.addr	sub_02F5C8

sub_02F50F:
	ldy	difficulty
	lda	a:data_05E6B6,y
	sta	$06,x
	stz	$16,x
	stz	$2E,x
	stz	$00,x
	stz	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	stz	$08,x
	stz	$0C,x
	lda	#$0001
	cmp	$12,x
	beq	sub_02F531
	sta	$12,x

sub_02F531:
	rtl
loc_02F532:
	lda	#$0002
	cmp	$12,x
	beq	sub_02F554
	sta	$12,x
	lda	#$B000
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	$0A,x
	sta	a:wram_1900
	lda	$0E,x
	sta	a:wram_1902

sub_02F554:
	lda	#$0002
	jsr	a:sub_02F78A
	rtl
loc_02F55B:
	lda	#$0003
	cmp	$12,x
	beq	sub_02F564
	sta	$12,x

sub_02F564:
	lda	#$0002
	jsr	a:sub_02F78A
	lda	#$0020
	jsl	f:sub_029C7F
	jsr	a:sub_02F7F0
	rtl
loc_02F575:
	lda	#$0004
	cmp	$12,x
	beq	sub_02F57E
	sta	$12,x

sub_02F57E:
	lda	a:wram_0AE4
	cmp	#$0010
	bne	loc_02F58A
	jsl	f:sub_02F86F
loc_02F58A:
	rtl
loc_02F58B:
	lda	#$0005
	cmp	$12,x
	beq	sub_02F5A3
	sta	$12,x
	lda	#$B000
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x

sub_02F5A3:
	jsr	a:sub_02F7DB
	sta	$04,x
	jsr	a:sub_02F834
	lda	$3A,x
	cmp	#$1900
	bcs	loc_02F5B5
	brl	clear_topdown_slot
loc_02F5B5:
	rtl
loc_02F5B6:
	lda	#$0006
	cmp	$12,x
	beq	sub_02F5C8
	sta	$12,x
	lda	#$0030
	jsl	f:queue_sound
	stz	$16,x

sub_02F5C8:
	lda	zp_EB
	and	#$0002
	sta	$14,x
	jsl	f:sub_02AC8F
	jsl	f:sub_029D0C
	rtl

sub_02F5D8:
	lda	a:wram_0B50
	bne	loc_02F5E0
	brl	clear_topdown_slot
loc_02F5E0:
	jsr	a:sub_02F753
	jsr	a:sub_02F745
	bcc	loc_02F5EB
	brl	loc_02F675
loc_02F5EB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02F5FA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F5FA:
	.addr	sub_02F602
	.addr	sub_02F61D
	.addr	sub_02F63C
	.addr	sub_02F665

sub_02F602:
	stz	$16,x
	stz	$2E,x
	stz	$00,x
	stz	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	stz	$08,x
	stz	$0C,x
	stz	$06,x
	stz	$04,x
	lda	#$0001
	sta	$12,x

sub_02F61D:
	lda	$3A,x
	cmp	#$18E0
	beq	loc_02F628
	jsr	a:sub_02F834
	rtl
loc_02F628:
	lda	#$B000
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	#$0002
	sta	$12,x

sub_02F63C:
	lda	$3A,x
	cmp	#$1900
	beq	loc_02F660
	jsr	a:sub_02F834
	lda	$3A,x
	cmp	#$18E0
	bcs	loc_02F650
	; (not executed in the CDL traces)
	brl	clear_topdown_slot
loc_02F650:
	lda	a:wram_1900
	sta	$0A,x
	lda	a:wram_1902
	sta	$0E,x
	jsr	a:sub_02F7C6
	sta	$04,x
	rtl
loc_02F660:
	lda	#$0003
	sta	$12,x

sub_02F665:
	jsr	a:sub_02F834
	lda	$3A,x
	cmp	#$1900
	bcc	loc_02F628
	jsr	a:sub_02F7C6
	sta	$04,x
	rtl
loc_02F675:
	stz	$16,x
	jsl	f:sub_029D0C
	rtl

sub_02F67C:
	lda	a:wram_0B50
	bne	loc_02F684
	; (not executed in the CDL traces)
	brl	clear_topdown_slot
loc_02F684:
	jsr	a:sub_02F753
	jsr	a:sub_02F745
	bcc	loc_02F68F
	brl	loc_02F719
loc_02F68F:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02F69E,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F69E:
	.addr	sub_02F6A8
	.addr	sub_02F6C3
	.addr	sub_02F6EA
	.addr	sub_02F70E
	.addr	sub_02F729

sub_02F6A8:
	stz	$16,x
	stz	$2E,x
	stz	$00,x
	stz	$02,x
	stz	$2A,x
	stz	$20,x
	stz	$28,x
	stz	$08,x
	stz	$0C,x
	stz	$06,x
	stz	$04,x
	lda	#$0001
	sta	$12,x

sub_02F6C3:
	lda	a:wram_0B52
	cmp	#$0002
	bcc	loc_02F6D5
	lda	$3A,x
	cmp	#$18E0
	beq	loc_02F6D6
	jsr	a:sub_02F834
loc_02F6D5:
	rtl
loc_02F6D6:
	lda	#$B000
	sta	$16,x
	lda	#$018C
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	#$0002
	sta	$12,x

sub_02F6EA:
	lda	$3A,x
	cmp	#$1900
	beq	loc_02F709
	jsr	a:sub_02F834
	lda	$3A,x
	cmp	#$18E0
	bcs	loc_02F6FE
	brl	clear_topdown_slot
loc_02F6FE:
	lda	a:wram_1900
	sta	$0A,x
	lda	a:wram_1902
	sta	$0E,x
	rtl
loc_02F709:
	lda	#$0003
	sta	$12,x

sub_02F70E:
	jsr	a:sub_02F834
	lda	$3A,x
	cmp	#$1900
	bcc	loc_02F6D6
	rtl
loc_02F719:
	lda	$12,x
	cmp	#$0004
	beq	sub_02F729
	stz	$16,x
	stz	$24,x
	lda	#$0004
	sta	$12,x

sub_02F729:
	inc	$24,x
	lda	$24,x
	cmp	#$0010
	bcc	loc_02F735
	brl	clear_topdown_slot
loc_02F735:
	lsr	a
	and	#$0006
	tay
	lda	a:data_05E6BC,y
	sta	$00,x
	lda	a:data_05E6C4,y
	sta	$02,x
	rtl

sub_02F745:
	lda	a:wram_0AC6
	bmi	loc_02F751
	lda	a:wram_0B46
	bmi	loc_02F751
	clc
	rts
loc_02F751:
	sec
	rts

sub_02F753:
	lda	a:wram_0B46
	clc
	adc	$06,x
	sta	a:wram_0B46
	stz	$06,x
	rts

sub_02F75F:
	lda	a:wram_0B50
	ora	a:wram_0B90
	ora	a:wram_0BD0
	ora	a:wram_0C10
	ora	a:wram_0C50
	ora	a:wram_0C90
	ora	a:wram_0CD0
	ora	a:wram_0D10
	ora	a:wram_0D50
	ora	a:wram_0D90
	ora	a:wram_0DD0
	ora	a:wram_0E10
	ora	a:wram_0E50
	ora	a:wram_0E90
	rts

sub_02F78A:
	sta	zp_FA
	jsr	a:sub_02F7B1
	sec
	sbc	$04,x
	beq	loc_02F7A3
	bit	#$0080
	bne	loc_02F7A5
	lda	$04,x
	clc
	adc	zp_FA
	and	#$00FF
	sta	$04,x
loc_02F7A3:
	sec
	rts
loc_02F7A5:
	lda	$04,x
	sec
	sbc	zp_FA
	and	#$00FF
	sta	$04,x
	sec
	rts

sub_02F7B1:
	sec
	lda	a:wram_0AFE
	sbc	$0A,x
	sta	zp_08
	sec
	lda	a:wram_0AFC
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	rts

sub_02F7C6:
	sec
	lda	$0A,x
	sbc	a:wram_0E8A
	sta	zp_08
	sec
	lda	$0E,x
	sbc	a:wram_0E8E
	sta	zp_0A
	jsl	f:calc_angle
	rts

sub_02F7DB:
	sec
	lda	$0A,x
	sbc	a:wram_0BCA
	sta	zp_08
	sec
	lda	$0E,x
	sbc	a:wram_0BCE
	sta	zp_0A
	jsl	f:calc_angle
	rts

sub_02F7F0:
	lda	a:wram_0B52
	cmp	#$0005
	beq	loc_02F821
	cmp	#$0003
	beq	loc_02F806
	; (not executed in the CDL traces)
	lda	$3A,x
	clc
	adc	#$0004
	sta	$3A,x
	rts
loc_02F806:
	ldy	$3A,x
	cpy	#$1B00
	bcc	loc_02F810
	ldy	#$1900
loc_02F810:
	lda	$0A,x
	sta	a:$0000,y
	iny
	iny
	lda	$0E,x
	sta	a:$0000,y
	iny
	iny
	sty	$3A,x
	rts
loc_02F821:
	; (not executed in the CDL traces)
	ldy	$3A,x
	dey
	dey
	lda	$0E,x
	sta	a:$0000,y
	dey
	dey
	lda	$0A,x
	sta	a:$0000,y
	sty	$3A,x
	rts

sub_02F834:
	lda	a:wram_0B52
	cmp	#$0005
	beq	loc_02F85C
	cmp	#$0003
	bne	loc_02F85B
	ldy	$3A,x
	cpy	#$1B00
	bcc	loc_02F84B
	ldy	#$1900
loc_02F84B:
	lda	a:$0000,y
	sta	$0A,x
	iny
	iny
	lda	a:$0000,y
	sta	$0E,x
	iny
	iny
	sty	$3A,x
loc_02F85B:
	rts
loc_02F85C:
	ldy	$3A,x
	dey
	dey
	lda	a:$0000,y
	sta	$0E,x
	dey
	dey
	lda	a:$0000,y
	sta	$0A,x
	sty	$3A,x
	rts

sub_02F86F:
	lda	$2E,x
	bit	#$0003
	beq	loc_02F8D3
	jsl	f:sub_029BC2
	bcs	loc_02F8D3
	lda	#$000E
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$02,x
	and	#$3000
	sta	a:$0002,y
	lda	$04,x
	sta	a:$0004,y
	phy
	ldy	#$000C
	jsl	f:polar_to_xy
	ply
	lda	$0A,x
	clc
	adc	zp_08
	sta	a:$000A,y
	lda	$0E,x
	clc
	adc	zp_0A
	sta	a:$000E,y
	lda	#$0000
	sta	a:$0008,y
	sta	a:$000C,y
	lda	a:$0004,y
	ora	#$FF00
	sta	a:$0004,y
	phx
	phy
	tyx
	jsl	f:sub_02B1A3
	ply
	plx
	lda	a:wram_159E
	clc
	adc	#$0EC0
	sta	a:$0014,y
loc_02F8D3:
	rtl

sub_02F8D4:
	lda	$06,x
	bpl	loc_02F8DB
	brl	loc_02F98A
loc_02F8DB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02F8EA,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02F8EA:
	.addr	sub_02F8F6
	.addr	sub_02F912
	.addr	sub_02F94B
	.addr	sub_02F963
	.addr	sub_02F97D
	.addr	sub_02F9A4

sub_02F8F6:
	ldy	difficulty
	lda	a:data_05E6CC,y
	sta	$06,x
	stz	$2E,x
	stz	$24,x
	stz	$28,x
loc_02F903:
	lda	#$0001
	sta	$20,x
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	$12,x

sub_02F912:
	dec	$24,x
	bmi	loc_02F917
	rtl
loc_02F917:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02F921
loc_02F920:
	rtl
loc_02F921:
	jsl	f:sub_029B77
	bcs	loc_02F920
	lda	#$0006
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	stx	$3A,y
	lda	#$0002
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02F94B:
	dec	$24,x
	beq	loc_02F950
	rtl
loc_02F950:
	lda	#$0003
	sta	$20,x
	stz	$2A,x
	lda	#$B000
	sta	$16,x
	lda	#$0080
	sta	$24,x
	inc	$12,x

sub_02F963:
	dec	$24,x
	bmi	loc_02F96C
	jsl	f:sub_02F9C7
	rtl
loc_02F96C:
	lda	#$0002
	sta	$20,x
	lda	#$8000
	sta	$16,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02F97D:
	dec	$24,x
	bpl	loc_02F989
	lda	#$0040
	sta	$24,x
	brl	loc_02F903
loc_02F989:
	rtl
loc_02F98A:
	lda	#$0030
	jsl	f:queue_sound
	stz	$06,x
	stz	$16,x
	lda	#$0003
	sta	$20,x
	lda	#$0040
	sta	$24,x
	lda	#$0005
	sta	$12,x

sub_02F9A4:
	dec	$24,x
	bmi	loc_02F9B4
	lda	$24,x
	bit	#$0003
	bne	loc_02F9B3
	jsl	f:sub_02AC72
loc_02F9B3:
	rtl
loc_02F9B4:
	lda	#$0007
	sta	$20,x
	cmp	$28,x
	bne	loc_02F9B3
	jsl	f:sub_02AC8F
	bcs	loc_02F9B3
	jml	f:clear_topdown_slot

sub_02F9C7:
	lda	$2A,x
	bne	loc_02F9EA
	lda	$2E,x
	bit	#$0040
	beq	loc_02F9F5
	lda	#$0010
	jsl	f:queue_sound
	lda	$20,x
	sta	$2A,x
	lda	#$0006
	sta	$20,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rtl
loc_02F9EA:
	sta	$20,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_02F9F5:
	rtl

sub_02F9F6:
	lda	$06,x
	bpl	loc_02F9FD
	brl	loc_02FAA0
loc_02F9FD:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FA0C,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FA0C:
	.addr	sub_02FA18
	.addr	sub_02FA35
	.addr	sub_02FA61
	.addr	sub_02FA79
	.addr	sub_02FA93
	.addr	sub_02FABA

sub_02FA18:
	ldy	difficulty
	lda	a:data_05E6D2,y
	sta	$06,x
	stz	$2E,x
	stz	$28,x
	stz	$24,x
loc_02FA25:
	lda	#$0050
	sta	$20,x
	lda	#$8000
	sta	$16,x
	lda	#$0001
	sta	$12,x
	rtl

sub_02FA35:
	dec	$24,x
	bmi	loc_02FA3A
	rtl
loc_02FA3A:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02FA44
loc_02FA43:
	rtl
loc_02FA44:
	lda	#$0010
	jsr	a:sub_02FC71
	bcs	loc_02FA43
	lda	a:$0004,y
	eor	#$0080
	sta	a:$0004,y
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FA61:
	dec	$24,x
	beq	loc_02FA66
	rtl
loc_02FA66:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000
	sta	$16,x
	lda	#$0080
	sta	$24,x
	inc	$12,x

sub_02FA79:
	dec	$24,x
	bmi	loc_02FA82
	jsl	f:sub_02FC9C
	rtl
loc_02FA82:
	lda	#$005B
	sta	$20,x
	lda	#$8000
	sta	$16,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FA93:
	dec	$24,x
	bpl	loc_02FA9F
	lda	#$0040
	sta	$24,x
	brl	loc_02FA25
loc_02FA9F:
	rtl
loc_02FAA0:
	lda	#$0030
	jsl	f:queue_sound
	stz	$06,x
	stz	$16,x
	lda	#$0059
	sta	$20,x
	lda	#$0040
	sta	$24,x
	lda	#$0005
	sta	$12,x

sub_02FABA:
	dec	$24,x
	bmi	loc_02FACA
	lda	$24,x
	bit	#$0003
	bne	loc_02FAC9
	jsl	f:sub_02AC72
loc_02FAC9:
	rtl
loc_02FACA:
	lda	#$0057
	sta	$20,x
	cmp	$28,x
	bne	loc_02FAC9
	jsl	f:sub_02AC8F
	bcs	loc_02FAC9
	jml	f:clear_topdown_slot

sub_02FADD:
	lda	$06,x
	bpl	loc_02FAE4
	brl	loc_02FAA0
loc_02FAE4:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FAF3,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FAF3:
	.addr	sub_02FA18
	.addr	sub_02FAFF
	.addr	sub_02FB2B
	.addr	sub_02FA79
	.addr	sub_02FA93
	.addr	sub_02FABA

sub_02FAFF:
	dec	$24,x
	bmi	loc_02FB04
	rtl
loc_02FB04:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02FB0E
loc_02FB0D:
	rtl
loc_02FB0E:
	lda	#$0009
	jsr	a:sub_02FC71
	bcs	loc_02FB0D
	lda	a:$0004,y
	eor	#$0080
	sta	a:$0004,y
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FB2B:
	dec	$24,x
	bne	loc_02FB32
	brl	loc_02FA66
loc_02FB32:
	rtl

sub_02FB33:
	lda	$06,x
	bpl	loc_02FB3A
	brl	loc_02FAA0
loc_02FB3A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FB49,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FB49:
	.addr	sub_02FA18
	.addr	sub_02FB55
	.addr	sub_02FB78
	.addr	sub_02FA79
	.addr	sub_02FA93
	.addr	sub_02FABA

sub_02FB55:
	dec	$24,x
	bmi	loc_02FB5A
	rtl
loc_02FB5A:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02FB64
loc_02FB63:
	rtl
loc_02FB64:
	lda	#$0011
	jsr	a:sub_02FC71
	bcs	loc_02FB63
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FB78:
	dec	$24,x
	bne	loc_02FB7F
	brl	loc_02FA66
loc_02FB7F:
	rtl

sub_02FB80:
	lda	$06,x
	bpl	loc_02FB87
	; (not executed in the CDL traces)
	brl	loc_02FAA0
loc_02FB87:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FB96,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FB96:
	.addr	sub_02FA18
	.addr	sub_02FBA2
	.addr	sub_02FBD4
	.addr	sub_02FA79
	.addr	sub_02FA93
	.addr	sub_02FABA

sub_02FBA2:
	dec	$24,x
	bmi	loc_02FBA7
	; (not executed in the CDL traces)
	rtl
loc_02FBA7:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02FBB1
loc_02FBB0:
	rtl
loc_02FBB1:
	; (not executed in the CDL traces)
	jsl	f:sub_02B1A3
	ldy	a:wram_159E
	lda	a:$152C,y
	bit	#$4000
	bne	loc_02FBB0
	lda	#$0010
	jsr	a:sub_02FC71
	bcs	loc_02FBB0
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FBD4:
	; (not executed in the CDL traces)
	dec	$24,x
	bne	loc_02FBDB
	brl	loc_02FBDC
loc_02FBDB:
	rtl
loc_02FBDC:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000
	sta	$16,x
	ldy	difficulty
	lda	a:data_05E6D8,y
	sta	$24,x
	inc	$12,x
	jmp	a:sub_02FA79

sub_02FBF4:
	lda	$06,x
	bpl	loc_02FBFB
	; (not executed in the CDL traces)
	brl	loc_02FAA0
loc_02FBFB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FC0A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FC0A:
	.addr	sub_02FA18
	.addr	sub_02FC16
	.addr	sub_02FC51
	.addr	sub_02FA79
	.addr	sub_02FA93
	.addr	sub_02FABA

sub_02FC16:
	dec	$24,x
	bmi	loc_02FC1B
	rtl
loc_02FC1B:
	stz	$24,x
	lda	$2E,x
	bit	#$0030
	bne	loc_02FC25
loc_02FC24:
	rtl
loc_02FC25:
	jsl	f:sub_02B1A3
	jsl	f:sub_029B06
	ldy	a:wram_159E
	sec
	sbc	a:$0EC4,y
	clc
	adc	#$0040
	bit	#$0080
	bne	loc_02FC24
	lda	#$0010
	jsr	a:sub_02FC71
	bcs	loc_02FC24
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

sub_02FC51:
	dec	$24,x
	bne	loc_02FC58
	brl	loc_02FC59
loc_02FC58:
	rtl
loc_02FC59:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000
	sta	$16,x
	ldy	difficulty
	lda	a:data_05E6DE,y
	sta	$24,x
	inc	$12,x
	jmp	a:sub_02FA79

sub_02FC71:
	pha
	jsl	f:sub_029B77
	bcc	loc_02FC7B
	; (not executed in the CDL traces)
	pla
	sec
	rts
loc_02FC7B:
	pla
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	stx	$3A,y
	phy
	jsl	f:sub_029B06
	ply
	sta	a:$0004,y
	clc
	rts

sub_02FC9C:
	lda	$2A,x
	bne	loc_02FCBF
	lda	$2E,x
	bit	#$0040
	beq	loc_02FCCA
	lda	#$0010
	jsl	f:queue_sound
	lda	$20,x
	sta	$2A,x
	lda	#$0074
	sta	$20,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rtl
loc_02FCBF:
	sta	$20,x
	stz	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
loc_02FCCA:
	rtl
