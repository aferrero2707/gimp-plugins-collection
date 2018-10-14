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
brew install fftw curl zlib || exit 1
wget https://github.com/aferrero2707/gimp-plugins-collection/releases/download/continuous/qt--5.6.3.yosemite.bottle.tar.gz || exit 1
(cd /usr/local/Cellar && \
  wget https://github.com/aferrero2707/gimp-plugins-collection/releases/download/continuous/qt--5.6.3.yosemite.bottle.tar.gz && \
  tar xf qt--5.6.3.yosemite.bottle.tar.gz && brew link --force qt) || exit 1
#brew link qt --force || exit 1

export PATH="/usr/local/opt/curl/bin:/usr/local/opt/zlib/bin:/usr/local/opt/qt/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/qt/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/opt/curl/lib:/usr/local/opt/zlib/lib:/usr/local/opt/qt/lib:$LD_LIBRARY_PATH"

ls /usr/local/opt/qt/bin

ls /usr/local/opt/curl/lib/pkgconfig
echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"

ls -l /usr/local/Cellar/qt/5.6.3/lib/QtCore.framework/Versions/5/QtCore
otool -L /usr/bin/install_name_tool
exit 1

echo "Generating GMIC headers"
make -C gmic-clone/src CImg.h gmic_stdlib.h || exit 1


echo "Compiling the Qt plug-in"
qmake QMAKE_CFLAGS+="${CFLAGS} -O2" QMAKE_CXXFLAGS+="${CXXFLAGS} -O2" QMAKE_LFLAGS+="${LDFLAGS} -L/usr/X11/lib -lX11 " CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src || exit 1
(make -j 3 && make -j 3 install) || exit 1

cp -a gmic_gimp_qt.app/Contents/MacOS/gmic_gimp_qt ../../plugins
