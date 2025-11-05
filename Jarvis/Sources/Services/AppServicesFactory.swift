import Foundation

@MainActor
final class AppServicesFactory: ObservableObject {
    
    // MARK: - Services
    
    lazy var swiftDataContextManager: SwiftDataContextManager = {
        SwiftDataContextManager(models: [
            TaskItem.self
            // сюда можно добавлять новые модельки
        ])
    }()
    
    // MARK: - Factoties
    
    lazy var tasksFactory: TasksFactory = {
        TasksFactoryImpl(swiftDataContextManager: swiftDataContextManager)
    }()
    
    lazy var hotkeyService: HotkeyService = {
        HotkeyServiceImpl()
    }()

    lazy var quickLauncherCoordinator: QuickLauncherCoordinator = {
        QuickLauncherCoordinatorImpl(viewModel: QuickLauncherViewModelImpl())
    }()
}
