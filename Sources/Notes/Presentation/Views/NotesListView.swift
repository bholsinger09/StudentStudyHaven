import Core
import SwiftUI

/// Notes list view
public struct NotesListView: View {
    @StateObject private var viewModel: NotesListViewModel
    @State private var showingNoteEditor = false

    let classId: String
    let userId: String
    let createNoteUseCase: CreateNoteUseCase
    let updateNoteUseCase: UpdateNoteUseCase

    public init(
        viewModel: NotesListViewModel,
        classId: String,
        userId: String,
        createNoteUseCase: CreateNoteUseCase,
        updateNoteUseCase: UpdateNoteUseCase
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.classId = classId
        self.userId = userId
        self.createNoteUseCase = createNoteUseCase
        self.updateNoteUseCase = updateNoteUseCase
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.filteredNotes.isEmpty {
                if viewModel.searchQuery.isEmpty {
                    EmptyNotesStateView {
                        showingNoteEditor = true
                    }
                } else {
                    SearchEmptyView(query: viewModel.searchQuery)
                }
            } else {
                VStack(spacing: 0) {
                    // Add button at top
                    Button(action: { showingNoteEditor = true }) {
                        Text("Add A Note For Class")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 12)
                            .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                            .cornerRadius(10)
                    }
                    .buttonStyle(.plain)
                    .padding()

                    List {
                        ForEach(viewModel.filteredNotes) { note in
                            NavigationLink(
                                destination:
                                    NoteEditorView(
                                        viewModel: NoteEditorViewModel(
                                            note: note,
                                            classId: classId,
                                            userId: userId,
                                            createNoteUseCase: createNoteUseCase,
                                            updateNoteUseCase: updateNoteUseCase
                                        ))
                            ) {
                                NoteListRowView(note: note)
                            }
                        }
                        .onDelete { indexSet in
                            Task {
                                await viewModel.deleteNote(at: indexSet)
                            }
                        }
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.black)
                    .searchable(text: $viewModel.searchQuery, prompt: "Search docs")
                }
            }
        }
        .navigationTitle("Classroom Notetaking")
        .sheet(isPresented: $showingNoteEditor) {
            NoteEditorView(
                viewModel: NoteEditorViewModel(
                    classId: classId,
                    userId: userId,
                    createNoteUseCase: createNoteUseCase,
                    updateNoteUseCase: updateNoteUseCase
                )
            )
            .frame(width: 600, height: 550)
        }
        .task {
            await viewModel.loadNotes()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("NoteDidSave"))) {
            _ in
            Task {
                await viewModel.loadNotes()
            }
        }
    }
}

/// Note row in list
struct NoteListRowView: View {
    let note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if !note.linkedNoteIds.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text("\(note.linkedNoteIds.count)")
                            .font(.caption)
                    }
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                }
            }

            Text(note.content.prefix(120))
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(note.tags.prefix(5), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }

            HStack {
                Image(systemName: "calendar")
                    .font(.caption2)
                Text(note.updatedAt, style: .date)
                    .font(.caption2)
            }
            .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for notes
struct EmptyNotesStateView: View {
    let onCreate: () -> Void

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            VStack {
                Spacer()

                Button(action: onCreate) {
                    Text("Add A Note For Class")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .cornerRadius(15)
                        .shadow(
                            color: Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.5),
                            radius: 10, x: 0, y: 5)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

/// Empty search results view
struct SearchEmptyView: View {
    let query: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.secondary)

            Text("No Results")
                .font(.headline)

            Text("No notes found for '\(query)'")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
