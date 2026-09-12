import Core
import SwiftUI

/// Registration screen view
public struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(viewModel: RegisterViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var horizontalPadding: CGFloat {
        isCompact ? 16 : 40
    }

    private var fieldSpacing: CGFloat {
        isCompact ? 12 : 16
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: isCompact ? 16 : 20) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: isCompact ? 40 : 50))
                        .foregroundColor(.blue)
                    Text("Create Account")
                        .font(isCompact ? .headline : .title2)
                        .fontWeight(.bold)
                }
                .padding(.top, isCompact ? 20 : 40)

                // Registration Form
                VStack(spacing: fieldSpacing) {
                    TextField("Full Name", text: $viewModel.name)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)

                    TextField("Email", text: $viewModel.email)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)

                    SecureField("Password", text: $viewModel.password)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)

                    SecureField("Confirm Password", text: $viewModel.confirmPassword)
                        .textFieldStyle(.roundedBorder)
                        .frame(minHeight: 44)

                    // College Selection Button
                    Button(action: {
                        // Show college selection
                    }) {
                        HStack {
                            Text(
                                viewModel.selectedCollegeId != nil
                                    ? "College Selected" : "Select College (Optional)")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(minHeight: 44)
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
                    .frame(minHeight: 48)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(viewModel.isLoading)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, isCompact ? 12 : 20)

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
