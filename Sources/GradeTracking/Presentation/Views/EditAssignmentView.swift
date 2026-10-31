import Core
import SwiftUI

public struct EditAssignmentView: View {
    @StateObject private var viewModel: EditAssignmentViewModel
    @Environment(\.dismiss) var dismiss
    
    /// For adding a new assignment
    public init(
        classRepository: ClassRepositoryProtocol,
        userId: String,
        assignmentRepository: AssignmentRepositoryProtocol
    ) {
        _viewModel = StateObject(wrappedValue: EditAssignmentViewModel(
            editAssignmentUseCase: UpdateAssignmentScoreUseCase(assignmentRepository: assignmentRepository),
            addAssignmentUseCase: AddAssignmentUseCase(assignmentRepository: assignmentRepository),
            classRepository: classRepository,
            userId: userId,
            mode: .create
        ))
    }
    
    /// For editing an existing assignment
    public init(
        assignment: Assignment,
        classRepository: ClassRepositoryProtocol,
        userId: String,
        assignmentRepository: AssignmentRepositoryProtocol
    ) {
        _viewModel = StateObject(wrappedValue: EditAssignmentViewModel(
            editAssignmentUseCase: UpdateAssignmentScoreUseCase(assignmentRepository: assignmentRepository),
            addAssignmentUseCase: AddAssignmentUseCase(assignmentRepository: assignmentRepository),
            classRepository: classRepository,
            userId: userId,
            mode: .edit(assignment)
        ))
    }
    
    public var body: some View {
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
                    .disabled(!viewModel.isCreating)
                
                TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                    .lineLimit(3...)
                    .disabled(!viewModel.isCreating)
            }
            
            Section("Due Date") {
                DatePicker("Due Date", selection: $viewModel.dueDate, displayedComponents: .date)
                    .disabled(!viewModel.isCreating)
            }
            
            Section("Grading") {
                TextField("Score", text: $viewModel.score)
                
                Picker("Quick Grade", selection: $viewModel.selectedGrade) {
                    ForEach(GradeOption.options) { option in
                        Text(option.label).tag(option)
                    }
                }
                .onChange(of: viewModel.selectedGrade) { newGrade in
                    if let percentage = newGrade.percentage {
                        viewModel.score = String(percentage)
                    } else {
                        viewModel.score = ""
                    }
                    viewModel.validateForm()
                }
                
                assignmentTypePicker
                    .onChange(of: viewModel.type) { _ in
                        viewModel.validateForm()
                    }
                
                if viewModel.isCreating {
                    HStack {
                        Text("Score Percentage")
                            .foregroundColor(.secondary)
                        Spacer()
                        if let percentage = viewModel.scorePercentage {
                            Text(String(format: "%.0f%%", percentage))
                                .fontWeight(.semibold)
                        } else {
                            Text("Not entered")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if let error = viewModel.error {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            
            Section {
                HStack(spacing: 12) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    
                    Button(viewModel.isCreating ? "Save" : "Update") {
                        Task {
                            do {
                                try await viewModel.save()
                                dismiss()
                            } catch {
                                viewModel.error = error.localizedDescription
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(!viewModel.isFormValid)
                    .opacity(viewModel.isFormValid ? 1.0 : 0.6)
                }
            }
        }
        .navigationTitle(viewModel.isCreating ? "Add Assignment" : "Edit Assignment")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button(viewModel.isCreating ? "Save" : "Update") {
                    Task {
                        do {
                            try await viewModel.save()
                            dismiss()
                        } catch {
                            viewModel.error = error.localizedDescription
                        }
                    }
                }
                .disabled(!viewModel.isFormValid)
            }
        }
        .task {
            await viewModel.loadClasses()
        }
        .onChange(of: viewModel.selectedClassId) { _ in
            viewModel.validateForm()
        }
    }
    
    private var classPickerSection: some View {
        Picker("Class", selection: $viewModel.selectedClassId) {
            ForEach(viewModel.classes, id: \.id) { classItem in
                Text(classItem.courseCode).tag(classItem.id)
            }
        }
        .disabled(!viewModel.isCreating)
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
    EditAssignmentView(
        classRepository: MockClassRepository(),
        userId: "test-user",
        assignmentRepository: MockAssignmentRepository()
    )
}
