; objects/object_loop.asm -- Object loop and type dispatcher
; Bank $00, $00:E960-$00:EB19. Included by main.asm in segment BANK00.
;
; The main object list: slots of OBJ_SIZE ($40) bytes from $0200 (players
; at $0200 and $0240; fields OBJ_* / PLAYER_* in ram.inc).  draw_players
; draws the players; update_objects runs slots $0300-$0ABF and
; update_objects_0280 slots $0280-$02FF: movement, the list of shot
; targets, contact with the players, animation, the type's handler through
; the 161 long pointers of tbl_object_types (call_object_handler), the hit
; flash and drawing.

; Draws both players' metasprites (OBJ_SPRITE) into the OAM buffer; the
; player drawn first alternates every frame (stage_frame_odd) so that neither is
; always hidden behind the other.
draw_players:
	ldx	#$0200
	lda	stage_frame_odd
	bne	loc_00E96A
	ldx	#$0240
loc_00E96A:
	ldy	OBJ_SPRITE,x
	beq	loc_00E971
	jsr	a:draw_metasprite
loc_00E971:
	txa
	eor	#$0040
	tax
	ldy	OBJ_SPRITE,x
	beq	loc_00E97D
	jsr	a:draw_metasprite
loc_00E97D:
	rtl

; Runs the two slots $0280 and $02C0 like update_objects (called after it,
; with target_list_end still pointing into the target list).
update_objects_0280:
	ldx	#$0280
	lda	#$0300
	sta	a:update_objects_stop
	bra	loc_00E997

; The main object loop: for each slot from $0300 up to update_objects_stop
; ($0AC0) whose OBJ_TYPE is not 0, in this order:
;   OBJF_MOVE: position += velocity, minus the BG scroll of this frame;
;   OBJF_OFFSCREEN_KILL: free the slot if outside -$20..$11F;
;   OBJF_TARGET: compute OBJ_HITBOX_RIGHT/TOP and append the slot to the
;     target list at $15A0 (target_list_end), read by the shots and the bomb;
;   OBJF_TOUCH: test the hitbox against the body of the player who goes
;     first this frame; on overlap OBJ_TOUCHED_BY = player, and unless the
;     player is invulnerable, OBJ_FLAGS is ORed into PLAYER_CONTACT (with the
;     barrier: OBJF_HARMFUL removed, and an OBJF_TARGET object loses 1 HP);
;   advance the animation script (OBJ_ANIM / OBJ_ANIM_TIMER -> OBJ_SPRITE);
;   call the type's handler (call_object_handler);
;   OBJF_DELETE: clear the slot; otherwise hit flash (OBJ_HIT -> palette 1
;     for a frame, OBJ_SAVED_ATTR), draw OBJ_SPRITE, clear OBJ_HIT.
; Ends the target list with 0.  In: A/X/Y 16-bit, DB = $05.
update_objects:
	lda	#$15A0
	sta	target_list_end
	lda	#$0AC0
	sta	a:update_objects_stop
	ldx	#$0300
loc_00E997:
	lda	OBJ_TYPE,x
	bne	loc_00E99E
	brl	loc_00EAF1
loc_00E99E:
	lda	OBJ_FLAGS,x
	bit	#OBJF_MOVE
	beq	loc_00E9C9
	clc
	lda	OBJ_X_SUB,x
	adc	OBJ_X_VEL_SUB,x
	sta	OBJ_X_SUB,x
	lda	OBJ_X,x
	adc	OBJ_X_VEL,x
	sec
	sbc	a:bg1_x_delta
	sta	OBJ_X,x
	clc
	lda	OBJ_Y_SUB,x
	adc	OBJ_Y_VEL_SUB,x
	sta	OBJ_Y_SUB,x
	lda	OBJ_Y,x
	adc	OBJ_Y_VEL,x
	sec
	sbc	a:bg1_y_delta
	sta	OBJ_Y,x
	lda	OBJ_FLAGS,x
loc_00E9C9:
	bit	#OBJF_OFFSCREEN_KILL
	beq	loc_00E9EE
	lda	OBJ_X,x
	cmp	#$0120
	bcc	loc_00E9DD
	cmp	#$FFE0
	bcs	loc_00E9DD
	brl	loc_00EAB0
loc_00E9DD:
	lda	OBJ_Y,x
	cmp	#$0120
	bcc	loc_00E9EC
	cmp	#$FFE0
	bcs	loc_00E9EC
	brl	loc_00EAB0
loc_00E9EC:
	lda	OBJ_FLAGS,x
loc_00E9EE:
	bit	#OBJF_TARGET
	beq	loc_00EA0B
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	sta	OBJ_HITBOX_RIGHT,x
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	sta	OBJ_HITBOX_TOP,x
	ldy	target_list_end
	txa
	sta	a:$0000,y
	inc	target_list_end
	inc	target_list_end
	lda	OBJ_FLAGS,x
loc_00EA0B:
	bit	#OBJF_TOUCH
	beq	loc_00EA76
	ldy	#$0200
	lda	stage_frame_odd
	beq	loc_00EA1A
	ldy	#$0240
loc_00EA1A:
	lda	a:OBJ_FLAGS,y
	beq	loc_00EA76
	lda	a:PLAYER_HITBOX_RIGHT,y
	cmp	OBJ_X,x
	bmi	loc_00EA76
	lda	a:PLAYER_HITBOX_TOP,y
	cmp	OBJ_Y,x
	bpl	loc_00EA76
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	cmp	a:PLAYER_HITBOX_LEFT,y
	bmi	loc_00EA76
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	cmp	a:PLAYER_HITBOX_BOTTOM,y
	bpl	loc_00EA76
	lda	a:OBJ_FLAGS,y
	bmi	loc_00EA76
	sty	OBJ_TOUCHED_BY,x
	bit	#PLAYERF_INVULNERABLE
	bne	loc_00EA76
	lda	a:PLAYER_BARRIER,y
	beq	loc_00EA6E
	lda	OBJ_FLAGS,x
	bit	#OBJF_TARGET
	beq	loc_00EA69
	; (not executed in the CDL traces)
	bit	#OBJF_INVULNERABLE
	bne	loc_00EA69
	lda	OBJ_HP,x
	bmi	loc_00EA67
	dec	OBJ_HP,x
	lda	#$0001
	sta	OBJ_HIT,x
loc_00EA67:
	lda	OBJ_FLAGS,x
loc_00EA69:
	and	#($FFFF ^ OBJF_HARMFUL)
	bra	loc_00EA70
loc_00EA6E:
	lda	OBJ_FLAGS,x
loc_00EA70:
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
loc_00EA76:
	ldy	OBJ_ANIM,x
	beq	loc_00EAA8
	dec	OBJ_ANIM_TIMER,x
	bmi	loc_00EA91
	bne	loc_00EAA8
	tya
	clc
	adc	#$0006
loc_00EA85:
	tay
	lda	a:$0000,y
	bmi	loc_00EA85
	beq	loc_00EA96
	sty	OBJ_ANIM,x
	bra	loc_00EA98
loc_00EA91:
	lda	a:$0000,y
	bne	loc_00EA98
loc_00EA96:
	sta	OBJ_ANIM,x
loc_00EA98:
	sta	OBJ_ANIM_TIMER,x
	lda	OBJ_FACING,x
	beq	loc_00EAA3
	lda	a:$0004,y
	bra	loc_00EAA6
loc_00EAA3:
	lda	a:$0002,y
loc_00EAA6:
	sta	OBJ_SPRITE,x
loc_00EAA8:
	jsl	f:call_object_handler
	lda	OBJ_FLAGS,x
	bpl	loc_00EABE
loc_00EAB0:
	phx
	stz	OBJ_SPRITE,x
	txy
	iny
	lda	#$003E
	mvn	#^tables_05, #^tables_05
	plx
	bra	loc_00EAF1
loc_00EABE:
	lda	OBJ_SAVED_ATTR,x
	bne	loc_00EADB
	lda	OBJ_HIT,x
	beq	loc_00EAE1
	lda	OBJ_FLAGS,x
	bit	#OBJF_INVULNERABLE
	bne	loc_00EAE1
	lda	OBJ_ATTR,x
	sta	OBJ_SAVED_ATTR,x
	and	#$3000
	ora	#$0200
	sta	OBJ_ATTR,x
	bra	loc_00EAE1
loc_00EADB:
	lda	OBJ_SAVED_ATTR,x
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
loc_00EAE1:
	ldy	OBJ_SPRITE,x
	beq	loc_00EAEF
	lda	oam_hi_ptr
	cmp	#$11E0
	bcs	loc_00EAEF
	jsr	a:draw_metasprite
loc_00EAEF:
	stz	OBJ_HIT,x
loc_00EAF1:
	clc
	txa
	adc	#$0040
	tax
	cmp	a:update_objects_stop
	bcs	loc_00EAFF
	brl	loc_00E997
loc_00EAFF:
	ldx	target_list_end
	stz	$00,x
	rtl

; Jumps (JML) to the handler of OBJ_TYPE,x in tbl_object_types; the handler
; returns with RTL to update_objects.  In: X = slot.
call_object_handler:
	lda	OBJ_TYPE,x
	sta	zp_00
	asl	a
	clc
	adc	zp_00
	tay
	lda	a:tbl_object_types,y
	sta	zp_00
	lda	a:tbl_object_types+2,y
	sta	zp_02
	jml	[zp_00]
