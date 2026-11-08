import Core
import SwiftUI

/// View for editing study group details
public struct EditStudyGroupView: View {
    let groupId: String
    let currentUserId: String
    let initialGroup: StudyGroup
    let updateStudyGroupUseCase: UpdateStudyGroupUseCase
    let onSaveComplete: (() -> Void)?
    
    @State private var groupName: String
    @State private var description: String
    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    public init(
        groupId: String,
        currentUserId: String,
        initialGroup: StudyGroup,
        updateStudyGroupUseCase: UpdateStudyGroupUseCase,
        onSaveComplete: (() -> Void)? = nil
    ) {
        self.groupId = groupId
        self.currentUserId = currentUserId
        self.initialGroup = initialGroup
        self.updateStudyGroupUseCase = updateStudyGroupUseCase
        self.onSaveComplete = onSaveComplete
        
        _groupName = State(initialValue: initialGroup.name)
        _description = State(initialValue: initialGroup.description ?? "")
    }
    
    private var hasChanges: Bool {
        groupName.trimmingCharacters(in: .whitespaces) != initialGroup.name ||
        description.trimmingCharacters(in: .whitespaces) != (initialGroup.description ?? "")
    }
    
    private var isFormValid: Bool {
        !groupName.trimmingCharacters(in: .whitespaces).isEmpty && hasChanges
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Group Name") {
                    TextField("Enter group name", text: $groupName)
                        .disabled(isLoading)
                }
                
                Section("Description") {
                    TextEditor(text: $description)
                        .frame(minHeight: 100)
                        .disabled(isLoading)
                }
                
                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
            }
            .navigationTitle("Edit Group")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isLoading)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    if isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            saveChanges()
                        }
                        .disabled(!isFormValid)
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        print("📝 EditStudyGroupView: Saving changes...")
        print("   Name: '\(groupName)' (changed: \(groupName.trimmingCharacters(in: .whitespaces) != initialGroup.name))")
        print("   Description: '\(description)' (changed: \(description.trimmingCharacters(in: .whitespaces) != (initialGroup.description ?? "")))")
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let newName = groupName.trimmingCharacters(in: .whitespaces) != initialGroup.name ?
                    groupName.trimmingCharacters(in: .whitespaces) : nil
                let newDescription = description.trimmingCharacters(in: .whitespaces) != (initialGroup.description ?? "") ?
                    description.trimmingCharacters(in: .whitespaces) : nil
                
                print("✏️ UpdateStudyGroupUseCase: Executing with name=\(newName != nil), description=\(newDescription != nil)")
                try await updateStudyGroupUseCase.execute(
                    groupId: groupId,
                    userId: currentUserId,
                    name: newName,
                    description: newDescription
                )
                
                print("✅ EditStudyGroupView: Update successful!")
                
                // Call completion callback to trigger refresh
                onSaveComplete?()
                
                await MainActor.run {
                    dismiss()
                }
            } catch let error as AppError {
                print("❌ EditStudyGroupView: Update failed - \(error.localizedDescription)")
                errorMessage = error.localizedDescription
                isLoading = false
            } catch {
                print("❌ EditStudyGroupView: Update failed - \(error)")
                errorMessage = "Failed to update group"
                isLoading = false
            }
        }
    }
}
