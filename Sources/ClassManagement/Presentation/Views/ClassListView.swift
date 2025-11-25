import ClassManagement
import Core
import SwiftUI

/// Class list view
public struct ClassListView: View {
    @StateObject private var viewModel: ClassListViewModel
    @State private var showingAddClass = false

    private let createClassUseCase: CreateClassUseCase
    private let updateClassUseCase: UpdateClassUseCase
    private let userId: String

    public init(
        viewModel: ClassListViewModel,
        createClassUseCase: CreateClassUseCase,
        updateClassUseCase: UpdateClassUseCase,
        userId: String
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
        self.createClassUseCase = createClassUseCase
        self.updateClassUseCase = updateClassUseCase
        self.userId = userId
    }

    public var body: some View {
        contentView
            .navigationTitle("Classes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingAddClass = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddClass) {
                NavigationStack {
                    AddClassView(
                        viewModel: ClassFormViewModel(
                            createClassUseCase: createClassUseCase,
                            updateClassUseCase: updateClassUseCase,
                            userId: userId
                        ))
                }
            }
            .task {
                await viewModel.loadClasses()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: {
                if let error = viewModel.errorMessage {
                    Text(error)
                }
            }
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading {
            ProgressView()
        } else if viewModel.classes.isEmpty {
            EmptyClassesView {
                showingAddClass = true
            }
        } else {
            List {
                // Today's Classes Section
                if !viewModel.todayClasses.isEmpty {
                    Section("Today's Classes") {
                        ForEach(viewModel.upcomingClasses) { classItem in
                            NavigationLink(destination: ClassDetailView(classItem: classItem)) {
                                TodayClassRow(classItem: classItem)
                            }
                        }
                    }
                }

                // All Classes Section
                Section("All Classes") {
                    ForEach(viewModel.classes) { classItem in
                        NavigationLink(destination: ClassDetailView(classItem: classItem)) {
                            ClassRowView(classItem: classItem)
                        }
                    }
                    .onDelete { indexSet in
                        Task {
                            await viewModel.deleteClass(at: indexSet)
                        }
                    }
                }
            }
        }
    }
}

/// Today's class row with next class time
struct TodayClassRow: View {
    let classItem: Class

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Class indicator dot
                Circle()
                    .fill(Color.blue)
                    .frame(width: 12, height: 12)

                VStack(alignment: .leading, spacing: 4) {
                    Text(classItem.name)
                        .font(.headline)

                    Text(classItem.courseCode)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if let nextTime = classItem.nextClassTime {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(nextTime, style: .time)
                            .font(.headline)
                            .foregroundColor(.blue)

                        Text(timeUntil(nextTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Today's schedule
            if let todaySchedule = todaySchedule {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption)
                    ForEach(todaySchedule, id: \.startTime) { slot in
                        Text("\(slot.startTime, style: .time) - \(slot.endTime, style: .time)")
                            .font(.caption)
                    }
                }
                .foregroundColor(.secondary)
            }

            if let location = classItem.location {
                HStack(spacing: 4) {
                    Image(systemName: "location")
                        .font(.caption)
                    Text(location)
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private var todaySchedule: [Class.TimeSlot]? {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek = DayOfWeek.fromWeekday(today)

        let slots = classItem.schedule.filter { $0.dayOfWeek == dayOfWeek }
        return slots.isEmpty ? nil : slots
    }

    private func timeUntil(_ date: Date) -> String {
        let interval = date.timeIntervalSinceNow
        let minutes = Int(interval / 60)

        if minutes < 60 {
            return "in \(minutes)m"
        } else {
            let hours = minutes / 60
            return "in \(hours)h"
        }
    }
}

/// Regular class row
struct ClassRowView: View {
    let classItem: Class

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(classItem.name)
                    .font(.headline)

                Spacer()

                // Schedule badge
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

            // Weekly schedule preview
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
        }
        .padding(.vertical, 4)
    }

    private var uniqueDays: [DayOfWeek] {
        let days = classItem.schedule.map { $0.dayOfWeek }
        return Array(Set(days)).sorted { $0.rawValue < $1.rawValue }
    }
}

/// Empty state for classes
struct EmptyClassesView: View {
    let onCreate: () -> Void

    var body: some View {
        ZStack {
            // Black background
            Color.black
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 70))
                    .foregroundColor(Color(red: 0.73, green: 0.33, blue: 0.83))

                VStack(spacing: 8) {
                    Text("No Classes Yet")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("Add your classes to keep track of your schedule")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                Button(action: onCreate) {
                    Label("Add Class", systemImage: "plus")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color(red: 0.9, green: 0.4, blue: 0.5))
                        .padding()
                        .frame(maxWidth: 200)
                        .background(Color(red: 0.0, green: 0.2, blue: 0.4))
                        .cornerRadius(12)
                        .shadow(
                            color: Color(red: 0.0, green: 0.2, blue: 0.4).opacity(0.3), radius: 8,
                            x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

extension DayOfWeek {
    var abbreviation: String {
        switch self {
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        case .sunday: return "Sun"
        }
    }
}

extension Class {
    var todayClasses: [Class.TimeSlot] {
        let today = Calendar.current.component(.weekday, from: Date())
        let dayOfWeek = DayOfWeek.fromWeekday(today)

        return schedule.filter { $0.dayOfWeek == dayOfWeek }
    }
}
