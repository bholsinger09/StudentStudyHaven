import Foundation

/// SuperMemo-2 (SM-2) Spaced Repetition Algorithm Implementation
/// Based on: https://www.supermemo.com/en/archives1990-2015/english/ol/sm2
public final class SpacedRepetitionAlgorithm {

    /// Quality rating for a flashcard review (0-5)
    public enum Quality: Int {
        case blackout = 0  // Complete blackout, no recall
        case incorrect = 1  // Incorrect response, but recognized answer
        case difficultCorrect = 2  // Correct response with difficulty
        case hesitantCorrect = 3  // Correct with hesitation
        case easyCorrect = 4  // Easy correct response
        case perfect = 5  // Perfect recall

        var isPass: Bool {
            self.rawValue >= 3
        }
    }

    /// Represents the review data for a flashcard
    public struct ReviewData: Codable, Equatable {
        public var repetitions: Int
        public var easeFactor: Double
        public var interval: Int  // in days
        public var nextReviewDate: Date
        public var lastReviewDate: Date?

        public init(
            repetitions: Int = 0,
            easeFactor: Double = 2.5,
            interval: Int = 0,
            nextReviewDate: Date = Date(),
            lastReviewDate: Date? = nil
        ) {
            self.repetitions = repetitions
            self.easeFactor = easeFactor
            self.interval = interval
            self.nextReviewDate = nextReviewDate
            self.lastReviewDate = lastReviewDate
        }
    }

    public init() {}

    /// Calculate the next review data based on the quality of recall
    /// - Parameters:
    ///   - currentData: The current review data
    ///   - quality: The quality rating (0-5) of the recall
    /// - Returns: Updated review data with new interval and next review date
    public func calculateNextReview(currentData: ReviewData, quality: Quality) -> ReviewData {
        var newData = currentData
        newData.lastReviewDate = Date()

        // Update ease factor (EF)
        // EF' = EF + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))
        let q = Double(quality.rawValue)
        var newEaseFactor = newData.easeFactor + (0.1 - (5 - q) * (0.08 + (5 - q) * 0.02))

        // Minimum ease factor is 1.3
        newEaseFactor = max(1.3, newEaseFactor)
        newData.easeFactor = newEaseFactor

        // Calculate new interval and repetitions
        if quality.isPass {
            // Correct response (quality >= 3)
            newData.repetitions += 1

            switch newData.repetitions {
            case 1:
                newData.interval = 1  // First review: 1 day
            case 2:
                newData.interval = 6  // Second review: 6 days
            default:
                // Subsequent reviews: I(n) = I(n-1) * EF
                newData.interval = Int(Double(newData.interval) * newData.easeFactor)
            }
        } else {
            // Incorrect response (quality < 3)
            newData.repetitions = 0
            newData.interval = 1  // Reset to 1 day
        }

        // Calculate next review date
        newData.nextReviewDate =
            Calendar.current.date(
                byAdding: .day,
                value: newData.interval,
                to: Date()
            ) ?? Date()

        return newData
    }

    /// Determine if a flashcard is due for review
    /// - Parameters:
    ///   - reviewData: The review data to check
    ///   - currentDate: The date to check against (defaults to now)
    /// - Returns: True if the card is due for review
    public func isDueForReview(reviewData: ReviewData, currentDate: Date = Date()) -> Bool {
        return currentDate >= reviewData.nextReviewDate
    }

    /// Calculate the number of days until the next review
    /// - Parameters:
    ///   - reviewData: The review data
    ///   - currentDate: The date to calculate from (defaults to now)
    /// - Returns: Number of days until review (negative if overdue)
    public func daysUntilReview(reviewData: ReviewData, currentDate: Date = Date()) -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: currentDate,
            to: reviewData.nextReviewDate
        )
        return components.day ?? 0
    }

    /// Get a difficulty assessment based on the review data
    public func getDifficultyLevel(reviewData: ReviewData) -> DifficultyLevel {
        switch reviewData.easeFactor {
        case 1.3..<1.8:
            return .hard
        case 1.8..<2.3:
            return .medium
        case 2.3...:
            return .easy
        default:
            return .medium
        }
    }

    public enum DifficultyLevel: String, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }

    /// Calculate optimal study session size based on due cards
    /// - Parameter totalDueCards: Number of cards due for review
    /// - Returns: Recommended number of cards per session
    public func recommendedSessionSize(totalDueCards: Int) -> Int {
        switch totalDueCards {
        case 0...10:
            return totalDueCards
        case 11...30:
            return 15
        case 31...50:
            return 20
        default:
            return 25
        }
    }
}
