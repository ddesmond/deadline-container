#!/bin/sh
workdir=$(pwd)
apt-get update
apt-get install -y \
    git \
    gcc \
    g++ \
    libopenexr-dev \
    openexr \
    && rm -rf /var/lib/apt/lists/*

pip install --upgrade pip

if [ -f /app/src/launcher.py ]; then
  pip install --no-cache-dir -r /app/requirements.txt
  echo "Files exist. Please remove the old files/ update to install new one."
else
  rm -rf $/app/
  mkdir -p /app
  cd /app

  git clone https://github.com/BreakTools/deadline-web-app-backend .
  pip install --no-cache-dir -r /app/requirements.txt
fi

python /app/src/launcher.py