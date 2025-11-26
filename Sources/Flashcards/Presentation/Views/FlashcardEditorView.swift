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
            HStack(spacing: 12) {
                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
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
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
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
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black)

            Divider()

            // Form
            Form {
                Section("Front (Question)") {
                    GeometryReader { geometry in
                        TextEditor(text: $front)
                            .frame(height: max(100, geometry.size.height * 0.35))
                            .font(.body)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(minHeight: 100)
                }

                Section("Back (Answer)") {
                    GeometryReader { geometry in
                        TextEditor(text: $back)
                            .frame(height: max(100, geometry.size.height * 0.35))
                            .font(.body)
                            .scrollContentBackground(.hidden)
                    }
                    .frame(minHeight: 100)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
        }
    }
}
