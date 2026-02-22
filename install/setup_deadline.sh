#!/bin/sh
set -e

echo "----------------------------------------------------"
echo "Checking: Deadline 10 Repository"
echo "----------------------------------------------------"

# Idempotency: skip if repository is already installed
if [ -f /deadline10/repository/settings/connection.ini ]; then
  echo "Repository already installed. Skipping."
  exit 0
fi

sh /opt/setup/pre_install.sh

installers="/opt/setup/d10instalers/Deadline-${DEADLINE_VERSION}-linux-installers"

if [ ! -d "$installers" ]; then
  echo "ERROR: Installer directory not found at $installers"
  exit 1
fi

echo "----------------------------------------------------"
echo "Installing Deadline 10 Repository"
echo "----------------------------------------------------"

# The repo installer may exit non-zero due to post-install DB validation
# warnings even when files install correctly. Allow it to fail,
# then verify the settings directory exists.
"$installers/DeadlineRepository-${DEADLINE_VERSION}-linux-x64-installer.run" \
  --debuglevel 4 \
  --mode unattended \
  --installmongodb false \
  --requireSSL false \
  --dbssl false \
  --dbauth false \
  --prefix /deadline10/repository \
  --dbname deadline10db \
  --dbhost host.docker.internal \
  --dbport 27017 \
  --setpermissions true \
  --backuprepo false \
  --installSecretsManagement false || true

if [ ! -d /deadline10/repository/settings ]; then
  echo "ERROR: Repository installation failed — settings directory not found."
  exit 1
fi

cp /opt/setup/connection.ini /deadline10/repository/settings/connection.ini
echo "Repository installation complete."

echo "----------------------------------------------------"
echo "Deadline 10 Repository installation complete."
echo "----------------------------------------------------"
exit 0
