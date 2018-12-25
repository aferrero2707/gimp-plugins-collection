#! /bin/bash

mkdir -p build || exit 1
cd build

(git clone https://github.com/bootchk/resynthesizer.git && \
cd resynthesizer && git rev-parse --verify HEAD > /tmp/commit-ResynthesizerPlugin-new.hash && \
./autogen.sh --prefix=/usr/local && make -j 2 install) || exit 1

cp -a ${PREFIX}/lib/gimp/2.0/plug-ins/resynthesizer* ../plugins
for P in plugin-heal-selection.py plugin-resynth-sharpen.py plugin-resynth-enlarge.py plugin-uncrop.py plugin-render-texture.py plugin-map-style.py plugin-heal-transparency.py plugin-resynth-fill-pattern.py; do
	cp -a "/usr/local/lib/gimp/2.0/plug-ins/$P" ../plugins
done
