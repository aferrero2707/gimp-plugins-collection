# gimp-plugins-collection
*If you find the packages in this repository useful, please consider supporting my work on [Patreon](https://www.patreon.com/andreaferrero).*

## Installation instructions

### Linux (AppImage)
===========
To install a plug-in, download the corresponding AppImage package, make it executable with 
```
chmod u+x
```
and run it.
This will automatically copy the required files into 
```
$HOME/.config/GIMP-AppImage/2.10/plug-ins`
```

### MacOS

To install a plug-in, extract the contents of the `.tgz` archive into the user's GIMP plug-ins folder:
```
cd $HOME/Library/Application Support/GIMP/2.10/plug-ins
tar xf PATH_TO_PLUGIN_ARCHIVE/PLUGIN.tgz
```
