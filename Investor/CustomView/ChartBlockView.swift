//
//  ChartBlockView.swift
//  Investor
//
//  Created by 홍정연 on 3/21/24.
//

import UIKit
import SnapKit

class ChartBlockView: BlockView {
    
    // MARK: 현재가 라벨
    private let priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.stable
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.text = "₩0"
        return label
    }()
    
    // MARK: 변동가 라벨
    private let changeLabel: UILabel = {
        let label = UILabel()
        label.textColor = ThemeColor.stable
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.text = "0%"
        return label
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
        [priceLabel, changeLabel].forEach(contentView.addSubview(_:))

        
        priceLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(12)
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
}
