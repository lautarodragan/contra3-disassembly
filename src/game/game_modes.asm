; game/game_modes.asm -- Game mode state machine
; Bank $00, $00:A377-$00:AD7B. Included by main.asm in segment BANK00.
;
; sub_00A377 increments the frame counter $3A and dispatches the game mode $32
; through tbl_00A38A (15 modes, sub_00A3A8..sub_00AB76); many modes dispatch a
; sub-mode $34 through their own table. Also the end-of-life/continue checks
; (sub_00ABE0) and the per-stage choice between side-view and top-down
; (tbl_00AC2A, indexed by $70).

sub_00A377:
	.a16
	rep	#$30
	inc	frame_counter
	lda	game_mode
	phx
	asl	a
	tax
	lda	f:tbl_00A38A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00A38A:
	.addr	sub_00A3A8
	.addr	sub_00A3E4
	.addr	sub_00A3E5
	.addr	sub_00A587
	.addr	sub_00A5E0
	.addr	sub_00A625
	.addr	sub_00A64A
	.addr	sub_00A73D
	.addr	sub_00A7FE
	.addr	sub_00A8E1
	.addr	sub_00A932
	.addr	sub_00A954
	.addr	sub_00AA0A
	.addr	sub_00AB56
	.addr	sub_00AB76

sub_00A3A8:
	lda	game_submode
	bne	loc_00A3C1
	ldx	#$F537
	jsl	f:sub_0098D4
	stz	a:wram_1C60
	stz	a:wram_1C62
	lda	#$0005
	sta	force_blank_frames
	inc	game_submode
loc_00A3C0:
	rtl
loc_00A3C1:
	jsl	f:sub_00B4DD
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A3D9
	; (not executed in the CDL traces)
	lda	#$0002
	sta	force_blank_frames
	lda	#$0003
	brl	sub_00ABA3
loc_00A3D9:
	lda	a:wram_1C62
	beq	loc_00A3C0
	lda	#$0002
	brl	sub_00ABA3

sub_00A3E4:
	; (not executed in the CDL traces)
	rtl

sub_00A3E5:
	lda	game_submode
	asl	a
	tax
	jmp	(.loword(tbl_00A3EC),x)
tbl_00A3EC:
	.addr	sub_00A404
	.addr	sub_00A434
	.addr	sub_00A43B
	.addr	sub_00A460
	.addr	sub_00A46E
	.addr	sub_00A46E
	.addr	sub_00A46E
	.addr	sub_00A491
	.addr	sub_00A4DD
	.addr	sub_00A501
	.addr	sub_00A525
	.addr	sub_00A54F

sub_00A404:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	stz	a:wram_1600
	stz	a:topdown_state
	stz	a:title_menu_cursor
	stz	stage_number
	brl	loc_00AB9B

sub_00A434:
	jsl	f:sub_04D9F1
	brl	loc_00AB9B

sub_00A43B:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A44B
	; (not executed in the CDL traces)
	stz	nmi_mode
	stz	hdma_preset
	brl	loc_00ABA0
loc_00A44B:
	lda	#$0002
	sta	nmi_mode
	jsl	f:sub_00BD40
	lda	zp_36
	beq	loc_00A45F
	stz	nmi_mode
	stz	hdma_preset
	brl	loc_00AB9B
loc_00A45F:
	rtl

sub_00A460:
	jsl	f:clear_ram_1c00_1cff
	stz	a:title_menu_cursor
	jsl	f:sub_00B091
	brl	loc_00AB9B

sub_00A46E:
	lda	a:m7a_shadow
	clc
	adc	#$0020
	sta	a:m7a_shadow
	lda	a:m7d_shadow
	clc
	adc	#$0020
	sta	a:m7d_shadow
	cmp	#$0100
	bcc	loc_00A490
	stz	a:m7a_shadow
	stz	a:m7d_shadow
	brl	loc_00AB9B
loc_00A490:
	rtl

sub_00A491:
	lda	a:m7a_shadow
	clc
	adc	#$0010
	sta	a:m7a_shadow
	lda	a:m7d_shadow
	clc
	adc	#$0010
	sta	a:m7d_shadow
	cmp	#$0100
	bcc	loc_00A490
	lda	#$0100
	sta	a:m7a_shadow
	sta	a:m7d_shadow
	lda	#$0100
	sta	a:wram_1E56
	lda	#$FFA0
	sta	a:wram_1E58
	lda	#$0100
	sta	a:wram_1E5A
	lda	#$FF80
	sta	a:wram_1E5C
	lda	#$0046
	jsl	f:queue_sound
	stz	a:wram_1E64
	lda	#$0001
	sta	hdma_preset
	brl	loc_00AB9B

sub_00A4DD:
	jsl	f:sub_00B400
	lda	a:wram_1E56
	sec
	sbc	#$0004
	sta	a:wram_1E56
	cmp	#$0068
	bmi	loc_00A4F1
	rtl
loc_00A4F1:
	lda	#$0068
	sta	a:wram_1E56
	lda	#$0046
	jsl	f:queue_sound
	brl	loc_00AB9B

sub_00A501:
	jsl	f:sub_00B400
	lda	a:wram_1E58
	clc
	adc	#$0004
	sta	a:wram_1E58
	cmp	#$0050
	bpl	loc_00A515
	rtl
loc_00A515:
	lda	#$0050
	sta	a:wram_1E58
	lda	#$0046
	jsl	f:queue_sound
	brl	loc_00AB9B

sub_00A525:
	jsl	f:sub_00B400
	lda	a:wram_1E5A
	sec
	sbc	#$0004
	sta	a:wram_1E5A
	cmp	#$0050
	bmi	loc_00A539
	rtl
loc_00A539:
	lda	#$0050
	sta	a:wram_1E5A
	lda	#$0047
	jsl	f:queue_sound
	lda	#$0004
	sta	a:wram_1E64
	brl	loc_00AB9B

sub_00A54F:
	lda	#$00B0
	sta	a:wram_1E5C
	jsl	f:sub_00B400
	ldy	a:wram_1E64
	lda	frame_counter
	bit	#$0002
	beq	loc_00A569
	tya
	eor	#$FFFF
	inc	a
	tay
loc_00A569:
	sty	a:wram_1398
	sty	a:wram_1418
	lda	a:wram_1E64
	beq	loc_00A57F
	lda	frame_counter
	bit	#$000F
	bne	loc_00A57E
	dec	a:wram_1E64
loc_00A57E:
	rtl
loc_00A57F:
	lda	#$0001
	sta	game_submode
	brl	loc_00ABAF

sub_00A587:
	lda	game_submode
	bne	loc_00A5B9
	lda	#$0068
	sta	a:wram_1E56
	lda	#$0050
	sta	a:wram_1E58
	lda	#$0050
	sta	a:wram_1E5A
	lda	#$00B0
	sta	a:wram_1E5C
	stz	a:wram_1E64
	jsl	f:clear_ram_1c00_1cff
	stz	a:title_menu_cursor
	jsl	f:sub_00B0DC
	lda	#$0001
	sta	hdma_preset
	brl	loc_00AB9B
loc_00A5B9:
	jsl	f:sub_00B1AD
	jsl	f:sub_00B400
	lda	zp_36
	asl	a
	tax
	jmp	(.loword(tbl_00A5C8),x)
tbl_00A5C8:
	.addr	sub_00A5DF
	.addr	sub_00A5D0
	.addr	sub_00A5D3
	.addr	sub_00A5D9

sub_00A5D0:
	brl	loc_00ABA0

sub_00A5D3:
	lda	#$0006
	brl	sub_00ABA3

sub_00A5D9:
	; (not executed in the CDL traces)
	lda	#$0005
	brl	sub_00ABA3

sub_00A5DF:
	rtl

sub_00A5E0:
	lda	game_submode
	bne	loc_00A60D
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A5F7
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A5F7:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	lda	#$0001
	sta	a:title_menu_cursor
	jsl	f:clear_ram_1c00_1cff
	brl	loc_00AB9B
loc_00A60D:
	jsl	f:sub_00AD7C
	lda	zp_36
	beq	loc_00A624
	dec	a
	bne	loc_00A61E
	lda	#$0000
	brl	sub_00ABA3
loc_00A61E:
	; (not executed in the CDL traces)
	lda	#$0003
	brl	sub_00ABA3
loc_00A624:
	rtl

sub_00A625:
	; (not executed in the CDL traces)
	lda	game_submode
	bne	loc_00A63B
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	stz	a:inidisp_shadow
	brl	loc_00AB9B
loc_00A63B:
	jsl	f:sub_04D878
	lda	zp_36
	beq	loc_00A649
	lda	#$0003
	brl	sub_00ABA3
loc_00A649:
	rtl

sub_00A64A:
	lda	game_submode
	dec	a
	beq	loc_00A65F
	bpl	loc_00A67F
	lda	#$0001
	sta	stage_number
	stz	a:wram_1E40
	ldx	#$0050
	brl	loc_00AB99
loc_00A65F:
	lda	zp_68
	and	#$0004
	sta	zp_F0
	lda	a:title_menu_cursor
	asl	a
	tay
	ldx	a:data_05840A,y
	lda	#$2400
	jsl	f:sub_009015
	jsl	f:sub_00ABB6
	bne	loc_00A67E
	brl	loc_00AB9B
loc_00A67E:
	rtl
loc_00A67F:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A692
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A692:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	hdma_preset
	jsr	a:sub_00A6C0
	jsr	a:sub_00A734
	lda	a:title_menu_cursor
	cmp	#$0003
	bcs	loc_00A6BA
	lda	a:wram_1E60
	beq	loc_00A6B4
	; (not executed in the CDL traces)
	lda	#$0007
	brl	sub_00ABA3
loc_00A6B4:
	lda	#$0008
	brl	sub_00ABA3
loc_00A6BA:
	lda	#$000D
	brl	sub_00ABA3

sub_00A6C0:
	stz	a:wram_1E4C

sub_00A6C3:
	stz	a:wram_1600
	stz	a:topdown_state
	stz	a:wram_1E5E
	stz	a:p1_weapon_slot
	stz	a:p2_weapon_slot
	stz	a:wram_1F82
	stz	a:wram_1FC2
	stz	a:p1_weapon_1
	stz	a:p2_weapon_1
	stz	a:p1_weapon_2
	stz	a:p2_weapon_2
	stz	a:wram_1F9E
	stz	a:wram_1FDE
	stz	a:p1_barrier_timer
	stz	a:p2_barrier_timer
	lda	#$0001
	sta	a:p1_bombs
	sta	a:p2_bombs
	stz	a:p1_spin
	stz	a:p2_spin
	stz	a:wram_1FA0
	stz	a:wram_1FA2
	stz	a:wram_1FE0
	stz	a:wram_1FE2
	lda	#$0000
	sta	a:wram_1FB6
	sta	a:wram_1FF6
	lda	#$0002
	sta	a:wram_1FB8
	sta	a:wram_1FF8
	lda	a:wram_1E3C
	sta	a:p1_lives
	lda	a:title_menu_cursor
	beq	loc_00A72B
	lda	a:wram_1E3C
loc_00A72B:
	sta	a:p2_lives
	lda	a:wram_1E3E
	sta	difficulty
	rts

sub_00A734:
	ldy	difficulty
	lda	a:data_0583F6,y
	sta	a:wram_1E62
	rts

sub_00A73D:
	; (not executed in the CDL traces)
	lda	game_submode
	dec	a
	beq	loc_00A77C
	bmi	loc_00A747
	brl	loc_00A7E1
loc_00A747:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	ldx	#$841B
	lda	#$2400
	jsl	f:sub_009015
	lda	#$0100
	sta	zp_4C
	brl	loc_00AB9B
loc_00A77C:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A78B
	and	#$000F
	sta	a:inidisp_shadow
loc_00A78B:
	cmp	#$000F
	bcs	loc_00A795
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A795:
	plp
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	jsl	f:sub_009024
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00A7B4
	lda	#$0002
	jsl	f:queue_sound
	brl	loc_00AB9B
loc_00A7B4:
	bit	#$2C00
	bne	loc_00A7BA
	rtl
loc_00A7BA:
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	beq	loc_00A7D2
	dec	stage_number
	bne	loc_00A7E0
	lda	#$0006
	sta	stage_number
	rtl
loc_00A7D2:
	inc	stage_number
	lda	stage_number
	cmp	#$0007
	bcc	loc_00A7E0
	lda	#$0001
	sta	stage_number
loc_00A7E0:
	rtl
loc_00A7E1:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A7F4
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A7F4:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	loc_00ABA0

sub_00A7FE:
	lda	game_submode
	dec	a
	bne	loc_00A806
	brl	loc_00A870
loc_00A806:
	bmi	loc_00A80B
	brl	loc_00A8B8
loc_00A80B:
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:sub_00B7B2
	lda	stage_number
	asl	a
	tay
	ldx	a:data_058428,y
	lda	#$2400
	jsl	f:sub_009015
	stz	a:wram_1600
	stz	a:topdown_state
	stz	a:wram_1E5E
	lda	#$0020
	sta	zp_94
	lda	#$0010
	sta	zp_96
	lda	#$4000
	sta	zp_88
	lda	#$8000
	sta	zp_8A
	sta	zp_92
	lda	#$0080
	sta	zp_8C
	lda	#$0010
	sta	zp_8E
	brl	loc_00AB9B
loc_00A870:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A87F
	and	#$000F
	sta	a:inidisp_shadow
loc_00A87F:
	cmp	#$000F
	bcs	loc_00A889
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A889:
	plp
	rep	#$30
	phb
	lda	#$0000
	sta	f:wram_1500
	lda	#$03FE
	ldx	#$1500
	txy
	iny
	mvn	#$00, #$00
	plb
	lda	a:wram_1E4C
	bne	loc_00A8AB
	lda	stage_number
	jsl	f:sub_00B99F
loc_00A8AB:
	lda	#$0002
	sta	a:wram_1E4C
	jsl	f:sub_04D9F1
	brl	loc_00AB9B
loc_00A8B8:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00A8CB
	dec	a:inidisp_shadow
	plp
	rtl
loc_00A8CB:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	stz	zp_4A
	lda	#$0002
	sta	zp_64
	lda	stage_number
	dec	a
	sta	stage_index
	brl	loc_00ABA0

sub_00A8E1:
	jsl	f:sub_00ABDD
	lda	zp_36
	beq	loc_00A931
	lda	a:p1_lives
	ora	a:p2_lives
	bne	loc_00A8FB
	jsl	f:reset_sound_queue
	lda	#$000B
	brl	sub_00ABA3
loc_00A8FB:
	lda	stage_number
	cmp	#$0006
	bcc	loc_00A92B
	lda	#$0001
	sta	stage_number
	stz	a:wram_1E40
	lda	a:wram_1E3E
	inc	a
	inc	a
	cmp	#$0006
	bcc	loc_00A91A
	lda	#$000E
	brl	sub_00ABA3
loc_00A91A:
	; (not executed in the CDL traces)
	sta	a:wram_1E3E
	sta	difficulty
	stz	a:wram_1E4C
	jsr	a:sub_00A734
	lda	#$0008
	brl	sub_00ABA3
loc_00A92B:
	lda	#$000A
	brl	sub_00ABA3
loc_00A931:
	rtl

sub_00A932:
	lda	game_submode
	bne	loc_00A945
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	brl	loc_00AB9B
loc_00A945:
	jsl	f:sub_00B679
	lda	zp_36
	beq	loc_00A953
	lda	#$0008
	brl	sub_00ABA3
loc_00A953:
	rtl

sub_00A954:
	lda	game_submode
	phx
	asl	a
	tax
	lda	f:tbl_00A963,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00A963:
	.addr	sub_00A96D
	.addr	sub_00A9A4
	.addr	sub_00A9DD
	.addr	sub_00A9E5
	.addr	sub_00A9ED

sub_00A96D:
	jsl	f:sub_008DBE
	lda	#$0080
	sta	a:inidisp_shadow
	sep	#$20
	.a8
	sta	a:INIDISP
	rep	#$20
	.a16
	ldx	#.loword(data_05CF41)
	jsl	f:sub_0090A8
	ldy	#$8412
	jsl	f:sub_009982
	jsl	f:sub_00B7B2
	ldx	#$8472
	lda	#$2400
	jsl	f:sub_009015
	ldx	#$F513
	jsl	f:sub_0098D4
	brl	loc_00AB9B

sub_00A9A4:
	php
	lda	a:inidisp_shadow
	bit	#$0080
	beq	loc_00A9B3
	and	#$000F
	sta	a:inidisp_shadow
loc_00A9B3:
	cmp	#$000F
	bcs	loc_00A9BD
	inc	a:inidisp_shadow
	plp
	rtl
loc_00A9BD:
	plp
	lda	#$006B
	jsl	f:queue_sound
	dec	a:wram_1E62
	bmi	loc_00A9D2
	lda	#$0080
	sta	zp_76
	brl	loc_00AB9B
loc_00A9D2:
	; (not executed in the CDL traces)
	lda	#$0180
	sta	zp_76
	lda	#$0003
	sta	game_submode
	rtl

sub_00A9DD:
	dec	zp_76
	bne	loc_00A9E4
	brl	loc_00ABA0
loc_00A9E4:
	rtl

sub_00A9E5:
	; (not executed in the CDL traces)
	dec	zp_76
	bne	loc_00A9EC
	brl	loc_00AB9B
loc_00A9EC:
	rtl

sub_00A9ED:
	; (not executed in the CDL traces)
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00AA00
	dec	a:inidisp_shadow
	plp
	rtl
loc_00AA00:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	brl	loc_00AAA8

sub_00AA0A:
	lda	game_submode
	asl	a
	tax
	jmp	(.loword(tbl_00AA11),x)
tbl_00AA11:
	.addr	sub_00AA19
	.addr	sub_00AA25
	.addr	sub_00AA5D
	.addr	sub_00AA80

sub_00AA19:
	lda	#$0002
	sta	a:wram_1C02
	stz	a:wram_1C00
	brl	loc_00AB9B

sub_00AA25:
	jsr	a:sub_00AAB1
	jsr	a:sub_00AAE6
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00AA5C
	lda	#$0002
	jsl	f:queue_sound
	lda	a:wram_1C00
	beq	loc_00AA46
	; (not executed in the CDL traces)
	lda	#$0003
	brl	loc_00ABAA
loc_00AA46:
	lda	a:title_menu_cursor
	sta	a:wram_1C00
	lda	#$0003
	sta	a:wram_1C02
	ldx	#$8490
	jsl	f:sub_009024
	brl	loc_00AB9B
loc_00AA5C:
	rtl

sub_00AA5D:
	jsr	a:sub_00AAB1
	jsr	a:sub_00AB28
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$1000
	beq	loc_00AA7F
	lda	#$0002
	jsl	f:queue_sound
	lda	a:wram_1C00
	sta	a:title_menu_cursor
	stz	a:wram_1C00
	brl	loc_00AB9B
loc_00AA7F:
	rtl

sub_00AA80:
	php
	rep	#$20
	lda	a:inidisp_shadow
	and	#$000F
	sta	a:inidisp_shadow
	beq	loc_00AA93
	dec	a:inidisp_shadow
	plp
	rtl
loc_00AA93:
	lda	#$0080
	sta	a:inidisp_shadow
	plp
	lda	a:wram_1C00
	bne	loc_00AAA8
	jsr	a:sub_00A6C3
	lda	#$0008
	brl	sub_00ABA3
loc_00AAA8:
	; (not executed in the CDL traces)
	stz	a:wram_1E40
	lda	#$0003
	brl	sub_00ABA3

sub_00AAB1:
	lda	joy1_pressed
	ora	joy2_pressed
	bit	#$2C00
	beq	loc_00AAE5
	pha
	lda	#$0001
	jsl	f:queue_sound
	pla
	bit	#$0800
	bne	loc_00AAD8
	lda	a:wram_1C00
	inc	a
	cmp	a:wram_1C02
	bcc	loc_00AAD4
	lda	#$0000
loc_00AAD4:
	sta	a:wram_1C00
	rts
loc_00AAD8:
	lda	a:wram_1C00
	dec	a
	bpl	loc_00AAE2
	lda	a:wram_1C02
	dec	a
loc_00AAE2:
	sta	a:wram_1C00
loc_00AAE5:
	rts

sub_00AAE6:
	lda	a:wram_1C00
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$847E
	pha
	jsl	f:sub_009015
	pla
	ldx	#$1E62
	ldy	#$5A35
	jsl	f:sub_00AB14
	lda	a:wram_1C00
	eor	#$0001
	asl	a
	tay
	lda	a:data_0583FC,y
	ldx	#$848A
	jsl	f:sub_009015
	rts

sub_00AB14:
	sta	zp_FA
	phx
	jsl	f:sub_008D41
	plx
	lda	$00,x
	inc	a
	jsl	f:sub_00B927
	jsl	f:sub_008DB0
	rtl

sub_00AB28:
	lda	a:wram_1C00
	asl	a
	tay
	lda	a:data_058404,y
	ldx	#$8599
	jsl	f:sub_009015
	lda	a:wram_1C00
	asl	a
	tay
	lda	a:data_058402,y
	ldx	#$85A6
	jsl	f:sub_009015
	lda	a:wram_1C00
	asl	a
	tay
	lda	a:data_058400,y
	ldx	#$85B4
	jsl	f:sub_009015
	rts

sub_00AB56:
	lda	game_submode
	bne	loc_00AB68
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	bra	loc_00AB9B
loc_00AB68:
	jsl	f:sub_00B9BE
	lda	zp_36
	beq	loc_00AB75
	lda	#$0003
	bra	sub_00ABA3
loc_00AB75:
	rtl

sub_00AB76:
	lda	game_submode
	bne	loc_00AB88
	jsl	f:reset_sound_queue
	jsl	f:sub_008DBE
	jsl	f:clear_ram_1c00_1cff
	bra	loc_00AB9B
loc_00AB88:
	jsl	f:sub_00BC38
	lda	zp_36
	beq	loc_00AB95
	; (not executed in the CDL traces)
	lda	#$0002
	bra	sub_00ABA3
loc_00AB95:
	rtl
	; CDL: not accessed
	.byte	$A2, $80, $00
loc_00AB99:
	stx	zp_68
loc_00AB9B:
	lda	game_submode
	inc	a
	bra	loc_00ABAA
loc_00ABA0:
	lda	game_mode
	inc	a

sub_00ABA3:
	sta	game_mode
	lda	#$0000
	sta	zp_36
loc_00ABAA:
	sta	game_submode
	stz	zp_38
	rtl
loc_00ABAF:
	inc	game_mode
	stz	zp_36
	stz	zp_38
	rtl

sub_00ABB6:
	lda	zp_68
	beq	loc_00ABBC
	dec	zp_68
loc_00ABBC:
	rtl

; (no caller found; decoded because it follows the end of a routine)
sub_00ABBD:
	; (not executed in the CDL traces)
	jsl	f:sub_00ABC6
	rep	#$20
	stz	zp_4A
	rtl

sub_00ABC6:
	; (not executed in the CDL traces)
	rep	#$10
	rep	#$20
	stz	zp_66
	jsl	f:disable_display_and_nmi
	sep	#$20
	.a8
	jsl	f:clear_ram_1c00_1cff
	jsl	f:start_display
	rep	#$20
	.a16
	rtl

sub_00ABDD:
	jsr	a:sub_00AD2A

sub_00ABE0:
	rep	#$30
	jsr	a:sub_00AC4A
	lda	zp_4A
	bne	loc_00AC1B
	lda	zp_64
	bne	loc_00AC1B
	lda	#$0000
	ldy	a:p1_lives
	beq	loc_00ABF7
	ora	joy1_pressed
loc_00ABF7:
	ldy	a:p2_lives
	beq	loc_00ABFE
	ora	joy2_pressed
loc_00ABFE:
	bit	#$1000
	beq	loc_00AC16
	lda	zp_66
	eor	#$0001
	sta	zp_66
	asl	a
	tay
	lda	a:data_0584D6,y
	jsl	f:queue_sound
	jsr	a:sub_00ACAF
loc_00AC16:
	lda	zp_66
	beq	loc_00AC1B
	rtl
loc_00AC1B:
	lda	stage_index
	phx
	asl	a
	tax
	lda	f:tbl_00AC2A,x
	plx
	sta	zp_00
	jmp	(zp_00)
tbl_00AC2A:
	.addr	sub_00AC36
	.addr	sub_00AC3F
	.addr	sub_00AC36
	.addr	sub_00AC36
	.addr	sub_00AC3F
	.addr	sub_00AC36

sub_00AC36:
	lda	#$0002
	sta	nmi_mode
	jml	f:sub_00BD40

sub_00AC3F:
	lda	#$0004
	sta	nmi_mode
	inc	zp_78
	jml	f:run_topdown_stage

sub_00AC4A:
	jsr	a:sub_00AC7E
	lda	a:p2_spin
	beq	loc_00AC5C
	lda	#$0002
	sta	a:wram_1FC2
	sta	a:p2_weapon_slot
	rts
loc_00AC5C:
	lda	a:p2_lives
	beq	loc_00AC71
	lda	joy2_pressed
	bit	#$0040
	beq	loc_00AC71
	lda	a:wram_1FDE
	eor	#$0002
	sta	a:wram_1FDE
loc_00AC71:
	lda	a:wram_1FDE
	sta	a:wram_1FC2
	eor	#$0002
	sta	a:p2_weapon_slot
	rts

sub_00AC7E:
	lda	a:p1_spin
	beq	loc_00AC8D
	lda	#$0002
	sta	a:wram_1F82
	sta	a:p1_weapon_slot
	rts
loc_00AC8D:
	lda	a:p1_lives
	beq	loc_00ACA2
	lda	joy1_pressed
	bit	#$0040
	beq	loc_00ACA2
	lda	a:wram_1F9E
	eor	#$0002
	sta	a:wram_1F9E
loc_00ACA2:
	lda	a:wram_1F9E
	sta	a:wram_1F82
	eor	#$0002
	sta	a:p1_weapon_slot
	rts

sub_00ACAF:
	lda	zp_66
	beq	loc_00ACCF
	lda	a:inidisp_shadow
	sta	a:wram_1E4E
	lda	a:p1_view_brightness
	sta	a:wram_1E50
	lda	a:p2_view_brightness
	sta	a:wram_1E52
	jsr	a:sub_00ACE2
	jsr	a:sub_00ACFA
	jsr	a:sub_00AD12
	rts
loc_00ACCF:
	lda	a:wram_1E4E
	sta	a:inidisp_shadow
	lda	a:wram_1E50
	sta	a:p1_view_brightness
	lda	a:wram_1E52
	sta	a:p2_view_brightness
	rts

sub_00ACE2:
	lda	a:inidisp_shadow
	bit	#$0080
	bne	loc_00ACF9
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00ACF6
	; (not executed in the CDL traces)
	lda	#$0000
loc_00ACF6:
	sta	a:inidisp_shadow
loc_00ACF9:
	rts

sub_00ACFA:
	lda	a:p1_view_brightness
	bit	#$0080
	bne	loc_00AD11
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD0E
	lda	#$0000
loc_00AD0E:
	sta	a:p1_view_brightness
loc_00AD11:
	rts

sub_00AD12:
	lda	a:p2_view_brightness
	bit	#$0080
	bne	loc_00AD29
	and	#$000F
	sec
	sbc	#$0004
	bpl	loc_00AD26
	lda	#$0000
loc_00AD26:
	sta	a:p2_view_brightness
loc_00AD29:
	rts

sub_00AD2A:
	lda	a:wram_1E5E
	bne	loc_00AD5A
	lda	a:title_menu_cursor
	beq	loc_00AD5A
	jsr	a:sub_00AD3A
	jmp	a:loc_00AD5B

sub_00AD3A:
	lda	a:p1_lives
	bne	loc_00AD5A
	; (not executed in the CDL traces)
	lda	joy1_pressed
	bit	#$0080
	beq	loc_00AD5A
	lda	a:p2_lives
	cmp	#$0002
	bcc	loc_00AD5A
	inc	a:p1_lives
	dec	a:p2_lives
	lda	#$0001
	sta	a:p1_bombs
loc_00AD5A:
	rts
loc_00AD5B:
	lda	a:p2_lives
	bne	loc_00AD7B
	; (not executed in the CDL traces)
	lda	joy2_pressed
	bit	#$0080
	beq	loc_00AD7B
	lda	a:p1_lives
	cmp	#$0002
	bcc	loc_00AD7B
	inc	a:p2_lives
	dec	a:p1_lives
	lda	#$0001
	sta	a:p2_bombs
loc_00AD7B:
	rts
