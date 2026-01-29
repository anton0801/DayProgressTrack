
import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = GoalsDataManager()
    @State private var showSplash = true
    @State private var showOnboarding = false
    @State private var currentOnboardingPage = 0
    
    var body: some View {
        ZStack {
            if showOnboarding {
                OnboardingView(
                    currentPage: $currentOnboardingPage,
                    isPresented: $showOnboarding
                )
            } else {
                MainNavigationView(dataManager: dataManager)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            checkFirstLaunch()
        }
    }
    
    private func checkFirstLaunch() {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if !hasLaunchedBefore {
            showOnboarding = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
