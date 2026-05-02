import XCTest
import Combine
@testable import Core

/// Mock implementation of StudyGroupRepositoryProtocol for testing
class MockStudyGroupRepository: StudyGroupRepositoryProtocol {
    var studyGroups: [StudyGroup] = []
    var error: Error?
    var getStudyGroupsCallCount = 0
    var createStudyGroupCallCount = 0
    var addMemberCallCount = 0
    var removeMemberCallCount = 0
    
    func getStudyGroups(for userId: String) async throws -> [StudyGroup] {
        getStudyGroupsCallCount += 1
        if let error = error { throw error }
        return studyGroups.filter { $0.memberIds.contains(userId) }
    }
    
    func getStudyGroup(by id: String) async throws -> StudyGroup {
        if let error = error { throw error }
        guard let group = studyGroups.first(where: { $0.id == id }) else {
            throw AppError.notFound("Study group not found")
        }
        return group
    }
    
    func getPublicStudyGroups(for collegeId: String, classId: String?) async throws -> [StudyGroup] {
        if let error = error { throw error }
        var filtered = studyGroups.filter { $0.isPublic && $0.collegeId == collegeId }
        if let classId = classId {
            filtered = filtered.filter { $0.classId == classId }
        }
        return filtered
    }
    
    func createStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        createStudyGroupCallCount += 1
        if let error = error { throw error }
        studyGroups.append(studyGroup)
        return studyGroup
    }
    
    func updateStudyGroup(_ studyGroup: StudyGroup) async throws -> StudyGroup {
        if let error = error { throw error }
        if let index = studyGroups.firstIndex(where: { $0.id == studyGroup.id }) {
            studyGroups[index] = studyGroup
            return studyGroup
        }
        throw AppError.notFound("Study group not found")
    }
    
    func deleteStudyGroup(id: String) async throws {
        if let error = error { throw error }
        studyGroups.removeAll { $0.id == id }
    }
    
    func addMember(groupId: String, userId: String) async throws -> StudyGroup {
        addMemberCallCount += 1
        if let error = error { throw error }
        guard let index = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            throw AppError.notFound("Study group not found")
        }
        var group = studyGroups[index]
        if !group.memberIds.contains(userId) {
            group.memberIds.append(userId)
        }
        studyGroups[index] = group
        return group
    }
    
    func removeMember(groupId: String, userId: String) async throws -> StudyGroup {
        removeMemberCallCount += 1
        if let error = error { throw error }
        guard let index = studyGroups.firstIndex(where: { $0.id == groupId }) else {
            throw AppError.notFound("Study group not found")
        }
        var group = studyGroups[index]
        group.memberIds.removeAll { $0 == userId }
        studyGroups[index] = group
        return group
    }
    
    func observeStudyGroups(for userId: String) -> AnyPublisher<[StudyGroup], Never> {
        fatalError("Not implemented in mock")
    }
    
    func observeStudyGroupChanges(for groupId: String) -> AnyPublisher<DataChange<StudyGroup>, Never> {
        fatalError("Not implemented in mock")
    }
    
    func stopObserving() {
        // No-op for mock
    }
}
