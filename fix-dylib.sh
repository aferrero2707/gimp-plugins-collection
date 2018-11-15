#! /bin/bash

PLUGIN="$1"
BUNDLE="$2"

#curl -L https://download.gimp.org/mirror/pub/gimp/v2.10/osx/gimp-2.10.6-x86_64.dmg -O || exit 1
#hdiutil attach gimp-2.10.6-x86_64.dmg >& attach.log || exit 1

#hdiutil attach ~/Downloads/gimp-2.10.6-x86_64.dmg >& attach.log
#MOUNT_POINT=$(cat attach.log | tr "\t" "\n" | tail -n 1)
#echo "MOUNT_POINT: $MOUNT_POINT"

#TARGET="/Applications/GIMP-2.10.app"
#TARGET="/Applications/McGimp-2.10.6.app"
#TARGET="$(find "$MOUNT_POINT" -depth 1 -name "*.app" | tail -n 1)"
TARGET="/tmp/gimp.app"
echo "TARGET: $TARGET"

#exit

rm -rf plugins-fixed
mkdir -p plugins-fixed
cd plugins

echo "Contents of plugins folder:"
ls -l

for F in ./??*; do

DYLIST=$(otool -L "$F")
NDY=$(echo "$DYLIST" | wc -l)
echo "NDY: $NDY"
	
#F2="$HOME/Library/Application Support/GIMP/2.10/plug-ins/$f"
#F2="$TARGET/Contents/Resources/lib/gimp/2.0/plug-ins/$f"
F2="../plugins-fixed/$F"
cp -a "$F" "$F2"

../build/macdylibbundler/dylibbundler -b -x "$F2" -d "../plugins-fixed/$PLUGIN/lib" --create-dir -p "@rpath" > /dev/null
for DYLIB in "../plugins-fixed/$PLUGIN/lib/"*.dylib; do
	PREFIX=$(basename "$DYLIB" | cut -d'.' -f 1)
	echo "PREFIX: $PREFIX"
	DYLIB2=$(find "$TARGET/Contents" -name "$PREFIX"*)
	if [ -n "$DYLIB2" ]; then
		echo "rm -f \"$DYLIB\""
		rm -f "$DYLIB"
	fi
done

#continue
cp -a "$F" "$F2"
cp -a "$F" "${F2}-orig"

# remove all the version information for non-system libraries
I=2
while [ $I -le $NDY ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	TEST=$(echo "$DYLIB" | grep '^/usr/local/')
	if [ -z "$TEST" ]; then
		TEST=$(echo "$DYLIB" | grep 'gimp-plugins-collection/inst/')
	fi
	if [ -n "$TEST" ]; then
		echo "../build/optool/build/Release/optool vreset -p \"$DYLIB\" -t \"$F2\""
		../build/optool/build/Release/optool vreset -p "$DYLIB" -t "$F2"
	fi
	I=$((I+1))
done

# patch absolute paths
I=2
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
		echo "install_name_tool -change \"$DYLIB\" \"@rpath/$DYLIB2NAME\" \"$F2\""
		install_name_tool -change "$DYLIB" "@rpath/$DYLIB2NAME" "$F2"
	else
		DYLIBNAME=$(basename "$DYLIB")
		echo "install_name_tool -change \"$DYLIB\" \"@rpath/$DYLIBNAME\" \"$F2\""
		install_name_tool -change "$DYLIB" "@rpath/$DYLIBNAME" "$F2"
	fi
	I=$((I+1))
done
otool -L "$F2"

# fill the directory list in @rpath 	
install_name_tool -add_rpath "@loader_path/../../.." "$F2"
install_name_tool -add_rpath "@loader_path/../../../../../Frameworks" "$F2"
install_name_tool -add_rpath "@loader_path/$PLUGIN/lib" "$F2"
install_name_tool -add_rpath "/Applications/$BUNDLE/Contents/Resources/lib" "$F2"
install_name_tool -add_rpath "/Applications/$BUNDLE/Contents/Frameworks" "$F2"
#install_name_tool -add_rpath "/tmp/McGimp-2.10.6/Contents/Resources/lib" "../../PhFGimp/build/$f"
#install_name_tool -add_rpath "/tmp/lib-std" "../../PhFGimp/build/$f"

done


# remove version information for dependencies of plugin libraries
for F in "../plugins-fixed/$PLUGIN/lib"/*.dylib; do

	DYLIST=$(otool -L "$F")
	NDY=$(echo "$DYLIST" | wc -l)
	echo "NDY: $NDY"
	
	# remove all the version information for non-system libraries
	I=2
	while [ $I -le $NDY ]; do
		LINE=$(echo "$DYLIST" | sed -n ${I}p)
		DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
		TEST=$(echo "$DYLIB" | grep '^@rpath/')
		if [ -n "$TEST" ]; then
			echo "../build/optool/build/Release/optool vreset -p \"$DYLIB\" -t \"$F\""
			../build/optool/build/Release/optool vreset -p "$DYLIB" -t "$F"
		fi
		I=$((I+1))
	done
done
