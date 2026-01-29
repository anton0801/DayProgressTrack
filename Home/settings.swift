
import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("weekStartsMonday") private var weekStartsMonday = true
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.deepBlue, Color.cardBlue.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Preferences Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Preferences")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.mintAccent)
                                .padding(.horizontal)
                            
                            VStack(spacing: 0) {
                                Toggle(isOn: $notificationsEnabled) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(.blueAccent)
                                            .frame(width: 30)
                                        Text("Notifications")
                                            .foregroundColor(.primaryText)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .mintAccent))
                                .padding()
                                
                                Divider()
                                    .background(Color.deepBlue.opacity(0.3))
                                
                                Toggle(isOn: $weekStartsMonday) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.blueAccent)
                                            .frame(width: 30)
                                        Text("Week starts on Monday")
                                            .foregroundColor(.primaryText)
                                    }
                                }
                                .toggleStyle(SwitchToggleStyle(tint: .mintAccent))
                                .padding()
                            }
                            .background(Color.cardBlue)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        // About Section
                        VStack(alignment: .leading, spacing: 15) {
                            Text("About")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.mintAccent)
                                .padding(.horizontal)
                            
                            VStack {
                                HStack {
                                    Image(systemName: "info.circle.fill")
                                        .foregroundColor(.blueAccent)
                                        .frame(width: 30)
                                    
                                    Text("Version")
                                        .foregroundColor(.primaryText)
                                    
                                    Spacer()
                                    
                                    Text("1.0.0")
                                        .foregroundColor(.secondaryText)
                                        .font(.system(size: 14))
                                }
                                
                                Button {
                                    UIApplication.shared.open(URL(string: "https://dayprogresstrack.com/privacy-policy.html")!)
                                } label: {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.blueAccent)
                                            .frame(width: 30)
                                        
                                        Text("Privacy Policy")
                                            .foregroundColor(.primaryText)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.vertical)
                            }
                            .padding()
                            .background(Color.cardBlue)
                            .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        Spacer(minLength: 20)
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    SettingsView()
}
