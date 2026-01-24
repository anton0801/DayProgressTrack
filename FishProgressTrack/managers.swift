
import SwiftUI
import Combine

class GoalsDataManager: ObservableObject {
    @Published var goals: [Goal] = []
    
    private let saveKey = "SavedGoals"
    
    init() {
        loadGoals()
    }
    
    func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
                goals = decoded
                return
            }
        }
        goals = []
    }
    
    func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
    }
}
