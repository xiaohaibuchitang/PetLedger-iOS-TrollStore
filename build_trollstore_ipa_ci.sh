#!/usr/bin/env bash
set -euo pipefail

APP_NAME="PetLedger"
SCHEME="PetLedger"
CONFIGURATION="Release"
DERIVED_DATA="$PWD/build/DerivedData"
DIST_DIR="$PWD/dist"
APP_PATH="$DERIVED_DATA/Build/Products/${CONFIGURATION}-iphoneos/${APP_NAME}.app"

rm -rf "$DERIVED_DATA" "$DIST_DIR" Payload
mkdir -p "$DIST_DIR"

xcodebuild \
  -project PetLedger.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -sdk iphoneos \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build

if [ -d "$APP_PATH/Frameworks" ]; then
  find "$APP_PATH/Frameworks" -type d -name "*.framework" -print0 | while IFS= read -r -d '' framework; do
    /usr/bin/codesign --force --sign - --timestamp=none "$framework"
  done

  find "$APP_PATH/Frameworks" -type f -name "*.dylib" -print0 | while IFS= read -r -d '' dylib; do
    /usr/bin/codesign --force --sign - --timestamp=none "$dylib"
  done
fi

/usr/bin/codesign --force --sign - --timestamp=none --entitlements entitlements.plist "$APP_PATH"

mkdir -p Payload
cp -R "$APP_PATH" Payload/
/usr/bin/zip -qry "$DIST_DIR/${APP_NAME}-TrollStore.ipa" Payload
rm -rf Payload

echo "Created $DIST_DIR/${APP_NAME}-TrollStore.ipa"
