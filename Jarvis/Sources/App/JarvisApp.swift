import SwiftUI

@main
struct JarvisApp: App {
    
    var body: some Scene {
        WindowGroup {
            RootTabView(appServicesFactory: appServicesFactory)
                .onAppear {
                    appServicesFactory.hotkeyService.registerHotkey {
                        Task { @MainActor in
                            appServicesFactory.quickLauncherCoordinator.toggleLauncher()
                        }
                    }
                    appServicesFactory.registerClipboardHotkey()
                }
        }
    }
    
    @StateObject private var appServicesFactory = AppServicesFactory()
}

