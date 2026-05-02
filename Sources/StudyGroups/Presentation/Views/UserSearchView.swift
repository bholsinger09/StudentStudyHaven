import Core
import SwiftUI

/// View for searching and inviting users to a study group
public struct UserSearchView: View {
    @StateObject private var viewModel: UserSearchViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: UserSearchViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Form
                Form {
                    Section {
                        TextField("First Name", text: $viewModel.firstName)
                            #if os(iOS)
                            .textContentType(.givenName)
                            .autocapitalization(.words)
                            #endif
                        
                        TextField("Email", text: $viewModel.email)
                            #if os(iOS)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            #endif
                    } header: {
                        Text("User Information")
                    } footer: {
                        Text("Enter the first name and email of the person you want to add to the group")
                    }
                    
                    Section {
                        Button(action: {
                            Task {
                                await viewModel.searchUsers()
                            }
                        }) {
                            if viewModel.isSearching {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                    Text("Searching...")
                                }
                            } else {
                                Text("Search")
                            }
                        }
                        .disabled(viewModel.firstName.isEmpty || viewModel.email.isEmpty || viewModel.isSearching)
                    }
                }
                
                // Search Results
                if !viewModel.searchResults.isEmpty {
                    List {
                        Section("Search Results") {
                            ForEach(viewModel.searchResults) { user in
                                UserResultRow(
                                    user: user,
                                    isInviting: viewModel.isInviting,
                                    onInvite: {
                                        Task {
                                            await viewModel.inviteUser(user)
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Add Member")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK", role: .cancel) {
                    dismiss()
                }
            } message: {
                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                }
            }
        }
    }
}

/// Row view for search result
struct UserResultRow: View {
    let user: User
    let isInviting: Bool
    let onInvite: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(.headline)
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: onInvite) {
                if isInviting {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Label("Add", systemImage: "plus.circle.fill")
                        .labelStyle(.iconOnly)
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .disabled(isInviting)
        }
        .padding(.vertical, 4)
    }
}
