#! /bin/bash

mkdir -p build || exit 1
cd build

(git clone https://github.com/carlobaldassi/liblqr.git && \
cd liblqr && git rev-parse --verify HEAD > /tmp/commit-LiquidRescale-new.hash && \
./configure --prefix=/usr/local && make -j 2 && make install) || exit 1

(git clone https://github.com/carlobaldassi/gimp-lqr-plugin.git && \
cd gimp-lqr-plugin && git rev-parse --verify HEAD >> /tmp/commit-LiquidRescale-new.hash && \
./configure --prefix=/usr/local && make -j 2 && make install) || exit 1

cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/gimp-lqr-plugin ../plugins
cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/plug_in_lqr_iter ../plugins
