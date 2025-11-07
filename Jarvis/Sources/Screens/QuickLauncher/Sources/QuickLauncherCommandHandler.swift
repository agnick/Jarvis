import Foundation
import SwiftUI

@MainActor
protocol QuickLauncherCommandHandler {
    func handle(command: String) -> StatusMessage
}

final class QuickLauncherCommandHandlerImpl: QuickLauncherCommandHandler {
    
    private let tasksDataSource: TasksLocalDataSource
    
    init(tasksDataSource: TasksLocalDataSource) {
        self.tasksDataSource = tasksDataSource
    }
    
    func handle(command: String) -> StatusMessage {
        let components = command.split(separator: " ")
        guard let first = components.first else {
            return .error("⁉️ Empty command")
        }
        
        switch first.lowercased() {
        case "task":
            return handleTaskCommand(components: components.dropFirst())
        default:
            return .unknown("⚠️ Unknown command")
        }
    }
    
    private func handleTaskCommand(components: ArraySlice<Substring>) -> StatusMessage {
        // Format: task [title] #tags @dueDate [time] !priority
        let text = components.joined(separator: " ")
        
        // MARK: - Title
        let title = text
            .split(separator: "#")
            .first?.split(separator: "@")
            .first?.split(separator: "!")
            .first?
            .trimmingCharacters(in: .whitespaces) ?? "Без названия"
        
        // MARK: - Tags
        let tags = text
            .components(separatedBy: "#")
            .dropFirst()
            .compactMap { $0.split(separator: " ").first }
            .map(String.init)
        
        // MARK: - Due Date + Time
        var dueDate: Date? = nil
        if let afterAt = text.components(separatedBy: "@").dropFirst().first {
            // пример: "@10.11.2025 18:30" или "@сегодня 12:00"
            let parts = afterAt.split(separator: "!")
                .first?
                .split(separator: "#")
                .first?
                .trimmingCharacters(in: .whitespaces)
            if let dateString = parts {
                dueDate = parseDateTime(String(dateString))
            }
        }
        
        // MARK: - Priority
        var priority: TaskPriority = .medium
        if let priorityToken = text.components(separatedBy: "!").dropFirst().first?.split(separator: " ").first {
            priority = parsePriority(String(priorityToken))
        }
        
        // MARK: - Create and insert
        let task = TaskItem(
            title: title,
            dueDate: dueDate,
            priority: priority,
            tags: tags
        )
        
        tasksDataSource.insert(task)
        return .success("✅ Task created successfully: \(task.title)")
    }
}

// MARK: - Parsing Helpers
private extension QuickLauncherCommandHandlerImpl {
    
    func parsePriority(_ token: String) -> TaskPriority {
        switch token.lowercased() {
        case "высокий", "high": return .high
        case "низкий", "low": return .low
        case "средний", "medium": return .medium
        default: return .medium
        }
    }
    
    func parseDateTime(_ raw: String) -> Date? {
        let lower = raw.lowercased()
        let calendar = Calendar.current
        
        // MARK: — Примитивные случаи
        if lower.contains("сегодня") || lower.contains("today") {
            return parseTimePart(baseDate: .now, raw: lower)
        }
        if lower.contains("завтра") || lower.contains("tomorrow") {
            if let tomorrow = calendar.date(byAdding: .day, value: 1, to: .now) {
                return parseTimePart(baseDate: tomorrow, raw: lower)
            }
        }
        
        // MARK: — Дата + время
        let dateFormats = [
            "dd.MM.yyyy HH:mm",
            "dd/MM/yyyy HH:mm",
            "dd.MM.yy HH:mm",
            "dd/MM/yy HH:mm",
            "dd.MM.yyyy",
            "dd/MM/yyyy",
            "dd.MM.yy",
            "dd/MM/yy"
        ]
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        
        for format in dateFormats {
            formatter.dateFormat = format
            if let date = formatter.date(from: raw) {
                return date
            }
        }
        
        // MARK: — Если указано только время (например, "@12:00")
        return parseTimePart(baseDate: .now, raw: lower)
    }
    
    func parseTimePart(baseDate: Date, raw: String) -> Date? {
        // ищем время в формате HH:mm
        let timeRegex = try! NSRegularExpression(pattern: #"(\d{1,2}):(\d{2})"#)
        if let match = timeRegex.firstMatch(in: raw, range: NSRange(raw.startIndex..., in: raw)),
           let hourRange = Range(match.range(at: 1), in: raw),
           let minuteRange = Range(match.range(at: 2), in: raw),
           let hour = Int(raw[hourRange]),
           let minute = Int(raw[minuteRange]) {
            
            var components = Calendar.current.dateComponents([.year, .month, .day], from: baseDate)
            components.hour = hour
            components.minute = minute
            return Calendar.current.date(from: components)
        }
        return baseDate
    }
}

enum StatusMessage: Equatable {
    case success(String)
    case unknown(String)
    case error(String)
}
