#! /bin/bash

mkdir -p /work/build || exit 1
cd /work/build || exit 1

yum install -y qt5-qtbase-devel qt5-linguist libcurl-devel

#rm -rf gmic-qt
if [ ! -e gmic-qt ]; then
git clone https://github.com/c-koi/gmic-qt.git || exit 1
fi
cd gmic-qt || exit 1
if [ ! -e gmic-clone ]; then
git clone --depth=1 https://framagit.org/dtschump/gmic.git gmic-clone || exit 1
make -C gmic-clone/src CImg.h gmic_stdlib.h || exit 1
fi

qmake-qt5 CONFIG+=Release HOST=gimp GMIC_PATH=gmic-clone/src || exit 1
(make && make) || exit 1

