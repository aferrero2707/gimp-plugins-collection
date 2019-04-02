#! /bin/bash

source /sources/environment-linux.sh
bash /sources/build-common-linux.sh
bash /sources/${TARGET_PLUGIN}/build-linux.sh
