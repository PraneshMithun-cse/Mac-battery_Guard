#!/bin/bash
# ─────────────────────────────────────────────
# BatteryGuard Build Script
# Compiles Swift sources and creates a .app bundle
# ─────────────────────────────────────────────

set -e

APP_NAME="BatteryGuard"
BUILD_DIR="build"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS_DIR="$CONTENTS/MacOS"
RESOURCES_DIR="$CONTENTS/Resources"

echo "🔨 Building $APP_NAME..."

# Clean previous build
rm -rf "$BUILD_DIR"

# Create .app bundle structure
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

# Detect architecture
ARCH=$(uname -m)
echo "   Architecture: $ARCH"

# Compile all Swift source files
swiftc \
    Sources/main.swift \
    Sources/AppDelegate.swift \
    Sources/BatteryManager.swift \
    Sources/NotificationManager.swift \
    Sources/PopoverView.swift \
    -o "$MACOS_DIR/$APP_NAME" \
    -framework Cocoa \
    -framework SwiftUI \
    -framework IOKit \
    -framework UserNotifications \
    -target "${ARCH}-apple-macos13.0" \
    -O \
    -swift-version 5

echo "   ✅ Compilation successful"

# Copy Info.plist
cp Resources/Info.plist "$CONTENTS/Info.plist"
echo "   ✅ Info.plist copied"

# Ad-hoc code sign (required for notifications)
codesign --force --sign - "$APP_BUNDLE"
echo "   ✅ Code signed (ad-hoc)"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Build complete: $APP_BUNDLE"
echo ""
echo "To run:  open $APP_BUNDLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
