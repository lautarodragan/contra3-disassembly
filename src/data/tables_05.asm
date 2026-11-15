; data/tables_05.asm -- Shared data tables (bank $05)
; Bank $05, $05:8000-$05:FFFF. Included by main.asm in segment BANK05.
;
; Most code runs with DB = $05, so this bank holds the game's tables: object
; handler pointers (tbl_object_types, tbl_shot_types), loader lists, sound block lists,
; per-stage tables, aim-direction tables, sine tables...

; The bank of the tables. Code that sets DB to it says #^tables_05; the
; loaders, which read lists with a 16-bit pointer in X, read
; f:TABLES_05_BASE,x.
tables_05:
TABLES_05_BASE = ^tables_05 << 16

data_058000:
	; CDL: not accessed
	.byte	$80, $00, $00, $00, $00, $01, $80, $00
data_058008:
	; CDL: not accessed
	.byte	$00, $01, $00, $00, $00, $00, $00, $01
data_058010:
	; CDL: read by build_wave_table, object_type_4E_state_0D; partly not accessed
	.byte	$00, $00, $24, $03, $48, $06, $6C, $09, $8F, $0C, $B2, $0F, $D4, $12, $F6, $15
	.byte	$17, $19, $37, $1C, $55, $1F, $73, $22, $8F, $25, $AA, $28, $C3, $2B, $DB, $2E
	.byte	$F0, $31, $04, $35, $16, $38, $25, $3B, $33, $3E, $3E, $41, $46, $44, $4C, $47
	.byte	$4F, $4A, $4F, $4D, $4C, $50, $46, $53, $3D, $56, $30, $59, $21, $5C, $0D, $5F
	.byte	$F6, $61, $DB, $64, $BC, $67, $99, $6A, $73, $6D, $47, $70, $18, $73, $E4, $75
	.byte	$AC, $78, $6F, $7B, $2D, $7E, $E6, $80, $9A, $83, $4A, $86, $F4, $88, $98, $8B
	.byte	$38, $8E, $D2, $90, $66, $93, $F5, $95, $7E, $98, $01, $9B, $7E, $9D, $F5, $9F
	.byte	$65, $A2, $D0, $A4, $34, $A7, $92, $A9, $E9, $AB, $3A, $AE, $83, $B0, $C7, $B2
	.byte	$03, $B5, $38, $B7, $66, $B9, $8D, $BB, $AD, $BD, $C5, $BF, $D6, $C1, $E0, $C3
	.byte	$E2, $C5, $DC, $C7, $CF, $C9, $BA, $CB, $9D, $CD, $78, $CF, $4B, $D1, $16, $D3
	.byte	$D9, $D4, $94, $D6, $46, $D8, $F0, $D9, $92, $DB, $2B, $DD, $BC, $DE, $44, $E0
	.byte	$C3, $E1, $3A, $E3, $A8, $E4, $0D, $E6, $6A, $E7, $BD, $E8, $07, $EA, $49, $EB
	.byte	$81, $EC, $B0, $ED, $D6, $EE, $F3, $EF, $07, $F1, $11, $F2, $12, $F3, $0A, $F4
	.byte	$F8, $F4, $DD, $F5, $B8, $F6, $8A, $F7, $52, $F8, $11, $F9, $C6, $F9, $71, $FA
	.byte	$13, $FB, $AB, $FB, $39, $FC, $BE, $FC, $39, $FD, $AA, $FD, $11, $FE, $6F, $FE
	.byte	$C3, $FE, $0D, $FF, $4D, $FF, $83, $FF, $AF, $FF, $D2, $FF, $EB, $FF, $FA, $FF
	.byte	$FE, $FF, $FA, $FF, $EB, $FF, $D2, $FF, $B0, $FF, $83, $FF, $4D, $FF, $0D, $FF
	.byte	$C3, $FE, $70, $FE, $12, $FE, $AB, $FD, $3A, $FD, $BF, $FC, $3A, $FC, $AC, $FB
	.byte	$14, $FB, $72, $FA, $C7, $F9, $12, $F9, $53, $F8, $8B, $F7, $BA, $F6, $DE, $F5
	.byte	$FA, $F4, $0C, $F4, $14, $F3, $13, $F2, $09, $F1, $F5, $EF, $D9, $EE, $B3, $ED
	.byte	$83, $EC, $4B, $EB, $0A, $EA, $BF, $E8, $6C, $E7, $10, $E6, $AB, $E4, $3D, $E3
	.byte	$C6, $E1, $47, $E0, $BF, $DE, $2E, $DD, $95, $DB, $F3, $D9, $49, $D8, $97, $D6
	.byte	$DC, $D4, $19, $D3, $4E, $D1, $7B, $CF, $A0, $CD, $BD, $CB, $D2, $C9, $E0, $C7
	.byte	$E6, $C5, $E4, $C3, $DA, $C1, $C9, $BF, $B1, $BD, $91, $BB, $6A, $B9, $3C, $B7
	.byte	$07, $B5, $CB, $B2, $88, $B0, $3E, $AE, $EE, $AB, $96, $A9, $39, $A7, $D5, $A4
	.byte	$6A, $A2, $F9, $9F, $82, $9D, $06, $9B, $83, $98, $FA, $95, $6B, $93, $D7, $90
	.byte	$3D, $8E, $9E, $8B, $F9, $88, $4F, $86, $A0, $83, $EB, $80, $32, $7E, $74, $7B
	.byte	$B1, $78, $E9, $75, $1D, $73, $4D, $70, $78, $6D, $9F, $6A, $C2, $67, $E1, $64
	.byte	$FC, $61, $13, $5F, $26, $5C, $36, $59, $43, $56, $4C, $53, $52, $50, $55, $4D
	.byte	$55, $4A, $52, $47, $4C, $44, $44, $41, $39, $3E, $2B, $3B, $1C, $38, $0A, $35
	.byte	$F6, $31, $E1, $2E, $C9, $2B, $B0, $28, $95, $25, $79, $22, $5B, $1F, $3D, $1C
	.byte	$1D, $19, $FC, $15, $DA, $12, $B8, $0F, $95, $0C, $72, $09, $4E, $06, $2A, $03
	.byte	$00, $00, $01, $00, $02, $00, $03, $00, $04, $00, $05, $00, $06, $00, $08, $00
	.byte	$10, $00, $50, $00, $00, $01, $00, $10
data_058228:
	; CDL: read by read_joypads
	.byte	$01, $00, $02, $00, $04, $00
data_05822E:
	; CDL: read by read_joypads, setup_hdma_channels; partly not accessed
	.byte	$08, $00
	.addr	hdma_list_0584FE
	.byte	$00, $00, $02, $00, $00, $22, $E0, $23, $00, $00, $00, $00
	; Never read in the traces (only hdma_preset 1 is used): 8 pairs (1, list);
	; each list is a word (3 or 9), $8000, pointers to 13-byte VRAM DMA records
	; (VMAIN, DMAP, BBAD, VRAM address, source in $7F, size, 0) and 0.
	.byte	$01, $00
	.addr	unused_dma_list_05825E
	.byte	$01, $00
	.addr	unused_dma_list_05826C
	.byte	$01, $00
	.addr	unused_dma_list_0582E2
	.byte	$01, $00
	.addr	unused_dma_list_0582F0
	.byte	$01, $00
	.addr	unused_dma_list_058366
	.byte	$01, $00
	.addr	unused_dma_list_058370
	.byte	$01, $00
	.addr	unused_dma_list_0583AE
	.byte	$01, $00
	.addr	unused_dma_list_0583D2
unused_dma_list_05825E:
	.byte	$03, $00, $00, $80
	.addr	unused_vram_dma_05827A
	.addr	unused_vram_dma_058287
	.addr	unused_vram_dma_058294
	.addr	unused_vram_dma_0582A1
	.byte	$00, $00
unused_dma_list_05826C:
	.byte	$03, $00
	.byte	$00, $80
	.addr	unused_vram_dma_0582AE
	.addr	unused_vram_dma_0582BB
	.addr	unused_vram_dma_0582C8
	.addr	unused_vram_dma_0582D5
	.byte	$00, $00
unused_vram_dma_05827A:
	.byte	$80, $00, $01, $18
	.byte	$00, $28, $20, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_058287:
	.byte	$80, $00, $01, $18, $00, $28, $40
	.byte	$E0, $7F, $20, $00, $00, $00
unused_vram_dma_058294:
	.byte	$80, $00, $01, $18, $00, $28, $00, $E0, $7F, $20
	.byte	$00, $00, $00
unused_vram_dma_0582A1:
	.byte	$80, $00, $01, $18, $00, $28, $60, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_0582AE:
	.byte	$80, $00, $01, $18, $10, $28, $00, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_0582BB:
	.byte	$80, $00, $01
	.byte	$18, $10, $28, $60, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_0582C8:
	.byte	$80, $00, $01, $18, $10, $28
	.byte	$20, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_0582D5:
	.byte	$80, $00, $01, $18, $10, $28, $40, $E0, $7F
	.byte	$20, $00, $00, $00
unused_dma_list_0582E2:
	.byte	$03, $00, $00, $80
	.addr	unused_vram_dma_0582FE
	.addr	unused_vram_dma_05830B
	.addr	unused_vram_dma_058318
	.addr	unused_vram_dma_058325
	.byte	$00, $00
unused_dma_list_0582F0:
	.byte	$03, $00, $00, $80
	.addr	unused_vram_dma_058332
	.addr	unused_vram_dma_05833F
	.addr	unused_vram_dma_05834C
	.addr	unused_vram_dma_058359
	.byte	$00, $00
unused_vram_dma_0582FE:
	.byte	$80, $00, $01, $18, $B0, $3B, $20, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_05830B:
	.byte	$80, $00, $01
	.byte	$18, $B0, $3B, $80, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_058318:
	.byte	$80, $00, $01, $18, $B0, $3B
	.byte	$00, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_058325:
	.byte	$80, $00, $01, $18, $B0, $3B, $A0, $E0, $7F
	.byte	$20, $00, $00, $00
unused_vram_dma_058332:
	.byte	$80, $00, $01, $18, $C0, $3B, $00, $E0, $7F, $20, $00, $00
	.byte	$00
unused_vram_dma_05833F:
	.byte	$80, $00, $01, $18, $C0, $3B, $A0, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_05834C:
	.byte	$80, $00
	.byte	$01, $18, $C0, $3B, $20, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_058359:
	.byte	$80, $00, $01, $18, $C0
	.byte	$3B, $80, $E0, $7F, $20, $00, $00, $00
unused_dma_list_058366:
	.byte	$09, $00, $00, $80
	.addr	unused_vram_dma_05837A
	.addr	unused_vram_dma_058387
	.byte	$00, $00
unused_dma_list_058370:
	.byte	$09, $00, $00, $80
	.addr	unused_vram_dma_058394
	.addr	unused_vram_dma_0583A1
	.byte	$00, $00
unused_vram_dma_05837A:
	.byte	$80, $00, $01, $18
	.byte	$90, $2A, $C0, $E0, $7F, $20, $00, $00, $00
unused_vram_dma_058387:
	.byte	$80, $00, $01, $18, $90, $2A, $20
	.byte	$E1, $7F, $20, $00, $00, $00
unused_vram_dma_058394:
	.byte	$80, $00, $01, $18, $F0, $2A, $E0, $E0, $7F, $40
	.byte	$00, $00, $00
unused_vram_dma_0583A1:
	.byte	$80, $00, $01, $18, $F0, $2A, $40, $E1, $7F, $40, $00, $00, $00
unused_dma_list_0583AE:
	.byte	$03, $00, $00, $80
	.addr	unused_vram_dma_0583B8
	.addr	unused_vram_dma_0583C5
	.byte	$00, $00
unused_vram_dma_0583B8:
	.byte	$80, $00, $01, $18, $00, $3E
	.byte	$80, $E1, $7F, $E0, $00, $00, $00
unused_vram_dma_0583C5:
	.byte	$80, $00, $01, $18, $00, $3E, $60, $E2, $7F
	.byte	$E0, $00, $00, $00
unused_dma_list_0583D2:
	.byte	$03, $00, $00, $80
	.addr	unused_vram_dma_0583DC
	.addr	unused_vram_dma_0583E9
	.byte	$00, $00
unused_vram_dma_0583DC:
	.byte	$80, $00
	.byte	$01, $18, $10, $2B, $40, $E3, $7F, $80, $00, $00, $00
unused_vram_dma_0583E9:
	.byte	$80, $00, $01, $18, $10
	.byte	$2B, $C0, $E3, $7F, $80, $00, $00, $00
continues_per_difficulty:
	; CDL: read by init_continues
.if CHEAT_CONTINUES
	.word	CHEAT_CONTINUES, CHEAT_CONTINUES, CHEAT_CONTINUES
.else
	.byte	$02, $00, $04, $00, $04, $00
.endif
data_0583FC:
	; CDL: read by continue_draw_menu
	.byte	$00, $24, $00, $20
data_058400:
	; CDL: read by continue_draw_player_menu
	.byte	$00, $20
data_058402:
	; CDL: read by continue_draw_player_menu
	.byte	$00, $20
data_058404:
	; CDL: read by continue_draw_player_menu
	.byte	$00, $24, $00, $20, $00, $20
data_05840A:
	; CDL: read by start_palette_task_at, palette_task_animate, game_mode_game_start; partly not accessed
	.addr	text_1_player, text_2_players_a, text_2_players_b, text_option
palette_task_058412:
	palette_animate	$00, $00
	palette_copy	palette_088F92, $2200
	palette_copy_end
text_stage_select:
	.byte	$2B, $5A, $4D, $4E, $3C, $42, $40, $00, $4D, $40, $47, $40, $3E
; Stage card text by stage (game_mode_stage_card: index = stage * 2, so
; entry 0 is the end of the string above).
data_058428:
	; CDL: read by draw_text, game_mode_stage_card; partly not accessed
	.byte	$4E, $FF
	.addr	text_stage_1, text_stage_2, text_stage_3, text_stage_4, text_stage_5, text_stage_6
text_stage_1:
	.byte	$6D, $5A
	.byte	$4D, $4E, $3C, $42, $40, $00, $02, $FF
text_stage_2:
	.byte	$6D, $5A, $4D, $4E, $3C, $42, $40, $00
	.byte	$03, $FF
text_stage_3:
	.byte	$6D, $5A, $4D, $4E, $3C, $42, $40, $00, $04, $FF
text_stage_4:
	.byte	$6D, $5A, $4D, $4E
	.byte	$3C, $42, $40, $00, $05, $FF
text_stage_5:
	.byte	$6D, $5A, $4D, $4E, $3C, $42, $40, $00, $06, $FF
text_stage_6:
	.byte	$6D, $5A, $4D, $4E, $3C, $42, $40, $00, $07, $FF
text_game_over:
	.byte	$2C, $5A, $42, $3C, $48, $40
	.byte	$00, $4A, $50, $40, $4C, $FF
text_continue:
	.byte	$2C, $5A, $3E, $4A, $49, $4E, $44, $49, $4F, $40
	.byte	$00, $FF
text_end:
	.byte	$8C, $5A, $40, $49, $3F, $FF
text_058490:
	.byte	$8C, $5A, $00, $00, $00, $FF, $2A
	; CDL: not accessed
	.byte	$5A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $6A
	.byte	$5A, $49, $4A, $51, $00, $47, $4A, $3C, $3F, $44, $49, $42, $00, $00, $FE, $AA
	.byte	$5A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FE, $EA
	.byte	$5A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $FF
pause_sounds:
	; CDL: read by run_stage
	.byte	$7D, $00, $7C, $00
demo_stages:
	; CDL: read by demo_init
	.byte	$01, $00, $02, $00
demo_stage_checkpoints:
	; CDL: read by demo_init, demo_init_players; partly not accessed
	.byte	$04, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
demo_p1_input_ptrs:
	; CDL: read by demo_init_input
	.faraddr	demo_input_p1_0, demo_input_p1_1, demo_input_p1_2
demo_p2_input_ptrs:
	; CDL: read by demo_init_input
	.faraddr	demo_input_p2_0, demo_input_p2_1, demo_input_p2_2
	; CDL: read by setup_hdma_channels; DMA / HDMA
hdma_list_0584FE:
	hdma_channel	$4370, $00, $05, hdma_table_05850F
	hdma_channel	$4360, $00, $2C, hdma_table_058514
	hdma_channels_end	$C0
hdma_table_05850F:
	.byte	$80, $0F, $01, $09, $00
hdma_table_058514:
	.byte	$80, $11
	.byte	$01, $04, $00
data_058519:
	; CDL: read by draw_title_menu_cursor
	.byte	$00, $20
data_05851B:
	; CDL: read by draw_title_menu_cursor
	.byte	$00, $20
data_05851D:
	; CDL: read by draw_title_menu_cursor
	.byte	$00, $20
data_05851F:
	; CDL: read by draw_title_menu_cursor
	.byte	$00, $24, $00, $20, $00, $20, $00, $20
load_list_058527:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $00
	load_vram	$0000, gfx_089249
	load_end
load_list_058530:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$6000, gfx_11EB28
	load_end
load_list_058539:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $01
	load_vram	$0000, gfx_06FADF
	load_end
load_list_058542:
	; CDL: read by draw_text, load_data_list, run_pending_loads (+3 more)
	load_list	$00, $00
	load_vram	$5000, gfx_089D7E
	load_end
palette_task_05854B:
	palette_animate	$00, $00
	palette_copy	palette_0880AA, $2200
	palette_copy	palette_088AF6, $2380
	palette_copy_end
palette_task_058558:
	palette_animate	$00, $00
	palette_copy	palette_088C1C, $2380
	palette_copy_end
text_tm_and_1992_konami_co_ltd:
	.byte	$21
	.byte	$5B, $4E, $48, $00, $3C, $49, $3F, $00, $2C, $00, $02, $0A, $0A, $03, $00, $46
	.byte	$4A, $49, $3C, $48, $44, $00, $3E, $4A, $2E, $2F, $00, $47, $4E, $3F, $2E, $FE
	.byte	$45, $5B, $47, $44, $3E, $40, $49, $4D, $40, $3F, $00, $3D, $53, $00, $49, $44
	.byte	$49, $4E, $40, $49, $3F, $4A, $FF
text_1_player:
	.byte	$2C, $5A, $02, $00, $0B, $47, $3C, $53, $40
	.byte	$4C, $00, $00, $FF
text_2_players_a:
	.byte	$6C, $5A, $03, $00, $0B, $47, $3C, $53, $40, $4C, $4D, $00
	.byte	$3C, $FF
text_2_players_b:
	.byte	$AC, $5A, $03, $00, $0B, $47, $3C, $53, $40, $4C, $4D, $00, $3D, $FF
text_option:
	.byte	$EC, $5A, $4A, $0B, $4E, $44, $4A, $49, $FF
ptrs_0585CB:
	.addr	load_list_0585D1
	.addr	load_list_058623
	.addr	load_list_058687
load_list_0585D1:
	; CDL: read by load_data_list, init_loader_context, decompress_chunk
	load_list	$01, $01
	load_wram	$7F0000, packed_0B8000
	load_wram	$7F2000, packed_0B935C
	load_wram	$7F4000, packed_0BAA9C
	load_wram	$7F6000, packed_0BBCFD
	load_wram	$7F8000, packed_0BC6A1
	load_wram	$7FA000, packed_0BD88C
	load_wram	$7FC000, packed_11CDEA
	load_wram	$7FE000, packed_11DF75
	load_wram	$7E5000, packed_0AB064
	load_wram	$7E9000, packed_0AD871
	load_wram	$7EB000, packed_0AC13B
	load_wram	$7E7000, packed_0ACDBC
	load_wram	$7EF000, packed_0ADE6D
	load_end
load_list_058623:
	; CDL: read by load_data_list, init_loader_context, decompress_chunk
	load_list	$01, $01
	load_wram	$7F0000, packed_128000
	load_wram	$7F2000, packed_129417
	load_wram	$7F4000, packed_12A7E8
	load_wram	$7F6000, packed_12BC16
	load_wram	$7F8000, packed_12CFEE
	load_wram	$7FA000, packed_12E60A
	load_wram	$7FC000, packed_138000
	load_wram	$7FE000, packed_139567
	load_wram	$7E8000, packed_13E420
	load_wram	$7E9000, packed_13ED3A
	load_wram	$7E9400, packed_13EE4E
	load_wram	$7E9800, packed_13EF62
	load_wram	$7E9C00, packed_13F076
	load_wram	$7EA000, packed_178000
	load_wram	$7EC000, packed_1798AD
	load_wram	$7EE000, packed_17AFDA
	load_end
load_list_058687:
	; CDL: read by load_data_list, init_loader_context, decompress_chunk
	load_list	$01, $01
	load_wram	$7F0000, packed_0B8000
	load_wram	$7F2000, packed_0B935C
	load_wram	$7F4000, packed_0BAA9C
	load_wram	$7F6000, packed_0BBCFD
	load_wram	$7F8000, packed_0BC6A1
	load_wram	$7FA000, packed_0BD88C
	load_wram	$7FC000, packed_11CDEA
	load_wram	$7FE000, packed_11DF75
	load_wram	$7E5000, packed_0FEDEA
	load_wram	$7E9000, packed_0EF366
	load_wram	$7EB000, packed_0FF83B
	load_wram	$7EF000, packed_0FFDB7
	load_end
data_0586D3:
	; CDL: not accessed
	.byte	$00, $01, $00, $04, $00, $05
data_0586D9:
	; CDL: not accessed
	.byte	$00, $04, $00, $05, $00, $01
data_0586DF:
	; CDL: read by draw_title_sprite_group; partly not accessed
	.byte	$00, $04, $00, $06, $00, $02
title_sprites_0586E5:
	.byte	$00, $00, $10, $00, $20, $00, $30, $00, $00, $00
	.byte	$10, $00, $20, $00, $30, $00
title_sprites_0586F5:
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $10, $00
	.byte	$10, $00, $10, $00, $10, $00
title_sprites_058705:
	.byte	$00, $38, $02, $38, $04, $38, $06, $38, $08, $38
	.byte	$0A, $38, $0C, $38, $0E, $38
title_sprites_058715:
	.byte	$00, $00, $10, $00, $20, $00, $30, $00, $40, $00
	.byte	$50, $00, $00, $00, $10, $00, $20, $00, $30, $00, $40, $00, $50, $00
title_sprites_05872D:
	.byte	$00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $10, $00, $10, $00
	.byte	$10, $00, $10, $00, $10, $00
title_sprites_058745:
	.byte	$20, $38, $22, $38, $24, $38, $26, $38, $28, $38
	.byte	$2A, $38, $2C, $38, $2E, $38, $40, $38, $42, $38, $44, $38, $46, $38
title_sprites_05875D:
	.byte	$00, $00
	.byte	$10, $00, $20, $00, $30, $00, $40, $00, $50, $00, $10, $00, $20, $00
title_sprites_05876D:
	.byte	$00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $10, $00, $10, $00
title_sprites_05877D:
	.byte	$48, $38
	.byte	$4A, $38, $4C, $38, $4E, $38, $60, $38, $62, $38, $64, $38, $66, $38
title_sprites_05878D:
	.byte	$00, $00
title_sprites_05878F:
	.byte	$00, $00
title_sprites_058791:
	.byte	$68, $38
data_058793:
	; CDL: read by draw_text, konami_logo_sweep
	.addr	text_05879B, text_05879F, text_0587A3, text_0587A7
text_05879B:
	.byte	$30, $00, $88, $FF
text_05879F:
	.byte	$30, $00, $8A, $FF
text_0587A3:
	.byte	$30, $00, $8C, $FF
text_0587A7:
	.byte	$30, $00, $8E, $FF
load_list_0587AB:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk (+2 more)
	load_list	$00, $00
	load_vram	$2000, gfx_07E9FE
	load_vram	$1000, gfx_088FD4
	load_vram	$0000, gfx_0891DE
	load_vram	$0100, gfx_089225
	load_end
palette_task_0587C3:
	palette_animate	$00, $00
	palette_copy	gfx_08, $2260
	palette_copy	palette_088022, $2200
	palette_copy	palette_088022, $2220
	palette_copy	palette_088022, $2240
	palette_copy_end
palette_task_0587D8:
	palette_animate	$00, $00
	palette_copy	palette_088044, $2200
	palette_copy_end
palette_task_0587E1:
	palette_animate	$00, $00
	palette_copy	palette_088066, $2220
	palette_copy_end
palette_task_0587EA:
	palette_animate	$00, $00
	palette_copy	palette_088088, $2240
; Load lists of the stage clear pictures, by stage_number (1-5); entry 0 is
; the end word of the palette task before.
ptrs_stage_clear_pictures:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk (+3 more); partly not accessed
	palette_copy_end
	.addr	load_list_058808
	.addr	load_list_058820
	.addr	load_list_058838
	.addr	load_list_058850
	.addr	load_list_058868
	; Never executed: code bytes left in the data (jsl reset_video_state,
	; ldx #load_list_058808, jsl load_data_list).
	.byte	$22
	.faraddr	reset_video_state
	.byte	$A2
	.addr	load_list_058808
	.byte	$22
	.faraddr	load_data_list
load_list_058808:
	load_list	$00, $00
	load_vram	$2000, gfx_188000
	load_vram	$3000, gfx_1899A4
	load_vram	$0000, gfx_18AAE3
	load_vram	$5000, gfx_089D7E
	load_end
load_list_058820:
	load_list	$00, $00
	load_vram	$2000, gfx_18AF20
	load_vram	$3000, gfx_18C896
	load_vram	$0000, gfx_18D15B
	load_vram	$5000, gfx_089D7E
	load_end
load_list_058838:
	load_list	$00, $00
	load_vram	$2000, gfx_18D4E3
	load_vram	$3000, gfx_18E9DF
	load_vram	$0000, gfx_18FAF5
	load_vram	$5000, gfx_089D7E
	load_end
load_list_058850:
	load_list	$00, $00
	load_vram	$2000, gfx_198000
	load_vram	$3000, gfx_199AB1
	load_vram	$0000, gfx_19AB40
	load_vram	$5000, gfx_089D7E
	load_end
load_list_058868:
	load_list	$00, $00
	load_vram	$2000, gfx_19AF8C
	load_vram	$3000, gfx_19CAB9
	load_vram	$0000, gfx_19D779
	load_vram	$5000, gfx_089D7E
	load_end
palette_task_058880:
	palette_animate	$00, $00
	palette_copy	palette_08882C, $2200
	palette_copy_end
palette_task_058889:
	palette_animate	$00, $00
	palette_copy	palette_08892E, $2240
	palette_copy_end
	; CDL: read by draw_text
text_hi_score:
	.byte	$6C, $58, $43, $44, $00, $4D, $3E, $4A, $4C, $40, $FF
text_1p_score:
	.byte	$E3, $58, $02, $0B, $00
	.byte	$4D, $3E, $4A, $4C, $40, $FF
text_rest_03:
	.byte	$64, $59, $4C, $40, $4D, $4E, $00, $01, $04, $FF
text_2p_score:
	.byte	$F5, $58, $03, $0B, $00, $4D, $3E, $4A, $4C, $40, $FF
text_rest_03_2:
	.byte	$76, $59, $4C, $40, $4D
	.byte	$4E, $00, $01, $04, $FF
text_stage_clear_bonus:
	.byte	$0B, $5A, $4D, $4E, $3C, $42, $40, $00, $3E, $47, $40
	.byte	$3C, $4C, $FE, $6B, $5A, $3E, $47, $40, $3C, $4C, $00, $3D, $4A, $49, $4F
ptrs_0588E1:
	.addr	data_05FF4D
	.addr	load_list_058A93
	.addr	load_list_05CF4A
	.addr	load_list_058A93
	.addr	load_list_058A93
	.addr	load_list_05CF4A
ptrs_0588ED:
	.addr	load_list_058A93
	.addr	load_list_058AE6
	.addr	load_list_05CF7E
	.addr	load_list_058B5D
	.addr	load_list_058BF8
	.addr	load_list_05D028
	.addr	load_list_058C6F
lives_options:
	; CDL: read by options_store_lives; partly not accessed
	.byte	$03, $00, $05, $00, $07, $00, $1E, $00
data_058903:
	; CDL: read by draw_text, options_change_level
	.addr	text_easy, text_normal, text_hard
text_easy:
	.byte	$D2, $59, $40, $3C, $4D, $53, $00, $00, $00, $00
	.byte	$FF
text_normal:
	.byte	$D2, $59, $49, $4A, $4C, $48, $3C, $47, $00, $00, $FF
text_hard:
	.byte	$D2, $59, $43, $3C
	.byte	$4C, $3F, $00, $00, $00, $00, $FF
sound_mode_commands:
	; CDL: read by draw_text; partly not accessed
	.byte	$7F, $00, $7E, $00
data_05892E:
	; CDL: read by draw_text, options_apply_sound_mode; partly not accessed
	.addr	text_stereo, text_monaural
text_stereo:
	.byte	$12, $5A, $4D, $4E, $40, $4C, $40, $4A, $00, $00, $FF
text_monaural:
	.byte	$12
	.byte	$5A, $48, $4A, $49, $3C, $4F, $4C, $3C, $47, $FF
text_option_mode:
	.byte	$0A, $59, $4A, $0B, $4E, $44
	.byte	$4A, $49, $00, $48, $4A, $3F, $40, $FF
text_player:
	.byte	$8A, $59, $0B, $47, $3C, $53, $40, $4C
	.byte	$FF
text_level:
	.byte	$CA, $59, $47, $40, $50, $40, $47, $FF
text_sound:
	.byte	$0A, $5A, $4D, $4A, $4F, $49, $3F
	.byte	$FF
text_exit:
	.byte	$4A, $5A, $40, $52, $44, $4E, $FF
load_list_058976:
	; CDL: read by draw_text, load_data_list, run_pending_loads (+3 more)
	load_list	$00, $00
	load_vram	$2000, gfx_1FE855
	load_vram	$3000, gfx_1AE9C9
	load_vram	$0000, gfx_1EEBD0
	load_vram	$5000, gfx_089D7E
	load_end
palette_task_05898E:
	palette_animate	$00, $00
	palette_copy	palette_088B7A, $2200
	palette_copy_end
	; CDL: read by draw_text
text_hi_score_2:
	.byte	$AC, $58, $43, $44, $00, $4D, $3E, $4A, $4C, $40, $FF
text_1p_score_2:
	.byte	$A3, $58, $02, $0B, $00
	.byte	$4D, $3E, $4A, $4C, $40, $FF
text_rest_03_3:
	.byte	$24, $59, $4C, $40, $4D, $4E, $00, $01, $04, $FF
text_2p_score_2:
	.byte	$B5, $58, $03, $0B, $00, $4D, $3E, $4A, $4C, $40, $FF
text_rest_03_4:
	.byte	$36, $59, $4C, $40, $4D
	.byte	$4E, $00, $01, $04, $FF
stage_layouts:
	; CDL: read by stage_init
	.byte	$08, $00, $02, $02, $04, $04, $06
data_0589D3:
	; CDL: read by stage_init; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $09, $00, $07, $80, $00
	.byte	$00, $04, $00, $00
data_0589E7:
	; CDL: read by stage_init; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $00
	.byte	$00, $00, $00, $00
data_0589FB:
	; CDL: read by stage_init
	.byte	$00, $00, $00, $00, $05, $00, $00, $00
ptrs_stage_dp_params:
	; CDL: read by stage_init
	.addr	stage_dp_params_058A2B, stage_dp_params_058A45, stage_dp_params_058A5F, stage_dp_params_058A79, stage_dp_params_058A5F
ptrs_stage_load_lists:
	; CDL: read by stage_setup_video; partly not accessed
	.addr	load_list_058B08, load_list_058B85, load_list_058C14, load_list_058C97
	.addr	load_list_058B08, load_list_058B2F, load_list_058BB6, load_list_058C3B
	.addr	load_list_058C97, load_list_058B08
ptrs_stage_palette_tasks:
	; CDL: read by stage_init, load_stage_dp_params; partly not accessed
	.addr	palette_task_058B4C, palette_task_058BE7, palette_task_058C62, palette_task_058CCD, palette_task_058B4C
stage_dp_params_058A2B:
	.byte	$91, $03, $ED, $03, $F4, $03
	.byte	$F8, $03, $FA, $03, $00, $00, $00, $00, $00, $00, $00, $00, $FC, $03, $FE, $03
	.byte	$00, $04, $00, $00
stage_dp_params_058A45:
	.byte	$68, $03, $D4, $03, $D7, $03, $00, $00, $00, $00, $E0, $03
	.byte	$E9, $03, $EC, $03, $EF, $03, $F1, $03, $F3, $03, $F5, $03, $00, $04
stage_dp_params_058A5F:
	.byte	$00, $04
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00
stage_dp_params_058A79:
	.byte	$B5, $03, $EA, $03, $F2, $03, $F8, $03
	.byte	$00, $04, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00
load_list_058A93:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+3 more)
	load_list	$01, $00
	load_wram	$7F0000, packed_0B8000
	load_wram	$7F2000, packed_0B935C
	load_wram	$7F4000, packed_0BAA9C
	load_wram	$7F6000, packed_0BBCFD
	load_wram	$7F8000, packed_0BC6A1
	load_wram	$7FA000, packed_0BD88C
	load_wram	$7FC000, packed_11CDEA
	load_wram	$7FE000, packed_11DF75
	load_end
palette_task_058AC7:
	palette_animate	$00, $00
	palette_copy	palette_0882B6, $2300
	palette_copy	palette_088254, $23A0
	palette_copy_end
load_list_058AD4:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$6000, gfx_0DA728
	load_end
load_list_058ADD:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$5000, gfx_089D7E
	load_end
load_list_058AE6:
	; CDL: read by load_data_list, run_pending_loads, init_loader_context (+4 more)
	load_list	$01, $00
	load_wram	$7E5000, packed_0AB064
	load_wram	$7E9000, packed_0AD871
	load_wram	$7EB000, packed_0AC13B
	load_wram	$7E7000, packed_0ACDBC
	load_wram	$7EF000, packed_0ADE6D
	load_end
load_list_058B08:
	load_list	$00, $00
	load_vram	$0000, gfx_098000
	load_vram	$1000, gfx_09998E
	load_vram	$2000, gfx_09B32D
	load_vram	$3000, gfx_09CD49
	load_vram	$7000, gfx_0DBCEB
	load_vram	$7400, gfx_0DC2FE
	load_vram	$7800, gfx_0DC90C
	load_end
load_list_058B2F:
	load_list	$00, $00
	load_vram	$0000, gfx_098000
	load_vram	$1000, gfx_09998E
	load_vram	$2000, gfx_09B32D
	load_vram	$3000, gfx_09CD49
	load_vram	$7000, gfx_0EDD88
	load_end
palette_task_058B4C:
	palette_animate	$00, $00
	palette_copy	palette_088150, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_0883BA, $2340
	palette_copy_end
load_list_058B5D:
	; CDL: read by load_data_list, run_pending_loads, init_loader_context (+2 more)
	load_list	$01, $00
	load_wram	$7E5000, packed_0D8CC4
	load_wram	$7E9000, packed_0EF5A2
	load_wram	$7EB000, packed_0D8000
	load_wram	$7E7000, packed_0D9C9E
	load_wram	$7EF000, packed_0DA5E5
	load_wram	$7EA000, packed_0EE8B1
	load_end
load_list_058B85:
	load_list	$00, $00
	load_vram	$0000, gfx_0C8000
	load_vram	$1000, gfx_0C98A2
	load_vram	$2000, gfx_0CAFBF
	load_vram	$3000, gfx_0CC65E
	load_vram	$7000, gfx_0E8000
	load_vram	$7200, gfx_0E8307
	load_vram	$7400, gfx_0DC2FE
	load_vram	$7800, gfx_0DD6D3
	load_vram	$7C00, gfx_0E8651
	load_end
	; CDL: read by start_palette_task_at, palette_task_animate; partly not accessed
load_list_058BB6:
	load_list	$00, $00
	load_vram	$0000, gfx_0C8000
	load_vram	$1000, gfx_0C98A2
	load_vram	$2000, gfx_0CAFBF
	load_vram	$3000, gfx_0CC65E
	load_vram	$7000, gfx_0E8000
	load_vram	$7200, gfx_0E8C89
	load_vram	$7400, gfx_0DC2FE
	load_vram	$7800, gfx_0DD6D3
	load_vram	$7C00, gfx_0E8F5B
	load_end
palette_task_058BE7:
	palette_animate	$00, $00
	palette_copy	palette_0882F8, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_088602, $2340
	palette_copy_end
load_list_058BF8:
	; CDL: read by load_data_list, run_pending_loads, init_loader_context (+2 more)
	load_list	$01, $00
	load_wram	$7E5000, packed_0FEDEA
	load_wram	$7E9000, packed_0EF366
	load_wram	$7EB000, packed_0FF83B
	load_wram	$7EF000, packed_0FFDB7
	load_end
load_list_058C14:
	load_list	$00, $00
	load_vram	$0000, gfx_0F8000
	load_vram	$1000, gfx_0F9460
	load_vram	$2000, gfx_0FAC90
	load_vram	$3000, gfx_0FC8E5
	load_vram	$7600, gfx_0EDA4E
	load_vram	$7000, gfx_0E9584
	load_vram	$7800, gfx_0DEF88
	load_end
	; CDL: read by start_palette_task_at, palette_task_animate; partly not accessed
load_list_058C3B:
	load_list	$00, $00
	load_vram	$0000, gfx_0F8000
	load_vram	$1000, gfx_0F9460
	load_vram	$2000, gfx_0FAC90
	load_vram	$3000, gfx_0FD147
	load_vram	$7600, gfx_0EDA4E
	load_vram	$7000, gfx_0E9584
	load_vram	$7800, gfx_0DEF88
	load_end
palette_task_058C62:
	palette_animate	$00, $00
	palette_copy	palette_08843E, $2200
	palette_copy	palette_088664, $2340
	palette_copy_end
load_list_058C6F:
	; CDL: read by load_data_list, run_pending_loads, init_loader_context (+4 more)
	load_list	$01, $00
	load_wram	$7E5000, packed_19DB20
	load_wram	$7E7000, packed_09FA34
	load_wram	$7E9000, packed_10F1FE
	load_wram	$7EB000, packed_16DF52
	load_wram	$7EF000, packed_10F731
	load_wram	$7EA000, packed_11B7AF
	load_end
load_list_058C97:
	load_list	$00, $00
	load_vram	$0000, gfx_108000
	load_vram	$1000, gfx_109C17
	load_vram	$2000, gfx_10B927
	load_vram	$3000, gfx_10D5A2
	load_vram	$7000, gfx_0E8000
	load_vram	$7200, gfx_0E8C89
	load_vram	$7400, gfx_0DC2FE
	load_vram	$7800, gfx_0DD6D3
	load_vram	$7C00, gfx_0E8F5B
	load_vram	$7000, gfx_0EA34B
	load_end
palette_task_058CCD:
	palette_animate	$00, $00
	palette_copy	palette_088540, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_0886C6, $2340
	palette_copy_end
data_058CDE:
	; CDL: read by player_autopilot_mode1; partly not accessed
	.byte	$68, $00, $98, $00
data_058CE2:
	; CDL: read by draw_bg3_block_map
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B3, $E0, $B7, $20, $B8, $00, $B3, $20, $B3, $40, $B3, $E0, $B7, $20, $B8
	.byte	$00, $B0, $00, $B0, $00, $B3, $00, $B8, $E0, $B7, $20, $B8, $00, $B0, $00, $B0
	.byte	$E0, $B7, $20, $B8, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B3, $00, $B8
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B3, $E0, $B7, $20, $B8, $00, $B0, $00, $B0
	.byte	$00, $B3, $20, $B3, $40, $B3, $E0, $B7, $20, $B8, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B3, $E0, $B7, $20, $B8, $00, $B0
data_058D52:
	; CDL: read by bg1_scroll_vertical; partly not accessed
	.byte	$00, $00, $00, $C0, $00, $20, $00, $00
; Velocity of 8 pixels a frame in 64 directions (index = angle & $7E, $00
; up, $20 right, $40 down, $60 left): vel8_x (pixels) and vel8_x_sub
; (fraction); vel8_y / vel8_y_sub are the same sine tables read a
; quarter turn ($20 bytes) earlier.  Player shots (spawn_shot_default...)
; and some enemies.
vel8_y:
	; CDL: read by spawn_shot_default, spawn_shots_spread, stage3_boss_spawn_debris_sparks
	.byte	$F8, $FF, $F8, $FF, $F8, $FF, $F8, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $FA, $FF
	.byte	$FA, $FF, $FB, $FF, $FB, $FF, $FC, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FF, $FF
vel8_x:
	; CDL: read by spawn_shot_default, spawn_shots_spread, stage3_second_robot_spawn_debris (+1 more)
	.byte	$00, $00, $00, $00, $01, $00, $02, $00, $02, $00, $03, $00, $04, $00, $04, $00
	.byte	$05, $00, $05, $00, $06, $00, $06, $00, $06, $00, $07, $00, $07, $00, $07, $00
	.byte	$07, $00, $07, $00, $07, $00, $07, $00, $06, $00, $06, $00, $06, $00, $05, $00
	.byte	$05, $00, $04, $00, $04, $00, $03, $00, $02, $00, $02, $00, $01, $00, $00, $00
	.byte	$00, $00, $FF, $FF, $FE, $FF, $FD, $FF, $FD, $FF, $FC, $FF, $FB, $FF, $FB, $FF
	.byte	$FA, $FF, $FA, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $F8, $FF, $F8, $FF, $F8, $FF
	.byte	$F8, $FF, $F8, $FF, $F8, $FF, $F8, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $FA, $FF
	.byte	$FA, $FF, $FB, $FF, $FB, $FF, $FC, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FF, $FF
vel8_y_sub:
	; CDL: read by spawn_shot_default, spawn_shots_spread, stage3_boss_spawn_debris_sparks
	.byte	$9A, $99, $B9, $A2, $01, $BE, $2D, $EB, $CE, $29, $4A, $79, $DE, $D8, $9C, $47
	.byte	$75, $C4, $35, $4E, $88, $E3, $FD, $82, $0C, $2B, $16, $DA, $6C, $8E, $51, $46
vel8_x_sub:
	; CDL: read by spawn_shot_default, spawn_shots_spread, stage3_second_robot_spawn_debris (+1 more)
	.byte	$00, $00, $AF, $B9, $94, $71, $EA, $25, $F4, $D4, $03, $7D, $78, $1C, $CB, $B1
	.byte	$8B, $3B, $64, $B8, $22, $27, $B6, $86, $32, $D6, $D3, $14, $FF, $41, $47, $5D
	.byte	$66, $66, $47, $5D, $FF, $41, $D3, $14, $32, $D6, $B6, $86, $22, $27, $64, $B8
	.byte	$8B, $3B, $CB, $B1, $78, $1C, $03, $7D, $F4, $D4, $EA, $25, $94, $71, $AF, $B9
	.byte	$00, $00, $51, $46, $6C, $8E, $16, $DA, $0C, $2B, $FD, $82, $88, $E3, $35, $4E
	.byte	$75, $C4, $9C, $47, $DE, $D8, $4A, $79, $CE, $29, $2D, $EB, $01, $BE, $B9, $A2
	.byte	$9A, $99, $B9, $A2, $01, $BE, $2D, $EB, $CE, $29, $4A, $79, $DE, $D8, $9C, $47
	.byte	$75, $C4, $35, $4E, $88, $E3, $FD, $82, $0C, $2B, $16, $DA, $6C, $8E, $51, $46
data_058E9A:
	; CDL: read by spawn_shots_flame, sub_04D0EA
	.byte	$F1, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF
	.byte	$F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F3, $FF
	.byte	$F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F4, $FF, $F4, $FF
	.byte	$F4, $FF, $F4, $FF, $F4, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F6, $FF
	.byte	$F6, $FF, $F6, $FF, $F6, $FF, $F7, $FF, $F7, $FF, $F7, $FF, $F8, $FF, $F8, $FF
	.byte	$F8, $FF, $F8, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $FA, $FF, $FA, $FF, $FA, $FF
	.byte	$FB, $FF, $FB, $FF, $FB, $FF, $FC, $FF, $FC, $FF, $FC, $FF, $FD, $FF, $FD, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00
data_058F1A:
	; CDL: read by spawn_shots_flame, sub_04D0EA
	.byte	$00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00
	.byte	$02, $00, $03, $00, $03, $00, $04, $00, $04, $00, $04, $00, $05, $00, $05, $00
	.byte	$05, $00, $06, $00, $06, $00, $06, $00, $07, $00, $07, $00, $07, $00, $08, $00
	.byte	$08, $00, $08, $00, $08, $00, $09, $00, $09, $00, $09, $00, $0A, $00, $0A, $00
	.byte	$0A, $00, $0A, $00, $0B, $00, $0B, $00, $0B, $00, $0B, $00, $0C, $00, $0C, $00
	.byte	$0C, $00, $0C, $00, $0C, $00, $0D, $00, $0D, $00, $0D, $00, $0D, $00, $0D, $00
	.byte	$0D, $00, $0D, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00
	.byte	$0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00
	.byte	$0F, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00
	.byte	$0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0E, $00, $0D, $00
	.byte	$0D, $00, $0D, $00, $0D, $00, $0D, $00, $0D, $00, $0D, $00, $0C, $00, $0C, $00
	.byte	$0C, $00, $0C, $00, $0C, $00, $0B, $00, $0B, $00, $0B, $00, $0B, $00, $0A, $00
	.byte	$0A, $00, $0A, $00, $0A, $00, $09, $00, $09, $00, $09, $00, $08, $00, $08, $00
	.byte	$08, $00, $08, $00, $07, $00, $07, $00, $07, $00, $06, $00, $06, $00, $06, $00
	.byte	$05, $00, $05, $00, $05, $00, $04, $00, $04, $00, $04, $00, $03, $00, $03, $00
	.byte	$02, $00, $02, $00, $02, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FD, $FF, $FD, $FF, $FC, $FF, $FC, $FF, $FC, $FF, $FB, $FF, $FB, $FF
	.byte	$FB, $FF, $FA, $FF, $FA, $FF, $FA, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $F8, $FF
	.byte	$F8, $FF, $F8, $FF, $F8, $FF, $F7, $FF, $F7, $FF, $F7, $FF, $F6, $FF, $F6, $FF
	.byte	$F6, $FF, $F6, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F4, $FF, $F4, $FF
	.byte	$F4, $FF, $F4, $FF, $F4, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF
	.byte	$F3, $FF, $F3, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF
	.byte	$F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF
	.byte	$F1, $FF
	; CDL: read by sub_04D0EA; partly not accessed
	.byte	$F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF
	.byte	$F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F2, $FF, $F3, $FF, $F3, $FF
	.byte	$F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F3, $FF, $F4, $FF, $F4, $FF, $F4, $FF
	.byte	$F4, $FF, $F4, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F5, $FF, $F6, $FF, $F6, $FF
	.byte	$F6, $FF, $F6, $FF, $F7, $FF, $F7, $FF, $F7, $FF, $F8, $FF, $F8, $FF, $F8, $FF
	.byte	$F8, $FF, $F9, $FF, $F9, $FF, $F9, $FF, $FA, $FF, $FA, $FF, $FA, $FF, $FB, $FF
	.byte	$FB, $FF, $FB, $FF, $FC, $FF, $FC, $FF, $FC, $FF, $FD, $FF, $FD, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $00, $00, $00, $00, $00, $03
	.byte	$06, $08, $0B, $0D, $0E, $0F, $10, $0F, $0E, $0D, $0B, $08, $06, $03
	; CDL: DMA (started in nmi_frame_side_view)
palette_05912A:
	.byte	$CE, $39, $EF, $3D, $10, $42, $52, $4A, $94, $52, $D6, $5A, $F7, $5E, $18, $63
	.byte	$39, $67, $5A, $6B, $7B, $6F, $9C, $73, $BD, $77, $DE, $7B, $FF, $7F, $FF, $7F
palette_05914A:
	.byte	$00, $00, $FF, $7F, $FF, $7F, $FF, $7F, $6D, $31, $F1, $3D, $D6, $5A, $09, $21
	.byte	$FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F, $FF, $7F, $00, $00
palette_05916A:
	.byte	$00, $00, $94, $62, $D6, $6A, $39, $77, $9C, $7F, $FE, $7F, $FE, $7F, $FF, $7F
	.byte	$FF, $7F, $00, $00, $1E, $6F, $9F, $7B, $FF, $7F, $FF, $7F, $5B, $29, $FF, $3D
palette_05918A:
	.byte	$00, $00, $42, $08, $C6, $18, $29, $25, $8C, $31, $31, $46, $B5, $56, $18, $63
	.byte	$9C, $73, $FF, $7F, $06, $00, $6A, $18, $8C, $2C, $12, $31, $B5, $39, $5A, $5A
data_0591AA:
	; CDL: read by stage1_boss_move_up
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
data_05921A:
	; CDL: read by stage1_boss_move_up
	.byte	$D8, $FF, $26, $FC, $8F, $F3, $28, $E6, $13, $D4, $7C, $BD, $9A, $A2, $B0, $83
	.byte	$0B, $61, $FF, $3A, $EB, $11, $33, $E6, $44, $B8, $8E, $88, $88, $57, $AA, $25
	.byte	$00, $13, $00, $13, $00, $15, $00, $18, $00, $1C, $00, $21, $00, $27, $00, $2E
	.byte	$00, $36, $00, $4F, $00, $5F, $00, $77, $28, $00, $DA, $03, $71, $0C, $D8, $19
	.byte	$ED, $2B, $84, $42, $66, $5D, $50, $7C, $F5, $9E, $01, $C5, $15, $EE, $CD, $19
	.byte	$BC, $47, $72, $77, $78, $A8, $56, $DA, $00, $ED, $00, $ED, $00, $EB, $00, $E8
	.byte	$00, $E4, $00, $DF, $00, $D9, $00, $D2, $00, $CA, $00, $B1, $00, $A1, $00, $89
enemy_bullet_speeds_normal:
	.byte	$FE, $FF
	; CDL: read by spawn_enemy_bullet
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $00, $00
	.byte	$00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	.byte	$FF, $FF, $FF, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $00, $00
	.byte	$D7, $09, $FA, $26, $4A, $56, $F7, $95, $8D, $E3, $11, $3C, $1E, $9C, $00, $00
	.byte	$E2, $63, $EF, $C3, $73, $1C, $09, $6A, $B6, $A9, $06, $D9, $29, $F6, $00, $00
	.byte	$29, $F6, $06, $D9, $B6, $A9, $09, $6A, $73, $1C, $EF, $C3, $E2, $63, $00, $00
	.byte	$1E, $9C, $11, $3C, $8D, $E3, $F7, $95, $4A, $56, $FA, $26, $D7, $09, $00, $00
	.byte	$D7, $09, $FA, $26, $4A, $56, $F7, $95, $8D, $E3, $11, $3C, $1E, $9C
	; CDL: not accessed
	.byte	$FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF
	.byte	$00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $01, $00, $01, $00, $00, $00
	.byte	$00, $00, $FF, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FD, $FF, $FD, $FF, $FD, $FF
	.byte	$FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF
	.byte	$34, $33, $FA, $40, $C4, $69, $01, $AC, $26, $05, $C5, $71, $B2, $ED, $29, $74
	.byte	$00, $00, $D7, $8B, $4E, $12, $3B, $8E, $DA, $FA, $FF, $53, $3C, $96, $06, $BF
	.byte	$CC, $CC, $06, $BF, $3C, $96, $FF, $53, $DA, $FA, $3B, $8E, $4E, $12, $D7, $8B
	.byte	$00, $00, $29, $74, $B2, $ED, $C5, $71, $26, $05, $01, $AC, $C4, $69, $FA, $40
	.byte	$34, $33, $FA, $40, $C4, $69, $01, $AC, $26, $05, $C5, $71, $B2, $ED, $29, $74
enemy_bullet_speeds_hard:
	; CDL: read by make_debris_effect
	.byte	$FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FE, $FF, $FF, $FF
data_0593DA:
	; CDL: read by make_debris_effect
	.byte	$00, $00, $00, $00, $01, $00, $01, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$03, $00, $02, $00, $02, $00, $02, $00, $02, $00, $01, $00, $01, $00, $00, $00
	.byte	$00, $00, $FF, $FF, $FE, $FF, $FE, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF
	.byte	$FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FE, $FF, $FF, $FF
data_05941A:
	; CDL: read by make_debris_effect
	.byte	$00, $00, $C2, $0E, $76, $3A, $6F, $81, $F2, $E0, $53, $55, $1A, $DA, $2C, $6A
data_05942A:
	; CDL: read by queue_vram_blocks_at_x, make_debris_effect
	.byte	$00, $00, $D4, $95, $E6, $25, $AD, $AA, $0E, $1F, $91, $7E, $8A, $C5, $3E, $F1
	.byte	$00, $00, $3E, $F1, $8A, $C5, $91, $7E, $0E, $1F, $AD, $AA, $E6, $25, $D4, $95
	.byte	$00, $00, $2C, $6A, $1A, $DA, $53, $55, $F2, $E0, $6F, $81, $76, $3A, $C2, $0E
	.byte	$00, $00, $C2, $0E, $76, $3A, $6F, $81, $F2, $E0, $53, $55, $1A, $DA, $2C, $6A
vram_blocks_05946A:
	.byte	$00, $50, $00, $50, $00, $50, $00, $50, $00, $50, $00, $50, $00, $50, $00, $50
ptrs_stage_spawn_pages:
	; CDL: read by init_stage_spawns, spawn_next_stage_object, find_free_object_slot_in_range; partly not accessed
	.addr	spawn_pages_059488, spawn_pages_059488, spawn_pages_059488, spawn_pages_0597E6, spawn_pages_059488, spawn_pages_059488, spawn_pages_059C2E
spawn_pages_059488:
	.addr	spawn_list_0594C0, spawn_list_0594F4, spawn_list_05951E, spawn_list_059534
	.addr	spawn_list_05955E, spawn_list_05957E, spawn_list_059594, spawn_list_0595AA
	.addr	spawn_list_0595CA, spawn_list_0595E0, spawn_list_0595F6, spawn_list_059616
	.addr	spawn_list_059640, spawn_list_05966A, spawn_list_05968A, spawn_list_0596A0
	.addr	spawn_list_0596CA, spawn_list_0596E0, spawn_list_05970A, spawn_list_05972A
	.addr	spawn_list_059736, spawn_list_05974C, spawn_list_059776, spawn_list_059778
	.addr	spawn_list_05978E, spawn_list_059790, spawn_list_05979C, spawn_list_0597DA
spawn_list_0594C0:
	.byte	$10, $0F, $78, $30, $F0, $FF, $30, $00, $06, $00
	.byte	$20, $11, $30, $28, $10, $01, $D0, $00, $00, $00, $70, $12, $78, $30, $00, $01
	.byte	$C8, $00, $00, $00, $80, $0F, $78, $30, $10, $01, $60, $00, $07, $00, $A0, $0B
	.byte	$84, $78, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_0594F4:
	.byte	$68, $0F, $78, $30, $F0, $FF
	.byte	$30, $00, $01, $00, $78, $0F, $78, $30, $10, $01, $60, $00, $01, $00, $80, $07
	.byte	$AC, $9C, $00, $00, $00, $00, $04, $00, $E0, $0D, $84, $78, $00, $01, $C8, $00
	.byte	$00, $00, $FF, $00
spawn_list_05951E:
	.byte	$50, $17, $94, $90, $00, $01, $48, $00, $00, $00, $E0, $0D
	.byte	$84, $78, $00, $01, $C8, $00, $02, $00, $FF, $00
spawn_list_059534:
	.byte	$30, $0F, $78, $30, $10, $01
	.byte	$40, $00, $03, $00, $48, $1E, $30, $28, $00, $01, $BE, $00, $00, $00, $80, $0F
	.byte	$78, $30, $F0, $FF, $60, $00, $05, $00, $C0, $35, $78, $30, $00, $01, $98, $00
	.byte	$08, $00, $FF, $00
spawn_list_05955E:
	.byte	$00, $35, $78, $30, $00, $01, $98, $00, $0A, $00, $48, $1E
	.byte	$30, $28, $00, $01, $BE, $00, $00, $00, $D0, $34, $84, $78, $00, $01, $60, $00
	.byte	$00, $00, $FF, $00
spawn_list_05957E:
	.byte	$1C, $17, $94, $90, $F4, $00, $68, $00, $00, $00, $C8, $1E
	.byte	$30, $28, $00, $01, $BE, $00, $00, $00, $FF, $00
spawn_list_059594:
	.byte	$48, $12, $78, $30, $00, $01
	.byte	$68, $00, $00, $00, $58, $17, $74, $30, $00, $01, $C8, $00, $00, $00, $FF, $00
spawn_list_0595AA:
	.byte	$80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $B0, $04, $94, $90, $00, $01
	.byte	$C0, $00, $00, $00, $C4, $17, $74, $30, $00, $01, $5C, $00, $00, $00, $FF, $00
spawn_list_0595CA:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00, $80, $09, $A0, $9C, $00, $01
	.byte	$C8, $00, $00, $00, $FF, $00
spawn_list_0595E0:
	.byte	$60, $35, $78, $30, $00, $01, $98, $00, $0C, $00
	.byte	$C0, $35, $78, $30, $00, $01, $98, $00, $0E, $00, $FF, $00
spawn_list_0595F6:
	.byte	$00, $0D, $84, $78
	.byte	$00, $01, $C8, $00, $04, $00, $40, $17, $74, $30, $00, $01, $68, $00, $00, $00
	.byte	$88, $12, $78, $30, $00, $01, $48, $00, $00, $00, $FF, $00
spawn_list_059616:
	.byte	$28, $12, $78, $30
	.byte	$00, $01, $68, $00, $00, $00, $80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00
	.byte	$B0, $04, $94, $90, $00, $01, $C0, $00, $00, $00, $C4, $17, $74, $30, $00, $01
	.byte	$5C, $00, $00, $00, $FF, $00
spawn_list_059640:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00
	.byte	$30, $0F, $78, $30, $F0, $FF, $60, $00, $02, $00, $40, $0D, $80, $78, $00, $01
	.byte	$C8, $00, $06, $00, $80, $36, $AC, $9C, $00, $00, $00, $00, $0B, $00, $FF, $00
spawn_list_05966A:
	.byte	$10, $0F, $78, $30, $F0, $FF, $30, $00, $07, $00, $48, $0F, $78, $30, $10, $01
	.byte	$60, $00, $07, $00, $80, $0F, $78, $30, $F0, $FF, $30, $00, $06, $00, $FF, $00
spawn_list_05968A:
	.byte	$42, $2C, $8C, $78, $00, $01, $00, $00, $80, $00, $A4, $2C, $8C, $78, $00, $01
	.byte	$00, $00, $50, $00, $FF, $00
spawn_list_0596A0:
	.byte	$80, $07, $AC, $9C, $00, $00, $00, $00, $02, $00
	.byte	$84, $2C, $8C, $78, $00, $01, $00, $00, $A0, $00, $C4, $2C, $8C, $78, $00, $01
	.byte	$00, $00, $50, $00, $F0, $03, $AC, $9C, $00, $00, $00, $00, $00, $02, $FF, $00
spawn_list_0596CA:
	.byte	$80, $02, $94, $90, $00, $00, $00, $00, $00, $00, $C0, $0F, $78, $30, $F0, $FF
	.byte	$60, $00, $05, $00, $FF, $00
spawn_list_0596E0:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00
	.byte	$20, $03, $AC, $9C, $00, $00, $00, $00, $00, $01, $80, $07, $AC, $9C, $00, $00
	.byte	$00, $00, $06, $00, $90, $0F, $78, $30, $10, $01, $60, $00, $03, $00, $FF, $00
spawn_list_05970A:
	.byte	$02, $07, $AC, $9C, $00, $00, $00, $00, $16, $00, $1C, $0F, $78, $30, $10, $01
	.byte	$70, $00, $02, $00, $80, $06, $AC, $9C, $00, $01, $00, $00, $00, $00, $FF, $00
spawn_list_05972A:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_059736:
	.byte	$08, $33, $30, $28
	.byte	$10, $01, $B8, $00, $00, $00, $98, $31, $90, $30, $10, $01, $B8, $00, $88, $F9
	.byte	$FF, $00
spawn_list_05974C:
	.byte	$08, $2B, $30, $28, $00, $01, $C8, $00, $02, $00, $3C, $31, $90, $30
	.byte	$10, $01, $B8, $00, $20, $FA, $6C, $31, $90, $30, $10, $01, $B8, $00, $10, $F9
	.byte	$E8, $2B, $30, $28, $00, $01, $C8, $00, $02, $00, $FF, $00
spawn_list_059776:
	.byte	$FF, $00
spawn_list_059778:
	.byte	$20, $0F
	.byte	$30, $28, $10, $01, $30, $00, $01, $00, $B4, $2F, $30, $28, $00, $01, $BC, $00
	.byte	$00, $00, $FF, $00
spawn_list_05978E:
	.byte	$FF, $00
spawn_list_059790:
	.byte	$18, $2A, $AC, $9C, $00, $00, $00, $00, $00, $00
	.byte	$FF, $00
spawn_list_05979C:
	.byte	$00, $07, $AC, $9C, $00, $00, $00, $00, $00, $00, $20, $0F, $30, $28
	.byte	$10, $01, $30, $00, $07, $00, $38, $0F, $30, $28, $10, $01, $60, $00, $07, $00
	.byte	$70, $03, $AC, $9C, $00, $00, $00, $00, $00, $05, $80, $05, $AC, $9C, $00, $00
	.byte	$00, $00, $00, $00, $F0, $01, $94, $90, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_0597DA:
	.byte	$00, $08, $AC, $9C, $00
	; CDL: read by spawn_next_stage_object, find_free_object_slot_in_range; partly not accessed
	.byte	$00, $00, $00, $00, $00, $FF, $00
spawn_pages_0597E6:
	.addr	spawn_list_05981A, spawn_list_059844, spawn_list_05986E, spawn_list_059898
	.addr	spawn_list_0598C2, spawn_list_0598E2, spawn_list_059BC6, spawn_list_0598EE
	.addr	spawn_list_059904, spawn_list_059BC6, spawn_list_05994C, spawn_list_059958
	.addr	spawn_list_059978, spawn_list_05998E, spawn_list_0599A4, spawn_list_0599C4
	.addr	spawn_list_0599EE, spawn_list_059A5E, spawn_list_059A88, spawn_list_059AB2
	.addr	spawn_list_059ADC, spawn_list_059B10, spawn_list_059B44, spawn_list_059B50
	.addr	spawn_list_059B7A
	.byte	$DA, $97
spawn_list_05981A:
	.byte	$40, $0F, $78, $30, $10
	.byte	$01, $60, $00, $04, $00, $98, $0F, $78, $30, $F0, $FF, $40, $00, $07, $00, $A0
	.byte	$4A, $78, $30, $F0, $FF, $B0, $00, $00, $00, $DC, $17, $78, $30, $00, $01, $50
	.byte	$00, $00, $00, $FF, $00
spawn_list_059844:
	.byte	$20, $4A, $78, $30, $F0, $FF, $00, $00, $00, $00, $70
	.byte	$4A, $78, $30, $00, $01, $90, $00, $02, $00, $A0, $4A, $78, $30, $00, $01, $90
	.byte	$00, $02, $00, $C8, $4A, $78, $30, $00, $01, $90, $00, $02, $00, $FF, $00
spawn_list_05986E:
	.byte	$08
	.byte	$4A, $78, $30, $00, $01, $90, $00, $02, $00, $48, $4A, $78, $30, $00, $01, $90
	.byte	$00, $02, $00, $68, $17, $78, $30, $00, $01, $40, $00, $00, $00, $E8, $4A, $78
	.byte	$30, $F0, $FF, $00, $00, $00, $00, $FF, $00
spawn_list_059898:
	.byte	$28, $0F, $78, $30, $10, $01, $50
	.byte	$00, $05, $00, $80, $4A, $78, $30, $00, $01, $90, $00, $02, $00, $C0, $4A, $78
	.byte	$30, $00, $01, $B0, $00, $02, $00, $E8, $4A, $78, $30, $F0, $FF, $60, $00, $00
	.byte	$00, $FF, $00
spawn_list_0598C2:
	.byte	$00, $39, $30, $28, $1E, $01, $50, $00, $00, $00, $50, $17, $78
	.byte	$30, $00, $01, $B0, $00, $00, $00, $C0, $4A, $78, $30, $F0, $FF, $B0, $00, $00
	.byte	$00, $FF, $00
spawn_list_0598E2:
	.byte	$20, $4F, $80, $30, $80, $00, $00, $00, $40, $60, $FF, $00
spawn_list_0598EE:
	.byte	$80
	.byte	$3D, $30, $28, $80, $01, $80, $00, $00, $00, $FE, $08, $AC, $9C, $00, $00, $00
	.byte	$00, $00, $00, $FF, $00
spawn_list_059904:
	.byte	$04, $47, $78, $30, $20, $00, $00, $01, $02, $00, $0C
	.byte	$47, $78, $30, $40, $00, $00, $01, $02, $00, $14, $47, $78, $30, $60, $00, $00
	.byte	$01, $02, $00, $1C, $47, $78, $30, $80, $00, $00, $01, $02, $00, $24, $47, $78
	.byte	$30, $A0, $00, $00, $01, $02, $00, $30, $0F, $8C, $80, $FF, $FF, $50, $00, $02
	.byte	$00, $48, $0F, $8C, $80, $10, $01, $50, $00, $01, $00, $FF, $00
spawn_list_05994C:
	.byte	$FE, $08, $AC
	.byte	$9C, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_059958:
	.byte	$60, $17, $78, $30, $10, $00, $FF
	.byte	$FF, $00, $00, $A0, $17, $78, $30, $14, $00, $FF, $FF, $00, $00, $E0, $17, $78
	.byte	$30, $10, $00, $FF, $FF, $00, $00, $FF, $00
spawn_list_059978:
	.byte	$80, $05, $AC, $9C, $00, $00, $00
	.byte	$00, $00, $00, $81, $42, $AC, $9C, $00, $00, $00, $00, $01, $00, $FF, $00
spawn_list_05998E:
	.byte	$00
	.byte	$3B, $AC, $9C, $00, $00, $00, $00, $00, $05, $30, $0F, $78, $30, $00, $01, $30
	.byte	$00, $05, $00, $FF, $00
spawn_list_0599A4:
	.byte	$10, $89, $78, $30, $00, $00, $00, $00, $00, $00, $40
	.byte	$03, $AC, $9C, $00, $00, $00, $00, $00, $01, $42, $4E, $94, $90, $80, $00, $80
	.byte	$01, $00, $01, $FF, $00
spawn_list_0599C4:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00, $02
	.byte	$0F, $78, $30, $10, $01, $30, $00, $06, $00, $50, $17, $78, $30, $00, $01, $80
	.byte	$00, $00, $00, $98, $17, $78, $30, $00, $01, $40, $00, $00, $00, $FF, $00
spawn_list_0599EE:
	.byte	$01
	.byte	$47, $78, $30, $00, $01, $48, $00, $00, $00, $11, $47, $78, $30, $00, $01, $68
	.byte	$00, $00, $00, $21, $47, $78, $30, $00, $01, $88, $00, $00, $00, $31, $47, $78
	.byte	$30, $00, $01, $A8, $00, $00, $00, $80, $05, $AC, $9C, $00, $00, $00, $00, $00
	.byte	$00, $84, $47, $78, $30, $00, $01, $A8, $00, $00, $00, $8C, $47, $78, $30, $00
	.byte	$01, $A8, $00, $00, $00, $94, $47, $78, $30, $00, $01, $A8, $00, $00, $00, $A0
	.byte	$17, $78, $30, $00, $01, $B0, $00, $00, $00, $BC, $17, $78, $30, $00, $01, $B0
	.byte	$00, $00, $00, $C0, $43, $94, $90, $1E, $01, $C0, $00, $00, $00, $FF, $00
spawn_list_059A5E:
	.byte	$00
	.byte	$08, $AC, $9C, $00, $00, $00, $00, $00, $00, $40, $50, $8C, $30, $00, $01, $60
	.byte	$00, $08, $45, $50, $0F, $78, $30, $FF, $FF, $30, $00, $02, $00, $A0, $50, $8C
	.byte	$30, $00, $01, $60, $00, $14, $45, $FF, $00
spawn_list_059A88:
	.byte	$47, $39, $30, $28, $1E, $01, $58
	.byte	$00, $02, $00, $80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $BD, $50, $8C
	.byte	$30, $00, $01, $60, $00, $18, $45, $FE, $3B, $AC, $9C, $00, $00, $00, $00, $02
	.byte	$00, $FF, $00
spawn_list_059AB2:
	.byte	$01, $42, $AC, $9C, $00, $00, $00, $00, $00, $04, $4C, $49, $78
	.byte	$30, $20, $00, $10, $00, $00, $00, $60, $50, $8C, $30, $C0, $00, $00, $00, $18
	.byte	$42, $CC, $49, $78, $30, $E0, $00, $10, $00, $00, $00, $FF, $00
spawn_list_059ADC:
	.byte	$00, $50, $8C
	.byte	$30, $C0, $00, $00, $00, $98, $43, $40, $50, $8C, $30, $C0, $00, $00, $00, $98
	.byte	$42, $80, $50, $8C, $30, $C0, $00, $00, $00, $98, $41, $90, $0F, $78, $30, $FF
	.byte	$FF, $30, $00, $01, $00, $C0, $50, $8C, $30, $C0, $00, $00, $00, $98, $40, $FF
	.byte	$00
spawn_list_059B10:
	.byte	$4B, $39, $30, $28, $A8, $00, $E2, $FF, $04, $00, $6B, $39, $30, $28, $08
	.byte	$01, $E2, $FF, $06, $00, $80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $C0
	.byte	$50, $8C, $30, $20, $00, $00, $00, $84, $40, $C1, $50, $8C, $30, $A0, $00, $01
	.byte	$00, $94, $40, $FF, $00
spawn_list_059B44:
	.byte	$00, $3B, $AC, $9C, $00, $00, $00, $00, $00, $00, $FF
	.byte	$00
spawn_list_059B50:
	.byte	$02, $42, $78, $30, $00, $00, $00, $00, $01, $04, $34, $07, $AC, $9C, $00
	.byte	$00, $00, $00, $0A, $00, $48, $42, $AC, $9C, $00, $00, $00, $00, $01, $03, $81
	.byte	$0F, $78, $30, $10, $01, $A0, $00, $03, $00, $FF, $00
spawn_list_059B7A:
	.byte	$20, $03, $AC, $9C, $00
	.byte	$00, $00, $00, $00, $02, $6E, $41, $94, $90, $1E, $01, $AC, $00, $00, $00, $78
	.byte	$45, $90, $8C, $1E, $01, $AC, $00, $02, $00, $80, $05, $AC, $9C, $00, $00, $00
	.byte	$00, $00, $00, $82, $44, $70, $30, $1E, $01, $20, $00, $00, $00, $FF, $00, $80
	.byte	$05, $AC, $9C, $00, $00, $00, $00, $00, $00, $FF, $00, $00, $08, $AC, $9C, $00
	.byte	$00, $00, $00, $00, $00, $FF, $00
spawn_list_059BC6:
	.byte	$FF, $00
data_059BC8:
	; CDL: read by scroll_bg1_by_velocity_and_spawn
	.byte	$27, $09
data_059BCA:
	; CDL: read by scroll_bg1_by_velocity_and_spawn
	.byte	$7A, $68
data_059BCC:
	; CDL: read by scroll_bg1_by_velocity_and_spawn; partly not accessed
	.byte	$00, $00, $E7, $08, $7A, $68, $02, $00, $C0, $08, $0F, $60, $03, $00, $68, $08
	.byte	$0F, $60, $04, $00, $5F, $08, $7C, $50, $04, $00, $1F, $08, $7C, $50, $00, $00
	.byte	$DF, $07, $7C, $50, $02, $00, $7F, $07, $7D, $68, $00, $00, $10, $06, $7E, $48
	.byte	$00, $00, $F0, $05, $07, $00, $14, $00, $A7, $05, $7A, $68, $04, $00, $67, $05
	.byte	$7A, $68, $06, $00, $27, $05, $7A, $68, $08, $00, $E7, $04, $7A, $68, $0A, $00
	.byte	$40, $04, $0F, $60, $05, $00, $E0, $03, $7F, $60, $00, $00, $00, $00, $7A, $60
	.byte	$00, $00
	; CDL: read by spawn_next_stage_object, find_free_object_slot_in_range; partly not accessed
spawn_pages_059C2E:
	.addr	spawn_list_059C54, spawn_list_059C56, spawn_list_059C6C, spawn_list_059C8C
	.addr	spawn_list_059CAC, spawn_list_059CD6, spawn_list_059D00, spawn_list_059D20
	.addr	spawn_list_059D22, spawn_list_059D4C, spawn_list_059D6C, spawn_list_059D82
	.addr	spawn_list_059DA2, spawn_list_059DD6, spawn_list_059DEC, spawn_list_059E20
	.addr	spawn_list_059E36, spawn_list_059E40, spawn_list_059E40
spawn_list_059C54:
	.byte	$FF, $00
spawn_list_059C56:
	.byte	$80, $0F, $30, $28, $10, $01, $60, $00
	.byte	$07, $00, $A0, $5C, $84, $78, $F8, $00, $80, $00, $00, $00, $FF, $00
spawn_list_059C6C:
	.byte	$60, $0F
	.byte	$30, $28, $10, $01, $60, $00, $01, $00, $80, $5B, $94, $90, $80, $00, $80, $01
	.byte	$00, $01, $80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_059C8C:
	.byte	$00, $08
	.byte	$AC, $9C, $00, $00, $00, $00, $00, $00, $80, $0F, $30, $28, $10, $01, $60, $00
	.byte	$02, $00, $C8, $61, $84, $78, $F8, $00, $E0, $00, $00, $00, $FF, $00
spawn_list_059CAC:
	.byte	$10, $5C
	.byte	$84, $78, $F8, $00, $80, $00, $00, $00, $28, $61, $64, $58, $F8, $00, $40, $00
	.byte	$00, $00, $80, $0F, $30, $28, $10, $01, $60, $00, $03, $00, $C8, $61, $84, $78
	.byte	$F8, $00, $C0, $00, $00, $00, $FF, $00
spawn_list_059CD6:
	.byte	$10, $5C, $84, $78, $F8, $00, $80, $00
	.byte	$00, $00, $48, $61, $74, $68, $F8, $00, $E0, $00, $00, $00, $80, $0F, $30, $28
	.byte	$10, $01, $60, $00, $04, $00, $C8, $61, $84, $78, $F8, $00, $40, $00, $00, $00
	.byte	$FF, $00
spawn_list_059D00:
	.byte	$10, $5C, $84, $78, $F8, $00, $80, $00, $00, $00, $28, $61, $64, $58
	.byte	$F8, $00, $A0, $00, $00, $00, $80, $0F, $30, $28, $10, $01, $60, $00, $05, $00
	.byte	$FF, $00
spawn_list_059D20:
	.byte	$FF, $00
spawn_list_059D22:
	.byte	$00, $03, $AC, $9C, $00, $00, $00, $00, $00, $00, $50, $0F
	.byte	$30, $28, $10, $01, $50, $00, $01, $00, $80, $58, $94, $90, $80, $00, $80, $01
	.byte	$00, $01, $80, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_059D4C:
	.byte	$00, $08
	.byte	$AC, $9C, $00, $00, $00, $00, $00, $00, $80, $0F, $30, $28, $10, $01, $60, $00
	.byte	$07, $00, $C0, $0F, $30, $28, $10, $01, $50, $00, $05, $00, $FF, $00
spawn_list_059D6C:
	.byte	$20, $03
	.byte	$AC, $9C, $00, $00, $00, $00, $00, $01, $80, $5D, $94, $90, $80, $00, $80, $01
	.byte	$00, $01, $FF, $00
spawn_list_059D82:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00, $80, $0F
	.byte	$30, $28, $10, $01, $50, $00, $02, $00, $FE, $3B, $AC, $9C, $00, $00, $00, $00
	.byte	$02, $00, $FF, $00
spawn_list_059DA2:
	.byte	$01, $42, $AC, $9C, $00, $02, $00, $00, $01, $02, $20, $03
	.byte	$78, $30, $00, $00, $00, $00, $00, $02, $78, $5E, $94, $90, $80, $00, $80, $01
	.byte	$00, $01, $C0, $05, $AC, $9C, $00, $00, $00, $00, $00, $00, $FE, $08, $AC, $9C
	.byte	$00, $00, $00, $00, $00, $00, $FF, $00
spawn_list_059DD6:
	.byte	$80, $05, $AC, $9C, $00, $00, $00, $00
	.byte	$00, $00, $81, $42, $AC, $9C, $00, $00, $00, $00, $01, $00, $FF, $00
spawn_list_059DEC:
	.byte	$00, $3B
	.byte	$AC, $9C, $00, $00, $00, $00, $00, $00, $10, $0F, $30, $28, $FF, $FF, $50, $00
	.byte	$04, $00, $20, $03, $AC, $9C, $00, $00, $00, $00, $00, $03, $80, $5F, $94, $90
	.byte	$80, $00, $80, $01, $00, $01, $D8, $05, $AC, $9C, $00, $00, $00, $00, $00, $00
	.byte	$FF, $00
spawn_list_059E20:
	.byte	$00, $08, $AC, $9C, $00, $00, $00, $00, $00, $00, $01, $42, $AC, $9C
	.byte	$00, $02, $00, $00, $01, $02, $FF, $00
spawn_list_059E36:
	.byte	$10, $07, $AC, $9C, $00, $00, $00, $00
	.byte	$10, $00
spawn_list_059E40:
	.byte	$FF, $00
data_059E42:
	; CDL: read by update_object_type_55
	.byte	$00, $A0, $00, $A4, $00, $A8, $00, $A4
data_059E4A:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk (+1 more); partly not accessed
	.addr	load_list_059E79, load_list_059E8C, load_list_059E62, load_list_059E70
	.addr	load_list_059E95, load_list_059E9E, load_list_059EB1, load_list_059EC9
	.addr	load_list_059EDC, load_list_059EEA, load_list_059EF3, load_list_059EFC
load_list_059E62:
	load_list	$00, $01
	load_vram	$7800, gfx_0DD6D3
	load_vram	$7C00, gfx_0DDC20
	load_end
load_list_059E70:
	load_list	$00, $01
	load_vram	$7000, gfx_0EDD88
	load_end
load_list_059E79:
	load_list	$00, $01
	load_vram	$0000, gfx_0A8000
	load_vram	$1000, gfx_09EBBA
	load_vram	$7000, gfx_0DE218
	load_end
load_list_059E8C:
	load_list	$00, $01
	load_vram	$0800, gfx_0AA37C
	load_end
load_list_059E95:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7200, gfx_11C386
	load_end
load_list_059E9E:
	load_list	$00, $01
	load_vram	$7000, gfx_0EC024
	load_vram	$0000, gfx_0CDB2D
	load_vram	$1000, gfx_0CF4BD
	load_end
load_list_059EB1:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7200, gfx_0E8C89
	load_vram	$7400, gfx_0DC2FE
	load_vram	$7800, gfx_0DD6D3
	load_vram	$7C00, gfx_0E8F5B
	load_end
load_list_059EC9:
	; CDL: read by load_data_list, step_vram_loader, init_loader_context (+1 more); partly not accessed
	load_list	$00, $01
	load_vram	$0000, gfx_118000
	load_vram	$1000, gfx_119D0E
	load_vram	$2000, gfx_10B927
	load_end
load_list_059EDC:
	load_list	$00, $01
	load_vram	$0000, gfx_0F8000
	load_vram	$2000, gfx_08A538
	load_end
load_list_059EEA:
	load_list	$00, $01
	load_vram	$3000, gfx_15DCD9
	load_end
load_list_059EF3:
	load_list	$00, $01
	load_vram	$7800, gfx_0E9F5E
	load_end
load_list_059EFC:
	load_list	$01, $01
	load_wram	$7EA000, packed_09E638
	load_end
data_059F06:
	; CDL: not accessed
	.byte	$04, $00
data_059F08:
	; CDL: read by object_type_06_state_04; partly not accessed
	.byte	$8A, $F4, $70, $00
data_059F0C:
	; CDL: read by object_type_06_state_04, update_bomber_bomb, update_objects; partly not accessed
	.byte	$88, $00, $FF, $FF, $00, $00
; The bomber's bomb (update_bomber_bomb) keeps in the third word the script
; of the fire effects it trails, not a metasprite.
anim_059F12:
	anim_frame	$0010, metasprite_06B5BB, anim_05C5B8
	anim_frame	$0010, metasprite_06B5C0, anim_05C5B8
	anim_frame	$6000, metasprite_06B5C5, anim_05C516
	anim_end	metasprite_06B5C5, anim_05C516
data_059F2A:
	; CDL: read by object_type_06_state_08; partly not accessed
	.byte	$80, $08, $80, $08, $10, $01, $10, $01, $40, $04, $40, $04, $20, $02, $20, $02
	.byte	$20, $02, $20, $02, $40, $04, $40, $04, $10, $01, $10, $01, $80, $08, $80, $08
	.byte	$40, $04, $40, $04, $80, $08, $80, $08, $20, $02, $20, $02, $10, $01, $10, $01
	.byte	$10, $01, $10, $01, $20, $02, $20, $02, $80, $08, $80, $08, $40, $04, $40, $04
data_059F6A:
	; CDL: read by object_type_06_state_08; partly not accessed
	.byte	$00, $00, $08, $08, $04, $04, $0C, $0C, $02, $02, $0A, $0A, $06, $06, $0E, $0E
	.byte	$00, $00, $08, $08, $04, $04, $0C, $0C, $02, $02, $0A, $0A, $06, $06, $0E, $0E
	.byte	$00, $00, $08, $08, $04, $04, $0C, $0C, $02, $02, $0A, $0A, $06, $06, $0E, $0E
	.byte	$00, $00, $08, $08, $04, $04, $0C, $0C, $02, $02, $0A, $0A, $06, $06, $0E, $0E
data_059FAA:
	; CDL: read by object_type_06_state_07
	.byte	$00, $A0, $80, $A3, $00, $A7, $80, $AA
data_059FB2:
	; CDL: read by update_object_type_3C
	.byte	$00, $A0, $00, $A3, $00, $A6, $00, $A9
load_list_059FBA:
	; CDL: read by load_data_list, init_loader_context, decompress_chunk (+1 more); DMA / HDMA; partly not accessed
	load_list	$01, $01
	load_wram	$7EA000, packed_0A9BC6
	load_end
hdma_table_059FC4:
	.byte	$7F, $20, $21, $20, $80, $02
	.byte	$00
hdma_table_059FCB:
	.byte	$7F, $49, $20, $49, $80, $48, $00
hdma_list_059FD2:
	hdma_channel_ind	$4370, $00, $05, $7E3840, $7E
	hdma_channel_ind	$4360, $02, $0D, $7E3800, $7E
	hdma_channel_ind	$4350, $02, $0E, $7E3820, $7E
	hdma_channels_end	$E0
hdma_list_059FED:
	hdma_channel_ind	$4370, $00, $30, hdma_table_059FC4, $05
	hdma_channel_ind	$4360, $00, $08, hdma_table_059FCB, $05
	hdma_channel_ind	$4350, $02, $0F, $7E3820, $7E
	hdma_channels_end	$E0
weapon_fire_delays:
	; CDL: read by spin_fire_weapon_2, fire_weapon
.if CHEAT_FIRE_DELAY
	.repeat	6
	.word	CHEAT_FIRE_DELAY
	.endrepeat
.else
	.byte	$03, $00, $04, $00, $05, $00, $04, $00, $01, $00, $01, $00
.endif
data_05A014:
	; CDL: read by spawn_shot_crush
	.byte	$2E, $31, $40, $31, $2C, $31, $40, $B1, $2E, $B1, $40, $F1, $2C, $71, $40, $71
data_05A024:
	; CDL: read by spawn_shots_flame; partly not accessed
	.byte	$00, $00, $F2, $FF, $F0, $FF, $F2, $FF, $00, $00, $0E, $00, $10, $00, $0E, $00
data_05A034:
	; CDL: read by spawn_shots_flame; partly not accessed
	.byte	$10, $00, $0E, $00, $00, $00, $F2, $FF, $F2, $FF, $F2, $FF, $00, $00, $0E, $00
data_05A044:
	; CDL: read by spawn_shot_laser; partly not accessed
	.byte	$00, $00, $F4, $FF, $F0, $FF, $F4, $FF, $00, $00, $0C, $00, $10, $00, $0C, $00
data_05A054:
	; CDL: read by spawn_shot_laser; partly not accessed
	.byte	$10, $00, $0C, $00, $00, $00, $F4, $FF, $F0, $FF, $F4, $FF, $00, $00, $0C, $00
data_05A064:
	; CDL: read by spawn_shot_laser; partly not accessed
	.byte	$44, $31, $46, $31, $42, $31, $46, $71, $44, $31, $46, $31, $42, $31, $46, $71
data_05A074:
	; CDL: read by update_homing_shot
	.byte	$2E, $3F, $40, $3F, $2C, $3F, $40, $BF, $2E, $BF, $40, $FF, $2C, $7F, $40, $7F
data_05A084:
	; CDL: not accessed
	.byte	$84, $3F
data_05A086:
	; CDL: read by update_shot_type_0C
	.byte	$82, $3B, $86, $3F, $EC, $3B, $84, $3D
data_05A08E:
	; CDL: read by update_crush_shot, update_crush_blast
	.byte	$C0, $31, $AE, $31, $AC, $31, $86, $33, $84, $33, $86, $33, $84, $33, $00, $00
data_05A09E:
	; CDL: read by update_shot_type_10
	.byte	$8A, $3D, $8A, $3D, $8E, $31, $8E, $31, $86, $3F, $86, $3F, $84, $3F, $84, $3F
data_05A0AE:
	; CDL: read by update_spent_shot
	.byte	$8A, $3D, $8A, $3D, $8A, $3F
tbl_shot_types:
	.faraddr	$000000
	.faraddr	update_default_shot
	.faraddr	update_spread_shot
	.faraddr	update_crush_shot
	.faraddr	update_homing_shot
	.faraddr	update_shot_type_05
	.faraddr	update_shot_type_06
	.faraddr	update_shot_type_07
	.faraddr	update_shot_type_08
	.faraddr	update_shot_type_09
	.faraddr	update_laser_shot
	.faraddr	update_laser_shot
	.faraddr	update_shot_type_0C
	.faraddr	update_crush_blast
	.faraddr	update_shot_type_0E
	.faraddr	update_shot_type_0E
	.faraddr	update_shot_type_10
	.faraddr	update_shot_type_10
	.faraddr	update_shot_type_10
	.faraddr	update_shot_type_13
	.faraddr	update_shot_type_13
	.faraddr	update_spent_shot
	.faraddr	update_ending_firework
	.faraddr	update_spark_random
	.faraddr	update_spark_radial
	.faraddr	update_spark_radial_fast
	.faraddr	update_spark_random
	; CDL: read by draw_text
text_1p:
	.byte	$20, $5C, $00, $02, $0B, $00, $0D, $00, $00, $0E, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $FE, $40, $5C, $00, $0C, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $0C, $00, $FF
text_2p:
	.byte	$30, $5C, $00, $03, $0B, $00, $0D, $00, $00, $0E
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $FE, $50, $5C, $00, $0C, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $0C
data_05A14F:
	; CDL: read by draw_text, init_hud
	.byte	$00, $FF, $00, $20, $02, $20, $0B, $20, $00, $20, $0D, $20, $10, $2C, $11, $2C
	.byte	$0E, $20, $10, $28, $11, $28, $00, $00, $28, $30, $29, $30, $00, $20, $00, $20
data_05A16F:
	; CDL: read by init_hud
	.byte	$00, $20, $00, $20, $03, $24, $0B, $24, $00, $20, $0D, $24, $10, $2C, $11, $2C
	.byte	$0E, $24, $10, $28, $11, $28, $00, $24, $28, $30, $29, $30, $00, $20, $00, $20
data_05A18F:
	; CDL: read by init_hud
	.byte	$00, $20, $00, $20, $0C, $20, $01, $20, $01, $20, $00, $20, $12, $2C, $13, $2C
	.byte	$00, $20, $12, $28, $13, $28, $00, $20, $2A, $30, $2B, $30, $0C, $20, $01, $20
data_05A1AF:
	; CDL: read by init_hud
	.byte	$00, $20, $00, $20, $0C, $24, $01, $24, $01, $24, $00, $20, $12, $2C, $13, $2C
	.byte	$00, $20, $12, $28, $13, $28, $00, $20, $2A, $30, $2B, $30, $0C, $24, $01, $24
	.byte	$00, $20
hud_weapon_slot_attrs:
	; CDL: read by update_p1_hud; partly not accessed
	.byte	$2C, $00, $28, $00
hud_weapon_tiles_tl:
	; CDL: read by update_p1_hud, update_p2_hud
	.byte	$10, $14, $18, $20, $1C, $24
hud_weapon_tiles_tr:
	; CDL: read by update_p1_hud, update_p2_hud
	.byte	$11, $15, $19, $21, $1D, $25
hud_weapon_tiles_bl:
	; CDL: read by update_p1_hud, update_p2_hud
	.byte	$12, $16, $1A, $22, $1E, $26
hud_weapon_tiles_br:
	; CDL: read by update_p1_hud, update_p2_hud
	.byte	$13, $17, $1B, $23, $1F, $27
ptrs_stage_hdma_lists:
	; CDL: read by setup_stage_hdma; partly not accessed
	.addr	hdma_list_05A226, hdma_list_05A226, hdma_list_05AF61, hdma_list_059FED
	.addr	hdma_list_059FD2, hdma_list_05AA31, hdma_list_05A226, hdma_list_05A362
	.addr	hdma_list_05A213, hdma_list_05A231, hdma_list_05A23C, hdma_list_05A24F
	.addr	hdma_list_05A375, hdma_list_05A380, hdma_list_05A393, hdma_list_05FF4E
	.addr	hdma_list_05F8A0, hdma_list_05F9B0, hdma_list_05FD8B
hdma_list_05A213:
	hdma_channel_ind	$4370, $02, $0D, $7E3820, $7E
	hdma_channel_ind	$4360, $42, $0F, $7ED200, $7E
	hdma_channels_end	$C0
hdma_list_05A226:
	hdma_channel_ind	$4360, $42, $0F, $7ED200, $7E
	hdma_channels_end	$40
hdma_list_05A231:
	hdma_channel_ind	$4360, $42, $0F, $7ED200, $7E
	hdma_channels_end	$40
hdma_list_05A23C:
	hdma_channel_ind	$4360, $03, $0D, $7E3800, $7E
	hdma_channel_ind	$4370, $02, $11, $7E3820, $7E
	hdma_channels_end	$C0
hdma_list_05A24F:
	hdma_channel_ind	$4370, $02, $11, $7E3820, $7E
	hdma_channels_end	$80
; Split-screen scroll patterns (scroll_split_pattern 1-3, build_scroll_split_hdma):
; each a list of line tables (split_lines_*) chosen by the high byte of
; scroll_split_y; a line table is entries of {line, value...} read by
; build_split_line_table.
ptrs_scroll_split_patterns:
	; CDL: read by build_scroll_split_hdma, build_split_line_table; partly not accessed
	.addr	scroll_split_pattern_1
	.addr	scroll_split_pattern_2
	.addr	scroll_split_pattern_3
scroll_split_pattern_1:
	.addr	split_lines_05A270
	.addr	split_lines_05A278
	.addr	split_lines_05A2BC
scroll_split_pattern_2:
	.addr	split_lines_05A2DC
	.addr	split_lines_05A2EC
scroll_split_pattern_3:
	.addr	split_lines_05A320
	.addr	split_lines_05A340
	.addr	split_lines_05A350
split_lines_05A270:
	.byte	$00, $00, $02, $00, $7F, $00, $02, $00
split_lines_05A278:
	.byte	$00, $01
	.byte	$00, $00, $70, $01, $00, $00, $78, $01, $00, $1C, $80, $01, $00, $1A, $88, $01
	.byte	$00, $18, $90, $01, $00, $16, $98, $01, $00, $14, $A0, $01, $00, $12, $A8, $01
	.byte	$00, $10, $C0, $01, $00, $0E, $C8, $01, $00, $0C, $D0, $01, $00, $0A, $D8, $01
	.byte	$00, $08, $E0, $01, $00, $06, $E8, $01, $00, $04, $F0, $01, $00, $02, $F8, $01
	.byte	$00, $04
split_lines_05A2BC:
	.byte	$00, $02, $00, $06, $08, $02, $00, $08, $10, $02, $00, $0A, $18, $02
	.byte	$00, $0C, $20, $02, $00, $0E, $8F, $02, $02, $00, $DF, $02, $02, $00, $FF, $7F
	.byte	$00, $00
split_lines_05A2DC:
	.byte	$00, $00, $02, $00
	; CDL: read by build_split_line_table
	.byte	$7F, $00, $02, $00, $C0, $00, $02, $00, $E0, $00, $02, $00
split_lines_05A2EC:
	.byte	$00, $01, $00, $0E
	.byte	$18, $01, $02, $00, $28, $01, $00, $0E, $50, $01, $00, $10, $58, $01, $00, $0C
	.byte	$60, $01, $00, $0A, $68, $01, $00, $08, $70, $01, $00, $06, $80, $01, $00, $04
	.byte	$90, $01, $00, $02, $A0, $01, $00, $18, $B0, $01, $00, $16, $FF, $7F, $00, $14
split_lines_05A320:
	.byte	$20, $00, $00, $04, $39, $00, $00, $06, $60, $00, $00, $08, $80, $00, $00, $04
	.byte	$99, $00, $00, $06, $C0, $00, $00, $08, $E0, $00, $00, $04, $FF, $00, $00, $06
split_lines_05A340:
	.byte	$18, $01, $00, $08, $28, $01, $00, $06, $7F, $01, $04, $00, $FF, $01, $04, $00
split_lines_05A350:
	.byte	$00, $02, $04, $00, $7F, $02, $04, $00, $FF, $7F, $04, $00
tbl_05A35C:
	.addr	split_value_from_table
	.addr	split_value_bg2_x
	.addr	split_value_bg1_x
	; CDL: read by setup_stage_hdma; partly not accessed
hdma_list_05A362:
	hdma_channel_ind	$4370, $00, $30, hdma_table_05CA90, $7E
	hdma_channel_ind	$4360, $42, $0F, $7EA000, $7E
	hdma_channels_end	$C0
hdma_list_05A375:
	hdma_channel_ind	$4370, $02, $0D, $7EA000, $7E
	hdma_channels_end	$80
hdma_list_05A380:
	hdma_channel_ind	$4370, $42, $0E, $7EA400, $7E
	hdma_channel_ind	$4360, $42, $0D, $7EA000, $7E
	hdma_channels_end	$C0
hdma_list_05A393:
	hdma_channel_ind	$4370, $42, $10, $7EE800, $7E
	hdma_channels_end	$80
data_05A39E:
	; CDL: read by update_player_window
	.byte	$00, $02, $40, $02
data_05A3A2:
	; CDL: read by update_player_window
	.byte	$00, $F8, $00, $FA
data_05A3A6:
	; CDL: read by update_player_window
	.byte	$00, $3C, $00, $3E
data_05A3AA:
	; CDL: read by wobble_barrier_window
	.byte	$1F, $1F, $1E, $1E, $1D, $1D, $1C, $1C, $1B, $1B, $1A, $1A, $19, $19, $18, $18
	.byte	$17, $17, $16, $16, $15, $15, $14, $14, $13, $13, $12, $12, $11, $11, $10, $10
	.byte	$0F, $0F, $0E, $0E, $0D, $0D, $0C, $0C, $0B, $0B, $0A, $0A, $09, $09, $08, $08
	.byte	$07, $07, $06, $06, $05, $05, $04, $04, $03, $03, $02, $02, $01, $01, $00, $00
	.byte	$00, $00, $01, $01, $02, $02, $03, $03, $04, $04, $05, $05, $06, $06, $07, $07
	.byte	$08, $08, $09, $09, $0A, $0A, $0B, $0B, $0C, $0C, $0D, $0D, $0E, $0E, $0F, $0F
	.byte	$10, $10, $11, $11, $12, $12, $13, $13, $14, $14, $15, $15, $16, $16, $17, $17
	.byte	$18, $18, $19, $19, $1A, $1A, $1B, $1B, $1C, $1C, $1D, $1D, $1E, $1E, $1F, $1F
	; CDL: read by build_window_from_widths
	.byte	$00, $00, $06, $00, $09, $00, $0B, $00, $0D, $00, $0E, $00, $0F, $00, $10, $00
	.byte	$11, $00, $12, $00, $13, $00, $14, $00, $14, $00, $15, $00, $15, $00, $16, $00
	.byte	$16, $00, $16, $00, $17, $00, $17, $00, $17, $00, $17, $00, $17, $00, $17, $00
	.byte	$18, $00, $17, $00, $17, $00, $17, $00, $17, $00, $17, $00, $17, $00, $16, $00
	.byte	$16, $00, $16, $00, $15, $00, $15, $00, $14, $00, $14, $00, $13, $00, $12, $00
	.byte	$11, $00, $10, $00, $0F, $00, $0E, $00, $0D, $00, $0B, $00, $09, $00, $06, $00
tbl_object_types:
	.faraddr	$000000
	.faraddr	update_stage1_boss_controller
	.faraddr	update_object_type_02
	.faraddr	update_bg2_scroll_mode_trigger
	.faraddr	update_object_type_04
	.faraddr	update_bg1_autoscroll_trigger
	.faraddr	update_object_type_06
	.faraddr	update_load_list_trigger
	.faraddr	update_object_type_08
	.faraddr	update_player_tank
	.faraddr	update_foot_soldier
	.faraddr	update_soldier_spawner
	.faraddr	update_bomber_bomb
	.faraddr	update_popup_turret
	.faraddr	update_bg1_scroll_mode_trigger
	.faraddr	update_weapon_capsule
	.faraddr	update_bouncing_debris
	.faraddr	update_object_type_11
	.faraddr	update_object_type_12
	.faraddr	update_grenade
	.faraddr	update_object_type_14
	.faraddr	update_object_type_15
	.faraddr	update_object_type_16
	.faraddr	update_window_sniper
	.faraddr	update_enemy_bullet
	.faraddr	update_object_type_19
	.faraddr	update_grenade_blast
	.faraddr	update_dying_soldier
	.faraddr	update_object_type_1C
	.faraddr	update_effect
	.faraddr	update_alien_dog
	.faraddr	update_stage1_boss_head
	.faraddr	update_stage1_boss_part
	.faraddr	update_face_boss_larva
	.faraddr	update_stage1_boss_wall_chunk
	.faraddr	update_falling_debris
	.faraddr	update_object_type_24
	.faraddr	update_winged_alien_tail_segment
	.faraddr	update_stage1_boss_tracking_shot
	.faraddr	update_stage1_boss_falling_shot
	.faraddr	update_object_type_28
	.faraddr	update_stage1_boss
	.faraddr	update_object_type_2A
	.faraddr	update_object_type_2B
	.faraddr	update_object_type_2C
	.faraddr	update_object_type_2D
	.faraddr	update_object_type_2E
	.faraddr	update_object_type_2F
	.faraddr	update_object_type_30
	.faraddr	update_object_type_31
	.faraddr	update_object_type_32
	.faraddr	update_object_type_33
	.faraddr	update_object_type_34
	.faraddr	update_object_type_35
	.faraddr	delete_self_and_linked
	.faraddr	stage_exit
	.faraddr	update_stage1_boss_fire
	.faraddr	update_swing_pivot
	.faraddr	update_swing_handle
	.faraddr	update_scroll_modes_trigger
	.faraddr	update_object_type_3C
	.faraddr	update_stage3_spiked_climber
	.faraddr	update_object_type_3E
	.faraddr	update_object_type_3F
	.faraddr	update_stage3_spiked_climber_core
	.faraddr	update_stage3_boss
	.faraddr	update_object_type_42
	.faraddr	update_object_type_43
	.faraddr	update_stage3_robot_cables
	.faraddr	update_stage3_second_robot
	.faraddr	update_debris_explosion
	.faraddr	update_homing_missile
	.faraddr	update_object_type_48
	.faraddr	update_object_type_49
	.faraddr	update_rolling_mine
	.faraddr	update_debris_spark
	.faraddr	update_countdown_bomb
	.faraddr	update_song_change_trigger
	.faraddr	update_object_type_4E
	.faraddr	update_stage3_winged_bug
	.faraddr	update_wall_hatch
	.faraddr	update_object_type_48
	.faraddr	update_object_type_52
	.faraddr	update_passive_part
	.faraddr	update_object_type_04
	.faraddr	update_object_type_55
	.faraddr	update_object_type_56
	.faraddr	update_object_type_57
	.faraddr	update_heart_boss
	.faraddr	update_object_type_59
	.faraddr	update_object_type_5A
	.faraddr	update_wall_worm
	.faraddr	update_alien_soldier_spawner
	.faraddr	update_cave_beast
	.faraddr	update_winged_alien
	.faraddr	update_face_boss
	.faraddr	update_object_type_60
	.faraddr	update_floor_mouth
	.faraddr	update_floor_mouth_bug
	.faraddr	update_wall_worm_larva
	.faraddr	update_stage4_controller
	.faraddr	update_rideable_missile
	.faraddr	update_cave_rock
	.faraddr	update_heart_boss_bug
	.faraddr	update_enemy_type_68
	.faraddr	update_stage4_boss
	.faraddr	update_stage4_boss_pod
	.faraddr	update_destructible_part
	.faraddr	update_destructible_part_2
	.faraddr	update_player_bike
	.faraddr	update_stage4_tank
	.faraddr	update_brain_boss
	.faraddr	update_enemy_type_70
	.faraddr	update_cave_beast_fireball
	.faraddr	update_cave_beast_beam
	.faraddr	update_object_type_73
	.faraddr	update_hoverbike_rider
	.faraddr	update_face_boss_side_head
	.faraddr	update_object_type_76
	.faraddr	update_face_boss_neck
	.faraddr	update_object_type_78
	.faraddr	update_snake_robot
	.faraddr	update_lightning_pylon
	.faraddr	update_lightning_bolt
	.faraddr	update_enemy_type_7C
	.faraddr	update_spiked_mine
	.faraddr	update_object_type_7E
	.faraddr	update_airship_gun_arm
	.faraddr	update_enemy_type_80
	.faraddr	update_snake_robot_head
	.faraddr	update_stage4_boss_shot
	.faraddr	update_stage4_boss_fireball
	.faraddr	update_helicopter_rope
	.faraddr	update_enemy_type_85
	.faraddr	update_trail_segment
	.faraddr	update_skeleton_eye_fireball
	.faraddr	update_snake_robot_debris
	.faraddr	update_object_type_89
	.faraddr	update_brain_boss
	.faraddr	update_brain_boss_orb_ring
	.faraddr	update_brain_boss_chain
	.faraddr	update_winged_alien_tail_tip
	.faraddr	update_enemy_type_8E
	.faraddr	update_enemy_type_8F
	.faraddr	update_brain_boss_eyeball
	.faraddr	update_brain_boss_rolling_eye
	.faraddr	update_brain_boss_orb_arch
	.faraddr	update_brain_boss_orb
	.faraddr	update_brain_boss_orb_cluster
	.faraddr	update_ending_sequence
	.faraddr	update_enemy_type_96
	.faraddr	update_enemy_type_97
	.faraddr	update_ending_explosion
	.faraddr	update_enemy_type_99
	.faraddr	update_ending_crowd_member
	.faraddr	update_ending_crowd_member
	.faraddr	update_ending_crowd_member
	.faraddr	update_ending_crowd_member
	.faraddr	update_ending_crowd_walker_a
	.faraddr	update_ending_crowd_walker_b
	.faraddr	update_cave_beast_target
type_scores:
	; CDL: read by update_shots, call_object_handler, bomb_hit_targets; partly not accessed
	.byte	$00, $00, $00, $00, $00, $52, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $80, $01, $00, $00, $00, $00, $20, $03, $00, $00, $05, $00
	.byte	$00, $00, $00, $35, $60, $05, $00, $00, $00, $72, $40, $02, $00, $00, $90, $07
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $03, $00, $00, $00, $80, $99, $00, $00
	.byte	$50, $00, $20, $00, $00, $00, $00, $00, $10, $06, $00, $00, $64, $08, $64, $04
	.byte	$00, $00, $50, $55, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $88, $08, $00, $00, $00, $00, $01, $90, $01, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $77, $77, $00, $00, $00, $00
	.byte	$77, $77, $00, $23, $00, $00, $01, $00, $00, $00, $00, $23, $00, $00, $07, $00
	.byte	$50, $04, $00, $00, $10, $07, $00, $00, $00, $00, $00, $00, $00, $48, $10, $00
	.byte	$00, $05, $52, $04, $00, $20, $00, $00, $00, $00, $00, $00, $00, $12, $00, $00
	.byte	$00, $15, $70, $77, $00, $00, $00, $05, $00, $00, $00, $25, $00, $35, $00, $45
	.byte	$00, $00, $50, $06, $01, $00, $30, $00, $00, $00, $00, $00, $00, $00, $80, $00
	.byte	$20, $00, $50, $98, $90, $51, $30, $00, $40, $00, $00, $00, $80, $02, $99, $99
	.byte	$00, $00, $00, $00, $00, $00, $30, $05, $30, $70, $00, $30, $00, $00, $00, $00
	.byte	$00, $00, $00, $50, $30, $04, $00, $00, $90, $00, $00, $00, $05, $00, $99, $99
	.byte	$00, $00, $80, $49, $04, $00, $00, $40, $50, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $50, $76, $50, $08, $00, $00, $00, $00, $00, $00, $05, $15
	.byte	$20, $56, $00, $00, $00, $00, $00, $00, $00, $00, $30, $57, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $25
ptrs_05A7AF:
	.addr	load_list_05A7DB
	.addr	load_list_05A7DB
	.addr	load_list_05A7DB
	.addr	load_list_05A7DB
	.addr	load_list_05A807
	.addr	load_list_05A807
	.addr	load_list_05A807
opening_scene_durations:
	; CDL: read by opening_scene_run
	.byte	$B4, $00, $DD, $02, $3C, $00, $EC, $01, $15, $02, $82, $00, $B2, $00
opening_scene_next_states:
	; CDL: read by opening_next_scene_unused; partly not accessed
	.byte	$01, $00, $03, $00, $03, $00, $03, $00, $01, $00, $01, $00, $03, $00, $05, $00
load_list_05A7DB:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$0000, gfx_06D6A7
	load_vram	$1000, gfx_08C078
	load_vram	$2000, gfx_08D8AF
	load_vram	$3000, gfx_17CE4D
	load_vram	$4000, gfx_06EF5C
	load_vram	$4400, gfx_06EC94
	load_vram	$4800, gfx_06F184
	load_vram	$7000, gfx_17B953
	load_end
load_list_05A807:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk (+4 more)
	load_list	$00, $00
	load_vram	$4000, gfx_06F313
	load_vram	$4800, gfx_06F68F
	load_end
palette_task_05A815:
	palette_animate	$00, $00
	palette_copy	palette_0889F0, $2200
	palette_copy	palette_0882B6, $2300
	palette_copy	palette_088254, $23A0
	palette_copy	palette_088AF6, $2380
	palette_copy_end
palette_task_05A82A:
	palette_fade_in	$08, palette_088AF6, $2380
palette_task_05A830:
	palette_fade_in	$10, palette_088254, $23A0
palette_task_05A836:
	palette_fade_out	$10, palette_088254, $23A0
palette_task_05A83C:
	palette_animate	$00, $00
	palette_copy	palette_088254, $23A0
	palette_copy_end
palette_task_05A845:
	palette_fade_in	$08, palette_088AF2, $2250
load_list_05A84B:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+1 more)
	load_list	$01, $00
	load_wram	$7E9000, packed_07F552
	load_wram	$7E5000, packed_15D80A
	load_end
data_05A85B:
	; CDL: read by opening_city_init
	.byte	$20, $00, $00, $08, $00, $00, $08, $00, $00, $08, $00, $00, $08, $00, $00, $08
	.byte	$00, $00, $08, $00, $00, $00
data_05A871:
	; CDL: read by opening_city_init, opening_vortex_spawn_objects
	.byte	$26, $00, $2E, $00, $36, $00, $3E, $00, $46, $00, $4E, $00, $56, $00, $5E, $00
	.byte	$66, $00, $6E, $00, $76, $00, $7E, $00, $86, $00, $8E, $00, $96, $00, $9E, $00
data_05A891:
	; CDL: read by opening_vortex_spawn_objects
	.addr	anim_05A92D, anim_05A93F, anim_05A951, anim_05A933
	.addr	anim_05A945, anim_05A957, anim_05A939, anim_05A94B
	.addr	anim_05A92D, anim_05A93F, anim_05A951, anim_05A933
	.addr	anim_05A945, anim_05A957, anim_05A939, anim_05A94B
data_05A8B1:
	; CDL: read by opening_ruins_fade
	.byte	$FE, $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1, $F0, $EF
	.byte	$EE, $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1, $E0, $00
data_05A8D1:
	; CDL: read by opening_ruins_fade, opening_scene_hero_face; partly not accessed
	.byte	$10, $08, $10, $08, $04, $04, $08, $04, $FF, $FF
data_05A8DB:
	; CDL: read by opening_scene_hero_face; partly not accessed
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $00, $00
data_05A8E5:
	; CDL: read by opening_scene_heroes; partly not accessed
	.byte	$19, $08, $10, $08, $04, $04, $08, $04, $04, $08, $08, $04, $FF, $FF
data_05A8F3:
	; CDL: read by opening_scene_heroes; partly not accessed
	.byte	$03, $02, $03, $02, $03, $02, $03, $02, $03, $02, $03, $02, $02, $02
data_05A901:
	; CDL: read by opening_draw_caption_part
	.byte	$02, $00, $02, $00, $01, $00, $01, $00
data_05A909:
	; CDL: read by opening_draw_caption_part
	.byte	$10, $00, $10, $00, $08, $00, $08, $00
data_05A911:
	; CDL: read by opening_draw_caption_part
	.byte	$6C, $42, $6C, $42, $0E, $49, $0E, $49
data_05A919:
	; CDL: read by update_objects, opening_draw_caption_part, queue_vram_blocks_at_x; partly not accessed
	.addr	vram_blocks_05A921, vram_blocks_05A925, vram_blocks_05A929, vram_blocks_05A92B
vram_blocks_05A921:
	.byte	$00, $68, $20, $68
vram_blocks_05A925:
	.byte	$40, $68, $60, $68
vram_blocks_05A929:
	.byte	$E0, $67
vram_blocks_05A92B:
	.byte	$80, $68
anim_05A92D:
	anim_frame	$0002, metasprite_06D3C1, metasprite_06D3C1
anim_05A933:
	anim_frame	$0002, metasprite_06D3C6, metasprite_06D3C6
anim_05A939:
	anim_frame	$0002, metasprite_06D3CB, metasprite_06D3CB
anim_05A93F:
	anim_frame	$0002, metasprite_06D3D0, metasprite_06D3D0
anim_05A945:
	anim_frame	$0002, metasprite_06D3D5, metasprite_06D3D5
anim_05A94B:
	anim_frame	$0002, metasprite_06D3DA, metasprite_06D3DA
anim_05A951:
	anim_frame	$0002, metasprite_06D3DF, metasprite_06D3DF
anim_05A957:
	anim_frame	$0002, metasprite_06D3E4, metasprite_06D3E4
	anim_goto	anim_05A92D
anim_05A95F:
	anim_frame	$0002, metasprite_06D380, metasprite_06D1B9
	anim_frame	$0002, metasprite_06D33F, metasprite_06D1FA
	anim_frame	$0002, metasprite_06D2FE, metasprite_06D23B
	anim_frame	$0002, metasprite_06D2BD, metasprite_06D27C
	anim_frame	$0002, metasprite_06D27C, metasprite_06D2BD
	anim_frame	$0002, metasprite_06D23B, metasprite_06D2FE
	anim_frame	$0002, metasprite_06D1FA, metasprite_06D33F
	anim_frame	$0002, metasprite_06D1B9, metasprite_06D380
	anim_frame	$0002, metasprite_06D1FA, metasprite_06D33F
	anim_frame	$0002, metasprite_06D1B9, metasprite_06D380
	anim_frame	$0002, metasprite_06D1FA, metasprite_06D33F
	anim_frame	$0002, metasprite_06D1B9, metasprite_06D380
	anim_frame	$0002, metasprite_06D1FA, metasprite_06D33F
	anim_frame	$0002, metasprite_06D23B, metasprite_06D2FE
	anim_frame	$0002, metasprite_06D27C, metasprite_06D2BD
	anim_frame	$0002, metasprite_06D2BD, metasprite_06D27C
	anim_frame	$0002, metasprite_06D2FE, metasprite_06D23B
	anim_frame	$0002, metasprite_06D33F, metasprite_06D1FA
	anim_frame	$0002, metasprite_06D380, metasprite_06D1B9
anim_05A9D1:
	anim_frame	$0002, $0000, $0000
	anim_goto	anim_05A9D1
data_05A9D9:
	; CDL: read by opening_clear_objects
	.byte	$00, $03, $40, $03, $80, $03, $C0, $03, $00, $04, $40, $04, $80, $04, $C0, $04
	.byte	$00, $05, $40, $05, $80, $05, $C0, $05, $00, $06, $40, $06, $80, $06, $C0, $06
data_05A9F9:
	; CDL: read by opening_init_ruins_wave
	.byte	$50, $10, $A0, $EE, $20, $A0, $30, $10, $A0, $00
data_05AA03:
	; CDL: read by build_wave_table, opening_init_ruins_wave
	.byte	$50, $10, $A4, $EE, $20, $A4, $30, $10, $A4, $00
ruins_wave_params_0:
	.byte	$80, $13, $00, $00, $70, $00
	.byte	$20, $A0, $7E
ruins_wave_params_1:
	.byte	$98, $13, $00, $00, $70, $00, $20, $A4, $7E
load_list_05AA1F:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk (+4 more); DMA / HDMA; partly not accessed
	load_list	$00, $01
	load_vram	$7000, gfx_0DE218
	load_end
palette_task_05AA28:
	palette_animate	$00, $00
	palette_copy	palette_08841C, $2380
	palette_copy_end
hdma_list_05AA31:
	hdma_channel_ind	$4370, $00, $05, hdma_table_05AA44, $05
	hdma_channel_ind	$4360, $02, $12, hdma_table_05AA49, $05
	hdma_channels_end	$C0
hdma_table_05AA44:
	.byte	$18, $09, $80, $0A, $00
hdma_table_05AA49:
	.byte	$18, $00, $00, $80, $80, $00
	.byte	$00
data_05AA50:
	; CDL: read by spawn_stage1_boss_wall_chunks
	.byte	$6C, $01, $8C, $01, $8C, $01, $8C, $01
data_05AA58:
	; CDL: read by spawn_stage1_boss_wall_chunks
	.byte	$A4, $00, $B0, $00, $BC, $00, $C8, $00
data_05AA60:
	; CDL: read by spawn_stage1_boss_wall_chunks
	.byte	$0A, $00, $05, $00, $00, $00, $00, $00
data_05AA68:
	; CDL: read by spawn_stage1_boss_falling_debris; DMA / HDMA
	.byte	$10, $00, $40, $00, $50, $00, $60, $00, $70, $00, $80, $00, $90, $00, $A0, $00
	.byte	$B0, $00, $C0, $00, $20, $00, $30, $00
data_05AA80:
	; CDL: read by spawn_stage1_boss_falling_debris
	.addr	metasprite_06B6F8, metasprite_06B6F8, metasprite_06B6E7, metasprite_06B6E7
	.addr	metasprite_06B6F8, metasprite_06B6E7, metasprite_06B6F8, metasprite_06B6F8
	.addr	metasprite_06B6E7, metasprite_06B6F8, metasprite_06B6F8, metasprite_06B6E7
data_05AA98:
	; CDL: read by spawn_stage1_boss_falling_debris
	.byte	$FC, $FF, $FD, $FF, $FD, $FF, $FE, $FF, $FF, $FF, $FD, $FF, $FF, $FF, $FC, $FF
	.byte	$FD, $FF, $FE, $FF, $FE, $FF, $FF, $FF
data_05AAB0:
	; CDL: read by update_stage1_boss_wall_chunk, queue_vram_blocks_at_x
	.addr	metasprite_06B699, metasprite_06B688, metasprite_06B673, metasprite_06B6FD
vram_blocks_05AAB8:
	.byte	$00, $80, $20, $80, $80, $80, $A0, $80
	.byte	$00, $81, $20, $81, $80, $81, $A0, $81
vram_blocks_05AAC8:
	.byte	$40, $80, $60, $80, $C0, $80, $E0, $80
	.byte	$40, $81, $60, $81
data_05AAD4:
	; CDL: read by spawn_stage1_boss_parts
	.byte	$10, $00, $3C, $00, $10, $00
data_05AADA:
	; CDL: read by spawn_stage1_boss_parts
	.byte	$29, $00, $1F, $00, $20, $00
data_05AAE0:
	; CDL: read by spawn_stage1_boss_parts
	.byte	$1E, $00, $40, $00, $20, $00
data_05AAE6:
	; CDL: read by spawn_stage1_boss_parts
	.byte	$F0, $FF, $E0, $FF, $E0, $FF
data_05AAEC:
	; CDL: read by spawn_stage1_boss_parts
	.byte	$98, $00, $60, $00, $98, $00
data_05AAF2:
	; CDL: read by update_objects, stage1_boss_fire_falling_shot, queue_vram_blocks_at_x (+1 more); DMA / HDMA
	.byte	$00, $20, $00, $30, $00, $50, $00, $40
anim_05AAFA:
	anim_frame	$0004, metasprite_06B6CC, metasprite_06B6B8
	anim_frame	$0004, metasprite_06B6D5, metasprite_06B6BD
	anim_frame	$0004, metasprite_06B6DE, metasprite_06B6C2
	anim_frame	$0004, metasprite_06B6D5, metasprite_06B6C7
	anim_goto	anim_05AAFA
anim_05AB14:
	anim_frame	$0002, metasprite_06B6AA, metasprite_06AFEA
	anim_frame	$0002, metasprite_06B6AF, metasprite_06AFD9
	anim_goto	anim_05AB14
anim_05AB22:
	anim_frame	$0080, metasprite_06AFD9, $3E00
vram_blocks_05AB28:
	.byte	$20, $C4
	.byte	$40, $C4, $A0, $C4, $C0, $C4
vram_blocks_05AB30:
	.byte	$00, $C5
	.byte	$20, $C5, $80, $C5, $A0, $C5, $00, $B5, $60, $C4, $00, $B5, $E0, $C4
.if CHEAT_ENEMY_HP = 100
stage1_boss_shell_hp:
.endif
	; CDL: read by spawn_stage1_boss_parts; DMA / HDMA
	.byte	$80, $00, $00, $01, $FF, $7F	; cheats: see cheat_enemy_hp_tables
data_05AB46:
	; CDL: read by update_stage1_boss_tracking_shot; DMA / HDMA
	.byte	$00, $04, $00, $06, $00, $08
data_05AB4C:
	; CDL: read by update_stage1_boss; partly not accessed
	.byte	$00, $01, $C0, $00, $08, $00
data_05AB52:
	; CDL: read by stage1_boss_attack_fire; partly not accessed
	.byte	$40, $00, $80, $00, $00, $01
data_05AB58:
	; CDL: read by song_change_state_00; partly not accessed
	.byte	$00, $00, $00, $00, $80, $00, $00, $00, $03, $00, $04, $00
data_05AB64:
	; CDL: not accessed
	.byte	$80, $13, $C0, $13
data_05AB68:
	; CDL: not accessed
	.byte	$00, $40, $00, $48
data_05AB6C:
	; CDL: read by update_player_bike
	.byte	$00, $02, $40, $02
data_05AB70:
	; CDL: read by player_bike_state_00
	.byte	$00, $3A, $00, $3C
data_05AB74:
	; CDL: read by set_player_box_jumping
	.byte	$FF, $FF, $FC, $FF
; By respawn mode (wram_1672): the player state, pose and y velocity after
; respawning (respawn_player).
respawn_states:
	; CDL: read by respawn_player
	.byte	$04, $04, $02, $04, $04, $12, $04, $04, $04
respawn_poses:
	; CDL: read by respawn_player
	.byte	$D3, $00, $D3, $00, $54, $00, $D3, $00, $D3, $00, $F0, $00, $D3, $00, $D3, $00
	.byte	$D3, $00
respawn_y_vels:
	; CDL: read by respawn_player
	.byte	$FE, $FF, $FE, $FF, $00, $00, $FE, $FF, $FE, $FF, $00, $00, $FE, $FF, $FE, $FF
	.byte	$FE, $FF
; Velocity table of the enemy bullets for each difficulty (easy and normal
; share $05:928A; hard $05:93CA, faster), read by spawn_enemy_bullet.
ptrs_enemy_bullet_speeds:
	; CDL: read by spawn_enemy_bullet
	.addr	enemy_bullet_speeds_normal
	.addr	enemy_bullet_speeds_normal
	.addr	enemy_bullet_speeds_hard
data_05ABAB:
	; CDL: read by init_homing_missile
	.byte	$00, $14
data_05ABAD:
	; CDL: read by init_homing_missile
	.byte	$40, $04, $00, $14, $80, $05, $00, $14, $80, $07, $00, $14
data_05ABB9:
	; CDL: read by init_homing_missile
	.byte	$06, $00, $00, $00
data_05ABBD:
	; CDL: read by init_homing_missile
	.byte	$00, $00, $06, $00
data_05ABC1:
	; CDL: read by player_state_ending
	.byte	$10, $01, $11, $01, $12, $01, $10, $01
data_05ABC9:
	; CDL: read by player_state_ending_wave; partly not accessed
	.byte	$17, $01, $16, $01, $13, $01, $14, $01, $15, $01, $18, $01, $15, $01, $15, $01
	.byte	$14, $01, $17, $01, $16, $01, $19, $01
data_05ABE1:
	; CDL: read by player_state_spin_stance
	.byte	$C4, $00, $1C, $1A, $CA, $B0, $B4, $B2, $C5, $BA, $BE, $BC
data_05ABED:
	; CDL: read by set_player_box_hanging
	.byte	$02, $00, $04, $00
data_05ABF1:
	; CDL: read by set_player_box_hanging
	.byte	$08, $00, $08, $00
data_05ABF5:
	; CDL: read by set_player_box_hanging
	.byte	$F4, $FF, $FA, $FF
data_05ABF9:
	; CDL: read by player_state_bike_intro; partly not accessed
	.byte	$20, $00, $20, $00, $00, $00, $10, $00, $60, $00, $00, $00, $70, $00, $00, $00
	.byte	$40, $00, $30, $00, $00, $00, $00, $00, $50, $00
data_05AC13:
	; CDL: read by player_state_bike_intro; partly not accessed
	.byte	$F0, $00, $F0, $00, $00, $01, $F8, $00, $F4, $00, $00, $00, $FC, $00, $00, $00
	.byte	$04, $01, $08, $01, $00, $00, $00, $00, $0C, $01
data_05AC2D:
	; CDL: read by player_state_bike_intro; partly not accessed
	.byte	$18, $00, $18, $00, $04, $00, $14, $00, $D8, $FF, $00, $00, $EA, $FF, $00, $00
	.byte	$02, $00, $12, $00, $00, $00, $00, $00, $E2, $FF
data_05AC47:
	; CDL: read by player_state_bike_intro; partly not accessed
	.byte	$DC, $FF, $DC, $FF, $BE, $FF, $C8, $FF, $D9, $FF, $00, $00, $CC, $FF, $00, $00
	.byte	$00, $00, $F0, $FF, $00, $00, $00, $00, $F0, $FF
data_05AC61:
	; CDL: read by object_type_02_state_07
	.byte	$0F, $00, $07, $00, $03, $00
data_05AC67:
	; CDL: read by object_type_02_state_07
	.byte	$FA, $FF, $FA, $FF, $F8, $FF, $FC, $FF, $F8, $FF, $FA, $FF, $F8, $FF, $FB, $FF
data_05AC77:
	; CDL: read by object_type_02_state_07; partly not accessed
	.byte	$00, $80, $00, $40, $00, $40, $00, $50, $00, $70, $00, $20, $00, $60, $00, $30
data_05AC87:
	; CDL: read by queue_vram_blocks_at_x, object_type_02_state_07; partly not accessed
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FD, $FF, $FE, $FF, $FD, $FF, $FE, $FF, $FD, $FF
vram_blocks_05AC97:
	.byte	$00, $B7, $20, $B7, $40, $B7, $60, $B7, $80, $B7, $A0, $B7, $C0, $B7, $E0, $B7
vram_blocks_05ACA7:
	.byte	$60, $BF, $80, $C0, $A0, $C0, $C0, $C0, $00, $C0, $20, $C0, $40, $C0, $60, $C0
vram_blocks_05ACB7:
	.byte	$00, $B5, $A0, $B5, $C0, $B5, $E0, $B5, $00, $B6, $20, $B6, $40, $B6, $60, $B6
vram_blocks_05ACC7:
	.byte	$80, $B6, $A0, $B6, $C0, $B6, $E0, $B6
vram_blocks_05ACCF:
	.byte	$80, $B6, $A0, $B6, $C0, $B6, $E0, $B6
vram_blocks_05ACD7:
	.byte	$80, $BF, $A0, $BF, $C0, $BF, $E0, $BF
vram_blocks_05ACDF:
	.byte	$00, $62, $20, $62, $40, $62, $60, $62
	.byte	$00, $61, $20, $61, $20, $61, $40, $61, $80, $61, $A0, $61, $A0, $61, $C0, $61
	.byte	$00, $61, $20, $61, $20, $61, $40, $61, $80, $61, $A0, $61, $A0, $61, $C0, $61
	.byte	$80, $7B, $A0, $7B, $A0, $7B, $C0, $7B, $80, $62, $A0, $62, $C0, $62, $E0, $62
	.byte	$00, $5D, $60, $72, $60, $72, $20, $5D, $40, $5D, $E0, $72, $E0, $72, $60, $5D
	.byte	$00, $5D, $60, $72, $60, $72, $20, $5D, $40, $5D, $E0, $72, $E0, $72, $60, $5D
	.byte	$00, $7B, $20, $7B, $20, $7B, $40, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $63, $20, $63, $40, $63, $60, $63, $00, $61, $20, $61, $20, $61, $40, $61
	.byte	$80, $61, $A0, $61, $A0, $61, $C0, $61, $00, $61, $20, $61, $20, $61, $40, $61
	.byte	$E0, $7A, $60, $7B, $60, $7B, $E0, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$80, $63, $A0, $63, $C0, $63, $E0, $63, $00, $5D, $60, $72, $60, $72, $20, $5D
	.byte	$40, $5D, $E0, $72, $E0, $72, $60, $5D, $00, $5D, $60, $72, $60, $72, $20, $5D
	.byte	$80, $73, $60, $73, $60, $73, $A0, $73, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $64, $20, $64, $40, $64, $60, $64
	.byte	$00, $61, $20, $61, $20, $61, $40, $61, $80, $61, $A0, $61, $A0, $61, $C0, $61
	.byte	$80, $7B, $A0, $7B, $A0, $7B, $C0, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $80, $63, $A0, $63, $C0, $63, $E0, $63
	.byte	$00, $5D, $60, $72, $60, $72, $20, $5D, $40, $5D, $E0, $72, $E0, $72, $60, $5D
	.byte	$00, $7B, $20, $7B, $20, $7B, $40, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$00, $65, $20, $65, $40, $65, $60, $65, $00, $61, $20, $61, $20, $61, $40, $61
	.byte	$E0, $7A, $60, $7B, $60, $7B, $E0, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$80, $65, $A0, $65, $C0, $65, $E0, $65, $00, $5D, $60, $72, $60, $72, $20, $5D
	.byte	$80, $73, $60, $73, $60, $73, $A0, $73, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$80, $5E, $A0, $5E, $C0, $5E, $E0, $5E, $00, $66, $20, $66, $20, $66, $40, $66
	.byte	$80, $7B, $A0, $7B, $A0, $7B, $C0, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$80, $5E, $A0, $5E, $C0, $5E, $E0, $5E, $80, $66, $A0, $66, $A0, $66, $C0, $66
	.byte	$00, $7B, $20, $7B, $20, $7B, $40, $7B, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$80, $5E, $A0, $5E, $C0, $5E, $E0, $5E, $00, $60, $20, $60, $20, $60, $40, $60
	.byte	$00, $67, $20, $67, $20, $67, $40, $67, $80, $5D, $A0, $5D, $C0, $5D, $E0, $5D
	.byte	$00, $5E, $20, $5E, $40, $5E, $60, $5E, $00, $5E, $20, $5E, $40, $5E, $60, $5E
	.byte	$80, $5E, $A0, $5E, $C0, $5E, $E0, $5E, $00, $60, $20, $60, $20, $60, $40, $60
	.byte	$80, $60, $A0, $60, $A0, $60, $C0, $60
vram_blocks_05AF1F:
	.byte	$20, $50, $40, $50, $60, $50
vram_blocks_05AF25:
	.byte	$A0, $50
	.byte	$C0, $50, $E0, $50
vram_blocks_05AF2B:
	.byte	$80, $50, $00, $51, $20, $51
data_05AF31:
	; CDL: read by player_tank_state_02
	.byte	$00, $02, $00, $02, $04, $02
data_05AF37:
	; CDL: read by setup_stage_hdma, queue_vram_blocks_at_x, player_tank_state_02; partly not accessed
	.byte	$00, $04, $04, $04, $00, $04
vram_blocks_05AF3D:
	.byte	$00, $C9, $20, $C9, $40, $C9, $80, $C9, $A0, $C9
	.byte	$C0, $C9
vram_blocks_05AF49:
	.byte	$60, $C9, $E0, $C9, $00, $CA, $20, $CA, $40, $CA, $60, $CA
vram_blocks_05AF55:
	.byte	$60, $C8
	.byte	$E0, $C8, $80, $CA, $20, $CA, $40, $CA, $60, $CA
hdma_list_05AF61:
	hdma_channel_ind	$4370, $02, $0F, $7E3800, $7E
	hdma_channels_end	$80
data_05AF6C:
	; CDL: read by setup_stage_hdma, object_type_35_state_02
	.byte	$02, $00, $0E, $00, $00, $00, $10, $00, $02, $00, $0E, $00
data_05AF78:
	; CDL: read by object_type_35_state_02
	.byte	$98, $00, $98, $00, $A0, $00, $A0, $00, $A8, $00, $A8, $00
data_05AF84:
	; CDL: read by object_type_35_state_02
	.byte	$00, $A0, $00, $60, $00, $C0, $00, $40, $00, $E0, $00, $20
data_05AF90:
	; CDL: read by update_objects, queue_vram_blocks_at_x, object_type_35_state_02; partly not accessed
	.byte	$FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00
anim_05AF9C:
	anim_frame	$0006, metasprite_06B158, metasprite_06B412
	anim_frame	$0008, metasprite_06B16D, metasprite_06B427
	anim_frame	$0006, metasprite_06B182, metasprite_06B43C
	anim_frame	$0008, metasprite_06B16D, metasprite_06B427
	anim_goto	anim_05AF9C
anim_05AFB6:
	anim_frame	$000C, metasprite_06B197, metasprite_06B451
	anim_frame	$0006, metasprite_06B1AC, metasprite_06B466
	anim_frame	$000C, metasprite_06B197, metasprite_06B451
	anim_end	metasprite_06B197, metasprite_06B451
vram_blocks_05AFCE:
	.byte	$40, $55
	.byte	$C0, $55
data_05AFD2:
	; CDL: read by update_soldier_spawner
	.byte	$40, $00, $28, $00, $10, $00
data_05AFD8:
	; CDL: read by update_soldier_spawner
	.byte	$80, $00, $60, $00, $40, $00
data_05AFDE:
	; CDL: read by update_soldier_spawner
	.byte	$02, $00, $04, $00, $0C, $00
; OBJ_HP of update_foot_soldier and type $35 by difficulty (easy, normal, hard)
soldier_hp:
	; CDL: read by init_foot_soldier_with_hp
	.word	ENEMY_HP($0000), ENEMY_HP($0001), ENEMY_HP($0003)
data_05AFEA:
	; CDL: read by object_type_73_state_00
	.byte	$F8, $FF, $F9, $FF, $FA, $FF
data_05AFF0:
	; CDL: read by object_type_73_state_00
	.byte	$40, $00, $60, $00, $80, $00
data_05AFF6:
	; CDL: read by update_objects, object_type_73_state_03; partly not accessed
	.byte	$60, $00, $70, $00, $80, $00
anim_05AFFC:
	anim_frame	$0020, metasprite_06C5CF, metasprite_06C7FB
anim_05B002:
	anim_frame	$0010, metasprite_06C5E0, metasprite_06C80C
	anim_frame	$0020, metasprite_06C5F1, metasprite_06C5F1
	anim_frame	$0080, metasprite_06C80C, metasprite_06C5E0
	anim_end	metasprite_06C7FB, metasprite_06C5CF
anim_05B01A:
	anim_frame	$0008, metasprite_06C675, metasprite_06C6A4
	anim_frame	$0008, metasprite_06C686, metasprite_06C6B5
	anim_goto	anim_05B01A
data_05B028:
	; CDL: read by object_type_7E_state_01
	.byte	$24, $00, $14, $00, $0C, $00
data_05B02E:
	; CDL: read by object_type_7E_state_01
	.byte	$18, $00, $58, $00, $98, $00, $D8, $00
data_05B036:
	; CDL: read by queue_vram_blocks_at_x, queue_object_tiles
	.byte	$9C, $42, $9C, $46, $80, $46, $88, $46, $18, $42, $00, $46, $0C, $42, $18, $42
vram_blocks_05B046:
	.byte	$00, $51, $60, $83, $80, $83, $A0, $83
vram_blocks_05B04E:
	.byte	$C0, $83, $E0, $83
vram_blocks_05B052:
	.byte	$20, $84, $40, $84
vram_blocks_05B056:
	.byte	$00, $51, $00, $84
; OBJ_HP of update_wall_hatch by difficulty (easy, normal, hard)
wall_hatch_hp:
	; CDL: read by wall_hatch_state_00; partly not accessed
	.word	ENEMY_HP($0004), ENEMY_HP($0008), ENEMY_HP($0010)
data_05B060:
	; CDL: read by wall_hatch_state_02
	.byte	$80, $69, $A0, $69
data_05B064:
	; CDL: read by wall_hatch_state_03
	.byte	$40, $69, $60, $69, $80, $68, $A0, $68, $C0, $68, $E0, $68, $00, $69, $20, $69
data_05B074:
	; CDL: read by wall_hatch_state_02
	.byte	$40, $69, $A0, $69, $80, $69
data_05B07A:
	; CDL: read by wall_hatch_state_03; partly not accessed
	.byte	$0C, $00, $18, $00, $1C, $00, $18, $00, $0C, $00, $00, $00, $FC, $FF, $FF, $FF
data_05B08A:
	; CDL: read by wall_hatch_state_03; partly not accessed
	.byte	$E4, $FF, $EA, $FF, $F6, $FF, $02, $00, $00, $00, $00, $00, $F6, $FF, $EA, $FF
data_05B09A:
	; CDL: read by queue_vram_blocks_at_x, wall_hatch_state_03; partly not accessed
	.byte	$03, $00, $01, $00, $00, $00
vram_blocks_05B0A0:
	.byte	$00, $50, $40, $76, $60, $76, $A0, $76, $C0, $76
	.byte	$E0, $76, $20, $77, $40, $77, $60, $77, $A0, $77, $C0, $77, $E0, $77, $60, $74
	.byte	$00, $77, $80, $77
	; CDL: read by update_objects, queue_vram_blocks_at_x; partly not accessed
	.byte	$00, $50, $00, $50, $00, $50, $00, $78, $20, $78, $40, $74, $80, $78, $20, $76
	.byte	$C0, $74, $00, $79, $A0, $78, $40, $75, $60, $74, $20, $79, $C0, $74, $00, $50
	.byte	$00, $50, $00, $50, $00, $50, $00, $78, $60, $76, $40, $78, $C0, $76, $E0, $76
	.byte	$C0, $78, $40, $77, $60, $77, $60, $74, $E0, $78, $E0, $77, $00, $50, $00, $50
	.byte	$00, $50, $00, $50, $00, $50, $00, $50, $40, $79, $60, $79, $40, $74, $C0, $79
	.byte	$20, $76, $C0, $74, $60, $74, $E0, $79, $40, $75, $00, $50, $00, $50, $00, $50
	.byte	$00, $50, $00, $50, $00, $50, $80, $50, $00, $7A, $20, $7A, $80, $7A, $C0, $76
	.byte	$E0, $76, $60, $74, $A0, $7A, $60, $77, $00, $50, $00, $50, $00, $50, $00, $50
	.byte	$00, $50, $00, $50, $80, $50, $80, $50, $80, $50, $C0, $73, $40, $7A, $40, $74
	.byte	$60, $74, $40, $6A, $C0, $74, $00, $50, $00, $50, $00, $50, $00, $50, $00, $50
	.byte	$00, $50, $80, $50, $80, $50, $80, $50, $C0, $73, $E0, $73, $E0, $73, $60, $74
	.byte	$80, $79, $A0, $79
anim_05B172:
	anim_frame	$0004, metasprite_06B0B9, metasprite_06B0B9
	anim_frame	$0004, metasprite_06B0D2, metasprite_06B0D2
; Metasprites by weapon capsule kind (weapon_capsule_set_kind, kinds 1-7).
; Entry 0 is the jump word of the script above, and the last entry is also
; the first word of data_05B18C: the tables overlap. The jump's $B172 is also
; a metasprite ($06:B172, drawn in the CDL): a fixed reference, see the book
; ("Shiftability").
data_05B17E:
	; CDL: read by update_objects, weapon_capsule_set_kind
	anim_goto	anim_05B172
	.addr	metasprite_06ADC4, metasprite_06ADED, metasprite_06AE16, metasprite_06AE3F, metasprite_06AE68, metasprite_06B07A
data_05B18C:
	; CDL: read by weapon_capsule_set_kind
	.addr	metasprite_06B0A3
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00, $03, $00
data_05B19C:
	; CDL: read by object_type_11_state_01; partly not accessed
	.addr	metasprite_06B408
	.addr	metasprite_06B403, metasprite_06B3FE, metasprite_06B408, metasprite_06B403
	.addr	metasprite_06B3FE
data_05B1A8:
	; CDL: read by object_type_11_state_01; partly not accessed
	.byte	$FD, $FF, $FC, $FF, $FA, $FF, $FB, $FF, $FD, $FF, $FC, $FF
data_05B1B4:
	; CDL: read by queue_vram_blocks_at_x, object_type_11_state_01; partly not accessed
	.byte	$03, $00, $02, $00, $01, $00, $FF, $FF, $FE, $FF, $FD, $FF
vram_blocks_05B1C0:
	.byte	$A0, $63, $60, $63
	.byte	$E0, $63, $80, $65
; OBJ_HP of update_object_type_12 by difficulty (easy, normal, hard)
object_type_12_hp:
	; CDL: read by object_type_12_state_00
	.word	ENEMY_HP($0004), ENEMY_HP($0006), ENEMY_HP($0008)
data_05B1CE:
	; CDL: read by object_type_12_state_01
	.byte	$60, $00, $40, $00, $10, $00
data_05B1D4:
	; CDL: read by object_type_12_state_05
	.byte	$0C, $00, $F8, $FF
data_05B1D8:
	; CDL: read by object_type_12_state_05; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $FF, $FF, $00, $00, $FF, $FF, $00, $00, $FF, $FF
	.byte	$01, $00, $FE, $FF, $01, $00, $FE, $FF, $01, $00, $FE, $FF, $01, $00, $FE, $FF
	.byte	$02, $00, $FD, $FF, $02, $00, $FD, $FF, $02, $00, $FD, $FF, $02, $00, $FD, $FF
	; CDL: not accessed
	.byte	$03, $00, $FC, $FF, $03, $00, $FC, $FF, $03, $00, $FC, $FF, $03, $00, $FC, $FF
	.byte	$04, $00, $FB, $FF, $04, $00, $FB, $FF, $04, $00, $FB, $FF, $04, $00, $FB, $FF
data_05B228:
	; CDL: read by object_type_12_state_05; partly not accessed
	.byte	$00, $00, $00, $00, $00, $40, $00, $C0, $00, $80, $00, $80, $00, $C0, $00, $40
	.byte	$00, $00, $00, $00, $00, $40, $00, $C0, $00, $80, $00, $80, $00, $C0, $00, $40
	.byte	$00, $00, $00, $00, $00, $40, $00, $C0, $00, $80, $00, $80, $00, $C0, $00, $40
	; CDL: not accessed
	.byte	$00, $00, $00, $00, $00, $40, $00, $C0, $00, $80, $00, $80, $00, $C0, $00, $40
	.byte	$00, $00, $00, $00, $00, $40, $00, $C0, $00, $80, $00, $80, $00, $C0, $00, $40
data_05B278:
	; CDL: read by object_type_12_state_01
	.addr	metasprite_06B1F0, metasprite_06B4AA
data_05B27C:
	; CDL: read by object_type_12_state_03
	.addr	metasprite_06B205, metasprite_06B4BF
data_05B280:
	; CDL: read by update_objects, object_type_12_state_05
	.addr	metasprite_06B21A, metasprite_06B4D4
anim_05B284:
	anim_frame	$0006, metasprite_06AE91, metasprite_06AE91
	anim_frame	$0006, metasprite_06AE96, metasprite_06AE96
	anim_frame	$0006, metasprite_06AFBE, metasprite_06AFBE
	anim_frame	$0006, metasprite_06AFC3, metasprite_06AFC3
	anim_goto	anim_05B284
; Player frames, 16 bytes each (index PLAYER_POSE + PLAYER_POSE_ADD + $38):
; six VRAM source addresses of the tiles, then the metasprite facing right
; and left (set_player_frame).
player_frames:
	; CDL: read by set_player_frame
	player_frame	$0000, $0040, $0080, $00C0, $0100, $0140, metasprite_068510, metasprite_0698CA
	player_frame	$0180, $01C0, $0400, $00C0, $0100, $0140, metasprite_068529, metasprite_0698E3
	player_frame	$0000, $0440, $0080, $0480, $04C0, $0000, metasprite_068542, metasprite_0698FC
	player_frame	$0000, $0440, $0080, $0480, $04C0, $0000, metasprite_068542, metasprite_0698FC
	player_frame	$0500, $0540, $0580, $05C0, $0800, $0840, metasprite_068557, metasprite_069911
	player_frame	$0500, $0540, $0580, $05C0, $0800, $0840, metasprite_068557, metasprite_069911
	player_frame	$0880, $0540, $0580, $08C0, $0900, $0940, metasprite_068570, metasprite_06992A
	player_frame	$0880, $0540, $0580, $08C0, $0900, $0940, metasprite_068570, metasprite_06992A
	player_frame	$0000, $0440, $0080, $0980, $09C0, $0000, metasprite_068589, metasprite_069943
	player_frame	$0000, $0440, $0080, $0980, $09C0, $0000, metasprite_068589, metasprite_069943
	player_frame	$0C00, $0C40, $0C80, $0CC0, $0D00, $0D40, metasprite_06859E, metasprite_069958
	player_frame	$0C00, $0C40, $0C80, $0CC0, $0D00, $0D40, metasprite_06859E, metasprite_069958
	player_frame	$0D80, $0C40, $0C80, $0DC0, $1000, $1040, metasprite_0685B7, metasprite_069971
	player_frame	$0D80, $0C40, $0C80, $0DC0, $1000, $1040, metasprite_0685B7, metasprite_069971
	player_frame	$0000, $0040, $0080, $0480, $04C0, $0000, metasprite_068614, metasprite_0699CE
	player_frame	$0180, $01C0, $0400, $0480, $04C0, $0000, metasprite_0686A2, metasprite_069A5C
	player_frame	$0000, $0040, $0080, $05C0, $0800, $0840, metasprite_068629, metasprite_0699E3
	player_frame	$0180, $01C0, $0400, $05C0, $0800, $0840, metasprite_0686B7, metasprite_069A71
	player_frame	$0000, $0040, $0080, $08C0, $0900, $0940, metasprite_068642, metasprite_0699FC
	player_frame	$0180, $01C0, $0400, $08C0, $0900, $0940, metasprite_0686D0, metasprite_069A8A
	player_frame	$0000, $0040, $0080, $0980, $09C0, $0000, metasprite_06865B, metasprite_069A15
	player_frame	$0180, $01C0, $0400, $0980, $09C0, $0000, metasprite_0686E9, metasprite_069AA3
	player_frame	$0000, $0040, $0080, $0CC0, $0D00, $0D40, metasprite_068670, metasprite_069A2A
	player_frame	$0180, $01C0, $0400, $0CC0, $0D00, $0D40, metasprite_0686FE, metasprite_069AB8
	player_frame	$0000, $0040, $0080, $0DC0, $1000, $1040, metasprite_068689, metasprite_069A43
	player_frame	$0180, $01C0, $0400, $0DC0, $1000, $1040, metasprite_068717, metasprite_069AD1
	player_frame	$1800, $1840, $00C0, $0100, $0140, $0000, metasprite_06884C, metasprite_069C06
	player_frame	$1800, $1880, $00C0, $0100, $0140, $1040, metasprite_068861, metasprite_069C1B
	player_frame	$18C0, $1900, $1940, $00C0, $0100, $0140, metasprite_0688A8, metasprite_069C62
	player_frame	$1980, $1900, $19C0, $00C0, $0100, $0140, metasprite_0688C1, metasprite_069C7B
	; CDL: read by set_player_frame
	player_frame	$18C0, $1900, $1940, $0480, $04C0, $0000, metasprite_0688DA, metasprite_069C94
	player_frame	$1980, $1900, $19C0, $0480, $04C0, $0000, metasprite_068968, metasprite_069D22
	player_frame	$18C0, $1900, $1940, $05C0, $0800, $0840, metasprite_0688EF, metasprite_069CA9
	player_frame	$1980, $1900, $19C0, $05C0, $0800, $0840, metasprite_06897D, metasprite_069D37
	player_frame	$18C0, $1900, $1940, $08C0, $0900, $0940, metasprite_068908, metasprite_069CC2
	player_frame	$1980, $1900, $19C0, $08C0, $0900, $0940, metasprite_068996, metasprite_069D50
	player_frame	$18C0, $1900, $1940, $0980, $09C0, $0000, metasprite_068921, metasprite_069CDB
	player_frame	$1980, $1900, $19C0, $0980, $09C0, $0000, metasprite_0689AF, metasprite_069D69
	player_frame	$18C0, $1900, $1940, $0CC0, $0D00, $0D40, metasprite_068936, metasprite_069CF0
	player_frame	$1980, $1900, $19C0, $0CC0, $0D00, $0D40, metasprite_0689C4, metasprite_069D7E
	player_frame	$18C0, $1900, $1940, $0DC0, $1000, $1040, metasprite_06894F, metasprite_069D09
	player_frame	$1980, $1900, $19C0, $0DC0, $1000, $1040, metasprite_0689DD, metasprite_069D97
	player_frame	$5400, $5440, $5480, $0000, $0000, $0000, metasprite_068D94, metasprite_06A14E
	player_frame	$5400, $54C0, $5480, $0100, $0140, $1040, metasprite_068DA1, metasprite_06A15B
	; CDL: not accessed
	player_frame	$1480, $14C0, $1500, $00C0, $0100, $0140, metasprite_068876, metasprite_069C30
	player_frame	$1540, $1580, $15C0, $00C0, $0100, $0140, metasprite_06888F, metasprite_069C49
	player_frame	$1480, $14C0, $1500, $0480, $04C0, $0000, metasprite_068730, metasprite_069AEA
	player_frame	$1540, $1580, $15C0, $0480, $04C0, $0000, metasprite_0687BE, metasprite_069B78
	player_frame	$1480, $14C0, $1500, $05C0, $0800, $0840, metasprite_068745, metasprite_069AFF
	player_frame	$1540, $1580, $15C0, $05C0, $0800, $0840, metasprite_0687D3, metasprite_069B8D
	player_frame	$1480, $14C0, $1500, $08C0, $0900, $0940, metasprite_06875E, metasprite_069B18
	player_frame	$1540, $1580, $15C0, $08C0, $0900, $0940, metasprite_0687EC, metasprite_069BA6
	player_frame	$1480, $14C0, $1500, $0980, $09C0, $0000, metasprite_068777, metasprite_069B31
	player_frame	$1540, $1580, $15C0, $0980, $09C0, $0000, metasprite_068805, metasprite_069BBF
	player_frame	$1480, $14C0, $1500, $0CC0, $0D00, $0D40, metasprite_06878C, metasprite_069B46
	player_frame	$1540, $1580, $15C0, $0CC0, $0D00, $0D40, metasprite_06881A, metasprite_069BD4
	player_frame	$1480, $14C0, $1500, $0DC0, $1000, $1040, metasprite_0687A5, metasprite_069B5F
	player_frame	$1540, $1580, $15C0, $0DC0, $1000, $1040, metasprite_068833, metasprite_069BED
	player_frame	$1080, $10C0, $1100, $1140, $0000, $0000, metasprite_0685D0, metasprite_06998A
	player_frame	$1180, $11C0, $1400, $1440, $0000, $0000, metasprite_0685E1, metasprite_06999B
	player_frame	$1080, $10C0, $1100, $1140, $0000, $0000, metasprite_0685F2, metasprite_0699AC
	player_frame	$1180, $11C0, $1400, $1440, $0000, $0000, metasprite_068603, metasprite_0699BD
	player_frame	$28C0, $2900, $2940, $2980, $29C0, $2C00, metasprite_068AE8, metasprite_069EA2
	player_frame	$2C40, $2C80, $2CC0, $2D00, $0000, $0000, metasprite_068B01, metasprite_069EBB
	player_frame	$2D40, $2D80, $29C0, $2C00, $0000, $0000, metasprite_068B12, metasprite_069ECC
	player_frame	$2C40, $2C80, $2CC0, $2D00, $0000, $0000, metasprite_068B01, metasprite_069EBB
	player_frame	$2DC0, $3000, $3040, $3080, $29C0, $2C00, metasprite_068B23, metasprite_069EDD
	player_frame	$30C0, $3100, $2CC0, $2D00, $0000, $0000, metasprite_068B3C, metasprite_069EF6
	player_frame	$3140, $3180, $29C0, $2C00, $0000, $0000, metasprite_068B4D, metasprite_069F07
	player_frame	$30C0, $3100, $2CC0, $2D00, $0000, $0000, metasprite_068B3C, metasprite_069EF6
	player_frame	$31C0, $3400, $3440, $3480, $29C0, $2C00, metasprite_068B5E, metasprite_069F18
	player_frame	$34C0, $3500, $2CC0, $2D00, $0000, $0000, metasprite_068B77, metasprite_069F31
	player_frame	$3540, $3580, $29C0, $2C00, $0000, $0000, metasprite_068B88, metasprite_069F42
	player_frame	$34C0, $3500, $2CC0, $2D00, $0000, $0000, metasprite_068B77, metasprite_069F31
	player_frame	$1C00, $1C80, $1CC0, $1C40, $1D00, $1D40, metasprite_0689F6, metasprite_069DB0
	player_frame	$1C00, $1D80, $1CC0, $1C40, $1D00, $1D40, metasprite_068A0F, metasprite_069DC9
	player_frame	$1DC0, $20C0, $2100, $1C40, $1D00, $1D40, metasprite_068A28, metasprite_069DE2
	player_frame	$1DC0, $20C0, $2140, $1C40, $1D00, $1D40, metasprite_068A41, metasprite_069DFB
	player_frame	$2180, $21C0, $2400, $2440, $2480, $0000, metasprite_068A8C, metasprite_069E46
	player_frame	$2180, $24C0, $2500, $2540, $2580, $0000, metasprite_068AA1, metasprite_069E5B
	player_frame	$2180, $25C0, $1C40, $2800, $1D40, $2000, metasprite_068AB6, metasprite_069E70
	player_frame	$2180, $2840, $1C40, $2880, $1D40, $2000, metasprite_068ACF, metasprite_069E89
	player_frame	$1DC0, $2000, $2040, $1C40, $1D00, $1D40, metasprite_068A5A, metasprite_069E14
	player_frame	$1DC0, $2000, $2080, $1C40, $1D00, $1D40, metasprite_068A73, metasprite_069E2D
	player_frame	$35C0, $3800, $3840, $0000, $0000, $0000, metasprite_068B99, metasprite_069F53
	player_frame	$3880, $38C0, $3900, $0000, $0000, $0000, metasprite_068BA6, metasprite_069F60
	player_frame	$3940, $3980, $39C0, $0000, $0000, $0000, metasprite_068BB3, metasprite_069F6D
	player_frame	$3880, $38C0, $3900, $0000, $0000, $0000, metasprite_068BA6, metasprite_069F60
	; CDL: read by set_player_frame
	player_frame	$3C00, $3C40, $1C80, $1CC0, $3C80, $3CC0, metasprite_068BC0, metasprite_069F7A
	player_frame	$3C00, $3C40, $1D80, $1CC0, $3C80, $3CC0, metasprite_068BD9, metasprite_069F93
	player_frame	$3D00, $3D40, $20C0, $2100, $3C80, $3CC0, metasprite_068C24, metasprite_069FDE
	player_frame	$3D00, $3D40, $20C0, $2140, $3C80, $3CC0, metasprite_068C3D, metasprite_069FF7
	; CDL: not accessed
	player_frame	$4140, $4180, $41C0, $4400, $4440, $4480, metasprite_068C88, metasprite_06A042
	player_frame	$44C0, $4180, $4500, $4540, $4580, $45C0, metasprite_068CA1, metasprite_06A05B
	; CDL: read by set_player_frame
	player_frame	$4800, $4840, $1CC0, $4880, $48C0, $3CC0, metasprite_068CBA, metasprite_06A074
	player_frame	$4900, $4840, $1CC0, $4940, $48C0, $3CC0, metasprite_068CD3, metasprite_06A08D
	player_frame	$4980, $49C0, $4C00, $4C40, $48C0, $3CC0, metasprite_068CEC, metasprite_06A0A6
	player_frame	$4980, $4C80, $4C00, $4CC0, $48C0, $3CC0, metasprite_068D05, metasprite_06A0BF
	; CDL: not accessed
	player_frame	$4D00, $4D40, $4D80, $48C0, $4DC0, $3CC0, metasprite_068D1E, metasprite_06A0D8
	player_frame	$5000, $4D40, $5040, $48C0, $4DC0, $3CC0, metasprite_068D37, metasprite_06A0F1
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$3D80, $3DC0, $4000, $4040, $3C80, $3CC0, metasprite_068C56, metasprite_06A010
	player_frame	$4080, $40C0, $4100, $4040, $3C80, $3CC0, metasprite_068C6F, metasprite_06A029
	player_frame	$3D00, $3D40, $2000, $2040, $3C80, $3CC0, metasprite_068BF2, metasprite_069FAC
	player_frame	$3D00, $3D40, $2000, $2080, $3C80, $3CC0, metasprite_068C0B, metasprite_069FC5
	player_frame	$7880, $78C0, $7900, $7940, $7980, $0000, metasprite_068F68, metasprite_06A322
	player_frame	$79C0, $7C00, $7C40, $7940, $7980, $0000, metasprite_068FF6, metasprite_06A3B0
	player_frame	$7880, $78C0, $7900, $7C80, $7CC0, $7D00, metasprite_068F7D, metasprite_06A337
	player_frame	$79C0, $7C00, $7C40, $7C80, $7CC0, $7D00, metasprite_06900B, metasprite_06A3C5
	player_frame	$7880, $78C0, $7900, $7D40, $7D80, $7DC0, metasprite_068F96, metasprite_06A350
	player_frame	$79C0, $7C00, $7C40, $7D40, $7D80, $7DC0, metasprite_069024, metasprite_06A3DE
	player_frame	$7880, $78C0, $7900, $8000, $8040, $0000, metasprite_068FAF, metasprite_06A369
	player_frame	$79C0, $7C00, $7C40, $8000, $8040, $0000, metasprite_06903D, metasprite_06A3F7
	player_frame	$7880, $78C0, $7900, $8080, $80C0, $8100, metasprite_068FC4, metasprite_06A37E
	player_frame	$79C0, $7C00, $7C40, $8080, $80C0, $8100, metasprite_069052, metasprite_06A40C
	player_frame	$7880, $78C0, $7900, $8140, $8180, $81C0, metasprite_068FDD, metasprite_06A397
	player_frame	$79C0, $7C00, $7C40, $8140, $8180, $81C0, metasprite_06906B, metasprite_06A425
	player_frame	$7880, $78C0, $7900, $8580, $85C0, $8800, metasprite_0692B0, metasprite_06A66A
	player_frame	$79C0, $7C00, $7C40, $8580, $85C0, $8800, metasprite_069342, metasprite_06A6FC
	player_frame	$7880, $78C0, $7900, $8840, $8880, $88C0, metasprite_0692C9, metasprite_06A683
	player_frame	$79C0, $7C00, $7C40, $8840, $8880, $88C0, metasprite_06935B, metasprite_06A715
	player_frame	$7880, $78C0, $7900, $8900, $8940, $8980, metasprite_0692E2, metasprite_06A69C
	player_frame	$79C0, $7C00, $7C40, $8900, $8940, $8980, metasprite_069374, metasprite_06A72E
	player_frame	$7880, $78C0, $7900, $89C0, $8C00, $0000, metasprite_0692FB, metasprite_06A6B5
	player_frame	$79C0, $7C00, $7C40, $89C0, $8C00, $0000, metasprite_06938D, metasprite_06A747
	player_frame	$7880, $78C0, $7900, $8C40, $8C80, $8CC0, metasprite_069310, metasprite_06A6CA
	player_frame	$79C0, $7C00, $7C40, $8C40, $8C80, $8CC0, metasprite_0693A2, metasprite_06A75C
	player_frame	$7880, $78C0, $7900, $8D00, $8D40, $8D80, metasprite_069329, metasprite_06A6E3
	player_frame	$79C0, $7C00, $7C40, $8D00, $8D40, $8D80, metasprite_0693BB, metasprite_06A775
	player_frame	$8400, $8440, $8480, $7940, $7980, $0000, metasprite_069084, metasprite_06A43E
	player_frame	$84C0, $8500, $8540, $7940, $7980, $0000, metasprite_069112, metasprite_06A4CC
	player_frame	$8400, $8440, $8480, $7C80, $7CC0, $7D00, metasprite_069099, metasprite_06A453
	player_frame	$84C0, $8500, $8540, $7C80, $7CC0, $7D00, metasprite_069127, metasprite_06A4E1
	player_frame	$8400, $8440, $8480, $7D40, $7D80, $7DC0, metasprite_0690B2, metasprite_06A46C
	player_frame	$84C0, $8500, $8540, $7D40, $7D80, $7DC0, metasprite_069140, metasprite_06A4FA
	player_frame	$8400, $8440, $8480, $8000, $8040, $0000, metasprite_0690CB, metasprite_06A485
	player_frame	$84C0, $8500, $8540, $8000, $8040, $0000, metasprite_069159, metasprite_06A513
	player_frame	$8400, $8440, $8480, $8080, $80C0, $8100, metasprite_0690E0, metasprite_06A49A
	player_frame	$84C0, $8500, $8540, $8080, $80C0, $8100, metasprite_06916E, metasprite_06A528
	player_frame	$8400, $8440, $8480, $8140, $8180, $81C0, metasprite_0690F9, metasprite_06A4B3
	; CDL: read by set_player_frame
	player_frame	$84C0, $8500, $8540, $8140, $8180, $81C0, metasprite_069187, metasprite_06A541
	player_frame	$8400, $8440, $8480, $8580, $85C0, $8800, metasprite_0693D4, metasprite_06A78E
	player_frame	$84C0, $8500, $8540, $8580, $85C0, $8800, metasprite_069466, metasprite_06A820
	player_frame	$8400, $8440, $8480, $8840, $8880, $88C0, metasprite_0693ED, metasprite_06A7A7
	player_frame	$84C0, $8500, $8540, $8840, $8880, $88C0, metasprite_06947F, metasprite_06A839
	player_frame	$8400, $8440, $8480, $8900, $8940, $8980, metasprite_069406, metasprite_06A7C0
	player_frame	$84C0, $8500, $8540, $8900, $8940, $8980, metasprite_069498, metasprite_06A852
	player_frame	$8400, $8440, $8480, $89C0, $8C00, $0000, metasprite_06941F, metasprite_06A7D9
	player_frame	$84C0, $8500, $8540, $89C0, $8C00, $0000, metasprite_0694B1, metasprite_06A86B
	player_frame	$8400, $8440, $8480, $8C40, $8C80, $8CC0, metasprite_069434, metasprite_06A7EE
	player_frame	$84C0, $8500, $8540, $8C40, $8C80, $8CC0, metasprite_0694C6, metasprite_06A880
	player_frame	$8400, $8440, $8480, $8D00, $8D40, $8D80, metasprite_06944D, metasprite_06A807
	player_frame	$84C0, $8500, $8540, $8D00, $8D40, $8D80, metasprite_0694DF, metasprite_06A899
	; CDL: not accessed
	player_frame	$8DC0, $9000, $9040, $9080, $90C0, $0000, metasprite_0691A0, metasprite_06A55A
	player_frame	$9100, $9140, $9180, $91C0, $9400, $0000, metasprite_069222, metasprite_06A5DC
	player_frame	$8DC0, $9440, $9480, $94C0, $9500, $0000, metasprite_0691B5, metasprite_06A56F
	player_frame	$9540, $9580, $95C0, $9800, $9840, $9880, metasprite_069237, metasprite_06A5F1
	player_frame	$8DC0, $98C0, $9900, $9940, $9980, $0000, metasprite_0691CA, metasprite_06A584
	player_frame	$9540, $9580, $99C0, $9800, $9C00, $9C40, metasprite_069250, metasprite_06A60A
	player_frame	$8DC0, $9C80, $9CC0, $9D00, $9D40, $0000, metasprite_0691DF, metasprite_06A599
	player_frame	$9100, $9D80, $9180, $9DC0, $A000, $0000, metasprite_069269, metasprite_06A623
	player_frame	$8DC0, $A040, $A080, $80C0, $A0C0, $0000, metasprite_0691F4, metasprite_06A5AE
	player_frame	$9540, $9580, $A100, $A140, $A180, $A1C0, metasprite_06927E, metasprite_06A638
	player_frame	$8DC0, $A400, $A440, $A480, $A4C0, $A500, metasprite_069209, metasprite_06A5C3
	player_frame	$9100, $A540, $9180, $A580, $A5C0, $A800, metasprite_069297, metasprite_06A651
	player_frame	$8DC0, $A840, $A880, $A8C0, $A900, $0000, metasprite_0694F8, metasprite_06A8B2
	player_frame	$9100, $A940, $9180, $A980, $A9C0, $0000, metasprite_06958A, metasprite_06A944
	player_frame	$AC00, $AC40, $AC80, $ACC0, $8880, $AD00, metasprite_06950D, metasprite_06A8C7
	player_frame	$AD40, $AD80, $ADC0, $B000, $8880, $B040, metasprite_06959F, metasprite_06A959
	player_frame	$AC00, $AC40, $B080, $B0C0, $B100, $B140, metasprite_069526, metasprite_06A8E0
	player_frame	$AD40, $AD80, $B180, $B1C0, $B400, $B440, metasprite_0695B8, metasprite_06A972
	player_frame	$8DC0, $B480, $A880, $B4C0, $B500, $B540, metasprite_06953F, metasprite_06A8F9
	player_frame	$9100, $B580, $9180, $B4C0, $B5C0, $B800, metasprite_0695D1, metasprite_06A98B
	player_frame	$AC00, $AC40, $B840, $B880, $B8C0, $B900, metasprite_069558, metasprite_06A912
	player_frame	$AD40, $AD80, $B940, $B980, $B8C0, $B9C0, metasprite_0695EA, metasprite_06A9A4
	player_frame	$AC00, $AC40, $BC00, $BC40, $B0C0, $BC80, metasprite_069571, metasprite_06A92B
	player_frame	$AD40, $AD80, $BCC0, $BD00, $B1C0, $BD40, metasprite_069603, metasprite_06A9BD
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$0000, $0040, $0080, $5080, $50C0, $5100, metasprite_068DAE, metasprite_06A168
	player_frame	$0180, $01C0, $0400, $5080, $50C0, $5100, metasprite_068DC7, metasprite_06A181
	player_frame	$1800, $1840, $5080, $50C0, $5100, $0000, metasprite_068E44, metasprite_06A1FE
	player_frame	$1800, $1880, $5080, $50C0, $5100, $0000, metasprite_068E59, metasprite_06A213
	player_frame	$18C0, $1900, $1940, $5080, $50C0, $5100, metasprite_068DE0, metasprite_06A19A
	player_frame	$1980, $1900, $19C0, $5080, $50C0, $5100, metasprite_068DF9, metasprite_06A1B3
	; CDL: read by set_player_frame
	player_frame	$5500, $5540, $5580, $55C0, $0000, $0000, metasprite_068D50, metasprite_06A10A
	player_frame	$5800, $5840, $5880, $58C0, $0000, $0000, metasprite_068D61, metasprite_06A11B
	; CDL: not accessed
	player_frame	$1480, $14C0, $1500, $5080, $50C0, $5100, metasprite_068E12, metasprite_06A1CC
	player_frame	$1540, $1580, $15C0, $5080, $50C0, $5100, metasprite_068E2B, metasprite_06A1E5
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$0000, $0040, $0080, $5140, $5180, $51C0, metasprite_068E6E, metasprite_06A228
	player_frame	$0180, $01C0, $0400, $5140, $5180, $51C0, metasprite_068E87, metasprite_06A241
	player_frame	$1800, $1840, $5140, $5180, $51C0, $0000, metasprite_068F04, metasprite_06A2BE
	player_frame	$1800, $1880, $5140, $5180, $51C0, $0000, metasprite_068F19, metasprite_06A2D3
	player_frame	$18C0, $1900, $1940, $5140, $5180, $51C0, metasprite_068EA0, metasprite_06A25A
	player_frame	$1980, $1900, $19C0, $5140, $5180, $51C0, metasprite_068EB9, metasprite_06A273
	; CDL: read by set_player_frame
	player_frame	$5500, $5540, $5900, $5940, $0000, $0000, metasprite_068D72, metasprite_06A12C
	player_frame	$5800, $5840, $5980, $59C0, $0000, $0000, metasprite_068D83, metasprite_06A13D
	; CDL: not accessed
	player_frame	$1480, $14C0, $1500, $5140, $5180, $51C0, metasprite_068ED2, metasprite_06A28C
	player_frame	$1540, $1580, $15C0, $5140, $5180, $51C0, metasprite_068EEB, metasprite_06A2A5
	; CDL: read by set_player_frame
	player_frame	$5C00, $5C40, $5C80, $5CC0, $0000, $0000, metasprite_068F2E, metasprite_06A2E8
	player_frame	$5C00, $5C40, $6800, $6840, $6880, $68C0, metasprite_06A305, metasprite_068F4B
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$6100, $6140, $6180, $61C0, $5CC0, $0000, $0000, $0000
	player_frame	$5D00, $5D40, $5D80, $5DC0, $6000, $5CC0, $0000, $0000
	player_frame	$64C0, $6500, $6540, $5CC0, $6580, $65C0, $0000, $0000
	player_frame	$6400, $6440, $6480, $0000, $0000, $0000, $0000, $0000
	player_frame	$5C00, $5C40, $6800, $6840, $6880, $68C0, metasprite_068F4B, metasprite_06A305
	; CDL: not accessed
	player_frame	$6040, $6080, $70C0, $7100, $6880, $68C0, $0000, $0000
	player_frame	$6D00, $6D40, $6D80, $6DC0, $6880, $68C0, $0000, $0000
	player_frame	$6900, $6940, $6980, $69C0, $6C00, $6C40, $0000, $0000
	player_frame	$7440, $7480, $74C0, $7500, $7540, $0000, $0000, $0000
	player_frame	$6400, $7140, $7180, $71C0, $7400, $0000, $0000, $0000
	player_frame	$64C0, $7580, $75C0, $7800, $7840, $68C0, $0000, $0000
	player_frame	$6900, $6940, $6980, $6C80, $6CC0, $6C00, $0000, $0000
	player_frame	$6D00, $6D40, $7000, $7040, $7080, $6880, $0000, $0000
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$7880, $78C0, $7900, $C000, $C040, $0000, metasprite_06961C, metasprite_06A9D6
	player_frame	$79C0, $7C00, $7C40, $C000, $C040, $0000, metasprite_069631, metasprite_06A9EB
	player_frame	$8400, $8440, $8480, $C000, $C040, $C040, metasprite_069668, metasprite_06AA22
	player_frame	$84C0, $8500, $8540, $C000, $C040, $C040, metasprite_06967D, metasprite_06AA37
	player_frame	$1800, $1840, $C000, $C040, $C040, $0000, metasprite_069646, metasprite_06AA00
	player_frame	$1800, $1880, $C000, $C040, $C040, $0000, metasprite_069657, metasprite_06AA11
	player_frame	$C080, $C0C0, $C100, $C000, $C040, $C040, metasprite_069692, metasprite_06AA4C
	; CDL: read by set_player_frame
	player_frame	$C140, $C180, $C1C0, $C000, $C040, $C040, metasprite_0696A7, metasprite_06AA61
	player_frame	$C400, $C440, $C480, $C4C0, $C500, $C540, metasprite_0696BC, metasprite_06AA76
	player_frame	$C580, $C440, $C5C0, $C4C0, $C800, $C540, metasprite_0696D5, metasprite_06AA8F
	player_frame	$1800, $1840, $0980, $09C0, $0000, $0000, metasprite_0696EE, metasprite_06AAA8
	player_frame	$1800, $1880, $0980, $09C0, $0000, $0000, metasprite_0696FF, metasprite_06AAB9
	; CDL: read by set_player_frame; partly not accessed
	player_frame	$C840, $C880, $C8C0, $C900, $C940, $0140, metasprite_06973A, metasprite_06AAF4
	player_frame	$C980, $C9C0, $CC00, $CC40, $CC80, $0140, metasprite_069753, metasprite_06AB0D
	player_frame	$C840, $C880, $D1C0, $D400, $D440, $0000, metasprite_069710, metasprite_06AACA
	player_frame	$C980, $C9C0, $D480, $D4C0, $D500, $0000, metasprite_069725, metasprite_06AADF
	player_frame	$C840, $C880, $CCC0, $CD00, $CD40, $5100, metasprite_06976C, metasprite_06AB26
	player_frame	$C980, $C9C0, $CD80, $CDC0, $D000, $5100, metasprite_069785, metasprite_06AB3F
	player_frame	$C840, $C880, $D040, $D080, $D0C0, $51C0, metasprite_06979E, metasprite_06AB58
	player_frame	$C980, $C9C0, $D100, $D140, $D180, $51C0, metasprite_0697B7, metasprite_06AB71
	player_frame	$D540, $D580, $0000, $0000, $0000, $0000, metasprite_06AC84, metasprite_06AC84
	; CDL: read by set_player_frame
	player_frame	$E440, $E480, $E4C0, $E500, $E540, $E580, metasprite_06AC8D, metasprite_06ACF7
	player_frame	$E5C0, $E800, $E840, $E880, $0000, $0000, metasprite_06ACA6, metasprite_06AD10
	player_frame	$E8C0, $E900, $E940, $E980, $0000, $0000, metasprite_06ACB7, metasprite_06AD21
	player_frame	$E5C0, $E800, $E840, $E880, $0000, $0000, metasprite_06ACC8, metasprite_06AD32
	player_frame	$E8C0, $E900, $E940, $E980, $0000, $0000, metasprite_06ACD9, metasprite_06AD43
	player_frame	$E9C0, $EC00, $EC40, $0000, $0000, $0000, metasprite_06ACEA, metasprite_06AD54
	player_frame	$D540, $D580, $0000, $0000, $0000, $0000, metasprite_06AC84, metasprite_06AC84
	player_frame	$D540, $D580, $0000, $0000, $0000, $0000, metasprite_06AC84, metasprite_06AC84
	player_frame	$D5C0, $ECC0, $0000, $0000, $0000, $0000, metasprite_06CBB0, metasprite_06CBB0
	player_frame	$D800, $ED40, $0000, $0000, $0000, $0000, metasprite_06CBD9, metasprite_06CBD9
	player_frame	$ED00, $ECC0, $0000, $0000, $0000, $0000, metasprite_06CBB0, metasprite_06CBB0
	player_frame	$ED80, $ED40, $0000, $0000, $0000, $0000, metasprite_06CBD9, metasprite_06CBD9
	player_frame	$E000, $E100, $E0C0, $1CC0, $0000, $0000, metasprite_06CD9A, metasprite_06CD9A
	player_frame	$E080, $EC80, $E0C0, $1CC0, $0000, $0000, metasprite_06CDCB, metasprite_06CDCB
	player_frame	$F000, $EDC0, $E0C0, $1CC0, $0000, $0000, metasprite_06CD9A, metasprite_06CD9A
	player_frame	$F080, $F040, $E0C0, $1CC0, $0000, $0000, metasprite_06CDCB, metasprite_06CDCB
	player_frame	$D880, $D840, $2100, $20C0, $0000, $0000, metasprite_06CC02, metasprite_06CC02
	player_frame	$D880, $D840, $2140, $20C0, $0000, $0000, metasprite_06CC33, metasprite_06CC33
	player_frame	$D8C0, $D840, $2100, $20C0, $0000, $0000, metasprite_06CC02, metasprite_06CC02
	player_frame	$D8C0, $D840, $2140, $20C0, $0000, $0000, metasprite_06CC33, metasprite_06CC33
	player_frame	$DD00, $D840, $DD80, $4980, $0000, $0000, metasprite_06CDFC, metasprite_06CDFC
	player_frame	$DD00, $D840, $DDC0, $4980, $0000, $0000, metasprite_06CE2D, metasprite_06CE2D
	player_frame	$DD40, $D840, $DD80, $4980, $0000, $0000, metasprite_06CDFC, metasprite_06CDFC
	player_frame	$DD40, $D840, $DDC0, $4980, $0000, $0000, metasprite_06CE2D, metasprite_06CE2D
	player_frame	$D880, $D840, $2040, $2000, $0000, $0000, metasprite_06CC64, metasprite_06CC64
	player_frame	$D880, $D840, $2080, $2000, $0000, $0000, metasprite_06CC95, metasprite_06CC95
	player_frame	$D8C0, $D840, $2040, $2000, $0000, $0000, metasprite_06CC64, metasprite_06CC64
	player_frame	$D8C0, $D840, $2080, $2000, $0000, $0000, metasprite_06CC95, metasprite_06CC95
	player_frame	$D900, $D840, $25C0, $DC80, $2000, $0000, metasprite_06CD30, metasprite_06CD30
	player_frame	$D900, $D840, $2840, $DCC0, $2000, $0000, metasprite_06CD65, metasprite_06CD65
	player_frame	$D940, $D840, $25C0, $DC80, $2000, $0000, metasprite_06CD30, metasprite_06CD30
	player_frame	$D940, $D840, $2840, $DCC0, $2000, $0000, metasprite_06CD65, metasprite_06CD65
	player_frame	$D900, $D840, $D980, $D9C0, $DC00, $0000, metasprite_06CCC6, metasprite_06CCC6
	player_frame	$D900, $D840, $DC40, $D9C0, $DC00, $0000, metasprite_06CCFB, metasprite_06CCFB
	player_frame	$D940, $D840, $D980, $D9C0, $DC00, $0000, metasprite_06CCC6, metasprite_06CCC6
	player_frame	$D940, $D840, $DC40, $D9C0, $DC00, $0000, metasprite_06CCFB, metasprite_06CCFB
	player_frame	$E140, $E040, $E0C0, $E1C0, $4DC0, $0000, metasprite_06CE5E, metasprite_06CE5E
	player_frame	$E140, $E040, $E0C0, $E400, $4DC0, $0000, metasprite_06CE93, metasprite_06CE93
	player_frame	$E180, $E040, $E0C0, $E1C0, $4DC0, $0000, metasprite_06CE5E, metasprite_06CE5E
	player_frame	$E180, $E040, $E0C0, $E400, $4DC0, $0000, metasprite_06CE93, metasprite_06CE93
	player_frame	$5D00, $5D40, $5D80, $5DC0, $0100, $0140, metasprite_0697D0, metasprite_06AB8A
	player_frame	$6000, $5D40, $5D80, $5DC0, $0100, $0140, metasprite_0697E9, metasprite_06ABA3
	player_frame	$6040, $5D40, $5D80, $5DC0, $0100, $0140, metasprite_069802, metasprite_06ABBC
	player_frame	$6080, $60C0, $4980, $DD80, $0100, $0140, metasprite_06981B, metasprite_06ABD5
	player_frame	$6100, $6140, $4980, $DD80, $0100, $0140, metasprite_069834, metasprite_06ABEE
	player_frame	$6180, $61C0, $4980, $DD80, $0100, $0140, metasprite_06984D, metasprite_06AC07
	player_frame	$6080, $60C0, $6400, $6440, $0100, $0140, metasprite_069866, metasprite_06AC20
	player_frame	$6100, $6140, $6400, $6440, $0100, $0140, metasprite_06987F, metasprite_06AC39
	player_frame	$6180, $61C0, $6400, $6440, $0100, $0140, metasprite_069898, metasprite_06AC52
	player_frame	$6480, $64C0, $6500, $6540, $0100, $0140, metasprite_0698B1, metasprite_06AC6B
; OBJ_HP of update_window_sniper by difficulty (easy, normal, hard)
window_sniper_hp:
	; CDL: read by window_sniper_state_00
	.word	ENEMY_HP($0004), ENEMY_HP($0006), ENEMY_HP($0008)
data_05C444:
	; CDL: read by window_sniper_state_01
	.byte	$50, $00, $40, $00, $10, $00
data_05C44A:
	; CDL: read by window_sniper_aim_at_nearest_player
	.byte	$00, $02, $40, $02
data_05C44E:
	; CDL: read by window_sniper_state_03; partly not accessed
	.byte	$06, $00, $00, $00, $1A, $00, $1A, $00, $24, $00, $24, $00, $1A, $00, $1A, $00
	.byte	$02, $00, $06, $00, $EE, $FF, $EE, $FF, $E2, $FF, $E2, $FF, $F0, $FF, $F0, $FF
data_05C46E:
	; CDL: read by window_sniper_state_03; partly not accessed
	.byte	$CA, $FF, $CA, $FF, $D9, $FF, $D9, $FF, $EE, $FF, $EE, $FF, $06, $00, $06, $00
	.byte	$12, $00, $12, $00, $06, $00, $06, $00, $EF, $FF, $EF, $FF, $DB, $FF, $DB, $FF
data_05C48E:
	; CDL: read by window_sniper_set_aim_sprite; partly not accessed
	.addr	metasprite_06B22F, metasprite_06B4E9, metasprite_06B259, metasprite_06B513
	.addr	metasprite_06B283, metasprite_06B53D, metasprite_06B2AD, metasprite_06B567
	.addr	metasprite_06B2D7, metasprite_06B591, metasprite_06B2AD, metasprite_06B567
	.addr	metasprite_06B283, metasprite_06B53D, metasprite_06B259, metasprite_06B513
data_05C4AE:
	; CDL: read by update_objects, window_sniper_set_fire_sprite, update_effect; partly not accessed
	.addr	metasprite_06B244, metasprite_06B4FE, metasprite_06B26E, metasprite_06B528
	.addr	metasprite_06B298, metasprite_06B552, metasprite_06B2C2, metasprite_06B57C
	.addr	metasprite_06B2EC, metasprite_06B5A6, metasprite_06B2C2, metasprite_06B57C
	.addr	metasprite_06B298, metasprite_06B552, metasprite_06B244, metasprite_06B4FE
anim_05C4CE:
	anim_frame	$0001, metasprite_06AFEA, $3200
	anim_frame	$0001, metasprite_06AFD9, $3200
	anim_frame	$0002, metasprite_06AEA5, $3200
	anim_frame	$0002, metasprite_06AFC8, $3E00
	anim_frame	$0002, metasprite_06AECF, $3E00
	anim_frame	$0002, metasprite_06AF11, $3E00
	anim_frame	$0002, metasprite_06AEE5, $3E00
	anim_frame	$0002, metasprite_06AEF6, $3E00
	anim_frame	$0001, metasprite_06AF22, $3E00
	anim_frame	$0001, metasprite_06AFFB, $3E00
	anim_frame	$0002, metasprite_06B04B, $3C00
	anim_end	$0000, $0000
anim_05C516:
	anim_frame	$0001, metasprite_06AFEA, $3200
anim_05C51C:
	anim_frame	$0002, metasprite_06AFD9, $3200
	anim_frame	$0003, metasprite_06AEA5, $3200
	anim_frame	$0002, metasprite_06AFC8, $3E00
	anim_frame	$0002, metasprite_06AECF, $3E00
	anim_frame	$0002, metasprite_06AF11, $3E00
	anim_frame	$0001, metasprite_06AEE5, $3E00
anim_05C540:
	anim_frame	$0001, metasprite_06AEF6, $3E00
	anim_frame	$0001, metasprite_06AF22, $3E00
	anim_frame	$0001, metasprite_06AFFB, $3E00
	anim_end	$0000, $0000
anim_05C558:
	anim_frame	$0001, metasprite_06AEA0, $3200
	anim_frame	$0005, metasprite_06AFD9, $3200
	anim_frame	$0003, metasprite_06AEA5, $3200
	anim_frame	$0003, metasprite_06AEA5, $3E00
	anim_frame	$0001, metasprite_06AFC8, $3E00
	anim_frame	$0001, metasprite_06AECF, $3E00
	anim_frame	$0001, metasprite_06AF11, $3E00
	anim_frame	$0001, metasprite_06AEE5, $3E00
	anim_frame	$0001, metasprite_06AEF6, $3E00
	anim_frame	$0001, metasprite_06AF22, $3E00
	anim_end	$0000, $0000
anim_05C59A:
	anim_frame	$0002, metasprite_06AE9B, $3200
	anim_frame	$0002, metasprite_06AEC5, $3000
	anim_frame	$0003, metasprite_06AECA, $3000
	anim_frame	$0002, metasprite_06AEE0, $3000
	anim_end	metasprite_06AEE0, $3000
anim_05C5B8:
	anim_frame	$0002, metasprite_06AE9B, $3200
	anim_frame	$0003, metasprite_06AEA0, $3E00
	anim_frame	$0004, metasprite_06AEB6, $3000
	anim_frame	$0003, metasprite_06AEBB, $3000
	anim_frame	$0002, metasprite_06AF0C, $3C00
	anim_end	$0000, $3000
anim_05C5DC:
	anim_frame	$0001, metasprite_06AFD9, $3E00
	anim_frame	$0001, metasprite_06AEA5, $3E00
	anim_end	$0000, $0000
anim_05C5EE:
	anim_frame	$0002, metasprite_06AFEA, $3200
	anim_frame	$0004, metasprite_06AFD9, $3200
	anim_frame	$0004, metasprite_06AEA5, $3E00
	anim_end	metasprite_06AFD9, $3000
anim_05C606:
	anim_frame	$0001, metasprite_06AFD9, $3200
	anim_frame	$0001, metasprite_06AEA5, $3E00
	anim_frame	$0001, metasprite_06B03A, $3C00
	anim_end	$0000, $0000
anim_05C61E:
	anim_frame	$0001, metasprite_06AFD9, $3000
	anim_frame	$0001, metasprite_06AEA5, $3000
	anim_frame	$0001, metasprite_06B03A, $3000
	anim_end	$0000, $0000
anim_05C636:
	anim_frame	$0005, metasprite_06AEA0, $3000
	anim_frame	$0005, metasprite_06AE9B, $3E00
	anim_frame	$0005, metasprite_06AEA0, $3000
	anim_frame	$0005, metasprite_06AE9B, $3E00
	anim_frame	$0005, metasprite_06AEA0, $3000
	anim_end	$0000, $0000
	.byte	$02, $00, $0C, $AF
	.byte	$00, $32, $02, $00, $0C, $AF, $00, $3E, $01, $00, $0C, $AF, $00, $3C, $00, $00
	.byte	$0C, $AF, $00, $3C
anim_05C672:
	anim_frame	$0001, metasprite_06B03A, $3200
	anim_frame	$0003, metasprite_06B03A, $3E00
	anim_frame	$0002, metasprite_06B04B, $3C00
	anim_end	metasprite_06B04B, $3C00
anim_05C68A:
	anim_frame	$0002, metasprite_06AF55, $3C00
	anim_frame	$0002, metasprite_06AF55, $3E00
	anim_end	metasprite_06AF55, $3E00
anim_05C69C:
	anim_frame	$0002, metasprite_06AEC5, $3E00
	anim_frame	$0003, metasprite_06AECA, $3E00
	anim_frame	$0004, metasprite_06AF33, $3E00
	anim_frame	$0005, metasprite_06AF44, $3E00
	anim_end	metasprite_06AF44, $3E00
anim_05C6BA:
	anim_frame	$0002, metasprite_06AF07, $3000
	anim_frame	$0002, metasprite_06B0B4, $3E00
	anim_frame	$0002, metasprite_06AF07, $3000
	anim_frame	$0002, metasprite_06B0B4, $3E00
	anim_frame	$0002, metasprite_06AF07, $3000
	anim_end	$0000, $0000
anim_05C6DE:
	anim_frame	$0008, metasprite_06B14E, $3200
	anim_frame	$0008, metasprite_06B14E, $3E00
anim_05C6EA:
	anim_frame	$0008, metasprite_06B14E, $3200
	anim_frame	$0008, metasprite_06B14E, $3E00
	anim_frame	$0008, metasprite_06B14E, $3200
	anim_frame	$0008, metasprite_06B14E, $3000
anim_05C702:
	anim_frame	$0008, metasprite_06B14E, $3200
	anim_frame	$0008, metasprite_06B14E, $3000
; OBJ_HP of update_alien_dog (the first 3 words; other data follows) by difficulty (easy, normal, hard)
.if CHEAT_ENEMY_HP = 100
alien_dog_hp:
.endif
	; CDL: read by update_objects, alien_dog_state_02; partly not accessed
	anim_end	$0002, $0008	; cheats: see cheat_enemy_hp_tables
anim_05C714:
	anim_frame	$0060, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_frame	$0008, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_frame	$0020, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_frame	$0008, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_frame	$0008, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_goto	anim_05C714
anim_05C752:
	anim_frame	$0040, metasprite_06B323, metasprite_06B323
	anim_frame	$0008, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_frame	$0020, metasprite_06B323, metasprite_06B323
	anim_frame	$0008, metasprite_06B301, metasprite_06B301
	anim_frame	$0008, metasprite_06B312, metasprite_06B312
	anim_goto	anim_05C752
anim_05C778:
	anim_frame	$0006, metasprite_06B334, metasprite_06B334
	anim_frame	$0008, metasprite_06B345, metasprite_06B345
	anim_frame	$0006, metasprite_06B356, metasprite_06B356
	anim_goto	anim_05C778
anim_05C78C:
	anim_end	metasprite_06B363, metasprite_06B363
data_05C792:
	; CDL: read by enemy_bullet_cycle_palette
	.byte	$00, $30, $00, $32, $00, $3E, $00, $30
data_05C79A:
	; CDL: read by update_dying_soldier
	.addr	metasprite_06B1D6, metasprite_06B490
data_05C79E:
	; CDL: read by update_dying_soldier
	.byte	$FF, $FF, $00, $00
data_05C7A2:
	; CDL: read by update_dying_soldier; partly not accessed
	.byte	$00, $80, $00, $80
anim_05C7A6:
	anim_frame	$0006, metasprite_06AF33, metasprite_06AF33
	anim_frame	$0004, metasprite_06AEE5, metasprite_06AEE5
	anim_frame	$0002, metasprite_06AEF6, metasprite_06AEF6
	anim_end	$0000, $0000
	.byte	$02, $00, $C5, $AE
	.byte	$C5, $AE, $02, $00, $CA, $AE, $CA, $AE, $02, $00, $33, $AF, $33, $AF, $02, $00
	.byte	$E5, $AE, $E5, $AE, $02, $00, $F6, $AE, $F6, $AE, $00, $00, $00, $00, $00, $00
data_05C7E2:
	; CDL: read by update_objects, update_object_type_2F; partly not accessed
	.byte	$80, $00, $70, $00, $60, $00
anim_05C7E8:
	anim_frame	$0006, metasprite_06B5D6, metasprite_06B61A
	anim_frame	$0006, metasprite_06B5E7, metasprite_06B62B
	anim_frame	$0006, metasprite_06B5F8, metasprite_06B63C
	anim_frame	$0006, metasprite_06B609, metasprite_06B64D
	anim_goto	anim_05C7E8
anim_05C802:
	anim_frame	$0002, metasprite_06B65E, metasprite_06B61A
	anim_frame	$0002, metasprite_06B663, metasprite_06B62B
	anim_frame	$0002, metasprite_06B668, metasprite_06B63C
	anim_frame	$0002, metasprite_06B66D, metasprite_06B64D
	anim_goto	anim_05C802
data_05C81C:
	; CDL: read by update_object_type_31
	.word	ENEMY_HP($0010), ENEMY_HP($0040), ENEMY_HP($7FFF)
data_05C822:
	; CDL: read by update_object_type_2C
	.byte	$00, $00, $10, $00, $20, $00
data_05C828:
	; CDL: read by shake_and_explode_state
	.byte	$04, $00, $FF, $FF, $01, $00, $FE, $FF, $02, $00, $FC, $FF, $03, $00, $FD, $FF
data_05C838:
	; CDL: read by queue_vram_blocks_at_x, shake_and_explode_state
	.byte	$00, $20, $00, $40, $00, $60, $00, $80, $00, $A0, $00, $C0, $00, $E0, $00, $80
vram_blocks_05C848:
	.byte	$00, $50, $00, $50, $00, $50, $00, $50, $80, $57, $A0, $57
vram_blocks_05C854:
	.byte	$00, $50, $00, $50
	.byte	$00, $50, $00, $50, $C0, $57, $00, $50
data_05C860:
	; CDL: read by init_swing_pivot
	.byte	$03, $00, $03, $00, $03, $00, $03, $00, $05, $00
data_05C86A:
	; CDL: read by init_swing_pivot
	.byte	$80, $00, $80, $00, $00, $00, $00, $00, $00, $00
data_05C874:
	; CDL: read by init_swing_pivot
	.byte	$FF, $FF, $FE, $FF, $01, $00, $FE, $FF, $01, $00
data_05C87E:
	; CDL: read by swing_handle_follow_pivot
	.addr	metasprite_06B755, metasprite_06B75A, metasprite_06B75F, metasprite_06B764
	.addr	metasprite_06B769, metasprite_06B76E, metasprite_06B773, metasprite_06B778
data_05C88E:
	; CDL: read by swing_player_climb
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
data_05C8CE:
	; CDL: read by swing_player_climb
	.byte	$00, $00, $E8, $4F, $BF, $9C, $8F, $E3, $A1, $21, $91, $54, $6B, $7A, $BA, $91
	.byte	$99, $99, $BA, $91, $6B, $7A, $91, $54, $A1, $21, $8F, $E3, $BF, $9C, $E8, $4F
	.byte	$00, $00, $18, $B0, $41, $63, $71, $1C, $5F, $DE, $6F, $AB, $95, $85, $46, $6E
	.byte	$67, $66, $46, $6E, $95, $85, $6F, $AB, $5F, $DE, $71, $1C, $41, $63, $18, $B0
; OBJ_HP of types $48 and $51 (a 4th word unused) by difficulty (easy, normal, hard)
object_type_48_hp:
	; CDL: read by object_type_48_state_00; partly not accessed
	.word	ENEMY_HP($0000), ENEMY_HP($0000), ENEMY_HP($0001), ENEMY_HP($0001)
data_05C916:
	; CDL: read by object_type_48_set_x_velocity; partly not accessed
	.byte	$00, $80, $00, $C0, $01, $00, $01, $40
data_05C91E:
	; CDL: read by update_objects, object_type_48_set_x_velocity; partly not accessed
	.byte	$FF, $80, $FF, $40, $FF, $00, $FE, $C0
anim_05C926:
	anim_frame	$0007, metasprite_06C16F, metasprite_06C1E1
	anim_frame	$0006, metasprite_06C184, metasprite_06C1F6
	anim_frame	$0007, metasprite_06C191, metasprite_06C203
	anim_frame	$0006, metasprite_06C184, metasprite_06C1F6
	anim_goto	anim_05C926
anim_05C940:
	anim_frame	$0007, metasprite_06C1A6, metasprite_06C1A6
anim_05C946:
	anim_frame	$0002, metasprite_06C1B7, metasprite_06C1B7
	anim_goto	anim_05C946
data_05C94E:
	; CDL: read by object_type_49_state_01; partly not accessed
	.byte	$02, $00, $02, $00, $03, $00, $03, $00
data_05C956:
	; CDL: read by object_type_49_state_02; partly not accessed
	.byte	$D2, $00, $B4, $00, $96, $00, $78, $00
; OBJ_HP of update_rolling_mine by difficulty (easy, normal, hard)
rolling_mine_hp:
	; CDL: read by rolling_mine_state_00
	.word	ENEMY_HP($0004), ENEMY_HP($0006), ENEMY_HP($0010)
data_05C964:
	; CDL: read by rolling_mine_state_00
	.byte	$00, $78, $FF, $87
data_05C968:
	; CDL: read by update_objects, rolling_mine_state_00
	.byte	$01, $00, $FE, $FF
anim_05C96C:
	anim_frame	$0003, metasprite_06B77D, metasprite_06B7B0
	anim_frame	$0003, metasprite_06B78E, metasprite_06B79F
	anim_frame	$0003, metasprite_06B79F, metasprite_06B78E
	anim_frame	$0003, metasprite_06B7B0, metasprite_06B77D
	anim_goto	anim_05C96C
anim_05C986:
	anim_frame	$0008, metasprite_06B7C1, metasprite_06B7C1
	anim_frame	$0008, metasprite_06B7D6, metasprite_06B7D6
	anim_frame	$0006, metasprite_06B7EB, metasprite_06B7EB
	anim_frame	$0006, metasprite_06B7FC, metasprite_06B7FC
	anim_frame	$0006, metasprite_06B7EB, metasprite_06B7EB
	anim_frame	$0004, metasprite_06B840, metasprite_06B840
	anim_end	metasprite_06B7EB, metasprite_06B7EB
anim_05C9B0:
	anim_frame	$0006, metasprite_06B7EB, metasprite_06B7EB
	anim_frame	$0006, metasprite_06B7D6, metasprite_06B7D6
	anim_frame	$0008, metasprite_06B7C1, metasprite_06B7C1
	anim_end	metasprite_06B7C1, metasprite_06B7C1
data_05C9C8:
	; CDL: read by rolling_mine_state_04
	.addr	metasprite_06B7EB, metasprite_06B7FC, metasprite_06B80D, metasprite_06B81E
	.addr	metasprite_06B82F, metasprite_06B862, metasprite_06B851, metasprite_06B840
data_05C9D8:
	; CDL: read by rolling_mine_state_04
	.byte	$04, $00, $14, $00, $18, $00, $10, $00, $04, $00, $FC, $FF, $F0, $FF, $F4, $FF
data_05C9E8:
	; CDL: read by rolling_mine_state_04
	.byte	$D8, $FF, $D8, $FF, $E8, $FF, $EC, $FF, $F0, $FF, $EC, $FF, $E8, $FF, $D8, $FF
data_05C9F8:
	; CDL: read by object_type_4E_state_05
	.addr	vram_blocks_05CA0C, vram_blocks_05CA1C, vram_blocks_05CA2C, vram_blocks_05CA3C
	.addr	vram_blocks_05CA4C
data_05CA02:
	; CDL: read by queue_vram_blocks_at_x, object_type_4E_state_05
	.byte	$00, $41, $80, $41, $00, $42, $80, $42, $00, $43
vram_blocks_05CA0C:
	.byte	$40, $61, $60, $61, $00, $50
	.byte	$00, $61, $40, $61, $60, $61, $00, $50, $80, $61
vram_blocks_05CA1C:
	.byte	$C0, $61, $E0, $61, $00, $61
	.byte	$80, $61, $C0, $61, $E0, $61, $00, $61, $80, $61
vram_blocks_05CA2C:
	.byte	$C0, $61, $E0, $61, $80, $61
	.byte	$A0, $61, $C0, $61, $E0, $61, $80, $61, $A0, $61
vram_blocks_05CA3C:
	.byte	$40, $5F, $60, $5F, $00, $5F
	.byte	$20, $5F, $40, $5F, $60, $5F, $00, $5F, $20, $5F
vram_blocks_05CA4C:
	.byte	$C0, $5F, $E0, $5F, $80, $5F
	.byte	$A0, $5E, $C0, $5F, $E0, $5F, $80, $5F, $A0, $5E
data_05CA5C:
	; CDL: read by object_type_4E_state_08
	.byte	$6D, $08, $A0, $E0, $00, $A1, $00, $00
; OBJ_HP of update_object_type_4E (the first 3 words; other data follows) by difficulty (easy, normal, hard)
object_type_4E_hp:
	; CDL: read by update_objects, queue_vram_blocks_at_x, object_type_4E_state_09; DMA / HDMA; partly not accessed
	.byte	$40, $00, $48, $00, $50, $00, $58, $00
vram_blocks_05CA6C:
	.byte	$60, $B8, $80, $B8, $E0, $B8, $00, $B9
	.byte	$20, $B9, $40, $B9
vram_blocks_05CA78:
	.byte	$A0, $B7, $C0, $B7, $80, $C2, $80, $C2, $80, $C2, $80, $C2
	.byte	$00, $00, $FF, $FF
vram_blocks_05CA88:
	.byte	$E0, $B7, $20, $B8, $00, $B8, $40, $B8
hdma_table_05CA90:
	.byte	$6D, $20, $60, $02
	.byte	$00
vram_blocks_05CA95:
	.byte	$80, $B6, $A0, $B6, $00, $B7, $20, $B7
vram_blocks_05CA9D:
	.byte	$A0, $B8, $C0, $B8
anim_05CAA1:
	anim_frame	$0001, metasprite_06B712, metasprite_06B873
	anim_frame	$0002, metasprite_06B72B, metasprite_06B88C
	anim_goto	anim_05CAA1
anim_05CAAF:
	anim_frame	$0001, metasprite_06B712, metasprite_06B873
	anim_goto	anim_05CAAF
anim_05CAB7:
	anim_frame	$0001, metasprite_06B740, metasprite_06B8A1
	anim_goto	anim_05CAB7
data_05CABF:
	; CDL: read by stage3_winged_bug_state_00; partly not accessed
	.byte	$9F, $00, $2F, $00, $07, $00, $00, $00, $04, $00, $08, $00
; OBJ_HP of types $56 and $24 (a 4th word unused) by difficulty (easy, normal, hard)
object_type_56_hp:
	; CDL: read by object_type_56_state_00; partly not accessed
	.word	ENEMY_HP($0001), ENEMY_HP($0002), ENEMY_HP($0003), ENEMY_HP($0004)
data_05CAD3:
	; CDL: read by object_type_56_set_velocity; partly not accessed
	.byte	$00, $00, $00, $80, $00, $00, $00, $00
data_05CADB:
	; CDL: read by object_type_56_set_velocity; partly not accessed
	.byte	$02, $00, $02, $00, $03, $00, $03, $00
data_05CAE3:
	; CDL: read by object_type_56_set_velocity; partly not accessed
	.byte	$00, $00, $00, $80, $00, $00, $00, $00
data_05CAEB:
	; CDL: read by object_type_56_set_velocity; partly not accessed
	.byte	$FE, $FF, $FD, $FF, $FD, $FF, $FD, $FF
data_05CAF3:
	; CDL: read by update_objects, object_type_56_state_01
	.byte	$02, $00, $FE, $FF
anim_05CAF7:
	anim_frame	$0007, metasprite_06C299, metasprite_06C408
	anim_frame	$0006, metasprite_06C2AE, metasprite_06C41D
	anim_frame	$0007, metasprite_06C2C3, metasprite_06C432
	anim_frame	$0006, metasprite_06C2AE, metasprite_06C41D
	anim_goto	anim_05CAF7
anim_05CB11:
	anim_frame	$0002, metasprite_06C2D8, metasprite_06C447
	anim_goto	anim_05CB11
data_05CB19:
	; CDL: read by update_object_type_56
	.byte	$E9, $C2, $58, $C4
data_05CB1D:
	; CDL: read by spawn_alien_soldier_right
	.byte	$40, $00, $28, $00, $10, $00
data_05CB23:
	; CDL: read by spawn_alien_soldier_left
	.byte	$80, $00, $60, $00, $40, $00
data_05CB29:
	; CDL: read by spiked_climber_move_x
	.byte	$00, $08, $FF, $F7
data_05CB2D:
	; CDL: read by spiked_climber_move_x
	.byte	$00, $00, $FF, $FF
data_05CB31:
	; CDL: read by spiked_climber_init_part
	.byte	$3E, $00, $3F, $00, $40, $00
data_05CB37:
	; CDL: read by spiked_climber_init_part
	.byte	$20, $00, $09, $00, $08, $00
data_05CB3D:
	; CDL: read by spiked_climber_init_part
	.addr	metasprite_06B8D0, metasprite_06B8B6
	.byte	$00, $00
data_05CB43:
	; CDL: read by update_objects, stage3_spiked_climber_state_05; partly not accessed
	.byte	$00, $03, $00, $02, $40, $00
anim_05CB49:
	anim_frame	$0003, metasprite_06B922, metasprite_06B8F9
	anim_frame	$0003, metasprite_06B943, metasprite_06BB1F
	anim_frame	$0003, metasprite_06BA8B, metasprite_06BAF6
	anim_frame	$0003, metasprite_06BAAC, metasprite_06BAD5
	anim_frame	$0003, metasprite_06BAD5, metasprite_06BAAC
	anim_frame	$0003, metasprite_06BAF6, metasprite_06BA8B
	anim_frame	$0003, metasprite_06BB1F, metasprite_06B943
	anim_frame	$0003, metasprite_06B8F9, metasprite_06B922
	anim_goto	anim_05CB49
data_05CB7B:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$A0, $00, $80, $00, $80, $00, $80, $00, $40, $00, $80, $00, $40, $00, $80, $00
	.byte	$50, $00, $50, $00, $80, $00, $90, $00, $88, $00, $40, $00, $F0, $00
data_05CB99:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$00, $06, $C0, $05, $80, $05, $40, $05, $00, $05, $40, $03, $C0, $04, $80, $04
	.byte	$40, $04, $00, $04, $C0, $03
data_05CBAF:
	; CDL: read by object_type_5A_state_00
	.byte	$48, $00, $38, $00, $28, $00, $18, $00, $08, $00, $08, $00, $18, $00, $28, $00
	.byte	$38, $00, $48, $00, $00, $00
data_05CBC5:
	; CDL: read by object_type_5A_state_00
	.byte	$94, $FF, $A4, $FF, $B4, $FF, $C4, $FF, $D4, $FF, $18, $00, $28, $00, $38, $00
	.byte	$48, $00, $58, $00, $00, $00
data_05CBDB:
	; CDL: read by object_type_5A_state_01
	.byte	$0E, $06, $CE, $03
data_05CBDF:
	; CDL: read by update_objects, object_type_5A_state_01; partly not accessed
	.byte	$C8, $00, $B8, $00, $A8, $00, $98, $00, $88, $00, $40, $00, $30, $00, $20, $00
	.byte	$10, $00, $00, $00, $5C, $00, $00, $00, $F8, $FF, $F0, $FF, $E8, $FF, $E0, $FF
	.byte	$A0, $FF, $98, $FF, $90, $FF, $88, $FF, $80, $FF, $B8, $FF
anim_05CC0B:
	anim_frame	$0002, metasprite_06B9E0, metasprite_06B9BE
	anim_frame	$0002, metasprite_06B9E5, metasprite_06B9CF
	anim_goto	anim_05CC0B
data_05CC19:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$00, $1C, $00, $1B, $00, $17, $00, $10, $00, $08, $00, $02, $00, $02, $00, $01
	.byte	$00, $00, $00, $00
data_05CC2D:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00
data_05CC41:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$FF, $BB, $FF, $E2, $FF, $7E, $FF, $8F, $FF, $C7, $FF, $B1, $FF, $B1, $FF, $D8
	.byte	$FF, $FF, $FF, $FF
data_05CC55:
	; CDL: read by stage3_spiked_climber_state_0A
	.byte	$FB, $FF, $FB, $FF, $FC, $FF, $FD, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF
data_05CC69:
	; CDL: read by stage3_spiked_climber_state_10
	.byte	$02, $00, $00, $00
data_05CC6D:
	; CDL: read by stage3_spiked_climber_state_10
	.byte	$3D, $00, $1D, $40
data_05CC71:
	; CDL: read by spiked_climber_set_hitbox
	.byte	$80, $00, $CC, $00
data_05CC75:
	; CDL: read by spiked_climber_set_hitbox
	.byte	$28, $00, $10, $00, $1C, $00
data_05CC7B:
	; CDL: read by spiked_climber_set_hitbox
	.byte	$E0, $FF, $40, $FF, $E0, $FF
data_05CC81:
	; CDL: read by update_objects, spiked_climber_set_hitbox; partly not accessed
	.addr	metasprite_06B943, metasprite_06B9F7, metasprite_06B9BE
anim_05CC87:
	anim_frame	$0002, metasprite_06B9F7, metasprite_06B9BE
	anim_frame	$0002, metasprite_06BA10, metasprite_06B9CF
	anim_goto	anim_05CC87
anim_05CC95:
	anim_frame	$0002, metasprite_06BA29, $0000
	anim_frame	$0002, metasprite_06BA5A, $0000
	anim_goto	anim_05CC95
	; CDL: read by queue_vram_blocks_at_x
vram_blocks_05CCA3:
	.byte	$00, $5B, $00, $5B, $00, $5B, $00, $5B, $40, $5C, $60, $5C
vram_blocks_05CCAF:
	.byte	$80, $5B, $80, $5B
	.byte	$80, $5B, $80, $5B, $00, $75, $20, $75
vram_blocks_05CCBB:
	.byte	$00, $50, $00, $50, $00, $50, $00, $50
	.byte	$00, $50, $00, $50
data_05CCC7:
	; CDL: read by stage3_spiked_climber_state_10
	.byte	$00, $10, $00, $E0
data_05CCCB:
	; CDL: read by stage3_spiked_climber_state_10
	.byte	$00, $00, $FF, $FF
data_05CCCF:
	; CDL: read by stage3_spiked_climber_state_10
	.byte	$FF, $00, $5A, $00, $42, $00, $FF, $00
data_05CCD7:
	; CDL: read by update_objects, stage3_spiked_climber_state_10; partly not accessed
	.byte	$28, $00, $60, $00, $98, $00
anim_05CCDD:
	anim_frame	$0004, metasprite_06B943, metasprite_06B995
	anim_frame	$0004, metasprite_06B96C, metasprite_06B96C
	anim_end	metasprite_06B995, metasprite_06B943
	.byte	$30, $00, $40, $00, $60, $00
; OBJ_HP of the stage 3 spiked climber's core (type $40) by difficulty (easy, normal, hard)
stage3_spiked_climber_core_hp:
	; CDL: read by stage3_spiked_climber_state_03
	.word	ENEMY_HP($0038), ENEMY_HP($0050), ENEMY_HP($0080)
; OBJ_HP of update_stage3_spiked_climber by difficulty (easy, normal, hard)
stage3_spiked_climber_hp:
	; CDL: read by stage3_spiked_climber_state_0F
	.word	ENEMY_HP($0060), ENEMY_HP($00A0), ENEMY_HP($00B8)
; OBJ_HP of update_hoverbike_rider by difficulty (easy, normal, hard)
hoverbike_rider_hp:
	; CDL: read by hoverbike_rider_state_00
	.word	ENEMY_HP($0008), ENEMY_HP($0010), ENEMY_HP($0020)
data_05CD07:
	; CDL: read by update_objects, hoverbike_rider_state_00; partly not accessed
	.addr	metasprite_06C6C6, metasprite_06C6EB
anim_05CD0B:
	anim_frame	$0008, metasprite_06C718, metasprite_06C718
	anim_frame	$0010, metasprite_06C741, metasprite_06C741
	.word	$0000
	.addr	metasprite_06C6C6
data_05CD1B:
	; CDL: read by update_palette_anim; partly not accessed
	.addr	metasprite_06C6C6
	.addr	palette_task_05CD29
	.addr	palette_task_05CD41
data_05CD21:
	; CDL: read by start_palette_task_at, palette_task_fade_out, palette_task_fade_in (+2 more); DMA / HDMA
	.addr	palette_task_05CD4D
	.addr	palette_task_05CD2F
	.addr	palette_task_05CD47
	.addr	palette_task_05CD53
palette_task_05CD29:
	palette_fade_in	$10, palette_08F02A, $22DA
palette_task_05CD2F:
	palette_fade_out	$10, palette_08F02A, $22DA
palette_task_05CD35:
	palette_fade_in	$30, palette_08F032, $22A2
palette_task_05CD3B:
	palette_fade_out	$30, palette_08F032, $22A2
palette_task_05CD41:
	palette_fade_in	$10, palette_08F04E, $22C2
palette_task_05CD47:
	palette_fade_out	$10, palette_08F04E, $22C2
palette_task_05CD4D:
	palette_fade_in	$10, palette_08F06E, $22C4
palette_task_05CD53:
	palette_fade_out	$10, palette_08F06E, $22C4
hdma_list_05CD59:
	hdma_channel	$4370, $01, $28, hdma_table_05CD63
	hdma_channels_end	$80
hdma_table_05CD63:
	.byte	$18, $01, $00, $01, $18, $E8, $00
topdown_stage_songs:
	; CDL: read by intro_play_music
	.byte	$63, $00, $66, $00
data_05CD6E:
	; CDL: read by set_status_bar_scroll
	.byte	$00
data_05CD6F:
	; CDL: read by set_status_bar_scroll
	.byte	$00, $9F, $FF
data_05CD72:
	.byte	$00, $00, $10, $00, $50, $00
stage2_target_type_sets:
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$00, $00, $00, $00, $00, $00, $01, $00, $07, $00, $0C, $00, $01, $00, $07, $00
	.byte	$00, $00, $00, $00, $00, $00, $07, $00, $0C, $00, $01, $00, $07, $00, $0C, $00
	.byte	$00, $00, $00, $00, $00, $00, $0C, $00, $01, $00, $07, $00, $0C, $00, $01, $00
	.byte	$00, $00, $00, $00, $00, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$00, $00, $00, $00, $00, $00, $01, $00, $07, $00, $0C, $00, $0D, $00, $0E, $00
	.byte	$00, $00, $00, $00, $00, $00, $07, $00, $0C, $00, $0D, $00, $0E, $00, $01, $00
	.byte	$00, $00, $00, $00, $00, $00, $0C, $00, $0D, $00, $0E, $00, $01, $00, $07, $00
	.byte	$00, $00, $00, $00, $00, $00, $0D, $00, $0E, $00, $01, $00, $07, $00, $0C, $00
	.byte	$00, $00, $00, $00, $00, $00
data_05CE08:
	; CDL: read by spawn_stage2_targets
	.byte	$90, $00, $70, $03, $70, $01, $90, $02, $70, $00
data_05CE12:
	; CDL: read by spawn_stage2_targets
	.byte	$70, $00, $50, $00, $90, $02, $90, $02, $90, $03
data_05CE1C:
	; CDL: read by spawn_stage2_targets
	.byte	$10, $06, $6C, $04, $2C, $28, $50, $28, $0C, $38
data_05CE26:
	; CDL: read by spawn_stage2_targets
	.byte	$00, $00, $00, $00, $04, $00, $00, $00, $02, $00
data_05CE30:
	; CDL: read by spawn_stage2_boss
	.byte	$03, $00, $00, $00, $04, $00, $05, $00, $06, $00, $06, $00, $06, $00, $06, $00
	.byte	$06, $00, $06, $00
data_05CE44:
	; CDL: read by spawn_stage2_boss
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $02, $00, $04, $00, $06, $00
	.byte	$08, $00, $0A, $00
data_05CE58:
	; CDL: read by spawn_stage2_boss, spawn_stage5_targets; partly not accessed
	.byte	$00, $00, $00, $00, $1C, $0E, $1C, $14, $16, $0D, $22, $0D, $14, $10, $24, $10
	.byte	$16, $13, $22, $13, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00
stage5_target_type_sets:
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	; CDL: read by spawn_stage5_targets; partly not accessed
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00
data_05CEFC:
	; CDL: read by spawn_stage5_targets
	.byte	$00, $00, $00, $00, $02, $00, $00, $00, $02, $00
data_05CF06:
	; CDL: read by spawn_stage5_targets
	.byte	$B0, $00, $70, $02, $90, $03, $50, $03, $F0, $00
data_05CF10:
	; CDL: read by spawn_stage5_targets
	.byte	$90, $00, $70, $01, $10, $01, $F0, $02, $30, $03
data_05CF1A:
	; CDL: read by spawn_stage5_targets
	.byte	$14, $08, $4C, $16, $70, $10, $68, $2E, $1C, $32
data_05CF24:
	; CDL: read by spawn_stage5_boss
	.byte	$08, $00
data_05CF26:
	; CDL: read by spawn_stage5_boss
	.byte	$00, $00
data_05CF28:
	; CDL: read by spawn_stage5_boss
	.byte	$00, $00
load_list_05CF2A:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $00
	load_vram	$0000, gfx_13CC02
	load_end
load_list_05CF33:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$6000, gfx_14A86D
	load_vram	$7000, gfx_16BE91
	load_end
load_list_05CF41:
	; CDL: read by load_data_list, run_pending_loads, decompress_chunk
	load_list	$00, $00
	load_vram	$5000, gfx_089D7E
	load_end
load_list_05CF4A:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+1 more)
	load_list	$01, $00
	load_wram	$7F0000, packed_128000
	load_wram	$7F2000, packed_129417
	load_wram	$7F4000, packed_12A7E8
	load_wram	$7F6000, packed_12BC16
	load_wram	$7F8000, packed_12CFEE
	load_wram	$7FA000, packed_12E60A
	load_wram	$7FC000, packed_138000
	load_wram	$7FE000, packed_139567
	load_end
load_list_05CF7E:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+3 more)
	load_list	$01, $00
	load_wram	$7E8000, packed_13E420
	load_wram	$7E9000, packed_13ED3A
	load_wram	$7E9400, packed_13EE4E
	load_wram	$7E9800, packed_13EF62
	load_wram	$7E9C00, packed_13F076
	load_wram	$7EA000, packed_178000
	load_wram	$7EC000, packed_1798AD
	load_wram	$7EE000, packed_17AFDA
	load_end
palette_task_05CFB2:
	palette_animate	$00, $00
	palette_copy	palette_088C3E, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_088F50, $2300
	palette_copy	palette_088F2E, $2340
	palette_copy	palette_088F0C, $2360
	palette_copy	palette_088CE0, $2380
	palette_copy_end
load_list_05CFCF:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $00
	load_vram	$0000, gfx_148000
	load_end
load_list_05CFD8:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+3 more)
	load_list	$01, $00
	load_wram	$7E8000, packed_13F18A
	load_wram	$7E9000, packed_13F4A5
	load_wram	$7E9400, packed_13F4EF
	load_wram	$7E9800, packed_13F545
	load_wram	$7E9C00, packed_13F569
	load_wram	$7EA000, packed_149C93
	load_wram	$7EC000, packed_1497F0
	load_end
palette_task_05D006:
	palette_animate	$00, $00
	palette_copy	palette_088C3E, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_088D82, $2300
	palette_copy	palette_088F0C, $2360
	palette_copy	palette_088CE0, $2380
	palette_copy_end
load_list_05D01F:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $00
	load_vram	$0000, gfx_158000
	load_end
load_list_05D028:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+3 more)
	load_list	$01, $00
	load_wram	$7E8000, packed_15A477
	load_wram	$7E9000, packed_15A9EA
	load_wram	$7E9400, packed_15AAFE
	load_wram	$7E9800, packed_15AC12
	load_wram	$7E9C00, packed_15AD26
	load_wram	$7EA000, packed_15AE2E
	load_wram	$7EC000, packed_15C2B3
	load_end
palette_task_05D056:
	palette_animate	$00, $00
	palette_copy	palette_088DA4, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_088ECA, $2300
	palette_copy	palette_088F2E, $2340
	palette_copy	palette_088F0C, $2360
	palette_copy	palette_088CE0, $2380
	palette_copy_end
load_list_05D073:
	; CDL: read by load_data_list, dma_ring_to_vram, decompress_chunk
	load_list	$03, $00
	load_vram	$0000, gfx_168000
	load_end
load_list_05D07C:
	; CDL: read by load_data_list, init_loader_context, load_wram_stream (+3 more); partly not accessed
	load_list	$01, $00
	load_wram	$7E8000, packed_16A8FE
	load_wram	$7E9000, packed_16AE8B
	load_wram	$7E9400, packed_16AEF6
	load_wram	$7E9800, packed_16B004
	load_wram	$7E9C00, packed_16B115
	load_wram	$7EA000, packed_16B623
	load_wram	$7EC000, packed_16B174
	load_end
palette_task_05D0AA:
	palette_animate	$00, $00
	palette_copy	palette_088DA4, $2240
	palette_copy	palette_088F92, $2200
	palette_copy	palette_088E46, $2300
	palette_copy	palette_088F0C, $2360
	palette_copy	palette_088CE0, $2380
	palette_copy_end
	.byte	$00, $01, $00, $30, $7B, $97, $1C, $FF, $FF
	.byte	$00, $01, $00, $30, $CC, $A9, $1A, $FF, $FF, $00, $01, $00, $30, $A6, $BC, $1A
	.byte	$FF, $FF
start_points_x:
	; CDL: read by set_start_points, respawn_at_start_point_stage2; partly not accessed
	.byte	$80, $00, $80, $01, $80, $02, $80, $03, $80, $00, $80, $01, $80, $02, $80, $03
	.byte	$80, $00, $80, $01, $80, $02, $80, $03, $80, $00, $80, $01, $80, $02, $80, $03
start_points_x_stage5:
	; CDL: read by set_start_points, respawn_at_start_point_stage5
	.byte	$F0, $00, $80, $01, $60, $02, $A0, $03, $A8, $00, $80, $01, $A0, $02, $80, $03
	.byte	$A0, $00, $40, $01, $A0, $02, $40, $03, $70, $00, $70, $01, $C0, $02, $80, $03
start_points_y:
	; CDL: read by set_start_points, respawn_at_start_point_stage2; partly not accessed
	.byte	$C0, $00, $80, $00, $80, $00, $A0, $00, $80, $01, $80, $01, $80, $01, $60, $01
	.byte	$60, $02, $40, $02, $40, $02, $80, $02, $50, $03, $40, $03, $80, $03, $80, $03
start_points_y_stage5:
	; CDL: read by set_start_points, respawn_at_start_point_stage5
	.byte	$A0, $00, $C0, $00, $60, $00, $60, $00, $60, $01, $80, $01, $A0, $01, $70, $01
	.byte	$90, $02, $C0, $02, $80, $02, $80, $02, $70, $03, $90, $03, $90, $03, $80, $03
data_05D15E:
	; CDL: read by td_set_jump_anim
	.byte	$10, $00, $07, $00, $11, $00, $08, $00
data_05D166:
	; CDL: read by td_set_stand_anim
	.byte	$0E, $00, $03, $00
data_05D16A:
	; CDL: read by td_set_stand_fire_anim
	.byte	$0E, $00, $03, $00, $0F, $00, $04, $00
data_05D172:
	; CDL: read by td_player_state_dying
	.byte	$12, $00, $09, $00, $13, $00, $0A, $00
data_05D17A:
	; CDL: read by td_spin_dying_player
	.byte	$06, $00, $04, $00, $02, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00
data_05D18C:
	; CDL: read by td_set_falling_anim
	.byte	$12, $00, $09, $00, $13, $00, $0A, $00
data_05D194:
	; CDL: read by td_set_walk_anim
	.byte	$0B, $00, $00, $00, $0C, $00, $01, $00, $0D, $00, $02, $00, $0C, $00, $01, $00
data_05D1A4:
	; CDL: read by td_fire_jump_shot
	.byte	$F4, $FF, $0D, $00
data_05D1A8:
	; CDL: read by td_fire_jump_shot
	.byte	$FD, $FF
data_05D1AA:
	; CDL: read by td_fire_jump_shot, fire_td_spread; partly not accessed
	.byte	$04, $00, $F0, $FF, $10, $00, $F8, $FF, $08, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $10, $00, $F0, $FF, $08, $00, $F8, $FF, $00, $00, $00, $00, $00, $00
	.byte	$00, $00
td_spawn_type_masks:
	; CDL: read by spawn_stage2_enemies
	.byte	$FF, $00, $03, $00, $01, $00
stage2_spawn_types:
	; CDL: read by spawn_stage2_enemies
	.byte	$01, $00, $02, $00
stage5_spawn_types:
	; CDL: read by spawn_stage5_enemies
	.byte	$12, $00, $05, $00
td_spawn_offsets_y:
	; CDL: read by td_place_enemy_near_player
	.byte	$40, $FF, $41, $FF, $41, $FF, $41, $FF, $41, $FF, $42, $FF, $43, $FF, $43, $FF
	.byte	$44, $FF, $45, $FF, $46, $FF, $47, $FF, $49, $FF, $4A, $FF, $4C, $FF, $4D, $FF
	.byte	$4F, $FF, $51, $FF, $53, $FF, $55, $FF, $57, $FF, $59, $FF, $5C, $FF, $5E, $FF
	.byte	$61, $FF, $64, $FF, $66, $FF, $69, $FF, $6C, $FF, $6F, $FF, $72, $FF, $75, $FF
	.byte	$79, $FF, $7C, $FF, $80, $FF, $83, $FF, $87, $FF, $8A, $FF, $8E, $FF, $92, $FF
	.byte	$96, $FF, $9A, $FF, $9E, $FF, $A2, $FF, $A6, $FF, $AA, $FF, $AE, $FF, $B3, $FF
	.byte	$B7, $FF, $BB, $FF, $C0, $FF, $C4, $FF, $C9, $FF, $CD, $FF, $D2, $FF, $D6, $FF
	.byte	$DB, $FF, $E0, $FF, $E4, $FF, $E9, $FF, $EE, $FF, $F2, $FF, $F7, $FF, $FC, $FF
td_spawn_offsets_x:
	; CDL: read by td_place_enemy_near_player
	.byte	$00, $00, $04, $00, $09, $00, $0E, $00, $12, $00, $17, $00, $1C, $00, $20, $00
	.byte	$25, $00, $2A, $00, $2E, $00, $33, $00, $37, $00, $3C, $00, $40, $00, $45, $00
	.byte	$49, $00, $4D, $00, $52, $00, $56, $00, $5A, $00, $5E, $00, $62, $00, $66, $00
	.byte	$6A, $00, $6E, $00, $72, $00, $76, $00, $79, $00, $7D, $00, $80, $00, $84, $00
	.byte	$87, $00, $8B, $00, $8E, $00, $91, $00, $94, $00, $97, $00, $9A, $00, $9C, $00
	.byte	$9F, $00, $A2, $00, $A4, $00, $A7, $00, $A9, $00, $AB, $00, $AD, $00, $AF, $00
	.byte	$B1, $00, $B3, $00, $B4, $00, $B6, $00, $B7, $00, $B9, $00, $BA, $00, $BB, $00
	.byte	$BC, $00, $BD, $00, $BD, $00, $BE, $00, $BF, $00, $BF, $00, $BF, $00, $BF, $00
	.byte	$C0, $00, $BF, $00, $BF, $00, $BF, $00, $BF, $00, $BE, $00, $BD, $00, $BD, $00
	.byte	$BC, $00, $BB, $00, $BA, $00, $B9, $00, $B7, $00, $B6, $00, $B4, $00, $B3, $00
	.byte	$B1, $00, $AF, $00, $AD, $00, $AB, $00, $A9, $00, $A7, $00, $A4, $00, $A2, $00
	.byte	$9F, $00, $9C, $00, $9A, $00, $97, $00, $94, $00, $91, $00, $8E, $00, $8B, $00
	.byte	$87, $00, $84, $00, $80, $00, $7D, $00, $79, $00, $76, $00, $72, $00, $6E, $00
	.byte	$6A, $00, $66, $00, $62, $00, $5E, $00, $5A, $00, $56, $00, $52, $00, $4D, $00
	.byte	$49, $00, $45, $00, $40, $00, $3C, $00, $37, $00, $33, $00, $2E, $00, $2A, $00
	.byte	$25, $00, $20, $00, $1C, $00, $17, $00, $12, $00, $0E, $00, $09, $00, $04, $00
	.byte	$00, $00, $FC, $FF, $F7, $FF, $F2, $FF, $EE, $FF, $E9, $FF, $E4, $FF, $E0, $FF
	.byte	$DB, $FF, $D6, $FF, $D2, $FF, $CD, $FF, $C9, $FF, $C4, $FF, $C0, $FF, $BB, $FF
	.byte	$B7, $FF, $B3, $FF, $AE, $FF, $AA, $FF, $A6, $FF, $A2, $FF, $9E, $FF, $9A, $FF
	.byte	$96, $FF, $92, $FF, $8E, $FF, $8A, $FF, $87, $FF, $83, $FF, $80, $FF, $7C, $FF
	.byte	$79, $FF, $75, $FF, $72, $FF, $6F, $FF, $6C, $FF, $69, $FF, $66, $FF, $64, $FF
	.byte	$61, $FF, $5E, $FF, $5C, $FF, $59, $FF, $57, $FF, $55, $FF, $53, $FF, $51, $FF
	.byte	$4F, $FF, $4D, $FF, $4C, $FF, $4A, $FF, $49, $FF, $47, $FF, $46, $FF, $45, $FF
	.byte	$44, $FF, $43, $FF, $43, $FF, $42, $FF, $41, $FF, $41, $FF, $41, $FF, $41, $FF
	.byte	$40, $FF, $41, $FF, $41, $FF, $41, $FF, $41, $FF, $42, $FF, $43, $FF, $43, $FF
	.byte	$44, $FF, $45, $FF, $46, $FF, $47, $FF, $49, $FF, $4A, $FF, $4C, $FF, $4D, $FF
	.byte	$4F, $FF, $51, $FF, $53, $FF, $55, $FF, $57, $FF, $59, $FF, $5C, $FF, $5E, $FF
	.byte	$61, $FF, $64, $FF, $66, $FF, $69, $FF, $6C, $FF, $6F, $FF, $72, $FF, $75, $FF
	.byte	$79, $FF, $7C, $FF, $80, $FF, $83, $FF, $87, $FF, $8A, $FF, $8E, $FF, $92, $FF
	.byte	$96, $FF, $9A, $FF, $9E, $FF, $A2, $FF, $A6, $FF, $AA, $FF, $AE, $FF, $B3, $FF
	.byte	$B7, $FF, $BB, $FF, $C0, $FF, $C4, $FF, $C9, $FF, $CD, $FF, $D2, $FF, $D6, $FF
	.byte	$DB, $FF, $E0, $FF, $E4, $FF, $E9, $FF, $EE, $FF, $F2, $FF, $F7, $FF, $FC, $FF
	; CDL: read by td_animate_enemy
td_anim_05D45A:
	anim_frame	$0002, $0000, $0E00
	anim_frame	$0002, $0001, $0E00
	anim_frame	$0002, $0002, $0E00
	anim_frame	$0002, $0003, $0E00
	anim_frame	$0002, $0004, $0E00
	anim_frame	$0002, $0005, $0E00
	anim_frame	$0002, $0006, $0E00
	anim_frame	$0002, $0007, $0E00
	anim_frame	$0002, $0008, $0E00
	anim_frame	$0002, $0009, $0E00
	anim_frame	$0002, $000A, $0E00
	anim_end	$000A, $0E00
.if CHEAT_ENEMY_HP = 100
td_runner_hp:
.endif
	; CDL: read by td_animate_enemy, td_runner_state_2
	.byte	$00, $00, $02, $00, $04, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D4A8:
	anim_frame	$0008, $0000, $0000
	anim_frame	$0008, $0001, $0000
	anim_frame	$0008, $0000, $0000
	anim_frame	$0008, $0002, $0000
	anim_goto	td_anim_05D4A8
td_gunner_hp:
	; CDL: read by td_gunner_state_2
	.word	ENEMY_HP($0000), ENEMY_HP($0002), ENEMY_HP($0004)
td_gunner_fire_delays:
	; CDL: read by td_animate_enemy, td_gunner_state_3; partly not accessed
	.byte	$40, $00, $20, $00, $10, $00
td_anim_05D4CE:
	anim_frame	$0002, $0000, $0200
	anim_end	$0001, $0200
.if CHEAT_ENEMY_HP = 100
hatch_turret_hp:
.endif
	; CDL: read by td_animate_enemy, hatch_turret_state_1, update_hatch_turret_sweep
	.byte	$10, $00, $20, $00, $40, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D4E0:
	anim_frame	$0008, $0000, $0200
	anim_frame	$0008, $0001, $0200
	anim_frame	$0008, $0000, $0200
	anim_frame	$0008, $0002, $0200
	anim_goto	td_anim_05D4E0
data_05D4FA:
	; CDL: read by hatch_turret_aim_state_2
	.byte	$02, $00, $04, $00, $08, $00
data_05D500:
	; CDL: read by hatch_turret_aim_state_2
	.byte	$01, $00, $02, $00, $04, $00
hatch_turret_aim_fire_masks:
	; CDL: read by hatch_turret_aim_state_2
	.byte	$1F, $00, $0F, $00
	.byte	$07, $00
data_05D50C:
	; CDL: read by hatch_turret_spin_state_2; partly not accessed
	.byte	$04, $00, $08, $00, $10, $00
hatch_turret_spin_fire_masks:
	; CDL: read by hatch_turret_spin_state_2; partly not accessed
	.byte	$07, $00, $01, $00, $00, $00
data_05D518:
	; CDL: read by hatch_turret_sweep_state_2; partly not accessed
	.byte	$08, $00, $04, $00, $10, $00
data_05D51E:
	; CDL: read by hatch_turret_sweep_turn; partly not accessed
	.byte	$02, $00, $02, $00, $08, $00
hatch_turret_sweep_fire_masks:
	; CDL: read by hatch_turret_sweep_state_2; partly not accessed
	.byte	$03, $00, $03, $00, $01, $00
.if CHEAT_ENEMY_HP = 100
td_centipede_unused_hp:
.endif
	; CDL: read by td_animate_enemy; partly not accessed
	.byte	$10, $00, $40, $00, $80, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D530:
	anim_frame	$0004, $0000, $0400
	anim_frame	$0004, $0001, $0400
	anim_goto	td_anim_05D530
.if CHEAT_ENEMY_HP = 100
td_bug_centipede_hp:
.endif
	; CDL: read by td_animate_enemy, td_bug_centipede_state_2
	.byte	$10, $00, $40, $00, $80, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D544:
	anim_frame	$0003, $0000, $0E00
	anim_frame	$0003, $0001, $0E00
	anim_goto	td_anim_05D544
td_centipede_bug_hp:
	; CDL: read by td_centipede_bug_state_0
	.word	ENEMY_HP($0002), ENEMY_HP($0004), ENEMY_HP($0008)
data_05D558:
	; CDL: read by td_centipede_bug_state_2
	.byte	$80, $00, $40, $00, $20, $00
td_centipede_hp:
	; CDL: read by td_centipede_state_2
	.word	ENEMY_HP($0010), ENEMY_HP($0040), ENEMY_HP($0080)
td_centipede_fire_masks:
	; CDL: read by td_centipede_state_4
	.byte	$FF, $FF, $01, $00, $00, $00
.if CHEAT_ENEMY_HP = 100
td_nest_crawler_hp:
.endif
	; CDL: read by td_animate_enemy, td_nest_crawler_state_0
	.byte	$02, $00, $10, $00, $20, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D570:
	anim_frame	$0008, $0000, $0000
	anim_frame	$0008, $0001, $0000
	anim_frame	$0008, $0000, $0000
	anim_frame	$0008, $0002, $0000
	anim_goto	td_anim_05D570
data_05D58A:
	; CDL: read by td_nest_crawler_state_2
	.byte	$00, $01, $80, $00, $20, $00
.if CHEAT_ENEMY_HP = 100
td_crawler_hp:
.endif
	; CDL: read by td_animate_enemy, td_crawler_state_2
	.byte	$02, $00, $04, $00, $08, $00	; cheats: see cheat_enemy_hp_tables
td_anim_05D596:
	anim_frame	$0008, $0000, $0200
	anim_frame	$0008, $0001, $0200
	anim_frame	$0008, $0000, $0200
	anim_frame	$0008, $0002, $0200
	anim_goto	td_anim_05D596
td_spitter_hp:
	; CDL: read by td_spitter_state_2; partly not accessed
	.word	ENEMY_HP($0002), ENEMY_HP($0004), ENEMY_HP($0008)
td_spitter_fire_delays:
	; CDL: read by td_spitter_state_3, animate_td_item; partly not accessed
	.byte	$40, $00, $20, $00, $10, $00
anim_05D5BC:
	anim_frame	$0003, metasprite_07E967, $2C00
	anim_frame	$0003, metasprite_07E8FB, $2C00
	anim_frame	$0003, metasprite_07E900, $2C00
	anim_frame	$0003, metasprite_07E8B7, $2C00
	anim_frame	$0003, metasprite_07E8C8, $2C00
	anim_frame	$0003, metasprite_07E8D9, $2C00
	anim_frame	$0003, metasprite_07E8EA, $2C00
	anim_frame	$0003, metasprite_07E905, $2C00
	anim_frame	$0003, metasprite_07E916, $2C00
	anim_frame	$0003, metasprite_07E927, $2C00
	anim_frame	$0003, metasprite_07E938, $2C00
	anim_frame	$0003, metasprite_07E987, $2C00
	anim_frame	$0003, metasprite_07E998, $2C00
	anim_end	$0000, $0000
anim_05D610:
	anim_frame	$0002, metasprite_07E967, $2E00
	anim_frame	$0002, metasprite_07E8FB, $2E00
	anim_frame	$0002, metasprite_07E900, $2E00
	anim_frame	$0002, metasprite_07E8B7, $2E00
	anim_frame	$0002, metasprite_07E8C8, $2E00
	anim_frame	$0002, metasprite_07E8D9, $2E00
	anim_frame	$0002, metasprite_07E8EA, $2E00
	anim_frame	$0002, metasprite_07E905, $2E00
	anim_frame	$0002, metasprite_07E916, $2E00
	anim_frame	$0002, metasprite_07E927, $2E00
	anim_frame	$0002, metasprite_07E938, $2E00
	anim_frame	$0002, metasprite_07E987, $2E00
	anim_frame	$0002, metasprite_07E998, $2E00
	anim_end	$0000, $0000
data_05D664:
	; CDL: read by td_item_spread_state_0; partly not accessed
	.addr	anim_05D680, anim_05D706
data_05D668:
	; CDL: read by td_item_crush_state_0
	.addr	anim_05D694, anim_05D71A
data_05D66C:
	; CDL: read by td_item_homing_state_0
	.addr	anim_05D6A8, anim_05D72E
data_05D670:
	; CDL: read by td_item_flame_state_0
	.addr	anim_05D6BC, anim_05D742
data_05D674:
	; CDL: read by td_item_laser_state_0
	.addr	anim_05D6D0, anim_05D756
data_05D678:
	; CDL: read by td_item_barrier_state_0; partly not accessed
	.addr	anim_05D6E4, anim_05D76A
data_05D67C:
	; CDL: read by td_item_bomb_state_0, animate_td_item; partly not accessed
	.addr	anim_05D6F8, anim_05D77E
anim_05D680:
	anim_frame	$0100, metasprite_07E9A9, $2E00
anim_05D686:
	anim_frame	$0002, $0000, $2E00
	anim_frame	$0002, metasprite_07E9A9, $2E00
	anim_goto	anim_05D686
anim_05D694:
	anim_frame	$0100, metasprite_07E9BA, $2E00
anim_05D69A:
	anim_frame	$0002, $0000, $2E00
	anim_frame	$0002, metasprite_07E9BA, $2E00
	anim_goto	anim_05D69A
anim_05D6A8:
	anim_frame	$0100, metasprite_07E9CB, $2E00
anim_05D6AE:
	anim_frame	$0002, $0000, $2E00
	anim_frame	$0002, metasprite_07E9CB, $2E00
	anim_goto	anim_05D6AE
anim_05D6BC:
	anim_frame	$0100, metasprite_07E9DC, $2E00
anim_05D6C2:
	anim_frame	$0002, $0000, $2E00
	anim_frame	$0002, metasprite_07E9DC, $2E00
	anim_goto	anim_05D6C2
anim_05D6D0:
	anim_frame	$0100, metasprite_07E9ED, $2E00
anim_05D6D6:
	anim_frame	$0002, $0000, $2E00
	anim_frame	$0002, metasprite_07E9ED, $2E00
	anim_goto	anim_05D6D6
anim_05D6E4:
	anim_frame	$0100, metasprite_07E971, $2C00
anim_05D6EA:
	anim_frame	$0002, $0000, $2C00
	anim_frame	$0002, metasprite_07E971, $2C00
	anim_goto	anim_05D6EA
anim_05D6F8:
	anim_frame	$0002, metasprite_07E982, $2E00
	anim_frame	$0002, metasprite_07E982, $2600
	anim_goto	anim_05D6F8
anim_05D706:
	anim_frame	$0100, metasprite_07E9A9, $1E00
anim_05D70C:
	anim_frame	$0002, $0000, $1E00
	anim_frame	$0002, metasprite_07E9A9, $1E00
	anim_goto	anim_05D70C
	; CDL: read by animate_td_item; partly not accessed
anim_05D71A:
	anim_frame	$0100, metasprite_07E9BA, $1E00
anim_05D720:
	anim_frame	$0002, $0000, $1E00
	anim_frame	$0002, metasprite_07E9BA, $1E00
	anim_goto	anim_05D720
anim_05D72E:
	anim_frame	$0100, metasprite_07E9CB, $1E00
anim_05D734:
	anim_frame	$0002, $0000, $1E00
	anim_frame	$0002, metasprite_07E9CB, $1E00
	anim_goto	anim_05D734
anim_05D742:
	anim_frame	$0100, metasprite_07E9DC, $1E00
anim_05D748:
	anim_frame	$0002, $0000, $1E00
	anim_frame	$0002, metasprite_07E9DC, $1E00
	anim_goto	anim_05D748
anim_05D756:
	anim_frame	$0100, metasprite_07E9ED, $1E00
anim_05D75C:
	anim_frame	$0002, $0000, $1E00
	anim_frame	$0002, metasprite_07E9ED, $1E00
	anim_goto	anim_05D75C
anim_05D76A:
	anim_frame	$0100, metasprite_07E971, $1C00
anim_05D770:
	anim_frame	$0002, $0000, $1C00
	anim_frame	$0002, metasprite_07E971, $1C00
	anim_goto	anim_05D770
anim_05D77E:
	anim_frame	$0002, metasprite_07E982, $1E00
	anim_frame	$0002, metasprite_07E982, $1600
	anim_goto	anim_05D77E
td_item_drop_kinds:
	; CDL: read by td_spawn_item_drop; partly not accessed
	.byte	$01, $00, $02, $00, $03, $00, $07, $00, $04, $00, $04, $00, $05, $00, $05, $00
	.byte	$06, $00, $06, $00, $06, $00
td_item_kind_types:
	; CDL: read by td_spawn_item_drop
	.byte	$07, $00, $03, $00, $04, $00, $05, $00, $06, $00, $07, $00, $08, $00, $09, $00
data_05D7B2:
	; CDL: read by stage2_boss_state_06
	.byte	$02, $00, $FE, $FF
data_05D7B6:
	; CDL: read by stage2_boss_state_0A; partly not accessed
	.byte	$04, $00, $06, $00, $08, $00
data_05D7BC:
	; CDL: read by stage2_boss_state_0A; partly not accessed
	.byte	$04, $00, $06, $00, $0C, $00
data_05D7C2:
	; CDL: read by stage2_boss_state_0F; partly not accessed
	.byte	$40, $00, $20, $00, $10, $00
data_05D7C8:
	; CDL: read by stage2_boss_aim_jump; partly not accessed
	.byte	$30, $00, $40, $00, $60, $00
stage2_boss_core_hp:
	; CDL: read by stage2_boss_core_state_0; partly not accessed
	.word	ENEMY_HP($0100), ENEMY_HP($0180), ENEMY_HP($0200)
stage2_boss_pod_hp:
	; CDL: read by stage2_boss_pod_state_0; partly not accessed
	.word	ENEMY_HP($0020), ENEMY_HP($0040), ENEMY_HP($0080)
stage2_boss_pod_drop_kinds:
	; CDL: read by stage2_boss_pod_drop_item; partly not accessed
	.byte	$01, $00, $02, $00, $03, $00, $07, $00, $04, $00, $04, $00, $05, $00, $05, $00
	.byte	$06, $00, $06, $00, $06, $00, $07, $00, $01, $00, $02, $00, $03, $00, $07, $00
	.byte	$04, $00, $04, $00, $05, $00, $05, $00, $06, $00, $06, $00, $06, $00
stage2_boss_pod_item_types:
	; CDL: read by stage2_boss_pod_drop_item; partly not accessed
	.byte	$07, $00, $03, $00, $04, $00, $05, $00, $06, $00, $07, $00, $08, $00, $09, $00
stage2_boss_cannon_hp:
	; CDL: read by stage2_boss_cannon_state_0; partly not accessed
	.word	ENEMY_HP($0080), ENEMY_HP($00C0), ENEMY_HP($0100)
data_05D81E:
	; CDL: read by stage2_boss_cannon_state_3
	.byte	$04, $00, $FC, $FF
stage2_boss_cannon_fire_masks:
	; CDL: read by stage2_boss_cannon_fire; partly not accessed
	.byte	$03, $00, $01, $00, $00, $00
data_05D828:
	; CDL: read by project_around_stage2_boss; partly not accessed
	.byte	$00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	.byte	$61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	.byte	$B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	.byte	$EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF
data_05D868:
	; CDL: read by project_around_stage2_boss; partly not accessed
	.byte	$FF, $FF, $FF, $FF, $FE, $FE, $FD, $FC, $FB, $F9, $F8, $F6, $F4, $F3, $F1, $EE
	.byte	$EC, $EA, $E7, $E4, $E1, $DE, $DB, $D8, $D4, $D1, $CD, $C9, $C5, $C1, $BD, $B9
	.byte	$B5, $B0, $AB, $A7, $A2, $9D, $98, $93, $8E, $88, $83, $7E, $78, $73, $6D, $67
	.byte	$61, $5C, $56, $50, $4A, $44, $3E, $38, $31, $2B, $25, $1F, $19, $12, $0C, $06
	.byte	$00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	.byte	$61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	.byte	$B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	.byte	$EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FE, $FE, $FD, $FC, $FB, $F9, $F8, $F6, $F4, $F3, $F1, $EE
	.byte	$EC, $EA, $E7, $E4, $E1, $DE, $DB, $D8, $D4, $D1, $CD, $C9, $C5, $C1, $BD, $B9
	.byte	$B5, $B0, $AB, $A7, $A2, $9D, $98, $93, $8E, $88, $83, $7E, $78, $73, $6D, $67
	.byte	$61, $5C, $56, $50, $4A, $44, $3E, $38, $31, $2B, $25, $1F, $19, $12, $0C, $06
	.byte	$00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	.byte	$61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	.byte	$B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	.byte	$EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF
data_05D968:
	; CDL: read by stage2_boss_pod_state_2
	.byte	$2B, $00, $2C, $00, $1D, $00, $21, $00, $2D, $00, $2E, $00
data_05D974:
	; CDL: read by stage2_boss_pod_state_3
	.byte	$35, $00, $01, $00, $02, $00, $03, $00, $04, $00, $05, $00
data_05D980:
	; CDL: read by stage2_boss_pod_state_4
	.byte	$06, $00, $07, $00, $08, $00, $09, $00, $0A, $00, $0B, $00
data_05D98C:
	; CDL: read by update_stage2_boss_pod
	.byte	$2F, $00, $30, $00, $31, $00, $32, $00, $33, $00, $34, $00
data_05D998:
	; CDL: read by stage2_boss_pod_state_7
	.byte	$0C, $00, $0D, $00, $0E, $00, $0F, $00, $10, $00, $11, $00
data_05D9A4:
	; CDL: not accessed
	.byte	$E0, $FF, $E1, $FF, $E1, $FF, $E2, $FF, $E3, $FF, $E4, $FF, $E6, $FF, $E8, $FF
	.byte	$EA, $FF, $EC, $FF, $EF, $FF, $F1, $FF, $F4, $FF, $F7, $FF, $FA, $FF, $FD, $FF
data_05D9C4:
	; CDL: not accessed
	.byte	$00, $00, $03, $00, $06, $00, $09, $00, $0C, $00, $0F, $00, $11, $00, $14, $00
	.byte	$16, $00, $18, $00, $1A, $00, $1C, $00, $1D, $00, $1E, $00, $1F, $00, $1F, $00
	.byte	$20, $00, $1F, $00, $1F, $00, $1E, $00, $1D, $00, $1C, $00, $1A, $00, $18, $00
	.byte	$16, $00, $14, $00, $11, $00, $0F, $00, $0C, $00, $09, $00, $06, $00, $03, $00
	.byte	$00, $00, $FD, $FF, $FA, $FF, $F7, $FF, $F4, $FF, $F1, $FF, $EF, $FF, $EC, $FF
	.byte	$EA, $FF, $E8, $FF, $E6, $FF, $E4, $FF, $E3, $FF, $E2, $FF, $E1, $FF, $E1, $FF
	.byte	$E0, $FF, $E1, $FF, $E1, $FF, $E2, $FF, $E3, $FF, $E4, $FF, $E6, $FF, $E8, $FF
	.byte	$EA, $FF, $EC, $FF, $EF, $FF, $F1, $FF, $F4, $FF, $F7, $FF, $FA, $FF, $FD, $FF
data_05DA44:
	; CDL: read by stage2_boss_core_position
	.byte	$EE, $FF, $EF, $FF, $EF, $FF, $EF, $FF, $F0, $FF, $F1, $FF, $F2, $FF, $F3, $FF
	.byte	$F4, $FF, $F5, $FF, $F6, $FF, $F8, $FF, $FA, $FF, $FB, $FF, $FD, $FF, $FF, $FF
data_05DA64:
	; CDL: read by stage2_boss_core_position
	.byte	$00, $00, $01, $00, $03, $00, $05, $00, $06, $00, $08, $00, $0A, $00, $0B, $00
	.byte	$0C, $00, $0D, $00, $0E, $00, $0F, $00, $10, $00, $11, $00, $11, $00, $11, $00
	.byte	$12, $00, $11, $00, $11, $00, $11, $00, $10, $00, $0F, $00, $0E, $00, $0D, $00
	.byte	$0C, $00, $0B, $00, $0A, $00, $08, $00, $06, $00, $05, $00, $03, $00, $01, $00
	.byte	$00, $00, $FF, $FF, $FD, $FF, $FB, $FF, $FA, $FF, $F8, $FF, $F6, $FF, $F5, $FF
	.byte	$F4, $FF, $F3, $FF, $F2, $FF, $F1, $FF, $F0, $FF, $EF, $FF, $EF, $FF, $EF, $FF
	.byte	$EE, $FF, $EF, $FF, $EF, $FF, $EF, $FF, $F0, $FF, $F1, $FF, $F2, $FF, $F3, $FF
	.byte	$F4, $FF, $F5, $FF, $F6, $FF, $F8, $FF, $FA, $FF, $FB, $FF, $FD, $FF, $FF, $FF
data_05DAE4:
	; CDL: read by stage2_boss_pod_position
	.byte	$BE, $FF, $BF, $FF, $C0, $FF, $C1, $FF, $C4, $FF, $C6, $FF, $CA, $FF, $CD, $FF
	.byte	$D2, $FF, $D7, $FF, $DC, $FF, $E1, $FF, $E7, $FF, $ED, $FF, $F4, $FF, $FA, $FF
data_05DB04:
	; CDL: read by stage2_boss_pod_position
	.byte	$00, $00, $06, $00, $0C, $00, $13, $00, $19, $00, $1F, $00, $24, $00, $29, $00
	.byte	$2E, $00, $33, $00, $36, $00, $3A, $00, $3C, $00, $3F, $00, $40, $00, $41, $00
	.byte	$42, $00, $41, $00, $40, $00, $3F, $00, $3C, $00, $3A, $00, $36, $00, $33, $00
	.byte	$2E, $00, $29, $00, $24, $00, $1F, $00, $19, $00, $13, $00, $0C, $00, $06, $00
	.byte	$00, $00, $FA, $FF, $F4, $FF, $ED, $FF, $E7, $FF, $E1, $FF, $DC, $FF, $D7, $FF
	.byte	$D2, $FF, $CD, $FF, $CA, $FF, $C6, $FF, $C4, $FF, $C1, $FF, $C0, $FF, $BF, $FF
	.byte	$BE, $FF, $BF, $FF, $C0, $FF, $C1, $FF, $C4, $FF, $C6, $FF, $CA, $FF, $CD, $FF
	.byte	$D2, $FF, $D7, $FF, $DC, $FF, $E1, $FF, $E7, $FF, $ED, $FF, $F4, $FF, $FA, $FF
	; CDL: not accessed
	.byte	$00, $00, $06, $00, $0C, $00, $13, $00, $19, $00, $1F, $00, $24, $00, $29, $00
	.byte	$2E, $00, $33, $00, $36, $00, $3A, $00, $3C, $00, $3F, $00, $40, $00, $41, $00
	.byte	$42, $00, $41, $00, $40, $00, $3F, $00, $3C, $00, $3A, $00, $36, $00, $33, $00
	.byte	$2E, $00, $29, $00, $24, $00, $1F, $00, $19, $00, $13, $00, $0C, $00, $06, $00
	.byte	$00, $00, $FA, $FF, $F4, $FF, $ED, $FF, $E7, $FF, $E1, $FF, $DC, $FF, $D7, $FF
	.byte	$D2, $FF, $CD, $FF, $CA, $FF, $C6, $FF, $C4, $FF, $C1, $FF, $C0, $FF, $BF, $FF
	.byte	$BE, $FF, $BF, $FF, $C0, $FF, $C1, $FF, $C4, $FF, $C6, $FF, $CA, $FF, $CD, $FF
	.byte	$D2, $FF, $D7, $FF, $DC, $FF, $E1, $FF, $E7, $FF, $ED, $FF, $F4, $FF, $FA, $FF
data_05DC04:
	; CDL: read by stage2_boss_pod_position; partly not accessed
	.byte	$30, $00, $50, $00, $20, $00, $60, $00, $10, $00, $70, $00, $2F, $00, $30, $00
	.byte	$31, $00, $32, $00, $33, $00, $34, $00, $00, $00, $00, $00, $2B, $00, $2C, $00
	.byte	$1D, $00, $21, $00, $2D, $00, $2E, $00, $00, $00, $00, $00
data_05DC30:
	; CDL: read by stage2_boss_stream_chr
	.byte	$00, $C0, $00, $C6
data_05DC34:
	; CDL: read by stage2_boss_stream_chr, td_play_turn_sound
	.byte	$00, $CC, $00, $01, $00, $01, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00
data_05DC44:
	; CDL: read by td_play_turn_sound; partly not accessed
	.byte	$40, $00, $26, $00, $27, $00, $28, $00, $29, $00, $2A, $00, $2B, $00, $2C, $00
	.byte	$2D, $00
data_05DC56:
	; CDL: read by update_td_enemy_bullet; partly not accessed
	.byte	$00, $08, $00, $06, $00, $0A, $00, $0C, $00, $08, $00, $0A
data_05DC62:
	; CDL: read by update_td_laser_shot; partly not accessed
	.byte	$04, $00, $12, $00, $20, $00, $2E, $00, $3C, $00, $4A, $00, $58, $00, $66, $00
	.byte	$74, $00, $82, $00, $90, $00, $9E, $00
data_05DC7A:
	; CDL: read by td_flicker_shot; partly not accessed
	.byte	$00, $0C, $00, $0A, $B6, $00, $C4, $00, $D2, $00, $E0, $00
data_05DC86:
	; CDL: read by td_homing_orb_frame
	.byte	$48, $01, $48, $01, $4A, $01, $4A, $01, $4A, $01, $4A, $C1, $4A, $C1, $4A, $C1
	.byte	$4C, $01, $4C, $01, $4E, $01, $4E, $01, $4E, $01, $4E, $C1, $4E, $C1, $4E, $C1
data_05DCA6:
	; CDL: read by td_homing_orb_frame
	.byte	$60, $01, $60, $01, $62, $01, $62, $01, $62, $01, $62, $C1, $62, $C1, $62, $C1
	.byte	$8E, $01, $8E, $01, $8E, $01, $8E, $01, $8E, $01, $8E, $01, $8E, $01, $8E, $01
data_05DCC6:
	; CDL: read by td_crush_blast_frame
	.byte	$11, $01, $88, $01, $8A, $01, $C0, $01, $C2, $01, $C4, $01, $00, $00, $00, $00
data_05DCD6:
	; CDL: read by td_crush_blast_frame
	.byte	$00, $0E, $00, $0E, $00, $0E, $00, $0C, $00, $0C, $00, $0C, $00, $0C, $00, $0C
data_05DCE6:
	; CDL: read by td_crush_blast_frame
	.byte	$04, $00, $08, $00, $08, $00, $08, $00, $08, $00, $08, $00, $08, $00, $08, $00
data_05DCF6:
	; CDL: read by td_homing_orb_steer; partly not accessed
	.byte	$00, $00, $01, $00, $02, $00
data_05DCFC:
	; CDL: read by update_td_flame_shot; partly not accessed
	.byte	$00, $00, $0C, $00, $18, $00, $24, $00, $30, $00, $3C, $00, $48, $00, $54, $00
	.byte	$60, $00, $6C, $00, $78, $00, $84, $00, $90, $00, $9C, $00, $90, $00, $B4, $00
	.byte	$C0, $00
data_05DD1E:
	; CDL: read by td_tile_whirl_player; partly not accessed
	.byte	$02, $00, $02, $00, $04, $00
data_05DD24:
	; CDL: read by td_tile_sand_pit; partly not accessed
	.byte	$01, $00, $03, $00, $05, $00
data_05DD2A:
	; CDL: read by td_wall_push_top_right, td_wall_push_bottom_right, td_wall_push_bottom_left (+1 more)
	.byte	$04, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $02, $00, $03, $00
	.byte	$04, $00, $05, $00, $01, $00, $01, $00, $00, $00, $01, $00, $02, $00, $03, $00
	.byte	$04, $00, $05, $00, $06, $00, $01, $00, $00, $00, $01, $00, $02, $00, $03, $00
	.byte	$04, $00, $05, $00, $06, $00, $07, $00, $00, $00, $01, $00, $02, $00, $03, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $02, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $02, $00, $03, $00
data_05DDAA:
	; CDL: read by td_wall_push_top_right, td_wall_push_bottom_right, td_wall_push_bottom_left (+1 more)
	.byte	$04, $00, $04, $00, $04, $00, $04, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $05, $00, $05, $00, $05, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $06, $00, $06, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $02, $00, $07, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $00, $00, $01, $00, $01, $00, $01, $00
	.byte	$02, $00, $02, $00, $02, $00, $02, $00, $00, $00, $01, $00, $02, $00, $02, $00
	.byte	$03, $00, $03, $00, $03, $00, $03, $00, $00, $00, $01, $00, $01, $00, $03, $00
data_05DE2A:
	; CDL: read by td_wall_push_top_left
	.byte	$01, $00, $01, $00, $02, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$01, $00, $02, $00, $02, $00, $03, $00, $00, $00, $00, $00, $00, $00, $01, $00
	.byte	$02, $00, $02, $00, $03, $00, $03, $00, $00, $00, $00, $00, $01, $00, $01, $00
	.byte	$02, $00, $03, $00, $03, $00, $04, $00, $00, $00, $01, $00, $01, $00, $02, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $01, $00, $01, $00, $02, $00, $00, $00, $00, $00, $00, $00, $00, $00
data_05DEAA:
	; CDL: read by td_trigger_trap; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $02, $00, $04, $00, $06, $00, $08, $00, $0A, $00
	.byte	$0C, $00, $0E, $00, $10, $00, $12, $00, $14, $00, $16, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $18, $00, $1A, $00, $1C, $00, $1E, $00, $20, $00, $22, $00
	.byte	$24, $00, $26, $00, $28, $00, $2A, $00, $2C, $00, $00, $00, $00, $00, $00, $00
data_05DEEA:
	; CDL: read by td_trigger_switch_event
	.byte	$34, $38, $50, $38
data_05DEEE:
	; CDL: read by td_trigger_switch_event
	.byte	$B0, $01, $90, $02
data_05DEF2:
	; CDL: read by td_trigger_switch_event
	.byte	$18, $22, $34, $22
data_05DEF6:
	; CDL: read by td_trigger_switch_event
	.byte	$D0, $00, $B0, $01
data_05DEFA:
	; CDL: read by td_trigger_switch_event
	.byte	$50, $04, $6C, $04
data_05DEFE:
	; CDL: read by td_trigger_switch_event
	.byte	$90, $02, $70, $03
data_05DF02:
	; CDL: read by td_get_map_object_at; partly not accessed
	.byte	$C0, $0A, $00, $00, $00, $00, $00, $0B, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $40, $0B, $80, $0B, $00, $00, $C0, $0B, $00, $00, $00, $00, $00, $00
data_05DF22:
	; CDL: read by td_get_map_object_at; partly not accessed
	.byte	$C0, $0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0B, $40, $0B
	.byte	$00, $00, $00, $00, $00, $00, $80, $0B, $C0, $0B, $00, $00, $00, $00, $00, $00
data_05DF42:
	; CDL: read by td_shot_tile_effect, td_tile_whirl_enemy
	.byte	$00, $20, $00, $10
data_05DF46:
	; CDL: read by td_whirl_around_cell
	.byte	$00, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	.byte	$01, $01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	.byte	$02, $02, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	.byte	$03, $03, $03, $04, $05, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	.byte	$04, $04, $04, $05, $05, $06, $07, $08, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F
	.byte	$05, $05, $05, $05, $06, $07, $07, $08, $09, $0A, $0B, $0C, $0D, $0D, $0E, $0F
	.byte	$06, $06, $06, $06, $07, $07, $08, $09, $0A, $0A, $0B, $0C, $0D, $0E, $0F, $10
	.byte	$07, $07, $07, $07, $08, $08, $09, $09, $0A, $0B, $0C, $0D, $0D, $0E, $0F, $10
	.byte	$08, $08, $08, $08, $08, $09, $0A, $0A, $0B, $0C, $0C, $0D, $0E, $0F, $10, $11
	.byte	$09, $09, $09, $09, $09, $0A, $0A, $0B, $0C, $0C, $0D, $0E, $0F, $0F, $10, $11
	.byte	$0A, $0A, $0A, $0A, $0A, $0B, $0B, $0C, $0C, $0D, $0E, $0E, $0F, $10, $11, $12
	.byte	$0B, $0B, $0B, $0B, $0B, $0C, $0C, $0D, $0D, $0E, $0E, $0F, $10, $11, $11, $12
	.byte	$0C, $0C, $0C, $0C, $0C, $0D, $0D, $0D, $0E, $0F, $0F, $10, $10, $11, $12, $13
	.byte	$0D, $0D, $0D, $0D, $0D, $0D, $0E, $0E, $0F, $0F, $10, $11, $11, $12, $13, $13
	.byte	$0E, $0E, $0E, $0E, $0E, $0E, $0F, $0F, $10, $10, $11, $11, $12, $13, $13, $14
	.byte	$0F, $0F, $0F, $0F, $0F, $0F, $10, $10, $11, $11, $12, $12, $13, $13, $14, $15
data_05E046:
	; CDL: read by td_check_nearest_target
	.byte	$00, $00, $C8, $3F, $C8, $3F, $C8, $3F, $00, $00, $C8, $7F, $C8, $7F, $C8, $7F
data_05E056:
	; CDL: read by td_check_nearest_target
	.byte	$C6, $3F, $C6, $3F, $00, $00, $C6, $BF, $C6, $BF, $C6, $BF, $00, $00, $C6, $3F
data_05E066:
	; CDL: read by td_check_nearest_target; partly not accessed
	.byte	$F0, $00, $F0, $00, $F0, $00, $F0, $00, $00, $00, $00, $00, $00, $00, $00, $00
data_05E076:
	; CDL: read by td_check_nearest_target; partly not accessed
	.byte	$18, $00, $18, $00, $D0, $00, $D0, $00, $D0, $00, $D0, $00, $18, $00, $18, $00
data_05E086:
	; CDL: read by td_check_nearest_target; partly not accessed
	.byte	$06, $00, $06, $00, $58, $00, $58, $00, $58, $00, $58, $00, $06, $00, $06, $00
data_05E096:
	; CDL: read by td_check_nearest_target_p2
	.byte	$00, $00, $C8, $3F, $C8, $3F, $C8, $3F, $00, $00, $C8, $7F, $C8, $7F, $C8, $7F
data_05E0A6:
	; CDL: read by td_check_nearest_target_p2
	.byte	$C6, $3F, $C6, $3F, $00, $00, $C6, $BF, $C6, $BF, $C6, $BF, $00, $00, $C6, $3F
data_05E0B6:
	; CDL: read by td_check_nearest_target_p2; partly not accessed
	.byte	$F0, $00, $F0, $00, $F0, $00, $F0, $00, $00, $00, $00, $00, $00, $00, $00, $00
data_05E0C6:
	; CDL: not accessed
	.byte	$18, $00, $18, $00, $D0, $00, $D0, $00, $D0, $00, $D0, $00, $18, $00, $18, $00
data_05E0D6:
	; CDL: read by td_check_nearest_target_p2; partly not accessed
	.byte	$78, $00, $78, $00, $D0, $00, $D0, $00, $D0, $00, $D0, $00, $78, $00
data_05E0E4:
	; CDL: read by td_check_nearest_target_p2, td_update_stage2_map_events
	.byte	$78, $00, $70, $00, $90, $00, $B0, $00, $D0, $00, $F0, $00, $10, $01, $30, $01
	.byte	$50, $01, $70, $01, $90, $01, $B0, $01, $50, $02, $70, $02, $90, $02, $B0, $02
	.byte	$D0, $02, $F0, $02, $10, $03, $30, $03, $50, $03, $70, $03
data_05E110:
	; CDL: read by td_update_stage2_map_events
	.byte	$90, $03, $B0, $01, $90, $02, $70, $02, $90, $02, $70, $02, $90, $02, $70, $02
	.byte	$90, $02, $70, $02, $90, $02, $70, $02, $70, $02, $90, $02, $70, $02, $90, $02
	.byte	$70, $02, $90, $02, $70, $02, $70, $00, $70, $00, $F0, $01
data_05E13C:
	; CDL: read by td_update_stage2_map_events
	.byte	$D0, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$10, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $0E, $00, $0C, $00
	.byte	$0A, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$08, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $06, $00, $04, $00
data_05E17C:
	; CDL: read by td_update_stage2_map_events
	.byte	$02, $00, $44, $00, $48, $00, $42, $00, $54, $00, $44, $00, $48, $00, $37, $00
data_05E18C:
	; CDL: read by td_update_stage2_map_events
	.byte	$58, $00, $45, $00, $49, $00, $76, $00, $77, $00, $4D, $00, $51, $00, $78, $00
data_05E19C:
	; CDL: read by td_update_stage2_map_events
	.byte	$78, $00, $46, $00, $4A, $00, $33, $00, $36, $00, $4E, $00, $52, $00, $37, $00
data_05E1AC:
	; CDL: read by td_update_stage2_map_events
	.byte	$58, $00, $47, $00, $4B, $00, $43, $00, $55, $00, $4F, $00, $53, $00, $37, $00
data_05E1BC:
	; CDL: read by td_update_stage2_map_events
	.byte	$58, $00, $08, $1E, $08, $22, $08, $20, $08, $20, $08, $1E, $08, $22, $08, $20
data_05E1CC:
	; CDL: read by td_update_stage2_map_events
	.byte	$08, $20, $0C, $1E, $0C, $22, $0C, $20, $0C, $20, $0C, $1E, $0C, $22, $0C, $20
data_05E1DC:
	; CDL: read by td_update_stage2_map_events
	.byte	$0C, $20, $10, $1E, $10, $22, $10, $20, $10, $20, $10, $1E, $10, $22, $10, $20
data_05E1EC:
	; CDL: read by td_update_stage2_map_events
	.byte	$10, $20, $14, $1E, $14, $22, $14, $20, $14, $20, $14, $1E, $14, $22, $14, $20
data_05E1FC:
	; CDL: read by td_update_stage2_map_events
	.byte	$14, $20, $68, $16, $68, $1A, $68, $18, $68, $18, $68, $16, $68, $1A, $68, $18
data_05E20C:
	; CDL: read by td_update_stage2_map_events
	.byte	$68, $18, $6C, $16, $6C, $1A, $6C, $18, $6C, $18, $6C, $16, $6C, $1A, $6C, $18
data_05E21C:
	; CDL: read by td_update_stage2_map_events
	.byte	$6C, $18, $70, $16, $70, $1A, $70, $18, $70, $18, $70, $16, $70, $1A, $70, $18
data_05E22C:
	; CDL: read by td_update_stage2_map_events
	.byte	$70, $18, $74, $16, $74, $1A, $74, $18, $74, $18, $74, $16, $74, $1A, $74, $18
data_05E23C:
	; CDL: read by td_update_stage2_map_events
	.byte	$74, $18, $0C, $1A, $10, $28, $14, $26, $18, $28, $1C, $26, $20, $28, $24, $26
	.byte	$28, $28, $2C, $26, $30, $28, $34, $26, $48, $26, $4C, $28, $50, $26, $54, $28
	.byte	$58, $26, $5C, $28, $60, $26, $64, $06, $68, $06, $6C, $1E, $70, $0C
data_05E26A:
	; CDL: read by td_step_switch_event
	.byte	$10, $00, $0F, $00, $0C, $00
data_05E270:
	; CDL: read by td_step_switch_event
	.byte	$20, $00, $E0, $FF
data_05E274:
	; CDL: read by td_step_switch_event
	.byte	$04, $00
data_05E276:
	; CDL: read by td_step_switch_event, td_patch_switch_event_block
	.byte	$FC, $FF, $17, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$16, $00, $16, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$17, $00
ptrs_05E298:
	.addr	data_05E2E6
	.addr	data_05E2E6
	.addr	data_05E2E6
	.addr	data_05E2D6
	.addr	data_05E2D6
	.addr	data_05E2D6
	.addr	data_05E2D6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2C6
	.addr	data_05E2B6
data_05E2B6:
	; CDL: not accessed
	.byte	$EF, $EE, $EC, $EB, $EA, $E8, $E7, $E5, $E4, $E5, $E7, $E8, $EA, $EB, $EC, $EE
data_05E2C6:
	; CDL: not accessed
	.byte	$9F, $9C, $99, $96, $93, $90, $8D, $8A, $87, $8A, $8D, $90, $93, $96, $99, $9C
data_05E2D6:
	; CDL: not accessed
	.byte	$6F, $6E, $6C, $6B, $6A, $68, $67, $65, $64, $65, $67, $68, $6A, $6B, $6C, $6E
data_05E2E6:
	; CDL: not accessed
	.byte	$3F, $3C, $39, $36, $33, $30, $2D, $2A, $27, $2A, $2D, $30, $33, $36, $39, $3C
window_widths_05E2F6:
	.byte	$00, $00, $05, $00, $07, $00, $09, $00, $0A, $00, $0B, $00, $0C, $00, $0D, $00
	.byte	$0D, $00, $0E, $00, $0E, $00, $0F, $00, $0F, $00, $0F, $00, $0F, $00, $0F, $00
	.byte	$10, $00, $0F, $00, $0F, $00, $0F, $00, $0F, $00, $0F, $00, $0E, $00, $0E, $00
	.byte	$0D, $00, $0D, $00, $0C, $00, $0B, $00, $0A, $00, $09, $00, $07, $00, $05, $00
data_05E336:
	; CDL: read by build_window_circle; partly not accessed
	.byte	$00, $16, $1F, $27, $2D, $32, $37, $3B, $3F, $43, $46, $4A, $4D, $50, $53, $56
	.byte	$59, $5B, $5E, $60, $63, $65, $67, $6A, $6C, $6E, $70, $72, $74, $76, $78, $7A
	.byte	$7B, $7D, $7F, $81, $82, $84, $86, $87, $89, $8A, $8C, $8E, $8F, $90, $92, $93
	.byte	$95, $96, $97, $99, $9A, $9B, $9D, $9E, $9F, $A1, $A2, $A3, $A4, $A5, $A7, $A8
	.byte	$A9, $AA, $AB, $AC, $AD, $AE, $AF, $B0, $B1, $B3, $B4, $B5, $B6, $B7, $B7, $B8
	.byte	$B9, $BA, $BB, $BC, $BD, $BE, $BF, $C0, $C1, $C2, $C2, $C3, $C4, $C5, $C6, $C7
	.byte	$C7, $C8, $C9, $CA, $CA, $CB, $CC, $CD, $CD, $CE, $CF, $D0, $D0, $D1, $D2, $D2
	.byte	$D3, $D4, $D5, $D5, $D6, $D6, $D7, $D8, $D8, $D9, $DA, $DA, $DB, $DB, $DC, $DD
	.byte	$DD, $DE, $DE, $DF, $DF, $E0, $E1, $E1, $E2, $E2, $E3, $E3, $E4, $E4, $E5, $E5
	.byte	$E6, $E6, $E7, $E7, $E8, $E8, $E9, $E9, $E9, $EA, $EA, $EB, $EB, $EC, $EC, $EC
	.byte	$ED, $ED, $EE, $EE, $EE, $EF, $EF, $F0, $F0, $F0, $F1, $F1, $F1, $F2, $F2, $F2
	.byte	$F3, $F3, $F3, $F4, $F4, $F4, $F5, $F5, $F5, $F5, $F6, $F6, $F6, $F7, $F7, $F7
	.byte	$F7, $F8, $F8, $F8, $F8, $F9, $F9, $F9, $F9, $FA, $FA, $FA, $FA, $FA, $FB, $FB
	.byte	$FB, $FB, $FB, $FC, $FC, $FC, $FC, $FC, $FC, $FD, $FD, $FD, $FD, $FD, $FD, $FD
	.byte	$FD, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
data_05E43E:
	; CDL: not accessed
	.byte	$13, $00, $11, $00
data_05E442:
	; CDL: not accessed
	.byte	$13, $00, $11, $00
td_enemy_scores:
	; CDL: read by td_get_enemy_points; partly not accessed
	.byte	$00, $00, $00, $05, $80, $01, $00, $10, $10, $00, $00, $02, $00, $02, $00, $10
	.byte	$00, $00, $00, $20, $00, $10, $10, $00, $00, $05, $10, $00, $00, $01, $00, $04
	.byte	$00, $20, $00, $24, $00, $20, $10, $00
td_map_object_scores:
	; CDL: read by td_get_kill_points; partly not accessed
	.byte	$00, $00, $00, $20, $00, $20, $00, $00, $99, $99, $00, $10, $00, $05, $00, $20
	.byte	$99, $99, $00, $00, $00, $10, $10, $00, $00, $20, $00, $20, $00, $20, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $10, $00
	; CDL: read by copy_hdma_table
hdma_table_05E496:
	.byte	$18, $09, $01, $07, $00, $09, $00, $07, $00
hdma_table_05E49F:
	.byte	$18, $00, $01, $40, $00, $00, $00
	.byte	$40, $00
hdma_table_05E4A8:
	.byte	$18, $0F, $01, $00, $00, $0F, $00, $00, $00
hdma_table_05E4B1:
	.byte	$18, $04, $01, $13, $00
	.byte	$04, $00, $13, $00
hdma_table_05E4BA:
	.byte	$18, $00, $01, $13, $00, $00, $00, $13, $00
hdma_table_05E4C3:
	.byte	$04, $09, $64
	.byte	$07, $10, $09, $01, $07, $00
hdma_table_05E4CC:
	.byte	$04, $00, $64, $40, $10, $00, $01, $40, $00
hdma_table_05E4D5:
	.byte	$04
	.byte	$0F, $64, $00, $10, $0F, $01, $00, $00
hdma_table_05E4DE:
	.byte	$06, $00, $62, $13, $10, $04, $01, $13
	.byte	$00
hdma_table_05E4E7:
	.byte	$04, $00, $64, $13, $10, $00, $01, $13, $00
sine_table:
	; CDL: read by copy_hdma_table, compute_m7_matrix, compute_p2_m7_matrix
	.byte	$00, $00, $24, $03, $47, $06, $6A, $09, $8B, $0C, $AB, $0F, $C8, $12, $E2, $15
	.byte	$F8, $18, $0B, $1C, $19, $1F, $23, $22, $28, $25, $26, $28, $1F, $2B, $11, $2E
	.byte	$FB, $30, $DE, $33, $BA, $36, $8C, $39, $56, $3C, $17, $3F, $CE, $41, $7A, $44
	.byte	$1C, $47, $B4, $49, $3F, $4C, $BF, $4E, $33, $51, $9B, $53, $F5, $55, $42, $58
	.byte	$82, $5A, $B4, $5C, $D7, $5E, $EC, $60, $F2, $62, $E8, $64, $CF, $66, $A6, $68
	.byte	$6D, $6A, $24, $6C, $CA, $6D, $5F, $6F, $E2, $70, $55, $72, $B5, $73, $04, $75
	.byte	$41, $76, $6C, $77, $84, $78, $8A, $79, $7D, $7A, $5D, $7B, $29, $7C, $E3, $7C
	.byte	$8A, $7D, $1D, $7E, $9D, $7E, $09, $7F, $62, $7F, $A7, $7F, $D8, $7F, $F6, $7F
cosine_table:
	; CDL: read by compute_m7_matrix, compute_p2_m7_matrix
	.byte	$00, $80, $F6, $7F, $D8, $7F, $A7, $7F, $62, $7F, $09, $7F, $9D, $7E, $1D, $7E
	.byte	$8A, $7D, $E3, $7C, $29, $7C, $5D, $7B, $7D, $7A, $8A, $79, $84, $78, $6C, $77
	.byte	$41, $76, $04, $75, $B5, $73, $55, $72, $E2, $70, $5F, $6F, $CA, $6D, $24, $6C
	.byte	$6D, $6A, $A6, $68, $CF, $66, $E8, $64, $F2, $62, $EC, $60, $D7, $5E, $B4, $5C
	.byte	$82, $5A, $42, $58, $F5, $55, $9B, $53, $33, $51, $BF, $4E, $3F, $4C, $B4, $49
	.byte	$1C, $47, $7A, $44, $CE, $41, $17, $3F, $56, $3C, $8C, $39, $BA, $36, $DE, $33
	.byte	$FB, $30, $11, $2E, $1F, $2B, $26, $28, $28, $25, $23, $22, $19, $1F, $0B, $1C
	.byte	$F8, $18, $E2, $15, $C8, $12, $AB, $0F, $8B, $0C, $6A, $09, $47, $06, $24, $03
	.byte	$00, $00, $24, $03, $47, $06, $6A, $09, $8B, $0C, $AB, $0F, $C8, $12, $E2, $15
	.byte	$F8, $18, $0B, $1C, $19, $1F, $23, $22, $28, $25, $26, $28, $1F, $2B, $11, $2E
	.byte	$FB, $30, $DE, $33, $BA, $36, $8C, $39, $56, $3C, $17, $3F, $CE, $41, $7A, $44
	.byte	$1C, $47, $B4, $49, $3F, $4C, $BF, $4E, $33, $51, $9B, $53, $F5, $55, $42, $58
	.byte	$82, $5A, $B4, $5C, $D7, $5E, $EC, $60, $F2, $62, $E8, $64, $CF, $66, $A6, $68
	.byte	$6D, $6A, $24, $6C, $CA, $6D, $5F, $6F, $E2, $70, $55, $72, $B5, $73, $04, $75
	.byte	$41, $76, $6C, $77, $84, $78, $8A, $79, $7D, $7A, $5D, $7B, $29, $7C, $E3, $7C
	.byte	$8A, $7D, $1D, $7E, $9D, $7E, $09, $7F, $62, $7F, $A7, $7F, $D8, $7F, $F6, $7F
stage5_boss_hp:
	; CDL: read by stage5_boss_state_0; partly not accessed
	.word	ENEMY_HP($0200), ENEMY_HP($0400), ENEMY_HP($0800)
data_05E676:
	; CDL: read by stage5_boss_stream_chr
	.byte	$00, $C5, $80, $C2, $00, $C0, $80, $C7
data_05E67E:
	; CDL: read by stage5_boss_spit_step_2
	.byte	$00, $03, $20, $03, $40, $03, $60, $03, $80, $03, $A0, $03, $C0, $03, $E0, $03
data_05E68E:
	; CDL: read by stage5_boss_spawn_spit
	.byte	$00, $00, $04, $00, $00, $00, $FC, $FF
data_05E696:
	; CDL: read by stage5_boss_spawn_spit
	.byte	$FC, $FF, $00, $00, $04, $00, $00, $00
data_05E69E:
	; CDL: read by stage5_boss_flash_on_hit
	.byte	$6A, $8E, $8A, $8E, $AA, $8E, $8A, $8E
data_05E6A6:
	; CDL: read by stage5_boss_spawn_arm
	.byte	$00, $02, $30, $02, $00, $02, $D0, $01
data_05E6AE:
	; CDL: read by stage5_boss_spawn_arm
	.byte	$CC, $01, $00, $02, $30, $02, $00, $02
stage5_boss_claw_hp:
	; CDL: read by stage5_boss_claw_state_0; partly not accessed
	.word	ENEMY_HP($0020), ENEMY_HP($0080), ENEMY_HP($0100)
data_05E6BC:
	; CDL: read by stage5_boss_arm_segment_state_4
	.byte	$A0, $01, $A2, $01, $A4, $01, $8E, $01
data_05E6C4:
	; CDL: read by stage5_boss_arm_segment_state_4
	.byte	$00, $2C, $00, $2C, $00, $2C, $00, $2A
td_nest_hp:
	; CDL: read by td_nest_state_0
	.word	ENEMY_HP($0020), ENEMY_HP($0050), ENEMY_HP($0080)
gun_hatch_hp:
	; CDL: read by gun_hatch_state_0
	.word	ENEMY_HP($0020), ENEMY_HP($0050), ENEMY_HP($0080)
data_05E6D8:
	; CDL: not accessed
	.byte	$40, $00, $30, $00, $20, $00
data_05E6DE:
	; CDL: read by gun_hatch_behind_state_2; partly not accessed
	.byte	$80, $00, $60, $00, $40, $00
; addresses of the 40 shot slots ($0AC0 + n * SHOT_SIZE), searched by find_free_shot_slot
shot_slot_addresses:
	; CDL: read by find_free_shot_slot
	.byte	$C0, $0A, $E0, $0A, $00, $0B, $20, $0B, $40, $0B, $60, $0B, $80, $0B, $A0, $0B
	.byte	$C0, $0B, $E0, $0B, $00, $0C, $20, $0C, $40, $0C, $60, $0C, $80, $0C, $A0, $0C
	.byte	$C0, $0C
	; CDL: not accessed
	.byte	$E0, $0C, $00, $0D, $20, $0D, $40, $0D, $60, $0D, $80, $0D, $A0, $0D, $C0, $0D
	.byte	$E0, $0D, $00, $0E, $20, $0E, $40, $0E, $60, $0E, $80, $0E, $A0, $0E, $C0, $0E
	.byte	$E0, $0E, $00, $0F, $20, $0F, $40, $0F, $60, $0F, $80, $0F, $A0, $0F
; shot type of the sparks of an ending firework, by its +$14 (0-3)
firework_spark_types:
	; CDL: read by spawn_firework_sparks
	.byte	$17, $00, $18, $00, $19, $00, $1A, $00
; last spark index of an ending firework, by its +$14 (16 sparks each)
firework_spark_counts:
	; CDL: read by spawn_firework_sparks
	.byte	$0F, $00, $0F, $00, $0F, $00, $0F, $00
; speeds of radial_spark_velocity (bytes), by spark direction / 8
radial_spark_speeds:
	; CDL: read by radial_spark_velocity
	.byte	$60, $00, $80, $00
data_05E748:
	; CDL: not accessed
	.byte	$04, $00, $06, $00, $08, $00, $0A, $00, $0C, $00, $0E, $00, $20, $00, $22, $00
	.byte	$24, $00, $22, $80, $20, $80, $0E, $80, $0C, $80, $0A, $80, $08, $80, $06, $80
	.byte	$04, $80, $06, $C0, $08, $C0, $0A, $C0, $0C, $C0, $0E, $C0, $20, $C0, $22, $C0
	.byte	$24, $C0, $22, $40, $20, $40, $0E, $40, $0C, $40, $0A, $40, $08, $40, $06, $40
data_05E788:
	; CDL: read by draw_p1_start_cursor, draw_p2_start_cursor
	.byte	$2B, $00, $5E, $00, $91, $00, $C4, $00
data_05E790:
	; CDL: read by draw_p1_start_cursor, draw_p2_start_cursor
	.byte	$2A, $00, $5D, $00, $90, $00
data_05E796:
	; CDL: read by draw_p1_start_cursor, draw_intro_banner_sprites
	.byte	$C3, $00, $30, $00, $40, $00, $50, $00, $60, $00, $70, $00, $80, $00, $90, $00
	.byte	$A0, $00, $B0, $00
data_05E7AA:
	; CDL: read by draw_intro_banner_sprites
	.byte	$C0, $00, $40, $3F, $42, $3F, $44, $3F, $46, $3F, $48, $3F, $4A, $3F, $4C, $3F
	.byte	$4E, $3F, $60, $3F, $62, $3F
data_05E7C0:
	; CDL: read by start_palette_task_at, palette_task_animate, update_objects (+2 more); partly not accessed
	.byte	$28, $3F, $28, $37, $2E, $3D, $2E, $3F
vram_blocks_05E7C8:
	.byte	$A0, $73, $20, $74, $E0, $73, $C0, $73
	.byte	$40, $74, $E0, $73, $00, $72, $80, $72, $00, $73
vram_blocks_05E7DA:
	.byte	$60, $74, $80, $74, $00, $6D
	.byte	$20, $6D
palette_task_05E7E2:
	palette_animate	$00, $00
	palette_copy	palette_088728, $2340
	palette_copy_end
anim_05E7EB:
	anim_frame	$0008, metasprite_06BE3E, $0000
	anim_frame	$0006, metasprite_06BE5B, $0000
	anim_frame	$0004, metasprite_06BE74, $0000
	anim_frame	$0002, metasprite_06BE85, $0000
	anim_end	$0000, $0000
data_05E809:
	; CDL: read by stage3_robot_state_02; partly not accessed
	.byte	$40, $00, $30, $00, $10, $00
data_05E80F:
	; CDL: read by stage3_second_robot_state_02; partly not accessed
	.byte	$79, $00, $59, $00, $29, $00
data_05E815:
	; CDL: read by stage3_robot_state_00
	.addr	metasprite_06BCFE, metasprite_06C0C8
data_05E819:
	; CDL: read by update_objects, stage3_robot_state_00; partly not accessed
	.byte	$00, $36, $00, $38
anim_05E81D:
	anim_frame	$0008, metasprite_06BBDA, metasprite_06BF28
	anim_end	metasprite_06BC2F, metasprite_06BF7D
anim_05E829:
	anim_frame	$0008, metasprite_06BBDA, metasprite_06BF28
	anim_end	metasprite_06BB40, metasprite_06BE8E
anim_05E835:
	anim_end	metasprite_06BCAD, metasprite_06BFFB
anim_05E83B:
	anim_end	metasprite_06BC2F, metasprite_06BF7D
anim_05E841:
	anim_end	metasprite_06BC88, metasprite_06BFD6
anim_05E847:
	anim_frame	$0002, metasprite_06BB95, metasprite_06BEE3
	anim_frame	$0002, metasprite_06BB40, metasprite_06BE8E
	anim_goto	anim_05E847
data_05E855:
	; CDL: read by stage3_robot_state_02
	.byte	$01, $00, $FF, $FF
data_05E859:
	; CDL: read by stage3_robot_state_02
	.byte	$02, $00, $FE, $FF
data_05E85D:
	; CDL: read by stage3_robot_state_02
	.byte	$00, $00, $02, $00
data_05E861:
	; CDL: read by update_objects, stage3_second_robot_spawn_debris; partly not accessed
	.addr	metasprite_06BD4B, metasprite_06C119
	.byte	$00, $00, $DA, $BB, $28, $BF
anim_05E86B:
	anim_frame	$0018, metasprite_06BE00, metasprite_06C0AB
anim_05E871:
	anim_frame	$0006, metasprite_06BDA1, metasprite_06C04C
	anim_frame	$0006, metasprite_06BDC6, metasprite_06C071
	anim_frame	$0006, metasprite_06BDE3, metasprite_06C08E
	anim_frame	$0008, metasprite_06BDC6, metasprite_06C071
	anim_goto	anim_05E871
anim_05E88B:
	anim_frame	$0008, metasprite_06BD50, metasprite_06C11E
	anim_frame	$0008, metasprite_06BCAD, metasprite_06BFFB
	anim_goto	anim_05E88B
data_05E899:
	; CDL: read by stage3_second_robot_spawn_debris
	.byte	$20, $00, $50, $00
data_05E89D:
	; CDL: read by stage3_second_robot_spawn_debris; partly not accessed
	.byte	$24, $00, $F0, $FF, $00, $02, $00, $04, $00, $08
data_05E8A7:
	; CDL: read by stage3_boss_state_06
	.byte	$0A, $00, $2A, $00
data_05E8AB:
	; CDL: read by stage3_boss_state_06
	.byte	$10, $00, $30, $00
data_05E8AF:
	; CDL: read by stage3_boss_state_06
	.byte	$16, $00, $36, $00
data_05E8B3:
	; CDL: read by stage3_boss_state_06
	.byte	$1E, $00, $FC, $FF
data_05E8B7:
	; CDL: read by stage3_boss_state_0C
	.byte	$40, $00, $0B, $00, $40, $00, $0B, $00
data_05E8BF:
	; CDL: read by stage3_boss_state_0C
	.byte	$8C, $41, $0C, $42
data_05E8C3:
	; CDL: read by skeleton_eye_fireball_state_01
	.addr	metasprite_06AF82, metasprite_06AF87, metasprite_06AF8C, metasprite_06AF91
	.addr	metasprite_06AF82, metasprite_06AF87, metasprite_06AF8C, metasprite_06AF91
data_05E8D3:
	; CDL: read by skeleton_eye_fireball_state_01
	.byte	$FD, $FF, $FE, $FF
data_05E8D7:
	; CDL: read by skeleton_eye_fireball_state_01
	.byte	$00, $00, $02, $00, $03, $00, $02, $00, $00, $00, $FE, $FF, $FD, $FF, $FE, $FF
data_05E8E7:
	; CDL: read by stage3_boss_break_wall
	.byte	$04, $00, $10, $00
data_05E8EB:
	; CDL: read by stage3_boss_break_wall
	.byte	$FF, $FF, $01, $00
data_05E8EF:
	; CDL: read by stage3_boss_break_wall
	.byte	$01, $E9, $71, $E9, $01, $EA
data_05E8F5:
	; CDL: read by stage3_boss_break_wall
	.byte	$0C, $41, $08, $41, $04, $41
data_05E8FB:
	; CDL: read by queue_vram_blocks_at_x, stage3_boss_break_wall
	.byte	$10, $41, $14, $41, $18, $41, $60, $6F, $20, $60, $A0, $62, $E0, $72, $00, $70
	.byte	$20, $61, $40, $75, $80, $71, $40, $76, $00, $77, $C0, $77, $80, $78, $60, $76
	.byte	$20, $77, $E0, $77, $A0, $78, $40, $79, $00, $7A, $C0, $7A, $80, $7B, $60, $79
	.byte	$20, $7A, $E0, $7A, $A0, $7B, $40, $7C, $00, $7D, $C0, $7D, $80, $7E, $60, $7C
	.byte	$20, $7D, $E0, $7D, $A0, $7E, $80, $75, $00, $7F, $80, $75, $60, $75, $60, $75
	.byte	$80, $75, $60, $7F, $80, $75, $80, $75, $00, $80, $80, $75, $60, $75, $60, $75
	.byte	$80, $75, $60, $80, $80, $75, $80, $75, $60, $75, $80, $75, $60, $75, $60, $75
	.byte	$80, $75, $60, $75, $80, $75, $40, $6F, $C0, $6F, $40, $72, $C0, $72, $20, $70
	.byte	$A0, $70, $20, $71, $A0, $71, $20, $76, $E0, $76, $A0, $77, $60, $78, $80, $76
	.byte	$40, $77, $00, $78, $C0, $78, $20, $79, $E0, $79, $A0, $7A, $60, $7B, $80, $79
	.byte	$40, $7A, $00, $7B, $C0, $7B, $20, $7C, $E0, $7C, $A0, $7D, $60, $7E, $80, $7C
	.byte	$40, $7D, $00, $7E, $C0, $7E, $60, $6F, $20, $60, $40, $7F, $E0, $72, $00, $70
	.byte	$20, $7F, $40, $75, $80, $71, $C0, $7F, $00, $77, $40, $80, $A0, $80, $E0, $7F
	.byte	$20, $80, $E0, $77, $C0, $80, $00, $81, $00, $7A, $60, $75, $60, $81, $20, $81
	.byte	$60, $75, $E0, $7A, $80, $81, $C0, $81, $00, $82, $60, $75, $A0, $64, $E0, $81
	.byte	$60, $75, $A0, $65, $60, $64, $60, $75, $C0, $63, $60, $75, $80, $75, $80, $75
	.byte	$60, $75, $60, $5D, $60, $75, $20, $6F, $A0, $6F, $20, $72, $A0, $72, $40, $70
	.byte	$C0, $70, $40, $71, $C0, $71, $00, $76, $C0, $76, $80, $77, $40, $78, $A0, $76
	.byte	$60, $77, $20, $78, $E0, $78, $00, $79, $C0, $79, $80, $7A, $40, $7B, $A0, $79
	.byte	$60, $7A, $20, $7B, $E0, $7B, $00, $7C, $C0, $7C, $80, $7D, $40, $7E, $A0, $7C
	.byte	$60, $7D, $20, $7E, $E0, $7E, $40, $6F, $C0, $6F, $40, $72, $80, $7F, $20, $70
	.byte	$A0, $70, $20, $71, $A0, $7F, $20, $76, $E0, $76, $A0, $77, $80, $80, $80, $76
	.byte	$40, $77, $00, $78, $E0, $80, $20, $79, $E0, $79, $A0, $7A, $40, $81, $80, $79
	.byte	$40, $7A, $00, $7B, $A0, $81, $20, $7C, $E0, $7C, $40, $82, $20, $65, $80, $7C
	.byte	$20, $82, $00, $7E, $20, $64, $60, $6F, $20, $60, $E0, $5D, $A0, $75, $00, $70
	.byte	$40, $63, $40, $75, $C0, $75
data_05EA91:
	; CDL: read by stage3_boss_queue_tiles
	.byte	$D9, $EA, $F1, $EA, $09, $EB, $F1, $EA, $D9, $EA, $C1, $EA, $A9, $EA, $C1, $EA
data_05EAA1:
	; CDL: read by queue_vram_blocks_at_x, stage3_boss_spawn_debris_sparks
	.byte	$78, $7C, $80, $7C, $78, $74, $70, $74, $00, $BE, $20, $BE, $80, $BE, $A0, $BE
	.byte	$00, $BF, $20, $BF, $80, $BF, $A0, $BF, $40, $BE, $60, $BE, $C0, $BE, $E0, $BE
	.byte	$00, $BD, $20, $BD, $80, $BD, $A0, $BD, $40, $BC, $60, $BC, $C0, $BC, $E0, $BC
	.byte	$40, $BD, $60, $BD, $C0, $BD, $E0, $BD, $80, $B9, $A0, $B9, $20, $BA, $40, $BA
	.byte	$00, $BB, $20, $BB, $C0, $BB, $E0, $BB, $00, $BC, $20, $BC, $80, $BC, $A0, $BC
	.byte	$40, $BF, $60, $BF, $C0, $BF, $E0, $BF, $00, $C0, $20, $C0, $80, $C0, $A0, $C0
	.byte	$00, $C1, $20, $C1, $80, $C1, $A0, $C1, $40, $C0, $60, $C0, $C0, $C0, $E0, $C0
	.byte	$40, $C1, $60, $C1, $C0, $C1, $E0, $C1, $00, $C2, $20, $C2, $40, $C2, $60, $C2
vram_blocks_05EB21:
	.byte	$20, $60, $20, $61, $E0, $6F, $E0, $5C, $A0, $62, $40, $75, $A0, $5F, $00, $71
data_05EB31:
	; CDL: read by update_objects, stage3_boss_spawn_debris_sparks; partly not accessed
	.byte	$00, $40, $00, $74, $00, $C8
anim_05EB37:
	anim_frame	$0002, metasprite_06AECF, metasprite_06AECF
	anim_frame	$0002, metasprite_06AF11, metasprite_06AF11
	anim_goto	anim_05EB37
load_list_05EB45:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7000, gfx_0AE033
	load_end
data_05EB4E:
	; CDL: read by stage3_boss_state_0E
	.byte	$00, $01, $40, $01, $00, $06
data_05EB54:
	; CDL: read by update_objects, stage3_boss_state_0E; partly not accessed
	.byte	$02, $00, $04, $00, $06, $00
anim_05EB5A:
	anim_frame	$0020, metasprite_06C218, metasprite_06C218
	anim_frame	$0020, metasprite_06C22D, metasprite_06C22D
	anim_frame	$0020, metasprite_06C242, metasprite_06C242
	anim_frame	$0020, metasprite_06C284, metasprite_06C284
	anim_end	$0000, $0000
data_05EB78:
	; CDL: read by skeleton_eye_fireball_state_00; partly not accessed
	.byte	$B8, $00, $D0, $00, $20, $01
data_05EB7E:
	; CDL: read by stage4_controller_state_0C
	.byte	$90, $09, $D0, $06, $30, $06, $00, $00, $80, $05, $00, $03, $00, $00
data_05EB8C:
	; CDL: read by stage4_controller_state_0C
	.byte	$80, $FD, $80, $FF, $80, $FE, $00, $00, $80, $FE, $80, $FF, $40, $FC
data_05EB9A:
	; CDL: read by rideable_missile_state_07
	.byte	$49, $69, $89, $A9
data_05EB9E:
	; CDL: read by rideable_missile_state_07
	.byte	$80, $A0, $C0, $E0
data_05EBA2:
	; CDL: read by rideable_missile_state_07
	.byte	$00, $28, $00, $28, $00, $88
data_05EBA8:
	; CDL: read by queue_vram_blocks_at_x, update_stage4_boss_pod
	.addr	vram_blocks_05EBAC, vram_blocks_05EBB0
vram_blocks_05EBAC:
	.byte	$A0, $B5, $C0, $B5
vram_blocks_05EBB0:
	.byte	$00, $B7, $E0, $B5
data_05EBB4:
	; CDL: read by update_objects, update_stage4_boss_pod; partly not accessed
	.byte	$10, $4C, $90, $4E
anim_05EBB8:
	anim_frame	$0010, $0000, $0000
	anim_frame	$0010, metasprite_06C770, $0000
	anim_goto	anim_05EBB8
data_05EBC6:
	; CDL: read by update_objects, update_destructible_part, sub_049A54
	.addr	anim_05EBCA, anim_05EBD8
anim_05EBCA:
	anim_frame	$0001, metasprite_06AF87, $3200
	anim_frame	$0001, metasprite_06AF87, $3E00
	anim_goto	anim_05EBCA
anim_05EBD8:
	anim_frame	$0001, metasprite_06AF91, $3200
	anim_frame	$0001, metasprite_06AF91, $3E00
	anim_goto	anim_05EBD8
data_05EBE6:
	; CDL: read by queue_vram_blocks_at_x, sub_049A54; partly not accessed
	.byte	$03, $00, $FD, $FF, $02, $EC, $0C, $EC, $1A, $EC, $26, $EC, $05, $00, $07, $00
	.byte	$06, $00, $07, $00, $04, $40, $80, $40, $04, $41, $80, $41, $60, $53, $80, $53
	.byte	$A0, $53, $C0, $53, $E0, $53, $80, $55, $A0, $55, $00, $52, $20, $52, $40, $52
	.byte	$60, $52, $40, $53, $00, $53, $80, $52, $A0, $52, $C0, $52, $E0, $52, $20, $53
vram_blocks_05EC26:
	.byte	$00, $50, $00, $50, $40, $51, $60, $51, $C0, $51, $E0, $51, $00, $50
vram_blocks_05EC34:
	.byte	$00, $50
	.byte	$00, $50, $00, $50, $00, $50
data_05EC3C:
	; CDL: read by queue_vram_blocks_at_x, rideable_missile_state_01
	.addr	vram_blocks_05EC44, vram_blocks_05EC50, vram_blocks_05EC5C, vram_blocks_05EC68
vram_blocks_05EC44:
	.byte	$60, $53, $80, $53, $A0, $53, $C0, $53
	.byte	$E0, $53, $00, $50
vram_blocks_05EC50:
	.byte	$00, $50, $60, $53, $00, $54, $20, $54, $40, $54, $60, $54
vram_blocks_05EC5C:
	.byte	$00, $50, $00, $50, $80, $54, $A0, $54, $80, $53, $C0, $54
vram_blocks_05EC68:
	.byte	$00, $50, $E0, $54
	.byte	$00, $55, $20, $55, $C0, $54, $00, $50
data_05EC74:
	; CDL: read by queue_vram_blocks_at_x, rideable_missile_state_01
	.addr	vram_blocks_05EC7A, vram_blocks_05EC7E, vram_blocks_05EC82
vram_blocks_05EC7A:
	.byte	$40, $55, $60, $55
vram_blocks_05EC7E:
	.byte	$80, $55, $A0, $55
vram_blocks_05EC82:
	.byte	$C0, $55
	.byte	$E0, $55
data_05EC86:
	; CDL: read by rideable_missile_set_hdma
	.byte	$06, $00, $0B, $00, $10, $00, $15, $00
data_05EC8E:
	; CDL: read by stage4_boss_init_part
	.byte	$6A, $00, $53, $00
data_05EC92:
	; CDL: read by stage4_boss_init_part
	.byte	$11, $40, $3D, $00
data_05EC96:
	; CDL: read by stage4_boss_init_part
	.addr	anim_05ECA2, anim_05ECA8
data_05EC9A:
	; CDL: read by stage4_boss_init_part
	.byte	$18, $00, $18, $00
data_05EC9E:
	; CDL: read by update_objects, stage4_boss_init_part; partly not accessed
	.byte	$E8, $FF, $80, $FF
anim_05ECA2:
	anim_end	metasprite_06C781, metasprite_06C792
anim_05ECA8:
	anim_frame	$0001, metasprite_06C7A3, $0000
	anim_frame	$0001, metasprite_06C7C4, $0000
	anim_goto	anim_05ECA8
data_05ECB6:
	; CDL: read by rideable_missile_state_06
	.byte	$F9, $FF, $FA, $FF, $FB, $FF, $FC, $FF
data_05ECBE:
	; CDL: read by queue_vram_blocks_at_x, stage4_spawn_hoverbike_rider; partly not accessed
	.byte	$38, $00, $30, $00, $28, $00, $A0, $51
vram_blocks_05ECC6:
	.byte	$80, $51, $E0, $5B, $E0, $5F, $E0, $5F
	.byte	$00, $60
load_list_05ECD0:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7800, gfx_0E9F5E
	load_end
load_list_05ECD9:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_0FD147
	load_end
; OBJ_HP of winged_alien by difficulty (easy, normal, hard)
winged_alien_hp:
	; CDL: read by winged_alien_state_01; partly not accessed
	.word	ENEMY_HP($0080), ENEMY_HP($00A0), ENEMY_HP($00C0)
data_05ECE8:
	; CDL: read by winged_alien_state_03; partly not accessed
	.byte	$40, $00, $50, $00, $60, $00
data_05ECEE:
	; CDL: read by winged_alien_state_03
	.byte	$00, $00, $00, $00
data_05ECF2:
	; CDL: read by winged_alien_state_03; partly not accessed
	.byte	$01, $00, $FF, $FF, $6D, $C4, $72, $C4, $80, $07
data_05ECFC:
	; CDL: read by winged_alien_spawn_tail; partly not accessed
	.byte	$40, $07, $00, $07, $C0, $06, $80, $06, $40, $06, $00, $06, $C0, $05, $80, $05
	.byte	$40, $05, $00, $05, $C0, $04, $80, $04, $40, $04, $00, $04, $C0, $03, $80, $03
	.byte	$40, $03, $00, $03
data_05ED20:
	; CDL: read by sub_04A16E
	.byte	$F0, $FF, $C0, $FF
data_05ED24:
	; CDL: read by winged_alien_tail_tip_state_00
	.addr	metasprite_06C477, metasprite_06C47C, metasprite_06C481, metasprite_06C486
	.addr	metasprite_06C48B, metasprite_06C490, metasprite_06C495, metasprite_06C49A
data_05ED34:
	; CDL: read by queue_vram_blocks_at_x, winged_alien_queue_tiles
	.addr	vram_blocks_05ED3A
	.addr	vram_blocks_05ED46
	.addr	vram_blocks_05ED52
vram_blocks_05ED3A:
	.byte	$00, $B0, $00, $B0, $00, $B0, $C0, $BD, $E0, $BD
	.byte	$00, $BE
vram_blocks_05ED46:
	.byte	$80, $BC, $A0, $BC, $C0, $BC, $E0, $BC, $00, $BD, $20, $BD
vram_blocks_05ED52:
	.byte	$00, $B0
	.byte	$20, $BE, $40, $BE, $00, $B0, $60, $BE, $80, $BE
; OBJ_HP of face_boss by difficulty (easy, normal, hard)
face_boss_hp:
	; CDL: read by face_boss_state_00; partly not accessed
	.word	ENEMY_HP($0080), ENEMY_HP($0100), ENEMY_HP($0180)
data_05ED64:
	; CDL: read by face_boss_state_06; partly not accessed
	.byte	$7F, $00, $3F, $00, $1F, $00
data_05ED6A:
	; CDL: read by face_boss_state_06; partly not accessed
	.byte	$FF, $00, $FF, $00, $7F, $00
data_05ED70:
	; CDL: read by sub_04A6B8; partly not accessed
	.byte	$FF, $00, $7F, $00, $3F, $00
data_05ED76:
	; CDL: read by sub_04A7A3
	.byte	$02, $80, $02, $80, $02, $80, $00, $80, $00, $80, $04, $80, $04, $80, $04, $80
data_05ED86:
	; CDL: read by sub_04A810; partly not accessed
	.byte	$40, $00, $80, $00, $00, $01
data_05ED8C:
	; CDL: read by face_boss_queue_tiles
	.byte	$E0, $BF, $E0, $C1, $A0, $C1, $60, $C1
data_05ED94:
	; CDL: read by face_boss_queue_tiles
	.byte	$00, $C0, $00, $C2, $C0, $C1, $80, $C1
data_05ED9C:
	; CDL: read by queue_vram_blocks_at_x, sub_04A93B
	.addr	vram_blocks_05EDA0
	.addr	vram_blocks_05EDA8
vram_blocks_05EDA0:
	.byte	$60, $C0, $80, $C0, $A0, $C0, $C0, $C0
vram_blocks_05EDA8:
	.byte	$E0, $C0, $00, $C1
	.byte	$20, $C1
data_05EDAE:
	; CDL: read by queue_vram_blocks_at_x, sub_04A95D
	.byte	$40, $C1, $08, $4C, $88, $4C, $08, $4D
data_05EDB6:
	; CDL: read by queue_vram_blocks_at_x, sub_04A95D
	.byte	$88, $4D, $C0, $ED, $C8, $ED, $D0, $ED, $D0, $ED, $00, $B4, $20, $C2, $40, $C2
	.byte	$E0, $B3, $00, $B0, $60, $C2, $A0, $BE, $00, $B0, $00, $B0, $00, $B0, $00, $B0
data_05EDD6:
	; CDL: read by queue_vram_blocks_at_x, sub_04A97A
	.byte	$00, $B0, $00, $4C, $80, $4C
data_05EDDC:
	; CDL: read by queue_vram_blocks_at_x, sub_04A97A
	.byte	$00, $4D, $E4, $ED, $F4, $ED, $04, $EE, $00, $B0, $00, $B0, $00, $B0, $A0, $B3
	.byte	$C0, $B3, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $60, $C2
	.byte	$A0, $BE, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0
; OBJ_HP of floor_mouth by difficulty (easy, normal, hard; a 4th word unused)
floor_mouth_hp:
	; CDL: read by floor_mouth_state_00; partly not accessed
	.word	ENEMY_HP($0020), ENEMY_HP($0028), ENEMY_HP($0030), ENEMY_HP($0038)
data_05EE1C:
	; CDL: read by queue_vram_blocks_at_x, sub_04ABA3
	.addr	vram_blocks_05EE22, vram_blocks_05EE24, vram_blocks_05EE26
vram_blocks_05EE22:
	.byte	$A0, $62
vram_blocks_05EE24:
	.byte	$20, $70
vram_blocks_05EE26:
	.byte	$00, $70
data_05EE28:
	; CDL: read by floor_mouth_state_01; partly not accessed
	.byte	$78, $00, $5A, $00, $3C, $00, $3C, $00
; OBJ_HP of floor_mouth_bug by difficulty (easy, normal, hard; a 4th word unused)
floor_mouth_bug_hp:
	; CDL: read by floor_mouth_bug_state_00; partly not accessed
	.word	ENEMY_HP($0001), ENEMY_HP($0001), ENEMY_HP($0002), ENEMY_HP($0003)
data_05EE38:
	; CDL: read by floor_mouth_bug_state_00
	.byte	$00, $00, $00, $F0, $00, $10
data_05EE3E:
	; CDL: read by floor_mouth_bug_state_00
	.byte	$00, $00, $00, $00, $FF, $FF
data_05EE44:
	; CDL: read by floor_mouth_bug_state_00
	.byte	$00, $00, $00, $80, $00, $80
data_05EE4A:
	; CDL: read by update_objects, floor_mouth_bug_state_00; partly not accessed
	.byte	$01, $00, $FF, $FF, $FF, $FF
anim_05EE50:
	anim_frame	$0007, metasprite_06C376, metasprite_06C376
	anim_frame	$0007, metasprite_06C37B, metasprite_06C37B
	anim_goto	anim_05EE50
; OBJ_HP of wall_worm_larva by difficulty (easy, normal, hard)
wall_worm_larva_hp:
	; CDL: read by wall_worm_larva_state_00
	.word	ENEMY_HP($0004), ENEMY_HP($0008), ENEMY_HP($0010)
data_05EE64:
	; CDL: read by update_objects, wall_worm_larva_state_00; partly not accessed
	.byte	$80, $00, $C0, $00
anim_05EE68:
	anim_frame	$0003, metasprite_06C380, metasprite_06C380
	anim_frame	$0003, metasprite_06C391, metasprite_06C391
	anim_frame	$0003, metasprite_06C3A2, metasprite_06C3A2
	anim_frame	$0003, metasprite_06C3B3, metasprite_06C3B3
	anim_frame	$0003, metasprite_06C3C4, metasprite_06C3C4
	anim_frame	$0003, metasprite_06C3D5, metasprite_06C3D5
	anim_frame	$0003, metasprite_06C3E6, metasprite_06C3E6
	anim_frame	$0003, metasprite_06C3F7, metasprite_06C3F7
	anim_goto	anim_05EE68
; OBJ_HP of face_boss_larva by difficulty (easy, normal, hard)
face_boss_larva_hp:
	; CDL: read by face_boss_larva_state_00; partly not accessed
	.word	ENEMY_HP($0002), ENEMY_HP($0004), ENEMY_HP($0008)
data_05EEA0:
	; CDL: read by enemy_type_68_state_00
	.word	ENEMY_HP($0000), ENEMY_HP($0002), ENEMY_HP($0004)
data_05EEA6:
	; CDL: read by enemy_type_68_state_00
	.byte	$FC, $FF, $04, $00
data_05EEAA:
	; CDL: read by enemy_type_68_state_00
	.byte	$00, $00, $00, $00
data_05EEAE:
	; CDL: read by enemy_type_68_state_00
	.addr	metasprite_06C2FE, metasprite_06C33A
data_05EEB2:
	; CDL: read by enemy_type_68_state_01
	.byte	$00, $00, $FF, $FF
data_05EEB6:
	; CDL: read by enemy_type_68_state_01
	.byte	$00, $40, $00, $C0
data_05EEBA:
	; CDL: read by sub_04AF1C
	.byte	$B8, $00, $48, $00
data_05EEBE:
	; CDL: read by update_objects, sub_04AF1C; partly not accessed
	.addr	anim_05EEC2, anim_05EEDC
anim_05EEC2:
	anim_frame	$0004, metasprite_06C307, metasprite_06C307
	anim_frame	$0004, metasprite_06C318, metasprite_06C318
	anim_frame	$0004, metasprite_06C329, metasprite_06C329
	anim_frame	$0004, metasprite_06C318, metasprite_06C318
	anim_goto	anim_05EEC2
anim_05EEDC:
	anim_frame	$0004, metasprite_06C343, metasprite_06C343
	anim_frame	$0004, metasprite_06C354, metasprite_06C354
	anim_frame	$0004, metasprite_06C365, metasprite_06C365
	anim_frame	$0004, metasprite_06C354, metasprite_06C354
	anim_goto	anim_05EEDC
	.byte	$00, $00, $F8, $FF
; OBJ_HP of heart_boss by difficulty (easy, normal; hard = first word of data_05EEFE, $0180)
.if CHEAT_ENEMY_HP = 100
heart_boss_hp:
.endif
	; CDL: read by heart_boss_state_00
	.byte	$80, $00, $00, $01	; cheats: see cheat_enemy_hp_tables
data_05EEFE:
	; CDL: read by heart_boss_state_00, sub_04B12E
	.byte	$80, $01, $90, $4C, $90, $4D
data_05EF04:
	; CDL: read by queue_vram_blocks_at_x, sub_04B12E
	.byte	$10, $4E, $0C, $EF, $1C, $EF, $2C, $EF, $20, $BC, $00, $B0, $20, $BC, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$60, $BC, $00, $B0, $60, $BC, $00, $B0
data_05EF3C:
	; CDL: read by queue_vram_blocks_at_x, sub_04B14B
	.addr	vram_blocks_05EF40
	.addr	vram_blocks_05EF4C
vram_blocks_05EF40:
	.byte	$80, $B0, $A0, $B0, $C0, $B0, $00, $BA, $20, $BA, $40, $BA
vram_blocks_05EF4C:
	.byte	$A0, $BA, $C0, $BA, $E0, $BA, $20, $BB, $40, $BB
data_05EF56:
	; CDL: read by queue_vram_blocks_at_x, spawn_heart_boss_bug
	.byte	$60, $BB, $00, $01, $40, $01, $00, $01
data_05EF5E:
	; CDL: read by spawn_heart_boss_bug
	.byte	$40, $01, $40, $00, $40, $00, $C0, $00
data_05EF66:
	; CDL: read by spawn_heart_boss_bug
	.byte	$C0, $00, $02, $00, $02, $00, $00, $00
data_05EF6E:
	; CDL: read by spawn_heart_boss_bug
	.byte	$00, $00, $90, $4C, $98, $4C, $90, $4E, $98, $4E
; OBJ_HP of heart_boss_bug by difficulty (easy, normal, hard)
heart_boss_bug_hp:
	; CDL: read by heart_boss_bug_state_00
	.word	ENEMY_HP($0020), ENEMY_HP($0040), ENEMY_HP($0080)
data_05EF7E:
	; CDL: read by heart_boss_bug_state_00
	.byte	$80, $00, $A8, $00, $D0, $00, $F8, $00, $40, $00, $52, $00, $64, $00, $76, $00
	.byte	$02, $00, $14, $00, $26, $00, $38, $00
data_05EF96:
	; CDL: read by heart_boss_bug_state_01, sub_04B2E7
	.byte	$9A, $EF, $B0, $EF, $04, $00, $80, $B1, $04, $00, $A0, $B1, $18, $00, $40, $BC
	.byte	$04, $00, $A0, $B1, $04, $00, $80, $B1, $00, $00, $04, $00, $00, $B1, $04, $00
	.byte	$20, $B1, $18, $00, $00, $BC, $04, $00, $20, $B1, $04, $00, $00, $B1, $00, $00
data_05EFC6:
	; CDL: read by heart_boss_bug_state_03
	.byte	$60, $BC, $20, $BC
data_05EFCA:
	; CDL: read by sub_04B2C1
	.byte	$F0, $FF, $0C, $00
; OBJ_HP of wall_worm by difficulty (easy, normal, hard)
wall_worm_hp:
	; CDL: read by wall_worm_state_00
	.word	ENEMY_HP($0040), ENEMY_HP($0080), ENEMY_HP($0100)
data_05EFD4:
	; CDL: read by queue_vram_blocks_at_x, sub_04B403
	.addr	vram_blocks_05EFE0
	.addr	vram_blocks_05EFD8
vram_blocks_05EFD8:
	.byte	$60, $51, $80, $51, $A0, $51, $C0, $51
vram_blocks_05EFE0:
	.byte	$40, $72, $60, $72
	.byte	$60, $50, $60, $50
data_05EFE8:
	; CDL: read by sub_04B403
	.byte	$3F, $00, $1F, $00
data_05EFEC:
	; CDL: read by sub_04B403
	.byte	$E0, $FF, $D0, $FF
data_05EFF0:
	; CDL: read by sub_04B403
	.byte	$80, $00, $90, $00
data_05EFF4:
	; CDL: read by queue_vram_blocks_at_x, sub_04B447
	.addr	vram_blocks_05EFF8
	.addr	data_05EFFA
vram_blocks_05EFF8:
	.byte	$80, $72
data_05EFFA:
	; CDL: read by queue_vram_blocks_at_x, sub_04B469
	.byte	$20, $5A, $90, $44, $10, $45, $90, $45
data_05F002:
	; CDL: read by queue_vram_blocks_at_x, sub_04B469
	.byte	$10, $46, $0C, $F0, $12, $F0, $18, $F0, $1E, $F0, $60, $50, $20, $52, $40, $52
	.byte	$60, $50, $60, $50, $60, $50, $60, $50, $60, $50, $60, $50, $60, $50, $60, $50
	.byte	$60, $50
data_05F024:
	; CDL: read by cave_beast_state_02; partly not accessed
	.byte	$00, $01, $40, $01, $80, $01, $C0, $01
data_05F02C:
	; CDL: read by sub_04BDC6
	.byte	$00, $02, $40, $02
data_05F030:
	; CDL: read by cave_beast_state_13
	.byte	$04, $00, $05, $00
data_05F034:
	; CDL: read by cave_beast_state_14; partly not accessed
	.byte	$09, $00, $0B, $00, $0D, $00, $0F, $00
data_05F03C:
	; CDL: read by cave_beast_state_17
	.byte	$01, $00, $02, $00
data_05F040:
	; CDL: read by cave_beast_state_19
	.byte	$04, $00, $03, $00, $01, $00, $00, $00
data_05F048:
	; CDL: read by sub_04BC10
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $02, $00
	.byte	$02, $00, $02, $00, $02, $00
data_05F05E:
	; CDL: read by sub_04BC10
	.byte	$08, $00, $08, $00, $08, $00, $08, $00, $08, $00, $08, $00, $08, $00, $10, $00
	.byte	$10, $00, $20, $00, $20, $00
data_05F074:
	; CDL: read by sub_04BC10
	.byte	$94, $4D, $94, $4D, $94, $4D, $14, $4E, $14, $4E, $14, $4E, $14, $4E, $90, $4E
	.byte	$90, $4E, $98, $4E, $98, $4E
data_05F08A:
	; CDL: read by queue_vram_blocks_at_x, sub_04BC10
	.addr	vram_blocks_05F0A0, vram_blocks_05F0A2, vram_blocks_05F0A4, vram_blocks_05F0A6
	.addr	vram_blocks_05F0A8, vram_blocks_05F0AA, vram_blocks_05F0AC, vram_blocks_05F0AE
	.addr	vram_blocks_05F0B2, vram_blocks_05F0B6, vram_blocks_05F0BE
vram_blocks_05F0A0:
	.byte	$80, $BB
vram_blocks_05F0A2:
	.byte	$C0, $B6
vram_blocks_05F0A4:
	.byte	$E0, $B6
vram_blocks_05F0A6:
	.byte	$E0, $BB
vram_blocks_05F0A8:
	.byte	$20, $B4
vram_blocks_05F0AA:
	.byte	$00, $B7
vram_blocks_05F0AC:
	.byte	$20, $B7
vram_blocks_05F0AE:
	.byte	$40, $B6, $60, $B6
vram_blocks_05F0B2:
	.byte	$40, $B7, $60, $B7
vram_blocks_05F0B6:
	.byte	$80, $B6, $A0, $B6
	.byte	$00, $B0, $00, $B0
vram_blocks_05F0BE:
	.byte	$80, $B7, $A0, $B7, $C0, $B7, $E0, $B7
data_05F0C6:
	; CDL: read by update_cave_beast_fireball
	.addr	metasprite_06AF82, metasprite_06AF87, metasprite_06AF8C, metasprite_06AF91
; OBJ_HP of face_boss_side_head by difficulty (easy, normal, hard)
face_boss_side_head_hp:
	; CDL: read by face_boss_side_head_state_00; partly not accessed
	.word	ENEMY_HP($0080), ENEMY_HP($00C0), ENEMY_HP($0100)
data_05F0D4:
	; CDL: read by face_boss_side_head_state_02
	.byte	$00, $19, $00, $1A, $00, $19, $00, $19
data_05F0DC:
	; CDL: read by face_boss_side_head_state_02; partly not accessed
	.byte	$38, $00, $78, $00, $00, $19, $00, $1A
data_05F0E4:
	; CDL: read by update_face_boss_neck
	.byte	$00, $04, $40, $04
data_05F0E8:
	; CDL: read by face_boss_side_head_state_02
	.byte	$97, $FF, $56, $00
data_05F0EC:
	; CDL: read by snake_robot_state_00; partly not accessed
	.byte	$00, $01, $40, $01, $80, $01, $C0, $01
data_05F0F4:
	; CDL: read by snake_robot_state_05
	.byte	$00, $00, $00, $00
data_05F0F8:
	; CDL: read by snake_robot_state_05
	.byte	$FD, $FF, $FB, $FF
data_05F0FC:
	; CDL: read by snake_robot_state_05
	.byte	$00, $00, $00, $00
data_05F100:
	; CDL: read by snake_robot_state_05
	.byte	$05, $00, $03, $00
data_05F104:
	; CDL: read by snake_robot_state_06
	.byte	$00, $00, $00, $00
data_05F108:
	; CDL: read by snake_robot_state_06
	.byte	$01, $00, $00, $00
data_05F10C:
	; CDL: read by snake_robot_state_07
	.byte	$00, $80, $00, $80
data_05F110:
	; CDL: read by snake_robot_state_07
	.byte	$FF, $FF, $00, $00
data_05F114:
	; CDL: read by snake_robot_state_01
	.byte	$40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00
	.byte	$40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00, $40, $00
data_05F134:
	; CDL: read by snake_robot_state_08
	.byte	$40, $00, $40, $01, $40, $01, $40, $01, $40, $01, $40, $01, $40, $01, $40, $01
	.byte	$40, $00, $C0, $00, $C0, $00, $C0, $00, $C0, $00, $C0, $00, $C0, $00, $C0, $00
data_05F154:
	; CDL: read by update_snake_robot_head
	.byte	$00, $09
data_05F156:
	; CDL: read by snake_robot_state_00
	.byte	$80, $04
data_05F158:
	; CDL: read by snake_robot_state_00
	.byte	$40, $04, $00, $04, $C0, $03, $80, $03, $40, $03, $00, $03, $C0, $04
data_05F166:
	; CDL: read by snake_robot_state_00
	.byte	$80, $05
data_05F168:
	; CDL: read by snake_robot_state_00
	.byte	$C0, $05, $00, $06, $40, $06, $80, $06, $C0, $06, $00, $07, $40, $05
data_05F176:
	; CDL: read by sub_04CB63
	.byte	$80, $04, $80, $05
data_05F17A:
	; CDL: read by sub_04CB63
	.byte	$10, $00
data_05F17C:
	; CDL: read by sub_04CB63
	.byte	$08, $00
ptrs_05F17E:
	.addr	data_05F158
	.addr	data_05F168
ptrs_05F182:
	.addr	data_05F156
	.addr	data_05F166
data_05F186:
	; CDL: read by snake_robot_state_00
	.byte	$00, $03
data_05F188:
	; CDL: read by snake_robot_state_00, snake_robot_state_06
	.byte	$00, $07, $00, $03
data_05F18C:
	; CDL: read by sub_04CBE2
	.byte	$C0, $04, $40, $05
data_05F190:
	; CDL: read by sub_04CBE2
	.byte	$00, $03, $C0, $03, $C0, $03, $00, $04, $C0, $03, $C0, $03, $C0, $03, $80, $03
	.byte	$C0, $03, $00, $07, $40, $06, $40, $06, $00, $06, $40, $06, $40, $06, $40, $06
	.byte	$80, $06, $40, $06
data_05F1B4:
	; CDL: read by sub_04CBE2
	.byte	$80, $04, $80, $04, $00, $04, $80, $04, $40, $04, $00, $03, $80, $03, $00, $03
	.byte	$40, $03, $80, $05, $80, $05, $00, $06, $80, $05, $C0, $05, $00, $07, $80, $06
	.byte	$00, $07, $C0, $06
data_05F1D8:
	; CDL: read by sub_04CBE2
	.byte	$C0, $03, $00, $04, $00, $04, $40, $04, $00, $04, $80, $03, $80, $03, $40, $03
	.byte	$80, $03, $40, $06, $00, $06, $00, $06, $C0, $05, $00, $06, $80, $06, $80, $06
	.byte	$C0, $06, $80, $06
data_05F1FC:
	; CDL: read by enemy_type_7C_state_00
	.byte	$60, $00, $40, $00, $80, $00
data_05F202:
	; CDL: read by sub_04CE28
	.byte	$A0, $5A
data_05F204:
	; CDL: read by sub_04CE28
	.byte	$00, $50, $C0, $5A, $00, $50, $E0, $5A, $00, $5B, $20, $5B, $40, $5B, $20, $5B
	.byte	$40, $5B, $20, $5B, $80, $5B, $20, $5B, $60, $5B, $A0, $5B, $C0, $5B
data_05F222:
	; CDL: read by enemy_type_7C_state_03
	.byte	$18, $00, $10, $00, $14, $00
data_05F228:
	; CDL: read by enemy_type_7C_state_03
	.byte	$03, $00, $04, $00, $00, $00
data_05F22E:
	; CDL: read by enemy_type_7C_state_03
	.byte	$1E, $00, $0C, $00, $00, $00
data_05F234:
	; CDL: read by sub_04CE28
	.byte	$84, $40, $9C, $44, $8C, $40
data_05F23A:
	; CDL: read by update_objects; partly not accessed
	.byte	$04, $45, $1C, $41, $14, $45, $0C, $45, $04, $45, $1C, $41
anim_05F246:
	anim_frame	$0001, metasprite_06AE9B, metasprite_06C607
	anim_frame	$0001, metasprite_06AEA0, metasprite_06C61C
	anim_frame	$0001, metasprite_06AFD9, metasprite_06C631
	anim_frame	$0001, metasprite_06AEA5, metasprite_06C646
	anim_goto	anim_05F246
data_05F260:
	; CDL: read by update_lightning_pylon
	.byte	$78, $00, $60, $00, $68, $00, $5C, $00, $50, $00, $44, $00
; OBJ_HP of lightning_pylon by difficulty: easy $40, normal $60; hard reads the next word, $7FFF
.if CHEAT_ENEMY_HP = 100
lightning_pylon_hp:
.endif
	; CDL: read by update_objects, update_lightning_pylon, update_enemy_type_80; partly not accessed
	.byte	$40, $00, $60, $00, $FF, $7F	; cheats: see cheat_enemy_hp_tables
vram_blocks_05F272:
	.byte	$C0, $59, $00, $50, $00, $50
anim_05F278:
	anim_frame	$0001, metasprite_06AFD9, $3200
	anim_frame	$0004, metasprite_06AEA5, $3E00
	anim_goto	anim_05F278
load_list_05F286:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7000, gfx_0AE4A2
	load_end
data_05F28F:
	; CDL: read by sub_04D6E7
	.byte	$08, $00, $F8, $FF
data_05F293:
	; CDL: read by sub_04D70A; partly not accessed
	.addr	metasprite_06C86E, metasprite_06C8D3, metasprite_06C859, metasprite_06C8E4
	.addr	metasprite_06C894
	.addr	metasprite_06C8A9, metasprite_06C87F, metasprite_06C8BE, metasprite_06C86E
	.addr	metasprite_06C8D3, metasprite_06C859, metasprite_06C8E4, metasprite_06C844
	.addr	metasprite_06C8F9, metasprite_06C859, metasprite_06C8E4
data_05F2B3:
	; CDL: read by sub_04D724; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $08, $00, $06, $00, $08, $00, $06, $00
	.byte	$F6, $FF, $FC, $FF, $EC, $FF, $EC, $FF, $E8, $FF, $E8, $FF, $00, $00, $00, $00
data_05F2D3:
	; CDL: read by sub_04D724; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $0C, $00, $0E, $00, $17, $00, $12, $00
	.byte	$16, $00, $14, $00, $12, $00, $14, $00, $0E, $00, $0C, $00, $00, $00, $00, $00
	; CDL: read by update_objects
anim_05F2F3:
	anim_frame	$0010, metasprite_06C90E, metasprite_06C96E
	anim_frame	$0003, metasprite_06C927, metasprite_06C987
	anim_frame	$0003, metasprite_06C93C, metasprite_06C99C
	anim_end	metasprite_06C955, metasprite_06C9B5
anim_05F30B:
	anim_frame	$0020, metasprite_06C9CE, metasprite_06CA7F
	anim_frame	$0004, metasprite_06C9EF, metasprite_06CAA0
	anim_frame	$0004, metasprite_06CA0C, metasprite_06CABD
	anim_frame	$0004, metasprite_06CA2D, metasprite_06CADE
	anim_end	metasprite_06CA56, metasprite_06CB07
data_05F329:
	; CDL: read by update_objects, helicopter_rope_state_07
	.byte	$0E, $00, $FE, $FF
anim_05F32D:
	anim_frame	$0004, metasprite_06CB72, metasprite_06CB7C
	anim_frame	$0004, metasprite_06CB77, metasprite_06CB81
	anim_goto	anim_05F32D
data_05F33B:
	; CDL: read by update_enemy_type_85
	.byte	$07, $00, $F9, $FF
data_05F33F:
	; CDL: read by update_enemy_type_85
	.byte	$00, $C0, $00, $40
data_05F343:
	; CDL: read by update_enemy_type_85; partly not accessed
	.byte	$FF, $FF, $00, $00
text_sound_check_mode:
	.byte	$08, $59, $4D, $4A, $4F, $49, $3F, $00, $3E, $43, $40, $3E
	.byte	$46, $00, $48, $4A, $3F, $40, $FF
text_sound_2:
	.byte	$4C, $5A, $4D, $4A, $4F, $49, $3F, $FF
song_lists:
	; CDL: not accessed
	.addr	song_set_05F3C9
	; CDL: read by load_stage_music; partly not accessed
	.addr	song_set_05F3AE, song_set_05F3FF, song_set_05F3E4
	.addr	song_set_05F3C9, song_set_05F41A, song_set_05F435, song_set_05F450
	.addr	song_set_05F46B, song_set_05F4A4, song_set_05F4F8, song_set_05F51C
	.addr	song_set_05F3C9, song_set_05F3C9, song_set_05F3C9, song_set_05F3E4
	.addr	song_set_05F3C9, song_set_05F4D0, song_set_05F540
song_start_commands:
	; CDL: not accessed
	.byte	$74, $00
	; CDL: read by load_spc_list, upload_ring_to_spc, upload_spc_raw_block (+3 more); partly not accessed
	.byte	$7A, $00, $76, $00, $75, $00, $74, $00, $77, $00, $78, $00, $79, $00, $74, $00
	.byte	$79, $00, $74, $00, $74, $00, $74, $00, $74, $00, $74, $00, $74, $00, $74, $00
	.byte	$79, $00, $74, $00
song_set_05F3AE:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8002, $0100
	load_spc_raw	$B08E, spc_block_1E8002, $1E96
	load_spc	$3000, spc_data_1AC08D
	load_end
song_set_05F3C9:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8104, $0100
	load_spc_raw	$B08E, spc_block_1E9E9A, $2637
	load_spc	$3000, spc_data_1C8002
	load_end
song_set_05F3E4:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8206, $0100
	load_spc_raw	$B08E, spc_block_1EC4D3, $26FD
	load_spc	$3000, spc_data_1C977B
	load_end
song_set_05F3FF:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8308, $0100
	load_spc_raw	$B08E, spc_block_1F8002, $2544
	load_spc	$3000, spc_data_1CB13C
	load_end
song_set_05F41A:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D840A, $0100
	load_spc_raw	$B08E, spc_block_1FA548, $2178
	load_spc	$3000, spc_data_1CBDE7
	load_end
song_set_05F435:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D850C, $0100
	load_spc_raw	$B08E, spc_block_1FC6C2, $2193
	load_spc	$3000, spc_data_1CD15E
	load_end
song_set_05F450:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D860E, $0100
	load_spc_raw	$B08E, spc_block_1D8710, $2490
	load_spc	$3000, spc_data_1CE6BD
	load_end
song_set_05F46B:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D860E, $0100
	load_spc_raw	$B08E, spc_block_1D8710, $2490
	load_spc_raw	$3000, spc_block_1AA9CC, $12D8
	load_end
song_set_05F48A:
	.byte	$02, $00, $FE, $FF, $00, $30, $CC, $A9, $1A, $D8, $12, $FF, $FF
song_set_05F497:
	.byte	$02, $00, $FE
	.byte	$FF, $00, $30, $23, $CA, $1A, $A6, $1F, $FF, $FF
song_set_05F4A4:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D860E, $0100
	load_spc_raw	$B08E, spc_block_1D8710, $2490
	load_spc_raw	$3000, spc_block_1ACA23, $1FA6
	load_end
song_set_05F4C3:
	load_list	$02, $00
	load_spc_raw	$3000, spc_block_1BDF92, $1DDC
	load_end
song_set_05F4D0:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D860E, $0100
	load_spc_raw	$B08E, spc_block_1D8710, $2490
	load_spc_raw	$3000, spc_block_1BDF92, $1DDC
	load_end
song_set_05F4EF:
	load_list	$02, $00
	load_spc	$3000, spc_data_1ABCA6
	load_end
song_set_05F4F8:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8104, $0100
	load_spc_raw	$B08E, spc_block_1E9E9A, $2637
	load_spc	$3000, spc_data_1ABCA6
	load_end
song_set_05F513:
	load_list	$02, $00
	load_spc	$3000, spc_data_1ABE84
	load_end
song_set_05F51C:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8104, $0100
	load_spc_raw	$B08E, spc_block_1E9E9A, $2637
	load_spc	$3000, spc_data_1ABE84
	load_end
song_set_05F537:
	load_list	$02, $00
	load_spc	$3000, spc_data_1AA5EE
	load_end
song_set_05F540:
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1D8104, $0100
	load_spc_raw	$B08E, spc_block_1E9E9A, $2637
	load_spc	$3000, spc_data_1AA5EE
	load_end
song_set_05F55B:
	; CDL: read by load_data_list, load_spc_list, upload_ring_to_spc (+5 more)
	load_list	$02, $00
	load_spc_raw	$5000, spc_block_1AA8CA, $0100
	load_spc_raw	$5100, spc_block_1B8002, $5F8E
	load_spc	$0200, spc_data_1A8002
	load_end
palette_task_05F576:
	palette_fade_out	$08, palette_088D62, $228A
palette_task_05F57C:
	palette_fade_in	$10, palette_088D62, $228A
palette_task_05F582:
	palette_fade_out	$08, palette_088D7A, $2260
palette_task_05F588:
	palette_fade_in	$10, palette_088D7A, $2260
data_05F58E:
	; CDL: read by spawn_ending_crowd
	.byte	$9A, $00
data_05F590:
	; CDL: read by spawn_ending_crowd
	.byte	$00, $34, $9A, $00, $00, $36, $9B, $00, $00, $36, $9B, $00, $00, $38, $9C, $00
	.byte	$00, $38, $9D, $00, $00, $36, $9E, $00, $00, $34, $9F, $00, $00, $34
data_05F5AE:
	; CDL: read by spawn_ending_crowd
	.addr	anim_05F604
data_05F5B0:
	; CDL: read by spawn_ending_crowd
	.byte	$00, $00, $04, $F6, $00, $00, $12, $F6, $00, $00, $12, $F6, $02, $00, $20, $F6
	.byte	$02, $00, $2E, $F6, $00, $00, $50, $F6, $02, $00, $6A, $F6, $02, $00
data_05F5CE:
	; CDL: read by spawn_ending_crowd
	.byte	$F0, $00
data_05F5D0:
	; CDL: read by spawn_ending_crowd
	.byte	$C5, $00, $38, $00, $BE, $00, $C4, $00, $C6, $00, $10, $00, $C8, $00, $A7, $00
	.byte	$BE, $00, $20, $00, $C6, $00, $20, $00, $D4, $00, $D0, $00, $D1, $00
data_05F5EE:
	; CDL: read by spawn_ending_crowd
	.byte	$C0, $03, $00, $05, $C0, $04, $40, $04, $00, $04, $80, $03, $00, $03, $40, $03
; number of crowd members spawned by spawn_ending_crowd, by difficulty (6, 7, 8)
ending_crowd_counts:
	; CDL: read by update_objects, spawn_ending_crowd; partly not accessed
	.byte	$06, $00, $07, $00, $08, $00
anim_05F604:
	anim_frame	$0010, metasprite_06D3E9, metasprite_06D3E9
	anim_frame	$0010, metasprite_06D422, metasprite_06D422
	anim_goto	anim_05F604
	.byte	$0C, $00, $63, $D4, $91, $D4, $0E, $00, $74, $D4, $A2, $D4
	.byte	$12, $F6, $0E, $00, $BF, $D4
	.byte	$F1, $D4
	.byte	$10, $00, $D8, $D4
	.byte	$0A, $D5
	.byte	$20, $F6
	.byte	$0E, $00, $23, $D5, $4A, $D5
	.byte	$0E, $00, $3D, $D5, $64, $D5
	.byte	$0E, $00, $30, $D5, $57, $D5
	; CDL: read by update_objects; partly not accessed
	.byte	$2E, $F6
anim_05F642:
	anim_frame	$0008, metasprite_06D571, metasprite_06D5AA
	anim_frame	$0008, metasprite_06D57A, metasprite_06D5B3
	anim_goto	anim_05F642
anim_05F650:
	anim_frame	$0008, metasprite_06D583, metasprite_06D5BC
	anim_frame	$0009, metasprite_06D590, metasprite_06D5C9
	anim_frame	$0008, metasprite_06D599, metasprite_06D5D2
	anim_frame	$0009, metasprite_06D590, metasprite_06D5C9
	anim_goto	anim_05F650
anim_05F66A:
	anim_frame	$000A, metasprite_06D5E3, metasprite_06D645
	anim_frame	$000A, metasprite_06D5F4, metasprite_06D656
	anim_goto	anim_05F66A
anim_05F678:
	anim_frame	$000A, metasprite_06D605, metasprite_06D667
	anim_goto	anim_05F678
anim_05F680:
	anim_frame	$0007, metasprite_06D616, metasprite_06D678
	anim_frame	$0009, metasprite_06D627, metasprite_06D689
	anim_frame	$0007, metasprite_06D638, metasprite_06D69A
	anim_goto	anim_05F680
atan_table:
	; CDL: read by calc_angle_8; partly not accessed
	.byte	$00, $00, $00, $00, $00, $00, $00, $01, $01, $01, $01, $01, $01, $02, $02, $02
	.byte	$02, $02, $02, $03, $03, $03, $03, $03, $03, $03, $04, $04, $04, $04, $04, $04
	.byte	$05, $05, $05, $05, $05, $05, $06, $06, $06, $06, $06, $06, $06, $07, $07, $07
	.byte	$07, $07, $07, $08, $08, $08, $08, $08, $08, $08, $09, $09, $09, $09, $09, $09
	.byte	$09, $0A, $0A, $0A, $0A, $0A, $0A, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0C, $0C
	.byte	$0C, $0C, $0C, $0C, $0C, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0E, $0E, $0E, $0E
	.byte	$0E, $0E, $0E, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $0F, $10, $10, $10, $10, $10
	.byte	$10, $10, $11, $11, $11, $11, $11, $11, $11, $11, $12, $12, $12, $12, $12, $12
	.byte	$12, $13, $13, $13, $13, $13, $13, $13, $13, $14, $14, $14, $14, $14, $14, $14
	.byte	$14, $14, $15, $15, $15, $15, $15, $15, $15, $15, $16, $16, $16, $16, $16, $16
	.byte	$16, $16, $16, $17, $17, $17, $17, $17, $17, $17, $17, $17, $18, $18, $18, $18
	.byte	$18, $18, $18, $18, $18, $19, $19, $19, $19, $19, $19, $19, $19, $19, $1A, $1A
	.byte	$1A, $1A, $1A, $1A, $1A, $1A, $1A, $1A, $1B, $1B, $1B, $1B, $1B, $1B, $1B, $1B
	.byte	$1B, $1B, $1B, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1C, $1D, $1D, $1D
	.byte	$1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1D, $1E, $1E, $1E, $1E, $1E, $1E, $1E
	.byte	$1E, $1E, $1E, $1E, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F, $1F
quarter_sine_lo:
	; CDL: read by scale_sine_cosine
	.byte	$00, $48, $8F, $D5, $17, $56, $90, $C4, $F1, $17, $33, $47, $50, $4D, $3E, $22
	.byte	$F7, $BD, $74, $19, $AD, $2E, $9C, $F5, $39, $68, $7F, $7F, $67, $36, $EB, $85
	.byte	$04, $68, $AE, $D8, $E4, $D1, $9F, $4D, $DB, $48, $94, $BE, $C5, $AA, $6B, $09
	.byte	$83, $D8, $09, $14, $FA, $BA, $53, $C7, $14, $3B, $3A, $13, $C4, $4E, $B1, $EC
quarter_cosine_lo:
	; CDL: read by scale_sine_cosine
	.byte	$FF, $EC, $B1, $4E, $C4, $13, $3A, $3B, $14, $C7, $53, $BA, $FA, $14, $09, $D8
	.byte	$83, $09, $6B, $AA, $C5, $BE, $94, $48, $DB, $4D, $9F, $D1, $E4, $D8, $AE, $68
	.byte	$04, $85, $EB, $36, $67, $7F, $7F, $68, $39, $F5, $9C, $2E, $AD, $19, $74, $BD
	.byte	$F7, $22, $3E, $4D, $50, $47, $33, $17, $F1, $C4, $90, $56, $17, $D5, $8F, $48
quarter_sine:
	; CDL: read by scale_sine_cosine, set_velocity_from_angle
	.byte	$00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	.byte	$61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	.byte	$B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	.byte	$EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF, $FF, $FF
quarter_cosine:
	; CDL: read by scale_sine_cosine, set_velocity_from_angle
	.byte	$FF, $FF, $FF, $FF, $FE, $FE, $FD, $FC, $FB, $F9, $F8, $F6, $F4, $F3, $F1, $EE
	.byte	$EC, $EA, $E7, $E4, $E1, $DE, $DB, $D8, $D4, $D1, $CD, $C9, $C5, $C1, $BD, $B9
	.byte	$B5, $B0, $AB, $A7, $A2, $9D, $98, $93, $8E, $88, $83, $7E, $78, $73, $6D, $67
	.byte	$61, $5C, $56, $50, $4A, $44, $3E, $38, $31, $2B, $25, $1F, $19, $12, $0C, $06
data_05F894:
	; CDL: read by ending_creature_aim_arm
	.byte	$00, $00, $40, $00
data_05F898:
	; CDL: read by ending_creature_aim_arm
	.byte	$FC, $FF, $04, $00
data_05F89C:
	; CDL: read by setup_stage_hdma, ending_creature_aim_arm; partly not accessed
	.byte	$05, $00, $FB, $FF
hdma_list_05F8A0:
	hdma_channel_ind	$4370, $42, $10, $7EE800, $7E
	hdma_channels_end	$80
data_05F8AB:
	; CDL: read by setup_stage_hdma, update_enemy_type_96
	.addr	metasprite_06C59C
	.addr	metasprite_06C5BE, metasprite_06C5AD, metasprite_06C4F2
data_05F8B3:
	; CDL: read by ending_creature_feed_arm
	.byte	$48, $00, $B0, $00, $60, $00, $98, $00
data_05F8BB:
	; CDL: read by ending_creature_swing; partly not accessed
	.byte	$04, $00, $08, $00, $02, $00, $FE, $FF
load_list_05F8C3:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$0000, gfx_0F8000
	load_vram	$2000, gfx_08A538
	load_end
load_list_05F8D1:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk (+2 more)
	load_list	$00, $01
	load_vram	$3000, gfx_15DCD9
	load_end
palette_task_05F8DA:
	palette_animate	$00, $00
	palette_copy	palette_08878A, $2240
	palette_copy_end
palette_task_05F8E3:
	palette_animate	$00, $00
	palette_copy	palette_08EFCA, $2200
	palette_copy_end
data_05F8EC:
	; CDL: read by ending_queue_tile_changes
	.byte	$10, $10, $00, $14, $00, $24, $00, $04, $58, $00, $04, $A8, $04, $08, $FC, $04
	.byte	$08, $6C, $08, $6C
data_05F900:
	; CDL: read by setup_stage_hdma, queue_vram_blocks_at_x, ending_queue_tile_changes; DMA / HDMA; partly not accessed
	.byte	$00, $0C, $18, $24, $30, $3C, $48, $54, $00, $60, $30, $3C, $6C, $18, $78, $60
	.byte	$84, $90, $60, $60
vram_blocks_05F914:
	.byte	$A0, $B5, $40, $C4, $40, $B4, $C0, $B5, $60, $C4, $60, $B4
	.byte	$C0, $C2, $80, $C2, $A0, $C3, $E0, $C2, $A0, $C2, $C0, $C3, $80, $B5, $A0, $B4
	.byte	$20, $B5, $E0, $B5, $C0, $B4, $40, $B5, $A0, $B5, $40, $C4, $40, $B4, $C0, $B5
	.byte	$60, $C4, $60, $B4, $00, $B0, $00, $C3, $80, $C3, $00, $B0, $60, $C3, $E0, $C3
	.byte	$C0, $C2, $80, $C2, $A0, $C3, $E0, $C2, $A0, $C2, $C0, $C3, $00, $B0, $80, $B4
	.byte	$00, $B5, $00, $B0, $E0, $B4, $60, $B5, $80, $B5, $A0, $B4, $20, $B5, $E0, $B5
	.byte	$C0, $B4, $40, $B5, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B0, $80, $B4, $00, $B5, $00, $B0, $E0, $B4, $60, $B5, $A0, $B5, $00, $C4
	.byte	$80, $B3, $C0, $B5, $20, $C4, $60, $B3, $00, $B0, $00, $C3, $80, $C3, $00, $B0
	.byte	$60, $C3, $E0, $C3, $C0, $C2, $20, $C3, $A0, $C3, $E0, $C2, $40, $C3, $C0, $C3
hdma_list_05F9B0:
	hdma_channel_ind	$4370, $00, $30, hdma_table_05F9C3, $05
	hdma_channel_ind	$4360, $42, $0D, $7ED200, $7E
	hdma_channels_end	$C0
hdma_table_05F9C3:
	.byte	$1F, $00, $7F, $02, $00
data_05F9C8:
	; CDL: read by sub_1DB98D
	.byte	$00, $1C, $00, $14, $00, $0C, $00, $04
data_05F9D0:
	; CDL: read by sub_1DB98D; partly not accessed
	.byte	$FF, $04, $FF, $14, $FF, $00, $02, $04, $06, $FF, $12, $14, $16, $10, $FE, $00
	.byte	$02, $04, $06, $FF, $12, $14, $16, $10, $FE, $00, $02, $04, $06, $08, $FF, $12
	.byte	$14, $16, $18, $FE, $02, $04, $06, $FF, $12, $14, $16, $10, $FE, $00, $02, $04
	.byte	$06, $FF, $12, $14, $16, $FE, $02, $04, $06, $08, $FE, $18, $12, $14, $16, $10
	.byte	$FE, $04, $FF, $14, $FE, $02, $04, $FF, $FF, $FF
data_05FA1A:
	; CDL: read by sub_1DB98D
	.byte	$8A, $FA, $F5, $FA, $08, $FB, $2E, $FB, $54, $FB, $99, $FA, $AB, $FA, $C8, $FA
	.byte	$E0, $FA, $70, $FB, $82, $FB, $A7, $FB, $C8, $FB, $EB, $FB, $0F, $FC, $31, $FC
	.byte	$53, $FC, $71, $FC, $82, $FC, $A3, $FC, $C5, $FC, $A7, $FA, $A7, $FA, $A7, $FA
	.byte	$22, $FD, $33, $FD, $4E, $FD, $6E, $FD
data_05FA52:
	; CDL: read by sub_1DB98D
	.byte	$A7, $FA, $A7, $FA, $1C, $FB, $42, $FB, $5D, $FB, $A7, $FA, $BF, $FA, $D4, $FA
	.byte	$EB, $FA, $A7, $FA, $97, $FB, $B6, $FB, $D7, $FB, $FA, $FB, $1F, $FC, $41, $FC
	.byte	$63, $FC, $A7, $FA, $96, $FC, $B4, $FC, $D6, $FC, $E6, $FC, $FA, $FC, $0E, $FD
	.byte	$A7, $FA, $3E, $FD, $A7, $FA, $A7, $FA
	; CDL: read by draw_text, setup_stage_hdma; DMA / HDMA; partly not accessed
	.byte	$AA, $5D, $32, $00, $4E, $40, $3C, $48, $31, $FA, $FB, $FC, $00, $32, $FF, $AB
	.byte	$5C, $0B, $4C, $4A, $42, $4C, $3C, $48, $48, $40, $4C, $4D, $FF, $F0, $5C, $00
	.byte	$FF, $23, $5D, $48, $3C, $44, $49, $00, $3C, $49, $3F, $00, $4E, $4A, $0B, $31
	.byte	$50, $44, $40, $51, $FF, $68, $5D, $53, $3C, $44, $0B, $4A, $49, $FF, $B1, $5D
	.byte	$4D, $44, $3F, $40, $31, $50, $44, $40, $51, $FF, $F1, $5D, $02, $0A, $0A, $02
	.byte	$30, $49, $3C, $48, $44, $FF, $27, $5E, $43, $40, $47, $0B, $31, $48, $3C, $49
	.byte	$FF, $68, $5E, $46, $2E, $43, $4A, $4C, $44, $4A, $FF, $A8, $5C, $50, $44, $4D
	.byte	$4F, $3C, $47, $00, $3F, $40, $4D, $44, $42, $49, $40, $4C, $4D, $FF, $23, $5D
	.byte	$48, $3C, $44, $49, $00, $3C, $49, $3F, $00, $3F, $44, $4C, $40, $3E, $4E, $40
	.byte	$3F, $FF, $64, $5D, $49, $4A, $3D, $4F, $53, $3C, $00, $49, $3C, $46, $3C, $54
	.byte	$3C, $4E, $4A, $FF, $AD, $5D, $0B, $47, $3C, $53, $40, $4C, $4D, $00, $3E, $43
	.byte	$3C, $4C, $3C, $3E, $4E, $40, $4C, $FF, $EE, $5D, $48, $3C, $4D, $3C, $53, $4F
	.byte	$46, $44, $00, $4D, $3C, $4C, $4F, $4E, $3C, $FF, $28, $5E, $3C, $4D, $4D, $44
	.byte	$4D, $4E, $FF, $63, $5E, $49, $4A, $4C, $44, $4E, $4A, $4D, $43, $44, $00, $4D
	.byte	$3C, $4D, $3C, $46, $44, $FF, $A9, $5C, $4D, $4A, $4F, $49, $3F, $00, $3F, $40
	.byte	$4D, $44, $42, $49, $40, $4C, $4D, $FF, $22, $5D, $0B, $4C, $4A, $42, $4C, $3C
	.byte	$48, $00, $3C, $49, $3F, $00, $40, $41, $41, $40, $3E, $4E, $FF, $65, $5D, $3C
	.byte	$4E, $4D, $4F, $4D, $43, $44, $00, $41, $4F, $45, $44, $4A, $FF, $AF, $5D, $4D
	.byte	$4A, $4F, $49, $3F, $00, $40, $41, $41, $40, $3E, $4E, $FF, $EE, $5D, $48, $3C
	.byte	$4D, $3C, $49, $4A, $4C, $44, $00, $4A, $4A, $4F, $3E, $43, $44, $FF, $25, $5E
	.byte	$4D, $4A, $4F, $49, $3F, $00, $40, $41, $41, $40, $3E, $4E, $FF, $63, $5E, $43
	.byte	$44, $4C, $4A, $4D, $43, $44, $00, $46, $4A, $3D, $3C, $53, $3C, $4D, $43, $44
	.byte	$FF, $AF, $5E, $4D, $4A, $4F, $49, $3F, $00, $40, $41, $41, $40, $3E, $4E, $FF
	.byte	$EC, $5E, $43, $44, $4C, $4A, $41, $4F, $48, $44, $00, $4E, $3C, $49, $44, $42
	.byte	$4F, $3E, $43, $44, $FF, $2F, $5D, $48, $4F, $4D, $44, $3E, $00, $3E, $4A, $48
	.byte	$0B, $4A, $4D, $40, $FF, $6E, $5D, $48, $44, $46, $44, $00, $53, $3C, $49, $3C
	.byte	$42, $44, $4D, $3C, $51, $3C, $FF, $A5, $5D, $48, $4F, $4D, $44, $3E, $00, $3E
	.byte	$4A, $48, $0B, $4A, $4D, $40, $FF, $E4, $5D, $48, $3C, $4D, $3C, $49, $4A, $4C
	.byte	$44, $00, $3C, $3F, $3C, $3E, $43, $44, $FF, $2F, $5E, $48, $4F, $4D, $44, $3E
	.byte	$00, $3E, $4A, $48, $0B, $4A, $4D, $40, $FF, $70, $5E, $4E, $3C, $0B, $0B, $44
	.byte	$00, $44, $51, $3C, $4D, $40, $FF, $A9, $5C, $4D, $0B, $40, $3E, $44, $3C, $47
	.byte	$00, $4E, $43, $3C, $49, $46, $4D, $FF, $2D, $5D, $4E, $40, $3E, $43, $49, $44
	.byte	$3E, $3C, $47, $00, $3C, $3F, $50, $44, $3E, $40, $3F, $FF, $70, $5D, $45, $4F
	.byte	$49, $00, $41, $4F, $4C, $3C, $49, $4A, $FF, $A4, $5D, $0B, $3C, $3E, $46, $3C
	.byte	$42, $40, $00, $3F, $40, $4D, $44, $42, $49, $FF, $E4, $5D, $46, $40, $49, $45
	.byte	$44, $00, $4D, $43, $44, $48, $4A, $44, $3F, $40, $FF, $2E, $5E, $0B, $3C, $3E
	.byte	$46, $3C, $42, $40, $00, $3F, $40, $4D, $44, $42, $49, $FF, $6F, $5E, $43, $44
	.byte	$4C, $4A, $48, $44, $00, $4D, $4F, $48, $44, $3F, $3C, $FF, $28, $5D, $3C, $3E
	.byte	$00, $00, $32, $3E, $4A, $49, $4E, $4C, $3C, $32, $00, $4E, $40, $3C, $48, $FF
	.byte	$A8, $5D, $49, $40, $4D, $00, $32, $3E, $4A, $49, $4E, $4C, $3C, $32, $00, $4E
	.byte	$40, $3C, $48, $FF, $28, $5E, $3F, $48, $42, $00, $32, $3E, $4A, $49, $4E, $4C
	.byte	$3C, $32, $00, $4E, $40, $3C, $48, $FF, $AE, $5E, $2E, $2E, $2E, $48, $3C, $49
	.byte	$53, $00, $4E, $43, $3C, $49, $46, $4D, $FF, $AC, $5D, $0B, $4C, $4A, $3F, $4F
	.byte	$3E, $40, $3F, $FF, $EA, $5D, $46, $3C, $54, $4F, $48, $44, $00, $46, $44, $4E
	.byte	$3C, $4F, $40, $FF, $22, $5D, $32, $00, $3E, $A0, $9F, $A5, $A3, $92, $00, $44
	.byte	$44, $44, $00, $4E, $99, $96, $00, $3C, $9D, $9A, $96, $9F, $00, $51, $92, $A3
	.byte	$A4, $00, $32, $FF, $A4, $5D, $3C, $00, $0B, $96, $92, $94, $96, $97, $A6, $9D
	.byte	$00, $4E, $9A, $9E, $96, $00, $51, $9A, $9D, $9D, $00, $3E, $A0, $9E, $96, $AD
	.byte	$FF
hdma_list_05FD8B:
	hdma_channel_ind	$4370, $00, $2C, hdma_table_05FD96, $05
	hdma_channels_end	$80
hdma_table_05FD96:
	.byte	$1F, $12, $7F, $16
	.byte	$00
data_05FD9B:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk (+1 more); partly not accessed
	.addr	load_list_05FDA1, load_list_05FDAA, load_list_05FDB3
load_list_05FDA1:
	load_list	$00, $01
	load_vram	$5C00, gfx_06F84C
	load_end
load_list_05FDAA:
	load_list	$00, $01
	load_vram	$5C00, gfx_06F996
	load_end
load_list_05FDB3:
	load_list	$00, $01
	load_vram	$5C00, gfx_07F78E
	load_end
ptrs_05FDBC:
	.addr	load_list_05FDC6
	.addr	load_list_05FDCF
	.addr	load_list_05FDD8
	.addr	load_list_05FDE1
	.addr	load_list_05FDEA
load_list_05FDC6:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_17E599
	load_end
load_list_05FDCF:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_14DC62
	load_end
load_list_05FDD8:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_17D20E
	load_end
load_list_05FDE1:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_14F0F8
	load_end
load_list_05FDEA:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$3000, gfx_19EF62
	load_end
data_05FDF3:
	; CDL: read by ending_sequence_state_1B
	.byte	$00, $00, $10, $00
data_05FDF7:
	; CDL: read by ending_sequence_state_1B
	.byte	$08, $4C, $08, $4D
data_05FDFB:
	; CDL: read by start_palette_task_at, palette_task_fade_out, palette_task_fade_in (+2 more)
	.addr	vram_blocks_05FE07
	.addr	vram_blocks_05FE27
	.addr	vram_blocks_05FE47
	.addr	vram_blocks_05FE67
	.addr	vram_blocks_05FE87
	.addr	vram_blocks_05FEA7
vram_blocks_05FE07:
	.byte	$80, $C4, $A0, $C4
	.byte	$C0, $C4, $E0, $C4, $00, $C5, $20, $C5, $40, $C5, $60, $C5, $80, $C5, $A0, $C5
	.byte	$C0, $C5, $E0, $C5, $00, $C6, $20, $C6, $40, $C6, $60, $C6
vram_blocks_05FE27:
	.byte	$80, $C6, $A0, $C6
	.byte	$C0, $C6, $E0, $C6, $00, $C7, $20, $C7, $40, $C7, $60, $C7, $80, $C7, $A0, $C7
	.byte	$C0, $C7, $E0, $C7, $00, $C8, $20, $C8, $40, $C8, $60, $C8
vram_blocks_05FE47:
	.byte	$80, $C8, $A0, $C8
	.byte	$C0, $C8, $E0, $C8, $00, $C9, $20, $C9, $40, $C9, $60, $C9, $80, $C9, $A0, $C9
	.byte	$C0, $C9, $E0, $C9, $00, $CA, $20, $CA, $40, $CA, $60, $CA
vram_blocks_05FE67:
	.byte	$80, $CA, $A0, $CA
	.byte	$C0, $CA, $E0, $CA, $00, $CB, $20, $CB, $40, $CB, $60, $CB, $80, $CB, $A0, $CB
	.byte	$C0, $CB, $E0, $CB, $00, $CC, $20, $CC, $40, $CC, $60, $CC
vram_blocks_05FE87:
	.byte	$80, $CC, $A0, $CC
	.byte	$C0, $CC, $E0, $CC, $00, $CD, $20, $CD, $40, $CD, $60, $CD, $80, $CD, $A0, $CD
	.byte	$C0, $CD, $E0, $CD, $00, $CE, $20, $CE, $40, $CE, $60, $CE
vram_blocks_05FEA7:
	.byte	$00, $B0, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
	.byte	$00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0, $00, $B0
palette_task_05FEC7:
	palette_fade_in	$12, palette_08F01A, $2202
palette_task_05FECD:
	palette_fade_out	$12, palette_08F01A, $2202
palette_task_05FED3:
	palette_fade_in	$12, palette_08F00C, $22B4
palette_task_05FED9:
	palette_fade_out	$12, palette_08F00C, $22B4
load_list_05FEDF:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk (+2 more)
	load_list	$00, $01
	load_vram	$7000, gfx_0BE86E
	load_end
palette_task_05FEE8:
	palette_animate	$00, $00
	palette_copy	palette_088B18, $2340
	palette_copy_end
data_05FEF1:
	; CDL: read by sub_1DBDA0
	.byte	$00, $E0, $00, $20
data_05FEF5:
	; CDL: read by draw_text, sub_1DBDA0
	.byte	$FF, $FF, $00, $00
text_05FEF9:
	.byte	$E9, $5E, $0B, $4F, $4D, $43, $00, $4D, $4E, $3C, $4C, $4E
	.byte	$00, $46, $40, $53, $FF
text_05FF0A:
	.byte	$E9, $5E, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $FF
data_05FF1B:
	; CDL: read by brain_boss_state_07
	.byte	$70, $00, $C0, $00
data_05FF1F:
	; CDL: read by brain_boss_state_07
	.byte	$03, $00, $09, $00
data_05FF23:
	; CDL: read by update_brain_boss_rolling_eye
	.byte	$10, $00, $20, $00
load_list_05FF27:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$7000, gfx_0EB8F7
	load_end
load_list_05FF30:
	; CDL: read by load_data_list, step_vram_loader, decompress_chunk
	load_list	$00, $01
	load_vram	$1000, gfx_0F9460
	load_vram	$2000, gfx_119D0E
	load_end
data_05FF3E:
	; CDL: read by brain_boss_init_minion
	.byte	$1C, $00, $3D, $40, $00, $40, $3F, $40, $3D, $40, $3D, $40, $1F, $00, $3F
data_05FF4D:
	; CDL: read by setup_stage_hdma, queue_vram_blocks_at_x, brain_boss_init_minion; partly not accessed
	.byte	$40
hdma_list_05FF4E:
	hdma_channel_ind	$4370, $42, $10, $7EEA00, $7E
	hdma_channels_end	$80
	.byte	$A0, $B3, $C0, $B3
	.byte	$C0, $BE, $E0, $BE
data_05FF61:
	; CDL: read by brain_boss_attack_3; partly not accessed
	.byte	$40, $00, $50, $00, $80, $00
data_05FF67:
	; CDL: read by brain_boss_spawn_orb_clusters
	.addr	metasprite_06C514, metasprite_06C525, metasprite_06C536, metasprite_06C558
	.addr	metasprite_06C547, metasprite_06C569, metasprite_06C57A, metasprite_06C58B
data_05FF77:
	; CDL: read by brain_boss_spawn_orb_clusters
	.byte	$00, $06, $00, $06, $00, $06, $00, $04, $00, $00, $00, $0E, $00, $04, $00, $00
data_05FF87:
	; CDL: read by brain_boss_attack_4_step_01, brain_boss_attack_4_step_04
	.byte	$00, $04, $40
data_05FF8A:
	; CDL: read by brain_boss_attack_4_step_01
	.byte	$05
data_05FF8B:
	; CDL: read by brain_boss_attack_4_step_02
	.byte	$74, $00, $8C
data_05FF8E:
	; CDL: read by brain_boss_attack_4_step_02
	.byte	$00, $80, $00, $80, $00
data_05FF93:
	; CDL: read by brain_boss_attack_4_step_02
	.byte	$FF, $FF, $01, $00, $01, $00, $FF, $FF
; OBJ_HP of brain_boss by difficulty (easy, normal, hard)
brain_boss_hp:
	; CDL: read by brain_boss_state_00; partly not accessed
	.word	ENEMY_HP($0401), ENEMY_HP($4256), ENEMY_HP($7532)
data_05FFA1:
	; CDL: read by brain_boss_state_0A
	.byte	$F8, $FF, $FF, $FF
data_05FFA5:
	; CDL: read by brain_boss_state_0A; partly not accessed
	.addr	anim_05C6EA
	.addr	anim_05C558
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF

.if CHEAT_ENEMY_HP <> 100
; cheat_enemy_hp_tables: with CHEAT_ENEMY_HP, the scaled copies of the HP tables
; whose bytes are also read as something else (the end of an animation
; script read by td_animate_enemy or update_objects, a DMA, the next
; table): the original bytes stay where they were, unlabelled, for those
; readers, and the HP label moves here (in the free space of the bank).
cheat_enemy_hp_tables:
alien_dog_hp:
	.word	ENEMY_HP($0000), ENEMY_HP($0002), ENEMY_HP($0008)
stage1_boss_shell_hp:
	.word	ENEMY_HP($0080), ENEMY_HP($0100), ENEMY_HP($7FFF)
td_runner_hp:
	.word	ENEMY_HP($0000), ENEMY_HP($0002), ENEMY_HP($0004)
hatch_turret_hp:
	.word	ENEMY_HP($0010), ENEMY_HP($0020), ENEMY_HP($0040)
td_centipede_unused_hp:
	.word	ENEMY_HP($0010), ENEMY_HP($0040), ENEMY_HP($0080)
td_bug_centipede_hp:
	.word	ENEMY_HP($0010), ENEMY_HP($0040), ENEMY_HP($0080)
td_nest_crawler_hp:
	.word	ENEMY_HP($0002), ENEMY_HP($0010), ENEMY_HP($0020)
td_crawler_hp:
	.word	ENEMY_HP($0002), ENEMY_HP($0004), ENEMY_HP($0008)
lightning_pylon_hp:
	.word	ENEMY_HP($0040), ENEMY_HP($0060), ENEMY_HP($7FFF)
heart_boss_hp:
	.word	ENEMY_HP($0080), ENEMY_HP($0100), ENEMY_HP($0180)
.endif
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
