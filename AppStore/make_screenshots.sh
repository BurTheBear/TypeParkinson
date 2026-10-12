#!/bin/zsh
# Captures App Store screenshots of each main screen with sample data.
# Needs a few GB of free disk space for the build and the simulators.
set -euo pipefail

cd "$(dirname "$0")/.."
BUILD_DIR="${TMPDIR:-/tmp}/typeparkinson-screenshots"
OUT=AppStore/screenshots
BUNDLE=com.pranavatreya.typeparkinson
SCREENS=(onboarding profile proposal compare home recalResult)

xcodebuild build -project TypeParkinson.xcodeproj -scheme TypeParkinson -configuration Debug \
  -destination 'generic/platform=iOS Simulator' -derivedDataPath "$BUILD_DIR" -quiet
APP="$BUILD_DIR/Build/Products/Debug-iphonesimulator/TypeParkinson.app"

capture() {
  local device=$1 folder=$2
  mkdir -p "$OUT/$folder"
  xcrun simctl boot "$device" 2>/dev/null || true
  xcrun simctl bootstatus "$device" -b >/dev/null
  xcrun simctl ui "$device" appearance light
  xcrun simctl status_bar "$device" override --time 9:41 --batteryState charged --batteryLevel 100 \
    --wifiBars 3 --cellularMode active --cellularBars 4 --dataNetwork wifi
  xcrun simctl install "$device" "$APP"
  local i=1
  for screen in $SCREENS; do
    xcrun simctl launch --terminate-running-process "$device" $BUNDLE -demoScreen $screen >/dev/null
    sleep 3
    xcrun simctl io "$device" screenshot "$OUT/$folder/$i-$screen.png" >/dev/null
    echo "saved $OUT/$folder/$i-$screen.png"
    i=$((i + 1))
  done
  xcrun simctl status_bar "$device" clear
  xcrun simctl shutdown "$device"
}

capture "iPhone 17 Pro Max" iphone-6.9
capture "iPad Pro 13-inch (M5)" ipad-13
rm -rf "$BUILD_DIR"
