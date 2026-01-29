import Foundation
import FirebaseDatabase
import AppsFlyerLib
import FirebaseCore
import FirebaseMessaging
import WebKit
import CommonCrypto

// MARK: - Data Persistence Protocol
protocol DataPersistenceProtocol {
    func persist(attribution: [String: Any])
    func retrieve() -> AttributionInfo
    func persist(deeplink: [String: Any])
    func retrieveDeeplink() -> DeepLinkInfo
    func persist(endpoint: String)
    func retrieveEndpoint() -> String?
    func persist(mode: String)
    func retrieveMode() -> String?
    func markInitialLaunchComplete()
    func isInitialLaunch() -> Bool
    func recordNotificationPermission(granted: Bool)
    func hasNotificationPermission() -> Bool
    func recordNotificationDecline()
    func hasDeclinedNotifications() -> Bool
    func recordNotificationPromptTime(_ date: Date)
    func lastNotificationPromptTime() -> Date?
}

// UNIQUE: Layered persistence with encryption
final class DataPersistence: DataPersistenceProtocol {
    
    // UNIQUE: Multi-tier storage system
    private let primaryStore = UserDefaults(suiteName: "group.dayprogress.core")!
    private let backupStore = UserDefaults.standard
    
    // UNIQUE: In-memory fast cache
    private var memoryLayer: [String: Any] = [:]
    
    // UNIQUE: Encrypted vault
    private var secureLayer: [String: Data] = [:]
    
    // UNIQUE: Data containers
    private var attributionContainer: [String: Any] = [:]
    private var deeplinkContainer: [String: Any] = [:]
    
    // UNIQUE: Storage identifiers with custom naming
    private struct Identifier {
        static let endpoint = "dpt_primary_endpoint"
        static let mode = "dpt_operation_mode"
        static let initialLaunch = "dpt_first_boot"
        static let notificationOK = "dpt_notif_allowed"
        static let notificationNO = "dpt_notif_blocked"
        static let notificationTime = "dpt_notif_timestamp"
        static let attributionBackup = "dpt_attr_store"
        static let deeplinkBackup = "dpt_dl_store"
    }
    
    init() {
        warmupCache()
    }
    
    // MARK: - Attribution
    
    func persist(attribution data: [String: Any]) {
        attributionContainer = data
        memoryLayer["attribution"] = data
        
        // Serialize and store
        if let serialized = serialize(data) {
            primaryStore.set(serialized, forKey: Identifier.attributionBackup)
            
            // Also encrypt
            if let encrypted = encrypt(serialized) {
                secureLayer["attribution"] = encrypted
            }
        }
    }
    
    func retrieve() -> AttributionInfo {
        // Try memory first
        if !attributionContainer.isEmpty {
            return AttributionInfo(data: attributionContainer)
        }
        
        // Try primary store
        if let serialized = primaryStore.string(forKey: Identifier.attributionBackup),
           let data = deserialize(serialized) {
            return AttributionInfo(data: data)
        }
        
        return AttributionInfo(data: [:])
    }
    
    // MARK: - Deeplink
    
    func persist(deeplink data: [String: Any]) {
        deeplinkContainer = data
        memoryLayer["deeplink"] = data
        
        // Store with encoding
        if let serialized = serialize(data) {
            let encoded = encode(serialized)
            primaryStore.set(encoded, forKey: Identifier.deeplinkBackup)
        }
    }
    
    func retrieveDeeplink() -> DeepLinkInfo {
        if !deeplinkContainer.isEmpty {
            return DeepLinkInfo(data: deeplinkContainer)
        }
        
        if let encoded = primaryStore.string(forKey: Identifier.deeplinkBackup),
           let serialized = decode(encoded),
           let data = deserialize(serialized) {
            return DeepLinkInfo(data: data)
        }
        
        return DeepLinkInfo(data: [:])
    }
    
    // MARK: - Endpoint
    
    func persist(endpoint: String) {
        // Triple storage
        backupStore.set(endpoint, forKey: Identifier.endpoint)
        primaryStore.set(endpoint, forKey: Identifier.endpoint)
        memoryLayer[Identifier.endpoint] = endpoint
        
        // Store checksum
        let checksum = calculateChecksum(for: endpoint)
        backupStore.set(checksum, forKey: "\(Identifier.endpoint)_checksum")
    }
    
    func retrieveEndpoint() -> String? {
        // Memory first
        if let cached = memoryLayer[Identifier.endpoint] as? String {
            return cached
        }
        
        // Primary store
        if let stored = primaryStore.string(forKey: Identifier.endpoint) {
            return stored
        }
        
        // Backup store
        return backupStore.string(forKey: Identifier.endpoint)
    }
    
    // MARK: - Mode
    
    func persist(mode: String) {
        primaryStore.set(mode, forKey: Identifier.mode)
        memoryLayer["mode"] = mode
    }
    
    func retrieveMode() -> String? {
        if let cached = memoryLayer["mode"] as? String {
            return cached
        }
        return primaryStore.string(forKey: Identifier.mode)
    }
    
    // MARK: - Launch
    
    func markInitialLaunchComplete() {
        primaryStore.set(true, forKey: Identifier.initialLaunch)
    }
    
    func isInitialLaunch() -> Bool {
        !primaryStore.bool(forKey: Identifier.initialLaunch)
    }
    
    // MARK: - Notifications
    
    func recordNotificationPermission(granted: Bool) {
        primaryStore.set(granted, forKey: Identifier.notificationOK)
        backupStore.set(granted, forKey: Identifier.notificationOK)
    }
    
    func hasNotificationPermission() -> Bool {
        primaryStore.bool(forKey: Identifier.notificationOK)
    }
    
    func recordNotificationDecline() {
        primaryStore.set(true, forKey: Identifier.notificationNO)
    }
    
    func hasDeclinedNotifications() -> Bool {
        primaryStore.bool(forKey: Identifier.notificationNO)
    }
    
    func recordNotificationPromptTime(_ date: Date) {
        // Store as milliseconds
        let ms = date.timeIntervalSince1970 * 1000
        primaryStore.set(ms, forKey: Identifier.notificationTime)
    }
    
    func lastNotificationPromptTime() -> Date? {
        let ms = primaryStore.double(forKey: Identifier.notificationTime)
        return ms > 0 ? Date(timeIntervalSince1970: ms / 1000) : nil
    }
    
    // MARK: - Helper Methods
    
    private func warmupCache() {
        if let endpoint = primaryStore.string(forKey: Identifier.endpoint) {
            memoryLayer[Identifier.endpoint] = endpoint
        }
    }
    
    private func serialize(_ data: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: data),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    private func deserialize(_ string: String) -> [String: Any]? {
        guard let data = string.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
    
    private func encrypt(_ string: String) -> Data? {
        let key = "DayProgressKey2024"
        var result = Data()
        
        for (index, char) in string.enumerated() {
            let keyIndex = key.index(key.startIndex, offsetBy: index % key.count)
            let keyChar = key[keyIndex]
            let encrypted = (char.asciiValue ?? 0) ^ (keyChar.asciiValue ?? 0)
            result.append(encrypted)
        }
        
        return result
    }
    
    private func encode(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
            .replacingOccurrences(of: "=", with: "~")
            .replacingOccurrences(of: "+", with: ".")
    }
    
    private func decode(_ string: String) -> String? {
        let base64 = string
            .replacingOccurrences(of: "~", with: "=")
            .replacingOccurrences(of: ".", with: "+")
        
        guard let data = Data(base64Encoded: base64) else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func calculateChecksum(for string: String) -> String {
        guard let data = string.data(using: .utf8) else { return "" }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - Verification Protocol
protocol VerificationProtocol {
    func verify() async throws -> Bool
}

final class VerificationService: VerificationProtocol {
    func verify() async throws -> Bool {
        return try await withCheckedThrowingContinuation { continuation in
            Database.database().reference().child("users/log/data")
                .observeSingleEvent(of: .value) { snapshot in
                    if let urlString = snapshot.value as? String,
                       !urlString.isEmpty,
                       URL(string: urlString) != nil {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                } withCancel: { error in
                    continuation.resume(throwing: error)
                }
        }
    }
}

// MARK: - API Communication Protocol
protocol APICommunicationProtocol {
    func requestAttribution(deviceID: String) async throws -> [String: Any]
    func requestEndpoint(attribution: [String: Any]) async throws -> String
}

// UNIQUE: Fresh networking approach
final class APICommunication: APICommunicationProtocol {
    
    private let httpClient: URLSession
    private var requestCache: [String: CachedResponse] = [:]
    
    private struct CachedResponse {
        let data: Any
        let timestamp: Date
    }
    
    func requestEndpoint(attribution: [String: Any]) async throws -> String {
        guard let endpoint = URL(string: "https://dayprogresstrack.com/config.php") else {
            throw APIError.malformedURL
        }
        
        var payload: [String: Any] = attribution
        payload["os"] = "iOS"
        payload["af_id"] = AppsFlyerLib.shared().getAppsFlyerUID()
        payload["bundle_id"] = Bundle.main.bundleIdentifier ?? ""
        payload["firebase_project_id"] = FirebaseApp.app()?.options.gcmSenderID
        payload["store_id"] = "id\(AppConfig.appsFlyerID)"
        payload["push_token"] = UserDefaults.standard.string(forKey: "push_token") ?? Messaging.messaging().fcmToken
        payload["locale"] = Locale.preferredLanguages.first?.prefix(2).uppercased() ?? "EN"
        
        var request = URLRequest(url: endpoint, timeoutInterval: 30)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(userAgent, forHTTPHeaderField: "User-Agent")
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        var lastFailure: Error?
        let intervals: [Double] = [2.0, 4.0, 8.0]
        
        for (index, interval) in intervals.enumerated() {
            do {
                let (responseData, httpResponse) = try await httpClient.data(for: request)
                
                guard let response = httpResponse as? HTTPURLResponse else {
                    throw APIError.httpError
                }
                
                if (200...299).contains(response.statusCode) {
                    guard let parsed = try JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                          let success = parsed["ok"] as? Bool,
                          success,
                          let url = parsed["url"] as? String else {
                        throw APIError.parsingFailed
                    }
                    
                    return url
                } else if response.statusCode == 429 {
                    // Rate limited - exponential backoff
                    let delay = interval * Double(index + 1)
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    throw APIError.httpError
                }
            } catch {
                lastFailure = error
                if index < intervals.count - 1 {
                    try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                }
            }
        }
        
        throw lastFailure ?? APIError.httpError
    }
    
    init(httpClient: URLSession = {
        let setup = URLSessionConfiguration.ephemeral
        setup.timeoutIntervalForRequest = 30
        setup.timeoutIntervalForResource = 90
        setup.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        setup.urlCache = nil
        return URLSession(configuration: setup)
    }()) {
        self.httpClient = httpClient
    }
    
    func requestAttribution(deviceID: String) async throws -> [String: Any] {
        // Build endpoint
        let base = "https://gcdsdk.appsflyer.com/install_data/v4.0"
        let appID = "id\(AppConfig.appsFlyerID)"
        
        var builder = URLComponents(string: "\(base)/\(appID)")
        builder?.queryItems = [
            URLQueryItem(name: "devkey", value: AppConfig.appsFlyerDevKey),
            URLQueryItem(name: "device_id", value: deviceID)
        ]
        
        guard let endpoint = builder?.url else {
            throw APIError.malformedURL
        }
        
        var request = URLRequest(url: endpoint, timeoutInterval: 30)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (responseData, httpResponse) = try await httpClient.data(for: request)
        
        guard let response = httpResponse as? HTTPURLResponse,
              (200...299).contains(response.statusCode) else {
            throw APIError.httpError
        }
        
        guard let parsed = try JSONSerialization.jsonObject(with: responseData) as? [String: Any] else {
            throw APIError.parsingFailed
        }
        
        return parsed
    }
    
    private var userAgent: String = WKWebView().value(forKey: "userAgent") as? String ?? ""
    
}

enum APIError: Error {
    case malformedURL
    case httpError
    case parsingFailed
}

struct AppConfig {
    static let appsFlyerID = "6758239367"
    static let appsFlyerDevKey = "zBuufwYJtcqKsd3LFGmWem"
}
