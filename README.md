# UTC Clock

A macOS menu bar clock showing the date and time in UTC, formatted `YYYY-MM-DD HH:mm UTC`. macOS has no built-in way to put a second time zone in the menu bar — the system clock always follows the machine's time zone, and Control Center's Clock Options offer no time zone or format field.

## Build

```
./build.sh            # produces build/UTC Clock.app
./build.sh --install  # also copies it to /Applications and launches it
```

Requires the Swift toolchain from the Xcode Command Line Tools. No third-party dependencies.

## Use

Click the clock for a menu with:

- **Copy UTC Timestamp** — puts `2026-09-01T16:31:00Z` on the clipboard.
- **Show Date / Show Time / Show Seconds / Show "UTC" Label** — toggles for what appears in the menu bar. Date and time can't both be off. Choices persist across restarts.
- **Open at Login** — registers the app as a login item. macOS only allows this for an app in `/Applications`, so install it there first.

## Configuration

Settings live in the `local.utcclock` defaults domain — the plist at `~/Library/Preferences/local.utcclock.plist`. The menu covers the display toggles; the font is set from a shell:

```
defaults write local.utcclock fontName -string "Courier New"
defaults write local.utcclock fontSize -float 13
defaults delete local.utcclock fontSize          # back to the default
```

| Key | Type | Default | Meaning |
| --- | --- | --- | --- |
| `fontName` | string | `CourierNewPS-BoldMT` | Family name (`Courier New`) or PostScript name (`CourierNewPS-BoldMT`). A name that doesn't resolve falls back to Courier Bold rather than leaving the clock blank. |
| `fontSize` | float | `14` | Point size. `0` means match the cap height of the surrounding menu bar, which lands near 15.5pt at the standard menu bar size and tracks the accessibility text size setting. |
| `showDate` | bool | `true` | `yyyy-MM-dd` |
| `showTime` | bool | `true` | `HH:mm` |
| `showSeconds` | bool | `false` | `HH:mm:ss` |
| `showSuffix` | bool | `true` | Trailing `UTC` |

Changes apply within a second — no relaunch. The app re-reads its configuration on each tick because `cfprefsd` posts no change notification to the process for an external write, though a read does see one.

Unset keys keep their built-in default and don't appear in `defaults read local.utcclock`.

## Icon

`Resources/icon.svg` is the source; `build.sh` rasterizes it into `AppIcon.icns` with the `svg2png` helper. The SVG stores the lettering as outlines rather than a `<text>` element because SVG renderers disagree about font resolution — AppKit's, the one doing the rasterizing, substitutes a sans-serif for any `font-family` it is given. Regenerate the outlines with `swift run makeicon` after changing the letters, font, or layout in `Sources/makeicon/main.swift`.

## Notes

The clock is always 24-hour and always Gregorian, regardless of the machine's locale and region settings. It ticks on a one-second timer anchored to the second boundary and re-anchors after the machine wakes from sleep.

The menu bar text defaults to Courier New Bold at 14pt. Courier's cap height per point is small enough that matching the menu bar's 13pt would render the clock visibly shorter than everything around it, which is what `fontSize 0` corrects for.
