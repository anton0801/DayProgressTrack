
import SwiftUI

@main
struct FishProgressTrackApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            DayProgressView()
        }
    }
}
