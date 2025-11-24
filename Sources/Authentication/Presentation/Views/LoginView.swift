import SwiftUI
import Core

/// Login screen view
public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    
    public init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // App Logo/Title
                VStack(spacing: 8) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    Text("StudentStudyHaven")
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 60)
                
                Spacer()
                
                // Login Form
                VStack(spacing: 16) {
                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                    
                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.password)
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Task {
                            await viewModel.login()
                        }
                    }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                                .tint(.white)
                        } else {
                            Text("Login")
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
                
                Spacer()
                
                // Register Link
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.secondary)
                    NavigationLink("Sign Up") {
                        // RegisterView will be injected here
                        Text("Register View")
                    }
                    .fontWeight(.semibold)
                }
                .padding(.bottom, 32)
            }
        }
    }
}
