#! /bin/bash

#AI=GIMP_AppImage-git-2.10.7-20181009-x86_64.AppImage
#AI=GIMP_AppImage-git-2.10.9-20181206-x86_64.AppImage
#AI=GIMP_AppImage-release-2.10.8-x86_64.AppImage
AI=GIMP_AppImage-release-2.10.20-x86_64.AppImage
#if [ x"${GIMP_VERSION}" = "x2.99" ]; then
#	AI=GIMP_AppImage-git-2.99.1-20200628-x86_64.AppImage
#fi

cd /tmp || exit 1
if [ ! -e $AI ]; then
	rm -rf squashfs-root
	wget https://github.com/aferrero2707/gimp-appimage/releases/download/continuous/$AI || exit 1
	chmod u+x $AI
	./$AI --appimage-extract
fi
rm -rf /usr/local/gimp
ln -s "$(pwd)/squashfs-root/usr" /usr/local/gimp || exit 1

echo "ls -l /usr/local/gimp/"
ls -l /usr/local/gimp/

echo "ls -l /usr/local/gimp/lib/"
ls -l /usr/local/gimp/lib/

cd /usr/local/gimp/lib
for L in $(find . -type f -name "*.so.*"); do

	L2=$(echo "$L" | sed -e 's|\(.*\).so.*|\1.so|g')
	if [ ! -e "$L2" ]; then
		echo "ln -s \"$L\" \"$L2\""
		ln -s "$L" "$L2"
	fi

done

mkdir -p /usr/local/lib/pkgconfig
#ln -s libbabl*.so libgegl*.so* libgimp*.so* /usr/local/lib
#ln -s pkgconfig/*.pc /usr/local/lib/pkgconfig
