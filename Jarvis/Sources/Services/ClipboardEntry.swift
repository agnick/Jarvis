import Foundation
import SwiftData

@Model
final class ClipboardEntry {
    @Attribute(.unique) var text: String
    var updatedAt: Date

    init(text: String, updatedAt: Date = .now) {
        self.text = text
        self.updatedAt = updatedAt
    }
}
