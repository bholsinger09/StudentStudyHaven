//
//  StudentStudyHavenApp.swift
//  StudentStudyHaven
//
//  Created by Ben H on 11/24/25.
//

import SwiftUI
import Core
import Authentication
import ClassManagement
import Flashcards
import Notes

@main
struct StudentStudyHavenApp: App {
    // @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            TestLoginView()
        }
    }
}

struct TestLoginView: View {
    @State private var email = "demo@studyhaven.com"
    @State private var password = "Demo2025!"
    @State private var showingMainApp = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            backgroundGradient
            
            VStack(spacing: 30) {
                headerSection
                loginFormSection
                Spacer()
            }
        }
        .frame(minWidth: 500, minHeight: 600)
        .sheet(isPresented: $showingMainApp) {
            DemoMainView()
        }
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: colorScheme == .dark ? darkColors : lightColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
    
    private var darkColors: [Color] {
        [
            Color(red: 0.15, green: 0.05, blue: 0.20),
            Color(red: 0.20, green: 0.10, blue: 0.25),
            Color(red: 0.25, green: 0.15, blue: 0.30)
        ]
    }
    
    private var lightColors: [Color] {
        [
            Color(red: 0.95, green: 0.85, blue: 0.98),
            Color(red: 0.90, green: 0.75, blue: 0.95),
            Color(red: 0.85, green: 0.65, blue: 0.90)
        ]
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "book.circle.fill")
                .font(.system(size: 70))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.purple, .pink],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Student Study Haven")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(colorScheme == .dark ? .white : .purple)
            
            Text("Your academic companion")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .purple.opacity(0.7))
        }
        .padding(.top, 40)
    }
    
    private var loginFormSection: some View {
        VStack(spacing: 20) {
            emailField
            passwordField
            signInButton
            signUpLink
            demoCredentials
        }
        .padding(30)
        .background(formBackground)
        .overlay(formBorder)
        .padding(.horizontal, 40)
    }
    
    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Email", systemImage: "envelope.fill")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .pink : .purple)
                .fontWeight(.medium)
            
            TextField("student@university.edu", text: $email)
                .textFieldStyle(.plain)
                .padding()
                .background(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white.opacity(0.95))
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Password", systemImage: "lock.fill")
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .pink : .purple)
                .fontWeight(.medium)
            
            SecureField("Enter your password", text: $password)
                .textFieldStyle(.plain)
                .padding()
                .background(colorScheme == .dark ? Color.white.opacity(0.15) : Color.white.opacity(0.95))
                .foregroundColor(colorScheme == .dark ? .white : .primary)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.purple.opacity(0.3), lineWidth: 1))
                .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
    
    private var signInButton: some View {
        Button(action: { showingMainApp = true }) {
            HStack {
                Text("Sign In")
                    .font(.headline)
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(LinearGradient(colors: [.purple, .pink], startPoint: .leading, endPoint: .trailing))
            .cornerRadius(12)
            .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.top, 10)
    }
    
    private var signUpLink: some View {
        HStack {
            Text("Don't have an account?")
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .purple.opacity(0.7))
            Button("Sign Up") {
                print("Sign up tapped")
            }
            .foregroundColor(colorScheme == .dark ? .pink : .purple)
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
    
    private var demoCredentials: some View {
        VStack(spacing: 4) {
            Text("Demo Account")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(colorScheme == .dark ? .pink.opacity(0.8) : .purple.opacity(0.8))
            Text("email: demo@studyhaven.com")
                .font(.caption2)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .purple.opacity(0.6))
            Text("password: Demo2025!")
                .font(.caption2)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.6) : .purple.opacity(0.6))
        }
        .padding(.top, 8)
    }
    
    private var formBackground: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.4))
            .shadow(
                color: colorScheme == .dark ? .black.opacity(0.5) : .purple.opacity(0.2),
                radius: 20,
                x: 0,
                y: 10
            )
    }
    
    private var formBorder: some View {
        RoundedRectangle(cornerRadius: 20)
            .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
    }
}

// Demo main app view to show after login
struct DemoMainView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        TabView {
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Classes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Your class schedule and management")
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button("Logout") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .navigationTitle("My Classes")
            }
            .tabItem {
                Label("Classes", systemImage: "book.fill")
            }
            
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "note.text")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Notes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Your study notes and resources")
                        .foregroundColor(.secondary)
                }
                .padding()
                .navigationTitle("Notes")
            }
            .tabItem {
                Label("Notes", systemImage: "note.text")
            }
            
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "rectangle.stack.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Flashcards")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    Text("Study with interactive flashcards")
                        .foregroundColor(.secondary)
                }
                .padding()
                .navigationTitle("Flashcards")
            }
            .tabItem {
                Label("Flashcards", systemImage: "rectangle.stack.fill")
            }
            
            NavigationStack {
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(
                            LinearGradient(colors: [.purple, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    VStack(spacing: 8) {
                        Text("Demo User")
                            .font(.headline)
                        Text("demo@studyhaven.com")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button("Logout") {
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .navigationTitle("Profile")
            }
            .tabItem {
                Label("Profile", systemImage: "person.fill")
            }
        }
        .frame(minWidth: 700, minHeight: 500)
    }
}
