
import SwiftUI

struct ImprovedGoalCard: View {
    let goal: Goal
    @ObservedObject var dataManager: GoalsDataManager
    @State private var scale: CGFloat = 1.0
    @State private var showDeleteAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: goal.category.icon)
                            .font(.system(size: 14))
                            .foregroundColor(goal.category.color)
                        
                        Text(goal.category.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(goal.category.color)
                    }
                    
                    Spacer()
                    
                    Text(goal.fishEmoji)
                        .font(.system(size: 40))
                }
                
                Text(goal.name)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primaryText)
                    .lineLimit(2)
                
                HStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .stroke(Color.deepBlue, lineWidth: 8)
                            .frame(width: 90, height: 90)
                        
                        Circle()
                            .trim(from: 0, to: goal.progress)
                            .stroke(
                                LinearGradient(
                                    colors: [goal.fishColor, goal.fishColor.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(goal.percentage)%")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            Text(goal.isCompleted ? "Done" : "Progress")
                                .font(.system(size: 10))
                                .foregroundColor(.secondaryText)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "target")
                                .font(.system(size: 14))
                                .foregroundColor(.blueAccent)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Target")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondaryText)
                                Text("\(Int(goal.target)) \(goal.unit)")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primaryText)
                            }
                        }
                        
                        HStack(spacing: 8) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.warningOrange)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Streak")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondaryText)
                                Text("\(goal.streak) days")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.primaryText)
                            }
                        }
                        
                        if !goal.subTasks.isEmpty {
                            HStack(spacing: 8) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 14))
                                    .foregroundColor(.mintAccent)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Subtasks")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondaryText)
                                    Text("\(goal.completedSubTasks)/\(goal.subTasks.count)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primaryText)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                VStack(spacing: 8) {
                    HStack {
                        Text("\(Int(goal.current))")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.mintAccent)
                        Text("/ \(Int(goal.target)) \(goal.unit)")
                            .font(.system(size: 14))
                            .foregroundColor(.secondaryText)
                        Spacer()
                    }
                    
                    ImprovedProgressBar(progress: goal.progress, color: goal.fishColor)
                        .frame(height: 12)
                }
            }
            .padding(20)
            
            HStack(spacing: 0) {
                Button(action: {
                    setInProgress()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.system(size: 14))
                        Text("In Progress")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(goal.isCompleted ? .secondaryText : .blueAccent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(goal.isCompleted ? Color.deepBlue.opacity(0.3) : Color.blueAccent.opacity(0.15))
                }
                
                Rectangle()
                    .fill(Color.deepBlue)
                    .frame(width: 1)
                
                Button(action: {
                    setDone()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                        Text("Done")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(goal.isCompleted ? .mintAccent : .secondaryText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(goal.isCompleted ? Color.mintAccent.opacity(0.15) : Color.deepBlue.opacity(0.3))
                }
                
                Rectangle()
                    .fill(Color.deepBlue)
                    .frame(width: 1)
                
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 14))
                        .foregroundColor(.errorRed)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.deepBlue.opacity(0.3))
                }
            }
        }
        .background(Color.cardBlue)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(goal.isCompleted ? Color.mintAccent.opacity(0.3) : Color.clear, lineWidth: 2)
        )
        .scaleEffect(scale)
        .onTapGesture {
            withAnimation(.spring(response: 0.3)) {
                scale = 0.96
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.spring(response: 0.3)) {
                    scale = 1.0
                }
            }
        }
        .alert("Delete Goal", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                dataManager.deleteGoal(goal)
            }
        } message: {
            Text("Are you sure you want to delete '\(goal.name)'?")
        }
    }
    
    private func setInProgress() {
        var updatedGoal = goal
        updatedGoal.isCompleted = false
        dataManager.updateGoal(updatedGoal)
    }
    
    private func setDone() {
        var updatedGoal = goal
        updatedGoal.isCompleted = true
        updatedGoal.current = updatedGoal.target
        dataManager.updateGoal(updatedGoal)
    }
}
