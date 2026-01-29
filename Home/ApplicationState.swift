import Foundation

// MARK: - Application State
enum ApplicationState: Equatable {
    case initializing
    case preparingData
    case verifying
    case verified
    case ready(endpoint: String)
    case standby
    case disconnected
}

// MARK: - Attribution Information
struct AttributionInfo {
    private var storage: [String: Any]
    
    init(data: [String: Any]) {
        self.storage = data
    }
    
    var hasData: Bool {
        !storage.isEmpty
    }
    
    var isOrganicInstall: Bool {
        storage["af_status"] as? String == "Organic"
    }
    
    func value(forKey key: String) -> Any? {
        storage[key]
    }
    
    var allData: [String: Any] {
        storage
    }
}

// MARK: - Deep Link Information
struct DeepLinkInfo {
    private var storage: [String: Any]
    
    init(data: [String: Any]) {
        self.storage = data
    }
    
    var hasData: Bool {
        !storage.isEmpty
    }
    
    func value(forKey key: String) -> Any? {
        storage[key]
    }
    
    var allData: [String: Any] {
        storage
    }
}

// MARK: - Application Settings
struct ApplicationSettings {
    var endpoint: String?
    var operatingMode: String?
    var initialLaunchCompleted: Bool
    var notificationsEnabled: Bool
    var notificationsDeclined: Bool
    var lastNotificationPrompt: Date?
    
    var canShowNotificationPrompt: Bool {
        guard !notificationsEnabled && !notificationsDeclined else {
            return false
        }
        
        if let lastPrompt = lastNotificationPrompt {
            let daysSincePrompt = Date().timeIntervalSince(lastPrompt) / 86400
            return daysSincePrompt >= 3
        }
        
        return true
    }
}
