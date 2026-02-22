#!/bin/sh
set -e

echo "----------------------------------------------------"
echo "Checking: Deadline 10 Worker Client"
echo "----------------------------------------------------"

# Idempotency: skip if worker binary already installed
if [ -f /deadline10/client/bin/deadlineworker.exe ]; then
  echo "Worker client already installed. Skipping."
  exit 0
fi

sh /opt/setup/pre_install.sh

installers="/opt/setup/d10instalers/Deadline-${DEADLINE_VERSION}-linux-installers"

if [ ! -d "$installers" ]; then
  echo "ERROR: Installer directory not found at $installers"
  exit 1
fi

echo "----------------------------------------------------"
echo "Installing Deadline 10 Worker Client"
echo "----------------------------------------------------"

mkdir -p /deadline10/client

# Install worker client with slavestartup enabled.
# No proxyconfig or webservice_config components — worker only.
# --slavestartup true installs deadlineworker.exe and deadlineslave.exe.
"$installers/DeadlineClient-${DEADLINE_VERSION}-linux-x64-installer.run" \
  --debuglevel 4 \
  --mode unattended \
  --prefix /deadline10/client \
  --connectiontype Direct \
  --repositorydir /deadline10/repository \
  --noguimode true \
  --slavestartup true \
  --blockautoupdateoverride Blocked \
  --launcherdaemon false

if [ ! -f /deadline10/client/bin/deadlineworker.exe ]; then
  echo "ERROR: Worker installation failed — deadlineworker.exe not found."
  exit 1
fi

chmod -R 777 /deadline10/client
echo "Worker client installation complete."

# -------------------------------------------------------
# Write deadline.ini to both Thinkbox config paths.
# -------------------------------------------------------
echo "----------------------------------------------------"
echo "Writing deadline.ini for worker"
echo "----------------------------------------------------"

mkdir -p /root/Thinkbox/Deadline10
mkdir -p /var/lib/Thinkbox/Deadline10

cat > /root/Thinkbox/Deadline10/deadline.ini << 'EOF'
[Deadline]
ConnectionType=Direct
NetworkRoot=/deadline10/repository
LicenseMode=LicenseFree
Region=
LauncherListeningPort=17000
LauncherServiceStartupDelay=60
AutoConfigurationPort=17001
SlaveStartupPort=17003
NoGuiMode=True
LaunchSlaveAtStartup=True
AutoUpdateOverride=Blocked
RemoteControl=Blocked
EOF

cp /root/Thinkbox/Deadline10/deadline.ini /var/lib/Thinkbox/Deadline10/deadline.ini
echo "deadline.ini written."

echo "----------------------------------------------------"
echo "Deadline 10 Worker Client installation complete."
echo "----------------------------------------------------"
exit 0
