//
//  DateValueFormatter.swift
//  Investor
//
//  Created by 홍정연 on 4/5/24.
//

import Foundation
import DGCharts

// MARK: DGChart에서 x축에 배치할 날짜 데이터 포멧 모델
class DateValueFormatter: NSObject, AxisValueFormatter {
    private let dateFormatter: DateFormatter
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // MARK: TimeStamp -> Date 변환
        let date = Date(timeIntervalSince1970: value)
        
        // MARK: DateFormat에 맞는 String 반환
        return dateFormatter.string(from: date)
    }
}
