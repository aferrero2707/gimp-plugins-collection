#! /bin/bash

cd build

(git clone https://github.com/carlobaldassi/liblqr.git && \
cd liblqr && ./configure --prefix=/usr/local && make -j 2 install) || exit 1

(git clone https://github.com/carlobaldassi/gimp-lqr-plugin.git && \
cd gimp-lqr-plugin && ./configure --prefix=/usr/local && make -j 2 install) || exit 1
