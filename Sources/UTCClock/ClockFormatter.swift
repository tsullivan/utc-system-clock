import Foundation

/// Renders instants in UTC, independent of the machine's locale and time zone.
struct ClockFormatter {
    private let formatter: DateFormatter

    init(format: String) {
        formatter = DateFormatter()
        // en_US_POSIX keeps the pattern literal; other locales substitute their own
        // calendar and numbering system into fixed formats.
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = format
    }

    func string(from date: Date) -> String {
        formatter.string(from: date)
    }
}
