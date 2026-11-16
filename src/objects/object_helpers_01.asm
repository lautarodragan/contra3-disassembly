; objects/object_helpers_01.asm -- Object helpers (bank $01)
; Bank $01, $01:9E44-$01:A547. Included by main.asm in segment BANK01.
;
; Routines shared by object handlers in banks $00, $01, $04 and $1D (movement,
; aiming, spawning).

; Handler of object type 54: marks itself OBJF_DELETE and frees the first
; object (from $0280) whose OBJ_TYPE equals its own $3A.
delete_self_and_linked:
	lda	#$8000	; [num]
	sta	OBJ_FLAGS,x
	txy
	ldx	#$0280
@loop:
	lda	OBJ_TYPE,x
	cmp	a:$003A,y
	beq	@found
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0AC0
	bcc	@loop
	; (not executed in the CDL traces)
	tyx
	rtl
@found:
	phy
	stz	$00,x
	txy
	iny
	lda	#$003E
	mvn	#^tables_05, #^tables_05
	plx
	rtl

; While OBJ_HIT is set, uploads the flash palette ($05:912A) to CGRAM
; address Y (bosses drawn on BG flash this way).
flash_palette_on_hit:
	lda	OBJ_SAVED_ATTR,x
	bne	@flash_done
	lda	OBJ_HIT,x
	beq	@return
	inc	OBJ_SAVED_ATTR,x
	lda	#.loword(palette_05912A)
	sta	cgram_upload_src
	sty	cgram_upload_addr
@return:
	rtl
@flash_done:
	; (not executed in the CDL traces)
	stz	OBJ_SAVED_ATTR,x
	rtl

; Returns X = the first free slot (OBJ_TYPE 0) of $0300-$077F, carry clear;
; carry set if none.
find_free_slot:
	ldx	#$0300

; The same, starting at X.
find_free_slot_from_x:
	lda	OBJ_TYPE,x
	beq	@found
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0780
	bcc	find_free_slot_from_x
	; (not executed in the CDL traces)
	rtl
@found:
	clc
	rtl

; Y = the first free slot from Y up to $0ABF, carry clear; carry set if
; none.
find_free_slot_y_to_end:
	lda	a:OBJ_TYPE,y
	beq	@found
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0AC0
	bcc	find_free_slot_y_to_end
	; (not executed in the CDL traces)
	rtl
@found:
	clc
	rtl

; Y = the first free slot of $0300-$077F, carry clear; carry set if none.
find_free_slot_y:
	ldy	#$0300

; The same, starting at Y.
find_free_slot_from_y:
	lda	a:OBJ_TYPE,y
	beq	@found
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0780
	bcc	find_free_slot_from_y
	rtl
@found:
	clc
	rtl

; Y = the first free slot from Y down to $0300, carry SET when found,
; carry clear if none.
find_free_slot_y_down:
	lda	a:OBJ_TYPE,y
	beq	@found
	tya
	sec
	sbc	#$0040
	tay
	cmp	#$0300
	bcs	find_free_slot_y_down
	rtl
@found:
	sec
	rtl

; X = the first free slot from X down to $0300, carry set when found.
find_free_slot_x_down:
	lda	OBJ_TYPE,x
	beq	@found
	txa
	sec
	sbc	#$0040
	tax
	cmp	#$0300
	bcs	find_free_slot_x_down
	; (not executed in the CDL traces)
	rtl
@found:
	sec
	rtl

; (no caller found; decoded because it follows the end of a routine)
; A wall tile (TILE_CLIMBABLE) 32 pixels above the object at x: field $38
; = 2 and snap right; at x+16: field $38 = 4 and snap left. Never reached.
unused_check_walls_above:
	; (not executed in the CDL traces)
	stz	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	beq	@check_right
	lda	#$0002
	sta	$38,x
	brl	snap_x_right_to_tile
@check_right:
	lda	#$0010
	sta	zp_00
	lda	#$FFE0	; [num]
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#TILE_CLIMBABLE
	beq	@return
	lda	#$0004
	sta	$38,x
	brl	snap_x_left_to_tile
@return:
	rtl

; Makes the object at X solid for each present player (solid_object_vs_player).
solid_object_vs_players:
	ldy	#$0200
	lda	a:OBJ_FLAGS,y
	beq	@player2
	stz	zp_0C
	jsl	f:solid_object_vs_player
@player2:
	ldy	#$0240
	lda	a:OBJ_FLAGS,y
	beq	solid_object_return
	; (not executed in the CDL traces)
	stz	zp_0C
	jsl	f:solid_object_vs_player
solid_object_return:
	rtl

; If the hitbox of the object at X overlaps the body of the player at Y,
; pushes the player out along the shallower axis: onto the top (lands it,
; PCONTACT_ON_OBJECT, PLAYER_PLATFORM = X), or to the side
; (PCONTACT_BLOCK_LEFT / PCONTACT_BLOCK_RIGHT; also PCONTACT_KILLED when
; crushed against the screen edge).  zp_0C = kind of object (0-2).
solid_object_vs_player:
	clc
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	sec
	sbc	a:OBJ_X,y
	bmi	solid_object_return
	sta	zp_10
	lda	a:PLAYER_HITBOX_RIGHT,y
	sec
	sbc	OBJ_X,x
	bmi	solid_object_return
	sta	zp_12
	clc
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	sec
	sbc	a:OBJ_Y,y
	bpl	solid_object_return
	eor	#$FFFF
	inc	a
	sta	zp_14
	lda	a:PLAYER_HITBOX_TOP,y
	sec
	sbc	OBJ_Y,x
	bpl	solid_object_return
	eor	#$FFFF
	inc	a
	sta	zp_16
	txa
	sta	a:PLAYER_PLATFORM,y
	lda	zp_10
	cmp	zp_12
	bcc	@have_min_x
	lda	zp_12
@have_min_x:
	sta	zp_08
	lda	zp_14
	cmp	zp_16
	bcc	@have_min_y
	lda	zp_16
@have_min_y:
	sta	zp_0A
	lda	zp_0A
	cmp	zp_08
	bcs	solid_object_push_sideways
	lda	zp_14
	cmp	zp_16
	bcs	solid_object_push_down
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_solid_push_up,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_solid_push_up:
	.addr	solid_push_player_up
	.addr	solid_push_player_up
	.addr	solid_push_player_up
; The vertical overlap is the smaller and the player is under the object:
; tbl_solid_push_down (all solid_push_player_down, which does nothing).
solid_object_push_down:
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_solid_push_down,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_solid_push_down:
	.addr	solid_push_player_down
	.addr	solid_push_player_down
	.addr	solid_push_player_down
; The horizontal overlap is the smaller: push right or left by kind.
solid_object_push_sideways:
	lda	zp_10
	cmp	zp_12
	bcs	solid_object_push_left
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_solid_push_right,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_solid_push_right:
	.addr	solid_push_player_right
	.addr	solid_push_player_right
	.addr	solid_push_player_right_2
solid_object_push_left:
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_solid_push_left,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_solid_push_left:
	.addr	solid_push_player_left
	.addr	solid_push_player_left_1
	.addr	solid_push_player_left

; zp_0C kinds 0-2: player landed on top: stops its fall, puts it on the
; object, PCONTACT_ON_OBJECT.
solid_push_player_up:
	lda	a:OBJ_Y_VEL,y
	bmi	@return
	lda	#$0000
	sta	a:OBJ_Y_VEL,y
	sta	a:OBJ_Y_VEL_SUB,y
	jsr	a:place_player_on_object
	lda	#$0080
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
@return:
	rtl

; The player hit the right side of the object: put it right of it,
; PCONTACT_BLOCK_LEFT; crushed (PCONTACT_KILLED) when that is past x $F1.
solid_push_player_right:
	jsr	a:place_player_right_of_object
	cmp	#$00F1
	bcs	solid_push_right_crushed
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0200
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl

solid_push_player_right_2:
	; (not executed in the CDL traces)
	jsr	a:place_player_right_of_object
	cmp	#$00F1
	bcs	solid_push_right_crushed
	lda	a:OBJ_X_VEL,y
	bmi	solid_push_right_crushed
	sec
	sbc	OBJ_X_VEL,x
	bcs	solid_push_right_blocked
	cmp	#$FFFF	; [num]
	bcs	solid_push_right_blocked
; Against the right screen edge: stop, PCONTACT_BLOCK_LEFT | PCONTACT_KILLED.
solid_push_right_crushed:
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0204
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl
; PCONTACT_BLOCK_LEFT only.
solid_push_right_blocked:
	; (not executed in the CDL traces)
	lda	#$0200
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl

; The player hit the left side of the object: put it left of it,
; PCONTACT_BLOCK_RIGHT; crushed when that is left of x 9.
solid_push_player_left:
	jsr	a:place_player_left_of_object
	cmp	#$0009
	bcc	solid_push_left_crushed
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0400
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl

solid_push_player_left_1:
	jsr	a:place_player_left_of_object
	cmp	#$0009
	bcc	solid_push_left_crushed
	lda	a:OBJ_X_VEL,y
	bpl	solid_push_left_crushed
	; (not executed in the CDL traces)
	sec
	sbc	OBJ_X_VEL,x
	bcc	solid_push_left_blocked
	cmp	#$0001
	bcc	solid_push_left_blocked
; Against the left screen edge: stop, PCONTACT_BLOCK_RIGHT | PCONTACT_KILLED.
solid_push_left_crushed:
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0404
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl
; PCONTACT_BLOCK_RIGHT only.
solid_push_left_blocked:
	; (not executed in the CDL traces)
	lda	#$0400
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl

place_player_on_object:
	clc
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	inc	a
	sta	a:OBJ_Y,y
	rts

place_player_left_of_object:
	sec
	lda	a:OBJ_X,y
	sbc	a:PLAYER_HITBOX_RIGHT,y
	clc
	adc	OBJ_X,x
	inc	a
	sta	a:OBJ_X,y
	rts

place_player_right_of_object:
	clc
	lda	OBJ_X,x
	adc	OBJ_HITBOX_W,x
	dec	a
	sta	a:OBJ_X,y
	rts

; Hitting the object from below: nothing.
solid_push_player_down:
	rtl

; A = angle (0-255, calc_angle) from the centre of the hitbox of the object
; at X to PLAYER_CENTER_X/Y of the player at Y, plus $80.
angle_to_player:
	lda	OBJ_HITBOX_W,x
	lsr	a
	adc	OBJ_X,x
	sbc	a:PLAYER_CENTER_X,y
	sta	zp_08
	sec
	lda	OBJ_HITBOX_H,x
	ror	a
	adc	OBJ_Y,x
	sbc	a:PLAYER_CENTER_Y,y
	sta	zp_0A
	jsl	f:calc_angle
	clc
	adc	#$0080
	and	#$00FF
	rtl

; Fires an enemy bullet from zp_00/zp_02 at the target player (the first
; present one, alternating by stage_frame_odd); see spawn_enemy_bullet.
fire_bullet_at_player:
	lda	stage_frame_odd
	bne	@odd_frame
	ldy	#$0200
	lda	a:player1_obj+OBJ_FLAGS
	bne	@aim
	ldy	#$0240
	bra	@aim
@odd_frame:
	ldy	#$0240
	lda	a:player2_obj+OBJ_FLAGS
	bne	@aim
	ldy	#$0200
@aim:
	lda	a:PLAYER_CENTER_X,y
	sbc	zp_00
	sta	zp_08
	lda	a:PLAYER_CENTER_Y,y
	sbc	zp_02
	sta	zp_0A
	jsl	f:calc_angle
	lsr	a
	lsr	a
	and	#$00FE

; In: A = direction (x2), zp_00/zp_02 = position.  Allocates a slot
; downwards from $0740 and makes it an enemy bullet (type $18) whose
; velocity comes from the table of the difficulty (ptrs_enemy_bullet_speeds[difficulty]
; + direction): faster bullets on harder levels.  Out: carry set and Y =
; bullet if spawned.
spawn_enemy_bullet:
	phy
	ldy	difficulty
	clc
	adc	a:ptrs_enemy_bullet_speeds,y
	sta	zp_FC
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	@no_slot
	lda	#$0018
	sta	a:OBJ_TYPE,y
	lda	zp_00
	sta	a:OBJ_X,y
	lda	zp_02
	sta	a:OBJ_Y,y
	phx
	ldx	zp_FC
	lda	a:$0000,x
	sta	a:OBJ_Y_VEL,y
	lda	a:$0010,x
	sta	a:OBJ_X_VEL,y
	lda	a:$0050,x
	sta	a:OBJ_Y_VEL_SUB,y
	lda	a:$0060,x
	sta	a:OBJ_X_VEL_SUB,y
	plx
	sec
@no_slot:
	ply
	rtl

; In: A = mask ANDed with stage_frame_counter.  Out: Y = $0200 or $0240, a
; present player, alternating when both are.
pick_target_player:
	and	stage_frame_counter
	bne	@try_player2
	lda	a:player1_obj+OBJ_FLAGS
	bmi	@player2
	beq	@player2
@player1:
	ldy	#$0200
	rtl
@try_player2:
	lda	a:player2_obj+OBJ_FLAGS
	bmi	@player1
	beq	@player1
@player2:
	ldy	#$0240
	rtl

; For walking objects: keeps the object at X on the BG floor under the
; centre of its hitbox (object_check_floor_tiles, the same tile classes as
; check_floor_tiles); zp_FC = 1 and the y velocity cleared when it stands on
; the floor.
object_follow_floor:
	lda	$0A,x
	pha
	jsl	f:object_check_floor_tiles
	pla
	sta	$0A,x
	lda	zp_FC
	beq	@return
	stz	$1C,x
	stz	$1E,x
@return:
	rtl

; The tree of check_floor_tiles for an object (zp_04/zp_06 at x and x+6
; after centring x on the hitbox), ending in the snap_y_* routines; zp_FC =
; 0 when there is no floor (@none), else 1.
object_check_floor_tiles:
	lda	#$0001
	sta	zp_FC
	lda	$28,x
	lsr	a
	sec
	sbc	#$0003
	clc
	adc	$0A,x
	sta	$0A,x
	stz	zp_00
	stz	zp_02
	jsl	f:get_bg_tile_at_object
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:get_bg_tile_at_object
	sta	zp_06
	bit	#TILE_FLOOR_MASK
	beq	@right_none
	bit	#TILE_FLOOR_SLOPES
	beq	@right_level
	bit	#TILE_FLIPPED
	bne	@right_fall
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@right_rise_upper
	bne	@right_rise_lower
@right_fall:
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@right_fall_upper
	bne	@right_fall_lower
@right_none:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	bne	@none_left_floor
	brl	@none
@none_left_floor:
	bit	#TILE_FLOOR_SLOPES
	bne	@none_left_slope
	brl	@level
@none_left_slope:
	bit	#TILE_FLIPPED
	beq	@none_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@fall_below
	; (not executed in the CDL traces)
	bne	@fall
@none_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	bne	@rise_above
@right_level:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@level
	bit	#TILE_FLOOR_SLOPES
	beq	@level
	bit	#TILE_FLIPPED
	beq	@level_left_rise
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@level
	bne	@level
@level_left_rise:
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	; (not executed in the CDL traces)
	bne	@rise_above
@right_rise_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@rise_below
	bit	#TILE_FLOOR_SLOPES
	beq	@level
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	; (not executed in the CDL traces)
	bne	@rise_above
@right_rise_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@rise
	bit	#TILE_FLOOR_SLOPES
	beq	@level
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@rise
	bne	@rise_above
@right_fall_upper:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@fall
	bit	#TILE_FLOOR_SLOPES
	beq	@fall
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@fall
	bne	@fall
@right_fall_lower:
	lda	zp_04
	bit	#TILE_FLOOR_MASK
	beq	@fall_above
	bit	#TILE_FLOOR_SLOPES
	beq	@fall_above
	bit	#TILE_FLOOR_SLOPE_LOWER
	beq	@fall_above
	bne	@fall_above
@none:
	stz	zp_FC
	rtl
@fall_below:
	brl	snap_y_slope_down_right_below
@level:
	brl	snap_y_up_to_tile
@rise:
	brl	snap_y_slope_up_right
@fall:
	brl	snap_y_slope_down_right
@rise_above:
	brl	snap_y_slope_up_right_above
@rise_below:
	brl	snap_y_slope_up_right_below
@fall_above:
	brl	snap_y_slope_down_right_above

; Object type $53: does nothing (rtl). A hitbox moved by another object
; (stage 3 spiked climber's body, seen in the emulator; stages 4 and 6).
update_passive_part:
	rtl

; Object type $6B: part of a bigger enemy (stage 4, seen at the airship):
; takes its attributes from word 2 of its animation entry; explodes when
; OBJ_HP < 0.
update_destructible_part:
	lda	$06,x
	bpl	destructible_part_set_attr
	txy
	lda	#.loword(anim_05C59A)
	jml	f:make_effect_object
; Not destroyed: OBJ_ATTR from word 2 of the current animation entry.
destructible_part_set_attr:
	ldy	$20,x
	lda	a:$0004,y
	sta	$02,x
	rtl

; Object type $6C: as type $6B with another explosion; never run in the CDL
; traces.
update_destructible_part_2:
	; (not executed in the CDL traces)
	lda	$06,x
	bpl	destructible_part_set_attr
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object

; Kills (PCONTACT_KILLED) each player outside the limits zp_00 (bottom),
; zp_01 (top), zp_02 (left), zp_03 (right) (0 = no limit), unless the
; player has the barrier and zp_FC = A was 0.  Absent, intangible or
; invulnerable players are spared.
kill_players_outside:
	sta	zp_FC
	ldy	#$0200
	jsr	a:kill_player_outside
	ldy	#$0240
	jsr	a:kill_player_outside
	rtl

kill_player_outside:
	lda	a:PLAYER_BARRIER,y
	beq	@check_alive
	; (not executed in the CDL traces)
	lda	zp_FC
	beq	@return
@check_alive:
	lda	a:PLAYER_LIVES,y
	beq	@return
	lda	a:OBJ_FLAGS,y
	beq	@return
	bit	#$8002
	bne	@return
	lda	a:OBJ_Y,y
	bmi	@return
	sep	#$20
	.a8
	lda	zp_01
	beq	@check_bottom
	cmp	a:OBJ_Y,y
	bcs	@kill
@check_bottom:
	lda	zp_00
	beq	@check_left
	cmp	a:OBJ_Y,y
	bcc	@kill
@check_left:
	lda	zp_02
	beq	@check_right
	; (not executed in the CDL traces)
	cmp	a:OBJ_X,y
	bcs	@kill
@check_right:
	lda	zp_03
	beq	@inside
	; (not executed in the CDL traces)
	cmp	a:OBJ_X,y
	bcs	@inside
@kill:
	lda	#$04
	sta	a:PLAYER_CONTACT,y
@inside:
	rep	#$20
@return:
	.a16
	rts

; Spawns a homing missile (type $47; field $3A = A: 0 flies horizontally, 2
; vertically) from the slots below $0740.
spawn_homing_missile:
	phx
	sta	zp_00
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	@no_slot
	tyx
	lda	#OBJT_HOMING_MISSILE
	sta	OBJ_TYPE,x
	lda	zp_00
	sta	$3A,x
	jsl	f:init_homing_missile
@no_slot:
	plx
	rtl

; Object type $47: small missile homing on a player (stage 3 and 4, seen in
; the emulator; fired by the stage 4 tank, the snake robot...): accelerates
; towards PLAYER_CENTER_X/Y (homing_missile_accel_x by difficulty), smoke trail,
; explodes after $A0 frames, when it touches a player or is shot.
update_homing_missile:
	lda	$12,x
	bne	homing_missile_fly

init_homing_missile:
	lda	#.loword(metasprite_06AE9B)
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0	; [num]
	sta	$2A,x
	lda	#$00A0
	sta	$24,x
	lda	#$001F
	sta	$16,x
	inc	$12,x
	sec
	rtl
; State 1: explode on timeout, contact or HP < 0; else steer and smoke.
homing_missile_fly:
	dec	$24,x
	bmi	@explode
	lda	$3C,x
	bne	@explode
	lda	$06,x
	bpl	@steer
@explode:
	lda	#$0017
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#.loword(anim_05C516)
	jml	f:make_effect_object
@steer:
	lda	#$0400
	jsl	f:pick_target_player
	lda	a:$1312,y
	sta	zp_00
	lda	a:$1314,y
	sta	zp_02
	ldy	$3A,x
	lda	a:homing_missile_smoke_x_vels,y
	sta	zp_06
	lda	a:homing_missile_smoke_y_vels,y
	sta	zp_04
	cpy	#$0000
	bne	@vertical
	ldy	#.loword(metasprite_06AFB4)
	lda	$1A,x
	bmi	@set_sprite
	ldy	#.loword(metasprite_06AFA0)
	lda	zp_06
	eor	#$FFFF
	sta	zp_06
	bra	@set_sprite
@vertical:
	ldy	#.loword(metasprite_06AF96)
	lda	$1E,x
	bmi	@set_sprite
	ldy	#.loword(metasprite_06AFAA)
	lda	zp_04
	eor	#$FFFF
	sta	zp_04
@set_sprite:
	sty	$00,x
	lda	stage_frame_mod4
	bne	@accelerate
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	@accelerate
	lda	#.loword(anim_05C606)
	jsl	f:make_effect_object
	lda	zp_06
	sta	a:$001A,y
	lda	zp_04
	sta	a:$001E,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
@accelerate:
	lda	difficulty
	asl	a
	clc
	adc	$3A,x
	tay
	lda	$0E,x
	cmp	zp_02
	bcc	@accel_down
	sec
	lda	$1C,x
	sbc	a:homing_missile_accel_y,y
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bra	@accel_x
@accel_down:
	clc
	lda	$1C,x
	adc	a:homing_missile_accel_y,y
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
@accel_x:
	lda	$0A,x
	cmp	zp_00
	bcc	@accel_right
	sec
	lda	$18,x
	sbc	a:homing_missile_accel_x,y
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rtl
@accel_right:
	clc
	lda	$18,x
	adc	a:homing_missile_accel_x,y
	sta	$18,x
	lda	$1A,x
	adc	#$0000
	sta	$1A,x
	rtl

; Spawns a chain of A+1 trail segments (type $86) after the object at X,
; linked by field $3E: each gets a free 16-word ring buffer at $7E:E000 +
; $34 (bit in trail_buffers_used, kept in $32). The segments then follow the
; path of the one before them (snake bodies, ropes, chains). In:
; zp_00/zp_04/zp_08/zp_0A/zp_0C/zp_0E/zp_10 = their fields
; $18/$04/$00/$02/$28/$2A/$16.
spawn_trail_chain:
	stz	zp_08
	stz	zp_0A
	stz	zp_0C
	stz	zp_0E
	stz	zp_10
; Entered with zp_08-zp_10 set by the caller (the brain boss chains).
spawn_trail_chain_with_fields:
	phx
	sta	zp_06
@next_segment:
	lda	#$FFF0	; [num]
	sta	zp_12
	lda	#$0001
	sta	zp_14
	lda	a:trail_buffers_used
	sta	zp_16
	jsl	f:find_free_slot_y_to_end
	bcs	@done
	bra	@try_buffer
@buffer_used:
	asl	zp_14
@try_buffer:
	clc
	lda	zp_12
	adc	#$0010
	sta	zp_12
	cmp	#$0100
	bcs	@done
	lsr	zp_16
	bcs	@buffer_used
	lda	zp_12
	sta	a:$0034,y
	phx
	clc
	adc	#$000E
	tax
	lda	#$0008
	sta	zp_FC
@loop:
	lda	#$0180
	sta	f:$7EE000,x
	lda	zp_08
	sta	f:$7EE200,x
	dex
	dex
	dec	zp_FC
	bpl	@loop
	plx
	lda	a:trail_buffers_used
	ora	zp_14
	sta	a:trail_buffers_used
	sta	a:$0032,y
	lda	#OBJT_TRAIL_SEGMENT
	sta	a:OBJ_TYPE,y
	lda	zp_04
	sta	a:$0004,y
	lda	zp_00
	sta	a:$0018,y
	lda	zp_08
	sta	a:$0000,y
	lda	zp_0A
	sta	a:$0002,y
	lda	zp_0C
	sta	a:$0028,y
	lda	zp_0E
	sta	a:$002A,y
	lda	zp_10
	sta	a:$0016,y
	lda	#$0000
	sta	a:$000C,y
	sty	$3E,x
	tyx
	dec	zp_06
	bmi	@chain_end
	brl	@next_segment
@chain_end:
	stz	$3E,x
@done:
	plx
	rtl

; Object type $86: a segment of a trail chain (spawn_trail_chain; seen at
; the stage 3 skeleton robot).
update_trail_segment:
	jsl	f:trail_segment_follow
	jsl	f:trail_pass_to_next
	rtl

; Records the position handed over by the previous segment (fields $1C/$1E)
; in the ring buffer and moves to the entry written ($04 / 2) frames ago;
; visible on the frames selected by the mask $18.
trail_segment_follow:
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	clc
	lda	$0C,x
	adc	$34,x
	tay
	lda	$08,x
	sta	a:$E200,y
	lda	$1C,x
	sta	a:$E000,y
	lda	$1E,x
	sta	a:$E100,y
	lda	$0C,x
	inc	a
	inc	a
	cmp	$04,x
	bcc	@no_wrap
	sbc	$04,x
@no_wrap:
	sta	$0C,x
	clc
	lda	$0C,x
	adc	$34,x
	tay
	lda	a:$E000,y
	sta	$0A,x
	lda	a:$E100,y
	sta	$0E,x
	lda	$18,x
	and	stage_frame_counter
	bne	@hidden
	lda	a:$E200,y
	sta	$00,x
	lda	$1A,x
	sta	$02,x
	bra	@restore_db
@hidden:
	stz	$00,x
@restore_db:
	sep	#$20
	.a8
	lda	#^tables_05
	pha
	plb
	rep	#$20
	.a16
	rtl

; Hands the position, sprite and attributes of X to the next segment of the
; chain (field $3E).
trail_pass_to_next:
	ldy	$3E,x
	beq	@return
	lda	$0A,x
	sta	a:$001C,y
	lda	$0E,x
	sta	a:$001E,y
	lda	$00,x
	sta	a:$0008,y
	lda	$02,x
	sta	a:$001A,y
@return:
	rtl

; Deletes the segments linked from X and frees their ring buffers
; (trail_buffers_used).
delete_trail_chain:
	phx
@loop:
	ldy	$3E,x
	beq	@done
	lda	#$8000	; [num]
	sta	a:$0016,y
	lda	a:$0032,y
	eor	#$FFFF
	and	a:trail_buffers_used
	sta	a:trail_buffers_used
	tyx
	bra	@loop
@done:
	plx
	rtl
