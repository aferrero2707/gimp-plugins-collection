#! /bin/bash

TARGET_PLUGIN=$1

source /sources/environment-appimage.sh
bash /sources/build-common-appimage.sh
bash /sources/${TARGET_PLUGIN}/build-appimage.sh
