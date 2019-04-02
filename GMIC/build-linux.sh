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
mkdir -p "$gimplibdir/plug-ins" || exit 1
cp -a /work/gmic-qt/gmic_gimp_qt "$gimplibdir/plug-ins" || exit 1
