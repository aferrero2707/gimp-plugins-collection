#! /bin/bash

source ./environment-osx.sh
brew update || exit 1
bash ./build-common-osx.sh || exit 1
tar czf osx-cache.tgz inst

wget -c https://github.com/aferrero2707/uploadtool/raw/master/upload_rotate.sh
bash  ./upload_rotate.sh "continuous" *.tgz
