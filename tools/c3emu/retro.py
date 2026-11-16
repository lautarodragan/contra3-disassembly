"""Drives a libretro core from Python through ctypes. No window, no clock.

Adapted from the-advocate's `tests/emulator/retro.py` (same owner). The
essentials, learnt the hard way there:

  * `retro_run()` advances exactly one frame; input is sampled per frame, and
    the framebuffer comes out through the video callback. Tests become "run N
    frames holding Start, look at frame N": deterministic and fast (snes9x runs
    this game at well over 1000 frames per second).
  * Call order: environment callback BEFORE `retro_init`, every other callback
    AFTER it (mesen-s segfaults otherwise; it is RetroArch's order).
  * `need_fullpath` cores (bsnes) ignore `game->data` and open the path: always
    pass a real path.
  * Answer GET_VARIABLE with each option's default (first value) plus the
    forced ones in CORE_OPTIONS; answering "no" leaves some cores with
    uninitialised settings (bsnes renders black).
  * GET_LOG_INTERFACE is answered "no": the callback is variadic and ctypes
    cannot build it.

Additions for this project: save states (`save_state`/`load_state`), WRAM
read/write, and access to the CDL tracer exported by our patched snes9x
(`retro_cdl_*`, see cores/patches/snes9x-cdl.patch and tools/c3emu/cdl.py).
"""
import ctypes
import hashlib
import os
import shutil
import sys
import tempfile
import weakref

from PIL import Image

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
CORES = os.path.join(ROOT, "build", "cores")
SNES9X = os.path.join(CORES, "snes9x_libretro.so")
BSNES = os.path.join(CORES, "bsnes_libretro.so")


def default_core():
    return os.environ.get("C3_CORE") or SNES9X


ENV_GET_OVERSCAN = 2
ENV_GET_CAN_DUPE = 3
ENV_GET_SYSTEM_DIRECTORY = 9
ENV_SET_PIXEL_FORMAT = 10
ENV_GET_VARIABLE = 15
ENV_SET_VARIABLES = 16
ENV_GET_SAVE_DIRECTORY = 31
PIXEL_FORMATS = {0: "0RGB1555", 1: "XRGB8888", 2: "RGB565"}

# Lines compared: snes9x and bsnes give 224; taller frames are cropped
# around the centre.
HEIGHT = 224

CORE_OPTIONS = {
    # 100% gamma so bsnes matches snes9x pixel for pixel at 15 bits; no WRAM
    # entropy so runs are reproducible (the game's own init is under test,
    # not the power-on garbage).
    "bsnes": {"bsnes_video_gamma": "100", "bsnes_entropy": "None"},
}

# RETRO_DEVICE_JOYPAD ids.
BUTTONS = {"b": 0, "y": 1, "select": 2, "start": 3, "up": 4, "down": 5,
           "left": 6, "right": 7, "a": 8, "x": 9, "l": 10, "r": 11}

MEMORY_SAVE_RAM = 0
MEMORY_SYSTEM_RAM = 2
MEMORY_VIDEO_RAM = 3


def fifteen_bits(image):
    """Pixels at the console's 15-bit precision: each core expands 5 bits per
    channel to 8 its own way, dropping the low 3 bits undoes exactly that."""
    return bytes(v >> 3 for v in image.convert("RGB").tobytes())


class SystemInfo(ctypes.Structure):
    _fields_ = [("library_name", ctypes.c_char_p),
                ("library_version", ctypes.c_char_p),
                ("valid_extensions", ctypes.c_char_p),
                ("need_fullpath", ctypes.c_bool),
                ("block_extract", ctypes.c_bool)]


class Variable(ctypes.Structure):
    _fields_ = [("key", ctypes.c_char_p), ("value", ctypes.c_char_p)]


class GameInfo(ctypes.Structure):
    _fields_ = [("path", ctypes.c_char_p), ("data", ctypes.c_void_p),
                ("size", ctypes.c_size_t), ("meta", ctypes.c_char_p)]


class AvInfo(ctypes.Structure):
    _fields_ = [("base_width", ctypes.c_uint), ("base_height", ctypes.c_uint),
                ("max_width", ctypes.c_uint), ("max_height", ctypes.c_uint),
                ("aspect_ratio", ctypes.c_float),
                ("fps", ctypes.c_double), ("sample_rate", ctypes.c_double)]


# One live Console per core file: libretro cores are process-wide singletons.
_loaded = {}


class Console:
    """One emulated SNES. Only one live Console per core file per process:
    libretro cores are singletons. Creating a new one deinitialises the
    previous one on the same core."""

    def __init__(self, rom, core=None, options=None, audio=False):
        core = os.path.abspath(core or default_core())
        if not os.path.exists(core):
            raise FileNotFoundError("no libretro core at %s (run `make cores`)" % core)
        prev = _loaded.get(core)
        if prev is not None:
            lib, console = prev
            if console() is not None:
                console().close()
        else:
            lib = ctypes.CDLL(core)
        self.lib = lib
        _loaded[core] = (lib, weakref.ref(self))
        self.core_path = core
        self._closed = False
        self.keep_audio = audio
        self.pixel_format = 0
        self.options = {}
        self.frame = None
        self.frame_count = 0
        self.held = [set(), set()]
        self.audio = bytearray()

        L = self.lib
        L.retro_get_memory_data.restype = ctypes.c_void_p
        L.retro_get_memory_size.restype = ctypes.c_size_t
        L.retro_serialize_size.restype = ctypes.c_size_t
        L.retro_serialize.restype = ctypes.c_bool
        L.retro_serialize.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
        L.retro_unserialize.restype = ctypes.c_bool
        L.retro_unserialize.argtypes = [ctypes.c_void_p, ctypes.c_size_t]

        info = SystemInfo()
        L.retro_get_system_info(ctypes.byref(info))
        self.library = info.library_name.decode()
        self.name = "%s %s" % (self.library, info.library_version.decode())
        self._forced = dict(CORE_OPTIONS.get(self.library, {}), **(options or {}))

        data = open(rom, "rb").read()
        self.rom_sha1 = hashlib.sha1(data).hexdigest()
        # A private copy in an empty directory: the core may look next to the
        # ROM for MSU-1 tracks, patches, saves; nothing should be found.
        own_dir = tempfile.mkdtemp(prefix="retro-")
        weakref.finalize(self, shutil.rmtree, own_dir, True)
        path = os.path.join(own_dir, os.path.basename(rom))
        with open(path, "wb") as handle:
            handle.write(data)
        self._directory = ctypes.c_char_p(own_dir.encode())

        self._env = ctypes.CFUNCTYPE(ctypes.c_bool, ctypes.c_uint,
                                     ctypes.c_void_p)(self._on_env)
        self._video = ctypes.CFUNCTYPE(None, ctypes.c_void_p, ctypes.c_uint,
                                       ctypes.c_uint, ctypes.c_size_t)(self._on_video)
        self._audio = ctypes.CFUNCTYPE(ctypes.c_size_t, ctypes.c_void_p,
                                       ctypes.c_size_t)(self._on_audio)
        self._audio_one = ctypes.CFUNCTYPE(None, ctypes.c_int16,
                                           ctypes.c_int16)(lambda i, d: None)
        self._poll = ctypes.CFUNCTYPE(None)(lambda: None)
        self._state = ctypes.CFUNCTYPE(ctypes.c_int16, ctypes.c_uint,
                                       ctypes.c_uint, ctypes.c_uint,
                                       ctypes.c_uint)(self._on_state)

        L.retro_set_environment(self._env)
        L.retro_init()
        L.retro_set_video_refresh(self._video)
        L.retro_set_audio_sample(self._audio_one)
        L.retro_set_audio_sample_batch(self._audio)
        L.retro_set_input_poll(self._poll)
        L.retro_set_input_state(self._state)

        self._buf = ctypes.create_string_buffer(data, len(data))
        game = GameInfo(path.encode(),
                        None if info.need_fullpath
                        else ctypes.cast(self._buf, ctypes.c_void_p),
                        len(data), None)
        # snes9x printf()s the mapper name on load: silence fd 1 (not
        # sys.stdout) and flush libc's buffer before restoring it.
        libc = ctypes.CDLL(None)
        saved = os.dup(1)
        devnull = os.open(os.devnull, os.O_WRONLY)
        sys.stdout.flush()
        os.dup2(devnull, 1)
        try:
            loaded = L.retro_load_game(ctypes.byref(game))
        finally:
            libc.fflush(None)
            os.dup2(saved, 1)
            os.close(devnull)
            os.close(saved)
        if not loaded:
            raise RuntimeError("the core could not load %s" % rom)

    def close(self):
        if not self._closed:
            self._closed = True
            self.lib.retro_unload_game()
            self.lib.retro_deinit()

    # -- callbacks ---------------------------------------------------------

    def _on_env(self, cmd, data):
        if cmd == ENV_SET_VARIABLES and data:
            arr = ctypes.cast(data, ctypes.POINTER(Variable))
            i = 0
            while arr[i].key:
                text = arr[i].value.decode()
                default = text.split(";", 1)[-1].strip().split("|")[0].strip()
                self.options[arr[i].key.decode()] = default
                i += 1
            self.options.update(self._forced)
            return True
        if cmd == ENV_GET_VARIABLE and data:
            var = ctypes.cast(data, ctypes.POINTER(Variable))
            key = var[0].key.decode() if var[0].key else ""
            if key not in self.options:
                return False
            self._alive = getattr(self, "_alive", {})
            self._alive[key] = self.options[key].encode()
            var[0].value = self._alive[key]
            return True
        if cmd == ENV_SET_PIXEL_FORMAT:
            self.pixel_format = ctypes.cast(data, ctypes.POINTER(ctypes.c_int))[0]
            return self.pixel_format in PIXEL_FORMATS
        if cmd in (ENV_GET_OVERSCAN, ENV_GET_CAN_DUPE):
            ctypes.cast(data, ctypes.POINTER(ctypes.c_bool))[0] = True
            return True
        if cmd in (ENV_GET_SYSTEM_DIRECTORY, ENV_GET_SAVE_DIRECTORY) and data:
            ctypes.cast(data, ctypes.POINTER(ctypes.c_char_p))[0] = self._directory
            return True
        return False

    def _on_video(self, data, w, h, pitch):
        if data:
            self.frame = (ctypes.string_at(data, pitch * h), w, h, pitch)
        self.frame_count += 1

    def _on_audio(self, data, frames):
        if data and self.keep_audio:
            self.audio += ctypes.string_at(data, frames * 4)
        return frames

    def _on_state(self, port, device, index, ident):
        if port < 2 and device == 1 and ident in self.held[port]:
            return 1
        return 0

    # -- control -----------------------------------------------------------

    def hold(self, *names, port=0):
        """Buttons held from now on (replaces the previous set)."""
        self.held[port] = {BUTTONS[n] for n in names}

    def run(self, frames=1):
        for _ in range(frames):
            self.lib.retro_run()

    def press(self, *names, frames=2, after=0, port=0):
        """Hold buttons for `frames` frames, release, then run `after` more."""
        self.hold(*names, port=port)
        self.run(frames)
        self.hold(port=port)
        self.run(after)

    def reset(self):
        self.lib.retro_reset()

    # -- save states ---------------------------------------------------------

    def save_state(self):
        size = self.lib.retro_serialize_size()
        buf = ctypes.create_string_buffer(size)
        if not self.lib.retro_serialize(buf, size):
            raise RuntimeError("retro_serialize failed")
        return buf.raw

    def load_state(self, blob):
        buf = ctypes.create_string_buffer(blob, len(blob))
        if not self.lib.retro_unserialize(buf, len(blob)):
            raise RuntimeError("retro_unserialize failed")

    # -- memory --------------------------------------------------------------

    def _mem(self, which):
        base = self.lib.retro_get_memory_data(which)
        total = self.lib.retro_get_memory_size(which)
        if not base or not total:
            raise RuntimeError("this core does not expose memory id %d" % which)
        return base, total

    def ram(self, address=0, length=None):
        """WRAM bytes; `address` is the offset in $7E:0000-$7F:FFFF."""
        base, total = self._mem(MEMORY_SYSTEM_RAM)
        if length is None:
            length = total - address
        return ctypes.string_at(base + address, length)

    def peek(self, address):
        return self.ram(address, 1)[0]

    def peek16(self, address):
        b = self.ram(address, 2)
        return b[0] | b[1] << 8

    def write_ram(self, address, data):
        base, total = self._mem(MEMORY_SYSTEM_RAM)
        if isinstance(data, int):
            data = bytes([data])
        data = bytes(data)
        if address + len(data) > total:
            raise ValueError("write past the end of WRAM")
        ctypes.memmove(base + address, data, len(data))

    def vram(self):
        base, total = self._mem(MEMORY_VIDEO_RAM)
        return ctypes.string_at(base, total)

    def cgram(self):
        """CGRAM as the PPU holds it now: 256 BGR555 words.  libretro does
        not expose it, so it is read from a save state: snes9x's ("#!s9xsnp:")
        `PPU:` block, whose CGDATA (256 big-endian words) is 64 bytes into
        the block (snapshot.cpp, SnapPPU: the VMA, BG and mode fields before
        it).  Other cores: RuntimeError.  The game's palette_buffer
        ($7E:2200) is what the next NMI copies there, when it does."""
        state = self.save_state()
        at = state.find(b"PPU:")
        if not state.startswith(b"#!s9xsnp:") or at < 0:
            raise RuntimeError("cgram(): not a snes9x save state")
        data = at + 11                  # "PPU:" + 6-digit length + ":"
        raw = state[data + 64:data + 64 + 512]
        return [raw[i] << 8 | raw[i + 1] for i in range(0, 512, 2)]

    # -- video ----------------------------------------------------------------

    def image(self):
        """The last frame as a PIL image, RGB, cropped to HEIGHT lines."""
        data, w, h, pitch = self.frame
        if self.pixel_format == 1:
            img = Image.frombuffer("RGBX", (pitch // 4, h), data, "raw", "BGRX", 0, 1)
            img = img.convert("RGB")
        else:
            mode = "BGR;16" if self.pixel_format == 2 else "BGR;15"
            img = Image.frombuffer("RGB", (pitch // 2, h), data, "raw", mode, 0, 1)
        top = max(0, (h - HEIGHT) // 2)
        return img.crop((0, top, w, top + min(h, HEIGHT)))

    # -- CDL tracer (patched snes9x only) ---------------------------------------

    def has_cdl(self):
        try:
            self.lib.retro_cdl_enable
            return True
        except AttributeError:
            return False

    def cdl_enable(self, on=True):
        self.lib.retro_cdl_enable.restype = ctypes.c_uint32
        size = self.lib.retro_cdl_enable(1 if on else 0)
        if on and not size:
            raise RuntimeError("CDL: no ROM loaded")
        return size

    def cdl_snapshot(self):
        """Copies everything the tracer recorded into a tools.c3emu.cdl.Cdl."""
        from .cdl import Cdl
        L = self.lib
        L.retro_cdl_rom_size.restype = ctypes.c_uint32
        for fn in ("retro_cdl_plane_a", "retro_cdl_plane_b", "retro_cdl_wram",
                   "retro_cdl_readers"):
            getattr(L, fn).restype = ctypes.c_void_p
        L.retro_cdl_flows.restype = ctypes.c_size_t
        L.retro_cdl_flows.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
        L.retro_cdl_regs.restype = ctypes.c_size_t
        L.retro_cdl_regs.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
        L.retro_cdl_stat.restype = ctypes.c_uint64
        size = L.retro_cdl_rom_size()
        if not size:
            raise RuntimeError("CDL was never enabled")
        a = ctypes.string_at(L.retro_cdl_plane_a(), size)
        b = ctypes.string_at(L.retro_cdl_plane_b(), size)
        w = ctypes.string_at(L.retro_cdl_wram(), 0x20000)
        readers = (ctypes.c_uint32 * size).from_address(L.retro_cdl_readers())
        n = L.retro_cdl_flows(None, 0)
        fb = (ctypes.c_uint32 * (5 * n))()
        L.retro_cdl_flows(fb, n)
        m = L.retro_cdl_regs(None, 0)
        rb = (ctypes.c_uint32 * (3 * m))()
        L.retro_cdl_regs(rb, m)
        cdl = Cdl(size, self.rom_sha1)
        cdl.a[:] = a
        cdl.b[:] = b
        cdl.wram[:] = w
        cdl.readers = list(readers)
        for i in range(n):
            op, src, dst, ptr, count = fb[5 * i:5 * i + 5]
            cdl.add_flow(op, src, dst, None if ptr == 0xFFFFFFFF else ptr, count)
        for i in range(m):
            off, regs, count = rb[3 * i:3 * i + 3]
            cdl.add_regs(off, regs >> 16, regs & 0xFFFF, count)
        cdl.stats = {"rom_instructions": L.retro_cdl_stat(0),
                     "wram_instructions": L.retro_cdl_stat(1),
                     "other_instructions": L.retro_cdl_stat(2)}
        return cdl

    def cdl_clear(self):
        self.lib.retro_cdl_clear()

    # -- write watch (patched snes9x only) ---------------------------------------

    def watch(self, address, length=1, on=True):
        """Log every CPU/DMA write to WRAM offsets [address, address+length)."""
        self.lib.retro_cdl_watch(ctypes.c_uint32(address), ctypes.c_uint32(length),
                                 1 if on else 0)

    def watch_log(self, clear=True):
        """[(pc24, wram_offset, size, value, frame, by_dma)] since the last call."""
        L = self.lib
        L.retro_cdl_watch_log.restype = ctypes.c_size_t
        L.retro_cdl_watch_log.argtypes = [ctypes.c_void_p, ctypes.c_size_t]
        n = L.retro_cdl_watch_log(None, 0)
        buf = (ctypes.c_uint32 * (4 * n))()
        L.retro_cdl_watch_log(buf, n)
        if clear:
            L.retro_cdl_watch_clear()
        return [(buf[4 * i] & 0xFFFFFF, buf[4 * i + 1] & 0xFFFFFF, buf[4 * i + 1] >> 24,
                 buf[4 * i + 2], buf[4 * i + 3], bool(buf[4 * i] >> 31)) for i in range(n)]
