//
//  Double.swift
//  Investor
//
//  Created by 홍정연 on 2/20/24.
//

import Foundation

extension Double {
    // MARK: Double의 소수점 자릿수 제한
    func roundedString(places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = places
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    // MARK: 통화를 천의 자리마다 쉼표 표시 + 소수점 자릿수 제한
    func formattedStringWithCommaAndDecimal(places: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = places
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    // MARK: 증감율 계산
    func percentageRelativeTo(_ other: Double) -> Double {
            guard other != 0 else { return 0 }
            return (self / other) * 100
        }
}
