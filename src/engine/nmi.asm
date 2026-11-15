; engine/nmi.asm -- NMI handler and per-frame drivers
; Bank $00, $00:819B-$00:85F2. Included by main.asm in segment BANK00.
;
; The whole game runs in the NMI. nmi saves the registers, sets D = 0 and
; DB = $05, writes NMITIMEN/HTIME/VTIME from their shadows and, unless the
; previous frame is still running (nmi_busy), calls the frame handler
; selected by nmi_mode through tbl_nmi_frame_handlers:
;
;   0  nmi_frame_default    menus, screens, loading (no stage scrolling)
;   2  nmi_frame_side_view  side-view stages (BG1/BG2/BG3 scroll, windows, HUD)
;   4  nmi_frame_top_down   top-down Mode 7 stages 2 and 5
;
; Each handler first does the vblank work with the screen blanked (scroll and
; PPU registers from their shadows, OAM and palette DMA, the VRAM queue,
; loaders' DMA), restores INIDISP from inidisp_shadow (kept blank while
; force_blank_frames counts down), then runs the frame's logic: read_joypads,
; the game mode state machine (run_game_mode), next_random, palette tasks
; (run_palette_tasks), pending loads (run_pending_loads), VRAM script tasks
; and send_queued_sound.
;
; Also here: helpers to switch the display and NMI off and on around loading
; (disable_display_and_nmi, enable_nmi, wait_nmi_and_disable_display,
; start_display).

nmi:
	.a8
	.i8
	rep	#$30
	.a16
	.i16
	pha
	phx
	phy
	phd
	phb
	sep	#$20
	.a8
	ldx	#$0000
	phx
	pld
	lda	#$05
	pha
	plb
	lda	a:RDNMI
	sei
	lda	a:nmitimen_shadow
	sta	a:NMITIMEN
	rep	#$20
	.a16
	lda	a:htime_shadow
	sta	a:HTIMEL
	lda	a:vtime_shadow
	sta	a:VTIMEL
	cli
	lda	nmi_busy
	beq	@run_frame
	lda	#$0001
	sta	nmi_busy
	bra	@exit
@run_frame:
	inc	nmi_busy
	ldx	nmi_mode
	jsr	(.loword(tbl_nmi_frame_handlers),x)
	stz	nmi_busy
@exit:
	plb
	pld
	ply
	plx
	pla
	rti
tbl_nmi_frame_handlers:
	.addr	nmi_frame_default
	.addr	nmi_frame_side_view
	.addr	nmi_frame_top_down

; Frame handler for nmi_mode 0 (menus, screens, loading).
nmi_frame_default:
	sep	#$20
	.a8
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	jsr	a:write_bg_scroll_regs
	jsr	a:write_ppu_shadows
	jsl	f:dma_vram_loader_chunk
	jsl	f:setup_hdma_channels
	jsr	a:dma_oam_and_palette
	jsl	f:run_vram_queue
	sep	#$20
	.a8
	lda	force_blank_frames
	beq	@display_on
	dec	force_blank_frames
	beq	@display_on
	lda	a:inidisp_shadow
	ora	#$80
	bra	@set_inidisp
@display_on:
	lda	a:inidisp_shadow
@set_inidisp:
	sta	a:INIDISP
	rep	#$20
	.a16
	jsl	f:read_joypads
	stz	sound_last_queued
	jsl	f:run_game_mode
	jsl	f:next_random
	jsl	f:sub_009995
	jsl	f:run_pending_loads
	jsl	f:sub_009B76
	jsl	f:send_queued_sound
	rts

; Frame handler for nmi_mode 2 (side-view stages). BG1/BG2 horizontal scroll
; is written one frame late (BG_HOFS_LATCH); the vertical scroll subtracts
; zp_A0/zp_A2. Also the 32-byte palette uploads (cgram_upload_addr), HUD
; uploads, stage HDMA, tilemap column/row DMA (dma_bg_tilemap_updates), window
; registers, and the scroll-split HDMA tables (double-buffered by the two
; MVNs in $7E:D000-$7E:D8FF).
nmi_frame_side_view:
	sep	#$20
	.a8
	lda	#$80
	sta	a:INIDISP
	rep	#$20
	.a16
	rep	#$30
	ldx	#$1380
	lda	$0A,x
	sep	#$20
	.a8
	sta	a:BG1HOFS
	xba
	sta	a:BG1HOFS
	rep	#$20
	.a16
	lda	$00,x
	sta	$0A,x
	lda	$22,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG1VOFS
	xba
	sta	a:BG1VOFS
	rep	#$20
	.a16
	lda	$18,x
	sec
	sbc	shake_bg1_y
	sta	$22,x
	ldx	#$13C0
	lda	$0A,x
	sep	#$20
	.a8
	sta	a:BG2HOFS
	xba
	sta	a:BG2HOFS
	rep	#$20
	.a16
	lda	$00,x
	sta	$0A,x
	lda	$22,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG2VOFS
	xba
	sta	a:BG2VOFS
	rep	#$20
	.a16
	lda	$18,x
	sec
	sbc	shake_bg2_y
	sta	$22,x
	ldx	#$1400
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG3HOFS
	lda	$01,x
	sta	a:BG3HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG3VOFS
	xba
	sta	a:BG3VOFS
	lda	#$E0
	sta	a:COLDATA
	rep	#$20
	.a16
	jsr	a:write_ppu_shadows
	jsl	f:dma_vram_loader_chunk
	jsr	a:dma_oam_and_palette
	sep	#$20
	.a8
	lda	cgram_upload_addr
	beq	@no_cgram_upload
	sta	a:CGADD
	ldx	cgram_upload_src
	stx	a:A1T1L
	lda	#$05
	sta	a:A1B1
	ldx	#$0020
	stx	a:DAS1L
	lda	#$02
	sta	a:MDMAEN
	lda	cgram_upload_addr2
	beq	@no_cgram_upload
	sta	a:CGADD
	ldx	cgram_upload_src
	stx	a:A1T1L
	lda	#$05
	sta	a:A1B1
	ldx	#$0020
	stx	a:DAS1L
	lda	#$02
	sta	a:MDMAEN
@no_cgram_upload:
	rep	#$20
	.a16
	jsl	f:run_vram_queue
	jsl	f:sub_00E4F6
	lda	a:title_menu_cursor
	beq	@one_player
	jsl	f:sub_00E535
@one_player:
	jsl	f:sub_00E575
	jsl	f:sub_00C283
	lda	a:w12sel_shadow
	sta	a:W12SEL
	lda	a:wobjsel_shadow
	sta	a:WOBJSEL
	lda	a:tmw_shadow
	sta	a:TMW
	sep	#$20
	.a8
	lda	a:wbglog_shadow
	sta	a:WBGLOG
	lda	force_blank_frames
	beq	@display_on
	dec	force_blank_frames
	beq	@display_on
	lda	a:inidisp_shadow
	ora	#$80
	bra	@set_inidisp
@display_on:
	lda	a:inidisp_shadow
@set_inidisp:
	sta	a:INIDISP
	rep	#$20
	.a16
	phb
	lda	#$0063
	ldx	#$D000
	ldy	#$D200
	mvn	#$7E, #$7E
	lda	#$0084
	ldx	#$D400
	ldy	#$D800
	mvn	#$7E, #$7E
	plb
	jsl	f:read_joypads
	jsl	f:sub_00E7EF
	jsl	f:sub_00E5F7
	stz	sound_last_queued
	jsl	f:run_game_mode
	jsl	f:next_random
	jsl	f:sub_009995
	jsl	f:run_pending_loads
	jsl	f:sub_009B76
	jsl	f:send_queued_sound
	lda	frame_counter
	bit	#$0001
	bne	@odd_frame
	jsl	f:sub_00E3DA
@done:
	rts
@odd_frame:
	lda	a:title_menu_cursor
	beq	@done
	jsl	f:sub_00E464
	rts

; Frame handler for nmi_mode 4 (top-down stages): Mode 7, split screen for
; two players (per-player brightness at $1FB4/$1FF4 written to the INIDISP
; HDMA table at $7E:38A1).
nmi_frame_top_down:
	sep	#$20
	.a8
	lda	#$80
	sta	f:wram_7E38A3
	sta	f:wram_7E38A7
	sta	f:wram_7E38A1
	sta	f:wram_7E38A5
	sta	a:INIDISP
	lda	a:hdmaen_shadow
	sta	a:HDMAEN
	rep	#$20
	.a16
	jsl	f:sub_02DDC6
	jsl	f:upload_m7_block_patches
	jsl	f:sub_00E4EE
	jsl	f:stream_topdown_sprite_gfx
	jsr	a:dma_oam_and_palette
	lda	force_blank_frames
	beq	@set_brightness
	dec	force_blank_frames
	bne	@after_display
@set_brightness:
	lda	a:title_menu_cursor
	beq	@inidisp_global
	dec	a
	beq	@inidisp_p1
@inidisp_global:
	sep	#$20
	.a8
	lda	a:p1_view_brightness
	sta	f:wram_7E38A3
	lda	a:p2_view_brightness
	sta	f:wram_7E38A7
	lda	a:inidisp_shadow
	sta	f:wram_7E38A1
	sta	f:wram_7E38A5
	sta	a:INIDISP
	rep	#$20
	.a16
	bra	@after_display
@inidisp_p1:
	sep	#$20
	.a8
	lda	a:p2_view_brightness
	sta	f:wram_7E38A7
	lda	a:inidisp_shadow
	sta	f:wram_7E38A1
	sta	f:wram_7E38A5
	lda	a:p1_view_brightness
	sta	f:wram_7E38A3
	sta	a:INIDISP
	rep	#$20
@after_display:
	.a16
	jsl	f:sub_02DDDC
	jsl	f:read_joypads
	stz	sound_last_queued
	jsl	f:run_game_mode
	jsl	f:next_random
	jsl	f:sub_00E3CD
	jsl	f:compute_m7_matrix
	jsl	f:draw_topdown_sprites
	jsl	f:sub_009995
	jsl	f:run_pending_loads
	jsl	f:send_queued_sound
	rts

; DMA channel 0: OAM from $7E:0FC0 ($220 bytes); channel 1: CGRAM from
; $7E:cgram_dma_src (512 bytes).
dma_oam_and_palette:
	sep	#$20
	.a8
	stz	a:OAMADDL
	ldx	#$0400
	stx	a:DMAP0
	ldx	#$0FC0
	stx	a:A1T0L
	lda	#$7E
	sta	a:A1B0
	ldx	#$0220
	stx	a:DAS0L
	stz	a:CGADD
	ldx	#$2200
	stx	a:DMAP1
	ldx	cgram_dma_src
	stx	a:A1T1L
	lda	#$7E
	sta	a:A1B1
	ldx	#$0200
	stx	a:DAS1L
	lda	#$03
	sta	a:MDMAEN
	rep	#$20
	.a16
	rts

; Sets full brightness in inidisp_shadow, enables NMI and joypad auto-read
; (NMITIMEN = $81), clears the BG scroll state (clear_bg_scroll_state) and
; keeps the screen blank for 4 frames (force_blank_frames).
start_display:
	php
	sep	#$30
	.a8
	.i8
	lda	a:RDNMI
	lda	#$0F
	sta	a:inidisp_shadow
	lda	#$81
	sta	a:nmitimen_shadow
	sta	a:NMITIMEN
	jsl	f:clear_bg_scroll_state
	.a16
	.i16
	sep	#$30
	.a8
	.i8
	lda	#$04
	sta	force_blank_frames
	plp
	.a16
	.i16
	rtl

; Writes TM, TS, CGWSEL, CGADSUB, COLDATA, OBSEL, BGMODE, MOSAIC, BGnSC and the
; Mode 7 registers from their shadows ($1E84-$1EAA).
write_ppu_shadows:
	sep	#$20
	.a8
	lda	a:tm_shadow
	sta	a:TM
	lda	a:ts_shadow
	sta	a:TS
	lda	a:cgwsel_shadow
	sta	a:CGWSEL
	lda	a:cgadsub_shadow
	sta	a:CGADSUB
	lda	a:coldata_shadow
	sta	a:COLDATA
	lda	a:obsel_shadow
	sta	a:OBSEL
	lda	a:bgmode_shadow
	sta	a:BGMODE
	lda	a:mosaic_shadow
	sta	a:MOSAIC
	lda	a:bg1sc_shadow
	sta	a:BG1SC
	lda	a:bg2sc_shadow
	sta	a:BG2SC
	lda	a:bg4sc_shadow
	sta	a:BG4SC
	lda	a:bg3sc_shadow
	sta	a:BG3SC
	lda	a:m7a_shadow
	sta	a:M7A
	lda	a:m7a_shadow+1
	sta	a:M7A
	lda	a:m7b_shadow
	sta	a:M7B
	lda	a:m7b_shadow+1
	sta	a:M7B
	lda	a:m7c_shadow
	sta	a:M7C
	lda	a:m7c_shadow+1
	sta	a:M7C
	lda	a:m7d_shadow
	sta	a:M7D
	lda	a:m7d_shadow+1
	sta	a:M7D
	lda	a:m7x_shadow
	sta	a:M7X
	lda	a:m7x_shadow+1
	sta	a:M7X
	lda	a:m7y_shadow
	sta	a:M7Y
	lda	a:m7y_shadow+1
	sta	a:M7Y
	lda	a:m7sel_shadow
	sta	a:M7SEL
	rep	#$20
	.a16
	rts

; Writes BG1-BG3 scroll registers from the BG scroll states at $1380, $13C0
; and $1400 (BG_X, BG_Y - 1).
write_bg_scroll_regs:
	rep	#$30
	ldx	#$1380
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG1HOFS
	lda	$01,x
	sta	a:BG1HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG1VOFS
	xba
	sta	a:BG1VOFS
	rep	#$20
	.a16
	ldx	#$13C0
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG2HOFS
	lda	$01,x
	sta	a:BG2HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG2VOFS
	xba
	sta	a:BG2VOFS
	rep	#$20
	.a16
	ldx	#$1400
	sep	#$20
	.a8
	lda	$00,x
	sta	a:BG3HOFS
	lda	$01,x
	sta	a:BG3HOFS
	rep	#$20
	.a16
	lda	$18,x
	dec	a
	sep	#$20
	.a8
	sta	a:BG3VOFS
	xba
	sta	a:BG3VOFS
	rep	#$20
	.a16
	rts

; Turns NMI, HDMA and DMA off and forces blank (INIDISP = $8F); sets
; force_blank_frames to 4.
disable_display_and_nmi:
	php
	sep	#$20
	.a8
	lda	a:RDNMI
	lda	#$00
	sta	a:HDMAEN
	sta	a:MDMAEN
	sta	a:NMITIMEN
set_forced_blank:
	lda	#$8F
	sta	a:INIDISP
	bra	display_off_common

; Turns NMI back on from nmitimen_shadow; sets force_blank_frames to 4 and
; stops HDMA.
enable_nmi:
	.a16
	php
	sep	#$20
	.a8
	lda	a:RDNMI
	lda	a:nmitimen_shadow
	sta	a:NMITIMEN
	lda	a:inidisp_shadow
display_off_common:
	lda	#$04
	sta	a:force_blank_frames
	lda	#$00
	sta	a:HDMAEN
	sta	a:MDMAEN
	plp
	.a16
	rtl

; If NMI is on, waits for the next NMI (sets nmi_busy bit 7, which the NMI
; clears), then like disable_display_and_nmi but leaves NMI on.
wait_nmi_and_disable_display:
	php
	sep	#$20
	.a8
	lda	a:nmitimen_shadow
	bpl	display_off_common
	lda	#$80
	sta	a:nmi_busy
@wait:
	lda	a:nmi_busy
	bmi	@wait
	bra	set_forced_blank
