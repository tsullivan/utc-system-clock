import Foundation

struct Settings {
    private enum Key {
        static let showDate = "showDate"
        static let showTime = "showTime"
        static let showSeconds = "showSeconds"
        static let showSuffix = "showSuffix"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.showDate: true,
            Key.showTime: true,
            Key.showSeconds: false,
            Key.showSuffix: true,
        ])
    }

    var showDate: Bool {
        get { defaults.bool(forKey: Key.showDate) }
        set { defaults.set(newValue, forKey: Key.showDate) }
    }

    var showTime: Bool {
        get { defaults.bool(forKey: Key.showTime) }
        set { defaults.set(newValue, forKey: Key.showTime) }
    }

    var showSeconds: Bool {
        get { defaults.bool(forKey: Key.showSeconds) }
        set { defaults.set(newValue, forKey: Key.showSeconds) }
    }

    var showSuffix: Bool {
        get { defaults.bool(forKey: Key.showSuffix) }
        set { defaults.set(newValue, forKey: Key.showSuffix) }
    }

    /// A `DateFormatter` pattern built from the current toggles.
    var dateFormat: String {
        var parts: [String] = []
        if showDate { parts.append("dd-MM-yyyy") }
        if showTime { parts.append(showSeconds ? "HH:mm:ss" : "HH:mm") }
        if showSuffix { parts.append("'UTC'") }
        return parts.joined(separator: " ")
    }
}
