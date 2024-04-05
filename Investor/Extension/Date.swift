//
//  Date.swift
//  Investor
//
//  Created by 홍정연 on 3/25/24.
//

import Foundation


extension Date {
    // MARK: 날짜 -> String 변환: 오늘이면 AM/PM hh:ymm, 오늘이 아니면 yy.MM.dd 리턴
    func formattedString() -> String {
        let formatter = DateFormatter()
        
        if Calendar.current.isDateInToday(self) {
            formatter.dateFormat = "a hh:mm"
        } else {
            formatter.dateFormat = "yy.MM.dd"
        }
        
        return formatter.string(from: self)
    }
    
    // MARK: 날짜 -> 포맷에 맞는 String 변환
    func toString(withFormat format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
}
