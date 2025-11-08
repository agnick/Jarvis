import SwiftUI

@MainActor
protocol QuickLauncherViewModel: ObservableObject {
    var command: String { get set }
    var statusMessage: StatusMessage? { get set }
    var clipboardItems: [String] { get }
    var isVisible: Bool { get set }

    func clearCommand()
    func executeCommand()
    func copyClipboardItem(_ text: String)
}

struct QuickLauncherView<ViewModel: QuickLauncherViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .center, spacing: 8) {
                    
                TextField("Enter command here...", text: $viewModel.command)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .font(.system(size: 24))
                    .frame(height: 48)
                    .focused($isFocused)
                    .onChange(of: viewModel.command) {
                        if !viewModel.command.isEmpty {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                viewModel.statusMessage = nil
                            }
                        }
                    }
                    .onSubmit {
                        viewModel.executeCommand()
                        isFocused = false
                    }
                    .submitLabel(.search)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color(nsColor: .textBackgroundColor).opacity(0.77))
                    )
                
                Button {
                    viewModel.clearCommand()
                    isFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
            }
            
            Text("Task example: \"task Купить продукты #дом #покупки @завтра !низкий\"")
                .foregroundStyle(.gray)
                .font(.system(size: 12))
                .padding(.leading, 4)
            
            if let status = viewModel.statusMessage {
                switch status {
                case .success(let message):
                    Text(message)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.green)
                        .transition(.slide.combined(with: .blurReplace))
                        .padding(.leading, 4)
                case .unknown(let message):
                    Text(message)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.yellow)
                        .transition(.slide.combined(with: .blurReplace))
                        .padding(.leading, 4)
                case .error(let error):
                    Text(error)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.red)
                        .transition(.slide.combined(with: .blurReplace))
                        .padding(.leading, 4)
                }
            } else {
                Color.clear.frame(height: 12)
            }
            
            if !viewModel.clipboardItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(viewModel.clipboardItems, id: \.self) { item in
                        Button {
                            viewModel.copyClipboardItem(item)
                        } label: {
                            Text(item)
                                .padding(.horizontal, 16)
                                .lineLimit(1)
                                .font(.system(size: 12))
                                .frame(height: 24)
                                .background(
                                    RoundedRectangle(cornerRadius: 15)
                                        .fill(Color(nsColor: .textBackgroundColor).opacity(0.77))
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: viewModel.statusMessage)
        .padding(.bottom, 16)
        .padding(.horizontal, 16)
        .frame(width: 650, height: 256)
        .background(.clear)
    }
}
