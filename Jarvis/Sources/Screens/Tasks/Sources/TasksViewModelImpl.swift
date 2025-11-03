import SwiftUI
import Combine

struct TaskFormModel {
    
    // MARK: - Internal Properties
    
    var title: String = ""
    var dueDate: Date = .now
    var priority: TaskPriority = .medium
    var tags: String = ""
    
    // MARK: - Public Methods
    
    func toEntity() -> TaskItem {
        TaskItem(
            title: title,
            dueDate: dueDate,
            priority: priority,
            tags: tags.split(separator: ",").map {
                $0.trimmingCharacters(in: .whitespaces)
            }
        )
    }
}

@MainActor
final class TasksViewModelImpl: TasksViewModel {
    
    // MARK: - Internal Properties
    
    @Published private(set) var tasks: [TaskItem] = []
    
    @Published var selectedPriority: TaskPriority? = nil
    @Published var tagFilter: String = ""
    
    @Published var form = TaskFormModel()
    @Published var formHasError = false
    @Published var isAddSheetPresented = false
    
    @Published var showErrorAlert = false
    @Published var errorMessage: String = ""
    
    // MARK: - Init
    
    init(dataSource: TasksLocalDataSource) {
        self.dataSource = dataSource
        setupBindings()
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
        fetchTasks()
    }
        
    func deleteTask(_ task: TaskItem) {
        dataSource.delete(task)
        fetchTasks()
    }
        
    func resetForm() {
        form = TaskFormModel()
        isAddSheetPresented = false
    }
    
    // MARK: - Private Properties
    
    private let dataSource: TasksLocalDataSource
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Private Methods
    
    private func setupBindings() {
        Publishers.CombineLatest($selectedPriority, $tagFilter)
            .debounce(for: .milliseconds(200), scheduler: RunLoop.main)
            .sink { [weak self] _, _ in
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
                
            tasks = fetchedTasks
        case .failure(let error):
            errorMessage = error.description
            showErrorAlert = true
        }
    }
}
