#! /bin/bash

TARGET_PLUGIN=$1

source ./environment.sh
#brew update
mkdir plugins
bash ./build-common-osx.sh
bash ./${TARGET_PLUGIN}/build-osx.sh
bash ./fix-dylib.sh ${TARGET_PLUGIN}
