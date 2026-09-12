import Core
import SwiftUI

/// View for resetting forgotten password
public struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel: ForgotPasswordViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(authRepository: AuthRepositoryProtocol) {
        _viewModel = StateObject(
            wrappedValue: ForgotPasswordViewModel(authRepository: authRepository))
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompact ? 16 : 40
    }

    private var iconSize: CGFloat {
        isCompact ? 45 : 60
    }

    private var titleFontSize: CGFloat {
        isCompact ? 18 : 22
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: isCompact ? 16 : 24) {
                        // Header
                        VStack(spacing: 12) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: iconSize))
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                            Text("Reset Password")
                                .font(.system(size: titleFontSize, weight: .bold))
                                .foregroundColor(.white)

                            Text(
                                "Enter your email address and we'll send you instructions to reset your password"
                            )
                            .font(.caption)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, isCompact ? 12 : 16)
                        }
                        .padding(.top, isCompact ? 20 : 40)

                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.subheadline)
                                .foregroundColor(.gray)

                            TextField("Enter your email", text: $viewModel.email)
                                .textFieldStyle(.roundedBorder)
                                .frame(minHeight: 44)
                                .disabled(viewModel.isLoading)
                        }
                        .padding(.horizontal, horizontalPadding)

                        // Send Button
                        Button {
                            Task {
                                await viewModel.sendResetEmail()
                            }
                        } label: {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .progressViewStyle(.circular)
                                        .tint(.white)
                                } else {
                                    Text("Send Reset Link")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .frame(minHeight: 48)
                            .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty)
                        .padding(.horizontal, horizontalPadding)

                        Spacer()
                            .frame(minHeight: isCompact ? 24 : 40)
                    }
                }
            }
            .navigationTitle("Forgot Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .alert("Success", isPresented: $viewModel.showSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Password reset instructions have been sent to \(viewModel.email)")
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}

// MARK: - View Model

@MainActor
class ForgotPasswordViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var isLoading = false
    @Published var showError = false
    @Published var showSuccess = false
    @Published var errorMessage = ""

    private let resetPasswordUseCase: ResetPasswordUseCase

    init(authRepository: AuthRepositoryProtocol) {
        self.resetPasswordUseCase = ResetPasswordUseCase(authRepository: authRepository)
    }

    func sendResetEmail() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await resetPasswordUseCase.execute(email: email)
            showSuccess = true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            showError = true
        } catch {
            errorMessage = "Failed to send reset email. Please try again."
            showError = true
        }
    }

    func clearError() {
        showError = false
        errorMessage = ""
    }
}
