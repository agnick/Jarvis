import AppKit
import Combine
import SwiftData

protocol ClipboardHistoryService: AnyObject {
    var entriesPublisher: AnyPublisher<[String], Never> { get }
    var entries: [String] { get }
    func clear()
    func copyToPasteboard(_ text: String)
}

final class ClipboardHistoryServiceImpl: ClipboardHistoryService {
    // MARK: - Public
    var entriesPublisher: AnyPublisher<[String], Never> {
        entriesSubject.eraseToAnyPublisher()
    }
    var entries: [String] { storage }

    // MARK: - Init
    init(context: ModelContext, maxItems: Int = 30, pollInterval: TimeInterval = 0.5) {
        self.context = context
        self.maxItems = maxItems
        self.pollInterval = pollInterval

        loadFromStore()
        entriesSubject.send(storage)
        startPolling()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - API
    func clear() {
        let fetch = FetchDescriptor<ClipboardEntry>()
        if let all = try? context.fetch(fetch) {
            all.forEach { context.delete($0) }
            try? context.save()
        }
        storage.removeAll()
        entriesSubject.send(storage)
    }

    func copyToPasteboard(_ text: String) {
        suppressNextChange = true
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    // MARK: - Private
    private let context: ModelContext
    private let maxItems: Int
    private let pollInterval: TimeInterval

    private var changeCount: Int = NSPasteboard.general.changeCount
    private var timer: Timer?
    private var storage: [String] = []
    private let entriesSubject = CurrentValueSubject<[String], Never>([])
    private var suppressNextChange: Bool = false

    private func startPolling() {
        timer = Timer.scheduledTimer(withTimeInterval: pollInterval, repeats: true) { [weak self] _ in
            self?.pollPasteboard()
        }
        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    private func pollPasteboard() {
        let pb = NSPasteboard.general
        guard pb.changeCount != changeCount else { return }
        changeCount = pb.changeCount

        if suppressNextChange {
            suppressNextChange = false
            return
        }

        guard let string = pb.string(forType: .string) else { return }
        upsertToFront(string)
    }

    private func loadFromStore() {
        let fetch = FetchDescriptor<ClipboardEntry>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        do {
            let items = try context.fetch(fetch)
            let texts = items.map { $0.text }
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }
            storage = Array(texts.prefix(maxItems))
        } catch {
            storage = []
        }
    }

    private func upsertToFront(_ newValue: String) {
        let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // Уже наверху — ничего не делаем
        if storage.first == trimmed {
            return
        }

        // Найдём существующую запись
        let existing: ClipboardEntry? = fetchEntry(with: trimmed)

        if let entry = existing {
            entry.updatedAt = .now
            try? context.save()

            if let idx = storage.firstIndex(of: trimmed) {
                storage.remove(at: idx)
            }
            storage.insert(trimmed, at: 0)
            publish()
            return
        }

        // Новая запись
        let newEntry = ClipboardEntry(text: trimmed, updatedAt: .now)
        context.insert(newEntry)
        try? context.save()

        storage.insert(trimmed, at: 0)

        // Соблюдаем лимит
        if storage.count > maxItems {
            let overflow = Array(storage.dropFirst(maxItems))
            deleteEntries(withTexts: overflow)
            storage = Array(storage.prefix(maxItems))
        }

        publish()
    }

    private func fetchEntry(with text: String) -> ClipboardEntry? {
        var descriptor = FetchDescriptor<ClipboardEntry>()
        descriptor.predicate = #Predicate { $0.text == text }
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    private func deleteEntries(withTexts texts: [String]) {
        guard !texts.isEmpty else { return }
        var descriptor = FetchDescriptor<ClipboardEntry>()
        descriptor.predicate = #Predicate { entry in
            texts.contains(entry.text)
        }
        if let items = try? context.fetch(descriptor) {
            items.forEach { context.delete($0) }
            try? context.save()
        }
    }

    private func publish() {
        entriesSubject.send(storage)
    }
}
