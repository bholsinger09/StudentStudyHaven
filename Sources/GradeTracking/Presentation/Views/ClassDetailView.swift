import Core
import SwiftUI

public struct ClassDetailView: View {
    let classId: String
    let className: String
    let classRepository: ClassRepositoryProtocol
    let assignmentRepository: AssignmentRepositoryProtocol
    let userId: String
    @StateObject private var viewModel: ClassDetailGradesViewModel
    @State private var showAddAssignment = false
    
    public init(classId: String, className: String, classRepository: ClassRepositoryProtocol, assignmentRepository: AssignmentRepositoryProtocol, userId: String) {
        self.classId = classId
        self.className = className
        self.classRepository = classRepository
        self.assignmentRepository = assignmentRepository
        self.userId = userId
        
        _viewModel = StateObject(wrappedValue: ClassDetailGradesViewModel(
            classId: classId,
            className: className,
            calculateClassGradeUseCase: CalculateClassGradeUseCase(assignmentRepository: assignmentRepository),
            getAssignmentsForClassUseCase: GetAssignmentsForClassUseCase(assignmentRepository: assignmentRepository),
            calculateRequiredScoreUseCase: CalculateRequiredScoreUseCase(assignmentRepository: assignmentRepository),
            deleteAssignmentUseCase: DeleteAssignmentUseCase(assignmentRepository: assignmentRepository)
        ))
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Grade Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Current Grade")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .center) {
                            Text(String(format: "%.1f%%", viewModel.currentGrade))
                                .font(.system(size: 32, weight: .bold))
                            Text("Class Grade")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .center) {
                            Text(viewModel.letterGrade)
                                .font(.system(size: 32, weight: .bold))
                            Text("Letter Grade")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    ProgressView(value: viewModel.currentGrade / 100.0)
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                .cornerRadius(12)
                
                // What if calculator
                VStack(alignment: .leading, spacing: 12) {
                    Text("Target Score")
                        .font(.headline)
                    
                    if let required = viewModel.requiredScoreForA {
                        if required.isNaN {
                            Text("No pending assignments")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else if required > 100 {
                            Text("Need ≥100% on remaining assignments")
                                .font(.caption)
                                .foregroundColor(.orange)
                        } else {
                            Text("Need \(String(format: "%.1f%%", required)) on next assignment")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                .cornerRadius(12)
                
                // Assignments
                VStack(alignment: .leading, spacing: 12) {
                    Text("Assignments (\(viewModel.assignments.filter { $0.isSubmitted }.count)/\(viewModel.assignments.count))")
                        .font(.headline)
                    
                    ForEach(viewModel.assignments.sorted { $0.dueDate < $1.dueDate }) { assignment in
                        AssignmentRow(assignment: assignment)
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(className)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: { showAddAssignment = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddAssignment) {
            AddAssignmentView(classRepository: classRepository, userId: userId, assignmentRepository: assignmentRepository)
        }
        .task {
            await viewModel.loadGrades()
        }
    }
}

struct AssignmentRow: View {
    let assignment: Assignment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(assignment.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    HStack(spacing: 12) {
                        if let score = assignment.score {
                            Text("\(String(format: "%.0f", score))/\(String(format: "%.0f", assignment.maxScore))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Not submitted")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    if let percentage = assignment.scorePercentage {
                        Text(String(format: "%.0f%%", percentage))
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    
                    Text(assignment.type.rawValue)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            if assignment.isDuesoon && !assignment.isSubmitted {
                Text("Due: \(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        ClassDetailView(classId: UUID().uuidString, className: "CS 101", classRepository: MockClassRepository(), assignmentRepository: MockAssignmentRepository(), userId: "test-user")
    }
}
