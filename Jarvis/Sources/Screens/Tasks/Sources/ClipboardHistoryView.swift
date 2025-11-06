import SwiftUI

struct ClipboardHistoryView<ViewModel: ClipboardHistoryViewModel>: View {
    @ObservedObject var viewModel: ViewModel
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 10) {
            // Search + Clear
            HStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search clipboard…", text: $viewModel.query)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($isSearchFocused)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))

                Button {
                    viewModel.clear()
                } label: {
                    Label("Clear", systemImage: "trash")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }

            // List
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(Array(viewModel.filteredItems.enumerated()), id: \.offset) { index, item in
                        ClipboardRow(
                            text: item,
                            query: viewModel.query,
                            isSelected: viewModel.selectionIndex == index,
                            showCopied: viewModel.copiedText == item
                        )
                        .onTapGesture {
                            viewModel.selectionIndex = index
                            withAnimation(.easeInOut(duration: 0.15)) {
                                viewModel.activateSelection()
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .frame(minWidth: 560, maxWidth: .infinity, minHeight: 380, maxHeight: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.thinMaterial)
            )
        }
        .padding(16)
        .frame(minWidth: 592, maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            isSearchFocused = true
            viewModel.onAppear()
        }
    }
}

private struct ClipboardRow: View {
    let text: String
    let query: String
    let isSelected: Bool
    let showCopied: Bool

    // Базовая высота строки и максимально допустимое увеличение (x2)
    private let baseRowHeight: CGFloat = 32

    var body: some View {
        ZStack(alignment: .trailing) {
            // Основной контент строки
            HStack(alignment: .center, spacing: 8) {
                Image(systemName: "doc.on.clipboard")
                    .foregroundStyle(.secondary)

                HighlightedText(text: text, highlight: query)
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .lineLimit(4)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 6)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .frame(minHeight: baseRowHeight, maxHeight: baseRowHeight * 2, alignment: .center)

            // Бейдж "Copied" поверх контента
            CopiedBadge()
                .opacity(showCopied ? 1.0 : 0.0)
                .animation(.easeInOut(duration: 0.25), value: showCopied)
                .padding(.trailing, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isSelected ? Color.accentColor.opacity(0.18) : Color(nsColor: .textBackgroundColor).opacity(0.6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .contextMenu {
            Button("Copy") {
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(text, forType: .string)
            }
        }
    }
}

private struct HighlightedText: View {
    let text: String
    let highlight: String

    var body: some View {
        Text(normalized)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var normalized: String {
        text.components(separatedBy: .whitespacesAndNewlines).joined(separator: " ")
    }
}

private struct CopiedBadge: View {
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
            Text("Copied")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(RoundedRectangle(cornerRadius: 10).fill(.regularMaterial))
        .shadow(radius: 6, y: 2)
    }
}
