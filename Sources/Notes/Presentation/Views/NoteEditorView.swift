import SwiftUI
import Core
import Notes

/// Rich text note editor
public struct NoteEditorView: View {
    @StateObject private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    
    @FocusState private var isTitleFocused: Bool
    @FocusState private var isContentFocused: Bool
    
    public init(viewModel: NoteEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if viewModel.isSaving {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    Text(viewModel.lastSaved)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Menu {
                    Button(action: { viewModel.generateFlashcards() }) {
                        Label("Generate Flashcards", systemImage: "rectangle.stack.fill.badge.plus")
                    }
                    
                    Button(action: { viewModel.showLinkNotes.toggle() }) {
                        Label("Link Notes", systemImage: "link")
                    }
                    
                    Divider()
                    
                    Button(role: .destructive, action: { viewModel.deleteNote() }) {
                        Label("Delete Note", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .background(Color.white)
            
            Divider()
            
            // Editor Content
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title
                    TextField("Title", text: $viewModel.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .focused($isTitleFocused)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    // Tags
                    TagsView(
                        tags: $viewModel.tags,
                        onAddTag: { tag in
                            viewModel.addTag(tag)
                        },
                        onRemoveTag: { tag in
                            viewModel.removeTag(tag)
                        }
                    )
                    .padding(.horizontal)
                    
                    // Linked Notes Preview
                    if !viewModel.linkedNotes.isEmpty {
                        LinkedNotesPreview(notes: viewModel.linkedNotes) {
                            viewModel.showLinkNotes = true
                        }
                        .padding(.horizontal)
                    }
                    
                    Divider()
                        .padding(.horizontal)
                    
                    // Content Editor
                    TextEditor(text: $viewModel.content)
                        .font(.body)
                        .focused($isContentFocused)
                        .frame(minHeight: 400)
                        .padding(.horizontal)
                }
                .padding(.bottom, 100)
            }
            
            // Formatting Toolbar
            FormattingToolbar(
                onBold: { /* Add bold formatting */ },
                onItalic: { /* Add italic formatting */ },
                onBullet: { viewModel.insertBulletPoint() },
                onNumbered: { viewModel.insertNumberedList() },
                onHeading: { viewModel.insertHeading() }
            )
        }
        .onAppear {
            isTitleFocused = viewModel.title.isEmpty
        }
        .sheet(isPresented: $viewModel.showLinkNotes) {
            NoteLinkingView(
                currentNoteId: viewModel.noteId,
                linkedNoteIds: viewModel.note?.linkedNoteIds ?? [],
                onLink: { noteId in
                    Task {
                        await viewModel.linkNote(noteId)
                    }
                }
            )
        }
        .alert("Generate Flashcards", isPresented: $viewModel.showGenerateAlert) {
            Button("Generate") {
                Task {
                    await viewModel.confirmGenerateFlashcards()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Generate flashcards from this note?")
        }
    }
}

/// ViewModel for note editor
@MainActor
public class NoteEditorViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var content: String = ""
    @Published public var tags: [String] = []
    @Published public var linkedNotes: [Note] = []
    @Published public var isSaving: Bool = false
    @Published public var lastSaved: String = "Not saved"
    @Published public var showLinkNotes: Bool = false
    @Published public var showGenerateAlert: Bool = false
    
    public var note: Note?
    public let noteId: UUID
    private let classId: UUID
    private let userId: UUID
    
    public init(note: Note? = nil, classId: UUID, userId: UUID) {
        self.note = note
        self.noteId = note?.id ?? UUID()
        self.classId = classId
        self.userId = userId
        
        if let note = note {
            self.title = note.title
            self.content = note.content
            self.tags = note.tags
        }
    }
    
    public func addTag(_ tag: String) {
        guard !tag.isEmpty && !tags.contains(tag) else { return }
        tags.append(tag)
        saveNote()
    }
    
    public func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
        saveNote()
    }
    
    public func insertBulletPoint() {
        content += "\n• "
    }
    
    public func insertNumberedList() {
        let nextNumber = content.components(separatedBy: "\n").filter { $0.hasPrefix("1.") }.count + 1
        content += "\n\(nextNumber). "
    }
    
    public func insertHeading() {
        content += "\n## "
    }
    
    public func generateFlashcards() {
        showGenerateAlert = true
    }
    
    public func confirmGenerateFlashcards() async {
        // Implementation would call flashcard generation use case
    }
    
    public func linkNote(_ noteId: UUID) async {
        // Implementation would call link notes use case
    }
    
    public func deleteNote() {
        // Implementation would call delete note use case
    }
    
    private func saveNote() {
        isSaving = true
        
        // Auto-save implementation
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)
            isSaving = false
            lastSaved = "Saved \(Date().formatted(date: .omitted, time: .shortened))"
        }
    }
}

/// Tags input view
struct TagsView: View {
    @Binding var tags: [String]
    let onAddTag: (String) -> Void
    let onRemoveTag: (String) -> Void
    
    @State private var newTag = ""
    @FocusState private var isTagFieldFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tags.isEmpty {
                FlowLayout(spacing: 8) {
                    ForEach(tags, id: \.self) { tag in
                        TagChip(tag: tag) {
                            onRemoveTag(tag)
                        }
                    }
                }
            }
            
            HStack {
                TextField("Add tag...", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                    .focused($isTagFieldFocused)
                    .onSubmit {
                        onAddTag(newTag)
                        newTag = ""
                    }
                
                Button(action: {
                    onAddTag(newTag)
                    newTag = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                }
                .disabled(newTag.isEmpty)
            }
        }
    }
}

/// Tag chip component
struct TagChip: View {
    let tag: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text("#\(tag)")
                .font(.caption)
            
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.blue.opacity(0.2))
        .foregroundColor(.blue)
        .cornerRadius(16)
    }
}

/// Linked notes preview
struct LinkedNotesPreview: View {
    let notes: [Note]
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.blue)
                Text("Linked Notes (\(notes.count))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: onTap) {
                    Text("Manage")
                        .font(.caption)
                }
            }
            
            ForEach(notes.prefix(3)) { note in
                HStack {
                    Image(systemName: "note.text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(note.title)
                        .font(.caption)
                        .lineLimit(1)
                    
                    Spacer()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.05))
        .cornerRadius(12)
    }
}

/// Formatting toolbar
struct FormattingToolbar: View {
    let onBold: () -> Void
    let onItalic: () -> Void
    let onBullet: () -> Void
    let onNumbered: () -> Void
    let onHeading: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            ToolbarButton(icon: "bold", action: onBold)
            ToolbarButton(icon: "italic", action: onItalic)
            ToolbarButton(icon: "list.bullet", action: onBullet)
            ToolbarButton(icon: "list.number", action: onNumbered)
            ToolbarButton(icon: "textformat.size", action: onHeading)
        }
        .padding()
        .background(Color.gray.opacity(0.1))
    }
}

struct ToolbarButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(.primary)
                .frame(width: 44, height: 44)
        }
    }
}

/// Flow layout for tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}
