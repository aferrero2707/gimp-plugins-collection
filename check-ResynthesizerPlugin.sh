#! /bin/bash

PLUGIN=ResynthesizerPlugin

rm -rf resynthesizer; git clone https://github.com/bootchk/resynthesizer.git || exit 1
cd resynthesizer || exit 1
git rev-parse --verify HEAD > /tmp/commit-${PLUGIN}-new.hash
cd ..
