import Foundation

struct TaskForm {
    
    // MARK: - Internal Properties
    
    var title: String = ""
    var dueDate: Date? = nil 
    var priority: TaskPriority = .medium
    var tags: String = ""
    
    // MARK: - Init
    
    init() {}
        
    init(from task: TaskItem) {
        self.title = task.title
        self.dueDate = task.dueDate ?? .now
        self.priority = task.priority
        self.tags = task.tags.joined(separator: ", ")
    }
    
    // MARK: - Public Methods
    
    func toEntity(existing: TaskItem? = nil) -> TaskItem {
        if let existing {
            existing.title = title
            existing.dueDate = dueDate
            existing.priority = priority
            existing.tags = tags
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            return existing
        } else {
            return TaskItem(
                title: title,
                dueDate: dueDate,
                priority: priority,
                tags: tags
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
            )
        }
    }
}
