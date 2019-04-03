#! /bin/bash

mkdir -p /work/build || exit 1
cd /work/build || exit 1

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

yum install -y qt5-qtbase-devel qt5-linguist libcurl-devel


if [ ! -e gmic-qt ]; then
  (rm -rf gmic gmic-qt && \
   git clone https://github.com/c-koi/gmic-qt.git && cd gmic-qt && \
   git clone https://github.com/dtschump/gmic.git gmic-clone) || exit 1
   #exit 1
fi
(cd /work/build/gmic-qt && \
make -C gmic-clone/src CImg.h gmic_stdlib.h && \
sed -i 's|-Ofast|-Ofast|g' gmic_qt.pro && \
sed -i 's| cimg_use_curl | cimg_use__curl |g' gmic_qt.pro && \
qmake-qt5 CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src && \
sed -i 's|^CURL_CFLAGS = \(.*\)|#CURL_CFLAGS = \1|g' gmic-clone/src/Makefile && \
sed -i 's|^CURL_LIBS = \(.*\)|#CURL_LIBS = \1|g' gmic-clone/src/Makefile && \
make -j 1 && make install) || exit 1

(cd /work/build/gmic-qt && git rev-parse --verify HEAD > /tmp/commit-GMIC-new.hash && \
 cd gmic-clone && git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash && \
 rm -rf CImg-clone && git clone https://github.com/dtschump/CImg.git CImg-clone && \
 cd CImg-clone && git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash)


#mkdir -p "$gimplibdir/plug-ins" || exit 1
#cp -a /work/gmic-qt/gmic_gimp_qt "$gimplibdir/plug-ins" || exit 1



source /work/appimage-helper-scripts/functions.sh

# copy the list of libraries that have to be excluded from the bundle
export APPROOT=/work/gmic-plugin
export APP="GMIC"
export APPDIR="${APPROOT}/$APP.AppDir"
(rm -rf "${APPROOT}" && mkdir -p "${APPROOT}/$APP.AppDir") || exit 1
cp /work/appimage-helper-scripts/excludelist "${APPROOT}"


# enter the AppImage bundle
mkdir -p "$APPDIR/gmic_qt/plug-ins"
cd "$APPDIR/gmic_qt" || exit 1
cp -a /work/build/gmic-qt/gmic_gimp_qt plug-ins || exit 1



# Copy Qt5 plugins
QT5PLUGINDIR=$(pkg-config --variable=plugindir Qt5)
if [ x"$QT5PLUGINDIR" != "x" ]; then
  mkdir -p "usr/lib/qt5/plugins"
  cp -a "$QT5PLUGINDIR"/* "usr/lib/qt5/plugins"
fi

copy_deps2; copy_deps2; copy_deps2;


# Remove unneeded libraries
delete_blacklisted2


cd "$APPDIR/gmic_qt" || exit 1
mkdir -p scripts || exit 1
cp -a "${STARTUP_SCRIPT}" scripts/startup.sh || exit 1


cd "$APPDIR/gmic_qt/usr/lib" || exit 1
for L in $(find . -name "*.so*"); do

	echo "checking $GIMP_PREFIX/lib/$L"
	if [ -e "$GIMP_PREFIX/lib/$L" ]; then
		echo "rm -f $L"
		rm -f "$L"
	fi

done


cd "${APPDIR}" || exit 1
cp -a "${APPRUN_SCRIPT}" AppRun || exit 1
cp -a "${DESKTOP_FILE}" GMIC.desktop || exit 1
cp -a "${ICON_FILE}" GMIC.png || exit 1




# Go out of AppImage
cd ..

echo "Building AppImage..."
pwd
rm -rf ../out

export VERSION=$(grep "define gmic_version " /work/build/gmic-qt/gmic-clone/src/gmic.h | cut -d' ' -f3)-$(date +%Y%m%d)
export ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
generate_type2_appimage

mkdir -p /sources/out
cp -a ../out/*.AppImage /sources/out/GMIC-${VERSION}-Gimp-2.10-$(date +%Y%m%d)-linux.AppImage
cp -a /tmp/commit-GMIC-new.hash /sources/out/GMIC-${VERSION}-Gimp-2.10-$(date +%Y%m%d)-linux.hash
