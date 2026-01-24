
import SwiftUI

struct MainProgressScreen: View {
    @ObservedObject var dataManager: GoalsDataManager
    @Binding var selectedGoal: Goal?
    @Binding var showCreateGoal: Bool
    @State private var searchText = ""
    @State private var selectedCategory: GoalCategory?
    @State private var filterStatus: FilterStatus = .all
    @State private var sortOption = SortOption.dateCreated
    
    enum FilterStatus: String, CaseIterable {
        case all = "All"
        case inProgress = "In Progress"
        case done = "Done"
    }
    
    enum SortOption: String, CaseIterable {
        case dateCreated = "Date"
        case progress = "Progress"
        case name = "Name"
    }
    
    var filteredGoals: [Goal] {
        var filtered = dataManager.goals
        
        switch filterStatus {
        case .all:
            break
        case .inProgress:
            filtered = filtered.filter { !$0.isDone }
        case .done:
            filtered = filtered.filter { $0.isDone }
        }
        
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
        
        switch sortOption {
        case .dateCreated:
            filtered.sort { $0.createdDate > $1.createdDate }
        case .progress:
            filtered.sort { $0.progress > $1.progress }
        case .name:
            filtered.sort { $0.name < $1.name }
        }
        
        return filtered
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.deepBlue, Color.cardBlue.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                
                if dataManager.goals.isEmpty {
                    EmptyStateView(showCreateGoal: $showCreateGoal)
                } else {
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 15) {
                                SummaryCard(
                                    title: "Total Goals",
                                    value: "\(dataManager.goals.count)",
                                    icon: "flag.fill",
                                    color: .blueAccent
                                )
                                
                                SummaryCard(
                                    title: "Completed",
                                    value: "\(dataManager.goals.filter { $0.isDone }.count)",
                                    icon: "checkmark.circle.fill",
                                    color: .mintAccent
                                )
                                
                                SummaryCard(
                                    title: "In Progress",
                                    value: "\(dataManager.goals.filter { !$0.isDone }.count)",
                                    icon: "chart.line.uptrend.xyaxis",
                                    color: .warningOrange
                                )
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(FilterStatus.allCases, id: \.self) { status in
                                    StatusChip(
                                        status: status,
                                        isSelected: filterStatus == status,
                                        action: { filterStatus = status }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 10)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                CategoryChip(
                                    category: nil,
                                    isSelected: selectedCategory == nil,
                                    action: { selectedCategory = nil }
                                )
                                
                                ForEach(GoalCategory.allCases, id: \.self) { category in
                                    CategoryChip(
                                        category: category,
                                        isSelected: selectedCategory == category,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 10)
                        
                        ScrollView {
                            VStack(spacing: 15) {
                                ForEach(filteredGoals) { goal in
                                    ImprovedGoalCard(goal: goal, dataManager: dataManager)
                                        .onTapGesture {
                                            selectedGoal = goal
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 20)
                        }
                    }
                }
            }
            .navigationTitle("My Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showCreateGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.mintAccent)
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        ForEach(SortOption.allCases, id: \.self) { option in
                            Button(action: { sortOption = option }) {
                                HStack {
                                    Text(option.rawValue)
                                    if sortOption == option {
                                        Image(systemName: "checkmark")
                                    }
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                            .foregroundColor(.primaryText)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search goals...")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatusChip: View {
    let status: MainProgressScreen.FilterStatus
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(status.rawValue)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .deepBlue : .primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected ?
                        AnyView(LinearGradient(
                            colors: [Color.mintAccent, Color.blueAccent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )) :
                        AnyView(Color.cardBlue)
                )
                .cornerRadius(20)
        }
    }
}

struct SummaryCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondaryText)
        }
        .padding()
        .frame(width: 130)
        .background(Color.cardBlue)
        .cornerRadius(16)
    }
}

struct CategoryChip: View {
    let category: GoalCategory?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let category = category {
                    Image(systemName: category.icon)
                        .font(.system(size: 14))
                    Text(category.rawValue)
                        .font(.system(size: 14, weight: .medium))
                } else {
                    Text("All")
                        .font(.system(size: 14, weight: .medium))
                }
            }
            .foregroundColor(isSelected ? .deepBlue : .primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(
                isSelected ?
                    AnyView(LinearGradient(
                        colors: [Color.mintAccent, Color.blueAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )) :
                    AnyView(Color.cardBlue)
            )
            .cornerRadius(20)
        }
    }
}

struct EmptyStateView: View {
    @Binding var showCreateGoal: Bool
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.mintAccent.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                
                Text("🐠")
                    .font(.system(size: 100))
                    .rotationEffect(.degrees(rotation))
            }
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 10.0)
                        .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.2
                }
            }
            
            VStack(spacing: 15) {
                Text("Start Your Journey")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primaryText)
                
                Text("Create your first goal and watch it grow like a fish")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button(action: { showCreateGoal = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create First Goal")
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.deepBlue)
                .frame(width: 250)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.mintAccent, Color.blueAccent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(16)
            }
            
            Spacer()
        }
    }
}
