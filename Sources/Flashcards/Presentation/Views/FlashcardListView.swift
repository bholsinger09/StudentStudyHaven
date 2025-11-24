import SwiftUI
import Core
import Flashcards

/// Flashcard list view
public struct FlashcardListView: View {
    @StateObject private var viewModel: FlashcardListViewModel
    @State private var showingStudyView = false
    
    public init(viewModel: FlashcardListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.flashcards.isEmpty {
                EmptyFlashcardsStateView()
            } else {
                List {
                    // Study Button Section
                    Section {
                        Button(action: { showingStudyView = true }) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.green.opacity(0.2))
                                        .frame(width: 50, height: 50)
                                    
                                    Image(systemName: "play.fill")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Start Studying")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text("\(viewModel.flashcards.count) cards ready to review")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
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
            }
        }
        .navigationTitle("Flashcards")
        .toolbar {
            if !viewModel.flashcards.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: {}) {
                            Label("Create Flashcard", systemImage: "plus")
                        }
                        Button(action: {}) {
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
                
                Spacer()
                
                if flashcard.lastReviewedAt != nil {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            Text(flashcard.back)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            if let lastReviewed = flashcard.lastReviewedAt {
                HStack {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text("Last reviewed \(lastReviewed, style: .relative)")
                        .font(.caption2)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Empty state for flashcards
struct EmptyFlashcardsStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "rectangle.stack")
                .font(.system(size: 70))
                .foregroundColor(.green.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Flashcards Yet")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Create flashcards manually or generate them from your notes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            VStack(spacing: 12) {
                Button(action: {}) {
                    Label("Create Flashcard", systemImage: "plus")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                }
                
                Button(action: {}) {
                    Label("Generate from Notes", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
