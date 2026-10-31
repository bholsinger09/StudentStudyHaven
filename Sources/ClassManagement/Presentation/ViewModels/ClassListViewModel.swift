import Combine
import Core
import GradeTracking
import Foundation

/// ViewModel for Class List screen
@MainActor
public final class ClassListViewModel: ObservableObject {
    @Published public var classes: [Class] = []
    @Published public var assignmentStats: [String: AssignmentStats] = [:]
    @Published public var assignmentsByClass: [String: [Assignment]] = [:]
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let getClassesUseCase: GetClassesUseCase
    private let deleteClassUseCase: DeleteClassUseCase
    private let getAssignmentsForClassUseCase: GetAssignmentsForClassUseCase
    private let userId: String

    public init(
        getClassesUseCase: GetClassesUseCase,
        deleteClassUseCase: DeleteClassUseCase,
        getAssignmentsForClassUseCase: GetAssignmentsForClassUseCase,
        userId: String
    ) {
        self.getClassesUseCase = getClassesUseCase
        self.deleteClassUseCase = deleteClassUseCase
        self.getAssignmentsForClassUseCase = getAssignmentsForClassUseCase
        self.userId = userId
    }

    public func loadClasses() async {
        isLoading = true
        errorMessage = nil

        do {
            classes = try await getClassesUseCase.execute(userId: userId)
            
            // Load assignment stats and details for each class
            await loadAssignmentData()
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load classes"
        }

        isLoading = false
    }
    
    public func loadAssignmentData() async {
        var stats: [String: AssignmentStats] = [:]
        var assignments: [String: [Assignment]] = [:]
        
        for classItem in classes {
            do {
                let classAssignments = try await getAssignmentsForClassUseCase.execute(classId: classItem.id)
                assignments[classItem.id] = classAssignments.sorted { $0.dueDate < $1.dueDate }
                let statForClass = calculateStats(for: classItem.id, assignments: classAssignments)
                stats[classItem.id] = statForClass
            } catch {
                // If we can't load assignments, provide empty stats
                stats[classItem.id] = AssignmentStats(classId: classItem.id)
                assignments[classItem.id] = []
            }
        }
        
        assignmentStats = stats
        assignmentsByClass = assignments
    }
    
    private func calculateStats(for classId: String, assignments: [Assignment]) -> AssignmentStats {
        let now = Date()
        let oneWeekLater = Calendar.current.date(byAdding: .day, value: 7, to: now) ?? Date()
        
        var completed = 0
        var notSubmitted = 0
        var expired = 0
        var currentDue = 0
        var upcoming = 0
        
        for assignment in assignments {
            // Count by submission status
            if assignment.score != nil {
                completed += 1
            } else {
                notSubmitted += 1
            }
            
            // Count by due date relative to today
            if assignment.dueDate < now {
                // Past due
                if assignment.score == nil {
                    expired += 1
                }
            } else if assignment.dueDate <= oneWeekLater {
                // Due within this week
                currentDue += 1
            } else {
                // More than a week away
                upcoming += 1
            }
        }
        
        return AssignmentStats(
            classId: classId,
            total: assignments.count,
            completed: completed,
            notSubmitted: notSubmitted,
            expired: expired,
            currentDue: currentDue,
            upcoming: upcoming
        )
    }

    public func deleteClass(at offsets: IndexSet) async {
        for index in offsets {
            let classItem = classes[index]
            do {
                try await deleteClassUseCase.execute(classId: classItem.id)
                classes.remove(at: index)
                assignmentStats.removeValue(forKey: classItem.id)
            } catch let error as AppError {
                errorMessage = error.localizedDescription
            } catch {
                errorMessage = "Failed to delete class"
            }
        }
    }

    public var todayClasses: [Class] {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek = DayOfWeek.fromWeekday(today)

        return classes.filter { classItem in
            classItem.schedule.contains { $0.dayOfWeek == dayOfWeek }
        }
    }

    public var upcomingClasses: [Class] {
        todayClasses.sorted { class1, class2 in
            guard let time1 = class1.nextClassTime,
                let time2 = class2.nextClassTime
            else {
                return false
            }
            return time1 < time2
        }
    }
}

extension DayOfWeek {
    static func fromWeekday(_ weekday: Int) -> DayOfWeek {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .monday
        }
    }
}

extension Class {
    var nextClassTime: Date? {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek = DayOfWeek.fromWeekday(today)

        return
            schedule
            .filter { $0.dayOfWeek == dayOfWeek }
            .map { $0.startTime }
            .sorted()
            .first { $0 > Date() }
    }
}
