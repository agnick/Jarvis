import SwiftUI

@main
struct JarvisApp: App {
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
    
    // MARK: - Private Properties
    
    @StateObject private var appServicesFactory = AppServicesFactory()
}
