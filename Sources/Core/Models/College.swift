import Foundation

/// Domain model representing a College/University
public struct College: Identifiable, Codable, Equatable {
    public let id: String
    public var name: String
    public var location: String
    public var funFacts: [FunFact]
    public var createdAt: Date

    public init(
        id: String = UUID().uuidString,
        name: String,
        location: String,
        funFacts: [FunFact] = [],
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.location = location
        self.funFacts = funFacts
        self.createdAt = createdAt
    }
}

/// Fun fact about a college
public struct FunFact: Identifiable, Codable, Equatable {
    public let id: String
    public var icon: String
    public var title: String
    public var description: String
    
    public init(
        id: String = UUID().uuidString,
        icon: String,
        title: String,
        description: String
    ) {
        self.id = id
        self.icon = icon
        self.title = title
        self.description = description
    }
}

// MARK: - Sample Colleges with Fun Facts

public extension College {
    static let sampleColleges: [College] = [
        College(
            name: "Idaho State University",
            location: "United States",
            funFacts: [
                FunFact(icon: "cross.case.fill", title: "Health Sciences Leader", description: "Top-ranked pharmacy and health professions programs"),
                FunFact(icon: "atom", title: "Nuclear Research", description: "Home to Idaho Accelerator Center for nuclear physics"),
                FunFact(icon: "building.2.fill", title: "Mountain Campus", description: "Located in beautiful Pocatello with mountain views"),
                FunFact(icon: "figure.run", title: "Mini Dome", description: "Historic Holt Arena, one of first covered stadiums"),
                FunFact(icon: "pawprint.fill", title: "Benny the Bengal", description: "Bengal tiger mascot since 1921")
            ]
        ),
        College(
            name: "University of Idaho",
            location: "United States",
            funFacts: [
                FunFact(icon: "leaf.fill", title: "Vandal Pride", description: "Home of the Fighting Vandals since 1917"),
                FunFact(icon: "tree.fill", title: "Arboretum Campus", description: "Beautiful tree-filled campus recognized as an arboretum"),
                FunFact(icon: "atom", title: "Research University", description: "Only Carnegie R1 research university in Idaho"),
                FunFact(icon: "building.columns.fill", title: "Historic", description: "Founded in 1889, Idaho's first university"),
                FunFact(icon: "lightbulb.fill", title: "Innovation", description: "Strong engineering and agricultural research programs")
            ]
        ),
        College(
            name: "Boise State University",
            location: "United States",
            funFacts: [
                FunFact(icon: "graduationcap.fill", title: "Academic Excellence", description: "A renowned institution with a rich history"),
                FunFact(icon: "person.3.fill", title: "Diverse Community", description: "Students from all backgrounds and countries"),
                FunFact(icon: "building.2.fill", title: "Beautiful Campus", description: "State-of-the-art facilities and resources"),
                FunFact(icon: "sportscourt.fill", title: "Blue Turf", description: "Famous blue football field, the only one in the world"),
                FunFact(icon: "trophy.fill", title: "Athletic Success", description: "Multiple conference championships in various sports")
            ]
        ),
        College(
            name: "Stanford University",
            location: "United States",
            funFacts: [
                FunFact(icon: "trophy.fill", title: "Innovation Hub", description: "Birthplace of Silicon Valley innovation"),
                FunFact(icon: "brain.head.profile", title: "Nobel Laureates", description: "84 Nobel Prize winners affiliated with Stanford"),
                FunFact(icon: "leaf.fill", title: "Sustainable Campus", description: "One of the most sustainable campuses in the world"),
                FunFact(icon: "lightbulb.fill", title: "Tech Giants", description: "Founded by alumni: Google, Yahoo, Netflix, Instagram"),
                FunFact(icon: "building.columns.fill", title: "Historic Architecture", description: "Beautiful Spanish Colonial Revival architecture")
            ]
        ),
        College(
            name: "MIT",
            location: "United States",
            funFacts: [
                FunFact(icon: "atom", title: "Scientific Excellence", description: "95 Nobel laureates among faculty and alumni"),
                FunFact(icon: "cpu.fill", title: "Tech Innovation", description: "Pioneered computer science and artificial intelligence"),
                FunFact(icon: "figure.walk", title: "Infinite Corridor", description: "251-meter hallway connects major buildings"),
                FunFact(icon: "puzzlepiece.fill", title: "Hacker Culture", description: "Famous for creative pranks called 'hacks'"),
                FunFact(icon: "brain.fill", title: "Research Powerhouse", description: "$4 billion annual research budget")
            ]
        ),
        College(
            name: "Harvard University",
            location: "United States",
            funFacts: [
                FunFact(icon: "calendar", title: "Oldest Institution", description: "Founded in 1636, oldest university in the US"),
                FunFact(icon: "books.vertical.fill", title: "Massive Library", description: "20 million volumes across 70 libraries"),
                FunFact(icon: "theatermasks.fill", title: "Cultural Impact", description: "Harvard students founded Facebook"),
                FunFact(icon: "building.columns.fill", title: "Historic Yard", description: "25-acre Harvard Yard, historic center of campus"),
                FunFact(icon: "dollarsign.circle.fill", title: "Largest Endowment", description: "$53 billion endowment, largest in the world")
            ]
        ),
        College(
            name: "UC Berkeley",
            location: "United States",
            funFacts: [
                FunFact(icon: "sparkles", title: "Element Discovery", description: "16 chemical elements discovered here"),
                FunFact(icon: "person.fill.checkmark", title: "Nobel Excellence", description: "107 Nobel laureates affiliated with Berkeley"),
                FunFact(icon: "figure.stand", title: "Free Speech Movement", description: "Birthplace of 1960s Free Speech Movement"),
                FunFact(icon: "server.rack", title: "Unix Origins", description: "BSD Unix operating system developed here"),
                FunFact(icon: "bell.fill", title: "Campanile Tower", description: "307-foot bell tower with 61 bells")
            ]
        ),
        College(
            name: "Oxford University",
            location: "United Kingdom",
            funFacts: [
                FunFact(icon: "hourglass", title: "Ancient History", description: "Teaching since 1096, second oldest university"),
                FunFact(icon: "theatermasks.fill", title: "Literary Legacy", description: "Educated Tolkien, C.S. Lewis, and Oscar Wilde"),
                FunFact(icon: "crown.fill", title: "Prime Ministers", description: "28 UK Prime Ministers attended Oxford"),
                FunFact(icon: "book.closed.fill", title: "Bodleian Library", description: "One of oldest libraries in Europe, 13 million items"),
                FunFact(icon: "building.columns.fill", title: "Harry Potter", description: "Multiple Harry Potter scenes filmed here")
            ]
        ),
        College(
            name: "University of Tokyo",
            location: "Japan",
            funFacts: [
                FunFact(icon: "building.2.fill", title: "Top Asian University", description: "Highest ranked university in Asia"),
                FunFact(icon: "person.2.fill", title: "Prime Ministers", description: "Educated 15 Japanese Prime Ministers"),
                FunFact(icon: "leaf.fill", title: "Cherry Blossoms", description: "Famous for beautiful cherry blossom season"),
                FunFact(icon: "cpu.fill", title: "Robotics Leader", description: "World-renowned robotics research"),
                FunFact(icon: "flag.fill", title: "Imperial Origins", description: "Founded in 1877 during Meiji era")
            ]
        ),
        College(
            name: "University of Melbourne",
            location: "Australia",
            funFacts: [
                FunFact(icon: "trophy.fill", title: "Top Australian Uni", description: "Australia's #1 ranked university"),
                FunFact(icon: "figure.australian.football", title: "Sports Excellence", description: "Strong tradition in Australian Rules football"),
                FunFact(icon: "theatermasks.fill", title: "Cultural Diversity", description: "Students from over 130 countries"),
                FunFact(icon: "building.columns.fill", title: "Historic Campus", description: "Beautiful Victorian-era architecture"),
                FunFact(icon: "brain.fill", title: "Research Impact", description: "Multiple breakthrough medical discoveries")
            ]
        )
    ]
    
    static let idahoState = sampleColleges[0]
    static let boiseState = sampleColleges[1]
    static let stanford = sampleColleges[2]
    static let mit = sampleColleges[3]
    static let harvard = sampleColleges[4]
}
