# Introduction

This book documents the disassembly of *Contra III: The Alien Wars* for the
SNES (USA release): a set of [ca65](https://cc65.github.io/) sources in
[lautarodragan/contra3-disassembly](https://github.com/lautarodragan/contra3-disassembly)
that assemble back into the original ROM, byte for byte.

The repository's `README.md` is the quick reference (how to build, the
layout, the generator's options). The book is the longer explanation, and the
place where what we learn about the game gets written down as the work goes
on: what the cartridge looks like, how the disassembler arrived at the
current source, what is in RAM and what each routine does.

## Goals

The work is planned in steps, each one keeping the build byte-identical to
the original:

1. **A matching build.** Generated source for all 32 banks that ca65/ld65
   assemble into a ROM with the original's SHA-1. This is done: see
   [Building](building.md) and [Progress](progress.md).
2. **Semantic names, many files.** Every routine and variable gets a real
   name instead of an address (`load_data_list` today), and the 32 bank files are
   split into files by subsystem.
3. **Shiftable.** No hard-coded ROM address anywhere, in code or in data
   tables, so code and data can grow or move and the game still works. Today
   every absolute and long operand that points into ROM is a label, but many
   immediates that are really pointers and the pointers inside data tables
   are still numbers (see [Progress](progress.md)).
4. **Cheats.** Optional changes to the game, chosen with build flags, on top
   of a source that otherwise still builds the original.

## The ROM and the assets

Right now the build doesn't need the original ROM: everything, graphics and
music included, is in `src/` as `.byte` lines generated from it. The plan is
to change that later: once the data is understood, the build will require a
ROM supplied by the user, check it against `contra3.sha1`, and extract the
assets (graphics, palettes, music and so on) from it into files the build
uses, so that the repository holds the code and the knowledge of how to read
the data, not the data.

Either way, never commit a ROM: `*.sfc`, `*.smc` and `*.zip` are in
`.gitignore`.

## This book

The sources are in `book/src/`, built with [mdBook](https://rust-lang.github.io/mdBook/)
and published to GitHub Pages by `.github/workflows/book.yml` on every push to
`main` that touches the book. See [Building](building.md#the-book) for how to
build it locally and for the names check, which fails CI when a page names a
label, constant or file that isn't in the code anymore. When you rename
something, fix the pages that name it in the same commit.

Write only what you checked in the code or by running the game, and say how
you know it when it isn't obvious.

For a quick tour of what the work has found so far (bugs in the original
code, unused debug features, tables that share their bytes), start with
[Curiosities](curiosities.md).
