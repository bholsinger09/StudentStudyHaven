import Core
import SwiftUI

/// Settings view
public struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("studyReminders") private var studyReminders = true
    @AppStorage("classReminders") private var classReminders = true
    @AppStorage("themeMode") private var themeMode = "auto"
    @State private var showingLogoutConfirmation = false
    @State private var showingDeleteAccountConfirmation = false
    @State private var showingAbout = false
    @Environment(\.dismiss) private var dismiss

    public init() {}

    public var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Notifications Section
                        settingsSection(title: "Notifications", icon: "bell.fill") {
                            VStack(spacing: 0) {
                                SettingsToggleRow(
                                    title: "Enable Notifications",
                                    icon: "bell.fill",
                                    isOn: $notificationsEnabled
                                )

                                Divider().background(Color.white.opacity(0.1))

                                SettingsToggleRow(
                                    title: "Study Reminders",
                                    icon: "clock.fill",
                                    isOn: $studyReminders
                                )
                                .disabled(!notificationsEnabled)
                                .opacity(notificationsEnabled ? 1 : 0.5)

                                Divider().background(Color.white.opacity(0.1))

                                SettingsToggleRow(
                                    title: "Class Reminders",
                                    icon: "calendar.badge.clock",
                                    isOn: $classReminders
                                )
                                .disabled(!notificationsEnabled)
                                .opacity(notificationsEnabled ? 1 : 0.5)
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Appearance Section
                        settingsSection(title: "Appearance", icon: "paintbrush.fill") {
                            VStack(spacing: 0) {
                                SettingsPickerRow(
                                    title: "Theme",
                                    icon: "circle.lefthalf.filled",
                                    selection: $themeMode,
                                    options: [
                                        ("auto", "Auto"),
                                        ("light", "Light"),
                                        ("dark", "Dark"),
                                    ]
                                )
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Data Management Section
                        settingsSection(title: "Data", icon: "internaldrive.fill") {
                            VStack(spacing: 0) {
                                SettingsActionRow(
                                    title: "Export Data",
                                    icon: "square.and.arrow.up",
                                    color: .blue
                                ) {
                                    // TODO: Implement export
                                }

                                Divider().background(Color.white.opacity(0.1))

                                SettingsActionRow(
                                    title: "Clear Cache",
                                    icon: "trash",
                                    color: .orange
                                ) {
                                    // TODO: Implement cache clearing
                                }
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // About Section
                        settingsSection(title: "About", icon: "info.circle.fill") {
                            VStack(spacing: 0) {
                                SettingsNavigationRow(
                                    title: "Privacy Policy",
                                    icon: "hand.raised.fill"
                                ) {
                                    // TODO: Open privacy policy
                                }

                                Divider().background(Color.white.opacity(0.1))

                                SettingsNavigationRow(
                                    title: "Terms of Service",
                                    icon: "doc.text.fill"
                                ) {
                                    // TODO: Open terms
                                }

                                Divider().background(Color.white.opacity(0.1))

                                SettingsInfoRow(
                                    title: "Version",
                                    value: "1.0.0"
                                )
                            }
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }

                        // Danger Zone
                        settingsSection(title: "Account", icon: "person.fill") {
                            VStack(spacing: 0) {
                                SettingsActionRow(
                                    title: "Delete Account",
                                    icon: "trash.fill",
                                    color: .red
                                ) {
                                    showingDeleteAccountConfirmation = true
                                }
                            }
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }
            .confirmationDialog(
                "Delete Account",
                isPresented: $showingDeleteAccountConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Account", role: .destructive) {
                    // TODO: Implement account deletion
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(
                    "This will permanently delete your account and all associated data. This action cannot be undone."
                )
            }
        }
    }

    private func settingsSection<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 4)

            content()
        }
    }
}

// MARK: - Settings Row Components

struct SettingsToggleRow: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                .frame(width: 24)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.73, green: 0.33, blue: 0.83))
        }
        .padding()
    }
}

struct SettingsPickerRow: View {
    let title: String
    let icon: String
    @Binding var selection: String
    let options: [(String, String)]

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                .frame(width: 24)

            Text(title)
                .foregroundColor(.white)

            Spacer()

            Picker("", selection: $selection) {
                ForEach(options, id: \.0) { value, label in
                    Text(label).tag(value)
                }
            }
            .pickerStyle(.menu)
            .tint(Color(red: 0.73, green: 0.33, blue: 0.83))
        }
        .padding()
    }
}

struct SettingsActionRow: View {
    let title: String
    let icon: String
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

struct SettingsNavigationRow: View {
    let title: String
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
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

struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Text(title)
                .foregroundColor(.white)

            Spacer()

            Text(value)
                .foregroundColor(.gray)
        }
        .padding()
    }
}
