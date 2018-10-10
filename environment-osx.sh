#! /bin/bash

#export HB_PREFIX="$HOME/homebrew"
export HB_PREFIX="/usr/local"
export PREFIX=$(pwd)/inst

export PATH="${HB_PREFIX}/opt/gettext/bin:${HB_PREFIX}/opt/jpeg-turbo:${HB_PREFIX}/bin:$PATH"
export LD_LIBRARY_PATH="${HB_PREFIX}/opt/gettext/lib:${HB_PREFIX}/opt/jpeg-turbo/lib:${HB_PREFIX}/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="${HB_PREFIX}/opt/jpeg-turbo/lib/pkgconfig:${HB_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH"
export ACLOCAL_PATH="${HB_PREFIX}/opt/gettext/share/aclocal:${HB_PREFIX}/share/aclocal:$ACLOCAL_PATH"
export ACLOCAL_FLAGS="-I ${HB_PREFIX}/opt/gettext/share/aclocal -I ${HB_PREFIX}/share/aclocal $ACLOCAL_FLAGS"

export LD_LIBRARY_PATH="${HB_PREFIX}/opt/libffi/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="${HB_PREFIX}/opt/libffi/lib/pkgconfig:$PKG_CONFIG_PATH"

export PATH="$PREFIX/bin:$PATH"
export LD_LIBRARY_PATH="$PREFIX/lib:$LD_LIBRARY_PATH"
export PKG_CONFIG_PATH="$PREFIX/lib/pkgconfig:$PREFIX/share/pkgconfig:$PKG_CONFIG_PATH"
export ACLOCAL_PATH="$PREFIX/share/aclocal:$ACLOCAL_PATH"
export ACLOCAL_FLAGS="-I $PREFIX/share/aclocal/ $ACLOCAL_FLAGS"

export LIBRARY_PATH="$LD_LIBRARY_PATH"

export LIBTOOLIZE=glibtoolize

export CC="gcc -mmacosx-version-min=10.8 -fno-stack-protector -march=nocona -mno-sse3 -mtune=generic -I$PREFIX/include -I${HB_PREFIX}/include -I${HB_PREFIX}/opt/gettext/include -I/usr/X11/include"
export CXX="g++ -mmacosx-version-min=10.8 -fno-stack-protector -march=nocona -mno-sse3 -mtune=generic -I$PREFIX/include -I${HB_PREFIX}/opt/gettext/include -I${HB_PREFIX}/include -I/usr/X11/include"
export CFLAGS="-fno-stack-protector -O0 -I$PREFIX/include -I${HB_PREFIX}/opt/gettext/include -I${HB_PREFIX}/include -I/usr/X11/include"
export CPPFLAGS="$CFLAGS"
export CXXFLAGS="-fno-stack-protector -O0 -stdlib=libc++ -I$PREFIX/include -I${HB_PREFIX}/opt/gettext/include -I${HB_PREFIX}/include -I/usr/X11/include"
export LDFLAGS="-L$PREFIX/lib -L${HB_PREFIX}/lib -framework Cocoa"
