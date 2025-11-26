import Foundation

/// Service for generating AI-powered fun facts about colleges
public class AIFunFactService {
    public static let shared = AIFunFactService()
    
    private init() {}
    
    /// Generate fun facts for a college using AI
    public func generateFunFacts(for collegeName: String) async throws -> [FunFact] {
        // Use macOS native NaturalLanguage framework for simple generation
        // In production, this would call OpenAI, Claude, or similar API
        
        let prompt = """
        Generate 5 interesting and accurate fun facts about \(collegeName).
        Each fact should have:
        1. A short title (2-4 words)
        2. A brief description (one sentence)
        3. An appropriate SF Symbol icon name
        
        Focus on: academic achievements, notable alumni, campus features, historical significance, and unique traditions.
        """
        
        // For now, return generated facts based on patterns
        // In production, replace with actual AI API call
        return try await generateFactsLocally(for: collegeName)
    }
    
    private func generateFactsLocally(for collegeName: String) async throws -> [FunFact] {
        // Simulate API delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        // Generate contextual facts based on college name patterns
        var facts: [FunFact] = []
        
        // Add facts based on college characteristics
        if collegeName.lowercased().contains("state") {
            facts.append(FunFact(
                icon: "flag.fill",
                title: "State Institution",
                description: "A proud public university serving the state's educational mission"
            ))
        }
        
        if collegeName.lowercased().contains("tech") || collegeName.lowercased().contains("institute") {
            facts.append(FunFact(
                icon: "cpu.fill",
                title: "Technical Excellence",
                description: "Renowned for engineering and technology programs"
            ))
        }
        
        // Always include these generic but positive facts
        if facts.count < 5 {
            facts.append(FunFact(
                icon: "graduationcap.fill",
                title: "Academic Excellence",
                description: "Committed to providing world-class education and research"
            ))
        }
        
        if facts.count < 5 {
            facts.append(FunFact(
                icon: "person.3.fill",
                title: "Diverse Community",
                description: "Students from diverse backgrounds creating a vibrant campus"
            ))
        }
        
        if facts.count < 5 {
            facts.append(FunFact(
                icon: "building.2.fill",
                title: "Modern Facilities",
                description: "State-of-the-art campus with cutting-edge resources"
            ))
        }
        
        if facts.count < 5 {
            facts.append(FunFact(
                icon: "trophy.fill",
                title: "Student Success",
                description: "Dedicated to helping every student achieve their goals"
            ))
        }
        
        if facts.count < 5 {
            facts.append(FunFact(
                icon: "network",
                title: "Strong Network",
                description: "Extensive alumni network supporting career opportunities"
            ))
        }
        
        return Array(facts.prefix(5))
    }
    
    /// Generate fun facts with caching
    private var cache: [String: [FunFact]] = [:]
    
    public func getFunFacts(for collegeName: String, useCache: Bool = true) async throws -> [FunFact] {
        if useCache, let cached = cache[collegeName] {
            return cached
        }
        
        let facts = try await generateFunFacts(for: collegeName)
        cache[collegeName] = facts
        return facts
    }
}
