; engine/gfx_loader.asm -- Loader for graphics/data lists
; Bank $00, $00:90A8-$00:9323. Included by main.asm in segment BANK00.
;
; sub_0090A8 takes, in X, a pointer to a list in bank $05 and loads what it
; names (graphics through the decompressor in engine/decompress.asm, palettes,
; tilemaps); sub_0090C7 runs pending loads each frame. Some of these routines
; run with the direct page moved to a loader context ($1300, $1340 or $1F00;
; see the D= comments).

sub_0090A8:
	rep	#$20
	lda	f:$050000,x
	inx
	and	#$00FF
	beq	loc_0090CE
	cmp	#$0001
	bne	loc_0090BC
	brl	loc_00928F
loc_0090BC:
	cmp	#$0002
	bne	loc_0090C4
	brl	sub_009341
loc_0090C4:
	brl	loc_0091B8

sub_0090C7:
	jsl	f:sub_00910B
	jmp	a:loc_0092BC
loc_0090CE:
	php
	phd
	ldy	#$1300
	lda	#$2400
	jsr	a:sub_009271
	sep	#$20
	.a8
	and	#$01
	bne	loc_009105
loc_0090DF:
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	cmp	#$FFFF
	beq	loc_0090F6
	jsl	f:sub_009155
	bra	loc_0090DF
loc_0090F6:
	jsl	f:enable_nmi
loc_0090FA:
	stz	$16	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	stz	$12	; $1312 (D=$1300) / $1352 (D=$1340) / $1F12 (D=$1F00)
	stz	$10	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	stz	$1C	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
loc_009102:
	pld
	plp
	rtl
loc_009105:
	.a8
	rep	#$20
	.a16
	inc	$12	; $1312 (D=$1300)
	bra	loc_009118

sub_00910B:
	php
	phd
	rep	#$20
	ldy	#$1300
	phy
	pld
	lda	$26	; $1326 (D=$1300)
	bne	loc_009102
loc_009118:
	lda	$12	; $1312 (D=$1300)
	beq	loc_009102
	lda	$10	; $1310 (D=$1300)
	bne	loc_009133
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	cmp	#$FFFF
	beq	loc_0090FA
	sta	$22	; $1322 (D=$1300)
	inx
	inx
	stx	$18	; $1318 (D=$1300)
	stz	$1C	; $131C (D=$1300)
loc_009133:
	stz	$26	; $1326 (D=$1300)
	jsl	f:sub_0094A9
	inc	$26	; $1326 (D=$1300)
	bra	loc_009102

sub_00913D:
	php
	phd
	rep	#$20
	rep	#$10
	ldy	#$1300
	phy
	pld
	lda	$26	; $1326 (D=$1300)
	beq	loc_009102
	stz	$26	; $1326 (D=$1300)
	jsl	f:sub_009172
	brl	loc_009102

sub_009155:
	rep	#$20
	stz	$10	; $1310 (D=$1300)
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	sta	$22	; $1322 (D=$1300)
	inx
	inx
	stx	$18	; $1318 (D=$1300)
loc_009165:
	jsl	f:sub_00949C
	jsl	f:sub_009172
	ldx	$10	; $1310 (D=$1300)
	bne	loc_009165
	rtl

sub_009172:
	php
	rep	#$20
	sep	#$10
	.i8
	ldx	#$80
	stx	a:VMAIN
	ldx	#$01
	stx	a:DMAP0
	lda	$22	; $1322 (D=$1300)
	sta	a:VMADDL
	lda	$0C	; $130C (D=$1300)
	sec
	sbc	$1A	; $131A (D=$1300)
	beq	loc_0091B6
	lsr	a
	clc
	adc	$22	; $1322 (D=$1300)
	sta	$22	; $1322 (D=$1300)
	ldx	#$18
	stx	a:BBAD0
loc_009198:
	lda	$03	; $1303 (D=$1300)
	clc
	adc	$1A	; $131A (D=$1300)
	sta	a:A1T0L
	ldx	$05	; $1305 (D=$1300)
	stx	a:A1B0
	lda	$0C	; $130C (D=$1300)
	sec
	sbc	$1A	; $131A (D=$1300)
	sta	a:DAS0L
	lda	$0C	; $130C (D=$1300)
	sta	$1A	; $131A (D=$1300)
	ldx	#$01
	stx	a:MDMAEN
loc_0091B6:
	plp
	.i16
	rtl
loc_0091B8:
	php
	phd
	rep	#$20
	rep	#$10
	ldy	#$1300
	lda	#$2400
	jsr	a:sub_009271
	sep	#$20
	.a8
	and	#$01
	bne	loc_0091E7
loc_0091CD:
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_0091E1
	brl	loc_0090F6
loc_0091E1:
	jsl	f:sub_009201
	bra	loc_0091CD
loc_0091E7:
	.a8
	rep	#$20
	.a16
	jsl	f:disable_display_and_nmi
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_0091FB
	; (not executed in the CDL traces)
	brl	loc_0090F6
loc_0091FB:
	jsl	f:sub_00921E
	bra	loc_0091CD

sub_009201:
	rep	#$20
	stz	$10	; $1310 (D=$1300)
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	sta	$22	; $1322 (D=$1300)
	inx
	inx
	stx	$18	; $1318 (D=$1300)
loc_009211:
	jsl	f:sub_00949C
	jsl	f:sub_009246
	ldx	$10	; $1310 (D=$1300)
	bne	loc_009211
	rtl

sub_00921E:
	rep	#$20
	stz	$10	; $1310 (D=$1300)
	ldx	$18	; $1318 (D=$1300)
	lda	f:$050000,x
	sta	$22	; $1322 (D=$1300)
	inx
	inx
	stx	$18	; $1318 (D=$1300)
loc_00922E:
	jsl	f:sub_00949C
	jsl	f:sub_00923B
	ldx	$10	; $1310 (D=$1300)
	bne	loc_00922E
	rtl

sub_00923B:
	php
	rep	#$20
	sep	#$10
	.i8
	ldy	#$18
	ldx	#$00
	bra	loc_00924F

sub_009246:
	.i16
	php
	rep	#$20
	sep	#$10
	.i8
	ldy	#$19
	ldx	#$80
loc_00924F:
	stx	a:VMAIN
	ldx	#$00
	stx	a:DMAP0
	lda	$22	; $1322 (D=$1300)
	sta	a:VMADDL
	lda	$0C	; $130C (D=$1300)
	sec
	sbc	$1A	; $131A (D=$1300)
	bne	loc_009266
	brl	loc_0091B6
loc_009266:
	clc
	adc	$22	; $1322 (D=$1300)
	sta	$22	; $1322 (D=$1300)
	sty	a:BBAD0
	jmp	a:loc_009198

sub_009271:
	.i16
	phy
	pld
	stz	$10	; $1310 (D=$1300) / $1350 (D=$1340) / $1F10 (D=$1F00)
	stz	$12	; $1312 (D=$1300) / $1352 (D=$1340) / $1F12 (D=$1F00)
	stz	$1C	; $131C (D=$1300) / $135C (D=$1340) / $1F1C (D=$1F00)
	sta	$03	; $1303 (D=$1300) / $1343 (D=$1340) / $1F03 (D=$1F00)
	sep	#$20
	.a8
	lda	#$7E
	sta	$05	; $1305 (D=$1300) / $1345 (D=$1340) / $1F05 (D=$1F00)
	lda	f:$050000,x
	sta	$16	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	inx
	stx	$18	; $1318 (D=$1300) / $1358 (D=$1340) / $1F18 (D=$1F00)
	lda	$16	; $1316 (D=$1300) / $1356 (D=$1340) / $1F16 (D=$1F00)
	rep	#$20
	.a16
	rts
loc_00928F:
	php
	phd
	ldy	#$1340
	lda	#$2800
	jsr	a:sub_009271
	sep	#$20
	.a8
	and	#$01
	bne	loc_0092B6
loc_0092A0:
	rep	#$20
	.a16
	ldx	$18	; $1358 (D=$1340)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_0092B0
	brl	loc_0090FA
loc_0092B0:
	jsl	f:sub_0092FA
	bra	loc_0092A0
loc_0092B6:
	.a8
	rep	#$20
	.a16
	inc	$12	; $1352 (D=$1340)
	bra	loc_0092C3
loc_0092BC:
	php
	phd
	ldy	#$1340
	phy
	pld
loc_0092C3:
	lda	$12	; $1352 (D=$1340)
	bne	loc_0092CA
	brl	loc_009102
loc_0092CA:
	lda	$10	; $1350 (D=$1340)
	bne	loc_0092EF
	ldx	$18	; $1358 (D=$1340)
	lda	f:$050000,x
	cmp	#$FFFF
	bne	loc_0092DC
	brl	loc_0090FA
loc_0092DC:
	sta	$20	; $1360 (D=$1340)
	inx
	inx
	sep	#$20
	.a8
	lda	f:$050000,x
	sta	$22	; $1362 (D=$1340)
	inx
	stx	$18	; $1358 (D=$1340)
	rep	#$20
	.a16
	stz	$1C	; $135C (D=$1340)
loc_0092EF:
	jsl	f:sub_0094A9
	jsl	f:sub_009324
	brl	loc_009102

sub_0092FA:
	rep	#$20
	stz	$10	; $1350 (D=$1340)
	stz	$1C	; $135C (D=$1340)
	ldx	$18	; $1358 (D=$1340)
	lda	f:$050000,x
	sta	$20	; $1360 (D=$1340)
	inx
	inx
	sep	#$20
	.a8
	lda	f:$050000,x
	sta	$22	; $1362 (D=$1340)
	inx
	stx	$18	; $1358 (D=$1340)
	rep	#$20
loc_009317:
	.a16
	jsl	f:sub_00949C
	jsl	f:sub_009324
	ldx	$10	; $1350 (D=$1340)
	bne	loc_009317
	rtl
