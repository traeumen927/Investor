//
//  DateAxisValueFormatter.swift
//  Investor
//
//  Created by 홍정연 on 4/5/24.
//

import Foundation
import DGCharts

// MARK: DGChart에서 x축에 배치할 날짜 데이터 포멧 모델
class DateAxisValueFormatter: NSObject, AxisValueFormatter {
    private var dates: [Date]
    private let dateFormatter: DateFormatter

    init(dates: [Date], dateFormatter: DateFormatter) {
        self.dates = dates
        self.dateFormatter = dateFormatter
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // value를 정수로 변환하여 해당 인덱스에 대응하는 날짜를 가져옵니다.
        let index = Int(value)
        guard index >= 0, index < dates.count else {
            return ""
        }
        // 해당 인덱스에 대응하는 날짜를 포맷팅하여 반환합니다.
        return dateFormatter.string(from: dates[index])
    }
}
