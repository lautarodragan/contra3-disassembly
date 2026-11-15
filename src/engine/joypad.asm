; engine/joypad.asm -- Joypad input
; Bank $00, $00:8B19-$00:8BA6. Included by main.asm in segment BANK00.
;
; sub_008B19 waits for auto-read and stores the four pads' held buttons at
; $20-$27 and newly pressed buttons at $28-$2F; pressing Select while holding
; L+R+Start+Select jumps to the warm boot (loc_0080A3). sub_008B64 (never run
; in the traces) is a pause/exit check.

sub_008B19:
	rep	#$10
	sep	#$20
loc_008B1D:
	.a8
	lda	a:HVBJOY
	and	#$01
	bne	loc_008B1D
	rep	#$20
	.a16
	ldx	#$0006
loc_008B29:
	lda	$20,x
	eor	#$FFFF
	ldy	a:JOY1L,x
	sty	$20,x
	and	$20,x
	sta	$28,x
	dex
	dex
	bpl	loc_008B29
	ldx	#$0000
loc_008B3E:
	rep	#$20
	lda	zp_30
	and	a:data_058228,x
	beq	loc_008B5C
	lda	$28,x
	cmp	#$2000
	bne	loc_008B5C
	lda	$20,x
	cmp	#$3030
	bne	loc_008B5C
	; (not executed in the CDL traces)
	lda	zp_3E
	bne	loc_008B5C
	jmp	a:loc_0080A3
loc_008B5C:
	inx
	inx
	cpx	#$0008
	bcc	loc_008B3E
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008B64:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	lda	zp_3E
	bne	loc_008B90
	lda	joy1_pressed
	and	#$3000
	beq	loc_008B90
	jsl	f:sub_008BA1
	lda	game_mode
	cmp	#$0002
	bne	loc_008B91
	lda	joy1_pressed
	and	#$2000
	bne	loc_008B90
	lda	#$0006
	jsl	f:sub_00ABA3
	jml	f:sub_00885E
loc_008B90:
	rtl
loc_008B91:
	lda	#$0004
	sta	zp_3E
	jsl	f:sub_00865C
	lda	#$0002
	jml	f:sub_00ABA3

sub_008BA1:
	; (not executed in the CDL traces)
	lda	#$0200
	sta	zp_68
	rtl
