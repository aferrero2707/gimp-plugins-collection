#!/bin/bash

DIR="`dirname \"$0\"`" 
DIR="`( cd \"$DIR\" && readlink -f $(pwd) )`"
echo "DIR: $DIR"
export APPDIR=$DIR

mkdir -p "$HOME/.config/GIMP-AppImage/2.10/plug-ins"
cp -a "$APPDIR/gmic_qt" "$HOME/.config/GIMP-AppImage/2.10/plug-ins"