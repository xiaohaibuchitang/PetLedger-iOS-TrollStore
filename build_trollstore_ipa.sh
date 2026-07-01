#!/bin/zsh
set -euo pipefail

APP_NAME="PetLedger"
SCHEME="PetLedger"
BUNDLE_ID="${BUNDLE_ID:-com.petledger.prototype}"
ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
BUILD_DIR="$ROOT_DIR/build"
ARCHIVE_PATH="$BUILD_DIR/$APP_NAME.xcarchive"
PAYLOAD_DIR="$BUILD_DIR/ipa/Payload"
APP_PATH="$ARCHIVE_PATH/Products/Applications/$APP_NAME.app"
IPA_PATH="$ROOT_DIR/PetLedger-TrollStore.ipa"

rm -rf "$BUILD_DIR" "$IPA_PATH"
mkdir -p "$PAYLOAD_DIR"

xcodebuild \
  -project "$ROOT_DIR/PetLedger.xcodeproj" \
  -scheme "$SCHEME" \
  -configuration Release \
  -sdk iphoneos \
  -destination "generic/platform=iOS" \
  archive \
  -archivePath "$ARCHIVE_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  PRODUCT_BUNDLE_IDENTIFIER="$BUNDLE_ID"

cp -R "$APP_PATH" "$PAYLOAD_DIR/"

if [ -d "$PAYLOAD_DIR/$APP_NAME.app/Frameworks" ]; then
  find "$PAYLOAD_DIR/$APP_NAME.app/Frameworks" -type d -name "*.framework" -print0 | while IFS= read -r -d '' framework; do
    /usr/bin/codesign --force --sign - --timestamp=none "$framework"
  done

  find "$PAYLOAD_DIR/$APP_NAME.app/Frameworks" -type f -name "*.dylib" -print0 | while IFS= read -r -d '' dylib; do
    /usr/bin/codesign --force --sign - --timestamp=none "$dylib"
  done
fi

/usr/bin/codesign --force --sign - --timestamp=none --entitlements "$ROOT_DIR/entitlements.plist" "$PAYLOAD_DIR/$APP_NAME.app"

(cd "$BUILD_DIR/ipa" && /usr/bin/zip -qry "$IPA_PATH" Payload)

echo "Created: $IPA_PATH"
