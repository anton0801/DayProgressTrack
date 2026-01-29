import SwiftUI

struct NotificationPromptView: View {
    
    @ObservedObject var manager: ApplicationManager
    @State private var animateIcon = false
    
    var body: some View {
        GeometryReader { g in
            ZStack {
                Image("bg_main_push")
                    .resizable()
                    .scaledToFill()
                    .frame(width: g.size.width, height: g.size.height)
                    .ignoresSafeArea()
                
                if g.size.width > g.size.height {
                    horizontalContent
                } else {
                    verticalContent
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private var iconContainer: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 165, height: 165)
                .scaleEffect(animateIcon ? 1.35 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 2.8).repeatForever(autoreverses: true),
                    value: animateIcon
                )
            
            Image(systemName: "clock.badge.checkmark")
                .font(.system(size: 75))
                .foregroundColor(.purple)
        }
        .onAppear { animateIcon = true }
    }
    
    private var messageContainer: some View {
        VStack(spacing: 28) {
            Text("Stay on Track")
                .font(.largeTitle.bold())
            
            Text("Enable notifications to get daily progress reminders and achievements")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 65)
        }
    }
    
    private var actionButtons: some View {
        VStack(spacing: 16) {
            Button {
                manager.authorizeNotifications()
            } label: {
                Image("btn_main_push")
                    .resizable()
                    .frame(width: 320, height: 60)
            }
            
            Button {
                manager.declineNotifications()
            } label: {
                Text("SKIP")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(28)
            }
        }
        .padding(.horizontal, 48)
    }
    
    private var verticalContent: some View {
        VStack(spacing: 12) {
            Spacer()
            
            Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                .font(.custom("Inter-Regular_Bold", size: 24))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            Text("STAY TUNED WITH BEST OFFERS FROM\nOUR CASINO")
                .font(.custom("Inter-Regular_Bold", size: 16))
                .foregroundColor(.white.opacity(0.7))
                .padding(.horizontal, 12)
                .multilineTextAlignment(.center)
            
            actionButtons
        }
        .padding(.bottom, 24)
    }
    
    private var horizontalContent: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                VStack(alignment: .leading, spacing: 12) {
                    Text("ALLOW NOTIFICATIONS ABOUT\nBONUSES AND PROMOS")
                        .font(.custom("Inter-Regular_Bold", size: 24))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                    
                    Text("STAY TUNED WITH BEST OFFERS FROM OUR CASINO")
                        .font(.custom("Inter-Regular_Bold", size: 16))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
                actionButtons
                Spacer()
            }
        }
        .padding(.bottom, 24)
    }
    
}

#Preview {
    NotificationPromptView(manager: ApplicationManager())
}
