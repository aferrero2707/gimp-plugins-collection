#! /bin/bash

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

mkdir -p /work/build || exit 1
cd /work/build || exit 1

if [ ! -e PhFGimp ]; then
	(git clone https://github.com/aferrero2707/PhFGimp.git) || exit 1
fi

(cd PhFGimp && mkdir -p build && cd build && rm -f CMakeCache.txt && cmake .. && make VERBOSE=1) || exit 1

(cd /work/build/PhFGimp && git rev-parse --verify HEAD > /tmp/commit-PhFGimp-new.hash)



source /work/appimage-helper-scripts/functions.sh

# copy the list of libraries that have to be excluded from the bundle
export APPROOT=/work/PhFGimp-plugin
export APP="PhFGimp"
export APPDIR="${APPROOT}/$APP.AppDir"
(rm -rf "${APPROOT}" && mkdir -p "${APPROOT}/$APP.AppDir") || exit 1
cp /work/appimage-helper-scripts/excludelist "${APPROOT}"


# enter the AppImage bundle
mkdir -p "$APPDIR/PhFGimp/plug-ins"
cd "$APPDIR/PhFGimp" || exit 1
cp -a /work/build/PhFGimp/build/file-photoflow /work/build/PhFGimp/build/phf_gimp plug-ins || exit 1

copy_deps2; copy_deps2; copy_deps2;


# Remove unneeded libraries
delete_blacklisted2


cd "$APPDIR/PhFGimp" || exit 1
mkdir -p scripts || exit 1
cp -a "${STARTUP_SCRIPT}" scripts/startup.sh || exit 1


cd "$APPDIR/PhFGimp/usr/lib" || exit 1
for L in $(find . -name "*.so*"); do

	echo "checking $GIMP_PREFIX/lib/$L"
	if [ -e "$GIMP_PREFIX/lib/$L" ]; then
		echo "rm -f $L"
		rm -f "$L"
	fi

done


cd "${APPDIR}" || exit 1
cp -a "${APPRUN_SCRIPT}" AppRun || exit 1
cp -a "${DESKTOP_FILE}" PhFGimp.desktop || exit 1
cp -a "${ICON_FILE}" PhFGimp.png || exit 1




# Go out of AppImage
cd ..

echo "Building AppImage..."
pwd
rm -rf ../out

export VERSION=0.1.0
export ARCH="x86_64"
export NO_GLIBC_VERSION=true
export DOCKER_BUILD=true
generate_type2_appimage

mkdir -p /sources/out
cp -a ../out/*.AppImage /sources/out/PhFGimp-Gimp-2.10-linux.AppImage
cp -a /tmp/commit-PhFGimp-new.hash /sources/out/PhFGimp-Gimp-2.10-linux.hash
