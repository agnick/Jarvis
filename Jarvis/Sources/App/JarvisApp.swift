import SwiftUI

@main
struct JarvisApp: App {

    // MARK: - Body

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
        MenuBarExtra("Productivity", systemImage: "bolt.fill") {
            appServicesFactory.statusBarFactory.makeMenuBarView()
        }
        .menuBarExtraStyle(.window)
    }

    // MARK: - Private Properties

    @StateObject private var appServicesFactory = AppServicesFactory()
}
