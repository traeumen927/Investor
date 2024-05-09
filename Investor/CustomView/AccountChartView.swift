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
    
    // MARK: 자산정보 리스트
    private var accountList: [Account] = []
    
    // MARK: PieChart 데이터
    private var pieData: [String: Double] = [:]
    
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
    
    // MARK: data binding, 자산 변동 및 자산 페이지 진입 시 호출
    func bind(with accounts: [Account]) {
        self.accountList = accounts
        
        // MARK: 새로운 데이터를 계산하여 combinedDataSubject에 업데이트
        self.pieData = Dictionary(uniqueKeysWithValues: accounts.map { account in
            if account.currency == "KRW" {
                // MARK: 원화라면 원화 보유 수량을 자산으로 배치
                return (account.currency, account.balance)
            } else {
                // MARK: 코인이라면 보유수량 * 평균 구매가를 자산으로 배치
                return (account.currency, account.balance * account.avg_buy_price)
            }
        })
        
        // MARK: 업데이트된 자산 내역으로 PieChart reload
        self.reloadPieChart()
    }
    
    // MARK: 현재가 변동 시 자산가치 업데이트
    func update(with ticker: SocketTicker) {
        // MARK: 기존의 자산정보 내에서 일치하는 항목
        if let account = accountList.first(where: { "KRW-\($0.currency)" == ticker.code}) {
            // MARK: 자산수량 * 현재가로 업데이트
            self.pieData[account.currency] = account.balance * ticker.trade_price
        }
        
        // MARK: 업데이트된 자산 내역으로 PieChart reload
        self.reloadPieChart()
    }
    
    
    // MARK: PieChart 초기화
    private func reloadPieChart() {
        
        var entries = [PieChartDataEntry]()
        
        // MARK: 가치가 높은 순으로 정렬
        for pieItem in self.pieData.sorted(by: { $0.value > $1.value }) {
            // MARK: 가치가 0 이상인 경우 PieChart에 삽입
            if pieItem.value > 0 {
                entries.append(PieChartDataEntry(value: pieItem.value, label: pieItem.key))
            }
        }
        
        // MARK: 각 label의 색상 설정
        let colors = entries.map { entry in
            guard let label = entry.label else {
                return ThemeColor.primary1
            }
            return UIColor.colorForString(with: label)
        }
        
        let dataSet = PieChartDataSet(entries: entries, label: "")
        dataSet.drawValuesEnabled = false
        dataSet.colors = colors
        
        let pieData = PieChartData(dataSet: dataSet)
        
        self.pieChart.data = pieData
    }
}



