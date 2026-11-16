; objects/secondary_objects.asm -- Player shots (the secondary object list)
; Bank $00, $00:E1B8-$00:E368. Included by main.asm in segment BANK00.
;
; update_shots (once per frame from the stage loop) runs the 40 shot slots
; of SHOT_SIZE ($20) bytes at $0AC0-$0FBF: calls each shot's handler
; through tbl_shot_types, draws and moves it, and tests it against the
; objects of the target list (damage to enemies).  The shots are spawned
; by objects/player_shots.asm; their handlers are in object_handlers_00b.

; The player shot loop (secondary list, SHOT_SIZE slots at $0AC0-$0FBF):
; calls each shot's handler (call_shot_handler), draws it (draw_shot; in
; 2-player games only every other frame per player), adds its velocity,
; frees it when off the screen, then tests its box (x..x+10, y..y+10)
; against every object of the target list at $15A0.  On a hit:
; target OBJ_HIT = SHOT_TYPE and, for an OBJF_TARGET object that is not
; OBJF_INVULNERABLE, OBJ_HP -= SHOT_DAMAGE; when OBJ_HP goes negative,
; SHOT_HIT = the new HP and the shooter scores type_scores[OBJ_TYPE]
; (add_score_for_player_obj); otherwise SHOT_HIT = 1 (sound $10 if OBJF_CLANG).
; A shot with SHOT_DAMAGE 0 hits nothing.  Each player's shots are tested
; every other frame only: player 1's ($0AC0-$0D3F) when stage_frame_odd = 1,
; player 2's when stage_frame_odd = 0.
; Runs the shots: player 1's ($0480-$06FF), player 2's ($0700-$097F) and the
; others ($0300-$047F), by type + 8 (tbl_shot_types).
update_shots:
	ldx	#$0AC0
@loop:
	lda	SHOT_TYPE,x
	bne	@active
@next_shot:
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcc	@loop
	rtl
@active:
	jsl	f:call_shot_handler
	lda	a:title_menu_cursor
	beq	@draw
	lda	stage_frame_odd
	beq	@even_frame
	cpx	#$0D40
	bcc	@draw
	bcs	@move
@even_frame:
	cpx	#$0D40
	bcc	@move
@draw:
	lda	SHOT_ATTR,x
	beq	@move
	ldy	oam_ptr
	jsr	a:draw_shot
@move:
	clc
	lda	OBJ_Y_SUB,x
	adc	OBJ_Y_VEL_SUB,x
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	adc	OBJ_Y_VEL,x
	sta	OBJ_Y,x
	clc
	lda	OBJ_X_SUB,x
	adc	OBJ_X_VEL_SUB,x
	sta	OBJ_X_SUB,x
	lda	OBJ_X,x
	adc	OBJ_X_VEL,x
	sta	OBJ_X,x
	ldy	SHOT_ATTR,x
	beq	@next_shot
	cmp	#$00F8
	bcs	@free_shot
	lda	OBJ_Y,x
	cmp	#$FFC0	; [num]
	bcs	@check_hits
	cmp	#$00F0
	bcc	@check_hits
@free_shot:
	phx
	stz	$00,x
	txy
	iny
	lda	#$001E
	mvn	#^tables_05, #^tables_05
	plx
	bra	@next_shot
@check_hits:
	lda	SHOT_DAMAGE,x
	beq	@next_shot
	lda	stage_frame_odd
	bne	@odd_frame
	cpx	#$0D40
	bcs	@test_targets
	bcc	@next_shot
@odd_frame:
	cpx	#$0D40
	bcs	@next_shot
@test_targets:
	lda	OBJ_X,x
	adc	#$000A
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$000A
	sta	zp_02
	txy
	ldx	#$159E
	phx
@next_target:
	plx
	inx
	inx
	lda	$00,x
	beq	@shot_done
	phx
	tax
	lda	OBJ_HP,x
	bmi	@next_target
	lda	zp_00
	cmp	OBJ_X,x
	bmi	@next_target
	lda	a:OBJ_Y,y
	cmp	OBJ_Y,x
	bpl	@next_target
	lda	zp_02
	cmp	OBJ_HITBOX_TOP,x
	bmi	@next_target
	lda	a:OBJ_X,y
	cmp	OBJ_HITBOX_RIGHT,x
	bpl	@next_target
	pla
	lda	a:SHOT_TYPE,y
	sta	OBJ_HIT,x
	lda	OBJ_FLAGS,x
	bit	#OBJF_TARGET
	beq	@not_destroyed
	bit	#OBJF_INVULNERABLE
	bne	@not_destroyed
.if CHEAT_DAMAGE_MULT > 1
	jsl	f:cheat_shot_damage	; cheat: A = OBJ_HP - n * SHOT_DAMAGE
.else
	sec
	lda	OBJ_HP,x
	sbc	a:SHOT_DAMAGE,y
.endif
	sta	OBJ_HP,x
	bpl	@not_destroyed
	sta	a:SHOT_HIT,y
	phy
	lda	OBJ_TYPE,x
	asl	a
	tay
	lda	a:type_scores,y
	ply
	phx
	ldx	#$0200
	cpy	#$0D40
	bcc	@have_player
	ldx	#$0240
@have_player:
	jsl	f:add_score_for_player_obj
	plx
	bra	@shot_done
@not_destroyed:
	lda	OBJ_FLAGS,x
	bit	#OBJF_CLANG
	beq	@set_hit
	lda	#$0010
	jsl	f:queue_sound
@set_hit:
	lda	#$0001
	sta	a:SHOT_HIT,y
@shot_done:
	tyx
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcs	@return
	brl	@loop
@return:
	rtl

; Writes one OAM entry for the shot at X from SHOT_ATTR (SHOTA_LARGE: 16x16
; at x, y; else 8x8 at x+4, y+4).  In: Y = oam_ptr.
draw_shot:
	bit	#SHOTA_LARGE
	beq	@small
	lda	OBJ_X,x
	cmp	#$00FE
	bcs	@return
	and	#$00FF
	sta	zp_08
	lda	OBJ_Y,x
	cmp	#$00F0
	bcs	@return
	and	#$00FF
	xba
	ora	zp_08
	sta	a:$0000,y
	lda	SHOT_ATTR,x
	and	#$FEFF
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	clc
	ror	oam_hi_bits
	sec
	ror	oam_hi_bits
	bcc	@advance_oam
@flush_hi_bits:
	phx
	ldx	oam_hi_ptr
	lda	oam_hi_bits
	sta	$00,x
	inx
	inx
	lda	#$8000	; [num]
	sta	oam_hi_bits
	stx	oam_hi_ptr
	plx
@advance_oam:
	sty	oam_ptr
@return:
	rts
@small:
	lda	OBJ_X,x
	adc	#$0004
	cmp	#$00FE
	bcs	@return
	and	#$00FF
	sta	zp_08
	lda	OBJ_Y,x
	adc	#$0004
	cmp	#$00F4
	bcs	@return
	and	#$00FF
	xba
	ora	zp_08
	sta	a:$0000,y
	lda	SHOT_ATTR,x
	sta	a:$0002,y
	iny
	iny
	iny
	iny
	clc
	ror	oam_hi_bits
	clc
	ror	oam_hi_bits
	bcc	@advance_oam
	bcs	@flush_hi_bits

; Jumps (JML) to the handler of shot type A in tbl_shot_types.
call_shot_handler:
	sta	zp_00
	asl	a
	clc
	adc	zp_00
	tay
	lda	a:tbl_shot_types,y
	sta	zp_00
	lda	a:tbl_shot_types+2,y
	sta	zp_02
	jml	[zp_00]
