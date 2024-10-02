#!/bin/sh
workdir=$(pwd)

rm -rf $workdir/deadline-web-app-frontend
rm -rf $workdir/deadline-web-app-backend

mkdir -p $workdir/deadline-web-app-frontend
mkdir -p $workdir/deadline-web-app-backend

cd $workdir/deadline-web-app-frontend
git clone https://github.com/BreakTools/deadline-web-app-frontend .

cd $workdir/deadline-web-app-backend
git clone https://github.com/BreakTools/deadline-web-app-backend .

