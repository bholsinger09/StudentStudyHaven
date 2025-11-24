import Foundation
import Core
import Combine

/// ViewModel for Add/Edit Class screen
@MainActor
public final class ClassFormViewModel: ObservableObject {
    @Published public var name: String = ""
    @Published public var courseCode: String = ""
    @Published public var professor: String = ""
    @Published public var location: String = ""
    @Published public var timeSlots: [TimeSlot] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    @Published public var isSaved: Bool = false
    
    private let createClassUseCase: CreateClassUseCase
    private let updateClassUseCase: UpdateClassUseCase
    private let userId: UUID
    private var existingClass: Class?
    
    public init(
        createClassUseCase: CreateClassUseCase,
        updateClassUseCase: UpdateClassUseCase,
        userId: UUID,
        existingClass: Class? = nil
    ) {
        self.createClassUseCase = createClassUseCase
        self.updateClassUseCase = updateClassUseCase
        self.userId = userId
        self.existingClass = existingClass
        
        if let existing = existingClass {
            self.name = existing.name
            self.courseCode = existing.courseCode
            self.professor = existing.professor ?? ""
            self.location = existing.location ?? ""
            self.timeSlots = existing.schedule
        }
    }
    
    public func save() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let classItem = Class(
                id: existingClass?.id ?? UUID(),
                userId: userId,
                name: name,
                courseCode: courseCode,
                schedule: timeSlots,
                professor: professor.isEmpty ? nil : professor,
                location: location.isEmpty ? nil : location
            )
            
            if existingClass != nil {
                _ = try await updateClassUseCase.execute(classItem: classItem)
            } else {
                _ = try await createClassUseCase.execute(classItem: classItem)
            }
            
            isSaved = true
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to save class"
        }
        
        isLoading = false
    }
    
    public func addTimeSlot(_ timeSlot: TimeSlot) {
        timeSlots.append(timeSlot)
    }
    
    public func removeTimeSlot(at offsets: IndexSet) {
        timeSlots.remove(atOffsets: offsets)
    }
}
