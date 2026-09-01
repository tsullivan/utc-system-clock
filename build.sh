#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")"

APP_NAME="UTC Clock"
BUNDLE="build/${APP_NAME}.app"

swift build -c release --product UTCClock

rm -rf "$BUNDLE"
mkdir -p "$BUNDLE/Contents/MacOS" "$BUNDLE/Contents/Resources"
cp "$(swift build -c release --show-bin-path)/UTCClock" "$BUNDLE/Contents/MacOS/UTCClock"
cp Resources/Info.plist "$BUNDLE/Contents/Info.plist"

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
