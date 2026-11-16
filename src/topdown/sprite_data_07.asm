; topdown/sprite_data_07.asm -- Top-down stages: sprite data (bank $07)
; Bank $07, $07:8000-$07:FFFF. Included by main.asm in segment BANK07.
;
; Data of the top-down sprite code (topdown/sprite_render.asm): metasprites
; (draw_topdown_metasprite), sprite tiles by angle, tables for the sprite
; graphics stream; also some compressed graphics (read by the decompressor)
; and the per-map tile attribute tables (tile_attrs_stage2 ...) used by
; build_tile_attr_rows.

; The bank of the top-down sprite data (DB = ^sprite_data_07).
sprite_data_07:
; X offsets of the 9 pieces of rubble of the stage 2 boss arena; read with
; X = 2-$12 as stage2_arena_rubble_x - 2 (indexed from 1, like
; stage2_arena_rubble_y).
stage2_arena_rubble_x:
	; CDL: read by draw_stage2_boss_arena
	.byte	$D0, $FF, $50, $00, $D0, $00, $D0, $FF, $50, $00, $D0, $00, $D0, $FF, $50, $00
stage2_arena_rubble_y:
	; LAYOUT: read on from stage2_arena_rubble_x (adc a:stage2_arena_rubble_x - 2,x)
	; CDL: read by draw_stage2_boss_arena
	.byte	$D0, $00, $D0, $FF, $D0, $FF, $D0, $FF, $50, $00, $50, $00, $50, $00, $D0, $00
	.byte	$D0, $00
stage2_arena_debris_x:
	; LAYOUT: read on from stage2_arena_rubble_y (adc a:stage2_arena_rubble_y,x)
	; CDL: read by draw_stage2_boss_arena
	.byte	$D0, $00, $80, $FF, $00, $00, $80, $00, $00, $01, $80, $FF, $B0, $FF, $00, $00
	.byte	$30, $00, $80, $00, $B0, $00, $00, $01, $80, $FF, $B0, $FF, $00, $00, $30, $00
	.byte	$80, $00, $B0, $00, $00, $01, $80, $FF, $B0, $FF, $00, $00, $30, $00, $80, $00
	.byte	$B0, $00
stage2_arena_debris_y:
	; LAYOUT: read on from stage2_arena_debris_x (adc a:stage2_arena_debris_x,x)
	; CDL: read by draw_stage2_boss_arena
	.byte	$00, $01, $88, $FF, $88, $FF, $88, $FF, $88, $FF, $08, $00, $B0, $FF, $08, $00
	.byte	$B0, $FF, $08, $00, $B0, $FF, $08, $00, $88, $00, $30, $00, $88, $00, $30, $00
	.byte	$88, $00, $30, $00, $88, $00, $08, $01, $B0, $00, $08, $01, $B0, $00, $08, $01
	.byte	$B0, $00, $08, $01
td_player_stream_slots:
	; CDL: read by draw_topdown_players
	.byte	$00, $00, $08, $00
td_enemy_stream_slots:
	; CDL: read by draw_enemies
	.byte	$10, $00, $18, $00, $20, $00, $28, $00, $30, $00, $38, $00
td_player_stream_slots_p2_view:
	; CDL: read by draw_topdown_players_p2
	.byte	$40, $00, $48, $00
td_enemy_stream_slots_p2_view:
	; CDL: read by draw_enemies_p2
	.byte	$50, $00, $58, $00, $60, $00, $68, $00, $70, $00, $78, $00
td_player_sprite_attrs:
	; CDL: read by draw_topdown_players
	.byte	$00, $00, $08, $00
td_enemy_sprite_attrs:
	; CDL: read by draw_enemies
	.byte	$20, $00, $28, $00, $40, $00, $48, $00, $60, $00, $68, $00
td_player_sprite_attrs_p2_view:
	; CDL: read by draw_topdown_players_p2
	.byte	$80, $00, $88, $00
td_enemy_sprite_attrs_p2_view:
	; CDL: read by draw_enemies_p2
	.byte	$A0, $00, $A8, $00, $C0, $00, $C8, $00, $E0, $00, $E8, $00
td_small_object_tiles:
	; CDL: read by draw_small_objects, draw_small_objects_p2; partly not accessed
	.byte	$04, $01, $04, $01, $04, $01, $04, $01, $06, $01, $06, $01, $06, $01, $06, $01
	.byte	$06, $01, $06, $01, $06, $01, $06, $01, $08, $01, $08, $01, $08, $01, $08, $01
	.byte	$08, $01, $08, $01, $08, $01, $08, $01, $0A, $01, $0A, $01, $0A, $01, $0A, $01
	.byte	$0A, $01, $0A, $01, $0A, $01, $0A, $01, $0C, $01, $0C, $01, $0C, $01, $0C, $01
	.byte	$0C, $01, $0C, $01, $0C, $01, $0C, $01, $0E, $01, $0E, $01, $0E, $01, $0E, $01
	.byte	$0E, $01, $0E, $01, $0E, $01, $0E, $01, $20, $01, $20, $01, $20, $01, $20, $01
	.byte	$20, $01, $20, $01, $20, $01, $20, $01, $22, $01, $22, $01, $22, $01, $22, $01
	.byte	$22, $01, $22, $01, $22, $01, $22, $01, $24, $81, $24, $81, $24, $81, $24, $81
	.byte	$24, $81, $24, $81, $24, $81, $24, $81, $22, $81, $22, $81, $22, $81, $22, $81
	.byte	$22, $81, $22, $81, $22, $81, $22, $81, $20, $81, $20, $81, $20, $81, $20, $81
	.byte	$20, $81, $20, $81, $20, $81, $20, $81, $0E, $81, $0E, $81, $0E, $81, $0E, $81
	.byte	$0E, $81, $0E, $81, $0E, $81, $0E, $81, $0C, $81, $0C, $81, $0C, $81, $0C, $81
	.byte	$0C, $81, $0C, $81, $0C, $81, $0C, $81, $0A, $81, $0A, $81, $0A, $81, $0A, $81
	.byte	$0A, $81, $0A, $81, $0A, $81, $0A, $81, $08, $81, $08, $81, $08, $81, $08, $81
	.byte	$08, $81, $08, $81, $08, $81, $08, $81, $06, $81, $06, $81, $06, $81, $06, $81
	.byte	$06, $81, $06, $81, $06, $81, $06, $81, $04, $C1, $04, $C1, $04, $C1, $04, $C1
	.byte	$04, $C1, $04, $C1, $04, $C1, $04, $C1, $06, $C1, $06, $C1, $06, $C1, $06, $C1
	.byte	$06, $C1, $06, $C1, $06, $C1, $06, $C1, $08, $C1, $08, $C1, $08, $C1, $08, $C1
	.byte	$08, $C1, $08, $C1, $08, $C1, $08, $C1, $0A, $C1, $0A, $C1, $0A, $C1, $0A, $C1
	.byte	$0A, $C1, $0A, $C1, $0A, $C1, $0A, $C1, $0C, $C1, $0C, $C1, $0C, $C1, $0C, $C1
	.byte	$0C, $C1, $0C, $C1, $0C, $C1, $0C, $C1, $0E, $C1, $0E, $C1, $0E, $C1, $0E, $C1
	.byte	$0E, $C1, $0E, $C1, $0E, $C1, $0E, $C1, $20, $C1, $20, $C1, $20, $C1, $20, $C1
	.byte	$20, $C1, $20, $C1, $20, $C1, $20, $C1, $22, $C1, $22, $C1, $22, $C1, $22, $C1
	.byte	$22, $C1, $22, $C1, $22, $C1, $22, $C1, $24, $41, $24, $41, $24, $41, $24, $41
	.byte	$24, $41, $24, $41, $24, $41, $24, $41, $22, $41, $22, $41, $22, $41, $22, $41
	.byte	$22, $41, $22, $41, $22, $41, $22, $41, $20, $41, $20, $41, $20, $41, $20, $41
	.byte	$20, $41, $20, $41, $20, $41, $20, $41, $0E, $41, $0E, $41, $0E, $41, $0E, $41
	.byte	$0E, $41, $0E, $41, $0E, $41, $0E, $41, $0C, $41, $0C, $41, $0C, $41, $0C, $41
	.byte	$0C, $41, $0C, $41, $0C, $41, $0C, $41, $0A, $41, $0A, $41, $0A, $41, $0A, $41
	.byte	$0A, $41, $0A, $41, $0A, $41, $0A, $41, $08, $41, $08, $41, $08, $41, $08, $41
	.byte	$08, $41, $08, $41, $08, $41, $08, $41, $06, $41, $06, $41, $06, $41, $06, $41
	.byte	$06, $41, $06, $41, $06, $41, $06, $41, $04, $01, $04, $01, $04, $01, $04, $01
	.byte	$26, $01, $26, $01, $26, $01, $26, $01, $28, $01, $28, $01, $28, $01, $28, $01
	.byte	$28, $01, $28, $01, $28, $01, $28, $01, $2A, $01, $2A, $01, $2A, $01, $2A, $01
	.byte	$2A, $01, $2A, $01, $2A, $01, $2A, $01, $2C, $01, $2C, $01, $2C, $01, $2C, $01
	.byte	$2C, $01, $2C, $01, $2C, $01, $2C, $01, $2E, $01, $2E, $01, $2E, $01
	.byte	$2E, $01, $2E, $01, $2E, $01, $2E, $01, $2E, $01, $40, $01, $40, $01, $40, $01
	.byte	$40, $01, $40, $01, $40, $01, $40, $01, $40, $01, $42, $01, $42, $01, $42, $01
	.byte	$42, $01, $42, $01, $42, $01, $42, $01, $42, $01, $44, $01, $44, $01, $44, $01
	.byte	$44, $01, $44, $01, $44, $01, $44, $01, $44, $01, $46, $81, $46, $81, $46, $81
	.byte	$46, $81, $46, $81, $46, $81, $46, $81, $46, $81, $44, $81, $44, $81, $44, $81
	.byte	$44, $81, $44, $81, $44, $81, $44, $81, $44, $81, $42, $81, $42, $81, $42, $81
	.byte	$42, $81, $42, $81, $42, $81, $42, $81, $42, $81, $40, $81, $40, $81, $40, $81
	.byte	$40, $81, $40, $81, $40, $81, $40, $81, $40, $81, $2E, $81, $2E, $81, $2E, $81
	.byte	$2E, $81, $2E, $81, $2E, $81, $2E, $81, $2E, $81, $2C, $81, $2C, $81, $2C, $81
	.byte	$2C, $81, $2C, $81, $2C, $81, $2C, $81, $2C, $81, $2A, $81, $2A, $81, $2A, $81
	.byte	$2A, $81, $2A, $81, $2A, $81, $2A, $81, $2A, $81, $28, $81, $28, $81, $28, $81
	.byte	$28, $81, $28, $81, $28, $81, $28, $81, $28, $81, $26, $C1, $26, $C1, $26, $C1
	.byte	$26, $C1, $26, $C1, $26, $C1, $26, $C1, $26, $C1, $28, $C1, $28, $C1, $28, $C1
	.byte	$28, $C1, $28, $C1, $28, $C1, $28, $C1, $28, $C1, $2A, $C1, $2A, $C1, $2A, $C1
	.byte	$2A, $C1, $2A, $C1, $2A, $C1, $2A, $C1, $2A, $C1, $2C, $C1, $2C, $C1, $2C, $C1
	.byte	$2C, $C1, $2C, $C1, $2C, $C1, $2C, $C1, $2C, $C1, $2E, $C1, $2E, $C1, $2E, $C1
	.byte	$2E, $C1, $2E, $C1, $2E, $C1, $2E, $C1, $2E, $C1, $40, $C1, $40, $C1, $40, $C1
	.byte	$40, $C1, $40, $C1, $40, $C1, $40, $C1, $40, $C1, $42, $C1, $42, $C1, $42, $C1
	.byte	$42, $C1, $42, $C1, $42, $C1, $42, $C1, $42, $C1, $44, $C1, $44, $C1, $44, $C1
	.byte	$44, $C1, $44, $C1, $44, $C1, $44, $C1, $44, $C1, $46, $41, $46, $41, $46, $41
	.byte	$46, $41, $46, $41, $46, $41, $46, $41, $46, $41, $44, $41, $44, $41, $44, $41
	.byte	$44, $41, $44, $41, $44, $41, $44, $41, $44, $41, $42, $41, $42, $41, $42, $41
	.byte	$42, $41, $42, $41, $42, $41, $42, $41, $42, $41, $40, $41, $40, $41, $40, $41
	.byte	$40, $41, $40, $41, $40, $41, $40, $41, $40, $41, $2E, $41, $2E, $41, $2E, $41
	.byte	$2E, $41, $2E, $41, $2E, $41, $2E, $41, $2E, $41, $2C, $41, $2C, $41, $2C, $41
	.byte	$2C, $41, $2C, $41, $2C, $41, $2C, $41, $2C, $41, $2A, $41, $2A, $41, $2A, $41
	.byte	$2A, $41, $2A, $41, $2A, $41, $2A, $41, $2A, $41, $28, $41, $28, $41, $28, $41
	.byte	$28, $41, $28, $41, $28, $41, $28, $41, $28, $41, $26, $01, $26, $01, $26, $01
	.byte	$26, $01, $64, $01, $64, $01, $64, $01, $64, $01, $66, $01, $66, $01, $66, $01
	.byte	$66, $01, $66, $01, $66, $01, $66, $01, $66, $01, $68, $01, $68, $01, $68, $01
	.byte	$68, $01, $68, $01, $68, $01, $68, $01, $68, $01, $6A, $01, $6A, $01, $6A, $01
	.byte	$6A, $01, $6A, $01, $6A, $01, $6A, $01, $6A, $01, $6C, $01, $6C, $01, $6C, $01
	.byte	$6C, $01, $6C, $01, $6C, $01, $6C, $01, $6C, $01, $6E, $01, $6E, $01, $6E, $01
	.byte	$6E, $01, $6E, $01, $6E, $01, $6E, $01, $6E, $01, $80, $01, $80, $01, $80, $01
	.byte	$80, $01, $80, $01, $80, $01, $80, $01, $80, $01, $82, $01, $82, $01, $82, $01
	.byte	$82, $01, $82, $01, $82, $01, $82, $01, $82, $01, $84, $81, $84, $81, $84, $81
	.byte	$84, $81, $84, $81, $84, $81, $84, $81, $84, $81, $82, $81, $82, $81, $82, $81
	.byte	$82, $81, $82, $81, $82, $81, $82, $81, $82, $81, $80, $81, $80, $81, $80, $81
	.byte	$80, $81, $80, $81, $80, $81, $80, $81, $80, $81, $6E, $81, $6E, $81, $6E, $81
	.byte	$6E, $81, $6E, $81, $6E, $81, $6E, $81, $6E, $81, $6C, $81, $6C, $81, $6C, $81
	.byte	$6C, $81, $6C, $81, $6C, $81, $6C, $81, $6C, $81, $6A, $81, $6A, $81, $6A, $81
	.byte	$6A, $81, $6A, $81, $6A, $81, $6A, $81, $6A, $81, $68, $81, $68, $81, $68, $81
	.byte	$68, $81, $68, $81, $68, $81, $68, $81, $68, $81, $66, $81, $66, $81, $66, $81
	.byte	$66, $81, $66, $81, $66, $81, $66, $81, $66, $81, $64, $C1, $64, $C1, $64, $C1
	.byte	$64, $C1, $64, $C1, $64, $C1, $64, $C1, $64, $C1, $66, $C1, $66, $C1, $66, $C1
	.byte	$66, $C1, $66, $C1, $66, $C1, $66, $C1, $66, $C1, $68, $C1, $68, $C1, $68, $C1
	.byte	$68, $C1, $68, $C1, $68, $C1, $68, $C1, $68, $C1, $6A, $C1, $6A, $C1, $6A, $C1
	.byte	$6A, $C1, $6A, $C1, $6A, $C1, $6A, $C1, $6A, $C1, $6C, $C1, $6C, $C1, $6C, $C1
	.byte	$6C, $C1, $6C, $C1, $6C, $C1, $6C, $C1, $6C, $C1, $6E, $C1, $6E, $C1, $6E, $C1
	.byte	$6E, $C1, $6E, $C1, $6E, $C1, $6E, $C1, $6E, $C1, $80, $C1, $80, $C1, $80, $C1
	.byte	$80, $C1, $80, $C1, $80, $C1, $80, $C1, $80, $C1, $82, $C1, $82, $C1, $82, $C1
	.byte	$82, $C1, $82, $C1, $82, $C1, $82, $C1, $82, $C1, $84, $41, $84, $41, $84, $41
	.byte	$84, $41, $84, $41, $84, $41, $84, $41, $84, $41, $82, $41, $82, $41, $82, $41
	.byte	$82, $41, $82, $41, $82, $41, $82, $41, $82, $41, $80, $41, $80, $41, $80, $41
	.byte	$80, $41, $80, $41, $80, $41, $80, $41, $80, $41, $6E, $41, $6E, $41, $6E, $41
	.byte	$6E, $41, $6E, $41, $6E, $41, $6E, $41, $6E, $41, $6C, $41, $6C, $41, $6C, $41
	.byte	$6C, $41, $6C, $41
	; CDL: read by draw_small_objects
	.byte	$6C, $41, $6C, $41, $6C, $41, $6A, $41, $6A, $41, $6A, $41, $6A, $41, $6A, $41
	.byte	$6A, $41, $6A, $41, $6A, $41, $68, $41, $68, $41, $68, $41, $68, $41, $68, $41
	.byte	$68, $41, $68, $41, $68, $41, $66, $41, $66, $41, $66, $41, $66, $41, $66, $41
	.byte	$66, $41, $66, $41, $66, $41, $64, $01, $64, $01, $64, $01, $64, $01
	; CDL: not accessed
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
	.byte	$FF, $FF, $FF, $FF, $FE, $FE, $FD, $FC, $FB, $F9, $F8, $F6, $F4, $F3, $F1, $EE
	.byte	$EC, $EA, $E7, $E4, $E1, $DE, $DB, $D8, $D4, $D1, $CD, $C9, $C5, $C1, $BD, $B9
	.byte	$B5, $B0, $AB, $A7, $A2, $9D, $98, $93, $8E, $88, $83, $7E, $78, $73, $6D, $67
	.byte	$61, $5C, $56, $50, $4A, $44, $3E, $38, $31, $2B, $25, $1F, $19, $12, $0C, $06
	.byte	$00, $06, $0C, $12, $19, $1F, $25, $2B, $31, $38, $3E, $44, $4A, $50, $56, $5C
	.byte	$61, $67, $6D, $73, $78, $7E, $83, $88, $8E, $93, $98, $9D, $A2, $A7, $AB, $B0
	.byte	$B5, $B9, $BD, $C1, $C5, $C9, $CD, $D1, $D4, $D8, $DB, $DE, $E1, $E4, $E7, $EA
	.byte	$EC, $EE, $F1, $F3, $F4, $F6, $F8, $F9, $FB, $FC, $FD, $FE, $FE, $FF
; Sprites of the rotating top-down objects, by sprite set (object field +$00:
; 1 player, 2 stage 2 boss cannon, 3 and 4 the rubble and debris of the stage
; 2 boss arena, 5 crawler, 6 runner / gunner / hatch turret, 7 centipede,
; 9 explosion, $11 stage 5 boss claw; set 0 is "nothing"): a table of
; metasprites and one of tiles (td_tiles, for stream_topdown_sprite_gfx),
; both indexed by animation frame * 32 + angle / 8 (32 angles per frame).
; The sets not used (8, $0A-$10) point at this table.  ptrs_td_tile_lists
; overlaps this one: its entry 0 (set 0, never read) is entry $11 here.
ptrs_td_metasprite_sets:
	; CDL: read by draw_enemies, draw_topdown_players, draw_stage2_boss_cannon (+1 more); partly not accessed
	.byte	$FF, $FF
	.addr	td_metasprites_player
	.addr	td_metasprites_stage2_boss_cannon
	.addr	stage2_arena_rubble_metasprites
	.addr	stage2_arena_rubble_metasprites
	.addr	td_metasprites_crawler
	.addr	td_metasprites_runner_gunner
	.addr	td_metasprites_centipede
	.addr	ptrs_td_metasprite_sets + 2
	.addr	td_metasprites_explosion
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
ptrs_td_tile_lists:
	; LAYOUT: read on from ptrs_td_metasprite_sets (lda a:ptrs_td_metasprite_sets,y)
	; CDL: read by draw_enemies, draw_topdown_players, draw_stage2_boss_cannon (+3 more); partly not accessed
	.addr	td_metasprites_stage5_boss_claw		; entry $11 of ptrs_td_metasprite_sets
	.addr	td_tile_list_player
	.addr	td_tile_list_stage2_boss_cannon
	.addr	stage2_arena_rubble_tile_list
	.addr	stage2_arena_debris_tile_list
	.addr	td_tile_list_crawler
	.addr	td_tile_list_runner_gunner
	.addr	td_tile_list_centipede
	.addr	ptrs_td_metasprite_sets + 2
	.addr	td_tile_list_explosion
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	ptrs_td_metasprite_sets + 2
	.addr	td_tile_list_stage5_boss_claw
td_tile_list_player:
	.addr	td_tiles_078D4C
	.addr	td_tiles_078D52
	.addr	td_tiles_078D58
	.addr	td_tiles_078D5E
	.addr	td_tiles_078D64
	.addr	td_tiles_078D6A
	.addr	td_tiles_078D70
	.addr	td_tiles_078D76
	.addr	td_tiles_078D7C
	.addr	td_tiles_078D82
	.addr	td_tiles_078D88
	.addr	td_tiles_078D8E
	.addr	td_tiles_078D94
	.addr	td_tiles_078D9A
	.addr	td_tiles_078DA0
	.addr	td_tiles_078DA6
	.addr	td_tiles_078D4C
	.addr	td_tiles_078D52
	.addr	td_tiles_078D58
	.addr	td_tiles_078D5E
	.addr	td_tiles_078D64
	.addr	td_tiles_078D6A
	.addr	td_tiles_078D70
	.addr	td_tiles_078D76
	.addr	td_tiles_078D7C
	.addr	td_tiles_078D82
	.addr	td_tiles_078D88
	.addr	td_tiles_078D8E
	.addr	td_tiles_078D94
	.addr	td_tiles_078D9A
	.addr	td_tiles_078DA0
	.addr	td_tiles_078DA6
	.addr	td_tiles_078DAC
	.addr	td_tiles_078DB2
	.addr	td_tiles_078DB8
	.addr	td_tiles_078DBE
	.addr	td_tiles_078DC4
	.addr	td_tiles_078DCA
	.addr	td_tiles_078DD0
	.addr	td_tiles_078DD6
	.addr	td_tiles_078DDC
	.addr	td_tiles_078DE2
	.addr	td_tiles_078DE8
	.addr	td_tiles_078DEE
	.addr	td_tiles_078DF4
	.addr	td_tiles_078DFA
	.addr	td_tiles_078E00
	.addr	td_tiles_078E06
	.addr	td_tiles_078DAC
	.addr	td_tiles_078DB2
	.addr	td_tiles_078DB8
	.addr	td_tiles_078DBE
	.addr	td_tiles_078DC4
	.addr	td_tiles_078DCA
	.addr	td_tiles_078DD0
	.addr	td_tiles_078DD6
	.addr	td_tiles_078DDC
	.addr	td_tiles_078DE2
	.addr	td_tiles_078DE8
	.addr	td_tiles_078DEE
	.addr	td_tiles_078DF4
	.addr	td_tiles_078DFA
	.addr	td_tiles_078E00
	.addr	td_tiles_078E06
	.addr	td_tiles_078E0C
	.addr	td_tiles_078E12
	.addr	td_tiles_078E18
	.addr	td_tiles_078E1E
	.addr	td_tiles_078E24
	.addr	td_tiles_078E2A
	.addr	td_tiles_078E30
	.addr	td_tiles_078E36
	.addr	td_tiles_078E3C
	.addr	td_tiles_078E42
	.addr	td_tiles_078E48
	.addr	td_tiles_078E4E
	.addr	td_tiles_078E54
	.addr	td_tiles_078E5A
	.addr	td_tiles_078E60
	.addr	td_tiles_078E66
	.addr	td_tiles_078E0C
	.addr	td_tiles_078E12
	.addr	td_tiles_078E18
	.addr	td_tiles_078E1E
	.addr	td_tiles_078E24
	.addr	td_tiles_078E2A
	.addr	td_tiles_078E30
	.addr	td_tiles_078E36
	.addr	td_tiles_078E3C
	.addr	td_tiles_078E42
	.addr	td_tiles_078E48
	.addr	td_tiles_078E4E
	.addr	td_tiles_078E54
	.addr	td_tiles_078E5A
	.addr	td_tiles_078E60
	.addr	td_tiles_078E66
	.addr	td_tiles_078E6C
	.addr	td_tiles_078E72
	.addr	td_tiles_078E78
	.addr	td_tiles_078E7E
	.addr	td_tiles_078E84
	.addr	td_tiles_078E8A
	.addr	td_tiles_078E90
	.addr	td_tiles_078E96
	.addr	td_tiles_078E9C
	.addr	td_tiles_078EA2
	.addr	td_tiles_078EA8
	.addr	td_tiles_078EAE
	.addr	td_tiles_078EB4
	.addr	td_tiles_078EBA
	.addr	td_tiles_078EC0
	.addr	td_tiles_078EC6
	.addr	td_tiles_078E6C
	.addr	td_tiles_078E72
	.addr	td_tiles_078E78
	.addr	td_tiles_078E7E
	.addr	td_tiles_078E84
	.addr	td_tiles_078E8A
	.addr	td_tiles_078E90
	.addr	td_tiles_078E96
	.addr	td_tiles_078E9C
	.addr	td_tiles_078EA2
	.addr	td_tiles_078EA8
	.addr	td_tiles_078EAE
	.addr	td_tiles_078EB4
	.addr	td_tiles_078EBA
	.addr	td_tiles_078EC0
	.addr	td_tiles_078EC6
	.addr	td_tiles_078ECC
	.addr	td_tiles_078ED2
	.addr	td_tiles_078ED8
	.addr	td_tiles_078EDE
	.addr	td_tiles_078EE4
	.addr	td_tiles_078EEA
	.addr	td_tiles_078EF0
	.addr	td_tiles_078EF6
	.addr	td_tiles_078EFC
	.addr	td_tiles_078F02
	.addr	td_tiles_078F08
	.addr	td_tiles_078F0E
	.addr	td_tiles_078F14
	.addr	td_tiles_078F1A
	.addr	td_tiles_078F20
	.addr	td_tiles_078F26
	.addr	td_tiles_078ECC
	.addr	td_tiles_078ED2
	.addr	td_tiles_078ED8
	.addr	td_tiles_078EDE
	.addr	td_tiles_078EE4
	.addr	td_tiles_078EEA
	.addr	td_tiles_078EF0
	.addr	td_tiles_078EF6
	.addr	td_tiles_078EFC
	.addr	td_tiles_078F02
	.addr	td_tiles_078F08
	.addr	td_tiles_078F0E
	.addr	td_tiles_078F14
	.addr	td_tiles_078F1A
	.addr	td_tiles_078F20
	.addr	td_tiles_078F26
	.addr	td_tiles_078F2C
	.addr	td_tiles_078F32
	.addr	td_tiles_078F38
	.addr	td_tiles_078F3E
	.addr	td_tiles_078F44
	.addr	td_tiles_078F4A
	.addr	td_tiles_078F50
	.addr	td_tiles_078F56
	.addr	td_tiles_078F5C
	; CDL: read by draw_topdown_players, draw_topdown_players_p2; partly not accessed
	.addr	td_tiles_078F56
	.addr	td_tiles_078F50
	.addr	td_tiles_078F4A
	.addr	td_tiles_078F44
	.addr	td_tiles_078F3E
	.addr	td_tiles_078F38
	.addr	td_tiles_078F32
	.addr	td_tiles_078F2C
	.addr	td_tiles_078F32
	.addr	td_tiles_078F38
	.addr	td_tiles_078F3E
	.addr	td_tiles_078F44
	.addr	td_tiles_078F4A
	.addr	td_tiles_078F50
	.addr	td_tiles_078F56
	.addr	td_tiles_078F5C
	.addr	td_tiles_078F56
	.addr	td_tiles_078F50
	.addr	td_tiles_078F4A
	.addr	td_tiles_078F44
	.addr	td_tiles_078F3E
	.addr	td_tiles_078F38
	.addr	td_tiles_078F32
	.addr	td_tiles_078F62
	.addr	td_tiles_078F68
	.addr	td_tiles_078F6E
	.addr	td_tiles_078F74
	.addr	td_tiles_078F7A
	.addr	td_tiles_078F80
	.addr	td_tiles_078F86
	.addr	td_tiles_078F8C
	.addr	td_tiles_078F92
	.addr	td_tiles_078F8C
	.addr	td_tiles_078F86
	.addr	td_tiles_078F80
	.addr	td_tiles_078F7A
	.addr	td_tiles_078F74
	.addr	td_tiles_078F6E
	.addr	td_tiles_078F68
	.addr	td_tiles_078F62
	.addr	td_tiles_078F68
	.addr	td_tiles_078F6E
	.addr	td_tiles_078F74
	.addr	td_tiles_078F7A
	.addr	td_tiles_078F80
	.addr	td_tiles_078F86
	.addr	td_tiles_078F8C
	.addr	td_tiles_078F92
	.addr	td_tiles_078F8C
	.addr	td_tiles_078F86
	.addr	td_tiles_078F80
	.addr	td_tiles_078F7A
	.addr	td_tiles_078F74
	.addr	td_tiles_078F6E
	.addr	td_tiles_078F68
	.addr	td_tiles_078F98
	.addr	td_tiles_078FF2
	.addr	td_tiles_078FEC
	.addr	td_tiles_078FE6
	.addr	td_tiles_078FE0
	.addr	td_tiles_078FDA
	.addr	td_tiles_078FD4
	.addr	td_tiles_078FCE
	.addr	td_tiles_078FC8
	.addr	td_tiles_078FC2
	.addr	td_tiles_078FBC
	.addr	td_tiles_078FB6
	.addr	td_tiles_078FB0
	.addr	td_tiles_078FAA
	.addr	td_tiles_078FA4
	.addr	td_tiles_078F9E
	.addr	td_tiles_078F98
	.addr	td_tiles_078FF2
	.addr	td_tiles_078FEC
	.addr	td_tiles_078FE6
	.addr	td_tiles_078FE0
	.addr	td_tiles_078FDA
	.addr	td_tiles_078FD4
	.addr	td_tiles_078FCE
	.addr	td_tiles_078FC8
	.addr	td_tiles_078FC2
	.addr	td_tiles_078FBC
	.addr	td_tiles_078FB6
	.addr	td_tiles_078FB0
	.addr	td_tiles_078FAA
	.addr	td_tiles_078FA4
	.addr	td_tiles_078F9E
	.addr	td_tiles_078FF8
	.addr	td_tiles_079052
	.addr	td_tiles_07904C
	.addr	td_tiles_079046
	.addr	td_tiles_079040
	.addr	td_tiles_07903A
	.addr	td_tiles_079034
	.addr	td_tiles_07902E
	.addr	td_tiles_079028
	.addr	td_tiles_079022
	.addr	td_tiles_07901C
	.addr	td_tiles_079016
	.addr	td_tiles_079010
	.addr	td_tiles_07900A
	.addr	td_tiles_079004
	.addr	td_tiles_078FFE
	.addr	td_tiles_078FF8
	.addr	td_tiles_079052
	.addr	td_tiles_07904C
	.addr	td_tiles_079046
	.addr	td_tiles_079040
	.addr	td_tiles_07903A
	.addr	td_tiles_079034
	.addr	td_tiles_07902E
	.addr	td_tiles_079028
	.addr	td_tiles_079022
	.addr	td_tiles_07901C
	.addr	td_tiles_079016
	.addr	td_tiles_079010
	.addr	td_tiles_07900A
	.addr	td_tiles_079004
	.addr	td_tiles_078FFE
	.addr	td_tiles_079058
	.addr	td_tiles_07905E
	.addr	td_tiles_079064
	.addr	td_tiles_07906A
	.addr	td_tiles_079070
	.addr	td_tiles_079076
	.addr	td_tiles_07907C
	.addr	td_tiles_079082
	.addr	td_tiles_079088
	.addr	td_tiles_07908E
	.addr	td_tiles_079094
	.addr	td_tiles_07909A
	.addr	td_tiles_0790A0
	.addr	td_tiles_0790A6
	.addr	td_tiles_0790AC
	.addr	td_tiles_0790B2
	.addr	td_tiles_079058
	.addr	td_tiles_07905E
	.addr	td_tiles_079064
	.addr	td_tiles_07906A
	.addr	td_tiles_079070
	.addr	td_tiles_079076
	.addr	td_tiles_07907C
	.addr	td_tiles_079082
	.addr	td_tiles_079088
	.addr	td_tiles_07908E
	.addr	td_tiles_079094
	.addr	td_tiles_07909A
	.addr	td_tiles_0790A0
	.addr	td_tiles_0790A6
	.addr	td_tiles_0790AC
	.addr	td_tiles_0790B2
	.addr	td_tiles_0790B8
	.addr	td_tiles_0790BE
	.addr	td_tiles_0790C4
	.addr	td_tiles_0790CA
	.addr	td_tiles_0790D0
	.addr	td_tiles_0790D6
	.addr	td_tiles_0790DC
	.addr	td_tiles_0790E2
	.addr	td_tiles_0790E8
	.addr	td_tiles_0790EE
	.addr	td_tiles_0790F4
	.addr	td_tiles_0790FA
	.addr	td_tiles_079100
	.addr	td_tiles_079106
	.addr	td_tiles_07910C
	.addr	td_tiles_079112
	.addr	td_tiles_0790B8
	.addr	td_tiles_0790BE
	.addr	td_tiles_0790C4
	.addr	td_tiles_0790CA
	.addr	td_tiles_0790D0
	.addr	td_tiles_0790D6
	.addr	td_tiles_0790DC
	.addr	td_tiles_0790E2
	.addr	td_tiles_0790E8
	.addr	td_tiles_0790EE
	.addr	td_tiles_0790F4
	.addr	td_tiles_0790FA
	.addr	td_tiles_079100
	.addr	td_tiles_079106
	.addr	td_tiles_07910C
	.addr	td_tiles_079112
	.addr	td_tiles_078D4C
	.addr	td_tiles_078DA6
	.addr	td_tiles_078DA0
	.addr	td_tiles_078D9A
	.addr	td_tiles_078D94
	.addr	td_tiles_078D8E
	.addr	td_tiles_078D88
	.addr	td_tiles_078D82
	.addr	td_tiles_078D7C
	.addr	td_tiles_078D76
	.addr	td_tiles_078D70
	.addr	td_tiles_078D6A
	.addr	td_tiles_078D64
	.addr	td_tiles_078D5E
	.addr	td_tiles_078D58
	.addr	td_tiles_078D52
	.addr	td_tiles_078D4C
	.addr	td_tiles_078DA6
	.addr	td_tiles_078DA0
	.addr	td_tiles_078D9A
	.addr	td_tiles_078D94
	.addr	td_tiles_078D8E
	.addr	td_tiles_078D88
	.addr	td_tiles_078D82
	.addr	td_tiles_078D7C
	.addr	td_tiles_078D76
	.addr	td_tiles_078D70
	.addr	td_tiles_078D6A
	.addr	td_tiles_078D64
	.addr	td_tiles_078D5E
	.addr	td_tiles_078D58
	.addr	td_tiles_078D52
	.addr	td_tiles_078DAC
	.addr	td_tiles_078E06
	.addr	td_tiles_078E00
	.addr	td_tiles_078DFA
	.addr	td_tiles_078DF4
	.addr	td_tiles_078DEE
	.addr	td_tiles_078DE8
	.addr	td_tiles_078DE2
	.addr	td_tiles_078DDC
	.addr	td_tiles_078DD6
	.addr	td_tiles_078DD0
	.addr	td_tiles_078DCA
	.addr	td_tiles_078DC4
	.addr	td_tiles_078DBE
	.addr	td_tiles_078DB8
	.addr	td_tiles_078DB2
	.addr	td_tiles_078DAC
	.addr	td_tiles_078E06
	.addr	td_tiles_078E00
	.addr	td_tiles_078DFA
	.addr	td_tiles_078DF4
	.addr	td_tiles_078DEE
	.addr	td_tiles_078DE8
	.addr	td_tiles_078DE2
	.addr	td_tiles_078DDC
	.addr	td_tiles_078DD6
	.addr	td_tiles_078DD0
	.addr	td_tiles_078DCA
	.addr	td_tiles_078DC4
	.addr	td_tiles_078DBE
	.addr	td_tiles_078DB8
	.addr	td_tiles_078DB2
	.addr	td_tiles_078E0C
	.addr	td_tiles_078E66
	.addr	td_tiles_078E60
	.addr	td_tiles_078E5A
	.addr	td_tiles_078E54
	.addr	td_tiles_078E4E
	.addr	td_tiles_078E48
	.addr	td_tiles_078E42
	.addr	td_tiles_078E3C
	.addr	td_tiles_078E36
	.addr	td_tiles_078E30
	.addr	td_tiles_078E2A
	.addr	td_tiles_078E24
	.addr	td_tiles_078E1E
	.addr	td_tiles_078E18
	.addr	td_tiles_078E12
	.addr	td_tiles_078E0C
	.addr	td_tiles_078E66
	.addr	td_tiles_078E60
	.addr	td_tiles_078E5A
	.addr	td_tiles_078E54
	.addr	td_tiles_078E4E
	.addr	td_tiles_078E48
	.addr	td_tiles_078E42
	.addr	td_tiles_078E3C
	.addr	td_tiles_078E36
	.addr	td_tiles_078E30
	.addr	td_tiles_078E2A
	.addr	td_tiles_078E24
	.addr	td_tiles_078E1E
	.addr	td_tiles_078E18
	.addr	td_tiles_078E12
	.addr	td_tiles_078E6C
	.addr	td_tiles_078EC6
	.addr	td_tiles_078EC0
	.addr	td_tiles_078EBA
	.addr	td_tiles_078EB4
	.addr	td_tiles_078EAE
	.addr	td_tiles_078EA8
	.addr	td_tiles_078EA2
	.addr	td_tiles_078E9C
	.addr	td_tiles_078E96
	.addr	td_tiles_078E90
	.addr	td_tiles_078E8A
	.addr	td_tiles_078E84
	.addr	td_tiles_078E7E
	.addr	td_tiles_078E78
	.addr	td_tiles_078E72
	.addr	td_tiles_078E6C
	.addr	td_tiles_078EC6
	.addr	td_tiles_078EC0
	.addr	td_tiles_078EBA
	.addr	td_tiles_078EB4
	.addr	td_tiles_078EAE
	.addr	td_tiles_078EA8
	.addr	td_tiles_078EA2
	.addr	td_tiles_078E9C
	.addr	td_tiles_078E96
	.addr	td_tiles_078E90
	.addr	td_tiles_078E8A
	.addr	td_tiles_078E84
	.addr	td_tiles_078E7E
	.addr	td_tiles_078E78
	.addr	td_tiles_078E72
	.addr	td_tiles_078ECC
	.addr	td_tiles_078F26
	.addr	td_tiles_078F20
	.addr	td_tiles_078F1A
	.addr	td_tiles_078F14
	.addr	td_tiles_078F0E
	.addr	td_tiles_078F08
	.addr	td_tiles_078F02
	.addr	td_tiles_078EFC
	.addr	td_tiles_078EF6
	.addr	td_tiles_078EF0
	.addr	td_tiles_078EEA
	.addr	td_tiles_078EE4
	.addr	td_tiles_078EDE
	.addr	td_tiles_078ED8
	.addr	td_tiles_078ED2
	.addr	td_tiles_078ECC
	.addr	td_tiles_078F26
	.addr	td_tiles_078F20
	.addr	td_tiles_078F1A
	.addr	td_tiles_078F14
	.addr	td_tiles_078F0E
	.addr	td_tiles_078F08
	.addr	td_tiles_078F02
	.addr	td_tiles_078EFC
	.addr	td_tiles_078EF6
	.addr	td_tiles_078EF0
	.addr	td_tiles_078EEA
	.addr	td_tiles_078EE4
	.addr	td_tiles_078EDE
	.addr	td_tiles_078ED8
	.addr	td_tiles_078ED2
	.addr	td_tiles_078F98
	.addr	td_tiles_078F9E
	.addr	td_tiles_078FA4
	.addr	td_tiles_078FAA
	.addr	td_tiles_078FB0
	.addr	td_tiles_078FB6
	.addr	td_tiles_078FBC
	.addr	td_tiles_078FC2
	.addr	td_tiles_078FC8
	.addr	td_tiles_078FCE
	.addr	td_tiles_078FD4
	.addr	td_tiles_078FDA
	.addr	td_tiles_078FE0
	.addr	td_tiles_078FE6
	.addr	td_tiles_078FEC
	.addr	td_tiles_078FF2
	.addr	td_tiles_078F98
	.addr	td_tiles_078F9E
	.addr	td_tiles_078FA4
	.addr	td_tiles_078FAA
	.addr	td_tiles_078FB0
	.addr	td_tiles_078FB6
	.addr	td_tiles_078FBC
	.addr	td_tiles_078FC2
	.addr	td_tiles_078FC8
	.addr	td_tiles_078FCE
	.addr	td_tiles_078FD4
	.addr	td_tiles_078FDA
	.addr	td_tiles_078FE0
	.addr	td_tiles_078FE6
	.addr	td_tiles_078FEC
	.addr	td_tiles_078FF2
	.addr	td_tiles_078FF8
	.addr	td_tiles_078FFE
	.addr	td_tiles_079004
	.addr	td_tiles_07900A
	.addr	td_tiles_079010
	.addr	td_tiles_079016
	.addr	td_tiles_07901C
	.addr	td_tiles_079022
	.addr	td_tiles_079028
	.addr	td_tiles_07902E
	.addr	td_tiles_079034
	.addr	td_tiles_07903A
	.addr	td_tiles_079040
	.addr	td_tiles_079046
	.addr	td_tiles_07904C
	.addr	td_tiles_079052
	.addr	td_tiles_078FF8
	.addr	td_tiles_078FFE
	.addr	td_tiles_079004
	.addr	td_tiles_07900A
	.addr	td_tiles_079010
	.addr	td_tiles_079016
	.addr	td_tiles_07901C
	.addr	td_tiles_079022
	.addr	td_tiles_079028
	.addr	td_tiles_07902E
	.addr	td_tiles_079034
	.addr	td_tiles_07903A
	.addr	td_tiles_079040
	.addr	td_tiles_079046
	.addr	td_tiles_07904C
	.addr	td_tiles_079052
	.addr	td_tiles_079058
	.addr	td_tiles_0790B2
	.addr	td_tiles_0790AC
	.addr	td_tiles_0790A6
	.addr	td_tiles_0790A0
	.addr	td_tiles_07909A
	.addr	td_tiles_079094
	.addr	td_tiles_07908E
	.addr	td_tiles_079088
	.addr	td_tiles_079082
	.addr	td_tiles_07907C
	.addr	td_tiles_079076
	.addr	td_tiles_079070
	.addr	td_tiles_07906A
	.addr	td_tiles_079064
	.addr	td_tiles_07905E
	.addr	td_tiles_079058
	.addr	td_tiles_0790B2
	.addr	td_tiles_0790AC
	.addr	td_tiles_0790A6
	.addr	td_tiles_0790A0
	.addr	td_tiles_07909A
	.addr	td_tiles_079094
	.addr	td_tiles_07908E
	.addr	td_tiles_079088
	.addr	td_tiles_079082
	.addr	td_tiles_07907C
	.addr	td_tiles_079076
	.addr	td_tiles_079070
	.addr	td_tiles_07906A
	.addr	td_tiles_079064
	.addr	td_tiles_07905E
	.addr	td_tiles_0790B8
	.addr	td_tiles_079112
	.addr	td_tiles_07910C
	.addr	td_tiles_079106
	.addr	td_tiles_079100
	.addr	td_tiles_0790FA
	.addr	td_tiles_0790F4
	.addr	td_tiles_0790EE
	.addr	td_tiles_0790E8
	.addr	td_tiles_0790E2
	.addr	td_tiles_0790DC
	.addr	td_tiles_0790D6
	.addr	td_tiles_0790D0
	.addr	td_tiles_0790CA
	.addr	td_tiles_0790C4
	.addr	td_tiles_0790BE
	.addr	td_tiles_0790B8
	.addr	td_tiles_079112
	.addr	td_tiles_07910C
	.addr	td_tiles_079106
	.addr	td_tiles_079100
	.addr	td_tiles_0790FA
	.addr	td_tiles_0790F4
	.addr	td_tiles_0790EE
	.addr	td_tiles_0790E8
	.addr	td_tiles_0790E2
	.addr	td_tiles_0790DC
	.addr	td_tiles_0790D6
	.addr	td_tiles_0790D0
	.addr	td_tiles_0790CA
	.addr	td_tiles_0790C4
	.addr	td_tiles_0790BE
td_tiles_078D4C:
	td_tiles	$7F0000, $7F00C0
td_tiles_078D52:
	td_tiles	$7F0180, $7F0240
td_tiles_078D58:
	td_tiles	$7F0300, $7F03C0
td_tiles_078D5E:
	td_tiles	$7F0480, $7F0540
td_tiles_078D64:
	td_tiles	$7F0600, $7F06C0
td_tiles_078D6A:
	td_tiles	$7F0780, $7F0840
td_tiles_078D70:
	td_tiles	$7F0900, $7F09C0
td_tiles_078D76:
	td_tiles	$7F0A80, $7F0B40
td_tiles_078D7C:
	td_tiles	$7F0C00, $7F0CC0
td_tiles_078D82:
	td_tiles	$7F0D80, $7F0E40
td_tiles_078D88:
	td_tiles	$7F0F00, $7F0FC0
td_tiles_078D8E:
	td_tiles	$7F1080, $7F1140
td_tiles_078D94:
	td_tiles	$7F1200, $7F12C0
td_tiles_078D9A:
	td_tiles	$7F1380, $7F1440
	; CDL: read by draw_topdown_players, draw_topdown_players_p2
td_tiles_078DA0:
	td_tiles	$7F1500, $7F15C0
td_tiles_078DA6:
	td_tiles	$7F1680, $7F1740
td_tiles_078DAC:
	td_tiles	$7F1800, $7F18C0
td_tiles_078DB2:
	td_tiles	$7F1980, $7F1A40
td_tiles_078DB8:
	td_tiles	$7F1B00, $7F1BC0
td_tiles_078DBE:
	td_tiles	$7F1C80, $7F1D40
td_tiles_078DC4:
	td_tiles	$7F1E00, $7F1EC0
td_tiles_078DCA:
	td_tiles	$7F1F80, $7F2040
td_tiles_078DD0:
	td_tiles	$7F2100, $7F21C0
td_tiles_078DD6:
	td_tiles	$7F2280, $7F2340
td_tiles_078DDC:
	td_tiles	$7F2400, $7F24C0
td_tiles_078DE2:
	td_tiles	$7F2580, $7F2640
td_tiles_078DE8:
	td_tiles	$7F2700, $7F27C0
td_tiles_078DEE:
	td_tiles	$7F2880, $7F2940
td_tiles_078DF4:
	td_tiles	$7F2A00, $7F2AC0
td_tiles_078DFA:
	td_tiles	$7F2B80, $7F2C40
td_tiles_078E00:
	td_tiles	$7F2D00, $7F2DC0
td_tiles_078E06:
	td_tiles	$7F2E80, $7F2F40
td_tiles_078E0C:
	td_tiles	$7F3000, $7F30C0
td_tiles_078E12:
	td_tiles	$7F3180, $7F3240
td_tiles_078E18:
	td_tiles	$7F3300, $7F33C0
td_tiles_078E1E:
	td_tiles	$7F3480, $7F3540
td_tiles_078E24:
	td_tiles	$7F3600, $7F36C0
td_tiles_078E2A:
	td_tiles	$7F3780, $7F3840
td_tiles_078E30:
	td_tiles	$7F3900, $7F39C0
td_tiles_078E36:
	td_tiles	$7F3A80, $7F3B40
td_tiles_078E3C:
	td_tiles	$7F3C00, $7F3CC0
td_tiles_078E42:
	td_tiles	$7F3D80, $7F3E40
td_tiles_078E48:
	td_tiles	$7F3F00, $7F3FC0
td_tiles_078E4E:
	td_tiles	$7F4080, $7F4140
td_tiles_078E54:
	td_tiles	$7F4200, $7F42C0
td_tiles_078E5A:
	td_tiles	$7F4380, $7F4440
td_tiles_078E60:
	td_tiles	$7F4500, $7F45C0
td_tiles_078E66:
	td_tiles	$7F4680, $7F4740
td_tiles_078E6C:
	td_tiles	$7F4800, $7F48C0
td_tiles_078E72:
	td_tiles	$7F4980, $7F4A40
td_tiles_078E78:
	td_tiles	$7F4B00, $7F4BC0
td_tiles_078E7E:
	td_tiles	$7F4C80, $7F4D40
td_tiles_078E84:
	td_tiles	$7F4E00, $7F4EC0
td_tiles_078E8A:
	td_tiles	$7F4F80, $7F5040
td_tiles_078E90:
	td_tiles	$7F5100, $7F51C0
td_tiles_078E96:
	td_tiles	$7F5280, $7F5340
td_tiles_078E9C:
	td_tiles	$7F5400, $7F54C0
td_tiles_078EA2:
	td_tiles	$7F5580, $7F5640
td_tiles_078EA8:
	td_tiles	$7F5700, $7F57C0
td_tiles_078EAE:
	td_tiles	$7F5880, $7F5940
td_tiles_078EB4:
	td_tiles	$7F5A00, $7F5AC0
td_tiles_078EBA:
	td_tiles	$7F5B80, $7F5C40
td_tiles_078EC0:
	td_tiles	$7F5D00, $7F5DC0
td_tiles_078EC6:
	td_tiles	$7F5E80, $7F5F40
td_tiles_078ECC:
	td_tiles	$7F6000, $7F60C0
td_tiles_078ED2:
	td_tiles	$7F6180, $7F6240
td_tiles_078ED8:
	td_tiles	$7F6300, $7F63C0
td_tiles_078EDE:
	td_tiles	$7F6480, $7F6540
td_tiles_078EE4:
	td_tiles	$7F6600, $7F66C0
td_tiles_078EEA:
	td_tiles	$7F6780, $7F6840
td_tiles_078EF0:
	td_tiles	$7F6900, $7F69C0
td_tiles_078EF6:
	td_tiles	$7F6A80, $7F6B40
td_tiles_078EFC:
	td_tiles	$7F6C00, $7F6CC0
td_tiles_078F02:
	td_tiles	$7F6D80, $7F6E40
td_tiles_078F08:
	td_tiles	$7F6F00, $7F6FC0
td_tiles_078F0E:
	td_tiles	$7F7080, $7F7140
td_tiles_078F14:
	td_tiles	$7F7200, $7F72C0
td_tiles_078F1A:
	td_tiles	$7F7380, $7F7440
td_tiles_078F20:
	td_tiles	$7F7500, $7F75C0
td_tiles_078F26:
	td_tiles	$7F7680, $7F7740
td_tiles_078F2C:
	td_tiles	$7F7800, $7F78C0
td_tiles_078F32:
	td_tiles	$7F7980, $7F7A40
td_tiles_078F38:
	td_tiles	$7F7B00, $7F7BC0
td_tiles_078F3E:
	td_tiles	$7F7C80, $7F7D40
td_tiles_078F44:
	td_tiles	$7F7E00, $7F7EC0
td_tiles_078F4A:
	td_tiles	$7F7F80, $7F8040
td_tiles_078F50:
	td_tiles	$7F8100, $7F81C0
td_tiles_078F56:
	td_tiles	$7F8280, $7F8340
td_tiles_078F5C:
	td_tiles	$7F8400, $7F84C0
td_tiles_078F62:
	td_tiles	$7F8580, $7F8640
td_tiles_078F68:
	td_tiles	$7F8700, $7F87C0
td_tiles_078F6E:
	td_tiles	$7F8880, $7F8940
td_tiles_078F74:
	td_tiles	$7F8A00, $7F8AC0
td_tiles_078F7A:
	td_tiles	$7F8B80, $7F8C40
td_tiles_078F80:
	td_tiles	$7F8D00, $7F8DC0
td_tiles_078F86:
	td_tiles	$7F8E80, $7F8F40
td_tiles_078F8C:
	td_tiles	$7F9000, $7F90C0
td_tiles_078F92:
	td_tiles	$7F9180, $7F9240
td_tiles_078F98:
	td_tiles	$7F9300, $7F93C0
td_tiles_078F9E:
	td_tiles	$7F9480, $7F9540
td_tiles_078FA4:
	td_tiles	$7F9600, $7F96C0
td_tiles_078FAA:
	td_tiles	$7F9780, $7F9840
td_tiles_078FB0:
	td_tiles	$7F9900, $7F99C0
td_tiles_078FB6:
	td_tiles	$7F9A80, $7F9B40
td_tiles_078FBC:
	td_tiles	$7F9C00, $7F9CC0
td_tiles_078FC2:
	td_tiles	$7F9D80, $7F9E40
td_tiles_078FC8:
	td_tiles	$7F9F00, $7F9FC0
td_tiles_078FCE:
	td_tiles	$7FA080, $7FA140
td_tiles_078FD4:
	td_tiles	$7FA200, $7FA2C0
td_tiles_078FDA:
	td_tiles	$7FA380, $7FA440
td_tiles_078FE0:
	td_tiles	$7FA500, $7FA5C0
td_tiles_078FE6:
	td_tiles	$7FA680, $7FA740
td_tiles_078FEC:
	td_tiles	$7FA800, $7FA8C0
td_tiles_078FF2:
	td_tiles	$7FA980, $7FAA40
td_tiles_078FF8:
	td_tiles	$7FAB00, $7FABC0
	; CDL: read by draw_topdown_players_p2; partly not accessed
td_tiles_078FFE:
	td_tiles	$7FAC80, $7FAD80
td_tiles_079004:
	td_tiles	$7FAE80, $7FAF80
td_tiles_07900A:
	td_tiles	$7FB080, $7FB180
td_tiles_079010:
	td_tiles	$7FB280, $7FB380
td_tiles_079016:
	td_tiles	$7FB480, $7FB580
td_tiles_07901C:
	td_tiles	$7FB680, $7FB780
td_tiles_079022:
	td_tiles	$7FB880, $7FB980
td_tiles_079028:
	td_tiles	$7FBA80, $7FBB40
td_tiles_07902E:
	td_tiles	$7FBC00, $7FBD00
td_tiles_079034:
	td_tiles	$7FBE00, $7FBF00
td_tiles_07903A:
	td_tiles	$7FC000, $7FC100
td_tiles_079040:
	td_tiles	$7FC200, $7FC300
td_tiles_079046:
	td_tiles	$7FC400, $7FC500
td_tiles_07904C:
	td_tiles	$7FC600, $7FC700
	; CDL: read by draw_topdown_players, draw_topdown_players_p2
td_tiles_079052:
	td_tiles	$7FC800, $7FC900
td_tiles_079058:
	td_tiles	$7FCA00, $7FCB00
td_tiles_07905E:
	td_tiles	$7FCC00, $7FCD00
td_tiles_079064:
	td_tiles	$7FCE00, $7FCF00
td_tiles_07906A:
	td_tiles	$7FD000, $7FD100
td_tiles_079070:
	td_tiles	$7FD200, $7FD300
td_tiles_079076:
	td_tiles	$7FD400, $7FD500
td_tiles_07907C:
	td_tiles	$7FD600, $7FD700
td_tiles_079082:
	td_tiles	$7FD800, $7FD900
td_tiles_079088:
	td_tiles	$7FDA00, $7FDB00
td_tiles_07908E:
	td_tiles	$7FDC00, $7FDD00
td_tiles_079094:
	td_tiles	$7FDE00, $7FDF00
td_tiles_07909A:
	td_tiles	$7FE000, $7FE100
td_tiles_0790A0:
	td_tiles	$7FE200, $7FE300
	; CDL: read by draw_topdown_players_p2
td_tiles_0790A6:
	td_tiles	$7FE400, $7FE500
td_tiles_0790AC:
	td_tiles	$7FE600, $7FE700
td_tiles_0790B2:
	td_tiles	$7FE800, $7FE900
td_tiles_0790B8:
	td_tiles	$7FEA00, $7FEB00
td_tiles_0790BE:
	td_tiles	$7FEC00, $7FED00
td_tiles_0790C4:
	td_tiles	$7FEE00, $7FEF00
td_tiles_0790CA:
	td_tiles	$7FF000, $7FF100
td_tiles_0790D0:
	td_tiles	$7FF200, $7FF300
td_tiles_0790D6:
	td_tiles	$7FF400, $7FF500
td_tiles_0790DC:
	td_tiles	$7FF600, $7FF700
td_tiles_0790E2:
	td_tiles	$7FF800, $7FF900
td_tiles_0790E8:
	td_tiles	$7FFA00, $7FFB00
td_tiles_0790EE:
	td_tiles	$7FFC00, $7FFD00
td_tiles_0790F4:
	td_tiles	$7FFE00, $7FFF00
td_tiles_0790FA:
	td_tiles	td_sprite_tiles_13 + $0000, td_sprite_tiles_13 + $0100
td_tiles_079100:
	td_tiles	td_sprite_tiles_13 + $0200, td_sprite_tiles_13 + $0300
td_tiles_079106:
	td_tiles	td_sprite_tiles_13 + $0400, td_sprite_tiles_13 + $0500
td_tiles_07910C:
	td_tiles	td_sprite_tiles_13 + $0600, td_sprite_tiles_13 + $0700
td_tiles_079112:
	td_tiles	td_sprite_tiles_13 + $0800, td_sprite_tiles_13 + $0900
td_walk_y_int:
	; CDL: read by td_get_walk_vectors
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
td_walk_x_int:
	; LAYOUT: td_walk_y_int (a quarter turn earlier) is read on into this table
	; CDL: read by td_get_walk_vectors
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$02, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00, $01, $00
	.byte	$01, $00, $01, $00, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF, $FE, $FF
	.byte	$FE, $FF, $FE, $FF, $FE, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
td_walk_y_frac:
	; CDL: read by td_get_walk_vectors
	.byte	$00, $00, $28, $00, $9E, $00, $64, $01, $78, $02, $DA, $03, $8B, $05, $8A, $07
	.byte	$D7, $09, $71, $0C, $59, $0F, $8C, $12, $0C, $16, $D8, $19, $EE, $1D, $4F, $22
	.byte	$FA, $26, $ED, $2B, $29, $31, $AC, $36, $75, $3C, $84, $42, $D8, $48, $70, $4F
	.byte	$4A, $56, $66, $5D, $C2, $64, $5E, $6C, $38, $74, $50, $7C, $A3, $84, $30, $8D
	.byte	$F7, $95, $F5, $9E, $2A, $A8, $94, $B1, $31, $BB, $01, $C5, $01, $CF, $30, $D9
	.byte	$8D, $E3, $15, $EE, $C8, $F8, $A3, $03, $A6, $0E, $CD, $19, $18, $25, $85, $30
	.byte	$11, $3C, $BC, $47, $84, $53, $66, $5F, $60, $6B, $72, $77, $99, $83, $D2, $8F
	.byte	$1E, $9C, $78, $A8, $E0, $B4, $54, $C1, $D1, $CD, $56, $DA, $E1, $E6, $70, $F3
td_walk_x_frac:
	; LAYOUT: td_walk_y_frac (a quarter turn earlier) is read on into this table
	; CDL: read by td_get_walk_vectors, draw_topdown_players, draw_topdown_players_p2; partly not accessed
	.byte	$00, $00, $90, $0C, $1F, $19, $AA, $25, $2F, $32, $AC, $3E, $20, $4B, $88, $57
	.byte	$E2, $63, $2E, $70, $67, $7C, $8E, $88, $A0, $94, $9A, $A0, $7C, $AC, $44, $B8
	.byte	$EF, $C3, $7B, $CF, $E8, $DA, $33, $E6, $5A, $F1, $5D, $FC, $38, $07, $EB, $11
	.byte	$73, $1C, $D0, $26, $FF, $30, $FF, $3A, $CF, $44, $6C, $4E, $D6, $57, $0B, $61
	.byte	$09, $6A, $D0, $72, $5D, $7B, $B0, $83, $C8, $8B, $A2, $93, $3E, $9B, $9A, $A2
	.byte	$B6, $A9, $90, $B0, $28, $B7, $7C, $BD, $8B, $C3, $54, $C9, $D7, $CE, $13, $D4
	.byte	$06, $D9, $B1, $DD, $12, $E2, $28, $E6, $F4, $E9, $74, $ED, $A7, $F0, $8F, $F3
	.byte	$29, $F6, $76, $F8, $75, $FA, $26, $FC, $88, $FD, $9C, $FE, $62, $FF, $D8, $FF
	.byte	$00, $00, $D8, $FF, $62, $FF, $9C, $FE, $88, $FD, $26, $FC, $75, $FA, $76, $F8
	.byte	$29, $F6, $8F, $F3, $A7, $F0, $74, $ED, $F4, $E9, $28, $E6, $12, $E2, $B1, $DD
	.byte	$06, $D9, $13, $D4, $D7, $CE, $54, $C9, $8B, $C3, $7C, $BD, $28, $B7, $90, $B0
	.byte	$B6, $A9, $9A, $A2, $3E, $9B, $A2, $93, $C8, $8B, $B0, $83, $5D, $7B, $D0, $72
	.byte	$09, $6A, $0B, $61, $D6, $57, $6C, $4E, $CF, $44, $FF, $3A, $FF, $30, $D0, $26
	.byte	$73, $1C, $EB, $11, $38, $07, $5D, $FC, $5A, $F1, $33, $E6, $E8, $DA, $7B, $CF
	.byte	$EF, $C3, $44, $B8, $7C, $AC, $9A, $A0, $A0, $94, $8E, $88, $67, $7C, $2E, $70
	.byte	$E2, $63, $88, $57, $20, $4B, $AC, $3E, $2F, $32, $AA, $25, $1F, $19, $90, $0C
	.byte	$00, $00, $70, $F3, $E1, $E6, $56, $DA, $D1, $CD, $54, $C1, $E0, $B4, $78, $A8
	.byte	$1E, $9C, $D2, $8F, $99, $83, $72, $77, $60, $6B, $66, $5F, $84, $53, $BC, $47
	.byte	$11, $3C, $85, $30, $18, $25, $CD, $19, $A6, $0E, $A3, $03, $C8, $F8, $15, $EE
	.byte	$8D, $E3, $30, $D9, $01, $CF, $01, $C5, $31, $BB, $94, $B1, $2A, $A8, $F5, $9E
	.byte	$F7, $95, $30, $8D, $A3, $84, $50, $7C, $38, $74, $5E, $6C, $C2, $64, $66, $5D
	.byte	$4A, $56, $70, $4F, $D8, $48, $84, $42, $75, $3C, $AC, $36, $29, $31, $ED, $2B
	.byte	$FA, $26, $4F, $22, $EE, $1D, $D8, $19, $0C, $16, $8C, $12, $59, $0F, $71, $0C
	.byte	$D7, $09, $8A, $07, $8B, $05, $DA, $03, $78, $02, $64, $01, $9E, $00, $28, $00
	.byte	$00, $00, $28, $00, $9E, $00, $64, $01, $78, $02, $DA, $03, $8B, $05, $8A, $07
	.byte	$D7, $09, $71, $0C, $59, $0F, $8C, $12, $0C, $16, $D8, $19, $EE, $1D, $4F, $22
	.byte	$FA, $26, $ED, $2B, $29, $31, $AC, $36, $75, $3C, $84, $42, $D8, $48, $70, $4F
	.byte	$4A, $56, $66, $5D, $C2, $64, $5E, $6C, $38, $74, $50, $7C, $A3, $84, $30, $8D
	.byte	$F7, $95, $F5, $9E, $2A, $A8, $94, $B1, $31, $BB, $01, $C5, $01, $CF, $30, $D9
	.byte	$8D, $E3, $15, $EE, $C8, $F8, $A3, $03, $A6, $0E, $CD, $19, $18, $25, $85, $30
	.byte	$11, $3C, $BC, $47, $84, $53, $66, $5F, $60, $6B, $72, $77, $99, $83, $D2, $8F
	.byte	$1E, $9C, $78, $A8, $E0, $B4, $54, $C1, $D1, $CD, $56, $DA, $E1, $E6, $70, $F3
td_metasprites_player:
	.addr	metasprite_07AAEE
	.addr	metasprite_07AAFB
	.addr	metasprite_07AB08
	.addr	metasprite_07AB15
	.addr	metasprite_07AB22
	.addr	metasprite_07AB2F
	.addr	metasprite_07AB3C
	.addr	metasprite_07AB49
	.addr	metasprite_07AB56
	.addr	metasprite_07AB63
	.addr	metasprite_07AB70
	.addr	metasprite_07AB7D
	.addr	metasprite_07AB8A
	.addr	metasprite_07AB97
	.addr	metasprite_07ABA4
	.addr	metasprite_07ABB1
	.addr	metasprite_07ABBE
	.addr	metasprite_07ABCB
	.addr	metasprite_07ABD8
	.addr	metasprite_07ABE5
	.addr	metasprite_07ABF2
	.addr	metasprite_07ABFF
	.addr	metasprite_07AC0C
	.addr	metasprite_07AC19
	.addr	metasprite_07AC26
	.addr	metasprite_07AC33
	.addr	metasprite_07AC40
	.addr	metasprite_07AC4D
	.addr	metasprite_07AC5A
	.addr	metasprite_07AC67
	.addr	metasprite_07AC74
	.addr	metasprite_07AC81
	.addr	metasprite_07AC8E
	.addr	metasprite_07AC9B
	.addr	metasprite_07ACA8
	.addr	metasprite_07ACB5
	.addr	metasprite_07ACC2
	.addr	metasprite_07ACCF
	.addr	metasprite_07ACDC
	.addr	metasprite_07ACE9
	.addr	metasprite_07ACF6
	.addr	metasprite_07AD03
	.addr	metasprite_07AD10
	.addr	metasprite_07AD1D
	.addr	metasprite_07AD2A
	.addr	metasprite_07AD37
	.addr	metasprite_07AD44
	.addr	metasprite_07AD51
	.addr	metasprite_07AD5E
	.addr	metasprite_07AD6B
	.addr	metasprite_07AD78
	.addr	metasprite_07AD85
	.addr	metasprite_07AD92
	.addr	metasprite_07AD9F
	.addr	metasprite_07ADAC
	.addr	metasprite_07ADB9
	.addr	metasprite_07ADC6
	.addr	metasprite_07ADD3
	.addr	metasprite_07ADE0
	.addr	metasprite_07ADED
	.addr	metasprite_07ADFA
	.addr	metasprite_07AE07
	.addr	metasprite_07AE14
	.addr	metasprite_07AE21
	.addr	metasprite_07AE2E
	.addr	metasprite_07AE3B
	.addr	metasprite_07AE48
	.addr	metasprite_07AE55
	.addr	metasprite_07AE62
	.addr	metasprite_07AE6F
	.addr	metasprite_07AE7C
	.addr	metasprite_07AE89
	.addr	metasprite_07AE96
	.addr	metasprite_07AEA3
	.addr	metasprite_07AEB0
	.addr	metasprite_07AEBD
	.addr	metasprite_07AECA
	.addr	metasprite_07AED7
	.addr	metasprite_07AEE4
	.addr	metasprite_07AEF1
	.addr	metasprite_07AEFE
	.addr	metasprite_07AF0B
	.addr	metasprite_07AF18
	.addr	metasprite_07AF25
	.addr	metasprite_07AF32
	.addr	metasprite_07AF3F
	.addr	metasprite_07AF4C
	.addr	metasprite_07AF59
	.addr	metasprite_07AF66
	.addr	metasprite_07AF73
	.addr	metasprite_07AF80
	.addr	metasprite_07AF8D
	.addr	metasprite_07AF9A
	.addr	metasprite_07AFA7
	.addr	metasprite_07AFB4
	.addr	metasprite_07AFC1
	.addr	metasprite_07AFCE
	.addr	metasprite_07AFDB
	.addr	metasprite_07AFE8
	.addr	metasprite_07AFF5
	.addr	metasprite_07B002
	.addr	metasprite_07B00F
	.addr	metasprite_07B01C
	.addr	metasprite_07B029
	.addr	metasprite_07B036
	.addr	metasprite_07B043
	.addr	metasprite_07B050
	.addr	metasprite_07B05D
	.addr	metasprite_07B06A
	.addr	metasprite_07B077
	.addr	metasprite_07B084
	.addr	metasprite_07B091
	.addr	metasprite_07B09E
	.addr	metasprite_07B0AB
	.addr	metasprite_07B0B8
	.addr	metasprite_07B0C5
	.addr	metasprite_07B0D2
	.addr	metasprite_07B0DF
	.addr	metasprite_07B0EC
	.addr	metasprite_07B0F9
	.addr	metasprite_07B106
	.addr	metasprite_07B113
	.addr	metasprite_07B120
	.addr	metasprite_07B12D
	.addr	metasprite_07B13A
	.addr	metasprite_07B147
	.addr	metasprite_07B154
	.addr	metasprite_07B161
	.addr	metasprite_07B16E
	.addr	metasprite_07B17B
	.addr	metasprite_07B188
	.addr	metasprite_07B195
	.addr	metasprite_07B1A2
	.addr	metasprite_07B1AF
	.addr	metasprite_07B1BC
	.addr	metasprite_07B1C9
	.addr	metasprite_07B1D6
	.addr	metasprite_07B1E3
	.addr	metasprite_07B1F0
	.addr	metasprite_07B1FD
	.addr	metasprite_07B20A
	.addr	metasprite_07B217
	.addr	metasprite_07B224
	.addr	metasprite_07B231
	.addr	metasprite_07B23E
	.addr	metasprite_07B24B
	.addr	metasprite_07B258
	.addr	metasprite_07B265
	.addr	metasprite_07B272
	.addr	metasprite_07B27F
	.addr	metasprite_07B28C
	.addr	metasprite_07B299
	.addr	metasprite_07B2A6
	.addr	metasprite_07B2B3
	.addr	metasprite_07B2C0
	.addr	metasprite_07B2CD
	.addr	metasprite_07B2DA
	.addr	metasprite_07B2E7
	.addr	metasprite_07B2F4
	.addr	metasprite_07B301
	.addr	metasprite_07B30E
	.addr	metasprite_07B31B
	.addr	metasprite_07B328
	.addr	metasprite_07B335
	.addr	metasprite_07B342
	.addr	metasprite_07B34F
	.addr	metasprite_07B35C
	.addr	metasprite_07B369
	.addr	metasprite_07B376
	; CDL: read by draw_topdown_players, draw_topdown_players_p2; partly not accessed
	.addr	metasprite_07B383
	.addr	metasprite_07B390
	.addr	metasprite_07B39D
	.addr	metasprite_07B3AA
	.addr	metasprite_07B3B7
	.addr	metasprite_07B3C4
	.addr	metasprite_07B3D1
	.addr	metasprite_07B3DE
	.addr	metasprite_07B3EB
	.addr	metasprite_07B3F8
	.addr	metasprite_07B405
	.addr	metasprite_07B412
	.addr	metasprite_07B41F
	.addr	metasprite_07B42C
	.addr	metasprite_07B439
	.addr	metasprite_07B446
	.addr	metasprite_07B453
	.addr	metasprite_07B460
	.addr	metasprite_07B46D
	.addr	metasprite_07B47A
	.addr	metasprite_07B487
	.addr	metasprite_07B494
	.addr	metasprite_07B4A1
	.addr	metasprite_07B4AE
	.addr	metasprite_07B4BB
	.addr	metasprite_07B4C8
	.addr	metasprite_07B4D5
	.addr	metasprite_07B4E2
	.addr	metasprite_07B4EF
	.addr	metasprite_07B4FC
	.addr	metasprite_07B509
	.addr	metasprite_07B516
	.addr	metasprite_07B523
	.addr	metasprite_07B530
	.addr	metasprite_07B53D
	.addr	metasprite_07B54A
	.addr	metasprite_07B557
	.addr	metasprite_07B564
	.addr	metasprite_07B571
	.addr	metasprite_07B57E
	.addr	metasprite_07B58B
	.addr	metasprite_07B598
	.addr	metasprite_07B5A5
	.addr	metasprite_07B5B2
	.addr	metasprite_07B5BF
	.addr	metasprite_07B5CC
	.addr	metasprite_07B5D9
	.addr	metasprite_07B5E6
	.addr	metasprite_07B5F3
	.addr	metasprite_07B600
	.addr	metasprite_07B60D
	.addr	metasprite_07B61A
	.addr	metasprite_07B627
	.addr	metasprite_07B634
	.addr	metasprite_07B641
	.addr	metasprite_07B64E
	.addr	metasprite_07B7E1
	.addr	metasprite_07B7D4
	.addr	metasprite_07B7C7
	.addr	metasprite_07B7BA
	.addr	metasprite_07B7AD
	.addr	metasprite_07B7A0
	.addr	metasprite_07B793
	.addr	metasprite_07B786
	.addr	metasprite_07B779
	.addr	metasprite_07B76C
	.addr	metasprite_07B75F
	.addr	metasprite_07B752
	.addr	metasprite_07B745
	.addr	metasprite_07B738
	.addr	metasprite_07B72B
	.addr	metasprite_07B71E
	.addr	metasprite_07B711
	.addr	metasprite_07B704
	.addr	metasprite_07B6F7
	.addr	metasprite_07B6EA
	.addr	metasprite_07B6DD
	.addr	metasprite_07B6D0
	.addr	metasprite_07B6C3
	.addr	metasprite_07B6B6
	.addr	metasprite_07B6A9
	.addr	metasprite_07B69C
	.addr	metasprite_07B68F
	.addr	metasprite_07B682
	.addr	metasprite_07B675
	.addr	metasprite_07B668
	.addr	metasprite_07B65B
	.addr	metasprite_07B7EE
	.addr	metasprite_07B9ED
	.addr	metasprite_07B9DC
	.addr	metasprite_07B9CB
	.addr	metasprite_07B9BA
	.addr	metasprite_07B9A9
	.addr	metasprite_07B998
	.addr	metasprite_07B987
	.addr	metasprite_07B97A
	.addr	metasprite_07B969
	.addr	metasprite_07B958
	.addr	metasprite_07B947
	.addr	metasprite_07B936
	.addr	metasprite_07B925
	.addr	metasprite_07B914
	.addr	metasprite_07B903
	.addr	metasprite_07B8F6
	.addr	metasprite_07B8E5
	.addr	metasprite_07B8D4
	.addr	metasprite_07B8C3
	.addr	metasprite_07B8B2
	.addr	metasprite_07B8A1
	.addr	metasprite_07B890
	.addr	metasprite_07B87F
	.addr	metasprite_07B872
	.addr	metasprite_07B861
	.addr	metasprite_07B850
	.addr	metasprite_07B83F
	.addr	metasprite_07B82E
	.addr	metasprite_07B81D
	.addr	metasprite_07B80C
	.addr	metasprite_07B7FB
	.addr	metasprite_07B9FE
	.addr	metasprite_07BA0F
	.addr	metasprite_07BA20
	.addr	metasprite_07BA31
	.addr	metasprite_07BA42
	.addr	metasprite_07BA53
	.addr	metasprite_07BA64
	.addr	metasprite_07BA75
	.addr	metasprite_07BA86
	.addr	metasprite_07BA97
	.addr	metasprite_07BAA8
	.addr	metasprite_07BAB9
	.addr	metasprite_07BACA
	.addr	metasprite_07BADB
	.addr	metasprite_07BAEC
	.addr	metasprite_07BAFD
	.addr	metasprite_07BB0E
	.addr	metasprite_07BB1F
	.addr	metasprite_07BB30
	.addr	metasprite_07BB41
	.addr	metasprite_07BB52
	.addr	metasprite_07BB63
	.addr	metasprite_07BB74
	.addr	metasprite_07BB85
	.addr	metasprite_07BB96
	.addr	metasprite_07BBA7
	.addr	metasprite_07BBB8
	.addr	metasprite_07BBC9
	.addr	metasprite_07BBDA
	.addr	metasprite_07BBEB
	.addr	metasprite_07BBFC
	.addr	metasprite_07BC0D
	.addr	metasprite_07BC1E
	.addr	metasprite_07BC2F
	.addr	metasprite_07BC40
	.addr	metasprite_07BC51
	.addr	metasprite_07BC62
	.addr	metasprite_07BC73
	.addr	metasprite_07BC84
	.addr	metasprite_07BC95
	.addr	metasprite_07BCA6
	.addr	metasprite_07BCB7
	.addr	metasprite_07BCC8
	.addr	metasprite_07BCD9
	.addr	metasprite_07BCEA
	.addr	metasprite_07BCFB
	.addr	metasprite_07BD0C
	.addr	metasprite_07BD1D
	.addr	metasprite_07BD2E
	.addr	metasprite_07BD3F
	.addr	metasprite_07BD50
	.addr	metasprite_07BD61
	.addr	metasprite_07BD72
	.addr	metasprite_07BD83
	.addr	metasprite_07BD94
	.addr	metasprite_07BDA5
	.addr	metasprite_07BDB6
	.addr	metasprite_07BDC7
	.addr	metasprite_07BDD8
	.addr	metasprite_07BDE9
	.addr	metasprite_07BDFA
	.addr	metasprite_07BE0B
	.addr	metasprite_07BE1C
	.addr	metasprite_07BE2D
	.addr	metasprite_07BE3E
	.addr	metasprite_07BFD1
	.addr	metasprite_07BFC4
	.addr	metasprite_07BFB7
	.addr	metasprite_07BFAA
	.addr	metasprite_07BF9D
	.addr	metasprite_07BF90
	.addr	metasprite_07BF83
	.addr	metasprite_07BF76
	.addr	metasprite_07BF69
	.addr	metasprite_07BF5C
	.addr	metasprite_07BF4F
	.addr	metasprite_07BF42
	.addr	metasprite_07BF35
	.addr	metasprite_07BF28
	.addr	metasprite_07BF1B
	.addr	metasprite_07BF0E
	.addr	metasprite_07BF01
	.addr	metasprite_07BEF4
	.addr	metasprite_07BEE7
	.addr	metasprite_07BEDA
	.addr	metasprite_07BECD
	.addr	metasprite_07BEC0
	.addr	metasprite_07BEB3
	.addr	metasprite_07BEA6
	.addr	metasprite_07BE99
	.addr	metasprite_07BE8C
	.addr	metasprite_07BE7F
	.addr	metasprite_07BE72
	.addr	metasprite_07BE65
	.addr	metasprite_07BE58
	.addr	metasprite_07BE4B
	.addr	metasprite_07BFDE
	.addr	metasprite_07C171
	.addr	metasprite_07C164
	.addr	metasprite_07C157
	.addr	metasprite_07C14A
	.addr	metasprite_07C13D
	.addr	metasprite_07C130
	.addr	metasprite_07C123
	.addr	metasprite_07C116
	.addr	metasprite_07C109
	.addr	metasprite_07C0FC
	.addr	metasprite_07C0EF
	.addr	metasprite_07C0E2
	.addr	metasprite_07C0D5
	.addr	metasprite_07C0C8
	.addr	metasprite_07C0BB
	.addr	metasprite_07C0AE
	.addr	metasprite_07C0A1
	.addr	metasprite_07C094
	.addr	metasprite_07C087
	.addr	metasprite_07C07A
	.addr	metasprite_07C06D
	.addr	metasprite_07C060
	.addr	metasprite_07C053
	.addr	metasprite_07C046
	.addr	metasprite_07C039
	.addr	metasprite_07C02C
	.addr	metasprite_07C01F
	.addr	metasprite_07C012
	.addr	metasprite_07C005
	.addr	metasprite_07BFF8
	.addr	metasprite_07BFEB
	.addr	metasprite_07C17E
	.addr	metasprite_07C311
	.addr	metasprite_07C304
	.addr	metasprite_07C2F7
	.addr	metasprite_07C2EA
	.addr	metasprite_07C2DD
	.addr	metasprite_07C2D0
	.addr	metasprite_07C2C3
	.addr	metasprite_07C2B6
	.addr	metasprite_07C2A9
	.addr	metasprite_07C29C
	.addr	metasprite_07C28F
	.addr	metasprite_07C282
	.addr	metasprite_07C275
	.addr	metasprite_07C268
	.addr	metasprite_07C25B
	.addr	metasprite_07C24E
	.addr	metasprite_07C241
	.addr	metasprite_07C234
	.addr	metasprite_07C227
	.addr	metasprite_07C21A
	.addr	metasprite_07C20D
	.addr	metasprite_07C200
	.addr	metasprite_07C1F3
	.addr	metasprite_07C1E6
	.addr	metasprite_07C1D9
	.addr	metasprite_07C1CC
	.addr	metasprite_07C1BF
	.addr	metasprite_07C1B2
	.addr	metasprite_07C1A5
	.addr	metasprite_07C198
	.addr	metasprite_07C18B
	.addr	metasprite_07C31E
	.addr	metasprite_07C4B1
	.addr	metasprite_07C4A4
	.addr	metasprite_07C497
	.addr	metasprite_07C48A
	.addr	metasprite_07C47D
	.addr	metasprite_07C470
	.addr	metasprite_07C463
	.addr	metasprite_07C456
	.addr	metasprite_07C449
	.addr	metasprite_07C43C
	.addr	metasprite_07C42F
	.addr	metasprite_07C422
	.addr	metasprite_07C415
	.addr	metasprite_07C408
	.addr	metasprite_07C3FB
	.addr	metasprite_07C3EE
	.addr	metasprite_07C3E1
	.addr	metasprite_07C3D4
	.addr	metasprite_07C3C7
	.addr	metasprite_07C3BA
	.addr	metasprite_07C3AD
	.addr	metasprite_07C3A0
	.addr	metasprite_07C393
	.addr	metasprite_07C386
	.addr	metasprite_07C379
	.addr	metasprite_07C36C
	.addr	metasprite_07C35F
	.addr	metasprite_07C352
	.addr	metasprite_07C345
	.addr	metasprite_07C338
	.addr	metasprite_07C32B
	.addr	metasprite_07C4BE
	.addr	metasprite_07C651
	.addr	metasprite_07C644
	.addr	metasprite_07C637
	.addr	metasprite_07C62A
	.addr	metasprite_07C61D
	.addr	metasprite_07C610
	.addr	metasprite_07C603
	.addr	metasprite_07C5F6
	.addr	metasprite_07C5E9
	.addr	metasprite_07C5DC
	.addr	metasprite_07C5CF
	.addr	metasprite_07C5C2
	.addr	metasprite_07C5B5
	.addr	metasprite_07C5A8
	.addr	metasprite_07C59B
	.addr	metasprite_07C58E
	.addr	metasprite_07C581
	.addr	metasprite_07C574
	.addr	metasprite_07C567
	.addr	metasprite_07C55A
	.addr	metasprite_07C54D
	.addr	metasprite_07C540
	.addr	metasprite_07C533
	.addr	metasprite_07C526
	.addr	metasprite_07C519
	.addr	metasprite_07C50C
	.addr	metasprite_07C4FF
	.addr	metasprite_07C4F2
	.addr	metasprite_07C4E5
	.addr	metasprite_07C4D8
	.addr	metasprite_07C4CB
	.addr	metasprite_07C65E
	.addr	metasprite_07C66B
	.addr	metasprite_07C678
	.addr	metasprite_07C685
	.addr	metasprite_07C692
	.addr	metasprite_07C69F
	.addr	metasprite_07C6AC
	.addr	metasprite_07C6B9
	.addr	metasprite_07C6C6
	.addr	metasprite_07C6D3
	.addr	metasprite_07C6E0
	.addr	metasprite_07C6ED
	.addr	metasprite_07C6FA
	.addr	metasprite_07C707
	.addr	metasprite_07C714
	.addr	metasprite_07C721
	.addr	metasprite_07C72E
	.addr	metasprite_07C73B
	.addr	metasprite_07C748
	.addr	metasprite_07C755
	.addr	metasprite_07C762
	.addr	metasprite_07C76F
	.addr	metasprite_07C77C
	.addr	metasprite_07C789
	.addr	metasprite_07C796
	.addr	metasprite_07C7A3
	.addr	metasprite_07C7B0
	.addr	metasprite_07C7BD
	.addr	metasprite_07C7CA
	.addr	metasprite_07C7D7
	.addr	metasprite_07C7E4
	.addr	metasprite_07C7F1
	.addr	metasprite_07C7FE
	.addr	metasprite_07C80B
	.addr	metasprite_07C81C
	.addr	metasprite_07C82D
	.addr	metasprite_07C83E
	.addr	metasprite_07C84F
	.addr	metasprite_07C860
	.addr	metasprite_07C871
	.addr	metasprite_07C882
	.addr	metasprite_07C88F
	.addr	metasprite_07C8A0
	.addr	metasprite_07C8B1
	.addr	metasprite_07C8C2
	.addr	metasprite_07C8D3
	.addr	metasprite_07C8E4
	.addr	metasprite_07C8F5
	.addr	metasprite_07C906
	.addr	metasprite_07C913
	.addr	metasprite_07C924
	.addr	metasprite_07C935
	.addr	metasprite_07C946
	.addr	metasprite_07C957
	.addr	metasprite_07C968
	.addr	metasprite_07C979
	.addr	metasprite_07C98A
	.addr	metasprite_07C997
	.addr	metasprite_07C9A8
	.addr	metasprite_07C9B9
	.addr	metasprite_07C9CA
	.addr	metasprite_07C9DB
	.addr	metasprite_07C9EC
	.addr	metasprite_07C9FD
	.addr	metasprite_07CA0E
	.addr	metasprite_07CC1D
	.addr	metasprite_07CC0C
	.addr	metasprite_07CBFB
	.addr	metasprite_07CBEA
	.addr	metasprite_07CBD9
	.addr	metasprite_07CBC8
	.addr	metasprite_07CBB7
	.addr	metasprite_07CBA6
	.addr	metasprite_07CB95
	.addr	metasprite_07CB84
	.addr	metasprite_07CB73
	.addr	metasprite_07CB62
	.addr	metasprite_07CB51
	.addr	metasprite_07CB40
	.addr	metasprite_07CB2F
	.addr	metasprite_07CB1E
	.addr	metasprite_07CB0D
	.addr	metasprite_07CAFC
	.addr	metasprite_07CAEB
	.addr	metasprite_07CADA
	.addr	metasprite_07CAC9
	.addr	metasprite_07CAB8
	.addr	metasprite_07CAA7
	.addr	metasprite_07CA96
	.addr	metasprite_07CA85
	.addr	metasprite_07CA74
	.addr	metasprite_07CA63
	.addr	metasprite_07CA52
	.addr	metasprite_07CA41
	.addr	metasprite_07CA30
	.addr	metasprite_07CA1F
	.addr	metasprite_07CC2E
	.addr	metasprite_07CE3D
	.addr	metasprite_07CE2C
	.addr	metasprite_07CE1B
	.addr	metasprite_07CE0A
	.addr	metasprite_07CDF9
	.addr	metasprite_07CDE8
	.addr	metasprite_07CDD7
	.addr	metasprite_07CDC6
	.addr	metasprite_07CDB5
	.addr	metasprite_07CDA4
	.addr	metasprite_07CD93
	.addr	metasprite_07CD82
	.addr	metasprite_07CD71
	.addr	metasprite_07CD60
	.addr	metasprite_07CD4F
	.addr	metasprite_07CD3E
	.addr	metasprite_07CD2D
	.addr	metasprite_07CD1C
	.addr	metasprite_07CD0B
	.addr	metasprite_07CCFA
	.addr	metasprite_07CCE9
	.addr	metasprite_07CCD8
	.addr	metasprite_07CCC7
	.addr	metasprite_07CCB6
	.addr	metasprite_07CCA5
	.addr	metasprite_07CC94
	.addr	metasprite_07CC83
	.addr	metasprite_07CC72
	.addr	metasprite_07CC61
	.addr	metasprite_07CC50
	.addr	metasprite_07CC3F
	; CDL: read by draw_stage2_boss_cannon
td_metasprites_stage2_boss_cannon:
	.addr	metasprite_07CEDE
	.addr	metasprite_07CEE7
	.addr	metasprite_07CEF0
	.addr	metasprite_07CEF9
	.addr	metasprite_07CF02
	.addr	metasprite_07CF0B
	.addr	metasprite_07CF14
	.addr	metasprite_07CF1D
	.addr	metasprite_07CF26
	.addr	metasprite_07CF2F
	.addr	metasprite_07CF38
	.addr	metasprite_07CF41
	.addr	metasprite_07CF4A
	.addr	metasprite_07CF53
	.addr	metasprite_07CF5C
	.addr	metasprite_07CF65
	.addr	metasprite_07CE4E
	.addr	metasprite_07CE57
	.addr	metasprite_07CE60
	.addr	metasprite_07CE69
	.addr	metasprite_07CE72
	.addr	metasprite_07CE7B
	.addr	metasprite_07CE84
	.addr	metasprite_07CE8D
	.addr	metasprite_07CE96
	.addr	metasprite_07CE9F
	.addr	metasprite_07CEA8
	.addr	metasprite_07CEB1
	.addr	metasprite_07CEBA
	.addr	metasprite_07CEC3
	.addr	metasprite_07CECC
	.addr	metasprite_07CED5
td_tile_list_stage2_boss_cannon:
	.addr	td_tiles_079B98
	.addr	td_tiles_079B9E
	.addr	td_tiles_079BA4
	.addr	td_tiles_079BAA
	.addr	td_tiles_079BB0
	.addr	td_tiles_079BB6
	.addr	td_tiles_079BBC
	.addr	td_tiles_079BC2
	.addr	td_tiles_079BC8
	.addr	td_tiles_079BC2
	.addr	td_tiles_079BBC
	.addr	td_tiles_079BB6
	.addr	td_tiles_079BB0
	.addr	td_tiles_079BAA
	.addr	td_tiles_079BA4
	.addr	td_tiles_079B9E
	.addr	td_tiles_079B98
	.addr	td_tiles_079B9E
	.addr	td_tiles_079BA4
	.addr	td_tiles_079BAA
	.addr	td_tiles_079BB0
	.addr	td_tiles_079BB6
	.addr	td_tiles_079BBC
	.addr	td_tiles_079BC2
	.addr	td_tiles_079BC8
	.addr	td_tiles_079BC2
	.addr	td_tiles_079BBC
	.addr	td_tiles_079BB6
	.addr	td_tiles_079BB0
	.addr	td_tiles_079BAA
	.addr	td_tiles_079BA4
	.addr	td_tiles_079B9E
td_tiles_079B98:
	td_tiles	$7EA000, $7EA080
td_tiles_079B9E:
	td_tiles	$7EA100, $7EA180
td_tiles_079BA4:
	td_tiles	$7EA200, $7EA280
td_tiles_079BAA:
	td_tiles	$7EA300, $7EA380
td_tiles_079BB0:
	td_tiles	$7EA400, $7EA480
td_tiles_079BB6:
	td_tiles	$7EA500, $7EA580
td_tiles_079BBC:
	td_tiles	$7EA600, $7EA680
td_tiles_079BC2:
	td_tiles	$7EA700, $7EA780
td_tiles_079BC8:
	td_tiles	$7EA800, $7EA880
stage2_arena_rubble_metasprites:
	; CDL: read by draw_stage2_boss_arena
	.addr	metasprite_07CF6E
	.addr	metasprite_07CF77
	.addr	metasprite_07CF80
	.addr	metasprite_07CF89
	.addr	metasprite_07CF92
	.addr	metasprite_07CF9B
	.addr	metasprite_07CFA4
	.addr	metasprite_07CFAD
	.addr	metasprite_07CFB6
	.addr	metasprite_07CFBF
	.addr	metasprite_07CFC8
	.addr	metasprite_07CFD1
	.addr	metasprite_07CFDA
	.addr	metasprite_07CFE3
	.addr	metasprite_07CFEC
	.addr	metasprite_07CFF5
	.addr	metasprite_07CF6E
	.addr	metasprite_07CF77
	.addr	metasprite_07CF80
	.addr	metasprite_07CF89
	.addr	metasprite_07CF92
	.addr	metasprite_07CF9B
	.addr	metasprite_07CFA4
	.addr	metasprite_07CFAD
	.addr	metasprite_07CFB6
	.addr	metasprite_07CFBF
	.addr	metasprite_07CFC8
	.addr	metasprite_07CFD1
	.addr	metasprite_07CFDA
	.addr	metasprite_07CFE3
	.addr	metasprite_07CFEC
	.addr	metasprite_07CFF5
stage2_arena_rubble_tile_list:
	; CDL: read by draw_stage2_boss_arena
	.addr	td_tiles_079C4E
	.addr	td_tiles_079C54
	.addr	td_tiles_079C5A
	.addr	td_tiles_079C60
	.addr	td_tiles_079C66
	.addr	td_tiles_079C6C
	.addr	td_tiles_079C72
	.addr	td_tiles_079C78
	.addr	td_tiles_079C7E
	.addr	td_tiles_079C78
	.addr	td_tiles_079C72
	.addr	td_tiles_079C6C
	.addr	td_tiles_079C66
	.addr	td_tiles_079C60
	.addr	td_tiles_079C5A
	.addr	td_tiles_079C54
	.addr	td_tiles_079C4E
	.addr	td_tiles_079C54
	.addr	td_tiles_079C5A
	.addr	td_tiles_079C60
	.addr	td_tiles_079C66
	.addr	td_tiles_079C6C
	.addr	td_tiles_079C72
	.addr	td_tiles_079C78
	.addr	td_tiles_079C7E
	.addr	td_tiles_079C78
	.addr	td_tiles_079C72
	.addr	td_tiles_079C6C
	.addr	td_tiles_079C66
	.addr	td_tiles_079C60
	.addr	td_tiles_079C5A
	.addr	td_tiles_079C54
td_tiles_079C4E:
	td_tiles	$7EA900, $7EA940
td_tiles_079C54:
	td_tiles	$7EA980, $7EA9C0
td_tiles_079C5A:
	td_tiles	$7EAA00, $7EAA40
td_tiles_079C60:
	td_tiles	$7EAA80, $7EAAC0
td_tiles_079C66:
	td_tiles	$7EAB00, $7EAB40
td_tiles_079C6C:
	td_tiles	$7EAB80, $7EABC0
td_tiles_079C72:
	td_tiles	$7EAC00, $7EAC40
td_tiles_079C78:
	td_tiles	$7EAC80, $7EACC0
td_tiles_079C7E:
	td_tiles	$7EAD00, $7EAD40
stage2_arena_debris_tile_list:
	; CDL: read by draw_stage2_boss_arena
	.addr	td_tiles_079CC4
	.addr	td_tiles_079CCA
	.addr	td_tiles_079CD0
	.addr	td_tiles_079CD6
	.addr	td_tiles_079CDC
	.addr	td_tiles_079CE2
	.addr	td_tiles_079CE8
	.addr	td_tiles_079CEE
	.addr	td_tiles_079CF4
	.addr	td_tiles_079CFA
	.addr	td_tiles_079D00
	.addr	td_tiles_079D06
	.addr	td_tiles_079D0C
	.addr	td_tiles_079D12
	.addr	td_tiles_079D18
	.addr	td_tiles_079D1E
	.addr	td_tiles_079CC4
	.addr	td_tiles_079CCA
	.addr	td_tiles_079CD0
	.addr	td_tiles_079CD6
	.addr	td_tiles_079CDC
	.addr	td_tiles_079CE2
	.addr	td_tiles_079CE8
	.addr	td_tiles_079CEE
	.addr	td_tiles_079CF4
	.addr	td_tiles_079CFA
	.addr	td_tiles_079D00
	.addr	td_tiles_079D06
	.addr	td_tiles_079D0C
	.addr	td_tiles_079D12
	.addr	td_tiles_079D18
	.addr	td_tiles_079D1E
td_tiles_079CC4:
	td_tiles	$7EAD80, $7EADC0
td_tiles_079CCA:
	td_tiles	$7EAE00, $7EAE40
td_tiles_079CD0:
	td_tiles	$7EAE80, $7EAEC0
td_tiles_079CD6:
	td_tiles	$7EAF00, $7EAF40
td_tiles_079CDC:
	td_tiles	$7EAF80, $7EAFC0
td_tiles_079CE2:
	td_tiles	$7EB000, $7EB040
td_tiles_079CE8:
	td_tiles	$7EB080, $7EB0C0
td_tiles_079CEE:
	td_tiles	$7EB100, $7EB140
td_tiles_079CF4:
	td_tiles	$7EB180, $7EB1C0
td_tiles_079CFA:
	td_tiles	$7EB200, $7EB240
td_tiles_079D00:
	td_tiles	$7EB280, $7EB2C0
td_tiles_079D06:
	td_tiles	$7EB300, $7EB340
td_tiles_079D0C:
	td_tiles	$7EB380, $7EB3C0
td_tiles_079D12:
	td_tiles	$7EB400, $7EB440
td_tiles_079D18:
	td_tiles	$7EB480, $7EB4C0
td_tiles_079D1E:
	td_tiles	$7EB500, $7EB540
	; CDL: read by draw_enemies, draw_enemies_p2
td_metasprites_crawler:
	.addr	metasprite_07D18E
	.addr	metasprite_07D19F
	.addr	metasprite_07D1B0
	.addr	metasprite_07D1C1
	.addr	metasprite_07D1D2
	.addr	metasprite_07D1E3
	.addr	metasprite_07D1F4
	.addr	metasprite_07D205
	.addr	metasprite_07D216
	.addr	metasprite_07D227
	.addr	metasprite_07D238
	.addr	metasprite_07D249
	.addr	metasprite_07D25A
	.addr	metasprite_07D26B
	.addr	metasprite_07D27C
	.addr	metasprite_07D28D
	.addr	metasprite_07D29E
	.addr	metasprite_07D2AF
	.addr	metasprite_07D2C0
	.addr	metasprite_07D2D1
	.addr	metasprite_07D2E2
	.addr	metasprite_07D2F3
	.addr	metasprite_07D304
	.addr	metasprite_07D315
	.addr	metasprite_07D326
	.addr	metasprite_07D337
	.addr	metasprite_07D348
	.addr	metasprite_07D359
	.addr	metasprite_07D36A
	.addr	metasprite_07D37B
	.addr	metasprite_07D38C
	.addr	metasprite_07D39D
	.addr	metasprite_07D3AE
	.addr	metasprite_07D3BF
	.addr	metasprite_07D3D0
	.addr	metasprite_07D3E1
	.addr	metasprite_07D3F2
	.addr	metasprite_07D403
	.addr	metasprite_07D414
	.addr	metasprite_07D425
	.addr	metasprite_07D436
	.addr	metasprite_07D447
	.addr	metasprite_07D458
	.addr	metasprite_07D469
	.addr	metasprite_07D47A
	.addr	metasprite_07D48B
	.addr	metasprite_07D49C
	.addr	metasprite_07D4AD
	.addr	metasprite_07D4BE
	.addr	metasprite_07D4CF
	.addr	metasprite_07D4E0
	.addr	metasprite_07D4F1
	.addr	metasprite_07D502
	.addr	metasprite_07D513
	.addr	metasprite_07D524
	.addr	metasprite_07D535
	.addr	metasprite_07D546
	.addr	metasprite_07D557
	.addr	metasprite_07D568
	.addr	metasprite_07D579
	.addr	metasprite_07D58A
	.addr	metasprite_07D59B
	.addr	metasprite_07D5AC
	.addr	metasprite_07D5BD
	.addr	metasprite_07D5CE
	.addr	metasprite_07D5DF
	.addr	metasprite_07D5F0
	.addr	metasprite_07D601
	.addr	metasprite_07D612
	.addr	metasprite_07D623
	.addr	metasprite_07D634
	.addr	metasprite_07D645
	.addr	metasprite_07D656
	.addr	metasprite_07D667
	.addr	metasprite_07D678
	.addr	metasprite_07D689
	.addr	metasprite_07D69A
	.addr	metasprite_07D6AB
	.addr	metasprite_07D6BC
	.addr	metasprite_07D6CD
	.addr	metasprite_07D6DE
	.addr	metasprite_07D6EF
	.addr	metasprite_07D700
	.addr	metasprite_07D711
	.addr	metasprite_07D722
	.addr	metasprite_07D733
	.addr	metasprite_07D744
	.addr	metasprite_07D755
	.addr	metasprite_07D766
	.addr	metasprite_07D777
	.addr	metasprite_07D788
	.addr	metasprite_07D799
	.addr	metasprite_07D7AA
	.addr	metasprite_07D7BB
	.addr	metasprite_07D7CC
	.addr	metasprite_07D7DD
	; CDL: not accessed
	.addr	metasprite_07D7EE
	.addr	metasprite_07D7FF
	.addr	metasprite_07D810
	.addr	metasprite_07D821
	.addr	metasprite_07D832
	.addr	metasprite_07D843
	.addr	metasprite_07D854
	.addr	metasprite_07D865
	.addr	metasprite_07D876
	.addr	metasprite_07D887
	.addr	metasprite_07D898
	.addr	metasprite_07D8A9
	.addr	metasprite_07D8BA
	.addr	metasprite_07D8CB
	.addr	metasprite_07D8DC
	.addr	metasprite_07D8ED
	.addr	metasprite_07D8FE
	.addr	metasprite_07D90F
	.addr	metasprite_07D920
	.addr	metasprite_07D931
	.addr	metasprite_07D942
	.addr	metasprite_07D953
	.addr	metasprite_07D964
	.addr	metasprite_07D975
	.addr	metasprite_07D986
	.addr	metasprite_07D997
	.addr	metasprite_07D9A8
	.addr	metasprite_07D9B9
	.addr	metasprite_07D9CA
	.addr	metasprite_07D9DB
	.addr	metasprite_07D9EC
	.addr	metasprite_07D9FD
	; CDL: read by draw_enemies, draw_enemies_p2
td_tile_list_crawler:
	.addr	td_tiles_079F24
	.addr	td_tiles_079F2A
	.addr	td_tiles_079F30
	.addr	td_tiles_079F36
	.addr	td_tiles_079F3C
	.addr	td_tiles_079F42
	.addr	td_tiles_079F48
	.addr	td_tiles_079F4E
	.addr	td_tiles_079F54
	.addr	td_tiles_079F7E
	.addr	td_tiles_079F78
	.addr	td_tiles_079F72
	.addr	td_tiles_079F6C
	.addr	td_tiles_079F66
	.addr	td_tiles_079F60
	.addr	td_tiles_079F5A
	.addr	td_tiles_079F24
	.addr	td_tiles_079F2A
	.addr	td_tiles_079F30
	.addr	td_tiles_079F36
	.addr	td_tiles_079F3C
	.addr	td_tiles_079F42
	.addr	td_tiles_079F48
	.addr	td_tiles_079F4E
	.addr	td_tiles_079F54
	.addr	td_tiles_079F7E
	.addr	td_tiles_079F78
	.addr	td_tiles_079F72
	.addr	td_tiles_079F6C
	.addr	td_tiles_079F66
	.addr	td_tiles_079F60
	.addr	td_tiles_079F5A
	.addr	td_tiles_079F84
	.addr	td_tiles_079F8A
	.addr	td_tiles_079F90
	.addr	td_tiles_079F96
	.addr	td_tiles_079F9C
	.addr	td_tiles_079FA2
	.addr	td_tiles_079FA8
	.addr	td_tiles_079FAE
	.addr	td_tiles_079FB4
	.addr	td_tiles_079FDE
	.addr	td_tiles_079FD8
	.addr	td_tiles_079FD2
	.addr	td_tiles_079FCC
	.addr	td_tiles_079FC6
	.addr	td_tiles_079FC0
	.addr	td_tiles_079FBA
	.addr	td_tiles_079F84
	.addr	td_tiles_079F8A
	.addr	td_tiles_079F90
	.addr	td_tiles_079F96
	.addr	td_tiles_079F9C
	.addr	td_tiles_079FA2
	.addr	td_tiles_079FA8
	.addr	td_tiles_079FAE
	.addr	td_tiles_079FB4
	.addr	td_tiles_079FDE
	.addr	td_tiles_079FD8
	.addr	td_tiles_079FD2
	.addr	td_tiles_079FCC
	.addr	td_tiles_079FC6
	.addr	td_tiles_079FC0
	.addr	td_tiles_079FBA
	.addr	td_tiles_079F24
	.addr	td_tiles_079F5A
	.addr	td_tiles_079F60
	.addr	td_tiles_079F66
	.addr	td_tiles_079F6C
	.addr	td_tiles_079F72
	.addr	td_tiles_079F78
	.addr	td_tiles_079F7E
	.addr	td_tiles_079F54
	.addr	td_tiles_079F4E
	.addr	td_tiles_079F48
	.addr	td_tiles_079F42
	.addr	td_tiles_079F3C
	.addr	td_tiles_079F36
	.addr	td_tiles_079F30
	.addr	td_tiles_079F2A
	.addr	td_tiles_079F24
	.addr	td_tiles_079F5A
	.addr	td_tiles_079F60
	.addr	td_tiles_079F66
	.addr	td_tiles_079F6C
	.addr	td_tiles_079F72
	.addr	td_tiles_079F78
	.addr	td_tiles_079F7E
	.addr	td_tiles_079F54
	.addr	td_tiles_079F4E
	.addr	td_tiles_079F48
	.addr	td_tiles_079F42
	.addr	td_tiles_079F3C
	.addr	td_tiles_079F36
	.addr	td_tiles_079F30
	.addr	td_tiles_079F2A
	; CDL: read by draw_enemies, draw_enemies_p2; partly not accessed
	.addr	td_tiles_079F84
	.addr	td_tiles_079FBA
	.addr	td_tiles_079FC0
	.addr	td_tiles_079FC6
	.addr	td_tiles_079FCC
	.addr	td_tiles_079FD2
	.addr	td_tiles_079FD8
	.addr	td_tiles_079FDE
	.addr	td_tiles_079FB4
	.addr	td_tiles_079FAE
	.addr	td_tiles_079FA8
	.addr	td_tiles_079FA2
	.addr	td_tiles_079F9C
	.addr	td_tiles_079F96
	.addr	td_tiles_079F90
	.addr	td_tiles_079F8A
	.addr	td_tiles_079F84
	.addr	td_tiles_079FBA
	.addr	td_tiles_079FC0
	.addr	td_tiles_079FC6
	.addr	td_tiles_079FCC
	.addr	td_tiles_079FD2
	.addr	td_tiles_079FD8
	.addr	td_tiles_079FDE
	.addr	td_tiles_079FB4
	.addr	td_tiles_079FAE
	.addr	td_tiles_079FA8
	.addr	td_tiles_079FA2
	.addr	td_tiles_079F9C
	.addr	td_tiles_079F96
	.addr	td_tiles_079F90
	.addr	td_tiles_079F8A
td_tiles_079F24:
	td_tiles	$7EA000, $7EA100
td_tiles_079F2A:
	td_tiles	$7EA200, $7EA300
td_tiles_079F30:
	td_tiles	$7EA400, $7EA500
td_tiles_079F36:
	td_tiles	$7EA600, $7EA700
td_tiles_079F3C:
	td_tiles	$7EA800, $7EA900
td_tiles_079F42:
	td_tiles	$7EAA00, $7EAB00
td_tiles_079F48:
	td_tiles	$7EAC00, $7EAD00
td_tiles_079F4E:
	td_tiles	$7EAE00, $7EAF00
td_tiles_079F54:
	td_tiles	$7EB000, $7EB100
td_tiles_079F5A:
	td_tiles	$7EB200, $7EB300
td_tiles_079F60:
	td_tiles	$7EB400, $7EB500
td_tiles_079F66:
	td_tiles	$7EB600, $7EB700
td_tiles_079F6C:
	td_tiles	$7EB800, $7EB900
td_tiles_079F72:
	td_tiles	$7EBA00, $7EBB00
td_tiles_079F78:
	td_tiles	$7EBC00, $7EBD00
td_tiles_079F7E:
	td_tiles	$7EBE00, $7EBF00
td_tiles_079F84:
	td_tiles	$7EC000, $7EC100
td_tiles_079F8A:
	td_tiles	$7EC200, $7EC300
td_tiles_079F90:
	td_tiles	$7EC400, $7EC500
td_tiles_079F96:
	td_tiles	$7EC600, $7EC700
td_tiles_079F9C:
	td_tiles	$7EC800, $7EC900
td_tiles_079FA2:
	td_tiles	$7ECA00, $7ECB00
td_tiles_079FA8:
	td_tiles	$7ECC00, $7ECD00
td_tiles_079FAE:
	td_tiles	$7ECE00, $7ECF00
td_tiles_079FB4:
	td_tiles	$7ED000, $7ED100
td_tiles_079FBA:
	td_tiles	$7ED200, $7ED300
td_tiles_079FC0:
	td_tiles	$7ED400, $7ED500
td_tiles_079FC6:
	td_tiles	$7ED600, $7ED700
td_tiles_079FCC:
	td_tiles	$7ED800, $7ED900
td_tiles_079FD2:
	td_tiles	$7EDA00, $7EDB00
td_tiles_079FD8:
	td_tiles	$7EDC00, $7EDD00
td_tiles_079FDE:
	td_tiles	$7EDE00, $7EDF00
td_metasprites_runner_gunner:
	.addr	metasprite_07E34E
	.addr	metasprite_07E35B
	.addr	metasprite_07E368
	.addr	metasprite_07E375
	.addr	metasprite_07E382
	.addr	metasprite_07E38F
	.addr	metasprite_07E39C
	.addr	metasprite_07E3A9
	.addr	metasprite_07E3B6
	.addr	metasprite_07E3C3
	.addr	metasprite_07E3D0
	.addr	metasprite_07E3DD
	.addr	metasprite_07E3EA
	.addr	metasprite_07E3F7
	.addr	metasprite_07E404
	.addr	metasprite_07E411
	.addr	metasprite_07E41E
	.addr	metasprite_07E42B
	.addr	metasprite_07E438
	.addr	metasprite_07E445
	.addr	metasprite_07E452
	.addr	metasprite_07E45F
	.addr	metasprite_07E46C
	.addr	metasprite_07E479
	.addr	metasprite_07E486
	.addr	metasprite_07E493
	.addr	metasprite_07E4A0
	.addr	metasprite_07E4AD
	.addr	metasprite_07E4BA
	.addr	metasprite_07E4C7
	.addr	metasprite_07E4D4
	.addr	metasprite_07E4E1
	.addr	metasprite_07E4EE
	.addr	metasprite_07E4FB
	.addr	metasprite_07E508
	.addr	metasprite_07E515
	.addr	metasprite_07E522
	.addr	metasprite_07E52F
	.addr	metasprite_07E53C
	.addr	metasprite_07E549
	.addr	metasprite_07E556
	.addr	metasprite_07E563
	.addr	metasprite_07E570
	.addr	metasprite_07E57D
	.addr	metasprite_07E58A
	.addr	metasprite_07E597
	.addr	metasprite_07E5A4
	.addr	metasprite_07E5B1
	.addr	metasprite_07E5BE
	.addr	metasprite_07E5CB
	.addr	metasprite_07E5D8
	.addr	metasprite_07E5E5
	.addr	metasprite_07E5F2
	.addr	metasprite_07E5FF
	.addr	metasprite_07E60C
	.addr	metasprite_07E619
	.addr	metasprite_07E626
	.addr	metasprite_07E633
	.addr	metasprite_07E640
	.addr	metasprite_07E64D
	.addr	metasprite_07E65A
	.addr	metasprite_07E667
	.addr	metasprite_07E674
	.addr	metasprite_07E681
	.addr	metasprite_07E68E
	.addr	metasprite_07E69F
	.addr	metasprite_07E6B0
	.addr	metasprite_07E6C1
	.addr	metasprite_07E6CE
	.addr	metasprite_07E6DB
	.addr	metasprite_07E6EC
	.addr	metasprite_07E6FD
	.addr	metasprite_07E70E
	.addr	metasprite_07E71F
	.addr	metasprite_07E730
	.addr	metasprite_07E741
	.addr	metasprite_07E74E
	.addr	metasprite_07E75B
	.addr	metasprite_07E76C
	.addr	metasprite_07E77D
	.addr	metasprite_07E78E
	.addr	metasprite_07E79F
	.addr	metasprite_07E7B0
	.addr	metasprite_07E7C1
	.addr	metasprite_07E7CE
	.addr	metasprite_07E7DB
	.addr	metasprite_07E7EC
	.addr	metasprite_07E7FD
	.addr	metasprite_07E80E
	.addr	metasprite_07E81F
	.addr	metasprite_07E830
	.addr	metasprite_07E841
	.addr	metasprite_07E84E
	.addr	metasprite_07E85B
	.addr	metasprite_07E86C
	.addr	metasprite_07E87D
td_tile_list_runner_gunner:
	.addr	td_tiles_07A164
	.addr	td_tiles_07A16A
	.addr	td_tiles_07A170
	.addr	td_tiles_07A176
	.addr	td_tiles_07A17C
	.addr	td_tiles_07A182
	.addr	td_tiles_07A188
	.addr	td_tiles_07A18E
	.addr	td_tiles_07A194
	.addr	td_tiles_07A19A
	.addr	td_tiles_07A1A0
	.addr	td_tiles_07A1A6
	.addr	td_tiles_07A1AC
	.addr	td_tiles_07A1B2
	.addr	td_tiles_07A1B8
	.addr	td_tiles_07A1BE
	.addr	td_tiles_07A164
	.addr	td_tiles_07A16A
	.addr	td_tiles_07A170
	.addr	td_tiles_07A176
	.addr	td_tiles_07A17C
	.addr	td_tiles_07A182
	.addr	td_tiles_07A188
	.addr	td_tiles_07A18E
	.addr	td_tiles_07A194
	.addr	td_tiles_07A19A
	.addr	td_tiles_07A1A0
	.addr	td_tiles_07A1A6
	.addr	td_tiles_07A1AC
	.addr	td_tiles_07A1B2
	.addr	td_tiles_07A1B8
	.addr	td_tiles_07A1BE
	.addr	td_tiles_07A1C4
	.addr	td_tiles_07A1CA
	.addr	td_tiles_07A1D0
	.addr	td_tiles_07A1D6
	.addr	td_tiles_07A1DC
	.addr	td_tiles_07A1E2
	.addr	td_tiles_07A1E8
	.addr	td_tiles_07A1EE
	.addr	td_tiles_07A1F4
	.addr	td_tiles_07A1FA
	.addr	td_tiles_07A200
	.addr	td_tiles_07A206
	.addr	td_tiles_07A20C
	.addr	td_tiles_07A212
	.addr	td_tiles_07A218
	.addr	td_tiles_07A21E
	.addr	td_tiles_07A1C4
	.addr	td_tiles_07A1CA
	.addr	td_tiles_07A1D0
	.addr	td_tiles_07A1D6
	.addr	td_tiles_07A1DC
	.addr	td_tiles_07A1E2
	.addr	td_tiles_07A1E8
	.addr	td_tiles_07A1EE
	.addr	td_tiles_07A1F4
	.addr	td_tiles_07A1FA
	.addr	td_tiles_07A200
	.addr	td_tiles_07A206
	.addr	td_tiles_07A20C
	.addr	td_tiles_07A212
	.addr	td_tiles_07A218
	.addr	td_tiles_07A21E
	.addr	td_tiles_07A224
	.addr	td_tiles_07A22A
	.addr	td_tiles_07A230
	.addr	td_tiles_07A236
	.addr	td_tiles_07A23C
	.addr	td_tiles_07A242
	.addr	td_tiles_07A248
	.addr	td_tiles_07A24E
	.addr	td_tiles_07A254
	.addr	td_tiles_07A25A
	.addr	td_tiles_07A260
	.addr	td_tiles_07A266
	.addr	td_tiles_07A26C
	.addr	td_tiles_07A272
	.addr	td_tiles_07A278
	.addr	td_tiles_07A27E
	.addr	td_tiles_07A224
	.addr	td_tiles_07A22A
	.addr	td_tiles_07A230
	.addr	td_tiles_07A236
	.addr	td_tiles_07A23C
	.addr	td_tiles_07A242
	.addr	td_tiles_07A248
	.addr	td_tiles_07A24E
	.addr	td_tiles_07A254
	.addr	td_tiles_07A25A
	.addr	td_tiles_07A260
	.addr	td_tiles_07A266
	.addr	td_tiles_07A26C
	.addr	td_tiles_07A272
	.addr	td_tiles_07A278
	.addr	td_tiles_07A27E
td_tiles_07A164:
	td_tiles	$7EA000, $7EA0C0
td_tiles_07A16A:
	td_tiles	$7EA180, $7EA240
td_tiles_07A170:
	td_tiles	$7EA300, $7EA3C0
td_tiles_07A176:
	td_tiles	$7EA480, $7EA540
td_tiles_07A17C:
	td_tiles	$7EA600, $7EA6C0
td_tiles_07A182:
	td_tiles	$7EA780, $7EA840
td_tiles_07A188:
	td_tiles	$7EA900, $7EA9C0
td_tiles_07A18E:
	td_tiles	$7EAA80, $7EAB40
td_tiles_07A194:
	td_tiles	$7EAC00, $7EACC0
td_tiles_07A19A:
	td_tiles	$7EAD80, $7EAE40
td_tiles_07A1A0:
	td_tiles	$7EAF00, $7EAFC0
td_tiles_07A1A6:
	td_tiles	$7EB080, $7EB140
td_tiles_07A1AC:
	td_tiles	$7EB200, $7EB2C0
td_tiles_07A1B2:
	td_tiles	$7EB380, $7EB440
td_tiles_07A1B8:
	td_tiles	$7EB500, $7EB5C0
td_tiles_07A1BE:
	td_tiles	$7EB680, $7EB740
td_tiles_07A1C4:
	td_tiles	$7EB800, $7EB8C0
td_tiles_07A1CA:
	td_tiles	$7EB980, $7EBA40
td_tiles_07A1D0:
	td_tiles	$7EBB00, $7EBBC0
td_tiles_07A1D6:
	td_tiles	$7EBC80, $7EBD40
td_tiles_07A1DC:
	td_tiles	$7EBE00, $7EBEC0
td_tiles_07A1E2:
	td_tiles	$7EBF80, $7EC040
td_tiles_07A1E8:
	td_tiles	$7EC100, $7EC1C0
td_tiles_07A1EE:
	td_tiles	$7EC280, $7EC340
td_tiles_07A1F4:
	td_tiles	$7EC400, $7EC4C0
td_tiles_07A1FA:
	td_tiles	$7EC580, $7EC640
td_tiles_07A200:
	td_tiles	$7EC700, $7EC7C0
td_tiles_07A206:
	td_tiles	$7EC880, $7EC940
td_tiles_07A20C:
	td_tiles	$7ECA00, $7ECAC0
td_tiles_07A212:
	td_tiles	$7ECB80, $7ECC40
td_tiles_07A218:
	td_tiles	$7ECD00, $7ECDC0
td_tiles_07A21E:
	td_tiles	$7ECE80, $7ECF40
td_tiles_07A224:
	td_tiles	$7ED000, $7ED100
td_tiles_07A22A:
	td_tiles	$7ED200, $7ED300
td_tiles_07A230:
	td_tiles	$7ED400, $7ED500
td_tiles_07A236:
	td_tiles	$7ED600, $7ED6C0
td_tiles_07A23C:
	td_tiles	$7ED780, $7ED840
td_tiles_07A242:
	td_tiles	$7ED900, $7EDA00
td_tiles_07A248:
	td_tiles	$7EDB00, $7EDC00
td_tiles_07A24E:
	td_tiles	$7EDD00, $7EDE00
td_tiles_07A254:
	td_tiles	$7EDF00, $7EE000
td_tiles_07A25A:
	td_tiles	$7EE100, $7EE200
td_tiles_07A260:
	td_tiles	$7EE300, $7EE400
td_tiles_07A266:
	td_tiles	$7EE500, $7EE5C0
td_tiles_07A26C:
	td_tiles	$7EE680, $7EE740
td_tiles_07A272:
	td_tiles	$7EE800, $7EE900
td_tiles_07A278:
	td_tiles	$7EEA00, $7EEB00
td_tiles_07A27E:
	td_tiles	$7EEC00, $7EED00
td_metasprites_centipede:
	.addr	metasprite_07E12E
	.addr	metasprite_07E13F
	.addr	metasprite_07E150
	.addr	metasprite_07E161
	.addr	metasprite_07E172
	.addr	metasprite_07E183
	.addr	metasprite_07E194
	.addr	metasprite_07E1A5
	.addr	metasprite_07E1B6
	.addr	metasprite_07E1C7
	.addr	metasprite_07E1D8
	.addr	metasprite_07E1E9
	.addr	metasprite_07E1FA
	.addr	metasprite_07E20B
	.addr	metasprite_07E21C
	.addr	metasprite_07E22D
	.addr	metasprite_07E23E
	.addr	metasprite_07E24F
	.addr	metasprite_07E260
	.addr	metasprite_07E271
	.addr	metasprite_07E282
	.addr	metasprite_07E293
	.addr	metasprite_07E2A4
	.addr	metasprite_07E2B5
	.addr	metasprite_07E2C6
	.addr	metasprite_07E2D7
	.addr	metasprite_07E2E8
	.addr	metasprite_07E2F9
	.addr	metasprite_07E30A
	.addr	metasprite_07E31B
	.addr	metasprite_07E32C
	.addr	metasprite_07E33D
	.addr	metasprite_07E12E
	.addr	metasprite_07E13F
	.addr	metasprite_07E150
	.addr	metasprite_07E161
	.addr	metasprite_07E172
	.addr	metasprite_07E183
	.addr	metasprite_07E194
	.addr	metasprite_07E1A5
	.addr	metasprite_07E1B6
	.addr	metasprite_07E1C7
	.addr	metasprite_07E1D8
	.addr	metasprite_07E1E9
	.addr	metasprite_07E1FA
	.addr	metasprite_07E20B
	.addr	metasprite_07E21C
	.addr	metasprite_07E22D
	.addr	metasprite_07E23E
	.addr	metasprite_07E24F
	.addr	metasprite_07E260
	.addr	metasprite_07E271
	.addr	metasprite_07E282
	.addr	metasprite_07E293
	.addr	metasprite_07E2A4
	.addr	metasprite_07E2B5
	.addr	metasprite_07E2C6
	.addr	metasprite_07E2D7
	.addr	metasprite_07E2E8
	.addr	metasprite_07E2F9
	.addr	metasprite_07E30A
	.addr	metasprite_07E31B
	.addr	metasprite_07E32C
	.addr	metasprite_07E33D
td_tile_list_centipede:
	.addr	td_tiles_07A384
	.addr	td_tiles_07A38A
	.addr	td_tiles_07A390
	.addr	td_tiles_07A396
	.addr	td_tiles_07A39C
	.addr	td_tiles_07A3A2
	.addr	td_tiles_07A3A8
	.addr	td_tiles_07A3AE
	.addr	td_tiles_07A3B4
	.addr	td_tiles_07A3AE
	.addr	td_tiles_07A3A8
	.addr	td_tiles_07A3A2
	.addr	td_tiles_07A39C
	.addr	td_tiles_07A396
	.addr	td_tiles_07A390
	.addr	td_tiles_07A38A
	.addr	td_tiles_07A384
	.addr	td_tiles_07A38A
	.addr	td_tiles_07A390
	.addr	td_tiles_07A396
	.addr	td_tiles_07A39C
	.addr	td_tiles_07A3A2
	.addr	td_tiles_07A3A8
	.addr	td_tiles_07A3AE
	.addr	td_tiles_07A3B4
	.addr	td_tiles_07A3AE
	.addr	td_tiles_07A3A8
	.addr	td_tiles_07A3A2
	.addr	td_tiles_07A39C
	.addr	td_tiles_07A396
	.addr	td_tiles_07A390
	.addr	td_tiles_07A38A
	.addr	td_tiles_07A3BA
	.addr	td_tiles_07A3C0
	.addr	td_tiles_07A3C6
	.addr	td_tiles_07A3CC
	.addr	td_tiles_07A3D2
	.addr	td_tiles_07A3D8
	.addr	td_tiles_07A3DE
	.addr	td_tiles_07A3E4
	.addr	td_tiles_07A3EA
	.addr	td_tiles_07A3E4
	.addr	td_tiles_07A3DE
	.addr	td_tiles_07A3D8
	.addr	td_tiles_07A3D2
	.addr	td_tiles_07A3CC
	.addr	td_tiles_07A3C6
	.addr	td_tiles_07A3C0
	.addr	td_tiles_07A3BA
	.addr	td_tiles_07A3C0
	.addr	td_tiles_07A3C6
	.addr	td_tiles_07A3CC
	.addr	td_tiles_07A3D2
	.addr	td_tiles_07A3D8
	.addr	td_tiles_07A3DE
	.addr	td_tiles_07A3E4
	.addr	td_tiles_07A3EA
	.addr	td_tiles_07A3E4
	.addr	td_tiles_07A3DE
	.addr	td_tiles_07A3D8
	.addr	td_tiles_07A3D2
	.addr	td_tiles_07A3CC
	.addr	td_tiles_07A3C6
	.addr	td_tiles_07A3C0
td_tiles_07A384:
	td_tiles	td_sprite_tiles_14 + $0000, td_sprite_tiles_14 + $0080
td_tiles_07A38A:
	td_tiles	td_sprite_tiles_14 + $0100, td_sprite_tiles_14 + $0200
td_tiles_07A390:
	td_tiles	td_sprite_tiles_14 + $0300, td_sprite_tiles_14 + $0400
td_tiles_07A396:
	td_tiles	td_sprite_tiles_14 + $0500, td_sprite_tiles_14 + $0600
td_tiles_07A39C:
	td_tiles	td_sprite_tiles_14 + $0700, td_sprite_tiles_14 + $0800
td_tiles_07A3A2:
	td_tiles	td_sprite_tiles_14 + $0900, td_sprite_tiles_14 + $0A00
td_tiles_07A3A8:
	td_tiles	td_sprite_tiles_14 + $0B00, td_sprite_tiles_14 + $0C00
td_tiles_07A3AE:
	td_tiles	td_sprite_tiles_14 + $0D00, td_sprite_tiles_14 + $0E00
td_tiles_07A3B4:
	td_tiles	td_sprite_tiles_14 + $0F00, td_sprite_tiles_14 + $0F80
td_tiles_07A3BA:
	td_tiles	td_sprite_tiles_14 + $1000, td_sprite_tiles_14 + $1080
td_tiles_07A3C0:
	td_tiles	td_sprite_tiles_14 + $1100, td_sprite_tiles_14 + $1200
td_tiles_07A3C6:
	td_tiles	td_sprite_tiles_14 + $1300, td_sprite_tiles_14 + $1400
td_tiles_07A3CC:
	td_tiles	td_sprite_tiles_14 + $1500, td_sprite_tiles_14 + $1600
td_tiles_07A3D2:
	td_tiles	td_sprite_tiles_14 + $1700, td_sprite_tiles_14 + $1800
td_tiles_07A3D8:
	td_tiles	td_sprite_tiles_14 + $1900, td_sprite_tiles_14 + $1A00
td_tiles_07A3DE:
	td_tiles	td_sprite_tiles_14 + $1B00, td_sprite_tiles_14 + $1C00
td_tiles_07A3E4:
	td_tiles	td_sprite_tiles_14 + $1D00, td_sprite_tiles_14 + $1E00
; The frames of two 16x16 sprites (td_tiles_07A384, _07A3B4, _07A3BA and this
; one) are $100 bytes, the top tiles then the bottom ones: the second half
; starts $80 after the first, and its last $80 bytes land in VRAM tiles that
; their metasprites do not use (only tiles 0 and 2).  Here those $80 bytes are
; past the end of td_sprite_tiles_14, in whatever follows it: not shown
; (checked in the emulator with other bytes there: the sprite VRAM differs,
; the screen does not).
td_tiles_07A3EA:
	td_tiles	td_sprite_tiles_14 + $1F00, td_sprite_tiles_14 + $1F80
td_metasprites_explosion:
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	; CDL: read by draw_enemies, draw_enemies_p2; partly not accessed
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
	.addr	metasprite_07E89C
td_tile_list_explosion:
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F0
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9F6
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07A9FC
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA02
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA08
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA0E
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA14
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA1A
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA20
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA26
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	.addr	td_tiles_07AA2C
	; CDL: not accessed
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	.addr	td_tiles_07AA32
	; CDL: read by draw_enemies; partly not accessed
td_tiles_07A9F0:
	td_tiles	td_sprite_tiles_16 + $0000, td_sprite_tiles_16 + $0100
td_tiles_07A9F6:
	td_tiles	td_sprite_tiles_16 + $0200, td_sprite_tiles_16 + $0300
td_tiles_07A9FC:
	td_tiles	td_sprite_tiles_16 + $0400, td_sprite_tiles_16 + $0500
td_tiles_07AA02:
	td_tiles	td_sprite_tiles_16 + $0600, td_sprite_tiles_16 + $0700
td_tiles_07AA08:
	td_tiles	td_sprite_tiles_16 + $0800, td_sprite_tiles_16 + $0900
td_tiles_07AA0E:
	td_tiles	td_sprite_tiles_16 + $0A00, td_sprite_tiles_16 + $0B00
td_tiles_07AA14:
	td_tiles	td_sprite_tiles_16 + $0C00, td_sprite_tiles_16 + $0D00
td_tiles_07AA1A:
	td_tiles	td_sprite_tiles_16 + $0E00, td_sprite_tiles_16 + $0F00
td_tiles_07AA20:
	td_tiles	td_sprite_tiles_16 + $1000, td_sprite_tiles_16 + $1100
td_tiles_07AA26:
	td_tiles	td_sprite_tiles_16 + $1200, td_sprite_tiles_16 + $1300
td_tiles_07AA2C:
	td_tiles	td_sprite_tiles_16 + $1400, td_sprite_tiles_16 + $1500
td_tiles_07AA32:
	td_tiles	td_sprite_tiles_16 + $1600, td_sprite_tiles_16 + $1700
	; CDL: read by draw_topdown_metasprite, draw_stage5_boss_claw, draw_topdown_metasprite_p2; partly not accessed
td_metasprites_stage5_boss_claw:
	.addr	metasprite_07CFFE
	.addr	metasprite_07D007
	.addr	metasprite_07D014
	.addr	metasprite_07D021
	.addr	metasprite_07D02E
	.addr	metasprite_07D03B
	.addr	metasprite_07D048
	.addr	metasprite_07D055
	.addr	metasprite_07D062
	.addr	metasprite_07D06B
	.addr	metasprite_07D078
	.addr	metasprite_07D085
	.addr	metasprite_07D092
	.addr	metasprite_07D09F
	.addr	metasprite_07D0AC
	.addr	metasprite_07D0B9
	.addr	metasprite_07D0C6
	.addr	metasprite_07D0CF
	.addr	metasprite_07D0DC
	.addr	metasprite_07D0E9
	.addr	metasprite_07D0F6
	.addr	metasprite_07D103
	.addr	metasprite_07D110
	.addr	metasprite_07D11D
	.addr	metasprite_07D12A
	.addr	metasprite_07D133
	.addr	metasprite_07D140
	.addr	metasprite_07D14D
	.addr	metasprite_07D15A
	.addr	metasprite_07D167
	.addr	metasprite_07D174
	.addr	metasprite_07D181
td_tile_list_stage5_boss_claw:
	.addr	td_tiles_07AAB8
	.addr	td_tiles_07AABE
	.addr	td_tiles_07AAC4
	.addr	td_tiles_07AACA
	.addr	td_tiles_07AAD0
	.addr	td_tiles_07AAD6
	.addr	td_tiles_07AADC
	.addr	td_tiles_07AAE2
	.addr	td_tiles_07AAE8
	.addr	td_tiles_07AAE2
	.addr	td_tiles_07AADC
	.addr	td_tiles_07AAD6
	.addr	td_tiles_07AAD0
	.addr	td_tiles_07AACA
	.addr	td_tiles_07AAC4
	.addr	td_tiles_07AABE
	.addr	td_tiles_07AAB8
	.addr	td_tiles_07AABE
	.addr	td_tiles_07AAC4
	.addr	td_tiles_07AACA
	.addr	td_tiles_07AAD0
	.addr	td_tiles_07AAD6
	.addr	td_tiles_07AADC
	.addr	td_tiles_07AAE2
	.addr	td_tiles_07AAE8
	.addr	td_tiles_07AAE2
	.addr	td_tiles_07AADC
	.addr	td_tiles_07AAD6
	.addr	td_tiles_07AAD0
	.addr	td_tiles_07AACA
	.addr	td_tiles_07AAC4
	.addr	td_tiles_07AABE
td_tiles_07AAB8:
	td_tiles	$7EA000, $7EA080
td_tiles_07AABE:
	td_tiles	$7EA100, $7EA1C0
td_tiles_07AAC4:
	td_tiles	$7EA280, $7EA340
td_tiles_07AACA:
	td_tiles	$7EA400, $7EA4C0
td_tiles_07AAD0:
	td_tiles	$7EA580, $7EA640
td_tiles_07AAD6:
	td_tiles	$7EA700, $7EA7C0
td_tiles_07AADC:
	td_tiles	$7EA880, $7EA940
td_tiles_07AAE2:
	td_tiles	$7EAA00, $7EAAC0
td_tiles_07AAE8:
	td_tiles	$7EAB80, $7EAC00
metasprite_07AAEE:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00
	.byte	$E8, $00, $00
metasprite_07AAFB:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00, $E8, $00, $00
metasprite_07AB08:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00, $E8, $00, $00
metasprite_07AB15:
	.byte	$03, $02, $00
	.byte	$04, $00, $02, $F0, $02, $00, $F2, $F8, $00, $00
metasprite_07AB22:
	.byte	$03, $02, $00, $04, $00, $02
	.byte	$F0, $02, $00, $F2, $F8, $00, $00
metasprite_07AB2F:
	.byte	$03, $F8, $08, $04, $00, $04, $F8, $02, $00
	.byte	$F4, $F8, $00, $00
metasprite_07AB3C:
	.byte	$03, $F4, $00, $04, $00, $04, $F9, $02, $00, $F4, $F0, $00
	.byte	$00
metasprite_07AB49:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AB56:
	.byte	$03, $08
	.byte	$00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AB63:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AB70:
	.byte	$03, $08, $00
	.byte	$04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AB7D:
	.byte	$03, $00, $02, $04, $00, $F0
	.byte	$02, $02, $00, $F8, $F2, $00, $00
metasprite_07AB8A:
	.byte	$03, $00, $02, $04, $00, $F0, $02, $02, $00
	.byte	$F8, $F2, $00, $00
metasprite_07AB97:
	.byte	$03, $F8, $04, $04, $00, $F8, $F4, $02, $00, $E8, $F8, $00
	.byte	$00
metasprite_07ABA4:
	.byte	$03, $F7, $05, $04, $00, $00, $F5, $02, $00, $F0, $F5, $00, $00
metasprite_07ABB1:
	.byte	$03, $F0
	.byte	$08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07ABBE:
	.byte	$03, $F0, $F8, $04, $C0
	.byte	$00, $F8, $02, $C0, $F0, $08, $00, $C0
metasprite_07ABCB:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02
	.byte	$C0, $F0, $08, $00, $C0
metasprite_07ABD8:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02, $C0, $F0, $08
	.byte	$00, $C0
metasprite_07ABE5:
	.byte	$03, $EE, $F0, $04, $C0, $EE, $00, $02, $C0, $FE, $F8, $00, $C0
metasprite_07ABF2:
	.byte	$03
	.byte	$EE, $F0, $04, $C0, $EE, $00, $02, $C0, $FE, $F8, $00, $C0
metasprite_07ABFF:
	.byte	$03, $F8, $E8, $04
	.byte	$C0, $EC, $F8, $02, $C0, $FC, $F8, $00, $C0
metasprite_07AC0C:
	.byte	$03, $FB, $F0, $04, $C0, $EB, $F7
	.byte	$02, $C0, $FB, $00, $00, $C0
metasprite_07AC19:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8
	.byte	$00, $00, $C0
metasprite_07AC26:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07AC33:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07AC40:
	.byte	$03, $E8, $F0
	.byte	$04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07AC4D:
	.byte	$03, $F0, $EE, $04, $C0, $00
	.byte	$EE, $02, $C0, $F8, $FE, $00, $C0
metasprite_07AC5A:
	.byte	$03, $F0, $EE, $04, $C0, $00, $EE, $02, $C0
	.byte	$F8, $FE, $00, $C0
metasprite_07AC67:
	.byte	$03, $F8, $EC, $04, $C0, $F8, $FC, $02, $C0, $08, $F8, $00
	.byte	$C0
metasprite_07AC74:
	.byte	$03, $F9, $EB, $04, $C0, $F0, $FB, $02, $C0, $00, $FB, $00, $C0
metasprite_07AC81:
	.byte	$03, $00
	.byte	$E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07AC8E:
	.byte	$03, $00, $F8, $04, $00
	.byte	$F0, $F8, $02, $00, $00, $E8, $00, $00
metasprite_07AC9B:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02
	.byte	$00, $00, $E8, $00, $00
metasprite_07ACA8:
	.byte	$03, $00, $00, $04, $00, $F0, $F8, $02, $00, $00, $F0
	.byte	$00, $00
metasprite_07ACB5:
	.byte	$03, $01, $00, $04, $00, $F1, $F8, $02, $00, $01, $F0, $00, $00
metasprite_07ACC2:
	.byte	$03
	.byte	$F8, $07, $04, $00, $02, $F7, $02, $00, $F2, $F7, $00, $00
metasprite_07ACCF:
	.byte	$03, $F8, $00, $04
	.byte	$00, $08, $F8, $02, $00, $F8, $F0, $00, $00
metasprite_07ACDC:
	.byte	$03, $F8, $00, $04, $00, $08, $F9
	.byte	$02, $00, $F8, $F0, $00, $00
metasprite_07ACE9:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8
	.byte	$F0, $00, $00
metasprite_07ACF6:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AD03:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AD10:
	.byte	$03, $00, $00
	.byte	$04, $00, $F0, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07AD1D:
	.byte	$03, $00, $01, $04, $00, $F0
	.byte	$01, $02, $00, $F8, $F1, $00, $00
metasprite_07AD2A:
	.byte	$03, $F9, $02, $04, $00, $F9, $F2, $02, $00
	.byte	$E9, $F8, $00, $00
metasprite_07AD37:
	.byte	$03, $F8, $08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00
	.byte	$00
metasprite_07AD44:
	.byte	$03, $F7, $08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07AD51:
	.byte	$03, $F0
	.byte	$08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07AD5E:
	.byte	$03, $F0, $F8, $04, $C0
	.byte	$00, $F8, $02, $C0, $F0, $08, $00, $C0
metasprite_07AD6B:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02
	.byte	$C0, $F0, $08, $00, $C0
metasprite_07AD78:
	.byte	$03, $F0, $F0, $04, $C0, $00, $F8, $02, $C0, $F0, $00
	.byte	$00, $C0
metasprite_07AD85:
	.byte	$03, $EF, $F0, $04, $C0, $FF, $F8, $02, $C0, $EF, $00, $00, $C0
metasprite_07AD92:
	.byte	$03
	.byte	$F8, $E9, $04, $C0, $EE, $F9, $02, $C0, $FE, $F9, $00, $C0
metasprite_07AD9F:
	.byte	$03, $F8, $F0, $04
	.byte	$C0, $E8, $F8, $02, $C0, $F8, $00, $00, $C0
metasprite_07ADAC:
	.byte	$03, $F8, $F0, $04, $C0, $E8, $F7
	.byte	$02, $C0, $F8, $00, $00, $C0
metasprite_07ADB9:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8
	.byte	$00, $00, $C0
metasprite_07ADC6:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07ADD3:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07ADE0:
	.byte	$03, $F0, $F0
	.byte	$04, $C0, $00, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07ADED:
	.byte	$03, $F0, $EF, $04, $C0, $00
	.byte	$EF, $02, $C0, $F8, $FF, $00, $C0
metasprite_07ADFA:
	.byte	$03, $F7, $EE, $04, $C0, $F7, $FE, $02, $C0
	.byte	$07, $F8, $00, $C0
metasprite_07AE07:
	.byte	$03, $F8, $E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00
	.byte	$C0
metasprite_07AE14:
	.byte	$03, $F9, $E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07AE21:
	.byte	$03, $00
	.byte	$E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07AE2E:
	.byte	$03, $00, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F8, $00, $00
metasprite_07AE3B:
	.byte	$03, $FC, $00, $04, $00, $FC, $F0, $02
	.byte	$00, $EC, $F5, $00, $00
metasprite_07AE48:
	.byte	$03, $FC, $04, $04, $00, $00, $F4, $02, $00, $F0, $F4
	.byte	$00, $00
metasprite_07AE55:
	.byte	$03, $FA, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07AE62:
	.byte	$03
	.byte	$F8, $00, $04, $00, $08, $F8, $02, $00, $F8, $F0, $00, $00
metasprite_07AE6F:
	.byte	$03, $F8, $00, $04
	.byte	$00, $08, $F8, $02, $00, $F8, $F0, $00, $00
metasprite_07AE7C:
	.byte	$03, $F8, $00, $04, $00, $08, $F8
	.byte	$02, $00, $F8, $F0, $00, $00
metasprite_07AE89:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8
	.byte	$F0, $00, $00
metasprite_07AE96:
	.byte	$03, $00, $00, $04, $00, $F0, $00, $02, $00, $F9, $F0, $00, $00
metasprite_07AEA3:
	.byte	$03, $00, $FC, $04, $00, $F0, $FC, $02, $00, $FB, $EC, $00, $00
metasprite_07AEB0:
	.byte	$03, $FC, $00
	.byte	$04, $00, $FC, $F0, $02, $00, $EC, $FC, $00, $00
metasprite_07AEBD:
	.byte	$03, $00, $00, $04, $00, $00
	.byte	$F0, $02, $00, $F0, $FA, $00, $00
metasprite_07AECA:
	.byte	$03, $F8, $08, $04, $00, $00, $F8, $02, $00
	.byte	$F0, $F8, $00, $00
metasprite_07AED7:
	.byte	$03, $F8, $08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00
	.byte	$00
metasprite_07AEE4:
	.byte	$03, $F8, $08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07AEF1:
	.byte	$03, $F0
	.byte	$08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07AEFE:
	.byte	$03, $F0, $F0, $04, $C0
	.byte	$F0, $00, $02, $C0, $00, $F9, $00, $C0
metasprite_07AF0B:
	.byte	$03, $F4, $F0, $04, $C0, $F4, $00, $02
	.byte	$C0, $04, $FB, $00, $C0
metasprite_07AF18:
	.byte	$03, $F4, $EC, $04, $C0, $F0, $FC, $02, $C0, $00, $FC
	.byte	$00, $C0
metasprite_07AF25:
	.byte	$03, $F6, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07AF32:
	.byte	$03
	.byte	$F8, $F0, $04, $C0, $E8, $F8, $02, $C0, $F8, $00, $00, $C0
metasprite_07AF3F:
	.byte	$03, $F8, $F0, $04
	.byte	$C0, $E8, $F8, $02, $C0, $F8, $00, $00, $C0
metasprite_07AF4C:
	.byte	$03, $F8, $F0, $04, $C0, $E8, $F8
	.byte	$02, $C0, $F8, $00, $00, $C0
metasprite_07AF59:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8
	.byte	$00, $00, $C0
metasprite_07AF66:
	.byte	$03, $F0, $F0, $04, $C0, $00, $F0, $02, $C0, $F7, $00, $00, $C0
metasprite_07AF73:
	.byte	$03, $F0, $F4, $04, $C0, $00, $F4, $02, $C0, $F5, $04, $00, $C0
metasprite_07AF80:
	.byte	$03, $F4, $F0
	.byte	$04, $C0, $F4, $00, $02, $C0, $04, $F4, $00, $C0
metasprite_07AF8D:
	.byte	$03, $F0, $F0, $04, $C0, $F0
	.byte	$00, $02, $C0, $00, $F6, $00, $C0
metasprite_07AF9A:
	.byte	$03, $F8, $E8, $04, $C0, $F0, $F8, $02, $C0
	.byte	$00, $F8, $00, $C0
metasprite_07AFA7:
	.byte	$03, $F8, $E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00
	.byte	$C0
metasprite_07AFB4:
	.byte	$03, $F8, $E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07AFC1:
	.byte	$03, $00
	.byte	$E8, $04, $C0, $F0, $F8, $02
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2
	.byte	$C0, $00, $F8, $00, $C0
metasprite_07AFCE:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00, $E8
	.byte	$00, $00
metasprite_07AFDB:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00, $E8, $00, $00
metasprite_07AFE8:
	.byte	$03
	.byte	$00, $F8, $04, $00, $F0, $F8, $02, $00, $00, $E8, $00, $00
metasprite_07AFF5:
	.byte	$03, $01, $00, $04, $00, $01, $F0, $02, $00, $F1, $F8, $00, $00
metasprite_07B002:
	.byte	$03, $02, $00
	.byte	$04, $00, $02, $F0, $02, $00, $F2, $F7, $00, $00
metasprite_07B00F:
	.byte	$03, $07, $F8, $04, $00, $F7
	.byte	$00, $02, $00, $F7, $F0, $00, $00
metasprite_07B01C:
	.byte	$03, $07, $F9, $04, $00, $F7, $00, $02, $00
	.byte	$F7, $F0, $00, $00
metasprite_07B029:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00
	.byte	$00
metasprite_07B036:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B043:
	.byte	$03, $08
	.byte	$00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B050:
	.byte	$03, $08, $00, $04, $00
	.byte	$F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B05D:
	.byte	$03, $00, $01, $04, $00, $F0, $01, $02
	.byte	$00, $F8, $F1, $00, $00
metasprite_07B06A:
	.byte	$03, $00, $02, $04, $00, $F0, $02, $02, $00, $F9, $F2
	.byte	$00, $00
metasprite_07B077:
	.byte	$03, $F8, $07, $04, $00, $00, $F7, $02, $00, $F0, $F7, $00, $00
metasprite_07B084:
	.byte	$03
	.byte	$F7, $07, $04, $00, $00, $F7, $02, $00, $F0, $F7, $00, $00
metasprite_07B091:
	.byte	$03, $F0, $08, $04
	.byte	$00, $00, $F8, $02, $00, $F0, $F8, $00, $00
metasprite_07B09E:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8
	.byte	$02, $C0, $F0, $08, $00, $C0
metasprite_07B0AB:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02, $C0, $F0
	.byte	$08, $00, $C0
metasprite_07B0B8:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02, $C0, $F0, $08, $00, $C0
metasprite_07B0C5:
	.byte	$03, $EF, $F0, $04, $C0, $EF, $00, $02, $C0, $FF, $F8, $00, $C0
metasprite_07B0D2:
	.byte	$03, $EE, $F0
	.byte	$04, $C0, $EE, $00, $02, $C0, $FE, $F9, $00, $C0
metasprite_07B0DF:
	.byte	$03, $E9, $F8, $04, $C0, $F9
	.byte	$F0, $02, $C0, $F9, $00, $00, $C0
metasprite_07B0EC:
	.byte	$03, $E9, $F7, $04, $C0, $F9, $F0, $02, $C0
	.byte	$F9, $00, $00, $C0
metasprite_07B0F9:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00
	.byte	$C0
metasprite_07B106:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B113:
	.byte	$03, $E8
	.byte	$F0, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B120:
	.byte	$03, $E8, $F0, $04, $C0
	.byte	$F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B12D:
	.byte	$03, $F0, $EF, $04, $C0, $00, $EF, $02
	.byte	$C0, $F8, $FF, $00, $C0
metasprite_07B13A:
	.byte	$03, $F0, $EE, $04, $C0, $00, $EE, $02, $C0, $F7, $FE
	.byte	$00, $C0
metasprite_07B147:
	.byte	$03, $F8, $E9, $04, $C0, $F0, $F9, $02, $C0, $00, $F9, $00, $C0
metasprite_07B154:
	.byte	$03
	.byte	$F9, $E9, $04, $C0, $F0, $F9, $02, $C0, $00, $F9, $00, $C0
metasprite_07B161:
	.byte	$03, $00, $E8, $04
	.byte	$C0, $F0, $F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07B16E:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8
	.byte	$02, $00, $00, $E8, $00, $00
metasprite_07B17B:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8, $02, $00, $00
	.byte	$E8, $00, $00
	; CDL: read by draw_topdown_metasprite; partly not accessed
metasprite_07B188:
	.byte	$03, $00, $F9, $04, $00, $F0, $F8, $02, $00, $00, $E9, $00, $00
metasprite_07B195:
	.byte	$03, $01, $00
	.byte	$04, $00, $01, $F0, $02, $00, $F1, $F8, $00, $00
metasprite_07B1A2:
	.byte	$03, $FC, $07, $04, $00, $04
	.byte	$F7, $02, $00, $F4, $F7, $00, $00
metasprite_07B1AF:
	.byte	$03, $07, $F9, $04, $00, $F7, $00, $02, $00
	.byte	$F7, $F0, $00, $00
metasprite_07B1BC:
	.byte	$03, $08, $F8, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00
	.byte	$00
metasprite_07B1C9:
	.byte	$03, $08, $00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B1D6:
	.byte	$03, $08
	.byte	$00, $04, $00, $F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B1E3:
	.byte	$03, $08, $00, $04, $00
	.byte	$F8, $00, $02, $00, $F8, $F0, $00, $00
metasprite_07B1F0:
	.byte	$03, $07, $00, $04, $00, $F7, $00, $02
	.byte	$00, $F8, $F0, $00, $00
metasprite_07B1FD:
	.byte	$03, $00, $01, $04, $00, $F0, $01, $02, $00, $F8, $F1, $00, $00
metasprite_07B20A:
	.byte	$03, $F9, $04
	.byte	$04, $00, $F9, $F4, $02, $00, $E9, $FC, $00, $00
metasprite_07B217:
	.byte	$03, $F7, $07, $04, $00, $00
	.byte	$F7, $02, $00, $F0, $F7, $00, $00
metasprite_07B224:
	.byte	$03, $F8, $08, $04, $00, $00, $F8, $02, $00
	.byte	$F0, $F8, $00, $00
metasprite_07B231:
	.byte	$03, $F0, $08, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00
	.byte	$00
metasprite_07B23E:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02, $C0, $F0, $08, $00, $C0
metasprite_07B24B:
	.byte	$03, $F0
	.byte	$F8, $04, $C0, $00, $F8, $02, $C0, $F0, $08, $00, $C0
metasprite_07B258:
	.byte	$03, $F0, $F7, $04, $C0
	.byte	$00, $F8, $02, $C0, $F0, $07, $00, $C0
metasprite_07B265:
	.byte	$03, $EF, $F0, $04, $C0, $EF, $00, $02
	.byte	$C0, $FF, $F8, $00, $C0
metasprite_07B272:
	.byte	$03, $F4, $E9, $04, $C0, $EC, $F9, $02, $C0, $FC, $F9
	.byte	$00, $C0
metasprite_07B27F:
	.byte	$03, $E9, $F7, $04, $C0, $F9, $F0, $02, $C0, $F9, $00, $00, $C0
metasprite_07B28C:
	.byte	$03
	.byte	$E8, $F8, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B299:
	.byte	$03, $E8, $F0, $04
	.byte	$C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B2A6:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0
	.byte	$02, $C0, $F8, $00, $00, $C0
metasprite_07B2B3:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F0, $02, $C0, $F8
	.byte	$00, $00, $C0
metasprite_07B2C0:
	.byte	$03, $E9, $F0, $04, $C0, $F9, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07B2CD:
	.byte	$03, $F0, $EF, $04, $C0, $00, $EF, $02, $C0, $F8, $FF, $00, $C0
metasprite_07B2DA:
	.byte	$03, $F7, $EC
	.byte	$04, $C0, $F7, $FC, $02, $C0, $07, $F4, $00, $C0
metasprite_07B2E7:
	.byte	$03, $F9, $E9, $04, $C0, $F0
	.byte	$F9, $02, $C0, $00, $F9, $00, $C0
metasprite_07B2F4:
	.byte	$03, $F8, $E8, $04, $C0, $F0, $F8, $02, $C0
	.byte	$00, $F8, $00, $C0
metasprite_07B301:
	.byte	$03, $00, $E8, $04, $C0, $F0, $F8, $02, $C0, $00, $F8, $00
	.byte	$C0
metasprite_07B30E:
	.byte	$03, $F8, $06, $04, $00, $00, $F6, $02, $00, $F0, $F6, $00, $00
	; CDL: read by draw_topdown_metasprite_p2; partly not accessed
metasprite_07B31B:
	.byte	$03, $08, $F8, $04, $00, $F8, $F9, $02, $00, $E8, $F4, $00, $00
metasprite_07B328:
	.byte	$03, $02, $F8
	.byte	$04, $00, $F2, $00, $02, $00, $F2, $F0, $00, $00
metasprite_07B335:
	.byte	$03, $04, $F8, $04, $00, $F4
	.byte	$F8, $02, $00, $F4, $E8, $00, $00
metasprite_07B342:
	.byte	$03, $04, $F9, $04, $00, $F4, $F9, $02, $00
	.byte	$F4, $E9, $00, $00
metasprite_07B34F:
	.byte	$03, $00, $FC, $04, $00, $F0, $FC, $02, $00, $F8, $EC, $00
	.byte	$00
metasprite_07B35C:
	.byte	$03, $00, $FE, $04, $00, $F0, $FE, $02, $00, $F8, $EE, $00, $00
metasprite_07B369:
	.byte	$03, $08
	.byte	$00, $04, $00, $F8, $FC, $02, $00, $F8, $EC, $00, $00
metasprite_07B376:
	.byte	$03, $FC, $08, $04, $00
	.byte	$F7, $F8, $02, $00, $FC, $E8, $00, $00
metasprite_07B383:
	.byte	$03, $08, $F0, $04, $80, $F8, $F4, $02, $80, $F8, $04, $00, $80
metasprite_07B390:
	.byte	$03, $00, $F2
	.byte	$04, $80, $F0, $F2, $02, $80, $F8, $02, $00, $80
metasprite_07B39D:
	.byte	$03, $00, $F4, $04, $80, $F0
	.byte	$F4, $02, $80, $F8, $04, $00, $80
metasprite_07B3AA:
	.byte	$03, $04, $F7, $04, $80, $F4, $F7, $02, $80
	.byte	$F4, $07, $00, $80
metasprite_07B3B7:
	.byte	$03, $04, $F8, $04, $80, $F4, $F8, $02, $80, $F4, $08, $00
	.byte	$80
metasprite_07B3C4:
	.byte	$03, $02, $F8, $04, $80, $F2, $F0, $02, $80, $F2, $00, $00, $80
metasprite_07B3D1:
	.byte	$03, $08
	.byte	$F8, $04, $80, $F8, $F7, $02, $80, $E8, $FC, $00, $80
metasprite_07B3DE:
	.byte	$03, $F8, $EA, $04, $C0
	.byte	$F0, $FA, $02, $C0, $00, $FA, $00, $C0
metasprite_07B3EB:
	.byte	$03, $E8, $F8, $04, $C0, $F8, $F7, $02
	.byte	$C0, $08, $FC, $00, $C0
metasprite_07B3F8:
	.byte	$03, $EE, $F8, $04, $C0, $FE, $F0, $02, $C0, $FE, $00
	.byte	$00, $C0
metasprite_07B405:
	.byte	$03, $EC, $F8, $04, $C0, $FC, $F8, $02, $C0, $FC, $08, $00, $C0
metasprite_07B412:
	.byte	$03
	.byte	$EC, $F7, $04, $C0, $FC, $F7, $02, $C0, $FC, $07, $00, $C0
metasprite_07B41F:
	.byte	$03, $F0, $F4, $04
	.byte	$C0, $00, $F4, $02, $C0, $F8, $04, $00, $C0
metasprite_07B42C:
	.byte	$03, $F0, $F2, $04, $C0, $00, $F2
	.byte	$02, $C0, $F8, $02, $00, $C0
metasprite_07B439:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F4, $02, $C0, $F8
	.byte	$04, $00, $C0
metasprite_07B446:
	.byte	$03, $F4, $E8, $04, $C0, $F9, $F8, $02, $C0, $F4, $08, $00, $C0
metasprite_07B453:
	.byte	$03, $E8, $00, $04, $40, $F8, $FC, $02, $40, $F8, $EC, $00, $40
metasprite_07B460:
	.byte	$03, $F0, $FE
	.byte	$04, $40, $00, $FE, $02, $40, $F8, $EE, $00, $40
metasprite_07B46D:
	.byte	$03, $F0, $FC, $04, $40, $00
	.byte	$FC, $02, $40, $F8, $EC, $00, $40
metasprite_07B47A:
	.byte	$03, $EC, $F9, $04, $40, $FC, $F9, $02, $40
	.byte	$FC, $E9, $00, $40
metasprite_07B487:
	.byte	$03, $EC, $F8, $04, $40, $FC, $F8, $02, $40, $FC, $E8, $00
	.byte	$40
metasprite_07B494:
	.byte	$03, $EE, $F8, $04, $40, $FE, $00, $02, $40, $FE, $F0, $00, $40
metasprite_07B4A1:
	.byte	$03, $E8
	.byte	$F8, $04, $40, $F8, $F9, $02, $40, $08, $F4, $00, $40
metasprite_07B4AE:
	.byte	$03, $08, $F8, $04, $00
	.byte	$F8, $F8, $02, $00, $E8, $F8, $00, $00
metasprite_07B4BB:
	.byte	$03, $08, $F8, $04, $00, $F8, $F8, $02
	.byte	$00, $E8, $F8, $00, $00
metasprite_07B4C8:
	.byte	$03, $08, $00, $04, $00, $F8, $F9, $02, $00, $E8, $F4
	.byte	$00, $00
metasprite_07B4D5:
	.byte	$03, $05, $00, $04, $00, $F8, $F8, $02, $00, $EE, $F0, $00, $00
metasprite_07B4E2:
	.byte	$03
	.byte	$02, $00, $04, $00, $F8, $F8, $02, $00, $F0, $EE, $00, $00
metasprite_07B4EF:
	.byte	$03, $00, $03, $04
	.byte	$00, $F8, $F8, $02, $00, $F0, $EC, $00, $00
metasprite_07B4FC:
	.byte	$03, $FC, $08, $04, $00, $F8, $F8
	.byte	$02, $00, $F0, $E8, $00, $00
metasprite_07B509:
	.byte	$03, $F9, $08, $04, $00, $F8, $F8, $02, $00, $F8
	.byte	$E8, $00, $00
metasprite_07B516:
	.byte	$03, $F8, $08, $04, $00, $F8, $F8, $02, $00, $F8, $E8, $00, $00
metasprite_07B523:
	.byte	$03, $F9, $E8, $04, $80, $F8, $F8, $02, $80, $F8, $08, $00, $80
metasprite_07B530:
	.byte	$03, $FC, $E8
	.byte	$04, $80, $F8, $F8, $02, $80, $F0, $08, $00, $80
metasprite_07B53D:
	.byte	$03, $00, $ED, $04, $80, $F8
	.byte	$F8, $02, $80, $F0, $04, $00, $80
metasprite_07B54A:
	.byte	$03, $02, $F0, $04, $80, $F8, $F8, $02, $80
	.byte	$F0, $02, $00, $80
metasprite_07B557:
	.byte	$03, $05, $F0, $04, $80, $F8, $F8, $02, $80, $EE, $00, $00
	.byte	$80
metasprite_07B564:
	.byte	$03, $08, $F0, $04, $80, $F8, $F7, $02, $80, $E8, $FC, $00, $80
metasprite_07B571:
	.byte	$03, $08
	.byte	$F8, $04, $80, $F8, $F8, $02, $80, $E8, $F8, $00, $80
metasprite_07B57E:
	.byte	$03, $E8, $F8, $04, $C0
	.byte	$F8, $F8, $02, $C0, $08, $F8, $00, $C0
metasprite_07B58B:
	.byte	$03, $E8, $F8, $04, $C0, $F8, $F8, $02
	.byte	$C0, $08, $F8, $00, $C0
metasprite_07B598:
	.byte	$03, $E8, $F0, $04, $C0, $F8, $F7, $02, $C0, $08, $FC
	.byte	$00, $C0
metasprite_07B5A5:
	.byte	$03, $EC, $F0, $04, $C0, $F9, $F8, $02, $C0, $03, $00, $00, $C0
metasprite_07B5B2:
	.byte	$03
	.byte	$EE, $F0, $04, $C0, $F8, $F8, $02, $C0, $00, $02, $00, $C0
metasprite_07B5BF:
	.byte	$03, $F0, $ED, $04
	.byte	$C0, $F8, $F8, $02, $C0, $00, $04, $00, $C0
metasprite_07B5CC:
	.byte	$03, $F4, $E8, $04, $C0, $F8, $F8
	.byte	$02, $C0, $00, $08, $00, $C0
metasprite_07B5D9:
	.byte	$03, $F7, $E8, $04, $C0, $F8, $F8, $02, $C0, $F8
	.byte	$08, $00, $C0
metasprite_07B5E6:
	.byte	$03, $F8, $E8, $04, $C0, $F8, $F8, $02, $C0, $F8, $08, $00, $C0
metasprite_07B5F3:
	.byte	$03, $F7, $08, $04, $40, $F8, $F8, $02, $40, $F8, $E8, $00, $40
metasprite_07B600:
	.byte	$03, $F4, $08
	.byte	$04, $40, $F8, $F8, $02, $40, $00, $E8, $00, $40
metasprite_07B60D:
	.byte	$03, $F0, $03, $04, $40, $F8
	.byte	$F8, $02, $40, $00, $EC, $00, $40
metasprite_07B61A:
	.byte	$03, $EE, $00, $04, $40, $F8, $F8, $02, $40
	.byte	$00, $EE, $00, $40
metasprite_07B627:
	.byte	$03, $EB, $00, $04, $40, $F8, $F8, $02, $40, $02, $F0, $00
	.byte	$40
metasprite_07B634:
	.byte	$03, $E8, $00, $04, $40, $F8, $F9, $02, $40, $08, $F4, $00, $40
metasprite_07B641:
	.byte	$03, $E8
	.byte	$F8, $04, $40, $F8, $F8, $02, $40, $08, $F8, $00, $40
metasprite_07B64E:
	.byte	$03, $F8, $00, $04, $40
	.byte	$F8, $F0, $02, $40, $F8, $E0, $00, $40
metasprite_07B65B:
	.byte	$03, $F9, $00, $04, $40, $F6, $F0, $02
	.byte	$40, $F8, $E0, $00, $40
metasprite_07B668:
	.byte	$03, $FB, $FF, $04, $40, $F5, $F0, $02, $40, $F0, $EA
	.byte	$00, $40
metasprite_07B675:
	.byte	$03, $FB, $FD, $04, $40, $F3, $F8, $02, $40, $F2, $EC, $00, $40
metasprite_07B682:
	.byte	$03
	.byte	$FD, $FD, $04, $40, $F3, $F6, $02, $40, $F1, $EE, $00, $40
metasprite_07B68F:
	.byte	$03, $F2, $00, $04
	.byte	$40, $FF, $FB, $02, $40, $EF, $F0, $00, $40
metasprite_07B69C:
	.byte	$03, $00, $FB, $04, $40, $F0, $F8
	.byte	$02, $40, $ED, $E8, $00, $40
metasprite_07B6A9:
	.byte	$03, $E0, $F8, $04, $40, $F0, $F7, $02, $40, $FD
	.byte	$FA, $00, $40
metasprite_07B6B6:
	.byte	$03, $E0, $F8, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07B6C3:
	.byte	$03, $E0, $F8, $04, $40, $F0, $FA, $02, $40, $00, $F7, $00, $40
metasprite_07B6D0:
	.byte	$03, $EA, $00
	.byte	$04, $40, $F0, $FB, $02, $40, $FF, $F5, $00, $40
metasprite_07B6DD:
	.byte	$03, $EC, $FE, $04, $40, $F8
	.byte	$FD, $02, $40, $FD, $F5, $00, $40
metasprite_07B6EA:
	.byte	$03, $EE, $FF, $04, $40, $F5, $FD, $02, $40
	.byte	$FD, $F3, $00, $40
metasprite_07B6F7:
	.byte	$03, $F0, $01, $04, $40, $00, $FE, $02, $40, $FB, $F1, $00, $40
metasprite_07B704:
	.byte	$03, $E8, $03
	.byte	$04, $40, $F8, $00, $02, $40, $FB, $F0, $00, $40
metasprite_07B711:
	.byte	$03, $F8, $10, $04, $40, $F7
	.byte	$00, $02, $40, $FA, $F3, $00, $40
metasprite_07B71E:
	.byte	$03, $F8, $F0, $04, $80, $F8, $00, $02, $80
	.byte	$F8, $10, $00, $80
metasprite_07B72B:
	.byte	$03, $F7, $F0, $04, $80, $FA, $00, $02, $80, $F8, $10, $00
	.byte	$80
metasprite_07B738:
	.byte	$03, $F5, $F1, $04, $80, $FB, $00, $02, $80, $00, $06, $00, $80
metasprite_07B745:
	.byte	$03, $F5
	.byte	$F3, $04, $80, $FD, $F8, $02, $80, $FE, $04, $00, $80
metasprite_07B752:
	.byte	$03, $F3, $F3, $04, $80
	.byte	$FD, $FA, $02, $80, $FF, $02, $00, $80
metasprite_07B75F:
	.byte	$03, $FE, $F0, $04, $80, $F1, $F5, $02
	.byte	$80, $01, $00, $00, $80
metasprite_07B76C:
	.byte	$03, $F0, $F5, $04, $80, $00, $F8, $02, $80, $03, $08
	.byte	$00, $80
metasprite_07B779:
	.byte	$03, $10, $F8, $04, $80, $00, $F9, $02, $80, $F3, $F6, $00, $80
metasprite_07B786:
	.byte	$03
	.byte	$10, $F8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07B793:
	.byte	$03, $10, $F8, $04
	.byte	$80, $00, $F6, $02, $80, $F0, $F9, $00, $80
metasprite_07B7A0:
	.byte	$03, $06, $F0, $04, $80, $00, $F5
	.byte	$02, $80, $F1, $FB, $00, $80
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
metasprite_07B7AD:
	.byte	$03, $04, $F2, $04, $80, $F8, $F3, $02, $80, $F3, $FB, $00, $80
metasprite_07B7BA:
	.byte	$03, $02, $F1
	.byte	$04, $80, $FB, $F3, $02, $80, $F3, $FD, $00, $80
metasprite_07B7C7:
	.byte	$03, $00, $EF, $04, $80, $F0
	.byte	$F2, $02, $80, $F5, $FF, $00, $80
metasprite_07B7D4:
	.byte	$03, $08, $ED, $04, $80, $F8, $F0, $02, $80
	.byte	$F5, $00, $00, $80
metasprite_07B7E1:
	.byte	$03, $F8, $E0, $04, $80, $F9, $F0, $02, $80, $F6, $FD, $00
	.byte	$80
metasprite_07B7EE:
	.byte	$03, $F8, $04, $04, $40, $F8, $F4, $02, $40, $F8, $E4, $00, $40
metasprite_07B7FB:
	.byte	$04, $FB
	.byte	$04, $06, $40, $F8, $00, $04, $40, $F6, $F0, $02, $40, $F6, $E0, $00, $40
metasprite_07B80C:
	.byte	$04
	.byte	$FD, $05, $06, $40, $F9, $01, $04, $40, $F5, $F6, $02, $40, $F4, $E6, $00, $40
metasprite_07B81D:
	.byte	$04, $FF, $03, $06, $40, $FC, $FC, $04, $40, $F2, $F8, $02, $40, $F2, $E8, $00
	.byte	$40
metasprite_07B82E:
	.byte	$04, $01, $01, $06, $40, $FB, $FB, $04, $40, $F1, $F3, $02, $40, $EE, $EA
	.byte	$00, $40
metasprite_07B83F:
	.byte	$04, $03, $00, $06, $40, $FB, $FC, $04, $40, $F0, $F4, $02, $40, $EA
	.byte	$EE, $00, $40
metasprite_07B850:
	.byte	$04, $05, $FE, $06, $40, $FC, $FB, $04, $40, $F0, $F5, $02, $40
	.byte	$E7, $F1
	; CDL: read by draw_topdown_metasprite_p2; partly not accessed
	.byte	$00, $40
metasprite_07B861:
	.byte	$04, $FE, $04, $06, $40, $E4, $F6, $04, $40, $F4, $F6, $02, $40, $04
	.byte	$FA, $00, $40
metasprite_07B872:
	.byte	$03, $E4, $F8, $04, $40, $F4, $F8, $02, $40, $04, $F8, $00, $40
metasprite_07B87F:
	.byte	$04, $E0, $FA, $06, $40, $F0, $FA, $04, $40, $00, $F8, $02, $40, $04, $F5, $00
	.byte	$40
	; CDL: read by draw_topdown_metasprite
metasprite_07B890:
	.byte	$04, $E6, $FC, $06, $40, $F6, $FB, $04, $40, $00, $F7, $02, $40, $04, $F3, $00
	.byte	$40
metasprite_07B8A1:
	.byte	$04, $E8, $FE, $06, $40, $F8, $FE, $04, $40, $FC, $F4, $02, $40, $03, $F1
	.byte	$00, $40
metasprite_07B8B2:
	.byte	$04, $EA, $02, $06, $40, $F3, $FF, $04, $40, $FB, $F5, $02, $40, $01
	.byte	$EF, $00, $40
metasprite_07B8C3:
	.byte	$04, $EE, $06, $06, $40, $F4, $00, $04, $40, $FC, $F5, $02, $40
	.byte	$00, $ED, $00, $40
metasprite_07B8D4:
	.byte	$04, $F1, $09, $06, $40, $F5, $00, $04, $40, $FB, $F4, $02, $40, $FE, $EB, $00
	.byte	$40
metasprite_07B8E5:
	.byte	$04, $F6, $0C, $06, $40, $F6, $FC, $04, $40, $FA, $EC, $02, $40, $04, $F2
	.byte	$00, $40
metasprite_07B8F6:
	.byte	$03, $F8, $EC, $04, $80, $F8, $FC, $02, $80, $F8, $0C, $00, $80
metasprite_07B903:
	.byte	$04
	.byte	$F5, $EC, $06, $80, $F8, $F0, $04, $80, $FA, $00, $02, $80, $FA, $10, $00, $80
metasprite_07B914:
	.byte	$04, $F3, $EB, $06, $80, $F7, $EF, $04, $80, $FB, $FA, $02, $80, $FC, $0A, $00
	.byte	$80
metasprite_07B925:
	.byte	$04, $F1, $ED, $06, $80, $F4, $F4, $04, $80, $FE, $F8, $02, $80, $FE, $08
	.byte	$00, $80
metasprite_07B936:
	.byte	$04, $EF, $EF, $06, $80, $F5, $F5, $04, $80, $FF, $FD, $02, $80, $02
	.byte	$06, $00, $80
metasprite_07B947:
	.byte	$04, $ED, $F0, $06, $80, $F5, $F4, $04, $80, $00, $FC, $02, $80
	.byte	$06, $02, $00, $80
metasprite_07B958:
	.byte	$04, $EB, $F2, $06, $80, $F4, $F5, $04, $80, $00, $FB, $02
	.byte	$80, $09, $FF, $00, $80
metasprite_07B969:
	.byte	$04, $F2, $EC, $06, $80, $0C, $FA, $04, $80, $FC, $FA
	.byte	$02, $80, $EC, $F6, $00, $80
metasprite_07B97A:
	.byte	$03, $0C, $F8, $04, $80, $FC, $F8, $02, $80, $EC
	.byte	$F8, $00, $80
metasprite_07B987:
	.byte	$04, $10, $F6, $06, $80, $00, $F6, $04, $80, $F0, $F8, $02, $80
	.byte	$EC, $FB, $00, $80
metasprite_07B998:
	.byte	$04, $0A, $F4, $06, $80, $FA, $F5, $04, $80, $F0, $F9, $02
	.byte	$80, $EC, $FD, $00, $80
	; CDL: not accessed
metasprite_07B9A9:
	.byte	$04, $08, $F2, $06, $80, $F8, $F2, $04, $80, $F4, $FC, $02, $80, $ED, $FF, $00
	.byte	$80
metasprite_07B9BA:
	.byte	$04, $06, $EE, $06, $80, $FD, $F1, $04, $80, $F5, $FB, $02, $80, $EF, $01
	.byte	$00, $80
metasprite_07B9CB:
	.byte	$04, $02, $EA, $06, $80, $FC, $F0, $04, $80, $F4, $FB, $02, $80, $F0
	.byte	$03, $00, $80
metasprite_07B9DC:
	.byte	$04, $FF, $E7, $06, $80, $FB, $F0, $04, $80, $F5, $FC, $02, $80
	.byte	$F2, $05, $00, $80
metasprite_07B9ED:
	.byte	$04, $FA, $E4, $06, $80, $FA, $F4, $04, $80, $F6, $04, $02
	.byte	$80, $EC, $FE, $00, $80
metasprite_07B9FE:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00, $00
	.byte	$C0
metasprite_07BA0F:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00
	.byte	$00, $C0
metasprite_07BA20:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00
	.byte	$00, $00, $C0
metasprite_07BA31:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0
	.byte	$00, $00, $00, $C0
metasprite_07BA42:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02
	.byte	$C0, $00, $00, $00, $C0
metasprite_07BA53:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00
	.byte	$02, $C0, $00, $00, $00, $C0
metasprite_07BA64:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0
	.byte	$00, $02, $C0, $00, $00, $00, $C0
metasprite_07BA75:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0
	.byte	$F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07BA86:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04
	.byte	$C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07BA97:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0
	.byte	$04, $C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07BAA8:
	.byte	$04, $F0, $F0, $06, $C0, $00
	.byte	$F0, $04, $C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07BAB9:
	.byte	$04, $F0, $F0, $06, $C0
	.byte	$00, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07BACA:
	.byte	$04, $F0, $F0, $06
	.byte	$C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00
	.byte	$00, $C0
metasprite_07BADB:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00
	.byte	$00, $00, $C0
metasprite_07BAEC:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0
	.byte	$00, $00, $00, $C0
metasprite_07BAFD:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02
	.byte	$C0, $00, $00, $00, $C0
metasprite_07BB0E:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0
	.byte	$02, $00, $F0, $F0, $00, $00
metasprite_07BB1F:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00
	.byte	$F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB30:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB41:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04
	.byte	$00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB52:
	.byte	$04, $00, $00, $06, $00, $F0, $00
	.byte	$04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB63:
	.byte	$04, $00, $00, $06, $00, $F0
	.byte	$00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB74:
	.byte	$04, $00, $00, $06, $00
	.byte	$F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB85:
	.byte	$04, $00, $00, $06
	.byte	$00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BB96:
	.byte	$04, $00, $00
	.byte	$06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BBA7:
	.byte	$04, $00
	.byte	$00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BBB8:
	.byte	$04
	.byte	$00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07BBC9:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00
	.byte	$00
metasprite_07BBDA:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0
	.byte	$00, $00
metasprite_07BBEB:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0
	.byte	$F0, $00, $00
metasprite_07BBFC:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00
	.byte	$F0, $F0, $00, $00
metasprite_07BC0D:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02
	.byte	$00, $F0, $F0, $00, $00
metasprite_07BC1E:
	.byte	$04, $F8, $E8, $06, $C0, $F8, $F8, $04, $C0, $F8, $08
	.byte	$02, $C0, $08, $FD, $00, $C0
metasprite_07BC2F:
	.byte	$04, $F8, $E4, $06, $C0, $F8, $F4, $04, $C0, $F5
	.byte	$04, $02, $C0, $02, $00, $00, $C0
metasprite_07BC40:
	.byte	$04, $FD, $EE, $06, $C0, $F5, $F4, $04, $C0
	.byte	$F4, $04, $02, $C0, $04, $FE, $00, $C0
metasprite_07BC51:
	.byte	$04, $FF, $EF, $06, $C0, $F2, $F4, $04
	.byte	$C0, $F2, $04, $02, $C0, $02, $FF, $00, $C0
metasprite_07BC62:
	.byte	$04, $00, $EF, $06, $C0, $F2, $F2
	.byte	$04, $C0, $F0, $02, $02, $C0, $FF, $FF, $00, $C0
metasprite_07BC73:
	.byte	$04, $F0, $F0, $06, $C0, $00
	.byte	$F0, $04, $C0, $EE, $00, $02, $C0, $FE, $00, $00, $C0
metasprite_07BC84:
	.byte	$04, $F0, $F0, $06, $C0
	.byte	$00, $F0, $04, $C0, $EA, $00, $02, $C0, $FA, $00, $00, $C0
metasprite_07BC95:
	.byte	$04, $F0, $F2, $06
	.byte	$C0, $00, $F2, $04, $C0, $E8, $FD, $02, $C0, $F8, $02, $00, $C0
metasprite_07BCA6:
	.byte	$04, $E8, $F8
	.byte	$06, $C0, $F8, $F8, $04, $C0, $08, $F8, $02, $C0, $F3, $08, $00, $C0
	; CDL: read by draw_topdown_metasprite
metasprite_07BCB7:
	.byte	$04, $EC, $F5, $06, $C0, $FC, $F8, $04, $C0, $0C, $F8, $02, $C0, $F0, $02, $00
	.byte	$C0
metasprite_07BCC8:
	.byte	$04, $EC, $F4, $06, $C0, $FC, $F5, $04, $C0, $F2, $04, $02, $C0, $02, $FD
	.byte	$00, $C0
metasprite_07BCD9:
	.byte	$04, $EC, $F2, $06, $C0, $FC, $F2, $04, $C0, $F1, $02, $02, $C0, $01
	.byte	$FF, $00, $C0
metasprite_07BCEA:
	.byte	$04, $EE, $F0, $06, $C0, $FE, $F2, $04, $C0, $F1, $FF, $02, $C0
	.byte	$01, $00, $00, $C0
metasprite_07BCFB:
	.byte	$04, $F0, $EE, $06, $C0, $00, $F0, $04, $C0, $F0, $FE, $02
	.byte	$C0, $00, $00, $00, $C0
metasprite_07BD0C:
	.byte	$04, $F0, $EA, $06, $C0, $00, $F0, $04, $C0, $F0, $FA
	.byte	$02, $C0, $00, $00, $00, $C0
metasprite_07BD1D:
	.byte	$04, $F3, $E8, $06, $C0, $FE, $F0, $04, $C0, $EE
	.byte	$F8, $02, $C0, $FE, $00, $00, $C0
metasprite_07BD2E:
	.byte	$04, $F8, $08, $06, $00, $F8, $F8, $04, $00
	.byte	$F8, $E8, $02, $00, $E8, $F3, $00, $00
metasprite_07BD3F:
	.byte	$04, $F8, $0C, $06, $00, $F8, $FC, $04
	.byte	$00, $FB, $EC, $02, $00, $EE, $F0, $00, $00
metasprite_07BD50:
	.byte	$04, $F3, $02, $06, $00, $FB, $FC
	.byte	$04, $00, $FC, $EC, $02, $00, $EC, $F2, $00, $00
metasprite_07BD61:
	.byte	$04, $F1, $01, $06, $00, $FE
	.byte	$FD, $04, $00, $FE, $ED, $02, $00, $EE, $F1, $00, $00
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
metasprite_07BD72:
	.byte	$04, $F0, $01, $06, $00, $FE, $FE, $04, $00, $00, $EE, $02, $00, $F1, $F1, $00
	.byte	$00
metasprite_07BD83:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $02, $F0, $02, $00, $F2, $F0
	.byte	$00, $00
metasprite_07BD94:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $06, $F0, $02, $00, $F6
	.byte	$F0, $00, $00
metasprite_07BDA5:
	.byte	$04, $00, $FE, $06, $00, $F0, $FE, $04, $00, $08, $F3, $02, $00
	.byte	$F8, $EE, $00, $00
metasprite_07BDB6:
	.byte	$04, $08, $F8, $06, $00, $F8, $F8, $04, $00, $E8, $F8, $02
	.byte	$00, $FD, $E8, $00, $00
metasprite_07BDC7:
	.byte	$04, $04, $FB, $06, $00, $F4, $F8, $04, $00, $E4, $F8
	.byte	$02, $00, $00, $EE, $00, $00
metasprite_07BDD8:
	.byte	$04, $04, $FC, $06, $00, $F4, $FB, $04, $00, $FE
	.byte	$EC, $02, $00, $EE, $F3, $00, $00
metasprite_07BDE9:
	.byte	$04, $04, $FE, $06, $00, $F4, $FE, $04, $00
	.byte	$FF, $EE, $02, $00, $EF, $F1, $00, $00
metasprite_07BDFA:
	.byte	$04, $02, $00, $06, $00, $F2, $FE, $04
	.byte	$00, $FF, $F1, $02, $00, $EF, $F0, $00, $00
metasprite_07BE0B:
	.byte	$04, $00, $02, $06, $00, $F0, $00
	.byte	$04, $00, $00, $F2, $02, $00, $F0, $F0, $00, $00
metasprite_07BE1C:
	.byte	$04, $00, $06, $06, $00, $F0
	.byte	$00, $04, $00, $00, $F6, $02, $00, $F0, $F0, $00, $00
metasprite_07BE2D:
	.byte	$04, $FD, $08, $06, $00
	.byte	$F2, $00, $04, $00, $02, $F8, $02, $00, $F2, $F0, $00, $00
metasprite_07BE3E:
	.byte	$03, $F0, $F8, $04
	.byte	$40, $00, $F8, $02, $40, $F0, $E8, $00, $40
metasprite_07BE4B:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8
	.byte	$02, $40, $F0, $E8, $00, $40
metasprite_07BE58:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8, $02, $40, $F0
	.byte	$E8, $00, $40
metasprite_07BE65:
	.byte	$03, $EE, $00, $04, $40, $EE, $F0, $02, $40, $FE, $F8, $00, $40
metasprite_07BE72:
	.byte	$03, $EE, $00, $04, $40, $EE, $F0, $02, $40, $FE, $F8, $00, $40
metasprite_07BE7F:
	.byte	$03, $F8, $08
	.byte	$04, $40, $EC, $F8, $02, $40, $FC, $F8, $00, $40
metasprite_07BE8C:
	.byte	$03, $FC, $00, $04, $40, $EC
	.byte	$F9, $02, $40, $FC, $F0, $00, $40
metasprite_07BE99:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40
	.byte	$F8, $F0, $00, $40
	; CDL: read by draw_topdown_metasprite; partly not accessed
metasprite_07BEA6:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07BEB3:
	.byte	$03, $E8, $00
	.byte	$04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07BEC0:
	.byte	$03, $E8, $00, $04, $40, $F8
	.byte	$00, $02, $40, $F8, $F0, $00, $40
metasprite_07BECD:
	.byte	$03, $F0, $02, $04, $40, $00, $02, $02, $40
	.byte	$F8, $F2, $00, $40
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2
metasprite_07BEDA:
	.byte	$03, $F0, $02, $04, $40, $00, $02, $02, $40, $F8, $F2, $00, $40
metasprite_07BEE7:
	.byte	$03, $F8, $04
	.byte	$04, $40, $F8, $F4, $02, $40, $08, $F8, $00, $40
metasprite_07BEF4:
	.byte	$03, $F9, $05, $04, $40, $F0
	.byte	$F5, $02, $40, $00, $F5, $00, $40
metasprite_07BF01:
	.byte	$03, $00, $08, $04, $40, $F0, $F8, $02, $40
	.byte	$00, $F8, $00, $40
metasprite_07BF0E:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8, $02, $80, $00, $08, $00
	.byte	$80
metasprite_07BF1B:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8, $02, $80, $00, $08, $00, $80
metasprite_07BF28:
	.byte	$03, $00
	.byte	$F8, $04, $80, $F0, $F8, $02, $80, $00, $08, $00, $80
metasprite_07BF35:
	.byte	$03, $02, $F0, $04, $80, $02, $00, $02, $80, $F2, $F8, $00, $80
metasprite_07BF42:
	.byte	$03, $02, $F0
	.byte	$04, $80, $02, $00, $02, $80, $F2, $F8, $00, $80
metasprite_07BF4F:
	.byte	$03, $F8, $E8, $04, $80, $04
	.byte	$F8, $02, $80, $F4, $F8, $00, $80
metasprite_07BF5C:
	.byte	$03, $F5, $F0, $04, $80, $05, $F7, $02, $80
	.byte	$F5, $00, $00, $80
metasprite_07BF69:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00
	.byte	$80
metasprite_07BF76:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07BF83:
	.byte	$03, $08
	.byte	$F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07BF90:
	.byte	$03, $08, $F0, $04, $80
	.byte	$F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07BF9D:
	.byte	$03, $00, $EE, $04, $80, $F0, $EE, $02
	.byte	$80, $F8, $FE, $00, $80
metasprite_07BFAA:
	.byte	$03, $00, $EE, $04, $80, $F0, $EE, $02, $80, $F8, $FE
	.byte	$00, $80
metasprite_07BFB7:
	.byte	$03, $F8, $EC, $04, $80, $F8, $FC, $02, $80, $E8, $F8, $00, $80
metasprite_07BFC4:
	.byte	$03
	.byte	$F7, $EB, $04, $80, $00, $FB, $02, $80, $F0, $FB, $00, $80
metasprite_07BFD1:
	.byte	$03, $F0, $E8, $04
	.byte	$80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07BFDE:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8
	.byte	$02, $40, $F0, $E8, $00, $40
metasprite_07BFEB:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8, $02, $40, $F0
	.byte	$E8, $00, $40
metasprite_07BFF8:
	.byte	$03, $F0, $00, $04, $40, $00, $F8, $02, $40, $F0, $F0, $00, $40
metasprite_07C005:
	.byte	$03, $EF, $00, $04, $40, $FF, $F8, $02, $40, $EF, $F0, $00, $40
metasprite_07C012:
	.byte	$03, $F8, $07
	.byte	$04, $40, $EE, $F7, $02, $40, $FE, $F7, $00, $40
metasprite_07C01F:
	.byte	$03, $F8, $00, $04, $40, $E8
	.byte	$F8, $02, $40, $F8, $F0, $00, $40
metasprite_07C02C:
	.byte	$03, $F8, $00, $04, $40, $E8, $F9, $02, $40
	.byte	$F8, $F0, $00, $40
metasprite_07C039:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00
	.byte	$40
metasprite_07C046:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C053:
	.byte	$03, $E8
	.byte	$00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C060:
	.byte	$03, $F0, $00, $04, $40
	.byte	$00, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C06D:
	.byte	$03, $F0, $01, $04, $40, $00, $01, $02
	.byte	$40, $F8, $F1, $00, $40
metasprite_07C07A:
	.byte	$03, $F7, $02, $04, $40, $F7, $F2, $02, $40, $07, $F8
	.byte	$00, $40
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2
metasprite_07C087:
	.byte	$03, $F8, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C094:
	.byte	$03, $F9, $08
	.byte	$04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C0A1:
	.byte	$03, $00, $08, $04, $40, $F0
	.byte	$F8, $02, $40, $00, $F8, $00, $40
metasprite_07C0AE:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8, $02, $80
	.byte	$00, $08, $00, $80
metasprite_07C0BB:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8, $02, $80, $00, $08, $00
	.byte	$80
metasprite_07C0C8:
	.byte	$03, $00, $F0, $04, $80, $F0, $F8, $02, $80, $00, $00, $00, $80
metasprite_07C0D5:
	.byte	$03, $01
	.byte	$F0, $04, $80, $F1, $F8, $02, $80, $01, $00, $00, $80
metasprite_07C0E2:
	.byte	$03, $F8, $E9, $04, $80
	.byte	$02, $F9, $02, $80, $F2, $F9, $00, $80
metasprite_07C0EF:
	.byte	$03, $F8, $F0, $04, $80, $08, $F8, $02, $80, $F8, $00, $00, $80
metasprite_07C0FC:
	.byte	$03, $F8, $F0
	.byte	$04, $80, $08, $F7, $02, $80, $F8, $00, $00, $80
metasprite_07C109:
	.byte	$03, $08, $F0, $04, $80, $F8
	.byte	$F0, $02, $80, $F8, $00, $00, $80
metasprite_07C116:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80
	.byte	$F8, $00, $00, $80
metasprite_07C123:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00
	.byte	$80
metasprite_07C130:
	.byte	$03, $00, $F0, $04, $80, $F0, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07C13D:
	.byte	$03, $00
	.byte	$EF, $04, $80, $F0, $EF, $02, $80, $F8, $FF, $00, $80
metasprite_07C14A:
	.byte	$03, $F9, $EE, $04, $80
	.byte	$F9, $FE, $02, $80, $E9, $F8, $00, $80
metasprite_07C157:
	.byte	$03, $F8, $E8, $04, $80, $00, $F8, $02
	.byte	$80, $F0, $F8, $00, $80
metasprite_07C164:
	.byte	$03, $F7, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8
	.byte	$00, $80
metasprite_07C171:
	.byte	$03, $F0, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C17E:
	.byte	$03
	.byte	$F0, $00, $04, $40, $F0, $F0, $02, $40, $00, $F8, $00, $40
metasprite_07C18B:
	.byte	$03, $F4, $00, $04
	.byte	$40, $F4, $F0, $02, $40, $04, $F5, $00, $40
metasprite_07C198:
	.byte	$03, $F4, $04, $04, $40, $F0, $F4
	.byte	$02, $40, $00, $F4, $00, $40
metasprite_07C1A5:
	.byte	$03, $F6, $00, $04, $40, $F0, $F0, $02, $40, $00
	.byte	$F0, $00, $40
metasprite_07C1B2:
	.byte	$03, $F8, $00, $04, $40, $E8, $F8, $02, $40, $F8, $F0, $00, $40
metasprite_07C1BF:
	.byte	$03, $F8, $00, $04, $40, $E8, $F8, $02, $40, $F8, $F0, $00, $40
metasprite_07C1CC:
	.byte	$03, $F8, $00
	.byte	$04, $40, $E8, $F8, $02, $40, $F8, $F0, $00, $40
metasprite_07C1D9:
	.byte	$03, $E8, $00, $04, $40, $F8
	.byte	$00, $02, $40, $F8, $F0, $00, $40
metasprite_07C1E6:
	.byte	$03, $F0, $00, $04, $40, $00, $00, $02, $40
	.byte	$F7, $F0, $00, $40
metasprite_07C1F3:
	.byte	$03, $F0, $FC, $04, $40, $00, $FC, $02, $40, $F5, $EC, $00
	.byte	$40
metasprite_07C200:
	.byte	$03, $F4, $00, $04, $40, $F4, $F0, $02, $40, $04, $FC, $00, $40
metasprite_07C20D:
	.byte	$03, $F0
	.byte	$00, $04, $40, $F0, $F0, $02, $40, $00, $FA, $00, $40
metasprite_07C21A:
	.byte	$03, $F8, $08, $04, $40
	.byte	$F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C227:
	.byte	$03, $F8, $08, $04, $40, $F0, $F8, $02
	.byte	$40, $00, $F8, $00, $40
metasprite_07C234:
	.byte	$03, $F8, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8
	.byte	$00, $40
metasprite_07C241:
	.byte	$03, $00, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C24E:
	.byte	$03
	.byte	$00, $F0, $04, $80, $00, $00, $02, $80, $F0, $F9, $00, $80
metasprite_07C25B:
	.byte	$03, $FC, $F0, $04
	.byte	$80, $FC, $00, $02, $80, $EC, $FB, $00, $80
metasprite_07C268:
	.byte	$03, $FC, $EC, $04, $80, $00, $FC
	.byte	$02, $80, $F0, $FC, $00, $80
metasprite_07C275:
	.byte	$03, $FA, $F0, $04, $80, $00, $00, $02, $80, $F0
	.byte	$00, $00, $80
metasprite_07C282:
	.byte	$03, $F8, $F0, $04, $80, $08, $F8, $02, $80, $F8, $00, $00, $80
metasprite_07C28F:
	.byte	$03, $F8, $F0, $04, $80, $08, $F8, $02, $80, $F8, $00, $00, $80
metasprite_07C29C:
	.byte	$03, $F8, $F0
	.byte	$04, $80, $08, $F8, $02, $80, $F8, $00, $00, $80
metasprite_07C2A9:
	.byte	$03, $08, $F0, $04, $80, $F8
	.byte	$F0, $02, $80, $F8, $00, $00, $80
metasprite_07C2B6:
	.byte	$03, $00, $F0, $04, $80, $F0, $F0, $02, $80
	.byte	$F9, $00, $00, $80
metasprite_07C2C3:
	.byte	$03, $00, $F4, $04, $80, $F0, $F4, $02, $80, $FB, $04, $00
	.byte	$80
metasprite_07C2D0:
	.byte	$03, $FC, $F0, $04, $80, $FC, $00, $02, $80, $EC, $F4, $00, $80
metasprite_07C2DD:
	.byte	$03, $00
	.byte	$F0, $04, $80, $00, $00, $02, $80, $F0, $F6, $00, $80
metasprite_07C2EA:
	.byte	$03, $F8, $E8, $04, $80
	.byte	$00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C2F7:
	.byte	$03, $F8, $E8, $04, $80, $00, $F8, $02
	.byte	$80, $F0, $F8, $00, $80
metasprite_07C304:
	.byte	$03, $F8, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8
	.byte	$00, $80
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2
metasprite_07C311:
	.byte	$03, $F0, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C31E:
	.byte	$03, $F0, $F8
	.byte	$04, $40, $00, $F8, $02, $40, $F0, $E8, $00, $40
metasprite_07C32B:
	.byte	$03, $F0, $F8, $04, $40, $00
	.byte	$F8, $02, $40, $F0, $E8, $00, $40
metasprite_07C338:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8, $02, $40
	.byte	$F0, $E8, $00, $40
metasprite_07C345:
	.byte	$03, $EF, $00, $04, $40, $EF, $F0, $02, $40, $FF, $F8, $00
	.byte	$40
metasprite_07C352:
	.byte	$03, $EE, $00, $04, $40, $EE, $F0, $02, $40, $FE, $F7, $00, $40
metasprite_07C35F:
	.byte	$03, $E9, $F8
	.byte	$04, $40, $F9, $00, $02, $40, $F9, $F0, $00, $40
metasprite_07C36C:
	.byte	$03, $E9, $F9, $04, $40, $F9
	.byte	$00, $02, $40, $F9, $F0, $00, $40
metasprite_07C379:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40
	.byte	$F8, $F0, $00, $40
metasprite_07C386:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00
	.byte	$40
metasprite_07C393:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C3A0:
	.byte	$03, $E8
	.byte	$00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C3AD:
	.byte	$03, $F0, $01, $04, $40
	.byte	$00, $01, $02, $40, $F8, $F1, $00, $40
metasprite_07C3BA:
	.byte	$03, $F0, $02, $04, $40, $00, $02, $02
	.byte	$40, $F7, $F2, $00, $40
metasprite_07C3C7:
	.byte	$03, $F8, $07, $04, $40, $F0, $F7, $02, $40, $00, $F7
	.byte	$00, $40
metasprite_07C3D4:
	.byte	$03, $F9, $07, $04, $40, $F0, $F7, $02, $40, $00, $F7, $00, $40
metasprite_07C3E1:
	.byte	$03
	.byte	$00, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C3EE:
	.byte	$03, $00, $F8, $04
	.byte	$80, $F0, $F8, $02, $80, $00, $08, $00, $80
metasprite_07C3FB:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8
	.byte	$02, $80, $00, $08, $00, $80
metasprite_07C408:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8, $02, $80, $00
	.byte	$08, $00, $80
metasprite_07C415:
	.byte	$03, $01, $F0, $04, $80, $01, $00, $02, $80, $F1, $F8, $00, $80
metasprite_07C422:
	.byte	$03, $02, $F0, $04, $80, $02, $00, $02, $80, $F2, $F9, $00, $80
metasprite_07C42F:
	.byte	$03, $07, $F8
	.byte	$04, $80, $F7, $F0, $02, $80, $F7, $00, $00, $80
metasprite_07C43C:
	.byte	$03, $07, $F7, $04, $80, $F7
	.byte	$F0, $02, $80, $F7, $00, $00, $80
metasprite_07C449:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80
	.byte	$F8, $00, $00, $80
metasprite_07C456:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00
	.byte	$80
metasprite_07C463:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07C470:
	.byte	$03, $08
	.byte	$F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07C47D:
	.byte	$03, $00, $EF, $04, $80
	.byte	$F0, $EF, $02, $80, $F8, $FF, $00, $80
metasprite_07C48A:
	.byte	$03, $00, $EE, $04, $80, $F0, $EE, $02
	.byte	$80, $F9, $FE, $00, $80
metasprite_07C497:
	.byte	$03, $F8, $E9, $04, $80, $00, $F9, $02, $80, $F0, $F9
	.byte	$00, $80
metasprite_07C4A4:
	.byte	$03, $F7, $E9, $04, $80, $00, $F9, $02, $80, $F0, $F9, $00, $80
metasprite_07C4B1:
	.byte	$03
	.byte	$F0, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C4BE:
	.byte	$03, $F0, $F8, $04
	.byte	$40, $00, $F8, $02, $40, $F0, $E8, $00, $40
metasprite_07C4CB:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8
	.byte	$02, $40, $F0, $E8, $00, $40
metasprite_07C4D8:
	.byte	$03, $F0, $F9, $04, $40, $00, $F8, $02, $40, $F0
	.byte	$E9, $00, $40
metasprite_07C4E5:
	.byte	$03, $EF, $00, $04, $40, $EF, $F0, $02, $40, $FF, $F8, $00, $40
metasprite_07C4F2:
	.byte	$03, $F4, $07, $04, $40, $EC, $F7, $02, $40, $FC, $F7, $00, $40
metasprite_07C4FF:
	.byte	$03, $E9, $F9
	.byte	$04, $40, $F9, $00, $02, $40, $F9, $F0, $00, $40
metasprite_07C50C:
	.byte	$03, $E8, $F8, $04, $40, $F8
	.byte	$00, $02, $40, $F8, $F0, $00, $40
metasprite_07C519:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40
	.byte	$F8, $F0, $00, $40
metasprite_07C526:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00
	.byte	$40
metasprite_07C533:
	.byte	$03, $E8, $00, $04, $40, $F8, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C540:
	.byte	$03, $E9
	.byte	$00, $04, $40, $F9, $00, $02, $40, $F8, $F0, $00, $40
metasprite_07C54D:
	.byte	$03, $F0, $01, $04, $40
	.byte	$00, $01, $02, $40, $F8, $F1, $00, $40
metasprite_07C55A:
	.byte	$03, $F7, $04, $04, $40, $F7, $F4, $02
	.byte	$40, $07, $FC, $00, $40
metasprite_07C567:
	.byte	$03, $F9, $07, $04, $40, $F0, $F7, $02, $40, $00, $F7
	.byte	$00, $40
metasprite_07C574:
	.byte	$03, $F8, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C581:
	.byte	$03
	.byte	$00, $08, $04, $40, $F0, $F8, $02, $40, $00, $F8, $00, $40
metasprite_07C58E:
	.byte	$03, $00, $F8, $04
	.byte	$80, $F0, $F8, $02, $80, $00, $08, $00, $80
metasprite_07C59B:
	.byte	$03, $00, $F8, $04, $80, $F0, $F8
	.byte	$02, $80, $00, $08, $00, $80
metasprite_07C5A8:
	.byte	$03, $00, $F7, $04, $80, $F0, $F8, $02, $80, $00
	.byte	$07, $00, $80
metasprite_07C5B5:
	.byte	$03, $01, $F0, $04, $80, $01, $00, $02, $80, $F1, $F8, $00, $80
metasprite_07C5C2:
	.byte	$03, $FC, $E9, $04, $80, $04, $F9, $02, $80, $F4, $F9, $00, $80
metasprite_07C5CF:
	.byte	$03, $07, $F7
	.byte	$04, $80, $F7, $F0, $02, $80, $F7, $00, $00, $80
metasprite_07C5DC:
	.byte	$03, $08, $F8, $04, $80, $F8
	.byte	$F0, $02, $80, $F8, $00, $00, $80
metasprite_07C5E9:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80
	.byte	$F8, $00, $00, $80
metasprite_07C5F6:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00
	.byte	$80
metasprite_07C603:
	.byte	$03, $08, $F0, $04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07C610:
	.byte	$03, $07
	.byte	$F0, $04, $80, $F7, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07C61D:
	.byte	$03, $00, $EF, $04, $80
	.byte	$F0, $EF, $02, $80, $F8, $FF, $00, $80
metasprite_07C62A:
	.byte	$03, $F9, $EC, $04, $80, $F9, $FC, $02
	.byte	$80, $E9, $F4, $00, $80
metasprite_07C637:
	.byte	$03, $F7, $E9, $04, $80, $00, $F9, $02, $80, $F0, $F9
	.byte	$00, $80
metasprite_07C644:
	.byte	$03, $F8, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C651:
	.byte	$03
	.byte	$F0, $E8, $04, $80, $00, $F8, $02, $80, $F0, $F8, $00, $80
metasprite_07C65E:
	.byte	$03, $F8, $00, $04
	.byte	$00, $F8, $F0, $02, $00, $F8, $E0, $00, $00
metasprite_07C66B:
	.byte	$03, $F7, $00, $04, $00, $FA, $F0
	.byte	$02, $00, $F8, $E0, $00, $00
metasprite_07C678:
	.byte	$03, $F5, $FF, $04, $00, $FB, $F0, $02, $00, $00
	.byte	$EA, $00, $00
metasprite_07C685:
	.byte	$03, $F5, $FD, $04, $00, $FD, $F8, $02, $00, $FE, $EC, $00, $00
metasprite_07C692:
	.byte	$03, $F3, $FD, $04, $00, $FD, $F6, $02, $00, $FF, $EE, $00, $00
metasprite_07C69F:
	.byte	$03, $FE, $00
	.byte	$04, $00, $F1, $FB, $02, $00, $01, $F0, $00, $00
metasprite_07C6AC:
	.byte	$03, $F0, $FB, $04, $00, $00
	.byte	$F8, $02, $00, $03, $E8, $00, $00
metasprite_07C6B9:
	.byte	$03, $10, $F8, $04, $00, $00, $F7, $02, $00
	.byte	$F3, $FA, $00, $00
metasprite_07C6C6:
	.byte	$03, $10, $F8, $04, $00, $00, $F8, $02, $00, $F0, $F8, $00
	.byte	$00
metasprite_07C6D3:
	.byte	$03, $10, $F8, $04, $00, $00, $FA, $02, $00, $F0, $F7, $00, $00
metasprite_07C6E0:
	.byte	$03, $06
	.byte	$00, $04, $00, $00, $FB, $02, $00, $F1, $F5, $00, $00
metasprite_07C6ED:
	.byte	$03, $04, $FE, $04, $00
	.byte	$F8, $FD, $02, $00, $F3, $F5, $00, $00
metasprite_07C6FA:
	.byte	$03, $02, $FF, $04, $00, $FB, $FD, $02
	.byte	$00, $F3, $F3, $00, $00
metasprite_07C707:
	.byte	$03, $00, $01, $04, $00, $F0, $FE, $02, $00, $F5, $F1
	; CDL: read by draw_topdown_metasprite_p2; partly not accessed
	.byte	$00, $00
metasprite_07C714:
	.byte	$03, $08, $03, $04, $00, $F8, $00, $02, $00, $F5, $F0, $00, $00
metasprite_07C721:
	.byte	$03
	.byte	$F8, $10, $04, $00, $F9, $00, $02, $00, $F6, $F3, $00, $00
metasprite_07C72E:
	.byte	$03, $F8, $F0, $04
	.byte	$C0, $F8, $00, $02, $C0, $F8, $10, $00, $C0
metasprite_07C73B:
	.byte	$03, $F9, $F0, $04, $C0, $F6, $00
	.byte	$02, $C0, $F8, $10, $00, $C0
metasprite_07C748:
	.byte	$03, $FB, $F1, $04, $C0, $F5, $00, $02, $C0, $F0
	.byte	$06, $00, $C0
metasprite_07C755:
	.byte	$03, $FB, $F3, $04, $C0, $F3, $F8, $02, $C0, $F2, $04, $00, $C0
metasprite_07C762:
	.byte	$03, $FD, $F3, $04, $C0, $F3, $FA, $02, $C0, $F1, $02, $00, $C0
metasprite_07C76F:
	.byte	$03, $F2, $F0
	.byte	$04, $C0, $FF, $F5, $02, $C0, $EF, $00, $00, $C0
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
metasprite_07C77C:
	.byte	$03, $00, $F5, $04, $C0, $F0, $F8, $02, $C0, $ED, $08, $00, $C0
metasprite_07C789:
	.byte	$03, $E0, $F8
	.byte	$04, $C0, $F0, $F9, $02, $C0, $FD, $F6, $00, $C0
metasprite_07C796:
	.byte	$03, $E0, $F8, $04, $C0, $F0
	.byte	$F8, $02, $C0, $00, $F8, $00, $C0
metasprite_07C7A3:
	.byte	$03, $E0, $F8, $04, $C0, $F0, $F6, $02, $C0
	.byte	$00, $F9, $00, $C0
metasprite_07C7B0:
	.byte	$03, $EA, $F0, $04, $C0, $F0, $F5, $02, $C0, $FF, $FB, $00
	.byte	$C0
metasprite_07C7BD:
	.byte	$03, $EC, $F2, $04, $C0, $F8, $F3, $02, $C0, $FD, $FB, $00, $C0
metasprite_07C7CA:
	.byte	$03, $EE
	.byte	$F1, $04, $C0, $F5, $F3, $02, $C0, $FD, $FD, $00, $C0
metasprite_07C7D7:
	.byte	$03, $F0, $EF, $04, $C0
	.byte	$00, $F2, $02, $C0, $FB, $FF, $00, $C0
metasprite_07C7E4:
	.byte	$03, $E8, $ED, $04, $C0, $F8, $F0, $02
	.byte	$C0, $FB, $00, $00, $C0
metasprite_07C7F1:
	.byte	$03, $F8, $E0, $04, $C0, $F7, $F0, $02, $C0, $FA, $FD
	.byte	$00, $C0
metasprite_07C7FE:
	.byte	$03, $F8, $04, $04, $00, $F8, $F4, $02, $00, $F8, $E4, $00, $00
metasprite_07C80B:
	.byte	$04, $F5, $04, $06, $00, $F8, $00, $04, $00, $FA, $F0, $02, $00, $FA, $E0, $00
	.byte	$00
metasprite_07C81C:
	.byte	$04, $F3, $05, $06, $00, $F7, $01, $04, $00, $FB, $F6, $02, $00, $FC, $E6
	.byte	$00, $00
metasprite_07C82D:
	.byte	$04, $F1, $03, $06, $00, $F4, $FC, $04, $00, $FE, $F8, $02, $00, $FE
	.byte	$E8, $00, $00
metasprite_07C83E:
	.byte	$04, $EF, $01, $06, $00, $F5, $FB, $04, $00, $FF, $F3, $02, $00
	.byte	$02, $EA, $00, $00
metasprite_07C84F:
	.byte	$04, $ED, $00, $06, $00, $F5, $FC, $04, $00, $00, $F4, $02
	.byte	$00, $06, $EE, $00, $00
metasprite_07C860:
	.byte	$04, $EB, $FE, $06, $00, $F4, $FB, $04, $00, $00, $F5
	.byte	$02, $00, $09, $F1, $00, $00
metasprite_07C871:
	.byte	$04, $F2, $04, $06, $00, $0C, $F6, $04, $00, $FC
	.byte	$F6, $02, $00, $EC, $FA, $00, $00
metasprite_07C882:
	.byte	$03, $0C, $F8, $04, $00, $FC, $F8, $02, $00
	.byte	$EC, $F8, $00, $00
metasprite_07C88F:
	.byte	$04, $10, $FA, $06, $00, $00, $FA, $04, $00, $F0, $F8, $02
	.byte	$00, $EC, $F5, $00, $00
metasprite_07C8A0:
	.byte	$04, $0A, $FC, $06, $00, $FA, $FB, $04, $00, $F0, $F7
	.byte	$02, $00, $EC, $F3, $00, $00
metasprite_07C8B1:
	.byte	$04, $08, $FE, $06, $00, $F8, $FE, $04, $00, $F4
	.byte	$F4, $02, $00, $ED, $F1, $00, $00
metasprite_07C8C2:
	.byte	$04, $06, $02, $06, $00, $FD, $FF, $04, $00
	.byte	$F5, $F5, $02, $00, $EF, $EF, $00, $00
metasprite_07C8D3:
	.byte	$04, $02, $06, $06, $00, $FC, $00, $04
	.byte	$00, $F4, $F5, $02, $00, $F0, $ED, $00, $00
metasprite_07C8E4:
	.byte	$04, $FF, $09, $06, $00, $FB, $00
	.byte	$04, $00, $F5, $F4, $02, $00, $F2, $EB, $00, $00
metasprite_07C8F5:
	.byte	$04, $FA, $0C, $06, $00, $FA
	.byte	$FC, $04, $00, $F6, $EC, $02, $00, $EC, $F2, $00, $00
metasprite_07C906:
	.byte	$03, $F8, $EC, $04, $C0
	.byte	$F8, $FC, $02, $C0, $F8, $0C, $00, $C0
metasprite_07C913:
	.byte	$04, $FB, $EC, $06, $C0, $F8, $F0, $04
	.byte	$C0, $F6, $00, $02, $C0, $F6, $10, $00, $C0
metasprite_07C924:
	.byte	$04, $FD, $EB, $06, $C0, $F9, $EF
	.byte	$04, $C0, $F5, $FA, $02, $C0, $F4, $0A, $00, $C0
metasprite_07C935:
	.byte	$04, $FF, $ED, $06, $C0, $FC
	.byte	$F4, $04, $C0, $F2, $F8, $02, $C0, $F2, $08, $00, $C0
metasprite_07C946:
	.byte	$04, $01, $EF, $06, $C0
	.byte	$FB, $F5, $04, $C0, $F1, $FD, $02, $C0, $EE, $06, $00, $C0
metasprite_07C957:
	.byte	$04, $03, $F0, $06
	.byte	$C0, $FB, $F4, $04, $C0, $F0, $FC, $02, $C0, $EA, $02, $00, $C0
	; CDL: read by draw_topdown_metasprite; partly not accessed
metasprite_07C968:
	.byte	$04, $05, $F2, $06, $C0, $FC, $F5, $04, $C0, $F0, $FB, $02, $C0, $E7, $FF, $00
	.byte	$C0
metasprite_07C979:
	.byte	$04, $FE, $EC, $06, $C0, $E4, $FA, $04, $C0, $F4, $FA, $02, $C0, $04, $F6
	.byte	$00, $C0
metasprite_07C98A:
	.byte	$03, $E4, $F8, $04, $C0, $F4, $F8, $02, $C0, $04, $F8, $00, $C0
	; CDL: read by draw_topdown_metasprite_p2; partly not accessed
metasprite_07C997:
	.byte	$04, $E0, $F6, $06, $C0, $F0, $F6, $04, $C0, $00, $F8, $02, $C0, $04, $FB, $00
	.byte	$C0
metasprite_07C9A8:
	.byte	$04, $E6, $F4, $06, $C0, $F6, $F5, $04, $C0, $00, $F9, $02, $C0, $04, $FD
	.byte	$00, $C0
metasprite_07C9B9:
	.byte	$04, $E8, $F2, $06, $C0, $F8, $F2, $04, $C0, $FC, $FC, $02, $C0, $03
	.byte	$FF, $00, $C0
metasprite_07C9CA:
	.byte	$04, $EA, $EE, $06, $C0, $F3, $F1, $04, $C0, $FB, $FB, $02, $C0
	.byte	$01, $01
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
	.byte	$00, $C0
metasprite_07C9DB:
	.byte	$04, $EE, $EA, $06, $C0, $F4, $F0, $04, $C0, $FC, $FB, $02, $C0, $00
	.byte	$03, $00, $C0
metasprite_07C9EC:
	.byte	$04, $F1, $E7, $06, $C0, $F5, $F0, $04, $C0, $FB, $FC, $02, $C0
	.byte	$FE, $05, $00, $C0
metasprite_07C9FD:
	.byte	$04, $F6, $E4, $06, $C0, $F6, $F4, $04, $C0, $FA, $04, $02
	.byte	$C0, $04, $FE, $00, $C0
metasprite_07CA0E:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00
	.byte	$02, $80, $F0, $00, $00, $80
	; CDL: read by draw_topdown_metasprite; partly not accessed
metasprite_07CA1F:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00
	.byte	$80
metasprite_07CA30:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00
	.byte	$00, $80
metasprite_07CA41:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0
	.byte	$00, $00, $80
metasprite_07CA52:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80
	.byte	$F0, $00, $00, $80
metasprite_07CA63:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02
	.byte	$80, $F0, $00, $00, $80
metasprite_07CA74:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00
	.byte	$02, $80, $F0, $00, $00, $80
metasprite_07CA85:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00
	.byte	$00, $02, $80, $F0, $00, $00, $80
metasprite_07CA96:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80
	.byte	$00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07CAA7:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04
	.byte	$80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07CAB8:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0
	.byte	$04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07CAC9:
	.byte	$04, $00, $F0, $06, $80, $F0
	.byte	$F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07CADA:
	.byte	$04, $00, $F0, $06, $80
	.byte	$F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
	; CDL: read by draw_topdown_metasprite_p2
metasprite_07CAEB:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00
	.byte	$80
metasprite_07CAFC:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00
	.byte	$00, $80
metasprite_07CB0D:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0
	.byte	$00, $00, $80
metasprite_07CB1E:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02, $40
	.byte	$00, $F0, $00, $40
metasprite_07CB2F:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02
	.byte	$40, $00, $F0, $00, $40
metasprite_07CB40:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0
	.byte	$02, $40, $00, $F0, $00, $40
metasprite_07CB51:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0
	.byte	$F0, $02, $40, $00, $F0, $00, $40
metasprite_07CB62:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40
	.byte	$F0, $F0, $02, $40, $00, $F0, $00, $40
metasprite_07CB73:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04
	.byte	$40, $F0, $F0, $02, $40, $00, $F0, $00, $40
metasprite_07CB84:
	.byte	$04, $F0, $00, $06, $40, $00, $00
	.byte	$04, $40, $F0, $F0, $02, $40, $00, $F0, $00, $40
metasprite_07CB95:
	.byte	$04, $F0, $00, $06, $40, $00
	.byte	$00, $04, $40, $F0, $F0, $02, $40, $00, $F0, $00, $40
	; CDL: read by draw_topdown_metasprite
metasprite_07CBA6:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02, $40, $00, $F0, $00
	.byte	$40
metasprite_07CBB7:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02, $40, $00, $F0
	.byte	$00, $40
metasprite_07CBC8:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02, $40, $00
	.byte	$F0, $00, $40
metasprite_07CBD9:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02, $40
	.byte	$00, $F0, $00, $40
metasprite_07CBEA:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0, $02
	.byte	$40, $00, $F0, $00, $40
metasprite_07CBFB:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0, $F0
	.byte	$02, $40, $00, $F0, $00, $40
metasprite_07CC0C:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $F0
	.byte	$F0, $02, $40, $00, $F0, $00, $40
metasprite_07CC1D:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40
	.byte	$F0, $F0, $02, $40, $00, $F0, $00, $40
	; CDL: read by draw_topdown_metasprite_p2
metasprite_07CC2E:
	.byte	$04, $F8, $E8, $06, $80, $F8, $F8, $04, $80, $F8, $08, $02, $80, $E8, $FD, $00
	.byte	$80
metasprite_07CC3F:
	.byte	$04, $F8, $E4, $06, $80, $F8, $F4, $04, $80, $FB, $04, $02, $80, $EE, $00
	.byte	$00, $80
metasprite_07CC50:
	.byte	$04, $F3, $EE, $06, $80, $FB, $F4, $04, $80, $FC, $04, $02, $80, $EC
	.byte	$FE, $00, $80
metasprite_07CC61:
	.byte	$04, $F1, $EF, $06, $80, $FE, $F4, $04, $80, $FE, $04, $02, $80
	.byte	$EE, $FF, $00, $80
metasprite_07CC72:
	.byte	$04, $F0, $EF, $06, $80, $FE, $F2, $04, $80, $00, $02, $02
	.byte	$80, $F1, $FF, $00, $80
metasprite_07CC83:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $02, $00
	.byte	$02, $80, $F2, $00, $00, $80
metasprite_07CC94:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $06
	.byte	$00, $02, $80, $F6, $00, $00, $80
metasprite_07CCA5:
	.byte	$04, $00, $F2, $06, $80, $F0, $F2, $04, $80
	.byte	$08, $FD, $02, $80, $F8, $02, $00, $80
metasprite_07CCB6:
	.byte	$04, $08, $F8, $06, $80, $F8, $F8, $04
	.byte	$80, $E8, $F8, $02, $80, $FD, $08, $00, $80
metasprite_07CCC7:
	.byte	$04, $04, $F5, $06, $80, $F4, $F8
	.byte	$04, $80, $E4, $F8, $02, $80, $00, $02, $00, $80
metasprite_07CCD8:
	.byte	$04, $04, $F4, $06, $80, $F4
	.byte	$F5, $04, $80, $FE, $04, $02, $80, $EE, $FD, $00, $80
metasprite_07CCE9:
	.byte	$04, $04, $F2, $06, $80
	.byte	$F4, $F2, $04, $80, $FF, $02, $02, $80, $EF, $FF, $00, $80
metasprite_07CCFA:
	.byte	$04, $02, $F0, $06
	.byte	$80, $F2, $F2, $04, $80, $FF, $FF, $02, $80, $EF, $00, $00, $80
	; CDL: read by draw_topdown_metasprite
metasprite_07CD0B:
	.byte	$04, $00, $EE, $06, $80, $F0, $F0, $04, $80, $00, $FE, $02, $80, $F0, $00, $00
	.byte	$80
metasprite_07CD1C:
	.byte	$04, $00, $EA, $06, $80, $F0, $F0, $04, $80, $00, $FA, $02, $80, $F0, $00
	.byte	$00, $80
metasprite_07CD2D:
	.byte	$04, $FD, $E8, $06, $80, $F2, $F0, $04, $80, $02, $F8, $02, $80, $F2
	.byte	$00, $00, $80
metasprite_07CD3E:
	.byte	$04, $F8, $08, $06, $40, $F8, $F8, $04, $40, $F8, $E8, $02, $40
	.byte	$08, $F3, $00, $40
metasprite_07CD4F:
	.byte	$04, $F8, $0C, $06, $40, $F8, $FC, $04, $40, $F5, $EC, $02
	.byte	$40, $02, $F0, $00, $40
metasprite_07CD60:
	.byte	$04, $FD, $02, $06, $40, $F5, $FC, $04, $40, $F4, $EC
	.byte	$02, $40, $04, $F2, $00, $40
metasprite_07CD71:
	.byte	$04, $FF, $01, $06, $40, $F2, $FD, $04, $40, $F2
	.byte	$ED, $02, $40, $02, $F1, $00, $40
metasprite_07CD82:
	.byte	$04, $00, $01, $06, $40, $F2, $FE, $04, $40
	.byte	$F0, $EE, $02, $40, $FF, $F1, $00, $40
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
metasprite_07CD93:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $EE, $F0, $02, $40, $FE, $F0, $00
	.byte	$40
metasprite_07CDA4:
	.byte	$04, $F0, $00, $06, $40, $00, $00, $04, $40, $EA, $F0, $02, $40, $FA, $F0
	.byte	$00, $40
metasprite_07CDB5:
	.byte	$04, $F0, $FE, $06, $40, $00, $FE, $04, $40, $E8, $F3, $02, $40, $F8
	.byte	$EE, $00, $40
metasprite_07CDC6:
	.byte	$04, $E8, $F8, $06, $40, $F8, $F8, $04, $40, $08, $F8, $02, $40
	.byte	$F3, $E8, $00, $40
metasprite_07CDD7:
	.byte	$04, $EC, $FB, $06, $40, $FC, $F8, $04, $40, $0C, $F8, $02
	.byte	$40, $F0, $EE, $00, $40
metasprite_07CDE8:
	.byte	$04, $EC, $FC, $06, $40, $FC, $FB, $04, $40, $F2, $EC
	.byte	$02, $40, $02, $F3, $00, $40
metasprite_07CDF9:
	.byte	$04, $EC, $FE, $06, $40, $FC, $FE, $04, $40, $F1
	.byte	$EE, $02, $40, $01, $F1, $00, $40
metasprite_07CE0A:
	.byte	$04, $EE, $00, $06, $40, $FE, $FE, $04, $40
	.byte	$F1, $F1, $02, $40, $01, $F0, $00, $40
metasprite_07CE1B:
	.byte	$04, $F0, $02, $06, $40, $00, $00, $04
	.byte	$40, $F0, $F2, $02, $40, $00, $F0, $00, $40
metasprite_07CE2C:
	.byte	$04, $F0, $06, $06, $40, $00, $00
	.byte	$04, $40, $F0, $F6, $02, $40, $00, $F0, $00, $40
metasprite_07CE3D:
	.byte	$04, $F3, $08, $06, $40, $FE
	.byte	$00, $04, $40, $EE, $F8, $02, $40, $FE, $F0, $00, $40
	; CDL: read by draw_topdown_metasprite
metasprite_07CE4E:
	.byte	$02, $F8, $0C, $02, $00, $F8, $FC, $00, $00
metasprite_07CE57:
	.byte	$02, $F8, $0C, $02, $00, $F8, $FC
	.byte	$00, $00
metasprite_07CE60:
	.byte	$02, $F0, $0C, $02, $00, $F4, $FC, $00, $00
metasprite_07CE69:
	.byte	$02, $EF, $0C, $02, $00
	.byte	$F3, $FC, $00, $00
metasprite_07CE72:
	.byte	$02, $EB, $06, $02, $00, $F3, $FB, $00, $00
metasprite_07CE7B:
	.byte	$02, $E9, $06
	.byte	$02, $00, $F3, $FD, $00, $00
metasprite_07CE84:
	.byte	$02, $E7, $02, $02, $00, $F4, $FC, $00, $00
metasprite_07CE8D:
	.byte	$02
	.byte	$E4, $FE, $02, $00, $F4, $FB, $00, $00
metasprite_07CE96:
	.byte	$02, $E4, $F8, $02, $00, $F4, $F8, $00
	.byte	$00
metasprite_07CE9F:
	.byte	$02, $E4, $F1, $02, $80, $F4, $F4, $00, $80
metasprite_07CEA8:
	.byte	$02, $E7, $EF, $02, $80, $F4
	.byte	$F4, $00, $80
metasprite_07CEB1:
	.byte	$02, $EA, $EA, $02, $80, $F4, $F3, $00, $80
metasprite_07CEBA:
	.byte	$02, $ED, $EA, $02
	.byte	$80, $F5, $F5, $00, $80
metasprite_07CEC3:
	.byte	$02, $F0, $E3, $02, $80, $F4, $F3, $00, $80
metasprite_07CECC:
	.byte	$02, $F1
	.byte	$E3, $02, $80, $F5, $F3, $00, $80
metasprite_07CED5:
	.byte	$02, $F8, $E3, $02, $80, $F8, $F3, $00, $80
metasprite_07CEDE:
	.byte	$02, $F8, $E4, $02, $80, $F8, $F4, $00, $80
metasprite_07CEE7:
	.byte	$02, $F8, $F4, $00, $C0, $F8, $E4
	.byte	$02, $C0
metasprite_07CEF0:
	.byte	$02, $FC, $F4, $00, $C0, $00, $E4, $02, $C0
metasprite_07CEF9:
	.byte	$02, $FD, $F4, $00, $C0
	.byte	$01, $E4, $02, $C0
metasprite_07CF02:
	.byte	$02, $FD, $F5, $00, $C0, $05, $EA, $02, $C0
metasprite_07CF0B:
	.byte	$02, $FD, $F3
	.byte	$00, $C0, $07, $EA, $02, $C0
metasprite_07CF14:
	.byte	$02, $FC, $F4, $00, $C0, $09, $EF, $02, $C0
metasprite_07CF1D:
	.byte	$02
	.byte	$0C, $F2, $02, $C0, $FC, $F5, $00, $C0
metasprite_07CF26:
	.byte	$02, $0C, $F8, $02, $C0, $FC, $F8, $00
	.byte	$C0
metasprite_07CF2F:
	.byte	$02, $0C, $FF, $02, $40, $FC, $FC, $00, $40
metasprite_07CF38:
	.byte	$02, $09, $01, $02, $40, $FC
	.byte	$FC, $00, $40
metasprite_07CF41:
	.byte	$02, $06, $06, $02, $40, $FC, $FD, $00, $40
metasprite_07CF4A:
	.byte	$02, $03, $06, $02
	.byte	$40, $FB, $FB, $00, $40
metasprite_07CF53:
	.byte	$02, $00, $0D, $02, $40, $FC, $FD, $00, $40
metasprite_07CF5C:
	.byte	$02, $FF
	.byte	$0D, $02, $40, $FB, $FD, $00, $40
metasprite_07CF65:
	.byte	$02, $F8, $0D, $02, $40, $F8, $FD, $00, $40
metasprite_07CF6E:
	.byte	$02, $F8, $00, $00, $C0, $F8, $F0, $00, $00
metasprite_07CF77:
	.byte	$02, $F8, $00, $00, $C0, $F8, $F0
	.byte	$00, $00
metasprite_07CF80:
	.byte	$02, $F8, $00, $00, $C0, $F8, $F0, $00, $00
metasprite_07CF89:
	.byte	$02, $F4, $00, $00, $C0
	.byte	$FC, $F0, $00, $00
metasprite_07CF92:
	.byte	$02, $F0, $FC, $00, $C0, $00, $F4, $00, $00
metasprite_07CF9B:
	.byte	$02, $F0, $FC
	.byte	$00, $C0, $00, $F4, $00, $00
metasprite_07CFA4:
	.byte	$02, $F0, $F8, $00, $C0, $00, $F8, $00, $00
metasprite_07CFAD:
	.byte	$02
	.byte	$F0, $F8, $00, $C0, $00, $F8, $00, $00
metasprite_07CFB6:
	.byte	$02, $F0, $F8, $00, $C0, $00, $F8, $00
	.byte	$00
metasprite_07CFBF:
	.byte	$02, $F0, $F8, $00, $40, $00, $F8, $00, $80
metasprite_07CFC8:
	.byte	$02, $F0, $F8, $00, $40, $00
	.byte	$F8, $00, $80
metasprite_07CFD1:
	.byte	$02, $F0, $F4, $00, $40, $00, $FC, $00, $80
metasprite_07CFDA:
	.byte	$02, $F0, $F4, $00
	.byte	$40, $00, $FC, $00, $80
metasprite_07CFE3:
	.byte	$02, $FC, $00, $00, $80, $F4, $F0, $00, $40
metasprite_07CFEC:
	.byte	$02, $F8
	.byte	$00, $00, $80, $F8, $F0, $00, $40
metasprite_07CFF5:
	.byte	$02, $F8, $00, $00, $80, $F8, $F0, $00, $40
metasprite_07CFFE:
	.byte	$02, $F8, $F8, $02, $00, $F8, $E8, $00, $00
metasprite_07D007:
	.byte	$03, $00, $F8, $04, $00, $F0, $F8
	.byte	$02, $00, $FB, $E8, $00, $00
metasprite_07D014:
	.byte	$03, $00, $F9, $04, $00, $F0, $F9, $02, $00, $FC
	.byte	$E9, $00, $00
metasprite_07D021:
	.byte	$03, $08, $F8, $04, $00, $F8, $F8, $02, $00, $FF, $E8, $00, $00
metasprite_07D02E:
	.byte	$03, $08, $F2, $04, $00, $00, $EF, $02, $00, $F8, $F8, $00, $00
metasprite_07D03B:
	.byte	$03, $08, $F1
	.byte	$04, $00, $F8, $F8, $02, $00, $F8, $E8, $00, $00
metasprite_07D048:
	.byte	$03, $07, $F4, $04, $00, $F7
	.byte	$00, $02, $00, $F7, $F0, $00, $00
metasprite_07D055:
	.byte	$03, $08, $F5, $04, $00, $F8, $00, $02, $00
	.byte	$F8, $F0, $00, $00
metasprite_07D062:
	.byte	$02, $08, $F8, $02, $00, $F8, $F8, $00, $00
metasprite_07D06B:
	.byte	$03, $08, $FB
	.byte	$04, $80, $F8, $F0, $02, $80, $F8, $00, $00, $80
metasprite_07D078:
	.byte	$03, $07, $FC, $04, $80, $F7
	.byte	$F0, $02, $80, $F7, $00, $00, $80
metasprite_07D085:
	.byte	$03, $08, $FF, $04, $80, $F8, $F8, $02, $80
	.byte	$F8, $08, $00, $80
metasprite_07D092:
	.byte	$03, $08, $FE, $04, $80, $00, $01, $02, $80, $F8, $F8, $00
	.byte	$80
metasprite_07D09F:
	.byte	$03, $08, $F8, $04, $80, $F8, $F8, $02, $80, $FF, $08, $00, $80
metasprite_07D0AC:
	.byte	$03, $00
	.byte	$F7, $04, $80, $F0, $F7, $02, $80, $FC, $07, $00, $80
metasprite_07D0B9:
	.byte	$03, $00, $F8, $04, $80
	.byte	$F0, $F8, $02, $80, $FB, $08, $00, $80
metasprite_07D0C6:
	.byte	$02, $F8, $F8, $02, $C0, $F8, $08, $00
	.byte	$C0
metasprite_07D0CF:
	.byte	$03, $F0, $F8, $04, $C0, $00, $F8, $02, $C0, $F5, $08, $00, $C0
metasprite_07D0DC:
	.byte	$03, $F0
	.byte	$F7, $04, $C0, $00, $F7, $02, $C0, $F4, $07, $00, $C0
metasprite_07D0E9:
	.byte	$03, $E8, $F8, $04, $C0
	.byte	$F8, $F8, $02, $C0, $F1, $08, $00, $C0
metasprite_07D0F6:
	.byte	$03, $E8, $FE, $04, $C0, $F0, $01, $02
	.byte	$C0, $F8, $F8, $00, $C0
metasprite_07D103:
	.byte	$03, $E8, $FF, $04, $C0, $F8, $F8, $02, $C0, $F8, $08
	.byte	$00, $C0
metasprite_07D110:
	.byte	$03, $E9, $FC, $04, $C0, $F9, $F0, $02, $C0, $F9, $00, $00, $C0
metasprite_07D11D:
	.byte	$03
	.byte	$E8, $FB, $04, $C0, $F8, $F0, $02, $C0, $F8, $00, $00, $C0
metasprite_07D12A:
	.byte	$02, $E8, $F8, $02
	.byte	$C0, $F8, $F8, $00, $C0
metasprite_07D133:
	.byte	$03, $E8, $F5, $04, $40, $F8, $00, $02, $40, $F8, $F0
	.byte	$00, $40
metasprite_07D140:
	.byte	$03, $E9, $F4, $04, $40, $F9, $00, $02, $40, $F9, $F0, $00, $40
metasprite_07D14D:
	.byte	$03
	.byte	$E8, $F1, $04, $40, $F8, $F8, $02, $40, $F8, $E8, $00, $40
metasprite_07D15A:
	.byte	$03, $E8, $F2, $04
	.byte	$40, $F0, $EF, $02, $40, $F8, $F8, $00, $40
metasprite_07D167:
	.byte	$03, $E8, $F8, $04, $40, $F8, $F8
	.byte	$02, $40, $F1, $E8, $00, $40
metasprite_07D174:
	.byte	$03, $F0, $F9, $04, $40, $00, $F9, $02, $40, $F4
	.byte	$E9, $00, $40
metasprite_07D181:
	.byte	$03, $F0, $F8, $04, $40, $00, $F8, $02, $40, $F5, $E8, $00, $40
metasprite_07D18E:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0, $00, $04, $00, $00, $00, $06
	.byte	$00
metasprite_07D19F:
	.byte	$04, $EF, $F1, $00, $00, $FF, $F1, $02, $00, $EF, $01, $04, $00, $FF, $01
	.byte	$06, $00
metasprite_07D1B0:
	.byte	$04, $F0, $EF, $00, $00, $00, $EF, $02, $00, $F0, $FF, $04, $00, $00
	.byte	$FF, $06, $00
metasprite_07D1C1:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0, $00, $04, $00
	.byte	$00, $00, $06, $00
metasprite_07D1D2:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0, $00, $04
	.byte	$00, $00, $00, $06, $00
metasprite_07D1E3:
	.byte	$04, $EF, $F0, $00, $00, $FF, $F0, $02, $00, $EF, $00
	.byte	$04, $00, $FF, $00, $06, $00
metasprite_07D1F4:
	.byte	$04, $EF, $F1, $00, $00, $FF, $F1, $02, $00, $EF
	.byte	$01, $04, $00, $FF, $01, $06, $00
metasprite_07D205:
	.byte	$04, $ED, $F0, $00, $00, $FD, $F0, $02, $00
	.byte	$ED, $00, $04, $00, $FD, $00, $06, $00
metasprite_07D216:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02
	.byte	$00, $F0, $00, $04, $00, $00, $00, $06, $00
metasprite_07D227:
	.byte	$04, $F0, $00, $00, $80, $00, $00
	.byte	$02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D238:
	.byte	$04, $F1, $FF, $00, $80, $01
	.byte	$FF, $02, $80, $F1, $EF, $04, $80, $01, $EF, $06, $80
metasprite_07D249:
	.byte	$04, $F0, $00, $00, $80
	.byte	$00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D25A:
	.byte	$04, $F0, $00, $00
	.byte	$80, $00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D26B:
	.byte	$04, $F0, $00
	.byte	$00, $80, $00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D27C:
	.byte	$04, $F0
	.byte	$FF, $00, $80, $00, $FF, $02, $80, $F0, $EF, $04, $80, $00, $EF, $06, $80
metasprite_07D28D:
	.byte	$04
	.byte	$EE, $FF, $00, $80, $FE, $FF, $02, $80, $EE, $EF, $04, $80, $FE, $EF, $06, $80
metasprite_07D29E:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0, $00, $00, $00
	.byte	$C0
metasprite_07D2AF:
	.byte	$04, $02, $EF, $04, $C0, $F2, $EF, $06, $C0, $F2, $FF, $02, $C0, $02, $FF
	.byte	$00, $C0
metasprite_07D2C0:
	.byte	$04, $00, $F1, $04, $C0, $F0, $F1, $06, $C0, $F0, $01, $02, $C0, $00
	.byte	$01, $00, $C0
metasprite_07D2D1:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02, $C0
	.byte	$00, $00, $00, $C0
metasprite_07D2E2:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04, $C0, $F0, $00, $02
	.byte	$C0, $00, $00, $00, $C0
metasprite_07D2F3:
	.byte	$04, $F1, $F0, $06, $C0, $01, $F0, $04, $C0, $F1, $00
	.byte	$02, $C0, $01, $00, $00, $C0
metasprite_07D304:
	.byte	$04, $F2, $EF, $06, $C0, $02, $EF, $04, $C0, $F2
	.byte	$FF, $02, $C0, $02, $FF, $00, $C0
metasprite_07D315:
	.byte	$04, $F3, $F0, $06, $C0, $03, $F0, $04, $C0
	.byte	$F3, $00, $02, $C0, $03, $00, $00, $C0
metasprite_07D326:
	.byte	$04, $F0, $F0, $06, $C0, $00, $F0, $04
	.byte	$C0, $F0, $00, $02, $C0, $00, $00, $00, $C0
metasprite_07D337:
	.byte	$04, $F0, $F0, $02, $40, $00, $F0
	.byte	$00, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D348:
	.byte	$04, $EF, $F1, $02, $40, $FF
	.byte	$F1, $00, $40, $FF, $01, $04, $40, $EF, $01, $06, $40
metasprite_07D359:
	.byte	$04, $F0, $F0, $02, $40
	.byte	$00, $F0, $00, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D36A:
	.byte	$04, $00, $F0, $00
	.byte	$40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D37B:
	.byte	$04, $00, $F0
	.byte	$00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D38C:
	.byte	$04, $F0
	.byte	$EF, $02, $40, $00, $EF, $00, $40, $00, $FF, $04, $40, $F0, $FF, $06, $40
metasprite_07D39D:
	.byte	$04
	.byte	$F2, $EF, $02, $40, $02, $EF, $00, $40, $02, $FF, $04, $40, $F2, $FF, $06, $40
metasprite_07D3AE:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00
	.byte	$00
metasprite_07D3BF:
	.byte	$04, $FE, $01, $06, $00, $EE, $01, $04, $00, $FE, $F1, $02, $00, $EE, $F1
	.byte	$00, $00
metasprite_07D3D0:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0
	.byte	$F0, $00, $00
metasprite_07D3E1:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00
	.byte	$F0, $F0, $00, $00
metasprite_07D3F2:
	.byte	$04, $00, $FF, $06, $00, $F0, $FF, $04, $00, $00, $EF, $02
	.byte	$00, $F0, $EF, $00, $00
metasprite_07D403:
	.byte	$04, $FF, $00, $06, $00, $EF, $00, $04, $00, $FF, $F0
	.byte	$02, $00, $EF, $F0, $00, $00
metasprite_07D414:
	.byte	$04, $01, $01, $06, $00, $F1, $01, $04, $00, $01
	.byte	$F1, $02, $00, $F1, $F1, $00, $00
metasprite_07D425:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07D436:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04
	.byte	$00, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07D447:
	.byte	$04, $F0, $00, $00, $80, $00, $00
	.byte	$02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D458:
	.byte	$04, $EE, $FF, $00, $80, $FE
	.byte	$FF, $02, $80, $EE, $EF, $04, $80, $FE, $EF, $06, $80
metasprite_07D469:
	.byte	$04, $EF, $00, $00, $80
	.byte	$FF, $00, $02, $80, $EF, $F0, $04, $80, $FF, $F0, $06, $80
metasprite_07D47A:
	.byte	$04, $F0, $00, $00
	.byte	$80, $00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D48B:
	.byte	$04, $F0, $00
	.byte	$00, $80, $00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D49C:
	.byte	$04, $F0
	.byte	$00, $00, $80, $00, $00, $02, $80, $F0, $F0, $04, $80, $00, $F0, $06, $80
metasprite_07D4AD:
	.byte	$04
	.byte	$EE, $FF, $00, $80, $FE, $FF, $02, $80, $EE, $EF, $04, $80, $FE, $EF, $06, $80
metasprite_07D4BE:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0, $F0, $F0, $06
	.byte	$C0
metasprite_07D4CF:
	.byte	$04, $02, $FF, $00, $C0, $F2, $FF, $02, $C0, $02, $EF, $04, $C0, $F2, $EF
	.byte	$06, $C0
metasprite_07D4E0:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0, $F0
	.byte	$F0, $06, $C0
metasprite_07D4F1:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0
	.byte	$F0, $F0, $06, $C0
metasprite_07D502:
	.byte	$04, $00, $01, $00, $C0, $F0, $01, $02, $C0, $00, $F1, $04
	.byte	$C0, $F0, $F1, $06, $C0
metasprite_07D513:
	.byte	$04, $01, $00, $00, $C0, $F1, $00, $02, $C0, $01, $F0
	.byte	$04, $C0, $F1, $F0, $06, $C0
metasprite_07D524:
	.byte	$04, $FF, $FF, $00, $C0, $EF, $FF, $02, $C0, $FF
	.byte	$EF, $04, $C0, $EF, $EF, $06, $C0
metasprite_07D535:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0
	.byte	$00, $F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07D546:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02
	.byte	$C0, $00, $F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07D557:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0
	.byte	$02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
	; CDL: read by draw_topdown_metasprite
metasprite_07D568:
	.byte	$04, $02, $F1, $00, $40, $F2, $F1, $02, $40, $02, $01, $04, $40, $F2, $01, $06
	.byte	$40
metasprite_07D579:
	.byte	$04, $01, $F0, $00, $40, $F1, $F0, $02, $40, $01, $00, $04, $40, $F1, $00
	.byte	$06, $40
metasprite_07D58A:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0
	.byte	$00, $06, $40
metasprite_07D59B:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40
	.byte	$F0, $00, $06, $40
metasprite_07D5AC:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04
	.byte	$40, $F0, $00, $06, $40
metasprite_07D5BD:
	.byte	$04, $02, $F1, $00, $40, $F2, $F1, $02, $40, $02, $01, $04, $40, $F2, $01, $06
	.byte	$40
metasprite_07D5CE:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00
	.byte	$06, $40
metasprite_07D5DF:
	.byte	$04, $EE, $F1, $00, $00, $FE, $F1, $02, $00, $EE, $01, $04, $00, $FE
	.byte	$01, $06, $00
metasprite_07D5F0:
	.byte	$04, $F0, $F1, $00, $00, $00, $F1, $02, $00, $F0, $01, $04, $00
	.byte	$00, $01, $06, $00
metasprite_07D601:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0, $00, $04
	.byte	$00, $00, $00, $06, $00
metasprite_07D612:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0, $00
	.byte	$04, $00, $00, $00, $06, $00
metasprite_07D623:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02, $00, $F0
	.byte	$00, $04, $00, $00, $00, $06, $00
metasprite_07D634:
	.byte	$04, $F1, $F1, $00, $00, $01, $F1, $02, $00
	.byte	$F1, $01, $04, $00, $01, $01, $06, $00
metasprite_07D645:
	.byte	$04, $F0, $F0, $00, $00, $00, $F0, $02
	.byte	$00, $F0, $00, $04, $00, $00, $00, $06, $00
metasprite_07D656:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0
	.byte	$04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D667:
	.byte	$04, $FD, $F0, $06, $80, $ED
	.byte	$F0, $04, $80, $FD, $00, $02, $80, $ED, $00, $00, $80
metasprite_07D678:
	.byte	$04, $FE, $EF, $06, $80
	.byte	$EE, $EF, $04, $80, $FE, $FF, $02, $80, $EE, $FF, $00, $80
metasprite_07D689:
	.byte	$04, $FF, $F0, $06
	.byte	$80, $EF, $F0, $04, $80, $FF, $00, $02, $80, $EF, $00, $00, $80
metasprite_07D69A:
	.byte	$04, $00, $F0
	.byte	$06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D6AB:
	.byte	$04, $00
	.byte	$F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D6BC:
	.byte	$04
	.byte	$00, $F1, $06, $80, $F0, $F1, $04, $80, $00, $01, $02, $80, $F0, $01, $00, $80
metasprite_07D6CD:
	.byte	$04, $FE, $EF, $06, $80, $EE, $EF, $04, $80, $FE, $FF, $02, $80, $EE, $FF, $00
	.byte	$80
metasprite_07D6DE:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00
	.byte	$00, $80
metasprite_07D6EF:
	.byte	$04, $02, $FF, $00, $C0, $F2, $FF, $02, $C0, $02, $EF, $04, $C0, $F2
	.byte	$EF, $06, $C0
metasprite_07D700:
	.byte	$04, $00, $FF, $00, $C0, $F0, $FF, $02, $C0, $00, $EF, $04, $C0
	.byte	$F0, $EF, $06, $C0
metasprite_07D711:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04
	.byte	$C0, $F0, $F0, $06, $C0
metasprite_07D722:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0
	.byte	$04, $C0, $F0, $F0, $06, $C0
metasprite_07D733:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00
	.byte	$F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07D744:
	.byte	$04, $FF, $FF, $00, $C0, $EF, $FF, $02, $C0
	.byte	$FF, $EF, $04, $C0, $EF, $EF, $06, $C0
metasprite_07D755:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02
	.byte	$C0, $00, $F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07D766:
	.byte	$04, $00, $00, $04, $40, $F0, $00
	.byte	$06, $40, $00, $F0, $00, $40, $F0, $F0, $02, $40
metasprite_07D777:
	.byte	$04, $03, $F0, $00, $40, $F3
	.byte	$F0, $02, $40, $03, $00, $04, $40, $F3, $00, $06, $40
metasprite_07D788:
	.byte	$04, $02, $F1, $00, $40
	.byte	$F2, $F1, $02, $40, $02, $01, $04, $40, $F2, $01, $06, $40
metasprite_07D799:
	.byte	$04, $01, $F0, $00
	.byte	$40, $F1, $F0, $02, $40, $01, $00, $04, $40, $F1, $00, $06, $40
metasprite_07D7AA:
	.byte	$04, $00, $F0
	.byte	$00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D7BB:
	.byte	$04, $00
	.byte	$EF, $00, $40, $F0, $EF, $02, $40, $00, $FF, $04, $40, $F0, $FF
	; CDL: read by draw_topdown_metasprite
	.byte	$06, $40
metasprite_07D7CC:
	.byte	$04, $00, $EF, $00, $40, $F0, $EF, $02, $40, $00, $FF, $04, $40, $F0
	.byte	$FF, $06, $40
metasprite_07D7DD:
	.byte	$04, $02, $F1, $00, $40, $F2, $F1, $02, $40, $02, $01, $04, $40
	.byte	$F2, $01, $06, $40
	; CDL: not accessed
metasprite_07D7EE:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06
	.byte	$40
metasprite_07D7FF:
	.byte	$04, $FE, $01, $06, $00, $EE, $01, $04, $00, $FE, $F1, $02, $00, $EE, $F1
	.byte	$00, $00
metasprite_07D810:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0
	.byte	$F0, $00, $00
metasprite_07D821:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00
	.byte	$F0, $F0, $00, $00
metasprite_07D832:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02
	.byte	$00, $F0, $F0, $00, $00
metasprite_07D843:
	.byte	$04, $FF, $00, $06, $00, $EF, $00, $04, $00, $FF, $F0
	.byte	$02, $00, $EF, $F0, $00, $00
metasprite_07D854:
	.byte	$04, $FE, $01, $06, $00, $EE, $01, $04, $00, $FE
	.byte	$F1, $02, $00, $EE, $F1, $00, $00
metasprite_07D865:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07D876:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04
	.byte	$80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D887:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0
	.byte	$04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D898:
	.byte	$04, $01, $EF, $06, $80, $01
	.byte	$FF, $02, $80, $F1, $EF, $04, $80, $F1, $FF, $00, $80
metasprite_07D8A9:
	.byte	$04, $FF, $F0, $06, $80
	.byte	$EF, $F0, $04, $80, $FF, $00, $02, $80, $EF, $00, $00, $80
metasprite_07D8BA:
	.byte	$04, $00, $F1, $06
	.byte	$80, $F0, $F1, $04, $80, $00, $01, $02, $80, $F0, $01, $00, $80
metasprite_07D8CB:
	.byte	$04, $00, $F0
	.byte	$06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D8DC:
	.byte	$04, $00
	.byte	$F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00, $80
metasprite_07D8ED:
	.byte	$04
	.byte	$FE, $EF, $06, $80, $EE, $EF, $04, $80, $FE, $FF, $02, $80, $EE, $FF, $00, $80
metasprite_07D8FE:
	.byte	$04, $00, $F0, $06, $80, $F0, $F0, $04, $80, $00, $00, $02, $80, $F0, $00, $00
	.byte	$80
metasprite_07D90F:
	.byte	$04, $02, $FF, $00, $C0, $F2, $FF, $02, $C0, $02, $EF, $04, $C0, $F2, $EF
	.byte	$06, $C0
metasprite_07D920:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0, $F0
	.byte	$F0, $06, $C0
metasprite_07D931:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0
	.byte	$F0, $F0, $06, $C0
metasprite_07D942:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04
	.byte	$C0, $F0, $F0, $06, $C0
metasprite_07D953:
	.byte	$04, $01, $00, $00, $C0, $F1, $00, $02, $C0, $01, $F0
	.byte	$04, $C0, $F1, $F0, $06, $C0
metasprite_07D964:
	.byte	$04, $02, $FF, $00, $C0, $F2, $FF, $02, $C0, $02
	.byte	$EF, $04, $C0, $F2, $EF, $06, $C0
metasprite_07D975:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0
	.byte	$00, $F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07D986:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02
	.byte	$40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D997:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0
	.byte	$02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D9A8:
	.byte	$04, $FF, $F1, $00, $40, $EF
	.byte	$F1, $02, $40, $FF, $01, $04, $40, $EF, $01, $06, $40
metasprite_07D9B9:
	.byte	$04, $01, $F0, $00, $40
	.byte	$F1, $F0, $02, $40, $01, $00, $04, $40, $F1, $00, $06, $40
metasprite_07D9CA:
	.byte	$04, $00, $EF, $00
	.byte	$40, $F0, $EF, $02, $40, $00, $FF, $04, $40, $F0, $FF, $06, $40
metasprite_07D9DB:
	.byte	$04, $00, $F0
	.byte	$00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D9EC:
	.byte	$04, $00
	.byte	$F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
metasprite_07D9FD:
	.byte	$04
	.byte	$00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
	.byte	$04, $FF, $F4, $04, $40, $F0, $F4, $04, $00, $F8, $00, $02, $00, $F8, $F4, $00
	.byte	$00, $03, $F8, $FF, $04, $00, $FF, $F6, $02, $00, $F3, $F3, $00, $00, $03, $F8
	.byte	$00, $04, $00, $00, $F8, $02, $00, $F5, $F2, $00, $00, $03, $F7, $FF, $04, $00
	.byte	$00, $F8, $02, $00, $F8, $F0, $00, $00, $03, $F5, $FB, $04, $00, $00, $F6, $02
	.byte	$00, $FA, $F0, $00, $00, $03, $F4, $FB, $04, $00, $00, $F8, $02, $00, $F9, $EF
	.byte	$00, $00, $03, $F3, $FA, $04, $00, $FE, $FB, $02, $00, $F9, $F0, $00, $00, $03
	.byte	$F2, $F9, $04, $00, $00, $00, $02, $00, $F9, $F1, $00, $00, $03, $00, $FF, $02
	.byte	$80, $00, $F0, $02, $00, $F0, $F8, $00, $00, $03, $F2, $F7, $04, $80, $00, $F0
	.byte	$02, $80, $F9, $FF, $00, $80, $03, $F3, $F6, $04, $80, $FE, $F5, $02, $80, $F9
	.byte	$00, $00, $80, $03, $F4, $F5, $04, $80, $00, $F8, $02, $80, $F9, $01, $00, $80
	.byte	$03, $F5, $F5, $04, $80, $00, $FA, $02, $80, $FA, $00, $00, $80, $03, $F7, $F1
	.byte	$04, $80, $00, $F8, $02, $80, $F8, $00, $00, $80, $03, $F8, $F0, $04, $80, $00
	.byte	$F8, $02, $80, $F5, $FE, $00, $80, $03, $F8, $F1, $04, $80, $FF, $FA, $02, $80
	.byte	$F3, $FD, $00, $80, $03, $F1, $FC, $02, $80, $00, $FC, $02, $C0, $F8, $F0, $00
	.byte	$C0, $03, $F8, $F1, $04, $C0, $F1, $FA, $02, $C0, $FD, $FD, $00, $C0, $03, $F8
	.byte	$F0, $04, $C0, $F0, $F8, $02, $C0, $FB, $FE, $00, $C0, $03, $F9, $F1, $04, $C0
	.byte	$F0, $F8, $02, $C0, $F8, $00, $00, $C0, $03, $FB, $F5, $04, $C0, $F0, $FA, $02
	.byte	$C0, $F8, $00, $00, $C0, $03, $FC, $F5, $04, $C0, $F0, $F8, $02, $C0, $F7, $01
	.byte	$00, $C0, $03, $FD, $F6, $04, $C0, $F2, $F5, $02, $C0, $F7, $00, $00, $C0, $03
	.byte	$FE, $F7, $04, $C0, $F0, $F0, $02, $C0, $F7, $FF, $00, $C0, $03, $F0, $F1, $02
	.byte	$40, $F0, $00, $02, $C0, $00, $F8, $00, $C0, $03, $FE, $F9, $04, $40, $F0, $00
	.byte	$02, $40, $F7, $F1, $00, $40, $03, $FD, $FA, $04, $40, $F2, $FB, $02, $40, $F7
	.byte	$F0, $00, $40, $03, $FC, $FB, $04, $40, $F0, $F8, $02, $40, $F7, $EF, $00, $40
	.byte	$03, $FB, $FB, $04, $40, $F0, $F6, $02, $40, $F6, $F0, $00, $40, $03, $F9, $FF
	.byte	$04, $40, $F0, $F8, $02, $40, $F8, $F0, $00, $40, $03, $F8, $00, $04, $40, $F0
	.byte	$F8, $02, $40, $FB, $F2, $00, $40, $03, $F8, $FF, $04, $40, $F1, $F6, $02, $40
	.byte	$FD, $F3, $00, $40, $04, $F0, $F7, $04, $00, $FF, $F7, $04, $40, $F8, $00, $02
	.byte	$00, $F8, $F3, $00, $00, $04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0
	.byte	$02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00, $F0, $00, $04, $00, $00
	.byte	$F0, $02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00, $F0, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00, $F0, $00, $04
	.byte	$00, $00, $F0, $02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00, $F0, $00
	.byte	$04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00, $F0
	.byte	$00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00, $04, $00, $00, $06, $00
	.byte	$F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0, $00, $00, $04, $F4, $F8, $02
	.byte	$00, $F9, $FF, $04, $80, $F9, $F0, $04, $00, $FE, $F8, $00, $40, $04, $00, $00
	.byte	$06, $80, $F0, $F0, $04, $80, $00, $F0, $02, $80, $F0, $00, $00, $80, $04, $00
	.byte	$F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80, $F0, $00, $00, $80, $04
	.byte	$00, $F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80, $F0, $00, $00, $80
	.byte	$04, $00, $F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80, $F0, $00, $00
	.byte	$80, $04, $00, $F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80, $F0, $00
	.byte	$00, $80, $04, $00, $F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80, $F0
	.byte	$00, $00, $80, $04, $00, $F0, $02, $80, $F0, $F0, $04, $80, $00, $00, $06, $80
	.byte	$F0, $00, $00, $80, $04, $F8, $F0, $02, $C0, $00, $F8, $04, $C0, $F1, $F8, $04
	.byte	$80, $F8, $FD, $00, $C0, $04, $00, $F0, $04, $C0, $F0, $F0, $06, $C0, $00, $00
	.byte	$00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0, $F0, $F0, $06, $C0, $00
	.byte	$00, $00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0, $F0, $F0, $06, $C0
	.byte	$00, $00, $00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0, $F0, $F0, $06
	.byte	$C0, $00, $00, $00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0, $F0, $F0
	.byte	$06, $C0, $00, $00, $00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0, $F0
	.byte	$F0, $06, $C0, $00, $00, $00, $C0, $F0, $00, $02, $C0, $04, $00, $F0, $04, $C0
	.byte	$F0, $F0, $06, $C0, $00, $00, $00, $C0, $F0, $00, $02, $C0, $04, $F8, $F1, $04
	.byte	$80, $F8, $00, $04, $C0, $FC, $F8, $02, $C0, $F2, $F8, $00, $C0, $04, $00, $F0
	.byte	$00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40, $04, $00
	.byte	$F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40, $04
	.byte	$00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06, $40
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00, $06
	.byte	$40, $04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0, $00
	.byte	$06, $40, $04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40, $F0
	.byte	$00, $06, $40, $04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $04, $40
	.byte	$F0, $00, $06, $40, $04, $FF, $00, $02, $40, $FF, $F0, $00, $40, $F0, $00, $02
	.byte	$00, $F0, $F0, $00, $00, $03, $FA, $FD, $04, $00, $F6, $F2, $02, $00, $F0, $FA
	.byte	$00, $00, $03, $FB, $FE, $04, $00, $F8, $F0, $02, $00, $F0, $F8, $00, $00, $03
	.byte	$FB, $FE, $04, $00, $F9, $F0, $02, $00, $F0, $F9, $00, $00, $03, $F9, $FE, $04
	.byte	$00, $00, $F0, $02, $00, $F2, $F7, $00, $00, $03, $F9, $FE, $04, $00, $FA, $F0
	.byte	$02, $00, $F2, $F7, $00, $00, $03, $F7, $FD, $04, $00, $FA, $F8, $02, $00, $F2
	.byte	$F0, $00, $00, $03, $F5, $FD, $04, $00, $FA, $FA, $02, $00, $F3, $F0, $00, $00
	.byte	$04, $00, $FF, $02, $80, $F0, $FF, $00, $80, $00, $F0, $02, $00, $F0, $F0, $00
	.byte	$00, $03, $F5, $F3, $04, $80, $FA, $F6, $02, $80, $F3, $00, $00, $80, $03, $F7
	.byte	$F3, $04, $80, $FA, $F8, $02, $80, $F2, $00, $00, $80, $03, $F9, $F2, $04, $80
	.byte	$FA, $00, $02, $80, $F2, $F9, $00, $80, $03, $F9, $F2, $04, $80, $00, $00, $02
	.byte	$80, $F2, $F9, $00, $80, $03, $FC, $F2, $04, $80, $F9, $00, $02, $80, $F0, $F7
	.byte	$00, $80, $03, $FB, $F2, $04, $80, $F8, $00, $02, $80, $F0, $F8, $00, $80, $03
	.byte	$FA, $F3, $04, $80, $F6, $FA, $02, $80, $F0, $F6, $00, $80, $04, $FF, $00, $02
	.byte	$C0, $FF, $F0, $00, $C0, $F0, $00, $02, $80, $F0, $F0, $00, $80, $03, $F6, $F3
	.byte	$04, $C0, $FA, $FA, $02, $C0, $00, $F6, $00, $C0, $03, $F5, $F2, $04, $C0, $F8
	.byte	$00, $02, $C0, $00, $F8, $00, $C0, $03, $F5, $F2, $04, $C0, $F6, $00, $02, $C0
	.byte	$00, $F7, $00, $C0, $03, $F7, $F2, $04, $C0, $F0, $00, $02, $C0, $FE, $F9, $00
	.byte	$C0, $03, $F7, $F2, $04, $C0, $F6, $00, $02, $C0, $FE, $F9, $00, $C0, $03, $F9
	.byte	$F3, $04, $C0, $F6, $F8, $02, $C0, $FE, $00, $00, $C0, $03, $FB, $F3, $04, $C0
	.byte	$F6, $F6, $02, $C0, $FD, $00, $00, $C0, $04, $F0, $F1, $02, $40, $00, $F1, $00
	.byte	$40, $F0, $00, $02, $C0, $00, $00, $00, $C0, $03, $FB, $FD, $04, $40, $F5, $FA
	.byte	$02, $40, $FD, $F0, $00, $40, $03, $F9, $FD, $04, $40, $F6, $F8, $02, $40, $FE
	.byte	$F0, $00, $40, $03, $F7, $FE, $04, $40, $F6, $F0, $02, $40, $FE, $F7, $00, $40
	.byte	$03, $F7, $FE, $04, $40, $F0, $F0, $02, $40, $FE, $F7, $00, $40, $03, $F5, $FE
	.byte	$04, $40, $F7, $F0, $02, $40, $00, $F9, $00, $40, $03, $F5, $FE, $04, $40, $F8
	.byte	$F0, $02, $40, $00, $F8, $00, $40, $03, $F6, $FD, $04, $40, $FA, $F6, $02, $40
	.byte	$00, $F8, $00, $40, $04, $00, $00, $02, $40, $00, $F0, $00, $40, $F1, $00, $02
	.byte	$00, $F1, $F0, $00, $00, $02, $F4, $F6, $02, $00, $FC, $F9, $00, $00, $03, $F8
	.byte	$00, $04, $00, $F0, $F0, $02, $00, $00, $F8, $00, $00, $03, $F8, $F8, $04, $00
	.byte	$F8, $F0, $02, $00, $00, $F8, $00, $00, $03, $F8, $F0, $02, $00, $F0, $00, $04
	.byte	$00, $00, $F8, $00, $00, $03, $F8, $F8, $04, $00, $F8, $F0, $02, $00, $00, $F8
	.byte	$00, $00, $03, $F0, $F8, $04, $00, $F8, $F0, $02, $00, $00, $F9, $00, $00, $02
	.byte	$F7, $F4, $02, $00, $FA, $FC, $00, $00, $04, $00, $FF, $02, $80, $F0, $FF, $00
	.byte	$80, $00, $F0, $02, $00, $F0, $F0, $00, $00, $02, $F7, $FC, $02, $80, $FA, $F4
	.byte	$00, $80, $03, $F0, $F8, $04, $80, $F8, $00, $02, $80, $00, $F7, $00, $80, $03
	.byte	$F8, $F8, $04, $80, $F8, $00, $02, $80, $00, $F8, $00, $80, $03, $F0, $F0, $04
	.byte	$80, $F8, $00, $02, $80, $00, $F8, $00, $80, $03, $F8, $F8, $04, $80, $F8, $00
	.byte	$02, $80, $00, $F8, $00, $80, $03, $F8, $F0, $04, $80, $F0, $00, $02, $80, $00
	.byte	$F8, $00, $80, $02, $F4, $FA, $02, $80, $FC, $F7, $00, $80, $04, $00, $F0, $02
	.byte	$C0, $00, $00, $00, $C0, $F1, $F0, $02, $80, $F1, $00, $00, $80, $02, $FC, $FA
	.byte	$02, $C0, $F4, $F7, $00, $C0, $03, $F8, $F0, $04, $C0, $00, $00, $02, $C0, $F0
	.byte	$F8, $00, $C0, $03, $F8, $F8, $04, $C0, $F8, $00, $02, $C0, $F0, $F8, $00, $C0
	.byte	$03, $00, $F0, $04, $C0, $F8, $00, $02, $C0, $F0, $F8, $00, $C0, $03, $F8, $F8
	.byte	$04, $C0, $F8, $00, $02, $C0, $F0, $F8, $00, $C0, $03, $00, $F8, $04, $C0, $F8
	.byte	$00, $02, $C0, $F0, $F7, $00, $C0, $02, $F9, $FC, $02, $C0, $F6, $F4, $00, $C0
	.byte	$04, $F0, $F1, $02, $40, $00, $F1, $00, $40, $F0, $00, $02, $C0, $00, $00, $00
	.byte	$C0, $02, $F9, $F4, $02, $40, $F6, $FC, $00, $40, $03, $00, $F8, $04, $40, $F8
	.byte	$F0, $02, $40, $F0, $F9, $00, $40, $03, $F8, $F8, $04, $40, $F8, $F0, $02, $40
	.byte	$F0, $F8, $00, $40, $03, $F8, $F0, $02, $40, $00, $00, $04, $40, $F0, $F8, $00
	.byte	$40, $03, $F8, $F8, $04, $40, $F8, $F0, $02, $40, $F0, $F8, $00, $40, $03, $F8
	.byte	$00, $04, $40, $00, $F0, $02, $40, $F0, $F8, $00, $40, $02, $FC, $F6, $02, $40
	.byte	$F4, $F9, $00, $40, $02, $00, $F8, $02, $00, $F0, $F8, $00, $00, $02, $00, $F8
	.byte	$06, $00, $F0, $F8, $04, $00, $01, $F8, $F8, $24, $00, $01, $F8, $F8, $26, $00
	; CDL: read by draw_topdown_metasprite_p2
metasprite_07E12E:
	.byte	$04, $00, $00, $02, $40, $00, $F0, $00, $40, $F0, $00, $02, $00, $F0, $F0, $00
	.byte	$00
metasprite_07E13F:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0, $F0
	.byte	$00, $00
metasprite_07E150:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00, $F0
	.byte	$F0, $00, $00
metasprite_07E161:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02, $00
	.byte	$F0, $F0, $00, $00
metasprite_07E172:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02
	.byte	$00, $F0, $F0, $00, $00
metasprite_07E183:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0
	.byte	$02, $00, $F0, $F0, $00, $00
metasprite_07E194:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00
	.byte	$F0, $02, $00, $F0, $F0, $00, $00
metasprite_07E1A5:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00
	.byte	$00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07E1B6:
	.byte	$04, $00, $00, $02, $80, $F0, $00, $00
	.byte	$80, $00, $F0, $02, $00, $F0, $F0, $00, $00
metasprite_07E1C7:
	.byte	$04, $00, $00, $02, $80, $F0, $00
	.byte	$00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E1D8:
	.byte	$04, $00, $00, $02, $80, $F0
	.byte	$00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E1E9:
	.byte	$04, $00, $00, $02, $80
	.byte	$F0, $00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E1FA:
	.byte	$04, $00, $00, $02
	.byte	$80, $F0, $00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E20B:
	.byte	$04, $00, $00
	.byte	$02, $80, $F0, $00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E21C:
	.byte	$04, $00
	.byte	$00, $02, $80, $F0, $00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E22D:
	.byte	$04
	.byte	$00, $00, $02, $80, $F0, $00, $00, $80, $00, $F0, $06, $80, $F0, $F0, $04, $80
metasprite_07E23E:
	.byte	$04, $00, $00, $00, $C0, $00, $F0, $02, $C0, $F0, $00, $00, $80, $F0, $F0, $02
	.byte	$80
metasprite_07E24F:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0, $F0, $F0
	.byte	$06, $C0
metasprite_07E260:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0, $F0
	.byte	$F0, $06, $C0
metasprite_07E271:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04, $C0
	.byte	$F0, $F0, $06, $C0
metasprite_07E282:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0, $04
	.byte	$C0, $F0, $F0, $06, $C0
metasprite_07E293:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00, $F0
	.byte	$04, $C0, $F0, $F0, $06, $C0
metasprite_07E2A4:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0, $00
	.byte	$F0, $04, $C0, $F0, $F0, $06, $C0
metasprite_07E2B5:
	.byte	$04, $00, $00, $00, $C0, $F0, $00, $02, $C0
	.byte	$00, $F0, $04, $C0, $F0, $F0, $06, $C0
	; CDL: read by draw_topdown_metasprite
metasprite_07E2C6:
	.byte	$04, $00, $F0, $00, $40, $F0, $F0, $02, $40, $00, $00, $00, $C0, $F0, $00, $02
	.byte	$C0
metasprite_07E2D7:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00, $40, $F0, $F0
	.byte	$02, $40
	; CDL: read by draw_topdown_metasprite_p2
metasprite_07E2E8:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00, $40, $F0, $F0, $02
	.byte	$40
metasprite_07E2F9:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00, $40, $F0, $F0
	.byte	$02, $40
metasprite_07E30A:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00, $40, $F0
	.byte	$F0, $02, $40
metasprite_07E31B:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00, $40
	.byte	$F0, $F0, $02, $40
metasprite_07E32C:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0, $00
	.byte	$40, $F0, $F0, $02, $40
metasprite_07E33D:
	.byte	$04, $00, $00, $04, $40, $F0, $00, $06, $40, $00, $F0
	.byte	$00, $40, $F0, $F0, $02, $40
metasprite_07E34E:
	.byte	$03, $00, $F9, $04, $00, $F0, $FD, $02, $00, $F0
	.byte	$ED, $00, $00
metasprite_07E35B:
	.byte	$03, $00, $FB, $04, $00, $F0, $FD, $02, $00, $F0, $ED, $00, $00
metasprite_07E368:
	.byte	$03, $00, $FD, $04, $00, $F4, $ED, $02, $00, $F0, $FD, $00, $00
metasprite_07E375:
	.byte	$03, $FB, $FD
	.byte	$04, $00, $F0, $F6, $02, $00, $F8, $ED, $00, $00
metasprite_07E382:
	.byte	$03, $F0, $F5, $04, $00, $FA, $FD, $02, $00, $F8, $ED, $00, $00
metasprite_07E38F:
	.byte	$03, $FA, $ED
	.byte	$04, $00, $F9, $FD, $02, $00, $F0, $F5, $00, $00
metasprite_07E39C:
	.byte	$03, $F0, $F1, $04, $00, $F9
	.byte	$FD, $02, $00, $00, $ED, $00, $00
metasprite_07E3A9:
	.byte	$03, $F0, $EF, $04, $00, $F8, $FD, $02, $00
	.byte	$00, $ED, $00, $00
metasprite_07E3B6:
	.byte	$03, $F5, $ED, $04, $00, $F5, $FD, $02, $00, $05, $ED, $00
	.byte	$00
metasprite_07E3C3:
	.byte	$03, $F5, $00, $04, $00, $F3, $F0, $02, $00, $03, $F0, $00, $00
metasprite_07E3D0:
	.byte	$03, $F3
	.byte	$00, $04, $00, $03, $F4, $02, $00, $F3, $F0, $00, $00
metasprite_07E3DD:
	.byte	$03, $F3, $FB, $04, $00
	.byte	$FA, $F0, $02, $00, $03, $F8, $00, $00
metasprite_07E3EA:
	.byte	$03, $FB, $F0, $04, $00, $F3, $FA, $02
	.byte	$00, $03, $F8, $00, $00
metasprite_07E3F7:
	.byte	$03, $03, $FA, $04, $00, $F3, $F9, $02, $00, $FB, $F0
	.byte	$00, $00
metasprite_07E404:
	.byte	$03, $FF, $F0, $04, $00, $F3, $F9, $02, $00, $03, $00, $00, $00
metasprite_07E411:
	.byte	$03
	.byte	$01, $F0, $04, $00, $F3, $F8, $02, $00, $03, $00, $00, $00
metasprite_07E41E:
	.byte	$03, $F0, $F7, $04
	.byte	$C0, $00, $F3, $02, $C0, $00, $03, $00, $C0
metasprite_07E42B:
	.byte	$03, $F0, $F5, $04, $C0, $00, $F3
	.byte	$02, $C0, $00, $03, $00, $C0
metasprite_07E438:
	.byte	$03, $F0, $F3, $04, $C0, $FC, $03, $02, $C0, $00
	.byte	$F3, $00, $C0
metasprite_07E445:
	.byte	$03, $F5, $F3, $04, $C0, $00, $FA, $02, $C0, $F8, $03, $00, $C0
metasprite_07E452:
	.byte	$03, $00, $FB, $04, $C0, $F6, $F3, $02, $C0, $F8, $03, $00, $C0
metasprite_07E45F:
	.byte	$03, $F6, $03
	.byte	$04, $C0, $F7, $F3, $02, $C0, $00, $FB, $00, $C0
metasprite_07E46C:
	.byte	$03, $00, $FF, $04, $C0, $F7
	.byte	$F3, $02, $C0, $F0, $03, $00, $C0
metasprite_07E479:
	.byte	$03, $00, $01, $04, $C0, $F8, $F3, $02, $C0
	.byte	$F0, $03, $00, $C0
metasprite_07E486:
	.byte	$03, $FB, $03, $04, $C0, $FB, $F3, $02, $C0, $EB, $03, $00
	.byte	$C0
metasprite_07E493:
	.byte	$03, $FB, $F0, $04, $C0, $FD, $00, $02, $C0, $ED, $00, $00, $C0
metasprite_07E4A0:
	.byte	$03, $FD
	.byte	$F0, $04, $C0, $ED, $FC, $02, $C0, $FD, $00, $00, $C0
metasprite_07E4AD:
	.byte	$03, $FD, $F5, $04, $C0
	.byte	$F6, $00, $02, $C0, $ED, $F8, $00, $C0
metasprite_07E4BA:
	.byte	$03, $F5, $00, $04, $C0, $FD, $F6, $02
	.byte	$C0, $ED, $F8, $00, $C0
metasprite_07E4C7:
	.byte	$03, $ED, $F6, $04, $C0, $FD, $F7, $02, $C0, $F5, $00
	.byte	$00, $C0
metasprite_07E4D4:
	.byte	$03, $F1, $00, $04, $C0, $FD, $F7, $02, $C0, $ED, $F0, $00, $C0
metasprite_07E4E1:
	.byte	$03
	.byte	$EF, $00, $04, $C0, $FD, $F8, $02, $C0, $ED, $F0, $00, $C0
metasprite_07E4EE:
	.byte	$03, $F0, $FC, $04
	.byte	$00, $F0, $EC, $02, $00, $00, $F8, $00, $00
metasprite_07E4FB:
	.byte	$03, $EC, $F9, $04, $00, $F0, $ED
	.byte	$02, $00, $FC, $F9, $00, $00
metasprite_07E508:
	.byte	$03, $F1, $FB, $04, $00, $F2, $EB, $02, $00, $FB
	.byte	$FA, $00, $00
metasprite_07E515:
	.byte	$03, $F2, $F8, $04, $00, $F6, $EB, $02, $00, $00, $FB, $00, $00
metasprite_07E522:
	.byte	$03, $F0, $F5, $04, $00, $FA, $EC, $02, $00, $F9, $FC, $00, $00
metasprite_07E52F:
	.byte	$03, $F3, $F4
	.byte	$04, $00, $FD, $ED, $02, $00, $F9, $FC, $00, $00
metasprite_07E53C:
	.byte	$03, $F0, $F3, $04, $00, $00
	.byte	$EF, $02, $00, $F9, $FD, $00, $00
metasprite_07E549:
	.byte	$03, $F2, $F3, $04, $00, $02, $ED, $02, $00
	.byte	$F9, $FD, $00, $00
metasprite_07E556:
	.byte	$03, $F5, $F2, $04, $00, $05, $F2, $02, $00, $F8, $FD, $00
	.byte	$00
metasprite_07E563:
	.byte	$03, $F7, $EC, $04, $00, $05, $F0, $02, $00, $F7, $FC, $00, $00
metasprite_07E570:
	.byte	$03, $F5
	.byte	$F1, $04, $00, $05, $F2, $02, $00, $F6, $FB, $00, $00
metasprite_07E57D:
	.byte	$03, $F8, $F2, $04, $00
	.byte	$05, $F6, $02, $00, $F5, $00, $00, $00
metasprite_07E58A:
	.byte	$03, $FB, $F0, $04, $00, $04, $FA, $02
	.byte	$00, $F4, $F9, $00, $00
metasprite_07E597:
	.byte	$03, $FC, $F3, $04, $00, $03, $FD, $02, $00, $F4, $F9
	.byte	$00, $00
metasprite_07E5A4:
	.byte	$03, $FD, $F0, $04, $00, $01, $00, $02, $00, $F3, $F9, $00, $00
metasprite_07E5B1:
	.byte	$03
	.byte	$FD, $F2, $04, $00, $03, $02, $02, $00, $F3, $F9, $00, $00
metasprite_07E5BE:
	.byte	$03, $00, $F4, $04
	.byte	$C0, $00, $04, $02, $C0, $F0, $F8, $00, $C0
metasprite_07E5CB:
	.byte	$03, $04, $F7, $04, $C0, $00, $05
	.byte	$02, $C0, $F4, $F7, $00, $C0
metasprite_07E5D8:
	.byte	$03, $FF, $F5, $04, $C0, $FE, $05, $02, $C0, $F5
	.byte	$F6, $00, $C0
metasprite_07E5E5:
	.byte	$03, $FE, $F8, $04, $C0, $FA, $05, $02, $C0, $F0, $F5, $00, $C0
metasprite_07E5F2:
	.byte	$03, $00, $FB, $04, $C0, $F6, $04, $02, $C0, $F7, $F4, $00, $C0
metasprite_07E5FF:
	.byte	$03, $FD, $FC
	.byte	$04, $C0, $F3, $03, $02, $C0, $F7, $F4, $00, $C0
metasprite_07E60C:
	.byte	$03, $00, $FD, $04, $C0, $F0
	.byte	$01, $02, $C0, $F7, $F3, $00, $C0
metasprite_07E619:
	.byte	$03, $FE, $FD, $04, $C0, $EE, $03, $02, $C0
	.byte	$F7, $F3, $00, $C0
metasprite_07E626:
	.byte	$03, $FB, $FE, $04, $C0, $EB, $FE, $02, $C0, $F8, $F3, $00
	.byte	$C0
metasprite_07E633:
	.byte	$03, $EB, $00, $02, $C0, $F9, $04, $04, $C0, $F9, $F4, $00, $C0
metasprite_07E640:
	.byte	$03, $FB
	.byte	$FF, $04, $C0, $EB, $FE, $02, $C0, $FA, $F5, $00, $C0
metasprite_07E64D:
	.byte	$03, $F8, $FE, $04, $C0
	.byte	$EB, $FA, $02, $C0, $FB, $F0, $00, $C0
metasprite_07E65A:
	.byte	$03, $F5, $00, $04, $C0, $EC, $F6, $02
	.byte	$C0, $FC, $F7, $00, $C0
metasprite_07E667:
	.byte	$03, $F4, $FD, $04, $C0, $ED, $F3, $02, $C0, $FC, $F7
	.byte	$00, $C0
metasprite_07E674:
	.byte	$03, $F3, $00, $04, $C0, $EF, $F0, $02, $C0, $FD, $F7, $00, $C0
metasprite_07E681:
	.byte	$03
	.byte	$ED, $EE, $02, $C0, $F3, $FE, $04, $C0, $FD, $F7, $00, $C0
metasprite_07E68E:
	.byte	$04, $F0, $FD, $06
	.byte	$00, $00, $FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E69F:
	.byte	$04, $F0, $FD
	.byte	$06, $00, $00, $FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E6B0:
	.byte	$04, $F0
	.byte	$FD, $06, $00, $00, $FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E6C1:
	.byte	$03
	.byte	$EF, $FD, $04, $00, $FB, $FB, $02, $00, $F4, $EF, $00, $00
metasprite_07E6CE:
	.byte	$03, $F0, $FA, $04
	.byte	$00, $FB, $FD, $02, $00, $F7, $ED, $00, $00
metasprite_07E6DB:
	.byte	$04, $F0, $FD, $06, $00, $00, $FD
	.byte	$04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E6EC:
	.byte	$04, $F0, $FD, $06, $00, $00
	.byte	$FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E6FD:
	.byte	$04, $F0, $FD, $06, $00
	.byte	$00, $FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E70E:
	.byte	$04, $F0, $FD, $06
	.byte	$00, $00, $FD, $04, $00, $00, $ED, $02, $00, $F0, $ED, $00, $00
metasprite_07E71F:
	.byte	$04, $F3, $F0
	.byte	$06, $00, $F3, $00, $04, $00, $03, $00, $02, $00, $03, $F0, $00, $00
metasprite_07E730:
	.byte	$04, $F3
	.byte	$F0, $06, $00, $F3, $00, $04, $00, $03, $00, $02, $00, $03, $F0, $00, $00
metasprite_07E741:
	.byte	$03
	.byte	$F3, $EF, $04, $00, $F5, $FB, $02, $00, $01, $F4, $00, $00
metasprite_07E74E:
	.byte	$03, $F6, $F0, $04
	.byte	$00, $F3, $FB, $02, $00, $03, $F7, $00, $00
metasprite_07E75B:
	.byte	$04, $F3, $F0, $06, $00, $F3, $00
	.byte	$04, $00, $03, $00, $02, $00, $03, $F0, $00, $00
metasprite_07E76C:
	.byte	$04, $F3, $F0, $06, $00, $F3
	.byte	$00, $04, $00, $03, $00, $02, $00, $03, $F0, $00, $00
metasprite_07E77D:
	.byte	$04, $F3, $F0, $06, $00
	.byte	$F3, $00, $04, $00, $03, $00, $02, $00, $03, $F0, $00, $00
metasprite_07E78E:
	.byte	$04, $00, $F3, $06
	.byte	$C0, $F0, $F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E79F:
	.byte	$04, $00, $F3
	.byte	$06, $C0, $F0, $F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E7B0:
	.byte	$04, $00
	.byte	$F3, $06, $C0, $F0, $F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E7C1:
	.byte	$03
	.byte	$01, $F3, $04, $C0, $F5, $F5, $02, $C0, $FC, $01, $00, $C0
metasprite_07E7CE:
	.byte	$03, $00, $F6, $04
	.byte	$C0, $F5, $F3, $02, $C0, $F9, $03, $00, $C0
metasprite_07E7DB:
	.byte	$04, $00, $F3, $06, $C0, $F0, $F3
	.byte	$04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E7EC:
	.byte	$04, $00, $F3, $06, $C0, $F0
	.byte	$F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E7FD:
	.byte	$04, $00, $F3, $06, $C0
	.byte	$F0, $F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E80E:
	.byte	$04, $00, $F3, $06
	.byte	$C0, $F0, $F3, $04, $C0, $F0, $03, $02, $C0, $00, $03, $00, $C0
metasprite_07E81F:
	.byte	$04, $FD, $00
	.byte	$06, $C0, $FD, $F0, $04, $C0, $ED, $F0, $02, $C0, $ED, $00, $00, $C0
metasprite_07E830:
	.byte	$04, $FD
	.byte	$00, $06, $C0, $FD, $F0, $04, $C0, $ED, $F0, $02, $C0, $ED, $00, $00, $C0
metasprite_07E841:
	.byte	$03
	.byte	$FD, $01, $04, $C0, $FB, $F5, $02, $C0, $EF, $FC, $00, $C0
metasprite_07E84E:
	.byte	$03, $FA, $00, $04
	.byte	$C0, $FD, $F5, $02, $C0, $ED, $F8, $00, $C0
metasprite_07E85B:
	.byte	$04, $FD, $00, $06, $C0, $FD, $F0
	.byte	$04, $C0, $ED, $F0, $02, $C0
	; CDL: read by draw_topdown_metasprite, draw_topdown_metasprite_p2; partly not accessed
	.byte	$ED, $00, $00, $C0
metasprite_07E86C:
	.byte	$04, $FD, $00, $06, $C0, $FD, $F0, $04, $C0, $ED, $F0, $02
	.byte	$C0, $ED, $00, $00, $C0
metasprite_07E87D:
	.byte	$04, $FD, $00, $06, $C0, $FD, $F0, $04, $C0, $ED, $F0
	.byte	$02, $C0, $ED, $00, $00, $C0, $02, $00, $F8, $02, $00, $F0, $F8, $00, $00, $01
	.byte	$F8, $F8, $00, $00
metasprite_07E89C:
	.byte	$04, $00, $00, $06, $00, $F0, $00, $04, $00, $00, $F0, $02
	.byte	$00, $F0, $F0, $00, $00, $01, $F8, $F8, $A0, $01, $01, $F8, $F8, $A2, $01
; The metasprites of the top-down items (draw_td_item_metasprite): a count,
; then 4 bytes per sprite (x, y, tile, attributes; bit 0 of the attributes is
; the size).  The routine reads the attributes as a word, so it also reads the
; byte after the last sprite (the next metasprite's count, after
; metasprite_07E9ED the first byte of gfx_07E9FE), but it only keeps bit 0 of
; the low byte: that byte is not used, and these blocks can move apart
; (checked in the emulator with other values there).
	; CDL: read by draw_td_item_metasprite, draw_td_item_metasprite_p2; partly not accessed
metasprite_07E8B7:
	.byte	$04, $00, $00, $A6, $C1, $F0, $00, $A6, $81, $00, $F0, $A6, $41, $F0, $F0, $A6
	.byte	$01
metasprite_07E8C8:
	.byte	$04, $00, $00, $A8, $C1, $F0, $00, $A8, $81, $00, $F0, $A8, $41, $F0, $F0
	.byte	$A8, $01
metasprite_07E8D9:
	.byte	$04, $00, $00, $AA, $C1, $F0, $00, $AA, $81, $00, $F0, $AA, $41, $F0
	.byte	$F0, $AA, $01
metasprite_07E8EA:
	.byte	$04, $00, $00, $AC, $C1, $F0, $00, $AC, $81, $00, $F0, $AC, $41
	.byte	$F0, $F0, $AC, $01
metasprite_07E8FB:
	.byte	$01, $F8, $F8, $88, $01
metasprite_07E900:
	.byte	$01, $F8, $F8, $8A, $01
metasprite_07E905:
	.byte	$04, $00
	.byte	$00, $AE, $C1, $F0, $00, $AE, $81, $00, $F0, $AE, $41, $F0, $F0, $AE, $01
metasprite_07E916:
	.byte	$04
	.byte	$00, $00, $CA, $C1, $F0, $00, $CA, $81, $00, $F0, $CA, $41, $F0, $F0, $CA, $01
metasprite_07E927:
	.byte	$04, $00, $00, $CC, $C1, $F0, $00, $CC, $81, $00, $F0, $CC, $41, $F0, $F0, $CC
	.byte	$01
metasprite_07E938:
	.byte	$04, $00, $00, $CE, $C1, $F0, $00, $CE, $81, $00, $F0, $CE, $41, $F0, $F0
	.byte	$CE, $01, $01, $F8, $F8, $A4, $01, $01, $F8, $F8, $8C, $01, $01, $F8, $F8, $C0
	.byte	$01, $01, $F8, $F8, $C2, $01, $01, $F8, $F8, $C4, $01, $01, $F8, $F8, $8E, $01
metasprite_07E967:
	.byte	$01, $F8, $F8, $86, $01, $01, $FC, $FC, $11, $00
metasprite_07E971:
	.byte	$04, $FC, $FE, $F9, $00, $FC
	.byte	$F6, $E9, $00, $00, $F8, $EC, $01, $F0, $F8, $EA, $01
metasprite_07E982:
	.byte	$01, $F8, $F8, $E2, $01
metasprite_07E987:
	.byte	$04, $00, $00, $E0, $C1, $F0, $00, $E0, $81, $00, $F0, $E0, $41, $F0, $F0, $E0
	.byte	$01
metasprite_07E998:
	.byte	$04, $00, $00, $EE, $C1, $F0, $00, $EE, $81, $00, $F0, $EE, $41, $F0, $F0
	.byte	$EE, $01
metasprite_07E9A9:
	.byte	$04
	; CDL: read by draw_td_item_metasprite, draw_td_item_metasprite_p2
	.byte	$FC, $FE, $E5, $00, $FC, $F6, $E4, $00, $00, $F8, $EC, $01, $F0, $F8, $EA, $01
metasprite_07E9BA:
	.byte	$04, $FC, $FE, $F5, $00, $FC, $F6, $E4, $00, $00, $F8, $EC, $01, $F0, $F8, $EA
	.byte	$01
metasprite_07E9CB:
	.byte	$04, $FC, $FE, $F6, $00, $FC, $F6, $E6, $00, $00, $F8, $EC, $01, $F0, $F8
	.byte	$EA, $01
metasprite_07E9DC:
	.byte	$04
	; CDL: read by draw_td_item_metasprite
	.byte	$FC, $FE, $F7, $00, $FC, $F6, $E7, $00, $00, $F8, $EC, $01, $F0, $F8, $EA, $01
metasprite_07E9ED:
	.byte	$04, $FC, $FE, $F8, $00, $FC, $F6, $E8, $00, $00, $F8, $EC, $01, $F0, $F8, $EA
	.byte	$01
	; CDL: read by decompress_chunk
gfx_07E9FE:
	; ASSET: compressed graphics (VRAM), $07:E9FE-$07:F551 (from its length word), loaded by load_list_0587AB
	.incbin	"gfx/gfx_07E9FE.lz"
opening_bg1_map:
	; Compressed data for WRAM $7E:9000, $07:F552-$07:F78D (from its length word), loaded by load_list_05A84B.
	; Opening cinematic (stage 0): BG1 map, one word per metatile (byte offset of the metatile, bits 14-15 flip), 8x8 metatiles per $80-byte page.
	; What it decompresses to is not checked for pointers (none known).
	.incbin	"wram/opening_bg1_map.lz"
ending_message_hard:
	; ASSET: compressed graphics (VRAM), $07:F78E-$07:F902 (from its length word), loaded by load_list_05FDB3
	; BG3 map (VRAM $5C00) of the closing message after stage 6 on HARD:
	; "Way to go! You've conquered the toughest Contra challenge yet. ..."
	; (seen in the emulator, play stage6_ending_hard).
	.incbin	"gfx/ending_message_hard.lz"
tile_attrs_stage2:
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $10, $10, $10, $10, $10, $10, $10, $11, $11, $11, $11, $11, $11, $11, $11
	.byte	$11, $11, $11, $11, $18, $18, $18, $18, $18, $18, $18, $19, $19, $19, $19, $19
	.byte	$19, $19, $19, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte	$01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte	$01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte	$01, $01, $05, $01, $05, $01, $01, $03, $03, $03, $03, $03, $03, $03, $03, $03
	.byte	$03, $03, $03, $03, $03, $03, $03, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
	.byte	$FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $04, $04, $04, $04, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FE, $FE, $FE, $FE, $FE, $FD, $FD, $FD, $FD, $FD
tile_attrs_stage5:
	; CDL: read by build_tile_attr_rows_stage5, set_m7_block_patch_0
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
	.byte	$00, $00, $00, $00, $00
	; CDL: read by build_tile_attr_rows_stage5
	.byte	$01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	.byte	$01, $01, $01, $01, $01, $01, $01, $01, $FF, $F4, $F4, $F4, $F4, $F4, $F4, $F4
	.byte	$F4, $F4, $F4, $F4, $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F3, $F2
	.byte	$F2, $F2, $F2, $F2, $F2, $F2, $F2, $F2, $F2, $F2, $F1, $F1, $F1, $F1, $F1, $F1
	.byte	$F1, $F1, $F1, $F1, $F1, $F0, $F0, $F0, $F0, $F0, $F0, $EF, $EF, $EF, $EF, $EF
	.byte	$EF, $EE, $EE, $EE, $EE, $EE, $EE, $ED, $ED, $ED, $ED, $ED, $ED, $FB, $FB, $FB
	.byte	$FB, $FB, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC
	; CDL: read by set_m7_block_patch_0; partly not accessed
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	; CDL: read by build_tile_attr_rows_stage5
	.byte	$FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA, $FA
	.byte	$F8, $F8, $F8, $F8, $F8, $F8, $F8, $F8, $F7, $F7, $F7, $F7, $F7, $F7, $F7, $F7
	.byte	$F6, $F6, $F6, $F6, $F6, $F6, $F6, $F6, $F5, $F5, $F5, $F5, $F5, $F5, $F5, $F5
tile_attrs_stage5_boss:
	; CDL: read by build_tile_attr_rows_stage5_boss; partly not accessed
	.byte	$00, $00, $00, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9
	.byte	$F9, $F9, $F9, $F9, $F9, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC
	.byte	$FC, $FC, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9
	.byte	$F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9, $F9
	.byte	$F9, $F9, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
