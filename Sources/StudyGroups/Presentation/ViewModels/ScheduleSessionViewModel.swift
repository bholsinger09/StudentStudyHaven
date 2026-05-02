import Combine
import Core
import Foundation

/// ViewModel for scheduling a study session
@MainActor
public final class ScheduleSessionViewModel: ObservableObject {
    @Published public var title: String = ""
    @Published public var description: String = ""
    @Published public var scheduledDate: Date = Date().addingTimeInterval(3600) // 1 hour from now
    @Published public var durationMinutes: Int = 60
    @Published public var location: String = ""
    @Published public var isVirtual: Bool = false
    @Published public var meetingLink: String = ""
    @Published public var maxAttendees: String = ""
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let studyGroupId: String
    private let userId: String
    private let scheduleStudySessionUseCase: ScheduleStudySessionUseCase
    
    public var onSessionScheduled: ((GroupStudySession) -> Void)?
    
    public init(
        studyGroupId: String,
        userId: String,
        scheduleStudySessionUseCase: ScheduleStudySessionUseCase
    ) {
        self.studyGroupId = studyGroupId
        self.userId = userId
        self.scheduleStudySessionUseCase = scheduleStudySessionUseCase
    }
    
    public var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        (!isVirtual || !meetingLink.isEmpty)
    }
    
    public func scheduleSession() async -> Bool {
        guard isValid else {
            errorMessage = "Please fill in all required fields"
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let maxAttendeesInt = maxAttendees.isEmpty ? nil : Int(maxAttendees)
            
            let session = try await scheduleStudySessionUseCase.execute(
                studyGroupId: studyGroupId,
                title: title,
                description: description.isEmpty ? nil : description,
                scheduledAt: scheduledDate,
                durationMinutes: durationMinutes,
                location: location.isEmpty ? nil : location,
                isVirtual: isVirtual,
                meetingLink: meetingLink.isEmpty ? nil : meetingLink,
                createdBy: userId,
                maxAttendees: maxAttendeesInt
            )
            
            onSessionScheduled?(session)
            isLoading = false
            return true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        } catch {
            errorMessage = "Failed to schedule session"
            isLoading = false
            return false
        }
    }
    
    public func reset() {
        title = ""
        description = ""
        scheduledDate = Date().addingTimeInterval(3600)
        durationMinutes = 60
        location = ""
        isVirtual = false
        meetingLink = ""
        maxAttendees = ""
        errorMessage = nil
    }
}
