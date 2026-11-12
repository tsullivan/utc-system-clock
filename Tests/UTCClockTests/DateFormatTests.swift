import Foundation
import XCTest
@testable import UTCClock

final class DateFormatTests: XCTestCase {
    // 2026-03-07 09:05:04 UTC
    private let instant = Date(timeIntervalSince1970: 1_772_874_304)

    private func makeSettings() -> Settings {
        let suite = "UTCClockTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return Settings(defaults: defaults)
    }

    func testDefaultFormatPutsYearFirst() {
        let settings = makeSettings()
        XCTAssertEqual(settings.dateFormat, "yyyy-MM-dd HH:mm 'UTC'")
        let text = ClockFormatter(format: settings.dateFormat).string(from: instant)
        XCTAssertEqual(text, "2026-03-07 09:05 UTC")
    }

    func testDateOnly() {
        var settings = makeSettings()
        settings.showTime = false
        settings.showSuffix = false
        let text = ClockFormatter(format: settings.dateFormat).string(from: instant)
        XCTAssertEqual(text, "2026-03-07")
    }

    func testSecondsAreIncludedWhenEnabled() {
        var settings = makeSettings()
        settings.showSeconds = true
        let text = ClockFormatter(format: settings.dateFormat).string(from: instant)
        XCTAssertEqual(text, "2026-03-07 09:05:04 UTC")
    }
}
