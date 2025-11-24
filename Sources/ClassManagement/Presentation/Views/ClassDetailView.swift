import SwiftUI
import Core
import ClassManagement

/// Detailed view for a single class
public struct ClassDetailView: View {
    let classItem: Class
    @Environment(\.dismiss) private var dismiss
    @State private var showEditSheet = false
    
    public init(classItem: Class) {
        self.classItem = classItem
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text(classItem.name)
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text(classItem.courseCode)
                        .font(.title3)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Quick Info Cards
                HStack(spacing: 16) {
                    if let professor = classItem.professor {
                        InfoCard(icon: "person.fill", title: "Professor", value: professor)
                    }
                    
                    if let location = classItem.location {
                        InfoCard(icon: "mappin.circle.fill", title: "Location", value: location)
                    }
                }
                .padding(.horizontal)
                
                // Schedule Section
                if !classItem.schedule.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Schedule")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(classItem.schedule) { timeSlot in
                            TimeSlotRow(timeSlot: timeSlot)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                
                // Actions Section
                VStack(spacing: 12) {
                    NavigationLink(destination: Text("Notes for \(classItem.name)")) {
                        ActionButton(icon: "note.text", title: "View Notes", color: .blue)
                    }
                    
                    NavigationLink(destination: Text("Flashcards for \(classItem.name)")) {
                        ActionButton(icon: "rectangle.stack.fill", title: "Study Flashcards", color: .green)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showEditSheet = true }) {
                    Text("Edit")
                }
            }
        }
        .sheet(isPresented: $showEditSheet) {
            Text("Edit Class View")
        }
    }
}

/// Info card component
struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
    }
}

/// Time slot row component
struct TimeSlotRow: View {
    let timeSlot: Class.TimeSlot
    
    var body: some View {
        HStack {
            // Day badge
            Text(timeSlot.dayOfWeek.rawValue.prefix(3))
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(timeSlot.dayOfWeek.rawValue)
                    .font(.headline)
                
                HStack {
                    Text(timeSlot.startTime, style: .time)
                    Text("–")
                    Text(timeSlot.endTime, style: .time)
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "clock.fill")
                .foregroundColor(.blue)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

/// Action button component
struct ActionButton: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
            
            Text(title)
                .fontWeight(.semibold)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .foregroundColor(color)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}
