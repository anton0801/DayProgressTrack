import Foundation
import SwiftUI
import UserNotifications


final class NotificationCoordinator: NSObject {
    
    func handleNotification(_ payload: [AnyHashable: Any]) {
        guard let extractedURL = extractURL(from: payload) else { return }
        
        UserDefaults.standard.set(extractedURL, forKey: "temp_url")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "temp_url_time")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(
                name: Notification.Name("LoadTempURL"),
                object: nil,
                userInfo: ["temp_url": extractedURL]
            )
        }
    }
    
    private func extractURL(from payload: [AnyHashable: Any]) -> String? {
        if let direct = payload["url"] as? String {
            return direct
        }
        
        if let dataLayer = payload["data"] as? [String: Any],
           let url = dataLayer["url"] as? String {
            return url
        }
        
        if let apsLayer = payload["aps"] as? [String: Any],
           let dataLayer = apsLayer["data"] as? [String: Any],
           let url = dataLayer["url"] as? String {
            return url
        }
        
        if let customLayer = payload["custom"] as? [String: Any],
           let url = customLayer["target_url"] as? String {
            return url
        }
        
        return nil
    }
}
