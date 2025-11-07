import SwiftUI

@MainActor
protocol TasksViewModel: ObservableObject {
    var tasks: [TaskItem] { get }
    var sortOption: TaskSortOption { get set }
    var selectedPriority: TaskPriority? { get set }
    var tagFilter: String { get set }
    var isAddSheetPresented: Bool { get set }
    var currentEditingTask: TaskItem? { get }
    var form: TaskForm { get set }
    var showErrorAlert: Bool { get set }
    var errorMessage: String { get }
    
    func addTask()
    func editTask(_ task: TaskItem)
    func updateTask(_ task: TaskItem)
    func deleteTask(_ task: TaskItem)
    func resetForm()
}

struct TasksView<ViewModel: TasksViewModel>: View {
    
    // MARK: - Init
    
    init(viewModel: ViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 12.0) {
                filterPanel
                tasksList
            }
            .padding(.horizontal, 15.0)
            .padding(.vertical, 10.0)
            .toolbar {
                Button {
                    viewModel.isAddSheetPresented = true
                } label: {
                    Label("Add Task", systemImage: "plus")
                }
            }
            .sheet(isPresented: $viewModel.isAddSheetPresented) {
                TaskEditorView(
                    form: $viewModel.form,
                    taskToEdit: viewModel.currentEditingTask,
                    onSave: {
                        if let task = viewModel.currentEditingTask {
                            viewModel.updateTask(task)
                        } else {
                            viewModel.addTask()
                        }
                    },
                    onCancel: {
                        viewModel.resetForm()
                    }
                )
                .presentationDetents([.medium, .large])
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK", role: .cancel) {
                    viewModel.showErrorAlert = false
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
    
    // MARK: - Private Properties
    
    @StateObject private var viewModel: ViewModel
    
    // MARK: - Private Views
    
    private var filterPanel: some View {
        HStack {
            Picker("Sort", selection: $viewModel.sortOption) {
                ForEach(TaskSortOption.allCases, id: \.self) { option in
                    Text(option.rawValue)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            Picker("Priority", selection: $viewModel.selectedPriority) {
                Text("All").tag(TaskPriority?.none)
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    Text(priority.rawValue).tag(TaskPriority?.some(priority))
                }
            }
            .pickerStyle(MenuPickerStyle())
                            
            TextField("Filter by tag...", text: $viewModel.tagFilter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
    
    @ViewBuilder
    private var tasksList: some View {
        ScrollViewReader { proxy in
            Group {
                if viewModel.tasks.isEmpty {
                    ContentUnavailableView(
                        TasksStrings.emptyLabel,
                        systemImage: "checklist",
                        description: Text(TasksStrings.emptyDescription)
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.tasks, id: \.id) { task in
                            row(task)
                                .id(task.id)
                        }
                    }
                    .listStyle(.plain)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .onChange(of: viewModel.tasks) { _, _ in
                scrollToTop(proxy: proxy)
            }
            .onChange(of: viewModel.selectedPriority) { _, _ in
                scrollToTop(proxy: proxy)
            }
            .onChange(of: viewModel.tagFilter) { _, _ in
                scrollToTop(proxy: proxy)
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func row(_ task: TaskItem) -> some View {
        HStack(spacing: 10.0) {
            VStack(alignment: .leading, spacing: 6.0) {
                HStack(spacing: 5.0) {
                    Text(task.title)
                        .fontWeight(.medium)
                        .offset(y: -1.0)
                    
                    Circle()
                        .fill(task.priority.color)
                        .frame(width: 10.0, height: 10.0)
                }
                
                if let date = task.dueDate {
                    Text("Due: \(date.formatted(date: .abbreviated, time: .shortened))")
                        .foregroundColor(.secondary)
                }
                
                if !task.tags.isEmpty {
                    HStack {
                        ForEach(task.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .lineLimit(1)
                                .padding(.horizontal, 6.0)
                                .padding(.vertical, 2.0)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(6.0)
                        }
                    }
                }
            }
            
            Spacer()
            
            HStack(spacing: 5.0) {
                Button {
                    viewModel.editTask(task)
                } label: {
                    Image(systemName: "pencil")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(.blue)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
                
                Button {
                    viewModel.deleteTask(task)
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 13.0, weight: .semibold))
                        .foregroundColor(.red)
                        .padding(6.0)
                        .background(
                            Circle().fill(Color.red.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 14.0)
        .padding(.horizontal, 10.0)
    }
    
    private func scrollToTop(proxy: ScrollViewProxy) {
        guard let firstId = viewModel.tasks.first?.id else {
            return
        }
        
        proxy.scrollTo(firstId)
    }
}
