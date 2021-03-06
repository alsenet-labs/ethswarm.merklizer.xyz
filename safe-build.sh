#!/bin/bash
set -e
set -x

PACKAGE=$1

# run a nodejs container to create the docker volume named $PACKAGE
# and to change the mountpoint ownership
docker run --rm --name $PACKAGE --mount source=$PACKAGE,destination=/home/nodejs/src/$PACKAGE -u root nodejs chown nodejs.nodejs src/$PACKAGE

# create an nodejs container named $PACKAGE to clone and build
# $PACKAGE in the docker volume named $PACKAGE
docker run --name $PACKAGE --mount source=$PACKAGE,destination=/home/nodejs/src/$PACKAGE -i nodejs << EOF
set -x
cd src/$PACKAGE
if [ -d .git ] ; then
  git submodule update --recursive --remote
else 
  git clone --recursive $(git config --get remote.origin.url) .
fi
grep version merklizer/webapp/package.json
make unsafe-build && echo 'The package is available in /var/lib/docker/volumes/$PACKAGE/_data/dist'
EOF
