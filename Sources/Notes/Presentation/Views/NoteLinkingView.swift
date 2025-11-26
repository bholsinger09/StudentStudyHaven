import Core
import SwiftUI

/// View for linking notes together
public struct NoteLinkingView: View {
    let currentNoteId: String
    let linkedNoteIds: [String]
    let onLink: (String) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var availableNotes: [Note] = []
    @State private var selectedNotes: Set<String> = []

    public init(currentNoteId: String, linkedNoteIds: [String], onLink: @escaping (String) -> Void)
    {
        self.currentNoteId = currentNoteId
        self.linkedNoteIds = linkedNoteIds
        self.onLink = onLink
        _selectedNotes = State(initialValue: Set(linkedNoteIds))
    }

    private var filteredNotes: [Note] {
        if searchText.isEmpty {
            return availableNotes
        }
        return availableNotes.filter {
            $0.title.localizedCaseInsensitiveContains(searchText)
                || $0.content.localizedCaseInsensitiveContains(searchText)
                || $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)

                    TextField("Search notes...", text: $searchText)
                        .textFieldStyle(.plain)

                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding()  // Linked Notes Count
                if !selectedNotes.isEmpty {
                    HStack {
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                        Text("\(selectedNotes.count) notes linked")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                Divider()

                // Notes List
                if filteredNotes.isEmpty {
                    EmptyStateView(
                        icon: "note.text",
                        title: "No Notes Found",
                        message: searchText.isEmpty
                            ? "Create some notes to link them together"
                            : "No notes match your search"
                    )
                } else {
                    List(filteredNotes) { note in
                        NoteLinkRow(
                            note: note,
                            isLinked: selectedNotes.contains(note.id)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            toggleNoteSelection(note.id)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Link Notes")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveLinks()
                        dismiss()
                    }
                }
            }
        }
    }

    private func toggleNoteSelection(_ noteId: String) {
        if selectedNotes.contains(noteId) {
            selectedNotes.remove(noteId)
        } else {
            selectedNotes.insert(noteId)
        }
    }

    private func saveLinks() {
        for noteId in selectedNotes {
            if !linkedNoteIds.contains(noteId) {
                onLink(noteId)
            }
        }
    }
}

/// Row for note linking
struct NoteLinkRow: View {
    let note: Note
    let isLinked: Bool

    var body: some View {
        HStack(spacing: 12) {
            // Link indicator
            Image(systemName: isLinked ? "link.circle.fill" : "circle")
                .foregroundColor(isLinked ? .blue : .secondary)
                .font(.title3)

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
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(4)
                        }
                    }
                }
            }

            Spacer()

            if isLinked {
                Image(systemName: "checkmark")
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 8)
    }
}

/// Empty state view
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.secondary)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Note connections visualization view
public struct NoteConnectionsView: View {
    let note: Note
    let linkedNotes: [Note]

    public init(note: Note, linkedNotes: [Note]) {
        self.note = note
        self.linkedNotes = linkedNotes
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Central Note
                NoteCard(note: note, isCenter: true)
                    .padding(.top)

                Text("Connected Notes")
                    .font(.headline)
                    .foregroundColor(.secondary)

                // Linked Notes
                ForEach(linkedNotes) { linkedNote in
                    HStack {
                        Rectangle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 2)

                        NavigationLink(destination: Text("Note Detail")) {
                            NoteCard(note: linkedNote, isCenter: false)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Connections")
    }
}

/// Note card component
struct NoteCard: View {
    let note: Note
    let isCenter: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(note.title)
                    .font(.headline)

                Spacer()

                if isCenter {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }

            Text(note.content.prefix(150))
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)

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
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCenter ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCenter ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}
