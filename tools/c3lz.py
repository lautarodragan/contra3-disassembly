#!/usr/bin/env python3
"""Contra III's LZ compression format: decompressor and matching compressor.

The game's decompressor is src/engine/decompress.asm (book: Compression).  A
stream is a little-endian length word (counting the word itself) followed by
commands; the output goes to a 1 KiB ring buffer that is cleared to zero and
written from position 0:

    $00-$7F  back-reference: copy (c >> 2) + 2 bytes (2..33) from ring
             position (((c & 3) << 8 | next byte) + $21) & $3FF
    $80-$9F  (c & $1F) literal bytes follow (0..31)
    $A0-$BF  (c & $1F) + 2 times: a zero, then the next literal byte
    $C0-$DF  (c & $1F) + 2 copies of the next byte
    $E0-$FF  (c & $1F) + 2 zeros

Library use:

    from c3lz import decompress, compress
    raw = decompress(stream)                 # bytes -> bytes
    stream = compress(raw, strategy="v2")    # reproduces the ROM's bytes

`compress` takes a strategy name from STRATEGIES.  "v1" and "v2" are the two
versions of the original encoder (every compressed block in the ROM is
reproduced byte for byte by at least one of them; see tools/test_compressor.py);
the others are the alternatives that were tried and are kept for comparison.

Command line:

    python3 tools/c3lz.py d IN OUT              # decompress a stream
    python3 tools/c3lz.py c IN OUT [STRATEGY]   # compress (default v2)
"""
import sys

RING = 0x400          # ring buffer = window size (N)
MAXLEN = 33           # longest back-reference / run (F)
WINDOW = RING - MAXLEN  # farthest back-reference distance the encoder uses (N - F)
PREFILL = MAXLEN      # zero bytes before the data the encoder can match against
OFFSET_BIAS = 0x21    # ring position = (field + $21) & $3FF


def parse(src):
    """Commands of a stream: (kind, out_pos, count, arg, src_pos) tuples.

    kind is 'R' (back-reference, arg = ring position), 'L' (literals),
    'Z' (zero-interleaved, count = pairs), 'B' (byte run, arg = byte) or
    '0' (zero run).  src_pos is the command byte's offset in the stream.
    """
    end = src[0] | src[1] << 8
    p, pos, cmds = 2, 0, []
    while p < end:
        c = src[p]
        at = p
        p += 1
        if c < 0x80:
            n = (c >> 2) + 2
            cmds.append(('R', pos, n, ((c & 3) << 8 | src[p]) + OFFSET_BIAS & RING - 1, at))
            p += 1
        elif c < 0xA0:
            n = c & 0x1F
            cmds.append(('L', pos, n, None, at))
            p += n
        elif c < 0xC0:
            n = (c & 0x1F) + 2
            cmds.append(('Z', pos, n, None, at))
            p += n
            n *= 2
        elif c < 0xE0:
            n = (c & 0x1F) + 2
            cmds.append(('B', pos, n, src[p], at))
            p += 1
        else:
            n = (c & 0x1F) + 2
            cmds.append(('0', pos, n, None, at))
        pos += n
    return cmds


def decompress(src):
    """Decompress a stream exactly as decompress.asm does (whole stream)."""
    end = src[0] | src[1] << 8
    ring = bytearray(RING)  # cleared to zero; writing starts at position 0
    out = bytearray()
    p = 2

    def put(b):
        ring[len(out) & RING - 1] = b
        out.append(b)

    while p < end:
        c = src[p]
        p += 1
        if c < 0x80:
            n = (c >> 2) + 2
            s = ((c & 3) << 8 | src[p]) + OFFSET_BIAS
            p += 1
            for k in range(n):  # byte by byte: may overlap the bytes it writes
                put(ring[s + k & RING - 1])
        elif c < 0xA0:
            for _ in range(c & 0x1F):
                put(src[p])
                p += 1
        elif c < 0xC0:
            for _ in range((c & 0x1F) + 2):
                put(0)
                put(src[p])
                p += 1
        elif c < 0xE0:
            for _ in range((c & 0x1F) + 2):
                put(src[p])
            p += 1
        else:
            for _ in range((c & 0x1F) + 2):
                put(0)
    return bytes(out)


# --------------------------------------------------------------------------
# Match finders.  All work on V = PREFILL zeros + data (+ nothing after the
# end: the original encoder does not match past the end of its input), so V
# index j is data index j - PREFILL, and ring position (j - PREFILL) & $3FF.

def _match_nearest(V, p, maxlen, farthest=False):
    """Longest match at V[p:] with a source in [p - WINDOW, p), may overlap.

    Returns (length, source V index); of the sources with the longest length
    the nearest one (or the farthest one if farthest)."""
    lo = max(0, p - WINDOW)
    best, where, n = 0, -1, 2
    while n <= maxlen:
        j = V.rfind(V[p:p + n], lo, p + n - 1)
        if j < 0:
            break
        best, where = n, j
        n += 1
    if farthest and best:
        where = V.find(V[p:p + best], lo, p + best - 1)
    return best, where


def okumura_matches(data, N=RING, F=MAXLEN, fill=0):
    """(length, source data index) for every data position, as the binary
    tree of Haruhiko Okumura's LZSS.C (1989) reports them: ring N, lookahead
    F, ring prefilled with `fill`, first position r = N - F, the F prefill
    strings before r inserted.  Lengths are clipped to the bytes left."""
    NIL = N
    text = bytearray([fill]) * (N + F - 1)
    lson = [NIL] * (N + 1)
    rson = [NIL] * (N + 257)
    dad = [NIL] * (N + 1)
    res = {}

    def insert(r):
        cmp, key, p = 1, r, N + 1 + text[r]
        rson[r] = lson[r] = NIL
        ml = mp = 0
        while True:
            if cmp >= 0:
                if rson[p] != NIL:
                    p = rson[p]
                else:
                    rson[p], dad[r] = r, p
                    break
            else:
                if lson[p] != NIL:
                    p = lson[p]
                else:
                    lson[p], dad[r] = r, p
                    break
            i = 1
            while i < F:
                cmp = text[key + i] - text[p + i]
                if cmp:
                    break
                i += 1
            if i > ml:
                mp, ml = p, i
                if ml >= F:
                    dad[r], lson[r], rson[r] = dad[p], lson[p], rson[p]
                    dad[lson[p]] = dad[rson[p]] = r
                    if rson[dad[p]] == p:
                        rson[dad[p]] = r
                    else:
                        lson[dad[p]] = r
                    dad[p] = NIL
                    break
        res['ml'], res['mp'] = ml, mp

    def delete(p):
        if dad[p] == NIL:
            return
        if rson[p] == NIL:
            q = lson[p]
        elif lson[p] == NIL:
            q = rson[p]
        else:
            q = lson[p]
            if rson[q] != NIL:
                while rson[q] != NIL:
                    q = rson[q]
                rson[dad[q]] = lson[q]
                dad[lson[q]] = dad[q]
                lson[q] = lson[p]
                dad[lson[p]] = q
            rson[q] = rson[p]
            dad[rson[p]] = q
        dad[q] = dad[p]
        if rson[dad[p]] == p:
            rson[dad[p]] = q
        else:
            lson[dad[p]] = q
        dad[p] = NIL

    s, r, n, ip, length = 0, N - F, len(data), 0, 0
    while length < F and ip < n:
        text[r + length] = data[ip]
        ip += 1
        length += 1
    for i in range(1, F + 1):
        insert(r - i)
    insert(r)
    out, pos = [], 0
    while length > 0:
        ml = min(res['ml'], length)
        # encoder ring position -> data index (ring position r is data pos)
        src = pos - ((r - res['mp']) & N - 1)
        out.append((ml, src))
        pos += 1
        if ip < n:
            delete(s)
            text[s] = data[ip]
            if s < F - 1:
                text[s + N] = data[ip]
            ip += 1
            s, r = s + 1 & N - 1, r + 1 & N - 1
            insert(r)
        else:
            delete(s)
            s, r = s + 1 & N - 1, r + 1 & N - 1
            length -= 1
            if length:
                insert(r)
    return out


# --------------------------------------------------------------------------
# Compressor

def _run(d, i, limit):
    """(byte, length) of the run of equal bytes at d[i], at most limit long."""
    b, k, n = d[i], 1, len(d)
    while k < limit and i + k < n and d[i + k] == b:
        k += 1
    return b, k


def _zero_pairs(d, i, limit=17):
    """Number of (zero, byte) pairs at d[i], at most limit."""
    k, n = 0, len(d)
    while k < limit and i + 2 * k + 1 < n and d[i + 2 * k] == 0:
        k += 1
    return k


def _encode(d, run_margin=0, finder="nearest", runs=True, lazy=False,
            prio="BR0Z", zi_limit=17):
    """Greedy encoder.  At each position it takes the command that saves the
    most bytes over literals (back-reference: length - 2, byte run: length - 2,
    zero run: length - 1, zero-interleaved: pairs - 1), ties broken by `prio`;
    with nothing that saves a byte, a literal (literal runs flushed at 31).

    run_margin: byte and zero runs stop this many bytes before the end of the
    33-byte lookahead (which is shorter near the end of the input).
    finder: 'nearest', 'farthest' or 'okumura' (binary tree of LZSS.C).
    lazy: emit a literal when the position after offers a bigger saving."""
    n = len(d)
    V = bytes(PREFILL) + bytes(d)
    tree = okumura_matches(d) if finder == "okumura" else None
    out = bytearray(b"\0\0")
    lit = bytearray()

    def flush():
        if lit:
            out.append(0x80 | len(lit))
            out.extend(lit)
            lit.clear()

    def options(i):
        look = min(MAXLEN, n - i)
        if tree is not None:
            m, j = tree[i]
            j += PREFILL
        else:
            m, j = _match_nearest(V, i + PREFILL, look, finder == "farthest")
        best = (-1, None, 0, 0)
        cands = {}
        if m >= 2:
            cands['R'] = (m - 2, m, j)
        if runs:
            b, r = _run(d, i, look - run_margin)
            if r >= 2:
                cands['B' if b else '0'] = ((r - 2) if b else (r - 1), r, b)
            z = _zero_pairs(d, i, zi_limit)
            if z >= 2:
                cands['Z'] = (z - 1, z, None)
        for k in prio:
            if k in cands and cands[k][0] > best[0]:
                best = (cands[k][0], k, cands[k][1], cands[k][2])
        return best

    i = 0
    while i < n:
        gain, kind, cnt, arg = options(i)
        if kind is not None and lazy and i + 1 < n and options(i + 1)[0] > gain:
            kind = None
        if kind is None:
            lit.append(d[i])
            i += 1
            if len(lit) == 31:
                flush()
            continue
        flush()
        if kind == 'R':
            f = (arg - PREFILL - OFFSET_BIAS) & RING - 1
            out += bytes((cnt - 2 << 2 | f >> 8, f & 0xFF))
            i += cnt
        elif kind == 'B':
            out += bytes((0xC0 | cnt - 2, arg))
            i += cnt
        elif kind == '0':
            out.append(0xE0 | cnt - 2)
            i += cnt
        else:
            out.append(0xA0 | cnt - 2)
            out += d[i + 1:i + 2 * cnt:2]
            i += 2 * cnt
    flush()
    if len(out) > 0xFFFF:
        raise ValueError("compressed stream longer than $FFFF bytes")
    out[0:2] = len(out).to_bytes(2, "little")
    return bytes(out)


STRATEGIES = {
    # The original encoder, two versions (see the book's Compression page).
    "v1": dict(run_margin=2),
    "v2": dict(run_margin=0),
    # Alternatives, for comparison.
    "okumura": dict(runs=False, finder="okumura"),
    "lzss-nearest": dict(runs=False),
    "v1-okumura-tree": dict(run_margin=2, finder="okumura"),
    "v2-okumura-tree": dict(run_margin=0, finder="okumura"),
    "v2-farthest": dict(run_margin=0, finder="farthest"),
    "v2-lazy": dict(run_margin=0, lazy=True),
}


def compress(data, strategy="v2"):
    """Compress data into a stream the game's decompressor accepts."""
    return _encode(bytes(data), **STRATEGIES[strategy])


def main(argv):
    if len(argv) < 4 or argv[1] not in ("c", "d"):
        print(__doc__)
        return 1
    data = open(argv[2], "rb").read()
    if argv[1] == "d":
        out = decompress(data)
    else:
        out = compress(data, argv[4] if len(argv) > 4 else "v2")
    open(argv[3], "wb").write(out)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
