import SwiftUI

@MainActor
protocol StatusBarFactory {
    func makeMenuBarView() -> AnyView
}

struct StatusBarFactoryImpl: StatusBarFactory {
    
    // MARK: - Initialization
    
    init(quickLauncherCoordinator: QuickLauncherCoordinator) {
        self.quickLauncherCoordinator = quickLauncherCoordinator
    }
    
    func makeMenuBarView() -> AnyView {
        let viewModel = StatusBarViewModelImpl(coordinator: quickLauncherCoordinator)
        let view = StatusBarView(viewModel: viewModel)
        return AnyView(view)
    }
    
    // MARK: - Private
    
    private let quickLauncherCoordinator: QuickLauncherCoordinator
}

