import SwiftUI

@MainActor
protocol TasksViewModel: ObservableObject {
    
}

struct TasksView<ViewModel: TasksViewModel>: View {
    
    // MARK: - Internal Properties
    
    @StateObject var viewModel: ViewModel
    
    // MARK: - Body
    
    var body: some View {
        Color.yellow
    }
}
