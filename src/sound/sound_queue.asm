; sound/sound_queue.asm -- Sound command queue
; Bank $00, $00:85F3-$00:86AB. Included by main.asm in segment BANK00.
;
; Commands for the sound CPU are queued in a ring at $0100 (sub_00868F queues
; the command in A, skipping repeats; $56 write index, $54 read index) and
; sent one per frame to APUIO0 by sub_0085F3. sub_00865C resets the queue with
; command $84.

sub_0085F3:
	.a16
	sep	#$30
	.a8
	.i8
	lda	$52
	beq	loc_008604
	cmp	#$FF
	beq	loc_00861D
	cmp	a:APUIO0
	bne	loc_00861D
	stz	$52
loc_008604:
	lda	$6A
	beq	loc_00860C
	; (not executed in the CDL traces)
	stz	$6A
	bra	loc_008618
loc_00860C:
	ldx	$54
	cpx	$56
	beq	loc_00861D
	lda	a:$0100,x
	inx
	stx	$54
loc_008618:
	sta	$52
	sta	a:APUIO0
loc_00861D:
	rep	#$30
	.a16
	.i16
	lda	$5A
	bne	loc_008675
	rtl

sub_008624:
	php
	sep	#$20
	.a8
	stz	$52
	sta	a:APUIO0
loc_00862C:
	cmp	a:APUIO0
	bne	loc_00862C
	stz	$54
	stz	$56
	stz	$5A
	stz	$6A
	rep	#$20
	.a16
	plp
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00863D:
	; (not executed in the CDL traces)
	php
	rep	#$20
	pha
	sep	#$20
	.a8
	lda	#$84
	stz	$52
	sta	a:APUIO0
loc_00864A:
	cmp	a:APUIO0
	bne	loc_00864A
	stz	$54
	stz	$56
	stz	$5A
	stz	$6A
	rep	#$20
	.a16
	pla
	plp
	rtl

sub_00865C:
	sep	#$20
	.a8
	lda	#$84
	sta	a:$0100
	stz	$54
	lda	#$01
	sta	$56
	stz	$5A
	stz	$6A
	rep	#$20
	.a16
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_008670:
	; (not executed in the CDL traces)
	lda	#$0001
	sta	$5A
loc_008675:
	ldy	$5A
	lda	a:$1F2D,y
	bit	#$8000
	beq	loc_008687
	bit	#$4000
	bne	loc_008686
	stz	$5A
loc_008686:
	rtl
loc_008687:
	and	#$00FF
	sta	$6A
	stz	$5A
	rtl

sub_00868F:
	phx
	phy
	php
	sep	#$30
	.a8
	.i8
	cmp	$5C
	beq	loc_0086A8
	ldx	$56
	sta	$5C
	sta	a:$0100,x
	inx
	stx	$56
	cpx	$54
	bne	loc_0086A8
	; (not executed in the CDL traces)
	inc	$54
loc_0086A8:
	plp
	.a16
	.i16
	ply
	plx
	rtl
