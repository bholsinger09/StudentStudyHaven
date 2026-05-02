import Combine
import Core
import Foundation

/// Mock implementation of StudyGroupRepository for development and testing
public final class MockStudyGroupRepositoryImpl: StudyGroupRepositoryProtocol {
    private var studyGroups: [String: StudyGroup] = [:]
    private let studyGroupsSubject = CurrentValueSubject<[StudyGroup], Never>([])
    private let changesSubject = PassthroughSubject<DataChange<StudyGroup>, Never>()
    private var isObserving = false
    
    public init() {}
    
    public func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        return studyGroups.values.filter { $0.memberIds.contains(userId) }
    }
    
    public func getStudyGroup(by id: String) async throws -> StudyGroup {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let studyGroup = studyGroups[id] else {
            throw AppError.notFound( "Study group not found")
        }
        
        return studyGroup
    }
    
    public func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        var filtered = studyGroups.values.filter { $0.isPublic && $0.collegeId == collegeId }
        
        if let classId = classId {
            filtered = filtered.filter { $0.classId == classId }
        }
        
        return Array(filtered)
    }
    
    public func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        studyGroups[studyGroup.id] = studyGroup
        
        if isObserving {
            changesSubject.send(DataChange(type: .added, item: studyGroup))
            updateStudyGroupsSubject()
        }
        
        return studyGroup
    }
    
    public func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard studyGroups[studyGroup.id] != nil else {
            throw AppError.notFound( "Study group not found")
        }
        
        var updatedGroup = studyGroup
        updatedGroup.updatedAt = Date()
        studyGroups[studyGroup.id] = updatedGroup
        
        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: updatedGroup))
            updateStudyGroupsSubject()
        }
        
        return updatedGroup
    }
    
    public func deleteStudyGroup(id: String) async throws {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard let deletedGroup = studyGroups[id] else {
            throw AppError.notFound( "Study group not found")
        }
        
        studyGroups.removeValue(forKey: id)
        
        if isObserving {
            changesSubject.send(DataChange(type: .removed, item: deletedGroup))
            updateStudyGroupsSubject()
        }
    }
    
    public func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard var studyGroup = studyGroups[groupId] else {
            throw AppError.notFound( "Study group not found")
        }
        
        if !studyGroup.memberIds.contains(userId) {
            studyGroup.memberIds.append(userId)
            studyGroup.updatedAt = Date()
            studyGroups[groupId] = studyGroup
            
            if isObserving {
                changesSubject.send(DataChange(type: .modified, item: studyGroup))
                updateStudyGroupsSubject()
            }
        }
        
        return studyGroup
    }
    
    public func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)
        
        guard var studyGroup = studyGroups[groupId] else {
            throw AppError.notFound( "Study group not found")
        }
        
        studyGroup.memberIds.removeAll { $0 == userId }
        studyGroup.updatedAt = Date()
        studyGroups[groupId] = studyGroup
        
        if isObserving {
            changesSubject.send(DataChange(type: .modified, item: studyGroup))
            updateStudyGroupsSubject()
        }
        
        return studyGroup
    }
    
    // MARK: - Real-time listeners
    
    public func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        isObserving = true
        // Initial load
        Task {
            do {
                let initialGroups = try await getStudyGroups(for: userId)
                studyGroupsSubject.send(initialGroups)
            } catch {
                studyGroupsSubject.send([])
            }
        }
        return studyGroupsSubject.eraseToAnyPublisher()
    }
    
    public func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        isObserving = true
        return changesSubject.eraseToAnyPublisher()
    }
    
    public func stopObserving() {
        isObserving = false
    }
    
    // MARK: - Private helpers
    
    private func updateStudyGroupsSubject() {
        let allGroups = Array(studyGroups.values)
        studyGroupsSubject.send(allGroups)
    }
}
