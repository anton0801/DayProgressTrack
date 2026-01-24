
import SwiftUI

enum GoalCategory: String, CaseIterable, Codable {
    case health = "Health"
    case fitness = "Fitness"
    case learning = "Learning"
    case work = "Work"
    case personal = "Personal"
    case finance = "Finance"
    case hobby = "Hobby"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .health: return "heart.fill"
        case .fitness: return "figure.run"
        case .learning: return "book.fill"
        case .work: return "briefcase.fill"
        case .personal: return "person.fill"
        case .finance: return "dollarsign.circle.fill"
        case .hobby: return "paintbrush.fill"
        case .other: return "star.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .health: return .errorRed
        case .fitness: return .warningOrange
        case .learning: return .blueAccent
        case .work: return .mintAccent
        case .personal: return .lightBlue
        case .finance: return .successGreen
        case .hobby: return Color(hex: "E91E63")
        case .other: return .secondaryText
        }
    }
}

struct ProgressEntry: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var value: Double
    var note: String
}

struct SubTask: Identifiable, Codable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
}

struct Goal: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: GoalCategory
    var target: Double
    var current: Double
    var unit: String
    var createdDate: Date
    var lastUpdated: Date
    var streak: Int
    var bestStreak: Int
    var history: [ProgressEntry]
    var subTasks: [SubTask]
    var notes: String
    var isCompleted: Bool = false
    
    var progress: Double {
        min(current / target, 1.0)
    }
    
    var percentage: Int {
        Int(progress * 100)
    }
    
    var fishEmoji: String {
        if isCompleted || progress >= 1.0 { return "🐠" }
        if progress >= 0.7 { return "🐟" }
        if progress >= 0.4 { return "🐡" }
        return "🦈"
    }
    
    var fishColor: Color {
        if isCompleted || progress >= 1.0 { return .mintAccent }
        if progress >= 0.7 { return .blueAccent }
        if progress >= 0.4 { return .lightBlue }
        return .secondaryText
    }
    
    var completedSubTasks: Int {
        subTasks.filter { $0.isCompleted }.count
    }
    
    var isDone: Bool {
        isCompleted
    }
}
