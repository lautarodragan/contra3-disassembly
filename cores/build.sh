#!/usr/bin/env bash
# Builds a libretro SNES core from a pinned upstream commit.
#
#   cores/build.sh snes9x      -> build/cores/snes9x_libretro.so (with the CDL tracer)
#   cores/build.sh bsnes       -> build/cores/bsnes_libretro.so  (WRAM patch only, second opinion)
#
# Sources are cloned into build/src/<name> (gitignored), reset to the pinned
# commit, patched with cores/patches/<name>-*.patch, and built. Re-running is
# cheap: the clone is reused and make only rebuilds what changed. Delete
# build/src/<name> to start from scratch.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
NAME=${1:?usage: cores/build.sh snes9x|bsnes}
JOBS=${JOBS:-$(nproc)}

case "$NAME" in
  snes9x)
    REPO=https://github.com/libretro/snes9x.git
    COMMIT=fae2fea08f74180759ef540ee94259213f503480   # 2026-09-19
    SUBDIR=libretro
    PRODUCT=snes9x_libretro.so
    MAKEARGS=()
    ;;
  bsnes)
    REPO=https://github.com/libretro/bsnes-libretro.git
    COMMIT=b51612a74c4ff4b91aa55eb094940d9d848e0e96
    SUBDIR=.
    PRODUCT=bsnes_libretro.so
    MAKEARGS=(-f Makefile)
    ;;
  *)
    echo "unknown core: $NAME" >&2; exit 2 ;;
esac

SRC=$ROOT/build/src/$NAME
OUT=$ROOT/build/cores
mkdir -p "$ROOT/build/src" "$OUT"

if [ ! -d "$SRC/.git" ]; then
  git clone --filter=blob:none "$REPO" "$SRC"
fi
cd "$SRC"
if ! git cat-file -e "$COMMIT^{commit}" 2>/dev/null; then
  git fetch origin "$COMMIT"
fi

# Re-apply the patches only when they (or the commit) changed, so that an
# unchanged tree keeps its object files and make stays incremental.
STAMP=$( { cat "$ROOT"/cores/patches/"$NAME"-*.patch 2>/dev/null || true; } | sha1sum | cut -c1-40)-$COMMIT
if [ "$(cat .contra3-stamp 2>/dev/null)" != "$STAMP" ]; then
  git checkout -q -f "$COMMIT"
  git clean -q -fdx
  for p in "$ROOT"/cores/patches/"$NAME"-*.patch; do
    [ -e "$p" ] || continue
    echo "applying $(basename "$p")"
    git apply --whitespace=nowarn "$p"
  done
  echo "$STAMP" > .contra3-stamp
fi

make -C "$SUBDIR" "${MAKEARGS[@]}" -j"$JOBS"
cp "$SUBDIR/$PRODUCT" "$OUT/$PRODUCT"
echo "built $OUT/$PRODUCT"
