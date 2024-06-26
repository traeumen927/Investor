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
    func formattedStringWithCommaAndDecimal(places: Int, removeZero: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = removeZero ? 0 : places
        formatter.maximumFractionDigits = places
        
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    // MARK: 통화 포맷
    func formattedStringWithDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
    
    // MARK: 증감율 계산
    func percentageRelativeTo(to other: Double) -> Double {
        guard other != 0 else { return 0 }
        return (self / other) * 100
    }
    
    // MARK: 변화율 계산
    func percentageDifference(to other: Double) -> Double {
        guard self != 0 else { return 0 }
        
        let difference = other - self
        let percentage = (difference / self) * 100
        return percentage
    }
}
