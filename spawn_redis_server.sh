#!/bin/sh
# Tester entry point. Must stay at repo root.
# Builds (if needed) and execs the C++ server.
set -e

cd "$(dirname "$0")"
if [ -n "$REDIS_BIN" ]; then
  # Harness-selected binary (e.g. sanitizer build in build-asan/).
  # Already built by harness/run.py, just exec.
  exec "$REDIS_BIN" "$@"
fi

if [ ! -x ./build/redis ]; then
  echo "[your_program] building ./build/redis ..." >&2
  if [ -n "$VCPKG_ROOT" ]; then
    cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE="$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake"
  else
    cmake -B build -S .
  fi
  cmake --build ./build
fi

exec ./build/redis "$@"
