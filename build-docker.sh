#! /bin/bash

TARGET_PLUGIN=GMIC
#GIMP_VERSION=2.10
GIMP_VERSION=2.99

docker run -it -v $(pwd):/sources -e TARGET_PLUGIN="${TARGET_PLUGIN}" -e GIMP_VERSION="${GIMP_VERSION}" photoflow/docker-centos7-gimp bash #/sources/travis/build-linux.sh

