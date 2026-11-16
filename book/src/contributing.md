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
  `python3 tools/shift.py scan` must stay at 0: it also fails on any
  16-bit immediate `>= $8000` that is loaded or compared (`lda`, `ldx`,
  `ldy`, `cmp`, `cpx`, `cpy`) and is neither a label expression nor marked
  `; [num]`. Put the marker only after checking how the value is used (a
  negative number, a mask, a WRAM or VRAM address, a colour...);
  `scan --list` prints the unmarked ones.
- **Layout.** When code reads a table past its label into the next block
  (or points into the middle of a block), put a comment `; LAYOUT: why`
  right after the next block's label, so that the shift test does not
  separate them (`tools/layoutcheck.py` finds some of these).
- **Cheap locals.** In ca65 an `@name` label is only visible between two
  normal labels, and every `loc_XXXXXX` is a normal label, so a cheap local
  can only replace a `loc_` label when nothing outside that span refers to
  it. When in doubt, give the `loc_` label a normal name instead
  (`update_players_next`). `tools/localize.py` does the checking; see
  [Cheap locals](#cheap-locals-toolslocalizepy) below.
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

## Cheap locals: `tools/localize.py`

Most `loc_XXXXXX` labels are jump targets inside one routine. Turned into
cheap locals, they leave the normal labels to the routines (and their
second entry points), so the structure shows at a glance, and `@loop`,
`@done` or `@next_slot` say more than an address.

**Scope.** A cheap local is visible from the previous normal symbol
definition to the next one. In ca65 that is not only a label `name:` but
also `name = ...`, `name := ...`, `name .set ...`, `.proc`/`.scope`, and a
macro whose body defines a label. A `.define` or a data directive does not
end the span. Every `loc_` is a normal label, so converting one merges the
spans on both sides of it: whether a label can be converted depends on which
others are converted too, and two `@return` that were apart can end up in
one span.

**When a label stays normal.** When something outside its span uses it:
another routine (a branch into the middle of it, a `jmp`/`jml`/`brl` from a
neighbour: it is a routine entry or a shared tail and deserves a semantic
name such as `kill_player_tail`), another file, a data table (`.addr`,
`.word`, `.faraddr`, the macros of `src/data_macros.inc`), an expression
(`#.loword(...)`, `label+1`, `jmp (label,x)`), the book or a tool. Labels
inside `.if`/`.else` (the cheat options) also stay normal, so that every
build assembles.

**Names.** Use the generic names only for what the code shows by its shape,
and a semantic name when the code shows the purpose:

| name | where |
|---|---|
| `@loop` (`@loop2` ...) | the top of a loop: the target of a backward branch that the code from the label can reach (a backward branch to an error exit that returns is not a loop) |
| `@done` | right after the branch that closes a loop, branched to from inside the loop |
| `@next` | inside a loop, entered by forward branches from the loop, followed only by the few instructions that advance and test (the "continue" point) |
| `@return`, `@return_clc`, `@return_sec` | `rts`/`rtl`/`rti`, or `clc`/`sec` and then a return |
| semantic: `@wait_vblank`, `@next_channel`, `@windows_off`, `@not_visible` | when the code shows what the label is for |

A label that fits none of these stays `loc_` until someone knows what it
is: a positional name such as `@L1` or `@skip3` says no more than the
address and loses the address. Several names in one span are numbered in
source order (`@loop`, `@loop2`), as elsewhere in the source.

**The tool.**

```sh
python3 tools/localize.py analyze [file|dir ...]              # per file: convertible / must stay, by reason
python3 tools/localize.py analyze --list src/objects/player.asm   # the decision for every label
python3 tools/localize.py analyze --entries                   # loc_ labels that look like routine entries
python3 tools/localize.py suggest src/objects/player.asm > names.txt   # automatic names, as a map to edit
python3 tools/localize.py apply src/objects/player.asm --map names.txt [--auto] [-n] [--check]
```

`analyze` reads the whole of `src/`, the book, `README.md` and `tools/*.py`
(the tools to find names they rely on), and computes the convertible
labels as a fixpoint: it assumes every candidate is converted and drops,
until nothing changes, those with a reference outside their span. The
reasons a label must stay: `entry` (used by another routine), `blocked`
(used across another `loc_` that must stay; name that one and re-run),
`other-file`, `expression`, `conditional`, `external` (the book or a tool),
`no-scope` (before the first label of its file). The `auto` column counts
what `apply --auto` converts by itself: only labels that match a pattern
*and* stay reachable while the unnamed labels around them stay `loc_`, so
naming a few labels by hand often lets more of the automatic ones through.

`apply` takes a map of `loc_XXXXXX @name` lines (and `OLD new_name` lines
for labels that stay normal, passed to `tools/rename.py`); `--auto` adds the
automatic names of the given files that the map does not mention. It
rewrites the definitions, the references and the comments (a comment
outside the span, or in another file, gets `@name in routine`), and refuses,
writing nothing, a label that is not convertible, one whose reference
would end up outside its span because a label in between stays, a name
that is not `@` + lower-case snake_case (or is a mnemonic or a register),
and two definitions of one name in a span, existing cheap locals included.
It does not build unless given `--check` (which runs `make`); either way
check as for any rename: `make`, `python3 tools/shift.py scan`,
`make book-check`. Renaming a cheap local afterwards:
`tools/rename.py --scope routine @old @new`.

Other tools: `tools/datafmt.py label` refuses an address that has a cheap
local (a normal label there would split the span), and `tools/shift_diag.py`
looks for `@next_char:` in `src/engine/vram.asm`. `ld65`'s debug file and
`tools/srcmap.py` list cheap locals by their bare name (`@loop` many times):
`SrcMap.labels` keeps only one address per name, `SrcMap.cheap_labels`
lists them all.

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
make emu-test         # when code or data moves (needs make cores)
python3 tools/shift.py scan                            # no hardcoded ROM reference of known forms
make shift-test       # when converting references
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
