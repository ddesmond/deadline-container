#!/bin/sh
echo "----------------------------------------------------"
echo "Checking up: Deadline10 Repository"
echo "----------------------------------------------------"


if [ -f /deadline10/repository/settings/connection.ini ]; then
  echo ""
  echo "Repository exists. Dispatching Deadline Client Check"
  echo "If you want to reinstall-rerun Repository installer please remove the old repository to install new one."
  echo "----------------------------------------------------"
  exit 0
else
  echo "Downloading Deadline installer"
  installers=/tmp/deadline10_installers
  destination=/opt/Thinkbox/Deadline10

  mkdir -p $installers
  # download installer outisde of the repo
  echo "Downloaded Deadline installer."
  # permissions
  chmod +x /opt/setup/Deadline-10.3.2.1-linux-installers.tar


  # create repository directories

  mkdir -p destination

  # permissions
  # extract the installer
  tar -xvf /opt/setup/Deadline-10.3.2.1-linux-installers.tar -C $installers
  echo "Deadline installer files extracted to $installers"
  chmod +x $installers/DeadlineRepository-10.3.2.1-linux-x64-installer.run
  echo "Installing Deadline 10 repository from $installers"
  # install the repository
  $installers/DeadlineRepository-10.3.2.1-linux-x64-installer.run \
        --debuglevel 4 \
        --installmongodb false \
        --mode unattended \
        --requireSSL false \
        --dbssl false \
        --prefix /deadline10/repository \
        --dbname deadline10db \
        --dbhost mongodb \
        --dbport 27017

  cp /opt/setup/connection.ini /deadline10/repository/settings/connection.ini
  echo "Done."
  exit 0
fi
