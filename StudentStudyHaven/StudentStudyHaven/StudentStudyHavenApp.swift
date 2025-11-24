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
    @State private var email = ""
    @State private var password = ""
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            // Background gradient - adapts to dark mode
            LinearGradient(
                colors: colorScheme == .dark ? [
                    Color(red: 0.15, green: 0.05, blue: 0.20),
                    Color(red: 0.20, green: 0.10, blue: 0.25),
                    Color(red: 0.25, green: 0.15, blue: 0.30)
                ] : [
                    Color(red: 0.95, green: 0.85, blue: 0.98),
                    Color(red: 0.90, green: 0.75, blue: 0.95),
                    Color(red: 0.85, green: 0.65, blue: 0.90)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
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
                
                // Login form
                VStack(spacing: 20) {
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
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
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                            )
                            .shadow(color: .purple.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: {
                        print("Login tapped")
                    }) {
                        HStack {
                            Text("Sign In")
                                .font(.headline)
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .purple.opacity(0.5), radius: 10, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    
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
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(colorScheme == .dark ? Color.white.opacity(0.1) : Color.white.opacity(0.4))
                        .shadow(color: colorScheme == .dark ? .black.opacity(0.5) : .purple.opacity(0.2), radius: 20, x: 0, y: 10)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(colorScheme == .dark ? Color.purple.opacity(0.3) : Color.white.opacity(0.5), lineWidth: 1)
                )
                .padding(.horizontal, 40)
                
                Spacer()
            }
        }
        .frame(minWidth: 500, minHeight: 600)
    }
}
