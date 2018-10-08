#! /bin/bash

cd build
if [ ! -e PhFGimp ]; then
	(git clone https://github.com/aferrero2707/PhFGimp.git) || exit 1
	(cd PhFGimp && mkdir -p build && cd build && rm -f CMakeCache.txt && cmake -DCMAKE_SKIP_RPATH=ON .. && make VERBOSE=1 install)
fi


pwd

cp -a PhFGimp/build/file-photoflow PhFGimp/build/phf_gimp ../plugins



exit

./dylibbundler -od -of -x "/Users/aferrero/Projects/gimp-osx/inst/lib/gimp/2.0/plug-ins/file-photoflow" -p @rpath
install_name_tool -add_rpath "@loader_path/../../.." "/Users/aferrero/Projects/gimp-osx/inst/lib/gimp/2.0/plug-ins/file-photoflow"
