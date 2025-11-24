import SwiftUI
import Core
import Notes

/// Notes list view
public struct NotesListView: View {
    @StateObject private var viewModel: NotesListViewModel
    @State private var showingNoteEditor = false
    
    let classId: UUID
    let userId: UUID
    
    public init(viewModel: NotesListViewModel, classId: UUID, userId: UUID) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.classId = classId
        self.userId = userId
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
                List {
                    ForEach(viewModel.filteredNotes) { note in
                        NavigationLink(destination: 
                            NoteEditorView(viewModel: NoteEditorViewModel(
                                note: note,
                                classId: classId,
                                userId: userId
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
                .searchable(text: $viewModel.searchQuery, prompt: "Search notes")
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
            NavigationStack {
                NoteEditorView(viewModel: NoteEditorViewModel(
                    classId: classId,
                    userId: userId
                ))
            }
        }
        .task {
            await viewModel.loadNotes()
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
                
                Spacer()
                
                if !note.linkedNoteIds.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                            .font(.caption)
                        Text("\(note.linkedNoteIds.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Text(note.content.prefix(120))
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if !note.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(note.tags.prefix(5), id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption2)
                                .foregroundColor(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
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
            .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for notes
struct EmptyNotesStateView: View {
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "note.text")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Notes Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Start taking notes for your classes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: onCreate) {
                Label("Create Note", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 200)
                    .background(Color.blue)
                    .cornerRadius(12)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
