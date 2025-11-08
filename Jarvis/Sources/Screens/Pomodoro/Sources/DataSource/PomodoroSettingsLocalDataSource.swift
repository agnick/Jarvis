import Foundation
import SwiftData

@MainActor
protocol PomodoroSettingsLocalDataSource {
    func fetchSettings() -> PomodoroTimerSettings?
    func saveSettings(_ settings: PomodoroTimerSettings)
    func deleteSettings(_ settings: PomodoroTimerSettings)
}

final class PomodoroSettingsLocalDataSourceImpl: PomodoroSettingsLocalDataSource {
    
    // MARK: - Init
    init(container: ModelContainer?, context: ModelContext?) {
        self.container = container
        self.context = context
    }
    
    // MARK: - Public Methods
    func fetchSettings() -> PomodoroTimerSettings? {
        guard let context else { return nil }
        let fetchDescriptor = FetchDescriptor<PomodoroTimerSettings>()
        return try? context.fetch(fetchDescriptor).first
    }
    
    func saveSettings(_ settings: PomodoroTimerSettings) {
        guard let context else { return }
        context.insert(settings)
        try? context.save()
    }
    
    func deleteSettings(_ settings: PomodoroTimerSettings) {
        guard let context else { return }
        context.delete(settings)
        try? context.save()
    }
    
    // MARK: - Private Properties
    private let container: ModelContainer?
    private let context: ModelContext?
}
