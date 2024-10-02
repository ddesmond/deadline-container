#!/bin/sh
hostname deadline-webservice
mono --version

export DEADLINE_PATH=/deadline10/client

if [ -d /deadline10/client ]; then
  cd /deadline10/client/bin
  echo "Deadline10 Webservice is Starting"
  /deadline10/client/bin/deadlinewebservice.exe
else
  # permissions
  echo "Waiting deployment of Deadline Client and Webservice Files"
  sleep 10
fi

