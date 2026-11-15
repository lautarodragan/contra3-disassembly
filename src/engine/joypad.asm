; engine/joypad.asm -- Joypad input
; Bank $00, $00:8B19-$00:8BA6. Included by main.asm in segment BANK00.
;
; read_joypads waits for auto-read and stores the four pads' held buttons at
; $20-$27 and newly pressed buttons at $28-$2F; pressing Select while holding
; L+R+Start+Select jumps to the warm boot (warm_boot). sub_008B64 (never run
; in the traces) is a pause/exit check.

read_joypads:
	rep	#$10
	sep	#$20
@wait_autoread:
	.a8
	lda	a:HVBJOY
	and	#$01
	bne	@wait_autoread
	rep	#$20
	.a16
	ldx	#$0006
@read_loop:
	lda	$20,x
	eor	#$FFFF
	ldy	a:JOY1L,x
	sty	$20,x
	and	$20,x
	sta	$28,x
	dex
	dex
	bpl	@read_loop
	ldx	#$0000
@reset_check_loop:
	rep	#$20
	lda	soft_reset_pad_mask
	and	a:data_058228,x
	beq	@next_pad
	lda	$28,x
	cmp	#$2000
	bne	@next_pad
	lda	$20,x
	cmp	#$3030
	bne	@next_pad
	; (not executed in the CDL traces)
	lda	force_blank_frames
	bne	@next_pad
	jmp	a:warm_boot
@next_pad:
	inx
	inx
	cpx	#$0008
	bcc	@reset_check_loop
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008B64:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	lda	force_blank_frames
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
	jml	f:clear_ram_1c00_1cff
loc_008B90:
	rtl
loc_008B91:
	lda	#$0004
	sta	force_blank_frames
	jsl	f:reset_sound_queue
	lda	#$0002
	jml	f:sub_00ABA3

sub_008BA1:
	; (not executed in the CDL traces)
	lda	#$0200
	sta	zp_68
	rtl
