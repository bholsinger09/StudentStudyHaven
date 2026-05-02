import Core
import SwiftUI

#if canImport(AppKit)
    import AppKit
#endif

/// Simple note editor for classroom documents
public struct NoteEditorView: View {
    @StateObject private var viewModel: NoteEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var focusedField: Field?
    @State private var keyMonitor: Any?

    enum Field: Hashable {
        case subject
        case notes
    }

    public init(viewModel: NoteEditorViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header with Cancel and Save
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
                    Task {
                        await viewModel.saveDocument()
                        dismiss()
                    }
                }) {
                    Text("Save Note")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(minWidth: 120, minHeight: 40)
                        .background(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .cornerRadius(8)
                }
                .buttonStyle(.plain)
                .disabled(!viewModel.isValid)
                .opacity(viewModel.isValid ? 1.0 : 0.5)
            }
            .padding()
            .background(Color.black)

            Divider()

            // Simple Form
            Form {
                Section("Class Information") {
                    TextField("Name of Class", text: $viewModel.subjectMatter)
                        .textFieldStyle(.plain)
                        .font(.body)
                        .focused($focusedField, equals: .subject)
                        .onChange(of: viewModel.subjectMatter) { newValue in
                            print(
                                "📝 [\(Date().formatted(date: .omitted, time: .standard))] Subject changed: '\(newValue)'"
                            )
                            logInputEvent("TextField", newValue)
                        }
                        .onTapGesture {
                            print("👆 TextField tapped - requesting focus")
                            focusedField = .subject
                            checkAppState()
                        }
                }

                Section("Date") {
                    DatePicker("", selection: $viewModel.documentDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                }

                Section("Notes") {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $viewModel.content)
                            .frame(minHeight: 250)
                            .font(.body)
                            .scrollContentBackground(.hidden)
                            .focused($focusedField, equals: .notes)
                            .onChange(of: viewModel.content) { newValue in
                                print(
                                    "📝 [\(Date().formatted(date: .omitted, time: .standard))] Content changed: \(newValue.count) chars"
                                )
                                logInputEvent("TextEditor", newValue)
                            }
                            .onTapGesture {
                                print("👆 TextEditor tapped - requesting focus")
                                focusedField = .notes
                                checkAppState()
                            }

                        if viewModel.content.isEmpty {
                            Text("Add notes here")
                                .foregroundColor(.gray.opacity(0.5))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                                .allowsHitTesting(false)
                        }
                    }
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            #if os(macOS)
                .background(Color(NSColor.windowBackgroundColor))
            #else
                .background(Color(.systemGroupedBackground))
            #endif
        }
        .onChange(of: focusedField) { newFocus in
            print("🎯 Focus changed to: \(newFocus?.description ?? "none")")
        }
        .onAppear {
            print("\n" + String(repeating: "=", count: 60))
            print("🚀 NOTE EDITOR OPENED")
            print(String(repeating: "=", count: 60))
            checkAppState()
            print(String(repeating: "=", count: 60) + "\n")

            // Install global keyboard event monitor
            setupKeyboardMonitor()

            // Force focus to subject field
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                focusedField = .subject
                print("⚡ Auto-focused to subject field")
            }
        }
        .onDisappear {
            #if os(macOS)
                if let monitor = keyMonitor {
                    NSEvent.removeMonitor(monitor)
                    print("🛑 Removed keyboard monitor")
                }
            #endif
        }
    }

    // MARK: - Debugging Helpers

    private func logInputEvent(_ source: String, _ text: String) {
        print("⌨️  INPUT EVENT from \(source):")
        print("   └─ Text: '\(text)'")
        print("   └─ Length: \(text.count)")
        print("   └─ Time: \(Date().formatted(date: .omitted, time: .standard))")
    }

    private func setupKeyboardMonitor() {
        #if os(macOS)
            print("⌨️  Installing GLOBAL keyboard event monitor...")

            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp]) { event in
                let char = event.characters ?? ""
                let keyCode = event.keyCode
                print("⌨️  KEYBOARD EVENT DETECTED:")
                print("   ├─ Type: \(event.type == .keyDown ? "KEY DOWN" : "KEY UP")")
                print("   ├─ Character: '\(char)'")
                print("   ├─ Key Code: \(keyCode)")
                print("   ├─ Modifiers: \(event.modifierFlags)")
                print("   ├─ Window: \(NSApp?.keyWindow?.title ?? "none")")
                print(
                    "   └─ First Responder: \(NSApp?.keyWindow?.firstResponder?.className ?? "none")"
                )
                return event
            }

            print("✅ Keyboard monitor installed!")
        #else
            print("⌨️  Keyboard monitoring not available on iOS")
        #endif
    }

    private func checkAppState() {
        #if os(macOS)
            guard let app = NSApp else { return }

            print("\n📊 APP STATE CHECK:")
            print("   ├─ App is active: \(app.isActive)")
            print("   ├─ App is hidden: \(app.isHidden)")
            print("   ├─ Main window key: \(app.mainWindow?.isKeyWindow ?? false)")
            print("   ├─ First responder: \(app.keyWindow?.firstResponder?.className ?? "none")")

            // Check for Notes app
            let notesRunning = isNotesAppRunning()
            let notesActive =
                NSWorkspace.shared.frontmostApplication?.bundleIdentifier == "com.apple.Notes"
            print("   ├─ Notes.app running: \(notesRunning ? "⚠️ YES" : "✅ NO")")
            print("   └─ Notes.app frontmost: \(notesActive ? "⚠️ YES" : "✅ NO")")

            // Try to activate
            app.activate(ignoringOtherApps: true)
            print("   └─ Attempted app activation")
            print("")
        #else
            print("\n📊 APP STATE CHECK (iOS - limited info)")
        #endif
    }
}

extension NoteEditorView.Field {
    var description: String {
        switch self {
        case .subject: return "Subject Field"
        case .notes: return "Notes Field"
        }
    }
}

func isNotesAppRunning() -> Bool {
    #if os(macOS)
        return NSWorkspace.shared.runningApplications.contains {
            $0.bundleIdentifier == "com.apple.Notes"
        }
    #else
        return false
    #endif
}

@MainActor
public class NoteEditorViewModel: ObservableObject {
    @Published public var subjectMatter: String = ""
    @Published public var documentDate: Date = Date()
    @Published public var content: String = ""
    @Published public var isSaving: Bool = false

    private let noteId: String
    private let classId: String
    private let userId: String
    private let existingNote: Note?
    private let createNoteUseCase: CreateNoteUseCase?
    private let updateNoteUseCase: UpdateNoteUseCase?

    public init(
        note: Note? = nil,
        classId: String,
        userId: String,
        createNoteUseCase: CreateNoteUseCase? = nil,
        updateNoteUseCase: UpdateNoteUseCase? = nil
    ) {
        self.existingNote = note
        self.noteId = note?.id ?? UUID().uuidString
        self.classId = classId
        self.userId = userId
        self.createNoteUseCase = createNoteUseCase
        self.updateNoteUseCase = updateNoteUseCase

        if let note = note {
            self.subjectMatter = note.title
            self.content = note.content
            self.documentDate = note.createdAt
        }
    }

    public func saveDocument() async {
        guard !subjectMatter.isEmpty else { return }

        print("💾 Saving note...")
        isSaving = true
        defer { isSaving = false }

        do {
            let note = Note(
                id: noteId,
                classId: classId,
                userId: userId,
                title: subjectMatter,
                content: content,
                tags: [],
                createdAt: documentDate,
                updatedAt: Date()
            )

            if existingNote != nil {
                // Update existing note
                _ = try await updateNoteUseCase?.execute(note: note)
                print("✅ Note updated!")
            } else {
                // Create new note
                _ = try await createNoteUseCase?.execute(note: note)
                print("✅ Note created!")
            }

            // Notify that note was saved
            NotificationCenter.default.post(
                name: NSNotification.Name("NoteDidSave"),
                object: note
            )
        } catch {
            print("❌ Save failed: \(error)")
        }
    }

    public var isValid: Bool {
        !subjectMatter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
