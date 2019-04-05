#! /bin/bash

PLUGIN=PhFGimp

rm -rf PhFGimp; git clone https://github.com/aferrero2707/PhFGimp.git || exit 1
cd PhFGimp || exit 1
git rev-parse --verify HEAD > /tmp/commit-${PLUGIN}-new.hash
cd ..
