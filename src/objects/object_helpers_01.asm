; objects/object_helpers_01.asm -- Object helpers (bank $01)
; Bank $01, $01:9E44-$01:A547. Included by main.asm in segment BANK01.
;
; Routines shared by object handlers in banks $00, $01, $04 and $1D (movement,
; aiming, spawning).

; Handler of object type 54: marks itself OBJF_DELETE and frees the first
; object (from $0280) whose OBJ_TYPE equals its own $3A.
delete_self_and_linked:
	lda	#$8000
	sta	$16,x
	txy
	ldx	#$0280
loc_019E4D:
	lda	$10,x
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

sub_019E6E:
	lda	$26,x
	bne	loc_019E80
	lda	$14,x
	beq	loc_019E7F
	inc	$26,x
	lda	#$912A
	sta	cgram_upload_src
	sty	cgram_upload_addr
loc_019E7F:
	rtl
loc_019E80:
	; (not executed in the CDL traces)
	stz	$26,x
	rtl

; Returns X = the first free slot (OBJ_TYPE 0) of $0300-$077F, carry clear;
; carry set if none.
find_free_slot:
	ldx	#$0300

; The same, starting at X.
find_free_slot_from_x:
	lda	$10,x
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
	lda	a:$0010,y
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
	lda	a:$0010,y
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
	lda	a:$0010,y
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
	lda	$10,x
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
	jsl	f:sub_00E16E
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
	jsl	f:sub_00E16E
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
	lda	a:$0016,y
	beq	loc_019F28
	stz	zp_0C
	jsl	f:solid_object_vs_player
loc_019F28:
	ldy	#$0240
	lda	a:$0016,y
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
	lda	$0A,x
	adc	$28,x
	sec
	sbc	a:$000A,y
	bmi	loc_019F36
	sta	zp_10
	lda	a:$0028,y
	sec
	sbc	$0A,x
	bmi	loc_019F36
	sta	zp_12
	clc
	lda	$0E,x
	adc	$2A,x
	sec
	sbc	a:$000E,y
	bpl	loc_019F36
	eor	#$FFFF
	inc	a
	sta	zp_14
	lda	a:$002A,y
	sec
	sbc	$0E,x
	bpl	loc_019F36
	eor	#$FFFF
	inc	a
	sta	zp_16
	txa
	sta	a:$1304,y
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
	lda	f:tbl_019FA0,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_019FA0:
	.addr	sub_019FEB
	.addr	sub_019FEB
	.addr	sub_019FEB
loc_019FA6:
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_019FB5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_019FB5:
	.addr	sub_01A0C7
	.addr	sub_01A0C7
	.addr	sub_01A0C7
loc_019FBB:
	lda	zp_10
	cmp	zp_12
	bcs	loc_019FD6
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_019FD0,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_019FD0:
	.addr	sub_01A006
	.addr	sub_01A006
	.addr	sub_01A021
loc_019FD6:
	lda	zp_0C
	phx
	asl	a
	tax
	lda	f:tbl_019FE5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_019FE5:
	.addr	sub_01A055
	.addr	sub_01A070
	.addr	sub_01A055

sub_019FEB:
	lda	a:$001E,y
	bmi	loc_01A005
	lda	#$0000
	sta	a:$001E,y
	sta	a:$001C,y
	jsr	a:sub_01A0A4
	lda	#$0080
	ora	a:$003C,y
	sta	a:$003C,y
loc_01A005:
	rtl

sub_01A006:
	jsr	a:sub_01A0BD
	cmp	#$00F1
	bcs	loc_01A038
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	lda	#$0200
	ora	a:$003C,y
	sta	a:$003C,y
	rtl

sub_01A021:
	; (not executed in the CDL traces)
	jsr	a:sub_01A0BD
	cmp	#$00F1
	bcs	loc_01A038
	lda	a:$001A,y
	bmi	loc_01A038
	sec
	sbc	$1A,x
	bcs	loc_01A04B
	cmp	#$FFFF
	bcs	loc_01A04B
loc_01A038:
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	lda	#$0204
	ora	a:$003C,y
	sta	a:$003C,y
	rtl
loc_01A04B:
	; (not executed in the CDL traces)
	lda	#$0200
	ora	a:$003C,y
	sta	a:$003C,y
	rtl

sub_01A055:
	jsr	a:sub_01A0AE
	cmp	#$0009
	bcc	loc_01A087
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	lda	#$0400
	ora	a:$003C,y
	sta	a:$003C,y
	rtl

sub_01A070:
	jsr	a:sub_01A0AE
	cmp	#$0009
	bcc	loc_01A087
	lda	a:$001A,y
	bpl	loc_01A087
	; (not executed in the CDL traces)
	sec
	sbc	$1A,x
	bcc	loc_01A09A
	cmp	#$0001
	bcc	loc_01A09A
loc_01A087:
	lda	#$0000
	sta	a:$001A,y
	sta	a:$0018,y
	lda	#$0404
	ora	a:$003C,y
	sta	a:$003C,y
	rtl
loc_01A09A:
	; (not executed in the CDL traces)
	lda	#$0400
	ora	a:$003C,y
	sta	a:$003C,y
	rtl

sub_01A0A4:
	clc
	lda	$0E,x
	adc	$2A,x
	inc	a
	sta	a:$000E,y
	rts

sub_01A0AE:
	sec
	lda	a:$000A,y
	sbc	a:$0028,y
	clc
	adc	$0A,x
	inc	a
	sta	a:$000A,y
	rts

sub_01A0BD:
	clc
	lda	$0A,x
	adc	$28,x
	dec	a
	sta	a:$000A,y
	rts

sub_01A0C7:
	rtl

; A = angle (0-255, sub_1DABA0) from the centre of the hitbox of the object
; at X to PLAYER_CENTER_X/Y of the player at Y, plus $80.
angle_to_player:
	lda	$28,x
	lsr	a
	adc	$0A,x
	sbc	a:$1312,y
	sta	zp_08
	sec
	lda	$2A,x
	ror	a
	adc	$0E,x
	sbc	a:$1314,y
	sta	zp_0A
	jsl	f:sub_1DABA0
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
	lda	a:$1312,y
	sbc	zp_00
	sta	zp_08
	lda	a:$1314,y
	sbc	zp_02
	sta	zp_0A
	jsl	f:sub_1DABA0
	lsr	a
	lsr	a
	and	#$00FE

; In: A = direction (x2), zp_00/zp_02 = position.  Allocates a slot
; downwards from $0740 and makes it an enemy bullet (type $18) whose
; velocity comes from the table of the difficulty (data_05ABA5[difficulty]
; + direction): faster bullets on harder levels.  Out: carry set and Y =
; bullet if spawned.
spawn_enemy_bullet:
	phy
	ldy	difficulty
	clc
	adc	a:data_05ABA5,y
	sta	zp_FC
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	loc_01A15B
	lda	#$0018
	sta	a:$0010,y
	lda	zp_00
	sta	a:$000A,y
	lda	zp_02
	sta	a:$000E,y
	phx
	ldx	zp_FC
	lda	a:$0000,x
	sta	a:$001E,y
	lda	a:$0010,x
	sta	a:$001A,y
	lda	a:$0050,x
	sta	a:$001C,y
	lda	a:$0060,x
	sta	a:$0018,y
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

sub_01A177:
	lda	$0A,x
	pha
	jsl	f:sub_01A18A
	pla
	sta	$0A,x
	lda	zp_FC
	beq	loc_01A189
	stz	$1C,x
	stz	$1E,x
loc_01A189:
	rtl

sub_01A18A:
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
	jsl	f:sub_00E16E
	sta	zp_04
	lda	#$0006
	sta	zp_00
	jsl	f:sub_00E16E
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

sub_01A275:
	rtl

sub_01A276:
	lda	$06,x
	bpl	loc_01A282
	txy
	lda	#$C59A
	jml	f:sub_01CF66
loc_01A282:
	ldy	$20,x
	lda	a:$0004,y
	sta	$02,x
	rtl

sub_01A28A:
	; (not executed in the CDL traces)
	lda	$06,x
	bpl	loc_01A282
	txy
	lda	#$C516
	jml	f:sub_01CF66

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
	lda	a:$1D88,y
	beq	loc_01A2AE
	; (not executed in the CDL traces)
	lda	zp_FC
	beq	loc_01A2EF
loc_01A2AE:
	lda	a:$1D8A,y
	beq	loc_01A2EF
	lda	a:$0016,y
	beq	loc_01A2EF
	bit	#$8002
	bne	loc_01A2EF
	lda	a:$000E,y
	bmi	loc_01A2EF
	sep	#$20
	.a8
	lda	zp_01
	beq	loc_01A2CD
	cmp	a:$000E,y
	bcs	loc_01A2E8
loc_01A2CD:
	lda	zp_00
	beq	loc_01A2D6
	cmp	a:$000E,y
	bcc	loc_01A2E8
loc_01A2D6:
	lda	zp_02
	beq	loc_01A2DF
	; (not executed in the CDL traces)
	cmp	a:$000A,y
	bcs	loc_01A2E8
loc_01A2DF:
	lda	zp_03
	beq	loc_01A2ED
	; (not executed in the CDL traces)
	cmp	a:$000A,y
	bcs	loc_01A2ED
loc_01A2E8:
	lda	#$04
	sta	a:$003C,y
loc_01A2ED:
	rep	#$20
loc_01A2EF:
	.a16
	rts

sub_01A2F0:
	phx
	sta	zp_00
	ldy	#$0740
	jsl	f:find_free_slot_y_down
	bcc	loc_01A30A
	tyx
	lda	#$0047
	sta	$10,x
	lda	zp_00
	sta	$3A,x
	jsl	f:sub_01A310
loc_01A30A:
	plx
	rtl

sub_01A30C:
	lda	$12,x
	bne	loc_01A332

sub_01A310:
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
	jml	f:sub_01CF66
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
	jsl	f:sub_01CF66
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

sub_01A412:
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
	lda	a:wram_16B2
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
	lda	a:wram_16B2
	ora	zp_14
	sta	a:wram_16B2
	sta	a:$0032,y
	lda	#$0086
	sta	a:$0010,y
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

sub_01A4B5:
	jsl	f:sub_01A4BE
	jsl	f:sub_01A513
	rtl

sub_01A4BE:
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

sub_01A513:
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

sub_01A52C:
	phx
loc_01A52D:
	ldy	$3E,x
	beq	loc_01A546
	lda	#$8000
	sta	a:$0016,y
	lda	a:$0032,y
	eor	#$FFFF
	and	a:wram_16B2
	sta	a:wram_16B2
	tyx
	bra	loc_01A52D
loc_01A546:
	plx
	rtl
