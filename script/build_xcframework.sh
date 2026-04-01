#!/usr/bin/env bash
set -euo pipefail

# Build mParticle-AppsFlyer as both a fat .framework and an XCFramework, then zip both.
# Run from repo root. Requires: CocoaPods, Xcode.
#
# Usage: ./script/build_xcframework.sh
# Output: mParticle_AppsFlyer.framework.zip and mParticle_AppsFlyer.xcframework.zip in the repo root.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

WORKSPACE="mParticle-AppsFlyer.xcworkspace"
SCHEME="mParticle-AppsFlyer"
FRAMEWORK_NAME="mParticle_AppsFlyer"
BUILD_DIR="$REPO_ROOT/build"
DERIVED_DATA="$BUILD_DIR/derived"
IOS_BUILD="$DERIVED_DATA/Build/Products/Release-iphoneos"
SIM_BUILD="$DERIVED_DATA/Build/Products/Release-iphonesimulator"
FAT_FRAMEWORK_DIR="$BUILD_DIR/${FRAMEWORK_NAME}.framework"
XCFRAMEWORK_PATH="$BUILD_DIR/${FRAMEWORK_NAME}.xcframework"
FRAMEWORK_ZIP="${FRAMEWORK_NAME}.framework.zip"
XCFRAMEWORK_ZIP="${FRAMEWORK_NAME}.xcframework.zip"

echo "→ Installing CocoaPods dependencies..."
pod install

echo "→ Building for iOS device..."
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -derivedDataPath "$DERIVED_DATA" \
  -configuration Release \
  -quiet

echo "→ Building for iOS Simulator (x86_64 for fat framework)..."
# Use x86_64 simulator slice so lipo can combine with device arm64 (on Apple Silicon, default sim is arm64)
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  -configuration Release \
  ARCHS=x86_64 ONLY_ACTIVE_ARCH=NO \
  -quiet

SIM_X86_FRAMEWORK="$BUILD_DIR/sim_x86_64/${FRAMEWORK_NAME}.framework"
rm -rf "$BUILD_DIR/sim_x86_64"
mkdir -p "$BUILD_DIR/sim_x86_64"
cp -R "$SIM_BUILD/${FRAMEWORK_NAME}.framework" "$SIM_X86_FRAMEWORK"

echo "→ Building for iOS Simulator (arm64)..."
xcodebuild build \
  -workspace "$WORKSPACE" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS Simulator" \
  -derivedDataPath "$DERIVED_DATA" \
  -configuration Release \
  ARCHS=arm64 ONLY_ACTIVE_ARCH=NO \
  -quiet

IOS_FRAMEWORK="$IOS_BUILD/${FRAMEWORK_NAME}.framework"
SIM_ARM64_FRAMEWORK="$SIM_BUILD/${FRAMEWORK_NAME}.framework"

if [[ ! -d "$IOS_FRAMEWORK" ]]; then
  echo "error: iOS framework not found at $IOS_FRAMEWORK"
  exit 1
fi
if [[ ! -d "$SIM_X86_FRAMEWORK" ]]; then
  echo "error: Simulator (x86_64) framework not found at $SIM_X86_FRAMEWORK"
  exit 1
fi
if [[ ! -d "$SIM_ARM64_FRAMEWORK" ]]; then
  echo "error: Simulator (arm64) framework not found at $SIM_ARM64_FRAMEWORK"
  exit 1
fi

echo "→ Creating fat framework (arm64 device + x86_64 simulator)..."
rm -rf "$FAT_FRAMEWORK_DIR"
cp -R "$IOS_FRAMEWORK" "$FAT_FRAMEWORK_DIR"
IOS_BINARY="$FAT_FRAMEWORK_DIR/$FRAMEWORK_NAME"
lipo -create "$IOS_BINARY" "$SIM_X86_FRAMEWORK/$FRAMEWORK_NAME" -output "$IOS_BINARY"

echo "→ Creating XCFramework (ios-arm64 + ios-arm64_x86_64-simulator)..."
# Merge both simulator archs into one framework so create-xcframework gets one simulator slice
SIM_UNIVERSAL="$BUILD_DIR/sim_universal/${FRAMEWORK_NAME}.framework"
rm -rf "$BUILD_DIR/sim_universal"
mkdir -p "$BUILD_DIR/sim_universal"
cp -R "$SIM_ARM64_FRAMEWORK" "$SIM_UNIVERSAL"
lipo -create \
  "$SIM_X86_FRAMEWORK/$FRAMEWORK_NAME" \
  "$SIM_ARM64_FRAMEWORK/$FRAMEWORK_NAME" \
  -output "$SIM_UNIVERSAL/$FRAMEWORK_NAME"
rm -rf "$XCFRAMEWORK_PATH"
xcodebuild -create-xcframework \
  -framework "$IOS_FRAMEWORK" \
  -framework "$SIM_UNIVERSAL" \
  -output "$XCFRAMEWORK_PATH"

echo "→ Creating $FRAMEWORK_ZIP..."
cd "$BUILD_DIR"
zip -r -y "$REPO_ROOT/$FRAMEWORK_ZIP" "${FRAMEWORK_NAME}.framework"
echo "→ Creating $XCFRAMEWORK_ZIP..."
zip -r -y "$REPO_ROOT/$XCFRAMEWORK_ZIP" "${FRAMEWORK_NAME}.xcframework"
cd "$REPO_ROOT"

echo "Done. Output:"
echo "  $REPO_ROOT/$FRAMEWORK_ZIP"
echo "  $REPO_ROOT/$XCFRAMEWORK_ZIP"
