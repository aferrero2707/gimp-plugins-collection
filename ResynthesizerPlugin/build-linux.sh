#! /bin/bash

gimplibdir=$(pkg-config --variable=gimplibdir gimp-2.0)
echo "gimplibdir: $gimplibdir"
if [ -z "$gimplibdir" ]; then exit 1; fi

yum install -y exiv2-devel || exit 1

mkdir -p /work/build || exit 1
cd /work/build || exit 1

if [ ! -e resynthesizer ]; then
	(git clone https://github.com/bootchk/resynthesizer.git) || exit 1
fi

(cd /work/build/resynthesizer && ./autogen.sh --prefix=/usr/local && make -j 2 install) || exit 1

(cd /work/build/resynthesizer && git rev-parse --verify HEAD > /tmp/commit-ResynthesizerPlugin-new.hash)



source /work/appimage-helper-scripts/functions.sh

# copy the list of libraries that have to be excluded from the bundle
export APPROOT=/work/ResynthesizerPlugin-plugin
export APP="ResynthesizerPlugin"
export APPDIR="${APPROOT}/$APP.AppDir"
(rm -rf "${APPROOT}" && mkdir -p "${APPROOT}/$APP.AppDir") || exit 1
cp /work/appimage-helper-scripts/excludelist "${APPROOT}"


# enter the AppImage bundle
mkdir -p "$APPDIR/ResynthesizerPlugin/plug-ins"
cd "$APPDIR/ResynthesizerPlugin" || exit 1
cp -a "$gimplibdir/plug-ins"/resynthesizer* plug-ins
for P in plugin-heal-selection.py plugin-resynth-sharpen.py plugin-resynth-enlarge.py plugin-uncrop.py plugin-render-texture.py plugin-map-style.py plugin-heal-transparency.py plugin-resynth-fill-pattern.py; do
	cp -a "/usr/local/lib/gimp/2.0/plug-ins/$P" plug-ins
done

copy_deps2; copy_deps2; copy_deps2;


# Remove unneeded libraries
delete_blacklisted2


cd "$APPDIR/ResynthesizerPlugin" || exit 1
mkdir -p scripts || exit 1
cp -a "${STARTUP_SCRIPT}" scripts/startup.sh || exit 1

echo "export GIMP_RESYNTHESIZER_PLUGIN_EXISTS=1" > scripts/set_exists.sh
echo 'if [ x"${GIMP_RESYNTHESIZER_PLUGIN_EXISTS}" = "x1" ]; then exit 1; fi; exit 0;' > scripts/check_exists.sh


cd "$APPDIR/ResynthesizerPlugin/usr/lib" || exit 1
for L in $(find . -name "*.so*"); do

	echo "checking $GIMP_PREFIX/lib/$L"
	if [ -e "$GIMP_PREFIX/lib/$L" ]; then
		echo "rm -f $L"
		rm -f "$L"
	fi

done


cd "${APPDIR}" || exit 1
cp -a "${APPRUN_SCRIPT}" AppRun || exit 1
cp -a "${DESKTOP_FILE}" ResynthesizerPlugin.desktop || exit 1
cp -a "${ICON_FILE}" ResynthesizerPlugin.png || exit 1




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
cp -a ../out/*.AppImage /sources/out/ResynthesizerPlugin-Gimp-2.10-linux.AppImage
cp -a /tmp/commit-ResynthesizerPlugin-new.hash /sources/out/ResynthesizerPlugin-Gimp-2.10-linux.hash
