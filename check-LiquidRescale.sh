#! /bin/bash

PLUGIN=LiquidRescale

rm -rf liblqr; git clone https://github.com/carlobaldassi/liblqr.git || exit 1
cd liblqr || exit 1
git rev-parse --verify HEAD > /tmp/commit-${PLUGIN}-new.hash
cd ..
rm -rf gimp-lqr-plugin; git clone https://github.com/carlobaldassi/gimp-lqr-plugin.git || exit 1
cd gimp-lqr-plugin || exit 1
git rev-parse --verify HEAD >> /tmp/commit-${PLUGIN}-new.hash
cd ..
