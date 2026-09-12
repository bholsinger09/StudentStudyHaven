import Core
import SwiftUI

/// Initial authentication landing page with three main options
public struct AuthenticationLandingView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Binding var authStep: AuthStep

    public init(authStep: Binding<AuthStep>) {
        self._authStep = authStep
    }

    private var isCompact: Bool {
        horizontalSizeClass == .compact
    }

    private var logoSize: CGFloat {
        isCompact ? 60 : 80
    }

    private var titleFontSize: CGFloat {
        isCompact ? 28 : 36
    }

    private var subtitleFontSize: CGFloat {
        isCompact ? 14 : 16
    }

    public var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: isCompact ? 20 : 32) {
                    Spacer()
                        .frame(minHeight: isCompact ? 30 : 60)

                    // Logo and branding
                    VStack(spacing: 16) {
                        Image(systemName: "book.fill")
                            .font(.system(size: logoSize))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("StudentStudyHaven")
                            .font(.system(size: titleFontSize, weight: .bold, design: .rounded))
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                        Text("Your study companion")
                            .font(.system(size: subtitleFontSize))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, isCompact ? 12 : 24)

                    Spacer()
                        .frame(minHeight: isCompact ? 24 : 40)

                    // Three main options
                    VStack(spacing: isCompact ? 14 : 18) {
                        // Option 1: Create Account
                        Button(action: { authStep = .register }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person.badge.plus.fill")
                                        .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: isCompact ? 40 : 50, alignment: .center)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Create Account")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        Text("Sign up with email")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                }
                                .padding()
                                .frame(minHeight: isCompact ? 56 : 66)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            Color(red: 0.73, green: 0.33, blue: 0.83),
                                            lineWidth: 2)
                                )
                            }
                        }
                        .buttonStyle(.plain)

                        // Option 2: Sign In
                        Button(action: { authStep = .login }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: isCompact ? 40 : 50, alignment: .center)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        Text("Use your email and password")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                }
                                .padding()
                                .frame(minHeight: isCompact ? 56 : 66)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            Color(red: 0.73, green: 0.33, blue: 0.83),
                                            lineWidth: 2)
                                )
                            }
                        }
                        .buttonStyle(.plain)

                        // Option 3: Sign In with Apple
                        #if canImport(UIKit)
                        Button(action: { authStep = .appleSignIn }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "apple.logo")
                                        .font(.system(size: isCompact ? 20 : 24, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: isCompact ? 40 : 50, alignment: .center)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Sign in with Apple")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)

                                        Text("Fast and secure")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.system(size: isCompact ? 14 : 16, weight: .semibold))
                                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                }
                                .padding()
                                .frame(minHeight: isCompact ? 56 : 66)
                                .background(
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(Color.black)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 14)
                                                .stroke(
                                                    Color(red: 0.73, green: 0.33, blue: 0.83),
                                                    lineWidth: 2)
                                        )
                                )
                            }
                        }
                        .buttonStyle(.plain)
                        #endif
                    }
                    .padding(.horizontal, isCompact ? 16 : 24)

                    Spacer()
                        .frame(minHeight: isCompact ? 24 : 40)

                    // Privacy notice
                    VStack(spacing: 8) {
                        Text("We respect your privacy")
                            .font(.caption)
                            .foregroundColor(.gray)

                        HStack(spacing: 4) {
                            Link("Terms", destination: URL(string: "https://example.com/terms") ?? URL(fileURLWithPath: ""))
                                .font(.caption2)
                                .foregroundColor(.gray)

                            Text("•")
                                .foregroundColor(.gray)

                            Link("Privacy", destination: URL(string: "https://example.com/privacy") ?? URL(fileURLWithPath: ""))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, isCompact ? 20 : 32)
                }
            }
        }
    }
}

#Preview {
    // Note: Preview requires AuthStep to be defined in RootView
    Text("Preview not available")
}
