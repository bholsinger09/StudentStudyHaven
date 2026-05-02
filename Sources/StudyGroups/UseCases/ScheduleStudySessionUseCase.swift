import Core
import Foundation

/// Use case for scheduling a Study Session
public final class ScheduleStudySessionUseCase {
    private let studySessionRepository: GroupStudySessionRepositoryProtocol
    private let studyGroupRepository: StudyGroupRepositoryProtocol
    
    public init(
        studySessionRepository: GroupStudySessionRepositoryProtocol,
        studyGroupRepository: StudyGroupRepositoryProtocol
    ) {
        self.studySessionRepository = studySessionRepository
        self.studyGroupRepository = studyGroupRepository
    }
    
    public func execute(
        studyGroupId: String,
        title: String,
        description: String?,
        scheduledAt: Date,
        durationMinutes: Int,
        location: String?,
        isVirtual: Bool,
        meetingLink: String?,
        createdBy: String,
        maxAttendees: Int?
    ) async throws -> GroupStudySession {
        // Validate inputs
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AppError.invalidData("Session title cannot be empty")
        }
        
        guard !studyGroupId.isEmpty else {
            throw AppError.invalidData("Study group ID is required")
        }
        
        guard !createdBy.isEmpty else {
            throw AppError.invalidData("Creator user ID is required")
        }
        
        // Validate scheduled time is in the future
        guard scheduledAt > Date() else {
            throw AppError.invalidData("Session must be scheduled in the future")
        }
        
        // Validate duration
        guard durationMinutes > 0 else {
            throw AppError.invalidData("Duration must be positive")
        }
        
        // Virtual sessions must have a meeting link
        if isVirtual {
            guard let link = meetingLink, !link.isEmpty else {
                throw AppError.invalidData("Virtual sessions require a meeting link")
            }
        }
        
        // Validate maxAttendees if provided
        if let maxAttendees = maxAttendees {
            guard maxAttendees >= 1 else {
                throw AppError.invalidData("Session must allow at least 1 attendee")
            }
        }
        
        // Verify user is a member of the study group
        let studyGroup = try await studyGroupRepository.getStudyGroup(by: studyGroupId)
        guard studyGroup.isMember(createdBy) else {
            throw AppError.unauthorized
        }
        
        // Create study session with creator as first attendee
        let studySession = GroupStudySession(
            studyGroupId: studyGroupId,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description,
            scheduledAt: scheduledAt,
            durationMinutes: durationMinutes,
            location: location,
            isVirtual: isVirtual,
            meetingLink: meetingLink,
            createdBy: createdBy,
            attendeeIds: [createdBy], // Creator automatically attends
            maxAttendees: maxAttendees,
            status: .scheduled
        )
        
        return try await studySessionRepository.createStudySession(studySession)
    }
}
