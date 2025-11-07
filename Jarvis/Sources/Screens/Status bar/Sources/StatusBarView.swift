import SwiftUI

@MainActor
protocol StatusBarViewModel: ObservableObject {
    func openQuickLauncher()
    func quitApp()
}

struct StatusBarView<ViewModel: StatusBarViewModel>: View {
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 4) {
                actionButton("Open Quick Launcher") {
                    viewModel.openQuickLauncher()
                }
                Text("Command ⌘ + Option ⌥ + J")
                    .foregroundStyle(.gray)
            }

            Divider()
            
            actionButton("Quit App") {
                viewModel.quitApp()
            }
        }
        .padding(12)
        .frame(width: 256)
    }
    
    // MARK: - Private

    private func actionButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(title)
                .font(.headline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 4)
    }
}

