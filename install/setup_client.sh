#!/bin/sh

ulimit -n unlimited

installers=/tmp/deadline10_installers
destination=/opt/Thinkbox/Deadline10
echo "Checking Deadline client Files"


if [ -f /deadline10/client/bin/deadlinecommand.exe ]; then
  echo "Client files exist. Please remove the old client to install new one."
  exit 0
else
  # run pre_install.sh script
  sh /opt/setup/pre_install.sh
  echo "Installing Deadline Client Files"
  #echo " - Downloading Deadline Client"
    # permissions
  # extract the installer
  mkdir -p $installers
  tar -xvf /opt/setup/Deadline-10.3.2.1-linux-installers.tar -C $installers
  echo "Deadline client installer files extracted to $installers"
  chmod +x $installers/*
  echo "Installing Deadline 10 client files from $installers"
  # permissions
  chmod +x $installers/DeadlineClient-10.3.2.1-linux-x64-installer.run
  mkdir -p /deadline10/client
  cp -v /opt/setup/deadline.ini /deadline10/client/deadline.ini

  # install the client
  $installers/DeadlineClient-10.3.2.1-linux-x64-installer.run \
        --debuglevel 4 \
        --mode unattended \
        --prefix /deadline10/client \
        --repositorydir /deadline10/repository \
        --connectiontype Direct

  # permissions
  chmod -R 777 /deadline10/client > /dev/null
fi
