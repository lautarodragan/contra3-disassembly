# RAM map

> **Stub.** This page will be filled in as RAM variables get names
> (milestone 2). Nothing in it is verified yet.

What is known so far comes only from the code around `reset`:

- the stack pointer is set to `$1DFF`;
- the direct page is set to `$0000`.

In the source, RAM is still addressed by number: direct page operands like
`$16`, absolute ones like `a:$1E0A`, and long ones like `f:$7E2000` (the
disassembler doesn't name RAM yet).

When a variable gets a name, add it here with its address, size, what
writes it and what reads it, and how you know.
