import Combine
import Core
import Foundation

/// ViewModel for Class List screen
@MainActor
public final class ClassListViewModel: ObservableObject {
    @Published public var classes: [Class] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?

    private let getClassesUseCase: GetClassesUseCase
    private let deleteClassUseCase: DeleteClassUseCase
    private let userId: String

    public init(
        getClassesUseCase: GetClassesUseCase,
        deleteClassUseCase: DeleteClassUseCase,
        userId: String
    ) {
        self.getClassesUseCase = getClassesUseCase
        self.deleteClassUseCase = deleteClassUseCase
        self.userId = userId
    }

    public func loadClasses() async {
        isLoading = true
        errorMessage = nil

        do {
            classes = try await getClassesUseCase.execute(userId: userId)
        } catch let error as AppError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Failed to load classes"
        }

        isLoading = false
    }

    public func deleteClass(at offsets: IndexSet) async {
        for index in offsets {
            let classItem = classes[index]
            do {
                try await deleteClassUseCase.execute(classId: classItem.id)
                classes.remove(at: index)
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
