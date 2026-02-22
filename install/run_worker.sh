#!/bin/sh
set -e

export DEADLINE_PATH=/deadline10/client

echo "----------------------------------------------------"
echo "Deadline 10 Worker — setup"
echo "----------------------------------------------------"

# Install worker client if not already installed (idempotent)
sh /opt/setup/setup_worker.sh

echo "----------------------------------------------------"
echo "Deadline 10 Worker (Launcher) is starting"
echo "----------------------------------------------------"

cd /deadline10/client/bin
exec /deadline10/client/bin/deadlinelauncher.exe -nogui
