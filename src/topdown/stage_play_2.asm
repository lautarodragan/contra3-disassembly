; topdown/stage_play_2.asm -- Top-down stages: gameplay (part 2)
; Bank $02, $02:E65F-$02:FCCA. Included by main.asm in segment BANK02.
;
; More code of the top-down stages (reached from the state handlers): bombs,
; views, scoring, HDMA/IRQ setup, compute_m7_matrix (run by their NMI frame
; handler), the stage 5 boss and its arm, the stage 5 nests and the stage 2
; gun hatches (map objects).

; Runs the two smart bomb objects ($0F40 player 1, $0F80 player 2).
td_update_bombs:
	ldx	#$0F40
@loop:
	jsr	a:td_update_bomb
	txa
	clc
	adc	#$0040
	tax
	cpx	#$0FC0
	bcc	@loop
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
	lda	a:.loword($000A - $0080),x	; x of the player (X - $80) that threw the bomb X
	sta	$0A,x
	lda	a:.loword($000E - $0080),x	; and its y
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
	sta	a:td_p1_x
	stz	a:td_p1_x_frac
	lda	a:p1_view_y
	sta	a:td_p1_y
	stz	a:td_p1_y_frac
	lda	a:p2_view_x
	sta	a:td_p2_x
	stz	a:td_p2_x_frac
	lda	a:p2_view_y
	sta	a:td_p2_y
	stz	a:td_p2_y_frac
	stz	a:p1_view_angle_frozen
	stz	a:p2_view_angle_frozen
	stz	a:p1_facing_in_view
	stz	a:p2_facing_in_view
	stz	a:p1_view_angle
	stz	a:p2_view_angle
	stz	a:td_p1_state
	stz	a:td_p2_state
	stz	a:td_p1_angle
	stz	a:td_p2_angle
	rtl
loc_02E723:
	lda	#$0080
	sta	a:p1_view_anchor_x
	lda	#$00A0
	sta	a:p1_view_anchor_y
	lda	a:p1_view_x
	sta	a:td_p1_x
	stz	a:td_p1_x_frac
	lda	a:p1_view_y
	sta	a:td_p1_y
	stz	a:td_p1_y_frac
	stz	a:p1_view_angle_frozen
	stz	a:p1_view_angle
	stz	a:p1_facing_in_view
	stz	a:td_p1_state
	stz	a:td_p1_angle
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
	sta	a:td_p1_x
	stz	a:td_p1_x_frac
	lda	a:p1_view_y
	sta	a:td_p1_y
	stz	a:td_p1_y_frac
	lda	a:p2_view_x
	sta	a:td_p2_x
	stz	a:td_p2_x_frac
	lda	a:p2_view_y
	sta	a:td_p2_y
	stz	a:td_p2_y_frac
	stz	a:p1_view_angle_frozen
	stz	a:p2_view_angle_frozen
	stz	a:p1_view_angle
	stz	a:p2_view_angle
	lda	#$0040
	sta	a:p1_facing_in_view
	sta	a:p2_facing_in_view
	stz	a:td_p1_state
	stz	a:td_p2_state
	lda	#$0040
	sta	a:td_p1_angle
	sta	a:td_p2_angle
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
	lda	a:td_p1_x
	sta	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_m7_hofs
	lda	a:td_p1_y
	sta	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_m7_vofs
	lda	a:p1_view_angle_frozen
	bne	loc_02E7FB
	lda	a:td_p1_angle
	sta	a:p1_view_angle
loc_02E7FB:
	lda	a:p1_view_angle
	eor	#$00FF
	inc	a
	and	#$00FF
	sta	a:p1_m7_angle
	rtl
loc_02E809:
	lda	a:td_p1_x
	sta	a:p1_view_x
	lda	a:td_p1_y
	sta	a:p1_view_y
	lda	a:p1_view_angle_frozen
	bne	loc_02E820
	lda	a:td_p1_angle
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
	jsl	f:project_around_stage2_boss
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
	lda	a:td_boss_angle
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
	lda	a:td_p1_x
	sta	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	a:p1_view_anchor_x
	sta	a:p1_m7_hofs
	lda	a:td_p1_y
	sta	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	a:p1_view_anchor_y
	sta	a:p1_m7_vofs
	lda	a:p1_view_angle_frozen
	bne	loc_02E8A7
	lda	a:td_p1_angle
	sec
	sbc	a:p1_facing_in_view
	and	#$00FF
	sta	a:p1_view_angle
loc_02E8A7:
	lda	a:p1_view_angle
	eor	#$00FF
	inc	a
	and	#$00FF
	sta	a:p1_m7_angle
	lda	a:td_p2_x
	sta	a:p2_view_x
	sta	a:p2_m7_center_x
	sec
	sbc	a:p2_view_anchor_x
	sta	a:p2_m7_hofs
	lda	a:td_p2_y
	sta	a:p2_view_y
	sta	a:p2_m7_center_y
	sec
	sbc	a:p2_view_anchor_y
	sta	a:p2_m7_vofs
	lda	a:p2_view_angle_frozen
	bne	loc_02E8E6
	lda	a:td_p2_angle
	sec
	sbc	a:p2_facing_in_view
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
	lda	a:td_p1_x
	sta	a:p1_view_x
	lda	a:td_p1_y
	sta	a:p1_view_y
	lda	a:p1_view_angle_frozen
	bne	loc_02E912
	lda	a:td_p1_angle
	sec
	sbc	a:p1_facing_in_view
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
	jsl	f:project_around_stage2_boss
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
	lda	a:td_boss_angle
	sec
	sbc	a:p1_view_angle
	eor	#$0080
	sta	a:p1_m7_angle
loc_02E95E:
	lda	a:td_p2_x
	sta	a:p2_view_x
	lda	a:td_p2_y
	sta	a:p2_view_y
	lda	a:p2_view_angle_frozen
	bne	loc_02E97C
	lda	a:td_p2_angle
	sec
	sbc	a:p2_facing_in_view
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
	jsl	f:project_around_stage2_boss
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
	lda	a:td_boss_angle
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
	jsr	a:td_scroll_shared_view_x
	lda	a:p1_view_x
	sta	a:p1_m7_center_x
	sec
	sbc	#$0080
	sta	a:p1_m7_hofs
	lda	#$0080
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	jsr	a:td_scroll_shared_view_y
	lda	a:p1_view_y
	sta	a:p1_m7_center_y
	sec
	sbc	#$007C
	sta	a:p1_m7_vofs
	lda	#$007C
	sta	a:p1_view_anchor_y
	sta	a:p2_view_anchor_y
	lda	a:p1_view_angle_frozen
	bne	loc_02EA0E
	lda	a:td_p1_angle
	sta	a:p1_facing_in_view
loc_02EA0E:
	lda	a:p2_view_angle_frozen
	bne	loc_02EA19
	lda	a:td_p2_angle
	sta	a:p2_facing_in_view
loc_02EA19:
	stz	a:p1_m7_angle
	rtl
loc_02EA1D:
	jsr	a:td_scroll_shared_view_x
	lda	#$0080
	sta	a:p1_view_anchor_x
	sta	a:p2_view_anchor_x
	jsr	a:td_scroll_shared_view_y
	lda	#$007C
	sta	a:p1_view_anchor_y
	sta	a:p2_view_anchor_y
	lda	a:p1_view_angle_frozen
	bne	loc_02EA40
	lda	a:td_p1_angle
	sta	a:p1_facing_in_view
loc_02EA40:
	lda	a:p2_view_angle_frozen
	bne	loc_02EA4B
	lda	a:td_p2_angle
	sta	a:p2_facing_in_view
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
	jsl	f:project_around_stage2_boss
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
	lda	a:td_boss_angle
	sec
	sbc	a:p1_view_angle
	eor	#$0080
	sta	a:p1_m7_angle
loc_02EAA3:
	rtl

td_scroll_shared_view_x:
	; (not executed in the CDL traces)
	jsr	a:td_shared_view_bounds_x
	jsr	a:td_shared_view_follow_p1_x
	jsr	a:td_shared_view_follow_p2_x
	rts

td_shared_view_follow_p1_x:
	; (not executed in the CDL traces)
	lda	a:td_p1_state
	beq	loc_02EAC0
	lda	a:td_p1_x
	cmp	zp_18
	beq	loc_02EABC
	bpl	loc_02EAD4
loc_02EABC:
	cmp	zp_1A
	bmi	loc_02EAE0
loc_02EAC0:
	rts

td_shared_view_follow_p2_x:
	; (not executed in the CDL traces)
	lda	a:td_p2_state
	beq	loc_02EAD3
	lda	a:td_p2_x
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
	bra	td_shared_view_bounds_x
loc_02EAE0:
	clc
	adc	#$0048
	sta	a:p1_view_x
	sta	a:p2_view_x

td_shared_view_bounds_x:
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

td_scroll_shared_view_y:
	; (not executed in the CDL traces)
	jsr	a:td_shared_view_bounds_y
	jsr	a:td_shared_view_follow_p1_y
	jsr	a:td_shared_view_follow_p2_y
	rts

td_shared_view_follow_p1_y:
	; (not executed in the CDL traces)
	lda	a:p1_lives
	beq	loc_02EB19
	lda	a:td_p1_y
	cmp	zp_18
	beq	loc_02EB15
	bpl	loc_02EB2D
loc_02EB15:
	cmp	zp_1A
	bmi	loc_02EB39
loc_02EB19:
	rts

td_shared_view_follow_p2_y:
	; (not executed in the CDL traces)
	lda	a:p2_lives
	beq	loc_02EB2C
	lda	a:td_p2_y
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
	bra	td_shared_view_bounds_y
loc_02EB39:
	clc
	adc	#$002C
	sta	a:p1_view_y
	sta	a:p2_view_y

td_shared_view_bounds_y:
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
	lda	a:td_p2_state
	beq	loc_02EB74
	jml	f:td_run_p2_collisions
loc_02EB6B:
	lda	a:td_p1_state
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

td_score_enemy_kill:
	; (not executed in the CDL traces)
	phx
	jsr	a:td_score_enemy_kill_2
	plx
	rtl

td_score_enemy_kill_2:
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
	ldx	#.loword(hdma_table_05E496)
	ldy	#$38E0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E49F)
	ldy	#$38C0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4A8)
	ldy	#$38A0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4B1)
	ldy	#$3880
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4BA)
	ldy	#$3860
	lda	#$001F
	jsr	a:copy_hdma_table
	rtl
loc_02EC71:
	ldx	#.loword(hdma_table_05E4C3)
	ldy	#$38E0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4CC)
	ldy	#$38C0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4D5)
	ldy	#$38A0
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4DE)
	ldy	#$3880
	lda	#$001F
	jsr	a:copy_hdma_table
	ldx	#.loword(hdma_table_05E4E7)
	ldy	#$3860
	lda	#$001F
	jsr	a:copy_hdma_table
	rtl

; MVN of A+1 bytes from $05:X to $7E:Y.
copy_hdma_table:
	phb
	mvn	#^tables_05, #$7E
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

; TDMT_STAGE5_BOSS ($0AC0): the stage 5 boss, a creature in a sand pit
; drawn as the Mode 7 layer. It sends out its arm (stage5_boss_spawn_arm:
; TDT_STAGE5_BOSS_CLAW, TDT_STAGE5_BOSS_ARM_BASE, 12
; TDT_STAGE5_BOSS_ARM_SEGMENT) towards a player, spits shots from the
; pit's edge (stage5_boss_update_spit), and the funnel (TDA_SAND_PIT)
; pulls the players in. HP 512/1024/2048 (stage5_boss_hp). Checked in the
; emulator.
update_stage5_boss:
	jsl	f:stage5_boss_run_state
	jsr	a:stage5_boss_animate_body
	jsr	a:stage5_boss_update_palette_cycle
	jsr	a:stage5_boss_update_spit
	jsr	a:stage5_boss_flash_on_hit
	jsl	f:stage5_boss_stream_chr
	rtl

stage5_boss_run_state:
	lda	$06,x
	bpl	loc_02EFA9
	brl	loc_02F09A
loc_02EFA9:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_states:
	.addr	stage5_boss_state_0
	.addr	stage5_boss_state_1
	.addr	stage5_boss_state_2
	.addr	stage5_boss_state_3
	.addr	stage5_boss_state_4
	.addr	stage5_boss_state_5
	.addr	stage5_boss_state_6
	.addr	stage5_boss_state_7
	.addr	stage5_boss_state_8
	.addr	stage5_boss_state_9

stage5_boss_state_0:
	ldy	difficulty
	lda	a:stage5_boss_hp,y
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
	stz	a:stage5_boss_body_step
	stz	a:stage5_boss_palette_step
	stz	a:stage5_boss_spit_step
loc_02EFF1:
	jsr	a:stage5_boss_spawn_arm
	lda	#$0040
	sta	$24,x
	lda	#$0001
	sta	$12,x

stage5_boss_state_1:
	dec	$24,x
	bmi	loc_02F003
	rtl
loc_02F003:
	lda	#$0040
	sta	$24,x
	lda	#$0002
	sta	$12,x

stage5_boss_state_2:
	dec	$24,x
	bmi	loc_02F015
	jsr	a:stage5_boss_target_player
	rtl
loc_02F015:
	ldy	difficulty
	lda	a:stage5_boss_hp,y
	lsr	a
	cmp	$06,x
	bcc	loc_02F031
	jsl	f:td_select_target_player_long
	lda	a:boss_target_distance
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

stage5_boss_state_3:
	dec	$24,x
	bmi	loc_02F043
	jsr	a:stage5_boss_target_player
	rtl
loc_02F043:
	lda	#$0040
	sta	$24,x
	lda	#$0004
	sta	$12,x

stage5_boss_state_4:
	dec	$24,x
	bmi	loc_02F052
	rtl
loc_02F052:
	lda	#$0005
	sta	$12,x

stage5_boss_state_5:
	jsr	a:stage5_boss_check_arm_out
	bne	@return
	brl	loc_02EFF1
@return:
	rtl
loc_02F060:
	lda	#$0006
	sta	$12,x

stage5_boss_state_6:
	jsr	a:stage5_boss_check_arm_out
	bne	loc_02F06D
	brl	loc_02EFF1
loc_02F06D:
	jsl	f:td_select_target_player_long
	lda	a:boss_target_distance
	cmp	#$4000
	bcs	loc_02F07D
	jsr	a:stage5_boss_target_circle
	rtl
loc_02F07D:
	lda	#$0007
	sta	$12,x

stage5_boss_state_7:
	jsr	a:stage5_boss_check_arm_out
	bne	loc_02F08A
	; (not executed in the CDL traces)
	brl	loc_02EFF1
loc_02F08A:
	jsl	f:td_select_target_player_long
	lda	a:boss_target_distance
	cmp	#$4000
	bcc	loc_02F060
	jsr	a:stage5_boss_target_player
	rtl
loc_02F09A:
	lda	#$0008
	cmp	$12,x
	beq	stage5_boss_state_8
	sta	$12,x
	stz	$16,x
	lda	#$0200
	sta	$24,x
	sta	a:screen_shake_timer
	lda	#$0002
	sta	a:screen_shake_offset

stage5_boss_state_8:
	jsl	f:td_play_rumble_sound
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
	sta	a:td_map_objects+1*OBJ_SIZE+OBJ_X
	lda	rng_lo
	and	#$003F
	sec
	sbc	#$0020
	clc
	adc	$0E,x
	sta	a:td_map_objects+1*OBJ_SIZE+OBJ_Y
	phx
	ldx	#$0B00
	jsl	f:td_spawn_explosion_effect
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

stage5_boss_state_9:
	lda	$24,x
	and	#$0003
	bne	loc_02F106
	jsl	f:td_spawn_explosion_effect
loc_02F106:
	dec	$24,x
	rtl

stage5_boss_animate_body:
	lda	a:td_boss_state
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
	lda	a:stage5_boss_body_step
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_body_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_body_steps:
	.addr	stage5_boss_body_step_0
	.addr	stage5_boss_body_step_1
	.addr	stage5_boss_body_step_2
	.addr	stage5_boss_body_step_3

stage5_boss_body_step_0:
	; (not executed in the CDL traces)
	stz	a:boss_anim_frame
loc_02F14F:
	lda	#$0001
	sta	a:stage5_boss_body_step

stage5_boss_body_step_1:
	lda	a:boss_anim_frame
	bne	loc_02F160
	lda	#$1000
	sta	$16,x
	rts
loc_02F160:
	dec	a:boss_anim_frame
	rts
loc_02F164:
	lda	#$0002
	sta	a:stage5_boss_body_step

stage5_boss_body_step_2:
	lda	a:boss_anim_frame
	cmp	#$0017
	bcc	loc_02F17E
	lda	#$0017
	sta	a:boss_anim_frame
	lda	#$B000	; [num]
	sta	$16,x
	rts
loc_02F17E:
	inc	a:boss_anim_frame
	rts
loc_02F182:
	lda	#$0003
	sta	a:stage5_boss_body_step

stage5_boss_body_step_3:
	lda	#$0018
	sta	a:boss_anim_frame
	rts

stage5_boss_stream_chr:
	lda	#$3200
	sta	a:boss_chr_stream_vram
	lda	#$007E
	sta	a:boss_chr_stream_bank
	lda	#$0280
	sta	a:boss_chr_stream_size
	lda	a:boss_anim_frame
	lsr	a
	lsr	a
	and	#$0006
	tay
	lda	a:stage5_boss_chr_sources,y
	sta	a:boss_chr_stream_src
	rtl

stage5_boss_update_palette_cycle:
	lda	a:stage5_boss_palette_step
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_palette_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_palette_steps:
	.addr	stage5_boss_palette_step_0
	.addr	stage5_boss_palette_step_1
	.addr	stage5_boss_palette_step_2

stage5_boss_palette_step_0:
	stz	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	lda	#$0001
	sta	a:palette_cycle_paused
	lda	#$0001
	sta	a:stage5_boss_palette_step

stage5_boss_palette_step_1:
	lda	a:td_boss_state
	cmp	#$0008
	bcs	@return
	ldy	difficulty
	lda	a:stage5_boss_hp,y
	lsr	a
	cmp	$06,x
	bcs	loc_02F1EC
@return:
	rts
loc_02F1EC:
	lda	#$0008
	sta	a:stage5_boss_cycle_pause
	sta	a:palette_cycle_paused
	lda	#$0100
	sta	a:palette_cycle_speed
	stz	a:palette_cycle_counter
	lda	#$0002
	sta	a:stage5_boss_palette_step

stage5_boss_palette_step_2:
	lda	a:stage5_boss_cycle_pause
	beq	loc_02F21C
	lda	a:palette_cycle_paused
	bne	loc_02F219
	dec	a:stage5_boss_cycle_pause
	lda	a:stage5_boss_cycle_pause
	sta	a:palette_cycle_paused
	bra	loc_02F21C
loc_02F219:
	dec	a:palette_cycle_paused
loc_02F21C:
	lda	a:td_boss_state
	cmp	#$0008
	bcs	stage5_boss_palette_step_0
	rts

stage5_boss_target_player:
	jsl	f:td_select_target_player_long
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sta	$3E,x
	lda	a:$0ECE,y
	sta	$3C,x
	rts

stage5_boss_target_circle:
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

stage5_boss_update_spit:
	lda	a:td_boss_hp
	bpl	loc_02F25F
	brl	loc_02F306
loc_02F25F:
	lda	a:stage5_boss_spit_step
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_spit_steps,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_spit_steps:
	.addr	stage5_boss_spit_step_0
	.addr	stage5_boss_spit_step_1
	.addr	stage5_boss_spit_step_2
	.addr	stage5_boss_spit_step_3
	.addr	stage5_boss_spit_step_4
loc_02F279:
	stz	a:stage5_boss_spit_step

stage5_boss_spit_step_0:
	lda	a:td_boss_state
	cmp	#$0006
	beq	loc_02F285
	rts
loc_02F285:
	lda	#$003A
	jsl	f:queue_sound
	lda	rng_lo
	and	#$0006
	sta	a:stage5_boss_spit_position
	lda	#$0020
	sta	a:stage5_boss_spit_timer
	lda	#$0300
	jsr	a:stage5_boss_spawn_spit
	stz	a:td_enemy_shots+$14
	lda	#$0001
	sta	a:stage5_boss_spit_step

stage5_boss_spit_step_1:
	dec	a:stage5_boss_spit_timer
	bmi	loc_02F2AF
	rts
loc_02F2AF:
	stz	a:stage5_boss_spit_timer
	lda	#$0002
	sta	a:stage5_boss_spit_step

stage5_boss_spit_step_2:
	lda	a:stage5_boss_spit_timer
	inc	a:stage5_boss_spit_timer
	cmp	#$0020
	bcs	loc_02F2DC
	bit	#$0003
	bne	@return
	lsr	a
	and	#$000E
	tay
	lda	a:stage5_boss_spit_slots,y
	tay
	lda	#$0001
	sta	a:$0014,y
	tya
	jsr	a:stage5_boss_spawn_spit
@return:
	rts
loc_02F2DC:
	lda	#$0000
	sta	a:stage5_boss_spit_timer
	stz	a:td_enemy_shots+$14
	stz	a:td_enemy_shots+1*SHOT_SIZE+$14
	stz	a:td_enemy_shots+2*SHOT_SIZE+$14
	stz	a:td_enemy_shots+3*SHOT_SIZE+$14
	stz	a:td_enemy_shots+4*SHOT_SIZE+$14
	stz	a:td_enemy_shots+5*SHOT_SIZE+$14
	stz	a:td_enemy_shots+6*SHOT_SIZE+$14
	stz	a:td_enemy_shots+7*SHOT_SIZE+$14
	lda	#$0003
	sta	a:stage5_boss_spit_step

stage5_boss_spit_step_3:
	dec	a:stage5_boss_spit_timer
	bmi	loc_02F306
	; (not executed in the CDL traces)
	rts
loc_02F306:
	lda	#$0020
	sta	a:stage5_boss_spit_timer
	lda	#$0002
	sta	a:td_enemy_shots+OBJ_STATE
	sta	a:td_enemy_shots+1*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+2*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+3*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+4*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+5*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+6*SHOT_SIZE+OBJ_STATE
	sta	a:td_enemy_shots+7*SHOT_SIZE+OBJ_STATE
	lda	#$0004
	sta	a:stage5_boss_spit_step

stage5_boss_spit_step_4:
	dec	a:stage5_boss_spit_timer
	bpl	@return
	brl	loc_02F279
@return:
	rts

stage5_boss_spawn_spit:
	phx
	tax
	lda	#TDS_BOSS_SPIT
	sta	$10,x
	stz	$12,x
	lda	#$2000
	sta	$02,x
	ldy	a:stage5_boss_spit_position
	lda	a:stage5_boss_pit_edge_x,y
	sta	$0A,x
	stz	$08,x
	lda	a:stage5_boss_pit_edge_y,y
	sta	$0E,x
	stz	$0C,x
	lda	a:stage5_boss_spit_velocity_x,y
	sta	$1A,x
	stz	$18,x
	lda	a:stage5_boss_spit_velocity_y,y
	sta	$1E,x
	stz	$1C,x
	plx
	rts

stage5_boss_flash_on_hit:
	lda	a:stage5_boss_flash_counter
	inc	a:stage5_boss_flash_counter
	lsr	a
	and	#$0006
	tay
	lda	a:ptrs_stage5_boss_flash_palettes,y
	sta	zp_00
	lda	#$22A0
	sta	zp_02
	lda	#$0020
	sta	zp_04
	lda	$2A,x
	beq	loc_02F390
	jsr	a:stage5_boss_restore_palette
	dec	$2A,x
	lda	$2E,x
	and	#$FFBF
	sta	$2E,x
	rts
loc_02F390:
	lda	$2E,x
	bit	#$0040
	beq	stage5_boss_restore_palette
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

stage5_boss_restore_palette:
	phx
	phb
	ldx	zp_00
	ldy	zp_02
	lda	zp_04
	mvn	#^gfx_08, #$7E
	plb
	plx
	rts

stage5_boss_spawn_arm:
	jsl	f:td_select_target_player_long
	ldy	a:boss_target_player
	lda	a:$0ECA,y
	sec
	sbc	$0A,x
	sta	zp_08
	lda	a:$0ECE,y
	sec
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	sta	a:td_map_objects+2*OBJ_SIZE+OBJ_ANGLE
	clc
	adc	#$0020
	asl	a
	asl	a
	xba
	asl	a
	and	#$0006
	tay
	lda	a:stage5_boss_pit_edge_x,y
	sta	a:td_map_objects+2*OBJ_SIZE+OBJ_X
	lda	a:stage5_boss_pit_edge_y,y
	sta	a:td_map_objects+2*OBJ_SIZE+OBJ_Y
	lda	#TDT_STAGE5_BOSS_CLAW
	sta	a:td_map_objects+2*OBJ_SIZE+OBJ_TYPE
	lda	#TDT_STAGE5_BOSS_ARM_BASE
	sta	a:td_map_objects+3*OBJ_SIZE+OBJ_TYPE
	lda	#TDT_STAGE5_BOSS_ARM_SEGMENT
	sta	a:td_map_objects+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_map_objects+5*OBJ_SIZE+OBJ_TYPE
	sta	a:td_map_objects+6*OBJ_SIZE+OBJ_TYPE
	sta	a:td_map_objects+7*OBJ_SIZE+OBJ_TYPE
	sta	a:td_map_objects+8*OBJ_SIZE+OBJ_TYPE
	sta	a:td_map_objects+9*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+OBJ_TYPE
	sta	a:td_enemies+1*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+2*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	sta	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	stz	a:td_map_objects+2*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+3*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+4*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+5*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+6*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+7*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+8*OBJ_SIZE+OBJ_STATE
	stz	a:td_map_objects+9*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+OBJ_STATE
	stz	a:td_enemies+1*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+2*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+3*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+4*OBJ_SIZE+OBJ_STATE
	stz	a:td_enemies+5*OBJ_SIZE+OBJ_STATE
	sec
	lda	#$1900
	sta	a:td_map_objects+2*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+4*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+5*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+6*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+7*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+8*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+9*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_enemies+$3A
	sbc	#$0020
	sta	a:td_enemies+1*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_enemies+2*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_enemies+3*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_enemies+4*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_enemies+5*OBJ_SIZE+$3A
	sbc	#$0020
	sta	a:td_map_objects+3*OBJ_SIZE+$3A
	rts

; TDT_STAGE5_BOSS_CLAW ($0B40): the claw at the end of the stage 5 boss's
; arm: turns to its target, reaches out recording its trail, fires
; TDS_HOMING_ORB, pulls back. Damage to any arm part counts against its HP,
; 32/128/256 (stage5_boss_claw_hp); destroyed, it drops an item.
update_stage5_boss_claw:
	lda	a:td_boss_hp
	bpl	loc_02F4C0
	brl	loc_02F5B6
loc_02F4C0:
	jsr	a:stage5_boss_arm_check_dead
	bcc	loc_02F4C8
	brl	loc_02F5B6
loc_02F4C8:
	lda	a:td_boss_state
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
	lda	f:tbl_stage5_boss_claw_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_claw_states:
	.addr	stage5_boss_claw_state_0
	.addr	stage5_boss_claw_state_1
	.addr	stage5_boss_claw_state_2
	.addr	stage5_boss_claw_state_3
	.addr	stage5_boss_claw_state_4
	.addr	stage5_boss_claw_state_5
	.addr	stage5_boss_claw_state_6

stage5_boss_claw_state_0:
	ldy	difficulty
	lda	a:stage5_boss_claw_hp,y
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
	beq	stage5_boss_claw_state_1
	sta	$12,x

stage5_boss_claw_state_1:
	rtl
loc_02F532:
	lda	#$0002
	cmp	$12,x
	beq	stage5_boss_claw_state_2
	sta	$12,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	$0A,x
	sta	a:wram_1900
	lda	$0E,x
	sta	a:wram_1902

stage5_boss_claw_state_2:
	lda	#$0002
	jsr	a:stage5_boss_claw_turn_to_target
	rtl
loc_02F55B:
	lda	#$0003
	cmp	$12,x
	beq	stage5_boss_claw_state_3
	sta	$12,x

stage5_boss_claw_state_3:
	lda	#$0002
	jsr	a:stage5_boss_claw_turn_to_target
	lda	#$0020
	jsl	f:td_move_at_angle
	jsr	a:stage5_boss_claw_record_trail
	rtl
loc_02F575:
	lda	#$0004
	cmp	$12,x
	beq	stage5_boss_claw_state_4
	sta	$12,x

stage5_boss_claw_state_4:
	lda	a:td_map_objects+$24
	cmp	#$0010
	bne	@return
	jsl	f:stage5_boss_claw_fire
@return:
	rtl
loc_02F58B:
	lda	#$0005
	cmp	$12,x
	beq	stage5_boss_claw_state_5
	sta	$12,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x

stage5_boss_claw_state_5:
	jsr	a:stage5_boss_arm_angle_from_head
	sta	$04,x
	jsr	a:stage5_boss_arm_follow_trail
	lda	$3A,x
	cmp	#$1900
	bcs	@return
	brl	clear_topdown_slot
@return:
	rtl
loc_02F5B6:
	lda	#$0006
	cmp	$12,x
	beq	stage5_boss_claw_state_6
	sta	$12,x
	lda	#$0030
	jsl	f:queue_sound
	stz	$16,x

stage5_boss_claw_state_6:
	lda	zp_EB
	and	#$0002
	sta	$14,x
	jsl	f:td_spawn_item_drop
	jsl	f:td_start_explosion
	rtl

; TDT_STAGE5_BOSS_ARM_BASE ($0B80): the end of the stage 5 boss's arm in the pit.
update_stage5_boss_arm_base:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_TYPE
	bne	loc_02F5E0
	brl	clear_topdown_slot
loc_02F5E0:
	jsr	a:stage5_boss_arm_pass_damage
	jsr	a:stage5_boss_arm_check_dead
	bcc	loc_02F5EB
	brl	loc_02F675
loc_02F5EB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_arm_base_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_arm_base_states:
	.addr	stage5_boss_arm_base_state_0
	.addr	stage5_boss_arm_base_state_1
	.addr	stage5_boss_arm_base_state_2
	.addr	stage5_boss_arm_base_state_3

stage5_boss_arm_base_state_0:
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

stage5_boss_arm_base_state_1:
	lda	$3A,x
	cmp	#$18E0
	beq	loc_02F628
	jsr	a:stage5_boss_arm_follow_trail
	rtl
loc_02F628:
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0011
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	#$0002
	sta	$12,x

stage5_boss_arm_base_state_2:
	lda	$3A,x
	cmp	#$1900
	beq	loc_02F660
	jsr	a:stage5_boss_arm_follow_trail
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
	jsr	a:stage5_boss_arm_angle_from_tail
	sta	$04,x
	rtl
loc_02F660:
	lda	#$0003
	sta	$12,x

stage5_boss_arm_base_state_3:
	jsr	a:stage5_boss_arm_follow_trail
	lda	$3A,x
	cmp	#$1900
	bcc	loc_02F628
	jsr	a:stage5_boss_arm_angle_from_tail
	sta	$04,x
	rtl
loc_02F675:
	stz	$16,x
	jsl	f:td_start_explosion
	rtl

; TDT_STAGE5_BOSS_ARM_SEGMENT: one of the 12 segments of the stage 5 boss's
; arm; follows the claw's trail.
update_stage5_boss_arm_segment:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_TYPE
	bne	loc_02F684
	; (not executed in the CDL traces)
	brl	clear_topdown_slot
loc_02F684:
	jsr	a:stage5_boss_arm_pass_damage
	jsr	a:stage5_boss_arm_check_dead
	bcc	loc_02F68F
	brl	loc_02F719
loc_02F68F:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_stage5_boss_arm_segment_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_stage5_boss_arm_segment_states:
	.addr	stage5_boss_arm_segment_state_0
	.addr	stage5_boss_arm_segment_state_1
	.addr	stage5_boss_arm_segment_state_2
	.addr	stage5_boss_arm_segment_state_3
	.addr	stage5_boss_arm_segment_state_4

stage5_boss_arm_segment_state_0:
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

stage5_boss_arm_segment_state_1:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_STATE
	cmp	#$0002
	bcc	@return
	lda	$3A,x
	cmp	#$18E0
	beq	loc_02F6D6
	jsr	a:stage5_boss_arm_follow_trail
@return:
	rtl
loc_02F6D6:
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$018C
	sta	$00,x
	lda	#$2000
	sta	$02,x
	lda	#$0002
	sta	$12,x

stage5_boss_arm_segment_state_2:
	lda	$3A,x
	cmp	#$1900
	beq	loc_02F709
	jsr	a:stage5_boss_arm_follow_trail
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

stage5_boss_arm_segment_state_3:
	jsr	a:stage5_boss_arm_follow_trail
	lda	$3A,x
	cmp	#$1900
	bcc	loc_02F6D6
	rtl
loc_02F719:
	lda	$12,x
	cmp	#$0004
	beq	stage5_boss_arm_segment_state_4
	stz	$16,x
	stz	$24,x
	lda	#$0004
	sta	$12,x

stage5_boss_arm_segment_state_4:
	inc	$24,x
	lda	$24,x
	cmp	#$0010
	bcc	loc_02F735
	brl	clear_topdown_slot
loc_02F735:
	lsr	a
	and	#$0006
	tay
	lda	a:stage5_boss_arm_segment_death_sprites,y
	sta	$00,x
	lda	a:stage5_boss_arm_segment_death_attrs,y
	sta	$02,x
	rtl

stage5_boss_arm_check_dead:
	lda	a:td_boss_hp
	bmi	loc_02F751
	lda	a:td_boss_core_hp
	bmi	loc_02F751
	clc
	rts
loc_02F751:
	sec
	rts

stage5_boss_arm_pass_damage:
	lda	a:td_boss_core_hp
	clc
	adc	$06,x
	sta	a:td_boss_core_hp
	stz	$06,x
	rts

stage5_boss_check_arm_out:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+3*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+4*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+5*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+6*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+7*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+8*OBJ_SIZE+OBJ_TYPE
	ora	a:td_map_objects+9*OBJ_SIZE+OBJ_TYPE
	ora	a:td_enemies+OBJ_TYPE
	ora	a:td_enemies+1*OBJ_SIZE+OBJ_TYPE
	ora	a:td_enemies+2*OBJ_SIZE+OBJ_TYPE
	ora	a:td_enemies+3*OBJ_SIZE+OBJ_TYPE
	ora	a:td_enemies+4*OBJ_SIZE+OBJ_TYPE
	ora	a:td_enemies+5*OBJ_SIZE+OBJ_TYPE
	rts

stage5_boss_claw_turn_to_target:
	sta	zp_FA
	jsr	a:stage5_boss_claw_angle_to_target
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

stage5_boss_claw_angle_to_target:
	sec
	lda	a:td_map_objects+$3E
	sbc	$0A,x
	sta	zp_08
	sec
	lda	a:td_map_objects+$3C
	sbc	$0E,x
	sta	zp_0A
	jsl	f:calc_angle
	rts

stage5_boss_arm_angle_from_tail:
	sec
	lda	$0A,x
	sbc	a:td_enemies+5*OBJ_SIZE+OBJ_X
	sta	zp_08
	sec
	lda	$0E,x
	sbc	a:td_enemies+5*OBJ_SIZE+OBJ_Y
	sta	zp_0A
	jsl	f:calc_angle
	rts

stage5_boss_arm_angle_from_head:
	sec
	lda	$0A,x
	sbc	a:td_map_objects+4*OBJ_SIZE+OBJ_X
	sta	zp_08
	sec
	lda	$0E,x
	sbc	a:td_map_objects+4*OBJ_SIZE+OBJ_Y
	sta	zp_0A
	jsl	f:calc_angle
	rts

stage5_boss_claw_record_trail:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_STATE
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

stage5_boss_arm_follow_trail:
	lda	a:td_map_objects+2*OBJ_SIZE+OBJ_STATE
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

stage5_boss_claw_fire:
	lda	$2E,x
	bit	#$0003
	beq	@return
	jsl	f:td_find_free_enemy_shot_slot
	bcs	@return
	lda	#TDS_HOMING_ORB
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
	jsl	f:td_select_target_player_long
	ply
	plx
	lda	a:boss_target_player
	clc
	adc	#$0EC0
	sta	a:$0014,y
@return:
	rtl

; TDMT_NEST, stage 5 target: a nest in the sand; when a player is near it
; opens and lets out a TDT_NEST_CRAWLER. HP 32/80/128 (td_nest_hp);
; destroyed, it may drop an item.
update_td_nest:
	lda	$06,x
	bpl	loc_02F8DB
	brl	loc_02F98A
loc_02F8DB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_td_nest_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_td_nest_states:
	.addr	td_nest_state_0
	.addr	td_nest_state_1
	.addr	td_nest_state_2
	.addr	td_nest_state_3
	.addr	td_nest_state_4
	.addr	td_nest_state_5

td_nest_state_0:
	ldy	difficulty
	lda	a:td_nest_hp,y
	sta	$06,x
	stz	$2E,x
	stz	$24,x
	stz	$28,x
loc_02F903:
	lda	#$0001
	sta	$20,x
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0001
	sta	$12,x

td_nest_state_1:
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
	jsl	f:td_get_hatch_enemy_slot
	bcs	loc_02F920
	lda	#TDT_NEST_CRAWLER
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

td_nest_state_2:
	dec	$24,x
	beq	loc_02F950
	rtl
loc_02F950:
	lda	#$0003
	sta	$20,x
	stz	$2A,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0080
	sta	$24,x
	inc	$12,x

td_nest_state_3:
	dec	$24,x
	bmi	loc_02F96C
	jsl	f:td_nest_flash_on_hit
	rtl
loc_02F96C:
	lda	#$0002
	sta	$20,x
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

td_nest_state_4:
	dec	$24,x
	bpl	@return
	lda	#$0040
	sta	$24,x
	brl	loc_02F903
@return:
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

td_nest_state_5:
	dec	$24,x
	bmi	loc_02F9B4
	lda	$24,x
	bit	#$0003
	bne	loc_02F9B3
	jsl	f:td_spawn_explosion_effect
loc_02F9B3:
	rtl
loc_02F9B4:
	lda	#$0007
	sta	$20,x
	cmp	$28,x
	bne	loc_02F9B3
	jsl	f:td_spawn_item_drop
	bcs	loc_02F9B3
	jml	f:clear_topdown_slot

td_nest_flash_on_hit:
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

; TDMT_GUN_HATCH_AIM, stage 2 target: a hatch in the floor (map blocks $50
; closed, $5B opening, $59 open, $57 destroyed). When a player is near, it
; opens and lets out a TDT_HATCH_TURRET_AIM, stays open $80 frames
; (hittable), closes for $40. HP 32/80/128 (gun_hatch_hp); destroyed, it
; may drop an item. Checked in the emulator.
update_gun_hatch_aim:
	lda	$06,x
	bpl	loc_02F9FD
	brl	loc_02FAA0
loc_02F9FD:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_gun_hatch_aim_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_gun_hatch_aim_states:
	.addr	gun_hatch_state_0
	.addr	gun_hatch_aim_state_1
	.addr	gun_hatch_aim_state_2
	.addr	gun_hatch_state_3
	.addr	gun_hatch_state_4
	.addr	gun_hatch_state_5

gun_hatch_state_0:
	ldy	difficulty
	lda	a:gun_hatch_hp,y
	sta	$06,x
	stz	$2E,x
	stz	$28,x
	stz	$24,x
loc_02FA25:
	lda	#$0050
	sta	$20,x
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0001
	sta	$12,x
	rtl

gun_hatch_aim_state_1:
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
	lda	#TDT_HATCH_TURRET_AIM
	jsr	a:gun_hatch_spawn_turret
	bcs	loc_02FA43
	lda	a:$0004,y
	eor	#$0080
	sta	a:$0004,y
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_aim_state_2:
	dec	$24,x
	beq	loc_02FA66
	rtl
loc_02FA66:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000	; [num]
	sta	$16,x
	lda	#$0080
	sta	$24,x
	inc	$12,x

gun_hatch_state_3:
	dec	$24,x
	bmi	loc_02FA82
	jsl	f:gun_hatch_flash_on_hit
	rtl
loc_02FA82:
	lda	#$005B
	sta	$20,x
	lda	#$8000	; [num]
	sta	$16,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_state_4:
	dec	$24,x
	bpl	@return
	lda	#$0040
	sta	$24,x
	brl	loc_02FA25
@return:
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

gun_hatch_state_5:
	dec	$24,x
	bmi	loc_02FACA
	lda	$24,x
	bit	#$0003
	bne	loc_02FAC9
	jsl	f:td_spawn_explosion_effect
loc_02FAC9:
	rtl
loc_02FACA:
	lda	#$0057
	sta	$20,x
	cmp	$28,x
	bne	loc_02FAC9
	jsl	f:td_spawn_item_drop
	bcs	loc_02FAC9
	jml	f:clear_topdown_slot

; TDMT_GUN_HATCH_SPIN, stage 2 target: as TDMT_GUN_HATCH_AIM with a
; TDT_HATCH_TURRET_SPIN.
update_gun_hatch_spin:
	lda	$06,x
	bpl	loc_02FAE4
	brl	loc_02FAA0
loc_02FAE4:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_gun_hatch_spin_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_gun_hatch_spin_states:
	.addr	gun_hatch_state_0
	.addr	gun_hatch_spin_state_1
	.addr	gun_hatch_spin_state_2
	.addr	gun_hatch_state_3
	.addr	gun_hatch_state_4
	.addr	gun_hatch_state_5

gun_hatch_spin_state_1:
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
	lda	#TDT_HATCH_TURRET_SPIN
	jsr	a:gun_hatch_spawn_turret
	bcs	loc_02FB0D
	lda	a:$0004,y
	eor	#$0080
	sta	a:$0004,y
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_spin_state_2:
	dec	$24,x
	bne	@return
	brl	loc_02FA66
@return:
	rtl

; TDMT_GUN_HATCH_SWEEP, stage 2 target: as TDMT_GUN_HATCH_AIM with a
; TDT_HATCH_TURRET_SWEEP.
update_gun_hatch_sweep:
	lda	$06,x
	bpl	loc_02FB3A
	brl	loc_02FAA0
loc_02FB3A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_gun_hatch_sweep_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_gun_hatch_sweep_states:
	.addr	gun_hatch_state_0
	.addr	gun_hatch_sweep_state_1
	.addr	gun_hatch_sweep_state_2
	.addr	gun_hatch_state_3
	.addr	gun_hatch_state_4
	.addr	gun_hatch_state_5

gun_hatch_sweep_state_1:
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
	lda	#TDT_HATCH_TURRET_SWEEP
	jsr	a:gun_hatch_spawn_turret
	bcs	loc_02FB63
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_sweep_state_2:
	dec	$24,x
	bne	@return
	brl	loc_02FA66
@return:
	rtl

; TDMT_GUN_HATCH_NO_FIRE, stage 2 target (HARD sets): opens only while the
; nearest player does not hold Y; stays open gun_hatch_no_fire time.
update_gun_hatch_no_fire:
	lda	$06,x
	bpl	loc_02FB87
	; (not executed in the CDL traces)
	brl	loc_02FAA0
loc_02FB87:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_gun_hatch_no_fire_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_gun_hatch_no_fire_states:
	.addr	gun_hatch_state_0
	.addr	gun_hatch_no_fire_state_1
	.addr	gun_hatch_no_fire_state_2
	.addr	gun_hatch_state_3
	.addr	gun_hatch_state_4
	.addr	gun_hatch_state_5

gun_hatch_no_fire_state_1:
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
	jsl	f:td_select_target_player_long
	ldy	a:boss_target_player
	lda	a:$152C,y
	bit	#$4000
	bne	loc_02FBB0
	lda	#TDT_HATCH_TURRET_AIM
	jsr	a:gun_hatch_spawn_turret
	bcs	loc_02FBB0
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_no_fire_state_2:
	; (not executed in the CDL traces)
	dec	$24,x
	bne	@return
	brl	loc_02FBDC
@return:
	rtl
loc_02FBDC:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000	; [num]
	sta	$16,x
	ldy	difficulty
	lda	a:gun_hatch_no_fire_open_times,y
	sta	$24,x
	inc	$12,x
	jmp	a:gun_hatch_state_3

; TDMT_GUN_HATCH_BEHIND, stage 2 target (HARD sets): opens only when the
; nearest player faces away from it.
update_gun_hatch_behind:
	lda	$06,x
	bpl	loc_02FBFB
	; (not executed in the CDL traces)
	brl	loc_02FAA0
loc_02FBFB:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_gun_hatch_behind_states,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_gun_hatch_behind_states:
	.addr	gun_hatch_state_0
	.addr	gun_hatch_behind_state_1
	.addr	gun_hatch_behind_state_2
	.addr	gun_hatch_state_3
	.addr	gun_hatch_state_4
	.addr	gun_hatch_state_5

gun_hatch_behind_state_1:
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
	jsl	f:td_select_target_player_long
	jsl	f:td_angle_to_nearest_player
	ldy	a:boss_target_player
	sec
	sbc	a:$0EC4,y
	clc
	adc	#$0040
	bit	#$0080
	bne	loc_02FC24
	lda	#TDT_HATCH_TURRET_AIM
	jsr	a:gun_hatch_spawn_turret
	bcs	loc_02FC24
	lda	#$005B
	sta	$20,x
	lda	#$0008
	sta	$24,x
	inc	$12,x

gun_hatch_behind_state_2:
	dec	$24,x
	bne	@return
	brl	loc_02FC59
@return:
	rtl
loc_02FC59:
	lda	#$0059
	sta	$20,x
	stz	$2A,x
	lda	#$B000	; [num]
	sta	$16,x
	ldy	difficulty
	lda	a:gun_hatch_behind_open_times,y
	sta	$24,x
	inc	$12,x
	jmp	a:gun_hatch_state_3

gun_hatch_spawn_turret:
	pha
	jsl	f:td_get_hatch_enemy_slot
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
	jsl	f:td_angle_to_nearest_player
	ply
	sta	a:$0004,y
	clc
	rts

gun_hatch_flash_on_hit:
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
