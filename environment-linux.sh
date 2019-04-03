#! /bin/bash

export GIMP_PREFIX="/usr/local/gimp"

export PATH="${GIMP_PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${GIMP_PREFIX}/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="${GIMP_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export ACLOCAL_PATH="${GIMP_PREFIX}/share/aclocal:$ACLOCAL_PATH"
export ACLOCAL_FLAGS="-I ${GIMP_PREFIX}/share/aclocal $ACLOCAL_FLAGS"

if [ ! -e /work/appimage-helper-scripts ]; then
	(cd /tmp && rm -rf gimp-appimage && \
	 git clone https://github.com/aferrero2707/gimp-appimage.git gimp-appimage && \
	 rm -rf /work/appimage-helper-scripts && mkdir -p /work && \
	 cp -a gimp-appimage/appimage-helper-scripts /work)
fi

source /work/appimage-helper-scripts/functions.sh

export APPRUN_SCRIPT=/sources/${TARGET_PLUGIN}/AppRun.sh
export STARTUP_SCRIPT=/sources/${TARGET_PLUGIN}/startup-linux.sh
export DESKTOP_FILE=/sources/${TARGET_PLUGIN}/app.desktop
export ICON_FILE=/sources/${TARGET_PLUGIN}/app.png
