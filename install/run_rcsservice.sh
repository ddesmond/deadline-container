#!/bin/sh

ulimit -n unimited
ulimit -a

mono --version

export DEADLINE_PATH=/deadline10/client

if [ -f /deadline10/client/bin/deadlinercs.exe ]; then
  cd /deadline10/client/bin
  echo "Deadline10 RCSservice is Starting"
  /deadline10/client/bin/deadlinercs.exe
else
  # permissions
  echo "Waiting deployment of Deadline Client and Service Files"
  sleep 10
fi

