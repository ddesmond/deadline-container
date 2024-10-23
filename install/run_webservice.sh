#!/bin/sh
# run pre_install.sh script

sudo ulimit -u unlimited

export DEADLINE_PATH=/deadline10/client

if [ -f /deadline10/client/bin/deadlinewebservice.exe ]; then
  cd /deadline10/client/bin
  echo "Deadline10 Webservice is Starting"
  /deadline10/client/bin/deadlinewebservice.exe
else
  # permissions
  echo "Waiting deployment of Deadline Client and Webservice Files"
  sleep 10
fi

