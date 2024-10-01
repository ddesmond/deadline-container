#!/bin/sh
echo "Checking Deadline"

if [ -d /deadline10/repository ]; then
  echo "Repository exists. Please remove the old repository to install new one. Thanks!"

else
  echo "Downloading Deadline installer"
  installers=/tmp/deadline10_installers
  destination=/opt/Thinkbox/Deadline10
  mkdir -p $installers
  # download installer outisde of the repo
  echo "Downloaded Deadline installer."
  # permissions
  chmod +x /tmp/Deadline-10.3.2.1-linux-installers.tar


  # create repository directories

  mkdir -p destination

  # permissions
  # extract the installer
  tar -xvf /tmp/Deadline-10.3.2.1-linux-installers.tar -C $installers
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

fi
cp /tmp/connection.ini /deadline10/repository/settings/connection.ini
echo "Done."
exit 0