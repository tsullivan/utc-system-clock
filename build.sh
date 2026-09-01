#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="UTC Clock"
BUNDLE="build/${APP_NAME}.app"
ICONSET="build/AppIcon.iconset"

swift build -c release --product UTCClock
swift build -c release --product svg2png
BIN="$(swift build -c release --show-bin-path)"

rm -rf "$ICONSET"
mkdir -p "$ICONSET"
for size in 16 32 128 256 512; do
	"$BIN/svg2png" Resources/icon.svg "$ICONSET/icon_${size}x${size}.png" "$size"
	"$BIN/svg2png" Resources/icon.svg "$ICONSET/icon_${size}x${size}@2x.png" "$((size * 2))"
done
iconutil -c icns -o build/AppIcon.icns "$ICONSET"

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp "$BIN/UTCClock" "$BUNDLE/Contents/MacOS/UTCClock"
cp Resources/Info.plist "$BUNDLE/Contents/Info.plist"
cp build/AppIcon.icns "$BUNDLE/Contents/Resources/AppIcon.icns"

# Ad-hoc signature: without one, macOS refuses to launch the bundle on Apple silicon.
codesign --force --sign - "$BUNDLE" >/dev/null

echo "Built $BUNDLE"

if [[ "${1:-}" == "--install" ]]; then
	DEST="/Applications/${APP_NAME}.app"
	osascript -e "tell application id \"local.utcclock\" to quit" 2>/dev/null || true
	rm -rf "$DEST"
	cp -R "$BUNDLE" "$DEST"
	open "$DEST"
	echo "Installed and launched $DEST"
fi
