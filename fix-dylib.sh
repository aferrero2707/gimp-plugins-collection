#! /bin/bash

PLUGIN="$1"

curl -L https://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.6-x86_64.dmg -O || exit 1
hdiutil attach gimp-2.10.6-x86_64.dmg >& attach.log || exit 1

#hdiutil attach ~/Downloads/gimp-2.10.6-x86_64.dmg >& attach.log
MOUNT_POINT=$(cat attach.log | tr "\t" "\n" | tail -n 1)
echo "MOUNT_POINT: $MOUNT_POINT"

#TARGET="/Applications/GIMP-2.10.app"
#TARGET="/Applications/McGimp-2.10.6.app"
TARGET="$(find "$MOUNT_POINT" -depth 1 -name "*.app" | tail -n 1)"
echo "TARGET: $TARGET"

#exit

mkdir -p plugins-fixed
cd plugins

for F in ./??*; do

DYLIST=$(otool -L "$F")
NDY=$(echo "$DYLIST" | wc -l)
echo "NDY: $NDY"
	
#F2="$HOME/Library/Application Support/GIMP/2.10/plug-ins/$f"
#F2="$TARGET/Contents/Resources/lib/gimp/2.0/plug-ins/$f"
F2="../plugins-fixed/$F"
cp -a "$F" "$F2"

# remove all the LC_ADD_DYLIB commands
I=$NDY
while [ $I -ge 3 ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	../build/optool/build/Release/optool uninstall -p "$DYLIB" -t "$F2"
	I=$((I-1))
done
	
otool -L "$F2"
# re-introduce all the LC_ADD_DYLIB commands, this time without version checking
I=3
while [ $I -le $NDY ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	../build/optool/build/Release/optool install -c load -p "$DYLIB" -t "$F2"
	otool -L "$F2"
	I=$((I+1))
done
	
I=3
while [ $I -le $NDY ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	PREFIX=$(basename "$DYLIB" | cut -d'.' -f 1)
	echo "PREFIX: $PREFIX"
	DYLIB2=$(find "$TARGET/Contents" -name "$PREFIX"*)
	echo "DYLIB2: $DYLIB2"
	
	#check if this is a system library, using an ad-hoc euristic
	TEST=$(echo "$DYLIB" | grep '\.framework')
	if [ -n "$TEST" ]; then
		# this looks like a framework, no ned to patch the absolute path
		I=$((I+1)); continue;
	fi
	TEST=$(echo "$DYLIB" | grep '/usr/lib/')
	if [ -n "$TEST" ]; then
		# this looks like a system library, no ned to patch the absolute path
		I=$((I+1)); continue;
	fi
	
	# replace absolute paths for non-system libraries and frameworks
	# at runtime the libraries will be searched through the @rpath list
	# if the library is provided by the application bundle, we eventually replace
	# the original file name with the one in the bundle
	if [ -n "$DYLIB2" ]; then
		DYLIB2NAME=$(basename "$DYLIB2")
		install_name_tool -change "$DYLIB" "@rpath/$DYLIB2NAME" "$F2"
	else
		DYLIBNAME=$(basename "$DYLIB")
		install_name_tool -change "$DYLIB" "@rpath/$DYLIBNAME" "$F2"
	fi
	otool -L "$F2"
	I=$((I+1))
done

# fill the directory list in @rpath 	
install_name_tool -add_rpath "@loader_path/../../.." "$F2"
install_name_tool -add_rpath "@loader_path/../../../../../Frameworks" "$F2"
install_name_tool -add_rpath "@loader_path/$PLUGIN/lib" "$F2"
#install_name_tool -add_rpath "/tmp/McGimp-2.10.6/Contents/Resources/lib" "../../PhFGimp/build/$f"
#install_name_tool -add_rpath "/tmp/lib-std" "../../PhFGimp/build/$f"

done
