
import SwiftUI

struct UpdateProgressView: View {
    let goal: Goal
    @ObservedObject var dataManager: GoalsDataManager
    @Binding var isPresented: Bool
    @State private var newValue = ""
    @State private var comment = ""
    @State private var buttonBounce = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.deepBlue, Color.cardBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                .onTapGesture {
                    hideKeyboard()
                }
                
                VStack(spacing: 25) {
                    VStack(spacing: 10) {
                        Text(goal.fishEmoji)
                            .font(.system(size: 50))
                        
                        Text("Update Progress")
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.primaryText)
                        
                        Text(goal.name)
                            .font(.system(size: 16))
                            .foregroundColor(.secondaryText)
                    }
                    .padding(.top, 10)
                    
                    VStack(spacing: 15) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Current")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondaryText)
                                Text("\(Int(goal.current)) \(goal.unit)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.primaryText)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text("Target")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondaryText)
                                Text("\(Int(goal.target)) \(goal.unit)")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(.mintAccent)
                            }
                        }
                        .padding()
                        .background(Color.cardBlue)
                        .cornerRadius(12)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            Text("New Value")
                                .foregroundColor(.secondaryText)
                                .font(.system(size: 14))
                            
                            HStack(spacing: 15) {
                                Button(action: { decrementValue() }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.cardBlue)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "minus")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.errorRed)
                                    }
                                }
                                
                                TextField("Enter value", text: $newValue)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primaryText)
                                    .padding()
                                    .background(Color.cardBlue)
                                    .cornerRadius(12)
                                
                                Button(action: { incrementValue() }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.cardBlue)
                                            .frame(width: 50, height: 50)
                                        
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.mintAccent)
                                    }
                                }
                            }
                        }
                        
                        CustomInputField(
                            icon: "note.text",
                            label: "Note (Optional)",
                            placeholder: "Add a comment...",
                            text: $comment
                        )
                    }
                    
                    Spacer()
                    
                    Button(action: saveProgress) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Progress")
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
                    .scaleEffect(buttonBounce ? 1.05 : 1.0)
                    .disabled(newValue.isEmpty)
                    .opacity(newValue.isEmpty ? 0.5 : 1.0)
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
        .onAppear {
            newValue = String(Int(goal.current))
        }
    }
    
    private func incrementValue() {
        if let current = Double(newValue) {
            newValue = String(Int(current + 1))
        }
    }
    
    private func decrementValue() {
        if let current = Double(newValue), current > 0 {
            newValue = String(Int(current - 1))
        }
    }
    
    private func saveProgress() {
        guard let value = Double(newValue) else { return }
        
        withAnimation(.spring()) {
            buttonBounce = true
        }
        
        var updatedGoal = goal
        let entry = ProgressEntry(date: Date(), value: value - goal.current, note: comment)
        updatedGoal.history.append(entry)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.spring()) {
                buttonBounce = false
                
                if value > updatedGoal.current {
                    updatedGoal.streak += 1
                    if updatedGoal.streak > updatedGoal.bestStreak {
                        updatedGoal.bestStreak = updatedGoal.streak
                    }
                }
                
                updatedGoal.current = value
                updatedGoal.lastUpdated = Date()
                
                dataManager.updateGoal(updatedGoal)
                isPresented = false
            }
        }
    }
}
