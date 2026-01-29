import SwiftUI
import AppsFlyerLib
import Combine

final class AttributionCoordinator: NSObject {
    
    var onAttributionReceived: (([AnyHashable: Any]) -> Void)?
    var onDeeplinkReceived: (([AnyHashable: Any]) -> Void)?
    
    private var attributionBuffer: [AnyHashable: Any] = [:]
    private var deeplinkBuffer: [AnyHashable: Any] = [:]
    private var mergeTimer: Timer?
    private let sentMarker = "dpt_attribution_processed"
    
    func receiveAttribution(_ data: [AnyHashable: Any]) {
        attributionBuffer = data
        scheduleMerge()
        
        if !deeplinkBuffer.isEmpty {
            merge()
        }
    }
    
    func receiveDeeplink(_ data: [AnyHashable: Any]) {
        deeplinkBuffer = data
        onDeeplinkReceived?(data)
        
        mergeTimer?.invalidate()
        
        if !attributionBuffer.isEmpty {
            merge()
        }
    }
    
    private func scheduleMerge() {
        mergeTimer?.invalidate()
        
        mergeTimer = Timer.scheduledTimer(
            withTimeInterval: 2.5,
            repeats: false
        ) { [weak self] _ in
            self?.merge()
        }
    }
    
    private func merge() {
        var merged = attributionBuffer
        
        deeplinkBuffer.forEach { key, value in
            let enhancedKey = "deep_\(key)"
            if merged[enhancedKey] == nil {
                merged[enhancedKey] = value
            }
        }
        
        onAttributionReceived?(merged)
    }
    
}
