import SwiftUI

@MainActor
protocol TasksFactory {
    func makeTasksScreen() -> AnyView
}

struct TasksFactoryImpl: TasksFactory {
    
    // MARK: - Init
    
    init(swiftDataContextManager: SwiftDataContextManager) {
        self.swiftDataContextManager = swiftDataContextManager
    }
    
    // MARK: - Public Methods

    func makeTasksScreen() -> AnyView {
        let viewModel = TasksViewModelImpl(
            dataSource: TasksLocalDataSourceImpl(
                container: swiftDataContextManager.container,
                context: swiftDataContextManager.context
            )
        )
        let view = TasksView(viewModel: viewModel)
        return AnyView(view)
    }
    
    // MARK: - Private Properties
    
    private let swiftDataContextManager: SwiftDataContextManager
}
