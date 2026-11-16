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
	bne	@draw_first
	ldx	#$0240
@draw_first:
	ldy	OBJ_SPRITE,x
	beq	@draw_second
	jsr	a:draw_metasprite
@draw_second:
	txa
	eor	#$0040
	tax
	ldy	OBJ_SPRITE,x
	beq	@return
	jsr	a:draw_metasprite
@return:
	rtl

; Runs the two slots $0280 and $02C0 like update_objects (called after it,
; with target_list_end still pointing into the target list).
update_objects_0280:
	ldx	#$0280
	lda	#$0300
	sta	a:update_objects_stop
	bra	update_object_slots

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
; The slot loop proper, from slot X up to update_objects_stop (also entered
; by update_objects_0280).
update_object_slots:
	lda	OBJ_TYPE,x
	bne	@active
	brl	@next_slot
@active:
	lda	OBJ_FLAGS,x
	bit	#OBJF_MOVE
	beq	@offscreen_check
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
@offscreen_check:
	bit	#OBJF_OFFSCREEN_KILL
	beq	@target_check
	lda	OBJ_X,x
	cmp	#$0120
	bcc	@x_on_screen
	cmp	#$FFE0	; [num]
	bcs	@x_on_screen
	brl	@free_slot
@x_on_screen:
	lda	OBJ_Y,x
	cmp	#$0120
	bcc	@on_screen
	cmp	#$FFE0	; [num]
	bcs	@on_screen
	brl	@free_slot
@on_screen:
	lda	OBJ_FLAGS,x
@target_check:
	bit	#OBJF_TARGET
	beq	@touch_check
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
@touch_check:
	bit	#OBJF_TOUCH
	beq	@animate
	ldy	#$0200
	lda	stage_frame_odd
	beq	@have_player
	ldy	#$0240
@have_player:
	lda	a:OBJ_FLAGS,y
	beq	@animate
	lda	a:PLAYER_HITBOX_RIGHT,y
	cmp	OBJ_X,x
	bmi	@animate
	lda	a:PLAYER_HITBOX_TOP,y
	cmp	OBJ_Y,x
	bpl	@animate
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	cmp	a:PLAYER_HITBOX_LEFT,y
	bmi	@animate
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	cmp	a:PLAYER_HITBOX_BOTTOM,y
	bpl	@animate
	lda	a:OBJ_FLAGS,y
	bmi	@animate
	sty	OBJ_TOUCHED_BY,x
	bit	#PLAYERF_INVULNERABLE
	bne	@animate
	lda	a:PLAYER_BARRIER,y
	beq	@no_barrier
	lda	OBJ_FLAGS,x
	bit	#OBJF_TARGET
	beq	@remove_harmful
	; (not executed in the CDL traces)
	bit	#OBJF_INVULNERABLE
	bne	@remove_harmful
	lda	OBJ_HP,x
	bmi	@hp_negative
	dec	OBJ_HP,x
	lda	#$0001
	sta	OBJ_HIT,x
@hp_negative:
	lda	OBJ_FLAGS,x
@remove_harmful:
	and	#($FFFF ^ OBJF_HARMFUL)
	bra	@add_contact
@no_barrier:
	lda	OBJ_FLAGS,x
@add_contact:
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
@animate:
	ldy	OBJ_ANIM,x
	beq	@call_handler
	dec	OBJ_ANIM_TIMER,x
	bmi	@start_anim
	bne	@call_handler
	tya
	clc
	adc	#$0006
@follow_jump:
	tay
	lda	a:$0000,y
	bmi	@follow_jump
	beq	@anim_end
	sty	OBJ_ANIM,x
	bra	@set_timer
@start_anim:
	lda	a:$0000,y
	bne	@set_timer
@anim_end:
	sta	OBJ_ANIM,x
@set_timer:
	sta	OBJ_ANIM_TIMER,x
	lda	OBJ_FACING,x
	beq	@first_sprite
	lda	a:$0004,y
	bra	@set_sprite
@first_sprite:
	lda	a:$0002,y
@set_sprite:
	sta	OBJ_SPRITE,x
@call_handler:
	jsl	f:call_object_handler
	lda	OBJ_FLAGS,x
	bpl	@hit_flash
@free_slot:
	phx
	stz	OBJ_SPRITE,x
	txy
	iny
	lda	#$003E
	mvn	#^tables_05, #^tables_05
	plx
	bra	@next_slot
@hit_flash:
	lda	OBJ_SAVED_ATTR,x
	bne	@restore_attr
	lda	OBJ_HIT,x
	beq	@draw
	lda	OBJ_FLAGS,x
	bit	#OBJF_INVULNERABLE
	bne	@draw
	lda	OBJ_ATTR,x
	sta	OBJ_SAVED_ATTR,x
	and	#$3000
	ora	#$0200
	sta	OBJ_ATTR,x
	bra	@draw
@restore_attr:
	lda	OBJ_SAVED_ATTR,x
	sta	OBJ_ATTR,x
	stz	OBJ_SAVED_ATTR,x
@draw:
	ldy	OBJ_SPRITE,x
	beq	@clear_hit
	lda	oam_hi_ptr
	cmp	#$11E0
	bcs	@clear_hit
	jsr	a:draw_metasprite
@clear_hit:
	stz	OBJ_HIT,x
@next_slot:
	clc
	txa
	adc	#$0040
	tax
	cmp	a:update_objects_stop
	bcs	@done
	brl	update_object_slots
@done:
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
