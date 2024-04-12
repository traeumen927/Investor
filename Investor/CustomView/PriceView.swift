//
//  InputView.swift
//  Investor
//
//  Created by 홍정연 on 3/24/24.
//

import UIKit
import SnapKit


// MARK: 현재가격, 변동률, 증감액을 보여주는 뷰
class PriceView: UIView {

    // MARK: 현재가 라벨
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.backgroundEven
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "₩0"
        return label
    }()
    
    // MARK: 변동가 라벨
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.backgroundEven
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.text = "0%"
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        [priceLabel, changeLabel].forEach(self.addSubview(_:))
        
        priceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide).offset(12)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
        }
        
        changeLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
    }
    
    // MARK: 현재가, 변동률 업데이트
    func update(ticker: TickerProtocol) {
        // MARK: 상승, 보합, 하락에 대한 색상 업데이트
        self.setColor(with: ticker.change.color)
        
        let changePrice = ticker.signed_change_price.formattedStringWithCommaAndDecimal(places: 2)
        let changeRate = ticker.signed_change_rate * 100
        
        // MARK: 현재가 업데이트
        self.priceLabel.text =  "₩\(ticker.trade_price.formattedStringWithCommaAndDecimal(places: 2))"
        
        // MARK: 변동률 업데이트
        self.changeLabel.text = "\(changeRate.formattedStringWithCommaAndDecimal(places: 2))%(\(changePrice))"
    }
    
    // MARK: 상승, 보합, 하락에 대한 색상 업데이트
    private func setColor(with color: UIColor) {
        self.priceLabel.textColor = color
        self.changeLabel.textColor = color
    }
}
