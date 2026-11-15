; objects/object_helpers_01.asm -- Object helpers (bank $01)
; Bank $01, $01:9E44-$01:A547. Included by main.asm in segment BANK01.
;
; Routines shared by object handlers in banks $00, $01, $04 and $1D (movement,
; aiming, spawning).

; Handler of object type 54: marks itself OBJF_DELETE and frees the first
; object (from $0280) whose OBJ_TYPE equals its own $3A.
delete_self_and_linked:
	lda	#$8000
	sta	OBJ_FLAGS,x
	txy
	ldx	#$0280
loc_019E4D:
	lda	OBJ_TYPE,x
	cmp	a:$003A,y
	beq	loc_019E61
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0AC0
	bcc	loc_019E4D
	; (not executed in the CDL traces)
	tyx
	rtl
loc_019E61:
	phy
	stz	$00,x
	txy
	iny
	lda	#$003E
	mvn	#$05, #$05
	plx
	rtl

; While OBJ_HIT is set, uploads the flash palette ($05:912A) to CGRAM
; address Y (bosses drawn on BG flash this way).
flash_palette_on_hit:
	lda	OBJ_SAVED_ATTR,x
	bne	loc_019E80
	lda	OBJ_HIT,x
	beq	loc_019E7F
	inc	OBJ_SAVED_ATTR,x
	lda	#$912A
	sta	cgram_upload_src
	sty	cgram_upload_addr
loc_019E7F:
	rtl
loc_019E80:
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
	beq	loc_019E96
	txa
	clc
	adc	#$0040
	tax
	cmp	#$0780
	bcc	find_free_slot_from_x
	; (not executed in the CDL traces)
	rtl
loc_019E96:
	clc
	rtl

; Y = the first free slot from Y up to $0ABF, carry clear; carry set if
; none.
find_free_slot_y_to_end:
	lda	a:OBJ_TYPE,y
	beq	loc_019EA9
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0AC0
	bcc	find_free_slot_y_to_end
	; (not executed in the CDL traces)
	rtl
loc_019EA9:
	clc
	rtl

; Y = the first free slot of $0300-$077F, carry clear; carry set if none.
find_free_slot_y:
	ldy	#$0300

; The same, starting at Y.
find_free_slot_from_y:
	lda	a:OBJ_TYPE,y
	beq	loc_019EBF
	tya
	clc
	adc	#$0040
	tay
	cmp	#$0780
	bcc	find_free_slot_from_y
	rtl
loc_019EBF:
	clc
	rtl

; Y = the first free slot from Y down to $0300, carry SET when found,
; carry clear if none.
find_free_slot_y_down:
	lda	a:OBJ_TYPE,y
	beq	loc_019ED2
	tya
	sec
	sbc	#$0040
	tay
	cmp	#$0300
	bcs	find_free_slot_y_down
	rtl
loc_019ED2:
	sec
	rtl

; X = the first free slot from X down to $0300, carry set when found.
find_free_slot_x_down:
	lda	OBJ_TYPE,x
	beq	loc_019EE4
	txa
	sec
	sbc	#$0040
	tax
	cmp	#$0300
	bcs	find_free_slot_x_down
	; (not executed in the CDL traces)
	rtl
loc_019EE4:
	sec
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_019EE6:
	; (not executed in the CDL traces)
	stz	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	beq	loc_019EFE
	lda	#$0002
	sta	$38,x
	brl	snap_x_right_to_tile
loc_019EFE:
	lda	#$0010
	sta	zp_00
	lda	#$FFE0
	sta	zp_02
	jsl	f:get_bg_tile_at_object
	bit	#$0002
	beq	loc_019F19
	lda	#$0004
	sta	$38,x
	brl	snap_x_left_to_tile
loc_019F19:
	rtl

; Makes the object at X solid for each present player (solid_object_vs_player).
solid_object_vs_players:
	ldy	#$0200
	lda	a:OBJ_FLAGS,y
	beq	loc_019F28
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_019F28:
	ldy	#$0240
	lda	a:OBJ_FLAGS,y
	beq	loc_019F36
	; (not executed in the CDL traces)
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_019F36:
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
	bmi	loc_019F36
	sta	zp_10
	lda	a:PLAYER_HITBOX_RIGHT,y
	sec
	sbc	OBJ_X,x
	bmi	loc_019F36
	sta	zp_12
	clc
	lda	OBJ_Y,x
	adc	OBJ_HITBOX_H,x
	sec
	sbc	a:OBJ_Y,y
	bpl	loc_019F36
	eor	#$FFFF
	inc	a
	sta	zp_14
	lda	a:PLAYER_HITBOX_TOP,y
	sec
	sbc	OBJ_Y,x
	bpl	loc_019F36
	eor	#$FFFF
	inc	a
	sta	zp_16
	txa
	sta	a:PLAYER_PLATFORM,y
	lda	zp_10
	cmp	zp_12
	bcc	loc_019F79
	lda	zp_12
loc_019F79:
	sta	zp_08
	lda	zp_14
	cmp	zp_16
	bcc	loc_019F83
	lda	zp_16
loc_019F83:
	sta	zp_0A
	lda	zp_0A
	cmp	zp_08
	bcs	loc_019FBB
	lda	zp_14
	cmp	zp_16
	bcs	loc_019FA6
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
loc_019FA6:
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
loc_019FBB:
	lda	zp_10
	cmp	zp_12
	bcs	loc_019FD6
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
loc_019FD6:
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
	bmi	loc_01A005
	lda	#$0000
	sta	a:OBJ_Y_VEL,y
	sta	a:OBJ_Y_VEL_SUB,y
	jsr	a:place_player_on_object
	lda	#$0080
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
loc_01A005:
	rtl

; The player hit the right side of the object: put it right of it,
; PCONTACT_BLOCK_LEFT; crushed (PCONTACT_KILLED) when that is past x $F1.
solid_push_player_right:
	jsr	a:place_player_right_of_object
	cmp	#$00F1
	bcs	loc_01A038
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
	bcs	loc_01A038
	lda	a:OBJ_X_VEL,y
	bmi	loc_01A038
	sec
	sbc	OBJ_X_VEL,x
	bcs	loc_01A04B
	cmp	#$FFFF
	bcs	loc_01A04B
loc_01A038:
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0204
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl
loc_01A04B:
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
	bcc	loc_01A087
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
	bcc	loc_01A087
	lda	a:OBJ_X_VEL,y
	bpl	loc_01A087
	; (not executed in the CDL traces)
	sec
	sbc	OBJ_X_VEL,x
	bcc	loc_01A09A
	cmp	#$0001
	bcc	loc_01A09A
loc_01A087:
	lda	#$0000
	sta	a:OBJ_X_VEL,y
	sta	a:OBJ_X_VEL_SUB,y
	lda	#$0404
	ora	a:PLAYER_CONTACT,y
	sta	a:PLAYER_CONTACT,y
	rtl
loc_01A09A:
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
	bne	loc_01A0FA
	ldy	#$0200
	lda	a:wram_0216
	bne	loc_01A105
	ldy	#$0240
	bra	loc_01A105
loc_01A0FA:
	ldy	#$0240
	lda	a:wram_0256
	bne	loc_01A105
	ldy	#$0200
loc_01A105:
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
	bcc	loc_01A15B
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
loc_01A15B:
	ply
	rtl

; In: A = mask ANDed with stage_frame_counter.  Out: Y = $0200 or $0240, a
; present player, alternating when both are.
pick_target_player:
	and	stage_frame_counter
	bne	loc_01A16C
	lda	a:wram_0216
	bmi	loc_01A173
	beq	loc_01A173
loc_01A168:
	ldy	#$0200
	rtl
loc_01A16C:
	lda	a:wram_0256
	bmi	loc_01A168
	beq	loc_01A168
loc_01A173:
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
	beq	loc_01A189
	stz	$1C,x
	stz	$1E,x
loc_01A189:
	rtl

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
	bit	#$807E
	beq	loc_01A1CD
	bit	#$0078
	beq	loc_01A1F2
	bit	#$0001
	bne	loc_01A1C6
	bit	#$0050
	beq	loc_01A211
	bne	loc_01A224
loc_01A1C6:
	bit	#$0050
	beq	loc_01A237
	bne	loc_01A24A
loc_01A1CD:
	lda	zp_04
	bit	#$807E
	bne	loc_01A1D7
	brl	loc_01A25D
loc_01A1D7:
	bit	#$0078
	bne	loc_01A1DF
	brl	loc_01A263
loc_01A1DF:
	bit	#$0001
	beq	loc_01A1EB
	bit	#$0050
	beq	loc_01A260
	; (not executed in the CDL traces)
	bne	loc_01A269
loc_01A1EB:
	bit	#$0050
	beq	loc_01A266
	bne	loc_01A26C
loc_01A1F2:
	lda	zp_04
	bit	#$807E
	beq	loc_01A263
	bit	#$0078
	beq	loc_01A263
	bit	#$0001
	beq	loc_01A20A
	bit	#$0050
	beq	loc_01A263
	bne	loc_01A263
loc_01A20A:
	bit	#$0050
	beq	loc_01A266
	; (not executed in the CDL traces)
	bne	loc_01A26C
loc_01A211:
	lda	zp_04
	bit	#$807E
	beq	loc_01A26F
	bit	#$0078
	beq	loc_01A263
	bit	#$0050
	beq	loc_01A266
	; (not executed in the CDL traces)
	bne	loc_01A26C
loc_01A224:
	lda	zp_04
	bit	#$807E
	beq	loc_01A266
	bit	#$0078
	beq	loc_01A263
	bit	#$0050
	beq	loc_01A266
	bne	loc_01A26C
loc_01A237:
	lda	zp_04
	bit	#$807E
	beq	loc_01A269
	bit	#$0078
	beq	loc_01A269
	bit	#$0050
	beq	loc_01A269
	bne	loc_01A269
loc_01A24A:
	lda	zp_04
	bit	#$807E
	beq	loc_01A272
	bit	#$0078
	beq	loc_01A272
	bit	#$0050
	beq	loc_01A272
	bne	loc_01A272
loc_01A25D:
	stz	zp_FC
	rtl
loc_01A260:
	brl	loc_019651
loc_01A263:
	brl	snap_y_up_to_tile
loc_01A266:
	brl	loc_019480
loc_01A269:
	brl	loc_019592
loc_01A26C:
	brl	loc_0194DD
loc_01A26F:
	brl	loc_019536
loc_01A272:
	brl	loc_0195F2

; Object type $53: does nothing (rtl). A hitbox moved by another object
; (stage 3 spiked climber's body, seen in the emulator; stages 4 and 6).
update_passive_part:
	rtl

; Object type $6B: part of a bigger enemy (stage 4, seen at the airship):
; takes its attributes from word 2 of its animation entry; explodes when
; OBJ_HP < 0.
update_destructible_part:
	lda	$06,x
	bpl	loc_01A282
	txy
	lda	#$C59A
	jml	f:make_effect_object
loc_01A282:
	ldy	$20,x
	lda	a:$0004,y
	sta	$02,x
	rtl

; Object type $6C: as type $6B with another explosion; never run in the CDL
; traces.
update_destructible_part_2:
	; (not executed in the CDL traces)
	lda	$06,x
	bpl	loc_01A282
	txy
	lda	#$C516
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
	beq	loc_01A2AE
	; (not executed in the CDL traces)
	lda	zp_FC
	beq	loc_01A2EF
loc_01A2AE:
	lda	a:PLAYER_LIVES,y
	beq	loc_01A2EF
	lda	a:OBJ_FLAGS,y
	beq	loc_01A2EF
	bit	#$8002
	bne	loc_01A2EF
	lda	a:OBJ_Y,y
	bmi	loc_01A2EF
	sep	#$20
	.a8
	lda	zp_01
	beq	loc_01A2CD
	cmp	a:OBJ_Y,y
	bcs	loc_01A2E8
loc_01A2CD:
	lda	zp_00
	beq	loc_01A2D6
	cmp	a:OBJ_Y,y
	bcc	loc_01A2E8
loc_01A2D6:
	lda	zp_02
	beq	loc_01A2DF
	; (not executed in the CDL traces)
	cmp	a:OBJ_X,y
	bcs	loc_01A2E8
loc_01A2DF:
	lda	zp_03
	beq	loc_01A2ED
	; (not executed in the CDL traces)
	cmp	a:OBJ_X,y
	bcs	loc_01A2ED
loc_01A2E8:
	lda	#$04
	sta	a:PLAYER_CONTACT,y
loc_01A2ED:
	rep	#$20
loc_01A2EF:
	.a16
	rts

; Spawns a homing missile (type $47; field $3A = A: 0 flies horizontally, 2
; vertically) from the slots below $0740.
spawn_homing_missile:
	phx
	sta	zp_00
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	loc_01A30A
	tyx
	lda	#OBJT_HOMING_MISSILE
	sta	OBJ_TYPE,x
	lda	zp_00
	sta	$3A,x
	jsl	f:init_homing_missile
loc_01A30A:
	plx
	rtl

; Object type $47: small missile homing on a player (stage 3 and 4, seen in
; the emulator; fired by the stage 4 tank, the snake robot...): accelerates
; towards PLAYER_CENTER_X/Y (data_05ABAB by difficulty), smoke trail,
; explodes after $A0 frames, when it touches a player or is shot.
update_homing_missile:
	lda	$12,x
	bne	loc_01A332

init_homing_missile:
	lda	#$AE9B
	sta	$00,x
	lda	#$3E00
	sta	$02,x
	lda	#$0010
	sta	$28,x
	lda	#$FFF0
	sta	$2A,x
	lda	#$00A0
	sta	$24,x
	lda	#$001F
	sta	$16,x
	inc	$12,x
	sec
	rtl
loc_01A332:
	dec	$24,x
	bmi	loc_01A33E
	lda	$3C,x
	bne	loc_01A33E
	lda	$06,x
	bpl	loc_01A34F
loc_01A33E:
	lda	#$0017
	jsl	f:queue_sound
	stz	$04,x
	txy
	lda	#$C516
	jml	f:make_effect_object
loc_01A34F:
	lda	#$0400
	jsl	f:pick_target_player
	lda	a:$1312,y
	sta	zp_00
	lda	a:$1314,y
	sta	zp_02
	ldy	$3A,x
	lda	a:data_05ABB9,y
	sta	zp_06
	lda	a:data_05ABBD,y
	sta	zp_04
	cpy	#$0000
	bne	loc_01A384
	ldy	#$AFB4
	lda	$1A,x
	bmi	loc_01A395
	ldy	#$AFA0
	lda	zp_06
	eor	#$FFFF
	sta	zp_06
	bra	loc_01A395
loc_01A384:
	ldy	#$AF96
	lda	$1E,x
	bmi	loc_01A395
	ldy	#$AFAA
	lda	zp_04
	eor	#$FFFF
	sta	zp_04
loc_01A395:
	sty	$00,x
	lda	stage_frame_mod4
	bne	loc_01A3BF
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	loc_01A3BF
	lda	#$C606
	jsl	f:make_effect_object
	lda	zp_06
	sta	a:$001A,y
	lda	zp_04
	sta	a:$001E,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$0A,x
	sta	a:$000A,y
loc_01A3BF:
	lda	difficulty
	asl	a
	clc
	adc	$3A,x
	tay
	lda	$0E,x
	cmp	zp_02
	bcc	loc_01A3DD
	sec
	lda	$1C,x
	sbc	a:data_05ABAD,y
	sta	$1C,x
	lda	$1E,x
	sbc	#$0000
	sta	$1E,x
	bra	loc_01A3EC
loc_01A3DD:
	clc
	lda	$1C,x
	adc	a:data_05ABAD,y
	sta	$1C,x
	lda	$1E,x
	adc	#$0000
	sta	$1E,x
loc_01A3EC:
	lda	$0A,x
	cmp	zp_00
	bcc	loc_01A402
	sec
	lda	$18,x
	sbc	a:data_05ABAB,y
	sta	$18,x
	lda	$1A,x
	sbc	#$0000
	sta	$1A,x
	rtl
loc_01A402:
	clc
	lda	$18,x
	adc	a:data_05ABAB,y
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
loc_01A41C:
	phx
	sta	zp_06
loc_01A41F:
	lda	#$FFF0
	sta	zp_12
	lda	#$0001
	sta	zp_14
	lda	a:trail_buffers_used
	sta	zp_16
	jsl	f:find_free_slot_y_to_end
	bcs	loc_01A4B3
	bra	loc_01A438
loc_01A436:
	asl	zp_14
loc_01A438:
	clc
	lda	zp_12
	adc	#$0010
	sta	zp_12
	cmp	#$0100
	bcs	loc_01A4B3
	lsr	zp_16
	bcs	loc_01A436
	lda	zp_12
	sta	a:$0034,y
	phx
	clc
	adc	#$000E
	tax
	lda	#$0008
	sta	zp_FC
loc_01A459:
	lda	#$0180
	sta	f:$7EE000,x
	lda	zp_08
	sta	f:$7EE200,x
	dex
	dex
	dec	zp_FC
	bpl	loc_01A459
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
	bmi	loc_01A4B1
	brl	loc_01A41F
loc_01A4B1:
	stz	$3E,x
loc_01A4B3:
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
	bcc	loc_01A4E5
	sbc	$04,x
loc_01A4E5:
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
	bne	loc_01A508
	lda	a:$E200,y
	sta	$00,x
	lda	$1A,x
	sta	$02,x
	bra	loc_01A50A
loc_01A508:
	stz	$00,x
loc_01A50A:
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

; Hands the position, sprite and attributes of X to the next segment of the
; chain (field $3E).
trail_pass_to_next:
	ldy	$3E,x
	beq	loc_01A52B
	lda	$0A,x
	sta	a:$001C,y
	lda	$0E,x
	sta	a:$001E,y
	lda	$00,x
	sta	a:$0008,y
	lda	$02,x
	sta	a:$001A,y
loc_01A52B:
	rtl

; Deletes the segments linked from X and frees their ring buffers
; (trail_buffers_used).
delete_trail_chain:
	phx
loc_01A52D:
	ldy	$3E,x
	beq	loc_01A546
	lda	#$8000
	sta	a:$0016,y
	lda	a:$0032,y
	eor	#$FFFF
	and	a:trail_buffers_used
	sta	a:trail_buffers_used
	tyx
	bra	loc_01A52D
loc_01A546:
	plx
	rtl
