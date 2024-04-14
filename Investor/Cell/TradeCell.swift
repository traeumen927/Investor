//
//  TradeCell.swift
//  Investor
//
//  Created by 홍정연 on 4/11/24.
//

import UIKit
import SnapKit

class TradeCell: UITableViewCell {
    static let cellId = "TradeCell"
    
    // MARK: 체결가 라벨
    private var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ThemeColor.tintEven
        return label
    }()
    
    // MARK: 체결량 라벨
    private var sizeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = ThemeColor.tintEven
        label.minimumScaleFactor = 0.5
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func layout() {
        self.contentView.backgroundColor = ThemeColor.background1
        [priceLabel, sizeLabel].forEach(self.contentView.addSubview(_:))
        
        priceLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.sizeLabel.snp.leading).offset(-8)
        }
        
        sizeLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-4)
            make.width.equalToSuperview().multipliedBy(0.4)
        }
    }
    
    // MARK: 체결정보로 셀 업데이트
    func configure(with trade: Trade) {
        self.priceLabel.text = "₩\(trade.trade_price.formattedStringWithCommaAndDecimal(places: 2))"
        self.priceLabel.textColor = trade.change.color
        
        
        self.sizeLabel.text = trade.trade_volume.formattedStringWithCommaAndDecimal(places: 3, removeZero: false)
        guard let ab = trade.ask_bid else {return}
        self.sizeLabel.textColor = ab == .ask ? ThemeColor.tintFall1 : ThemeColor.tintRise1
    }
}
