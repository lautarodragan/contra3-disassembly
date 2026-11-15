; objects/object_handlers_02.asm -- Object handlers (bank $02)
; Bank $02, $02:FCCB-$02:FFFF. Included by main.asm in segment BANK02.
;
; Handlers of the secondary object list (tbl_shot_types) and a routine called from
; bank $1D.

sub_02FCCB:
	lda	stage_frame_counter
	and	#$007F
	bne	loc_02FD09
	jsr	a:sub_02FD0E
	bcs	loc_02FD09
	lda	stage_frame_counter
	and	#$0180
	asl	a
	xba
	and	#$0003
	sta	a:$0014,y
	lda	#$0016
	sta	a:$0010,y
	lda	#$0000
	sta	a:$0012,y
	lda	zp_E9
	and	#$007F
	clc
	adc	#$0040
	sta	a:$000A,y
	lda	frame_counter
	adc	rng_lo
	and	#$001F
	adc	#$0020
	sta	a:$000E,y
loc_02FD09:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_02FD0A:
	; (not executed in the CDL traces)
	jsr	a:sub_02FD0E
	rtl

sub_02FD0E:
	phx
	ldx	#$0000
loc_02FD12:
	txa
	asl	a
	tay
	lda	a:data_05E6E4,y
	tay
	lda	a:$0010,y
	beq	loc_02FD27
	inx
	cpx	#$0028
	bcc	loc_02FD12
	; (not executed in the CDL traces)
	sec
	plx
	rts
loc_02FD27:
	clc
	plx
	rts

sub_02FD2A:
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FD39,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FD39:
	.addr	sub_02FD3D
	.addr	sub_02FD56

sub_02FD3D:
	lda	#$3E4F
	sta	$02,x
	stz	$16,x
	stz	$06,x
	lda	#$FFFF
	sta	$1E,x
	stz	$1A,x
	stz	$1C,x
	stz	$18,x
	stz	$00,x
	inc	$12,x
	rtl

sub_02FD56:
	inc	$00,x
	lda	$00,x
	cmp	#$000F
	bcc	loc_02FD73
	jsr	a:sub_02FD74
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FD6A:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FD6A
loc_02FD73:
	rtl

sub_02FD74:
	stz	zp_00
loc_02FD76:
	jsr	a:sub_02FD0E
	bcs	loc_02FDB5
	sty	zp_02
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:data_05E734,y
	ldy	zp_02
	sta	a:$0010,y
	lda	zp_00
	sta	a:$0004,y
	lda	#$0000
	sta	a:$0012,y
	lda	$0A,x
	sta	a:$000A,y
	lda	$0E,x
	sta	a:$000E,y
	lda	$18,x
	sta	a:$0018,y
	lda	$1A,x
	sta	a:$001A,y
	lda	$1C,x
	sta	a:$001C,y
	lda	$1E,x
	sta	a:$001E,y
loc_02FDB5:
	inc	zp_00
	lda	$14,x
	and	#$0003
	asl	a
	tay
	lda	a:data_05E73C,y
	cmp	zp_00
	bcs	loc_02FD76
	rts

sub_02FDC6:
	lda	$1C,x
	clc
	adc	#$0400
	sta	$1C,x
	bcc	loc_02FDD2
	inc	$1E,x
loc_02FDD2:
	rts

sub_02FDD3:
	jsr	a:sub_02FDC6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FDE5,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FDE5:
	.addr	sub_02FDEB
	.addr	sub_02FE0B
	.addr	sub_02FE19

sub_02FDEB:
	lda	#$3E4F
	sta	$02,x
	jsr	a:sub_02FF17
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

sub_02FE0B:
	inc	$00,x
	lda	$00,x
	cmp	#$001E
	bcc	loc_02FE18
	stz	$00,x
	inc	$12,x
loc_02FE18:
	rtl

sub_02FE19:
	lda	$00,x
	bit	#$0002
	bne	loc_02FE25
	lda	#$3E5E
	bra	loc_02FE28
loc_02FE25:
	lda	#$3E4F
loc_02FE28:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$003C
	bcc	loc_02FE44
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FE3B:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FE3B
loc_02FE44:
	rtl

sub_02FE45:
	jsr	a:sub_02FDC6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FE57,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FE57:
	.addr	sub_02FE5D
	.addr	sub_02FE7D
	.addr	sub_02FE8B

sub_02FE5D:
	lda	#$3E4F
	sta	$02,x
	jsr	a:sub_02FF27
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

sub_02FE7D:
	inc	$00,x
	lda	$00,x
	cmp	#$0032
	bcc	loc_02FE8A
	stz	$00,x
	inc	$12,x
loc_02FE8A:
	rtl

sub_02FE8B:
	lda	$00,x
	bit	#$0002
	bne	loc_02FE97
	lda	#$3C4F
	bra	loc_02FE9A
loc_02FE97:
	lda	#$3E4F
loc_02FE9A:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	loc_02FEB6
loc_02FEA5:
	stx	zp_00
	lda	#$0000
	ldy	#$0000
loc_02FEAD:
	sta	(zp_00),y
	iny
	iny
	cpy	#$0020
	bcc	loc_02FEAD
loc_02FEB6:
	rtl

sub_02FEB7:
	jsr	a:sub_02FDC6
	lda	$12,x
	phx
	asl	a
	tax
	lda	f:tbl_02FEC9,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_02FEC9:
	.addr	sub_02FECF
	.addr	sub_02FEF7
	.addr	sub_02FEFA

sub_02FECF:
	lda	#$3E4F
	sta	$02,x
	jsr	a:sub_02FF27
	asl	zp_08
	rol	zp_00
	asl	zp_0A
	rol	zp_02
	lda	zp_08
	sta	$18,x
	lda	zp_00
	sta	$1A,x
	lda	zp_0A
	sta	$1C,x
	lda	$1E,x
	clc
	adc	zp_02
	sta	$1E,x
	stz	$00,x
	inc	$12,x
	rtl

sub_02FEF7:
	jmp	a:sub_02FE7D

sub_02FEFA:
	lda	$00,x
	bit	#$0002
	bne	loc_02FF06
	lda	#$324F
	bra	loc_02FF09
loc_02FF06:
	lda	#$384F
loc_02FF09:
	sta	$02,x
	inc	$00,x
	lda	$00,x
	cmp	#$0046
	bcc	loc_02FEB6
	jmp	a:loc_02FEA5

sub_02FF17:
	lda	rng_lo
	sta	zp_08
	eor	#$EA9E
	ror	a
	sta	zp_0A
	adc	zp_E9
	sta	rng_lo
	bra	loc_02FF4B

sub_02FF27:
	lda	$04,x
	lsr	a
	lsr	a
	lsr	a
	asl	a
	tay
	lda	a:data_05E744,y
	and	#$00FF
	sta	zp_00
	tay
	lda	$04,x
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	#$0010
	and	#$00FF
	sta	zp_00
	jsl	f:sub_1DACA4
loc_02FF4B:
	lda	zp_08
	bmi	loc_02FF54
	lda	#$0000
	bra	loc_02FF57
loc_02FF54:
	lda	#$FFFF
loc_02FF57:
	sta	zp_00
	lda	zp_08
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_08
	lda	zp_0A
	bmi	loc_02FF6D
	lda	#$0000
	bra	loc_02FF70
loc_02FF6D:
	lda	#$FFFF
loc_02FF70:
	sta	zp_02
	lda	zp_0A
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	zp_0A
	rts
	; CDL: not accessed
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF
