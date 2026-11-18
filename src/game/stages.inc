; game/stages.inc -- the number and order of the stages. Included by common.inc.
;
; Every place that depends on a stage's number goes through the constants
; and macros of this file (the book: Game flow, "Stage numbering", and
; "Adding a stage"):
;
; - STAGE_n is the stage_number of the original game's stage n: compare
;   stage_number with it (`cmp #STAGE_4`), never with a bare number;
; - a table indexed by stage_number (or stage_index) lists its entries with
;   per_stage_byte / per_stage_word / per_stage_addr, which take them in
;   the original order (stages 1-6, then the extra stage) and emit them in
;   play order;
; - the side-view tables indexed by stage_layout (stage_init) list theirs
;   with per_layout_word / per_layout_addr.
;
; With CHEAT_EXTRA_STAGE = 0 (the default) everything assembles to the
; original bytes.  With CHEAT_EXTRA_STAGE = 1 (`make cheats
; CHEATS=extra_stage`) a new side-view stage, STAGE_EXTRA, is inserted as
; stage 2 and the original stages 2-6 become 3-7; it has its own layout
; (LAYOUT_EXTRA), and every per-stage table has an entry for it (the "sx" /
; "lx" arguments of the macros): "Collapsed Tower" (book: Stage 2: Collapsed
; Tower), its own BG1 map and spawn lists on stage 1's graphics, mid-boss
; and boss (game/extra_stage.asm, data/tables_05.asm).

.ifndef STAGES_INC
STAGES_INC = 1

; 1: the extra-stage build (a build variant, not a cheat; it goes through
; tools/cheats.py so that it can be combined with the cheats): a new
; side-view stage inserted as stage 2 ("Collapsed Tower"), the original
; stages 2-6 become 3-7.
.ifndef CHEAT_EXTRA_STAGE
CHEAT_EXTRA_STAGE = 0
.endif

.assert CHEAT_EXTRA_STAGE = 0 || CHEAT_EXTRA_STAGE = 1, error, "CHEAT_EXTRA_STAGE: 0 or 1"

; --- stage numbers (stage_number; stage_index = stage_number - 1) ----------

STAGE_OPENING   = 0	; the opening cinematic runs as side-view stage 0 (game_mode_opening)
STAGE_1         = 1	; original stage 1 (side view)
.if CHEAT_EXTRA_STAGE
STAGE_EXTRA     = 2	; the inserted stage (side view, layout LAYOUT_EXTRA)
STAGE_2         = 3	; original stage 2 (top-down)
STAGE_3         = 4	; original stage 3 (side view)
STAGE_4         = 5	; original stage 4 (side view)
STAGE_5         = 6	; original stage 5 (top-down)
STAGE_6         = 7	; original stage 6 (side view; the ending)
.else
STAGE_2         = 2	; top-down
STAGE_3         = 3	; side view
STAGE_4         = 4	; side view
STAGE_5         = 5	; top-down
STAGE_6         = 6	; side view; the ending
.endif
STAGE_COUNT     = 6 + CHEAT_EXTRA_STAGE	; stages of a loop (stage select: 1-STAGE_COUNT)
STAGE_LAST      = STAGE_6	; the stage after which the game loops or ends (game_mode_stage_play)

; --- side-view layouts (stage_layout, x2; stage_layouts[stage_number]) ----

LAYOUT_STAGE1   = $00
LAYOUT_STAGE3   = $02
LAYOUT_STAGE4   = $04
LAYOUT_STAGE6   = $06
LAYOUT_OPENING  = $08
.if CHEAT_EXTRA_STAGE
LAYOUT_EXTRA    = $0A
.endif
LAYOUT_COUNT    = 5 + CHEAT_EXTRA_STAGE
; stage_init adds this to the layout when the stage restarts past its
; midpoint (stage_checkpoint): the tables by stage_layout list every layout
; and then every layout's checkpoint version.
LAYOUT_CHECKPOINT = LAYOUT_COUNT * 2

; --- per-stage tables ------------------------------------------------------
;
; Arguments: the entries of the original stages 1-6, then sx, the extra
; stage's (used only when CHEAT_EXTRA_STAGE).  Emitted in play order: 1,
; [extra], 2, 3, 4, 5, 6.  An empty s6 emits no entry for the last stage
; (tables that end before it, such as the stage clear pictures).  Entry 0
; (stage 0, the opening), when a table has one, is written before the macro.

.macro per_stage_byte s1, s2, s3, s4, s5, s6, sx
	.byte	s1
  .if CHEAT_EXTRA_STAGE
    .ifblank sx
	.error	"per_stage_byte: no entry for the extra stage"
    .endif
	.byte	sx
  .endif
	.byte	s2, s3, s4, s5
  .ifnblank s6
	.byte	s6
  .endif
.endmacro

.macro per_stage_word s1, s2, s3, s4, s5, s6, sx
	.word	s1
  .if CHEAT_EXTRA_STAGE
    .ifblank sx
	.error	"per_stage_word: no entry for the extra stage"
    .endif
	.word	sx
  .endif
	.word	s2, s3, s4, s5
  .ifnblank s6
	.word	s6
  .endif
.endmacro

.macro per_stage_addr s1, s2, s3, s4, s5, s6, sx
	.addr	s1
  .if CHEAT_EXTRA_STAGE
    .ifblank sx
	.error	"per_stage_addr: no entry for the extra stage"
    .endif
	.addr	sx
  .endif
	.addr	s2, s3, s4, s5
  .ifnblank s6
	.addr	s6
  .endif
.endmacro

; --- per-layout tables -----------------------------------------------------
;
; Arguments: the entries of the layouts of stages 1, 3, 4, 6 and of the
; opening, then lx, the extra stage's layout (used only when
; CHEAT_EXTRA_STAGE).  A table by stage_layout uses the macro twice: the
; layouts, then their checkpoint versions (LAYOUT_CHECKPOINT bytes in).  An
; empty lop emits no entry for the opening (a table whose last entry is the
; start of the next one); the extra-stage build then needs one, so give it.

.macro per_layout_word l1, l3, l4, l6, lop, lx
	.word	l1, l3, l4, l6
  .ifnblank lop
	.word	lop
  .endif
  .if CHEAT_EXTRA_STAGE
    .ifblank lx
	.error	"per_layout_word: no entry for the extra stage's layout"
    .endif
    .ifblank lop
	.error	"per_layout_word: the extra stage's layout comes after the opening's"
    .endif
	.word	lx
  .endif
.endmacro

.macro per_layout_addr l1, l3, l4, l6, lop, lx
	.addr	l1, l3, l4, l6
  .ifnblank lop
	.addr	lop
  .endif
  .if CHEAT_EXTRA_STAGE
    .ifblank lx
	.error	"per_layout_addr: no entry for the extra stage's layout"
    .endif
    .ifblank lop
	.error	"per_layout_addr: the extra stage's layout comes after the opening's"
    .endif
	.addr	lx
  .endif
.endmacro

.endif
