; sound/sound_load.asm -- Song set loading and sound streaming
; Bank $00, $00:9627-$00:9970. Included by main.asm in segment BANK00.
;
; sub_0098D4 loads a song set (pointer in X) into the sound CPU through
; sub_0098E2; sub_00994F requests one for the main loop (sub_00995A).
; sub_009627..sub_00988E (never run in the traces) stream data through APUIO2.

; (no caller found; decoded because it follows the end of a routine)
sub_009627:
	; (not executed in the CDL traces)
	.a16
	lda	f:$050000,x
	and	#$00FF
	beq	loc_009633
	brl	loc_00978C
loc_009633:
	jsl	f:sub_00863D
	lda	f:$050001,x
	and	#$00FF
	bne	loc_009643
	brl	loc_0096F8
loc_009643:
	php
	phd
	lda	#$1F00
	pha
	pld
	lda	#$2C00
	sta	$03
	sep	#$20
	.a8
	lda	#$7E
	sta	$05
	rep	#$20
	.a16
	stz	$12
	lda	#$0001
	sta	$16
	inx
	inx
	stx	$18
loc_009662:
	ldx	$18
	lda	f:$050000,x
	cmp	#$FFFF
	beq	loc_009672
	jsr	a:sub_00967D
	bra	loc_009662
loc_009672:
	stz	$16
	stz	$12
	stz	$10
	stz	$1C
	pld
	plp
	rtl

sub_00967D:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$26
	stz	$10
	stz	$1C
	stz	$20
	lda	#$AABB
	jsr	a:sub_0096EF
	lda	#$A0B0
	jsr	a:sub_0096EF
	ldx	$18
	lda	f:$050000,x
	sta	$22
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	$22
	rep	#$20
	.a16
	jsr	a:sub_0096EF
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	$23
	rep	#$20
	.a16
	jsr	a:sub_0096EF
	inx
	inx
	stx	$18
loc_0096B8:
	jsl	f:sub_00949C
	jsr	a:sub_0096CA
	ldx	$10
	bne	loc_0096B8
	lda	#$BBAA
	jsr	a:sub_0096EF
	rts

sub_0096CA:
	; (not executed in the CDL traces)
	ldy	$1A
	cpy	$0C
	beq	loc_0096EA
loc_0096D0:
	sep	#$20
	.a8
	lda	$20
	and	#$7F
	xba
	lda	[$03],y
	iny
	rep	#$20
loc_0096DC:
	.a16
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	loc_0096DC
	inc	$20
	cpy	$0C
	bne	loc_0096D0
loc_0096EA:
	lda	$0C
	sta	$1A
	rts

sub_0096EF:
	; (not executed in the CDL traces)
	sta	a:APUIO2
loc_0096F2:
	cmp	a:APUIO2
	bne	loc_0096F2
	rts
loc_0096F8:
	php
	phd
	rep	#$20
	inx
	inx
	stx	$18
loc_009700:
	ldx	$18
	lda	f:$050000,x
	cmp	#$FFFF
	beq	loc_009710
	jsr	a:sub_009713
	bra	loc_009700
loc_009710:
	pld
	plp
	rtl

sub_009713:
	; (not executed in the CDL traces)
	stz	$20
	lda	#$AABB
	jsr	a:sub_0096EF
	lda	#$A0B0
	jsr	a:sub_0096EF
	ldx	$18
	lda	f:$050000,x
	sta	$22
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	$22
	rep	#$20
	.a16
	jsr	a:sub_0096EF
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	$23
	rep	#$20
	.a16
	jsr	a:sub_0096EF
	inx
	inx
	stx	$18
	sep	#$20
	.a8
	lda	f:$050002,x
	sta	$05
	rep	#$20
	.a16
	lda	f:$050000,x
	dec	a
	dec	a
	sta	$03
	inx
	inx
	inx
	stx	$18
	lda	[$03]
	sta	$08
	inc	$03
	inc	$03
	jsr	a:sub_00976E
	lda	#$BBAA
	jsr	a:sub_0096EF
	rts

sub_00976E:
	; (not executed in the CDL traces)
	ldy	#$0000
loc_009771:
	sep	#$20
	.a8
	lda	$20
	and	#$7F
	xba
	lda	[$03],y
	iny
	rep	#$20
	.a16
	sta	a:APUIO2
loc_009780:
	cmp	a:APUIO2
	bne	loc_009780
	inc	$20
	cpy	$08
	bcc	loc_009771
	rts
loc_00978C:
	stx	a:$1F2C
	stz	a:$1F26
	lda	f:$050001,x
	and	#$00FF
	ora	#$C000
	sta	a:$1F2E
	stz	$5A
	stz	$6A
	stz	$16
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_0097A6:
	; (not executed in the CDL traces)
	phd
	ldy	#$1F00
	phy
	pld
	lda	$16
	beq	loc_0097B8
	cmp	#$0004
	beq	loc_0097B8
	brl	loc_00985B
loc_0097B8:
	ldx	$2C
	bne	loc_0097BF
	brl	loc_00985B
loc_0097BF:
	lda	#$0001
	sta	$2A
	sta	$26
	ldx	$2C
	stz	$2C
	stz	$2A
	cpx	#$0000
	bne	loc_0097D4
	brl	loc_00985B
loc_0097D4:
	jsl	f:sub_009341
	lda	#$0001
	sta	$12
	lda	#$0002
	sta	$16
	stz	$10
	stz	$1C
	stz	$20
	lda	#$AABB
	jsl	f:sub_00987B
	lda	#$A0B0
	jsl	f:sub_00987B
	ldx	$18
	sep	#$20
	.a8
	lda	f:$050000,x
	sta	$24
	inx
	rep	#$20
	.a16
	lda	f:$050000,x
	sta	$22
	sep	#$20
	.a8
	lda	#$80
	xba
	lda	$22
	rep	#$20
	.a16
	jsl	f:sub_00987B
	sep	#$20
	.a8
	lda	#$81
	xba
	lda	$23
	rep	#$20
	.a16
	jsl	f:sub_00987B
	inx
	inx
	stx	$18
loc_009827:
	jsl	f:sub_0094A9
	jsl	f:sub_00988E
	lda	$26
	beq	loc_00985D
	ldx	$10
	bne	loc_009827
	lda	#$BBAA
	jsl	f:sub_00987B
	lda	$16
	cmp	#$0002
	bne	loc_00985D
	lda	$24
	and	#$0001
	asl	a
	tax
	lda	$24
	and	#$00FF
	sta	$2E,x
	stz	$16
	stz	$12
	stz	$10
	stz	$1C
loc_00985B:
	pld
	rtl
loc_00985D:
	lda	#$BBAA
	jsl	f:sub_00987B
	lda	$24
	and	#$0001
	asl	a
	tax
	lda	$24
	and	#$00FF
	ora	#$8000
	sta	$2E,x
	lda	#$0004
	sta	$16
	rtl

sub_00987B:
	; (not executed in the CDL traces)
	rep	#$20
	sta	$28
loc_00987F:
	lda	$26
	beq	loc_00988D
	lda	$28
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	loc_00987F
loc_00988D:
	rtl

sub_00988E:
	; (not executed in the CDL traces)
	rep	#$20
	ldy	$1A
	cpy	$0C
	beq	loc_0098B8
loc_009896:
	sep	#$20
	.a8
	lda	$20
	and	#$7F
	xba
	lda	[$03],y
	iny
	rep	#$20
	.a16
	sta	$28
loc_0098A4:
	lda	$26
	beq	loc_0098B8
	lda	$28
	sta	a:APUIO2
	cmp	a:APUIO2
	bne	loc_0098A4
	inc	$20
	cpy	$0C
	bne	loc_009896
loc_0098B8:
	rep	#$20
	lda	$0C
	sta	$1A
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_0098BF:
	; (not executed in the CDL traces)
	rep	#$20
	lda	a:$1F2C
	bne	loc_0098D3
	lda	a:$1F16
	beq	loc_0098D3
	cmp	#$0004
	bne	loc_0098D3
	lda	#$0000
loc_0098D3:
	rtl

sub_0098D4:
	rep	#$30
	lda	#$00FF
	sta	$52
	jsl	f:sub_0098E2
	stz	$52
	rtl

sub_0098E2:
	rep	#$20
	stz	$54
	stz	$56
	stz	$5A
	stz	$6A
	lda	f:$050000,x
	inx
	php
	phd
	ldy	#$1F00
	lda	#$2C00
	jsr	a:sub_009271
	rep	#$20
	and	#$0001
	sta	$16	; $1F16 (D=$1F00)
	jsr	a:sub_00990E
	lda	#$0001
	sta	$20	; $1F20 (D=$1F00)
	jmp	a:loc_00935A

sub_00990E:
	sep	#$20
	.a8
	lda	#$84
	sta	a:APUIO0
loc_009915:
	cmp	a:APUIO0
	bne	loc_009915
	lda	#$FF
loc_00991C:
	sta	a:APUIO0
	cmp	a:APUIO0
	bne	loc_00991C
	lda	#$00
	sta	a:APUIO2
	lda	#$30
	sta	a:APUIO3
	lda	#$01
	sta	a:APUIO1
	xba
	lda	#$CC
	rep	#$20
	.a16
	sta	a:APUIO0
	sep	#$20
loc_00993D:
	.a8
	cmp	a:APUIO0
	bne	loc_00993D
	lda	#$00
	sta	a:APUIO0
loc_009947:
	cmp	a:APUIO0
	bne	loc_009947
	rep	#$20
	.a16
	rts

sub_00994F:
	rep	#$20
	lda	#$00FF
	sta	$52
	stx	a:$1F2C
	rtl

sub_00995A:
	rep	#$20
	lda	$52
	cmp	#$00FF
	bne	loc_009970
	ldx	a:$1F2C
	jsl	f:sub_0098E2
	stz	$54
	stz	$56
	stz	$52
loc_009970:
	rtl
