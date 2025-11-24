import SwiftUI
import Core
import Authentication

/// College selection view for registration
public struct CollegeSelectionView: View {
    @StateObject private var viewModel: CollegeSelectionViewModel
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: CollegeSelectionViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search colleges...", text: $viewModel.searchQuery)
                        .textFieldStyle(.plain)
                    
                    if !viewModel.searchQuery.isEmpty {
                        Button(action: { viewModel.searchQuery = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
            .padding()
            
            Divider()
            
            // College List
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.filteredColleges.isEmpty {
                    EmptyCollegeState(hasSearch: !viewModel.searchQuery.isEmpty)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.filteredColleges) { college in
                                CollegeRow(
                                    college: college,
                                    isSelected: viewModel.selectedCollege?.id == college.id
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    viewModel.selectCollege(college)
                                }
                                
                                Divider()
                                    .padding(.leading, 16)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select College")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .disabled(viewModel.selectedCollege == nil)
                }
            }
            .task {
                await viewModel.loadColleges()
            }
        }
    }
}

/// ViewModel for college selection
@MainActor
public class CollegeSelectionViewModel: ObservableObject {
    @Published public var colleges: [College] = []
    @Published public var searchQuery: String = ""
    @Published public var selectedCollege: College?
    @Published public var isLoading: Bool = false
    @Published public var errorMessage: String?
    
    public var filteredColleges: [College] {
        if searchQuery.isEmpty {
            return colleges
        }
        return colleges.filter {
            $0.name.localizedCaseInsensitiveContains(searchQuery) ||
            $0.location.localizedCaseInsensitiveContains(searchQuery)
        }
    }
    
    public init() {}
    
    public func loadColleges() async {
        isLoading = true
        errorMessage = nil
        
        // Simulate loading colleges
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Mock data for demonstration
        colleges = [
            College(name: "Stanford University", location: "Stanford, CA"),
            College(name: "Harvard University", location: "Cambridge, MA"),
            College(name: "MIT", location: "Cambridge, MA"),
            College(name: "UC Berkeley", location: "Berkeley, CA"),
            College(name: "UCLA", location: "Los Angeles, CA"),
            College(name: "Yale University", location: "New Haven, CT"),
            College(name: "Princeton University", location: "Princeton, NJ"),
            College(name: "Columbia University", location: "New York, NY"),
            College(name: "University of Chicago", location: "Chicago, IL"),
            College(name: "Caltech", location: "Pasadena, CA")
        ]
        
        isLoading = false
    }
    
    public func selectCollege(_ college: College) {
        selectedCollege = college
    }
}

/// College row component
struct CollegeRow: View {
    let college: College
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // College Icon
            ZStack {
                Circle()
                    .fill(isSelected ? Color.blue : Color.blue.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: "building.columns.fill")
                    .foregroundColor(isSelected ? .white : .blue)
                    .font(.title3)
            }
            
            // College Info
            VStack(alignment: .leading, spacing: 4) {
                Text(college.name)
                    .font(.headline)
                
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                    Text(college.location)
                        .font(.subheadline)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Selection Indicator
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.05) : Color.clear)
    }
}

/// Empty state for college search
struct EmptyCollegeState: View {
    let hasSearch: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "building.columns")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text(hasSearch ? "No Colleges Found" : "Loading Colleges")
                .font(.headline)
            
            Text(hasSearch ? "Try a different search term" : "Please wait while we load colleges")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// College detail view (optional)
public struct CollegeDetailView: View {
    let college: College
    
    public init(college: College) {
        self.college = college
    }
    
    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .center, spacing: 12) {
                    Image(systemName: "building.columns.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.blue)
                    
                    Text(college.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    HStack {
                        Image(systemName: "location.fill")
                        Text(college.location)
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.blue.opacity(0.1), .blue.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .cornerRadius(16)
                
                // Info Sections
                InfoSection(
                    icon: "info.circle.fill",
                    title: "About",
                    content: "Information about \(college.name) would appear here."
                )
                
                InfoSection(
                    icon: "person.3.fill",
                    title: "Student Body",
                    content: "Student population and demographics information."
                )
                
                InfoSection(
                    icon: "book.fill",
                    title: "Academics",
                    content: "Academic programs and majors offered."
                )
            }
            .padding()
        }
        .navigationTitle(college.name)
    }
}

/// Info section component
struct InfoSection: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            
            Text(content)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}
