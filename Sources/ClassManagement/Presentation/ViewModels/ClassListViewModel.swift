import Foundation
import Core
import Combine

/// ViewModel for Class List screen
@MainActor
public final class ClassListViewModel: ObservableObject {
    @Published public var classes: [Class] = []
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    private let getClassesUseCase: GetClassesUseCase
    private let deleteClassUseCase: DeleteClassUseCase
    private let userId: UUID
    
    public init(
        getClassesUseCase: GetClassesUseCase,
        deleteClassUseCase: DeleteClassUseCase,
        userId: UUID
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
}
