//
//  UIColor.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import UIKit
import CryptoKit

extension UIColor {
    // MARK: HexString to UIColor 변환
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
    
    
    // MARK: SHA-256 기반 String에 매칭된 색상 추출
    static func colorForUserId(userId: String) -> UIColor {
        // MARK:  SHA-256 해시 생성
        let inputData = Data(userId.utf8)
        let hashedData = SHA256.hash(data: inputData)
        
        // MARK:  해시된 값을 바이트 배열로 변환하여 RGB 색상 값 생성
        var colorComponents: [CGFloat] = []
        for byte in hashedData {
            colorComponents.append(CGFloat(byte) / 255.0) // MARK:  각 바이트 값을 [0, 1] 범위로 정규화하여 사용
        }
        
        return UIColor(red: colorComponents[0], green: colorComponents[1], blue: colorComponents[2], alpha: 1.0)
    }

}

// MARK: 앱에서 사용하는 컬러 목록
struct ThemeColor {
    ///대표색상1
    static let primary1 = UIColor(hexString: "191919")
    
    ///밝은 틴트색상
    static let tintLight = UIColor(hexString: "f8f9fa")
    
    ///짙은 틴트색상
    static let tintDark = UIColor(hexString: "212529")
    
    ///비활성화색상
    static let tintDisable = UIColor(hexString: "495057")
    
    ///배경색상1
    static let background1 = UIColor(hexString: "f8f9fa")
    
    ///배경색상2
    static let background2 = UIColor(hexString: "dee2e6")
    
    ///상승색상
    static let positive = UIColor(hexString: "c84a31")
    
    ///보합색상
    static let stable = UIColor(hexString: "6c757d")
    
    ///하락색상
    static let negative = UIColor(hexString: "1261c4")
}
