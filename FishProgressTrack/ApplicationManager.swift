import Foundation
import Combine
import UIKit
import UserNotifications
import AppsFlyerLib
import Network

@MainActor
final class ApplicationManager: ObservableObject {
    
    @Published private(set) var currentState: ApplicationState = .initializing
    @Published private(set) var activeEndpoint: String?
    @Published var displayNotificationPrompt: Bool = false
    
    private let persistence: DataPersistenceProtocol
    private let verification: VerificationProtocol
    private let communication: APICommunicationProtocol
    
    private var attributionInfo = AttributionInfo(data: [:])
    private var deeplinkInfo = DeepLinkInfo(data: [:])
    private var settings = ApplicationSettings(
        endpoint: nil,
        operatingMode: nil,
        initialLaunchCompleted: false,
        notificationsEnabled: false,
        notificationsDeclined: false,
        lastNotificationPrompt: nil
    )
    
    private var subscriptions = Set<AnyCancellable>()
    private var timeoutOperation: Task<Void, Never>?
    private var stateLocked = false
    
    private let connectivityMonitor = NWPathMonitor()
    
    init(
        persistence: DataPersistenceProtocol = DataPersistence(),
        verification: VerificationProtocol = VerificationService(),
        communication: APICommunicationProtocol = APICommunication()
    ) {
        self.persistence = persistence
        self.verification = verification
        self.communication = communication
        
        restoreSettings()
        observeConnectivity()
        initializeApplication()
    }
    
    func processAttribution(_ data: [String: Any]) {
        attributionInfo = AttributionInfo(data: data)
        persistence.persist(attribution: data)
        
        Task {
            await executeVerification()
        }
    }
    
    func processDeeplink(_ data: [String: Any]) {
        deeplinkInfo = DeepLinkInfo(data: data)
        persistence.persist(deeplink: data)
    }
    
    func authorizeNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { [weak self] granted, _ in
            Task { @MainActor in
                self?.persistence.recordNotificationPermission(granted: granted)
                self?.persistence.recordNotificationDecline()
                self?.settings.notificationsEnabled = granted
                self?.settings.notificationsDeclined = !granted
                
                if granted {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                
                self?.displayNotificationPrompt = false
            }
        }
    }
    
    func declineNotifications() {
        persistence.recordNotificationPromptTime(Date())
        settings.lastNotificationPrompt = Date()
        displayNotificationPrompt = false
    }
    
    private func restoreSettings() {
        settings = ApplicationSettings(
            endpoint: persistence.retrieveEndpoint(),
            operatingMode: persistence.retrieveMode(),
            initialLaunchCompleted: !persistence.isInitialLaunch(),
            notificationsEnabled: persistence.hasNotificationPermission(),
            notificationsDeclined: persistence.hasDeclinedNotifications(),
            lastNotificationPrompt: persistence.lastNotificationPromptTime()
        )
    }
    
    private func initializeApplication() {
        currentState = .preparingData
        scheduleTimeoutOperation()
    }
    
    private func observeConnectivity() {
        connectivityMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self, !self.stateLocked else { return }
                
                if path.status == .satisfied {
                    if self.currentState == .disconnected {
                        self.currentState = .standby
                    }
                } else {
                    self.currentState = .disconnected
                }
            }
        }
        connectivityMonitor.start(queue: .global(qos: .background))
    }
    
    private func executeVerification() async {
        guard activeEndpoint == nil else { return }
        
        currentState = .verifying
        
        do {
            let isVerified = try await verification.verify()
            
            if isVerified {
                currentState = .verified
                await proceedWithFlow()
            } else {
                currentState = .standby
            }
        } catch {
            currentState = .standby
        }
    }
    
    private func scheduleTimeoutOperation() {
        timeoutOperation = Task {
            try? await Task.sleep(nanoseconds: 30_000_000_000)
            
            if !stateLocked {
                await MainActor.run {
                    self.currentState = .standby
                }
            }
        }
    }
    
    private func proceedWithFlow() async {
        if !attributionInfo.hasData {
            restoreCachedEndpoint()
            return
        }
        
        if settings.operatingMode == "Inactive" {
            currentState = .standby
            return
        }
        
        if requiresInitialLaunchFlow() {
            await performInitialLaunchFlow()
            return
        }
        
        if let temporaryEndpoint = UserDefaults.standard.string(forKey: "temp_url") {
            activateApplication(with: temporaryEndpoint)
            return
        }
        
        await fetchEndpoint()
    }
    
    private func requiresInitialLaunchFlow() -> Bool {
        !settings.initialLaunchCompleted && attributionInfo.isOrganicInstall
    }
    
    private func performInitialLaunchFlow() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        
        do {
            let deviceIdentifier = AppsFlyerLib.shared().getAppsFlyerUID()
            let fetchedAttribution = try await communication.requestAttribution(deviceID: deviceIdentifier)
            
            var combinedData = fetchedAttribution
            for (key, value) in deeplinkInfo.allData {
                if combinedData[key] == nil {
                    combinedData[key] = value
                }
            }
            
            attributionInfo = AttributionInfo(data: combinedData)
            persistence.persist(attribution: combinedData)
            
            await fetchEndpoint()
        } catch {
            currentState = .standby
        }
    }
    
    private func restoreCachedEndpoint() {
        if let cached = settings.endpoint {
            activateApplication(with: cached)
        } else {
            currentState = .standby
        }
    }
    
    private func activateApplication(with endpoint: String) {
        guard !stateLocked else { return }
        
        timeoutOperation?.cancel()
        activeEndpoint = endpoint
        currentState = .ready(endpoint: endpoint)
        stateLocked = true
        
        if settings.canShowNotificationPrompt {
            displayNotificationPrompt = true
        }
    }
    
    private func fetchEndpoint() async {
        do {
            let endpoint = try await communication.requestEndpoint(attribution: attributionInfo.allData)
            
            persistence.persist(endpoint: endpoint)
            persistence.persist(mode: "Active")
            persistence.markInitialLaunchComplete()
            
            settings.endpoint = endpoint
            settings.operatingMode = "Active"
            settings.initialLaunchCompleted = true
            
            activateApplication(with: endpoint)
        } catch {
            restoreCachedEndpoint()
        }
    }
    
}
