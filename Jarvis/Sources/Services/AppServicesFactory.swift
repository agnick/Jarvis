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
        let tasksDataSource = TasksLocalDataSourceImpl(
            container: swiftDataContextManager.container,
            context: swiftDataContextManager.context
        )

        let commandHandler = QuickLauncherCommandHandlerImpl(tasksDataSource: tasksDataSource)
        return QuickLauncherCoordinatorImpl(viewModel: QuickLauncherViewModelImpl(commandHandler: commandHandler))
    }()
}
