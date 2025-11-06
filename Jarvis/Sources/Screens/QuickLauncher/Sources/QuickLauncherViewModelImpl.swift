import SwiftUI

final class QuickLauncherViewModelImpl: QuickLauncherViewModel {
    // MARK: - Properties
    @Published var command: String = ""
    
    // MARK: - Initialization
    
    init(commandHandler: QuickLauncherCommandHandler) {
        self.commandHandler = commandHandler
    }
    
    // MARK: - Public methods
    
    func clearCommand() {
        command = ""
    }
    
    func executeCommand() {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        commandHandler.handle(command: trimmed)

        clearCommand()
    }
    
    // MARK: - Private
    
    private let commandHandler: QuickLauncherCommandHandler
}
