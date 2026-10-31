import Core
import SwiftUI

/// View showing all assignments that have grades
public struct GradesListView: View {
    let assignments: [Assignment]
    let classes: [Class]
    let assignmentRepository: AssignmentRepositoryProtocol
    let classRepository: ClassRepositoryProtocol
    let userId: String
    
    @State private var editingAssignment: Assignment?
    @State private var showEditSheet = false
    @State private var selectedTypeFilter: AssignmentType? = nil
    
    var gradedAssignments: [Assignment] {
        var filtered = assignments.filter { $0.score != nil }.sorted { $0.dueDate > $1.dueDate }
        if let selectedType = selectedTypeFilter {
            filtered = filtered.filter { $0.type == selectedType }
        }
        return filtered
    }
    
    func classNameFor(_ classId: String) -> String {
        classes.first { $0.id == classId }?.courseCode ?? "Unknown"
    }
    
    public var body: some View {
        if gradedAssignments.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "gradebook")
                    .font(.system(size: 48))
                    .foregroundColor(.gray)
                
                Text("No Graded Assignments Yet")
                    .font(.headline)
                
                Text("As you receive grades on assignments, they'll appear here")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 0.98, green: 0.98, blue: 0.99))
        } else {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Graded Assignments")
                        .font(.headline)
                    
                    Picker("Filter by Type", selection: $selectedTypeFilter) {
                        Text("All Types").tag(nil as AssignmentType?)
                        ForEach(AssignmentType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type as AssignmentType?)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal)
                
                VStack(spacing: 8) {
                    ForEach(gradedAssignments) { assignment in
                        Button(action: {
                            editingAssignment = assignment
                            showEditSheet = true
                        }) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(assignment.name)
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        
                                        Text(classNameFor(assignment.classId))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(4)
                                        
                                        Spacer()
                                    }
                                    
                                    HStack(spacing: 8) {
                                        Image(systemName: "calendar")
                                            .font(.caption2)
                                        Text(assignment.dueDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Image(systemName: assignment.type.icon)
                                            .font(.caption2)
                                        Text(assignment.type.rawValue)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 4) {
                                    if let score = assignment.score, let percentage = assignment.scorePercentage {
                                        VStack(alignment: .trailing, spacing: 2) {
                                            Text(String(format: "%.0f%%", percentage))
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(percentageColor(percentage))
                                            
                                            Text(String(format: "%.0f/%.0f pts", score, assignment.maxScore))
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding(.vertical)
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
        }
    }
    
    private func percentageColor(_ percentage: Double) -> Color {
        if percentage >= 90 { return .green }
        if percentage >= 80 { return .blue }
        if percentage >= 70 { return .orange }
        return .red
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
