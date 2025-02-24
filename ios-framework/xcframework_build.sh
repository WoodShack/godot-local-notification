#!/bin/bash

rm -rf ./build/*.xcframework
rm -rf ./build/*.xcarchive

PROJECT=${1:-gdnative_ios.xcodeproj}
SCHEME=${2:-library}

xcodebuild archive \
    -project "./$PROJECT" \
    -scheme $SCHEME \
    -archivePath "./build/ios.xcarchive" \
    -sdk iphoneos \
    SKIP_INSTALL=NO

FRAMEWORK=`ls ./build/ios.xcarchive/Products/Library/Frameworks/`

xcodebuild -create-xcframework \
    -framework "./build/ios.xcarchive/Products/Library/Frameworks/$FRAMEWORK" \
    -output "./build/`echo $FRAMEWORK| sed "s/.framework/.xcframework/"`"

