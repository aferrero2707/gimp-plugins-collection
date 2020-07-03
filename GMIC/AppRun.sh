#!/bin/bash

DIR="`dirname \"$0\"`" 
DIR="`( cd \"$DIR\" && readlink -f $(pwd) )`"
echo "DIR: $DIR"
export APPDIR=$DIR

DESTDIR="$HOME/.config/GIMP-AppImage/2.10/plug-ins"
if [ $# -gt 0 ]; then DESTDIR="$1"; fi
mkdir -p "$DESTDIR" || exit 1

rm -rf "$DESTDIR/GMIC"
cp -a "$APPDIR/GMIC" "$DESTDIR"