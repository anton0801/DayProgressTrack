
import SwiftUI

struct GoalDetailView: View {
    let goal: Goal
    @ObservedObject var dataManager: GoalsDataManager
    @Environment(\.presentationMode) var presentationMode
    @State private var showUpdateProgress = false
    @State private var showAddSubTask = false
    @State private var showHistory = false
    @State private var animatedProgress: Double = 0
    
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
                    VStack(spacing: 25) {
                        VStack(spacing: 15) {
                            HStack {
                                Image(systemName: goal.category.icon)
                                    .font(.system(size: 14))
                                    .foregroundColor(goal.category.color)
                                Text(goal.category.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(goal.category.color)
                            }
                            
                            Text(goal.name)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.primaryText)
                                .multilineTextAlignment(.center)
                            
                            ZStack {
                                Circle()
                                    .stroke(Color.cardBlue, lineWidth: 25)
                                    .frame(width: 220, height: 220)
                                
                                Circle()
                                    .trim(from: 0, to: animatedProgress)
                                    .stroke(
                                        LinearGradient(
                                            colors: [goal.fishColor, goal.fishColor.opacity(0.6)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 25, lineCap: .round)
                                    )
                                    .frame(width: 220, height: 220)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 5) {
                                    Text("\(goal.percentage)%")
                                        .font(.system(size: 52, weight: .bold))
                                        .foregroundColor(.primaryText)
                                    
                                    Text("\(Int(goal.current)) / \(Int(goal.target))")
                                        .font(.system(size: 16))
                                        .foregroundColor(.secondaryText)
                                    
                                    Text(goal.unit)
                                        .font(.system(size: 14))
                                        .foregroundColor(.secondaryText)
                                }
                            }
                            .onAppear {
                                withAnimation(.easeInOut(duration: 1.2)) {
                                    animatedProgress = goal.progress
                                }
                            }
                        }
                        .padding()
                        .background(Color.cardBlue)
                        .cornerRadius(20)
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                            StatCard(icon: "flame.fill", label: "Current Streak", value: "\(goal.streak) days", color: .warningOrange)
                            StatCard(icon: "trophy.fill", label: "Best Streak", value: "\(goal.bestStreak) days", color: .mintAccent)
                            StatCard(icon: "calendar", label: "Created", value: formatDate(goal.createdDate), color: .blueAccent)
                            StatCard(icon: "clock.fill", label: "Updated", value: formatDate(goal.lastUpdated), color: .lightBlue)
                        }
                        .padding(.horizontal)
                        
                        if !goal.subTasks.isEmpty {
                            VStack(alignment: .leading, spacing: 15) {
                                HStack {
                                    Text("Subtasks")
                                        .font(.system(size: 20, weight: .bold))
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Text("\(goal.completedSubTasks)/\(goal.subTasks.count)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.mintAccent)
                                }
                                
                                ForEach(goal.subTasks) { subTask in
                                    SubTaskRow(subTask: subTask, goal: goal, dataManager: dataManager)
                                }
                            }
                            .padding()
                            .background(Color.cardBlue)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        
                        if !goal.notes.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "note.text")
                                        .foregroundColor(.blueAccent)
                                    Text("Notes")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.primaryText)
                                }
                                
                                Text(goal.notes)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondaryText)
                            }
                            .padding()
                            .background(Color.cardBlue)
                            .cornerRadius(20)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: 12) {
                            Button(action: { showUpdateProgress = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Update Progress")
                                }
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.deepBlue)
                                .frame(maxWidth: .infinity)
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
                            
                            HStack(spacing: 12) {
                                Button(action: { showAddSubTask = true }) {
                                    HStack {
                                        Image(systemName: "checklist")
                                        Text("Add Subtask")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.cardBlue)
                                    .cornerRadius(12)
                                }
                                
                                Button(action: { showHistory = true }) {
                                    HStack {
                                        Image(systemName: "clock.arrow.circlepath")
                                        Text("History")
                                    }
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.primaryText)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(Color.cardBlue)
                                    .cornerRadius(12)
                                }
                            }
                            
                            Button(action: deleteGoal) {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Goal")
                                }
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.errorRed)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(Color.cardBlue)
                                .cornerRadius(12)
                            }
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 30)
                    }
                    .padding(.vertical)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.secondaryText)
                }
            }
            .sheet(isPresented: $showUpdateProgress) {
                UpdateProgressView(goal: goal, dataManager: dataManager, isPresented: $showUpdateProgress)
            }
            .sheet(isPresented: $showAddSubTask) {
                AddSubTaskView(goal: goal, dataManager: dataManager, isPresented: $showAddSubTask)
            }
            .sheet(isPresented: $showHistory) {
                HistoryView(goal: goal)
            }
        }
    }
    
    private func deleteGoal() {
        dataManager.deleteGoal(goal)
        presentationMode.wrappedValue.dismiss()
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

struct StatCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primaryText)
            
            Text(label)
                .font(.system(size: 12))
                .foregroundColor(.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.cardBlue)
        .cornerRadius(16)
    }
}

struct SubTaskRow: View {
    let subTask: SubTask
    let goal: Goal
    @ObservedObject var dataManager: GoalsDataManager
    
    var body: some View {
        HStack {
            Button(action: {
                toggleSubTask()
            }) {
                Image(systemName: subTask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(subTask.isCompleted ? .mintAccent : .secondaryText)
            }
            
            Text(subTask.title)
                .foregroundColor(subTask.isCompleted ? .secondaryText : .primaryText)
                .strikethrough(subTask.isCompleted)
            
            Spacer()
        }
    }
    
    private func toggleSubTask() {
        var updatedGoal = goal
        if let index = updatedGoal.subTasks.firstIndex(where: { $0.id == subTask.id }) {
            updatedGoal.subTasks[index].isCompleted.toggle()
            dataManager.updateGoal(updatedGoal)
        }
    }
}
