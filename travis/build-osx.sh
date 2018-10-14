#! /bin/bash

source ./environment-osx.sh
brew update >& /dev/null

cd $( brew --prefix )/Homebrew/Library/Taps/homebrew/homebrew-core || exit 1
git checkout 9ba3d6ef8891e5c15dbdc9333f857b13711d4e97 Formula/qt@5.5.rb || exit 1

brew install qt@5.5 || exit 1

exit

export HOMEBREW_MAKE_JOBS=3
brew install --verbose --build-from-source --build-bottle ./travis/qt.rb || exit 1
brew bottle qt || exit 1

wget -c https://github.com/aferrero2707/uploadtool/raw/master/upload_rotate.sh
bash  ./upload_rotate.sh "continuous" qt*bottle.tar.gz


exit

mkdir plugins || exit 1
bash ./build-common-osx.sh || exit 1
exit
bash ./${TARGET_PLUGIN}/build-osx.sh || exit 1
#exit

rm -rf plugins-fixed
curl -L https://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.6-x86_64.dmg -O || exit 1
hdiutil attach gimp-2.10.6-x86_64.dmg >& attach.log || exit 1
export MOUNT_POINT=$(cat attach.log | tr "\t" "\n" | tail -n 1)
export GIMP_BUNDLE="$(find "$MOUNT_POINT" -depth 1 -name "*.app" | tail -n 1)"
rm -f /tmp/gimp.app
ln -s "$GIMP_BUNDLE" /tmp/gimp.app || exit 1
ls -l /tmp/gimp.app/
bash ./fix-dylib.sh ${TARGET_PLUGIN} "$(basename "$GIMP_BUNDLE")" || exit 1
if [ -e "${TARGET_PLUGIN}/fix-dylib.sh" ]; then
	bash "${TARGET_PLUGIN}/fix-dylib.sh" ${TARGET_PLUGIN} "McGimp-2.10.6.app"
fi
ls plugins-fixed || exit 1
cd plugins-fixed || exit 1
tar czf ../${TARGET_PLUGIN}-Gimp-2.10.6-OSX.tgz ??* || exit 1
cd ..

if [ "x" = "y" ]; then
rm -rf plugins-fixed
curl -L https://www.partha.com/downloads/McGimp-2.10.6.app.zip -O
unzip McGimp-2.10.6.app.zip
rm -f /tmp/gimp.app
ln -s "$(pwd)/McGimp-2.10.6.app" /tmp/gimp.app
bash ./fix-dylib.sh ${TARGET_PLUGIN} "McGimp-2.10.6.app"
ls plugins-fixed
cd plugins-fixed
tar czvf ../${TARGET_PLUGIN}-McGimp-2.10.6-OSX.tgz ??*
cd ..
fi

wget -c https://github.com/aferrero2707/uploadtool/raw/master/upload_rotate.sh
bash  ./upload_rotate.sh "continuous" *.tgz >& /dev/null

