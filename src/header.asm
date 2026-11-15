; header.asm -- Internal header and vectors
; Bank $00, $00:FFC0-$00:FFFF. Included by main.asm in segment HEADER,
; which contra3.cfg places at $00:FFC0.
;
; The SNES internal header ($00:FFC0-$00:FFDF) and the interrupt vectors
; ($00:FFE0-$00:FFFF), one line per field. See the book, "The cartridge".

; ---------------------------------------------------------------------------
; Internal ROM header ($00:FFC0-$00:FFDF) and interrupt vectors
; ($00:FFE0-$00:FFFF).  Reproduced exactly as in the original ROM.
; The developer ID at $FFDA is not $33, so there is no extended header:
; $FFB0-$FFBF above are ordinary ROM bytes (code ends at $FFB1).
; ---------------------------------------------------------------------------
rom_header:
	.byte	"CONTRA3 THE ALIEN WAR"	; $FFC0 title (21 bytes, $FFC0-$FFD4)
	.byte	$53	; $FFD5 map mode: invalid. "S" is the 22nd character of the title, which overflows the field (LoROM SlowROM would be $20)
	.byte	$00	; $FFD6 cartridge type: ROM only
	.byte	$0A	; $FFD7 ROM size: 2^10 KiB = 1024 KiB
	.byte	$00	; $FFD8 SRAM size: none
	.byte	$01	; $FFD9 region: North America
	.byte	$A4	; $FFDA developer (licensee) ID: Konami
	.byte	$00	; $FFDB version: 1.0
	.word	$F3C3	; $FFDC checksum complement (checksum ^ $FFFF)
	.word	$0C3C	; $FFDE checksum: 16-bit sum of every ROM byte (matches)
vectors:
	.word	$FFFF	; $FFE0 native: reserved
	.word	$FFFF	; $FFE2 native: reserved
	.addr	irq	; $FFE4 native COP
	.addr	irq	; $FFE6 native BRK
	.addr	irq	; $FFE8 native ABORT
	.addr	nmi	; $FFEA native NMI
	.addr	reset	; $FFEC native: unused
	.addr	irq	; $FFEE native IRQ
	.word	$FFFF	; $FFF0 emulation: reserved
	.word	$FFFF	; $FFF2 emulation: reserved
	.addr	irq	; $FFF4 emulation COP
	.addr	irq	; $FFF6 emulation: unused
	.addr	irq	; $FFF8 emulation ABORT
	.addr	nmi	; $FFFA emulation NMI
	.addr	reset	; $FFFC emulation RESET
	.addr	irq	; $FFFE emulation IRQ/BRK
