import Foundation
import SwiftData
import SwiftUI

@Model
final class TaskItem {
    @Attribute(.unique) var id: UUID
    var title: String
    var dueDate: Date?
    var priority: TaskPriority
    var tags: [String]
    
    init(
        title: String,
        dueDate: Date? = nil,
        priority: TaskPriority = .medium,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.dueDate = dueDate
        self.priority = priority
        self.tags = tags
    }
}

enum TaskPriority: String, Codable, CaseIterable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}
