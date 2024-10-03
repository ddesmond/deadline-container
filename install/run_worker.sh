
#!/bin/sh
# run pre_install.sh script

export DEADLINE_PATH=/deadline10/client

if [ -f /deadline10/client/bin/deadlineworker.exe ]; then
  cd /deadline10/client/bin
  echo "Deadline10 deadlineworker is Starting"
  /deadline10/client/bin/deadlineworker.exe -nogui
else
  # permissions
  echo "Waiting deployment of Deadline Client and deadlineworker Files"
  sleep 10
fi

