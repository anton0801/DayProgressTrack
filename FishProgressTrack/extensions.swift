
import SwiftUI

extension Color {
    static let deepBlue = Color(hex: "071D2B")
    static let cardBlue = Color(hex: "103447")
    static let mintAccent = Color(hex: "6FE3C1")
    static let blueAccent = Color(hex: "4FC3F7")
    static let lightBlue = Color(hex: "9FE6FF")
    static let primaryText = Color.white
    static let secondaryText = Color(hex: "9CB6C9")
    static let errorRed = Color(hex: "FF8A8A")
    static let successGreen = Color(hex: "4CAF50")
    static let warningOrange = Color(hex: "FFA726")
    
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
