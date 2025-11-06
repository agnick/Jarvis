import SwiftUI

struct RootTabView: View {
    
    // MARK: - Init
    
    init(appServicesFactory: AppServicesFactory) {
        self.appServicesFactory = appServicesFactory
    }
    
    // MARK: - Body
    
    var body: some View {
        TabView {
            appServicesFactory.tasksFactory.makeTasksScreen()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }

            Color.red
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            ClipboardHistoryView(viewModel: appServicesFactory.clipboardViewModelImpl)
                .tabItem {
                    Label("Clipboard", systemImage: "doc.on.clipboard")
                }

            Color.blue
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        .tabViewStyle(.automatic)
    }
    
    // MARK: - Private Properties
    
    private var appServicesFactory: AppServicesFactory
}
