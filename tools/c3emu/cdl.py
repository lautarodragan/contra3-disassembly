"""CDL (code/data log) container, file format, merging and coverage report.

The format is specified in docs/CDL_FORMAT.md; keep the two in sync.

    python3 -m tools.c3emu.cdl report cdl/contra3.cdl
    python3 -m tools.c3emu.cdl merge out.cdl a.cdl b.cdl ...
"""
import hashlib
import json
import os
import struct
import sys

MAGIC = b"SNESCDL\0"
VERSION = 1
HEADER = struct.Struct("<8sHHI20sI24x")   # 64 bytes
assert HEADER.size == 64
WRAM_SIZE = 0x20000

# Plane A
OPCODE, OPERAND, DATA, DMA, M0, M1, X0, X1 = (1 << i for i in range(8))
# Plane B
B_EMU, B_NATIVE, B_SUB, B_JUMP, B_INDIRECT, B_RETDISP, B_IRQ, B_PTRTAB = (1 << i for i in range(8))

FLAGS_A = {"OPCODE": OPCODE, "OPERAND": OPERAND, "DATA": DATA, "DMA": DMA,
           "M0": M0, "M1": M1, "X0": X0, "X1": X1}
FLAGS_B = {"EMU": B_EMU, "NATIVE": B_NATIVE, "SUB": B_SUB, "JUMP": B_JUMP,
           "INDIRECT": B_INDIRECT, "RETDISP": B_RETDISP, "IRQ": B_IRQ,
           "PTRTAB": B_PTRTAB}

FLOW_NAMES = {0x6C: "JMP (a)", 0x7C: "JMP (a,X)", 0xDC: "JML [a]",
              0xFC: "JSR (a,X)", 0x60: "RTS", 0x6B: "RTL"}


def lorom_offset(addr):
    """ROM offset of a 24-bit LoROM CPU address, or None."""
    bank, a = addr >> 16, addr & 0xFFFF
    if bank in (0x7E, 0x7F) or a < 0x8000:
        return None
    return (((bank & 0x7F) << 15) | (a & 0x7FFF)) & 0xFFFFF


def lorom_address(off, fast=True):
    """Canonical CPU address of a ROM offset ($80+ banks when fast)."""
    return ((off >> 15) | (0x80 if fast else 0)) << 16 | 0x8000 | (off & 0x7FFF)


def fmt(addr):
    return "%02X:%04X" % (addr >> 16, addr & 0xFFFF)


class Cdl:

    def __init__(self, rom_size, rom_sha1=None):
        self.rom_size = rom_size
        self.rom_sha1 = rom_sha1
        self.a = bytearray(rom_size)
        self.b = bytearray(rom_size)
        self.wram = bytearray(WRAM_SIZE)
        self.readers = [0] * rom_size        # 24-bit PC + 1, 0 = none
        self.flows = {}                      # (op, src, dst) -> [ptr, count]
        self.regs = {}                       # (offset, db, d) -> count
        self.stats = {}

    def add_flow(self, op, src, dst, ptr, count):
        key = (op, src, dst)
        if key in self.flows:
            self.flows[key][1] += count
            if self.flows[key][0] is None:
                self.flows[key][0] = ptr
        else:
            self.flows[key] = [ptr, count]

    def add_regs(self, off, db, d, count):
        key = (off, db, d)
        self.regs[key] = self.regs.get(key, 0) + count

    def merge(self, other):
        if other.rom_size != self.rom_size:
            raise ValueError("ROM sizes differ")
        if self.rom_sha1 and other.rom_sha1 and self.rom_sha1 != other.rom_sha1:
            raise ValueError("CDLs are for different ROMs")
        self.rom_sha1 = self.rom_sha1 or other.rom_sha1
        for i, v in enumerate(other.a):
            if v:
                self.a[i] |= v
        for i, v in enumerate(other.b):
            if v:
                self.b[i] |= v
        for i, v in enumerate(other.wram):
            if v:
                self.wram[i] |= v
        for i, v in enumerate(other.readers):
            if v and not self.readers[i]:
                self.readers[i] = v
        for (op, src, dst), (ptr, count) in other.flows.items():
            self.add_flow(op, src, dst, ptr, count)
        for (off, db, d), count in other.regs.items():
            self.add_regs(off, db, d, count)
        for k, v in other.stats.items():
            self.stats[k] = self.stats.get(k, 0) + v
        return self

    # -- coverage ---------------------------------------------------------------

    def classify(self, i):
        v = self.a[i]
        code = v & (OPCODE | OPERAND)
        data = v & (DATA | DMA) or self.b[i] & B_PTRTAB
        if code and data:
            return "both"
        if code:
            return "code"
        if data:
            return "data"
        return "unknown"

    def coverage(self):
        counts = {"code": 0, "data": 0, "both": 0, "unknown": 0}
        banks = []
        for bank in range(0, self.rom_size, 0x8000):
            c = {"code": 0, "data": 0, "both": 0, "unknown": 0}
            for i in range(bank, min(bank + 0x8000, self.rom_size)):
                c[self.classify(i)] += 1
            for k in c:
                counts[k] += c[k]
            banks.append(c)
        return counts, banks

    def report(self):
        counts, banks = self.coverage()
        n = self.rom_size
        lines = ["ROM bytes: %d" % n]
        for k in ("code", "data", "both", "unknown"):
            lines.append("  %-8s %7d  %6.2f%%" % (k, counts[k], 100.0 * counts[k] / n))
        lines.append("  opcodes  %7d" % sum(1 for v in self.a if v & OPCODE))
        lines.append("  M0+M1 opcodes %d, X0+X1 opcodes %d" % (
            sum(1 for v in self.a if v & M0 and v & M1),
            sum(1 for v in self.a if v & X0 and v & X1)))
        lines.append("  dynamic flow edges %d (%s)" % (
            len(self.flows), ", ".join(
                "%s: %d" % (FLOW_NAMES.get(op, "%02X" % op),
                            sum(1 for k in self.flows if k[0] == op))
                for op in sorted({k[0] for k in self.flows}))))
        lines.append("  WRAM code bytes %d" % sum(1 for v in self.wram if v))
        lines.append("bank  code   data   both   unknown")
        for i, c in enumerate(banks):
            lines.append("$%02X  %5.1f%% %5.1f%% %5.1f%% %5.1f%%" % (
                i | 0x80, *(100.0 * c[k] / 0x8000 for k in ("code", "data", "both", "unknown"))))
        return "\n".join(lines)

    # -- files ----------------------------------------------------------------

    def save(self, path):
        """Writes <path> (binary planes) and <path>.json (sidecar)."""
        sha = bytes.fromhex(self.rom_sha1) if self.rom_sha1 else bytes(20)
        with open(path + ".tmp", "wb") as f:
            f.write(HEADER.pack(MAGIC, VERSION, HEADER.size, self.rom_size, sha, WRAM_SIZE))
            f.write(self.a)
            f.write(self.b)
            f.write(self.wram)
            f.write(struct.pack("<%dI" % self.rom_size, *self.readers))
        os.replace(path + ".tmp", path)
        with open(path + ".json.tmp", "w") as f:
            f.write(self._json())
        os.replace(path + ".json.tmp", path + ".json")

    def _json(self):
        counts, _ = self.coverage()
        flows = []
        for (op, src, dst), (ptr, count) in sorted(self.flows.items(),
                                                     key=lambda kv: (kv[0][1], kv[0][0], kv[0][2])):
            flows.append({
                "op": FLOW_NAMES.get(op, "%02X" % op), "opcode": op,
                "src": fmt(src), "src_offset": lorom_offset(src),
                "dst": fmt(dst), "dst_offset": lorom_offset(dst),
                "ptr": fmt(ptr) if ptr is not None else None,
                "ptr_offset": lorom_offset(ptr) if ptr is not None else None,
                "count": count})
        wram = []
        start = None
        for i in range(WRAM_SIZE + 1):
            v = self.wram[i] if i < WRAM_SIZE else 0
            if v and start is None:
                start = i
            elif not v and start is not None:
                wram.append([start, i])
                start = None
        regs = sorted([off, db, d, c] for (off, db, d), c in self.regs.items())
        head = {
            "format": "snescdl-sidecar", "version": VERSION,
            "rom_sha1": self.rom_sha1, "rom_size": self.rom_size,
            "flags_a": FLAGS_A, "flags_b": FLAGS_B,
            "stats": self.stats, "coverage_bytes": counts,
        }
        out = ["{"]
        for k, v in head.items():
            out.append("  %s: %s," % (json.dumps(k), json.dumps(v)))
        def block(name, items, last=False):
            out.append('  "%s": [' % name)
            for j, it in enumerate(items):
                out.append("    " + json.dumps(it, separators=(",", ":")) +
                           ("," if j + 1 < len(items) else ""))
            out.append("  ]" + ("" if last else ","))
        block("flows", flows)
        block("wram_code", wram)
        block("regs", regs, last=True)
        out.append("}")
        return "\n".join(out) + "\n"

    @classmethod
    def load(cls, path):
        with open(path, "rb") as f:
            raw = f.read()
        magic, version, hsize, size, sha, wsize = HEADER.unpack_from(raw)
        if magic != MAGIC or version != VERSION:
            raise ValueError("%s: not a v%d SNESCDL file" % (path, VERSION))
        cdl = cls(size, sha.hex() if any(sha) else None)
        p = hsize
        cdl.a[:] = raw[p:p + size]; p += size
        cdl.b[:] = raw[p:p + size]; p += size
        cdl.wram[:] = raw[p:p + wsize]; p += wsize
        cdl.readers = list(struct.unpack_from("<%dI" % size, raw, p))
        side = path + ".json"
        if os.path.exists(side):
            with open(side) as f:
                j = json.load(f)
            cdl.stats = j.get("stats", {})
            for fl in j["flows"]:
                src = int(fl["src"].replace(":", ""), 16)
                dst = int(fl["dst"].replace(":", ""), 16)
                ptr = int(fl["ptr"].replace(":", ""), 16) if fl["ptr"] else None
                cdl.add_flow(fl["opcode"], src, dst, ptr, fl["count"])
            for off, db, d, c in j["regs"]:
                cdl.add_regs(off, db, d, c)
        return cdl


def main(argv):
    if len(argv) >= 2 and argv[0] == "report":
        for p in argv[1:]:
            print(p)
            print(Cdl.load(p).report())
    elif len(argv) >= 3 and argv[0] == "merge":
        out = Cdl.load(argv[1]) if os.path.exists(argv[1]) else None
        for p in argv[2:]:
            c = Cdl.load(p)
            out = c if out is None else out.merge(c)
        out.save(argv[1])
        print(out.report())
    else:
        print(__doc__)
        return 2
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
