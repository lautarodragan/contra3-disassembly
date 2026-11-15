; Included once, at the top of main.asm.

.ifndef COMMON_INC
COMMON_INC = 1

.p816
.smart -

.include "snes_registers.inc"
.include "ram.inc"
.include "object_types.inc"
.include "game/game.inc"
.include "data_macros.inc"
.include "cheats.inc"

.endif
