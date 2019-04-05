#! /bin/bash

rm -rf gmic-qt; git clone https://github.com/c-koi/gmic-qt.git || exit 1
cd gmic-qt || exit 1
git rev-parse --verify HEAD > /tmp/commit-GMIC-new.hash
rm -rf gmic-clone; git clone https://github.com/dtschump/gmic.git gmic-clone || exit 1
cd gmic-clone
git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash
cd ../../
rm -rf CImg; git clone https://github.com/dtschump/CImg.git || exit 1
cd CImg || exit 1
git rev-parse --verify HEAD >> /tmp/commit-GMIC-new.hash
cd ..
