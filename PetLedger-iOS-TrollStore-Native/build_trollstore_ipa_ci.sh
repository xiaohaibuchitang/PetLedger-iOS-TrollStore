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

if command -v brew >/dev/null 2>&1; then
  brew list ldid >/dev/null 2>&1 || brew install ldid || true
fi

if command -v ldid >/dev/null 2>&1; then
  ldid -S entitlements.plist "$APP_PATH/$APP_NAME"
else
  codesign -s - --force --entitlements entitlements.plist "$APP_PATH/$APP_NAME"
fi

mkdir -p Payload
cp -R "$APP_PATH" Payload/
/usr/bin/zip -qry "$DIST_DIR/${APP_NAME}-TrollStore.ipa" Payload
rm -rf Payload

echo "Created $DIST_DIR/${APP_NAME}-TrollStore.ipa"

