import Foundation
import Core
import Combine

/// ViewModel for notes list
@MainActor
public final class NotesListViewModel: ObservableObject {
    @Published public var notes: [Note] = []
    @Published public var searchQuery: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let getNotesUseCase: GetNotesUseCase
    private let deleteNoteUseCase: DeleteNoteUseCase
    private let classId: UUID?
    
    public var filteredNotes: [Note] {
        if searchQuery.isEmpty {
            return notes
        }
        return notes.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.content.localizedCaseInsensitiveContains(searchQuery) ||
            $0.tags.contains { $0.localizedCaseInsensitiveContains(searchQuery) }
        }
    }
    
    public init(
        getNotesUseCase: GetNotesUseCase,
        deleteNoteUseCase: DeleteNoteUseCase,
        classId: UUID? = nil
    ) {
        self.getNotesUseCase = getNotesUseCase
        self.deleteNoteUseCase = deleteNoteUseCase
        self.classId = classId
    }
    
    public func loadNotes() async {
        guard let classId = classId else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            notes = try await getNotesUseCase.execute(classId: classId)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load notes"
        }
        
        isLoading = false
    }
    
    public func deleteNote(at offsets: IndexSet) async {
        for index in offsets {
            let note = notes[index]
            do {
                try await deleteNoteUseCase.execute(noteId: note.id)
                notes.remove(at: index)
            } catch {
                errorMessage = "Failed to delete note"
            }
        }
    }
}
