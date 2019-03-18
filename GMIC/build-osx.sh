#! /bin/bash

cd build
if [ ! -e gmic-qt ]; then
	echo "Running git clone https://github.com/c-koi/gmic-qt.git"
	git clone https://github.com/c-koi/gmic-qt.git || exit 1
	echo "... finished"
fi
cd gmic-qt || exit 1
git rev-parse --verify HEAD > /tmp/commit-GMIC-new.hash || exit 1
if [ ! -e gmic-clone ]; then
	#echo "Running git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone"
	#git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone || exit 1
	echo "Running git clone https://github.com/dtschump/gmic.git gmic-clone"
	git clone https://github.com/dtschump/gmic.git gmic-clone || exit 1
	echo "... finished"
	patch -p1 < ../../GMIC/gmic-plugins-path.patch
	cd gmic-clone || exit 1
	git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash || exit 1
	cd ..
	
	rm -rf CImg-clone; git clone https://github.com/dtschump/CImg.git CImg-clone || exit 1
	cd CImg-clone || exit 1
	git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash
	cd ..

fi

brew cask uninstall oclint
brew install fftw curl zlib || exit 1

if [ "x" = "y" ]; then
#HASH=9ba3d6ef8891e5c15dbdc9333f857b13711d4e97 #qt@5.5
#QTPREFIX="qt@5.5"
HASH=13d52537d1e0e5f913de46390123436d220035f6 #qt 5.9
QTPREFIX="qt"
(cd $( brew --prefix )/Homebrew/Library/Taps/homebrew/homebrew-core && \
  git pull --unshallow && git checkout $HASH -- Formula/${QTPREFIX}.rb && \
  cat Formula/${QTPREFIX}.rb | sed -e 's|depends_on :mysql|depends_on "mysql-client"|g' | sed -e 's|depends_on :postgresql|depends_on "postgresql"|g' > /tmp/${QTPREFIX}.rb && cp /tmp/${QTPREFIX}.rb Formula/${QTPREFIX}.rb &&
  cat Formula/${QTPREFIX}.rb && brew install ${QTPREFIX} && brew link --force ${QTPREFIX}) || exit 1

#wget https://github.com/aferrero2707/gimp-plugins-collection/releases/download/continuous/qt--5.6.3.yosemite.bottle.tar.gz || exit 1
#(cd /usr/local/Cellar && \
#  wget https://github.com/aferrero2707/gimp-plugins-collection/releases/download/continuous/qt--5.6.3.yosemite.bottle.tar.gz && \
#  tar xf qt--5.6.3.yosemite.bottle.tar.gz && brew link --force qt) || exit 1
#brew link ${QTPREFIX} --force || exit 1
else
  brew install qt || exit 1
  brew link --force qt || exit 1
fi

export PATH="/usr/local/opt/curl/bin:/usr/local/opt/zlib/bin:/usr/local/opt/${QTPREFIX}/bin:$PATH"
export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig:/usr/local/opt/zlib/lib/pkgconfig:/usr/local/opt/${QTPREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/opt/curl/lib:/usr/local/opt/zlib/lib:/usr/local/opt/${QTPREFIX}/lib:$LD_LIBRARY_PATH"

#ls /usr/local/opt/qt/bin

#ls /usr/local/opt/curl/lib/pkgconfig

#ls /usr/local/opt/${QTPREFIX}/lib
#ls /usr/local/opt/${QTPREFIX}/lib/pkgconfig
#exit 1
#echo "PKG_CONFIG_PATH: $PKG_CONFIG_PATH"

#ls -l /usr/local/Cellar/qt/5.6.3/lib/QtCore.framework/Versions/5/QtCore
#otool -L /usr/bin/install_name_tool
#exit 1

echo "Generating GMIC headers"
make -C gmic-clone/src CImg.h gmic_stdlib.h || exit 1


echo "Compiling the Qt plug-in"
qmake QMAKE_CFLAGS+="${CFLAGS} -O2" QMAKE_CXXFLAGS+="${CXXFLAGS} -O2" QMAKE_LFLAGS+="${LDFLAGS} -L/usr/X11/lib -lX11 " CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src || exit 1
/sources/travis_wait.sh &
(make -j 3 && make -j 3 install) || exit 1

cp -a gmic_gimp_qt.app/Contents/MacOS/gmic_gimp_qt ../../plugins
