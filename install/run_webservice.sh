#!/bin/sh
hostname deadline-server
mono --version
ulimit -u unlimited

echo "----------------------------------------------------"
echo "Starting up service for: Deadline10 Webservice"
echo "----------------------------------------------------"
export DEADLINE_PATH=/deadline10/client

#mkdir -p /var/lib/Thinkbox/
#mkdir -p /var/lib/Thinkbox/Deadline10
#cp -v /tmp/deadline-webservice.ini /var/lib/Thinkbox/Deadline10/deadline.ini

if [ -d /deadline10/client ]; then
  echo "Client exists. Please remove the old client to install new one. Thanks!"
  cd /dealine10/client/bin

  echo "Deadline10 Webservice is running"
  /deadline10/client/bin/deadlinewebservice.exe
else
  # permissions
  echo "Waiting deployment of Deadline Client"
  sleep 10
fi

