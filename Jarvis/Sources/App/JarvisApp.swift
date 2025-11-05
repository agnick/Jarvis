import SwiftUI

@main
struct JarvisApp: App {
    
    // MARK: - Init
    
    init() {
        HotkeyManager.shared.registerHotkey()
    }
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootTabView(appServicesFactory: appServicesFactory)
        }
    }
    
    // MARK: - Private Properties
    
    @StateObject private var appServicesFactory = AppServicesFactory()
}
