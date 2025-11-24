import SwiftUI
import Authentication
import ClassManagement

/// Root view that handles authentication state
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        if appState.isAuthenticated {
            MainTabView()
        } else {
            AuthenticationCoordinator()
        }
    }
}

/// Authentication coordinator
struct AuthenticationCoordinator: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        LoginView(
            viewModel: LoginViewModel(
                loginUseCase: LoginUseCase(
                    authRepository: appState.authRepository
                )
            )
        )
        .onReceive(NotificationCenter.default.publisher(for: .userDidLogin)) { notification in
            if let user = notification.object as? User {
                appState.login(user: user)
            }
        }
    }
}

/// Main tab view after authentication
struct MainTabView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TabView {
            ClassesTab()
                .tabItem {
                    Label("Classes", systemImage: "book.fill")
                }
            
            NotesTab()
                .tabItem {
                    Label("Notes", systemImage: "note.text")
                }
            
            FlashcardsTab()
                .tabItem {
                    Label("Flashcards", systemImage: "rectangle.stack.fill")
                }
            
            ProfileTab()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

/// Classes tab
struct ClassesTab: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var viewModel: ClassListViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: ClassListViewModel(
            getClassesUseCase: GetClassesUseCase(classRepository: MockClassRepositoryImpl()),
            deleteClassUseCase: DeleteClassUseCase(classRepository: MockClassRepositoryImpl()),
            userId: UUID() // Will be replaced with actual user ID
        ))
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.classes) { classItem in
                    ClassRow(classItem: classItem)
                }
                .onDelete { indexSet in
                    Task {
                        await viewModel.deleteClass(at: indexSet)
                    }
                }
            }
            .navigationTitle("My Classes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        // Add class
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .task {
                await viewModel.loadClasses()
            }
        }
    }
}

struct ClassRow: View {
    let classItem: Class
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(classItem.name)
                .font(.headline)
            Text(classItem.courseCode)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Notes tab placeholder
struct NotesTab: View {
    var body: some View {
        NavigationStack {
            Text("Notes")
                .navigationTitle("Notes")
        }
    }
}

/// Flashcards tab placeholder
struct FlashcardsTab: View {
    var body: some View {
        NavigationStack {
            Text("Flashcards")
                .navigationTitle("Flashcards")
        }
    }
}

/// Profile tab
struct ProfileTab: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationStack {
            List {
                if let user = appState.currentUser {
                    Section("Account") {
                        HStack {
                            Text("Name")
                            Spacer()
                            Text(user.name)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Email")
                            Spacer()
                            Text(user.email)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        Task {
                            await appState.logout()
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Logout")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// Notification names
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
}
