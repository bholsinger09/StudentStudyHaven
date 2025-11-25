import Core
import Flashcards
import SwiftUI

/// Flashcard study view with flip animations
public struct FlashcardStudyView: View {
    let flashcards: [Flashcard]
    @Environment(\.dismiss) private var dismiss

    @State private var currentIndex = 0
    @State private var isShowingAnswer = false
    @State private var offset: CGSize = .zero
    @State private var rotation: Double = 0
    @State private var studiedCount = 0

    public init(flashcards: [Flashcard]) {
        self.flashcards = flashcards
    }

    private var currentCard: Flashcard? {
        guard currentIndex < flashcards.count else { return nil }
        return flashcards[currentIndex]
    }

    private var progress: Double {
        guard !flashcards.isEmpty else { return 0 }
        return Double(studiedCount) / Double(flashcards.count)
    }

    public var body: some View {
        VStack(spacing: 20) {
            // Progress Bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(studiedCount) / \(flashcards.count)")
                        .font(.caption)
                        .fontWeight(.semibold)
                }

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(.blue)
            }
            .padding(.horizontal)
            .padding(.top)

            // Flashcard Stack
            ZStack {
                if let card = currentCard {
                    FlashcardView(
                        flashcard: card,
                        isShowingAnswer: isShowingAnswer
                    )
                    .rotationEffect(.degrees(rotation))
                    .offset(offset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                offset = gesture.translation
                                rotation = Double(gesture.translation.width / 20)
                            }
                            .onEnded { gesture in
                                handleSwipe(gesture)
                            }
                    )
                    .onTapGesture {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            isShowingAnswer.toggle()
                        }
                    }
                } else {
                    CompletedView(
                        totalCards: flashcards.count,
                        onRestart: restart,
                        onDismiss: { dismiss() }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Action Buttons
            if currentCard != nil {
                HStack(spacing: 40) {
                    ActionButtonView(
                        icon: "xmark",
                        color: .red,
                        action: { swipeLeft() }
                    )

                    ActionButtonView(
                        icon: "arrow.clockwise",
                        color: .blue,
                        action: { flipCard() }
                    )

                    ActionButtonView(
                        icon: "checkmark",
                        color: .green,
                        action: { swipeRight() }
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
        .navigationTitle("Study")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
    }

    private func handleSwipe(_ gesture: DragGesture.Value) {
        let swipeThreshold: CGFloat = 100

        if gesture.translation.width > swipeThreshold {
            swipeRight()
        } else if gesture.translation.width < -swipeThreshold {
            swipeLeft()
        } else {
            withAnimation(.spring()) {
                offset = .zero
                rotation = 0
            }
        }
    }

    private func swipeLeft() {
        withAnimation(.spring()) {
            offset = CGSize(width: -500, height: 0)
            rotation = -20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            moveToNextCard()
        }
    }

    private func swipeRight() {
        withAnimation(.spring()) {
            offset = CGSize(width: 500, height: 0)
            rotation = 20
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            moveToNextCard()
        }
    }

    private func flipCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isShowingAnswer.toggle()
        }
    }

    private func moveToNextCard() {
        studiedCount += 1
        currentIndex += 1
        isShowingAnswer = false

        withAnimation(.spring()) {
            offset = .zero
            rotation = 0
        }
    }

    private func restart() {
        currentIndex = 0
        studiedCount = 0
        isShowingAnswer = false
        offset = .zero
        rotation = 0
    }
}

/// Individual flashcard view
struct FlashcardView: View {
    let flashcard: Flashcard
    let isShowingAnswer: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.8), .blue],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(radius: 10)

            VStack(spacing: 20) {
                Text(isShowingAnswer ? "Answer" : "Question")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white.opacity(0.8))

                Text(isShowingAnswer ? flashcard.back : flashcard.front)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Text("Tap to flip")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .frame(maxWidth: 350, maxHeight: 500)
        .rotation3DEffect(
            .degrees(isShowingAnswer ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
    }
}

/// Action button for study controls
struct ActionButtonView: View {
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())
                .shadow(radius: 5)
        }
    }
}

/// Completion view
struct CompletedView: View {
    let totalCards: Int
    let onRestart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)

            Text("Great Job!")
                .font(.title)
                .fontWeight(.bold)

            Text("You've studied \(totalCards) flashcards")
                .font(.subheadline)
                .foregroundColor(.secondary)

            VStack(spacing: 16) {
                Button(action: onRestart) {
                    Text("Study Again")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: onDismiss) {
                    Text("Done")
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
        }
    }
}
