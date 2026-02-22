#!/bin/sh
set -e

# ulimits are set via docker-compose.yml; no need to set them here

export DEADLINE_PATH=/deadline10/client

binary=/deadline10/client/bin/deadlinercs.exe
sentinel=/deadline10/repository/settings/connection.ini
timeout=300
elapsed=0
interval=5

echo "----------------------------------------------------"
echo "Waiting for Deadline RCS binary"
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
echo "Waiting for Deadline Repository installation"
echo "----------------------------------------------------"

elapsed=0
while [ ! -f "$sentinel" ]; do
  if [ "$elapsed" -ge "$timeout" ]; then
    echo "ERROR: Repository not ready after ${timeout}s. Exiting."
    exit 1
  fi
  echo "Waiting for repository sentinel ... (${elapsed}s/${timeout}s)"
  sleep "$interval"
  elapsed=$((elapsed + interval))
done

echo "----------------------------------------------------"
echo "Deadline 10 RCS is starting"
echo "----------------------------------------------------"

cd /deadline10/client/bin
exec "$binary"
