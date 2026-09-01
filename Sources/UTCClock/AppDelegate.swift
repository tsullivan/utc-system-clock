import AppKit
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private var timer: Timer?
    private var settings = Settings()
    private var formatter = ClockFormatter(format: "")
    private var renderedTitle = ""

    private let copyFormatter = ClockFormatter(format: "yyyy-MM-dd'T'HH:mm:ss'Z'")

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem.button?.font = NSFont.monospacedDigitSystemFont(ofSize: 0, weight: .regular)
        statusItem.menu = buildMenu()

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(handleWake),
            name: NSWorkspace.didWakeNotification,
            object: nil
        )

        applyFormat()
    }

    func applicationWillTerminate(_ notification: Notification) {
        timer?.invalidate()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    // MARK: - Ticking

    private func applyFormat() {
        formatter = ClockFormatter(format: settings.dateFormat)
        renderedTitle = ""
        startTimer()
        tick()
    }

    private func startTimer() {
        timer?.invalidate()
        // Anchored to the next whole second so the displayed value flips at the
        // same moment the underlying clock does.
        let nextSecond = (floor(Date().timeIntervalSince1970) + 1).rounded()
        let timer = Timer(
            fire: Date(timeIntervalSince1970: nextSecond),
            interval: 1,
            repeats: true
        ) { [weak self] _ in
            // The timer is installed on the main run loop, so this always fires on the main actor.
            MainActor.assumeIsolated { self?.tick() }
        }
        timer.tolerance = 0.1
        // .common keeps the clock running while a menu is open or a window is being dragged.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }

    private func tick() {
        let title = formatter.string(from: Date())
        guard title != renderedTitle else { return }
        renderedTitle = title
        statusItem.button?.title = title
    }

    @objc private func handleWake() {
        applyFormat()
    }

    // MARK: - Menu

    private func buildMenu() -> NSMenu {
        let menu = NSMenu()
        menu.autoenablesItems = false

        menu.addItem(item(title: "Copy UTC Timestamp", action: #selector(copyTimestamp)))
        menu.addItem(.separator())

        menu.addItem(item(title: "Show Date", action: #selector(toggleDate), state: settings.showDate))
        menu.addItem(item(title: "Show Time", action: #selector(toggleTime), state: settings.showTime))
        menu.addItem(item(title: "Show Seconds", action: #selector(toggleSeconds), state: settings.showSeconds))
        menu.addItem(item(title: "Show \"UTC\" Label", action: #selector(toggleSuffix), state: settings.showSuffix))
        menu.addItem(.separator())

        menu.addItem(item(title: "Open at Login", action: #selector(toggleLaunchAtLogin), state: launchesAtLogin))
        menu.addItem(.separator())

        menu.addItem(item(title: "Quit UTC Clock", action: #selector(NSApplication.terminate(_:)), key: "q"))
        return menu
    }

    private func item(title: String, action: Selector, key: String = "", state: Bool? = nil) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        if let state { item.state = state ? .on : .off }
        return item
    }

    private func refreshMenu() {
        statusItem.menu = buildMenu()
    }

    @objc private func copyTimestamp() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(copyFormatter.string(from: Date()), forType: .string)
    }

    @objc private func toggleDate() {
        settings.showDate.toggle()
        // An empty menu bar item would be unclickable, so the two fields can never both be off.
        if !settings.showDate && !settings.showTime { settings.showTime = true }
        applyFormat()
        refreshMenu()
    }

    @objc private func toggleTime() {
        settings.showTime.toggle()
        if !settings.showDate && !settings.showTime { settings.showDate = true }
        applyFormat()
        refreshMenu()
    }

    @objc private func toggleSeconds() {
        settings.showSeconds.toggle()
        applyFormat()
        refreshMenu()
    }

    @objc private func toggleSuffix() {
        settings.showSuffix.toggle()
        applyFormat()
        refreshMenu()
    }

    // MARK: - Login item

    private var launchesAtLogin: Bool {
        SMAppService.mainApp.status == .enabled
    }

    @objc private func toggleLaunchAtLogin() {
        do {
            if launchesAtLogin {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            let alert = NSAlert()
            alert.messageText = "Could not change the login item"
            alert.informativeText = """
                \(error.localizedDescription)

                Login items only register for an app in /Applications. Move UTC Clock there and try again.
                """
            alert.runModal()
        }
        refreshMenu()
    }
}
