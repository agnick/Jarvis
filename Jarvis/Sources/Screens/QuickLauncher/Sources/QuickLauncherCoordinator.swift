import SwiftUI

protocol QuickLauncherCoordinator {
    func toggleLauncher()
}

final class QuickLauncherCoordinatorImpl: QuickLauncherCoordinator {
    private var window: NSWindow?

    func toggleLauncher() {
        if let window, window.isVisible {
            window.orderOut(nil)
        } else {
            let contentView = QuickLauncherView()
            let hosting = NSHostingController(rootView: contentView)
            let window = NSWindow(contentViewController: hosting)
            window.styleMask = [.titled, .fullSizeContentView]
            window.titleVisibility = .hidden
            window.isReleasedWhenClosed = false
            window.level = .floating
            window.backgroundColor = .clear
            window.isOpaque = false
            window.center()
            self.window = window
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

