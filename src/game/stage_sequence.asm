; game/stage_sequence.asm -- Scripted stage sequence
; Bank $00, $00:EBC4-$00:F27B. Included by main.asm in segment BANK00.
;
; A scripted sequence run from the stage state machine (sub_00EBD7, state in
; $1C80, table tbl_00EBEF): colour-math fades, graphics loads, and state
; tables at $1C82; it clears both players' lives ($1F8A/$1FCA) at its start.

sub_00EBC4:
	lda	#$0005
	sta	a:wram_13BA
	lda	#$000C
	sta	a:wram_13FA
	lda	#$0001
	sta	a:cgadsub_shadow
	rtl

sub_00EBD7:
	jsl	f:sub_00EBDC
	rtl

sub_00EBDC:
	inc	a:wram_1C96
	lda	a:wram_1C80
	phx
	asl	a
	tax
	lda	f:tbl_00EBEF,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00EBEF:
	.addr	sub_00EBFB
	.addr	sub_00EC6A
	.addr	sub_00ECAD
	.addr	sub_00ECF6
	.addr	sub_00ED00
	.addr	sub_00ED30

sub_00EBFB:
	lda	#$0061
	jsl	f:queue_sound
	ldx	#.loword(data_05A84B)
	jsl	f:sub_0090A8
	ldy	#$A815
	jsl	f:sub_009982
	stz	a:wram_1C96
	lda	#$0020
	sta	a:CGWSEL
	sta	a:cgwsel_shadow
	lda	#$003F
	sta	a:CGADSUB
	sta	a:cgadsub_shadow
	lda	#$0023
	sta	a:W12SEL
	sta	a:w12sel_shadow
	lda	#$0200
	sta	a:TMW
	sta	a:tmw_shadow
	lda	#$00E0
	sta	a:COLDATA
	stz	a:coldata_shadow
	lda	#$00FF
	sta	a:wram_1EB0
	stz	a:wram_1EB2
	lda	#$0030
	sta	a:wobjsel_shadow
	lda	#$0013
	sta	a:tm_shadow
	stz	a:p1_lives
	stz	a:p2_lives
	stz	zp_B8
	stz	a:p1_view_x
	stz	a:p2_view_x
	stz	a:wram_1C84
	inc	a:wram_1C80
	rtl

sub_00EC6A:
	lda	#$0080
	sta	a:INIDISP
	sta	a:inidisp_shadow
	lda	#$0041
	sta	a:BG1SC
	sta	a:bg1sc_shadow
	lda	#$0049
	sta	a:BG2SC
	sta	a:bg2sc_shadow
	stz	a:wram_1C86
	inc	a:wram_1C80
	lda	a:wram_1C84
	cmp	#$0004
	beq	loc_00ECA0
	lda	#$0004
	sta	a:wram_13BA
	lda	#$0000
	sta	a:wram_13FA
	rtl
loc_00ECA0:
	lda	#$0005
	sta	a:wram_13BA
	lda	#$000C
	sta	a:wram_13FA
	rtl

sub_00ECAD:
	jsr	a:sub_00F174
	jsr	a:sub_00F1A9
	lda	a:wram_1C84
	cmp	#$0005
	beq	loc_00ECCE
	cmp	#$0004
	bne	loc_00ECDA
	rep	#$10
	ldy	#$0FFF
	ldx	#$4000
	jsl	f:sub_008E4B
	bra	loc_00ECE7
loc_00ECCE:
	rep	#$10
	ldy	#$03FF
	ldx	#$4400
	jsl	f:sub_008E4B
loc_00ECDA:
	lda	a:wram_1C84
	asl	a
	tay
	lda	a:ptrs_05A7AF,y
	tax
	jsl	f:sub_0090A8
loc_00ECE7:
	inc	a:wram_1C80
	lda	a:wram_1C84
	beq	loc_00ECF5
	lda	#$000F
	sta	a:inidisp_shadow
loc_00ECF5:
	rtl

sub_00ECF6:
	stz	a:wram_1C86
	stz	a:wram_1C82
	inc	a:wram_1C80
	rtl

sub_00ED00:
	jsr	a:sub_00ED34
	lda	a:wram_1C84
	asl	a
	tay
	inc	a:wram_1C86
	lda	a:wram_1C86
	cmp	a:data_05A7BD,y
	bcc	loc_00ED2F
	lda	a:wram_1C84
	inc	a
	bra	loc_00ED21

; (no caller found; decoded because it follows the end of a routine)
sub_00ED19:
	; (not executed in the CDL traces)
	cmp	#$0007
	bcc	loc_00ED21
	lda	#$0000
loc_00ED21:
	sta	a:wram_1C84
	asl	a
	tay
	lda	a:data_05A7CB,y
	sta	a:wram_1C80
	stz	a:wram_1C86
loc_00ED2F:
	rtl

sub_00ED30:
	inc	a:zp_36
	rtl

sub_00ED34:
	lda	a:wram_1C84
	phx
	asl	a
	tax
	lda	f:tbl_00ED44,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00ED44:
	.addr	sub_00ED52
	.addr	sub_00EDE2
	.addr	sub_00EE6D
	.addr	sub_00EF37
	.addr	sub_00F00B
	.addr	sub_00F03A
	.addr	sub_00F09F

sub_00ED52:
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00ED60
	and	#$000F
	sta	a:inidisp_shadow
loc_00ED60:
	cmp	#$000F
	bcs	loc_00ED68
	inc	a:inidisp_shadow
loc_00ED68:
	lda	a:wram_1C82
	phx
	asl	a
	tax
	lda	f:tbl_00ED78,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00ED78:
	.addr	sub_00ED7E
	.addr	sub_00EDCF
	.addr	sub_00EDDE

sub_00ED7E:
	ldx	#$0000
loc_00ED81:
	lda	f:data_05A85B,x
	sta	f:$7EA000,x
	inx
	cpx	#$0016
	bcc	loc_00ED81
	lda	#$000D
	sta	hdma_preset
	stz	a:wram_1384
	lda	#$0100
	sta	a:wram_1380
	stz	a:wram_13DC
	stz	a:wram_13D8
	jsr	a:sub_00F18D
	ldy	#$A830
	jsl	f:sub_009982
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	sta	$0E,x
	lda	#$3C00
	sta	$02,x
	lda	#$D12A
	sta	$00,x
	inc	a:wram_1C82
	jsr	a:sub_00F149
	rts

sub_00EDCF:
	jsr	a:sub_00F13C
	bcc	sub_00EDDE
	ldy	#$A836
	jsl	f:sub_009982
	inc	a:wram_1C82

sub_00EDDE:
	jsr	a:sub_00F149
	rts

sub_00EDE2:
	lda	a:wram_1C82
	phx
	asl	a
	tax
	lda	f:tbl_00EDF2,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00EDF2:
	.addr	sub_00EDFA
	.addr	sub_00EE01
	.addr	sub_00EE2C
	.addr	sub_00EE69

sub_00EDFA:
	jsr	a:sub_00F149
	inc	a:wram_1C82
	rts

sub_00EE01:
	lda	a:wram_13D8
	and	#$00FF
	cmp	#$00E0
	beq	loc_00EE1F
	lda	a:wram_13DC
	sec
	sbc	#$1000
	sta	a:wram_13DC
	bcs	loc_00EE1B
	dec	a:wram_13D8
loc_00EE1B:
	jsr	a:sub_00F149
	rts
loc_00EE1F:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:wram_1C82
	bra	loc_00EE1B

sub_00EE2C:
	jsr	a:sub_00F1A9
	ldy	#$0000
loc_00EE32:
	lda	a:data_05A9D9,y
	tax
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	a:data_05A871,y
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	lda	#$0000
	sta	$04,x
	lda	a:data_05A891,y
	sta	$20,x
	stz	$22,x
	iny
	iny
	cpy	#$0020
	bcc	loc_00EE32
	ldy	#$A845
	jsl	f:sub_009982
	inc	a:wram_1C82

sub_00EE69:
	jsr	a:sub_00F149
	rts

sub_00EE6D:
	lda	a:wram_1C82
	phx
	asl	a
	tax
	lda	f:tbl_00EE7D,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00EE7D:
	.addr	sub_00EE85
	.addr	sub_00EEB7
	.addr	sub_00EEC9
	.addr	sub_00EEFE

sub_00EE85:
	jsr	a:sub_00F174
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$0068
	sta	$0E,x
	lda	#$2000
	sta	$02,x
	lda	#$0000
	sta	$04,x
	lda	#$A95F
	sta	$20,x
	stz	$22,x
	inc	a:wram_1C82
	stz	a:wram_1C88
	jsr	a:sub_00F149
	rts

sub_00EEB7:
	inc	a:wram_1C88
	lda	a:wram_1C88
	cmp	#$0010
	bcc	loc_00EEC5
	inc	a:wram_1C82
loc_00EEC5:
	jsr	a:sub_00F149
	rts

sub_00EEC9:
	stz	a:title_menu_cursor
	stz	a:p1_view_x
	stz	a:wram_1C8A
	stz	a:wram_1C8C
	stz	a:wram_1C8E
	stz	a:wram_16AC
	lda	#$FFFF
	sta	a:wram_16AA
	lda	#$0080
	sta	a:wram_151E
	sta	a:wram_151C
	sta	a:wram_155E
	sta	a:wram_155C
	lda	#$005B
	jsl	f:queue_sound
	inc	a:wram_1C82
	jsr	a:sub_00F149
	rts

sub_00EEFE:
	lda	a:p1_view_x
	cmp	#$00FE
	bcs	loc_00EF33
	lda	a:wram_1C8C
	clc
	adc	#$8000
	sta	a:wram_1C8C
	bcc	loc_00EF15
	inc	a:wram_1C8E
loc_00EF15:
	lda	a:wram_1C8A
	clc
	adc	a:wram_1C8C
	sta	a:wram_1C8A
	lda	a:p1_view_x
	adc	a:wram_1C8E
	cmp	#$00FE
	bcc	loc_00EF2D
	lda	#$00FE
loc_00EF2D:
	sta	a:p1_view_x
	sta	a:p2_view_x
loc_00EF33:
	jsr	a:sub_00F149
	rts

sub_00EF37:
	jsr	a:sub_00F25A
	lda	a:wram_1C82
	phx
	asl	a
	tax
	lda	f:tbl_00EF4A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00EF4A:
	.addr	sub_00EF56
	.addr	sub_00EF7E
	.addr	sub_00EF90
	.addr	sub_00EFB6
	.addr	sub_00EFF0
	.addr	sub_00F00A

sub_00EF56:
	lda	#$0000
	sta	a:wram_1380
	lda	#$0040
	sta	a:BG1SC
	sta	a:bg1sc_shadow
	lda	#$000E
	sta	hdma_preset
	jsr	a:sub_00F214
	lda	#$0000
	sta	f:wram_7E2250
	jsr	a:sub_00F174
	stz	a:wram_1C88
	inc	a:wram_1C82
	rts

sub_00EF7E:
	inc	a:wram_1C88
	lda	a:wram_1C88
	cmp	#$001E
	bcc	loc_00EF8F
	stz	a:wram_1C88
	inc	a:wram_1C82
loc_00EF8F:
	rts

sub_00EF90:
	lda	a:wram_1C88
	cmp	#$003F
	bcs	loc_00EFAF
	inc	a:wram_1C88
	lda	a:wram_1C88
	lsr	a
	tay
	lda	a:data_05A8B1,y
	and	#$00FF
	sta	a:p1_view_x
	sta	a:p2_view_x
	beq	loc_00EFAF
	rts
loc_00EFAF:
	stz	a:wram_1C88
	inc	a:wram_1C82
	rts

sub_00EFB6:
	inc	a:wram_1C88
	lda	a:wram_1C88
	cmp	#$0050
	bcc	loc_00EFEF
	jsr	a:sub_00F18D
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$0054
	sta	$0E,x
	lda	#$3800
	sta	$02,x
	lda	#$CEC8
	sta	$00,x
	ldy	#$A82A
	jsl	f:sub_009982
	stz	a:wram_1C88
	inc	a:wram_1C82
loc_00EFEF:
	rts

sub_00EFF0:
	inc	a:wram_1C88
	lda	a:wram_1C88
	cmp	#$003C
	bcc	loc_00F009
	ldx	#$0300
	lda	#$CFF9
	sta	$00,x
	stz	a:wram_1C88
	inc	a:wram_1C82
loc_00F009:
	rts

sub_00F00A:
	rts

sub_00F00B:
	lda	a:wram_1C82
	beq	loc_00F015
	dec	a
	beq	loc_00F026
	; (not executed in the CDL traces)
	bne	loc_00F039
loc_00F015:
	lda	#$0000
	sta	hdma_preset
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:wram_1C82
	rts
loc_00F026:
	lda	a:wram_1380
	clc
	adc	#$0004
	sta	a:wram_1380
	cmp	#$0900
	bcc	loc_00F038
	; (not executed in the CDL traces)
	inc	a:wram_1C82
loc_00F038:
	rts
loc_00F039:
	; (not executed in the CDL traces)
	rts

sub_00F03A:
	lda	a:wram_1C82
	bne	loc_00F04E
	stz	a:wram_13D8
	stz	a:wram_1380
	stz	a:wram_1C90
	stz	a:wram_1C92
	inc	a:wram_1C82
loc_00F04E:
	sep	#$20
	.a8
	ldy	a:wram_1C90
	inc	a:wram_1C92
	lda	a:wram_1C92
	cmp	a:data_05A8D1,y
	bcc	loc_00F09C
	lda	a:data_05A8DB,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:sub_00F120
	inc	a:wram_1C90
	lda	a:wram_1C90
	cmp	#$0001
	bne	loc_00F099
	ldy	#$A83C
	jsl	f:sub_009982
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$00C8
	sta	$0E,x
	lda	#$3A00
	sta	$02,x
	lda	#$D16F
	sta	$00,x
loc_00F099:
	stz	a:wram_1C92
loc_00F09C:
	rep	#$20
	rts

sub_00F09F:
	lda	a:wram_1C82
	beq	loc_00F0A9
	dec	a
	beq	loc_00F0B5
	bne	loc_00F0CE
loc_00F0A9:
	ldx	#$0300
	lda	#$0000
	sta	$00,x
	inc	a:wram_1C82
	rts
loc_00F0B5:
	lda	a:wram_1380
	clc
	adc	#$0004
	sta	a:wram_1380
	cmp	#$0080
	bcc	loc_00F0CD
	stz	a:wram_1C90
	stz	a:wram_1C92
	inc	a:wram_1C82
loc_00F0CD:
	rts
loc_00F0CE:
	sep	#$20
	.a8
	ldy	a:wram_1C90
	inc	a:wram_1C92
	lda	a:wram_1C92
	cmp	a:data_05A8E5,y
	bcc	loc_00F115
	lda	a:data_05A8F3,y
	rep	#$20
	.a16
	and	#$00FF
	jsr	a:sub_00F120
	inc	a:wram_1C90
	lda	a:wram_1C90
	cmp	#$0001
	bne	loc_00F099
	ldx	#$0300
	lda	#$0053
	sta	$10,x
	stz	$16,x
	lda	#$0080
	sta	$0A,x
	lda	#$00C0
	sta	$0E,x
	lda	#$3C00
	sta	$02,x
	lda	#$D190
	sta	$00,x
	stz	a:wram_1C92
loc_00F115:
	rep	#$20
	jsr	a:sub_00F13C
	bcc	loc_00F11F
	jsr	a:sub_00F174
loc_00F11F:
	rts

sub_00F120:
	asl	a
	tay
	lda	a:data_05A901,y
	sta	zp_02
	lda	a:data_05A909,y
	sta	zp_08
	lda	a:data_05A911,y
	pha
	lda	a:data_05A919,y
	tay
	pla
	phx
	jsl	f:sub_00FEA3
	plx
	rts

sub_00F13C:
	lda	a:wram_1C84
	asl	a
	tay
	lda	a:wram_1C86
	inc	a
	cmp	a:data_05A7BD,y
	rts

sub_00F149:
	lda	a:wram_1380
	sta	f:wram_7EA013
	lda	a:wram_1C96
	lsr	a
	lsr	a
	eor	#$FFFF
	sta	f:wram_7EA004
	lda	a:wram_1C96
	lsr	a
	sta	f:wram_7EA007
	lsr	a
	sta	f:wram_7EA00A
	lsr	a
	sta	f:wram_7EA00D
	lsr	a
	sta	f:wram_7EA010
	rts

sub_00F174:
	ldy	#$0000
loc_00F177:
	lda	a:data_05A9D9,y
	tax
	stz	$10,x
	stz	$00,x
	stz	$16,x
	stz	$20,x
	stz	$22,x
	iny
	iny
	cpy	#$0020
	bcc	loc_00F177
	rts

sub_00F18D:
	lda	#$0003
	sta	a:tm_shadow
	sta	a:TM
	lda	#$0010
	sta	a:ts_shadow
	sta	a:TS
	lda	#$0002
	sta	a:cgwsel_shadow
	sta	a:CGWSEL
	rts

sub_00F1A9:
	lda	#$0013
	sta	a:tm_shadow
	sta	a:TM
	lda	#$0002
	sta	a:ts_shadow
	sta	a:TS
	lda	#$0020
	sta	a:cgwsel_shadow
	sta	a:CGWSEL
	rts

sub_00F1C5:
	lda	a:$0000,y
	sta	zp_00
	lda	a:$0002,y
	asl	a
	sta	zp_02
	lda	a:$0004,y
	clc
	adc	#$0040
	asl	a
	sta	zp_04
	lda	a:$0006,y
	sta	zp_08
	lda	a:$0008,y
	sta	zp_0A
	phx
	ldy	zp_02
loc_00F1E7:
	tya
	and	#$003F
	asl	a
	asl	a
	asl	a
	tax
	lda	f:data_058010,x
	rol	a
	rol	a
	and	#$0001
	pha
	tya
	bit	#$0040
	beq	loc_00F206
	pla
	eor	#$FFFF
	inc	a
	bra	loc_00F207
loc_00F206:
	pla
loc_00F207:
	clc
	adc	(zp_00)
	sta	[zp_08],y
	iny
	iny
	cpy	zp_04
	bcc	loc_00F1E7
	plx
	rtl

sub_00F214:
	ldy	#$0000
	ldx	#$0000
loc_00F21A:
	lda	a:data_05A9F9,y
	sta	f:$7EA000,x
	inx
	iny
	cpy	#$0009
	bcc	loc_00F21A
	ldy	#$0000
	ldx	#$0000
loc_00F22E:
	lda	a:data_05AA03,y
	sta	f:$7EA400,x
	inx
	iny
	cpy	#$0009
	bcc	loc_00F22E
	lda	a:wram_1380
	sta	f:wram_7EA010
	lda	a:wram_1398
	inc	a
	sta	f:wram_7EA410
	ldy	#$AA0D
	jsl	f:sub_00F1C5
	ldy	#$AA16
	jsl	f:sub_00F1C5
	rts

sub_00F25A:
	lda	a:wram_1C96
	and	#$007E
	clc
	adc	#$A020
	sta	f:wram_7EA004
	lda	a:wram_1C96
	clc
	adc	#$0010
	and	#$003F
	asl	a
	clc
	adc	#$A420
	sta	f:wram_7EA404
	rts
