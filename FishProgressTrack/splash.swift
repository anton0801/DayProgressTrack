
import SwiftUI

struct SplashScreen: View {
    @Binding var isPresented: Bool
    @State private var fishOffset: CGFloat = 0
    @State private var opacity: Double = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.deepBlue, Color.cardBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("🐠")
                    .font(.system(size: 100))
                    .offset(y: fishOffset)
                    .scaleEffect(scale)
                
                VStack(spacing: 10) {
                    Text("Fish Progress Track")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("Track your goals, watch them grow")
                        .font(.system(size: 16))
                        .foregroundColor(.secondaryText)
                }
            }
            .opacity(opacity)
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
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    isPresented = false
                }
            }
        }
    }
}
