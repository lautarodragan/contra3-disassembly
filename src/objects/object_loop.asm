; objects/object_loop.asm -- Object loop and type dispatcher
; Bank $00, $00:E960-$00:EB19. Included by main.asm in segment BANK00.
;
; The main object list: slots of $40 bytes from $0200 (players at $0200 and
; $0240). sub_00E960 draws the players, sub_00E989 (and sub_00E97E for
; $0280-$02FF) runs slots $0300-$0ABF: moves them by their velocity and calls
; the handler of the type at +$10 through 161 long pointers at tbl_05A48A
; (sub_00EB04, JML [$00]).

sub_00E960:
	ldx	#$0200
	lda	zp_BC
	bne	loc_00E96A
	ldx	#$0240
loc_00E96A:
	ldy	$00,x
	beq	loc_00E971
	jsr	a:sub_00EB1A
loc_00E971:
	txa
	eor	#$0040
	tax
	ldy	$00,x
	beq	loc_00E97D
	jsr	a:sub_00EB1A
loc_00E97D:
	rtl

sub_00E97E:
	ldx	#$0280
	lda	#$0300
	sta	a:wram_166A
	bra	loc_00E997

sub_00E989:
	lda	#$15A0
	sta	zp_AA
	lda	#$0AC0
	sta	a:wram_166A
	ldx	#$0300
loc_00E997:
	lda	$10,x
	bne	loc_00E99E
	brl	loc_00EAF1
loc_00E99E:
	lda	$16,x
	bit	#$0001
	beq	loc_00E9C9
	clc
	lda	$08,x
	adc	$18,x
	sta	$08,x
	lda	$0A,x
	adc	$1A,x
	sec
	sbc	a:wram_138E
	sta	$0A,x
	clc
	lda	$0C,x
	adc	$1C,x
	sta	$0C,x
	lda	$0E,x
	adc	$1E,x
	sec
	sbc	a:wram_13A6
	sta	$0E,x
	lda	$16,x
loc_00E9C9:
	bit	#$0002
	beq	loc_00E9EE
	lda	$0A,x
	cmp	#$0120
	bcc	loc_00E9DD
	cmp	#$FFE0
	bcs	loc_00E9DD
	brl	loc_00EAB0
loc_00E9DD:
	lda	$0E,x
	cmp	#$0120
	bcc	loc_00E9EC
	cmp	#$FFE0
	bcs	loc_00E9EC
	brl	loc_00EAB0
loc_00E9EC:
	lda	$16,x
loc_00E9EE:
	bit	#$0010
	beq	loc_00EA0B
	lda	$0A,x
	adc	$28,x
	sta	$2C,x
	lda	$0E,x
	adc	$2A,x
	sta	$2E,x
	ldy	zp_AA
	txa
	sta	a:$0000,y
	inc	zp_AA
	inc	zp_AA
	lda	$16,x
loc_00EA0B:
	bit	#$0008
	beq	loc_00EA76
	ldy	#$0200
	lda	zp_BC
	beq	loc_00EA1A
	ldy	#$0240
loc_00EA1A:
	lda	a:$0016,y
	beq	loc_00EA76
	lda	a:$0028,y
	cmp	$0A,x
	bmi	loc_00EA76
	lda	a:$002A,y
	cmp	$0E,x
	bpl	loc_00EA76
	lda	$0A,x
	adc	$28,x
	cmp	a:$0006,y
	bmi	loc_00EA76
	lda	$0E,x
	adc	$2A,x
	cmp	a:$0010,y
	bpl	loc_00EA76
	lda	a:$0016,y
	bmi	loc_00EA76
	sty	$3C,x
	bit	#$0002
	bne	loc_00EA76
	lda	a:$1D88,y
	beq	loc_00EA6E
	lda	$16,x
	bit	#$0010
	beq	loc_00EA69
	; (not executed in the CDL traces)
	bit	#$0020
	bne	loc_00EA69
	lda	$06,x
	bmi	loc_00EA67
	dec	$06,x
	lda	#$0001
	sta	$14,x
loc_00EA67:
	lda	$16,x
loc_00EA69:
	and	#$FFFB
	bra	loc_00EA70
loc_00EA6E:
	lda	$16,x
loc_00EA70:
	ora	a:$003C,y
	sta	a:$003C,y
loc_00EA76:
	ldy	$20,x
	beq	loc_00EAA8
	dec	$22,x
	bmi	loc_00EA91
	bne	loc_00EAA8
	tya
	clc
	adc	#$0006
loc_00EA85:
	tay
	lda	a:$0000,y
	bmi	loc_00EA85
	beq	loc_00EA96
	sty	$20,x
	bra	loc_00EA98
loc_00EA91:
	lda	a:$0000,y
	bne	loc_00EA98
loc_00EA96:
	sta	$20,x
loc_00EA98:
	sta	$22,x
	lda	$04,x
	beq	loc_00EAA3
	lda	a:$0004,y
	bra	loc_00EAA6
loc_00EAA3:
	lda	a:$0002,y
loc_00EAA6:
	sta	$00,x
loc_00EAA8:
	jsl	f:sub_00EB04
	lda	$16,x
	bpl	loc_00EABE
loc_00EAB0:
	phx
	stz	$00,x
	txy
	iny
	lda	#$003E
	mvn	#$05, #$05
	plx
	bra	loc_00EAF1
loc_00EABE:
	lda	$26,x
	bne	loc_00EADB
	lda	$14,x
	beq	loc_00EAE1
	lda	$16,x
	bit	#$0020
	bne	loc_00EAE1
	lda	$02,x
	sta	$26,x
	and	#$3000
	ora	#$0200
	sta	$02,x
	bra	loc_00EAE1
loc_00EADB:
	lda	$26,x
	sta	$02,x
	stz	$26,x
loc_00EAE1:
	ldy	$00,x
	beq	loc_00EAEF
	lda	zp_AE
	cmp	#$11E0
	bcs	loc_00EAEF
	jsr	a:sub_00EB1A
loc_00EAEF:
	stz	$14,x
loc_00EAF1:
	clc
	txa
	adc	#$0040
	tax
	cmp	a:wram_166A
	bcs	loc_00EAFF
	brl	loc_00E997
loc_00EAFF:
	ldx	zp_AA
	stz	$00,x
	rtl

sub_00EB04:
	lda	$10,x
	sta	zp_00
	asl	a
	clc
	adc	zp_00
	tay
	lda	a:tbl_05A48A,y
	sta	zp_00
	lda	a:tbl_05A48A+2,y
	sta	zp_02
	jml	[zp_00]
