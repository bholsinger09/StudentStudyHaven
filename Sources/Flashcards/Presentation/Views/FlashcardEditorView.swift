import SwiftUI

/// Editor view for creating/editing flashcards
struct FlashcardEditorView: View {
    @State private var front: String
    @State private var back: String
    @Environment(\.dismiss) private var dismiss

    let onSave: (String, String) -> Void

    init(front: String, back: String, onSave: @escaping (String, String) -> Void) {
        _front = State(initialValue: front)
        _back = State(initialValue: back)
        self.onSave = onSave
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with Cancel and Save buttons
            HStack(spacing: 16) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(minWidth: 100, minHeight: 40)
                        .background(Color(red: 0.9, green: 0.4, blue: 0.5))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {
                    onSave(front, back)
                    dismiss()
                }) {
                    Text("Save Flashcard")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 140, minHeight: 40)
                        .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(
                    front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
                .opacity(
                    (front.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || back.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty) ? 0.5 : 1.0
                )
            }
            .padding()
            .background(Color.black)

            Divider()

            // Form
            Form {
                Section("Front (Question)") {
                    TextEditor(text: $front)
                        .frame(minHeight: 100)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                }

                Section("Back (Answer)") {
                    TextEditor(text: $back)
                        .frame(minHeight: 100)
                        .font(.body)
                        .scrollContentBackground(.hidden)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
    }
}
