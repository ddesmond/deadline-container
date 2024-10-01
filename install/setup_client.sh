#!/bin/sh
echo "Installing Deadline Client"

echo "Downloading Deadline Client"
installers=/tmp/deadline10_installers
destination=/opt/Thinkbox/Deadline10


if [ -d /deadline10/client ]; then
  echo "Client exists. Please remove the old client to install new one. Thanks!"
else
  # permissions
  chmod +x $installers/DeadlineClient-10.3.2.1-linux-x64-installer.run
  mkdir -p /deadline10/client

  # install the client
  $installers/DeadlineClient-10.3.2.1-linux-x64-installer.run \
        --debuglevel 4 \
        --mode unattended \
        --prefix /deadline10/client \
        --repositorydir /deadline10/repository \
        --connectiontype Direct

  cp -v /tmp/deadline.ini /deadline10/client/deadline.ini

  # permissions
  chmod -R 777 /deadline10/client > /dev/null
fi