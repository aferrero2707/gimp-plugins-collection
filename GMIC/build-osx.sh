#! /bin/bash

cd build
if [ ! -e gmic-qt ]; then
	echo "Running git clone https://github.com/c-koi/gmic-qt.git"
	git clone https://github.com/c-koi/gmic-qt.git || exit 1
	echo "... finished"
fi
cd gmic-qt || exit 1
if [ ! -e gmic-clone ]; then
	#echo "Running git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone"
	#git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone || exit 1
	echo "Running git clone https://github.com/dtschump/gmic.git gmic-clone"
	git clone https://github.com/dtschump/gmic.git gmic-clone || exit 1
	echo "... finished"
fi

brew cask uninstall oclint
brew install fftw curl qt@5.5 || exit 1
#brew link qt --force || exit 1

export PATH="/usr/local/opt/qt/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/qt/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/opt/qt/lib:$LD_LIBRARY_PATH"

ls /usr/local/opt/qt/bin

echo "Generating GMIC headers"
make -C gmic-clone/src CImg.h gmic_stdlib.h || exit 1


echo "Compiling the Qt plug-in"
qmake QMAKE_CFLAGS+="${CFLAGS} -O2" QMAKE_CXXFLAGS+="${CXXFLAGS} -O2" QMAKE_LFLAGS+="${LDFLAGS} -L/usr/X11/lib -lX11 " CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src || exit 1
(make -j 3 && make -j 3 install) || exit 1

cp -a gmic_gimp_qt.app/Contents/MacOS/gmic_gimp_qt ../../plugins
