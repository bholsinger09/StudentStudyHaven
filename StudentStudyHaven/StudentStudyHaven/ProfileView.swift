import Authentication
import Core
import SwiftUI

/// Profile view showing user information and account settings
struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ProfileViewModel
    @State private var showingImagePicker = false
    @State private var showingEditSheet = false
    @State private var showingChangePasswordSheet = false
    @State private var showingDeleteAccountAlert = false
    @State private var showingDeleteConfirmation = false
    @State private var deleteConfirmationText = ""

    init(viewModel: ProfileViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        profileHeader

                        // Account Statistics
                        statisticsSection

                        // Account Actions
                        actionsSection

                        // Danger Zone
                        dangerZoneSection
                    }
                    .padding()
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit") {
                        showingEditSheet = true
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                EditProfileView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingChangePasswordSheet) {
                ChangePasswordView(viewModel: viewModel)
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage)
            }
            .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Continue", role: .destructive) {
                    showingDeleteConfirmation = true
                }
            } message: {
                Text("Are you sure you want to delete your account? This action cannot be undone.\n\n• All your data will be permanently deleted\n• Your classes, notes, and flashcards will be removed\n• Any active subscriptions should be cancelled separately in App Store settings")
            }
            .sheet(isPresented: $showingDeleteConfirmation) {
                DeleteAccountConfirmationView(
                    confirmationText: $deleteConfirmationText,
                    userEmail: viewModel.userEmail,
                    onConfirm: {
                        Task {
                            await viewModel.deleteAccount()
                        }
                    },
                    onCancel: {
                        showingDeleteConfirmation = false
                        deleteConfirmationText = ""
                    }
                )
            }
        }
    }

    // MARK: - Profile Header

    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Photo
            ZStack {
                if let photoURL = viewModel.profilePhotoURL {
                    AsyncImage(url: photoURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text(viewModel.userInitials)
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                        }
                }

                // Camera button overlay
                Button {
                    showingImagePicker = true
                } label: {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "camera.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 14))
                        }
                }
                .offset(x: 35, y: 35)
            }

            // User Info
            VStack(spacing: 8) {
                Text(viewModel.userName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text(viewModel.userEmail)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                if let college = viewModel.userCollege {
                    HStack(spacing: 4) {
                        Image(systemName: "building.columns.fill")
                            .font(.caption)
                        Text(college)
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                    .cornerRadius(12)
                }
            }
        }
        .padding(.vertical, 24)
    }

    // MARK: - Statistics Section

    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your Statistics")
                .font(.headline)
                .foregroundColor(.white)

            HStack(spacing: 16) {
                ProfileStatCard(
                    icon: "book.fill",
                    title: "Classes",
                    value: "\(viewModel.classCount)",
                    color: .blue
                )

                ProfileStatCard(
                    icon: "note.text",
                    title: "Notes",
                    value: "\(viewModel.noteCount)",
                    color: .green
                )

                ProfileStatCard(
                    icon: "rectangle.stack.fill",
                    title: "Flashcards",
                    value: "\(viewModel.flashcardCount)",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }

    // MARK: - Actions Section

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Account")
                .font(.headline)
                .foregroundColor(.white)

            VStack(spacing: 0) {
                ActionRow(
                    icon: "person.fill",
                    title: "Edit Profile",
                    color: Color(red: 0.73, green: 0.33, blue: 0.83)
                ) {
                    showingEditSheet = true
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                ActionRow(
                    icon: "lock.fill",
                    title: "Change Password",
                    color: .blue
                ) {
                    showingChangePasswordSheet = true
                }

                Divider()
                    .background(Color.white.opacity(0.1))

                NavigationLink {
                    SettingsView()
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "gear")
                            .foregroundColor(.gray)
                            .frame(width: 24)

                        Text("Settings")
                            .foregroundColor(.white)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding()
                }
            }
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
        }
    }

    // MARK: - Danger Zone

    private var dangerZoneSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Danger Zone")
                .font(.headline)
                .foregroundColor(.red)

            VStack(spacing: 0) {
                Button {
                    Task {
                        await viewModel.logout()
                    }
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text("Log Out")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .padding()
                }

                Divider()
                    .background(Color.red.opacity(0.3))

                Button {
                    showingDeleteAccountAlert = true
                } label: {
                    HStack {
                        Image(systemName: "trash.fill")
                        Text("Delete Account")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .foregroundColor(.red)
                    .padding()
                }
            }
            .background(Color.red.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Profile Stat Card Component

struct ProfileStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Action Row Component

struct ActionRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 24)

                Text(title)
                    .foregroundColor(.white)

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
            .padding()
        }
    }
}

// MARK: - Edit Profile View

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var name: String = ""
    @State private var email: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .foregroundColor(.gray)
                        TextField("Enter your name", text: $name)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .foregroundColor(.gray)
                        TextField("Enter your email", text: $email)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Edit Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.updateProfile(name: name, email: email)
                            dismiss()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .onAppear {
                name = viewModel.userName
                email = viewModel.userEmail
            }
        }
    }
}

// MARK: - Change Password View

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ProfileViewModel
    @State private var currentPassword: String = ""
    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Current Password")
                            .foregroundColor(.gray)
                        SecureField("Enter current password", text: $currentPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("New Password")
                            .foregroundColor(.gray)
                        SecureField("Enter new password", text: $newPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Confirm Password")
                            .foregroundColor(.gray)
                        SecureField("Confirm new password", text: $confirmPassword)
                            .textFieldStyle(.roundedBorder)
                    }
                    .padding(.horizontal)

                    Text("Password must be at least 6 characters")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal)

                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Change Password")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            if newPassword == confirmPassword {
                                await viewModel.changePassword(
                                    current: currentPassword,
                                    new: newPassword
                                )
                                dismiss()
                            }
                        }
                    }
                    .disabled(
                        viewModel.isLoading || newPassword.count < 6
                            || newPassword != confirmPassword)
                }
            }
        }
    }
}

// MARK: - Delete Account Confirmation View

struct DeleteAccountConfirmationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @Binding var confirmationText: String
    let userEmail: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    private var isConfirmationValid: Bool {
        confirmationText.lowercased() == "delete"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Warning Icon
                        HStack {
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(Color.red.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.red)
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        
                        // Warning Title
                        VStack(spacing: 8) {
                            Text("Delete Your Account?")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("This action is permanent and cannot be undone")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        
                        // What will be deleted
                        VStack(alignment: .leading, spacing: 16) {
                            Text("What will be deleted:")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                DeleteWarningRow(
                                    icon: "person.fill.xmark",
                                    text: "Your account and profile information"
                                )
                                DeleteWarningRow(
                                    icon: "book.fill",
                                    text: "All your classes and course data"
                                )
                                DeleteWarningRow(
                                    icon: "note.text",
                                    text: "All your notes and study materials"
                                )
                                DeleteWarningRow(
                                    icon: "rectangle.stack.fill",
                                    text: "All your flashcards and study progress"
                                )
                                DeleteWarningRow(
                                    icon: "chart.bar.fill",
                                    text: "All your statistics and learning data"
                                )
                            }
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        // Billing Information
                        VStack(alignment: .leading, spacing: 12) {
                            HStack(spacing: 8) {
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Important: Billing & Subscriptions")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                            
                            Text("If you have any active subscriptions, please cancel them separately through the App Store before deleting your account. Deleting your account does not automatically cancel subscriptions.")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Button {
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    openURL(url)
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.up.right.square")
                                    Text("Manage Subscriptions in App Store")
                                        .font(.subheadline)
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        // Account Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Account to be deleted:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            Text(userEmail)
                                .font(.body)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Confirmation Input
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Type DELETE to confirm")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("To verify this action, type the word DELETE below:")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            
                            TextField("Type DELETE", text: $confirmationText)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Delete Account")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onCancel()
                    }
                }
                
                ToolbarItem(placement: .destructiveAction) {
                    Button("Delete Account") {
                        onConfirm()
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .disabled(!isConfirmationValid)
                }
            }
        }
    }
}

// MARK: - Delete Warning Row

struct DeleteWarningRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.red)
                .frame(width: 24)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
        }
    }
}
