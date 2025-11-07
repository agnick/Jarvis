import SwiftUI

struct TaskEditorView: View {
    
    // MARK: - Internal Properties
    
    @Binding var form: TaskForm
    var taskToEdit: TaskItem?
    var onSave: () -> Void
    var onCancel: () -> Void
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                VStack(alignment: .leading, spacing: 10.0) {
                    Section("Details") {
                        TextField("Title", text: $form.title)
                            .fontWeight(.regular)
                        
                        Toggle("Set Due Date", isOn: $hasDueDate)
                                            
                        if hasDueDate {
                            DatePicker(
                                "Due Date",
                                selection: Binding(
                                    get: { form.dueDate ?? .now },
                                    set: { form.dueDate = $0 }
                                ),
                                displayedComponents: [.date, .hourAndMinute]
                            )
                            .fontWeight(.regular)
                        }
                        
                        Picker("Priority", selection: $form.priority) {
                            ForEach(TaskPriority.allCases, id: \.self) {
                                Text($0.rawValue)
                            }
                        }
                        .fontWeight(.regular)
                    }
                    .fontWeight(.semibold)
                    
                    Section("Tags") {
                        TextField("Comma-separated tags", text: $form.tags)
                            .fontWeight(.regular)
                    }
                    .fontWeight(.semibold)
                }
            }
            .padding(.vertical, 10.0)
            .padding(.horizontal, 15.0)
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(taskToEdit == nil ? "Add" : "Save") {
                        onSave()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
            }
        }
    }
    
    // MARK: - Private Properties
    
    @State private var hasDueDate: Bool = true
}
