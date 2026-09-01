import Foundation

struct Settings {
    private enum Key {
        static let showDate = "showDate"
        static let showTime = "showTime"
        static let showSeconds = "showSeconds"
        static let showSuffix = "showSuffix"
        static let fontName = "fontName"
        static let fontSize = "fontSize"
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Key.showDate: true,
            Key.showTime: true,
            Key.showSeconds: false,
            Key.showSuffix: true,
            Key.fontName: StatusFont.defaultName,
            Key.fontSize: StatusFont.defaultSize,
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

    /// A family name ("Courier New") or a PostScript name ("CourierNewPS-BoldMT").
    var fontName: String {
        get { defaults.string(forKey: Key.fontName) ?? StatusFont.defaultName }
        set { defaults.set(newValue, forKey: Key.fontName) }
    }

    /// Point size, or `0` to match the cap height of the surrounding menu bar.
    var fontSize: Double {
        get { defaults.double(forKey: Key.fontSize) }
        set { defaults.set(newValue, forKey: Key.fontSize) }
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
