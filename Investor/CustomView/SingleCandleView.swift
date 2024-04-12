//
//  SingleCandleView.swift
//  Investor
//
//  Created by 홍정연 on 3/20/24.
//

import UIKit
import SnapKit

// MARK: 개장시간 기준 하루동안의 등락폭을 시각적으로 표현하는 뷰
class SingleCandleView: UIView {
    
    // MARK: 등락폭 표시의 최대치(30%)
    private let maxRate:Double = 30
    
    // MARK: 중앙 선(가로)
    private let evenRow: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.backgroundEven
        return view
    }()
    
    // MARK: 당일 최고점 표시 선(세로)
    private let riseRow: UIView = {
        let view = UIView()
        
        return view
    }()
    
    // MARK: 당일 최저점 표시 선(세로)
    private let fallRow: UIView = {
        let view = UIView()
        return view
    }()
    
    
    // MARK: 당일 최고점 표시 뷰
    private let riseView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.tintRise1
        return view
    }()
    
    // MARK: 당일 최저점 표시 뷰
    private let fallView: UIView = {
        let view = UIView()
        view.backgroundColor = ThemeColor.tintFall1
        return view
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
        self.backgroundColor = ThemeColor.background2
        
        let riseContentView = UIView()
        let fallContentView = UIView()
        
        [evenRow, riseContentView, fallContentView].forEach(self.addSubview(_:))
        [riseView, riseRow].forEach(riseContentView.addSubview(_:))
        [fallView, fallRow].forEach(fallContentView.addSubview(_:))
        
        evenRow.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        riseContentView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(evenRow.snp.top)
        }
        
        fallContentView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(evenRow.snp.bottom)
        }
        
        riseView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0)
        }
        
        fallView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0)
        }
        
        riseRow.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(0)
        }
        
        fallRow.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(0)
        }
    }
    
    // MARK: 변화된 값으로 뷰의 등락폭 및 색상을 결정
    func update(change: ChangeType, market: String, rate:Double, highPrice: Double, lowPrice: Double, closingPrice: Double) {
        self.setColor(with: change)
        self.updateConstraints(for: change, with: rate)
        self.updateRows(with: highPrice, lowPrice: lowPrice, closingPrice: closingPrice)
    }
    
    // MARK: 변화타입에 따라 객체의 색상 지정
    private func setColor(with change: ChangeType) {
        self.riseView.backgroundColor = change.color
        self.riseRow.backgroundColor = change.color
        self.evenRow.backgroundColor = change.color
        self.fallView.backgroundColor = change.color
        self.fallRow.backgroundColor = change.color
    }
    
    // MARK: 제약 조건 업데이트
    private func updateConstraints(for change: ChangeType, with rate: Double) {
        // 표시할 퍼센트 영역 최대값 30% (30% 이상일 시 100%로 고정)
        let displayRate = min((rate / maxRate) * 100, 1.0)
        
        switch change {
        case .even:
            updateHeightConstraints(for: 0, with: 0)
        case .rise:
            updateHeightConstraints(for: displayRate, with: 0)
        case .fall:
            updateHeightConstraints(for: 0, with: displayRate)
        }
    }
    
    
    // MARK: 높이 제약 조건 업데이트
    private func updateHeightConstraints(for riseRate: Double, with fallRate: Double) {
        riseView.snp.remakeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(riseRate)
        }
        
        fallView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(fallRate)
        }
    }
    
    // MARK: 행 업데이트
    private func updateRows(with highPrice: Double, lowPrice: Double, closingPrice: Double) {
        riseRow.snp.remakeConstraints { make in
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(getChangeRate(closingPrice: closingPrice, recordPrice: highPrice))
        }
        
        fallRow.snp.remakeConstraints { make in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.height.equalToSuperview().multipliedBy(getChangeRate(closingPrice: closingPrice, recordPrice: lowPrice))
        }
    }
    
    
    
    // MARK: 기존 종가 대비 절대값 변화율 반환함수
    private func getChangeRate(closingPrice:Double, recordPrice: Double) -> CGFloat {
        guard closingPrice != 0 else {
            
            return 0
        }
        
        let changeRate = CGFloat(abs((recordPrice - closingPrice) / closingPrice))
        let achievedPercentage = ( changeRate / maxRate ) * 100
        
        // MARK: 최대값은 1.0(100%)
        return min(achievedPercentage, 1.0)
    }
}
