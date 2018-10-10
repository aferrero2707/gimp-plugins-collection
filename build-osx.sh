#! /bin/bash

TARGET_PLUGIN=$1

export HB_PREFIX="$HOME/homebrew"
source ./environment-osx.sh
#brew update
mkdir plugins
bash ./build-common-osx.sh || exit 1
bash ./${TARGET_PLUGIN}/build-osx.sh || exit 1
rm -f /tmp/gimp.app
ln -s /Applications/McGimp-2.10.6.app /tmp/gimp.app || exit 1
bash ./fix-dylib.sh ${TARGET_PLUGIN} "McGimp-2.10.6.app" || exit 1
