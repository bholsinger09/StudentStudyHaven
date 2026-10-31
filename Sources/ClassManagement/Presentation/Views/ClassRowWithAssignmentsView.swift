import Core
import GradeTracking
import SwiftUI

/// Class row showing assignments with edit capability
struct ClassRowWithAssignmentsView: View {
    let classItem: Class
    let assignmentStats: AssignmentStats?
    let assignments: [Assignment]
    let assignmentRepository: AssignmentRepositoryProtocol
    let classRepository: ClassRepositoryProtocol
    let userId: String
    var onAssignmentUpdated: (() -> Void)? = nil
    
    @State private var editingAssignment: Assignment?
    @State private var showEditSheet = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(classItem.name)
                    .font(.headline)

                Spacer()

                Text("\(classItem.schedule.count) sessions")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }

            Text(classItem.courseCode)
                .font(.subheadline)
                .foregroundColor(.secondary)

            if let professor = classItem.professor {
                HStack(spacing: 4) {
                    Image(systemName: "person")
                        .font(.caption)
                    Text(professor)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }

            HStack(spacing: 6) {
                ForEach(uniqueDays, id: \.self) { day in
                    Text(day.abbreviation)
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            
            if let stats = assignmentStats, stats.total > 0 {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Assignments")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text("\(stats.completed)/\(stats.total)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // Assignment details list
                    if !assignments.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(assignments) { assignment in
                                Button(action: {
                                    editingAssignment = assignment
                                    showEditSheet = true
                                }) {
                                    HStack(spacing: 8) {
                                        if assignment.score != nil {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                                .font(.caption)
                                        } else if assignment.dueDate < Date() {
                                            Image(systemName: "exclamationmark.circle.fill")
                                                .foregroundColor(.red)
                                                .font(.caption)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                                .font(.caption)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(assignment.name)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(.black)
                                            
                                            HStack(spacing: 6) {
                                                Image(systemName: "calendar")
                                                    .font(.caption2)
                                                Text(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                                
                                                // Assignment type
                                                Image(systemName: assignment.type.icon)
                                                    .font(.caption2)
                                                Text(assignment.type.rawValue)
                                                    .font(.caption2)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if assignment.score != nil {
                                            Text(String(format: "%.0f%%", assignment.scorePercentage ?? 0))
                                                .font(.caption)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.blue)
                                        } else {
                                            Text("No grade")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.vertical, 6)
                                    .padding(.horizontal, 8)
                                    .background(Color(red: 0.98, green: 0.98, blue: 0.99))
                                    .cornerRadius(6)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 10)
                .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                .cornerRadius(8)
            } else if assignmentStats != nil && (assignmentStats?.total ?? 0) == 0 {
                Text("No assignments yet")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding(.vertical, 4)
        .sheet(isPresented: $showEditSheet) {
            if let assignment = editingAssignment {
                EditAssignmentView(
                    assignment: assignment,
                    classRepository: classRepository,
                    userId: userId,
                    assignmentRepository: assignmentRepository
                )
            }
        }
        .onChange(of: showEditSheet) { isShown in
            if !isShown {
                // When sheet is dismissed, refresh the assignments
                // Wait 400ms to ensure the 300ms network delay simulation completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    onAssignmentUpdated?()
                }
            }
        }
    }

    private var uniqueDays: [DayOfWeek] {
        let days = classItem.schedule.map { $0.dayOfWeek }
        return Array(Set(days)).sorted { $0.rawValue < $1.rawValue }
    }
}

extension AssignmentType {
    var icon: String {
        switch self {
        case .homework: return "doc.circle"
        case .quiz: return "questionmark.circle"
        case .exam: return "book.circle"
        case .project: return "briefcase.circle"
        case .other: return "star.circle"
        }
    }
}
