#!/bin/sh

set -e -u

D=$(dirname "$0")
exec "$D/runtime.sh" "$D/inspectcode.exe" "$@"