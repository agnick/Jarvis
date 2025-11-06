import AppKit
import Combine
import SwiftUI

@MainActor
protocol ClipboardHistoryViewModel: ObservableObject {
    var query: String { get set }
    var items: [String] { get }
    var filteredItems: [String] { get }
    var selectionIndex: Int? { get set }
    var copiedText: String? { get }

    func clear()
    func selectNext()
    func selectPrev()
    func activateSelection()
    func onAppear()
    var onClose: (() -> Void)? { get set }
}

final class ClipboardHistoryViewModelImpl: ClipboardHistoryViewModel {
    @Published var query: String = ""
    @Published var selectionIndex: Int? = nil

    @Published private(set) var items: [String] = []
    @Published private(set) var filteredItems: [String] = []
    @Published private(set) var copiedText: String? = nil

    init(service: ClipboardHistoryService) {
        self.service = service
        items = service.entries
        filteredItems = items

        serviceCancellable = service.entriesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newItems in
                guard let self else { return }
                self.items = newItems
                self.applyFilter()
            }

        $query
            .removeDuplicates()
            .debounce(for: .milliseconds(150), scheduler: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.applyFilter()
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        selectionIndex = filteredItems.isEmpty ? nil : 0
    }

    func clear() {
        service.clear()
        selectionIndex = nil
    }

    func selectNext() {}
    func selectPrev() {}

    func activateSelection() {
        guard let idx = selectionIndex, filteredItems.indices.contains(idx) else { return }
        let text = filteredItems[idx]
        service.copyToPasteboard(text)

        copiedText = text
        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run { self?.copiedText = nil }
        }

        // Закрываем окно после выбора элемента
        onClose?()
    }

    var onClose: (() -> Void)?

    private let service: ClipboardHistoryService
    private var serviceCancellable: AnyCancellable?
    private var cancellables = Set<AnyCancellable>()

    private func applyFilter() {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if q.isEmpty {
            filteredItems = items
        } else {
            filteredItems = items.filter { $0.localizedCaseInsensitiveContains(q) }
        }
        if filteredItems.isEmpty {
            selectionIndex = nil
        } else if selectionIndex == nil || !(filteredItems.indices.contains(selectionIndex!)) {
            selectionIndex = 0
        }
    }
}
