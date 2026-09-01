# UTC Clock

A macOS menu bar clock showing the date and time in UTC, formatted `dd-mm-YYYY HH:mm UTC`. macOS has no built-in way to put a second time zone in the menu bar — the system clock always follows the machine's time zone, and Control Center's Clock Options offer no time zone or format field.

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

## Notes

The clock is always 24-hour and always Gregorian, regardless of the machine's locale and region settings. It ticks on a one-second timer anchored to the second boundary and re-anchors after the machine wakes from sleep.
