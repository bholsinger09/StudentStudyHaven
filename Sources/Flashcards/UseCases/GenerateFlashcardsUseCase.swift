import Core
import Foundation

/// Use case for generating flashcards from note content
public final class GenerateFlashcardsUseCase {
    private let flashcardRepository: FlashcardRepositoryProtocol

    public init(flashcardRepository: FlashcardRepositoryProtocol) {
        self.flashcardRepository = flashcardRepository
    }

    public func execute(from note: Note, userId: String) async throws -> [Flashcard] {
        // Generate flashcards from note content
        let generatedFlashcards = generateFromContent(
            content: note.content,
            classId: note.classId,
            userId: userId,
            noteId: note.id
        )

        guard !generatedFlashcards.isEmpty else {
            throw AppError.invalidData("Could not generate flashcards from the provided content")
        }

        return try await flashcardRepository.createFlashcards(generatedFlashcards)
    }

    private func generateFromContent(
        content: String,
        classId: String,
        userId: String,
        noteId: String
    ) -> [Flashcard] {
        var flashcards: [Flashcard] = []

        // Split content into sentences
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        // Look for definition patterns (e.g., "X is Y", "X: Y")
        for sentence in sentences {
            if let flashcard = extractDefinition(
                from: sentence,
                classId: classId,
                userId: userId,
                noteId: noteId
            ) {
                flashcards.append(flashcard)
            }
        }

        return flashcards
    }

    private func extractDefinition(
        from sentence: String,
        classId: String,
        userId: String,
        noteId: String
    ) -> Flashcard? {
        // Pattern 1: "Term is definition"
        if let range = sentence.range(of: " is ") {
            let term = String(sentence[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let definition = String(sentence[range.upperBound...]).trimmingCharacters(
                in: .whitespaces)

            if !term.isEmpty && !definition.isEmpty {
                return Flashcard(
                    classId: classId,
                    userId: userId,
                    front: term,
                    back: definition,
                    noteIds: [noteId]
                )
            }
        }

        // Pattern 2: "Term: definition"
        if let range = sentence.range(of: ": ") {
            let term = String(sentence[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
            let definition = String(sentence[range.upperBound...]).trimmingCharacters(
                in: .whitespaces)

            if !term.isEmpty && !definition.isEmpty {
                return Flashcard(
                    classId: classId,
                    userId: userId,
                    front: term,
                    back: definition,
                    noteIds: [noteId]
                )
            }
        }

        return nil
    }
}
