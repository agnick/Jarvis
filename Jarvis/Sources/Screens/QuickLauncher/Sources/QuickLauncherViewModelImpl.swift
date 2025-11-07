import SwiftUI

final class QuickLauncherViewModelImpl: QuickLauncherViewModel {
    // MARK: - Properties
    @Published var command: String = ""
    @Published var statusMessage: StatusMessage?
    
    var clipboardItems: [String] {
        Array(clipboardService.entries.prefix(3))
    }
    
    // MARK: - Initialization
    
    init(commandHandler: QuickLauncherCommandHandler, clipboardService: ClipboardHistoryService) {
        self.commandHandler = commandHandler
        self.clipboardService = clipboardService
    }
    
    // MARK: - Public methods
    
    func clearCommand() {
        command = ""
    }
    
    func executeCommand() {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        let result = commandHandler.handle(command: trimmed)
        withAnimation {
            statusMessage = result
        }

        clearCommand()
    }
    
    func copyClipboardItem(_ text: String) {
        clipboardService.copyToPasteboard(text)
        withAnimation {
            statusMessage = .success("✅ Copied: \(text)")
        }
    }
    
    // MARK: - Private
    
    private let commandHandler: QuickLauncherCommandHandler
    private let clipboardService: ClipboardHistoryService
}
