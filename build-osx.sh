#! /bin/bash

TARGET_PLUGIN=$1

source ./environment.sh
#brew update
mkdir plugins
bash ./build-common-osx.sh || exit 1
bash ./${TARGET_PLUGIN}/build-osx.sh || exit 1
rm -f /tmp/gimp.app
ln -s /Applications/McGimp-2.10.6.app /tmp/gimp.app || exit 1
bash ./fix-dylib.sh ${TARGET_PLUGIN} "McGimp-2.10.6.app" || exit 1
