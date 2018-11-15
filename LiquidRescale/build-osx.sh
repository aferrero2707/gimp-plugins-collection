#! /bin/bash

cd build

(git clone https://github.com/carlobaldassi/liblqr.git && \
cd liblqr && ./configure --prefix=/usr/local && make -j 2 && make install) || exit 1

(git clone https://github.com/carlobaldassi/gimp-lqr-plugin.git && \
cd gimp-lqr-plugin && ./configure --prefix=/usr/local && make -j 2 && make install) || exit 1

cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/gimp-lqr-plugin ../plugins
cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/plug_in_lqr_iter ../plugins
