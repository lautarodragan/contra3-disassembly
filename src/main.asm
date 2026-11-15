; Contra III: The Alien Wars (USA) -- top-level file, the only translation unit.
;
; The linker config (contra3.cfg) places segment BANKxx at $xx:8000.  The
; files of a bank are included in address order inside that bank's segment;
; each file's header gives its address range.  Files do not switch
; segments themselves.

.include "common.inc"

; ---- bank $00 ----
.segment "BANK00"
.include "engine/reset.asm"
.include "engine/random.asm"
.include "engine/nmi.asm"
.include "sound/sound_queue.asm"
.include "engine/init.asm"
.include "engine/math.asm"
.include "engine/joypad.asm"
.include "engine/irq.asm"
.include "engine/vram.asm"
.include "engine/gfx_loader.asm"
.include "sound/spc_upload.asm"
.include "engine/decompress.asm"
.include "sound/sound_load.asm"
.include "engine/palette_tasks.asm"
.include "topdown/vram_streaming.asm"
.include "game/game_modes.asm"
.include "game/attract.asm"
.include "game/screens.asm"
.include "game/stage.asm"
.include "engine/bg_scroll.asm"
.include "objects/object_handlers_00a.asm"
.include "objects/player_shots.asm"
.include "objects/object_handlers_00b.asm"
.include "objects/secondary_objects.asm"
.include "engine/hdma.asm"
.include "engine/window_effect.asm"
.include "objects/object_loop.asm"
.include "objects/sprite_draw.asm"
.include "game/opening.asm"
.include "objects/object_handlers_00c.asm"
.include "objects/object_helpers_00.asm"
.segment "HEADER"		; at $00:FFC0 (contra3.cfg)
.include "header.asm"

; ---- bank $01 ----
.segment "BANK01"
.include "objects/player_weapons.asm"
.include "objects/object_helpers_01.asm"
.include "objects/player.asm"
.include "objects/object_handlers_01a.asm"
.include "objects/object_handlers_01b.asm"
.include "game/stage_palette_anim.asm"

; ---- bank $02 ----
.segment "BANK02"
.include "topdown/stage_states.asm"
.include "topdown/stage_play.asm"
.include "effects/window_shapes.asm"
.include "topdown/stage_play_2.asm"
.include "objects/object_handlers_02.asm"

; ---- bank $03 ----
.segment "BANK03"
.include "topdown/sine_products.asm"
.include "topdown/sprite_render.asm"

; ---- bank $04 ----
.segment "BANK04"
.include "objects/object_handlers_04a.asm"
.include "game/sound_check.asm"
.include "sound/stage_music.asm"
.include "topdown/support_04.asm"
.include "objects/object_handlers_04b.asm"

; ---- bank $05 ----
.segment "BANK05"
.include "data/tables_05.asm"

; ---- bank $06 ----
.segment "BANK06"
.include "data/sprites_06.asm"

; ---- bank $07 ----
.segment "BANK07"
.include "topdown/sprite_data_07.asm"

; ---- bank $08 ----
.segment "BANK08"
.include "gfx/gfx_08.asm"

; ---- bank $09 ----
.segment "BANK09"
.include "gfx/gfx_09.asm"

; ---- bank $0A ----
.segment "BANK0A"
.include "gfx/gfx_0A.asm"

; ---- bank $0B ----
.segment "BANK0B"
.include "gfx/gfx_0B.asm"

; ---- bank $0C ----
.segment "BANK0C"
.include "gfx/gfx_0C.asm"

; ---- bank $0D ----
.segment "BANK0D"
.include "gfx/gfx_0D.asm"

; ---- bank $0E ----
.segment "BANK0E"
.include "gfx/gfx_0E.asm"

; ---- bank $0F ----
.segment "BANK0F"
.include "gfx/gfx_0F.asm"

; ---- bank $10 ----
.segment "BANK10"
.include "gfx/gfx_10.asm"

; ---- bank $11 ----
.segment "BANK11"
.include "gfx/gfx_11.asm"

; ---- bank $12 ----
.segment "BANK12"
.include "gfx/gfx_12.asm"

; ---- bank $13 ----
.segment "BANK13"
.include "gfx/gfx_13.asm"

; ---- bank $14 ----
.segment "BANK14"
.include "gfx/gfx_14.asm"

; ---- bank $15 ----
.segment "BANK15"
.include "gfx/gfx_15.asm"

; ---- bank $16 ----
.segment "BANK16"
.include "gfx/gfx_16.asm"

; ---- bank $17 ----
.segment "BANK17"
.include "gfx/gfx_17.asm"

; ---- bank $18 ----
.segment "BANK18"
.include "gfx/gfx_18.asm"

; ---- bank $19 ----
.segment "BANK19"
.include "gfx/gfx_19.asm"

; ---- bank $1A ----
.segment "BANK1A"
.include "sound/sound_1A.asm"

; ---- bank $1B ----
.segment "BANK1B"
.include "sound/sound_1B.asm"

; ---- bank $1C ----
.segment "BANK1C"
.include "gfx/gfx_1C.asm"

; ---- bank $1D ----
.segment "BANK1D"
.include "sound/sound_1D.asm"
.include "engine/trig.asm"
.include "objects/object_handlers_1D.asm"
.include "data/tables_1D.asm"

; ---- bank $1E ----
.segment "BANK1E"
.include "sound/sound_1E.asm"

; ---- bank $1F ----
.segment "BANK1F"
.include "sound/sound_1F.asm"
