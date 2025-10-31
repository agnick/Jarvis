import SwiftUI

@MainActor
protocol TasksFactory {
    func makeTasksScreen() -> AnyView
}

struct TasksFactoryImpl: TasksFactory {
    
    // MARK: - Public Methods

    func makeTasksScreen() -> AnyView {
        let viewModel = TasksViewModelImpl()
        let view = TasksView(viewModel: viewModel)
        return AnyView(view)
    }
}
