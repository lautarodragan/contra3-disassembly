; game/attract.asm -- Attract mode: intro, title, demo
; Bank $00, $00:AD7C-$00:B678. Included by main.asm in segment BANK00.
;
; Game modes 0, 3 and 4 and their helpers: the intro (sub_00B4DD, sub-modes
; tbl_00B4F1), the title screen helpers, and the attract demo (sub_00AD7C;
; demo index $1E48; sub_00AECD/sub_00AF11 read data from banks $15/$16,
; probably the recorded inputs). sub_00B2F3..sub_00B39F (never run in the
; traces) look like button-code checks.

sub_00AD7C:
	lda	a:$1C00
	asl	a
	tax
	jmp	(.loword(tbl_00AD84),x)
tbl_00AD84:
	.addr	sub_00AD8A
	.addr	sub_00ADD1
	.addr	sub_00AE15

sub_00AD8A:
	rep	#$30
	phb
	lda	#$0000
	sta	f:$001500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	a:$1E48
	asl	a
	tay
	lda	a:data_0584DA,y
	sta	$86
	jsr	a:sub_00AF40
	jsl	f:sub_04D9F1
	lda	$86
	dec	a
	sta	$70
	jsr	a:sub_00AFE4
	stz	$E6
	stz	$E8
	stz	$EA
	stz	$3A
	stz	$78
	lda	#$0002
	sta	$4A
	lda	#$0800
	sta	$4C
	inc	a:$1C00
	rtl

sub_00ADD1:
	dec	$4C
	beq	loc_00ADFF
	lda	$28
	ora	$2A
	bit	#$1000
	bne	loc_00AE0B
	jsr	a:sub_00AE39
	jsl	f:sub_00ABE0
	lda	a:$1E4A
	beq	loc_00ADFA
	; (not executed in the CDL traces)
	lda	a:$1C08
	cmp	#$0400
	bcs	loc_00ADFF
	lda	a:$1C0B
	cmp	#$0800
	bcs	loc_00ADFF
loc_00ADFA:
	lda	$36
	bne	loc_00ADFF
	rtl
loc_00ADFF:
	stz	$36
	lda	#$0001
	sta	a:$1C02
	inc	a:$1C00
	rtl
loc_00AE0B:
	; (not executed in the CDL traces)
	lda	#$0002
	sta	a:$1C02
	inc	a:$1C00
	rtl

sub_00AE15:
	jsl	f:sub_00B031
	bcs	loc_00AE38
	lda	a:$1E48
	inc	a
	cmp	#$0003
	bcc	loc_00AE27
	lda	#$0000
loc_00AE27:
	sta	a:$1E48
	stz	$46
	stz	$42
	lda	#$0002
	sta	$3E
	lda	a:$1C02
	sta	$36
loc_00AE38:
	rtl

sub_00AE39:
	lda	a:$1E4A
	beq	loc_00AEB2
	; (not executed in the CDL traces)
	jsr	a:sub_00AE44
	jmp	a:loc_00AE7B

sub_00AE44:
	; (not executed in the CDL traces)
	inc	a:$1C04
	lda	$20
	cmp	a:$1C0E
	bne	loc_00AE4F
	rts
loc_00AE4F:
	ldy	#$0000
	lda	a:$1C08
	sta	$00
	lda	a:$1C09
	sta	$01
	lda	a:$1C0E
	sta	[$00],y
	iny
	iny
	lda	a:$1C04
	sta	[$00],y
	lda	$20
	sta	a:$1C0E
	stz	a:$1C04
	lda	a:$1C08
	clc
	adc	#$0004
	sta	a:$1C08
	rts
loc_00AE7B:
	inc	a:$1C06
	lda	$22
	cmp	a:$1C10
	bne	loc_00AE86
	rts
loc_00AE86:
	ldy	#$0000
	lda	a:$1C0B
	sta	$00
	lda	a:$1C0C
	sta	$01
	lda	a:$1C10
	sta	[$00],y
	iny
	iny
	lda	a:$1C06
	sta	[$00],y
	lda	$22
	sta	a:$1C10
	stz	a:$1C06
	lda	a:$1C0B
	clc
	adc	#$0004
	sta	a:$1C0B
	rts
loc_00AEB2:
	jsr	a:sub_00AEB8
	jmp	a:loc_00AEFC

sub_00AEB8:
	lda	a:$1C04
	bne	loc_00AEC0
	jsr	a:sub_00AECD
loc_00AEC0:
	dec	a:$1C04
	beq	sub_00AECD
	lda	a:$1C0E
	sta	$20
	stz	$28
	rts

sub_00AECD:
	ldy	#$0000
	lda	a:$1C08
	sta	$00
	lda	a:$1C09
	sta	$01
	lda	[$00],y
	sta	$20
	eor	a:$1C0E
	and	[$00],y
	sta	$28
	lda	[$00],y
	sta	a:$1C0E
	iny
	iny
	lda	[$00],y
	sta	a:$1C04
	lda	a:$1C08
	clc
	adc	#$0004
	sta	a:$1C08
	rts
loc_00AEFC:
	lda	a:$1C06
	bne	loc_00AF04
	jsr	a:sub_00AF11
loc_00AF04:
	dec	a:$1C06
	beq	sub_00AF11
	lda	a:$1C10
	sta	$22
	stz	$2A
	rts

sub_00AF11:
	ldy	#$0000
	lda	a:$1C0B
	sta	$00
	lda	a:$1C0C
	sta	$01
	lda	[$00],y
	sta	$22
	eor	a:$1C10
	and	[$00],y
	sta	$2A
	lda	[$00],y
	sta	a:$1C10
	iny
	iny
	lda	[$00],y
	sta	a:$1C06
	lda	a:$1C0B
	clc
	adc	#$0004
	sta	a:$1C0B
	rts

sub_00AF40:
	lda	$86
	asl	a
	tay
	lda	a:data_0584DE,y
	sta	a:$1E40
	stz	a:$1FA0
	stz	a:$1FA2
	stz	a:$1FE0
	stz	a:$1FE2
	lda	#$0000
	sta	a:$1FB6
	sta	a:$1FF6
	lda	#$0002
	sta	a:$1FB8
	sta	a:$1FF8
	lda	#$0003
	sta	a:$1F8A
	lda	#$0001
	sta	a:$1F8C
	stz	a:$1FCC
	stz	a:$1FCA
	lda	a:$1E02
	beq	loc_00AF8B
	lda	#$0003
	sta	a:$1FCA
	lda	#$0001
	sta	a:$1FCC
loc_00AF8B:
	lda	#$0002
	sta	$84
	stz	a:$1F80
	stz	a:$1FC0
	stz	a:$1F82
	stz	a:$1FC2
	stz	a:$1F84
	stz	a:$1FC4
	stz	a:$1F86
	stz	a:$1FC6
	stz	a:$1F9E
	stz	a:$1FDE
	stz	a:$1F88
	stz	a:$1FC8
	stz	a:$1F8E
	stz	a:$1FCE
	stz	a:$1600
	stz	a:$1E42
	lda	#$0020
	sta	$94
	lda	#$0010
	sta	$96
	lda	#$4000
	sta	$88
	lda	#$8000
	sta	$8A
	lda	#$8000
	sta	$92
	lda	#$0080
	sta	$8C
	lda	#$0010
	sta	$8E
	rts

sub_00AFE4:
	stz	a:$1C04
	stz	a:$1C06
	stz	a:$1C0E
	stz	a:$1C10
	lda	a:$1E4A
	beq	loc_00B00F
	; (not executed in the CDL traces)
	lda	#$0000
	sta	a:$1C08
	lda	#$0400
	sta	a:$1C0B
	sep	#$20
	.a8
	lda	#$70
	sta	a:$1C0A
	sta	a:$1C0D
	rep	#$20
	.a16
	bra	loc_00B030
loc_00B00F:
	lda	a:$1E48
	asl	a
	clc
	adc	a:$1E48
	tay
	lda	a:data_0584EC,y
	sta	a:$1C08
	lda	a:data_0584ED,y
	sta	a:$1C09
	lda	a:data_0584F5,y
	sta	a:$1C0B
	lda	a:data_0584F6,y
	sta	a:$1C0C
loc_00B030:
	rts

sub_00B031:
	lda	$86
	cmp	#$0002
	beq	loc_00B055
	cmp	#$0005
	beq	loc_00B055
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00B04D
	dec	a:$1E80
	sec
	rtl
loc_00B04D:
	lda	#$0080
	sta	a:$1E80
	clc
	rtl
loc_00B055:
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00B083
	dec	a:$1E80
	lda	a:$1FB4
	and	#$000F
	dec	a
	bpl	loc_00B06F
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B06F:
	sta	a:$1FB4
	lda	a:$1FF4
	and	#$000F
	dec	a
	bpl	loc_00B07E
	; (not executed in the CDL traces)
	lda	#$0080
loc_00B07E:
	sta	a:$1FF4
	sec
	rtl
loc_00B083:
	lda	#$0080
	sta	a:$1E80
	sta	a:$1FB4
	sta	a:$1FF4
	clc
	rtl

sub_00B091:
	jsl	f:sub_008DBE
	jsr	a:sub_00B0F7
	jsr	a:sub_00B0AB
	jsr	a:sub_00B153
	lda	#$000F
	sta	a:$1C04
	lda	#$000F
	sta	a:$1E80
	rtl

sub_00B0AB:
	lda	#$000F
	sta	a:$1E84
	lda	#$0000
	sta	a:$1E9E
	stz	a:$1EA0
	stz	a:$1EA2
	sta	a:$1EA4
	lda	#$0080
	sta	a:$1EA6
	lda	#$0040
	sta	a:$1EA8
	lda	#$0000
	sta	a:$1380
	lda	#$0000
	sta	a:$1398
	stz	a:$1EAA
	rts

sub_00B0DC:
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsr	a:sub_00B0F7
	jsr	a:sub_00B125
	jsr	a:sub_00B153
	lda	#$000F
	sta	a:$1C04
	stz	a:$1E80
	rtl

sub_00B0F7:
	ldy	#$8558
	ldx	#$1210
	jsl	f:sub_009985
	ldy	#$854B
	jsl	f:sub_009982
	ldx	#.loword(data_058527)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058530)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058539)
	jsl	f:sub_0090A8
	ldx	#.loword(data_058542)
	jsl	f:sub_0090A8
	rts

sub_00B125:
	lda	#$000F
	sta	a:$1E84
	lda	#$0100
	sta	a:$1E9E
	stz	a:$1EA0
	stz	a:$1EA2
	sta	a:$1EA4
	lda	#$0080
	sta	a:$1EA6
	sta	a:$1EA8
	lda	#$0000
	sta	a:$1380
	lda	#$0000
	sta	a:$1398
	stz	a:$1EAA
	rts

sub_00B153:
	ldx	#$8561
	jsl	f:sub_009024
	ldx	#$8599
	jsl	f:sub_009024
	ldx	#$85A6
	jsl	f:sub_009024
	ldx	#$85B4
	jsl	f:sub_009024
	ldx	#$85C2
	jsl	f:sub_009024
	jsl	f:sub_00B285
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B17B:
	; (not executed in the CDL traces)
	ldy	#$84FE
	jsl	f:sub_00B183
	rts

sub_00B183:
	ldx	a:$0000,y
	cpx	#$FFFF
	bcs	loc_00B1A2
	lda	a:$0002,y
	sta	$00,x
	lda	a:$0004,y
	sta	$02,x
	lda	a:$0005,y
	sta	$03,x
	tya
	clc
	adc	#$0007
	tay
	bra	sub_00B183
loc_00B1A2:
	sep	#$20
	.a8
	lda	a:$0002,y
	sta	a:HDMAEN
	rep	#$20
	.a16
	rtl

sub_00B1AD:
	rep	#$20
	rep	#$10
	lda	a:$1C00
	phx
	asl	a
	tax
	lda	f:tbl_00B1C1,x
	plx
	sta	$00
	jmp	($0000)
tbl_00B1C1:
	.addr	sub_00B1C9
	.addr	sub_00B1E8
	.addr	sub_00B209
	.addr	sub_00B226

sub_00B1C9:
	lda	#$0300
	sta	a:$1C02
	stz	a:$1C08
	stz	a:$1C0A
	stz	a:$1C0C
	stz	a:$1C0E
	stz	a:$1C10
	stz	a:$1C12
	stz	a:$1E60
	inc	a:$1C00
	rtl

sub_00B1E8:
	php
	lda	a:$1E80
	bit	#$0080
	beq	loc_00B1F7
	; (not executed in the CDL traces)
	and	#$000F
	sta	a:$1E80
loc_00B1F7:
	cmp	#$000F
	bcs	loc_00B201
	inc	a:$1E80
	plp
	rtl
loc_00B201:
	plp
	jsr	a:sub_00B2DD
	inc	a:$1C00
	rtl

sub_00B209:
	jsl	f:sub_00B246
	bcs	loc_00B21A
	dec	a:$1C02
	bne	loc_00B21F
	lda	#$0001
	sta	$36
	rtl
loc_00B21A:
	lda	#$0002
	sta	$36
loc_00B21F:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00B220:
	; (not executed in the CDL traces)
	lda	#$0003
	sta	a:$1C00

sub_00B226:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:$1E80
	and	#$000F
	sta	a:$1E80
	beq	loc_00B239
	dec	a:$1E80
	plp
	rtl
loc_00B239:
	lda	#$0080
	sta	a:$1E80
	plp
	lda	#$0003
	sta	$36
	rtl

sub_00B246:
	lda	$28
	ora	$2A
	bit	#$1000
	bne	loc_00B2C3
	bit	#$2C00
	beq	sub_00B285
	lda	#$0300
	sta	a:$1C02
	lda	#$0001
	jsl	f:sub_00868F
	lda	$28
	ora	$2A
	bit	#$2400
	bne	loc_00B277
	dec	a:$1E02
	bpl	sub_00B285
	lda	#$0003
	sta	a:$1E02
	bra	sub_00B285
loc_00B277:
	inc	a:$1E02
	lda	a:$1E02
	cmp	#$0004
	bcc	sub_00B285
	stz	a:$1E02

sub_00B285:
	lda	a:$1E02
	asl	a
	tay
	lda	a:data_05851F,y
	ldx	#$8599
	jsl	f:sub_009015
	lda	a:$1E02
	asl	a
	tay
	lda	a:data_05851D,y
	ldx	#$85A6
	jsl	f:sub_009015
	lda	a:$1E02
	asl	a
	tay
	lda	a:data_05851B,y
	ldx	#$85B4
	jsl	f:sub_009015
	lda	a:$1E02
	asl	a
	tay
	lda	a:data_058519,y
	ldx	#$85C2
	jsl	f:sub_009015
	clc
	rtl
loc_00B2C3:
	lda	a:$1E02
	cmp	#$0003
	beq	loc_00B2D4
	lda	#$006D
	jsl	f:sub_00868F
	sec
	rtl
loc_00B2D4:
	lda	#$0002
	jsl	f:sub_00868F
	sec
	rtl

sub_00B2DD:
	jsl	f:sub_0088A3
	jsl	f:sub_008942
	lda	a:$1E48
	asl	a
	tay
	lda	a:ptrs_0585CB,y
	tax
	jsl	f:sub_0090A8
	rts

; sub_00B2F3, sub_00B346, sub_00B39F: never executed in the CDL traces (found
; by the unreferenced-routine heuristic).  Each compares the d-pad bits of the
; joypads ($20/$22 & $0F00) with a 3-entry sequence and then checks a button:
; probably button-code checks.  DB is assumed to be $05, the game's usual data
; bank (hint): the sequences are then d-pad masks at $05:86D3/86D9/86DF.
; (no caller found; decoded because it follows the end of a routine)
sub_00B2F3:
	; (not executed in the CDL traces)
	lda	a:$1C0A
	bne	loc_00B300
	ldy	#$0000
	sty	a:$1C08
	bra	loc_00B30B
loc_00B300:
	dec	a:$1C0A
	ldy	a:$1C08
	cpy	#$0006
	bcs	loc_00B332
loc_00B30B:
	lda	$20
	ora	$22
	and	#$0F00
	cmp	a:data_0586D3,y
	bne	loc_00B33B
	cpy	#$0000
	bne	loc_00B322
	lda	#$0010
	sta	a:$1C0A
loc_00B322:
	iny
	iny
	sty	a:$1C08
	cpy	#$0006
	bcc	loc_00B33B
	lda	#$000C
	sta	a:$1C0A
loc_00B332:
	lda	$28
	ora	$2A
	bit	#$0040
	bne	loc_00B33D
loc_00B33B:
	clc
	rts
loc_00B33D:
	lda	#$003E
	jsl	f:sub_00868F
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B346:
	; (not executed in the CDL traces)
	lda	a:$1C0E
	bne	loc_00B353
	ldy	#$0000
	sty	a:$1C0C
	bra	loc_00B35E
loc_00B353:
	dec	a:$1C0E
	ldy	a:$1C0C
	cpy	#$0006
	bcs	loc_00B385
loc_00B35E:
	lda	$20
	ora	$22
	and	#$0F00
	cmp	a:data_0586D9,y
	bne	loc_00B38E
	cpy	#$0000
	bne	loc_00B375
	lda	#$0010
	sta	a:$1C0E
loc_00B375:
	iny
	iny
	sty	a:$1C0C
	cpy	#$0006
	bcc	loc_00B38E
	lda	#$000C
	sta	a:$1C0E
loc_00B385:
	lda	$28
	ora	$2A
	bit	#$1000
	bne	loc_00B390
loc_00B38E:
	clc
	rts
loc_00B390:
	lda	#$0043
	jsl	f:sub_00868F
	lda	#$001E
	sta	a:$1E3C
	sec
	rts

; (no caller found; decoded because it follows the end of a routine)
sub_00B39F:
	; (not executed in the CDL traces)
	lda	a:$1C12
	bne	loc_00B3AC
	ldy	#$0000
	sty	a:$1C10
	bra	loc_00B3B7
loc_00B3AC:
	dec	a:$1C12
	ldy	a:$1C10
	cpy	#$0006
	bcs	loc_00B3DE
loc_00B3B7:
	lda	$20
	ora	$22
	and	#$0F00
	cmp	a:data_0586DF,y
	bne	loc_00B3E7
	cpy	#$0000
	bne	loc_00B3CE
	lda	#$0010
	sta	a:$1C12
loc_00B3CE:
	iny
	iny
	sty	a:$1C10
	cpy	#$0006
	bcc	loc_00B3E7
	lda	#$000C
	sta	a:$1C12
loc_00B3DE:
	lda	$28
	ora	$2A
	bit	#$1000
	bne	loc_00B3E9
loc_00B3E7:
	clc
	rts
loc_00B3E9:
	lda	a:$1E02
	cmp	#$0003
	beq	loc_00B3E7
	lda	#$0059
	jsl	f:sub_00868F
	lda	#$0001
	sta	a:$1E60
	sec
	rts

sub_00B400:
	ldx	#$0FC0
	lda	#$11C0
	sta	$12
	lda	#$8000
	sta	$14
	lda	a:$1E56
	sta	$FC
	lda	#$0044
	sta	$FE
	lda	#$8705
	sta	$18
	lda	#$86E5
	sta	$1A
	lda	#$86F5
	sta	$1C
	ldy	#$000E
	jsr	a:sub_00B499
	lda	a:$1E58
	sta	$FC
	lda	#$004C
	sta	$FE
	lda	#$8745
	sta	$18
	lda	#$8715
	sta	$1A
	lda	#$872D
	sta	$1C
	ldy	#$0016
	jsr	a:sub_00B499
	lda	a:$1E5A
	sta	$FC
	lda	#$006C
	sta	$FE
	lda	#$877D
	sta	$18
	lda	#$875D
	sta	$1A
	lda	#$876D
	sta	$1C
	ldy	#$000E
	jsr	a:sub_00B499
	lda	a:$1E5C
	sta	$FC
	lda	#$006C
	sta	$FE
	lda	#$8791
	sta	$18
	lda	#$878D
	sta	$1A
	lda	#$878F
	sta	$1C
	ldy	#$0000
	jsr	a:sub_00B499
loc_00B489:
	sec
	ror	$14
	sec
	ror	$14
	bcc	loc_00B489
	ldy	$12
	lda	$14
	sta	a:$0000,y
	rtl

sub_00B499:
	lda	$FE
	sec
	sbc	a:$1398
	clc
	adc	($1C),y
	sta	a:$0001,x
	lda	$FC
	clc
	adc	($1A),y
	pha
	cmp	#$0100
	ror	$14
	sec
	ror	$14
	bcc	loc_00B4C7
	phy
	ldy	$12
	lda	$14
	sta	a:$0000,y
	iny
	iny
	sty	$12
	lda	#$8000
	sta	$14
	ply
loc_00B4C7:
	pla
	sep	#$20
	.a8
	sta	a:$0000,x
	rep	#$20
	.a16
	lda	($18),y
	sta	a:$0002,x
	inx
	inx
	inx
	inx
	dey
	dey
	bpl	sub_00B499
	rts

sub_00B4DD:
	rep	#$20
	rep	#$10
	lda	a:$1C60
	phx
	asl	a
	tax
	lda	f:tbl_00B4F1,x
	plx
	sta	$00
	jmp	($0000)
tbl_00B4F1:
	.addr	sub_00B507
	.addr	sub_00B551
	.addr	sub_00B586
	.addr	sub_00B59C
	.addr	sub_00B64A
	.addr	sub_00B5B5
	.addr	sub_00B5D3
	.addr	sub_00B64A
	.addr	sub_00B628
	.addr	sub_00B64A
	.addr	sub_00B653

sub_00B507:
	jsl	f:sub_0085DF
	jsl	f:sub_0085A9
	jsl	f:sub_00865C
	jsl	f:sub_008DBE
	jsl	f:sub_00885E
	lda	#$0009
	sta	a:$1E84
	lda	#$0001
	ldx	#.loword(data_0587AB)
	jsl	f:sub_0090A8
	ldy	#$87C3
	jsl	f:sub_009982
	lda	#$0400
	sta	a:$1398
	lda	#$0100
	sta	a:$1380
	sta	a:$13C0
	lda	#$0019
	sta	a:$1E84
	lda	#$0003
	sta	a:$1C66
	inc	a:$1C60
	rtl

sub_00B551:
	lda	$3A
	and	#$0001
	bne	loc_00B573
	lda	a:$1C64
	asl	a
	tay
	ldx	a:data_058793,y
	lda	#$2C00
	jsl	f:sub_009015
	inc	a:$1C64
	lda	a:$1C64
	and	#$0003
	sta	a:$1C64
loc_00B573:
	lda	a:$1380
	sec
	sbc	#$0008
	sta	a:$1380
	bne	loc_00B585
	stz	a:$13C0
	inc	a:$1C60
loc_00B585:
	rtl

sub_00B586:
	lda	$3A
	and	#$0003
	bne	loc_00B59B
	ldx	#$2264
	jsr	a:sub_00B65C
	dec	a:$1C66
	bne	loc_00B59B
	inc	a:$1C60
loc_00B59B:
	rtl

sub_00B59C:
	lda	a:$1398
	sec
	sbc	#$0002
	sta	a:$1398
	and	#$0100
	bne	loc_00B5D2
loc_00B5AB:
	lda	#$0001
	sta	a:$1C6A
	inc	a:$1C60
	rtl

sub_00B5B5:
	lda	#$000A
	sta	a:$1C64
	sta	a:$1C66
	sta	a:$1C68
	ldy	#$87E1
	jsl	f:sub_009982
	lda	#$0072
	jsl	f:sub_00868F
	inc	a:$1C60
loc_00B5D2:
	rtl

sub_00B5D3:
	lda	a:$1C64
	beq	loc_00B5ED
	cmp	#$000A
	bne	loc_00B5E4
	ldy	#$87EA
	jsl	f:sub_009982
loc_00B5E4:
	dec	a:$1C64
	ldx	#$222C
	jsr	a:sub_00B65C
loc_00B5ED:
	lda	a:$1C66
	bmi	loc_00B602
	ldx	#$224C
	jsr	a:sub_00B65C
	dec	a:$1C66
	lda	#$0003
	sta	a:$1C6A
	rtl
loc_00B602:
	lda	a:$1C6A
	beq	loc_00B612
	dec	a:$1C6A
	bne	loc_00B627
	ldy	#$87D8
	jmp	a:sub_009982
loc_00B612:
	lda	a:$1C68
	bmi	loc_00B5AB
	lda	$3A
	and	#$0001
	bne	loc_00B627
	dec	a:$1C68
	ldx	#$220A
	jsr	a:sub_00B65C
loc_00B627:
	rtl

sub_00B628:
	ldx	#$2200
	lda	f:$7E0000,x
	clc
	adc	#$0421
	sta	f:$7E0000,x
	sta	f:$7E0002,x
	cmp	#$7FFF
	bne	loc_00B649
	lda	#$0100
	sta	a:$1C6A
	inc	a:$1C60
loc_00B649:
	rtl

sub_00B64A:
	dec	a:$1C6A
	bne	loc_00B652
	inc	a:$1C60
loc_00B652:
	rtl

sub_00B653:
	dec	a:$1E80
	bne	loc_00B65B
	inc	a:$1C62
loc_00B65B:
	rtl

sub_00B65C:
	lda	f:$7E0000,x
	pha
	inx
	inx
loc_00B663:
	lda	f:$7E0000,x
	sta	f:$7DFFFE,x
	inx
	inx
	txa
	and	#$001F
	bne	loc_00B663
	pla
	sta	f:$7DFFFE,x
	rts
