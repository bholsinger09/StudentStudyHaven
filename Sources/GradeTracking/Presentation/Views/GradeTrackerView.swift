import Core
import SwiftUI

public struct GradeTrackerView: View {
    @StateObject private var viewModel: GradeTrackerViewModel
    @State private var selectedClassId: String?
    
    public init(viewModel: GradeTrackerViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = viewModel.error {
                VStack {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    
                    Text("Error Loading Grades")
                        .font(.headline)
                    
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                    
                    Button("Try Again") {
                        Task {
                            await viewModel.loadGrades()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // GPA Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("📊 Your GPA")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            HStack(alignment: .center, spacing: 20) {
                                VStack(alignment: .center) {
                                    Text(String(format: "%.2f", viewModel.overallGPA))
                                        .font(.system(size: 36, weight: .bold))
                                    Text("out of 4.0")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    ProgressView(value: viewModel.overallGPA / 4.0)
                                        .tint(.blue)
                                }
                            }
                            .padding()
                            .background(Color(red: 0.95, green: 0.95, blue: 0.96))
                            .cornerRadius(12)
                        }
                        
                        // Classes Section
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("📚 Your Classes")
                                    .font(.headline)
                                Spacer()
                            }
                            
                            if viewModel.courseGrades.isEmpty {
                                Text("No classes or grades yet")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding()
                            } else {
                                classesListView
                            }
                        }
                        
                        // Graded Assignments Section
                        VStack(alignment: .leading, spacing: 12) {
                            GradesListView(
                                assignments: viewModel.allAssignments,
                                classes: viewModel.classes,
                                assignmentRepository: viewModel.assignmentRepository,
                                classRepository: viewModel.classRepository,
                                userId: viewModel.userId
                            )
                        }
                    }
                    .padding()
                }
                .navigationTitle("Grades")
                .toolbar {
                    ToolbarItem(placement: .automatic) {
                        NavigationLink(destination: AddAssignmentView(classRepository: viewModel.classRepository, userId: viewModel.userId, assignmentRepository: viewModel.assignmentRepository)) {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.loadGrades()
        }
    }
    
    private var classesListView: some View {
        ForEach(viewModel.courseGrades) { courseGrade in
            let className = viewModel.classes.first { $0.id == courseGrade.classId }?.courseCode ?? "Unknown"
            NavigationLink(value: courseGrade.classId) {
                ClassGradeCard(courseGrade: courseGrade)
            }
            .navigationDestination(for: String.self) { classId in
                ClassDetailView(classId: classId, className: className, classRepository: viewModel.classRepository, assignmentRepository: viewModel.assignmentRepository, userId: viewModel.userId)
            }
        }
    }
}

struct ClassGradeCard: View {
    let courseGrade: CourseGradeInfo
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text(String(format: "%.1f%%", courseGrade.currentGrade))
                        .font(.headline)
                    Text("Current Grade")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(courseGrade.letterGrade)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(gradeColor(courseGrade.letterGrade))
                }
            }
            
            ProgressView(value: courseGrade.currentGrade / 100.0)
                .tint(gradeColor(courseGrade.letterGrade))
        }
        .padding()
        .background(Color(red: 0.95, green: 0.95, blue: 0.96))
        .cornerRadius(12)
    }
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "A":
            return .green
        case "B":
            return .blue
        case "C":
            return .yellow
        case "D":
            return .orange
        default:
            return .red
        }
    }
}

#Preview {
    let sharedAssignmentRepo = MockAssignmentRepository()
    let sharedClassRepo = MockClassRepository()
    return NavigationStack {
        GradeTrackerView(
            viewModel: GradeTrackerViewModel(
                calculateGPAUseCase: CalculateGPAUseCase(
                    classRepository: sharedClassRepo,
                    assignmentRepository: sharedAssignmentRepo
                ),
                calculateClassGradeUseCase: CalculateClassGradeUseCase(
                    assignmentRepository: sharedAssignmentRepo
                ),
                getGradeAnalyticsUseCase: GetGradeAnalyticsUseCase(
                    classRepository: sharedClassRepo,
                    assignmentRepository: sharedAssignmentRepo
                ),
                classRepository: sharedClassRepo,
                assignmentRepository: sharedAssignmentRepo,
                userId: "test-user"
            )
        )
    }
}
