import Core
import SwiftUI

/// Registration screen view
public struct RegisterView: View {
    @StateObject private var viewModel: RegisterViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var backAction: (() -> Void)?

    public init(viewModel: RegisterViewModel, backAction: (() -> Void)? = nil) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.backAction = backAction
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
                // Back button
                HStack {
                    if let backAction = backAction {
                        Button(action: backAction) {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                Text("Back")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.blue)
                        }
                        .buttonStyle(.plain)
                    }
                    Spacer()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, isCompact ? 12 : 16)

                // Header
                VStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                        .font(.system(size: isCompact ? 40 : 50))
                        .foregroundColor(.blue)
                    Text("Create Account")
                        .font(isCompact ? .headline : .title2)
                        .fontWeight(.bold)
                }
                .padding(.top, isCompact ? 8 : 12)

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
