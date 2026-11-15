; sound/spc_upload.asm -- Sound CPU upload
; Bank $00, $00:9324-$00:949B. Included by main.asm in segment BANK00.
;
; Upload of the sound program and data to the sound CPU through APUIO0-3 (the
; IPL transfer protocol); block lists come from bank $05, the data from banks
; $1A-$1F.

sub_009324:
	ldy	$1A	; $135A (D=$1340)
	cpy	$0C	; $134C (D=$1340)
	beq	loc_009340
	sep	#$20
loc_00932C:
	.a8
	lda	[$03],y	; $1343 (D=$1340)
	sta	[$20]	; $1360 (D=$1340)
	ldx	$20	; $1360 (D=$1340)
	inx
	stx	$20	; $1360 (D=$1340)
	iny
	cpy	$0C	; $134C (D=$1340)
	bne	loc_00932C
	rep	#$20
	.a16
	lda	$0C	; $134C (D=$1340)
	sta	$1A	; $135A (D=$1340)
loc_009340:
	rtl

sub_009341:
	php
	phd
	ldy	#$1F00
	lda	#$2C00
	jsr	a:sub_009271
	and	#$0001
	sta	$16	; $1F16 (D=$1F00)
	beq	loc_009356
	; (not executed in the CDL traces)
	brl	loc_009102
loc_009356:
	jsl	f:sub_00937B
loc_00935A:
	rep	#$20
	ldx	$18	; $1F18 (D=$1F00)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_00936A
	brl	loc_0090FA
loc_00936A:
	cmp	#$FFFE
	bne	loc_009375
	jsl	f:sub_009429
	bra	loc_00935A
loc_009375:
	jsl	f:sub_009479
	bra	loc_00935A

sub_00937B:
	rep	#$20
	lda	#$BBAA
	stz	$20	; $1F20 (D=$1F00)
loc_009382:
	cmp	a:APUIO0
	bne	loc_009382
	sep	#$20
	.a8
	lda	#$01
	sta	a:APUIO1
	lda	#$CC
	sta	a:APUIO0
	jsr	a:sub_0093A6
	lda	#$00
	sta	a:APUIO0
	jsr	a:sub_0093A6
	rep	#$20
	.a16
	lda	#$0001
	sta	$20	; $1F20 (D=$1F00)
	rtl

sub_0093A6:
	.a8
	cmp	a:APUIO0
	bne	sub_0093A6
	rts

sub_0093AC:
	.a16
	rep	#$20
	rep	#$10
	lda	$22	; $1F22 (D=$1F00)
	sta	a:APUIO2
	sep	#$20
	.a8
	lda	#$01
	sta	a:APUIO1
	lda	$20	; $1F20 (D=$1F00)
	inc	a
	sta	a:APUIO0
	jsr	a:sub_0093A6
	stz	$20	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	rtl

sub_0093CA:
	rep	#$20
	ldy	$1A	; $1F1A (D=$1F00)
	cpy	$0C	; $1F0C (D=$1F00)
	beq	loc_0093ED
	sep	#$20
loc_0093D4:
	.a8
	lda	[$03],y	; $1F03 (D=$1F00)
	iny
	sta	a:APUIO1
	xba
	lda	$20	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	inc	$20	; $1F20 (D=$1F00)
	sta	a:APUIO0
	sep	#$20
	.a8
	jsr	a:sub_0093A6
	cpy	$0C	; $1F0C (D=$1F00)
	bne	loc_0093D4
loc_0093ED:
	lda	$10	; $1F10 (D=$1F00)
	beq	loc_0093F8
	rep	#$20
	.a16
	lda	$0C	; $1F0C (D=$1F00)
	sta	$1A	; $1F1A (D=$1F00)
	rtl
loc_0093F8:
	.a8
	rep	#$20
	.a16
	ldx	$18	; $1F18 (D=$1F00)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_009408
	brl	loc_00940B
loc_009408:
	rep	#$20
	rtl
loc_00940B:
	rep	#$20
	lda	$22	; $1F22 (D=$1F00)
	sta	a:APUIO2
	sep	#$20
	.a8
	inc	$20	; $1F20 (D=$1F00)
	lda	#$00
	sta	a:APUIO1
	lda	$20	; $1F20 (D=$1F00)
	sta	a:APUIO0
	jsr	a:sub_0093A6
	stz	a:APUIO0
	rep	#$20
	.a16
	rtl

sub_009429:
	rep	#$20
	stz	$10	; $1F10 (D=$1F00)
	stz	$1C	; $1F1C (D=$1F00)
	ldx	$18	; $1F18 (D=$1F00)
	lda	f:$050002,x
	sta	$22	; $1F22 (D=$1F00)
	lda	f:$050004,x
	sta	$00	; $1F00 (D=$1F00)
	sep	#$20
	.a8
	lda	f:$050006,x
	sta	$02	; $1F02 (D=$1F00)
	rep	#$20
	.a16
	lda	f:$050007,x
	sta	$06	; $1F06 (D=$1F00)
	txa
	clc
	adc	#$0009
	sta	$18	; $1F18 (D=$1F00)
	jsl	f:sub_0093AC
	ldy	#$0000
	sep	#$20
loc_00945D:
	.a8
	lda	[$00],y	; $1F00 (D=$1F00)
	iny
	sta	a:APUIO1
	xba
	lda	$20	; $1F20 (D=$1F00)
	rep	#$20
	.a16
	inc	$20	; $1F20 (D=$1F00)
	sta	a:APUIO0
	sep	#$20
	.a8
	jsr	a:sub_0093A6
	cpy	$06	; $1F06 (D=$1F00)
	bne	loc_00945D
	brl	loc_0093F8

sub_009479:
	.a16
	rep	#$20
	stz	$10	; $1F10 (D=$1F00)
	stz	$1C	; $1F1C (D=$1F00)
	ldx	$18	; $1F18 (D=$1F00)
	lda	f:$050000,x
	sta	$22	; $1F22 (D=$1F00)
	inx
	inx
	stx	$18	; $1F18 (D=$1F00)
	jsl	f:sub_0093AC
loc_00948F:
	jsl	f:sub_00949C
	jsl	f:sub_0093CA
	ldx	$10	; $1F10 (D=$1F00)
	bne	loc_00948F
	rtl
