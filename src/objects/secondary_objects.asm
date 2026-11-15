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
; (sub_00B829); otherwise SHOT_HIT = 1 (sound $10 if OBJF_CLANG).
; A shot with SHOT_DAMAGE 0 hits nothing.  Each player's shots are tested
; every other frame only: player 1's ($0AC0-$0D3F) when zp_BC = 1,
; player 2's when zp_BC = 0.
update_shots:
	ldx	#$0AC0
loc_00E1BB:
	lda	SHOT_TYPE,x
	bne	loc_00E1CB
loc_00E1BF:
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcc	loc_00E1BB
	rtl
loc_00E1CB:
	jsl	f:call_shot_handler
	lda	a:title_menu_cursor
	beq	loc_00E1E4
	lda	zp_BC
	beq	loc_00E1DF
	cpx	#$0D40
	bcc	loc_00E1E4
	bcs	loc_00E1ED
loc_00E1DF:
	cpx	#$0D40
	bcc	loc_00E1ED
loc_00E1E4:
	lda	SHOT_ATTR,x
	beq	loc_00E1ED
	ldy	oam_ptr
	jsr	a:draw_shot
loc_00E1ED:
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
	beq	loc_00E1BF
	cmp	#$00F8
	bcs	loc_00E21C
	lda	OBJ_Y,x
	cmp	#$FFC0
	bcs	loc_00E22A
	cmp	#$00F0
	bcc	loc_00E22A
loc_00E21C:
	phx
	stz	$00,x
	txy
	iny
	lda	#$001E
	mvn	#$05, #$05
	plx
	bra	loc_00E1BF
loc_00E22A:
	lda	SHOT_DAMAGE,x
	beq	loc_00E1BF
	lda	zp_BC
	bne	loc_00E239
	cpx	#$0D40
	bcs	loc_00E23E
	bcc	loc_00E1BF
loc_00E239:
	cpx	#$0D40
	bcs	loc_00E1BF
loc_00E23E:
	lda	OBJ_X,x
	adc	#$000A
	sta	zp_00
	lda	OBJ_Y,x
	adc	#$000A
	sta	zp_02
	txy
	ldx	#$159E
	phx
loc_00E251:
	plx
	inx
	inx
	lda	$00,x
	beq	loc_00E2C7
	phx
	tax
	lda	OBJ_HP,x
	bmi	loc_00E251
	lda	zp_00
	cmp	OBJ_X,x
	bmi	loc_00E251
	lda	a:OBJ_Y,y
	cmp	OBJ_Y,x
	bpl	loc_00E251
	lda	zp_02
	cmp	OBJ_HITBOX_TOP,x
	bmi	loc_00E251
	lda	a:OBJ_X,y
	cmp	OBJ_HITBOX_RIGHT,x
	bpl	loc_00E251
	pla
	lda	a:SHOT_TYPE,y
	sta	OBJ_HIT,x
	lda	OBJ_FLAGS,x
	bit	#OBJF_TARGET
	beq	loc_00E2B3
	bit	#OBJF_INVULNERABLE
	bne	loc_00E2B3
	sec
	lda	OBJ_HP,x
	sbc	a:SHOT_DAMAGE,y
	sta	OBJ_HP,x
	bpl	loc_00E2B3
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
	bcc	loc_00E2AC
	ldx	#$0240
loc_00E2AC:
	jsl	f:sub_00B829
	plx
	bra	loc_00E2C7
loc_00E2B3:
	lda	OBJ_FLAGS,x
	bit	#OBJF_CLANG
	beq	loc_00E2C1
	lda	#$0010
	jsl	f:queue_sound
loc_00E2C1:
	lda	#$0001
	sta	a:SHOT_HIT,y
loc_00E2C7:
	tyx
	clc
	txa
	adc	#$0020
	tax
	cmp	#$0FC0
	bcs	loc_00E2D6
	brl	loc_00E1BB
loc_00E2D6:
	rtl

; Writes one OAM entry for the shot at X from SHOT_ATTR (SHOTA_LARGE: 16x16
; at x, y; else 8x8 at x+4, y+4).  In: Y = oam_ptr.
draw_shot:
	bit	#SHOTA_LARGE
	beq	loc_00E320
	lda	OBJ_X,x
	cmp	#$00FE
	bcs	loc_00E31F
	and	#$00FF
	sta	zp_08
	lda	OBJ_Y,x
	cmp	#$00F0
	bcs	loc_00E31F
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
	bcc	loc_00E31D
loc_00E30C:
	phx
	ldx	oam_hi_ptr
	lda	oam_hi_bits
	sta	$00,x
	inx
	inx
	lda	#$8000
	sta	oam_hi_bits
	stx	oam_hi_ptr
	plx
loc_00E31D:
	sty	oam_ptr
loc_00E31F:
	rts
loc_00E320:
	lda	OBJ_X,x
	adc	#$0004
	cmp	#$00FE
	bcs	loc_00E31F
	and	#$00FF
	sta	zp_08
	lda	OBJ_Y,x
	adc	#$0004
	cmp	#$00F4
	bcs	loc_00E31F
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
	bcc	loc_00E31D
	bcs	loc_00E30C

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
