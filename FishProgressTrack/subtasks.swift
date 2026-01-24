
import SwiftUI

struct AddSubTaskView: View {
    let goal: Goal
    @ObservedObject var dataManager: GoalsDataManager
    @Binding var isPresented: Bool
    @State private var taskTitle = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.deepBlue.ignoresSafeArea()
                    .onTapGesture {
                        hideKeyboard()
                    }
                
                VStack(spacing: 20) {
                    Text("Add Subtask")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primaryText)
                        .padding(.top)
                    
                    CustomInputField(
                        icon: "checklist",
                        label: "Task",
                        placeholder: "Enter subtask...",
                        text: $taskTitle
                    )
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button(action: addSubTask) {
                        Text("Add Subtask")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.deepBlue)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.mintAccent)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .disabled(taskTitle.isEmpty)
                    .opacity(taskTitle.isEmpty ? 0.5 : 1.0)
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.secondaryText)
                }
            }
        }
    }
    
    private func addSubTask() {
        let newSubTask = SubTask(title: taskTitle, isCompleted: false)
        var updatedGoal = goal
        updatedGoal.subTasks.append(newSubTask)
        dataManager.updateGoal(updatedGoal)
        isPresented = false
    }
}
