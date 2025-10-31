import SwiftUI

@main
struct JarvisApp: App {
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootTabView(appServicesFactory: appServicesFactory)
        }
    }
    
    // MARK: - Private Properties
    
    @StateObject private var appServicesFactory = AppServicesFactory()
}
