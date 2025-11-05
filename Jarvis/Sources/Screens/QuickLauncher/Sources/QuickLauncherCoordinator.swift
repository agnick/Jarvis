import AVFoundation
import SwiftUI

protocol QuickLauncherCoordinator {
    func toggleLauncher()
}

final class QuickLauncherCoordinatorImpl<ViewModel: QuickLauncherViewModel>: QuickLauncherCoordinator {
    // MARK: - Initialization
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Toggle

    func toggleLauncher() {
        if let window, window.isVisible {
            window.orderOut(nil)
            return
        }

        let view = QuickLauncherView(viewModel: viewModel)
        let hostingController = NSHostingController(rootView: view)

        let window = NSWindow(
            contentViewController: hostingController
        )
        window.styleMask = [.titled, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.makeKeyAndOrderFront(nil)
        window.title = "Hey, Jarvis!"
        window.backgroundColor = .clear
        window.isOpaque = false
        NSApp.activate(ignoringOtherApps: true)

        self.window = window
        
        jarvisClipThat()
    }
    
    // MARK: - Private properties
    
    private var window: NSWindow?
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
            print("🎵 Jarvis clip playing!")
        } catch {
            print("Ошибка воспроизведения: \(error)")
        }
    }
}
