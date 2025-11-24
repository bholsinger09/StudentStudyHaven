import SwiftUI
import Core

/// Registration screen view
public struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    Text("Create Account")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 40)
                
                // Registration Form
                VStack(spacing: 16) {
                    TextField("Full Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                    
                    // College Selection Button
                    Button(action: {
                        // Show college selection
                    }) {
                        HStack {
                            Text(viewModel.selectedCollegeId != nil ? "College Selected" : "Select College (Optional)")
                            Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.register()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Register")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, 32)
                .padding(.top, 20)
                
                Spacer()
            }
        }
        .navigationTitle("Register")
        .onChange(of: viewModel.isRegistered) { isRegistered in
            if isRegistered {
                dismiss()
            }
        }
    }
}
