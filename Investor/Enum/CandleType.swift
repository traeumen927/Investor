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
    
    // MARK: 세그먼트컨트롤 버튼표시
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
    
    
    // MARK: 차트의 Date Format String  
    var chartDateFormat: String {
        switch self {
        case .months:
            return "MM"
        case .weeks:
            return "MM-dd"
        case .days:
            return "MM-dd"
        case .minutes:
            return "HH:mm"
        }
    }
}
