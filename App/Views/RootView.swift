import Authentication
import ClassManagement
import Core
import Flashcards
import Notes
import SwiftUI

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

    var body: some View {
        NavigationStack {
            ClassManagement.ClassListView(
                viewModel: ClassListViewModel(
                    getClassesUseCase: GetClassesUseCase(classRepository: appState.classRepository),
                    deleteClassUseCase: DeleteClassUseCase(
                        classRepository: appState.classRepository),
                    userId: appState.currentUser?.id ?? UUID()
                ),
                createClassUseCase: CreateClassUseCase(classRepository: appState.classRepository),
                updateClassUseCase: UpdateClassUseCase(classRepository: appState.classRepository),
                userId: appState.currentUser?.id ?? UUID()
            )
        }
    }
}

/// Class list view
struct ClassListView: View {
    let userId: UUID
    @EnvironmentObject var appState: AppState
    @State private var classes: [Class] = []
    @State private var isLoading = false
    @State private var showingAddClass = false

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if classes.isEmpty {
                EmptyClassesView {
                    showingAddClass = true
                }
            } else {
                List {
                    ForEach(classes) { classItem in
                        NavigationLink(destination: ClassDetailView(classItem: classItem)) {
                            ClassRow(classItem: classItem)
                        }
                    }
                    .onDelete { indexSet in
                        deleteClasses(at: indexSet)
                    }
                }
            }
        }
        .navigationTitle("My Classes")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingAddClass = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddClass) {
            AddClassView(
                viewModel: ClassFormViewModel(
                    createClassUseCase: CreateClassUseCase(
                        classRepository: appState.classRepository),
                    updateClassUseCase: UpdateClassUseCase(
                        classRepository: appState.classRepository),
                    userId: userId
                ))
        }
        .task {
            await loadClasses()
        }
    }

    private func loadClasses() async {
        isLoading = true
        do {
            let useCase = GetClassesUseCase(classRepository: appState.classRepository)
            classes = try await useCase.execute(userId: userId)
        } catch {
            print("Error loading classes: \(error)")
        }
        isLoading = false
    }

    private func deleteClasses(at offsets: IndexSet) {
        Task {
            let useCase = DeleteClassUseCase(classRepository: appState.classRepository)
            for index in offsets {
                do {
                    try await useCase.execute(classId: classes[index].id)
                    classes.remove(at: index)
                } catch {
                    print("Error deleting class: \(error)")
                }
            }
        }
    }
}

/// Empty state for classes
struct EmptyClassesView: View {
    let onAddClass: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("No Classes Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Add your first class to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Button(action: onAddClass) {
                Label("Add Class", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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

/// Notes tab
struct NotesTab: View {
    @EnvironmentObject var appState: AppState
    @State private var notes: [Note] = []
    @State private var selectedClass: Class?
    @State private var showingNoteEditor = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(notes) { note in
                    NavigationLink(
                        destination:
                            NoteEditorView(
                                viewModel: NoteEditorViewModel(
                                    note: note,
                                    classId: note.classId,
                                    userId: appState.currentUser?.id ?? UUID()
                                ))
                    ) {
                        NoteRowView(note: note)
                    }
                }
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNoteEditor = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNoteEditor) {
                if let classId = selectedClass?.id ?? appState.currentUser?.collegeId {
                    NoteEditorView(
                        viewModel: NoteEditorViewModel(
                            classId: classId,
                            userId: appState.currentUser?.id ?? UUID()
                        ))
                }
            }
        }
    }
}

/// Note row view
struct NoteRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(note.title)
                .font(.headline)

            Text(note.content.prefix(100))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(2)

            if !note.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(note.tags.prefix(3), id: \.self) { tag in
                        Text("#\(tag)")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

/// Flashcards tab
struct FlashcardsTab: View {
    @EnvironmentObject var appState: AppState
    @State private var flashcards: [Flashcard] = []
    @State private var showingStudyView = false

    var body: some View {
        NavigationStack {
            Group {
                if flashcards.isEmpty {
                    EmptyFlashcardsView()
                } else {
                    List {
                        Section {
                            Button(action: { showingStudyView = true }) {
                                HStack {
                                    Image(systemName: "play.fill")
                                        .font(.title3)
                                    VStack(alignment: .leading) {
                                        Text("Start Studying")
                                            .font(.headline)
                                        Text("\(flashcards.count) cards ready")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                        }

                        Section("All Flashcards") {
                            ForEach(flashcards) { flashcard in
                                FlashcardRowView(flashcard: flashcard)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Flashcards")
            .sheet(isPresented: $showingStudyView) {
                NavigationStack {
                    FlashcardStudyView(flashcards: flashcards)
                }
            }
        }
    }
}

/// Flashcard row view
struct FlashcardRowView: View {
    let flashcard: Flashcard

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(flashcard.front)
                .font(.headline)
            Text(flashcard.back)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(1)
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for flashcards
struct EmptyFlashcardsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "rectangle.stack.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)

            Text("No Flashcards Yet")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Create notes and generate flashcards to start studying")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                    Button(
                        role: .destructive,
                        action: {
                            Task {
                                await appState.logout()
                            }
                        }
                    ) {
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
