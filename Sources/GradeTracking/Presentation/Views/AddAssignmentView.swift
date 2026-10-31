import Core
import SwiftUI

public struct AddAssignmentView: View {
    @StateObject private var viewModel: AddAssignmentViewModel
    @Environment(\.dismiss) var dismiss
    
    public init(
        classRepository: ClassRepositoryProtocol,
        userId: String,
        assignmentRepository: AssignmentRepositoryProtocol
    ) {
        _viewModel = StateObject(wrappedValue: AddAssignmentViewModel(
            addAssignmentUseCase: AddAssignmentUseCase(assignmentRepository: assignmentRepository),
            classRepository: classRepository,
            userId: userId
        ))
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Assignment Details") {
                    if !viewModel.classes.isEmpty {
                        classPickerSection
                    } else if viewModel.isLoadingClasses {
                        ProgressView("Loading classes...")
                    }
                    
                    TextField("Assignment Name", text: $viewModel.name)
                        .onChange(of: viewModel.name) { _ in
                            viewModel.validateForm()
                        }
                    
                    TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                        .lineLimit(3...)
                }
                
                Section("Due Date") {
                    DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: .date)
                }
                
                Section("Grading") {
                    TextField("Score", text: $viewModel.score)
                    
                    TextField("Max Points", text: $viewModel.maxScore)
                        .onChange(of: viewModel.maxScore) { _ in
                            viewModel.validateForm()
                        }
                    
                    TextField("Weight (%)", text: $viewModel.weight)
                        .onChange(of: viewModel.weight) { _ in
                            viewModel.validateForm()
                        }
                    
                    assignmentTypePicker
                }
                
                if let error = viewModel.error {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Add Assignment")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        
                        Button("Save") {
                            Task {
                                do {
                                    _ = try await viewModel.saveAssignment()
                                    dismiss()
                                } catch {
                                    viewModel.error = error.localizedDescription
                                }
                            }
                        }
                        .disabled(!viewModel.isFormValid || viewModel.isLoading)
                    }
                }
            }
            .task {
                await viewModel.loadClasses()
            }
        }
    }
    
    private var classPickerSection: some View {
        Picker("Class", selection: $viewModel.selectedClassId) {
            Text("Select a class").tag(nil as String?)
            ForEach(viewModel.classes, id: \.id) { classItem in
                Text(classItem.courseCode).tag(classItem.id as String?)
            }
        }
        .onChange(of: viewModel.selectedClassId) { _ in
            viewModel.validateForm()
        }
    }
    
    private var assignmentTypePicker: some View {
        Picker("Type", selection: $viewModel.type) {
            ForEach(AssignmentType.allCases, id: \.self) { type in
                Text(type.rawValue).tag(type)
            }
        }
    }
}

#Preview {
    AddAssignmentView(
        classRepository: MockClassRepository(),
        userId: "test-user",
        assignmentRepository: MockAssignmentRepository()
    )
}
