#!/bin/sh
set -e
# pre-install dependencies for Deadline containers

# Debian Buster is EOL — switch apt to the archive mirror
if grep -q "deb.debian.org" /etc/apt/sources.list 2>/dev/null; then
  sed -i 's|http://deb.debian.org/debian|http://archive.debian.org/debian|g' /etc/apt/sources.list
  sed -i 's|http://deb.debian.org/debian-security|http://archive.debian.org/debian-security|g' /etc/apt/sources.list
  sed -i '/buster-updates/d' /etc/apt/sources.list
fi

apt-get update -y
apt-get install -y wget unzip curl bzip2
