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

            appServicesFactory.pomodoroFactory.makePomodoroScreen()
                .tabItem {
                    Label("Focus", systemImage: "timer")
                }

            ClipboardHistoryView(viewModel: appServicesFactory.clipboardViewModelImpl)
                .tabItem {
                    Label("Clipboard", systemImage: "doc.on.clipboard")
                }
        }
        .tabViewStyle(.automatic)
    }
    
    // MARK: - Private Properties
    
    private var appServicesFactory: AppServicesFactory
}
