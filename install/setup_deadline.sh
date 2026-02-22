#!/bin/sh
set -e

echo "----------------------------------------------------"
echo "Checking: Deadline 10 Repository + Client"
echo "----------------------------------------------------"

# Idempotency: skip if repo, client binaries, and deadline.ini are all present
if [ -f /deadline10/repository/settings/connection.ini ] && \
   [ -f /deadline10/client/bin/deadlinecommand.exe ] && \
   [ -f /root/Thinkbox/Deadline10/deadline.ini ]; then
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
fi

# -------------------------------------------------------
# Client install: direct connection + RCS + webservice
# -------------------------------------------------------
if [ -f /deadline10/client/bin/deadlinecommand.exe ]; then
  echo "Client binaries present. Skipping client install."
else
  echo "----------------------------------------------------"
  echo "Installing Deadline 10 Client (RCS + Webservice)"
  echo "----------------------------------------------------"

  mkdir -p /deadline10/client

  # Install with direct repo connection and configure both RCS and webservice.
  # --enabletls false / --webservice_enabletls false: plain HTTP, internal use only.
  # --connserveruser root / --webserviceuser root: running as root in container.
  # --httpport 8080: RCS HTTP port.
  # --webservice_httpport 8081: Webservice HTTP port.
  # The installer writes deadline.ini to /root/Thinkbox/Deadline10/ and
  # /var/lib/Thinkbox/Deadline10/ (both mounted as named volumes).
  "$installers/DeadlineClient-${DEADLINE_VERSION}-linux-x64-installer.run" \
    --debuglevel 4 \
    --mode unattended \
    --prefix /deadline10/client \
    --enable-components proxyconfig,webservice_config \
    --connectiontype Direct \
    --repositorydir /deadline10/repository \
    --noguimode true \
    --slavestartup false \
    --blockautoupdateoverride Blocked \
    --launcherdaemon false \
    --connserveruser root \
    --httpport 8080 \
    --enabletls false \
    --webserviceuser root \
    --webservice_httpport 8081 \
    --webservice_enabletls false

  if [ ! -f /deadline10/client/bin/deadlinecommand.exe ]; then
    echo "ERROR: Client installation failed — deadlinecommand.exe not found."
    exit 1
  fi

  chmod -R 777 /deadline10/client
  echo "Client installation complete."
fi

# -------------------------------------------------------
# Write deadline.ini to both Thinkbox config paths if missing.
# The installer writes it when binaries are freshly installed;
# this block covers the case where volumes are wiped independently.
# -------------------------------------------------------
if [ ! -f /root/Thinkbox/Deadline10/deadline.ini ]; then
  echo "----------------------------------------------------"
  echo "Writing deadline.ini to Thinkbox config paths"
  echo "----------------------------------------------------"

  mkdir -p /root/Thinkbox/Deadline10
  mkdir -p /var/lib/Thinkbox/Deadline10

  cat > /root/Thinkbox/Deadline10/deadline.ini << 'EOF'
[Deadline]
ConnectionType=Direct
NetworkRoot=/deadline10/repository
HttpListenPort=8080
TlsListenPort=0
LaunchRemoteConnectionServerAtStartup=True
KeepRemoteConnectionServerRunning=True
WebServiceHttpListenPort=8081
WebServiceTlsListenPort=0
WebServiceTlsServerCert=
WebServiceTlsCaCert=
WebServiceTlsAuth=False
WebServiceClientSSLAuthentication=NotRequired
LicenseMode=LicenseFree
Region=
LauncherListeningPort=17000
LauncherServiceStartupDelay=60
AutoConfigurationPort=17001
SlaveStartupPort=17003
SlaveDataRoot=
RestartStalledSlave=false
NoGuiMode=true
LaunchSlaveAtStartup=false
AutoUpdateOverride=
IncludeRCSInLauncherMenu=true
RemoteControl=Blocked
DbSSLCertificate=
EOF

  cp /root/Thinkbox/Deadline10/deadline.ini /var/lib/Thinkbox/Deadline10/deadline.ini
  echo "deadline.ini written."
fi

echo "----------------------------------------------------"
echo "Deadline 10 Repository + Client installation complete."
echo "----------------------------------------------------"
exit 0
