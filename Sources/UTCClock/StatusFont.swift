import AppKit

enum StatusFont {
    /// Courier New is the serifed monospace that ships with macOS.
    static let defaultName = "CourierNewPS-BoldMT"
    static let defaultSize = 14.0

    /// Used when the configured face cannot be found; the plain Courier alias, then the
    /// system's own monospace, so a typo in `fontName` still leaves a readable clock.
    private static let fallbackName = "Courier-Bold"

    @MainActor
    static func resolve(name: String, size: Double) -> NSFont {
        for candidate in [name, fallbackName] {
            // A size of 100 keeps the metrics well away from hinting, so the ratio below
            // is a property of the typeface rather than of a particular rendering.
            guard let probe = NSFont(name: candidate, size: 100), probe.capHeight > 0 else { continue }
            let points = size > 0 ? size : capHeightMatchedSize(probe: probe)
            return NSFont(name: candidate, size: points) ?? probe
        }
        return .monospacedDigitSystemFont(ofSize: size > 0 ? size : menuBarSize, weight: .bold)
    }

    @MainActor
    private static var menuBarSize: Double { Double(NSFont.menuBarFont(ofSize: 0).pointSize) }

    /// The point size at which the face's capitals stand as tall as the menu bar's own.
    /// Courier's cap height per point is small enough that an equal point size renders
    /// visibly shorter than everything around it.
    @MainActor
    private static func capHeightMatchedSize(probe: NSFont) -> Double {
        100 * Double(NSFont.menuBarFont(ofSize: 0).capHeight) / Double(probe.capHeight)
    }
}
