#! /bin/bash

mkdir -p build && cd build
if [ -n "$TRAVIS" ]; then
	brew reinstall little-cms2 openexr gettext intltool json-c json-glib glib-networking gexiv2 librsvg poppler gtk+ py2cairo pygtk gtk-mac-integration || exit 1
fi

ls /usr/local/opt
#ls /usr/local/opt/gettext/bin
#ls /usr/local/bin
which autopoint
which gcc
which libtool
#/usr/local/bin/pkg-config --exists --print-errors "pygtk-2.0 >= 2.10.4"
#ls /usr/local/Cellar/exiv2/0.26/lib
#exit

mkdir -p ${PREFIX}/share/aclocal/


#if [ ! -e gettext-0.19.8 ]; then
#	curl -L  https://ftp.gnu.org/gnu/gettext/gettext-0.19.8.tar.gz -O	 || exit 1
#	tar xzvf gettext-0.19.8.tar.gz || exit 1
#	(cd gettext-0.19.8 && ./configure --prefix=${PREFIX} && make -j 3 install) || exit 1
#fi

which xgettext

#exit

if [ ! -e libmypaint-1.3.0 ]; then
	curl -L https://github.com/mypaint/libmypaint/releases/download/v1.3.0/libmypaint-1.3.0.tar.xz -O
	tar xvf libmypaint-1.3.0.tar.xz
	(cd libmypaint-1.3.0 && ./configure --enable-introspection=no --prefix=${PREFIX} && make -j 3 install) || exit 1
fi

if [ ! -e mypaint-brushes ]; then
	git clone -b v1.3.x https://github.com/Jehan/mypaint-brushes
	(cd mypaint-brushes && ./autogen.sh && ./configure --prefix=${PREFIX} && make -j 3 install) || exit 1
fi


if [ ! -e babl ]; then
	(git clone -b BABL_0_1_70 https://git.gnome.org/browse/babl) || exit 1
	(cd babl && TIFF_LIBS="-ltiff -ljpeg -lz" JPEG_LIBS="-ljpeg" ./autogen.sh --disable-gtk-doc --enable-sse3=no --enable-sse4_1=no --enable-f16c=no --enable-altivec=no --prefix=${PREFIX} && make && make -j 3 install) || exit 1
fi

if [ ! -e gegl ]; then
	(git clone -b GEGL_0_4_16 https://git.gnome.org/browse/gegl) || exit 1
	(cd gegl && TIFF_LIBS="-ltiff -ljpeg -lz" JPEG_LIBS="-ljpeg" ./autogen.sh --disable-docs --prefix=${PREFIX} --enable-gtk-doc-html=no --enable-introspection=no && make V=1 -j 3 install) || exit 1
fi

#exit

if [ ! -e gimp ]; then
	(git clone -b GIMP_2_10_12 http://git.gnome.org/browse/gimp) || exit 1
	(cd gimp && patch -p1 < "../../gimp-icons-osx.patch") || exit 1
	(cd gimp && TIFF_LIBS="-ltiff -ljpeg -lz" JPEG_LIBS="-ljpeg" ./autogen.sh --disable-gtk-doc --disable-python --enable-sse=no --prefix=${PREFIX} && make -j 3 install) || exit 1
#(cd gimp && TIFF_LIBS="-ltiff -ljpeg -lz" JPEG_LIBS="-ljpeg" ./configure --disable-gtk-doc --enable-sse=no --prefix=${PREFIX} && make -j 1 install) || exit 1
fi

if [ ! -e optool ]; then
	git clone https://github.com/alexzielenski/optool.git || exit 1
	(cd optool && git submodule update --init --recursive && CC="" xcodebuild build) || exit 1
fi


if [ ! -e macdylibbundler ]; then
	git clone https://github.com/aferrero2707/macdylibbundler.git || exit 1
	(cd macdylibbundler && make) || exit 1
fi
#exit
