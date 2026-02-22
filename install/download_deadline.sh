#!/bin/sh
set -e

tarball="install/Deadline-${DEADLINE_VERSION:-10.4.2.3}-linux-installers.tar"

if [ -f "$tarball" ]; then
  echo "Deadline installer already present: $tarball"
  exit 0
fi

echo "----------------------------------------------------"
echo "Deadline installer not found."
echo "----------------------------------------------------"
echo ""
echo "Download the Deadline ${DEADLINE_VERSION:-10.4.2.3} Linux installer from"
echo "the AWS Thinkbox website and place it at:"
echo ""
echo "  $tarball"
echo ""
echo "Then run 'make dev' to start the stack."
exit 1
