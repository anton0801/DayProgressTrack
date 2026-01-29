import SwiftUI
import Combine

struct SplashScreen: View {
    @State private var fishOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                
                LinearGradient(
                    colors: [Color.deepBlue, Color.cardBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                Image(g.size.width > g.size.height ? "load_l_bg" : "bg_load")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                    .opacity(0.15)
                
                VStack(spacing: 30) {
                    Text("🐠")
                        .font(.system(size: 100))
                        .offset(y: fishOffset)
                        .scaleEffect(scale)
                    
                    VStack(spacing: 10) {
                        Text("Fish Progress Track")
                            .font(.custom("Inter-Regular_Bold", size: 34))
                            .foregroundColor(.primaryText)
                        
                        Text("Track your goals, watch them grow")
                            .font(.custom("Inter-Regular_Medium", size: 16))
                            .foregroundColor(.secondaryText)
                    }
                }
                .opacity(opacity)
                
                VStack {
                    Spacer()
                    HStack {
                        Text("Loading...")
                            .font(.custom("Inter-Regular_Bold", size: 20))
                            .foregroundColor(.primaryText)
                        ProgressView()
                            .tint(.primaryText)
                    }
                    .padding(.bottom)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    opacity = 1
                    scale = 1.0
                }
                withAnimation(
                    Animation.easeInOut(duration: 2.5)
                        .repeatForever(autoreverses: true)
                ) {
                    fishOffset = -8
                }
                
            }
        }
        .ignoresSafeArea()
    }
}


struct DayProgressView: View {
    
    @StateObject private var appManager = ApplicationManager()
    @State private var eventSubscriptions = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            renderCurrentState()
            
            if appManager.displayNotificationPrompt {
                NotificationPromptView(manager: appManager)
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .onAppear {
            subscribeToEvents()
        }
    }
    
    @ViewBuilder
    private func renderCurrentState() -> some View {
        switch appManager.currentState {
        case .initializing, .preparingData, .verifying, .verified:
            SplashScreen()
            
        case .ready:
            if appManager.activeEndpoint != nil {
                ProgressContentView()
            } else {
                ContentView()
            }
            
        case .standby:
            ContentView()
            
        case .disconnected:
            DisconnectedView()
        }
    }
    
    private func subscribeToEvents() {
        NotificationCenter.default
            .publisher(for: Notification.Name("ConversionDataReceived"))
            .compactMap { $0.userInfo?["conversionData"] as? [String: Any] }
            .sink { data in
                appManager.processAttribution(data)
            }
            .store(in: &eventSubscriptions)
        
        NotificationCenter.default
            .publisher(for: Notification.Name("deeplink_values"))
            .compactMap { $0.userInfo?["deeplinksData"] as? [String: Any] }
            .sink { data in
                appManager.processDeeplink(data)
            }
            .store(in: &eventSubscriptions)
    }
}

struct DisconnectedView: View {
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image(g.size.width > g.size.height ? "inet_l_bg" : "bg_inet")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                Image("alert_inet")
                    .resizable()
                    .frame(width: 250, height: 200)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreen()
}
