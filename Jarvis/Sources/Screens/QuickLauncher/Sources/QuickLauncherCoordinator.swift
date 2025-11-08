import AVFoundation
import SwiftUI

protocol QuickLauncherCoordinator {
    func toggleLauncher()
    func openLauncher()
    func closeLauncher(animated: Bool)
}

final class QuickLauncherCoordinatorImpl<ViewModel: QuickLauncherViewModel>: QuickLauncherCoordinator {
    // MARK: - Initialization
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Public
    func toggleLauncher() {
        if let window, window.isVisible {
            closeLauncher(animated: true)
            return
        }
        openLauncher()
    }
    
    func openLauncher() {
        if let window, window.isVisible { return }

        let view = QuickLauncherView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: view)

        let window = QuickLauncherWindow(
            contentRect: NSRect(x: 0, y: 0, width: 650, height: 256),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.backgroundColor = .clear
        window.isOpaque = false
        window.hasShadow = true
        window.level = .screenSaver
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        window.setFrame(NSRect(x: 0, y: 0, width: 650, height: 256), display: true)
        window.center()
        window.makeKeyAndOrderFront(nil)

        // Событие Esc
        window.onEscPressed = { [weak self] in
            self?.closeLauncher(animated: true)
        }

        self.window = window

        NSApp.activate(ignoringOtherApps: true)
        setupAnimation()
        jarvisClipThat()
    }

    func closeLauncher(animated: Bool = false) {
        guard let window else { return }

        if animated {
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                window.animator().alphaValue = 0
            } completionHandler: {
                window.orderOut(nil)
            }
        } else {
            window.orderOut(nil)
        }
    }

    // MARK: - Private Properties
    private var window: QuickLauncherWindow?
    private let viewModel: ViewModel
    private var player: AVAudioPlayer?
    
    // MARK: - Private Methods

    private func jarvisClipThat() {
        guard let url = Bundle.main.url(forResource: "jarvis_meme", withExtension: "mp3") else {
            print("Не найден файл jarvis_meme.mp3")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.volume = 20.0
            player?.play()
        } catch {
            print("Ошибка воспроизведения: \(error)")
        }
    }

    private func setupAnimation() {
        guard let window else { return }
        window.alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            window.animator().alphaValue = 1
        }
    }
}

// MARK: - Custom NSWindow
final class QuickLauncherWindow: NSWindow {
    var onEscPressed: (() -> Void)?

    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func cancelOperation(_ sender: Any?) {
        onEscPressed?()
    }
}
