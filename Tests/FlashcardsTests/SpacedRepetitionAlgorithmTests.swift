import XCTest
@testable import Flashcards

final class SpacedRepetitionAlgorithmTests: XCTestCase {
    var sut: SpacedRepetitionAlgorithm!
    
    override func setUp() {
        super.setUp()
        sut = SpacedRepetitionAlgorithm()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial Review Tests
    
    func testCalculateNextReview_FirstReview_PerfectRecall_SetsIntervalToOne() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .perfect)
        
        // Then
        XCTAssertEqual(result.interval, 1, "First review should have 1-day interval")
        XCTAssertEqual(result.repetitions, 1, "Repetitions should be 1")
    }
    
    func testCalculateNextReview_FirstReview_EasyCorrect_SetsIntervalToOne() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .easyCorrect)
        
        // Then
        XCTAssertEqual(result.interval, 1, "First review should have 1-day interval")
        XCTAssertEqual(result.repetitions, 1)
    }
    
    func testCalculateNextReview_FirstReview_FailedRecall_ResetsToOne() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .blackout)
        
        // Then
        XCTAssertEqual(result.interval, 1, "Failed review should reset to 1-day interval")
        XCTAssertEqual(result.repetitions, 0, "Repetitions should reset to 0")
    }
    
    // MARK: - Second Review Tests
    
    func testCalculateNextReview_SecondReview_PerfectRecall_SetsIntervalToSix() {
        // Given
        var firstReview = SpacedRepetitionAlgorithm.ReviewData()
        firstReview = sut.calculateNextReview(currentData: firstReview, quality: .perfect)
        
        // When
        let secondReview = sut.calculateNextReview(currentData: firstReview, quality: .perfect)
        
        // Then
        XCTAssertEqual(secondReview.interval, 6, "Second successful review should have 6-day interval")
        XCTAssertEqual(secondReview.repetitions, 2)
    }
    
    func testCalculateNextReview_SecondReview_Failed_ResetsProgress() {
        // Given
        var firstReview = SpacedRepetitionAlgorithm.ReviewData()
        firstReview = sut.calculateNextReview(currentData: firstReview, quality: .perfect)
        
        // When
        let secondReview = sut.calculateNextReview(currentData: firstReview, quality: .incorrect)
        
        // Then
        XCTAssertEqual(secondReview.interval, 1, "Failed review should reset interval")
        XCTAssertEqual(secondReview.repetitions, 0, "Failed review should reset repetitions")
    }
    
    // MARK: - Subsequent Review Tests
    
    func testCalculateNextReview_ThirdReview_UsesEaseFactor() {
        // Given
        var review = SpacedRepetitionAlgorithm.ReviewData()
        review = sut.calculateNextReview(currentData: review, quality: .perfect)
        review = sut.calculateNextReview(currentData: review, quality: .perfect)
        let expectedInterval = Int(Double(review.interval) * review.easeFactor)
        
        // When
        let thirdReview = sut.calculateNextReview(currentData: review, quality: .perfect)
        
        // Then
        XCTAssertEqual(thirdReview.interval, expectedInterval, "Should calculate interval using ease factor")
        XCTAssertEqual(thirdReview.repetitions, 3)
    }
    
    func testCalculateNextReview_MultipleReviews_IntervalIncreases() {
        // Given
        var review = SpacedRepetitionAlgorithm.ReviewData()
        
        // When - Simulate multiple successful reviews
        review = sut.calculateNextReview(currentData: review, quality: .perfect)
        let interval1 = review.interval
        
        review = sut.calculateNextReview(currentData: review, quality: .perfect)
        let interval2 = review.interval
        
        review = sut.calculateNextReview(currentData: review, quality: .perfect)
        let interval3 = review.interval
        
        // Then
        XCTAssertLessThan(interval1, interval2, "Interval should increase")
        XCTAssertLessThan(interval2, interval3, "Interval should continue increasing")
    }
    
    // MARK: - Ease Factor Tests
    
    func testCalculateNextReview_PerfectRecall_IncreasesEaseFactor() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        let initialEase = initialData.easeFactor
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .perfect)
        
        // Then
        XCTAssertGreaterThan(result.easeFactor, initialEase, "Perfect recall should increase ease factor")
    }
    
    func testCalculateNextReview_DifficultRecall_DecreasesEaseFactor() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        let initialEase = initialData.easeFactor
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .hesitantCorrect)
        
        // Then
        XCTAssertLessThan(result.easeFactor, initialEase, "Difficult recall should decrease ease factor")
    }
    
    func testCalculateNextReview_MinimumEaseFactor_NeverGoesBelowMinimum() {
        // Given
        var review = SpacedRepetitionAlgorithm.ReviewData(easeFactor: 1.4)
        
        // When - Multiple failed attempts
        for _ in 0..<10 {
            review = sut.calculateNextReview(currentData: review, quality: .blackout)
        }
        
        // Then
        XCTAssertGreaterThanOrEqual(review.easeFactor, 1.3, "Ease factor should never go below 1.3")
    }
    
    func testCalculateNextReview_EaseFactorFormula_CalculatesCorrectly() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData(easeFactor: 2.5)
        let quality = 4 // easyCorrect
        let expectedEase = 2.5 + (0.1 - (5 - Double(quality)) * (0.08 + (5 - Double(quality)) * 0.02))
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .easyCorrect)
        
        // Then
        XCTAssertEqual(result.easeFactor, expectedEase, accuracy: 0.01, "Should calculate ease factor correctly")
    }
    
    // MARK: - Quality Rating Tests
    
    func testQuality_IsPass_CorrectlyIdentifiesPassingGrades() {
        XCTAssertTrue(SpacedRepetitionAlgorithm.Quality.perfect.isPass)
        XCTAssertTrue(SpacedRepetitionAlgorithm.Quality.easyCorrect.isPass)
        XCTAssertTrue(SpacedRepetitionAlgorithm.Quality.hesitantCorrect.isPass)
        XCTAssertFalse(SpacedRepetitionAlgorithm.Quality.difficultCorrect.isPass)
        XCTAssertFalse(SpacedRepetitionAlgorithm.Quality.incorrect.isPass)
        XCTAssertFalse(SpacedRepetitionAlgorithm.Quality.blackout.isPass)
    }
    
    // MARK: - Date Calculation Tests
    
    func testCalculateNextReview_SetsNextReviewDate() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        let now = Date()
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .perfect)
        
        // Then
        let daysDifference = Calendar.current.dateComponents([.day], from: now, to: result.nextReviewDate).day ?? 0
        XCTAssertEqual(daysDifference, result.interval, "Next review date should match interval")
    }
    
    func testCalculateNextReview_UpdatesLastReviewDate() {
        // Given
        let initialData = SpacedRepetitionAlgorithm.ReviewData()
        let beforeReview = Date()
        
        // When
        let result = sut.calculateNextReview(currentData: initialData, quality: .perfect)
        
        // Then
        XCTAssertNotNil(result.lastReviewDate)
        XCTAssertGreaterThanOrEqual(result.lastReviewDate!, beforeReview)
    }
    
    // MARK: - isDueForReview Tests
    
    func testIsDueForReview_CurrentDateAfterNextReview_ReturnsTrue() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(nextReviewDate: pastDate)
        
        // When
        let isDue = sut.isDueForReview(reviewData: reviewData)
        
        // Then
        XCTAssertTrue(isDue, "Should be due when current date is after next review date")
    }
    
    func testIsDueForReview_CurrentDateBeforeNextReview_ReturnsFalse() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(nextReviewDate: futureDate)
        
        // When
        let isDue = sut.isDueForReview(reviewData: reviewData)
        
        // Then
        XCTAssertFalse(isDue, "Should not be due when current date is before next review date")
    }
    
    func testIsDueForReview_CurrentDateEqualsNextReview_ReturnsTrue() {
        // Given
        let now = Date()
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(nextReviewDate: now)
        
        // When
        let isDue = sut.isDueForReview(reviewData: reviewData, currentDate: now)
        
        // Then
        XCTAssertTrue(isDue, "Should be due when current date equals next review date")
    }
    
    // MARK: - daysUntilReview Tests
    
    func testDaysUntilReview_FutureDate_ReturnsPositive() {
        // Given
        let futureDate = Calendar.current.date(byAdding: .day, value: 5, to: Date())!
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(nextReviewDate: futureDate)
        
        // When
        let days = sut.daysUntilReview(reviewData: reviewData)
        
        // Then
        XCTAssertEqual(days, 5, "Should return positive days for future date")
    }
    
    func testDaysUntilReview_PastDate_ReturnsNegative() {
        // Given
        let pastDate = Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(nextReviewDate: pastDate)
        
        // When
        let days = sut.daysUntilReview(reviewData: reviewData)
        
        // Then
        XCTAssertEqual(days, -3, "Should return negative days for overdue cards")
    }
    
    // MARK: - Difficulty Level Tests
    
    func testGetDifficultyLevel_LowEaseFactor_ReturnsHard() {
        // Given
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(easeFactor: 1.5)
        
        // When
        let difficulty = sut.getDifficultyLevel(reviewData: reviewData)
        
        // Then
        XCTAssertEqual(difficulty, .hard, "Low ease factor should be hard")
    }
    
    func testGetDifficultyLevel_MediumEaseFactor_ReturnsMedium() {
        // Given
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(easeFactor: 2.0)
        
        // When
        let difficulty = sut.getDifficultyLevel(reviewData: reviewData)
        
        // Then
        XCTAssertEqual(difficulty, .medium, "Medium ease factor should be medium")
    }
    
    func testGetDifficultyLevel_HighEaseFactor_ReturnsEasy() {
        // Given
        let reviewData = SpacedRepetitionAlgorithm.ReviewData(easeFactor: 2.8)
        
        // When
        let difficulty = sut.getDifficultyLevel(reviewData: reviewData)
        
        // Then
        XCTAssertEqual(difficulty, .easy, "High ease factor should be easy")
    }
    
    // MARK: - Session Size Recommendation Tests
    
    func testRecommendedSessionSize_SmallNumberOfCards_ReturnsAll() {
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 5), 5)
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 10), 10)
    }
    
    func testRecommendedSessionSize_MediumNumberOfCards_Returns15() {
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 20), 15)
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 30), 15)
    }
    
    func testRecommendedSessionSize_LargeNumberOfCards_Returns20() {
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 40), 20)
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 50), 20)
    }
    
    func testRecommendedSessionSize_VeryLargeNumberOfCards_Returns25() {
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 100), 25)
        XCTAssertEqual(sut.recommendedSessionSize(totalDueCards: 500), 25)
    }
    
    // MARK: - Integration Tests
    
    func testFullReviewCycle_MultipleCards_MaintainsCorrectState() {
        // Given - Simulate 5 successful reviews
        var reviewData = SpacedRepetitionAlgorithm.ReviewData()
        var intervals: [Int] = []
        
        // When
        for i in 0..<5 {
            let quality: SpacedRepetitionAlgorithm.Quality = i % 2 == 0 ? .perfect : .easyCorrect
            reviewData = sut.calculateNextReview(currentData: reviewData, quality: quality)
            intervals.append(reviewData.interval)
        }
        
        // Then
        XCTAssertEqual(reviewData.repetitions, 5, "Should have 5 successful repetitions")
        XCTAssertTrue(intervals[0] < intervals[intervals.count - 1], "Intervals should generally increase")
        XCTAssertGreaterThanOrEqual(reviewData.easeFactor, 1.3, "Ease factor should be valid")
    }
    
    func testReviewCycle_WithFailures_RecoversCorrectly() {
        // Given
        var reviewData = SpacedRepetitionAlgorithm.ReviewData()
        
        // When - Success, success, fail, success
        reviewData = sut.calculateNextReview(currentData: reviewData, quality: .perfect)
        reviewData = sut.calculateNextReview(currentData: reviewData, quality: .perfect)
        let beforeFailure = reviewData.repetitions
        
        reviewData = sut.calculateNextReview(currentData: reviewData, quality: .blackout)
        let afterFailure = reviewData.repetitions
        
        reviewData = sut.calculateNextReview(currentData: reviewData, quality: .perfect)
        
        // Then
        XCTAssertEqual(beforeFailure, 2, "Should have 2 reps before failure")
        XCTAssertEqual(afterFailure, 0, "Should reset to 0 after failure")
        XCTAssertEqual(reviewData.repetitions, 1, "Should restart progression")
        XCTAssertEqual(reviewData.interval, 1, "Should restart with 1-day interval")
    }
}
