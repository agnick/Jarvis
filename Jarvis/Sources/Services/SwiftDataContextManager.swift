import SwiftData

final class SwiftDataContextManager {
    
    // MARK: - Internal Properties
    
    let container: ModelContainer
    let context: ModelContext
    
    // MARK: - Init
    
    init(models: [any PersistentModel.Type]) {
        do {
            let schema = Schema(models)
            container = try ModelContainer(for: schema)
            context = ModelContext(container)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    convenience init(model: any PersistentModel.Type) {
        self.init(models: [model])
    }
}
