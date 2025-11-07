import SwiftUI

final class StatusBarViewModelImpl: StatusBarViewModel {
    // MARK: - Initialiaztion
    
    init(coordinator: QuickLauncherCoordinator) {
        self.quickLauncherCoordinator = coordinator
    }
    
    // MARK: - Public Methods

    func openQuickLauncher() {
        quickLauncherCoordinator.toggleLauncher()
    }
    
    func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Private
    private let quickLauncherCoordinator: QuickLauncherCoordinator
}
