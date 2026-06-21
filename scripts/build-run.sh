#!/usr/bin/env bash
#
# build-run.sh — compile the watchface for every target device, then reload it
# in the Connect IQ simulator.
#
# Usage:
#   scripts/build-run.sh                 # build default devices, run first one in sim
#   scripts/build-run.sh fenix6 fr245    # build only these, run the first one
#   SIM=fr245 scripts/build-run.sh       # build defaults, run fr245 in sim
#   NORUN=1 scripts/build-run.sh         # build only, do not touch the simulator
#
# The SDK location is resolved from Garmin's current-sdk.cfg, so it keeps working
# after an SDK update.

set -u
cd "$(dirname "$0")/.." || exit 1

# --- resolve SDK bin ---------------------------------------------------------
SDK_DIR="$(tr -d '\r\n' < "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg" 2>/dev/null)"
SDK_BIN="${SDK_DIR%/}/bin"
MC="$SDK_BIN/monkeyc"
MD="$SDK_BIN/monkeydo"

if [ ! -x "$MC" ]; then
  echo "ERROR: monkeyc not found at $MC" >&2
  echo "       Check ~/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg" >&2
  exit 1
fi

KEY="developer_key.der"
if [ ! -f "$KEY" ]; then
  echo "ERROR: signing key $KEY not found in $(pwd)" >&2
  exit 1
fi

# --- device list -------------------------------------------------------------
DEFAULT_DEVICES="fenix6 fenix6s fenix6xpro fr245 fr945"
DEVICES="${*:-$DEFAULT_DEVICES}"
SIM="${SIM:-$(echo "$DEVICES" | awk '{print $1}')}"

mkdir -p bin

# --- build -------------------------------------------------------------------
fail=0
for d in $DEVICES; do
  if out=$("$MC" -f monkey.jungle -d "$d" -o "bin/$d.prg" -y "$KEY" 2>&1); then
    echo "OK   $d"
  else
    echo "FAIL $d"
    echo "$out" | grep ERROR | sort -u | head | sed 's/^/   /'
    fail=1
  fi
done

if [ "$fail" -ne 0 ]; then
  echo "=== BUILD FAILED — simulator not reloaded ==="
  exit 1
fi

# --- run in simulator --------------------------------------------------------
if [ "${NORUN:-0}" = "1" ]; then
  echo "=== ALL GREEN (build only) ==="
  exit 0
fi

pkill -f 'monkeydo bin/' 2>/dev/null
sleep 1
"$MD" "bin/$SIM.prg" "$SIM" >/dev/null 2>&1 &
echo "=== ALL GREEN — reloaded $SIM in simulator ==="
