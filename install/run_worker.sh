#!/bin/sh
set -e

# ulimits are set via docker-compose.worker.yml; no need to set them here

# 'file' is required by the deadlineworker shell wrapper to detect ELF binaries.
# Install it if missing (ubuntu:24.04 does not include it by default).
if ! command -v file >/dev/null 2>&1; then
  echo "Installing 'file' utility..."
  apt-get update -qq && apt-get install -y --no-install-recommends file 2>/dev/null
fi

export DEADLINE_PATH=/deadline10/client
export LD_LIBRARY_PATH=/deadline10/client/lib/python3/lib:${LD_LIBRARY_PATH}

binary=/deadline10/client/bin/deadlinelauncher.exe
ini=/root/Thinkbox/Deadline10/deadline.ini
timeout=1800
elapsed=0
interval=5

echo "----------------------------------------------------"
echo "Waiting for Deadline Worker binary"
echo "----------------------------------------------------"

while [ ! -f "$binary" ]; do
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "ERROR: $binary not found after ${timeout}s. Exiting."
    exit 1
  fi
  echo "Waiting for $binary ... (${elapsed}s/${timeout}s)"
  sleep "$interval"
  elapsed=$((elapsed + interval))
done

echo "----------------------------------------------------"
echo "Waiting for deadline.ini"
echo "----------------------------------------------------"

while [ ! -f "$ini" ]; do
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "ERROR: $ini not found after ${timeout}s. Exiting."
    exit 1
  fi
  echo "Waiting for $ini ... (${elapsed}s/${timeout}s)"
  sleep "$interval"
  elapsed=$((elapsed + interval))
done

echo "----------------------------------------------------"
echo "Deadline 10 Worker (Launcher) is starting"
echo "----------------------------------------------------"

cd /deadline10/client/bin
exec "$binary" -nogui
