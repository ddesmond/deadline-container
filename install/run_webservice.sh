#!/bin/sh
set -e

# ulimits are set via docker-compose.yml; no need to set them here

export DEADLINE_PATH=/deadline10/client

binary=/deadline10/client/bin/deadlinewebservice.exe
timeout=300
elapsed=0
interval=5

echo "----------------------------------------------------"
echo "Waiting for Deadline Webservice binary"
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
echo "Deadline 10 Webservice is starting"
echo "----------------------------------------------------"

cd /deadline10/client/bin
exec "$binary"
