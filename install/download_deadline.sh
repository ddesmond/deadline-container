#!/bin/sh
workdir=$(pwd)

link="https://thinkbox-installers.s3.us-west-2.amazonaws.com/Releases/Deadline/10.3/7_10.3.2.1/Deadline-10.3.2.1-linux-installers.tar"

echo "Downloading Deadline installer"
# download the installer
wget -O install/Deadline.tar $link
# permissions
chmod +x install/Deadline.tar
echo "Downloaded Deadline installer."
