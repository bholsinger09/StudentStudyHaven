import Core
import Flashcards
import SwiftUI

/// Flashcard list view
public struct FlashcardListView: View {
    @StateObject private var viewModel: FlashcardListViewModel
    @State private var showingStudyView = false
    @State private var showingCreateFlashcard = false

    public init(viewModel: FlashcardListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.flashcards.isEmpty {
                EmptyFlashcardsStateView(showingCreateFlashcard: $showingCreateFlashcard)
            } else {
                List {
                    // Study Button Section
                    Section {
                        Button(action: { showingStudyView = true }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(
                                            Color(red: 0.73, green: 0.33, blue: 0.83).opacity(0.2)
                                        )
                                        .frame(width: 50, height: 50)

                                    Image(systemName: "play.fill")
                                        .font(.title3)
                                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start Studying")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Text("\(viewModel.flashcards.count) cards ready to review")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    // Flashcards List
                    Section("All Flashcards") {
                        ForEach(viewModel.flashcards) { flashcard in
                            FlashcardListRow(flashcard: flashcard)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
        }
        .navigationTitle("Flashcards")
        .toolbar {
            if !viewModel.flashcards.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingCreateFlashcard = true }) {
                            Label("Create Flashcard", systemImage: "plus")
                        }
                        Button(action: { /* TODO: Generate from notes */  }) {
                            Label("Generate from Notes", systemImage: "wand.and.stars")
                        }
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingStudyView) {
            NavigationStack {
                FlashcardStudyView(flashcards: viewModel.flashcards)
            }
        }
        .sheet(isPresented: $showingCreateFlashcard) {
            FlashcardEditorView(
                front: "",
                back: "",
                onSave: { front, back in
                    Task {
                        await viewModel.createFlashcard(front: front, back: back)
                    }
                    showingCreateFlashcard = false
                }
            )
            .frame(width: 500, height: 400)
        }
        .task {
            await viewModel.loadFlashcards()
        }
    }
}

/// Flashcard row in list
struct FlashcardListRow: View {
    let flashcard: Flashcard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(flashcard.front)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if flashcard.lastReviewedAt != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                        .font(.caption)
                }
            }

            Text(flashcard.back)
                .font(.subheadline)
                .foregroundColor(.gray)
                .lineLimit(2)

            if let lastReviewed = flashcard.lastReviewedAt {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Last reviewed \(lastReviewed, style: .relative)")
                        .font(.caption2)
                }
                .foregroundColor(.gray)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for flashcards
struct EmptyFlashcardsStateView: View {
    @Binding var showingCreateFlashcard: Bool

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "rectangle.stack")
                    .font(.system(size: 70))
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                VStack(spacing: 8) {
                    Text("No Flashcards Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Create flashcards manually or generate them from your notes")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                VStack(spacing: 12) {
                    Button(action: { showingCreateFlashcard = true }) {
                        Label("Create Flashcard", systemImage: "plus")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                            .cornerRadius(12)
                            .shadow(
                                color: Color(red: 0.0, green: 0.2, blue: 0.4).opacity(0.3),
                                radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)

                    Button(action: { /* TODO: Generate from notes */  }) {
                        Label("Generate from Notes", systemImage: "wand.and.stars")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 40)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
