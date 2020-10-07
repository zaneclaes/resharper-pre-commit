#!/bin/sh

set -e

platform=linux
if [ "$(uname)" = "Darwin" ]; then
  platform=macos
fi

root=$(cd "$(dirname "$0")"; pwd)
mono="$root/$platform-x64/mono"

export RIDER_ORIGINAL_MONO_GAC_PREFIX="$MONO_GAC_PREFIX"
export RIDER_ORIGINAL_MONO_PATH="$MONO_PATH"
export RIDER_ORIGINAL_MONO_CONFIG="$MONO_CONFIG"
export RIDER_ORIGINAL_MONO_CFG_DIR="$MONO_CFG_DIR"
export RIDER_ORIGINAL_MONO_TLS_PROVIDER="$MONO_TLS_PROVIDER"
export RIDER_ORIGINAL_MONO_LOCAL_MACHINE_CERTS="$MONO_LOCAL_MACHINE_CERTS"

export MONO_GAC_PREFIX="$mono/lib/mono/gac"
export MONO_PATH="$mono/lib/mono/4.5"
export MONO_CONFIG="$mono/etc/mono/config"
export MONO_CFG_DIR="$mono/etc"
# Custom local machine trust store (bundled in)
export MONO_LOCAL_MACHINE_CERTS="$mono/etc/certs"



# Tuning GC
export MONO_GC_PARAMS=nursery-size=64m

# Starts with El Capitan macOS with enabled SIP not allow pass DYLD_LIBRARY_PATH into child process
if [ "x$platform" = "xmacos" ]; then
  export RIDER_ORIGINAL_DYLD_LIBRARY_PATH="$DYLD_LIBRARY_PATH"
  exec "$mono/bin/env-wrapper" DYLD_LIBRARY_PATH="$mono/lib:$RIDER_MONO_PROFILER_PATH:$DYLD_LIBRARY_PATH" -- "$mono/bin/mono-sgen" "$@"
else
  # Find libMonoPosixHelper.so on Linux
  export RIDER_ORIGINAL_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
  export LD_LIBRARY_PATH="$mono/lib:$LD_LIBRARY_PATH"
  exec "$mono/bin/mono-sgen" "$@"
fi
