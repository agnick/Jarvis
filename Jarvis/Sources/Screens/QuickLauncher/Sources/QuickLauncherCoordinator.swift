import AVFoundation
import SwiftUI

protocol QuickLauncherCoordinator {
    func toggleLauncher()
    func closeLauncher(animated: Bool)
}

final class QuickLauncherCoordinatorImpl<ViewModel: QuickLauncherViewModel>: QuickLauncherCoordinator {
    // MARK: - Initialization

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    // MARK: - Public

    func toggleLauncher() {
        if let panel, panel.isVisible {
            closeLauncher(animated: true)
            return
        }

        let view = QuickLauncherView(viewModel: viewModel)

        let hostingController = NSHostingController(rootView: view)

        let panel = QuickLauncherPanel(contentViewController: hostingController)
        panel.styleMask = [.titled, .fullSizeContentView]
        panel.titlebarAppearsTransparent = true
        panel.isReleasedWhenClosed = false
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = true
        panel.title = "Hey, Jarvis!"
        panel.becomesKeyOnlyIfNeeded = true
        panel.standardWindowButton(.closeButton)?.isHidden = true
        panel.standardWindowButton(.miniaturizeButton)?.isHidden = true
        panel.standardWindowButton(.zoomButton)?.isHidden = true
        panel.onEscPressed = { [weak self] in
            self?.closeLauncher(animated: true) 
        }

        self.panel = panel

        NSApp.activate(ignoringOtherApps: true)
        
        setupAnimation()

        // jarvisClipThat()
    }

    func closeLauncher(animated: Bool = false) {
        guard let panel else { return }

        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.25
                context.allowsImplicitAnimation = true
                panel.animator().alphaValue = 0
            }, completionHandler: {
                panel.orderOut(nil)
            })
        } else {
            panel.orderOut(nil)
        }
    }

    // MARK: - Private Properties

    private var panel: NSPanel?
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
        guard let panel else { return }
        panel.alphaValue = 0
        panel.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.25
            context.allowsImplicitAnimation = true
            panel.animator().alphaValue = 1
        }
    }
}

final class QuickLauncherPanel: NSPanel {
    var onEscPressed: (() -> Void)?

    override func cancelOperation(_ sender: Any?) {
        onEscPressed?()
    }
}

