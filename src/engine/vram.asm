; engine/vram.asm -- VRAM transfer queue and VRAM helpers
; Bank $00, $00:8CFF-$00:90A7. Included by main.asm in segment BANK00.
;
; sub_008CFF (called from NMI) runs the queue of DMA transfers built in WRAM
; at $7E0000 by sub_008D41..sub_008DB0; sub_008DBE resets the screen;
; sub_008E0A..sub_008E4B fill VRAM; sub_009015/sub_009024 queue transfers.

sub_008CFF:
	ldx	#$3000
loc_008D02:
	cpx	$4E
	bcs	loc_008CF4
	lda	f:$7E0004,x
	sta	a:VMADDL
	lda	f:$7E0006,x
	sta	a:A1T0L
	lda	f:$7E0009,x
	sta	a:DAS0L
	lda	f:$7E0002,x
	sta	a:DMAP0
	sep	#$20
	.a8
	lda	f:$7E0000,x
	sta	a:VMAIN
	lda	f:$7E0008,x
	sta	a:A1B0
	lda	#$01
	sta	a:MDMAEN
	rep	#$20
	.a16
	txa
	clc
	adc	#$000B
	tax
	bra	loc_008D02

sub_008D41:
	lda	#$0080

sub_008D44:
	ldx	$4E
	sta	f:$7E0000,x
	tya
	sta	f:$7E0004,x
	lda	#$1801
	sta	f:$7E0002,x
	lda	$50
	sta	f:$7E0006,x
	lda	#$007E
	sta	f:$7E0008,x
	txa
	clc
	adc	#$000B
	sta	$4E
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008D6B:
	; (not executed in the CDL traces)
	ldx	$4E
	lda	#$0000
	sta	f:$7E0000,x
	tya
	sta	f:$7E0004,x
	lda	#$1800
	sta	f:$7E0002,x
	lda	$50
	sta	f:$7E0006,x
	lda	#$007E
	sta	f:$7E0008,x
	txa
	clc
	adc	#$000B
	sta	$4E
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008D95:
	; (not executed in the CDL traces)
	phb
	sep	#$20
	.a8
	ldx	$50
	sta	f:$7E0000,x
	inx
	stx	$50
	rep	#$20
	.a16
	plb
	rtl

sub_008DA5:
	ldx	$50
	sta	f:$7E0000,x
	inx
	inx
	stx	$50
	rtl

sub_008DB0:
	ldx	$4E
	sec
	lda	$50
	sbc	f:$7DFFFB,x
	sta	f:$7DFFFE,x
	rtl

sub_008DBE:
	stz	$46
	stz	$44
	lda	#$2200
	sta	$48
	lda	#$0004
	sta	$3E
	lda	#$0009
	sta	a:$1E84
	stz	a:$1E8A
	lda	#$3000
	sta	$4E
	lda	#$3400
	sta	$50
	jsl	f:sub_0085A9
	sep	#$20
	.a8
	rep	#$10
	jsl	f:sub_0088BA
	.a16
	jsl	f:sub_0088E7
	jsl	f:sub_008914
	jsl	f:sub_008E0A
	jsl	f:sub_0088A3
	sep	#$20
	.a8
	jsl	f:sub_0086AC
	rep	#$20
	.a16
	jsl	f:sub_00848F
	rep	#$20
	rtl

sub_008E0A:
	rep	#$10
	ldy	#$7FFF
	ldx	#$0000
	jsl	f:sub_008E4B
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008E17:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$0FFF
	ldx	#$0000
	jsl	f:sub_008E4B
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008E24:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$0FFF
	ldx	#$1000
	jsl	f:sub_008E4B
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008E31:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$03FF
	ldx	#$5800
	jsl	f:sub_008E4B
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008E3E:
	; (not executed in the CDL traces)
	rep	#$10
	ldy	#$03FF
	ldx	#$5800
	jsl	f:sub_008E4B
	rtl

sub_008E4B:
	rep	#$20
	lda	#$0000
	sta	$00
	sep	#$20
	.a8
	lda	#$80
	sta	a:VMAIN
	stx	a:VMADDL
	rep	#$20
	.a16
	lda	$00
loc_008E60:
	sta	a:VMDATAL
	dey
	bpl	loc_008E60
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008E67:
	; (not executed in the CDL traces)
	ldx	#$6000
	ldy	#$4000
	stx	$08
	sty	$0A
	stz	a:VMADDL
	sep	#$10
	.i8
	ldx	#$00
	stx	a:VMAIN
	rep	#$10
	.i16
	lda	#$0004
	sta	$12
	sta	$14
	lda	#$0008
	sta	$16
	lda	#$3400
	sta	$0C
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
loc_008E96:
	.a16
	jsl	f:sub_008EE0
	lda	$08
	clc
	adc	#$0080
	sta	$08
	dec	$12
	bne	loc_008E96
	jsl	f:sub_008F40
	lda	#$3400
	sta	$0C
	lda	$08
	sec
	sbc	#$01F0
	sta	$08
	lda	#$0004
	sta	$12
	dec	$16
	bne	loc_008E96
	lda	#$0008
	sta	$16
	lda	$08
	clc
	adc	#$0380
	sta	$08
	dec	$14
	bne	loc_008E96
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	lda	#$0007
	sta	a:$1E84
	rtl

sub_008EE0:
	; (not executed in the CDL traces)
	ldy	$08
	lda	a:$0000,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$0002,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$0004,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$0006,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$0008,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$000A,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$000C,y
	and	#$00FF
	jsl	f:sub_008F71
	ldy	$08
	lda	a:$000E,y
	and	#$00FF
	jml	f:sub_008F71

sub_008F40:
	; (not executed in the CDL traces)
	sep	#$20
	.a8
	lda	#$05
	pha
	plb
	rep	#$20
	.a16
	sep	#$10
	.i8
	lda	#$1800
	sta	a:DMAP0
	ldx	#$7E
	stx	a:A1B0
	lda	#$0200
	sta	a:DAS0L
	lda	#$3400
	sta	a:A1T0L
	ldx	#$01
	stx	a:MDMAEN
	rep	#$10
	.i16
	sep	#$20
	.a8
	lda	#$7E
	pha
	plb
	rep	#$20
	.a16
	rtl

sub_008F71:
	; (not executed in the CDL traces)
	asl	a
	asl	a
	asl	a
	asl	a
	asl	a
	clc
	adc	$0A
	tay
	sep	#$20
	.a8
	ldx	$0C
	lda	a:$0000,y
	sta	a:$0000,x
	lda	a:$0002,y
	sta	a:$0001,x
	lda	a:$0004,y
	sta	a:$0002,x
	lda	a:$0006,y
	sta	a:$0003,x
	lda	a:$0008,y
	sta	a:$0080,x
	lda	a:$000A,y
	sta	a:$0081,x
	lda	a:$000C,y
	sta	a:$0082,x
	lda	a:$000E,y
	sta	a:$0083,x
	lda	a:$0010,y
	sta	a:$0100,x
	lda	a:$0012,y
	sta	a:$0101,x
	lda	a:$0014,y
	sta	a:$0102,x
	lda	a:$0016,y
	sta	a:$0103,x
	lda	a:$0018,y
	sta	a:$0180,x
	lda	a:$001A,y
	sta	a:$0181,x
	lda	a:$001C,y
	sta	a:$0182,x
	lda	a:$001E,y
	sta	a:$0183,x
	rep	#$20
	.a16
	txa
	clc
	adc	#$0004
	sta	$0C
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008FE8:
	; (not executed in the CDL traces)
	stx	$F4
	inc	$F6
	jsl	f:sub_009024
	bra	loc_009012

; (no caller found; decoded because it follows the end of a routine)
sub_008FF2:
	; (not executed in the CDL traces)
	ldx	$F4
	beq	loc_009012
	jsl	f:sub_008D41
	rep	#$20
	lda	$F2
	jsl	f:sub_008DA5
	lda	$F8
	ldx	$F4
	inc	$F6
	jsl	f:sub_00901E
	lda	$F6
	bne	loc_009012
	stz	$F4
loc_009012:
	stz	$F6
	rtl

sub_009015:
	sta	$04
	lda	#$0001
	sta	$02
	bra	loc_009032

; (no caller found; decoded because it follows the end of a routine)
sub_00901E:
	; (not executed in the CDL traces)
	stz	$02
	sta	$04
	bra	loc_009032

sub_009024:
	lda	#$0001
	sta	$02
	bra	loc_00902D
	; CDL: not accessed
	.byte	$64, $02
loc_00902D:
	lda	#$2000
	sta	$04
loc_009032:
	stx	$00
	lda	$02
	beq	loc_00904D
loc_009038:
	ldx	$00
	ldy	a:$0000,x
	inx
	inx
	stx	$00
	jsl	f:sub_008D41
	lda	$F6
	beq	loc_00904B
	; (not executed in the CDL traces)
	sty	$F2
loc_00904B:
	stz	$02
loc_00904D:
	ldx	$00
	lda	a:$0000,x
	inx
	stx	$00
	and	#$00FF
	cmp	#$00FF
	beq	loc_00909F
	cmp	#$00FE
	beq	loc_009099
	cmp	#$00FD
	beq	loc_00908F
	ldy	$F0
	beq	loc_00906E
	lda	#$0000
loc_00906E:
	ora	$04
	jsl	f:sub_008DA5
	lda	$F6
	beq	loc_00904D
	; (not executed in the CDL traces)
	ldx	$00
	stx	$F4
	lda	$04
	sta	$F8
	inc	$F2
	lda	a:$0000,x
	and	#$00FF
	cmp	#$00FF
	beq	loc_00909F
	bra	loc_0090A3
loc_00908F:
	lda	a:$0000,x
	inx
	stx	$00
	sta	$05
	bra	loc_00904D
loc_009099:
	jsl	f:sub_008DB0
	bra	loc_009038
loc_00909F:
	stz	$F0
	stz	$F6
loc_0090A3:
	jsl	f:sub_008DB0
	rtl
