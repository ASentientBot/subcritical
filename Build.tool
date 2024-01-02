set -e
cd "$(dirname "$0")"

NAME=Subcritical
IN_PATH=Inject.m
TARGET=com.apple.springboard
VERSION=2

packagePath=Package
installPath=$packagePath/var/jb/Library/MobileSubstrate/DynamicLibraries
dylibPath=$installPath/$NAME.dylib
plistPath=$installPath/$NAME.plist
metaPath=$packagePath/DEBIAN
controlPath=$metaPath/control
outPath=$NAME.deb

rm -rf $packagePath
mkdir -p $installPath
mkdir -p $metaPath

xcrun -sdk iphoneos clang -dynamiclib -fmodules -arch arm64 $IN_PATH -o $dylibPath
codesign -f -s - $dylibPath

/usr/libexec/PlistBuddy -c "add Filter:Bundles array" $plistPath
/usr/libexec/PlistBuddy -c "add Filter:Bundles:0 string $TARGET" $plistPath

echo "Package:$NAME\nVersion:$VERSION\nArchitecture:iphoneos-arm64\nDepends:mobilesubstrate" > $controlPath

dpkg-deb -Z none -b $packagePath $outPath