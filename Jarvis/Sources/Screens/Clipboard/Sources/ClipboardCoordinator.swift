import SwiftUI

@MainActor
protocol ClipboardCoordinator {
    func toggleClipboard()
    func showClipboard()
    func hideClipboard()
}

@MainActor
final class ClipboardCoordinatorImpl<ViewModel: ClipboardHistoryViewModel>: ClipboardCoordinator {
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        // Устанавливаем обработчик закрытия окна после выбора элемента
        viewModel.onClose = { [weak self] in
            self?.hideClipboard()
        }
    }

    func toggleClipboard() {
        if let window, window.isVisible {
            hideClipboard()
        } else {
            showClipboard()
        }
    }

    func showClipboard() {
        if let window, window.isVisible {
            window.makeKeyAndOrderFront(nil)
            return
        }

        let view = ClipboardHistoryView(viewModel: viewModel)

        let hosting = NSHostingController(rootView: view)
        let window = NSWindow(contentViewController: hosting)

        window.styleMask = [.titled, .fullSizeContentView]
        window.titlebarAppearsTransparent = true
        window.isReleasedWhenClosed = false
        window.level = .floating
        window.title = "Clipboard"
        window.backgroundColor = .clear
        window.isOpaque = false

        // Показать поверх и сфокусировать, не переключая фокус туда-сюда
        NSApp.activate(ignoringOtherApps: true)
        window.center()
        window.makeKeyAndOrderFront(nil)

        self.window = window
    }

    func hideClipboard() {
        window?.orderOut(nil)
        // Не делаем NSApp.deactivate() — чтобы не переключать фокус на основное окно
    }

    private var window: NSWindow?
    private let viewModel: ViewModel
}
