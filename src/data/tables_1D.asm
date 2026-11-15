; data/tables_1D.asm -- Data (bank $1D, $CCE0-$FFFF)
; Bank $1D, $1D:CCE0-$1D:FFFF. Included by main.asm in segment BANK1D.
;
; A table nothing read in the CDL traces, then $FF padding.

data_1DCCE0:
	; CDL: not accessed
	.byte	$01, $02, $03, $04, $05, $06, $07, $08, $09, $0A, $0B, $0C, $0D, $0E, $0F, $10
	.byte	$11, $12, $13, $14, $15, $16, $17, $1A, $1B, $1C, $1D, $20, $21, $22, $23, $24
	.byte	$25, $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31, $32, $33, $34
	.byte	$35, $36, $37, $38, $39, $3A, $3B, $3C, $3D, $55, $3E, $3F, $41, $42, $43, $44
	.byte	$45, $46, $47, $48, $49, $4A, $4B, $4C, $4D, $4E, $4F, $50, $51, $52, $53, $54
	.byte	$56, $57, $58, $59, $5A, $5B, $5C, $5D, $5E, $5F, $6D, $6E, $61, $62, $63, $64
	.byte	$65, $66, $67, $68, $69, $82, $6F, $6A, $6B, $71, $72, $FF, $FF, $FF, $FF, $FF
	; The rest of the bank is free: filled with $FF by the linker (contra3.cfg).
