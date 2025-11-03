import Foundation
import SwiftData

@MainActor
protocol TasksLocalDataSource {
    func insert(_ entity: TaskItem)
    func delete(_ entity: TaskItem)
    func fetchTasks() -> Result<[TaskItem], TasksDataSourceError>
}

final class TasksLocalDataSourceImpl: TasksLocalDataSource {
    
    // MARK: - Init
    
    init(container: ModelContainer?, context: ModelContext?) {
        self.container = container
        self.context = context
    }
    
    // MARK: - Public Methods
    
    func insert(_ entity: TaskItem) {
        guard let context else {
            return
        }
        
        context.insert(entity)
        try? context.save()
    }
    
    func delete(_ entity: TaskItem) {
        guard let context else {
            return
        }
        
        context.delete(entity)
        try? context.save()
    }
    
    func fetchTasks() -> Result<[TaskItem], TasksDataSourceError> {
        guard let context else {
            return .failure(.fetchFailed)
        }
        
        let fetchDescriptor = FetchDescriptor<TaskItem>(
            sortBy: [SortDescriptor(\.dueDate, order: .forward)]
        )
        
        do {
            let result = try context.fetch(fetchDescriptor)
            return .success(result)
        } catch {
            return .failure(.fetchFailed)
        }
    }
    
    // MARK: - Private Properties
    
    private let container: ModelContainer?
    private let context: ModelContext?
}
