#! /bin/bash

mkdir -p build || exit 1
cd build

(git clone https://github.com/bootchk/resynthesizer.git && \
cd resynthesizer && git rev-parse --verify HEAD > /tmp/commit-Resynthesizer-new.hash && \
./autogen.sh --prefix=/usr/local && make -j 2 install) || exit 1

cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/gimp-lqr-plugin ../plugins
cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/plug_in_lqr_iter ../plugins
