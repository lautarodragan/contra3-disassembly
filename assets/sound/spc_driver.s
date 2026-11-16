; The sound driver (SPC700), uploaded to ARAM $0200 at boot (spc_driver).
; Assembled by tools/spcasm.py; book: Sound driver. The sequences of the sound
; effects are text in spc_sfx.seq (included below). Code and tables stay at
; their addresses (the .org lines check it): the code reads the tables at
; fixed addresses. The sound effects may change size up to $3000.

	.org $0200
	jmp driver_start

	.org $0203
; $0203-$03E5: the driver's variables (cleared by driver_start)
	.zero $1E3

	.org $03E6, "the code reads sound_table at $03E6"
sound_table:	; $03E6: sounds $01-$73, 5 bytes each: channel mask, priority, channels, the address of the sound's header (one sequence address per channel); read from $03E6 + 5 x (n - 1) (L197A)
	.byte $40, $01, $01	; $01
	.word sound_01
	.byte $40, $01, $01	; $02
	.word sound_02
	.byte $40, $01, $01	; $03
	.word sound_03
	.byte $40, $02, $01	; $04: the default gun's shot (spawn_shot_default)
	.word sound_04
	.byte $40, $05, $01	; $05: the laser (spawn_shot_laser_in_slots)
	.word sound_05
	.byte $40, $05, $01	; $06
	.word sound_06
	.byte $40, $06, $01	; $07: the crush gun (spawn_shot_crush_in_slot)
	.word sound_07
	.byte $40, $07, $01	; $08: the homing gun (spawn_shot_homing_in_slot)
	.word sound_08
	.byte $40, $08, $01	; $09: the spread gun (spawn_shots_spread_in_slots)
	.word sound_09
	.byte $40, $09, $01	; $0A: the flame thrower (spawn_shots_flame)
	.word sound_0A
	.byte $40, $10, $01	; $0B
	.word sound_0B
	.byte $40, $10, $01	; $0C
	.word sound_0C
	.byte $40, $12, $01	; $0D
	.word sound_0D
	.byte $40, $12, $01	; $0E
	.word sound_0E
	.byte $40, $14, $01	; $0F
	.word sound_0F
	.byte $40, $17, $01	; $10
	.word sound_10
	.byte $40, $18, $01	; $11
	.word sound_11
	.byte $40, $19, $01	; $12
	.word sound_12
	.byte $40, $20, $01	; $13
	.word sound_13
	.byte $40, $20, $01	; $14
	.word sound_14
	.byte $40, $20, $01	; $15
	.word sound_15
	.byte $40, $20, $01	; $16
	.word sound_16
	.byte $40, $20, $01	; $17
	.word sound_17
	.byte $40, $20, $01	; $18
	.word sound_18
	.byte $40, $20, $01	; $19
	.word sound_19
	.byte $40, $20, $01	; $1A
	.word sound_1A
	.byte $40, $25, $01	; $1B
	.word sound_1B
	.byte $40, $28, $01	; $1C
	.word sound_1C
	.byte $40, $28, $01	; $1D
	.word sound_1D
	.byte $40, $30, $01	; $1E
	.word sound_1E
	.byte $40, $30, $01	; $1F
	.word sound_1F
	.byte $40, $35, $01	; $20
	.word sound_20
	.byte $40, $37, $01	; $21
	.word sound_21
	.byte $40, $37, $01	; $22
	.word sound_22
	.byte $40, $37, $01	; $23
	.word sound_23
	.byte $40, $37, $01	; $24
	.word sound_24
	.byte $40, $39, $01	; $25
	.word sound_25
	.byte $40, $40, $01	; $26
	.word sound_26
	.byte $40, $40, $01	; $27
	.word sound_27
	.byte $40, $40, $01	; $28
	.word sound_28
	.byte $40, $40, $01	; $29
	.word sound_29
	.byte $40, $40, $01	; $2A
	.word sound_2A
	.byte $40, $40, $01	; $2B
	.word sound_2B
	.byte $40, $40, $01	; $2C
	.word sound_2C
	.byte $40, $40, $01	; $2D
	.word sound_2D
	.byte $40, $41, $01	; $2E
	.word sound_2E
	.byte $40, $41, $01	; $2F
	.word sound_2F
	.byte $40, $44, $01	; $30
	.word sound_30
	.byte $40, $45, $01	; $31
	.word sound_31
	.byte $40, $45, $01	; $32
	.word sound_32
	.byte $40, $45, $01	; $33
	.word sound_33
	.byte $40, $45, $01	; $34
	.word sound_34
	.byte $40, $45, $01	; $35
	.word sound_35
	.byte $40, $45, $01	; $36
	.word sound_36
	.byte $40, $45, $01	; $37
	.word sound_37
	.byte $40, $45, $01	; $38
	.word sound_38
	.byte $40, $45, $01	; $39
	.word sound_39
	.byte $40, $45, $01	; $3A
	.word sound_3A
	.byte $40, $45, $01	; $3B
	.word sound_3B
	.byte $40, $45, $01	; $3C
	.word sound_3C
	.byte $40, $45, $01	; $3D
	.word sound_3D
	.byte $40, $46, $01	; $3E: an extra life (add_score)
	.word sound_3E
	.byte $40, $60, $01	; $3F
	.word sound_3F
	.byte $00, $00, $00	; $40: empty
	.word $0000
	.byte $C0, $A0, $02	; $41
	.word sound_41
	.byte $C0, $A0, $02	; $42
	.word sound_42
	.byte $C0, $A0, $02	; $43
	.word sound_43
	.byte $C0, $A0, $02	; $44
	.word sound_44
	.byte $C0, $A0, $02	; $45
	.word sound_45
	.byte $C0, $A0, $02	; $46
	.word sound_46
	.byte $C0, $A0, $02	; $47
	.word sound_47
	.byte $C0, $A0, $02	; $48
	.word sound_48
	.byte $C0, $A0, $02	; $49
	.word sound_49
	.byte $C0, $A0, $02	; $4A
	.word sound_4A
	.byte $C0, $A0, $02	; $4B
	.word sound_4B
	.byte $C0, $A0, $02	; $4C
	.word sound_4C
	.byte $C0, $A0, $02	; $4D
	.word sound_4D
	.byte $C0, $A0, $02	; $4E
	.word sound_4E
	.byte $C0, $A0, $02	; $4F
	.word sound_4F
	.byte $C0, $A0, $02	; $50
	.word sound_50
	.byte $C0, $B0, $02	; $51
	.word sound_51
	.byte $C0, $B0, $02	; $52
	.word sound_52
	.byte $C0, $B0, $02	; $53
	.word sound_53
	.byte $C0, $B0, $02	; $54
	.word sound_54
	.byte $C0, $B0, $02	; $55
	.word sound_55
	.byte $C0, $B0, $02	; $56
	.word sound_56
	.byte $C0, $B0, $02	; $57
	.word sound_57
	.byte $C0, $B5, $02	; $58
	.word sound_58
	.byte $C0, $B5, $02	; $59
	.word sound_59
	.byte $C0, $D0, $02	; $5A
	.word sound_5A
	.byte $C0, $D0, $02	; $5B
	.word sound_5B
	.byte $03, $D8, $02	; $5C
	.word sound_5C
	.byte $03, $D8, $02	; $5D
	.word sound_5D
	.byte $0C, $D8, $02	; $5E
	.word sound_5E
	.byte $10, $D8, $01	; $5F
	.word sound_31
	.byte $00, $00, $00	; $60: empty
	.word $0000
	.byte $3F, $E0, $06	; $61: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $62: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $63: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $64: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $65: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $66: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $67: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $68: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $69: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $6A: the song at $3000
	.word $3000
	.byte $3F, $E0, $06	; $6B: the song at $3000
	.word $3000
	.byte $00, $00, $00	; $6C: empty
	.word $0000
	.byte $3F, $E0, $06	; $6D
	.word sound_6D
	.byte $3F, $E0, $06	; $6E
	.word sound_6E
	.byte $3F, $E0, $06	; $6F: the song at $4B00
	.word $4B00
	.byte $00, $00, $00	; $70: empty
	.word $0000
	.byte $FF, $E0, $08	; $71: the song at $3000
	.word $3000
	.byte $FF, $E0, $08	; $72: the song at $3000
	.word $3000
	.byte $00, $00, $00	; $73: empty
	.word $0000

	.org $0625, "the code reads fade_speeds at $0625"
fade_speeds:	; $0625: ticks per step of the fade-out of commands $80, $81 (cmd_fade_out reads $0625 + n - $80)
	.byte $02, $04

	.org $0627
; not read by the code the trace reaches
	.byte $0A

	.org $0628, "the code reads instrument_sets at $0628"
instrument_sets:	; $0628: the instruments $14-$18 of each set chosen by commands $74-$7A ($0205 = n - $74)
	.word instrument_set_0
	.word instrument_set_1
	.word instrument_set_2
	.word instrument_set_3
	.word instrument_set_4
	.word instrument_set_5
	.word instrument_set_6

	.org $0636, "the code reads instruments at $0636"
instruments:	; $0636: instruments $00-$13, 8 bytes each: source (SRCN), tuning (semitones, 256ths), ADSR1, ADSR2, GAIN, pan (0-20), attenuation
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $00
	.byte $01, $16, $A9, $FF, $EB, $B8, $0A, $00	; $01
	.byte $02, $0C, $FC, $FF, $E0, $B8, $0A, $00	; $02
	.byte $03, $0C, $FC, $FF, $E0, $B8, $0A, $00	; $03
	.byte $04, $0C, $FC, $FF, $E0, $B8, $0A, $00	; $04
	.byte $05, $10, $D8, $FF, $E0, $B8, $0A, $00	; $05
	.byte $06, $F4, $00, $FF, $E0, $B8, $0A, $00	; $06
	.byte $07, $07, $00, $FF, $E0, $B8, $0A, $00	; $07
	.byte $08, $07, $00, $FF, $E0, $B8, $0A, $00	; $08
	.byte $09, $05, $48, $FF, $E0, $B8, $0A, $00	; $09
	.byte $0A, $07, $00, $FF, $E0, $B8, $0A, $00	; $0A
	.byte $0B, $00, $00, $FF, $E0, $B8, $0A, $00	; $0B
	.byte $0C, $00, $00, $FF, $E0, $B8, $0A, $00	; $0C
	.byte $0D, $01, $FC, $FF, $E0, $B8, $0A, $02	; $0D
	.byte $0E, $01, $00, $FF, $E0, $B8, $0A, $00	; $0E
	.byte $0F, $00, $00, $FF, $E0, $B8, $0A, $00	; $0F
	.byte $10, $00, $F9, $FF, $E0, $B8, $0A, $00	; $10
	.byte $11, $00, $00, $FF, $F3, $B8, $0A, $00	; $11
	.byte $12, $04, $D9, $FF, $E0, $B8, $0A, $00	; $12
	.byte $13, $1A, $04, $FF, $E0, $B8, $0A, $00	; $13

	.org $06D6
instrument_set_0:	; $06D6: instruments $14-$18 of set 0 (stage 3)
	.byte $14, $00, $00, $FF, $EE, $B8, $0A, $00	; $14
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $15
	.byte $16, $FE, $A9, $FF, $EE, $B8, $0A, $00	; $16
	.byte $17, $00, $00, $FF, $E0, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $06FE, "the code reads drum_instruments at $06FE"
drum_instruments:	; $06FE: the drums: note n of a channel in drums_on mode plays instrument n of this table
	.byte $0E, $0E, $00, $FF, $E0, $B8, $0A, $00	; $00
	.byte $0F, $0F, $00, $FF, $E0, $B8, $0A, $00	; $01
	.byte $11, $FF, $00, $FF, $F3, $B8, $0C, $00	; $02
	.byte $14, $04, $40, $FF, $E0, $B8, $08, $32	; $03
	.byte $15, $00, $00, $FF, $EF, $B8, $0A, $00	; $04
	.byte $0B, $0E, $00, $FC, $1F, $B8, $09, $05	; $05
	.byte $17, $FD, $00, $FF, $F2, $B8, $05, $00	; $06
	.byte $17, $FF, $00, $FF, $F2, $B8, $08, $00	; $07
	.byte $17, $00, $00, $8F, $F4, $B8, $0C, $00	; $08
	.byte $17, $09, $00, $8F, $F4, $B8, $0F, $00	; $09
	.byte $0F, $02, $00, $FF, $D2, $B8, $0A, $00	; $0A
	.byte $15, $FB, $00, $FF, $D4, $B8, $0A, $00	; $0B
	.byte $15, $00, $00, $FF, $D4, $B8, $0D, $00	; $0C
	.byte $15, $05, $00, $FF, $D4, $B8, $07, $00	; $0D
	.byte $14, $0C, $00, $FF, $E0, $B8, $05, $05	; $0E
	.byte $14, $07, $00, $FF, $E0, $B8, $08, $05	; $0F
	.byte $14, $03, $00, $FF, $EF, $B8, $0C, $05	; $10
	.byte $14, $FF, $00, $FF, $EF, $B8, $0F, $05	; $11
	.byte $0B, $1D, $00, $FF, $B1, $B8, $09, $00	; $12
	.byte $0B, $16, $00, $FF, $9D, $B8, $0C, $00	; $13
	.byte $14, $FB, $00, $FF, $F2, $B8, $12, $05	; $14

	.org $07A6
instrument_set_1:	; $07A6: set 1 (stage 2)
	.byte $14, $00, $00, $FF, $EE, $B8, $0A, $00	; $14
	.byte $15, $0E, $04, $FF, $E0, $B8, $0A, $00	; $15
	.byte $16, $FE, $A9, $FF, $EE, $B8, $0A, $00	; $16
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $07CE
instrument_set_2:	; $07CE: set 2 (stage 1)
	.byte $14, $03, $00, $FF, $E0, $B8, $0A, $00	; $14
	.byte $15, $00, $00, $FF, $EE, $B8, $0A, $00	; $15
	.byte $16, $05, $4C, $FF, $E0, $B8, $0A, $00	; $16
	.byte $17, $0A, $A5, $FF, $E0, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $07F6
instrument_set_3:	; $07F6: set 3 (stage 4)
	.byte $14, $00, $00, $FF, $EE, $B8, $0A, $00	; $14
	.byte $15, $0E, $04, $FF, $E0, $B8, $0A, $00	; $15
	.byte $16, $07, $FE, $FF, $E0, $B8, $0A, $00	; $16
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $081E
instrument_set_4:	; $081E: set 4 (stage 5)
	.byte $14, $00, $00, $FF, $EE, $B8, $0A, $00	; $14
	.byte $16, $00, $00, $FF, $EE, $B8, $0A, $00	; $15
	.byte $15, $00, $00, $FF, $E0, $B8, $0A, $00	; $16
	.byte $17, $00, $00, $FF, $E0, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $0846
instrument_set_5:	; $0846: set 5 (stage 6)
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $14
	.byte $15, $00, $00, $FF, $E0, $B8, $0A, $00	; $15
	.byte $16, $05, $4C, $FF, $E0, $B8, $0A, $00	; $16
	.byte $17, $0A, $A5, $FF, $E0, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $086E
instrument_set_6:	; $086E: set 6 (the opening)
	.byte $14, $00, $00, $FF, $E0, $B8, $0A, $00	; $14
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $15
	.byte $16, $05, $4C, $FF, $E0, $B8, $0A, $00	; $16
	.byte $17, $00, $00, $FF, $E0, $B8, $0A, $00	; $17
	.byte $00, $0A, $B1, $FF, $EA, $B8, $0A, $00	; $18

	.org $0896
driver_start:
	clrp
	mov x, #$CF
	mov sp, x
	mov a, #$30
	mov !$00F1, a
	mov a, #$00
	mov x, #$00
L08A3:
	mov (x)+, a
	cmp x, #$F0
	bne L08A3
	mov y, #$00
	mov $04, #$00
	mov $05, #$01
L08B0:
	mov [$04]+y, a
	cmp y, #$8F
	bne L08BB
	cmp $05, #$01
	beq L08C2
L08BB:
	inc y
	bne L08B0
	inc $05
	bra L08B0
L08C2:
	mov y, #$03
	mov $04, #$00
	mov $05, #$02
L08CA:
	mov [$04]+y, a
	cmp y, #$E5
	bne L08D5
	cmp $05, #$03
	beq L08DC
L08D5:
	inc y
	bne L08CA
	inc $05
	bra L08CA
L08DC:
	mov a, #$00
	call L11A1
	set1 $18.5
	mov y, #$71
L08E5:
	mov a, #$00
	mov !$00F2, y
	mov !$00F3, a
	dec y
	mov !$00F2, y
	mov !$00F3, a
	mov a, y
	setc
	sbc a, #$0F
	mov y, a
	bpl L08E5
	mov a, #$FF
	mov $17, a
	mov y, #$5C
	mov !$00F2, y
	mov !$00F3, a
	mov a, #$7F
	mov y, #$0C
	mov !$00F2, y
	mov !$00F3, a
	mov y, #$1C
	mov !$00F2, y
	mov !$00F3, a
	mov a, #$50
	mov y, #$5D
	mov !$00F2, y
	mov !$00F3, a
	mov $10, #$00
	mov a, #$20
	mov !$00FA, a
	mov a, #$01
	mov !$00F1, a
L0930:
	mov y, #$0A
L0932:
	cmp y, #$05
	beq L093D
	bcs L0940
	cmp $1D, $1E
	bne L094E
L093D:
	bbs $1D.7, L094E
L0940:
	mov a, !$15A7+y
	mov !$00F2, a
	mov a, !$15B1+y
	mov x, a
	mov a, (x)
	mov !$00F3, a
L094E:
	dbnz y, L0932
	mov $16, y
	mov $17, y
	mov $22, y
L0956:
	mov y, !$00FD
	beq L0956
	mov $21, y
	mov !$00F5, y
	mov a, $28
	clrc
	adc a, #$40
	mov $28, a
	bcc L0970
	cmp $1D, $1E
	beq L0970
	inc $1D
L0970:
	call L18BC
	beq L097E
	tset1 !$0017
	tclr1 !$001F
	tset1 !$0022
L097E:
	bbs $25.1, L099F
	mov a, $23
	beq L099F
	mov x, #$3F
	inc $24
	mov a, !$0204
	cbne $24, L099F
	mov $24, #$00
	dec $23
	bne L099F
	call cmd_stop_music
	tset1 !$0017
	tclr1 !$001F
L099F:
	mov $20, #$01
	mov x, #$00
L09A4:
	mov a, $CE+x
	beq L0A04
	mov a, $20
	and a, $22
	bne L0A04
	mov $27, x
	mov a, !$156E+x
	mov $29, a
	mov a, !$02C6+x
	mov $26, a
	mov a, !$02D6+x
	mov $2B, a
	mov a, !$02D7+x
	mov $2C, a
	mov y, $21
	mov a, $BD+x
	mov $04, a
	mov $05, #$00
	mov a, !$0206+x
	mul ya
	addw ya, $04
	mov $BD+x, a
	cmp y, #$00
	beq L09F2
	dec y
	beq L09EA
	cmp x, #$0C
	bcs L09EA
	mov a, $CE+x
	cmp a, #$1A
	bcc L09EA
L09E6:
	decw $2B
	dbnz y, L09E6
L09EA:
	call L0AAE
	call L0BC0
	bra L09F5
L09F2:
	call L0A14
L09F5:
	mov a, $26
	mov !$02C6+x, a
	mov a, $2B
	mov !$02D6+x, a
	mov a, $2C
	mov !$02D7+x, a
L0A04:
	bbc $25.1, L0A0B
	cmp x, #$0A
	bcs L0A11
L0A0B:
	inc x
	inc x
	asl $20
	bne L09A4
L0A11:
	jmp L0930
L0A14:
	clr1 $25.2
	mov a, !$0347+x
	mov $0B, a
	mov a, !$0346+x
	mov $0A, a
	mov a, $7D+x
	beq L0A6F
	mov a, $7E+x
	bne L0A6F
	set1 $25.2
	mov a, !$0356+x
	mov $04, a
	mov a, !$0357+x
	mov $05, a
	bmi L0A4E
	mov a, $BD+x
	mov y, $04
	mul ya
	mov $06, y
	mov $07, #$00
	mov a, $BD+x
	mov y, $05
	mul ya
	clrc
	addw ya, $06
	addw ya, $0A
	movw $0A, ya
	bra L0A6F
L0A4E:
	eor $04, #$FF
	eor $05, #$FF
	incw $04
	mov a, $BD+x
	mov y, $04
	mul ya
	mov $06, y
	mov $07, #$00
	mov a, $BD+x
	mov y, $05
	mul ya
	addw ya, $06
	movw $04, ya
	movw ya, $0A
	subw ya, $04
	movw $0A, ya
L0A6F:
	mov a, !$0377+x
	or a, !$0376+x
	beq L0A95
	mov a, !$0246+x
	cbne $9D+x, L0A95
	mov a, !$0237+x
	clrc
	adc a, !$0236+x
	mov !$0237+x, a
	clrc
	adc a, $9E+x
	call L13C5
	movw ya, $08
	addw ya, $0A
	movw $0A, ya
	set1 $25.2
L0A95:
	mov a, !$0277+x
	beq L0AA5
	call L13F5
	movw ya, $0A
	addw ya, $04
	movw $0A, ya
	set1 $25.2
L0AA5:
	bbc $25.2, L0AAD
	movw ya, $0A
	jmp L1440
L0AAD:
	ret
L0AAE:
	decw $2B
	bmi L0AB4
	bne L0AB7
L0AB4:
	jmp L0C8C
L0AB7:
	mov a, $4E+x
	beq L0AC7
	dec $4E+x
	bne L0AFE
	mov a, !$03C6+x
	or a, !$03C7+x
	beq L0AFB
L0AC7:
	mov a, !$03D7+x
	cmp a, !$0217+x
	bcs L0AFB
	mov a, !$03C6+x
	or a, !$03C7+x
	beq L0AFE
	mov a, !$0267+x
	cmp a, #$64
	bcs L0AE6
	mov y, #$00
	mov a, #$01
	cmpw ya, $2B
	beq L0AFB
L0AE6:
	mov a, !$03D6+x
	clrc
	adc a, !$03C6+x
	mov !$03D6+x, a
	mov a, !$03D7+x
	adc a, !$03C7+x
	mov !$03D7+x, a
	bra L0AFE
L0AFB:
	or $17, $20
L0AFE:
	clr1 $25.2
	mov a, #$00
	mov y, a
	movw $08, ya
	mov a, $7D+x
	beq L0B38
	mov a, $7E+x
	beq L0B11
	dec $7E+x
	bra L0B38
L0B11:
	dec $7D+x
	bne L0B23
	mov a, !$0367+x
	mov !$0347+x, a
	mov a, !$0366+x
	mov !$0346+x, a
	bra L0B36
L0B23:
	mov a, !$0346+x
	clrc
	adc a, !$0356+x
	mov !$0346+x, a
	mov a, !$0347+x
	adc a, !$0357+x
	mov !$0347+x, a
L0B36:
	set1 $25.2
L0B38:
	mov a, !$0256+x
	beq L0B95
	mov a, $9D+x
	cmp a, !$0246+x
	beq L0B48
	inc $9D+x
	bra L0B95
L0B48:
	mov a, $CD+x
	cmp a, !$0247+x
	bne L0B5C
	mov a, !$0256+x
	mov !$0377+x, a
	mov a, #$00
	mov !$0376+x, a
	bra L0B83
L0B5C:
	cmp a, #$00
	bne L0B6E
	mov a, !$0387+x
	mov !$0377+x, a
	mov a, !$0386+x
	mov !$0376+x, a
	bra L0B81
L0B6E:
	mov a, !$0376+x
	clrc
	adc a, !$0386+x
	mov !$0376+x, a
	mov a, !$0377+x
	adc a, !$0387+x
	mov !$0377+x, a
L0B81:
	inc $CD+x
L0B83:
	mov a, #$00
	mov !$0237+x, a
	mov a, $9E+x
	clrc
	adc a, !$00BE+x
	mov $9E+x, a
	call L13C5
	set1 $25.2
L0B95:
	mov a, !$0277+x
	beq L0BB0
	call L13F5
	mov a, !$0346+x
	mov $06, a
	mov a, !$0347+x
	mov $07, a
	movw ya, $04
	addw ya, $08
	addw ya, $06
	jmp L1440
L0BB0:
	bbc $25.2, L0BBF
	mov a, !$0347+x
	mov y, a
	mov a, !$0346+x
	addw ya, $08
	jmp L1440
L0BBF:
	ret
L0BC0:
	bbc $26.5, L0BC6
	clr1 $26.5
	ret
L0BC6:
	mov a, $3D+x
	beq L0BE8
	dec $3D+x
	bne L0BD2
	mov a, $3E+x
	bra L0BE2
L0BD2:
	mov a, !$0110+x
	clrc
	adc a, !$0100+x
	mov !$0110+x, a
	mov a, !$0111+x
	adc a, !$0101+x
L0BE2:
	mov !$0111+x, a
	mov !$0206+x, a
L0BE8:
	mov a, $7D+x
	bne L0C32
	mov a, [$2D+x]
	cmp a, #$F3
	bne L0C32
	call L0E78
	call L0E76
	mov $7E+x, a
	call L0E76
	mov $7D+x, a
	mov a, !$0151+x
	mov $05, a
	mov a, !$0150+x
	mov $04, a
	mov a, !$0161+x
	mov $07, a
	mov a, !$0160+x
	mov $06, a
	mov a, !$03B7+x
	mov $0B, a
	mov a, !$03B6+x
	mov $0A, a
	call L0E76
	clrc
	adc a, !$0257+x
	mov y, a
	mov a, #$00
	addw ya, $04
	addw ya, $06
	addw ya, $0A
	movw $04, ya
	call L1368
L0C32:
	mov a, $6E+x
	beq L0C5A
	dec $6E+x
	bne L0C47
	mov a, !$0216+x
	mov !$0307+x, a
	mov a, #$00
	mov !$0306+x, a
	bra L0C5A
L0C47:
	mov a, !$0306+x
	clrc
	adc a, !$0316+x
	mov !$0306+x, a
	mov a, !$0307+x
	adc a, !$0317+x
	mov !$0307+x, a
L0C5A:
	mov a, !$0217+x
	beq L0C64
	mov a, #$00
	call L14AB
L0C64:
	mov a, $6D+x
	beq L0C8B
	dec $6D+x
	beq L0C80
	mov a, !$0326+x
	clrc
	adc a, !$0336+x
	mov !$0326+x, a
	mov a, !$0327+x
	adc a, !$0337+x
	mov !$0327+x, a
	ret
L0C80:
	mov a, !$0227+x
	mov !$0327+x, a
	mov a, #$00
	mov !$0326+x, a
L0C8B:
	ret
L0C8C:
	call L0E76
	mov $08, a
	and a, #$7F
	cmp a, #$60
	bcc L0C9A
	jmp L0E4C
L0C9A:
	bbc $26.1, L0CA0
	or $17, $20
L0CA0:
	bbc $08.7, L0CA8
	mov a, !$0266+x
	bra L0CAB
L0CA8:
	call L0E76
L0CAB:
	mov !$0266+x, a
	mov y, #$00
	addw ya, $2B
	movw $2B, ya
	beq L0CB8
	bpl L0CD3
L0CB8:
	bbs $26.0, L0CD0
	call L0E76
	mov y, a
	bpl L0CC4
	mov a, !$0267+x
L0CC4:
	mov !$0267+x, a
	mov !$0276+x, a
	mov a, y
	bmi L0CD0
	call L0E78
L0CD0:
	jmp L0C8C
L0CD3:
	bbc $26.0, L0CF0
	mov a, !$0276+x
	cmp a, #$65
	beq L0CE3
	or $16, $20
	or $1F, $20
L0CE3:
	mov a, !$0267+x
	mov !$0276+x, a
	mov a, !$02B7+x
	and a, #$7F
	bra L0D17
L0CF0:
	mov a, !$0276+x
	cmp a, #$65
	beq L0CFD
	or $16, $20
	or $1F, $20
L0CFD:
	call L0E76
	mov y, a
	bpl L0D06
	mov a, !$0267+x
L0D06:
	mov !$0267+x, a
	mov !$0276+x, a
	mov a, y
	bmi L0D12
	call L0E76
L0D12:
	and a, #$7F
	mov !$02B7+x, a
L0D17:
	mov !$0217+x, a
	bne L0D24
	mov a, $20
	tclr1 !$0016
	tclr1 !$001F
L0D24:
	bbc $26.1, L0D34
	mov a, $08
	and a, #$7F
	mov !$0297+x, a
	call L0F2B
	mov $08, #$3C
L0D34:
	mov a, !$0266+x
	mov y, a
	mov a, !$0267+x
	mul ya
	mov x, #$64
	clrv
	div ya, x
	mov x, $27
	bvs L0D4A
	cmp a, #$00
	bne L0D4A
	mov a, #$01
L0D4A:
	mov $4E+x, a
	mov a, !$0346+x
	mov $0C, a
	mov a, !$0347+x
	mov $0D, a
	mov a, !$0151+x
	mov $05, a
	mov a, !$0150+x
	mov $04, a
	mov a, !$0161+x
	mov $07, a
	mov a, !$0160+x
	mov $06, a
	mov a, !$03B7+x
	mov $0B, a
	mov a, !$03B6+x
	mov $0A, a
	mov a, $08
	clrc
	adc a, !$0257+x
	mov y, a
	mov a, #$00
	addw ya, $04
	addw ya, $06
	addw ya, $0A
	mov !$0346+x, a
	mov a, y
	and a, #$7F
	mov !$0347+x, a
	mov a, #$00
	mov $9E+x, a
	mov $9D+x, a
	mov $CD+x, a
	mov !$0376+x, a
	mov !$0377+x, a
	mov !$03D7+x, a
	mov !$03D6+x, a
	mov a, $8D+x
	mov $7D+x, a
	beq L0DD3
	mov a, $8E+x
	mov $7E+x, a
	mov a, !$0347+x
	mov $05, a
	mov a, !$0346+x
	mov $04, a
	bbs $26.4, L0DC6
	mov a, !$0347+x
	setc
	sbc a, !$0207+x
	mov !$0347+x, a
	call L1368
	bra L0DD3
L0DC6:
	mov a, $0D
	mov !$0347+x, a
	mov a, $0C
	mov !$0346+x, a
	call L1368
L0DD3:
	mov a, !$0347+x
	mov y, a
	mov a, !$0346+x
	jmp L1440

	.org $0DDD, "the code reads seq_command_handlers at $0DDD"
seq_command_handlers:	; $0DDD: the sequence commands $60-$64 and $E0-$FF (pushed and returned to, L0E61)
	.word seq_drums_on	; $60
	.word seq_drums_off	; $61
	.word seq_gate	; $62
	.word seq_volume	; $63
	.word seq_gate_volume	; $64
	.word seq_rest	; $E0
	.word seq_tie	; $E1
	.word seq_inst	; $E2
	.word seq_pan	; $E3
	.word seq_vibrato	; $E4
	.word seq_pitch_noise	; $E5
	.word seq_loop1_start	; $E6
	.word seq_loop1	; $E7
	.word seq_loop2_start	; $E8
	.word seq_loop2	; $E9
	.word seq_tempo	; $EA
	.word seq_tempo_fade	; $EB
	.word seq_transpose	; $EC
	.word seq_skip3	; $ED
	.word seq_channel_volume	; $EE
	.word seq_channel_volume_fade	; $EF
	.word seq_glide	; $F0
	.word seq_bend	; $F1
	.word seq_detune	; $F2
	.word seq_slide	; $F3
	.word seq_echo	; $F4
	.word seq_echo_setup	; $F5
	.word seq_repeat_start	; $F6
	.word seq_repeat	; $F7
	.word seq_pan_fade	; $F8
	.word seq_vibrato_fade	; $F9
	.word seq_envelope	; $FA
	.word seq_pitch_mod	; $FB
	.word seq_branch	; $FC
	.word seq_jump	; $FD
	.word seq_call	; $FE
	.word seq_end	; $FF

	.org $0E27, "the code reads seq_command_operands at $0E27"
seq_command_operands:	; $0E27: how many operand bytes each command has
	.byte $00, $00, $01, $01, $02, $01, $02, $01	; $60-
	.byte $01, $03, $03, $00, $03, $00, $03, $01	; $E3-
	.byte $02, $01, $03, $01, $02, $01, $03, $01	; $EB-
	.byte $03, $03, $03, $00, $00, $02, $01, $03	; $F3-
	.byte $01, $01, $02, $02, $00	; $FB-

	.org $0E4C
L0E4C:
	mov a, $08
	mov $04, #$DB
	cmp a, #$E0
	bcs L0E61
	cmp a, #$65
	bcc L0E5E
	set1 $26.5
	jmp cmd_stop_all
L0E5E:
	mov $04, #$60
L0E61:
	setc
	sbc a, $04
	asl a
	mov y, a
	mov a, !seq_command_handlers+1+y
	push a
	mov a, !seq_command_handlers+y
	push a
	mov a, y
	lsr a
	mov y, a
	mov a, !seq_command_operands+y
	beq L0E7E
L0E76:
	mov a, [$2D+x]
L0E78:
	inc $2D+x
	bne L0E7E
	inc $2E+x
L0E7E:
	ret
seq_drums_on:
	set1 $26.1
	jmp L0C8C
seq_drums_off:
	clr1 $26.1
	jmp L0C8C
seq_gate:
	mov y, a
	mov a, !$0267+x
	mov !$0276+x, a
	mov a, y
	mov !$0267+x, a
	jmp L0C8C
seq_gate_volume:
	mov y, a
	mov a, !$0267+x
	mov !$0276+x, a
	mov a, y
	mov !$0267+x, a
	call L0E76
seq_volume:
	mov !$02B7+x, a
	jmp L0C8C
seq_rest:
	mov !$0266+x, a
	or $17, $20
	mov a, #$00
	mov !$0267+x, a
	mov !$0276+x, a
	mov $4E+x, a
	mov !$0217+x, a
L0EBE:
	mov a, !$0266+x
	mov y, #$00
	addw ya, $2B
	movw $2B, ya
	beq L0ECC
	bmi L0ECC
	ret
L0ECC:
	jmp L0C8C
seq_tie:
	mov !$0266+x, a
	push a
	call L0E76
	mov !$0267+x, a
	mov !$0276+x, a
	pop y
	mul ya
	mov x, #$64
	clrv
	div ya, x
	mov x, $27
	bvs L0EEC
	or a, #$00
	bne L0EEC
	mov a, #$01
L0EEC:
	mov $4E+x, a
	jmp L0EBE
seq_inst:
	or $17, $20
	mov !$0297+x, a
	cmp a, #$19
	bcs L0EFF
	cmp a, #$14
	bcs L0F10
L0EFF:
	mov a, #<instruments
	mov $04, a
	mov a, #>instruments
	mov $05, a
	mov a, !$0297+x
	call L0F36
	jmp L0C8C
L0F10:
	mov a, !$0205
	asl a
	mov y, a
	mov a, !instrument_sets+y
	mov $04, a
	mov a, !instrument_sets+1+y
	mov $05, a
	mov a, !$0297+x
	setc
	sbc a, #$14
	call L0F36
	jmp L0C8C
L0F2B:
	mov a, #<drum_instruments
	mov $04, a
	mov a, #>drum_instruments
	mov $05, a
	mov a, !$0297+x
L0F36:
	mov y, #$08
	mul ya
	addw ya, $04
	movw $04, ya
	mov y, #$00
	mov a, #$04
	or a, $29
	mov $06, a
	mov !$00F2, a
	mov a, [$04]+y
	mov !$00F3, a
	inc y
	mov a, [$04]+y
	mov !$02A6+x, a
	inc y
	mov a, [$04]+y
	mov !$02A7+x, a
	mov $07, #$03
L0F5C:
	inc y
	inc $06
	mov a, $06
	mov !$00F2, a
	mov a, [$04]+y
	mov !$00F3, a
	dbnz $07, L0F5C
	inc y
	bbs $26.3, L0F7A
	mov a, [$04]+y
	mov !$0327+x, a
	mov a, #$00
	mov !$0326+x, a
L0F7A:
	inc y
	mov a, [$04]+y
	mov !$02B6+x, a
	ret
seq_pan:
	cmp a, #$15
	beq L0F94
	cmp a, #$16
	beq L0F99
	mov !$0327+x, a
	mov a, #$00
	mov !$0326+x, a
	jmp L0C8C
L0F94:
	set1 $26.3
	jmp L0C8C
L0F99:
	clr1 $26.3
	jmp L0C8C
seq_vibrato:
	mov !$0246+x, a
	call L0E76
	mov !$00BE+x, a
	mov y, a
	mov a, !$0206+x
	mul ya
	mov a, y
	mov !$0236+x, a
	call L0E76
	mov !$0377+x, a
	mov !$0256+x, a
	mov a, #$00
	mov !$0376+x, a
	mov !$0247+x, a
	jmp L0C8C
seq_pitch_noise:
	mov !$0277+x, a
	call L0E76
	mov !$03A7+x, a
	call L0E76
	mov !$03A6+x, a
	mov a, #$00
	mov $5E+x, a
	mov !$0396+x, a
	mov !$0397+x, a
	jmp L0C8C
seq_loop1_start:
	mov a, $2D+x
	mov !$0170+x, a
	mov a, $2E+x
	mov !$0171+x, a
	jmp L0C8C
seq_loop2_start:
	mov a, $2D+x
	mov !$0180+x, a
	mov a, $2E+x
	mov !$0181+x, a
	mov a, #$00
	mov $5D+x, a
	mov !$0140+x, a
	mov !$0141+x, a
	mov !$0160+x, a
	mov !$0161+x, a
	jmp L0C8C
seq_loop2:
	mov y, a
	mov a, x
	clrc
	adc a, #$10
	mov x, a
	mov a, y
	cmp a, #$00
	beq L1047
	inc $4D+x
	cbne $4D+x, L1047
	mov x, $27
	call L0E78
	call L0E78
	jmp L0C8C
seq_loop1:
	cmp a, #$00
	beq L1047
	inc $4D+x
	cbne $4D+x, L1047
	call L0E78
	call L0E78
	mov a, #$00
	mov $4D+x, a
	mov !$0130+x, a
	mov !$0131+x, a
	mov !$0150+x, a
	mov !$0151+x, a
	jmp L0C8C
L1047:
	mov a, !$0130+x
	mov $04, a
	mov a, !$0131+x
	mov $05, a
	push x
	mov x, $27
	call L0E76
	pop x
	mov y, #$00
	or a, #$00
	beq L106A
	bpl L1061
	dec y
L1061:
	addw ya, $04
	mov !$0130+x, a
	mov a, y
	mov !$0131+x, a
L106A:
	push x
	mov x, $27
	call L0E76
	pop x
	cmp a, #$00
	beq L1092
	mov y, #$00
	asl a
	bcc L107B
	dec y
L107B:
	mov $04, y
	asl a
	rol $04
	asl a
	rol $04
	clrc
	adc a, !$0150+x
	mov !$0150+x, a
	mov a, $04
	adc a, !$0151+x
	mov !$0151+x, a
L1092:
	mov y, $27
	mov a, !$0170+x
	mov !$002D+y, a
	mov a, !$0171+x
	mov !$002E+y, a
	mov x, $27
	jmp L0C8C
seq_tempo:
	mov !$0206+x, a
	mov a, #$00
	mov $3D+x, a
	jmp L0C8C
seq_tempo_fade:
	mov $3D+x, a
	push a
	call L0E76
	mov $3E+x, a
	setc
	sbc a, !$0206+x
	pop x
	call L134B
	mov !$0100+x, a
	mov a, y
	mov !$0101+x, a
	mov a, !$0206+x
	mov !$0111+x, a
	mov a, #$00
	mov !$0110+x, a
	jmp L0C8C
seq_transpose:
	mov !$0257+x, a
	jmp L0C8C
seq_skip3:
	call L0E78
	call L0E78
	jmp L0C8C
seq_channel_volume:
	mov !$0307+x, a
	mov a, #$00
	mov !$0306+x, a
	jmp L0C8C
seq_channel_volume_fade:
	mov $6E+x, a
	push a
	call L0E76
	mov !$0216+x, a
	setc
	sbc a, !$0307+x
	pop x
	call L134B
	mov !$0316+x, a
	mov a, y
	mov !$0317+x, a
	jmp L0C8C
seq_glide:
	mov $8D+x, a
	set1 $26.4
	mov a, #$00
	mov $8E+x, a
	jmp L0C8C
seq_bend:
	mov $8E+x, a
	call L0E76
	mov $8D+x, a
	call L0E76
	mov !$0207+x, a
	clr1 $26.4
	jmp L0C8C
seq_detune:
	mov $04, #$00
	or a, #$00
	bmi L1132
	mov y, #$04
	mul ya
	bra L113E
L1132:
	eor a, #$FF
	inc a
	mov y, #$04
	mul ya
	movw $04, ya
	movw ya, $0E
	subw ya, $04
L113E:
	mov !$03B6+x, a
	mov a, y
	mov !$03B7+x, a
	jmp L0C8C
seq_slide:
	call L0E78
	call L0E78
	jmp L0C8C
seq_echo:
	mov $1C, a
	beq L1164
	call L0E76
	mov $14, a
	call L0E76
	mov $15, a
	clr1 $18.5
	jmp L0C8C
L1164:
	mov $14, a
	mov $15, a
	set1 $18.5
	call L0E78
	call L0E78
	jmp L0C8C
seq_echo_setup:
	call L11A1
	call L0E76
	mov $19, a
	call L0E78
	mov y, #$08
L1180:
	mov a, !fir_registers-1+y
	mov !$00F2, a
	mov a, !fir_registers+7+y
	mov !$00F3, a
	dbnz y, L1180
	jmp L0C8C

	.org $1191, "the code reads fir_registers at $1191"
fir_registers:	; $1191: the DSP's FIR coefficient registers C0-C7
	.byte $0F, $1F, $2F, $3F, $4F, $5F, $6F, $7F

	.org $1199, "the code reads fir_coefficients at $1199"
fir_coefficients:	; $1199: the echo filter (written by echo_setup)
	.byte $0C, $21, $2B, $2B, $13, $FE, $F3, $F9

	.org $11A1
L11A1:
	mov $1E, a
	mov y, #$7D
	mov !$00F2, y
	mov a, !$00F3
	cmp a, $1E
	beq L11E0
	and a, #$0F
	eor a, #$FF
	bbc $1D.7, L11B9
	clrc
	adc a, $1D
L11B9:
	mov $1D, a
	mov y, #$04
L11BD:
	mov a, !$15A7+y
	mov !$00F2, a
	mov a, #$00
	mov !$00F3, a
	dbnz y, L11BD
	mov a, $18
	or a, #$20
	mov y, #$6C
	mov !$00F2, y
	mov !$00F3, a
	mov a, $1E
	mov y, #$7D
	mov !$00F2, y
	mov !$00F3, a
L11E0:
	cmp a, #$00
	beq L11ED
	asl a
	asl a
	asl a
	eor a, #$FF
	inc a
	clrc
	adc a, #$00
L11ED:
	mov y, #$6D
	mov !$00F2, y
	mov !$00F3, a
	ret
seq_repeat_start:
	mov a, $2D+x
	mov !$02E6+x, a
	mov a, $2E+x
	mov !$02E7+x, a
	mov a, #$C0
	tclr1 !$0026
	jmp L0C8C
seq_repeat:
	bbs $26.6, L1213
	bbs $26.7, L122E
	set1 $26.6
	jmp L0C8C
L1213:
	clr1 $26.6
	set1 $26.7
	mov a, $2D+x
	mov !$02F6+x, a
	mov a, $2E+x
	mov !$02F7+x, a
	mov a, !$02E6+x
	mov $2D+x, a
	mov a, !$02E7+x
	mov $2E+x, a
	jmp L0C8C
L122E:
	set1 $26.6
	clr1 $26.7
	mov a, !$02F6+x
	mov $2D+x, a
	mov a, !$02F7+x
	mov $2E+x, a
	jmp L0C8C
seq_pan_fade:
	mov $6D+x, a
	push a
	call L0E76
	mov !$0227+x, a
	setc
	sbc a, !$0327+x
	pop x
	call L134B
	mov !$0336+x, a
	mov a, y
	mov !$0337+x, a
	jmp L0C8C
seq_vibrato_fade:
	mov !$0247+x, a
	push a
	mov y, #$00
	mov a, !$0256+x
	pop x
	div ya, x
	push a
	mov a, #$00
	div ya, x
	mov x, $27
	mov !$0386+x, a
	pop a
	mov !$0387+x, a
	jmp L0C8C
seq_envelope:
	mov y, #$00
	cmp a, #$A0
	bcs L12AF
	mov x, #$0A
	div ya, x
	mov $04, a
	mov a, y
	and a, #$07
	xcn a
	or a, $04
	or a, #$80
	mov y, a
	mov a, #$05
	or a, $29
	mov x, a
	mov !$00F2, x
	mov !$00F3, y
	inc x
	mov !$00F2, x
	mov x, $27
	call L0E76
	mov y, #$00
	mov x, #$1E
	div ya, x
	inc y
	inc y
	mov $04, y
	xcn a
	asl a
	or a, $04
	mov !$00F3, a
	bra L12C7
L12AF:
	mov a, #$05
	or a, $29
	mov x, a
	mov !$00F2, x
	mov !$00F3, y
	inc x
	inc x
	mov !$00F2, x
	mov x, $27
	call L0E76
	mov !$00F3, a
L12C7:
	mov x, $27
	call L0E76
	mov y, #$10
	mul ya
	mov !$03C6+x, a
	mov a, y
	mov !$03C7+x, a
	jmp L0C8C
seq_pitch_mod:
	mov $1A, a
	jmp L0C8C
seq_branch:
	bbc $2A.0, L12ED
	cmp x, #$0A
	bne L12E7
	clr1 $2A.0
L12E7:
	call L0E78
	call L0E76
L12ED:
	push a
	call L0E76
	mov !$002E+x, a
	pop a
	mov !$002D+x, a
	jmp L0C8C
seq_jump:
	mov $04, a
	call L0E76
	mov $2E+x, a
	mov a, $04
	mov $2D+x, a
	jmp L0C8C
seq_call:
	mov $04, a
	call L0E76
	mov $05, a
	mov a, $2D+x
	mov !$0120+x, a
	mov a, $2E+x
	mov !$0121+x, a
	movw ya, $04
	mov $2D+x, a
	mov $2E+x, y
	set1 $26.2
	jmp L0C8C
seq_end:
	bbc $26.2, L1337
	clr1 $26.2
	mov a, !$0120+x
	mov $2D+x, a
	mov a, !$0121+x
	mov $2E+x, a
	jmp L0C8C
L1337:
	mov a, #$00
	mov $BD+x, a
	mov $CE+x, a
	mov !$0226+x, a
	mov a, $20
	tset1 !$0017
	tclr1 !$001F
	set1 $26.5
	ret
L134B:
	notc
	ror $04
	bpl L1353
	eor a, #$FF
	inc a
L1353:
	mov y, #$00
	div ya, x
	push a
	mov a, #$00
	div ya, x
	pop y
	mov x, $27
	bbc $04.7, L1367
	movw $04, ya
	mov a, #$00
	mov y, a
	subw ya, $04
L1367:
	ret
L1368:
	mov a, $7D+x
	beq L13C4
	mov a, !$0347+x
	mov $07, a
	mov a, !$0346+x
	mov $06, a
	movw ya, $04
	cmp y, #$60
	bcc L1388
	cmp y, #$80
	bcc L1384
	movw ya, $0E
	bra L1388
L1384:
	mov y, #$5F
	mov a, #$FF
L1388:
	mov !$0366+x, a
	push a
	mov a, y
	mov !$0367+x, a
	mov a, $7D+x
	mov x, a
	pop a
	subw ya, $06
	movw $04, ya
	notc
	ror $06
	bpl L13A7
	eor $04, #$FF
	eor $05, #$FF
	incw $04
	movw ya, $04
L13A7:
	mov y, #$00
	mov a, $05
	div ya, x
	push a
	mov a, $04
	div ya, x
	pop y
	bbc $06.7, L13BB
	movw $04, ya
	mov a, #$00
	mov y, a
	subw ya, $04
L13BB:
	mov x, $27
	mov !$0356+x, a
	mov a, y
	mov !$0357+x, a
L13C4:
	ret
L13C5:
	mov $04, a
	bbc $04.7, L13CD
	eor a, #$FF
	inc a
L13CD:
	asl a
	bpl L13D3
	eor a, #$FF
	inc a
L13D3:
	lsr a
	lsr a
	mov y, a
	mov a, !$0377+x
	mul ya
	movw $08, ya
	mov a, !$0256+x
	bmi L13E9
	lsr $09
	ror $08
	lsr $09
	ror $08
L13E9:
	bbc $04.7, L13F4
	eor $08, #$FF
	eor $09, #$FF
	incw $08
L13F4:
	ret
L13F5:
	mov a, #$00
	mov $05, a
	mov $04, a
	mov a, !$0277+x
	beq L143F
	clrc
	adc a, $5E+x
	mov $5E+x, a
	bcc L143F
	mov a, !$0397+x
	lsr a
	mov a, !$0396+x
	mov x, a
	bcc L141A
	mov a, !pitch_noise_17BC+1+x
	mov y, a
	mov a, !pitch_noise_17BC+x
	bra L1421
L141A:
	mov a, !pitch_noise_16BC+1+x
	mov y, a
	mov a, !pitch_noise_16BC+x
L1421:
	mov x, $27
	and a, !$03A6+x
	mov $04, a
	mov a, y
	and a, !$03A7+x
	mov $05, a
	mov a, !$0396+x
	clrc
	adc a, #$01
	mov !$0396+x, a
	mov a, !$0397+x
	adc a, #$00
	mov !$0397+x, a
L143F:
	ret
L1440:
	push a
	push y
	mov a, !$02A6+x
	mov $05, a
	mov a, !$02A7+x
	mov $04, a
	bmi L1454
	pop y
	pop a
	addw ya, $04
	bra L1460
L1454:
	pop a
	clrc
	adc a, $05
	mov y, a
	pop a
	clrc
	adc a, $04
	bcs L1460
	dec y
L1460:
	movw $04, ya
	mov a, y
	and a, #$7F
	asl a
	mov y, a
	mov a, !pitch_table+1+y
	mov $07, a
	mov a, !pitch_table+y
	mov $06, a
	mov a, !pitch_table+3+y
	push a
	mov a, !pitch_table+2+y
	pop y
	subw ya, $06
	bcs L1481
	mov y, #$00
	mov a, #$C9
L1481:
	push y
	mov y, $04
	mul ya
	mov $09, #$00
	mov $08, y
	pop a
	mov y, $04
	mul ya
	addw ya, $08
	addw ya, $06
	push y
	push a
	mov a, #$02
	or a, $29
	mov y, a
	pop a
	mov !$00F2, y
	mov !$00F3, a
	inc y
	pop a
	and a, #$3F
	mov !$00F2, y
	mov !$00F3, a
	ret
L14AB:
	mov $05, #$00
	mov $07, #$00
	mov $04, a
	or a, #$00
	bpl L14B9
	dec $05
L14B9:
	mov a, !$03D7+x
	mov $06, a
	mov a, !$0130+x
	mov $08, a
	mov a, !$0131+x
	mov $09, a
	mov a, !$0140+x
	mov $0A, a
	mov a, !$0141+x
	mov $0B, a
	mov a, !$0217+x
	mov y, #$00
	subw ya, $04
	subw ya, $06
	addw ya, $08
	addw ya, $0A
	cmp y, #$80
	bcs L152B
	cmp y, #$00
	bne L14EB
	or a, #$00
	bpl L14ED
L14EB:
	mov a, #$7F
L14ED:
	mov y, a
	mov a, !$0307+x
	mul ya
	asl a
	mov a, y
	rol a
	cmp $23, #$00
	beq L150E
	mov y, a
	cmp x, #$0C
	bcc L1508
	mov a, $CE+x
	cmp a, #$60
	bcs L1508
	mov a, y
	bra L150E
L1508:
	mov a, $23
	mul ya
	asl a
	mov a, y
	rol a
L150E:
	bbc $25.1, L1523
	cmp x, #$0C
	bcs L152B
	mov $04, a
	mov a, $CE+x
	cmp a, #$60
	bcc L152B
	mov a, $04
	mov y, #$32
	mul ya
	mov a, y
L1523:
	setc
	sbc a, !$02B6+x
	bcc L152B
	bcs L152D
L152B:
	mov a, #$00
L152D:
	mov $05, a
	mov a, #$0A
	bbs $25.0, L153D
	mov a, !$0327+x
	cmp a, #$15
	bcc L153D
	mov a, #$14
L153D:
	mov $04, a
	mov a, $29
	or a, #$00
	mov !$00F2, a
	mov x, $04
	mov a, !$157E+x
	mov y, $05
	mul ya
	mov x, #$7F
	div ya, x
	mov !$00F3, a
	mov x, $27
	mov a, $29
	or a, #$01
	mov !$00F2, a
	mov x, $04
	mov a, !$1593+x
	mov y, $05
	mul ya
	mov x, #$7F
	div ya, x
	mov !$00F3, a
	mov x, $27
	ret

	.org $156E
; read by the code at $09B0, $0940, $0946, $11BD, $1548, $155F (not worked out)
	.byte $00, $00, $10, $00, $20, $00, $30, $00, $40, $00, $50, $00, $60, $00, $70, $00
	.byte $00, $05, $0C, $14, $1E, $28, $32, $3C, $46, $50, $59, $62, $69, $6F, $74, $78
	.byte $7B, $7D, $7E, $7E, $7F, $7F, $7E, $7E, $7D, $7B, $78, $74, $6F, $69, $62, $59
	.byte $50, $46, $3C, $32, $28, $1E, $14, $0C, $05, $00, $2C, $3C, $0D, $4D, $6C, $4C
	.byte $5C, $3D, $2D, $5C, $14, $15, $19, $1C, $18, $16, $0E, $1B, $1A, $17

	.org $15BC, "the code reads pitch_table at $15BC"
pitch_table:	; $15BC: the DSP pitch of each note, 128 words (index: note and $7F; $60-$7F are the octave below 0)
	.word $0042, $0046, $004B, $004F, $0054, $0059, $005E, $0064
	.word $006A, $0070, $0077, $007E, $0085, $008D, $0096, $009F
	.word $00A8, $00B2, $00BD, $00C8, $00D4, $00E1, $00EE, $00FC
	.word $010B, $011B, $012C, $013E, $0151, $0165, $017A, $0191
	.word $01A9, $01C2, $01DD, $01F9, $0217, $0237, $0259, $027D
	.word $02A3, $02CB, $02F5, $0322, $0352, $0385, $03BA, $03F3
	.word $042F, $046F, $04B2, $04FA, $0546, $0596, $05EB, $0645
	.word $06A5, $070A, $0775, $07E6, $085F, $08DE, $0965, $09F4
	.word $0A8C, $0B2C, $0BD6, $0C8B, $0D4A, $0E14, $0EEA, $0FCD
	.word $10BE, $11BD, $12CB, $13E9, $1518, $1659, $17AD, $1916
	.word $1A94, $1C28, $1DD5, $1F9B, $217C, $237A, $2596, $27D2
	.word $2A30, $2CB2, $2F5A, $322C, $3528, $3850, $3BAC, $3F36
	.word $000B, $000C, $000D, $000E, $000E, $000F, $0010, $0010
	.word $0012, $0013, $0014, $0015, $0016, $0018, $0019, $001B
	.word $001C, $001E, $0020, $0021, $0023, $0026, $0028, $002A
	.word $002D, $002F, $0032, $0035, $0038, $003C, $003F, $0042

	.org $16BC, "the code reads pitch_noise_16BC at $16BC"
pitch_noise_16BC:	; $16BC: pitch_noise's pseudo-random offsets (low table, read at $141A)
	.byte $9F, $3C, $B2, $52, $AF, $45, $C7, $89, $10, $7F, $E0, $9D, $DC, $1F, $61, $16
	.byte $39, $C9, $9C, $EB, $57, $08, $66, $F8, $5A, $24, $BF, $0E, $3E, $15, $4B, $DB
	.byte $AB, $F5, $31, $0C, $43, $02, $55, $DE, $41, $DA, $BD, $AE, $19, $B0, $48, $57
	.byte $BA, $A3, $36, $0B, $F9, $DF, $17, $A8, $04, $0C, $E0, $91, $18, $5D, $DD, $D3
	.byte $28, $8A, $F2, $11, $59, $6F, $06, $0A, $34, $2A, $79, $AC, $5E, $A7, $83, $C6
	.byte $39, $C1, $B4, $3A, $3F, $FE, $4F, $EF, $1F, $00, $30, $99, $4C, $28, $83, $ED
	.byte $8A, $2F, $2C, $66, $3F, $D6, $6C, $B7, $49, $22, $BC, $65, $FA, $CF, $02, $B1
	.byte $46, $F0, $9A, $D7, $E2, $0F, $11, $C5, $74, $F6, $7A, $2C, $8F, $FB, $19, $6A
	.byte $E5, $75, $51, $4A, $FF, $B8, $7F, $62, $DB, $4F, $14, $E8, $C2, $D6, $62, $B9
	.byte $C2, $AD, $A6, $D5, $29, $F7, $14, $2E, $6C, $18, $8E, $A4, $C1, $A0, $7E, $32
	.byte $A9, $BE, $E6, $15, $B6, $7D, $F8, $A0, $E6, $12, $7A, $67, $47, $D2, $03, $58
	.byte $FD, $D1, $9E, $31, $9B, $50, $54, $A5, $EC, $72, $70, $D5, $B6, $9B, $82, $7C
	.byte $A1, $C5, $72, $B9, $A8, $33, $8B, $EB, $59, $9E, $29, $87, $8E, $36, $AD, $86
	.byte $EA, $E4, $D4, $37, $92, $AE, $45, $F0, $6E, $24, $D0, $F3, $CB, $95, $71, $E8
	.byte $C6, $38, $ED, $71, $44, $22, $2B, $60, $C0, $26, $F9, $53, $5A, $C4, $2D, $74
	.byte $C8, $50, $8D, $F7, $AC, $01, $79, $BD, $52, $10, $5E, $67, $B0, $01, $A6, $FF

	.org $17BC, "the code reads pitch_noise_17BC at $17BC"
pitch_noise_17BC:	; $17BC: pitch_noise's pseudo-random offsets (read at $1411)
	.byte $5F, $CE, $54, $64, $5C, $E7, $BA, $32, $96, $FC, $00, $E9, $CC, $77, $DC, $60
	.byte $B5, $92, $4D, $84, $1C, $68, $EE, $4E, $AF, $AB, $07, $87, $9F, $93, $BF, $88
	.byte $F1, $CD, $80, $D7, $4A, $E5, $20, $4E, $63, $44, $DA, $78, $8F, $07, $F3, $40
	.byte $98, $6B, $37, $A2, $F4, $21, $1E, $96, $13, $7E, $09, $EA, $3D, $27, $86, $4D
	.byte $BE, $8B, $CD, $D0, $FB, $A3, $1B, $97, $2A, $BC, $1A, $8C, $73, $4C, $46, $6F
	.byte $DE, $26, $8C, $B8, $33, $AA, $0E, $BB, $21, $D8, $89, $3B, $97, $1D, $BB, $23
	.byte $48, $90, $69, $FA, $C9, $76, $CE, $E7, $1B, $7B, $1A, $2B, $78, $C0, $03, $08
	.byte $6B, $CF, $CC, $B3, $6D, $A9, $B2, $3A, $16, $A1, $56, $95, $0B, $17, $F1, $12
	.byte $99, $13, $D8, $81, $56, $38, $F5, $3E, $D1, $B1, $E3, $E1, $B3, $2E, $84, $EF
	.byte $5B, $04, $64, $5D, $B5, $0A, $5B, $1D, $94, $06, $D9, $E4, $0D, $FD, $6D, $A2
	.byte $4B, $F6, $65, $A5, $CB, $AA, $5F, $E3, $70, $1E, $F2, $93, $82, $63, $27, $EE
	.byte $E2, $1C, $98, $23, $CA, $0D, $EC, $D9, $05, $F4, $3B, $53, $9D, $73, $3C, $C3
	.byte $D4, $FE, $E1, $DD, $61, $69, $90, $2D, $2F, $8D, $51, $C4, $A4, $7C, $43, $88
	.byte $34, $5C, $85, $B4, $7D, $25, $30, $58, $85, $68, $35, $C7, $47, $20, $05, $35
	.byte $09, $25, $80, $55, $CA, $6A, $91, $FC, $C8, $D3, $0F, $A7, $C3, $9A, $6E, $94
	.byte $9C, $42, $DF, $77, $42, $40, $D2, $76, $3D, $41, $81, $75, $B7, $49, $E9, $7B

	.org $18BC
L18BC:
	mov a, !$00F4
	cmp a, !$00F4
	bne L18BC
	cmp a, #$00
	bne L18C9
	ret
L18C9:
	mov !$00F4, a
	mov y, #$11
	mov !$00F1, y
	mov $0C, a
	cmp a, #$FF
	bne L18DD
	call L1AF3
	mov a, #$00
	ret
L18DD:
	cmp a, #$85
	bcs L18F2
	cmp a, #$7B
	bcs L18F5
	cmp a, #$74
	bcs L18EC
	jmp L197A
L18EC:
	setc
	sbc a, #$74
	mov !$0205, a
L18F2:
	mov a, #$00
	ret
L18F5:
	setc
	sbc a, #$7C
	asl a
	mov x, a
	mov a, #$00
	jmp [!$18FF+x]

	.org $18FF, "the code reads control_command_handlers at $18FF"
control_command_handlers:	; $18FF: commands $7C-$84 (jmp [!$18FF+x], x = 2 x (n - $7C))
	.word cmd_pause	; $7C
	.word cmd_unpause	; $7D
	.word cmd_mono	; $7E
	.word cmd_stereo	; $7F
	.word cmd_fade_out	; $80
	.word cmd_fade_out	; $81
	.word cmd_set_branch_flag	; $82
	.word cmd_stop_music	; $83
	.word cmd_stop_all	; $84

	.org $1911
cmd_pause:
	set1 $25.1
	mov y, #$60
	mov !$00F2, y
	mov !$00F3, a
	inc y
	mov !$00F2, y
	mov !$00F3, a
	mov y, #$70
	mov !$00F2, y
	mov !$00F3, a
	inc y
	mov !$00F2, y
	mov !$00F3, a
	ret
cmd_unpause:
	clr1 $25.1
	ret
cmd_mono:
	set1 $25.0
	ret
cmd_stereo:
	clr1 $25.0
	ret
cmd_fade_out:
	mov a, $0C
	setc
	sbc a, #$80
	mov x, a
	mov a, !fade_speeds+x
	mov !$0204, a
	mov $23, #$70
	mov a, #$00
	mov $24, a
	ret
cmd_set_branch_flag:
	set1 $2A.0
	ret
cmd_stop_music:
	mov a, #$00
	mov y, #$0C
	mov x, #$3F
	bra L1960
cmd_stop_all:
	mov a, #$00
	mov y, #$10
	mov x, #$FF
L1960:
	clr1 $25.1
L1962:
	mov !$00CC+y, a
	mov !$0224+y, a
	dec y
	dbnz y, L1962
	mov $23, a
	mov $19, a
	mov $1C, a
	mov $14, a
	mov $15, a
	call L11A1
	mov a, x
	ret
L197A:
	mov a, $0C
	mov $04, #<sound_table
	mov $05, #>sound_table
	dec a
	mov y, #$05
	mul ya
	addw ya, $04
	movw $04, ya
	mov y, #$00
	mov x, #$00
	mov a, [$04]+y
	mov $20, a
	inc y
	mov a, [$04]+y
	mov $06, a
	mov a, $0C
	cmp a, #$60
	bcs L1A01
	cmp a, #$5C
	bcc L19AB
	setc
	sbc a, #$5C
	mov x, a
	mov a, !$1AEF+x
	mov x, a
	bra L1A01
L19AB:
	mov x, #$0C
	cmp a, #$40
	bcs L19F7
	cmp a, #$1F
	bne L19C3
	mov a, $CE+x
	cmp a, #$1E
	beq L1A01
	mov a, $D0+x
	cmp a, #$1E
	bne L19D9
	bra L19D3
L19C3:
	cmp a, #$19
	bne L19DB
	mov a, $CE+x
	cmp a, #$18
	beq L1A01
	mov a, $D0+x
	cmp a, #$18
	bne L19D9
L19D3:
	inc x
	inc x
	asl $20
	bra L1A01
L19D9:
	mov a, $0C
L19DB:
	cmp a, $D0+x
	bne L19E5
	inc x
	inc x
	asl $20
	bra L1A01
L19E5:
	cmp a, $CE+x
	beq L1A01
	mov a, !$0226+x
	cmp a, !$0228+x
	beq L19F7
	bcc L19F7
	inc x
	inc x
	asl $20
L19F7:
	mov a, $06
	cmp a, !$0226+x
	bcs L1A01
	mov a, #$00
	ret
L1A01:
	inc y
	mov a, [$04]+y
	and a, #$0F
	mov $07, a
	mov a, [$04]+y
	xcn a
	and a, #$0F
	mov $08, a
	inc y
	mov a, [$04]+y
	mov $0A, a
	inc y
	mov a, [$04]+y
	mov $0B, a
	mov y, #$00
	mov $1A, #$00
	cmp $0C, #$60
	bcc L1A3A
	mov $23, #$00
	mov $2A, #$00
	mov a, #$00
	mov $19, a
	mov $1C, a
	mov $14, a
	mov $15, a
	set1 $18.5
	push y
	call L11A1
	pop y
L1A3A:
	mov a, [$0A]+y
	mov $2D+x, a
	mov !$0170+x, a
	mov !$0180+x, a
	mov !$02E6+x, a
	inc y
	mov a, [$0A]+y
	mov $2E+x, a
	mov !$0171+x, a
	mov !$0181+x, a
	mov !$02E7+x, a
	mov a, #$FF
	mov $BD+x, a
	mov !$0206+x, a
	mov a, #$7F
	mov !$0306+x, a
	mov !$0217+x, a
	mov a, #$0A
	mov !$0327+x, a
	mov !$0227+x, a
	mov a, #$00
	mov !$0307+x, a
	mov $3D+x, a
	mov !$0326+x, a
	mov !$02C6+x, a
	mov $4D+x, a
	mov $5D+x, a
	mov !$0130+x, a
	mov !$0131+x, a
	mov !$0140+x, a
	mov !$0141+x, a
	mov !$0150+x, a
	mov !$0151+x, a
	mov !$0160+x, a
	mov !$0161+x, a
	mov !$03B6+x, a
	mov !$03B7+x, a
	mov !$0257+x, a
	mov $8D+x, a
	mov $7D+x, a
	mov !$0376+x, a
	mov !$0377+x, a
	mov !$0256+x, a
	mov !$0277+x, a
	mov $6E+x, a
	mov $6D+x, a
	mov !$03C6+x, a
	mov !$03C7+x, a
	mov !$0267+x, a
	mov !$0276+x, a
	mov !$004E+x, a
	mov !$0266+x, a
	mov !$02D7+x, a
	mov !$0297+x, a
	mov !$02B6+x, a
	inc a
	mov !$02D6+x, a
	mov a, $0C
	mov $CE+x, a
	mov a, $06
	mov !$0226+x, a
	mov a, $08
	beq L1AE3
	mov a, #$01
	mov !$02C6+x, a
L1AE3:
	dbnz $07, L1AE9
	mov a, $20
	ret
L1AE9:
	inc x
	inc x
	inc y
	jmp L1A3A

	.org $1AEF
; read by the code at $19A5
	.byte $00, $00, $04, $08

	.org $1AF3
L1AF3:
	mov x, #$CC
	cmp x, !$00F4
	bne L1AF3
	bra L1B1C
L1AFC:
	mov y, !$00F4
	bne L1AFC
L1B01:
	cmp y, !$00F4
	bne L1B15
	mov a, !$00F5
	mov !$00F4, y
	mov [$04]+y, a
	inc y
	bne L1B01
	inc $05
	bra L1B01
L1B15:
	bpl L1B01
	cmp y, !$00F4
	bpl L1B01
L1B1C:
	mov a, !$00F6
	mov y, !$00F7
	movw $04, ya
	mov a, !$00F4
	mov y, !$00F5
	mov !$00F4, a
	mov a, y
	mov x, a
	bne L1AFC
	mov a, #$31
	mov !$00F1, a
	ret

; the sequences of the sound effects (and of sounds $6D, $6E)
	.org $1B37
	.incseq "spc_sfx.seq"

; zeros up to the song of the set ($3000)
	.org $3000, "the sound effects must end before the song of the set, at $3000"
