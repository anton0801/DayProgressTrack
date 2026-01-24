
import SwiftUI

struct StatisticsScreen: View {
    let goals: [Goal]
    @State private var animatedProgress: Double = 0
    
    var totalProgress: Double {
        guard !goals.isEmpty else { return 0 }
        return goals.map { $0.progress }.reduce(0, +) / Double(goals.count)
    }
    
    var completedCount: Int {
        goals.filter { $0.isDone }.count
    }
    
    var inProgressCount: Int {
        goals.filter { !$0.isDone }.count
    }
    
    var averageStreak: Double {
        guard !goals.isEmpty else { return 0 }
        return Double(goals.map { $0.streak }.reduce(0, +)) / Double(goals.count)
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Main Stats Cards
                        HStack(spacing: 15) {
                            StatisticCard(
                                title: "Avg Progress",
                                value: "\(Int(totalProgress * 100))%",
                                icon: "chart.pie.fill",
                                color: .blueAccent
                            )
                            
                            StatisticCard(
                                title: "Avg Streak",
                                value: "\(Int(averageStreak)) days",
                                icon: "flame.fill",
                                color: .warningOrange
                            )
                        }
                        .padding(.horizontal)
                        
                        // Overall Progress Circle
                        VStack(spacing: 15) {
                            Text("Overall Progress")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.cardBlue.opacity(0.3), lineWidth: 25)
                                    .frame(width: 200, height: 200)
                                
                                Circle()
                                    .trim(from: 0, to: animatedProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color.mintAccent, Color.blueAccent],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 25, lineCap: .round)
                                    )
                                    .frame(width: 200, height: 200)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 5) {
                                    Text("\(Int(totalProgress * 100))%")
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(.primaryText)
                                    Text("Complete")
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.2)) {
                                    animatedProgress = totalProgress
                                }
                            }
                            
                            HStack(spacing: 30) {
                                VStack(spacing: 5) {
                                    Text("\(completedCount)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.mintAccent)
                                    Text("Completed")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondaryText)
                                }
                                
                                VStack(spacing: 5) {
                                    Text("\(inProgressCount)")
                                        .font(.system(size: 32, weight: .bold))
                                        .foregroundColor(.warningOrange)
                                    Text("In Progress")
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                        }
                        .padding(.vertical, 25)
                        .frame(maxWidth: .infinity)
                        .background(Color.cardBlue)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Category Breakdown
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Image(systemName: "folder.fill")
                                    .foregroundColor(.mintAccent)
                                Text("Goals by Category")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primaryText)
                            }
                            .padding(.horizontal)
                            
                            ForEach(GoalCategory.allCases, id: \.self) { category in
                                let categoryGoals = goals.filter { $0.category == category }
                                if !categoryGoals.isEmpty {
                                    ImprovedCategoryRow(
                                        category: category,
                                        count: categoryGoals.count,
                                        completed: categoryGoals.filter { $0.isDone }.count,
                                        progress: categoryGoals.map { $0.progress }.reduce(0, +) / Double(categoryGoals.count)
                                    )
                                }
                            }
                        }
                        .padding(.vertical, 20)
                        .frame(maxWidth: .infinity)
                        .background(Color.cardBlue)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        // Top Streaks
                        if !goals.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.warningOrange)
                                    Text("Top Streaks")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primaryText)
                                }
                                .padding(.horizontal)
                                
                                ForEach(goals.sorted(by: { $0.bestStreak > $1.bestStreak }).prefix(5)) { goal in
                                    StreakRow(goal: goal)
                                }
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(Color.cardBlue)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct StatisticCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
                Spacer()
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primaryText)
            
            Text(title)
                .font(.system(size: 13))
                .foregroundColor(.secondaryText)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.cardBlue)
        .cornerRadius(16)
    }
}

struct ImprovedCategoryRow: View {
    let category: GoalCategory
    let count: Int
    let completed: Int
    let progress: Double
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(category.color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: category.icon)
                    .font(.system(size: 20))
                    .foregroundColor(category.color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(category.rawValue)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primaryText)
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Text("\(count)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.blueAccent)
                        Text("total")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                    }
                    
                    HStack(spacing: 4) {
                        Text("\(completed)")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.mintAccent)
                        Text("done")
                            .font(.system(size: 12))
                            .foregroundColor(.secondaryText)
                    }
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(Int(progress * 100))%")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(category.color)
                
                ImprovedProgressBar(progress: progress, color: category.color)
                    .frame(width: 70, height: 8)
            }
        }
        .padding(.horizontal)
    }
}

struct StreakRow: View {
    let goal: Goal
    
    var body: some View {
        HStack(spacing: 12) {
            Text(goal.fishEmoji)
                .font(.system(size: 28))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(goal.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primaryText)
                    .lineLimit(1)
                
                HStack(spacing: 6) {
                    Image(systemName: goal.category.icon)
                        .font(.system(size: 10))
                        .foregroundColor(goal.category.color)
                    Text(goal.category.rawValue)
                        .font(.system(size: 11))
                        .foregroundColor(.secondaryText)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.warningOrange)
                    Text("\(goal.bestStreak)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primaryText)
                }
                Text("days")
                    .font(.system(size: 11))
                    .foregroundColor(.secondaryText)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
