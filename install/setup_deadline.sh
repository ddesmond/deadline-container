#!/bin/sh
# run pre_install.sh script

ulimit -n unlimited

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
  sh /opt/setup/pre_install.sh
  echo "Getting Deadline installer"
  installers=/tmp/deadline10_installers
  destination=/opt/Thinkbox/Deadline10

  # download installer outisde of the repo

  # permissions
  chmod +x /opt/setup/Deadline.tar
  # create repository directories
  mkdir -p $installers
  mkdir -p destination

  # permissions
  # extract the installer
  tar -xvf /opt/setup/Deadline.tar -C $installers
  echo "Deadline installer files extracted to $installers"
  chmod +x $installers/*
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
