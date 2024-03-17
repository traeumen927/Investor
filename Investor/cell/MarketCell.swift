//
//  MarketCell.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import UIKit
import SnapKit

class MarketCell: UITableViewCell {
    
    // MARK: 코인 한글명
    private let korLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .bold)
        label.textColor = ThemeColor.tint1
        return label
    }()
    
    // MARK: 코인 영문명
    private let engLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = ThemeColor.tintDisable
        return label
    }()
    
    // MARK: 코인 심볼
    private let symbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        label.textColor = ThemeColor.tint2
        return label
    }()
   
    
    static let cellId = "cell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
        self.backgroundColor = .clear
        self.selectionStyle = .none
        
        [korLabel, engLabel, symbolLabel].forEach(self.contentView.addSubview(_:))
        
        korLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(12)
        }
        
        engLabel.snp.makeConstraints { make in
            make.bottom.equalTo(self.korLabel.snp.bottom)
            make.leading.equalTo(self.korLabel.snp.trailing).offset(4)
            make.trailing.lessThanOrEqualToSuperview().offset(-12)
        }
        
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(self.korLabel.snp.bottom).offset(4)
            make.leading.equalToSuperview().offset(12)
            make.trailing.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-8)
        }
    }
    
    func configure(with marketTicker: MarketTicker) {
        self.korLabel.text = marketTicker.marketInfo.koreanName
        self.engLabel.text = "\(marketTicker.socketTicker?.trade_price ?? marketTicker.apiTicker.trade_price)"
        self.symbolLabel.text = marketTicker.marketInfo.market
        
        
    }
    
    func update(with marketTicker: MarketTicker) {
        self.engLabel.text = "수정!!"
    }
}
