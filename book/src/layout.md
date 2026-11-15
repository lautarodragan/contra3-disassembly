# Source layout

`src/` is split into files by subsystem. `src/main.asm` is the only
translation unit: it includes `src/common.inc` (CPU setup, register and RAM
names, data macros), then for each bank opens the bank's segment (`BANK00` to `BANK1F`,
placed at `$XX:8000` by `src/contra3.cfg`) and includes that bank's files in
address order. The files never switch segments themselves, so a bank's files
must stay contiguous and in order in `src/main.asm`; the first lines of every
file give its title, its address range and what is known about its contents.

| directory | contents |
|---|---|
| `src/engine/` | reset, NMI/IRQ, PPU init, DMA/VRAM, loaders, decompressor, palette tasks, HDMA, math |
| `src/sound/` | sound CPU communication (queue, upload, song sets) and the sound data banks |
| `src/game/` | game mode state machine, attract mode, menus/screens, side-view stage state machine |
| `src/objects/` | object lists and dispatchers, players, weapons, object type handlers, shared helpers |
| `src/topdown/` | the top-down (Mode 7) stages 2 and 5: their state machine, gameplay, sprite projection, Mode 7 map building and data |
| `src/effects/` | window/raster effect shapes |
| `src/data/` | shared tables (bank `$05`), metasprite data (bank `$06`), bank `$1D` tail |
| `src/gfx/` | data-only files of the graphics banks (`$08-$19`, `$1C`) |
| `src/header.asm` | the internal header and the vectors (segment `HEADER`, at `$00:FFC0`) |
| `src/data_macros.inc` | macros for the data formats with pointers (animation scripts, data lists, palette tasks, HDMA lists, player frames) |

The names of the files are as specific as the code allowed so far: where it
is only known that a range holds handlers of object types, the file is named
for that (`object_handlers_01a.asm`), not for a guess. Rename or split files
as their contents get understood; keep a bank's files in order.

## Data files

The banks that only hold data (the files in `src/gfx/`, and `src/sound/sound_1A.asm` and its siblings) are
data-only files of `.byte` lines, without code. Their labels name the
streams that the data lists in `src/data/tables_05.asm` point to; other
blocks start at a CDL comment. A block whose bounds are exact and that
holds no pointers is marked `; ASSET:` (see [Shiftability](shiftability.md)):
those can later be replaced by `.incbin` of files extracted from a
user-supplied ROM (see the
[Introduction](introduction.md#the-rom-and-the-assets)); no binary game data
is committed. Banks `$05`, `$06` and `$07`, and the data blocks inside code
banks, stay as source because they contain pointers; their formats are
macros in `src/data_macros.inc`.

## Files by address

| file | addresses | contents |
|---|---|---|
| `src/engine/reset.asm` | `$00:8000-$00:816B` | Reset: cold boot, warm boot and the main loop |
| `src/engine/random.asm` | `$00:816C-$00:819A` | Random number generator |
| `src/engine/nmi.asm` | `$00:819B-$00:85F2` | NMI handler and per-frame drivers |
| `src/sound/sound_queue.asm` | `$00:85F3-$00:86AB` | Sound command queue |
| `src/engine/init.asm` | `$00:86AC-$00:8985` | PPU init and RAM clear helpers |
| `src/engine/math.asm` | `$00:8986-$00:8B18` | Arithmetic helpers |
| `src/engine/joypad.asm` | `$00:8B19-$00:8BA6` | Joypad input |
| `src/engine/irq.asm` | `$00:8BA7-$00:8CFE` | HDMA channel setup and IRQ handler |
| `src/engine/vram.asm` | `$00:8CFF-$00:90A7` | VRAM transfer queue and VRAM helpers |
| `src/engine/gfx_loader.asm` | `$00:90A8-$00:9323` | Loader for graphics/data lists |
| `src/sound/spc_upload.asm` | `$00:9324-$00:949B` | Sound CPU upload |
| `src/engine/decompress.asm` | `$00:949C-$00:9626` | Decompressor |
| `src/sound/sound_load.asm` | `$00:9627-$00:9970` | Song set loading and sound streaming |
| `src/engine/palette_tasks.asm` | `$00:9971-$00:9C17` | Palette tasks and VRAM script tasks |
| `src/topdown/vram_streaming.asm` | `$00:9C18-$00:A376` | Top-down stages: VRAM streaming |
| `src/game/game_modes.asm` | `$00:A377-$00:AD7B` | Game mode state machine, stage frame (pause, weapon swap) |
| `src/game/attract.asm` | `$00:AD7C-$00:B678` | Attract mode: demo, title screen and menu, Konami logo |
| `src/game/screens.asm` | `$00:B679-$00:BD3F` | Stage clear, OPTION and FINAL SCORE screens; scores |
| `src/game/stage.asm` | `$00:BD40-$00:C282` | Side-view stage state machine |
| `src/engine/bg_scroll.asm` | `$00:C283-$00:CF0B` | BG scrolling, tilemap updates and stage spawning |
| `src/objects/object_handlers_00a.asm` | `$00:CF0C-$00:D655` | Object handlers (bank $00, part 1) |
| `src/objects/player_shots.asm` | `$00:D656-$00:DDC7` | Player shots |
| `src/objects/object_handlers_00b.asm` | `$00:DDC8-$00:E1B7` | Object handlers (bank $00, part 2) |
| `src/objects/secondary_objects.asm` | `$00:E1B8-$00:E368` | Player shots (the secondary object list) |
| `src/engine/hdma.asm` | `$00:E369-$00:E7EE` | HUD, stage HDMA and HDMA tables |
| `src/engine/window_effect.asm` | `$00:E7EF-$00:E95F` | Window effect around a player |
| `src/objects/object_loop.asm` | `$00:E960-$00:EB19` | Object loop and type dispatcher |
| `src/objects/sprite_draw.asm` | `$00:EB1A-$00:EBC3` | Metasprite drawing |
| `src/game/opening.asm` | `$00:EBC4-$00:F27B` | Opening cinematic |
| `src/objects/object_handlers_00c.asm` | `$00:F27C-$00:FD8C` | Object handlers (bank $00, part 3) |
| `src/objects/object_helpers_00.asm` | `$00:FD8D-$00:FFBF` | Object helpers (bank $00) |
| `src/header.asm` | `$00:FFC0-$00:FFFF` | Internal header and vectors |
| `src/objects/player_weapons.asm` | `$01:8000-$01:9E43` | Player weapons |
| `src/objects/object_helpers_01.asm` | `$01:9E44-$01:A547` | Object helpers (bank $01) |
| `src/objects/player.asm` | `$01:A548-$01:B193` | Players |
| `src/objects/object_handlers_01a.asm` | `$01:B194-$01:CF8A` | Object handlers (bank $01, part 1) |
| `src/objects/object_handlers_01b.asm` | `$01:CF8B-$01:F6A7` | Object handlers (bank $01, part 2) |
| `src/game/stage_palette_anim.asm` | `$01:F6A8-$01:FFFF` | Stage palette animation |
| `src/topdown/stage_states.asm` | `$02:8000-$02:8E32` | Top-down stages: state machine and setup |
| `src/topdown/stage_play.asm` | `$02:8E33-$02:DDC5` | Top-down stages: gameplay (part 1) |
| `src/effects/window_shapes.asm` | `$02:DDC6-$02:E65E` | Window shapes |
| `src/topdown/stage_play_2.asm` | `$02:E65F-$02:FCCA` | Top-down stages: gameplay (part 2) |
| `src/objects/object_handlers_02.asm` | `$02:FCCB-$02:FFFF` | Object handlers (bank $02) |
| `src/topdown/sine_products.asm` | `$03:8000-$03:E17F` | Top-down stages: products k*sin(angle) for sprite projection |
| `src/topdown/sprite_render.asm` | `$03:E180-$03:FFFF` | Top-down stages: sprite projection and OAM |
| `src/objects/object_handlers_04a.asm` | `$04:8000-$04:D877` | Object handlers (bank $04, part 1) |
| `src/game/sound_check.asm` | `$04:D878-$04:D9F0` | Sound check mode (game mode 5) |
| `src/sound/stage_music.asm` | `$04:D9F1-$04:DA06` | Stage music |
| `src/topdown/support_04.asm` | `$04:DA07-$04:E21A` | Top-down stages: support routines (bank $04) |
| `src/objects/object_handlers_04b.asm` | `$04:E21B-$04:FFFF` | Object handlers (bank $04, part 2) |
| `src/data/tables_05.asm` | `$05:8000-$05:FFFF` | Shared data tables (bank $05) |
| `src/data/sprites_06.asm` | `$06:8000-$06:FFFF` | Metasprite data (bank $06) |
| `src/topdown/sprite_data_07.asm` | `$07:8000-$07:FFFF` | Top-down stages: sprite data (bank $07) |
| `src/gfx/gfx_08.asm` | `$08:8000-$08:FFFF` | Palettes and compressed graphics (bank $08) |
| `src/gfx/gfx_09.asm` | `$09:8000-$09:FFFF` | Compressed graphics (bank $09) |
| `src/gfx/gfx_0A.asm` | `$0A:8000-$0A:FFFF` | Compressed graphics (bank $0A) |
| `src/gfx/gfx_0B.asm` | `$0B:8000-$0B:FFFF` | Compressed graphics (bank $0B) |
| `src/gfx/gfx_0C.asm` | `$0C:8000-$0C:FFFF` | Compressed graphics (bank $0C) |
| `src/gfx/gfx_0D.asm` | `$0D:8000-$0D:FFFF` | Compressed graphics (bank $0D) |
| `src/gfx/gfx_0E.asm` | `$0E:8000-$0E:FFFF` | Compressed graphics (bank $0E) |
| `src/gfx/gfx_0F.asm` | `$0F:8000-$0F:FFFF` | Compressed graphics (bank $0F) |
| `src/gfx/gfx_10.asm` | `$10:8000-$10:FFFF` | Compressed graphics (bank $10) |
| `src/gfx/gfx_11.asm` | `$11:8000-$11:FFFF` | Compressed graphics (bank $11) |
| `src/gfx/gfx_12.asm` | `$12:8000-$12:FFFF` | Compressed graphics (bank $12) |
| `src/gfx/gfx_13.asm` | `$13:8000-$13:FFFF` | Compressed graphics (bank $13) |
| `src/gfx/gfx_14.asm` | `$14:8000-$14:FFFF` | Compressed graphics (bank $14) |
| `src/gfx/gfx_15.asm` | `$15:8000-$15:FFFF` | Compressed graphics (bank $15) |
| `src/gfx/gfx_16.asm` | `$16:8000-$16:FFFF` | Compressed graphics (bank $16) |
| `src/gfx/gfx_17.asm` | `$17:8000-$17:FFFF` | Compressed graphics (bank $17) |
| `src/gfx/gfx_18.asm` | `$18:8000-$18:FFFF` | Compressed graphics (bank $18) |
| `src/gfx/gfx_19.asm` | `$19:8000-$19:FFFF` | Compressed graphics (bank $19) |
| `src/sound/sound_1A.asm` | `$1A:8000-$1A:FFFF` | Sound data (bank $1A) |
| `src/sound/sound_1B.asm` | `$1B:8000-$1B:FFFF` | Sound data (bank $1B) |
| `src/gfx/gfx_1C.asm` | `$1C:8000-$1C:FFFF` | Compressed graphics (bank $1C) |
| `src/sound/sound_1D.asm` | `$1D:8000-$1D:AB9F` | Sound data (bank $1D, $8000-$AB9F) |
| `src/engine/trig.asm` | `$1D:ABA0-$1D:AF26` | Angle and trigonometry helpers |
| `src/objects/object_handlers_1D.asm` | `$1D:AF27-$1D:CCDF` | Object handlers (bank $1D) |
| `src/data/tables_1D.asm` | `$1D:CCE0-$1D:FFFF` | Data (bank $1D, $CCE0-$FFFF) |
| `src/sound/sound_1E.asm` | `$1E:8000-$1E:FFFF` | Sound data (bank $1E) |
| `src/sound/sound_1F.asm` | `$1F:8000-$1F:FFFF` | Sound data (bank $1F) |

## The generator

`tools/disasm.py` still writes one file per bank (`bank_00.asm` ...) into
`build/disasm/`. It cannot reproduce this layout, and the hand edits made
since (names, RAM symbols, comments) make its output differ from `src/` more
and more; it is kept as a reference and research tool (see
[The disassembler](disassembler.md)).
