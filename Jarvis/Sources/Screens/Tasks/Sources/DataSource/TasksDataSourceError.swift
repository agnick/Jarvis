import Foundation

enum TasksDataSourceError: CustomStringConvertible, Error {
    case fetchFailed
    
    var description: String {
        switch self {
        case .fetchFailed: "Failed to load your tasks"
        }
    }
}
