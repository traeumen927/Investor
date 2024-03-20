//
//  MarketCell.swift
//  Investor
//
//  Created by 홍정연 on 3/7/24.
//

import UIKit
import SnapKit

class MarketCell: UICollectionViewCell {
    static let cellId = "MarketCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.titleLabel.text = nil
        self.priceLabel.text = nil
    }
    
    private func setupUI() {
        addSubview(titleLabel)
        addSubview(priceLabel)
        
        [titleLabel, priceLabel].forEach(self.contentView.addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(8)
            make.centerY.equalToSuperview()
        }
        
        priceLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-8)
            make.centerY.equalToSuperview()
        }
    }
    
    func configure(with marketTicker: MarketTicker) {
        titleLabel.text = marketTicker.marketInfo.market
        priceLabel.text = "\(marketTicker.socketTicker?.trade_price ?? marketTicker.apiTicker.trade_price)"
    }
}
