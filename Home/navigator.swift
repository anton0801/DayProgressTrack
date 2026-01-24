
import SwiftUI

struct MainNavigationView: View {
    @ObservedObject var dataManager: GoalsDataManager
    @State private var selectedGoal: Goal?
    @State private var showCreateGoal = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MainProgressScreen(
                dataManager: dataManager,
                selectedGoal: $selectedGoal,
                showCreateGoal: $showCreateGoal
            )
            .tabItem {
                Image(systemName: "list.bullet.circle.fill")
                Text("Goals")
            }
            .tag(0)
            
            StatisticsScreen(goals: dataManager.goals)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Stats")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .accentColor(.mintAccent)
        .sheet(isPresented: $showCreateGoal) {
            GoalCreationView(dataManager: dataManager, isPresented: $showCreateGoal)
        }
        .sheet(item: $selectedGoal) { goal in
            GoalDetailView(goal: goal, dataManager: dataManager)
        }
    }
}
