import UIKit

extension UIColor {
    static let primaryColor = UIColor(hex: "#546A76")
    static let secondaryColor = UIColor(hex: "#88A0A8")
    static let accentColor = UIColor(hex: "#B4CEB3")
    static let backgroundColor = UIColor(hex: "#DBD3C9")
    static let alertColor = UIColor(hex: "#FAD4D8")
    // Home-specific tones
    static let homeBackground = UIColor(hex: "#F5F7F8")
    static let homeCardBackground = UIColor(hex: "#D1D8DD")
    static let homePrimary = UIColor(hex: "#546A76")
    static let homeSecondary = UIColor(hex: "#7A8A97")
    static let homeAccent = UIColor(hex: "#88A0A8")
    // Impact-specific tones
    static let impactPrimary = UIColor(hex: "#BC96E6")
    static let impactBackground = UIColor(hex: "#F3EDFA")
    static let impactSecondary = UIColor(hex: "#A47EDB")
    static let impactAccent = UIColor(hex: "#D1B8F0")
    static let impactDark = UIColor(hex: "#210B2C")
    static let impactPurple = UIColor(hex: "#55286F")
    static let impactLila = UIColor(hex: "#BC96E6")
    static let impactPink = UIColor(hex: "#D8B4E2")
    static let impactMid = UIColor(hex: "#AE759F")
    
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000FF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
} 