; engine/palette_tasks.asm -- Palette tasks and VRAM script tasks
; Bank $00, $00:9971-$00:9C17. Included by main.asm in segment BANK00.
;
; Eight task slots of $10 bytes at $1200 (sub_009982/sub_009985 start one from
; a script in Y; sub_009995 runs them each frame through tbl_0099C1): copy
; palettes from bank $08 to the WRAM buffer, and fade them. sub_009B76 runs a
; second kind of task (slots at $1280) that appends entries to the VRAM
; transfer list.

sub_009971:
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	rtl

sub_009982:
	ldx	#$1200

sub_009985:
	jsl	f:sub_009971
	lda	a:$0000,y
	and	#$00FF
	sta	$00,x
	iny
	sty	$02,x
	rtl

sub_009995:
	rep	#$20
	rep	#$10
	ldx	#$1200
loc_00999C:
	stx	$FC
	lda	$00,x
	beq	loc_0099A6
	jsl	f:sub_0099B3
loc_0099A6:
	lda	$FC
	clc
	adc	#$0010
	tax
	cpx	#$1280
	bcc	loc_00999C
	rtl

sub_0099B3:
	dec	a
	phx
	asl	a
	tax
	lda	f:tbl_0099C1,x
	plx
	sta	$00
	jmp	($0000)
tbl_0099C1:
	.addr	sub_0099C9
	.addr	sub_009A19
	.addr	sub_009AA5
	.addr	sub_009A81

sub_0099C9:
	lda	$08,x
	beq	loc_0099D0
	; (not executed in the CDL traces)
	dec	$08,x
	rtl
loc_0099D0:
	ldy	$02,x
	lda	a:$0000,y
	and	#$00FF
	sta	$08,x
loc_0099DA:
	lda	$02,x
	clc
	adc	$06,x
	tay
	lda	a:$0002,y
	beq	loc_009A03
	phb
	phx
	ldx	a:$0002,y
	lda	a:$0004,y
	tay
	lda	f:$080000,x
	inx
	inx
	mvn	#$08, #$7E
	plx
	plb
	lda	$06,x
	clc
	adc	#$0004
	sta	$06,x
	bra	sub_0099C9
loc_009A03:
	inc	$04,x
	stz	$06,x
	ldy	$02,x
	lda	a:$0000,y
	bmi	loc_0099DA
	xba
	and	#$00FF
	cmp	$04,x
	bcs	loc_0099DA
	jmp	a:sub_009971

sub_009A19:
	; (not executed in the CDL traces)
	ldy	$02,x
	lda	$04,x
	xba
	and	#$00FF
	sta	$04
	lda	a:$0000,y
	and	#$00FF
	bne	loc_009A2E
	lda	#$0010
loc_009A2E:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	$04,x
	cmp	#$2000
	bcc	loc_009A3D
	brl	sub_009971
loc_009A3D:
	sta	$04,x
	xba
	and	#$00FF
	sec
	sbc	$04
	beq	loc_009A52
	sta	$02
loc_009A4A:
	jsl	f:sub_009A53
	dec	$02
	bne	loc_009A4A
loc_009A52:
	rtl

sub_009A53:
	; (not executed in the CDL traces)
	lda	a:$0003,y
	sta	$00
	ldx	a:$0001,y
loc_009A5B:
	sec
	lda	f:$7E0000,x
	bit	#$001F
	beq	loc_009A66
	dec	a
loc_009A66:
	bit	#$03E0
	beq	loc_009A6E
	sbc	#$0020
loc_009A6E:
	bit	#$7C00
	beq	loc_009A76
	sbc	#$0400
loc_009A76:
	sta	f:$7E0000,x
	inx
	inx
	cpx	$00
	bcc	loc_009A5B
	rtl

sub_009A81:
	ldy	$02,x
	lda	a:$0000,y
	and	#$00FF
	bne	loc_009A8E
	; (not executed in the CDL traces)
	lda	#$0010
loc_009A8E:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	$04,x
	cmp	#$2000
	bcc	loc_009A9D
	brl	sub_009971
loc_009A9D:
	sta	$04,x
	xba
	and	#$00FF
	bra	loc_009ACA

sub_009AA5:
	ldy	$02,x
	lda	a:$0000,y
	and	#$00FF
	bne	loc_009AB2
	; (not executed in the CDL traces)
	lda	#$0010
loc_009AB2:
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	$04,x
	cmp	#$2000
	bcc	loc_009AC1
	brl	sub_009971
loc_009AC1:
	sta	$04,x
	xba
	and	#$00FF
	eor	#$001F
loc_009ACA:
	sta	$08
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$0A
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	sta	$0C
	ldx	a:$0003,y
	lda	a:$0001,y
	tay
	sep	#$20
	.a8
	lda	#$08
	pha
	plb
	rep	#$20
	.a16
	lda	a:$0000,y
	sta	$02
loc_009AEE:
	lda	a:$0002,y
	and	#$001F
	sec
	sbc	$08
	bpl	loc_009AFC
	lda	#$0000
loc_009AFC:
	sta	$00
	lda	a:$0002,y
	and	#$03E0
	sec
	sbc	$0A
	bpl	loc_009B0C
	lda	#$0000
loc_009B0C:
	ora	$00
	sta	$00
	lda	a:$0002,y
	and	#$7C00
	sec
	sbc	$0C
	bpl	loc_009B1E
	lda	#$0000
loc_009B1E:
	ora	$00
	sta	f:$7E0000,x
	inx
	inx
	iny
	iny
	dec	$02
	dec	$02
	bpl	loc_009AEE
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_009B37:
	; (not executed in the CDL traces)
	jsl	f:sub_009B4A
	bne	loc_009B46
	ldy	$FC
	sty	$0A,x
	lda	a:$0010,y
	sta	$0C,x
loc_009B46:
	rtl
	; CDL: not accessed
	.byte	$A2, $80, $12

sub_009B4A:
	; (not executed in the CDL traces)
	lda	a:$0000,y
	beq	loc_009B53
	lda	$00,x
	bne	loc_009B64
loc_009B53:
	jsl	f:sub_009B65
	lda	a:$0000,y
	sta	$00,x
	lda	a:$0002,y
	sta	$02,x
	lda	#$0000
loc_009B64:
	rtl

sub_009B65:
	; (not executed in the CDL traces)
	stz	$00,x
	stz	$02,x
	stz	$04,x
	stz	$06,x
	stz	$08,x
	stz	$0A,x
	stz	$0C,x
	stz	$0E,x
	rtl

sub_009B76:
	ldx	#$1280
	lda	$3A
	lsr	a
	bcs	loc_009B81
	ldx	#$1290
loc_009B81:
	stx	$FC
	lda	$00,x
	beq	loc_009B8B
	; (not executed in the CDL traces)
	jsl	f:sub_009B98
loc_009B8B:
	clc
	lda	$FC
	adc	#$0020
	tax
	cpx	#$1300
	bcc	loc_009B81
	rtl

sub_009B98:
	; (not executed in the CDL traces)
	dec	a
	phx
	asl	a
	tax
	lda	f:tbl_009BA6,x
	plx
	sta	$00
	jmp	($0000)
tbl_009BA6:
	.addr	sub_009BA8

sub_009BA8:
	; (not executed in the CDL traces)
	lda	$08,x
	beq	loc_009BAF
	dec	$08,x
	rtl
loc_009BAF:
	lda	$02,x
	sta	$00
	lda	($00)
	sta	$08,x
loc_009BB7:
	inc	$06,x
	inc	$06,x
	ldy	$06,x
	iny
	iny
	lda	($00),y
	beq	loc_009C06
	ldx	$4E
	tay
loc_009BC6:
	lda	a:$0000,y
	beq	loc_009C00
	sta	f:$7E0000,x
	lda	a:$0002,y
	sta	f:$7E0002,x
	lda	a:$0004,y
	sta	f:$7E0004,x
	lda	a:$0006,y
	sta	f:$7E0006,x
	lda	a:$0008,y
	sta	f:$7E0008,x
	lda	a:$0009,y
	sta	f:$7E0009,x
	tya
	clc
	adc	#$000B
	tay
	txa
	clc
	adc	#$000B
	tax
	bra	loc_009BC6
loc_009C00:
	stx	$4E
	ldx	$FC
	bra	sub_009BA8
loc_009C06:
	inc	$04,x
	stz	$06,x
	ldy	#$0002
	lda	($00),y
	bmi	loc_009BB7
	cmp	$04,x
	bcs	loc_009BB7
	jmp	a:sub_009B65
