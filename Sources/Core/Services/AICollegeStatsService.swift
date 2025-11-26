import Foundation

/// Service for generating college-specific statistics
/// In production, this would integrate with a real database or API
public class AICollegeStatsService {
    public static let shared = AICollegeStatsService()
    
    private init() {}
    
    /// Statistics for a college
    public struct CollegeStats {
        public let students: String
        public let acceptance: String
        
        public init(students: String, acceptance: String) {
            self.students = students
            self.acceptance = acceptance
        }
    }
    
    /// Get statistics for a specific college
    public func getStats(for collegeName: String) async throws -> CollegeStats {
        // In production, this would call a real API or database
        // For now, we'll generate contextual stats based on the college name
        return generateStatsLocally(for: collegeName)
    }
    
    private func generateStatsLocally(for collegeName: String) -> CollegeStats {
        let lowerName = collegeName.lowercased()
        
        // Ivy League / Elite Private Universities
        if lowerName.contains("harvard") || lowerName.contains("yale") || lowerName.contains("princeton") {
            return CollegeStats(students: "6,800", acceptance: "3-5%")
        }
        
        if lowerName.contains("stanford") {
            return CollegeStats(students: "17,000", acceptance: "3.7%")
        }
        
        if lowerName.contains("mit") {
            return CollegeStats(students: "11,900", acceptance: "3.2%")
        }
        
        if lowerName.contains("columbia") {
            return CollegeStats(students: "33,000", acceptance: "3.9%")
        }
        
        if lowerName.contains("duke") || lowerName.contains("dartmouth") {
            return CollegeStats(students: "15,500", acceptance: "6-8%")
        }
        
        if lowerName.contains("cornell") || lowerName.contains("brown") || lowerName.contains("penn") {
            return CollegeStats(students: "23,000", acceptance: "7-10%")
        }
        
        // Top Public Universities
        if lowerName.contains("berkeley") || lowerName == "uc berkeley" {
            return CollegeStats(students: "45,000", acceptance: "11%")
        }
        
        if lowerName.contains("ucla") {
            return CollegeStats(students: "46,000", acceptance: "9%")
        }
        
        if lowerName.contains("michigan") && lowerName.contains("ann arbor") {
            return CollegeStats(students: "47,000", acceptance: "18%")
        }
        
        if lowerName.contains("virginia") && !lowerName.contains("west") {
            return CollegeStats(students: "26,000", acceptance: "19%")
        }
        
        // Large State Universities
        if lowerName.contains("texas") && lowerName.contains("austin") {
            return CollegeStats(students: "52,000", acceptance: "29%")
        }
        
        if lowerName.contains("ohio state") {
            return CollegeStats(students: "68,000", acceptance: "53%")
        }
        
        if lowerName.contains("florida") && !lowerName.contains("florida state") {
            return CollegeStats(students: "56,000", acceptance: "23%")
        }
        
        if lowerName.contains("penn state") {
            return CollegeStats(students: "76,000", acceptance: "55%")
        }
        
        if lowerName.contains("arizona state") {
            return CollegeStats(students: "80,000", acceptance: "88%")
        }
        
        // Idaho Universities
        if lowerName.contains("boise state") {
            return CollegeStats(students: "26,000", acceptance: "84%")
        }
        
        if lowerName.contains("university of idaho") || lowerName == "university of idaho" {
            return CollegeStats(students: "11,500", acceptance: "74%")
        }
        
        if lowerName.contains("idaho state") {
            return CollegeStats(students: "12,000", acceptance: "100%")
        }
        
        // Tech Schools
        if lowerName.contains("caltech") {
            return CollegeStats(students: "2,400", acceptance: "2.7%")
        }
        
        if lowerName.contains("georgia tech") || lowerName.contains("georgia institute") {
            return CollegeStats(students: "40,000", acceptance: "16%")
        }
        
        if lowerName.contains("carnegie mellon") {
            return CollegeStats(students: "15,800", acceptance: "11%")
        }
        
        // International Universities
        if lowerName.contains("oxford") {
            return CollegeStats(students: "24,000", acceptance: "13%")
        }
        
        if lowerName.contains("cambridge") {
            return CollegeStats(students: "24,000", acceptance: "15%")
        }
        
        if lowerName.contains("tokyo") {
            return CollegeStats(students: "28,000", acceptance: "35%")
        }
        
        if lowerName.contains("melbourne") {
            return CollegeStats(students: "51,000", acceptance: "70%")
        }
        
        // Medium State Universities (Default for unmatched)
        if lowerName.contains("state") {
            return CollegeStats(students: "15,000-25,000", acceptance: "65-75%")
        }
        
        // Private Universities (Default for unmatched)
        if lowerName.contains("university") {
            return CollegeStats(students: "12,000-18,000", acceptance: "55-70%")
        }
        
        // Generic fallback
        return CollegeStats(students: "15,000", acceptance: "60%")
    }
}
