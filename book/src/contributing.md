# Contributing: naming

Milestone 2 gives every routine, table and variable a real name. The work
is spread over several people at once, so it follows the same conventions
and the same checks everywhere.

## The rule

**A wrong name is worse than a number.** Name something only when the code
(or the game running in the emulator) shows what it is, and write down how
you know in a comment next to the definition. If you only have a guess, keep
the generated name and add a comment saying "probably ...". The CDL comments
(`; CDL: read by ...`, `; (not executed in the CDL traces)`) and the `D=`
comments are evidence; keep them.

## Renaming: `tools/rename.py`

```sh
python3 tools/rename.py sub_00816C next_random           # one symbol
python3 tools/rename.py OLD1 NEW1 OLD2 NEW2              # several
python3 tools/rename.py --map names.txt                  # a batch: "OLD NEW" per line, # comments
python3 tools/rename.py -n --map names.txt               # dry run: show the files it would change
python3 tools/rename.py --scope decompress_chunk @old @new     # a cheap local label, inside one scope
```

It replaces whole words (a name inside a path such as `src/engine/nmi.asm` is
left alone) in every file of `src/`, comments included, and in the code spans
and code blocks of the book and `README.md` (not their prose). Names that
could be English words (no `_`, no digit) are not renamed in comments. It
refuses, writing nothing, when the old name isn't defined in `src/`, when
the new name is already used somewhere (a collision), is not a valid ca65
identifier, or is a mnemonic or a register name. A batch is checked as a
whole and applied all at once. The generator's files
(`tools/disasm_hints.json`, `docs/disasm_report.md`) are not changed.

Rename a placeholder rather than defining a second name for the same thing,
so that every use changes with it.

## Conventions

ca65 symbols are case-sensitive; use these forms consistently.

| kind | style | examples |
|---|---|---|
| routine (called, or dispatched from a table) | `snake_case`, verb first | `load_stage_graphics`, `update_players`, `queue_sound`, `next_random` |
| predicate routine (returns a flag in carry or A) | `is_` / `has_` / `check_` | `check_soft_reset` |
| jump target inside a routine | keep `loc_XXXXXX`, or a cheap local `@name` (see below) | `@loop`, `@done` |
| jump table (code pointers) | `tbl_` + what it dispatches | `tbl_game_modes`, `tbl_nmi_handlers` |
| table of data pointers | `ptrs_` + what they point to | `ptrs_stage_palettes` |
| other data | plain noun phrase, plural for arrays | `aim_velocity_x`, `stage_song_sets` |
| RAM variable | `snake_case` noun, no prefix; `p1_` / `p2_` for per-player copies | `stage_number`, `p1_lives`, `frame_counter` |
| constant, structure field offset, command number | `UPPER_CASE` | `OBJ_STATE`, `PLAYER_STATS_STRIDE` |
| hardware register | as in `src/snes_registers.inc` | `INIDISP`, `NMITIMEN` |

More rules:

- **Placeholders.** `sub_`, `loc_`, `tbl_`, `ptrs_`, `data_` + six hex digits
  (ROM) and `zp_XX` / `wram_XXXX` / `wram_7EXXXX` (RAM, see
  [RAM map](ram-map.md)) mean "not named yet". Don't create new names in
  those forms. Data whose kind is known but not its meaning is named
  after its kind and address instead (`anim_05C4CE`, `metasprite_06AEA0`,
  `gfx_0A8000`; list in [Shiftability](shiftability.md)): these are
  placeholders too, rename them freely.
- **References are labels** (milestone 3): never write a ROM address as a
  number. Pointers in code are `#.loword(label)`, banks `#^label`, pointers
  in data `.addr` / `.faraddr` or the macros of `src/data_macros.inc`;
  `tools/datafmt.py label 05:C59A name` adds a label at an address.
  `python3 tools/shift.py scan` must stay at 0.
- **Cheap locals.** In ca65 an `@name` label is only visible between two
  normal labels, and every `loc_XXXXXX` is a normal label, so a cheap local
  can only replace a `loc_` label when nothing outside that span refers to
  it. When in doubt, give the `loc_` label a normal name instead
  (`update_players_next`).
- **Direct-page scratch.** `$00-$0F` (and a few more) are temporaries used
  by many routines with different meanings: leave them as `zp_XX` (or name
  them generically, e.g. `temp0`) instead of giving them the meaning they
  have in one routine.
- **Structure fields.** `lda $12,x` with X pointing at an object slot is a
  field (`lda OBJ_STATE,x`). Use the constants in `src/ram.inc` only after
  checking that X (or Y) really holds an object slot at that instruction;
  the same numbers index other structures elsewhere. Don't turn indexed
  operands into absolute RAM names.
- **Direct page other than 0.** Instructions with a `D=` comment address a
  context structure, not the direct page at `$0000`; name their operands as
  fields of that structure (constants), not as `zp_` variables.
- **Per-player variables.** Player 1's copy at `$1F8x`, player 2's at `$1FCx`
  (stride `$40`); name both (`p1_lives`, `p2_lives`).
- **English**, everywhere: names, comments, commit messages.

## Files

Each file in `src/` starts with its title, address range and a description
(see [Source layout](layout.md)). When you learn what a file holds, update
its header; to split or rename files, `git mv` them, update the `.include`
lines in `src/main.asm` (a bank's files must stay contiguous and in address
order) and the table in [Source layout](layout.md).

## Checking a change

```sh
make                  # the ROM must still match contra3.sha1
make book-check       # every name the book mentions must exist
make emu-test PRIVATE=../contra3-disassembly-private   # when code or data moves
python3 tools/shift.py scan                            # no hardcoded ROM reference of known forms
make shift-test PRIVATE=../contra3-disassembly-private # when converting references
```

A rename that keeps `make` matching changes nothing in the ROM, so
`make emu-test` is only needed when bytes change or move. When you rename
something the book names, `tools/rename.py` fixes the code spans in the
book; check the prose around them still reads right. Document what you name
in [Routines](routines.md) and [RAM map](ram-map.md).

Commit in small steps (one subsystem or one batch of names at a time),
`git pull --rebase` before pushing, and rerun `make` after the rebase.

## Working in parallel

The work is split by file sets so that people rarely touch the same lines:

| area | files |
|---|---|
| A. Engine and sound | `src/engine/` (except `window_effect.asm`), `src/sound/` code files, `src/header.asm` |
| B. Game flow | `src/game/` |
| C. Objects core and players | `src/objects/object_loop.asm`, `secondary_objects.asm`, `sprite_draw.asm`, `player.asm`, `player_weapons.asm`, `player_shots.asm`, `object_helpers_00.asm`, `object_helpers_01.asm`, `src/engine/window_effect.asm`, `src/effects/` |
| D. Object handlers, banks `$00`/`$01` | `src/objects/object_handlers_00a.asm` ... `object_handlers_01b.asm` |
| E. Object handlers, banks `$02`/`$04`/`$1D` | `src/objects/object_handlers_02.asm`, `object_handlers_04a.asm`, `object_handlers_04b.asm`, `object_handlers_1D.asm` |
| F. Top-down stages | `src/topdown/` |

Shared files: `src/ram.inc`, `src/data/tables_05.asm` (most tables), the
book. A symbol belongs to the area whose code defines it (for RAM: the area
whose code writes it, usually its initialisation); rename others' symbols
only after agreeing with them. `src/ram.inc` has one symbol per line sorted
by address, so concurrent renames there only conflict on neighbouring lines.
