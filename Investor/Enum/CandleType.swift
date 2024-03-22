//
//  CandleType.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import Foundation

enum CandleType: String, CaseIterable {
    case months = "months"
    case weeks = "weeks"
    case days = "days"
    case minutes = "minutes"
    
    var displayName: String {
        switch self {
        case .months:
            return "월"
        case .weeks:
            return "주"
        case .days:
            return "일"
        case .minutes:
            return "분"
        }
    }
}
