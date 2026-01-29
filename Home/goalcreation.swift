
import SwiftUI
import WebKit

struct GoalCreationView: View {
    @ObservedObject var dataManager: GoalsDataManager
    @Binding var isPresented: Bool
    
    @State private var goalName = ""
    @State private var targetValue = ""
    @State private var unit = ""
    @State private var selectedCategory: GoalCategory = .personal
    @State private var notes = ""
    
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
                
                ScrollView {
                    VStack(spacing: 25) {
                        VStack(spacing: 10) {
                            Text("🐠")
                                .font(.system(size: 60))
                            
                            Text("Create New Goal")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.primaryText)
                            
                            Text("Set your target and start tracking")
                                .font(.system(size: 14))
                                .foregroundColor(.secondaryText)
                        }
                        .padding(.top, 10)
                        
                        VStack(alignment: .leading, spacing: 20) {
                            CustomInputField(
                                icon: "flag.fill",
                                label: "Goal Name",
                                placeholder: "e.g., Read books",
                                text: $goalName
                            )
                            
                            CustomInputField(
                                icon: "target",
                                label: "Target",
                                placeholder: "e.g., 50",
                                text: $targetValue,
                                keyboardType: .numberPad
                            )
                            
                            CustomInputField(
                                icon: "ruler",
                                label: "Unit",
                                placeholder: "e.g., books, km, hours",
                                text: $unit
                            )
                            
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Image(systemName: "folder.fill")
                                        .foregroundColor(.mintAccent)
                                    Text("Category")
                                        .foregroundColor(.secondaryText)
                                        .font(.system(size: 14))
                                }
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 10) {
                                        ForEach(GoalCategory.allCases, id: \.self) { category in
                                            CategoryButton(
                                                category: category,
                                                isSelected: selectedCategory == category,
                                                action: { selectedCategory = category }
                                            )
                                        }
                                    }
                                }
                            }
                            
                            CustomInputField(
                                icon: "note.text",
                                label: "Notes (Optional)",
                                placeholder: "Add any notes...",
                                text: $notes
                            )
                        }
                        
                        Button(action: createGoal) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("Create Goal")
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
                        .disabled(goalName.isEmpty || targetValue.isEmpty)
                        .opacity(goalName.isEmpty || targetValue.isEmpty ? 0.5 : 1.0)
                    }
                    .padding()
                }
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
    
    private func createGoal() {
        guard let target = Double(targetValue) else { return }
        
        let newGoal = Goal(
            name: goalName,
            category: selectedCategory,
            target: target,
            current: 0,
            unit: unit,
            createdDate: Date(),
            lastUpdated: Date(),
            streak: 0,
            bestStreak: 0,
            history: [],
            subTasks: [],
            notes: notes,
            isCompleted: false
        )
        
        dataManager.addGoal(newGoal)
        isPresented = false
    }
}

final class ProgressCoordinator: NSObject {
    
    weak var webInstance: WKWebView?
    
    var redirectTracker = 0
    var redirectCap = 70
    var previousURL: URL?
    
    var redirectHistory: [URL] = []
    var recoveryURL: URL?
    
    var popupStack: [WKWebView] = []
    
    let sessionKey = "progress_session_data"
    
    func initiateLoad(url: URL, in webView: WKWebView) {
        print("🚀 [DayProgress] Initiating: \(url.absoluteString)")
        redirectHistory = [url]
        redirectTracker = 0
        
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        
        webView.load(request)
    }
    
    func restoreSessionData(in webView: WKWebView) {
        guard let stored = UserDefaults.standard.object(forKey: sessionKey) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else {
            return
        }
        
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        let cookies = stored.values
            .flatMap { $0.values }
            .compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    func persistSessionData(from webView: WKWebView) {
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        
        cookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            
            var storage: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            
            for cookie in cookies {
                var domainStorage = storage[cookie.domain] ?? [:]
                
                if let properties = cookie.properties {
                    domainStorage[cookie.name] = properties
                }
                
                storage[cookie.domain] = domainStorage
            }
            
            UserDefaults.standard.set(storage, forKey: self.sessionKey)
        }
    }
}

struct CategoryButton: View {
    let category: GoalCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color : Color.cardBlue)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 20))
                        .foregroundColor(isSelected ? .deepBlue : category.color)
                }
                
                Text(category.rawValue)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? category.color : .secondaryText)
            }
        }
    }
}
