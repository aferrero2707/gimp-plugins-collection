#! /bin/bash

AI=GIMP_AppImage-git-2.10.7-20181009-x86_64.AppImage
cd /tmp || exit 1
if [ ! -e $AI ]; then
	rm -rf squashfs-root
	wget https://github.com/aferrero2707/gimp-appimage/releases/download/continuous/$AI || exit 1
	chmod u+x $AI
	./$AI --appimage-extract
fi
rm -rf /usr/local/gimp
ln -s "$(pwd)/squashfs-root/usr" /usr/local/gimp || exit 1

