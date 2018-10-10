#! /bin/bash

brew install fftw curl qt || exit 1
#brew link qt --force || exit 1

export PATH="/usr/local/opt/qt/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/qt/lib/pkgconfig"
export LD_LIBRARY_PATH="/usr/local/opt/qt/lib:$LD_LIBRARY_PATH"

ls /usr/local/opt/qt/bin


cd build
if [ ! -e gmic-qt ]; then
	git clone https://github.com/c-koi/gmic-qt.git || exit 1
fi
cd gmic-qt || exit 1
if [ ! -e gmic-clone ]; then
	git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone || exit 1
	make -C gmic-clone/src CImg.h gmic_stdlib.h || exit 1
fi

qmake CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src || exit 1
(make && make install) || exit 1

#cp -a PhFGimp/build/file-photoflow PhFGimp/build/phf_gimp ../plugins
