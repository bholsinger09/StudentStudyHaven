import Core
import SwiftUI

/// Create Study Group View
public struct CreateStudyGroupView: View {
    @StateObject private var viewModel: CreateStudyGroupViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var availableClasses: [Class] = []
    
    let onDismiss: () -> Void
    
    public init(viewModel: CreateStudyGroupViewModel, onDismiss: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        Form {
            Section("Group Details") {
                TextField("Group Name", text: $viewModel.name)
                    .autocorrectionDisabled()
                
                TextField("Description (Optional)", text: $viewModel.description, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section("Settings") {
                // Note: In production, this would fetch actual classes
                TextField("Class ID", text: $viewModel.selectedClassId)
                    .autocorrectionDisabled()
                
                HStack {
                    Text("Max Members")
                    TextField("Unlimited", text: $viewModel.maxMembers)
                    #if os(iOS)
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                    #endif
                }
                
                Toggle("Public Group", isOn: $viewModel.isPublic)
            }
            
            Section {
                Text("Public groups can be discovered by other students in your college. Private groups require an invite.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("Create Study Group")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button("Create") {
                    Task {
                        if await viewModel.createGroup() {
                            onDismiss()
                        }
                    }
                }
                .disabled(!viewModel.isValid || viewModel.isLoading)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let error = viewModel.errorMessage {
                Text(error)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
    }
}
