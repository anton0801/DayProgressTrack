import UIKit
import FirebaseCore
import FirebaseMessaging
import AppTrackingTransparency
import UserNotifications
import AppsFlyerLib

final class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    private let attributionCoordinator = AttributionCoordinator()
    private let notificationCoordinator = NotificationCoordinator()
    private var trackingCoordinator: TrackingCoordinator?
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        attributionCoordinator.onAttributionReceived = { [weak self] data in
            self?.announceAttribution(data)
        }
        
        attributionCoordinator.onDeeplinkReceived = { [weak self] data in
            self?.announceDeeplink(data)
        }
        
        trackingCoordinator = TrackingCoordinator(attributionCoordinator: attributionCoordinator)
        
        setupFirebase()
        setupNotifications()
        setupTracking()
        
        if let notification = launchOptions?[.remoteNotification] as? [AnyHashable: Any] {
            notificationCoordinator.handleNotification(notification)
        }
        
        observeApplicationLifecycle()
        
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupNotifications() {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    private func setupTracking() {
        trackingCoordinator?.configure()
    }
    
    private func observeApplicationLifecycle() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidActivate),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }
    
    @objc private func applicationDidActivate() {
        trackingCoordinator?.startTracking()
    }
    
    private func announceAttribution(_ data: [AnyHashable: Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            NotificationCenter.default.post(
                name: Notification.Name("ConversionDataReceived"),
                object: nil,
                userInfo: ["conversionData": data]
            )
        }
    }
    
    private func announceDeeplink(_ data: [AnyHashable: Any]) {
        NotificationCenter.default.post(
            name: Notification.Name("deeplink_values"),
            object: nil,
            userInfo: ["deeplinksData": data]
        )
    }
    
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        notificationCoordinator.handleNotification(userInfo)
        completionHandler(.newData)
    }
    
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        messaging.token { token, error in
            guard error == nil, let token = token else { return }
            
            UserDefaults.standard.set(token, forKey: "fcm_token")
            UserDefaults.standard.set(token, forKey: "push_token")
            UserDefaults(suiteName: "group.dayprogress.core")?.set(token, forKey: "shared_token")
            
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "token_timestamp")
        }
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        notificationCoordinator.handleNotification(notification.request.content.userInfo)
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        notificationCoordinator.handleNotification(response.notification.request.content.userInfo)
        completionHandler()
    }
}

final class TrackingCoordinator: NSObject, AppsFlyerLibDelegate, DeepLinkDelegate {
    
    private var attributionCoordinator: AttributionCoordinator
    
    init(attributionCoordinator: AttributionCoordinator) {
        self.attributionCoordinator = attributionCoordinator
    }
    
    func configure() {
        let sdk = AppsFlyerLib.shared()
        sdk.appsFlyerDevKey = AppConfig.appsFlyerDevKey
        sdk.appleAppID = AppConfig.appsFlyerID
        sdk.delegate = self
        sdk.deepLinkDelegate = self
        sdk.isDebug = false
    }
    
    func startTracking() {
        if #available(iOS 14.0, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            
            ATTrackingManager.requestTrackingAuthorization { status in
                DispatchQueue.main.async {
                    AppsFlyerLib.shared().start()
                    UserDefaults.standard.set(status.rawValue, forKey: "tracking_status")
                    UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "tracking_time")
                }
            }
        } else {
            AppsFlyerLib.shared().start()
        }
    }
    
    func onConversionDataSuccess(_ data: [AnyHashable: Any]) {
        attributionCoordinator.receiveAttribution(data)
    }
    
    func onConversionDataFail(_ error: Error) {
        var errorData: [AnyHashable: Any] = [:]
        errorData["error"] = true
        errorData["error_description"] = error.localizedDescription
        attributionCoordinator.receiveAttribution(errorData)
    }
    
    func didResolveDeepLink(_ result: DeepLinkResult) {
        guard case .found = result.status,
              let deepLink = result.deepLink else {
            return
        }
        
        attributionCoordinator.receiveDeeplink(deepLink.clickEvent)
    }
}
