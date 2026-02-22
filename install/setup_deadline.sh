#!/bin/sh
set -e

echo "----------------------------------------------------"
echo "Checking: Deadline 10 Repository + Client"
echo "----------------------------------------------------"

# Idempotency: skip if both repo and client are already installed
if [ -f /deadline10/repository/settings/connection.ini ] && \
   [ -f /deadline10/client/bin/deadlinecommand.exe ]; then
  echo "Repository and Client already installed. Skipping."
  exit 0
fi

sh /opt/setup/pre_install.sh

installers="/opt/setup/d10instalers/Deadline-${DEADLINE_VERSION}-linux-installers"

if [ ! -d "$installers" ]; then
  echo "ERROR: Installer directory not found at $installers"
  exit 1
fi

# -------------------------------------------------------
# Repository install
# -------------------------------------------------------
if [ -f /deadline10/repository/settings/connection.ini ]; then
  echo "Repository already installed. Skipping repo install."
else
  echo "----------------------------------------------------"
  echo "Installing Deadline 10 Repository from $installers"
  echo "----------------------------------------------------"

  # The repo installer may exit non-zero due to post-install DB validation
  # warnings even when files are installed correctly. Allow it to fail,
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
    --dbhost d10mongodb \
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
fi

# -------------------------------------------------------
# Client install (binaries only)
# -------------------------------------------------------
if [ -f /deadline10/client/bin/deadlinecommand.exe ]; then
  echo "Client already installed. Skipping client install."
else
  echo "----------------------------------------------------"
  echo "Installing Deadline 10 Client from $installers"
  echo "----------------------------------------------------"

  mkdir -p /deadline10/client
  cp -v /opt/setup/deadline.ini /deadline10/client/deadline.ini

  # --binariesonly true skips all post-install configuration (no RSA keygen,
  # no daemon setup). Clean exit expected under QEMU emulation.
  # --enable-components includes RCS (proxyconfig) and webservice binaries.
  "$installers/DeadlineClient-${DEADLINE_VERSION}-linux-x64-installer.run" \
    --debuglevel 4 \
    --mode unattended \
    --prefix /deadline10/client \
    --enable-components proxyconfig,webservice_config \
    --binariesonly true \
    --noguimode true \
    --slavestartup false \
    --blockautoupdateoverride Blocked \
    --launcherdaemon false

  if [ ! -f /deadline10/client/bin/deadlinecommand.exe ]; then
    echo "ERROR: Client installation failed — deadlinecommand.exe not found."
    exit 1
  fi

  chmod -R 777 /deadline10/client
  echo "Client installation complete."
fi

echo "----------------------------------------------------"
echo "Deadline 10 Repository + Client installation complete."
echo "----------------------------------------------------"
exit 0
