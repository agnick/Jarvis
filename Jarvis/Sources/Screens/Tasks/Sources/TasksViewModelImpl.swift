import SwiftUI
import SwiftData
import Combine

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    
    // MARK: - Internal Properties
    
    @Published private(set) var tasks: [TaskItem] = []
    
    @Published var sortOption: TaskSortOption = .byDate
    @Published var selectedPriority: TaskPriority? = nil
    @Published var tagFilter: String = ""
    
    @Published var currentEditingTask: TaskItem? = nil
    @Published var form = TaskForm()
    @Published var formHasError = false
    @Published var isAddSheetPresented = false
    
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    
    // MARK: - Init
    
    init(dataSource: TasksLocalDataSource) {
        self.dataSource = dataSource
        setupBindings()
        setupExternalUpdates()
        fetchTasks()
    }
    
    // MARK: - Public Methods
    
    func addTask() {
        guard !form.title.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        let newTask = form.toEntity()
        dataSource.insert(newTask)
        resetForm()
    }
    
    func editTask(_ task: TaskItem) {
        currentEditingTask = task
        form = TaskForm(from: task)
        isAddSheetPresented = true
    }

    func updateTask(_ task: TaskItem) {
        let updated = form.toEntity(existing: task)
        dataSource.insert(updated)
        resetForm()
    }
        
    func deleteTask(_ task: TaskItem) {
        dataSource.delete(task)
    }
        
    func resetForm() {
        form = TaskForm()
        isAddSheetPresented = false
    }
    
    // MARK: - Private Properties
    
    private let dataSource: TasksLocalDataSource
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        Publishers.CombineLatest3($selectedPriority, $tagFilter, $sortOption)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _, _, _ in
                self?.fetchTasks()
            }
            .store(in: &cancellables)
    }
    
    private func setupExternalUpdates() {
        NotificationCenter.default.publisher(
            for: ModelContext.didSave,
            object: nil
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] _ in
            self?.fetchTasks()
        }
        .store(in: &cancellables)
    }
    
    private func fetchTasks() {
        let fetchResult = dataSource.fetchTasks()
        switch fetchResult {
        case .success(var fetchedTasks):
            if let selectedPriority {
                fetchedTasks = fetchedTasks.filter {
                    $0.priority == selectedPriority
                }
            }
                    
            if !tagFilter.isEmpty {
                fetchedTasks = fetchedTasks.filter {
                    $0.tags.contains {
                        $0.localizedCaseInsensitiveContains(tagFilter)
                    }
                }
            }
                
            switch sortOption {
            case .byName:
                fetchedTasks.sort {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .byDate:
                fetchedTasks.sort {
                    ($0.dueDate ?? .distantFuture) < ($1.dueDate ?? .distantFuture)
                }
            case .byPriority:
                fetchedTasks.sort {
                    $0.priority.sortOrder < $1.priority.sortOrder
                }
            }

            tasks = fetchedTasks
                
        case .failure(let error):
            errorMessage = error.description
            showErrorAlert = true
        }
    }
}
