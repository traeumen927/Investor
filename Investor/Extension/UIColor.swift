//
//  UIColor.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

struct ThemeColor {
    static let primary1 = UIColor(hexString: "1c2541")
    static let primary2 = UIColor(hexString: "1b3b6f")
    static let tint1 = UIColor(hexString: "f8f9fa")
    static let tint2 = UIColor(hexString: "ced4da")
    static let tintDisable = UIColor(hexString: "495057")
    static let background = UIColor(hexString: "0b132b")
    static let positive = UIColor(hexString: "c84a31")
    static let stable = UIColor(hexString: "bcb8b1")
    static let negative = UIColor(hexString: "1261c4")
    
}
