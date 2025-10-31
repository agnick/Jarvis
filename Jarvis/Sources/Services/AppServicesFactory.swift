import Foundation

@MainActor
final class AppServicesFactory: ObservableObject {
    
    // MARK: - Factoties
    
    lazy var tasksFactory: TasksFactory = {
        TasksFactoryImpl()
    }()
}
