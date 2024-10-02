#!/bin/sh
workdir=$(pwd)
setup_done=false

if [ -f /.setup_done ] ;then
  echo "setup done"
else
  apt-get update
  apt-get install -y \
    git \
    gcc \
    g++ \
    libopenexr-dev \
    openexr \
    && rm -rf /var/lib/apt/lists/*

  pip install --upgrade pip
  setup_done=true
  touch /.setup_done
  git clone https://github.com/BreakTools/deadline-web-app-backend .
  pip install -r /app/requirements.txt
fi
python /app/src/launcher.py
