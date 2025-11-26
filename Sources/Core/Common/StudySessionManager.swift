import Foundation
import Combine

/// Manages Pomodoro-style study sessions
public final class StudySessionManager: ObservableObject {
    
    public enum SessionType {
        case focus(minutes: Int)
        case shortBreak(minutes: Int)
        case longBreak(minutes: Int)
        
        var duration: TimeInterval {
            switch self {
            case .focus(let minutes):
                return TimeInterval(minutes * 60)
            case .shortBreak(let minutes):
                return TimeInterval(minutes * 60)
            case .longBreak(let minutes):
                return TimeInterval(minutes * 60)
            }
        }
        
        var displayName: String {
            switch self {
            case .focus:
                return "Focus Time"
            case .shortBreak:
                return "Short Break"
            case .longBreak:
                return "Long Break"
            }
        }
    }
    
    public enum SessionState {
        case idle
        case running
        case paused
        case completed
    }
    
    public struct SessionConfiguration: Codable {
        public var focusDuration: Int = 25 // minutes
        public var shortBreakDuration: Int = 5
        public var longBreakDuration: Int = 15
        public var sessionsBeforeLongBreak: Int = 4
        public var autoStartBreaks: Bool = false
        public var autoStartFocus: Bool = false
        
        public init(
            focusDuration: Int = 25,
            shortBreakDuration: Int = 5,
            longBreakDuration: Int = 15,
            sessionsBeforeLongBreak: Int = 4,
            autoStartBreaks: Bool = false,
            autoStartFocus: Bool = false
        ) {
            self.focusDuration = focusDuration
            self.shortBreakDuration = shortBreakDuration
            self.longBreakDuration = longBreakDuration
            self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
            self.autoStartBreaks = autoStartBreaks
            self.autoStartFocus = autoStartFocus
        }
    }
    
    // MARK: - Published Properties
    
    @Published public private(set) var state: SessionState = .idle
    @Published public private(set) var currentType: SessionType
    @Published public private(set) var timeRemaining: TimeInterval = 0
    @Published public private(set) var completedSessions: Int = 0
    @Published public private(set) var currentSession: StudySession?
    
    // MARK: - Properties
    
    public var configuration: SessionConfiguration
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var pausedTime: Date?
    private var totalPausedDuration: TimeInterval = 0
    
    // MARK: - Initialization
    
    public init(configuration: SessionConfiguration = SessionConfiguration()) {
        self.configuration = configuration
        self.currentType = .focus(minutes: configuration.focusDuration)
        self.timeRemaining = currentType.duration
    }
    
    // MARK: - Session Control
    
    /// Start the current session
    public func start() {
        guard state != .running else { return }
        
        if state == .idle {
            sessionStartTime = Date()
            currentSession = StudySession(
                type: currentType,
                startTime: Date()
            )
        } else if state == .paused, let pausedTime = pausedTime {
            totalPausedDuration += Date().timeIntervalSince(pausedTime)
            self.pausedTime = nil
        }
        
        state = .running
        startTimer()
    }
    
    /// Pause the current session
    public func pause() {
        guard state == .running else { return }
        
        state = .paused
        pausedTime = Date()
        stopTimer()
    }
    
    /// Resume a paused session
    public func resume() {
        guard state == .paused else { return }
        start()
    }
    
    /// Skip to the next session (focus or break)
    public func skip() {
        completeCurrentSession()
        moveToNextSession()
    }
    
    /// Reset the current session
    public func reset() {
        stopTimer()
        state = .idle
        timeRemaining = currentType.duration
        sessionStartTime = nil
        pausedTime = nil
        totalPausedDuration = 0
        currentSession = nil
    }
    
    /// End the entire study session cycle
    public func endSession() {
        stopTimer()
        state = .idle
        completedSessions = 0
        currentType = .focus(minutes: configuration.focusDuration)
        timeRemaining = currentType.duration
        sessionStartTime = nil
        currentSession = nil
    }
    
    // MARK: - Private Methods
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
        timer?.tolerance = 0.1
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func timerTick() {
        guard timeRemaining > 0 else {
            completeCurrentSession()
            moveToNextSession()
            return
        }
        
        timeRemaining -= 1
    }
    
    private func completeCurrentSession() {
        stopTimer()
        state = .completed
        
        // Update current session
        if var session = currentSession {
            session.endTime = Date()
            session.actualDuration = session.endTime.timeIntervalSince(session.startTime) - totalPausedDuration
            session.completed = true
            currentSession = session
        }
        
        // Increment completed sessions for focus time
        if case .focus = currentType {
            completedSessions += 1
        }
    }
    
    private func moveToNextSession() {
        let shouldAutoStart: Bool
        
        switch currentType {
        case .focus:
            // Determine if it's time for a long break
            if completedSessions % configuration.sessionsBeforeLongBreak == 0 {
                currentType = .longBreak(minutes: configuration.longBreakDuration)
            } else {
                currentType = .shortBreak(minutes: configuration.shortBreakDuration)
            }
            shouldAutoStart = configuration.autoStartBreaks
            
        case .shortBreak, .longBreak:
            currentType = .focus(minutes: configuration.focusDuration)
            shouldAutoStart = configuration.autoStartFocus
        }
        
        timeRemaining = currentType.duration
        totalPausedDuration = 0
        pausedTime = nil
        
        if shouldAutoStart {
            state = .idle
            start()
        } else {
            state = .idle
        }
    }
    
    // MARK: - Computed Properties
    
    /// Progress as a percentage (0.0 to 1.0)
    public var progress: Double {
        let total = currentType.duration
        guard total > 0 else { return 0 }
        return 1.0 - (timeRemaining / total)
    }
    
    /// Formatted time remaining (MM:SS)
    public var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    /// Is the session currently active (running or paused)
    public var isActive: Bool {
        return state == .running || state == .paused
    }
    
    /// Time until long break
    public var sessionsUntilLongBreak: Int {
        let remaining = configuration.sessionsBeforeLongBreak - (completedSessions % configuration.sessionsBeforeLongBreak)
        return remaining == configuration.sessionsBeforeLongBreak ? 0 : remaining
    }
}

// MARK: - StudySession Model

public struct StudySession: Identifiable, Codable {
    public let id: String
    public var type: StudySessionManager.SessionType
    public var startTime: Date
    public var endTime: Date
    public var actualDuration: TimeInterval
    public var completed: Bool
    public var classId: String?
    public var notes: String?
    
    public init(
        id: String = UUID().uuidString,
        type: StudySessionManager.SessionType,
        startTime: Date,
        endTime: Date = Date(),
        actualDuration: TimeInterval = 0,
        completed: Bool = false,
        classId: String? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.type = type
        self.startTime = startTime
        self.endTime = endTime
        self.actualDuration = actualDuration
        self.completed = completed
        self.classId = classId
        self.notes = notes
    }
}

// MARK: - SessionType Codable

extension StudySessionManager.SessionType: Codable {
    enum CodingKeys: String, CodingKey {
        case type, minutes
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        let minutes = try container.decode(Int.self, forKey: .minutes)
        
        switch type {
        case "focus":
            self = .focus(minutes: minutes)
        case "shortBreak":
            self = .shortBreak(minutes: minutes)
        case "longBreak":
            self = .longBreak(minutes: minutes)
        default:
            self = .focus(minutes: 25)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .focus(let minutes):
            try container.encode("focus", forKey: .type)
            try container.encode(minutes, forKey: .minutes)
        case .shortBreak(let minutes):
            try container.encode("shortBreak", forKey: .type)
            try container.encode(minutes, forKey: .minutes)
        case .longBreak(let minutes):
            try container.encode("longBreak", forKey: .type)
            try container.encode(minutes, forKey: .minutes)
        }
    }
}
