import SwiftUI

@MainActor
protocol QuickLauncherViewModel: ObservableObject {
    var command: String { get set }
    func clearCommand()
}

struct QuickLauncherView<ViewModel: QuickLauncherViewModel>: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        HStack(alignment: .center, spacing: 8){
            TextField("Enter command here...", text: $viewModel.command)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            Button {
                viewModel.clearCommand()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .frame(width: 16, height: 16)
        }
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
        .frame(width: 512, height: 64)
        .background(.ultraThinMaterial)
    }
}
