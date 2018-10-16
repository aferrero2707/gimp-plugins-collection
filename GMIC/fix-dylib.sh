#! /bin/bash

PLUGIN="$1"
BUNDLE="$2"

TARGET="/tmp/gimp.app"
echo "TARGET: $TARGET"

#exit

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

	
I=2
while [ $I -le $NDY ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	PREFIX=$(basename "$DYLIB" | cut -d'.' -f 1)
	echo "PREFIX: $PREFIX"
	
	# check if this is a Qt framework
	TEST=$(echo "$DYLIB" | grep '\.framework' | grep '/usr/local/')
	if [ -n "$TEST" ]; then
		DYLIBNAME="$(basename "$DYLIB")"
		mkdir -p "../plugins-fixed/$PLUGIN/Frameworks/" || exit 1
		echo "cp -a \"$DYLIB\" \"../plugins-fixed/$PLUGIN/Frameworks\""
		cp -a "$DYLIB" "../plugins-fixed/$PLUGIN/Frameworks" || exit 1
		chmod u+w "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME"
		DYLIB2="@loader_path/$PLUGIN/Frameworks/$DYLIBNAME"
		echo "DYLIB2: $DYLIB2"
		echo "install_name_tool -change \"$DYLIB\" \"$DYLIB2\" \"$F2\""
		install_name_tool -change "$DYLIB" "$DYLIB2" "$F2"

		echo "Patching $../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME"
		DYLIST2=$(otool -L "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME")
		NDY2=$(echo "$DYLIST2" | wc -l)
		echo "NDY2: $NDY2"
		I2=2
		while [ $I2 -le $NDY2 ]; do
			LINE2=$(echo "$DYLIST2" | sed -n ${I2}p)
			DYLIB2=$(echo $LINE2 | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
			DYLIB2NAME="$(basename "$DYLIB2")"
			echo "DYLIB2: $DYLIB2"
			
			# check what kind of library this is
			TEST=$(echo "$DYLIB2" | grep '\.framework' | grep '^/usr/local/')
			if [ -n "$TEST" ]; then
				# this is a Qt framework
				echo "install_name_tool -change \"$DYLIB2\" \"@loader_path/$DYLIB2NAME\" \"../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME\""
				install_name_tool -change "$DYLIB2" "@loader_path/$DYLIB2NAME" "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME"
				I2=$((I2+1))
				continue
			fi
			
			TEST=$(echo "$DYLIB2" | grep '\.framework')
			if [ -n "$TEST" ]; then
				# this is a system framework, don't patch the path
				echo "this is a system framework, don't patch the path"
				I2=$((I2+1))
				continue
			fi
			
			TEST=$(echo "$DYLIB2" | grep '^/usr/lib/')
			if [ -n "$TEST" ]; then
				# this is a system library, don't patch the path
				echo "this is a system library, don't patch the path"
				I2=$((I2+1))
				continue
			fi
			
			# all previous test were negative, it must be a standard library
			echo "install_name_tool -change \"$DYLIB2\" \"@rpath/$DYLIB2NAME\" \"../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME\""
			install_name_tool -change "$DYLIB2" "@rpath/$DYLIB2NAME" "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME"
		
			
			I2=$((I2+1))
		done
		otool -L "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBNAME"

		#DYLIBPATH="$(echo "$DYLIB" | sed "s|/usr/local/opt/qt/lib/||g")"
		#DYLIBPATH="$(dirname "$DYLIBPATH")"
		#mkdir -p "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBPATH" || exit 1
		#echo "cp -a \"$DYLIB\" \"../plugins-fixed/$PLUGIN/Frameworks/$DYLIBPATH\""
		#cp -a "$DYLIB" "../plugins-fixed/$PLUGIN/Frameworks/$DYLIBPATH" || exit 1
		#DYLIB2=$(echo "$DYLIB" | sed "s|/usr/local/opt/qt/lib|@loader_path/$PLUGIN/Frameworks|g")
		#echo "DYLIB2: $DYLIB2"
		#echo "install_name_tool -change \"$DYLIB\" \"$DYLIB2\" \"$F2\""
		#install_name_tool -change "$DYLIB" "$DYLIB2" "$F2"
	fi
	I=$((I+1))
done
otool -L "$F2"

done

# Copy Qt5 plugins
cat /usr/local/opt/qt@5.5/lib/pkgconfig/Qt5Core.pc
QT5PREFIX="$(pkg-config --variable=prefix Qt5Core)"
QT5PLUGINDIR="$QT5PREFIX/plugins"
if [ x"$QT5PLUGINDIR" != "x" ]; then
  mkdir -p "../plugins-fixed/$PLUGIN/plugins"
  cp -a "$QT5PLUGINDIR"/* "../plugins-fixed/$PLUGIN/plugins"
fi


# patch library paths in Qt plug-ins
# they should only reference system libraries or Qt frameworks
for F in "../plugins-fixed/$PLUGIN/plugins"/*/*.dylib; do

echo "otool -L \"$F\""
otool -L "$F"
DYLIST=$(otool -L "$F")
echo "DYLIST: $DYLIST"
NDY=$(echo "$DYLIST" | wc -l)
echo "NDY: $NDY"
I=2
while [ $I -le $NDY ]; do
	LINE=$(echo "$DYLIST" | sed -n ${I}p)
	DYLIB=$(echo $LINE | sed -e 's/^[ \t]*//' | tr -s ' ' | tr ' ' '\n' | head -n 1)
	DYLIBNAME="$(basename "$DYLIB")"
	echo "DYLIB: $DYLIB"

	# check what kind of library this is
	TEST=$(echo "$DYLIB" | grep '\.framework' | grep '^/usr/local/')
	if [ -n "$TEST" ]; then
		# this is a Qt framework
		echo "install_name_tool -change \"$DYLIB\" \"@loader_path/../../Frameworks/$DYLIBNAME\" \"$F\""
		install_name_tool -change "$DYLIB" "@loader_path/../../Frameworks/$DYLIBNAME" "$F"
	fi
	I=$((I+1))
done

done