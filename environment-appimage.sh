#! /bin/bash

export GIMP_PREFIX="/usr/local/gimp"

export PATH="${GIMP_PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${GIMP_PREFIX}/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="${GIMP_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export ACLOCAL_PATH="${GIMP_PREFIX}/share/aclocal:$ACLOCAL_PATH"
export ACLOCAL_FLAGS="-I ${GIMP_PREFIX}/share/aclocal $ACLOCAL_FLAGS"
