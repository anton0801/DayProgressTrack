
import SwiftUI

struct OnboardingView: View {
    @Binding var currentPage: Int
    @Binding var isPresented: Bool
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.deepBlue, Color.cardBlue],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    OnboardingPage1().tag(0)
                    OnboardingPage2().tag(1)
                    OnboardingPage3().tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                .frame(maxHeight: .infinity)
                
                VStack(spacing: 20) {
                    Button(action: {
                        if currentPage < 2 {
                            withAnimation {
                                currentPage += 1
                            }
                        } else {
                            withAnimation {
                                isPresented = false
                            }
                        }
                    }) {
                        HStack {
                            Text(currentPage < 2 ? "Next" : "Get Started")
                                .font(.system(size: 18, weight: .semibold))
                            
                            if currentPage < 2 {
                                Image(systemName: "arrow.right")
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                        }
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
                    
                    if currentPage < 2 {
                        Button(action: {
                            withAnimation {
                                isPresented = false
                            }
                        }) {
                            Text("Skip")
                                .font(.system(size: 16))
                                .foregroundColor(.secondaryText)
                        }
                    }
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .padding(.top, 10)
            }
        }
    }
}

struct OnboardingPage1: View {
    @State private var progress: Double = 0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .stroke(Color.cardBlue.opacity(0.3), lineWidth: 20)
                    .frame(width: 180, height: 180)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: [Color.mintAccent, Color.blueAccent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))
                
                VStack(spacing: 5) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.primaryText)
                    
                    Text("Complete")
                        .font(.system(size: 14))
                        .foregroundColor(.secondaryText)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                    progress = 0.65
                }
            }
            
            VStack(spacing: 15) {
                Text("Set Clear Goals")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primaryText)
                
                Text("Define your targets and track progress with visual indicators")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage2: View {
    @State private var dotsVisible = [false, false, false]
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            HStack(spacing: 25) {
                ForEach(0..<3) { index in
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.blueAccent, Color.mintAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 60, height: 60)
                            .scaleEffect(dotsVisible[index] ? 1.0 : 0.0)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.deepBlue)
                            .scaleEffect(dotsVisible[index] ? 1.0 : 0.0)
                    }
                }
            }
            .padding(.vertical, 40)
            .onAppear {
                for i in 0..<3 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.4) {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                            dotsVisible[i] = true
                        }
                    }
                }
            }
            
            VStack(spacing: 15) {
                Text("Track Daily")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primaryText)
                
                Text("Update your progress every day and build consistent habits")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct OnboardingPage3: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(Color.mintAccent.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .scaleEffect(scale)
                
                Circle()
                    .fill(Color.mintAccent.opacity(0.2))
                    .frame(width: 150, height: 150)
                    .scaleEffect(scale * 0.8)
                
                Text("🐠")
                    .font(.system(size: 120))
                    .scaleEffect(scale)
            }
            .onAppear {
                withAnimation(
                    Animation.easeInOut(duration: 2.0)
                        .repeatForever(autoreverses: true)
                ) {
                    scale = 1.1
                }
            }
            
            VStack(spacing: 15) {
                Text("Watch It Grow")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primaryText)
                
                Text("See your progress grow like a fish swimming upstream")
                    .font(.system(size: 16))
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}
