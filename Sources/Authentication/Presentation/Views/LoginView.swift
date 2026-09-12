import Core
import SwiftUI

/// Login screen view
public struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel
    @State private var isPasswordVisible = false
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    public init(viewModel: LoginViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var contentSpacing: CGFloat {
        isCompact ? 16 : 24
    }

    private var horizontalPadding: CGFloat {
        isCompact ? 16 : 40
    }

    private var cardPadding: CGFloat {
        isCompact ? 20 : 32
    }

    private var cornerRadius: CGFloat {
        isCompact ? 16 : 20
    }

    private var logoSize: CGFloat {
        isCompact ? 50 : 70
    }

    private var titleFontSize: CGFloat {
        isCompact ? 22 : 28
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                // Black background
                Color.black
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: contentSpacing) {
                        Spacer()
                            .frame(minHeight: isCompact ? 20 : 40)

                        // App Logo/Title with softer styling
                        VStack(spacing: 12) {
                            Image(systemName: "book.fill")
                                .font(.system(size: logoSize))
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            Text("StudentStudyHaven")
                                .font(.system(size: titleFontSize, weight: .semibold, design: .rounded))
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                        }

                        Spacer()
                            .frame(minHeight: isCompact ? 16 : 32)

                        // Login Form with card styling
                        VStack(spacing: contentSpacing) {
                            // Email field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                TextField("Enter your email", text: $viewModel.email)
                                    .textFieldStyle(.plain)
                                    .fontWeight(.bold)
                                    .foregroundColor(.black)
                                    .padding()
                                    .frame(minHeight: 44)
                                    .background(Color.white.opacity(0.9))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.3),
                                                lineWidth: 1)
                                    )
                            }

                            // Password field
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                HStack {
                                    if isPasswordVisible {
                                        TextField("Enter your password", text: $viewModel.password)
                                            .textFieldStyle(.plain)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .textContentType(.password)
                                    } else {
                                        SecureField("Enter your password", text: $viewModel.password)
                                            .textFieldStyle(.plain)
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                            .textContentType(.password)
                                    }
                                    Button(action: {
                                        isPasswordVisible.toggle()
                                    }) {
                                        Image(
                                            systemName: isPasswordVisible
                                                ? "eye.slash.fill" : "eye.fill"
                                        )
                                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding()
                                .frame(minHeight: 44)
                                .background(Color.white.opacity(0.9))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(
                                            Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.3),
                                            lineWidth: 1)
                                )
                            }

                            if let errorMessage = viewModel.errorMessage {
                                Text(errorMessage)
                                    .foregroundColor(.red.opacity(0.8))
                                    .font(.caption)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 4)
                            }

                            // Forgot Password Link
                            HStack {
                                Spacer()
                                NavigationLink("Forgot Password?") {
                                    ForgotPasswordView(authRepository: viewModel.authRepository)
                                }
                                .font(.caption)
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            }

                            // Login button with dark blue background
                            Button(action: {
                                Task {
                                    await viewModel.login()
                                }
                            }) {
                                HStack {
                                    Spacer()
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .progressViewStyle(.circular)
                                            .tint(Color(red: 0.9, green: 0.4, blue: 0.5))
                                    } else {
                                        Text("Login")
                                            .fontWeight(.semibold)
                                            .font(.headline)
                                            .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                                    }
                                    Spacer()
                                }
                                .padding()
                                .frame(minHeight: 48)
                                .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                                .cornerRadius(12)
                                .shadow(
                                    color: Color(red: 0.0, green: 0.2, blue: 0.4).opacity(0.3),
                                    radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isLoading)
                            .padding(.top, 8)

                            #if canImport(UIKit)
                            // Sign in with Apple button
                            Button(action: {
                                Task {
                                    await viewModel.signInWithApple()
                                }
                            }) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: isCompact ? 14 : 16, weight: .bold))
                                    Text("Sign in with Apple")
                                        .fontWeight(.semibold)
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .frame(minHeight: 48)
                                .background(Color.black)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .shadow(
                                    color: Color.black.opacity(0.3),
                                    radius: 8, x: 0, y: 4)
                            }
                            .buttonStyle(.plain)
                            .disabled(viewModel.isLoading)
                            .padding(.top, 12)
                            #endif
                        }
                        .padding(.horizontal, horizontalPadding)
                        .padding(.vertical, cardPadding)
                        .background(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .fill(Color.white.opacity(0.7))
                                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                        )
                        .padding(.horizontal, isCompact ? 12 : 32)

                        Spacer()
                            .frame(minHeight: isCompact ? 16 : 32)

                        // Register Link with prettier styling
                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            NavigationLink("Sign Up") {
                                // RegisterView will be injected here
                                Text("Register View")
                            }
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                        }
                        .padding(.bottom, isCompact ? 20 : 40)
                    }
                }
            }
        }
    }
}
