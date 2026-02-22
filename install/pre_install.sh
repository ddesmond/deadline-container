#!/bin/sh
set -e
# pre-install dependencies for Deadline containers (Ubuntu 24.04)

export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y wget unzip curl bzip2 libstdc++6 libgomp1 file
