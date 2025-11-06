import Foundation
import SwiftUI

@MainActor
protocol QuickLauncherCommandHandler {
    func handle(command: String)
}

final class QuickLauncherCommandHandlerImpl: QuickLauncherCommandHandler {
    
    private let tasksDataSource: TasksLocalDataSource
    
    init(tasksDataSource: TasksLocalDataSource) {
        self.tasksDataSource = tasksDataSource
    }
    
    func handle(command: String) {
        let components = command.split(separator: " ")
        guard let first = components.first else { return }
        
        switch first.lowercased() {
        case "task":
            handleTaskCommand(components: components.dropFirst())
        default:
            print("Unknown command: \(command)")
        }
    }
    
    private func handleTaskCommand(components: ArraySlice<Substring>) {
        // Format: task [title] #tags @due !priority
        let text = components.joined(separator: " ")
        
        let title = text
            .split(separator: "#")
            .first?.split(separator: "@")
            .first?.split(separator: "!")
            .first?.trimmingCharacters(in: .whitespaces) ?? ""
        
        let tags = text.components(separatedBy: "#").dropFirst().map { $0.split(separator: " ").first ?? "" }.map(String.init)
        
        var dueDate: Date? = nil
        if let dueToken = text.components(separatedBy: "@").dropFirst().first?.split(separator: " ").first {
            if dueToken.lowercased().contains("завтра") {
                dueDate = Calendar.current.date(byAdding: .day, value: 1, to: .now)
            } else if dueToken.lowercased().contains("today") || dueToken.lowercased().contains("сегодня") {
                dueDate = .now
            }
        }
        
        var priority: TaskPriority = .medium
        if let priorityToken = text.components(separatedBy: "!").dropFirst().first?.split(separator: " ").first {
            switch priorityToken.lowercased() {
            case "высокий", "high": priority = .high
            case "низкий", "low": priority = .low
            default: break
            }
        }
        
        let task = TaskItem(
            title: title,
            dueDate: dueDate,
            priority: priority,
            tags: tags
        )
        tasksDataSource.insert(task)
        print("Task added successfully: \(task.title)")
    }
}

