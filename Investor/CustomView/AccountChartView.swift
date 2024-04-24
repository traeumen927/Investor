//
//  PieChartView.swift
//  Investor
//
//  Created by 홍정연 on 4/17/24.
//

import UIKit
import SnapKit
import DGCharts

class AccountChartView: UIView {
    
    private lazy var pieChart: PieChartView = {
        let chart = PieChartView()
        chart.noDataText = "데이터가 없습니다."
        chart.noDataFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        chart.rotationEnabled = false
        chart.isUserInteractionEnabled = false
        chart.rotationAngle = 0
        chart.drawHoleEnabled = true
        chart.chartDescription.enabled = false
        return chart
    }()
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        layout()
    }
    
    private func layout() {
        self.backgroundColor = ThemeColor.background1
        
        [pieChart].forEach(self.addSubview(_:))
        
        pieChart.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(12)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(300)
        }
    }
    
    // MARK: data binding
    func configure(with accounts: [Account]) {
        
    }
    
    func update(with pieData: [String:Double]) {
        var entries: [PieChartDataEntry] = []
        
        for pieItem in pieData {
            entries.append(PieChartDataEntry(value: pieItem.value, label: pieItem.key))
        }
        
        let colors = entries.map { entry in
            guard let label = entry.label else {
                return ThemeColor.primary1
            }
            return UIColor.colorForString(with: label)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = false
        dataSet.colors = colors
        
        self.pieChart.data = PieChartData(dataSet: dataSet)
    }
}
