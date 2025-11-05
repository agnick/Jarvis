import SwiftUI

final class QuickLauncherController {
    static let shared = QuickLauncherController()
    private var window: NSWindow?

    func toggleLauncher() {
        if let window = window, window.isVisible {
            window.orderOut(nil)
            return
        }

        let contentView = QuickLauncherView()
        let hosting = NSHostingController(rootView: contentView)
        let window = NSWindow(contentViewController: hosting)
        window.styleMask = [.titled, .fullSizeContentView]
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.level = .floating
        window.backgroundColor = .clear
        window.isOpaque = false
        window.center()

        self.window = window
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

